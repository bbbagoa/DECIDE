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
  # Parts shown only with an outcome indicator, or only without one.
  with_outcome <- function(...) conditionalPanel(sprintf("input['%s'] !== 'none'", ns("framework_mode")), ...)
  without_outcome <- function(...) conditionalPanel(sprintf("input['%s'] === 'none'", ns("framework_mode")), ...)
  # A food-security outcome only, or a welfare measure (proxy means test) only.
  binary_only <- function(...) conditionalPanel(sprintf("input['%s'] === 'outcome'", ns("framework_mode")), ...)
  pmt_only <- function(...) conditionalPanel(sprintf("input['%s'] === 'pmt'", ns("framework_mode")), ...)
  tagList(
    bslib::layout_sidebar(
      fillable = FALSE,
      sidebar = bslib::sidebar(
        id = ns("design_sidebar"), width = 320, class = "wfp-side",
        side_steps(
          id = ns("side"), open = "data",
          # The assessment data and its tools.
          side_step("1. Assessment data", "clipboard-data", value = "data",
            tags$p(class = "small text-muted mb-2",
                   "An assessment survey with a food-security outcome (EFSA, VAM...) or a welfare measure (HIES, LSMS), not the registration or PDM data."),
            fileInput(ns("assessment_file"), NULL, width = "100%",
                      placeholder = "Load assessment data",
                      accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet")),
            tags$div(
              class = "d-flex flex-wrap gap-2 wfp-data-tools",
              # The same data from a MODA / ONA form.
              tags$div(class = "flex-fill",
                       mod_moda_import_ui(ns("moda"), "MODA", class = "btn-outline-secondary btn-sm w-100")),
              # Reloading data is the session's job; this explains the method.
              tags$div(class = "flex-fill",
                       actionButton(ns("open_guide"), "How it works", icon = icon("book-open"),
                                    class = "btn-outline-secondary btn-sm w-100",
                                    title = "The design process step by step, with its methods")),
              # Build outcomes or criteria the data does not carry yet (a
              # two-level CARI, a dependency-ratio flag).
              tags$div(class = "flex-fill",
                       mod_var_calc_ui(ns("calc"), "Calculator",
                                       class = "btn-outline-secondary btn-sm w-100"))),
            uiOutput(ns("data_status"))),
          side_step("2. Areas covered", "geo-alt", value = "areas",
            mod_area_scope_ui(ns("scope"), title = NULL)),
          side_step("3. Exports", "box-arrow-up-right", value = "adopt",
            # Exports: a list, each with what it is for.
            tags$div(
              class = "wfp-export-list",
              downloadButton(ns("download"), class = "wfp-export-item", icon = icon("file-excel"),
                             label = tags$span(class = "wfp-export-text",
                                               tags$span(class = "wfp-export-title", with_outcome("Scorecard"), without_outcome("Vulnerability ranking"), " (Excel)"),
                                               tags$span(class = "wfp-export-sub", with_outcome("Criteria, points, threshold and design errors"),
                                                         without_outcome("Criteria, points, threshold and validity")))),
              downloadButton(ns("download_json"), class = "wfp-export-item", icon = icon("file-code"),
                             label = tags$span(class = "wfp-export-text",
                                               tags$span(class = "wfp-export-title", "Card (JSON)"),
                                               tags$span(class = "wfp-export-sub", "For other tools and systems"))),
              # The whole design as a document: data, variables, screening, models,
              # threshold, errors, figures.
              downloadButton(ns("download_report"), class = "wfp-export-item", icon = icon("file-lines"),
                             label = tags$span(class = "wfp-export-text",
                                               tags$span(class = "wfp-export-title", with_outcome("Design report"), without_outcome("Ranking report"), " (HTML)"),
                                               tags$span(class = "wfp-export-sub", "Every step and chart, to share and review")))))),
        # Adopt: the one main action, always in view (one section is open at a time).
        side_actions(
          actionButton(ns("btn_use"), tagList(binary_only("Use this scorecard"), pmt_only("Use this PMT"), without_outcome("Use this ranking")),
                       icon = icon("circle-check"), class = "btn-primary btn-sm w-100 wfp-adopt-btn"),
          tags$div(class = "small text-muted mt-1", textOutput(ns("use_status"))))
      ),

      # The whole design as one slim bar, data to adoption: done, current and
      # next at a glance, each step one click away, the next action inline.
      uiOutput(ns("flow")),

      tags$div(class = "wfp-design-steps", bslib::navset_card_pill(
        id = ns("steps"),

        bslib::nav_panel(
          title = "1. Vulnerability Framework",
          value = "outcome",
          bslib::card_body(
            shinyWidgets::radioGroupButtons(
              ns("framework_mode"), NULL, status = "outline-primary",
              choices = c("Food-security outcome indicator" = "outcome", "Welfare measure: proxy means test (PMT)" = "pmt",
                          "No outcome indicator: vulnerability ranking" = "none"),
              selected = "outcome"),
            without_outcome(
              bslib::card(
                class = "mb-3",
                bslib::card_header(bsicons::bs_icon("compass"), " Targeting without an outcome indicator"),
                bslib::card_body(
                  tags$p(class = "small mb-2",
                         "When no food-security assessment is available (a sudden shock, data from a partner, a registry), households are ranked on",
                         " the criteria you choose instead of predicting an outcome: deprivation counting, a PCA or MCA index, or household profiles",
                         " from clustering. The criteria are not tested (there is nothing to test them against) and no inclusion or exclusion error can",
                         " be measured: the design reports internal consistency and the stability of the selection instead."),
                  tags$p(class = "small text-muted mb-2",
                         "Plan a small verification sample (a light food-security module) or use the PDM to measure the errors later."),
                  tags$div(
                    class = "d-flex flex-wrap align-items-end gap-2",
                    tags$div(style = "flex: 0 1 520px;",
                             textInput(ns("rank_label"), "What the ranking stands for",
                                       placeholder = "e.g. Economic vulnerability after the floods", width = "100%")),
                    tags$div(class = "mb-3", actionButton(ns("fw_validate_none"), "Validate", icon = icon("check"), class = "btn-primary"))),
                  uiOutput(ns("fw_note_none"))))),
            with_outcome(
            binary_only(
            tags$p(class = "text-muted",
                   "Pick the food-security outcome the scorecard should predict, and",
                   " which of its two levels means a vulnerable household."),
            tags$div(
              class = "d-flex flex-wrap align-items-end gap-2",
              tags$div(style = "flex: 1 1 260px;", selectInput(ns("outcome_col"), "Outcome variable", choices = NULL, width = "100%")),
              tags$div(style = "flex: 1 1 260px;", selectInput(ns("outcome_pos"), "Level meaning 'vulnerable'", choices = NULL, width = "100%")),
              tags$div(class = "mb-3", actionButton(ns("fw_validate"), "Validate", icon = icon("check"), class = "btn-primary"))),
            uiOutput(ns("fw_note")),
            uiOutput(ns("outcome_summary"))),
            pmt_only(pmt_framework_ui(ns)),
            # Where the vulnerable households are: the share by first-level area.
            bslib::card(
              class = "mb-3",
              bslib::card_header(
                class = "d-flex align-items-center justify-content-between gap-2",
                tags$span(bsicons::bs_icon("geo-alt"), binary_only(" Vulnerable households by area"), pmt_only(" Poor households by area"), chart_help("vuln_area_plot")),
                tags$div(style = "min-width: 200px;",
                         selectizeInput(ns("vuln_area"), NULL, choices = c("(none)" = ""), width = "100%",
                                        options = list(allowEmptyOption = TRUE)))),
              bslib::card_body(uiOutput(ns("vuln_area_ui")))
            )),
            uiOutput(ns("nav_outcome"))
          )
        ),

        bslib::nav_panel(
          title = "2. Criteria",
          value = "screening",
          bslib::card_body(
            uiOutput(ns("gate_screening")),
            # One table: each variable's test and overlap in one row, the Use
            # ticks pre-set from the screening. No model is fitted here.
            # Binarising (the calculator, best split for vulnerability) and the
            # correlations are separate dialogs, run only when wanted.
            with_outcome(
            tags$p(class = "text-muted",
                   "Every yes/no variable of the data, tested against the vulnerability framework. The ones associated with vulnerability come ticked in Use,",
                   " except the weaker of any two that repeat each other. Adjust the ticks and continue to the model."),
            bslib::layout_columns(
              col_widths = c(3, 4, 3, 2), fill = FALSE,
              numericInput(ns("qs_alpha"),
                           tagList("Significance level", info_tip("A variable counts as associated when its adjusted p-value is below this level. 0.05 is the usual choice.")),
                           value = 0.05, min = 0.001, max = 0.5, step = 0.005),
              selectInput(ns("qs_adjust"),
                          tagList("Multiplicity adjustment", info_tip(tip_body("Testing many variables at once finds some by chance", list(
                            list(name = "Benjamini-Hochberg.", text = "Controls the share of false findings among those declared associated. Recommended.",
                                 ref = "Benjamini & Hochberg (1995), JRSS B 57(1)."),
                            list(name = "Bonferroni / Holm.", text = "Control the chance of even one false finding: stricter, fewer associations.",
                                 ref = "Holm (1979), Scandinavian Journal of Statistics 6(2)."),
                            list(name = "None.", text = "No correction; expect false findings when there are many variables."))))),
                          choices = c("Benjamini-Hochberg" = "BH", "Bonferroni" = "bonferroni",
                                      "Holm" = "holm", "None" = "none"), selected = "BH"),
              numericInput(ns("corr_cutoff"),
                           tagList("Overlap above |r|",
                                   info_tip("Two variables correlated above this value say nearly the same thing. The weaker of the pair starts unticked, so one effect is not counted twice in the score.")),
                           value = 0.8, min = 0.3, max = 1, step = 0.05),
              tags$div(class = "wfp-inline-action",
                       tags$label(class = "form-label", "\u00a0"),
                       actionButton(ns("qs_run"), "Run the tests", icon = icon("play"), class = "btn-outline-primary w-100"))),
            uiOutput(ns("qs_stale"))),
            without_outcome(
              tags$p(class = "text-muted",
                     "Every yes/no variable of the data. Without an outcome nothing is tested: tick the criteria that describe vulnerability in this",
                     " context (for deprivation counting, so that 'yes' means deprived). Variables met by 5% to 95% of households come ticked,",
                     " except the weaker of any two that repeat each other.")),
            tags$div(
              class = "d-flex flex-wrap align-items-center gap-2 mb-2",
              uiOutput(ns("criteria_strip"), class = "me-auto"),
              # Search: filters the rows in the browser (name and label only); the
              # hidden rows keep their ticks.
              tags$input(id = ns("crit_search"), type = "search", class = "form-control form-control-sm wfp-crit-search",
                         placeholder = "Search variables", `aria-label` = "Search variables",
                         oninput = sprintf("twFilterRows(this, '%s')", ns("criteria_table"))),
              tags$script(HTML(sprintf(
                "window.twFilterRows = window.twFilterRows || function(inp, id) {
                   var q = (inp.value || '').trim().toLowerCase(), box = document.getElementById(id);
                   if (!box) return;
                   box.querySelectorAll('tbody tr').forEach(function(tr) {
                     var c = tr.querySelector('.tw-var'), t = (c || tr).textContent.toLowerCase();
                     tr.style.display = !q || t.indexOf(q) >= 0 ? '' : 'none';
                   });
                 };
                 $(document).on('shiny:value', function(e) {
                   if (e.name !== '%s') return;
                   setTimeout(function() { var i = document.getElementById('%s'); if (i && i.value) twFilterRows(i, '%s'); }, 0);
                 });", ns("criteria_table"), ns("crit_search"), ns("criteria_table")))),
              bslib::tooltip(
                mod_var_calc_bulk_ui(ns("calc"), "Binarise variables"),
                "Turn variables with several answers or numbers into yes/no, with the split that separates vulnerable households best. The new variables join this table."),
              bslib::tooltip(
                actionButton(ns("open_corr"), "Correlations", icon = icon("table-cells"), class = "btn-outline-secondary btn-sm"),
                "Correlation matrix and descriptive statistics of the ticked variables.")),
            uiOutput(ns("criteria_table")),
            pmt_only(pmt_numeric_ui(ns)),
            tags$details(
              class = "wfp-qs-how small mt-3",
              tags$summary(tags$strong("How to read this table")),
              tags$ul(
                class = "mt-2 mb-0",
                tags$li(tags$strong("Among vulnerable / among others"), ": the share of households meeting the criterion in each outcome group. ",
                        "More common among the vulnerable: an inclusion criterion; less common: an exclusion criterion."),
                tags$li(tags$strong("Odds ratio and adjusted p"), ": each variable is tested alone with a one-criterion logistic regression and a likelihood-ratio test ",
                        "(Fisher's exact test when that model cannot be estimated). The p-values are adjusted for testing many variables. ",
                        "\u2191 associated with vulnerability, \u2193 associated with not being vulnerable."),
                tags$li(tags$strong("Overlaps with"), ": the associated variable it correlates with most. Above the cut-off, the weaker of the pair starts unticked."),
                tags$li(tags$strong("Missing"), ": households with no answer. Above about 20%, check the question: in the score a missing answer counts as 'no'."),
                with_outcome(tags$li("Every variable listed is observable at registration and not an outcome indicator (checked automatically; the others are listed below).")),
                without_outcome(tags$li("Without an outcome every yes/no variable is listed except names and identifiers: outcome indicators and what a registration team cannot observe may rank households too, but a criterion the registration cannot collect cannot be applied in Beneficiary Selection.")),
                tags$li("A variable with no clear association alone can still matter next to others: keep what field knowledge supports, the model gives each its net weight."))),
            tags$details(
              class = "wfp-qs-how small mt-2",
              tags$summary(tags$strong(bsicons::bs_icon("shield-exclamation"), " Columns that cannot be criteria")),
              tags$div(class = "pt-2", uiOutput(ns("blocked_note")))),
            uiOutput(ns("nav_screening"))
          )
        ),

        bslib::nav_panel(
          title = "3. Model & weights",
          value = "weights",
          bslib::card_body(
            tags$p(class = "text-muted",
                   "Fit a model on the retained criteria and turn it into points.",
                   " Adjust any weight where local knowledge says the model is wrong --",
                   " the reference analysis does exactly this."),
            uiOutput(ns("gate_weights")),
            # One band: three panels side by side (model, what it is fitted on,
            # comparison and Fit).
            tags$div(
              class = "wfp-fit-band mb-3",
              tags$div(
                class = "wfp-fit-group",
                tags$div(class = "wfp-fit-label", "1. Model"),
                # A model with its own settings gets a small button beside it
                # that opens them in a dialog; a line under it says what is set.
                tags$div(
                  class = "wfp-model-row",
                  tags$div(class = "flex-grow-1",
                           selectInput(ns("model_method"), tagList("Model", model_tip()),
                                       choices = scorecard_model_choices(), width = "100%", selectize = FALSE)),
                  conditionalPanel(
                    condition = sprintf("input['%s'] !== 'none' || ['pca', 'mca', 'lca', 'kmeans', 'hclust'].indexOf(input['%s']) >= 0",
                                        ns("framework_mode"), ns("model_method")),
                    tags$div(class = "wfp-model-gear",
                             actionButton(ns("model_params"), NULL, icon = icon("sliders"), class = "btn-outline-secondary btn-sm",
                                          title = "Settings of this model", `aria-label` = "Settings of this model")))),
                uiOutput(ns("params_summary")),
                binary_only(
                selectInput(ns("model_scheme"),
                            tagList("Weighting scheme", info_tip("How model coefficients become points: odds ratios (APP-FA reference), log-odds, whole points out of 10, or 1 point per criterion.")),
                            choices = scorecard_scheme_choices(), width = "100%", selectize = FALSE)),
                without_outcome(tags$div(class = "small text-muted", textOutput(ns("unsup_note")))),
                pmt_only(tags$div(class = "small text-muted", "Points: 100 \u00d7 each proxy's coefficient on log welfare per person, so one point is about 1% less predicted welfare; a numeric proxy scores per unit."))),
              tags$div(
                class = "wfp-fit-group",
                tags$div(class = "wfp-fit-label", "2. Criteria and data"),
                # Iterate: change the criteria (or any setting) and fit again;
                # every fit is kept in the run history below.
                shinyWidgets::pickerInput(
                  ns("fit_criteria"), "Criteria in the model",
                  choices = character(0), multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE,
                                                        selectedTextFormat = "count > 3")),
                selectizeInput(ns("model_weights"),
                               tagList("Survey weights (optional)", info_tip("Sampling weight column. When set, the model counts each household by its weight so the estimates represent the population, not the sample.")),
                               choices = c("(none)" = ""), width = "100%", options = list(allowEmptyOption = TRUE)),
                NULL),
              tags$div(
                class = "wfp-fit-group",
                with_outcome(tags$div(class = "wfp-fit-label", "3. Comparison")),
                without_outcome(
                  tags$div(class = "wfp-fit-label", "3. Orientation"),
                  selectizeInput(ns("anchor"),
                                 tagList("Anchor criterion (optional)", info_tip("Sets the direction of the ranking: a PCA or MCA axis has no direction of its own, so the index is turned so that this criterion raises it, and the cluster profiles are ranked on it. Choose a criterion that clearly marks vulnerability here. With none, more criteria met means more vulnerable (tick criteria so that yes = deprived). Deprivation counting does not use it.")),
                                 choices = c("(none: more criteria met = more vulnerable)" = ""), width = "100%",
                                 options = list(allowEmptyOption = TRUE))),
                # Each extra model is a full fit: the machine-learning ones
                # take most of the time, so only the quick ones run by default.
                binary_only(shinyWidgets::pickerInput(
                  ns("compare_models"),
                  tagList("Models to compare", info_tip("Models fitted next to the chosen one: each variable's effect under every model, and each model's AUC and ROC on the held-out households. Machine-learning models are slow on large data: add them only when you need them.")),
                  choices = scorecard_model_choices(), selected = intersect(c("logit", "woe", "stumps"), scorecard_model_choices()),
                  multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE,
                                                        selectedTextFormat = "count > 2",
                                                        countSelectedText = "{0} models"))),
                pmt_only(shinyWidgets::pickerInput(
                  ns("pmt_compare"),
                  tagList("Models to compare", info_tip("Other PMT models fitted on the same proxies and households: R-squared on held-out households, leakage and under-coverage at the line, and how both errors move with the cut-off.")),
                  choices = pmt_model_choices(), selected = c("pmt_ols", "pmt_qr", "pmt_lasso"),
                  multiple = TRUE, width = "100%",
                  options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, selectedTextFormat = "count > 2",
                                                        countSelectedText = "{0} models"))),
                # stepwise selection of the criteria, applied before the model
                with_outcome(
                tags$div(
                  class = "wfp-fit-pair",
                  selectInput(ns("stepwise"),
                              tagList("Stepwise", info_tip("Selection of the criteria before fitting, for any model. Backward removes criteria from the full set, forward adds them from none, both directions adds and may remove again.")),
                              choices = c("No stepwise" = "none", "Backward" = "backward", "Forward" = "forward", "Both directions" = "both"),
                              selected = "none", width = "100%", selectize = FALSE),
                  conditionalPanel(
                    condition = sprintf("input['%s'] !== 'none'", ns("stepwise")),
                    selectInput(ns("stepwise_ic"),
                                tagList("Criterion", info_tip("AIC is the usual choice; BIC penalises each criterion more (log of the sample size) and keeps fewer.")),
                                choices = c("AIC" = "aic", "BIC" = "bic"), selected = "aic", width = "100%", selectize = FALSE)))),

                tags$div(
                  class = "wfp-fit-go",
                  bslib::tooltip(
                    actionButton(ns("run_fit"), "Fit model", icon = icon("play"), class = "btn-primary w-100"),
                    "Fits the chosen model on the training households, turns it into points, and adds the fit to the run history.")))
            ),
            tags$div(class = "small text-muted mb-3",
                     textOutput(ns("model_note"), inline = TRUE), " ",
                     textOutput(ns("scheme_note"), inline = TRUE), " ",
                     uiOutput(ns("scheme_apply_ui"), inline = TRUE)),
            uiOutput(ns("fit_note")),
            uiOutput(ns("runs_ui")),
            hr(),
            uiOutput(ns("weights_ui")),
            # Right under the estimates: which model to trust is the next
            # question once the coefficients are read.
            uiOutput(ns("comparison_ui")),
            uiOutput(ns("effects_ui")),
            uiOutput(ns("diagram_ui")),
            uiOutput(ns("tree_ui")),
            uiOutput(ns("weights_charts")),
            uiOutput(ns("nav_weights"))
          )
        ),

        bslib::nav_panel(
          title = "4. Threshold & errors",
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
            # Set-up on the left, the team's rationale on the right.
            bslib::layout_columns(
              col_widths = c(6, 6), fill = FALSE, class = "mb-2 wfp-thr-setup",
              tags$div(
                class = "border-0 bg-body-tertiary rounded-3 px-3 pt-2 h-100",
                uiOutput(ns("threshold_ui")),
                bslib::layout_columns(
                  col_widths = c(6, 6), fill = FALSE,
                  with_outcome(tags$div(class = "wfp-fit-pair",
                  numericInput(ns("tol_lower"),
                               tagList("Lower %", info_tip("Lower bound of the tolerance band (Advisory 2/2025). Errors below it are acceptable without action. Changing the default (5%) needs an explanation in the rationale.")),
                               value = TOL_DEFAULT[1],
                               min = 0, max = 49, step = 1, width = "100%"),
                  numericInput(ns("tol_upper"),
                               tagList("Upper %", info_tip("Upper bound of the tolerance band. Errors above it call for a redesign; it can never reach 50% (no better than random). Changing the default (20%) needs an explanation in the rationale.")),
                               value = TOL_DEFAULT[2],
                               min = 1, max = 49, step = 1, width = "100%"))),
                  numericInput(ns("caseload_pct"),
                               tagList("Caseload (% of households)", info_tip("Share of households the programme can serve. Used by 'Fit to caseload' to set the highest threshold that stays within it.")),
                               value = NA, min = 1, max = 100, step = 1, width = "100%")
                ),
                tags$div(
                  class = "d-flex flex-wrap gap-2 mb-2",
                  with_outcome(tags$div(class = "d-flex flex-wrap gap-2",
                  bslib::tooltip(
                    actionButton(ns("thr_balanced"), "Minimise errors",
                                 icon = icon("arrows-to-dot"), class = "btn-outline-primary btn-sm"),
                    "Sets the threshold where the larger of the inclusion and exclusion errors is smallest, so neither is traded away for the other."),
                  bslib::tooltip(
                    actionButton(ns("thr_youden"), "Balance (Youden)",
                                 icon = icon("scale-balanced"), class = "btn-outline-primary btn-sm"),
                    tip_body("Youden's J", list(list(name = "", text = "Picks the threshold maximising sensitivity + specificity - 1: the point of the ROC curve furthest from the diagonal (Targeting Advisory 3/2025).",
                                                   ref = "Youden (1950), Index for rating diagnostic tests, Cancer 3(1).")))))),
                  pmt_only(bslib::tooltip(
                    actionButton(ns("thr_line"), "At the poverty line", icon = icon("ruler-horizontal"), class = "btn-outline-primary btn-sm"),
                    "Eligible when predicted welfare per person is at or below the poverty line: the standard PMT cut-off. A cut-off above the line lowers exclusion errors at the cost of inclusion errors (Brown, Ravallion & van de Walle 2018).")),
                  bslib::tooltip(
                    actionButton(ns("thr_caseload"), "Fit to caseload",
                                 icon = icon("people-group"), class = "btn-outline-primary btn-sm"),
                    "Sets the threshold so no more than the caseload share of households is eligible.")),
                tags$div(class = "d-flex flex-wrap align-items-center gap-2 mb-2",
                         actionButton(ns("thr_apply"), "Apply", icon = icon("check"), class = "btn-primary btn-sm"),
                         uiOutput(ns("thr_stale"), inline = TRUE)),
                tags$div(class = "small text-muted pb-2", textOutput(ns("thr_note"))),
                pmt_only(tags$div(class = "small pb-2", uiOutput(ns("pmt_thr_note"))))
              ),
              # Advisory 2/2025: COs must document the rationale behind their
              # threshold bandwidth. It travels in the exported workbook.
              rich_text_input(ns("tol_rationale"),
                              tagList("Rationale for the band and the threshold",
                                      info_tip("Required by Targeting Advisory 2/2025; it goes into the exported scorecard and the design report.")),
                              placeholder = paste("e.g. Lower 15% / upper 25% agreed with the programme",
                                                  "team given field access constraints; threshold set to",
                                                  "fit a caseload of 40% of households."),
                              rows = 4)
            ),
            # Without an outcome: the selection, its consistency and stability.
            without_outcome(
              bslib::layout_columns(
                col_widths = c(3, 3, 6), fill = FALSE, class = "wfp-kpi-flat",
                bslib::value_box(title = "Households selected", value = textOutput(ns("kpi_selected")),
                                 showcase = bsicons::bs_icon("people"), theme = "info"),
                bslib::value_box(title = tagList("Internal consistency", info_tip("Cronbach's alpha of the criteria: how far they measure one thing. Above 0.7 is usually read as consistent; low values are expected when the criteria cover different dimensions of vulnerability on purpose.")),
                                 value = textOutput(ns("kpi_alpha")),
                                 showcase = bsicons::bs_icon("diagram-3"), theme = "primary"),
                bslib::card(
                  bslib::card_header(bsicons::bs_icon("shuffle"), " Stability of the selection",
                                     info_tip("The design is refitted on 20 resamples of the households; each refit selects the same share of households. The agreement with the design's own selection (Jaccard index) says how much the targeting depends on who happened to be in the data.")),
                  bslib::card_body(uiOutput(ns("stability_ui"))))),
              bslib::layout_columns(
                col_widths = c(6, 6),
                bslib::card(bslib::card_header(bsicons::bs_icon("lightbulb"), " What the selection concentrates",
                                               info_tip("A household's deprivations are the criteria it meets in the vulnerable direction (an inclusion criterion met, an exclusion criterion not met).")),
                            bslib::card_body(uiOutput(ns("insights_ui")))),
                bslib::card(bslib::card_header(
                              class = "d-flex align-items-center justify-content-between gap-2",
                              tags$span(bsicons::bs_icon("geo-alt"), " Share selected by area", chart_help("cov_area_plot")),
                              tags$div(style = "min-width: 180px;",
                                       selectizeInput(ns("cov_area"), NULL, choices = c("(none)" = ""), width = "100%",
                                                      options = list(allowEmptyOption = TRUE)))),
                            plotly::plotlyOutput(ns("cov_area_plot"), height = "320px"))),
              bslib::layout_columns(
                col_widths = c(6, 6),
                bslib::card(bslib::card_header(bsicons::bs_icon("bar-chart"), " Ranking distribution", chart_help("rank_plot")),
                            plotly::plotlyOutput(ns("rank_plot"), height = "400px")),
                bslib::card(bslib::card_header(bsicons::bs_icon("check2-square"), " Criteria among selected and other households", chart_help("sel_prev_plot")),
                            plotly::plotlyOutput(ns("sel_prev_plot"), height = "400px")))),
            with_outcome(
            tags$div(class = "small text-muted mb-2", textOutput(ns("eval_note"))),
            pmt_only(uiOutput(ns("pmt_accuracy_ui"))),
            bslib::layout_columns(
              col_widths = c(3, 3, 3, 3), fill = FALSE, class = "wfp-kpi-flat",
              bslib::value_box(title = textOutput(ns("kpi_auc_title"), inline = TRUE),
                               value = textOutput(ns("kpi_auc")),
                               showcase = bsicons::bs_icon("graph-up"), theme = "primary"),
              bslib::value_box(title = tagList(binary_only("Eligible households"), pmt_only("Selected (predicted poor)")), value = textOutput(ns("kpi_elig")),
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
                  binary_only(" Design error matrix"), pmt_only(" PMT targeting matrix")
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
                bslib::card_header("ROC curve", chart_help("roc_plot")),
                plotly::plotlyOutput(ns("roc_plot"), height = "400px")
              ),
              bslib::card(
                bslib::card_header("Score distribution", chart_help("score_plot")),
                plotly::plotlyOutput(ns("score_plot"), height = "400px")
              ),
              bslib::card(
                bslib::card_header(bsicons::bs_icon("box"), binary_only(" Score by vulnerability"), pmt_only(" PMT score by poverty status"), chart_help("box_plot")),
                plotly::plotlyOutput(ns("box_plot"), height = "400px")
              )
            )),
            bslib::layout_columns(
              col_widths = c(4, 4, 4),
              bslib::card(
                bslib::card_header(
                  bsicons::bs_icon("bar-chart-steps"),
                  " What actually drives the score", chart_help("contribution_plot")
                ),
                plotly::plotlyOutput(ns("contribution_plot"), height = "480px")
              ),
              bslib::card(
                bslib::card_header(
                  bsicons::bs_icon("people"),
                  " Criteria met, eligible vs not", chart_help("met_plot")
                ),
                plotly::plotlyOutput(ns("met_plot"), height = "480px")
              ),
              # one slot: coverage with an outcome; without one (coverage cannot
              # be read) the selection by number of criteria met
              tags$div(
                class = "h-100",
                with_outcome(bslib::card(
                  bslib::card_header(bsicons::bs_icon("person-check"), " Coverage by criterion", chart_help("coverage_plot")),
                  plotly::plotlyOutput(ns("coverage_plot"), height = "480px")
                )),
                without_outcome(bslib::card(
                  bslib::card_header(bsicons::bs_icon("graph-up-arrow"), " Share selected by number of criteria met", chart_help("sel_by_met_plot")),
                  plotly::plotlyOutput(ns("sel_by_met_plot"), height = "480px")
                )))
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
      ))
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
      take_assessment(df, input$assessment_file$name)
    })
    take_assessment <- function(df, name) {
      assessment_df(as.data.frame(df))
      assessment_source(name)
      audit_add(modification_log, "Design", "Assessment data loaded",
                sprintf("%s (%s rows, %s columns)", name, nrow(df), ncol(df)))
      reset_build()
      go_step("outcome")
      showNotification(sprintf("Assessment data loaded: %s rows, %s columns.",
                               format(nrow(df), big.mark = ","), ncol(df)),
                       type = "message")
    }
    # The same data can come from a MODA / ONA form.
    moda <- mod_moda_import_server("moda")
    observeEvent(moda$data(), {
      df <- moda$data(); req(df)
      take_assessment(df, moda$label() %||% sprintf("MODA form %s", moda$credentials()$form_id %||% ""))
    })

    observeEvent(input$open_guide, showModal(design_guide_modal()))

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
        list(data = assessment_all(), source = assessment_source(), calc = calc_vars(),
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
        assessment_df(s$data); assessment_source(s$source)
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
      ok <- framework_ready()
      step_nav(NULL, NULL, ok,
               if (no_outcome()) "No outcome indicator: the design will rank households on the criteria you choose."
               else if (pmt()) sprintf("Welfare validated: %s per person, poverty line %s.", pmt_applied()$welfare %||% "",
                                       fmt_money(tryCatch(pmt_line_value(), error = function(e) NA_real_)))
               else sprintf("Outcome set: %s = %s.", input$outcome_col %||% "", input$outcome_pos %||% ""),
               if (pmt()) "Load assessment data above, set the welfare variable and the poverty line, then Validate."
               else "Load assessment data above, then choose the outcome and the level that means vulnerable.",
               "nav_next_outcome", "Continue to Criteria")
    })

    # The one action of the Criteria step: the Use ticks go to the model.
    output$nav_screening <- renderUI({
      res <- screened()
      use <- if (is.null(res)) character(0) else res$criterion[use_now()]
      if (pmt()) use <- c(use, setdiff(pmt_numeric_sel(), use))
      sent <- isTRUE(selection_applied()) && setequal(use, ready_criteria())
      step_nav("nav_back_screening", "Back to Vulnerability Framework", length(use) > 0,
               paste0(sprintf("%d criteria ticked", length(use)), if (sent) ": sent to the model." else "."),
               "Tick at least one variable in the Use column.",
               "nav_next_screening", sprintf("Continue to the model (%d)", length(use)))
    })

    output$nav_weights <- renderUI({
      f <- fitted()
      step_nav("nav_back_weights", "Back to Criteria", !is.null(f),
               if (is.null(f)) "" else sprintf("Model fitted on %d criteria. Iterate above if needed.", nrow(f$weights)),
               "Fit the model first.",
               "nav_next_weights", "Continue to Threshold & errors")
    })

    output$nav_threshold <- renderUI({
      todo <- missing_steps()
      if (adopted_current()) {
        return(tags$div(
          class = "wfp-stepnav",
          actionButton(ns("nav_back_threshold"), "Back to Model & weights", icon = icon("arrow-left"), class = "btn-outline-secondary"),
          tags$div(class = "wfp-stepnav-status small",
                   bsicons::bs_icon("check-circle-fill", class = "text-success"),
                   sprintf(" Adopted %s. Any change to the design withdraws the adoption.", user_setup$scorecard$adopted_at %||% "")),
          tags$span(class = "wfp-adopted-pill", bsicons::bs_icon("patch-check-fill"), " Adopted")))
      }
      other <- !scorecard_is_empty(user_setup$scorecard)
      step_nav("nav_back_threshold", "Back to Model & weights", !length(todo),
               if (other) "Another scorecard is in use. Adopting replaces it with this design."
               else "Check the errors and the verdict, record the rationale, then adopt.",
               paste0("Still to do: ", paste(todo, collapse = ", "), "."),
               "nav_adopt", if (no_outcome()) "Adopt this ranking" else if (pmt()) "Adopt this PMT" else "Adopt this scorecard", next_icon = "check")
    })

    observeEvent(input$nav_next_outcome, go_step("screening"))
    observeEvent(input$nav_back_screening, go_step("outcome"))
    observeEvent(input$nav_back_weights, go_step("screening"))
    observeEvent(input$nav_next_weights, go_step("threshold"))
    observeEvent(input$nav_back_threshold, go_step("weights"))

    output$gate_screening <- renderUI({
      if (framework_ready()) return(NULL)
      gate("Screening compares each variable with the vulnerability framework, so set it first.",
           "back_to_outcome", "Back to Vulnerability Framework")
    })

    output$gate_weights <- renderUI({
      if (length(ready_criteria()) > 0) return(NULL)
      gate("Weights come from a model fitted on the chosen criteria, so choose them first.",
           "back_to_criteria", "Back to Criteria")
    })

    output$gate_threshold <- renderUI({
      if (!is.null(fitted())) return(NULL)
      gate("The threshold is chosen against the errors a scored design produces, so fit the weights first.",
           "back_to_weights", "Back to Model & weights")
    })

    observeEvent(input$back_to_criteria, go_step("screening"))
    observeEvent(input$back_to_outcome, go_step("outcome"))
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
    output$pmt_setup_note <- renderUI({
      a <- pmt_applied()
      if (is.null(a)) return(tags$div(class = "small text-muted mb-2", bsicons::bs_icon("info-circle"),
                                      " Set the welfare variable and the poverty line, then Validate: the analysis starts from there."))
      if (!identical(a[setdiff(names(a), "weights")], pmt_now()[setdiff(names(a), "weights")])) return(tags$div(class = "small text-warning mb-2", bsicons::bs_icon("exclamation-circle"),
                                                    " The setup changed since it was validated: Validate again to apply it."))
      NULL
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
    observeEvent(input$fw_validate, validate_framework())
    observeEvent(input$fw_validate_none, validate_framework())
    fw_stale_note <- function() {
      a <- fw_applied()
      if (is.null(a) || !identical(a$mode, input$framework_mode %||% "outcome"))
        return(tags$div(class = "small text-muted mb-2", bsicons::bs_icon("info-circle"), " Click Validate: the design starts from there."))
      if (identical(a$mode, "outcome") && !identical(a, fw_now()))
        return(tags$div(class = "small text-warning mb-2", bsicons::bs_icon("exclamation-circle"),
                        " The outcome changed since it was validated: Validate again to apply it."))
      NULL
    }
    output$fw_note <- renderUI(fw_stale_note())
    output$fw_note_none <- renderUI(fw_stale_note())
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
    output$pmt_summary <- renderUI({
      df <- assessment_df(); req(df, pmt())
      pc <- tryCatch(pmt_pc(), error = function(e) NULL)
      if (is.null(pc)) return(NULL)
      line <- tryCatch(pmt_line_value(), error = function(e) NA_real_)
      if (!isTRUE(is.finite(line))) return(NULL)
      poor <- pmt_poor(pc, line)
      rq <- pmt_requirements(pc, poor, per_person = identical(pmt_applied()$unit, "pc"),
                             size_given = nzchar(pmt_applied()$size %||% ""))
      icon_of <- c(ok = "check-circle-fill", warn = "exclamation-triangle-fill", fail = "x-octagon-fill")
      col_of <- c(ok = "text-success", warn = "text-warning", fail = "text-danger")
      tagList(
        bslib::layout_columns(
          col_widths = c(3, 3, 3, 3), fill = FALSE, class = "wfp-kpi-flat",
          bslib::value_box(title = "Households with welfare", value = format(sum(!is.na(pc)), big.mark = ","),
                           showcase = bsicons::bs_icon("clipboard-data"), theme = "primary"),
          bslib::value_box(title = "Median welfare per person", value = fmt_money(stats::median(pc, na.rm = TRUE)),
                           showcase = bsicons::bs_icon("cash"), theme = "info"),
          bslib::value_box(title = "Poverty line per person", value = fmt_money(line),
                           showcase = bsicons::bs_icon("rulers"), theme = "secondary"),
          bslib::value_box(title = "Poor (at or below the line)", value = sprintf("%.1f%%", 100 * mean(poor, na.rm = TRUE)),
                           showcase = bsicons::bs_icon("exclamation-triangle"), theme = "danger")),
        tags$div(class = "small fw-bold text-uppercase mt-2 mb-1", "Data requirements"),
        tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$tbody(lapply(seq_len(nrow(rq)), function(i) tags$tr(
            tags$td(bsicons::bs_icon(icon_of[[rq$status[i]]], class = col_of[[rq$status[i]]])),
            tags$td(tags$strong(rq$check[i])),
            tags$td(class = "small", rq$detail[i])))))))
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
    output$pmt_numeric_table <- renderUI({
      d <- pmt_num_prof()
      if (is.null(d)) return(tags$div(class = "small text-muted", "Validate the welfare setup (Vulnerability Framework) to list the numeric proxies."))
      tags$div(class = "wfp-model-table-wrap mt-2", tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(tags$th(class = "text-center", "Use"), tags$th("Proxy"), tags$th(class = "num", "Average"), tags$th(class = "num", "Missing"),
                           tags$th(class = "num", tagList("Correlation with log welfare", info_tip("Negative: households with more of it are poorer (an inclusion proxy, as household size usually is)."))))),
        tags$tbody(lapply(seq_len(nrow(d)), function(i) tags$tr(
          tags$td(class = "text-center", checkboxInput(ns(pnum_id(d$proxy[i])), NULL, value = isTRUE(d$use[i]))),
          tags$td(class = "tw-var", tags$strong(d$proxy[i])),
          tags$td(class = "num", sprintf("%.2f", d$mean[i])),
          tags$td(class = "num", sprintf("%.0f%%", 100 * d$missing[i])),
          tags$td(class = "num", if (is.na(d$r[i])) "\u2013" else sprintf("%+.2f", d$r[i])))))))
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
          bslib::value_box(title = paste0("Vulnerable (", opos(), ")"),
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
    output$vuln_area_ui <- renderUI({
      if (!shiny::isTruthy(input$vuln_area))
        return(tags$div(class = "small text-muted", "Choose the area column (for example the province) to see where the vulnerable households are."))
      d <- tryCatch(vuln_area_tab(), error = function(e) NULL)
      if (is.null(d)) return(tags$div(class = "small text-muted", "Choose the outcome first."))
      n <- min(nrow(d), 30)
      # Every area: past about 30 columns the chart grows wider and scrolls
      # inside its card instead of dropping areas.
      tags$div(style = "overflow-x: auto;",
               tags$div(style = sprintf("min-width: %dpx;", max(0, 40 * nrow(d))),
                        plotly::plotlyOutput(ns("vuln_area_plot"), height = if (nrow(d) > 8) "440px" else "380px")))
    })
    # 100% stacked columns: vulnerable and not vulnerable in each area, the
    # dotted line at the share vulnerable overall.
    output$vuln_area_plot <- render_wfp_plotly({
      d <- vuln_area_tab()
      y <- outcome_binary()
      overall <- 100 * mean(y == 1, na.rm = TRUE)
      d$area <- factor(d$area, levels = d$area)
      hover <- function(k, lab) sprintf("%s<br>%s: %.0f%% (%s of %s households)", d$area, lab, 100 * k / d$households,
                                        format(k, big.mark = ","), format(d$households, big.mark = ","))
      plotly::plot_ly(d, x = ~area) |>
        plotly::add_bars(y = ~ 100 * share, name = W("Vulnerable"), marker = list(color = "#c5192d"),
                         text = ~ sprintf("%.0f%%", 100 * share), textposition = "inside", insidetextanchor = "middle",
                         textfont = list(color = "#ffffff"), hovertext = hover(d$vulnerable, W("Vulnerable")), hoverinfo = "text") |>
        plotly::add_bars(y = ~ 100 * (1 - share), name = W("Not vulnerable"), marker = list(color = "#3f7e44"),
                         text = ~ sprintf("%.0f%%", 100 * (1 - share)), textposition = "inside", insidetextanchor = "middle",
                         textfont = list(color = "#ffffff"),
                         hovertext = hover(d$households - d$vulnerable, W("Not vulnerable")), hoverinfo = "text") |>
        plotly::layout(barmode = "stack", bargap = 0.35,
                       xaxis = list(title = "", tickangle = if (nrow(d) > 8) -90 else 0, automargin = TRUE),
                       yaxis = list(title = "Households (%)", range = c(0, 100), ticksuffix = "%"),
                       legend = list(orientation = "h", x = 0, y = 1.1, xanchor = "left", yanchor = "bottom"),
                       shapes = list(list(type = "line", xref = "paper", x0 = 0, x1 = 1, y0 = overall, y1 = overall,
                                          line = list(color = "#1f2a37", dash = "dot", width = 2))),
                       annotations = list(list(xref = "paper", x = 1, y = overall, xanchor = "right", yanchor = "bottom",
                                               showarrow = FALSE, text = sprintf(W("All areas: %.0f%% vulnerable"), overall),
                                               font = list(size = 11), bgcolor = "rgba(255,255,255,0.8)")))
    })

    # Allowing blocked columns back: the analyst's call, recorded.
    allow_ui <- function() {
      ov <- overridable(); al <- intersect(allowed_blocked(), ov)
      if (!length(ov)) return(NULL)
      tags$div(
        class = "mt-3 pt-2 border-top",
        tags$strong(bsicons::bs_icon("unlock"), " Allow some of them anyway"),
        tags$p(class = "small text-muted mb-2",
               "The blocking rules read column names and can be wrong. You decide: an allowed column joins the candidates, and the choice and its reason go to the audit trail and the report."),
        if (length(al)) tags$div(class = "small mb-2", bsicons::bs_icon("check2-circle", class = "text-success"), " Allowed:",
                                 tags$ul(class = "mb-0", lapply(al, function(a) tags$li(tags$code(a), " \u2014 ",
                                   tags$em(if (is.na(allowed_reason()[a])) "no note given" else allowed_reason()[[a]]))))),
        shinyWidgets::pickerInput(ns("allow_blocked"), NULL, choices = ov, selected = al, multiple = TRUE, width = "100%",
                                  options = shinyWidgets::pickerOptions(container = "body", liveSearch = TRUE, actionsBox = TRUE,
                                                                        noneSelectedText = "Choose blocked columns to allow",
                                                                        selectedTextFormat = "count > 3")),
        textInput(ns("allow_reason"), tagList("Note (why)", info_tip("A short explanation, recorded for the columns allowed now: it goes to the audit trail and the design report.")),
                  value = "", width = "100%",
                  placeholder = "e.g. a household characteristic despite its name; observable by the registration team here"),
        actionButton(ns("allow_apply"), "Allow as criteria", icon = icon("unlock"), class = "btn-outline-primary btn-sm"))
    }
    observeEvent(input$allow_apply, {
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

    output$blocked_note <- renderUI({
      b <- blockers()
      outcome_blocked <- b[vapply(b, function(x) grepl("Advisory 1/2025", x, fixed = TRUE), logical(1))]
      unobs <- b[vapply(b, function(x) grepl("Not observable", x, fixed = TRUE), logical(1))]
      ids <- b[vapply(b, function(x) grepl("identification variable", x, fixed = TRUE), logical(1))]
      if (!length(outcome_blocked) && !length(unobs) && !length(ids)) return(tags$div(class = "text-muted", "No column is blocked."))
      al <- intersect(allowed_blocked(), names(b))
      outcome_blocked <- outcome_blocked[!names(outcome_blocked) %in% al]
      unobs <- unobs[!names(unobs) %in% al]; ids <- ids[!names(ids) %in% al]
      cols_line <- function(v) tags$div(class = "small", paste(utils::head(names(v), 25), collapse = ", "), if (length(v) > 25) ", ...")
      tags$div(
        class = "alert alert-info mt-2",
        if (length(outcome_blocked)) tagList(
          tags$strong(bsicons::bs_icon("shield-exclamation"),
                      sprintf(" %d column(s) blocked as outcome indicators", length(outcome_blocked))),
          tags$p(class = "small mb-1 mt-2",
                 "Outcome indicators reflect a household's current food consumption, which",
                 " moves with the season and with assistance itself. Targeting on them is",
                 " reactive rather than preventive, and they cannot then be used to validate",
                 " the targeting."),
          cols_line(outcome_blocked)),
        if (length(unobs)) tagList(
          tags$strong(class = if (length(outcome_blocked)) "d-block mt-3", bsicons::bs_icon("eye-slash"),
                      sprintf(" %d column(s) not observable at registration", length(unobs))),
          tags$p(class = "small mb-1 mt-2",
                 "Expenditure, prices, coping strategies and their reasons, MEB and transfer values, food consumption,",
                 " phone numbers and indebtedness cannot be seen or verified by a registration team, so they are not criteria."),
          cols_line(unobs)),
        if (length(ids)) tagList(
          tags$strong(class = if (length(outcome_blocked) || length(unobs)) "d-block mt-3", bsicons::bs_icon("person-vcard"),
                      sprintf(" %d name or identification column(s)", length(ids))),
          tags$p(class = "small mb-1 mt-2", "Identifiers, names, phone numbers and form metadata identify a household; they do not describe it."),
          cols_line(ids)),
        if (no_outcome()) tags$p(class = "small mb-0 mt-3",
          "Without an outcome, outcome indicators (FCS, rCSI, CARI...) and what a registration team cannot observe are allowed: they may rank households.",
          " Remember that a criterion the registration cannot collect cannot be applied in Beneficiary Selection."),
        allow_ui()
      )
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
      need_ok(!is.null(screened()), "Set the vulnerability framework first.")
      run_qs()
      showNotification("Tests run: the Use ticks follow the new results.", type = "message", duration = 5)
    })
    output$qs_stale <- renderUI({
      p <- qs_params()
      if (is.null(p) || isTRUE(all.equal(p, qs_now()))) {
        return(tags$div(class = "small text-muted mb-2", "Change the settings, then Run the tests: running again resets the Use ticks."))
      }
      tags$div(class = "small text-warning mb-2", bsicons::bs_icon("exclamation-circle"),
               " The settings changed since the tests were run: click Run the tests to apply them.")
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

    output$criteria_table <- renderUI({
      res <- screened()
      if (is.null(res)) return(empty_state("No variables yet", "Set the vulnerability framework: the table fills by itself.", icon = "funnel"))
      r <- qs_result(); ov <- overlap(); sug <- corr_suggest() %||% character(0)
      cutoff <- isolate(input$corr_cutoff) %||% 0.8
      m <- if (is.null(r)) rep(NA_integer_, nrow(res)) else match(res$criterion, r$criterion)
      sig <- if (is.null(r)) rep(FALSE, nrow(res)) else r$significant[m] %in% TRUE
      p <- if (is.null(r)) rep(NA_real_, nrow(res)) else r$p_adj[m]
      ord <- order(!sig, p, -abs(res$gap), na.last = TRUE)
      fmt_p <- function(v) if (is.na(v)) "\u2013" else if (v < 0.0001) "< 0.0001" else sprintf("%.4f", v)
      pct <- function(v) if (is.na(v)) "\u2013" else sprintf("%.0f%%", 100 * v)
      rows <- lapply(ord, function(i) {
        cr <- res$criterion[i]; k <- m[i]
        or_cell <- if (is.na(k) || is.na(r$or[k])) "\u2013" else
          tags$span(title = sprintf("95%% CI %s\u2013%s", fmt_ratio(r$or_low[k]), fmt_ratio(r$or_high[k])), fmt_ratio(r$or[k]))
        p_cell <- if (is.na(k)) "\u2013" else if (sig[i])
          tags$strong(if (identical(r$direction[k], "inclusion")) "\u2191 " else "\u2193 ", fmt_p(p[i]))
        else if (r$test[k] %in% c("constant", "not binary")) tags$span(class = "text-muted", "not testable")
        else tags$span(class = "text-muted", fmt_p(p[i]))
        o <- if (is.null(ov)) NULL else ov[ov$criterion == cr, , drop = FALSE]
        ov_cell <- if (cr %in% names(sug)) tags$span(class = "text-danger", sprintf("repeats %s%s", sug[[cr]],
                                                                                  if (NROW(o) && !is.na(o$r[1])) sprintf(" (r = %.2f)", o$r[1]) else ""))
          else if (!NROW(o) || is.na(o$r[1])) "\u2013"
          else tags$span(class = if (o$r[1] >= cutoff) "text-danger" else "text-muted", sprintf("%s (%.2f)", o$with[1], o$r[1]))
        tags$tr(
          tags$td(class = "text-center", checkboxInput(ns(use_id(cr)), NULL, value = isTRUE(res$retained[i]))),
          tags$td(class = "tw-var", tags$strong(cr)),
          tags$td(class = "num", pct(res$prev_vuln[i])),
          tags$td(class = "num", pct(res$prev_not[i])),
          tags$td(class = "num", or_cell),
          tags$td(class = "num", p_cell),
          tags$td(class = "small", ov_cell),
          tags$td(class = "num", sprintf("%.0f%%", 100 * res$missing[i])))
      })
      if (no_outcome()) {
        # no outcome: the share of households meeting each criterion instead
        rows <- lapply(ord, function(i) {
          cr <- res$criterion[i]
          o <- if (is.null(ov)) NULL else ov[ov$criterion == cr, , drop = FALSE]
          ov_cell <- if (cr %in% names(sug)) tags$span(class = "text-danger", sprintf("repeats %s", sug[[cr]]))
            else if (!NROW(o) || is.na(o$r[1])) "\u2013"
            else tags$span(class = if (o$r[1] >= cutoff) "text-danger" else "text-muted", sprintf("%s (%.2f)", o$with[1], o$r[1]))
          tags$tr(
            tags$td(class = "text-center", checkboxInput(ns(use_id(cr)), NULL, value = isTRUE(res$retained[i]))),
            tags$td(class = "tw-var", tags$strong(cr)),
            tags$td(class = "num", pct(res$prevalence[i])),
            tags$td(class = "small", ov_cell),
            tags$td(class = "num", sprintf("%.0f%%", 100 * res$missing[i])))
        })
        return(tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(tags$th(class = "text-center", "Use"), tags$th("Variable"), tags$th(class = "num", "Households yes"),
                             tags$th("Overlaps with"), tags$th(class = "num", "Missing"))),
          tags$tbody(rows))))
      }
      tags$div(class = "wfp-model-table-wrap", tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(
          tags$th(class = "text-center", "Use"), tags$th("Variable"),
          tags$th(class = "num", "Among vulnerable"), tags$th(class = "num", "Among others"),
          tags$th(class = "num", "Odds ratio"), tags$th(class = "num", "Adjusted p"), tags$th("Overlaps with"),
          tags$th(class = "num", "Missing"))),
        tags$tbody(rows)))
    })
    output$criteria_strip <- renderUI({
      res <- screened(); req(res)
      r <- qs_result()
      tags$div(class = "wfp-stat-strip",
               tags$span(tags$strong(nrow(res)), " variables"),
               tags$span(tags$strong(if (is.null(r)) 0 else sum(r$significant, na.rm = TRUE)), " associated"),
               tags$span(tags$strong(length(corr_suggest() %||% character(0))), " repeating another"),
               tags$span(tags$strong(sum(use_now())), " ticked"))
    })

    # Correlations of the ticked variables, in a dialog run only when asked:
    # the groups correlated above the cut-off and which member of each to
    # remove (proposed, editable), not the whole matrix.
    corr_groups <- reactiveVal(NULL)
    corr_request <- reactiveVal(NULL)   # the threshold asked for, once Find is clicked
    observeEvent(input$open_corr, {
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

    output$effects_ui <- renderUI({
      eff <- effects()
      if (is.null(fitted()) || is.null(eff) || !is.null(index_method())) return(NULL)
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
    output$params_summary <- renderUI({
      m <- input$model_method
      txt <- c(
        if (!no_outcome()) sprintf("Hold-out %s%%, seed %s", model_params$holdout_pct, model_params$split_seed),
        if (has_axes(m)) {
          if (identical(model_params$pca_mode, "var")) sprintf("axes: the fewest explaining %s%% of the variation", model_params$pca_min_var)
          else sprintf("%d axis(es) kept", as.integer(model_params$pca_axes))
        },
        if (isTRUE(m %in% cluster_methods()))
          sprintf("%s, seed %s", if (isTRUE(model_params$auto_k)) "profiles chosen by silhouette" else sprintf("%d profiles", as.integer(model_params$n_clusters)),
                  model_params$split_seed),
        if (!no_outcome() && isTRUE(m %in% tunable_models()) && isTRUE(model_params$tune)) sprintf("tuned by %d-fold cross-validation", as.integer(model_params$folds)),
        if (isTRUE(m %in% diagram_models()) && isFALSE(model_params$diagram)) "no diagram")
      if (!length(txt)) return(NULL)
      txt <- paste(txt, collapse = " \u00b7 ")
      tags$div(class = "small text-muted wfp-params-line", bsicons::bs_icon("sliders"), " ", txt, " \u00b7 ",
               actionLink(ns("model_params2"), "change"))
    })
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
    observeEvent(input$model_params, show_params())
    observeEvent(input$model_params2, show_params())
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

    output$runs_ui <- renderUI({
      rl <- runs()
      if (length(rl) < 1) return(NULL)
      best <- which.max(vapply(rl, function(r) r$auc %||% NA_real_, numeric(1)))
      rows <- lapply(rev(rl), function(r) {
        cur <- isTRUE(r$id == current_run())
        tags$tr(
          class = paste(if (cur) "is-current" else "", if (isTRUE(r$id == best)) "is-best" else ""),
          tags$td(tags$strong(paste0("#", r$id)), tags$span(class = "text-muted small ms-1", r$at)),
          tags$td(model_label(r$settings$method)),
          tags$td(if (isTRUE(r$settings$unsupervised)) "ranking" else scheme_label(r$settings$scheme, r$settings$method)),
          tags$td(class = "num", nrow(r$fit$weights)),
          tags$td(class = "num", if (is.na(r$auc %||% NA)) tags$span(class = "text-muted", "\u2013 no outcome") else
                  tagList(tags$strong(sprintf("%.3f", r$auc)),
                          tags$span(class = "text-muted small", if (r$held_out) " held out" else " training"))),
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
                     sprintf(W("Run history (%d fit%s) \u2014 scorecard AUC; best highlighted"),
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

    # Changing the scheme after fitting re-derives the points from the same
    # coefficients; no refit needed.
    output$scheme_apply_ui <- renderUI({
      f <- fitted()
      if (is.null(f) || identical(f$scheme, input$model_scheme) || isTRUE(f$method %in% c("pca", "lda")) ||
          identical(f$scheme, "pmt") || isTRUE(f$unsupervised)) return(NULL)
      actionLink(ns("scheme_apply"), "Apply this scheme to the fitted model")
    })
    observeEvent(input$scheme_apply, {
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

    output$fit_note <- renderUI({
      f <- fitted()
      if (is.null(f)) return(NULL)
      tn <- f$tuning; kq <- f$index$k_quality
      tagList(
        if (!is.null(tn)) tags$div(class = "small text-muted", bsicons::bs_icon("sliders"),
          sprintf(" Tuned by %d-fold cross-validation on %s training households: %s (cross-validated AUC %.3f). ",
                  tn$folds, format(tn$n, big.mark = ","), paste(sprintf("%s = %s", names(tn$best), vapply(tn$best, function(v) format(signif(v, 3)), character(1))), collapse = ", "), tn$best_auc),
          actionLink(ns("show_tuning"), "See the grid")),
        if (!is.null(kq)) tags$div(class = "small text-muted", bsicons::bs_icon("sliders"),
          sprintf(" Number of profiles chosen automatically: %d (best silhouette %.2f among 2 to 8).", f$index$k, max(kq$silhouette, na.rm = TRUE))),
        tags$span(
          class = "text-muted small",
          sprintf("%s, fitted on %s households%s; %d criteria kept.",
                  model_label(f$method),
                  format(f$n, big.mark = ","),
                  if (length(split_state()$test))
                    sprintf(", %s held out for evaluation", format(length(split_state()$test), big.mark = ","))
                  else "",
                  nrow(f$weights))
        ),
        # Missing criterion answers count as "no", in the model as in the score.
        if (length(f$filled)) tags$div(
          class = "small text-muted",
          bsicons::bs_icon("info-circle"), if (!is.null(f$pmt)) " Missing answers counted as 'no', missing numbers as the average (as in the score): "
                                           else " Missing answers counted as 'no' (as in the score): ",
          paste(sprintf("%s (%s)", names(f$filled), format(f$filled, big.mark = ",")), collapse = ", "), "."),
        if (length(f$dropped)) {
          tags$div(class = "small text-muted",
                   bsicons::bs_icon("scissors"),
                   " Removed by stepwise selection (no information once the others are known): ",
                   paste(f$dropped, collapse = ", "))
        },
        if (!is.null(f$index)) index_note(f$index),
        if (!is.null(f$pmt)) pmt_fit_html(f$pmt),
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
        return(empty_state("No model yet", "Set the model above, then click Fit model.",
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
      tagList(
        tags$div(class = "d-flex justify-content-between align-items-center mb-2 gap-2",
                 tags$span(class = "small fw-bold text-uppercase", bsicons::bs_icon("table"), " Model estimates"),
                 tags$div(class = "d-flex gap-2 align-items-center",
                          uiOutput(ns("points_stale"), inline = TRUE),
                          actionButton(ns("apply_points"), "Apply points", icon = icon("check"), class = "btn-primary btn-sm"),
                          actionButton(ns("reset_weights"), "Reset to model values",
                                       icon = icon("rotate-left"), class = "btn-outline-secondary btn-sm"),
                          downloadButton(ns("dl_model_tables2"), "Export (Excel)",
                                         class = "btn-outline-primary btn-sm"))),
        coefficients_html(wts, f$model, points = points, pmt = !is.null(f$pmt)),
        tags$div(
          class = "small text-muted mt-2",
          bsicons::bs_icon("info-circle"),
          " Every criterion here is observable at registration and not an outcome indicator (Targeting Advisory 1/2025);",
          " validate them with the community before implementation."
        )
      )
    })

    observeEvent(input$apply_points, {
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
    output$points_stale <- renderUI({
      f <- fitted(); req(f)
      w <- current_weights()$weight
      v <- vapply(seq_along(w), function(i) { x <- input[[paste0("w_", i)]]; if (is.null(x) || is.na(x)) w[i] else as.numeric(x) }, numeric(1))
      if (all(abs(v - w) < 1e-9)) return(NULL)
      tags$span(class = "small text-warning", bsicons::bs_icon("exclamation-circle"), " Points edited: click Apply points.")
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
    # The decision tree's leaves, most vulnerable first
    output$tree_ui <- renderUI({
      f <- fitted(); rl <- f$tree_rules
      if (!identical(f$method, "tree") || is.null(rl) || !nrow(rl)) return(NULL)
      nof <- isTRUE(f$unsupervised)
      bslib::card(
        class = "mt-3",
        bslib::card_header(bsicons::bs_icon("diagram-2"), " Decision tree: the rules",
                           info_tip(if (nof) "Each row is a leaf of the tree: the answers that lead to it, how many households it holds and the share of them in the targeted profiles. The points of the ranking are the tree's average effects, so it stays additive; the rules show what the tree itself does."
                                    else "Each row is a leaf of the tree: the answers that lead to it, how many training households it holds and the share of them that is vulnerable. The points of the card are the tree's average effects, so the card stays additive; the rules show what the tree itself does.")),
        bslib::card_body(
          tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(tags$th("If the household..."), tags$th(class = "num", "Households"), tags$th(class = "num", if (nof) "In targeted profiles" else "Vulnerable"))),
          tags$tbody(lapply(seq_len(nrow(rl)), function(i) tags$tr(
            tags$td(class = "small", rl$rule[i]), tags$td(class = "num", format(rl$households[i], big.mark = ",")),
            tags$td(class = "num", tags$strong(sprintf("%.0f%%", 100 * rl$share_vulnerable[i]))))))))))
    })
    # The model's diagram where one is standard (tree, forest plot, network,
    # importance, dendrogram); switched off in the model settings
    output$diagram_ui <- renderUI({
      f <- fitted(); d <- f$diagram
      if (is.null(d) || isFALSE(model_params$diagram)) return(NULL)
      nof <- isTRUE(f$unsupervised)
      svg <- diagram_svg(d, if (nof) "targeted" else "vulnerable")
      if (!nzchar(svg)) return(NULL)
      bslib::card(
        class = "mt-3",
        bslib::card_header(bsicons::bs_icon("diagram-3"), paste0(" ", diagram_title(d$kind)), info_tip(diagram_help(d$kind, nof))),
        bslib::card_body(HTML(svg)))
    })

    output$weights_charts <- renderUI({
      if (is.null(fitted())) return(NULL)
      im <- index_method()
      if (!is.null(fitted()$pmt)) {
        pchart <- function(icon_name, title, id, h = "400px") bslib::card(
          bslib::card_header(bsicons::bs_icon(icon_name), title, chart_help(id)),
          plotly::plotlyOutput(ns(id), height = h))
        return(tagList(
          tags$hr(),
          bslib::layout_columns(
            col_widths = c(6, 6),
            pchart("arrow-left-right", " Points and direction", "weights_plot", "440px"),
            pchart("bullseye", " Predicted against measured welfare", "pmt_fit_plot", "440px")),
          bslib::layout_columns(
            col_widths = c(4, 4, 4),
            pchart("bar-chart", " Selected by decile of measured welfare", "pmt_decile_plot"),
            pchart("graph-down", " Leakage and under-coverage as the cut-off moves", "pmt_curve_plot"),
            pchart("distribute-vertical", " Prediction errors (residuals)", "pmt_resid_plot"))))
      }
      chart <- function(icon_name, title, id) bslib::card(
        bslib::card_header(bsicons::bs_icon(icon_name), title, chart_help(id)),
        plotly::plotlyOutput(ns(id), height = "480px"))
      if (identical(im, "pca")) return(tagList(tags$hr(), bslib::layout_columns(
        col_widths = c(4, 4, 4),
        chart("arrow-left-right", " Weight and direction", "weights_plot"),
        chart("bar-chart-steps", " Variation explained by each axis", "pca_scree"),
        chart("diagram-3", " Loadings on the axes kept", "pca_loadings")),
        bslib::layout_columns(
          col_widths = c(6, 6),
          chart("bullseye", " Variables: correlation circle, axes 1 and 2", "pca_var_map"),
          chart("people", " Households on axes 1 and 2", "pca_ind_map"))))
      if (identical(im, "mca")) return(tagList(tags$hr(), bslib::layout_columns(
        col_widths = c(4, 4, 4),
        chart("arrow-left-right", " Weight and direction", "weights_plot"),
        chart("bar-chart-steps", " Variation explained by each axis", "pca_scree"),
        chart("diagram-3", " Weights on the axes kept", "pca_loadings")),
        bslib::layout_columns(col_widths = c(12), chart("people", " Households on the first two components", "unsup_map"))))
      if (identical(im, "count")) return(tagList(tags$hr(), bslib::layout_columns(
        col_widths = c(4, 4, 4),
        chart("arrow-left-right", " Weight of each deprivation", "weights_plot"),
        chart("bar-chart", " Weighted deprivations per household", "dep_count_plot"),
        chart("people", " Households on the first two components", "unsup_map"))))
      if (isTRUE(im %in% cluster_methods())) return(tagList(tags$hr(),
        uiOutput(ns("cluster_ui")),
        bslib::layout_columns(
          col_widths = c(4, 4, 4),
          chart("people", " Households by profile, first two components", "unsup_map"),
          chart("grid-3x3", " Profiles: share of households meeting each criterion", "cluster_plot"),
          chart("arrow-left-right", " Points that reproduce the targeted profiles", "weights_plot"))))
      if (identical(im, "lda")) return(tagList(tags$hr(), bslib::layout_columns(
        col_widths = c(4, 4, 4),
        chart("arrow-left-right", " Weight and direction", "weights_plot"),
        chart("percent", " How common each criterion is", "prevalence_plot"),
        chart("distribute-vertical", " Index by group", "lda_scores")),
        bslib::layout_columns(
          col_widths = c(6, 6),
          chart("bullseye", " Variables: correlation of each criterion with the index", "lda_var_map"),
          chart("people", " Households on the index", "lda_ind_map"))))
      tagList(
        tags$hr(),
        bslib::layout_columns(
          col_widths = c(4, 4, 4),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("arrow-left-right"),
                               " Weight and direction", chart_help("weights_plot")),
            plotly::plotlyOutput(ns("weights_plot"), height = "480px")
          ),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("percent"),
                               " How common each criterion is", chart_help("prevalence_plot")),
            plotly::plotlyOutput(ns("prevalence_plot"), height = "480px")
          ),
          # Is each weight robust to the method? Same criterion, four models.
          bslib::card(
            bslib::card_header(bsicons::bs_icon("bullseye"),
                               " Effect by model", chart_help("effects_plot")),
            plotly::plotlyOutput(ns("effects_plot"), height = "480px")
          )
        )
      )
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

    output$pca_scree <- render_wfp_plotly({
      ix <- fitted()$index; req(isTRUE(ix$type %in% c("pca", "mca")))
      ev <- utils::head(ix$eigen, 20)
      d <- data.frame(axis = factor(paste("Axis", seq_along(ev)), levels = paste("Axis", seq_along(ev))),
                      eigen = ev, share = 100 * ev / sum(ix$eigen), kept = seq_along(ev) <= (ix$axes %||% 1))
      d$cum <- 100 * cumsum(ix$eigen)[seq_along(ev)] / sum(ix$eigen)
      plotly::plot_ly(d, x = ~axis, y = ~eigen, type = "bar", name = "Eigenvalue",
                      marker = list(color = ifelse(d$kept, "#0A6EB4", "#b8c4d0")),
                      customdata = ~sprintf("%.1f%%", share),
                      hovertemplate = "%{x}: eigenvalue %{y:.2f}, %{customdata} of the variation<extra></extra>") |>
        # cumulative share explained, on its own axis
        plotly::add_trace(data = d, x = ~axis, y = ~cum, type = "scatter", mode = "lines+markers", yaxis = "y2",
                          name = "Cumulative %", line = list(color = "#c5192d", width = 2), marker = list(color = "#c5192d", size = 6),
                          hovertemplate = "Axes 1 to %{x}: %{y:.1f}% of the variation<extra></extra>", inherit = FALSE) |>
        plotly::layout(xaxis = list(title = "", tickangle = if (nrow(d) > 8) -90 else 0),
                       yaxis2 = list(title = "Cumulative % explained", overlaying = "y", side = "right", range = c(0, 105),
                                     ticksuffix = "%", showgrid = FALSE),
                       legend = list(orientation = "h", x = 0, y = 1.12, xanchor = "left", yanchor = "bottom"),
                       margin = list(r = 60),
                       yaxis = list(title = "Eigenvalue", gridcolor = "rgba(128,128,128,0.2)"),
                       shapes = list(list(type = "line", x0 = -0.5, x1 = nrow(d) - 0.5, y0 = 1, y1 = 1,
                                          line = list(color = "#f7b825", dash = "dash", width = 1.5))),
                       annotations = list(list(x = nrow(d) - 1, y = 1, text = "Kaiser: 1", showarrow = FALSE,
                                               yanchor = "bottom", font = list(size = 11, color = "#f7b825"))))
    })

    # Loadings: how each criterion weighs on each axis kept (turned towards
    # vulnerability, as in the index).
    output$pca_loadings <- render_wfp_plotly({
      ix <- fitted()$index; req(isTRUE(ix$type %in% c("pca", "mca")), !is.null(ix$axis_loadings))
      L <- ix$axis_loadings
      d <- data.frame(criterion = rep(rownames(L), ncol(L)), axis = rep(colnames(L), each = nrow(L)),
                      loading = as.vector(L), stringsAsFactors = FALSE)
      ord <- rownames(L)[order(L[, 1])]
      d$criterion <- factor(d$criterion, levels = ord)
      plotly::plot_ly(d, x = ~loading, y = ~criterion, color = ~axis, type = "bar", orientation = "h",
                      colors = rep_len(c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d"), ncol(L)),
                      hovertemplate = "%{y}, %{fullData.name}: %{x:.2f}<extra></extra>") |>
        plotly::layout(barmode = "group", xaxis = list(title = "Loading", zeroline = TRUE),
                       yaxis = list(title = "", automargin = TRUE), legend = list(orientation = "h", y = -0.12))
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
    output$dep_count_plot <- render_wfp_plotly({
      s <- scored(); req(s$score)
      d <- as.data.frame(table(round(s$score, 2)))
      names(d) <- c("score", "n")
      d$score <- as.numeric(as.character(d$score)); d$pct <- 100 * d$n / sum(d$n)
      t <- thr_applied() %||% 0
      plotly::plot_ly(d, x = ~score, y = ~pct, type = "bar", marker = list(color = ifelse(d$score > t, "#0A6EB4", "#b8c4d0")),
                      customdata = ~n, hovertemplate = "%{x} weighted deprivations<br>%{y:.1f}% of households (%{customdata})<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Weighted deprivations"), yaxis = list(title = "% of households", ticksuffix = "%"),
                       shapes = list(list(type = "line", x0 = t, x1 = t, y0 = 0, y1 = 1, yref = "paper", line = list(color = "#1f2a37", dash = "dash"))))
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
    output$cluster_ui <- renderUI({
      pv <- profile_view(); ix <- pv$ix; pc <- pv$pc
      k <- ix$k; pr <- ix$profiles; ord <- ix$rank; top <- pv$top
      pct <- function(v) sprintf("%.0f%%", 100 * v)
      tint <- function(d) {
        a <- min(abs(d) / 0.4, 1) * 0.55
        if (d >= 0) sprintf("background: rgba(10,110,180,%.2f)", a) else sprintf("background: rgba(247,184,37,%.2f)", a)
      }
      vmax <- max(pc$v[top], 1e-9)
      rank_word <- function(r) if (r == 1) "most vulnerable" else if (r == k) "least vulnerable" else sprintf("rank %d of %d", r, k)
      # which answer a criterion's percentage counts ("Yes", "1 - Oui", TRUE...)
      df <- assessment_df()
      counted <- function(cl) {
        x <- df[[cl]]; if (is.null(x)) return(NA_character_)
        if (is.logical(x)) return("TRUE")
        if (is.numeric(x)) return("1")
        v <- as.character(x); u <- sort(unique(v[!is.na(v) & nzchar(trimws(v))]))
        if (length(u) != 2) return(NA_character_)
        lv <- guess_positive_level(u)
        unname(names(value_choices(lv, cl))[1] %||% lv)
      }
      head_of <- function(j) tags$th(
        class = "num wfp-prof-head",
        checkboxInput(ns(paste0("tgt_", j)), sprintf("Profile %d", j), value = j %in% ix$target),
        tags$div(class = "small fw-normal", sprintf("%s of households", pct(ix$size[j]))),
        tags$div(class = paste("small fw-normal", if (match(j, ord) == 1) "text-danger" else "text-muted"), rank_word(match(j, ord))))
      bslib::card(
        bslib::card_header(bsicons::bs_icon("people"), sprintf(" %d household profiles", k),
                           info_tip("Profiles are ordered from the most to the least vulnerable, judged on the anchor-oriented first component. Rows: the ten criteria that separate the profiles most. Each cell is the share of the profile's households giving the answer named under the criterion, tinted blue above the average household and amber below. Tick the profiles to target, then click Target the ticked profiles: the points are refitted to reproduce them.")),
        bslib::card_body(
          tags$div(class = "wfp-model-table-wrap wfp-prof-wrap", tags$table(
            class = "wfp-model-table wfp-prof-table",
            tags$thead(tags$tr(
              tags$th("Criterion"),
              tags$th("Separates", info_tip(paste(
                "How strongly the criterion tells the profiles apart: Cramer's V of the criterion against profile membership,",
                "from 0 (every profile has the same share) to 1 (the criterion alone says which profile a household is in).",
                "Above about 0.3 the criterion is one of the things that define the profiles; below 0.1 it hardly differs between them."))),
              lapply(ord, head_of),
              tags$th(class = "num", "All", info_tip("The share among all households, for comparison.")))),
            tags$tbody(lapply(top, function(i) tags$tr(
              # the label is written here in full, so the browser's labeller skips the cell (data-tw)
              tags$td(class = "tw-var wfp-prof-var", `data-tw` = "1",
                      tags$strong(rownames(pr)[i]),
                      local({ l <- var_label(rownames(pr)[i]); if (!is.na(l) && nzchar(l)) tags$div(class = "tw-cell-label", l) }),
                      local({ a <- counted(rownames(pr)[i]); if (!is.na(a)) tags$div(class = "small text-muted", sprintf("%% of households answering \u201c%s\u201d", a)) })),
              tags$td(style = "min-width: 120px;", tags$div(class = "d-flex align-items-center gap-2",
                      tags$div(class = "wfp-prof-bar flex-grow-1", tags$span(style = sprintf("width:%.0f%%;background:#0A6EB4", 100 * pc$v[i] / vmax))),
                      tags$span(class = "small", sprintf("%.2f", pc$v[i])))),
              lapply(ord, function(j) tags$td(class = "num", style = tint(pc$diff[i, j]), pct(pr[i, j]))),
              tags$td(class = "num text-muted", pct(pc$overall[i]))))))),
          tags$div(class = "d-flex justify-content-between align-items-center flex-wrap gap-2 mt-2",
                   uiOutput(ns("profile_pick_note"), inline = TRUE),
                   actionButton(ns("cluster_apply"), "Target the ticked profiles", icon = icon("check"), class = "btn-primary btn-sm")),
          tags$div(class = "small mt-2",
                   sprintf("Separation of the profiles (silhouette): %s", if (is.na(ix$silhouette %||% NA)) "n/a" else sprintf("%.2f", ix$silhouette)),
                   if (!is.null(ix$entropy)) sprintf(" \u00b7 classification certainty (entropy): %.2f", ix$entropy),
                   if (!is.null(ix$bic)) sprintf(" \u00b7 BIC: %s", format(round(ix$bic), big.mark = ",")),
                   " ", actionLink(ns("profile_quality"), "Compare 2 to 8 profiles")),
          if (!is.null(ix$fidelity)) tags$div(class = paste("small", if (ix$fidelity < 0.8) "text-warning" else "text-muted"),
            sprintf("The points reproduce the targeted profiles with an AUC of %.2f%s", ix$fidelity,
                    if (ix$fidelity < 0.8) ": the profiles are not a straight cut through the criteria; try another number of profiles or method." else "."))))
    })
    # What the ticks would target (counting only; nothing is refitted)
    output$profile_pick_note <- renderUI({
      pv <- profile_view(); ix <- pv$ix
      pick <- which(vapply(seq_len(ix$k), function(j) isTRUE(input[[paste0("tgt_", j)]] %||% (j %in% ix$target)), logical(1)))
      same <- setequal(pick, ix$target)
      tags$span(class = "small",
                if (!length(pick)) "No profile ticked." else
                  sprintf("Ticked: profile%s %s, %.0f%% of households.", if (length(pick) > 1) "s" else "", paste(pick, collapse = ", "),
                          100 * sum(ix$size[pick])),
                if (!same && length(pick)) tags$span(class = "text-warning", " Click Target the ticked profiles to apply."))
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
    output$unsup_map <- render_wfp_plotly({
      m <- map_data()
      plotly::plot_ly(data.frame(x = m$x, y = m$y, g = m$group), x = ~x, y = ~y, color = ~g, colors = m$pal,
                      type = "scatter", mode = "markers", marker = list(size = 5, opacity = 0.5),
                      hovertemplate = "%{fullData.name}<br>component 1: %{x:.2f}, component 2: %{y:.2f}<extra></extra>") |>
        plotly::layout(xaxis = list(title = m$xlab, zeroline = TRUE),
                       yaxis = list(title = m$ylab, zeroline = TRUE),
                       legend = list(orientation = "h", y = -0.2))
    })
    # How many profiles? Quality for 2 to 8, on evidence.
    observeEvent(input$profile_quality, {
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

    output$cluster_plot <- render_wfp_plotly({
      ix <- fitted()$index; req(identical(ix$type, "cluster"))
      pr <- ix$profiles[, ix$rank, drop = FALSE]
      pr <- pr[order(profile_contrasts(ix$profiles, ix$size, fitted()$n)$v), , drop = FALSE]   # strongest separators on top
      plotly::plot_ly(x = colnames(pr), y = rownames(pr), z = 100 * pr, type = "heatmap",
                      colors = grDevices::colorRamp(c("#f4f7fa", "#0A6EB4")), zmin = 0, zmax = 100,
                      hovertemplate = "%{y}<br>%{x}: %{z:.0f}% meet it<extra></extra>") |>
        plotly::layout(xaxis = list(title = ""), yaxis = list(title = "", automargin = TRUE))
    })
    lab_of <- function(v) { l <- var_label(v); ifelse(is.na(l), v, paste0(v, "<br><i>", l, "</i>")) }

    # PCA correlation circle: each criterion's correlation with axes 1 and 2
    # (its loading); arrows close to the circle are well represented, arrows
    # pointing the same way go together.
    output$pca_var_map <- render_wfp_plotly({
      ix <- fitted()$index; req(identical(ix$type, "pca"), !is.null(ix$map_vectors))
      V <- ix$map_vectors
      co <- sweep(V, 2, sqrt(ix$eigen[seq_len(ncol(V))]), "*")
      d <- data.frame(criterion = ix$criteria, x = co[, 1], y = if (ncol(co) > 1) co[, 2] else 0)
      th <- seq(0, 2 * pi, length.out = 121)
      arrows <- lapply(seq_len(nrow(d)), function(i) list(x = d$x[i], y = d$y[i], ax = 0, ay = 0, xref = "x", yref = "y",
                                                         axref = "x", ayref = "y", text = "", showarrow = TRUE,
                                                         arrowhead = 2, arrowsize = 1, arrowwidth = 1.4, arrowcolor = "#0A6EB4"))
      share <- function(j) sprintf("Axis %d (%.0f%%)", j, 100 * ix$eigen[j] / sum(ix$eigen))
      plotly::plot_ly() |>
        plotly::add_trace(x = cos(th), y = sin(th), type = "scatter", mode = "lines", hoverinfo = "skip",
                          line = list(color = "rgba(128,128,128,0.45)", width = 1), showlegend = FALSE) |>
        plotly::add_trace(data = d, x = ~x, y = ~y, type = "scatter", mode = "markers+text", text = ~criterion,
                          textposition = "top center", textfont = list(size = 10), marker = list(size = 6, color = "#0A6EB4"),
                          customdata = lab_of(d$criterion), showlegend = FALSE,
                          hovertemplate = "%{customdata}<br>axis 1: %{x:.2f}, axis 2: %{y:.2f}<extra></extra>") |>
        plotly::layout(annotations = arrows,
                       xaxis = list(title = share(1), range = c(-1.15, 1.15), zeroline = TRUE, scaleanchor = "y"),
                       yaxis = list(title = if (length(ix$eigen) > 1) share(2) else "", range = c(-1.15, 1.15), zeroline = TRUE))
    })

    # Households on the first two axes, by vulnerability. Yes/no criteria put
    # many households on the same point: a small jitter shows how many.
    output$pca_ind_map <- render_wfp_plotly({
      pts <- index_points(); req(identical(pts$type, "pca"))
      set.seed(2)
      jit <- function(v) v + stats::runif(length(v), -0.06, 0.06)
      d <- data.frame(x = jit(pts$x), y = jit(pts$y), group = pts$group)
      plotly::plot_ly(d, x = ~x, y = ~y, color = ~group, colors = grp_cols, type = "scatter", mode = "markers",
                      marker = list(size = 5, opacity = 0.45),
                      hovertemplate = "%{fullData.name}<br>axis 1: %{x:.2f}, axis 2: %{y:.2f}<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Axis 1 (towards vulnerability)", zeroline = TRUE),
                       yaxis = list(title = "Axis 2", zeroline = TRUE), legend = list(orientation = "h", y = -0.15))
    })

    # LDA structure correlations: how much each criterion moves with the index
    # (the usual way to read which criteria the discriminant rests on).
    output$lda_var_map <- render_wfp_plotly({
      pts <- index_points(); req(identical(pts$type, "lda"))
      r <- vapply(colnames(pts$M), function(cl) {
        v <- pts$M[, cl]; if (stats::sd(v) == 0 || stats::sd(pts$x) == 0) NA_real_ else stats::cor(v, pts$x)
      }, numeric(1))
      d <- data.frame(criterion = names(r), r = unname(r))
      d <- d[order(d$r), , drop = FALSE]
      d$criterion <- factor(d$criterion, levels = d$criterion)
      plotly::plot_ly(d, x = ~r, y = ~criterion, type = "bar", orientation = "h",
                      marker = list(color = ifelse(d$r >= 0, "#0A6EB4", "#c5192d")),
                      customdata = lab_of(as.character(d$criterion)),
                      hovertemplate = "%{customdata}<br>correlation with the index: %{x:.2f}<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Correlation with the index", range = c(-1, 1), zeroline = TRUE),
                       yaxis = list(title = "", automargin = TRUE))
    })

    # Households on the index, one dot each, by group.
    output$lda_ind_map <- render_wfp_plotly({
      pts <- index_points(); req(identical(pts$type, "lda"))
      d <- data.frame(score = pts$x, group = pts$group)
      plotly::plot_ly(d, x = ~score, y = ~group, color = ~group, colors = grp_cols, type = "box",
                      boxpoints = "all", jitter = 0.5, pointpos = 0, marker = list(size = 4, opacity = 0.45),
                      hoverinfo = "x") |>
        plotly::layout(xaxis = list(title = "Index"), yaxis = list(title = ""), showlegend = FALSE)
    })

    # LDA: the index of vulnerable and other households side by side; the less
    # the two overlap, the better the index separates them.
    output$lda_scores <- render_wfp_plotly({
      f <- fitted(); req(identical(f$index$type, "lda"))
      df <- assessment_df(); y <- outcome_binary()
      req(df, length(y) == nrow(df))
      sc <- apply_scorecard(df, build_scorecard(f$weights))$score
      ok <- !is.na(sc) & !is.na(y)
      mirrored_hist_plot(sc[ok], y[ok] == 1, NULL, "Index")
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

      d$value <- d$signed
      d$hover <- sprintf("%s<br>%s<br>weight %.2f%s", d$criterion, d$direction, abs(d$signed),
                         ifelse(is.na(d$or), "", sprintf(" (OR %.2f)", d$or)))
      lollipop_plot(d, "Points (+ / -)")
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
    output$pmt_fit_plot <- render_wfp_plotly({
      f <- fitted()$pmt; req(f)
      d <- pmt_eval_sample(f); req(nrow(d) > 0); ll <- f$log_line
      d$cell <- ifelse(d$actual <= ll, ifelse(d$predicted <= ll, "Poor, predicted poor", "Poor, predicted not poor (exclusion)"),
                       ifelse(d$predicted <= ll, "Not poor, predicted poor (inclusion)", "Not poor, predicted not poor"))
      rng <- range(c(d$actual, d$predicted), na.rm = TRUE)
      plotly::plot_ly(d, x = ~actual, y = ~predicted, color = ~cell, type = "scattergl", mode = "markers",
                      colors = c("Poor, predicted poor" = "#0A6EB4", "Poor, predicted not poor (exclusion)" = "#c5192d",
                                 "Not poor, predicted poor (inclusion)" = "#f7b825", "Not poor, predicted not poor" = "#9aa5b1"),
                      marker = list(size = 5, opacity = 0.6),
                      hovertemplate = "measured %{x:.2f}<br>predicted %{y:.2f}<extra>%{fullData.name}</extra>") |>
        plotly::layout(
          xaxis = list(title = "Measured log welfare per person"), yaxis = list(title = "Predicted log welfare per person"),
          legend = list(orientation = "h", x = 0, y = 1.14, xanchor = "left", yanchor = "bottom"),
          shapes = list(
            list(type = "line", x0 = rng[1], x1 = rng[2], y0 = rng[1], y1 = rng[2], line = list(color = "rgba(128,128,128,0.6)", dash = "dot")),
            list(type = "line", x0 = ll, x1 = ll, y0 = 0, y1 = 1, yref = "paper", line = list(color = "#1f2a37", dash = "dash")),
            list(type = "line", y0 = ll, y1 = ll, x0 = 0, x1 = 1, xref = "paper", line = list(color = "#1f2a37", dash = "dash"))))
    })

    # Share selected in each decile of measured welfare, at the current
    # cut-off: a PMT should select most of the bottom deciles and few of the top.
    output$pmt_decile_plot <- render_wfp_plotly({
      f <- fitted()$pmt; req(f, NROW(f$eval) > 0)
      d <- pmt_decile_coverage(f$eval, pmt_cut(f))
      d$label <- paste0("D", d$decile)
      poor_dec <- ceiling(10 * f$headcount)
      plotly::plot_ly(d, x = ~label, y = ~ 100 * selected, type = "bar",
                      marker = list(color = ifelse(d$decile <= poor_dec, "#0A6EB4", "#9aa5b1")),
                      hovertemplate = "%{x}: %{y:.0f}% selected<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Decile of measured welfare per person (D1 poorest)", categoryorder = "array", categoryarray = d$label),
                       yaxis = list(title = "Selected (%)", range = c(0, 100)))
    })
    # Leakage and under-coverage for every cut-off from half to twice the
    # line, the current one marked.
    output$pmt_curve_plot <- render_wfp_plotly({
      f <- fitted()$pmt; req(f, NROW(f$eval) > 0)
      d <- pmt_error_curve(f$eval, f$log_line)
      now <- 100 * exp(pmt_cut(f) - f$log_line)
      plotly::plot_ly(d, x = ~ 100 * mult) |>
        plotly::add_lines(y = ~ 100 * inclusion_error, name = "Inclusion error (leakage)", line = list(color = "#f7b825", width = 3)) |>
        plotly::add_lines(y = ~ 100 * exclusion_error, name = "Exclusion error (under-coverage)", line = list(color = "#c5192d", width = 3)) |>
        plotly::layout(xaxis = list(title = "Cut-off (% of the poverty line)"), yaxis = list(title = "Error (%)", range = c(0, 100)),
                       legend = list(orientation = "h", x = 0, y = 1.14, xanchor = "left", yanchor = "bottom"),
                       shapes = list(list(type = "line", x0 = now, x1 = now, y0 = 0, y1 = 1, yref = "paper",
                                          line = list(color = "#1f2a37", dash = "dash"))))
    })
    # Residuals against predicted welfare: a cloud centred on zero at every
    # level; a slope means the poorest are predicted too well-off.
    output$pmt_resid_plot <- render_wfp_plotly({
      f <- fitted()$pmt; req(f)
      d <- pmt_eval_sample(f); req(nrow(d) > 0)
      d$resid <- d$actual - d$predicted
      plotly::plot_ly(d, x = ~predicted, y = ~resid, type = "scattergl", mode = "markers",
                      marker = list(size = 4, opacity = 0.5, color = "#0A6EB4"),
                      hovertemplate = "predicted %{x:.2f}<br>residual %{y:+.2f}<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Predicted log welfare per person"), yaxis = list(title = "Measured - predicted"),
                       shapes = list(list(type = "line", x0 = 0, x1 = 1, xref = "paper", y0 = 0, y1 = 0,
                                          line = list(color = "#1f2a37", dash = "dash")),
                                     list(type = "line", x0 = f$log_line, x1 = f$log_line, y0 = 0, y1 = 1, yref = "paper",
                                          line = list(color = "#c5192d", dash = "dot"))))
    })
    # Each compared model's trade-off: leakage against under-coverage as the
    # cut-off moves; the curve nearest the bottom-left corner is best.
    output$pmt_compare_plot <- render_wfp_plotly({
      b <- bench(); req(isTRUE(b$pmt), length(b$curves) > 1)
      cols <- c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#6c757d")
      p <- plotly::plot_ly()
      for (k in seq_along(b$curves)) {
        d <- b$curves[[k]]
        p <- plotly::add_lines(p, data = d, x = ~ 100 * inclusion_error, y = ~ 100 * exclusion_error, name = names(b$curves)[k],
                               line = list(color = cols[(k - 1) %% length(cols) + 1], width = 2.5),
                               text = ~ sprintf("cut-off %.0f%% of the line", 100 * mult),
                               hovertemplate = "%{text}<br>leakage %{x:.1f}%<br>under-coverage %{y:.1f}%<extra>%{fullData.name}</extra>")
      }
      plotly::layout(p, xaxis = list(title = "Inclusion error, leakage (%)", range = c(0, 100)),
                     yaxis = list(title = "Exclusion error, under-coverage (%)", range = c(0, 100)),
                     legend = list(orientation = "h", x = 0, y = 1.18, xanchor = "left", yanchor = "bottom"))
    })
    # The PMT accuracy measures at the current threshold (threshold step).
    pmt_acc_now <- reactive({
      req(pmt(), fitted()$pmt)
      s <- scored(); y <- outcome_binary(); r <- eval_rows()
      req(length(s$eligible) == length(y))
      pmt_accuracy(s$eligible[r], y[r] == 1)
    })
    output$pmt_accuracy_ui <- renderUI(pmt_accuracy_html(pmt_acc_now(), fitted()$pmt, pmt_cut(fitted()$pmt)))

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

    # Model comparison: the models chosen in "Models to compare", each scored
    # as the sum of its effects, next to the scorecard, on the same held-out
    # households.
    output$comparison_ui <- renderUI({
      if (is.null(fitted()) || isTRUE(fitted()$unsupervised)) return(NULL)
      if (!is.null(fitted()$pmt)) {
        b <- bench()
        if (is.null(b$table) || nrow(b$table) < 2) return(tagList(tags$hr(), bslib::card(
          bslib::card_header(bsicons::bs_icon("trophy"), " PMT model comparison"),
          empty_state("No comparison yet", "Choose other models in \u201cModels to compare\u201d above and fit again.", icon = "trophy"))))
        return(tagList(tags$hr(), bslib::layout_columns(
          col_widths = c(7, 5),
          bslib::card(bslib::card_header(bsicons::bs_icon("trophy"), " PMT model comparison"),
                      pmt_compare_html(b$table),
                      tags$div(class = "small text-muted p-2",
                               "Measured on the held-out households with the cut-off at the poverty line. The best held-out R\u00b2 is marked;",
                               " a model with a lower R\u00b2 can still have lower under-coverage (quantile regression usually does).")),
          bslib::card(bslib::card_header(bsicons::bs_icon("graph-down"), " Error trade-off by model", chart_help("pmt_compare_plot")),
                      plotly::plotlyOutput(ns("pmt_compare_plot"), height = "360px")))))
      }
      b <- bench()
      why <- if (is.null(b)) "Choose models in \u201cModels to compare\u201d above and fit again."
             else if (!is.null(b$error)) paste("The models could not be compared:", b$error)
             else if (nrow(b$table) == 0) "None of the compared models could be fitted on these data."
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
                     "AUC on the held-out households is the honest figure. Each model is scored as the sum of its effects;",
                     " if the machine-learning models barely beat the logistic one, more complex models are not needed. The",
                     " gap between a model and the scorecard is the price of the weighting scheme and of flooring scores at zero.")
          ),
          bslib::card(
            bslib::card_header(bsicons::bs_icon("graph-up"), " ROC, held-out households", chart_help("comparison_roc")),
            plotly::plotlyOutput(ns("comparison_roc"), height = "340px")
          )
        )
      )
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

    output$comparison_table <- renderUI(comparison_html(live_bench()$table))

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
        rl <- runs()
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
            weights = input$model_weights, dropped = f$dropped, converged = f$converged,
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
    output$threshold_ui <- renderUI({
      mx <- score_max(); mn <- score_min()
      v <- isolate(thr_pending() %||% thr_applied()) %||% 0
      sliderInput(ns("threshold"),
                  tagList("Eligible when score is above", info_tip("Households scoring strictly above this value are eligible. Moving it trades inclusion error against exclusion error.")),
                  min = mn, max = mx, value = min(max(mn, v), mx),
                  step = 0.0001, ticks = FALSE, width = "100%")
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
      t <- suppressWarnings(as.numeric(input$threshold))
      lo <- suppressWarnings(as.numeric(input$tol_lower %||% tol_applied()[1])); up <- suppressWarnings(as.numeric(input$tol_upper %||% tol_applied()[2]))
      need_ok(length(t) == 1 && is.finite(t), "Set the threshold first.")
      need_ok(isTRUE(is.finite(lo) && is.finite(up) && lo >= 0 && up > lo && up < 50),
              "The tolerance band needs a lower bound below the upper one, and an upper bound below 50%.")
      thr_applied(t); tol_applied(c(lo, up))
    })
    output$thr_stale <- renderUI({
      t <- suppressWarnings(as.numeric(input$threshold)); a <- thr_applied()
      tol_now <- c(suppressWarnings(as.numeric(input$tol_lower %||% tol_applied()[1])), suppressWarnings(as.numeric(input$tol_upper %||% tol_applied()[2])))
      same_t <- length(t) == 1 && !is.null(a) && isTRUE(all.equal(t, a))
      if (same_t && isTRUE(all.equal(tol_now, tol_applied()))) return(NULL)
      tags$span(class = "small text-warning", bsicons::bs_icon("exclamation-circle"),
                " Threshold or tolerance changed: click Apply to update the errors and charts.")
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
    output$stability_ui <- renderUI({
      st <- stability()
      tagList(
        if (is.null(st)) tags$div(class = "small text-muted mb-2", "Refits the design on 20 resamples of the households and compares their selections with this one.")
        else tags$div(class = "mb-2",
                      tags$strong(sprintf("%s: %.0f%% agreement", local({ w <- stability_word(st$jaccard); paste0(toupper(substr(w, 1, 1)), substring(w, 2)) }), 100 * st$jaccard)),
                      tags$div(class = "small text-muted", sprintf("Jaccard index of the selections, median of %d refits (10th-90th percentile %.0f%%-%.0f%%), at %.0f%% of households selected%s.",
                                                               st$draws, 100 * st$low, 100 * st$high, 100 * st$share,
                                                               if (is.finite(st$spearman %||% NA)) sprintf("; rank agreement (Spearman) %.2f", st$spearman) else ""))),
        actionButton(ns("run_stability"), if (is.null(st)) "Check stability" else "Check again", icon = icon("shuffle"), class = "btn-outline-primary btn-sm"))
    })
    observeEvent(input$run_stability, {
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
    output$insights_ui <- renderUI({
      si <- sel_insights()
      if (is.null(si)) return(tags$div(class = "small text-muted", "Set a threshold that selects some households."))
      st <- stability()
      tags$ul(
        class = "small mb-0",
        tags$li(tags$strong(sprintf("%.1f times", si$ratio)), sprintf(" as many deprivations among the selected (%.1f of %d criteria) as among the others (%.1f).",
                                                                 si$mean_sel, si$n_criteria, si$mean_not)),
        tags$li(tags$strong(sprintf("%.0f%%", 100 * si$concentration)), sprintf(" of all deprivations are held by the %.0f%% of households selected.", 100 * si$share)),
        tags$li(if (is.null(st) || is.null(st$spearman)) "Rank agreement across resamples: run the stability check."
                else tagList(tags$strong(sprintf("%.2f", st$spearman)),
                             " rank agreement across resamples (Spearman): how far the order of households holds when the data change.")))
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
    output$cov_area_plot <- render_wfp_plotly({
      d <- cov_area_tab(); req(nrow(d))
      overall <- 100 * mean(scored()$eligible %in% TRUE)
      d$area <- factor(d$area, levels = d$area)
      plotly::plot_ly(d, x = ~area, y = ~ 100 * share, type = "bar", marker = list(color = "#0A6EB4"),
                      customdata = ~n, hovertemplate = "%{x}<br>%{y:.1f}% selected of %{customdata} households<extra></extra>") |>
        plotly::layout(xaxis = list(title = "", tickangle = if (nrow(d) > 8) -90 else 0, automargin = TRUE),
                       yaxis = list(title = "% selected", ticksuffix = "%"),
                       shapes = list(list(type = "line", xref = "paper", x0 = 0, x1 = 1, y0 = overall, y1 = overall,
                                          line = list(color = "#1f2a37", dash = "dot"))))
    })

    output$sel_by_met_plot <- render_wfp_plotly({
      s <- scored(); req(ncol(s$detail) > 0)
      met <- rowSums(s$detail != 0, na.rm = TRUE)
      d <- stats::aggregate(list(sel = s$eligible %in% TRUE), list(met = met), function(v) c(n = length(v), p = mean(v)))
      d <- data.frame(met = d$met, n = d$sel[, "n"], p = 100 * d$sel[, "p"])
      plotly::plot_ly(d, x = ~met, y = ~p, type = "bar", marker = list(color = "#0A6EB4"), customdata = ~n,
                      hovertemplate = "%{x} criteria met<br>%{y:.0f}% selected (of %{customdata} households)<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Criteria met by the household", dtick = 1),
                       yaxis = list(title = "% selected", range = c(0, 100), ticksuffix = "%"))
    })

    output$rank_plot <- render_wfp_plotly({
      s <- scored(); req(length(s$score))
      t <- thr_applied() %||% 0
      d <- data.frame(score = s$score[!is.na(s$score)])
      plotly::plot_ly(d, x = ~score, type = "histogram", nbinsx = 30, marker = list(color = "#0A6EB4", line = list(color = "#ffffff", width = 0.5)),
                      hovertemplate = "Score %{x}<br>%{y} households<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Score"), yaxis = list(title = "Households"), bargap = 0.02,
                       shapes = list(list(type = "line", x0 = t, x1 = t, y0 = 0, y1 = 1, yref = "paper", line = list(color = "#1f2a37", dash = "dash"))),
                       annotations = list(list(x = t, y = 1, yref = "paper", text = sprintf(" threshold %s", fmt5(t)), showarrow = FALSE,
                                               xanchor = "left", yanchor = "top", font = list(size = 11))))
    })
    output$sel_prev_plot <- render_wfp_plotly({
      s <- scored(); df <- assessment_df(); f <- fitted(); req(f, df, length(s$eligible) == nrow(df))
      crit <- intersect(f$weights$criterion, names(df))
      el <- s$eligible %in% TRUE
      d <- do.call(rbind, lapply(crit, function(cl) {
        x <- as_binary_criterion(df[[cl]]); x[is.na(x)] <- 0L
        data.frame(criterion = cl, group = c("Selected", "Not selected"),
                   pct = c(100 * mean(x[el] == 1), 100 * mean(x[!el] == 1)))
      }))
      # criteria ordered by the gap between the two groups: what drives the
      # selection comes first; the gap is in the hover
      gap <- stats::setNames(d$pct[d$group == "Selected"] - d$pct[d$group == "Not selected"], crit)
      ord <- names(sort(gap, decreasing = TRUE))
      d$criterion <- factor(d$criterion, levels = ord)
      d$gap <- gap[as.character(d$criterion)]
      many <- length(crit) > 8
      plotly::plot_ly(d, x = ~criterion, y = ~pct, color = ~group, type = "bar",
                      colors = c(Selected = "#0A6EB4", `Not selected` = "#8a96a3"),
                      customdata = ~sprintf("%+.0f", gap),
                      hovertemplate = "%{x}<br>%{fullData.name}: %{y:.1f}% meet it<br>gap %{customdata} points<extra></extra>") |>
        plotly::layout(barmode = "group", bargap = 0.25,
                       xaxis = list(title = "", tickangle = if (many) -90 else 0, automargin = TRUE),
                       yaxis = list(title = "% of households meeting it", range = c(0, 100), ticksuffix = "%"),
                       legend = list(orientation = "h", x = 0, y = 1.1, xanchor = "left", yanchor = "bottom"))
    })
    observeEvent(input$thr_balanced, apply_balanced())
    # A PMT's standard cut-off: predicted welfare per person at the line.
    apply_line <- function() {
      f <- fitted()$pmt; req(f)
      t <- f$threshold_line
      thr_pending(t); set_threshold(t)
      thr_msg(sprintf("Threshold %s: eligible when predicted welfare per person is at or below the poverty line (%s).", fmt5(t), fmt_money(f$line)))
    }
    observeEvent(input$thr_line, apply_line())
    output$pmt_thr_note <- renderUI({
      f <- fitted()$pmt; t <- thr_applied()
      req(f, is.numeric(t))
      w <- pmt_predicted_welfare(t, f$intercept)
      tagList(bsicons::bs_icon("cash-coin"), sprintf(" Eligible when predicted welfare per person is below %s (%.0f%% of the poverty line).",
                                                     fmt_money(w), 100 * w / f$line))
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
      r <- roc()
      need_ok(is.finite(r$youden), "Fit a model first: the Youden point comes from its ROC curve.")
      t <- max(0, r$youden)
      set_threshold(t)
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
    error_gauge <- function(which) {
      e <- errors(); req(e$n > 0)
      lower <- (tol_applied()[1] %||% 5) / 100
      upper <- (tol_applied()[2] %||% 20) / 100
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
        gauge(W("Inclusion error"), e$inclusion_error, e$included_not_in_need, n_elig, "err-incl",
              W("selected but not in need"))
      } else {
        gauge(W("Exclusion error"), e$exclusion_error, e$excluded_in_need, n_vuln, "err-excl",
              W("in need but not selected"))
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
      lower <- (tol_applied()[1] %||% 5) / 100
      upper <- (tol_applied()[2] %||% 20) / 100

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
                        tags$div(class = "wfp-cm-axis", W("Scorecard decision \u2193")),
                        tags$div(class = "wfp-cm-axis", W("Assessment outcome \u2192"))),
                tags$th(class = "wfp-cm-group", colspan = 2,
                        if (pmt()) "Welfare per person: " else "Outcome: ", tags$strong(oc())),
                tags$th(class = "wfp-cm-tot-head", rowspan = 2, "Total")
              ),
              tags$tr(
                tags$th(class = "wfp-cm-col", W("Vulnerable"),
                        tags$div(class = "wfp-cm-sub", opos())),
                tags$th(class = "wfp-cm-col", W("Not vulnerable"))
              )
            ),
            tags$tbody(
              tags$tr(
                tags$th(class = "wfp-cm-rowgroup", rowspan = 2, tags$span(W("Scorecard"))),
                tags$th(class = "wfp-cm-row", W("Eligible"),
                        tags$div(class = "wfp-cm-sub", sprintf("score > %s", fmt5(thr_applied() %||% 0)))),
                cell(e$correctly_included, n_elig, "Correctly included", "ok", "check-circle-fill"),
                cell(e$included_not_in_need, n_elig, W("Inclusion error"), "err-incl", "x-circle-fill"),
                tags$td(class = "wfp-cm-tot", num(n_elig), tags$div(class = "wfp-cm-sub", pct(n_elig, e$n)))
              ),
              tags$tr(
                tags$th(class = "wfp-cm-row", W("Not eligible")),
                cell(e$excluded_in_need, n_not, W("Exclusion error"), "err-excl", "exclamation-circle-fill"),
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
      lower <- (tol_applied()[1] %||% 5) / 100
      upper <- (tol_applied()[2] %||% 20) / 100
      v <- tryCatch(error_verdict(e$inclusion_error, e$exclusion_error, lower, upper),
                    error = function(err) list(level = "invalid",
                                               interpretation = conditionMessage(err),
                                               action = "Lower the upper tolerance below 50%."))
      # Replay the animation only when the verdict changes, not on every
      # nudge of the threshold.
      animate <- !identical(v$level, verdict_seen)
      verdict_seen <<- v$level
      if (pmt()) { v$interpretation <- W(v$interpretation); v$action <- W(v$action) }
      verdict_card(v, animate = animate,
        errors = c(inclusion = e$inclusion_error, exclusion = e$exclusion_error), tolerance = c(lower, upper),
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
      t_now <- thr_applied() %||% 0
      here <- cur[which.min(abs(cur$threshold - t_now)), , drop = FALSE]

      plotly::plot_ly() |>
        plotly::add_lines(x = c(0, 1), y = c(0, 1), line = list(dash = "dash", color = "#9aa5b1"),
                          name = "Random", hoverinfo = "skip") |>
        plotly::add_lines(data = cur, x = ~fpr, y = ~tpr, name = W("Scorecard"),
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
      d <- data.frame(score = s$score, group = grp_of(y), stringsAsFactors = FALSE)
      d <- d[!is.na(d$group) & !is.na(d$score), , drop = FALSE]
      # Mirrored: vulnerable above the axis, not vulnerable below, each as a
      # share of its own group, so neither hides the other.
      mirrored_hist_plot(d$score, y[!is.na(y) & !is.na(s$score)] == 1, thr_applied() %||% 0, W("Scorecard score"), labels = W(c("Vulnerable", "Not vulnerable")))
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

      d$value <- d$share
      d$hover <- sprintf("%s<br>%.1f%% of all points moved", d$criterion, d$share)
      lollipop_plot(d, "Share of points (%)")
    })

    # How many criteria a household meets, eligible against not: if the two
    # distributions overlap heavily the threshold is doing little work.
    # Score by outcome as boxplots, threshold drawn across: how far apart the
    # two groups sit, and how much of each falls on the wrong side.
    output$box_plot <- render_wfp_plotly({
      s <- scored(); y <- outcome_binary()
      req(length(s$score) == length(y))
      d <- data.frame(score = s$score, group = grp_of(y))
      d <- d[!is.na(d$group), , drop = FALSE]
      t <- thr_applied() %||% 0
      plotly::plot_ly(d, y = ~score, x = ~group, color = ~group, type = "box",
                      colors = vn_cols(),
                      boxmean = TRUE, showlegend = FALSE) |>
        plotly::layout(
          xaxis = list(title = ""),
          yaxis = list(title = W("Scorecard score")),
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
        data.frame(criterion = cl, group = W(c("Vulnerable", "Not vulnerable")),
                   pct = c(100 * mean(s$eligible[met & y %in% 1]), 100 * mean(s$eligible[met & y %in% 0])))
      })
      d <- do.call(rbind, rows)
      d$pct[!is.finite(d$pct)] <- NA
      plotly::plot_ly(d, x = ~pct, y = ~criterion, color = ~group, type = "bar", orientation = "h",
                      colors = vn_cols(),
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
        tw_datatable(b, rownames = FALSE, selection = "none",
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
      # The step tabs, in order; the dots carry the same numbers.
      panels <- c(outcome = "Vulnerability Framework", screening = "Criteria",
                  weights = "Model & weights", threshold = "Threshold & errors")
      has_data <- !is.null(assessment_df())
      st <- list(
        list(key = "data", label = "Data", icon = "database", done = has_data, panel = "data",
             todo = "Load the assessment data (file or MODA) on the left."),
        list(key = "outcome", label = panels[["outcome"]],
             done = has_data && (no_outcome() || (pmt() && framework_ready()) || (shiny::isTruthy(input$outcome_col) && shiny::isTruthy(input$outcome_pos))),
             panel = "outcome", todo = "Choose the outcome and the level that means vulnerable, a welfare measure and its poverty line, or build a ranking without one."),
        list(key = "screening", label = panels[["screening"]], done = isTRUE(selection_applied()) && length(ready_criteria()) > 0,
             panel = "screening", todo = "Check the Use ticks (binarise variables or review correlations if needed), then continue to the model."),
        list(key = "weights", label = panels[["weights"]], done = !is.null(fitted()),
             panel = "weights", todo = "Fit the model; iterate until satisfied."),
        list(key = "threshold", label = panels[["threshold"]],
             done = !is.null(fitted()) && !is.null(thr_applied() %||% thr_pending()),
             panel = "threshold", todo = "Set the threshold and check the design errors."),
        list(key = "adopt", label = "Adopted", icon = "patch-check", done = adopted_current(),
             panel = "threshold", todo = "Record the rationale, then adopt the scorecard.")
      )
      keys <- vapply(st, `[[`, character(1), "key")
      todo_i <- which(!vapply(st, `[[`, logical(1), "done"))[1]
      go <- function(panel) if (is.null(panel)) NULL else
        sprintf("Shiny.setInputValue('%s', '%s', {priority:'event'})", ns("flow_go"), panel)
      items <- lapply(seq_along(st), function(i) {
        x <- st[[i]]
        cls <- paste("wfp-flow-step",
                     if (x$done) "is-done" else "",
                     if (identical(x$key, here)) "is-current" else "",
                     if (isTRUE(i == todo_i)) "is-next" else "")
        num <- match(x$key, names(panels))
        tags$button(type = "button", class = cls, onclick = go(x$panel),
                    title = if (identical(x$panel, "data")) "Open the assessment data (sidebar)" else paste("Open", panels[[x$panel]]),
                    tags$span(class = "wfp-flow-dot",
                              if (x$done) bsicons::bs_icon("check-lg")
                              else if (!is.na(num)) as.character(num) else bsicons::bs_icon(x$icon)),
                    tags$span(class = "wfp-flow-label", x$label))
      })
      btn <- function(panel, text, icon_name, cls = "btn-outline-primary") tags$button(
        type = "button", class = paste("btn btn-sm", cls), onclick = go(panel),
        if (identical(icon_name, "arrow-left")) bsicons::bs_icon(icon_name),
        paste(text, if (identical(panel, "data")) "the data" else panels[[panel]]),
        if (!identical(icon_name, "arrow-left")) bsicons::bs_icon(icon_name))
      # Seen from the page the user is on: what this step asks (or that it is
      # done), always a way on to the next page, and a word about an earlier
      # step left unfinished.
      order <- names(panels)
      cur_i <- match(here, order)
      cur <- st[[match(here, keys)]]
      nxt <- if (!is.na(cur_i) && cur_i < length(order)) order[cur_i + 1] else NULL
      status <- if (is.na(todo_i)) {
        tagList(bsicons::bs_icon("check-circle-fill", class = "text-success"),
                sprintf(" Design complete: the %s is adopted and ready for Beneficiary Selection.", if (no_outcome()) "vulnerability ranking" else "scorecard"))
      } else if (isTRUE(cur$done) && identical(here, "threshold")) {
        tagList(tags$strong("On this step: "), st[[length(st)]]$todo)
      } else if (isTRUE(cur$done)) {
        tagList(bsicons::bs_icon("check-circle-fill", class = "text-success"), " This step is done.")
      } else {
        tagList(tags$strong("On this step: "), cur$todo)
      }
      earlier <- if (!is.na(todo_i) && todo_i < match(here, keys)) st[[todo_i]]
      tags$div(
        class = "wfp-flow wfp-flow-slim mb-3",
        tags$div(class = "wfp-flow-row", tags$div(class = "wfp-flow-track", items)),
        tags$div(
          class = "wfp-flow-next",
          tags$span(class = "wfp-flow-status", status),
          if (!is.null(earlier)) tags$span(
            class = "wfp-flow-earlier small text-muted",
            sprintf("%s is not finished.", earlier$label),
            btn(earlier$panel, "Back to", "arrow-left", "btn-link p-0 ms-1 align-baseline")),
          if (!is.null(nxt)) tags$span(class = "ms-auto", if (identical(here, "screening")) {
            # from the criteria table, continuing sends the ticked criteria
            b <- btn(nxt, "Continue to", "arrow-right")
            b$attribs$onclick <- sprintf("Shiny.setInputValue('%s', Date.now(), {priority:'event'})", ns("nav_next_screening"))
            b
          } else btn(nxt, "Continue to", "arrow-right")))
      )
    })

    observeEvent(input$flow_go, {
      if (identical(input$flow_go, "data")) {
        # The data lives in the sidebar: open it and its section.
        bslib::toggle_sidebar("design_sidebar", open = TRUE, session = session)
        bslib::accordion_panel_open("side", "data", session = session)
      } else {
        bslib::nav_select("steps", input$flow_go, session = session)
      }
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
    observeEvent(input$btn_use, adopt_scorecard())
    observeEvent(input$nav_adopt, adopt_scorecard())

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
  })
}
