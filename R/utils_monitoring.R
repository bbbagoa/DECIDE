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
#' * `crosstab` -- records by `x` (rows) and `group` (columns), as row, column
#'   or total percentages (`pct`), with a chi-square test
#' @name monitoring_charts
#' @noRd
NULL

#' @noRd
chart_types <- function() {
  c("Count of records" = "count", "Total of a number" = "sum", "Average of a number" = "mean",
    "Share (%) of two totals" = "share", "Trend over time" = "trend",
    "Cross-tabulation (rows by columns)" = "crosstab")
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

  if (identical(type, "crosstab")) {
    if (!has("x") || !has("group")) return(NULL)
    cnt <- table(lab(df[[spec$x]]), lab(df[[spec$group]]))
    basis <- spec$pct %||% "row"
    p <- switch(basis, row = prop.table(cnt, 1), col = prop.table(cnt, 2), total = cnt / sum(cnt), cnt)
    out <- data.frame(x = rep(rownames(cnt), ncol(cnt)), group = rep(colnames(cnt), each = nrow(cnt)),
                      value = round(if (identical(basis, "count")) as.numeric(cnt) else 100 * as.numeric(p), 2),
                      n = as.integer(cnt), stringsAsFactors = FALSE)
    row_tot <- stats::ave(out$n, out$x, FUN = sum)
    out <- out[order(-row_tot, out$x, out$group), , drop = FALSE]
    rownames(out) <- NULL
    return(out)
  }

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
  if (identical(spec$type, "crosstab")) return(crosstab_table(d, spec))
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
         crosstab = switch(spec$pct %||% "row", row = "% of the row", col = "% of the column",
                           total = "% of all records", "Records"),
         "Records")
}

#' Ready-made charts for the usual targeting-process and PDM questions
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
  st <- chart_style(item$spec)
  one <- function(b) if (length(groups) == 1) billboarder::bb_legend(b, show = FALSE) else b
  if (st %in% c("pie", "donut")) {
    p <- chart_pie_data(d)
    if (identical(st, "donut")) return(rp_donut(p, height = 300))
    pc <- stats::setNames(rep_len(rp_cols$models, nrow(p)), p$category)
    return(rp_base(300) |>
             billboarder::bb_piechart(p) |>
             rp_colors(pc) |>
             billboarder::bb_pie(label = list(format = htmlwidgets::JS("function(v, r) { return (r * 100).toFixed(0) + '%'; }"))))
  }
  if (identical(st, "column")) {
    return(rp_base(340) |>
             billboarder::bb_barchart(wide, stacked = length(groups) > 1 && chart_stacks(item$spec)) |>
             rp_colors(cols) |>
             billboarder::bb_x_axis(tick = list(multiline = FALSE, culling = list(max = 15))) |>
             billboarder::bb_y_axis(label = rp_axis_label(vlab)) |>
             one())
  }
  if (st %in% c("line", "area")) {
    return(rp_base(320) |>
             billboarder::bb_linechart(wide, type = if (identical(st, "area")) "area-spline" else "spline") |>
             billboarder::bb_x_axis(type = "category", tick = list(culling = list(max = 12), multiline = FALSE)) |>
             billboarder::bb_y_axis(label = rp_axis_label(vlab)) |>
             rp_colors(cols) |>
             one())
  }
  b <- rp_hbars(wide, cols, vlab, stacked = length(groups) > 1 && chart_stacks(item$spec))
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
  pairs <- list()   # raw HTML blocks, swapped in after conversion
  add <- function(...) L <<- c(L, ...)
  pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
  # The officer's formatted texts go in as raw HTML blocks, swapped in after
  # the Markdown is converted.
  quote_block <- function(txt) {
    h <- rich_html(txt)
    if (!nzchar(h)) return("> _Not written._")
    ph <- sprintf("@@RICH%d@@", length(pairs) + 1)
    pairs[[ph]] <<- sprintf('<div class="rich">%s</div>', h)
    ph
  }
  items <- x$items %||% list()
  p <- x$pdm
  kind <- x$kind %||% p$kind %||% "PDM"

  add("# Targeting monitoring report", "",
      "This report brings together how the targeting was carried out on the ground (targeting process) and how accurately",
      if (identical(kind, "Baseline")) "it reached the intended households (baseline survey)." else "it reached the intended households (post-distribution monitoring).", "")
  if (!is.null(p)) add("## Key results", "", "@@IMPL@@", "")
  add("## 1. Context", "", quote_block(x$context), "")

  add(sprintf("## 2. Implementation accuracy (%s)", kind), "")
  if (is.null(p)) {
    add(sprintf("_No %s analysis was run._", kind), "")
  } else {
    m <- p$metrics
    add(sprintf("- %s records analysed: %s", kind, format(p$n %||% NA, big.mark = ",")),
        sprintf("- Areas covered: %s", p$areas %||% "All areas"),
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

  esc <- function(t) htmltools::htmlEscape(t %||% "")
  source_line <- function(it, src) sprintf("Source: %s; %s.", it$dataset %||% src,
                                            tolower(names(chart_types())[chart_types() == it$spec$type][1] %||% ""))
  # Two half-width items in a row: one side-by-side block (raw HTML, in which
  # the figure placeholders are still filled by report_write_page()).
  pair_html <- function(its, src) paste0('<div class="pair">', paste(vapply(its, function(it) paste0(
    '<div class="pair-cell"><h3>', esc(it$title), '</h3>',
    if (identical(it$display, "table")) commonmark::markdown_html(paste(md_table(chart_table(it$data, it$spec)), collapse = "\n"), extensions = TRUE)
    else sprintf("<p>@@FIG:%s@@</p>", it$id),
    if (identical(it$spec$type, "crosstab")) sprintf('<p class="note"><em>%s</em></p>', esc(crosstab_test_text(crosstab_test(it$data)))) else "",
    if (nzchar(rich_html(it$comment))) sprintf('<div class="rich">%s</div>', rich_html(it$comment)) else "",
    sprintf('<p class="note"><em>%s</em></p>', esc(source_line(it, src))), '</div>'), character(1)), collapse = ""), '</div>')
  section <- function(num, title, src, empty) {
    its <- Filter(function(it) identical(it$source, src), items)
    add(sprintf("## %d. %s", num, title), "")
    if (!length(its)) { add(sprintf("_%s_", empty), ""); return(invisible()) }
    i <- 1
    while (i <= length(its)) {
      it <- its[[i]]
      if (identical(it$width, "half") && i < length(its) && identical(its[[i + 1]]$width, "half")) {
        ph <- sprintf("@@PAIR%d@@", length(pairs) + 1)
        pairs[[ph]] <<- pair_html(its[i:(i + 1)], src)
        add(ph, "")
        i <- i + 2
        next
      }
      i <- i + 1
      add(sprintf("### %s", it$title), "",
          if (identical(it$display, "table")) md_table(chart_table(it$data, it$spec)) else sprintf("@@FIG:%s@@", it$id), "",
          if (identical(it$spec$type, "crosstab")) c(sprintf("_%s_", crosstab_test_text(crosstab_test(it$data))), "") else NULL)
      if (nzchar(rich_html(it$comment))) add(quote_block(it$comment), "")
      add(sprintf("_Source: %s; %s._", it$dataset %||% src, tolower(names(chart_types())[chart_types() == it$spec$type][1] %||% "")), "")
    }
  }
  section(3, "Targeting process", "process", "No targeting-process chart was added.")
  section(4, sprintf("Insights from the %s data", kind), "pdm", sprintf("No %s chart was added.", kind))

  add("## 5. Key findings", "", quote_block(x$findings), "",
      "## 6. Recommendations", "", quote_block(x$recommendations), "",
      "## 7. Method", "",
      paste(sprintf("**Implementation errors** are measured on the %s sample.", kind), "Eligibility is re-established for each surveyed household",
            "(from a column of the survey data, or by applying the adopted scorecard or eligibility rules to its answers).",
            "Inclusion error = beneficiaries who were not eligible / all beneficiaries, from the beneficiary sample.",
            "Exclusion error = eligible households not assisted / all eligible households; it needs the non-beneficiary sample, and",
            "because the PDM surveys set numbers of beneficiaries and non-beneficiaries, each household is weighted by its group's",
            "population over the number surveyed from it (per area when the sizes are given per area), so the non-beneficiaries",
            "count for their real share.",
            "They show whether the criteria were applied correctly on the ground, not whether the criteria were right (that is the design error).",
            "Eligible households left out because of prioritisation are excluded by design and reported separately (Targeting Advisory 2/2025)."), "",
      paste("**Targeting process** charts count records, total or average a number, or divide two totals (for example women among",
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
    blocks = c(list("@@IMPL@@" = impl), pairs))
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

#' A crosstab as a table: each cell "percent (count)", row and column totals
#' @noRd
crosstab_table <- function(d, spec) {
  rows <- unique(d$x); cols <- unique(d$group)
  cnt <- matrix(0L, length(rows), length(cols), dimnames = list(rows, cols))
  cnt[cbind(match(d$x, rows), match(d$group, cols))] <- d$n
  basis <- spec$pct %||% "row"
  tot <- sum(cnt)
  p <- switch(basis, row = cnt / rowSums(cnt), col = t(t(cnt) / colSums(cnt)), total = cnt / tot, NULL)
  cell <- if (is.null(p)) format(cnt, big.mark = ",") else
    matrix(sprintf("%.1f%% (%s)", 100 * p, format(cnt, big.mark = ",", trim = TRUE)), nrow(cnt))
  out <- data.frame(rows, cell, check.names = FALSE, stringsAsFactors = FALSE)
  names(out) <- c(spec$x %||% "Rows", cols)
  out$Total <- sprintf("%s (%.1f%%)", format(rowSums(cnt), big.mark = ",", trim = TRUE), 100 * rowSums(cnt) / tot)
  last <- c("Total", sprintf("%s (%.1f%%)", format(colSums(cnt), big.mark = ",", trim = TRUE), 100 * colSums(cnt) / tot),
            format(tot, big.mark = ","))
  out <- rbind(out, stats::setNames(as.list(last), names(out)))
  rownames(out) <- NULL
  out
}

#' Chi-square test of independence on a crosstab, with Cramer's V
#' @param d Output of `chart_aggregate()` for a crosstab (uses `n`).
#' @return list(chi2, df, p, cramer_v, low_expected) or NULL (not testable).
#' @noRd
crosstab_test <- function(d) {
  if (is.null(d) || !nrow(d)) return(NULL)
  cnt <- stats::xtabs(n ~ x + group, d)
  if (any(dim(cnt) < 2) || sum(cnt) == 0) return(NULL)
  cnt <- cnt[rowSums(cnt) > 0, colSums(cnt) > 0, drop = FALSE]
  if (any(dim(cnt) < 2)) return(NULL)
  t <- suppressWarnings(stats::chisq.test(cnt, correct = FALSE))
  list(chi2 = unname(t$statistic), df = unname(t$parameter), p = unname(t$p.value),
       cramer_v = sqrt(unname(t$statistic) / (sum(cnt) * (min(dim(cnt)) - 1))),
       low_expected = mean(t$expected < 5))
}

#' The test in words
#' @noRd
crosstab_test_text <- function(tt) {
  if (is.null(tt)) return("Chi-square test: not applicable (needs at least two rows and two columns with records).")
  strength <- if (tt$cramer_v < 0.1) "negligible" else if (tt$cramer_v < 0.3) "weak" else if (tt$cramer_v < 0.5) "moderate" else "strong"
  paste0(sprintf("Chi-square = %.2f, df = %d, p %s; Cramer's V = %.2f (%s association). ",
                 tt$chi2, as.integer(tt$df), if (tt$p < 0.001) "< 0.001" else sprintf("= %.3f", tt$p), tt$cramer_v, strength),
         if (tt$p < 0.05) "The rows and columns are related: the differences are unlikely to be chance. "
         else "No evidence that rows and columns are related: the differences may be chance. ",
         if (tt$low_expected > 0.2) sprintf("%.0f%% of the expected counts are below 5, so read the p-value with caution.", 100 * tt$low_expected) else "")
}

#' Whether a chart's groups stack: parts of a whole do, rates and column
#' percentages (each column sums to 100) sit side by side
#' @noRd
chart_stacks <- function(spec) {
  !identical(spec$type, "share") && !(identical(spec$type, "crosstab") && identical(spec$pct, "col"))
}

#' How a chart is drawn (the computation is `spec$type`)
#' @noRd
chart_styles <- function() {
  c("Automatic" = "auto", "Bars (horizontal)" = "bar", "Columns (vertical)" = "column",
    "Donut" = "donut", "Pie" = "pie", "Line" = "line", "Area" = "area")
}

#' The style actually drawn: automatic is a line over time, bars otherwise
#' @noRd
chart_style <- function(spec) {
  s <- spec$style %||% "auto"
  if (!s %in% chart_styles() || identical(s, "auto")) if (identical(spec$type, "trend")) "line" else "bar" else s
}

#' Parts of a whole for a pie or donut: one slice per category, the split
#' (if any) added up
#' @noRd
chart_pie_data <- function(d) {
  a <- stats::aggregate(value ~ x, d, sum, na.rm = TRUE)
  a <- a[order(-a$value), , drop = FALSE]
  data.frame(category = a$x, n = a$value, stringsAsFactors = FALSE)
}

#' Why a pie or donut may mislead for this spec, or NULL
#' @noRd
chart_pie_note <- function(spec) {
  if (!chart_style(spec) %in% c("pie", "donut")) return(NULL)
  if (!(spec$type %||% "count") %in% c("count", "sum")) return("A pie or donut shows parts of a whole: use it for counts or totals, not averages or percentages.")
  if (shiny::isTruthy(spec$group)) return("A pie or donut shows one series: the split is added up. Use bars to compare the groups.")
  NULL
}
