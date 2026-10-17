# In the criteria table: Use ticked for `crit` only, then Continue.
send_criteria <- function(session, candidates, crit) {
  id <- function(k, x) paste0("rv", k, "_", gsub("[^A-Za-z0-9]", "_", x))
  do.call(session$setInputs, stats::setNames(as.list(candidates %in% crit), id("use", candidates)))
  session$setInputs(nav_next_screening = 1)
}

test_that("a saved session carries module work and puts it back", {
  ws <- TargetWise:::workspace_new()
  val <- 0
  TargetWise:::workspace_register(ws, "a", function() list(x = 1), function(s) val <<- s$x)
  TargetWise:::workspace_register(ws, "empty", function() NULL, function(s) stop("never"))
  snap <- TargetWise:::workspace_snapshot(ws)
  expect_equal(names(snap), "a")

  withr::local_envvar(TARGETWISE_SESSION_DIR = withr::local_tempdir())
  TargetWise:::save_session(data.frame(a = 1), list(), data.frame(), name = "ws", workspace = snap)
  TargetWise:::workspace_restore(ws, TargetWise:::load_session("ws")$workspace)
  expect_equal(val, 1)
})

test_that("restoring a Targeting Design keeps the fitted model through the input round trip", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance")
  args <- function(ws) list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                            workspace = ws)
  ws1 <- TargetWise:::workspace_new()
  snap <- NULL
  shiny::testServer(TargetWise:::mod_scorecard_server, args = args(ws1), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    # Criteria go to the model once ticked and community-validated.
    send_criteria(session, screened()$criterion, crit)
    session$setInputs(holdout_pct = 0, split_seed = 1, params_apply = 1)   # the settings dialog
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", 
                      run_benchmarks = FALSE, fit_criteria = crit, run_fit = 1)
    session$setInputs(w_1 = 9, ver_2 = TRUE, threshold = 1.5)
    session$setInputs(apply_points = 1, thr_apply = 1)
    snap <<- TargetWise:::workspace_snapshot(ws1)$scorecard
  })
  expect_false(is.null(snap$fitted))
  expect_equal(snap$points$weight[1], 9)

  ws2 <- TargetWise:::workspace_new()
  shiny::testServer(TargetWise:::mod_scorecard_server, args = args(ws2), {
    ws2$scorecard$restore(snap)
    session$flushReact()
    # the browser sends the restored inputs back one by one
    session$setInputs(outcome_col = "FSI_CARI2_2class")
    session$setInputs(outcome_pos = "Food insecure")
    session$setInputs(model_scheme = "odds_ratio")
    expect_null(restoring())
    expect_equal(ready_criteria(), crit)
    expect_false(is.null(fitted()))
    expect_equal(fitted()$weights$criterion, snap$fitted$weights$criterion)
    expect_equal(length(runs()), 1)
    expect_equal(saved_points()$weight[1], 9)
    expect_true(saved_points()$verifiable[2])
    # and a real change afterwards rebuilds as before
    send_criteria(session, screened()$criterion, crit[1:2])
    expect_null(fitted())
  })
})

test_that("a restored session says what it brought back", {
  sc <- TargetWise:::session_contents
  got <- sc(list(uploaded_df = data.frame(a = 1:3),
                 user_setup = list(scorecard = list(items = list(1, 2), source = "design", adopted_at = "2026-09-01 10:00")),
                 workspace = list(scorecard = list(data = data.frame(x = 1:5), runs = list(1, 2)),
                                  pdm = list(df = data.frame(x = 1:4), results = list(a = 1)),
                                  monitoring = list(datasets = list(a = 1), items = list(1, 2, 3))),
                 modification_log = data.frame(a = 1:7)))
  expect_true(any(grepl("Registration data: 3 households", got)))
  expect_true(any(grepl("2 model run(s), scorecard adopted 2026-09-01", got, fixed = TRUE)))
  expect_true(any(grepl("PDM data (4 rows) with implementation errors", got, fixed = TRUE)))
  expect_true(any(grepl("3 report item", got)))
  expect_true(any(grepl("Activity log: 7 entries", got)))
})

test_that("the autosave fingerprint changes with the work, not with nothing", {
  sig <- TargetWise:::workspace_signature
  a <- list(scorecard = list(data = data.frame(x = 1:3), threshold = 2))
  expect_identical(sig(a), sig(a))
  b <- a; b$scorecard$threshold <- 2.5
  expect_false(identical(sig(a), sig(b)))
  c <- a; c$scorecard$data$y <- 1   # a calculated column
  expect_false(identical(sig(a), sig(c)))
})

test_that("only the ticked criteria go on to the model", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance")
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    expect_equal(ready_criteria(), character(0))              # nothing sent yet
    expect_true(any(screened()$retained))                      # the screening pre-ticked Use
    send_criteria(session, screened()$criterion, crit[1:2])
    expect_equal(ready_criteria(), c("Targ_HHNoLight", "Targ_HHDepRatio2plus"))
    expect_true(selection_applied())
    expect_setequal(names(review()), screened()$criterion)
    session$setInputs(holdout_pct = 0, split_seed = 1, params_apply = 1)   # the settings dialog
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", 
                      run_benchmarks = FALSE, run_fit = 1)
    expect_setequal(fitted()$weights$criterion, c("Targ_HHNoLight", "Targ_HHDepRatio2plus"))
    expect_false(any(current_weights()$validated))   # community validation is not recorded here
  })
})

test_that("the stepwise dropdown and its criterion reach the fit", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance")
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    send_criteria(session, screened()$criterion, crit)
    session$setInputs(holdout_pct = 0, split_seed = 1, params_apply = 1)   # the settings dialog
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", 
                      run_benchmarks = FALSE, stepwise = "forward", stepwise_ic = "bic", run_fit = 1)
    expect_equal(fitted()$stepwise, "bic")
    expect_equal(fitted()$stepwise_dir, "forward")
    session$setInputs(stepwise = "none", run_fit = 2)
    expect_equal(fitted()$stepwise, "none")
  })
})

test_that("a variable whose gap cannot be computed does not break the criteria table", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  df$FSI_CARI2_2class[1:60] <- NA
  df$odd_Bin <- ifelse(seq_len(nrow(df)) <= 60, c("Yes", "No"), NA)   # answered only where the outcome is missing
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    expect_true("odd_Bin" %in% screened()$criterion)
    expect_false(anyNA(screened()$retained))
    ov <- overlap()                                          # the table's overlap column
    expect_false(anyNA(ov$criterion))
    expect_false(anyNA(rownames(ov)))
  })
})

test_that("the model comparison comes from the models chosen to compare", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance")
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    send_criteria(session, screened()$criterion, crit)
    session$setInputs(holdout_pct = 20, split_seed = 1, params_apply = 1)   # the settings dialog
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", 
                      stepwise = "none", compare_models = c("logit", "woe"), run_fit = 1)
    b <- bench()
    expect_gt(length(split_state()$test), 0)                          # the hold-out set in the dialog
    expect_equal(model_params$holdout_pct, 20)
    expect_setequal(b$table$model, c("Scorecard (as adopted)", "Logistic", "Weight of evidence"))
    expect_true(all(b$table$auc_test > 0.5, na.rm = TRUE))
    expect_null(attr(effects(), "fits"))                     # the fits stay in the worker
  })
})

test_that("the tests wait for Run when a setting changes", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", qs_alpha = 0.05, qs_adjust = "BH", fw_validate = 1)
    first <- qs_result()
    expect_false(is.null(first))                                     # ran once, on the new variables
    session$setInputs(qs_alpha = 0.5, qs_adjust = "none")
    expect_identical(qs_result(), first)                             # a setting alone does not re-run
    session$setInputs(qs_run = 1)
    expect_gt(sum(qs_result()$significant), sum(first$significant))  # Run applies it
  })
})

test_that("a changed tolerance needs a rationale, errors beyond it need an explanation", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance")
  setup <- shiny::reactiveValues()
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = setup,
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    send_criteria(session, screened()$criterion, crit)
    session$setInputs(holdout_pct = 0, split_seed = 1, params_apply = 1)   # the settings dialog
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", 
                      stepwise = "none", compare_models = "logit", run_fit = 1)
    session$setInputs(threshold = 1.5, tol_lower = 1, tol_upper = 2, thr_apply = 1)
    expect_true(any(grepl("differs from the default", missing_steps())))
    session$setInputs(tol_rationale = "<p>Very strict band agreed with the programme team.</p>")
    expect_false(any(grepl("differs from the default", missing_steps())))
    expect_true(length(beyond_tolerance()) > 0)
    session$setInputs(nav_adopt = 1)
    expect_null(setup$scorecard)                                     # waits for the explanation
    session$setInputs(exceed_text = "No better design with the criteria observable at registration.", adopt_confirm = 1)
    expect_false(is.null(setup$scorecard))
    expect_match(setup$scorecard$exceed_note, "No better design")
  })
})

test_that("the design report carries each model's results: PCA, LDA and the others", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance", "Targ_HHHousingTent")
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", fw_validate = 1)
    send_criteria(session, screened()$criterion, crit)
    report <- function() paste(readLines(output$download_report, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    session$setInputs(model_method = "pca")
    session$setInputs(pca_mode = "var", pca_min_var = 50, params_apply = 1)   # the settings dialog
    expect_equal(model_params$pca_mode, "var")
    session$setInputs(holdout_pct = 0, split_seed = 1, params_apply = 2)   # the settings dialog
    session$setInputs(
                      stepwise = "none", compare_models = "logit", run_fit = 1, threshold = 1)
    h <- report()
    expect_match(h, "The PCA index", fixed = TRUE)
    expect_match(h, "Total variation explained", fixed = TRUE)
    expect_match(h, "correlation circle, axes 1 and 2", fixed = TRUE)
    expect_false(grepl("Loadings on the axes kept", h, fixed = TRUE))
    expect_false(grepl("Estimates and points", h, fixed = TRUE))
    session$setInputs(model_method = "lda", run_fit = 2)
    h <- report()
    expect_match(h, "The LDA index", fixed = TRUE)
    expect_match(h, "Correlation of each criterion with the index", fixed = TRUE)
    session$setInputs(model_method = "logit", compare_models = c("logit", "woe"), run_fit = 3)
    h <- report()
    expect_match(h, "Estimates and points", fixed = TRUE)
    expect_match(h, "Each criterion under every model", fixed = TRUE)
  })
})
