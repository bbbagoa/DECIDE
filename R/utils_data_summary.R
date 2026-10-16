#' A quick summary of a dataset: every variable, its type, missing values,
#' its categories or distribution (for the "Data summary" dialog of every
#' upload, R/mod_data_summary.R, and its Excel export).
#'
#' Counting goes through data.table (one grouped count per column), so a
#' 1.5 million row file is summarised in seconds.
#' @name data_summary
NULL

#' Summarise every column
#'
#' @param df A data frame.
#' @param max_levels Categories shown for a categorical variable (the rest are
#'   counted together).
#' @param bins Bars of a number's or a date's histogram.
#' @param labels Named character: variable labels (the session dictionary).
#' @return list(rows, cols, vars): one entry per column with `name`, `label`,
#'   `kind` ("category", "number", "date", "text", "id", "empty"), `missing`,
#'   `distinct`, and for categories `levels` (value, n) + `other`; for numbers
#'   `stats` (min, q1, median, mean, q3, max, sd) + `hist`; for dates `range`
#'   + `hist`; for text and ids `top` (value, n).
#' @noRd
data_summary <- function(df, max_levels = 12, bins = 24, labels = NULL) {
  n <- nrow(df)
  vars <- lapply(names(df), function(k) {
    x <- df[[k]]
    if (is.list(x)) x <- vapply(x, function(v) paste(as.character(unlist(v)), collapse = ", "), "")
    if (is.factor(x)) x <- as.character(x)
    # Counted once; for text, blanks are found among the distinct values (not
    # row by row: trimws() over 1.5 million values takes half a second)
    counts <- data.table::data.table(v = x)[, list(N = .N), by = "v"]
    bad <- if (is.character(x)) is.na(counts$v) | !nzchar(trimws(counts$v)) | counts$v == "NULL" else is.na(counts$v)
    nm <- sum(counts$N[bad])
    counts <- counts[!bad]
    out <- list(name = k, label = if (!is.null(labels) && k %in% names(labels)) unname(labels[[k]]) else NA_character_,
                missing = nm, missing_pct = if (n) nm / n else 0)
    if (!nrow(counts)) return(c(out, list(kind = "empty", distinct = 0L)))
    data.table::setorderv(counts, "N", order = -1L)
    out$distinct <- nrow(counts)
    n_ok <- n - nm
    top <- function(m) {
      h <- utils::head(counts, m)
      lapply(seq_len(nrow(h)), function(i) list(value = format_cell(h$v[[i]]), n = h$N[[i]]))
    }
    # the values themselves only for numbers and dates (quantiles, histogram)
    v <- if (is.numeric(x) || inherits(x, c("Date", "POSIXt"))) x[!is.na(x)] else NULL
    if (inherits(x, c("Date", "POSIXt"))) {
      d <- as.numeric(as.Date(v)); d <- d[is.finite(d)]
      if (!length(d)) return(c(out, list(kind = "empty")))
      out$kind <- "date"
      out$range <- format(as.Date(range(d), origin = "1970-01-01"))
      out$hist <- summary_hist(d, bins, as_date = TRUE)
      return(out)
    }
    if (is.numeric(v) && out$distinct > max_levels) {
      out$kind <- "number"
      # Inf / -Inf (a ratio divided by 0) are counted apart: figures and
      # histogram on the finite values (seq() fails on an infinite range)
      fin <- is.finite(v)
      if (!all(fin)) { out$infinite <- sum(!fin); v <- v[fin] }
      q <- stats::quantile(v, c(0, .25, .5, .75, 1), names = FALSE, type = 7)
      out$stats <- list(min = q[1], q1 = q[2], median = q[3], mean = mean(v), q3 = q[4], max = q[5],
                        sd = if (length(v) > 1) stats::sd(v) else NA_real_)
      out$hist <- summary_hist(v, bins)
      return(out)
    }
    if (out$distinct <= max(max_levels, 30) || is.numeric(v)) {
      # a few values: categories (numbers too, e.g. 0 / 1 or 1-5 codes)
      out$kind <- "category"
      if (is.numeric(v)) data.table::setorderv(counts, "v")
      shown <- utils::head(counts, max_levels)
      out$levels <- lapply(seq_len(nrow(shown)), function(i) list(value = format_cell(shown$v[[i]]), n = shown$N[[i]]))
      out$other <- sum(counts$N) - sum(shown$N)
      return(out)
    }
    # many distinct texts: an identifier when nearly all differ, free text otherwise
    out$kind <- if (out$distinct >= 0.9 * n_ok) "id" else "text"
    out$top <- top(5)
    out
  })
  list(rows = n, cols = ncol(df), vars = vars)
}

#' Equal-width histogram counts (and the bin edges), for numbers or dates
#' @noRd
summary_hist <- function(v, bins = 24, as_date = FALSE) {
  r <- range(v)
  if (r[1] == r[2]) return(list(edges = c(r[1], r[2]), counts = length(v), date = as_date))
  br <- seq(r[1], r[2], length.out = bins + 1)
  cnt <- tabulate(findInterval(v, br, rightmost.closed = TRUE, all.inside = TRUE), nbins = bins)
  list(edges = if (as_date) format(as.Date(br, origin = "1970-01-01")) else signif(br, 6), counts = cnt, date = as_date)
}

#' A value as the summary shows it
#' @noRd
format_cell <- function(v) {
  if (is.numeric(v)) return(format(v, big.mark = ",", scientific = FALSE, trim = TRUE, drop0trailing = TRUE))
  s <- as.character(v)
  if (nchar(s) > 80) paste0(substr(s, 1, 77), "...") else s
}

#' The summary as one row per variable (the Excel export)
#' @noRd
data_summary_frame <- function(s) {
  num <- function(x) if (is.null(x) || !is.finite(x)) NA_real_ else signif(x, 6)
  rows <- lapply(s$vars, function(v) {
    lev <- v$levels %||% v$top
    data.frame(
      Variable = v$name, Label = v$label %||% NA_character_, Type = v$kind,
      `Missing` = v$missing, `Missing (%)` = round(100 * v$missing_pct, 1), `Distinct values` = v$distinct %||% 0L,
      Min = num(v$stats$min), Q1 = num(v$stats$q1), Median = num(v$stats$median), Mean = num(v$stats$mean),
      Q3 = num(v$stats$q3), Max = num(v$stats$max), SD = num(v$stats$sd),
      `Date range` = if (is.null(v$range)) NA_character_ else paste(v$range, collapse = " to "),
      `Values (count)` = if (is.null(lev)) NA_character_ else
        paste0(paste(vapply(lev, function(l) sprintf("%s (%s)", l$value, format(l$n, big.mark = ",")), ""), collapse = "; "),
               if (isTRUE(v$other > 0)) sprintf("; other values (%s)", format(v$other, big.mark = ",")) else ""),
      check.names = FALSE, stringsAsFactors = FALSE)
  })
  do.call(rbind, rows)
}
