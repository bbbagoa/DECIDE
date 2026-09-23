#' file_import UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_file_import_ui <- function(id, display = FALSE) {
  ns <- NS(id)
  tagList(
    tags$div(
      id = ns("file_in_container"),
      fileInput(ns("file_in"), "Load registration data", width = "100%",
              accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"))
    ),
    uiOutput(ns("status")), # Shows a success message when loaded

    # Only create the table placeholder if display is TRUE
    # The Table Section
    # Placeholder for the stats - only if display is TRUE
    if(display) {
      tags$div(
        class = "width: 450px; text-center",
        style = "margin-left: auto; margin-right: auto;",
        uiOutput(ns("data_summary"))
      )
    }
  )
}

#' Read an uploaded dataset by extension
#'
#' @param path Path to the uploaded file.
#' @param ext Lower-case extension without the dot.
#' @return A plain data.frame (haven-labelled columns converted to factors).
#' @noRd
read_import_file <- function(path, ext) {
  switch(ext,
    xlsx = as.data.frame(readxl::read_excel(path), stringsAsFactors = FALSE),
    xls  = as.data.frame(readxl::read_excel(path), stringsAsFactors = FALSE),
    sav  = haven::as_factor(haven::read_sav(path)),
    dta  = haven::as_factor(haven::read_dta(path)),
    csv  = data.table::fread(path, data.table = FALSE, encoding = "UTF-8",
                             na.strings = c("", "NA", "NULL"), showProgress = FALSE),
    parquet = as.data.frame(nanoparquet::read_parquet(path), stringsAsFactors = FALSE),
    stop("Unsupported file type: ", ext)
  )
}

#' file_import Server Functions
#'
#' @noRd
mod_file_import_server <- function(id, display = FALSE){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # 1. Create a reactive trigger/container
    raw_data <- reactive({
      req(input$file_in)

      w <- waiter::Waiter$new(
        html = waiter_content("Reading uploaded file..."),
        color = "rgba(10, 30, 50, 0.65)"
      )
      w$show()
      on.exit(w$hide(), add = TRUE)

      ext <- tolower(tools::file_ext(input$file_in$name))
      allowed <- c("xlsx", "xls", "sav", "dta", "csv", "parquet")

      if (!(ext %in% allowed)) {
        showNotification(
          paste("Unsupported file type:", ext, "- Please upload .xlsx, .xls, .sav, .dta, .csv or .parquet"),
          type = "error",
          duration = 10
        )
        return(NULL)
      }

      max_size <- 2 * 1024^3 # 2 GB
      if (input$file_in$size > max_size) {
        showNotification("File is too large. Maximum allowed size is 2 GB.", type = "error", duration = 10)
        return(NULL)
      }

      w$update(html = waiter_content("Parsing data..."))

      # 2. Load the data into a dataframe. xlsx is inherently slow (XML) and
      # kept for convenience; for 1 GB-class extracts CSV (multi-threaded
      # fread) and Parquet (columnar, ~5-10x smaller to upload) are the fast
      # paths.
      df <- read_import_file(input$file_in$datapath, ext)

      w$update(html = waiter_content("Building summary..."))
      return(df)
    })

    # 3. Simple feedback for the user
    output$status <- renderUI({
      req(raw_data())
      span(class = "text-success", "File loaded.")
    })

    # 4. CRITICAL: Return the reactive object
    # Logic to render the table ONLY if display is TRUE

    # Only render this output if the display argument is TRUE
    if (display) {
      output$data_summary <- renderUI({
        req(raw_data())
        df <- raw_data()

        # Metrics
        n_rows   <- format(nrow(df), big.mark = ",")
        n_cols   <- format(ncol(df), big.mark = ",")
        mem_size <- format(object.size(df), units = "auto")

        # Simplified Type Summary
        col_types <- table(sapply(df, function(x) class(x)[1]))
        type_summary <- paste(names(col_types), col_types, sep = ": ", collapse = " | ")

        tagList(
          bslib::layout_column_wrap(
            width = 1/3, fill = FALSE,
            bslib::value_box(title = span("Observations", class = "small"),
                             value = span(n_rows, class = "fs-5"),
                             showcase = bsicons::bs_icon("database", size = "1.2rem"),
                             theme = "primary",
                             class = "p-2"
            ),
            bslib::value_box(title = span("Variables", class = "small"),
                             value = span(n_cols, class = "fs-5"),
                             showcase = bsicons::bs_icon("columns-gap", size = "1.2rem"),
                             theme = "secondary",
                             class = "p-2"
            ),
            bslib::value_box(title = span("Memory Impact", class = "small"),
                             value = span(mem_size, class = "fs-5"),
                             showcase = bsicons::bs_icon("cpu", size = "1.2rem"),
                             theme = "info",
                             class = "p-2"
            )
          ),
          bslib::card(
            bslib::card_header("File Composition"),
            bslib::card_body(
              class = "text-center",
              tags$p(strong("Column Type Breakdown:")),
              tags$code(type_summary, style = "font-size: 1.1rem; color: #5b6b7e;")
            )
          )
        )
      })
    }

    return(raw_data)
  })
}

## To be copied in the UI
# mod_file_import_ui("file_import_1")

## To be copied in the server
# mod_file_import_server("file_import_1")
