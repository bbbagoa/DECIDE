test_that("stratum weights correct the exclusion error of a beneficiary/non-beneficiary PDM", {
  sw <- DECIDE:::pdm_stratum_weights
  tmet <- DECIDE:::targeting_metrics
  # 200 beneficiaries surveyed (150 eligible), 200 non-beneficiaries (60 eligible);
  # the area has 5,000 beneficiary and 20,000 non-beneficiary households.
  benef <- rep(c(TRUE, FALSE), each = 200)
  elig <- c(rep(TRUE, 150), rep(FALSE, 50), rep(TRUE, 60), rep(FALSE, 140))
  raw <- tmet(benef, elig)
  expect_equal(round(raw$exclusion_error, 3), round(60 / 210, 3))
  w <- sw(benef, NULL, data.frame(unit = "All", beneficiaries = 5000, non_beneficiaries = 20000))
  expect_equal(unique(w$w[benef]), 25); expect_equal(unique(w$w[!benef]), 100)
  m <- tmet(benef, elig, w$w)
  expect_equal(round(m$exclusion_error, 3), round(6000 / 9750, 3))
  expect_equal(round(m$inclusion_error, 3), 0.25)          # inclusion needs no weighting
})

test_that("per-area weights use each area's own sizes; missing sizes give NA", {
  sw <- DECIDE:::pdm_stratum_weights
  benef <- c(TRUE, TRUE, FALSE, TRUE, FALSE, FALSE)
  area <- c("A", "A", "A", "B", "B", "B")
  w <- sw(benef, area, data.frame(unit = c("A", "B"), beneficiaries = c(100, 50), non_beneficiaries = c(300, NA)))
  expect_equal(w$w, c(50, 50, 300, 50, NA, NA))
  expect_equal(w$strata$surveyed_non_beneficiaries, c(1, 2))
})

test_that("scorecard eligibility on PDM data refuses missing criteria", {
  f <- DECIDE:::pdm_scorecard_eligibility
  sc <- list(threshold = 1, items = list(
    list(criterion = "a", direction = "inclusion", weight = 2, column = NA),
    list(criterion = "b", direction = "inclusion", weight = 1, column = "b_reg")))
  df <- data.frame(a = c(1, 0, 1), b_reg = c(0, 1, 1))
  expect_equal(f(df, sc)$eligible, c(TRUE, FALSE, TRUE))
  expect_equal(f(data.frame(a = 1), sc)$missing, "b")
})
