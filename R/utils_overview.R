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
                                         sub = sprintf("%s to %s", format(min(day, na.rm = TRUE), "%d %b"), format(max(day, na.rm = TRUE), "%d %b %Y")))
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
