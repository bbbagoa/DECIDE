#' Implementation errors: post-targeting survey (or PDM) module UI
#'
#' Phase 3 of the targeting cycle: monitoring. The preferred source is a
#' post-targeting survey (or baseline): a sample of selected and non-selected
#' households drawn in Beneficiary Selection (`ptm_draw()`), surveyed
#' BEFORE the distribution, so an area whose list is wrong can be reviewed
#' or its distribution paused (`ptm_area_decisions()`). A Post-Distribution
#' Monitoring extract can still be analysed, as the least preferred option:
#' nothing can be undone after distribution, and the assistance may itself
#' have changed some answers.
#'
#' These are *implementation* errors, and they answer a different question
#' from the design errors on the Scorecard tab (Targeting Advisory 2/2025):
#'
#' * Design error     -- were the eligibility criteria themselves right?
#'                       Measured on assessment data, before anyone is served.
#' * Implementation error -- were those criteria applied correctly on the
#'                       ground? Measured on a post-targeting survey before
#'                       distribution (preferred) or on PDM data after it.
#'
#' A good design can still be implemented badly, so the two are reported
#' separately and are not comparable to each other.
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_pdm_ui <- function(id, explore = NULL) {
  ns <- NS(id)
  pick <- function(id, label) shinyWidgets::pickerInput(
    ns(id), label, choices = NULL, width = "100%",
    options = shinyWidgets::pickerOptions(container = "body", liveSearch = TRUE))
  # Set-up in a compact sidebar, one collapsible step each; the results take
  # the page beside it.
  panel <- function(value, title, icon_name, ...) bslib::accordion_panel(
    title = title, value = value, icon = bsicons::bs_icon(icon_name), ...)
  bslib::layout_sidebar(
    fillable = FALSE, class = "mt-3 wfp-mon-layout",
    sidebar = bslib::sidebar(
      width = 330, class = "wfp-mon-sidebar",
      bslib::accordion(
        id = ns("setup"), multiple = FALSE, open = "data",
        # Implementation errors are best measured after the selection and
        # before the distribution, on a sample of selected and non-selected
        # households: problems can then still be fixed.
        panel("data", "1. Survey data", "cloud-upload",
              # Before distribution (recommended) or after it (PDM); the
              # choice names the data in the results, the exports and the report.
              radioButtons(ns("data_kind"), NULL,
                           choices = c("Post-targeting survey / baseline (before distribution, recommended)" = "Baseline",
                                       "PDM (after distribution, least preferred)" = "PDM"),
                           selected = "Baseline"),
              uiOutput(ns("kind_note")),
              fileInput(ns("pdm_file"), NULL, width = "100%", accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"),
                        placeholder = "One row per surveyed household"),
              tags$div(class = "mt-1 mb-2", mod_moda_import_ui(ns("moda"))),
              uiOutput(ns("pdm_file_status"))),
        panel("areas", "Areas covered", "geo-alt", mod_area_scope_ui(ns("scope"), title = NULL)),
        panel("benef", "2. Selected or assisted households", "person-check",
              radioButtons(ns("benef_source"), NULL,
                           choices = c("From the sample list (upload it, match the household ID)" = "design", "A column in the data" = "column"),
                           selected = "design"),
              conditionalPanel(sprintf("input['%s'] === 'design'", ns("benef_source")),
                               uiOutput(ns("ptm_sample_ui")),
                               pick("ptm_id", "Household ID in the survey"),
                               uiOutput(ns("ptm_match"))),
              conditionalPanel(sprintf("input['%s'] === 'column'", ns("benef_source")),
              pick("pdm_beneficiary", "Selected / beneficiary column"),
              # Any column with two answers: say which one means assisted.
              uiOutput(ns("benef_level_ui"))),
              # Where resources did not cover every eligible household, the ones
              # cut by prioritisation are excluded by design, not exclusion
              # errors (Targeting Advisory 2/2025).
              pick("pdm_prioritized", "Prioritised column (optional)"),
              pick("pdm_unit", "Area column (optional)")),
        panel("elig", "3. Who was eligible", "clipboard-check",
              # Implementation error = were the criteria applied correctly? The
              # ground truth is the criteria, re-applied to the PDM answers.
              radioButtons(ns("pdm_elig_source"), NULL,
                           choices = c("A column in the data" = "column",
                                       "Apply the selection logic" = "logic"),
                           selected = "column"),
              conditionalPanel(sprintf("input['%s'] === 'column'", ns("pdm_elig_source")),
                               pick("pdm_eligibility", "Eligibility column")),
              uiOutput(ns("pdm_elig_note"))),
        panel("weight", "4. Weighting", "sliders",
              # The surveys set numbers of beneficiaries and non-beneficiaries;
              # the exclusion error needs each group weighted by its real size.
              radioButtons(ns("pdm_weight_mode"), NULL,
                           choices = c("From the sample design (recommended)" = "design",
                                       "Population sizes typed in" = "population",
                                       "A weight column" = "column", "None" = "none"),
                           selected = "design"),
              conditionalPanel(sprintf("input['%s'] === 'column'", ns("pdm_weight_mode")),
                               pick("pdm_weight", "Weight column")),
              conditionalPanel(
                sprintf("input['%s'] === 'population'", ns("pdm_weight_mode")),
                radioButtons(ns("pop_scope"), NULL, inline = TRUE,
                             choices = c("Overall" = "overall", "Per area" = "unit"), selected = "overall"),
                conditionalPanel(
                  sprintf("input['%s'] === 'overall'", ns("pop_scope")),
                  numericInput(ns("pop_benef"), "Beneficiary households", value = NA, min = 0, width = "100%"),
                  numericInput(ns("pop_nonbenef"), "Non-beneficiary households", value = NA, min = 0, width = "100%")),
                conditionalPanel(sprintf("input['%s'] === 'unit'", ns("pop_scope")),
                                 tags$div(class = "small text-muted", "Type the sizes per area in the table on the right."))))
      ),
      # After the four steps (not stuck over them: the steps scrolled under it).
      tags$div(class = "wfp-sb-actions wfp-sb-actions-end",
               tags$div(class = "small fw-semibold mb-2", "5. Compute"),
               actionButton(ns("pdm_run"), "Compute implementation errors", class = "btn-primary btn-sm w-100", icon = icon("calculator")),
               downloadButton(ns("pdm_download"), "Export (Excel)", class = "btn-outline-secondary btn-sm w-100 mt-2"),
               tags$div(class = "small text-muted mt-2", bsicons::bs_icon("info-circle"),
                        " Implementation errors measure whether the criteria were applied correctly on the ground, not whether they were right (that is the design error)."))
    ),
    uiOutput(ns("pop_table_ui")),
    uiOutput(ns("pdm_hint")),
    bslib::navset_underline(
      id = ns("pdm_tabs"),
      bslib::nav_panel(
        value = "errors", title = tagList(bsicons::bs_icon("bullseye"), " Errors and verdict"),
        uiOutput(ns("pdm_results")),
        uiOutput(ns("decisions_ui")),
        # The tolerance band only means something once there is data to judge.
        conditionalPanel(
          sprintf("output['%s']", ns("has_data")),
          tags$div(class = "d-flex gap-3 flex-wrap align-items-end mt-2 wfp-tol-row",
                   tags$div(style = "flex: 0 1 200px;", numericInput(ns("tol_lower"), "Lower error tolerance (%)", value = 5, min = 0, max = 49, step = 1, width = "100%")),
                   tags$div(style = "flex: 0 1 200px;", numericInput(ns("tol_upper"), "Upper error tolerance (%)", value = 20, min = 1, max = 49, step = 1, width = "100%")))),
        uiOutput(ns("pdm_verdict"))
      ),
      bslib::nav_panel(
        value = "details", title = tagList(bsicons::bs_icon("table"), " Details by group and area"),
        uiOutput(ns("pdm_details"))
      ),
      # A ranking adopted without an outcome gets its errors measured here.
      bslib::nav_panel(
        value = "calibrate", title = tagList(bsicons::bs_icon("sliders"), " Calibrate the ranking"),
        tags$div(class = "mt-3", uiOutput(ns("calib_ui")))
      ),
      if (!is.null(explore)) bslib::nav_panel(
        value = "explore", title = tagList(bsicons::bs_icon("bar-chart"), " Explore the data"),
        tags$div(class = "mt-3", explore)
      )
    )
  )
}

#' PDM / Targeting Accuracy Module Server
#'
#' The PDM extract is self-contained -- it carries its own eligibility and
#' beneficiary columns -- so this module deliberately does not read the main
#' dataset or its setup mapping.
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_pdm_server <- function(id, workspace = NULL, country_office = reactive(NULL), modification_log = NULL,
                           user_setup = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # The selection logic, loaded here from the file Beneficiary Selection
    # downloads (approach, card with the threshold applied, rules): each
    # workstream stands alone, so nothing adopted elsewhere is read here, and
    # the Design card alone is not used (Selection may change its threshold
    # and add rules). Its card (a ranking) also feeds "Calibrate the ranking".
    pdm_logic <- reactiveVal(NULL)
    pdm_card <- reactive(pdm_logic()$scorecard)

    # Kept whole; the analysis runs on the areas covered (see mod_area_scope).
    pdm_all <- reactiveVal(NULL)
    mod_data_summary_server("summary", pdm_all, "Verification survey / PDM data")
    # WFP food security indicators on the survey, as on the assessment: the
    # yes / no versions can say who was eligible (step 3)
    mod_fs_indicators_server("fsi", pdm_all, function(df) { pdm_all(df); refresh_pickers() },
                             log = modification_log, phase = "Monitoring")
    # new columns: every picker lists them, keeping what is chosen
    refresh_pickers <- function() {
      cols <- names(pdm_all())
      for (k in c("pdm_eligibility", "pdm_beneficiary", "ptm_id"))
        shinyWidgets::updatePickerInput(session, k, choices = c("Choose a column" = "", cols), selected = isolate(input[[k]]) %||% "")
      for (k in c("pdm_prioritized", "pdm_unit", "pdm_weight"))
        shinyWidgets::updatePickerInput(session, k, choices = c("(none)", cols), selected = isolate(input[[k]]) %||% "(none)")
    }
    scope <- mod_area_scope_server("scope", pdm_all, workspace, "pdm_scope", modification_log, "Monitoring")
    pdm_scoped <- reactive(scope$filter(pdm_all()))
    pdm_df <- function(value) if (missing(value)) pdm_scoped() else pdm_all(value)
    results <- reactiveVal(NULL)

    pdm_inputs <- c("pdm_eligibility", "pdm_beneficiary", "pdm_prioritized", "pdm_unit", "pdm_weight", "ptm_id")
    workspace_register(workspace, "pdm",
      snapshot = function() {
        if (is.null(pdm_df()) && is.null(sample_design()) && is.null(pdm_logic())) return(NULL)
        list(df = pdm_all(), results = results(), logic = pdm_logic(), source = pdm_source(), moda_form = pdm_form(), sample_design = sample_design(),
             inputs = lapply(stats::setNames(pdm_inputs, pdm_inputs), function(k) input[[k]]),
             options = list(data_kind = input$data_kind, elig_source = input$pdm_elig_source, weight_mode = input$pdm_weight_mode,
                            benef_source = input$benef_source,
                            pop_scope = input$pop_scope, pop_benef = input$pop_benef,
                            pop_nonbenef = input$pop_nonbenef, pop_units = pop_units(),
                            benef_level = input$pdm_benef_level, elig_level = input$pdm_elig_level,
                            tol = c(input$tol_lower, input$tol_upper)))
      },
      restore = function(s) {
        pdm_logic(s$logic)
        pdm_df(s$df)
        pdm_source(s$source)
        pdm_form(s$moda_form)
        results(s$results)
        sample_design(s$sample_design)
        cols <- names(s$df)
        for (k in pdm_inputs) {
          ch <- if (k %in% c("pdm_eligibility", "pdm_beneficiary")) c("Choose a column" = "", cols) else c("(none)", cols)
          shinyWidgets::updatePickerInput(session, k, choices = ch, selected = s$inputs[[k]])
        }
        o <- s$options %||% list()
        if (!is.null(o$data_kind)) updateRadioButtons(session, "data_kind", selected = o$data_kind)
        # the scorecard and rules sources became the selection logic
        if (!is.null(o$elig_source)) updateRadioButtons(session, "pdm_elig_source",
                                                        selected = if (o$elig_source %in% c("scorecard", "rules")) "logic" else o$elig_source)
        if (!is.null(o$weight_mode)) updateRadioButtons(session, "pdm_weight_mode", selected = o$weight_mode)
        if (!is.null(o$benef_source)) updateRadioButtons(session, "benef_source", selected = o$benef_source)
        if (!is.null(o$pop_scope)) updateRadioButtons(session, "pop_scope", selected = o$pop_scope)
        updateNumericInput(session, "pop_benef", value = o$pop_benef %||% NA)
        updateNumericInput(session, "pop_nonbenef", value = o$pop_nonbenef %||% NA)
        if (!is.null(o$pop_units)) pop_units(o$pop_units)
        if (!is.null(o$benef_level)) after_flush(session, function() updateRadioButtons(session, "pdm_benef_level", selected = o$benef_level))
        if (!is.null(o$elig_level)) after_flush(session, function() updateRadioButtons(session, "pdm_elig_level", selected = o$elig_level))
        if (length(o$tol) == 2) {
          updateNumericInput(session, "tol_lower", value = o$tol[1])
          updateNumericInput(session, "tol_upper", value = o$tol[2])
        }
      })

    # --- The sample list (drawn in Beneficiary Selection) ----------------------
    # The workbook Beneficiary Selection exports: each household's group and
    # area, and the Design sheet (group sizes, for the weights).
    sample_design <- reactiveVal(NULL)
    observeEvent(input$ptm_sample_file, {
      f <- input$ptm_sample_file; req(f)
      tw_guard("Reading the sample list", {
        need_ok(tolower(tools::file_ext(f$name)) %in% c("xlsx", "xls"),
                "Upload the sample list as exported by Beneficiary Selection (Excel).")
        sd <- ptm_read_sample(f$datapath, f$name)
        sample_design(sd)
        updateRadioButtons(session, "benef_source", selected = "design")
        updateRadioButtons(session, "data_kind", selected = sd$kind)
        if (is.null(sd$design)) updateRadioButtons(session, "pdm_weight_mode", selected = "population")
        df <- pdm_all()
        if (!is.null(df)) {
          idg <- if (sd$id_col %in% names(df)) sd$id_col else find_guess(names(df), c("household_id", "hh_id", "hhid", "unique", "id"))
          shinyWidgets::updatePickerInput(session, "ptm_id", selected = idg)
        }
        audit_add(modification_log, "Monitoring", "Sample list loaded",
                  sprintf("%s (%s households, %s eligible)", f$name, format(nrow(sd$list), big.mark = ","),
                          format(sum(sd$group == "Selected", na.rm = TRUE), big.mark = ",")))
      })
    })
    # --- The selection logic, from its file -----------------------------------
    observeEvent(input$pdm_logic_file, {
      f <- input$pdm_logic_file; req(f)
      tw_guard("Reading the selection logic", {
        lg <- read_selection_logic(f$datapath)
        pdm_logic(lg)
        calib(NULL)
        updateRadioButtons(session, "pdm_elig_source", selected = "logic")
        audit_add(modification_log, "Monitoring", "Selection logic loaded", paste0(f$name, ": ", logic_describe(lg)))
      })
    })
    output$pdm_logic_ui <- renderUI(fileInput(ns("pdm_logic_file"), NULL, width = "100%", accept = ".json",
                                              placeholder = "The selection logic (.json)"))
    outputOptions(output, "pdm_logic_ui", suspendWhenHidden = FALSE)
    output$ptm_sample_ui <- renderUI(fileInput(ns("ptm_sample_file"), NULL, width = "100%", accept = c(".xlsx", ".xls"),
                                               placeholder = "The sample list (Excel)"))
    outputOptions(output, "ptm_sample_ui", suspendWhenHidden = FALSE)
    output$kind_note <- renderUI({
      if (identical(input$data_kind, "PDM")) return(tags$div(class = "alert alert-warning small py-2",
        bsicons::bs_icon("exclamation-triangle"),
        " The least preferred option: after distribution nothing can be undone, vulnerability may have changed, and the assistance itself",
        " may have changed the answers to some criteria (assets bought, debts paid). Use it when no survey could be done before distribution."))
      tags$div(class = "small text-muted mb-2", bsicons::bs_icon("info-circle"),
               " A survey of eligible and not eligible households after the selection and before the distribution (the sample drawn in Beneficiary Selection):",
               " problems in an area can still be fixed, or its distribution paused.")
    })
    # Survey households matched to the sample list on their identifier
    ptm_matched <- reactive({
      sd <- sample_design(); df <- pdm_df(); idc <- input$ptm_id
      if (is.null(sd) || is.null(df) || !shiny::isTruthy(idc) || !idc %in% names(df)) return(NULL)
      m <- match(trimws(as.character(df[[idc]])), trimws(sd$list$household_id))
      list(flag = ifelse(is.na(m), NA, sd$group[m] == "Selected"), area = sd$area[m], n = sum(!is.na(m)), of = nrow(df))
    })
    output$ptm_match <- renderUI({
      if (is.null(sample_design())) return(tags$div(class = "small text-warning", "Upload the sample list first, or use a column in the data."))
      mt <- ptm_matched(); if (is.null(mt)) return(NULL)
      tags$div(class = paste("small", if (mt$n < mt$of) "text-warning" else "text-success"),
               sprintf("%s of %s surveyed households found in the sample list.", format(mt$n, big.mark = ","), format(mt$of, big.mark = ",")),
               if (mt$n < mt$of) " The others are left out.")
    })

    # Who received assistance: any column with exactly two answers; the
    # officer says which answer means assisted (guessed for yes/no, 1/0,
    # "Beneficiary / Non-beneficiary", "Assisted / Not assisted"...).
    benef_levels <- reactive({
      df <- pdm_df(); b <- input$pdm_beneficiary
      if (is.null(df) || !shiny::isTruthy(b) || !b %in% names(df)) return(NULL)
      two_levels(df[[b]])
    })
    # The React page draws the radio (input$pdm_benef_level) from these facts
    # (output$pdm_side); a new column picks its answer as the Shiny page did.
    observeEvent(benef_levels(), {
      lv <- benef_levels()
      if (length(lv) == 2 && !isTRUE(isolate(input$pdm_benef_level) %in% lv))
        updateRadioButtons(session, "pdm_benef_level", selected = guess_positive_answer(lv))
    })
    # The eligibility column: with two answers, the officer says which one
    # means vulnerable (guessed: yes-like, else "food insecure", "poor"...).
    elig_levels <- reactive({
      df <- pdm_df(); e <- input$pdm_eligibility
      if (is.null(df) || !shiny::isTruthy(e) || !e %in% names(df)) return(NULL)
      two_levels(df[[e]])
    })
    observeEvent(elig_levels(), {
      lv <- elig_levels()
      if (length(lv) == 2 && !isTRUE(isolate(input$pdm_elig_level) %in% lv))
        updateRadioButtons(session, "pdm_elig_level", selected = guess_vulnerable_answer(lv))
    })
    elig_col_flag <- function(df) {
      x <- df[[input$pdm_eligibility]]
      lv <- elig_levels()
      if (length(lv) != 2) return(eligibility_flag(x))
      pos <- if (isTRUE(input$pdm_elig_level %in% lv)) input$pdm_elig_level else guess_vulnerable_answer(lv)
      v <- trimws(as.character(x))
      ifelse(is.na(v) | !nzchar(v), NA, v == pos)
    }
    # TRUE = received, FALSE = not, NA = not answered; NULL when the column
    # does not have two answers.
    benef_flag <- function(df) {
      lv <- benef_levels()
      if (length(lv) != 2) return(NULL)
      pos <- input$pdm_benef_level %||% guess_positive_answer(lv)
      x <- trimws(as.character(df[[input$pdm_beneficiary]]))
      out <- x == pos
      out[is.na(x) | !nzchar(x)] <- NA
      out
    }

    # Population sizes per area, typed into an editable table.
    pop_units <- reactiveVal(NULL)
    pop_template <- reactive({
      df <- pdm_df(); u <- input$pdm_unit
      req(df, shiny::isTruthy(u), u %in% names(df), shiny::isTruthy(input$pdm_beneficiary), input$pdm_beneficiary %in% names(df))
      b <- benef_flag(df); req(b)
      st <- pdm_stratum_weights(b, df[[u]], data.frame(unit = character(0), beneficiaries = numeric(0), non_beneficiaries = numeric(0)))$strata
      old <- pop_units()
      if (!is.null(old)) {
        i <- match(st$unit, old$unit)
        st$beneficiaries <- old$beneficiaries[i]; st$non_beneficiaries <- old$non_beneficiaries[i]
      }
      st
    })
    output$pop_table_ui <- renderUI({
      if (!identical(input$pdm_weight_mode, "population") || !identical(input$pop_scope, "unit")) return(NULL)
      if (!shiny::isTruthy(input$pdm_unit) || identical(input$pdm_unit, "(none)")) {
        return(tags$div(class = "alert alert-warning", "Choose the Break down by column (the area) to give the population sizes per area."))
      }
      bslib::card(
        class = "mb-3",
        bslib::card_header(bsicons::bs_icon("people"), " Population sizes per area"),
        bslib::card_body(
          tags$p(class = "small text-muted mb-2",
                 "Double-click a cell of the last two columns to type the number of beneficiary and non-beneficiary households in each area."),
          DT::DTOutput(ns("pop_table"), fill = FALSE)
        )
      )
    })
    output$pop_table <- render_react_table({
      st <- pop_template()
      names(st) <- c("Area", "Beneficiaries surveyed", "Non-beneficiaries surveyed",
                     "Beneficiary households", "Non-beneficiary households")
      st
    }, page_size = 100, editable = c("Beneficiary households", "Non-beneficiary households"),
    formats = list(`Beneficiaries surveyed` = "int", `Non-beneficiaries surveyed` = "int",
                   `Beneficiary households` = "int", `Non-beneficiary households` = "int"))
    observeEvent(input$pop_table_cell_edit, {
      e <- input$pop_table_cell_edit
      st <- pop_template()
      # the React table counts columns from 1 (DT counted from 0): 4 and 5 are editable
      col <- c("beneficiaries", "non_beneficiaries")[as.integer(e$col) - 3L]
      req(length(col) == 1, !is.na(col))
      st[[col]][e$row] <- suppressWarnings(as.numeric(e$value))
      pop_units(st[, c("unit", "beneficiaries", "non_beneficiaries")])
    })

    # What the eligibility source can do with this PDM file: list(kind, text)
    # (kind "warning" or "note"), or NULL.
    elig_note <- function() {
      src <- input$pdm_elig_source %||% "column"
      if (identical(src, "column")) return(NULL)
      lg <- pdm_logic()
      if (is.null(lg)) return(list(kind = "warning", text = "Load the selection logic downloaded from Beneficiary Selection (.json)."))
      df <- pdm_df()
      # the columns alone say what is missing: nothing is computed here
      r <- if (is.null(df)) list(missing = character(0)) else
        tryCatch(logic_eligibility(df[0, , drop = FALSE], lg), error = function(e) list(missing = conditionMessage(e)))
      if (length(r$missing)) list(kind = "warning", text = paste0("The survey data lacks: ", paste(r$missing, collapse = ", "), "."))
      else list(kind = "note", text = logic_describe(lg))
    }

    # --- Load -------------------------------------------------------------
    observeEvent(input$pdm_file, {
      req(input$pdm_file)
      ext <- tolower(tools::file_ext(input$pdm_file$name))
      allowed <- c("xlsx", "xls", "sav", "dta", "csv", "parquet")
      if (!ext %in% allowed) {
        showNotification(paste("Unsupported file type:", ext), type = "error", duration = 10)
        return()
      }

      w <- waiter::Waiter$new(html = waiter_content("Reading PDM data..."),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show()
      on.exit(w$hide(), add = TRUE)

      df <- tryCatch(read_import_file(input$pdm_file$datapath, ext),
                     error = function(e) { showNotification(paste("Could not read file:", conditionMessage(e)), type = "error", duration = 10); NULL })
      req(df)
      pdm_form(NULL)
      take_pdm(df, input$pdm_file$name)
    })
    pdm_source <- reactiveVal(NULL)
    # The same data can come from a MODA / ONA form.
    moda <- mod_moda_import_server("moda")
    pdm_form <- reactiveVal(NULL)   # the MODA form the data came from (saved; never the key)
    observeEvent(moda$data(), {
      df <- moda$data(); req(df)
      pdm_form(moda$credentials()$form_id)
      take_pdm(df, moda$label() %||% sprintf("MODA form %s", moda$credentials()$form_id %||% ""))
    })
    mod_moda_refresh_server("moda_refresh", pdm_all, function(df) pdm_all(df), pdm_form,
                            "Survey data", log = modification_log, phase = "Monitoring")
    take_pdm <- function(df, name) tw_guard("Loading the PDM data", {
      pdm_df(df)
      pdm_source(name)
      results(NULL)
      audit_add(modification_log, "Monitoring", paste(input$data_kind %||% "PDM", "data loaded"),
                sprintf("%s (%s records)", name, nrow(df)))

      cols <- names(df)
      guess <- function(keys) {
        g <- find_guess(cols, keys)
        if (nzchar(g)) g else NULL
      }
      # Required columns start empty when nothing matches: defaulting to the
      # first column (often the record id) silently computed nonsense.
      shinyWidgets::updatePickerInput(session, "pdm_eligibility", choices = c("Choose a column" = "", cols),
                                      selected = guess(c("eligib", "eligible", "target")))
      shinyWidgets::updatePickerInput(session, "pdm_beneficiary", choices = c("Choose a column" = "", cols),
                                      selected = guess(c("benef", "assisted", "received", "distribut")))
      shinyWidgets::updatePickerInput(session, "pdm_prioritized", choices = c("(none)", cols),
                                      selected = guess(c("priorit")) %||% "(none)")
      shinyWidgets::updatePickerInput(session, "pdm_unit", choices = c("(none)", cols),
                                      selected = guess(c("admin1", "province", "region")) %||% "(none)")
      shinyWidgets::updatePickerInput(session, "pdm_weight", choices = c("(none)", cols),
                                      selected = guess(c("weight", "poids", "pond")) %||% "(none)")
      # A survey that kept the sample list's columns carries the sample: no
      # list to upload, and the group sizes give the weights.
      sv <- ptm_survey_design(df)
      if (!is.null(sv)) {
        sample_design(sv)
        updateRadioButtons(session, "benef_source", selected = "design")
        updateRadioButtons(session, "pdm_weight_mode", selected = if (is.null(sv$design)) "population" else "design")
        audit_add(modification_log, "Monitoring", "Sample read from the survey",
                  sprintf("%s households, %s eligible", format(sum(!is.na(sv$group)), big.mark = ","),
                          format(sum(sv$group == "Selected", na.rm = TRUE), big.mark = ",")))
      } else if (isTRUE(sample_design()$from_survey)) {
        sample_design(NULL)   # the previous survey's, not this one's
      }
      sd <- sample_design()
      idg <- if (!is.null(sd) && sd$id_col %in% cols) sd$id_col else guess(c("household_id", "hh_id", "hhid", "unique", "id"))
      shinyWidgets::updatePickerInput(session, "ptm_id", choices = c("Choose a column" = "", cols), selected = idg %||% "")
    })

    output$pdm_file_status <- renderUI({
      df <- pdm_df()
      if (is.null(df)) return(NULL)
      tags$div(class = "text-success small mb-0",
               bsicons::bs_icon("check-circle-fill"), " ",
               tags$strong(pdm_source() %||% "Data loaded"), tags$br(),
               paste0(format(nrow(df), big.mark = ","), " records, ",
                      format(ncol(df), big.mark = ","), " variables. Continue with the steps below."))
    })

    observe({
      gate_button("pdm_run", !is.null(pdm_df()), "Load the survey data first.")
      gate_button("pdm_download", !is.null(results()), "Compute the implementation errors first.")
    })

    # --- Compute ----------------------------------------------------------
    observeEvent(input$pdm_run, {
      req(input$pdm_run > 0)
      df <- pdm_df()
      if (is.null(df)) {
        showNotification("Load a PDM dataset first.", type = "warning")
        return()
      }
      from_design <- identical(input$benef_source %||% "design", "design")
      if (from_design) {
        need_ok(!is.null(sample_design()), "Upload the sample list drawn in Beneficiary Selection (step 2), or take the selection status from a column.")
        need_ok(!is.null(ptm_matched()) && ptm_matched()$n > 0, "Choose the household ID column: no surveyed household matches the sample list yet.")
      } else if (!shiny::isTruthy(input$pdm_beneficiary)) {
        showNotification("Choose the beneficiary column first.", type = "warning")
        return()
      }
      if (identical(input$pdm_elig_source %||% "column", "column") && !shiny::isTruthy(input$pdm_eligibility)) {
        showNotification("Choose the eligibility column first.", type = "warning")
        return()
      }

      w <- waiter::Waiter$new(html = waiter_content("Computing targeting accuracy..."),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show()
      on.exit(w$hide(), add = TRUE)

      mt <- if (from_design) ptm_matched()
      benef <- if (from_design) mt$flag else benef_flag(df)
      if (is.null(benef)) {
        showNotification("The beneficiary column must have exactly two answers (received / not received).", type = "warning")
        return()
      }
      src <- input$pdm_elig_source %||% "column"
      elig <- switch(src,
        logic = {
          if (is.null(pdm_logic())) { showNotification("Load the selection logic downloaded from Beneficiary Selection first.", type = "error"); return() }
          r <- tryCatch(logic_eligibility(df, pdm_logic()), error = function(e) list(missing = conditionMessage(e)))
          if (length(r$missing)) {
            showNotification(paste0("The selection logic cannot be applied: the survey data lacks ", paste(r$missing, collapse = ", "), "."),
                             type = "error", duration = 12)
            return()
          }
          r$eligible
        },
        { req(input$pdm_eligibility); elig_col_flag(df) })

      if (all(is.na(elig))) {
        showNotification(
          "The eligibility column could not be read as yes/no. Expected values like yes/no, 1/0, true/false, eligible/ineligible.",
          type = "error", duration = 12
        )
        return()
      }
      if (all(is.na(benef))) {
        showNotification(
          "The beneficiary column could not be read as yes/no. Expected values like yes/no, 1/0, beneficiary/non-beneficiary.",
          type = "error", duration = 12
        )
        return()
      }

      mode <- input$pdm_weight_mode %||% "none"
      if (identical(mode, "design") && !from_design) {
        showNotification("Weights from the sample design need the selection status from the sample list (step 2).", type = "warning", duration = 10)
        return()
      }
      if (identical(mode, "design") && is.null(sample_design()$design)) {
        showNotification("This sample list has no Design sheet: type the population sizes in step 4 instead.", type = "warning", duration = 10)
        return()
      }
      wcol <- input$pdm_weight
      strata <- NULL
      # the area of each surveyed household, from the sample list
      if (from_design) df$.ptm_area <- mt$area
      wts <- if (identical(mode, "design")) {
        sw <- pdm_stratum_weights(benef, df$.ptm_area, ptm_population(sample_design()$design))
        strata <- sw$strata
        v <- sw$w; v[is.na(v)] <- 0; v
      } else if (identical(mode, "column") && !is.null(wcol) && wcol %in% names(df)) {
        v <- as_number(df[[wcol]])
        v[is.na(v) | v < 0] <- 0
        v
      } else if (identical(mode, "population")) {
        unit_c <- input$pdm_unit
        per_unit <- identical(input$pop_scope, "unit") && shiny::isTruthy(unit_c) && unit_c %in% names(df)
        pop <- if (per_unit) pop_units() else
          data.frame(unit = "All", beneficiaries = input$pop_benef, non_beneficiaries = input$pop_nonbenef)
        if (is.null(pop) || all(is.na(c(pop$beneficiaries, pop$non_beneficiaries)))) {
          showNotification("Enter the number of beneficiary and non-beneficiary households (or choose another weighting).",
                           type = "warning", duration = 10)
          return()
        }
        sw <- pdm_stratum_weights(benef, if (per_unit) df[[unit_c]] else NULL, pop)
        strata <- sw$strata
        if (anyNA(sw$w[!is.na(benef)])) {
          showNotification("Some areas or groups have no population size: their households are left out of the errors.",
                           type = "warning", duration = 10)
        }
        v <- sw$w; v[is.na(v)] <- 0; v
      } else {
        rep(1, nrow(df))
      }

      # Eligible, not prioritised and not served: excluded by design. They
      # leave the error calculation (treated as unknown) and are reported on
      # their own as unmet need.
      pcol <- input$pdm_prioritized
      excl_design <- NULL
      if (!is.null(pcol) && pcol %in% names(df)) {
        prio <- eligibility_flag(df[[pcol]])
        by_design <- which(elig %in% TRUE & prio %in% FALSE & !(benef %in% TRUE))
        w_elig <- sum(wts[elig %in% TRUE])
        excl_design <- list(n = length(by_design),
                            share = if (w_elig > 0) sum(wts[by_design]) / w_elig else NA_real_)
        # served although not prioritised: outside the criteria for targeting
        # and prioritisation, so an inclusion error (Advisory 2/2025, p. 5)
        elig[which(elig %in% TRUE & prio %in% FALSE)] <- FALSE
        elig[by_design] <- NA
      }

      metrics <- targeting_metrics(selected = benef, eligible = elig, w = wts)
      if (is.null(metrics)) {
        showNotification("Not enough usable rows to compute accuracy.", type = "error")
        return()
      }
      # Only beneficiaries surveyed: who was left out cannot be seen, so the
      # exclusion error and the coverage are not measurable (not 0% / 100%).
      no_nonbenef <- !any(benef %in% FALSE)
      if (no_nonbenef) {
        metrics$exclusion_error <- NA_real_; metrics$coverage_rate <- NA_real_; metrics$recall <- NA_real_
        showNotification("Only beneficiaries were surveyed: the inclusion error is measured, the exclusion error cannot be.",
                         type = "warning", duration = 12)
      }

      unit_col <- if (from_design && nzchar(sample_design()$level %||% "")) ".ptm_area" else input$pdm_unit
      by_unit <- if (!is.null(unit_col) && unit_col %in% names(df)) {
        coverage_by_unit(df, selected = benef, eligible = elig, unit_col = unit_col, w = wts)
      } else {
        NULL
      }

      # Weighted 2x2 confusion matrix of eligibility against what was delivered
      known <- !is.na(elig) & !is.na(wts)
      sel <- benef; sel[is.na(sel)] <- FALSE
      wsum <- function(mask) sum(wts[known & mask], na.rm = TRUE)
      confusion <- data.frame(
        Eligibility = c("Eligible", "Not eligible"),
        Beneficiary = c(wsum(elig & sel), wsum(!elig & sel)),
        `Non-beneficiary` = c(wsum(elig & !sel), wsum(!elig & !sel)),
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
      # the same four cells for the page's matrix (Advisory 2/2025, p. 6), each
      # with the households surveyed in it
      nsum <- function(mask) sum(known & mask & wts > 0, na.rm = TRUE)
      matrix <- list(correct_in = wsum(elig & sel), incl = wsum(!elig & sel),
                     excl = wsum(elig & !sel), correct_out = wsum(!elig & !sel),
                     n_correct_in = nsum(elig & sel), n_incl = nsum(!elig & sel),
                     n_excl = nsum(elig & !sel), n_correct_out = nsum(!elig & !sel))

      # a decision per area, while it can still be acted on
      tol <- c((input$tol_lower %||% 5) / 100, (input$tol_upper %||% 20) / 100)
      before <- !identical(input$data_kind, "PDM")
      decisions <- if (!is.null(unit_col) && unit_col %in% names(df))
        ptm_area_decisions(benef, elig, df[[unit_col]], wts, tol[1], tol[2], before = before)
      # the same table at every area level the survey carries, for the page's
      # level picker: the sample's areas, the chosen column, the mapped levels
      # (found under a form's group path too), else the levels guessed from
      # the survey's own column names
      base <- sub(".*[/.]", "", names(df))
      guessed <- NULL
      lv_cols <- c(if (identical(unit_col, ".ptm_area")) stats::setNames(".ptm_area", paste("Sample area", sample_design()$level %||% "")),
                   if (shiny::isTruthy(input$pdm_unit) && input$pdm_unit %in% names(df)) stats::setNames(input$pdm_unit, input$pdm_unit))
      for (k in names(AREA_LEVELS)) {
        v <- as.character(if (!is.null(user_setup)) user_setup[[k]] else "")[1]
        hit <- if (!is.na(v) && nzchar(v)) names(df)[base == v][1] else NA
        if (is.na(hit)) {
          if (is.null(guessed)) guessed <- tryCatch(guess_mapping(df[setdiff(names(df), c(".ptm_area", ".ptm_group"))]), error = function(e) data.frame(key = character(), column = character()))
          v <- guessed$column[guessed$key == k][1]
          hit <- if (!is.na(v) && nzchar(v)) v else NA
        }
        if (!is.na(hit)) lv_cols[sprintf("%s \u00b7 %s", AREA_LEVELS[[k]], v)] <- hit
      }
      lv_cols <- lv_cols[!duplicated(lv_cols)]
      by_level <- lapply(names(lv_cols), function(nm) list(
        label = trimws(nm), rows = ptm_area_decisions(benef, elig, df[[lv_cols[[nm]]]], wts, tol[1], tol[2], before = before)))
      results(list(
        metrics = metrics,
        decisions = decisions,
        by_level = by_level,
        kind = input$data_kind %||% "Baseline",
        from_design = from_design,
        by_unit = by_unit,
        confusion = confusion,
        matrix = matrix,
        excl_design = excl_design,
        n = nrow(df),
        n_known = sum(known),
        weighted = !identical(wts, rep(1, nrow(df))),
        weighting = switch(mode,
                           population = if (!is.null(strata) && nrow(strata) > 1) "population sizes per area" else "population sizes (overall)",
                           design = "the sample design (households in each group of each area / households surveyed)",
                           column = paste("weight column", wcol), "none"),
        strata = strata,
        no_nonbenef = no_nonbenef,
        elig_source = switch(src, logic = paste0("the selection logic of Beneficiary Selection, applied to the survey answers (",
                                                 sub("[.]$", "", logic_describe(pdm_logic())), ")"),
                             paste("the PDM column", input$pdm_eligibility)),
        elig_col = if (identical(src, "column")) input$pdm_eligibility else src,
        benef_col = if (from_design) "the sample list" else input$pdm_beneficiary,
        unit_col = if (identical(unit_col, ".ptm_area")) sample_design()$level else if (!is.null(unit_col) && unit_col %in% names(df)) unit_col else NA_character_
      ))
      audit_add(modification_log, "Monitoring", "Implementation errors computed",
                sprintf("inclusion %.1f%%, exclusion %.1f%%, coverage %.1f%%",
                        100 * metrics$inclusion_error, 100 * metrics$exclusion_error, 100 * metrics$coverage_rate))
      showNotification("Targeting accuracy computed.", type = "message")
    })

    # --- Render -----------------------------------------------------------
    # --- Calibrating a vulnerability ranking ----------------------------------
    # The adopted ranking was built without an outcome indicator; PDM (or
    # verification) data that carry one measure its errors for the first time.
    calib <- reactiveVal(NULL)
    # The tab's facts (output$calib_state, drawn by the React page): what is
    # adopted, the columns that can hold the outcome, what the data lack, and
    # the last measure.
    output$calib_state <- shinyreact::reactive_output({
      sc <- pdm_card()
      if (scorecard_is_empty(sc) || !is_ranking(sc)) return(list(status = "none"))
      df <- pdm_df()
      if (is.null(df)) return(list(status = "nodata"))
      # the columns alone say what is missing
      miss <- pdm_scorecard_eligibility(df[0, , drop = FALSE], sc)$missing
      cols <- names(df)[vapply(df, function(v) { k <- length(unique(stats::na.omit(v))); k >= 2 && k <= 12 }, logical(1))]
      c0 <- calib()
      list(status = "ready", missing = I(as.character(miss)), cols = I(cols),
           result = if (!is.null(c0)) list(
             auc = c0$auc, n = c0$n, outcome = c0$outcome, pos = c0$pos, threshold = fmt5(c0$threshold),
             inclusion = c0$current$inclusion_error, exclusion = c0$current$exclusion_error,
             best = if (!is.na(c0$balanced$threshold)) list(threshold = fmt5(c0$balanced$threshold),
                                                           inclusion = c0$balanced$inclusion_error,
                                                           exclusion = c0$balanced$exclusion_error)))
    })
    observeEvent(input$calib_outcome, {
      df <- pdm_df(); req(df, shiny::isTruthy(input$calib_outcome), input$calib_outcome %in% names(df))
      lv <- outcome_levels(df[[input$calib_outcome]])
      updateSelectInput(session, "calib_pos", choices = lv, selected = guess_positive_level(lv))
    })
    observeEvent(input$calib_run, {
      req(input$calib_run > 0)   # a React button sends 0 at start
      sc <- pdm_card(); df <- pdm_df()
      need_ok(!scorecard_is_empty(sc) && !is.null(df) && shiny::isTruthy(input$calib_outcome), "Choose the outcome column first.")
      r <- pdm_scorecard_eligibility(df, sc)
      need_ok(!length(r$missing), sprintf("These data lack the criteria %s.", paste(r$missing, collapse = ", ")))
      y <- as_binary_outcome(df[[input$calib_outcome]], input$calib_pos)
      res <- tryCatch(ranking_calibration(r$score, y, sc$threshold %||% 0), error = function(e) e)
      need_ok(!inherits(res, "error"), if (inherits(res, "error")) conditionMessage(res) else "")
      calib(c(res, list(outcome = input$calib_outcome, pos = input$calib_pos, threshold = sc$threshold %||% 0)))
      audit_add(modification_log, "Monitoring", "Ranking calibrated",
                sprintf("On %s households, outcome %s = %s: inclusion error %.1f%%, exclusion error %.1f%%, AUC %.3f",
                        format(res$n, big.mark = ","), input$calib_outcome, input$calib_pos,
                        100 * res$current$inclusion_error, 100 * res$current$exclusion_error, res$auc))
    })
    output$has_data <- reactive(!is.null(pdm_all()))
    outputOptions(output, "has_data", suspendWhenHidden = FALSE)

    output$pdm_hint <- renderUI({
      if (is.null(pdm_df())) {
        return(empty_state(
          "No survey data loaded",
          "Draw the sample in Beneficiary Selection, survey it, then load the survey in step 1 and the sample list in step 2. A PDM with a beneficiary column can be loaded instead.",
          icon = "clipboard-data"
        ))
      }
      if (is.null(results())) {
        return(empty_state(
          "Ready to compute",
          "Check steps 2 to 4, then click Compute implementation errors.",
          icon = "calculator"
        ))
      }
      NULL
    })

    pct <- function(x) if (is.null(x) || is.na(x)) "\u2014" else paste0(round(x * 100, 1), "%")

    output$pdm_results <- renderUI({
      req(results())
      tagList(
        bslib::layout_columns(
          class = "mt-3",
          # NB: box-arrow-*, not arrow-*-bracket -- the latter are Font Awesome
          # names and bs_icon() renders them as "Error: [object Object]".
          bslib::value_box(title = "Implementation inclusion error",
                           value = textOutput(ns("pdm_incl")),
                           showcase = bsicons::bs_icon("box-arrow-in-right"), theme = "danger"),
          bslib::value_box(title = "Implementation exclusion error",
                           value = textOutput(ns("pdm_excl")),
                           showcase = bsicons::bs_icon("box-arrow-right"), theme = "warning"),
          bslib::value_box(title = "Coverage Rate", value = textOutput(ns("pdm_cov")),
                           showcase = bsicons::bs_icon("percent"), theme = "success"),
          bslib::value_box(title = "Precision / Recall", value = textOutput(ns("pdm_pr")),
                           showcase = bsicons::bs_icon("bullseye"), theme = "info"),
          col_widths = c(3, 3, 3, 3)
        ),
        # How the numbers were produced, stated next to them.
        tags$div(class = "wfp-norm-bar",
                 bsicons::bs_icon("info-circle"),
                 sprintf(" Eligibility from %s; weighting: %s.", results()$elig_source %||% "a PDM column",
                         results()$weighting %||% "none"),
                 if (isTRUE(results()$no_nonbenef)) tags$strong(" Only beneficiaries were surveyed: the exclusion error cannot be measured."))
      )
    })

    output$pdm_details <- renderUI({
      if (is.null(results())) return(tags$div(class = "mt-3", empty_state("Nothing computed yet", "Set up the four steps above, then compute.", icon = "table")))
      tagList(
        bslib::layout_columns(
          class = "mt-3",
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Eligibility vs. assistance received (estimated households)"),
            DT::DTOutput(ns("pdm_confusion"), fill = FALSE)
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Error decomposition"),
            plotly::plotlyOutput(ns("pdm_plot"), height = "300px")
          ),
          col_widths = c(6, 6)
        ),
        bslib::card(
          full_screen = TRUE,
          bslib::card_header("Coverage by area"),
          DT::DTOutput(ns("pdm_by_unit"), fill = FALSE)
        )
      )
    })

    # Targeting Advisory 2/2025 gives a separate decision table for
    # implementation errors; error_verdict() routes to it by stage.
    # The verdict card's facts (components/VerdictCard.tsx draws them), with
    # the households excluded by design.
    output$pdm_verdict <- shinyreact::reactive_output({
      m <- results()$metrics
      req(m)
      lower <- (input$tol_lower %||% 5) / 100
      upper <- (input$tol_upper %||% 20) / 100
      v <- tryCatch(error_verdict(m$inclusion_error, m$exclusion_error, lower, upper,
                                  stage = "implementation"),
                    error = function(e) list(level = "invalid",
                                             interpretation = conditionMessage(e),
                                             action = "Lower the upper tolerance below 50%."))
      ed <- results()$excl_design
      c(verdict_facts(v, errors = c(inclusion = m$inclusion_error, exclusion = m$exclusion_error),
                      tolerance = c(lower, upper), stage = "implementation"),
        list(excl_design = if (!is.null(ed)) list(n = ed$n, share = ed$share)))
    })

    output$decisions_ui <- renderUI({
      d <- results()$decisions
      if (is.null(d) || !nrow(d)) return(NULL)
      before <- !identical(results()$kind, "PDM")
      col <- c(redesign = "#c5192d", review = "#b7791f", good = "#3f7e44", few = "#6c757d", unknown = "#6c757d")
      n_pause <- sum(d$level == "redesign"); n_rev <- sum(d$level == "review")
      bslib::card(
        class = "mt-3",
        bslib::card_header(bsicons::bs_icon("signpost-split"), if (before) " Decision by area, before distribution" else " Lessons by area, for the next round"),
        bslib::card_body(
          tags$p(class = "small mb-2",
                 if (n_pause || n_rev) tags$strong(sprintf("%d area(s) to %s, %d to review.", n_pause, if (before) "pause" else "re-target", n_rev))
                 else "No area needs action.",
                 " Each area is judged on its own errors with the same decision table and tolerance band; areas with fewer than 30 surveyed households in either group are not judged."),
          tags$div(class = "wfp-model-table-wrap", tags$table(
            class = "wfp-model-table",
            tags$thead(tags$tr(tags$th("Area"), tags$th(class = "num", "Selected surveyed"), tags$th(class = "num", "Not selected surveyed"),
                               tags$th(class = "num", "Inclusion error"), tags$th(class = "num", "Exclusion error"), tags$th("Decision"))),
            tags$tbody(lapply(seq_len(nrow(d)), function(i) tags$tr(
              tags$td(tags$strong(d$area[i])),
              tags$td(class = "num", d$n_selected[i]), tags$td(class = "num", d$n_not[i]),
              tags$td(class = "num", pct(d$inclusion_error[i])), tags$td(class = "num", pct(d$exclusion_error[i])),
              tags$td(tags$span(style = sprintf("color:%s;font-weight:600", col[[d$level[i]]] %||% "inherit"), d$decision[i])))))))))
    })

    output$pdm_incl <- renderText(pct(results()$metrics$inclusion_error))
    output$pdm_excl <- renderText(pct(results()$metrics$exclusion_error))
    output$pdm_cov  <- renderText(pct(results()$metrics$coverage_rate))
    output$pdm_pr   <- renderText({
      m <- results()$metrics
      paste0(pct(m$precision), " / ", pct(m$recall))
    })

    output$pdm_confusion <- render_react_table({
      r <- results(); req(r)
      r$confusion
    }, formats = list(Beneficiary = "int", `Non-beneficiary` = "int"))

    # bars of rates, coloured by meaning, with an optional dashed band
    rate_bars <- function(d, mark = NULL, ymax = NULL) {
      d <- d[!is.na(d$value), , drop = FALSE]
      req(nrow(d) > 0)
      list(tooltip = list(trigger = "item", formatter = "fn:tip"),
           grid = list(left = 8, right = if (is.null(mark)) 16 else 64, top = 24, bottom = 8, containLabel = TRUE),
           xAxis = list(type = "category", data = d$metric, axisLabel = list(interval = 0, width = 110, overflow = "break")),
           yAxis = Filter(Negate(is.null), list(type = "value", min = 0, max = if (max(d$value) > 0.8) 1 else ymax,
                                                axisLabel = list(formatter = "fn:pct"))),
           series = list(Filter(Negate(is.null), list(type = "bar", barMaxWidth = 70,
                              label = list(show = TRUE, position = "top", formatter = "fn:pct1"),
                              markLine = mark,
                              data = lapply(seq_len(nrow(d)), function(i) list(
                                value = d$value[i], itemStyle = list(color = d$colour[i]),
                                tip = sprintf("%s: <b>%.1f%%</b>", d$metric[i], 100 * d$value[i])))))))
    }

    # the two errors against the tolerance band, dashed
    output$pdm_plot <- render_echart({
      r <- results(); req(r)
      m <- r$metrics
      d <- data.frame(metric = c("Inclusion error", "Exclusion error"),
                      value = c(m$inclusion_error, m$exclusion_error), colour = c("#c5192d", "#f7b825"),
                      stringsAsFactors = FALSE)
      tol <- c(lower = (input$tol_lower %||% 5) / 100, upper = (input$tol_upper %||% 20) / 100)
      tol_lines <- list(symbol = "none", silent = TRUE,
        data = lapply(names(tol), function(k) list(yAxis = tol[[k]],
          lineStyle = list(type = "dashed", width = 1.5, color = if (k == "upper") "#c5192d" else "#3f7e44"),
          label = list(show = TRUE, position = "end", fontSize = 10, color = if (k == "upper") "#c5192d" else "#3f7e44",
                       formatter = sprintf("%s %d%%", if (k == "upper") "Upper" else "Lower", round(100 * tol[[k]]))))))
      top <- max(d$value, na.rm = TRUE)
      rate_bars(d, tol_lines, ymax = if (is.finite(top) && top < tol[["upper"]]) ceiling(24 * tol[["upper"]]) / 20)
    }, height = 320)

    # who was reached among the eligible, and who was right among the assisted
    output$pdm_cov_plot <- render_echart({
      r <- results(); req(r)
      m <- r$metrics
      rate_bars(data.frame(metric = c("Coverage (recall)", "Precision"),
                           value = c(m$coverage_rate, m$precision), colour = c("#3f7e44", "#007DBC"),
                           stringsAsFactors = FALSE))
    }, height = 320)

    output$pdm_by_unit <- render_react_table({
      r <- results(); req(r)
      if (is.null(r$by_unit) || nrow(r$by_unit) == 0) {
        return(data.frame(Message = "Pick a breakdown column to see coverage by unit."))
      }
      cov <- r$by_unit
      colnames(cov) <- c(r$unit_col, "Eligible (w)", "Reached (w)", "Coverage")
      cov
    }, formats = list(`Eligible (w)` = "int", `Reached (w)` = "int", Coverage = "pct1"),
    styles = list(Coverage = list(bar = "#007DBC")))

    # --- Export -----------------------------------------------------------
    output$pdm_download <- download_handler(
      filename = function() export_file_name("Targeting_PDM_Accuracy", "xlsx", "%Y-%m-%d_%Hh%Mm%Ss"),
      content = function(file) {
        r <- results()
        wb <- pdm_workbook(r, tol = c((input$tol_lower %||% 5) / 100, (input$tol_upper %||% 20) / 100),
                           meta = c(`Country office` = country_office() %||% "", `Exported at` = fmt_datetime(),
                                    `Areas covered` = scope$text()))
        save_workbook_readonly(wb, file)
      }
    )

    # --- The React page (react/src/pages/monitoring/) ------------------------
    # The file input stays Shiny's (it streams the upload), drawn here and
    # hosted; rendered once, kept bound while its step is folded.
    output$pdm_file_ui <- renderUI(fileInput(ns("pdm_file"), NULL, width = "100%", accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"),
                                             placeholder = "One row per surveyed household"))
    outputOptions(output, "pdm_file_ui", suspendWhenHidden = FALSE)
    # The sidebar's small facts: the answers of the beneficiary column (the
    # radio input$pdm_benef_level) and what the eligibility source can do.
    output$pdm_side <- shinyreact::reactive_output({
      lv <- benef_levels()
      list(benef = if (!is.null(lv)) {
             ch <- value_choices(lv, input$pdm_beneficiary)
             list(n = length(lv), choices = lapply(seq_along(ch), function(i) list(value = unname(ch[i]), label = names(ch)[i] %||% unname(ch[i]))))
           },
           elig = elig_note(),
           elig_levels = if (!is.null(elig_levels())) {
             lv <- elig_levels(); ch <- value_choices(lv, input$pdm_eligibility)
             list(n = length(lv), choices = lapply(seq_along(ch), function(i) list(value = unname(ch[i]), label = names(ch)[i] %||% unname(ch[i]))))
           })
    })
    # The facts the page draws: data, sample, match, results, decisions.
    output$pdm_state <- shinyreact::reactive_output({
      df <- pdm_df(); sd <- sample_design(); r <- results(); mt <- ptm_matched()
      d <- sd$design
      m <- r$metrics
      dd <- r$decisions
      list(
        data = if (!is.null(pdm_all())) list(source = pdm_source() %||% "Data loaded", rows = NROW(df), cols = NCOL(df)),
        sample = if (!is.null(sd)) list(file = sd$file %||% "", drawn_at = sd$drawn_at %||% "", n = sum(sd$group %in% "Selected") + sum(sd$group %in% "Not selected"),
                                        selected = sum(sd$group %in% "Selected"), not_selected = sum(sd$group %in% "Not selected"),
                                        areas = length(unique(sd$area)), design = !is.null(d), from_survey = isTRUE(sd$from_survey)),
        match = if (!is.null(mt)) list(n = mt$n, of = mt$of),
        results = if (!is.null(r)) list(
          kind = r$kind, inclusion = m$inclusion_error, exclusion = m$exclusion_error, coverage = m$coverage_rate,
          precision = m$precision, recall = m$recall, elig_source = r$elig_source %||% "a PDM column",
          weighting = r$weighting %||% "none", no_nonbenef = isTRUE(r$no_nonbenef), matrix = r$matrix,
          excl_design = if (!is.null(r$excl_design)) r$excl_design$n,
          levels = lapply(r$by_level, function(l) { dd <- l$rows; list(label = l$label, rows = lapply(seq_len(nrow(dd)), function(i) list(
            area = as.character(dd$area[i]), n_selected = dd$n_selected[i], n_not = dd$n_not[i],
            eligible = dd$eligible[i], reached = dd$reached[i], coverage = dd$coverage[i],
            inclusion = dd$inclusion_error[i], exclusion = dd$exclusion_error[i], level = dd$level[i], decision = dd$decision[i]))) })))
    })

    # For the Targeting Monitoring report and the PDM chart builder.
    list(
      df = pdm_scoped,
      areas = scope$text,
      name = reactive(pdm_source() %||% paste(if (identical(input$data_kind, "PDM")) "PDM" else "Post-targeting survey", "data")),
      kind = reactive(input$data_kind %||% "PDM"),
      results = results,
      tolerance = reactive(c((input$tol_lower %||% 5) / 100, (input$tol_upper %||% 20) / 100))
    )
  })
}

## To be copied in the UI
# mod_pdm_ui("pdm_1")

## To be copied in the server
# mod_pdm_server("pdm_1")
