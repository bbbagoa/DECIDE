test_that("PCA and LDA give an additive vulnerability index that points the right way", {
  df <- utils::read.csv(system.file("extdata", "assessment_demo.csv", package = "DECIDE"), stringsAsFactors = FALSE)
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance", "Targ_HHHousingTent", "Targ_HHOwnCattle2more")
  y <- DECIDE:::as_binary_outcome(df$FSI_CARI2_2class, "Food insecure")
  for (m in c("pca", "lda")) {
    f <- DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure", method = m, scheme = "odds_ratio")
    expect_equal(f$scheme, "coefficient")            # odds-ratio points make no sense for an index
    expect_equal(max(abs(f$weights$weight)), 10)     # scaled so the largest weight is 10
    expect_equal(f$index$type, m)
    sc <- DECIDE:::apply_scorecard(df, DECIDE:::build_scorecard(f$weights))$score
    auc <- DECIDE:::roc_curve(sc, y)$auc
    expect_gt(auc, 0.5)                              # a higher index means more vulnerable
  }
  p <- DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure", method = "pca")$index
  expect_true(p$share > 0 && p$share <= 1)
  expect_true(is.na(p$kmo) || (p$kmo > 0 && p$kmo <= 1))
  expect_true(p$bartlett_p >= 0 && p$bartlett_p <= 1)
  expect_true(all(c("pca", "lda") %in% DECIDE:::scorecard_model_choices()))
})

test_that("a PCA index can average several axes, weighted by the variation they explain", {
  df <- utils::read.csv(system.file("extdata", "assessment_demo.csv", package = "DECIDE"), stringsAsFactors = FALSE)
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance", "Targ_HHHousingTent", "Targ_HHOwnCattle2more")
  f1 <- DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure", method = "pca", pca_axes = 1)
  f3 <- DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure", method = "pca", pca_axes = 3)
  ix <- f3$index
  expect_equal(ix$axes, 3)
  expect_equal(sum(ix$axis_weights), 1)
  expect_equal(dim(ix$axis_loadings), c(5, 3))
  expect_true(ix$share > f1$index$share)                  # three axes explain more than one
  expect_false(isTRUE(all.equal(f1$weights$weight, f3$weights$weight)))
  expect_equal(DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure",
                                                   method = "pca", pca_axes = 99)$index$axes, 5)   # capped
})

test_that("a PCA index can keep the fewest axes reaching a minimum variation explained", {
  df <- utils::read.csv(system.file("extdata", "assessment_demo.csv", package = "DECIDE"), stringsAsFactors = FALSE)
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance", "Targ_HHHousingTent", "Targ_HHOwnCattle2more")
  sh <- DECIDE:::pca_variance(df, crit)
  expect_equal(sum(sh), 1)
  expect_true(all(diff(sh) <= 1e-12))                              # largest first
  for (target in c(0.3, 0.6, 0.9)) {
    ix <- DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure", method = "pca",
                                               pca_min_var = target)$index
    k <- which(cumsum(sh) >= target)[1]
    expect_equal(ix$axes, k)                                        # the fewest axes reaching it
    expect_gte(ix$share, target)
    expect_equal(ix$min_var, target)
  }
  # a target of 100% keeps every axis
  expect_equal(DECIDE:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit, "Food insecure", method = "pca",
                                                    pca_min_var = 1)$index$axes, length(crit))
  expect_match(as.character(DECIDE:::index_note(DECIDE:::fit_scorecard_advanced(
    df, "FSI_CARI2_2class", crit, "Food insecure", method = "pca", pca_min_var = 0.6)$index)), "Total variation explained")
})
