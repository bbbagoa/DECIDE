# Data Quality sub-tab: Health check. One row per check with what it found and
# a Review button that opens the tab holding the detail and the corrections.

dq_health_ui <- function(ns) {
  bslib::nav_panel(
    title = "Health check", value = "Health check",
    icon = bsicons::bs_icon("heart-pulse"),
    bslib::card(
      class = "mt-3",
      bslib::card_header(
        class = "d-flex align-items-center justify-content-between gap-2",
        tags$span(bsicons::bs_icon("heart-pulse"), " Health check of the data in scope"),
        actionButton(ns("hc_run"), "Run the health check", icon = icon("play"), class = "btn-primary btn-sm")),
      bslib::card_body(
        tags$p(class = "small text-muted mb-2",
               "A quick pass with the rules of each tab. Review opens the tab with the detail and the corrections;",
               " the Data quality report (sidebar) records everything."),
        uiOutput(ns("hc_table"))))
  )
}

dq_health_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  user_setup <- core$user_setup

  hc <- reactiveVal(NULL)
  observeEvent(input$hc_run, {
    req(input$hc_run > 0)   # a React button sends 0 at start
    df <- dq_filtered_data()
    need_ok(!is.null(df) && nrow(df) > 0, "Load and map the data first.")
    res <- tryCatch(dq_health(df, if (shiny::is.reactivevalues(user_setup)) shiny::reactiveValuesToList(user_setup) else user_setup),
                    error = function(e) { showNotification(conditionMessage(e), type = "error"); NULL })
    req(res)
    hc(list(res = res, n = nrow(df), at = fmt_datetime()))
  })
  # a Review button opens its tab
  observeEvent(input$hc_go, bslib::nav_select("dq_tabs", input$hc_go, session = session))

  # The result as data: the React page draws the table and its Review
  # buttons (react/src/pages/dq/HealthTab.tsx), which set input$hc_go.
  output$hc_table <- shinyreact::reactive_output({
    h <- hc()
    if (is.null(h)) return(NULL)
    r <- h$res
    list(rows = lapply(seq_len(nrow(r)), function(i) as.list(r[i, c("check", "tab", "found", "status")])),
         n = h$n, at = h$at)
  })
}
