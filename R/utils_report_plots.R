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
    n_all <- nrow(weights)
    weights <- weights[rp_top(weights$weight), , drop = FALSE]
    signed <- ifelse(weights$direction == "exclusion", -weights$weight, weights$weight)
    o <- order(signed, decreasing = TRUE)
    d <- data.frame(criterion = weights$criterion[o],
                    a = round(ifelse(weights$direction[o] == "exclusion", 0, signed[o]), 3),
                    b = round(ifelse(weights$direction[o] == "exclusion", signed[o], 0), 3))
    names(d)[2:3] <- rp_cap(tr(c("inclusion", "exclusion")))
    out$weights <- rp_of(rp_hbars(d, stats::setNames(c(rp_cols$incl, rp_cols$excl), names(d)[2:3]),
                                  tr("Points added (+) or subtracted (-)"), stacked = TRUE), nrow(d), n_all)
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

  # Score distribution by outcome, threshold marked.
  if (!is.null(score) && length(score) && length(vulnerable) == length(score)) {
    ok <- !is.na(score) & !is.na(vulnerable)
    s <- score[ok]; v <- vulnerable[ok]
    br <- unique(pretty(range(s), n = 20))
    if (length(br) < 2) br <- c(min(s), min(s) + 1)
    cnt <- function(x) as.integer(table(cut(x, br, include.lowest = TRUE)))
    d <- data.frame(bin = sprintf("%s", format(br[-1], trim = TRUE, drop0trailing = TRUE)),
                    a = cnt(s[v]), b = cnt(s[!v]))
    names(d)[2:3] <- tr(c("Vulnerable", "Not vulnerable"))
    thr_bin <- findInterval(threshold %||% 0, br, rightmost.closed = TRUE)
    out$scores <- rp_base(340) |>
      billboarder::bb_barchart(d) |>
      rp_colors(rp_grp(tr)) |>
      billboarder::bb_bar(width = list(ratio = 0.9)) |>
      billboarder::bb_x_axis(tick = list(culling = list(max = 10), multiline = FALSE),
                             label = rp_axis_label(tr("Score (upper bound of the bin)"), rotated = TRUE)) |>
      billboarder::bb_y_axis(label = rp_axis_label(tr("Households"))) |>
      billboarder::bb_x_grid(lines = list(list(value = max(0, thr_bin - 0.5), text = tr("Threshold"))))
  }
  out
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
    n_all <- nrow(p)
    # The most relevant: the largest gap between vulnerable and not.
    p <- p[rp_top(p$gap), , drop = FALSE]
    p <- p[order(p$gap, decreasing = TRUE), , drop = FALSE]
    d <- data.frame(criterion = p$criterion, a = round(100 * p$prev_vuln, 1), b = round(100 * p$prev_not, 1))
    names(d)[2:3] <- tr(c("Vulnerable", "Not vulnerable"))
    out$prevalence <- rp_of(rp_hbars(d, rp_grp(tr), tr("% households meeting it")), nrow(d), n_all)
    if (nrow(p) > 1) out$correlation <- rp_of(rp_corr_table(criteria_cor(df, p$criterion)), nrow(p), n_all)
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
    o <- o[names(detail)[o] %in% top_cols]
    d <- data.frame(criterion = names(detail)[o],
                    a = ifelse(dir[o] == "exclusion", 0, share[o]),
                    b = ifelse(dir[o] == "exclusion", share[o], 0))
    names(d)[2:3] <- rp_cap(tr(c("inclusion", "exclusion")))
    out$drivers <- rp_of(rp_hbars(d, stats::setNames(c(rp_cols$incl, rp_cols$excl), names(d)[2:3]),
                                  tr("Share of points (%)"), stacked = TRUE), nrow(d), ncol(detail))

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
        d <- data.frame(criterion = top_cols,
                        a = vapply(top_cols, function(cl) pct(detail[[cl]] != 0, TRUE), numeric(1)),
                        b = vapply(top_cols, function(cl) pct(detail[[cl]] != 0, FALSE), numeric(1)))
        d <- d[order(d$a, decreasing = TRUE), , drop = FALSE]
        names(d)[2:3] <- tr(c("Vulnerable", "Not vulnerable"))
        out$coverage <- rp_hbars(d, rp_grp(tr), tr("% of holders eligible")) |>
          billboarder::bb_y_axis(min = 0, max = 100, padding = list(top = 0, bottom = 0),
                                 label = rp_axis_label(tr("% of holders eligible"), rotated = TRUE))
      }
    }
  }
  out
}

# Lower-triangle correlation table, cells shaded from red (-1) to blue (+1).
rp_corr_table <- function(cm) {
  nm <- colnames(cm)
  shade <- function(r) {
    if (is.na(r)) return("background:#fff")
    a <- min(1, abs(r))
    col <- if (r >= 0) c(10, 110, 180) else c(197, 25, 45)
    sprintf("background:rgba(%d,%d,%d,%.2f);color:%s", col[1], col[2], col[3], 0.85 * a,
            if (a > 0.55) "#fff" else "#1f2a37")
  }
  rows <- lapply(seq_along(nm)[-1], function(i) htmltools::tags$tr(
    htmltools::tags$th(class = "rh", nm[i]),
    lapply(seq_len(i - 1), function(j) htmltools::tags$td(style = shade(cm[i, j]), sprintf("%.2f", cm[i, j]))),
    lapply(seq_len(length(nm) - i), function(j) htmltools::tags$td(class = "blank"))))
  htmltools::tags$div(class = "corr-wrap", htmltools::tags$table(
    class = "corr",
    htmltools::tags$thead(htmltools::tags$tr(htmltools::tags$th(""),
                                             lapply(nm[-length(nm)], function(x) htmltools::tags$th(htmltools::tags$span(x))))),
    htmltools::tags$tbody(rows)))
}

# Donut of shares (category, n): the profile charts of the selection report.
rp_donut <- function(d, height = 240) {
  cols <- stats::setNames(rep_len(c("#0A6EB4", "#f7b825", "#26bde2", "#3f7e44", "#c5192d", "#8a96a3"), nrow(d)), d$category)
  rp_base(height) |>
    billboarder::bb_donutchart(data.frame(category = d$category, n = d$n)) |>
    rp_colors(cols) |>
    billboarder::bb_donut(label = list(format = htmlwidgets::JS("function(v, r) { return (r * 100).toFixed(0) + '%'; }")),
                          width = 46) |>
    billboarder::bb_legend(position = "bottom")
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
rp_stacked_share <- function(group, share, overall_pct, lang = "en") {
  tr <- function(x) i18n_lookup(x, lang)
  lab <- tr(c("Vulnerable", "Not vulnerable"))
  d <- data.frame(group = group, a = round(100 * share, 1), b = round(100 * (1 - share), 1))
  names(d)[2:3] <- lab
  rp_base(340) |>
    billboarder::bb_barchart(d, stacked = TRUE) |>
    rp_colors(stats::setNames(c(rp_cols$vuln, rp_cols$not), lab)) |>
    billboarder::bb_bar(width = list(ratio = 0.6)) |>
    billboarder::bb_x_axis(tick = list(multiline = FALSE, rotate = if (length(group) > 8) -35 else 0)) |>
    billboarder::bb_y_axis(max = 100, min = 0, padding = list(top = 0, bottom = 0),
                           label = rp_axis_label(tr("Households (%)"))) |>
    billboarder::bb_y_grid(lines = list(list(value = round(overall_pct, 1), class = "rp-avg",
                                             text = sprintf("%s: %.0f%%", tr("All areas"), overall_pct)))) |>
    billboarder::bb_add_style(".rp-avg line" = "stroke: #1f2a37; stroke-dasharray: 4 4; stroke-width: 2px;")
}
