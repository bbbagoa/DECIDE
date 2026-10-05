#' Data Quality Module UI
#'
#' Thin orchestrator: renders the shared sidebar filter and composes the six
#' Data-Quality sub-tabs (each defined in its own mod_dq_*.R file).
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_dq_ui <- function(id) {
  ns <- NS(id)
  tagList(
      bslib::nav_panel(
        value = "dq_panel",
        title = "Data Quality",
        icon = icon("check-double"),
        bslib::layout_sidebar(
          fillable = FALSE,
          sidebar = bslib::sidebar(
            width = 300, class = "wfp-side",
            side_steps(
              side_step("1. Areas", "geo-alt",
                shinyWidgets::pickerInput(
                  inputId = ns("dq_filter_adm1"), label = "Admin 1", choices = character(0), multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE, size = 10)),
                shinyWidgets::pickerInput(
                  inputId = ns("dq_filter_adm2"), label = "Admin 2", choices = character(0), multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE, size = 10)),
                shinyWidgets::pickerInput(
                  inputId = ns("dq_filter_adm3"), label = "Admin 3", choices = character(0), multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE, size = 10))),
              side_step("2. Interview dates", "calendar-range",
                shinyWidgets::airDatepickerInput(
                  ns("dq_filter_date"), label = NULL, range = TRUE, autoClose = TRUE, dateFormat = "dd/MM/yyyy",
                  placeholder = "All dates", width = "100%", addon = "none"))),
            side_actions(
              tags$div(
                class = "d-flex gap-2",
                actionButton(ns("btn_apply_dq_filters"), "Apply", class = "btn-primary btn-sm flex-fill", icon = icon("filter")),
                actionButton(ns("btn_clear_dq_filters"), label = NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm",
                             title = "Clear the filters")),
              downloadButton(ns("dq_report"), "Data quality report (HTML)", class = "btn-outline-primary btn-sm w-100",
                             icon = icon("file-lines")),
              actionButton(ns("btn_reset_data"), "Reset to original data", class = "btn-outline-danger btn-sm w-100",
                           icon = icon("rotate-left")),
              tags$div(class = "wfp-sb-note", textOutput(ns("dq_filtered_rows"))))
          ),

          # Main Content

          # 2. SUB-TABS (Bottom)
          bslib::navset_tab(
            id = ns("dq_tabs"),

            # Each sub-tab is rendered by its own UI helper (see mod_dq_*.R);
            # the health check comes first: what needs attention, and where
            dq_health_ui(ns),
            dq_spelling_ui(ns),
            dq_location_ui(ns),
            dq_missing_ui(ns),
            dq_outliers_ui(ns),
            dq_duplicates_ui(ns),
            dq_enumerator_ui(ns)
          ) # closes navset_tab
        ) # closes layout_sidebar
      ),
  )
}
#' Data Quality Module Server
#'
#' Thin orchestrator: builds the shared filter pipeline and `core`, then
#' delegates each sub-tab's server logic to its mod_dq_*.R helper.
#'
#' @param id module id
#' @param uploaded_df reactive data
#' @param user_setup reactive values
#' @param modification_log reactiveVal for audit trail
#' @param original_df reactiveVal holding the originally imported data (Reset)
#' @import shiny
#' @noRd
mod_dq_server <- function(id, uploaded_df, user_setup, modification_log, original_df = reactiveVal(NULL),
                          workspace = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

  #  ------------------- Data Quality Panel Server Side
  ## -----------------------------------------------------------------------------------

  #------------ First lets filter the DQ Panel Data

  # Applied DQ filter state
  applied_dq_filters <- reactiveValues(
    admin1 = NULL,
    admin2 = NULL,
    admin3 = NULL,
    date = NULL
  )

  # Applied missing-data analysis state
  applied_missing <- reactiveValues(
    vars = NULL,
    geo_level = "Admin 1"
  )

  # --- STEP 1: Populate Admin choices and date range ---
  observe({
    req(uploaded_df())

    # Admin choices: cascade_pickers() below.

    if (shiny::isTruthy(user_setup$date)) {
      all_dates <- as.Date(uploaded_df()[[user_setup$date]])
      d_min <- min(all_dates, na.rm = TRUE)
      d_max <- max(all_dates, na.rm = TRUE)
      shinyWidgets::updateAirDateInput(
        session,
        "dq_filter_date",
        value = c(d_min, d_max),
        options = list(minDate = d_min, maxDate = d_max)
      )
      applied_dq_filters$date <- c(d_min, d_max)
    }

    # Corrections change the data too: keep the applied areas that still exist.
    for (lvl in c("admin1", "admin2", "admin3")) {
      col <- user_setup[[lvl]]
      a <- isolate(applied_dq_filters[[lvl]])
      if (length(a)) applied_dq_filters[[lvl]] <- if (shiny::isTruthy(col) && col %in% names(uploaded_df()))
        intersect(a, unique(as.character(uploaded_df()[[col]]))) else NULL
    }
  })

  # --- STEP 2: each admin level lists only the areas inside those picked above ---
  # The pickers carry the mapped column names ("Province"), as the data does.
  observe({
    for (k in 1:3) {
      col <- as.character(user_setup[[paste0("admin", k)]] %||% "")[1]
      lab <- if (is.na(col) || !nzchar(col)) sprintf("Admin %d", k) else col
      shinyWidgets::updatePickerInput(session, paste0("dq_filter_adm", k), label = paste0(lab, ":"))
    }
  })

  cascade_pickers(session, input, c("dq_filter_adm1", "dq_filter_adm2", "dq_filter_adm3"),
                  cols = reactive(vapply(c("admin1", "admin2", "admin3"), function(l) as.character(user_setup[[l]] %||% "")[1], character(1))),
                  data = uploaded_df)

  # --- Apply DQ Filters ---
  observeEvent(input$btn_apply_dq_filters, {
    waiter::waiter_show(
      html = waiter_content("Filtering the data-quality view\u2026"),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    applied_dq_filters$admin1 <- input$dq_filter_adm1
    applied_dq_filters$admin2 <- input$dq_filter_adm2
    applied_dq_filters$admin3 <- input$dq_filter_adm3
    applied_dq_filters$date <- input$dq_filter_date
    showNotification("DQ filters applied.", type = "message")
  })

  # --- Clear DQ Filters ---
  observeEvent(input$btn_clear_dq_filters, {
    waiter::waiter_show(
      html = waiter_content("Clearing the filters\u2026"),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    for (id in c("dq_filter_adm1", "dq_filter_adm2", "dq_filter_adm3")) {
      shinyWidgets::updatePickerInput(session, id, selected = character(0))
    }
    if (shiny::isTruthy(user_setup$date)) {
      all_dates <- as.Date(uploaded_df()[[user_setup$date]])
      shinyWidgets::updateAirDateInput(session, "dq_filter_date", value = c(min(all_dates, na.rm = TRUE), max(all_dates, na.rm = TRUE)))
    }
    applied_dq_filters$admin1 <- NULL
    applied_dq_filters$admin2 <- NULL
    applied_dq_filters$admin3 <- NULL
    if (shiny::isTruthy(user_setup$date)) {
      applied_dq_filters$date <- c(min(as.Date(uploaded_df()[[user_setup$date]]), na.rm = TRUE), max(as.Date(uploaded_df()[[user_setup$date]]), na.rm = TRUE))
    }
    showNotification("DQ filters cleared.", type = "message")
  })

  # --- STEP 4: The Master Filtered Data ---
  dq_filtered_data <- reactive({
    req(uploaded_df())
    df <- uploaded_df()

    if (shiny::isTruthy(user_setup$admin1) && shiny::isTruthy(applied_dq_filters$admin1)) {
      df <- df[df[[user_setup$admin1]] %in% applied_dq_filters$admin1, ]
    }
    if (shiny::isTruthy(user_setup$admin2) && shiny::isTruthy(applied_dq_filters$admin2)) {
      df <- df[df[[user_setup$admin2]] %in% applied_dq_filters$admin2, ]
    }
    if (shiny::isTruthy(user_setup$admin3) && shiny::isTruthy(applied_dq_filters$admin3)) {
      df <- df[df[[user_setup$admin3]] %in% applied_dq_filters$admin3, ]
    }
    if (shiny::isTruthy(user_setup$date) && shiny::isTruthy(applied_dq_filters$date)) {
      df <- filter_by_date_range(df, user_setup$date, applied_dq_filters$date)
    }

    return(df)
  })

  ## Number of DQ filtered rows

  output$dq_filtered_rows <- renderText({
    req(dq_filtered_data())
    paste(format(nrow(dq_filtered_data()), big.mark = ","), "filtered records")
  })

  # --------------- Filter End

  # ---------------------------------------------------------------------------
  # Shared reactive state handed to every sub-tab. Each sub-server aliases these
  # names locally so its verbatim body reads identically to the original.
  # ---------------------------------------------------------------------------
  # One record of every check, on the data in scope (Data quality report).
  output$dq_report <- download_handler(
    filename = function() export_file_name("Data_quality_report", "html", "%Y-%m-%d_%Hh%M"),
    content = function(file) {
      df <- dq_filtered_data()
      req(df)
      setup <- reactiveValuesToList(user_setup)
      x <- tw_step("check completeness, duplicates, outliers, GPS, names and enumerators",
                   dq_report_data(df, setup, modification_log()))
      f <- reactiveValuesToList(applied_dq_filters)
      lv <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3")
      scope <- unlist(lapply(names(lv), function(k) if (length(f[[k]])) paste0(lv[[k]], ": ", paste(f[[k]], collapse = ", "))))
      if (length(f$date) == 2) scope <- c(scope, paste("dates", paste(format(as.Date(f$date)), collapse = " to ")))
      x$scope <- if (length(scope)) paste(scope, collapse = "; ") else "All areas"
      x$country_office <- user_setup$country_office
      x$variables_md <- variables_md(unlist(x$mapped), session)
      lang <- session$rootScope()$input$lang_selector
      tw_step("write the report", write_dq_report(file, x, lang = if (identical(lang, "fr")) "fr" else "en"))
      audit_add(modification_log, "Selection", "Data quality report exported", sprintf("%s records", format(nrow(df), big.mark = ",")))
    }
  )

  core <- list(
    dq_filtered_data = dq_filtered_data,
    uploaded_df      = uploaded_df,
    user_setup       = user_setup,
    modification_log = modification_log,
    applied_missing  = applied_missing,
    workspace        = workspace
  )

  # Saved with the session: the filters and the missing-data analysis that
  # were applied (each sub-tab registers its own settings).
  workspace_register(workspace, "dq",
    snapshot = function() {
      if (is.null(uploaded_df())) return(NULL)
      list(filters = reactiveValuesToList(applied_dq_filters), missing = reactiveValuesToList(applied_missing))
    },
    restore = function(s) {
      after_flush(session, function() {
        for (k in names(s$filters)) applied_dq_filters[[k]] <- s$filters[[k]]
        for (k in names(s$missing)) applied_missing[[k]] <- s$missing[[k]]
        for (lvl in c("admin1", "admin2", "admin3")) {
          shinyWidgets::updatePickerInput(session, paste0("dq_filter_adm", substr(lvl, 6, 6)),
                                          selected = s$filters[[lvl]] %||% character(0))
        }
        if (length(s$missing$vars)) shinyWidgets::updatePickerInput(session, "mandatory_vars", selected = s$missing$vars)
      })
    })

  # --- Delegate each sub-tab's logic to its own helper (mod_dq_*.R) ---
  dq_health_server(input, output, session, ns, core)
  dq_spelling_server(input, output, session, ns, core)
  dq_location_server(input, output, session, ns, core)
  dq_missing_server(input, output, session, ns, core)
  dq_outliers_server(input, output, session, ns, core)
  dq_duplicates_server(input, output, session, ns, core)
  dq_enumerator_server(input, output, session, ns, core)

  # Reset to original imported data
  observeEvent(input$btn_reset_data, {
    if (is.null(original_df()) || is.null(original_df)) {
      showNotification("No original data available to reset to.", type = "warning")
      return()
    }

    showModal(modalDialog(
      title = "Reset Data?",
      "This will discard all data quality edits and restore the originally imported dataset. Are you sure?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton(ns("confirm_reset"), "Reset", class = "btn-danger")
      ),
      easyClose = TRUE
    ))
  })

  observeEvent(input$confirm_reset, {
    waiter::waiter_show(
      html = waiter_content("Restoring the original data\u2026"),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    removeModal()
    uploaded_df(original_df())
    # Append, never replace: the reset is itself an auditable event, and
    # overwriting the log both destroyed the history and left it with fewer
    # columns than every other entry (breaking the next rbind).
    modification_log(rbind(
      modification_log(),
      data.frame(
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        uid = "(system)",
        column = "(all)",
        old_value = "modified dataset",
        new_value = "original dataset",
        action = "Reset to original data",
        user = session$user %||% "Admin",
        reason = "",
        stringsAsFactors = FALSE
      )
    ))
    showNotification("Data reset to original imported dataset.", type = "message")
  })

  })
}
