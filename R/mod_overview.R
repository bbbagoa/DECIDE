#' Overview Module UI
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_overview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # fillable = FALSE: the dashboard is taller than the viewport (KPIs, map,
    # profiles, analytics), so it must scroll. In a fill container the map /
    # summary row would be squeezed to zero height once the analytics render.
    bslib::layout_sidebar(
      fillable = FALSE,
      sidebar = bslib::sidebar(
        title = "Dashboard Filters",
        width = 290,
        shinyWidgets::pickerInput(
          inputId = ns("filter_admin1"), label = "Admin 1:", choices = character(0), multiple = TRUE,
          options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE, selectedTextFormat = "count > 3")
        ),
        shinyWidgets::pickerInput(
          inputId = ns("filter_admin2"), label = "Admin 2:", choices = character(0), multiple = TRUE,
          options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE)
        ),
        shinyWidgets::pickerInput(
          inputId = ns("filter_admin3"), label = "Admin 3:", choices = character(0), multiple = TRUE,
          options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE)
        ),
        hr(),
        shinyWidgets::airDatepickerInput(
          inputId = ns("filter_date"), label = "Observation Period:", range = TRUE,
          value = c("2026-01-01", Sys.Date()), dateFormat = "yyyy-mm-dd", autoClose = TRUE
        ),
        hr(),
        tags$div(
          class = "d-flex gap-2 mt-2",
          actionButton(ns("btn_apply_filters"), "Apply", class = "btn-primary btn-sm flex-fill", icon = icon("filter")),
          actionButton(ns("btn_clear_filters"), label = NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm")
        )
      ),

      bslib::layout_column_wrap(
        width = 1 / 5, fill = FALSE,
        bslib::value_box(title = "Households", value = textOutput(ns("stat_hh")), showcase = bsicons::bs_icon("house-door"), theme = "primary"),
        bslib::value_box(title = "Individuals", value = textOutput(ns("stat_indiv")), showcase = bsicons::bs_icon("people"), theme = "secondary"),
        bslib::value_box(title = "Communities", value = textOutput(ns("stat_comm")), showcase = bsicons::bs_icon("geo-alt"), theme = "info"),
        bslib::value_box(title = "Daily Sync Rate", value = textOutput(ns("stat_rate")), showcase = plotly::plotlyOutput(ns("stat_rate_plot")), full_screen = TRUE, theme = "danger"),
        bslib::value_box(title = "Avg Survey Time", value = textOutput(ns("stat_duration")), showcase = bsicons::bs_icon("stopwatch"), theme = "dark")
      ),

      bslib::layout_columns(
        # The map: a quiet header, one toolbar (colour + mode), and the map
        # filling the rest of the card so it matches the summary next to it.
        bslib::card(
          full_screen = TRUE, class = "wfp-map-card",
          bslib::card_header(bsicons::bs_icon("map"), " ", textOutput(ns("map_area_title"), inline = TRUE)),
          bslib::card_body(
            class = "p-0 gap-0", fillable = FALSE, fill = FALSE,
          tags$div(
            class = "wfp-map-toolbar",
            tags$div(class = "d-flex align-items-center gap-2",
                     tags$span(class = "wfp-map-toolbar-label", "Colour by"),
                     uiOutput(ns("map_var_ui"), class = "wfp-map-var")),
            shinyWidgets::radioGroupButtons(
              inputId = ns("map_mode"), label = NULL,
              choices = c("Households" = "points", "By area" = "choropleth"),
              selected = "points", size = "sm", status = "outline-primary"
            )
          ),
          tags$div(class = "small text-muted wfp-map-note", textOutput(ns("map_note"), inline = TRUE))
          ),
          bslib::card_body(
            class = "p-0", fillable = TRUE, min_height = "520px",
            leafgl::leafglOutput(ns("map_plot"), height = "100%")
          )
        ),

        bslib::card(
          full_screen = TRUE,
          bslib::card_header(bsicons::bs_icon("clipboard-data"), " ", textOutput(ns("table_title"), inline = TRUE)),
          bslib::card_body(
            fillable = FALSE,
            # Sized to their content: no stretched table leaving a gap below.
            bslib::layout_columns(
              fill = FALSE, class = "align-items-center",
              DT::DTOutput(ns("vulnerability_table"), fill = FALSE),
              plotly::plotlyOutput(ns("eligibility_donut"), height = "200px"),
              col_widths = c(8, 4)
            ),
            tags$div(
              class = "wfp-profile-bar",
              tags$span(class = "wfp-profile-title", "Profile by"),
              shinyWidgets::radioGroupButtons(
                inputId = ns("profile_view"), label = NULL,
                choices = c("Vulnerability score" = "score", "Vulnerability group" = "vuln", "Eligibility" = "elig"),
                selected = "score", status = "outline-primary", size = "sm"
              )
            ),
            bslib::layout_column_wrap(
              width = 1 / 3, fill = FALSE, gap = ".75rem",
              plotly::plotlyOutput(ns("plot_sex"), height = "210px"),
              plotly::plotlyOutput(ns("plot_age"), height = "210px"),
              plotly::plotlyOutput(ns("plot_residence"), height = "210px"),
              plotly::plotlyOutput(ns("plot_hh_size"), height = "210px"),
              plotly::plotlyOutput(ns("plot_childU5"), height = "210px"),
              plotly::plotlyOutput(ns("plot_chronic"), height = "210px")
            )
          )
        ),
        col_widths = c(5, 7)
      ),

      # --- Advanced analytics (activate when the relevant columns are mapped) ---
      uiOutput(ns("analytics_block"))
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

    # Admin choices
    for (lvl in c("admin1", "admin2", "admin3")) {
      col <- user_setup[[lvl]]
      if (shiny::isTruthy(col)) {
        shinyWidgets::updatePickerInput(
          session,
          paste0("filter_", lvl),
          choices = sort(unique(as.character(uploaded_df()[[col]]))),
          selected = character(0)
        )
      }
    }

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

    # Reset applied admin filters on new data
    applied_filters$admin1 <- NULL
    applied_filters$admin2 <- NULL
    applied_filters$admin3 <- NULL
  })

  # --- Cascade Admin 2 choices based on selected Admin 1 ---
  observeEvent(input$filter_admin1, {
    req(uploaded_df(), shiny::isTruthy(user_setup$admin2))
    df <- uploaded_df()
    if (!shiny::isTruthy(input$filter_admin1)) {
      choices <- unique(df[[user_setup$admin2]])
    } else {
      choices <- df |>
        dplyr::filter(.data[[user_setup$admin1]] %in% input$filter_admin1) |>
        dplyr::pull(.data[[user_setup$admin2]]) |>
        unique()
    }
    shinyWidgets::updatePickerInput(session, "filter_admin2", choices = sort(as.character(choices)))
  }, ignoreNULL = FALSE)

  # --- Cascade Admin 3 choices based on selected Admin 2 ---
  observeEvent(input$filter_admin2, {
    req(uploaded_df(), shiny::isTruthy(user_setup$admin3))
    df <- uploaded_df()
    if (!shiny::isTruthy(input$filter_admin2)) {
      choices <- unique(df[[user_setup$admin3]])
    } else {
      choices <- df |>
        dplyr::filter(.data[[user_setup$admin2]] %in% input$filter_admin2) |>
        dplyr::pull(.data[[user_setup$admin3]]) |>
        unique()
    }
    shinyWidgets::updatePickerInput(session, "filter_admin3", choices = sort(as.character(choices)))
  }, ignoreNULL = FALSE)

  # --- Apply Filters ---
  observeEvent(input$btn_apply_filters, {
    waiter::waiter_show(
      html = waiter_content(),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    applied_filters$admin1 <- input$filter_admin1
    applied_filters$admin2 <- input$filter_admin2
    applied_filters$admin3 <- input$filter_admin3
    applied_filters$date <- input$filter_date
    showNotification("Filters applied.", type = "message")
  })

  # --- Clear Filters ---
  observeEvent(input$btn_clear_filters, {
    waiter::waiter_show(
      html = waiter_content(),
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
    req(shiny::isTruthy(user_setup$lon), shiny::isTruthy(user_setup$lat))
    df <- filtered_data()
    req(user_setup$lon %in% names(df), user_setup$lat %in% names(df))

    lng <- suppressWarnings(as.numeric(as.character(df[[user_setup$lon]])))
    lat <- suppressWarnings(as.numeric(as.character(df[[user_setup$lat]])))
    ok <- is.finite(lng) & is.finite(lat) &
      abs(lng) <= 180 & abs(lat) <= 90 & !(lng == 0 & lat == 0)

    list(df = df[ok, , drop = FALSE], lng = lng[ok], lat = lat[ok],
         dropped = sum(!ok), total = length(ok))
  })

  # Colour scale for the chosen variable. Blank / NA gets its own grey level
  # instead of silently taking the first (least-severe) IPC colour, which is
  # what shifted every category one step down the severity ramp.
  map_palette <- function(values) {
    ipc <- c("#CDFACD", "#FAE61E", "#E67800", "#C80000", "#640000")
    grey <- "#BEBEBE"

    if (is.numeric(values) && length(unique(stats::na.omit(values))) > 8) {
      pal <- leaflet::colorNumeric("YlOrRd", domain = values, na.color = grey)
      return(list(color = pal(values), numeric = TRUE, pal = pal, values = values))
    }

    v <- as.character(values)
    v[is.na(v) | trimws(v) == ""] <- NA
    lv <- sort(unique(v[!is.na(v)]))
    # More levels than the IPC ramp has stops used to produce NA colours, i.e.
    # invisible points; interpolate instead.
    cols <- if (length(lv) == 0) character(0)
            else if (length(lv) <= length(ipc)) ipc[seq_along(lv)]
            else grDevices::colorRampPalette(ipc)(length(lv))
    names(cols) <- lv

    out <- unname(cols[v])
    out[is.na(out)] <- grey
    legend <- cols
    if (anyNA(v)) legend <- c(legend, stats::setNames(grey, "Not specified"))
    list(color = out, numeric = FALSE,
         legend_colors = unname(legend), legend_labels = names(legend))
  }

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

  # Base map follows the app's light/dark switch, unless the user picked
  # Terrain or Satellite, which then stays.
  dark_mode <- reactive(identical(session$rootScope()$input$dark_mode, "dark"))
  base_choice <- reactiveVal(NULL)
  observeEvent(input$map_plot_groups, {
    g <- intersect(input$map_plot_groups, c("Terrain", "Satellite"))
    base_choice(if (length(g)) g[1] else NULL)
  })
  base_group <- function() base_choice() %||% if (isTRUE(dark_mode())) "Dark" else "Light"

  esri_canvas <- function(layer) sprintf(
    "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_%s/MapServer/tile/{z}/{y}/{x}", layer)
  esri_attr <- "Tiles &copy; Esri &mdash; Esri, HERE, Garmin, &copy; OpenStreetMap contributors"

  base_map <- function(bounds = NULL) {
    keep <- isolate(base_group())
    m <- leaflet::leaflet(options = leaflet::leafletOptions(zoomControl = TRUE, attributionControl = TRUE)) |>
      # Esri canvas basemaps: keyless, a matched light/dark pair, with their
      # place-name layers on top. (CARTO now asks for an API key.)
      leaflet::addTiles(esri_canvas("Light_Gray_Base"), attribution = esri_attr, group = "Light") |>
      leaflet::addTiles(esri_canvas("Light_Gray_Reference"), group = "Light") |>
      leaflet::addTiles(esri_canvas("Dark_Gray_Base"), attribution = esri_attr, group = "Dark") |>
      leaflet::addTiles(esri_canvas("Dark_Gray_Reference"), group = "Dark") |>
      leaflet::addProviderTiles(leaflet::providers$Esri.WorldTopoMap, group = "Terrain") |>
      leaflet::addProviderTiles(leaflet::providers$Esri.WorldImagery, group = "Satellite") |>
      leaflet::hideGroup(setdiff(c("Light", "Dark", "Terrain", "Satellite"), keep)) |>
      leaflet::addLayersControl(
        baseGroups = c("Light", "Dark", "Terrain", "Satellite"),
        position = "topright",
        options = leaflet::layersControlOptions(collapsed = TRUE)
      ) |>
      leaflet::addScaleBar(position = "bottomleft", options = leaflet::scaleBarOptions(imperial = FALSE))
    if (!is.null(bounds)) {
      # Back to the data after panning around.
      m <- leaflet::addEasyButton(m, leaflet::easyButton(
        icon = "fa-expand", title = "Zoom to the households",
        onClick = htmlwidgets::JS(sprintf(
          "function(btn, map){ map.fitBounds([[%f, %f], [%f, %f]]); }",
          bounds[2], bounds[1], bounds[4], bounds[3]))))
    }
    m
  }

  observeEvent(dark_mode(), {
    if (!is.null(base_choice())) return()
    leaflet::leafletProxy("map_plot", session) |>
      leaflet::hideGroup(c("Light", "Dark")) |>
      leaflet::showGroup(if (isTRUE(dark_mode())) "Dark" else "Light")
  }, ignoreInit = TRUE)

  # Points and choropleth are two branches of ONE render. The previous version
  # drove the toggle through leafletProxy and called clearGroup("points") on the
  # way into choropleth; nothing ever put the points back, so switching back to
  # Points left an empty map.
  output$map_plot <- leaflet::renderLeaflet({
    pts <- map_points()
    if (nrow(pts$df) == 0) return(base_map())
    xr <- fit_range(pts$lng); yr <- fit_range(pts$lat)
    map <- base_map(c(xr[1], yr[1], xr[2], yr[2]))

    df <- pts$df
    choropleth <- identical(input$map_mode, "choropleth")
    col <- if (shiny::isTruthy(input$map_var)) input$map_var else user_setup$v_groups
    if (!shiny::isTruthy(col) || !col %in% names(df)) col <- NULL

    if (choropleth) {
      unit_col <- user_setup$admin1
      # Colour the units by the selected variable when it is numeric, else by
      # the vulnerability score.
      score_col <- if (!is.null(col) && is.numeric(df[[col]])) col else user_setup$v_score
      if (!shiny::isTruthy(unit_col) || !unit_col %in% names(df) ||
          !shiny::isTruthy(score_col) || !score_col %in% names(df)) {
        return(map)
      }

      w <- get_weights(df, user_setup)
      sc <- suppressWarnings(as.numeric(as.character(df[[score_col]])))
      unit <- as.character(df[[unit_col]])

      agg <- do.call(rbind, lapply(split(seq_len(nrow(df)), unit), function(idx) {
        ww <- w[idx]; ss <- sc[idx]
        data.frame(
          unit = unit[idx[1]],
          mean_score = sum(ss * ww, na.rm = TRUE) / sum(ww[!is.na(ss)], na.rm = TRUE),
          n = sum(ww, na.rm = TRUE),
          lng = mean(pts$lng[idx], na.rm = TRUE),
          lat = mean(pts$lat[idx], na.rm = TRUE),
          stringsAsFactors = FALSE
        )
      }))
      agg <- agg[is.finite(agg$mean_score), , drop = FALSE]
      if (is.null(agg) || nrow(agg) == 0) return(map)

      pal <- leaflet::colorNumeric("YlOrRd", domain = agg$mean_score, na.color = "transparent")
      r_in <- log1p(agg$n)
      radius_scaled <- 6 + 18 * (r_in - min(r_in)) / (max(r_in) - min(r_in) + 1e-9)

      return(
        map |>
          leaflet::addCircleMarkers(
            data = agg, lng = ~lng, lat = ~lat, group = "choropleth",
            radius = radius_scaled, fillColor = ~pal(mean_score),
            fillOpacity = 0.8, stroke = TRUE, color = "#ffffff", weight = 1.5, opacity = 0.9,
            label = ~unit,
            labelOptions = leaflet::labelOptions(direction = "top", className = "wfp-map-label"),
            popup = ~sprintf("<div class='wfp-map-pop'><b>%s</b><span>Mean %s</span><strong>%.1f</strong><span>%s households</span></div>",
                             htmltools::htmlEscape(unit), htmltools::htmlEscape(score_col), mean_score,
                             format(round(n), big.mark = ","))
          ) |>
          leaflet::addLegend("bottomright", pal = pal, values = agg$mean_score,
                             title = paste("Mean", score_col), layerId = "choro_legend") |>
          leaflet::fitBounds(min(agg$lng), min(agg$lat), max(agg$lng), max(agg$lat))
      )
    }

    values <- if (is.null(col)) rep(NA_character_, nrow(df)) else df[[col]]
    if (inherits(values, "haven_labelled")) values <- haven::as_factor(values)
    p <- map_palette(values)

    # Popup: the household, where it is, and the value it is coloured by.
    fld <- function(k) { cl <- user_setup[[k]]; if (shiny::isTruthy(cl) && cl %in% names(df)) as.character(df[[cl]]) else rep("", nrow(df)) }
    esc <- function(x) htmltools::htmlEscape(ifelse(is.na(x), "", x))
    pop <- sprintf("<div class='wfp-map-pop'><b>%s</b><span>%s</span>%s</div>",
                   esc(fld("unique_id")), esc(paste(fld("admin2"), fld("village"), sep = " \u00b7 ")),
                   if (is.null(col)) "" else sprintf("<span>%s</span><strong>%s</strong>", esc(col), esc(as.character(values))))
    sf_pts <- sf::st_as_sf(
      data.frame(lng = pts$lng, lat = pts$lat, popup = pop, stringsAsFactors = FALSE),
      coords = c("lng", "lat"), crs = 4326
    )

    map <- map |>
      leafgl::addGlPoints(
        data = sf_pts, fillColor = p$color, radius = 7, fillOpacity = 0.9,
        group = "points", popup = "popup"
      ) |>
      # A fixed zoom of 8 centred on the mean coordinate showed a sliver of a
      # country-wide sample; fit to the data instead.
      leaflet::fitBounds(xr[1], yr[1], xr[2], yr[2])

    if (p$numeric) {
      map <- leaflet::addLegend(map, "bottomright", pal = p$pal, values = p$values,
                                title = col, opacity = 0.8)
    } else if (length(p$legend_colors) > 0) {
      map <- leaflet::addLegend(map, "bottomright", colors = p$legend_colors,
                                labels = p$legend_labels, title = col, opacity = 0.8)
    }
    map
  })

  ### ----------------- Computing various metrics of the Overview
  # -----------------------------------------------------------------------------------

  # Metric 1: Total Households (Filtered, weighted)
  output$stat_hh <- renderText({
    req(filtered_data())
    format(round(weighted_count(filtered_data(), user_setup)), big.mark = ",")
  })

  # Metric 2: Total Individuals (Weighted sum of HH Size)
  output$stat_indiv <- renderText({
    req(filtered_data(), user_setup$hh_size)
    total <- weighted_sum(filtered_data(), user_setup$hh_size, user_setup)
    format(round(total), big.mark = ",")
  })

  # Metric 3: Total Unique Communities (excluding zero-weight rows)
  output$stat_comm <- renderText({
    req(filtered_data(), user_setup$village)
    df <- filtered_data()
    w <- get_weights(df, user_setup)
    n_comm <- length(unique(df[[user_setup$village]][w > 0]))
    format(n_comm, big.mark = ",")
  })

  # Metric 4: Daily Submission Rate (Efficiency)
  output$stat_rate <- renderText({
    # Wait for data AND the date mapping from setup
    req(filtered_data(), user_setup$date)

    df <- filtered_data()
    date_col <- user_setup$date

    # Calculate unique days
    # as.Date ensures we count calendar days, even if the data has timestamps
    unique_days <- unique(as.Date(df[[date_col]]))
    n_days <- length(unique_days)

    if (n_days <= 0) {
      return("0 / day")
    }

    rate <- round(weighted_count(df, user_setup) / n_days, 0)
    paste0(format(rate, big.mark = ","), " / day")
  })

  # Metric 5: Average Survey Duration (weighted)
  output$stat_duration <- renderText({
    req(filtered_data())
    df <- filtered_data()

    # Check if columns exist; if not, fall back to starttime/endtime
    if (all(c("start", "end") %in% names(df))) {
      t_start <- lubridate::as_datetime(df[["start"]])
      t_end <- lubridate::as_datetime(df[["end"]])
    } else {
      t_start <- lubridate::as_datetime(df[["starttime"]])
      t_end <- lubridate::as_datetime(df[["endtime"]])
    }

    if (length(t_start) == 0 || length(t_end) == 0) {
      return("No Data")
    }

    # Calculate difference in minutes
    durations <- as.numeric(difftime(t_end, t_start, units = "mins"))
    w <- get_weights(df, user_setup)

    # Filter for realistic surveys (e.g., 5 min to 3 hours)
    valid <- !is.na(durations) & durations > 5 & durations < 180 & !is.na(w) & w > 0

    if (sum(valid) == 0) {
      return("N/A")
    }

    avg <- sum(durations[valid] * w[valid]) / sum(w[valid])
    paste0(round(avg, 1), " min")
  })

  ### ----------------- Daily Synchronisation graph in the box
  # -----------------------------------------------------------------------------------

  output$stat_rate_plot <- render_wfp_plotly({
    req(filtered_data(), user_setup$date)

    # 1. Aggregate weighted data by day
    df <- filtered_data()
    daily_data <- weighted_table(df, user_setup$date, user_setup) |>
      dplyr::mutate(date = as.Date(.data$value)) |>
      dplyr::arrange(.data$date)

    # 2. Build the Sparkline
    plotly::plot_ly(
      daily_data,
      x = ~date,
      y = ~n,
      color = I("#0A6EB4"),
      span = I(1),
      alpha = 0.2
    ) |>
      plotly::add_lines(
        color = I("#0A6EB4"), # Brand accent reads on both light and dark surfaces
        fill = "tozeroy", # Shades the area under the line
        alpha = 0.2
      ) |>
      plotly::layout(
        xaxis = list(visible = FALSE, showgrid = FALSE),
        yaxis = list(visible = FALSE, showgrid = FALSE),
        hovermode = "x",
        margin = list(t = 0, r = 0, l = 0, b = 0),
        paper_bgcolor = "transparent",
        plot_bgcolor = "transparent"
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  ### ----------------- Dynamic filtered info
  # -----------------------------------------------------------------------------------

  # Create the dynamic title string
  dynamic_title <- reactive({
    # Start with the highest level selected
    if (shiny::isTruthy(input$filter_admin3)) {
      paste("Data for ", paste(input$filter_admin3, collapse = ", "))
    } else if (shiny::isTruthy(input$filter_admin2)) {
      paste("Data for ", paste(input$filter_admin2, collapse = ", "))
    } else if (shiny::isTruthy(input$filter_admin1)) {
      paste("Data for ", paste(input$filter_admin1, collapse = ", "))
    } else {
      "Summary for All Administrative Areas"
    }
  })

  # Pass this to the UI
  output$table_title <- renderText({
    dynamic_title()
  })

  # Pass this to the UI
  output$map_area_title <- renderText(dynamic_title())

  # Rows missing from the map are said, not left to be guessed at.
  output$map_note <- renderText({
    pts <- tryCatch(map_points(), error = function(e) NULL)
    if (is.null(pts) || pts$dropped == 0) return("")
    sprintf("%s of %s households have no usable coordinates and are not on the map.",
            format(pts$dropped, big.mark = ","), format(pts$total, big.mark = ","))
  })

  ### ----------------- Vulnerability Table
  # -----------------------------------------------------------------------------------

  output$vulnerability_table <- DT::renderDT({
    req(filtered_data(), user_setup$v_groups, user_setup$hh_size)

    if (user_setup$v_groups == "") {
      return("Vulnerability scales not available")
    } # Handle the empty case gracefully

    df <- filtered_data()
    vuln_col <- user_setup$v_groups
    size_col <- user_setup$hh_size
    w <- get_weights(df, user_setup)
    size_num <- suppressWarnings(as.numeric(as.character(df[[size_col]])))

    # 1. Aggregate and calculate weighted percentages
    summary_df <- df |>
      dplyr::transmute(
        Vulnerability = as.character(.data[[vuln_col]]),
        .w = w,
        .size = tidyr::replace_na(size_num, 0)
      ) |>
      dplyr::filter(Vulnerability != "") |>
      dplyr::group_by(Vulnerability) |>
      dplyr::summarise(
        Households = sum(.data$.w, na.rm = TRUE),
        Individuals = sum(.data$.size * .data$.w, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::mutate(
        `% HH` = Households / sum(Households),
        `% Indiv` = Individuals / sum(Individuals)
      ) |>
      dplyr::arrange(Vulnerability)

    # 3. Create Table with Percentage Formatting
    DT::datatable(
      summary_df,
      options = list(dom = 't', paging = FALSE, ordering = FALSE),
      rownames = FALSE
    ) |>
      # Format big numbers with commas
      DT::formatCurrency(
        c('Households', 'Individuals'),
        currency = "",
        interval = 3,
        mark = ",",
        digits = 0
      ) |>
      # Format the new columns as Percentages
      DT::formatPercentage(c('% HH', '% Indiv'), digits = 1)
  })

  ### ----------------- The Eligibility Donut Chart
  # -----------------------------------------------------------------------------------

  output$eligibility_donut <- render_wfp_plotly({
    req(filtered_data(), user_setup$eligibility)

    df <- filtered_data()
    target_col <- user_setup$eligibility

    # 1. Clean and Aggregate (weighted). Keep ALL categories so nothing is
    #    silently dropped; bundle the tail beyond the top 2 into an "Other" slice.
    counts <- weighted_table(df, target_col, user_setup) |>
      dplyr::filter(.data$value != "", .data$value != "NA") |>
      dplyr::arrange(dplyr::desc(.data$n))

    if (nrow(counts) == 0 || sum(counts$n) == 0) {
      return(plotly::plot_ly() |>
        plotly::layout(
          paper_bgcolor = 'rgba(0,0,0,0)',
          plot_bgcolor = 'rgba(0,0,0,0)',
          annotations = list(text = "No data", showarrow = FALSE, x = 0.5, y = 0.5)
        ) |>
        plotly::config(displayModeBar = FALSE))
    }

    # If there are more than 2 categories, fold the remainder into "Other"
    # so the donut always represents 100% of the data (no silent loss).
    if (nrow(counts) > 2) {
      top2 <- counts[1:2, ]
      other_n <- sum(counts$n[3:nrow(counts)])
      if (other_n > 0) {
        top2 <- dplyr::bind_rows(top2, data.frame(value = "Other", n = other_n, stringsAsFactors = FALSE))
      }
      counts <- top2
    }

    # Calculate % for both highlighted levels
    total <- sum(counts$n)
    p1_lab <- substr(counts$value[1], 1, 22)
    p1_pct <- round((counts$n[1] / total) * 100, 1)

    p2_lab <- if (nrow(counts) > 1) substr(counts$value[2], 1, 22) else "N/A"
    p2_pct <- if (nrow(counts) > 1) {
      round((counts$n[2] / total) * 100, 1)
    } else {
      0
    }

    # 2. Build the Donut
    plotly::plot_ly(
      labels = counts$value,
      values = counts$n,
      type = 'pie',
      hole = 0.85,
      marker = list(colors = c("#0A6EB4", "#f7b825", "#6c757d")), # WFP blue / amber / grey (Other)
      textinfo = 'none',
      hoverinfo = 'label+percent'
    ) |>
      plotly::layout(
        margin = list(t = 0, b = 0, l = 0, r = 0),
        showlegend = FALSE,
        autosize = TRUE,
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)',
        annotations = list(
          list(
            text = paste0(
              "<span style='color:#0A6EB4; font-size:27px; font-weight:bold;'>",
              p1_pct,
              "%</span>",
              "<br><span style='color:#0A6EB4; font-size:10px;'>",
              p1_lab,
              "</span><br>",
              "<span style='color:#94a3b8; font-size:12px;'>----------</span><br>",
              "<br><span style='color:#f7b825; font-size:27px; font-weight:bold;'>",
              p2_pct,
              "%</span>",
              "<br><span style='color:#f7b825; font-size:10px;'>",
              p2_lab,
              "</span>"
            ),
            showarrow = FALSE,
            x = 0.5,
            y = 0.5
          )
        )
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  ### ----------------- The Eligibility Waffle Chart
  # -----------------------------------------------------------------------------------

  # output$eligibility_waffle <- render_wfp_plotly({
  #   req(filtered_data(), user_setup$eligibility)
  #
  #   # 1. Aggregate and get top 2 levels
  #   target_col <- user_setup$eligibility
  #   counts <- as.data.frame(table(filtered_data()[[target_col]])) |>
  #     dplyr::slice_max(Freq, n = 2) |>
  #     dplyr::arrange(desc(Freq))
  #
  #   # 2. Calculate percentage for the primary group
  #   p1_pct <- round((counts$Freq[1] / sum(counts$Freq)) * 100)
  #
  #   # 3. Build the 10x10 grid (Values 1 and 2)
  #   # Filling a 100-length vector: p1_pct ones, then the rest twos
  #   grid_vals <- c(rep(1, p1_pct), rep(2, 100 - p1_pct))
  #   waffle_matrix <- matrix(grid_vals, nrow = 10, ncol = 10, byrow = TRUE)
  #
  #   # 4. Create the Plotly Heatmap as a Waffle
  #   plotly::plot_ly(
  #     z = waffle_matrix,
  #     type = "heatmap",
  #     # Fancy Solarized Palette: Cyan (#0A6EB4) and Muted Sage (#c9cba3)
  #     colorscale = list(list(0, "#0A6EB4"), list(0.5, "#0A6EB4"),
  #                       list(0.5, "#c9cba3"), list(1, "#c9cba3")),
  #     showscale = FALSE,
  #     # Add gaps to create the "squares" look
  #     xgap = 3, ygap = 3,
  #     # Hover text shows the label and percentage
  #     hoverinfo = "text",
  #     text = ifelse(waffle_matrix == 1,
  #                   paste0(counts$Var1[1], ": ", p1_pct, "%"),
  #                   paste0(counts$Var1[2], ": ", 100 - p1_pct, "%"))
  #   ) |>
  #     plotly::layout(
  #       title = list(text = "Eligibility Comp. (1 block = 1%)",
  #                    font = list(color = "#5b6b7e", size = 11)),
  #       paper_bgcolor = 'rgba(0,0,0,0)',
  #       plot_bgcolor = 'rgba(0,0,0,0)',
  #       xaxis = list(visible = FALSE, fixedrange = TRUE),
  #       yaxis = list(visible = FALSE, fixedrange = TRUE, autorange = "reversed"),
  #       margin = list(t = 30, b = 10, l = 10, r = 10)
  #     ) |>
  #     plotly::config(displayModeBar = FALSE)
  # })

  ### ----------------- Vulnerability Profile
  # -----------------------------------------------------------------------------------

  # ------------------- Define each Vulnerability Plot

  ## Sex of the HH Head

  output$plot_sex <- render_wfp_plotly({
    req(filtered_data(), user_setup$hhh_sex)
    # Map internal choice to actual column name from setup
    view_col <- switch(
      input$profile_view,
      "vuln" = user_setup$v_groups,
      "elig" = user_setup$eligibility,
      "score" = user_setup$v_score
    )

    create_profile_plot(
      filtered_data(),
      view_col,
      user_setup$hhh_sex,
      weights = get_weights(filtered_data(), user_setup)
    )
  })

  ## Disability / Chronic Illness

  output$plot_chronic <- render_wfp_plotly({
    req(filtered_data(), user_setup$disability)
    # Map internal choice to actual column name from setup
    view_col_name <- switch(
      input$profile_view,
      "vuln" = user_setup$v_groups,
      "elig" = user_setup$eligibility,
      "score" = user_setup$v_score
    )

    create_profile_plot(
      data = filtered_data(),
      view_col = view_col_name,
      demo_col = user_setup$disability,
      weights = get_weights(filtered_data(), user_setup)
    )
  })

  ## HH Size

  output$plot_hh_size <- render_wfp_plotly({
    req(filtered_data(), user_setup$hh_size)

    # Determine which column name to use based on radioButtons
    view_col_name <- switch(
      input$profile_view,
      "vuln" = user_setup$v_groups,
      "elig" = user_setup$eligibility,
      "score" = user_setup$v_score
    )

    create_profile_plot(
      data = filtered_data(),
      view_col = view_col_name,
      demo_col = user_setup$hh_size,
      weights = get_weights(filtered_data(), user_setup)
    )
  })

  ## HHH Age

  output$plot_age <- render_wfp_plotly({
    req(filtered_data(), user_setup$hhh_age)

    # Determine which column name to use based on radioButtons
    view_col_name <- switch(
      input$profile_view,
      "vuln" = user_setup$v_groups,
      "elig" = user_setup$eligibility,
      "score" = user_setup$v_score
    )

    create_profile_plot(
      data = filtered_data(),
      view_col = view_col_name,
      demo_col = user_setup$hhh_age,
      weights = get_weights(filtered_data(), user_setup)
    )
  })

  ## Residence Status

  output$plot_residence <- render_wfp_plotly({
    req(filtered_data(), user_setup$residency)

    # Determine which column name to use based on radioButtons
    view_col_name <- switch(
      input$profile_view,
      "vuln" = user_setup$v_groups,
      "elig" = user_setup$eligibility,
      "score" = user_setup$v_score
    )

    create_profile_plot(
      data = filtered_data(),
      view_col = view_col_name,
      demo_col = user_setup$residency,
      weights = get_weights(filtered_data(), user_setup)
    )
  })

  ## Presence of Children Under 5yo

  output$plot_childU5 <- render_wfp_plotly({
    req(filtered_data(), user_setup$childU5)

    # Determine which column name to use based on radioButtons
    view_col_name <- switch(
      input$profile_view,
      "vuln" = user_setup$v_groups,
      "elig" = user_setup$eligibility,
      "score" = user_setup$v_score
    )

    create_profile_plot(
      data = filtered_data(),
      view_col = view_col_name,
      demo_col = user_setup$childU5,
      weights = get_weights(filtered_data(), user_setup)
    )
  })

  ## ---------------------- In case Vuln and groups are not available

  observe({
    req(user_setup) # Wait for setup module to initialize

    # 1. Start with the 'Score' which we assume is the primary numeric metric
    available_choices <- c("Vulnerability score" = "score")

    # 2. Add others ONLY if they exist in the mapping
    if (shiny::isTruthy(user_setup$v_groups) && user_setup$v_groups != "") {
      available_choices <- c(available_choices, "Vulnerability group" = "vuln")
    }

    if (
      shiny::isTruthy(user_setup$eligibility) && user_setup$eligibility != ""
    ) {
      available_choices <- c(available_choices, "Eligibility" = "elig")
    }

    # 3. Update the buttons. If 'vuln' isn't in available_choices, it disappears.
    shinyWidgets::updateRadioGroupButtons(
      session = session,
      inputId = "profile_view",
      choices = available_choices,
      selected = input$profile_view %||% "score", # Keep current selection or default to score
      status = "outline-primary",
      checkIcon = list(
        yes = NULL,
        no = NULL
      ),
    )
  })

    # -----------------------------------------------------------------------
    # Advanced analytics: weighted cross-tabulation and weighted correlation
    # matrix. Each block activates only when the relevant columns are mapped.
    # -----------------------------------------------------------------------
    output$analytics_block <- renderUI({
      req(filtered_data())
      ns <- session$ns
      block_list <- list()

      # Cross-tab explorer + correlation matrix share a row of column pickers.
      # Identifiers, dates, coordinates and weights make meaningless crosstabs,
      # so they are excluded and the categorical profile variables come first.
      setup_list <- reactiveValuesToList(user_setup)
      skip_keys <- c("unique_id", "date", "lon", "lat", "weight", "enumerator_id", "force_numeric")
      preferred_keys <- c("v_groups", "eligibility", "hhh_sex", "residency", "admin1", "admin2",
                          "childU5", "disability", "hhid_avail", "phone_avail")
      pick <- function(keys) {
        vals <- unlist(setup_list[intersect(keys, names(setup_list))], use.names = FALSE)
        vals <- as.character(vals)
        vals[nzchar(vals) & vals %in% names(filtered_data())]
      }
      mapped_cols <- unique(c(pick(preferred_keys), pick(setdiff(names(setup_list), skip_keys))))
      if (length(mapped_cols) >= 2) {
        block_list <- c(block_list, list(
          hr(),
          bslib::layout_columns(
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(bsicons::bs_icon("table"), " Cross-Tabulation Explorer"),
              bslib::card_body(
                bslib::layout_columns(
                  shinyWidgets::pickerInput(ns("xtab_row"), "Rows:", choices = mapped_cols, selected = mapped_cols[1], width = "100%", options = shinyWidgets::pickerOptions(container = "body", liveSearch = TRUE)),
                  shinyWidgets::pickerInput(ns("xtab_col"), "Columns:", choices = mapped_cols, selected = mapped_cols[2], width = "100%", options = shinyWidgets::pickerOptions(container = "body", liveSearch = TRUE))
                ),
                DT::DTOutput(ns("xtab_table"), fill = FALSE),
                tags$div(class = "text-muted small", textOutput(ns("xtab_chi")))
              )
            ),
            bslib::card(
              full_screen = TRUE,
              bslib::card_header(bsicons::bs_icon("grid-3x3-gap"), " Weighted Correlation (numeric variables)"),
              bslib::card_body(
                plotly::plotlyOutput(ns("plot_cor_matrix"), height = "360px")
              )
            ),
            col_widths = c(6, 6)
          )
        ))
      }

      do.call(tagList, block_list)
    })

    # --- Cross-tab explorer ---
    output$xtab_table <- DT::renderDT({
      req(filtered_data(), input$xtab_row, input$xtab_col)
      ct <- weighted_crosstab(filtered_data(), input$xtab_row, input$xtab_col, get_weights(filtered_data(), user_setup))
      if (is.null(ct) || nrow(ct$counts) == 0) return(DT::datatable(data.frame()))
      out <- ct$counts
      out$n <- round(out$n, 1)
      out$row_pct <- paste0(round(out$row_pct * 100, 1), "%")
      out$col_pct <- paste0(round(out$col_pct * 100, 1), "%")
      colnames(out) <- c("Row", "Col", "Weighted n", "% within row", "% within col")
      DT::datatable(out, options = list(pageLength = 12, scrollX = TRUE), rownames = FALSE)
    })

    output$xtab_chi <- renderText({
      req(filtered_data(), input$xtab_row, input$xtab_col)
      ct <- weighted_crosstab(filtered_data(), input$xtab_row, input$xtab_col, get_weights(filtered_data(), user_setup))
      if (is.null(ct) || !is.list(ct$chi_sq) || is.null(ct$chi_sq$p.value)) return("")
      sprintf("Chi-square p-value: %.4f (n = %s)", ct$chi_sq$p.value, format(ct$n_valid, big.mark = ","))
    })

    # --- Weighted correlation matrix ---
    output$plot_cor_matrix <- render_wfp_plotly({
      req(filtered_data())
      df <- filtered_data()
      num_cols <- names(df)[vapply(df, is.numeric, logical(1))]
      # A 100 x 100 heatmap is unreadable: drop ODK metadata / coordinates /
      # ids / constant columns, put the mapped analytical variables first and
      # cap the matrix at 25 variables.
      setup_list <- reactiveValuesToList(user_setup)
      meta <- c(setup_list$unique_id, setup_list$lon, setup_list$lat, setup_list$date)
      num_cols <- num_cols[!grepl("^@?_", num_cols) & !num_cols %in% meta]
      num_cols <- num_cols[vapply(df[num_cols], function(x) {
        v <- suppressWarnings(stats::var(x, na.rm = TRUE)); is.finite(v) && v > 0
      }, logical(1))]
      mapped_num <- intersect(unique(as.character(unlist(setup_list, use.names = FALSE))), num_cols)
      num_cols <- unique(c(mapped_num, num_cols))
      max_vars <- 25
      truncated <- length(num_cols) > max_vars
      num_cols <- head(num_cols, max_vars)
      if (length(num_cols) < 2) return(plotly::plot_ly() |> plotly::layout(annotations = list(text = "Need >= 2 numeric variables", showarrow = FALSE, x = 0.5, y = 0.5)))
      mat <- weighted_cor_matrix(df, num_cols, get_weights(df, user_setup))
      if (nrow(mat) < 2) return(plotly::plot_ly() |> plotly::layout(annotations = list(text = "Insufficient data", showarrow = FALSE, x = 0.5, y = 0.5)))
      plotly::plot_ly(
        x = colnames(mat), y = rownames(mat), z = mat,
        type = "heatmap", colorscale = "RdBu", zmid = 0, zmin = -1, zmax = 1,
        text = round(mat, 2), texttemplate = if (nrow(mat) <= 12) "%{text}" else "", hoverinfo = "x+y+z"
      ) |>
        plotly::layout(
          title = if (truncated) list(text = sprintf("First %d of %d numeric variables", max_vars, length(mapped_num) + sum(!num_cols %in% mapped_num)), font = list(size = 11)) else NULL,
          margin = list(l = 120, b = 110, t = if (truncated) 36 else 16),
          xaxis = list(tickangle = -45, tickfont = list(size = 10)),
          yaxis = list(tickfont = list(size = 10))
        )
    })

  })
}
