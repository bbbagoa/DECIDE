#' Scorecard modelling options
#'
#' The scorecard itself is always additive -- points added for inclusion
#' criteria, subtracted for exclusion criteria -- because it has to be applied
#' by a field team and challenged by a community. What varies is how the model
#' behind it is fitted, how its coefficients become points, and how honestly
#' its accuracy is measured:
#'
#' * Model: logistic regression on every retained criterion, or backward
#'   stepwise selection (AIC), which drops criteria that add nothing once the
#'   others are known and so yields a shorter card. Either can use survey
#'   sampling weights.
#' * Weighting scheme: the odds ratio (as the APP-FA reference analysis does),
#'   the log-odds coefficient, integer points, or equal weights.
#' * Validation: a stratified hold-out sample the model never sees, so the AUC
#'   and design errors are not flattered by being measured on the data they
#'   were fitted to.
#' * Benchmarks: a random forest and gradient boosting are fitted on the same
#'   criteria for comparison only. They cannot be written down as a scorecard,
#'   but they show how much predictive power the simple card gives up
#'   (Targeting Advisory 3/2025 compares a logistic model and a random forest in
#'   exactly this way).
#'
#' @name models
NULL

#' Model choices offered in the UI
#' @noRd
scorecard_model_choices <- function() {
  # Stepwise selection is not a model of its own: it is an option that
  # applies to every model (see `stepwise` in fit_scorecard_advanced()).
  out <- c("Logistic regression (all retained criteria)" = "logit",
           "Weight of evidence (criterion by criterion)" = "woe")
  # Boosted stumps are still additive (one split per tree), so they give a
  # card like the others -- but only when xgboost is installed.
  if (requireNamespace("xgboost", quietly = TRUE)) {
    out <- c(out, "Boosted stumps (additive gradient boosting)" = "stumps")
  }
  # Machine-learning models: their points are average marginal effects, so
  # the card stays additive whatever the model inside.
  if (requireNamespace("ranger", quietly = TRUE)) out <- c(out, "Random forest (machine learning)" = "rf")
  if (requireNamespace("xgboost", quietly = TRUE)) out <- c(out, "XGBoost (machine learning)" = "xgb")
  if (requireNamespace("e1071", quietly = TRUE)) {
    out <- c(out, "Naive Bayes (machine learning)" = "nb",
             "Support vector machine (machine learning)" = "svm")
  }
  if (requireNamespace("nnet", quietly = TRUE)) out <- c(out, "Neural network (machine learning)" = "nnet")
  if (requireNamespace("rpart", quietly = TRUE)) out <- c(out, "Decision tree (machine learning)" = "tree")
  # Composite indices: a weighted sum of the criteria from dimension reduction,
  # not a prediction model. Base R, always available.
  c(out, "Vulnerability index: principal component analysis (PCA)" = "pca",
    "Vulnerability index: linear discriminant analysis (LDA)" = "lda")
}

#' A vulnerability index from dimension reduction
#'
#' PCA (unsupervised): the first principal component of the criteria's
#' (survey-weighted) correlation matrix, the asset-index method of Filmer &
#' Pritchett (2001). For yes/no criteria it gives the same first dimension as
#' multiple correspondence analysis. The component has no sign of its own; it
#' is turned so a higher index means more vulnerable (positive correlation
#' with the outcome). LDA (supervised): Fisher's discriminant, the weights
#' that best separate vulnerable from other households given how the criteria
#' vary together.
#'
#' With `axes` > 1 the PCA index is the average of the first `axes`
#' component scores, each turned towards vulnerability and weighted by the
#' share of variation it explains (its eigenvalue).
#'
#' Either way the index is linear, sum_k w_k x_k plus a constant, so each
#' criterion keeps one weight and the card stays additive. The weights are
#' scaled so the largest is 10.
#' @param X Model frame from fit_scorecard_advanced() (criteria, .y, .w).
#' @param axes PCA: how many axes the index averages.
#' @return list(coef = named weights, diag = diagnostics).
#' @noRd
index_effects <- function(X, criteria, method = c("pca", "lda"), axes = 1, min_var = NULL) {
  method <- match.arg(method)
  M <- as.matrix(X[criteria]); storage.mode(M) <- "double"
  w <- X$.w / sum(X$.w)
  y <- X$.y
  p <- ncol(M)
  scale10 <- function(v) { m <- max(abs(v)); if (!is.finite(m) || m == 0) v else 10 * v / m }
  wcor <- function(a, b) { ma <- sum(w * a); mb <- sum(w * b)
    sum(w * (a - ma) * (b - mb)) / sqrt(sum(w * (a - ma)^2) * sum(w * (b - mb)^2)) }
  if (method == "pca") {
    cw <- stats::cov.wt(M, wt = w, cor = TRUE)
    R <- cw$cor
    e <- eigen(R, symmetric = TRUE)
    sdv <- sqrt(diag(cw$cov))
    # Either a number of axes, or the fewest axes whose variation together
    # reaches `min_var` (a share, 0-1).
    cum <- cumsum(e$values) / sum(e$values)
    k <- if (!is.null(min_var) && isTRUE(is.finite(min_var)))
      max(1L, min(which(cum >= min_var - 1e-9)[1] %||% p, p))
    else max(1L, min(as.integer(axes %||% 1L), p))
    A <- e$vectors[, seq_len(k), drop = FALSE]
    scores <- sweep(sweep(M, 2, cw$center), 2, sdv, "/") %*% A
    # each axis turned so a higher coordinate means more vulnerable
    sgn <- vapply(seq_len(k), function(j) { r <- wcor(scores[, j], y); if (is.finite(r) && r < 0) -1 else 1 }, numeric(1))
    A <- sweep(A, 2, sgn, "*")
    lam <- e$values[seq_len(k)]
    axis_w <- lam / sum(lam)
    a <- A[, 1]
    coef <- stats::setNames(as.vector(A %*% axis_w) / sdv, criteria)
    # Kaiser-Meyer-Olkin sampling adequacy and Bartlett's test of sphericity:
    # do the criteria share enough variation to make one index of them?
    Ri <- tryCatch(solve(R), error = function(e) NULL)
    kmo <- NA_real_
    if (!is.null(Ri)) {
      P <- -Ri / sqrt(outer(diag(Ri), diag(Ri)))
      off <- upper.tri(R)
      kmo <- sum(R[off]^2) / (sum(R[off]^2) + sum(P[off]^2))
    }
    n <- nrow(M)
    bart <- -(n - 1 - (2 * p + 5) / 6) * log(max(det(R), .Machine$double.xmin))
    diag_out <- list(type = "pca", axes = k, share = sum(lam) / sum(e$values), min_var = min_var, cumulative = cum,
                     axis_share = lam / sum(e$values), axis_weights = axis_w,
                     kaiser = sum(e$values > 1), eigen = e$values, kmo = kmo,
                     axis_loadings = matrix(sweep(A, 2, sqrt(lam), "*"), ncol = k, dimnames = list(criteria, paste("Axis", seq_len(k)))),
                     # for the variable and household maps (first two axes, turned
                     # towards vulnerability like the index)
                     criteria = criteria, center = cw$center, sd = sdv,
                     map_vectors = local({
                       V <- e$vectors[, seq_len(min(2, p)), drop = FALSE]
                       Sm <- sweep(sweep(M, 2, cw$center), 2, sdv, "/") %*% V
                       sg <- vapply(seq_len(ncol(V)), function(j) { r <- wcor(Sm[, j], y); if (is.finite(r) && r < 0) -1 else 1 }, numeric(1))
                       sweep(V, 2, sg, "*")
                     }),
                     bartlett_p = stats::pchisq(bart, p * (p - 1) / 2, lower.tail = FALSE),
                     loadings = stats::setNames(a * sqrt(e$values[1]), criteria))
  } else {
    g1 <- y == 1
    if (sum(g1) < 2 || sum(!g1) < 2) stop("LDA needs at least two households in each outcome group.", call. = FALSE)
    wm <- function(rows) colSums(M[rows, , drop = FALSE] * w[rows]) / sum(w[rows])
    wc <- function(rows) stats::cov.wt(M[rows, , drop = FALSE], wt = w[rows] / sum(w[rows]))$cov
    m1 <- wm(g1); m0 <- wm(!g1)
    S <- (sum(w[g1]) * wc(g1) + sum(w[!g1]) * wc(!g1)) / sum(w)
    S <- S + diag(1e-6, p)                      # ridge: rare or overlapping criteria
    b <- as.vector(solve(S, m1 - m0))
    coef <- stats::setNames(b, criteria)
    diag_out <- list(type = "lda", mahalanobis = as.numeric(t(m1 - m0) %*% b), criteria = criteria)
  }
  list(coef = scale10(coef), diag = diag_out)
}

#' What each model choice does, shown under the picker
#' @noRd
scorecard_model_note <- function(method) {
  switch(method,
    logit = "One logistic model on every retained criterion; each criterion's effect is net of the others.",
    woe = "Each criterion's effect is its own log odds ratio against the outcome (weight of evidence, as in credit scorecards). Never fails on separation or collinearity; effects are not net of the other criteria, so overlapping criteria count twice.",
    stumps = "Gradient boosting restricted to one split per tree. With yes/no criteria that model is exactly additive, so each criterion still gets fixed points, but it can capture effects a logistic fit misses when criteria are unstable together.",
    rf = "Random forest (500 trees). Each criterion's points are its average marginal effect: how much the forest's prediction moves, on the log-odds scale, when a household meets the criterion rather than not. The card is additive; the forest's interactions are averaged out.",
    xgb = "XGBoost (gradient-boosted trees, depth 3). Points are average marginal effects on the log-odds scale, as for the random forest.",
    svm = "Support vector machine (radial kernel, probability output). Points are average marginal effects on the log-odds scale. An SVM optimises a class boundary, not probabilities, so a criterion that never moves a household across the boundary gets close to zero points even when it matters: compare its held-out AUC before adopting it. Trained on at most 3,000 households, which already gives it its full accuracy on yes/no criteria.",
    nb = "Naive Bayes: each criterion's evidence combined as if independent given the outcome. Fast and stable on small samples; overlapping criteria are over-counted. Points are average marginal effects on the log-odds scale.",
    nnet = "Neural network (one hidden layer of 5 units, weight decay). Can capture interactions between criteria; points are average marginal effects on the log-odds scale.",
    "")
}

#' Additive per-criterion effects on the log-odds scale for the non-GLM methods
#'
#' Both return a named numeric vector (one per criterion) that plays the role
#' of the logistic coefficient.
#' @noRd
woe_effects <- function(X, criteria) {
  y <- X$.y; w <- X$.w
  vapply(criteria, function(cl) {
    x <- X[[cl]]
    # 0.5 added to every cell (Haldane) so an empty cell gives a finite effect.
    a <- sum(w[x == 1 & y == 1]) + 0.5; b <- sum(w[x == 1 & y == 0]) + 0.5
    cc <- sum(w[x == 0 & y == 1]) + 0.5; d <- sum(w[x == 0 & y == 0]) + 0.5
    log((a * d) / (b * cc))
  }, numeric(1))
}

#' Average marginal effects of a machine-learning model, as scorecard points
#'
#' For each criterion, every household is scored twice by the fitted model --
#' once with the criterion set to 1, once set to 0, all else unchanged -- and
#' the mean difference in predicted log-odds is the criterion's effect. That
#' turns any classifier into an additive card; how much of its accuracy the
#' card keeps shows in the held-out AUC.
#' @noRd
ml_effects <- function(X, criteria, method, seed = 123, max_rows = 5000, params = list()) {
  m <- as.data.frame(lapply(X[, criteria, drop = FALSE], as.numeric))
  y <- X$.y; w <- X$.w
  set.seed(seed)
  # training sample cap, for large registries; an SVM's training time grows
  # with the square of the rows and 3,000 already gives it its full AUC
  cap <- if (method == "svm") min(max_rows, 3000) else 20000
  if (method == "svm") max_rows <- min(max_rows, 2000)   # effects: a mean, 2,000 households estimate it well
  fit_rows <- if (nrow(m) > cap) sample.int(nrow(m), cap) else seq_len(nrow(m))
  predict_p <- ml_fit_predict(method, m[fit_rows, , drop = FALSE], y[fit_rows], w[fit_rows], params, seed)
  # Marginal effects on (at most) max_rows households keeps big data fast.
  eval_rows <- if (nrow(m) > max_rows) sample.int(nrow(m), max_rows) else seq_len(nrow(m))
  base <- m[eval_rows, , drop = FALSE]
  lo <- function(p) stats::qlogis(pmin(pmax(p, 1e-4), 1 - 1e-4))
  # yes/no criteria repeat: score each distinct answer pattern once, and all
  # the counterfactuals in one call (an SVM pays per call and per row)
  a_all <- do.call(rbind, lapply(criteria, function(cl) { a <- base; a[[cl]] <- 1; a }))
  b_all <- do.call(rbind, lapply(criteria, function(cl) { b <- base; b[[cl]] <- 0; b }))
  both <- rbind(a_all, b_all)
  key <- do.call(paste, c(both, sep = "
"))
  first <- !duplicated(key)
  pr <- lo(predict_p(both[first, , drop = FALSE]))[match(key, key[first])]
  n <- nrow(base); half <- nrow(a_all)
  d <- pr[seq_len(half)] - pr[half + seq_len(half)]
  out <- stats::setNames(vapply(seq_along(criteria), function(j) mean(d[(j - 1) * n + seq_len(n)]), numeric(1)), criteria)
  attr(out, "model") <- attr(predict_p, "model")
  out
}

#' Train one machine-learning model and return its prediction function
#'
#' Shared by the fit and by cross-validation. `params` overrides the
#' defaults (the tuned values); the fitted model rides along as the "model"
#' attribute (the decision tree's rules are read from it).
#' @param m data.frame of 0/1 criteria; y 0/1; w case weights.
#' @noRd
ml_fit_predict <- function(method, m, y, w, params = list(), seed = 123) {
  g <- function(k, def) params[[k]] %||% def
  set.seed(seed)
  pf <- switch(method,
    rf = {
      fit <- ranger::ranger(x = m, y = factor(y, levels = c(0, 1)), probability = TRUE,
                            num.trees = g("num.trees", 500), mtry = min(ncol(m), g("mtry", max(1, floor(sqrt(ncol(m)))))),
                            min.node.size = g("min.node.size", 10), case.weights = w, seed = seed, num.threads = 1,
                            importance = "impurity")
      structure(function(nd) stats::predict(fit, data = nd)$predictions[, "1"], model = fit)
    },
    xgb = , stumps = {
      dm <- xgboost::xgb.DMatrix(as.matrix(m), label = y, weight = w)
      fit <- xgboost::xgb.train(params = list(objective = "binary:logistic", nthread = 1,
                                              max_depth = if (method == "stumps") 1 else g("max_depth", 3),
                                              eta = g("eta", 0.1), subsample = if (method == "stumps") 1 else 0.8),
                                data = dm, nrounds = g("nrounds", if (method == "stumps") 300 else 200), verbose = 0)
      structure(function(nd) stats::predict(fit, xgboost::xgb.DMatrix(as.matrix(nd))), model = fit)
    },
    svm = {
      # No probability = TRUE: libsvm would refit it 5 more times for its own
      # Platt scaling. One logistic fit on the decision values does the same.
      # Matrix interface: no model frame to build on every call.
      fit <- e1071::svm(as.matrix(m), factor(y, levels = c(0, 1)), kernel = "radial", cost = g("cost", 1),
                        gamma = g("gamma", 1 / ncol(m)), tolerance = 0.01, cachesize = 200)
      dv <- function(nd) as.numeric(attr(stats::predict(fit, as.matrix(nd), decision.values = TRUE), "decision.values"))
      cal <- stats::glm.fit(cbind(1, dv(m)), y, family = stats::quasibinomial())$coefficients
      if (anyNA(cal)) cal <- c(0, 1)
      function(nd) stats::plogis(cal[1] + cal[2] * dv(nd))
    },
    nb = {
      as_f <- function(dd) { dd[] <- lapply(dd, function(v) factor(v, levels = c(0, 1))); dd }
      d <- as_f(m); d$.y <- factor(y, levels = c(0, 1))
      fit <- e1071::naiveBayes(.y ~ ., data = d, laplace = g("laplace", 1))
      function(nd) stats::predict(fit, as_f(nd), type = "raw")[, "1"]
    },
    nnet = {
      d <- m; d$.y <- factor(y, levels = c(0, 1))
      fit <- nnet::nnet(.y ~ ., data = d, weights = w, size = g("size", 5), decay = g("decay", 0.01),
                        maxit = 300, trace = FALSE)
      structure(function(nd) as.numeric(stats::predict(fit, nd, type = "raw")), model = fit)
    },
    tree = {
      d <- m; d$.y <- factor(y, levels = c(0, 1))
      fit <- rpart::rpart(.y ~ ., data = d, weights = w, method = "class",
                          control = rpart::rpart.control(cp = g("cp", 0.01), maxdepth = g("maxdepth", 4),
                                                         minbucket = g("minbucket", max(5, round(nrow(m) / 100))), xval = 0))
      structure(function(nd) stats::predict(fit, nd, type = "prob")[, "1"], model = fit)
    },
    stop("Unknown model: ", method, call. = FALSE))
  pf
}

#' The grid tried when a model is tuned by cross-validation (NULL: nothing to tune)
#' @noRd
ml_grid <- function(method, p) {
  switch(method,
    tree = expand.grid(cp = c(0.001, 0.005, 0.01, 0.02), maxdepth = c(3, 4, 6)),
    rf = expand.grid(mtry = unique(pmax(1, round(c(sqrt(p), p / 3, p / 2)))), min.node.size = c(5, 20, 50), num.trees = 200),
    xgb = expand.grid(max_depth = c(2, 3, 4), eta = c(0.05, 0.1, 0.3), nrounds = c(100, 200)),
    stumps = expand.grid(eta = c(0.05, 0.1, 0.3), nrounds = c(100, 300)),
    svm = expand.grid(cost = c(0.5, 1, 4), gamma = c(0.5, 1, 2) / p),
    nnet = expand.grid(size = c(2, 5, 8), decay = c(0.001, 0.01, 0.1)),
    nb = expand.grid(laplace = c(0, 1, 2)),
    NULL)
}
tunable_models <- function() c("tree", "rf", "xgb", "stumps", "svm", "nnet", "nb")

#' Tune a model's hyperparameters by k-fold cross-validation
#'
#' Folds are stratified on the outcome and drawn from the training households
#' only (at most `max_rows` of them); each setting of the grid is fitted on
#' k-1 folds and scored on the one left out, and the setting with the best
#' cross-validated AUC (pooled over the folds) is kept.
#' @return list(best = named list of parameters, table = the grid with its
#'   AUC, folds, n) or NULL when the model has nothing to tune.
#' @noRd
tune_ml <- function(X, criteria, method, folds = 5, seed = 123, max_rows = 5000) {
  grid <- ml_grid(method, length(criteria)); if (is.null(grid)) return(NULL)
  m <- as.data.frame(lapply(X[, criteria, drop = FALSE], as.numeric)); y <- X$.y; w <- X$.w
  set.seed(seed)
  if (method == "svm") max_rows <- min(max_rows, 2000)   # folds x grid fits: keep each one small
  if (nrow(m) > max_rows) { k <- sample.int(nrow(m), max_rows); m <- m[k, , drop = FALSE]; y <- y[k]; w <- w[k] }
  folds <- max(2L, min(as.integer(folds), 10L))
  fold <- integer(length(y))
  for (lv in unique(y)) { i <- which(y == lv); fold[i] <- sample(rep_len(seq_len(folds), length(i))) }
  auc <- vapply(seq_len(nrow(grid)), function(g) {
    pr <- rep(NA_real_, length(y))
    for (f in seq_len(folds)) {
      tr <- fold != f
      pf <- tryCatch(ml_fit_predict(method, m[tr, , drop = FALSE], y[tr], w[tr], as.list(grid[g, , drop = FALSE]), seed),
                     error = function(e) NULL)
      if (!is.null(pf)) pr[!tr] <- tryCatch(pf(m[!tr, , drop = FALSE]), error = function(e) NA_real_)
    }
    ok <- !is.na(pr); if (sum(ok) < 10) return(NA_real_)
    roc_curve(pr[ok], y[ok])$auc
  }, numeric(1))
  tab <- cbind(grid, cv_auc = round(auc, 4))
  best <- which.max(auc)
  if (!length(best)) return(NULL)
  list(best = as.list(grid[best, , drop = FALSE]), table = tab[order(-tab$cv_auc), , drop = FALSE], folds = folds, n = length(y),
       best_auc = auc[best])
}

#' The decision tree's leaves as readable rules
#' @return data.frame(rule, households, share_vulnerable), most vulnerable first
#' @noRd
tree_rules <- function(fit) {
  fr <- fit$frame
  leaves <- as.integer(rownames(fr)[fr$var == "<leaf>"])
  if (!length(leaves)) return(NULL)
  paths <- rpart::path.rpart(fit, nodes = leaves, print.it = FALSE)
  words <- vapply(paths, function(pth) {
    pth <- pth[-1]                                         # "root"
    if (!length(pth)) return("All households")
    pth <- sub("^(.*)>=0\\.5$", "\\1 = yes", pth)
    pth <- sub("^(.*)< 0\\.5$", "\\1 = no", pth)
    paste(pth, collapse = " and ")
  }, character(1))
  lf <- fr[fr$var == "<leaf>", , drop = FALSE]
  prob <- lf$yval2[, ncol(lf$yval2) - 1]                  # probability of the second class (vulnerable)
  out <- data.frame(rule = unname(words), households = lf$n, share_vulnerable = round(prob, 4), stringsAsFactors = FALSE)
  out[order(-out$share_vulnerable), , drop = FALSE]
}

stump_effects <- function(X, criteria, seed = 123, params = list()) {
  m <- as.matrix(X[, criteria, drop = FALSE])
  set.seed(seed)
  dm <- xgboost::xgb.DMatrix(m, label = X$.y, weight = X$.w)
  fit <- xgboost::xgb.train(
    params = list(objective = "binary:logistic", max_depth = 1, eta = params$eta %||% 0.1, nthread = 1),
    data = dm, nrounds = params$nrounds %||% 300, verbose = 0)
  # One split per tree: the model is a sum of per-criterion functions, so the
  # contribution of a criterion depends on that criterion alone. Its effect is
  # the contribution when met minus when not met.
  contrib <- stats::predict(fit, dm, predcontrib = TRUE)
  vapply(criteria, function(cl) {
    x <- m[, cl]
    if (!any(x == 1) || !any(x == 0)) return(0)
    mean(contrib[x == 1, cl]) - mean(contrib[x == 0, cl])
  }, numeric(1))
}

#' Weighting schemes offered in the UI
#' @noRd
scorecard_scheme_choices <- function() {
  c("Odds ratio (APP-FA reference)" = "odds_ratio",
    "Log-odds coefficient" = "coefficient",
    "Integer points (largest = 10)" = "points",
    "Equal weights (count of criteria)" = "equal")
}

#' A one-line explanation of each weighting scheme, shown under the picker
#' @noRd
#' The weighting scheme as people read it; an index (PCA, LDA) has its own
#' weights, whatever scheme was picked.
#' @noRd
#' The criteria of an index as the model saw them: yes/no, missing = no
#' @noRd
#' Variation explained by each PCA axis of these criteria (preview before fitting)
#' @return numeric: each axis's share (0-1), largest first; NULL under 2 criteria.
#' @noRd
pca_variance <- function(df, criteria, weights = NULL) {
  if (length(criteria) < 2) return(NULL)
  M <- index_matrix(df, criteria)
  keep <- apply(M, 2, stats::sd) > 0
  if (sum(keep) < 2) return(NULL)
  w <- if (is.null(weights)) rep(1, nrow(M)) else { w <- as.numeric(weights); w[!is.finite(w) | w < 0] <- 0; w }
  ev <- eigen(stats::cov.wt(M[, keep, drop = FALSE], wt = w / sum(w), cor = TRUE)$cor, symmetric = TRUE, only.values = TRUE)$values
  pmax(ev, 0) / sum(pmax(ev, 0))
}

index_matrix <- function(df, criteria) {
  M <- vapply(criteria, function(cl) { v <- as_binary_criterion(df[[cl]]); v[is.na(v)] <- 0; as.numeric(v) }, numeric(nrow(df)))
  matrix(M, nrow = nrow(df), dimnames = list(NULL, criteria))
}

scheme_label <- function(scheme, method = NULL) {
  if (isTRUE(method %in% c("pca", "lda"))) return("Index weights (largest = 10)")
  names(scorecard_scheme_choices())[scorecard_scheme_choices() == scheme][1]
}

scorecard_scheme_note <- function(scheme) {
  switch(scheme,
    odds_ratio = "Each criterion is worth its odds ratio. This is the APP-FA reference method; note that an exclusion criterion with OR 0.24 subtracts only 0.24 points.",
    coefficient = "Each criterion is worth its log-odds coefficient, so the score is the model's own linear predictor minus the intercept. Inclusion and exclusion criteria weigh symmetrically.",
    points = "Coefficients rescaled so the strongest criterion is worth 10 points and rounded to whole numbers, which is easier to apply on paper.",
    equal = "Every inclusion criterion is worth 1 point and every exclusion criterion subtracts 1. The model only decides which criteria are kept and in which direction.",
    "")
}

#' Split rows into a training and an evaluation sample
#'
#' Stratified by the outcome so both samples keep the same prevalence. A small
#' hold-out on an unbalanced outcome would otherwise risk an evaluation sample
#' with almost no vulnerable households in it.
#'
#' @param y Binary outcome (0/1, NA allowed -- NA rows go nowhere).
#' @param holdout Share of rows held out, 0 for none.
#' @param seed Random seed, so the same split is reproduced for the report.
#' @return A list with integer vectors `train` and `test`.
#' @noRd
split_train_test <- function(y, holdout = 0.2, seed = 123) {
  ok <- which(!is.na(y))
  if (!is.finite(holdout) || holdout <= 0 || length(ok) < 20) {
    return(list(train = ok, test = integer(0)))
  }
  holdout <- min(holdout, 0.5)
  old <- if (exists(".Random.seed", envir = globalenv())) get(".Random.seed", envir = globalenv()) else NULL
  on.exit({
    if (is.null(old)) {
      if (exists(".Random.seed", envir = globalenv())) rm(".Random.seed", envir = globalenv())
    } else {
      assign(".Random.seed", old, envir = globalenv())
    }
  }, add = TRUE)
  set.seed(seed)
  test <- unlist(lapply(split(ok, y[ok]), function(idx) {
    k <- round(length(idx) * holdout)
    if (k == 0) integer(0) else idx[sample.int(length(idx), k)]
  }), use.names = FALSE)
  list(train = setdiff(ok, test), test = sort(test))
}

#' Turn model coefficients into scorecard weights
#'
#' @param coef Named numeric vector of coefficients (intercept excluded).
#' @param scheme One of `names(scorecard_scheme_choices())`'s values.
#' @return Positive weights, one per coefficient. The direction (add or
#'   subtract) is carried separately by the sign of the coefficient.
#' @noRd
scorecard_weights <- function(coef, scheme = "odds_ratio") {
  a <- abs(coef)
  w <- switch(scheme,
    odds_ratio = exp(coef),
    coefficient = a,
    points = {
      top <- max(a, na.rm = TRUE)
      if (!is.finite(top) || top == 0) rep(1, length(a)) else pmax(1, round(10 * a / top))
    },
    equal = rep(1, length(a)),
    stop("Unknown weighting scheme: ", scheme, call. = FALSE)
  )
  round(w, 5)
}

#' Fit the scorecard model under a chosen method and weighting scheme
#'
#' Supersedes the fixed odds-ratio fit: the same checks apply (binary outcome,
#' complete rows, constant criteria dropped), but the method, the rows used
#' and the survey weights are chosen by the caller.
#'
#' @param df Assessment data.
#' @param outcome,criteria,outcome_positive As in `fit_scorecard_model()`.
#' @param method "logit" or "stepwise".
#' @param scheme Weighting scheme (see `scorecard_weights()`).
#' @param rows Row indices to fit on (the training sample); all rows if NULL.
#' @param weights Optional numeric sampling weights, one per row of `df`.
#' @return A list with `weights` (criterion, coefficient, odds_ratio, p_value,
#'   direction, weight), `dropped` (criteria removed by stepwise), `model`,
#'   `n`, `converged`, `method` and `scheme`.
#' @noRd
fit_scorecard_advanced <- function(df, outcome, criteria, outcome_positive = NULL,
                                   method = "logit", scheme = "odds_ratio",
                                   rows = NULL, weights = NULL, stepwise = "none", stepwise_dir = "backward",
                                   pca_axes = 1, pca_min_var = NULL, tune = FALSE, folds = 5) {
  # "stepwise" was once a model; it is now logistic with AIC selection.
  if (identical(method, "stepwise")) { method <- "logit"; if (identical(stepwise, "none")) stepwise <- "aic" }
  y <- as_binary_outcome(df[[outcome]], outcome_positive)
  if (is.null(y)) stop("The outcome must be binary (two levels).", call. = FALSE)
  if (length(criteria) == 0) stop("No criteria to model.", call. = FALSE)

  X <- as.data.frame(lapply(criteria, function(cl) as_binary_criterion(df[[cl]])))
  names(X) <- criteria
  # A missing answer counts as "no", as it does in the score (it scores
  # nothing). Keeping only households that answered every criterion left no
  # row at all when criteria were asked to different subgroups.
  filled <- vapply(criteria, function(cl) sum(is.na(X[[cl]]) & !is.na(y)), integer(1))
  for (cl in criteria) X[[cl]][is.na(X[[cl]])] <- 0L
  X$.y <- y
  X$.w <- if (is.null(weights)) 1 else suppressWarnings(as.numeric(weights))
  if (!is.null(rows)) X <- X[rows, , drop = FALSE]
  if (!any(!is.na(X$.y))) stop("No household has an answer for the outcome.", call. = FALSE)
  if (!is.null(weights) && !any(!is.na(X$.w[!is.na(X$.y)]) & X$.w[!is.na(X$.y)] > 0, na.rm = TRUE))
    stop("The survey weight column is empty (or zero) for the households with an outcome: choose another weight column or none.", call. = FALSE)
  X <- X[stats::complete.cases(X) & X$.w > 0, , drop = FALSE]
  if (nrow(X) == 0) stop("No household has both an outcome and a survey weight.", call. = FALSE)
  if (length(unique(X$.y)) < 2) stop("The training sample has only one outcome level.", call. = FALSE)

  keep <- vapply(criteria, function(cl) length(unique(X[[cl]])) > 1, logical(1))
  criteria <- criteria[keep]
  if (length(criteria) == 0) stop("Every criterion is constant once NAs are removed.", call. = FALSE)

  # Normalise the survey weights to a mean of 1 so the likelihood keeps the
  # scale of the sample size; raw expansion weights would make every criterion
  # look significant.
  X$.w <- X$.w / mean(X$.w)

  # Stepwise selection, for any model: backward elimination on a logistic
  # fit, by AIC (k = 2) or BIC (k = log n, stricter, so a shorter card),
  # decides which criteria go into the chosen model.
  step_dropped <- character(0)
  step_model <- NULL
  if (stepwise %in% c("aic", "bic")) {
    k <- if (identical(stepwise, "bic")) log(nrow(X)) else 2
    full_f <- stats::reformulate(criteria, response = ".y")
    dir <- if (stepwise_dir %in% c("forward", "both")) stepwise_dir else "backward"
    # Backward starts from every criterion and removes; forward starts from
    # none and adds; both starts from none and may also remove one added before.
    start <- suppressWarnings(stats::glm(if (identical(dir, "backward")) full_f else .y ~ 1, data = X,
                                         family = stats::binomial(), weights = .w))
    step_model <- withCallingHandlers(
      stats::step(start, scope = list(lower = ~ 1, upper = full_f), direction = dir, trace = 0, k = k),
      warning = function(w) invokeRestart("muffleWarning"))
    sel <- intersect(criteria, attr(stats::terms(step_model), "term.labels"))
    if (length(sel) == 0) stop("Stepwise selection removed every criterion: none adds information over the others.", call. = FALSE)
    step_dropped <- setdiff(criteria, sel)
    criteria <- sel
  }

  index <- NULL; tuning <- NULL; rules <- NULL; diagram <- NULL
  if (method %in% c("woe", "stumps", "rf", "xgb", "svm", "nb", "nnet", "tree", "pca", "lda")) {
    # hyperparameters: tuned by cross-validation on the training households
    if (isTRUE(tune) && method %in% tunable_models()) tuning <- tune_ml(X, criteria, method, folds = folds)
    params <- tuning$best %||% list()
    coef <- switch(method,
                   woe = woe_effects(X, criteria),
                   stumps = stump_effects(X, criteria, params = params),
                   pca = , lda = { r <- index_effects(X, criteria, method, axes = pca_axes, min_var = pca_min_var); index <- r$diag; r$coef },
                   ml_effects(X, criteria, method, params = params))
    if (method == "tree" && !is.null(attr(coef, "model"))) rules <- tryCatch(tree_rules(attr(coef, "model")), error = function(e) NULL)
    diagram <- model_diagram(method, attr(coef, "model"))
    attr(coef, "model") <- NULL
    # An index's weights are its own coefficients (odds ratios mean nothing here).
    if (method %in% c("pca", "lda")) scheme <- "coefficient"
    kept <- names(coef)[abs(coef) > 1e-6]
    if (length(kept) == 0) stop("The model gave every criterion a zero effect.", call. = FALSE)
    out <- data.frame(criterion = kept, coefficient = unname(coef[kept]),
                      odds_ratio = exp(unname(coef[kept])),
                      std_error = NA_real_, or_low = NA_real_, or_high = NA_real_,
                      p_value = NA_real_, stringsAsFactors = FALSE)
    out$direction <- ifelse(out$coefficient > 0, "inclusion", "exclusion")
    out$weight <- scorecard_weights(out$coefficient, scheme)
    out <- out[order(-abs(out$coefficient)), , drop = FALSE]
    rownames(out) <- NULL
    return(list(weights = round5(out), dropped = c(step_dropped, setdiff(criteria, kept)), model = NULL, filled = filled[filled > 0],
                n = nrow(X), converged = TRUE, method = method, scheme = scheme, stepwise = stepwise, stepwise_dir = stepwise_dir,
                index = index, tuning = tuning, tree_rules = rules, diagram = diagram))
  }

  converged <- TRUE
  fit_once <- function(fml) {
    withCallingHandlers(
      stats::glm(fml, data = X, family = stats::binomial(), weights = .w),
      warning = function(w) {
        msg <- conditionMessage(w)
        # Fractional weights make glm warn about non-integer successes; that is
        # expected and harmless. Separation and non-convergence are not.
        if (!grepl("non-integer", msg, fixed = TRUE)) converged <<- FALSE
        invokeRestart("muffleWarning")
      }
    )
  }

  model <- fit_once(stats::reformulate(criteria, response = ".y"))

  cf <- summary(model)$coefficients
  kept <- setdiff(rownames(cf), "(Intercept)")
  dropped <- c(step_dropped, setdiff(criteria, kept))
  if (length(kept) == 0) {
    stop("Stepwise selection removed every criterion: none adds information over the others.",
         call. = FALSE)
  }

  coef <- cf[kept, 1]
  out <- data.frame(
    criterion = kept,
    coefficient = coef,
    odds_ratio = exp(coef),
    std_error = cf[kept, 2],
    or_low = exp(coef - 1.96 * cf[kept, 2]),
    or_high = exp(coef + 1.96 * cf[kept, 2]),
    p_value = cf[kept, 4],
    stringsAsFactors = FALSE
  )
  out$direction <- ifelse(out$coefficient > 0, "inclusion", "exclusion")
  out$weight <- scorecard_weights(out$coefficient, scheme)
  out <- out[order(-abs(out$coefficient)), , drop = FALSE]
  rownames(out) <- NULL

  list(weights = round5(out), dropped = dropped, model = model, n = nrow(X), filled = filled[filled > 0],
       converged = converged && isTRUE(model$converged),
       method = method, scheme = scheme, stepwise = stepwise, stepwise_dir = stepwise_dir,
       diagram = model_diagram("logit", weights = out))
}

#' Benchmark the scorecard against models that cannot be written as one
#'
#' Logistic probabilities, a random forest and gradient boosting are fitted on
#' the training rows and scored on both samples. The benchmarks need `ranger`
#' and `xgboost`; either one missing is skipped rather than failing the run.
#'
#' @param df,outcome,criteria,outcome_positive As above.
#' @param split Output of `split_train_test()`.
#' @param scorecard_score Optional numeric score from the adopted card, one per
#'   row of `df`, compared on the same samples.
#' @param seed Seed for the tree models.
#' @return A list with `table` (model, criteria, auc_train, auc_test), `roc`
#'   (named list of ROC curves on the evaluation sample) and `importance`
#'   (random-forest importance by criterion, or NULL).
#' @noRd
benchmark_models <- function(df, outcome, criteria, outcome_positive = NULL,
                             split, scorecard_score = NULL, seed = 123) {
  y <- as_binary_outcome(df[[outcome]], outcome_positive)
  X <- as.data.frame(lapply(criteria, function(cl) {
    v <- as_binary_criterion(df[[cl]]); v[is.na(v)] <- 0L; v
  }))
  names(X) <- criteria
  tr <- split$train[!is.na(y[split$train])]
  te <- split$test[!is.na(y[split$test])]
  eval_rows <- if (length(te)) te else tr

  auc_of <- function(score, rows) {
    if (length(rows) == 0) return(NA_real_)
    roc_curve(score[rows], y[rows])$auc
  }

  rows <- list()
  curves <- list()
  add <- function(name, n_feat, score) {
    rows[[length(rows) + 1]] <<- data.frame(
      model = name, criteria = n_feat,
      auc_train = auc_of(score, tr), auc_test = auc_of(score, te),
      stringsAsFactors = FALSE
    )
    curves[[name]] <<- roc_curve(score[eval_rows], y[eval_rows])$curve
  }

  if (!is.null(scorecard_score)) {
    add("Scorecard (as adopted)", NA_integer_, as.numeric(scorecard_score))
  }

  d_tr <- cbind(X[tr, , drop = FALSE], .y = y[tr])
  lg <- tryCatch(suppressWarnings(stats::glm(.y ~ ., data = d_tr, family = stats::binomial())),
                 error = function(e) NULL)
  if (!is.null(lg)) {
    add("Logistic (probabilities)", length(criteria),
        suppressWarnings(as.numeric(stats::predict(lg, newdata = X, type = "response"))))
  }

  importance <- NULL
  if (requireNamespace("ranger", quietly = TRUE)) {
    rf <- tryCatch(
      ranger::ranger(x = X[tr, , drop = FALSE], y = factor(y[tr], levels = c(0, 1)),
                     probability = TRUE, num.trees = 300, importance = "impurity",
                     seed = seed, num.threads = 1),
      error = function(e) NULL)
    if (!is.null(rf)) {
      p <- stats::predict(rf, data = X)$predictions[, "1"]
      add("Random forest (benchmark)", length(criteria), p)
      importance <- sort(rf$variable.importance, decreasing = TRUE)
    }
  }

  if (requireNamespace("xgboost", quietly = TRUE)) {
    xb <- tryCatch({
      dtr <- xgboost::xgb.DMatrix(as.matrix(X[tr, , drop = FALSE]), label = y[tr])
      xgboost::xgb.train(
        params = list(objective = "binary:logistic", max_depth = 3, eta = 0.1,
                      subsample = 0.8, nthread = 1, seed = seed),
        data = dtr, nrounds = 150, verbose = 0)
    }, error = function(e) NULL)
    if (!is.null(xb)) {
      p <- stats::predict(xb, xgboost::xgb.DMatrix(as.matrix(X)))
      add("Gradient boosting (benchmark)", length(criteria), p)
    }
  }

  list(
    table = if (length(rows)) round5(do.call(rbind, rows)) else data.frame(),
    roc = curves,
    importance = importance
  )
}

#' Each criterion's effect under every additive model
#'
#' Fits logistic, stepwise, weight of evidence and boosted stumps on the same
#' rows and returns the log-odds effect per criterion and model (NA where a
#' model dropped the criterion), so an analyst can see whether a criterion's
#' weight is robust to the method or an artefact of one of them.
#'
#' @return A data frame: criterion, model (label), effect, p_value.
#' @noRd
model_effects <- function(df, outcome, criteria, outcome_positive = NULL,
                          rows = NULL, weights = NULL, methods = NULL) {
  ch <- scorecard_model_choices()
  # Only the models asked for: each one is a full fit.
  if (!is.null(methods)) ch <- ch[ch %in% methods]
  # Index weights (PCA, LDA) are not log-odds effects: comparing them here
  # would mislead, so the indices show their weights in their own table only.
  ch <- ch[!ch %in% c("pca", "lda")]
  short <- c(logit = "Logistic", woe = "Weight of evidence",
             stumps = "Boosted stumps", rf = "Random forest", xgb = "XGBoost", svm = "SVM",
             nb = "Naive Bayes", nnet = "Neural network", tree = "Decision tree")
  fits <- list()   # kept for compare_models_auc(), dropped before leaving the worker
  out <- lapply(names(ch), function(full) {
    lab <- short[[ch[[full]]]]
    f <- tryCatch(fit_scorecard_advanced(df, outcome, criteria, outcome_positive,
                                         method = ch[[full]], scheme = "coefficient",
                                         rows = rows, weights = weights),
                  error = function(e) NULL)
    w <- if (is.null(f)) NULL else f$weights
    fits[[lab]] <<- f
    data.frame(criterion = criteria, model = lab,
               effect = if (is.null(w)) NA_real_ else w$coefficient[match(criteria, w$criterion)],
               p_value = if (is.null(w)) NA_real_ else w$p_value[match(criteria, w$criterion)],
               stringsAsFactors = FALSE)
  })
  res <- round5(do.call(rbind, out))
  attr(res, "fits") <- fits
  res
}

#' Model comparison from the models compared per variable
#'
#' Each model's score is the sum of its per-criterion effects (every model
#' here is additive), so its AUC on the training and held-out households
#' says how well it ranks them; the scorecard as built is the first row.
#' Same shape as `benchmark_models()`: list(table, roc, importance).
#' @param fits Named list of `fit_scorecard_advanced()` results (labels as names).
#' @noRd
compare_models_auc <- function(df, outcome, outcome_positive = NULL, split, fits, scorecard_score = NULL) {
  y <- as_binary_outcome(df[[outcome]], outcome_positive)
  tr <- split$train[!is.na(y[split$train])]
  te <- split$test[!is.na(y[split$test])]
  eval_rows <- if (length(te)) te else tr
  auc_of <- function(s, rows) if (length(rows)) roc_curve(s[rows], y[rows])$auc else NA_real_
  rows <- list(); curves <- list()
  add <- function(name, k, s) {
    rows[[length(rows) + 1]] <<- data.frame(model = name, criteria = k, auc_train = auc_of(s, tr),
                                            auc_test = auc_of(s, te), stringsAsFactors = FALSE)
    curves[[name]] <<- roc_curve(s[eval_rows], y[eval_rows])$curve
  }
  if (!is.null(scorecard_score)) add("Scorecard (as adopted)", NA_integer_, as.numeric(scorecard_score))
  for (nm in names(fits)) {
    w <- fits[[nm]]$weights
    if (is.null(w) || !nrow(w)) next
    eff <- if (!is.null(w$coefficient)) w$coefficient else w$weight
    ok <- !is.na(eff) & w$criterion %in% names(df)
    if (!any(ok)) next
    X <- vapply(w$criterion[ok], function(cl) { v <- as_binary_criterion(df[[cl]]); v[is.na(v)] <- 0L; as.numeric(v) },
                numeric(nrow(df)))
    add(nm, sum(ok), as.numeric(matrix(X, nrow = nrow(df)) %*% eff[ok]))
  }
  list(table = if (length(rows)) round5(do.call(rbind, rows)) else data.frame(), roc = curves, importance = NULL)
}

#' What the stepwise option does, shown under the model settings
#' @noRd
stepwise_note <- function(ic, dir = "backward") {
  how <- switch(dir %||% "backward",
    forward = "starting from no criterion, the one that improves the fit most is added, one at a time, while it lowers the %s",
    both = "starting from no criterion, criteria are added one at a time, and one added earlier is removed again when that lowers the %s",
    "starting from every criterion, the one that adds least is removed, one at a time, while that lowers the %s")
  switch(ic %||% "none",
    aic = paste0("Stepwise (", dir %||% "backward", ", AIC): ", sprintf(how, "AIC"), ", on a logistic fit; then the chosen model is fitted on the criteria kept."),
    bic = paste0("Stepwise (", dir %||% "backward", ", BIC): ", sprintf(how, "BIC"), ". BIC penalises each criterion more (log of the sample size), so it keeps fewer: a shorter card."),
    "")
}
