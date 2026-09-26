test_that("design report charts keep the 15 most relevant variables and say so", {
  set.seed(1)
  n <- 400
  df <- as.data.frame(stats::setNames(lapply(1:25, function(i) rbinom(n, 1, 0.2 + i / 100)), paste0("v", 1:25)))
  y <- rbinom(n, 1, 0.4)
  p <- TargetWise:::design_report_extra_plots(df = df, criteria = names(df), vulnerable = y == 1)
  expect_equal(unname(attr(p$prevalence, "tw_of")), c(15, 25))
  expect_equal(unname(attr(p$correlation, "tw_of")), c(15, 25))
  w <- data.frame(criterion = paste0("v", 1:20), weight = 1:20, direction = "inclusion")
  pw <- TargetWise:::design_report_plots(weights = w)
  expect_equal(unname(attr(pw$weights, "tw_of")), c(15, 20))
  few <- TargetWise:::design_report_plots(weights = w[1:5, ])
  expect_null(attr(few$weights, "tw_of"))
})

test_that("the scorecard workbook carries the full report tables", {
  sc <- list(items = list(list(criterion = "a", direction = "inclusion", weight = 2)), threshold = 1)
  wb <- TargetWise:::scorecard_workbook(sc, report_tables = list(
    "Points by criterion (all criteria)" = data.frame(Criterion = paste0("v", 1:30), Points = 1:30),
    "Empty" = data.frame()))
  expect_true("Report_tables" %in% names(wb))
  f <- withr::local_tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(wb, f)
  x <- openxlsx::read.xlsx(f, sheet = "Report_tables", colNames = FALSE)
  expect_true(any(grepl("Points by criterion", x[[1]])))
  expect_true("v30" %in% x[[1]])
})
