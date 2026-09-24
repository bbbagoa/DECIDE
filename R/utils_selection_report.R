#' Beneficiary selection report (HTML)
#'
#' The selection written up like the design and verification reports: the
#' headline figures, the data and how it was prepared, the design that drew
#' the list, who was selected (by area, and against who was not), a map of
#' selected and non-selected households, and the accuracy against a mapped
#' eligibility. One self-contained HTML file (see `report_write_page()`).
#'
#' @param x List: `country_office`, `sections` (from the module's
#'   `selection_sections()`), `totals` (named numbers: households, eligible,
#'   served, excluded, people), `by_area` (from `selection_by_area()`),
#'   `profile` (from `selection_profile()`), `map` (data.frame lon, lat,
#'   status, label, or NULL).
#' @noRd
write_selection_report <- function(file, x, lang = "en") {
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  kv <- function(v) md_table(data.frame(Item = names(v), Value = unname(v), check.names = FALSE))
  sec <- x$sections %||% list()

  add("# Beneficiary selection report", "",
      "This report records how the beneficiary list was drawn, from the registration data to the households served,",
      "so the selection can be reviewed, explained to communities and challenged.", "",
      "## Key results", "", "@@KPI@@", "")

  add("## 1. Data and preparation", "")
  for (nm in intersect(c("Data", "Data preparation (before selection)"), names(sec))) add(paste("###", nm), "", kv(sec[[nm]]), "")

  add("## 2. Selection design", "")
  for (nm in intersect(c("Selection", "Filters and rules", "Scorecard"), names(sec))) add(paste("###", nm), "", kv(sec[[nm]]), "")

  add("## 3. Who was selected", "")
  sm <- area_summary(x$by_area)
  if (!is.null(sm)) {
    add(sprintf("### Summary by %s", attr(sm, "level")), "",
        sprintf("%s units. The household-level list, with every area, is in the Excel export.", nrow(sm)), "",
        md_table(sm), "", "@@FIG:area@@", "")
  }
  if (!is.null(x$profile) && nrow(x$profile)) {
    add("### Selected compared with not selected", "",
        "Means for numbers, shares for categories. A wide gap shows where the selection tells the two groups apart.", "",
        md_table(data.frame(Indicator = x$profile$indicator, Selected = x$profile$selected,
                            `Not selected` = x$profile$not_selected, Difference = x$profile$difference,
                            check.names = FALSE)), "")
  }

  bp <- x$beneficiary_profile
  if (!is.null(bp) && (length(bp$tiles) || length(bp$vars))) {
    add("## 4. Who the beneficiaries are", "",
        "Socio-demographic and socio-economic profile of the households served.", "",
        "@@PROFILE@@", "",
        # Two charts per row.
        unlist(lapply(split(names(bp$vars), ceiling(seq_along(bp$vars) / 2)),
                      function(k) c(sprintf("@@FIG:%s@@", paste(k, collapse = ",")), ""))))
  }

  if (!is.null(x$map) && nrow(x$map)) {
    add(sprintf("## %d. Map", if (is.null(bp)) 4 else 5), "",
        sprintf("%s households with coordinates%s. The background map (OpenStreetMap) needs an internet connection; the points do not.",
                format(x$map_n %||% nrow(x$map), big.mark = ","),
                if (isTRUE(x$map_n > nrow(x$map))) sprintf(", %s of them drawn (an even sample, to keep the file light)",
                                                           format(nrow(x$map), big.mark = ",")) else ""), "",
        "@@FIG:map@@", "")
  }

  add(sprintf("## %d. Accuracy and notes", 4 + !is.null(bp) + (!is.null(x$map) && nrow(x$map) > 0)), "")
  for (nm in intersect(c("Accuracy against mapped eligibility", "Notes"), names(sec))) add(paste("###", nm), "", kv(sec[[nm]]), "")
  if ("Variable mapping" %in% names(sec)) add("### Variable mapping", "", kv(sec[["Variable mapping"]]), "")

  plots <- list()
  if (!is.null(sm)) {
    top <- utils::head(sm[order(-sm$Served), , drop = FALSE], 25)
    lab <- vapply(c("Served", "Excluded by design"), function(t) i18n_lookup(t, lang), character(1))
    d <- data.frame(area = top[[1]], top$Served, top$`Excluded by design`)
    names(d)[2:3] <- lab
    plots$area <- rp_hbars(d, stats::setNames(c("#0A6EB4", "#f7b825"), lab),
                           i18n_lookup("Households", lang), stacked = TRUE)
  }
  if (!is.null(bp)) for (nm in names(bp$vars)) plots[[nm]] <- rp_donut(bp$vars[[nm]])
  if (!is.null(x$map) && nrow(x$map)) plots$map <- selection_map(x$map, lang)

  report_write_page(
    file, paste(L, collapse = "\n"), plots,
    captions = c(area = "Households served and excluded by design (the 25 units serving most)",
                 map = "Selected and non-selected households",
                 if (!is.null(bp)) stats::setNames(vapply(bp$vars, function(v) attr(v, "label"), character(1)), names(bp$vars))),
    lang = lang, title = "Beneficiary selection report", record = "Beneficiary selection record",
    meta = c("Country office" = x$country_office %||% "",
             "Generated" = format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Served" = format(x$totals[["served"]] %||% NA, big.mark = ",")),
    footer = "This record documents the selection so it can be reviewed, explained and challenged.",
    blocks = list("@@KPI@@" = selection_kpis(x$totals, lang),
                  "@@PROFILE@@" = profile_tiles(bp$tiles, lang)))
}

#' Headline figures of the selection, as quiet tiles
#' @noRd
selection_kpis <- function(t, lang = "en") {
  if (is.null(t)) return("")
  tr <- function(s) htmltools::htmlEscape(i18n_lookup(s, lang))
  num <- function(v) if (is.null(v) || is.na(v)) "n/a" else format(round(v), big.mark = ",")
  pc <- function(a, b) if (is.null(a) || is.null(b) || is.na(a) || !isTRUE(b > 0)) "" else sprintf("%.1f%%", 100 * a / b)
  tile <- function(label, value, sub) sprintf('<div class="kpi"><div class="kpi-label">%s</div><div class="kpi-value">%s</div><div class="kpi-sub">%s</div></div>',
                                              tr(label), value, sub)
  paste0('<div class="kpis">',
         tile("Households served", num(t[["served"]]), paste(pc(t[["served"]], t[["households"]]), tr("of all households"))),
         tile("People served", num(t[["people"]]), tr("in the households served")),
         tile("Eligible by design", num(t[["eligible"]]), paste(pc(t[["eligible"]], t[["households"]]), tr("of all households"))),
         tile("Excluded by design", num(t[["excluded"]]), tr("eligible, not served for lack of resources")),
         '</div>')
}

#' Leaflet map of selected and non-selected households
#' @param d data.frame(lon, lat, status, label)
#' @noRd
selection_map <- function(d, lang = "en") {
  lv <- c("Served", "Excluded by design", "Not selected")
  cols <- c("#0A6EB4", "#f7b825", "#8a96a3")
  d$status <- factor(d$status, levels = lv)
  pal <- leaflet::colorFactor(cols, levels = lv)
  labs <- vapply(lv, function(t) i18n_lookup(t, lang), character(1))
  # Not selected first, so the served points are drawn on top.
  d <- d[order(-as.integer(d$status)), , drop = FALSE]
  leaflet::leaflet(d, width = "100%", height = 480) |>
    # OpenStreetMap's own tiles: no account or API key needed.
    leaflet::addTiles(attribution = "\u00a9 OpenStreetMap contributors") |>
    leaflet::addCircleMarkers(~lon, ~lat, radius = 3.5, stroke = FALSE, fillOpacity = 0.8,
                              fillColor = ~pal(status), label = ~label) |>
    leaflet::addLegend("bottomright", colors = cols, labels = labs, opacity = 0.9)
}

#' Points for the map: every household with coordinates, or an even sample
#' when there are too many for a portable file
#' @noRd
selection_map_points <- function(df, settings, s, max_points = 20000) {
  lon <- as.character(settings$lon %||% "")[1]; lat <- as.character(settings$lat %||% "")[1]
  if (is.na(lon) || is.na(lat) || !all(c(lon, lat) %in% names(df))) return(NULL)
  x <- as_number(df[[lon]]); y <- as_number(df[[lat]])
  ok <- which(is.finite(x) & is.finite(y) & abs(x) <= 180 & abs(y) <= 90)
  if (!length(ok)) return(NULL)
  n <- length(ok)
  if (n > max_points) ok <- ok[unique(round(seq(1, n, length.out = max_points)))]
  uid <- as.character(settings$unique_id %||% "")[1]
  status <- ifelse(s$prioritized[ok], "Served", ifelse(s$eligible[ok], "Excluded by design", "Not selected"))
  out <- data.frame(lon = x[ok], lat = y[ok], status = status,
                    label = if (!is.na(uid) && uid %in% names(df)) paste0(as.character(df[[uid]][ok]), ": ", status) else status,
                    stringsAsFactors = FALSE)
  attr(out, "n_total") <- n
  out
}

#' The per-area table rolled up to a readable level
#'
#' Admin 3 when it has at most 60 units, else Admin 2, else Admin 1: a
#' summary for the report, not the full list (that is in the Excel export).
#' @param by_area Output of `selection_by_area()`.
#' @noRd
area_summary <- function(by_area, max_units = 60) {
  if (is.null(by_area) || !nrow(by_area)) return(NULL)
  levels <- intersect(c("Admin 3", "Admin 2", "Admin 1"), names(by_area))
  if (!length(levels)) return(NULL)
  pick <- levels[length(levels)]
  for (lv in levels) if (length(unique(by_area[[lv]])) <= max_units) { pick <- lv; break }
  g <- by_area[[pick]]
  sm <- function(col) as.numeric(tapply(by_area[[col]], g, sum, na.rm = TRUE))
  out <- data.frame(Area = sort(unique(g)), stringsAsFactors = FALSE)
  out$Households <- sm("Households")
  out$Eligible <- sm("Eligible")
  out$Served <- sm("Served")
  out$`Excluded by design` <- sm("Excluded by design")
  out$`People served` <- sm("People served")
  out$`Served (%)` <- round(100 * out$Served / pmax(out$Households, 1), 1)
  out$`Eligible served (%)` <- ifelse(out$Eligible > 0, round(100 * out$Served / out$Eligible, 1), NA)
  out$`People per household served` <- ifelse(out$Served > 0, round(out$`People served` / out$Served, 1), NA)
  names(out)[1] <- pick
  out <- out[order(-out$Served), , drop = FALSE]
  total <- out[1, , drop = FALSE]
  total[[1]] <- "Total"
  for (k in c("Households", "Eligible", "Served", "Excluded by design", "People served")) total[[k]] <- sum(out[[k]])
  total$`Served (%)` <- round(100 * total$Served / max(total$Households, 1), 1)
  total$`Eligible served (%)` <- if (total$Eligible > 0) round(100 * total$Served / total$Eligible, 1) else NA
  total$`People per household served` <- if (total$Served > 0) round(total$`People served` / total$Served, 1) else NA
  out <- rbind(out, total)
  rownames(out) <- NULL
  attr(out, "level") <- pick
  out
}

#' Socio-demographic and socio-economic profile of the households served
#'
#' Mapped fields (head of household sex, residency, disability, children under
#' 5, household size, head's age) plus columns found by name (marital status,
#' chronic illness). Returns donut data per categorical variable and headline
#' tiles.
#' @param df The households served.
#' @noRd
beneficiary_profile <- function(df, settings) {
  if (is.null(df) || !nrow(df)) return(NULL)
  col <- function(k) { v <- as.character(settings[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v) && v %in% names(df)) v else NULL }
  find <- function(pat) { hit <- grep(pat, names(df), ignore.case = TRUE, value = TRUE); hit <- hit[!grepl("^@?_", hit)]; if (length(hit)) hit[1] else NULL }
  pct <- function(x) sprintf("%.0f%%", 100 * x)
  shares <- function(v, label, top = 6) {
    v <- as.character(v); v[is.na(v) | !nzchar(trimws(v))] <- "Not answered"
    tb <- sort(table(v), decreasing = TRUE)
    if (length(tb) > top) tb <- c(tb[seq_len(top - 1)], Other = sum(tb[-seq_len(top - 1)]))
    out <- data.frame(category = names(tb), n = as.integer(tb), stringsAsFactors = FALSE)
    attr(out, "label") <- label
    out
  }
  yes_share <- function(v) { f <- eligibility_flag(v); if (all(is.na(f))) NA_real_ else mean(f, na.rm = TRUE) }

  vars <- list(); tiles <- list()
  sx <- col("hhh_sex")
  if (!is.null(sx)) {
    vars$sex <- shares(df[[sx]], "Head of household sex")
    fem <- mean(is_female(df[[sx]]))
    tiles[[length(tiles) + 1]] <- list(icon = "female", label = "Female-headed", value = pct(fem),
                                       sub = sprintf("%s male-headed", pct(1 - fem)))
  }
  rs <- col("residency")
  if (!is.null(rs)) {
    vars$residency <- shares(df[[rs]], "Residency status")
    v <- tolower(as.character(df[[rs]]))
    idp <- mean(grepl("idp|displac|d\u00e9plac|deplac", v)); ref <- mean(grepl("refug|r\u00e9fug", v))
    if (idp > 0 || ref > 0) tiles[[length(tiles) + 1]] <- list(icon = "shelter", label = "Displaced", value = pct(idp + ref),
                                                               sub = sprintf("IDP %s \u00b7 refugee %s", pct(idp), pct(ref)))
  }
  ms <- find("marital|matrimon|civil_status|etat_civil|statut_mat")
  if (!is.null(ms)) vars$marital <- shares(df[[ms]], "Marital status of the head")
  ds <- col("disability") %||% find("disab|handicap")
  if (!is.null(ds)) {
    vars$disability <- shares(df[[ds]], "Disability")
    y <- yes_share(df[[ds]])
    if (!is.na(y)) tiles[[length(tiles) + 1]] <- list(icon = "disability", label = "With a disability", value = pct(y), sub = "households")
  }
  ci <- find("chronic|chroniq")
  if (!is.null(ci)) {
    vars$chronic <- shares(df[[ci]], "Chronic illness")
    y <- yes_share(df[[ci]])
    if (!is.na(y)) tiles[[length(tiles) + 1]] <- list(icon = "health", label = "Chronic illness", value = pct(y), sub = "households")
  }
  hs <- col("hh_size")
  if (!is.null(hs)) {
    z <- as_number(df[[hs]])
    tiles[[length(tiles) + 1]] <- list(icon = "family", label = "Household size", value = sprintf("%.1f", mean(z, na.rm = TRUE)),
                                       sub = sprintf("%s people in all", format(sum(z, na.rm = TRUE), big.mark = ",")))
  }
  cu <- col("childU5")
  if (!is.null(cu)) {
    z <- as_number(df[[cu]])
    if (any(!is.na(z))) tiles[[length(tiles) + 1]] <- list(icon = "child", label = "With children under 5", value = pct(mean(z > 0, na.rm = TRUE)),
                                                           sub = sprintf("%.1f per household", mean(z, na.rm = TRUE)))
  }
  ag <- col("hhh_age")
  if (!is.null(ag)) {
    z <- as_number(df[[ag]])
    if (any(!is.na(z))) tiles[[length(tiles) + 1]] <- list(icon = "elderly", label = "Head aged 60+", value = pct(mean(z >= 60, na.rm = TRUE)),
                                                           sub = sprintf("median age %.0f", stats::median(z, na.rm = TRUE)))
  }
  if (!length(vars) && !length(tiles)) return(NULL)
  list(vars = vars, tiles = tiles)
}

#' Simple humanitarian-style pictograms, inline SVG (no icon font, no network)
#' @noRd
profile_icon <- function(name) {
  p <- switch(name,
    female = '<circle cx="12" cy="5" r="3"/><path d="M12 9c-2.2 0-3.6 1.6-4.3 4.2L6.5 17h3v4h5v-4h3l-1.2-3.8C15.6 10.6 14.2 9 12 9z"/>',
    shelter = '<path d="M12 3 2 20h20L12 3zm0 5.2L17.8 18H14v-4h-4v4H6.2L12 8.2z"/>',
    disability = '<circle cx="11" cy="4" r="2"/><path d="M9 7h3v5h4.5l2.8 6.2-1.8.8-2.2-5H10.5A1.5 1.5 0 0 1 9 12.5V7z"/><path d="M8 10.6v2A4.5 4.5 0 1 0 14.4 18h2.1A6.5 6.5 0 1 1 8 10.6z"/>',
    health = '<path d="M12 21s-7.5-4.6-9.5-9.3C1.2 8.4 3.3 5 6.6 5c2 0 3.4 1.1 4.2 2.4h2.4C14 6.1 15.4 5 17.4 5c3.3 0 5.4 3.4 4.1 6.7C19.5 16.4 12 21 12 21z"/><path d="M11 9h2v2h2v2h-2v2h-2v-2H9v-2h2z" fill="#fff"/>',
    family = '<circle cx="7" cy="5" r="2.3"/><circle cx="17" cy="5" r="2.3"/><circle cx="12" cy="11" r="1.8"/><path d="M4 9h6v7H9v5H5v-5H4zM14 9h6v7h-1v5h-4v-5h-1zM10.5 14h3v7h-3z"/>',
    child = '<circle cx="12" cy="6" r="2.6"/><path d="M8.5 10h7l-1 6h-1.5v5h-3v-5H9.5z"/>',
    elderly = '<circle cx="10" cy="4" r="2.2"/><path d="M8 7.5h3.5l1.5 4 2 1-1 1.5-2.4-1.2L12 16l1.5 5h-2.2L10 17l-1 4H7l1.2-6L8 7.5z"/><path d="M15.5 12h1l1 9h-1z"/>',
    '<circle cx="12" cy="12" r="8"/>')
  sprintf('<svg viewBox="0 0 24 24" aria-hidden="true">%s</svg>', p)
}

#' The profile's headline tiles
#' @noRd
profile_tiles <- function(tiles, lang = "en") {
  if (!length(tiles)) return("")
  tr <- function(s) htmltools::htmlEscape(i18n_lookup(s, lang))
  paste0('<div class="ptiles">', paste(vapply(tiles, function(t) sprintf(
    '<div class="ptile"><div class="ptile-ico">%s</div><div><div class="ptile-value">%s</div><div class="ptile-label">%s</div><div class="ptile-sub">%s</div></div></div>',
    profile_icon(t$icon), htmltools::htmlEscape(t$value), tr(t$label), htmltools::htmlEscape(t$sub)), character(1)), collapse = ""), '</div>')
}
