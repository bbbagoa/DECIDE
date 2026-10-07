#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  # The page does not depend on the request (it always opens in English; the
  # language switches in the browser), and building it takes seconds: it is
  # built once per R process and reused for every page load.
  if (is.null(.app_ui_cache$ui)) .app_ui_cache$ui <- app_ui_build()
  .app_ui_cache$ui
}
.app_ui_cache <- new.env(parent = emptyenv())

#' Build the application page (see `app_ui()`, which keeps it)
#'
#' A React client (shinyreact `ui.tsx` pattern): `react/src/` is built to
#' `inst/app/react/ui.js`, which draws the navbar and the pages ported to
#' React and hosts the other pages, rendered by the server (`legacy_pages()`,
#' `R/utils_react.R`). The WFP Bootstrap theme and the app's stylesheets and
#' scripts load as before, so hosted pages look and behave as they did.
#' @noRd
app_ui_build <- function() {
  i18n <- app_i18n()
  shinyreact::page_react(
    src_dir = app_sys("app/react"),
    title = "TargetWise",
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
    if (!is.null(i18n)) shiny.i18n::usei18n(i18n),
    tags$head(golem_add_external_resources()),
    # the dependencies of every widget the hosted pages use, loaded up front
    htmltools::findDependencies(plotly::plot_ly(type = "scatter", mode = "none")),
    waiter::useWaiter(),
    # First screen while the app starts: the name and what it is for.
    waiter::waiterPreloader(html = startup_splash(), color = "#07456f")
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
      app_title = "TargetWise",
      # a new address per installation: the browser fetches the new files
      version = tw_resource_version()
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
