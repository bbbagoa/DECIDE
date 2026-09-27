demo_df <- function() utils::read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"), stringsAsFactors = FALSE)
crit5t <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance", "Targ_HHHousingTent", "Targ_HHOwnCattle2more")

test_that("a decision tree gives an additive card and readable rules", {
  skip_if_not_installed("rpart")
  df <- demo_df()
  expect_true("tree" %in% TargetWise:::scorecard_model_choices())
  f <- TargetWise:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit5t, "Food insecure", method = "tree")
  expect_true(nrow(f$weights) > 0)
  rl <- f$tree_rules
  expect_true(nrow(rl) >= 2)
  expect_true(all(grepl("= (yes|no)", rl$rule) | rl$rule == "All households"))
  expect_equal(sum(rl$households), f$n)
  expect_true(all(diff(rl$share_vulnerable) <= 0))                   # most vulnerable first
  y <- TargetWise:::as_binary_outcome(df$FSI_CARI2_2class, "Food insecure")
  sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(f$weights))$score
  expect_gt(TargetWise:::roc_curve(sc, y)$auc, 0.6)
})

test_that("cross-validation tries the grid and keeps the best setting", {
  skip_if_not_installed("rpart")
  df <- demo_df()
  f <- TargetWise:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit5t, "Food insecure", method = "tree", tune = TRUE, folds = 4)
  tn <- f$tuning
  expect_equal(tn$folds, 4)
  expect_equal(nrow(tn$table), nrow(TargetWise:::ml_grid("tree", 5)))
  expect_equal(tn$best_auc, max(tn$table$cv_auc, na.rm = TRUE), tolerance = 1e-3)
  expect_equal(unname(unlist(tn$best)), unname(unlist(tn$table[1, c("cp", "maxdepth")])))
  expect_true(tn$best_auc > 0.5 && tn$best_auc <= 1)
  # nothing to tune: no tuning
  expect_null(TargetWise:::fit_scorecard_advanced(df, "FSI_CARI2_2class", crit5t, "Food insecure", method = "logit", tune = TRUE)$tuning)
  expect_null(TargetWise:::ml_grid("logit", 5))
  for (m in intersect(TargetWise:::tunable_models(), TargetWise:::scorecard_model_choices()))
    expect_false(is.null(TargetWise:::ml_grid(m, 5)), info = m)
})

test_that("the settings dialog turns tuning and automatic profiles on", {
  skip_if_not_installed("rpart")
  df <- demo_df()
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure")
    id <- function(k, x) paste0("rv", k, "_", gsub("[^A-Za-z0-9]", "_", x))
    do.call(session$setInputs, stats::setNames(as.list(screened()$criterion %in% crit5t), id("use", screened()$criterion)))
    session$setInputs(nav_next_screening = 1)
    session$setInputs(model_method = "tree", stepwise = "none", compare_models = "logit")
    session$setInputs(tune = TRUE, folds = 3, holdout_pct = 20, split_seed = 1, params_apply = 1)
    expect_true(model_params$tune)
    session$setInputs(run_fit = 1)
    expect_equal(fitted()$tuning$folds, 3)
    expect_false(is.null(fitted()$tree_rules))
    # without an outcome: the number of profiles chosen by silhouette
    session$setInputs(framework_mode = "none")
    do.call(session$setInputs, stats::setNames(as.list(screened()$criterion %in% crit5t), id("use", screened()$criterion)))
    session$setInputs(nav_next_screening = 2)
    session$setInputs(model_method = "kmeans")
    session$setInputs(auto_k = TRUE, params_apply = 2)
    session$setInputs(run_fit = 2)
    ix <- fitted()$index
    expect_false(is.null(ix$k_quality))
    expect_equal(ix$k, ix$k_quality$k[which.max(ix$k_quality$silhouette)])
  })
})

test_that("changing the PCA settings runs nothing: only Fit fits", {
  df <- demo_df()
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure")
    id <- function(k, x) paste0("rv", k, "_", gsub("[^A-Za-z0-9]", "_", x))
    do.call(session$setInputs, stats::setNames(as.list(screened()$criterion %in% crit5t), id("use", screened()$criterion)))
    session$setInputs(nav_next_screening = 1, model_method = "pca", stepwise = "none", compare_models = "logit")
    session$setInputs(run_fit = 1)
    before <- fitted(); n_runs <- length(runs())
    session$setInputs(model_params = 1)                               # open the dialog
    expect_false(is.null(pca_shares()))                               # shares worked out once
    session$setInputs(pca_mode = "var", pca_min_var = 80)
    session$setInputs(pca_min_var = 40, pca_axes = 3)
    expect_identical(fitted(), before)                                # nothing refitted
    session$setInputs(params_apply = 1)
    expect_identical(fitted(), before)                                # applying does not fit either
    expect_equal(length(runs()), n_runs)
    session$setInputs(run_fit = 2)                                    # Fit does
    expect_equal(length(runs()), n_runs + 1)
    expect_equal(fitted()$index$min_var, 0.4)
  })
})
