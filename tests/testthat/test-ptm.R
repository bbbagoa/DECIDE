# Post-targeting monitoring: the verification sample and decisions by area.

test_that("sample sizes follow the margin of error with the finite-population correction", {
  n <- TargetWise:::ptm_sample_size(c(20, 500, 1e6), margin = 0.10)
  expect_equal(n[1], 17)                         # a group of 20: most of it, not all (finite population)
  expect_true(n[2] < 97 && n[2] > 75)
  expect_equal(n[3], 97)                         # 1.96^2 / (4 * 0.1^2) rounded up
})

test_that("the sample is stratified by area and group, without households excluded by design", {
  set.seed(3); N <- 4000
  area <- sample(c("A", "B"), N, TRUE)
  st <- sample(c("selected", "not_selected", "by_design"), N, TRUE, prob = c(.3, .6, .1))
  d <- TargetWise:::ptm_draw(st, area, list(mode = "fixed", n = 40), reserve = 0.25, seed = 1)
  expect_equal(nrow(d$design), 4)
  expect_true(all(d$design$n == 40) && all(d$design$reserve == 10))
  expect_false(any(duplicated(d$rows$row)))
  expect_true(all(st[d$rows$row] %in% c("selected", "not_selected")))
  expect_true(all(area[d$rows$row] == d$rows$area) && all(st[d$rows$row] == d$rows$group))
  pop <- TargetWise:::ptm_population(d$design)
  expect_equal(sum(pop$beneficiaries), sum(st == "selected"))
  expect_equal(sum(pop$non_beneficiaries), sum(st == "not_selected"))
  # the same seed draws the same households
  expect_identical(TargetWise:::ptm_draw(st, area, list(mode = "fixed", n = 40), reserve = 0.25, seed = 1)$rows, d$rows)
})

test_that("each area gets its own decision, and small areas are not judged", {
  set.seed(5)
  ar <- rep(c("Good", "Bad", "Small"), c(200, 200, 20))
  sel <- c(rep(c(TRUE, FALSE), 100), rep(c(TRUE, FALSE), 100), rep(c(TRUE, FALSE), 10))
  el <- sel
  bad <- ar == "Bad"; el[bad] <- ifelse(sel[bad], runif(sum(bad)) < 0.5, runif(sum(bad)) < 0.5)
  d <- TargetWise:::ptm_area_decisions(sel, el, ar, min_n = 30)
  expect_equal(d$area[1], "Bad")                                  # worst first
  expect_match(d$decision[d$area == "Bad"], "Pause")
  expect_match(d$decision[d$area == "Good"], "Proceed")
  expect_equal(d$level[d$area == "Small"], "few")
  after <- TargetWise:::ptm_area_decisions(sel, el, ar, min_n = 30, before = FALSE)
  expect_match(after$decision[after$area == "Bad"], "next round")
})

test_that("Monitoring draws the sample from the selection and measures the errors on the survey", {
  set.seed(7); N <- 3000
  reg <- data.frame(hh_id = sprintf("H%05d", 1:N), province = sample(c("North", "South"), N, TRUE),
                    stringsAsFactors = FALSE)
  served <- runif(N) < 0.35
  eligible <- served | runif(N) < 0.05                               # a few excluded by design
  setup <- shiny::reactiveValues(unique_id = "hh_id", admin1 = "province")
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                       new_value = character(0), action = character(0), user = character(0), reason = character(0)))
  shiny::testServer(TargetWise:::mod_pdm_server,
                    args = list(workspace = TargetWise:::workspace_new(), user_setup = setup, modification_log = log,
                                selection = shiny::reactive(list(df = reg, served = served, eligible = eligible))), {
    session$setInputs(ptm_level = "province", ptm_size_mode = "fixed", ptm_n = 50, ptm_reserve = 10, ptm_seed = 1, ptm_draw = 1)
    sd <- sample_design()
    expect_false(is.null(sd))
    expect_equal(sum(sd$design$n), 200)                              # 2 areas x 2 groups x 50
    expect_false(any(sd$list$household_id %in% reg$hh_id[eligible & !served]))   # excluded by design stay out
    # the survey: the main households, with their true eligibility (North mostly wrong)
    main <- sd$list[sd$list$role == "main", ]
    grp <- sd$group[sd$list$role == "main"]
    truth <- grp == "Selected"
    north <- main$province == "North"
    truth[north] <- runif(sum(north)) < 0.5
    survey <- data.frame(hh_id = main$household_id, eligible_now = ifelse(truth, "Yes", "No"), stringsAsFactors = FALSE)
    pdm_df(survey)
    session$setInputs(data_kind = "Baseline", benef_source = "design", ptm_id = "hh_id",
                      pdm_elig_source = "column", pdm_eligibility = "eligible_now",
                      pdm_weight_mode = "design", pdm_prioritized = "(none)", pdm_unit = "(none)",
                      tol_lower = 5, tol_upper = 20)
    expect_equal(ptm_matched()$n, 100 * 2)
    session$setInputs(pdm_run = 1)
    r <- results()
    expect_false(is.null(r))
    expect_match(r$weighting, "sample design")
    d <- r$decisions
    expect_setequal(d$area, c("North", "South"))
    expect_match(d$decision[d$area == "North"], "Pause|Review")
    expect_match(d$decision[d$area == "South"], "Proceed")
  })
})
