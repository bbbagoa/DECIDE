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
                tags$div(class = "mt-3", uiOutput(ns("enum_speed_insights"))),
                bslib::layout_columns(
                  col_widths = c(6, 6),
                  bslib::card(
                    full_screen = TRUE,
                    bslib::card_header("Interviews by enumerator"),
                    tags$div(class = "small text-muted px-3 pt-2",
                             "Red: flagged for review. Dashed line: the team median."),
                    plotly::plotlyOutput(ns("enum_interviews_plot"), height = "560px")
                  ),
                  bslib::card(
                    full_screen = TRUE,
                    bslib::card_header("Average interview duration"),
                    tags$div(class = "small text-muted px-3 pt-2",
                             "Green band: the team's usual range (IQR fences). Red: shorter; amber: longer. The enumerators furthest from the median are shown."),
                    plotly::plotlyOutput(ns("enum_duration_plot"), height = "560px")
                  )
                ),
                bslib::card(
                  full_screen = TRUE,
                  bslib::card_header("Interviews per day, by enumerator"),
                  tags$div(class = "small text-muted px-3 pt-2",
                           "Darker cells are busier days. A cell far darker than the rest of its row is a day worth checking."),
                  plotly::plotlyOutput(ns("enum_daily_plot"), height = "560px")
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
                bslib::card_header("Empty answers by enumerator"),
                plotly::plotlyOutput(ns("enum_missingness_plot"), height = "560px")
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
    enumerator_metrics(dq_filtered_data(), user_setup)
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

  # Interviews per enumerator and day (when a date is mapped).
  enum_per_day <- reactive({
    df <- dq_filtered_data(); req(df, user_setup$enumerator_id)
    date_col <- user_setup$date
    if (!shiny::isTruthy(date_col) || !date_col %in% names(df)) return(NULL)
    day <- suppressWarnings(as.Date(df[[date_col]]))
    enum <- as.character(df[[user_setup$enumerator_id]])
    ok <- !is.na(day) & !is.na(enum) & nzchar(enum)
    if (!any(ok)) return(NULL)
    d <- as.data.frame(table(enumerator_id = enum[ok], day = format(day[ok])), stringsAsFactors = FALSE)
    d[d$Freq > 0, , drop = FALSE]
  })

  output$enum_speed_insights <- renderUI({
    m <- enum_metrics(); req(m, nrow(m) > 0)
    th <- attr(m, "thresholds") %||% list()
    tiles <- list()
    # Workload balance: how much the busiest fifth carries.
    iv <- sort(m$interviews, decreasing = TRUE)
    top <- max(1, ceiling(0.2 * length(iv)))
    share <- sum(iv[seq_len(top)]) / max(1, sum(iv))
    busiest <- m[which.max(m$interviews), ]
    tiles[[length(tiles) + 1]] <- ben_insight("people", "Workload balance",
      sprintf("%.0f%%", 100 * share),
      sprintf("of interviews by the busiest %d of %d enumerators. Busiest: %s (%s; median %s).", top, length(iv),
              busiest$enumerator_id, format(round(busiest$interviews), big.mark = ","),
              format(round(stats::median(m$interviews)), big.mark = ",")))
    # Interview length against the team.
    dur <- m$avg_duration[!is.na(m$avg_duration)]
    if (length(dur)) {
      short <- if (is.na(th$dur_lo %||% NA)) 0 else sum(dur < th$dur_lo)
      long <- if (is.na(th$dur_hi %||% NA)) 0 else sum(dur > th$dur_hi)
      tiles[[length(tiles) + 1]] <- ben_insight("stopwatch", "Interview length",
        sprintf("%.0f min", stats::median(dur)),
        if (is.na(th$dur_lo %||% NA)) "team median (too few enumerators to set a usual range)"
        else sprintf("team median. %d usually shorter than %.0f min, %d longer than %.0f min.", short, th$dur_lo, long, th$dur_hi))
    }
    pd <- enum_per_day()
    if (!is.null(pd) && nrow(pd)) {
      b <- pd[which.max(pd$Freq), ]
      tiles[[length(tiles) + 1]] <- ben_insight("calendar-event", "Busiest day",
        sprintf("%d interviews", b$Freq),
        sprintf("by %s on %s%s.", b$enumerator_id, b$day,
                if (is.na(th$day_hi %||% NA)) "" else sprintf(" (the team's usual maximum is %.0f)", th$day_hi)))
      pace <- stats::aggregate(pd$Freq, list(pd$enumerator_id), stats::median)$x
      tiles[[length(tiles) + 1]] <- ben_insight("speedometer2", "Daily pace",
        sprintf("%.1f / day", stats::median(pace)),
        sprintf("median interviews per working day per enumerator, over %d days of fieldwork.", length(unique(pd$day))))
    }
    worst <- m[which.max(m$missingness_rate), ]
    tiles[[length(tiles) + 1]] <- ben_insight("ui-checks", "Empty answers",
      sprintf("%.1f%%", 100 * stats::weighted.mean(m$missingness_rate, m$interviews, na.rm = TRUE)),
      sprintf("of fields left empty on average. Highest: %s (%.1f%%).", worst$enumerator_id, 100 * worst$missingness_rate))
    tags$div(class = "wfp-insights", tiles)
  })

  # A dashed vertical line with a small label, for the charts below.
  vline <- function(x, label, color = "#f7b825") {
    list(shape = list(type = "line", x0 = x, x1 = x, y0 = 0, y1 = 1, yref = "paper",
                      line = list(color = color, dash = "dash", width = 1.5)),
         note = list(x = x, y = 1, yref = "paper", text = label, showarrow = FALSE, yanchor = "bottom",
                     font = list(size = 11, color = color)))
  }

  output$enum_interviews_plot <- render_wfp_plotly({
    m <- enum_metrics(); req(m, nrow(m) > 0)
    tab <- utils::head(m[order(-m$interviews), , drop = FALSE], 30)
    tab <- tab[order(tab$interviews), , drop = FALSE]
    tab$label <- substr(as.character(tab$enumerator_id), 1, 24)
    med <- stats::median(m$interviews)
    ml <- vline(med, sprintf("median %s", format(round(med), big.mark = ",")))
    plotly::plot_ly(
      tab, x = ~interviews, y = ~factor(label, levels = label), type = "bar",
      marker = list(color = ifelse(tab$flag == "Review", "#c5192d", "#0A6EB4")),
      customdata = ~ifelse(nzchar(reasons), reasons, "No flag"),
      hovertemplate = "%{y}: %{x:,.0f} interviews<br>%{customdata}<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Interviews", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = "", automargin = TRUE),
        shapes = list(ml$shape), annotations = list(ml$note),
        margin = list(t = 30, b = 40, r = 20))
  })

  output$enum_daily_plot <- render_wfp_plotly({
    pd <- enum_per_day()
    validate(need(!is.null(pd) && nrow(pd) > 0, "Map the interview date in the variable setup to see the daily workload."))
    tot <- sort(tapply(pd$Freq, pd$enumerator_id, sum), decreasing = TRUE)
    keep <- names(tot)[seq_len(min(30, length(tot)))]
    pd <- pd[pd$enumerator_id %in% keep, , drop = FALSE]
    days <- sort(unique(pd$day))
    z <- matrix(0, nrow = length(keep), ncol = length(days), dimnames = list(keep, days))
    z[cbind(match(pd$enumerator_id, keep), match(pd$day, days))] <- pd$Freq
    z <- z[rev(seq_len(nrow(z))), , drop = FALSE]
    plotly::plot_ly(
      x = days, y = substr(rownames(z), 1, 24), z = z, type = "heatmap",
      colorscale = list(c(0, "rgba(10,110,180,0.04)"), c(0.01, "#d7e8f5"), c(1, "#0A6EB4")),
      hovertemplate = "%{y}<br>%{x}: %{z} interviews<extra></extra>",
      colorbar = list(title = "Interviews", thickness = 12)
    ) |>
      plotly::layout(
        xaxis = list(title = "", tickangle = if (length(days) > 10) -90 else 0, type = "category"),
        yaxis = list(title = "", automargin = TRUE),
        margin = list(t = 10, b = 60, r = 10))
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
    m <- enum_metrics(); req(m)
    tab <- m[!is.na(m$avg_duration), , drop = FALSE]
    validate(need(nrow(tab) > 0, "No interview durations: the data needs start and end times (start/end or starttime/endtime)."))
    th <- attr(m, "thresholds") %||% list()
    med <- stats::median(tab$avg_duration)
    # The 30 furthest from the team median, then in order.
    tab <- utils::head(tab[order(-abs(tab$avg_duration - med)), , drop = FALSE], 30)
    tab <- tab[order(tab$avg_duration), , drop = FALSE]
    tab$label <- substr(as.character(tab$enumerator_id), 1, 24)
    lo <- th$dur_lo %||% NA; hi <- th$dur_hi %||% NA
    col <- ifelse(!is.na(lo) & tab$avg_duration < lo, "#c5192d",
                  ifelse(!is.na(hi) & tab$avg_duration > hi, "#f7b825", "#0A6EB4"))
    ml <- vline(med, sprintf("median %.0f min", med))
    shapes <- list(ml$shape)
    if (!is.na(lo) && !is.na(hi)) shapes <- c(list(list(type = "rect", x0 = lo, x1 = hi, y0 = 0, y1 = 1, yref = "paper",
                                                           fillcolor = "rgba(63,126,68,0.10)", line = list(width = 0), layer = "below")), shapes)
    plotly::plot_ly(
      tab, x = ~avg_duration, y = ~factor(label, levels = label), type = "bar",
      marker = list(color = col),
      customdata = ~format(round(interviews), big.mark = ","),
      hovertemplate = "%{y}: %{x:.1f} min on average<br>%{customdata} interviews<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Minutes", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = "", automargin = TRUE),
        shapes = shapes, annotations = list(ml$note),
        margin = list(t = 30, b = 40, r = 20))
  })

  output$enum_missingness_plot <- render_wfp_plotly({
    m <- enum_metrics(); req(m, nrow(m) > 0)
    th <- attr(m, "thresholds") %||% list()
    tab <- utils::head(m[order(-m$missingness_rate), , drop = FALSE], 30)
    tab <- tab[order(tab$missingness_rate), , drop = FALSE]
    tab$label <- substr(as.character(tab$enumerator_id), 1, 24)
    hi <- th$miss_hi %||% NA
    notes <- list(); shapes <- list()
    if (!is.na(hi)) { l <- vline(100 * hi, sprintf("team limit %.1f%%", 100 * hi), "#c5192d"); shapes <- list(l$shape); notes <- list(l$note) }
    plotly::plot_ly(
      tab, x = ~missingness_rate * 100, y = ~factor(label, levels = label), type = "bar",
      marker = list(color = ifelse(!is.na(hi) & tab$missingness_rate > hi, "#c5192d", "#8a96a3")),
      hovertemplate = "%{y}: %{x:.1f}% of fields empty<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Fields left empty (%)", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = "", automargin = TRUE),
        shapes = shapes, annotations = notes,
        margin = list(t = 30, b = 40, r = 20))
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

#' Interviews, duration, empty answers and household size per enumerator,
#' flagged against the team (`enumerator_flags()`)
#' @param df The records.
#' @param setup The variable mapping (list or reactiveValues).
#' @noRd
enumerator_metrics <- function(df, setup) {
  enum_col <- setup$enumerator_id
  w <- get_weights(df, setup)

  hh_size_col <- setup$hh_size
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

  miss_cols <- setdiff(names(df), c(enum_col, setup$weight))
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
  date_col <- setup$date
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
}
