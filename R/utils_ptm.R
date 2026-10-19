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
    el_w <- sum(ww[e]); re_w <- sum(ww[e & s])
    data.frame(area = u, n_selected = ns, n_not = nn, eligible = el_w, reached = re_w,
               coverage = if (el_w > 0) re_w / el_w else NA_real_, inclusion_error = incl, exclusion_error = excl,
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
  # the size of the household's group travels with it: a survey that keeps
  # these columns is enough on its own to weight the errors
  N <- d$design$N[match(paste(r$area, r$group), paste(d$design$area, d$design$group))]
  out <- data.frame(household_id = as.character(df[[id_col]][r$row]),
                    eligibility = ifelse(r$group == "selected", "Eligible", "Not eligible"),
                    sample_area = r$area, sample_group_size = N, df[r$row, keep, drop = FALSE],
                    check.names = FALSE, stringsAsFactors = FALSE)
  rownames(out) <- NULL
  main <- r$role == "main"
  # rep(): no replacements drawn (reserve 0) gives a list with no rows
  list(main = cbind(out[main, , drop = FALSE], `Interview status` = rep(NA_character_, sum(main))),
       replacements = cbind(replacement_order = r$order[!main], out[!main, , drop = FALSE],
                            `Replaces household_id` = rep(NA_character_, sum(!main))))
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
      paste("The questions needed to apply the eligibility criteria (the scorecard or the rules), and the outcome (CARI...).",
            "Keep household_id, eligibility, sample_area and sample_group_size in the survey, as they are (preload them in the form):",
            "the survey data alone is then enough to compute the errors."),
      paste("In Targeting Monitoring > Implementation errors: load the survey data (step 1); it carries the sample, so there is nothing to upload.",
            "If the survey lost those columns, upload THIS workbook in step 2 (From the sample list) and choose the survey's household ID column."),
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
  grp <- ptm_group(lst$eligibility)
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

#' "Selected" / "Not selected" from the sample list's eligibility column
#' @noRd
ptm_group <- function(x) {
  el <- tolower(trimws(as.character(x)))
  ifelse(el %in% c("eligible", "selected"), "Selected", ifelse(el %in% c("not eligible", "not selected"), "Not selected", NA))
}

#' The sample design read from the survey itself
#'
#' A survey that kept the sample list's columns (household_id, eligibility,
#' sample_area and sample_group_size, preloaded in the form) carries all the
#' sample list did: each household's group and area, and the size of its
#' group for the weights. Columns are found under a form's group path too.
#' @return A `ptm_read_sample()`-shaped design, or NULL when the survey does
#'   not carry them (`design` is NULL without sample_group_size).
#' @noRd
ptm_survey_design <- function(df) {
  if (is.null(df) || !nrow(df)) return(NULL)
  base <- tolower(sub(".*[/.]", "", names(df)))
  col <- function(k) { i <- which(base == k); if (length(i)) names(df)[i[1]] }
  id <- col("household_id"); el <- col("eligibility"); ar <- col("sample_area"); gs <- col("sample_group_size")
  if (is.null(id) || is.null(el) || is.null(ar)) return(NULL)
  grp <- ptm_group(df[[el]])
  if (!any(!is.na(grp))) return(NULL)
  area <- as.character(df[[ar]]); area[is.na(area) | !nzchar(trimws(area))] <- "(missing)"
  design <- if (!is.null(gs)) {
    N <- as_number(df[[gs]]); ok <- !is.na(grp) & !is.na(N)
    key <- unique(data.frame(area = area[ok], group = ifelse(grp[ok] == "Selected", "selected", "not_selected"), stringsAsFactors = FALSE))
    if (nrow(key)) {
      key$N <- vapply(seq_len(nrow(key)), function(i) {
        m <- ok & area == key$area[i] & (grp == "Selected") == (key$group[i] == "selected")
        max(N[m])
      }, numeric(1))
      key$n <- vapply(seq_len(nrow(key)), function(i) sum(ok & area == key$area[i] & (grp == "Selected") == (key$group[i] == "selected")), numeric(1))
      key$reserve <- 0
      key
    }
  }
  lst <- data.frame(household_id = trimws(as.character(df[[id]])), eligibility = df[[el]], sample_area = area, stringsAsFactors = FALSE)
  list(list = lst, group = grp, area = area, design = design, id_col = id, level = "sample_area", drawn_at = "",
       kind = NA_character_, file = "", from_survey = TRUE)
}

#' The Implementation errors workbook, laid out as the page
#'
#' Summary (survey, sources, tolerance band, results), Matrix (assistance x
#' eligibility, estimated households, each cell's rate and households
#' surveyed, errors coloured by the band) and one sheet per area level
#' (decision and coverage by area, errors coloured by the band).
#' @param r `results()` of `mod_pdm_server()` (NULL: a one-line workbook).
#' @param tol Lower and upper tolerance (shares).
#' @param meta Named character: extra Survey fields.
#' @noRd
pdm_workbook <- function(r, tol = c(0.05, 0.20), meta = character(0)) {
  wb <- openxlsx::createWorkbook()
  if (is.null(r)) {
    xl_data_sheet(wb, "Summary", data.frame(Message = "No analysis has been run."))
    return(wb)
  }
  m <- r$metrics
  pc <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  band <- function(v) if (is.null(v) || is.na(v)) "na" else if (v <= tol[1]) "good" else if (v <= tol[2]) "review" else "bad"
  band_txt <- c(good = "within the tolerance band", review = "in the review band", bad = "beyond the tolerance band", na = "not measured")
  colour <- c(good = "#3F7E44", review = "#A87400", bad = "#C5192D", na = "#5B6B7E")
  err <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%s (%s)", pc(v), band_txt[[band(v)]])
  before <- !identical(r$kind, "PDM")

  xl_summary_sheet(wb, "Summary", "Implementation errors",
    if (before) "Post-targeting survey / baseline (before distribution)" else "Post-distribution monitoring (after distribution)",
    list(
      Survey = c(meta, `Records analysed` = format(r$n, big.mark = ","),
                 `Records with known eligibility` = format(r$n_known, big.mark = ",")),
      `Who was selected and who should have been` = c(`Assistance received from` = r$benef_col %||% "",
                                                     `Eligibility from` = r$elig_source %||% r$elig_col %||% "",
                                                     Weighting = r$weighting %||% "none"),
      `Tolerance band` = c(Lower = pc(tol[1]), Upper = pc(tol[2]),
                           Reading = "Errors up to the lower value are acceptable; above the upper one the targeting must be revisited (Targeting Advisory 2/2025)."),
      Results = c(`Inclusion error (assisted but not eligible / all assisted)` = err(m$inclusion_error),
                  `Exclusion error (eligible but not assisted / all eligible)` = err(m$exclusion_error),
                  `Coverage (recall): eligible reached / all eligible` = pc(m$coverage_rate),
                  `Precision: eligible among the assisted` = pc(m$precision),
                  `Excluded by design (eligible, not prioritised)` = if (is.null(r$excl_design)) "no prioritised column mapped" else
                    sprintf("%s households surveyed (%s of eligible), left out of the errors", format(r$excl_design$n, big.mark = ","),
                            pc(r$excl_design$share)),
                  Note = if (isTRUE(r$no_nonbenef)) "Only beneficiaries were surveyed: the exclusion error and the coverage cannot be measured.")))

  # the matrix, as on the page
  mx <- r$matrix
  if (!is.null(mx)) {
    sh <- "Matrix"
    openxlsx::addWorksheet(wb, sh, gridLines = FALSE)
    st <- function(..., fontSize = 10) openxlsx::createStyle(fontSize = fontSize, ...)
    put <- function(x, row, col, style = NULL) {
      openxlsx::writeData(wb, sh, x, startRow = row, startCol = col, colNames = FALSE)
      if (!is.null(style)) openxlsx::addStyle(wb, sh, style, rows = row, cols = col, stack = TRUE)
    }
    na <- isTRUE(r$no_nonbenef)
    rowA <- mx$correct_in + mx$incl; rowN <- mx$excl + mx$correct_out
    colE <- mx$correct_in + mx$excl; colN <- mx$incl + mx$correct_out
    put("Eligibility vs. assistance received (estimated households)", 1, 1, openxlsx::createStyle(fontSize = 14, textDecoration = "bold", fontColour = "#007DBC"))
    put(sprintf("Weighting: %s. Each cell: estimated households, its rate, and the households surveyed in it.", r$weighting %||% "none"), 2, 1, st(fontColour = "#5B6B7E"))
    head <- st(textDecoration = "bold", fontColour = "#FFFFFF", fgFill = "#007DBC", halign = "center", valign = "center")
    for (j in 1:4) put(c("Assistance (rows) / eligibility (columns)", "Eligible", "Not eligible", "Total")[j], 4, j, head)
    # one cell = three rows: count, rate and name, households surveyed
    cell <- function(row, col, x, ns, d, label, of, error = FALSE) {
      if (na && is.null(x)) {
        put("n/a", row, col, st(textDecoration = "bold", halign = "center"))
        put("no non-beneficiaries surveyed", row + 1, col, st(fontColour = "#5B6B7E", halign = "center"))
        return()
      }
      v <- if (d > 0) x / d else NA
      put(round(x), row, col, st(textDecoration = "bold", fontSize = 14, halign = "center", numFmt = "#,##0"))
      put(sprintf("%s %s - %s", pc(v), of, label), row + 1, col,
          st(halign = "center", fontColour = if (error) colour[[band(v)]] else "#222222", textDecoration = if (error) "bold" else NULL))
      put(sprintf("%s surveyed", format(ns, big.mark = ",")), row + 2, col, st(fontColour = "#5B6B7E", halign = "center"))
    }
    put("Assisted", 5, 1, st(textDecoration = "bold", valign = "center"))
    cell(5, 2, mx$correct_in, mx$n_correct_in, colE, "correctly included", "of the eligible")
    cell(5, 3, mx$incl, mx$n_incl, rowA, "inclusion error", "of the assisted", TRUE)
    put(round(rowA), 5, 4, st(halign = "center", numFmt = "#,##0"))
    put("Not assisted", 8, 1, st(textDecoration = "bold", valign = "center"))
    cell(8, 2, if (na) NULL else mx$excl, mx$n_excl, colE, "exclusion error", "of the eligible", TRUE)
    cell(8, 3, if (na) NULL else mx$correct_out, mx$n_correct_out, colN, "correctly excluded", "of the not eligible")
    put(if (na) "n/a" else round(rowN), 8, 4, st(halign = "center", numFmt = "#,##0"))
    tot <- st(textDecoration = "bold", halign = "center", numFmt = "#,##0", border = "top", borderColour = "#085387")
    put("Total", 11, 1, st(textDecoration = "bold", border = "top", borderColour = "#085387"))
    put(if (na) "n/a" else round(colE), 11, 2, tot)
    put(if (na) "n/a" else round(colN), 11, 3, tot)
    put(round(if (na) rowA else rowA + rowN), 11, 4, tot)
    openxlsx::addStyle(wb, sh, openxlsx::createStyle(border = "bottom", borderColour = "#DFE6EE"), rows = c(7, 10), cols = 1:4, gridExpand = TRUE, stack = TRUE)
    notes <- c(sprintf("Inclusion error = assisted but not eligible / all assisted; exclusion error = eligible but not assisted / all eligible (Targeting Advisory 2/2025, p. 6). Error rates against the tolerance band of %s-%s: green within it, amber to review, red above it.",
                       pc(tol[1]), pc(tol[2])),
               if (!is.null(r$excl_design)) sprintf("Households excluded by design (eligible, not prioritised): %s surveyed, left out of the table.", format(r$excl_design$n, big.mark = ",")))
    for (i in seq_along(notes)) put(notes[i], 12 + i, 1, st(fontColour = "#5B6B7E", wrapText = TRUE))
    for (i in seq_along(notes)) openxlsx::mergeCells(wb, sh, cols = 1:4, rows = 12 + i)
    openxlsx::setRowHeights(wb, sh, rows = 12 + seq_along(notes), heights = 42)
    openxlsx::setColWidths(wb, sh, cols = 1:4, widths = c(30, 34, 34, 14))
  }

  # decision and coverage by area, one sheet per level
  levels <- r$by_level %||% (if (!is.null(r$decisions)) list(list(label = r$unit_col %||% "Area", rows = r$decisions)))
  used <- names(wb)
  for (lv in levels) {
    dd <- lv$rows
    if (is.null(dd) || !nrow(dd)) next
    nm <- substr(gsub("[\\[\\]:*?/\\\\]", "", paste("Areas -", sub(".* \u00b7 ", "", lv$label)), perl = TRUE), 1, 31)
    while (nm %in% used) nm <- paste0(substr(nm, 1, 29), "_", length(used))
    used <- c(used, nm)
    df <- data.frame(Area = dd$area, `Selected surveyed` = dd$n_selected, `Not selected surveyed` = dd$n_not,
                     `Eligible (est.)` = round(dd$eligible), `Reached (est.)` = round(dd$reached), Coverage = dd$coverage,
                     `Inclusion error` = dd$inclusion_error, `Exclusion error` = dd$exclusion_error, Decision = dd$decision,
                     check.names = FALSE, stringsAsFactors = FALSE)
    xl_data_sheet(wb, nm, df)
    rows <- seq_len(nrow(df)) + 1
    openxlsx::addStyle(wb, nm, openxlsx::createStyle(numFmt = "0.0%"), rows = rows, cols = 6:8, gridExpand = TRUE, stack = TRUE)
    openxlsx::addStyle(wb, nm, openxlsx::createStyle(numFmt = "#,##0"), rows = rows, cols = 2:5, gridExpand = TRUE, stack = TRUE)
    for (k in names(colour)) {
      s_k <- openxlsx::createStyle(fontColour = colour[[k]], textDecoration = "bold")
      for (j in 7:8) {
        i <- which(vapply(df[[j]], band, character(1)) == k & k != "na")
        if (length(i)) openxlsx::addStyle(wb, nm, s_k, rows = i + 1, cols = j, stack = TRUE)
      }
    }
    dcol <- c(redesign = "#C5192D", review = "#A87400", good = "#3F7E44")
    for (k in names(dcol)) {
      i <- which(dd$level == k)
      if (length(i)) openxlsx::addStyle(wb, nm, openxlsx::createStyle(fontColour = dcol[[k]], textDecoration = "bold"), rows = i + 1, cols = 9, stack = TRUE)
    }
    openxlsx::setColWidths(wb, nm, cols = 9, widths = 60)
  }
  wb
}
