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
          tags$div(class = "tw-ov-map-body", leafgl::leafglOutput(ns("map_plot"), height = "100%")))
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
    waiter::waiter_show(
      html = waiter_content("Filtering the overview\u2026"),
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

  # Esri Terrain is the default basemap. Whatever base the user picks then
  # stays; the light/dark switch only moves between Light and Dark.
  dark_mode <- reactive(identical(session$rootScope()$input$dark_mode, "dark"))
  base_choice <- reactiveVal("Terrain")
  light_base <- reactiveVal("Terrain")     # the base to go back to when leaving dark mode
  observeEvent(input$map_plot_groups, {
    g <- intersect(input$map_plot_groups, BASE_GROUPS)
    if (length(g)) { base_choice(g[1]); if (g[1] != "Dark") light_base(g[1]) }
  })
  # dark mode draws the map on the dark basemap
  base_group <- function() if (isTRUE(dark_mode())) "Dark" else base_choice()


  base_map <- function(bounds = NULL) {
    keep <- isolate(base_group())
    # Esri basemaps: keyless, a matched light/dark pair, terrain and two
    # satellite views, zooming to level 21 (add_esri_bases()).
    m <- leaflet::leaflet(options = leaflet::leafletOptions(zoomControl = TRUE, attributionControl = TRUE, maxZoom = 21)) |>
      add_esri_bases() |>
      leaflet::hideGroup(setdiff(BASE_GROUPS, keep)) |>
      leaflet::addLayersControl(
        baseGroups = BASE_GROUPS,
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
    target <- if (isTRUE(dark_mode())) "Dark" else light_base()
    base_choice(target)
    leaflet::leafletProxy("map_plot", session) |>
      leaflet::hideGroup(BASE_GROUPS) |>
      leaflet::showGroup(target)
  }, ignoreInit = TRUE)

  # A button on the map: draw a rectangle, the map zooms to it (Leaflet's own
  # Shift + drag does the same, but nobody knows it).
  box_zoom_js <- htmlwidgets::JS("function(el, x) {
    var map = this;
    // leafgl redraws its points on 'moveend' only, and on 'resize' it just
    // sets the canvas size, which wipes a WebGL canvas. Leaflet fires
    // 'moveend' before 'resize', so any resize of the map box (a session load
    // re-lays the page out) left the points blank until the next zoom or pan.
    // Redraw them after each resize.
    if (!map._twGlResize) {
      map._twGlResize = true;
      map.on('resize', function() {
        setTimeout(function() {
          ((L.glify && L.glify.pointsInstances) || []).forEach(function(q) {
            if (q.map === map && q.layer && q.layer._redraw) q.layer._redraw();
          });
        }, 0);
      });
    }
    if (map._twBox) return; map._twBox = true;
    var on = false, start = null, rect = null, link = null;
    function toggle(v) { on = v; link.classList.toggle('active', on); map.getContainer().style.cursor = on ? 'crosshair' : '';
      if (on) map.dragging.disable(); else map.dragging.enable(); }
    var Box = L.Control.extend({ options: { position: 'topleft' }, onAdd: function() {
      var d = L.DomUtil.create('div', 'leaflet-bar tw-boxzoom'); link = L.DomUtil.create('a', '', d);
      link.href = '#'; link.title = 'Zoom to an area: click, then draw a rectangle on the map (or Shift + drag)';
      link.innerHTML = '<svg viewBox=\"0 0 16 16\" width=\"15\" height=\"15\"><rect x=\"2\" y=\"2\" width=\"12\" height=\"12\" rx=\"1\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.5\" stroke-dasharray=\"2.5 2\"/><path d=\"M8 5v6M5 8h6\" stroke=\"currentColor\" stroke-width=\"1.5\"/></svg>';
      L.DomEvent.on(link, 'click', function(e) { L.DomEvent.stop(e); toggle(!on); });
      L.DomEvent.disableClickPropagation(d); return d; } });
    map.addControl(new Box());
    map.on('mousedown', function(e) { if (!on) return; start = e.latlng;
      rect = L.rectangle([start, start], { color: '#0A6EB4', weight: 1.5, dashArray: '4 3', fillOpacity: 0.08, interactive: false }).addTo(map); });
    map.on('mousemove', function(e) { if (on && start && rect) rect.setBounds(L.latLngBounds(start, e.latlng)); });
    map.on('mouseup', function(e) { if (!on || !start) return;
      var b = L.latLngBounds(start, e.latlng); if (rect) map.removeLayer(rect); rect = null; start = null; toggle(false);
      if (b.isValid() && !b.getNorthEast().equals(b.getSouthWest())) map.fitBounds(b); });
  }")

  MAP_POPUP_MAX <- 20000
  # A household's popup: its id, where it is, and the value it is coloured by
  map_popup <- function(df, i, col, values) {
    fld <- function(k) { cl <- user_setup[[k]]; if (shiny::isTruthy(cl) && cl %in% names(df)) as.character(df[[cl]][i]) else rep("", length(i)) }
    esc <- function(x) htmltools::htmlEscape(ifelse(is.na(x), "", x))
    sprintf("<div class='wfp-map-pop'><b>%s</b><span>%s</span>%s</div>",
            esc(fld("unique_id")), esc(paste(fld("admin2"), fld("village"), sep = " \u00b7 ")),
            if (is.null(col)) "" else sprintf("<span>%s</span><strong>%s</strong>", esc(col), esc(as.character(values[i]))))
  }
  # large maps: the popup of the point clicked, built when it is clicked
  # The column the points are coloured by: the picker, else the vulnerability groups
  map_col <- function(df) {
    col <- if (shiny::isTruthy(input$map_var)) input$map_var else user_setup$v_groups
    if (shiny::isTruthy(col) && col %in% names(df)) col else NULL
  }
  observeEvent(input$map_plot_glify_click, {
    ev <- input$map_plot_glify_click
    pts <- tryCatch(map_points(), error = function(e) NULL)
    if (is.null(pts) || nrow(pts$df) <= MAP_POPUP_MAX) return()
    i <- suppressWarnings(as.integer(ev$id)); if (is.na(i) || i < 1 || i > nrow(pts$df)) return()
    col <- map_col(pts$df)
    html <- map_popup(pts$df, i, col, if (is.null(col)) NULL else pts$df[[col]])
    leaflet::leafletProxy("map_plot", session) |> leaflet::clearPopups() |>
      leaflet::addPopups(lng = pts$lng[i], lat = pts$lat[i], popup = html)
  })

  output$map_plot <- leaflet::renderLeaflet({
    htmlwidgets::onRender(map_render(), box_zoom_js)
  })
  # The map is drawn when the data or the filters change; a new colour only
  # swaps the points and the legend in place, so the view stays where it is.
  map_drawn_col <- NULL
  map_render <- function() {
    pts <- map_points()
    if (nrow(pts$df) == 0) return(base_map())
    xr <- fit_range(pts$lng); yr <- fit_range(pts$lat)
    col <- isolate(map_col(pts$df))
    if (!is.null(col) && map_too_many(pts$df[[col]], col)) col <- NULL
    map_drawn_col <<- col
    # A fixed zoom of 8 centred on the mean coordinate showed a sliver of a
    # country-wide sample; fit to the data instead.
    add_map_points(base_map(c(xr[1], yr[1], xr[2], yr[2])), pts, col) |>
      leaflet::fitBounds(xr[1], yr[1], xr[2], yr[2])
  }
  observeEvent(input$map_var, {
    pts <- tryCatch(map_points(), error = function(e) NULL)
    if (is.null(pts) || nrow(pts$df) == 0) return()
    col <- map_col(pts$df)
    if (identical(col, map_drawn_col)) return()
    if (!is.null(col) && map_too_many(pts$df[[col]], col)) {
      showNotification(too_many_options(pts$df[[col]], col_label(col)), type = "warning", duration = 8)
      updateSelectInput(session, "map_var", selected = map_drawn_col %||% "")
      return()
    }
    map_drawn_col <<- col
    leaflet::leafletProxy("map_plot", session) |>
      leaflet::clearPopups() |>
      leafgl::clearGlGroup("points") |>
      leaflet::removeControl("map_legend") |>
      add_map_points(pts, col)
  }, ignoreInit = TRUE)
  # Coloured as categories (not a number scale) with more options than can be told apart
  map_too_many <- function(values, col) {
    as_scale <- is.numeric(values) && length(unique(stats::na.omit(values))) > 8
    !as_scale && !is.null(too_many_options(values, col))
  }
  # The points coloured by `col`, with their legend (works on a map or a proxy)
  add_map_points <- function(map, pts, col) {
    df <- pts$df
    values <- if (is.null(col)) rep(NA_character_, nrow(df)) else df[[col]]
    if (inherits(values, "haven_labelled")) values <- haven::as_factor(values)
    p <- map_palette(values)
    # Popup: the household, where it is, and the value it is coloured by.
    # Above MAP_POPUP_MAX points the popups are not sent with the map (they
    # were three quarters of its weight: 47 of 61 MB for 300k households); a
    # click asks the server for that household's popup instead.
    inline <- nrow(df) <= MAP_POPUP_MAX
    sf_pts <- sf::st_as_sf(
      data.frame(lng = round(pts$lng, 6), lat = round(pts$lat, 6),
                 popup = if (inline) map_popup(df, seq_len(nrow(df)), col, values) else "", stringsAsFactors = FALSE),
      coords = c("lng", "lat"), crs = 4326
    )
    map <- leafgl::addGlPoints(map,
      data = if (inline) sf_pts else sf_pts[, "geometry"], fillColor = p$color, radius = 7, fillOpacity = 0.9,
      group = "points", popup = if (inline) "popup" else NULL)
    if (p$numeric) {
      map <- leaflet::addLegend(map, "bottomright", pal = p$pal, values = p$values,
                                title = col, opacity = 0.8, layerId = "map_legend")
    } else if (length(p$legend_colors) > 0) {
      map <- leaflet::addLegend(map, "bottomright", colors = p$legend_colors,
                                labels = p$legend_labels, title = col, opacity = 0.8, layerId = "map_legend")
    }
    map
  }

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
  observeEvent(input$view_all, {
    bslib::update_switch("view_follow", value = FALSE, session = session)
    pts <- map_points(); xr <- fit_range(pts$lng); yr <- fit_range(pts$lat)
    leaflet::leafletProxy("map_plot", session) |> leaflet::fitBounds(xr[1] - 1, yr[1] - 1, xr[2] + 1, yr[2] + 1)
  })

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

  AREA_COLS <- c("#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#8a96a3")
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
      plotly::plot_ly(d, x = ~day, y = ~n, type = "bar", marker = list(color = "#0A6EB4"), name = "Households",
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
      plotly::plot_ly(d, x = ~factor(category, levels = category), y = ~pct, type = "bar", marker = list(color = "#0A6EB4"),
                      text = ~sprintf("%.0f%%", 100 * pct), textposition = "outside", cliponaxis = FALSE, textfont = list(size = 9),
                      hovertemplate = "%{x}: %{y:.1%} (%{customdata:,.0f} households)<extra></extra>", customdata = ~n) |>
        plotly::layout(margin = list(l = 8, r = 8, t = 6, b = 26), yaxis = list(visible = FALSE, range = c(0, max(d$pct) * 1.25)),
                       xaxis = list(title = "", tickfont = list(size = 10)))
    } else {
      d <- d[rev(seq_len(nrow(d))), , drop = FALSE]
      plotly::plot_ly(d, y = ~factor(category, levels = category), x = ~pct, type = "bar", orientation = "h", marker = list(color = "#0A6EB4"),
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
  pick <- function(id, label, choices, selected) selectizeInput(ns(id), label, choices = choices, selected = selected, width = "100%", multiple = FALSE)

  output$table_ui <- renderUI({
    ec <- explore_cols(); ch <- ec$ch; all <- ec$all; nums <- ec$nums
    if (length(all) < 1) return(empty_state("No column to tabulate", NULL, "table"))
    tagList(
      tags$div(class = "tw-ct-controls",
        pick("ct_row", "Rows", ch, all[1]),
        pick("ct_col", "Columns", c(`(none: one-way table)` = "", ch), if (length(all) > 1) all[2] else ""),
        selectInput(ns("ct_stat"), "Cells", width = "100%", selectize = FALSE,
                    choices = c("Households" = "n", "Row %" = "row", "Column %" = "col", "Total %" = "total",
                                "Mean of a number" = "mean", "Sum of a number" = "sum")),
        conditionalPanel(sprintf("['mean','sum'].indexOf(input['%s']) >= 0", ns("ct_stat")),
                         pick("ct_value", "Number", if (length(nums)) nums else c("(no numeric column)" = ""), nums[1]))),
      uiOutput(ns("ct_table")))
  })

  output$chart_ui <- renderUI({
    ec <- explore_cols(); ch <- ec$ch; all <- ec$all
    if (length(all) < 1) return(empty_state("No column to chart", NULL, "bar-chart-line"))
    tagList(
      tags$div(class = "tw-ct-controls",
        pick("gb_x", "Variable", ch, all[1]),
        pick("gb_y", "Against", c(`(none)` = "", ch), ""),
        pick("gb_group", "Grouped by", c(`(none)` = "", ch), ""),
        uiOutput(ns("gb_type_ui"))),
      tags$div(class = "mb-2", axis_button(ns("gb_axes"))),
      plotly::plotlyOutput(ns("gb_plot"), height = "360px"),
      tags$div(class = "tw-ct-note", textOutput(ns("gb_note"), inline = TRUE)))
  })

  # the table follows the fields as they change (builders are the exception
  # to "settings wait for their button")
  output$ct_table <- renderUI({
    p <- list(row = input$ct_row, col = input$ct_col, stat = input$ct_stat, value = input$ct_value)
    if (!shiny::isTruthy(p$row)) return(tags$div(class = "small text-muted mt-2", "Choose the rows, the columns and the cells to see the table."))
    df <- view_data(); req(df, p$row, p$row %in% names(df))
    stat <- p$stat %||% "n"
    col <- if (shiny::isTruthy(p$col) && p$col %in% names(df) && p$col != p$row) p$col else NULL
    for (k in c(p$row, col)) if (ov_var_kind(df[[k]]) == "cat") shiny::validate(shiny::need(is.null(too_many_options(df[[k]], col_label(k))), too_many_options(df[[k]], col_label(k))))
    if (stat %in% c("mean", "sum")) shiny::validate(shiny::need(shiny::isTruthy(p$value) && p$value %in% names(df), "Choose the number to average or sum."))
    ct <- contingency(df, p$row, col, NULL, stat, p$value)
    tab <- ct$table
    shiny::validate(shiny::need(nrow(tab) > 1, "No household has an answer for these variables."))
    fmt <- function(v) if (is.na(v)) "" else switch(stat, n = , sum = format(round(v), big.mark = ","), mean = format(signif(v, 3), big.mark = ","),
                                                     sprintf("%.1f%%", v))
    body <- tab[-nrow(tab), if (is.null(col)) 1 else -ncol(tab), drop = FALSE]
    rng <- range(body, na.rm = TRUE); if (!all(is.finite(rng)) || diff(rng) == 0) rng <- c(0, max(1, rng[2], na.rm = TRUE))
    shade <- function(v, margin) if (margin || is.na(v)) NULL else sprintf("background: rgba(10, 110, 180, %.3f)", 0.04 + 0.42 * (v - rng[1]) / diff(rng))
    what <- switch(stat, n = "Households", row = "Share of each row (%)", col = "Share of each column (%)", total = "Share of all households (%)",
                   mean = sprintf("Mean of %s", col_label(p$value)), sum = sprintf("Sum of %s", col_label(p$value)))
    nr <- nrow(tab); nc <- ncol(tab)
    tags$div(class = "tw-ct",
      tags$div(class = "tw-ct-caption", tags$strong(what), sprintf(" \u00b7 %s households", format(ct$n, big.mark = ","))),
      tags$div(class = "tw-ct-wrap", tags$table(class = "tw-ct-table",
        tags$thead(
          if (!is.null(col)) tags$tr(tags$th(class = "tw-ct-corner", ""), tags$th(colspan = nc, class = "tw-ct-colvar", col_label(col))),
          tags$tr(tags$th(class = "tw-ct-rowvar", col_label(p$row)),
                  lapply(seq_len(nc), function(j) tags$th(class = if (colnames(tab)[j] == "Total") "tw-ct-margin num" else "num", colnames(tab)[j])))),
        tags$tbody(lapply(seq_len(nr), function(i) tags$tr(class = if (i == nr) "tw-ct-total" else NULL,
          tags$th(rownames(tab)[i]),
          lapply(seq_len(nc), function(j) { m <- i == nr || colnames(tab)[j] == "Total"
            tags$td(class = paste("num", if (m) "tw-ct-margin"), style = shade(tab[i, j], m), fmt(tab[i, j])) })))))),
      if (is.finite(ct$chi)) tags$div(class = "tw-ct-note",
        sprintf("Chi-square test of independence: p %s%s.",
                if (ct$chi < 0.001) "< 0.001" else sprintf("= %.3f", ct$chi),
                if (ct$chi < 0.05) " (the two variables are related)" else " (no evidence of a relation)")))
  })

  # Chart builder: one or two variables, optionally grouped by a third; the
  # chart follows their types (numbers: scatter and correlation; a number and
  # a category: box plots, means or violins; two categories: stacked bars).
  GB_MAX_POINTS <- 20000
  # Box plots from their five numbers, computed here: sending every household
  # to the browser made them slow on large data
  box_plot <- function(yv, cat, grp, pal) {
    cat <- droplevels(as.factor(cat))
    grp <- if (is.null(grp)) NULL else droplevels(as.factor(grp))
    key <- if (is.null(grp)) list(cat) else list(cat, grp)
    st <- do.call(rbind, lapply(split(seq_along(yv), key, drop = TRUE), function(k) {
      q <- stats::quantile(yv[k], c(.25, .5, .75), names = FALSE); iqr <- q[3] - q[1]
      inr <- yv[k][yv[k] >= q[1] - 1.5 * iqr & yv[k] <= q[3] + 1.5 * iqr]
      data.frame(c = as.character(cat[k[1]]), g = if (is.null(grp)) "" else as.character(grp[k[1]]), q1 = q[1], med = q[2], q3 = q[3],
                 lf = min(inr), uf = max(inr), mean = mean(yv[k]), n = length(k), stringsAsFactors = FALSE)
    }))
    # Clean by design: a light fill in the line's colour, thin lines, the
    # median as the one strong mark, short whiskers, no mean line (the note
    # and the hover give the mean), slim boxes with air between them.
    p <- plotly::plot_ly()
    for (lv in unique(st$g)) {
      s <- st[st$g == lv, , drop = FALSE]
      col <- if (nzchar(lv)) pal(grp)[[lv]] else GB_COLS[1]
      p <- plotly::add_trace(p, type = "box", x = factor(s$c, levels = levels(cat)), q1 = s$q1, median = s$med, q3 = s$q3,
                             lowerfence = s$lf, upperfence = s$uf, name = if (nzchar(lv)) lv else "Households",
                             fillcolor = tint(col, 0.16), line = list(color = col, width = 1.4), whiskerwidth = 0.35,
                             marker = list(color = col), boxpoints = FALSE, legendgroup = lv)
    }
    n_box <- length(unique(st$c))
    plotly::layout(p, boxmode = "group", boxgap = if (n_box == 1) 0.75 else 0.35, boxgroupgap = 0.18,
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showline = TRUE, linecolor = "rgba(128,128,128,0.35)"),
                   yaxis = list(zeroline = FALSE, gridcolor = "rgba(128,128,128,0.15)"))
  }
  GB_COLS <- c("#0A6EB4", "#f7b825", "#3f7e44", "#c5192d", "#26bde2", "#8a96a3", "#5b6b7c", "#e67e22")
  # one look for box plots, means and violins: a light fill in the line's colour
  tint <- function(hex, a) { v <- grDevices::col2rgb(hex); sprintf("rgba(%d,%d,%d,%.2f)", v[1], v[2], v[3], a) }
  # The chart follows the fields as they change: the one exception to
  # "settings wait for their button" (a chart is what the choice is for).
  gb_vars <- reactive({
    df <- view_data(); x <- input$gb_x
    req(df, shiny::isTruthy(x), x %in% names(df))
    y <- if (shiny::isTruthy(input$gb_y) && input$gb_y %in% names(df) && input$gb_y != x) input$gb_y
    g <- if (shiny::isTruthy(input$gb_group) && input$gb_group %in% names(df) && !input$gb_group %in% c(x, y)) input$gb_group
    list(df = df, x = x, y = y, g = g, kx = ov_var_kind(df[[x]]), ky = if (is.null(y)) "none" else ov_var_kind(df[[y]]))
  })
  # the chart types the chosen variables allow (one column each is looked at)
  output$gb_type_ui <- renderUI({
    df <- filtered_data(); x <- input$gb_x; req(df, shiny::isTruthy(x), x %in% names(df))
    y <- if (shiny::isTruthy(input$gb_y) && input$gb_y %in% names(df) && input$gb_y != x) input$gb_y
    ch <- ov_chart_types(ov_var_kind(df[[x]]), if (is.null(y)) "none" else ov_var_kind(df[[y]])); cur <- isolate(input$gb_type)
    selectInput(ns("gb_type"), "Chart", choices = ch, selected = if (isTRUE(cur %in% ch)) cur else unname(ch[1]), selectize = FALSE, width = "100%")
  })
  gb_note <- reactiveVal("")
  output$gb_note <- renderText(gb_note())
  output$gb_plot <- render_wfp_plotly({
    v <- gb_vars(); df <- v$df; n <- nrow(df)
    for (k in c(v$x, v$y, v$g)) {
      if (ov_var_kind(df[[k]]) != "cat") next
      msg <- too_many_options(df[[k]], col_label(k))
      shiny::validate(shiny::need(is.null(msg), msg))
    }
    types <- ov_chart_types(v$kx, v$ky)
    type <- if (isTRUE(input$gb_type %in% types)) input$gb_type else unname(types[1])
    as_cat <- function(col, k = 12) { f <- ov_categories(df[[col]], rep(1, n), max_levels = k); f }
    num <- function(col) as_number(df[[col]])
    g <- if (is.null(v$g)) NULL else as_cat(v$g, 6)
    lab <- function(col) col_label(col)
    pal <- function(f) stats::setNames(rep_len(GB_COLS, nlevels(f)), levels(f))
    base_layout <- function(p, xt, yt, legend = !is.null(g), xr = NULL, yr = NULL) {
      gb_auto(list(x = xr, y = yr))
      plotly::layout(p,
      xaxis = c(list(title = list(text = xt, font = list(size = 11)), tickfont = list(size = 10), automargin = TRUE),
                axis_bounds(gb_axes()$xmin, gb_axes()$xmax, xr)),
      yaxis = c(list(title = list(text = yt, font = list(size = 11)), tickfont = list(size = 10), automargin = TRUE),
                axis_bounds(gb_axes()$ymin, gb_axes()$ymax, yr)),
      showlegend = legend, legend = list(orientation = "h", y = -0.22, font = list(size = 10), title = list(text = if (!is.null(v$g)) lab(v$g) else "")),
      margin = list(l = 8, r = 8, t = 8, b = 8))
    }
    keep <- function(...) { ok <- Reduce(`&`, lapply(list(...), function(z) !is.na(z))); if (!is.null(g)) ok <- ok & !is.na(g); which(ok) }

    # one variable
    if (v$ky == "none" && v$kx == "num") {
      x <- num(v$x); i <- keep(x)
      gb_note(sprintf("%s households; mean %.1f, median %.1f", format(length(i), big.mark = ","), mean(x[i]), stats::median(x[i])))
      p <- if (type == "hist") {
        if (is.null(g)) plotly::plot_ly(x = x[i], type = "histogram", marker = list(color = GB_COLS[1]), nbinsx = 30)
        else plotly::plot_ly(x = x[i], color = g[i], colors = pal(g), type = "histogram", alpha = 0.6, nbinsx = 30) |> plotly::layout(barmode = "overlay")
      } else box_plot(x[i], if (!is.null(g)) g[i] else factor(rep(lab(v$x), length(i))), NULL, pal)
      if (type == "hist") return(base_layout(p, lab(v$x), "Households", xr = range(x[i]),
                                             yr = c(0, max(graphics::hist(x[i], breaks = 30, plot = FALSE)$counts))))
      return(base_layout(p, "", lab(v$x), yr = range(x[i])))
    }
    if (v$ky == "none") {
      x <- as_cat(v$x); i <- keep(x)
      d <- as.data.frame(table(x = x[i], g = if (is.null(g)) rep("All", length(i)) else g[i]), stringsAsFactors = FALSE)
      d <- d[d$Freq > 0 | TRUE, , drop = FALSE]
      if (type == "bars") d$val <- ave(d$Freq, d$g, FUN = function(z) 100 * z / sum(z)) else d$val <- d$Freq
      gb_note(sprintf("%s households", format(length(i), big.mark = ",")))
      p <- if (is.null(g)) plotly::plot_ly(d, x = ~x, y = ~val, type = "bar", marker = list(color = GB_COLS[1]),
                                           text = ~if (type == "bars") sprintf("%.0f%%", val) else format(val, big.mark = ","), textposition = "outside", cliponaxis = FALSE)
           else plotly::plot_ly(d, x = ~x, y = ~val, color = ~g, colors = pal(g), type = "bar") |> plotly::layout(barmode = "group")
      return(base_layout(p, lab(v$x), if (type == "bars") "% of households" else "Households", yr = c(0, max(d$val))))
    }
    # two numbers
    if (v$kx == "num" && v$ky == "num") {
      x <- num(v$x); y <- num(v$y); i <- keep(x, y)
      grp <- if (is.null(g)) factor(rep("All", n)) else g
      p <- plotly::plot_ly()
      notes <- character(0)
      for (lv in levels(droplevels(grp[i]))) {
        j <- i[grp[i] == lv]; col <- if (is.null(g)) GB_COLS[1] else pal(g)[[lv]]
        rtxt <- ov_cor_text(x[j], y[j]); notes <- c(notes, if (is.null(g)) rtxt else sprintf("%s: %s", lv, rtxt))
        nm <- if (is.null(g)) "Households" else sprintf("%s (r = %s)", lv, sub("^r = ([-0-9.]+).*", "\\1", rtxt))
        # at most GB_MAX_POINTS points drawn (WebGL); r and the trend use every household
        jp <- if (length(j) > GB_MAX_POINTS / nlevels(grp)) sort(sample(j, ceiling(GB_MAX_POINTS / nlevels(grp)))) else j
        p <- plotly::add_trace(p, x = x[jp], y = y[jp], type = "scattergl", mode = "markers", name = nm, legendgroup = lv,
                               marker = list(color = col, opacity = 0.55, size = 6),
                               hovertemplate = paste0(lab(v$x), ": %{x}<br>", lab(v$y), ": %{y}<extra>", lv, "</extra>"))
        if (type == "scatter_trend" && length(j) >= 3 && stats::var(x[j]) > 0) {
          fit <- stats::lm(y[j] ~ x[j]); xs <- range(x[j])
          p <- plotly::add_lines(p, x = xs, y = stats::coef(fit)[1] + stats::coef(fit)[2] * xs, name = paste(lv, "trend"), legendgroup = lv,
                                 showlegend = FALSE, line = list(color = col, width = 2), hoverinfo = "skip")
        }
      }
      gb_note(paste(notes, collapse = " \u00b7 "))
      return(base_layout(p, lab(v$x), lab(v$y), xr = range(x[i]), yr = range(y[i])))
    }
    # a category and a number
    if (xor(v$kx == "num", v$ky == "num")) {
      ccol <- if (v$kx == "cat") v$x else v$y; ncol <- if (v$kx == "num") v$x else v$y
      cx <- as_cat(ccol); y <- num(ncol); i <- keep(cx, y)
      gb_note(sprintf("%s households", format(length(i), big.mark = ",")))
      if (type == "mean") {
        grp <- if (is.null(g)) factor(rep("All", n)) else g
        d <- do.call(rbind, lapply(split(i, list(cx[i], grp[i]), drop = TRUE), function(j) {
          m <- mean(y[j]); se <- if (length(j) > 1) stats::sd(y[j]) / sqrt(length(j)) else NA
          data.frame(c = as.character(cx[j[1]]), g = as.character(grp[j[1]]), m = m, ci = 1.96 * se, n = length(j))
        }))
        d$c <- factor(d$c, levels = levels(cx))
        p <- plotly::plot_ly()
        for (lv in unique(d$g)) {
          s <- d[d$g == lv, , drop = FALSE]
          col <- if (is.null(g)) GB_COLS[1] else pal(g)[[lv]]
          p <- plotly::add_bars(p, x = s$c, y = s$m, name = if (is.null(g)) "Mean" else lv, legendgroup = lv,
                                marker = list(color = tint(col, 0.16), line = list(color = col, width = 1.4)),
                                error_y = list(type = "data", array = s$ci, color = col, thickness = 1.2, width = 4),
                                # the hover reads its words from hovertext (customdata did not reach the template)
                                hovertext = sprintf("%s%s<br>Mean %s \u00b1 %s<br>%s households", s$c,
                                                    if (is.null(g)) "" else paste0(" \u00b7 ", lv), fmt5(signif(s$m, 3)),
                                                    ifelse(is.na(s$ci), "-", fmt5(signif(s$ci, 2))), format(s$n, big.mark = ",")),
                                hovertemplate = "%{hovertext}<extra></extra>")
        }
        p <- plotly::layout(p, barmode = "group", bargap = 0.35, bargroupgap = 0.18, xaxis = list(showgrid = FALSE, zeroline = FALSE))
        return(base_layout(p, lab(ccol), paste("Mean of", lab(ncol), "(95% interval)"),
                           yr = c(min(0, d$m - d$ci, na.rm = TRUE), max(d$m + d$ci, d$m, na.rm = TRUE))))
      }
      if (type == "box") return(base_layout(box_plot(y[i], cx[i], if (is.null(g)) NULL else g[i], pal), lab(ccol), lab(ncol), yr = range(y[i])))
      # a violin needs the values: drawn from a sample on large data
      iv <- if (length(i) > GB_MAX_POINTS) sort(sample(i, GB_MAX_POINTS)) else i
      p <- plotly::plot_ly()
      gv <- if (is.null(g)) factor(rep("Households", length(iv))) else droplevels(g[iv])
      for (lv in levels(gv)) {
        k <- iv[gv == lv]
        col <- if (is.null(g)) GB_COLS[1] else pal(g)[[lv]]
        p <- plotly::add_trace(p, type = "violin", x = cx[k], y = y[k], name = lv, legendgroup = lv,
                               fillcolor = tint(col, 0.16), line = list(color = col, width = 1.4), points = FALSE,
                               box = list(visible = TRUE, width = 0.18, fillcolor = tint(col, 0.35), line = list(color = col, width = 1)),
                               meanline = list(visible = FALSE), spanmode = "hard")
      }
      p <- plotly::layout(p, violinmode = "group", violingap = 0.3, violingroupgap = 0.15,
                          xaxis = list(showgrid = FALSE, zeroline = FALSE), yaxis = list(zeroline = FALSE))
      return(base_layout(p, lab(ccol), lab(ncol), yr = range(y[iv])))
    }
    # two categories: bars, one panel per group
    x <- as_cat(v$x); y <- as_cat(v$y, 8); i <- keep(x, y)
    gb_note(sprintf("%s households", format(length(i), big.mark = ",")))
    ycols <- pal(y)
    panel <- function(j, show) {
      d <- as.data.frame(table(x = x[j], y = y[j]), stringsAsFactors = FALSE)
      d$val <- if (type == "stack100") ave(d$Freq, d$x, FUN = function(z) if (sum(z)) 100 * z / sum(z) else 0) else d$Freq
      pp <- plotly::plot_ly()
      for (lv in levels(y)) {
        s <- d[d$y == lv, , drop = FALSE]
        pp <- plotly::add_bars(pp, x = s$x, y = s$val, name = lv, legendgroup = lv, showlegend = show, marker = list(color = ycols[[lv]]),
                               hovertemplate = paste0("%{x}<br>", lv, ": ", if (type == "stack100") "%{y:.1f}%" else "%{y:,}", "<extra></extra>"))
      }
      plotly::layout(pp, barmode = if (type == "dodge") "group" else "stack")
    }
    ytitle <- if (type == "stack100") "% of households" else "Households"
    tab <- table(x[i], y[i])
    yr2 <- c(0, if (type == "stack100") 100 else if (type == "dodge") max(tab) else max(rowSums(tab)))
    if (is.null(g)) {
      p <- panel(i, TRUE)
      return(base_layout(p, lab(v$x), ytitle, legend = TRUE, yr = yr2) |> plotly::layout(legend = list(title = list(text = lab(v$y)))))
    }
    gb_auto(list(x = NULL, y = yr2))
    lvs <- levels(droplevels(g[i]))
    panels <- lapply(seq_along(lvs), function(k) panel(i[g[i] == lvs[k]], k == 1) |>
                       plotly::layout(annotations = list(list(text = lvs[k], x = 0.5, y = 1.06, xref = "paper", yref = "paper", showarrow = FALSE, font = list(size = 11)))))
    p <- plotly::subplot(panels, nrows = ceiling(length(lvs) / 3), shareY = TRUE, titleX = FALSE, margin = 0.04)
    plotly::layout(p, showlegend = TRUE, legend = list(orientation = "h", y = -0.15, font = list(size = 10), title = list(text = lab(v$y))),
                   margin = list(l = 8, r = 8, t = 24, b = 8),
                   yaxis = c(list(title = list(text = ytitle, font = list(size = 11))), axis_bounds(gb_axes()$ymin, gb_axes()$ymax, yr2)))
  })
  # the axes, set in the Axes dialog (NA = automatic); gb_auto is the chart's
  # own range, shown in the dialog
  gb_axes <- reactiveVal(list(ymin = NA_real_, ymax = NA_real_, xmin = NA_real_, xmax = NA_real_))
  gb_auto <- reactiveVal(NULL)
  observeEvent(input$gb_axes, {
    a <- gb_auto()
    r <- function(v) if (is.null(v)) "categories" else sprintf("%s to %s", fmt5(signif(v[1], 3)), fmt5(signif(v[2], 3)))
    hint <- if (!is.null(a)) sprintf("Automatic now: Y %s; X %s.", r(a$y), r(a$x))
    showModal(axis_dialog(ns, "gbax_", gb_axes(), hint, with_x = TRUE))
  })
  observeEvent(input$gbax_apply, { gb_axes(axis_read(input, "gbax_")); removeModal() })
  observeEvent(input$gbax_reset, { gb_axes(list(ymin = NA_real_, ymax = NA_real_, xmin = NA_real_, xmax = NA_real_)); removeModal() })
  observe(updateActionButton(session, "gb_axes", label = if (any(is.finite(unlist(gb_axes())))) "Axes (set)" else "Axes"))

  ## ---------------------- What these data do not allow (one quiet line)

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
