#' Overview insights
#'
#' What the Overview page shows beside its map, and what its report prints:
#' the data collection (volume, pace, days, areas), who is in the data (the
#' households' profile from every mapped characteristic) and their
#' vulnerability (score, groups, eligibility, and how they differ across
#' household profiles). Pure functions of the data and the mapping, weighted
#' when a sampling weight is mapped, and silent about what is not mapped.
#' @name overview_insights
#' @noRd
NULL

# the column mapped to a field, when it is in the data
ov_col <- function(settings, df, key) {
  v <- as.character(settings[[key]] %||% "")[1]
  if (!is.na(v) && nzchar(v) && v %in% names(df)) v else NULL
}
# totals of `w` per value of `g` (named numeric), fast on large data
sum_by <- function(w, g) {
  r <- data.table::data.table(w = w, g = as.character(g))[, list(s = sum(w, na.rm = TRUE)), by = "g"]
  r <- r[!is.na(r$g)]
  stats::setNames(r$s, r$g)
}
ov_pct <- function(x) if (is.na(x)) "n/a" else sprintf("%.0f%%", 100 * x)
ov_num <- function(x) format(round(x), big.mark = ",")
ov_wmean <- function(x, w) { ok <- !is.na(x) & !is.na(w); if (!any(ok) || sum(w[ok]) <= 0) NA_real_ else sum(x[ok] * w[ok]) / sum(w[ok]) }

#' A household has at least one: a count above 0, or a yes
#' @noRd
ov_has <- function(x) {
  if (is.numeric(x)) return(ifelse(is.na(x), NA, x > 0))
  n <- suppressWarnings(as.numeric(as.character(x)))
  if (mean(!is.na(n[!is.na(x)])) > 0.9) return(ifelse(is.na(n), NA, n > 0))
  eligibility_flag(x)
}

#' Weighted shares of a category (top `top`, the rest as Other)
#' @return data.frame(category, n) in households (weighted)
#' @noRd
ov_shares <- function(v, w, top = 6, order = NULL) {
  v <- as.character(v); v[is.na(v) | !nzchar(trimws(v))] <- "Not answered"
  s <- sum_by(w, v)
  s <- if (!is.null(order)) s[c(intersect(order, names(s)), setdiff(names(sort(s, decreasing = TRUE)), order))] else sort(s, decreasing = TRUE)
  if (length(s) > top) s <- c(s[seq_len(top - 1)], Other = sum(s[-seq_len(top - 1)]))
  data.frame(category = names(s), n = as.numeric(s), stringsAsFactors = FALSE)
}

# ---- 1. Data collection ----------------------------------------------------

#' Volume, pace and days of the collection, and submissions per day by area
#' @return list(tiles = list of list(label, value, sub, icon), daily =
#'   data.frame(day, area, n) or NULL, area_label)
#' @noRd
ov_collection <- function(df, settings, max_areas = 6) {
  n <- nrow(df); w <- get_weights(df, settings)
  weighted <- !is.null(ov_col(settings, df, "weight"))
  tiles <- list(list(label = "Households", value = ov_num(sum(w, na.rm = TRUE)), icon = "house-door",
                     sub = if (weighted) sprintf("weighted, %s records", ov_num(n)) else "records"))
  hs <- ov_col(settings, df, "hh_size")
  if (!is.null(hs)) tiles[[length(tiles) + 1]] <- list(label = "Individuals", value = ov_num(sum(as_number(df[[hs]]) * w, na.rm = TRUE)),
                                                       icon = "people", sub = if (weighted) "weighted" else "in these households")
  cm <- ov_col(settings, df, "village") %||% ov_col(settings, df, "admin4") %||% ov_col(settings, df, "admin3")
  if (!is.null(cm)) tiles[[length(tiles) + 1]] <- list(label = "Communities", value = ov_num(length(unique(stats::na.omit(df[[cm]][w > 0])))),
                                                       icon = "geo-alt", sub = "distinct places reached")
  dt <- ov_col(settings, df, "date"); daily <- NULL; area_label <- NULL
  if (!is.null(dt)) {
    day <- suppressWarnings(as.Date(df[[dt]]))
    if (any(!is.na(day))) {
      nd <- length(unique(stats::na.omit(day)))
      tiles[[length(tiles) + 1]] <- list(label = "Days of collection", value = ov_num(nd), icon = "calendar-range",
                                         sub = sprintf("%s to %s", fmt_date(min(day, na.rm = TRUE)), fmt_date(max(day, na.rm = TRUE))))
      last <- max(day, na.rm = TRUE); recent <- !is.na(day) & day > last - 7
      tiles[[length(tiles) + 1]] <- list(label = "Households per day", value = ov_num(sum(w[!is.na(day)]) / nd), icon = "graph-up",
                                         sub = sprintf("last 7 days: %s a day", ov_num(sum(w[recent]) / max(1, length(unique(day[recent]))))))
      a1 <- ov_col(settings, df, "admin1")
      area <- if (is.null(a1)) rep("All", n) else { v <- as.character(df[[a1]]); v[is.na(v) | !nzchar(v)] <- "(no area)"; v }
      if (!is.null(a1)) {
        top <- names(sort(sum_by(w, area), decreasing = TRUE))
        if (length(top) > max_areas) area[!area %in% top[seq_len(max_areas - 1)]] <- "Other areas"
        area_label <- "Admin 1"
      }
      ok <- !is.na(day)
      agg <- data.table::data.table(n = w[ok], day = day[ok], area = area[ok])[, list(n = sum(n)), by = c("day", "area")]
      agg <- as.data.frame(agg)
      daily <- agg[order(agg$day, agg$area), , drop = FALSE]
    }
  }
  en <- ov_col(settings, df, "enumerator_id")
  if (!is.null(en)) {
    ne <- length(unique(stats::na.omit(df[[en]])))
    tiles[[length(tiles) + 1]] <- list(label = "Enumerators", value = ov_num(ne), icon = "person-badge",
                                       sub = sprintf("%s interviews each", ov_num(n / max(1, ne))))
  }
  dur <- ov_duration(df, w)
  if (!is.na(dur)) tiles[[length(tiles) + 1]] <- list(label = "Interview length", value = sprintf("%.0f min", dur), icon = "stopwatch", sub = "average, 5 min to 3 h kept")
  list(tiles = tiles, daily = daily, area_label = area_label)
}

# average interview length from the form's start and end times (NA when absent)
ov_duration <- function(df, w) {
  s <- intersect(c("start", "starttime"), names(df))[1]; e <- intersect(c("end", "endtime"), names(df))[1]
  if (is.na(s) || is.na(e)) return(NA_real_)
  d <- suppressWarnings(as.numeric(difftime(lubridate::as_datetime(df[[e]]), lubridate::as_datetime(df[[s]]), units = "mins")))
  ok <- !is.na(d) & d > 5 & d < 180 & !is.na(w) & w > 0
  if (!any(ok)) NA_real_ else sum(d[ok] * w[ok]) / sum(w[ok])
}

# ---- 2. Who is in the data ---------------------------------------------------

#' The households' profile from every mapped characteristic
#' @return list(tiles, charts = named list of list(title, kind ("cat" or
#'   "bins"), data = data.frame(category, n))), or NULL when nothing is mapped
#' @noRd
ov_profile <- function(df, settings) {
  if (!nrow(df)) return(NULL)
  w <- get_weights(df, settings)
  col <- function(k) ov_col(settings, df, k)
  tiles <- list(); charts <- list()
  share_has <- function(k) { h <- ov_has(df[[col(k)]]); ov_wmean(as.numeric(h), w) }
  sx <- col("hhh_sex")
  if (!is.null(sx)) {
    f <- is_female(df[[sx]])
    tiles[[length(tiles) + 1]] <- list(label = "Female-headed", value = ov_pct(ov_wmean(as.numeric(f), w)), share = ov_wmean(as.numeric(f), w), icon = "person-standing-dress",
                                       sub = "of the households")
  }
  ag <- col("hhh_age")
  if (!is.null(ag)) {
    z <- as_number(df[[ag]])
    if (any(!is.na(z))) {
      tiles[[length(tiles) + 1]] <- list(label = "Head's age", value = sprintf("%.0f", stats::median(z, na.rm = TRUE)), icon = "person",
                                         sub = sprintf("median; %s aged 60+", ov_pct(ov_wmean(as.numeric(z >= 60), w))))
      b <- cut(z, c(-Inf, 19, 29, 39, 49, 59, 69, Inf), labels = c("Under 20", "20-29", "30-39", "40-49", "50-59", "60-69", "70+"))
      charts$age <- list(title = "Age of the head of household", kind = "bins", data = ov_shares(b, w, top = 7, order = levels(b)))
      charts$age$data <- charts$age$data[charts$age$data$category != "Not answered", , drop = FALSE]
    }
  }
  hs <- col("hh_size")
  if (!is.null(hs)) {
    z <- as_number(df[[hs]])
    tiles[[length(tiles) + 1]] <- list(label = "Household size", value = sprintf("%.1f", ov_wmean(z, w)), icon = "people",
                                       sub = sprintf("average; %s with 7 or more", ov_pct(ov_wmean(as.numeric(z >= 7), w))))
    b <- cut(z, c(-Inf, 1, 2, 3, 4, 5, 6, 7, 9, Inf), labels = c("1", "2", "3", "4", "5", "6", "7", "8-9", "10+"))
    charts$size <- list(title = "Household size", kind = "bins", data = ov_shares(b, w, top = 9, order = levels(b)))
    charts$size$data <- charts$size$data[charts$size$data$category != "Not answered", , drop = FALSE]
  }
  for (k in c("childU5", "plw", "elderly", "disability")) if (!is.null(col(k))) {
    lab <- switch(k, childU5 = "With children under 5", plw = "With pregnant or lactating women",
                  elderly = "With people aged 60+", disability = "With disability or chronic illness")
    tiles[[length(tiles) + 1]] <- list(label = lab, value = ov_pct(share_has(k)), share = share_has(k), icon = switch(k, childU5 = "balloon", plw = "heart-pulse",
                                       elderly = "person-walking", disability = "universal-access"), sub = "of the households")
  }
  cu <- col("childU5")
  if (!is.null(cu) && is.numeric(as_number(df[[cu]]))) {
    z <- as_number(df[[cu]])
    if (any(z > 1, na.rm = TRUE)) {
      b <- cut(z, c(-Inf, 0, 1, 2, Inf), labels = c("None", "1", "2", "3+"))
      charts$u5 <- list(title = "Children under 5 per household", kind = "bins", data = ov_shares(b, w, top = 4, order = levels(b)))
      charts$u5$data <- charts$u5$data[charts$u5$data$category != "Not answered", , drop = FALSE]
    }
  }
  rs <- col("residency")
  if (!is.null(rs)) charts$residency <- list(title = "Residence status", kind = "cat", data = ov_shares(df[[rs]], w))
  for (k in c("hhid_avail", "phone_avail")) if (!is.null(col(k)))
    tiles[[length(tiles) + 1]] <- list(label = if (k == "hhid_avail") "Head has an ID" else "Household has a phone",
                                       value = ov_pct(share_has(k)), share = share_has(k), icon = if (k == "hhid_avail") "person-vcard" else "phone", sub = "of the households")
  if (!length(tiles) && !length(charts)) return(NULL)
  list(tiles = tiles, charts = charts)
}

# ---- 3. Vulnerability ------------------------------------------------------

# severity words, least to most (for ordering groups without a score)
SEVERITY_WORDS <- c("none", "no", "minimal", "low", "faible", "bajo", "stress", "moderate", "moderee", "modere", "moyen", "medium",
                    "high", "eleve", "elevee", "alto", "crisis", "severe", "grave", "very high", "tres eleve", "extreme", "emergency", "urgence", "catastrophe")

#' The vulnerability groups, least to most vulnerable
#'
#' By the mean score of each group when a score is mapped; otherwise by the
#' severity word in the label ("Low" < "Moderate" < "High" < "Severe"), then a
#' leading number ("1-Low", "4-Severe").
#' @noRd
ov_group_order <- function(g, score = NULL, w = NULL) {
  lv <- unique(stats::na.omit(as.character(g))); lv <- lv[nzchar(lv)]
  if (!length(lv)) return(character(0))
  if (!is.null(score) && any(!is.na(score))) {
    m <- vapply(lv, function(l) { i <- which(as.character(g) == l); ov_wmean(score[i], w[i] %||% rep(1, length(i))) }, numeric(1))
    if (sum(!is.na(m)) >= 2) return(lv[order(m, na.last = TRUE)])
  }
  nl <- norm_name(lv)
  rank_word <- vapply(nl, function(z) { hit <- which(vapply(SEVERITY_WORDS, function(s) grepl(paste0("(^| )", s, "( |$)"), z), logical(1)))
                                        if (length(hit)) max(hit) else NA_real_ }, numeric(1))
  lead <- suppressWarnings(as.numeric(sub("^(\\d+).*", "\\1", lv))); lead[!grepl("^\\d", lv)] <- NA
  if (sum(!is.na(rank_word)) >= 2) return(lv[order(rank_word, lead, lv, na.last = TRUE)])
  if (sum(!is.na(lead)) >= 2) return(lv[order(lead, lv, na.last = TRUE)])
  sort(lv)
}

#' The vulnerability of the households, and how it differs across profiles
#'
#' @param indicator "eligible", "vulnerable" (in the most vulnerable group(s))
#'   or "score"; NULL picks the first available in that order.
#' @return list(tiles, groups = data.frame(group, households, people),
#'   score = data.frame(category, n) (histogram), cross = data.frame(dimension,
#'   category, households, value), indicator, indicator_label, top_groups),
#'   or NULL when no vulnerability variable is mapped
#' @noRd
ov_vulnerability <- function(df, settings, indicator = NULL) {
  col <- function(k) ov_col(settings, df, k)
  vg <- col("v_groups"); el <- col("eligibility"); vs <- col("v_score")
  if (is.null(vg) && is.null(el) && is.null(vs)) return(NULL)
  w <- get_weights(df, settings)
  score <- if (is.null(vs)) NULL else as_number(df[[vs]])
  tiles <- list(); groups <- NULL; top_groups <- NULL; hist <- NULL
  if (!is.null(vs) && any(!is.na(score))) {
    q <- stats::quantile(score, c(.25, .5, .75), na.rm = TRUE, names = FALSE)
    tiles[[length(tiles) + 1]] <- list(label = "Vulnerability score", value = sprintf("%.1f", ov_wmean(score, w)), icon = "speedometer2",
                                       sub = sprintf("mean; median %.1f, Q1-Q3 %.1f-%.1f", q[2], q[1], q[3]))
    br <- pretty(range(score, na.rm = TRUE), n = 12)
    b <- cut(score, br, include.lowest = TRUE, right = FALSE, labels = sprintf("%s-%s", utils::head(br, -1), br[-1]))
    hist <- ov_shares(b, w, top = length(br), order = levels(b)); hist <- hist[hist$category != "Not answered", , drop = FALSE]
  }
  if (!is.null(vg)) {
    ord <- ov_group_order(df[[vg]], score, w)
    hs <- col("hh_size"); size <- if (is.null(hs)) NULL else as_number(df[[hs]])
    g <- as.character(df[[vg]])
    groups <- do.call(rbind, lapply(ord, function(l) { i <- which(g == l)
      data.frame(group = l, households = sum(w[i], na.rm = TRUE), people = if (is.null(size)) NA_real_ else sum(size[i] * w[i], na.rm = TRUE)) }))
    top_groups <- utils::tail(ord, if (length(ord) >= 4) 2 else 1)
    in_top <- g %in% top_groups
    tiles[[length(tiles) + 1]] <- list(label = sprintf("In %s", paste(top_groups, collapse = " / ")), value = ov_pct(ov_wmean(as.numeric(in_top), w)),
                                       share = ov_wmean(as.numeric(in_top), w),
                                       icon = "exclamation-triangle", sub = if (!is.null(size)) sprintf("%s people", ov_num(sum(size[in_top] * w[in_top], na.rm = TRUE))) else "of the households")
  }
  if (!is.null(el)) {
    f <- eligibility_flag(df[[el]])
    tiles[[length(tiles) + 1]] <- list(label = "Eligible", value = ov_pct(ov_wmean(as.numeric(f), w)), share = ov_wmean(as.numeric(f), w), icon = "check2-circle",
                                       sub = sprintf("%s households", ov_num(sum(w[f %in% TRUE]))))
  }
  avail <- c(eligible = !is.null(el), vulnerable = !is.null(vg), score = !is.null(vs) && any(!is.na(score)))
  indicator <- if (!is.null(indicator) && isTRUE(avail[[indicator]])) indicator else names(avail)[avail][1]
  y <- switch(indicator, eligible = as.numeric(eligibility_flag(df[[el]])), vulnerable = as.numeric(as.character(df[[vg]]) %in% top_groups), score = score)
  ind_label <- switch(indicator, eligible = "Share eligible", vulnerable = sprintf("Share in %s", paste(top_groups, collapse = " / ")), score = "Mean vulnerability score")
  list(tiles = tiles, groups = groups, score = hist, cross = ov_cross(df, settings, y, w), indicator = indicator,
       indicator_label = ind_label, available = names(avail)[avail], top_groups = top_groups)
}

#' An indicator across household profiles (sex, residence, size, children,
#' pregnant or lactating women, older people, disability, age, area)
#' @return data.frame(dimension, category, households, value)
#' @noRd
ov_cross <- function(df, settings, y, w, min_n = 5) {
  col <- function(k) ov_col(settings, df, k)
  dims <- list()
  if (!is.null(col("hhh_sex"))) dims[["Head of household"]] <- ifelse(is_female(df[[col("hhh_sex")]]), "Female-headed", "Male-headed")
  if (!is.null(col("hhh_age"))) { z <- as_number(df[[col("hhh_age")]]); dims[["Head's age"]] <- as.character(cut(z, c(-Inf, 29, 59, Inf), labels = c("Head under 30", "Head 30-59", "Head 60+"))) }
  if (!is.null(col("hh_size"))) { z <- as_number(df[[col("hh_size")]]); dims[["Household size"]] <- as.character(cut(z, c(-Inf, 3, 6, Inf), labels = c("1-3 members", "4-6 members", "7+ members"))) }
  for (k in c("childU5", "plw", "elderly", "disability")) if (!is.null(col(k))) {
    h <- ov_has(df[[col(k)]])
    lab <- switch(k, childU5 = c("Children under 5", "No children under 5"), plw = c("Pregnant or lactating women", "None pregnant or lactating"),
                  elderly = c("People aged 60+", "No one aged 60+"), disability = c("Disability or illness", "No disability or illness"))
    dims[[c(childU5 = "Children under 5", plw = "Pregnant or lactating women", elderly = "People aged 60+", disability = "Disability or illness")[[k]]]] <-
      ifelse(is.na(h), NA, ifelse(h, lab[1], lab[2]))
  }
  if (!is.null(col("residency"))) dims[["Residence status"]] <- as.character(df[[col("residency")]])
  if (!is.null(col("admin1"))) dims[["Admin 1"]] <- as.character(df[[col("admin1")]])
  if (!length(dims)) return(NULL)
  out <- do.call(rbind, lapply(names(dims), function(d) {
    v <- dims[[d]]; v[!is.na(v) & !nzchar(v)] <- NA
    lv <- names(sort(sum_by(w, v), decreasing = TRUE)); lv <- utils::head(lv, if (d == "Admin 1") 8 else 6)
    do.call(rbind, lapply(lv, function(l) { i <- which(v == l)
      data.frame(dimension = d, category = l, households = sum(w[i], na.rm = TRUE), value = ov_wmean(y[i], w[i]), stringsAsFactors = FALSE) }))
  }))
  out[!is.na(out$value) & out$households >= min_n, , drop = FALSE]
}

#' The rows whose coordinates are inside a map view
#' @param bounds list(north, south, east, west) from leaflet
#' @return integer row indices, or NULL when every located household is in
#'   view (then the households without coordinates count too)
#' @noRd
ov_in_view <- function(lng, lat, idx, bounds) {
  if (is.null(bounds) || !length(idx)) return(NULL)
  b <- vapply(bounds[c("north", "south", "east", "west")], function(v) as.numeric(v %||% NA)[1], numeric(1))
  if (anyNA(b)) return(NULL)
  inside <- lat <= b[["north"]] & lat >= b[["south"]] &
    (if (b[["west"]] <= b[["east"]]) lng >= b[["west"]] & lng <= b[["east"]] else lng >= b[["west"]] | lng <= b[["east"]])
  if (all(inside)) NULL else idx[inside]
}

# ---- Figures as HTML (the page and the report) ------------------------------

#' A share as a ring (80% hole), the figure inside, the label under it
#' @noRd
ov_donut_html <- function(share, label, sub = "", colour = "#0A6EB4") {
  r <- 27; cfr <- 2 * pi * r
  on <- if (is.finite(share)) max(0, min(1, share)) * cfr else 0
  sprintf(paste0('<div class="tw-donut" title="%s"><svg viewBox="0 0 64 64" width="84" height="84" role="img" aria-label="%s: %s">',
                 '<circle cx="32" cy="32" r="%.1f" fill="none" stroke="rgba(128,128,128,.18)" stroke-width="6.4"/>',
                 '<circle cx="32" cy="32" r="%.1f" fill="none" stroke="%s" stroke-width="6.4" stroke-linecap="round" ',
                 'stroke-dasharray="%.2f %.2f" transform="rotate(-90 32 32)"/>',
                 '<text x="32" y="36.5" text-anchor="middle" style="font:700 13px Commissioner,system-ui,sans-serif;fill:currentColor">%s</text></svg>',
                 '<div class="tw-donut-label">%s</div></div>'),
          htmltools::htmlEscape(sub), htmltools::htmlEscape(label), ov_pct(share), r, r, colour, on, cfr - on,
          ov_pct(share), htmltools::htmlEscape(label))
}

#' Tiles as HTML: the other figures as quiet cards on top, then the first
#' `max_rings` shares as rings (further shares become cards)
#' @noRd
ov_tiles_html <- function(tiles, max_rings = 5) {
  if (!length(tiles)) return("")
  is_share <- vapply(tiles, function(t) !is.null(t$share), logical(1))
  is_share[is_share][-seq_len(min(sum(is_share), max_rings))] <- FALSE
  rings <- vapply(tiles[is_share], function(t) ov_donut_html(t$share, t$label, t$sub %||% ""), "")
  cards <- vapply(tiles[!is_share], function(t) sprintf(
    '<div class="tw-tile" data-key="%s" title="%s"><div class="tw-tile-label">%s</div><div class="tw-tile-value">%s</div><div class="tw-tile-sub">%s</div></div>',
    htmltools::htmlEscape(t$label), htmltools::htmlEscape(t$sub %||% ""), htmltools::htmlEscape(t$label),
    htmltools::htmlEscape(t$value), htmltools::htmlEscape(t$sub %||% "")), "")
  paste0(if (length(cards)) paste0('<div class="tw-figs tw-figs-cards">', paste(cards, collapse = ""), '</div>'),
         if (length(rings)) paste0('<div class="tw-figs">', paste(rings, collapse = ""), '</div>'))
}

# ---- Contingency table ------------------------------------------------------

#' A variable as categories: text as is (top `max_levels`, the rest Other),
#' numbers with many values in about five ranges
#' @noRd
ov_categories <- function(x, w, max_levels = 20) {
  if (is.numeric(x) && length(unique(stats::na.omit(x))) > 12) {
    br <- unique(stats::quantile(x, seq(0, 1, 0.2), na.rm = TRUE, names = FALSE))
    if (length(br) < 3) br <- pretty(range(x, na.rm = TRUE), 5)
    f <- cut(x, br, include.lowest = TRUE, dig.lab = 4)
    return(factor(as.character(f), levels = levels(f)))
  }
  v <- as.character(x); v[is.na(v) | !nzchar(trimws(v))] <- NA
  tot <- sort(sum_by(w, v), decreasing = TRUE)
  keep <- names(tot)[seq_len(min(length(tot), max_levels - 1))]
  if (length(tot) > max_levels) v[!is.na(v) & !v %in% keep] <- "Other"
  lv <- if (is.numeric(x)) as.character(sort(unique(as.numeric(keep)))) else keep
  factor(v, levels = c(lv, if (length(tot) > max_levels) "Other"))
}

#' Weighted contingency table with totals
#'
#' @param stat "n" (households), "row" / "col" / "total" (percentages),
#'   "mean" / "sum" (of `value`, a numeric column).
#' @param col Column variable, or NULL for one-way.
#' @return list(table = numeric matrix with a Total row and column, stat,
#'   chi = chi-square p-value (counts and percentages, two-way), n)
#' @noRd
contingency <- function(df, row, col = NULL, w = NULL, stat = "n", value = NULL) {
  n <- nrow(df); if (is.null(w)) w <- rep(1, n)
  r <- ov_categories(df[[row]], w)
  cc <- if (is.null(col)) factor(rep("All", n)) else ov_categories(df[[col]], w)
  y <- if (stat %in% c("mean", "sum")) as_number(df[[value]]) else NULL
  ok <- !is.na(r) & !is.na(cc) & !is.na(w) & w > 0 & (if (is.null(y)) TRUE else !is.na(y))
  r <- droplevels(r[ok]); cc <- droplevels(cc[ok]); ww <- w[ok]; yy <- y[ok]
  cnt <- tapply(ww, list(r, cc), sum); cnt[is.na(cnt)] <- 0
  cnt_m <- cbind(cnt, Total = rowSums(cnt)); cnt_m <- rbind(cnt_m, Total = colSums(cnt_m))
  tab <- switch(stat,
    n = cnt_m,
    total = 100 * cnt_m / sum(cnt),
    row = 100 * cnt_m / cnt_m[, "Total"],
    col = 100 * sweep(cnt_m, 2, cnt_m["Total", ], "/"),
    sum = , mean = {
      s <- tapply(ww * yy, list(r, cc), sum); s[is.na(s)] <- 0
      s_m <- cbind(s, Total = rowSums(s)); s_m <- rbind(s_m, Total = colSums(s_m))
      if (stat == "sum") s_m else { m <- s_m / cnt_m; m[!is.finite(m)] <- NA; m }
    })
  chi <- NA_real_
  if (!is.null(col) && stat %in% c("n", "row", "col", "total") && nrow(cnt) > 1 && ncol(cnt) > 1) {
    # on the unweighted counts scaled to the sample size, a design-naive test
    scaled <- cnt * sum(ok) / sum(cnt)
    chi <- tryCatch(suppressWarnings(stats::chisq.test(scaled)$p.value), error = function(e) NA_real_)
  }
  if (is.null(col)) tab <- tab[, "Total", drop = FALSE]
  list(table = tab, stat = stat, chi = chi, n = sum(ok))
}

# ---- Chart builder -----------------------------------------------------------

#' A column as a number (many values) or a category (a few values)
#' @noRd
ov_var_kind <- function(x) {
  if (is.null(x)) return("none")
  n <- if (is.numeric(x)) x else suppressWarnings(as.numeric(as.character(x)))
  if (mean(!is.na(n[!is.na(x)])) > 0.95 && length(unique(stats::na.omit(n))) > 12) "num" else "cat"
}

#' The charts that make sense for two variables (the first is the default)
#' @noRd
ov_chart_types <- function(kx, ky) {
  key <- paste(kx, ky)
  switch(key,
    "num none" = c("Histogram" = "hist", "Box plot" = "box"),
    "cat none" = c("Bars (share of households)" = "bars", "Bars (households)" = "bars_n"),
    "num num" = c("Scatter with trend line" = "scatter_trend", "Scatter" = "scatter"),
    "cat num" = , "num cat" = c("Box plot" = "box", "Mean" = "mean", "Violin" = "violin"),
    "cat cat" = c("100% stacked bars" = "stack100", "Stacked bars (households)" = "stack", "Side by side" = "dodge"),
    character(0))
}

#' Pearson and Spearman correlation with the number of pairs
#' @noRd
ov_cor_text <- function(x, y) {
  ok <- is.finite(x) & is.finite(y)
  if (sum(ok) < 3) return("too few pairs")
  r <- stats::cor(x[ok], y[ok]); rs <- suppressWarnings(stats::cor(x[ok], y[ok], method = "spearman"))
  sprintf("r = %.2f (Spearman %.2f, %s pairs)", r, rs, format(sum(ok), big.mark = ","))
}

# ---- Report pieces -------------------------------------------------------------

#' The key findings, as short sentences, from the insights already computed
#' @param n_gps Households with usable coordinates (NULL when GPS is not mapped).
#' @noRd
ov_key_findings <- function(n, cl, pr, v, n_gps = NULL) {
  tv <- function(tiles, label) { t <- Filter(function(z) identical(z$label, label), tiles %||% list()); if (length(t)) t[[1]]$value }
  out <- character(0)
  people <- tv(cl$tiles, "Individuals"); places <- tv(cl$tiles, "Communities"); days <- tv(cl$tiles, "Days of collection")
  pace <- tv(cl$tiles, "Households per day"); enum <- tv(cl$tiles, "Enumerators")
  out <- c(out, paste0(ov_num(n), " households", if (!is.null(people)) sprintf(" (%s people)", people),
                       if (!is.null(places)) sprintf(" in %s places", places),
                       if (!is.null(days)) sprintf(", over %s days of collection (about %s a day)", days, pace),
                       if (!is.null(enum)) sprintf(", by %s enumerators", enum), "."))
  if (!is.null(pr)) {
    bits <- c(if (!is.null(v1 <- tv(pr$tiles, "Female-headed"))) sprintf("%s are headed by women", v1),
              if (!is.null(v2 <- tv(pr$tiles, "Head's age"))) sprintf("the head's median age is %s", v2),
              if (!is.null(v3 <- tv(pr$tiles, "Household size"))) sprintf("households have %s members on average", v3),
              if (!is.null(v4 <- tv(pr$tiles, "With children under 5"))) sprintf("%s have children under 5", v4))
    if (length(bits)) out <- c(out, paste0(toupper(substr(paste(bits, collapse = "; "), 1, 1)), substring(paste(bits, collapse = "; "), 2), "."))
  }
  if (!is.null(v)) {
    el <- tv(v$tiles, "Eligible"); top <- Filter(function(z) startsWith(z$label, "In "), v$tiles)
    sc <- tv(v$tiles, "Vulnerability score")
    bits <- c(if (!is.null(el)) sprintf("%s of the households are eligible", el),
              if (length(top)) sprintf("%s are in the most vulnerable groups (%s)", top[[1]]$value, paste(v$top_groups, collapse = ", ")),
              if (!is.null(sc)) sprintf("the mean vulnerability score is %s", sc))
    if (length(bits)) out <- c(out, paste0(toupper(substr(paste(bits, collapse = "; "), 1, 1)), substring(paste(bits, collapse = "; "), 2), "."))
    cr <- v$cross
    if (!is.null(cr) && nrow(cr) >= 2) {
      pct <- !identical(v$indicator, "score"); f <- function(x) if (pct) ov_pct(x) else sprintf("%.1f", x)
      hi <- cr[which.max(cr$value), ]; lo <- cr[which.min(cr$value), ]
      out <- c(out, sprintf("%s is highest among %s (%s) and lowest among %s (%s), against %s overall.",
                            v$indicator_label, tolower(hi$category), f(hi$value), tolower(lo$category), f(lo$value),
                            f(ov_wmean(cr$value[cr$dimension == cr$dimension[1]], cr$households[cr$dimension == cr$dimension[1]]))))
    }
  }
  if (!is.null(n_gps)) out <- c(out, sprintf("%s of the %s households have usable GPS coordinates.", ov_num(n_gps), ov_num(n)))
  out
}

#' A table whose value column carries a bar; rows may be grouped under
#' header rows. `overall` draws a marker at that value on every bar.
#' @param d data.frame(group (optional), label, n, value, extra (optional))
#' @noRd
ov_bar_table_html <- function(d, value_label, pct = TRUE, overall = NULL, colours = NULL, extra_label = NULL) {
  if (is.null(d) || !nrow(d)) return("")
  esc <- htmltools::htmlEscape
  vmax <- max(c(d$value, overall), na.rm = TRUE); if (!is.finite(vmax) || vmax <= 0) vmax <- 1
  fmt <- function(x) if (is.na(x)) "" else if (pct) sprintf("%.0f%%", 100 * x) else sprintf("%.1f", x)
  mark <- if (!is.null(overall) && is.finite(overall)) sprintf('<span class="bt-mark" style="left:%.1f%%"></span>', 100 * overall / vmax) else ""
  rows <- character(0); last <- NULL
  for (i in seq_len(nrow(d))) {
    if (!is.null(d$group) && !identical(d$group[i], last)) {
      rows <- c(rows, sprintf('<tr class="bt-group"><th colspan="%d">%s</th></tr>', 3 + !is.null(d$extra), esc(d$group[i]))); last <- d$group[i]
    }
    col <- if (!is.null(colours)) colours[i] else "#0A6EB4"
    rows <- c(rows, sprintf(paste0('<tr><td class="bt-label">%s</td><td class="num">%s</td>',
                                   '<td class="bt-cell"><div class="bt-wrap"><div class="bt-track"><span class="bt-bar" style="width:%.1f%%;background:%s"></span>%s</div>',
                                   '<span class="bt-val">%s</span></div></td>%s</tr>'),
                            esc(d$label[i]), ov_num(d$n[i]), 100 * max(0, d$value[i], na.rm = TRUE) / vmax, col, mark, fmt(d$value[i]),
                            if (!is.null(d$extra)) sprintf('<td class="num">%s</td>', esc(d$extra[i])) else ""))
  }
  paste0('<table class="bt"><thead><tr><th></th><th class="num">Households</th><th>', esc(value_label), '</th>',
         if (!is.null(d$extra)) sprintf('<th class="num">%s</th>', esc(extra_label %||% "")), '</tr></thead><tbody>',
         paste(rows, collapse = ""), '</tbody></table>',
         if (nzchar(mark)) sprintf('<div class="bt-note"><span class="bt-mark-key"></span> overall: %s</div>', fmt(overall)) else "")
}

#' Labelled facts as a compact two-column grid
#' @noRd
ov_meta_html <- function(v) {
  v <- v[!is.na(v) & nzchar(v)]
  paste0('<dl class="tw-meta">', paste(sprintf('<div><dt>%s</dt><dd>%s</dd></div>', htmltools::htmlEscape(names(v)), htmltools::htmlEscape(v)), collapse = ""), '</dl>')
}

#' Columns worth tabulating or charting: not identifiers, names, phone
#' numbers or form metadata (by name, `is_identification_col()`), nor text
#' where nearly every household has its own value (free text, names under
#' another heading)
#' @noRd
analysis_cols <- function(df, cols = names(df), sample_n = 2000) {
  cols <- cols[!vapply(cols, is_identification_col, logical(1))]
  keep <- vapply(cols, function(cl) {
    x <- df[[cl]]; if (is.numeric(x) || inherits(x, c("Date", "POSIXt"))) return(TRUE)
    v <- x[!is.na(x)]; if (length(v) > sample_n) v <- v[seq_len(sample_n)]
    length(v) < 50 || length(unique(v)) / length(v) < 0.9
  }, logical(1))
  cols[keep]
}


#' A plotly axis range from typed bounds: nothing when both are blank
#' (automatic), else the typed bounds with a blank end taken from `auto`
#' (the data's own range)
#' @noRd
axis_bounds <- function(lo, hi, auto) {
  num <- function(v) { v <- suppressWarnings(as.numeric(v)); if (length(v) == 1 && is.finite(v)) v else NA_real_ }
  lo <- num(lo); hi <- num(hi)
  if ((!is.finite(lo) && !is.finite(hi)) || is.null(auto) || any(!is.finite(auto))) return(list())
  pad <- 0.05 * max(abs(diff(auto)), 1e-9)
  list(range = c(if (is.finite(lo)) lo else auto[1] - (if (auto[1] == 0) 0 else pad), if (is.finite(hi)) hi else auto[2] + pad),
       autorange = FALSE)
}

#' The axes button of a chart builder: quiet, says when bounds are set
#' @noRd
axis_button <- function(id) {
  actionButton(id, "Axes", icon = icon("up-down"), class = "btn-sm btn-outline-secondary")
}

#' The axes dialog: bounds prefilled with what is set, blank = automatic.
#' `prefix` names its inputs (<prefix>ymin, ..., <prefix>apply, <prefix>reset).
#' @noRd
axis_dialog <- function(ns, prefix, cur, hint = NULL, with_x = FALSE) {
  f <- function(id, lab) numericInput(ns(paste0(prefix, id)), lab, value = cur[[id]] %||% NA, width = "100%")
  modalDialog(
    title = "Axes", size = "m", easyClose = TRUE,
    tags$p(class = "small text-muted", "Leave a box blank and the chart sets it from the data."),
    tags$div(class = "d-flex gap-2", f("ymin", if (with_x) "Y axis from" else "Value axis from"), f("ymax", "to")),
    if (with_x) tags$div(class = "d-flex gap-2", f("xmin", "X axis from"), f("xmax", "to")),
    if (with_x) tags$p(class = "small text-muted", "The X bounds apply when the X axis is a number."),
    if (!is.null(hint)) tags$div(class = "small text-muted", hint),
    footer = tagList(actionButton(ns(paste0(prefix, "reset")), "Automatic", class = "btn-outline-secondary"),
                     modalButton("Cancel"),
                     actionButton(ns(paste0(prefix, "apply")), "Apply", class = "btn-primary")))
}

#' The bounds typed in the axes dialog (NA = automatic)
#' @noRd
axis_read <- function(input, prefix) {
  num <- function(v) { v <- suppressWarnings(as.numeric(v)); if (length(v) == 1 && is.finite(v)) v else NA_real_ }
  ids <- c("ymin", "ymax", "xmin", "xmax")
  stats::setNames(lapply(ids, function(k) num(input[[paste0(prefix, k)]])), ids)
}

# ---- Too many options --------------------------------------------------------

#' The most different answers a variable may have to be shown as categories
#' (map colours, table rows and columns, chart bars and groups); above it the
#' display would be unreadable, so the variable is refused with a message.
MAX_OPTIONS <- 30L

#' Number of different answers (missing and blank left out)
#' @noRd
n_options <- function(x) {
  if (is.factor(x)) x <- as.character(x)
  u <- unique(x[!is.na(x)])
  if (is.character(u)) u <- u[nzchar(trimws(u))]
  length(u)
}

#' The message for a variable with too many options, or NULL when it is fine
#' @noRd
too_many_options <- function(x, name) {
  n <- n_options(x)
  if (n <= MAX_OPTIONS) return(NULL)
  sprintf("Too many options for %s (%s different answers): it cannot be shown clearly. Choose a variable with at most %d answers.",
          name, format(n, big.mark = ","), MAX_OPTIONS)
}

# ---- Chart builder as ECharts (the React Overview) ---------------------------

#' Chart builder colours (WFP token hexes)
#' @noRd
GB_COLS <- c("#0A6EB4", "#f7b825", "#3f7e44", "#c5192d", "#26bde2", "#8a96a3", "#5b6b7c", "#e67e22")

#' At most this many points drawn in a scatter (the correlation and the trend
#' use every household)
#' @noRd
GB_MAX_POINTS <- 20000L

#' A colour with an alpha, as rgba()
#' @noRd
gb_tint <- function(hex, a) { v <- grDevices::col2rgb(hex); sprintf("rgba(%d,%d,%d,%.2f)", v[1], v[2], v[3], a) }

#' Five numbers of a box plot (whiskers at the last values within 1.5 IQR)
#' @noRd
gb_five <- function(y) {
  q <- stats::quantile(y, c(.25, .5, .75), names = FALSE); iqr <- q[3] - q[1]
  inr <- y[y >= q[1] - 1.5 * iqr & y <= q[3] + 1.5 * iqr]
  c(min(inr), q[1], q[2], q[3], max(inr))
}

#' The chart builder's chart as an ECharts option
#'
#' One or two variables, optionally grouped by a third; the chart follows
#' their kinds (`ov_var_kind()`) and `type` (`ov_chart_types()`). Box plots
#' come from five numbers computed here and scatters draw at most
#' `GB_MAX_POINTS` points, so the browser never gets every household.
#' @param axes list(ymin, ymax, xmin, xmax), NA = automatic.
#' @param lab Labels a column name.
#' @return list(option, note, auto = list(x, y)) (auto: the data's own ranges,
#'   for the Axes dialog).
#' @noRd
gb_echart <- function(df, x, y = NULL, g = NULL, type = NULL, axes = list(), lab = function(z) z,
                      max_points = GB_MAX_POINTS) {
  n <- nrow(df)
  kx <- ov_var_kind(df[[x]]); ky <- if (is.null(y)) "none" else ov_var_kind(df[[y]])
  types <- ov_chart_types(kx, ky)
  type <- if (isTRUE(type %in% types)) type else unname(types[1])
  fin <- function(v) { v <- suppressWarnings(as.numeric(v)); if (length(v) == 1 && is.finite(v)) v else NULL }
  ymin <- fin(axes$ymin); ymax <- fin(axes$ymax); xmin <- fin(axes$xmin); xmax <- fin(axes$xmax)
  as_cat <- function(col, k = 12) ov_categories(df[[col]], rep(1, n), max_levels = k)
  num <- function(col) as_number(df[[col]])
  gf <- if (is.null(g)) NULL else as_cat(g, 6)
  pal <- function(f) stats::setNames(rep_len(GB_COLS, nlevels(f)), levels(f))
  keep <- function(...) { ok <- Reduce(`&`, lapply(list(...), function(z) !is.na(z))); if (!is.null(gf)) ok <- ok & !is.na(gf); which(ok) }
  esc <- function(z) htmltools::htmlEscape(as.character(z))
  fmt <- function(v) vapply(signif(v, 3), function(z) format(z, big.mark = ",", scientific = FALSE, trim = TRUE), "")
  cnt <- function(v) format(v, big.mark = ",")
  legend <- !is.null(gf)
  vaxis <- function(name, lo = ymin, hi = ymax, scale = TRUE) c(list(type = "value", name = name, nameLocation = "end",
                                                                       nameTextStyle = list(align = "left"), scale = scale),
                                                    if (!is.null(lo)) list(min = lo), if (!is.null(hi)) list(max = hi))
  caxis <- function(cats, name) list(type = "category", data = I(as.character(cats)), name = name, nameLocation = "middle",
                                     nameGap = 28, axisLabel = list(interval = 0, hideOverlap = TRUE))
  done <- function(opt, note, auto = list(x = NULL, y = NULL), show_legend = legend) {
    opt$grid <- opt$grid %||% list(left = 12, right = 18, top = 30, bottom = if (show_legend) 56 else 34, containLabel = TRUE)
    if (show_legend) opt$legend <- list(bottom = 0, type = "scroll")
    opt$tooltip <- opt$tooltip %||% list(trigger = "item", formatter = "fn:tip")
    list(option = opt, note = note, auto = auto)
  }
  boxes <- function(yv, cat, grp) {
    cat <- droplevels(as.factor(cat)); grp <- if (is.null(grp)) NULL else droplevels(as.factor(grp))
    lv <- if (is.null(grp)) "" else levels(grp)
    series <- lapply(lv, function(l) {
      col <- if (nzchar(l)) pal(gf)[[l]] else GB_COLS[1]
      data <- lapply(levels(cat), function(cl) {
        k <- which(cat == cl & (if (is.null(grp)) TRUE else grp == l))
        if (!length(k)) return("-")
        f <- gb_five(yv[k])
        list(value = round(f, 6), tip = sprintf("<b>%s%s</b><br>median %s (%s to %s)<br>whiskers %s to %s<br>mean %s, %s households",
                                                 esc(cl), if (nzchar(l)) paste0(" \u00b7 ", esc(l)) else "", fmt(f[3]), fmt(f[2]), fmt(f[4]),
                                                 fmt(f[1]), fmt(f[5]), fmt(mean(yv[k])), cnt(length(k))))
      })
      list(type = "boxplot", name = if (nzchar(l)) l else "Households", data = data, boxWidth = c(14, 46),
           itemStyle = list(color = gb_tint(col, 0.16), borderColor = col, borderWidth = 1.4))
    })
    list(cats = levels(cat), series = series)
  }

  # ---- one number
  if (ky == "none" && kx == "num") {
    xv <- num(x); i <- keep(xv)
    note <- sprintf("%s households; mean %.1f, median %.1f", cnt(length(i)), mean(xv[i]), stats::median(xv[i]))
    if (type == "hist") {
      j <- i
      if (!is.null(xmin)) j <- j[xv[j] >= xmin]
      if (!is.null(xmax)) j <- j[xv[j] <= xmax]
      if (!length(j)) j <- i
      br <- graphics::hist(xv[j], breaks = 30, plot = FALSE)$breaks
      bins <- cut(xv[j], br, include.lowest = TRUE)
      cats <- fmt((br[-1] + br[-length(br)]) / 2)
      rng <- sprintf("%s to %s", fmt(br[-length(br)]), fmt(br[-1]))
      lv <- if (is.null(gf)) "Households" else levels(droplevels(gf[j]))
      series <- lapply(lv, function(l) {
        k <- if (is.null(gf)) seq_along(j) else which(gf[j] == l)
        h <- as.numeric(table(bins[k]))
        col <- if (is.null(gf)) GB_COLS[1] else pal(gf)[[l]]
        list(type = "bar", name = l, barGap = "-100%", barCategoryGap = "4%",
             itemStyle = list(color = if (is.null(gf)) col else gb_tint(col, 0.55)),
             data = lapply(seq_along(h), function(b) list(value = h[b], tip = sprintf("%s%s<br><b>%s</b> households",
                                                                                   if (is.null(gf)) "" else paste0(esc(l), ": "), rng[b], cnt(h[b])))))
      })
      mx <- max(vapply(series, function(s) max(vapply(s$data, function(d) d$value, 0)), 0))
      return(done(list(xAxis = caxis(cats, lab(x)), yAxis = vaxis("Households", scale = FALSE), series = series), note,
                  list(x = range(xv[i]), y = c(0, mx))))
    }
    b <- boxes(xv[i], if (!is.null(gf)) gf[i] else factor(rep(lab(x), length(i))), NULL)
    return(done(list(xAxis = caxis(b$cats, ""), yAxis = vaxis(lab(x)), series = b$series), note,
                list(x = NULL, y = range(xv[i])), show_legend = FALSE))
  }

  # ---- one category
  if (ky == "none") {
    xc <- as_cat(x); i <- keep(xc)
    gg <- if (is.null(gf)) factor(rep("All", length(i))) else droplevels(gf[i])
    tab <- table(droplevels(xc[i]), gg)
    val <- if (type == "bars") sweep(tab, 2, pmax(colSums(tab), 1), "/") * 100 else tab
    series <- lapply(colnames(tab), function(l) {
      col <- if (is.null(gf)) GB_COLS[1] else pal(gf)[[l]]
      list(type = "bar", name = if (is.null(gf)) "Households" else l, itemStyle = list(color = col), barMaxWidth = 46,
           label = if (is.null(gf)) list(show = TRUE, position = "top", fontSize = 10, textBorderWidth = 0, formatter = if (type == "bars") "{c}%" else "{c}"),
           data = lapply(rownames(tab), function(r) list(value = round(val[r, l], 1),
             tip = sprintf("<b>%s</b>%s<br>%s households%s", esc(r), if (is.null(gf)) "" else paste0(" \u00b7 ", esc(l)), cnt(tab[r, l]),
                           if (type == "bars") sprintf(" (%.1f%%)", val[r, l]) else ""))))
    })
    return(done(list(xAxis = caxis(rownames(tab), lab(x)), yAxis = vaxis(if (type == "bars") "% of households" else "Households", scale = FALSE),
                     series = series), sprintf("%s households", cnt(length(i))), list(x = NULL, y = c(0, max(val)))))
  }

  # ---- two numbers
  if (kx == "num" && ky == "num") {
    xv <- num(x); yv <- num(y); i <- keep(xv, yv)
    grp <- if (is.null(gf)) factor(rep("All", n)) else gf
    lvs <- levels(droplevels(grp[i]))
    notes <- character(0); series <- list(); names_shown <- character(0)
    for (l in lvs) {
      j <- i[grp[i] == l]; col <- if (is.null(gf)) GB_COLS[1] else pal(gf)[[l]]
      rtxt <- ov_cor_text(xv[j], yv[j]); notes <- c(notes, if (is.null(gf)) rtxt else sprintf("%s: %s", l, rtxt))
      nm <- if (is.null(gf)) "Households" else sprintf("%s (r = %s)", l, sub("^r = ([-0-9.]+).*", "\\1", rtxt))
      cap <- ceiling(max_points / length(lvs))
      jp <- if (length(j) > cap) sort(sample(j, cap)) else j
      series[[length(series) + 1]] <- list(type = "scatter", name = nm, symbolSize = 6, large = length(jp) > 5000,
                                           itemStyle = list(color = col, opacity = 0.55),
                                           data = unname(cbind(signif(xv[jp], 6), signif(yv[jp], 6))))
      names_shown <- c(names_shown, nm)
      if (type == "scatter_trend" && length(j) >= 3 && stats::var(xv[j]) > 0) {
        cf <- stats::coef(stats::lm(yv[j] ~ xv[j])); xs <- range(xv[j])
        series[[length(series) + 1]] <- list(type = "line", name = paste(l, "trend"), showSymbol = FALSE, silent = TRUE,
                                             lineStyle = list(color = col, width = 2), itemStyle = list(color = col),
                                             tooltip = list(show = FALSE),
                                             data = unname(cbind(xs, cf[1] + cf[2] * xs)))
      }
    }
    opt <- list(xAxis = c(vaxis(lab(x), xmin, xmax)[-c(3, 4)], list(nameLocation = "middle", nameGap = 28)),
                yAxis = vaxis(lab(y)), series = series,
                tooltip = list(trigger = "item"))
    out <- done(opt, paste(notes, collapse = " \u00b7 "), list(x = range(xv[i]), y = range(yv[i])))
    if (legend) out$option$legend$data <- I(names_shown)
    return(out)
  }

  # ---- a category and a number
  if (xor(kx == "num", ky == "num")) {
    ccol <- if (kx == "cat") x else y; ncol <- if (kx == "num") x else y
    cx <- as_cat(ccol); yv <- num(ncol); i <- keep(cx, yv)
    note <- sprintf("%s households", cnt(length(i)))
    if (type == "mean") {
      # the mean and its 95% interval: a mark at the mean, whiskers to the interval
      cats <- levels(droplevels(cx[i]))
      lv <- if (is.null(gf)) "" else levels(droplevels(gf[i]))
      lo <- Inf; hi <- -Inf
      series <- lapply(lv, function(l) {
        col <- if (nzchar(l)) pal(gf)[[l]] else GB_COLS[1]
        data <- lapply(cats, function(cl) {
          k <- i[cx[i] == cl & (if (nzchar(l)) gf[i] == l else TRUE)]
          if (!length(k)) return("-")
          m <- mean(yv[k]); ci <- if (length(k) > 1) 1.96 * stats::sd(yv[k]) / sqrt(length(k)) else 0
          lo <<- min(lo, m - ci); hi <<- max(hi, m + ci)
          list(value = signif(c(m - ci, m, m, m, m + ci), 6),
               tip = sprintf("<b>%s%s</b><br>Mean %s \u00b1 %s<br>%s households", esc(cl), if (nzchar(l)) paste0(" \u00b7 ", esc(l)) else "",
                             fmt(m), if (length(k) > 1) fmt(ci) else "-", cnt(length(k))))
        })
        list(type = "boxplot", name = if (nzchar(l)) l else "Mean", data = data, boxWidth = c(16, 40),
             itemStyle = list(color = gb_tint(col, 0.16), borderColor = col, borderWidth = 2))
      })
      return(done(list(xAxis = caxis(cats, lab(ccol)), yAxis = vaxis(paste("Mean of", lab(ncol), "(95% interval)")), series = series),
                  note, list(x = NULL, y = c(min(0, lo), hi))))
    }
    if (type == "box") {
      b <- boxes(yv[i], cx[i], if (is.null(gf)) NULL else gf[i])
      return(done(list(xAxis = caxis(b$cats, lab(ccol)), yAxis = vaxis(lab(ncol)), series = b$series), note, list(x = NULL, y = range(yv[i]))))
    }
    # violins: the density of each category drawn as stacked horizontal bars
    # (a transparent bar to the left edge, then the width), on bins of the
    # number; a sample on large data
    iv <- if (length(i) > max_points) sort(sample(i, max_points)) else i
    lo <- ymin %||% min(yv[iv]); hi <- ymax %||% max(yv[iv])
    if (!(hi > lo)) hi <- lo + 1
    nb <- 48
    edges <- seq(lo, hi, length.out = nb + 1); mids <- (edges[-1] + edges[-(nb + 1)]) / 2
    cats <- levels(droplevels(cx[iv]))
    lv <- if (is.null(gf)) "" else levels(droplevels(gf[iv]))
    G <- length(lv); slot <- 0.9 / G
    series <- list()
    for (ci in seq_along(cats)) for (gi in seq_along(lv)) {
      l <- lv[gi]
      k <- iv[cx[iv] == cats[ci] & (if (nzchar(l)) gf[iv] == l else TRUE)]
      if (length(k) < 2) next
      vals <- yv[k]
      col <- if (nzchar(l)) pal(gf)[[l]] else GB_COLS[1]
      d <- if (stats::sd(vals) > 0) stats::approx(stats::density(vals), xout = mids, rule = 2)$y else as.numeric(abs(mids - vals[1]) == min(abs(mids - vals[1])))
      d[mids < min(vals) | mids > max(vals)] <- 0
      hw <- if (max(d) > 0) d / max(d) * slot * 0.48 else d
      centre <- ci + (gi - (G + 1) / 2) * slot
      q <- stats::quantile(vals, c(.25, .5, .75), names = FALSE)
      tip <- sprintf("<b>%s%s</b><br>median %s (%s to %s)<br>%s households", esc(cats[ci]), if (nzchar(l)) paste0(" \u00b7 ", esc(l)) else "",
                     fmt(q[2]), fmt(q[1]), fmt(q[3]), cnt(length(k)))
      stk <- sprintf("v%d_%d", ci, gi)
      series[[length(series) + 1]] <- list(type = "bar", stack = stk, silent = TRUE, barGap = "-100%", barCategoryGap = 0,
                                           itemStyle = list(color = "transparent"), tooltip = list(show = FALSE),
                                           data = round(centre - hw, 4))
      series[[length(series) + 1]] <- list(type = "bar", stack = stk, name = if (nzchar(l)) l else "Households", barGap = "-100%",
                                           barCategoryGap = 0, itemStyle = list(color = gb_tint(col, 0.45)),
                                           data = lapply(hw, function(h) list(value = round(2 * h, 4), tip = tip)))
    }
    opt <- list(
      grid = list(left = 12, right = 18, top = 30, bottom = if (legend) 56 else 34, containLabel = TRUE),
      xAxis = list(list(type = "value", min = 0.5, max = length(cats) + 0.5, show = FALSE),
                   list(type = "category", data = I(cats), position = "bottom", name = lab(ccol), nameLocation = "middle", nameGap = 28,
                        axisTick = list(show = FALSE), axisLabel = list(interval = 0, hideOverlap = TRUE))),
      yAxis = list(type = "category", data = I(fmt(mids)), name = lab(ncol), nameLocation = "end", nameTextStyle = list(align = "left"),
                   axisTick = list(show = FALSE), axisLabel = list(hideOverlap = TRUE)),
      series = series)
    out <- done(opt, note, list(x = NULL, y = range(yv[iv])))
    if (legend) out$option$legend$data <- I(lv)
    return(out)
  }

  # ---- two categories: bars, one panel per group
  xc <- as_cat(x); yc <- as_cat(y, 8); i <- keep(xc, yc)
  note <- sprintf("%s households \u00b7 colours: %s", cnt(length(i)), lab(y))
  ycols <- pal(yc)
  xs <- levels(droplevels(xc[i])); ys <- levels(droplevels(yc[i]))
  ytitle <- if (type == "stack100") "% of households" else "Households"
  panel <- function(j, p) {
    tab <- table(factor(xc[j], levels = xs), factor(yc[j], levels = ys))
    val <- if (type == "stack100") sweep(tab, 1, pmax(rowSums(tab), 1), "/") * 100 else tab
    lapply(ys, function(l) list(
      type = "bar", name = l, stack = if (type == "dodge") NULL else paste0("s", p), xAxisIndex = p - 1, yAxisIndex = p - 1,
      itemStyle = list(color = ycols[[l]]), barMaxWidth = 46,
      data = lapply(xs, function(r) list(value = round(val[r, l], 1), tip = sprintf("<b>%s</b><br>%s: %s households%s", esc(r), esc(l), cnt(tab[r, l]),
                                                                                     if (type == "stack100") sprintf(" (%.1f%%)", val[r, l]) else "")))))
  }
  tab <- table(xc[i], yc[i])
  ytop <- if (type == "stack100") 100 else if (type == "dodge") max(tab) else max(rowSums(tab))
  auto <- list(x = NULL, y = c(0, ytop))
  if (is.null(gf)) {
    opt <- list(xAxis = caxis(xs, lab(x)), yAxis = vaxis(ytitle, scale = FALSE), series = panel(i, 1))
    out <- done(opt, note, auto, show_legend = TRUE)
    out$option$legend$data <- I(ys)
    return(out)
  }
  lvs <- levels(droplevels(gf[i])); np <- length(lvs); nc <- min(3, np); nr <- ceiling(np / nc)
  ph <- 230; top0 <- 30; gap <- 46; height <- top0 + nr * (ph + gap) + 30
  grids <- list(); xa <- list(); ya <- list(); titles <- list(); series <- list()
  for (p in seq_len(np)) {
    r <- (p - 1) %/% nc; cc <- (p - 1) %% nc
    left <- sprintf("%.1f%%", 2 + cc * 98 / nc); width <- sprintf("%.1f%%", 98 / nc - 4)
    top <- top0 + r * (ph + gap)
    grids[[p]] <- list(left = left, width = width, top = top + 26, height = ph - 46, containLabel = TRUE)
    titles[[p]] <- list(text = lvs[p], left = left, top = top, textStyle = list(fontSize = 11, fontWeight = 600))
    xa[[p]] <- c(caxis(xs, ""), list(gridIndex = p - 1))
    ya[[p]] <- c(vaxis("", ymin %||% 0, ymax %||% ytop), list(gridIndex = p - 1))
    series <- c(series, panel(i[gf[i] == lvs[p]], p))
  }
  opt <- list(title = titles, grid = grids, xAxis = xa, yAxis = ya, series = series,
              legend = list(bottom = 0, type = "scroll", data = I(ys)), tooltip = list(trigger = "item", formatter = "fn:tip"))
  note <- paste0(note, " \u00b7 bars: ", tolower(ytitle), " \u00b7 one panel per ", lab(g))
  attr(opt, "height") <- height + 30
  list(option = opt, note = note, auto = auto)
}

#' The table builder's cross-tab as a data frame for render_react_table()
#'
#' The row categories, then one column per column category and the total
#' (keys c1, c2, ...; their headers in `labels`). Percentages as shares 0-1.
#' @return list(data, labels, formats, styles, what, n, chi) or NULL
#' @noRd
ct_frame <- function(ct, row_label, what) {
  tab <- ct$table; stat <- ct$stat
  pct <- stat %in% c("row", "col", "total")
  v <- if (pct) tab / 100 else tab
  keys <- paste0("c", seq_len(ncol(v)))
  out <- data.frame(row = rownames(v), stringsAsFactors = FALSE, check.names = FALSE)
  for (j in seq_len(ncol(v))) out[[keys[j]]] <- unname(v[, j])
  labels <- c(list(row = row_label), stats::setNames(as.list(colnames(v)), keys))
  f <- switch(stat, n = , sum = "int", mean = "num", "pct1")
  body <- v[-nrow(v), if (ncol(v) == 1) 1 else -ncol(v), drop = FALSE]
  rng <- range(body, na.rm = TRUE)
  styles <- list()
  if (all(is.finite(rng)) && diff(rng) > 0) {
    # a light-to-blue scale on the cells (not the totals); dark text pinned,
    # so it reads in light and dark mode
    br <- rng[1] + diff(rng) * c(.2, .4, .6, .8)
    st <- list(breaks = br, colors = c("#f2f7fb", "#dcebf6", "#bdd9ef", "#94c1e4", "#68a7d8"),
               text = rep("#1f2a37", 5))
    body_keys <- if (ncol(v) == 1) keys else keys[-length(keys)]
    styles <- stats::setNames(rep(list(st), length(body_keys)), body_keys)
  }
  list(data = out, labels = labels, formats = stats::setNames(rep(list(f), length(keys)), keys), styles = styles,
       what = what, n = ct$n, chi = ct$chi)
}

# ---- The Overview map (React: MapLibre + deck.gl) ---------------------------

#' Bytes as base64 on one line (no line breaks)
#' @noRd
b64_line <- function(r) gsub("\n", "", jsonlite::base64_enc(r), fixed = TRUE)

#' The map's points as compact binary: lon / lat pairs as little-endian
#' float32, base64 (8 bytes a household; never one object per point)
#' @param bounds c(west, south, east, north): the view the map opens on
#' @noRd
map_points_payload <- function(lng, lat, bounds) {
  list(n = length(lng),
       pos = b64_line(writeBin(as.vector(rbind(lng, lat)), raw(), size = 4, endian = "little")),
       bounds = as.numeric(bounds))
}

#' The map's colours: one byte a point (its index in `palette`) and the legend
#'
#' Categories take the IPC ramp (interpolated beyond five), blank and missing
#' a grey of their own; a number with more than 8 values a 255-step YlOrRd
#' scale (the last palette entry is the grey).
#' @return list(n, palette, code (base64 of one byte a point), legend =
#'   list(numeric, colors, labels))
#' @noRd
map_colour_codes <- function(values) {
  grey <- "#BEBEBE"
  if (inherits(values, "haven_labelled")) values <- labelled_to_plain(data.frame(v = values))$v
  n <- length(values)
  out <- function(palette, code, legend) list(n = n, palette = I(palette), code = b64_line(as.raw(code)), legend = legend)
  if (is.numeric(values) && length(unique(stats::na.omit(values))) > 8) {
    r <- range(values[is.finite(values)])
    pal <- leaflet::colorNumeric("YlOrRd", domain = r)(seq(r[1], r[2], length.out = 255))
    code <- if (r[2] > r[1]) round((values - r[1]) / (r[2] - r[1]) * 254) else rep(0, n)
    code[!is.finite(values)] <- 255
    stops <- seq(r[1], r[2], length.out = 5)
    return(out(c(pal, grey), code, list(numeric = TRUE, colors = I(pal[round(seq(1, 255, length.out = 7))]),
                                        labels = I(format(signif(stops, 3), big.mark = ",", trim = TRUE)))))
  }
  # judged on the distinct answers, not on every household
  v <- as.character(values)
  u <- unique(v)
  lv <- sort(u[!is.na(u) & nzchar(trimws(u))])
  ipc <- c("#CDFACD", "#FAE61E", "#E67800", "#C80000", "#640000")
  cols <- if (length(lv) == 0) character(0)
          else if (length(lv) <= length(ipc)) ipc[seq_along(lv)]
          else grDevices::colorRampPalette(ipc)(length(lv))
  code <- match(v, lv) - 1L
  na <- anyNA(code)
  code[is.na(code)] <- length(lv)
  out(c(cols, grey), code, list(numeric = FALSE, colors = I(c(cols, if (na) grey)),
                                labels = I(c(lv, if (na) "Not specified"))))
}
