#' Scorecard module UI
#'
#' A five-step build, in order, because each step depends on the one before:
#' choose the outcome, choose candidate criteria, screen them, fit the weights,
#' then pick the threshold against the error trade-off.
#'
#' This is the *targeting design* phase and it runs on **needs-assessment**
#' data, which is a different dataset from the registration data used to select
#' beneficiaries and different again from the PDM data used to monitor the
#' distribution. The assessment data is loaded here, not on the Welcome page:
#' it is only ever needed to build and validate the design.
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_scorecard_ui <- function(id) {
  # Drawn by React: react/src/pages/design/ (the page value scorecard_panel).
  # The parts that stay Shiny (file input, MODA, calculator, areas covered,
  # rationale editor) are rendered by the server into holders (host_*).
  tags$div(class = "wfp-react-page", `data-module` = id)
}

#' Scorecard module server
#'
#' @param id module id
#' @param uploaded_df reactiveVal holding the *registration* data. Used only so
#'   the user can point the scorecard at it when the two happen to be the same
#'   file; the scorecard otherwise loads its own assessment extract.
#' @param user_setup reactiveValues holding the mapping; the finished scorecard
#'   is stored on it so it travels inside the setup profile and can be applied
#'   by Beneficiary Selection.
#' @noRd
mod_scorecard_server <- function(id, uploaded_df, user_setup, workspace = NULL, modification_log = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # The Shiny parts of the React page (react/src/pages/design/), rendered
    # once into their holders: the file input (it streams the upload) and the
    # rationale editor. Rendered even while hidden, so their inputs exist and
    # update*Input() reaches them. MODA, the calculator and the areas covered
    # are React components on the sub-modules' ids (react/src/components/).
    hosted <- list(
      host_file = fileInput(ns("assessment_file"), NULL, width = "100%", placeholder = "Load assessment data",
                            accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet")),
      host_rationale = rich_text_input(ns("tol_rationale"), NULL,
                                       placeholder = paste("e.g. Lower 15% / upper 25% agreed with the programme",
                                                           "team given field access constraints; threshold set to",
                                                           "fit a caseload of 40% of households."),
                                       rows = 5))
    for (nm in names(hosted)) local({
      ui <- hosted[[nm]]
      output[[nm]] <- renderUI(ui)
      outputOptions(output, nm, suspendWhenHidden = FALSE)
    })

    # The assessment extract this tab works on. Deliberately separate from the
    # registration data: designing the scorecard on the same file you then
    # select from would validate the design against itself.
    # The loaded data is kept whole; the design works on the areas covered.
    # assessment_df() reads the covered part, assessment_df(value) stores new
    # data, so every existing call site keeps working.
    assessment_all <- reactiveVal(NULL)
    scope <- mod_area_scope_server("scope", assessment_all, workspace, "scorecard_scope", modification_log, "Design")
    assessment_scoped <- reactive(scope$filter(assessment_all()))
    assessment_df <- function(value) if (missing(value)) assessment_scoped() else assessment_all(value)
    assessment_source <- reactiveVal(NA_character_)

    # Loading data lands the user on step 1 rather than wherever they were
    # (in the two load handlers, so adding a calculated column does not).

    observeEvent(input$assessment_file, {
      req(input$assessment_file)
      ext <- tolower(tools::file_ext(input$assessment_file$name))
      if (!ext %in% c("xlsx", "xls", "sav", "dta", "csv", "parquet")) {
        showNotification(paste("Unsupported file type:", ext), type = "error", duration = 10)
        return()
      }
      w <- waiter::Waiter$new(html = waiter_content("Reading assessment data..."),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show(); on.exit(w$hide(), add = TRUE)

      df <- tryCatch(read_import_file(input$assessment_file$datapath, ext),
                     error = function(e) {
                       showNotification(paste("Could not read file:", conditionMessage(e)),
                                        type = "error", duration = 12)
                       NULL
                     })
      req(df)
      assessment_form(NULL)
      take_assessment(df, input$assessment_file$name)
    })
    take_assessment <- function(df, name) tw_guard("Loading the assessment data", {
      assessment_df(as.data.frame(df))
      assessment_source(name)
      audit_add(modification_log, "Design", "Assessment data loaded",
                sprintf("%s (%s rows, %s columns)", name, nrow(df), ncol(df)))
      reset_build()
      go_step("outcome")
      showNotification(sprintf("Assessment data loaded: %s rows, %s columns.",
                               format(nrow(df), big.mark = ","), ncol(df)),
                       type = "message")
    })
    # The same data can come from a MODA / ONA form.
    moda <- mod_moda_import_server("moda")
    assessment_form <- reactiveVal(NULL)   # the MODA form the data came from (saved; never the key)
    observeEvent(moda$data(), {
      df <- moda$data(); req(df)
      assessment_form(moda$credentials()$form_id)
      take_assessment(df, moda$label() %||% sprintf("MODA form %s", moda$credentials()$form_id %||% ""))
    })
    # its new submissions, later (also after a restore)
    mod_moda_refresh_server("moda_refresh", assessment_all, function(df) assessment_all(df), assessment_form,
                            "Assessment data", log = modification_log, phase = "Design")

    observeEvent(input$open_guide, { req(input$open_guide > 0); showModal(design_guide_modal()) })

    # Buttons that need an earlier step are frozen until it is done.
    observe({
      gate_button("run_fit", !is.null(assessment_df()) && length(ready_criteria()) > 0,
           "Load the assessment data, choose the outcome and the candidate criteria first.")
      todo <- tryCatch(missing_steps(), error = function(e) "finish the earlier steps")
      why <- paste0("Before adopting, ", paste(todo, collapse = ", "), ".")
      gate_button("btn_use", !length(todo), why)
      gate_button("nav_adopt", !length(todo), why)
      has_fit <- !is.null(fitted())
      gate_button("thr_youden", has_fit, "Fit a model first.")
      gate_button("thr_balanced", has_fit, "Fit a model first.")
      gate_button("thr_caseload", has_fit, "Fit a model first.")
    })

    # Whole data here: a column built on the covered part only would lose the rest.
    calc_vars <- mod_var_calc_server("calc", assessment_all, function(df) assessment_all(df),
                                     log = modification_log, phase = "Design",
                                     outcome = reactive(list(y = outcome_binary(), col = oc())))
    # WFP food security indicators (FCS, rCSI, LCS, FES, CARI) from the
    # dictionary's variables, added to the whole data like the calculator's
    mod_fs_indicators_server("fsi", assessment_all, function(df) assessment_all(df),
                             log = modification_log, created = calc_vars)
    mod_data_summary_server("summary", assessment_all, "Assessment data")

    screened <- reactiveVal(NULL)      # screening result table
    collinear <- reactiveVal(NULL)     # dropped-by-correlation map
    fitted <- reactiveVal(NULL)        # fit_scorecard_advanced() output
    split_state <- reactiveVal(NULL)   # training / evaluation rows
    bench <- reactiveVal(NULL)         # benchmark_models() output
    weight_bump <- reactiveVal(0)      # forces the weight inputs to redraw
    saved_points <- reactiveVal(NULL)  # edited points / review ticks from a saved session

    # -----------------------------------------------------------------------
    # Saved with the session: the whole design, from the data to the
    # threshold. Restoring sets the inputs back through the browser, and each
    # input change would normally rebuild (and so wipe) the later steps; while
    # `restoring()` holds the snapshot those rebuilds stand aside, and it
    # clears once the inputs are back to their saved values.
    # -----------------------------------------------------------------------
    restoring <- reactiveVal(NULL)
    rs_in <- function(k) isolate(restoring())$inputs[[k]]
    sc_inputs <- c("outcome_col", "outcome_pos", "qs_alpha", "qs_adjust", "model_method", "model_scheme",
                   "model_weights", "fit_criteria", "compare_models",
                   "stepwise", "stepwise_ic",
                   "corr_cutoff", "tol_lower", "tol_upper", "tol_rationale", "caseload_pct", "vuln_area",
                   "framework_mode", "rank_label", "anchor", "cov_area",
                   "pmt_welfare", "pmt_unit", "pmt_size", "pmt_line_mode", "pmt_line", "pmt_share")

    workspace_register(workspace, "scorecard",
      snapshot = function() {
        if (is.null(assessment_df())) return(NULL)
        pts <- tryCatch(current_weights()[, c("weight", "verifiable", "validated")], error = function(e) NULL)
        list(data = assessment_all(), source = assessment_source(), moda_form = assessment_form(), calc = calc_vars(),
             inputs = lapply(stats::setNames(sc_inputs, sc_inputs), function(k) input[[k]]),
             screened = screened(), collinear = collinear(), analyst_dropped = analyst_dropped(),
             criteria = criteria_sel(), corr_suggest = corr_suggest(), selection_applied = selection_applied(),
             fitted = fitted(), split = split_state(), bench = bench(), effects = effects(),
             runs = runs(), current_run = current_run(), points = pts,
             threshold = thr_applied(), step = input$steps, quick_screen = qs_result(), review = review(),
             exceed_note = exceed_note(), stability = stability(),
             model_params = shiny::reactiveValuesToList(model_params),
             allowed_blocked = allowed_blocked(), allowed_reason = allowed_reason(), pmt_applied = pmt_applied(),
             fw_applied = fw_applied(), pmt_numeric = pmt_numeric_sel(), tol_applied = tol_applied())
      },
      restore = function(s) {
        restoring(s)
        assessment_df(s$data); assessment_source(s$source); assessment_form(s$moda_form)
        qs_result(s$quick_screen)
        review(s$review %||% list())
        exceed_note(s$exceed_note %||% "")
        stability(s$stability)
        allowed_blocked(s$allowed_blocked %||% character(0))
        pmt_applied(s$pmt_applied)
        # sessions from before validation: what was on screen counted
        fw_applied(s$fw_applied %||% (if (!is.null(s$inputs)) list(mode = s$inputs$framework_mode %||% "outcome",
                                                                    outcome_col = s$inputs$outcome_col %||% "",
                                                                    outcome_pos = s$inputs$outcome_pos %||% "")))
        tol_applied(s$tol_applied %||% c(as.numeric(s$inputs$tol_lower %||% TOL_DEFAULT[1]), as.numeric(s$inputs$tol_upper %||% TOL_DEFAULT[2])))
        # older sessions kept one note for all
        ar <- s$allowed_reason %||% character(0)
        if (length(ar) == 1 && is.null(names(ar))) ar <- stats::setNames(rep(ar, length(allowed_blocked())), allowed_blocked())
        allowed_reason(ar)
        if (!is.null(s$calc)) calc_vars(s$calc)
        screened(s$screened); collinear(s$collinear); analyst_dropped(s$analyst_dropped %||% character(0))
        # Sessions from before the single criteria table kept the chosen
        # criteria as an input.
        criteria_sel(s$criteria %||% s$inputs$criteria %||% character(0))
        corr_suggest(s$corr_suggest %||% s$collinear)
        selection_applied(isTRUE(s$selection_applied))
        fitted(s$fitted); split_state(s$split); bench(s$bench); effects(s$effects)
        runs(s$runs %||% list()); current_run(s$current_run %||% NA_integer_)
        saved_points(s$points); weight_bump(weight_bump() + 1)
        # Inputs of a weights table already on the page take the saved values too.
        for (k in seq_len(NROW(s$points))) {
          updateNumericInput(session, paste0("w_", k), value = s$points$weight[k])
          updateCheckboxInput(session, paste0("ver_", k), value = isTRUE(s$points$verifiable[k]))
          updateCheckboxInput(session, paste0("val_", k), value = isTRUE(s$points$validated[k]))
        }
        i <- s$inputs
        # The outcome level is set here too: when the outcome column is
        # unchanged its observer never fires to set it.
        if (isTRUE(i$outcome_col %in% names(s$data))) {
          updateSelectInput(session, "outcome_pos", choices = value_choices(outcome_levels(s$data[[i$outcome_col]]), i$outcome_col),
                            selected = i$outcome_pos)
        }
        updateSelectInput(session, "model_method", selected = i$model_method)
        updateSelectInput(session, "model_scheme", selected = i$model_scheme)
        if (!is.null(i$qs_adjust)) updateSelectInput(session, "qs_adjust", selected = i$qs_adjust)
        # model settings (older sessions kept them as inputs)
        mp <- s$model_params %||% list(pca_mode = i$pca_mode, pca_axes = i$pca_axes, pca_min_var = i$pca_min_var, n_clusters = i$n_clusters,
                                       holdout_pct = i$holdout_pct, split_seed = i$split_seed)
        for (k in names(mp)) if (!is.null(mp[[k]])) model_params[[k]] <- mp[[k]]
        if (!is.null(i$framework_mode)) shinyWidgets::updateRadioGroupButtons(session, "framework_mode", selected = i$framework_mode)
        if (!is.null(i$rank_label)) updateTextInput(session, "rank_label", value = i$rank_label)
        if (identical(i$framework_mode, "none"))
          updateSelectInput(session, "model_method", choices = unsupervised_model_choices(), selected = i$model_method)
        if (identical(i$framework_mode, "pmt")) {
          updateSelectInput(session, "model_method", choices = pmt_model_choices(), selected = i$model_method)
          cols <- names(s$data)
          updateSelectInput(session, "pmt_welfare", choices = cols, selected = i$pmt_welfare)
          updateSelectInput(session, "pmt_size", choices = c("(none)" = "", cols), selected = i$pmt_size %||% "")
          for (k in c("pmt_unit", "pmt_line_mode")) if (!is.null(i[[k]])) updateSelectInput(session, k, selected = i[[k]])
          for (k in c("pmt_line", "pmt_share")) if (length(i[[k]]) == 1) updateNumericInput(session, k, value = i[[k]])
          pmt_num_default(s$pmt_numeric %||% i$pmt_numeric)
        }
        for (k in c("corr_cutoff", "qs_alpha", "tol_lower", "tol_upper", "caseload_pct")) {
          if (length(i[[k]]) == 1 && is.finite(suppressWarnings(as.numeric(i[[k]])))) updateNumericInput(session, k, value = i[[k]])
        }
        if (!is.null(i$compare_models)) shinyWidgets::updatePickerInput(session, "compare_models", selected = i$compare_models)
        # Older sessions kept stepwise as a checkbox and a direction.
        sw <- i$stepwise %||% (if (isTRUE(i$stepwise_on)) i$stepwise_dir %||% "backward" else if (!is.null(i$stepwise_on)) "none")
        if (!is.null(sw)) updateSelectInput(session, "stepwise", selected = sw)
        if (!is.null(i$stepwise_ic)) updateSelectInput(session, "stepwise_ic", selected = i$stepwise_ic)
        # A session from before stepwise became an option.
        if (identical(i$model_method, "stepwise")) {
          updateSelectInput(session, "model_method", selected = "logit")
          updateSelectInput(session, "stepwise", selected = "backward")
        }
        if (!is.null(i$tol_rationale)) update_rich_text(session, "tol_rationale", i$tol_rationale)
        if (!is.null(s$threshold)) {
          thr_pending(s$threshold)
          set_threshold(s$threshold)
        }
        if (!is.null(s$step)) go_step(if (identical(s$step, "criteria")) "screening" else s$step)
        # Safety net: never leave the rebuilds switched off. It starts once the
        # restored design has been drawn (which takes seconds on large data):
        # counting from here, it fired while the browser was still sending the
        # inputs back, and the next rebuild wiped the fitted model.
        # A browser that closed meanwhile has nothing to clear (an error in a
        # later() callback would stop the whole app).
        after_flush(session, function() later::later(function() {
          if (!isTRUE(session$isClosed())) try(shiny::withReactiveDomain(session, restoring(NULL)), silent = TRUE)
        }, 30))
      })

    observe({
      s <- restoring(); req(s)
      i <- s$inputs
      nof_r <- !identical(i$framework_mode %||% "outcome", "outcome")   # no binary outcome to wait for
      same_in <- function(k) identical(as.character(input[[k]] %||% ""), as.character(i[[k]] %||% ""))
      back <- identical(input$framework_mode %||% "outcome", i$framework_mode %||% "outcome") &&
        (nof_r || identical(input$outcome_col %||% "", i$outcome_col %||% "")) &&
        (nof_r || identical(input$outcome_pos %||% "", i$outcome_pos %||% "")) &&
        (!identical(i$framework_mode, "pmt") || all(vapply(c("pmt_welfare", "pmt_unit", "pmt_line_mode", "pmt_line", "pmt_share"), same_in, logical(1)))) &&
        identical(input$model_scheme %||% "", i$model_scheme %||% "") &&
        # the screening settings too: a change there screens again
        identical(input$qs_adjust %||% "BH", i$qs_adjust %||% "BH") &&
        isTRUE(all.equal(as.numeric(input$qs_alpha %||% 0.05), as.numeric(i$qs_alpha %||% 0.05))) &&
        isTRUE(all.equal(as.numeric(input$corr_cutoff %||% 0.8), as.numeric(i$corr_cutoff %||% 0.8)))
      # points, flags and threshold already on the page must be back too
      same <- function(v, w) is.null(v) || isTRUE(all.equal(as.numeric(v), as.numeric(w)))
      pts <- s$points
      for (k in seq_len(NROW(pts))) {
        back <- back && same(input[[paste0("w_", k)]], pts$weight[k]) &&
          same(input[[paste0("ver_", k)]], isTRUE(pts$verifiable[k])) &&
          same(input[[paste0("val_", k)]], isTRUE(pts$validated[k]))
      }
      back <- back && (is.null(s$threshold) || same(input$threshold, s$threshold))
      if (back) restoring(NULL)
    }, priority = -100)

    # A screen or a fit belongs to the dataset it was run on. Swapping the
    # assessment data without clearing them would show weights from the old
    # file beside criteria from the new one.
    reset_build <- function() {
      screened(NULL)
      collinear(NULL)
      fitted(NULL)
      split_state(NULL)
      bench(NULL)
    }

    # -----------------------------------------------------------------------
    # Guided flow
    #
    # Each step states what it needs, and finishes by handing over to the next
    # one. A step whose prerequisite is missing shows what to do and a button
    # that goes there, instead of an empty control the user has to guess at.
    # -----------------------------------------------------------------------

    go_step <- function(v) bslib::nav_select("steps", v, session = session)

    observeEvent(input$nav_next_outcome, { req(input$nav_next_outcome > 0); go_step("screening") })
    observeEvent(input$nav_back_screening, { req(input$nav_back_screening > 0); go_step("outcome") })
    observeEvent(input$nav_back_weights, { req(input$nav_back_weights > 0); go_step("screening") })
    observeEvent(input$nav_next_weights, { req(input$nav_next_weights > 0); go_step("threshold") })
    observeEvent(input$nav_back_threshold, { req(input$nav_back_threshold > 0); go_step("weights") })

    observeEvent(input$back_to_criteria, { req(input$back_to_criteria > 0); go_step("screening") })
    observeEvent(input$back_to_outcome, { req(input$back_to_outcome > 0); go_step("outcome") })
    observeEvent(input$back_to_screening, { req(input$back_to_screening > 0); go_step("screening") })
    observeEvent(input$back_to_weights, { req(input$back_to_weights > 0); go_step("weights") })

    # The sidebar checklist doubles as navigation.

    # -----------------------------------------------------------------------
    # Step 1: the outcome
    # -----------------------------------------------------------------------

    # Binary columns are the only things that can be an outcome or a criterion.
    binary_cols <- reactive({
      df <- assessment_df()
      req(df)
      nm <- names(df)
      nm[vapply(nm, function(cl) !is.null(as_binary_criterion(df[[cl]])), logical(1))]
    })

    observeEvent(assessment_df(), {
      df <- assessment_df()
      req(df)
      cols <- binary_cols()
      # The outcome SHOULD be an outcome indicator, so those come first -- the
      # opposite of the criteria list -- ranked with CARI at the top.
      likely <- rank_outcome_candidates(
        intersect(outcome_like_columns(names(df)), cols), df
      )
      choices <- unique(c(likely, cols))
      # Keep the current outcome when the data only gained a column.
      cur <- rs_in("outcome_col") %||% isolate(input$outcome_col)
      updateSelectInput(session, "outcome_col", choices = choices,
                        selected = if (isTRUE(cur %in% choices)) cur
                                   else if (length(likely)) likely[1] else NULL)
    })

    observeEvent(input$outcome_col, {
      df <- assessment_df()
      req(df, input$outcome_col %in% names(df))
      lv <- outcome_levels(df[[input$outcome_col]])
      pos <- rs_in("outcome_pos")
      updateSelectInput(session, "outcome_pos", choices = value_choices(lv, input$outcome_col),
                        selected = if (isTRUE(pos %in% lv)) pos else guess_positive_level(lv))
    })

    # No outcome indicator: the design ranks households instead of predicting.
    no_outcome <- reactive(identical(input$framework_mode, "none"))
    # A welfare measure (proxy means test): the outcome is being poor, welfare
    # per person at or below the line.
    pmt <- reactive(identical(input$framework_mode, "pmt"))
    # The welfare setup counts once it is validated: nothing is computed
    # while the line is still being typed.
    pmt_applied <- reactiveVal(NULL)
    pmt_now <- function() list(welfare = input$pmt_welfare %||% "", unit = input$pmt_unit %||% "hh",
                               size = input$pmt_size %||% "", mode = input$pmt_line_mode %||% "value",
                               line = suppressWarnings(as.numeric(input$pmt_line %||% NA)),
                               share = suppressWarnings(as.numeric(input$pmt_share %||% NA)),
                               weights = input$model_weights %||% "")
    observeEvent(input$pmt_validate, {
      req(input$pmt_validate > 0)   # a React button sends 0 at start
      df <- assessment_df(); need_ok(!is.null(df), "Load the assessment data first.")
      st <- pmt_now()
      need_ok(nzchar(st$welfare) && st$welfare %in% names(df), "Choose the welfare variable.")
      need_ok(identical(st$unit, "pc") || (nzchar(st$size) && st$size %in% names(df)),
              "Choose the household size: the welfare is per household.")
      if (identical(st$mode, "share")) need_ok(isTRUE(is.finite(st$share) && st$share > 0 && st$share < 100),
                                               "Enter the share of households below the line (between 0 and 100).")
      else need_ok(isTRUE(is.finite(st$line) && st$line > 0), "Enter the poverty line per person (above zero).")
      pmt_applied(st)
      fw_applied(list(mode = "pmt", outcome_col = "", outcome_pos = ""))
      audit_add(modification_log, "Design", "PMT setup validated",
                sprintf("Welfare %s (%s), poverty line %s", st$welfare, if (identical(st$unit, "pc")) "per person" else paste("per household /", st$size),
                        if (identical(st$mode, "share")) sprintf("at the poorest %s%%", st$share) else fmt5(st$line)))
    })
    pmt_pc <- reactive({
      df <- assessment_df(); a <- pmt_applied()
      req(pmt(), df, a, a$welfare %in% names(df))
      per_hh <- !identical(a$unit, "pc")
      req(!per_hh || a$size %in% names(df))
      pmt_welfare(df[[a$welfare]], if (per_hh) df[[a$size]])
    })
    model_weight_vec <- function(df) {
      wcol <- input$model_weights
      if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]] else NULL
    }
    pmt_line_value <- reactive({
      a <- pmt_applied(); req(a)
      if (identical(a$mode, "share")) {
        req(isTRUE(is.finite(a$share) && a$share > 0 && a$share < 100))
        df <- assessment_df()
        pmt_line_from_share(pmt_pc(), a$share / 100, if (nzchar(a$weights %||% "") && a$weights %in% names(df)) df[[a$weights]])
      } else {
        req(isTRUE(is.finite(a$line) && a$line > 0)); a$line
      }
    })
    # The framework counts once validated: choosing the outcome, the level,
    # the mode or the welfare setup computes nothing until Validate.
    fw_applied <- reactiveVal(NULL)
    fw_now <- function() list(mode = input$framework_mode %||% "outcome", outcome_col = input$outcome_col %||% "",
                              outcome_pos = input$outcome_pos %||% "")
    fw_is <- function(mode) { a <- fw_applied(); !is.null(a) && identical(a$mode, mode) && identical(input$framework_mode %||% "outcome", mode) }
    validate_framework <- function() {
      df <- assessment_df(); need_ok(!is.null(df), "Load the assessment data first.")
      st <- fw_now()
      if (identical(st$mode, "outcome")) {
        need_ok(nzchar(st$outcome_col) && st$outcome_col %in% names(df), "Choose the outcome variable.")
        need_ok(nzchar(st$outcome_pos), "Choose the level that means vulnerable.")
      }
      fw_applied(st)
      audit_add(modification_log, "Design", "Vulnerability framework validated",
                switch(st$mode, none = "No outcome indicator: vulnerability ranking",
                       pmt = "Welfare measure: proxy means test",
                       sprintf("Outcome %s, vulnerable = %s", st$outcome_col, st$outcome_pos)))
    }
    observeEvent(input$fw_validate, { req(input$fw_validate > 0); validate_framework() })
    observeEvent(input$fw_validate_none, { req(input$fw_validate_none > 0); validate_framework() })
    outcome_binary <- reactive({
      df <- assessment_df()
      if (pmt()) { req(fw_is("pmt")); return(pmt_poor(pmt_pc(), pmt_line_value())) }
      a <- fw_applied()
      req(!no_outcome(), df, fw_is("outcome"), a$outcome_col %in% names(df))
      as_binary_outcome(df[[a$outcome_col]], a$outcome_pos)
    })
    # The column the outcome comes from, and its "vulnerable" level, whatever the framework.
    oc <- function() if (pmt()) pmt_applied()$welfare %||% "" else fw_applied()$outcome_col %||% ""
    # PMT words for the generic ones on the page (poor, leakage, under-coverage)
    W <- function(x) if (isTRUE(pmt())) pmt_wording(x) else x
    grp_of <- function(y) ifelse(y == 1, W("Vulnerable"), W("Not vulnerable"))
    vn_cols <- function() stats::setNames(c("#c5192d", "#3f7e44"), W(c("Vulnerable", "Not vulnerable")))
    opos <- function() if (pmt()) "at or below the poverty line" else fw_applied()$outcome_pos %||% ""
    framework_ready <- reactive({
      if (is.null(assessment_df())) return(FALSE)
      if (no_outcome()) return(fw_is("none"))
      if (pmt()) return(fw_is("pmt") && !is.null(tryCatch(outcome_binary(), error = function(e) NULL)))
      fw_is("outcome")
    })
    card_kind <- function() if (no_outcome()) "ranking" else if (pmt()) "pmt" else "scorecard"
    # What a PMT card carries besides its points: turning a score back into
    # predicted welfare, and where the line is.
    pmt_card <- function() {
      f <- fitted()$pmt
      if (!pmt() || is.null(f)) return(NULL)
      a <- pmt_applied()
      list(intercept = f$intercept, line = f$line, method = f$method, welfare = a$welfare,
           unit = a$unit, size = if (identical(a$unit, "hh")) a$size, r2 = f$r2, r2_test = f$r2_test)
    }

    # --- The welfare measure (proxy means test) -----------------------------
    observeEvent(assessment_df(), {
      df <- assessment_df(); req(df)
      nums <- names(df)[vapply(df, function(v) (is.numeric(v) || is.character(v)) && !inherits(v, c("Date", "POSIXt")) &&
                                 length(unique(v)) >= 10 && mean(!is.na(as_number(v[!is.na(v)]))) >= 0.95, logical(1))]
      like <- grepl("expend|consum|welfare|income|revenu|d[e\u00e9]pense|tot_?exp|pc_?exp|pce", nums, ignore.case = TRUE)
      cur <- rs_in("pmt_welfare") %||% isolate(input$pmt_welfare)
      ch <- c(nums[like], nums[!like])
      updateSelectInput(session, "pmt_welfare", choices = ch, selected = if (isTRUE(cur %in% ch)) cur else if (any(like)) nums[like][1] else "")
      sz <- names(df)[vapply(df, function(v) {
        x <- as_number(v); x <- x[!is.na(x)]
        length(x) > 0 && all(x >= 1 & x <= 60 & x == round(x))
      }, logical(1))]
      cur_s <- rs_in("pmt_size") %||% isolate(input$pmt_size)
      guess <- find_guess(sz, c("hh_size", "hhsize", "household_size", "size", "taille", "members", "nb_membres"))
      updateSelectInput(session, "pmt_size", choices = c("(none)" = "", sz),
                        selected = if (isTRUE(cur_s %in% sz)) cur_s else guess %||% "")
    })
    # Numeric proxies: every observable number, household size first.
    # Numeric proxies: every observable number, profiled once when the setup
    # is validated; ticking one computes nothing.
    pmt_num_prof <- reactiveVal(NULL)
    pmt_num_default <- reactiveVal(NULL)     # ticks from a saved session
    pnum_id <- function(cl) paste0("pnum_", gsub("[^A-Za-z0-9]", "_", cl))
    observeEvent(list(pmt_applied(), assessment_df()), {
      df <- assessment_df(); a <- pmt_applied()
      if (is.null(df) || is.null(a)) { pmt_num_prof(NULL); return() }
      cand <- pmt_numeric_candidates(df, exclude = c(a$welfare, a$weights))
      if (nzchar(a$size %||% "") && a$size %in% names(df)) cand <- unique(c(a$size, cand))
      pc <- tryCatch(pmt_pc(), error = function(e) NULL)
      if (!length(cand) || is.null(pc)) { pmt_num_prof(NULL); return() }
      d <- pmt_numeric_profile(df, cand, pc)
      keep <- pmt_num_default() %||% isolate(pmt_numeric_sel())
      d$use <- if (length(keep)) d$proxy %in% keep else d$proxy %in% a$size
      pmt_num_prof(d)
    })
    pmt_numeric_sel <- reactive({
      d <- pmt_num_prof(); if (is.null(d)) return(character(0))
      d$proxy[vapply(seq_len(nrow(d)), function(i) { v <- input[[pnum_id(d$proxy[i])]]; if (is.null(v)) isTRUE(d$use[i]) else isTRUE(v) }, logical(1))]
    })

    # -----------------------------------------------------------------------
    # Step 2: the candidate criteria
    # -----------------------------------------------------------------------

    blockers <- reactive({
      df <- assessment_df()
      req(df)
      criterion_blockers(df, names(df), if (no_outcome()) "" else oc(), strict = !no_outcome())
    })

    # The analyst decides last: a column blocked by a rule (outcome indicator,
    # not observable, identifier) can be allowed back, with a reason that goes
    # to the audit trail and the report. The outcome itself, constants and
    # non yes/no columns are not judgement calls and stay out.
    allowed_blocked <- reactiveVal(character(0))
    allowed_reason <- reactiveVal(character(0))   # the note given for each allowed column
    overridable <- reactive({
      b <- blockers()
      rule <- vapply(b, function(x) grepl("Advisory 1/2025|Not observable|identification variable", x), logical(1))
      intersect(names(b)[rule], binary_cols())
    })
    eligible_criteria <- reactive({
      setdiff(binary_cols(), setdiff(names(blockers()), intersect(allowed_blocked(), overridable())))
    })

    # The criteria sent to the model from the criteria table.
    criteria_sel <- reactiveVal(character(0))
    corr_suggest <- reactiveVal(NULL)   # overlap drops proposed by the screening

    # --- Vulnerable households by area (step 1) ------------------------------
    observeEvent(assessment_df(), {
      df <- assessment_df(); req(df)
      cols <- names(df)[vapply(df, function(v) { k <- length(unique(v)); k >= 2 && k <= 200 }, logical(1))]
      cols <- setdiff(cols, isolate(oc()))
      cur <- rs_in("vuln_area") %||% isolate(input$vuln_area)
      sc_col <- tryCatch(isolate(scope$applied())[[1]]$col, error = function(e) NULL)
      guess <- find_guess(cols, c("admin1", "adm1", "province", "region", "state", "governorate", "departement"))
      sel <- if (isTRUE(cur %in% cols)) cur else if (isTRUE(sc_col %in% cols)) sc_col else guess
      updateSelectInput(session, "vuln_area", choices = c("(none)" = "", cols), selected = sel %||% "")
    })
    vuln_area_tab <- reactive({
      df <- assessment_df(); a <- input$vuln_area
      req(df, shiny::isTruthy(a), a %in% names(df))
      y <- tryCatch(outcome_binary(), error = function(e) NULL); req(y)
      vulnerability_by_area(df[[a]], y)
    })
    # 100% stacked columns: vulnerable and not vulnerable in each area, the
    # dotted line at the share vulnerable overall.
    output$vuln_area_plot <- render_echart({
      validate(need(shiny::isTruthy(input$vuln_area),
                    W("Choose the area column (for example the province) to see where the vulnerable households are.")))
      d <- tryCatch(vuln_area_tab(), error = function(e) NULL)
      validate(need(!is.null(d), "Choose the outcome first."))
      y <- outcome_binary()
      overall <- 100 * mean(y == 1, na.rm = TRUE)
      ec_area_share(d, overall, W(c("Vulnerable", "Not vulnerable")), W("All areas: %.0f%% vulnerable"))
    })

    # Allowing blocked columns back: the analyst's call, recorded (the
    # picker, note and button are drawn by the page from sc_blocked).
    observeEvent(input$allow_apply, {
      req(input$allow_apply > 0)   # a React button sends 0 at start
      pick <- intersect(input$allow_blocked %||% character(0), overridable())
      was <- allowed_blocked()
      if (setequal(pick, was)) { showNotification("No change to the allowed columns.", type = "message"); return() }
      added <- setdiff(pick, was); removed <- setdiff(was, pick)
      reason <- trimws(input$allow_reason %||% "")
      notes <- allowed_reason()[intersect(names(allowed_reason()), pick)]
      if (length(added)) notes[added] <- if (nzchar(reason)) reason else "no note given"
      allowed_blocked(pick); allowed_reason(notes)
      updateTextInput(session, "allow_reason", value = "")
      if (length(added)) audit_add(modification_log, "Design", "Blocked column allowed as a criterion",
                                   paste(sprintf("%s (%s)", added, vapply(added, function(a) blockers()[[a]], character(1))), collapse = "; "),
                                   reason = reason)
      if (length(removed)) audit_add(modification_log, "Design", "Blocked column no longer allowed", paste(removed, collapse = ", "))
      showNotification(sprintf("%d blocked column%s allowed as criteria%s.", length(pick), if (length(pick) == 1) "" else "s",
                               if (length(added)) paste0(": ", paste(added, collapse = ", ")) else ""), type = "message", duration = 6)
    })

    # The columns that cannot be criteria, by reason, and those allowed back
    # (React: StepCriteria's BlockedNote; the stamp resets the picker to the
    # allowed columns, as the Shiny redraw did).
    output$sc_blocked <- shinyreact::reactive_output({
      b <- blockers()
      grp <- function(key) b[vapply(b, function(x) grepl(key, x, fixed = TRUE), logical(1))]
      g <- list(outcome = grp("Advisory 1/2025"), unobs = grp("Not observable"), ids = grp("identification variable"))
      if (!any(lengths(g))) return(list(none = TRUE))
      ov <- overridable(); al <- intersect(allowed_blocked(), names(b))
      groups <- lapply(names(g), function(k) {
        v <- names(g[[k]]); v <- v[!v %in% al]
        if (length(v)) list(kind = k, n = length(v), cols = I(utils::head(v, 25)), more = length(v) > 25)
      })
      ala <- intersect(allowed_blocked(), ov)
      list(none = FALSE, nof = no_outcome(), groups = Filter(Negate(is.null), groups), overridable = I(ov),
           allowed = lapply(ala, function(a) list(col = a, note = if (is.na(allowed_reason()[a])) NA else unname(allowed_reason()[[a]]))),
           stamp = stamp())
    })

    # -----------------------------------------------------------------------
    # Step 2: the criteria table
    # -----------------------------------------------------------------------

    # Every yes/no variable of the data (outcome indicators and the outcome
    # left out), rebuilt when the outcome or the data change -- including when
    # a suggested yes/no version is created. Those with a gap of 5 points or
    # more start ticked.
    observeEvent(list(fw_applied(), pmt_applied(), assessment_df(), input$framework_mode, allowed_blocked()), {
      if (!is.null(isolate(restoring()))) return()
      df <- assessment_df()
      nof <- no_outcome()
      if (!framework_ready()) { screened(NULL); fitted(NULL); return() }
      crit <- tryCatch(if (nof) eligible_criteria() else setdiff(eligible_criteria(), oc()), error = function(e) character(0))
      y <- tryCatch(outcome_binary(), error = function(e) NULL)
      collinear(character(0)); analyst_dropped(character(0)); corr_suggest(NULL)
      criteria_sel(character(0)); selection_applied(FALSE)
      if (nof && !is.null(df) && length(crit)) {
        # Nothing to test against: variables met by 5% to 95% of households
        # start ticked (the overlap rule then unticks repeats).
        prof <- criteria_profile(df, crit, rep(NA_integer_, nrow(df)))
        prof$direction <- NA_character_
        prof$retained <- !is.na(prof$prevalence) & prof$prevalence >= 0.05 & prof$prevalence <= 0.95 & prof$missing <= 0.2
        prof <- prof[order(!prof$retained, prof$criterion), , drop = FALSE]
        rownames(prof) <- NULL
        qs_for(NULL)
        screened(prof); fitted(NULL)
        return()
      }
      if (is.null(df) || !length(crit) || is.null(y)) { screened(NULL); return() }
      prof <- criteria_profile(df, crit, y)
      prof$direction <- ifelse(prof$gap >= 0, "inclusion", "exclusion")
      prof$retained <- !is.na(prof$gap) & abs(prof$gap) >= 0.05
      prof <- prof[order(-abs(prof$gap)), , drop = FALSE]
      rownames(prof) <- NULL
      screened(prof)
      fitted(NULL)
    }, ignoreNULL = FALSE)

    selection_applied <- reactiveVal(FALSE)
    analyst_dropped <- reactiveVal(character(0))

    # Quick screening: a univariate test per candidate. It runs by itself on
    # the table's variables (and again when its settings change) and sets the
    # Use ticks: the associated variables, less the weaker of any pair that
    # repeats each other.
    qs_result <- reactiveVal(NULL)
    qs_for <- reactiveVal(NULL)
    run_qs <- function(quiet = FALSE) {
      df <- assessment_df(); res <- screened()
      if (is.null(df) || is.null(res) || !nrow(res)) return(invisible())
      # a PMT tests each criterion against being poor
      if (pmt()) df$.pmt_poor <- tryCatch(outcome_binary(), error = function(e) NA_integer_)
      r <- if (no_outcome()) NULL else tryCatch(screen_criteria(df, if (pmt()) ".pmt_poor" else input$outcome_col, res$criterion,
                                    alpha = input$qs_alpha %||% 0.05, adjust = input$qs_adjust %||% "BH",
                                    outcome_positive = if (pmt()) "1" else input$outcome_pos),
                    error = function(e) { if (!quiet) showNotification(paste("Screening failed:", conditionMessage(e)), type = "error"); NULL })
      qs_result(r); qs_for(res$criterion); qs_params(qs_now())
      # When none is associated, the ticks by gap (5 points or more) stay.
      sig <- if (is.null(r)) character(0) else r$criterion[which(r$significant)]
      base <- if (length(sig)) sig else res$criterion[which(res$retained)]
      sug <- drop_collinear(df, base, cutoff = input$corr_cutoff %||% 0.8)$dropped
      corr_suggest(sug)
      res$retained <- res$criterion %in% setdiff(base, names(sug))
      screened(res)
    }
    observeEvent(screened(), {
      if (!is.null(isolate(restoring()))) return()
      res <- screened()
      if (is.null(res)) { qs_result(NULL); qs_for(NULL); return() }
      if (!identical(sort(res$criterion), sort(isolate(qs_for()) %||% character(0)))) run_qs(quiet = TRUE)
    }, ignoreNULL = FALSE)
    # The tests run by themselves only when the variables change (new data, new
    # outcome, binarised variables); a change of settings waits for Run.
    qs_params <- reactiveVal(NULL)
    qs_now <- function() list(alpha = input$qs_alpha %||% 0.05, adjust = input$qs_adjust %||% "BH", cutoff = input$corr_cutoff %||% 0.8)
    observeEvent(input$qs_run, {
      req(input$qs_run > 0)   # a React button sends 0 at start
      need_ok(!is.null(screened()), "Set the vulnerability framework first.")
      run_qs()
      showNotification("Tests run: the Use ticks follow the new results.", type = "message", duration = 5)
    })

    # The ticks as they are on the page (the saved state before it is drawn).
    use_id <- function(cr) rv_id("use", cr)
    use_now <- reactive({
      res <- screened(); req(res)
      vapply(seq_len(nrow(res)), function(i) {
        v <- input[[use_id(res$criterion[i])]]
        if (is.null(v)) isTRUE(res$retained[i]) else isTRUE(v)
      }, logical(1))
    })
    # What the page shows (ticked count, step status): once the ticks settle.
    # Ticking every row from the header sends one input per row; redrawing the
    # status after each one made the count crawl for seconds on a long table.
    # Actions (Continue, correlations) read use_now() itself, never a late copy.
    use_shown <- debounce(use_now, 150)

    # Overlap: for each associated or ticked variable, the one of that set it
    # correlates with most (one correlation matrix per screening).
    overlap <- reactive({
      res <- screened(); req(res)
      r <- qs_result()
      set <- unique(stats::na.omit(c(res$criterion[which(res$retained)], if (!is.null(r)) r$criterion[which(r$significant)])))
      if (length(set) < 2) return(NULL)
      cm <- criteria_cor(assessment_df(), set)
      a <- abs(cm); diag(a) <- NA
      data.frame(criterion = set,
                 r = apply(a, 1, function(v) if (all(is.na(v))) NA_real_ else max(v, na.rm = TRUE)),
                 with = set[apply(a, 1, function(v) if (all(is.na(v))) NA_integer_ else which.max(v))],
                 stringsAsFactors = FALSE)
    })

    # Correlations of the ticked variables, in a dialog run only when asked:
    # the groups correlated above the cut-off and which member of each to
    # remove (proposed, editable), not the whole matrix.
    corr_groups <- reactiveVal(NULL)
    corr_request <- reactiveVal(NULL)   # the threshold asked for, once Find is clicked
    observeEvent(input$open_corr, {
      req(input$open_corr > 0)   # a React button sends 0 at start
      res <- screened(); need_ok(!is.null(res), "Set the vulnerability framework first.")
      n <- sum(use_now())
      need_ok(n > 1, "Tick at least two variables in the Use column first.")
      corr_request(NULL); corr_groups(NULL)
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("grid-3x3"), sprintf(" Correlations of the %d ticked variables", n)),
        size = "l", easyClose = TRUE,
        footer = tagList(modalButton("Close"), uiOutput(ns("corr_apply_ui"), inline = TRUE)),
        tags$div(
          class = "d-flex flex-wrap align-items-end gap-2 mb-3",
          tags$div(style = "max-width: 220px;",
                   numericInput(ns("corr_modal_cut"), "Correlated at or above |r|", value = input$corr_cutoff %||% 0.8,
                                min = 0.1, max = 1, step = 0.05, width = "100%")),
          tags$div(class = "pb-3", actionButton(ns("corr_compute"), "Find correlated variables", icon = icon("magnifying-glass"),
                                                class = "btn-outline-primary"))),
        uiOutput(ns("details_ui"))))
    })
    observeEvent(input$corr_compute, {
      cut <- suppressWarnings(as.numeric(input$corr_modal_cut))
      need_ok(isTRUE(cut > 0 && cut <= 1), "Set a threshold between 0 and 1.")
      corr_request(list(cutoff = cut, at = Sys.time()))
    })
    output$details_ui <- renderUI({
      req_ <- corr_request()
      if (is.null(req_)) return(tags$div(class = "small text-muted", "Set the threshold, then click Find correlated variables."))
      res <- isolate(screened()); req(res)
      chosen <- isolate(res$criterion[use_now()])
      cutoff <- req_$cutoff
      cg <- correlated_groups(isolate(assessment_df()), chosen, cutoff)
      corr_groups(cg)
      if (!length(cg$groups)) {
        return(tags$div(class = "alert alert-success mb-0", bsicons::bs_icon("check-circle-fill"),
                        sprintf(" No two of the %d ticked variables are correlated at or above |r| = %.2f: nothing to remove.",
                                length(chosen), cutoff)))
      }
      p <- cg$pairs
      with_r <- function(m) {
        k <- which(p$a == m | p$b == m)
        paste(sprintf("%s (%.2f)", ifelse(p$a[k] == m, p$b[k], p$a[k]), p$r[k]), collapse = ", ")
      }
      tagList(
        tags$p(class = "small",
               sprintf("%d group%s of variables correlated at or above |r| = %.2f. Variables in a group say nearly the same thing: ",
                       length(cg$groups), if (length(cg$groups) == 1) "" else "s", cutoff),
               "keep one and remove the others, so one effect is not counted twice in the score. ",
               tags$strong("Remove"), " is ticked for the proposal (the member that overlaps most with the others); change it as you see fit."),
        lapply(seq_along(cg$groups), function(g) {
          mem <- cg$groups[[g]]
          tags$div(
            class = "wfp-corr-group mb-3",
            tags$div(class = "small fw-bold text-uppercase mb-1", sprintf("Group %d", g)),
            tags$div(class = "wfp-model-table-wrap", tags$table(
              class = "wfp-model-table",
              tags$thead(tags$tr(tags$th(class = "text-center", "Remove"), tags$th("Variable"), tags$th("Correlated with (r)"))),
              tags$tbody(lapply(mem, function(m) tags$tr(
                tags$td(class = "text-center", checkboxInput(ns(rv_id("drop", m)), NULL, value = m %in% names(cg$drop))),
                tags$td(class = "tw-var", tags$strong(m)),
                tags$td(class = "small", with_r(m))))))))
        }))
    })
    output$corr_apply_ui <- renderUI({
      cg <- corr_groups()
      if (is.null(cg) || !length(cg$groups)) return(NULL)
      actionButton(ns("corr_apply"), "Remove the ticked from Use", icon = icon("check"), class = "btn-primary")
    })
    observeEvent(input$corr_apply, {
      cg <- corr_groups(); need_ok(!is.null(cg) && length(cg$groups) > 0, "No correlated group to act on.")
      members <- unique(unlist(cg$groups))
      rm <- members[vapply(members, function(m) {
        v <- input[[rv_id("drop", m)]]; if (is.null(v)) m %in% names(cg$drop) else isTRUE(v)
      }, logical(1))]
      need_ok(length(rm) > 0, "Tick Remove for at least one variable.")
      need_ok(all(vapply(cg$groups, function(g) !all(g %in% rm), logical(1))), "Keep at least one variable of each group.")
      p <- cg$pairs
      partner <- vapply(rm, function(m) {
        if (m %in% names(cg$drop)) return(cg$drop[[m]])
        k <- which(p$a == m | p$b == m); k <- k[which.max(abs(p$r[k]))]
        if (p$a[k] == m) p$b[k] else p$a[k]
      }, character(1))
      sug <- corr_suggest() %||% character(0)
      corr_suggest(c(sug[setdiff(names(sug), rm)], partner))
      res <- screened()
      res$retained <- use_now() & !res$criterion %in% rm
      screened(res)
      removeModal()
      showNotification(sprintf("%d variable%s removed from Use: %s.", length(rm), if (length(rm) == 1) "" else "s",
                               paste(rm, collapse = ", ")), type = "message", duration = 8)
    })

    # Continue: the Use ticks go to the model.
    observeEvent(input$nav_next_screening, {
      req(input$nav_next_screening > 0)   # a React button sends 0 at start
      res <- screened(); need_ok(!is.null(res), "Set the vulnerability framework first.")
      use <- use_now()
      keep <- c(res$criterion[use], if (pmt()) setdiff(pmt_numeric_sel(), res$criterion))
      need_ok(length(keep) > 0, if (pmt()) "Tick at least one variable in the Use column or choose a numeric proxy." else "Tick at least one variable in the Use column.")
      sug <- corr_suggest() %||% character(0)
      auto <- intersect(setdiff(res$criterion, keep), names(sug))
      sig <- if (is.null(qs_result())) character(0) else qs_result()$criterion[which(qs_result()$significant)]
      collinear(sug[auto])
      analyst_dropped(setdiff(intersect(sig, res$criterion[!use]), auto))
      res$retained <- use
      screened(res)
      criteria_sel(keep)
      selection_applied(TRUE)
      go_step("weights")
      showNotification(sprintf("%d criteria go to the model.", length(keep)), type = "message", duration = 6)
    })

    # -----------------------------------------------------------------------
    # Step 4: the model and the weights
    # -----------------------------------------------------------------------

    stepwise_on <- function() !identical(input$stepwise %||% "none", "none")

    observeEvent(input$run_fit, {
      req(input$run_fit > 0)   # a React button sends 0 at start
      df <- assessment_df()
      res <- screened()
      need_ok(!is.null(df) && !is.null(res), "Load the assessment data, choose the outcome and the criteria, and select the variables first.")
      # The picker lets the model be iterated on a different set than the
      # screening retained; it starts from the retained set.
      keep <- intersect(input$fit_criteria %||% ready_criteria(), ready_criteria())
      if (length(keep) == 0) {
        showNotification("No criteria to model: tick at least one in the criteria list.", type = "error")
        return()
      }
      if (no_outcome()) return(fit_without_outcome(df, keep))

      y <- outcome_binary()
      sp <- split_train_test(y, holdout = model_params$holdout_pct / 100, seed = model_params$split_seed)
      wcol <- input$model_weights
      wts_vec <- if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]] else NULL
      # Everything the fit needs, taken now: the inputs may change while it runs.
      a <- if (pmt()) list(df = df[, keep, drop = FALSE], pc = pmt_pc(), line = pmt_line_value(), keep = keep, pmt = TRUE,
                           method = if (isTRUE(input$model_method %in% pmt_model_choices())) input$model_method else "pmt_ols",
                           stepwise = if (stepwise_on()) input$stepwise_ic %||% "aic" else "none",
                           stepwise_dir = if (stepwise_on()) input$stepwise else "backward",
                           sp = sp, weights = wts_vec, compare = input$pmt_compare) else
           list(df = df[, unique(c(input$outcome_col, keep)), drop = FALSE],
                outcome_col = input$outcome_col, keep = keep, outcome_pos = input$outcome_pos,
                method = input$model_method %||% "logit",
                stepwise = if (stepwise_on()) input$stepwise_ic %||% "aic" else "none",
                stepwise_dir = if (stepwise_on()) input$stepwise else "backward",
                scheme = input$model_scheme %||% "odds_ratio",
                sp = sp, weights = wts_vec, compare = input$compare_models,
                seed = model_params$split_seed,
                pca_axes = model_params$pca_axes, pca_min_var = pca_min_var_now(),
                tune = isTRUE(model_params$tune), folds = model_params$folds)
      settings <- list(tune = isTRUE(model_params$tune), folds = model_params$folds, method = a$method, scheme = if (pmt()) "pmt" else input$model_scheme, stepwise = a$stepwise, pca_axes = a$pca_axes,
                       pca_min_var = a$pca_min_var,
                       stepwise_dir = a$stepwise_dir, holdout = model_params$holdout_pct, seed = model_params$split_seed)
      waiter_log(sprintf("%d criteria, %s households for training", length(keep), format(length(sp$train), big.mark = ",")))

      # The fit runs in the background worker (bg_run): the page stays usable
      # and the cross on the loader stops it.
      bg_run(if (pmt()) "Fitting the proxy means test..." else sprintf("Fitting the %s model...", a$method), design_fit_job, a,
        on_error = function(msg) showNotification(paste("Model failed:", msg), type = "error", duration = 12),
        on_done = function(res) {
          out <- res$out
          split_state(sp)
          fitted(out)
          effects(res$effects)
          saved_points(NULL); weight_bump(weight_bump() + 1)
          bench(res$bench)

          # Keep every fit so a worse iteration never loses a better one.
          yb <- outcome_binary()
          sc_score <- apply_scorecard(df, build_scorecard(out$weights, kind = if (identical(out$scheme, "pmt")) "pmt" else "scorecard"))$score
          auc_rows <- if (length(sp$test)) sp$test else sp$train
          rl <- runs()
          rl[[length(rl) + 1]] <- list(
            id = length(rl) + 1, at = format(Sys.time(), "%H:%M:%S"),
            fit = out, split = sp, bench = res$bench, criteria = keep, effects = res$effects,
            settings = settings,
            auc = roc_curve(sc_score[auc_rows], yb[auc_rows])$auc,
            held_out = length(sp$test) > 0
          )
          runs(rl)
          current_run(length(rl))
          audit_add(modification_log, "Design", "Model fitted",
                    sprintf("Run #%d: %s, %s, %d criteria, AUC %.3f", length(rl),
                            model_label(out$method),
                            scheme_label(out$scheme, out$method),
                            nrow(out$weights), rl[[length(rl)]]$auc %||% NA_real_))
        })
    })

    runs <- reactiveVal(list())
    effects <- reactiveVal(NULL)

    # Without an outcome: the ranking method on the chosen criteria, in the
    # background worker like any fit; no hold-out (nothing to evaluate on).
    unsup_args <- function(df, keep, target = NULL) {
      wcol <- input$model_weights
      list(df = df[, keep, drop = FALSE], keep = keep, method = input$model_method %||% "count", anchor = input$anchor,
           k = model_params$n_clusters, weights = if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]] else NULL,
           pca_axes = model_params$pca_axes, pca_min_var = pca_min_var_now(),
           target = target, seed = model_params$split_seed, unsupervised = TRUE,
           auto_k = is.null(target) && isTRUE(model_params$auto_k))
    }
    take_unsup_fit <- function(out, a) {
      split_state(list(train = seq_len(nrow(assessment_df())), test = integer(0)))
      fitted(out); effects(NULL); bench(NULL); stability(NULL)
      saved_points(NULL); weight_bump(weight_bump() + 1)
      settings <- list(method = a$method, anchor = a$anchor, k = a$k, pca_axes = a$pca_axes, pca_min_var = a$pca_min_var,
                       target = out$index$target, unsupervised = TRUE, seed = a$seed)
      rl <- runs()
      rl[[length(rl) + 1]] <- list(id = length(rl) + 1, at = format(Sys.time(), "%H:%M:%S"), fit = out,
                                   split = split_state(), bench = NULL, criteria = a$keep, effects = NULL,
                                   settings = settings, auc = NA_real_, held_out = FALSE)
      runs(rl); current_run(length(rl))
      audit_add(modification_log, "Design", "Ranking fitted (no outcome)",
                sprintf("Run #%d: %s, %d criteria, oriented by %s", length(rl), model_label(a$method), nrow(out$weights), anchor_text(out$index$anchor)))
    }
    fit_without_outcome <- function(df, keep, target = NULL) {
      a <- unsup_args(df, keep, target)
      bg_run(sprintf("Ranking households (%s)...", model_label(a$method)), design_fit_job, a,
             on_error = function(msg) showNotification(paste("Ranking failed:", msg), type = "error", duration = 12),
             on_done = function(res) take_unsup_fit(res$out, a))
    }
    # Cluster methods: the profiles to target, then points that reproduce them.
    observeEvent(input$cluster_apply, {
      req(input$cluster_apply > 0)   # a React button sends 0 at start
      f <- fitted(); need_ok(identical(f$index$type, "cluster"), "Fit a cluster method first.")
      k <- f$index$k
      pick <- which(vapply(seq_len(k), function(j) isTRUE(input[[paste0("tgt_", j)]]), logical(1)))
      need_ok(length(pick) > 0 && length(pick) < k, "Tick some profiles to target, not none or all.")
      r <- runs()[[current_run()]]
      a <- unsup_args(assessment_df(), r$criteria, pick)
      a$method <- f$method; a$anchor <- f$index$anchor; a$k <- k
      out <- tryCatch(fit_unsupervised(assessment_df(), a$keep, a$method, a$anchor, a$weights, a$k, a$pca_axes, a$pca_min_var,
                                       target = pick, seed = r$settings$seed %||% a$seed),
                      error = function(e) { showNotification(conditionMessage(e), type = "error"); NULL })
      req(out)
      take_unsup_fit(out, a)
      showNotification(sprintf("Targeting profile%s %s.", if (length(pick) > 1) "s" else "", paste(pick, collapse = ", ")), type = "message")
    })

    # What the More options dialog holds, in one line under its button
    output$fit_more_summary <- renderText({
      w <- input$model_weights
      cmp <- if (pmt()) input$pmt_compare else input$compare_models
      st <- input$stepwise %||% "none"
      paste(c(if (shiny::isTruthy(w)) paste("Weights:", w) else "No survey weights",
              sprintf("%d model%s compared", length(cmp), if (length(cmp) == 1) "" else "s"),
              if (!no_outcome()) { if (identical(st, "none")) "no stepwise" else sprintf("stepwise %s (%s)", st, toupper(input$stepwise_ic %||% "aic")) }),
            collapse = " \u00b7 ")
    })

    # The other models' effects per criterion, shown in the estimates table
    # (the chosen model's own column would repeat its beta)
    other_effects <- function(f) {
      eff <- effects()
      if (is.null(eff) || !is.null(index_method())) return(NULL)
      eff[eff$model != (EFFECT_LABELS[f$method %||% ""] %||% ""), c("criterion", "model", "effect"), drop = FALSE]
    }

    output$effects_plot <- render_echart({
      eff <- effects(); req(eff)
      d <- eff[!is.na(eff$effect), , drop = FALSE]
      req(nrow(d) > 0)
      ord <- stats::aggregate(effect ~ criterion, d, mean)
      cats <- ord$criterion[order(-ord$effect)]
      pal <- c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#8a96a3")
      mods <- unique(d$model)
      ser <- lapply(seq_along(mods), function(k) {
        g <- d[d$model == mods[k], , drop = FALSE]
        list(type = "scatter", name = mods[k], symbolSize = 11, itemStyle = list(color = pal[(k - 1) %% length(pal) + 1], opacity = 0.9),
             data = lapply(seq_len(nrow(g)), function(i) list(value = list(round(g$effect[i], 4), g$criterion[i]),
                                                             tip = sprintf("%s<br>%s: <b>%+.2f</b>", ec_esc(g$criterion[i]), ec_esc(mods[k]), g$effect[i]))))
      })
      ser[[1]]$markLine <- ec_markline(list(list(xAxis = 0)), color = "rgba(128,128,128,0.6)", dotted = TRUE)
      list(legend = ec_legend(), grid = ec_grid(), tooltip = ec_tip(),
           xAxis = list(type = "value", name = "Log-odds effect", nameLocation = "middle", nameGap = 26),
           yAxis = list(type = "category", data = I(cats), inverse = TRUE, axisLabel = list(interval = 0, hideOverlap = TRUE)),
           series = ser)
    })
    current_run <- reactiveVal(NA_integer_)

    # The model list follows the mode (restored sessions keep their choice).
    observeEvent(input$framework_mode, {
      ch <- if (no_outcome()) unsupervised_model_choices() else if (pmt()) pmt_model_choices() else scorecard_model_choices()
      want <- rs_in("model_method") %||% isolate(input$model_method)
      updateSelectInput(session, "model_method", choices = ch, selected = if (isTRUE(want %in% ch)) want else ch[[1]])
      if (is.null(isolate(restoring()))) fitted(NULL)
    }, ignoreInit = TRUE)
    output$unsup_note <- renderText(unsupervised_note(input$model_method))

    # Model settings (PCA / MCA axes, number of profiles): kept here, set in a
    # dialog from the button beside the model, used by every fit.
    model_params <- reactiveValues(pca_mode = "axes", pca_axes = 1, pca_min_var = 60, n_clusters = 3,
                                   holdout_pct = 20, split_seed = 123, tune = FALSE, folds = 5, auto_k = FALSE, diagram = TRUE)
    has_axes <- function(m) isTRUE(m %in% c("pca", "mca"))
    # The PCA variation shares, worked out once when the dialog opens: the
    # preview then only redraws text as the settings change (nothing runs
    # before Fit).
    pca_shares <- reactiveVal(NULL)
    show_params <- function() {
      m <- input$model_method
      pca_shares(NULL)
      if (identical(m, "pca")) {
        df <- assessment_df(); wcol <- input$model_weights
        if (!is.null(df)) pca_shares(tryCatch(pca_variance(df, intersect(input$fit_criteria %||% ready_criteria(), names(df)),
                                                           if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]]),
                                              error = function(e) NULL))
      }
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("sliders"), paste0(" Settings: ", model_label(m))),
        size = "m", easyClose = TRUE,
        footer = tagList(modalButton("Cancel"), actionButton(ns("params_apply"), "Apply", icon = icon("check"), class = "btn-primary")),
        if (has_axes(m)) tagList(
          radioButtons(ns("pca_mode"),
                       tagList("Axes kept in the index", info_tip("The index averages the coordinates on the first axes, each turned towards vulnerability and weighted by the share of variation it explains. Choose how many axes, or the minimum share of variation the index must explain: the fewest axes reaching it are kept.")),
                       choices = c("Number of axes" = "axes", "Minimum variation explained" = "var"),
                       selected = model_params$pca_mode, inline = TRUE),
          conditionalPanel(
            condition = sprintf("input['%s'] !== 'var'", ns("pca_mode")),
            numericInput(ns("pca_axes"), "Number of axes", value = model_params$pca_axes, min = 1, max = 20, step = 1, width = "100%")),
          conditionalPanel(
            condition = sprintf("input['%s'] === 'var'", ns("pca_mode")),
            numericInput(ns("pca_min_var"), "Minimum variation explained (%)", value = model_params$pca_min_var, min = 10, max = 100, step = 5, width = "100%")),
          uiOutput(ns("pca_preview"))),
        if (isTRUE(m %in% cluster_methods())) checkboxInput(ns("auto_k"),
          tagList("Choose the number of profiles automatically", info_tip("Tries 2 to 8 profiles and keeps the number with the best silhouette (the clearest separation). Without an outcome there is nothing to cross-validate against: separation is the evidence.")),
          value = isTRUE(model_params$auto_k)),
        if (isTRUE(m %in% cluster_methods())) tags$div(class = "wfp-fit-pair",
          numericInput(ns("n_clusters"), tagList("Number of profiles", info_tip("How many household profiles the clustering looks for (2 to 8). Try a few, or use 'Compare 2 to 8 profiles' after a fit: profiles that are too alike mean too many.")),
                       value = model_params$n_clusters, min = 2, max = 8, step = 1, width = "100%"),
          numericInput(ns("split_seed"), tagList("Seed", info_tip("Fixes the random starts of the clustering, so the same settings give the same profiles.")),
                       value = model_params$split_seed, min = 1, step = 1, width = "100%")),
        if (isTRUE(m %in% diagram_models())) checkboxInput(ns("diagram"),
          tagList("Draw the model diagram", info_tip(paste(
            "Shows the model as the standard picture for its kind, in the app and in the report:",
            "the tree for a decision tree, the odds ratios with their intervals for a logistic regression,",
            "the network for a neural network, variable importance for a random forest or XGBoost,",
            "the dendrogram for Ward clustering."))),
          value = !isFALSE(model_params$diagram)),
        # outcome models with hyperparameters: tuned by cross-validation
        if (!no_outcome() && isTRUE(m %in% tunable_models())) tagList(
          tags$div(class = "small fw-bold text-uppercase mb-2", "Hyperparameters"),
          checkboxInput(ns("tune"),
                        tagList("Tune by cross-validation", info_tip("Tries a small grid of settings (for the tree: complexity and depth; forest: variables per split and leaf size; boosting: depth, learning rate and rounds; SVM: cost and kernel width; neural network: size and decay; naive Bayes: smoothing) on the training households only. Each setting is fitted on k-1 folds and scored on the one left out; the setting with the best cross-validated AUC is kept and the model refitted with it.")),
                        value = isTRUE(model_params$tune)),
          conditionalPanel(sprintf("input['%s']", ns("tune")),
                           tags$div(style = "max-width: 200px;",
                                    numericInput(ns("folds"), "Folds (k)", value = model_params$folds, min = 2, max = 10, step = 1, width = "100%"))),
          tags$hr()),
        # outcome models: the households kept aside to measure the errors
        if (!no_outcome()) tagList(
          if (has_axes(m)) tags$hr(),
          tags$div(class = "small fw-bold text-uppercase mb-2", "Training and evaluation"),
          tags$div(class = "wfp-fit-pair",
            numericInput(ns("holdout_pct"),
                         tagList("Hold-out %", info_tip("Share of households kept aside and never used to fit the model. Errors and AUC are measured on them, so the figures are honest (0 = measure on the training data).")),
                         value = model_params$holdout_pct, min = 0, max = 50, step = 5, width = "100%"),
            numericInput(ns("split_seed"),
                         tagList("Seed", info_tip("Fixes the random hold-out split so the same settings give the same result every time.")),
                         value = model_params$split_seed, min = 1, step = 1, width = "100%")))))
    }
    observeEvent(input$model_params, { req(input$model_params > 0); show_params() })
    observeEvent(input$model_params2, { req(input$model_params2 > 0); show_params() })
    observeEvent(input$params_apply, {
      num <- function(v, lo, hi, def) { v <- suppressWarnings(as.numeric(v)); if (length(v) != 1 || !is.finite(v)) def else min(max(v, lo), hi) }
      if (!is.null(input$pca_mode)) model_params$pca_mode <- input$pca_mode
      if (!is.null(input$pca_axes)) model_params$pca_axes <- round(num(input$pca_axes, 1, 20, 1))
      if (!is.null(input$pca_min_var)) model_params$pca_min_var <- num(input$pca_min_var, 10, 100, 60)
      if (!is.null(input$n_clusters)) model_params$n_clusters <- round(num(input$n_clusters, 2, 8, 3))
      if (!is.null(input$holdout_pct)) model_params$holdout_pct <- num(input$holdout_pct, 0, 50, 20)
      if (!is.null(input$split_seed)) model_params$split_seed <- round(num(input$split_seed, 1, 1e9, 123))
      if (!is.null(input$tune)) model_params$tune <- isTRUE(input$tune)
      if (!is.null(input$folds)) model_params$folds <- round(num(input$folds, 2, 10, 5))
      if (!is.null(input$auto_k)) model_params$auto_k <- isTRUE(input$auto_k)
      if (!is.null(input$diagram)) model_params$diagram <- isTRUE(input$diagram)
      removeModal()
    })
    pca_min_var_now <- function() if (identical(model_params$pca_mode, "var")) model_params$pca_min_var / 100
    # The anchor is one of the criteria going to the model.
    observe({
      cr <- ready_criteria()
      cur <- rs_in("anchor") %||% isolate(input$anchor)
      updateSelectizeInput(session, "anchor", choices = c("(none: more criteria met = more vulnerable)" = "", cr),
                           selected = if (isTRUE(cur %in% cr)) cur else "")
    })

    # --- Review of each criterion -----------------------------------------------
    # Observable at registration and not an outcome indicator are checked
    # automatically (blocked columns never reach the table). Community
    # validation is no longer ticked per criterion; sessions that recorded it
    # keep it.
    review <- reactiveVal(list())
    rv_kinds <- c(obs = "Observable at registration", nout = "Not an outcome indicator", cval = "Validated by the community")
    rv_id <- function(kind, cr) paste0("rv", kind, "_", gsub("[^A-Za-z0-9]", "_", cr))
    rv_default <- function(kind) kind != "cval"   # the automatic checks already cover the first two
    rv_value <- function(rv, cr, kind) { r <- rv[[cr]]; if (is.null(r)) rv_default(kind) else isTRUE(r[[kind]]) }
    observe({
      cr <- screened()$criterion %||% character(0)
      cur <- isolate(review())
      for (c in cr) {
        x <- input[[rv_id("cval", c)]]
        cur[[c]] <- list(obs = TRUE, nout = TRUE, cval = if (is.null(x)) rv_value(cur, c, "cval") else isTRUE(x))
      }
      if (!identical(cur, isolate(review()))) review(cur)
    })
    # What Continue sent: the ticked criteria.
    ready_criteria <- reactive(criteria_sel())

    # The model iterates on the criteria that passed the review.
    observeEvent(ready_criteria(), {
      cr <- ready_criteria()
      # A model fitted on other criteria no longer describes this design
      # (not while a saved session is coming back).
      if (is.null(isolate(restoring()))) fitted(NULL)
      shinyWidgets::updatePickerInput(session, "fit_criteria", choices = cr,
                                      selected = intersect(rs_in("fit_criteria") %||% cr, cr))
    }, ignoreNULL = FALSE)
    observeEvent(screened(), {
      if (!is.null(isolate(restoring()))) return()
      runs(list()); current_run(NA_integer_)
    })

    output$model_note <- renderText(paste(scorecard_model_note(input$model_method %||% "logit"),
                                          if (stepwise_on()) stepwise_note(input$stepwise_ic, input$stepwise) else ""))

    # The run history as rows of the model comparison table (same columns:
    # model, criteria, AUC training, AUC held out, action)
    # Runs removed from the history stay as a small marker (their place keeps
    # every other run's number, which Restore and saved sessions use).
    live_runs <- function() Filter(function(r) !isTRUE(r$deleted), runs())
    best_run <- function(rl) { a <- vapply(rl, function(r) r$auc %||% NA_real_, numeric(1))
      if (!length(a) || all(is.na(a))) NA_integer_ else rl[[which.max(a)]]$id }
    # Scorecards show their history inside the model comparison table
    runs_in_comparison <- reactive({ f <- fitted(); !is.null(f) && !isTRUE(f$unsupervised) && is.null(f$pmt) })

    observeEvent(input$delete_run, {
      id <- input$delete_run; rl <- runs()
      need_ok(isTRUE(id >= 1 && id <= length(rl)) && !isTRUE(rl[[id]]$deleted), "This fit is no longer in the history.")
      need_ok(!isTRUE(id == current_run()), "This is the fit shown: restore another one first.")
      r <- rl[[id]]
      rl[[id]] <- list(id = id, deleted = TRUE)   # frees the fit, keeps the numbering
      runs(rl)
      audit_add(modification_log, "Design", "Model fit removed from the history",
                sprintf("Run #%d: %s", id, model_label(r$settings$method)))
      showNotification(sprintf("Run #%d removed from the history.", id), type = "message")
    })

    observeEvent(input$restore_run, {
      r <- runs()[[input$restore_run]]
      req(r)
      fitted(r$fit); split_state(r$split); bench(r$bench); effects(r$effects)
      current_run(r$id)
      updateSelectInput(session, "model_method", selected = if (identical(r$settings$method, "stepwise")) "logit" else r$settings$method)
      st <- r$settings$stepwise %||% if (identical(r$settings$method, "stepwise")) "aic" else "none"
      updateSelectInput(session, "stepwise", selected = if (st %in% c("aic", "bic")) r$settings$stepwise_dir %||% "backward" else "none")
      if (st %in% c("aic", "bic")) updateSelectInput(session, "stepwise_ic", selected = st)
      freezeReactiveValue(input, "model_scheme")
      updateSelectInput(session, "model_scheme", selected = r$settings$scheme)
      if (!is.null(r$settings$holdout)) model_params$holdout_pct <- r$settings$holdout
      if (identical(r$settings$method, "pca")) {
        model_params$pca_mode <- if (is.null(r$settings$pca_min_var)) "axes" else "var"
        if (!is.null(r$settings$pca_min_var)) model_params$pca_min_var <- 100 * r$settings$pca_min_var
        if (!is.null(r$settings$pca_axes)) model_params$pca_axes <- r$settings$pca_axes
      }
      if (!is.null(r$settings$seed)) model_params$split_seed <- r$settings$seed
      shinyWidgets::updatePickerInput(session, "fit_criteria", selected = r$criteria)
      saved_points(NULL); weight_bump(weight_bump() + 1)
      showNotification(sprintf("Run #%d restored.", r$id), type = "message")
    })

    # Survey weight candidates: numeric columns only.
    observeEvent(assessment_df(), {
      df <- assessment_df()
      req(df)
      num <- names(df)[vapply(df, is.numeric, logical(1))]
      guess <- num[grepl("weight|wgt|pond", num, ignore.case = TRUE)][1]
      updateSelectInput(session, "model_weights",
                        choices = c("(none)" = "", stats::setNames(num, num)),
                        selected = rs_in("model_weights") %||% (if (is.na(guess)) "" else guess))
    })

    output$scheme_note <- renderText(
      if (no_outcome() || pmt()) ""
      else if (isTRUE(input$model_method %in% c("pca", "lda")))
        "The index has its own weights (scaled so the largest is 10): the weighting scheme does not apply."
      else scorecard_scheme_note(input$model_scheme %||% "odds_ratio"))

    observeEvent(input$scheme_apply, {
      req(input$scheme_apply > 0)   # a React button sends 0 at start
      if (!is.null(isolate(restoring()))) return()
      f <- fitted()
      req(f)
      # An index keeps its own weights: odds-ratio points would mean nothing.
      if (isTRUE(f$method %in% c("pca", "lda")) || identical(f$scheme, "pmt")) return()
      f$weights$weight <- scorecard_weights(f$weights$coefficient, input$model_scheme)
      f$scheme <- input$model_scheme
      fitted(f)
      saved_points(NULL); weight_bump(weight_bump() + 1)
    }, ignoreInit = TRUE)

    # The fit in figures (React: StepModel's FitNote): the tuning and the
    # number of profiles chosen, the summary line, the index or PMT figures,
    # a convergence warning, and the per-criterion notes folded below the
    # estimates (missing answers counted as "no", criteria removed by stepwise).
    output$sc_fit <- shinyreact::reactive_output({
      f <- fitted()
      if (is.null(f)) return(NULL)
      tn <- f$tuning; kq <- f$index$k_quality
      list(
        tuning = if (!is.null(tn)) list(folds = tn$folds, n = tn$n, auc = u(tn$best_auc),
                                        best = paste(sprintf("%s = %s", names(tn$best), vapply(tn$best, function(v) format(signif(v, 3)), character(1))), collapse = ", ")),
        k_auto = if (!is.null(kq)) list(k = f$index$k, silhouette = u(max(kq$silhouette, na.rm = TRUE))),
        model = model_label(f$method), n = f$n, held_out = length(split_state()$test), kept = nrow(f$weights),
        index = if (!is.null(f$index)) index_note_facts(f$index),
        pmt = if (!is.null(f$pmt)) pmt_fit_figs(f$pmt),
        converged = isTRUE(f$converged),
        filled = lapply(names(f$filled), function(k) list(name = k, n = u(f$filled[[k]]))),
        dropped = I(as.character(f$dropped)), is_pmt = !is.null(f$pmt))
    })

    observeEvent(input$apply_points, {
      req(input$apply_points > 0)   # a React button sends 0 at start
      f <- fitted(); need_ok(!is.null(f), "Fit the model first.")
      old <- current_weights()$weight
      v <- vapply(seq_len(nrow(f$weights)), function(i) {
        x <- input[[paste0("w_", i)]]
        if (is.null(x)) return(old[i])                      # a box not on the page keeps its value
        x <- suppressWarnings(as.numeric(x)); if (length(x) == 1 && is.finite(x)) x else NA_real_ }, numeric(1))
      need_ok(!anyNA(v) && all(v >= 0), "Every point must be a number of zero or more.")
      saved_points(data.frame(weight = v, verifiable = TRUE, validated = FALSE))
      ch <- which(abs(v - old) > 1e-9)
      if (length(ch)) audit_add(modification_log, "Design", "Points edited",
                                paste(sprintf("%s: %s -> %s", f$weights$criterion[ch], fmt5(old[ch]), fmt5(v[ch])), collapse = "; "))
      showNotification("Edited points applied.", type = "message")
    })
    # Edited points not applied yet (React: the estimates card's header)
    points_stale <- reactive({
      f <- fitted(); if (is.null(f)) return(FALSE)
      w <- current_weights()$weight
      v <- vapply(seq_along(w), function(i) { x <- input[[paste0("w_", i)]]; if (is.null(x) || is.na(x)) w[i] else as.numeric(x) }, numeric(1))
      !all(abs(v - w) < 1e-9)
    })
    observeEvent(input$reset_weights, {
      req(input$reset_weights > 0)   # a React button sends 0 at start
      saved_points(NULL); weight_bump(weight_bump() + 1)
      showNotification("Weights reset to the fitted model values.", type = "message")
    })

    # The weights as currently edited.
    current_weights <- reactive({
      f <- fitted()
      req(f)
      wts <- f$weights
      # Before the weights table has been drawn (a restored session whose
      # Model step was not opened yet) the saved points stand in for it.
      sp <- saved_points()
      if (!is.null(sp) && nrow(sp) != nrow(wts)) sp <- NULL
      # the points count once applied (Apply points), not as they are typed
      if (!is.null(sp)) wts$weight <- as.numeric(sp$weight)
      rv <- review()
      wts$verifiable <- vapply(wts$criterion, function(c) rv_value(rv, c, "obs"), logical(1))
      wts$validated <- vapply(wts$criterion, function(c) rv_value(rv, c, "cval"), logical(1))
      wts
    })

    # Criteria charts. The weights table answers "what is in the card"; these
    # answer "which criteria are doing the work", which is the question a
    # targeting officer actually has when deciding what to keep.
    # PCA / LDA are indices, not log-odds models: their own charts replace the
    # logistic ones (prevalence stays for LDA, which separates the two groups).
    index_method <- reactive({
      f <- fitted()
      if (!is.null(f) && (isTRUE(f$unsupervised) || isTRUE(f$method %in% c("pca", "lda")))) f$method else NULL
    })

    # The cross-validation grid, best first
    observeEvent(input$show_tuning, {
      req(input$show_tuning > 0)   # a React button sends 0 at start
      tn <- fitted()$tuning; req(tn)
      tab <- utils::head(tn$table, 12)
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("sliders"), sprintf(" %d-fold cross-validation", tn$folds)), size = "l", easyClose = TRUE,
        footer = modalButton("Close"),
        tags$p(class = "small text-muted", sprintf("Each setting fitted on %d folds and scored on the one left out, on %s training households; the best is kept (first row).",
                                                   tn$folds - 1, format(tn$n, big.mark = ","))),
        tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(lapply(names(tab), function(k) tags$th(class = "num", if (k == "cv_auc") "CV AUC" else k)))),
          tags$tbody(lapply(seq_len(nrow(tab)), function(i) tags$tr(
            class = if (i == 1) "table-active" else NULL,
            lapply(names(tab), function(k) tags$td(class = "num", format(signif(tab[[k]][i], 4)))))))))))
    })
    # More diagnostics (React: StepModel's Diagnostics): the model's diagram
    # where one is standard (tree, forest plot, network, importance,
    # dendrogram; switched off in the model settings), as the SVG the design
    # report draws, and the decision tree's leaves, most vulnerable first.
    output$sc_diagram <- shinyreact::reactive_output({
      f <- fitted(); if (is.null(f)) return(NULL)
      nof <- isTRUE(f$unsupervised)
      d <- f$diagram
      svg <- if (is.null(d) || isFALSE(model_params$diagram)) "" else diagram_svg(d, if (nof) "targeted" else "vulnerable")
      rl <- f$tree_rules
      list(nof = nof,
           diagram = if (nzchar(svg)) list(title = diagram_title(d$kind), help = diagram_help(d$kind, nof), svg = svg),
           tree = if (identical(f$method, "tree") && !is.null(rl) && nrow(rl))
             lapply(seq_len(nrow(rl)), function(i) list(rule = rl$rule[i], households = u(rl$households[i]), share = u(rl$share_vulnerable[i]))))
    })

    # Scree plot: the variation each axis explains, the axes in the index in
    # blue, and Kaiser's rule (eigenvalue 1).
    # Before fitting: how much variation the first axes of the chosen
    # criteria explain, and what the current setting keeps.
    output$pca_preview <- renderUI({
      req(identical(isolate(input$model_method), "pca"))
      sh <- pca_shares()
      if (is.null(sh)) return(tags$div(class = "small text-muted", "Choose at least two criteria to see the variation explained."))
      cum <- cumsum(sh)
      mode <- input$pca_mode %||% model_params$pca_mode
      k <- if (identical(mode, "var")) {
        target <- (input$pca_min_var %||% model_params$pca_min_var) / 100
        which(cum >= target - 1e-9)[1] %||% length(cum)
      } else min(max(1, input$pca_axes %||% model_params$pca_axes), length(cum))
      show <- seq_len(min(length(cum), max(k, 4)))
      tags$div(class = "small text-muted",
               tags$strong(sprintf("Keeps %d %s: %.0f%% of the variation explained in total.", k, if (k == 1) "axis" else "axes", 100 * cum[k])),
               tags$br(),
               "Cumulative: ", paste(sprintf("%d %s %.0f%%", show, ifelse(show == 1, "axis", "axes"), 100 * cum[show]), collapse = " \u00b7 "),
               if (length(cum) > max(show)) " \u00b7 ...")
    })

    output$pca_scree <- render_echart({
      ix <- fitted()$index; req(isTRUE(ix$type %in% c("pca", "mca")))
      ev <- utils::head(ix$eigen, 20)
      share <- 100 * ev / sum(ix$eigen)
      kept <- seq_along(ev) <= (ix$axes %||% 1)
      cum <- 100 * cumsum(ix$eigen)[seq_along(ev)] / sum(ix$eigen)
      ax <- paste("Axis", seq_along(ev))
      list(legend = ec_legend(), grid = ec_grid(), tooltip = ec_tip(),
           xAxis = list(type = "category", data = I(ax), axisLabel = list(interval = 0, rotate = if (length(ev) > 8) 90 else 0)),
           yAxis = list(list(type = "value", name = "Eigenvalue", nameLocation = "middle", nameGap = 36),
                        list(type = "value", name = "Cumulative % explained", nameLocation = "middle", nameGap = 40, min = 0, max = 105,
                             splitLine = list(show = FALSE), axisLabel = list(formatter = "fn:pctv"))),
           series = list(
             list(type = "bar", name = "Eigenvalue", barMaxWidth = 38,
                  data = lapply(seq_along(ev), function(k) list(value = round(ev[k], 4), itemStyle = list(color = if (kept[k]) "#0A6EB4" else "#b8c4d0"),
                                                               tip = sprintf("%s: eigenvalue <b>%.2f</b>, %.1f%% of the variation%s", ax[k], ev[k], share[k], if (kept[k]) " (in the index)" else ""))),
                  markLine = ec_markline(list(list(yAxis = 1)), "Kaiser: 1", "#f7b825")),
             list(type = "line", name = "Cumulative %", yAxisIndex = 1, symbolSize = 6, itemStyle = list(color = "#c5192d"),
                  lineStyle = list(color = "#c5192d", width = 2),
                  data = lapply(seq_along(ev), function(k) list(value = round(cum[k], 2), tip = sprintf("Axes 1 to %d: <b>%.1f%%</b> of the variation", k, cum[k]))))))
    })

    # Loadings: how each criterion weighs on each axis kept (turned towards
    # vulnerability, as in the index).
    output$pca_loadings <- render_echart({
      ix <- fitted()$index; req(isTRUE(ix$type %in% c("pca", "mca")), !is.null(ix$axis_loadings))
      L <- ix$axis_loadings
      ord <- order(-L[, 1])
      cats <- rownames(L)[ord]
      pal <- c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d")
      o <- ec_bars(cats, lapply(seq_len(ncol(L)), function(j) list(
        name = colnames(L)[j], color = pal[(j - 1) %% length(pal) + 1], values = round(L[ord, j], 4),
        tips = sprintf("%s, %s: <b>%.2f</b>", ec_esc(cats), ec_esc(colnames(L)[j]), L[ord, j]))),
        horizontal = TRUE, value_name = "Loading", legend = ncol(L) > 1)
      o
    })

    # Households' coordinates on the index's axes (PCA) or on the index (LDA),
    # with their vulnerability; at most 3,000 drawn, so the chart stays fast.
    index_points <- reactive({
      f <- fitted(); ix <- f$index; req(ix)
      df <- assessment_df(); y <- if (no_outcome()) rep(0L, nrow(df)) else outcome_binary()
      req(df, length(y) == nrow(df), all(ix$criteria %in% names(df)))
      M <- index_matrix(df, ix$criteria)
      if (no_outcome()) y <- as.integer(scored()$eligible)
      ok <- which(!is.na(y))
      if (length(ok) > 3000) { set.seed(1); ok <- sort(sample(ok, 3000)) }
      grp <- if (no_outcome()) ifelse(y[ok] == 1, "Selected", "Not selected") else ifelse(y[ok] == 1, "Vulnerable", "Not vulnerable")
      if (identical(ix$type, "pca")) {
        Z <- sweep(sweep(M[ok, , drop = FALSE], 2, ix$center), 2, ix$sd, "/") %*% ix$map_vectors
        list(type = "pca", x = Z[, 1], y = if (ncol(Z) > 1) Z[, 2] else rep(0, nrow(Z)), group = grp)
      } else {
        sc <- apply_scorecard(df, build_scorecard(f$weights))$score
        list(type = "lda", x = sc[ok], group = grp, M = M[ok, , drop = FALSE])
      }
    })
    grp_cols <- c(Vulnerable = "#c5192d", `Not vulnerable` = "#3f7e44", Selected = "#0A6EB4", `Not selected` = "#8a96a3")

    # Deprivation counting: how many weighted deprivations households have.
    output$dep_count_plot <- render_echart({
      s <- scored(); req(s$score)
      d <- as.data.frame(table(round(s$score, 2)))
      names(d) <- c("score", "n")
      d$score <- as.numeric(as.character(d$score)); d$pct <- 100 * d$n / sum(d$n)
      t <- thr_applied() %||% 0
      list(grid = ec_grid(top = 20), tooltip = ec_tip(),
           xAxis = list(type = "value", name = "Weighted deprivations", nameLocation = "middle", nameGap = 26, scale = TRUE),
           yAxis = list(type = "value", name = "% of households", nameLocation = "middle", nameGap = 40, axisLabel = list(formatter = "fn:pctv")),
           series = list(list(type = "bar", name = "Households", barMaxWidth = 38,
                              data = lapply(seq_len(nrow(d)), function(k) list(
                                value = list(d$score[k], round(d$pct[k], 2)), itemStyle = list(color = if (d$score[k] > t) "#0A6EB4" else "#b8c4d0"),
                                tip = sprintf("%s weighted deprivations<br><b>%.1f%%</b> of households (%s)", fmt5(d$score[k]), d$pct[k], format(d$n[k], big.mark = ",")))),
                              markLine = ec_markline(list(list(xAxis = t)), sprintf("threshold %s", fmt5(t))))))
    })
    # Profiles of the cluster methods: one table, one column per profile
    # (most vulnerable first) with its Target tick, size and rank, and the
    # ten criteria that separate the profiles most. Ticking computes nothing:
    # the points are refitted when "Target the ticked profiles" is clicked.
    profile_view <- reactive({
      f <- fitted(); ix <- f$index; req(identical(ix$type, "cluster"))
      pc <- profile_contrasts(ix$profiles, ix$size, f$n)
      list(ix = ix, pc = pc, top = utils::head(order(-pc$v), 10))
    })
    # (React: StepModel's Profiles; the Target ticks are inputs tgt_<j>, set
    # back to the targeted profiles each time the table is sent.)
    output$sc_profiles <- shinyreact::reactive_output({
      pv <- safe(profile_view()); if (is.null(pv)) return(NULL)
      ix <- pv$ix; pc <- pv$pc
      k <- ix$k; pr <- ix$profiles; ord <- ix$rank; top <- pv$top
      # which answer a criterion's percentage counts ("Yes", "1 - Oui", TRUE...)
      df <- assessment_df()
      counted <- function(cl) {
        x <- df[[cl]]; if (is.null(x)) return(NA_character_)
        if (is.logical(x)) return("TRUE")
        if (is.numeric(x)) return("1")
        v <- as.character(x); uu <- sort(unique(v[!is.na(v) & nzchar(trimws(v))]))
        if (length(uu) != 2) return(NA_character_)
        lv <- guess_positive_level(uu)
        unname(names(value_choices(lv, cl))[1] %||% lv)
      }
      list(k = k, target = I(as.integer(ix$target)),
           profiles = lapply(seq_along(ord), function(r) list(j = ord[r], size = u(ix$size[ord[r]]), rank = r)),
           rows = lapply(top, function(i) {
             cr <- rownames(pr)[i]; l <- var_label(cr)
             list(criterion = cr, label = if (!is.na(l) && nzchar(l)) l else NA, counted = counted(cr), v = u(pc$v[i]),
                  cells = lapply(ord, function(j) list(p = u(pr[i, j]), d = u(pc$diff[i, j]))), overall = u(pc$overall[i]))
           }),
           vmax = u(max(pc$v[top], 1e-9)),
           silhouette = u(ix$silhouette %||% NA), entropy = u(ix$entropy %||% NA), bic = u(ix$bic %||% NA),
           fidelity = u(ix$fidelity %||% NA), stamp = stamp())
    })
    # Households on the first two principal components of the criteria
    # (turned towards the anchor), coloured by profile or by selection.
    map_data <- reactive({
      f <- fitted(); req(isTRUE(f$unsupervised))
      df <- assessment_df(); ix <- f$index
      crit <- intersect(ix$criteria %||% f$weights$criterion, names(df)); req(length(crit) >= 2)
      M <- index_matrix(df, crit)
      keep <- apply(M, 2, stats::sd) > 0; req(sum(keep) >= 2)
      set.seed(3)
      idx <- if (nrow(M) > 3000) sort(sample(nrow(M), 3000)) else seq_len(nrow(M))
      pc <- stats::prcomp(M[, keep, drop = FALSE], scale. = TRUE, rank. = 2)
      Z <- pc$x[idx, , drop = FALSE]
      a <- if (is.na(ix$anchor %||% NA)) rowSums(M[idx, , drop = FALSE]) else M[idx, ix$anchor]
      if (isTRUE(stats::cor(Z[, 1], a) < 0)) Z[, 1] <- -Z[, 1]
      jit <- function(v) v + stats::runif(length(v), -0.08, 0.08)
      grp <- if (identical(ix$type, "cluster")) {
        g <- paste("Profile", ix$assign[idx]); ifelse(ix$assign[idx] %in% ix$target, paste(g, "(targeted)"), g)
      } else ifelse(scored()$eligible[idx] %in% TRUE, "Selected", "Not selected")
      lv <- sort(unique(grp))
      pal <- if (identical(ix$type, "cluster")) stats::setNames(rep_len(c("#c5192d", "#f7b825", "#0A6EB4", "#26bde2", "#3f7e44", "#8a96a3", "#5b6b7c", "#b8c4d0"), length(lv)), lv)
             else c(Selected = "#0A6EB4", `Not selected` = "#b8c4d0")
      share <- summary(pc)$importance[2, 1:2]
      list(x = jit(Z[, 1]), y = jit(Z[, 2]), group = grp, pal = pal,
           xlab = sprintf("Component 1 (%.0f%%, towards %s)", 100 * share[1], anchor_text(ix$anchor)),
           ylab = sprintf("Component 2 (%.0f%%)", 100 * share[2]),
           xlab_short = sprintf("Component 1 (%.0f%%)", 100 * share[1]))
    })
    output$unsup_map <- render_echart({
      m <- map_data()
      ec_scatter(m$x, m$y, m$group, m$pal, m$xlab, m$ylab, tip_fmt = "%s<br>%s: %.2f<br>%s: %.2f")
    })
    # How many profiles? Quality for 2 to 8, on evidence.
    observeEvent(input$profile_quality, {
      req(input$profile_quality > 0)   # a React button sends 0 at start
      f <- fitted(); need_ok(identical(f$index$type, "cluster"), "Fit a cluster method first.")
      r <- runs()[[current_run()]]
      df <- assessment_df(); wcol <- input$model_weights
      a <- list(df = df[, r$criteria, drop = FALSE], criteria = r$criteria, method = f$method, seed = r$settings$seed %||% 123,
                weights = if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]] else NULL)
      bg_run("Comparing 2 to 8 profiles...", profile_quality_job, a,
             on_error = function(msg) showNotification(paste("Comparison failed:", msg), type = "error"),
             on_done = function(q) {
               pq(q)
               showModal(modalDialog(
                 title = tagList(bsicons::bs_icon("people"), " How many profiles?"), size = "l", easyClose = TRUE,
                 footer = modalButton("Close"),
                 tags$p(class = "small text-muted",
                        "Silhouette: how well separated the profiles are (above 0.5 clear, 0.25 to 0.5 weak but real, below 0.25 hardly any).",
                        if (identical(f$method, "lca")) " Entropy: how certainly each household belongs to one class (above 0.8 clear). BIC: lower is better." else "",
                        " Prefer the number where the silhouette peaks, with no profile too small to act on."),
                 plotly::plotlyOutput(ns("pq_plot"), height = "300px"),
                 tags$div(class = "wfp-model-table-wrap mt-2", tags$table(
                   class = "wfp-model-table",
                   tags$thead(tags$tr(tags$th("Profiles"), tags$th(class = "num", "Silhouette"),
                                      if (identical(f$method, "lca")) tagList(tags$th(class = "num", "Entropy"), tags$th(class = "num", "BIC")),
                                      tags$th(class = "num", "Smallest profile"))),
                   tags$tbody(lapply(seq_len(nrow(q)), function(i) tags$tr(
                     class = if (q$k[i] == f$index$k) "table-active" else NULL,
                     tags$td(q$k[i], if (q$k[i] == f$index$k) " (current)"),
                     tags$td(class = "num", sprintf("%.2f", q$silhouette[i])),
                     if (identical(f$method, "lca")) tagList(tags$td(class = "num", sprintf("%.2f", q$entropy[i])),
                                                             tags$td(class = "num", format(round(q$bic[i]), big.mark = ","))),
                     tags$td(class = "num", sprintf("%.0f%%", 100 * q$smallest[i])))))))))
             })
    })
    pq <- reactiveVal(NULL)
    output$pq_plot <- render_wfp_plotly({
      q <- pq(); req(q)
      p <- plotly::plot_ly(q, x = ~k, y = ~silhouette, type = "scatter", mode = "lines+markers", name = "Silhouette",
                           line = list(color = "#0A6EB4"), marker = list(color = "#0A6EB4"))
      if (!all(is.na(q$entropy))) p <- plotly::add_trace(p, y = ~entropy, name = "Entropy", line = list(color = "#c5192d"),
                                                         marker = list(color = "#c5192d"))
      plotly::layout(p, xaxis = list(title = "Number of profiles", dtick = 1), yaxis = list(title = ""),
                     legend = list(orientation = "h", y = 1.15))
    })

    output$cluster_plot <- render_echart({
      ix <- fitted()$index; req(identical(ix$type, "cluster"))
      pr <- ix$profiles[, ix$rank, drop = FALSE]
      pr <- pr[order(-profile_contrasts(ix$profiles, ix$size, fitted()$n)$v), , drop = FALSE]   # strongest separators on top
      o <- ec_heat(colnames(pr), rownames(pr), 100 * pr)
      o$yAxis$inverse <- TRUE
      # one readable row per criterion: the chart grows with them
      o$yAxis$axisLabel <- list(interval = 0, width = 220, overflow = "truncate")
      attr(o, "height") <- max(360, 28 * nrow(pr) + 110)
      o
    })

    # PCA correlation circle: each criterion's correlation with axes 1 and 2
    # (its loading); arrows close to the circle are well represented, arrows
    # pointing the same way go together.
    output$pca_var_map <- render_echart({
      ix <- fitted()$index; req(identical(ix$type, "pca"), !is.null(ix$map_vectors))
      V <- ix$map_vectors
      co <- sweep(V, 2, sqrt(ix$eigen[seq_len(ncol(V))]), "*")
      x <- co[, 1]; y <- if (ncol(co) > 1) co[, 2] else rep(0, nrow(co))
      share <- function(j) sprintf("Axis %d (%.0f%%)", j, 100 * ix$eigen[j] / sum(ix$eigen))
      th <- seq(0, 2 * pi, length.out = 121)
      lab <- vapply(ix$criteria, function(v) { l <- var_label(v); if (is.na(l)) ec_esc(v) else sprintf("%s<br><i>%s</i>", ec_esc(v), ec_esc(l)) }, "")
      ax <- function(nm) list(type = "value", name = nm, nameLocation = "middle", nameGap = 28, min = -1.15, max = 1.15,
                              axisLine = list(onZero = TRUE))
      list(grid = ec_grid(top = 16), tooltip = ec_tip(),
           xAxis = ax(share(1)), yAxis = ax(if (length(ix$eigen) > 1) share(2) else ""),
           series = list(
             list(type = "line", name = "circle", showSymbol = FALSE, silent = TRUE, tooltip = list(show = FALSE),
                  lineStyle = list(color = "rgba(128,128,128,0.45)", width = 1),
                  data = lapply(seq_along(th), function(k) list(round(cos(th[k]), 4), round(sin(th[k]), 4)))),
             list(type = "lines", coordinateSystem = "cartesian2d", silent = TRUE, symbol = I(c("none", "arrow")), symbolSize = 8,
                  lineStyle = list(color = "#0A6EB4", width = 1.4, opacity = 0.9),
                  data = lapply(seq_along(x), function(k) list(coords = list(c(0, 0), c(round(x[k], 4), round(y[k], 4)))))),
             list(type = "scatter", name = "Criteria", symbolSize = 6, itemStyle = list(color = "#0A6EB4"),
                  label = list(show = TRUE, position = "top", fontSize = 10, formatter = "{b}"),
                  data = lapply(seq_along(x), function(k) list(name = ix$criteria[k], value = list(round(x[k], 4), round(y[k], 4)),
                                                               tip = sprintf("%s<br>axis 1: %.2f, axis 2: %.2f", lab[k], x[k], y[k]))))))
    })

    # Households on the first two axes, by vulnerability. Yes/no criteria put
    # many households on the same point: a small jitter shows how many.
    output$pca_ind_map <- render_echart({
      pts <- index_points(); req(identical(pts$type, "pca"))
      set.seed(2)
      jit <- function(v) v + stats::runif(length(v), -0.06, 0.06)
      ec_scatter(jit(pts$x), jit(pts$y), pts$group, grp_cols[unique(pts$group)], "Axis 1 (towards vulnerability)", "Axis 2",
                 tip_fmt = "%s<br>%s: %.2f<br>%s: %.2f", opacity = 0.45)
    })

    # LDA structure correlations: how much each criterion moves with the index
    # (the usual way to read which criteria the discriminant rests on).
    output$lda_var_map <- render_echart({
      pts <- index_points(); req(identical(pts$type, "lda"))
      r <- vapply(colnames(pts$M), function(cl) {
        v <- pts$M[, cl]; if (stats::sd(v) == 0 || stats::sd(pts$x) == 0) NA_real_ else stats::cor(v, pts$x)
      }, numeric(1))
      d <- data.frame(criterion = names(r), r = unname(r))
      d <- d[order(-d$r), , drop = FALSE]
      lab <- vapply(d$criterion, function(v) { l <- var_label(v); if (is.na(l)) ec_esc(v) else sprintf("%s<br><i>%s</i>", ec_esc(v), ec_esc(l)) }, "")
      o <- ec_bars(d$criterion, list(list(name = "Correlation", values = round(d$r, 4),
                                          colors = ifelse(is.na(d$r) | d$r >= 0, "#0A6EB4", "#c5192d"),
                                          tips = sprintf("%s<br>correlation with the index: <b>%.2f</b>", lab, d$r))),
                   horizontal = TRUE, value_name = "Correlation with the index", legend = FALSE)
      o$xAxis$min <- -1; o$xAxis$max <- 1
      o
    })

    # Households on the index, one dot each, by group.
    output$lda_ind_map <- render_echart({
      pts <- index_points(); req(identical(pts$type, "lda"))
      ec_box(pts$x, pts$group, grp_cols[unique(pts$group)], "Index", horizontal = TRUE, points = TRUE)
    })

    # LDA: the index of vulnerable and other households side by side; the less
    # the two overlap, the better the index separates them.
    output$lda_scores <- render_echart({
      f <- fitted(); req(identical(f$index$type, "lda"))
      df <- assessment_df(); y <- outcome_binary()
      req(df, length(y) == nrow(df))
      sc <- apply_scorecard(df, build_scorecard(f$weights))$score
      ok <- !is.na(sc) & !is.na(y)
      ec_mirrored(sc[ok], y[ok] == 1, NULL, "Index")
    })

    # Weights as a diverging bar: inclusion to the right, exclusion to the
    # left, so the shape of the card is legible at a glance.
    output$weights_plot <- render_echart({
      wts <- current_weights()
      req(nrow(wts) > 0)
      signed <- ifelse(wts$direction == "exclusion", -wts$weight, wts$weight)
      or <- wts$odds_ratio %||% rep(NA_real_, nrow(wts))
      o <- order(-signed)
      tip <- sprintf("<b>%s</b><br>%s<br>weight %.2f%s", ec_esc(wts$criterion), wts$direction, abs(signed),
                     ifelse(is.na(or), "", sprintf(" (OR %.2f)", or)))
      ec_lollipop(wts$criterion[o], round(signed[o], 4), wts$direction[o], tip[o], "Points (+ / -)")
    })

    # A PMT's evaluation households (up to 3,000 for the scatter charts)
    pmt_eval_sample <- function(f, n = 3000) {
      e <- f$eval %||% f$sample
      if (NROW(e) > n) { set.seed(1); e <- e[sort(sample.int(nrow(e), n)), , drop = FALSE] }
      e
    }
    # the cut-off in predicted log welfare for the current threshold
    pmt_cut <- function(f) f$intercept - (if (is.numeric(thr_applied())) thr_applied() else f$threshold_line) / 100
    # A PMT: predicted against measured log welfare per person on the
    # evaluation households, the line on both axes (the four quadrants are
    # the right calls and the two errors).
    output$pmt_fit_plot <- render_echart({
      f <- fitted()$pmt; req(f)
      d <- pmt_eval_sample(f); req(nrow(d) > 0); ll <- f$log_line
      cell <- ifelse(d$actual <= ll, ifelse(d$predicted <= ll, "Poor, predicted poor", "Poor, predicted not poor (exclusion)"),
                     ifelse(d$predicted <= ll, "Not poor, predicted poor (inclusion)", "Not poor, predicted not poor"))
      pal <- c("Poor, predicted poor" = "#0A6EB4", "Poor, predicted not poor (exclusion)" = "#c5192d",
               "Not poor, predicted poor (inclusion)" = "#f7b825", "Not poor, predicted not poor" = "#9aa5b1")
      rng <- range(c(d$actual, d$predicted), na.rm = TRUE)
      o <- ec_scatter(d$actual, d$predicted, cell, pal, "Measured log welfare per person", "Predicted log welfare per person",
                      tip_fmt = "%s<br>%s: %.2f<br>%s: %.2f", opacity = 0.6)
      o$series[[1]]$markLine <- list(silent = TRUE, symbol = "none", label = list(show = FALSE), animation = FALSE,
                                     data = list(list(list(coord = c(rng[1], rng[1]), lineStyle = list(type = "dotted", color = "rgba(128,128,128,0.6)")),
                                                      list(coord = c(rng[2], rng[2]))),
                                                 list(xAxis = ll, lineStyle = list(type = "dashed", color = EC_REF)),
                                                 list(yAxis = ll, lineStyle = list(type = "dashed", color = EC_REF))))
      o
    })

    # Share selected in each decile of measured welfare, at the current
    # cut-off: a PMT should select most of the bottom deciles and few of the top.
    output$pmt_decile_plot <- render_echart({
      f <- fitted()$pmt; req(f, NROW(f$eval) > 0)
      d <- pmt_decile_coverage(f$eval, pmt_cut(f))
      poor_dec <- ceiling(10 * f$headcount)
      o <- ec_bars(paste0("D", d$decile), list(list(name = "Selected", values = round(100 * d$selected, 1),
                                                    colors = ifelse(d$decile <= poor_dec, "#0A6EB4", "#9aa5b1"),
                                                    tips = sprintf("D%d: <b>%.0f%%</b> selected", d$decile, 100 * d$selected))),
                   value_name = "Selected (%)", pct = TRUE, legend = FALSE, rotate = 0)
      o$xAxis$name <- "Decile of measured welfare per person (D1 poorest)"; o$xAxis$nameLocation <- "middle"; o$xAxis$nameGap <- 26
      o
    })
    # Leakage and under-coverage for every cut-off from half to twice the
    # line, the current one marked.
    output$pmt_curve_plot <- render_echart({
      f <- fitted()$pmt; req(f, NROW(f$eval) > 0)
      d <- pmt_error_curve(f$eval, f$log_line)
      now <- 100 * exp(pmt_cut(f) - f$log_line)
      x <- 100 * d$mult
      o <- ec_lines(list(
        list(name = "Inclusion error (leakage)", x = x, y = 100 * d$inclusion_error, color = "#f7b825", width = 3,
             tips = sprintf("Cut-off %.0f%% of the line: leakage <b>%.1f%%</b>", x, 100 * d$inclusion_error)),
        list(name = "Exclusion error (under-coverage)", x = x, y = 100 * d$exclusion_error, color = "#c5192d", width = 3,
             tips = sprintf("under-coverage <b>%.1f%%</b>", 100 * d$exclusion_error))),
        "Cut-off (% of the poverty line)", "Error (%)", ymax = 100, ypct = TRUE)
      o$xAxis$min <- min(x); o$xAxis$max <- max(x)
      o$series[[1]]$markLine <- ec_markline(list(list(xAxis = now)), "current")
      o
    })
    # Residuals against predicted welfare: a cloud centred on zero at every
    # level; a slope means the poorest are predicted too well-off.
    output$pmt_resid_plot <- render_echart({
      f <- fitted()$pmt; req(f)
      d <- pmt_eval_sample(f); req(nrow(d) > 0)
      res <- d$actual - d$predicted
      o <- ec_scatter(d$predicted, res, rep("Households", nrow(d)), c(Households = "#0A6EB4"),
                      "Predicted log welfare per person", "Measured - predicted", tip_fmt = "%s<br>%s: %.2f<br>%s: %+.2f", size = 4, opacity = 0.5)
      o$legend <- NULL; o$grid$top <- 16
      o$series[[1]]$markLine <- list(silent = TRUE, symbol = "none", label = list(show = FALSE), animation = FALSE,
                                     data = list(list(yAxis = 0, lineStyle = list(type = "dashed", color = EC_REF)),
                                                 list(xAxis = f$log_line, lineStyle = list(type = "dotted", color = "#c5192d", width = 2))))
      o
    })
    # Each compared model's trade-off: leakage against under-coverage as the
    # cut-off moves; the curve nearest the bottom-left corner is best.
    output$pmt_compare_plot <- render_echart({
      b <- bench(); req(isTRUE(b$pmt), length(b$curves) > 1)
      cols <- c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#6c757d")
      o <- ec_lines(lapply(seq_along(b$curves), function(k) {
        d <- b$curves[[k]]
        list(name = names(b$curves)[k], x = 100 * d$inclusion_error, y = 100 * d$exclusion_error,
             color = cols[(k - 1) %% length(cols) + 1], width = 2.5,
             tips = sprintf("<b>%s</b>, cut-off %.0f%% of the line<br>leakage %.1f%%, under-coverage %.1f%%",
                            ec_esc(names(b$curves)[k]), 100 * d$mult, 100 * d$inclusion_error, 100 * d$exclusion_error))
      }), "Inclusion error, leakage (%)", "Exclusion error, under-coverage (%)", 100, 100, TRUE, TRUE)
      o$tooltip <- ec_tip()
      for (k in seq_along(o$series)) o$series[[k]]$showSymbol <- TRUE
      o
    })
    # The PMT accuracy measures at the current threshold (threshold step).
    pmt_acc_now <- reactive({
      req(pmt(), fitted()$pmt)
      s <- scored(); y <- outcome_binary(); r <- eval_rows()
      req(length(s$eligible) == length(y))
      pmt_accuracy(s$eligible[r], y[r] == 1)
    })
    # (React: StepThreshold's PmtAccuracy)
    output$sc_pmt_accuracy <- shinyreact::reactive_output({
      a <- safe(pmt_acc_now()); if (is.null(a)) return(NULL)
      f <- fitted()$pmt
      pmt_accuracy_figs(a, f, pmt_cut(f))
    })

    # Prevalence split by the outcome: a criterion that is equally common in
    # both groups adds points without separating anyone.
    output$prevalence_plot <- render_echart({
      wts <- current_weights()
      df <- assessment_df()
      y <- outcome_binary()
      req(nrow(wts) > 0, !is.null(df), length(y) == nrow(df))
      rows <- lapply(wts$criterion, function(cl) {
        x <- as_binary_criterion(df[[cl]])
        if (is.null(x)) return(NULL)
        ok <- !is.na(x) & !is.na(y)
        data.frame(criterion = cl, vuln = 100 * mean(x[ok & y == 1] == 1), not = 100 * mean(x[ok & y == 0] == 1))
      })
      d <- do.call(rbind, rows)
      req(!is.null(d), nrow(d) > 0)
      d <- d[order(-abs(d$vuln - d$not)), , drop = FALSE]   # the widest separators first
      lab <- W(c("Vulnerable", "Not vulnerable"))
      ec_bars(d$criterion, list(
        list(name = lab[1], values = round(d$vuln, 1), color = "#c5192d", tips = sprintf("%s<br>%s: <b>%.1f%%</b>", ec_esc(d$criterion), lab[1], d$vuln)),
        list(name = lab[2], values = round(d$not, 1), color = "#3f7e44", tips = sprintf("%s<br>%s: <b>%.1f%%</b>", ec_esc(d$criterion), lab[2], d$not))),
        horizontal = TRUE, value_name = "% households meeting it", pct = TRUE)
    })

    # The benchmarks are fixed once fitted, but the scorecard row follows the
    # weights as they are edited and the scheme as it is switched, so the cost
    # of each choice is visible straight away.
    live_bench <- reactive({
      b <- bench(); req(b, !isTRUE(b$pmt), nrow(b$table) > 0)   # a PMT comparison has its own table
      sp <- split_state(); y <- outcome_binary(); sc <- scored()$score
      auc <- function(rows) if (length(rows)) roc_curve(sc[rows], y[rows])$auc else NA_real_
      i <- which(b$table$model == "Scorecard (as adopted)")
      if (length(i)) {
        b$table$model[i] <- "Scorecard (current weights)"
        b$table$auc_train[i] <- auc(sp$train)
        b$table$auc_test[i] <- auc(sp$test)
        b$table$criteria[i] <- nrow(current_weights())
        names(b$roc)[names(b$roc) == "Scorecard (as adopted)"] <- "Scorecard (current weights)"
        b$roc[["Scorecard (current weights)"]] <- roc()$curve
      }
      b
    })

    model_tables_dl <- download_handler(
      filename = function() export_file_name("Scorecard_model_tables", "xlsx", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        f <- fitted()
        b <- tryCatch(live_bench(), error = function(e) NULL)
        wts <- if (is.null(f)) NULL else tryCatch(current_weights(), error = function(e) f$weights)
        save_workbook_readonly(model_tables_workbook(NULL, wts, if (is.null(b)) NULL else b$table), file)
      }
    )
    output$dl_model_tables <- model_tables_dl
    output$dl_model_tables2 <- model_tables_dl

    output$comparison_roc <- render_echart({
      b <- live_bench(); req(length(b$roc) > 0)
      pal <- c("#0A6EB4", "#26bde2", "#3f7e44", "#f7b825", "#c5192d", "#8a96a3")
      nm <- names(b$roc)[vapply(b$roc, function(r) NROW(r) > 0, logical(1))]
      o <- ec_lines(lapply(seq_along(nm), function(i) {
        cur <- ec_thin(b$roc[[nm[i]]], 400)
        list(name = nm[i], x = cur$fpr, y = cur$tpr, color = pal[(i - 1) %% length(pal) + 1], width = if (i == 1) 3 else 2,
             tips = sprintf("<b>%s</b><br>recall %.1f%%, false positive rate %.1f%%", ec_esc(nm[i]), 100 * cur$tpr, 100 * cur$fpr))
      }), "False positive rate", "Recall", 1, 1)
      o$tooltip <- ec_tip()
      o$series[[1]]$markLine <- list(silent = TRUE, symbol = "none", label = list(show = FALSE),
                                     lineStyle = list(type = "dashed", color = "#9aa5b1", width = 1.2),
                                     data = list(list(list(coord = c(0, 0)), list(coord = c(1, 1)))))
      o
    })

    # -----------------------------------------------------------------------
    # Step 5: threshold, errors, bands
    # -----------------------------------------------------------------------

    # Rows the design is judged on: the held-out sample when there is one, so
    # the AUC and the error matrix are not flattered by the training data.
    eval_rows <- reactive({
      sp <- split_state()
      y <- outcome_binary()
      if (is.null(sp)) return(which(!is.na(y)))
      if (length(sp$test)) sp$test else sp$train
    })

    output$eval_note <- renderText({
      sp <- split_state()
      if (is.null(sp)) return("")
      if (length(sp$test)) {
        sprintf("Errors, AUC and the matrix below are measured on the %s held-out households the model never saw.",
                format(length(sp$test), big.mark = ","))
      } else {
        "No hold-out sample: errors and AUC are measured on the same households the model was fitted to, and will be optimistic."
      }
    })

    # Everything the design did, gathered for the Markdown report. Each piece
    # is optional so a partial design still produces a (partial) record.
    # The report follows the interface language chosen in the navbar.
    report_lang <- function() {
      l <- tryCatch(session$rootScope()$input$lang_selector, error = function(e) NULL)
      if (identical(l, "fr")) "fr" else "en"
    }

    output$download_report <- download_handler(
      filename = function() export_file_name(if (no_outcome()) "Vulnerability_ranking_report" else if (pmt()) "PMT_design_report" else "Targeting_design_report", "html", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        # a PMT's report speaks of poor households, leakage and under-coverage
        if (pmt()) { old_terms <- options(tw.terms = "pmt"); on.exit(options(old_terms), add = TRUE) }
        safe <- function(expr) tryCatch(expr, error = function(e) NULL)
        df <- assessment_df()
        y <- safe(outcome_binary())
        f <- fitted()
        sp <- split_state()
        e <- safe(errors())
        r <- safe(eval_rows())
        s <- safe(scored())
        rc <- safe(roc())
        wts <- if (is.null(f)) NULL else safe(current_weights())
        lower <- (tol_applied()[1] %||% 5) / 100
        upper <- (tol_applied()[2] %||% 20) / 100
        rl <- live_runs()
        runs_df <- if (length(rl)) data.frame(
          Run = vapply(rl, function(x) paste0("#", x$id, if (isTRUE(x$id == current_run()))
            (if (adopted_current()) " (current, adopted)" else " (current)") else ""), character(1)),
          Model = vapply(rl, function(x) model_label(x$settings$method), character(1)),
          Scheme = vapply(rl, function(x) scheme_label(x$settings$scheme, x$settings$method), character(1)),
          Criteria = vapply(rl, function(x) nrow(x$fit$weights), integer(1)),
          AUC = vapply(rl, function(x) x$auc %||% NA_real_, numeric(1)),
          stringsAsFactors = FALSE) else NULL
        fit_stats <- if (!is.null(f) && inherits(f$model, "glm")) sprintf(
          "AIC %.1f, McFadden pseudo-R2 %.3f", stats::AIC(f$model), 1 - f$model$deviance / f$model$null.deviance)
        bl <- safe(blockers())
        x <- list(
          generated = fmt_datetime(),
          source = assessment_source(), n_rows = if (is.null(df)) NA else nrow(df),
          areas = scope$text(),
          n_cols = if (is.null(df)) NA else ncol(df),
          calc_vars = calc_vars(),
          outcome = oc(), outcome_pos = opos(),
          pmt = if (pmt()) safe({
            pc <- pmt_pc(); line <- pmt_line_value(); ap <- pmt_applied()
            list(welfare = ap$welfare, unit = ap$unit, size = ap$size,
                 line = line, line_mode = ap$mode, share = ap$share,
                 median = stats::median(pc, na.rm = TRUE), n = sum(!is.na(pc)),
                 requirements = pmt_requirements(pc, pmt_poor(pc, line), per_person = identical(ap$unit, "pc"),
                                                 size_given = nzchar(ap$size %||% ""), n_proxies = length(criteria_sel())),
                 numeric = intersect(pmt_numeric_sel(), criteria_sel()),
                 fit = if (!is.null(f$pmt)) f$pmt[setdiff(names(f$pmt), c("sample", "eval"))],
                 accuracy = safe(pmt_acc_now()),
                 comparison = if (isTRUE(bench()$pmt)) bench()$table,
                 cutoff = if (!is.null(f$pmt) && is.numeric(thr_applied())) pmt_predicted_welfare(thr_applied(), f$pmt$intercept))
          }),
          n_outcome = sum(!is.na(y)), n_vuln = sum(y == 1, na.rm = TRUE),
          prevalence = if (is.null(y)) NA else mean(y == 1, na.rm = TRUE),
          vuln_area = safe(vuln_area_tab()), vuln_area_col = input$vuln_area,
          candidates = criteria_sel(),
          blocked = if (is.null(bl)) NULL else unlist(bl[setdiff(names(bl), c(oc(), allowed_blocked()))]),
          allowed_blocked = if (length(allowed_blocked())) stats::setNames(vapply(allowed_blocked(), function(a) bl[[a]] %||% "", character(1)), allowed_blocked()),
          allowed_reason = allowed_reason(),
          screening = screened(), collinear = collinear(),
          corr_pairs = safe({
            kept0 <- if (is.null(screened())) character(0) else screened()$criterion[screened()$retained]
            cp <- correlated_groups(df, union(kept0, names(collinear())), input$corr_cutoff %||% 0.8)$pairs
            cp$removed <- vapply(seq_len(nrow(cp)), function(i) {
              gone <- setdiff(c(cp$a[i], cp$b[i]), kept0); if (length(gone)) paste(gone, collapse = ", ") else "none"
            }, character(1))
            cp
          }),
          quick_screen = if (is.null(qs_result())) NULL else
            list(alpha = input$qs_alpha %||% 0.05, adjust = input$qs_adjust %||% "BH"),
          screen_settings = list(alpha = input$alpha, adjust = input$adjust, corr = input$corr_cutoff),
          model = if (is.null(f)) NULL else list(
            method = model_label(f$method),
            scheme = scheme_label(f$scheme, f$method),
            method_code = f$method, scheme_code = f$scheme, stepwise = f$stepwise %||% "none", stepwise_dir = f$stepwise_dir %||% "backward",
            n_train = f$n, n_test = length(sp$test), seed = model_params$split_seed,
            weights = input$model_weights, dropped = f$dropped, filled = f$filled, converged = f$converged,
            tuning = f$tuning, tree_rules = f$tree_rules, diagram = if (!isFALSE(model_params$diagram)) f$diagram, k_quality = f$index$k_quality,
            fit_stats = fit_stats),
          runs = runs_df, estimates = wts,
          index = if (isTRUE(f$unsupervised) || isTRUE(f$method %in% c("pca", "lda"))) f$index,
          index_structure = if (identical(f$index$type, "lda")) safe({
            pts <- index_points()
            vapply(colnames(pts$M), function(cl) { v <- pts$M[, cl]
              if (stats::sd(v) == 0 || stats::sd(pts$x) == 0) NA_real_ else stats::cor(v, pts$x) }, numeric(1))
          }),
          effects = if (!isTRUE(f$method %in% c("pca", "lda"))) safe(effects()),
          comparison = if (!pmt()) safe(live_bench()$table),
          threshold = thr_applied(), threshold_note = thr_msg(),
          tolerance = c(lower, upper), rationale = input$tol_rationale,
          bands = safe({ sc_ <- scored()$score
            lapply(c(Quartiles = 4L, Quintiles = 5L), function(n) { b <- score_bands(sc_, n)
              names(b) <- c(if (n == 4L) "Quartile" else "Quintile", "From", "To", "Households"); b }) }),
          no_outcome = no_outcome(), rank_label = input$rank_label, stability = stability(),
          insights = if (no_outcome()) safe(sel_insights()), cov_area = if (no_outcome()) safe(cov_area_tab()), cov_area_col = input$cov_area,
          selected = if (no_outcome()) safe(list(n = sum(scored()$eligible %in% TRUE), share = mean(scored()$eligible %in% TRUE))),
          tolerance_changed = tol_changed(),
          exceed_note = if (adopted_current()) user_setup$scorecard$exceed_note else if (nzchar(exceed_note())) exceed_note(),
          eval_note = if (!is.null(sp) && length(sp$test)) sprintf("%s held-out households", length(sp$test)) else "the households the model was fitted on",
          auc = rc$auc %||% NA_real_, errors = e,
          verdict = if (is.null(e)) NULL else safe(error_verdict(e$inclusion_error, e$exclusion_error, lower, upper)),
          adopted = adopted_current(),
          adopted_at = if (adopted_current()) user_setup$scorecard$adopted_at,
          other_in_use = !adopted_current() && !scorecard_is_empty(user_setup$scorecard),
          country_office = user_setup$country_office
        )
        pt <- NULL
        if (!is.null(e) && !is.null(rc)) {
          tpr <- e$correctly_included / max(1, e$correctly_included + e$excluded_in_need)
          fpr <- e$included_not_in_need / max(1, e$included_not_in_need + e$correctly_excluded)
          pt <- data.frame(fpr = fpr, tpr = tpr)
        }
        plots <- design_report_plots(lang = report_lang(),
          weights = wts, roc = rc$curve, roc_point = pt,
          score = if (!is.null(s) && !is.null(r)) s$score[r], vulnerable = if (!is.null(y) && !is.null(r)) y[r] == 1,
          threshold = thr_applied())
        # Every chart of the design page, as static figures.
        kept <- if (is.null(screened())) character(0) else screened()$criterion[screened()$retained]
        b <- safe(live_bench())
        dirs <- if (is.null(wts)) NULL else stats::setNames(wts$direction, wts$criterion)
        plots <- c(plots, design_report_extra_plots(
          df = df, criteria = kept, vulnerable = if (is.null(y)) NULL else y == 1,
          model_rocs = if (is.null(b)) NULL else b$roc,
          score = if (!is.null(s) && !is.null(r)) s$score[r],
          threshold = thr_applied(),
          detail = if (is.null(s)) NULL else s$detail,
          eligible = if (is.null(s)) NULL else s$eligible,
          directions = dirs, lang = report_lang()),
          if (no_outcome() && !is.null(s)) ranking_report_plots(s$score, thr_applied(), map = safe({
            m <- map_data(); k <- seq_along(m$x); if (length(k) > 1500) k <- sort(sample(k, 1500))
            data.frame(x = m$x[k], y = m$y[k], group = m$group[k], xlab = m$xlab_short, ylab = m$ylab) }),
            cov_area = safe(cov_area_tab()), lang = report_lang()),
          design_report_index_plots(if (isTRUE(f$unsupervised) || isTRUE(f$method %in% c("pca", "lda"))) f$index,
                                    structure = x$index_structure, lang = report_lang()),
          if (pmt() && !is.null(f$pmt)) safe(pmt_report_plots(f$pmt, pmt_cut(f$pmt), if (isTRUE(bench()$pmt)) bench()$curves, report_lang())))
        if (!is.null(s) && !is.null(r)) {
          # the boxplot compares groups on the evaluation households
          plots$box <- design_report_extra_plots(score = s$score[r], vulnerable = y[r] == 1,
                                                 threshold = thr_applied(), lang = report_lang())$box
        }
        va <- x$vuln_area
        if (!is.null(va) && nrow(va)) {
          plots$vuln_area <- rp_stacked_share(va$area, va$share, 100 * x$prevalence, lang = report_lang())
        }
        x$variables_md <- variables_md(c(oc(), kept, if (!is.null(wts)) wts$criterion), session)
        write_design_report(file, x, plots, lang = report_lang())
      }
    )

    output$kpi_auc_title <- renderText({
      sp <- split_state()
      if (!is.null(sp) && length(sp$test)) "AUC (held out)" else "AUC (in sample)"
    })

    draft_scorecard <- reactive({
      wts <- current_weights()
      build_scorecard(wts, outcome = if (no_outcome()) NULL else if (pmt()) sprintf("PMT: log welfare per person (%s)", oc()) else input$outcome_col,
                      outcome_positive = if (no_outcome()) NULL else opos(),
                      threshold = thr_applied() %||% thr_pending() %||% 0,
                      kind = card_kind(), pmt = pmt_card())
    })

    scored <- reactive({
      df <- assessment_df()
      req(df)
      apply_scorecard(df, draft_scorecard())
    })

    roc <- reactive({
      s <- scored()
      y <- outcome_binary()
      req(length(s$score) == length(y))
      r <- eval_rows()
      roc_curve(s$score[r], y[r])
    })

    score_max <- reactive({
      df <- assessment_df(); w <- tryCatch(current_weights(), error = function(e) NULL)
      if (is.null(df) || is.null(w) || !nrow(w)) return(10)
      m <- suppressWarnings(max(apply_scorecard(df, build_scorecard(w, threshold = 0, kind = card_kind()))$score, na.rm = TRUE))
      if (is.finite(m) && m > 0) ceiling(m * 100) / 100 else 10
    })
    score_min <- reactive({
      if (!pmt()) return(0)
      df <- assessment_df(); w <- tryCatch(current_weights(), error = function(e) NULL)
      if (is.null(df) || is.null(w) || !nrow(w)) return(0)
      m <- suppressWarnings(min(apply_scorecard(df, build_scorecard(w, threshold = 0, kind = "pmt"))$score, na.rm = TRUE))
      if (is.finite(m)) min(0, floor(m * 100) / 100) else 0
    })
    # Every programmatic move of the slider goes through here: nothing that
    # is not a finite number reaches the browser, and it stays in range.
    set_threshold <- function(t) {
      t <- suppressWarnings(as.numeric(t))
      if (length(t) != 1 || !is.finite(t)) return(invisible(FALSE))
      t <- round(min(max(isolate(score_min()), t), isolate(score_max())), 5)
      updateSliderInput(session, "threshold", value = t)
      thr_applied(t)
      invisible(TRUE)
    }

    # A new fit starts from the threshold that keeps both errors lowest,
    # rather than from 0 (everyone with any point eligible).
    thr_pending <- reactiveVal(NULL)
    # The threshold and the tolerance band count once applied; the helper
    # buttons (minimise errors, Youden, caseload, poverty line) apply theirs.
    thr_applied <- reactiveVal(NULL)
    tol_applied <- reactiveVal(as.numeric(TOL_DEFAULT))
    observeEvent(input$thr_apply, {
      req(input$thr_apply > 0)   # a React button sends 0 at start
      t <- suppressWarnings(as.numeric(input$threshold))
      lo <- suppressWarnings(as.numeric(input$tol_lower %||% tol_applied()[1])); up <- suppressWarnings(as.numeric(input$tol_upper %||% tol_applied()[2]))
      need_ok(length(t) == 1 && is.finite(t), "Set the threshold first.")
      need_ok(isTRUE(is.finite(lo) && is.finite(up) && lo >= 0 && up > lo && up < 50),
              "The tolerance band needs a lower bound below the upper one, and an upper bound below 50%.")
      thr_applied(t); tol_applied(c(lo, up))
    })
    # Threshold or tolerance changed but not applied (React: the Apply row)
    thr_stale <- reactive({
      t <- suppressWarnings(as.numeric(input$threshold)); a <- thr_applied()
      tol_now <- c(suppressWarnings(as.numeric(input$tol_lower %||% tol_applied()[1])), suppressWarnings(as.numeric(input$tol_upper %||% tol_applied()[2])))
      same_t <- length(t) == 1 && !is.null(a) && isTRUE(all.equal(t, a))
      !(same_t && isTRUE(all.equal(tol_now, tol_applied())))
    })
    apply_balanced <- function(announce = TRUE) {
      s <- scored(); y <- outcome_binary(); r <- eval_rows()
      req(length(s$score) == length(y))
      b <- balanced_threshold(s$score[r], y[r] == 1)
      if (is.na(b$threshold)) {
        thr_msg("No cut-point does better than selecting everyone: consider blanket assistance for this population.")
        return(invisible(NULL))
      }
      t <- round(b$threshold, 5)
      thr_pending(t)
      set_threshold(t)
      if (announce) thr_msg(sprintf(
        "Suggested threshold %s keeps both errors as low as possible together: inclusion %.1f%%, exclusion %.1f%% (the larger of the two is minimised).",
        fmt5(t), 100 * b$inclusion_error, 100 * b$exclusion_error))
    }
    observeEvent(fitted(), {
      if (!is.null(isolate(restoring()))) return()
      if (!is.null(fitted()$pmt)) return(apply_line())
      if (!isTRUE(fitted()$unsupervised)) return(apply_balanced())
      t <- round(unsupervised_start_threshold(fitted(), apply_scorecard(assessment_df(), build_scorecard(fitted()$weights, kind = "ranking"))$score), 5)
      thr_pending(t); set_threshold(t)
      thr_msg(switch(if (identical(fitted()$index$type, "cluster")) "cluster" else fitted()$method,
        count = "Starting threshold: a third of the total weight (the global MPI's cut-off). Set it to the number of deprivations that defines vulnerability here.",
        cluster = "Starting threshold: the cut that best reproduces the targeted profiles.",
        "Starting threshold: selects the 30% of households with the highest index. Set it from the caseload."))
    }, ignoreNULL = TRUE)
    stability <- reactiveVal(NULL)
    output$kpi_selected <- renderText({
      s <- scored(); n <- sum(!is.na(s$score))
      sprintf("%s (%.1f%%)", format(sum(s$eligible, na.rm = TRUE), big.mark = ","), 100 * mean(s$eligible, na.rm = TRUE))
    })
    output$kpi_alpha <- renderText({
      a <- fitted()$index$alpha
      if (is.null(a) || is.na(a)) "n/a" else sprintf("%.2f", a)
    })
    observeEvent(input$run_stability, {
      req(input$run_stability > 0)   # a React button sends 0 at start
      f <- fitted(); need_ok(isTRUE(f$unsupervised), "Fit a ranking first.")
      r <- runs()[[current_run()]]
      share <- mean(scored()$eligible, na.rm = TRUE)
      need_ok(share > 0 && share < 1, "Set a threshold that selects some households, not none or all.")
      df <- assessment_df()
      wcol <- input$model_weights
      a <- list(df = df[, r$criteria, drop = FALSE], criteria = r$criteria, method = f$method, share = share,
                anchor = f$index$anchor, weights = if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]] else NULL,
                k = f$index$k %||% 3, pca_axes = r$settings$pca_axes %||% 1, pca_min_var = r$settings$pca_min_var)
      bg_run("Checking the stability of the selection (20 refits)...", stability_job, a,
             on_error = function(msg) showNotification(paste("Stability check failed:", msg), type = "error"),
             on_done = function(res) stability(c(res, list(share = share))))
    })
    sel_insights <- reactive({
      f <- fitted(); req(isTRUE(f$unsupervised))
      selection_insights(assessment_df(), current_weights(), scored()$eligible)
    })
    # Without an outcome (React: StepThreshold's RankingFacts): the stability
    # check's result and what the selection concentrates.
    output$sc_ranking <- shinyreact::reactive_output({
      st <- stability()
      si <- safe(sel_insights())
      list(stability = if (!is.null(st)) list(word = stability_word(st$jaccard), jaccard = u(st$jaccard), draws = u(st$draws),
                                              low = u(st$low), high = u(st$high), share = u(st$share), spearman = u(st$spearman %||% NA)),
           insights = if (!is.null(si)) list(ratio = u(si$ratio), mean_sel = u(si$mean_sel), mean_not = u(si$mean_not),
                                             n_criteria = u(si$n_criteria), concentration = u(si$concentration), share = u(si$share)))
    })
    observeEvent(assessment_df(), {
      df <- assessment_df(); req(df)
      cols <- names(df)[vapply(df, function(v) { k <- length(unique(v)); k >= 2 && k <= 200 }, logical(1))]
      cur <- rs_in("cov_area") %||% isolate(input$cov_area)
      guess <- find_guess(cols, c("admin1", "adm1", "province", "region", "state", "governorate", "departement"))
      updateSelectizeInput(session, "cov_area", choices = c("(none)" = "", cols), selected = if (isTRUE(cur %in% cols)) cur else guess %||% "")
    })
    cov_area_tab <- reactive({
      a <- input$cov_area; df <- assessment_df(); s <- scored()
      req(isTRUE(fitted()$unsupervised), shiny::isTruthy(a), a %in% names(df))
      g <- as.character(df[[a]]); ok <- !is.na(g) & nzchar(g)
      d <- stats::aggregate(list(sel = s$eligible[ok] %in% TRUE), list(area = g[ok]), function(v) c(n = length(v), s = mean(v)))
      d <- data.frame(area = d$area, n = d$sel[, "n"], share = d$sel[, "s"])
      d[order(-d$share), , drop = FALSE]
    })
    output$cov_area_plot <- render_echart({
      d <- cov_area_tab(); req(nrow(d))
      overall <- 100 * mean(scored()$eligible %in% TRUE)
      ec_bars(d$area, list(list(name = "Selected", values = round(100 * d$share, 1), color = "#0A6EB4",
                                tips = sprintf("<b>%s</b><br>%.1f%% selected of %s households", ec_esc(d$area), 100 * d$share, format(d$n, big.mark = ",")),
                                markLine = ec_markline(list(list(yAxis = overall)), sprintf("all areas: %.0f%%", overall), dotted = TRUE))),
              value_name = "% selected", pct = TRUE, legend = FALSE)
    })

    output$sel_by_met_plot <- render_echart({
      s <- scored(); req(ncol(s$detail) > 0)
      met <- rowSums(s$detail != 0, na.rm = TRUE)
      d <- stats::aggregate(list(sel = s$eligible %in% TRUE), list(met = met), function(v) c(n = length(v), p = mean(v)))
      d <- data.frame(met = d$met, n = d$sel[, "n"], p = 100 * d$sel[, "p"])
      o <- ec_bars(d$met, list(list(name = "Selected", values = round(d$p, 1), color = "#0A6EB4",
                                    tips = sprintf("%d criteria met<br><b>%.0f%%</b> selected (of %s households)", d$met, d$p, format(d$n, big.mark = ",")))),
                   value_name = "% selected", pct = TRUE, legend = FALSE, rotate = 0)
      o$xAxis$name <- "Criteria met by the household"; o$xAxis$nameLocation <- "middle"; o$xAxis$nameGap <- 26
      o
    })

    output$rank_plot <- render_echart({
      s <- scored(); req(length(s$score))
      ec_histogram(s$score, thr_applied() %||% 0, "Score")
    })
    output$sel_prev_plot <- render_echart({
      s <- scored(); df <- assessment_df(); f <- fitted(); req(f, df, length(s$eligible) == nrow(df))
      crit <- intersect(f$weights$criterion, names(df))
      el <- s$eligible %in% TRUE
      p <- vapply(crit, function(cl) {
        x <- as_binary_criterion(df[[cl]]); x[is.na(x)] <- 0L
        c(100 * mean(x[el] == 1), 100 * mean(x[!el] == 1))
      }, numeric(2))
      gap <- p[1, ] - p[2, ]
      o <- order(-gap)
      cats <- crit[o]
      tip <- function(k, lab) sprintf("%s<br>%s: <b>%.1f%%</b> meet it<br>gap %+.0f points", ec_esc(cats), lab, p[k, o], gap[o])
      ec_bars(cats, list(list(name = "Selected", values = round(p[1, o], 1), color = "#0A6EB4", tips = tip(1, "Selected")),
                         list(name = "Not selected", values = round(p[2, o], 1), color = "#8a96a3", tips = tip(2, "Not selected"))),
              value_name = "% of households meeting it", pct = TRUE)
    })
    observeEvent(input$thr_balanced, { req(input$thr_balanced > 0); apply_balanced() })
    # A PMT's standard cut-off: predicted welfare per person at the line.
    apply_line <- function() {
      f <- fitted()$pmt; req(f)
      t <- f$threshold_line
      thr_pending(t); set_threshold(t)
      thr_msg(sprintf("Threshold %s: eligible when predicted welfare per person is at or below the poverty line (%s).", fmt5(t), fmt_money(f$line)))
    }
    observeEvent(input$thr_line, { req(input$thr_line > 0); apply_line() })
    # The notes that a setting waits for its button, and the PMT cut-off in
    # welfare (cheap; React: the estimates header and the Apply row)
    output$sc_stale <- shinyreact::reactive_output({
      f <- fitted()$pmt; t <- thr_applied()
      w <- if (!is.null(f) && is.numeric(t)) pmt_predicted_welfare(t, f$intercept)
      list(points = isTRUE(safe(points_stale())), thr = isTRUE(safe(thr_stale())),
           pmt_line = if (!is.null(w)) list(welfare = fmt_money(w), pct = u(100 * w / f$line)))
    })
    observeEvent(input$threshold, {
      if (isTRUE(all.equal(input$threshold, thr_pending()))) thr_pending(NULL)
    })

    errors <- reactive({
      s <- scored()
      y <- outcome_binary()
      req(length(s$score) == length(y))
      r <- eval_rows()
      design_errors(s$score[r] > (thr_applied() %||% 0), y[r] == 1)
    })

    # Threshold helpers (Advisory 3/2025). Both only move the slider.
    thr_msg <- reactiveVal("")
    output$thr_note <- renderText(thr_msg())

    observeEvent(input$thr_youden, {
      req(input$thr_youden > 0)   # a React button sends 0 at start
      r <- roc()
      need_ok(is.finite(r$youden), "Fit a model first: the Youden point comes from its ROC curve.")
      t <- max(0, r$youden)
      set_threshold(t)
      thr_msg(sprintf("Youden's J cut-point: score > %s (maximises recall minus false-positive rate).", fmt5(t)))
    })

    observeEvent(input$thr_caseload, {
      req(input$thr_caseload > 0)   # a React button sends 0 at start
      s <- scored()
      pct <- input$caseload_pct
      if (!isTruthy(pct) || pct <= 0 || pct > 100) {
        showNotification("Enter the caseload as a percentage of households (1-100).", type = "warning")
        return()
      }
      sc <- sort(s$score, decreasing = TRUE)
      n <- length(sc)
      k <- floor(n * pct / 100)
      # Eligible means score > t. Take the (k+1)-th highest score so no more
      # than k households qualify: a caseload is a budget ceiling, and ties at
      # the boundary must fall below it rather than above.
      t <- if (k >= n) 0 else sc[k + 1]
      set_threshold(t)
      got <- sum(s$score > t)
      thr_msg(sprintf("Threshold %s selects %s households (%.1f%%) against a %s%% caseload.",
                      fmt5(t), format(got, big.mark = ","), 100 * got / n, pct))
    })

    output$kpi_auc <- renderText({
      a <- roc()$auc
      if (is.na(a)) "n/a" else sprintf("%.3f", a)
    })
    output$kpi_elig <- renderText({
      e <- errors()
      sprintf("%s (%.1f%%)",
              format(e$correctly_included + e$included_not_in_need, big.mark = ","),
              100 * (e$coverage %||% NA_real_))
    })

    output$roc_plot <- render_echart({
      r <- roc()
      req(nrow(r$curve) > 0)
      cur <- r$curve
      t_now <- thr_applied() %||% 0
      here <- cur[which.min(abs(cur$threshold - t_now)), , drop = FALSE]
      ec_roc(cur, here, r$auc, W("Scorecard"))
    })

    output$score_plot <- render_echart({
      s <- scored()
      y <- outcome_binary()
      req(length(s$score) == length(y))
      ok <- !is.na(y) & !is.na(s$score)
      # Mirrored: vulnerable above the axis, not vulnerable below, each as a
      # share of its own group, so neither hides the other.
      ec_mirrored(s$score[ok], y[ok] == 1, thr_applied() %||% 0, W("Scorecard score"), labels = W(c("Vulnerable", "Not vulnerable")))
    })

    # Weight times prevalence: the points a criterion actually contributes
    # across the caseload. A heavy weight on a rare criterion moves almost
    # nobody, which the weights table alone does not show.
    output$contribution_plot <- render_echart({
      s <- scored()
      req(ncol(s$detail) > 0)
      total <- vapply(s$detail, function(v) sum(abs(v), na.rm = TRUE), numeric(1))
      share <- 100 * total / max(sum(total), 1e-9)
      items <- draft_scorecard()$items
      dir <- stats::setNames(vapply(items, function(i) i$direction, character(1)), vapply(items, function(i) i$criterion, character(1)))
      cr <- names(s$detail)
      # inclusion criteria to the right of 0, exclusion criteria to the left,
      # each group largest first: the two kinds never mix
      d <- unname(dir[cr]); excl <- d %in% "exclusion"
      o <- c(which(!excl)[order(-share[!excl])], which(excl)[order(-share[excl])])
      signed <- ifelse(excl, -share, share)
      g <- ec_lollipop(cr[o], round(signed[o], 2), d[o],
                       sprintf("<b>%s</b> (%s)<br>%.1f%% of all points moved", ec_esc(cr[o]), ifelse(excl[o], "exclusion", "inclusion"), share[o]),
                       "Share of points (%): inclusion to the right, exclusion to the left")
      g$xAxis$axisLabel <- list(formatter = "fn:abspctv")
      m <- max(share, 1)
      g$xAxis$min <- if (any(excl)) -ceiling(m) else 0
      g$xAxis$max <- if (any(!excl)) ceiling(m) else 0
      attr(g, "height") <- drive_pair_height(length(cr))
      g
    })

    # How many criteria a household meets, eligible against not: if the two
    # distributions overlap heavily the threshold is doing little work.
    # Score by outcome as boxplots, threshold drawn across: how far apart the
    # two groups sit, and how much of each falls on the wrong side.
    output$box_plot <- render_echart({
      s <- scored(); y <- outcome_binary()
      req(length(s$score) == length(y))
      g <- grp_of(y)
      ok <- !is.na(g)
      ec_box(s$score[ok], g[ok], vn_cols(), W("Scorecard score"), thr_applied() %||% 0)
    })

    # Of the households meeting each criterion, the share the current
    # threshold makes eligible, split by outcome: a criterion whose vulnerable
    # holders are poorly covered is carrying little weight in practice.
    output$coverage_plot <- render_echart({
      s <- scored(); y <- outcome_binary()
      req(ncol(s$detail) > 0, length(y) == nrow(s$detail))
      cr <- colnames(s$detail)
      p <- vapply(cr, function(cl) {
        met <- s$detail[[cl]] != 0
        c(100 * mean(s$eligible[met & y %in% 1]), 100 * mean(s$eligible[met & y %in% 0]))
      }, numeric(2))
      p[!is.finite(p)] <- NA
      lab <- W(c("Vulnerable", "Not vulnerable"))
      tip <- function(k) sprintf("%s<br>%s: <b>%s</b> eligible", ec_esc(cr), lab[k], ifelse(is.na(p[k, ]), "n/a", sprintf("%.1f%%", p[k, ])))
      o <- ec_bars(cr, list(list(name = lab[1], values = round(p[1, ], 1), color = "#c5192d", tips = tip(1)),
                            list(name = lab[2], values = round(p[2, ], 1), color = "#3f7e44", tips = tip(2))),
                   horizontal = TRUE, value_name = "% of holders eligible", pct = TRUE)
      attr(o, "height") <- drive_pair_height(length(cr))
      o
    })

    output$met_plot <- render_echart({
      s <- scored()
      req(ncol(s$detail) > 0)
      met <- rowSums(s$detail != 0, na.rm = TRUE)
      el <- s$eligible %in% TRUE
      lv <- seq(0, max(met))
      a <- tabulate(met[el] + 1L, length(lv)); b <- tabulate(met[!el] + 1L, length(lv))
      tip <- function(n, lab) sprintf("%d criteria met<br>%s: <b>%s</b> households", lv, lab, format(n, big.mark = ","))
      o <- ec_bars(lv, list(list(name = "Eligible", values = a, color = "#0A6EB4", tips = tip(a, "Eligible")),
                            list(name = "Not eligible", values = b, color = "#8a96a3", tips = tip(b, "Not eligible"))),
                   value_name = "Households", rotate = 0)
      o$xAxis$name <- "Criteria met by the household"; o$xAxis$nameLocation <- "middle"; o$xAxis$nameGap <- 26
      o
    })

    # Score percentiles, in a dialog: the user picks the cut points, the table
    # is computed there on Compute and can be exported.
    pct_res <- reactiveVal(NULL)
    observeEvent(input$pct_open, {
      req(input$pct_open > 0)   # a React button sends 0 at start
      need_ok(!is.null(tryCatch(scored(), error = function(e) NULL)), "Fit a model first.")
      pct_res(NULL)
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("percent"), " Score percentiles"), size = "l", easyClose = TRUE,
        tags$p(class = "small text-muted", "Households between consecutive percentiles of the score, on the households the threshold is evaluated on."),
        tags$div(class = "d-flex flex-wrap gap-3 align-items-end",
                 radioButtons(ns("pct_preset"), NULL, inline = TRUE, selected = "q4",
                              choices = c("Quartiles" = "q4", "Quintiles" = "q5", "Deciles" = "q10", "My percentiles" = "custom")),
                 conditionalPanel(sprintf("input['%s'] === 'custom'", ns("pct_preset")),
                                  textInput(ns("pct_custom"), "Percentiles", placeholder = "e.g. 10, 25, 50, 75, 90", width = "16rem")),
                 tags$div(class = "mb-3", actionButton(ns("pct_go"), "Compute", icon = icon("play"), class = "btn-primary btn-sm"))),
        uiOutput(ns("pct_table")),
        footer = tagList(downloadButton(ns("pct_dl"), "Export (Excel)", class = "btn-outline-primary"), modalButton("Close"))))
    })
    observeEvent(input$pct_go, {
      probs <- switch(input$pct_preset %||% "q4",
                      q4 = c(.25, .5, .75), q5 = seq(.2, .8, .2), q10 = seq(.1, .9, .1),
                      custom = suppressWarnings(as.numeric(strsplit(input$pct_custom %||% "", "[^0-9.]+")[[1]])) / 100)
      probs <- probs[is.finite(probs) & probs > 0 & probs < 1]
      need_ok(length(probs) > 0, "Type percentiles between 1 and 99, e.g. 10, 25, 50, 75, 90.")
      s <- scored(); r <- tryCatch(eval_rows(), error = function(e) NULL)
      sc <- if (!is.null(r)) s$score[r] else s$score
      pct_res(list(tab = score_percentiles(sc, probs), probs = probs))
    })
    output$pct_table <- renderUI({
      p <- pct_res()
      if (is.null(p)) return(tags$div(class = "small text-muted", "Choose the percentiles, then click Compute."))
      t <- p$tab; req(nrow(t))
      tags$div(class = "wfp-model-table-wrap", tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(tags$th("Band"), tags$th(class = "num", "Score from"), tags$th(class = "num", "to"),
                           tags$th(class = "num", "Households"), tags$th(class = "num", "Share"))),
        tags$tbody(lapply(seq_len(nrow(t)), function(i) tags$tr(
          tags$td(tags$strong(t$band[i])), tags$td(class = "num", fmt5(t$from[i])), tags$td(class = "num", fmt5(t$to[i])),
          tags$td(class = "num", format(t$households[i], big.mark = ",")), tags$td(class = "num", sprintf("%.1f%%", t$share[i])))))))
    })
    output$pct_dl <- download_handler(
      filename = function() export_file_name("Score_percentiles", "xlsx"),
      content = function(file) {
        p <- pct_res(); t <- if (is.null(p)) data.frame(Message = "Click Compute first") else p$tab
        if (!is.null(p)) names(t) <- c("Band", "Score from", "Score to", "Households", "Share (%)")
        write_xlsx_readonly(t, file, "Percentiles")
      })

    # -----------------------------------------------------------------------
    # The React page (react/src/pages/design/): what it draws, as JSON
    #
    # Facts only, from the reactives the Shiny page used, so the two cannot
    # disagree. sc_meta never changes; sc_flow is the stepper, each step's
    # footer, the gates and the small notes; the others are the tables and
    # the figures the user works with. A table whose rows hold inputs (Use
    # ticks, points) is sent again only when the Shiny page redrew it, and
    # the page then sets its inputs back to the values sent, as the redraw did.
    # -----------------------------------------------------------------------
    safe <- function(expr) tryCatch(expr, error = function(e) NULL)
    choice_list <- function(ch) lapply(seq_along(ch), function(i) list(value = unname(ch[[i]]), label = names(ch)[i]))
    stamp <- function() as.numeric(Sys.time())
    # Shiny sends a data frame column by column; the page reads rows. Names
    # come off too: a named number would arrive as an object.
    rows_of <- function(d) if (is.null(d) || !NROW(d)) list() else
      lapply(seq_len(nrow(d)), function(i) lapply(as.list(d[i, , drop = FALSE]), function(v) unname(v)))
    u <- function(x) unname(as.vector(x))

    output$sc_meta <- shinyreact::reactive_output(list(
      models = list(outcome = choice_list(scorecard_model_choices()), pmt = choice_list(pmt_model_choices()),
                    none = choice_list(unsupervised_model_choices())),
      schemes = choice_list(scorecard_scheme_choices()),
      compare_default = I(intersect(c("logit", "woe", "stumps"), scorecard_model_choices())),
      pmt_compare_default = I(c("pmt_ols", "pmt_qr", "pmt_lasso")),
      axes = I(c("pca", "mca")), clusters = I(cluster_methods()),
      help = CHART_HELP, tol_default = I(TOL_DEFAULT)))

    # Where the design stands: the stepper, each step's footer and gate, the
    # notes that say a setting waits for its button.
    output$sc_flow <- shinyreact::reactive_output({
      df <- assessment_df()
      has_data <- !is.null(df)
      mode <- input$framework_mode %||% "outcome"
      nof <- no_outcome(); fr <- isTRUE(safe(framework_ready())); f <- fitted()
      here <- input$steps %||% "outcome"
      adopted <- isTRUE(safe(adopted_current()))
      todo <- safe(missing_steps()) %||% character(0)
      panels <- c(outcome = "Vulnerability Framework", screening = "Criteria",
                  weights = "Model & weights", threshold = "Threshold & errors")
      st <- list(
        list(key = "data", label = "Data", done = has_data, panel = "data",
             todo = "Load the assessment data (file or MODA) on the left."),
        list(key = "outcome", label = panels[["outcome"]],
             done = has_data && (nof || (pmt() && fr) || (shiny::isTruthy(input$outcome_col) && shiny::isTruthy(input$outcome_pos))),
             panel = "outcome", todo = "Choose the outcome and the level that means vulnerable, a welfare measure and its poverty line, or build a ranking without one."),
        list(key = "screening", label = panels[["screening"]], done = isTRUE(selection_applied()) && length(ready_criteria()) > 0,
             panel = "screening", todo = "Check the Use ticks (binarise variables or review correlations if needed), then continue to the model."),
        list(key = "weights", label = panels[["weights"]], done = !is.null(f),
             panel = "weights", todo = "Fit the model; iterate until satisfied."),
        list(key = "threshold", label = panels[["threshold"]], done = !is.null(f) && !is.null(thr_applied() %||% thr_pending()),
             panel = "threshold", todo = "Set the threshold and check the design errors."),
        list(key = "adopt", label = "Adopted", done = adopted, panel = "threshold",
             todo = "Record the rationale, then adopt the scorecard."))
      keys <- vapply(st, `[[`, character(1), "key")
      done <- vapply(st, `[[`, logical(1), "done")
      todo_i <- which(!done)[1]
      cur <- st[[match(here, keys, nomatch = 2L)]]
      status <- if (is.na(todo_i)) list(kind = "complete", text = sprintf("Design complete: the %s is adopted and ready for Beneficiary Selection.",
                                                                          if (nof) "vulnerability ranking" else "scorecard"))
        else if (isTRUE(cur$done) && identical(here, "threshold")) list(kind = "todo", text = st[[length(st)]]$todo)
        else if (isTRUE(cur$done)) list(kind = "done", text = "This step is done.")
        else list(kind = "todo", text = cur$todo)
      cur_i <- match(here, names(panels))
      # each step's footer
      res <- screened()
      u <- safe(use_shown())
      use <- if (is.null(res) || is.null(u)) character(0) else res$criterion[u]
      if (pmt()) use <- c(use, setdiff(pmt_numeric_sel(), use))
      sent <- isTRUE(selection_applied()) && setequal(use, ready_criteria())
      nav <- list(
        outcome = list(ok = fr,
                       done = if (nof) "No outcome indicator: the design will rank households on the criteria you choose."
                              else if (pmt()) sprintf("Welfare validated: %s per person, poverty line %s.", pmt_applied()$welfare %||% "",
                                                      fmt_money(tryCatch(pmt_line_value(), error = function(e) NA_real_)))
                              else sprintf("Outcome set: %s = %s.", input$outcome_col %||% "", input$outcome_pos %||% ""),
                       todo = if (pmt()) "Load assessment data above, set the welfare variable and the poverty line, then Validate."
                              else "Load assessment data above, then choose the outcome and the level that means vulnerable."),
        screening = list(ok = length(use) > 0, n = length(use),
                         done = paste0(sprintf("%d criteria ticked", length(use)), if (sent) ": sent to the model." else "."),
                         todo = "Tick at least one variable in the Use column."),
        weights = list(ok = !is.null(f), done = if (is.null(f)) "" else sprintf("Model fitted on %d criteria. Iterate above if needed.", nrow(f$weights)),
                       todo = "Fit the model first."),
        threshold = list(ok = !length(todo), adopted = adopted, adopted_at = if (adopted) user_setup$scorecard$adopted_at %||% "",
                         done = if (!scorecard_is_empty(user_setup$scorecard)) "Another scorecard is in use. Adopting replaces it with this design."
                                else "Check the errors and the verdict, record the rationale, then adopt.",
                         todo = paste0("Still to do: ", paste(todo, collapse = ", "), ".")))
      # the notes that say a setting waits for its button
      fw <- local({ a <- fw_applied()
        if (is.null(a) || !identical(a$mode, mode)) "validate" else if (identical(a$mode, "outcome") && !identical(a, fw_now())) "stale" else "ok" })
      pmt_note <- local({ a <- pmt_applied(); k <- setdiff(names(a), "weights")
        if (is.null(a)) "validate" else if (!identical(a[k], pmt_now()[k])) "stale" else "ok" })
      qp <- qs_params()
      m <- input$model_method
      params <- c(
        if (!nof) sprintf("Hold-out %s%%, seed %s", model_params$holdout_pct, model_params$split_seed),
        if (has_axes(m)) {
          if (identical(model_params$pca_mode, "var")) sprintf("axes: the fewest explaining %s%% of the variation", model_params$pca_min_var)
          else sprintf("%d axis(es) kept", as.integer(model_params$pca_axes))
        },
        if (isTRUE(m %in% cluster_methods()))
          sprintf("%s, seed %s", if (isTRUE(model_params$auto_k)) "profiles chosen by silhouette" else sprintf("%d profiles", as.integer(model_params$n_clusters)),
                  model_params$split_seed),
        if (!nof && isTRUE(m %in% tunable_models()) && isTRUE(model_params$tune)) sprintf("tuned by %d-fold cross-validation", as.integer(model_params$folds)),
        if (isTRUE(m %in% diagram_models()) && isFALSE(model_params$diagram)) "no diagram")
      list(
        mode = mode, here = here, has_data = has_data,
        data = if (has_data) list(rows = nrow(df), cols = ncol(df), source = assessment_source() %||% "unknown"),
        steps = lapply(st, function(x) x[c("key", "label", "done", "panel")]), todo_i = if (is.na(todo_i)) NULL else todo_i,
        status = status,
        earlier = if (!is.na(todo_i) && todo_i < match(here, keys)) list(label = st[[todo_i]]$label, panel = st[[todo_i]]$panel),
        next_panel = if (!is.na(cur_i) && cur_i < length(panels)) names(panels)[cur_i + 1],
        next_label = if (!is.na(cur_i) && cur_i < length(panels)) panels[[cur_i + 1]],
        nav = nav, gates = list(screening = !fr, weights = !length(ready_criteria()), threshold = is.null(f)),
        framework_ready = fr, fw_note = fw, pmt_note = pmt_note,
        qs_stale = !is.null(qp) && !isTRUE(all.equal(qp, qs_now())),
        fit = if (!is.null(f)) list(method = f$method, unsupervised = isTRUE(f$unsupervised), pmt = !is.null(f$pmt),
                                    index = safe(index_method()), cluster = identical(f$index$type, "cluster"),
                                    runs_inline = isTRUE(safe(runs_in_comparison()))),
        params = if (length(params)) paste(params, collapse = " \u00b7 "),
        scheme_apply = !is.null(f) && !identical(f$scheme, input$model_scheme) && !isTRUE(f$method %in% c("pca", "lda")) &&
          !identical(f$scheme, "pmt") && !isTRUE(f$unsupervised),
        adopted = adopted, can_adopt = !length(todo))
    })

    # Step 1: the outcome (or the welfare) at a glance
    output$sc_framework <- shinyreact::reactive_output({
      out <- list(outcome = NULL, pmt = NULL)
      y <- if (!pmt()) safe(outcome_binary())
      if (!is.null(y)) {
        n <- sum(!is.na(y)); k <- sum(y == 1, na.rm = TRUE)
        out$outcome <- list(n = n, pct = if (n) 100 * k / n else NA_real_, opos = opos())
      }
      if (pmt()) out$pmt <- safe({
        pc <- pmt_pc(); line <- pmt_line_value(); req(is.finite(line))
        poor <- pmt_poor(pc, line)
        rq <- pmt_requirements(pc, poor, per_person = identical(pmt_applied()$unit, "pc"), size_given = nzchar(pmt_applied()$size %||% ""))
        list(n = sum(!is.na(pc)), median = fmt_money(stats::median(pc, na.rm = TRUE)), line = fmt_money(line),
             poor = 100 * mean(poor, na.rm = TRUE), requirements = rows_of(rq[c("status", "check", "detail")]))
      })
      out
    })

    # Step 2: the criteria table (each row's Use tick is input rvuse_<criterion>)
    output$sc_criteria <- shinyreact::reactive_output({
      res <- screened()
      if (is.null(res)) return(NULL)
      nof <- no_outcome()
      r <- qs_result(); ov <- safe(overlap()); sug <- corr_suggest() %||% character(0)
      cutoff <- isolate(input$corr_cutoff) %||% 0.8
      m <- if (is.null(r)) rep(NA_integer_, nrow(res)) else match(res$criterion, r$criterion)
      sig <- if (is.null(r)) rep(FALSE, nrow(res)) else r$significant[m] %in% TRUE
      p <- if (is.null(r)) rep(NA_real_, nrow(res)) else r$p_adj[m]
      ord <- order(!sig, p, -abs(res$gap), na.last = TRUE)
      rows <- lapply(ord, function(i) {
        cr <- res$criterion[i]; k <- m[i]
        o <- if (is.null(ov)) NULL else ov[ov$criterion == cr, , drop = FALSE]
        olap <- if (cr %in% names(sug)) list(text = sprintf("repeats %s%s", sug[[cr]],
                                                            if (!nof && NROW(o) && !is.na(o$r[1])) sprintf(" (r = %.2f)", o$r[1]) else ""), high = TRUE)
          else if (!NROW(o) || is.na(o$r[1])) NULL
          else list(text = sprintf("%s (%.2f)", o$with[1], o$r[1]), high = o$r[1] >= cutoff)
        list(id = use_id(cr), criterion = cr, use = isTRUE(res$retained[i]),
             vuln = u(res$prev_vuln[i]), other = u(res$prev_not[i]), yes = u(res$prevalence[i]), missing = u(res$missing[i]),
             or = if (is.na(k)) NA else u(r$or[k]), or_low = if (is.na(k)) NA else u(r$or_low[k]), or_high = if (is.na(k)) NA else u(r$or_high[k]),
             p = u(p[i]), sig = sig[i], dir = if (is.na(k)) NA else u(r$direction[k]),
             testable = !is.na(k) && !isTRUE(r$test[k] %in% c("constant", "not binary")), overlap = olap)
      })
      list(nof = nof, rows = rows, n = nrow(res), associated = if (is.null(r)) 0L else sum(r$significant, na.rm = TRUE),
           repeating = length(sug), stamp = stamp())
    })

    # Step 2 with a welfare measure: the numeric proxies (input pnum_<column>)
    output$sc_pmt_numeric <- shinyreact::reactive_output({
      d <- pmt_num_prof(); if (is.null(d)) return(NULL)
      list(rows = lapply(seq_len(nrow(d)), function(i) list(id = pnum_id(d$proxy[i]), proxy = d$proxy[i], use = isTRUE(d$use[i]),
                                                            mean = u(d$mean[i]), missing = u(d$missing[i]), r = u(d$r[i]))),
           stamp = stamp())
    })

    # Step 3: the estimates with the editable points (inputs w_1, w_2, ...)
    output$sc_estimates <- shinyreact::reactive_output({
      weight_bump()
      f <- fitted(); if (is.null(f)) return(NULL)
      wts <- f$weights
      sp <- isolate(saved_points()); if (!is.null(sp) && nrow(sp) != nrow(wts)) sp <- NULL
      pts <- if (is.null(sp)) wts$weight else sp$weight
      is_pmt <- !is.null(f$pmt)
      oth <- if (is_pmt) NULL else other_effects(f)
      if (!is.null(oth) && !nrow(oth)) oth <- NULL
      oth_models <- if (is.null(oth)) character(0) else unique(oth$model)
      b <- bench()
      imp <- if (!is_pmt && is.list(b) && length(b$importance) && !is.null(oth)) b$importance / sum(b$importance)
      col <- function(k) if (k %in% names(wts)) wts[[k]] else rep(NA, nrow(wts))
      se <- col("std_error"); orr <- col("odds_ratio"); lo <- col("or_low"); hi <- col("or_high"); pv <- col("p_value"); ty <- col("type")
      rows <- lapply(seq_len(nrow(wts)), function(i) {
        cr <- wts$criterion[i]
        vals <- vapply(oth_models, function(mm) oth$effect[oth$criterion == cr & oth$model == mm][1], numeric(1))
        v <- c(wts$coefficient[i], vals); v <- v[!is.na(v) & v != 0]
        list(id = paste0("w_", i), criterion = cr, numeric = identical(u(ty[i]), "numeric"), beta = u(wts$coefficient[i]), se = u(se[i]),
             or = u(orr[i]), or_low = u(lo[i]), or_high = u(hi[i]), p = u(pv[i]), dir = u(wts$direction[i]), points = u(pts[i]),
             others = I(unname(vals)), imp = if (is.null(imp)) NA else unname(imp[cr]),
             agree = if (length(oth_models) && length(v) >= 2) length(unique(sign(v))) == 1 else NA)
      })
      fit_line <- if (!is.null(f$model) && inherits(f$model, "glm"))
        sprintf("n = %s  \u00b7  AIC %.1f  \u00b7  McFadden pseudo-R\u00b2 %.3f  \u00b7  intercept %+.3f",
                format(f$model$tw_n %||% length(f$model$y), big.mark = ","), stats::AIC(f$model),
                1 - f$model$deviance / f$model$null.deviance, stats::coef(f$model)[1])
      list(pmt = is_pmt, unsupervised = isTRUE(f$unsupervised), others = I(oth_models), has_imp = !is.null(imp),
           rows = rows, fit_line = fit_line, stamp = stamp())
    })

    # Step 3: the model comparison and the run history
    output$sc_comparison <- shinyreact::reactive_output({
      f <- fitted()
      rl <- live_runs(); best <- best_run(rl)
      runs <- lapply(rev(rl), function(r) list(
        id = r$id, at = r$at, model = model_label(r$settings$method),
        scheme = if (isTRUE(r$settings$unsupervised)) "ranking" else scheme_label(r$settings$scheme, r$settings$method),
        criteria = nrow(r$fit$weights), auc = u(r$auc %||% NA_real_), held_out = isTRUE(r$held_out),
        current = isTRUE(r$id == current_run()), best = isTRUE(r$id == best)))
      out <- list(kind = "none", runs = runs, title = W("Run history"))
      if (is.null(f) || isTRUE(f$unsupervised)) return(out)
      b <- bench()
      if (!is.null(f$pmt)) {
        out$kind <- "pmt"
        if (!is.null(b$table) && nrow(b$table) >= 2)
          out$table <- rows_of(b$table[intersect(c("model", "proxies", "r2_train", "r2_test", "inclusion_error", "exclusion_error", "accuracy", "cgh"), names(b$table))])
        return(out)
      }
      out$kind <- "scorecard"
      out$why <- if (is.null(b)) "Choose models in \u201cModels to compare\u201d above and fit again."
                 else if (!is.null(b$error)) paste("The models could not be compared:", b$error)
                 else if (!nrow(b$table)) "None of the compared models could be fitted on these data."
      if (is.null(out$why)) out$table <- rows_of(safe(live_bench()$table[c("model", "criteria", "auc_train", "auc_test")]))
      out
    })

    # Step 4: the slider's range, and the value it starts from
    output$sc_slider <- shinyreact::reactive_output({
      mx <- score_max(); mn <- score_min()
      v <- isolate(thr_pending() %||% thr_applied()) %||% 0
      list(min = u(mn), max = u(mx), value = u(min(max(mn, v), mx)), stamp = stamp())
    })

    # Step 4: the errors, the matrix and the verdict
    output$sc_threshold <- shinyreact::reactive_output({
      e <- safe(errors())
      if (is.null(e) || !isTRUE(e$n > 0)) return(NULL)
      lower <- (tol_applied()[1] %||% 5) / 100
      upper <- (tol_applied()[2] %||% 20) / 100
      v <- tryCatch(error_verdict(e$inclusion_error, e$exclusion_error, lower, upper),
                    error = function(err) list(level = "invalid", interpretation = conditionMessage(err),
                                               action = "Lower the upper tolerance below 50%."))
      if (pmt()) { v$interpretation <- W(v$interpretation); v$action <- W(v$action) }
      keys <- c(vuln = "Vulnerable", notvuln = "Not vulnerable", incl = "Inclusion error", excl = "Exclusion error",
                card = "Scorecard", elig = "Eligible", notelig = "Not eligible", axis_row = "Scorecard decision \u2193",
                axis_col = "Assessment outcome \u2192", incl_mean = "selected but not in need", excl_mean = "in need but not selected")
      list(e = lapply(e, u), lower = u(lower), upper = u(upper), threshold = fmt5(thr_applied() %||% 0), outcome = oc(), opos = opos(), pmt = pmt(),
           verdict = v[c("level", "interpretation", "action")], words = as.list(stats::setNames(W(unname(keys)), names(keys))))
    })

    # The stepper's buttons send the page to show; the data lives in the
    # sidebar, which the page opens itself.
    observeEvent(input$flow_go, {
      if (!identical(input$flow_go, "data")) bslib::nav_select("steps", input$flow_go, session = session)
    })

    # Adoption is the last step: every earlier one must be done first.
    missing_steps <- function() {
      c(if (is.null(assessment_df())) "load the assessment data",
        if (!no_outcome() && !framework_ready()) if (pmt()) "choose the welfare variable and the poverty line" else "choose the outcome",
        if (!isTRUE(selection_applied()) || !length(ready_criteria())) "choose the criteria and send them to the model",
        if (is.null(fitted())) "fit the model",
        if (is.null(thr_applied() %||% thr_pending())) "set the threshold",
        if (no_outcome() && !nzchar(trimws(rich_text(input$tol_rationale %||% ""))))
          "record the rationale for the ranking and the threshold (no outcome: errors cannot be measured)",
        if (!no_outcome() && tol_changed() && !nzchar(trimws(rich_text(input$tol_rationale %||% ""))))
          sprintf("explain in the rationale why the tolerance band differs from the default (%s%% - %s%%)", TOL_DEFAULT[1], TOL_DEFAULT[2]))
    }
    tol_changed <- function() !isTRUE(all.equal(c(as.numeric(tol_applied()[1] %||% TOL_DEFAULT[1]), as.numeric(tol_applied()[2] %||% TOL_DEFAULT[2])),
                                                as.numeric(TOL_DEFAULT)))

    # Errors beyond the upper tolerance can still be adopted, with a short
    # explanation from the country office that the report and the workbook
    # carry (Advisory 2/2025: the decision must be documented).
    exceed_note <- reactiveVal("")
    beyond_tolerance <- function() {
      e <- tryCatch(errors(), error = function(err) NULL)
      up <- (tol_applied()[2] %||% TOL_DEFAULT[2]) / 100
      if (is.null(e)) return(character(0))
      c(if (isTRUE(e$inclusion_error > up)) sprintf("inclusion error %.1f%%", 100 * e$inclusion_error),
        if (isTRUE(e$exclusion_error > up)) sprintf("exclusion error %.1f%%", 100 * e$exclusion_error))
    }
    adopt_scorecard <- function() {
      todo <- missing_steps()
      if (length(todo)) {
        showNotification(paste0("Before adopting, ", paste(todo, collapse = ", "), "."), type = "warning", duration = 10)
        return()
      }
      over <- beyond_tolerance()
      if (length(over)) {
        showModal(modalDialog(
          title = tagList(bsicons::bs_icon("exclamation-triangle"), " Errors beyond the tolerance"),
          easyClose = FALSE,
          footer = tagList(modalButton("Cancel"),
                           actionButton(ns("adopt_confirm"), "Adopt with this explanation", icon = icon("check"), class = "btn-primary")),
          tags$p(sprintf("The %s %s above the upper tolerance of %s%%.", paste(over, collapse = " and "),
                         if (length(over) > 1) "are" else "is", tol_applied()[2] %||% TOL_DEFAULT[2])),
          textAreaInput(ns("exceed_text"), "Why adopt this design anyway? (shown in the design report and the scorecard workbook)",
                        value = exceed_note(), rows = 4, width = "100%",
                        placeholder = "e.g. No better design with the criteria available at registration; the programme will verify exclusion through community validation and the complaint mechanism.")))
        return()
      }
      exceed_note("")
      do_adopt()
    }
    observeEvent(input$adopt_confirm, {
      txt <- trimws(input$exceed_text %||% "")
      need_ok(nchar(txt) >= 10, "Write a short explanation (a sentence or two).")
      exceed_note(txt)
      removeModal()
      do_adopt()
    })
    do_adopt <- function() {
      sc <- draft_scorecard()
      sc$source <- "design"
      sc$fingerprint <- scorecard_fingerprint(sc)
      sc$adopted_at <- fmt_datetime()
      sc$country_office <- user_setup$country_office
      sc$exceed_note <- if (nzchar(exceed_note())) exceed_note()
      # A ranking tells Selection what it is: purpose, method, orientation,
      # validity, and its profiles (to place registration households in them).
      if (no_outcome()) {
        ix <- fitted()$index; st <- stability()
        sc$ranking <- list(label = input$rank_label %||% "", method = model_label(fitted()$method),
                           oriented_by = anchor_text(ix$anchor),
                           stability = if (is.null(st)) NA_real_ else st$jaccard,
                           alpha = ix$alpha %||% NA_real_,
                           profiles = if (identical(ix$type, "cluster")) ix$profiles,
                           target = if (identical(ix$type, "cluster")) ix$target)
      }
      user_setup$scorecard <- sc
      e <- tryCatch(errors(), error = function(err) NULL)
      audit_add(modification_log, "Design", "Scorecard adopted",
                sprintf("%d criteria, eligible above %s%s", length(sc$items), fmt5(sc$threshold),
                        if (is.null(e)) "" else sprintf("; inclusion error %.1f%%, exclusion error %.1f%%",
                                                        100 * e$inclusion_error, 100 * e$exclusion_error)),
                reason = paste(c(rich_text(input$tol_rationale),
                                 if (nzchar(exceed_note())) paste("Adopted beyond tolerance:", exceed_note())), collapse = " | "))
      showNotification(
        sprintf("%s adopted: %d criteria, eligible above %s. Beneficiary Selection can now apply it.",
                if (no_outcome()) "Vulnerability ranking" else "Scorecard",
                length(sc$items), fmt5(sc$threshold)),
        type = "message", duration = 10
      )
    }

    # Is the card in use exactly the design on screen?
    adopted_current <- reactive({
      sc <- user_setup$scorecard
      if (scorecard_is_empty(sc) || !identical(sc$source, "design")) return(FALSE)
      cur <- tryCatch(scorecard_fingerprint(draft_scorecard()), error = function(e) NA_character_)
      identical(cur, sc$fingerprint)
    })

    # Any change to an adopted design withdraws the adoption: Beneficiary
    # Selection must never apply a card the analyst has since changed without
    # approving it again. (A card loaded from a workbook is not this design's
    # to withdraw.) Stands aside while a saved session is being restored.
    observe({
      sc <- user_setup$scorecard
      if (scorecard_is_empty(sc) || !identical(sc$source, "design")) return()
      if (!is.null(restoring())) return()
      if (adopted_current()) return()
      user_setup$scorecard <- NULL
      audit_add(modification_log, "Design", "Adoption withdrawn", "The design changed after adoption")
      showNotification("The design changed after it was adopted, so the adoption was withdrawn. Adopt it again to use it for selection.",
                       type = "warning", duration = 12)
    })
    observeEvent(input$btn_use, { req(input$btn_use > 0); adopt_scorecard() })
    observeEvent(input$nav_adopt, { req(input$nav_adopt > 0); adopt_scorecard() })

    output$use_status <- renderText({
      sc <- user_setup$scorecard
      if (scorecard_is_empty(sc)) return(if (no_outcome()) "No ranking adopted yet." else "No scorecard adopted yet.")
      sprintf("%s: %d criteria, threshold %s.",
              if (adopted_current()) "Adopted" else "In use (loaded from a workbook)",
              length(sc$items), fmt5(sc$threshold %||% 0))
    })

    # The full tables behind the design report's charts (which show the 15
    # most relevant variables): the Report_tables sheet of the scorecard.
    design_full_tables <- function(s) {
      safe <- function(expr) tryCatch(expr, error = function(e) NULL)
      df <- assessment_df(); y <- safe(outcome_binary())
      kept <- if (is.null(screened())) character(0) else screened()$criterion[screened()$retained]
      out <- list()
      ix <- fitted()$index
      if (identical(ix$type, "cluster")) {
        pr <- ix$profiles[, ix$rank, drop = FALSE]
        out[["Household profiles (share meeting each criterion, most vulnerable first)"]] <- data.frame(
          Criterion = rownames(pr), round(100 * pr, 1), check.names = FALSE)
        out[["Profile sizes"]] <- data.frame(Profile = colnames(ix$profiles)[ix$rank], `Share of households (%)` = round(100 * ix$size[ix$rank], 1),
                                             Targeted = ifelse(ix$rank %in% ix$target, "yes", "no"), check.names = FALSE)
      }
      ca <- if (no_outcome()) safe(cov_area_tab())
      if (!is.null(ca) && nrow(ca)) out[["Share selected by area"]] <- data.frame(
        Area = ca$area, Households = ca$n, `Selected (%)` = round(100 * ca$share, 1), check.names = FALSE)
      if (!is.null(df) && length(kept) && length(y) == nrow(df)) {
        p <- safe(criteria_profile(df, kept, y))
        if (!is.null(p)) out[["How common each criterion is (all criteria)"]] <- data.frame(
          Criterion = p$criterion, `Among vulnerable (%)` = round(100 * p$prev_vuln, 1),
          `Among others (%)` = round(100 * p$prev_not, 1), `Gap (pts)` = round(100 * p$gap, 1), check.names = FALSE)
        cm <- if (length(kept) > 1) safe(criteria_cor(df, kept))
        if (!is.null(cm)) out[["Correlation between the selected variables"]] <- data.frame(Variable = rownames(cm), round(cm, 3), check.names = FALSE)
      }
      w <- safe(current_weights())
      if (!is.null(w) && nrow(w)) out[["Points by criterion (all criteria)"]] <- data.frame(
        Criterion = w$criterion, Direction = w$direction, Points = w$weight, check.names = FALSE)
      det <- s$detail
      if (!is.null(det) && ncol(det)) {
        tot <- vapply(det, function(v) sum(abs(v), na.rm = TRUE), numeric(1))
        dr <- data.frame(Criterion = names(det), `Share of points (%)` = round(100 * tot / max(sum(tot), 1e-9), 1), check.names = FALSE)
        if (length(y) == nrow(det) && length(s$eligible) == nrow(det)) {
          pc <- function(m, v) { x <- s$eligible[m & y %in% v]; if (length(x)) round(100 * mean(x), 1) else NA }
          dr[["Holders eligible, vulnerable (%)"]] <- vapply(names(det), function(cl) pc(det[[cl]] != 0, 1), numeric(1))
          dr[["Holders eligible, others (%)"]] <- vapply(names(det), function(cl) pc(det[[cl]] != 0, 0), numeric(1))
        }
        out[["What drives the score, and coverage by criterion (all criteria)"]] <- dr[order(-dr[[2]]), , drop = FALSE]
      }
      va <- safe(vuln_area_tab())
      if (is.data.frame(va) && nrow(va)) out[["Vulnerable households by area (all areas)"]] <- va
      fp <- fitted()$pmt
      if (pmt() && !is.null(fp)) {
        cmp <- if (isTRUE(bench()$pmt)) bench()$table
        if (!is.null(cmp)) out[["PMT model comparison (held-out households, cut-off at the line)"]] <- data.frame(
          Model = cmp$model, Proxies = cmp$proxies, `R2 training` = round(cmp$r2_train, 4), `R2 held out` = round(cmp$r2_test, 4),
          `Leakage (%)` = round(100 * cmp$inclusion_error, 1), `Under-coverage (%)` = round(100 * cmp$exclusion_error, 1),
          `Accuracy (%)` = round(100 * cmp$accuracy, 1), CGH = round(cmp$cgh, 3), check.names = FALSE)
        dc <- pmt_decile_coverage(fp$eval, pmt_cut(fp))
        out[["Selected by decile of measured welfare (D1 poorest)"]] <- data.frame(Decile = paste0("D", dc$decile),
                                                                                 `Selected (%)` = round(100 * dc$selected, 1), check.names = FALSE)
        cu <- pmt_error_curve(fp$eval, fp$log_line)
        out[["Leakage and under-coverage by cut-off"]] <- data.frame(`Cut-off (% of the line)` = round(100 * cu$mult),
          `Leakage (%)` = round(100 * cu$inclusion_error, 1), `Under-coverage (%)` = round(100 * cu$exclusion_error, 1),
          `Selected (%)` = round(100 * cu$selected, 1), check.names = FALSE)
      }
      out
    }

    # Draft registration form from the adopted design (editable, not locked)
    observe(gate_button("download_xlsform", isTRUE(adopted_current()),
                        "Adopt the design first (Use this scorecard): the form is built from the adopted one."))
    output$download_xlsform <- download_handler(
      filename = function() export_file_name("Registration_form_draft_XLSForm", "xlsx"),
      content = function(file) {
        sc <- user_setup$scorecard
        if (!isTRUE(adopted_current()) || scorecard_is_empty(sc)) {
          openxlsx::write.xlsx(data.frame(Message = "Adopt the design first: the form is built from the adopted one."), file)
          return(invisible())
        }
        sc_ <- tryCatch(apply_scorecard(assessment_df(), sc)$score, error = function(e) numeric(0))
        sc_ <- sc_[is.finite(sc_)]
        cuts <- if (length(sc_)) list(quartiles = stats::quantile(sc_, c(.25, .5, .75), names = FALSE),
                                     quintiles = stats::quantile(sc_, c(.2, .4, .6, .8), names = FALSE)) else list()
        # the area levels mapped on the registration data, if loaded
        reg <- tryCatch(uploaded_df(), error = function(e) NULL)
        lv <- unlist(lapply(c("admin1", "admin2", "admin3", "admin4", "village"), function(k) {
          cl <- user_setup[[k]]; if (length(cl) == 1 && !is.na(cl) && nzchar(cl) && !is.null(reg) && cl %in% names(reg)) cl }))
        areas <- if (length(lv)) unique(reg[, lv, drop = FALSE]) else NULL
        crit <- vapply(sc$items, function(it) it$criterion, character(1))
        labs <- stats::setNames(vapply(crit, function(cl) { l <- var_label(cl); if (is.na(l) || !nzchar(l)) NA_character_ else l }, character(1)), crit)
        labs <- labs[!is.na(labs)]   # without a label: the scorecard's own
        title <- paste(c("Household registration", user_setup$country_office), collapse = " - ")
        xlsform_write(xlsform_draft(sc, cuts, areas, labs, title), file)
        audit_add(modification_log, "Design", "Draft registration form exported",
                  sprintf("XLSForm from the adopted design: %d criteria", length(sc$items)))
      }
    )

    output$download <- download_handler(
      filename = function() export_file_name(if (no_outcome()) "Vulnerability_Ranking" else if (pmt()) "PMT_Targeting" else "Targeting_Scorecard", "xlsx", "%Y-%m-%d_%Hh%Mm"),
      content = function(file) {
        req(fitted())
        if (pmt()) { old_terms <- options(tw.terms = "pmt"); on.exit(options(old_terms), add = TRUE) }
        sc <- draft_scorecard()
        s <- scored()
        nof <- no_outcome()
        e <- if (nof) list(n = sum(!is.na(s$score)), correctly_included = sum(s$eligible, na.rm = TRUE), included_not_in_need = 0,
                           coverage = mean(s$eligible, na.rm = TRUE), inclusion_error = NA_real_, exclusion_error = NA_real_)
             else errors()
        r <- if (nof) list(auc = NA_real_, curve = NULL) else roc()
        lower <- (tol_applied()[1] %||% 5) / 100
        upper <- (tol_applied()[2] %||% 20) / 100
        v <- tryCatch(error_verdict(e$inclusion_error, e$exclusion_error, lower, upper),
                      error = function(err) list(interpretation = "n/a", action = "n/a"))
        pct <- function(x) if (is.na(x)) "n/a" else sprintf("%.1f%%", 100 * x)

        # Field names here are the contract read_scorecard_workbook() relies on
        # for Outcome, Vulnerable level and Eligibility threshold.
        meta <- list(
          "Outcome" = sc$outcome %||% "",
          "Vulnerable level" = sc$outcome_positive %||% "",
          "Eligibility threshold" = sprintf("score > %s", fmt5(sc$threshold %||% 0)),
          "Country office" = user_setup$country_office %||% "",
          "Designed on" = fmt_date(sc$created %||% Sys.Date()),
          "Review due" = "Every 2-3 years in stable contexts, annually in highly dynamic ones (WFP Targeting OGN, 2021), or when new assessment data arrives.",
          "Criteria in the card" = length(sc$items),
          "Households scored" = format(e$n, big.mark = ","),
          "Eligible" = sprintf("%s (%s)",
                               format(e$correctly_included + e$included_not_in_need, big.mark = ","),
                               pct(e$coverage)),
          "Model AUC" = if (is.na(r$auc)) "n/a" else sprintf("%.3f", r$auc),
          "Design inclusion error" = pct(e$inclusion_error),
          "Design exclusion error" = pct(e$exclusion_error),
          "Correctly included" = format(e$correctly_included, big.mark = ","),
          "Included, not in need" = format(e$included_not_in_need, big.mark = ","),
          "Excluded, in need" = format(e$excluded_in_need, big.mark = ","),
          "Correctly excluded" = format(e$correctly_excluded, big.mark = ","),
          "Tolerance band" = sprintf("%.0f%% - %.0f%%", 100 * lower, 100 * upper),
          # Advisory 2/2025: the rationale for the band has to be documented.
          "Threshold rationale" = if (nzchar(rich_text(input$tol_rationale)))
            rich_text(input$tol_rationale) else "NOT DOCUMENTED (Targeting Advisory 2/2025 requires it)",
          "Adopted beyond tolerance, because" = if (nzchar(exceed_note())) exceed_note() else "not applicable",
          "Model" = model_label((fitted()$method %||% "logit")),
          "Weighting scheme" = scheme_label(fitted()$scheme %||% "odds_ratio", fitted()$method),
          "Survey weights" = if (shiny::isTruthy(input$model_weights)) input$model_weights else "none",
          "Evaluation sample" = if (length(split_state()$test))
            sprintf("%s held-out households (%s%%, seed %s)", format(length(split_state()$test), big.mark = ","),
                    model_params$holdout_pct, model_params$split_seed)
            else "in sample (no hold-out)",
          "Criteria removed by stepwise" = if (length(fitted()$dropped)) paste(fitted()$dropped, collapse = ", ") else "none",
          "Criteria marked verifiable" = sprintf("%d of %d", sum(vapply(sc$items, function(i) isTRUE(i$verifiable), logical(1))), length(sc$items)),
          "Criteria community-validated" = sprintf("%d of %d%s",
            sum(vapply(sc$items, function(i) isTRUE(i$validated), logical(1))), length(sc$items),
            if (!all(vapply(sc$items, function(i) isTRUE(i$validated), logical(1))))
              " -- Advisory 1/2025 requires community validation before implementation" else ""),
          "Verdict" = v$interpretation,
          "Recommended action" = v$action,
          "Assessment source" = assessment_source() %||% "unknown",
          "Built at" = fmt_datetime(),
          "Built with" = paste0("TargetWise ",
                                tryCatch(as.character(utils::packageVersion("TargetWise")),
                                         error = function(e) ""))
        )
        if (pmt() && !is.null(fitted()$pmt)) {
          fp <- fitted()$pmt
          meta[["Vulnerable level"]] <- "poor: predicted welfare per person at or below the poverty line"
          ap <- pmt_applied()
          meta[["Welfare variable"]] <- sprintf("%s (%s)", ap$welfare %||% "",
                                                if (identical(ap$unit, "pc")) "per person" else sprintf("per household, divided by %s", ap$size %||% "?"))
          meta[["Poverty line (per person)"]] <- fmt5(fp$line)
          meta[["PMT intercept"]] <- fmt5(fp$intercept)
          meta[["PMT formula"]] <- "predicted log welfare per person = intercept - score / 100; eligible when the score is above the threshold"
          meta[["Eligible when predicted welfare per person is below"]] <- fmt_money(pmt_predicted_welfare(sc$threshold %||% 0, fp$intercept))
          meta[["R-squared (training / held out)"]] <- sprintf("%.3f / %s", fp$r2, if (is.na(fp$r2_test)) "n/a" else sprintf("%.3f", fp$r2_test))
          meta[["Weighting scheme"]] <- scheme_label("pmt")
          meta[["Model"]] <- model_label(fitted()$method)
          meta[["Prediction error (RMSE, log points)"]] <- sprintf("%.3f", fp$rmse %||% NA_real_)
          a <- tryCatch(pmt_acc_now(), error = function(e) NULL)
          if (!is.null(a)) {
            p1 <- function(v) if (is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)
            meta[["Design inclusion error"]] <- paste(p1(a$inclusion_error), "(leakage: non-poor among the selected)")
            meta[["Design exclusion error"]] <- paste(p1(a$exclusion_error), "(under-coverage: poor not selected)")
            meta[["Coverage of the poor"]] <- p1(a$coverage_poor)
            meta[["Coverage of the non-poor"]] <- p1(a$coverage_nonpoor)
            meta[["Targeting accuracy"]] <- p1(a$accuracy)
            meta[["Targeting differential (Ravallion 2000)"]] <- sprintf("%.2f", a$differential)
            meta[["CGH indicator (Coady, Grosh & Hoddinott 2004)"]] <- sprintf("%.2f", a$cgh)
            meta[["Poverty rate (headcount)"]] <- p1(a$headcount)
          }
          meta[["Model AUC"]] <- NULL
        }
        if (nof) {
          # a ranking: no outcome, so no error to report
          for (k in c("Design inclusion error", "Design exclusion error", "Correctly included", "Included, not in need",
                      "Excluded, in need", "Correctly excluded", "Tolerance band", "Model AUC", "Verdict", "Recommended action"))
            meta[[k]] <- "not measured: no outcome indicator"
          meta$Outcome <- "none: households ranked without an outcome indicator"
          meta[["Vulnerable level"]] <- ""
          meta[["What the ranking stands for"]] <- input$rank_label %||% ""
          meta[["Oriented by"]] <- anchor_text(fitted()$index$anchor)
          st <- stability()
          meta[["Stability of the selection"]] <- if (is.null(st)) "not checked" else
            sprintf("%s: %.0f%% agreement (Jaccard, %d refits)", stability_word(st$jaccard), 100 * st$jaccard, st$draws)
          meta[["Internal consistency (Cronbach's alpha)"]] <- if (is.na(fitted()$index$alpha %||% NA)) "n/a" else sprintf("%.2f", fitted()$index$alpha)
        }

        b <- bench()
        wb <- scorecard_workbook(
          sc, meta = meta, screening = screened(),
          comparison = if (!is.null(b) && !isTRUE(b$pmt)) b$table else NULL,
          bands = list(Quartiles = score_bands(s$score, 4L),
                       Quintiles = score_bands(s$score, 5L)),
          roc = r$curve,
          report_tables = design_full_tables(s)
        )
        save_workbook_readonly(wb, file)
      }
    )

    output$download_json <- download_handler(
      filename = function() export_file_name("scorecard", "json", "%Y-%m-%d"),
      content = function(file) {
        req(fitted())
        # digits = NA: full precision (the default keeps 4 digits, which moved scores)
        writeLines(as.character(jsonlite::toJSON(draft_scorecard(), auto_unbox = TRUE, digits = NA,
                                                 pretty = TRUE, null = "null", na = "null")),
                   file, useBytes = TRUE)
      }
    )

    # Downloads sit in folded sections: their links are made even while hidden.
    for (nm in c("download", "download_json", "download_report", "download_xlsform", "dl_model_tables2"))
      outputOptions(output, nm, suspendWhenHidden = FALSE)
  })
}
