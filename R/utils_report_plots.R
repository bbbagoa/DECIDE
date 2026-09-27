#' Figures for the design report (billboarder)
#'
#' Interactive billboard.js charts, rendered into the self-contained HTML
#' report with their scripts inlined, so the file still opens offline and
#' prints as vector graphics. Every argument is optional; a figure is drawn
#' only when its data is there. The correlation matrix is a heat-coloured
#' table, which billboard.js has no chart type for.
#' @name design_report_figures
#' @noRd
NULL

# Shared look: WFP colours, legend below, light grid.
rp_cols <- list(vuln = "#c5192d", not = "#3f7e44", incl = "#0A6EB4", excl = "#c5192d",
                elig = "#0A6EB4", notelig = "#9aa5b1",
                models = c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#6c757d", "#8a6100", "#5b3a8e", "#d9822b", "#1b9e77"))

rp_base <- function(height = 320) {
  billboarder::billboarder(width = "100%", height = height) |>
    billboarder::bb_legend(position = "bottom") |>
    billboarder::bb_y_grid(show = TRUE) |>
    billboarder::bb_add_style(".bb-ygrid" = "stroke: rgba(128,128,128,.18); stroke-dasharray: 0;")
}

rp_colors <- function(bb, cols) do.call(billboarder::bb_colors_manual, c(list(bb), as.list(cols)))

rp_axis_label <- function(text, rotated = FALSE) {
  list(text = text, position = if (rotated) "outer-center" else "outer-middle")
}

# Vertical columns, one per variable, every variable kept: first column is
# the category, the others are series (inclusion up, exclusion down when
# stacked). Labels vertical when there are many.
rp_columns <- function(d, cols, value_label, stacked = TRUE) {
  many <- nrow(d) > 8
  long <- nrow(d) > 12
  rp_base(if (many) 440 else 340) |>
    billboarder::bb_barchart(d, stacked = stacked) |>
    rp_colors(cols) |>
    billboarder::bb_bar(width = list(ratio = 0.7)) |>
    billboarder::bb_x_axis(tick = list(multiline = FALSE, rotate = if (many) 90 else 0, autorotate = FALSE, culling = FALSE,
                                       format = if (long) htmlwidgets::JS("function(i, name){ return i % 2 === 1 ? '' : name; }") else NULL),
                           height = if (many) 130 else NULL) |>
    billboarder::bb_y_axis(label = rp_axis_label(value_label))
}

# Vertical lollipops: a thin stem and a dot per variable, every variable kept
# (inclusion up, exclusion down). d: category, inclusion, exclusion (0 where
# the criterion is not of that direction). With many variables only about 20
# names are written under the axis; the tooltip gives every one.
rp_lollipop <- function(d, cols, value_label) {
  n <- nrow(d); many <- n > 8
  nm <- names(d)[2:3]
  heads <- paste0(nm, " ")
  stem <- d
  for (k in nm) stem[[k]][stem[[k]] == 0] <- NA
  dd <- stem
  dd[[heads[1]]] <- stem[[nm[1]]]; dd[[heads[2]]] <- stem[[nm[2]]]
  bb <- rp_base(if (many) 440 else 340) |>
    billboarder::bb_barchart(dd) |>
    rp_colors(stats::setNames(c(cols, cols), c(nm, heads))) |>
    billboarder::bb_bar(width = list(ratio = 0.08)) |>
    billboarder::bb_point(r = 5.5) |>
    billboarder::bb_legend(hide = heads) |>
    # past 12 variables every other name is written (odd positions); the
    # tooltip gives every one
    billboarder::bb_x_axis(tick = list(multiline = FALSE, rotate = if (many) 90 else 0, autorotate = FALSE, culling = FALSE,
                                       format = if (n > 12) htmlwidgets::JS("function(i, name){ return i % 2 === 1 ? '' : name; }") else NULL),
                           height = if (many) 130 else NULL) |>
    billboarder::bb_y_axis(label = rp_axis_label(value_label)) |>
    billboarder::bb_tooltip(format = list(value = htmlwidgets::JS(
      "function(v, r, id){ return id.slice(-1) === ' ' ? undefined : v; }")))
  # stems stacked on one bar (centred under the dot), dots drawn as points only
  bb$x$bb_opts$data$groups <- list(as.list(nm))
  bb$x$bb_opts$data$types <- stats::setNames(list("line", "line"), heads)
  billboarder::bb_add_style(bb, ".bb-line" = "stroke-opacity: 0;")
}

# Radar: one spoke per variable, every variable kept; series as polygons.
# Long names are shortened on the spokes (the table in the report and the
# Excel scorecard carry them in full).
rp_radar <- function(d, cols, max = 100, named = 12) {
  # past `named` spokes, every other spoke is named (odd positions); the
  # others get an invisible but unique name, and the tooltip gives them all
  full <- as.character(d[[1]])
  n <- nrow(d)
  shown <- ifelse(nchar(full) > 24, paste0(substr(full, 1, 23), "..."), full)
  # beyond `named` spokes: an invisible (but unique) name; the tooltip says it
  if (n > named) shown[seq(2, n, by = 2)] <- vapply(seq(2, n, by = 2), function(i) strrep("\u200b", i), character(1))
  d[[1]] <- shown
  billboarder::billboarder(width = "100%", height = if (n > 20) 560 else 440) |>
    billboarder::bb_radarchart(d) |>
    rp_colors(cols) |>
    billboarder::bb_radar(axis = list(max = max, line = list(show = TRUE), text = list(show = TRUE)),
                          level = list(depth = 4, text = list(format = htmlwidgets::JS("function(x){ return Math.round(x) + '%'; }"))),
                          direction = list(clockwise = TRUE)) |>
    billboarder::bb_point(r = 2.5) |>
    billboarder::bb_legend(position = "bottom") |>
    billboarder::bb_tooltip(format = list(title = htmlwidgets::JS(sprintf(
      "function(i){ var n = %s; return n[i] !== undefined ? n[i] : i; }", jsonlite::toJSON(full))),
      value = htmlwidgets::JS("function(v){ return (Math.round(v * 10) / 10) + '%'; }"))) |>
    rp_radar_hover()
}

# billboard.js shows a radar's tooltip only over the spoke names: an
# invisible slice around each spoke shows it anywhere on the chart.
rp_radar_hover <- function(bb) {
  bb$x$bb_opts$onrendered <- htmlwidgets::JS(
    "function() {
       var ch = this, g = ch.$.main.select('.bb-chart-radars').node();
       if (!g) return;
       var old = g.querySelector('.tw-radar-hover'); if (old) old.remove();
       var L = [].map.call(g.querySelectorAll('.bb-axis line'), function(l) {
         return [+l.getAttribute('x1'), +l.getAttribute('y1'), +l.getAttribute('x2'), +l.getAttribute('y2')];
       });
       var n = L.length; if (n < 3) return;
       var cx = L[0][0], cy = L[0][1], R = Math.hypot(L[0][2] - cx, L[0][3] - cy) * 1.08;
       var end = function(i) { var dx = L[i][2] - cx, dy = L[i][3] - cy, d = Math.hypot(dx, dy) || 1; return [dx / d, dy / d]; };
       var mid = function(a, b) { var x = a[0] + b[0], y = a[1] + b[1], d = Math.hypot(x, y) || 1; return [x / d, y / d]; };
       var NS = 'http://www.w3.org/2000/svg', h = document.createElementNS(NS, 'g');
       h.setAttribute('class', 'tw-radar-hover');
       for (var i = 0; i < n; i++) (function(i) {
         var e = end(i), a = mid(end((i - 1 + n) % n), e), b = mid(e, end((i + 1) % n));
         var p = document.createElementNS(NS, 'path');
         p.setAttribute('d', 'M' + cx + ',' + cy + 'L' + (cx + R * a[0]) + ',' + (cy + R * a[1]) + 'L' + (cx + R * e[0]) + ',' + (cy + R * e[1]) +
                        'L' + (cx + R * b[0]) + ',' + (cy + R * b[1]) + 'Z');
         p.setAttribute('style', 'fill: transparent; stroke: none; pointer-events: all; cursor: default;');
         p.addEventListener('mouseenter', function() { ch.tooltip.show({ index: i }); });
         p.addEventListener('mouseleave', function() { ch.tooltip.hide(); });
         h.appendChild(p);
       })(i);
       g.appendChild(h);
     }")
  bb
}

# Horizontal bars: first column is the category, the others are series.
rp_hbars <- function(d, cols, value_label, stacked = FALSE, px = 12) {
  n_series <- if (stacked) 1 else ncol(d) - 1
  h <- max(240, 90 + nrow(d) * (14 + px * n_series))
  rp_base(h) |>
    billboarder::bb_barchart(d, rotated = TRUE, stacked = stacked) |>
    rp_colors(cols) |>
    billboarder::bb_bar(width = list(ratio = 0.7)) |>
    billboarder::bb_x_axis(tick = list(multiline = FALSE)) |>
    billboarder::bb_y_axis(label = rp_axis_label(value_label, rotated = TRUE))
}

# ROC curves on a common false-positive-rate grid, so several models share
# one x axis.
rp_roc_grid <- seq(0, 1, by = 0.01)
rp_roc_on_grid <- function(cur) {
  cur <- cur[is.finite(cur$fpr) & is.finite(cur$tpr), , drop = FALSE]
  if (nrow(cur) < 2) return(rep(NA_real_, length(rp_roc_grid)))
  a <- stats::aggregate(tpr ~ fpr, cur, max)
  round(stats::approx(a$fpr, a$tpr, xout = rp_roc_grid, rule = 2, ties = max)$y, 4)
}
rp_roc_chart <- function(d, cols, tr, point = NULL) {
  bb <- rp_base(380) |>
    billboarder::bb_linechart(d, type = "line", show_point = FALSE) |>
    billboarder::bb_x_axis(type = "indexed", min = 0, max = 1, padding = list(left = 0, right = 0),
                           tick = list(values = seq(0, 1, 0.2), outer = FALSE),
                           label = rp_axis_label(tr("False positive rate"), rotated = TRUE)) |>
    billboarder::bb_y_axis(min = 0, max = 1, padding = list(top = 0, bottom = 0),
                           tick = list(values = seq(0, 1, 0.2)),
                           label = rp_axis_label(tr("Recall (1 - exclusion error)"))) |>
    rp_colors(cols)
  bb$x$bb_opts$data$classes <- NULL
  bb <- billboarder::bb_add_style(bb, ".bb-line-Random" = "stroke-dasharray: 5 4;")
  bb
}

rp_cap <- function(x) paste0(toupper(substr(x, 1, 1)), substring(x, 2))

#' The design report shows at most this many variables per chart (the most
#' relevant); the Excel scorecard carries them all (sheet Report_tables).
#' @noRd
RP_TOP <- 15

#' Indices of the `n` most relevant entries (largest `rel`), in their order
#' @noRd
rp_top <- function(rel, n = RP_TOP) {
  keep <- order(-abs(rel))[seq_len(min(n, length(rel)))]
  sort(keep)
}

#' Mark a chart as showing `shown` of `of` variables (read by the captions)
#' @noRd
rp_of <- function(chart, shown, of) {
  if (of > shown) attr(chart, "tw_of") <- c(shown = shown, of = of)
  chart
}
rp_grp <- function(tr) stats::setNames(c(rp_cols$vuln, rp_cols$not), tr(c("Vulnerable", "Not vulnerable")))

#' @noRd
design_report_plots <- function(weights = NULL, roc = NULL, roc_point = NULL,
                                score = NULL, vulnerable = NULL, threshold = NULL, lang = "en") {
  tr <- function(x) i18n_lookup(x, lang)
  out <- list()

  # Points by criterion: inclusion adds, exclusion subtracts.
  if (!is.null(weights) && nrow(weights)) {
    signed <- ifelse(weights$direction == "exclusion", -weights$weight, weights$weight)
    o <- order(signed, decreasing = TRUE)
    d <- data.frame(criterion = weights$criterion[o],
                    a = round(ifelse(weights$direction[o] == "exclusion", 0, signed[o]), 3),
                    b = round(ifelse(weights$direction[o] == "exclusion", signed[o], 0), 3))
    names(d)[2:3] <- rp_cap(tr(c("inclusion", "exclusion")))
    out$weights <- rp_lollipop(d, c(rp_cols$incl, rp_cols$excl), tr("Points added (+) or subtracted (-)"))
  }

  # ROC curve with the chosen threshold marked.
  if (!is.null(roc) && nrow(roc)) {
    d <- data.frame(fpr = rp_roc_grid, Scorecard = rp_roc_on_grid(roc), Random = rp_roc_grid)
    names(d)[2:3] <- tr(c("Scorecard", "Random"))
    cols <- stats::setNames(c(rp_cols$incl, "#9aa5b1"), names(d)[2:3])
    bb <- rp_roc_chart(d, cols, tr)
    if (!is.null(roc_point) && nrow(roc_point)) {
      bb <- billboarder::bb_x_grid(bb, lines = list(list(
        value = round(roc_point$fpr[1], 4),
        text = sprintf("%s: %s %.0f%%", tr("Threshold"), tr("recall"), 100 * roc_point$tpr[1]))))
    }
    out$roc <- bb
  }

  # Score distribution by outcome, threshold marked: mirrored, vulnerable up
  # and not vulnerable down, each as a share of its own group.
  if (!is.null(score) && length(score) && length(vulnerable) == length(score)) {
    ok <- !is.na(score) & !is.na(vulnerable)
    h <- score_bins(score[ok], vulnerable[ok])
    d <- data.frame(bin = format(h$upper, trim = TRUE, drop0trailing = TRUE), a = round(h$vuln, 1), b = -round(h$not, 1))
    names(d)[2:3] <- tr(c("Vulnerable", "Not vulnerable"))
    thr_bin <- findInterval(threshold %||% 0, c(h$lower[1], h$upper), rightmost.closed = TRUE)
    bb <- rp_base(360) |>
      billboarder::bb_barchart(d) |>
      rp_colors(rp_grp(tr)) |>
      billboarder::bb_bar(width = list(ratio = 0.92)) |>
      billboarder::bb_x_axis(tick = list(culling = list(max = 10), multiline = FALSE),
                             label = rp_axis_label(tr("Score (upper bound of the bin)"), rotated = TRUE)) |>
      billboarder::bb_y_axis(label = rp_axis_label(tr("% of the group")),
                             tick = list(format = htmlwidgets::JS("function(v){ return Math.abs(v) + '%'; }"))) |>
      billboarder::bb_y_grid(lines = list(list(value = 0))) |>
      billboarder::bb_tooltip(format = list(value = htmlwidgets::JS("function(v){ return Math.abs(v) + '%'; }"))) |>
      billboarder::bb_x_grid(lines = list(list(value = max(0, thr_bin - 0.5), text = tr("Threshold"))))
    bb$x$bb_opts$data$groups <- list(as.list(names(d)[2:3]))
    out$scores <- bb
  }
  out
}

#' Report charts of a PCA or LDA index
#'
#' PCA: the variation each axis explains (bars) with the cumulative share
#' (line, right axis), and the loadings on the axes kept. LDA: each
#' criterion's correlation with the index.
#' @param index `fit$index` (from `index_effects()`).
#' @param structure LDA only: named correlations of the criteria with the index.
#' @noRd
design_report_index_plots <- function(index, structure = NULL, lang = "en") {
  tr <- function(x) i18n_lookup(x, lang)
  out <- list()
  if (is.null(index)) return(out)
  if (identical(index$type, "cluster")) {
    pr <- index$profiles[, index$rank, drop = FALSE]
    d <- data.frame(criterion = rownames(pr), round(100 * pr, 1), check.names = FALSE)
    pal <- rep_len(c("#c5192d", "#f7b825", "#0A6EB4", "#26bde2", "#3f7e44", "#8a96a3", "#5b6b7c", "#b8c4d0"), ncol(pr))
    out$cluster_profiles <- rp_hbars(d, stats::setNames(pal, names(d)[-1]), tr("% of households meeting it"))
    return(out)
  }
  if (isTRUE(index$type %in% c("pca", "mca"))) {
    ev <- utils::head(index$eigen, 20)
    cum <- 100 * cumsum(index$eigen)[seq_along(ev)] / sum(index$eigen)
    d <- data.frame(axis = paste(tr("Axis"), seq_along(ev)), a = round(ev, 3), b = round(cum, 1))
    names(d)[2:3] <- tr(c("Eigenvalue", "Cumulative % explained"))
    bb <- rp_base(320) |>
      billboarder::bb_barchart(d) |>
      rp_colors(stats::setNames(c(rp_cols$incl, rp_cols$vuln), names(d)[2:3])) |>
      billboarder::bb_y_axis(label = rp_axis_label(names(d)[2])) |>
      billboarder::bb_x_axis(tick = list(multiline = FALSE, rotate = if (length(ev) > 10) 90 else 0, autorotate = FALSE, culling = FALSE),
                             height = if (length(ev) > 10) 70 else NULL) |>
      billboarder::bb_bar(width = list(ratio = if (length(ev) > 10) 0.6 else 0.7)) |>
      billboarder::bb_y_grid(lines = list(list(value = 1, text = "Kaiser: 1")))
    bb$x$bb_opts$data$types <- stats::setNames(list("line"), names(d)[3])
    bb$x$bb_opts$data$axes <- stats::setNames(list("y2"), names(d)[3])
    bb$x$bb_opts$axis$y2 <- list(show = TRUE, min = 0, max = 100, padding = list(top = 0, bottom = 0),
                                 label = rp_axis_label(names(d)[3]))
    out$pca_scree <- bb
    # the correlation circle: each criterion on axes 1 and 2
    V <- index$map_vectors
    if (!is.null(V) && ncol(V) >= 2) {
      co <- sweep(V[, 1:2, drop = FALSE], 2, sqrt(index$eigen[1:2]), "*")
      out$pca_circle <- rp_corr_circle(co[, 1], co[, 2], index$criteria,
                                       sprintf("%s 1 (%.0f%%)", tr("Axis"), 100 * index$eigen[1] / sum(index$eigen)),
                                       sprintf("%s 2 (%.0f%%)", tr("Axis"), 100 * index$eigen[2] / sum(index$eigen)))
    }
  } else if (identical(index$type, "lda") && length(structure)) {
    ds <- data.frame(criterion = names(structure), r = round(unname(structure), 3))
    ds <- ds[order(-ds$r), , drop = FALSE]
    names(ds)[2] <- tr("Correlation with the index")
    out$lda_structure <- rp_hbars(ds, stats::setNames(rp_cols$incl, names(ds)[2]), names(ds)[2])
  }
  out
}

#' Correlation circle for the report: each criterion a labelled point at its
#' correlation with axes 1 and 2, the unit circle and the axes drawn.
#' @noRd
rp_corr_circle <- function(x, y, names, xlab, ylab) {
  # two halves: billboard.js joins a line's points in x order
  up <- seq(0, pi, length.out = 61); lo <- seq(pi, 2 * pi, length.out = 61)
  bb <- billboarder::billboarder(width = "100%", height = 440)
  bb$x$bb_opts <- list(
    data = list(
      xs = list(Criteria = "x_c", CircleU = "x_u", CircleL = "x_l"),
      columns = list(c(list("x_c"), as.list(round(x, 4))), c(list("Criteria"), as.list(round(y, 4))),
                     c(list("x_u"), as.list(round(cos(up), 4))), c(list("CircleU"), as.list(round(sin(up), 4))),
                     c(list("x_l"), as.list(round(cos(lo), 4))), c(list("CircleL"), as.list(round(sin(lo), 4)))),
      types = list(Criteria = "scatter", CircleU = "line", CircleL = "line"),
      colors = list(Criteria = "#0A6EB4", CircleU = "#9aa5b1", CircleL = "#9aa5b1"),
      labels = list(show = TRUE, format = list(Criteria = htmlwidgets::JS(sprintf(
        "function(v, id, i){ var n = %s; return n[i] !== undefined ? n[i] : ''; }", jsonlite::toJSON(as.character(names))))),
        colors = "#1f2a37")),
    axis = list(x = list(min = -1.1, max = 1.1, tick = list(values = c(-1, -0.5, 0, 0.5, 1), fit = FALSE),
                         label = list(text = xlab, position = "outer-center"), padding = list(left = 0, right = 0)),
                y = list(min = -1.1, max = 1.1, tick = list(values = c(-1, -0.5, 0, 0.5, 1)),
                         label = list(text = ylab, position = "outer-middle"), padding = list(top = 0, bottom = 0))),
    grid = list(x = list(lines = list(list(value = 0))), y = list(lines = list(list(value = 0)))),
    point = list(r = 5),
    legend = list(show = FALSE),
    tooltip = list(format = list(
      title = htmlwidgets::JS(sprintf("function(x, i){ var n = %s; return n[i] !== undefined ? n[i] : ''; }", jsonlite::toJSON(as.character(names)))),
      value = htmlwidgets::JS("function(v){ return v.toFixed(2); }"))))
  billboarder::bb_add_style(bb, ".bb-circles-CircleU, .bb-circles-CircleL" = "display: none;")
}

#' Report charts of a vulnerability ranking: the score distribution with the
#' threshold, the households on the first two components (coloured by profile
#' or selection) and the share selected by area
#' @noRd
ranking_report_plots <- function(score, threshold, map = NULL, cov_area = NULL, lang = "en") {
  tr <- function(x) i18n_lookup(x, lang)
  out <- list()
  s <- score[!is.na(score)]
  if (length(s)) {
    br <- unique(pretty(range(s), n = 20)); if (length(br) < 2) br <- c(min(s) - .5, min(s) + .5)
    cnt <- as.integer(table(cut(s, br, include.lowest = TRUE)))
    d <- data.frame(bin = format(br[-1], trim = TRUE, drop0trailing = TRUE), n = cnt)
    names(d)[2] <- tr("Households")
    thr_bin <- findInterval(threshold %||% 0, br, rightmost.closed = TRUE)
    out$rank_hist <- rp_base(320) |>
      billboarder::bb_barchart(d) |>
      rp_colors(stats::setNames(rp_cols$incl, names(d)[2])) |>
      billboarder::bb_bar(width = list(ratio = 0.92)) |>
      billboarder::bb_legend(show = FALSE) |>
      billboarder::bb_x_axis(tick = list(culling = list(max = 10), multiline = FALSE),
                             label = rp_axis_label(tr("Score (upper bound of the bin)"), rotated = TRUE)) |>
      billboarder::bb_x_grid(lines = list(list(value = max(0, thr_bin - 0.5), text = tr("Threshold"))))
  }
  if (!is.null(map) && nrow(map)) out$households_map <- rp_group_scatter(map$x, map$y, map$group, map$xlab[1], map$ylab[1])
  if (!is.null(cov_area) && nrow(cov_area)) {
    d <- data.frame(area = cov_area$area, v = round(100 * cov_area$share, 1))
    names(d)[2] <- tr("% selected")
    out$cov_area <- rp_columns(d, stats::setNames(rp_cols$incl, names(d)[2]), tr("% selected"), stacked = FALSE)
  }
  out
}

#' Scatter of points coloured by group (households map of the ranking report)
#' @noRd
rp_group_scatter <- function(x, y, group, xlab = "", ylab = "") {
  lv <- sort(unique(group))
  pal <- if (all(lv %in% c("Selected", "Not selected"))) c(Selected = "#0A6EB4", `Not selected` = "#b8c4d0")[lv]
         else stats::setNames(rep_len(c("#c5192d", "#f7b825", "#0A6EB4", "#26bde2", "#3f7e44", "#8a96a3", "#5b6b7c", "#b8c4d0"), length(lv)), lv)
  xs <- stats::setNames(as.list(paste0("x_", seq_along(lv))), lv)
  cols <- unlist(lapply(seq_along(lv), function(i) {
    k <- group == lv[i]
    list(c(list(paste0("x_", i)), as.list(round(x[k], 3))), c(list(lv[i]), as.list(round(y[k], 3))))
  }), recursive = FALSE)
  bb <- billboarder::billboarder(width = "100%", height = 420)
  bb$x$bb_opts <- list(
    data = list(xs = xs, columns = cols, type = "scatter", colors = as.list(pal)),
    axis = list(x = list(label = list(text = xlab, position = "outer-center"), tick = list(fit = FALSE, format = htmlwidgets::JS("function(v){ return v.toFixed(1); }"))),
                y = list(label = list(text = ylab, position = "outer-middle"))),
    point = list(r = 2.5), legend = list(position = "bottom"),
    tooltip = list(format = list(title = htmlwidgets::JS("function(){ return ''; }"))))
  billboarder::bb_add_style(bb, ".bb-circle" = "opacity: 0.55;")
}

#' Scores in bins, as a share of each group (for the mirrored distribution)
#' @return data.frame(lower, upper, mid, width, vuln, not, n_vuln, n_not): the
#'   % of vulnerable / not-vulnerable households in each bin.
#' @noRd
score_bins <- function(score, vulnerable, n = 20) {
  br <- unique(pretty(range(score), n = n))
  if (length(br) < 2) br <- c(min(score) - 0.5, min(score) + 0.5)
  cnt <- function(x) as.integer(table(cut(x, br, include.lowest = TRUE)))
  nv <- cnt(score[vulnerable]); nn <- cnt(score[!vulnerable])
  data.frame(lower = utils::head(br, -1), upper = br[-1], mid = (utils::head(br, -1) + br[-1]) / 2, width = diff(br),
             vuln = 100 * nv / max(1, sum(vulnerable)), not = 100 * nn / max(1, sum(!vulnerable)),
             n_vuln = nv, n_not = nn)
}

#' @noRd
design_report_extra_plots <- function(df = NULL, criteria = NULL, vulnerable = NULL,
                                      model_rocs = NULL, score = NULL,
                                      threshold = NULL, detail = NULL, eligible = NULL,
                                      directions = NULL, lang = "en") {
  tr <- function(x) i18n_lookup(x, lang)
  out <- list()

  # Prevalence of each kept criterion among vulnerable and not-vulnerable households
  if (!is.null(df) && length(criteria) && length(vulnerable) == nrow(df)) {
    p <- criteria_profile(df, criteria, as.integer(vulnerable))
    p <- p[order(p$gap, decreasing = TRUE), , drop = FALSE]
    d <- data.frame(criterion = p$criterion, a = round(100 * p$prev_vuln, 1), b = round(100 * p$prev_not, 1))
    names(d)[2:3] <- tr(c("Vulnerable", "Not vulnerable"))
    # every criterion, as a radar (a spoke each)
    out$prevalence <- if (nrow(d) >= 3) rp_radar(d, rp_grp(tr)) else rp_hbars(d, rp_grp(tr), tr("% households meeting it"))
  }

  # ROC curve of every model on the held-out households
  if (length(model_rocs)) {
    keep <- Filter(function(cur) !is.null(cur) && nrow(cur) > 1, model_rocs)
    if (length(keep)) {
      d <- data.frame(fpr = rp_roc_grid, lapply(keep, rp_roc_on_grid), check.names = FALSE)
      names(d)[-1] <- tr(names(keep))
      d[[tr("Random")]] <- rp_roc_grid
      cols <- stats::setNames(c(rep_len(rp_cols$models, length(keep)), "#9aa5b1"), names(d)[-1])
      out$comparison_roc <- rp_roc_chart(d, cols, tr)
    }
  }

  # Score by vulnerability: box (quartiles), whiskers (1.5 IQR) and median.
  if (length(score) && length(vulnerable) == length(score)) {
    grp <- tr(c("Vulnerable", "Not vulnerable"))
    st <- lapply(list(score[vulnerable %in% TRUE], score[vulnerable %in% FALSE]), function(s) {
      s <- s[!is.na(s)]
      if (!length(s)) return(c(NA, NA, NA, NA, NA))
      q <- stats::quantile(s, c(.25, .5, .75), names = FALSE)
      iqr <- q[3] - q[1]
      c(q[1], max(s[s <= q[3] + 1.5 * iqr]), min(s[s >= q[1] - 1.5 * iqr]), q[3], q[2])
    })
    ohlc <- lapply(st, function(v) round(v[1:4], 3))
    med <- round(vapply(st, `[`, numeric(1), 5), 3)
    bb <- rp_base(340) |>
      billboarder::bb_data(x = "x", columns = list(c("x", grp), c(tr("Quartiles"), ohlc),
                                                   c(tr("Median"), as.list(med))),
                           types = stats::setNames(list("candlestick", "scatter"), tr(c("Quartiles", "Median"))),
                           colors = stats::setNames(list(rp_cols$incl, "#1f2a37"), tr(c("Quartiles", "Median")))) |>
      billboarder::bb_x_axis(type = "category") |>
      billboarder::bb_y_axis(label = rp_axis_label(tr("Scorecard score"))) |>
      billboarder::bb_point(r = 5) |>
      billboarder::bb_y_grid(lines = list(list(value = threshold %||% 0, text = tr("Threshold"))))
    bb$x$bb_opts$candlestick <- list(width = list(ratio = 0.35), color = list(down = rp_cols$excl))
    out$box <- bb
  }

  # What drives the score, criteria met, coverage by criterion
  if (!is.null(detail) && ncol(detail)) {
    tot <- vapply(detail, function(v) sum(abs(v), na.rm = TRUE), numeric(1))
    share <- round(100 * tot / max(sum(tot), 1e-9), 1)
    # The criteria that carry the most points, for the per-criterion charts.
    top_cols <- names(detail)[rp_top(tot)]
    dir <- unname(directions[names(detail)] %||% rep("inclusion", length(tot)))
    dir[is.na(dir)] <- "inclusion"
    o <- order(share, decreasing = TRUE)
    d <- data.frame(criterion = names(detail)[o],
                    a = ifelse(dir[o] == "exclusion", 0, share[o]),
                    b = ifelse(dir[o] == "exclusion", share[o], 0))
    names(d)[2:3] <- rp_cap(tr(c("inclusion", "exclusion")))
    d[[3]] <- -d[[3]]   # exclusion below the axis, as in the points
    out$drivers <- rp_lollipop(d, c(rp_cols$incl, rp_cols$excl), tr("Share of points (%)"))

    if (length(eligible) == nrow(detail)) {
      met <- rowSums(detail != 0, na.rm = TRUE)
      lv <- sort(unique(met))
      d <- data.frame(met = as.character(lv),
                      a = vapply(lv, function(k) sum(met == k & eligible %in% TRUE), numeric(1)),
                      b = vapply(lv, function(k) sum(met == k & eligible %in% FALSE), numeric(1)))
      names(d)[2:3] <- tr(c("Eligible", "Not eligible"))
      out$met <- rp_base(340) |>
        billboarder::bb_barchart(d) |>
        rp_colors(stats::setNames(c(rp_cols$elig, rp_cols$notelig), names(d)[2:3])) |>
        billboarder::bb_x_axis(label = rp_axis_label(tr("Criteria met by the household"), rotated = TRUE)) |>
        billboarder::bb_y_axis(label = rp_axis_label(tr("Households")))

      if (length(vulnerable) == nrow(detail)) {
        pct <- function(m, v) { x <- eligible[m & vulnerable %in% v]; if (length(x)) round(100 * mean(x), 1) else NA }
        all_cols <- names(detail)[order(tot, decreasing = TRUE)]
        d <- data.frame(criterion = all_cols,
                        a = vapply(all_cols, function(cl) pct(detail[[cl]] != 0, TRUE), numeric(1)),
                        b = vapply(all_cols, function(cl) pct(detail[[cl]] != 0, FALSE), numeric(1)))
        d <- d[order(d$a, decreasing = TRUE), , drop = FALSE]
        names(d)[2:3] <- tr(c("Vulnerable", "Not vulnerable"))
        # every criterion, as a radar (a spoke each, 0 to 100%)
        out$coverage <- if (nrow(d) >= 3) rp_radar(d, rp_grp(tr)) else
          rp_hbars(d, rp_grp(tr), tr("% of holders eligible")) |>
            billboarder::bb_y_axis(min = 0, max = 100, padding = list(top = 0, bottom = 0),
                                   label = rp_axis_label(tr("% of holders eligible"), rotated = TRUE))
      }
    }
  }
  out
}

# Donut of shares (category, n): the profile charts of the selection report.
rp_donut <- function(d, height = 240) {
  cols <- stats::setNames(rep_len(c("#0A6EB4", "#f7b825", "#26bde2", "#3f7e44", "#c5192d", "#8a96a3"), nrow(d)), d$category)
  # 80% hollow: the ring is a fifth of the radius; the largest share is
  # written in the middle.
  radius <- (height - 50) / 2
  top <- which.max(d$n)
  mid <- sprintf("%.0f%%\n%s", 100 * d$n[top] / sum(d$n), substr(as.character(d$category[top]), 1, 22))
  rp_base(height) |>
    billboarder::bb_donutchart(data.frame(category = d$category, n = d$n)) |>
    rp_colors(cols) |>
    billboarder::bb_donut(label = list(show = FALSE), width = base::max(8, round(0.2 * radius)), title = mid) |>
    billboarder::bb_legend(position = "bottom") |>
    billboarder::bb_add_style(".bb-chart-arcs-title" = "font-size: 20px; font-weight: 700; fill: #1f2a37;",
                              ".bb-chart-arcs-title tspan + tspan" = "font-size: 11px; font-weight: 400; fill: #5b6b7c;")
}

# Category shares as charts: donuts for the (at most three) variables with
# three categories or fewer, side by side on one row; horizontal bars of the
# share of households for everything else.
# `vars`: named list of data.frame(category, n) with attr "label".
# Returns list(plots, captions, rows): rows are the @@FIG@@ lines to add.
rp_share_charts <- function(vars, max_donuts = 3, lang = "en") {
  if (!length(vars)) return(list(plots = list(), captions = character(0), rows = character(0)))
  k <- vapply(vars, nrow, integer(1))
  donut <- utils::head(names(vars)[k <= 3], max_donuts)
  bars <- setdiff(names(vars), donut)
  lab <- i18n_lookup("Share of households (%)", lang)
  plots <- list()
  for (nm in donut) plots[[nm]] <- rp_donut(vars[[nm]])
  for (nm in bars) {
    v <- vars[[nm]]
    d <- data.frame(category = v$category, share = round(100 * v$n / sum(v$n), 1))
    names(d)[2] <- lab
    plots[[nm]] <- rp_hbars(d, stats::setNames("#0A6EB4", lab), lab) |> billboarder::bb_legend(show = FALSE)
  }
  fig <- function(keys) c(sprintf("@@FIG:%s@@", paste(keys, collapse = ",")), "")
  # The donuts' row is filled up to three with bars, so a lone donut does not
  # take the whole width.
  first <- if (length(donut)) c(donut, utils::head(bars, 3 - length(donut))) else character(0)
  bars <- setdiff(bars, first)
  rows <- c(if (length(first)) fig(first),
            unlist(lapply(split(bars, ceiling(seq_along(bars) / 2)), fig), use.names = FALSE))
  list(plots = plots, rows = rows,
       captions = stats::setNames(vapply(vars, function(v) attr(v, "label") %||% "", character(1)), names(vars)))
}

# 100% stacked columns: vulnerable / not vulnerable per group, with a dotted
# line at the overall share vulnerable (Vulnerability Framework by area).
# Stacks in the data's order (billboard.js otherwise sorts them by size)
rp_keep_order <- function(bb) { bb$x$bb_opts$data$order <- htmlwidgets::JS("null"); bb }

rp_stacked_share <- function(group, share, overall_pct, lang = "en") {
  tr <- function(x) i18n_lookup(x, lang)
  lab <- tr(c("Vulnerable", "Not vulnerable"))
  d <- data.frame(group = group, a = round(100 * share, 1), b = round(100 * (1 - share), 1))
  names(d)[2:3] <- lab
  many <- length(group) > 8
  # every area, labels horizontal or vertical (never slanted), the share
  # printed on each part of the column; past ~20 areas the chart keeps 42 px
  # per area and scrolls sideways rather than shrinking the columns
  bb0 <- rp_base(if (many) 420 else 340)
  if (length(group) > 20) bb0$width <- paste0(42 * length(group) + 80, "px")
  bb0 |>
    billboarder::bb_barchart(d, stacked = TRUE) |>
    billboarder::bb_data(labels = list(format = htmlwidgets::JS("function(v){ return v >= 6 ? Math.round(v) + '%' : ''; }"),
                                       centered = TRUE, colors = "#ffffff")) |>
    rp_colors(stats::setNames(c(rp_cols$vuln, rp_cols$not), lab)) |>
    billboarder::bb_bar(width = list(ratio = 0.6)) |>
    billboarder::bb_x_axis(tick = list(multiline = FALSE, rotate = if (many) 90 else 0, autorotate = FALSE, culling = FALSE),
                           height = if (many) 110 else NULL) |>
    billboarder::bb_y_axis(max = 100, min = 0, padding = list(top = 0, bottom = 0),
                           label = rp_axis_label(tr("Households (%)"))) |>
    billboarder::bb_y_grid(lines = list(list(value = round(overall_pct, 1), class = "rp-avg",
                                             text = sprintf("%s: %.0f%%", tr("All areas"), overall_pct)))) |>
    rp_keep_order() |>
    billboarder::bb_add_style(".rp-avg line" = "stroke: #1f2a37; stroke-dasharray: 4 4; stroke-width: 2px;")
}
