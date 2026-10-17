tm <- function(f) utils::getFromNamespace(f, "DECIDE")

# Same planted-effect design as test-scorecard.R, plus a redundant criterion
# that stepwise selection should be able to drop.
demo_models <- function(n = 1500, seed = 7) {
  set.seed(seed)
  tent <- rbinom(n, 1, 0.30); nolight <- rbinom(n, 1, 0.35)
  cattle <- rbinom(n, 1, 0.20)
  lp <- -0.4 + 1.6 * tent + 1.2 * nolight - 1.5 * cattle
  y <- rbinom(n, 1, 1 / (1 + exp(-lp)))
  # Uninformative BY CONSTRUCTION: exactly half of each outcome group, in an
  # order unrelated to anything else. A plain rbinom() column is random, and
  # with n = 1500 one draw in a thousand is associated with the outcome at
  # p < 0.001 -- which is exactly what an earlier version of this test drew,
  # and stepwise quite rightly kept it.
  noise <- integer(n)
  for (g in 0:1) {
    idx <- which(y == g)
    noise[idx] <- rep_len(c(0L, 1L), length(idx))[order(runif(length(idx)))]
  }
  yn <- function(v) ifelse(v == 1, "Yes", "No")
  data.frame(
    Targ_Tent = yn(tent), Targ_NoLight = yn(nolight),
    Targ_Cattle = yn(cattle), Targ_Noise = yn(noise),
    FSI = ifelse(y == 1, "Food insecure", "Food secure"),
    w = runif(n, 0.5, 2),
    stringsAsFactors = FALSE
  )
}

test_that("the hold-out split is stratified, disjoint and reproducible", {
  y <- c(rep(1, 700), rep(0, 300), NA, NA)
  s1 <- tm("split_train_test")(y, holdout = 0.2, seed = 42)
  s2 <- tm("split_train_test")(y, holdout = 0.2, seed = 42)
  expect_identical(s1, s2)
  expect_length(intersect(s1$train, s1$test), 0)
  expect_equal(length(s1$test), 200)
  # prevalence preserved in both samples
  expect_equal(mean(y[s1$test]), 0.7, tolerance = 0.01)
  expect_equal(mean(y[s1$train]), 0.7, tolerance = 0.01)
  # rows with a missing outcome go to neither sample
  expect_false(any(c(1001, 1002) %in% c(s1$train, s1$test)))
  # no hold-out means every usable row trains
  s0 <- tm("split_train_test")(y, holdout = 0)
  expect_equal(length(s0$train), 1000); expect_length(s0$test, 0)
  # and the caller's RNG stream is left as it was
  set.seed(1); a <- runif(1); set.seed(1); invisible(tm("split_train_test")(y, 0.2, 99)); b <- runif(1)
  expect_equal(a, b)
})

test_that("each weighting scheme turns coefficients into positive weights", {
  coef <- c(a = 1.6, b = -1.5, c = 0.2)
  w <- tm("scorecard_weights")
  expect_equal(w(coef, "odds_ratio"), round(exp(coef), 5))
  expect_equal(w(coef, "coefficient"), c(a = 1.6, b = 1.5, c = 0.2))
  expect_equal(unname(w(coef, "points")), c(10, 9, 1))      # largest = 10, min 1
  expect_equal(w(coef, "equal"), c(1, 1, 1))
  expect_error(w(coef, "nonsense"), "Unknown weighting scheme")
})

test_that("stepwise drops a criterion that adds nothing and keeps the real drivers", {
  df <- demo_models()
  crit <- c("Targ_Tent", "Targ_NoLight", "Targ_Cattle", "Targ_Noise")
  full <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", method = "logit")
  step <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", method = "logit", stepwise = "aic")
  expect_setequal(full$weights$criterion, crit)
  expect_true("Targ_Noise" %in% step$dropped)
  expect_setequal(step$weights$criterion, c("Targ_Tent", "Targ_NoLight", "Targ_Cattle"))
  dir <- stats::setNames(step$weights$direction, step$weights$criterion)
  expect_equal(dir[["Targ_Cattle"]], "exclusion")
  expect_equal(dir[["Targ_Tent"]], "inclusion")
})

test_that("fitting on the training rows only uses those rows", {
  df <- demo_models()
  y <- tm("as_binary_outcome")(df$FSI, "Food insecure")
  sp <- tm("split_train_test")(y, 0.25, seed = 3)
  f <- tm("fit_scorecard_advanced")(df, "FSI", c("Targ_Tent", "Targ_NoLight"),
                                     "Food insecure", rows = sp$train)
  expect_equal(f$n, length(sp$train))
})

test_that("survey weights change the fit without flattering significance", {
  df <- demo_models()
  crit <- c("Targ_Tent", "Targ_NoLight", "Targ_Cattle")
  unw <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure")
  wtd <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", weights = df$w)
  expect_true(wtd$converged)             # fractional weights are not "non-convergence"
  expect_false(isTRUE(all.equal(unw$weights$coefficient, wtd$weights$coefficient)))
  # weights are normalised, so a constant x10 weight gives the unweighted fit
  x10 <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", weights = rep(10, nrow(df)))
  expect_equal(x10$weights$coefficient, unw$weights$coefficient, tolerance = 1e-8)
  expect_equal(x10$weights$p_value, unw$weights$p_value, tolerance = 1e-8)
})

test_that("benchmarks score on the hold-out and report AUCs the scorecard can be compared to", {
  df <- demo_models()
  y <- tm("as_binary_outcome")(df$FSI, "Food insecure")
  sp <- tm("split_train_test")(y, 0.25, seed = 5)
  crit <- c("Targ_Tent", "Targ_NoLight", "Targ_Cattle", "Targ_Noise")
  b <- tm("benchmark_models")(df, "FSI", crit, "Food insecure", sp)
  expect_true("Logistic (probabilities)" %in% b$table$model)
  expect_true(all(b$table$auc_test > 0.6, na.rm = TRUE))
  expect_true(all(is.finite(b$table$auc_train)))
  if (requireNamespace("ranger", quietly = TRUE)) {
    expect_true("Random forest (benchmark)" %in% b$table$model)
    # the planted drivers matter more to the forest than the noise column
    expect_lt(b$importance[["Targ_Noise"]], b$importance[["Targ_Tent"]])
  }
  expect_true(all(vapply(b$roc, nrow, integer(1)) > 0))
})

test_that("implementation errors use the implementation table, not the design one", {
  v <- tm("error_verdict")
  d <- v(0.15, 0.03, 0.05, 0.20, stage = "design")
  i <- v(0.15, 0.03, 0.05, 0.20, stage = "implementation")
  expect_false(identical(d$action, i$action))
  expect_match(i$interpretation, "manipulation of the final lists")
  expect_match(i$action, "re-train the CPs")
  # high inclusion, low exclusion: the advisory calls for a full investigation
  expect_match(v(0.30, 0.02, 0.05, 0.20, stage = "implementation")$action, "undue influence")
  expect_equal(v(0.02, 0.02, 0.05, 0.20, stage = "implementation")$action, "No adjustments required.")
  expect_match(v(0.40, 0.40, 0.05, 0.20, stage = "implementation")$action, "IDM processes")
  # the design default is unchanged
  expect_equal(v(0.04, 0.03)$level, "good")
  expect_error(v(0.1, 0.1, lower = 0.3, upper = 0.2), "lower tolerance")
})

test_that("p-values band and the model tables export", {
  pl <- DECIDE:::p_level
  expect_equal(pl(c(0.0001, 0.005, 0.03, 0.07, 0.5, NA)), c("p001", "p01", "p05", "p10", "ns", "na"))
  co <- data.frame(criterion = c("a", "b"), coefficient = c(0.5, -0.4), std_error = c(0.1, 0.2),
                   odds_ratio = exp(c(0.5, -0.4)), or_low = c(1.3, 0.45), or_high = c(2, 0.99),
                   p_value = c(0.0001, 0.04), direction = c("inclusion", "exclusion"), weight = c(2, 1))
  wb <- DECIDE:::model_tables_workbook(coefficients = co)
  expect_equal(openxlsx::sheets(wb), "Model")
  html <- as.character(DECIDE:::coefficients_html(co))
  expect_match(html, "wfp-p-p001")
  expect_match(html, "wfp-p-p05")
})

test_that("weight of evidence and boosted stumps give additive cards in the right direction", {
  set.seed(7)
  n <- 800
  a <- rbinom(n, 1, 0.4); b <- rbinom(n, 1, 0.4)
  y <- rbinom(n, 1, plogis(-0.5 + 1.2 * a - 1.0 * b))
  df <- data.frame(y = ifelse(y == 1, "Food insecure", "Food secure"), a = a, b = b)
  fit <- DECIDE:::fit_scorecard_advanced
  w <- fit(df, "y", c("a", "b"), "Food insecure", method = "woe")
  expect_equal(w$weights$direction[match(c("a", "b"), w$weights$criterion)], c("inclusion", "exclusion"))
  expect_true(all(is.na(w$weights$p_value)))
  expect_null(w$model)
  skip_if_not_installed("xgboost")
  s <- fit(df, "y", c("a", "b"), "Food insecure", method = "stumps")
  expect_equal(s$weights$direction[match(c("a", "b"), s$weights$criterion)], c("inclusion", "exclusion"))
  # The stump effects approximate the true log-odds effects.
  expect_lt(abs(s$weights$coefficient[s$weights$criterion == "a"] - 1.2), 0.5)
})

test_that("variable-selection profile, correlation and per-model effects line up", {
  set.seed(11)
  n <- 600
  a <- rbinom(n, 1, 0.4); b <- ifelse(runif(n) < 0.9, a, 1 - a); cc <- rbinom(n, 1, 0.3)
  y <- rbinom(n, 1, plogis(-0.4 + 1.1 * a - 0.8 * cc))
  df <- data.frame(y = ifelse(y == 1, "Food insecure", "Food secure"), a = a, b = b, cc = cc)
  prof <- DECIDE:::criteria_profile(df, c("a", "cc"), y)
  expect_equal(prof$criterion, c("a", "cc"))
  expect_gt(prof$gap[1], 0); expect_lt(prof$gap[2], 0)
  cm <- DECIDE:::criteria_cor(df, c("a", "b", "cc"))
  expect_gt(cm["a", "b"], 0.7)
  expect_match(as.character(DECIDE:::correlation_html(cm, 0.7)), "is-high")
  eff <- DECIDE:::model_effects(df, "y", c("a", "cc"), "Food insecure")
  # every model but the indices (PCA, LDA), whose weights are not log-odds effects
  expect_equal(length(unique(eff$model)), sum(!DECIDE:::scorecard_model_choices() %in% c("pca", "lda")))
  expect_true(all(eff$effect[eff$criterion == "a"] > 0, na.rm = TRUE))
  expect_match(as.character(DECIDE:::effects_html(eff)), "wfp-eff-neg")
})

test_that("machine-learning models give additive points in the right direction", {
  set.seed(21)
  n <- 700
  a <- rbinom(n, 1, 0.4); b <- rbinom(n, 1, 0.4)
  y <- rbinom(n, 1, plogis(-0.3 + 1.4 * a - 1.2 * b))
  df <- data.frame(y = ifelse(y == 1, "Food insecure", "Food secure"), a = a, b = b)
  fit <- DECIDE:::fit_scorecard_advanced
  for (m in c("rf", "xgb", "nb", "nnet")) {
    pkg <- c(rf = "ranger", xgb = "xgboost", nb = "e1071", nnet = "nnet")[[m]]
    if (!requireNamespace(pkg, quietly = TRUE)) next
    f <- fit(df, "y", c("a", "b"), "Food insecure", method = m)
    dir <- f$weights$direction[match(c("a", "b"), f$weights$criterion)]
    expect_equal(dir, c("inclusion", "exclusion"), info = m)
    expect_true(all(is.na(f$weights$p_value)), info = m)
  }
  # SVM optimises a boundary, not probabilities: only check it produces points.
  skip_if_not_installed("e1071")
  s <- fit(df, "y", c("a", "b"), "Food insecure", method = "svm")
  expect_true(all(is.finite(s$weights$weight)))
})

test_that("stepwise works with every model, and BIC keeps no more than AIC", {
  df <- demo_models()
  crit <- c("Targ_Tent", "Targ_NoLight", "Targ_Cattle", "Targ_Noise")
  woe <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", method = "woe", stepwise = "aic")
  expect_true("Targ_Noise" %in% woe$dropped)
  expect_false("Targ_Noise" %in% woe$weights$criterion)
  aic <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", stepwise = "aic")
  bic <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", stepwise = "bic")
  expect_lte(nrow(bic$weights), nrow(aic$weights))
  expect_equal(bic$stepwise, "bic")
  # a session saved when stepwise was a model of its own
  old <- tm("fit_scorecard_advanced")(df, "FSI", crit, "Food insecure", method = "stepwise")
  expect_equal(old$method, "logit"); expect_equal(old$stepwise, "aic")
})

test_that("criteria asked to different subgroups still fit: a missing answer counts as no", {
  set.seed(3)
  n <- 300
  y <- rbinom(n, 1, 0.5)
  df <- data.frame(out = ifelse(y == 1, "Vulnerable", "Not"),
                   a = ifelse(runif(n) < 0.3 + 0.4 * y, "Yes", "No"),
                   b = ifelse(runif(n) < 0.5, "Yes", "No"), c = ifelse(runif(n) < 0.5, "Yes", "No"))
  df$b[1:150] <- NA                 # asked to half the households
  df$c[151:300] <- NA               # asked to the other half: no household answered both
  f <- DECIDE:::fit_scorecard_advanced(df, "out", c("a", "b", "c"), outcome_positive = "Vulnerable")
  expect_equal(f$n, n)
  expect_equal(unname(f$filled[c("b", "c")]), c(150L, 150L))
  g <- DECIDE:::fit_scorecard_model(df, "out", c("a", "b", "c"), outcome_positive = "Vulnerable")
  expect_equal(g$n, n)
  expect_error(DECIDE:::fit_scorecard_advanced(df, "out", "a", outcome_positive = "Vulnerable", weights = rep(NA, n)),
               "survey weight column is empty")
})

test_that("stepwise selection runs backward, forward or both", {
  set.seed(11); n <- 500; y <- rbinom(n, 1, 0.5)
  df <- data.frame(out = ifelse(y == 1, "V", "N"),
                   s1 = ifelse(runif(n) < 0.2 + 0.5 * y, "Yes", "No"), s2 = ifelse(runif(n) < 0.3 + 0.4 * y, "Yes", "No"),
                   n1 = ifelse(runif(n) < 0.5, "Yes", "No"), n2 = ifelse(runif(n) < 0.5, "Yes", "No"))
  for (d in c("backward", "forward", "both")) {
    f <- DECIDE:::fit_scorecard_advanced(df, "out", c("s1", "s2", "n1", "n2"), outcome_positive = "V",
                                             stepwise = "bic", stepwise_dir = d)
    expect_true(all(c("s1", "s2") %in% f$weights$criterion), info = d)
    expect_equal(f$stepwise_dir, d)
  }
  expect_match(DECIDE:::stepwise_note("aic", "forward"), "starting from no criterion")
})
