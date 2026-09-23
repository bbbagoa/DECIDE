#
# Targeting analytics helpers
#
# Pure, Shiny-free functions for targeting-accuracy, coverage, quota allocation
# and weighted distribution analysis. Kept here (rather than in module files)
# so they are easy to unit-test and reuse across the Overview, Ben. Selection
# and Data Quality modules.
#
# Weighted variants honor a row-weight vector (as returned by get_weights());
# pass rep(1, n) -- or NULL -- to get the unweighted behaviour.
#


# ---------------------------------------------------------------------------
# Weighted quantiles and distribution analysis
# ---------------------------------------------------------------------------

#' Weighted quantile of a numeric vector
#'
#' Step-function (type 1) weighted quantile, matching the definition used by
#' survey packages: sort by value, cumulate weights, take the first value whose
#' cumulative weight crosses `probs * total_weight`.
#'
#' @param x Numeric vector.
#' @param w Numeric weights of the same length as `x`. May contain zeros; NAs
#'   are dropped together with their `x` value.
#' @param probs Numeric vector of probabilities in [0, 1].
#' @return Numeric vector of quantiles, length `length(probs)`.
#' @noRd
weighted_quantile <- function(x, w, probs = c(0.25, 0.5, 0.75)) {
  if (is.null(w)) w <- rep(1, length(x))
  x <- as.numeric(x)
  w <- rep_len(as.numeric(w), length(x))
  ok <- !is.na(x) & !is.na(w) & w > 0
  x <- x[ok]; w <- w[ok]
  if (length(x) == 0L) return(rep(NA_real_, length(probs)))

  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  cw <- cumsum(w)
  total <- cw[length(cw)]
  vapply(probs, function(p) {
    if (p <= 0) return(x[1])
    if (p >= 1) return(x[length(x)])
    idx <- which.max(cw >= p * total)
    x[idx]
  }, numeric(1))
}

#' Weighted mean (NA-safe)
#'
#' @param x Numeric vector.
#' @param w Weights; NULL => unweighted.
#' @return Numeric scalar (NA if no valid observations).
#' @noRd
wmean <- function(x, w = NULL) {
  if (is.null(w)) w <- rep(1, length(x))
  x <- as.numeric(x); w <- as.numeric(w)
  ok <- !is.na(x) & !is.na(w) & w > 0
  if (!any(ok)) return(NA_real_)
  sum(x[ok] * w[ok]) / sum(w[ok])
}

#' Lorenz coordinates for a (higher = better) score
#'
#' Sorts ascending by score and returns the cumulative population share and
#' cumulative score share, plus the Gini coefficient. Used for the equity /
#' concentration analysis of vulnerability scores.
#'
#' @param x Numeric score vector (higher = more of the measured attribute).
#' @param w Row weights; NULL => unweighted.
#' @return A list with `pop_share`, `score_share` (cumulative shares including
#'   the (0,0) origin so it plots cleanly), and `gini` in [0, 1]. `NA` if fewer
#'   than 2 valid observations or total weight is zero.
#' @noRd
weighted_lorenz <- function(x, w = NULL) {
  if (is.null(w)) w <- rep(1, length(x))
  x <- as.numeric(x); w <- rep_len(as.numeric(w), length(x))
  ok <- !is.na(x) & !is.na(w) & w > 0
  x <- x[ok]; w <- w[ok]
  n <- length(x)
  if (n < 2L || sum(w) == 0) return(list(pop_share = NA_real_, score_share = NA_real_, gini = NA_real_))

  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  cw <- cumsum(w); cscore <- cumsum(x * w)
  total_w <- cw[n]; total_s <- cscore[n]
  if (total_s == 0) return(list(pop_share = c(0, cw / total_w), score_share = rep(0, n + 1), gini = 0))

  pop_share <- c(0, cw / total_w)
  score_share <- c(0, cscore / total_s)

  # Gini from the Lorenz curve: 1 - 2 * area_under_curve (trapezoid)
  area <- sum((pop_share[-1] - pop_share[-length(pop_share)]) *
                (score_share[-1] + score_share[-length(score_share)]) / 2)
  gini <- 1 - 2 * area
  list(pop_share = pop_share, score_share = score_share, gini = gini)
}

#' Weighted decile breaks of a score
#'
#' @param x Numeric vector.
#' @param w Row weights; NULL => unweighted.
#' @return Named numeric vector of decile cut points (10th .. 90th percentile).
#' @noRd
weighted_deciles <- function(x, w = NULL) {
  weighted_quantile(x, w, probs = seq(0.1, 0.9, by = 0.1))
}

#' Weighted boxplot summary across the levels of a grouping column
#'
#' Computes weighted q1/median/q3 and Tukey whiskers (1.5*IQR) per group, so a
#' single plotly "box" trace can be drawn in summary mode (no raw points).
#' Levels with fewer than 2 valid observations are dropped.
#'
#' @param data Data frame.
#' @param group_col Column name to group by.
#' @param val_col Numeric column name to summarise.
#' @param w Row weights aligned with `data`; NULL => unweighted.
#' @return Data frame: `group, min, q1, median, q3, max`.
#' @noRd
weighted_boxplot_summary <- function(data, group_col, val_col, w = NULL) {
  if (is.null(w)) w <- rep(1, nrow(data))
  g <- as.character(data[[group_col]])
  v <- as.numeric(data[[val_col]])
  rows <- lapply(sort(unique(g)), function(lvl) {
    idx <- g == lvl
    x <- v[idx]; ww <- w[idx]
    ok <- !is.na(x) & !is.na(ww) & ww > 0
    x <- x[ok]; ww <- ww[ok]
    if (length(x) < 2) return(NULL)
    qs <- weighted_quantile(x, ww, c(0.25, 0.5, 0.75))
    q1 <- qs[1]; med <- qs[2]; q3 <- qs[3]
    iqr <- q3 - q1
    if (iqr == 0) {
      lo <- min(x); hi <- max(x)
    } else {
      lo <- min(x[x >= q1 - 1.5 * iqr])
      hi <- max(x[x <= q3 + 1.5 * iqr])
    }
    data.frame(group = lvl, min = lo, q1 = q1, median = med, q3 = q3, max = hi,
               stringsAsFactors = FALSE)
  })
  do.call(rbind, Filter(Negate(is.null), rows))
}


# ---------------------------------------------------------------------------
# Targeting accuracy
# ---------------------------------------------------------------------------

#' Normalise an eligibility column to a TRUE/FALSE/NA flag
#'
#' Treats common affirmative strings ("eligible", "yes", "1", "true", "oui")
#' as eligible and negative strings ("ineligible", "no", "0", "false", "non")
#' as ineligible. Anything else (including >2 distinct non-trivial levels) is
#' treated as NA, which disables eligibility-based metrics gracefully.
#'
#' @param x Atomic vector (the mapped eligibility column).
#' @return Logical vector (NA where the value is ambiguous).
#' @noRd
eligibility_flag <- function(x) {
  if (is.logical(x)) return(x)
  tx <- tolower(trimws(as.character(x)))
  pos <- c("eligible", "elig", "yes", "y", "1", "true", "t", "oui", "o", "selected", "included")
  neg <- c("ineligible", "not eligible", "inelig", "no", "n", "0", "false", "f", "non", "excluded", "rejected")
  out <- rep(NA, length(tx))
  out[tx %in% pos] <- TRUE
  out[tx %in% neg] <- FALSE
  out
}

#' Compute targeting accuracy metrics for a selection against ground truth
#'
#' Compares a *selected* set of households against a binary eligibility ground
#' truth and returns coverage / selection / error rates plus precision & recall.
#' All counts are weighted (weights default to 1).
#'
#' Definitions (weighted):
#'   - coverage_rate   = eligible & selected / eligible
#'   - selection_ratio = selected / eligible
#'   - inclusion_error = selected but ineligible / selected
#'   - exclusion_error = eligible but not selected / eligible
#'   - precision       = selected & eligible / selected      (= 1 - inclusion_error)
#'   - recall          = selected & eligible / eligible      (= coverage_rate)
#'
#' @param selected Logical: is each household in the proposed selection?
#' @param eligible Logical: is each household truly eligible (ground truth)?
#' @param w Row weights; NULL => unweighted.
#' @return List of named numerics; elements are NA when undefined
#'   (e.g. no eligible households). NULL if inputs are incompatible.
#' @noRd
targeting_metrics <- function(selected, eligible, w = NULL) {
  if (is.null(selected) || is.null(eligible)) return(NULL)
  n <- length(eligible)
  if (length(selected) != n) return(NULL)
  if (is.null(w)) w <- rep(1, n)

  w <- as.numeric(w)
  # Restrict to rows where eligibility ground truth is known
  known <- !is.na(eligible) & !is.na(w) & w > 0
  if (!any(known)) return(NULL)

  sel <- as.logical(selected)
  if (is.null(sel)) sel <- rep(FALSE, n) else sel[is.na(sel)] <- FALSE
  elig <- as.logical(eligible)

  w_sel <- w * sel
  w_elig <- w * elig

  W_elig <- sum(w_elig[known])
  W_sel  <- sum((w * sel)[known])
  W_sel_elig <- sum((w * sel * elig)[known & sel])
  W_sel_notelig <- sum((w * sel * !elig)[!is.na(eligible) & !is.na(w) & w > 0 & sel])
  W_elig_notsel <- sum((w * elig * !sel)[known])

  safe_div <- function(a, b) if (is.null(a) || is.na(b) || b == 0) NA_real_ else a / b

  list(
    coverage_rate    = safe_div(W_sel_elig, W_elig),
    selection_ratio  = safe_div(W_sel, W_elig),
    inclusion_error  = safe_div(W_sel_notelig, W_sel),
    exclusion_error  = safe_div(W_elig_notsel, W_elig),
    precision        = safe_div(W_sel_elig, W_sel),
    recall           = safe_div(W_sel_elig, W_elig),
    n_eligible       = W_elig,
    n_selected       = W_sel,
    n_selected_eligible = W_sel_elig
  )
}

#' Weighted coverage rate of a selection, per administrative unit
#'
#' @param df Data frame containing all households.
#' @param selected Logical vector aligned with `df` rows: is each row selected?
#' @param eligible Logical vector aligned with `df` rows: ground-truth eligibility.
#' @param unit_col Column name in `df` to group by.
#' @param w Row weights; NULL => unweighted.
#' @return Data frame: `unit, eligible, selected, coverage` (coverage in [0,1],
#'   NA where there are no eligible households).
#' @noRd
coverage_by_unit <- function(df, selected, eligible, unit_col, w = NULL) {
  if (is.null(df) || is.null(unit_col) || !unit_col %in% names(df)) {
    return(data.frame(unit = character(), eligible = numeric(),
                      selected = numeric(), coverage = numeric()))
  }
  n <- nrow(df)
  if (is.null(w)) w <- rep(1, n)
  w <- as.numeric(w)
  sel <- as.logical(selected); sel[is.na(sel)] <- FALSE
  elig <- as.logical(eligible)
  unit <- as.character(df[[unit_col]])

  agg <- tapply(seq_len(n), unit, function(idx) {
    elig_idx <- idx[which(elig[idx])]
    elig <- sum(w[elig_idx], na.rm = TRUE)
    # Rows that are BOTH selected and eligible. `&` between an index vector and
    # a logical mask silently coerces every nonzero index to TRUE and recycles,
    # so this must be a set intersection, not an element-wise and.
    chosen <- sum(w[intersect(idx[sel[idx]], elig_idx)], na.rm = TRUE)
    c(elig = elig, selected = chosen)
  }, simplify = FALSE)

  out <- do.call(rbind, lapply(names(agg), function(nm) {
    a <- agg[[nm]]
    data.frame(
      unit = nm,
      eligible = unname(a["elig"]),
      selected = unname(a["selected"]),
      coverage = if (a["elig"] > 0) a["selected"] / a["elig"] else NA_real_,
      stringsAsFactors = FALSE
    )
  }))
  out[order(-out$eligible), , drop = FALSE]
}


# ---------------------------------------------------------------------------
# Weighted cross-tabulation and correlation
# ---------------------------------------------------------------------------

#' Weighted two-way frequency table with row/column percentages
#'
#' @param df Data frame.
#' @param row_col,col_col Column names in `df`.
#' @param w Row weights; NULL => unweighted.
#' @return List: `counts` (long data.frame: row, col, n),
#'   `row_pct`, `col_pct`, `chi_sq` (htest or NA), `n_valid`.
#' @noRd
weighted_crosstab <- function(df, row_col, col_col, w = NULL) {
  empty <- list(counts = data.frame(), row_pct = data.frame(),
                col_pct = data.frame(), chi_sq = NA, n_valid = 0)
  if (is.null(df) || !row_col %in% names(df) || !col_col %in% names(df)) return(empty)
  n <- nrow(df)
  if (is.null(w)) w <- rep(1, n)
  w <- as.numeric(w)

  r <- as.character(df[[row_col]])
  c <- as.character(df[[col_col]])
  ok <- !is.na(r) & r != "" & !is.na(c) & c != "" & !is.na(w)
  r <- r[ok]; c <- c[ok]; w <- w[ok]
  if (length(r) == 0L) return(empty)

  counts <- as.data.frame(
    tapply(w, list(row = r, col = c), sum, na.rm = TRUE),
    responseName = "n"
  )
  # tapply drops dimnames -> rebuild from xtabs for robustness
  xt <- stats::xtabs(w ~ r + c)
  counts <- as.data.frame(xt, responseName = "n")
  names(counts)[1:2] <- c("row", "col")

  row_tot <- tapply(counts$n, counts$row, sum)
  col_tot <- tapply(counts$n, counts$col, sum)
  grand <- sum(counts$n)

  counts$row_pct <- counts$n / row_tot[as.character(counts$row)]
  counts$col_pct <- counts$n / col_tot[as.character(counts$col)]

  chi <- tryCatch(
    stats::chisq.test(xt, correct = FALSE),
    error = function(e) NA
  )
  list(counts = counts, chi_sq = chi, n_valid = length(r), grand_total = grand)
}

#' Weighted Pearson correlation between two numeric columns
#'
#' Uses the weighted covariance / variance formula. NA pairs are dropped.
#'
#' @param x,y Numeric vectors.
#' @param w Weights; NULL => unweighted (stats::cor).
#' @return Numeric scalar in [-1, 1] (NA if undefined).
#' @noRd
weighted_cor <- function(x, y, w = NULL) {
  x <- as.numeric(x); y <- as.numeric(y)
  if (is.null(w)) w <- rep(1, length(x))
  w <- as.numeric(w)
  ok <- !is.na(x) & !is.na(y) & !is.na(w) & w > 0
  x <- x[ok]; y <- y[ok]; w <- w[ok]
  if (length(x) < 2L) return(NA_real_)
  mx <- sum(x * w) / sum(w); my <- sum(y * w) / sum(w)
  cov_xy <- sum(w * (x - mx) * (y - my)) / sum(w)
  var_x  <- sum(w * (x - mx)^2) / sum(w)
  var_y  <- sum(w * (y - my)^2) / sum(w)
  if (var_x == 0 || var_y == 0) return(NA_real_)
  cov_xy / sqrt(var_x * var_y)
}

#' Weighted correlation matrix over a set of numeric columns
#'
#' @param df Data frame.
#' @param cols Character vector of numeric column names.
#' @param w Row weights; NULL => unweighted.
#' @return Correlation matrix with dimnames from `cols`.
#' @noRd
weighted_cor_matrix <- function(df, cols, w = NULL) {
  cols <- cols[cols %in% names(df)]
  if (length(cols) < 2L) return(matrix(NA, 0, 0))
  m <- matrix(NA_real_, length(cols), length(cols), dimnames = list(cols, cols))
  for (i in seq_along(cols)) {
    for (j in seq_along(cols)) {
      if (i == j) m[i, j] <- 1
      else if (j > i) {
        m[i, j] <- m[j, i] <- weighted_cor(df[[cols[i]]], df[[cols[j]]], w)
      }
    }
  }
  m
}

#' Weights for a PDM that samples beneficiaries and non-beneficiaries separately
#'
#' PDMs usually survey a set number of beneficiary and non-beneficiary
#' households, whatever the two groups' real sizes. Left unweighted, the
#' eligible non-beneficiaries -- the exclusion error -- are counted as if the
#' two groups were the same size. Each household is weighted by the size of
#' its group in the population over the number surveyed from it:
#' w = N / n, per area when the population is given per area.
#'
#' @param benef Logical beneficiary flag, one per PDM household (NA: unknown).
#' @param unit Area of each household, or NULL for one overall stratum.
#' @param pop data.frame with columns `unit`, `beneficiaries`,
#'   `non_beneficiaries` (population households); `unit` = "All" when overall.
#' @return list(`w` = weights (NA where the stratum has no population),
#'   `strata` = data.frame of surveyed and population counts per stratum).
#' @noRd
pdm_stratum_weights <- function(benef, unit = NULL, pop) {
  n <- length(benef)
  u <- if (is.null(unit)) rep("All", n) else as.character(unit)
  u[is.na(u)] <- "(missing)"
  status <- ifelse(benef %in% TRUE, "beneficiaries", ifelse(benef %in% FALSE, "non_beneficiaries", NA))
  key <- paste(u, status, sep = "\r")
  n_s <- table(key[!is.na(status)])
  pop_n <- function(uu, st) {
    i <- match(uu, as.character(pop$unit))
    if (is.na(i)) NA_real_ else suppressWarnings(as.numeric(pop[[st]][i]))
  }
  w <- vapply(seq_len(n), function(i) {
    if (is.na(status[i])) return(NA_real_)
    N <- pop_n(u[i], status[i])
    if (is.na(N) || N < 0) NA_real_ else N / as.numeric(n_s[[key[i]]])
  }, numeric(1))
  units <- sort(unique(u))
  strata <- data.frame(
    unit = units,
    surveyed_beneficiaries = vapply(units, function(x) sum(u == x & status %in% "beneficiaries"), numeric(1)),
    surveyed_non_beneficiaries = vapply(units, function(x) sum(u == x & status %in% "non_beneficiaries"), numeric(1)),
    beneficiaries = vapply(units, function(x) pop_n(x, "beneficiaries"), numeric(1)),
    non_beneficiaries = vapply(units, function(x) pop_n(x, "non_beneficiaries"), numeric(1)),
    stringsAsFactors = FALSE, row.names = NULL)
  list(w = w, strata = strata)
}

#' Eligibility of PDM households from the adopted scorecard
#'
#' Each criterion is looked for in the PDM data under the column the scorecard
#' was mapped to, then under its own name. A criterion the PDM does not carry
#' makes the result meaningless (a missing answer would count as "not met"),
#' so the missing ones are returned instead.
#' @return list(`eligible`, `missing`)
#' @noRd
pdm_scorecard_eligibility <- function(df, scorecard) {
  if (scorecard_is_empty(scorecard)) return(list(eligible = NULL, missing = "(no scorecard adopted)"))
  missing <- character(0)
  scorecard$items <- lapply(scorecard$items, function(it) {
    cand <- c(it$column, it$criterion)
    cand <- cand[!is.na(cand) & nzchar(cand) & cand %in% names(df)]
    if (!length(cand)) missing <<- c(missing, it$criterion) else it$column <- cand[1]
    it
  })
  if (length(missing)) return(list(eligible = NULL, missing = missing))
  list(eligible = apply_scorecard(df, scorecard)$eligible, missing = character(0))
}
