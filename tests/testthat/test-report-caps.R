test_that("design report charts keep every variable", {
  set.seed(1)
  n <- 400
  df <- as.data.frame(stats::setNames(lapply(1:25, function(i) rbinom(n, 1, 0.2 + i / 100)), paste0("v", 1:25)))
  y <- rbinom(n, 1, 0.4)
  p <- TargetWise:::design_report_extra_plots(df = df, criteria = names(df), vulnerable = y == 1)
  # radar with a spoke per criterion
  expect_equal(p$prevalence$x$bb_opts$data$type, "radar")
  expect_length(p$prevalence$x$bb_opts$data$json[[1]], 25)
  expect_null(attr(p$prevalence, "tw_of"))
  expect_null(p$correlation)   # the report lists the high pairs instead
  # points by criterion: vertical columns, every criterion
  w <- data.frame(criterion = paste0("v", 1:20), weight = 1:20, direction = rep(c("inclusion", "exclusion"), 10))
  pw <- TargetWise:::design_report_plots(weights = w)
  expect_null(attr(pw$weights, "tw_of"))
  expect_length(pw$weights$x$bb_opts$data$json[[1]], 20)
  expect_false(isTRUE(pw$weights$x$bb_opts$axis$rotated))
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

test_that("charts side by side in a report get the same height", {
  a <- billboarder::billboarder(height = 300); b <- billboarder::billboarder(height = 520)
  c <- billboarder::billboarder(height = 250); d <- billboarder::billboarder(height = 410)
  f <- withr::local_tempfile(fileext = ".html")
  TargetWise:::report_write_page(f, "# T\n\n@@FIG:a,b@@\n\n@@FIG:c@@\n\n@@PAIR1@@\n", list(a = a, b = b, c = c, d = d, e = a),
                                 blocks = list("@@PAIR1@@" = '<div class="pair"><p>@@FIG:d@@</p><p>@@FIG:e@@</p></div>'),
                                 title = "t", record = "r")
  page <- paste(readLines(f, warn = FALSE), collapse = " ")
  h <- regmatches(page, gregexpr("height:[0-9]+px", page))[[1]]
  expect_false("height:300px" %in% h)   # a was raised to b's 520
  expect_true("height:520px" %in% h)
  expect_true("height:250px" %in% h)    # c, alone, keeps its height
  expect_true("height:410px" %in% h)    # the monitoring pair d, e: both 410
})

test_that("the score distribution is a share of each group, on shared bins", {
  set.seed(2)
  s <- c(rnorm(300, 6, 2), rnorm(900, 3, 2)); v <- rep(c(TRUE, FALSE), c(300, 900))
  h <- TargetWise:::score_bins(s, v)
  expect_equal(sum(h$vuln), 100)
  expect_equal(sum(h$not), 100)
  expect_equal(sum(h$n_vuln) + sum(h$n_not), 1200)
  p <- TargetWise:::design_report_plots(score = s, vulnerable = v, threshold = 4)
  expect_length(p$scores$x$bb_opts$data$groups[[1]], 2)          # mirrored, one bar per bin
})
