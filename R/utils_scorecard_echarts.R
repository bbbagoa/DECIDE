#' ECharts options for the Targeting Design charts
#'
#' The React page (react/src/pages/design/) draws each chart from the option
#' its `render_echart()` output sends (R/utils_react_render.R). These build
#' the options the plotly charts drew: lollipops, mirrored distributions, ROC
#' curves, grouped bars, scatter maps, lines. Colours carry meaning only
#' (vulnerable red, not vulnerable green, inclusion blue, exclusion red);
#' fonts, axes and the rest come from the WFP theme in light and dark mode.
#' Formatters are names the page registers (`fn:pctv`: a value already in
#' percent, `fn:abspctv`: its absolute value, for mirrored charts).
#' @name scorecard_echarts
#' @noRd
NULL

ec_esc <- function(x) htmltools::htmlEscape(as.character(x))

#' Data items with a hover text each (`fn:tip`); NA becomes ECharts' "-"
#' @noRd
ec_items <- function(values, tips = NULL) {
  lapply(seq_along(values), function(i) {
    v <- unname(values[[i]])
    e <- list(value = if (length(v) == 1 && is.na(v)) "-" else v)
    if (!is.null(tips)) e$tip <- tips[[i]]
    e
  })
}

ec_grid <- function(top = 34, left = 30, right = 18, bottom = 30) list(top = top, left = left, right = right, bottom = bottom, containLabel = TRUE)
ec_legend <- function(...) list(top = 0, left = 0, type = "scroll", ...)
ec_tip <- function(trigger = "item") list(trigger = trigger, formatter = "fn:tip", confine = TRUE)
ec_dash <- function(color = "#5b6b7c") list(type = "dashed", color = color, width = 1.5)

#' The grey of reference lines: reads on light and dark surfaces
#' @noRd
EC_REF <- "#7a8794"

#' A reference line (threshold, overall share) on a series
#' @param at list(xAxis = v) or list(yAxis = v), several allowed.
#' @noRd
ec_markline <- function(at, label = NULL, color = EC_REF, dotted = FALSE) {
  vertical <- length(at) && !is.null(at[[1]]$xAxis)
  list(silent = TRUE, symbol = "none", animation = FALSE,
       lineStyle = list(type = if (dotted) "dotted" else "dashed", color = color, width = 1.6),
       label = if (is.null(label)) list(show = FALSE) else
         list(show = TRUE, formatter = label, position = if (vertical) "end" else "insideEndTop", fontSize = 11,
              color = color, textBorderWidth = 0),
       data = at)
}

#' Horizontal lollipops coloured by direction (inclusion / exclusion)
#' @param tip hover text per criterion (HTML; escape user text).
#' @noRd
ec_lollipop <- function(criterion, value, direction, tip, xtitle) {
  cats <- as.character(criterion)
  cols <- c(inclusion = "#007DBC", exclusion = "#c5192d")
  labs <- c(inclusion = "Inclusion", exclusion = "Exclusion")
  ser <- list(); leg <- character(0)
  for (d in names(cols)) {
    on <- which(direction %in% d)
    if (!length(on)) next
    v <- rep(NA_real_, length(cats)); v[on] <- unname(value[on])
    ser[[length(ser) + 1]] <- list(type = "bar", name = labs[[d]], data = ec_items(v), barWidth = 3, barGap = "-100%",
                                   itemStyle = list(color = cols[[d]], borderRadius = 0), silent = TRUE, tooltip = list(show = FALSE))
    ser[[length(ser) + 1]] <- list(type = "scatter", name = labs[[d]], symbolSize = 11, z = 3,
                                   itemStyle = list(color = cols[[d]], borderColor = "#ffffff", borderWidth = 1.5),
                                   data = lapply(on, function(i) list(value = list(unname(value[[i]]), cats[[i]]), tip = tip[[i]])))
    leg <- c(leg, labs[[d]])
  }
  list(legend = ec_legend(data = I(leg)), grid = ec_grid(), tooltip = ec_tip(),
       xAxis = list(type = "value", name = xtitle, nameLocation = "middle", nameGap = 26,
                    axisLine = list(show = TRUE, onZero = TRUE)),
       yAxis = list(type = "category", data = I(cats), inverse = TRUE,
                    axisLabel = list(interval = if (length(cats) > 24) "auto" else 0, hideOverlap = TRUE)),
       series = ser)
}

#' Mirrored distribution of a score: one group above the axis, the other
#' below, each as a share of its own size (`score_bins()`), the threshold drawn
#' @noRd
ec_mirrored <- function(score, vulnerable, threshold = NULL, xtitle = "Score",
                        labels = c("Vulnerable", "Not vulnerable")) {
  ok <- !is.na(score) & !is.na(vulnerable)
  h <- score_bins(score[ok], vulnerable[ok] %in% c(TRUE, 1))
  rng <- function(i) sprintf("%s to %s", fmt5(h$lower[i]), fmt5(h$upper[i]))
  i <- seq_len(nrow(h))
  top <- list(type = "bar", name = labels[1], barWidth = "92%", itemStyle = list(color = "#c5192d"),
              data = lapply(i, function(k) list(value = list(h$mid[k], round(h$vuln[k], 2)),
                                                tip = sprintf("Score %s<br>%s: <b>%.1f%%</b> (%s households)", rng(k), ec_esc(labels[1]), h$vuln[k], h$n_vuln[k]))))
  bot <- list(type = "bar", name = labels[2], barWidth = "92%", barGap = "-100%", itemStyle = list(color = "#3f7e44"),
              data = lapply(i, function(k) list(value = list(h$mid[k], -round(h$not[k], 2)),
                                                tip = sprintf("Score %s<br>%s: <b>%.1f%%</b> (%s households)", rng(k), ec_esc(labels[2]), h$not[k], h$n_not[k]))))
  if (length(threshold) == 1 && is.finite(threshold))
    top$markLine <- ec_markline(list(list(xAxis = threshold)), sprintf("threshold %s", fmt5(threshold)))
  list(legend = ec_legend(), grid = ec_grid(top = 52), tooltip = ec_tip(),
       xAxis = list(type = "value", name = xtitle, nameLocation = "middle", nameGap = 26, scale = TRUE,
                    min = min(h$lower), max = max(h$upper)),
       yAxis = list(type = "value", name = "% of the group", nameLocation = "middle", nameGap = 40,
                    axisLabel = list(formatter = "fn:abspctv")),
       series = list(top, bot))
}

#' A histogram of a score with the threshold drawn
#' @param density Add the density curve (scaled to the counts).
#' @param split Bars above the threshold (eligible) in `colour`, the others grey.
#' @noRd
ec_histogram <- function(x, threshold = NULL, xtitle = "Score", bins = 30, colour = "#007DBC",
                         density = FALSE, split = FALSE, dotted = FALSE) {
  x <- x[is.finite(x)]
  if (!length(x)) return(NULL)
  br <- unique(pretty(range(x), n = bins))
  if (length(br) < 2) br <- c(min(x) - 0.5, min(x) + 0.5)
  n <- as.integer(table(cut(x, br, include.lowest = TRUE)))
  mid <- (utils::head(br, -1) + br[-1]) / 2
  thr <- length(threshold) == 1 && is.finite(threshold)
  col <- function(k) if (split && thr && mid[k] <= threshold) "#8a96a3" else colour
  s <- list(type = "bar", name = "Households", barWidth = "96%", itemStyle = list(color = colour),
            data = lapply(seq_along(n), function(k) list(value = list(mid[k], n[k]), itemStyle = list(color = col(k)),
                                                         tip = sprintf("Score %s to %s<br><b>%s</b> households", fmt5(br[k]), fmt5(br[k + 1]), format(n[k], big.mark = ",")))))
  if (thr) s$markLine <- ec_markline(list(list(xAxis = threshold)), sprintf("threshold %s", fmt5(threshold)), dotted = dotted)
  series <- list(s)
  if (density && length(unique(x)) > 1) {
    # the kernel density in households per bin, so it sits on the bars
    d <- stats::density(x, n = 128, from = min(br), to = max(br))
    k <- length(x) * diff(br)[1]
    series[[2]] <- list(type = "line", name = "Density", smooth = TRUE, showSymbol = FALSE, silent = TRUE,
                        lineStyle = list(color = "#26bde2", width = 2.2), itemStyle = list(color = "#26bde2"),
                        data = lapply(seq_along(d$x), function(i) list(round(d$x[i], 4), round(d$y[i] * k, 3))))
  }
  list(grid = ec_grid(top = 32), tooltip = ec_tip(),
       xAxis = list(type = "value", name = xtitle, nameLocation = "middle", nameGap = 26, min = min(br), max = max(br)),
       yAxis = list(type = "value", name = "Households", nameLocation = "middle", nameGap = 40),
       series = series)
}

#' Bars by category, one series per group (grouped), vertical or horizontal
#' @param series list of list(name, values, color, tips); `colors` per item allowed.
#' @param pct values are percentages (axis 0-100 with %).
#' @noRd
ec_bars <- function(cats, series, horizontal = FALSE, value_name = NULL, pct = FALSE, max = NULL,
                    stack = FALSE, rotate = NULL, legend = length(series) > 1) {
  cats <- as.character(cats)
  ser <- lapply(series, function(s) {
    d <- ec_items(s$values, s$tips)
    if (!is.null(s$colors)) for (k in seq_along(d)) d[[k]]$itemStyle <- list(color = s$colors[[k]])
    out <- list(type = "bar", name = s$name %||% "", data = d, barMaxWidth = 38)
    if (!is.null(s$color)) out$itemStyle <- list(color = s$color)
    if (isTRUE(stack)) out$stack <- "s"
    if (!is.null(s$label)) out$label <- s$label
    if (!is.null(s$markLine)) out$markLine <- s$markLine
    out
  })
  cax <- list(type = "category", data = I(cats),
              axisLabel = list(interval = if (length(cats) <= 40) 0 else "auto", hideOverlap = TRUE,
                               rotate = rotate %||% (if (!horizontal && length(cats) > 8) 90 else 0)))
  vax <- list(type = "value", name = value_name, nameLocation = "middle", nameGap = if (horizontal) 26 else 40)
  # (a NULL left in the list would reach ECharts as null and hide the labels)
  if (pct) { vax$axisLabel <- list(formatter = "fn:pctv"); vax$min <- 0; vax$max <- max %||% 100 } else if (!is.null(max)) vax$max <- max
  if (horizontal) { cax$inverse <- TRUE; cax$axisLabel$rotate <- 0 }
  out <- list(grid = ec_grid(top = if (legend) 34 else 16), tooltip = ec_tip(), series = ser)
  if (legend) out$legend <- ec_legend()
  if (horizontal) { out$xAxis <- vax; out$yAxis <- cax } else { out$xAxis <- cax; out$yAxis <- vax }
  out
}

#' Points by group (scatter), at most what the caller sampled
#' @param pal named colours, one per group.
#' @noRd
ec_scatter <- function(x, y, group, pal, xname, yname, tip_fmt = "%s<br>%s: %.2f, %s: %.2f", size = 5,
                       opacity = 0.55, extra = list(), square = FALSE) {
  lv <- names(pal)[names(pal) %in% unique(group)]
  lv <- c(lv, setdiff(sort(unique(group)), lv))
  ser <- lapply(lv, function(g) {
    k <- which(group == g)
    list(type = "scatter", name = g, symbolSize = size, large = length(k) > 2000,
         itemStyle = list(color = pal[[g]] %||% "#8a96a3", opacity = opacity),
         data = lapply(k, function(i) list(value = list(round(x[[i]], 4), round(y[[i]], 4)),
                                           tip = sprintf(tip_fmt, ec_esc(g), xname, x[[i]], yname, y[[i]]))))
  })
  ax <- function(nm) list(type = "value", name = nm, nameLocation = "middle", nameGap = 28, scale = TRUE)
  out <- list(legend = ec_legend(), grid = ec_grid(), tooltip = ec_tip(), xAxis = ax(xname), yAxis = ax(yname),
              series = c(ser, extra))
  if (square) { out$yAxis$nameGap <- 36 }
  out
}

#' Lines on a value axis (ROC curves, error curves)
#' @param lines list of list(name, x, y, color, width, tips, dashed)
#' @noRd
ec_lines <- function(lines, xname, yname, xmax = NULL, ymax = NULL, xpct = FALSE, ypct = FALSE, legend = TRUE) {
  ser <- lapply(lines, function(l) {
    d <- lapply(seq_along(l$x), function(i) {
      e <- list(value = list(round(l$x[[i]], 5), round(l$y[[i]], 5)))
      if (!is.null(l$tips)) e$tip <- l$tips[[i]]
      e
    })
    list(type = "line", name = l$name, showSymbol = FALSE, symbolSize = 4, data = d, z = l$z %||% 2,
         lineStyle = list(width = l$width %||% 2, color = l$color, type = if (isTRUE(l$dashed)) "dashed" else "solid"),
         itemStyle = list(color = l$color))
  })
  ax <- function(nm, mx, pc) {
    a <- list(type = "value", name = nm, nameLocation = "middle", nameGap = 28, min = 0)
    if (!is.null(mx)) a$max <- mx
    if (pc) a$axisLabel <- list(formatter = "fn:pctv")
    a
  }
  out <- list(grid = ec_grid(top = if (legend) 34 else 16), tooltip = list(trigger = "axis", formatter = "fn:tip", confine = TRUE),
              xAxis = ax(xname, xmax, xpct), yAxis = ax(yname, ymax, ypct), series = ser)
  out$yAxis$nameGap <- 40
  if (legend) out$legend <- ec_legend()
  out
}

#' Thin a curve to at most n points, keeping both ends
#' @noRd
ec_thin <- function(d, n = 600) {
  if (NROW(d) <= n) return(d)
  d[unique(c(1, round(seq(1, nrow(d), length.out = n)), nrow(d))), , drop = FALSE]
}

#' A ROC curve with the chosen threshold marked and the AUC written
#' @noRd
ec_roc <- function(curve, here = NULL, auc = NA_real_, name = "Scorecard") {
  cur <- ec_thin(curve)
  tips <- sprintf("Threshold &gt; %s<br>Recall <b>%.1f%%</b><br>False positive rate <b>%.1f%%</b>",
                  fmt5(round(cur$threshold, 2)), 100 * cur$tpr, 100 * cur$fpr)
  o <- ec_lines(list(list(name = name, x = cur$fpr, y = cur$tpr, color = "#007DBC", width = 3, tips = tips)),
                "False positive rate (1 - specificity)", "Recall (sensitivity)", 1, 1)
  o$series[[1]]$markLine <- list(silent = TRUE, symbol = "none", label = list(show = FALSE),
                                 lineStyle = list(type = "dashed", color = "#9aa5b1", width = 1.2),
                                 data = list(list(list(coord = c(0, 0)), list(coord = c(1, 1)))))
  if (NROW(here)) o$series[[2]] <- list(type = "scatter", name = "Chosen threshold", symbolSize = 13, z = 5,
                                        itemStyle = list(color = "#c5192d", borderColor = "#ffffff", borderWidth = 1.5),
                                        data = list(list(value = list(here$fpr[1], here$tpr[1]),
                                                         tip = sprintf("<b>Chosen threshold</b><br>Recall %.1f%%<br>False positive rate %.1f%%", 100 * here$tpr[1], 100 * here$fpr[1]))))
  o$tooltip <- ec_tip()
  if (is.finite(auc)) o$title <- list(text = sprintf("AUC = %.3f", auc), right = 28, bottom = 52, textStyle = list(fontSize = 13))
  o
}

#' Box plots of a score by group (five numbers each, the mean marked)
#' @param pal named colours, one per group.
#' @noRd
ec_box <- function(score, group, pal, ytitle, threshold = NULL, horizontal = FALSE, points = FALSE) {
  lv <- names(pal)[names(pal) %in% unique(group)]
  st <- lapply(lv, function(g) { v <- score[group == g & !is.na(score)]; if (length(v)) grDevices::boxplot.stats(v)$stats else rep(NA, 5) })
  mn <- vapply(lv, function(g) mean(score[group == g], na.rm = TRUE), numeric(1))
  box <- list(type = "boxplot", name = ytitle, boxWidth = c(24, 70),
              data = lapply(seq_along(lv), function(k) list(name = lv[k], value = round(st[[k]], 4),
                                                            itemStyle = list(borderColor = pal[[lv[k]]], color = paste0(pal[[lv[k]]], "33")))),
              tooltip = list(formatter = "fn:tip"))
  for (k in seq_along(lv)) box$data[[k]]$tip <- sprintf("<b>%s</b><br>max %s<br>Q3 %s<br>median %s<br>Q1 %s<br>min %s<br>mean %s",
                                                        ec_esc(lv[k]), fmt5(round(st[[k]][5], 2)), fmt5(round(st[[k]][4], 2)), fmt5(round(st[[k]][3], 2)),
                                                        fmt5(round(st[[k]][2], 2)), fmt5(round(st[[k]][1], 2)), fmt5(round(mn[k], 2)))
  mean_s <- list(type = "scatter", name = "Mean", symbol = "diamond", symbolSize = 10,
                 itemStyle = list(color = "#1f2a37", borderColor = "#ffffff", borderWidth = 1),
                 data = lapply(seq_along(lv), function(k) list(value = if (horizontal) list(round(mn[[k]], 4), lv[[k]]) else list(lv[[k]], round(mn[[k]], 4)),
                                                               tip = sprintf("%s: mean %s", ec_esc(lv[[k]]), fmt5(round(mn[[k]], 2))))))
  ser <- list(box, mean_s)
  if (isTRUE(points)) {
    for (g in lv) {
      v <- score[group == g & !is.na(score)]
      if (length(v) > 1500) { set.seed(5); v <- sample(v, 1500) }
      ser[[length(ser) + 1]] <- list(type = "scatter", name = g, symbolSize = 4, itemStyle = list(color = pal[[g]], opacity = 0.35),
                                     tooltip = list(show = FALSE), silent = TRUE,
                                     data = lapply(v, function(x) if (horizontal) list(round(x, 4), g) else list(g, round(x, 4))))
    }
  }
  if (length(threshold) == 1 && is.finite(threshold))
    ser[[1]]$markLine <- ec_markline(list(if (horizontal) list(xAxis = threshold) else list(yAxis = threshold)),
                                     sprintf("threshold %s", fmt5(threshold)))
  cax <- list(type = "category", data = I(lv))
  vax <- list(type = "value", name = ytitle, nameLocation = "middle", nameGap = 40, scale = TRUE)
  out <- list(grid = ec_grid(top = 20), tooltip = ec_tip(), series = ser)
  if (horizontal) { out$xAxis <- vax; out$yAxis <- cax } else { out$xAxis <- cax; out$yAxis <- vax }
  out
}

#' A heatmap of shares (0-100) with the value written in each cell
#' @noRd
ec_heat <- function(xcats, ycats, z, tip_fmt = "%s<br>%s: <b>%.0f%%</b> meet it") {
  d <- list()
  for (i in seq_along(ycats)) for (j in seq_along(xcats)) {
    v <- z[i, j]
    d[[length(d) + 1]] <- list(value = list(j - 1, i - 1, if (is.na(v)) "-" else round(v, 1)),
                               tip = if (is.na(v)) "" else sprintf(tip_fmt, ec_esc(ycats[i]), ec_esc(xcats[j]), v))
  }
  list(grid = ec_grid(top = 10, bottom = 46), tooltip = ec_tip(),
       xAxis = list(type = "category", data = I(xcats), splitArea = list(show = FALSE)),
       yAxis = list(type = "category", data = I(ycats), axisLabel = list(interval = 0)),
       visualMap = list(min = 0, max = 100, calculable = FALSE, orient = "horizontal", left = "center", bottom = 0,
                        itemHeight = 120, inRange = list(color = I(c("rgba(0,125,188,0.06)", "#007DBC"))),
                        text = I(c("100%", "0%"))),
       series = list(list(type = "heatmap", data = d,
                          # dark figures with a light halo: readable on pale and dark cells
                          label = list(show = length(d) <= 200, formatter = "fn:hmap", color = "#1f2a37",
                                       textBorderColor = "rgba(255,255,255,0.85)", textBorderWidth = 2),
                          itemStyle = list(borderColor = "rgba(128,128,128,0.25)", borderWidth = 1))))
}

#' 100% stacked columns: the vulnerable and other households in each area,
#' the share overall as a dotted line
#' @noRd
ec_area_share <- function(d, overall, labels = c("Vulnerable", "Not vulnerable"), overall_label = "All areas: %.0f%% vulnerable") {
  hov <- function(k, lab) sprintf("<b>%s</b><br>%s: %.0f%% (%s of %s households)", ec_esc(d$area), ec_esc(lab), 100 * k / d$households,
                                  format(k, big.mark = ","), format(d$households, big.mark = ","))
  # every area shown: past 15 the areas run down the side, one row each, and
  # the chart grows with them (no zoom slider)
  n <- nrow(d)
  horizontal <- n > 15
  lab <- list(show = n <= 40, position = "inside", formatter = "fn:pctv", color = "#ffffff", fontSize = if (n > 25) 9 else 10)
  ref <- if (horizontal) list(xAxis = overall) else list(yAxis = overall)
  o <- ec_bars(d$area, list(
    list(name = labels[1], values = round(100 * d$share, 1), color = "#c5192d", tips = hov(d$vulnerable, labels[1]), label = lab,
         markLine = ec_markline(list(ref), sprintf(overall_label, overall), dotted = TRUE)),
    list(name = labels[2], values = round(100 * (1 - d$share), 1), color = "#3f7e44", tips = hov(d$households - d$vulnerable, labels[2]), label = lab)),
    value_name = "Households (%)", pct = TRUE, stack = TRUE, horizontal = horizontal)
  attr(o, "height") <- if (horizontal) max(440, 22 * n + 90) else if (n > 8) 440 else 380
  o
}

#' Height of the two charts side by side under "What drives it" (what drives
#' the score, coverage by criterion): the same for both, 640px, taller only
#' when the criteria need more than 26px a row
#' @noRd
drive_pair_height <- function(n) max(640, 26 * n + 110)
