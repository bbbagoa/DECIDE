# Upper bound on the donor rows handed to VIM::kNN. kNN builds an all-pairs
# Gower distance matrix, so cost grows with the SQUARE of the row count: at the
# full 17k rows of a real dataset that is ~290M pairwise distances and the
# session simply stops responding.
#
# Measured on this machine (8 donor columns): 5,000 donors = 0.11 s,
# 10,000 = 0.32 s, 20,000 = 1.76 s. The original 2,000 was picked without
# measuring; 10,000 gives a five times richer donor pool and still returns
# within a third of a second. Raising it further is quadratic, so 20,000 is
# about where an interactive correction stops feeling instant.
KNN_MAX_DONORS <- 10000L

# Upper bound on donor COLUMNS, for the same reason (Gower cost is linear in
# columns but the frame is often 200+ numeric columns wide).
KNN_MAX_DONOR_COLS <- 8L

# Mapped numeric fields, labelled in the variable list.
OUTLIER_FIELD_LABELS <- c(hh_size = "Household size", hhh_age = "HH head age",
                          childU5 = "Children under 5", v_score = "Vulnerability score",
                          weight = "Sampling weight")

#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_outliers_ui <- function(ns) {
  range_box <- function(id, ph) numericInput(ns(id), NULL, value = NA, width = "100%") |>
    tagAppendAttributes(placeholder = ph, .cssSelector = "input")
  bslib::nav_panel(
    title = "Outliers",
    icon = bsicons::bs_icon("speedometer2"),
    tags$div(
      class = "p-3",
      # Settings in one toolbar, like the other data-quality views.
      tags$div(
        class = "d-flex flex-wrap align-items-end gap-3 wfp-dq-toolbar",
        tags$div(style = "flex: 0 1 250px;",
          shinyWidgets::pickerInput(
            inputId = ns("outlier_var"), label = "Variable", width = "100%", choices = NULL,
            options = shinyWidgets::pickerOptions(container = "body", liveSearch = TRUE, size = 12))),
        tags$div(style = "flex: 0 1 190px;",
          selectInput(ns("outlier_method"), "Detection method", width = "100%",
                      choices = c("IQR (Tukey)" = "IQR", "Z-Score (mean/SD)" = "Z", "Modified Z (MAD)" = "MAD",
                                  "Allowed range only" = "none"),
                      selected = "IQR")),
        tags$div(style = "flex: 0 1 200px;", uiOutput(ns("outlier_threshold_ui"))),
        tags$div(style = "flex: 0 1 230px;",
          tags$label(class = "form-label",
                     "Allowed range",
                     info_tip("The values this variable can plausibly take (e.g. a household size of 1 to 30). Values outside it are flagged whatever the distribution says.")),
          tags$div(class = "d-flex gap-2", range_box("range_min", "min"), range_box("range_max", "max"))),
        tags$div(style = "flex: 0 1 210px;",
          selectInput(ns("outlier_correction_method"), "Correction", width = "100%",
                      choices = c("Cap at the limits" = "cap", "Set to missing" = "na",
                                  "Replace with Median" = "median", "Replace with Mean" = "mean",
                                  "K-Nearest Neighbors" = "knn", "Drop Row entirely" = "drop"))),
        tags$div(class = "pb-3",
          actionButton(ns("ol_check"), "Check", icon = icon("magnifying-glass"), class = "btn-primary",
                       title = "Look for outliers with this variable, method and allowed range")),
        tags$div(class = "pb-3",
          actionButton(ns("btn_apply_outlier_correction"), "Correct all flagged",
                       class = "btn-primary", icon = icon("wand-magic-sparkles")))
      ),
      uiOutput(ns("range_hint")),
      uiOutput(ns("ol_stale"))
    ),
    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      bslib::value_box(title = "Values checked", value = textOutput(ns("outlier_total")),
                       showcase = bsicons::bs_icon("list-ol"), theme = "primary"),
      bslib::value_box(title = "Flagged", value = textOutput(ns("outlier_count")),
                       textOutput(ns("outlier_verified")),
                       showcase = bsicons::bs_icon("exclamation-triangle"), theme = "warning"),
      bslib::value_box(title = "Flag rate", value = textOutput(ns("outlier_rate")),
                       showcase = bsicons::bs_icon("percent"), theme = "info"),
      bslib::value_box(title = "Accepted values", value = textOutput(ns("outlier_bounds")),
                       textOutput(ns("outlier_bounds_src")),
                       showcase = bsicons::bs_icon("rulers"), theme = "secondary")
    ),
    bslib::navset_underline(
      id = ns("outlier_tabs"),
      bslib::nav_panel(
        value = "dist", title = tagList(bsicons::bs_icon("bar-chart"), " Distribution"),
        bslib::layout_columns(
          class = "mt-3", col_widths = c(6, 6),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Distribution and limits"),
            plotly::plotlyOutput(ns("plot_outlier_hist"), height = "320px"),
            tags$div(class = "small text-muted px-3 pb-2",
                     "Red dashed: statistical bounds. Blue dotted: allowed range.")
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("By area"),
            plotly::plotlyOutput(ns("plot_outlier_box"), height = "320px")
          )
        )
      ),
      bslib::nav_panel(
        value = "where", title = tagList(bsicons::bs_icon("geo-alt"), " Where they come from"),
        bslib::layout_columns(
          class = "mt-3", col_widths = c(6, 6),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Flag rate by Admin 1"),
            plotly::plotlyOutput(ns("plot_outlier_admin_rates"), height = "320px")
          ),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header("Flag rate by enumerator"),
            plotly::plotlyOutput(ns("plot_outlier_enum_rates"), height = "320px")
          )
        )
      ),
      bslib::nav_panel(
        value = "flagged", title = tagList(bsicons::bs_icon("sort-down"), " Most extreme values"),
        tags$div(
          class = "mt-3",
          uiOutput(ns("outlier_insights")),
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(bsicons::bs_icon("list-check"), " Flagged values, most extreme first"),
            bslib::card_body(
              tags$div(
                class = "d-flex flex-wrap align-items-center gap-2 mb-2",
                actionButton(ns("ol_select_all"), "Select all", class = "btn-outline-secondary btn-sm"),
                actionButton(ns("ol_select_none"), "Clear selection", class = "btn-outline-secondary btn-sm"),
                tags$span(class = "small text-muted", textOutput(ns("ol_selected_n"), inline = TRUE)),
                tags$div(
                  class = "d-flex flex-wrap gap-2 ms-auto",
                  actionButton(ns("ol_correct_sel"), "Correct selected", class = "btn-outline-primary btn-sm",
                               icon = icon("wand-magic-sparkles")),
                  actionButton(ns("ol_set_value"), "Set a value", class = "btn-outline-primary btn-sm", icon = icon("pen")),
                  actionButton(ns("ol_verify"), "Mark as verified", class = "btn-outline-secondary btn-sm",
                               icon = icon("check")),
                  downloadButton(ns("ol_download"), "Export", class = "btn-outline-secondary btn-sm"))
              ),
              DT::DTOutput(ns("ol_table"), fill = FALSE)
            )
          )
        )
      ),
      bslib::nav_panel(
        value = "all", title = tagList(bsicons::bs_icon("grid-3x3-gap"), " All numeric variables"),
        tags$div(
          class = "mt-3",
          bslib::card(
            full_screen = TRUE,
            bslib::card_header(bsicons::bs_icon("clipboard-data"), " Every numeric variable, with the settings above"),
            bslib::card_body(
              tags$div(
                class = "d-flex flex-wrap align-items-center gap-2 mb-2",
                tags$span(class = "small text-muted",
                          "Checks every numeric column with the detection method and the allowed ranges you entered. ",
                          "Click a row to open that variable."),
                actionButton(ns("ol_scan"), "Audit all numeric variables", class = "btn-outline-primary btn-sm ms-auto",
                             icon = icon("magnifying-glass"))
              ),
              uiOutput(ns("ol_scan_empty")),
              DT::DTOutput(ns("ol_scan_table"), fill = FALSE)
            )
          )
        )
      )
    )
  )
}

#' Data Quality sub-tab server
#' Shares the parent module input/output/session/ns namespace.
#' @param input,output,session,ns parent module handles
#' @param core list with dq_filtered_data, uploaded_df, user_setup, modification_log
#' @import shiny
#' @noRd
dq_outliers_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  num_or_na <- function(x) if (is.null(x) || length(x) != 1 || !is.finite(x)) NA_real_ else as.numeric(x)
  fmt <- function(x) if (is.finite(x)) format(round(x, 2), big.mark = ",") else "\u2013"

  # --- which variables ---------------------------------------------------------
  # Every column that holds numbers, the mapped fields first.
  num_cols <- reactive(quantitative_cols(uploaded_df()))

  # column -> setup key, for the mapped numeric fields
  mapped_keys <- reactive({
    keys <- names(OUTLIER_FIELD_LABELS)
    cols <- vapply(keys, function(k) as.character(user_setup[[k]] %||% "")[1], character(1))
    keep <- !is.na(cols) & nzchar(cols)
    stats::setNames(keys[keep], cols[keep])
  })

  last_default <- NULL
  observe({
    cols <- num_cols()
    req(length(cols))
    mk <- mapped_keys()
    mapped <- intersect(names(mk), cols)
    lab <- sprintf("%s (%s)", OUTLIER_FIELD_LABELS[mk[mapped]], mapped)
    choices <- col_choice_groups(`Mapped fields` = stats::setNames(mapped, lab),
                                 `Other numeric columns` = setdiff(cols, mapped))
    cur <- isolate(input$outlier_var)
    # Start on a quantity (household size first), never on a coordinate, a
    # weight or an id; a pick the app made itself follows the mapping when it
    # arrives, one the user made stays.
    def <- outlier_default_var(cols, mk, user_setup)
    keep_cur <- isTRUE(cur %in% cols) && !identical(cur, last_default)
    last_default <<- def
    shinyWidgets::updatePickerInput(session, "outlier_var", choices = choices,
                                    selected = if (keep_cur) cur else def)
  })

  # --- allowed range, remembered per variable -------------------------------
  ranges <- reactiveVal(list())

  # Saved with the session: the variable, the method and every allowed range.
  workspace_register(core$workspace, "dq_outliers",
    snapshot = function() {
      if (is.null(uploaded_df())) return(NULL)
      list(var = input$outlier_var, method = input$outlier_method, threshold = input$outlier_threshold,
           correction = input$outlier_correction_method, ranges = ranges(), applied = ol_applied())
    },
    restore = function(s) {
      ranges(s$ranges %||% list())
      ol_applied(s$applied)
      after_flush(session, function() {
        updateSelectInput(session, "outlier_method", selected = s$method)
        updateSelectInput(session, "outlier_correction_method", selected = s$correction)
        if (shiny::isTruthy(s$var)) shinyWidgets::updatePickerInput(session, "outlier_var", selected = s$var)
        # The slider is redrawn when the method changes; set it once it exists.
        if (!is.null(s$threshold)) after_flush(session, function() updateSliderInput(session, "outlier_threshold", value = s$threshold))
      })
    })
  observeEvent(input$outlier_var, {
    v <- input$outlier_var
    req(nzchar(v %||% ""))
    rg <- ranges()[[v]] %||% suggested_range(mapped_keys()[v])
    # "" empties the React field (an NA would arrive as the text "NA")
    updateNumericInput(session, "range_min", value = if (is.na(rg[1])) "" else rg[1])
    updateNumericInput(session, "range_max", value = if (is.na(rg[2])) "" else rg[2])
  })
  observeEvent(list(input$range_min, input$range_max), {
    v <- input$outlier_var
    req(nzchar(v %||% ""))
    r <- ranges()
    r[[v]] <- c(num_or_na(input$range_min), num_or_na(input$range_max))
    ranges(r)
  }, ignoreInit = TRUE)

  allowed <- reactive({
    a <- c(num_or_na(input$range_min), num_or_na(input$range_max))
    if (!anyNA(a) && a[1] > a[2]) c(NA_real_, NA_real_) else a
  })

  # which hint goes under the allowed range (React, OutliersTab.tsx)
  output$range_hint <- shinyreact::reactive_output({
    a <- c(num_or_na(input$range_min), num_or_na(input$range_max))
    if (!anyNA(a) && a[1] > a[2]) return("inverted")
    if (all(is.na(a))) return("tip")
    key <- mapped_keys()[input$outlier_var %||% ""]
    if (isTRUE(!is.na(key)) && identical(a, suggested_range(key))) return("suggested")
    NULL
  })

  # --- detection ---------------------------------------------------------------
  # Method-specific threshold slider. Each method has its own sensible default and
  # range so the same "sensitivity" control is statistically appropriate:
  #   IQR -> Tukey multiplier (default 1.5)
  #   Z   -> number of SDs     (default 3.0)
  #   MAD -> modified-Z multiplier (default 3.5, the standard Iglewicz-Hoaglin cut-off)
  # The method's threshold slider is drawn by React (OutliersTab.tsx), with the
  # same ranges and defaults: IQR multiplier 1-5 (1.5), SDs 1-6 (3), modified-Z
  # multiplier 1-6 (3.5, the Iglewicz-Hoaglin cut-off); none for "Allowed range only".

  threshold <- reactive({
    if (identical(input$outlier_method, "none")) return(NA_real_)
    req(input$outlier_threshold)
    input$outlier_threshold
  })

  # An exception to "settings wait for their button": the Outliers tab redraws
  # as soon as the variable, the method, the sensitivity or the range changes
  # (after a short pause, so dragging the slider does not recompute each step).
  # ol_applied() stays the one value everything reads, so a restored session or
  # a row picked in "All numeric variables" set it the same way.
  ol_applied <- reactiveVal(NULL)
  ol_now <- function() list(var = input$outlier_var %||% "", method = input$outlier_method %||% "IQR",
                            threshold = if (identical(input$outlier_method, "none")) NA_real_ else (input$outlier_threshold %||% NA_real_),
                            allowed = allowed())
  ol_live <- debounce(reactive(ol_now()), 400)
  observe({
    a <- ol_live()
    req(shiny::isTruthy(a$var))
    if (!identical(a, isolate(ol_applied()))) ol_applied(a)
  })
  output$ol_stale <- renderUI(NULL)
  outlier_info <- reactive({
    df <- dq_filtered_data()
    a <- ol_applied(); req(a)
    var_col <- a$var
    req(df, shiny::isTruthy(var_col), var_col %in% names(df))
    method <- a$method %||% "IQR"

    # via as.character(): .sav/.dta imports arrive factorised, and as.numeric()
    # on a factor returns level codes (1,2,3...), not the recorded values.
    vals <- as_number(df[[var_col]])
    bounds <- outlier_bounds(vals, method, a$threshold)
    rg <- a$allowed
    reason <- outlier_reason(vals, bounds, rg)

    # Values the analyst checked and kept stay out of the flags.
    uid_col <- user_setup$unique_id
    has_uid <- shiny::isTruthy(uid_col) && uid_col %in% names(df)
    verified <- if (has_uid) as.character(df[[uid_col]]) %in% verified_uids(modification_log(), var_col)
                else rep(FALSE, length(vals))
    n_verified <- sum(nzchar(reason) & verified)
    reason[verified] <- ""
    is_outlier <- nzchar(reason)

    list(var_col = var_col, vals = vals, bounds = bounds, allowed = rg,
         limits = outlier_limits(bounds, rg), reason = reason,
         is_outlier = is_outlier, idx = which(is_outlier), n_verified = n_verified,
         uid_col = if (has_uid) uid_col else NULL, method = method)
  })

  # --- KPIs ----------------------------------------------------------------------
  output$outlier_total <- renderText(format(sum(!is.na(outlier_info()$vals)), big.mark = ","))
  output$outlier_count <- renderText(format(length(outlier_info()$idx), big.mark = ","))
  output$outlier_verified <- renderText({
    n <- outlier_info()$n_verified
    if (n) sprintf("%s checked and kept", format(n, big.mark = ",")) else ""
  })
  output$outlier_rate <- renderText({
    info <- outlier_info()
    n <- sum(!is.na(info$vals))
    if (n == 0) return("0%")
    paste0(round(length(info$idx) / n * 100, 1), "%")
  })
  output$outlier_bounds <- renderText({
    l <- outlier_info()$limits
    paste(fmt(l[1]), "to", fmt(l[2]))
  })
  output$outlier_bounds_src <- renderText({
    info <- outlier_info()
    has_rg <- any(!is.na(info$allowed))
    has_stat <- any(is.finite(info$bounds))
    if (has_rg && has_stat) "Tighter of the statistical bounds and the allowed range"
    else if (has_rg) "Allowed range" else if (has_stat) "Statistical bounds" else "No limit set"
  })

  # --- the area level the charts compare (Admin 1 to 4, village: the mapped ones) --
  # A display choice: switching it redraws the area charts and the "concentrated
  # in an area" insight, nothing else.
  ol_levels <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4", village = "Village")
  ol_area <- reactive({
    k <- input$ol_level %||% "admin1"
    if (!k %in% names(ol_levels)) k <- "admin1"
    col <- as.character(user_setup[[k]] %||% "")[1]
    list(key = k, label = ol_levels[[k]], col = if (!is.na(col) && nzchar(col) && col %in% names(dq_filtered_data())) col)
  })
  output$ol_level_meta <- shinyreact::reactive_output({
    keys <- names(ol_levels)[vapply(names(ol_levels), function(k) { v <- as.character(user_setup[[k]] %||% "")[1]; !is.na(v) && nzchar(v) }, logical(1))]
    list(levels = lapply(keys, function(k) list(value = k, label = sprintf("%s · %s", ol_levels[[k]], user_setup[[k]]))),
         current = ol_area()$label)
  })

  # --- charts --------------------------------------------------------------------
  output$plot_outlier_hist <- render_echart({
    info <- outlier_info()
    v <- info$vals[!is.na(info$vals)]
    req(length(v))
    dq_hist_option(v, info$var_col, bounds = info$bounds[is.finite(info$bounds)], allowed = info$allowed[!is.na(info$allowed)])
  })

  output$plot_outlier_box <- render_echart({
    info <- outlier_info()
    a <- ol_area()
    validate(need(!is.null(a$col), sprintf("Map %s to compare the areas.", a$label)))
    df <- dq_filtered_data()
    d <- data.frame(admin = as.character(df[[a$col]]), value = info$vals, stringsAsFactors = FALSE)
    d <- d[!is.na(d$value) & !is.na(d$admin) & nzchar(d$admin), , drop = FALSE]
    req(nrow(d) > 0)
    # many areas (villages): the 25 with the most answers, so each box stays readable
    n_areas <- length(unique(d$admin))
    if (n_areas > 25) {
      keep <- names(sort(table(d$admin), decreasing = TRUE))[1:25]
      d <- d[d$admin %in% keep, , drop = FALSE]
    }
    o <- dq_box_option(d$admin, d$value, info$var_col)
    if (n_areas > 25) o$title <- list(text = sprintf("The 25 of %s areas with the most answers", format(n_areas, big.mark = ",")),
                                      textStyle = list(fontSize = 11, fontWeight = "normal"), left = "center", top = 0)
    o
  })

  # Flag rate per group, among the households that answered.
  rate_plot <- function(group, color, empty_msg) {
    info <- outlier_info()
    d <- data.frame(g = as.character(group), o = info$is_outlier, stringsAsFactors = FALSE)
    d <- d[!is.na(info$vals) & !is.na(d$g) & d$g != "", , drop = FALSE]
    tab <- d |>
      dplyr::group_by(.data$g) |>
      dplyr::summarise(total = dplyr::n(), flagged = sum(.data$o), .groups = "drop") |>
      dplyr::filter(.data$total >= 5) |>
      dplyr::mutate(rate = .data$flagged / .data$total * 100) |>
      dplyr::arrange(dplyr::desc(.data$rate)) |>
      dplyr::slice_head(n = 20)
    validate(need(nrow(tab) > 0, empty_msg))
    dq_hbar(tab$g, round(tab$rate, 1), color = color,
            tips = sprintf("<b>%s</b><br>%.1f%% flagged (%s of %s)", htmltools::htmlEscape(tab$g), tab$rate,
                           format(tab$flagged, big.mark = ","), format(tab$total, big.mark = ",")),
            x_name = "Flagged (%)", x_min = 0, bar_labels = "fn:dec1")
  }

  output$plot_outlier_admin_rates <- render_echart({
    a <- ol_area()
    validate(need(!is.null(a$col), sprintf("Map %s to see where the flags come from.", a$label)))
    rate_plot(dq_filtered_data()[[a$col]], "#f7b825", sprintf("No %s with at least 5 answers to display.", a$label))
  })

  output$plot_outlier_enum_rates <- render_echart({
    validate(need(shiny::isTruthy(user_setup$enumerator_id), "Map the enumerator to see who the flags come from."))
    df <- dq_filtered_data()
    req(user_setup$enumerator_id %in% names(df))
    rate_plot(df[[user_setup$enumerator_id]], "#0A6EB4", "No enumerator data to display")
  })

  # --- most extreme values: insights, table, actions ----------------------------
  flagged_df <- reactive({
    info <- outlier_info()
    df <- dq_filtered_data()
    idx <- info$idx
    if (!length(idx)) return(NULL)
    v <- info$vals[idx]
    rz <- robust_z(v, info$vals)
    med <- stats::median(info$vals, na.rm = TRUE)
    id_cols <- identification_cols(df, user_setup)
    enum <- user_setup$enumerator_id
    if (shiny::isTruthy(enum) && enum %in% names(df)) id_cols <- unique(c(id_cols, enum))
    out <- df[idx, id_cols, drop = FALSE]
    out[] <- lapply(out, as.character)
    out$Value <- v
    out$Flag <- info$reason[idx]
    out$`Robust z` <- round(rz, 1)
    out$`Times the median` <- if (is.finite(med) && med != 0) round(v / med, 1) else NA_real_
    out$.idx <- idx
    out[order(-abs(rz)), , drop = FALSE]
  })

  insight <- dq_insight
  # a "Select ..." link: React sends input$ol_pick = list(what, value, n)
  pick_btn <- function(what, value, label) list(what = what, value = value, label = label)

  # drawn by React (OutliersTab.tsx -> Insights.tsx): the cards and their
  # "Select ..." links, which set input$ol_pick
  output$outlier_insights <- shinyreact::reactive_output({
    info <- outlier_info()
    df <- dq_filtered_data()
    n <- length(info$idx)
    if (!n) {
      return(list(empty = list(title = "No flagged values",
                               sub = if (info$n_verified) sprintf("Every value is inside the limits; %d flagged value(s) were checked and kept.", info$n_verified)
                                     else "Every value is inside the limits.")))
    }
    v <- info$vals[info$idx]
    r <- info$reason[info$idx]
    answered <- sum(!is.na(info$vals))
    cards <- list()

    n_hi <- sum(r %in% c("Statistically high", "Above allowed maximum"))
    n_rg <- sum(grepl("allowed", r))
    cards <- c(cards, list(insight(
      "arrow-down-up", "Direction",
      sprintf("%s high \u00b7 %s low", format(n_hi, big.mark = ","), format(n - n_hi, big.mark = ",")),
      if (n_rg) sprintf("%s outside the allowed range: impossible, not just unusual.", format(n_rg, big.mark = ","))
      else "All inside the allowed range: unusual, possibly true.")))

    rz <- robust_z(v, info$vals)
    if (any(is.finite(rz))) {
      k <- which.max(abs(rz))
      cards <- c(cards, list(insight(
        "bullseye", "Most extreme",
        format(v[k], big.mark = ","),
        sprintf("%.1f robust SDs from the median (%s).", abs(rz[k]),
                format(stats::median(info$vals, na.rm = TRUE), big.mark = ",")))))
    }

    # A flag that sits with one person or one place points at a cause.
    concentration <- function(col, what, icon_name, label) {
      if (!shiny::isTruthy(col) || !col %in% names(df) || n < 5) return(NULL)
      g_all <- as.character(df[[col]])[!is.na(info$vals)]
      g_flag <- as.character(df[[col]][info$idx])
      tf <- sort(table(g_flag), decreasing = TRUE)
      if (!length(tf)) return(NULL)
      top <- names(tf)[1]
      share_flag <- tf[[1]] / n
      share_all <- mean(g_all == top, na.rm = TRUE)
      if (share_flag < 0.2 || share_flag < 2 * share_all) return(NULL)
      insight(icon_name, label, top,
              sprintf("%.0f%% of the flagged values, for %.0f%% of the answers.", 100 * share_flag, 100 * share_all),
              pick_btn(what, top, "Select their values"))
    }
    cards <- c(cards, list(concentration(user_setup$enumerator_id, "enum", "person-badge", "Concentrated on an enumerator"),
                           concentration(ol_area()$col, "admin", "geo-alt", sprintf("Concentrated in an area (%s)", ol_area()$label))))

    sc <- sentinel_codes(v)
    if (nrow(sc)) {
      cards <- c(cards, list(insight(
        "question-octagon", "Looks like a code",
        paste(format(sc$value), collapse = ", "),
        sprintf("%s repeats %d times: probably 'don't know' or 'refused'. Set them to missing rather than to a number.",
                format(sc$value[1]), sc$n[1]),
        pick_btn("value", sc$value, "Select them"))))
    }

    nxt <- if (nrow(sc)) "Select the coded values and correct them with 'Set to missing'."
           else if (n_rg) "Values outside the allowed range cannot be true: check a few with Details, then cap them or set them to missing."
           else if (n / answered > 0.05) "Over 5% of the answers are flagged: the method may be too strict for this variable; widen the threshold or enter an allowed range."
           else "Open the most extreme with Details. Correct what is wrong, and mark what you confirmed as verified so it stops being flagged."
    cards <- c(cards, list(insight("signpost", "Suggested next step", NULL, nxt)))

    list(cards = Filter(Negate(is.null), cards))
  })

  # drawn by React (OutliersTab.tsx); the Details buttons set input$ol_view
  flag_cols <- list(map = list(`Below allowed minimum` = list(color = "#c5192d"), `Above allowed maximum` = list(color = "#c5192d"),
                               `Statistically low` = list(color = "#b07800"), `Statistically high` = list(color = "#b07800")))
  output$ol_table <- render_react_table({
    d <- flagged_df()
    req(d)
    info <- isolate(outlier_info())
    df <- isolate(dq_filtered_data())
    keys <- if (!is.null(info$uid_col)) as.character(df[[info$uid_col]][d$.idx]) else as.character(d$.idx)
    show <- d[, setdiff(names(d), ".idx"), drop = FALSE]
    show$Details <- record_detail_buttons(keys, ns("ol_view"))
    show
  }, page_size = 15, selection = "multiple", html = "Details", styles = list(Flag = flag_cols),
  formats = list(`Robust z` = "dec1", `Times the median` = "dec1"))

  selected_rows <- reactive({
    d <- flagged_df()
    s <- input$ol_table_rows_selected
    if (is.null(d) || !length(s)) integer(0) else d$.idx[s[s <= nrow(d)]]
  })
  output$ol_selected_n <- renderText({
    k <- length(selected_rows())
    if (k) sprintf("%s selected", format(k, big.mark = ",")) else "Select rows to act on some of them only."
  })

  observeEvent(input$ol_select_all, {
    req(input$ol_select_all > 0)
    d <- flagged_df(); need_ok(!is.null(d), "Nothing is flagged for this variable.")
    react_table_select("ol_table", seq_len(nrow(d)))
  })
  observeEvent(input$ol_select_none, { req(input$ol_select_none > 0); react_table_select("ol_table", NULL) })
  observeEvent(input$ol_pick, {
    d <- flagged_df(); need_ok(!is.null(d), "Nothing is flagged for this variable.")
    p <- input$ol_pick
    df <- dq_filtered_data()
    hit <- switch(p$what,
      value = which(d$Value %in% as.numeric(unlist(p$value))),
      enum = which(as.character(df[[user_setup$enumerator_id]][d$.idx]) == p$value),
      admin = if (is.null(ol_area()$col)) integer(0) else which(as.character(df[[ol_area()$col]][d$.idx]) == p$value),
      integer(0))
    react_table_select("ol_table", hit)
    showNotification(sprintf("%d value(s) selected.", length(hit)), type = "message", duration = 3)
  })

  observeEvent(input$ol_view, {
    showModal(record_detail_modal(find_record(dq_filtered_data(), user_setup, input$ol_view),
                                  title = paste("Flagged record:", input$ol_view)))
  })

  output$ol_download <- download_handler(
    filename = function() export_file_name(paste0("Targeting_Outliers_", ol_applied()$var %||% ""), "xlsx"),
    content = function(file) {
      d <- flagged_df()
      write_xlsx_readonly(if (is.null(d)) data.frame(Message = "No flagged values") else d[, setdiff(names(d), ".idx")], file, "Outliers")
    }
  )

  # --- corrections -------------------------------------------------------------
  # kNN on a bounded donor set (see KNN_MAX_* above); falls back to the median.
  knn_impute <- function(df, idx, var_col, uid_col, clean_median) {
    num_cols <- setdiff(names(df)[vapply(df, is.numeric, logical(1))], c(uid_col, var_col))
    if (length(num_cols) < 1) return(rep(clean_median, length(idx)))
    # Donor columns: the most complete numeric variables, so the Gower
    # distance is computed on real values rather than mostly-NA columns.
    completeness <- vapply(df[num_cols], function(x) mean(!is.na(x)), numeric(1))
    keep_cols <- names(sort(completeness, decreasing = TRUE))[seq_len(min(KNN_MAX_DONOR_COLS, length(num_cols)))]
    donor_cols <- unique(c(var_col, keep_cols))
    # Donor rows: an evenly spaced subsample of the other rows, the rows being
    # imputed placed FIRST so their positions are known. Evenly spaced rather
    # than sample(): the same correction run twice must give the same values.
    donor_pool <- setdiff(seq_len(nrow(df)), idx)
    if (length(donor_pool) > KNN_MAX_DONORS) {
      donor_pool <- donor_pool[unique(round(seq(1, length(donor_pool), length.out = KNN_MAX_DONORS)))]
    }
    df_temp <- df[c(idx, donor_pool), donor_cols, drop = FALSE]
    df_temp[[var_col]] <- as_number(df_temp[[var_col]])
    df_temp[[var_col]][seq_along(idx)] <- NA_real_
    imputed <- tryCatch(VIM::kNN(df_temp, variable = var_col, k = 5, imp_var = FALSE), error = function(e) NULL)
    if (is.null(imputed)) rep(clean_median, length(idx)) else as.numeric(imputed[[var_col]][seq_along(idx)])
  }

  # The proposal is computed once and kept, so what the preview shows is
  # exactly what Apply writes.
  pending <- reactiveVal(NULL)

  # rows: positions in dq_filtered_data(); method: a correction, or "manual"
  propose <- function(rows, method, manual_value = NA_real_) {
    info <- outlier_info()
    fdf <- dq_filtered_data()
    df <- uploaded_df()
    uid_col <- info$uid_col
    if (is.null(uid_col) || !uid_col %in% names(df)) {
      showNotification("Map a unique ID in the setup before correcting values.", type = "error")
      return(NULL)
    }
    ids <- as.character(df[[uid_col]])
    idx <- which(ids %in% as.character(fdf[[uid_col]][rows]))
    if (!length(idx)) return(NULL)
    var_col <- info$var_col
    all_vals <- as_number(df[[var_col]])
    old <- all_vals[idx]
    flagged_all <- which(ids %in% as.character(fdf[[uid_col]][info$idx]))
    clean <- all_vals[setdiff(seq_along(all_vals), flagged_all)]
    whole <- all(clean == round(clean), na.rm = TRUE)   # a count stays a count
    new <- switch(method,
      mean = rep(mean(clean, na.rm = TRUE), length(idx)),
      median = rep(stats::median(clean, na.rm = TRUE), length(idx)),
      cap = pmin(pmax(old, info$limits[1]), info$limits[2]),
      na = rep(NA_real_, length(idx)),
      manual = rep(manual_value, length(idx)),
      knn = knn_impute(df, idx, var_col, uid_col, stats::median(clean, na.rm = TRUE)),
      old)   # drop: no replacement
    if (whole && method %in% c("mean", "median", "knn")) new <- round(new)
    list(idx = idx, uids = ids[idx], old_vals = old, new_vals = as.numeric(new), method = method,
         var_col = var_col, uid_col = uid_col, detect = info$method,
         limits = info$limits)
  }

  method_label <- function(m) switch(m, cap = "capped at the limits", na = "set to missing", mean = "replaced by the mean",
                                     median = "replaced by the median", knn = "imputed by k-nearest neighbours",
                                     drop = "row dropped", manual = "set by hand", m)

  confirm_modal <- function(prop) {
    if (prop$method == "drop") {
      body <- tags$div(
        tags$p(class = "text-danger", sprintf("This will permanently DROP %d row(s) from the dataset.", length(prop$idx))),
        tags$p("It can only be undone with Reset to Original Data."))
    } else {
      all_vals <- as_number(uploaded_df()[[prop$var_col]])
      projected <- all_vals
      projected[prop$idx] <- prop$new_vals
      mk_stats <- function(v) {
        v <- v[!is.na(v)]
        sprintf("mean = %.2f | median = %.2f | SD = %.2f | min = %.2f | max = %.2f",
                mean(v), stats::median(v), stats::sd(v), min(v), max(v))
      }
      ex <- utils::head(data.frame(ID = prop$uids, Before = prop$old_vals, After = prop$new_vals), 8)
      body <- tags$div(
        bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(bslib::card_header(class = "small fw-bold", "Before"),
                      bslib::card_body(class = "small", tags$code(mk_stats(all_vals)))),
          bslib::card(bslib::card_header(class = "small fw-bold", "After (projected)"),
                      bslib::card_body(class = "small", tags$code(mk_stats(projected))))
        ),
        tags$table(class = "wfp-model-table mt-2",
                   tags$thead(tags$tr(tags$th("ID"), tags$th(class = "num", "Before"), tags$th(class = "num", "After"))),
                   tags$tbody(lapply(seq_len(nrow(ex)), function(i) tags$tr(
                     tags$td(ex$ID[i]), tags$td(class = "num", format(ex$Before[i])),
                     tags$td(class = "num", if (is.na(ex$After[i])) "missing" else format(round(ex$After[i], 2))))))),
        if (length(prop$idx) > 8) tags$div(class = "small text-muted", sprintf("... and %d more.", length(prop$idx) - 8)))
    }
    showModal(modalDialog(
      # "wand-magic-sparkles" is a Font Awesome name; bs_icon() threw on it and
      # the whole confirmation modal failed to open.
      title = tags$div(bsicons::bs_icon("magic", class = "text-primary me-2"), "Confirm the correction"),
      body,
      tags$p(class = "text-muted small mt-2",
             sprintf("%d value(s) of '%s' %s.", length(prop$idx), prop$var_col, method_label(prop$method))),
      textInput(ns("ol_reason"), "Reason (written to the audit trail)", width = "100%",
                placeholder = "e.g. confirmed with the field team"),
      easyClose = TRUE,
      footer = tagList(modalButton("Cancel"),
                       actionButton(ns("btn_confirm_outlier_correction"), "Apply", class = "btn-primary"))
    ))
  }

  start_correction <- function(rows, method, manual_value = NA_real_) {
    # Computing the proposal is the expensive step (kNN especially), so the
    # overlay goes up BEFORE it runs rather than only on confirmation.
    waiter::waiter_show(html = waiter_content("Computing proposed correction..."), color = "rgba(10, 30, 50, 0.65)")
    on.exit(waiter::waiter_hide(), add = TRUE)
    prop <- propose(rows, method, manual_value)
    if (is.null(prop)) return()
    pending(prop)
    confirm_modal(prop)
  }

  observe({
    n <- tryCatch(length(outlier_info()$idx), error = function(e) 0)
    gate_button("btn_apply_outlier_correction", n > 0, "Nothing is flagged for this variable with these settings.")
    has <- tryCatch(!is.null(flagged_df()), error = function(e) FALSE)
    for (b in c("ol_select_all", "ol_correct_sel", "ol_set_value", "ol_verify", "ol_download"))
      gate_button(b, has, "Nothing is flagged for this variable with these settings.")
  })

  observeEvent(input$btn_apply_outlier_correction, {
    req(input$btn_apply_outlier_correction > 0)   # a React button sends 0 at start
    info <- outlier_info()
    if (!length(info$idx)) { showNotification("Nothing is flagged.", type = "message"); return() }
    start_correction(info$idx, input$outlier_correction_method)
  })
  observeEvent(input$ol_correct_sel, {
    req(input$ol_correct_sel > 0)   # a React button sends 0 at start
    rows <- selected_rows()
    if (!length(rows)) { showNotification("Select rows in the table first.", type = "warning"); return() }
    start_correction(rows, input$outlier_correction_method)
  })
  observeEvent(input$ol_set_value, {
    req(input$ol_set_value > 0)   # a React button sends 0 at start
    rows <- selected_rows()
    if (!length(rows)) { showNotification("Select the rows to set first.", type = "warning"); return() }
    showModal(modalDialog(
      title = tagList(bsicons::bs_icon("pencil"), " Set a value"),
      tags$p(sprintf("New value of '%s' for the %d selected row(s):", ol_applied()$var %||% "", length(rows))),
      numericInput(ns("ol_manual_value"), NULL, value = NA, width = "200px"),
      easyClose = TRUE,
      footer = tagList(modalButton("Cancel"), actionButton(ns("ol_manual_next"), "Preview", class = "btn-primary"))
    ))
  })
  observeEvent(input$ol_manual_next, {
    v <- num_or_na(input$ol_manual_value)
    if (is.na(v)) { showNotification("Type a number.", type = "warning"); return() }
    start_correction(selected_rows(), "manual", v)
  })

  log_rows <- function(uids, column, old, new, action, reason) {
    rows <- data.frame(timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = as.character(uids),
                       column = column, old_value = as.character(old), new_value = as.character(new),
                       action = action, user = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
                       reason = reason, stringsAsFactors = FALSE)
    modification_log(dplyr::bind_rows(modification_log(), rows))
  }

  observeEvent(input$btn_confirm_outlier_correction, tw_guard("Correcting the outliers", {
    prop <- pending()
    req(prop)
    waiter::waiter_show(html = waiter_content("Applying the correction\u2026"), color = "rgba(10, 30, 50, 0.65)")
    on.exit(waiter::waiter_hide(), add = TRUE)

    df <- uploaded_df()
    idx <- prop$idx
    var_col <- prop$var_col
    note <- trimws(input$ol_reason %||% "")
    lim <- if (prop$method == "cap") sprintf(" [%s, %s]", fmt(prop$limits[1]), fmt(prop$limits[2])) else ""
    reason <- sprintf("%s on %s, %s%s%s", if (identical(prop$detect, "none")) "Outside the allowed range" else paste(prop$detect, "outlier"),
                      var_col, method_label(prop$method), lim, if (nzchar(note)) paste0(": ", note) else "")

    if (prop$method == "drop") {
      df <- df[-idx, , drop = FALSE]
      log_rows(prop$uids, "ALL", "Row Existed", "Deleted", "Outlier deletion", reason)
    } else {
      old_raw <- df[[var_col]][idx]
      # A factor cannot take a new value; text columns keep being text.
      if (is.factor(df[[var_col]])) df[[var_col]] <- as.character(df[[var_col]])
      df[[var_col]][idx] <- if (is.character(df[[var_col]])) as.character(prop$new_vals) else prop$new_vals
      log_rows(prop$uids, var_col, old_raw, prop$new_vals, paste("Outlier correction:", prop$method), reason)
    }
    uploaded_df(df)
    pending(NULL)
    removeModal()
    showNotification(sprintf("%d value(s) corrected and logged.", length(idx)), type = "message")
  }))

  # Checked and true: logged, and no longer flagged (read back by verified_uids()).
  observeEvent(input$ol_verify, {
    req(input$ol_verify > 0)   # a React button sends 0 at start
    rows <- selected_rows()
    if (!length(rows)) { showNotification("Select the values you checked first.", type = "warning"); return() }
    showModal(modalDialog(
      title = tagList(bsicons::bs_icon("check2-circle"), " Mark as verified"),
      tags$p(sprintf("%d value(s) of '%s' will be kept as they are and no longer flagged.", length(rows), ol_applied()$var %||% "")),
      textInput(ns("ol_verify_reason"), "How was it verified?", width = "100%",
                placeholder = "e.g. confirmed by phone with the household"),
      easyClose = TRUE,
      footer = tagList(modalButton("Cancel"), actionButton(ns("ol_verify_ok"), "Keep these values", class = "btn-primary"))
    ))
  })
  observeEvent(input$ol_verify_ok, {
    rows <- selected_rows()
    info <- outlier_info()
    if (is.null(info$uid_col)) { showNotification("Map a unique ID in the setup first.", type = "error"); return() }
    reason <- trimws(input$ol_verify_reason %||% "")
    if (!nzchar(reason)) { showNotification("Say how the values were verified.", type = "warning"); return() }
    df <- dq_filtered_data()
    log_rows(df[[info$uid_col]][rows], info$var_col, info$vals[rows], info$vals[rows], "Outlier verified (kept)", reason)
    removeModal()
    showNotification(sprintf("%d value(s) marked as verified.", length(rows)), type = "message")
  })

  # --- every numeric variable at once -----------------------------------------
  scan <- eventReactive(input$ol_scan, {
    req(input$ol_scan > 0)   # a React button sends 0 at start
    waiter::waiter_show(html = waiter_content("Checking every numeric variable..."), color = "rgba(10, 30, 50, 0.65)")
    on.exit(waiter::waiter_hide(), add = TRUE)
    df <- dq_filtered_data()
    cols <- intersect(num_cols(), names(df))
    mk <- mapped_keys()
    rg <- ranges()
    # Mapped fields not opened yet still get their suggested range.
    for (cl in setdiff(intersect(names(mk), cols), names(rg))) rg[[cl]] <- suggested_range(mk[[cl]])
    if (shiny::isTruthy(input$outlier_var)) rg[[input$outlier_var]] <- allowed()
    labels <- stats::setNames(unname(OUTLIER_FIELD_LABELS[mk]), names(mk))
    numeric_audit(df, cols, input$outlier_method %||% "IQR", threshold(), rg, labels)
  })

  output$ol_scan_table <- render_react_table({
    s <- scan()
    req(s, nrow(s) > 0)
    names(s) <- c("Variable", "Mapped as", "Answered", "Missing (%)", "Min", "Median", "Max",
                  "Allowed range", "Flagged", "Flagged (%)")
    s
  }, page_size = 15, selection = "single",
  formats = list(Answered = "int", Min = "dec2", Median = "dec2", Max = "dec2", Flagged = "int"),
  styles = list(`Flagged (%)` = list(bar = "#c5192d")))

  observeEvent(input$ol_scan_table_rows_selected, {
    s <- scan()
    i <- input$ol_scan_table_rows_selected
    req(s, length(i) == 1)
    shinyWidgets::updatePickerInput(session, "outlier_var", selected = s$variable[i])
    rg <- ranges()[[s$variable[i]]] %||% suggested_range(mapped_keys()[s$variable[i]])
    ol_applied(list(var = s$variable[i], method = input$outlier_method %||% "IQR",
                    threshold = if (identical(input$outlier_method, "none")) NA_real_ else (input$outlier_threshold %||% NA_real_),
                    allowed = if (length(rg) == 2) rg else c(NA_real_, NA_real_)))
    bslib::nav_select("outlier_tabs", "dist", session = session)
  })
}

#' The variable the Outliers tab starts on
#'
#' The first mapped quantity (household size, head's age, children under 5,
#' score), else the first numeric column that is not a coordinate, a weight
#' or an identifier.
#' @param cols Numeric columns; `mk` column -> mapped key.
#' @noRd
outlier_default_var <- function(cols, mk, setup) {
  for (k in c("hh_size", "hhh_age", "childU5", "v_score")) {
    hit <- names(mk)[mk == k]
    if (length(hit) && hit[1] %in% cols) return(hit[1])
  }
  avoid <- unlist(lapply(c("lon", "lat", "weight", "unique_id"), function(k) as.character(setup[[k]] %||% "")[1]))
  rest <- cols[!cols %in% avoid & !grepl("(^|_)(lon|lat|long|longitude|latitude|gps|x|y|weight|wgt|id|uuid|index)($|_)", tolower(cols))]
  c(rest, cols)[1]
}

#' A histogram with the statistical bounds (red dashed) and the allowed range
#' (blue dotted) as lines
#' @noRd
dq_hist_option <- function(v, name, bounds = numeric(0), allowed = numeric(0)) {
  whole <- all(v == round(v)) && diff(range(v)) <= 60
  h <- graphics::hist(v, breaks = if (whole) seq(min(v) - 0.5, max(v) + 0.5, 1) else "Sturges", plot = FALSE)
  tip <- sprintf("%s to %s: <b>%s</b> households", format(signif(h$breaks[-length(h$breaks)], 4)),
                 format(signif(h$breaks[-1], 4)), format(h$counts, big.mark = ","))
  if (whole) tip <- sprintf("%s: <b>%s</b> households", format(h$mids), format(h$counts, big.mark = ","))
  ml <- c(lapply(bounds, function(x) list(xAxis = x, lineStyle = list(color = "#c5192d", type = "dashed", width = 1.5),
                                          label = list(formatter = format(signif(x, 4)), color = "#c5192d", fontSize = 10))),
          lapply(allowed, function(x) list(xAxis = x, lineStyle = list(color = "#0A6EB4", type = "dotted", width = 2),
                                           label = list(formatter = format(signif(x, 4)), color = "#0A6EB4", fontSize = 10))))
  # the axis takes in the lines; round ends, so its labels stay plain numbers
  lo <- floor(min(c(h$breaks, bounds, allowed))); hi <- ceiling(max(c(h$breaks, bounds, allowed)))
  s <- list(type = "bar", barWidth = "96%", itemStyle = list(color = "rgba(10,110,180,0.6)"),
            data = lapply(seq_along(h$mids), function(i) list(value = list(h$mids[i], h$counts[i]), tip = tip[i])))
  if (length(ml)) s$markLine <- list(silent = TRUE, symbol = "none", data = ml)
  list(grid = list(left = 8, right = 16, top = 34, bottom = 8, containLabel = TRUE),
       tooltip = list(trigger = "item", formatter = "fn:tip"),
       xAxis = list(type = "value", name = name, nameLocation = "middle", nameGap = 26, min = lo, max = hi,
                    axisLabel = list(formatter = if (hi - lo < 20) "fn:dec1" else "fn:num", hideOverlap = TRUE)),
       yAxis = list(type = "value", name = "Households", axisLabel = list(formatter = "fn:num")),
       series = list(s))
}

#' Box plots of a variable by area (at most 30 areas, the largest), the values
#' beyond the whiskers as points (at most 2,000)
#' @noRd
dq_box_option <- function(g, v, name) {
  n <- sort(table(g), decreasing = TRUE)
  keep <- sort(names(n)[seq_len(min(30, length(n)))])
  st <- lapply(keep, function(k) grDevices::boxplot.stats(v[g == k]))
  out <- do.call(rbind, lapply(seq_along(keep), function(i) if (length(st[[i]]$out)) data.frame(i = i - 1, y = st[[i]]$out)))
  if (!is.null(out) && nrow(out) > 2000) out <- out[order(-abs(out$y))[seq_len(2000)], , drop = FALSE]
  list(grid = list(left = 8, right = 16, top = 34, bottom = 8, containLabel = TRUE),
       tooltip = list(trigger = "item"),
       xAxis = list(type = "category", data = I(keep), axisLabel = list(interval = 0, rotate = if (length(keep) > 6) 35 else 0,
                                                                         width = 110, overflow = "truncate")),
       yAxis = list(type = "value", name = name, scale = TRUE),
       series = list(
         list(type = "boxplot", name = name, data = lapply(st, function(x) x$stats),
              itemStyle = list(color = "rgba(10,110,180,0.15)", borderColor = "#0A6EB4")),
         list(type = "scatter", name = "Beyond the whiskers", symbolSize = 5, itemStyle = list(color = "#c5192d", opacity = 0.6),
              data = if (is.null(out)) list() else lapply(seq_len(nrow(out)), function(k) list(out$i[k], out$y[k])))))
}
