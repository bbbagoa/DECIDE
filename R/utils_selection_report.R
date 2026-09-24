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
  if (!is.null(x$by_area) && nrow(x$by_area)) {
    add("@@FIG:area@@", "", "### By area", "",
        if (nrow(x$by_area) > 100) "The 100 areas with the most households served are listed; the Excel export has them all." else NULL, "",
        md_table(utils::head(x$by_area[order(-x$by_area$Served), , drop = FALSE], 100)), "")
  }
  if (!is.null(x$profile) && nrow(x$profile)) {
    add("### Selected compared with not selected", "",
        "Means for numbers, shares for categories. A wide gap shows where the selection tells the two groups apart.", "",
        md_table(data.frame(Indicator = x$profile$indicator, Selected = x$profile$selected,
                            `Not selected` = x$profile$not_selected, Difference = x$profile$difference,
                            check.names = FALSE)), "")
  }

  if (!is.null(x$map) && nrow(x$map)) {
    add("## 4. Map", "",
        sprintf("%s households with coordinates%s. The background map needs an internet connection; the points do not.",
                format(x$map_n %||% nrow(x$map), big.mark = ","),
                if (isTRUE(x$map_n > nrow(x$map))) sprintf(", %s of them drawn (an even sample, to keep the file light)",
                                                           format(nrow(x$map), big.mark = ",")) else ""), "",
        "@@FIG:map@@", "")
  }

  add(sprintf("## %d. Accuracy and notes", if (is.null(x$map) || !nrow(x$map)) 4 else 5), "")
  for (nm in intersect(c("Accuracy against mapped eligibility", "Notes"), names(sec))) add(paste("###", nm), "", kv(sec[[nm]]), "")
  if ("Variable mapping" %in% names(sec)) add("### Variable mapping", "", kv(sec[["Variable mapping"]]), "")

  plots <- list()
  if (!is.null(x$by_area) && nrow(x$by_area)) {
    top <- utils::head(x$by_area[order(-x$by_area$Served), , drop = FALSE], 25)
    area <- do.call(paste, c(top[intersect(names(top), AREA_LEVELS)], sep = " / "))
    lab <- vapply(c("Served", "Excluded by design"), function(t) i18n_lookup(t, lang), character(1))
    d <- data.frame(area = area, top$Served, top$`Excluded by design`)
    names(d)[2:3] <- lab
    plots$area <- rp_hbars(d, stats::setNames(c("#0A6EB4", "#f7b825"), lab),
                           i18n_lookup("Households", lang), stacked = TRUE)
  }
  if (!is.null(x$map) && nrow(x$map)) plots$map <- selection_map(x$map, lang)

  report_write_page(
    file, paste(L, collapse = "\n"), plots,
    captions = c(area = "Households served and excluded by design, by area (top 25)",
                 map = "Selected and non-selected households"),
    lang = lang, title = "Beneficiary selection report", record = "Beneficiary selection record",
    meta = c("Country office" = x$country_office %||% "",
             "Generated" = format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Served" = format(x$totals[["served"]] %||% NA, big.mark = ",")),
    footer = "This record documents the selection so it can be reviewed, explained and challenged.",
    blocks = list("@@KPI@@" = selection_kpis(x$totals, lang)))
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
    leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) |>
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
