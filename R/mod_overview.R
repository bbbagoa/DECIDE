#' Overview Module UI
#'
#' One screen: the map on the left half (full height), the insights on the
#' right half. The data collection (metrics and daily submissions) stays in
#' view at the top; who is in the data, their vulnerability and a free
#' explorer are sections below it, one open at a time, each scrolling inside
#' itself. The figures follow the map view (`ov_in_view()`).
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_overview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::layout_sidebar(
      fillable = TRUE, class = "tw-ov-page",
      sidebar = bslib::sidebar(
        width = 300, class = "wfp-side",
        side_steps(
          side_step("1. Areas", "geo-alt",
            shinyWidgets::pickerInput(
              inputId = ns("filter_admin1"), label = "Admin 1", choices = character(0), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE, selectedTextFormat = "count > 3")),
            shinyWidgets::pickerInput(
              inputId = ns("filter_admin2"), label = "Admin 2", choices = character(0), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE)),
            shinyWidgets::pickerInput(
              inputId = ns("filter_admin3"), label = "Admin 3", choices = character(0), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE))),
          side_step("2. Interview dates", "calendar-range",
            shinyWidgets::airDatepickerInput(
              inputId = ns("filter_date"), label = NULL, range = TRUE, dateFormat = "dd/MM/yyyy",
              value = c("2026-01-01", Sys.Date()), autoClose = TRUE, width = "100%"))),
        side_actions(
          tags$div(
            class = "d-flex gap-2",
            actionButton(ns("btn_apply_filters"), "Apply", class = "btn-primary btn-sm flex-fill", icon = icon("filter")),
            actionButton(ns("btn_clear_filters"), label = NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm",
                         title = "Clear the filters")),
          # What this page shows, as a report: the filters and the map view.
          downloadButton(ns("overview_report"), "Overview report (HTML)", class = "btn-outline-primary btn-sm w-100"))
      ),

      tags$div(
        class = "tw-ov",
        # Left half: the map, full height
        bslib::card(
          full_screen = TRUE, class = "wfp-map-card tw-ov-map",
          bslib::card_body(
          padding = 0, gap = 0, fillable = TRUE, class = "tw-ov-map-inner",
          tags$div(
            class = "wfp-map-toolbar",
            tags$div(class = "d-flex align-items-center gap-2",
                     tags$span(class = "wfp-map-toolbar-label", "Colour by"),
                     uiOutput(ns("map_var_ui"), class = "wfp-map-var"))),
          tags$div(class = "tw-ov-map-body", "The map is drawn by the React client."))
        ),
        # Right half: the collection stays in view, the sections below fold
        tags$div(
          class = "tw-ov-right",
          tags$div(
            class = "tw-ov-fixed",
            tags$div(
              class = "tw-ov-head",
              tags$span(class = "tw-ov-title", bsicons::bs_icon("broadcast"), " Data collection"),
              uiOutput(ns("view_chip"), inline = TRUE),
              tags$div(class = "tw-ov-follow",
                       tags$span(title = "On: the figures describe the households in the map view and follow it as you pan or zoom. Off: every household.",
                                 bslib::input_switch(ns("view_follow"), "Follow the map", value = FALSE)))),
            uiOutput(ns("readiness_strip")),
            uiOutput(ns("col_tiles")),
            tags$div(
              class = "tw-ov-daily",
              tags$div(class = "tw-ov-daily-bar",
                       tags$span(class = "tw-ov-sub", "Households per day"),
                       tags$div(class = "tw-seg",
                                shinyWidgets::radioGroupButtons(ns("daily_by"), NULL, choices = c("Total" = "total", "By area" = "area"),
                                                                selected = "area", size = "xs", status = "outline-primary"))),
              plotly::plotlyOutput(ns("daily_plot"), height = "205px"))
          ),
          bslib::accordion(
            id = ns("ov_sections"), multiple = FALSE, open = "who", class = "tw-ov-acc",
            bslib::accordion_panel(
              "Who is in the data", value = "who", icon = bsicons::bs_icon("people"),
              uiOutput(ns("who_ui"))),
            bslib::accordion_panel(
              "Vulnerability", value = "vuln", icon = bsicons::bs_icon("shield-exclamation"),
              uiOutput(ns("vuln_ui"))),
            bslib::accordion_panel(
              "Table builder", value = "explore", icon = bsicons::bs_icon("table"),
              uiOutput(ns("table_ui"))),
            bslib::accordion_panel(
              "Chart builder", value = "charts", icon = bsicons::bs_icon("bar-chart-line"),
              uiOutput(ns("chart_ui"))))
        )
      )
    )
  )
}

#' Overview Module Server
#'
#' @param id module id
#' @param uploaded_df reactive data
#' @param user_setup reactive values
#' @import shiny
#' @noRd
mod_overview_server <- function(id, uploaded_df, user_setup) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Registration data lists every household: the Overview counts each once,
    # whatever sampling weight the setup maps (the mapping without it).
    ov_setup <- reactive({ s <- reactiveValuesToList(user_setup); s$weight <- NULL; s })

  # Applied filter state (only refreshes outputs when Apply is clicked)
  applied_filters <- reactiveValues(
    admin1 = NULL,
    admin2 = NULL,
    admin3 = NULL,
    date = NULL
  )

  # 0. Update Date Range dynamically and initialize applied filters
  observe({
    req(uploaded_df())

    # Admin choices: cascade_pickers() below.

    # Date range
    if (shiny::isTruthy(user_setup$date)) {
      all_dates <- as.Date(uploaded_df()[[user_setup$date]])
      d_min <- min(all_dates, na.rm = TRUE)
      d_max <- max(all_dates, na.rm = TRUE)
      shinyWidgets::updateAirDateInput(
        session = session,
        inputId = "filter_date",
        value = c(d_min, d_max),
        options = list(minDate = d_min, maxDate = d_max)
      )
      applied_filters$date <- c(d_min, d_max)
    }

    # The data also changes on every correction: keep the applied areas that
    # still exist, as the pickers do.
    for (lvl in c("admin1", "admin2", "admin3")) {
      col <- user_setup[[lvl]]
      a <- isolate(applied_filters[[lvl]])
      if (length(a)) applied_filters[[lvl]] <- if (shiny::isTruthy(col) && col %in% names(uploaded_df()))
        intersect(a, unique(as.character(uploaded_df()[[col]]))) else NULL
    }
  })

  # Each admin level lists only the areas inside those picked above.
  cascade_pickers(session, input, c("filter_admin1", "filter_admin2", "filter_admin3"),
                  cols = reactive(vapply(c("admin1", "admin2", "admin3"), function(l) as.character(user_setup[[l]] %||% "")[1], character(1))),
                  data = uploaded_df)

  # --- Apply Filters ---
  observeEvent(input$btn_apply_filters, {
    req(input$btn_apply_filters > 0)   # a React button sends 0 at start
    waiter::waiter_show(
      html = waiter_content("Filtering the overview\u2026"),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    # from React: picks as a JSON list, dates as "YYYY-MM-DD" text
    applied_filters$admin1 <- as.character(unlist(input$filter_admin1))
    applied_filters$admin2 <- as.character(unlist(input$filter_admin2))
    applied_filters$admin3 <- as.character(unlist(input$filter_admin3))
    applied_filters$date <- tryCatch(as.Date(unlist(input$filter_date)), error = function(e) NULL)
    showNotification("Filters applied.", type = "message")
  })

  # --- Clear Filters ---
  observeEvent(input$btn_clear_filters, {
    req(input$btn_clear_filters > 0)
    waiter::waiter_show(
      html = waiter_content("Clearing the filters\u2026"),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    for (lvl in c("filter_admin1", "filter_admin2", "filter_admin3")) {
      shinyWidgets::updatePickerInput(session, lvl, selected = character(0))
    }
    if (shiny::isTruthy(user_setup$date)) {
      all_dates <- as.Date(uploaded_df()[[user_setup$date]])
      shinyWidgets::updateAirDateInput(session, "filter_date", value = c(min(all_dates, na.rm = TRUE), max(all_dates, na.rm = TRUE)))
    }
    applied_filters$admin1 <- NULL
    applied_filters$admin2 <- NULL
    applied_filters$admin3 <- NULL
    if (shiny::isTruthy(user_setup$date)) {
      applied_filters$date <- c(min(as.Date(uploaded_df()[[user_setup$date]]), na.rm = TRUE), max(as.Date(uploaded_df()[[user_setup$date]]), na.rm = TRUE))
    }
    showNotification("Filters cleared.", type = "message")
  })

  # --- Master Filtered Data (uses applied filters) ---
  output$overview_report <- download_handler(
    filename = function() export_file_name("Overview", "html", "%Y-%m-%d_%Hh%M"),
    content = function(file) {
      df <- view_data()
      d <- applied_filters$date
      lang <- session$rootScope()$input$lang_selector
      write_overview_report(file, df, ov_setup(), list(
        country_office = user_setup$country_office, source = user_setup$data_source,
        n_total = nrow(uploaded_df()), view = if (!is.null(view_rows())) view_label(),
        areas = areas_covered_text(list(admin1 = applied_filters$admin1, admin2 = applied_filters$admin2, admin3 = applied_filters$admin3)),
        period = if (length(d) == 2 && all(!is.na(d))) sprintf("%s to %s", format(as.Date(d[1])), format(as.Date(d[2]))) else "All dates"),
        lang = if (identical(lang, "fr")) "fr" else "en")
    }
  )
  observe(gate_button("overview_report", !is.null(tryCatch(filtered_data(), error = function(e) NULL)),
                      "Load the registration data and map its variables first."))

  filtered_data <- reactive({
    req(uploaded_df())
    df <- uploaded_df()

    if (shiny::isTruthy(user_setup$admin1) && shiny::isTruthy(applied_filters$admin1)) {
      df <- df[df[[user_setup$admin1]] %in% applied_filters$admin1, ]
    }
    if (shiny::isTruthy(user_setup$admin2) && shiny::isTruthy(applied_filters$admin2)) {
      df <- df[df[[user_setup$admin2]] %in% applied_filters$admin2, ]
    }
    if (shiny::isTruthy(user_setup$admin3) && shiny::isTruthy(applied_filters$admin3)) {
      df <- df[df[[user_setup$admin3]] %in% applied_filters$admin3, ]
    }
    if (shiny::isTruthy(user_setup$date) && shiny::isTruthy(applied_filters$date)) {
      df <- filter_by_date_range(df, user_setup$date, applied_filters$date)
    }

    return(df)
  })

  ### ----------------- Mapping vs Vulnerability
  # ---------------------------------------------------------------------------

  # Variables worth colouring the map by: the mapped setup fields, labelled.
  # Offering all 200-odd survey columns would make the dropdown useless.
  MAP_VAR_LABELS <- c(
    v_groups = "Vulnerability group", v_score = "Vulnerability score",
    eligibility = "Eligibility", residency = "Residence type",
    hhh_sex = "HH head sex", hhh_age = "HH head age", hh_size = "HH size",
    childU5 = "Children under 5", disability = "Disability / illness",
    hhid_avail = "HH head ID available", phone_avail = "Phone available",
    admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3",
    admin4 = "Admin 4", village = "Village", enumerator_id = "Enumerator"
  )

  map_var_choices <- reactive({
    df <- filtered_data()
    req(df)
    out <- character(0)
    for (k in names(MAP_VAR_LABELS)) {
      col <- user_setup[[k]]
      if (shiny::isTruthy(col) && col %in% names(df)) out[[MAP_VAR_LABELS[[k]]]] <- col
    }
    out
  })

  output$map_var_ui <- renderUI({
    ch <- map_var_choices()
    if (length(ch) == 0) return(NULL)
    selectInput(
      ns("map_var"), label = NULL, choices = ch, width = "100%", selectize = FALSE,
      selected = if (shiny::isTruthy(user_setup$v_groups) && user_setup$v_groups %in% ch) {
        user_setup$v_groups
      } else {
        unname(ch[[1]])
      }
    )
  })

  # Coordinates come back numeric from CSV but character or haven_labelled from
  # .sav/.dta, and every survey carries a few impossible fixes (0/0 nulls,
  # swapped pairs, decimal typos). Coerce once, then keep only plottable rows --
  # a single out-of-range point used to drag the map centre off the country.
  map_points <- reactive({
    req(filtered_data())
    need_mapped(user_setup, "lon", "lat")
    df <- filtered_data()
    req(user_setup$lon %in% names(df), user_setup$lat %in% names(df))

    lng <- as_number(df[[user_setup$lon]])
    lat <- as_number(df[[user_setup$lat]])
    ok <- is.finite(lng) & is.finite(lat) &
      abs(lng) <= 180 & abs(lat) <= 90 & !(lng == 0 & lat == 0)

    list(df = df[ok, , drop = FALSE], lng = lng[ok], lat = lat[ok], idx = which(ok),
         dropped = sum(!ok), total = length(ok))
  })

  # A single mis-keyed GPS fix (one row 10 degrees off) used to double the map
  # extent and shrink the real cluster to a speck in the corner. Fit the view to
  # the inner 99% and pad it -- every point is still drawn, the strays are just
  # outside the opening view until the user zooms out.
  fit_range <- function(x, p = 0.005) {
    if (length(x) < 20) return(range(x))
    q <- stats::quantile(x, c(p, 1 - p), names = FALSE, na.rm = TRUE)
    if (!all(is.finite(q)) || q[1] == q[2]) return(range(x))
    pad <- max(diff(q) * 0.05, 0.01)
    c(q[1] - pad, q[2] + pad)
  }

  # The map is drawn by the client (react/src/pages/overview/MapView.tsx:
  # MapLibre basemaps, deck.gl points). The server sends the points once per
  # data or filter change (map_points: the client fits the view to them) and
  # their colours separately (map_colours), so a new colour keeps the view.
  # Basemaps, box zoom, full screen and the light / dark basemap are the
  # client's; the view comes back as input$map_plot_bounds.
  output$map_points <- shinyreact::reactive_output({
    pts <- map_points()
    if (!length(pts$lng)) return(list(n = 0L, pos = "", bounds = NULL))
    xr <- fit_range(pts$lng); yr <- fit_range(pts$lat)
    map_points_payload(pts$lng, pts$lat, c(xr[1], yr[1], xr[2], yr[2]))
  })

  # The column the points are coloured by: the picker, else the vulnerability groups
  map_col <- function(df) {
    col <- if (shiny::isTruthy(input$map_var)) input$map_var else user_setup$v_groups
    if (shiny::isTruthy(col) && col %in% names(df)) col else NULL
  }
  # Coloured as categories (not a number scale) with more options than can be told apart
  map_too_many <- function(values, col) {
    as_scale <- is.numeric(values) && length(unique(stats::na.omit(values))) > 8
    !as_scale && !is.null(too_many_options(values, col))
  }
  map_drawn_col <- NULL
  # A refused variable keeps the colours drawn; `col` tells the client which
  # one that is, so the picker goes back to it.
  output$map_colours <- shinyreact::reactive_output({
    pts <- map_points()
    if (!length(pts$lng)) return(NULL)
    col <- map_col(pts$df)
    refused <- !is.null(col) && map_too_many(pts$df[[col]], col)
    if (refused) {
      showNotification(too_many_options(pts$df[[col]], col_label(col)), type = "warning", duration = 8)
      old <- map_drawn_col
      col <- if (!is.null(old) && old %in% names(pts$df) && !map_too_many(pts$df[[old]], old)) old
    }
    map_drawn_col <<- col
    values <- if (is.null(col)) rep(NA_character_, nrow(pts$df)) else pts$df[[col]]
    c(list(col = col %||% "", title = col %||% "", refused = refused), map_colour_codes(values))
  })

  # A household's popup: its id, where it is, and the value it is coloured by
  map_popup <- function(df, i, col, values) {
    fld <- function(k) { cl <- user_setup[[k]]; if (shiny::isTruthy(cl) && cl %in% names(df)) as.character(df[[cl]][i]) else rep("", length(i)) }
    esc <- function(x) htmltools::htmlEscape(ifelse(is.na(x), "", x))
    sprintf("<div class='wfp-map-pop'><b>%s</b><span>%s</span>%s</div>",
            esc(fld("unique_id")), esc(paste(fld("admin2"), fld("village"), sep = " \u00b7 ")),
            if (is.null(col)) "" else sprintf("<span>%s</span><strong>%s</strong>", esc(col), esc(as.character(values[i]))))
  }
  # A click on a point sends its place in map_points (from 1); the popup goes
  # back as a message, built for that household only.
  observeEvent(input$map_click, {
    ev <- input$map_click
    pts <- tryCatch(map_points(), error = function(e) NULL)
    i <- suppressWarnings(as.integer(ev$i)[1])
    if (is.null(pts) || is.na(i) || i < 1 || i > nrow(pts$df)) return()
    col <- map_col(pts$df)
    values <- if (is.null(col)) NULL else pts$df[[col]]
    if (inherits(values, "haven_labelled")) values <- labelled_to_plain(data.frame(v = values))$v
    shinyreact::send_message(session, "map_popup", list(
      lng = pts$lng[i], lat = pts$lat[i], nonce = ev$nonce %||% 0, html = map_popup(pts$df, i, col, values)))
  })

  ### ----------------- The figures follow the map view
  # ---------------------------------------------------------------------------

  # The households the insights describe: all of them, or, with "Follow the
  # map" on (off by default), those in the map view, following it as the map
  # moves (debounced so a pan recomputes once).
  map_bounds <- shiny::debounce(reactive(input$map_plot_bounds), 600)
  view_bounds <- reactive(if (isTRUE(input$view_follow)) map_bounds())
  view_rows <- reactive({
    b <- view_bounds(); if (is.null(b)) return(NULL)
    pts <- tryCatch(map_points(), error = function(e) NULL)
    if (is.null(pts) || !length(pts$idx)) return(NULL)
    ov_in_view(pts$lng, pts$lat, pts$idx, b)
  })
  view_data <- reactive({
    df <- filtered_data(); r <- view_rows()
    if (is.null(r)) df else df[r, , drop = FALSE]
  })
  view_label <- reactive({
    n_all <- nrow(filtered_data())
    if (is.null(view_rows())) sprintf("All %s households", ov_num(n_all))
    else sprintf("Map view: %s of %s households", ov_num(length(view_rows())), ov_num(n_all))
  })

  output$view_chip <- renderUI({
    req(filtered_data())
    zoomed <- !is.null(view_rows())
    tags$span(class = paste("tw-ov-chip", if (zoomed) "zoomed"), bsicons::bs_icon(if (zoomed) "zoom-in" else "globe2"), " ", view_label(),
              if (zoomed) actionLink(ns("view_all"), "show all", class = "ms-1"))
  })
  # "show all" (input$view_all): the client turns Follow off and fits the map
  # to the households itself (MapView.tsx).

  ### ----------------- 1. Data collection (always in view)
  # ---------------------------------------------------------------------------

  collection <- reactive({ df <- view_data(); req(nrow(df) > 0); ov_collection(df, ov_setup()) })
  ov_tiles <- function(tiles, cls = "") {
    if (!length(tiles)) return(NULL)
    if (any(vapply(tiles, function(t) !is.null(t$share), logical(1)))) return(HTML(ov_tiles_html(tiles)))
    tags$div(class = paste("tw-tiles", cls), lapply(tiles, function(t) tags$div(
      class = "tw-tile", title = t$sub, `data-key` = t$label,
      tags$div(class = "tw-tile-top", bsicons::bs_icon(t$icon %||% "dot"), tags$span(class = "tw-tile-label", t$label)),
      tags$div(class = "tw-tile-value", t$value),
      tags$div(class = "tw-tile-sub", t$sub))))
  }
  output$col_tiles <- renderUI(ov_tiles(collection()$tiles, "tw-tiles-col"))

  AREA_COLS <- c("#007DBC", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#8a96a3")
  output$daily_plot <- render_wfp_plotly({
    cl <- collection()
    shiny::validate(shiny::need(!is.null(cl$daily), "Not in these data: map the data collection date to see the daily submissions."))
    d <- cl$daily
    by_area <- identical(input$daily_by, "area") && !is.null(cl$area_label)
    if (!by_area) d <- stats::aggregate(list(n = d$n), list(day = d$day), sum)
    tot <- stats::aggregate(list(n = d$n), list(day = d$day), sum); tot$cum <- cumsum(tot$n)
    p <- if (by_area) {
      # one colour per area whatever the map view: set on all the filtered data
      a1 <- ov_col(user_setup, filtered_data(), "admin1")
      all_areas <- sort(unique(c(as.character(filtered_data()[[a1]]), "Other areas", "(no area)")))
      pal <- stats::setNames(rep_len(AREA_COLS, length(all_areas)), all_areas)
      plotly::plot_ly(d, x = ~day, y = ~n, color = ~area, colors = pal[unique(d$area)], type = "bar",
                      hovertemplate = "%{x|%d %b}: %{y:,.0f} households<extra>%{fullData.name}</extra>")
    } else {
      plotly::plot_ly(d, x = ~day, y = ~n, type = "bar", marker = list(color = "#007DBC"), name = "Households",
                      hovertemplate = "%{x|%d %b}: %{y:,.0f} households<extra></extra>")
    }
    p |>
      plotly::add_lines(data = tot, x = ~day, y = ~cum, yaxis = "y2", inherit = FALSE, name = "Cumulative",
                        line = list(color = "#5b6b7c", width = 1.5, dash = "dot"), hovertemplate = "%{x|%d %b}: %{y:,.0f} in all<extra></extra>") |>
      plotly::layout(barmode = "stack", bargap = 0.15, showlegend = by_area,
                     legend = list(orientation = "h", y = 1.02, yanchor = "bottom", x = 0, font = list(size = 9), itemwidth = 30),
                     margin = list(l = 30, r = 36, t = if (by_area) 16 else 4, b = 20),
                     xaxis = list(title = "", type = "date", tickformat = "%d/%m", hoverformat = "%d/%m/%Y", tickfont = list(size = 10)),
                     yaxis = list(title = "", tickfont = list(size = 10)),
                     yaxis2 = list(overlaying = "y", side = "right", showgrid = FALSE, title = "", tickfont = list(size = 9), rangemode = "tozero"))
  })

  ### ----------------- Compact charts shared by the sections
  # ---------------------------------------------------------------------------

  # shares as short horizontal bars (categories) or columns (bins)
  share_plot <- function(ch) {
    d <- ch$data; d$pct <- d$n / sum(d$n)
    if (identical(ch$kind, "bins")) {
      plotly::plot_ly(d, x = ~factor(category, levels = category), y = ~pct, type = "bar", marker = list(color = "#007DBC"),
                      text = ~sprintf("%.0f%%", 100 * pct), textposition = "outside", cliponaxis = FALSE, textfont = list(size = 9),
                      hovertemplate = "%{x}: %{y:.1%} (%{customdata:,.0f} households)<extra></extra>", customdata = ~n) |>
        plotly::layout(margin = list(l = 8, r = 8, t = 6, b = 26), yaxis = list(visible = FALSE, range = c(0, max(d$pct) * 1.25)),
                       xaxis = list(title = "", tickfont = list(size = 10)))
    } else {
      d <- d[rev(seq_len(nrow(d))), , drop = FALSE]
      plotly::plot_ly(d, y = ~factor(category, levels = category), x = ~pct, type = "bar", orientation = "h", marker = list(color = "#007DBC"),
                      text = ~sprintf("%.0f%%", 100 * pct), textposition = "outside", cliponaxis = FALSE, textfont = list(size = 9),
                      hovertemplate = "%{y}: %{x:.1%} (%{customdata:,.0f} households)<extra></extra>", customdata = ~n) |>
        plotly::layout(margin = list(l = 8, r = 30, t = 6, b = 6), xaxis = list(visible = FALSE, range = c(0, max(d$pct) * 1.3)),
                       yaxis = list(title = "", tickfont = list(size = 10), automargin = TRUE))
    }
  }
  mini_chart <- function(id, title, height = 170) tags$div(class = "tw-mini",
    tags$div(class = "tw-mini-title", title), plotly::plotlyOutput(ns(id), height = paste0(height, "px")))

  ### ----------------- 2. Who is in the data
  # ---------------------------------------------------------------------------

  profile <- reactive({ df <- view_data(); req(nrow(df) > 0); ov_profile(df, ov_setup()) })
  PROFILE_CHARTS <- c("age", "size", "u5", "residency")   # sex: the female-headed ring says it
  output$who_ui <- renderUI({
    pr <- profile()
    if (is.null(pr)) return(empty_state("No household characteristic is mapped",
                                        "Map the head's sex and age, household size, children under 5, residence status... in Variable Definition & Setup.", "people"))
    charts <- intersect(PROFILE_CHARTS, names(pr$charts))
    tagList(ov_tiles(pr$tiles, "tw-tiles-small"),
            if (length(charts)) tags$div(class = "tw-mini-grid", lapply(charts, function(k) mini_chart(paste0("who_", k), pr$charts[[k]]$title))))
  })
  for (k in PROFILE_CHARTS) local({
    key <- k
    output[[paste0("who_", key)]] <- render_wfp_plotly({
      ch <- profile()$charts[[key]]; req(ch, nrow(ch$data) > 0)
      share_plot(ch)
    })
  })

  ### ----------------- 3. Vulnerability
  # ---------------------------------------------------------------------------

  # every indicator's cross computed together: the picker only switches views
  vuln_all <- reactive({
    df <- view_data(); req(nrow(df) > 0)
    v <- ov_vulnerability(df, ov_setup(), NULL)
    if (is.null(v)) return(NULL)
    by <- stats::setNames(lapply(v$available, function(ind) if (identical(ind, v$indicator)) v else ov_vulnerability(df, ov_setup(), ind)), v$available)
    list(base = v, by = by)
  })
  vuln <- reactive({
    a <- vuln_all(); if (is.null(a)) return(NULL)
    ind <- input$vuln_indicator
    if (isTRUE(ind %in% names(a$by))) a$by[[ind]] else a$base
  })
  output$vuln_ui <- renderUI({
    v <- vuln()
    if (is.null(v)) return(empty_state("No vulnerability variable is mapped",
                                       "Map a vulnerability score, vulnerability groups or eligibility in Variable Definition & Setup, or build a scorecard in Targeting Design.", "shield"))
    ind_choices <- c(eligible = "Share eligible", vulnerable = "Share in the most vulnerable groups", score = "Mean score")[v$available]
    n_cross <- if (is.null(v$cross)) 0 else nrow(v$cross)
    tagList(
      tags$div(class = "tw-mini-grid",
        if (!is.null(v$groups)) mini_chart("vuln_groups", "Households by vulnerability group", 200),
        if (!is.null(v$score)) mini_chart("vuln_score", "Distribution of the vulnerability score", 200)),
      if (n_cross) tags$div(class = "tw-mini tw-mini-wide",
        tags$div(class = "tw-mini-title d-flex align-items-center justify-content-between gap-2",
                 tags$span("Across household profiles"),
                 selectInput(ns("vuln_indicator"), NULL, choices = stats::setNames(names(ind_choices), unname(ind_choices)),
                             selected = v$indicator, width = "220px", selectize = FALSE)),
        plotly::plotlyOutput(ns("vuln_cross"), height = paste0(max(160, 17 * n_cross + 40), "px"))))
  })
  output$vuln_groups <- render_wfp_plotly({
    g <- vuln()$groups; req(g)
    g$pct <- g$households / sum(g$households)
    cols <- vapply(seq_len(nrow(g)) / nrow(g), diagram_colour, "")
    g <- g[rev(seq_len(nrow(g))), , drop = FALSE]; cols <- rev(cols)
    plotly::plot_ly(g, y = ~factor(group, levels = group), x = ~pct, type = "bar", orientation = "h", marker = list(color = cols),
                    text = ~sprintf("%.0f%%", 100 * pct), textposition = "outside", cliponaxis = FALSE, textfont = list(size = 9),
                    customdata = ~people,
                    hovertemplate = "%{y}: %{x:.1%} of households<br>%{customdata:,.0f} people<extra></extra>") |>
      plotly::layout(margin = list(l = 8, r = 30, t = 6, b = 6), xaxis = list(visible = FALSE, range = c(0, max(g$pct) * 1.3)),
                     yaxis = list(title = "", tickfont = list(size = 10), automargin = TRUE))
  })
  output$vuln_score <- render_wfp_plotly({
    s <- vuln()$score; req(s)
    share_plot(list(kind = "bins", data = s)) |> plotly::layout(xaxis = list(tickfont = list(size = 8), tickangle = -45))
  })
  output$vuln_cross <- render_wfp_plotly({
    v <- vuln(); d <- v$cross; req(d, nrow(d) > 0)
    pct <- !identical(v$indicator, "score")
    overall <- ov_wmean(d$value, d$households)
    d$label <- paste0(d$category, " ")
    d$lab <- factor(d$label, levels = rev(unique(d$label)))
    dims <- unique(d$dimension)
    plotly::plot_ly(d, y = ~lab, x = ~value, color = ~dimension, colors = stats::setNames(rep_len(AREA_COLS, length(dims)), dims),
                    type = "bar", orientation = "h", customdata = ~households,
                    text = ~if (pct) sprintf("%.0f%%", 100 * value) else sprintf("%.1f", value), textposition = "outside", cliponaxis = FALSE,
                    textfont = list(size = 9),
                    hovertemplate = paste0("%{y}<br>", v$indicator_label, ": ", if (pct) "%{x:.1%}" else "%{x:.1f}",
                                           "<br>%{customdata:,.0f} households<extra>%{fullData.name}</extra>")) |>
      plotly::layout(showlegend = TRUE, legend = list(orientation = "h", y = -0.02, yanchor = "top", font = list(size = 9)),
                     margin = list(l = 8, r = 34, t = 4, b = 4),
                     xaxis = list(title = "", tickformat = if (pct) ".0%" else NULL, tickfont = list(size = 9)),
                     yaxis = list(title = "", tickfont = list(size = 10), automargin = TRUE),
                     shapes = list(list(type = "line", x0 = overall, x1 = overall, yref = "paper", y0 = 0, y1 = 1,
                                        line = list(color = "#5b6b7c", dash = "dot", width = 1))))
  })

  ### ----------------- Explore two variables
  # ---------------------------------------------------------------------------

  # Explore two variables: a contingency table (households, row / column /
  # total percentages, or the mean or sum of a number) and the correlations.
  col_label <- function(cl) { l <- var_label(cl); if (is.na(l) || !nzchar(l)) cl else l }
  # The columns both builders offer: mapped fields first, then the others;
  # never identifiers, names, phone numbers or free text (analysis_cols()).
  explore_cols <- reactive({
    df <- filtered_data(); req(df)
    setup_list <- reactiveValuesToList(user_setup)
    skip_keys <- c("unique_id", "date", "lon", "lat", "weight")
    keys <- setdiff(intersect(setup_keys(), names(setup_list)), skip_keys)
    mapped <- unique(unlist(lapply(keys, function(k) { v <- as.character(setup_list[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v) && v %in% names(df)) v })))
    mapped <- analysis_cols(df, mapped)
    others <- analysis_cols(df, setdiff(names(df)[!grepl("^@?_", names(df))], c(mapped, unlist(setup_list[skip_keys]))))
    ch <- col_choice_groups(`Mapped fields` = mapped, `Other columns` = others)
    all <- unlist(ch, use.names = FALSE)
    # numbers, including numbers stored as text (Excel, MODA exports)
    # (judged on the distinct values: converting every household's answer
    # took seconds on large data)
    nums <- all[vapply(df[all], function(x) {
      u <- unique(x); u <- u[!is.na(u)]
      z <- if (is.numeric(u)) u else suppressWarnings(as.numeric(as.character(u)))
      length(u) > 2 && mean(!is.na(z)) > 0.95 }, logical(1))]
    list(ch = ch, all = all, nums = nums)
  })
  # The builders are drawn by React (react/src/pages/overview/Builders.tsx):
  # the columns they offer, as JSON
  output$ov_explore <- shinyreact::reactive_output({
    ec <- tryCatch(explore_cols(), error = function(e) NULL)
    if (is.null(ec)) return(NULL)
    choices <- unlist(lapply(names(ec$ch), function(grp) lapply(unlist(ec$ch[[grp]], use.names = FALSE), function(v)
      list(value = v, label = v, group = grp))), recursive = FALSE)
    list(choices = choices, all = I(ec$all), nums = I(ec$nums))
  })

  # ---- Table builder: the table follows the fields as they change (builders
  # are the exception to "settings wait for their button")
  ct_result <- reactive({
    p <- list(row = input$ct_row, col = input$ct_col, stat = input$ct_stat, value = input$ct_value)
    shiny::validate(shiny::need(shiny::isTruthy(p$row), "Choose the rows, the columns and the cells to see the table."))
    df <- view_data(); req(df, p$row %in% names(df))
    stat <- p$stat %||% "n"
    col <- if (shiny::isTruthy(p$col) && p$col %in% names(df) && p$col != p$row) p$col else NULL
    for (k in c(p$row, col)) if (ov_var_kind(df[[k]]) == "cat") shiny::validate(shiny::need(is.null(too_many_options(df[[k]], col_label(k))), too_many_options(df[[k]], col_label(k))))
    if (stat %in% c("mean", "sum")) shiny::validate(shiny::need(shiny::isTruthy(p$value) && p$value %in% names(df), "Choose the number to average or sum."))
    ct <- contingency(df, p$row, col, NULL, stat, p$value)
    shiny::validate(shiny::need(nrow(ct$table) > 1, "No household has an answer for these variables."))
    what <- switch(stat, n = "Households", row = "Share of each row (%)", col = "Share of each column (%)", total = "Share of all households (%)",
                   mean = sprintf("Mean of %s", col_label(p$value)), sum = sprintf("Sum of %s", col_label(p$value)))
    out <- ct_frame(ct, col_label(p$row), what)
    out$col_label <- if (is.null(col)) "" else col_label(col)
    out
  })
  # render_react_table() with the formats and shading of this table (its
  # columns change with the variables chosen)
  output$ct_table <- shiny::createRenderFunction(function() ct_result(), function(value, session, name, ...) {
    if (is.null(value)) return(NULL)
    spec <- react_table_spec(value$data, page_size = 50, labels = value$labels)
    react_table_payload(spec, session$input[[paste0(name, "_state")]], formats = value$formats, styles = value$styles,
                        empty = "No household has an answer for these variables.")
  })
  output$ct_info <- shinyreact::reactive_output({
    r <- tryCatch(ct_result(), error = function(e) NULL); if (is.null(r)) return(NULL)
    list(what = r$what, n = format(r$n, big.mark = ","), col_label = r$col_label,
         chi = if (is.finite(r$chi)) sprintf("Chi-square test of independence: p %s%s.",
                                             if (r$chi < 0.001) "< 0.001" else sprintf("= %.3f", r$chi),
                                             if (r$chi < 0.05) " (the two variables are related)" else " (no evidence of a relation)"))
  })

  # ---- Chart builder: one or two variables, optionally grouped by a third;
  # the chart follows their types (numbers: scatter and correlation; a number
  # and a category: box plots, means or violins; two categories: stacked
  # bars) and follows the fields as they change, the one exception to
  # "settings wait for their button" (a chart is what the choice is for).
  gb_vars <- reactive({
    df <- view_data(); x <- input$gb_x
    req(df, shiny::isTruthy(x), x %in% names(df))
    y <- if (shiny::isTruthy(input$gb_y) && input$gb_y %in% names(df) && input$gb_y != x) input$gb_y
    g <- if (shiny::isTruthy(input$gb_group) && input$gb_group %in% names(df) && !input$gb_group %in% c(x, y)) input$gb_group
    list(df = df, x = x, y = y, g = g, kx = ov_var_kind(df[[x]]), ky = if (is.null(y)) "none" else ov_var_kind(df[[y]]))
  })
  # the chart types the chosen variables allow, and whether the axes are set
  output$gb_meta <- shinyreact::reactive_output({
    v <- tryCatch(gb_vars(), error = function(e) NULL)
    ch <- if (is.null(v)) character(0) else ov_chart_types(v$kx, v$ky)
    list(types = lapply(seq_along(ch), function(i) list(value = unname(ch[i]), label = names(ch)[i])),
         axes_set = any(is.finite(unlist(gb_axes()))))
  })
  gb_note <- reactiveVal("")
  output$gb_note <- renderText(gb_note())
  output$gb_plot <- render_echart({
    v <- gb_vars(); df <- v$df
    for (k in c(v$x, v$y, v$g)) {
      if (ov_var_kind(df[[k]]) != "cat") next
      msg <- too_many_options(df[[k]], col_label(k))
      shiny::validate(shiny::need(is.null(msg), msg))
    }
    r <- gb_echart(df, v$x, v$y, v$g, input$gb_type, gb_axes(), col_label)
    gb_note(r$note); gb_auto(r$auto)
    r$option
  }, height = 380)
  # the axes, set in the Axes dialog (NA = automatic); gb_auto is the chart's
  # own range, shown in the dialog
  gb_axes <- reactiveVal(list(ymin = NA_real_, ymax = NA_real_, xmin = NA_real_, xmax = NA_real_))
  gb_auto <- reactiveVal(NULL)
  observeEvent(input$gb_axes, {
    req(input$gb_axes > 0)   # a React button sends 0 at start
    a <- gb_auto()
    r <- function(v) if (is.null(v)) "categories" else sprintf("%s to %s", fmt5(signif(v[1], 3)), fmt5(signif(v[2], 3)))
    hint <- if (!is.null(a)) sprintf("Automatic now: Y %s; X %s.", r(a$y), r(a$x))
    showModal(axis_dialog(ns, "gbax_", gb_axes(), hint, with_x = TRUE))
  })
  observeEvent(input$gbax_apply, { gb_axes(axis_read(input, "gbax_")); removeModal() })
  observeEvent(input$gbax_reset, { gb_axes(list(ymin = NA_real_, ymax = NA_real_, xmin = NA_real_, xmax = NA_real_)); removeModal() })

  ## ---------------------- What these data do not allow (one quiet line)

  ### ----------------- The React Overview (shinyreact): the same figures as JSON
  # ---------------------------------------------------------------------------
  # Facts only; the client draws them (react/src/pages/overview/). Each comes
  # from the reactive the Shiny page uses, so the two cannot disagree.
  rows <- function(d) if (is.null(d) || !nrow(d)) list() else lapply(seq_len(nrow(d)), function(i) as.list(d[i, , drop = FALSE]))
  tiles_json <- function(tl) lapply(tl, function(t) list(label = t$label, value = t$value, sub = t$sub %||% "",
                                                        icon = t$icon %||% "", share = t$share %||% NA))
  output$ov_meta <- shinyreact::reactive_output({
    df <- uploaded_df(); if (is.null(df) || !shiny::isTruthy(user_setup$unique_id)) return(NULL)
    lv <- Filter(function(k) { cl <- user_setup[[k]]; shiny::isTruthy(cl) && cl %in% names(df) }, c("admin1", "admin2", "admin3"))
    cols <- vapply(lv, function(k) as.character(user_setup[[k]])[1], "")
    areas <- if (length(cols)) unique(as.data.frame(lapply(df[cols], as.character), stringsAsFactors = FALSE)) else data.frame()
    d <- if (shiny::isTruthy(user_setup$date) && user_setup$date %in% names(df)) {
      x <- as.Date(df[[user_setup$date]]); if (any(!is.na(x))) format(range(x, na.rm = TRUE)) } else NULL
    mv <- tryCatch(map_var_choices(), error = function(e) character(0))
    list(levels = I(unname(lv)), level_cols = as.list(cols),
         areas = lapply(seq_along(cols), function(j) I(areas[[j]])),
         dates = if (is.null(d)) NULL else I(d),
         map_vars = lapply(seq_along(mv), function(i) list(label = names(mv)[i], value = unname(mv[i]))),
         map_default = if (shiny::isTruthy(user_setup$v_groups) && user_setup$v_groups %in% mv) user_setup$v_groups else unname(mv[1]) %||% "")
  })
  output$ov_view <- shinyreact::reactive_output({
    if (is.null(tryCatch(filtered_data(), error = function(e) NULL))) return(NULL)
    list(label = view_label(), zoomed = !is.null(view_rows()))
  })
  output$ov_ready <- shinyreact::reactive_output({
    if (!shiny::isTruthy(user_setup$unique_id)) return(list(off = list()))
    rd <- data_readiness(ov_setup())
    off <- rd[rd$status == "Not available" & rd$area %in% c("Overview", "Selection"), , drop = FALSE]
    list(off = lapply(seq_len(nrow(off)), function(i) list(feature = off$feature[i], detail = off$detail[i])))
  })
  output$ov_collection <- shinyreact::reactive_output({
    cl <- tryCatch(collection(), error = function(e) NULL); if (is.null(cl)) return(NULL)
    a1 <- ov_col(user_setup, filtered_data(), "admin1")
    list(tiles = tiles_json(cl$tiles), daily = rows(if (is.null(cl$daily)) NULL else transform(cl$daily, day = format(day))),
         by_area = !is.null(cl$area_label),
         areas = I(sort(unique(c(if (!is.null(a1)) as.character(filtered_data()[[a1]]), "Other areas", "(no area)")))))
  })
  output$ov_profile <- shinyreact::reactive_output({
    pr <- tryCatch(profile(), error = function(e) NULL); if (is.null(pr)) return(list(empty = TRUE))
    keys <- intersect(PROFILE_CHARTS, names(pr$charts))
    list(empty = FALSE, tiles = tiles_json(pr$tiles),
         charts = lapply(keys, function(k) { ch <- pr$charts[[k]]; list(key = k, title = ch$title, kind = ch$kind, data = rows(ch$data)) }))
  })
  output$ov_vuln <- shinyreact::reactive_output({
    a <- tryCatch(vuln_all(), error = function(e) NULL); if (is.null(a)) return(list(empty = TRUE))
    v <- a$base
    g <- v$groups
    list(empty = FALSE, indicator = v$indicator, available = I(v$available),
         groups = if (is.null(g)) NULL else rows(transform(g, colour = vapply(seq_len(nrow(g)) / nrow(g), diagram_colour, ""))),
         score = if (is.null(v$score)) NULL else rows(v$score),
         cross = lapply(a$by, function(x) list(indicator = x$indicator, label = x$indicator_label,
                                               pct = !identical(x$indicator, "score"), rows = rows(x$cross),
                                               overall = if (is.null(x$cross)) NA else ov_wmean(x$cross$value, x$cross$households))))
  })

  output$readiness_strip <- renderUI({
    # from the mapping in use, not the copy saved at setup (older sessions
    # carry features that no longer apply, such as weighted figures)
    req(user_setup$unique_id)
    rd <- data_readiness(ov_setup())
    off <- rd[rd$status == "Not available" & rd$area %in% c("Overview", "Selection"), , drop = FALSE]
    if (!nrow(off)) return(NULL)
    tags$div(class = "tw-ready-strip",
      bsicons::bs_icon("info-circle"),
      tags$span(" Not available with these data:"),
      lapply(seq_len(nrow(off)), function(i) tags$span(class = "tw-ready-chip off", title = off$detail[i], off$feature[i])))
  })

  })
}
