tm <- function(f) utils::getFromNamespace(f, "TargetWise")

test_that("markdown tables escape pipes and keep one row per record", {
  md <- tm("md_table")(data.frame(a = c("x|y", NA), b = c(1.23456, 2)))
  expect_equal(length(md), 4)
  expect_match(md[3], "x\\\\|y", fixed = FALSE)
  expect_equal(tm("md_table")(data.frame()), "_None._")
})

test_that("a partial design still produces a report with its figures", {
  set.seed(1)
  y <- rbinom(200, 1, 0.5)
  score <- pmax(0, 2 * y + rnorm(200))
  w <- data.frame(criterion = c("a", "b"), coefficient = c(0.8, -0.5), odds_ratio = exp(c(0.8, -0.5)),
                  p_value = c(0.001, 0.03), direction = c("inclusion", "exclusion"), weight = c(2.2, 0.6))
  e <- tm("design_errors")(score > 1, y == 1)
  x <- list(source = "demo.csv", n_rows = 200, n_cols = 5,
            calc_vars = data.frame(name = "a", definition = "Condition: size at least 7", created = "2026-09-23"),
            outcome = "cari", outcome_pos = "Food insecure", n_outcome = 200, n_vuln = sum(y), prevalence = mean(y),
            candidates = c("a", "b"), model = list(method = "Logistic", scheme = "Odds ratio", n_train = 160,
                                                   n_test = 40, seed = 1, weights = ""),
            estimates = w, threshold = 1, tolerance = c(0.05, 0.2), errors = e,
            verdict = list(interpretation = "OK", action = "None"))
  plots <- tm("design_report_plots")(weights = w, roc = tm("roc_curve")(score, y)$curve,
                                     score = score, vulnerable = y == 1, threshold = 1)
  f <- withr::local_tempfile(fileext = ".html")
  tm("write_design_report")(f, x, plots)
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, "<!DOCTYPE html>", fixed = TRUE)
  expect_match(html, "<table>", fixed = TRUE)
  expect_equal(lengths(regmatches(html, gregexpr("<figure class=\"fig\">", html, fixed = TRUE))), 3)
  expect_match(html, "billboard", fixed = TRUE)
  expect_match(html, "<div class=\"fig-row n2\">", fixed = TRUE)
  expect_false(grepl("@@FIG", html, fixed = TRUE))
  expect_match(html, "4. Criteria Screening", fixed = TRUE)
  expect_match(html, "No variables were selected", fixed = TRUE)
  expect_match(html, "Condition: size at least 7", fixed = TRUE)
  expect_match(html, "Not documented", fixed = TRUE)
  expect_false(grepl("base64,[A-Za-z0-9+/=]*\n", html))
  expect_match(html, "8. Methods", fixed = TRUE)
  expect_match(html, "7. Adoption", fixed = TRUE)
  expect_match(html, "Not adopted", fixed = TRUE)
  expect_match(html, "class=\"err-card", fixed = TRUE)
  expect_false(grepl("Effect by model", html, fixed = TRUE))
  expect_match(html, "logistic regression", fixed = TRUE)
})

test_that("the verification report writes the back-check with its cards, chart and method", {
  o <- data.frame(id = 1:6, a = c("x", "y", "z", "x", "y", "z"), n = 1:6)
  v <- data.frame(id = c(1:5, 9), a = c("x", "Y", "q", "x", "y", "z"), n = c(1:4, 9, 6))
  r <- tm("compare_verification")(o, v, "id")
  f <- withr::local_tempfile(fileext = ".html")
  tm("write_verification_report")(f, list(country_office = "Chad",
    sample = list(method = "Simple random", n = 6, population = 60, seed = 1, filters = "none"),
    source = "file back.csv", n_verification = 6, tolerance = 0, comparison = r))
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, "Verification report", fixed = TRUE)
  expect_match(html, "class=\"err-card", fixed = TRUE)
  expect_match(html, "<figure class=\"fig\">", fixed = TRUE)
  expect_match(html, "5. Method", fixed = TRUE)
  expect_match(html, "Chad", fixed = TRUE)
  expect_false(grepl("@@(FIG|AGREE)", html))
  # without a comparison it still writes the sample section
  tm("write_verification_report")(f, list(sample = list(method = "Systematic", n = 3, population = 10)))
  expect_match(paste(readLines(f), collapse = "\n"), "No comparison has been run yet", fixed = TRUE)
})

test_that("the data collection summary report is written from the Overview data", {
  df <- utils::read.csv(testthat::test_path("fixtures", "mini_targeting.csv"), stringsAsFactors = FALSE)
  st <- list(admin1 = "Province", admin2 = "Territoire", village = "Village", hh_size = "HHSize", hhh_sex = "HHHSex",
             enumerator_id = "enumerator", date = "SvyDate", v_score = "score", v_groups = "score_class",
             eligibility = "eligible", lon = "lon", lat = "lat", residency = "HHStatus")
  ga <- tm("overview_by_area")(df, st)
  expect_equal(ga$Households[ga$.kind == "total"], nrow(df))
  expect_equal(sum(ga$Households[ga$.kind == "group"]), nrow(df))
  f <- withr::local_tempfile(fileext = ".html")
  tm("write_overview_report")(f, df, st, list(n_total = nrow(df), areas = "All areas", period = "All dates", source = "test"))
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, "Data collection summary", fixed = TRUE)
  expect_match(html, 'class="area-sum"', fixed = TRUE)
  expect_match(html, "World_Topo_Map", fixed = TRUE)
  expect_false(grepl("@@", gsub("@@iterator", "", html), fixed = TRUE))
})

test_that("without vulnerability mapped, the data summary shows socio-economic indicators", {
  df <- data.frame(FCS_class = rep(c("Poor", "Acceptable"), 20), rCSI = rep(0:19, 2),
                   water_source = rep(c("Well", "Tap", "River", "Tap"), 10), `_id` = 1:40, check.names = FALSE)
  se <- tm("socioeconomic_indicators")(df)
  expect_equal(se$numbers$Column, "rCSI")
  expect_equal(unname(vapply(se$vars, attr, "", "label")),
               c("Food consumption group (FCS_class)", "Water source (water_source)"))
  expect_null(tm("socioeconomic_indicators")(data.frame(a = 1:3)))
  sc <- tm("rp_share_charts")(se$vars)
  expect_equal(sc$rows[1], "@@FIG:se_1,se_2@@")
})
