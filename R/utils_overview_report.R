#' Overview report (HTML)
#'
#' The Overview page as a self-contained report, from the same functions
#' (`ov_collection()`, `ov_profile()`, `ov_vulnerability()`): the data
#' collection, who is in the data, their vulnerability and how it differs
#' across household profiles, where the data comes from, and the map. Covers
#' the Overview's filters and, when the figures follow a zoomed map, that map
#' view, which it states. Same page writer and look as the other reports
#' (`report_write_page()`).
#'
#' @param df The data covered (the Overview's filtered data, or the map view).
#' @param x List: `country_office`, `source`, `n_total` (records in the
#'   data), `areas`, `period`, `view` (the map view, when zoomed).
#' @noRd
write_overview_report <- function(file, df, settings, x, lang = "en") {
  col <- function(k) ov_col(settings, df, k)
  num <- function(v) format(round(v), big.mark = ",")
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  tiles_of <- function(t) lapply(t, function(z) list(z$label, z$value, z$sub %||% ""))
  as_var <- function(ch) { d <- data.frame(category = ch$data$category, n = round(ch$data$n, 1), stringsAsFactors = FALSE); attr(d, "label") <- ch$title; d }
  n <- nrow(df)
  plots <- list(); caps <- character(0); blocks <- list()
  cl <- ov_collection(df, settings)
  pr <- ov_profile(df, settings)
  v <- ov_vulnerability(df, settings)
  mp <- overview_map_points(df, settings)
  notes <- character(0)

  # At a glance: the key findings in sentences, then the headline figures
  add("# Overview", "",
      "What was collected, when and where, who the households are and how vulnerable they are.", "",
      "## At a glance", "", "@@GLANCE@@", "", "@@KPI@@", "")
  blocks[["@@GLANCE@@"]] <- paste0('<div class="tw-glance"><ul>',
    paste(sprintf("<li>%s</li>", htmltools::htmlEscape(ov_key_findings(n, cl, pr, v, if (!is.null(mp)) attr(mp, "n_total")))), collapse = ""), '</ul></div>')

  add("## 1. Data and coverage", "", "@@META@@", "")
  blocks[["@@META@@"]] <- ov_meta_html(c(
    "Source" = x$source %||% "not recorded", "Records in the data" = num(x$n_total), "Records in this report" = num(n),
    "Areas covered" = x$areas %||% "All areas", "Period covered" = x$period %||% "All dates",
    "Map view" = if (shiny::isTruthy(x$view)) paste0(x$view, " (the figures followed the map)") else ""))

  sec <- 2
  en <- col("enumerator_id"); dt <- col("date")
  if (!is.null(cl$daily)) {
    add(sprintf("## %d. Data collection", sec), "", "@@FIG:days@@", "")
    d <- cl$daily; d$day <- format(d$day, "%d %b")
    ord <- unique(d$day[order(cl$daily$day)])
    wide <- stats::reshape(stats::aggregate(n ~ day + area, d, sum), idvar = "day", timevar = "area", direction = "wide")
    names(wide) <- sub("^n\\.", "", names(wide)); wide[is.na(wide)] <- 0
    wide <- wide[match(ord, wide$day), , drop = FALSE]
    for (k in names(wide)[-1]) wide[[k]] <- round(wide[[k]], 1)
    areas <- names(wide)[-1]
    plots$days <- rp_base(260) |>
      billboarder::bb_barchart(wide, stacked = length(areas) > 1) |>
      billboarder::bb_x_axis(type = "category", tick = list(culling = list(max = 12), multiline = FALSE)) |>
      rp_colors(stats::setNames(rep_len(c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#8a96a3"), length(areas)), areas)) |>
      billboarder::bb_legend(show = length(areas) > 1)
    caps[["days"]] <- if (length(areas) > 1) sprintf("Households registered per day, by %s", cl$area_label %||% "area") else "Households registered per day"
    if (!is.null(en)) {
      day <- suppressWarnings(as.Date(df[[dt]]))
      e <- data.frame(en = as.character(df[[en]]), day = day)
      e <- e[!is.na(e$en) & nzchar(e$en), , drop = FALSE]
      if (nrow(e)) {
        agg <- do.call(rbind, lapply(split(e, e$en), function(g) data.frame(
          Enumerator = g$en[1], Interviews = nrow(g), Days = length(unique(stats::na.omit(g$day))),
          `Per day` = round(nrow(g) / max(1, length(unique(stats::na.omit(g$day)))), 1),
          First = format(suppressWarnings(min(g$day, na.rm = TRUE)), "%d %b"), Last = format(suppressWarnings(max(g$day, na.rm = TRUE)), "%d %b"),
          check.names = FALSE)))
        agg <- agg[order(-agg$Interviews), , drop = FALSE]
        add("### By enumerator", "", if (nrow(agg) > 30) "The 30 enumerators with the most interviews." else NULL, "",
            md_table(utils::head(agg, 30)), "")
      }
    }
    sec <- sec + 1
  }

  if (!is.null(pr)) {
    add(sprintf("## %d. Who is in the data", sec), "", "@@PROFILE@@", "")
    blocks[["@@PROFILE@@"]] <- ov_tiles_html(pr$tiles)
    if (length(pr$charts)) {
      sc <- rp_share_charts(lapply(pr$charts, as_var), lang = lang)
      add(sc$rows); plots <- c(plots, sc$plots); caps <- c(caps, sc$captions)
    }
    notes <- c(notes, "Shares of households are counted on the households that answered; \"with children under 5\", \"with pregnant or lactating women\" and similar mean at least one such member (a count above zero or a yes).")
    sec <- sec + 1
  }

  if (!is.null(v)) {
    add(sprintf("## %d. Vulnerability", sec), "", "@@VULN@@", "")
    blocks[["@@VULN@@"]] <- ov_tiles_html(v$tiles)
    if (!is.null(v$groups)) {
      g <- v$groups
      add("### Vulnerability groups", "", sprintf("From the least to the most vulnerable%s.", if (!is.null(col("v_score"))) " (ordered by their mean score)" else ""), "",
          "@@GROUPS@@", "")
      blocks[["@@GROUPS@@"]] <- ov_bar_table_html(
        data.frame(label = g$group, n = g$households, value = g$households / sum(g$households),
                   extra = if (all(is.na(g$people))) "" else num(g$people), stringsAsFactors = FALSE),
        "Share of households", colours = vapply(seq_len(nrow(g)) / nrow(g), diagram_colour, ""),
        extra_label = if (all(is.na(g$people))) "" else "People")
      notes <- c(notes, sprintf("The most vulnerable groups are %s: the %s of the %d groups%s.", paste(v$top_groups, collapse = " and "),
                                if (length(v$top_groups) > 1) "two highest" else "highest", nrow(g),
                                if (!is.null(col("v_score"))) " by mean score" else " by the severity their names express"))
    }
    if (!is.null(v$score)) {
      s <- data.frame(score = v$score$category, Households = round(v$score$n, 1))
      plots$score <- rp_base(240) |> billboarder::bb_barchart(s) |> rp_colors(c(Households = "#0A6EB4")) |>
        billboarder::bb_legend(show = FALSE) |> billboarder::bb_x_axis(tick = list(multiline = FALSE))
      caps[["score"]] <- "Distribution of the vulnerability score"
      add("@@FIG:score@@", "")
    }
    cr <- v$cross
    if (!is.null(cr) && nrow(cr)) {
      pct <- !identical(v$indicator, "score")
      first <- cr$dimension == cr$dimension[1]
      overall <- ov_wmean(cr$value[first], cr$households[first])
      add("### Across household profiles", "",
          sprintf("%s in each group of households; the line marks the overall figure. A group far from it is where vulnerability concentrates.", v$indicator_label), "",
          "@@CROSS@@", "")
      blocks[["@@CROSS@@"]] <- ov_bar_table_html(data.frame(group = cr$dimension, label = cr$category, n = cr$households, value = cr$value, stringsAsFactors = FALSE),
                                                 v$indicator_label, pct = pct, overall = overall)
    }
    sec <- sec + 1
  } else {
    # No vulnerability mapped: the usual socio-economic indicators, found by
    # column name, stand in.
    se <- socioeconomic_indicators(df)
    if (!is.null(se)) {
      add(sprintf("## %d. Socio-economic situation", sec), "",
          "No vulnerability group, eligibility or score is mapped in the variable setup; these indicators were found in the data by their column names.", "")
      if (!is.null(se$numbers)) add(md_table(se$numbers), "")
      if (length(se$vars)) {
        sv <- rp_share_charts(se$vars, lang = lang)
        add(sv$rows); plots <- c(plots, sv$plots); caps <- c(caps, sv$captions)
      }
      sec <- sec + 1
    }
  }

  ga <- overview_by_area(df, settings)
  if (!is.null(ga)) {
    add(sprintf("## %d. Where the data comes from", sec), "", "Each Admin 1 subtotal is followed by its Admin 2 units.", "", "@@AREAS@@", "")
    sec <- sec + 1
  }

  if (!is.null(mp)) {
    add(sprintf("## %d. Map", sec), "",
        sprintf("%s households with coordinates%s.", num(attr(mp, "n_total")),
                if (attr(mp, "n_total") > nrow(mp)) sprintf(", %s drawn (an even sample)", num(nrow(mp))) else ""), "",
        "@@FIG:map@@", "")
    plots$map <- overview_map(mp); caps[["map"]] <- if (!is.null(col("v_groups"))) "Households by vulnerability group" else "Households registered"
    notes <- c(notes, "The background map (Esri) needs an internet connection; the points and every other part of this report do not.")
    sec <- sec + 1
  }

  add("## Notes and definitions", "",
      paste0("- ", c("Every household counts once: registration data lists the whole population, so no sampling weight is applied.",
                     "Figures cover the areas, the period and, when stated, the map view listed under Data and coverage.",
                     notes)), "")

  report_write_page(
    file, paste(L, collapse = "\n"), plots, captions = caps, lang = lang,
    title = "Overview", record = "Data collection record",
    meta = c("Country office" = x$country_office %||% "", "Generated" = format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Areas covered" = x$areas %||% "All areas", "Households" = num(n)),
    footer = "This record summarises the data collected, as shown on the Overview page.",
    blocks = c(list("@@KPI@@" = overview_kpis(tiles_of(cl$tiles), lang), "@@AREAS@@" = area_summary_html(ga)), blocks))
}

#' Headline figures as quiet tiles (label, value, sub)
#' @noRd
overview_kpis <- function(tiles, lang = "en") {
  if (!length(tiles)) return("")
  tr <- function(s) htmltools::htmlEscape(i18n_lookup(s, lang))
  paste0('<div class="kpis">', paste(vapply(tiles, function(t) sprintf(
    '<div class="kpi"><div class="kpi-label">%s</div><div class="kpi-value">%s</div><div class="kpi-sub">%s</div></div>',
    tr(t[[1]]), htmltools::htmlEscape(t[[2]]), htmltools::htmlEscape(t[[3]])), character(1)), collapse = ""), '</div>')
}

#' Households per area, grouped Admin 1 > Admin 2 (the shape `area_summary_html()` draws)
#' @noRd
overview_by_area <- function(df, settings) {
  col <- function(k) { v <- as.character(settings[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v) && v %in% names(df)) v else NULL }
  a1 <- col("admin1"); if (is.null(a1)) return(NULL)
  a2 <- col("admin2"); hs <- col("hh_size"); sx <- col("hhh_sex"); vs <- col("v_score")
  size <- if (is.null(hs)) NULL else as_number(df[[hs]])
  fem <- if (is.null(sx)) NULL else is_female(df[[sx]])
  score <- if (is.null(vs)) NULL else as_number(df[[vs]])
  metrics <- function(i) {
    out <- data.frame(Households = length(i), check.names = FALSE)
    if (!is.null(size)) { out$Individuals <- sum(size[i], na.rm = TRUE); out$`Household size` <- round(mean(size[i], na.rm = TRUE), 1) }
    if (!is.null(fem)) out$`Female-headed (%)` <- round(100 * mean(fem[i]), 1)
    if (!is.null(score)) out$`Mean score` <- round(mean(score[i], na.rm = TRUE), 1)
    out
  }
  g1 <- as.character(df[[a1]]); g1[is.na(g1)] <- "(missing)"
  g2 <- if (is.null(a2)) NULL else { v <- as.character(df[[a2]]); v[is.na(v)] <- "(missing)"; v }
  rows <- list()
  for (g in names(sort(table(g1), decreasing = TRUE))) {
    i1 <- which(g1 == g)
    rows[[length(rows) + 1]] <- cbind(data.frame(Area = g, .kind = "group", stringsAsFactors = FALSE), metrics(i1))
    if (!is.null(g2)) for (u in names(sort(table(g2[i1]), decreasing = TRUE))) {
      rows[[length(rows) + 1]] <- cbind(data.frame(Area = u, .kind = "unit", stringsAsFactors = FALSE), metrics(i1[g2[i1] == u]))
    }
  }
  rows[[length(rows) + 1]] <- cbind(data.frame(Area = "Total", .kind = "total", stringsAsFactors = FALSE), metrics(seq_len(nrow(df))))
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

#' Points for the Overview map (every household, or an even sample)
#' @noRd
overview_map_points <- function(df, settings, max_points = 20000) {
  lon <- as.character(settings$lon %||% "")[1]; lat <- as.character(settings$lat %||% "")[1]
  if (is.na(lon) || is.na(lat) || !all(c(lon, lat) %in% names(df))) return(NULL)
  x <- as_number(df[[lon]]); y <- as_number(df[[lat]])
  ok <- which(is.finite(x) & is.finite(y) & abs(x) <= 180 & abs(y) <= 90)
  if (!length(ok)) return(NULL)
  n <- length(ok)
  if (n > max_points) ok <- ok[unique(round(seq(1, n, length.out = max_points)))]
  vg <- as.character(settings$v_groups %||% "")[1]
  grp <- if (!is.na(vg) && nzchar(vg) && vg %in% names(df)) as.character(df[[vg]][ok]) else rep("Household", length(ok))
  grp[is.na(grp) | !nzchar(grp)] <- "Not answered"
  out <- data.frame(lon = x[ok], lat = y[ok], group = grp, stringsAsFactors = FALSE)
  attr(out, "n_total") <- n
  out
}

#' The Overview map in the report: Esri terrain, points by vulnerability group
#' @noRd
overview_map <- function(d) {
  lv <- names(sort(table(d$group), decreasing = TRUE))
  cols <- rep_len(c("#0A6EB4", "#f7b825", "#c5192d", "#3f7e44", "#26bde2", "#8a96a3"), length(lv))
  pal <- leaflet::colorFactor(cols, levels = lv)
  esri_basemap(leaflet::leaflet(d, width = "100%", height = 460)) |>
    leaflet::addCircleMarkers(~lon, ~lat, radius = 3.5, stroke = FALSE, fillOpacity = 0.8, fillColor = ~pal(group), label = ~group) |>
    leaflet::addLegend("bottomright", colors = cols, labels = lv, opacity = 0.9) |>
    fit_to_points(d$lon, d$lat)
}

#' The app's basemaps on a report map: Esri terrain by default, light-grey
#' canvas and satellite to switch to; keyless, and served to a page opened
#' from a local file
#' @noRd
esri_basemap <- function(m) {
  groups <- c("Terrain", "Light", "Satellite", "Satellite (Clarity)")
  m |>
    add_esri_bases(groups) |>
    leaflet::hideGroup(setdiff(groups, "Terrain")) |>
    leaflet::addLayersControl(baseGroups = groups, position = "topright",
                              options = leaflet::layersControlOptions(collapsed = TRUE)) |>
    leaflet::addScaleBar(position = "bottomleft", options = leaflet::scaleBarOptions(imperial = FALSE))
}

#' Common socio-economic indicators, found by column name
#'
#' Food consumption, coping, income, expenditure, shelter, water, assets...
#' Numbers are summarised in a table; categories (12 or fewer) become charts.
#' @return list(numbers = data.frame or NULL, vars = named list for
#'   `rp_share_charts()`), or NULL when nothing is found.
#' @noRd
socioeconomic_indicators <- function(df, max_vars = 8) {
  ind <- list(
    list("Food consumption group", "fcg|fcs_?(cat|group|class|thresh)", "cat"),
    list("Food consumption score", "fcs", "num"),
    list("Reduced coping strategies", "rcsi", "any"),
    list("Household dietary diversity", "hdds", "num"),
    list("Livelihood coping strategies", "lcs|lhcs|coping_?strat", "cat"),
    list("Main source of income", "income_?(source|main)|main_?income|livelihood|source.*reven|activit", "cat"),
    list("Income", "income|revenu", "num"),
    list("Food expenditure share", "fes$|food_?exp.*(share|pct|prop)", "num"),
    list("Total expenditure", "expend|depense", "num"),
    list("Debt", "debt|dette", "any"),
    list("Shelter type", "shelter|abri|housing|logement", "cat"),
    list("Water source", "water|eau", "cat"),
    list("Land access", "land|terre", "any"),
    list("Livestock", "livestock|tlu|betail|cheptel", "any"),
    list("Assets", "asset|biens", "num"))
  cols <- names(df)[!grepl("^@?_", names(df))]
  used <- character(0); vars <- list(); rows <- list()
  for (it in ind) {
    if (length(vars) + length(rows) >= max_vars) break
    for (cl in setdiff(grep(it[[2]], cols, ignore.case = TRUE, value = TRUE), used)) {
      v <- df[[cl]]; k <- length(unique(stats::na.omit(v)))
      z <- as_number(v); numeric <- k > 12 && mean(!is.na(z[!is.na(v)])) >= 0.8
      if (it[[3]] != "cat" && numeric) {
        z <- z[!is.na(z)]
        q <- stats::quantile(z, c(.25, .5, .75), names = FALSE)
        rows[[length(rows) + 1]] <- data.frame(Indicator = it[[1]], Column = cl, Answered = format(length(z), big.mark = ","),
                                               Mean = sprintf("%.1f", mean(z)), Median = sprintf("%.1f", q[2]),
                                               `Q1 to Q3` = sprintf("%.1f to %.1f", q[1], q[3]), check.names = FALSE)
      } else if (it[[3]] != "num" && k >= 2 && k <= 12) {
        x <- as.character(v); x[is.na(x) | !nzchar(trimws(x))] <- "Not answered"
        tb <- sort(table(x), decreasing = TRUE)
        d <- data.frame(category = names(tb), n = as.integer(tb), stringsAsFactors = FALSE)
        attr(d, "label") <- sprintf("%s (%s)", it[[1]], cl)
        vars[[paste0("se_", length(vars) + 1)]] <- d
      } else next
      used <- c(used, cl)
      break
    }
  }
  if (!length(vars) && !length(rows)) return(NULL)
  list(numbers = if (length(rows)) do.call(rbind, rows), vars = vars)
}
