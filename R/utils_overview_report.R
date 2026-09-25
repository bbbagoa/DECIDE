#' Data collection summary report (HTML)
#'
#' What the Overview page shows, as a self-contained report: how much was
#' collected, where, when and by whom, who was surveyed, how vulnerable they
#' are, and a map. Covers the Overview's filters (areas and period), which it
#' states. Same page writer and look as the other reports
#' (`report_write_page()`).
#'
#' @param df The data covered (the Overview's filtered data).
#' @param x List: `country_office`, `source`, `n_total` (records in the
#'   data), `areas`, `period`.
#' @noRd
write_overview_report <- function(file, df, settings, x, lang = "en") {
  col <- function(k) { v <- as.character(settings[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v) && v %in% names(df)) v else NULL }
  num <- function(v) format(round(v), big.mark = ",")
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  kv <- function(v) md_table(data.frame(Item = names(v), Value = unname(v), check.names = FALSE))
  n <- nrow(df)
  hs <- col("hh_size"); people <- if (is.null(hs)) NA else sum(as_number(df[[hs]]), na.rm = TRUE)
  en <- col("enumerator_id"); dt <- col("date")
  day <- if (is.null(dt)) NULL else suppressWarnings(as.Date(df[[dt]]))
  vill <- col("village") %||% col("admin4") %||% col("admin3")
  wcol <- col("weight"); w <- if (is.null(wcol)) NULL else as_number(df[[wcol]])

  totals <- list(
    list("Households", num(n), sprintf("%s of the %s records in the data", if (x$n_total > 0) sprintf("%.0f%%", 100 * n / x$n_total) else "", num(x$n_total))),
    if (!is.na(people)) list("Individuals", num(people), sprintf("%.1f per household", people / max(n, 1))),
    if (!is.null(vill)) list("Communities", num(length(unique(stats::na.omit(df[[vill]])))), sprintf("distinct %s", vill)),
    if (!is.null(en)) list("Enumerators", num(length(unique(stats::na.omit(df[[en]])))), sprintf("%.0f interviews each on average", n / max(1, length(unique(stats::na.omit(df[[en]])))))),
    if (!is.null(day) && any(!is.na(day))) list("Days of collection", num(length(unique(stats::na.omit(day)))),
                                                sprintf("%s to %s", format(min(day, na.rm = TRUE)), format(max(day, na.rm = TRUE)))),
    if (!is.null(w)) list("Weighted households", num(sum(w, na.rm = TRUE)), sprintf("population estimate (weight: %s)", wcol)))
  totals <- Filter(Negate(is.null), totals)

  add("# Data collection summary", "",
      "What was collected, where, when and by whom, and who the households are: the summary behind the Overview page.", "",
      "## Key figures", "", "@@KPI@@", "")

  add("## 1. Data and coverage", "",
      kv(c("Source" = x$source %||% "not recorded", "Records in the data" = num(x$n_total), "Records covered by this report" = num(n),
           "Areas covered" = x$areas %||% "All areas", "Period covered" = x$period %||% "All dates")), "")

  ga <- overview_by_area(df, settings)
  if (!is.null(ga)) add("## 2. Where the data comes from", "",
                        "Each Admin 1 subtotal is followed by its Admin 2 units.", "", "@@AREAS@@", "")

  plots <- list(); caps <- character(0)
  sec <- 3
  if (!is.null(day) && any(!is.na(day))) {
    add(sprintf("## %d. Collection over time", sec), "", "@@FIG:days@@", "")
    tb <- table(day)
    d <- data.frame(day = names(tb), Interviews = as.integer(tb))
    plots$days <- rp_base(280) |>
      billboarder::bb_linechart(d, type = "area-spline") |>
      billboarder::bb_x_axis(type = "category", tick = list(culling = list(max = 10), multiline = FALSE)) |>
      rp_colors(c(Interviews = "#0A6EB4")) |>
      billboarder::bb_legend(show = FALSE)
    caps[["days"]] <- "Interviews per day"
    if (!is.null(en)) {
      e <- data.frame(en = as.character(df[[en]]), day = day)
      e <- e[!is.na(e$en) & nzchar(e$en), , drop = FALSE]
      if (nrow(e)) {
        agg <- do.call(rbind, lapply(split(e, e$en), function(g) data.frame(
          Enumerator = g$en[1], Interviews = nrow(g), Days = length(unique(stats::na.omit(g$day))),
          `Per day` = round(nrow(g) / max(1, length(unique(stats::na.omit(g$day)))), 1),
          First = format(suppressWarnings(min(g$day, na.rm = TRUE))), Last = format(suppressWarnings(max(g$day, na.rm = TRUE))),
          check.names = FALSE)))
        agg <- agg[order(-agg$Interviews), , drop = FALSE]
        add("### By enumerator", "",
            if (nrow(agg) > 30) "The 30 enumerators with the most interviews." else NULL, "",
            md_table(utils::head(agg, 30)), "")
      }
    }
    sec <- sec + 1
  }

  bp <- beneficiary_profile(df, settings)
  if (!is.null(bp) && (length(bp$tiles) || length(bp$vars))) {
    sc <- rp_share_charts(bp$vars, lang = lang)
    add(sprintf("## %d. Who was surveyed", sec), "", "@@PROFILE@@", "", sc$rows)
    plots <- c(plots, sc$plots); caps <- c(caps, sc$captions)
    sec <- sec + 1
  }

  vg <- col("v_groups"); el <- col("eligibility"); vs <- col("v_score")
  if (!is.null(vg) || !is.null(el) || !is.null(vs)) {
    add(sprintf("## %d. Vulnerability", sec), "")
    vv <- list()
    shares <- function(v, label) { tb <- sort(table(v), decreasing = TRUE)
                                   out <- data.frame(category = names(tb), n = as.integer(tb), stringsAsFactors = FALSE); attr(out, "label") <- label; out }
    if (!is.null(vg)) { v <- as.character(df[[vg]]); v[is.na(v) | !nzchar(v)] <- "Not answered"; vv$vgroups <- shares(v, "Vulnerability group") }
    if (!is.null(el)) { f <- eligibility_flag(df[[el]]); vv$elig <- shares(ifelse(is.na(f), "Unknown", ifelse(f, "Eligible", "Not eligible")), "Eligibility") }
    if (length(vv)) {
      sv <- rp_share_charts(vv, lang = lang)
      add(sv$rows); plots <- c(plots, sv$plots); caps <- c(caps, sv$captions)
    }
    if (!is.null(vs)) {
      z <- as_number(df[[vs]]); z <- z[!is.na(z)]
      if (length(z)) {
        q <- stats::quantile(z, c(0, .25, .5, .75, 1), names = FALSE)
        add(kv(c("Households with a score" = num(length(z)), "Mean" = sprintf("%.1f", mean(z)),
                 "Median" = sprintf("%.1f", q[3]), "Quartiles (Q1 to Q3)" = sprintf("%.1f to %.1f", q[2], q[4]),
                 "Range" = sprintf("%.1f to %.1f", q[1], q[5]))), "", "@@FIG:score@@", "")
        br <- pretty(z, 12); cnt <- as.integer(table(cut(z, br, include.lowest = TRUE)))
        d <- data.frame(score = sprintf("%s-%s", utils::head(br, -1), br[-1]), Households = cnt)
        plots$score <- rp_base(260) |> billboarder::bb_barchart(d) |> rp_colors(c(Households = "#0A6EB4")) |>
          billboarder::bb_legend(show = FALSE) |> billboarder::bb_x_axis(tick = list(multiline = FALSE))
        caps[["score"]] <- "Distribution of the vulnerability score"
      }
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

  mp <- overview_map_points(df, settings)
  if (!is.null(mp)) {
    add(sprintf("## %d. Map", sec), "",
        sprintf("%s households with coordinates%s. The background map (Esri) needs an internet connection; the points do not.",
                num(attr(mp, "n_total")), if (attr(mp, "n_total") > nrow(mp)) sprintf(", %s drawn (an even sample)", num(nrow(mp))) else ""), "",
        "@@FIG:map@@", "")
    plots$map <- overview_map(mp); caps[["map"]] <- if (!is.null(vg)) "Households by vulnerability group" else "Households surveyed"
  }

  report_write_page(
    file, paste(L, collapse = "\n"), plots, captions = caps, lang = lang,
    title = "Data collection summary", record = "Data collection record",
    meta = c("Country office" = x$country_office %||% "", "Generated" = format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Areas covered" = x$areas %||% "All areas", "Households" = num(n)),
    footer = "This record summarises the data collected, as shown on the Overview page.",
    blocks = list("@@KPI@@" = overview_kpis(totals, lang), "@@PROFILE@@" = profile_tiles(bp$tiles, lang),
                  "@@AREAS@@" = area_summary_html(ga)))
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
  m |>
    leaflet::addProviderTiles(leaflet::providers$Esri.WorldTopoMap, group = "Terrain") |>
    leaflet::addTiles(esri_canvas("Light_Gray_Base"), attribution = ESRI_ATTRIBUTION, group = "Light") |>
    leaflet::addTiles(esri_canvas("Light_Gray_Reference"), group = "Light") |>
    leaflet::addProviderTiles(leaflet::providers$Esri.WorldImagery, group = "Satellite") |>
    leaflet::hideGroup(c("Light", "Satellite")) |>
    leaflet::addLayersControl(baseGroups = c("Terrain", "Light", "Satellite"), position = "topright",
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
