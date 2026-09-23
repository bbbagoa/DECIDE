#' Targeting Monitoring: chart specifications and aggregation
#'
#' A chart is a small list (`spec`): what to count or measure, by what, for
#' whom. `chart_aggregate()` turns a spec and a dataset into a tidy table
#' (`x`, `group`, `value`) that the app previews with plotly and the
#' Targeting Monitoring report draws with billboarder -- one computation for
#' both, so the report shows exactly what the officer saw.
#'
#' Chart types:
#' * `count` -- number of records by `x` (and `group`)
#' * `sum`   -- total of the numeric `value` column by `x` (e.g. participants)
#' * `mean`  -- average of `value` by `x` (e.g. days to resolve a complaint)
#' * `share` -- sum of `value` over sum of `den`, in % (e.g. women among participants)
#' * `trend` -- count (or sum of `value`) per week or month of `date`
#' @name monitoring_charts
#' @noRd
NULL

#' @noRd
chart_types <- function() {
  c("Count of records" = "count", "Total of a number" = "sum", "Average of a number" = "mean",
    "Share (%) of two totals" = "share", "Trend over time" = "trend")
}

#' @noRd
chart_aggregate <- function(df, spec) {
  if (is.null(df) || !nrow(df)) return(NULL)
  has <- function(k) shiny::isTruthy(spec[[k]]) && spec[[k]] %in% names(df)
  # filter
  if (has("filter_col") && length(spec$filter_vals)) {
    df <- df[as.character(df[[spec$filter_col]]) %in% spec$filter_vals, , drop = FALSE]
  }
  if (!nrow(df)) return(NULL)
  lab <- function(v) { v <- as.character(v); v[is.na(v) | !nzchar(trimws(v))] <- "(missing)"; v }
  num <- function(k) suppressWarnings(as.numeric(as.character(df[[spec[[k]]]])))
  type <- spec$type %||% "count"

  if (identical(type, "trend")) {
    if (!has("date")) return(NULL)
    d <- suppressWarnings(as.Date(df[[spec$date]]))
    if (all(is.na(d))) d <- suppressWarnings(as.Date(lubridate::parse_date_time(as.character(df[[spec$date]]), c("Ymd", "dmY", "mdY"))))
    x <- if (identical(spec$period, "week")) format(lubridate::floor_date(d, "week", week_start = 1)) else format(d, "%Y-%m")
  } else {
    if (!has("x")) return(NULL)
    x <- lab(df[[spec$x]])
  }
  g <- if (has("group")) lab(df[[spec$group]]) else rep("All", nrow(df))
  keep <- !is.na(x)
  x <- x[keep]; g <- g[keep]
  v <- if (type %in% c("sum", "mean", "share") || (identical(type, "trend") && has("value"))) {
    if (!has("value")) return(NULL)
    num("value")[keep]
  } else rep(1, length(x))
  den <- if (identical(type, "share")) { if (!has("den")) return(NULL); num("den")[keep] } else NULL

  key <- paste(x, g, sep = "\r")
  out <- do.call(rbind, lapply(split(seq_along(x), key), function(i) {
    val <- switch(type,
                  mean = mean(v[i], na.rm = TRUE),
                  share = { dd <- sum(den[i], na.rm = TRUE); if (dd > 0) 100 * sum(v[i], na.rm = TRUE) / dd else NA_real_ },
                  sum(v[i], na.rm = TRUE))
    data.frame(x = x[i[1]], group = g[i[1]], value = val, n = length(i), stringsAsFactors = FALSE)
  }))
  if (is.null(out)) return(NULL)
  out$value <- round(out$value, 2)
  out <- if (identical(type, "trend")) out[order(out$x, out$group), , drop = FALSE] else
    out[order(-stats::ave(out$value, out$x, FUN = function(z) sum(z, na.rm = TRUE)), out$x, out$group), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' The aggregated data as a table: one row per category, one column per
#' group, with a total and (for counts and totals) each row's share
#' @noRd
chart_table <- function(d, spec) {
  first <- if (identical(spec$type, "trend")) "Period" else (spec$x %||% "Category")
  groups <- unique(d$group)
  wide <- stats::reshape(d[, c("x", "group", "value")], idvar = "x", timevar = "group", direction = "wide")
  names(wide) <- c(first, sub("^value[.]", "", names(wide)[-1]))
  additive <- (spec$type %||% "count") %in% c("count", "sum", "trend")
  if (additive) {
    wide[-1][is.na(wide[-1])] <- 0
    tot <- rowSums(wide[-1])
    if (length(groups) > 1) wide$Total <- tot
    wide[["% of total"]] <- if (sum(tot) > 0) sprintf("%.1f%%", 100 * tot / sum(tot)) else ""
    total_row <- c(list("Total"), as.list(colSums(wide[setdiff(names(wide), c(first, "% of total"))])), list("100%"))
    names(total_row) <- names(wide)
    wide <- rbind(wide, as.data.frame(total_row, check.names = FALSE, stringsAsFactors = FALSE))
  }
  if (length(groups) == 1 && groups == "All") names(wide)[names(wide) == "All"] <- chart_value_label(spec)
  rownames(wide) <- NULL
  wide
}

#' Words for the axis of a spec
#' @noRd
chart_value_label <- function(spec) {
  switch(spec$type %||% "count",
         sum = paste("Total", spec$value),
         mean = paste("Average", spec$value),
         share = sprintf("%s as %% of %s", spec$value, spec$den),
         trend = if (shiny::isTruthy(spec$value)) paste("Total", spec$value) else "Records",
         "Records")
}

#' Ready-made charts for the usual process-monitoring and PDM questions
#'
#' Each preset names the chart and says which columns it wants, as name
#' patterns; `apply_preset()` picks the first matching column of the data.
#' The officer can change any of them afterwards.
#' @noRd
chart_presets <- function() {
  list(
    `Complaints and feedback (CFM)` = list(
      cfm_type = list(label = "Complaints by type", type = "count", x = "type|categ|motif|nature|subject|topic"),
      cfm_channel = list(label = "Complaints by channel", type = "count", x = "channel|canal|mode|source"),
      cfm_status = list(label = "Complaints by status", type = "count", x = "status|statut|resol|closed|state"),
      cfm_area = list(label = "Complaints by area", type = "count", x = "admin|province|region|district|site|location|village", group = "type|categ"),
      cfm_time = list(label = "Complaints over time", type = "trend", date = "date|received|recu|submission", period = "month"),
      cfm_days = list(label = "Days to resolve, by type", type = "mean", x = "type|categ|motif", value = "day|jour|delay|delai|duration|resolution")
    ),
    `Community process` = list(
      com_part = list(label = "Community participants by area", type = "sum", x = "admin|province|region|district|site|village|location",
                      value = "total|participant|attend|present|nb_|number"),
      com_women = list(label = "Women's share of participants", type = "share", x = "admin|province|region|district|site|village|location",
                       value = "women|female|femme|fem", den = "total|participant|attend"),
      com_minority = list(label = "Minorities' share of participants", type = "share", x = "admin|province|region|district|site|village|location",
                          value = "minorit|disab|handicap|idp|refugee|pwd", den = "total|participant|attend"),
      com_committee = list(label = "Targeting committees in place, by area", type = "count", x = "admin|province|region|district|site|village|location",
                           filter_col = "committee|comite|activity|type", filter_pattern = "committee|comit"),
      com_fgd = list(label = "Focus group discussions on the criteria, by area", type = "count",
                     x = "admin|province|region|district|site|village|location",
                     filter_col = "activity|type|session|event", filter_pattern = "fgd|focus|group discussion|discussion"),
      com_sessions = list(label = "Community sessions by type", type = "count", x = "activity|type|session|event")
    ),
    `PDM` = list(
      pdm_status = list(label = "Households by beneficiary status", type = "count", x = "benef|assist|receiv|recu|distribut"),
      pdm_by_area = list(label = "Beneficiary status by area", type = "count", x = "admin|province|region|district|site",
                         group = "benef|assist|receiv|recu"),
      pdm_aware = list(label = "Awareness of the selection criteria", type = "count", x = "aware|know|connai|criteria|critere",
                       group = "benef|assist|receiv"),
      pdm_satisf = list(label = "Satisfaction with the selection process", type = "count", x = "satisf|fair|juste|equit",
                        group = "benef|assist|receiv")
    )
  )
}

#' Fill a preset's column patterns from a dataset
#' @noRd
apply_preset <- function(preset, df) {
  cols <- names(df)
  pick <- function(pat) {
    if (is.null(pat)) return("")
    hit <- grep(pat, cols, ignore.case = TRUE, value = TRUE)
    if (length(hit)) hit[1] else ""
  }
  spec <- list(type = preset$type, title = preset$label, x = pick(preset$x), group = pick(preset$group),
               value = pick(preset$value), den = pick(preset$den), date = pick(preset$date),
               period = preset$period %||% "month", filter_col = pick(preset$filter_col), filter_vals = character(0))
  if (nzchar(spec$filter_col) && !is.null(preset$filter_pattern)) {
    v <- unique(as.character(df[[spec$filter_col]]))
    spec$filter_vals <- v[!is.na(v) & grepl(preset$filter_pattern, v, ignore.case = TRUE)]
  }
  # a numeric "value" column that is not a number is no use
  for (k in c("value", "den")) {
    if (nzchar(spec[[k]]) && all(is.na(suppressWarnings(as.numeric(as.character(df[[spec[[k]]]])))))) spec[[k]] <- ""
  }
  spec
}

#' The chart of a report item, for the HTML report (billboarder)
#' @noRd
monitoring_item_chart <- function(item, lang = "en") {
  d <- item$data
  if (is.null(d) || !nrow(d)) return(NULL)
  tr <- function(x) i18n_lookup(x, lang)
  groups <- unique(d$group)
  wide <- stats::reshape(d[, c("x", "group", "value")], idvar = "x", timevar = "group", direction = "wide")
  names(wide) <- sub("^value[.]", "", names(wide))
  wide[is.na(wide)] <- 0
  cols <- stats::setNames(rep_len(rp_cols$models, length(groups)), groups)
  vlab <- tr(chart_value_label(item$spec))
  if (identical(item$spec$type, "trend")) {
    return(rp_base(320) |>
             billboarder::bb_linechart(wide, type = "spline") |>
             billboarder::bb_x_axis(type = "category", tick = list(culling = list(max = 12), multiline = FALSE)) |>
             billboarder::bb_y_axis(label = rp_axis_label(vlab)) |>
             rp_colors(cols) |>
             (\(b) if (length(groups) == 1) billboarder::bb_legend(b, show = FALSE) else b)())
  }
  b <- rp_hbars(wide, cols, vlab, stacked = length(groups) > 1 && !identical(item$spec$type, "share"))
  if (length(groups) == 1) b <- billboarder::bb_legend(b, show = FALSE)
  b
}

#' Targeting Monitoring report (HTML)
#'
#' @param x List: `country_office`, `context`, `findings`, `recommendations`,
#'   `pdm` (list with `metrics`, `verdict`, `tolerance`, `n`, `by_unit`,
#'   `excl_design`, or NULL), `items` (report items: `title`, `comment`,
#'   `source`, `spec`, `data`).
#' @noRd
write_monitoring_report <- function(file, x, lang = "en") {
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  quote_block <- function(txt) if (shiny::isTruthy(txt)) paste0("> ", gsub("\n", "\n> ", trimws(txt))) else "> _Not written._"
  items <- x$items %||% list()
  p <- x$pdm

  add("# Targeting monitoring report", "",
      "This report brings together how the targeting was carried out on the ground (process monitoring) and how accurately",
      "it reached the intended households (post-distribution monitoring).", "")
  if (!is.null(p)) add("## Key results", "", "@@IMPL@@", "")
  add("## 1. Context", "", quote_block(x$context), "")

  add("## 2. Implementation accuracy (PDM)", "")
  if (is.null(p)) {
    add("_No PDM analysis was run._", "")
  } else {
    m <- p$metrics
    add(sprintf("- PDM records analysed: %s", format(p$n %||% NA, big.mark = ",")),
        sprintf("- Eligibility from %s", p$elig_source %||% "a PDM column"),
        sprintf("- Weighting: %s", p$weighting %||% "none"),
        if (isTRUE(p$no_nonbenef)) "- **Only beneficiaries were surveyed: the exclusion error and the coverage cannot be measured.**",
        sprintf("- Coverage of eligible households: %s", pct(m$coverage_rate)),
        sprintf("- Precision: %s; recall: %s", pct(m$precision), pct(m$recall)),
        if (!is.null(p$excl_design)) sprintf("- Excluded by design (eligible, not prioritised): %s households (%s of eligible), not counted as exclusion error.",
                                             format(p$excl_design$n, big.mark = ","), pct(p$excl_design$share)),
        "",
        if (!is.null(p$verdict)) sprintf("**%s** Action: %s", p$verdict$interpretation, p$verdict$action) else NULL, "")
    if (!is.null(p$strata) && nrow(p$strata)) {
      st <- p$strata
      add("Households surveyed and population, by group:", "",
          md_table(data.frame(Area = st$unit, `Beneficiaries surveyed` = st$surveyed_beneficiaries,
                              `Non-beneficiaries surveyed` = st$surveyed_non_beneficiaries,
                              `Beneficiary households` = st$beneficiaries, `Non-beneficiary households` = st$non_beneficiaries,
                              check.names = FALSE)), "")
    }
    if (!is.null(p$by_unit) && nrow(p$by_unit)) {
      bu <- p$by_unit
      add("Coverage by area:", "", md_table(data.frame(Area = bu[[1]], Eligible = round(bu$eligible), Selected = round(bu$selected),
                                                      Coverage = vapply(bu$coverage, pct, character(1)), check.names = FALSE)), "")
    }
  }

  section <- function(num, title, src, empty) {
    its <- Filter(function(it) identical(it$source, src), items)
    add(sprintf("## %d. %s", num, title), "")
    if (!length(its)) { add(sprintf("_%s_", empty), ""); return(invisible()) }
    for (it in its) {
      add(sprintf("### %s", it$title), "",
          if (identical(it$display, "table")) md_table(chart_table(it$data, it$spec)) else sprintf("@@FIG:%s@@", it$id), "")
      if (shiny::isTruthy(it$comment)) add(quote_block(it$comment), "")
      add(sprintf("_Source: %s; %s._", it$dataset %||% src, tolower(names(chart_types())[chart_types() == it$spec$type][1] %||% "")), "")
    }
  }
  section(3, "Process monitoring", "process", "No process-monitoring chart was added.")
  section(4, "Insights from the PDM", "pdm", "No PDM chart was added.")

  add("## 5. Key findings", "", quote_block(x$findings), "",
      "## 6. Recommendations", "", quote_block(x$recommendations), "",
      "## 7. Method", "",
      paste("**Implementation errors** are measured on the PDM sample. Eligibility is re-established for each surveyed household",
            "(from a PDM column, or by applying the adopted scorecard or eligibility rules to its answers).",
            "Inclusion error = beneficiaries who were not eligible / all beneficiaries, from the beneficiary sample.",
            "Exclusion error = eligible households not assisted / all eligible households; it needs the non-beneficiary sample, and",
            "because the PDM surveys set numbers of beneficiaries and non-beneficiaries, each household is weighted by its group's",
            "population over the number surveyed from it (per area when the sizes are given per area), so the non-beneficiaries",
            "count for their real share.",
            "They show whether the criteria were applied correctly on the ground, not whether the criteria were right (that is the design error).",
            "Eligible households left out because of prioritisation are excluded by design and reported separately (Targeting Advisory 2/2025)."), "",
      paste("**Process monitoring** charts count records, total or average a number, or divide two totals (for example women among",
            "participants), by area or category, as chosen by the officer, shown as a chart or a table; each carries the officer's comment."), "")

  plots <- list(); caps <- character(0)
  for (it in items) {
    if (identical(it$display, "table")) next
    ch <- tryCatch(monitoring_item_chart(it, lang), error = function(e) NULL)
    # the item's heading already names the chart
    if (!is.null(ch)) { plots[[it$id]] <- ch; caps[[it$id]] <- "" }
  }
  impl <- if (is.null(p)) "" else implementation_cards(p, lang)
  report_write_page(
    file, paste(L, collapse = "\n"), plots, captions = caps, lang = lang,
    title = "Targeting monitoring report", record = "Targeting monitoring record",
    meta = c("Country office" = x$country_office %||% "", "Generated" = format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Charts" = as.character(length(items))),
    footer = "This record documents how the targeting was implemented so it can be reviewed and improved.",
    blocks = list("@@IMPL@@" = impl))
}

#' Implementation error gauges for the monitoring report
#' @noRd
implementation_cards <- function(p, lang = "en") {
  m <- p$metrics
  tol <- p$tolerance %||% c(0.05, 0.20)
  tr <- function(t) htmltools::htmlEscape(i18n_lookup(t, lang))
  card <- function(label, v, what, icon) {
    band <- if (is.null(v) || is.na(v)) "na" else if (v <= tol[1]) "ok" else if (v <= tol[2]) "warn" else "bad"
    state <- c(ok = "Within tolerance", warn = "In the review band", bad = "Beyond tolerance", na = "Not available")[[band]]
    report_gauge_card(tr(label), v %||% NA_real_, band, tr(state), tr(what), tr("Measured on the PDM sample"),
                      icon, zones = c(ok = tol[1], warn = tol[2], bad = 0.5), max = 0.5)
  }
  ico_in <- '<svg viewBox="0 0 16 16"><path d="M2 8h8M7 4.5 10.5 8 7 11.5M13 3v10" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  ico_out <- '<svg viewBox="0 0 16 16"><path d="M3 3v10M6 8h8M11 4.5 14.5 8 11 11.5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  paste0('<div class="err-cards">',
         card("Implementation inclusion error", m$inclusion_error, "Beneficiaries who were not eligible", ico_in),
         card("Implementation exclusion error", m$exclusion_error, "Eligible households who were not assisted", ico_out),
         '</div>')
}
