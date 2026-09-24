#' Extreme values: detection helpers
#'
#' Two checks run together on a numeric variable:
#'
#' * a statistical one (IQR, Z-score or modified Z / MAD), which knows the
#'   distribution but not what is plausible;
#' * an allowed range typed by the analyst (a household of 0 or 45 people, an
#'   age of 150), which is flagged whatever the distribution says.
#'
#' A value is flagged when it falls outside the narrower of the two, so the
#' effective limits are the tighter lower and the tighter upper bound.
#'
#' @name outlier_helpers
NULL

#' Statistical bounds of a numeric vector
#'
#' @param vals Numeric vector.
#' @param method "IQR", "Z", "MAD" or "none" (allowed range only).
#' @param threshold Tukey multiplier, number of SDs, or modified-Z cut-off.
#' @return c(lower, upper); -Inf / Inf when the method cannot say (no spread).
#' @noRd
outlier_bounds <- function(vals, method = "IQR", threshold = 1.5) {
  vals <- vals[is.finite(vals)]
  if (!length(vals) || identical(method, "none")) return(c(-Inf, Inf))
  if (identical(method, "IQR")) {
    q <- stats::quantile(vals, c(0.25, 0.75), names = FALSE)
    iqr <- q[2] - q[1]
    return(c(q[1] - threshold * iqr, q[2] + threshold * iqr))
  }
  if (identical(method, "MAD")) {
    # 1.4826 scales the MAD to the SD for normal data; 3.5 is the
    # Iglewicz-Hoaglin cut-off. Robust to the very values being detected.
    med <- stats::median(vals)
    s <- stats::median(abs(vals - med)) * 1.4826
    if (!is.finite(s) || s == 0) return(c(-Inf, Inf))
    return(c(med - threshold * s, med + threshold * s))
  }
  # Z-score: the SD is inflated by the outliers themselves; MAD is safer on
  # skewed data.
  m <- mean(vals); s <- stats::sd(vals)
  if (!is.finite(s) || s == 0) return(c(-Inf, Inf))
  c(m - threshold * s, m + threshold * s)
}

#' Why each value is flagged ("" when it is not)
#'
#' @param vals Numeric vector.
#' @param bounds Statistical bounds, from `outlier_bounds()`.
#' @param allowed c(min, max) typed by the analyst; NA means no limit.
#' @return Character vector the length of `vals`.
#' @noRd
outlier_reason <- function(vals, bounds, allowed = c(NA, NA)) {
  lo <- allowed[1]; hi <- allowed[2]
  out <- rep("", length(vals))
  ok <- !is.na(vals)
  out[ok & vals < bounds[1]] <- "Statistically low"
  out[ok & vals > bounds[2]] <- "Statistically high"
  # The analyst's range speaks louder than the distribution.
  if (!is.na(lo)) out[ok & vals < lo] <- "Below allowed minimum"
  if (!is.na(hi)) out[ok & vals > hi] <- "Above allowed maximum"
  out
}

#' The limits a correction caps to: the tighter of the two checks
#' @noRd
outlier_limits <- function(bounds, allowed = c(NA, NA)) {
  c(max(bounds[1], allowed[1], na.rm = TRUE), min(bounds[2], allowed[2], na.rm = TRUE))
}

#' A sensible allowed range for the mapped variables, as a starting point
#' @noRd
suggested_range <- function(key) {
  key <- if (length(key) && !is.na(key[1])) as.character(key[1]) else ""
  switch(key,
    hh_size = c(1, 30),
    hhh_age = c(12, 110),   # child-headed households exist
    childU5 = c(0, 10),
    c(NA, NA))
}

#' Robust z-score: distance from the median in scaled MADs
#' @noRd
robust_z <- function(x, vals) {
  v <- vals[is.finite(vals)]
  med <- stats::median(v)
  s <- stats::median(abs(v - med)) * 1.4826
  if (!is.finite(s) || s == 0) s <- stats::sd(v)
  if (!is.finite(s) || s == 0) return(rep(NA_real_, length(x)))
  (x - med) / s
}

#' Codes that stand for "don't know" / "refused" rather than a quantity
#'
#' 9, 99, 999... and their negatives, plus -1 and 88/888. Returned only when
#' they repeat among the flagged values: one household of 99 people is an
#' error, twenty of them is a code.
#' @param flagged_vals Numeric values that were flagged.
#' @param min_count Minimum repetitions to report.
#' @return data.frame(value, n), most frequent first.
#' @noRd
sentinel_codes <- function(flagged_vals, min_count = 3) {
  codes <- c(-1, -9, -99, -999, -9999, 88, 888, 8888, 98, 998, 99, 999, 9999, 99999)
  v <- flagged_vals[flagged_vals %in% codes]
  if (!length(v)) return(data.frame(value = numeric(0), n = integer(0)))
  tb <- table(v)
  out <- data.frame(value = as.numeric(names(tb)), n = as.integer(tb))
  out <- out[out$n >= min_count, , drop = FALSE]
  out[order(-out$n), , drop = FALSE]
}

#' Audit every numeric variable at once
#'
#' @param df data.frame.
#' @param cols Numeric-like columns to audit.
#' @param method,threshold Detection settings (as `outlier_bounds()`).
#' @param ranges Named list of c(min, max) allowed ranges, by column.
#' @param labels Named character: column -> mapped field label.
#' @return One row per column, most flagged first.
#' @noRd
numeric_audit <- function(df, cols, method = "IQR", threshold = 1.5, ranges = list(), labels = character(0)) {
  rows <- lapply(cols, function(cl) {
    v <- as_number(df[[cl]])
    ans <- sum(!is.na(v))
    rg <- ranges[[cl]] %||% c(NA, NA)
    lab <- if (cl %in% names(labels)) unname(labels[[cl]]) else ""
    if (ans == 0) {
      return(data.frame(variable = cl, mapped = lab, answered = 0L,
                        missing_pct = 100, min = NA, median = NA, max = NA,
                        allowed = "", flagged = 0L, flagged_pct = 0, stringsAsFactors = FALSE))
    }
    b <- outlier_bounds(v, method, threshold)
    flagged <- sum(nzchar(outlier_reason(v, b, rg)))
    data.frame(
      variable = cl, mapped = lab,
      answered = ans, missing_pct = round(100 * mean(is.na(v)), 1),
      min = min(v, na.rm = TRUE), median = stats::median(v, na.rm = TRUE), max = max(v, na.rm = TRUE),
      allowed = if (all(is.na(rg))) "" else paste(ifelse(is.na(rg[1]), "\u2013", rg[1]), "to", ifelse(is.na(rg[2]), "\u2013", rg[2])),
      flagged = flagged, flagged_pct = round(100 * flagged / ans, 2),
      stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  if (is.null(out)) return(NULL)
  out[order(-out$flagged_pct, -out$flagged), , drop = FALSE]
}

#' Record ids whose value of `column` was checked and kept, read from the audit trail
#' @noRd
verified_uids <- function(log, column) {
  if (is.null(log) || !nrow(log)) return(character(0))
  hit <- log$action == "Outlier verified (kept)" & log$column == column
  unique(as.character(log$uid[hit]))
}
