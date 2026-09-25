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
                title = tagList(bsicons::bs_icon("flag"), " Flagged enumerators"),
                tags$div(
                  class = "mt-3",
                  tags$div(
                    class = "d-flex flex-wrap align-items-center gap-2 mb-2",
                    uiOutput(ns("enum_rules"), class = "small text-muted flex-grow-1"),
                    downloadButton(ns("enum_flag_download"), "Export flagged", class = "btn-outline-secondary btn-sm")),
                  uiOutput(ns("enum_flagged_ui"))
                )
              ),
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
      as_number(df[[hh_size_col]])
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

    m <- data.frame(
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
      dplyr::arrange(dplyr::desc(.data$interviews))

    # Busiest day per enumerator, when a date is mapped.
    date_col <- user_setup$date
    per_day <- NULL
    if (shiny::isTruthy(date_col) && date_col %in% names(df)) {
      day <- suppressWarnings(as.Date(df[[date_col]]))
      ok <- !is.na(day) & !is.na(df[[enum_col]]) & as.character(df[[enum_col]]) != ""
      if (any(ok)) {
        per_day <- as.data.frame(table(enumerator_id = as.character(df[[enum_col]][ok]), day = as.character(day[ok])),
                                 stringsAsFactors = FALSE)
        per_day <- per_day[per_day$Freq > 0, , drop = FALSE]
      }
    }
    enumerator_flags(m, per_day)
  })

  output$enum_rules <- renderUI({
    m <- enum_metrics(); req(m)
    th <- attr(m, "thresholds")
    fmt <- function(x, d = 1) if (is.na(x)) "n/a" else format(round(x, d), nsmall = d)
    tags$span(bsicons::bs_icon("info-circle"), " Flagged against the other enumerators: average interview under ",
              fmt(th$dur_lo), " or over ", fmt(th$dur_hi), " min (outside the IQR fences), missing answers over ",
              fmt(100 * th$miss_hi), "% (mean + 2 SD)",
              if (!is.na(th$day_hi)) paste0(", or more than ", fmt(th$day_hi, 0), " interviews in one day") else "", ".")
  })

  output$enum_flagged_ui <- renderUI({
    m <- enum_metrics(); req(m)
    f <- m[m$flag == "Review", , drop = FALSE]
    if (!nrow(f)) {
      return(empty_state("No enumerator flagged", "Everyone's speed, completeness and daily load are in line with the team.",
                         icon = "check2-circle"))
    }
    tags$div(class = "wfp-enum-grid", lapply(seq_len(nrow(f)), function(i) {
      id <- as.character(f$enumerator_id[i])
      tags$div(
        class = "wfp-insight",
        tags$div(class = "d-flex align-items-center gap-2",
                 tags$strong(id),
                 tags$span(class = "small text-muted ms-auto", format(round(f$interviews[i]), big.mark = ","), " interviews")),
        tags$ul(class = "wfp-enum-reasons", lapply(strsplit(f$reasons[i], "; ", fixed = TRUE)[[1]], tags$li)),
        tags$button(type = "button", class = "btn btn-link btn-sm p-0",
                    onclick = sprintf("Shiny.setInputValue('%s', %s, {priority: 'event'})", ns("enum_open"),
                                      jsonlite::toJSON(id, auto_unbox = TRUE)),
                    "See their interviews"))
    }))
  })

  observeEvent(input$enum_open, {
    df <- dq_filtered_data(); req(df, user_setup$enumerator_id)
    recs <- df[which(as.character(df[[user_setup$enumerator_id]]) == input$enum_open), , drop = FALSE]
    m <- enum_metrics()
    why <- m$reasons[as.character(m$enumerator_id) == input$enum_open][1]
    output$enum_recs <- DT::renderDT(record_table(recs, user_setup, session$ns, "enum_view", page_length = 10))
    showModal(modalDialog(
      title = tagList(bsicons::bs_icon("person-badge"), " ", input$enum_open, sprintf(": %s interviews", format(nrow(recs), big.mark = ","))),
      size = "xl", easyClose = TRUE,
      if (!is.na(why) && nzchar(why)) tags$div(class = "alert alert-warning small", why),
      DT::DTOutput(ns("enum_recs"), fill = FALSE),
      footer = modalButton("Close")
    ))
  })
  observeEvent(input$enum_view, {
    showModal(record_detail_modal(find_record(dq_filtered_data(), user_setup, input$enum_view),
                                  title = paste("Interview:", input$enum_view)))
  })

  output$enum_flag_download <- download_handler(
    filename = function() export_file_name("Targeting_Flagged_enumerators", "xlsx", "%Y-%m-%d_%Hh%M"),
    content = function(file) {
      m <- enum_metrics()
      f <- if (is.null(m)) NULL else m[m$flag == "Review", , drop = FALSE]
      write_xlsx_readonly(if (is.null(f) || !nrow(f)) data.frame(Message = "No enumerator flagged") else f, file, "Flagged")
    }
  )

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

#' Flag enumerators against their cohort, with the reason in words
#'
#' Durations outside the IQR fences suggest rushed or padded interviews;
#' missingness above the cohort mean + 2 SD suggests sloppy capture; a day far
#' busier than the team's usual (Q3 + 1.5 IQR of enumerator-days) suggests
#' interviews that were not all really held.
#'
#' @param m One row per enumerator: enumerator_id, interviews, avg_duration,
#'   missingness_rate.
#' @param per_day Optional data.frame(enumerator_id, day, Freq).
#' @return `m` with `flag` ("OK"/"Review") and `reasons`; the thresholds in
#'   attr(, "thresholds").
#' @noRd
enumerator_flags <- function(m, per_day = NULL) {
  n <- nrow(m)
  reasons <- vector("list", n)
  add <- function(i, txt) for (k in seq_along(i)) reasons[[i[k]]] <<- c(reasons[[i[k]]], txt[k])

  dur_lo <- dur_hi <- NA_real_
  ok <- !is.na(m$avg_duration)
  if (sum(ok) >= 4) {
    qs <- stats::quantile(m$avg_duration[ok], c(0.25, 0.5, 0.75), names = FALSE)
    iqr <- qs[3] - qs[1]
    dur_lo <- max(0, qs[1] - 1.5 * iqr); dur_hi <- qs[3] + 1.5 * iqr
    lo <- which(ok & m$avg_duration < dur_lo)
    hi <- which(ok & m$avg_duration > dur_hi)
    if (length(lo)) add(lo, sprintf("Short interviews: %.1f min on average, under the team's %.1f (team median %.1f)",
                                    m$avg_duration[lo], dur_lo, qs[2]))
    if (length(hi)) add(hi, sprintf("Long interviews: %.1f min on average, over the team's %.1f (team median %.1f)",
                                    m$avg_duration[hi], dur_hi, qs[2]))
  }

  miss_hi <- NA_real_
  miss_sd <- stats::sd(m$missingness_rate, na.rm = TRUE)
  if (!is.na(miss_sd) && miss_sd > 0) {
    miss_mean <- stats::weighted.mean(m$missingness_rate, m$interviews, na.rm = TRUE)
    miss_hi <- miss_mean + 2 * miss_sd
    hi <- which(m$missingness_rate > miss_hi)
    if (length(hi)) add(hi, sprintf("Missing answers: %.1f%% of fields left empty, over the team's %.1f%% (average %.1f%%)",
                                    100 * m$missingness_rate[hi], 100 * miss_hi, 100 * miss_mean))
  }

  day_hi <- NA_real_
  if (!is.null(per_day) && nrow(per_day) >= 4) {
    qs <- stats::quantile(per_day$Freq, c(0.25, 0.5, 0.75), names = FALSE)
    day_hi <- max(qs[3] + 1.5 * (qs[3] - qs[1]), qs[2] + 2)
    busy <- per_day[per_day$Freq > day_hi, , drop = FALSE]
    busy <- busy[order(-busy$Freq), , drop = FALSE]
    busy <- busy[!duplicated(busy$enumerator_id), , drop = FALSE]
    i <- match(busy$enumerator_id, as.character(m$enumerator_id))
    keep <- !is.na(i)
    if (any(keep)) add(i[keep], sprintf("Busy day: %d interviews on %s, over the team's usual maximum of %.0f",
                                        busy$Freq[keep], busy$day[keep], day_hi))
  }

  m$reasons <- vapply(reasons, function(r) paste(r, collapse = "; "), character(1))
  m$flag <- ifelse(nzchar(m$reasons), "Review", "OK")
  attr(m, "thresholds") <- list(dur_lo = dur_lo, dur_hi = dur_hi, miss_hi = miss_hi, day_hi = day_hi)
  m
}
