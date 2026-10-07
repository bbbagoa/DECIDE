#' Proxy means test (PMT)
#'
#' The third way to design targeting, next to a scorecard that predicts a
#' food-security outcome and a ranking without an outcome. A PMT predicts a
#' household's welfare (consumption or expenditure per person, in logs) from
#' characteristics a registration team can observe and verify, and a household
#' is eligible when its predicted welfare falls below a poverty line (Grosh &
#' Baker 1995, World Bank LSMS Working Paper 118; Grosh et al. 2008, *For
#' Protection and Promotion*, ch. 4; Del Ninno & Mills 2015, *Safety Nets in
#' Africa*).
#'
#' The model is additive, so it stays a card of points like the others: each
#' proxy's coefficient on log welfare, times 100, is its points (one point is
#' about 1% less predicted welfare per person), and the threshold at the
#' poverty line is 100 x (intercept - log line). Numeric proxies (household
#' size, rooms, members by age) enter with points per unit.
#'
#' Accuracy is the known weak point: at the coverage of most programmes
#' exclusion errors of 40-60% are common, because proxies explain only 30-60%
#' of welfare (Brown, Ravallion & van de Walle 2018, *Journal of Development
#' Economics* 134; Kidd, Gelders & Bailey-Athias 2017, ILO/Development
#' Pathways). The design therefore validates on households the model never
#' saw and reports both errors at the line; a quantile regression at the
#' poverty rate is offered because it fits the bottom of the distribution
#' better than least squares (Brown et al. 2018).
#' @name pmt
#' @noRd
NULL

#' PMT models offered in the Design step
#' @noRd
pmt_model_choices <- function() {
  out <- c("Least squares on log welfare per person (World Bank PMT)" = "pmt_ols",
           "Quantile regression at the poverty rate" = "pmt_qr",
           "Ridge regression (shrinkage, cross-validated)" = "pmt_ridge",
           "Lasso regression (selection and shrinkage, cross-validated)" = "pmt_lasso")
  # machine-learning PMTs (McBride & Nichols 2018): the card keeps their
  # average effects, so it stays additive
  if (requireNamespace("ranger", quietly = TRUE)) out <- c(out, "Random forest regression (machine learning)" = "pmt_rf")
  if (requireNamespace("xgboost", quietly = TRUE)) out <- c(out, "Gradient boosting regression, XGBoost (machine learning)" = "pmt_xgb")
  out
}

#' Welfare per person
#' @param welfare Household welfare (consumption or expenditure).
#' @param size Household size, or NULL when welfare is already per person.
#' @noRd
pmt_welfare <- function(welfare, size = NULL) {
  w <- as_number(welfare)
  if (is.null(size)) return(w)
  s <- as_number(size)
  ifelse(is.finite(s) & s > 0, w / s, NA_real_)
}

#' The poverty line that puts `share` of households below it
#' @noRd
pmt_line_from_share <- function(pc, share, weights = NULL) {
  weighted_quantile(pc, weights, probs = share)
}

#' Poor (1) when welfare per person is at or below the line; NA without welfare
#' @noRd
pmt_poor <- function(pc, line) {
  out <- as.integer(pc <= line)
  out[is.na(pc)] <- NA_integer_
  out
}

#' Columns that can be numeric proxies
#'
#' Numbers with at least three distinct values (household size, rooms,
#' members by age...) that a registration team can observe: identifiers,
#' outcome indicators and what cannot be observed (expenditure, prices,
#' coping...) are left out, as they are for yes/no criteria.
#' @noRd
pmt_numeric_candidates <- function(df, exclude = character(0)) {
  if (is.null(df)) return(character(0))
  cols <- setdiff(names(df), exclude)
  ok <- vapply(cols, function(cl) {
    x <- df[[cl]]
    if (inherits(x, c("Date", "POSIXt"))) return(FALSE)
    if (!is.numeric(x) && !is.character(x)) return(FALSE)
    v <- as_number(x)
    given <- !is.na(x) & nzchar(trimws(as.character(x)))
    if (!any(given) || mean(!is.na(v[given])) < 0.95) return(FALSE)
    length(unique(v[!is.na(v)])) >= 3
  }, logical(1))
  cols <- cols[ok]
  cols[!is_identification_col_v(cols) & !cols %in% outcome_like_columns(cols) & is.na(unobservable_reason(cols))]
}

is_identification_col_v <- function(cols) vapply(cols, is_identification_col, logical(1), USE.NAMES = FALSE)

#' Is the data fit for a PMT?
#'
#' The checks the World Bank guidance puts before any estimation: a welfare
#' aggregate for most households, enough households for the proxies
#' (thousands in a household budget survey; at the very least 10 to 20 per
#' proxy), a poverty rate the model can separate, and no extreme values that
#' would pull a least-squares fit.
#' @param pc Welfare per person.
#' @param poor From `pmt_poor()`.
#' @param per_person Whether the welfare column was already per person.
#' @param size_given Whether a household-size column divides it.
#' @return data.frame(check, status = "ok" / "warn" / "fail", detail)
#' @noRd
pmt_requirements <- function(pc, poor, per_person = TRUE, size_given = FALSE, n_proxies = NA_integer_) {
  n <- length(pc)
  have <- sum(!is.na(pc))
  row <- function(check, status, detail) data.frame(check = check, status = status, detail = detail, stringsAsFactors = FALSE)
  out <- list(
    row("Households with a welfare value",
        if (have >= 1000) "ok" else if (have >= 300) "warn" else "fail",
        sprintf("%s of %s (%.0f%%). A PMT is normally estimated on a household budget survey of several thousand households; below 1,000 the weights are imprecise, below 300 they are not usable.",
                format(have, big.mark = ","), format(n, big.mark = ","), 100 * have / max(n, 1))),
    row("Welfare per person",
        if (per_person || size_given) "ok" else "fail",
        if (per_person) "The welfare column is already per person."
        else if (size_given) "Household welfare divided by household size."
        else "Household welfare needs the household size to be compared with a per-person poverty line."),
    row("Welfare above zero",
        if (mean(pc[!is.na(pc)] <= 0) > 0.01) "warn" else "ok",
        sprintf("%.1f%% of the welfare values are zero or negative: they cannot be logged and are left out of the model (they still count as poor).",
                100 * mean(pc[!is.na(pc)] <= 0))))
  rate <- mean(poor, na.rm = TRUE)
  out[[length(out) + 1]] <- row("Poverty rate",
    if (is.finite(rate) && rate >= 0.1 && rate <= 0.7) "ok" else "warn",
    sprintf("%.1f%% of households are at or below the line. Below 10%% a PMT separates the poor poorly and exclusion errors rise steeply (Brown, Ravallion & van de Walle 2018).",
            100 * rate))
  pos <- pc[!is.na(pc) & pc > 0]
  if (length(pos) >= 20) {
    ratio <- stats::quantile(pos, 0.99) / stats::median(pos)
    out[[length(out) + 1]] <- row("Extreme values",
      if (ratio > 20) "warn" else "ok",
      sprintf("The top 1%% of welfare is %.0f times the median. Very large values pull a least-squares fit: check them, or use the quantile regression.", ratio))
  }
  if (is.finite(n_proxies) && n_proxies > 0) {
    per <- have / n_proxies
    out[[length(out) + 1]] <- row("Households per proxy",
      if (per >= 20) "ok" else if (per >= 10) "warn" else "fail",
      sprintf("%.0f households per proxy in the model (at least 10 to 20 are needed).", per))
  }
  do.call(rbind, out)
}

#' Quantile regression by iteratively reweighted least squares
#'
#' Minimises the check loss sum w_i rho_tau(y_i - x_i b) by repeated weighted
#' least squares with weights w_i * (tau or 1 - tau) / |r_i| (Schlossmacher
#' 1973). It reaches the linear-programming solution to within a small
#' tolerance, without an extra package.
#' @noRd
# ponytail: IRLS approximation of the LP solution; quantreg::rq() if exact
# ties at the optimum ever matter.
qr_irls <- function(X, y, w, tau, iter = 200, tol = 1e-8) {
  b <- stats::lm.wfit(X, y, w)$coefficients
  b[is.na(b)] <- 0
  for (i in seq_len(iter)) {
    r <- as.vector(y - X %*% b)
    ww <- w * ifelse(r > 0, tau, 1 - tau) / pmax(abs(r), 1e-6)
    nb <- stats::lm.wfit(X, y, ww)$coefficients
    nb[is.na(nb)] <- 0
    if (max(abs(nb - b)) < tol) { b <- nb; break }
    b <- nb
  }
  b
}

#' The proxies as model columns: yes/no as 0/1, numbers as they are
#'
#' A missing yes/no answer counts as "no", as in the score; a missing number
#' takes the training mean, which the card keeps so the registration data is
#' scored the same way.
#' @noRd
pmt_matrix <- function(df, criteria, train) {
  type <- character(0); mean_v <- numeric(0); filled <- integer(0)
  cols <- lapply(criteria, function(cl) {
    b <- as_binary_criterion(df[[cl]])
    v <- if (is.null(b)) as_number(df[[cl]]) else as.numeric(b)
    ty <- if (is.null(b)) "numeric" else "binary"
    fill <- if (ty == "numeric") mean(v[train], na.rm = TRUE) else 0
    if (!is.finite(fill)) fill <- 0
    filled[cl] <<- sum(is.na(v[train]))
    v[is.na(v)] <- fill
    type[cl] <<- ty; mean_v[cl] <<- if (ty == "numeric") fill else NA_real_
    v
  })
  M <- matrix(unlist(cols), ncol = length(criteria), dimnames = list(NULL, criteria))
  list(M = M, type = type, mean = mean_v, filled = filled)
}

#' Fit a proxy means test
#'
#' @param df Assessment data (the proxies).
#' @param pc Welfare per person, one per row of `df`.
#' @param criteria Proxy columns (yes/no or numeric).
#' @param line Poverty line, per person, in the welfare's unit.
#' @param method "pmt_ols" or "pmt_qr".
#' @param rows Training rows; `test` the held-out rows (may be empty).
#' @param weights Optional survey weights, one per row of `df`.
#' @param stepwise "none", "aic" or "bic"; `stepwise_dir` its direction.
#' @param tau Quantile for "pmt_qr"; the poverty rate of the training
#'   households when NULL.
#' @return The shape of `fit_scorecard_advanced()` (weights with `type` and
#'   `mean` columns, points = 100 x |coefficient|), plus `pmt`: intercept,
#'   line, R-squared in and out of sample, errors at the line, a sample of
#'   predicted against actual welfare.
#' @noRd
fit_pmt <- function(df, pc, criteria, line, method = "pmt_ols", rows = NULL, test = integer(0),
                    weights = NULL, stepwise = "none", stepwise_dir = "backward", tau = NULL) {
  if (!length(criteria)) stop("No proxies to model.", call. = FALSE)
  if (length(line) != 1 || !is.finite(line) || line <= 0) stop("Set a poverty line above zero.", call. = FALSE)
  n <- nrow(df)
  w_all <- if (is.null(weights)) rep(1, n) else suppressWarnings(as.numeric(weights))
  y_all <- ifelse(is.finite(pc) & pc > 0, log(pc), NA_real_)
  if (is.null(rows)) rows <- seq_len(n)
  train <- rows[!is.na(y_all[rows]) & is.finite(w_all[rows]) & w_all[rows] > 0]
  if (length(train) < 30) stop("Fewer than 30 training households have a welfare value above zero.", call. = FALSE)

  pm <- pmt_matrix(df, criteria, train)
  M <- pm$M
  keep <- vapply(criteria, function(cl) length(unique(M[train, cl])) > 1, logical(1))
  criteria <- criteria[keep]
  if (!length(criteria)) stop("Every proxy is constant among the training households.", call. = FALSE)
  M <- M[, criteria, drop = FALSE]
  wt <- w_all[train] / mean(w_all[train])
  d <- as.data.frame(M[train, , drop = FALSE]); d$.y <- y_all[train]; d$.w <- wt

  step_dropped <- character(0)
  if (stepwise %in% c("aic", "bic")) {
    k <- if (identical(stepwise, "bic")) log(nrow(d)) else 2
    full_f <- stats::reformulate(sprintf("`%s`", criteria), response = ".y")
    dir <- if (stepwise_dir %in% c("forward", "both")) stepwise_dir else "backward"
    start <- stats::lm(if (identical(dir, "backward")) full_f else .y ~ 1, data = d, weights = .w)
    sm <- stats::step(start, scope = list(lower = ~ 1, upper = full_f), direction = dir, trace = 0, k = k)
    sel <- intersect(criteria, gsub("`", "", attr(stats::terms(sm), "term.labels")))
    if (!length(sel)) stop("Stepwise selection removed every proxy: none predicts welfare once the others are known.", call. = FALSE)
    step_dropped <- setdiff(criteria, sel)
    criteria <- sel
  }

  if (identical(method, "pmt_qr") && is.null(tau)) tau <- stats::weighted.mean(pc[train] <= line, w_all[train], na.rm = TRUE)
  est <- pmt_estimate(method, M[train, criteria, drop = FALSE], d$.y, d$.w, tau = tau)
  b <- est$b; se <- est$se; p <- est$p; tau <- est$tau
  names(b) <- c("(Intercept)", criteria)
  beta <- b[-1]
  nz <- abs(beta) > 1e-9
  if (!any(nz)) stop("The model gave every proxy a zero effect.", call. = FALSE)

  # predicted log welfare for every household (missing proxies filled as in
  # the score)
  pred <- as.vector(b[1] + pm$M[, criteria, drop = FALSE] %*% beta)
  r2 <- function(idx) {
    idx <- idx[!is.na(y_all[idx])]
    if (length(idx) < 10) return(NA_real_)
    w <- w_all[idx]; y <- y_all[idx]; m <- stats::weighted.mean(y, w)
    1 - sum(w * (y - pred[idx])^2) / sum(w * (y - m)^2)
  }
  eval_rows <- if (length(test)) test else train
  poor <- pmt_poor(pc, line)
  pred_poor <- as.integer(pred <= log(line))
  er <- eval_rows[!is.na(poor[eval_rows])]
  acc <- pmt_accuracy(pred_poor[er] == 1, poor[er] == 1)
  r2_in <- r2(train); k <- sum(nz)
  # the evaluation households for the charts (welfare above zero), at most 50,000
  set.seed(1)
  ev <- er[!is.na(y_all[er])]
  if (length(ev) > 50000) ev <- sort(sample(ev, 50000))
  # a machine-learning PMT: how well the model itself predicts, before the
  # card averages its effects
  r2_model <- if (!is.null(est$predict) && length(test)) {
    te <- test[!is.na(y_all[test])]
    pm_te <- est$predict(pm$M[te, criteria, drop = FALSE])
    w <- w_all[te]; y <- y_all[te]; 1 - sum(w * (y - pm_te)^2) / sum(w * (y - stats::weighted.mean(y, w))^2)
  } else NA_real_

  out <- data.frame(criterion = criteria[nz], coefficient = unname(beta[nz]), odds_ratio = NA_real_,
                    std_error = unname(se[-1][nz]), or_low = NA_real_, or_high = NA_real_,
                    p_value = unname(p[-1][nz]), stringsAsFactors = FALSE)
  out$direction <- ifelse(out$coefficient < 0, "inclusion", "exclusion")
  out$weight <- round(100 * abs(out$coefficient), 5)
  out$type <- unname(pm$type[out$criterion])
  out$mean <- unname(pm$mean[out$criterion])
  out <- out[order(-abs(out$coefficient)), , drop = FALSE]
  rownames(out) <- NULL

  diag <- list(
    method = method, tau = tau, intercept = unname(b[1]), line = line, log_line = log(line),
    threshold_line = unname(round(100 * (b[1] - log(line)), 5)),
    r2 = r2_in, adj_r2 = 1 - (1 - r2_in) * (length(train) - 1) / max(length(train) - k - 1, 1),
    r2_test = if (length(test)) r2(test) else NA_real_,
    headcount = stats::weighted.mean(poor[er], w_all[er], na.rm = TRUE),
    inclusion_error = acc$inclusion_error, exclusion_error = acc$exclusion_error, accuracy = acc,
    rmse = sqrt(sum(w_all[ev] * (y_all[ev] - pred[ev])^2) / sum(w_all[ev])),
    r2_model_test = r2_model, lambda = est$lambda,
    n_train = length(train), n_test = length(test), n_nonpositive = sum(!is.na(pc) & pc <= 0),
    held_out = length(test) > 0,
    eval = data.frame(actual = y_all[ev], predicted = pred[ev], w = w_all[ev]))
  list(weights = round5(out), dropped = c(step_dropped, criteria[!nz]), model = NULL, n = length(train),
       filled = pm$filled[pm$filled > 0 & names(pm$filled) %in% criteria], converged = TRUE,
       method = method, scheme = "pmt", stepwise = stepwise, stepwise_dir = stepwise_dir,
       pmt = diag, diagram = NULL)
}

#' Predicted welfare per person for a PMT score
#' @noRd
pmt_predicted_welfare <- function(score, intercept) exp(intercept - score / 100)

#' Is this card a proxy means test?
#' @noRd
is_pmt <- function(sc) identical(sc$kind, "pmt") || isTRUE(grepl("^PMT", sc$outcome %||% ""))

#' Numeric proxies at a glance: average, missing, correlation with log welfare
#' @noRd
pmt_numeric_profile <- function(df, cols, pc) {
  ly <- ifelse(is.finite(pc) & pc > 0, log(pc), NA_real_)
  do.call(rbind, lapply(cols, function(cl) {
    x <- as_number(df[[cl]]); ok <- !is.na(x) & !is.na(ly)
    data.frame(proxy = cl, mean = mean(x, na.rm = TRUE), missing = mean(is.na(x)),
               r = if (sum(ok) > 10 && stats::sd(x[ok]) > 0) stats::cor(x[ok], ly[ok]) else NA_real_,
               stringsAsFactors = FALSE)
  }))
}

#' A welfare amount, readable: 3 significant digits, thousands separated
#' @noRd
fmt_money <- function(x) {
  if (length(x) != 1 || !is.finite(x)) return("n/a")
  format(signif(x, 3), big.mark = ",", scientific = FALSE, trim = TRUE)
}

#' The fit of a PMT in a few figures (Targeting Design, step 3)
#'
#' Each figure: title, value, sub (a line under it, `%s` replaced by `arg`)
#' and tip, in English; the page translates them.
#' @noRd
pmt_fit_figs <- function(p) {
  pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  r2 <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.2f", v)
  where <- if (isTRUE(p$held_out)) "held-out households" else "training households (no hold-out)"
  figs <- list(
    pmt_fig("R\u00b2 (training)", r2(p$r2), "adjusted %s",
            "Share of the variance of log welfare per person the proxies explain. PMTs usually reach 0.3 to 0.6; above 0.6 on survey data is rare.", r2(p$adj_r2)),
    pmt_fig("R\u00b2 (held out)", r2(p$r2_test), "households the model never saw",
            "The honest figure: a large drop from the training R\u00b2 means the model learnt noise (too many proxies for the sample)."),
    if (is.finite(p$r2_model_test %||% NA)) pmt_fig("R\u00b2 of the model itself", r2(p$r2_model_test), "held out, before the card averages it",
            "A machine-learning PMT predicts with interactions; the card keeps each proxy's average effect. The gap between the two R\u00b2 is what the additive card gives up."),
    pmt_fig("Prediction error (RMSE)", sprintf("%.2f", p$rmse %||% NA), "log points, evaluation households",
            "Root mean squared error of predicted log welfare. 0.45 means a typical household is predicted about 45% above or below its measured welfare."),
    pmt_fig("Poverty rate (headcount)", pct(p$headcount), "line %s per person", NULL, fmt_money(p$line)),
    pmt_fig("Leakage / under-coverage", sprintf("%s / %s", pct(p$inclusion_error), pct(p$exclusion_error)), "at the line, %s",
            "Inclusion error (leakage): non-poor households among those selected. Exclusion error (under-coverage): poor households not selected. Step 4 shows them for any cut-off, with the other PMT accuracy measures.", where),
    if (identical(p$method, "pmt_qr")) pmt_fig("Quantile", sprintf("%.2f", p$tau), "the poverty rate of the training households"),
    if (is.finite(p$lambda %||% NA)) pmt_fig("Penalty (\u03bb)", format(signif(p$lambda, 3)), "chosen by 5-fold cross-validation"))
  list(figs = Filter(Negate(is.null), figs), nonpositive = p$n_nonpositive %||% 0,
       under = if (is.finite(p$exclusion_error) && p$exclusion_error > 0.4) pct(p$exclusion_error))
}

pmt_fig <- function(title, value, sub = NULL, tip = NULL, arg = NULL) list(title = title, value = value, sub = sub, tip = tip, arg = arg)

#' The PMT accuracy measures at the current cut-off (threshold step)
#' @noRd
pmt_accuracy_figs <- function(a, f, cut) {
  pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  w <- exp(cut)
  list(welfare = fmt_money(w), pct_line = 100 * w / f$line, n = a$n, figs = list(
    pmt_fig("Leakage", pct(a$inclusion_error), "inclusion error: non-poor among the selected",
            "Share of the households selected who are not poor (measured welfare above the line)."),
    pmt_fig("Under-coverage", pct(a$exclusion_error), "exclusion error: poor not selected",
            "Share of the poor households the PMT leaves out."),
    pmt_fig("Coverage of the poor", pct(a$coverage_poor), "non-poor covered: %s", NULL, pct(a$coverage_nonpoor)),
    pmt_fig("Targeting accuracy", pct(a$accuracy), "households classified correctly",
            "Poor and selected, or non-poor and not selected, over all households."),
    pmt_fig("Targeting differential", if (is.na(a$differential)) "n/a" else sprintf("%.2f", a$differential),
            "coverage of the poor minus the non-poor",
            "Ravallion (2000): 1 is perfect targeting, 0 no better than chance, negative worse than chance."),
    pmt_fig("CGH indicator", if (is.na(a$cgh)) "n/a" else sprintf("%.2f", a$cgh), "1 = random selection",
            "Coady, Grosh & Hoddinott (2004): the share of beneficiaries who are poor divided by the poverty rate. Above 1 the PMT does better than random; with equal transfers it is the share of the budget reaching the poor over their population share."),
    pmt_fig("Selected", pct(a$selected), "poverty rate %s", NULL, pct(a$headcount))))
}

#' The PMT model comparison as a table; the best held-out R-squared marked
#' @noRd
pmt_compare_html <- function(tab) {
  best <- suppressWarnings(max(tab$r2_test, na.rm = TRUE))
  pct <- function(v) if (is.na(v)) "-" else sprintf("%.1f%%", 100 * v)
  num <- function(v, d = 3) if (is.na(v)) "-" else formatC(v, format = "f", digits = d)
  tags$div(class = "wfp-model-table-wrap", tags$table(
    class = "wfp-model-table",
    tags$thead(tags$tr(tags$th("Model"), tags$th(class = "num", "Proxies"), tags$th(class = "num", "R\u00b2 training"),
                       tags$th(class = "num", "R\u00b2 held out"), tags$th(class = "num", "Leakage"),
                       tags$th(class = "num", "Under-coverage"), tags$th(class = "num", "Accuracy"), tags$th(class = "num", "CGH"))),
    tags$tbody(lapply(seq_len(nrow(tab)), function(i) {
      r <- tab[i, ]; top <- isTRUE(r$r2_test == best)
      tags$tr(class = if (top) "is-best" else NULL,
              tags$td(tags$strong(r$model), if (top) tags$span(class = "wfp-kept ms-2", bsicons::bs_icon("trophy"), " best R\u00b2")),
              tags$td(class = "num", r$proxies), tags$td(class = "num", num(r$r2_train)), tags$td(class = "num", num(r$r2_test)),
              tags$td(class = "num", pct(r$inclusion_error)), tags$td(class = "num", pct(r$exclusion_error)),
              tags$td(class = "num", pct(r$accuracy)), tags$td(class = "num", num(r$cgh, 2)))
    }))))
}

#' The PMT's estimates, with the points editable in place
#' @noRd
pmt_coefficients_html <- function(wts, points = NULL) {
  rows <- lapply(seq_len(nrow(wts)), function(i) {
    r <- wts[i, ]
    num <- identical(r$type, "numeric")
    tags$tr(
      tags$td(tags$strong(r$criterion), if (num) tags$span(class = "small text-muted", " (per unit)")),
      tags$td(class = "num", sprintf("%+.4f", r$coefficient)),
      tags$td(class = "num", if (is.na(r$std_error)) "-" else sprintf("%.4f", r$std_error)),
      tags$td(class = "num", sprintf("%+.1f%%", 100 * (exp(r$coefficient) - 1))),
      tags$td(class = "num", p_pill(r$p_value)),
      tags$td(dir_badge(r$direction)),
      tags$td(class = "num", if (is.null(points)) tags$strong(sprintf("%.2f", r$weight)) else points[[i]]))
  })
  tagList(
    tags$div(
      class = "wfp-model-table-wrap",
      tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(
          tags$th("Proxy"), tags$th(class = "num", "\u03b2 (log welfare)"), tags$th(class = "num", "SE"),
          tags$th(class = "num", tagList("Effect on welfare", info_tip("How much higher (+) or lower (-) predicted welfare per person is for a household with this characteristic, or per unit of a number, all else equal."))),
          tags$th(class = "num", "p"), tags$th("Direction"), tags$th(class = "num", "Points"))),
        tags$tbody(rows))),
    tags$div(class = "small text-muted mt-2",
             "Inclusion: the proxy lowers predicted welfare, so it adds points. Points = 100 \u00d7 |\u03b2|."),
    p_legend())
}

#' The design report's section 2 for a proxy means test
#' @noRd
pmt_report_md <- function(p, estimates = NULL, figures = character(0)) {
  f <- p$fit
  rq <- p$requirements
  fig <- function(...) { k <- intersect(c(...), figures); if (length(k)) c(sprintf("@@FIG:%s@@", paste(k, collapse = ",")), "") }
  pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  a <- p$accuracy
  acc_md <- if (!is.null(a)) c("### PMT targeting accuracy at the adopted cut-off", "",
    md_table(data.frame(
      Measure = c("Inclusion error (leakage)", "Exclusion error (under-coverage)", "Coverage of the poor", "Coverage of the non-poor",
                  "Targeting accuracy", "Targeting differential", "CGH indicator", "Households selected", "Poverty rate (headcount)"),
      Value = c(pct(a$inclusion_error), pct(a$exclusion_error), pct(a$coverage_poor), pct(a$coverage_nonpoor), pct(a$accuracy),
                sprintf("%.2f", a$differential), sprintf("%.2f", a$cgh), pct(a$selected), pct(a$headcount)),
      Meaning = c("non-poor households among those selected", "poor households not selected", "share of the poor selected",
                  "share of the non-poor selected", "households classified correctly",
                  "coverage of the poor minus coverage of the non-poor (Ravallion 2000; 1 perfect, 0 chance)",
                  "share of beneficiaries who are poor over the poverty rate (Coady, Grosh & Hoddinott 2004; 1 random)",
                  "share of households selected", "share of households at or below the line"), check.names = FALSE)),
    sprintf("_Measured on %s evaluation households._", format(a$n, big.mark = ",")), "",
    fig("pmt_decile", "pmt_curve"))
  cmp <- p$comparison
  cmp_md <- if (!is.null(cmp) && nrow(cmp) > 1) c("### PMT model comparison", "",
    "Every model was fitted on the same proxies and training households and evaluated on the same held-out households, with the cut-off at the poverty line.", "",
    md_table(data.frame(Model = cmp$model, Proxies = cmp$proxies, `R2 training` = sprintf("%.3f", cmp$r2_train),
                        `R2 held out` = ifelse(is.na(cmp$r2_test), "n/a", sprintf("%.3f", cmp$r2_test)),
                        Leakage = vapply(cmp$inclusion_error, pct, ""), `Under-coverage` = vapply(cmp$exclusion_error, pct, ""),
                        Accuracy = vapply(cmp$accuracy, pct, ""), CGH = sprintf("%.2f", cmp$cgh), check.names = FALSE)), "",
    fig("pmt_compare"))
  c("## 2. Welfare measure: proxy means test", "",
    sprintf("- Welfare variable: `%s`, %s", p$welfare %||% "",
            if (identical(p$unit, "pc")) "per person" else sprintf("per household, divided by the household size `%s`", p$size %||% "")),
    sprintf("- Households with a welfare value: %s; median welfare per person: %s", format(p$n %||% NA, big.mark = ","), fmt_money(p$median)),
    sprintf("- Poverty line per person: **%s**%s", fmt_money(p$line),
            if (identical(p$line_mode, "share")) sprintf(" (the welfare that puts %s%% of households below it: relative targeting)", p$share) else ""),
    if (!is.null(f)) sprintf("- Poor at the line: %s of the evaluation households", md_pct(f$headcount)),
    if (length(p$numeric)) sprintf("- Numeric proxies (points per unit): %s", paste0("`", p$numeric, "`", collapse = ", ")),
    "", "Households are eligible when their welfare predicted from observable proxies is at or below the line. Welfare itself,",
    "expenditure, income and coping answers are never proxies: they are what the model predicts, or cannot be verified at registration.", "",
    if (!is.null(rq) && nrow(rq)) c("### Data requirements", "",
      md_table(data.frame(Check = rq$check, Status = c(ok = "met", warn = "check", fail = "NOT MET")[rq$status],
                          Detail = rq$detail, check.names = FALSE)), ""),
    if (!is.null(f)) c("### Fit of the model", "",
      sprintf("- Model: %s%s", model_label(f$method), if (identical(f$method, "pmt_qr")) sprintf(" (quantile %.2f)", f$tau) else ""),
      sprintf("- R-squared: %.3f on the training households (adjusted %.3f); %s on households the model never saw",
              f$r2, f$adj_r2, if (is.na(f$r2_test)) "not measured (no hold-out)" else sprintf("%.3f", f$r2_test)),
      sprintf("- Intercept: %s; the threshold at the poverty line is a score of %s", fmt5(f$intercept), fmt5(f$threshold_line)),
      sprintf("- Prediction error (RMSE): %.3f log points", f$rmse %||% NA_real_),
      if (is.finite(f$r2_model_test %||% NA)) sprintf("- R-squared of the machine-learning model itself (held out): %.3f; the card keeps its average effects", f$r2_model_test),
      if (is.finite(f$lambda %||% NA)) sprintf("- Penalty chosen by 5-fold cross-validation: %s", format(signif(f$lambda, 3))),
      sprintf("- With the cut-off at the line: leakage %s, under-coverage %s", md_pct(f$inclusion_error), md_pct(f$exclusion_error)),
      if (is.finite(p$cutoff %||% NA)) sprintf("- Adopted cut-off: eligible when predicted welfare per person is below **%s** (%.0f%% of the line)",
                                             fmt_money(p$cutoff), 100 * p$cutoff / p$line),
      "", "**The formula.** predicted log welfare per person = intercept + the sum of each proxy's coefficient times its value.",
      "The card turns it into points (100 x the coefficient: one point is about 1% less predicted welfare), so the score is",
      "100 x (intercept - predicted log welfare) and a household is eligible when its score is above the threshold.", ""),
    if (!is.null(estimates) && nrow(estimates) && !is.null(estimates$type)) c(
      md_table(data.frame(Proxy = estimates$criterion, Type = ifelse(estimates$type %in% "numeric", "number", "yes/no"),
                          Coefficient = sprintf("%+.4f", estimates$coefficient),
                          `Effect on welfare` = sprintf("%+.1f%%", 100 * (exp(estimates$coefficient) - 1)),
                          Direction = estimates$direction, Points = fmt5(estimates$weight),
                          `If missing` = ifelse(estimates$type %in% "numeric", fmt5(estimates$mean), "no"), check.names = FALSE)), ""),
    acc_md, "", cmp_md, "", if (!is.null(f)) fig("pmt_fit"),
    "_Expect exclusion errors: PMTs typically leave out 40-60% of the poor at the coverage of most programmes (Brown, Ravallion & van de Walle 2018).",
    "Validate the criteria with the community, publish how eligibility is decided, and keep a grievance mechanism (Kidd, Gelders & Bailey-Athias 2017)._")
}

#' The method text for a proxy means test (report, section 7)
#' @noRd
pmt_method_text <- function(p) {
  f <- p$fit %||% list()
  paste0(
    "Welfare per person was logged and regressed on the proxies ",
    switch(f$method %||% "pmt_ols",
      pmt_qr = sprintf("by quantile regression at the %.2f quantile, the poverty rate, estimated by iteratively reweighted least squares (Koenker & Bassett 1978; Brown, Ravallion & van de Walle 2018). ", f$tau %||% NA_real_),
      pmt_ridge = "by ridge regression on standardised proxies, the penalty chosen by 5-fold cross-validation (Hoerl & Kennard 1970): shrinkage steadies the weights when proxies overlap. ",
      pmt_lasso = "by lasso regression on standardised proxies, the penalty chosen by 5-fold cross-validation (Tibshirani 1996): weak proxies are set to zero. ",
      pmt_rf = "by a random forest regression (300 trees; McBride & Nichols 2018 on machine-learning PMTs); each proxy's coefficient is its average effect on the forest's prediction, so the card stays additive. ",
      pmt_xgb = "by gradient-boosted trees (XGBoost, depth 3, 200 rounds; McBride & Nichols 2018); each proxy's coefficient is its average effect on the prediction, so the card stays additive. ",
      "by weighted least squares, the World Bank's standard proxy means test (Grosh & Baker 1995; Grosh et al. 2008). "),
    "Yes/no proxies enter as 0/1 (a missing answer as no), numbers as they are (a missing value at the training mean). ",
    "Households with zero or negative welfare were left out of the fit and still counted as poor. ",
    "A household is poor when its measured welfare per person is at or below the line, and predicted poor when its predicted welfare is; ",
    "leakage (inclusion error: non-poor among the selected) and under-coverage (exclusion error: poor not selected) compare the two on the held-out households, ",
    "with coverage of the poor and non-poor, targeting accuracy, the targeting differential (Ravallion 2000) and the Coady-Grosh-Hoddinott indicator (2004). ",
    "The R-squared is the share of the variance of log welfare the proxies explain; RMSE the typical prediction error in log points.")
}

#' One PMT estimator on the training households
#'
#' @param X Proxy matrix (no intercept column); `y` log welfare per person;
#'   `w` weights (mean 1).
#' @return list(b = intercept then one coefficient per column, se, p, tau,
#'   lambda, predict = the model's own prediction for a machine-learning PMT)
#' @noRd
pmt_estimate <- function(method, X, y, w, tau = NULL) {
  X1 <- cbind(1, X)
  na <- rep(NA_real_, ncol(X1))
  out <- list(b = NULL, se = na, p = na, tau = NA_real_, lambda = NA_real_, predict = NULL)
  if (method %in% c("pmt_ridge", "pmt_lasso")) {
    r <- pen_fit(X, y, w, alpha = if (method == "pmt_lasso") 1 else 0)
    out$b <- r$b; out$lambda <- r$lambda
    return(out)
  }
  if (method %in% c("pmt_rf", "pmt_xgb")) {
    r <- pmt_ml_effects(method, X, y, w)
    out$b <- r$b; out$predict <- r$predict
    return(out)
  }
  if (identical(method, "pmt_qr")) {
    out$tau <- min(max(tau %||% 0.3, 0.05), 0.95)
    out$b <- qr_irls(X1, y, w, out$tau)
    return(out)
  }
  ols <- stats::lm.wfit(X1, y, w)
  b <- ols$coefficients; b[is.na(b)] <- 0
  df_res <- max(nrow(X1) - ncol(X1), 1)
  sigma2 <- sum(w * ols$residuals^2) / df_res
  xtwx <- tryCatch(solve(crossprod(X1 * sqrt(w))), error = function(e) NULL)
  se <- if (is.null(xtwx)) na else sqrt(pmax(diag(xtwx) * sigma2, 0))
  out$b <- b; out$se <- se; out$p <- 2 * stats::pt(-abs(b / se), df_res)
  out
}

#' Ridge (alpha = 0) or lasso (alpha = 1) regression, penalty chosen by
#' 5-fold cross-validation
#'
#' The proxies are standardised (weighted) so the penalty treats them alike;
#' the fit works on the weighted cross-products, so its cost does not grow
#' with the number of households once they are computed. Shrinking the
#' coefficients guards against the overfitting that makes PMT weights
#' unstable from one survey to the next.
#' @noRd
pen_fit <- function(X, y, w, alpha = 0, folds = 5, seed = 123) {
  w <- w / sum(w)
  mx <- colSums(w * X)
  Xc <- sweep(X, 2, mx)
  sx <- sqrt(colSums(w * Xc^2)); sx[!is.finite(sx) | sx == 0] <- 1
  Xs <- sweep(Xc, 2, sx, "/")
  my <- sum(w * y); yc <- y - my
  p <- ncol(Xs)
  gram <- function(idx) {
    ww <- w[idx] / sum(w[idx])
    list(G = crossprod(Xs[idx, , drop = FALSE] * ww, Xs[idx, , drop = FALSE]),
         c = colSums(Xs[idx, , drop = FALSE] * (ww * yc[idx])))
  }
  solve_at <- function(g, lam, b = rep(0, p)) {
    if (alpha == 0) return(as.vector(solve(g$G + diag(lam, p), g$c)))
    for (it in seq_len(500)) {                     # coordinate descent on the Gram matrix
      moved <- 0
      for (j in seq_len(p)) {
        z <- g$c[j] - sum(g$G[j, -j] * b[-j])
        nb <- sign(z) * max(abs(z) - lam, 0) / g$G[j, j]
        moved <- max(moved, abs(nb - b[j])); b[j] <- nb
      }
      if (moved < 1e-7) break
    }
    b
  }
  full <- gram(seq_along(y))
  top <- if (alpha == 1) max(abs(full$c)) else max(1, sum(diag(full$G)))
  lams <- top * 10^seq(0, -4, length.out = 30)
  set.seed(seed)
  fold <- sample(rep_len(seq_len(folds), length(y)))
  grams <- lapply(seq_len(folds), function(k) gram(which(fold != k)))
  cv <- vapply(lams, function(l) {
    mean(vapply(seq_len(folds), function(k) {
      te <- which(fold == k); b <- solve_at(grams[[k]], l)
      sum(w[te] * (yc[te] - Xs[te, , drop = FALSE] %*% b)^2) / sum(w[te])
    }, numeric(1)))
  }, numeric(1))
  lam <- lams[which.min(cv)]
  b <- solve_at(full, lam) / sx
  list(b = c(my - sum(b * mx), b), lambda = lam)
}

#' A machine-learning PMT as additive points
#'
#' A random forest or gradient boosting predicts log welfare; each proxy's
#' coefficient is its average effect on that prediction (yes against no for
#' a yes/no proxy, one unit more for a number), on up to 2,000 training
#' households. The intercept makes the card's average prediction match the
#' model's. The model's own prediction is kept to report how much the card
#' gives up (McBride & Nichols 2018 for machine-learning PMTs).
#' @noRd
pmt_ml_effects <- function(method, X, y, w, seed = 123, n_eff = 2000) {
  set.seed(seed)
  if (method == "pmt_rf") {
    fit <- ranger::ranger(x = as.data.frame(X), y = y, case.weights = w, num.trees = 300,
                          min.node.size = 10, seed = seed, num.threads = tw_cores())
    pf <- function(nd) stats::predict(fit, data = as.data.frame(nd))$predictions
  } else {
    dm <- xgboost::xgb.DMatrix(X, label = y, weight = w)
    fit <- xgboost::xgb.train(params = list(objective = "reg:squarederror", nthread = tw_cores(), max_depth = 3,
                                            eta = 0.1, subsample = 0.8),
                              data = dm, nrounds = 200, verbose = 0)
    pf <- function(nd) stats::predict(fit, xgboost::xgb.DMatrix(as.matrix(nd)))
  }
  idx <- if (nrow(X) > n_eff) sample.int(nrow(X), n_eff) else seq_len(nrow(X))
  base <- X[idx, , drop = FALSE]
  eff <- vapply(seq_len(ncol(X)), function(j) {
    if (all(X[, j] %in% c(0, 1))) {
      hi <- base; lo <- base; hi[, j] <- 1; lo[, j] <- 0
      mean(pf(hi) - pf(lo))
    } else {
      up <- base; up[, j] <- up[, j] + 1
      mean(pf(up) - pf(base))
    }
  }, numeric(1))
  b0 <- stats::weighted.mean(pf(X), w) - sum(eff * colSums(w * X) / sum(w))
  list(b = c(b0, eff), predict = pf)
}

#' Targeting accuracy of a PMT (the standard measures)
#'
#' - inclusion error (leakage): share of those selected who are not poor;
#' - exclusion error (under-coverage): share of the poor not selected;
#' - coverage of the poor and of the non-poor;
#' - targeting accuracy: share of households classified correctly;
#' - targeting differential: coverage of the poor minus coverage of the
#'   non-poor (Ravallion 2000; 1 is perfect, 0 no better than chance);
#' - CGH indicator: share of beneficiaries who are poor divided by the
#'   poverty rate (Coady, Grosh & Hoddinott 2004; 1 is random, higher is
#'   better, with equal transfers).
#' @param selected,poor Logical, one per household.
#' @noRd
pmt_accuracy <- function(selected, poor, w = NULL) {
  ok <- !is.na(selected) & !is.na(poor)
  s <- as.logical(selected)[ok]; q <- as.logical(poor)[ok]
  w <- if (is.null(w)) rep(1, length(s)) else as.numeric(w)[ok]
  tot <- function(m) sum(w[m])
  sel <- tot(s); np <- tot(q); nn <- tot(!q); N <- sum(w)
  cov_p <- if (np > 0) tot(s & q) / np else NA_real_
  cov_n <- if (nn > 0) tot(s & !q) / nn else NA_real_
  list(n = length(s), selected = if (N > 0) sel / N else NA_real_, headcount = if (N > 0) np / N else NA_real_,
       inclusion_error = if (sel > 0) tot(s & !q) / sel else NA_real_,
       exclusion_error = if (np > 0) tot(!s & q) / np else NA_real_,
       coverage_poor = cov_p, coverage_nonpoor = cov_n,
       accuracy = if (N > 0) tot(s == q) / N else NA_real_,
       differential = cov_p - cov_n,
       cgh = if (sel > 0 && np > 0) (tot(s & q) / sel) / (np / N) else NA_real_)
}

#' Leakage and under-coverage as the cut-off moves (a multiple of the line)
#' @param e The fit's evaluation households (actual, predicted log welfare, w).
#' @noRd
pmt_error_curve <- function(e, log_line, mult = seq(0.5, 2, by = 0.05)) {
  poor <- e$actual <= log_line
  do.call(rbind, lapply(mult, function(m) {
    a <- pmt_accuracy(e$predicted <= log_line + log(m), poor, e$w)
    data.frame(mult = m, inclusion_error = a$inclusion_error, exclusion_error = a$exclusion_error,
               selected = a$selected)
  }))
}

#' Share selected in each decile of measured welfare (the PMT incidence)
#' @param cut Predicted log welfare at or below which a household is selected.
#' @noRd
pmt_decile_coverage <- function(e, cut) {
  br <- unique(weighted_quantile(e$actual, e$w, probs = seq(0, 1, 0.1)))
  dec <- cut(e$actual, br, include.lowest = TRUE, labels = FALSE)
  sel <- e$predicted <= cut
  do.call(rbind, lapply(sort(unique(dec)), function(k) {
    m <- dec == k
    data.frame(decile = k, selected = sum(e$w[m & sel]) / sum(e$w[m]))
  }))
}

#' One row of the PMT model comparison
#' @noRd
pmt_compare_row <- function(f) {
  p <- f$pmt; a <- p$accuracy
  data.frame(model = model_label(f$method), code = f$method, proxies = nrow(f$weights),
             r2_train = p$r2, r2_test = p$r2_test, inclusion_error = a$inclusion_error,
             exclusion_error = a$exclusion_error, accuracy = a$accuracy, cgh = a$cgh, stringsAsFactors = FALSE)
}

#' PMT words for the design's generic ones (page, report, workbook)
#'
#' The design is written for a food-security outcome; with a welfare measure
#' the literature speaks of poor and non-poor households, of leakage and
#' under-coverage, and of the PMT. Names in backticks are left alone.
#' @noRd
pmt_wording <- function(x) {
  if (!length(x)) return(x)
  exact <- c("Scorecard decision \u2193" = "PMT decision \u2193", "Assessment outcome \u2192" = "Measured welfare \u2192",
             "Eligible" = "Eligible (predicted poor)", "Not eligible" = "Not eligible (predicted non-poor)",
             "Scorecard" = "PMT", "Outcome" = "Measured welfare", "Design error matrix" = "PMT targeting matrix",
             "Targeting design report" = "Proxy means test design report",
             "Targeting design record" = "Proxy means test design record")
  subs <- list(
    c("\\bnot in need\\b", "not poor"), c("\\bin need\\b", "poor"),
    c("\\bmost vulnerable\\b", "poorest"), c("\\bNot vulnerable\\b", "Non-poor"), c("\\bnot[ -]vulnerable\\b", "non-poor"),
    c("\\bVulnerability Framework\\b", "Welfare measure"), c("\\bVulnerable\\b", "Poor"), c("\\bvulnerable\\b", "poor"),
    c("\\bScorecard score\\b", "PMT score"), c("\\b[Ss]corecards\\b", "PMTs"), c("\\bScorecard\\b", "PMT"), c("\\bscorecard\\b", "PMT"),
    c("\\b([Ii])nclusion error(s?)\\b(?! \\()", "\\1nclusion error\\2 (leakage)"),
    c("\\b([Ee])xclusion error(s?)\\b(?! \\()", "\\1xclusion error\\2 (under-coverage)"))
  one <- function(t) {
    if (is.na(t) || !nzchar(t)) return(t)
    k <- trimws(t)
    if (k %in% names(exact)) return(sub(k, exact[[k]], t, fixed = TRUE))
    parts <- strsplit(t, "`", fixed = TRUE)[[1]]
    if (endsWith(t, "`")) parts <- c(parts, "")
    for (i in seq(1, length(parts), by = 2)) for (r in subs) parts[i] <- gsub(r[1], r[2], parts[i], perl = TRUE)
    paste(parts, collapse = "`")
  }
  vapply(x, one, character(1), USE.NAMES = FALSE)
}

#' PMT wording when the report or workbook being written is a PMT's
#' (`options(tw.terms = "pmt")`), the text as it is otherwise
#' @noRd
tw_terms <- function(x) if (identical(getOption("tw.terms"), "pmt")) pmt_wording(x) else x

#' The design report's PMT charts (billboarder, work offline)
#'
#' Selection by decile of measured welfare, the two errors as the cut-off
#' moves, predicted against measured welfare, and the compared models'
#' under-coverage.
#' @param f `fit$pmt`; `cut` the adopted cut-off in predicted log welfare;
#'   `curves` the compared models' error curves (named).
#' @noRd
pmt_report_plots <- function(f, cut, curves = NULL, lang = "en") {
  if (is.null(f) || !NROW(f$eval)) return(list())
  tr <- function(x) i18n_lookup(x, lang)
  out <- list()
  dc <- pmt_decile_coverage(f$eval, cut)
  d <- data.frame(decile = paste0("D", dc$decile), selected = round(100 * dc$selected, 1))
  names(d)[2] <- tr("Selected (%)")
  out$pmt_decile <- rp_columns(d, stats::setNames(rp_cols$elig, names(d)[2]), tr("Selected (%)"), stacked = FALSE)

  cu <- pmt_error_curve(f$eval, f$log_line)
  d <- data.frame(cut = round(100 * cu$mult), a = round(100 * cu$inclusion_error, 1), b = round(100 * cu$exclusion_error, 1))
  names(d)[2:3] <- c("Inclusion error (leakage)", "Exclusion error (under-coverage)")
  out$pmt_curve <- rp_base(340) |>
    billboarder::bb_linechart(d, type = "line", show_point = FALSE) |>
    billboarder::bb_x_axis(type = "indexed", tick = list(values = seq(50, 200, 25)),
                           label = rp_axis_label(tr("Cut-off (% of the poverty line)"), rotated = TRUE)) |>
    billboarder::bb_y_axis(min = 0, max = 100, padding = list(top = 0, bottom = 0), label = rp_axis_label(tr("Error (%)"))) |>
    rp_colors(stats::setNames(c("#f7b825", "#c5192d"), names(d)[2:3])) |>
    billboarder::bb_x_grid(lines = list(list(value = round(100 * exp(cut - f$log_line)), text = tr("Cut-off"))))

  e <- f$eval
  if (nrow(e) > 1500) { set.seed(1); e <- e[sort(sample.int(nrow(e), 1500)), , drop = FALSE] }
  ll <- f$log_line
  grp <- ifelse(e$actual <= ll, ifelse(e$predicted <= cut, "Poor, selected", "Poor, not selected (under-coverage)"),
                ifelse(e$predicted <= cut, "Non-poor, selected (leakage)", "Non-poor, not selected"))
  out$pmt_fit <- rp_group_scatter(round(e$actual, 3), round(e$predicted, 3), grp,
                                  tr("Measured log welfare per person"), tr("Predicted log welfare per person"))

  if (length(curves) > 1) {
    d <- data.frame(cut = round(100 * curves[[1]]$mult))
    for (k in names(curves)) d[[k]] <- round(100 * curves[[k]]$exclusion_error, 1)
    out$pmt_compare <- rp_base(340) |>
      billboarder::bb_linechart(d, type = "line", show_point = FALSE) |>
      billboarder::bb_x_axis(type = "indexed", tick = list(values = seq(50, 200, 25)),
                             label = rp_axis_label(tr("Cut-off (% of the poverty line)"), rotated = TRUE)) |>
      billboarder::bb_y_axis(min = 0, max = 100, padding = list(top = 0, bottom = 0),
                             label = rp_axis_label(tr("Exclusion error, under-coverage (%)"))) |>
      rp_colors(stats::setNames(rp_cols$models[seq_along(curves)], names(curves)))
  }
  out
}
