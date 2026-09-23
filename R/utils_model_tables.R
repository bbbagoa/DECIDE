#' Model tables: HTML for the page, a workbook for the export
#'
#' The screening results, the fitted coefficients and the model comparison
#' are read the way a regression table is read in a report -- odds ratio,
#' confidence interval, a p-value whose strength is visible at a glance -- so
#' they are drawn as styled HTML rather than a DataTable, and exported with
#' the same colour coding.
#'
#' @name model_tables
NULL

#' Significance band of a p-value
#' @noRd
p_level <- function(p) {
  ifelse(is.na(p), "na",
         ifelse(p < 0.001, "p001", ifelse(p < 0.01, "p01", ifelse(p < 0.05, "p05",
                ifelse(p < 0.1, "p10", "ns")))))
}

#' Format a p-value for display
#' @noRd
p_format <- function(p) {
  ifelse(is.na(p), "-", ifelse(p < 0.001, "<0.001", sprintf("%.3f", p)))
}

p_pill <- function(p) {
  tags$span(class = paste("wfp-p", paste0("wfp-p-", p_level(p))), p_format(p))
}

#' Odds ratio with its CI and a small forest-plot whisker on a log scale
#' (OR 0.1 at the left edge, 10 at the right, 1 in the middle).
#' @noRd
or_cell <- function(or, lo, hi) {
  if (is.na(or)) return(tags$span(class = "text-muted", "-"))
  pos <- function(x) 100 * (min(max(log10(x), -1), 1) + 1) / 2
  cls <- if (or >= 1) "is-incl" else "is-excl"
  tags$div(
    class = "wfp-or",
    tags$div(class = "wfp-or-num",
             tags$strong(sprintf("%.2f", or)),
             if (!is.na(lo)) tags$span(class = "wfp-or-ci", sprintf(" (%.2f\u2013%.2f)", lo, hi))),
    tags$div(
      class = paste("wfp-or-track", cls),
      tags$span(class = "wfp-or-one"),
      if (!is.na(lo)) tags$span(class = "wfp-or-whisker",
                                style = sprintf("left:%.1f%%;width:%.1f%%", pos(lo), max(pos(hi) - pos(lo), 0.5))),
      tags$span(class = "wfp-or-dot", style = sprintf("left:%.1f%%", pos(or)))
    )
  )
}

p_legend <- function() {
  tags$div(
    class = "wfp-p-legend small text-muted",
    "p-value: ",
    tags$span(class = "wfp-p wfp-p-p001", "<0.001"),
    tags$span(class = "wfp-p wfp-p-p01", "<0.01"),
    tags$span(class = "wfp-p wfp-p-p05", "<0.05"),
    tags$span(class = "wfp-p wfp-p-p10", "<0.10"),
    tags$span(class = "wfp-p wfp-p-ns", "\u22650.10")
  )
}

dir_badge <- function(d) {
  if (is.na(d)) return(tags$span(class = "text-muted", "-"))
  tags$span(class = paste("wfp-dir", if (d == "inclusion") "is-incl" else "is-excl"), d)
}

#' Fitted model coefficients as an HTML table
#'
#' @param points,review Optional lists (one element per row) of tags to show
#'   instead of the plain points value, and in an extra review column -- the
#'   page passes its editable inputs here so the estimates and the editable
#'   card are one table.
#' @noRd
coefficients_html <- function(wts, model = NULL, points = NULL, review = NULL) {
  rows <- lapply(seq_len(nrow(wts)), function(i) {
    r <- wts[i, ]
    tags$tr(
      tags$td(tags$strong(r$criterion)),
      tags$td(class = "num", sprintf("%+.3f", r$coefficient)),
      tags$td(class = "num", if (is.null(r$std_error)) "-" else sprintf("%.3f", r$std_error)),
      tags$td(or_cell(r$odds_ratio, r$or_low %||% NA, r$or_high %||% NA)),
      tags$td(class = "num", p_pill(r$p_value)),
      tags$td(dir_badge(r$direction)),
      tags$td(class = "num", if (is.null(points)) tags$strong(sprintf("%.2f", r$weight)) else points[[i]]),
      if (!is.null(review)) tags$td(review[[i]])
    )
  })
  fit_line <- NULL
  if (!is.null(model) && inherits(model, "glm")) {
    r2 <- 1 - model$deviance / model$null.deviance
    fit_line <- tags$div(
      class = "small text-muted mt-2",
      sprintf("n = %s  \u00b7  AIC %.1f  \u00b7  McFadden pseudo-R\u00b2 %.3f  \u00b7  intercept %+.3f",
              format(length(model$y), big.mark = ","), stats::AIC(model), r2,
              stats::coef(model)[1])
    )
  }
  tagList(
    tags$div(
      class = "wfp-model-table-wrap",
      tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(
          tags$th("Criterion"), tags$th(class = "num", "\u03b2"), tags$th(class = "num", "SE"),
          tags$th("Odds ratio (95% CI)"), tags$th(class = "num", "p"),
          tags$th("Direction"), tags$th(class = "num", "Points"),
          if (!is.null(review)) tags$th("Review")
        )),
        tags$tbody(rows)
      )
    ),
    fit_line,
    p_legend()
  )
}

#' Model comparison as an HTML table; the best held-out AUC is highlighted
#' @noRd
comparison_html <- function(tab) {
  best <- suppressWarnings(max(tab$auc_test, na.rm = TRUE))
  bar <- function(x) if (is.na(x)) "-" else tags$div(
    class = "wfp-auc",
    tags$span(class = "wfp-auc-bar", style = sprintf("width:%.0f%%", 100 * max(0, (x - 0.5) / 0.5))),
    tags$span(class = "wfp-auc-num", sprintf("%.3f", x))
  )
  rows <- lapply(seq_len(nrow(tab)), function(i) {
    r <- tab[i, ]
    tags$tr(
      class = if (isTRUE(r$auc_test == best)) "is-best" else NULL,
      tags$td(tags$strong(r$model), if (isTRUE(r$auc_test == best))
        tags$span(class = "wfp-kept ms-2", bsicons::bs_icon("trophy"), " best")),
      tags$td(class = "num", if (is.na(r$criteria)) "" else r$criteria),
      tags$td(bar(r$auc_train)),
      tags$td(bar(r$auc_test))
    )
  })
  tags$div(
    class = "wfp-model-table-wrap",
    tags$table(
      class = "wfp-model-table",
      tags$thead(tags$tr(tags$th("Model"), tags$th(class = "num", "Criteria"),
                         tags$th("AUC (training)"), tags$th("AUC (held out)"))),
      tags$tbody(rows)
    )
  )
}

#' One workbook with the screening, the coefficients and the comparison,
#' p-values colour-coded as on the page
#' @noRd
model_tables_workbook <- function(screening = NULL, coefficients = NULL, comparison = NULL) {
  wb <- openxlsx::createWorkbook()
  head_st <- openxlsx::createStyle(fgFill = "#0A6EB4", fontColour = "#FFFFFF",
                                   textDecoration = "bold", border = "Bottom")
  fills <- c(p001 = "#1E6B2A", p01 = "#3F7E44", p05 = "#CFE6D1", p10 = "#FDF0D5", ns = "#EEF1F4")
  fonts <- c(p001 = "#FFFFFF", p01 = "#FFFFFF", p05 = "#1E4B24", p10 = "#8A6100", ns = "#5B6B7E")

  add <- function(name, df, pcols) {
    if (is.null(df) || !nrow(df)) return()
    openxlsx::addWorksheet(wb, name)
    write_data(wb, name, df, headerStyle = head_st)
    openxlsx::freezePane(wb, name, firstRow = TRUE)
    openxlsx::setColWidths(wb, name, cols = seq_along(df), widths = "auto")
    for (pc in intersect(pcols, names(df))) {
      j <- match(pc, names(df))
      lv <- p_level(df[[pc]])
      for (l in names(fills)) {
        rr <- which(lv == l)
        if (length(rr)) openxlsx::addStyle(
          wb, name, openxlsx::createStyle(fgFill = fills[[l]], fontColour = fonts[[l]], numFmt = "0.0000"),
          rows = rr + 1, cols = j, gridExpand = TRUE)
      }
    }
  }

  if (!is.null(screening)) {
    add("Screening", data.frame(
      Criterion = screening$criterion, Prevalence = round(screening$prevalence, 4),
      `Odds ratio` = round(screening$or, 3), `CI low` = round(screening$or_low, 3),
      `CI high` = round(screening$or_high, 3), Direction = screening$direction,
      Test = screening$test, p = screening$p_value, `p (adj.)` = screening$p_adj,
      Retained = ifelse(screening$retained, "yes", "no"), check.names = FALSE
    ), c("p", "p (adj.)"))
  }
  if (!is.null(coefficients)) {
    add("Model", data.frame(
      Criterion = coefficients$criterion, Beta = round(coefficients$coefficient, 4),
      SE = round(coefficients$std_error %||% NA_real_, 4),
      `Odds ratio` = round(coefficients$odds_ratio, 3),
      `CI low` = round(coefficients$or_low %||% NA_real_, 3),
      `CI high` = round(coefficients$or_high %||% NA_real_, 3),
      p = coefficients$p_value, Direction = coefficients$direction,
      Points = coefficients$weight, check.names = FALSE
    ), "p")
  }
  if (!is.null(comparison)) {
    add("Model comparison", data.frame(
      Model = comparison$model, Criteria = comparison$criteria,
      `AUC (training)` = round(comparison$auc_train, 4),
      `AUC (held out)` = round(comparison$auc_test, 4), check.names = FALSE
    ), character(0))
  }
  if (!length(openxlsx::sheets(wb))) {
    openxlsx::addWorksheet(wb, "Model")
    write_data(wb, "Model", data.frame(Message = "Run the screening and fit the model first."))
  }
  wb
}

# ---------------------------------------------------------------------------
# Variable selection: descriptive profile and correlation of the chosen set
# ---------------------------------------------------------------------------

#' Descriptive profile of candidate criteria against the outcome
#'
#' @param y Binary outcome (1 = vulnerable), one per row of `df`.
#' @return One row per criterion: valid n, missing share, prevalence overall
#'   and in each outcome group, and the gap between the groups.
#' @noRd
criteria_profile <- function(df, criteria, y) {
  do.call(rbind, lapply(criteria, function(cl) {
    x <- as_binary_criterion(df[[cl]])
    if (is.null(x)) x <- rep(NA_integer_, nrow(df))
    ok <- !is.na(x)
    pv <- mean(x[ok & y %in% 1] == 1)
    pn <- mean(x[ok & y %in% 0] == 1)
    round5(data.frame(criterion = cl, n = sum(ok), missing = mean(!ok),
               prevalence = mean(x[ok] == 1), prev_vuln = pv, prev_not = pn,
               gap = pv - pn, stringsAsFactors = FALSE))
  }))
}

#' Pairwise correlation (phi) between binary criteria
#' @noRd
criteria_cor <- function(df, criteria) {
  m <- vapply(criteria, function(cl) {
    v <- as_binary_criterion(df[[cl]]); if (is.null(v)) rep(NA_real_, nrow(df)) else as.numeric(v)
  }, numeric(nrow(df)))
  m <- matrix(m, ncol = length(criteria), dimnames = list(NULL, criteria))
  suppressWarnings(stats::cor(m, use = "pairwise.complete.obs"))
}

#' Correlation matrix as a compact HTML table
#'
#' Lower triangle only (the matrix is symmetric), numbered columns, cell tint
#' proportional to |r| (blue positive, red negative), pairs at or above the
#' cut-off outlined.
#' @noRd
correlation_html <- function(cm, cutoff = 0.8) {
  k <- ncol(cm); nm <- colnames(cm)
  if (k < 2) return(tags$div(class = "small text-muted", "One variable: nothing to correlate."))
  cell <- function(i, j) {
    if (j >= i) return(tags$td(class = "wfp-corr-empty"))
    r <- cm[i, j]
    if (is.na(r)) return(tags$td(class = "wfp-corr-cell", ""))
    a <- min(abs(r), 1)
    bg <- if (r >= 0) sprintf("rgba(10,110,180,%.2f)", 0.75 * a) else sprintf("rgba(197,25,45,%.2f)", 0.75 * a)
    tags$td(class = paste("wfp-corr-cell", if (a >= cutoff) "is-high" else "", if (a >= 0.45) "is-dark" else ""),
            style = sprintf("background:%s", bg), title = sprintf("%s \u00d7 %s: r = %.2f", nm[i], nm[j], r),
            sprintf("%.2f", r))
  }
  tagList(
    tags$div(
      class = "wfp-corr-wrap",
      tags$table(
        class = "wfp-corr",
        tags$thead(tags$tr(tags$th(""),
                           lapply(seq_len(k - 1), function(j) tags$th(class = "wfp-corr-colh", title = nm[j], j)))),
        tags$tbody(lapply(2:k, function(i) tags$tr(
          tags$th(class = "wfp-corr-row", title = nm[i], tags$span(class = "wfp-corr-idx", i), nm[i]),
          lapply(seq_len(k - 1), function(j) cell(i, j)))))
      )
    ),
    tags$div(class = "wfp-p-legend small text-muted",
             sprintf("1 = %s. ", nm[1]),
             tags$span(class = "wfp-corr-key pos"), "positive",
             tags$span(class = "wfp-corr-key neg"), "negative",
             sprintf("\u00b7 darker = stronger \u00b7 outlined: |r| \u2265 %.2f", cutoff))
  )
}

#' Descriptive statistics of the chosen criteria, with a Drop control per row
#'
#' @param prof Output of `criteria_profile()`, plus `max_r`, `max_with` and
#'   `suggest` (the partner it duplicates, or NA).
#' @param drop List of tags (one per row), the page's Drop checkboxes.
#' @noRd
profile_html <- function(prof, drop) {
  pct <- function(x) ifelse(is.na(x), "-", sprintf("%.1f%%", 100 * x))
  rows <- lapply(seq_len(nrow(prof)), function(i) {
    r <- prof[i, ]
    tags$tr(
      class = if (!is.na(r$suggest)) "is-flagged" else NULL,
      tags$td(tags$strong(r$criterion),
              if (!is.na(r$suggest)) tags$div(class = "small text-muted",
                                              sprintf("duplicates %s", r$suggest))),
      tags$td(class = "num", format(r$n, big.mark = ",")),
      tags$td(class = "num", pct(r$missing)),
      tags$td(class = "num", pct(r$prevalence)),
      tags$td(class = "num", pct(r$prev_vuln)),
      tags$td(class = "num", pct(r$prev_not)),
      tags$td(class = "num", tags$strong(sprintf("%+.1f pts", 100 * r$gap))),
      tags$td(class = "num", if (is.na(r$max_r)) "-" else tags$span(title = r$max_with, sprintf("%.2f", r$max_r))),
      tags$td(drop[[i]])
    )
  })
  tags$div(
    class = "wfp-model-table-wrap",
    tags$table(
      class = "wfp-model-table",
      tags$thead(tags$tr(
        tags$th("Criterion"), tags$th(class = "num", "Valid n"), tags$th(class = "num", "Missing"),
        tags$th(class = "num", "Prevalence"), tags$th(class = "num", "Vulnerable"),
        tags$th(class = "num", "Not vuln."), tags$th(class = "num", "Gap"),
        tags$th(class = "num", "Max |r|"), tags$th("Drop")
      )),
      tags$tbody(rows)
    )
  )
}

#' Per-criterion effects across models as an HTML table (log-odds; blue =
#' raises vulnerability, red = lowers it; dash = dropped by that model),
#' with the random-forest importance share when available.
#' @noRd
effects_html <- function(eff, importance = NULL) {
  models <- unique(eff$model)
  crit <- unique(eff$criterion)
  val <- function(cr, m) eff$effect[eff$criterion == cr & eff$model == m][1]
  cell <- function(v) {
    if (is.na(v)) return(tags$td(class = "num text-muted", "\u2014"))
    tags$td(class = paste("num", if (v >= 0) "wfp-eff-pos" else "wfp-eff-neg"), sprintf("%+.2f", v))
  }
  imp <- if (length(importance)) importance / sum(importance) else NULL
  tagList(
    tags$div(
      class = "wfp-model-table-wrap",
      tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(tags$th("Criterion"), lapply(models, function(m) tags$th(class = "num", m)),
                           if (!is.null(imp)) tags$th(class = "num", "Random forest importance"))),
        tags$tbody(lapply(crit, function(cr) tags$tr(
          tags$td(tags$strong(cr)),
          lapply(models, function(m) cell(val(cr, m))),
          if (!is.null(imp)) tags$td(class = "num", if (is.na(imp[cr])) "-" else sprintf("%.0f%%", 100 * imp[cr]))
        )))
      )
    ),
    tags$div(class = "small text-muted mt-1",
             "Log-odds effect of each criterion under each model, fitted on the same training households. ",
             "A criterion whose sign or size changes a lot between models deserves a second look.")
  )
}
