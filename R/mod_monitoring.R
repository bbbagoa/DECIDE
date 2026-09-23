#' Targeting Monitoring (phase 3)
#'
#' Three tabs: the PDM analysis (implementation errors, plus charts on any
#' PDM variable), process monitoring (the officer's own datasets and charts:
#' complaints, community process, committees, participation...), and the
#' report, which gathers the implementation errors, every chart or table
#' added with its comment, and the officer's context, findings and
#' recommendations into one HTML Targeting Monitoring report.
#' @param id module id
#' @noRd
mod_monitoring_ui <- function(id) {
  ns <- NS(id)
  bslib::navset_underline(
    id = ns("tabs"),
    bslib::nav_panel(
      value = "pdm", title = tagList(bsicons::bs_icon("bullseye"), " 1. PDM analysis"),
      mod_pdm_ui(ns("pdm"), explore = mod_chart_builder_ui(ns("pdm_charts"), presets = "PDM"))
    ),
    bslib::nav_panel(
      value = "process", title = tagList(bsicons::bs_icon("people"), " 2. Process monitoring"),
      bslib::card(
        class = "mt-3",
        bslib::card_header(bsicons::bs_icon("cloud-upload"), " Process-monitoring data"),
        bslib::card_body(
          tags$p(class = "small text-muted mb-2",
                 "Complaints and feedback, community sessions, targeting committees, participation of women and minorities, ",
                 "focus group discussions on the criteria... Load as many datasets as you have; each one can feed charts and tables."),
          tags$div(
            class = "d-flex flex-wrap align-items-end gap-3",
            tags$div(style = "flex: 1 1 280px;",
                     fileInput(ns("pm_file"), "Load a dataset", width = "100%",
                               accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"))),
            tags$div(style = "flex: 0 1 260px;",
                     selectInput(ns("pm_active"), "Dataset to chart", choices = character(0), width = "100%")),
            tags$div(class = "pb-3",
                     actionButton(ns("pm_remove"), NULL, icon = icon("trash"), class = "btn-outline-danger btn-sm",
                                  title = "Remove this dataset"))
          ),
          uiOutput(ns("pm_status"))
        )
      ),
      mod_chart_builder_ui(ns("pm_charts"), presets = c("Complaints and feedback (CFM)", "Community process"))
    ),
    bslib::nav_panel(
      value = "report", title = tagList(bsicons::bs_icon("file-earmark-text"), " 3. Monitoring report"),
      bslib::layout_columns(
        class = "mt-3", col_widths = c(5, 7),
        bslib::card(
          bslib::card_header(bsicons::bs_icon("pencil"), " Your analysis"),
          bslib::card_body(
            textAreaInput(ns("context"), "Context", rows = 4, width = "100%",
                          placeholder = "Programme, area, period, targeting approach, who collected what."),
            textAreaInput(ns("findings"), "Key findings", rows = 5, width = "100%",
                          placeholder = "What worked, what did not, where and for whom."),
            textAreaInput(ns("recommendations"), "Recommendations", rows = 5, width = "100%",
                          placeholder = "What to change in the next round, and who does it."),
            checkboxInput(ns("include_pdm"), "Include the implementation errors from the PDM analysis", value = TRUE),
            downloadButton(ns("report"), "Targeting monitoring report (HTML)", class = "btn-primary w-100")
          )
        ),
        bslib::card(
          bslib::card_header(bsicons::bs_icon("collection"), " In the report"),
          bslib::card_body(uiOutput(ns("items_ui")))
        )
      )
    )
  )
}

#' @noRd
mod_monitoring_server <- function(id, workspace = NULL, country_office = reactive(NULL), modification_log = NULL,
                                  user_setup = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    pdm <- mod_pdm_server("pdm", workspace, country_office = country_office, modification_log = modification_log,
                          user_setup = user_setup)

    items <- reactiveVal(list())
    add_item <- function(it) {
      items(c(items(), list(it)))
      audit_add(modification_log, "Monitoring", "Added to the monitoring report", it$title)
    }

    # --- process-monitoring datasets -------------------------------------------
    datasets <- reactiveVal(list())
    observeEvent(input$pm_file, {
      f <- input$pm_file; req(f)
      ext <- tolower(tools::file_ext(f$name))
      if (!ext %in% c("xlsx", "xls", "sav", "dta", "csv", "parquet")) {
        showNotification(paste("Unsupported file type:", ext), type = "error"); return()
      }
      df <- tryCatch(as.data.frame(read_import_file(f$datapath, ext)), error = function(e) {
        showNotification(paste("Could not read file:", conditionMessage(e)), type = "error"); NULL })
      req(df)
      ds <- datasets(); ds[[f$name]] <- df; datasets(ds)
      updateSelectInput(session, "pm_active", choices = names(ds), selected = f$name)
      audit_add(modification_log, "Monitoring", "Process-monitoring data loaded", sprintf("%s (%s rows)", f$name, nrow(df)))
    })
    observeEvent(input$pm_remove, {
      ds <- datasets(); req(length(ds), input$pm_active)
      ds[[input$pm_active]] <- NULL; datasets(ds)
      updateSelectInput(session, "pm_active", choices = names(ds), selected = if (length(ds)) names(ds)[1] else character(0))
    })
    output$pm_status <- renderUI({
      ds <- datasets()
      if (!length(ds)) return(NULL)
      tags$div(class = "wfp-norm-bar", tags$strong(sprintf("%d dataset%s", length(ds), if (length(ds) > 1) "s" else "")),
               lapply(names(ds), function(n) tags$span(class = "wfp-norm-chip", n, tags$em(format(nrow(ds[[n]]), big.mark = ",")))))
    })
    active_pm <- reactive({ ds <- datasets(); if (shiny::isTruthy(input$pm_active)) ds[[input$pm_active]] else NULL })

    mod_chart_builder_server("pdm_charts", data = pdm$df, source = "pdm", dataset_name = pdm$name, add_item = add_item)
    mod_chart_builder_server("pm_charts", data = active_pm, source = "process",
                             dataset_name = reactive(input$pm_active %||% ""), add_item = add_item)

    # --- the report's items: reorder, edit the comment, remove -------------------
    output$items_ui <- renderUI({
      its <- items()
      if (!length(its)) {
        return(empty_state("Nothing added yet",
                           "Build a chart or a table on the PDM or Process monitoring tab and click Add to report.",
                           icon = "collection"))
      }
      js <- function(what, id) sprintf("Shiny.setInputValue('%s', {what: '%s', id: '%s', n: Math.random()})", ns("item_act"), what, id)
      tagList(lapply(seq_along(its), function(i) {
        it <- its[[i]]
        tags$div(
          class = "wfp-item",
          tags$div(class = "wfp-item-head",
                   tags$span(class = "wfp-item-num", i),
                   tags$div(class = "flex-grow-1",
                            tags$strong(it$title),
                            tags$div(class = "small text-muted",
                                     if (identical(it$source, "pdm")) "PDM" else "Process monitoring", " \u00b7 ",
                                     it$dataset, " \u00b7 ", if (identical(it$display, "table")) "table" else "chart")),
                   tags$div(class = "btn-group btn-group-sm",
                            tags$button(type = "button", class = "btn btn-outline-secondary", title = "Move up",
                                        onclick = js("up", it$id), icon("arrow-up")),
                            tags$button(type = "button", class = "btn btn-outline-secondary", title = "Move down",
                                        onclick = js("down", it$id), icon("arrow-down")),
                            tags$button(type = "button", class = "btn btn-outline-danger", title = "Remove",
                                        onclick = js("remove", it$id), icon("xmark")))),
          tags$textarea(class = "form-control form-control-sm mt-2", rows = 2, placeholder = "Comment",
                        onchange = sprintf("Shiny.setInputValue('%s', {id: '%s', text: this.value, n: Math.random()})",
                                           ns("item_comment"), it$id),
                        it$comment)
        )
      }))
    })
    observeEvent(input$item_act, {
      a <- input$item_act; its <- items()
      i <- which(vapply(its, `[[`, character(1), "id") == a$id); req(length(i) == 1)
      if (identical(a$what, "remove")) its <- its[-i]
      else if (identical(a$what, "up") && i > 1) its[c(i - 1, i)] <- its[c(i, i - 1)]
      else if (identical(a$what, "down") && i < length(its)) its[c(i, i + 1)] <- its[c(i + 1, i)]
      items(its)
    })
    observeEvent(input$item_comment, {
      a <- input$item_comment; its <- items()
      i <- which(vapply(its, `[[`, character(1), "id") == a$id); req(length(i) == 1)
      its[[i]]$comment <- a$text
      items(its)
    })

    # --- the report --------------------------------------------------------------
    output$report <- downloadHandler(
      filename = function() paste0("Targeting_monitoring_report_", format(Sys.time(), "%Y-%m-%d_%Hh%M"), ".html"),
      content = function(file) {
        r <- pdm$results()
        tol <- pdm$tolerance()
        p <- if (isTRUE(input$include_pdm) && !is.null(r)) list(
          metrics = r$metrics, n = r$n, by_unit = r$by_unit, excl_design = r$excl_design, tolerance = tol,
          elig_source = r$elig_source, weighting = r$weighting, strata = r$strata, no_nonbenef = r$no_nonbenef,
          verdict = tryCatch(error_verdict(r$metrics$inclusion_error, r$metrics$exclusion_error, tol[1], tol[2],
                                           stage = "implementation"), error = function(e) NULL))
        lang <- session$rootScope()$input$lang_selector
        write_monitoring_report(file, list(country_office = country_office(), context = input$context,
                                           findings = input$findings, recommendations = input$recommendations,
                                           pdm = p, items = items()),
                                lang = if (identical(lang, "fr")) "fr" else "en")
        audit_add(modification_log, "Monitoring", "Monitoring report exported",
                  sprintf("%d charts and tables%s", length(items()), if (is.null(p)) "" else ", with implementation errors"))
      }
    )

    # --- saved with the session ------------------------------------------------------
    workspace_register(workspace, "monitoring",
      snapshot = function() {
        if (!length(datasets()) && !length(items()) && !nzchar(paste0(input$context, input$findings, input$recommendations))) return(NULL)
        list(datasets = datasets(), active = input$pm_active, items = items(),
             context = input$context, findings = input$findings, recommendations = input$recommendations,
             include_pdm = input$include_pdm)
      },
      restore = function(s) {
        datasets(s$datasets %||% list()); items(s$items %||% list())
        updateSelectInput(session, "pm_active", choices = names(s$datasets %||% list()), selected = s$active)
        for (k in c("context", "findings", "recommendations")) updateTextAreaInput(session, k, value = s[[k]] %||% "")
        if (!is.null(s$include_pdm)) updateCheckboxInput(session, "include_pdm", value = s$include_pdm)
      })
  })
}
