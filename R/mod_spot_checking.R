#' Spot Checking Module UI
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_spot_checking_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::layout_sidebar(
      fillable = FALSE,
      sidebar = bslib::sidebar(
        width = 300, class = "wfp-side",
        side_steps(
          side_step("1. Areas", "geo-alt",
            shinyWidgets::pickerInput(
              inputId = ns("sc_admin1"), label = "Admin 1", choices = character(0), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE)),
            shinyWidgets::pickerInput(
              inputId = ns("sc_admin2"), label = "Admin 2", choices = character(0), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE)),
            shinyWidgets::pickerInput(
              inputId = ns("sc_admin3"), label = "Admin 3", choices = character(0), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE))),
          side_step("2. Search", "search",
            textInput(ns("sc_search"), NULL, placeholder = "e.g. household ID", width = "100%"))),
        side_actions(
          tags$div(
            class = "d-flex gap-2",
            actionButton(ns("sc_apply"), "Apply", class = "btn-outline-primary btn-sm flex-fill", icon = icon("filter")),
            actionButton(ns("sc_clear"), label = NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm",
                         title = "Clear the filters")),
          tags$div(class = "wfp-sb-group", "Back-check results"),
          downloadButton(ns("verif_report"), "Verification report (HTML)", class = "btn-outline-primary btn-sm w-100",
                         icon = icon("file-lines")),
          downloadButton(ns("verif_download"), "Comparison (Excel)", class = "btn-outline-secondary btn-sm w-100",
                         icon = icon("file-excel")))
      ),
      bslib::layout_columns(
        bslib::value_box(
          title = "Population Records",
          value = textOutput(ns("sc_pop_total")),
          showcase = bsicons::bs_icon("database"),
          theme = "primary"
        ),
        bslib::value_box(
          title = "Share sampled",
          value = textOutput(ns("sc_share")),
          showcase = bsicons::bs_icon("pie-chart"),
          theme = "info"
        ),
        bslib::value_box(
          title = "Sample Size",
          value = textOutput(ns("sc_sample_n")),
          showcase = bsicons::bs_icon("list-ol"),
          theme = "secondary"
        ),
        bslib::value_box(
          title = "Back-check agreement",
          value = textOutput(ns("sc_agreement")),
          showcase = bsicons::bs_icon("check-circle"),
          theme = "success"
        ),
        col_widths = c(3, 3, 3, 3)
      ),
      uiOutput(ns("sc_pool_note")),
      # Two steps, two tabs: draw the sample to check, then verify it.
      bslib::navset_underline(
        id = ns("sc_tabs"),
        bslib::nav_panel(
          value = "sample", title = tagList(bsicons::bs_icon("list-check"), " 1. Sample for checking"),
          # How the sample is drawn, above the list it produces.
          tags$div(
            class = "wfp-oneline bg-body-tertiary rounded-3 px-3 pt-2 mt-3",
            tags$div(style = "flex: 0 1 230px;",
                     radioButtons(ns("sc_mode"), "Interview mode",
                                  choices = c("Face to face" = "face", "Remote (phone)" = "remote"), selected = "face", inline = TRUE)),
            conditionalPanel(
              condition = sprintf("input['%s'] === 'remote'", ns("sc_mode")),
              tags$div(style = "flex: 0 1 200px;",
                       selectInput(ns("sc_phone_col"), tagList("Phone column", info_tip("Only households with a valid phone number are sampled.")),
                                   choices = character(0), width = "100%"))),
            tags$div(style = "flex: 0 1 120px;",
                     numericInput(ns("sc_sample_size"), "Sample size", value = 30, min = 1, max = 100000, step = 1, width = "100%")),
            tags$div(style = "flex: 0 1 180px;",
                     selectInput(ns("sc_per_unit"), "Applies to",
                                 choices = c("The whole scope" = "all", "Each Admin 1" = "admin1", "Each Admin 2" = "admin2",
                                             "Each Admin 3" = "admin3", "Each village" = "village"),
                                 selected = "all", width = "100%")),
            tags$div(style = "flex: 0 1 230px;",
                     shinyWidgets::pickerInput(
                       inputId = ns("sc_sample_method"), label = "Method",
                       choices = c("Simple Random" = "random", "Systematic" = "systematic",
                                   "PPS (size = hh size or weight)" = "pps"),
                       selected = "random", width = "100%",
                       options = shinyWidgets::pickerOptions(container = "body"))),
            tags$div(style = "flex: 0 1 110px;",
                     numericInput(ns("sc_seed"), "Seed", value = 12345, min = 1, step = 1, width = "100%")),
            tags$div(class = "pb-3",
                     actionButton(ns("sc_draw"), "Draw sample", class = "btn-primary", icon = icon("shuffle")))
          ),
          bslib::card(
            class = "mt-3", full_screen = TRUE,
            bslib::card_header(
              tags$div(class = "d-flex justify-content-between align-items-center gap-2",
                       tags$span("Sampled households"),
                       tags$div(class = "d-flex gap-2",
                                downloadButton(ns("download_spot"), "Export sample (Excel)", class = "btn-outline-secondary btn-sm",
                                               icon = icon("file-excel")),
                                actionButton(ns("sc_go_verify"), "Continue to verification", icon = icon("arrow-right"),
                                             class = "btn-outline-primary btn-sm")))),
            tags$p(class = "small text-muted mb-2",
                   "Export this list, re-visit these households, then load what the team collected in the Verification tab."),
            DT::DTOutput(ns("spot_table"), fill = FALSE)
          )
        ),
        bslib::nav_panel(
          value = "verify", title = tagList(bsicons::bs_icon("clipboard-check"), " 2. Verification"),

      # ---------------------------------------------------------------------
      # Back-check: the sample is re-collected in the field, then compared
      # field-by-field against what was originally recorded.
      # ---------------------------------------------------------------------
      bslib::card(
        class = "mt-3", full_screen = TRUE,
        bslib::card_header(bsicons::bs_icon("clipboard-check"), " Back-check comparison"),
        bslib::card_body(
          tags$p(
            class = "text-muted small",
            "Export the sample above, re-collect those households, then load the results here to measure how far the two rounds agree."
          ),
          # Two numbered parts: where the re-collected data comes from, then
          # how the two rounds are compared; the actions close the second.
          tags$div(
            class = "wfp-vc",
            tags$div(
              class = "wfp-vc-col",
              tags$div(class = "wfp-vc-head", tags$span(class = "wfp-vc-num", "1"), "Verification data"),
              shinyWidgets::radioGroupButtons(
                ns("verif_source"), NULL,
                choices = c("File" = "file", "MODA form" = "moda"),
                selected = "file", size = "sm", status = "outline-primary"
              ),
              conditionalPanel(
                condition = sprintf("input['%s'] == 'file'", ns("verif_source")),
                fileInput(
                  ns("verif_file"), NULL,
                  accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"),
                  width = "100%", placeholder = "Re-collected households (Excel, CSV, SPSS, Stata, Parquet)"
                )
              ),
              conditionalPanel(
                condition = sprintf("input['%s'] == 'moda'", ns("verif_source")),
                tags$div(
                  class = "d-flex align-items-end gap-2",
                  tags$div(style = "flex: 1 1 110px;",
                           textInput(ns("verif_form_id"), "Form ID", placeholder = "e.g. 123456", width = "100%")),
                  tags$div(style = "flex: 1 1 160px;",
                           passwordInput(ns("verif_token"), "API key", width = "100%")),
                  tags$div(class = "wfp-vc-fetch",
                           actionButton(ns("verif_fetch"), "Fetch", class = "btn-outline-primary",
                                        icon = icon("cloud-arrow-down"))))
              ),
              uiOutput(ns("verif_status"))
            ),
            tags$div(
              class = "wfp-vc-col",
              tags$div(class = "wfp-vc-head", tags$span(class = "wfp-vc-num", "2"), "Comparison"),
              bslib::layout_columns(
                col_widths = c(4, 5, 3), fill = FALSE, gap = ".75rem",
                shinyWidgets::pickerInput(
                  ns("verif_key"), "Match records on", choices = NULL, width = "100%",
                  options = shinyWidgets::pickerOptions(liveSearch = TRUE, container = "body")
                ),
                shinyWidgets::pickerInput(
                  ns("verif_cols"), "Fields to compare", choices = NULL, multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(actionsBox = TRUE, liveSearch = TRUE, container = "body",
                                                        selectedTextFormat = "count > 2", countSelectedText = "{0} fields")
                ),
                numericInput(ns("verif_tolerance"),
                             tagList("Tolerance", info_tip("Numeric answers closer than this count as agreeing.")),
                             value = 0, min = 0, step = 0.1, width = "100%")
              ),
              tags$div(
                class = "wfp-vc-actions",
                actionButton(ns("verif_run"), "Run comparison", class = "btn-primary", icon = icon("code-compare"))
              )
            )
          ),
          uiOutput(ns("verif_hint")),
          uiOutput(ns("verif_results"))
        )
      )
        )
      )
    )
  )
}

#' Spot Checking Module Server
#'
#' @param id module id
#' @param uploaded_df reactive data
#' @param user_setup reactive values
#' @import shiny
#' @noRd
mod_spot_checking_server <- function(id, uploaded_df, user_setup, workspace = NULL) {
  moduleServer(id, function(input, output, session) {
    # moduleServer does NOT provide `ns`; server-side UI (renderUI) that builds
    # namespaced output ids needs it explicitly or it fails with
    # "could not find function \"ns\"".
    ns <- session$ns

    applied <- reactiveValues(
      admin1 = NULL, admin2 = NULL, admin3 = NULL, search = "",
      sample_size = 30, sample_method = "random", seed = 12345,
      mode = "face", phone_col = NULL, per_unit = "all"
    )

    # Saved with the session: the applied sample and the back-check. The
    # sample is seeded, so the same filters redraw the same households.
    workspace_register(workspace, "spot_checking",
      snapshot = function() if (is.null(uploaded_df())) NULL else list(
        applied = reactiveValuesToList(applied), verification = verification_df(),
        comparison = comparison(),
        inputs = list(verif_key = input$verif_key, verif_cols = input$verif_cols,
                      verif_tolerance = input$verif_tolerance)),
      restore = function(s) {
        # after the data-load observer has reset the filters
        after_flush(session, function() {
          for (k in names(s$applied)) applied[[k]] <- s$applied[[k]]
          for (lvl in c("admin1", "admin2", "admin3")) {
            shinyWidgets::updatePickerInput(session, paste0("sc_", lvl), selected = s$applied[[lvl]] %||% character(0))
          }
          updateTextInput(session, "sc_search", value = s$applied$search %||% "")
          updateNumericInput(session, "sc_sample_size", value = s$applied$sample_size)
          updateNumericInput(session, "sc_seed", value = s$applied$seed)
          shinyWidgets::updatePickerInput(session, "sc_sample_method", selected = s$applied$sample_method)
          updateRadioButtons(session, "sc_mode", selected = s$applied$mode %||% "face")
          updateSelectInput(session, "sc_per_unit", selected = s$applied$per_unit %||% "all")
          if (shiny::isTruthy(s$applied$phone_col)) updateSelectInput(session, "sc_phone_col", selected = s$applied$phone_col)
          verification_df(s$verification)
          # and after the back-check pickers have been refilled
          after_flush(session, function() {
            comparison(s$comparison)
            shinyWidgets::updatePickerInput(session, "verif_key", selected = s$inputs$verif_key)
            shinyWidgets::updatePickerInput(session, "verif_cols", selected = s$inputs$verif_cols)
            if (!is.null(s$inputs$verif_tolerance)) updateNumericInput(session, "verif_tolerance", value = s$inputs$verif_tolerance)
          })
        })
      })

    observe({
      df <- uploaded_df(); req(df)
      cols <- names(df)
      guess <- c(user_setup$phone_avail, grep("phone|tel|mobile|portable|numero", cols, ignore.case = TRUE, value = TRUE))
      guess <- intersect(guess, cols)
      updateSelectInput(session, "sc_phone_col", choices = c("Choose a column" = "", unique(c(guess, cols))),
                        selected = isolate(input$sc_phone_col) %||% if (length(guess)) guess[1] else NULL)
    })

    # Each admin level lists only the areas inside those picked above.
    cascade_pickers(session, input, c("sc_admin1", "sc_admin2", "sc_admin3"),
                    cols = reactive(vapply(c("admin1", "admin2", "admin3"), function(l) as.character(user_setup[[l]] %||% "")[1], character(1))),
                    data = uploaded_df)
    # New data: keep the applied areas that still exist, as the pickers do.
    observe({
      df <- uploaded_df(); req(df)
      for (lvl in c("admin1", "admin2", "admin3")) {
        col <- user_setup[[lvl]]
        a <- isolate(applied[[lvl]])
        if (length(a)) applied[[lvl]] <- if (shiny::isTruthy(col) && col %in% names(df))
          intersect(a, unique(as.character(df[[col]]))) else NULL
      }
    })

    observeEvent(list(input$sc_apply, input$sc_draw), ignoreInit = TRUE, {
      # React buttons send 0 at start
      req(sum(unlist(input$sc_apply), unlist(input$sc_draw)) > 0)
      waiter::waiter_show(
        html = waiter_content("Drawing the spot-check sample\u2026"),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)

      applied$admin1 <- input$sc_admin1
      applied$admin2 <- input$sc_admin2
      applied$admin3 <- input$sc_admin3
      applied$search <- input$sc_search
      applied$sample_size <- max(1, as.integer(input$sc_sample_size))
      applied$sample_method <- input$sc_sample_method
      applied$seed <- as.integer(input$sc_seed)
      applied$mode <- input$sc_mode %||% "face"
      applied$phone_col <- input$sc_phone_col
      applied$per_unit <- input$sc_per_unit %||% "all"
      showNotification("Spot check filters and sample applied.", type = "message")
    })

    observeEvent(input$sc_clear, {
      req(input$sc_clear > 0)
      waiter::waiter_show(
        html = waiter_content("Clearing the sample\u2026"),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)

      for (lvl in c("sc_admin1", "sc_admin2", "sc_admin3")) {
        shinyWidgets::updatePickerInput(session, lvl, selected = character(0))
      }
      updateTextInput(session, "sc_search", value = "")
      updateNumericInput(session, "sc_sample_size", value = 30)
      updateNumericInput(session, "sc_seed", value = 12345)
      applied$admin1 <- NULL
      applied$admin2 <- NULL
      applied$admin3 <- NULL
      applied$search <- ""
      applied$sample_size <- 30
      applied$sample_method <- "random"
      applied$seed <- 12345
      showNotification("Spot check filters cleared.", type = "message")
    })

    filtered_data <- reactive({
      req(uploaded_df())
      df <- uploaded_df()

      if (shiny::isTruthy(user_setup$admin1) && shiny::isTruthy(applied$admin1)) {
        df <- df[df[[user_setup$admin1]] %in% applied$admin1, , drop = FALSE]
      }
      if (shiny::isTruthy(user_setup$admin2) && shiny::isTruthy(applied$admin2)) {
        df <- df[df[[user_setup$admin2]] %in% applied$admin2, , drop = FALSE]
      }
      if (shiny::isTruthy(user_setup$admin3) && shiny::isTruthy(applied$admin3)) {
        df <- df[df[[user_setup$admin3]] %in% applied$admin3, , drop = FALSE]
      }

      if (shiny::isTruthy(applied$search)) {
        txt <- tolower(applied$search)
        # Column by column: apply(df, 1, ...) coerced the whole frame to a
        # character matrix, which at 1 GB is the page freezing.
        matches <- Reduce(`|`, lapply(df, function(col) grepl(txt, tolower(as.character(col)), fixed = TRUE)),
                          rep(FALSE, nrow(df)))
        df <- df[matches, , drop = FALSE]
      }

      df
    })

    # The households that can be reached: all of them face to face, only
    # those with a valid phone number for a remote check.
    sample_pool <- reactive({
      df <- filtered_data(); req(df)
      pc <- applied$phone_col
      if (identical(applied$mode, "remote")) {
        # No phone column, no remote sample: never fall back to everyone.
        keep <- if (shiny::isTruthy(pc) && pc %in% names(df)) which(valid_phone(df[[pc]])) else integer(0)
        df <- df[keep, , drop = FALSE]
      }
      df
    })

    sampled_data <- reactive({
      df <- sample_pool()
      n <- applied$sample_size
      if (!nrow(df) || !isTRUE(n > 0)) return(df[0, , drop = FALSE])

      # A blank seed used to leave the RNG untouched, so the sample was
      # re-drawn on every invalidation and the list the team went to the field
      # with no longer matched. Always seed; fall back to the default.
      seed <- applied$seed
      set.seed(if (is.na(seed)) 12345L else seed)

      draw <- function(d, k) {
        k <- min(k, nrow(d))
        if (k <= 0) return(integer(0))
        switch(applied$sample_method,
               "systematic" = sample_systematic(nrow(d), k),
               "pps" = sample_pps(d, k, user_setup),
               sample_random(nrow(d), k))
      }
      # "Sample size applies to" a level: the same number in every unit.
      unit_col <- if (!identical(applied$per_unit %||% "all", "all")) user_setup[[applied$per_unit]] else NULL
      if (shiny::isTruthy(unit_col) && unit_col %in% names(df)) {
        groups <- split(seq_len(nrow(df)), as.character(df[[unit_col]]))
        idx <- sort(unlist(lapply(groups, function(g) g[draw(df[g, , drop = FALSE], n)]), use.names = FALSE))
      } else {
        idx <- draw(df, n)
      }
      df[idx, , drop = FALSE]
    })

    output$sc_pool_note <- renderUI({
      if (!identical(applied$mode, "remote")) return(NULL)
      tot <- nrow(filtered_data()); ok <- nrow(sample_pool())
      if (!shiny::isTruthy(applied$phone_col)) {
        return(tags$div(class = "alert alert-warning mt-2", bsicons::bs_icon("telephone-x"),
                        " Remote check: choose the column holding the phone numbers in the sidebar, then Apply."))
      }
      tags$div(class = "wfp-norm-bar mt-2", bsicons::bs_icon("telephone"),
               sprintf(" Remote check: %s of %s households in scope have a valid phone number in %s.",
                       format(ok, big.mark = ","), format(tot, big.mark = ","), applied$phone_col %||% "?"))
    })

    output$sc_pop_total <- renderText({
      req(sample_pool())
      format(nrow(sample_pool()), big.mark = ",")
    })

    output$sc_share <- renderText({
      req(sample_pool(), sampled_data())
      n <- nrow(sample_pool())
      if (!n) "\u2014" else sprintf("%.1f%%", 100 * nrow(sampled_data()) / n)
    })

    observeEvent(input$sc_go_verify, { req(input$sc_go_verify > 0); bslib::nav_select("sc_tabs", "verify", session = session) })

    output$sc_sample_n <- renderText({
      need_ok(!is.null(tryCatch(sampled_data(), error = function(e) NULL)), "Draw the spot-check sample first.")
      req(sampled_data())
      format(nrow(sampled_data()), big.mark = ",")
    })

    output$sc_agreement <- renderText({
      r <- comparison()
      if (is.null(r) || is.na(r$overall_agreement)) "\u2014" else sprintf("%.1f%%", 100 * r$overall_agreement)
    })

    # Identification columns only; everything else is behind Details.
    output$spot_table <- render_react_table({
      req(sampled_data())
      record_table(sampled_data(), user_setup, session$ns, "spot_view")
    }, html = "Details", labels = list(Details = ""), empty = "No household in the sample: widen the areas or the search, then draw again.")

    observeEvent(input$spot_view, {
      showModal(record_detail_modal(
        find_record(sampled_data(), user_setup, input$spot_view),
        title = paste("Sampled record:", input$spot_view)
      ))
    })

    # How the sample was drawn, in words: used by the exports and the report.
    sample_description <- function() {
      methods <- c(random = "Simple random", systematic = "Systematic", pps = "PPS (size = household size or weight)")
      flt <- c(if (length(applied$admin1)) paste("Admin 1:", paste(applied$admin1, collapse = ", ")),
               if (length(applied$admin2)) paste("Admin 2:", paste(applied$admin2, collapse = ", ")),
               if (length(applied$admin3)) paste("Admin 3:", paste(applied$admin3, collapse = ", ")),
               if (shiny::isTruthy(applied$search)) paste0("search \"", applied$search, "\""))
      per <- applied$per_unit %||% "all"
      c("Method" = methods[[applied$sample_method %||% "random"]],
        "Interview mode" = if (identical(applied$mode, "remote"))
          sprintf("Remote (phone): only valid numbers in %s", applied$phone_col %||% "?") else "Face to face",
        "Sample size" = if (identical(per, "all")) sprintf("%s households", applied$sample_size)
                        else sprintf("%s households per %s", applied$sample_size, per),
        "Random seed" = as.character(applied$seed),
        "Filters" = if (length(flt)) paste(flt, collapse = "; ") else "none")
    }

    # The sample as a field-ready workbook: how it was drawn, then the list
    # with the identification columns first and blank columns for the team.
    output$download_spot <- download_handler(
      filename = function() export_file_name("Targeting_SpotCheck", "xlsx", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        smp <- sampled_data()
        pool <- sample_pool()
        keys <- c("unique_id", "admin1", "admin2", "admin3", "admin4", "village", "hh_size", "hhh_sex")
        id_cols <- unique(unlist(lapply(keys, function(k) { cl <- user_setup[[k]]; if (shiny::isTruthy(cl) && cl %in% names(smp)) cl })))
        if (identical(applied$mode, "remote") && shiny::isTruthy(applied$phone_col) && applied$phone_col %in% names(smp)) {
          id_cols <- unique(c(id_cols, applied$phone_col))
        }
        smp <- smp[, c(id_cols, setdiff(names(smp), id_cols)), drop = FALSE]
        field <- c("Visited (yes/no)", "Date of visit", "Checked by", "Comments")
        for (f in field) smp[[f]] <- NA_character_
        smp <- smp[, c(id_cols, field, setdiff(names(smp), c(id_cols, field))), drop = FALSE]

        wb <- openxlsx::createWorkbook()
        xl_summary_sheet(wb, "Summary", "Spot-check sample",
                         paste(c(user_setup$country_office, fmt_date()), collapse = " \u00b7 "),
                         list(
                           "Sample" = c(
                             "Country office" = user_setup$country_office %||% "not set",
                             "Exported" = fmt_datetime(),
                             "Exported by" = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
                             sample_description(),
                             "Households in scope" = format(nrow(pool), big.mark = ","),
                             "Households sampled" = format(nrow(smp), big.mark = ","),
                             "Share sampled" = if (nrow(pool)) sprintf("%.1f%%", 100 * nrow(smp) / nrow(pool)) else "n/a"),
                           "For the field team" = c(
                             "What to do" = "Re-visit (or call) each household, fill in the four highlighted columns, and re-ask the questions to verify.",
                             "Back-check" = "Load what the team collected in Spot Checking > Verification to measure how far the two rounds agree.",
                             "Keep" = "Do not change the household identifier: the comparison matches on it.")))
        xl_data_sheet(wb, "Sample", sanitize_for_excel(smp))
        # the columns the team fills in stand out
        fcols <- match(field, names(smp))
        openxlsx::addStyle(wb, "Sample", openxlsx::createStyle(fontSize = 10, textDecoration = "bold", fontColour = "#1F2A37",
                                                               fgFill = "#F7B825", border = "bottom", borderColour = "#B88600"),
                           rows = 1, cols = fcols, gridExpand = TRUE)
        if (nrow(smp)) {
          openxlsx::addStyle(wb, "Sample", openxlsx::createStyle(fontSize = 10, fgFill = "#FFF8E1"),
                             rows = 2:(nrow(smp) + 1), cols = fcols, gridExpand = TRUE)
        }
        openxlsx::setColWidths(wb, "Sample", cols = fcols, widths = c(16, 14, 16, 36))
        save_workbook_readonly(wb, file)
      }
    )

    # -----------------------------------------------------------------------
    # Back-check comparison
    # -----------------------------------------------------------------------
    verification_df <- reactiveVal(NULL)
    verif_source <- reactiveVal(NA_character_)
    comparison <- reactiveVal(NULL)

    # --- Source A: uploaded file ---
    observeEvent(input$verif_file, {
      req(input$verif_file)
      ext <- tolower(tools::file_ext(input$verif_file$name))
      if (!ext %in% c("xlsx", "xls", "sav", "dta", "csv", "parquet")) {
        showNotification(paste("Unsupported file type:", ext), type = "error", duration = 10)
        return()
      }
      w <- waiter::Waiter$new(html = waiter_content("Reading verification data..."),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show()
      on.exit(w$hide(), add = TRUE)

      df <- tryCatch(
        read_import_file(input$verif_file$datapath, ext),
        error = function(e) {
          showNotification(paste("Could not read file:", conditionMessage(e)), type = "error", duration = 10)
          NULL
        }
      )
      req(df)
      verification_df(df)
      verif_source(sprintf("file %s", input$verif_file$name))
      comparison(NULL)
    })

    # The key entered for an earlier MODA import is filled in.
    observeEvent(input$verif_source, {
      k <- api_key_get(session, "moda")
      if (identical(input$verif_source, "moda") && !is.null(k) && !shiny::isTruthy(input$verif_token))
        updateTextInput(session, "verif_token", value = k)
    })

    # --- Source B: a second MODA form ---
    observeEvent(input$verif_fetch, {
      req(input$verif_fetch > 0)
      token <- if (shiny::isTruthy(input$verif_token)) input$verif_token else api_key_get(session, "moda")
      if (!shiny::isTruthy(input$verif_form_id) || !shiny::isTruthy(token)) {
        showNotification("Enter both the verification Form ID and the API key.", type = "warning")
        return()
      }
      api_key_set(session, token, "moda")
      moda_async_fetch(
        form_id = input$verif_form_id,
        token = token,
        existing_df = NULL,
        page_size = MODA_PAGE_SIZE,
        session = session,
        on_success = function(result) {
          verification_df(result$df)
          verif_source(sprintf("MODA form %s", input$verif_form_id))
          comparison(NULL)
          showNotification(
            paste0(format(nrow(result$df), big.mark = ","), " verification records downloaded."),
            type = "message"
          )
        },
        on_error = function(msg) showNotification(paste("MODA:", msg), type = "error", duration = 12)
      )
    })

    # Before the re-collected data arrives, the key already shows the
    # household id of the sample, so the user sees what records match on.
    observe({
      req(is.null(verification_df()))
      s <- tryCatch(sampled_data(), error = function(e) NULL)
      req(s)
      uid <- user_setup$unique_id
      if (shiny::isTruthy(uid) && uid %in% names(s)) {
        shinyWidgets::updatePickerInput(session, "verif_key", choices = names(s), selected = uid)
      }
    })

    # The back-check exports wait for a comparison.
    observe({
      ok <- !is.null(comparison())
      gate_button("verif_report", ok, "Run the comparison first.")
      gate_button("verif_download", ok, "Run the comparison first.")
    })

    # Refresh the key / field pickers whenever either side changes
    observe({
      v <- verification_df()
      s <- tryCatch(sampled_data(), error = function(e) NULL)
      req(v, s)
      shared <- intersect(names(s), names(v))
      req(length(shared) > 0)

      uid <- user_setup$unique_id
      key_default <- if (shiny::isTruthy(uid) && uid %in% shared) uid else shared[1]
      shinyWidgets::updatePickerInput(session, "verif_key", choices = shared, selected = key_default)
      shinyWidgets::updatePickerInput(
        session, "verif_cols",
        choices = setdiff(shared, key_default),
        selected = setdiff(shared, key_default)
      )
    })

    output$verif_status <- renderUI({
      v <- verification_df()
      if (is.null(v)) return(NULL)
      s <- tryCatch(sampled_data(), error = function(e) NULL)
      shared <- if (is.null(s)) character(0) else intersect(names(s), names(v))
      ok <- length(shared) > 0
      tags$div(
        class = paste("small mb-1", if (ok) "text-success" else "text-danger"),
        bsicons::bs_icon(if (ok) "check-circle-fill" else "exclamation-triangle-fill"), " ",
        sprintf("%s records loaded; %d column%s in common with the sample.", format(nrow(v), big.mark = ","),
                length(shared), if (length(shared) == 1) "" else "s")
      )
    })

    observeEvent(input$verif_run, {
      req(input$verif_run > 0)
      v <- verification_df()
      if (is.null(v)) {
        showNotification("Load the verification data first.", type = "warning")
        return()
      }
      s <- sampled_data()
      req(nrow(s) > 0, input$verif_key)

      w <- waiter::Waiter$new(html = waiter_content("Comparing rounds..."),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show()
      on.exit(w$hide(), add = TRUE)

      tol <- suppressWarnings(as.numeric(input$verif_tolerance))
      if (is.na(tol) || tol < 0) tol <- 0

      res <- compare_verification(
        original = s,
        verification = v,
        key_col = input$verif_key,
        cols = input$verif_cols,
        numeric_tolerance = tol
      )
      if (is.null(res)) {
        showNotification("The chosen key column is not present in both datasets.", type = "error")
        return()
      }
      comparison(res)
      if (res$matched_n == 0) {
        showNotification(
          "No households matched on the chosen key. Check that the verification round carries the same identifier.",
          type = "warning", duration = 12
        )
      } else {
        showNotification("Back-check comparison complete.", type = "message")
      }
    })

    output$verif_hint <- renderUI({
      if (is.null(verification_df())) {
        return(empty_state(
          "No verification data yet",
          "Upload the re-collected dataset, or fetch the verification form from MODA, then run the comparison.",
          icon = "clipboard-check"
        ))
      }
      if (is.null(comparison())) {
        return(empty_state(
          "Ready to compare",
          "Confirm the matching key and the fields to compare, then click Run comparison.",
          icon = "code-slash"
        ))
      }
      NULL
    })

    output$verif_results <- renderUI({
      req(comparison())
      tagList(
        hr(),
        bslib::layout_columns(
          bslib::value_box(title = "Matched Records", value = textOutput(ns("verif_matched")),
                           showcase = bsicons::bs_icon("link"), theme = "primary"),
          bslib::value_box(title = "Overall Agreement", value = textOutput(ns("verif_agreement")),
                           showcase = bsicons::bs_icon("check2-circle"), theme = "success"),
          bslib::value_box(title = "Records w/ Discordance", value = textOutput(ns("verif_bad_records")),
                           showcase = bsicons::bs_icon("exclamation-triangle"), theme = "warning"),
          bslib::value_box(title = "Unmatched", value = textOutput(ns("verif_unmatched")),
                           showcase = bsicons::bs_icon("question-circle"), theme = "secondary"),
          col_widths = c(3, 3, 3, 3)
        ),
        bslib::layout_columns(
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Agreement by field"),
            plotly::plotlyOutput(ns("verif_plot"), height = "340px")
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Field summary"),
            DT::DTOutput(ns("verif_field_table"), fill = FALSE)
          ),
          col_widths = c(6, 6)
        ),
        bslib::card(
          full_screen = TRUE,
          bslib::card_header("Discordances"),
          DT::DTOutput(ns("verif_disc_table"), fill = FALSE)
        )
      )
    })

    output$verif_matched <- renderText({
      r <- comparison(); if (is.null(r)) "\u2014" else format(r$matched_n, big.mark = ",")
    })
    output$verif_agreement <- renderText({
      r <- comparison()
      if (is.null(r) || is.na(r$overall_agreement)) "\u2014" else paste0(round(r$overall_agreement * 100, 1), "%")
    })
    output$verif_bad_records <- renderText({
      r <- comparison(); if (is.null(r)) "\u2014" else format(r$records_with_discordance, big.mark = ",")
    })
    output$verif_unmatched <- renderText({
      r <- comparison()
      if (is.null(r)) "\u2014" else format(r$only_original_n + r$only_verification_n, big.mark = ",")
    })

    output$verif_plot <- render_echart({
      r <- comparison(); req(r, nrow(r$field_summary) > 0)
      verification_field_chart(r$field_summary)
    })

    output$verif_field_table <- render_react_table({
      r <- comparison(); req(r)
      fs <- r$field_summary
      req(nrow(fs) > 0)
      data.frame(
        Field = fs$variable,
        Compared = fs$compared,
        Agree = fs$agree,
        Disagree = fs$disagree,
        Agreement = fs$agreement_rate,
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
    }, page_size = 10, formats = list(Compared = "int", Agree = "int", Disagree = "int", Agreement = "pct1"),
    # the reading of the agreement: below 90%, 90-95%, 95% or more
    styles = list(Agreement = list(breaks = c(0.89999, 0.94999), colors = c("#f8d7da", "#fff3cd", "#d4edda"),
                                   text = c("#842029", "#664d03", "#0f5132"))))

    output$verif_disc_table <- render_react_table({
      r <- comparison(); req(r)
      out <- r$discordances
      colnames(out) <- c(r$key_col, "Field", "Original round", "Verification round")
      out
    }, page_size = 15, empty = "No discordances found on the compared fields.")

    # ---- The React page (react/src/pages/spot/): facts as JSON -----------------
    # The figures the Shiny page wrote with textOutput() / renderUI(), from the
    # same reactives.
    safe <- function(expr) tryCatch(expr, error = function(e) NULL)
    output$sc_kpis <- shinyreact::reactive_output({
      pool <- safe(sample_pool()); smp <- safe(sampled_data()); r <- comparison()
      fmt <- function(n) format(n, big.mark = ",")
      remote <- identical(applied$mode, "remote")
      list(pool = if (is.null(pool)) NULL else fmt(nrow(pool)),
           share = if (is.null(pool) || is.null(smp)) NULL else if (!nrow(pool)) "\u2014" else sprintf("%.1f%%", 100 * nrow(smp) / nrow(pool)),
           sample = if (is.null(smp)) NULL else fmt(nrow(smp)),
           agreement = if (is.null(r) || is.na(r$overall_agreement)) NULL else sprintf("%.1f%%", 100 * r$overall_agreement),
           remote = remote, phone_col = applied$phone_col %||% "",
           in_scope = if (remote) safe(fmt(nrow(filtered_data()))),
           reachable = if (remote && !is.null(pool)) fmt(nrow(pool)))
    })
    output$verif_state <- shinyreact::reactive_output({
      v <- verification_df(); r <- comparison()
      s <- safe(sampled_data())
      shared <- if (is.null(v) || is.null(s)) character(0) else intersect(names(s), names(v))
      fmt <- function(n) format(n, big.mark = ",")
      src <- verif_source()
      list(loaded = !is.null(v), n = if (is.null(v)) "0" else fmt(nrow(v)), source = if (is.na(src)) "" else src,
           shared = length(shared), compared = !is.null(r),
           kpis = if (!is.null(r)) list(
             matched = fmt(r$matched_n),
             agreement = if (is.na(r$overall_agreement)) "\u2014" else paste0(round(r$overall_agreement * 100, 1), "%"),
             discordant = fmt(r$records_with_discordance),
             unmatched = fmt(r$only_original_n + r$only_verification_n),
             only_original = fmt(r$only_original_n), only_verification = fmt(r$only_verification_n),
             fields = length(r$cols), key = r$key_col))
    })
    # the file input stays Shiny's
    output$verif_file_ui <- renderUI(fileInput(
      ns("verif_file"), NULL, accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"),
      width = "100%", placeholder = "Re-collected households (Excel, CSV, SPSS, Stata, Parquet)"))

    # Where the discordances sit (enumerator, areas) and what changes: for the
    # report and the workbook.
    verif_insights <- function() {
      r <- comparison()
      if (is.null(r)) return(NULL)
      col <- function(k) { v <- as.character(user_setup[[k]] %||% "")[1]; if (is.na(v)) "" else v }
      groups <- c(Enumerator = col("enumerator_id"), "Admin 1" = col("admin1"), "Admin 2" = col("admin2"))
      orig <- sampled_data()
      ver <- verification_df()
      matched <- if (!is.null(orig) && !is.null(ver) && r$key_col %in% names(orig) && r$key_col %in% names(ver))
        intersect(as.character(orig[[r$key_col]]), as.character(ver[[r$key_col]]))
      tryCatch(verification_insights(r, orig, groups[nzchar(groups)], matched = matched), error = function(e) NULL)
    }

    output$verif_report <- download_handler(
      filename = function() export_file_name("Verification_report", "html", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        methods <- c(random = "Simple random", systematic = "Systematic", pps = "PPS (size = household size or weight)")
        flt <- c(if (length(applied$admin1)) paste("Admin 1:", paste(applied$admin1, collapse = ", ")),
                 if (length(applied$admin2)) paste("Admin 2:", paste(applied$admin2, collapse = ", ")),
                 if (length(applied$admin3)) paste("Admin 3:", paste(applied$admin3, collapse = ", ")),
                 if (shiny::isTruthy(applied$search)) paste0("search \"", applied$search, "\""))
        lang <- session$rootScope()$input$lang_selector
        write_verification_report(file, list(
          country_office = user_setup$country_office,
          sample = list(method = paste0(methods[[applied$sample_method %||% "random"]],
                                        if (identical(applied$mode, "remote")) sprintf(", remote (phone, valid numbers in %s)", applied$phone_col) else ", face to face",
                                        if (!identical(applied$per_unit %||% "all", "all")) sprintf(", %s per %s", applied$sample_size, applied$per_unit) else ""),
                        n = nrow(sampled_data()), population = nrow(sample_pool()),
                        seed = applied$seed, filters = if (length(flt)) paste(flt, collapse = "; ") else "none"),
          source = verif_source(), n_verification = if (is.null(verification_df())) NA else nrow(verification_df()),
          tolerance = input$verif_tolerance, comparison = comparison(), insights = verif_insights(),
          variables_md = if (!is.null(comparison())) variables_md(comparison()$cols, session)),
          lang = if (identical(lang, "fr")) "fr" else "en")
      }
    )

    output$verif_download <- download_handler(
      filename = function() export_file_name("Targeting_BackCheck", "xlsx", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        r <- comparison()
        wb <- openxlsx::createWorkbook()
        pct <- function(v) if (is.null(v) || is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
        sections <- list("Sample" = c("Country office" = user_setup$country_office %||% "not set",
                                      "Exported" = fmt_datetime(),
                                      sample_description(),
                                      "Households sampled" = format(nrow(sampled_data()), big.mark = ",")))
        if (is.null(r)) {
          sections[["Comparison"]] <- c("Status" = "No comparison has been run yet.")
        } else {
          sections[["Comparison"]] <- c(
            "Verification data" = verif_source() %||% "n/a",
            "Matched on" = r$key_col,
            "Households matched" = format(r$matched_n, big.mark = ","),
            "Sampled but not re-visited" = format(r$only_original_n, big.mark = ","),
            "Re-visited but not in the sample" = format(r$only_verification_n, big.mark = ","),
            "Fields compared" = as.character(length(r$cols)),
            "Numeric tolerance" = fmt5(input$verif_tolerance %||% 0),
            "Overall agreement" = pct(r$overall_agreement),
            "Households with a discordance" = sprintf("%s (%s of matched)", format(r$records_with_discordance, big.mark = ","),
                                                      pct(r$records_with_discordance / max(1, r$matched_n))))
          sections[["Reading the agreement"]] <- c("95% or more" = "sound",
                                                   "90-95%" = "look at how the question is asked",
                                                   "Below 90%" = "follow up with the enumerators")
        }
        xl_summary_sheet(wb, "Summary", "Spot-check back-check",
                         paste(c(user_setup$country_office, fmt_date()), collapse = " \u00b7 "), sections)
        if (!is.null(r)) {
          fs <- r$field_summary
          by_field <- data.frame(Field = fs$variable, Compared = fs$compared, Agree = fs$agree, Disagree = fs$disagree,
                                 `Agreement (%)` = round(100 * fs$agreement_rate, 1), check.names = FALSE)
          xl_data_sheet(wb, "By_field", by_field)
          if (nrow(by_field)) {
            rows <- 2:(nrow(by_field) + 1)
            band <- function(rule, fill, font) openxlsx::conditionalFormatting(
              wb, "By_field", cols = 5, rows = rows, rule = rule,
              style = openxlsx::createStyle(bgFill = fill, fontColour = font))
            band(">=95", "#D4EDDA", "#0F5132"); band("<90", "#F8D7DA", "#842029")
            openxlsx::conditionalFormatting(wb, "By_field", cols = 5, rows = rows, type = "between", rule = c(90, 94.999),
                                            style = openxlsx::createStyle(bgFill = "#FFF3CD", fontColour = "#664D03"))
          }
          ins <- verif_insights()
          for (lab in names(ins$by_group)) {
            g <- ins$by_group[[lab]]
            xl_data_sheet(wb, paste0("By_", gsub("[^A-Za-z0-9]+", "_", tolower(lab))),
                          sanitize_for_excel(stats::setNames(
                            data.frame(g$group, g$households, g$with_discordance, g$discordant_answers, round(100 * g$agreement, 1)),
                            c(lab, "Households", "With a discordance", "Answers that differ", "Agreement (%)"))))
          }
          d <- r$discordances
          names(d) <- c("Household", "Field", "First round", "Back-check")[seq_along(d)]
          xl_data_sheet(wb, "Discordances", sanitize_for_excel(d))
        }
        save_workbook_readonly(wb, file)
      }
    )
  })
}

#' Simple random sample indices
#'
#' @param N Population size.
#' @param n Sample size.
#' @return Integer vector of sampled row indices.
#' @noRd
sample_random <- function(N, n) {
  if (n >= N) return(seq_len(N))
  sort(sample.int(N, size = n, replace = FALSE))
}

#' Systematic sample indices
#'
#' @param N Population size.
#' @param n Sample size.
#' @return Integer vector of sampled row indices.
#' @noRd
sample_systematic <- function(N, n) {
  if (n >= N) return(seq_len(N))
  interval <- N / n
  start <- sample(interval, 1)
  sort(unique(floor(seq(from = start, to = N, length.out = n))))
}

#' Probability-proportional-to-size sample indices
#'
#' Uses household size if mapped, otherwise the sampling weight. Falls back to
#' simple random sampling when no size information is available.
#'
#' @param df A data.frame.
#' @param n Sample size.
#' @param settings Setup settings list.
#' @return Integer vector of sampled row indices.
#' @importFrom stats runif
#' @noRd
sample_pps <- function(df, n, settings) {
  N <- nrow(df)
  if (n >= N) return(seq_len(N))

  size_col <- settings$hh_size
  if (isTruthy(size_col) && size_col %in% names(df)) {
    sizes <- as_number(df[[size_col]])
  } else {
    sizes <- NULL
  }

  if (is.null(sizes) || all(is.na(sizes)) || sum(sizes, na.rm = TRUE) <= 0) {
    sizes <- get_weights(df, settings)
  }

  sizes[is.na(sizes) | sizes < 0] <- 0
  if (sum(sizes) <= 0) return(sample_random(N, n))

  # Systematic PPS: cumulative sizes and a random start
  cum <- cumsum(sizes)
  total <- cum[N]
  interval <- total / n
  start <- runif(1, 0, interval)
  points <- start + (seq_len(n) - 1) * interval
  idx <- findInterval(points, cum, rightmost.closed = TRUE) + 1
  idx[idx > N] <- N
  sort(unique(idx))
}

#' Which values are usable phone numbers
#'
#' A number column: 8 to 15 digits once spaces, dashes and a leading + are
#' dropped, and not one digit repeated (00000000). A yes/no "phone available"
#' column: the yes values.
#' @noRd
valid_phone <- function(x) {
  s <- trimws(as.character(x))
  s[is.na(s)] <- ""
  digits <- gsub("[^0-9]", "", s)
  filled <- nzchar(s)
  looks_numbers <- any(filled) && mean(nchar(digits[filled]) >= 8) > 0.5
  if (looks_numbers) {
    nchar(digits) >= 8 & nchar(digits) <= 15 & !grepl("^(\\d)\\1+$", digits, perl = TRUE)
  } else {
    tolower(s) %in% c("yes", "oui", "y", "1", "true", "si", "s\u00ed")
  }
}
