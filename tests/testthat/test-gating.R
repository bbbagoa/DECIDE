# Settings compute nothing until their button is clicked.

send_criteria <- function(session, candidates, crit) {
  id <- function(k, x) paste0("rv", k, "_", gsub("[^A-Za-z0-9]", "_", x))
  do.call(session$setInputs, stats::setNames(as.list(candidates %in% crit), id("use", candidates)))
  session$setInputs(nav_next_screening = 1)
}

test_that("Targeting Design: the framework, points and threshold wait for their buttons", {
  df <- read.csv(system.file("extdata", "assessment_demo.csv", package = "DECIDE"))
  crit <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance")
  shiny::testServer(DECIDE:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = DECIDE:::workspace_new()), {
    assessment_df(df)
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure")
    expect_null(screened())                                    # chosen, not validated
    expect_null(qs_result())
    session$setInputs(fw_validate = 1)
    expect_false(is.null(screened()))
    send_criteria(session, screened()$criterion, crit)
    session$setInputs(holdout_pct = 0, split_seed = 1, params_apply = 1)
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", stepwise = "none",
                      compare_models = "logit", run_fit = 1)
    w0 <- current_weights()$weight[1]
    session$setInputs(w_1 = w0 + 5)
    expect_equal(current_weights()$weight[1], w0)              # typed, not applied
    session$setInputs(apply_points = 1)
    expect_equal(current_weights()$weight[1], w0 + 5)
    t0 <- thr_applied()
    session$setInputs(threshold = t0 + 1, tol_upper = 30)
    expect_equal(thr_applied(), t0)                            # moved, not applied
    expect_equal(tol_applied()[2], 20)
    session$setInputs(thr_apply = 1)
    expect_equal(thr_applied(), t0 + 1)
    expect_equal(tol_applied()[2], 30)
    # a new scheme is applied to the fit on request only
    session$setInputs(model_scheme = "points")
    expect_equal(fitted()$scheme, "odds_ratio")
    session$setInputs(scheme_apply = 1)
    expect_equal(fitted()$scheme, "points")
  })
})

test_that("profile contrasts: overall shares and Cramer's V", {
  set.seed(1); n <- 2000
  g <- sample(1:3, n, TRUE)
  M <- cbind(a = rbinom(n, 1, c(.2, .5, .9)[g]), b = rbinom(n, 1, .5))
  prof <- sapply(1:3, function(j) colMeans(M[g == j, , drop = FALSE]))
  size <- tabulate(g) / n
  pc <- profile_contrasts(prof, size, n)
  expect_equal(unname(pc$overall), unname(colMeans(M)), tolerance = 1e-9)
  v_direct <- sqrt(suppressWarnings(stats::chisq.test(table(M[, "a"], g), correct = FALSE)$statistic) / n)
  expect_equal(unname(pc$v["a"]), unname(v_direct), tolerance = 1e-9)
  expect_gt(pc$v["a"], 0.5); expect_lt(pc$v["b"], 0.1)
})
