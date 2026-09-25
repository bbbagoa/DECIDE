#' Variable screening: every variable of the assessment data against the outcome
#'
#' Run once the vulnerability framework (the outcome) is set, before the
#' criteria are chosen, so the officer sees which variables separate
#' vulnerable from other households:
#'
#' * yes/no variables are ready as they are;
#' * a variable with 3 to 15 answers gets a suggested yes/no version: "yes"
#'   for the answers where vulnerability is above average;
#' * a number gets a suggested cut-off: the one that separates the two groups
#'   best (largest gap in vulnerability, both sides at least 5% of the
#'   households).
#'
#' Each suggestion is a condition the variable calculator can build in one
#' click (`rule`: list(op, value)).
#' @name variable_screening
#' @noRd
NULL

#' The 2x2 comparison of a yes/no variable with the outcome
#' @noRd
screen_stats <- function(b, y) {
  ok <- !is.na(b) & !is.na(y)
  b <- b[ok] == 1; y <- y[ok] == 1
  n <- length(b); ny <- sum(b); nn <- n - ny
  if (n < 10 || ny == 0 || nn == 0) return(NULL)
  vy <- mean(y[b]); vn <- mean(y[!b])
  a <- sum(y & b) + .5; bb <- sum(!y & b) + .5; cc <- sum(y & !b) + .5; d <- sum(!y & !b) + .5
  p <- tryCatch(suppressWarnings(stats::chisq.test(table(factor(b, c(FALSE, TRUE)), factor(y, c(FALSE, TRUE))))$p.value),
                error = function(e) NA_real_)
  list(n = n, yes_share = ny / n, vuln_yes = vy, vuln_no = vn, gap = vy - vn, odds_ratio = (a * d) / (bb * cc), p_value = p)
}

#' How strong a gap is, in words
#' @noRd
screen_strength <- function(gap, p) {
  g <- abs(gap) * 100
  ifelse(is.na(p) | p >= 0.05, "Not significant",
         ifelse(g >= 15, "Strong", ifelse(g >= 7, "Moderate", "Weak")))
}

#' Screen every usable variable
#'
#' @param df Assessment data.
#' @param y The outcome, 1 = vulnerable, 0 = not, NA = unknown.
#' @param exclude Columns left out (the outcome, outcome indicators).
#' @return data.frame, strongest first: variable, kind ("yes/no",
#'   "categories", "number"), suggestion, rule (list column, NULL when ready),
#'   n, yes_share, vuln_yes, vuln_no, gap, odds_ratio, p_value, strength,
#'   detail (answers and their vulnerability, for categories).
#' @noRd
screen_variables <- function(df, y, exclude = character(0), max_levels = 15L, min_share = 0.05) {
  rows <- list()
  n_all <- nrow(df)
  base <- mean(y == 1, na.rm = TRUE)
  for (cl in setdiff(names(df), exclude)) {
    x <- df[[cl]]
    if (inherits(x, "haven_labelled")) x <- haven::as_factor(x)
    if (inherits(x, c("Date", "POSIXt")) || startsWith(cl, "_")) next
    # Outcome indicators and what a registration team cannot observe
    # (expenditure, prices, coping, MEB, food consumption, phone, debt).
    if (length(outcome_like_columns(cl)) || !is.na(unobservable_reason(cl))) next
    # Coordinates and survey weights describe the record, not the household.
    if (grepl("^(lat|lon|long|lng|latitude|longitude|x|y|gps.*|.*_(latitude|longitude|altitude|precision)|weights?|wt|poids|pond.*)$",
              cl, ignore.case = TRUE)) next
    nonmiss <- x[!is.na(x)]
    if (!length(nonmiss)) next
    u <- unique(nonmiss)
    if (length(u) < 2) next
    add <- function(kind, b, suggestion, rule, detail = "") {
      st <- screen_stats(b, y)
      if (is.null(st)) return(invisible())
      rows[[length(rows) + 1]] <<- data.frame(variable = cl, kind = kind, suggestion = suggestion,
        rule = I(list(rule)), n = st$n, yes_share = st$yes_share, vuln_yes = st$vuln_yes, vuln_no = st$vuln_no,
        gap = st$gap, odds_ratio = st$odds_ratio, p_value = st$p_value, detail = detail, stringsAsFactors = FALSE)
    }

    b <- as_binary_criterion(x)
    if (!is.null(b)) {
      add("yes/no", b, "Ready: already yes/no", NULL)
      next
    }
    num <- if (is.numeric(x)) x else suppressWarnings(as.numeric(as.character(x)))
    answered <- !is.na(x) & nzchar(trimws(as.character(x)))
    if (mean(!is.na(num[answered])) >= 0.95 && length(unique(num[!is.na(num)])) >= 3) {
      # A number (ordered, however few its values): the cut-off with the
      # largest gap, both sides >= min_share.
      cand <- sort(unique(c(stats::quantile(num, seq(0.1, 0.9, 0.05), na.rm = TRUE, names = FALSE),
                            if (length(unique(num[!is.na(num)])) <= 30) unique(num[!is.na(num)]))))
      best <- NULL
      for (c0 in cand) {
        bb <- as.integer(num >= c0)
        share <- mean(bb, na.rm = TRUE)
        if (is.na(share) || share < min_share || share > 1 - min_share) next
        ok <- !is.na(bb) & !is.na(y)
        gap <- mean(y[ok][bb[ok] == 1]) - mean(y[ok][bb[ok] == 0])
        if (is.null(best) || abs(gap) > abs(best$gap)) best <- list(cut = c0, gap = gap)
      }
      if (is.null(best)) next
      # Whole numbers (household size, ages): a whole cut-off, same households.
      whole <- all(num[!is.na(num)] == round(num[!is.na(num)]))
      cut <- if (whole) ceiling(best$cut) else signif(best$cut, 4)
      add("number", as.integer(num >= cut), sprintf("Yes when %s is at least %s", cl, format(cut)),
          list(op = ">=", value = format(cut)))
      next
    }
    lv <- sort(unique(trimws(as.character(nonmiss))))
    lv <- lv[nzchar(lv)]
    if (length(lv) < 3 || length(lv) > max_levels || any(grepl(",", lv, fixed = TRUE))) next
    xs <- trimws(as.character(x)); xs[!nzchar(xs)] <- NA
    rate <- vapply(lv, function(l) mean(y[which(xs == l)] == 1, na.rm = TRUE), numeric(1))
    cnt <- vapply(lv, function(l) sum(xs == l, na.rm = TRUE), integer(1))
    high <- lv[!is.na(rate) & rate > base]
    if (!length(high) || length(high) == length(lv)) next
    bb <- ifelse(is.na(xs), NA_integer_, as.integer(xs %in% high))
    detail <- paste(sprintf("%s: %.0f%% (n %s)", lv, 100 * rate, format(cnt, big.mark = ","))[order(-rate)], collapse = "; ")
    add("categories", bb, sprintf("Yes when %s is %s", cl, paste(high, collapse = " or ")),
        list(op = "in", value = paste(high, collapse = ",")), detail)
  }
  if (!length(rows)) return(NULL)
  out <- do.call(rbind, rows)
  out$strength <- screen_strength(out$gap, out$p_value)
  # Odds ratios (and shares) to 4 decimals at most.
  for (k in c("odds_ratio", "yes_share", "vuln_yes", "vuln_no", "gap")) out[[k]] <- round(out[[k]], 4)
  out <- out[order(out$strength == "Not significant", -abs(out$gap)), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' The name of the yes/no variable built from a suggestion
#' @noRd
screen_new_name <- function(variable, rule, taken) {
  # "ge7", "ge_m1_51" for -1.51 (the minus sign kept as m)
  suffix <- if (identical(rule$op, ">=")) paste0("ge", gsub("[^0-9A-Za-z]+", "_", sub("^-", "_m", rule$value))) else "grp"
  nm <- paste0(variable, "_", suffix)
  base <- nm; k <- 2
  while (nm %in% taken) { nm <- paste0(base, "_", k); k <- k + 1 }
  nm
}
