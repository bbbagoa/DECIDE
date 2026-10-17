tm <- function(f) utils::getFromNamespace(f, "DECIDE")

test_that("statistical bounds and the allowed range combine into reasons", {
  v <- c(1:9, 60, NA)
  b <- tm("outlier_bounds")(v, "IQR", 1.5)
  expect_equal(b, c(-3.5, 14.5))   # Q1 3.25, Q3 7.75
  expect_equal(tm("outlier_bounds")(v, "none"), c(-Inf, Inf))
  expect_equal(tm("outlier_bounds")(rep(3, 5), "MAD", 3.5), c(-Inf, Inf))   # no spread: nothing flagged
  r <- tm("outlier_reason")(v, b, c(2, 30))
  expect_equal(r[1], "Below allowed minimum")      # 1 is statistically fine, but impossible
  expect_equal(r[10], "Above allowed maximum")
  expect_equal(r[11], "")                          # missing is not an outlier
  expect_equal(sum(nzchar(r)), 2)
  expect_equal(tm("outlier_limits")(b, c(2, 30)), c(2, 14.5))   # the tighter of each
  expect_equal(tm("outlier_limits")(b, c(NA, NA)), b)
})

test_that("repeated 99-style values are reported as codes, one-offs are not", {
  sc <- tm("sentinel_codes")(c(rep(99, 5), 98, 98, 45, -1, -1, -1))
  expect_equal(sc$value, c(99, -1))
  expect_equal(nrow(tm("sentinel_codes")(c(99, 45))), 0)
})

test_that("the numeric audit covers every column and applies each range", {
  df <- data.frame(a = c(1:9, 60), b = as.character(c(1:9, 10)), c = NA_real_)
  out <- tm("numeric_audit")(df, c("a", "b", "c"), "IQR", 1.5, list(b = c(1, 5)))
  expect_setequal(out$variable, c("a", "b", "c"))
  expect_equal(out$flagged[out$variable == "b"], 5)   # text numbers are read, 6..10 out of range
  expect_equal(out$flagged[out$variable == "a"], 1)
  expect_equal(out$answered[out$variable == "c"], 0)
})

test_that("verified values are read back from the audit trail", {
  log <- data.frame(action = c("Outlier verified (kept)", "Outlier verified (kept)", "Edit record"),
                    column = c("hh_size", "age", "hh_size"), uid = c("A", "B", "C"))
  expect_equal(tm("verified_uids")(log, "hh_size"), "A")
})

test_that("number-like columns are found, NA does not count against them", {
  df <- data.frame(n = 1:4, t = c("1", NA, NA, "3"), x = c("a", "b", "1", "2"),
                   f = factor(c("10", "20", "30", "40")), d = as.Date("2025-01-01") + 0:3,
                   stringsAsFactors = FALSE)
  expect_equal(tm("quantitative_cols")(df), c("n", "t", "f"))
})

test_that("duplicate groups report the columns that differ", {
  d <- data.frame(id = c(1, 1, 2, 2, 2), name = c("A", "A", "B", "B", "C"), age = c(30, 31, 40, 40, 40))
  diffs <- tm("duplicate_group_diffs")(d, c(1, 1, 2, 2, 2))
  expect_equal(diffs[["1"]], "age")
  expect_equal(diffs[["2"]], "name")
  expect_equal(tm("duplicate_group_diffs")(d[3:4, ], c(5, 5))[["5"]], character(0))
})

test_that("enumerators are flagged with the reason in words", {
  m <- data.frame(enumerator_id = paste0("E", 1:6), interviews = 10,
                  avg_duration = c(30, 32, 28, 31, 29, 5), missingness_rate = c(.02, .03, .02, .03, .02, .02))
  per_day <- data.frame(enumerator_id = paste0("E", c(1:6, 1)), day = "2025-01-01", Freq = c(5, 6, 5, 6, 5, 6, 40))
  f <- tm("enumerator_flags")(m, per_day)
  expect_equal(f$flag, c("Review", rep("OK", 4), "Review"))
  expect_match(f$reasons[6], "Short interviews")
  expect_match(f$reasons[1], "Busy day: 40 interviews")
  expect_false(is.na(attr(f, "thresholds")$dur_lo))
})
