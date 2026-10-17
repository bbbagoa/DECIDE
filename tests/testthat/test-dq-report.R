test_that("the data quality report summarises every check on the fixture", {
  df <- utils::read.csv(testthat::test_path("fixtures", "mini_targeting.csv"), stringsAsFactors = FALSE)
  setup <- list(unique_id = "instanceID", date = "SvyDate", enumerator_id = "enumerator",
                admin1 = "Province", admin2 = "Territoire", lon = "lon", lat = "lat",
                hhh_sex = "HHHSex", hhh_age = "HHHAge", hh_size = "HHSize", childU5 = "childU5", v_score = "score")
  df$HHSize[1] <- 99; df$instanceID[2] <- df$instanceID[1]
  log <- data.frame(timestamp = "2026-01-01 10:00:00", uid = "x", column = "HHSize", old_value = "9", new_value = "8",
                    action = "Outlier correction", user = "", reason = "typo", stringsAsFactors = FALSE)
  x <- DECIDE:::dq_report_data(df, setup, log)
  expect_equal(x$n, nrow(df))
  expect_equal(x$dup_ids$ids, 1)
  expect_true(any(x$outliers$flagged > 0))
  expect_true("Household size" %in% x$fields$field)
  expect_equal(as.integer(x$corrections$by_action[["Outlier correction"]]), 1L)
  f <- withr::local_tempfile(fileext = ".html")
  DECIDE:::write_dq_report(f, c(x, list(scope = "All areas", country_office = "Chad")))
  html <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(html, "Data quality report", fixed = TRUE)
  expect_match(html, "household IDs are used more than once", fixed = TRUE)
  expect_match(html, "Enumerators to review", fixed = TRUE)
})

test_that("the back-check insights find where discordances sit and the report uses them", {
  o <- data.frame(id = 1:6, enum = c("A", "A", "B", "B", "C", "C"), prov = c("X", "X", "X", "Y", "Y", "Y"),
                  age = c(30, 40, 50, 60, 70, 80), sex = c("m", "f", "m", "f", "m", "f"))
  v <- o; v$age[1:2] <- c(35, 41); v$sex[1] <- "f"; v <- v[-6, ]
  r <- DECIDE:::compare_verification(o, v, "id", c("age", "sex"))
  ins <- DECIDE:::verification_insights(r, o, c(Enumerator = "enum", "Admin 1" = "prov"), matched = intersect(o$id, v$id))
  expect_equal(ins$by_group$Enumerator$group[1], "A")
  expect_equal(ins$by_group$Enumerator$agreement[1], 0.25)
  expect_equal(ins$by_group$Enumerator$households[ins$by_group$Enumerator$group == "C"], 1)
  expect_equal(ins$direction$higher[ins$direction$field == "age"], 2)
  f <- withr::local_tempfile(fileext = ".html")
  DECIDE:::write_verification_report(f, list(comparison = r, insights = ins, sample = list(method = "Simple random", n = 6, population = 6)))
  html <- paste(readLines(f, warn = FALSE), collapse = "\n")
  expect_match(html, "Where the discordances concentrate", fixed = TRUE)
  expect_match(html, "Households to re-check first", fixed = TRUE)
})
