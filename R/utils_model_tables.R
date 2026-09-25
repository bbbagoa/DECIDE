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

#' One line on what a candidate criterion can tell, from its descriptives
#'
#' @param prevalence,missing,prev_vuln,prev_not Shares (0-1), one per criterion.
#' @return Character vector of plain-language readings.
#' @noRd
criterion_reading <- function(prevalence, missing, prev_vuln, prev_not) {
  gap <- prev_vuln - prev_not
  out <- ifelse(abs(gap) >= 0.15,
                ifelse(gap > 0, "Clearly more common among the vulnerable", "Clearly less common among the vulnerable"),
         ifelse(abs(gap) >= 0.05,
                ifelse(gap > 0, "Somewhat more common among the vulnerable", "Somewhat less common among the vulnerable"),
                "About as common in both groups: weak on its own"))
  out[prevalence < 0.05 | prevalence > 0.95] <- "Almost all or almost no households meet it: separates few"
  out[missing > 0.2] <- sprintf("Often missing (%.0f%%): check the question first", 100 * missing[missing > 0.2])
  out[is.na(gap)] <- "Cannot be read: no answers"
  out
}

#' "How the design works": the design process step by step, with the methods
#'
#' One step open at a time; each gives what the analyst does, how the app
#' does it, why it matters, the technical details and the references.
#' @noRd
design_guide_modal <- function() {
  sec <- function(icon_name, title, ...) tags$div(
    class = "wfp-guide-sec",
    tags$div(class = "wfp-guide-sec-title", bsicons::bs_icon(icon_name), " ", title),
    tags$div(class = "wfp-guide-sec-body", ...))
  step <- function(n, title, lead, what, how, why, tech, refs, tip = NULL) bslib::accordion_panel(
    title = tags$span(class = "wfp-guide-head", tags$span(class = "wfp-guide-num", n),
                      tags$span(tags$strong(title), tags$span(class = "wfp-guide-lead", lead))),
    value = paste0("g", n),
    tags$div(
      class = "wfp-guide-grid",
      sec("hand-index", "What you do", what),
      sec("gear", "How it works", how),
      sec("lightbulb", "Why it matters", why),
      sec("cpu", "Technical details", tech)),
    tags$div(class = "wfp-guide-refs", bsicons::bs_icon("journal-text"), " ", tags$strong("References. "), refs),
    if (!is.null(tip)) tags$div(class = "wfp-guide-tip", bsicons::bs_icon("stars"), " ", tags$strong("Tip. "), tip))

  modalDialog(
    title = tagList(bsicons::bs_icon("book"), " How the targeting design works"),
    size = "xl", easyClose = TRUE, footer = modalButton("Close"),
    tags$div(
      class = "wfp-guide",
      tags$div(
        class = "wfp-guide-intro",
        tags$p("The design turns a needs assessment into a ", tags$strong("scorecard"), ": a short list of observable household ",
               "criteria, each worth some points, and a threshold above which a household is eligible. It is built on data where ",
               "vulnerability is measured, then applied to registration data where it is not."),
        tags$p(class = "mb-0", "Seven steps, each recorded in the design report so the card can be reviewed, reproduced and ",
               "challenged. Guidance: WFP Targeting and Prioritisation OGN (2021); Targeting Advisories 1/2025 (outcome indicators), ",
               "2/2025 (errors and tolerance) and 3/2025 (models and thresholds).")),
      bslib::accordion(
        id = "design_guide", open = "g1", multiple = FALSE,
        step(1, "Assessment data", "the survey the card is learned from",
             tagList("Load the needs-assessment survey (EFSA, VAM, CFSVA or similar): one row per household, with a food-security ",
                     "outcome and the candidate criteria. Create missing variables with the ", tags$em("Variable calculator"),
                     " (conditions, formulas, bulk yes/no, or pasted R code)."),
             "The file is read into memory and checked (rows, columns, types). Calculated variables are added to it and recorded with their definition, so the report shows exactly how each was built.",
             "The card can only be as good as the data it learns from: the assessment must cover the population the card will be applied to, with the same questions the registration will ask.",
             "Excel, SPSS, Stata, CSV (data.table, multi-threaded) or Parquet. Formulas and R code are parsed and checked against a whitelist of functions before they run; nothing can reach files, the network or other code.",
             "WFP (2021) Targeting and Prioritisation Operational Guidance Note, ch. 4.",
             "Save the session once the data is loaded: sessions keep the data, every model run and the adopted card."),
        step(2, "Vulnerability Framework", "what 'vulnerable' means for this card",
             "Choose the outcome variable (for example CARI food insecure, or a two-level FCS/rCSI class) and the level that means vulnerable. The share of vulnerable households is shown straight away.",
             "The outcome is recoded to 1 (vulnerable) and 0 (not). Every later statistic, model and error rate is computed against it.",
             "Outcome indicators are what the criteria must stand for; they are never used as criteria themselves (Advisory 1/2025). A very unbalanced outcome (under 5% or over 95% vulnerable) is flagged: no card can separate households that barely differ.",
             "Binary recoding of any categorical or numeric column; missing outcomes are left out of every estimate. Likely outcome columns (CARI, FCS, rCSI, LCSI) are listed first.",
             "WFP (2021) CARI Technical Guidance; Targeting Advisory 1/2025.",
             "If the outcome has more than two levels, build the two-level version with the calculator and document the cut in its name."),
        step(3, "Criteria Screening", "which variables of the data point to vulnerability, and which repeat each other",
             "Right after the vulnerability framework, every yes/no variable of the data is compared with it, before any criterion is chosen. Read each variable's prevalence, its share among vulnerable and other households and the plain-language reading; optionally run Quick screening; tick the promising ones, click Select, review the correlation matrix and the statistics, drop the ones that repeat each other and continue. Variables with several answers or numbers get a suggested yes/no version at the top of the step: create the ones you want and they join the screening.",
             tagList("Suggestions: for a variable with 3 to 15 answers, the answers where vulnerability is above average become 'yes'; for a number, every cut-off between the 10th and 90th percentiles is tried and the one with the largest gap in vulnerability is kept, each side holding at least 5% of the households (whole numbers keep a whole cut-off). They are built by the variable calculator and listed with the calculated variables. ",
                     "Quick screening tests each criterion alone against the outcome and reports its odds ratio, adjusted p-value and a verdict. ",
                     "The correlation matrix shows pairs of criteria that say the same thing; one of each pair above the cut-off is proposed for dropping."),
             "Looking at all the data first avoids missing a strong criterion hidden in a variable nobody thought to binarise, and gives cut-offs an evidence base. A criterion met by almost everyone (or no one) separates nobody; two criteria that repeat each other split one effect into two weights and count it twice in the score.",
             tagList("Suggestions: 2x2 comparison with the outcome (share, vulnerability if yes and if no, gap in points, odds ratio with a 0.5 continuity correction, chi-square p-value). ",
                     "Quick screening: likelihood-ratio test of a one-criterion logistic model, or Fisher's exact test on the 2x2 table when that model cannot be estimated; ",
                     "p-values adjusted by Benjamini-Hochberg (false discovery rate), Holm or Bonferroni; odds ratios with Wald 95% intervals (Haldane correction for empty cells). ",
                     "Overlap: phi coefficients on complete pairs; pairs at or above |r| = 0.8 flagged, dropping the member with the larger mean absolute correlation (as caret::findCorrelation)."),
             "Benjamini & Hochberg (1995) JRSS B 57(1); Holm (1979) Scand. J. Stat. 6(2); Agresti (2013) Categorical Data Analysis, 3rd ed.; Targeting OGN (2021) ch. 5.",
             "A suggested cut-off is a starting point: it must still make sense on the ground and be verifiable at registration. A criterion with no clear association on its own can still matter next to others: keep what field knowledge supports and let the model decide the net weights."),
        step(4, "Criteria Selection", "what goes to the model",
             "Confirm the criteria that go to the model: those kept at the screening come pre-selected; add or remove any. Only criteria a registration team can observe and verify belong here.",
             "Each criterion is turned into 0/1. Columns that are outcome indicators, identifiers, constants or not yes/no are blocked with the reason.",
             "Criteria that cannot be observed at registration, or that households can easily misreport, make a card that is gamed or unfair. Fewer, stronger criteria make a card communities can understand.",
             "Binarisation of text and numeric answers (yes/no, 1/0, true/false in several languages). Blocking rules are listed next to the picker.",
             "Targeting OGN (2021) ch. 5; UNHCR-WFP Joint Programme Excellence and Targeting Hub, targeting toolkit.",
             "Use the calculator's bulk mode to turn a block of asset questions into yes/no criteria in one go."),
        step(5, "Model and weights", "how much each criterion points to vulnerability",
             "Choose a model, a weighting scheme, a hold-out share and, if wanted, stepwise selection (AIC or BIC). Choose which other models to compare. Fit, compare runs, and edit any weight local knowledge disputes.",
             tagList("The model estimates each criterion's effect on the odds of being vulnerable, net of the others; the weighting scheme turns effects into points. ",
                     "Every model gives an additive card, so a field team can apply it and a community can check it. Each fit is kept in the run history and can be restored."),
             "Weights set by a model on real data are defensible; weights set by hand are not, unless the reason is recorded. The hold-out keeps the accuracy figures honest.",
             tagList("Logistic regression (maximum likelihood, Wald SEs); weight of evidence (log odds ratio per criterion, Haldane correction); boosted stumps (XGBoost, depth 1, exactly additive); ",
                     "random forest, XGBoost, naive Bayes, SVM, neural network, whose points are average marginal effects on the log-odds scale. ",
                     "Stepwise: backward elimination on a logistic fit by AIC = 2k - 2 log L or BIC = k log n - 2 log L, then the chosen model on what remains. ",
                     "Points: odds ratio (APP-FA reference), log-odds, integer points or equal weights. Stratified seeded hold-out; survey weights normalised to a mean of 1."),
             "Hosmer, Lemeshow & Sturdivant (2013) Applied Logistic Regression; Siddiqi (2017) Intelligent Credit Scoring; Breiman (2001) Machine Learning 45; Chen & Guestrin (2016) KDD; Molnar (2022) Interpretable Machine Learning; Targeting Advisory 3/2025.",
             "Compare the card's held-out AUC with the random-forest benchmark: if the forest barely beats it, the simple card loses little."),
        step(6, "Threshold and design errors", "who is eligible, and how wrong that is",
             "Set the score above which a household is eligible, read the inclusion and exclusion errors against your tolerance band, and record the rationale for the choice.",
             tagList("Inclusion error: selected households that are not vulnerable, over all selected. Exclusion error: vulnerable households left out, over all vulnerable. ",
                     "Both come from the design error matrix, measured on the held-out households the model never saw."),
             "Every threshold trades one error for the other. The tolerance band and the rationale make that trade-off explicit and reviewable (Advisory 2/2025); in emergencies the OGN gives priority to reducing exclusion.",
             "Helpers: the balanced threshold (minimises the larger of the two errors), Youden's J (maximises recall minus false-positive rate), or a caseload (the top k% of scores). ROC curve and AUC; the verdict compares both errors with the band.",
             "Targeting Advisory 2/2025; Youden (1950) Cancer 3(1); Fawcett (2006) Pattern Recognition Letters 27(8).",
             "Write the rationale before adopting: it is printed in the design report and is required by Advisory 2/2025."),
        step(7, "Adoption and report", "what Beneficiary Selection will apply",
             "Adopt the card to make it the one Beneficiary Selection uses, then export the design report (HTML), the scorecard (Excel) and its JSON for other tools.",
             "Adoption freezes this exact design: criteria, points and threshold. Any later change withdraws the adoption until the card is adopted again, and the audit trail records both.",
             "The list is only as accountable as its card: a card that changed after approval must never select households silently.",
             "The design report is one self-contained HTML file (charts inlined, works offline): data, outcome, criteria, selection, model, points, threshold, errors, verdict and methods. The scorecard is fingerprinted to detect any change.",
             "Targeting OGN (2021) ch. 6 (documentation and accountability).",
             "Share the design report with the targeting committee before adopting; it is written to be read by non-statisticians.")
      )
    )
  )
}
