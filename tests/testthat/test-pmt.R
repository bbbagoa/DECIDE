pmt_data <- function(n = 3000, seed = 2) {
  set.seed(seed)
  d <- data.frame(roof_metal = sample(c("Yes", "No"), n, TRUE), has_tv = rbinom(n, 1, 0.3),
                  hh_size = rpois(n, 5) + 1, rooms = sample(1:5, n, TRUE))
  ly <- 7 + 0.3 * (d$roof_metal == "Yes") + 0.5 * d$has_tv - 0.12 * d$hh_size + 0.1 * d$rooms + rnorm(n, 0, 0.45)
  list(d = d, pc = exp(ly))
}

test_that("fit_pmt recovers the welfare model and its errors at the line", {
  x <- pmt_data()
  line <- unname(stats::quantile(x$pc, 0.3))
  sp <- split_train_test(pmt_poor(x$pc, line), 0.2)
  f <- fit_pmt(x$d, x$pc, names(x$d), line, rows = sp$train, test = sp$test)
  b <- stats::setNames(f$weights$coefficient, f$weights$criterion)
  expect_equal(unname(b[c("roof_metal", "has_tv", "hh_size", "rooms")]), c(0.3, 0.5, -0.12, 0.1), tolerance = 0.1)
  expect_equal(f$weights$direction[f$weights$criterion == "hh_size"], "inclusion")
  expect_equal(f$weights$type[f$weights$criterion == "hh_size"], "numeric")
  expect_true(f$pmt$r2 > 0.3 && f$pmt$r2 < 0.7)
  expect_true(is.finite(f$pmt$r2_test))
  # the quantile regression at the poverty rate lowers exclusion errors
  q <- fit_pmt(x$d, x$pc, names(x$d), line, method = "pmt_qr", rows = sp$train, test = sp$test)
  expect_lt(q$pmt$exclusion_error, f$pmt$exclusion_error)
})

test_that("a PMT card scores 100 x (intercept - predicted log welfare) and selects at the line", {
  x <- pmt_data()
  line <- unname(stats::quantile(x$pc, 0.3))
  f <- fit_pmt(x$d, x$pc, names(x$d), line)
  sc <- build_scorecard(f$weights, threshold = f$pmt$threshold_line, kind = "pmt",
                        pmt = list(intercept = f$pmt$intercept, line = line))
  s <- apply_scorecard(x$d, sc)
  b <- stats::setNames(f$weights$coefficient, f$weights$criterion)
  X <- cbind(roof_metal = as.numeric(x$d$roof_metal == "Yes"), has_tv = x$d$has_tv, hh_size = x$d$hh_size, rooms = x$d$rooms)
  pred <- f$pmt$intercept + as.vector(X[, names(b)] %*% b)
  expect_equal(s$score, round(100 * (f$pmt$intercept - pred), 5), tolerance = 1e-4)
  expect_true(any(s$score < 0))                      # not floored
  expect_equal(mean(s$eligible == (pred < log(line))), 1, tolerance = 1e-3)
  # a missing number takes the training mean
  d2 <- x$d[1:3, ]; d2$hh_size[1] <- NA
  s2 <- apply_scorecard(d2, sc)
  it <- sc$items[[which(vapply(sc$items, `[[`, "", "criterion") == "hh_size")]]
  d3 <- d2; d3$hh_size[1] <- it$mean
  expect_equal(s2$score, apply_scorecard(d3, sc)$score)
  expect_equal(pmt_predicted_welfare(f$pmt$threshold_line, f$pmt$intercept), line, tolerance = 1e-3)
})

test_that("a PMT card survives the workbook and JSON", {
  x <- pmt_data(800)
  line <- unname(stats::quantile(x$pc, 0.3))
  f <- fit_pmt(x$d, x$pc, names(x$d), line)
  sc <- build_scorecard(f$weights, outcome = "PMT: log welfare per person (exp)", threshold = f$pmt$threshold_line,
                        kind = "pmt", pmt = list(intercept = f$pmt$intercept, line = line))
  wb <- scorecard_workbook(sc, meta = list(Outcome = sc$outcome, "Eligibility threshold" = sprintf("score > %s", fmt5(sc$threshold)),
                                           "PMT intercept" = fmt5(f$pmt$intercept), "Poverty line (per person)" = fmt5(line)))
  p <- tempfile(fileext = ".xlsx"); openxlsx::saveWorkbook(wb, p)
  back <- read_scorecard_workbook(p)
  expect_true(is_pmt(back))
  expect_equal(apply_scorecard(x$d, back)$score, apply_scorecard(x$d, sc)$score, tolerance = 1e-3)
  js <- normalise_scorecard(jsonlite::fromJSON(jsonlite::toJSON(sc, auto_unbox = TRUE, null = "null", na = "null", digits = NA),
                                               simplifyVector = FALSE))
  expect_true(is_pmt(js))
  expect_equal(apply_scorecard(x$d, js)$score, apply_scorecard(x$d, sc)$score)
})

test_that("PMT data requirements flag what the guidance asks for", {
  x <- pmt_data(200)
  rq <- pmt_requirements(x$pc, pmt_poor(x$pc, stats::quantile(x$pc, 0.05)), per_person = FALSE, size_given = FALSE, n_proxies = 5)
  st <- stats::setNames(rq$status, rq$check)
  expect_equal(unname(st["Households with a welfare value"]), "fail")
  expect_equal(unname(st["Welfare per person"]), "fail")
  expect_equal(unname(st["Poverty rate"]), "warn")
  expect_equal(unname(st["Households per proxy"]), "ok")
  expect_equal(pmt_welfare(c(100, 90, NA), c(2, 0, 3)), c(50, NA, NA))
  cand <- pmt_numeric_candidates(cbind(x$d, hh_id = seq_len(200), exp_food = x$pc))
  expect_true("hh_size" %in% cand && !"hh_id" %in% cand && !"exp_food" %in% cand)
})

test_that("PMT accuracy measures follow their definitions", {
  sel  <- c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE)
  poor <- c(TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE)
  a <- pmt_accuracy(sel, poor)
  expect_equal(a$inclusion_error, 2 / 4)             # leakage: non-poor among the 4 selected
  expect_equal(a$exclusion_error, 1 / 3)             # under-coverage: 1 of the 3 poor left out
  expect_equal(a$accuracy, 5 / 8)
  expect_equal(a$differential, 2 / 3 - 2 / 5)
  expect_equal(a$cgh, (2 / 4) / (3 / 8))
})

test_that("every PMT model fits; lasso drops a pure-noise proxy", {
  x <- pmt_data(3000)
  set.seed(9); x$d$noise <- rnorm(3000)
  line <- unname(stats::quantile(x$pc, 0.3))
  sp <- split_train_test(pmt_poor(x$pc, line), 0.2)
  for (m in pmt_model_choices()) {
    f <- fit_pmt(x$d, x$pc, names(x$d), line, m, rows = sp$train, test = sp$test)
    expect_true(f$pmt$r2_test > 0.25, info = m)
    expect_equal(f$weights$direction[f$weights$criterion == "hh_size"], "inclusion", info = m)
  }
  l <- fit_pmt(x$d, x$pc, names(x$d), line, "pmt_lasso", rows = sp$train)
  expect_lt(abs(sum(l$weights$coefficient[l$weights$criterion == "noise"])), 0.01)
  cu <- pmt_error_curve(l$pmt$eval, l$pmt$log_line)
  expect_true(all(diff(cu$exclusion_error) <= 1e-9))    # a higher cut-off never leaves more poor out
  dc <- pmt_decile_coverage(l$pmt$eval, l$pmt$log_line)
  expect_gt(dc$selected[1], dc$selected[nrow(dc)])
})

test_that("PMT wording leaves variable names alone", {
  expect_equal(pmt_wording("Vulnerable households and the scorecard in `vulnerable_hh`"),
               "Poor households and the PMT in `vulnerable_hh`")
  expect_equal(pmt_wording(c("Inclusion error", "Inclusion error (leakage)")), rep("Inclusion error (leakage)", 2))
  withr::with_options(list(tw.terms = "pmt"), expect_equal(i18n_lookup("Not vulnerable"), "Non-poor"))
  expect_equal(i18n_lookup("Not vulnerable"), "Not vulnerable")
})
