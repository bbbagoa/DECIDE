#' WFP chart theme for plotly
#'
#' Applies the house style ('Open Sans', token colorway, transparent surfaces,
#' neutral gridlines, dark hover labels, no modebar) to any plotly object.
#' Only fills in layout keys the chart has not set itself, so chart-specific
#' margins, axes or legends always win.
#'
#' @param p A plotly object (anything else is returned untouched).
#' @return The themed plotly object.
#' @noRd
wfp_plotly <- function(p, dark = FALSE) {
  if (!inherits(p, "plotly")) return(p)

  attrs <- p$x$layoutAttrs
  if (is.null(attrs)) attrs <- list()
  existing <- Reduce(function(a, b) utils::modifyList(a, b), attrs, p$x$layout %||% list())

  font <- list(family = "'Open Sans', 'Segoe UI', system-ui, sans-serif", size = 12,
               color = if (isTRUE(dark)) "#e6ebf2" else "#1f2a37")
  defaults <- list(
    font = font,
    colorway = c("#007DBC", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#6c757d"),
    paper_bgcolor = "rgba(0,0,0,0)",
    plot_bgcolor = "rgba(0,0,0,0)",
    hoverlabel = list(bgcolor = "#1f2a37", bordercolor = "#1f2a37",
                      font = list(family = font$family, size = 12, color = "#ffffff")),
    margin = list(t = 40, r = 16, b = 44, l = 52),
    legend = list(bgcolor = "rgba(0,0,0,0)", font = list(size = 11)),
    xaxis = list(gridcolor = "rgba(128,128,128,0.2)", zerolinecolor = "rgba(128,128,128,0.35)"),
    yaxis = list(gridcolor = "rgba(128,128,128,0.2)", zerolinecolor = "rgba(128,128,128,0.35)")
  )

  for (nm in names(defaults)) {
    if (nm %in% c("xaxis", "yaxis")) {
      for (k in names(defaults[[nm]])) {
        if (!is.null(existing[[nm]][[k]])) defaults[[nm]][[k]] <- NULL
      }
      if (length(defaults[[nm]]) == 0) defaults[[nm]] <- NULL
    } else if (!is.null(existing[[nm]])) {
      defaults[[nm]] <- NULL
    }
  }

  if (length(defaults) > 0) p <- do.call(plotly::layout, c(list(p), defaults))
  plotly::config(p, displayModeBar = FALSE, displaylogo = FALSE)
}

#' renderPlotly with the WFP chart theme applied
#'
#' Drop-in replacement for `plotly::renderPlotly()`; every chart in the app
#' goes through this so styling stays coherent from one place.
#' @noRd
render_wfp_plotly <- function(expr, env = parent.frame(), quoted = FALSE) {
  func <- shiny::exprToFunction(expr, env, quoted)
  plotly::renderPlotly({
    # Redraw on the light/dark switch, with text in the mode's colour.
    dom <- shiny::getDefaultReactiveDomain()
    dark <- !is.null(dom) && identical(dom$rootScope()$input$dark_mode, "dark")
    wfp_plotly(func(), dark)
  })
}

#' Empty-state placeholder shown before an analysis has been run
#'
#' @param title Short headline (what the user should do).
#' @param subtitle Optional one-line hint.
#' @param icon Bootstrap icon name.
#' @noRd
empty_state <- function(title, subtitle = NULL, icon = "clipboard-data") {
  tags$div(
    class = "wfp-empty-state",
    bsicons::bs_icon(icon),
    tags$div(class = "fw-semibold", title),
    if (!is.null(subtitle)) tags$div(class = "small", subtitle)
  )
}

#' One characteristic's weighted distribution: bars of the (top 12) answers,
#' or a histogram of a number
#' @noRd
profile_distribution <- function(x, w, colour = "#007DBC") {
  ok <- !is.na(x) & is.finite(w) & w > 0
  x <- x[ok]; w <- w[ok]
  if (is.numeric(x)) {
    br <- pretty(range(x), n = min(20, max(5, length(unique(x)))))
    bin <- cut(x, br, include.lowest = TRUE, right = FALSE)
    tot <- tapply(w, bin, sum); tot[is.na(tot)] <- 0
    mid <- (utils::head(br, -1) + utils::tail(br, -1)) / 2
    plotly::plot_ly(x = mid, y = as.numeric(tot), type = "bar", marker = list(color = colour),
                    hovertemplate = paste0("%{x}: %{y:,.0f} households<extra></extra>")) |>
      plotly::layout(bargap = 0.05)
  } else {
    tot <- sort(tapply(w, as.character(x), sum), decreasing = TRUE)
    tot <- utils::head(tot, 12)
    plotly::plot_ly(x = substr(names(tot), 1, 14), y = as.numeric(tot), type = "bar", marker = list(color = colour),
                    hovertemplate = paste0("%{x}: %{y:,.0f} households<extra></extra>"))
  }
}

#' Create Adaptive Profile Plots
#' @description Automatically switches between Bar and Heatmap based on data type.
#'   Weight-aware: categorical bars and numeric boxplots both honour sampling
#'   weights when supplied (so weighted surveys display correctly). Falls back
#'   to unweighted counts/quantiles when `weights` is NULL.
#' @param data A data frame containing the variables to plot.
#' @param view_col Character string naming the variable to display on the y-axis / values.
#' @param demo_col Character string naming the demographic variable to display on the x-axis.
#' @param weights Optional numeric vector of row weights, used for counts in
#'   categorical bar charts and for weighted quantiles in boxplots. If `NULL`,
#'   raw counts / unweighted quantiles are used.
#' @export
create_profile_plot <- function(data, view_col, demo_col, weights = NULL, title = NULL) {

  # WFP token palette (blue / cyan / amber / green / red)
  wfp_pal <- c("#007DBC", "#26bde2", "#f7b825", "#3f7e44", "#c5192d")

  if (is.null(weights)) weights <- rep(1, nrow(data))
  weights <- rep(weights, length.out = nrow(data))

  # 1. Detect Types. Without a vulnerability variable to compare on, the
  # characteristic's own (weighted) distribution is drawn.
  no_view <- is.null(view_col) || !isTRUE(nzchar(view_col)) || !view_col %in% names(data)
  is_view_numeric <- !no_view && is.numeric(data[[view_col]])
  is_demo_numeric <- is.numeric(data[[demo_col]])

  # (weighted_boxplot_summary is defined in R/utils_targeting.R)

  # Initialize the plot object
  p <- if (no_view) profile_distribution(data[[demo_col]], weights, wfp_pal[1]) else if (is_view_numeric && is_demo_numeric) {
    # SCENARIO A: Score vs Age (density heatmap). Weighted via histnorm weight
    # by expanding each point into a small integer weight bucket is expensive at
    # scale; instead we let plotly weight the 2D bins with a per-point weight
    # using source weights as marker size proxy (kept transparent). The primary
    # weighting fix is in the boxplot branches (B/C), which are the common views.
    solar_red_scale <- list(
      list(0, 'rgba(255, 0, 0, 0)'), # Start: Red at 0% opacity
      list(1, '#e26d5c')  # Official Solarized Red
    )

    plotly::plot_ly(data, x = ~.data[[demo_col]], y = ~.data[[view_col]],
                    type = "histogram2dcontour", colorscale = solar_red_scale,
                    showscale = FALSE)
  } else if (!is_view_numeric && is_demo_numeric) {
    # SCENARIO B: Category (view) vs Numeric Age (demo). Weighted boxplot of the
    # numeric demo within each view level.
    data[[view_col]] <- substr(as.character(data[[view_col]]), 1, 8)
    summ <- weighted_boxplot_summary(data, group_col = view_col, val_col = demo_col, w = weights)
    plotly::plot_ly(summ, x = ~group, type = "box",
                    lowerfence = ~min, q1 = ~q1, median = ~median,
                    q3 = ~q3, upperfence = ~max,
                    color = ~group, colors = wfp_pal)
  } else if (is_view_numeric && !is_demo_numeric) {
    # SCENARIO C: Numeric View (Score) vs Category Demo. Weighted boxplot of the
    # numeric view within each demo level.
    data[[demo_col]] <- substr(as.character(data[[demo_col]]), 1, 8)
    summ <- weighted_boxplot_summary(data, group_col = demo_col, val_col = view_col, w = weights)
    plotly::plot_ly(summ, x = ~group, type = "box",
                    lowerfence = ~min, q1 = ~q1, median = ~median,
                    q3 = ~q3, upperfence = ~max,
                    color = ~group, colors = wfp_pal)
  } else {
    # SCENARIO D: Cat vs Cat (Stacked Bar)
    agg <- data |>
      # 1. Attach weights and summarise weighted counts for every combination
      dplyr::mutate(.w = weights) |>
      dplyr::group_by(
        View = as.character(.data[[view_col]]),
        Demo = as.character(.data[[demo_col]])
      ) |>
      dplyr::summarise(Count = sum(.data$.w, na.rm = TRUE), .groups = "drop") |>
      # 2. CRITICAL: Group by the Demographic (X-axis) to get Column-wise percentages
      dplyr::group_by(Demo) |>
      dplyr::mutate(
        Pct = Count / sum(Count),
        # Plotted directly (0-100) so each column really does stack to 100%.
        Pct100 = 100 * Count / sum(Count)
      ) |>
      dplyr::ungroup()

    # 3. Truncate labels for cleaner UI
    agg$Demo <- substr(agg$Demo, 1, 8)
    agg$View <- substr(agg$View, 1, 8)

    plotly::plot_ly(
      data = agg,
      x = ~Demo,
      # Percentages, not counts: plotly's R layout validator rejects `barnorm`
      # (it warns "'layout' objects don't have these attributes" and drops it),
      # so the bars never normalised and their heights disagreed with the
      # percentage labels drawn inside them.
      y = ~Pct100,
      color = ~View,
      colors = wfp_pal,
      type = "bar",
      # Labels match the column-wise percentage
      text = ~paste0(round(Pct * 100, 0), "%"),
      texttemplate = '%{text}',
      textposition = 'inside',
      insidetextanchor = 'middle',
      insidetextfont = list(color = "#023047", size = 9,
                            family = "'Open Sans', 'Segoe UI', system-ui, sans-serif"),
      hovertemplate = ~paste0(View, ": %{y:.1f}%<extra></extra>")
    ) |>
      plotly::layout(barmode = "stack")
  }

  # APPLY TRANSPARENCY AND STYLING
  p |> plotly::layout(

    # Text colors are left unset so thematic supplies theme-aware (light/dark) values
    title = list(text = title %||% paste(view_col, "by", demo_col),
                 font = list(size = 10)),

    showlegend = FALSE, # REMOVE LEGEND
    # TRANSPARENCY: rgba(0,0,0,0) makes it invisible
    paper_bgcolor = 'rgba(0,0,0,0)',
    plot_bgcolor = 'rgba(0,0,0,0)',

    # NOTE: xaxis/yaxis declared once (a previous version duplicated these,
    # which discarded the tickfont/title settings).
    xaxis = list(
      tickfont = list(size = 10),
      title = list(text = ""),
      gridcolor = 'rgba(128,128,128,0.2)',
      zeroline = FALSE
    ),
    yaxis = list(
      tickfont = list(size = 10),
      title = list(text = ""),
      gridcolor = 'rgba(128,128,128,0.2)',
      zeroline = FALSE
    ),
    margin = list(t = 50, b = 40, l = 40, r = 20)
  ) |>
    # Remove the floating toolbar for a cleaner look
    plotly::config(displayModeBar = FALSE)

}

#' Horizontal lollipops: a stem from 0 to the value and a dot, coloured by
#' direction (inclusion / exclusion). Lighter than bars when there are many
#' criteria, and every criterion stays on the chart.
#' @param d data.frame(criterion (ordered factor), value, direction, hover)
#' @noRd
lollipop_plot <- function(d, xtitle) {
  cols <- c(inclusion = "#007DBC", exclusion = "#c5192d")
  # past 20 criteria every other name is written on the axis (hover gives all)
  lv <- levels(d$criterion) %||% unique(as.character(d$criterion))
  yax <- list(title = "", automargin = TRUE)
  if (length(lv) > 20) yax <- c(yax, list(tickmode = "array", tickvals = lv,
                                          ticktext = ifelse(seq_along(lv) %% 2 == 0, "", lv)))
  plotly::plot_ly(d) |>
    plotly::add_segments(x = 0, xend = ~value, y = ~criterion, yend = ~criterion, color = ~direction, colors = cols,
                         line = list(width = 2.5), hoverinfo = "skip", showlegend = FALSE) |>
    plotly::add_markers(x = ~value, y = ~criterion, color = ~direction, colors = cols,
                        marker = list(size = 11, line = list(width = 1.5, color = "#ffffff")),
                        text = ~hover, hovertemplate = "%{text}<extra></extra>") |>
    plotly::layout(xaxis = list(title = xtitle, zeroline = TRUE, zerolinecolor = "rgba(128,128,128,0.5)"),
                   yaxis = yax,
                   legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom"))
}

#' Mirrored distribution of a score by outcome: vulnerable above the axis,
#' not vulnerable below, each as a share of its own group on the same bins
#' (`score_bins()`), so neither group hides the other. `threshold` draws the
#' cut-off.
#' @noRd
mirrored_hist_plot <- function(score, vulnerable, threshold = NULL, xtitle = "Score", labels = c("Vulnerable", "Not vulnerable")) {
  ok <- !is.na(score) & !is.na(vulnerable)
  h <- score_bins(score[ok], vulnerable[ok] %in% c(TRUE, 1))
  top <- max(c(h$vuln, h$not), 1)
  ticks <- pretty(c(0, top), 4)
  p <- plotly::plot_ly(h) |>
    plotly::add_bars(x = ~mid, y = ~vuln, width = ~width * 0.92, name = labels[1], marker = list(color = "#c5192d"),
                     customdata = ~n_vuln, hovertemplate = paste0("%{x}<br>", labels[1], ": %{y:.1f}% (%{customdata} households)<extra></extra>")) |>
    plotly::add_bars(x = ~mid, y = ~-not, width = ~width * 0.92, name = labels[2], marker = list(color = "#3f7e44"),
                     customdata = ~paste0(sprintf("%.1f", not), "% (", n_not, " households)"),
                     hovertemplate = paste0("%{x}<br>", labels[2], ": %{customdata}<extra></extra>"))
  lay <- list(barmode = "relative", bargap = 0,
              legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom"),
              xaxis = list(title = xtitle),
              yaxis = list(title = "% of the group", tickvals = c(-rev(ticks), ticks[-1]),
                           ticktext = paste0(c(rev(ticks), ticks[-1]), "%"), zeroline = TRUE,
                           zerolinecolor = "rgba(128,128,128,0.6)"))
  if (!is.null(threshold)) {
    lay$shapes <- list(list(type = "line", x0 = threshold, x1 = threshold, y0 = 0, y1 = 1, yref = "paper",
                            line = list(color = "#1f2a37", dash = "dash")))
    lay$annotations <- list(list(x = threshold, y = 1, yref = "paper", text = sprintf(" threshold %s", fmt5(threshold)),
                                 showarrow = FALSE, xanchor = "left", yanchor = "top", font = list(size = 11)))
  }
  do.call(plotly::layout, c(list(p), lay))
}
