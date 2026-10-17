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
  setup <- function() if (shiny::is.reactivevalues(user_setup)) shiny::reactiveValuesToList(user_setup) else user_setup

  run_on <- function(df) {
    s <- setup()
    tryCatch(list(res = dq_health(df, s), ov = dq_health_overview(df, s), n = nrow(df), at = fmt_datetime()),
             error = function(e) { showNotification(conditionMessage(e), type = "error"); NULL })
  }
  # Light data is checked as soon as the tab is open (its outputs wait while
  # it is hidden) and again after every correction; heavy data on the button.
  light <- reactive({ df <- dq_filtered_data(); !is.null(df) && as.numeric(nrow(df)) * ncol(df) <= health_auto_cells() })
  manual <- reactiveVal(NULL)
  observeEvent(input$hc_run, {
    req(input$hc_run > 0)   # a React button sends 0 at start
    df <- dq_filtered_data()
    need_ok(!is.null(df) && nrow(df) > 0, "Load and map the data first.")
    manual(run_on(df))
  })
  current <- reactive({
    df <- dq_filtered_data()
    if (is.null(df) || !nrow(df)) return(NULL)
    if (light()) run_on(df) else manual()
  })
  # a Review button opens its tab
  observeEvent(input$hc_go, bslib::nav_select("dq_tabs", input$hc_go, session = session))

  # The result as data: the React page draws the checks, the figures and
  # their Review buttons (react/src/pages/dq/HealthTab.tsx).
  output$hc_table <- shinyreact::reactive_output({
    df <- dq_filtered_data()
    if (is.null(df)) return(NULL)
    h <- current()
    base <- list(auto = light(), records = nrow(df), variables = ncol(df))
    if (is.null(h)) return(base)
    r <- h$res; o <- h$ov
    c(base, list(rows = lapply(seq_len(nrow(r)), function(i) as.list(r[i, c("check", "tab", "found", "status")])),
                 n = h$n, at = h$at, completeness = o$completeness, dup_share = o$dup_share,
                 incomplete = sum(o$missing$pct > 10)))
  })

  hbar <- function(lab, val, colour, name, fmt = "fn:num") list(
    tooltip = list(trigger = "axis", axisPointer = list(type = "shadow")),
    grid = list(left = 8, right = 18, top = 8, bottom = 8, containLabel = TRUE),
    xAxis = list(type = "value", axisLabel = list(formatter = fmt)),
    yAxis = list(type = "category", data = lab, inverse = TRUE, axisLabel = list(width = 120, overflow = "truncate")),
    series = list(list(type = "bar", name = name, data = val, barMaxWidth = 16, itemStyle = list(color = colour, borderRadius = c(0, 3, 3, 0)))))
  output$hc_missing_plot <- render_echart({
    o <- current()$ov; req(o)
    validate(need(nrow(o$missing) > 0, "No missing answers: every column is complete."))
    opt <- hbar(o$missing$var, lapply(seq_len(nrow(o$missing)), function(i) list(value = o$missing$pct[i],
      itemStyle = list(color = if (o$missing$pct[i] > 10) "#c5192d" else "#f7b825"))), "#f7b825", "Missing (%)")
    opt$xAxis$name <- "% missing"; opt$xAxis$nameLocation <- "middle"; opt$xAxis$nameGap <- 24; opt$grid$bottom <- 24
    attr(opt, "height") <- max(220, 40 + 22 * nrow(o$missing)); opt
  })
  output$hc_area_plot <- render_echart({
    o <- current()$ov; req(o)
    validate(need(!is.null(o$areas), "Map an area level to see the records per area."))
    opt <- hbar(o$areas$area, o$areas$n, "#007DBC", "Records")
    attr(opt, "height") <- max(220, 40 + 22 * nrow(o$areas)); opt
  })
  output$hc_daily_plot <- render_echart({
    o <- current()$ov; req(o)
    validate(need(!is.null(o$daily), "Map the data collection date to see the interviews per day."))
    d <- o$daily
    opt <- list(tooltip = list(trigger = "axis"),
                grid = list(left = 8, right = 18, top = 12, bottom = 8, containLabel = TRUE),
                xAxis = list(type = "category", data = d$day, axisLabel = list(hideOverlap = TRUE)),
                yAxis = list(type = "value", name = "Interviews", minInterval = 1),
                series = list(list(type = "bar", name = "Interviews", data = d$n, barMaxWidth = 18,
                                   itemStyle = list(color = "#26bde2", borderRadius = c(3, 3, 0, 0)))))
    attr(opt, "height") <- 240; opt
  })
}
