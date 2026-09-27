#' Targeting without an outcome indicator
#'
#' When no food-security outcome is available (a sudden shock, data from a
#' partner or a registry), the design ranks households on the chosen yes/no
#' criteria instead of predicting an outcome:
#'
#' * deprivation counting (Alkire-Foster): each criterion met adds its weight;
#' * PCA or MCA index: the first axes of the criteria, turned towards an
#'   anchor criterion the analyst names as a clear sign of vulnerability;
#' * clusters (latent class analysis, k-means, hierarchical Ward): household
#'   profiles; the analyst picks the profiles to target, and a linear
#'   discriminant turns that choice into additive points.
#'
#' Every method ends in the same fit object as the supervised models (a
#' weights table), so scoring, the threshold, adoption and Beneficiary
#' Selection work unchanged. There is no inclusion or exclusion error to
#' measure: internal consistency (Cronbach's alpha) and the stability of the
#' selection under resampling stand in for it, until a verification sample or
#' a PDM gives an outcome.
#' @name unsupervised_targeting
#' @noRd
NULL

#' The methods offered when there is no outcome
#' @noRd
unsupervised_model_choices <- function() {
  out <- c("Deprivation count (Alkire-Foster)" = "count", "PCA index" = "pca", "MCA index" = "mca",
           "Latent class analysis" = "lca", "k-means clusters" = "kmeans", "Hierarchical clusters (Ward)" = "hclust")
  if (requireNamespace("rpart", quietly = TRUE)) out <- c(out, "Decision tree (rules describing the profiles)" = "tree")
  out
}
# Methods that find household profiles (the tree finds them by k-means, then
# describes the targeted ones)
cluster_methods <- function() c("lca", "kmeans", "hclust", "tree")
cluster_algorithm_label <- function(a) c(lca = "latent class analysis", kmeans = "k-means", hclust = "hierarchical clustering (Ward)",
                                         tree = "k-means, described by a decision tree")[[a %||% "kmeans"]]

#' What orients a ranking, in words
#' @noRd
anchor_text <- function(anchor) if (is.null(anchor) || is.na(anchor) || !nzchar(anchor)) "the number of criteria met" else anchor

#' A model's name, from the supervised or the no-outcome list
#' @noRd
model_label <- function(method) {
  ch <- c(scorecard_model_choices(), unsupervised_model_choices())
  lab <- names(ch)[match(method, ch)]
  ifelse(is.na(lab), as.character(method), lab)
}

#' A short description of each method, shown under the settings
#' @noRd
unsupervised_note <- function(method) {
  switch(method %||% "count",
    count = "Each criterion met adds its points (1 by default; edit them in the table below). The threshold is the number of weighted deprivations a household must have (Alkire-Foster; the global MPI uses a third of the criteria). Tick criteria so that 'yes' means deprived.",
    pca = "The first principal component(s) of the criteria, turned so that the anchor criterion raises the index. The classic asset-index ranking (Filmer & Pritchett 2001).",
    mca = "Multiple correspondence analysis: PCA's counterpart for categorical answers. Rare answers weigh more than in PCA. Turned so that the anchor criterion raises the index.",
    lca = "Latent class analysis: households are grouped into profiles that answer the criteria alike (a mixture of independent yes/no answers, fitted by EM). You choose the profiles to target.",
    kmeans = "k-means: households are grouped into k profiles around their average answers. You choose the profiles to target.",
    hclust = "Hierarchical clustering (Ward): households are merged step by step into k profiles, each as compact as possible. You choose the profiles to target. Above 5,000 households the tree is built on a sample and the others join the nearest profile.",
    tree = "Decision tree: households are grouped into k profiles (k-means), you choose the profiles to target, and a tree describes them in plain rules (which answers lead into the targeted profiles). The points are the tree's average effects, so the card stays additive.",
    "")
}

#' 0/1 matrix of the criteria (a missing answer counts as no) and weights
#' @noRd
unsup_data <- function(df, criteria, weights = NULL) {
  M <- index_matrix(df, criteria)
  w <- if (is.null(weights)) rep(1, nrow(M)) else { w <- suppressWarnings(as.numeric(weights)); w[!is.finite(w) | w < 0] <- 0; w }
  ok <- w > 0
  keep <- apply(M[ok, , drop = FALSE], 2, function(v) length(unique(v)) > 1)
  if (sum(keep) < 1) stop("Every criterion is constant: nothing to rank on.", call. = FALSE)
  list(M = M[, keep, drop = FALSE], w = w, ok = ok, dropped = criteria[!keep])
}

#' Cronbach's alpha of 0/1 criteria (internal consistency)
#' @noRd
cronbach_alpha <- function(M, w = rep(1, nrow(M))) {
  p <- ncol(M); if (p < 2) return(NA_real_)
  w <- w / sum(w)
  v <- function(x) { m <- sum(w * x); sum(w * (x - m)^2) }
  items <- sum(apply(M, 2, v)); total <- v(rowSums(M))
  if (total <= 0) return(NA_real_)
  (p / (p - 1)) * (1 - items / total)
}

#' MCA on 0/1 criteria: additive coefficients of the first axes
#'
#' The indicator table holds both answers of each criterion. A household's
#' principal coordinate on an axis is the average of the standard coordinates
#' of its answers, so its score is additive in the criteria: coefficient =
#' (coordinate of yes - coordinate of no) / number of criteria. Axes are
#' weighted by the inertia they explain, as in the PCA index.
#' @noRd
mca_effects <- function(M, w, anchor, axes = 1, min_var = NULL) {
  p <- ncol(M); n <- nrow(M)
  r <- w / sum(w)
  Z <- cbind(M, 1 - M)
  cm <- colSums(Z * r) / p
  P <- Z * r / p
  Q <- sweep((P - outer(r, cm)) / sqrt(r), 2, sqrt(cm), "/")
  e <- eigen(crossprod(Q), symmetric = TRUE)
  lam <- pmax(e$values[seq_len(p)], 0)
  if (sum(lam) <= 0) stop("The criteria vary too little for an MCA.", call. = FALSE)
  cum <- cumsum(lam) / sum(lam)
  k <- if (!is.null(min_var) && isTRUE(is.finite(min_var))) max(1L, min(which(cum >= min_var - 1e-9)[1] %||% p, p))
       else max(1L, min(as.integer(axes %||% 1L), p))
  G <- sweep(e$vectors[, seq_len(k), drop = FALSE], 1, sqrt(cm), "/")       # standard coordinates
  D <- (G[seq_len(p), , drop = FALSE] - G[p + seq_len(p), , drop = FALSE]) / p  # yes minus no, per axis
  scores <- M %*% D
  sgn <- vapply(seq_len(k), function(j) { rr <- suppressWarnings(stats::cor(scores[, j], anchor)); if (is.finite(rr) && rr < 0) -1 else 1 }, numeric(1))
  D <- sweep(D, 2, sgn, "*")
  aw <- lam[seq_len(k)] / sum(lam[seq_len(k)])
  coef <- stats::setNames(as.vector(D %*% aw), colnames(M))
  list(coef = coef, diag = list(type = "mca", axes = k, eigen = lam, share = sum(lam[seq_len(k)]) / sum(lam),
                                axis_share = lam[seq_len(k)] / sum(lam), axis_weights = aw, cumulative = cum, min_var = min_var,
                                axis_loadings = matrix(D, ncol = k, dimnames = list(colnames(M), paste("Axis", seq_len(k))))))
}

#' Latent class analysis of 0/1 criteria: a mixture of independent Bernoulli
#' answers, fitted by EM from several random starts (the best likelihood kept)
#' @return list(assign, posterior, prior, theta (class x criterion), loglik, bic)
#' @noRd
lca_fit <- function(M, w, k, seed = 123, starts = 5, iter = 300, tol = 1e-6) {
  n <- nrow(M); p <- ncol(M); w <- w / mean(w)
  eps <- 1e-6
  best <- NULL
  set.seed(seed)
  for (s in seq_len(starts)) {
    post <- matrix(stats::runif(n * k), n, k); post <- post / rowSums(post)
    ll_old <- -Inf
    for (it in seq_len(iter)) {
      wp <- post * w
      prior <- colSums(wp) / sum(wp)
      theta <- t(wp) %*% M / colSums(wp)
      theta <- pmin(pmax(theta, eps), 1 - eps)
      lp <- M %*% t(log(theta)) + (1 - M) %*% t(log(1 - theta))
      lp <- sweep(lp, 2, log(prior), "+")
      mx <- apply(lp, 1, max)
      post <- exp(lp - mx); rs <- rowSums(post); post <- post / rs
      ll <- sum(w * (mx + log(rs)))
      if (abs(ll - ll_old) < tol * abs(ll)) break
      ll_old <- ll
    }
    if (is.null(best) || ll > best$loglik) best <- list(post = post, prior = prior, theta = theta, loglik = ll)
  }
  npar <- (k - 1) + k * p
  list(assign = max.col(best$post, ties.method = "first"), posterior = best$post, prior = best$prior,
       theta = best$theta, loglik = best$loglik, bic = -2 * best$loglik + npar * log(n))
}

#' Household profiles by clustering (latent classes, k-means or Ward)
#' @return integer cluster of each row of M
#' @noRd
cluster_assign <- function(M, w, method, k, seed = 123) {
  k <- max(2L, min(as.integer(k), nrow(unique(M))))
  if (identical(method, "tree")) method <- "kmeans"      # the tree describes k-means profiles
  if (identical(method, "lca")) {
    f <- lca_fit(M, w, k, seed)
    return(structure(f$assign, entropy = lca_entropy(f$posterior), bic = f$bic))
  }
  switch(method,
    kmeans = { set.seed(seed); stats::kmeans(M, centers = k, nstart = 10, iter.max = 50)$cluster },
    hclust = {
      set.seed(seed)
      idx <- if (nrow(M) > 5000) sort(sample(nrow(M), 5000)) else seq_len(nrow(M))
      hc <- stats::hclust(stats::dist(M[idx, , drop = FALSE]), method = "ward.D2")
      cl <- stats::cutree(hc, k = k)
      dendro <- tryCatch(dendro_structure(hc, k), error = function(e) NULL)
      if (length(idx) == nrow(M)) return(structure(cl, dendro = dendro))
      cen <- t(vapply(seq_len(k), function(j) colMeans(M[idx[cl == j], , drop = FALSE]), numeric(ncol(M))))
      d <- vapply(seq_len(k), function(j) rowSums(sweep(M, 2, cen[j, ])^2), numeric(nrow(M)))
      structure(max.col(-matrix(d, nrow = nrow(M)), ties.method = "first"), dendro = dendro)
    },
    stop("Unknown clustering method.", call. = FALSE))
}

#' How clearly latent classes are told apart: 1 - the posterior entropy
#' relative to its maximum (1 = every household certainly in one class;
#' above 0.8 is usually read as a clear classification)
#' @noRd
lca_entropy <- function(post) {
  k <- ncol(post); n <- nrow(post)
  if (k < 2 || n < 2) return(NA_real_)
  p <- pmax(post, 1e-12)
  1 - sum(-p * log(p)) / (n * log(k))
}

#' Mean silhouette width of a clustering (on up to `n_max` households)
#'
#' For each household, how much closer it is to its own profile than to the
#' nearest other one (-1 to 1); the mean says how well separated the profiles
#' are (above 0.5 clear, 0.25-0.5 weak but real, below 0.25 hardly any).
#' @noRd
silhouette_mean <- function(M, cl, n_max = 2000, seed = 1) {
  set.seed(seed)
  idx <- if (nrow(M) > n_max) sort(sample(nrow(M), n_max)) else seq_len(nrow(M))
  cl <- cl[idx]; if (length(unique(cl)) < 2) return(NA_real_)
  D <- as.matrix(stats::dist(M[idx, , drop = FALSE]))
  ks <- sort(unique(cl))
  sums <- vapply(ks, function(c) rowSums(D[, cl == c, drop = FALSE]), numeric(length(cl)))
  sums <- matrix(sums, nrow = length(cl))
  n_c <- vapply(ks, function(c) sum(cl == c), numeric(1))
  own <- match(cl, ks)
  a <- sums[cbind(seq_along(cl), own)] / pmax(n_c[own] - 1, 1)
  other <- sweep(sums, 2, n_c, "/"); other[cbind(seq_along(cl), own)] <- Inf
  b <- apply(other, 1, min)
  sw <- ifelse(n_c[own] > 1, (b - a) / pmax(a, b), 0)
  mean(sw[is.finite(sw)])
}

#' Profile quality for 2 to 8 profiles, to choose their number on evidence
#' @return data.frame(k, silhouette, entropy (LCA), bic (LCA), smallest share)
#' @noRd
profile_quality <- function(df, criteria, method, ks = 2:8, weights = NULL, seed = 123) {
  u <- unsup_data(df, criteria, weights)
  M <- u$M[u$ok, , drop = FALSE]; w <- u$w[u$ok]
  do.call(rbind, lapply(ks, function(k) {
    cl <- tryCatch(cluster_assign(M, w, method, k, seed), error = function(e) NULL)
    if (is.null(cl)) return(NULL)
    data.frame(k = k, silhouette = silhouette_mean(M, cl, seed = seed),
               entropy = attr(cl, "entropy") %||% NA_real_, bic = attr(cl, "bic") %||% NA_real_,
               smallest = min(tabulate(cl, max(cl))) / length(cl))
  }))
}

#' What the selection concentrates
#'
#' A household's deprivations are the criteria it meets in the vulnerable
#' direction (an inclusion criterion met, an exclusion criterion not met).
#' @return list(ratio = mean deprivations of the selected / of the others,
#'   concentration = share of all deprivations held by the selected, share
#'   selected, mean_sel, mean_not)
#' @noRd
selection_insights <- function(df, weights, eligible) {
  crit <- intersect(weights$criterion, names(df))
  if (!length(crit) || !any(eligible, na.rm = TRUE)) return(NULL)
  M <- index_matrix(df, crit)
  inc <- weights$direction[match(crit, weights$criterion)] != "exclusion"
  Dm <- sweep(M, 2, inc, function(x, i) ifelse(i, x, 1 - x))
  d <- rowSums(Dm)
  sel <- eligible %in% TRUE
  list(ratio = mean(d[sel]) / max(mean(d[!sel]), 1e-9), concentration = sum(d[sel]) / max(sum(d), 1e-9),
       share = mean(sel), mean_sel = mean(d[sel]), mean_not = mean(d[!sel]), n_criteria = length(crit))
}

#' Points that reproduce the chosen profiles: a linear discriminant between
#' households in the targeted profiles and the others (weights up to 10)
#' @noRd
profile_points <- function(M, w, in_target) {
  if (!any(in_target) || all(in_target)) stop("Choose some profiles to target, not none or all.", call. = FALSE)
  X <- as.data.frame(M); X$.y <- as.integer(in_target); X$.w <- w
  index_effects(X, colnames(M), "lda")$coef
}

#' Fit a ranking without an outcome
#'
#' @param method One of `unsupervised_model_choices()`.
#' @param anchor Criterion named as a clear sign of vulnerability: it orients
#'   PCA / MCA and ranks the profiles (the first criterion when missing).
#' @param k Number of profiles for the cluster methods.
#' @param target Profiles to target (cluster methods); by default the one
#'   ranked most vulnerable.
#' @return The same shape as `fit_scorecard_advanced()`, with `index` holding
#'   the method's diagnostics (and, for clusters, the profiles).
#' @noRd
fit_unsupervised <- function(df, criteria, method = "count", anchor = NULL, weights = NULL, k = 3,
                             pca_axes = 1, pca_min_var = NULL, target = NULL, seed = 123) {
  if (!length(criteria)) stop("No criteria to rank on.", call. = FALSE)
  u <- unsup_data(df, criteria, weights)
  M <- u$M[u$ok, , drop = FALSE]; w <- u$w[u$ok]
  crit <- colnames(M)
  # No anchor: the direction comes from the criteria themselves, more
  # criteria met meaning more vulnerable (criteria ticked so that yes = deprived).
  anchor <- if (isTRUE(anchor %in% crit)) anchor else NA_character_
  a <- if (is.na(anchor)) rowSums(M) else M[, anchor]
  alpha <- cronbach_alpha(M, w)
  index <- NULL
  coef <- switch(method,
    count = { index <- list(type = "count", alpha = alpha); stats::setNames(rep(1, length(crit)), crit) },
    pca = {
      if (length(crit) < 2) stop("A PCA index needs at least two criteria.", call. = FALSE)
      X <- as.data.frame(M); X$.y <- a; X$.w <- w
      r <- index_effects(X, crit, "pca", axes = pca_axes, min_var = pca_min_var)
      index <- r$diag; r$coef },
    mca = {
      if (length(crit) < 2) stop("An MCA index needs at least two criteria.", call. = FALSE)
      r <- mca_effects(M, w, a, axes = pca_axes, min_var = pca_min_var)
      index <- r$diag; r$coef },
    lca = , kmeans = , hclust = , tree = {
      cl <- cluster_assign(M, w, method, k, seed)
      dendro <- attr(cl, "dendro"); attr(cl, "dendro") <- NULL
      k <- max(cl)
      prof <- vapply(seq_len(k), function(j) colSums(M[cl == j, , drop = FALSE] * w[cl == j]) / sum(w[cl == j]), numeric(length(crit)))
      prof <- matrix(prof, nrow = length(crit), dimnames = list(crit, paste("Profile", seq_len(k))))
      size <- vapply(seq_len(k), function(j) sum(w[cl == j]) / sum(w), numeric(1))
      # profiles ranked by the anchor-oriented first component: most vulnerable first
      pc <- tryCatch({ X <- as.data.frame(M); X$.y <- a; X$.w <- w
        rr <- index_effects(X, crit, "pca")$coef; as.vector(M %*% rr[crit]) }, error = function(e) a)
      level <- vapply(seq_len(k), function(j) stats::weighted.mean(pc[cl == j], w[cl == j]), numeric(1))
      rank <- order(-level)
      tg <- if (length(target)) intersect(as.integer(target), seq_len(k)) else rank[1]
      if (!length(tg)) tg <- rank[1]
      assign <- rep(NA_integer_, nrow(df)); assign[u$ok] <- cl
      index <- list(type = "cluster", algorithm = method, k = k, profiles = prof, size = size, level = level,
                    rank = rank, target = tg, assign = assign, alpha = alpha,
                    silhouette = silhouette_mean(M, cl, seed = seed), entropy = attr(cl, "entropy"), bic = attr(cl, "bic"))
      if (!is.null(dendro)) { dendro$target <- tg; index$diagram <- list(kind = "dendrogram", data = dendro) }
      if (method == "tree") {
        # a tree that describes the targeted profiles: its rules, and points
        # from its average effects
        if (!any(cl %in% tg) || all(cl %in% tg)) stop("Choose some profiles to target, not none or all.", call. = FALSE)
        X <- as.data.frame(M); X$.y <- as.integer(cl %in% tg); X$.w <- w
        eff <- ml_effects(X, crit, "tree", seed = seed)
        index$rules <- tryCatch(tree_rules(attr(eff, "model")), error = function(e) NULL)
        index$diagram <- model_diagram("tree", attr(eff, "model"))
        attr(eff, "model") <- NULL
        eff
      } else profile_points(M, w, cl %in% tg) })
  coef <- coef[abs(coef) > 1e-9]
  if (!length(coef)) stop("The method gave every criterion a zero weight.", call. = FALSE)
  if (method != "count") coef <- 10 * coef / max(abs(coef))
  # How well the points reproduce the targeted profiles (AUC of the floored
  # score against membership): shown to the analyst, since a profile is not
  # always a straight cut through the criteria.
  if (identical(index$type, "cluster")) {
    sc <- as.vector(M[, names(coef), drop = FALSE] %*% coef)   # the ranking's order (no floor)
    index$fidelity <- roc_curve(sc, as.integer(index$assign[u$ok] %in% index$target))$auc
  }
  out <- data.frame(criterion = names(coef), coefficient = unname(coef), odds_ratio = NA_real_,
                    std_error = NA_real_, or_low = NA_real_, or_high = NA_real_, p_value = NA_real_,
                    stringsAsFactors = FALSE)
  out$direction <- ifelse(out$coefficient > 0, "inclusion", "exclusion")
  out$weight <- abs(out$coefficient)
  out <- out[order(-abs(out$coefficient)), , drop = FALSE]
  rownames(out) <- NULL
  if (is.null(index$alpha)) index$alpha <- alpha
  index$anchor <- anchor
  index$criteria <- crit
  list(weights = round5(out), dropped = u$dropped, model = NULL, n = nrow(M), filled = integer(0), converged = TRUE,
       method = method, scheme = "coefficient", stepwise = "none", stepwise_dir = "backward", index = index,
       unsupervised = TRUE, tree_rules = index$rules, diagram = index$diagram)
}

#' A starting threshold without an outcome
#'
#' Counting: a third of the total weight (the global MPI's cut-off). Profiles:
#' the score that selects as many households as the targeted profiles hold.
#' Indices: the score selecting the `share` of households with the highest
#' index.
#' @noRd
unsupervised_start_threshold <- function(fit, score, share = 0.3) {
  s <- sort(score[!is.na(score)], decreasing = TRUE)
  if (!length(s)) return(0)
  at_share <- function(q) { k <- floor(length(s) * q); if (k >= length(s)) 0 else s[k + 1] }
  if (identical(fit$method, "count")) return(max(0, sum(fit$weights$weight) / 3 - 1e-9))
  if (identical(fit$index$type, "cluster")) {
    # the cut that best reproduces the targeted profiles (ties make a cut at
    # their share land far from it)
    b <- balanced_threshold(score, fit$index$assign %in% fit$index$target)
    return(if (is.na(b$threshold)) at_share(sum(fit$index$size[fit$index$target])) else b$threshold)
  }
  at_share(share)
}

#' Stability of the selection under resampling
#'
#' The design is refitted on `B` bootstrap samples of the households, each
#' refit scores everyone, and the same share of households is selected. The
#' agreement of each refit's selection with the design's own (Jaccard index)
#' says how much the targeting depends on who happened to be surveyed.
#' @return list(jaccard = median, low / high = 10th / 90th percentiles, draws)
#' @noRd
selection_stability <- function(df, criteria, method, share, anchor = NULL, weights = NULL, k = 3,
                                pca_axes = 1, pca_min_var = NULL, target_n = NULL, B = 20, seed = 123) {
  fit0 <- fit_unsupervised(df, criteria, method, anchor, weights, k, pca_axes, pca_min_var, seed = seed)
  sc0 <- apply_scorecard(df, build_scorecard(fit0$weights, kind = "ranking"))$score
  top <- function(s) { r <- rank(-s, ties.method = "first"); r <= max(1, round(share * length(s))) }
  base <- top(sc0)
  set.seed(seed)
  j <- vapply(seq_len(B), function(b) {
    idx <- sample(nrow(df), replace = TRUE)
    f <- tryCatch(fit_unsupervised(df[idx, , drop = FALSE], criteria, method, anchor,
                                   if (is.null(weights)) NULL else weights[idx], k, pca_axes, pca_min_var, seed = seed + b),
                  error = function(e) NULL)
    if (is.null(f)) return(c(NA_real_, NA_real_))   # a refit that failed (e.g. a criterion constant in the resample) is left out
    sc <- apply_scorecard(df, build_scorecard(f$weights, kind = "ranking"))$score
    sel <- top(sc)
    rho <- suppressWarnings(stats::cor(sc, sc0, method = "spearman"))
    c(sum(sel & base) / max(1, sum(sel | base)), rho)
  }, numeric(2))
  rho <- j[2, ]; j <- j[1, ]
  ok <- is.finite(j)
  if (!any(ok)) return(list(jaccard = NA_real_, low = NA_real_, high = NA_real_, draws = 0L, spearman = NA_real_))
  list(jaccard = stats::median(j[ok]), low = unname(stats::quantile(j[ok], .1)), high = unname(stats::quantile(j[ok], .9)),
       draws = sum(ok), spearman = stats::median(rho[is.finite(rho)]))
}

#' Stability in words
#' @noRd
stability_word <- function(j) {
  if (!is.finite(j)) return("not computable")
  if (j >= .85) "stable" else if (j >= .7) "fairly stable" else if (j >= .5) "unstable" else "very unstable"
}

#' Each household's deprivations: the ranking's criteria it meets in the
#' vulnerable direction (an inclusion criterion met, an exclusion one not met)
#' @noRd
ranking_deprivations <- function(df, scorecard) {
  cols <- vapply(scorecard$items, function(it) {
    cand <- c(it$column, it$criterion); cand <- cand[!is.na(cand) & nzchar(cand) & cand %in% names(df)]
    if (length(cand)) cand[1] else NA_character_
  }, character(1))
  ok <- !is.na(cols)
  if (!any(ok)) return(rep(NA_real_, nrow(df)))
  inc <- vapply(scorecard$items[ok], function(it) !identical(it$direction, "exclusion"), logical(1))
  M <- index_matrix(df, cols[ok])
  rowSums(sweep(M, 2, inc, function(x, i) ifelse(i, x, 1 - x)))
}

#' The ranking profile nearest to each household (cluster methods)
#'
#' Profiles are the share of households meeting each criterion; a household
#' joins the profile closest to its own answers (squared distance on the
#' criteria found in these data).
#' @return integer profile number, or NULL when the ranking has no profiles
#' @noRd
ranking_profile_assign <- function(df, scorecard) {
  pr <- scorecard$ranking$profiles
  if (is.null(pr)) return(NULL)
  col_of <- stats::setNames(vapply(scorecard$items, function(it) it$column %||% NA_character_, character(1)),
                            vapply(scorecard$items, function(it) it$criterion, character(1)))
  crit <- rownames(pr)
  cols <- vapply(crit, function(cr) {
    cand <- c(col_of[[cr]] %||% NA_character_, cr); cand <- cand[!is.na(cand) & cand %in% names(df)]
    if (length(cand)) cand[1] else NA_character_
  }, character(1))
  ok <- !is.na(cols)
  if (!any(ok)) return(NULL)
  M <- index_matrix(df, cols[ok])
  P <- pr[ok, , drop = FALSE]
  d <- vapply(seq_len(ncol(P)), function(j) rowSums(sweep(M, 2, P[, j])^2), numeric(nrow(M)))
  max.col(-matrix(d, nrow = nrow(M)), ties.method = "first")
}
