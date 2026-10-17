# Unit tests for the targeting-analytic primitives in R/utils_targeting.R.
# These are pure functions (no Shiny), so they run fast and deterministically.
#
# Like test-helpers.R, the helpers are not exported (@noRd), so we reach them
# via the package-internal namespace DECIDE::: which is available
# once devtools::test() loads the package.

test_that("weighted_quantile matches stats::quantile type 1 when unweighted", {
  x <- 1:10
  for (p in c(0.1, 0.25, 0.5, 0.75, 0.9)) {
    expect_equal(DECIDE:::weighted_quantile(x, rep(1, 10), p)[1],
                 unname(stats::quantile(x, p, type = 1)), tolerance = 1e-12)
  }
})

test_that("weighted_quantile honours weights", {
  # heavy weight on the last value pulls the median to it
  expect_equal(DECIDE:::weighted_quantile(1:10, c(rep(1, 9), 9), 0.5)[1], 9)
  # all-NA -> NA
  expect_true(is.na(DECIDE:::weighted_quantile(c(NA_real_, NA_real_), c(1, 1), 0.5)[1]))
  # empty -> NA
  expect_true(all(is.na(DECIDE:::weighted_quantile(numeric(0), numeric(0), c(0.25, 0.5)))))
})

test_that("weighted_lorenz gini is correct on known distributions", {
  # Identical scores -> Gini 0 (perfect equality)
  expect_equal(DECIDE:::weighted_lorenz(c(5, 5, 5, 5))$gini, 0)
  # 9 zeros + one large value -> highly unequal
  expect_gt(DECIDE:::weighted_lorenz(c(rep(0, 9), 100))$gini, 0.8)
  # Lorenz score-share is monotonic non-decreasing
  lr <- DECIDE:::weighted_lorenz(1:10, c(1, 1, 1, 1, 10))
  expect_true(all(diff(lr$score_share) >= 0))
})

test_that("eligibility_flag normalises common labels", {
  pos <- c("Yes", "1", "true", "OUI", "eligible", "selected")
  neg <- c("No", "0", "FALSE", "non", "ineligible", "rejected")
  expect_equal(DECIDE:::eligibility_flag(pos), rep(TRUE, length(pos)))
  expect_equal(DECIDE:::eligibility_flag(neg), rep(FALSE, length(neg)))
  expect_equal(is.na(DECIDE:::eligibility_flag(c("maybe", "xyz"))), c(TRUE, TRUE))
})

test_that("targeting_metrics is correct for a perfect selection", {
  elig <- c(T, T, T, T, F, F, F, F)
  m <- DECIDE:::targeting_metrics(elig, elig)  # selected == eligible
  expect_equal(m$coverage_rate, 1)
  expect_equal(m$precision, 1)
  expect_equal(m$recall, 1)
  expect_equal(m$inclusion_error, 0)
  expect_equal(m$exclusion_error, 0)
})

test_that("targeting_metrics computes errors and precision/recall", {
  elig <- c(T, T, T, T, F, F, F, F)
  sel  <- c(T, T, F, F, T, F, F, F)  # rows 1,2 eligible-selected; row5 ineligible-selected
  m <- DECIDE:::targeting_metrics(sel, elig)
  expect_equal(m$coverage_rate, 2 / 4)    # 2 of 4 eligible selected
  expect_equal(m$precision, 2 / 3)        # 2 of 3 selected are eligible
  expect_equal(m$inclusion_error, 1 / 3)  # 1 of 3 selected is ineligible
  expect_equal(m$exclusion_error, 2 / 4)  # 2 of 4 eligible missed
})

test_that("targeting_metrics is weighted", {
  elig <- c(T, T, T, T, F, F, F, F)
  sel  <- c(T, T, F, F, T, F, F, F)
  w    <- c(1, 1, 1, 1, 100, 1, 1, 1)  # ineligible-selected row is heavy
  m <- DECIDE:::targeting_metrics(sel, elig, w)
  # selected weight = 102; ineligible selected weight = 100
  expect_equal(m$inclusion_error, 100 / 102)
})

test_that("targeting_metrics returns NULL when eligibility is unknown", {
  expect_null(DECIDE:::targeting_metrics(c(T, F), c(NA, NA)))
  expect_null(DECIDE:::targeting_metrics(NULL, c(T, F)))
})

test_that("weighted_crosstab aggregates and totals", {
  df <- data.frame(g = c("M", "M", "F", "F", "M"),
                   e = c("Y", "N", "Y", "N", "Y"), stringsAsFactors = FALSE)
  ct <- DECIDE:::weighted_crosstab(df, "g", "e")
  expect_equal(ct$grand_total, 5)
  expect_equal(nrow(ct$counts), 4)
  m_row <- ct$counts[ct$counts$row == "M", ]   # row percentages within a group sum to 1
  expect_equal(sum(m_row$row_pct), 1)
})

test_that("weighted_cor handles perfect, anti, constant, and NA cases", {
  expect_equal(DECIDE:::weighted_cor(1:10, 1:10 + 0.5), 1)
  expect_equal(DECIDE:::weighted_cor(1:10, -(1:10)), -1)
  expect_true(is.na(DECIDE:::weighted_cor(rep(5, 5), 1:5)))  # constant x -> undefined
})

test_that("weighted_cor_matrix builds a symmetric matrix with unit diagonal", {
  mat <- DECIDE:::weighted_cor_matrix(
    data.frame(a = 1:10, b = 1:10, c = -(1:10)),
    c("a", "b", "c")
  )
  expect_equal(unname(diag(mat)), c(1, 1, 1))
  expect_equal(mat["a", "b"], 1)
  expect_equal(mat["a", "c"], -1)
  expect_equal(mat["a", "b"], mat["b", "a"])  # symmetric
})

test_that("any two-answer column can say who received assistance", {
  g <- DECIDE:::guess_positive_answer
  expect_equal(g(c("No", "Yes")), "Yes")
  expect_equal(g(c("0", "1")), "1")
  expect_equal(g(c("Beneficiary", "Non-beneficiary")), "Beneficiary")
  expect_equal(g(c("Non beneficiaire", "Beneficiaire")), "Beneficiaire")
  expect_equal(g(c("Assisted", "Not assisted")), "Assisted")
  expect_equal(g(c("Group A", "Group B")), "Group A")          # no clue: the first, the officer can change it
  expect_equal(DECIDE:::two_levels(c(" A", "B", NA, "", "A")), c("A", "B"))
})
