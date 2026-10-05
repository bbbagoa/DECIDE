#' Post-targeting monitoring: the verification sample and decisions by area
#'
#' Implementation errors are best measured after the selection and BEFORE the
#' distribution, on a sample of selected and non-selected households
#' (a post-targeting monitoring survey, or a baseline). Problems then show
#' while they can still be fixed: the list of an area can be reviewed, or its
#' distribution paused. A post-distribution monitoring survey remains possible
#' but comes too late to change anything, and by then vulnerability may have
#' moved and the assistance itself may have changed the answers to some
#' criteria (assets bought, debts paid).
#' @name ptm
#' @noRd
NULL

#' Households to survey in a group: a proportion estimated within a margin of
#' error, with the finite-population correction (p = 0.5 is the safe choice)
#' @noRd
ptm_sample_size <- function(N, margin = 0.10, conf = 0.95, p = 0.5) {
  z <- stats::qnorm(1 - (1 - conf) / 2)
  n0 <- z^2 * p * (1 - p) / margin^2
  pmin(N, ceiling(n0 / (1 + (n0 - 1) / pmax(N, 1))))
}

#' Draw the verification sample from a selection
#'
#' Stratified by area and by group: selected households (served) and
#' households judged not eligible. Households excluded by design (eligible
#' but cut by prioritisation) are not errors and are left out of the frame.
#' Each stratum gets its own simple random sample, plus a reserve list to
#' replace households that cannot be found.
#' @param status "selected", "not_selected" or "by_design", one per household.
#' @param area Area of each household (NULL: one stratum per group).
#' @param size list(mode = "margin" | "fixed", margin, n).
#' @param reserve Share of extra households drawn as replacements.
#' @return list(rows = data.frame(row, area, group, role, order),
#'   design = data.frame(area, group, N, n, reserve)).
#' @noRd
ptm_draw <- function(status, area = NULL, size = list(mode = "margin", margin = 0.10), reserve = 0.10, seed = 123) {
  n_hh <- length(status)
  area <- if (is.null(area)) rep("All", n_hh) else { a <- as.character(area); a[is.na(a) | !nzchar(trimws(a))] <- "(missing)"; a }
  keep <- status %in% c("selected", "not_selected")
  strata <- split(which(keep), list(area[keep], status[keep]), drop = TRUE)
  set.seed(seed)
  rows <- list(); design <- list()
  for (k in names(strata)) {
    idx <- strata[[k]]; N <- length(idx)
    n <- if (identical(size$mode, "fixed")) min(N, as.integer(size$n)) else ptm_sample_size(N, size$margin %||% 0.10)
    r <- min(N - n, ceiling(n * reserve))
    pick <- if (length(idx) > 1) idx[sample.int(N, n + r)] else idx[seq_len(n + r)]
    a <- area[idx[1]]; g <- status[idx[1]]
    rows[[k]] <- data.frame(row = pick, area = a, group = g,
                            role = c(rep("main", n), rep("reserve", r)),
                            order = c(seq_len(n), seq_len(r)), stringsAsFactors = FALSE)
    design[[k]] <- data.frame(area = a, group = g, N = N, n = n, reserve = r, stringsAsFactors = FALSE)
  }
  rows <- do.call(rbind, rows); design <- do.call(rbind, design)
  rownames(rows) <- NULL; rownames(design) <- NULL
  design <- design[order(design$area, design$group != "selected"), , drop = FALSE]
  list(rows = rows, design = design)
}

#' Population sizes per area from a sample design, in the shape
#' `pdm_stratum_weights()` takes (unit, beneficiaries, non_beneficiaries)
#' @noRd
ptm_population <- function(design) {
  areas <- unique(design$area)
  N <- function(a, g) { v <- design$N[design$area == a & design$group == g]; if (length(v)) v[1] else 0 }
  data.frame(unit = areas,
             beneficiaries = vapply(areas, N, numeric(1), g = "selected"),
             non_beneficiaries = vapply(areas, N, numeric(1), g = "not_selected"),
             stringsAsFactors = FALSE)
}

#' Implementation errors and a decision for each area
#'
#' The Targeting Advisory 2/2025 decision table, applied area by area. Before
#' the distribution the decision can still be acted on: proceed, review the
#' list first, or pause the distribution there. Areas with fewer than
#' `min_n` surveyed households in either group are not judged.
#' @param selected,eligible Logical per surveyed household.
#' @param w Weights (population / surveyed in the household's group).
#' @param before TRUE for a survey before the distribution (decisions), FALSE
#'   for a PDM (lessons for the next round).
#' @return data.frame(area, n_selected, n_not, inclusion_error, exclusion_error,
#'   level, decision), worst first.
#' @noRd
ptm_area_decisions <- function(selected, eligible, area, w = NULL, lower = 0.05, upper = 0.20,
                               min_n = 30, before = TRUE) {
  if (is.null(w)) w <- rep(1, length(selected))
  a <- as.character(area); a[is.na(a) | !nzchar(trimws(a))] <- "(missing)"
  out <- lapply(sort(unique(a)), function(u) {
    m <- which(a == u & !is.na(selected) & !is.na(eligible))
    s <- selected[m]; e <- eligible[m]; ww <- w[m]
    ns <- sum(s); nn <- sum(!s)
    incl <- if (sum(ww[s]) > 0) sum(ww[s & !e]) / sum(ww[s]) else NA_real_
    excl <- if (sum(ww[e]) > 0) sum(ww[e & !s]) / sum(ww[e]) else NA_real_
    few <- ns < min_n || nn < min_n
    lvl <- if (few) "few" else tryCatch(implementation_verdict(incl, excl, lower, upper)$level,
                                        error = function(err) "unknown")
    if (!few && (is.na(incl) || is.na(excl))) lvl <- "unknown"
    data.frame(area = u, n_selected = ns, n_not = nn, inclusion_error = incl, exclusion_error = excl,
               level = lvl, decision = ptm_decision(lvl, before), stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, out)
  ord <- match(out$level, c("redesign", "review", "unknown", "few", "good"))
  out <- out[order(ord, -pmax(out$inclusion_error, out$exclusion_error, na.rm = TRUE)), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' What to do in an area, from its verdict level
#' @noRd
ptm_decision <- function(level, before = TRUE) {
  if (before) switch(level,
    good = "Proceed with the distribution",
    review = "Review the list before distributing (verify the households in error)",
    redesign = "Pause the distribution here: re-verify the list, or re-run the targeting",
    few = "Too few households surveyed to judge: survey more before deciding",
    "Not enough data to judge")
  else switch(level,
    good = "No change needed next round",
    review = "Review the list and the process before the next round",
    redesign = "Re-run the targeting here before the next round",
    few = "Too few households surveyed to judge",
    "Not enough data to judge")
}

#' The verification sample as a read-only workbook: the list to visit (main
#' and reserve), the design, and how to use it
#' @noRd
ptm_sample_workbook <- function(sample_df, design, meta = list()) {
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "How to use")
  guide <- data.frame(
    Step = c("What this is", "Who to visit", "Replacements", "What to ask", "After the survey", "Why before distribution"),
    Explanation = c(
      "A random sample of the households the targeting selected and of those it did not select, drawn area by area, to measure implementation errors before any assistance is distributed.",
      "Visit every household of the Sample sheet with role 'main'. Do not tell the enumerators or the households which group a household is in.",
      "If a main household cannot be found or refuses, replace it with the next 'reserve' household of the SAME area and group, in order, and record the replacement.",
      "The questions needed to apply the eligibility criteria (the scorecard or the rules) and the household identifier (column 'household_id'), so each interview can be matched back to this list.",
      "Load the survey in Targeting Monitoring (Post-targeting survey), match it on household_id: the group comes from this list and each household is weighted by the size of its group in its area (Design sheet).",
      "Errors found now can still be fixed: review the list of an area, or pause its distribution. After distribution nothing can be undone, and the assistance itself may change the answers."),
    stringsAsFactors = FALSE)
  write_data(wb, "How to use", guide)
  openxlsx::setColWidths(wb, "How to use", cols = 1:2, widths = c(26, 110))
  openxlsx::addStyle(wb, "How to use", openxlsx::createStyle(wrapText = TRUE, valign = "top"), rows = 2:(nrow(guide) + 1), cols = 2, gridExpand = TRUE)
  openxlsx::addWorksheet(wb, "Sample")
  write_data(wb, "Sample", sample_df)
  openxlsx::freezePane(wb, "Sample", firstRow = TRUE)
  openxlsx::setColWidths(wb, "Sample", cols = seq_along(sample_df), widths = "auto")
  openxlsx::addWorksheet(wb, "Design")
  d <- design
  d$group <- ifelse(d$group == "selected", "Selected", "Not selected")
  names(d) <- c("Area", "Group", "Households in the group", "To survey", "Reserve")
  write_data(wb, "Design", d)
  openxlsx::setColWidths(wb, "Design", cols = 1:5, widths = "auto")
  if (length(meta)) {
    openxlsx::addWorksheet(wb, "Settings")
    write_data(wb, "Settings", data.frame(Field = names(meta), Value = vapply(meta, function(v) paste(v, collapse = ", "), ""),
                                          stringsAsFactors = FALSE))
    openxlsx::setColWidths(wb, "Settings", cols = 1:2, widths = c(34, 80))
  }
  wb
}
