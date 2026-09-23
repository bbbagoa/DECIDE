#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_duplicates_ui <- function(ns) {
          bslib::nav_panel(
            title = "Duplicates",
            icon = bsicons::bs_icon("copy"),
            tags$div(
              class = "p-3",
              tags$div(
                class = "d-flex flex-wrap align-items-end gap-3 wfp-dq-toolbar",
                tags$div(style = "flex: 1 1 320px; max-width: 520px;",
                  shinyWidgets::pickerInput(
                    inputId = ns("duplicate_vars"), label = "Columns that identify a household", width = "100%",
                    choices = NULL, multiple = TRUE,
                    options = shinyWidgets::pickerOptions(actionsBox = TRUE, liveSearch = TRUE, container = "body",
                                                          selectedTextFormat = "count > 3"))),
                tags$div(class = "pb-3",
                  shinyWidgets::awesomeCheckbox(inputId = ns("duplicate_fuzzy"), label = "Fuzzy matching", value = FALSE)),
                tags$div(style = "flex: 0 1 200px;",
                  sliderInput(ns("duplicate_fuzzy_dist"), "Max string distance", min = 0, max = 5, value = 1, step = 1, width = "100%")),
                tags$div(class = "d-flex gap-2 pb-3",
                  actionButton(ns("btn_refresh_duplicates"), "Find duplicates", class = "btn-primary", icon = icon("magnifying-glass")),
                  downloadButton(ns("download_duplicates"), "Export", class = "btn-outline-secondary"))
              )
            ),
            bslib::layout_columns(
              col_widths = c(4, 4, 4),
              bslib::value_box(title = "Records checked", value = textOutput(ns("dup_total")),
                               showcase = bsicons::bs_icon("list-ol"), theme = "primary"),
              bslib::value_box(title = "Duplicate records", value = textOutput(ns("dup_count")),
                               showcase = bsicons::bs_icon("copy"), theme = "warning"),
              bslib::value_box(title = "Duplicate groups", value = textOutput(ns("dup_groups")),
                               showcase = bsicons::bs_icon("diagram-3"), theme = "info")
            ),
            uiOutput(ns("dup_hint")),
            bslib::card(
                full_screen = TRUE,
                bslib::card_header(bsicons::bs_icon("copy"), " Duplicate records, grouped"),
                DT::DTOutput(ns("dq_duplicate_table"), fill = FALSE)
              )
          )
}

#' Data Quality sub-tab server
#' Shares the parent module input/output/session/ns namespace.
#' @param input,output,session,ns parent module handles
#' @param core list with dq_filtered_data, uploaded_df, user_setup, modification_log
#' @import shiny
#' @noRd
dq_duplicates_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  # Duplicates Analysis
  # ------------------------------------------------------------

  observeEvent(uploaded_df(), {
    req(uploaded_df())
    cols <- names(uploaded_df())
    selected <- character(0)
    if (!is.null(user_setup$unique_id) && user_setup$unique_id %in% cols) {
      selected <- user_setup$unique_id
    }
    shinyWidgets::updatePickerInput(
      session = session,
      inputId = "duplicate_vars",
      choices = cols,
      selected = selected
    )
  })

  duplicate_analysis <- eventReactive(input$btn_refresh_duplicates, {
    req(dq_filtered_data(), input$duplicate_vars)
    df <- dq_filtered_data()
    vars <- input$duplicate_vars
    req(all(vars %in% names(df)))

    use_fuzzy <- isTRUE(input$duplicate_fuzzy)
    max_dist <- as.integer(input$duplicate_fuzzy_dist)

    if (use_fuzzy && max_dist > 0) {
      key <- do.call(paste, c(df[vars], list(sep = "|")))
      groups <- fuzzy_match_groups(key, max_dist = max_dist)
      dup_index <- groups > 0
      dup_df <- df[dup_index, , drop = FALSE]
      if (nrow(dup_df) > 0) {
        dup_df$.dup_group <- groups[dup_index]
        dup_df <- dup_df |> dplyr::arrange(.data[[".dup_group"]])
      } else {
        dup_df$.dup_group <- integer()
      }
    } else {
      dup_index <- duplicated(df[vars]) | duplicated(df[vars], fromLast = TRUE)
      dup_df <- df[dup_index, , drop = FALSE]
      if (nrow(dup_df) > 0) {
        dup_df$.dup_group <- as.integer(factor(do.call(paste, c(dup_df[vars], list(sep = "|")))))
        dup_df <- dup_df |> dplyr::arrange(.data[[".dup_group"]])
      } else {
        dup_df$.dup_group <- integer()
      }
    }

    list(
      total = nrow(df),
      dup_count = sum(dup_index),
      dup_groups = dplyr::n_distinct(dup_df$.dup_group),
      dup_df = dup_df
    )
  }, ignoreNULL = FALSE)

  # NULL until the user has run the analysis (req() inside the eventReactive
  # raises a silent error, which tryCatch turns into NULL for the placeholders)
  analysis_or_null <- reactive(tryCatch(duplicate_analysis(), error = function(e) NULL))

  kpi <- function(field) renderText({
    a <- analysis_or_null()
    if (is.null(a)) "\u2014" else format(a[[field]], big.mark = ",")
  })
  output$dup_total  <- kpi("total")
  output$dup_count  <- kpi("dup_count")
  output$dup_groups <- kpi("dup_groups")

  output$dup_hint <- renderUI({
    a <- analysis_or_null()
    if (is.null(a)) {
      empty_state("No duplicate analysis yet",
                  "Choose the columns that identify a record, then click Refresh Analysis.", icon = "copy")
    } else if (nrow(a$dup_df) == 0) {
      empty_state("No duplicates found",
                  paste0("Checked ", format(a$total, big.mark = ","), " records on the selected columns."), icon = "check2-circle")
    }
  })

  # Identification columns plus the duplicate-group number, which is the whole
  # point of this table; everything else is behind Details.
  output$dq_duplicate_table <- DT::renderDT({
    req(duplicate_analysis())
    dup_df <- duplicate_analysis()$dup_df
    req(nrow(dup_df) > 0)
    record_table(dup_df, user_setup, session$ns, "dup_view",
                 extra_cols = ".dup_group", page_length = 15)
  })

  observeEvent(input$dup_view, {
    a <- analysis_or_null()
    req(a)
    showModal(record_detail_modal(
      find_record(a$dup_df, user_setup, input$dup_view),
      title = paste("Duplicate record:", input$dup_view)
    ))
  })

  output$download_duplicates <- downloadHandler(
    filename = function() paste0("Targeting_Duplicates_", format(Sys.time(), "%Y-%m-%d_%Hh%Mm%Ss"), ".csv"),
    content = function(file) {
      dup_df <- duplicate_analysis()$dup_df
      if (is.null(dup_df) || nrow(dup_df) == 0) {
        write_csv_utf8(data.frame(Message = "No duplicates found"), file)
      } else {
        write_csv_utf8(dup_df, file)
      }
    }
  )


}
