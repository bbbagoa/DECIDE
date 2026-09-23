# Regression tests for two bugs that produced wrong numbers rather than errors:
#   * date filtering injected all-NA rows for undated records
#   * coverage_by_unit ANDed an index vector with a logical mask

test_that("filter_by_date_range keeps only rows inside the range", {
  df <- data.frame(
    id = 1:5,
    d = as.Date(c("2026-01-01", "2026-01-05", "2026-01-10", "2026-01-15", "2026-01-20")),
    stringsAsFactors = FALSE
  )
  out <- filter_by_date_range(df, "d", c(as.Date("2026-01-05"), as.Date("2026-01-15")))
  expect_equal(out$id, 2:4)
})

test_that("filter_by_date_range drops undated rows instead of injecting NA rows", {
  df <- data.frame(
    id = 1:4,
    d = c("2026-01-02", NA, "", "2026-01-20"),
    stringsAsFactors = FALSE
  )
  out <- filter_by_date_range(df, "d", c(as.Date("2026-01-01"), as.Date("2026-01-31")))

  # The buggy version returned 4 rows, two of them entirely NA.
  expect_equal(nrow(out), 2)
  expect_equal(out$id, c(1L, 4L))
  expect_false(any(is.na(out$id)))
})

test_that("filter_by_date_range is a no-op for an unmapped or absent column", {
  df <- data.frame(id = 1:3, d = as.Date("2026-01-01") + 0:2)
  rng <- c(as.Date("2026-01-01"), as.Date("2026-01-02"))

  expect_identical(filter_by_date_range(df, NULL, rng), df)
  expect_identical(filter_by_date_range(df, "", rng), df)
  expect_identical(filter_by_date_range(df, "not_a_column", rng), df)
  expect_identical(filter_by_date_range(df, "d", NULL), df)
})

test_that("filter_by_date_range does not error on an unparseable date column", {
  df <- data.frame(id = 1:3, d = c("15/03/2026", "not a date", "x"), stringsAsFactors = FALSE)
  rng <- c(as.Date("2026-01-01"), as.Date("2026-12-31"))
  expect_silent(out <- filter_by_date_range(df, "d", rng))
  expect_s3_class(out, "data.frame")
})

test_that("coverage_by_unit counts only households that are both selected and eligible", {
  df <- data.frame(unit = c("A", "A", "A", "B"), stringsAsFactors = FALSE)
  w <- c(1, 2, 3, 4)
  eligible <- c(TRUE, TRUE, FALSE, TRUE)
  selected <- c(TRUE, FALSE, TRUE, TRUE)

  out <- coverage_by_unit(df, selected, eligible, "unit", w)
  a <- out[out$unit == "A", ]
  b <- out[out$unit == "B", ]

  # A: eligible = rows 1,2 (w 1+2 = 3); selected AND eligible = row 1 only (w 1).
  # The buggy version scored row 3 (selected, NOT eligible) and returned 3.
  expect_equal(a$eligible, 3)
  expect_equal(a$selected, 1)
  expect_equal(a$coverage, 1 / 3)

  expect_equal(b$eligible, 4)
  expect_equal(b$selected, 4)
  expect_equal(b$coverage, 1)
})

test_that("coverage_by_unit is unweighted when no weights are supplied", {
  df <- data.frame(unit = c("A", "A", "B", "B"), stringsAsFactors = FALSE)
  eligible <- c(TRUE, TRUE, TRUE, FALSE)
  selected <- c(TRUE, FALSE, FALSE, TRUE)

  out <- coverage_by_unit(df, selected, eligible, "unit")
  a <- out[out$unit == "A", ]
  b <- out[out$unit == "B", ]

  expect_equal(a$eligible, 2)
  expect_equal(a$selected, 1)
  expect_equal(b$eligible, 1)
  expect_equal(b$selected, 0)
  expect_equal(b$coverage, 0)
})

test_that("coverage_by_unit returns an empty frame for a missing unit column", {
  df <- data.frame(unit = c("A", "B"), stringsAsFactors = FALSE)
  out <- coverage_by_unit(df, c(TRUE, TRUE), c(TRUE, TRUE), "nope")
  expect_equal(nrow(out), 0)
})
