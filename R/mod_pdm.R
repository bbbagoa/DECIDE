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
  # Same numbered-step cards as the selection design: set up left to right,
  # compute once, read the results in tabs below.
  step <- function(title, ...) tags$section(class = "wfp-sb-step",
                                            tags$div(class = "wfp-sb-head", tags$span(class = "wfp-sb-num"), tags$span(title)), ...)
  tagList(
    tags$div(
      class = "wfp-design-grid mt-3 wfp-pdm-grid",
      step("Monitoring data",
           # The same accuracy analysis runs on a post-distribution survey or on
           # a baseline taken before distribution; the choice names the data in
           # the results, the exports and the report.
           radioButtons(ns("data_kind"), NULL, inline = TRUE,
                        choices = c("PDM (after distribution)" = "PDM", "Baseline (before distribution)" = "Baseline"),
                        selected = "PDM"),
           tags$p(class = "small text-muted mb-2",
                  "One row per surveyed household, beneficiaries and non-beneficiaries."),
           fileInput(ns("pdm_file"), NULL, width = "100%", accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet")),
           uiOutput(ns("pdm_file_status"))),
      step("Who received assistance",
           pick("pdm_beneficiary", "Beneficiary column"),
           # Where resources did not cover every eligible household, the ones
           # cut by prioritisation are excluded by design, not exclusion errors
           # (Targeting Advisory 2/2025).
           pick("pdm_prioritized", "Prioritised column (optional)"),
           pick("pdm_unit", "Area column (optional: coverage and per-area sizes)")),
      step("Who was eligible",
           # Implementation error = were the criteria applied correctly? The
           # ground truth is the criteria, re-applied to the PDM answers.
           radioButtons(ns("pdm_elig_source"), NULL,
                        choices = c("A column in the PDM data" = "column",
                                    "Apply the adopted scorecard" = "scorecard",
                                    "Apply the eligibility rules" = "rules"),
                        selected = "column"),
           conditionalPanel(sprintf("input['%s'] === 'column'", ns("pdm_elig_source")),
                            pick("pdm_eligibility", "Eligibility column")),
           uiOutput(ns("pdm_elig_note"))),
      step("Weighting",
           # The PDM surveys set numbers of beneficiaries and non-beneficiaries;
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
               tags$div(class = "d-flex gap-2",
                        tags$div(class = "flex-fill", numericInput(ns("pop_benef"), "Beneficiary households", value = NA, min = 0, width = "100%")),
                        tags$div(class = "flex-fill", numericInput(ns("pop_nonbenef"), "Non-beneficiary households", value = NA, min = 0, width = "100%")))),
             conditionalPanel(sprintf("input['%s'] === 'unit'", ns("pop_scope")),
                              tags$div(class = "small text-muted", "Type the sizes per area in the table below."))))
    ),
    uiOutput(ns("pop_table_ui")),
    tags$div(
      class = "wfp-design-foot",
      tags$span(class = "small text-muted", bsicons::bs_icon("info-circle"),
                " Implementation errors measure whether the criteria were applied correctly on the ground, not whether they were right (that is the design error)."),
      tags$div(class = "d-flex gap-2",
               downloadButton(ns("pdm_download"), "Export (Excel)", class = "btn-outline-secondary btn-sm"),
               actionButton(ns("pdm_run"), "Compute implementation errors", class = "btn-primary btn-sm", icon = icon("calculator")))
    ),
    uiOutput(ns("pdm_hint")),
    bslib::navset_underline(
      id = ns("pdm_tabs"),
      bslib::nav_panel(
        value = "errors", title = tagList(bsicons::bs_icon("bullseye"), " Errors and verdict"),
        uiOutput(ns("pdm_results")),
        tags$div(class = "d-flex gap-3 flex-wrap align-items-end mt-2 wfp-tol-row",
                 tags$div(style = "flex: 0 1 220px;", numericInput(ns("tol_lower"), "Lower error tolerance (%)", value = 5, min = 0, max = 49, step = 1, width = "100%")),
                 tags$div(style = "flex: 0 1 220px;", numericInput(ns("tol_upper"), "Upper error tolerance (%)", value = 20, min = 1, max = 49, step = 1, width = "100%"))),
        uiOutput(ns("pdm_verdict"))
      ),
      bslib::nav_panel(
        value = "details", title = tagList(bsicons::bs_icon("table"), " Details by group and area"),
        uiOutput(ns("pdm_details"))
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

    pdm_df <- reactiveVal(NULL)
    results <- reactiveVal(NULL)

    pdm_inputs <- c("pdm_eligibility", "pdm_beneficiary", "pdm_prioritized", "pdm_unit", "pdm_weight")
    workspace_register(workspace, "pdm",
      snapshot = function() {
        if (is.null(pdm_df())) return(NULL)
        list(df = pdm_df(), results = results(),
             inputs = lapply(stats::setNames(pdm_inputs, pdm_inputs), function(k) input[[k]]),
             options = list(data_kind = input$data_kind, elig_source = input$pdm_elig_source, weight_mode = input$pdm_weight_mode,
                            pop_scope = input$pop_scope, pop_benef = input$pop_benef,
                            pop_nonbenef = input$pop_nonbenef, pop_units = pop_units(),
                            tol = c(input$tol_lower, input$tol_upper)))
      },
      restore = function(s) {
        pdm_df(s$df)
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
        if (length(o$tol) == 2) {
          updateNumericInput(session, "tol_lower", value = o$tol[1])
          updateNumericInput(session, "tol_upper", value = o$tol[2])
        }
      })

    # Population sizes per area, typed into an editable table.
    pop_units <- reactiveVal(NULL)
    pop_template <- reactive({
      df <- pdm_df(); u <- input$pdm_unit
      req(df, shiny::isTruthy(u), u %in% names(df), shiny::isTruthy(input$pdm_beneficiary), input$pdm_beneficiary %in% names(df))
      b <- eligibility_flag(df[[input$pdm_beneficiary]])
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
      pdm_df(df)
      results(NULL)
      audit_add(modification_log, "Monitoring", paste(input$data_kind %||% "PDM", "data loaded"),
                sprintf("%s (%s records)", input$pdm_file$name, nrow(df)))

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
    })

    output$pdm_file_status <- renderUI({
      df <- pdm_df()
      if (is.null(df)) return(NULL)
      tags$p(class = "text-success small mb-0",
             paste0(format(nrow(df), big.mark = ","), " records, ",
                    format(ncol(df), big.mark = ","), " variables loaded."))
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

      benef <- eligibility_flag(df[[input$pdm_beneficiary]])
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
        v <- suppressWarnings(as.numeric(as.character(df[[wcol]])))
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
        v,
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
      filename = function() paste0("Targeting_PDM_Accuracy_", format(Sys.time(), "%Y-%m-%d_%Hh%Mm%Ss"), ".xlsx"),
      content = function(file) {
        r <- results()
        wb <- openxlsx::createWorkbook()

        openxlsx::addWorksheet(wb, "Summary")
        if (is.null(r)) {
          write_data(wb, "Summary", data.frame(Message = "No analysis has been run."))
        } else {
          m <- r$metrics
          summary_df <- data.frame(
            Field = c("Country office", "Exported at", "Eligibility from", "Weighting", "PDM records", "Records with known eligibility",
                      "Eligibility column", "Beneficiary column", "Weighted",
                      "Implementation inclusion error",
                      "Implementation exclusion error", "Coverage rate",
                      "Selection ratio", "Precision", "Recall",
                      "Excluded by design (not counted as errors)"),
            Value = c(
              country_office() %||% "",
              format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
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
      df = pdm_df,
      name = reactive(if (is.null(input$pdm_file)) paste(input$data_kind %||% "PDM", "data") else input$pdm_file$name),
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
