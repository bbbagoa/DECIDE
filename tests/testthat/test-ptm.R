# Post-targeting monitoring: the verification sample and decisions by area.

test_that("sample sizes follow the margin of error with the finite-population correction", {
  n <- DECIDE:::ptm_sample_size(c(20, 500, 1e6), margin = 0.10)
  expect_equal(n[1], 17)                         # a group of 20: most of it, not all (finite population)
  expect_true(n[2] < 97 && n[2] > 75)
  expect_equal(n[3], 97)                         # 1.96^2 / (4 * 0.1^2) rounded up
})

test_that("the sample is stratified by area and group, without households excluded by design", {
  set.seed(3); N <- 4000
  area <- sample(c("A", "B"), N, TRUE)
  st <- sample(c("selected", "not_selected", "by_design"), N, TRUE, prob = c(.3, .6, .1))
  d <- DECIDE:::ptm_draw(st, area, list(mode = "fixed", n = 40), reserve = 0.25, seed = 1)
  expect_equal(nrow(d$design), 4)
  expect_true(all(d$design$n == 40) && all(d$design$reserve == 10))
  expect_false(any(duplicated(d$rows$row)))
  expect_true(all(st[d$rows$row] %in% c("selected", "not_selected")))
  expect_true(all(area[d$rows$row] == d$rows$area) && all(st[d$rows$row] == d$rows$group))
  pop <- DECIDE:::ptm_population(d$design)
  expect_equal(sum(pop$beneficiaries), sum(st == "selected"))
  expect_equal(sum(pop$non_beneficiaries), sum(st == "not_selected"))
  # the same seed draws the same households
  expect_identical(DECIDE:::ptm_draw(st, area, list(mode = "fixed", n = 40), reserve = 0.25, seed = 1)$rows, d$rows)
})

test_that("each area gets its own decision, and small areas are not judged", {
  set.seed(5)
  ar <- rep(c("Good", "Bad", "Small"), c(200, 200, 20))
  sel <- c(rep(c(TRUE, FALSE), 100), rep(c(TRUE, FALSE), 100), rep(c(TRUE, FALSE), 10))
  el <- sel
  bad <- ar == "Bad"; el[bad] <- ifelse(sel[bad], runif(sum(bad)) < 0.5, runif(sum(bad)) < 0.5)
  d <- DECIDE:::ptm_area_decisions(sel, el, ar, min_n = 30)
  expect_equal(d$area[1], "Bad")                                  # worst first
  expect_match(d$decision[d$area == "Bad"], "Pause")
  expect_match(d$decision[d$area == "Good"], "Proceed")
  expect_equal(d$level[d$area == "Small"], "few")
  after <- DECIDE:::ptm_area_decisions(sel, el, ar, min_n = 30, before = FALSE)
  expect_match(after$decision[after$area == "Bad"], "next round")
})

test_that("the sample list drawn in Selection goes to the field and comes back to Monitoring", {
  set.seed(7); N <- 3000
  reg <- data.frame(hh_id = sprintf("H%05d", 1:N), province = sample(c("North", "South"), N, TRUE),
                    HHHName = paste("Name", 1:N), HHHSex = sample(c("M", "F"), N, TRUE), Phone = sprintf("0812%06d", 1:N),
                    stringsAsFactors = FALSE)
  served <- runif(N) < 0.35
  eligible <- served | runif(N) < 0.05                               # a few excluded by design
  status <- ifelse(served, "selected", ifelse(eligible, "by_design", "not_selected"))
  st <- list(unique_id = "hh_id", admin1 = "province", hhh_sex = "HHHSex")
  d <- DECIDE:::ptm_draw(status, reg$province, list(mode = "fixed", n = 50), reserve = 0.1, seed = 1)
  lists <- DECIDE:::ptm_sample_lists(reg, d, st)
  # what the field team needs to find each household
  expect_true(all(c("household_id", "eligibility", "sample_area", "province", "HHHName", "HHHSex", "Phone") %in% names(lists$main)))
  expect_equal(nrow(lists$main), 200)                                # 2 areas x 2 groups x 50
  expect_equal(nrow(lists$replacements), 20)
  expect_false(any(c(lists$main$household_id, lists$replacements$household_id) %in% reg$hh_id[status == "by_design"]))
  f <- tempfile(fileext = ".xlsx")
  DECIDE:::save_workbook_readonly(DECIDE:::ptm_sample_workbook(lists, d$design, kind = "Baseline",
                                        meta = list("Survey" = "Post-targeting survey / baseline", "Household ID column" = "hh_id",
                                                    "Areas by" = "province")), f)
  back <- DECIDE:::ptm_read_sample(f)
  expect_equal(nrow(back$list), 220)
  expect_equal(back$id_col, "hh_id")
  expect_equal(sum(back$design$N[back$design$group == "selected"]), sum(served))

  setup <- shiny::reactiveValues(unique_id = "hh_id", admin1 = "province")
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                       new_value = character(0), action = character(0), user = character(0), reason = character(0)))
  shiny::testServer(DECIDE:::mod_pdm_server,
                    args = list(workspace = DECIDE:::workspace_new(), user_setup = setup, modification_log = log), {
    # the survey: the main households, with their true eligibility (North mostly wrong)
    main <- lists$main
    truth <- main$eligibility == "Eligible"
    north <- main$province == "North"
    truth[north] <- runif(sum(north)) < 0.5
    survey <- data.frame(hh_id = main$household_id, eligible_now = ifelse(truth, "Yes", "No"), stringsAsFactors = FALSE)
    pdm_df(survey)
    session$setInputs(ptm_sample_file = list(datapath = f, name = "sample.xlsx"))
    expect_false(is.null(sample_design()))
    session$setInputs(data_kind = "Baseline", benef_source = "design", ptm_id = "hh_id",
                      pdm_elig_source = "column", pdm_eligibility = "eligible_now",
                      pdm_weight_mode = "design", pdm_prioritized = "(none)", pdm_unit = "(none)",
                      tol_lower = 5, tol_upper = 20)
    expect_equal(ptm_matched()$n, 200)
    session$setInputs(pdm_run = 1)
    r <- results()
    expect_false(is.null(r))
    expect_match(r$weighting, "sample design")
    dd <- r$decisions
    expect_setequal(dd$area, c("North", "South"))
    expect_match(dd$decision[dd$area == "North"], "Pause|Review")
    expect_match(dd$decision[dd$area == "South"], "Proceed")
  })
})

test_that("Monitoring calculates the food security indicators on the survey and takes them as eligibility", {
  fcs <- utils::read.csv(testthat::test_path("fixtures", "wfp", "FCS_Sample_Survey.csv"), na.strings = c("n/a", ""))
  set.seed(2)
  fcs$received <- sample(c("Assisted", "Not assisted"), nrow(fcs), TRUE)
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                       new_value = character(0), action = character(0), user = character(0), reason = character(0)))
  shiny::testServer(DECIDE:::mod_pdm_server,
                    args = list(workspace = DECIDE:::workspace_new(), user_setup = shiny::reactiveValues(), modification_log = log), {
    pdm_df(fcs)
    session$setInputs(`fsi-use_fcs` = TRUE, `fsi-fcs_threshold` = "21", `fsi-compute` = 1)
    expect_true("FCS_PoorBorderline" %in% names(pdm_all()))
    expect_equal(DECIDE:::guess_vulnerable_answer(c("Food insecure", "Food secure")), "Food insecure")
    expect_equal(DECIDE:::guess_vulnerable_answer(c("Food secure", "Not food insecure", "Food insecure")[c(1, 3)]), "Food insecure")
    session$setInputs(benef_source = "column", pdm_beneficiary = "received", pdm_benef_level = "Assisted",
                      pdm_elig_source = "column", pdm_eligibility = "FCS_PoorBorderline", pdm_weight_mode = "none",
                      pdm_prioritized = "(none)", pdm_unit = "(none)", tol_lower = 5, tol_upper = 20, pdm_run = 1)
    r <- results()
    expect_false(is.null(r))
    expect_true(is.finite(r$metrics$inclusion_error))
  })
})
