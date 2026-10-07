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
        width = 300,
        class = "wfp-ben-sidebar wfp-side",
        # Not a criterion: the part of the registration data this selection
        # covers. Households elsewhere are left out of every count, list and
        # report, which then say which areas they cover.
        side_steps(
          side_step("1. Areas covered", "geo-alt",
             tags$p(class = "small text-muted mb-2",
                    "Leave empty to cover every area. Households outside the chosen areas are left out of the selection and its reports."),
             picker("ben_admin1", "Admin 1"),
             picker("ben_admin2", "Admin 2"),
             picker("ben_admin3", "Admin 3"))),
        tags$div(
          class = "wfp-sb-actions",
          tags$div(
            class = "d-flex gap-2",
            actionButton(ns("ben_apply"), "Apply selection", class = "btn-primary btn-sm flex-fill", icon = icon("filter")),
            actionButton(ns("ben_clear"), label = NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm",
                         title = "Clear the selection criteria")),
          actionButton(ns("export_open"), "Export selection (Excel)", icon = icon("download"),
                       class = "btn-outline-primary btn-sm w-100 mt-2"),
          downloadButton(ns("selection_report"), "Selection report (HTML)",
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
                   # Caseloads are usually given in beneficiaries (people).
                   radioButtons(ns("ben_prio_count"), "Caseload counted in", inline = TRUE,
                                choices = c("People (beneficiaries)" = "people", "Households" = "households"),
                                selected = "people"),
                   conditionalPanel(
                     condition = sprintf("input['%s'] === 'caseload'", ns("ben_prio_mode")),
                     numericInput(ns("ben_prio_n"), "Caseload to serve", value = NA, min = 1, step = 1, width = "100%"),
                     textAreaInput(ns("ben_prio_rationale"), "Rationale (required)", rows = 2, width = "100%",
                                   placeholder = "e.g. Caseload set by the funding available for the first round.")),
                   # Areas rarely share one caseload: each gets its own, in
                   # households or as a share of the total, with a rationale.
                   conditionalPanel(
                     condition = sprintf("input['%s'] === 'per_unit'", ns("ben_prio_mode")),
                     selectInput(ns("ben_quota_unit"), "Per",
                                 choices = c("Admin 1" = "admin1", "Admin 2" = "admin2", "Admin 3" = "admin3", "Admin 4" = "admin4"),
                                 selected = "admin1", width = "100%"),
                     actionButton(ns("quota_open"), "Set the caseload per area...", icon = icon("table-list"),
                                  class = "btn-outline-primary btn-sm w-100 mb-2"),
                     uiOutput(ns("quota_summary"))),
                   tags$div(class = "text-muted small",
                            "Most vulnerable first (highest score). Eligible households cut here are ",
                            tags$em("excluded by design"), ": reported separately, not counted as exclusion errors.")),
                 condition = approach_js(ns, c("hybrid", "scorecard", "categorical", "community", "geographic", "blanket")))
          ),
          tags$div(
            class = "wfp-design-foot",
            tags$span(class = "small text-muted", bsicons::bs_icon("info-circle"),
                      " The design and the filters take effect together when you apply the selection."),
            # The sidebar's Apply selection is the page's one primary action.
            tags$button(type = "button", class = "btn btn-outline-primary btn-sm",
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
          ),
          # an adopted vulnerability ranking: selection by its profiles and deprivations
          uiOutput(ns("ranking_comp"))
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
      prio_mode = "none", prio_n = NA, prio_count = "people", quota_unit = "admin1", quota_plan = NULL,
      # the card and its threshold count once applied, like every criterion
      use_scorecard = TRUE, sc_threshold = NULL
    )
    # A new card brings its own threshold.
    observeEvent(scorecard_fingerprint(user_setup$scorecard), {
      applied$sc_threshold <- NULL
      sc <- user_setup$scorecard
      if (!scorecard_is_empty(sc)) updateNumericInput(session, "scorecard_threshold", value = as.numeric(sc$threshold %||% 0))
    }, ignoreInit = TRUE)

    # --- Caseload per area ------------------------------------------------------
    # list(unit, kind ("households" | "share"), total, values (named, as typed),
    # caseload (named households), rationale, set_at). Takes effect on Apply.
    quota_plan <- reactiveVal(NULL)
    has_size <- reactive(shiny::isTruthy(user_setup$hh_size) && isTRUE(user_setup$hh_size %in% names(full_df() %||% data.frame())))
    # The user's choice, kept while household size is not mapped (people
    # cannot be counted then) and given back once it is.
    count_pref <- reactiveVal("people")
    observeEvent(input$ben_prio_count, if (isolate(has_size())) count_pref(input$ben_prio_count))
    observe({
      if (!has_size()) updateRadioButtons(session, "ben_prio_count", selected = "households",
                                         choices = c("Households (map household size to count people)" = "households"))
      else updateRadioButtons(session, "ben_prio_count", choices = c("People (beneficiaries)" = "people", "Households" = "households"),
                              selected = isolate(count_pref()))
    })
    count_unit <- reactive(if (has_size() && !identical(input$ben_prio_count, "households")) "people" else "households")
    unit_word <- function(u = count_unit()) if (identical(u, "people")) "people" else "households"
    quota_areas <- reactive({
      df <- full_df(); lvl <- input$ben_quota_unit %||% "admin1"
      col <- user_setup[[lvl]]
      if (is.null(df) || !shiny::isTruthy(col) || !col %in% names(df)) return(NULL)
      u <- as.character(df[[col]])
      tab <- sort(table(u[!is.na(u) & nzchar(u)]), decreasing = TRUE)
      hs <- user_setup$hh_size
      size <- if (shiny::isTruthy(hs) && hs %in% names(df)) as_number(df[[hs]]) else rep(NA_real_, nrow(df))
      people <- tapply(size, factor(u, levels = names(tab)), sum, na.rm = TRUE)
      el <- tryCatch({
        s <- selection(); d <- uploaded_df()
        if (length(s$eligible) != nrow(d)) NULL else {
          ud <- factor(as.character(d[[col]]), levels = names(tab))
          sd <- if (shiny::isTruthy(hs) && hs %in% names(d)) as_number(d[[hs]]) else rep(NA_real_, nrow(d))
          list(hh = tapply(s$eligible, ud, sum), people = tapply(ifelse(s$eligible, sd, 0), ud, sum, na.rm = TRUE))
        }
      }, error = function(e) NULL)
      has_size <- shiny::isTruthy(hs) && hs %in% names(df)
      ipc <- ipc_by_area(df, u)
      out <- data.frame(area = names(tab), households = as.integer(tab),
                 people = if (has_size) as.numeric(people[names(tab)]) else NA_real_,
                 eligible = if (is.null(el)) NA_integer_ else as.integer(el$hh[names(tab)]),
                 eligible_people = if (is.null(el) || !has_size) NA_real_ else as.numeric(el$people[names(tab)]),
                 stringsAsFactors = FALSE)
      out$ipc_phase <- if (is.null(ipc$phase)) NA_real_ else as.numeric(ipc$phase[names(tab)])
      out$ipc_pop <- if (is.null(ipc$pop)) NA_real_ else as.numeric(ipc$pop[names(tab)])
      attr(out, "ipc_phase_col") <- ipc$phase_col; attr(out, "ipc_pop_col") <- ipc$pop_col
      out
    })
    quota_label <- function(lvl) c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4")[[lvl %||% "admin1"]]
    # the caseload is set per a mapped level only, named with its column
    observe({
      lv <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4")
      cols <- vapply(names(lv), function(k) as.character(user_setup[[k]] %||% "")[1], "")
      ok <- !is.na(cols) & nzchar(cols)
      ch <- if (any(ok)) stats::setNames(names(lv)[ok], sprintf("%s - %s", lv[ok], cols[ok])) else c("Admin 1" = "admin1")
      cur <- isolate(input$ben_quota_unit)
      updateSelectInput(session, "ben_quota_unit", choices = ch, selected = if (isTRUE(cur %in% ch)) cur else unname(ch[1]))
    })
    # Ways to split a total caseload; the IPC ones only when the data has IPC figures.
    alloc_choices <- function(a) {
      c("In proportion to eligible households" = "eligible",
        "In proportion to households" = "households",
        if (!all(is.na(a$eligible_people))) c("In proportion to eligible people" = "eligible_people", "In proportion to people" = "people"),
        if (!all(is.na(a$ipc_phase))) c("Eligible households in IPC phase 3+ areas only" = "ipc3",
                                        "Eligible households weighted by IPC phase (3 x1, 4 x2, 5 x3)" = "ipc_weight"),
        c("In proportion to the reference figure (column in the table)" = "fig"))
    }
    fig_types <- function() c("IPC phase 3 population" = "ipc3", "IPC phase 4 population" = "ipc4",
                              "IPC phase 5 population" = "ipc5", "IPC phase 3+ population" = "ipc3plus",
                              "HNRP people in need" = "hnrp_pin", "HNRP people targeted" = "hnrp_target")
    fig_label <- function(t) names(fig_types())[match(t %||% "ipc3plus", fig_types())] %||% "Reference figure"
    output$fig_label <- renderText(fig_label(input$fig_type))
    alloc_words <- c(eligible = "eligible households", households = "households", eligible_people = "eligible people",
                     people = "people", ipc3 = "eligible households of the areas in IPC phase 3 or above",
                     ipc_weight = "eligible households weighted by IPC phase (phase 3 x1, 4 x2, 5 x3)",
                     fig = "the reference figure")
    observeEvent(input$quota_allocate, {
      a <- quota_areas(); req(a)
      total <- input$quota_total
      need_ok(isTRUE(total > 0), "Give the total caseload to allocate first.")
      m <- input$quota_alloc %||% "eligible"
      w <- switch(m,
        eligible = a$eligible, households = a$households, eligible_people = a$eligible_people, people = a$people,
        ipc3 = ifelse(!is.na(a$ipc_phase) & a$ipc_phase >= 3, a$eligible, 0),
        ipc_weight = ifelse(!is.na(a$ipc_phase) & a$ipc_phase >= 3, a$eligible * (a$ipc_phase - 2), 0),
        fig = typed_figs("fig"))
      need_ok(sum(w, na.rm = TRUE) > 0, if (identical(m, "fig")) "Type the reference figure of the areas in the table first."
              else "Nothing to allocate on: no area has a figure for this method.")
      vals <- if (identical(input$quota_kind, "share")) allocate_total(w, 1000) / 10 else allocate_total(w, total)
      for (i in seq_len(nrow(a))) updateNumericInput(session, paste0("quota_", i), value = vals[i])
      # The rationale stays the officer's to write: the method is only suggested.
      what <- if (identical(m, "fig")) paste("the", fig_label(input$fig_type)) else alloc_words[[m]]
      updateTextAreaInput(session, "quota_rationale",
                          placeholder = sprintf("e.g. Total caseload of %s %s allocated in proportion to %s per %s, because...",
                                                format(total, big.mark = ","), unit_word(), what, quota_label(input$ben_quota_unit)))
    })
    observeEvent(input$quota_open, {
      req(input$quota_open > 0)  # React buttons send an initial 0
      a <- quota_areas()
      need_ok(!is.null(a) && nrow(a) > 0, sprintf("Map %s in the variable setup first.", quota_label(input$ben_quota_unit)))
      plan <- quota_plan()
      same <- !is.null(plan) && identical(plan$unit, input$ben_quota_unit)
      kind <- if (same) plan$kind else "households"
      val <- function(i) if (same) plan$values[[a$area[i]]] %||% NA else NA
      # IPC and HNRP figures: typed per area (from the data when it has IPC
      # figures), kept with the plan, usable to allocate the caseload.
      fig0 <- function(i) {
        v <- plan$fig[[a$area[i]]]
        if (!is.null(v)) return(v)
        x <- a$ipc_pop[i]; if (is.na(x)) NA else x
      }
      fig_type0 <- plan$fig_type %||% "ipc3plus"
      n0 <- function(v) if (is.na(v)) "\u2013" else format(round(v), big.mark = ",")
      rows <- lapply(seq_len(nrow(a)), function(i) tags$tr(
        tags$td(a$area[i]),
        tags$td(class = "num", n0(a$households[i])),
        tags$td(class = "num", n0(a$people[i])),
        tags$td(class = "num", n0(a$eligible[i])),
        tags$td(class = "num", n0(a$eligible_people[i])),
        tags$td(class = "num wfp-quota-fig", style = "width: 130px;",
                numericInput(ns(paste0("fig_", i)), NULL, value = fig0(i), min = 0, step = 1, width = "100%")),
        tags$td(class = "num", style = "width: 125px;",
                numericInput(ns(paste0("quota_", i)), NULL, value = val(i), min = 0, step = 1, width = "100%")),
        tags$td(class = "wfp-quota-flag", uiOutput(ns(paste0("quota_flag_", i)), inline = TRUE))))
      tot <- function(v) if (all(is.na(v))) "\u2013" else format(round(sum(v, na.rm = TRUE)), big.mark = ",")
      rows <- c(rows, list(tags$tr(class = "wfp-quota-total",
        tags$td("Total"), tags$td(class = "num", tot(a$households)), tags$td(class = "num", tot(a$people)),
        tags$td(class = "num", tot(a$eligible)), tags$td(class = "num", tot(a$eligible_people)),
        tags$td(class = "num", textOutput(ns("fig_total"), inline = TRUE)),
        tags$td(class = "num", textOutput(ns("quota_total_entered"), inline = TRUE)), tags$td())))
      # One live flag per area: the caseload above what is eligible there
      # (eligible people or eligible households, in the caseload's unit).
      elig_in_unit <- if (identical(count_unit(), "people")) a$eligible_people else a$eligible
      for (i in seq_len(nrow(a))) local({
        ii <- i
        output[[paste0("quota_flag_", ii)]] <- renderUI({
          k <- quota_caseload()[ii]; el <- elig_in_unit[ii]
          if (is.na(k) || is.na(el) || k <= el) return(NULL)
          tags$span(class = "text-danger small", title = sprintf("%s %s asked, %s eligible", format(k, big.mark = ","), unit_word(), format(round(el), big.mark = ",")),
                    bsicons::bs_icon("exclamation-triangle-fill"), sprintf(" %s > %s eligible", format(k, big.mark = ","), format(round(el), big.mark = ",")))
        })
      })
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("table"), sprintf(" Caseload per %s", quota_label(input$ben_quota_unit))),
        size = "xl", easyClose = FALSE,
        tags$p(class = "small text-muted",
               sprintf("Each area is served up to its own caseload in %s, most vulnerable households first. Give the caseload of each area,", unit_word()),
               " or each area's share of a total caseload. Eligible households beyond an area's caseload are excluded by design (Advisory 2/2025)."),
        tags$div(class = "d-flex flex-wrap gap-3 align-items-end",
                 radioButtons(ns("quota_kind"), NULL, inline = TRUE, selected = kind,
                              choices = stats::setNames(c("households", "share"),
                                                        c(sprintf("Caseload per area (%s)", unit_word()), "Share (%) of a total caseload"))),
                 numericInput(ns("quota_total"), sprintf("Total caseload (%s)", unit_word()), value = if (same) plan$total else NA,
                              min = 1, step = 1, width = "200px")),
        # Fill the table from the total caseload in one click.
        tags$div(class = "d-flex flex-wrap gap-2 align-items-end wfp-quota-alloc",
                 tags$div(style = "min-width: 230px;",
                          selectInput(ns("fig_type"), "Reference figure in the table", width = "100%", selectize = FALSE,
                                      choices = fig_types(), selected = fig_type0)),
                 tags$div(style = "min-width: 320px;",
                          selectInput(ns("quota_alloc"), "Allocate the total caseload", width = "100%", selectize = FALSE,
                                      choices = alloc_choices(a))),
                 tags$div(class = "pb-3",
                          actionButton(ns("quota_allocate"), "Allocate", icon = icon("scale-balanced"), class = "btn-outline-primary"))),
        tags$div(class = "wfp-quota-table",
                 tags$table(class = "table table-sm align-middle mb-2",
                            tags$thead(tags$tr(tags$th("Area"), tags$th(class = "num", "Households"), tags$th(class = "num", "People"),
                                               tags$th(class = "num", "Eligible households"), tags$th(class = "num", "Eligible people"),
                                               tags$th(class = "num", textOutput(ns("fig_label"), inline = TRUE),
                                                       info_tip("The reference figure of each area (IPC population of the chosen phase, or the HNRP figure), typed or read from the data. The allocation can follow it.")),
                                               tags$th(class = "num", textOutput(ns("quota_col_label"), inline = TRUE)), tags$th(""))),
                            tags$tbody(rows))),
        uiOutput(ns("quota_check")),
        textAreaInput(ns("quota_rationale"), "Rationale for these caseloads (required)", rows = 3, width = "100%",
                      value = if (same) plan$rationale else "",
                      placeholder = "e.g. Caseloads follow the IPC phase 3+ population in each province and the partner capacity agreed with the cluster."),
        footer = tagList(modalButton("Cancel"),
                         actionButton(ns("quota_save"), "Save the caseloads", icon = icon("check"), class = "btn-primary"))
      ))
    })
    output$quota_col_label <- renderText(if (identical(input$quota_kind, "share")) "Share (%)" else sprintf("Caseload (%s)", unit_word()))
    quota_typed <- reactive({
      a <- quota_areas(); req(a)
      v <- vapply(seq_len(nrow(a)), function(i) suppressWarnings(as.numeric(input[[paste0("quota_", i)]] %||% NA)), numeric(1))
      stats::setNames(v, a$area)
    })
    typed_figs <- function(key) {
      a <- quota_areas(); req(a)
      stats::setNames(vapply(seq_len(nrow(a)), function(i) suppressWarnings(as.numeric(input[[paste0(key, "_", i)]] %||% NA)), numeric(1)), a$area)
    }
    output$fig_total <- renderText({ v <- typed_figs("fig"); if (all(is.na(v))) "" else format(round(sum(v, na.rm = TRUE)), big.mark = ",") })
    quota_caseload <- reactive({
      v <- quota_typed()
      if (identical(input$quota_kind, "share")) round((input$quota_total %||% NA) * v / 100) else round(v)
    })
    output$quota_total_entered <- renderText({
      v <- quota_typed()
      if (identical(input$quota_kind, "share")) sprintf("%.1f%%", sum(v, na.rm = TRUE)) else format(sum(v, na.rm = TRUE), big.mark = ",")
    })
    over_eligible <- function() {
      a <- quota_areas(); k <- quota_caseload()
      el <- if (identical(count_unit(), "people")) a$eligible_people else a$eligible
      o <- !is.na(k) & !is.na(el) & k > el
      a$area[o]
    }
    output$quota_check <- renderUI({
      over <- tryCatch(over_eligible(), error = function(e) character(0))
      over_note <- if (length(over)) tags$div(class = "small text-danger mb-1", bsicons::bs_icon("exclamation-triangle-fill"),
        sprintf(" %d area%s above %s eligible %s (%s): %s will serve all its eligible households, fewer than asked.",
                length(over), if (length(over) == 1) "" else "s", if (length(over) == 1) "its" else "their", unit_word(),
                paste(over, collapse = ", "), if (length(over) == 1) "it" else "each"))
      v <- quota_typed(); v[is.na(v)] <- 0
      if (identical(input$quota_kind, "share")) {
        tot <- sum(v); ok <- abs(tot - 100) < 0.05
        tagList(over_note, tags$div(class = paste("small mb-2", if (ok) "text-success" else "text-danger"),
                 bsicons::bs_icon(if (ok) "check-circle-fill" else "exclamation-triangle-fill"),
                 sprintf(" Shares add up to %.1f%%%s", tot, if (ok) "." else ": they must add up to 100% to save."),
                 if (ok && isTRUE(input$quota_total > 0)) sprintf(" %s %s in all.", format(sum(round(input$quota_total * v / 100)), big.mark = ","), unit_word())))
      } else {
        tagList(over_note, tags$div(class = "small mb-2 text-muted", sprintf("%s %s in all.", format(sum(v), big.mark = ","), unit_word())))
      }
    })
    observeEvent(input$quota_save, {
      a <- quota_areas(); v <- quota_typed()
      kind <- input$quota_kind %||% "households"
      need_ok(any(!is.na(v) & v > 0), "Give a caseload for at least one area.")
      need_ok(all(is.na(v) | v >= 0), "Caseloads cannot be negative.")
      v[is.na(v)] <- 0
      if (identical(kind, "share")) {
        need_ok(abs(sum(v) - 100) < 0.05, sprintf("The shares add up to %.1f%%: they must add up to 100%%.", sum(v)))
        need_ok(isTRUE(input$quota_total > 0), "Give the total caseload the shares apply to.")
      }
      need_ok(nzchar(trimws(input$quota_rationale %||% "")), "Write the rationale for these caseloads.")
      caseload <- if (identical(kind, "share")) round(input$quota_total * v / 100) else round(v)
      fv <- typed_figs("fig")
      quota_plan(list(unit = input$ben_quota_unit, kind = kind, count = count_unit(),
                      fig = if (all(is.na(fv))) NULL else as.list(fv), fig_type = input$fig_type %||% "ipc3plus", total = if (identical(kind, "share")) input$quota_total else sum(caseload),
                      values = as.list(v), caseload = as.list(stats::setNames(caseload, a$area)),
                      rationale = trimws(input$quota_rationale), set_at = fmt_datetime()))
      audit_add(modification_log, "Selection", "Caseload per area set",
                sprintf("%s per %s: %s %s in %d areas (%s)", if (identical(kind, "share")) "Shares" else "Caseloads",
                        quota_label(input$ben_quota_unit), format(sum(caseload), big.mark = ","), unit_word(), sum(caseload > 0),
                        paste(sprintf("%s %s", names(caseload), caseload)[caseload > 0], collapse = ", ")),
                reason = trimws(input$quota_rationale))
      removeModal()
      over <- tryCatch(over_eligible(), error = function(e) character(0))
      showNotification(paste0("Caseloads saved. Apply the selection to use them.",
                              if (length(over)) sprintf(" %s: caseload above the eligible households; all of them will be served.",
                                                        paste(over, collapse = ", ")) else ""),
                       type = if (length(over)) "warning" else "message", duration = if (length(over)) 10 else 5)
    })
    output$quota_summary <- renderUI({
      plan <- quota_plan()
      if (is.null(plan) || !identical(plan$unit, input$ben_quota_unit) || !identical(plan$count %||% "households", count_unit()))
        return(tags$div(class = "small text-warning", bsicons::bs_icon("exclamation-circle"), " No caseload set for this level yet."))
      k <- unlist(plan$caseload)
      tags$div(class = "small text-muted", bsicons::bs_icon("check-circle-fill", class = "text-success"),
               sprintf(" %s %s in %d areas (%s).", format(sum(k), big.mark = ","), plan$count %||% "households", sum(k > 0),
                       if (identical(plan$kind, "share")) "by share of the total" else "per area"))
    })

    # The whole registration data stays as it is; this module works on the
    # areas covered. Area choices and new variables use the whole data.
    full_df <- uploaded_df
    uploaded_df <- reactive({
      df <- full_df()
      if (is.null(df)) return(NULL)
      keep <- area_mask(df, user_setup, list(admin1 = applied$admin1, admin2 = applied$admin2, admin3 = applied$admin3))
      if (all(keep)) df else df[which(keep), , drop = FALSE]
    })

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
          if (!is.null(s$prio_count)) updateRadioButtons(session, "ben_prio_count", selected = s$prio_count)
          if (!is.null(s$quota_plan)) quota_plan(s$quota_plan)
          # the community values picker refills when its column arrives
          pending_comm_vals(s$comm_vals)
        })
      })
    pending_comm_vals <- reactiveVal(NULL)

    mod_var_calc_server("calc", full_df, function(df) full_df(df), modification_log)

    # Exports need a selection to export.
    observe({
      has <- !is.null(uploaded_df()) && isTRUE(tryCatch(any(selection()$prioritized), error = function(e) FALSE))
      why <- "Apply a selection that serves at least one household first."
      gate_button("export_open", has, why)
      gate_button("selection_report", has, why)
    })

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
      shinyWidgets::updatePickerInput(session, "ben_comm_vals", choices = value_choices(ch, col),
                                      selected = intersect(isolate(pending_comm_vals()) %||% character(0), ch))
      pending_comm_vals(NULL)
    })

    score_range <- reactiveValues(min = 0, max = 100)

    # Update choices and score range when data loads. The data also changes
    # when a column is added (variable calculator) or a record edited, so the
    # applied area and score are kept wherever they still fit the data.
    observe({
      req(full_df())
      df <- full_df()
      for (lvl in c("admin1", "admin2", "admin3")) {
        col <- user_setup[[lvl]]
        if (!is.null(col) && col %in% names(df)) {
          # The pickers' choices come from cascade_pickers() below.
          keep <- intersect(isolate(applied[[lvl]]) %||% character(0), unique(as.character(df[[col]])))
          applied[[lvl]] <- if (length(keep)) keep else NULL
        }
      }

      score_col <- user_setup$v_score
      if (!is.null(score_col) && score_col %in% names(df)) {
        vals <- as_number(df[[score_col]])
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

    # Each admin level lists only the areas inside those picked above.
    cascade_pickers(session, input, c("ben_admin1", "ben_admin2", "ben_admin3"),
                    cols = reactive(vapply(c("admin1", "admin2", "admin3"), function(l) as.character(user_setup[[l]] %||% "")[1], character(1))),
                    data = full_df)

    observeEvent(input$ben_apply, {
      req(input$ben_apply > 0)  # React buttons send an initial 0
      waiter::waiter_show(
        html = waiter_content("Applying the selection\u2026"),
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
      applied$prio_count <- count_unit()
      applied$use_scorecard <- !isFALSE(input$use_scorecard)
      applied$sc_threshold <- suppressWarnings(as.numeric(input$scorecard_threshold))
      if (length(applied$sc_threshold) != 1 || !is.finite(applied$sc_threshold)) applied$sc_threshold <- NULL
      if (identical(applied$prio_mode, "caseload")) {
        if (!nzchar(trimws(input$ben_prio_rationale %||% ""))) {
          applied$prio_mode <- "none"
          showNotification("Write the rationale for the caseload first (Prioritisation). The selection was applied without prioritisation.",
                           type = "warning", duration = 10)
        } else applied$prio_rationale <- trimws(input$ben_prio_rationale)
      }
      plan <- quota_plan()
      applied$quota_plan <- if (identical(applied$prio_mode, "per_unit") && !is.null(plan) && identical(plan$unit, applied$quota_unit) &&
                                identical(plan$count %||% "households", applied$prio_count)) plan
      if (identical(applied$prio_mode, "per_unit") && is.null(applied$quota_plan))
        showNotification("No caseload is set for this area level: every eligible household is served. Set the caseload per area first.",
                         type = "warning", duration = 10)
      audit_add(modification_log, "Selection", "Selection criteria applied",
                sprintf("%s; prioritisation: %s", targeting_approaches()[[applied$approach]]$label, applied$prio_mode))
      showNotification("Selection criteria applied.", type = "message")
    })

    observeEvent(input$ben_clear, {
      req(input$ben_clear > 0)  # React buttons send an initial 0
      waiter::waiter_show(
        html = waiter_content("Clearing the selection\u2026"),
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
      applied$quota_plan <- NULL
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
          id("value"), label = NULL,
          choices = value_choices(vals, if (startsWith(key, "col:")) sub("^col:", "", key) else as.character(user_setup[[key]] %||% "")[1]),
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
      req(input$btn_rules > 0)  # React buttons send an initial 0
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
      req(input$sc_rematch > 0)  # React buttons send an initial 0
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

      # the same quiet badges as the variable setup
      badge <- function(method, sim) {
        cls <- switch(method,
                      exact = "tw-conf tw-conf-high", case = "tw-conf tw-conf-high",
                      normalised = "tw-conf tw-conf-medium",
                      approximate = "tw-conf tw-conf-low",
                      "tw-conf tw-conf-in-use")
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
                     "tw-conf tw-conf-medium" else "tw-conf tw-conf-in-use", dirs[[crit]])),
          tags$div(class = "pt-2 small text-muted",
                   sprintf("%.2f pts  ", wts[[crit]]), badge(m$method[i], m$similarity[i])),
          selectizeInput(ns(paste0("xw_", i)), label = NULL, choices = choices,
                         selected = if (is.na(m$column[i])) "" else m$column[i], width = "100%")
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

    # The React page draws the card's controls (use_scorecard,
    # scorecard_threshold, sc_rematch, from output$ben_meta); only the file
    # loader stays a Shiny input.
    output$scorecard_ui <- renderUI({
      tags$div(
        class = "wfp-inline-file mt-1",
        fileInput(ns("sc_file"), label = NULL, accept = c(".xlsx", ".json"),
                  buttonLabel = "Load a scorecard or ranking", placeholder = "exported from Targeting Design (.xlsx)",
                  width = "100%")
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
          if (is_ranking(sc)) sprintf(" All %d criteria mapped. A vulnerability ranking built without an outcome indicator: its errors are not measured; calibrate it in Monitoring (PDM).", r$n)
          else sprintf(" All %d criteria mapped. Outcome: %s.", r$n, sc$outcome %||% "not recorded")
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
      if (isTRUE(applied$use_scorecard) && !scorecard_is_empty(sc)) {
        sc$threshold <- applied$sc_threshold %||% sc$threshold %||% 0
      } else {
        sc <- NULL
      }
      select_households(
        df, user_setup,
        approach = applied$approach,
        # The areas covered are applied to the data above, not as a criterion.
        area = list(),
        # The sidebar's household-criteria pickers were dropped: the
        # eligibility rules express the same conditions, on any column.
        filters = list(),
        ruleset = active_ruleset(),
        scorecard = sc,
        score_range = c(applied$score_min, applied$score_max),
        combine = applied$combine,
        community = list(column = applied$comm_col, values = applied$comm_vals),
        prioritization = list(mode = applied$prio_mode, n = applied$prio_n, count = applied$prio_count %||% "households",
                              unit = applied$quota_unit, quotas = applied$quota_plan$caseload)
      )
    })

    # The applied caseload plan per area, with what the selection did.
    caseload_table <- function(s, df_all) {
      qp <- applied$quota_plan
      if (!identical(applied$prio_mode, "per_unit") || is.null(qp)) return(NULL)
      col <- user_setup[[qp$unit]]
      if (!shiny::isTruthy(col) || !col %in% names(df_all)) return(NULL)
      k <- unlist(qp$caseload)
      u <- factor(as.character(df_all[[col]]), levels = names(k))
      hs <- user_setup$hh_size
      size <- if (shiny::isTruthy(hs) && hs %in% names(df_all)) as_number(df_all[[hs]]) else NULL
      n <- function(x) as.numeric(tapply(x, u, sum, na.rm = TRUE)[names(k)])
      out <- data.frame(Area = names(k), Households = n(rep(1, nrow(df_all))),
                        People = if (is.null(size)) NA else n(size),
                        `Eligible households` = n(s$eligible), `Eligible people` = if (is.null(size)) NA else n(ifelse(s$eligible, size, 0)),
                        check.names = FALSE)
      if (!is.null(qp$fig)) out[[fig_label(qp$fig_type)]] <- as.numeric(unlist(qp$fig)[names(k)])
      if (identical(qp$kind, "share")) out$`Share (%)` <- as.numeric(unlist(qp$values)[names(k)])
      people <- identical(qp$count, "people")
      out[[if (people) "Caseload (people)" else "Caseload (households)"]] <- as.numeric(k)
      out$`Served households` <- n(s$prioritized)
      if (!is.null(size)) out$`Served people` <- n(ifelse(s$prioritized, size, 0))
      out$`Excluded by design` <- n(s$eligible & !s$prioritized)
      el <- if (people && !is.null(size)) out$`Eligible people` else out$`Eligible households`
      out$Note <- ifelse(as.numeric(k) > el, sprintf("Caseload above the eligible %s", if (people) "people" else "households"), "")
      if (is.null(size)) out$People <- out$`Eligible people` <- NULL
      tot <- out[1, ]; tot$Area <- "Total"
      for (cl in setdiff(names(out), c("Area", "Note"))) tot[[cl]] <- sum(out[[cl]], na.rm = TRUE)
      tot$Note <- ""
      out <- rbind(out, tot)
      attr(out, "rationale") <- qp$rationale
      attr(out, "level") <- quota_label(qp$unit)
      attr(out, "kind") <- qp$kind
      attr(out, "count") <- qp$count %||% "households"
      attr(out, "total") <- qp$total
      out
    }

    selected_data <- reactive({
      df <- uploaded_df(); req(df)
      df[which(selection()$prioritized), , drop = FALSE]
    })

    # --- what the React page reads (react/src/pages/selection/) ---------------
    # Facts as JSON; the client draws them. Each comes from the reactives the
    # Shiny page used, so the two cannot disagree.
    sel_or_null <- function() tryCatch(selection(), error = function(e) NULL)
    fmt_n <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)

    # The approaches (which steps each uses), the card in use, the ranking charts.
    output$ben_meta <- shinyreact::reactive_output({
      a <- targeting_approaches()
      sc <- user_setup$scorecard
      card <- if (!scorecard_is_empty(sc)) list(word = card_word(sc), n = length(sc$items),
                                                threshold = as.numeric(sc$threshold %||% 0), fp = scorecard_fingerprint(sc))
      list(ready = !is.null(full_df()) && shiny::isTruthy(user_setup$unique_id),
           approaches = lapply(names(a), function(k) list(value = k, label = a[[k]]$label, description = a[[k]]$description,
                                                          gates = I(a[[k]]$gates), list = !isFALSE(a[[k]]$list))),
           card = card,
           ranking = if (isTRUE(applied$use_scorecard) && !is.null(card) && is_ranking(sc))
             list(profiles = !is.null(sc$ranking$profiles)))
    })

    # Settings wait for Apply: what differs from the applied selection.
    output$ben_pending <- shinyreact::reactive_output({
      if (is.null(full_df())) return(list(pending = I(character(0))))
      chr_same <- function(a, b) setequal(as.character(a %||% character(0)), as.character(b %||% character(0)))
      num_same <- function(a, b) {
        a <- suppressWarnings(as.numeric(a %||% NA))[1]; b <- suppressWarnings(as.numeric(b %||% NA))[1]
        (is.na(a) && is.na(b)) || isTRUE(abs(a - b) < 1e-9)
      }
      ap <- input$ben_approach %||% "hybrid"
      gates <- targeting_approaches()[[ap]]$gates %||% character(0)
      what <- character(0)
      if (!all(vapply(c("admin1", "admin2", "admin3"), function(k) chr_same(input[[paste0("ben_", k)]], applied[[k]]), TRUE)))
        what <- c(what, "areas covered")
      if (!identical(ap, applied$approach) || (identical(ap, "hybrid") && !identical(input$ben_combine %||% "both", applied$combine)))
        what <- c(what, "approach")
      if ("score" %in% gates) {
        sc <- user_setup$scorecard; card <- !scorecard_is_empty(sc)
        use <- card && !isFALSE(input$use_scorecard)
        changed <- if (card && use != isTRUE(applied$use_scorecard)) TRUE
                   else if (use) !num_same(input$scorecard_threshold, applied$sc_threshold %||% sc$threshold %||% 0)
                   else !num_same(input$ben_score_min, applied$score_min) || !num_same(input$ben_score_max, applied$score_max)
        if (changed) what <- c(what, "score")
      }
      if ("community" %in% gates && (!identical(input$ben_comm_col %||% "", applied$comm_col %||% "") ||
                                     !chr_same(input$ben_comm_vals, applied$comm_vals)))
        what <- c(what, "community decision")
      if (!identical(ap, "self")) {
        mode <- input$ben_prio_mode %||% "none"
        changed <- !identical(mode, applied$prio_mode) ||
          (identical(mode, "caseload") && (!num_same(input$ben_prio_n, applied$prio_n) || !identical(count_unit(), applied$prio_count))) ||
          (identical(mode, "per_unit") && (!identical(input$ben_quota_unit, applied$quota_unit) ||
                                           !identical(count_unit(), applied$prio_count) ||
                                           !identical(quota_plan(), applied$quota_plan)))
        if (changed) what <- c(what, "prioritisation")
      }
      list(pending = I(what))
    })

    output$selection_note <- shinyreact::reactive_output({
      s <- sel_or_null(); if (is.null(s)) return(NULL)
      a <- targeting_approaches()[[applied$approach]]
      list(label = a$label, list_produced = isTRUE(s$list_produced), eligible = sum(s$eligible),
           served = sum(s$prioritized), notes = I(as.character(unlist(s$notes))))
    })

    output$ben_total <- renderText({
      req(selected_data())
      format(nrow(selected_data()), big.mark = ",")
    })

    output$ben_indiv <- renderText({
      req(selected_data()); need_mapped(user_setup, "hh_size", short = TRUE)
      sizes <- as_number(selected_data()[[user_setup$hh_size]])
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
    output$ben_validation_plot <- render_echart({
      df <- selected_data(); req(df, nrow(df) > 0)
      keys <- c(Eligibility = "eligibility", `Vulnerability group` = "v_groups")
      parts <- list()
      for (nm in names(keys)) {
        col <- user_setup[[keys[[nm]]]]
        if (shiny::isTruthy(col) && col %in% names(df)) {
          tb <- table(as.character(df[[col]]), useNA = "no")
          if (length(tb)) parts[[length(parts) + 1]] <- data.frame(criterion = nm, category = names(tb), n = as.integer(tb), stringsAsFactors = FALSE)
        }
      }
      validate(need(length(parts) > 0, "Map eligibility or vulnerability groups to see what the selection is made of."))
      d <- do.call(rbind, parts)
      d$pct <- 100 * d$n / nrow(df)
      d <- d[order(d$criterion, -d$n), , drop = FALSE]
      labs <- paste0(d$category, "  \u00b7  ", d$criterion)
      crit <- unique(d$criterion)
      colour <- c(Eligibility = "#0A6EB4", `Vulnerability group` = "#f7b825")
      series <- lapply(crit, function(k) list(
        type = "bar", name = k, stack = "s", barMaxWidth = 22, itemStyle = list(color = colour[[k]]),
        data = lapply(seq_len(nrow(d)), function(i) if (d$criterion[i] != k) "-" else list(
          value = d$n[i],
          tip = sprintf("%s<br><b>%s</b> households (%.0f%%)", htmltools::htmlEscape(labs[i]), fmt_n(d$n[i]), d$pct[i]),
          label = list(show = TRUE, position = "right", fontSize = 10, formatter = sprintf("%s (%.0f%%)", fmt_n(d$n[i]), d$pct[i]))))))
      opt <- list(
        legend = list(show = length(crit) > 1, top = 0, left = 0),
        grid = list(left = 8, right = 76, top = if (length(crit) > 1) 30 else 8, bottom = 28, containLabel = TRUE),
        tooltip = list(trigger = "item", formatter = "fn:tip"),
        xAxis = list(type = "value", name = "Selected households", nameLocation = "middle", nameGap = 26),
        yAxis = list(type = "category", data = labs, inverse = TRUE),
        series = series)
      attr(opt, "height") <- max(300, min(560, 70 + 26 * nrow(d)))
      opt
    })

    # --- composition insights ------------------------------------------------
    col_of <- function(k) {
      cl <- as.character(user_setup[[k]] %||% "")[1]
      df <- uploaded_df()
      if (!is.na(cl) && nzchar(cl) && !is.null(df) && cl %in% names(df)) cl else NULL
    }

    # An adopted vulnerability ranking: the client shows its two charts when
    # output$ben_meta says one is in use.
    ranking_view <- reactive({
      sc <- user_setup$scorecard; df <- uploaded_df(); s <- selection()
      req(is_ranking(sc), df, length(s$prioritized) == nrow(df))
      list(dep = ranking_deprivations(df, sc), prof = ranking_profile_assign(df, sc), served = s$prioritized, sc = sc)
    })
    pct_axis <- function(name) list(type = "value", min = 0, max = 100,  # the card title names the axis
                                    axisLabel = list(formatter = "{value}%"))
    output$rank_dep_plot <- render_echart({
      v <- ranking_view(); ok <- !is.na(v$dep); req(any(ok))
      k <- sort(unique(v$dep[ok]))
      n <- as.numeric(table(factor(v$dep[ok], levels = k)))
      p <- 100 * as.numeric(tapply(v$served[ok], factor(v$dep[ok], levels = k), mean))
      list(tooltip = list(trigger = "item", formatter = "fn:tip"),
           grid = list(left = 8, right = 16, top = 16, bottom = 28, containLabel = TRUE),
           xAxis = list(type = "category", data = as.character(k), name = "Deprivations", nameLocation = "middle", nameGap = 26),
           yAxis = pct_axis("% selected"),
           series = list(list(type = "bar", barMaxWidth = 40, itemStyle = list(color = "#0A6EB4"),
                              data = lapply(seq_along(k), function(i) list(value = round(p[i], 1),
                                tip = sprintf("%s deprivations<br><b>%.0f%%</b> selected (of %s households)", k[i], p[i], fmt_n(n[i])))))))
    }, height = 320)
    output$rank_prof_plot <- render_echart({
      v <- ranking_view(); req(!is.null(v$prof))
      k <- ncol(v$sc$ranking$profiles)
      n <- vapply(seq_len(k), function(j) sum(v$prof == j, na.rm = TRUE), numeric(1))
      p <- vapply(seq_len(k), function(j) if (n[j] > 0) 100 * mean(v$served[which(v$prof == j)]) else 0, numeric(1))
      tg <- seq_len(k) %in% v$sc$ranking$target
      lab <- paste0("Profile ", seq_len(k), ifelse(tg, " (targeted)", ""))
      list(tooltip = list(trigger = "item", formatter = "fn:tip"),
           grid = list(left = 8, right = 16, top = 16, bottom = 8, containLabel = TRUE),
           xAxis = list(type = "category", data = lab, axisLabel = list(interval = 0, hideOverlap = TRUE)),
           yAxis = pct_axis("% selected"),
           series = list(list(type = "bar", barMaxWidth = 40,
                              data = lapply(seq_len(k), function(i) list(value = round(p[i], 1),
                                itemStyle = list(color = if (tg[i]) "#c5192d" else "#8a96a3"),
                                tip = sprintf("%s<br><b>%.0f%%</b> selected (of %s households)", lab[i], p[i], fmt_n(n[i])))))))
    }, height = 320)

    output$comp_insights <- shinyreact::reactive_output({
      s <- sel_or_null(); df <- uploaded_df()
      if (is.null(s) || is.null(df)) return(NULL)
      sel <- s$prioritized
      n_sel <- sum(sel)
      if (!n_sel) return(list(empty = TRUE, tiles = list()))
      tile <- function(icon, label, value, sub = "") list(icon = icon, label = label, value = as.character(value), sub = sub)
      cards <- list(tile("people", "Households served", sprintf("%.1f%%", 100 * n_sel / nrow(df)),
                         sprintf("%s of %s households", fmt_n(n_sel), fmt_n(nrow(df)))))
      hs <- col_of("hh_size")
      if (!is.null(hs)) {
        sz <- as_number(df[[hs]])
        cards <- c(cards, list(tile("person", "People served",
          sprintf("%.1f%%", 100 * sum(sz[sel], na.rm = TRUE) / sum(sz, na.rm = TRUE)),
          sprintf("Average household: %.1f people selected, %.1f not selected", mean(sz[sel], na.rm = TRUE), mean(sz[!sel], na.rm = TRUE)))))
      }
      sx <- col_of("hhh_sex")
      if (!is.null(sx)) {
        fem <- is_female(df[[sx]])
        if (any(fem)) cards <- c(cards, list(tile("female", "Female-headed households",
          sprintf("%.0f%% of the selected", 100 * mean(fem[sel])), sprintf("against %.0f%% of all households", 100 * mean(fem)))))
      }
      cut <- sum(s$eligible & !sel)
      if (cut) cards <- c(cards, list(tile("cut", "Unmet need", fmt_n(cut),
        "eligible households not served for lack of resources (excluded by design)")))
      a1 <- col_of("admin1")
      if (!is.null(a1)) {
        u <- as.character(df[[a1]])
        none <- setdiff(unique(u[s$eligible]), unique(u[sel]))
        if (length(none)) cards <- c(cards, list(tile("area", "Areas with eligible households, nobody served",
          length(none), paste(utils::head(none, 5), collapse = ", "))))
      }
      list(empty = FALSE, tiles = cards)
    })

    output$ben_area_plot <- render_echart({
      s <- selection(); df <- uploaded_df(); req(s, df)
      a <- col_of("admin1")
      validate(need(!is.null(a), "Map Admin 1 to see the selection by area."))
      colour <- c(Served = "#0A6EB4", `Excluded by design` = "#f7b825", `Not eligible` = "#b8c0ca")
      status <- factor(ifelse(s$prioritized, "Served", ifelse(s$eligible, "Excluded by design", "Not eligible")), levels = names(colour))
      m <- table(as.character(df[[a]]), status)
      top <- utils::head(names(sort(m[, "Served"] + m[, "Excluded by design"], decreasing = TRUE)), 25)
      opt <- list(
        legend = list(top = 0, left = 0),
        tooltip = list(trigger = "axis", axisPointer = list(type = "shadow")),
        grid = list(left = 8, right = 16, top = 30, bottom = 28, containLabel = TRUE),
        xAxis = list(type = "value", name = "Households", nameLocation = "middle", nameGap = 26),
        yAxis = list(type = "category", data = top, inverse = TRUE),
        series = lapply(names(colour), function(k) list(type = "bar", name = k, stack = "s", barMaxWidth = 22,
                                                       itemStyle = list(color = colour[[k]]), data = as.numeric(m[top, k]))))
      attr(opt, "height") <- max(300, min(640, 70 + 24 * length(top)))
      opt
    })

    current_profile <- function(df, sel) {
      keys <- c(hh_size = "Household size", hhh_age = "Head of household age", childU5 = "Children under 5",
                v_score = "Vulnerability score", hhh_sex = "Head of household sex", residency = "Residency status",
                disability = "Disability / chronic illness", v_groups = "Vulnerability group")
      cols <- Filter(Negate(is.null), lapply(stats::setNames(names(keys), names(keys)), col_of))
      if (!length(cols)) return(NULL)
      selection_profile(df, unlist(cols), keys, sel)
    }

    output$ben_profile <- shinyreact::reactive_output({
      s <- sel_or_null(); df <- uploaded_df()
      if (is.null(s) || is.null(df)) return(NULL)
      sel <- s$prioritized
      if (!any(sel) || all(sel)) return(list(message = "Needs both selected and non-selected households."))
      p <- current_profile(df, sel)
      if (is.null(p)) return(list(message = "Map household variables (size, age, sex...) to compare the groups."))
      list(rows = lapply(seq_len(nrow(p)), function(i) as.list(p[i, , drop = FALSE])))
    })

    # Identification columns only; everything else is behind Details. Paged by
    # the server above 5,000 rows.
    output$ben_table <- render_react_table({
      req(selected_data())
      record_table(selected_data(), user_setup, session$ns, "ben_view")
    }, html = "Details", empty = "Nobody selected.")


    observeEvent(input$ben_view, {
      showModal(record_detail_modal(
        find_record(selected_data(), user_setup, input$ben_view),
        title = paste("Selected household:", input$ben_view)
      ))
    })

    # -----------------------------------------------------------------------
    # Export: the user picks the variables, then downloads. The choice is kept
    # for the next export in this session.
    # -----------------------------------------------------------------------
    export_cols <- reactiveVal(NULL)
    observeEvent(input$export_open, {
      req(input$export_open > 0)  # React buttons send an initial 0
      df <- uploaded_df(); need_ok(!is.null(df), "Load the registration data and map its variables first.")
      cols <- names(df)
      # Identification and the mapped fields first, the rest after.
      keys <- c("unique_id", "admin1", "admin2", "admin3", "admin4", "village", "hh_size",
                "hhh_sex", "hhh_age", "v_score", "v_groups", "eligibility")
      mapped <- unique(unlist(lapply(keys, function(k) {
        cl <- user_setup[[k]]; if (shiny::isTruthy(cl) && cl %in% cols) cl
      })))
      ordered <- c(mapped, setdiff(cols, mapped))
      sel <- intersect(export_cols() %||% ordered, ordered)
      lv <- c("Admin 1" = "admin1", "Admin 2" = "admin2", "Admin 3" = "admin3", "Admin 4" = "admin4", "Village" = "village")
      split_levels <- lv[vapply(lv, function(k) shiny::isTruthy(user_setup[[k]]) && user_setup[[k]] %in% cols, logical(1))]
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("download"), " Export the selection"),
        size = "m", easyClose = TRUE,
        tags$p(class = "small text-muted",
               "Choose the variables to include in the Selected and Excluded-by-design sheets. ",
               "The Summary sheet is always included. Workbooks are locked for editing."),
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
        checkboxInput(ns("export_audit"), "Include the audit trail (Audit_trail sheet)", value = FALSE),
        radioButtons(ns("export_split"), "Files", inline = TRUE,
                     choices = c("One workbook" = "one", "One workbook per area (zipped)" = "area"),
                     selected = "one"),
        conditionalPanel(
          sprintf("input['%s'] === 'area'", ns("export_split")),
          selectInput(ns("export_split_level"), "Area level", width = "100%", selectize = FALSE,
                      choices = split_levels),
          tags$div(class = "small text-muted",
                   "One workbook per area, each named after its area (e.g. ..._Ituri.xlsx), in one .zip file.")),
        footer = tagList(modalButton("Cancel"),
                         downloadButton(ns("download_selection"), "Download", class = "btn-primary"))
      ))
      session$userData$export_mapped <- mapped
      session$userData$export_all <- ordered
    })
    observeEvent(input$export_mapped, shinyWidgets::updatePickerInput(session, "export_vars", selected = session$userData$export_mapped))
    observeEvent(input$export_all, shinyWidgets::updatePickerInput(session, "export_vars", selected = session$userData$export_all))
    observeEvent(input$export_vars, export_cols(input$export_vars), ignoreNULL = FALSE, ignoreInit = TRUE)

    # What the selection is and how it was made, as labelled sections. The
    # Excel summary sheet and the HTML report both use it, so they never
    # disagree.
    selection_sections <- function(s, df_all, keep_cols, with_audit = FALSE) {
      cut <- which(s$eligible & !s$prioritized)
      qp <- applied$quota_plan
      prio_desc <- if (identical(applied$prio_mode, "per_unit") && !is.null(qp)) {
        k <- unlist(qp$caseload)
        sprintf("caseload per %s, %s: %s %s in all (%s). Rationale: %s",
                quota_label(qp$unit), if (identical(qp$kind, "share")) sprintf("as shares of %s", format(qp$total, big.mark = ",")) else "set per area",
                format(sum(k), big.mark = ","), qp$count %||% "households", paste(sprintf("%s %s", names(k), format(k, big.mark = ",")), collapse = "; "), qp$rationale)
      } else if (!isTRUE(suppressWarnings(as.numeric(applied$prio_n)) > 0)) "none (all eligible served)" else switch(applied$prio_mode %||% "none",
        none = "none (all eligible served)",
        caseload = sprintf("total caseload of %s %s. Rationale: %s", applied$prio_n, applied$prio_count %||% "households",
                           applied$prio_rationale %||% "not recorded"),
        per_unit = sprintf("%s households per %s", applied$prio_n, applied$quota_unit))
      full <- selected_data()
      n_ind <- if (shiny::isTruthy(user_setup$hh_size) && user_setup$hh_size %in% names(full))
        sum(as_number(full[[user_setup$hh_size]]), na.rm = TRUE) else NA
      sc <- user_setup$scorecard
      sc_used <- isTRUE(applied$use_scorecard) && !scorecard_is_empty(sc)

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
          "Households in the data" = format(nrow(full_df()), big.mark = ","),
          "Households in the areas covered" = format(nrow(df_all), big.mark = ",")),
        "Areas covered" = c("Areas covered" = areas_covered_text(reactiveValuesToList(applied))),
        "Data preparation (before selection)" = c(
          "Records deleted" = format(length(deleted_uids(lg_sel)), big.mark = ","),
          "Values edited" = format(count_act("^Edit record"), big.mark = ","),
          "Location names normalised" = format(count_act("location normalization"), big.mark = ","),
          "Outlier values corrected" = format(count_act("Outlier correction"), big.mark = ","),
          "Reset to the original data" = if (count_act("Reset to original")) "yes" else "no",
          "Calculated variables" = if (is.null(calc) || !nrow(calc)) "none" else
            paste(sprintf("%s = %s", calc$column, calc$new_value), collapse = "; "),
          "Full history" = if (isTRUE(with_audit)) "see the Audit_trail sheet" else "in the app's Audit Trail (not exported)"),
        # what the registration data allowed (fields not mapped), and the
        # standardisation applied at import
        "Data available" = local({
          rd <- if (shiny::isTruthy(user_setup$unique_id)) data_readiness(reactiveValuesToList(user_setup))
          plan <- user_setup$setup_plan %||% list()
          c(if (!is.null(rd)) {
              off <- rd[rd$status != "Available", , drop = FALSE]
              if (nrow(off)) stats::setNames(sprintf("%s: %s", tolower(off$status), tolower(off$detail)), off$feature)
              else c("All features" = "available with the fields mapped")
            } else c("Readiness" = "not recorded (mapping made before this version)"),
            "Values standardised" = if (length(plan$recodes)) paste(vapply(names(plan$recodes), field_label, ""), collapse = ", ") else "none",
            "Import checks" = { ch <- user_setup$checks; if (is.null(ch) || !any(ch$level == "warn")) "no problem found" else paste(ch$message[ch$level == "warn"], collapse = " | ") })
        }),
        "Selection" = c(
          "Country office" = user_setup$country_office %||% "not set",
          "Exported" = fmt_datetime(),
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
        "Rules" = c(
          "Vulnerability score range" = paste(applied$score_min, "-", applied$score_max),
          "Eligibility rules" = ruleset_describe(active_ruleset(), user_setup, RULE_FIELDS),
          "Community selection" = if (shiny::isTruthy(applied$comm_col))
            sprintf("%s in {%s}", applied$comm_col, paste(applied$comm_vals %||% "", collapse = ", ")) else "n/a"),
        "Scorecard" = if (sc_used) c(
          "Scorecard" = sprintf("%d criteria, eligible when score > %s", length(sc$items), fmt5(sc$threshold %||% 0)),
          "Type" = if (is_ranking(sc)) "Vulnerability ranking (no outcome indicator; errors not measured)"
                   else if (is_pmt(sc)) "Proxy means test (predicts welfare per person against a poverty line)"
                   else "Scorecard (predicts an outcome)",
          "Ranking" = if (is_ranking(sc) && !is.null(sc$ranking))
            sprintf("%s%s; oriented by %s; stability %s; calibrate it on PDM data with an outcome (Monitoring)",
                    sc$ranking$method, if (nzchar(sc$ranking$label %||% "")) sprintf(" (%s)", sc$ranking$label) else "",
                    sc$ranking$oriented_by, if (is.na(sc$ranking$stability %||% NA)) "not checked" else sprintf("%.0f%%", 100 * sc$ranking$stability))
            else "n/a",
          "Status" = if (identical(sc$source, "design")) paste("adopted", sc$adopted_at %||% "") else "loaded from a workbook",
          "Designed on" = sc$created %||% "n/a",
          "Criteria" = paste(vapply(sc$items, function(it) sprintf("%s (%s%s)", it$criterion,
            if (identical(it$direction, "exclusion")) "-" else "+", fmt5(it$weight)), character(1)), collapse = "; "))
          else c("Scorecard" = "not used"),
        "Variable mapping" = stats::setNames(ifelse(nzchar(mapping), mapping, "not mapped"), map_keys),
        "Notes" = c("Notes" = if (length(s$notes)) paste(s$notes, collapse = " | ") else "none",
                    "Excluded by design" = "Eligible households not served for lack of resources: unmet need, not counted as exclusion error (Targeting Advisory 2/2025).")
      )
      sections
    }

    output$selection_report <- download_handler(
      filename = function() export_file_name("Beneficiary_selection_report", "html", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        s <- selection(); df_all <- uploaded_df()
        req(s, df_all)
        sections <- selection_sections(s, df_all, names(df_all))
        # The report is about the selection, not about which columns an
        # export carried.
        sections$Selection <- sections$Selection[names(sections$Selection) != "Variables exported"]
        sections[["Data preparation (before selection)"]][["Full history"]] <- "in the app's Audit Trail"
        hs <- col_of("hh_size")
        people <- if (is.null(hs)) NA else sum(as_number(df_all[[hs]])[s$prioritized], na.rm = TRUE)
        sel <- s$prioritized
        mp <- selection_map_points(df_all, user_setup, s)
        lang <- session$rootScope()$input$lang_selector
        mapped <- unlist(lapply(reactiveValuesToList(user_setup), function(v) if (is.character(v) && length(v) == 1) v))
        write_selection_report(file, list(
          variables_md = variables_md(intersect(mapped, names(df_all)), session),
          country_office = user_setup$country_office, sections = sections,
          areas = areas_covered_text(reactiveValuesToList(applied)),
          totals = c(households = nrow(df_all), eligible = sum(s$eligible), served = sum(sel),
                     excluded = sum(s$eligible & !sel), people = people),
          by_area = selection_by_area(df_all, user_setup, s),
          profile = if (any(sel) && !all(sel)) current_profile(df_all, sel),
          beneficiary_profile = beneficiary_profile(df_all[which(sel), , drop = FALSE], user_setup),
          rates = selection_rates(df_all, user_setup, sel),
          caseload = caseload_table(s, df_all),
          map = mp, map_n = attr(mp, "n_total")),
          lang = if (identical(lang, "fr")) "fr" else "en")
        audit_add(modification_log, "Selection", "Selection report exported",
                  sprintf("%s households served", format(sum(sel), big.mark = ",")))
      }
    )

    # Self-documenting export: rows + a metadata sheet (filters, totals, rules)
    output$download_selection <- download_handler(
      filename = function() {
        export_file_name("Targeting_BeneficiarySelection", if (identical(input$export_split, "area")) "zip" else "xlsx")
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
        # a vulnerability ranking adds what it knows of each household
        rk <- ranking_columns(df_all, user_setup$scorecard, s$score)
        if (!is.null(rk)) for (k in names(rk)) sel[[k]] <- rk[[k]][which(s$prioritized)]
        cut <- which(s$eligible & !s$prioritized)
        ex <- NULL
        if (length(cut)) {
          ex <- df_all[cut, intersect(keep_cols, names(df_all)), drop = FALSE]
          if (with_score) ex$selection_score <- s$score[cut]
          if (!is.null(rk)) for (k in names(rk)) ex[[k]] <- rk[[k]][cut]
        }
        full <- selected_data()
        lg <- if (is.function(modification_log)) modification_log() else NULL
        sections <- selection_sections(s, df_all, keep_cols, with_audit = isTRUE(input$export_audit))
        subtitle <- paste(c(user_setup$country_office, fmt_date()), collapse = " \u00b7 ")
        make_wb <- function(sel_df, ex_df, area = NULL) {
          wb <- openxlsx::createWorkbook()
          xl_summary_sheet(wb, "Summary", "Beneficiary selection",
                           if (is.null(area)) subtitle else paste(subtitle, area[["Area"]], sep = " \u00b7 "),
                           c(if (!is.null(area)) list("This file" = area), sections))
          xl_data_sheet(wb, "Selected", sanitize_for_excel(sel_df))
          if (is.null(area)) {
            by_area <- selection_by_area(df_all, user_setup, s)
            if (!is.null(by_area)) xl_data_sheet(wb, "By_area", by_area)
            ct <- caseload_table(s, df_all)
            if (!is.null(ct)) xl_data_sheet(wb, "Caseload_per_area", ct)
          }
          if (!is.null(ex_df) && nrow(ex_df)) xl_data_sheet(wb, "Excluded_by_design", sanitize_for_excel(ex_df))
          if (isTRUE(input$export_audit) && !is.null(lg) && nrow(lg)) {
            lg$timestamp <- fmt_datetime(lg$timestamp)
            xl_data_sheet(wb, "Audit_trail", sanitize_for_excel(data.frame(phase = audit_phase(lg$action), lg,
                                                                           stringsAsFactors = FALSE)))
          }
          wb
        }

        level <- input$export_split_level %||% "admin1"
        acol <- user_setup[[level]]
        if (identical(input$export_split, "area") && shiny::isTruthy(acol) && acol %in% names(df_all)) {
          # One locked workbook per area, named after it, in one zip.
          lab <- AREA_LEVELS[[level]]
          # An area is its whole path (a village name can repeat in two
          # districts); the file is named after the area itself, with its
          # parent added only when two names clash.
          path_cols <- vapply(names(AREA_LEVELS)[seq_len(match(level, names(AREA_LEVELS)))],
                              function(k) as.character(user_setup[[k]] %||% "")[1], character(1))
          path_cols <- path_cols[!is.na(path_cols) & nzchar(path_cols) & path_cols %in% names(df_all)]
          area_of <- function(d) do.call(paste, c(lapply(d[path_cols], function(x) {
            x <- as.character(x); x[is.na(x) | !nzchar(trimws(x))] <- "Missing"; x }), sep = " / "))
          sel_area <- area_of(full)
          ex_area <- area_of(df_all[cut, , drop = FALSE])
          areas <- sort(unique(c(sel_area, ex_area)))
          dir <- tempfile("selection_"); dir.create(dir)
          fnames <- paste0("Targeting_BeneficiarySelection_", area_file_suffix(area_short_names(areas)), ".xlsx")
          for (i in seq_along(areas)) {
            a <- areas[i]
            ex_a <- if (is.null(ex)) NULL else ex[ex_area == a, , drop = FALSE]
            wb <- make_wb(sel[sel_area == a, , drop = FALSE], ex_a,
                          area = c("Area level" = lab, "Area" = a,
                                   "Selected (served)" = format(sum(sel_area == a), big.mark = ","),
                                   "Excluded by design" = format(sum(ex_area == a), big.mark = ",")))
            save_workbook_readonly(wb, file.path(dir, fnames[i]))
          }
          zip::zipr(file, file.path(dir, fnames))
        } else {
          save_workbook_readonly(make_wb(sel, ex), file)
        }
      }
    )

    # What Targeting Monitoring draws its verification sample from: every
    # household of the areas covered, served or not, and eligible or not.
    list(frame = reactive({
      df <- uploaded_df(); req(df)
      s <- selection()
      list(df = df, served = s$prioritized, eligible = s$eligible)
    }))
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
  # decided once per distinct answer
  u <- unique(as.character(x))
  (tolower(trimws(u)) %in% c("f", "female", "femme", "feminin", "woman", "women", "fille"))[match(as.character(x), u)]
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
      f1 <- function(z, fmt) if (is.finite(z)) sprintf(fmt, z) else "\u2013"
      rows[[length(rows) + 1]] <- data.frame(
        indicator = paste(labels[[k]], "(mean)"), selected = f1(a, "%.1f"), not_selected = f1(b, "%.1f"),
        difference = f1(a - b, "%+.1f"), notable = is.finite(a) && is.finite(b) && b != 0 && abs(a - b) / abs(b) >= 0.2,
        stringsAsFactors = FALSE)
    } else {
      v <- as.character(x)
      v[is.na(v) | !nzchar(trimws(v))] <- "Not answered"
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

#' The area levels, top to bottom, down to the lowest mapped one
#' @noRd
AREA_LEVELS <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4", village = "Village")

#' Households and people served per area, for the export
#' @noRd
selection_by_area <- function(df, settings, s) {
  lv <- Filter(function(k) {
    cl <- as.character(settings[[k]] %||% "")[1]
    !is.na(cl) && nzchar(cl) && cl %in% names(df)
  }, names(AREA_LEVELS))
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
  names(out) <- AREA_LEVELS[lv]
  out$Households <- agg(rep(1, nrow(df)))
  out$Eligible <- agg(s$eligible)
  out$Served <- agg(s$prioritized)
  out$`Excluded by design` <- agg(s$eligible & !s$prioritized)
  out$`People served` <- agg(ifelse(s$prioritized, size, 0))
  out$`Served (%)` <- round(100 * out$Served / out$Households, 1)
  rownames(out) <- NULL
  out
}

#' Shortest unambiguous name for each area path ("A / B / C"): the last part,
#' with parents prefixed only where the last parts clash
#' @noRd
area_short_names <- function(paths) {
  parts <- strsplit(paths, " / ", fixed = TRUE)
  depth <- rep(1L, length(parts))
  repeat {
    nm <- vapply(seq_along(parts), function(i) {
      p <- parts[[i]]; paste(utils::tail(p, min(depth[i], length(p))), collapse = "_")
    }, character(1))
    clash <- nm %in% nm[duplicated(nm)] & depth < lengths(parts)
    if (!any(clash)) return(nm)
    depth[clash] <- depth[clash] + 1L
  }
}

#' File-name suffix for an area: ASCII letters, digits, - and _ only, unique
#' @noRd
area_file_suffix <- function(areas) {
  x <- iconv(as.character(areas), to = "ASCII//TRANSLIT", sub = "")
  x[is.na(x)] <- ""
  x <- gsub("[^A-Za-z0-9_-]+", "_", trimws(x))
  x <- gsub("^_+|_+$", "", x)
  x[!nzchar(x)] <- "area"
  make.unique(x, sep = "_")
}

#' What a vulnerability ranking adds to each household of a selection export
#' @return list of columns (priority_rank, deprivations, ranking_profile), or
#'   NULL when the card in use is not a ranking
#' @noRd
ranking_columns <- function(df, sc, score) {
  if (scorecard_is_empty(sc) || !is_ranking(sc) || is.null(df)) return(NULL)
  out <- list(priority_rank = rank(-score, ties.method = "min", na.last = "keep"),
              deprivations = ranking_deprivations(df, sc))
  pr <- ranking_profile_assign(df, sc)
  if (!is.null(pr)) out$ranking_profile <- paste0("Profile ", pr, ifelse(pr %in% sc$ranking$target, " (targeted)", ""))
  out
}
