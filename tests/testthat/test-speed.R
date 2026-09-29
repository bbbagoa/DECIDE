# Speed helpers: every core, one row per answer pattern (R/utils_parallel.R)

test_that("the app uses every core unless TARGETWISE_CORES caps it", {
  withr::local_envvar(TARGETWISE_CORES = "")
  expect_equal(TargetWise:::tw_cores(), max(1L, parallel::detectCores()))
  withr::local_envvar(TARGETWISE_CORES = "1")
  expect_equal(TargetWise:::tw_cores(), 1L)
})

test_that("a logistic fit on answer patterns is the fit on every household", {
  set.seed(2); n <- 5000
  d <- data.frame(a = rbinom(n, 1, .4), b = rbinom(n, 1, .3), c = rbinom(n, 1, .5))
  d$out <- ifelse(rbinom(n, 1, plogis(-.5 + d$a - .8 * d$b)) == 1, "yes", "no")
  f <- TargetWise:::fit_scorecard_advanced(d, "out", c("a", "b", "c"), "yes", method = "logit")
  g <- stats::glm(I(out == "yes") ~ a + b + c, data = d, family = stats::binomial())
  expect_equal(f$model$tw_n, n)
  expect_lt(nrow(f$model$data), 20)                                    # at most 2^3 x 2 patterns
  expect_equal(stats::AIC(f$model), stats::AIC(g))
  expect_equal(unname(sort(stats::coef(f$model))), unname(sort(stats::coef(g))), tolerance = 1e-8)
  cp <- TargetWise:::collapse_rows(d, c("a", "b"))
  expect_equal(sum(cp$.n), n); expect_equal(nrow(cp), 4)
})

test_that("tw_lapply gives the same answer as lapply", {
  expect_equal(TargetWise:::tw_lapply(1:3, function(i) i^2, big = FALSE), lapply(1:3, function(i) i^2))
})

test_that("a background job writes its steps and R's messages to the log the waiter reads", {
  log <- withr::local_tempfile(fileext = ".log")
  job <- function(a) { message("reading ", a$n, " rows"); x <- TargetWise:::tw_step("sum the rows", sum(seq_len(a$n)), session = NULL); warning("a small warning"); x }
  res <- suppressWarnings(TargetWise:::bg_call(job, list(n = 10), log))
  expect_equal(res, 55)
  ln <- readLines(log)
  st <- vapply(strsplit(ln, "\t", fixed = TRUE), `[`, "", 1)
  expect_true(all(c("r", "run", "ok", "rwarn") %in% st))
  expect_match(paste(ln, collapse = "\n"), "reading 10 rows")
  expect_match(paste(ln, collapse = "\n"), "sum the rows [(]")
})

test_that("the import hands the table back as parquet, labels kept", {
  f <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(data.frame(a = 1:3000, b = rep(c("x", "y", "z"), 1000)), f, row.names = FALSE)
  p <- TargetWise:::import_job(list(path = f, ext = "csv"))
  expect_s3_class(p, "tw_parquet")
  expect_equal(TargetWise:::unpack_frames(p)$b[1:3], c("x", "y", "z"))
})
