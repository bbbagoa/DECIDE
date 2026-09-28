#' Chart builder (Targeting Monitoring)
#'
#' Pick a ready-made chart or build one (what to count or measure, by what,
#' for whom), see it, then add it to the Targeting Monitoring report with a
#' title and a comment. Used on the PDM data and on targeting-process data.
#'
#' @param id module id
#' @param presets Names of `chart_presets()` groups offered here.
#' @noRd
mod_chart_builder_ui <- function(id, presets = names(chart_presets())) {
  ns <- NS(id)
  pr <- chart_presets()[presets]
  choices <- c(list(`Build my own` = c("Custom chart" = "custom")),
               lapply(pr, function(g) stats::setNames(names(g), vapply(g, `[[`, character(1), "label"))))
  field <- function(...) tags$div(class = "wfp-cb-field", ...)
  bslib::layout_columns(
    col_widths = c(4, 8),
    bslib::card(
      bslib::card_header(bsicons::bs_icon("sliders"), " Chart"),
      bslib::card_body(
        selectInput(ns("preset"), "Ready-made chart", choices = choices, width = "100%"),
        shinyWidgets::radioGroupButtons(ns("display"), "Display as", choices = c("Chart" = "chart", "Table" = "table"),
                                        selected = "chart", size = "sm", status = "outline-primary", justified = TRUE),
        selectInput(ns("type"), "Show", choices = chart_types(), width = "100%"),
        conditionalPanel(sprintf("input['%s'] !== 'table'", ns("display")),
                         selectInput(ns("style"), "Chart style", choices = chart_styles(), width = "100%")),
        conditionalPanel(sprintf("input['%s'] !== 'trend'", ns("type")),
                         selectInput(ns("x"), "By", choices = character(0), width = "100%")),
        conditionalPanel(sprintf("input['%s'] === 'trend'", ns("type")),
                         tags$div(class = "d-flex gap-2",
                                  field(selectInput(ns("date"), "Date column", choices = character(0), width = "100%")),
                                  field(selectInput(ns("period"), "Per", choices = c("Month" = "month", "Week" = "week"), width = "100%")))),
        conditionalPanel(sprintf("['sum','mean','share','trend'].indexOf(input['%s']) >= 0", ns("type")),
                         selectInput(ns("value"), "Number column", choices = character(0), width = "100%")),
        conditionalPanel(sprintf("input['%s'] === 'share'", ns("type")),
                         selectInput(ns("den"), "Out of (total column)", choices = character(0), width = "100%")),
        selectInput(ns("group"), "Split by (optional; the columns of a crosstab)", choices = character(0), width = "100%"),
        conditionalPanel(sprintf("input['%s'] === 'crosstab'", ns("type")),
                         radioButtons(ns("pct"), "Percentages", inline = TRUE,
                                      choices = c("Row" = "row", "Column" = "col", "Total" = "total", "Counts only" = "count"),
                                      selected = "row")),
        tags$div(class = "d-flex gap-2",
                 field(selectInput(ns("filter_col"), "Only where", choices = character(0), width = "100%")),
                 field(shinyWidgets::pickerInput(ns("filter_vals"), "is one of", choices = character(0), multiple = TRUE,
                                                 width = "100%",
                                                 options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE,
                                                                                       liveSearch = TRUE, selectedTextFormat = "count > 2"))))
      )
    ),
    bslib::card(
      full_screen = TRUE,
      bslib::card_header(bsicons::bs_icon("bar-chart"), " ", textOutput(ns("preview_title"), inline = TRUE)),
      bslib::card_body(
        uiOutput(ns("preview_empty")),
        uiOutput(ns("stat_note")),
        conditionalPanel(sprintf("input['%s'] !== 'table'", ns("display")),
                         plotly::plotlyOutput(ns("preview"), height = "360px")),
        conditionalPanel(sprintf("input['%s'] === 'table'", ns("display")),
                         DT::DTOutput(ns("preview_table"), fill = FALSE)),
        tags$div(
          class = "wfp-cb-add",
          textInput(ns("title"), "Title in the report", width = "100%"),
          rich_text_input(ns("comment"), "Your comment (what it shows, why it matters)", rows = 3,
                          placeholder = "e.g. Women made up 38% of participants in Beni, below the 50% target; sessions were held on market days."),
          actionButton(ns("add"), "Add to report", icon = icon("plus"), class = "btn-primary")
        )
      )
    )
  )
}

#' @param data Reactive data.frame.
#' @param source "pdm" or "process" (report section).
#' @param dataset_name Reactive label of the dataset (report source line).
#' @param add_item Function taking one report item.
#' @noRd
mod_chart_builder_server <- function(id, data, source, dataset_name = reactive(""), add_item) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    none <- c("(none)" = "")

    observeEvent(data(), {
      df <- data(); req(df)
      cols <- names(df)
      # Judged on the answered values: counting NA against a column dropped
      # every sparsely answered number from the list.
      num <- quantitative_cols(df, min_share = 0.8)
      # Start on a column worth charting: a category, not an identifier.
      few <- cols[vapply(df, function(v) { k <- length(unique(v)); k >= 2 && k <= 30 }, logical(1))]
      # no identifiers, names or free text to chart (the date list keeps every column)
      an <- analysis_cols(df, cols); few <- intersect(few, an); num <- intersect(num, an)
      updateSelectInput(session, "x", choices = an, selected = if (length(few)) few[1] else an[1])
      updateSelectInput(session, "date", choices = cols,
                        selected = grep("date|time|submission", cols, ignore.case = TRUE, value = TRUE)[1] %||% cols[1])
      updateSelectInput(session, "value", choices = c(none, num))
      updateSelectInput(session, "den", choices = c(none, num))
      updateSelectInput(session, "group", choices = c(none, an))
      updateSelectInput(session, "filter_col", choices = c(none, an))
    })

    observeEvent(input$filter_col, {
      df <- data()
      v <- if (!is.null(df) && nzchar(input$filter_col %||% "") && input$filter_col %in% names(df))
        utils::head(sort(unique(as.character(df[[input$filter_col]]))), 500) else character(0)
      shinyWidgets::updatePickerInput(session, "filter_vals", choices = value_choices(v, input$filter_col),
                                      selected = isolate(pending_vals()) %||% character(0))
      pending_vals(NULL)
    })
    pending_vals <- reactiveVal(NULL)

    # A ready-made chart fills the fields; the officer can change any of them.
    observeEvent(input$preset, {
      req(nzchar(input$preset %||% ""), !identical(input$preset, "custom"))
      df <- data(); req(df)
      pr <- unlist(unname(chart_presets()), recursive = FALSE)[[input$preset]]
      sp <- apply_preset(pr, df)
      updateSelectInput(session, "type", selected = sp$type)
      for (k in c("x", "date", "value", "den", "group", "filter_col")) updateSelectInput(session, k, selected = sp[[k]])
      updateSelectInput(session, "period", selected = sp$period)
      pending_vals(sp$filter_vals)
      shinyWidgets::updatePickerInput(session, "filter_vals", selected = sp$filter_vals)
      updateTextInput(session, "title", value = sp$title)
      missing <- c(if (sp$type != "trend" && !nzchar(sp$x)) "the category column",
                   if (sp$type %in% c("sum", "mean", "share") && !nzchar(sp$value)) "the number column",
                   if (sp$type == "share" && !nzchar(sp$den)) "the total column")
      if (length(missing)) showNotification(paste("Pick", paste(missing, collapse = " and "), "for this chart."), type = "warning")
    }, ignoreInit = TRUE)

    spec <- reactive(list(type = input$type, x = input$x, group = input$group, value = input$value, den = input$den,
                          date = input$date, period = input$period, filter_col = input$filter_col,
                          filter_vals = input$filter_vals, pct = input$pct, style = input$style %||% "auto"))
    agg <- reactive(tryCatch(chart_aggregate(data(), spec()), error = function(e) NULL))

    output$stat_note <- renderUI({
      sp <- spec()
      pn <- if (!identical(input$display, "table")) chart_pie_note(sp)
      if (!is.null(pn)) return(tags$div(class = "small text-warning mb-2", bsicons::bs_icon("info-circle"), " ", pn))
      if (!identical(sp$type, "crosstab")) return(NULL)
      if (!nzchar(sp$group %||% "")) return(tags$div(class = "small text-warning mb-2", "Choose the column variable in 'Split by'."))
      d <- agg(); req(d)
      tags$div(class = "small text-muted mb-2", bsicons::bs_icon("calculator"), " ", crosstab_test_text(crosstab_test(d)))
    })

    output$preview_title <- renderText(if (nzchar(input$title %||% "")) input$title else "Preview")
    output$preview_empty <- renderUI({
      if (is.null(data())) return(empty_state("No data yet", "Load a dataset above to build charts.", icon = "cloud-upload"))
      if (is.null(agg())) return(tags$div(class = "small text-muted mb-2", "Choose the columns on the left to see the chart."))
      NULL
    })
    output$preview <- render_wfp_plotly({
      d <- agg(); req(d, nrow(d) > 0)
      sp <- spec()
      grp <- length(unique(d$group)) > 1
      st <- chart_style(sp)
      if (st %in% c("pie", "donut")) {
        pd <- chart_pie_data(d)
        donut <- identical(st, "donut")
        top <- which.max(pd$n)
        p <- plotly::plot_ly(pd, labels = ~category, values = ~n, type = "pie", sort = FALSE,
                             hole = if (donut) 0.8 else 0, textinfo = if (donut) "none" else "percent",
                             hoverinfo = "label+percent+value",
                             marker = list(colors = rep_len(rp_cols$models, nrow(pd)))) |>
          plotly::layout(legend = list(orientation = "h", x = 0, y = -0.05))
        # a donut says its largest share in the middle
        if (donut) p <- plotly::layout(p, annotations = list(list(
          text = sprintf("<b style='font-size:22px'>%.0f%%</b><br><span style='font-size:11px'>%s</span>",
                         100 * pd$n[top] / sum(pd$n), substr(as.character(pd$category[top]), 1, 22)),
          showarrow = FALSE, x = 0.5, y = 0.5, xref = "paper", yref = "paper")))
        return(p)
      }
      if (identical(st, "column")) {
        d$x <- factor(d$x, levels = unique(d$x))
        p <- plotly::plot_ly(d, x = ~x, y = ~value, color = if (grp) ~group else I("#0A6EB4"), type = "bar",
                             text = ~value, textposition = "outside", cliponaxis = FALSE)
        if (grp && chart_stacks(sp)) p <- plotly::layout(p, barmode = "stack")
        return(plotly::layout(p, xaxis = list(title = "", automargin = TRUE), yaxis = list(title = chart_value_label(sp)),
                              legend = list(orientation = "h", x = 0, y = 1.08, xanchor = "left", yanchor = "bottom")))
      }
      if (st %in% c("line", "area")) {
        if (!identical(sp$type, "trend")) d$x <- factor(d$x, levels = unique(d$x))
        p <- plotly::plot_ly(d, x = ~x, y = ~value, color = if (grp) ~group else I("#0A6EB4"),
                             type = "scatter", mode = "lines+markers", fill = if (identical(st, "area")) "tozeroy" else "none")
      } else {
        d$x <- factor(d$x, levels = rev(unique(d$x)))
        p <- plotly::plot_ly(d, x = ~value, y = ~x, color = if (grp) ~group else I("#0A6EB4"), type = "bar",
                             orientation = "h", text = ~value, textposition = "outside", cliponaxis = FALSE)
        if (grp && chart_stacks(sp)) p <- plotly::layout(p, barmode = "stack")
      }
      line <- st %in% c("line", "area")
      plotly::layout(p, xaxis = list(title = if (line) "" else chart_value_label(sp)),
                     yaxis = list(title = if (line) chart_value_label(sp) else "", automargin = TRUE),
                     legend = list(orientation = "h", x = 0, y = 1.08, xanchor = "left", yanchor = "bottom"))
    })

    output$preview_table <- DT::renderDT({
      d <- agg(); req(d, nrow(d) > 0)
      DT::datatable(chart_table(d, spec()), rownames = FALSE,
                    options = list(dom = "t", paging = FALSE, ordering = FALSE))
    })

    observeEvent(input$add, {
      d <- agg()
      if (is.null(d) || !nrow(d)) {
        showNotification("Nothing to add yet: choose the columns first.", type = "warning")
        return()
      }
      title <- trimws(input$title %||% "")
      if (!nzchar(title)) title <- chart_value_label(spec())
      # A finding written from the numbers, offered as a suggestion in the
      # report list ("Use it"); the comment stays what the officer typed.
      cap <- tryCatch(chart_caption(d, spec()), error = function(e) "")
      comment <- input$comment %||% ""
      add_item(list(id = paste0("it", format(as.numeric(Sys.time()) * 1000, scientific = FALSE), sample.int(999, 1)),
                    source = source, dataset = dataset_name(), title = title,
                    comment = comment, caption = cap, spec = spec(), data = d,
                    display = input$display %||% "chart",
                    preset = if (!identical(input$preset, "custom")) input$preset))
      update_rich_text(session, "comment", "")
      showNotification(sprintf("'%s' added to the monitoring report.", title), type = "message")
    })
  })
}
