#' React shell (shinyreact): navigation and hosted pages
#'
#' The page is a React client (`react/src/`, built to `inst/app/react/ui.js`)
#' served by `shinyreact::page_react()`. It owns the navbar; the server keeps
#' driving the navigation through `tw_nav()`, which sends the React shell the
#' message it used to send bslib (`nav_show()` / `nav_hide()` / `nav_select()`
#' on "main_nav"). `input$main_nav` still holds the current page.
#'
#' Pages not yet ported to React are the Shiny pages, hosted: the server
#' renders each into `output$pg_<page value>` (built once per R process, like
#' the page was), the client keeps them mounted and tells Shiny when one is
#' shown or hidden.
#' @name react_shell
NULL

#' Show, hide or select pages of the React navbar
#' @param action "show", "hide" or "select".
#' @param target Page value(s), e.g. "overview_panel".
#' @noRd
tw_nav <- function(action, target, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) return(invisible(NULL))
  root <- session$rootScope()
  if (identical(action, "select")) {
    # an event: go to that page now
    shinyreact::send_message(root, "tw-nav", list(action = "select", target = I(as.character(target))))
  } else {
    # state: which pages are hidden, read by the client from output$tw_nav_state
    rv <- root$userData$tw_hidden
    if (is.null(rv)) return(invisible(NULL))
    cur <- shiny::isolate(rv())
    rv(if (identical(action, "hide")) union(cur, target) else setdiff(cur, target))
  }
  invisible(NULL)
}

#' The navbar state the React shell reads (hidden pages); call once per session
#'
#' Pushed as a message once the client says it is ready (`input$tw_client_ready`,
#' react/src/App.tsx) and on every change: a root `reactive_output` computed in
#' the first flush, before React subscribed, never reached the client.
#' @noRd
tw_nav_state <- function(output, session) {
  rv <- session$userData$tw_hidden <- shiny::reactiveVal(character(0))
  shiny::observe({
    shiny::req(session$input$tw_client_ready > 0)
    shinyreact::send_message(session, "tw-nav-state", list(hidden = I(rv())))
  })
}

#' The Shiny pages not yet ported to React, by page value (built once per R
#' process: building them takes seconds)
#' @noRd
legacy_pages <- function() {
  i18n <- app_i18n()
  tr <- function(x) i18n_t(i18n, x)
  list(
    welcome_panel = function() mod_welcome_ui(tr),
    scorecard_panel = function() mod_scorecard_ui("scorecard_1"),
    import_panel = function() mod_import_panel_ui(tr),
    overview_panel = function() mod_overview_ui("overview_1"),
    dq_panel = function() mod_dq_ui("dq_1"),
    spot_panel = function() mod_spot_checking_ui("spot_checking_1"),
    ben_panel = function() mod_ben_selection_ui("ben_selection_1"),
    pdm_panel = function() mod_monitoring_ui("monitoring_1"),
    modif_logs = function() mod_audit_ui("audit_1")
  )
}

#' Render every page not drawn by React into its holder (called once per session)
#'
#' A page is built (and cached per R process) only when the client asks for
#' it: with every page in React, none is.
#' @noRd
render_legacy_pages <- function(output) {
  pages <- legacy_pages()
  input <- shiny::getDefaultReactiveDomain()$input
  for (nm in names(pages)) local({
    id <- paste0("pg_", nm)
    # not for the pages React draws (the client lists them in input$tw_ported)
    output[[id]] <- shiny::renderUI({
      shiny::req(!is.null(input$tw_ported))
      if (nm %in% unlist(input$tw_ported)) return(NULL)
      key <- paste0("page_", nm)
      if (is.null(.app_ui_cache[[key]])) .app_ui_cache[[key]] <- pages[[nm]]()
      .app_ui_cache[[key]]
    })
    # hosted pages start hidden; render them anyway so their inputs exist
    shiny::outputOptions(output, id, suspendWhenHidden = FALSE)
  })
  invisible(NULL)
}
