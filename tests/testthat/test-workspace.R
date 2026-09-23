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
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure", criteria = crit)
    session$setInputs(model_method = "logit", model_scheme = "odds_ratio", holdout_pct = 0,
                      split_seed = 1, run_benchmarks = FALSE, fit_criteria = crit, run_fit = 1)
    session$setInputs(w_1 = 9, ver_2 = TRUE, threshold = 1.5)
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
    session$setInputs(criteria = crit, model_scheme = "odds_ratio")
    expect_null(restoring())
    expect_false(is.null(fitted()))
    expect_equal(fitted()$weights$criterion, snap$fitted$weights$criterion)
    expect_equal(length(runs()), 1)
    expect_equal(saved_points()$weight[1], 9)
    expect_true(saved_points()$verifiable[2])
    # and a real change afterwards rebuilds as before
    session$setInputs(criteria = crit[1:2])
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
  expect_true(any(grepl("Audit trail: 7 entries", got)))
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
