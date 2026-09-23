# Spot-check back-check comparison engine

make_pair <- function() {
  original <- data.frame(
    id = c("a", "b", "c", "d"),
    hh_size = c(5, 6, 7, 8),
    name = c("Bora", "Neema", "Sifa", "Vera"),
    stringsAsFactors = FALSE
  )
  verification <- data.frame(
    id = c("a", "b", "c", "e"),
    hh_size = c(5, 99, 7, 4),          # b disagrees
    name = c("bora ", "Neema", "SIFA", "X"), # a and c agree after normalising
    stringsAsFactors = FALSE
  )
  list(original = original, verification = verification)
}

test_that("compare_verification matches on the key and ignores unmatched records", {
  p <- make_pair()
  res <- compare_verification(p$original, p$verification, "id")

  expect_equal(res$matched_n, 3)          # a, b, c
  expect_equal(res$only_original_n, 1)    # d
  expect_equal(res$only_verification_n, 1) # e
})

test_that("compare_verification normalises case and whitespace in text", {
  p <- make_pair()
  res <- compare_verification(p$original, p$verification, "id")

  name_row <- res$field_summary[res$field_summary$variable == "name", ]
  expect_equal(name_row$agree, 3)
  expect_equal(name_row$disagree, 0)
})

test_that("compare_verification reports numeric discordances", {
  p <- make_pair()
  res <- compare_verification(p$original, p$verification, "id")

  size_row <- res$field_summary[res$field_summary$variable == "hh_size", ]
  expect_equal(size_row$disagree, 1)
  expect_equal(size_row$agree, 2)

  expect_equal(nrow(res$discordances), 1)
  expect_equal(res$discordances$key, "b")
  expect_equal(res$discordances$variable, "hh_size")
  expect_equal(res$records_with_discordance, 1)
})

test_that("numeric_tolerance suppresses small differences", {
  o <- data.frame(id = c("a", "b"), score = c(10.0, 20.0), stringsAsFactors = FALSE)
  v <- data.frame(id = c("a", "b"), score = c(10.4, 25.0), stringsAsFactors = FALSE)

  strict <- compare_verification(o, v, "id")
  expect_equal(strict$field_summary$disagree, 2)

  loose <- compare_verification(o, v, "id", numeric_tolerance = 0.5)
  expect_equal(loose$field_summary$disagree, 1)
})

test_that("two missing values agree but one missing value does not", {
  o <- data.frame(id = c("a", "b"), v = c(NA, "x"), stringsAsFactors = FALSE)
  v <- data.frame(id = c("a", "b"), v = c(NA, NA), stringsAsFactors = FALSE)

  res <- compare_verification(o, v, "id")
  expect_equal(res$field_summary$agree, 1)
  expect_equal(res$field_summary$disagree, 1)
})

test_that("empty strings and NULL spellings count as missing, not as values", {
  o <- data.frame(id = "a", v = "", stringsAsFactors = FALSE)
  v <- data.frame(id = "a", v = "NULL", stringsAsFactors = FALSE)
  res <- compare_verification(o, v, "id")
  expect_equal(res$field_summary$agree, 1)
})

test_that("overall_agreement aggregates across every compared field", {
  p <- make_pair()
  res <- compare_verification(p$original, p$verification, "id")
  # 3 records x 2 fields = 6 comparisons, 1 disagreement
  expect_equal(res$overall_agreement, 5 / 6)
})

test_that("compare_verification restricts to the requested columns", {
  p <- make_pair()
  res <- compare_verification(p$original, p$verification, "id", cols = "name")
  expect_equal(res$cols, "name")
  expect_equal(nrow(res$field_summary), 1)
})

test_that("compare_verification returns NULL when the key is absent", {
  p <- make_pair()
  expect_null(compare_verification(p$original, p$verification, "not_a_column"))
  expect_null(compare_verification(NULL, p$verification, "id"))
})

test_that("duplicate keys keep only the first occurrence", {
  o <- data.frame(id = c("a", "a"), v = c("x", "y"), stringsAsFactors = FALSE)
  v <- data.frame(id = c("a"), v = "x", stringsAsFactors = FALSE)
  res <- compare_verification(o, v, "id")
  expect_equal(res$matched_n, 1)
  expect_equal(res$field_summary$agree, 1)
})

test_that("no shared records yields an empty but well-formed result", {
  o <- data.frame(id = "a", v = 1, stringsAsFactors = FALSE)
  v <- data.frame(id = "z", v = 1, stringsAsFactors = FALSE)
  res <- compare_verification(o, v, "id")
  expect_equal(res$matched_n, 0)
  expect_equal(nrow(res$discordances), 0)
  expect_true(is.na(res$overall_agreement))
})
