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

test_that("a survey that kept the sample columns is enough on its own", {
  set.seed(7); N <- 3000
  reg <- data.frame(hh_id = sprintf("H%05d", 1:N), province = sample(c("North", "South"), N, TRUE), stringsAsFactors = FALSE)
  served <- runif(N) < 0.35
  status <- ifelse(served, "selected", "not_selected")
  d <- DECIDE:::ptm_draw(status, reg$province, list(mode = "fixed", n = 50), reserve = 0, seed = 1)
  main <- DECIDE:::ptm_sample_lists(reg, d, list(unique_id = "hh_id", admin1 = "province"))$main
  expect_true("sample_group_size" %in% names(main))
  # the survey: the preloaded sample columns (under a form group) and the answers
  truth <- main$eligibility == "Eligible"
  north <- main$province == "North"
  truth[north] <- runif(sum(north)) < 0.5
  survey <- data.frame(`pre/household_id` = main$household_id, `pre/eligibility` = main$eligibility,
                       `pre/sample_area` = main$sample_area, `pre/sample_group_size` = as.character(main$sample_group_size),
                       eligible_now = ifelse(truth, "Yes", "No"), check.names = FALSE, stringsAsFactors = FALSE)
  sv <- DECIDE:::ptm_survey_design(survey)
  expect_equal(sv$id_col, "pre/household_id")
  # the group sizes are the population's, as in the Design sheet
  expect_equal(sum(sv$design$N[sv$design$group == "selected"]), sum(served))
  expect_null(DECIDE:::ptm_survey_design(survey["eligible_now"]))

  setup <- shiny::reactiveValues(unique_id = "hh_id", admin1 = "province")
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                       new_value = character(0), action = character(0), user = character(0), reason = character(0)))
  shiny::testServer(DECIDE:::mod_pdm_server,
                    args = list(workspace = DECIDE:::workspace_new(), user_setup = setup, modification_log = log), {
    take_pdm(survey, "survey.csv")
    expect_true(isTRUE(sample_design()$from_survey))
    session$setInputs(data_kind = "Baseline", benef_source = "design", ptm_id = "pre/household_id",
                      pdm_elig_source = "column", pdm_eligibility = "eligible_now",
                      pdm_weight_mode = "design", pdm_prioritized = "(none)", pdm_unit = "(none)",
                      tol_lower = 5, tol_upper = 20)
    expect_equal(ptm_matched()$n, 200)
    session$setInputs(pdm_run = 1)
    r <- results()
    expect_match(r$weighting, "sample design")
    expect_setequal(r$decisions$area, c("North", "South"))
    expect_match(r$decisions$decision[r$decisions$area == "North"], "Pause|Review")
    # a survey without the columns drops the previous survey's sample
    take_pdm(survey["eligible_now"], "other.csv")
    expect_null(sample_design())
  })
})

test_that("Monitoring applies only the selection logic loaded there, not the card adopted elsewhere", {
  card <- list(kind = "scorecard", outcome = "poor", threshold = 0, created = "2026-01-01",
               items = list(list(criterion = "tent", direction = "inclusion", weight = 1)))
  logic <- list(format = "DECIDE selection logic", version = 1, approach = "scorecard", approach_label = "Scorecard", combine = "both",
                scorecard = card)
  jf <- tempfile(fileext = ".json"); jsonlite::write_json(logic, jf, auto_unbox = TRUE)
  setup <- shiny::reactiveValues(scorecard = DECIDE:::normalise_scorecard(card))   # adopted in Design
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                       new_value = character(0), action = character(0), user = character(0), reason = character(0)))
  shiny::testServer(DECIDE:::mod_pdm_server,
                    args = list(workspace = DECIDE:::workspace_new(), user_setup = setup, modification_log = log), {
    pdm_df(data.frame(id = 1:4, `grp/Tent` = c(1, 0, 1, 0), check.names = FALSE))
    session$setInputs(pdm_elig_source = "logic")
    expect_null(pdm_card())
    expect_match(elig_note()$text, "Load the selection logic")
    session$setInputs(pdm_logic_file = list(datapath = jf, name = "logic.json"))
    expect_equal(length(pdm_card()$items), 1)
    expect_match(elig_note()$text, "Scorecard")
    # found under the form's group path, whatever the case
    expect_equal(DECIDE:::logic_eligibility(pdm_df(), pdm_logic())$eligible, c(TRUE, FALSE, TRUE, FALSE))
  })
})

test_that("the Implementation errors workbook follows the page", {
  dd <- data.frame(area = c("North", "South"), n_selected = c(40, 50), n_not = c(35, 45), eligible = c(300, 420), reached = c(150, 410),
                   coverage = c(0.5, 0.976), inclusion_error = c(0.3, 0.04), exclusion_error = c(0.5, 0.024),
                   level = c("redesign", "good"), decision = c("Pause", "Proceed"), stringsAsFactors = FALSE)
  r <- list(kind = "Baseline", n = 400, n_known = 390, benef_col = "the sample list", elig_source = "the scorecard", weighting = "sample design",
            metrics = list(inclusion_error = 0.491, exclusion_error = 0.777, coverage_rate = 0.223, precision = 0.509),
            matrix = list(correct_in = 176, incl = 170, excl = 612, correct_out = 542, n_correct_in = 176, n_incl = 170, n_excl = 612, n_correct_out = 542),
            by_level = list(list(label = "Province", rows = dd), list(label = "Admin 2 \u00b7 Territoire", rows = dd)))
  wb <- DECIDE:::pdm_workbook(r, tol = c(0.05, 0.2), meta = c(`Country office` = "Chad"))
  expect_equal(names(wb), c("Summary", "Matrix", "Areas - Province", "Areas - Territoire"))
  f <- tempfile(fileext = ".xlsx"); openxlsx::saveWorkbook(wb, f)
  mx <- openxlsx::read.xlsx(f, "Matrix", colNames = FALSE, skipEmptyRows = FALSE)
  expect_equal(as.numeric(mx[5, 3]), 170)
  expect_match(mx[6, 3], "49.1% of the assisted - inclusion error", fixed = TRUE)
  ar <- openxlsx::read.xlsx(f, "Areas - Province")
  expect_equal(names(ar)[c(4, 6, 9)], c("Eligible.(est.)", "Coverage", "Decision"))
  sm <- openxlsx::read.xlsx(f, "Summary", colNames = FALSE)
  expect_true(any(grepl("49.1% (beyond the tolerance band)", sm[[2]], fixed = TRUE)))
  expect_equal(names(DECIDE:::pdm_workbook(NULL)), "Summary")
})
