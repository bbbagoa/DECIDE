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
                         selectInput(ns("style"), "Chart style", choices = chart_styles(), width = "100%"),
                         tags$div(class = "mb-2", axis_button(ns("axes")))),
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
mod_chart_builder_server <- function(id, data, source, dataset_name = reactive(""), add_item,
                                     presets = names(chart_presets())) {
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

    # The chart follows the fields as they change (the one exception to
    # "settings wait for their button": a chart is cheap and seeing it is the
    # point of choosing).
    # the value axis, set in the Axes dialog (NA = automatic)
    axes <- reactiveVal(list(ymin = NA_real_, ymax = NA_real_))
    spec <- reactive(list(type = input$type, x = input$x, group = input$group, value = input$value, den = input$den,
                          date = input$date, period = input$period, filter_col = input$filter_col,
                          filter_vals = input$filter_vals, pct = input$pct, style = input$style %||% "auto",
                          axis_min = axes()$ymin, axis_max = axes()$ymax, colours = colours()))
    # the axis bounds and colours do not change the numbers: the aggregation ignores them
    spec_data <- reactive(spec()[setdiff(names(spec()), c("axis_min", "axis_max", "colours"))])
    # By and the split are drawn as categories: refuse one with too many options
    too_many <- reactive({
      df <- data(); sp <- spec_data(); if (is.null(df)) return(NULL)
      keys <- c(if (!identical(sp$type, "trend")) sp$x, sp$group)
      for (k in keys) if (shiny::isTruthy(k) && k %in% names(df)) {
        lb <- var_label(k); msg <- too_many_options(df[[k]], if (is.na(lb) || !nzchar(lb)) k else lb)
        if (!is.null(msg)) return(msg)
      }
      NULL
    })
    agg <- reactive({
      if (!is.null(too_many())) return(NULL)
      tryCatch(chart_aggregate(data(), spec_data()), error = function(e) NULL)
    })
    observeEvent(input$axes, {
      req(input$axes > 0)   # a React button sends 0 at start
      d <- agg()
      hint <- if (!is.null(d) && nrow(d)) {
        a <- chart_auto_range(d, spec())
        sprintf("Automatic now: %s to %s.", fmt5(signif(a[1], 3)), fmt5(signif(a[2], 3)))
      }
      showModal(axis_dialog(ns, "ax_", axes(), hint))
    })
    observeEvent(input$ax_apply, { axes(axis_read(input, "ax_")[c("ymin", "ymax")]); removeModal() })
    observeEvent(input$ax_reset, { axes(list(ymin = NA_real_, ymax = NA_real_)); removeModal() })
    observe(updateActionButton(session, "axes", label = if (any(is.finite(unlist(axes())))) "Axes (set)" else "Axes"))

    # Colours: one per series (per slice of a pie or donut), kept by name
    # (group or category) so they follow the chart as its fields change.
    colours <- reactiveVal(list())
    col_keys <- reactiveVal(character(0))
    # the browser's own colour picker; each dialog gets fresh input ids
    col_id <- function(i) paste0("col_", input$colours, "_", i)
    observeEvent(input$colours, {
      req(input$colours > 0)
      d <- agg()
      if (is.null(d) || !nrow(d)) { showNotification("Choose the columns first: the colours follow the chart.", type = "warning"); return() }
      cols <- chart_colours(d, spec())
      col_keys(names(cols))
      pick <- function(i) tags$label(class = "d-flex align-items-center gap-2 mb-1",
        tags$input(type = "color", value = cols[[i]], class = "form-control form-control-color",
                   oninput = sprintf("Shiny.setInputValue('%s', this.value)", ns(col_id(i)))),
        tags$span(class = "small", names(cols)[i]))
      showModal(modalDialog(
        title = "Colours", size = "m", easyClose = TRUE,
        tags$p(class = "small text-muted", "Click a colour to change it. The report uses the same colours."),
        tags$div(style = "columns: 2; column-gap: 16px;", lapply(seq_along(cols), pick)),
        footer = tagList(actionButton(ns("col_reset"), "Automatic", class = "btn-outline-secondary"),
                         modalButton("Cancel"),
                         actionButton(ns("col_apply"), "Apply", class = "btn-primary"))))
    })
    observeEvent(input$col_apply, {
      cur <- colours()
      for (i in seq_along(col_keys())) {
        v <- input[[col_id(i)]]
        if (is.character(v) && grepl("^#[0-9A-Fa-f]{6}$", v)) cur[[col_keys()[i]]] <- v
      }
      colours(cur); removeModal()
    })
    observeEvent(input$col_reset, { colours(list()); removeModal() })

    output$preview_title <- renderText(if (nzchar(input$title %||% "")) input$title else "Preview")
    output$preview <- render_echart({
      d <- agg(); req(d, nrow(d) > 0)
      chart_echart_option(d, spec())
    }, height = 360)

    output$preview_table <- render_react_table({
      d <- agg(); req(d, nrow(d) > 0)
      chart_table(d, spec())
    }, page_size = 100)

    # --- The React page (react/src/pages/monitoring/): choices and state as facts
    output$cb_meta <- shinyreact::reactive_output({
      pr <- chart_presets()[presets]
      opts <- c(list(list(value = "custom", label = "Custom chart", group = "Build my own")),
                unlist(lapply(names(pr), function(g) lapply(names(pr[[g]]), function(k)
                  list(value = k, label = pr[[g]][[k]]$label, group = g))), recursive = FALSE))
      list(presets = opts, types = as.list(chart_types()), styles = as.list(chart_styles()))
    })
    # A note above the preview: why a pie may mislead, the crosstab's test.
    # list(kind = "warning" | "test", text), or NULL.
    stat_note <- function(d) {
      sp <- spec()
      pn <- if (!identical(input$display, "table")) chart_pie_note(sp)
      if (!is.null(pn)) return(list(kind = "warning", text = pn))
      if (!identical(sp$type, "crosstab")) return(NULL)
      if (!nzchar(sp$group %||% "")) return(list(kind = "warning", text = "Choose the column variable in 'Split by'."))
      if (is.null(d)) return(NULL)
      list(kind = "test", text = crosstab_test_text(crosstab_test(d)))
    }
    output$cb_state <- shinyreact::reactive_output({
      d <- agg()
      list(has_data = !is.null(data()), too_many = too_many(), ready = !is.null(d) && nrow(d) > 0,
           axes_set = any(is.finite(unlist(axes()))),
           colours_set = !is.null(d) && nrow(d) > 0 && any(names(colours()) %in% names(chart_colours(d, spec()))),
           note = stat_note(d))
    })
    # the comment editor (www/richtext.js) is drawn by React and bound by Shiny

    observeEvent(input$add, {
      req(input$add > 0)
      d <- agg()
      if (!is.null(too_many())) { showNotification(too_many(), type = "warning", duration = 8); return() }
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
