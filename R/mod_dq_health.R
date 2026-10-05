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
    df <- dq_filtered_data()
    need_ok(!is.null(df) && nrow(df) > 0, "Load and map the data first.")
    res <- tryCatch(dq_health(df, if (shiny::is.reactivevalues(user_setup)) shiny::reactiveValuesToList(user_setup) else user_setup),
                    error = function(e) { showNotification(conditionMessage(e), type = "error"); NULL })
    req(res)
    hc(list(res = res, n = nrow(df), at = fmt_datetime()))
  })
  # a Review button opens its tab
  observeEvent(input$hc_go, bslib::nav_select("dq_tabs", input$hc_go, session = session))

  output$hc_table <- renderUI({
    h <- hc()
    if (is.null(h)) return(empty_state("Not run yet", "Click Run the health check to see what needs attention.", "heart-pulse"))
    r <- h$res
    pill <- function(st) switch(st,
      ok = tags$span(class = "tw-pill tw-pill-ok", "OK"),
      review = tags$span(class = "tw-pill tw-pill-review", "Review"),
      tags$span(class = "tw-pill tw-pill-na", "Not checked"))
    tagList(
      tags$div(class = "wfp-model-table-wrap", tags$table(
        class = "wfp-model-table",
        tags$thead(tags$tr(tags$th("Check"), tags$th("What was found"), tags$th("Status"), tags$th(""))),
        tags$tbody(lapply(seq_len(nrow(r)), function(i) tags$tr(
          tags$td(tags$strong(r$check[i])),
          tags$td(r$found[i]),
          tags$td(pill(r$status[i])),
          tags$td(class = "text-end",
                  tags$button(type = "button",
                              class = paste("btn btn-sm", if (identical(r$status[i], "review")) "btn-outline-primary" else "btn-outline-secondary"),
                              onclick = sprintf("Shiny.setInputValue('%s', '%s', {priority:'event'})", ns("hc_go"), r$tab[i]),
                              "Review"))))))),
      tags$div(class = "small text-muted mt-2",
               sprintf("Checked on %s records, %s. Run it again after corrections.", format(h$n, big.mark = ","), h$at)))
  })
}
