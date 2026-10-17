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

#' The columns that let a field team find a household: identifier, areas,
#' names, sex, age and size of the household, phone numbers, GPS
#' @noRd
ptm_identity_cols <- function(df, settings) {
  col <- function(k) { v <- as.character(settings[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v) && v %in% names(df)) v }
  base <- unlist(lapply(c("unique_id", names(AREA_LEVELS)), col))
  used <- unlist(lapply(c("enumerator_id", "date", "weight", "v_score", "v_groups", "eligibility", "phone_avail"), col))
  free <- setdiff(names(df), c(base, used))
  free <- free[!grepl("^@?_", free) & !grepl("enum|agent|surveyor|interview|supervis|admin|village|site", free, ignore.case = TRUE)]
  who <- grep("name|nom|prenom|surname", free, ignore.case = TRUE, value = TRUE)
  # a "has a phone" yes/no column is not a number to call
  phones <- Filter(function(p) {
    d <- gsub("[^0-9]", "", as.character(utils::head(stats::na.omit(df[[p]]), 200)))
    length(d) > 0 && mean(nchar(d) >= 8) > 0.5
  }, grep("phone|tel|mobile|portable|contact", free, ignore.case = TRUE, value = TRUE))
  bio <- unlist(lapply(c("hhh_sex", "hhh_age", "hh_size", "residency"), col))
  gps <- unlist(lapply(c("lat", "lon"), col))
  unique(c(base, utils::head(who, 3), bio, utils::head(phones, 2), gps))
}

#' The lists the field team takes: the households to survey and, apart, the
#' replacements, each with its eligibility and what is needed to find it
#' @param d A `ptm_draw()` result on the rows of `df`.
#' @noRd
ptm_sample_lists <- function(df, d, settings) {
  id_col <- as.character(settings$unique_id)[1]
  keep <- setdiff(ptm_identity_cols(df, settings), id_col)
  r <- d$rows
  out <- data.frame(household_id = as.character(df[[id_col]][r$row]),
                    eligibility = ifelse(r$group == "selected", "Eligible", "Not eligible"),
                    sample_area = r$area, df[r$row, keep, drop = FALSE],
                    check.names = FALSE, stringsAsFactors = FALSE)
  rownames(out) <- NULL
  main <- r$role == "main"
  list(main = cbind(out[main, , drop = FALSE], `Interview status` = NA_character_),
       replacements = cbind(replacement_order = r$order[!main], out[!main, , drop = FALSE],
                            `Replaces household_id` = NA_character_))
}

#' The sample as a read-only workbook: how to use it, the households to
#' survey, the replacements, the design (for the weights) and the settings.
#' Targeting Monitoring reads it back with `ptm_read_sample()`.
#' @noRd
ptm_sample_workbook <- function(lists, design, meta = list(), kind = "Baseline") {
  pdm <- identical(kind, "PDM")
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "How to use")
  guide <- data.frame(
    Step = c("What this is", "Who to visit", "Replacements", "What to ask", "After the survey", "When"),
    Explanation = c(
      paste("A random sample of the households the targeting found eligible and of those it found not eligible, drawn area by area,",
            "to measure implementation errors (inclusion and exclusion errors)."),
      "Visit every household of the Sample sheet. Do not tell the households which group they are in.",
      paste("If a household cannot be found, has moved or refuses, take the next household of the Replacements sheet with the SAME",
            "sample_area and eligibility, in replacement_order, and write the household it replaces in 'Replaces household_id'."),
      paste("The questions needed to apply the eligibility criteria (the scorecard or the rules), and the household_id,",
            "so each interview can be matched back to this list."),
      paste("In Targeting Monitoring > Implementation errors: load the survey data (step 1), then upload THIS workbook in step 2",
            "(From the sample list) and choose the survey's household ID column. Keep the workbook as it is: the Design sheet gives the weights."),
      if (pdm) "After the distribution (PDM): errors found become lessons for the next round."
      else "Before the distribution: errors found can still be fixed (review the list of an area, or pause its distribution)."),
    stringsAsFactors = FALSE)
  write_data(wb, "How to use", guide)
  openxlsx::setColWidths(wb, "How to use", cols = 1:2, widths = c(22, 110))
  openxlsx::addStyle(wb, "How to use", openxlsx::createStyle(wrapText = TRUE, valign = "top"), rows = 2:(nrow(guide) + 1), cols = 2, gridExpand = TRUE)
  xl_data_sheet(wb, "Sample", sanitize_for_excel(lists$main))
  xl_data_sheet(wb, "Replacements", sanitize_for_excel(lists$replacements))
  d <- design
  d$group <- ifelse(d$group == "selected", "Eligible", "Not eligible")
  names(d) <- c("Area", "Eligibility", "Households in the group", "To survey", "Replacements")
  xl_data_sheet(wb, "Design", d)
  if (length(meta)) {
    openxlsx::addWorksheet(wb, "Settings")
    write_data(wb, "Settings", data.frame(Field = names(meta), Value = vapply(meta, function(v) paste(v, collapse = ", "), ""),
                                          stringsAsFactors = FALSE))
    openxlsx::setColWidths(wb, "Settings", cols = 1:2, widths = c(34, 80))
  }
  wb
}

#' Read a sample workbook back (Targeting Monitoring, step 2)
#'
#' The Sample and Replacements sheets give each household its group and
#' area, the Design sheet the size of each group (the weights).
#' @return The sample design: list(list, group ("Selected" / "Not selected"),
#'   area, design, id_col, level, drawn_at, kind, file).
#' @noRd
ptm_read_sample <- function(path, name = basename(path)) {
  sheets <- readxl::excel_sheets(path)
  rd <- function(s) as.data.frame(readxl::read_excel(path, sheet = s, col_types = "text"), stringsAsFactors = FALSE)
  lst <- rd(if ("Sample" %in% sheets) "Sample" else sheets[1])
  if ("Replacements" %in% sheets) {
    r <- rd("Replacements"); common <- intersect(names(lst), names(r))
    lst <- rbind(lst[common], r[common])
  }
  if (!all(c("household_id", "eligibility") %in% names(lst)))
    stop("this is not a sample list drawn in Beneficiary Selection (it needs the columns household_id and eligibility)")
  lst <- lst[!is.na(lst$household_id) & nzchar(trimws(lst$household_id)), , drop = FALSE]
  lst$household_id <- trimws(lst$household_id)
  el <- tolower(trimws(lst$eligibility))
  grp <- ifelse(el %in% c("eligible", "selected"), "Selected", ifelse(el %in% c("not eligible", "not selected"), "Not selected", NA))
  design <- if ("Design" %in% sheets) {
    ds <- rd("Design")
    data.frame(area = ds[[1]], group = ifelse(tolower(trimws(ds[[2]])) %in% c("eligible", "selected"), "selected", "not_selected"),
               N = as_number(ds[[3]]), n = as_number(ds[[4]]), reserve = as_number(ds[[5]]), stringsAsFactors = FALSE)
  }
  meta <- if ("Settings" %in% sheets) { s <- rd("Settings"); stats::setNames(as.character(s[[2]]), s[[1]]) } else character(0)
  m <- function(k) if (k %in% names(meta) && !is.na(meta[[k]])) meta[[k]] else ""
  level <- m("Areas by"); if (grepl("^one group", level)) level <- ""
  list(list = lst, group = grp, area = if ("sample_area" %in% names(lst)) lst$sample_area else rep("All", nrow(lst)),
       design = design, id_col = if (nzchar(m("Household ID column"))) m("Household ID column") else "household_id",
       level = level, drawn_at = m("Drawn at"), kind = if (grepl("^PDM", m("Survey"))) "PDM" else "Baseline", file = name)
}
