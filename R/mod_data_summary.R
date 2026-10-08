#' "Data summary" for an uploaded dataset (React: components/DataSummary.tsx)
#'
#' The button sends `input$<ns>-open`; the summary of the data at that moment
#' is computed then (`data_summary()`), never in the background, and sent as
#' `output$<ns>-summary`. `output$<ns>-download` writes it to a read-only
#' workbook (one row per variable).
#'
#' @param get_data A reactive (or function) returning the data frame.
#' @param name What the data is, for the dialog and the file name.
#' @noRd
mod_data_summary_server <- function(id, get_data, name = "Data") {
  moduleServer(id, function(input, output, session) {
    result <- reactiveVal(NULL)
    runs <- 0   # each summary is numbered; the dialog waits for a newer one than it had
    compute <- function() {
      runs <<- runs + 1
      df <- tryCatch(get_data(), error = function(e) NULL)
      if (is.null(df) || !nrow(df)) {
        result(list(empty = TRUE, title = name, n = runs))
        return(invisible(runs))
      }
      labs <- tryCatch(label_registry()$labels, error = function(e) NULL)
      s <- data_summary(df, labels = labs)
      s$title <- name
      s$empty <- FALSE
      s$n <- runs
      result(s)
      invisible(runs)
    }
    observeEvent(input$open, {
      req(input$open > 0)   # a React button sends 0 at start
      compute()
    })
    # from a Shiny dialog (the import summary): a plain Shiny button; the React
    # dialog is told to open over it
    observeEvent(input$open_modal, {
      req(input$open_modal > 0)
      k <- compute()
      shinyreact::send_message(session, "show", list(n = k))
    })
    output$summary <- shinyreact::reactive_output(result())
    output$download <- download_handler(
      filename = function() export_file_name(paste0("Data_summary_", gsub("[^A-Za-z0-9]+", "_", name)), "xlsx"),
      content = function(file) {
        s <- result()
        df <- tryCatch(get_data(), error = function(e) NULL)
        if (is.null(s) || isTRUE(s$empty)) {
          if (is.null(df)) return(write_xlsx_readonly(data.frame(Message = "No data loaded."), file, "Summary"))
          s <- data_summary(df, labels = tryCatch(label_registry()$labels, error = function(e) NULL))
        }
        wb <- openxlsx::createWorkbook()
        xl_data_sheet(wb, "Summary", sanitize_for_excel(data_summary_frame(s)))
        save_workbook_readonly(wb, file)
      })
    shiny::outputOptions(output, "download", suspendWhenHidden = FALSE)
    invisible(NULL)
  })
}
