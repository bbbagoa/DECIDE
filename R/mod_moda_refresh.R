#' Refresh a page's MODA data (React: components/ModaRefresh.tsx)
#'
#' For a dataset that came from a MODA form (Targeting Design's assessment
#' data, PDM, a targeting-process dataset): fetch the submissions received
#' since, add them to the data already there (by `_id` / `_uuid`, the work on
#' the existing rows kept) and record it in the audit trail. The page keeps
#' the form id with its saved work, so the button is back after a restore;
#' the API key never is: the one typed earlier in the browser session is used
#' (`api_key_get()`), or a dialog asks for it. The registration data has its
#' own refresh (session toolbar, `app_server()`).
#'
#' @param get_data,set_data The page's data (whole, not the areas covered).
#' @param form A reactive: the MODA form id the data came from, or NULL.
#' @param name What the data is, for messages and the audit trail.
#' @noRd
mod_moda_refresh_server <- function(id, get_data, set_data, form, name = "Data", log = NULL, phase = "Design") {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    form_now <- function() { f <- tryCatch(form(), error = function(e) NULL); if (shiny::isTruthy(f)) as.character(f) else NULL }
    output$state <- shinyreact::reactive_output(list(form = form_now()))

    run <- function(token) {
      fid <- form_now(); df <- get_data()
      before <- NROW(df)
      moda_async_fetch(
        form_id = fid, token = token, existing_df = df, page_size = MODA_PAGE_SIZE, session = session,
        on_success = function(r) {
          set_data(as.data.frame(r$df))
          added <- NROW(r$df) - before
          audit_add(log, phase, "MODA refresh", sprintf("%s, form %s: %s new records (%s in all)", name, fid,
                                                         format(max(added, 0), big.mark = ","), format(NROW(r$df), big.mark = ",")))
          showNotification(if (added > 0) sprintf("%s: %s new submissions added (%s records in all).", name,
                                                  format(added, big.mark = ","), format(NROW(r$df), big.mark = ","))
                           else sprintf("%s: no new submission since the last download.", name),
                           type = "message", duration = 8)
        },
        on_error = function(msg) showNotification(paste("MODA refresh failed:", msg), type = "error", duration = NULL))
    }

    observeEvent(input$go, {
      req(input$go > 0)   # a React button sends 0 at start
      fid <- form_now()
      need_ok(!is.null(fid), "This data did not come from a MODA form.")
      need_ok(!is.null(get_data()), "No data loaded.")
      known <- api_key_get(session, "moda")
      if (!is.null(known)) return(run(known))
      showModal(modalDialog(
        title = tagList(icon("sync"), " Refresh from MODA"), size = "s", easyClose = TRUE,
        tags$p(class = "small", sprintf("%s, form %s. The data already loaded is kept; only the submissions received since are fetched.", name, fid)),
        passwordInput(ns("token"), "API Gateway Key", width = "100%"),
        tags$p(class = "small text-muted mb-0", "The key is kept in memory for this session only and is never saved."),
        footer = tagList(modalButton("Cancel"), actionButton(ns("go_key"), "Refresh", class = "btn-primary", icon = icon("sync")))
      ))
    })
    observeEvent(input$go_key, {
      tok <- trimws(input$token %||% "")
      if (!nzchar(tok)) { showNotification("Enter the API key.", type = "warning"); return() }
      api_key_set(session, tok, "moda")
      removeModal()
      run(tok)
    })
    invisible(NULL)
  })
}
