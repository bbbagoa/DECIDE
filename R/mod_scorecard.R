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
  ns <- NS(id)
  tagList(
    bslib::layout_sidebar(
      fillable = FALSE,
      sidebar = bslib::sidebar(
        title = "Scorecard",
        width = 320,
        uiOutput(ns("data_status")),
        hr(),
        mod_area_scope_ui(ns("scope")),
        hr(),
        actionButton(ns("btn_use"), "Use this scorecard", icon = icon("check"),
                     class = "btn-success w-100"),
        tags$div(class = "small text-muted mt-1", textOutput(ns("use_status"))),
        hr(),
        downloadButton(ns("download"), "Export scorecard (Excel)",
                       class = "btn-outline-primary w-100"),
        downloadButton(ns("download_json"), "Export scorecard (JSON)",
                       class = "btn-outline-secondary w-100 mt-2"),
        # The whole design as a document: data, variables, screening, models,
        # threshold, errors, figures.
        downloadButton(ns("download_report"), "Design report (HTML)",
                       class = "btn-outline-secondary w-100 mt-2")
      ),

      # The data and its tools on one side, the analysis chain on the other.
      bslib::layout_columns(
        col_widths = c(4, 8), fill = FALSE, class = "mb-3 wfp-design-top",
        bslib::card(
          class = "mb-0",
          bslib::card_header(bsicons::bs_icon("clipboard-data"), " Needs-assessment data"),
          bslib::card_body(
            tags$p(class = "small text-muted mb-2",
                   "An assessment survey carrying a food-security outcome (EFSA, VAM...): ",
                   "not the registration data selected from, nor the PDM data."),
            fileInput(ns("assessment_file"), NULL, width = "100%",
                      placeholder = "Load assessment data",
                      accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet")),
            tags$div(
              class = "d-flex gap-2",
              # Reloading data is the session's job; this explains the method.
              tags$div(class = "flex-fill",
                       actionButton(ns("open_guide"), "How it works", icon = icon("book-open"),
                                    class = "btn-outline-secondary btn-sm w-100",
                                    title = "The design process step by step, with its methods")),
              # Build outcomes or criteria the data does not carry yet (a
              # two-level CARI, a dependency-ratio flag).
              tags$div(class = "flex-fill",
                       mod_var_calc_ui(ns("calc"), "Variable calculator",
                                       class = "btn-outline-secondary btn-sm w-100")))
          )
        ),
        # The whole design as one path, data to final model: done, current and
        # next are visible at a glance, and the next action is one click.
        uiOutput(ns("flow"))
      ),

      bslib::navset_card_pill(
        id = ns("steps"),

        bslib::nav_panel(
          title = "1. Vulnerability Framework",
          value = "outcome",
          bslib::card_body(
            tags$p(class = "text-muted",
                   "Pick the food-security outcome the scorecard should predict, and",
                   " which of its two levels means a vulnerable household."),
            bslib::layout_columns(
              col_widths = c(6, 6), fill = FALSE,
              selectInput(ns("outcome_col"), "Outcome variable", choices = NULL, width = "100%"),
              selectInput(ns("outcome_pos"), "Level meaning 'vulnerable'", choices = NULL, width = "100%")
            ),
            uiOutput(ns("outcome_summary")),
            uiOutput(ns("nav_outcome"))
          )
        ),

        bslib::nav_panel(
          title = "2. Criteria Selection",
          value = "criteria",
          bslib::card_body(
            tags$p(class = "text-muted",
                   "Candidate eligibility criteria. Only binary columns qualify;",
                   " anything that looks like a food-security outcome is blocked."),
            # Select all / Deselect all and search are built into the picker.
            shinyWidgets::pickerInput(
              ns("criteria"), "Candidate criteria", choices = character(0),
              multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body",
                actionsBox = TRUE, liveSearch = TRUE, size = 14,
                selectedTextFormat = "count > 3"
              )
            ),
            uiOutput(ns("blocked_note")),
            uiOutput(ns("nav_criteria"))
          )
        ),

        bslib::nav_panel(
          title = "3. Criteria Screening",
          value = "screening",
          bslib::card_body(
            uiOutput(ns("gate_screening")),
            # Descriptive only: no model is fitted here. Statistics and
            # correlations guide which candidates go forward to step 4.
            tags$p(class = "text-muted",
                   "Tick the candidates to examine and click Select: their descriptive statistics and",
                   " correlations follow. No model is fitted at this step."),
            bslib::layout_columns(
              col_widths = c(3, 9), fill = FALSE,
              numericInput(ns("corr_cutoff"),
                           tagList("Flag pairs above |r|",
                                   info_tip("Two criteria correlated above this value say nearly the same thing. The weaker of the pair is pre-ticked for dropping, so one effect is not counted twice in the score.")),
                           value = 0.8, min = 0.3, max = 1, step = 0.05)
            ),
            uiOutput(ns("screen_note")),
            uiOutput(ns("screen_table")),
            # Select -> review correlation and descriptive statistics -> drop.
            uiOutput(ns("selection_ui")),
            uiOutput(ns("nav_screening"))
          )
        ),

        bslib::nav_panel(
          title = "4. Model & weights",
          value = "weights",
          bslib::card_body(
            tags$p(class = "text-muted",
                   "Fit a model on the retained criteria and turn it into points.",
                   " Adjust any weight where local knowledge says the model is wrong --",
                   " the reference analysis does exactly this."),
            uiOutput(ns("gate_weights")),
            bslib::card(
              class = "border-0 bg-body-tertiary mb-3",
              bslib::card_body(
                class = "py-2",
                # Every model setting and the run button on one row.
                bslib::layout_columns(
                  col_widths = c(3, 3, 1, 1, 2, 2), fill = FALSE,
                  selectInput(ns("model_method"),
                              tagList("Model", model_tip()),
                              choices = scorecard_model_choices(),
                              width = "100%", selectize = FALSE),
                  selectInput(ns("model_scheme"),
                              tagList("Weighting scheme", info_tip("How model coefficients become points: odds ratios (APP-FA reference), log-odds, whole points out of 10, or 1 point per criterion.")),
                              choices = scorecard_scheme_choices(), width = "100%",
                              selectize = FALSE),
                  numericInput(ns("holdout_pct"),
                               tagList("Hold-out", info_tip("Share of households kept aside and never used to fit the model. Errors and AUC are measured on them, so the figures are honest (0 = measure on the training data).")),
                               value = 20,
                               min = 0, max = 50, step = 5, width = "100%"),
                  numericInput(ns("split_seed"),
                               tagList("Seed", info_tip("Fixes the random hold-out split so the same settings give the same result every time.")),
                               value = 123, min = 1,
                               step = 1, width = "100%"),
                  selectInput(ns("model_weights"),
                              tagList("Survey weights", info_tip("Sampling weight column. When set, the model counts each household by its weight so the estimates represent the population, not the sample.")),
                              choices = c("(none)" = ""), width = "100%", selectize = FALSE),
                  tags$div(class = "d-flex align-items-end h-100 pb-3",
                           bslib::tooltip(
                             actionButton(ns("run_fit"), "Fit model",
                                          icon = icon("play"), class = "btn-primary w-100"),
                             "Fits the chosen model on the training households, turns it into points, and adds the fit to the run history."))
                ),
                # Iterate: change the criteria (or any setting above) and fit
                # again; every fit is kept in the run history below.
                bslib::layout_columns(
                  col_widths = c(6, 3, 3), fill = FALSE,
                  shinyWidgets::pickerInput(
                    ns("fit_criteria"), "Criteria in the model (untick to drop, then fit again)",
                    choices = character(0), multiple = TRUE, width = "100%",
                    options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE,
                                                          liveSearch = TRUE,
                                                          selectedTextFormat = "count > 6")),
                  # Each extra model is a full fit: the machine-learning ones
                  # take most of the time, so only the quick ones run by default.
                  shinyWidgets::pickerInput(
                    ns("compare_models"),
                    tagList("Also compare per variable", info_tip("Models fitted next to the chosen one to show each variable's effect under every model. Machine-learning models are slow on large data: add them only when you need them.")),
                    choices = scorecard_model_choices(), selected = intersect(c("logit", "woe", "stumps"), scorecard_model_choices()),
                    multiple = TRUE, width = "100%",
                    options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE,
                                                          selectedTextFormat = "count > 2",
                                                          countSelectedText = "{0} models")),
                  tags$div(class = "pt-4",
                           checkboxInput(ns("run_benchmarks"),
                                         tagList("Compare with random forest & boosting",
                                                 info_tip(tip_body("Benchmarks (not used for targeting)", list(
                                                   list(name = "Random forest.", text = "Many decision trees on random subsets; captures interactions a card cannot.",
                                                        ref = "Breiman (2001), Random Forests, Machine Learning 45."),
                                                   list(name = "Gradient boosting.", text = "Trees added one at a time to correct the previous ones.",
                                                        ref = "Chen & Guestrin (2016), XGBoost, KDD."),
                                                   list(name = "Why.", text = "If they barely beat the card on the held-out households, a simple additive card loses little (Targeting Advisory 3/2025)."))))),
                                         value = TRUE))
                ),
                tags$div(
                  class = "d-flex flex-wrap align-items-center gap-3",
                  checkboxInput(ns("stepwise_on"),
                                tagList("Stepwise selection of the criteria",
                                        info_tip("Backward elimination before fitting, for any model: a criterion is dropped when the fit it loses is smaller than the complexity it costs. AIC is the usual choice; BIC penalises each criterion more (log of the sample size) and keeps fewer.")),
                                value = FALSE),
                  conditionalPanel(sprintf("input['%s']", ns("stepwise_on")),
                                   radioButtons(ns("stepwise_ic"), NULL, inline = TRUE,
                                                choices = c("AIC" = "aic", "BIC" = "bic"), selected = "aic"))),
                tags$div(class = "small text-muted",
                         textOutput(ns("model_note"), inline = TRUE), " ",
                         textOutput(ns("scheme_note"), inline = TRUE))
              )
            ),
            uiOutput(ns("fit_note")),
            uiOutput(ns("runs_ui")),
            hr(),
            uiOutput(ns("weights_ui")),
            # Right under the estimates: which model to trust is the next
            # question once the coefficients are read.
            uiOutput(ns("comparison_ui")),
            uiOutput(ns("effects_ui")),
            uiOutput(ns("weights_charts")),
            uiOutput(ns("nav_weights"))
          )
        ),

        bslib::nav_panel(
          title = "5. Threshold & errors",
          value = "threshold",
          bslib::card_body(
            tags$p(class = "text-muted",
                   "Choosing the eligibility threshold is a programmatic decision,",
                   " not a mechanical one (Targeting Advisory 3/2025). The curve shows",
                   " the whole trade-off; the band below is your tolerance for error."),
            uiOutput(ns("gate_threshold")),
            # Every threshold and tolerance parameter, and both helpers, on
            # one row. Advisory 3/2025: the cut-point can be set statistically
            # (Youden's J) or programmatically (to fit a caseload); both only
            # move the slider, which stays the decision.
            tags$div(
              class = "border-0 bg-body-tertiary rounded-3 px-3 pt-2 mb-2",
              bslib::layout_columns(
                col_widths = c(3, 1, 1, 1, 2, 2, 2), fill = FALSE,
                uiOutput(ns("threshold_ui")),
                numericInput(ns("tol_lower"),
                             tagList("Lower %", info_tip("Lower bound of the tolerance band (Advisory 2/2025). Errors below it are acceptable without action.")),
                             value = 5,
                             min = 0, max = 49, step = 1, width = "100%"),
                numericInput(ns("tol_upper"),
                             tagList("Upper %", info_tip("Upper bound of the tolerance band. Errors above it call for a redesign; it can never reach 50% (no better than random).")),
                             value = 20,
                             min = 1, max = 49, step = 1, width = "100%"),
                numericInput(ns("caseload_pct"),
                             tagList("Caseload", info_tip("Share of households the programme can serve. Used by 'Fit to caseload' to set the highest threshold that stays within it.")),
                             value = NA, min = 1, max = 100, step = 1, width = "100%"),
                tags$div(class = "wfp-inline-action",
                         tags$label(class = "form-label", "\u00a0"),
                         bslib::tooltip(
                           actionButton(ns("thr_balanced"), "Minimise errors",
                                        icon = icon("arrows-to-dot"), class = "btn-outline-primary w-100"),
                           "Sets the threshold where the larger of the inclusion and exclusion errors is smallest, so neither is traded away for the other.")),
                tags$div(class = "wfp-inline-action",
                         tags$label(class = "form-label", "\u00a0"),
                         bslib::tooltip(
                           actionButton(ns("thr_youden"), "Balance (Youden)",
                                        icon = icon("scale-balanced"), class = "btn-outline-primary w-100"),
                           tip_body("Youden's J", list(list(name = "", text = "Picks the threshold maximising sensitivity + specificity - 1: the point of the ROC curve furthest from the diagonal (Targeting Advisory 3/2025).",
                                                          ref = "Youden (1950), Index for rating diagnostic tests, Cancer 3(1)."))))),
                tags$div(class = "wfp-inline-action",
                         tags$label(class = "form-label", "\u00a0"),
                         bslib::tooltip(
                           actionButton(ns("thr_caseload"), "Fit to caseload",
                                        icon = icon("people-group"), class = "btn-outline-primary w-100"),
                           "Sets the threshold so no more than the caseload share of households is eligible."))
              ),
              tags$div(class = "small text-muted pb-2", textOutput(ns("thr_note")))
            ),
            # Advisory 2/2025: COs must document the rationale behind their
            # threshold bandwidth. It travels in the exported workbook.
            textAreaInput(ns("tol_rationale"),
                          "Rationale for the tolerance band and the threshold (goes into the export)",
                          placeholder = paste("e.g. Lower 15% / upper 25% agreed with the programme",
                                              "team given field access constraints; threshold set to",
                                              "fit a caseload of 40% of households."),
                          rows = 2, width = "100%"),
            tags$div(class = "small text-muted mb-2", textOutput(ns("eval_note"))),
            bslib::layout_columns(
              col_widths = c(3, 3, 3, 3), fill = FALSE, class = "wfp-kpi-flat",
              bslib::value_box(title = textOutput(ns("kpi_auc_title"), inline = TRUE),
                               value = textOutput(ns("kpi_auc")),
                               showcase = bsicons::bs_icon("graph-up"), theme = "primary"),
              bslib::value_box(title = "Eligible households", value = textOutput(ns("kpi_elig")),
                               showcase = bsicons::bs_icon("people"), theme = "info"),
              # The two error rates on a track with the tolerance band drawn in.
              uiOutput(ns("kpi_incl_gauge")),
              uiOutput(ns("kpi_excl_gauge"))
            ),
            bslib::layout_columns(
              col_widths = c(8, 4),
              bslib::card(
                bslib::card_header(
                  bsicons::bs_icon("grid-3x3"),
                  " Design error matrix"
                ),
                bslib::card_body(uiOutput(ns("error_matrix")))
              ),
              bslib::card(
                bslib::card_header(bsicons::bs_icon("clipboard-check"), " Verdict"),
                bslib::card_body(uiOutput(ns("verdict")))
              )
            ),
            bslib::layout_columns(
              col_widths = c(4, 4, 4),
              bslib::card(
                bslib::card_header("ROC curve"),
                plotly::plotlyOutput(ns("roc_plot"), height = "400px")
              ),
              bslib::card(
                bslib::card_header("Score distribution"),
                plotly::plotlyOutput(ns("score_plot"), height = "400px")
              ),
              bslib::card(
                bslib::card_header(bsicons::bs_icon("box"), " Score by vulnerability"),
                plotly::plotlyOutput(ns("box_plot"), height = "400px")
              )
            ),
            bslib::layout_columns(
              col_widths = c(4, 4, 4),
              bslib::card(
                bslib::card_header(
                  bsicons::bs_icon("bar-chart-steps"),
                  " What actually drives the score"
                ),
                plotly::plotlyOutput(ns("contribution_plot"), height = "480px")
              ),
              bslib::card(
                bslib::card_header(
                  bsicons::bs_icon("people"),
                  " Criteria met, eligible vs not"
                ),
                plotly::plotlyOutput(ns("met_plot"), height = "480px")
              ),
              bslib::card(
                bslib::card_header(bsicons::bs_icon("person-check"), " Coverage by criterion"),
                plotly::plotlyOutput(ns("coverage_plot"), height = "480px")
              )
            ),
            bslib::layout_columns(
              col_widths = c(6, 6),
              bslib::card(
                bslib::card_header("Quartiles"),
                DT::DTOutput(ns("quartiles"), fill = FALSE)
              ),
              bslib::card(
                bslib::card_header("Quintiles"),
                DT::DTOutput(ns("quintiles"), fill = FALSE)
              )
            ),
            uiOutput(ns("nav_threshold"))
          )
        )
      )
    )
  )
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
      assessment_df(as.data.frame(df))
      assessment_source(input$assessment_file$name)
      audit_add(modification_log, "Design", "Assessment data loaded",
                sprintf("%s (%s rows, %s columns)", input$assessment_file$name, nrow(df), ncol(df)))
      reset_build()
      go_step("outcome")
      showNotification(sprintf("Assessment data loaded: %s rows, %s columns.",
                               format(nrow(df), big.mark = ","), ncol(df)),
                       type = "message")
    })

    observeEvent(input$open_guide, showModal(design_guide_modal()))

    # Buttons that need an earlier step are frozen until it is done.
    observe({
      gate_button("run_fit", !is.null(assessment_df()) && !is.null(screened()),
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
                                     log = modification_log, phase = "Design")

    output$data_status <- renderUI({
      df <- assessment_df()
      if (is.null(df)) {
        return(tags$div(
          class = "small",
          bsicons::bs_icon("exclamation-circle", class = "text-warning"),
          tags$strong(" No assessment data yet."),
          tags$div(class = "text-muted mt-1",
                   "Load a needs-assessment extract above to start the design.")
        ))
      }
      tags$div(
        class = "small",
        bsicons::bs_icon("check-circle-fill", class = "text-success"),
        tags$strong(sprintf(" %s rows, %s columns",
                            format(nrow(df), big.mark = ","), ncol(df))),
        tags$div(class = "text-muted mt-1",
                 "Source: ", assessment_source() %||% "unknown")
      )
    })

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
    sc_inputs <- c("outcome_col", "outcome_pos", "criteria", "model_method", "model_scheme",
                   "holdout_pct", "split_seed", "model_weights", "run_benchmarks", "fit_criteria", "compare_models",
                   "stepwise_on", "stepwise_ic",
                   "corr_cutoff", "tol_lower", "tol_upper", "tol_rationale", "caseload_pct")

    workspace_register(workspace, "scorecard",
      snapshot = function() {
        if (is.null(assessment_df())) return(NULL)
        pts <- tryCatch(current_weights()[, c("weight", "verifiable", "validated")], error = function(e) NULL)
        list(data = assessment_all(), source = assessment_source(), calc = calc_vars(),
             inputs = lapply(stats::setNames(sc_inputs, sc_inputs), function(k) input[[k]]),
             screened = screened(), collinear = collinear(), analyst_dropped = analyst_dropped(),
             selection_set = selection_set(), selection_applied = selection_applied(),
             fitted = fitted(), split = split_state(), bench = bench(), effects = effects(),
             runs = runs(), current_run = current_run(), points = pts,
             threshold = input$threshold, step = input$steps, quick_screen = qs_result())
      },
      restore = function(s) {
        restoring(s)
        assessment_df(s$data); assessment_source(s$source)
        qs_result(s$quick_screen)
        if (!is.null(s$calc)) calc_vars(s$calc)
        screened(s$screened); collinear(s$collinear); analyst_dropped(s$analyst_dropped %||% character(0))
        selection_set(s$selection_set); selection_applied(isTRUE(s$selection_applied))
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
          updateSelectInput(session, "outcome_pos", choices = outcome_levels(s$data[[i$outcome_col]]),
                            selected = i$outcome_pos)
        }
        updateSelectInput(session, "model_method", selected = i$model_method)
        updateSelectInput(session, "model_scheme", selected = i$model_scheme)
        for (k in c("holdout_pct", "split_seed", "corr_cutoff", "tol_lower", "tol_upper", "caseload_pct")) {
          if (!is.null(i[[k]])) updateNumericInput(session, k, value = i[[k]])
        }
        if (!is.null(i$run_benchmarks)) updateCheckboxInput(session, "run_benchmarks", value = i$run_benchmarks)
        if (!is.null(i$compare_models)) shinyWidgets::updatePickerInput(session, "compare_models", selected = i$compare_models)
        if (!is.null(i$stepwise_on)) updateCheckboxInput(session, "stepwise_on", value = i$stepwise_on)
        if (!is.null(i$stepwise_ic)) updateRadioButtons(session, "stepwise_ic", selected = i$stepwise_ic)
        # A session from before stepwise became an option.
        if (identical(i$model_method, "stepwise")) {
          updateSelectInput(session, "model_method", selected = "logit")
          updateCheckboxInput(session, "stepwise_on", value = TRUE)
        }
        if (!is.null(i$tol_rationale)) updateTextAreaInput(session, "tol_rationale", value = i$tol_rationale)
        if (!is.null(s$threshold)) {
          thr_pending(s$threshold)
          updateSliderInput(session, "threshold", value = s$threshold)
        }
        if (!is.null(s$step)) go_step(s$step)
        # Safety net: never leave the rebuilds switched off.
        later::later(function() shiny::withReactiveDomain(session, restoring(NULL)), 10)
      })

    observe({
      s <- restoring(); req(s)
      i <- s$inputs
      back <- identical(input$outcome_col %||% "", i$outcome_col %||% "") &&
        identical(input$outcome_pos %||% "", i$outcome_pos %||% "") &&
        setequal(input$criteria %||% character(0), i$criteria %||% character(0)) &&
        identical(input$model_scheme %||% "", i$model_scheme %||% "")
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

    # The block that replaces a step whose prerequisite is not met.
    gate <- function(reason, btn_id, btn_label) {
      tags$div(
        class = "wfp-gate",
        bsicons::bs_icon("lock", class = "wfp-gate-icon"),
        tags$div(class = "wfp-gate-text", reason),
        actionButton(ns(btn_id), btn_label, icon = icon("arrow-left"),
                     class = "btn-outline-primary btn-sm mt-2")
      )
    }

    # Every step ends with the same footer: Back to the previous step, what
    # this step achieved (or what is missing), and Continue to the next one.
    step_nav <- function(back_id, back_label, ok, done_text, todo_text, next_id, next_label,
                         next_icon = "arrow-right") {
      tags$div(
        class = "wfp-stepnav",
        if (is.null(back_id)) tags$span() else
          actionButton(ns(back_id), back_label, icon = icon("arrow-left"), class = "btn-outline-secondary"),
        tags$div(
          class = "wfp-stepnav-status small",
          if (ok) tagList(bsicons::bs_icon("check-circle-fill", class = "text-success"), " ", done_text)
          else tagList(bsicons::bs_icon("info-circle", class = "text-muted"), tags$span(class = "text-muted", " ", todo_text))
        ),
        actionButton(ns(next_id), next_label, icon = icon(next_icon),
                     class = if (ok) "btn-primary" else "btn-outline-secondary disabled",
                     disabled = if (ok) NULL else NA)
      )
    }

    output$nav_outcome <- renderUI({
      ok <- !is.null(assessment_df()) && shiny::isTruthy(input$outcome_col)
      step_nav(NULL, NULL, ok,
               sprintf("Outcome set: %s = %s.", input$outcome_col %||% "", input$outcome_pos %||% ""),
               "Load assessment data above, then choose the outcome and the level that means vulnerable.",
               "nav_next_outcome", "Continue to criteria")
    })

    output$nav_criteria <- renderUI({
      n <- length(input$criteria %||% character(0))
      step_nav("nav_back_criteria", "Back to outcome", n > 0,
               sprintf("%d candidate criteria selected.", n),
               "Select the household characteristics that could make a household eligible.",
               "nav_next_criteria", "Continue to variable selection")
    })

    output$nav_screening <- renderUI({
      res <- screened()
      step_nav("nav_back_screening", "Back to criteria", isTRUE(selection_applied()),
               sprintf("%d variables kept for the model.", sum(res$retained %||% FALSE)),
               "Tick variables, click Select, review them, then use 'Drop ticked and continue'.",
               "nav_next_screening", "Continue to model & weights")
    })

    output$nav_weights <- renderUI({
      f <- fitted()
      step_nav("nav_back_weights", "Back to variable selection", !is.null(f),
               if (is.null(f)) "" else sprintf("Model fitted on %d criteria. Iterate above if needed.", nrow(f$weights)),
               "Fit the model first.",
               "nav_next_weights", "Continue to threshold & errors")
    })

    output$nav_threshold <- renderUI({
      todo <- missing_steps()
      if (adopted_current()) {
        return(tags$div(
          class = "wfp-stepnav",
          actionButton(ns("nav_back_threshold"), "Back to model & weights", icon = icon("arrow-left"), class = "btn-outline-secondary"),
          tags$div(class = "wfp-stepnav-status small",
                   bsicons::bs_icon("check-circle-fill", class = "text-success"),
                   sprintf(" Adopted %s. Any change to the design withdraws the adoption.", user_setup$scorecard$adopted_at %||% "")),
          tags$span(class = "wfp-adopted-pill", bsicons::bs_icon("patch-check-fill"), " Adopted")))
      }
      other <- !scorecard_is_empty(user_setup$scorecard)
      step_nav("nav_back_threshold", "Back to model & weights", !length(todo),
               if (other) "Another scorecard is in use. Adopting replaces it with this design."
               else "Check the errors and the verdict, record the rationale, then adopt.",
               paste0("Still to do: ", paste(todo, collapse = ", "), "."),
               "nav_adopt", "Adopt this scorecard", next_icon = "check")
    })

    observeEvent(input$nav_next_outcome, go_step("criteria"))
    observeEvent(input$nav_back_criteria, go_step("outcome"))
    observeEvent(input$nav_next_criteria, go_step("screening"))
    observeEvent(input$nav_back_screening, go_step("criteria"))
    observeEvent(input$nav_next_screening, go_step("weights"))
    observeEvent(input$nav_back_weights, go_step("screening"))
    observeEvent(input$nav_next_weights, go_step("threshold"))
    observeEvent(input$nav_back_threshold, go_step("weights"))

    output$gate_screening <- renderUI({
      if (length(input$criteria %||% character(0)) > 0) return(NULL)
      gate("Screening compares each candidate criterion against the outcome, so pick the candidates first.",
           "back_to_criteria", "Back to criteria")
    })

    output$gate_weights <- renderUI({
      if (!is.null(screened())) return(NULL)
      gate("Weights come from a model fitted on the selected variables, so select them first.",
           "back_to_screening", "Back to variable selection")
    })

    output$gate_threshold <- renderUI({
      if (!is.null(fitted())) return(NULL)
      gate("The threshold is chosen against the errors a scored design produces, so fit the weights first.",
           "back_to_weights", "Back to weights")
    })

    observeEvent(input$back_to_criteria, go_step("criteria"))
    observeEvent(input$back_to_screening, go_step("screening"))
    observeEvent(input$back_to_weights, go_step("weights"))

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
      updateSelectInput(session, "outcome_pos", choices = lv,
                        selected = if (isTRUE(pos %in% lv)) pos else guess_positive_level(lv))
    })

    outcome_binary <- reactive({
      df <- assessment_df()
      req(df, shiny::isTruthy(input$outcome_col), input$outcome_col %in% names(df))
      as_binary_outcome(df[[input$outcome_col]], input$outcome_pos)
    })

    output$outcome_summary <- renderUI({
      y <- tryCatch(outcome_binary(), error = function(e) NULL)
      if (is.null(y)) return(NULL)
      n <- sum(!is.na(y))
      k <- sum(y == 1, na.rm = TRUE)
      if (n == 0) {
        return(tags$div(class = "alert alert-danger",
                        "This outcome has no usable values."))
      }
      pct <- 100 * k / n
      tagList(
        bslib::layout_columns(
          col_widths = c(4, 4, 4), fill = FALSE,
          bslib::value_box(title = "Households with an outcome",
                           value = format(n, big.mark = ","),
                           showcase = bsicons::bs_icon("clipboard-data"), theme = "primary"),
          bslib::value_box(title = paste0("Vulnerable (", input$outcome_pos, ")"),
                           value = sprintf("%.1f%%", pct),
                           showcase = bsicons::bs_icon("exclamation-triangle"), theme = "danger"),
          bslib::value_box(title = "Not vulnerable",
                           value = sprintf("%.1f%%", 100 - pct),
                           showcase = bsicons::bs_icon("check-circle"), theme = "success")
        ),
        if (pct > 95 || pct < 5) {
          tags$div(
            class = "alert alert-warning",
            bsicons::bs_icon("exclamation-triangle"),
            sprintf(" Only %.1f%% of households fall on one side of this outcome. ", min(pct, 100 - pct)),
            "A scorecard built on such an unbalanced outcome will separate very little. ",
            "Check the level you selected is the one that means vulnerable."
          )
        }
      )
    })

    # -----------------------------------------------------------------------
    # Step 2: the candidate criteria
    # -----------------------------------------------------------------------

    blockers <- reactive({
      df <- assessment_df()
      req(df)
      criterion_blockers(df, names(df), input$outcome_col %||% "")
    })

    eligible_criteria <- reactive({
      setdiff(binary_cols(), names(blockers()))
    })

    observe({
      choices <- eligible_criteria()
      shinyWidgets::updatePickerInput(session, "criteria", choices = choices,
                                      selected = rs_in("criteria") %||% isolate(input$criteria))
    })

    output$blocked_note <- renderUI({
      b <- blockers()
      outcome_blocked <- b[vapply(b, function(x) grepl("Advisory 1/2025", x, fixed = TRUE), logical(1))]
      if (length(outcome_blocked) == 0) return(NULL)
      tags$div(
        class = "alert alert-info mt-2",
        tags$strong(bsicons::bs_icon("shield-exclamation"),
                    sprintf(" %d column(s) blocked as outcome indicators", length(outcome_blocked))),
        tags$p(class = "small mb-1 mt-2",
               "Outcome indicators reflect a household's current food consumption, which",
               " moves with the season and with assistance itself. Targeting on them is",
               " reactive rather than preventive, and they cannot then be used to validate",
               " the targeting."),
        tags$div(class = "small",
                 paste(utils::head(names(outcome_blocked), 20), collapse = ", "),
                 if (length(outcome_blocked) > 20) ", ...")
      )
    })

    # -----------------------------------------------------------------------
    # Step 3: screening
    # -----------------------------------------------------------------------

    # The candidate table is descriptive and rebuilt whenever the candidates,
    # the outcome or the data change. Every candidate starts ticked.
    observeEvent(list(input$criteria, input$outcome_col, input$outcome_pos, assessment_df()), {
      if (!is.null(isolate(restoring()))) return()
      df <- assessment_df()
      crit <- input$criteria
      y <- tryCatch(outcome_binary(), error = function(e) NULL)
      collinear(character(0)); analyst_dropped(character(0))
      selection_set(NULL); selection_applied(FALSE)
      if (is.null(df) || !length(crit) || is.null(y)) { screened(NULL); return() }
      prof <- criteria_profile(df, crit, y)
      prof$direction <- ifelse(prof$gap >= 0, "inclusion", "exclusion")
      prof$retained <- TRUE
      screened(prof)
      fitted(NULL)
    }, ignoreNULL = FALSE)

    selection_set <- reactiveVal(NULL)
    selection_applied <- reactiveVal(FALSE)
    analyst_dropped <- reactiveVal(character(0))

    observeEvent(input$select_vars, {
      res <- screened(); need_ok(!is.null(res), "Choose the outcome and the candidate criteria first.")
      use <- vapply(seq_len(nrow(res)), function(i) isTRUE(input[[paste0("sv_", i)]]), logical(1))
      if (!any(use)) {
        showNotification("Tick at least one variable in the Use column.", type = "warning")
        return()
      }
      selection_set(res$criterion[use])
    })

    # Profile + correlation of the chosen set, with the drops the collinearity
    # rule would make pre-ticked.
    selection_info <- reactive({
      chosen <- selection_set(); req(length(chosen))
      df <- assessment_df(); res <- screened(); y <- outcome_binary()
      cutoff <- input$corr_cutoff %||% 0.8
      prof <- criteria_profile(df, chosen, y)
      cm <- criteria_cor(df, chosen)
      a <- abs(cm); diag(a) <- NA
      if (length(chosen) > 1) {
        mx <- apply(a, 1, function(v) if (all(is.na(v))) NA_real_ else max(v, na.rm = TRUE))
        wi <- apply(a, 1, function(v) if (all(is.na(v))) NA_integer_ else which.max(v))
        prof$max_r <- unname(mx); prof$max_with <- chosen[wi]
      } else {
        prof$max_r <- NA_real_; prof$max_with <- NA_character_
      }
      sug <- drop_collinear(df, chosen, cutoff = cutoff)$dropped
      prof$suggest <- unname(sug[chosen])
      list(prof = prof, cm = cm, cutoff = cutoff, suggest = sug)
    })

    output$selection_ui <- renderUI({
      if (is.null(selection_set())) return(NULL)
      si <- selection_info()
      drop <- lapply(seq_len(nrow(si$prof)), function(i)
        checkboxInput(ns(paste0("dv_", i)), NULL, value = !is.na(si$prof$suggest[i])))
      tagList(
        tags$hr(),
        tags$div(class = "small fw-bold text-uppercase mb-2", bsicons::bs_icon("grid-3x3"),
                 sprintf(" Correlation between the %d selected variables", nrow(si$prof))),
        correlation_html(si$cm, si$cutoff),
        tags$div(class = "small fw-bold text-uppercase mt-4 mb-2", bsicons::bs_icon("table"),
                 " Descriptive statistics"),
        profile_html(si$prof, drop),
        tags$div(
          class = "d-flex justify-content-between align-items-center flex-wrap gap-2 mt-3",
          tags$div(class = "small text-muted",
                   if (length(si$suggest)) sprintf("%d variable(s) pre-ticked for dropping: they duplicate a stronger one above |r| = %.2f.",
                                                   length(si$suggest), si$cutoff)
                   else sprintf("No pair is correlated above |r| = %.2f.", si$cutoff),
                   " Tick or untick Drop as you see fit."),
          bslib::tooltip(
            actionButton(ns("apply_selection"), "Drop ticked and continue to the model",
                         icon = icon("arrow-right"), class = "btn-primary"),
            "Removes the variables ticked in the Drop column and opens step 4 with the rest.")
        )
      )
    })

    observeEvent(input$apply_selection, {
      si <- selection_info(); res <- screened(); need_ok(!is.null(si) && !is.null(res), "Tick the variables and click Select ticked variables first.")
      chosen <- si$prof$criterion
      drop <- chosen[vapply(seq_along(chosen), function(i) isTRUE(input[[paste0("dv_", i)]]), logical(1))]
      keep <- setdiff(chosen, drop)
      if (!length(keep)) {
        showNotification("That would drop every variable; keep at least one.", type = "warning")
        return()
      }
      res$retained <- res$criterion %in% keep
      auto <- intersect(drop, names(si$suggest))
      collinear(si$suggest[auto])
      analyst_dropped(setdiff(drop, auto))
      screened(res)
      selection_applied(TRUE)
      go_step("weights")
      showNotification(sprintf("%d variables kept for the model, %d dropped.", length(keep), length(drop)),
                       type = "message")
    })

    # Quick screening: a univariate test per candidate, summarised as two
    # lists rather than a table of statistics. It only informs the ticks.
    qs_result <- reactiveVal(NULL)
    observeEvent(input$quick_screen, {
      qs_result(NULL)
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("funnel"), " Quick screening"),
        size = "l", easyClose = TRUE,
        tags$p(class = "text-muted small",
               "Each candidate is tested on its own against the outcome. The result only helps you decide what to tick; nothing changes until you apply it."),
        tags$details(
          class = "wfp-qs-how small mb-3", open = NA,
          tags$summary(tags$strong("How the screening works")),
          tags$ol(
            class = "mt-2 mb-0",
            tags$li("For each candidate, a logistic regression of the outcome (vulnerable or not) on that one criterion is fitted, and a ",
                    tags$strong("likelihood-ratio test"), " checks whether knowing the criterion improves the prediction."),
            tags$li("If that model cannot be estimated (for example, no vulnerable household meets the criterion), ",
                    tags$strong("Fisher's exact test"), " on the 2\u00d72 table is used instead."),
            tags$li("Because many candidates are tested at once, the p-values are ", tags$strong("adjusted"),
                    " with the method chosen below, so chance findings are not counted as associations."),
            tags$li("A candidate is ", tags$strong("associated"), " when its adjusted p-value is below the significance level. ",
                    "The arrow gives its direction: more common (\u2191) or less common (\u2193) among vulnerable households."),
            tags$li("Each test looks at one criterion alone, not net of the others. Overlaps between criteria are checked with the correlation matrix after Select, and the model in step 4 estimates the net effects.")
          )
        ),
        bslib::layout_columns(
          col_widths = c(4, 5, 3), fill = FALSE,
          numericInput(ns("qs_alpha"),
                       tagList("Significance level", info_tip("A candidate counts as associated when its adjusted p-value is below this level. 0.05 is the usual choice.")),
                       value = 0.05, min = 0.001, max = 0.5, step = 0.005),
          selectInput(ns("qs_adjust"),
                      tagList("Multiplicity adjustment", info_tip(tip_body("Testing many candidates at once finds some by chance", list(
                        list(name = "Benjamini-Hochberg.", text = "Controls the share of false findings among those declared associated. Recommended.",
                             ref = "Benjamini & Hochberg (1995), JRSS B 57(1)."),
                        list(name = "Bonferroni / Holm.", text = "Control the chance of even one false finding: stricter, fewer associations.",
                             ref = "Holm (1979), Scandinavian Journal of Statistics 6(2)."),
                        list(name = "None.", text = "No correction; expect false findings when there are many candidates."))))),
                      choices = c("Benjamini-Hochberg" = "BH", "Bonferroni" = "bonferroni",
                                  "Holm" = "holm", "None" = "none"), selected = "BH"),
          tags$div(class = "wfp-inline-action",
                   tags$label(class = "form-label", "\u00a0"),
                   actionButton(ns("qs_run"), "Screen", icon = icon("play"), class = "btn-primary w-100"))
        ),
        uiOutput(ns("qs_out")),
        footer = tagList(
          modalButton("Close"),
          actionButton(ns("qs_apply"), "Tick only the associated ones", icon = icon("check-double"),
                       class = "btn-outline-primary")
        )
      ))
    })

    observeEvent(input$qs_run, {
      df <- assessment_df(); res <- screened(); need_ok(!is.null(df) && !is.null(res), "Load the assessment data and choose the outcome and criteria first.")
      r <- tryCatch(screen_criteria(df, input$outcome_col, res$criterion,
                                    alpha = input$qs_alpha %||% 0.05, adjust = input$qs_adjust %||% "BH",
                                    outcome_positive = input$outcome_pos),
                    error = function(e) { showNotification(paste("Screening failed:", conditionMessage(e)), type = "error"); NULL })
      qs_result(r)
    })

    output$qs_out <- renderUI({
      r <- qs_result()
      if (is.null(r)) return(NULL)
      res <- screened()
      m <- match(r$criterion, res$criterion)
      pv <- res$prev_vuln[m]; pn <- res$prev_not[m]
      yes <- sum(r$significant, na.rm = TRUE)
      verdict <- ifelse(r$test %in% c("constant", "not binary"),
                        ifelse(r$test == "constant", "Cannot be tested: every household answers the same",
                               "Cannot be tested: not a yes/no variable"),
                 ifelse(r$significant,
                        ifelse(r$direction == "inclusion", "Associated: points to vulnerability",
                               "Associated: points away from vulnerability"),
                        "No clear association on its own"))
      fmt_p <- function(p) ifelse(is.na(p), "\u2013", ifelse(p < 0.001, "< 0.001", sprintf("%.3f", p)))
      fmt_or <- function(o, lo, hi) ifelse(is.na(o), "\u2013", sprintf("%.2f (%.2f\u2013%.2f)", o, lo, hi))
      ord <- order(!r$significant, r$p_adj, na.last = TRUE)
      tagList(
        tags$hr(),
        tags$p(class = "small mb-2",
               tags$strong(sprintf("%d of %d candidates are associated with the outcome", yes, nrow(r))),
               sprintf(" at the %s level, after %s adjustment.", format(input$qs_alpha %||% 0.05),
                       c(BH = "Benjamini-Hochberg", bonferroni = "Bonferroni", holm = "Holm", none = "no")[[input$qs_adjust %||% "BH"]])),
        tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(tags$th("Criterion"), tags$th(class = "num", "Among vulnerable"), tags$th(class = "num", "Among others"),
                             tags$th(class = "num", "Odds ratio (95% CI)"), tags$th(class = "num", "Adjusted p"), tags$th("Verdict"))),
          tags$tbody(lapply(ord, function(i) tags$tr(
            class = if (isTRUE(r$significant[i])) NULL else "is-dropped",
            tags$td(tags$strong(r$criterion[i])),
            tags$td(class = "num", if (is.na(pv[i])) "\u2013" else sprintf("%.0f%%", 100 * pv[i])),
            tags$td(class = "num", if (is.na(pn[i])) "\u2013" else sprintf("%.0f%%", 100 * pn[i])),
            tags$td(class = "num", fmt_or(r$or[i], r$or_low[i], r$or_high[i])),
            tags$td(class = "num", fmt_p(r$p_adj[i])),
            tags$td(class = "small", verdict[i])))))),
        tags$ul(
          class = "small text-muted mt-2 mb-0",
          tags$li(tags$strong("Odds ratio"), ": how much more likely a household meeting the criterion is to be vulnerable. ",
                  "Above 1 points to vulnerability, below 1 away from it; a range crossing 1 means the direction is not certain."),
          tags$li(tags$strong("Adjusted p"), ": the chance of seeing such a gap if the criterion had nothing to do with vulnerability, ",
                  "corrected for testing many candidates. Below the significance level: associated."),
          tags$li("A criterion with no clear association alone can still matter next to others (and the reverse): ",
                  "keep the ones the field knowledge supports, and let the model in step 4 decide the net weights."))
      )
    })

    observeEvent(input$qs_apply, {
      r <- qs_result(); res <- screened()
      if (is.null(r)) { showNotification("Click Screen first.", type = "warning"); return() }
      sig <- r$criterion[r$significant]
      for (i in seq_len(nrow(res))) updateCheckboxInput(session, paste0("sv_", i), value = res$criterion[i] %in% sig)
      removeModal()
      showNotification(sprintf("%d associated candidates ticked. Click Select to review them.", length(sig)), type = "message")
    })

    output$screen_note <- renderUI({
      res <- screened()
      if (is.null(res)) {
        return(empty_state("No candidates yet",
                           "Choose an outcome and candidate criteria first.",
                           icon = "funnel"))
      }
      drops <- collinear()
      tagList(
        tags$div(
          class = "wfp-stat-strip mb-2",
          tags$span(tags$strong(nrow(res)), " candidates"),
          tags$span(tags$strong(sum(res$retained, na.rm = TRUE)), " kept"),
          tags$span(tags$strong(sum(res$direction == "inclusion" & res$retained, na.rm = TRUE)), " inclusion"),
          tags$span(tags$strong(sum(res$direction == "exclusion" & res$retained, na.rm = TRUE)), " exclusion")
        ),
        if (length(drops)) {
          tags$div(
            class = "alert alert-secondary small",
            tags$strong("Dropped as collinear: "),
            paste(sprintf("%s (duplicates %s)", names(drops), unname(drops)), collapse = "; "),
            tags$div(class = "mt-1",
                     "Two criteria saying the same thing would split one effect into two",
                     " weights and count it twice in the score.")
          )
        }
      )
    })

    output$screen_table <- renderUI({
      res <- screened()
      req(res)
      drops <- collinear()
      status <- ifelse(res$retained, "kept",
                ifelse(res$criterion %in% names(drops),
                       paste("dropped: duplicates", drops[res$criterion]), "dropped after review"))
      reading <- criterion_reading(res$prevalence, res$missing, res$prev_vuln, res$prev_not)
      rows <- lapply(seq_len(nrow(res)), function(i) tags$tr(
        class = if (isTRUE(res$retained[i])) NULL else "is-dropped",
        tags$td(checkboxInput(ns(paste0("sv_", i)), NULL, value = isTRUE(res$retained[i]))),
        tags$td(tags$strong(res$criterion[i])),
        tags$td(class = "num", sprintf("%.1f%%", 100 * res$prevalence[i])),
        tags$td(class = "num", sprintf("%.0f%%", 100 * res$prev_vuln[i])),
        tags$td(class = "num", sprintf("%.0f%%", 100 * res$prev_not[i])),
        tags$td(class = "num", sprintf("%.1f%%", 100 * res$missing[i])),
        tags$td(class = "small", reading[i]),
        tags$td(class = "small text-muted", status[i])))
      tagList(
        tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(tags$th(style = "width: 3rem;", "Use"), tags$th("Criterion"), tags$th(class = "num", "Prevalence"),
                             tags$th(class = "num", "Among vulnerable"), tags$th(class = "num", "Among others"),
                             tags$th(class = "num", "Missing"), tags$th(style = "min-width: 14rem;", "What it tells"), tags$th("Status"))),
          tags$tbody(rows))),
        tags$details(
          class = "wfp-qs-how small mt-2",
          tags$summary(tags$strong("How to read this table")),
          tags$ul(
            class = "mt-2 mb-0",
            tags$li(tags$strong("Prevalence"), ": share of all households meeting the criterion. Near 0% or 100%, it barely separates anyone."),
            tags$li(tags$strong("Among vulnerable / among others"), ": the same share within each outcome group. ",
                    "The wider the gap, the more the criterion points to vulnerability (more common among the vulnerable: an inclusion criterion; less common: an exclusion criterion)."),
            tags$li(tags$strong("Missing"), ": households with no answer. Above about 20%, check the question: missing answers score nothing."),
            tags$li("These are descriptive and one criterion at a time. Quick screening tests them statistically; ",
                    "Select ticked variables then shows how they overlap, and the model in step 4 gives each its net weight."))),
        tags$div(
          class = "d-flex justify-content-end gap-2 mt-3",
          bslib::tooltip(
            actionButton(ns("quick_screen"), "Quick screening", icon = icon("filter"),
                         class = "btn-outline-primary"),
            "Tests each candidate against the outcome and shows, in one glance, which are associated with it. Optional: nothing is dropped unless you tick accordingly."),
          bslib::tooltip(
            actionButton(ns("select_vars"), "Select ticked variables",
                         icon = icon("check-double"), class = "btn-primary"),
            "Shows the correlation matrix and descriptive statistics of the ticked variables, so you can decide which to drop.")
        )
      )
    })

    # -----------------------------------------------------------------------
    # Step 4: the model and the weights
    # -----------------------------------------------------------------------

    observeEvent(input$run_fit, {
      df <- assessment_df()
      res <- screened()
      need_ok(!is.null(df) && !is.null(res), "Load the assessment data, choose the outcome and the criteria, and select the variables first.")
      # The picker lets the model be iterated on a different set than the
      # screening retained; it starts from the retained set.
      keep <- input$fit_criteria %||% res$criterion[res$retained]
      if (length(keep) == 0) {
        showNotification("No criteria to model: tick at least one in the criteria list.", type = "error")
        return()
      }

      w <- waiter::Waiter$new(html = waiter_content("Fitting the model..."),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show(); on.exit(w$hide(), add = TRUE)

      y <- outcome_binary()
      sp <- split_train_test(y, holdout = (input$holdout_pct %||% 0) / 100,
                             seed = input$split_seed %||% 123)
      wcol <- input$model_weights
      wts_vec <- if (shiny::isTruthy(wcol) && wcol %in% names(df)) df[[wcol]] else NULL

      out <- tryCatch(
        fit_scorecard_advanced(df, input$outcome_col, keep,
                               outcome_positive = input$outcome_pos,
                               method = input$model_method %||% "logit",
                               stepwise = if (isTRUE(input$stepwise_on)) input$stepwise_ic %||% "aic" else "none",
                               scheme = input$model_scheme %||% "odds_ratio",
                               rows = sp$train, weights = wts_vec),
        error = function(e) {
          showNotification(paste("Model failed:", conditionMessage(e)),
                           type = "error", duration = 12)
          NULL
        }
      )
      req(out)
      split_state(sp)
      fitted(out)
      # Every additive model on the same rows, for the per-variable view.
      w$update(html = waiter_content("Comparing models per variable..."))
      effects(tryCatch(model_effects(df, input$outcome_col, keep, input$outcome_pos,
                                     rows = sp$train, weights = wts_vec,
                                     methods = unique(c(out$method, input$compare_models))),
                       error = function(e) NULL))
      saved_points(NULL); weight_bump(weight_bump() + 1)

      # Benchmarks use the same split, so every AUC in the comparison table is
      # measured on the same households.
      if (isTRUE(input$run_benchmarks)) {
        w$update(html = waiter_content("Fitting benchmark models..."))
        sc0 <- build_scorecard(out$weights)
        b <- tryCatch(
          benchmark_models(df, input$outcome_col, keep, input$outcome_pos, sp,
                           scorecard_score = apply_scorecard(df, sc0)$score,
                           seed = input$split_seed %||% 123),
          error = function(e) list(error = conditionMessage(e))
        )
        bench(b)
      } else {
        bench(NULL)
      }

      # Keep every fit so a worse iteration never loses a better one.
      yb <- outcome_binary()
      sc_score <- apply_scorecard(df, build_scorecard(out$weights))$score
      auc_rows <- if (length(sp$test)) sp$test else sp$train
      rl <- runs()
      rl[[length(rl) + 1]] <- list(
        id = length(rl) + 1, at = format(Sys.time(), "%H:%M:%S"),
        fit = out, split = sp, bench = bench(), criteria = keep, effects = effects(),
        settings = list(method = input$model_method, scheme = input$model_scheme,
                        stepwise = if (isTRUE(input$stepwise_on)) input$stepwise_ic %||% "aic" else "none",
                        holdout = input$holdout_pct, seed = input$split_seed),
        auc = roc_curve(sc_score[auc_rows], yb[auc_rows])$auc,
        held_out = length(sp$test) > 0
      )
      runs(rl)
      current_run(length(rl))
      audit_add(modification_log, "Design", "Model fitted",
                sprintf("Run #%d: %s, %s, %d criteria, AUC %.3f", length(rl),
                        names(scorecard_model_choices())[scorecard_model_choices() == out$method][1],
                        names(scorecard_scheme_choices())[scorecard_scheme_choices() == out$scheme][1],
                        nrow(out$weights), rl[[length(rl)]]$auc %||% NA_real_))
    })

    runs <- reactiveVal(list())
    effects <- reactiveVal(NULL)

    output$effects_ui <- renderUI({
      eff <- effects()
      if (is.null(fitted()) || is.null(eff)) return(NULL)
      b <- bench()
      bslib::card(
        class = "mt-3",
        bslib::card_header(bsicons::bs_icon("columns-gap"), " Each variable under every model"),
        bslib::card_body(effects_html(eff, if (is.list(b)) b$importance else NULL))
      )
    })

    output$effects_plot <- render_wfp_plotly({
      eff <- effects(); req(eff)
      d <- eff[!is.na(eff$effect), , drop = FALSE]
      req(nrow(d) > 0)
      ord <- stats::aggregate(effect ~ criterion, d, mean)
      d$criterion <- factor(d$criterion, levels = ord$criterion[order(ord$effect)])
      plotly::plot_ly(d, x = ~effect, y = ~criterion, color = ~model, type = "scatter", mode = "markers",
                      colors = c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44"),
                      marker = list(size = 11, opacity = 0.9),
                      hovertemplate = "%{y}<br>%{fullData.name}: %{x:+.2f}<extra></extra>") |>
        plotly::layout(
          xaxis = list(title = "Log-odds effect", zeroline = TRUE),
          yaxis = list(title = ""),
          margin = list(l = 170),
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom"),
          shapes = list(list(type = "line", x0 = 0, x1 = 0, y0 = 0, y1 = 1, yref = "paper",
                             line = list(color = "rgba(128,128,128,0.5)", dash = "dot")))
        )
    })
    current_run <- reactiveVal(NA_integer_)

    observeEvent(screened(), {
      res <- screened()
      shinyWidgets::updatePickerInput(session, "fit_criteria", choices = res$criterion,
                                      selected = rs_in("fit_criteria") %||% res$criterion[res$retained])
      if (!is.null(isolate(restoring()))) return()
      runs(list()); current_run(NA_integer_)
    })


    output$model_note <- renderText(paste(scorecard_model_note(input$model_method %||% "logit"),
                                          if (isTRUE(input$stepwise_on)) stepwise_note(input$stepwise_ic) else ""))

    output$runs_ui <- renderUI({
      rl <- runs()
      if (length(rl) < 1) return(NULL)
      best <- which.max(vapply(rl, function(r) r$auc %||% NA_real_, numeric(1)))
      rows <- lapply(rev(rl), function(r) {
        cur <- isTRUE(r$id == current_run())
        tags$tr(
          class = paste(if (cur) "is-current" else "", if (isTRUE(r$id == best)) "is-best" else ""),
          tags$td(tags$strong(paste0("#", r$id)), tags$span(class = "text-muted small ms-1", r$at)),
          tags$td(names(scorecard_model_choices())[scorecard_model_choices() == r$settings$method]),
          tags$td(names(scorecard_scheme_choices())[scorecard_scheme_choices() == r$settings$scheme]),
          tags$td(class = "num", nrow(r$fit$weights)),
          tags$td(class = "num", tags$strong(sprintf("%.3f", r$auc)),
                  tags$span(class = "text-muted small", if (r$held_out) " held out" else " training")),
          tags$td(if (cur) tags$span(class = "wfp-kept", bsicons::bs_icon("check2"), " shown")
                  else tags$button(type = "button", class = "btn btn-outline-primary btn-sm",
                                   onclick = sprintf("Shiny.setInputValue('%s', %d, {priority:'event'})",
                                                     ns("restore_run"), r$id),
                                   "Restore"))
        )
      })
      tags$details(
        class = "wfp-runs mt-2", open = NA,
        tags$summary(class = "small fw-bold text-uppercase",
                     sprintf("Run history (%d fit%s) \u2014 scorecard AUC; best highlighted",
                             length(rl), if (length(rl) == 1) "" else "s")),
        tags$div(class = "wfp-model-table-wrap mt-2", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(tags$th("Run"), tags$th("Model"), tags$th("Scheme"),
                             tags$th(class = "num", "Criteria"), tags$th(class = "num", "AUC"), tags$th(""))),
          tags$tbody(rows)))
      )
    })

    observeEvent(input$restore_run, {
      r <- runs()[[input$restore_run]]
      req(r)
      fitted(r$fit); split_state(r$split); bench(r$bench); effects(r$effects)
      current_run(r$id)
      updateSelectInput(session, "model_method", selected = if (identical(r$settings$method, "stepwise")) "logit" else r$settings$method)
      st <- r$settings$stepwise %||% if (identical(r$settings$method, "stepwise")) "aic" else "none"
      updateCheckboxInput(session, "stepwise_on", value = st %in% c("aic", "bic"))
      if (st %in% c("aic", "bic")) updateRadioButtons(session, "stepwise_ic", selected = st)
      freezeReactiveValue(input, "model_scheme")
      updateSelectInput(session, "model_scheme", selected = r$settings$scheme)
      updateNumericInput(session, "holdout_pct", value = r$settings$holdout)
      updateNumericInput(session, "split_seed", value = r$settings$seed)
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

    output$scheme_note <- renderText(scorecard_scheme_note(input$model_scheme %||% "odds_ratio"))

    # Changing the scheme after fitting re-derives the points from the same
    # coefficients; no refit needed.
    observeEvent(input$model_scheme, {
      if (!is.null(isolate(restoring()))) return()
      f <- fitted()
      req(f)
      f$weights$weight <- scorecard_weights(f$weights$coefficient, input$model_scheme)
      f$scheme <- input$model_scheme
      fitted(f)
      saved_points(NULL); weight_bump(weight_bump() + 1)
    }, ignoreInit = TRUE)

    output$fit_note <- renderUI({
      f <- fitted()
      if (is.null(f)) return(NULL)
      tagList(
        tags$span(
          class = "text-muted small",
          sprintf("%s, fitted on %s households%s; %d criteria kept.",
                  names(scorecard_model_choices())[scorecard_model_choices() == f$method],
                  format(f$n, big.mark = ","),
                  if (length(split_state()$test))
                    sprintf(", %s held out for evaluation", format(length(split_state()$test), big.mark = ","))
                  else "",
                  nrow(f$weights))
        ),
        if (length(f$dropped)) {
          tags$div(class = "small text-muted",
                   bsicons::bs_icon("scissors"),
                   " Removed by stepwise selection (no information once the others are known): ",
                   paste(f$dropped, collapse = ", "))
        },
        if (!f$converged) {
          tags$div(
            class = "alert alert-warning mt-2 mb-0",
            bsicons::bs_icon("exclamation-triangle"),
            tags$strong(" The model did not converge cleanly."),
            " Usually one criterion perfectly predicts the outcome (complete separation).",
            " Its weight is not trustworthy -- drop it in step 3 or set the weight by hand."
          )
        }
      )
    })

    # Weights are editable: the reference analysis overrides several from local
    # knowledge, and a scorecard nobody can correct is a scorecard nobody uses.
    output$weights_ui <- renderUI({
      weight_bump()
      f <- fitted()
      if (is.null(f)) {
        return(empty_state("No model yet", "Run the screening, then fit the model.",
                           icon = "calculator"))
      }
      wts <- f$weights
      idx <- seq_len(nrow(wts))
      sp <- isolate(saved_points())
      if (!is.null(sp) && nrow(sp) != nrow(wts)) sp <- NULL
      # One table: the model estimates, with the points and the review flags
      # editable in place.
      points <- lapply(idx, function(i) tags$div(
        class = "wfp-points-input",
        numericInput(ns(paste0("w_", i)), label = NULL,
                     value = if (is.null(sp)) wts$weight[i] else sp$weight[i],
                     min = 0, step = 0.01, width = "6rem")))
      tick <- function(id, i, col) if (!is.null(sp)) isTRUE(sp[[col]][i]) else isolate(input[[id]]) %||% FALSE
      review <- lapply(idx, function(i) tags$div(
        class = "wfp-review-checks",
        checkboxInput(ns(paste0("ver_", i)), "Verifiable", value = tick(paste0("ver_", i), i, "verifiable")),
        checkboxInput(ns(paste0("val_", i)), "Community-validated", value = tick(paste0("val_", i), i, "validated"))))
      tagList(
        tags$div(class = "d-flex justify-content-between align-items-center mb-2 gap-2",
                 tags$span(class = "small fw-bold text-uppercase", bsicons::bs_icon("table"), " Model estimates"),
                 tags$div(class = "d-flex gap-2",
                          actionButton(ns("reset_weights"), "Reset to model values",
                                       icon = icon("rotate-left"), class = "btn-outline-secondary btn-sm"),
                          downloadButton(ns("dl_model_tables2"), "Export (Excel)",
                                         class = "btn-outline-primary btn-sm"))),
        coefficients_html(wts, f$model, points = points, review = review),
        tags$div(
          class = "small text-muted mt-2",
          bsicons::bs_icon("info-circle"),
          " Targeting Advisory 1/2025: criteria must be observable and verifiable, and",
          " validated through community consultation before implementation. Tick them as",
          " that is done; the export records which have not been."
        )
      )
    })

    observeEvent(input$reset_weights, {
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
      wts$weight <- vapply(seq_len(nrow(wts)), function(i) {
        v <- input[[paste0("w_", i)]]
        if (!is.null(v) && !is.na(v)) as.numeric(v) else if (!is.null(sp)) sp$weight[i] else wts$weight[i]
      }, numeric(1))
      flag <- function(id, col) vapply(seq_len(nrow(wts)), function(i) {
        v <- input[[paste0(id, i)]]
        if (is.null(v)) isTRUE(sp[[col]][i]) else isTRUE(v)
      }, logical(1))
      wts$verifiable <- flag("ver_", "verifiable")
      wts$validated <- flag("val_", "validated")
      wts
    })

    # Criteria charts. The weights table answers "what is in the card"; these
    # answer "which criteria are doing the work", which is the question a
    # targeting officer actually has when deciding what to keep.
    output$weights_charts <- renderUI({
      if (is.null(fitted())) return(NULL)
      tagList(
        tags$hr(),
        bslib::layout_columns(
          col_widths = c(4, 4, 4),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("arrow-left-right"),
                               " Weight and direction"),
            plotly::plotlyOutput(ns("weights_plot"), height = "480px")
          ),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("percent"),
                               " How common each criterion is"),
            plotly::plotlyOutput(ns("prevalence_plot"), height = "480px")
          ),
          # Is each weight robust to the method? Same criterion, four models.
          bslib::card(
            bslib::card_header(bsicons::bs_icon("bullseye"),
                               " Effect by model"),
            plotly::plotlyOutput(ns("effects_plot"), height = "480px")
          )
        )
      )
    })


    # Weights as a diverging bar: inclusion to the right, exclusion to the
    # left, so the shape of the card is legible at a glance.
    output$weights_plot <- render_wfp_plotly({
      wts <- current_weights()
      req(nrow(wts) > 0)
      d <- data.frame(
        criterion = wts$criterion,
        signed = ifelse(wts$direction == "exclusion", -wts$weight, wts$weight),
        direction = wts$direction,
        or = wts$odds_ratio,
        stringsAsFactors = FALSE
      )
      d <- d[order(d$signed), , drop = FALSE]
      d$criterion <- factor(d$criterion, levels = d$criterion)

      plotly::plot_ly(
        d, x = ~signed, y = ~criterion, type = "bar", orientation = "h",
        color = ~direction,
        colors = c(inclusion = "#0A6EB4", exclusion = "#c5192d"),
        hovertemplate = ~paste0(criterion, "<br>", direction,
                                "<br>weight %{customdata:.2f} (OR ", sprintf("%.2f", or),
                                ")<extra></extra>"),
        customdata = ~abs(signed)
      ) |>
        plotly::layout(
          xaxis = list(title = "Points (+ / -)", zeroline = TRUE),
          yaxis = list(title = ""),
          margin = list(l = 180),
          showlegend = TRUE,
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom")
        )
    })

    # Prevalence split by the outcome: a criterion that is equally common in
    # both groups adds points without separating anyone.
    output$prevalence_plot <- render_wfp_plotly({
      wts <- current_weights()
      df <- assessment_df()
      y <- outcome_binary()
      req(nrow(wts) > 0, !is.null(df), length(y) == nrow(df))

      rows <- lapply(seq_len(nrow(wts)), function(i) {
        cl <- wts$criterion[i]
        x <- as_binary_criterion(df[[cl]])
        if (is.null(x)) return(NULL)
        ok <- !is.na(x) & !is.na(y)
        data.frame(
          criterion = cl,
          group = c("Vulnerable", "Not vulnerable"),
          pct = c(100 * mean(x[ok & y == 1] == 1), 100 * mean(x[ok & y == 0] == 1)),
          stringsAsFactors = FALSE
        )
      })
      d <- do.call(rbind, rows)
      req(!is.null(d), nrow(d) > 0)

      # Order by the gap: the widest separators first.
      gap <- stats::setNames(
        vapply(split(d, d$criterion), function(g) abs(diff(g$pct)), numeric(1)),
        names(split(d, d$criterion))
      )
      d$criterion <- factor(d$criterion, levels = names(sort(gap)))

      plotly::plot_ly(
        d, x = ~pct, y = ~criterion, type = "bar", orientation = "h",
        color = ~group,
        colors = c("Vulnerable" = "#c5192d", "Not vulnerable" = "#3f7e44"),
        hovertemplate = "%{y}<br>%{fullData.name}: %{x:.1f}%<extra></extra>"
      ) |>
        plotly::layout(
          barmode = "group",
          xaxis = list(title = "% households meeting it"),
          yaxis = list(title = ""),
          margin = list(l = 180),
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom")
        )
    })

    # Model comparison. The benchmarks cannot be written down as a scorecard;
    # they are here to show how much predictive power the additive card gives
    # up, measured on the same held-out households.
    output$comparison_ui <- renderUI({
      if (is.null(fitted())) return(NULL)
      b <- bench()
      why <- if (is.null(b)) "Tick \u201cCompare with random forest and gradient boosting\u201d above and fit again."
             else if (!is.null(b$error)) paste("The benchmark models could not be fitted:", b$error)
             else if (nrow(b$table) == 0) "No benchmark model could be fitted on these data."
      if (!is.null(why)) {
        return(tagList(tags$hr(), bslib::card(
          bslib::card_header(bsicons::bs_icon("trophy"), " Model comparison"),
          empty_state("No comparison yet", why, icon = "trophy"))))
      }
      tagList(
        tags$hr(),
        bslib::layout_columns(
          col_widths = c(5, 7),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("trophy"), " Model comparison"),
            uiOutput(ns("comparison_table")),
            tags$div(class = "small text-muted p-2",
                     "AUC on the held-out households is the honest figure. If the benchmarks",
                     " barely beat the logistic model, more complex models are not needed; the",
                     " gap between the logistic model and the scorecard is then the price of the",
                     " weighting scheme and of flooring scores at zero.")
          ),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("graph-up"), " ROC, held-out households"),
            plotly::plotlyOutput(ns("comparison_roc"), height = "340px")
          )
        )
      )
    })

    # The benchmarks are fixed once fitted, but the scorecard row follows the
    # weights as they are edited and the scheme as it is switched, so the cost
    # of each choice is visible straight away.
    live_bench <- reactive({
      b <- bench(); req(b, nrow(b$table) > 0)
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

    output$comparison_table <- renderUI(comparison_html(live_bench()$table))

    model_tables_dl <- download_handler(
      filename = function() paste0("Scorecard_model_tables_", format(Sys.time(), "%Y-%m-%d_%Hh%M"), ".xlsx"),
      content = function(file) {
        f <- fitted()
        b <- tryCatch(live_bench(), error = function(e) NULL)
        wts <- if (is.null(f)) NULL else tryCatch(current_weights(), error = function(e) f$weights)
        save_workbook_readonly(model_tables_workbook(NULL, wts, if (is.null(b)) NULL else b$table), file)
      }
    )
    output$dl_model_tables <- model_tables_dl
    output$dl_model_tables2 <- model_tables_dl

    output$comparison_roc <- render_wfp_plotly({
      b <- live_bench(); req(length(b$roc) > 0)
      pal <- c("#0A6EB4", "#26bde2", "#3f7e44", "#f7b825", "#c5192d")
      p <- plotly::plot_ly() |>
        plotly::add_lines(x = c(0, 1), y = c(0, 1), name = "Random",
                          line = list(dash = "dash", color = "#9aa5b1"), hoverinfo = "skip")
      i <- 0
      for (nm in names(b$roc)) {
        i <- i + 1
        cur <- b$roc[[nm]]
        if (is.null(cur) || nrow(cur) == 0) next
        p <- plotly::add_lines(p, data = cur, x = ~fpr, y = ~tpr, name = nm,
                               line = list(color = pal[(i - 1) %% length(pal) + 1],
                                           width = if (i == 1) 3 else 2))
      }
      plotly::layout(p,
                     xaxis = list(title = "False positive rate", range = c(0, 1)),
                     yaxis = list(title = "Recall", range = c(0, 1)),
                     legend = list(orientation = "h", y = -0.2))
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
      filename = function() paste0("Targeting_design_report_", format(Sys.time(), "%Y-%m-%d_%Hh%M"), ".html"),
      content = function(file) {
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
        lower <- (input$tol_lower %||% 5) / 100
        upper <- (input$tol_upper %||% 20) / 100
        rl <- runs()
        runs_df <- if (length(rl)) data.frame(
          Run = vapply(rl, function(x) paste0("#", x$id, if (isTRUE(x$id == current_run()))
            (if (adopted_current()) " (current, adopted)" else " (current)") else ""), character(1)),
          Model = vapply(rl, function(x) names(scorecard_model_choices())[scorecard_model_choices() == x$settings$method][1], character(1)),
          Scheme = vapply(rl, function(x) names(scorecard_scheme_choices())[scorecard_scheme_choices() == x$settings$scheme][1], character(1)),
          Criteria = vapply(rl, function(x) nrow(x$fit$weights), integer(1)),
          AUC = vapply(rl, function(x) x$auc %||% NA_real_, numeric(1)),
          stringsAsFactors = FALSE) else NULL
        fit_stats <- if (!is.null(f) && inherits(f$model, "glm")) sprintf(
          "AIC %.1f, McFadden pseudo-R2 %.3f", stats::AIC(f$model), 1 - f$model$deviance / f$model$null.deviance)
        bl <- safe(blockers())
        x <- list(
          generated = format(Sys.time(), "%Y-%m-%d %H:%M"),
          source = assessment_source(), n_rows = if (is.null(df)) NA else nrow(df),
          areas = scope$text(),
          n_cols = if (is.null(df)) NA else ncol(df),
          calc_vars = calc_vars(),
          outcome = input$outcome_col, outcome_pos = input$outcome_pos,
          n_outcome = sum(!is.na(y)), n_vuln = sum(y == 1, na.rm = TRUE),
          prevalence = if (is.null(y)) NA else mean(y == 1, na.rm = TRUE),
          candidates = input$criteria,
          blocked = if (is.null(bl)) NULL else unlist(bl[setdiff(names(bl), input$outcome_col)]),
          screening = screened(), collinear = collinear(),
          quick_screen = if (is.null(qs_result())) NULL else
            list(alpha = input$qs_alpha %||% 0.05, adjust = input$qs_adjust %||% "BH"),
          screen_settings = list(alpha = input$alpha, adjust = input$adjust, corr = input$corr_cutoff),
          model = if (is.null(f)) NULL else list(
            method = names(scorecard_model_choices())[scorecard_model_choices() == f$method][1],
            scheme = names(scorecard_scheme_choices())[scorecard_scheme_choices() == f$scheme][1],
            method_code = f$method, scheme_code = f$scheme, stepwise = f$stepwise %||% "none",
            n_train = f$n, n_test = length(sp$test), seed = input$split_seed,
            weights = input$model_weights, dropped = f$dropped, converged = f$converged,
            fit_stats = fit_stats),
          runs = runs_df, estimates = wts,
          comparison = safe(live_bench()$table),
          threshold = input$threshold, threshold_note = thr_msg(),
          tolerance = c(lower, upper), rationale = input$tol_rationale,
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
          threshold = input$threshold)
        # Every chart of the design page, as static figures.
        kept <- if (is.null(screened())) character(0) else screened()$criterion[screened()$retained]
        b <- safe(live_bench())
        dirs <- if (is.null(wts)) NULL else stats::setNames(wts$direction, wts$criterion)
        plots <- c(plots, design_report_extra_plots(
          df = df, criteria = kept, vulnerable = if (is.null(y)) NULL else y == 1,
          model_rocs = if (is.null(b)) NULL else b$roc,
          score = if (!is.null(s) && !is.null(r)) s$score[r],
          threshold = input$threshold,
          detail = if (is.null(s)) NULL else s$detail,
          eligible = if (is.null(s)) NULL else s$eligible,
          directions = dirs, lang = report_lang()))
        if (!is.null(s) && !is.null(r)) {
          # the boxplot compares groups on the evaluation households
          plots$box <- design_report_extra_plots(score = s$score[r], vulnerable = y[r] == 1,
                                                 threshold = input$threshold, lang = report_lang())$box
        }
        write_design_report(file, x, plots, lang = report_lang())
      }
    )

    output$kpi_auc_title <- renderText({
      sp <- split_state()
      if (!is.null(sp) && length(sp$test)) "AUC (held out)" else "AUC (in sample)"
    })

    draft_scorecard <- reactive({
      wts <- current_weights()
      build_scorecard(wts, outcome = input$outcome_col,
                      outcome_positive = input$outcome_pos,
                      threshold = input$threshold %||% thr_pending() %||% 0)
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

    output$threshold_ui <- renderUI({
      s <- tryCatch(scored(), error = function(e) NULL)
      max_score <- if (is.null(s) || !length(s$score)) 10 else max(s$score, na.rm = TRUE)
      sliderInput(ns("threshold"),
                  tagList("Eligible when score is above", info_tip("Households scoring strictly above this value are eligible. Moving it trades inclusion error against exclusion error.")),
                  min = 0, max = round(max_score, 5),
                  value = isolate(thr_pending() %||% input$threshold) %||% 0,
                  step = 0.00001, width = "100%")
    })

    # A new fit starts from the threshold that keeps both errors lowest,
    # rather than from 0 (everyone with any point eligible).
    thr_pending <- reactiveVal(NULL)
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
      updateSliderInput(session, "threshold", value = t)
      if (announce) thr_msg(sprintf(
        "Suggested threshold %s keeps both errors as low as possible together: inclusion %.1f%%, exclusion %.1f%% (the larger of the two is minimised).",
        fmt5(t), 100 * b$inclusion_error, 100 * b$exclusion_error))
    }
    observeEvent(fitted(), if (is.null(isolate(restoring()))) apply_balanced(), ignoreNULL = TRUE)
    observeEvent(input$thr_balanced, apply_balanced())
    observeEvent(input$threshold, {
      if (isTRUE(all.equal(input$threshold, thr_pending()))) thr_pending(NULL)
    })

    errors <- reactive({
      s <- scored()
      y <- outcome_binary()
      req(length(s$score) == length(y))
      r <- eval_rows()
      design_errors(s$score[r] > (input$threshold %||% 0), y[r] == 1)
    })

    # Threshold helpers (Advisory 3/2025). Both only move the slider.
    thr_msg <- reactiveVal("")
    output$thr_note <- renderText(thr_msg())

    observeEvent(input$thr_youden, {
      r <- roc()
      need_ok(is.finite(r$youden), "Fit a model first: the Youden point comes from its ROC curve.")
      t <- max(0, r$youden)
      updateSliderInput(session, "threshold", value = round(t, 5))
      thr_msg(sprintf("Youden's J cut-point: score > %s (maximises recall minus false-positive rate).", fmt5(t)))
    })

    observeEvent(input$thr_caseload, {
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
      updateSliderInput(session, "threshold", value = round(max(0, t), 5))
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
    error_gauge <- function(which) {
      e <- errors(); req(e$n > 0)
      lower <- (input$tol_lower %||% 5) / 100
      upper <- (input$tol_upper %||% 20) / 100
      num <- function(x) format(round(x), big.mark = ",")
      # Error rate on a 0-50% track with the tolerance band drawn in: green
      # up to the lower bound, amber to the upper, red beyond.
      gauge <- function(label, value, numer, denom, kind, meaning) {
        v <- if (is.na(value)) NA_real_ else value
        band <- if (is.na(v)) "na" else if (v <= lower) "good" else if (v <= upper) "review" else "bad"
        pos <- function(x) sprintf("%.1f%%", 100 * min(max(x, 0), 0.5) / 0.5)
        tags$div(
          class = paste("wfp-cm-gauge", kind),
          tags$div(class = "wfp-cm-gauge-head",
                   tags$span(class = "wfp-cm-gauge-title", label),
                   tags$span(class = paste("wfp-cm-gauge-value", band),
                             if (is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v))),
          tags$div(
            class = "wfp-cm-track",
            tags$span(class = "wfp-cm-zone good", style = sprintf("width:%s", pos(lower))),
            tags$span(class = "wfp-cm-zone review",
                      style = sprintf("left:%s;width:%s", pos(lower),
                                      sprintf("%.1f%%", 100 * (min(upper, .5) - min(lower, .5)) / 0.5))),
            if (!is.na(v)) tags$span(class = "wfp-cm-marker", style = sprintf("left:%s", pos(v)),
                                     `data-label` = "you are here")
          ),
          tags$div(class = "wfp-cm-gauge-foot",
                   sprintf("%s / %s \u2014 %s", num(numer), num(denom), meaning))
        )
      }

      n_elig <- e$correctly_included + e$included_not_in_need
      n_vuln <- e$correctly_included + e$excluded_in_need
      if (which == "incl") {
        gauge("Inclusion error", e$inclusion_error, e$included_not_in_need, n_elig, "err-incl",
              "selected but not in need")
      } else {
        gauge("Exclusion error", e$exclusion_error, e$excluded_in_need, n_vuln, "err-excl",
              "in need but not selected")
      }
    }
    output$kpi_incl_gauge <- renderUI(tagAppendAttributes(error_gauge("incl"), class = "is-kpi"))
    output$kpi_excl_gauge <- renderUI(tagAppendAttributes(error_gauge("excl"), class = "is-kpi"))

    output$kpi_incl <- renderText({
      e <- errors()
      if (is.na(e$inclusion_error)) "n/a" else sprintf("%.1f%%", 100 * e$inclusion_error)
    })
    output$kpi_excl <- renderText({
      e <- errors()
      if (is.na(e$exclusion_error)) "n/a" else sprintf("%.1f%%", 100 * e$exclusion_error)
    })

    # The contingency table from Targeting Advisory 2/2025, with this design's
    # own counts in it. Showing the two error rates without the table they come
    # from hides which cell is driving them -- a 37% inclusion error reads very
    # differently on a caseload of 80 than on a caseload of 8,000.
    output$error_matrix <- renderUI({
      e <- errors()
      req(e$n > 0)

      n_elig   <- e$correctly_included + e$included_not_in_need
      n_not    <- e$excluded_in_need + e$correctly_excluded
      n_vuln   <- e$correctly_included + e$excluded_in_need
      n_novuln <- e$included_not_in_need + e$correctly_excluded
      num <- function(x) format(round(x), big.mark = ",")
      pct <- function(x, d) if (is.na(d) || d == 0) "-" else sprintf("%.1f%%", 100 * x / d)
      lower <- (input$tol_lower %||% 5) / 100
      upper <- (input$tol_upper %||% 20) / 100

      cell <- function(count, row_total, label, kind, icon_name) {
        tags$td(
          class = paste("wfp-cm-cell", kind),
          tags$div(class = "wfp-cm-label", bsicons::bs_icon(icon_name), " ", label),
          tags$div(class = "wfp-cm-count", num(count)),
          tags$div(class = "wfp-cm-share",
                   tags$span(pct(count, row_total), " of row"),
                   tags$span(pct(count, e$n), " of all"))
        )
      }

      tagList(
        tags$div(
          class = "wfp-cm-wrap",
          tags$table(
            class = "wfp-matrix wfp-cm",
            tags$thead(
              tags$tr(
                tags$th(class = "wfp-cm-corner", colspan = 2, rowspan = 2,
                        tags$div(class = "wfp-cm-axis", "Scorecard decision \u2193"),
                        tags$div(class = "wfp-cm-axis", "Assessment outcome \u2192")),
                tags$th(class = "wfp-cm-group", colspan = 2,
                        "Outcome: ", tags$strong(input$outcome_col %||% "")),
                tags$th(class = "wfp-cm-tot-head", rowspan = 2, "Total")
              ),
              tags$tr(
                tags$th(class = "wfp-cm-col", "Vulnerable",
                        tags$div(class = "wfp-cm-sub", input$outcome_pos %||% "")),
                tags$th(class = "wfp-cm-col", "Not vulnerable")
              )
            ),
            tags$tbody(
              tags$tr(
                tags$th(class = "wfp-cm-rowgroup", rowspan = 2, tags$span("Scorecard")),
                tags$th(class = "wfp-cm-row", "Eligible",
                        tags$div(class = "wfp-cm-sub", sprintf("score > %s", fmt5(input$threshold %||% 0)))),
                cell(e$correctly_included, n_elig, "Correctly included", "ok", "check-circle-fill"),
                cell(e$included_not_in_need, n_elig, "Inclusion error", "err-incl", "x-circle-fill"),
                tags$td(class = "wfp-cm-tot", num(n_elig), tags$div(class = "wfp-cm-sub", pct(n_elig, e$n)))
              ),
              tags$tr(
                tags$th(class = "wfp-cm-row", "Not eligible"),
                cell(e$excluded_in_need, n_not, "Exclusion error", "err-excl", "exclamation-circle-fill"),
                cell(e$correctly_excluded, n_not, "Correctly excluded", "ok", "check-circle-fill"),
                tags$td(class = "wfp-cm-tot", num(n_not), tags$div(class = "wfp-cm-sub", pct(n_not, e$n)))
              ),
              tags$tr(
                class = "wfp-matrix-totals-row",
                tags$th(class = "wfp-cm-row wfp-cm-tot-label", colspan = 2, "Total"),
                tags$td(class = "wfp-cm-tot", num(n_vuln), tags$div(class = "wfp-cm-sub", pct(n_vuln, e$n))),
                tags$td(class = "wfp-cm-tot", num(n_novuln), tags$div(class = "wfp-cm-sub", pct(n_novuln, e$n))),
                tags$td(class = "wfp-cm-tot wfp-cm-grand", num(e$n))
              )
            )
          )
        ),
        tags$div(
          class = "small text-muted mt-2",
          "Valid for direct household-level assistance (Tier 1) only. In emergencies the OGN ",
          "gives priority to reducing exclusion errors; inclusion errors are more acceptable."
        )
      )
    })

    output$verdict <- renderUI({
      e <- errors()
      lower <- (input$tol_lower %||% 5) / 100
      upper <- (input$tol_upper %||% 20) / 100
      v <- tryCatch(error_verdict(e$inclusion_error, e$exclusion_error, lower, upper),
                    error = function(err) list(level = "invalid",
                                               interpretation = conditionMessage(err),
                                               action = "Lower the upper tolerance below 50%."))
      # Replay the animation only when the verdict changes, not on every
      # nudge of the threshold.
      animate <- !identical(v$level, verdict_seen)
      verdict_seen <<- v$level
      verdict_card(v, animate = animate,
        tags$div(class = "small mt-2 text-muted",
                 sprintf("Judged against a tolerance band of %.0f%%-%.0f%%. ",
                         100 * lower, 100 * upper),
                 "Targeting Advisory 2/2025 observes design errors of 5-20% across country offices."))
    })
    verdict_seen <- NULL

    output$roc_plot <- render_wfp_plotly({
      r <- roc()
      req(nrow(r$curve) > 0)
      cur <- r$curve
      t_now <- input$threshold %||% 0
      here <- cur[which.min(abs(cur$threshold - t_now)), , drop = FALSE]

      plotly::plot_ly() |>
        plotly::add_lines(x = c(0, 1), y = c(0, 1), line = list(dash = "dash", color = "#9aa5b1"),
                          name = "Random", hoverinfo = "skip") |>
        plotly::add_lines(data = cur, x = ~fpr, y = ~tpr, name = "Scorecard",
                          line = list(color = "#0A6EB4", width = 3),
                          hovertemplate = ~paste0(
                            "Threshold > %{customdata:.2f}<br>",
                            "Recall %{y:.1%}<br>False positive rate %{x:.1%}<extra></extra>"),
                          customdata = ~threshold) |>
        plotly::add_markers(data = here, x = ~fpr, y = ~tpr, name = "Chosen threshold",
                            marker = list(color = "#c5192d", size = 12),
                            hovertemplate = "Chosen threshold<extra></extra>") |>
        plotly::layout(
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom"),
          xaxis = list(title = "False positive rate (1 - specificity)", range = c(0, 1)),
          yaxis = list(title = "Recall (sensitivity)", range = c(0, 1)),
          annotations = list(list(
            x = 0.95, y = 0.05, xref = "paper", yref = "paper",
            text = sprintf("AUC = %.3f", r$auc), showarrow = FALSE,
            xanchor = "right", font = list(size = 13)
          ))
        )
    })

    output$score_plot <- render_wfp_plotly({
      s <- scored()
      y <- outcome_binary()
      req(length(s$score) == length(y))
      d <- data.frame(score = s$score,
                      group = ifelse(y == 1, "Vulnerable", "Not vulnerable"),
                      stringsAsFactors = FALSE)
      d <- d[!is.na(d$group), , drop = FALSE]
      plotly::plot_ly(d, x = ~score, color = ~group, type = "histogram",
                      colors = c("Vulnerable" = "#c5192d", "Not vulnerable" = "#3f7e44"),
                      opacity = 0.75) |>
        plotly::layout(
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom"),
          barmode = "overlay",
          xaxis = list(title = "Scorecard score"),
          yaxis = list(title = "Households"),
          shapes = list(list(type = "line", x0 = input$threshold %||% 0,
                             x1 = input$threshold %||% 0, y0 = 0, y1 = 1,
                             yref = "paper", line = list(color = "#1f2a37", dash = "dash")))
        )
    })

    # Weight times prevalence: the points a criterion actually contributes
    # across the caseload. A heavy weight on a rare criterion moves almost
    # nobody, which the weights table alone does not show.
    output$contribution_plot <- render_wfp_plotly({
      s <- scored()
      req(ncol(s$detail) > 0)
      d <- data.frame(
        criterion = names(s$detail),
        total = vapply(s$detail, function(v) sum(abs(v), na.rm = TRUE), numeric(1)),
        stringsAsFactors = FALSE
      )
      d$share <- 100 * d$total / max(sum(d$total), 1e-9)
      dir <- stats::setNames(
        vapply(draft_scorecard()$items, function(i) i$direction, character(1)),
        vapply(draft_scorecard()$items, function(i) i$criterion, character(1))
      )
      d$direction <- unname(dir[d$criterion])
      d <- d[order(d$share), , drop = FALSE]
      d$criterion <- factor(d$criterion, levels = d$criterion)

      plotly::plot_ly(
        d, x = ~share, y = ~criterion, type = "bar", orientation = "h",
        color = ~direction,
        colors = c(inclusion = "#0A6EB4", exclusion = "#c5192d"),
        hovertemplate = "%{y}<br>%{x:.1f}% of all points moved<extra></extra>"
      ) |>
        plotly::layout(
          xaxis = list(title = "Share of points (%)"),
          yaxis = list(title = ""),
          margin = list(l = 180),
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom")
        )
    })

    # How many criteria a household meets, eligible against not: if the two
    # distributions overlap heavily the threshold is doing little work.
    # Score by outcome as boxplots, threshold drawn across: how far apart the
    # two groups sit, and how much of each falls on the wrong side.
    output$box_plot <- render_wfp_plotly({
      s <- scored(); y <- outcome_binary()
      req(length(s$score) == length(y))
      d <- data.frame(score = s$score, group = ifelse(y == 1, "Vulnerable", "Not vulnerable"))
      d <- d[!is.na(d$group), , drop = FALSE]
      t <- input$threshold %||% 0
      plotly::plot_ly(d, y = ~score, x = ~group, color = ~group, type = "box",
                      colors = c("Vulnerable" = "#c5192d", "Not vulnerable" = "#3f7e44"),
                      boxmean = TRUE, showlegend = FALSE) |>
        plotly::layout(
          xaxis = list(title = ""),
          yaxis = list(title = "Scorecard score"),
          shapes = list(list(type = "line", y0 = t, y1 = t, x0 = 0, x1 = 1, xref = "paper",
                             line = list(color = "#1f2a37", dash = "dash"))),
          annotations = list(list(x = 1, xref = "paper", y = t, text = sprintf("threshold %s", fmt5(t)),
                                  showarrow = FALSE, xanchor = "right", yanchor = "bottom",
                                  font = list(size = 11)))
        )
    })

    # Of the households meeting each criterion, the share the current
    # threshold makes eligible, split by outcome: a criterion whose vulnerable
    # holders are poorly covered is carrying little weight in practice.
    output$coverage_plot <- render_wfp_plotly({
      s <- scored(); y <- outcome_binary()
      req(ncol(s$detail) > 0, length(y) == nrow(s$detail))
      rows <- lapply(colnames(s$detail), function(cl) {
        met <- s$detail[[cl]] != 0
        data.frame(criterion = cl, group = c("Vulnerable", "Not vulnerable"),
                   pct = c(100 * mean(s$eligible[met & y %in% 1]), 100 * mean(s$eligible[met & y %in% 0])))
      })
      d <- do.call(rbind, rows)
      d$pct[!is.finite(d$pct)] <- NA
      plotly::plot_ly(d, x = ~pct, y = ~criterion, color = ~group, type = "bar", orientation = "h",
                      colors = c("Vulnerable" = "#c5192d", "Not vulnerable" = "#3f7e44"),
                      hovertemplate = "%{y}<br>%{fullData.name}: %{x:.1f}% eligible<extra></extra>") |>
        plotly::layout(
          barmode = "group",
          xaxis = list(title = "% of holders eligible", range = c(0, 100)),
          yaxis = list(title = ""),
          margin = list(l = 160),
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom")
        )
    })

    output$met_plot <- render_wfp_plotly({
      s <- scored()
      req(ncol(s$detail) > 0)
      met <- rowSums(s$detail != 0, na.rm = TRUE)
      d <- data.frame(
        met = met,
        group = ifelse(s$eligible, "Eligible", "Not eligible"),
        stringsAsFactors = FALSE
      )
      plotly::plot_ly(
        d, x = ~met, color = ~group, type = "histogram",
        colors = c("Eligible" = "#0A6EB4", "Not eligible" = "#6c757d"),
        opacity = 0.8,
        hovertemplate = "%{x} criteria met<br>%{y} households<extra></extra>"
      ) |>
        plotly::layout(
          barmode = "group",
          xaxis = list(title = "Criteria met by the household", dtick = 1),
          yaxis = list(title = "Households"),
          legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom")
        )
    })

    band_table <- function(n) {
      DT::renderDT({
        s <- scored()
        b <- score_bands(s$score, n)
        req(nrow(b) > 0)
        names(b) <- c(if (n == 4) "Quartile" else "Quintile", "From", "To", "Households")
        DT::datatable(b, rownames = FALSE, selection = "none",
                      options = list(dom = "t", paging = FALSE))
      })
    }
    output$quartiles <- band_table(4L)
    output$quintiles <- band_table(5L)

    # -----------------------------------------------------------------------
    # Progress, adoption and export
    # -----------------------------------------------------------------------

    output$flow <- renderUI({
      here <- input$steps %||% "outcome"
      st <- list(
        list(key = "data", label = "Data loaded", done = !is.null(assessment_df()), panel = NULL,
             todo = "Load the assessment data on the left."),
        list(key = "outcome", label = "Vulnerability Framework", done = shiny::isTruthy(input$outcome_col),
             panel = "outcome", todo = "Choose the food-security outcome to predict."),
        list(key = "criteria", label = "Criteria Selection", done = length(input$criteria %||% character(0)) > 0,
             panel = "criteria", todo = "Pick the candidate criteria."),
        list(key = "screening", label = "Criteria Screening", done = isTRUE(selection_applied()),
             panel = "screening", todo = "Review the variables' statistics and correlations, then drop the ones not to keep."),
        list(key = "weights", label = "Model fitted", done = !is.null(fitted()),
             panel = "weights", todo = "Fit the model, iterate until satisfied."),
        list(key = "threshold", label = "Threshold & errors",
             done = !is.null(fitted()) && !is.null(input$threshold %||% thr_pending()),
             panel = "threshold", todo = "Set the threshold and check the design errors."),
        list(key = "adopt", label = "Adopted", done = adopted_current(),
             panel = "threshold", todo = "Record the rationale, then adopt the scorecard (after every other step).")
      )
      nxt <- Find(function(x) !x$done, st)
      go <- function(panel) if (is.null(panel)) NULL else
        sprintf("Shiny.setInputValue('%s', '%s', {priority:'event'})", ns("flow_go"), panel)
      items <- lapply(seq_along(st), function(i) {
        x <- st[[i]]
        cls <- paste("wfp-flow-step",
                     if (x$done) "is-done" else "",
                     if (!is.null(x$panel) && identical(x$panel, here)) "is-current" else "",
                     if (identical(x$key, nxt$key)) "is-next" else "")
        tags$button(type = "button", class = cls, onclick = go(x$panel),
                    tags$span(class = "wfp-flow-dot",
                              if (x$done) bsicons::bs_icon("check-lg") else as.character(i)),
                    tags$span(class = "wfp-flow-label", x$label))
      })
      # Back and forward through the step tabs, either side of the chart.
      panels <- c(outcome = "Vulnerability Framework", criteria = "Criteria Selection", screening = "Criteria Screening",
                  weights = "Model & weights", threshold = "Threshold & errors")
      at <- match(here, names(panels))
      arrow <- function(to, icon_name, side) {
        ok <- !is.na(to) && to >= 1 && to <= length(panels)
        tags$button(type = "button", class = paste("wfp-flow-arrow", side), disabled = if (!ok) NA,
                    title = if (ok) paste(if (side == "prev") "Back to" else "Next:", panels[[to]]) else NULL,
                    `aria-label` = if (side == "prev") "Previous step" else "Next step",
                    onclick = if (ok) go(names(panels)[to]), bsicons::bs_icon(icon_name))
      }
      tags$div(
        class = "wfp-flow mb-3",
        tags$div(class = "wfp-flow-row",
                 arrow(at - 1, "chevron-left", "prev"),
                 tags$div(class = "wfp-flow-track", items),
                 arrow(at + 1, "chevron-right", "next")),
        tags$div(
          class = "wfp-flow-next",
          if (is.null(nxt)) tagList(bsicons::bs_icon("check-circle-fill"),
                                    " Design complete: the scorecard is adopted and ready for Beneficiary Selection.")
          else tagList(
            tags$span(tags$strong("Next: "), nxt$todo),
            if (!is.null(nxt$panel) && !identical(nxt$panel, here))
              tags$button(type = "button", class = "btn btn-primary btn-sm ms-2", onclick = go(nxt$panel),
                          paste("Go to", nxt$label), bsicons::bs_icon("arrow-right"))
          )
        )
      )
    })

    observeEvent(input$flow_go, bslib::nav_select("steps", input$flow_go, session = session))

    # Adoption is the last step: every earlier one must be done first.
    missing_steps <- function() {
      c(if (is.null(assessment_df())) "load the assessment data",
        if (!shiny::isTruthy(input$outcome_col)) "choose the outcome",
        if (!length(input$criteria)) "pick the candidate criteria",
        if (!isTRUE(selection_applied())) "confirm the variable selection",
        if (is.null(fitted())) "fit the model",
        if (is.null(input$threshold %||% thr_pending())) "set the threshold")
    }

    adopt_scorecard <- function() {
      todo <- missing_steps()
      if (length(todo)) {
        showNotification(paste0("Before adopting, ", paste(todo, collapse = ", "), "."), type = "warning", duration = 10)
        return()
      }
      sc <- draft_scorecard()
      sc$source <- "design"
      sc$fingerprint <- scorecard_fingerprint(sc)
      sc$adopted_at <- format(Sys.time(), "%Y-%m-%d %H:%M")
      sc$country_office <- user_setup$country_office
      user_setup$scorecard <- sc
      e <- tryCatch(errors(), error = function(err) NULL)
      audit_add(modification_log, "Design", "Scorecard adopted",
                sprintf("%d criteria, eligible above %s%s", length(sc$items), fmt5(sc$threshold),
                        if (is.null(e)) "" else sprintf("; inclusion error %.1f%%, exclusion error %.1f%%",
                                                        100 * e$inclusion_error, 100 * e$exclusion_error)),
                reason = input$tol_rationale %||% "")
      showNotification(
        sprintf("Scorecard adopted: %d criteria, eligible above %s. Beneficiary Selection can now apply it.",
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
    observeEvent(input$btn_use, adopt_scorecard())
    observeEvent(input$nav_adopt, adopt_scorecard())

    output$use_status <- renderText({
      sc <- user_setup$scorecard
      if (scorecard_is_empty(sc)) return("No scorecard adopted yet.")
      sprintf("%s: %d criteria, threshold %s.",
              if (adopted_current()) "Adopted" else "In use (loaded from a workbook)",
              length(sc$items), fmt5(sc$threshold %||% 0))
    })

    output$download <- download_handler(
      filename = function() paste0("Targeting_Scorecard_", format(Sys.time(), "%Y-%m-%d_%Hh%Mm"), ".xlsx"),
      content = function(file) {
        req(fitted())
        sc <- draft_scorecard()
        s <- scored()
        e <- errors()
        r <- roc()
        lower <- (input$tol_lower %||% 5) / 100
        upper <- (input$tol_upper %||% 20) / 100
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
          "Designed on" = sc$created %||% format(Sys.Date()),
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
          "Threshold rationale" = if (nzchar(trimws(input$tol_rationale %||% "")))
            trimws(input$tol_rationale) else "NOT DOCUMENTED (Targeting Advisory 2/2025 requires it)",
          "Model" = names(scorecard_model_choices())[scorecard_model_choices() == (fitted()$method %||% "logit")],
          "Weighting scheme" = names(scorecard_scheme_choices())[scorecard_scheme_choices() == (fitted()$scheme %||% "odds_ratio")],
          "Survey weights" = if (shiny::isTruthy(input$model_weights)) input$model_weights else "none",
          "Evaluation sample" = if (length(split_state()$test))
            sprintf("%s held-out households (%s%%, seed %s)", format(length(split_state()$test), big.mark = ","),
                    input$holdout_pct %||% 0, input$split_seed %||% "")
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
          "Built at" = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          "Built with" = paste0("TargetWise ",
                                tryCatch(as.character(utils::packageVersion("TargetWise")),
                                         error = function(e) ""))
        )

        b <- bench()
        wb <- scorecard_workbook(
          sc, meta = meta, screening = screened(),
          comparison = if (!is.null(b)) b$table else NULL,
          bands = list(Quartiles = score_bands(s$score, 4L),
                       Quintiles = score_bands(s$score, 5L)),
          roc = r$curve
        )
        save_workbook_readonly(wb, file)
      }
    )

    output$download_json <- download_handler(
      filename = function() paste0("scorecard_", format(Sys.time(), "%Y-%m-%d"), ".json"),
      content = function(file) {
        req(fitted())
        writeLines(as.character(jsonlite::toJSON(draft_scorecard(), auto_unbox = TRUE,
                                                 pretty = TRUE, null = "null", na = "null")),
                   file, useBytes = TRUE)
      }
    )
  })
}
