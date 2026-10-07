#' Implementation errors: post-targeting survey (or PDM) module UI
#'
#' Phase 3 of the targeting cycle: monitoring. The preferred source is a
#' post-targeting survey (or baseline): a sample of selected and non-selected
#' households drawn from the selection (step 0, `ptm_draw()`) and surveyed
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
        id = ns("setup"), multiple = FALSE, open = "sample",
        # Implementation errors are best measured after the selection and
        # before the distribution, on a sample of selected and non-selected
        # households: problems can then still be fixed.
        panel("sample", "0. Verification sample", "shuffle",
              tags$p(class = "small text-muted mb-2",
                     "Draw households the targeting selected and households it did not, area by area, from the current selection",
                     " (Beneficiary Selection). Survey them before any distribution: errors found then can still be corrected."),
              selectInput(ns("ptm_level"), "Area level", choices = NULL, width = "100%"),
              radioButtons(ns("ptm_size_mode"), "Households per group and area", inline = TRUE,
                           choices = c("From a margin of error" = "margin", "A fixed number" = "fixed"), selected = "margin"),
              conditionalPanel(sprintf("input['%s'] === 'margin'", ns("ptm_size_mode")),
                               numericInput(ns("ptm_margin"), tagList("Margin of error (%)", info_tip("For each group of each area, enough households to estimate a share within this margin at 95% confidence (about 96 households at 10%, fewer in small groups).")),
                                            value = 10, min = 3, max = 25, step = 1, width = "100%")),
              conditionalPanel(sprintf("input['%s'] === 'fixed'", ns("ptm_size_mode")),
                               numericInput(ns("ptm_n"), "Households per group", value = 60, min = 10, step = 10, width = "100%")),
              tags$div(class = "d-flex gap-2",
                       numericInput(ns("ptm_reserve"), tagList("Reserve (%)", info_tip("Extra households drawn in each group to replace those who cannot be found.")),
                                    value = 10, min = 0, max = 50, step = 5, width = "100%"),
                       numericInput(ns("ptm_seed"), "Seed", value = 123, min = 1, step = 1, width = "100%")),
              actionButton(ns("ptm_draw"), "Draw the sample", icon = icon("shuffle"), class = "btn-primary btn-sm w-100"),
              downloadButton(ns("ptm_download"), "Sample list (Excel)", class = "btn-outline-secondary btn-sm w-100 mt-2"),
              uiOutput(ns("ptm_status"))),
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
                           choices = c("From the sample list (match the household ID)" = "design", "A column in the data" = "column"),
                           selected = "design"),
              conditionalPanel(sprintf("input['%s'] === 'design'", ns("benef_source")),
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
                                       "Apply the adopted scorecard" = "scorecard",
                                       "Apply the eligibility rules" = "rules"),
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
                           user_setup = NULL, selection = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Kept whole; the analysis runs on the areas covered (see mod_area_scope).
    pdm_all <- reactiveVal(NULL)
    scope <- mod_area_scope_server("scope", pdm_all, workspace, "pdm_scope", modification_log, "Monitoring")
    pdm_scoped <- reactive(scope$filter(pdm_all()))
    pdm_df <- function(value) if (missing(value)) pdm_scoped() else pdm_all(value)
    results <- reactiveVal(NULL)

    pdm_inputs <- c("pdm_eligibility", "pdm_beneficiary", "pdm_prioritized", "pdm_unit", "pdm_weight", "ptm_id")
    workspace_register(workspace, "pdm",
      snapshot = function() {
        if (is.null(pdm_df()) && is.null(sample_design())) return(NULL)
        list(df = pdm_all(), results = results(), source = pdm_source(), sample_design = sample_design(),
             inputs = lapply(stats::setNames(pdm_inputs, pdm_inputs), function(k) input[[k]]),
             options = list(data_kind = input$data_kind, elig_source = input$pdm_elig_source, weight_mode = input$pdm_weight_mode,
                            benef_source = input$benef_source,
                            pop_scope = input$pop_scope, pop_benef = input$pop_benef,
                            pop_nonbenef = input$pop_nonbenef, pop_units = pop_units(),
                            benef_level = input$pdm_benef_level,
                            tol = c(input$tol_lower, input$tol_upper)))
      },
      restore = function(s) {
        pdm_df(s$df)
        pdm_source(s$source)
        results(s$results)
        sample_design(s$sample_design)
        cols <- names(s$df)
        for (k in pdm_inputs) {
          ch <- if (k %in% c("pdm_eligibility", "pdm_beneficiary")) c("Choose a column" = "", cols) else c("(none)", cols)
          shinyWidgets::updatePickerInput(session, k, choices = ch, selected = s$inputs[[k]])
        }
        o <- s$options %||% list()
        if (!is.null(o$data_kind)) updateRadioButtons(session, "data_kind", selected = o$data_kind)
        if (!is.null(o$elig_source)) updateRadioButtons(session, "pdm_elig_source", selected = o$elig_source)
        if (!is.null(o$weight_mode)) updateRadioButtons(session, "pdm_weight_mode", selected = o$weight_mode)
        if (!is.null(o$benef_source)) updateRadioButtons(session, "benef_source", selected = o$benef_source)
        if (!is.null(o$pop_scope)) updateRadioButtons(session, "pop_scope", selected = o$pop_scope)
        updateNumericInput(session, "pop_benef", value = o$pop_benef %||% NA)
        updateNumericInput(session, "pop_nonbenef", value = o$pop_nonbenef %||% NA)
        if (!is.null(o$pop_units)) pop_units(o$pop_units)
        if (!is.null(o$benef_level)) after_flush(session, function() updateRadioButtons(session, "pdm_benef_level", selected = o$benef_level))
        if (length(o$tol) == 2) {
          updateNumericInput(session, "tol_lower", value = o$tol[1])
          updateNumericInput(session, "tol_upper", value = o$tol[2])
        }
      })

    # --- The verification sample (before the survey) -------------------------
    sample_design <- reactiveVal(NULL)
    level_cols <- reactive({
      if (is.null(user_setup)) return(character(0))
      lv <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4", village = "Village")
      cols <- vapply(names(lv), function(k) { v <- as.character(user_setup[[k]] %||% "")[1]; if (is.na(v)) "" else v }, "")
      stats::setNames(cols[nzchar(cols)], sprintf("%s \u00b7 %s", lv[nzchar(cols)], cols[nzchar(cols)]))
    })
    observe({
      ch <- level_cols()
      updateSelectInput(session, "ptm_level", choices = c("(one group for all areas)" = "", ch),
                        selected = isolate(input$ptm_level) %||% (if (length(ch)) unname(ch[1]) else ""))
    })
    observeEvent(input$ptm_draw, {
      req(input$ptm_draw > 0)   # a React button sends 0 at start
      fr <- tryCatch(if (is.null(selection)) NULL else selection(), error = function(e) NULL)
      need_ok(!is.null(fr) && NROW(fr$df) > 0, "Load and map the registration data, then apply the selection in Beneficiary Selection first.")
      need_ok(any(fr$served %in% TRUE), "The selection serves no household yet: apply it in Beneficiary Selection first.")
      id_col <- user_setup$unique_id
      need_ok(shiny::isTruthy(id_col) && id_col %in% names(fr$df), "Map the household identifier in the setup first: each interview is matched back on it.")
      df <- fr$df
      status <- ifelse(fr$served %in% TRUE, "selected", ifelse(fr$eligible %in% TRUE, "by_design", "not_selected"))
      lvl <- input$ptm_level
      area <- if (shiny::isTruthy(lvl) && lvl %in% names(df)) df[[lvl]] else NULL
      size <- list(mode = input$ptm_size_mode %||% "margin", margin = (input$ptm_margin %||% 10) / 100, n = input$ptm_n %||% 60)
      d <- ptm_draw(status, area, size, reserve = (input$ptm_reserve %||% 10) / 100, seed = input$ptm_seed %||% 123)
      need_ok(!is.null(d$rows) && nrow(d$rows) > 0, "Nothing to draw: no selected or non-selected household.")
      keep <- unique(unlist(lapply(c("admin1", "admin2", "admin3", "admin4", "village", "hhh_name", "lon", "lat"), function(k) {
        v <- as.character(user_setup[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v) && v %in% names(df)) v })))
      lst <- data.frame(household_id = as.character(df[[id_col]][d$rows$row]), df[d$rows$row, setdiff(keep, id_col), drop = FALSE],
                        role = d$rows$role, order = d$rows$order, check.names = FALSE, stringsAsFactors = FALSE)
      sample_design(list(list = lst, group = ifelse(d$rows$group == "selected", "Selected", "Not selected"),
                         area = d$rows$area, design = d$design, id_col = id_col,
                         level = if (is.null(area)) "" else lvl, drawn_at = fmt_datetime(),
                         settings = list(size = size, reserve = input$ptm_reserve %||% 10, seed = input$ptm_seed %||% 123),
                         excluded_by_design = sum(status == "by_design")))
      audit_add(modification_log, "Monitoring", "Verification sample drawn",
                sprintf("%s households to survey (+%s reserve) in %d area(s); %s excluded by design left out of the frame",
                        format(sum(d$design$n), big.mark = ","), format(sum(d$design$reserve), big.mark = ","),
                        length(unique(d$design$area)), format(sum(status == "by_design"), big.mark = ",")))
    })
    output$ptm_status <- renderUI({
      sd <- sample_design()
      if (is.null(sd)) return(tags$div(class = "small text-muted mt-2", "No sample drawn yet."))
      d <- sd$design
      tags$div(class = "small mt-2",
               bsicons::bs_icon("check-circle-fill", class = "text-success"),
               sprintf(" Drawn %s: %s households to survey (%s selected, %s not selected) and %s in reserve, %d area(s).",
                       sd$drawn_at, format(sum(d$n), big.mark = ","), format(sum(d$n[d$group == "selected"]), big.mark = ","),
                       format(sum(d$n[d$group == "not_selected"]), big.mark = ","), format(sum(d$reserve), big.mark = ","),
                       length(unique(d$area))))
    })
    output$ptm_download <- download_handler(
      filename = function() export_file_name("Verification_sample", "xlsx", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        sd <- sample_design(); req(sd)
        field <- sd$list
        analyst <- cbind(sd$list, group = sd$group, stringsAsFactors = FALSE)
        wb <- ptm_sample_workbook(field, sd$design, meta = list(
          "Drawn at" = sd$drawn_at, "Areas by" = if (nzchar(sd$level)) sd$level else "one group for all areas",
          "Size" = if (identical(sd$settings$size$mode, "fixed")) paste(sd$settings$size$n, "households per group")
                   else sprintf("margin of error %.0f%% at 95%% confidence", 100 * sd$settings$size$margin),
          "Reserve" = paste0(sd$settings$reserve, "%"), "Seed" = sd$settings$seed,
          "Excluded by design (not in the frame)" = format(sd$excluded_by_design, big.mark = ",")))
        openxlsx::addWorksheet(wb, "Groups (analyst only)")
        write_data(wb, "Groups (analyst only)", analyst)
        save_workbook_readonly(wb, file)
      })
    observe({
      gate_button("ptm_download", !is.null(sample_design()), "Draw the sample first.")
    })
    output$kind_note <- renderUI({
      if (identical(input$data_kind, "PDM")) return(tags$div(class = "alert alert-warning small py-2",
        bsicons::bs_icon("exclamation-triangle"),
        " The least preferred option: after distribution nothing can be undone, vulnerability may have changed, and the assistance itself",
        " may have changed the answers to some criteria (assets bought, debts paid). Use it when no survey could be done before distribution."))
      tags$div(class = "small text-muted mb-2", bsicons::bs_icon("info-circle"),
               " A survey of selected and non-selected households after the selection and before the distribution (the sample drawn in step 0):",
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
      if (is.null(sample_design())) return(tags$div(class = "small text-warning", "Draw the sample in step 0 first, or use a column in the data."))
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
      if (identical(src, "scorecard")) {
        sc <- if (is.null(user_setup)) NULL else user_setup$scorecard
        if (scorecard_is_empty(sc)) return(list(kind = "warning", text = "No scorecard is adopted yet (Targeting Design)."))
        df <- pdm_df()
        # the columns alone say what is missing: nothing is scored here
        miss <- if (is.null(df)) character(0) else pdm_scorecard_eligibility(df[0, , drop = FALSE], sc)$missing
        return(if (length(miss)) list(kind = "warning", text = paste0("The PDM data lacks: ", paste(miss, collapse = ", "), "."))
               else list(kind = "note", text = sprintf("%d criteria, eligible when score > %s.", length(sc$items), fmt5(sc$threshold %||% 0))))
      }
      rs <- if (is.null(user_setup)) NULL else user_setup$rules
      if (is.null(rs) || ruleset_is_empty(rs)) return(list(kind = "warning", text = "No eligibility rules are saved yet (Beneficiary Selection)."))
      list(kind = "note", text = paste(ruleset_describe(rs, user_setup), collapse = " "))
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
      take_pdm(df, input$pdm_file$name)
    })
    pdm_source <- reactiveVal(NULL)
    # The same data can come from a MODA / ONA form.
    moda <- mod_moda_import_server("moda")
    observeEvent(moda$data(), {
      df <- moda$data(); req(df)
      take_pdm(df, moda$label() %||% sprintf("MODA form %s", moda$credentials()$form_id %||% ""))
    })
    take_pdm <- function(df, name) {
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
      sd <- sample_design()
      idg <- if (!is.null(sd) && sd$id_col %in% cols) sd$id_col else guess(c("household_id", "hh_id", "hhid", "unique", "id"))
      shinyWidgets::updatePickerInput(session, "ptm_id", choices = c("Choose a column" = "", cols), selected = idg %||% "")
    }

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
        need_ok(!is.null(sample_design()), "Draw the verification sample first (step 0), or take the selection status from a column.")
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
        scorecard = {
          r <- pdm_scorecard_eligibility(df, if (is.null(user_setup)) NULL else user_setup$scorecard)
          if (length(r$missing)) {
            showNotification(paste0("The scorecard cannot be applied: the PDM data lacks ", paste(r$missing, collapse = ", "), "."),
                             type = "error", duration = 12)
            return()
          }
          r$eligible
        },
        rules = {
          rs <- if (is.null(user_setup)) NULL else user_setup$rules
          if (is.null(rs) || ruleset_is_empty(rs)) { showNotification("No eligibility rules are saved yet.", type = "error"); return() }
          ev <- ruleset_eval(df, rs, user_setup)
          if (length(ev$unresolved)) {
            showNotification(paste0("The rules cannot be applied: the PDM data lacks ", paste(ev$unresolved, collapse = ", "), "."),
                             type = "error", duration = 12)
            return()
          }
          ev$mask
        },
        { req(input$pdm_eligibility); eligibility_flag(df[[input$pdm_eligibility]]) })

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

      # a decision per area, while it can still be acted on
      tol <- c((input$tol_lower %||% 5) / 100, (input$tol_upper %||% 20) / 100)
      decisions <- if (!is.null(unit_col) && unit_col %in% names(df))
        ptm_area_decisions(benef, elig, df[[unit_col]], wts, tol[1], tol[2], before = !identical(input$data_kind, "PDM"))
      results(list(
        metrics = metrics,
        decisions = decisions,
        kind = input$data_kind %||% "Baseline",
        from_design = from_design,
        by_unit = by_unit,
        confusion = confusion,
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
        elig_source = switch(src, scorecard = "the adopted scorecard, applied to the PDM answers",
                             rules = "the eligibility rules, applied to the PDM answers",
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
      sc <- if (is.null(user_setup)) NULL else user_setup$scorecard
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
      sc <- user_setup$scorecard; df <- pdm_df()
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
          "Draw the verification sample (step 0), survey it before distribution, then load the survey in step 1 and set up steps 2 to 4. A PDM extract can be loaded instead.",
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

    output$pdm_plot <- render_echart({
      r <- results(); req(r)
      m <- r$metrics
      d <- data.frame(
        metric = c("Implementation inclusion error",
                   "Implementation exclusion error", "Coverage"),
        value = c(m$inclusion_error, m$exclusion_error, m$coverage_rate),
        colour = c("#c5192d", "#f7b825", "#3f7e44"),
        stringsAsFactors = FALSE
      )
      d <- d[!is.na(d$value), , drop = FALSE]
      req(nrow(d) > 0)
      # the colours carry the meaning: inclusion, exclusion, coverage
      list(tooltip = list(trigger = "item", formatter = "fn:tip"),
           grid = list(left = 8, right = 16, top = 24, bottom = 8, containLabel = TRUE),
           xAxis = list(type = "category", data = d$metric, axisLabel = list(interval = 0, width = 110, overflow = "break")),
           yAxis = Filter(Negate(is.null), list(type = "value", min = 0, max = if (max(d$value) > 0.8) 1,
                                                axisLabel = list(formatter = "fn:pct"))),
           series = list(list(type = "bar", barMaxWidth = 70,
                              label = list(show = TRUE, position = "top", formatter = "fn:pct1"),
                              data = lapply(seq_len(nrow(d)), function(i) list(
                                value = d$value[i], itemStyle = list(color = d$colour[i]),
                                tip = sprintf("%s: <b>%.1f%%</b>", d$metric[i], 100 * d$value[i]))))))
    }, height = 300)

    output$pdm_by_unit <- render_react_table({
      r <- results(); req(r)
      if (is.null(r$by_unit) || nrow(r$by_unit) == 0) {
        return(data.frame(Message = "Pick a breakdown column to see coverage by unit."))
      }
      cov <- r$by_unit
      colnames(cov) <- c(r$unit_col, "Eligible (w)", "Reached (w)", "Coverage")
      cov
    }, formats = list(`Eligible (w)` = "int", `Reached (w)` = "int", Coverage = "pct1"),
    styles = list(Coverage = list(bar = "#0A6EB4")))

    # --- Export -----------------------------------------------------------
    output$pdm_download <- download_handler(
      filename = function() export_file_name("Targeting_PDM_Accuracy", "xlsx", "%Y-%m-%d_%Hh%Mm%Ss"),
      content = function(file) {
        r <- results()
        wb <- openxlsx::createWorkbook()

        openxlsx::addWorksheet(wb, "Summary")
        if (is.null(r)) {
          write_data(wb, "Summary", data.frame(Message = "No analysis has been run."))
        } else {
          m <- r$metrics
          summary_df <- data.frame(
            Field = c("Survey", "Country office", "Exported at", "Areas covered", "Eligibility from", "Weighting", "Records analysed", "Records with known eligibility",
                      "Eligibility column", "Beneficiary column", "Weighted",
                      "Implementation inclusion error",
                      "Implementation exclusion error", "Coverage rate",
                      "Selection ratio", "Precision", "Recall",
                      "Excluded by design (not counted as errors)"),
            Value = c(
              if (identical(r$kind, "PDM")) "Post-distribution monitoring (after distribution)" else "Post-targeting survey / baseline (before distribution)",
              country_office() %||% "",
              fmt_datetime(),
              scope$text(),
              r$elig_source %||% r$elig_col, r$weighting %||% (if (isTRUE(r$weighted)) "weight column" else "none"),
              format(r$n, big.mark = ","),
              format(r$n_known, big.mark = ","),
              r$elig_col, r$benef_col, if (isTRUE(r$weighted)) "yes" else "no",
              pct(m$inclusion_error), pct(m$exclusion_error), pct(m$coverage_rate),
              if (is.na(m$selection_ratio)) "\u2014" else sprintf("%.2f", m$selection_ratio),
              pct(m$precision), pct(m$recall),
              if (is.null(r$excl_design)) "no prioritised column mapped" else
                sprintf("%s households (%s of eligible)", format(r$excl_design$n, big.mark = ","),
                        pct(r$excl_design$share))
            ),
            stringsAsFactors = FALSE
          )
          write_data(wb, "Summary", summary_df)

          openxlsx::addWorksheet(wb, "Confusion")
          write_data(wb, "Confusion", r$confusion)

          if (!is.null(r$decisions) && nrow(r$decisions) > 0) {
            openxlsx::addWorksheet(wb, "Decisions_by_area")
            dd <- r$decisions
            write_data(wb, "Decisions_by_area", data.frame(Area = dd$area, `Selected surveyed` = dd$n_selected, `Not selected surveyed` = dd$n_not,
                                                          `Inclusion error (%)` = round(100 * dd$inclusion_error, 1),
                                                          `Exclusion error (%)` = round(100 * dd$exclusion_error, 1),
                                                          Decision = dd$decision, check.names = FALSE))
          }
          if (!is.null(r$by_unit) && nrow(r$by_unit) > 0) {
            openxlsx::addWorksheet(wb, "By_Unit")
            write_data(wb, "By_Unit", sanitize_for_excel(r$by_unit))
          }
        }
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
           elig = elig_note())
    })
    # The facts the page draws: data, sample, match, results, decisions.
    output$pdm_state <- shinyreact::reactive_output({
      df <- pdm_df(); sd <- sample_design(); r <- results(); mt <- ptm_matched()
      d <- sd$design
      m <- r$metrics
      dd <- r$decisions
      list(
        data = if (!is.null(pdm_all())) list(source = pdm_source() %||% "Data loaded", rows = NROW(df), cols = NCOL(df)),
        sample = if (!is.null(sd)) list(drawn_at = sd$drawn_at, n = sum(d$n), selected = sum(d$n[d$group == "selected"]),
                                        not_selected = sum(d$n[d$group == "not_selected"]), reserve = sum(d$reserve),
                                        areas = length(unique(d$area))),
        match = if (!is.null(mt)) list(n = mt$n, of = mt$of),
        results = if (!is.null(r)) list(
          kind = r$kind, inclusion = m$inclusion_error, exclusion = m$exclusion_error, coverage = m$coverage_rate,
          precision = m$precision, recall = m$recall, elig_source = r$elig_source %||% "a PDM column",
          weighting = r$weighting %||% "none", no_nonbenef = isTRUE(r$no_nonbenef),
          decisions = if (!is.null(dd) && nrow(dd)) lapply(seq_len(nrow(dd)), function(i) list(
            area = as.character(dd$area[i]), n_selected = dd$n_selected[i], n_not = dd$n_not[i],
            inclusion = dd$inclusion_error[i], exclusion = dd$exclusion_error[i], level = dd$level[i], decision = dd$decision[i]))))
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
