#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  # A translator per request, never shared: it holds the selected language as
  # mutable state, so one global instance would mean the last person to switch
  # language changed it for everyone else on the server.
  i18n <- app_i18n()
  tr <- function(x) i18n_t(i18n, x)

  tagList(
    if (!is.null(i18n)) shiny.i18n::usei18n(i18n),
    tags$head(
      golem_add_external_resources()
      # Component styling lives in inst/app/www/custom.css (base) and
      # wfp-ui.css (soft-modern refresh + dark-mode tokens). bundle_resources()
      # loads www/*.css in alphabetical order, so wfp-ui.css overrides custom.css.
    ),
    # Force plotly dependencies to load
    # Force plotly dependencies to load
    htmltools::findDependencies(plotly::plot_ly(type = "scatter", mode = "none")),

    ## ------------- Waiters Paremeters
    # ---------------------------------------------------------------------------

    waiter::useWaiter(),
    # First screen while the app starts: the name and what it is for.
    waiter::waiterPreloader(html = startup_splash(), color = "#07456f"),

    ## -------------------- Start my UI Content
    # ---------------------------------------------------------------------------

    # Your application UI logic
    bslib::page_navbar(
      id = "main_nav", # Add this ID here

      title = tags$span(
        tags$img(
          src = "www/wfp-logo-standard-white-en.png",
          height = "35px", # Adjust based on your logo's proportions
          style = "margin-top: -5px; margin-right: 10px;" # Fine-tune alignment
        ),
        tags$span(class = "brand-text", "TargetWise")
      ),

      theme = bslib::bs_theme(
        version = 5,
        primary = "#0A6EB4",
        secondary = "#f7b825",
        success = "#3f7e44",
        info = "#26bde2",
        warning = "#f7b825",
        danger = "#c5192d",
        base_font = app_font(),
        code_font = app_font()
      ),
      # NEW: All styling goes inside navbar_options
      navbar_options = bslib::navbar_options(
        bg = "#0A6EB4",
        inverse = TRUE,
        underline = TRUE
      ),

      # Tab 0: ----------------- Landing page. Loads nothing: importing the
      # registration data is the first step of beneficiary selection, so it
      # lives in that phase, and the assessment and PDM extracts are loaded
      # inside the tabs that use them.
      bslib::nav_panel(
        title = tr("Welcome"),
        # Explicit value: bslib derives one from the title when it is missing,
        # and a translated title is a tag, so the panel ended up with its own
        # markup as its data-value.
        value = "welcome_panel",
        icon = icon("house"),
        mod_welcome_ui(tr)
      ),

      # The navigation follows the three phases of the targeting cycle, because
      # each phase runs on a different dataset and they must not be confused:
      #
      #   1. Targeting design      -> needs-assessment data (loaded in the tab)
      #   2. Beneficiary selection -> household registration data (Welcome page)
      #   3. Targeting monitoring  -> PDM data (loaded in the tab)
      #
      # Panel `value`s are unchanged, so nav_show()/nav_hide(), session restore
      # and every existing link keep working against the same identifiers.
      # ---------------------------------------------------------------------------

      # --- Phase 1: design the targeting, on assessment data ----------------
      bslib::nav_panel(
        value = "scorecard_panel",
        title = tr("1. Targeting Design"),
        icon = icon("scale-balanced"),
        mod_scorecard_ui("scorecard_1")
      ),

      # --- Phase 2: select beneficiaries, on registration data --------------
      bslib::nav_menu(
        title = tr("2. Beneficiary Selection"),
        # Explicit value for the same reason the panels have one: bslib derives
        # it from the title, and a translated title is a tag, so the menu ended
        # up carrying its own markup as its data-value.
        value = "selection_menu",
        icon = icon("user-check"),

        # First step of the phase, and the only panel in it that is available
        # before the variable mapping exists.
        bslib::nav_panel(
          value = "import_panel",
          title = tr("Load registration data"),
          icon = icon("upload"),
          mod_import_panel_ui(tr)
        ),
        bslib::nav_panel(
          title = tr("Overview"),
          value = "overview_panel",
          icon = icon("map"),
          mod_overview_ui("overview_1")
        ),
        bslib::nav_panel(
          value = "dq_panel",
          title = tr("Data Quality"),
          icon = icon("check-double"),
          mod_dq_ui("dq_1")
        ),
        bslib::nav_panel(
          value = "spot_panel",
          title = tr("Spot Checking"),
          icon = icon("magnifying-glass-location"),
          mod_spot_checking_ui("spot_checking_1")
        ),
        bslib::nav_panel(
          value = "ben_panel",
          title = tr("Selection"),
          icon = icon("person-circle-check"),
          mod_ben_selection_ui("ben_selection_1")
        )
      ),

      # --- Phase 3: monitor what was actually delivered, on PDM data --------
      bslib::nav_panel(
        value = "pdm_panel",
        title = tr("3. Targeting Monitoring"),
        icon = icon("bullseye"),
        mod_monitoring_ui("monitoring_1")
      ),

      # The audit trail covers all three phases, so it is a page of its own,
      # available from the start.
      bslib::nav_panel(
        value = "modif_logs",
        title = tr("Audit Trail"),
        icon = icon("clock-rotate-left"),
        mod_audit_ui("audit_1")
      ),

      bslib::nav_spacer(),

      # The country office the analysis is for; shown here and written on
      # every report and export.
      bslib::nav_item(uiOutput("co_badge", inline = TRUE)),

      # One theme only: the WFP palette, light or dark. The Bootswatch presets
      # that used to be offered here each needed their own contrast pass in two
      # modes, and none of them is a WFP design.
      bslib::nav_item(
        tags$div(
          class = "mini-theme-selector",
          tags$span(tr("Language")),
          shiny::selectInput(
            inputId = "lang_selector",
            label = NULL,
            choices = i18n_languages(),
            selected = "en",
            width = "120px",
            selectize = FALSE
          )
        )
      ),
      bslib::nav_item(
        tags$div(
          class = "session-toolbar",
          style = "display: flex; align-items: center; gap: 8px;",
          tags$span(tr("Session"), style = "font-size: 15px;"),
          mod_session_manager_ui("session_manager_1")
        )
      ),
      # Opens in light mode whatever the OS preference; the toggle still
      # switches to dark for the session.
      bslib::nav_item(bslib::input_dark_mode(id = "dark_mode", mode = "light"))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "TargetWise"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
