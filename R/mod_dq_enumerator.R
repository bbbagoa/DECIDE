#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_enumerator_ui <- function(ns) {
          bslib::nav_panel(
            title = "Enumerator Performance",
            icon = bsicons::bs_icon("person-badge"),
            bslib::layout_columns(
              class = "mt-3", col_widths = c(3, 3, 3, 3),
              bslib::value_box(title = "Active enumerators", value = textOutput(ns("enum_active")),
                               showcase = bsicons::bs_icon("people"), theme = "primary"),
              bslib::value_box(title = "Interviews per enumerator", value = textOutput(ns("enum_avg_int")),
                               showcase = bsicons::bs_icon("person-lines-fill"), theme = "secondary"),
              bslib::value_box(title = "Total interviews", value = textOutput(ns("enum_total_int")),
                               showcase = bsicons::bs_icon("clipboard-check"), theme = "info"),
              bslib::value_box(title = "Flagged for review", value = textOutput(ns("enum_flagged")),
                               showcase = bsicons::bs_icon("flag"), theme = "danger")
            ),
            bslib::navset_underline(
              bslib::nav_panel(
                title = tagList(bsicons::bs_icon("bar-chart"), " Workload and speed"),
                bslib::layout_columns(
                  class = "mt-3", col_widths = c(6, 6),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Interviews by enumerator (top 20)"),
                plotly::plotlyOutput(ns("enum_interviews_plot"), height = "320px")
              ),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Average interview duration (top 20)"),
                plotly::plotlyOutput(ns("enum_duration_plot"), height = "320px")
              )
                )
              ),
              bslib::nav_panel(
                title = tagList(bsicons::bs_icon("table"), " Performance table"),
                bslib::layout_columns(
                  class = "mt-3", col_widths = c(7, 5),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Enumerator metrics"),
                DT::DTOutput(ns("enum_metrics_table"), fill = FALSE)
              ),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Missingness by enumerator (top 20)"),
                plotly::plotlyOutput(ns("enum_missingness_plot"), height = "360px")
              )
                )
              )
            )
          )
}

#' Data Quality sub-tab server
#' Shares the parent module input/output/session/ns namespace.
#' @param input,output,session,ns parent module handles
#' @param core list with dq_filtered_data, uploaded_df, user_setup, modification_log
#' @import shiny
#' @noRd
dq_enumerator_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  # Enumerator Performance
  # ------------------------------------------------------------

  enum_metrics <- reactive({
    req(dq_filtered_data(), user_setup$enumerator_id)
    df <- dq_filtered_data()
    enum_col <- user_setup$enumerator_id
    w <- get_weights(df, user_setup)

    hh_size_col <- user_setup$hh_size
    size_num <- if (shiny::isTruthy(hh_size_col) && hh_size_col %in% names(df)) {
      suppressWarnings(as.numeric(as.character(df[[hh_size_col]])))
    } else {
      rep(NA_real_, nrow(df))
    }

    if (all(c("start", "end") %in% names(df))) {
      t_start <- lubridate::as_datetime(df[["start"]])
      t_end <- lubridate::as_datetime(df[["end"]])
    } else if (all(c("starttime", "endtime") %in% names(df))) {
      t_start <- lubridate::as_datetime(df[["starttime"]])
      t_end <- lubridate::as_datetime(df[["endtime"]])
    } else {
      t_start <- t_end <- rep(NA_real_, nrow(df))
    }
    durations <- as.numeric(difftime(t_end, t_start, units = "mins"))
    valid_dur <- !is.na(durations) & durations > 5 & durations < 180

    miss_cols <- setdiff(names(df), c(enum_col, user_setup$weight))
    row_missing <- rowMeans(is.na(df[, miss_cols, drop = FALSE]))

    data.frame(
      enumerator_id = df[[enum_col]],
      w = w,
      valid_dur = valid_dur,
      duration = durations,
      size = size_num,
      row_missing = row_missing,
      stringsAsFactors = FALSE
    ) |>
      dplyr::filter(!is.na(.data$enumerator_id), .data$enumerator_id != "", .data$w > 0) |>
      dplyr::group_by(.data$enumerator_id) |>
      dplyr::summarise(
        interviews = sum(.data$w, na.rm = TRUE),
        avg_duration = ifelse(
          sum(.data$valid_dur) == 0,
          NA_real_,
          sum(.data$duration[.data$valid_dur] * .data$w[.data$valid_dur], na.rm = TRUE) /
            sum(.data$w[.data$valid_dur], na.rm = TRUE)
        ),
        missingness_rate = sum(.data$row_missing * .data$w, na.rm = TRUE) / sum(.data$w, na.rm = TRUE),
        avg_hh_size = ifelse(
          sum(!is.na(.data$size)) == 0,
          NA_real_,
          sum(.data$size[!is.na(.data$size)] * .data$w[!is.na(.data$size)], na.rm = TRUE) /
            sum(.data$w[!is.na(.data$size)], na.rm = TRUE)
        ),
        .groups = "drop"
      ) |>
      dplyr::arrange(dplyr::desc(.data$interviews)) |>
      # --- D1: flag poor performers against cohort thresholds.
      # An enumerator is flagged "Review" when their mean interview duration or
      # missingness rate is an outlier among peers. Durations outside the IQR
      # band suggest rushed or inefficient work; missingness above the cohort
      # mean + 2 SD suggests sloppy capture. Robust to extreme enumerators.
      dplyr::mutate(flag = {
        dur_ok <- !is.na(.data$avg_duration)
        dur_out <- rep(FALSE, dplyr::n())
        if (sum(dur_ok) >= 4) {
          qs <- stats::quantile(.data$avg_duration[dur_ok], c(0.25, 0.75))
          iqr <- qs[2] - qs[1]
          dur_out <- dur_ok & (.data$avg_duration < (qs[1] - 1.5 * iqr) |
                                 .data$avg_duration > (qs[2] + 1.5 * iqr))
        }
        miss_mean <- stats::weighted.mean(.data$missingness_rate, .data$interviews, na.rm = TRUE)
        miss_sd <- stats::sd(.data$missingness_rate, na.rm = TRUE)
        miss_high <- !is.na(miss_sd) && miss_sd > 0 &
          .data$missingness_rate > (miss_mean + 2 * miss_sd)
        ifelse(dur_out | miss_high, "Review", "OK")
      })
  })

  output$enum_active <- renderText({
    req(enum_metrics())
    format(nrow(enum_metrics()), big.mark = ",")
  })

  output$enum_avg_int <- renderText({
    req(dq_filtered_data(), enum_metrics())
    n_active <- nrow(enum_metrics())
    if (n_active == 0) return("0")
    avg <- weighted_count(dq_filtered_data(), user_setup) / n_active
    format(round(avg, 1), big.mark = ",")
  })

  output$enum_interviews_plot <- render_wfp_plotly({
    req(dq_filtered_data(), user_setup$enumerator_id)
    df <- dq_filtered_data()

    tab <- weighted_table(df, user_setup$enumerator_id, user_setup) |>
      dplyr::slice_max(.data$n, n = 20) |>
      dplyr::mutate(value = substr(.data$value, 1, 20)) |>
      dplyr::arrange(.data$n)

    plotly::plot_ly(
      tab,
      x = ~n,
      y = ~reorder(value, n),
      type = "bar",
      marker = list(color = "#0A6EB4"),
      hovertemplate = "%{y}: %{x:,.0f}<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = "", gridcolor = "rgba(128,128,128,0.2)"),
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)',
        margin = list(t = 40, b = 40, l = 120, r = 20)
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  output$enum_total_int <- renderText({
    req(enum_metrics())
    format(round(sum(enum_metrics()$interviews, na.rm = TRUE)), big.mark = ",")
  })

  output$enum_flagged <- renderText({
    m <- enum_metrics()
    req(m)
    format(sum(m$flag == "Review", na.rm = TRUE), big.mark = ",")
  })

  output$enum_duration_plot <- render_wfp_plotly({
    req(enum_metrics())
    tab <- enum_metrics() |>
      dplyr::filter(!is.na(.data$avg_duration)) |>
      dplyr::slice_max(.data$avg_duration, n = 20) |>
      dplyr::mutate(enumerator_id = substr(as.character(.data$enumerator_id), 1, 20)) |>
      dplyr::arrange(.data$avg_duration)

    if (nrow(tab) == 0) {
      return(plotly::plot_ly() |> plotly::layout(
        title = "No duration data available",
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      ))
    }

    plotly::plot_ly(
      tab,
      x = ~avg_duration,
      y = ~reorder(enumerator_id, avg_duration),
      type = "bar",
      marker = list(color = "#0A6EB4"),
      hovertemplate = "%{y}: %{x:.1f} min<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Minutes", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = ""),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 120)
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  output$enum_missingness_plot <- render_wfp_plotly({
    req(enum_metrics())
    tab <- enum_metrics() |>
      dplyr::slice_max(.data$missingness_rate, n = 20) |>
      dplyr::mutate(enumerator_id = substr(as.character(.data$enumerator_id), 1, 20)) |>
      dplyr::arrange(.data$missingness_rate)

    if (nrow(tab) == 0) {
      return(plotly::plot_ly() |> plotly::layout(
        title = "No missingness data available",
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      ))
    }

    plotly::plot_ly(
      tab,
      x = ~missingness_rate * 100,
      y = ~reorder(enumerator_id, missingness_rate),
      type = "bar",
      marker = list(color = "#c5192d"),
      hovertemplate = "%{y}: %{x:.1f}%<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Missingness (%)", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = ""),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 120)
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  output$enum_metrics_table <- DT::renderDT({
    req(enum_metrics())
    m <- enum_metrics()
    DT::datatable(
      m,
      class = "compact stripe hover",
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        searching = FALSE,
        lengthChange = FALSE,
        dom = "tp",
        ordering = TRUE,
        columnDefs = list(list(targets = which(colnames(m) == "flag") - 1L, searchable = FALSE))
      ),
      rownames = FALSE
    ) |>
      DT::formatRound(c("avg_duration", "avg_hh_size"), digits = 1) |>
      DT::formatPercentage("missingness_rate", digits = 1) |>
      DT::formatCurrency("interviews", currency = "", interval = 3, mark = ",", digits = 0) |>
      DT::formatStyle(
        columns = "missingness_rate",
        background = DT::styleColorBar(c(0, 1), "#f7b825"),
        backgroundSize = "100% 80%",
        backgroundRepeat = "no-repeat",
        backgroundPosition = "center"
      ) |>
      # Flag column: green for OK, red for Review
      DT::formatStyle(
        "flag",
        backgroundColor = DT::styleEqual(c("OK", "Review"), c("#3f7e44", "#c5192d")),
        color = "#FFFFFF", fontWeight = "bold"
      )
  })
}
