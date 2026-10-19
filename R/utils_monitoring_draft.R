#' Targeting Monitoring: drafts, findings, headline indicators, rounds, checks
#'
#' * `monitoring_templates()` / `monitoring_draft()`: a report drafted from a
#'   template (the ready-made charts of `chart_presets()` applied to the data
#'   loaded), so the officer edits instead of starting from an empty page.
#' * `chart_caption()`: a finding written from a chart's numbers (plain
#'   sentence templates; nothing leaves the machine).
#' * `monitoring_indicators()`: the headline figures with a traffic light,
#'   for the executive summary and for the comparison between rounds.
#' * `monitoring_round()` / `template_from_items()` / `items_from_template()`:
#'   a report saved as a template (charts without data) with each round's
#'   figures, re-applied to the next round's data.
#' * `monitoring_checks()`: what to look at before exporting.
#' @name monitoring_draft
#' @noRd
NULL

#' Built-in report templates: which ready-made charts, from which data
#' @noRd
monitoring_templates <- function() {
  it <- function(source, preset, width = "full", display = "chart") list(source = source, preset = preset, width = width, display = display)
  list(
    pdm = list(label = "PDM targeting accuracy", items = list(
      it("pdm", "pdm_status", "half"), it("pdm", "pdm_by_area", "half"),
      it("pdm", "pdm_aware", "half"), it("pdm", "pdm_satisf", "half"))),
    process = list(label = "Process monitoring", items = list(
      it("process", "cfm_type", "half"), it("process", "cfm_status", "half"),
      it("process", "cfm_channel", "half"), it("process", "cfm_time", "half"),
      it("process", "cfm_days", "full", "table"),
      it("process", "com_part", "half"), it("process", "com_women", "half"),
      it("process", "com_committee", "half"), it("process", "com_fgd", "half"))),
    brief = list(label = "2-page donor brief", items = list(
      it("pdm", "pdm_by_area", "half"), it("pdm", "pdm_satisf", "half"),
      it("process", "cfm_type", "half"), it("process", "com_women", "half")))
  )
}

#' One ready-made chart by its key (e.g. "cfm_type")
#' @noRd
preset_by_key <- function(key) unlist(unname(chart_presets()), recursive = FALSE)[[key]]

#' Whether a spec has the columns its type needs
#' @noRd
spec_complete <- function(sp, preset = NULL) {
  ok <- if (identical(sp$type, "trend")) nzchar(sp$date %||% "") else nzchar(sp$x %||% "")
  if (sp$type %in% c("sum", "mean", "share")) ok <- ok && nzchar(sp$value %||% "")
  if (identical(sp$type, "share")) ok <- ok && nzchar(sp$den %||% "")
  # a filtered preset whose filter finds nothing would chart every record
  if (!is.null(preset$filter_pattern)) ok <- ok && length(sp$filter_vals) > 0
  ok
}

#' A report item from a spec and its data
#' @noRd
monitoring_item <- function(spec, data, source, dataset, title = NULL, display = "chart", width = "full", preset = NULL) {
  d <- tryCatch(chart_aggregate(data, spec), error = function(e) NULL)
  if (is.null(d) || !nrow(d)) return(NULL)
  cap <- chart_caption(d, spec)
  list(id = paste0("it", format(as.numeric(Sys.time()) * 1000, scientific = FALSE), sample.int(99999, 1)),
       source = source, dataset = dataset, title = title %||% spec$title %||% chart_value_label(spec),
       comment = cap, caption = cap, spec = spec, data = d, display = display, width = width, preset = preset)
}

#' Draft the report items of a built-in template from the data loaded
#'
#' @param key Name in `monitoring_templates()`.
#' @param pdm_df PDM data (or NULL); `pdm_name` its label.
#' @param process Named list of targeting-process datasets; each chart takes
#'   the first dataset where its columns are found.
#' @return list(items, skipped = chart labels that found no data).
#' @noRd
monitoring_draft <- function(key, pdm_df = NULL, process = list(), pdm_name = "PDM data") {
  tpl <- monitoring_templates()[[key]]
  items <- list(); skipped <- character(0)
  for (t in tpl$items) {
    pr <- preset_by_key(t$preset)
    if (is.null(pr)) next
    sources <- if (identical(t$source, "pdm")) stats::setNames(list(pdm_df), pdm_name) else process
    made <- NULL
    for (nm in names(sources)) {
      df <- sources[[nm]]
      if (is.null(df) || !nrow(df)) next
      if (!draft_topic_ok(t$preset, nm, df)) next
      sp <- apply_preset(pr, df)
      if (!spec_complete(sp, pr)) next
      sp$style <- "auto"
      made <- monitoring_item(sp, df, t$source, nm, title = pr$label, display = t$display, width = t$width, preset = t$preset)
      if (!is.null(made)) break
    }
    if (is.null(made)) skipped <- c(skipped, pr$label) else items[[length(items) + 1]] <- made
  }
  list(items = items, skipped = skipped)
}

#' Whether a dataset is about what a ready-made chart shows
#'
#' The presets find their columns by name patterns ("status", "date"), which
#' any dataset has: a registration list would give "Complaints by status" from
#' its residency status. A draft only uses a complaints chart on data that
#' looks like complaints (by its name or its columns), and a community chart
#' on committee / session data. The chart builder is not limited: there the
#' officer picks the chart.
#' @noRd
draft_topic_ok <- function(preset, name, df) {
  topic <- if (startsWith(preset, "cfm_")) "complain|plainte|cfm|feedback|grievance|reclam|hotline|helpdesk|help_desk"
           else if (startsWith(preset, "com_")) "committee|comite|community|communaut|fgd|focus|session|meeting|reunion|participant|attend"
           else return(TRUE)
  grepl(topic, tolower(name %||% "")) || any(grepl(topic, tolower(names(df))))
}

#' A finding written from a chart's numbers
#'
#' Highest and lowest category, the gap to the average, the trend's peak and
#' last change, a crosstab's test; and a caution when groups are small.
#' @param d Output of `chart_aggregate()`.
#' @param spec The chart spec.
#' @return One or two sentences, or "".
#' @noRd
chart_caption <- function(d, spec) {
  if (is.null(d) || !nrow(d)) return("")
  type <- spec$type %||% "count"
  f <- function(v) {
    if (type %in% c("share") || (identical(type, "crosstab") && !identical(spec$pct, "count"))) sprintf("%.1f%%", v)
    else if (identical(type, "mean")) format(round(v, 1), nsmall = 1, big.mark = ",")
    else format(round(v), big.mark = ",")
  }
  unit <- switch(type, count = "records", sum = "", mean = "", share = "", trend = if (nzchar(spec$value %||% "")) "" else "records", "")
  with_unit <- function(v) trimws(paste(f(v), unit))
  if (identical(type, "crosstab")) {
    tt <- crosstab_test(d)
    top <- d[which.max(d$value), ]
    return(paste0(sprintf("The largest cell is %s / %s (%s). ", top$x, top$group, f(top$value)),
                  if (is.null(tt)) "" else if (tt$p < 0.05) "The rows and columns are related (chi-square p < 0.05)."
                  else "No evidence that the rows and columns are related."))
  }
  # one value per category (groups added up for counts and totals, averaged otherwise)
  add_up <- type %in% c("count", "sum", "trend")
  a <- stats::aggregate(list(value = d$value), list(x = d$x),
                        function(z) if (add_up) sum(z, na.rm = TRUE) else mean(z, na.rm = TRUE))
  a$n <- as.numeric(tapply(d$n, d$x, sum)[a$x])
  if (identical(type, "trend")) {
    a <- a[order(a$x), , drop = FALSE]
    pk <- a[which.max(a$value), ]
    s <- sprintf("Peak in %s (%s).", pk$x, with_unit(pk$value))
    if (nrow(a) >= 2) {
      last <- a[nrow(a), ]; prev <- a[nrow(a) - 1, ]
      ch <- if (prev$value > 0) (last$value - prev$value) / prev$value else NA
      s <- paste(s, sprintf("Latest period %s: %s, %s from %s.", last$x, with_unit(last$value),
                            if (is.na(ch)) "changed" else if (ch >= 0) sprintf("up %.0f%%", 100 * ch) else sprintf("down %.0f%%", -100 * ch), prev$x))
    }
    return(s)
  }
  a <- a[order(-a$value), , drop = FALSE]
  hi <- a[1, ]
  if (nrow(a) == 1) return(sprintf("%s: %s.", hi$x, with_unit(hi$value)))
  lo <- a[nrow(a), ]
  s <- if (add_up) {
    sprintf("%s comes first with %s (%.0f%% of the total); %s is last with %s.", hi$x, with_unit(hi$value),
            100 * hi$value / max(1, sum(a$value)), lo$x, with_unit(lo$value))
  } else {
    avg <- stats::weighted.mean(a$value, a$n, na.rm = TRUE)
    gap <- hi$value - avg
    sprintf("Highest in %s (%s, %s %s above the average of %s); lowest in %s (%s).", hi$x, f(hi$value),
            if (identical(type, "share")) sprintf("%.1f", gap) else format(round(gap, 1), nsmall = 1),
            if (identical(type, "share")) "points" else "", f(avg), lo$x, f(lo$value))
  }
  s <- gsub("  +", " ", s)
  small <- sum(a$n < 30)
  if (!add_up && small) s <- paste(s, sprintf("%d categor%s rest%s on fewer than 30 records: read with caution.",
                                              small, if (small == 1) "y" else "ies", if (small == 1) "s" else ""))
  s
}

#' Share of a count chart whose category reads as "yes" / "satisfied" /
#' "resolved" (and not "not satisfied", "unresolved"...)
#' @noRd
positive_share <- function(d, pos, neg = "^(no|non)\\b|\\bnot\\b|\\bpas\\b|unsatisf|insatisf|dissatisf|unresol|non r") {
  if (is.null(d) || !nrow(d)) return(NA_real_)
  a <- tapply(d$value, d$x, sum, na.rm = TRUE)
  x <- tolower(names(a))
  hit <- grepl(pos, x) & !grepl(neg, x)
  if (!any(hit) || sum(a) <= 0) return(NA_real_)
  sum(a[hit]) / sum(a)
}

#' The headline indicators, each with its traffic light
#'
#' @param p The implementation errors (`metrics`, `tolerance`) or NULL.
#' @param items Report items (their `preset` says what they measure).
#' @return list of list(key, label, value, format "pct"/"num", band, better, sub).
#' @noRd
monitoring_indicators <- function(p = NULL, items = list()) {
  out <- list()
  band3 <- function(v, good, warn, up = TRUE) {
    if (is.null(v) || is.na(v)) return("na")
    if (up) { if (v >= good) "ok" else if (v >= warn) "warn" else "bad" } else { if (v <= good) "ok" else if (v <= warn) "warn" else "bad" }
  }
  add <- function(key, label, v, fmt, band, better, sub) {
    if (is.null(v) || is.na(v)) return()
    out[[key]] <<- list(key = key, label = label, value = v, format = fmt, band = band, better = better, sub = sub)
  }
  if (!is.null(p$metrics)) {
    tol <- p$tolerance %||% c(0.05, 0.20)
    m <- p$metrics
    add("coverage", "Coverage of eligible households", m$coverage_rate, "pct", band3(m$coverage_rate, 0.8, 0.6), "up",
        "eligible households assisted")
    add("inclusion", "Inclusion error", m$inclusion_error, "pct", band3(m$inclusion_error, tol[1], tol[2], up = FALSE), "down",
        sprintf("tolerance %.0f-%.0f%%", 100 * tol[1], 100 * tol[2]))
    add("exclusion", "Exclusion error", m$exclusion_error, "pct", band3(m$exclusion_error, tol[1], tol[2], up = FALSE), "down",
        sprintf("tolerance %.0f-%.0f%%", 100 * tol[1], 100 * tol[2]))
  }
  by_preset <- function(k) { for (it in items) if (identical(it$preset, k)) return(it$data); NULL }
  cfm <- by_preset("cfm_type") %||% by_preset("cfm_channel") %||% by_preset("cfm_status")
  if (!is.null(cfm)) add("complaints", "Complaints and feedback", sum(cfm$value, na.rm = TRUE), "num", "na", "none", "received")
  add("resolved", "Complaints resolved", positive_share(by_preset("cfm_status"), "resol|closed|clos|ferm|trait|done|solved|answered|repond"),
      "pct", band3(positive_share(by_preset("cfm_status"), "resol|closed|clos|ferm|trait|done|solved|answered|repond"), 0.8, 0.5), "up",
      "of complaints closed")
  sat <- positive_share(by_preset("pdm_satisf"), "yes|oui|satisf|agree|accord|fair|juste|^1$|true")
  add("satisfaction", "Satisfied with the selection", sat, "pct", band3(sat, 0.8, 0.6), "up", "of households surveyed")
  aw <- positive_share(by_preset("pdm_aware"), "yes|oui|aware|know|connai|^1$|true")
  add("awareness", "Aware of the criteria", aw, "pct", band3(aw, 0.8, 0.6), "up", "of households surveyed")
  w <- by_preset("com_women")
  if (!is.null(w) && nrow(w)) {
    ws <- stats::weighted.mean(w$value, w$n, na.rm = TRUE) / 100
    add("women", "Women among participants", ws, "pct", band3(ws, 0.5, 0.4), "up", "of community participants")
  }
  out
}

#' An item's figures, for the next round's comparison: value by category
#' @noRd
item_figures <- function(d) {
  if (is.null(d) || !nrow(d)) return(NULL)
  k <- if (length(unique(d$group)) > 1) paste(d$x, d$group, sep = " / ") else d$x
  stats::setNames(as.numeric(d$value), k)
}

#' This round's figures: the headline indicators and every item's values
#' @noRd
monitoring_round <- function(label, p = NULL, items = list()) {
  ind <- monitoring_indicators(p, items)
  list(label = label, date = format(Sys.Date()),
       indicators = vapply(ind, `[[`, numeric(1), "value"),
       items = stats::setNames(lapply(items, function(it) item_figures(it$data)), vapply(items, `[[`, character(1), "title")))
}

#' A report as a template: the charts without their data
#' @noRd
template_from_items <- function(items, keep_comments = FALSE) {
  lapply(items, function(it) {
    t <- it[c("title", "source", "dataset", "spec", "display", "width", "preset")]
    # the officer's own comment (not the finding written from the numbers)
    if (keep_comments && nzchar(rich_text(it$comment %||% "")) && !identical(it$comment, it$caption)) t$comment <- it$comment
    t
  })
}

TEMPLATE_FORMAT <- "DECIDE monitoring template"
#' Older templates carry the app's earlier name
#' @noRd
TEMPLATE_FORMATS_OLD <- "TargetWise monitoring template"

#' A saved template as a JSON file, to share with colleagues or another office
#'
#' The charts' definitions, the kept texts and every round's figures; never
#' the data. JSON rather than an R file: a template received from someone
#' else carries nothing but values.
#' @noRd
template_json <- function(t) {
  as.character(jsonlite::toJSON(list(
    format = TEMPLATE_FORMAT, version = 1L, name = t$name, exported = fmt_datetime(),
    items = t$items, texts = if (length(t$texts)) as.list(t$texts),
    rounds = lapply(t$rounds %||% list(), function(r) list(label = r$label, date = r$date, indicators = as.list(r$indicators),
                                                         items = lapply(r$items, as.list)))),
    auto_unbox = TRUE, null = "null", na = "null", digits = NA, pretty = TRUE))
}

#' Read a template file back, checking it is one
#' @return The template (name, items, texts, rounds), or an error with a
#'   readable message.
#' @noRd
read_template_json <- function(txt) {
  j <- tryCatch(jsonlite::fromJSON(txt, simplifyVector = FALSE), error = function(e) NULL)
  if (!is.list(j) || !isTRUE(j$format %in% c(TEMPLATE_FORMAT, TEMPLATE_FORMATS_OLD))) stop("This file is not a DECIDE monitoring template.", call. = FALSE)
  one <- function(v, default = "") if (is.null(v) || !length(v)) default else as.character(v[[1]])
  num <- function(l) { v <- vapply(l %||% list(), function(x) if (is.null(x)) NA_real_ else as.numeric(x), numeric(1)); stats::setNames(v, names(l)) }
  items <- lapply(j$items %||% list(), function(it) {
    sp <- lapply(it$spec %||% list(), function(v) if (is.list(v)) as.character(unlist(v)) else v)
    sp$filter_vals <- as.character(unlist(sp$filter_vals))
    out <- list(title = one(it$title), source = one(it$source, "process"), dataset = one(it$dataset), spec = sp,
                display = one(it$display, "chart"), width = one(it$width, "full"), preset = if (!is.null(it$preset)) one(it$preset))
    if (!is.null(it$comment)) out$comment <- one(it$comment)
    out
  })
  if (!length(items)) stop("The template has no chart.", call. = FALSE)
  texts <- if (is.list(j$texts)) vapply(j$texts, function(v) one(v), character(1))
  rounds <- lapply(j$rounds %||% list(), function(r) list(label = one(r$label), date = one(r$date),
                                                          indicators = num(r$indicators), items = lapply(r$items %||% list(), num)))
  list(name = one(j$name, "Imported template"), items = items, texts = texts, rounds = rounds)
}

#' A template's charts on the new round's data
#'
#' @param tpl_items From `template_from_items()`.
#' @param pdm_df,process,pdm_name As `monitoring_draft()`; a process chart
#'   takes its old dataset when a dataset of that name is loaded, else the
#'   first one where it works.
#' @return list(items, skipped).
#' @noRd
items_from_template <- function(tpl_items, pdm_df = NULL, process = list(), pdm_name = "PDM data") {
  items <- list(); skipped <- character(0)
  for (t in tpl_items) {
    sources <- if (identical(t$source, "pdm")) stats::setNames(list(pdm_df), pdm_name) else
      process[c(intersect(t$dataset, names(process)), setdiff(names(process), t$dataset))]
    made <- NULL
    for (nm in names(sources)) {
      made <- monitoring_item(t$spec, sources[[nm]], t$source, nm, title = t$title, display = t$display %||% "chart",
                              width = t$width %||% "full", preset = t$preset)
      # the comment kept from the last round comes back as the starting text;
      # the finding from the new numbers stays offered beside it
      if (!is.null(made) && !is.null(t$comment)) made$comment <- t$comment
      if (!is.null(made)) break
    }
    if (is.null(made)) skipped <- c(skipped, t$title) else items[[length(items) + 1]] <- made
  }
  list(items = items, skipped = skipped)
}

#' What to look at before exporting
#'
#' @param items Report items.
#' @param p The implementation errors (or NULL), with `tolerance`.
#' @param texts Named character: context, findings, recommendations.
#' @param include_pdm Whether the report includes the implementation errors.
#' @param tol_default The app's default tolerance band.
#' @return Character vector of warnings (empty when all is well).
#' @noRd
monitoring_checks <- function(items, p = NULL, texts = character(0), include_pdm = TRUE, tol_default = c(0.05, 0.20)) {
  w <- character(0)
  if (!length(items) && is.null(p)) w <- c(w, "The report has no chart, table or implementation errors yet.")
  for (it in items) {
    t <- trimws(it$title %||% "")
    if (!nzchar(t) || identical(tolower(t), tolower(chart_value_label(it$spec)))) w <- c(w, sprintf("'%s' has no title of its own.", if (nzchar(t)) t else "A chart"))
    if (!nzchar(rich_text(it$comment))) w <- c(w, sprintf("'%s' has no comment.", t))
    pct_like <- (it$spec$type %||% "count") %in% c("mean", "share", "crosstab")
    if (pct_like && !is.null(it$data) && nrow(it$data)) {
      small <- unique(it$data$x[it$data$n < 30])
      if (length(small)) w <- c(w, sprintf("'%s': %d categor%s on fewer than 30 records (%s).", t, length(small),
                                           if (length(small) == 1) "y rests" else "ies rest",
                                           paste(utils::head(small, 4), collapse = ", ")))
    }
  }
  if (include_pdm) {
    if (is.null(p)) w <- c(w, "The implementation errors are not computed: run the PDM / baseline analysis, or untick them.")
    else if (isTRUE(all.equal(unname(p$tolerance %||% tol_default), tol_default)))
      w <- c(w, "The tolerance band is still the default 5-20%: confirm it on the PDM tab.")
  }
  labs <- c(context = "Context", findings = "Key findings", recommendations = "Recommendations")
  for (k in intersect(names(labs), names(texts))) if (!nzchar(rich_text(texts[[k]]))) w <- c(w, sprintf("%s is empty.", labs[[k]]))
  w
}

#' The executive summary block: traffic-light tiles (with the change since
#' the previous round) and what to do
#'
#' @param ind From `monitoring_indicators()`.
#' @param prev Previous round's indicators (named numeric) or NULL.
#' @param prev_label Its label.
#' @param todo Character vector of actions.
#' @noRd
monitoring_summary_html <- function(ind, prev = NULL, prev_label = NULL, todo = character(0), lang = "en") {
  tr <- function(t) htmltools::htmlEscape(i18n_lookup(t, lang))
  fmt <- function(i, v) if (identical(i$format, "pct")) sprintf("%.1f%%", 100 * v) else format(round(v), big.mark = ",")
  state <- c(ok = "Good", warn = "Watch", bad = "Act", na = "")
  tiles <- vapply(ind, function(i) {
    delta <- ""
    if (!is.null(prev) && i$key %in% names(prev) && !is.na(prev[[i$key]])) {
      d <- i$value - prev[[i$key]]
      good <- if (identical(i$better, "up")) d > 0 else if (identical(i$better, "down")) d < 0 else NA
      txt <- if (identical(i$format, "pct")) sprintf("%+.1f pts", 100 * d) else paste0(if (d > 0) "+" else "", format(round(d), big.mark = ","))
      cls <- if (abs(d) < 1e-9 || is.na(good)) "flat" else if (good) "up" else "down"
      delta <- sprintf('<div class="mx-delta is-%s">%s %s %s</div>', cls,
                       if (d > 0) "\u25b2" else if (d < 0) "\u25bc" else "\u25cf", txt,
                       htmltools::htmlEscape(paste(i18n_lookup("since", lang), prev_label %||% "")))
    }
    sprintf('<div class="mx-tile is-%s"><div class="mx-top"><span class="mx-label">%s</span>%s</div><div class="mx-value">%s</div><div class="mx-sub">%s</div>%s</div>',
            i$band, tr(i$label), if (nzchar(state[[i$band]])) sprintf('<span class="mx-state"><i></i>%s</span>', tr(state[[i$band]])) else "",
            fmt(i, i$value), tr(i$sub), delta)
  }, character(1))
  todo_html <- if (length(todo)) paste0('<div class="mx-todo"><div class="mx-todo-head">', tr("What to do"), '</div><ol>',
                                        paste0("<li>", htmltools::htmlEscape(todo), "</li>", collapse = ""), '</ol></div>') else ""
  paste0(monitoring_summary_css(),
         if (length(tiles)) paste0('<div class="mx-tiles">', paste(tiles, collapse = ""), '</div>') else "",
         todo_html)
}

#' Styles of the executive summary, carried in the report itself
#' @noRd
monitoring_summary_css <- function() {
  # A quiet strip: figures side by side, hairline dividers, the status as a
  # small coloured dot and a word. No boxes, no thick borders.
  paste0('<style>',
         '.mx-tiles{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));margin:10px 0 18px;',
         'border-top:1px solid var(--line,#dde3ea);border-bottom:1px solid var(--line,#dde3ea)}',
         '.mx-tile{padding:12px 16px;border-left:1px solid var(--line,#dde3ea)}.mx-tile:first-child{border-left:0;padding-left:2px}',
         '.mx-top{display:flex;justify-content:space-between;align-items:baseline;gap:8px}',
         '.mx-label{font-size:10.5px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--muted,#5b6b7c)}',
         '.mx-state{font-size:11px;font-weight:600;color:var(--muted,#5b6b7c);white-space:nowrap}',
         '.mx-state i{display:inline-block;width:7px;height:7px;border-radius:50%;background:#8a96a3;margin-right:5px;vertical-align:1px}',
         '.is-ok .mx-state i{background:#3f7e44}.is-warn .mx-state i{background:#e0a100}.is-bad .mx-state i{background:#c5192d}',
         '.is-bad .mx-state{color:#c5192d}',
         '.mx-value{font-size:24px;font-weight:600;line-height:1.25;margin-top:6px;color:var(--ink,#1f2a37);font-variant-numeric:tabular-nums}',
         '.mx-sub{font-size:11.5px;color:var(--muted,#5b6b7c);margin-top:1px}',
         '.mx-delta{font-size:11.5px;font-weight:600;margin-top:5px}.mx-delta.is-up{color:#3f7e44}.mx-delta.is-down{color:#c5192d}.mx-delta.is-flat{color:#5b6b7c}',
         '.mx-todo{margin:0 0 18px}',
         '.mx-todo-head{font-size:10.5px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--muted,#5b6b7c)}',
         '.mx-todo ol{margin:6px 0 0 18px;padding:0}.mx-todo li{margin:2px 0}',
         '</style>')
}

#' The first actions of the recommendations text (and the verdict's action)
#' @noRd
monitoring_todo <- function(recommendations, verdict_action = NULL, n = 3) {
  txt <- rich_text(recommendations)
  parts <- unlist(strsplit(txt, "\n+|(?<=[.;!?])\\s+(?=[A-Z0-9])", perl = TRUE))
  parts <- trimws(sub("^[-*\u2022]\\s*|^[0-9]+[.)]\\s*", "", parts))
  parts <- parts[nchar(parts) > 3]
  c(utils::head(parts, n), if (!length(parts) && length(verdict_action) && nzchar(verdict_action)) verdict_action)
}

#' Headline indicators over the rounds, for the trend chart
#' @param rounds Previous rounds (from `monitoring_round()`), oldest first.
#' @param ind This round's indicators.
#' @noRd
monitoring_trend_chart <- function(rounds, ind, lang = "en") {
  keys <- names(ind)[vapply(ind, function(i) identical(i$format, "pct"), logical(1))]
  keys <- keys[vapply(keys, function(k) any(vapply(rounds, function(r) k %in% names(r$indicators), logical(1))), logical(1))]
  if (!length(keys) || !length(rounds)) return(NULL)
  lab <- c(vapply(rounds, `[[`, character(1), "label"), i18n_lookup("This round", lang))
  wide <- data.frame(round = make.unique(lab), check.names = FALSE)
  for (k in keys) {
    v <- c(vapply(rounds, function(r) if (k %in% names(r$indicators)) unname(r$indicators[[k]]) else NA_real_, numeric(1)), ind[[k]]$value)
    wide[[i18n_lookup(ind[[k]]$label, lang)]] <- round(100 * v, 1)
  }
  cols <- stats::setNames(rep_len(rp_cols$models, length(keys)), names(wide)[-1])
  rp_base(300) |>
    billboarder::bb_linechart(wide, type = "line") |>
    billboarder::bb_x_axis(type = "category", tick = list(multiline = FALSE)) |>
    billboarder::bb_y_axis(label = rp_axis_label("%"), min = 0, padding = list(bottom = 0)) |>
    rp_colors(cols)
}
