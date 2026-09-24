#' Beneficiary Selection Module UI
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_ben_selection_ui <- function(id) {
  ns <- NS(id)
  # One numbered block per step of the process. Steps the chosen approach
  # does not use are hidden by their conditionalPanel, and the numbering (a
  # CSS counter) skips them, so what is shown always reads 1, 2, 3...
  step <- function(title, ..., condition = NULL) {
    blk <- tags$section(class = "wfp-sb-step",
                        tags$div(class = "wfp-sb-head", tags$span(class = "wfp-sb-num"), tags$span(title)),
                        ...)
    if (is.null(condition)) blk else conditionalPanel(condition = condition, blk)
  }
  picker <- function(id, label) shinyWidgets::pickerInput(
    inputId = ns(id), label = label, choices = character(0), multiple = TRUE,
    options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE,
                                          selectedTextFormat = "count > 2"))
  tagList(
    bslib::layout_sidebar(
      fillable = FALSE,
      # The sidebar holds the filters only; the design of the selection
      # (approach, rules, score, prioritisation) has its own tab.
      sidebar = bslib::sidebar(
        title = "Filters",
        width = 300,
        class = "wfp-ben-sidebar",
        step("Area",
             picker("ben_admin1", "Admin 1"),
             picker("ben_admin2", "Admin 2"),
             picker("ben_admin3", "Admin 3"),
             condition = approach_js(ns, c("hybrid", "scorecard", "categorical", "community", "geographic"))),
        tags$div(
          class = "wfp-sb-actions",
          tags$div(
            class = "d-flex gap-2",
            actionButton(ns("ben_apply"), "Apply selection", class = "btn-primary btn-sm flex-fill", icon = icon("filter")),
            actionButton(ns("ben_clear"), label = NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm",
                         title = "Clear the selection criteria")),
          actionButton(ns("export_open"), "Export selection (Excel)", icon = icon("download"),
                       class = "btn-outline-primary btn-sm w-100 mt-2"),
          # New criteria built from the registration data (e.g. a dependency
          # ratio), usable at once in the eligibility rules.
          tags$div(class = "mt-2",
                   mod_var_calc_ui(ns("calc"), "Variable calculator", class = "btn-outline-secondary btn-sm w-100"))
        )
      ),
      bslib::layout_columns(
        bslib::value_box(
          title = "Selected households",
          value = textOutput(ns("ben_total")),
          showcase = bsicons::bs_icon("people"),
          theme = "primary"
        ),
        bslib::value_box(
          title = "Selected individuals",
          value = textOutput(ns("ben_indiv")),
          showcase = bsicons::bs_icon("person-lines-fill"),
          theme = "secondary"
        ),
        bslib::value_box(
          title = "Eligible by design",
          value = textOutput(ns("ben_eligible")),
          showcase = bsicons::bs_icon("check2-circle"),
          theme = "info"
        ),
        bslib::value_box(
          title = "Excluded by design",
          value = textOutput(ns("ben_cut")),
          showcase = bsicons::bs_icon("dash-circle"),
          theme = "warning"
        ),
        col_widths = c(3, 3, 3, 3)
      ),
      uiOutput(ns("selection_note")),
      bslib::navset_underline(
        id = ns("ben_tabs"),
        bslib::nav_panel(
          value = "design", title = tagList(bsicons::bs_icon("sliders"), " Selection design"),
          tags$div(
            class = "wfp-design-grid mt-3",
            step("Approach",
                 # The approach decides which of the other steps take part, so the
                 # list produced is the one the approved design describes.
                 selectInput(ns("ben_approach"), NULL, choices = targeting_approach_choices(),
                             selected = "hybrid", width = "100%"),
                 uiOutput(ns("approach_desc")),
                 conditionalPanel(
                   condition = approach_js(ns, "hybrid"),
                   radioButtons(ns("ben_combine"), "Criteria and score combine as",
                                choices = c("Both (criteria AND score)" = "both",
                                            "Either (criteria OR score)" = "either"),
                                selected = "both"))),
            step("Eligibility rules",
                 # The sidebar pickers can only express "this AND this". Real
                 # designs need "(A AND B) OR C".
                 tags$p(class = "small text-muted mb-2", "Combine conditions on any column, e.g. (A and B) or C."),
                 actionButton(ns("btn_rules"), "Edit eligibility rules", icon = icon("sliders"),
                              class = "btn-outline-primary btn-sm"),
                 tags$div(class = "small text-muted mt-2", textOutput(ns("rules_summary"))),
                 condition = approach_js(ns, c("hybrid", "categorical"))),
            step("Score",
                 # A scorecard adopted on the Targeting Design tab is the score
                 # layer; the mapped vulnerability score stands in only when none
                 # is in use.
                 uiOutput(ns("scorecard_ui")),
                 conditionalPanel(
                   condition = sprintf("!input['%s']", ns("use_scorecard")),
                   sliderInput(ns("ben_score_min"), "Minimum vulnerability score", min = 0, max = 100, value = 0, width = "100%"),
                   sliderInput(ns("ben_score_max"), "Maximum vulnerability score", min = 0, max = 100, value = 100, width = "100%")),
                 condition = approach_js(ns, c("hybrid", "scorecard"))),
            step("Community decision",
                 selectInput(ns("ben_comm_col"), "Column recording the community's decision",
                             choices = character(0), width = "100%"),
                 picker("ben_comm_vals", "Value(s) meaning selected"),
                 condition = approach_js(ns, "community")),
            step("Prioritisation",
                 # Who is served when resources do not cover everyone eligible.
                 # Those cut here are excluded by design, not errors.
                 radioButtons(ns("ben_prio_mode"), NULL,
                              choices = c("None: serve all eligible" = "none",
                                          "Total caseload" = "caseload",
                                          "Caseload per area" = "per_unit"),
                              selected = "none"),
                 conditionalPanel(
                   condition = sprintf("input['%s'] !== 'none'", ns("ben_prio_mode")),
                   numericInput(ns("ben_prio_n"), "Households to serve", value = NA, min = 1, step = 1, width = "100%"),
                   conditionalPanel(
                     condition = sprintf("input['%s'] === 'per_unit'", ns("ben_prio_mode")),
                     selectInput(ns("ben_quota_unit"), "Per",
                                 choices = c("Admin 1" = "admin1", "Admin 2" = "admin2", "Admin 3" = "admin3"),
                                 selected = "admin1", width = "100%")),
                   tags$div(class = "text-muted small",
                            "Most vulnerable first (highest score). Eligible households cut here are ",
                            tags$em("excluded by design"), ": reported separately, not counted as exclusion errors.")),
                 condition = approach_js(ns, c("hybrid", "scorecard", "categorical", "community", "geographic", "blanket")))
          ),
          tags$div(
            class = "wfp-design-foot",
            tags$span(class = "small text-muted", bsicons::bs_icon("info-circle"),
                      " The design and the filters take effect together when you apply the selection."),
            tags$button(type = "button", class = "btn btn-primary btn-sm",
                        onclick = sprintf("document.getElementById('%s').click()", ns("ben_apply")),
                        icon("filter"), " Apply selection")
          )
        ),
        bslib::nav_panel(
          value = "composition", title = tagList(bsicons::bs_icon("bar-chart"), " Composition"),
          tags$div(class = "mt-3", uiOutput(ns("comp_insights"))),
          bslib::layout_columns(
            col_widths = c(6, 6),
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(bsicons::bs_icon("bar-chart"), " Eligibility and vulnerability mix"),
              bslib::card_body(plotly::plotlyOutput(ns("ben_validation_plot"), height = "360px"))
            ),
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(bsicons::bs_icon("geo-alt"), " By area: served, excluded by design, not eligible"),
              bslib::card_body(plotly::plotlyOutput(ns("ben_area_plot"), height = "360px"))
            )
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(bsicons::bs_icon("people"), " Who is selected, compared with who is not"),
            bslib::card_body(uiOutput(ns("ben_profile")))
          )
        ),
        bslib::nav_panel(
          value = "list", title = tagList(bsicons::bs_icon("list-ul"), " Beneficiary list"),
          bslib::card(
            class = "mt-3", full_screen = TRUE,
            bslib::card_header(
              class = "d-flex align-items-center",
              tags$span(bsicons::bs_icon("people"), " Selected beneficiaries"),
              # Same export as the sidebar button: the list plus its metadata.
              tags$button(type = "button", class = "btn btn-outline-primary btn-sm ms-auto",
                          onclick = sprintf("document.getElementById('%s').click()", ns("export_open")),
                          icon("file-excel"), " Download the list (Excel)")),
            DT::DTOutput(ns("ben_table"), fill = FALSE)
          )
        ),
        bslib::nav_panel(
          value = "accuracy", title = tagList(bsicons::bs_icon("bullseye"), " Accuracy"),
          # Shown only when an eligibility column is mapped; otherwise says so.
          uiOutput(ns("ben_diagnostics_ui"))
        )
      )
    )
  )
}

#' Beneficiary Selection Module Server
#'
#' @param id module id
#' @param uploaded_df reactive data
#' @param user_setup reactive values
#' @import shiny
#' @noRd
mod_ben_selection_server <- function(id, uploaded_df, user_setup, workspace = NULL, modification_log = NULL) {
  moduleServer(id, function(input, output, session) {
    # moduleServer does not supply `ns`. Two renderUI blocks below happened to
    # declare it locally, which hid the omission until something at module
    # level needed it.
    ns <- session$ns

    applied <- reactiveValues(
      admin1 = NULL, admin2 = NULL, admin3 = NULL,
      score_min = 0, score_max = 100,
      approach = "hybrid", combine = "both", comm_col = NULL, comm_vals = NULL,
      prio_mode = "none", prio_n = NA, quota_unit = "admin1"
    )

    # Saved with the session: the applied selection. The rules already travel
    # in user_setup.
    workspace_register(workspace, "ben_selection",
      snapshot = function() if (is.null(uploaded_df())) NULL else reactiveValuesToList(applied),
      restore = function(s) {
        # after the data-load observer has reset the filters
        after_flush(session, function() {
          for (k in names(s)) applied[[k]] <- s[[k]]
          for (k in c("admin1", "admin2", "admin3")) {
            shinyWidgets::updatePickerInput(session, paste0("ben_", k), selected = s[[k]] %||% character(0))
          }
          updateSliderInput(session, "ben_score_min", value = s$score_min)
          updateSliderInput(session, "ben_score_max", value = s$score_max)
          updateSelectInput(session, "ben_approach", selected = s$approach)
          updateRadioButtons(session, "ben_combine", selected = s$combine)
          updateSelectInput(session, "ben_comm_col", selected = s$comm_col %||% "")
          updateRadioButtons(session, "ben_prio_mode", selected = s$prio_mode)
          updateNumericInput(session, "ben_prio_n", value = s$prio_n)
          updateSelectInput(session, "ben_quota_unit", selected = s$quota_unit)
          # the community values picker refills when its column arrives
          pending_comm_vals(s$comm_vals)
        })
      })
    pending_comm_vals <- reactiveVal(NULL)

    mod_var_calc_server("calc", uploaded_df, function(df) uploaded_df(df), modification_log)

    output$approach_desc <- renderUI({
      a <- targeting_approaches()[[input$ben_approach %||% "hybrid"]]
      tags$div(class = "small text-muted mb-2", a$description)
    })

    # Community-based: any column can hold the community's decision.
    observe({
      df <- uploaded_df(); req(df)
      updateSelectInput(session, "ben_comm_col", choices = c("Choose a column" = "", names(df)),
                        selected = isolate(input$ben_comm_col) %||% "")
    })
    observeEvent(input$ben_comm_col, {
      df <- uploaded_df()
      col <- input$ben_comm_col
      ch <- if (!is.null(df) && nzchar(col) && col %in% names(df))
        utils::head(sort(unique(as.character(df[[col]]))), 500) else character(0)
      shinyWidgets::updatePickerInput(session, "ben_comm_vals", choices = ch,
                                      selected = intersect(isolate(pending_comm_vals()) %||% character(0), ch))
      pending_comm_vals(NULL)
    })

    score_range <- reactiveValues(min = 0, max = 100)

    # Update choices and score range when data loads. The data also changes
    # when a column is added (variable calculator) or a record edited, so the
    # applied area and score are kept wherever they still fit the data.
    observe({
      req(uploaded_df())
      df <- uploaded_df()
      for (lvl in c("admin1", "admin2", "admin3")) {
        col <- user_setup[[lvl]]
        if (!is.null(col) && col %in% names(df)) {
          ch <- sort(unique(as.character(df[[col]])))
          keep <- intersect(isolate(applied[[lvl]]) %||% character(0), ch)
          shinyWidgets::updatePickerInput(session = session, inputId = paste0("ben_", lvl),
                                          choices = ch, selected = keep)
          applied[[lvl]] <- if (length(keep)) keep else NULL
        }
      }

      score_col <- user_setup$v_score
      if (!is.null(score_col) && score_col %in% names(df)) {
        vals <- suppressWarnings(as.numeric(as.character(df[[score_col]])))
        vals <- vals[!is.na(vals)]
        if (length(vals) > 0) {
          lo <- floor(min(vals)); hi <- ceiling(max(vals))
          if (!identical(c(lo, hi), isolate(c(score_range$min, score_range$max)))) {
            score_range$min <- lo
            score_range$max <- hi
            updateSliderInput(session, "ben_score_min", min = lo, max = hi, value = lo)
            updateSliderInput(session, "ben_score_max", min = lo, max = hi, value = hi)
            applied$score_min <- lo
            applied$score_max <- hi
          }
        }
      }
    })

    observeEvent(input$ben_apply, {
      waiter::waiter_show(
        html = waiter_content(),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)

      applied$admin1 <- input$ben_admin1
      applied$admin2 <- input$ben_admin2
      applied$admin3 <- input$ben_admin3
      applied$score_min <- input$ben_score_min
      applied$score_max <- input$ben_score_max
      applied$approach <- input$ben_approach %||% "hybrid"
      applied$combine <- input$ben_combine %||% "both"
      applied$comm_col <- input$ben_comm_col
      applied$comm_vals <- input$ben_comm_vals
      applied$prio_mode <- input$ben_prio_mode %||% "none"
      applied$prio_n <- input$ben_prio_n
      applied$quota_unit <- input$ben_quota_unit
      audit_add(modification_log, "Selection", "Selection criteria applied",
                sprintf("%s; prioritisation: %s", targeting_approaches()[[applied$approach]]$label, applied$prio_mode))
      showNotification("Selection criteria applied.", type = "message")
    })

    observeEvent(input$ben_clear, {
      waiter::waiter_show(
        html = waiter_content(),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)

      for (lvl in c("ben_admin1", "ben_admin2", "ben_admin3")) {
        shinyWidgets::updatePickerInput(session, lvl, selected = character(0))
      }
      updateSliderInput(session, "ben_score_min", value = score_range$min)
      updateSliderInput(session, "ben_score_max", value = score_range$max)

      applied$admin1 <- NULL
      applied$admin2 <- NULL
      applied$admin3 <- NULL
      applied$score_min <- score_range$min
      applied$score_max <- score_range$max
      applied$comm_vals <- NULL
      applied$prio_mode <- "none"
      applied$prio_n <- NA
      applied$quota_unit <- "admin1"
      shinyWidgets::updatePickerInput(session, "ben_comm_vals", selected = character(0))
      updateRadioButtons(session, "ben_prio_mode", selected = "none")
      updateNumericInput(session, "ben_prio_n", value = NA)
      audit_add(modification_log, "Selection", "Selection criteria cleared")
      showNotification("Selection criteria cleared.", type = "message")
    })

    # -----------------------------------------------------------------------
    # Eligibility rules
    #
    # The rule set lives on the shared setup settings, so it travels with a
    # setup profile instead of being rebuilt every round.
    #
    # Every dynamic control below reports through ONE namespaced input via
    # Shiny.setInputValue rather than getting its own observer: per-row
    # observeEvents would be created afresh on each redraw and leak (or fire
    # with a stale row index) as the builder is edited.
    # -----------------------------------------------------------------------
    RULE_FIELDS <- c(
      v_score = "Vulnerability score", v_groups = "Vulnerability group",
      eligibility = "Eligibility", residency = "Residence type",
      hhh_sex = "HH head sex", hhh_age = "HH head age", hh_size = "HH size",
      childU5 = "Children under 5", disability = "Disability / illness",
      hhid_avail = "HH head ID available", phone_avail = "Phone available",
      admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3",
      admin4 = "Admin 4", village = "Village"
    )

    rules_draft <- reactiveVal(NULL)

    active_ruleset <- reactive({
      rs <- user_setup$rules
      if (is.null(rs)) ruleset_empty() else rs
    })

    # Fields this dataset can actually offer a rule on: the mapped fields,
    # then every other column -- including variables built with the variable
    # calculator -- as "col:<name>".
    rule_field_choices <- reactive({
      df <- uploaded_df()
      req(df)
      mapped <- character(0)
      for (k in names(RULE_FIELDS)) {
        col <- user_setup[[k]]
        if (shiny::isTruthy(col) && col %in% names(df)) mapped[[RULE_FIELDS[[k]]]] <- k
      }
      used <- unlist(lapply(names(RULE_FIELDS), function(k) user_setup[[k]]))
      other <- setdiff(names(df), used)
      out <- list()
      if (length(mapped)) out[["Mapped fields"]] <- mapped
      if (length(other)) out[["Other columns (incl. calculated)"]] <- stats::setNames(paste0("col:", other), other)
      out
    })

    # Distinct values for a categorical field, so the value box is a picker
    # rather than free text the user has to spell exactly right.
    rule_value_choices <- function(key) {
      df <- uploaded_df()
      col <- if (!shiny::isTruthy(key)) NULL
             else if (startsWith(key, "col:")) sub("^col:", "", key) else user_setup[[key]]
      if (is.null(df) || !shiny::isTruthy(col) || !col %in% names(df)) return(NULL)
      x <- df[[col]]
      if (inherits(x, "haven_labelled")) x <- haven::as_factor(x)
      if (is.numeric(x)) return(NULL)
      v <- sort(unique(as.character(x)))
      v <- v[!is.na(v) & nzchar(trimws(v))]
      if (length(v) == 0 || length(v) > 60) return(NULL)
      v
    }

    set_input_js <- function(target, value) {
      sprintf("Shiny.setInputValue('%s', '%s', {priority: 'event'})", ns(target), value)
    }

    rule_row_ui <- function(gi, ri, rule, fields) {
      id <- function(part) ns(paste0("rule_", gi, "_", ri, "_", part))
      key <- rule$key %||% ""
      if (is.na(key)) key <- ""
      if (!nzchar(key) && shiny::isTruthy(rule$col)) key <- paste0("col:", rule$col)
      op <- rule$op %||% "=="
      vals <- rule_value_choices(key)

      value_input <- if (op %in% rule_ops_no_value) {
        tags$div(class = "text-muted small fst-italic pt-2", "no value needed")
      } else if (!is.null(vals)) {
        shinyWidgets::pickerInput(
          id("value"), label = NULL, choices = vals,
          selected = intersect(rule$value %||% character(0), vals),
          multiple = TRUE, width = "100%",
          options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE,
                                                selectedTextFormat = "count > 2")
        )
      } else {
        textInput(id("value"), label = NULL, value = paste(rule$value %||% "", collapse = ", "),
                  placeholder = "value (comma-separated for a list)", width = "100%")
      }

      bslib::layout_columns(
        col_widths = c(4, 3, 4, 1), fill = FALSE,
        # Changing the field or the operator changes which value widget is
        # right, so those two redraw the builder; the value itself does not.
        tags$div(
          onchange = set_input_js("rule_redraw", sprintf("%d-%d-key", gi, ri)),
          selectInput(id("key"), label = NULL, choices = fields, selected = key,
                      width = "100%", selectize = FALSE)
        ),
        tags$div(
          onchange = set_input_js("rule_redraw", sprintf("%d-%d-op", gi, ri)),
          selectInput(id("op"), label = NULL, choices = rule_ops(), selected = op,
                      width = "100%", selectize = FALSE)
        ),
        value_input,
        actionButton(id("drop"), label = NULL, icon = icon("xmark"),
                     class = "btn-outline-danger btn-sm", title = "Remove this condition",
                     onclick = set_input_js("rule_drop", sprintf("%d-%d", gi, ri)))
      )
    }

    output$rules_ui <- renderUI({
      rs <- rules_draft()
      req(rs)
      fields <- rule_field_choices()
      if (length(fields) == 0) {
        return(tags$div(class = "alert alert-warning",
                        "No variables are mapped yet -- run Variable Setup first."))
      }

      groups <- lapply(seq_along(rs$groups), function(gi) {
        g <- rs$groups[[gi]]
        rules <- g$rules %||% list()
        tagList(
          if (gi > 1) tags$div(class = "text-center my-2",
                               tags$span(class = "badge bg-secondary", "OR")),
          bslib::card(
            class = "border-0 bg-body-tertiary mb-2",
            bslib::card_body(
              class = "py-2",
              tags$div(
                class = "d-flex justify-content-between align-items-center mb-2",
                tags$span(class = "small fw-bold text-uppercase",
                          paste0("Group ", gi, " - must match all of:")),
                actionButton(ns(paste0("grp_drop_", gi)), label = NULL, icon = icon("trash"),
                             class = "btn-outline-danger btn-sm", title = "Remove this group",
                             onclick = set_input_js("rule_group_drop", gi))
              ),
              if (length(rules) == 0) {
                tags$div(class = "text-muted small fst-italic mb-2", "No conditions yet.")
              } else {
                tagList(lapply(seq_along(rules), function(ri) rule_row_ui(gi, ri, rules[[ri]], fields)))
              },
              actionButton(ns(paste0("grp_add_", gi)), "Add condition", icon = icon("plus"),
                           class = "btn-outline-primary btn-sm",
                           onclick = set_input_js("rule_cond_add", gi))
            )
          )
        )
      })

      tagList(groups, actionButton(ns("rule_group_add"), "Add OR group", icon = icon("plus"),
                                   class = "btn-outline-secondary btn-sm mt-1"))
    })

    # Read the rendered inputs back into a rule set. Run before every
    # structural change so in-progress edits survive adding or removing a row.
    harvest_rules <- function() {
      rs <- rules_draft()
      if (is.null(rs)) return(ruleset_empty())
      rs$groups <- lapply(seq_along(rs$groups), function(gi) {
        rules <- rs$groups[[gi]]$rules %||% list()
        list(rules = lapply(seq_along(rules), function(ri) {
          pre <- paste0("rule_", gi, "_", ri, "_")
          key <- input[[paste0(pre, "key")]] %||% rules[[ri]]$key
          op <- input[[paste0(pre, "op")]] %||% rules[[ri]]$op %||% "=="
          raw <- input[[paste0(pre, "value")]]
          value <- if (is.null(raw)) {
            rules[[ri]]$value %||% character(0)
          } else if (length(raw) == 1 && is.character(raw) && grepl(",", raw, fixed = TRUE)) {
            trimws(strsplit(raw, ",", fixed = TRUE)[[1]])
          } else {
            as.character(raw)
          }
          value <- value[!is.na(value) & nzchar(value)]
          if (shiny::isTruthy(key) && startsWith(key, "col:")) {
            list(key = NA_character_, col = sub("^col:", "", key), op = op, value = value)
          } else {
            list(key = key, col = rules[[ri]]$col %||% NA_character_, op = op, value = value)
          }
        }))
      })
      rs
    }

    observeEvent(input$btn_rules, {
      rules_draft(active_ruleset())
      showModal(modalDialog(
        title = tags$div(bsicons::bs_icon("funnel"), " Eligibility rules"),
        size = "xl", easyClose = FALSE,
        footer = tagList(
          actionButton(ns("rules_clear"), "Clear all", class = "btn-outline-danger"),
          modalButton("Cancel"),
          actionButton(ns("rules_save"), "Use these rules", class = "btn-primary",
                       icon = icon("check"))
        ),
        tags$p(class = "text-muted small",
               "A household is eligible when it matches every condition in at least one group. ",
               "Conditions point at mapped variables, so the rules survive a column being renamed ",
               "and travel with the setup profile."),
        uiOutput(ns("rules_ui")),
        tags$hr(),
        tags$div(class = "small", tags$strong("Reads as: "),
                 textOutput(ns("rules_preview"), inline = TRUE))
      ))
    })

    observeEvent(input$rule_group_add, {
      rs <- harvest_rules()
      rs$groups <- c(rs$groups, list(list(rules = list())))
      rules_draft(rs)
    })

    observeEvent(input$rule_cond_add, {
      gi <- suppressWarnings(as.integer(input$rule_cond_add))
      rs <- harvest_rules()
      req(!is.na(gi), gi <= length(rs$groups))
      rs$groups[[gi]]$rules <- c(
        rs$groups[[gi]]$rules %||% list(),
        list(list(key = NA_character_, col = NA_character_, op = "==", value = character(0)))
      )
      rules_draft(rs)
    })

    observeEvent(input$rule_group_drop, {
      gi <- suppressWarnings(as.integer(input$rule_group_drop))
      rs <- harvest_rules()
      req(!is.na(gi), gi <= length(rs$groups))
      rs$groups[[gi]] <- NULL
      if (length(rs$groups) == 0) rs <- ruleset_empty()
      rules_draft(rs)
    })

    observeEvent(input$rule_drop, {
      parts <- suppressWarnings(as.integer(strsplit(as.character(input$rule_drop), "-", fixed = TRUE)[[1]]))
      rs <- harvest_rules()
      req(length(parts) == 2, !anyNA(parts), parts[1] <= length(rs$groups))
      req(parts[2] <= length(rs$groups[[parts[1]]]$rules))
      rs$groups[[parts[1]]]$rules[[parts[2]]] <- NULL
      rules_draft(rs)
    })

    observeEvent(input$rule_redraw, {
      rules_draft(harvest_rules())
    })

    # Reads the inputs directly, so the sentence updates as the user types.
    output$rules_preview <- renderText({
      req(rules_draft())
      ruleset_describe(harvest_rules(), user_setup, RULE_FIELDS)
    })

    observeEvent(input$rules_clear, rules_draft(ruleset_empty()))

    observeEvent(input$rules_save, {
      rs <- harvest_rules()
      # Drop half-built conditions instead of letting them quietly pass everyone.
      rs$groups <- lapply(rs$groups, function(g) {
        list(rules = Filter(function(r) {
          ((shiny::isTruthy(r$key) && !is.na(r$key)) || (shiny::isTruthy(r$col) && !is.na(r$col))) &&
            (r$op %in% rule_ops_no_value || length(r$value) > 0)
        }, g$rules %||% list()))
      })
      rs$groups <- Filter(function(g) length(g$rules) > 0, rs$groups)
      if (length(rs$groups) == 0) rs <- ruleset_empty()
      user_setup$rules <- rs
      removeModal()
      audit_add(modification_log, "Selection", "Eligibility rules saved", ruleset_describe(rs, user_setup, RULE_FIELDS))
      showNotification(ruleset_describe(rs, user_setup, RULE_FIELDS), type = "message", duration = 12)
    })

    # -----------------------------------------------------------------------
    # Scorecard: load, cross-walk, gate
    #
    # The card is designed on assessment data and applied here to registration
    # data, and the two rarely name their columns the same way. Loading a card
    # therefore always goes through a crosswalk: the app proposes a match per
    # criterion and the user confirms it, rather than the card silently
    # scoring nobody because every column name missed.
    # -----------------------------------------------------------------------

    xwalk_draft <- reactiveVal(NULL)     # the card being mapped
    xwalk_match <- reactiveVal(NULL)     # proposed matches

    open_crosswalk <- function(sc) {
      df <- uploaded_df()
      if (is.null(df)) {
        showNotification("Load the registration data first.", type = "error")
        return()
      }
      m <- match_scorecard_columns(sc, df)
      xwalk_draft(sc)
      xwalk_match(m)

      showModal(modalDialog(
        title = tags$div(bsicons::bs_icon("diagram-3"), " Match scorecard criteria to this dataset"),
        size = "xl", easyClose = FALSE,
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("xwalk_auto"), "Re-run autodetect", icon = icon("wand-magic-sparkles"),
                       class = "btn-outline-secondary"),
          actionButton(ns("xwalk_apply"), "Use this scorecard", icon = icon("check"),
                       class = "btn-primary")
        ),
        uiOutput(ns("xwalk_summary")),
        uiOutput(ns("xwalk_ui"))
      ))
    }

    observeEvent(input$sc_file, {
      req(input$sc_file)
      ext <- tolower(tools::file_ext(input$sc_file$name))
      sc <- tryCatch({
        if (ext == "xlsx") {
          read_scorecard_workbook(input$sc_file$datapath)
        } else if (ext == "json") {
          normalise_scorecard(jsonlite::fromJSON(
            paste(readLines(input$sc_file$datapath, warn = FALSE), collapse = "\n"),
            simplifyVector = TRUE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE))
        } else {
          stop("Load the .xlsx exported from Targeting Design, or its .json.", call. = FALSE)
        }
      }, error = function(e) {
        showNotification(conditionMessage(e), type = "error", duration = 15)
        NULL
      })
      req(sc)
      if (scorecard_is_empty(sc)) {
        showNotification("That file contains no usable criteria.", type = "error")
        return()
      }
      open_crosswalk(sc)
    })

    # Re-matching an already-adopted card against the current data.
    observeEvent(input$sc_rematch, {
      sc <- user_setup$scorecard
      if (scorecard_is_empty(sc)) {
        showNotification("No scorecard in use yet.", type = "warning")
        return()
      }
      open_crosswalk(sc)
    })

    observeEvent(input$xwalk_auto, {
      sc <- xwalk_draft(); df <- uploaded_df()
      req(sc, df)
      xwalk_match(match_scorecard_columns(sc, df))
      showNotification("Autodetect re-run.", type = "message")
    })

    output$xwalk_summary <- renderUI({
      m <- xwalk_match()
      req(m)
      found <- sum(!is.na(m$column))
      exact <- sum(m$method %in% c("exact", "case"))
      fuzzy <- sum(m$method == "approximate")
      none <- sum(m$method == "none")
      tagList(
        tags$p(class = "text-muted",
               "Each criterion needs a yes/no column in the registration data.",
               " Confirm or correct the proposals below; anything left unmatched",
               " scores nobody and is reported rather than silently counted as a no."),
        tags$div(
          class = "wfp-stat-strip mb-3",
          tags$span(tags$strong(nrow(m)), " criteria"),
          tags$span(tags$strong(exact), " matched by name"),
          tags$span(tags$strong(fuzzy), " matched approximately"),
          tags$span(tags$strong(none), " not matched")
        ),
        if (fuzzy > 0 || none > 0) {
          tags$div(
            class = if (none > 0) "alert alert-warning" else "alert alert-info",
            bsicons::bs_icon("exclamation-triangle"),
            if (none > 0) {
              sprintf(" %d criteria have no proposal. Pick a column, or leave blank and the card will score without them.", none)
            } else {
              sprintf(" %d criteria were matched on name similarity. Check them before using the card.", fuzzy)
            }
          )
        }
      )
    })

    output$xwalk_ui <- renderUI({
      m <- xwalk_match()
      sc <- xwalk_draft()
      df <- uploaded_df()
      req(m, sc, df)

      # Only binary columns can satisfy a yes/no criterion.
      choices <- names(df)[vapply(names(df), function(cl)
        !is.null(as_binary_criterion(df[[cl]])), logical(1))]
      choices <- c("(not mapped)" = "", stats::setNames(choices, choices))

      dirs <- stats::setNames(
        vapply(sc$items, function(i) i$direction, character(1)),
        vapply(sc$items, function(i) i$criterion, character(1))
      )
      wts <- stats::setNames(
        vapply(sc$items, function(i) i$weight, numeric(1)),
        vapply(sc$items, function(i) i$criterion, character(1))
      )

      badge <- function(method, sim) {
        cls <- switch(method,
                      exact = "badge bg-success", case = "badge bg-success",
                      normalised = "badge bg-info",
                      approximate = "badge bg-warning text-dark",
                      "badge bg-secondary")
        lab <- switch(method,
                      exact = "exact", case = "case", normalised = "shape",
                      approximate = sprintf("~%.0f%%", 100 * sim), "none")
        tags$span(class = cls, lab)
      }

      rows <- lapply(seq_len(nrow(m)), function(i) {
        crit <- m$criterion[i]
        bslib::layout_columns(
          col_widths = c(4, 2, 2, 4), fill = FALSE,
          tags$div(class = "pt-2", tags$strong(crit)),
          tags$div(class = "pt-2",
                   tags$span(class = if (identical(dirs[[crit]], "inclusion"))
                     "badge bg-primary" else "badge bg-secondary", dirs[[crit]])),
          tags$div(class = "pt-2 small text-muted",
                   sprintf("%.2f pts  ", wts[[crit]]), badge(m$method[i], m$similarity[i])),
          selectInput(ns(paste0("xw_", i)), label = NULL, choices = choices,
                      selected = if (is.na(m$column[i])) "" else m$column[i],
                      width = "100%", selectize = FALSE)
        )
      })

      tagList(
        bslib::layout_columns(
          col_widths = c(4, 2, 2, 4), fill = FALSE, class = "small fw-bold text-uppercase",
          tags$div("Scorecard criterion"), tags$div("Direction"),
          tags$div("Weight / match"), tags$div("Column in this dataset")
        ),
        tags$hr(class = "mt-1 mb-2"),
        rows
      )
    })

    observeEvent(input$xwalk_apply, {
      sc <- xwalk_draft(); m <- xwalk_match()
      req(sc, m)
      mapping <- stats::setNames(
        vapply(seq_len(nrow(m)), function(i) input[[paste0("xw_", i)]] %||% "", character(1)),
        m$criterion
      )
      sc <- apply_scorecard_mapping(sc, mapping)
      user_setup$scorecard <- sc
      removeModal()
      audit_add(modification_log, "Selection", "Scorecard mapped to the registration data",
                paste(sprintf("%s -> %s", names(mapping), ifelse(nzchar(mapping), mapping, "(not mapped)")), collapse = "; "))

      r <- scorecard_readiness(sc, uploaded_df())
      if (r$unmapped > 0) {
        showNotification(
          sprintf("Scorecard in use with %d of %d criteria mapped. Unmapped: %s.",
                  r$mapped, r$n, paste(utils::head(r$missing, 5), collapse = ", ")),
          type = "warning", duration = 15
        )
      } else {
        showNotification(
          sprintf("Scorecard in use: all %d criteria mapped to this dataset.", r$n),
          type = "message", duration = 10
        )
      }
    })

    output$scorecard_ui <- renderUI({
      sc <- user_setup$scorecard
      loader <- tags$div(
        class = "wfp-inline-file mt-1",
        fileInput(ns("sc_file"), label = NULL, accept = c(".xlsx", ".json"),
                  buttonLabel = "Load scorecard", placeholder = "scorecard.xlsx",
                  width = "100%")
      )
      if (scorecard_is_empty(sc)) {
        return(tagList(
          tags$div(
            class = "small text-muted",
            bsicons::bs_icon("card-checklist"),
            " No scorecard in use. Build one under ", tags$strong("Targeting Design"),
            ", or load one exported from there."
          ),
          loader
        ))
      }
      tagList(
        checkboxInput(ns("use_scorecard"),
                      sprintf("Apply scorecard (%d criteria)", length(sc$items)),
                      value = isolate(input$use_scorecard) %||% TRUE),
        conditionalPanel(
          condition = sprintf("input['%s']", ns("use_scorecard")),
          numericInput(ns("scorecard_threshold"), "Eligible when score is above",
                       value = isolate(input$scorecard_threshold) %||% (sc$threshold %||% 0),
                       min = 0, step = 0.1, width = "100%")
        ),
        uiOutput(ns("scorecard_note")),
        tags$div(
          class = "d-flex gap-2 mt-1",
          actionButton(ns("sc_rematch"), "Match columns", icon = icon("diagram-project"),
                       class = "btn-outline-primary btn-sm flex-fill")
        ),
        loader
      )
    })

    output$scorecard_note <- renderUI({
      sc <- user_setup$scorecard
      df <- uploaded_df()
      if (scorecard_is_empty(sc) || is.null(df)) return(NULL)
      r <- scorecard_readiness(sc, df)
      age <- scorecard_age_months(sc)
      stale <- if (isTRUE(age > 24)) tags$div(
        class = "small text-warning",
        bsicons::bs_icon("calendar-x"),
        sprintf(" Designed %d months ago (%s). The OGN asks for weights to be reviewed every 2-3 years, annually in dynamic contexts.",
                round(age), sc$created)
      )
      if (r$ready) {
        return(tagList(tags$div(
          class = "small text-success",
          bsicons::bs_icon("check-circle-fill"),
          sprintf(" All %d criteria mapped. Outcome: %s.", r$n, sc$outcome %||% "not recorded")
        ), stale))
      }
      # An unmapped criterion scores nobody, which would quietly shrink every
      # household's score without ever looking like an error.
      tagList(tags$div(
        class = "small text-warning",
        bsicons::bs_icon("exclamation-triangle-fill"),
        sprintf(" %d of %d criteria are not mapped to this dataset (%s). They score nobody.",
                r$unmapped, r$n, paste(utils::head(r$missing, 3), collapse = ", "))
      ), stale)
    })

    output$rules_summary <- renderText({
      rs <- active_ruleset()
      if (ruleset_is_empty(rs)) return("No eligibility rules set.")
      n <- sum(vapply(rs$groups, function(g) length(g$rules %||% list()), integer(1)))
      paste0(n, " condition", if (n == 1) "" else "s", " in ",
             length(rs$groups), " group", if (length(rs$groups) == 1) "" else "s", ".")
    })

    # One pass over the full registration data: the eligible-by-design and
    # prioritised masks both stay aligned to it, so diagnostics can tell a
    # targeting error from a household cut for lack of resources.
    selection <- reactive({
      df <- uploaded_df(); req(df)
      sc <- user_setup$scorecard
      if (isTRUE(input$use_scorecard) && !scorecard_is_empty(sc)) {
        sc$threshold <- input$scorecard_threshold %||% sc$threshold %||% 0
      } else {
        sc <- NULL
      }
      select_households(
        df, user_setup,
        approach = applied$approach,
        area = list(admin1 = applied$admin1, admin2 = applied$admin2, admin3 = applied$admin3),
        # The sidebar's household-criteria pickers were dropped: the
        # eligibility rules express the same conditions, on any column.
        filters = list(),
        ruleset = active_ruleset(),
        scorecard = sc,
        score_range = c(applied$score_min, applied$score_max),
        combine = applied$combine,
        community = list(column = applied$comm_col, values = applied$comm_vals),
        prioritization = list(mode = applied$prio_mode, n = applied$prio_n,
                              unit = applied$quota_unit)
      )
    })

    selected_data <- reactive({
      df <- uploaded_df(); req(df)
      df[which(selection()$prioritized), , drop = FALSE]
    })

    output$selection_note <- renderUI({
      s <- selection(); req(s)
      a <- targeting_approaches()[[applied$approach]]
      n_el <- sum(s$eligible); n_pr <- sum(s$prioritized)
      fmt <- function(x) format(x, big.mark = ",")
      # One HTML string: inline tags as separate children pick up whitespace
      # before the punctuation.
      body <- if (!s$list_produced) "no household list is produced." else paste0(
        fmt(n_el), " eligible by design",
        if (n_pr < n_el) sprintf(", %s prioritised, <strong>%s excluded by design</strong> (unmet need, not an exclusion error)",
                                 fmt(n_pr), fmt(n_el - n_pr)),
        ".")
      tags$div(
        class = "small mt-2",
        tags$div(HTML(paste0("<strong>", htmltools::htmlEscape(a$label), "</strong>: ", body))),
        if (s$list_produced) lapply(s$notes, function(x) tags$div(
          class = "text-warning", bsicons::bs_icon("exclamation-triangle-fill"), " ", x))
      )
    })

    output$ben_total <- renderText({
      req(selected_data())
      format(nrow(selected_data()), big.mark = ",")
    })

    output$ben_indiv <- renderText({
      req(selected_data(), user_setup$hh_size)
      sizes <- suppressWarnings(as.numeric(as.character(selected_data()[[user_setup$hh_size]])))
      format(sum(sizes, na.rm = TRUE), big.mark = ",")
    })

    # Selection counts households; survey weights have no place here.
    output$ben_eligible <- renderText({
      s <- selection(); req(s)
      format(sum(s$eligible), big.mark = ",")
    })

    output$ben_cut <- renderText({
      s <- selection(); req(s)
      format(sum(s$eligible & !s$prioritized), big.mark = ",")
    })

    # What the selected list is made of: its eligibility and vulnerability
    # group mix, as shares of the selected households.
    output$ben_validation_plot <- render_wfp_plotly({
      df <- selected_data(); req(df, nrow(df) > 0)
      parts <- list()
      for (k in c(Eligibility = "eligibility", `Vulnerability group` = "v_groups")) {
        col <- user_setup[[k]]
        if (shiny::isTruthy(col) && col %in% names(df)) {
          tb <- table(as.character(df[[col]]), useNA = "no")
          parts[[length(parts) + 1]] <- data.frame(criterion = names(which(c(Eligibility = "eligibility", `Vulnerability group` = "v_groups") == k)),
                                                   category = names(tb), n = as.integer(tb), stringsAsFactors = FALSE)
        }
      }
      validate(need(length(parts) > 0, "Map eligibility or vulnerability groups to see what the selection is made of."))
      d <- do.call(rbind, parts)
      d$pct <- 100 * d$n / nrow(df)
      d$label <- paste0(d$category, "  \u00b7  ", d$criterion)
      d <- d[order(d$criterion, d$n), , drop = FALSE]
      d$label <- factor(d$label, levels = d$label)
      plotly::plot_ly(d, x = ~n, y = ~label, color = ~criterion, type = "bar", orientation = "h",
                      colors = c("#0A6EB4", "#f7b825"),
                      text = ~sprintf("%s (%.0f%%)", format(n, big.mark = ","), pct), textposition = "outside",
                      cliponaxis = FALSE,
                      hovertemplate = "%{y}<br>%{x:,} households<extra></extra>") |>
        plotly::layout(xaxis = list(title = "Selected households", rangemode = "tozero"),
                       yaxis = list(title = "", automargin = TRUE),
                       bargap = 0.35, margin = list(r = 60),
                       legend = list(orientation = "h", x = 0, y = 1.08, xanchor = "left", yanchor = "bottom"))
    })

    # --- composition insights ------------------------------------------------
    col_of <- function(k) {
      cl <- as.character(user_setup[[k]] %||% "")[1]
      df <- uploaded_df()
      if (!is.na(cl) && nzchar(cl) && !is.null(df) && cl %in% names(df)) cl else NULL
    }

    output$comp_insights <- renderUI({
      s <- selection(); df <- uploaded_df(); req(s, df)
      sel <- s$prioritized
      n_sel <- sum(sel)
      if (!n_sel) return(empty_state("Nobody selected", "Apply a selection to see what the list is made of.", icon = "people"))
      cards <- list(ben_insight("people", "Households served",
                                sprintf("%.1f%%", 100 * n_sel / nrow(df)),
                                sprintf("%s of %s households", format(n_sel, big.mark = ","), format(nrow(df), big.mark = ","))))
      hs <- col_of("hh_size")
      if (!is.null(hs)) {
        sz <- as_number(df[[hs]])
        cards <- c(cards, list(ben_insight("person-lines-fill", "People served",
          sprintf("%.1f%%", 100 * sum(sz[sel], na.rm = TRUE) / sum(sz, na.rm = TRUE)),
          sprintf("Average household: %.1f people selected, %.1f not selected",
                  mean(sz[sel], na.rm = TRUE), mean(sz[!sel], na.rm = TRUE)))))
      }
      sx <- col_of("hhh_sex")
      if (!is.null(sx)) {
        fem <- is_female(df[[sx]])
        if (any(fem)) cards <- c(cards, list(ben_insight("gender-female", "Female-headed households",
          sprintf("%.0f%% of the selected", 100 * mean(fem[sel])),
          sprintf("against %.0f%% of all households", 100 * mean(fem)))))
      }
      cut <- sum(s$eligible & !sel)
      if (cut) cards <- c(cards, list(ben_insight("dash-circle", "Unmet need",
        format(cut, big.mark = ","), "eligible households not served for lack of resources (excluded by design)")))
      a1 <- col_of("admin1")
      if (!is.null(a1)) {
        u <- as.character(df[[a1]])
        none <- setdiff(unique(u[s$eligible]), unique(u[sel]))
        if (length(none)) cards <- c(cards, list(ben_insight("geo-alt", "Areas with eligible households, nobody served",
          length(none), paste(utils::head(none, 5), collapse = ", "))))
      }
      tags$div(class = "wfp-insights", cards)
    })

    output$ben_area_plot <- render_wfp_plotly({
      s <- selection(); df <- uploaded_df(); req(s, df)
      a <- col_of("admin1")
      validate(need(!is.null(a), "Map Admin 1 to see the selection by area."))
      status <- ifelse(s$prioritized, "Served", ifelse(s$eligible, "Excluded by design", "Not eligible"))
      d <- as.data.frame(table(area = as.character(df[[a]]), status = status), stringsAsFactors = FALSE)
      tot <- tapply(d$Freq * (d$status != "Not eligible"), d$area, sum)
      top <- utils::head(names(sort(tot, decreasing = TRUE)), 25)
      d <- d[d$area %in% top, , drop = FALSE]
      d$area <- factor(d$area, levels = rev(top))
      d$status <- factor(d$status, levels = c("Served", "Excluded by design", "Not eligible"))
      plotly::plot_ly(d, x = ~Freq, y = ~area, color = ~status, type = "bar", orientation = "h",
                      colors = c("#0A6EB4", "#f7b825", "rgba(128,128,128,0.35)"),
                      hovertemplate = "%{y}: %{x:,} households<extra></extra>") |>
        plotly::layout(barmode = "stack", xaxis = list(title = "Households"), yaxis = list(title = "", automargin = TRUE),
                       legend = list(orientation = "h", x = 0, y = 1.08, xanchor = "left", yanchor = "bottom"))
    })

    output$ben_profile <- renderUI({
      s <- selection(); df <- uploaded_df(); req(s, df)
      sel <- s$prioritized
      if (!any(sel) || all(sel)) return(tags$div(class = "small text-muted", "Needs both selected and non-selected households."))
      keys <- c(hh_size = "Household size", hhh_age = "Head of household age", childU5 = "Children under 5",
                v_score = "Vulnerability score", hhh_sex = "Head of household sex", residency = "Residency status",
                disability = "Disability / chronic illness", v_groups = "Vulnerability group")
      cols <- Filter(Negate(is.null), lapply(stats::setNames(names(keys), names(keys)), col_of))
      p <- selection_profile(df, unlist(cols), keys, sel)
      if (is.null(p)) return(tags$div(class = "small text-muted", "Map household variables (size, age, sex...) to compare the groups."))
      tagList(
        tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table",
          tags$thead(tags$tr(tags$th("Indicator"), tags$th(class = "num", "Selected"), tags$th(class = "num", "Not selected"),
                             tags$th(class = "num", "Difference"))),
          tags$tbody(lapply(seq_len(nrow(p)), function(i) tags$tr(
            tags$td(p$indicator[i]), tags$td(class = "num", p$selected[i]), tags$td(class = "num", p$not_selected[i]),
            tags$td(class = "num", style = if (isTRUE(p$notable[i])) "font-weight:600;color:var(--wfp-blue)" else NULL,
                    p$difference[i])))))),
        tags$div(class = "small text-muted mt-1",
                 "Means for numbers, shares for categories. Bold: a gap of 10 points or 20% or more, where the selection tells the groups apart."))
    })

    # Identification columns only; everything else is behind Details.
    output$ben_table <- DT::renderDT({
      req(selected_data())
      record_table(selected_data(), user_setup, session$ns, "ben_view")
    })

    observeEvent(input$ben_view, {
      showModal(record_detail_modal(
        find_record(selected_data(), user_setup, input$ben_view),
        title = paste("Selected household:", input$ben_view)
      ))
    })

    # -----------------------------------------------------------------------
    # Targeting-accuracy diagnostics (activate only when eligibility is mapped)
    # -----------------------------------------------------------------------

    # Eligible-by-design flag aligned with the FULL uploaded dataset, so
    # coverage and inclusion/exclusion error are measured against the whole
    # population. Households cut by prioritisation are excluded by design and
    # must not count as exclusion errors (Targeting Advisory 2/2025).
    selection_mask <- reactive({
      s <- selection(); req(s)
      if (!s$list_produced) return(NULL)
      s$eligible
    })

    ben_metrics <- reactive({
      elig_col <- user_setup$eligibility
      df <- uploaded_df()
      if (!shiny::isTruthy(elig_col) || !elig_col %in% names(df)) return(NULL)
      sel_mask <- selection_mask()
      if (is.null(sel_mask)) return(NULL)
      elig <- eligibility_flag(df[[elig_col]])
      if (!any(!is.na(elig))) return(NULL)  # eligibility not binary -> no-op
      targeting_metrics(sel_mask, elig)
    })

    # Only render the diagnostics block when metrics are computable
    output$ben_diagnostics_ui <- renderUI({
      if (is.null(ben_metrics())) {
        return(tags$div(class = "mt-3", empty_state(
          "No accuracy check yet",
          "Map an eligibility column in the variable setup and apply a selection: coverage, inclusion and exclusion errors are measured against it.",
          icon = "bullseye")))
      }
      ns <- session$ns
      tagList(
        bslib::card(
          class = "mt-3",
          full_screen = TRUE,
          bslib::card_header(
            bsicons::bs_icon("bullseye"), " Targeting Accuracy (eligible by design vs mapped eligibility)"
          ),
          bslib::card_body(
            bslib::layout_columns(
              bslib::value_box(title = "Coverage Rate",   value = textOutput(ns("ben_coverage")),   showcase = bsicons::bs_icon("percent"),       theme = "success"),
              # "scale-balanced" is a Font Awesome name; bs_icon() threw on it and
              # this value box rendered "Error: [object Object]" as its icon.
              bslib::value_box(title = "Selection Ratio", value = textOutput(ns("ben_sel_ratio")),  showcase = bsicons::bs_icon("arrow-left-right"), theme = "info"),
              # box-arrow-* are Bootstrap Icons; arrow-*-bracket are Font Awesome
              # names and rendered as "Error: [object Object]" in these boxes.
              bslib::value_box(title = "Inclusion Error", value = textOutput(ns("ben_incl_err")),   showcase = bsicons::bs_icon("box-arrow-in-right"), theme = "danger"),
              bslib::value_box(title = "Exclusion Error", value = textOutput(ns("ben_excl_err")),   showcase = bsicons::bs_icon("box-arrow-right"), theme = "warning"),
              col_widths = c(3, 3, 3, 3)
            ),
            bslib::layout_columns(
              bslib::card(
                bslib::card_header("Coverage by Admin 1"),
                DT::DTOutput(ns("ben_coverage_table"), fill = FALSE)
              ),
              bslib::card(
                bslib::card_header("Precision / Recall"),
                textOutput(ns("ben_precision_recall"))
              ),
              col_widths = c(7, 5)
            )
          )
        )
      )
    })

    output$ben_coverage <- renderText({
      m <- ben_metrics(); if (is.null(m) || is.na(m$coverage_rate)) return("-")
      paste0(round(m$coverage_rate * 100, 1), "%")
    })
    output$ben_sel_ratio <- renderText({
      m <- ben_metrics(); if (is.null(m) || is.na(m$selection_ratio)) return("-")
      paste0(round(m$selection_ratio, 2), "x")
    })
    output$ben_incl_err <- renderText({
      m <- ben_metrics(); if (is.null(m) || is.na(m$inclusion_error)) return("-")
      paste0(round(m$inclusion_error * 100, 1), "%")
    })
    output$ben_excl_err <- renderText({
      m <- ben_metrics(); if (is.null(m) || is.na(m$exclusion_error)) return("-")
      paste0(round(m$exclusion_error * 100, 1), "%")
    })

    output$ben_coverage_table <- DT::renderDT({
      m <- ben_metrics(); req(m)
      df <- uploaded_df(); elig_col <- user_setup$eligibility
      unit_col <- user_setup$admin1
      if (!shiny::isTruthy(unit_col) || !unit_col %in% names(df)) return(DT::datatable(data.frame()))
      cov <- coverage_by_unit(df, selection_mask(), eligibility_flag(df[[elig_col]]), unit_col)
      cov$coverage <- paste0(round(cov$coverage * 100, 1), "%")
      colnames(cov) <- c("Admin 1", "Eligible", "Selected", "Coverage")
      DT::datatable(cov, options = list(pageLength = 12, scrollX = TRUE), rownames = FALSE) |>
        DT::formatCurrency(c("Eligible", "Selected"), currency = "", interval = 3, mark = ",", digits = 0)
    })

    output$ben_precision_recall <- renderText({
      m <- ben_metrics(); if (is.null(m)) return("")
      out <- sprintf("Precision: %s   |   Recall: %s",
                     if (is.na(m$precision)) "-" else paste0(round(m$precision * 100, 1), "%"),
                     if (is.na(m$recall)) "-" else paste0(round(m$recall * 100, 1), "%"))
      # The OGN notes exclusion rises by definition once prioritisation cuts
      # the list; show by how much, kept apart from the design error above.
      s <- selection()
      if (any(s$eligible & !s$prioritized)) {
        df <- uploaded_df()
        mp <- targeting_metrics(s$prioritized, eligibility_flag(df[[user_setup$eligibility]]))
        if (!is.null(mp) && !is.na(mp$exclusion_error)) {
          out <- paste0(out, sprintf("   |   After prioritisation, %.1f%% of eligible households are not served (+%.1f pts, excluded by design).",
                                     100 * mp$exclusion_error, 100 * (mp$exclusion_error - m$exclusion_error)))
        }
      }
      out
    })

    # -----------------------------------------------------------------------
    # Export: the user picks the variables, then downloads. The choice is kept
    # for the next export in this session.
    # -----------------------------------------------------------------------
    export_cols <- reactiveVal(NULL)
    observeEvent(input$export_open, {
      df <- uploaded_df(); req(df)
      cols <- names(df)
      # Identification and the mapped fields first, the rest after.
      keys <- c("unique_id", "admin1", "admin2", "admin3", "admin4", "village", "hh_size",
                "hhh_sex", "hhh_age", "v_score", "v_groups", "eligibility")
      mapped <- unique(unlist(lapply(keys, function(k) {
        cl <- user_setup[[k]]; if (shiny::isTruthy(cl) && cl %in% cols) cl
      })))
      ordered <- c(mapped, setdiff(cols, mapped))
      sel <- intersect(export_cols() %||% ordered, ordered)
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("download"), " Export the selection"),
        size = "m", easyClose = TRUE,
        tags$p(class = "small text-muted",
               "Choose the variables to include in the Selected and Excluded-by-design sheets. ",
               "The Summary and Audit trail sheets are always included."),
        shinyWidgets::pickerInput(
          ns("export_vars"), "Variables to export", width = "100%",
          choices = col_choice_groups(`Mapped fields` = mapped, `Other columns` = setdiff(ordered, mapped)),
          selected = sel, multiple = TRUE,
          options = shinyWidgets::pickerOptions(actionsBox = TRUE, liveSearch = TRUE, container = "body",
                                                selectedTextFormat = "count > 4",
                                                countSelectedText = "{0} of {1} variables")),
        tags$div(class = "d-flex gap-2 flex-wrap mt-1",
                 actionButton(ns("export_mapped"), "Mapped fields only", class = "btn-outline-secondary btn-sm"),
                 actionButton(ns("export_all"), "All variables", class = "btn-outline-secondary btn-sm")),
        checkboxInput(ns("export_score"), "Add the selection score column", value = TRUE),
        footer = tagList(modalButton("Cancel"),
                         downloadButton(ns("download_selection"), "Download Excel", class = "btn-primary"))
      ))
      session$userData$export_mapped <- mapped
      session$userData$export_all <- ordered
    })
    observeEvent(input$export_mapped, shinyWidgets::updatePickerInput(session, "export_vars", selected = session$userData$export_mapped))
    observeEvent(input$export_all, shinyWidgets::updatePickerInput(session, "export_vars", selected = session$userData$export_all))
    observeEvent(input$export_vars, export_cols(input$export_vars), ignoreNULL = FALSE, ignoreInit = TRUE)

    # Self-documenting export: rows + a metadata sheet (filters, totals, accuracy)
    output$download_selection <- downloadHandler(
      filename = function() {
        paste0("Targeting_BeneficiarySelection_", format(Sys.time(), "%Y-%m-%d_%Hh%Mm%Ss"), ".xlsx")
      },
      content = function(file) {
        sel <- selected_data()
        s <- selection()
        df_all <- uploaded_df()
        # Only the variables picked in the export dialog (all when none picked).
        keep_cols <- intersect(input$export_vars %||% names(sel), names(sel))
        if (!length(keep_cols)) keep_cols <- names(sel)
        with_score <- !isFALSE(input$export_score) && !all(is.na(s$score))
        sel <- sel[, keep_cols, drop = FALSE]
        if (with_score) sel$selection_score <- s$score[which(s$prioritized)]
        cut <- which(s$eligible & !s$prioritized)
        ex <- NULL
        if (length(cut)) {
          ex <- df_all[cut, intersect(keep_cols, names(df_all)), drop = FALSE]
          if (with_score) ex$selection_score <- s$score[cut]
        }
        prio_desc <- if (!isTRUE(suppressWarnings(as.numeric(applied$prio_n)) > 0)) "none (all eligible served)" else switch(applied$prio_mode %||% "none",
          none = "none (all eligible served)",
          caseload = sprintf("total caseload of %s households", applied$prio_n),
          per_unit = sprintf("%s households per %s", applied$prio_n, applied$quota_unit))
        m <- ben_metrics()
        mpct <- function(x) if (is.null(m) || is.na(x)) "n/a" else sprintf("%.1f%%", 100 * x)
        mnum <- function(x) if (is.null(m) || is.na(x)) "n/a" else sprintf("%.2f", x)
        full <- selected_data()
        n_ind <- if (shiny::isTruthy(user_setup$hh_size) && user_setup$hh_size %in% names(full))
          sum(suppressWarnings(as.numeric(as.character(full[[user_setup$hh_size]]))), na.rm = TRUE) else NA
        sc <- user_setup$scorecard
        sc_used <- isTRUE(input$use_scorecard) && !scorecard_is_empty(sc)
        flt <- function(x) if (length(x)) paste(x, collapse = ", ") else "all"

        # Everything done to the data before this list was drawn, from the
        # audit trail, so the list can be traced back to its source.
        lg <- if (is.function(modification_log)) modification_log() else NULL
        lg_sel <- if (is.null(lg)) NULL else lg[audit_phase(lg$action) == "Selection", , drop = FALSE]
        count_act <- function(pattern) if (is.null(lg_sel)) 0L else sum(grepl(pattern, lg_sel$action))
        calc <- if (is.null(lg_sel)) NULL else lg_sel[grepl("Variable created", lg_sel$action), , drop = FALSE]
        map_keys <- c(unique_id = "Household id", admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3",
                      hh_size = "Household size", v_score = "Vulnerability score", v_groups = "Vulnerability group",
                      eligibility = "Eligibility", hhh_sex = "Head of household sex", hhh_age = "Head of household age")
        mapping <- vapply(names(map_keys), function(k) as.character(user_setup[[k]] %||% "")[1], character(1))

        sections <- list(
          "Data" = c(
            "Source" = user_setup$data_source %||% "not recorded",
            "Households now" = format(nrow(df_all), big.mark = ",")),
          "Data preparation (before selection)" = c(
            "Records deleted" = format(length(deleted_uids(lg_sel)), big.mark = ","),
            "Values edited" = format(count_act("^Edit record"), big.mark = ","),
            "Location names normalised" = format(count_act("location normalization"), big.mark = ","),
            "Outlier values corrected" = format(count_act("Outlier correction"), big.mark = ","),
            "Reset to the original data" = if (count_act("Reset to original")) "yes" else "no",
            "Calculated variables" = if (is.null(calc) || !nrow(calc)) "none" else
              paste(sprintf("%s = %s", calc$column, calc$new_value), collapse = "; "),
            "Full history" = "see the Audit_trail sheet"),
          "Selection" = c(
            "Country office" = user_setup$country_office %||% "not set",
            "Exported" = format(Sys.time(), "%Y-%m-%d %H:%M"),
            "Exported by" = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
            "Variables exported" = sprintf("%d of %d: %s", length(keep_cols), ncol(df_all), paste(keep_cols, collapse = ", ")),
            "Targeting approach" = targeting_approaches()[[applied$approach]]$label,
            "Criteria and score combine as" = if (identical(applied$approach, "hybrid")) applied$combine else "n/a",
            "Prioritisation" = prio_desc,
            "Ranked by" = if (is.na(s$rank_by)) "n/a" else s$rank_by),
          "Totals" = c(
            "Households in the dataset" = format(nrow(df_all), big.mark = ","),
            "Eligible by design" = format(sum(s$eligible), big.mark = ","),
            "Selected (served)" = format(sum(s$prioritized), big.mark = ","),
            "Individuals in selected households" = if (is.na(n_ind)) "n/a" else format(n_ind, big.mark = ","),
            "Excluded by design (unmet need)" = format(length(cut), big.mark = ",")),
          "Filters and rules" = c(
            "Admin 1" = flt(applied$admin1), "Admin 2" = flt(applied$admin2), "Admin 3" = flt(applied$admin3),
            "Vulnerability score range" = paste(applied$score_min, "-", applied$score_max),
            "Eligibility rules" = ruleset_describe(active_ruleset(), user_setup, RULE_FIELDS),
            "Community selection" = if (shiny::isTruthy(applied$comm_col))
              sprintf("%s in {%s}", applied$comm_col, paste(applied$comm_vals %||% "", collapse = ", ")) else "n/a"),
          "Scorecard" = if (sc_used) c(
            "Scorecard" = sprintf("%d criteria, eligible when score > %s", length(sc$items), fmt5(sc$threshold %||% 0)),
            "Status" = if (identical(sc$source, "design")) paste("adopted", sc$adopted_at %||% "") else "loaded from a workbook",
            "Designed on" = sc$created %||% "n/a",
            "Criteria" = paste(vapply(sc$items, function(it) sprintf("%s (%s%s)", it$criterion,
              if (identical(it$direction, "exclusion")) "-" else "+", fmt5(it$weight)), character(1)), collapse = "; "))
            else c("Scorecard" = "not used"),
          "Accuracy against mapped eligibility" = c(
            "Coverage rate" = mpct(m$coverage_rate), "Selection ratio" = mnum(m$selection_ratio),
            "Inclusion error" = mpct(m$inclusion_error), "Exclusion error" = mpct(m$exclusion_error),
            "Precision" = mpct(m$precision), "Recall" = mpct(m$recall)),
          "Variable mapping" = stats::setNames(ifelse(nzchar(mapping), mapping, "not mapped"), map_keys),
          "Notes" = c("Notes" = if (length(s$notes)) paste(s$notes, collapse = " | ") else "none",
                      "Excluded by design" = "Eligible households not served for lack of resources: unmet need, not counted as exclusion error (Targeting Advisory 2/2025).")
        )

        wb <- openxlsx::createWorkbook()
        xl_summary_sheet(wb, "Summary", "Beneficiary selection",
                         paste(c(user_setup$country_office, format(Sys.Date())), collapse = " \u00b7 "), sections)
        xl_data_sheet(wb, "Selected", sanitize_for_excel(sel))
        by_area <- selection_by_area(df_all, user_setup, s)
        if (!is.null(by_area)) xl_data_sheet(wb, "By_area", by_area)
        if (!is.null(ex)) xl_data_sheet(wb, "Excluded_by_design", sanitize_for_excel(ex))
        if (!is.null(lg) && nrow(lg)) {
          xl_data_sheet(wb, "Audit_trail", sanitize_for_excel(data.frame(phase = audit_phase(lg$action), lg,
                                                                         stringsAsFactors = FALSE)))
        }
        openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
      }
    )
  })
}

#' Insight tile (the same look as the data-quality insights)
#' @noRd
ben_insight <- function(icon_name, label, value, sub = NULL) {
  tags$div(class = "wfp-insight",
           tags$div(class = "wfp-insight-label", bsicons::bs_icon(icon_name), " ", label),
           tags$div(class = "wfp-insight-value", value),
           if (!is.null(sub)) tags$div(class = "wfp-insight-sub", sub))
}

#' Female head of household, from the usual codings
#' @noRd
is_female <- function(x) {
  tolower(trimws(as.character(x))) %in% c("f", "female", "femme", "feminin", "woman", "women", "fille")
}

#' Selected vs not selected, indicator by indicator
#'
#' @param df The full registration data.
#' @param cols Named character: setup key -> column.
#' @param labels Named character: setup key -> label.
#' @param sel Logical, TRUE for selected households.
#' @return data.frame(indicator, selected, not_selected, difference, notable),
#'   formatted for display; NULL when there is nothing to compare.
#' @noRd
selection_profile <- function(df, cols, labels, sel) {
  rows <- list()
  for (k in names(cols)) {
    x <- df[[cols[[k]]]]
    num <- as_number(x)
    if (mean(!is.na(num[!is.na(x)])) > 0.9 && length(unique(stats::na.omit(num))) > 2) {
      a <- mean(num[sel], na.rm = TRUE); b <- mean(num[!sel], na.rm = TRUE)
      rows[[length(rows) + 1]] <- data.frame(
        indicator = paste(labels[[k]], "(mean)"), selected = sprintf("%.1f", a), not_selected = sprintf("%.1f", b),
        difference = sprintf("%+.1f", a - b), notable = is.finite(a) && is.finite(b) && b != 0 && abs(a - b) / abs(b) >= 0.2,
        stringsAsFactors = FALSE)
    } else {
      v <- as.character(x)
      lv <- utils::head(names(sort(table(v), decreasing = TRUE)), 6)
      for (l in lv) {
        a <- 100 * mean(v[sel] == l, na.rm = TRUE); b <- 100 * mean(v[!sel] == l, na.rm = TRUE)
        rows[[length(rows) + 1]] <- data.frame(
          indicator = sprintf("%s: %s", labels[[k]], l), selected = sprintf("%.0f%%", a), not_selected = sprintf("%.0f%%", b),
          difference = sprintf("%+.0f pts", a - b), notable = is.finite(a - b) && abs(a - b) >= 10,
          stringsAsFactors = FALSE)
      }
    }
  }
  if (!length(rows)) NULL else do.call(rbind, rows)
}

#' Households and people served per area, for the export
#' @noRd
selection_by_area <- function(df, settings, s) {
  lv <- Filter(function(k) {
    cl <- as.character(settings[[k]] %||% "")[1]
    !is.na(cl) && nzchar(cl) && cl %in% names(df)
  }, c("admin1", "admin2", "admin3"))
  if (!length(lv)) return(NULL)
  cols <- vapply(lv, function(k) as.character(settings[[k]])[1], character(1))
  key <- df[cols]
  key[] <- lapply(key, as.character)
  hs <- as.character(settings$hh_size %||% "")[1]
  size <- if (!is.na(hs) && nzchar(hs) && hs %in% names(df)) as_number(df[[hs]]) else rep(NA_real_, nrow(df))
  g <- interaction(key, drop = TRUE, lex.order = TRUE)
  agg <- function(v) as.numeric(tapply(v, g, sum, na.rm = TRUE))
  first <- !duplicated(g)
  out <- key[first, , drop = FALSE][order(g[first]), , drop = FALSE]
  names(out) <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3")[lv]
  out$Households <- agg(rep(1, nrow(df)))
  out$Eligible <- agg(s$eligible)
  out$Served <- agg(s$prioritized)
  out$`Excluded by design` <- agg(s$eligible & !s$prioritized)
  out$`People served` <- agg(ifelse(s$prioritized, size, 0))
  out$`Served (%)` <- round(100 * out$Served / out$Households, 1)
  rownames(out) <- NULL
  out
}
