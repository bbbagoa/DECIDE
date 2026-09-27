#' PDM / Targeting Accuracy Module UI
#'
#' Phase 3 of the targeting cycle: monitoring. Loads a Post-Distribution
#' Monitoring extract carrying both an eligibility ground truth and a
#' beneficiary flag, and reports the weighted inclusion / exclusion error of
#' what was actually delivered.
#'
#' These are *implementation* errors, and they answer a different question
#' from the design errors on the Scorecard tab (Targeting Advisory 2/2025):
#'
#' * Design error     -- were the eligibility criteria themselves right?
#'                       Measured on assessment data, before anyone is served.
#' * Implementation error -- were those criteria applied correctly on the
#'                       ground? Measured on PDM data, after distribution.
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
        id = ns("setup"), multiple = TRUE, open = c("data", "benef", "elig"),
        panel("data", "1. Monitoring data", "cloud-upload",
              # The same accuracy analysis runs on a post-distribution survey or
              # on a baseline taken before distribution; the choice names the
              # data in the results, the exports and the report.
              radioButtons(ns("data_kind"), NULL,
                           choices = c("PDM (after distribution)" = "PDM", "Baseline (before distribution)" = "Baseline"),
                           selected = "PDM"),
              fileInput(ns("pdm_file"), NULL, width = "100%", accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet"),
                        placeholder = "One row per surveyed household"),
              tags$div(class = "mt-1 mb-2", mod_moda_import_ui(ns("moda"))),
              uiOutput(ns("pdm_file_status"))),
        panel("areas", "Areas covered", "geo-alt", mod_area_scope_ui(ns("scope"), title = NULL)),
        panel("benef", "2. Who received assistance", "person-check",
              pick("pdm_beneficiary", "Beneficiary column"),
              # Any column with two answers: say which one means assisted.
              uiOutput(ns("benef_level_ui")),
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
                           choices = c("Population sizes (recommended)" = "population",
                                       "A weight column" = "column", "None" = "none"),
                           selected = "population"),
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

    # Kept whole; the analysis runs on the areas covered (see mod_area_scope).
    pdm_all <- reactiveVal(NULL)
    scope <- mod_area_scope_server("scope", pdm_all, workspace, "pdm_scope", modification_log, "Monitoring")
    pdm_scoped <- reactive(scope$filter(pdm_all()))
    pdm_df <- function(value) if (missing(value)) pdm_scoped() else pdm_all(value)
    results <- reactiveVal(NULL)

    pdm_inputs <- c("pdm_eligibility", "pdm_beneficiary", "pdm_prioritized", "pdm_unit", "pdm_weight")
    workspace_register(workspace, "pdm",
      snapshot = function() {
        if (is.null(pdm_df())) return(NULL)
        list(df = pdm_all(), results = results(), source = pdm_source(),
             inputs = lapply(stats::setNames(pdm_inputs, pdm_inputs), function(k) input[[k]]),
             options = list(data_kind = input$data_kind, elig_source = input$pdm_elig_source, weight_mode = input$pdm_weight_mode,
                            pop_scope = input$pop_scope, pop_benef = input$pop_benef,
                            pop_nonbenef = input$pop_nonbenef, pop_units = pop_units(),
                            benef_level = input$pdm_benef_level,
                            tol = c(input$tol_lower, input$tol_upper)))
      },
      restore = function(s) {
        pdm_df(s$df)
        pdm_source(s$source)
        results(s$results)
        cols <- names(s$df)
        for (k in pdm_inputs) {
          ch <- if (k %in% c("pdm_eligibility", "pdm_beneficiary")) c("Choose a column" = "", cols) else c("(none)", cols)
          shinyWidgets::updatePickerInput(session, k, choices = ch, selected = s$inputs[[k]])
        }
        o <- s$options %||% list()
        if (!is.null(o$data_kind)) updateRadioButtons(session, "data_kind", selected = o$data_kind)
        if (!is.null(o$elig_source)) updateRadioButtons(session, "pdm_elig_source", selected = o$elig_source)
        if (!is.null(o$weight_mode)) updateRadioButtons(session, "pdm_weight_mode", selected = o$weight_mode)
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

    # Who received assistance: any column with exactly two answers; the
    # officer says which answer means assisted (guessed for yes/no, 1/0,
    # "Beneficiary / Non-beneficiary", "Assisted / Not assisted"...).
    benef_levels <- reactive({
      df <- pdm_df(); b <- input$pdm_beneficiary
      if (is.null(df) || !shiny::isTruthy(b) || !b %in% names(df)) return(NULL)
      two_levels(df[[b]])
    })
    output$benef_level_ui <- renderUI({
      lv <- benef_levels()
      if (is.null(lv)) return(NULL)
      if (length(lv) != 2)
        return(tags$div(class = "small text-danger mb-2", bsicons::bs_icon("exclamation-triangle"), " ",
                        sprintf("This column has %d different answers; choose one with exactly two (received / not received).", length(lv))))
      sel <- isolate(input$pdm_benef_level)
      radioButtons(ns("pdm_benef_level"), "Answer meaning 'received assistance'", choices = value_choices(lv, input$pdm_beneficiary), inline = TRUE,
                   selected = if (isTRUE(sel %in% lv)) sel else guess_positive_answer(lv))
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
    output$pop_table <- DT::renderDT({
      st <- pop_template()
      names(st) <- c("Area", "Beneficiaries surveyed", "Non-beneficiaries surveyed",
                     "Beneficiary households", "Non-beneficiary households")
      DT::datatable(st, rownames = FALSE, selection = "none",
                    editable = list(target = "cell", disable = list(columns = 0:2)),
                    options = list(dom = "t", paging = FALSE, ordering = FALSE))
    })
    observeEvent(input$pop_table_cell_edit, {
      e <- input$pop_table_cell_edit
      st <- pop_template()
      col <- c("beneficiaries", "non_beneficiaries")[e$col - 2]
      req(length(col) == 1, !is.na(col))
      st[[col]][e$row] <- suppressWarnings(as.numeric(e$value))
      pop_units(st[, c("unit", "beneficiaries", "non_beneficiaries")])
    })

    # What the eligibility source can do with this PDM file.
    output$pdm_elig_note <- renderUI({
      src <- input$pdm_elig_source %||% "column"
      if (identical(src, "column")) return(NULL)
      if (identical(src, "scorecard")) {
        sc <- if (is.null(user_setup)) NULL else user_setup$scorecard
        if (scorecard_is_empty(sc)) return(tags$div(class = "alert alert-warning small", "No scorecard is adopted yet (Targeting Design)."))
        df <- pdm_df()
        miss <- if (is.null(df)) character(0) else pdm_scorecard_eligibility(df, sc)$missing
        return(tags$div(class = if (length(miss)) "alert alert-warning small" else "small text-muted mb-2",
                        if (length(miss)) paste0("The PDM data lacks: ", paste(miss, collapse = ", "), ".")
                        else sprintf("%d criteria, eligible when score > %s.", length(sc$items), fmt5(sc$threshold %||% 0))))
      }
      rs <- if (is.null(user_setup)) NULL else user_setup$rules
      if (is.null(rs) || ruleset_is_empty(rs)) return(tags$div(class = "alert alert-warning small", "No eligibility rules are saved yet (Beneficiary Selection)."))
      tags$div(class = "small text-muted mb-2", ruleset_describe(rs, user_setup))
    })

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
      gate_button("pdm_run", !is.null(pdm_df()), "Load the PDM or baseline data first.")
      gate_button("pdm_download", !is.null(results()), "Compute the implementation errors first.")
    })

    # --- Compute ----------------------------------------------------------
    observeEvent(input$pdm_run, {
      df <- pdm_df()
      if (is.null(df)) {
        showNotification("Load a PDM dataset first.", type = "warning")
        return()
      }
      if (!shiny::isTruthy(input$pdm_beneficiary)) {
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

      benef <- benef_flag(df)
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
      wcol <- input$pdm_weight
      strata <- NULL
      wts <- if (identical(mode, "column") && !is.null(wcol) && wcol %in% names(df)) {
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

      unit_col <- input$pdm_unit
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

      results(list(
        metrics = metrics,
        by_unit = by_unit,
        confusion = confusion,
        excl_design = excl_design,
        n = nrow(df),
        n_known = sum(known),
        weighted = !identical(wts, rep(1, nrow(df))),
        weighting = switch(mode,
                           population = if (!is.null(strata) && nrow(strata) > 1) "population sizes per area" else "population sizes (overall)",
                           column = paste("weight column", wcol), "none"),
        strata = strata,
        no_nonbenef = no_nonbenef,
        elig_source = switch(src, scorecard = "the adopted scorecard, applied to the PDM answers",
                             rules = "the eligibility rules, applied to the PDM answers",
                             paste("the PDM column", input$pdm_eligibility)),
        elig_col = if (identical(src, "column")) input$pdm_eligibility else src,
        benef_col = input$pdm_beneficiary,
        unit_col = if (!is.null(unit_col) && unit_col %in% names(df)) unit_col else NA_character_
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
    output$calib_ui <- renderUI({
      sc <- if (is.null(user_setup)) NULL else user_setup$scorecard
      if (scorecard_is_empty(sc) || !is_ranking(sc))
        return(empty_state("No vulnerability ranking adopted",
                           "This tab measures the errors of a ranking built without an outcome indicator (Targeting Design, 'No outcome indicator'). A scorecard built on an outcome already has its design errors.",
                           icon = "sliders"))
      df <- pdm_df()
      if (is.null(df)) return(empty_state("Load PDM or verification data", "Data with a food-security outcome and the ranking's criteria.", icon = "upload"))
      miss <- pdm_scorecard_eligibility(df, sc)$missing
      cols <- names(df)[vapply(df, function(v) { k <- length(unique(stats::na.omit(v))); k >= 2 && k <= 12 }, logical(1))]
      tagList(
        tags$p(class = "small text-muted",
               "The adopted ranking was built without an outcome, so its inclusion and exclusion errors were unknown. Choose the food-security outcome",
               " these data carry (CARI, FCS or rCSI class...) and the level that means vulnerable: the ranking is applied to these households and its errors,",
               " its AUC and the threshold that keeps both errors lowest are measured."),
        if (length(miss)) tags$div(class = "alert alert-warning small", sprintf("These data lack %d of the ranking's criteria (%s): they cannot be scored.",
                                                                               length(miss), paste(utils::head(miss, 5), collapse = ", "))),
        bslib::layout_columns(
          col_widths = c(5, 4, 3), fill = FALSE,
          selectizeInput(ns("calib_outcome"), "Outcome in these data", choices = c("Choose a column" = "", cols), width = "100%"),
          selectInput(ns("calib_pos"), "Level meaning vulnerable", choices = NULL, width = "100%"),
          tags$div(class = "wfp-inline-action", tags$label(class = "form-label", "\u00a0"),
                   actionButton(ns("calib_run"), "Measure the errors", icon = icon("play"), class = "btn-primary w-100"))),
        uiOutput(ns("calib_result")))
    })
    observeEvent(input$calib_outcome, {
      df <- pdm_df(); req(df, shiny::isTruthy(input$calib_outcome), input$calib_outcome %in% names(df))
      lv <- outcome_levels(df[[input$calib_outcome]])
      updateSelectInput(session, "calib_pos", choices = lv, selected = guess_positive_level(lv))
    })
    observeEvent(input$calib_run, {
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
    output$calib_result <- renderUI({
      c0 <- calib(); req(c0)
      e <- c0$current; b <- c0$balanced
      pct <- function(v) if (is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
      tagList(
        bslib::layout_columns(
          col_widths = c(3, 3, 3, 3), fill = FALSE, class = "wfp-kpi-flat mt-2",
          bslib::value_box(title = "AUC of the ranking", value = if (is.na(c0$auc)) "n/a" else sprintf("%.3f", c0$auc),
                           showcase = bsicons::bs_icon("graph-up"), theme = "primary"),
          bslib::value_box(title = "Inclusion error (adopted threshold)", value = pct(e$inclusion_error),
                           showcase = bsicons::bs_icon("person-plus"), theme = "warning"),
          bslib::value_box(title = "Exclusion error (adopted threshold)", value = pct(e$exclusion_error),
                           showcase = bsicons::bs_icon("person-dash"), theme = "danger"),
          bslib::value_box(title = "Households measured", value = format(c0$n, big.mark = ","),
                           showcase = bsicons::bs_icon("people"), theme = "info")),
        tags$div(class = "small mt-2",
                 if (is.na(b$threshold)) "No threshold does better than selecting everyone on these data."
                 else sprintf("The threshold that keeps both errors lowest on these data is %s (inclusion %s, exclusion %s), against %s adopted. Re-adopt the ranking in Targeting Design with it if the data are representative.",
                              fmt5(b$threshold), pct(b$inclusion_error), pct(b$exclusion_error), fmt5(c0$threshold))),
        tags$div(class = "small text-muted mt-1",
                 sprintf("Outcome: %s = %s. An AUC near 0.5 means the ranking does not order households by this outcome: revisit the criteria or the method.",
                         c0$outcome, c0$pos)))
    })

    output$has_data <- reactive(!is.null(pdm_all()))
    outputOptions(output, "has_data", suspendWhenHidden = FALSE)

    output$pdm_hint <- renderUI({
      if (is.null(pdm_df())) {
        return(empty_state(
          "No PDM data loaded",
          "Load a Post-Distribution Monitoring extract in step 1, then set up steps 2 to 4.",
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
    output$pdm_verdict <- renderUI({
      m <- results()$metrics
      req(m)
      lower <- (input$tol_lower %||% 5) / 100
      upper <- (input$tol_upper %||% 20) / 100
      v <- tryCatch(error_verdict(m$inclusion_error, m$exclusion_error, lower, upper,
                                  stage = "implementation"),
                    error = function(e) list(level = "invalid",
                                             interpretation = conditionMessage(e),
                                             action = "Lower the upper tolerance below 50%."))
      verdict_card(
        v, stage = "implementation",
        errors = c(inclusion = m$inclusion_error, exclusion = m$exclusion_error), tolerance = c(lower, upper),
        tags$div(class = "small mt-2 text-muted",
                 sprintf("Implementation errors, judged against a %.0f%%-%.0f%% band. ",
                         100 * lower, 100 * upper),
                 "These measure whether the criteria were applied correctly on the ground, ",
                 "not whether the criteria themselves were right -- that is the design error ",
                 "on the Targeting Design tab."),
        if (!is.null(ed <- results()$excl_design)) tags$div(
          class = "small mt-2",
          tags$strong(sprintf("Excluded by design: %s households (%s of eligible).",
                              format(ed$n, big.mark = ","), pct(ed$share))),
          " Eligible but not prioritised for lack of resources: unmet need, left out of the exclusion error."
        )
      )
    })

    output$pdm_incl <- renderText(pct(results()$metrics$inclusion_error))
    output$pdm_excl <- renderText(pct(results()$metrics$exclusion_error))
    output$pdm_cov  <- renderText(pct(results()$metrics$coverage_rate))
    output$pdm_pr   <- renderText({
      m <- results()$metrics
      paste0(pct(m$precision), " / ", pct(m$recall))
    })

    output$pdm_confusion <- DT::renderDT({
      r <- results(); req(r)
      DT::datatable(r$confusion, rownames = FALSE,
                    options = list(dom = "t", ordering = FALSE)) |>
        DT::formatCurrency(c("Beneficiary", "Non-beneficiary"),
                           currency = "", interval = 3, mark = ",", digits = 0)
    })

    output$pdm_plot <- render_wfp_plotly({
      r <- results(); req(r)
      m <- r$metrics
      d <- data.frame(
        metric = c("Implementation inclusion error",
                   "Implementation exclusion error", "Coverage"),
        value = c(m$inclusion_error, m$exclusion_error, m$coverage_rate) * 100,
        stringsAsFactors = FALSE
      )
      d <- d[!is.na(d$value), , drop = FALSE]
      req(nrow(d) > 0)
      plotly::plot_ly(
        d, x = ~metric, y = ~value, type = "bar",
        marker = list(color = c("#c5192d", "#f7b825", "#3f7e44")[seq_len(nrow(d))]),
        hovertemplate = "%{x}: %{y:.1f}%<extra></extra>"
      ) |>
        plotly::layout(
          xaxis = list(title = ""),
          yaxis = list(title = "%", gridcolor = "rgba(128,128,128,0.2)")
        )
    })

    output$pdm_by_unit <- DT::renderDT({
      r <- results(); req(r)
      if (is.null(r$by_unit) || nrow(r$by_unit) == 0) {
        return(DT::datatable(
          data.frame(Message = "Pick a breakdown column to see coverage by unit."),
          rownames = FALSE, options = list(dom = "t")
        ))
      }
      cov <- r$by_unit
      cov$coverage <- paste0(round(cov$coverage * 100, 1), "%")
      colnames(cov) <- c(r$unit_col, "Eligible (w)", "Reached (w)", "Coverage")
      DT::datatable(cov, rownames = FALSE, options = list(pageLength = 15, scrollX = TRUE)) |>
        DT::formatCurrency(c("Eligible (w)", "Reached (w)"),
                           currency = "", interval = 3, mark = ",", digits = 0)
    })

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
            Field = c("Country office", "Exported at", "Areas covered", "Eligibility from", "Weighting", "Records analysed", "Records with known eligibility",
                      "Eligibility column", "Beneficiary column", "Weighted",
                      "Implementation inclusion error",
                      "Implementation exclusion error", "Coverage rate",
                      "Selection ratio", "Precision", "Recall",
                      "Excluded by design (not counted as errors)"),
            Value = c(
              country_office() %||% "",
              format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
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

          if (!is.null(r$by_unit) && nrow(r$by_unit) > 0) {
            openxlsx::addWorksheet(wb, "By_Unit")
            write_data(wb, "By_Unit", sanitize_for_excel(r$by_unit))
          }
        }
        save_workbook_readonly(wb, file)
      }
    )

    # For the Targeting Monitoring report and the PDM chart builder.
    list(
      df = pdm_scoped,
      areas = scope$text,
      name = reactive(pdm_source() %||% paste(input$data_kind %||% "PDM", "data")),
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
