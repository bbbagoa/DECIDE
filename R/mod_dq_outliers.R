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

#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_outliers_ui <- function(ns) {
          bslib::nav_panel(
            title = "Outliers",
            icon = bsicons::bs_icon("speedometer2"),
            tags$div(
              class = "p-3",
              # Settings in one toolbar, like the other data-quality views.
              tags$div(
                class = "d-flex flex-wrap align-items-end gap-3 wfp-dq-toolbar",
                tags$div(style = "flex: 0 1 200px;",
                  shinyWidgets::pickerInput(
                    inputId = ns("outlier_var"), label = "Variable", width = "100%",
                    choices = c("Household Size" = "hh_size", "HH Head Age" = "hhh_age",
                                "Children Under 5" = "childU5", "Vulnerability Score" = "v_score"),
                    selected = "hh_size")),
                tags$div(style = "flex: 0 1 190px;",
                  selectInput(ns("outlier_method"), "Detection method", width = "100%",
                              choices = c("IQR (Tukey)" = "IQR", "Z-Score (mean/SD)" = "Z", "Modified Z (MAD)" = "MAD"),
                              selected = "IQR")),
                tags$div(style = "flex: 0 1 220px;", uiOutput(ns("outlier_threshold_ui"))),
                tags$div(style = "flex: 0 1 200px;",
                  selectInput(ns("outlier_correction_method"), "Correction", width = "100%",
                              choices = c("Replace with Mean" = "mean", "Replace with Median" = "median",
                                          "K-Nearest Neighbors" = "knn", "Drop Row entirely" = "drop"))),
                tags$div(class = "pb-3",
                  actionButton(ns("btn_apply_outlier_correction"), "Apply correction",
                               class = "btn-primary", icon = icon("wand-magic-sparkles")))
              )
            ),
            bslib::layout_columns(
              col_widths = c(3, 3, 3, 3),
              bslib::value_box(title = "Records checked", value = textOutput(ns("outlier_total")),
                               showcase = bsicons::bs_icon("list-ol"), theme = "primary"),
              bslib::value_box(title = "Outliers detected", value = textOutput(ns("outlier_count")),
                               showcase = bsicons::bs_icon("exclamation-triangle"), theme = "warning"),
              bslib::value_box(title = "Outlier rate", value = textOutput(ns("outlier_rate")),
                               showcase = bsicons::bs_icon("percent"), theme = "info"),
              bslib::value_box(title = "Allowed range", value = textOutput(ns("outlier_bounds")),
                               showcase = bsicons::bs_icon("rulers"), theme = "secondary")
            ),
            bslib::navset_underline(
              bslib::nav_panel(
                title = tagList(bsicons::bs_icon("bar-chart"), " Distribution"),
                bslib::layout_columns(
                  class = "mt-3", col_widths = c(6, 6),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Distribution and allowed range"),
                plotly::plotlyOutput(ns("plot_outlier_hist"), height = "320px")
              ),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("By area"),
                plotly::plotlyOutput(ns("plot_outlier_box"), height = "320px")
              )
                )
              ),
              bslib::nav_panel(
                title = tagList(bsicons::bs_icon("geo-alt"), " Where they come from"),
                bslib::layout_columns(
                  class = "mt-3", col_widths = c(6, 6),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Outlier rate by Admin 1"),
                plotly::plotlyOutput(ns("plot_outlier_admin_rates"), height = "320px")
              ),
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("Outlier rate by enumerator"),
                plotly::plotlyOutput(ns("plot_outlier_enum_rates"), height = "320px")
              )
                )
              ),
              bslib::nav_panel(
                title = tagList(bsicons::bs_icon("sort-down"), " Most extreme"),
                tags$div(class = "mt-3",
                  bslib::card(
                full_screen = TRUE,
                bslib::card_header("The 25 most extreme flagged values"),
                plotly::plotlyOutput(ns("plot_outlier_top_values"), height = "380px")
              ))
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

  # OUTLIER DETECTION AND CORRECTION LOGIC
  # -----------------------------------------------------------------------------------

  # Method-specific threshold slider. Each method has its own sensible default and
  # range so the same "sensitivity" control is statistically appropriate:
  #   IQR -> Tukey multiplier (default 1.5)
  #   Z   -> number of SDs     (default 3.0)
  #   MAD -> modified-Z multiplier (default 3.5, the standard Iglewicz-Hoaglin cut-off)
  output$outlier_threshold_ui <- renderUI({
    m <- input$outlier_method
    cfg <- switch(m,
      "IQR" = list(label = "IQR Multiplier:", min = 1, max = 5, value = 1.5, step = 0.5),
      "Z"   = list(label = "Standard Deviations:", min = 1, max = 6, value = 3.0, step = 0.5),
      list(label = "Modified-Z Multiplier:", min = 1, max = 6, value = 3.5, step = 0.5) # MAD
    )
    sliderInput(ns("outlier_threshold"), cfg$label,
                min = cfg$min, max = cfg$max, value = cfg$value, step = cfg$step)
  })

  # Reactive to calculate outliers based on user settings
  outlier_info <- reactive({
    req(dq_filtered_data(), input$outlier_var, user_setup[[input$outlier_var]], input$outlier_threshold)

    df <- dq_filtered_data()
    var_col <- user_setup[[input$outlier_var]]
    req(var_col %in% names(df))

    # via as.character(): .sav/.dta imports arrive factorised, and as.numeric()
    # on a factor returns level codes (1,2,3...), not the recorded values.
    vals <- suppressWarnings(as.numeric(as.character(df[[var_col]])))

    threshold <- input$outlier_threshold

    if (input$outlier_method == "IQR") {
      q1 <- quantile(vals, 0.25, na.rm = TRUE)
      q3 <- quantile(vals, 0.75, na.rm = TRUE)
      iqr <- q3 - q1
      lower_bound <- q1 - threshold * iqr
      upper_bound <- q3 + threshold * iqr
    } else if (input$outlier_method == "MAD") {
      # Modified z-score using the Median Absolute Deviation. Robust to the very
      # outliers we are detecting (unlike mean/SD). 1.4826 scales MAD to the SD
      # for normal data; threshold default 3.5 is the Iglewicz-Hoaglin cut-off.
      med <- median(vals, na.rm = TRUE)
      mad_val <- median(abs(vals - med), na.rm = TRUE)
      if (is.na(mad_val) || mad_val == 0) {
        # Degenerate: no spread around the median -> nothing is an outlier
        lower_bound <- -Inf; upper_bound <- Inf
      } else {
        scaled <- mad_val * 1.4826
        lower_bound <- med - threshold * scaled
        upper_bound <- med + threshold * scaled
      }
    } else {
      # Classic Z-score (mean/SD). NOTE: SD is contaminated by the outliers
      # themselves; MAD is preferred for skewed data.
      m <- mean(vals, na.rm = TRUE)
      s <- sd(vals, na.rm = TRUE)
      if (is.na(s) || s == 0) {
        lower_bound <- -Inf; upper_bound <- Inf
      } else {
        lower_bound <- m - threshold * s
        upper_bound <- m + threshold * s
      }
    }

    # Identify outliers
    is_outlier <- !is.na(vals) & (vals < lower_bound | vals > upper_bound)
    outlier_df <- df[is_outlier, ]

    list(
      var_col = var_col,
      vals = vals,
      lower_bound = lower_bound,
      upper_bound = upper_bound,
      outlier_df = outlier_df,
      is_outlier = is_outlier
    )
  })
  
  # Render Histogram
  output$plot_outlier_hist <- render_wfp_plotly({
    info <- outlier_info()
    req(info)
    
    plotly::plot_ly(x = info$vals, type = "histogram", name = "Distribution") |>
      plotly::add_segments(x = info$lower_bound, xend = info$lower_bound, 
                           y = 0, yend = 100, name = "Lower Bound", line = list(color = "red", dash = "dash")) |>
      plotly::add_segments(x = info$upper_bound, xend = info$upper_bound, 
                           y = 0, yend = 100, name = "Upper Bound", line = list(color = "red", dash = "dash")) |>
      plotly::layout(
        xaxis = list(title = info$var_col),
        yaxis = list(title = "Count"),
        showlegend = TRUE
      )
  })
  
  # Render Boxplot by Admin 1
  output$plot_outlier_box <- render_wfp_plotly({
    info <- outlier_info()
    req(info, user_setup$admin1)
    
    df <- dq_filtered_data()
    admin_col <- user_setup$admin1
    
    plotly::plot_ly(df, y = as.formula(paste0("~", info$var_col)), color = as.formula(paste0("~", admin_col)), type = "box") |>
      plotly::layout(
        xaxis = list(title = admin_col),
        yaxis = list(title = info$var_col),
        showlegend = FALSE
      )
  })
  
  # Summary metrics
  output$outlier_total <- renderText({
    info <- outlier_info()
    req(info)
    format(sum(!is.na(info$vals)), big.mark = ",")
  })

  output$outlier_count <- renderText({
    info <- outlier_info()
    req(info)
    format(sum(info$is_outlier), big.mark = ",")
  })

  output$outlier_rate <- renderText({
    info <- outlier_info()
    req(info)
    n <- sum(!is.na(info$vals))
    if (n == 0) return("0%")
    paste0(round(sum(info$is_outlier) / n * 100, 1), "%")
  })

  output$outlier_bounds <- renderText({
    info <- outlier_info()
    req(info)
    paste0(round(info$lower_bound, 2), " - ", round(info$upper_bound, 2))
  })

  # Outlier rate by Admin 1
  output$plot_outlier_admin_rates <- render_wfp_plotly({
    info <- outlier_info()
    req(info, shiny::isTruthy(user_setup$admin1))
    df <- dq_filtered_data()
    admin_col <- user_setup$admin1
    req(admin_col %in% names(df))

    plot_df <- data.frame(
      admin = as.character(df[[admin_col]]),
      is_outlier = info$is_outlier,
      stringsAsFactors = FALSE
    ) |>
      dplyr::filter(!is.na(.data$admin), .data$admin != "") |>
      dplyr::group_by(.data$admin) |>
      dplyr::summarise(
        total = dplyr::n(),
        outliers = sum(.data$is_outlier, na.rm = TRUE),
        rate = ifelse(.data$total == 0, 0, .data$outliers / .data$total * 100),
        .groups = "drop"
      ) |>
      dplyr::filter(.data$total >= 5) |>
      dplyr::arrange(dplyr::desc(.data$rate)) |>
      dplyr::slice_head(n = 20)

    if (nrow(plot_df) == 0) {
      return(plotly::plot_ly() |> plotly::layout(
        title = "No admin-level data to display",
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      ))
    }

    plotly::plot_ly(
      plot_df,
      x = ~rate,
      y = ~reorder(admin, rate),
      type = "bar",
      marker = list(color = "#f7b825"),
      hovertemplate = "%{y}: %{x:.1f}%<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Outliers (%)", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = ""),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 120)
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  # Outlier rate by Enumerator
  output$plot_outlier_enum_rates <- render_wfp_plotly({
    info <- outlier_info()
    req(info, shiny::isTruthy(user_setup$enumerator_id))
    df <- dq_filtered_data()
    enum_col <- user_setup$enumerator_id
    req(enum_col %in% names(df))

    plot_df <- data.frame(
      enumerator = as.character(df[[enum_col]]),
      is_outlier = info$is_outlier,
      stringsAsFactors = FALSE
    ) |>
      dplyr::filter(!is.na(.data$enumerator), .data$enumerator != "") |>
      dplyr::group_by(.data$enumerator) |>
      dplyr::summarise(
        total = dplyr::n(),
        outliers = sum(.data$is_outlier, na.rm = TRUE),
        rate = ifelse(.data$total == 0, 0, .data$outliers / .data$total * 100),
        .groups = "drop"
      ) |>
      dplyr::filter(.data$total >= 5) |>
      dplyr::arrange(dplyr::desc(.data$rate)) |>
      dplyr::slice_head(n = 20)

    if (nrow(plot_df) == 0) {
      return(plotly::plot_ly() |> plotly::layout(
        title = "No enumerator data to display",
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      ))
    }

    plotly::plot_ly(
      plot_df,
      x = ~rate,
      y = ~reorder(enumerator, rate),
      type = "bar",
      marker = list(color = "#0A6EB4"),
      hovertemplate = "%{y}: %{x:.1f}%<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = "Outliers (%)", gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = ""),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 120)
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  # Most extreme flagged values
  output$plot_outlier_top_values <- render_wfp_plotly({
    info <- outlier_info()
    req(info)
    df <- info$outlier_df
    if (nrow(df) == 0) {
      return(plotly::plot_ly() |> plotly::layout(
        title = "No outliers detected",
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)"
      ))
    }

    vals <- as.numeric(df[[info$var_col]])
    uid_col <- user_setup$unique_id
    if (shiny::isTruthy(uid_col) && uid_col %in% names(df)) {
      label <- substr(as.character(df[[uid_col]]), 1, 20)
    } else {
      label <- paste0("Row ", seq_len(nrow(df)))
    }

    plot_df <- data.frame(
      label = label,
      value = vals,
      stringsAsFactors = FALSE
    ) |>
      dplyr::arrange(dplyr::desc(abs(.data$value))) |>
      dplyr::slice_head(n = 25) |>
      dplyr::arrange(.data$value)

    plotly::plot_ly(
      plot_df,
      x = ~value,
      y = ~reorder(label, value),
      type = "bar",
      marker = list(color = "#c5192d"),
      hovertemplate = "%{y}: %{x}<extra></extra>"
    ) |>
      plotly::layout(
        xaxis = list(title = info$var_col, gridcolor = "rgba(128,128,128,0.2)"),
        yaxis = list(title = ""),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        margin = list(l = 140)
      ) |>
      plotly::config(displayModeBar = FALSE)
  })

  # Apply Correction Logic
  # D4: compute the proposed replacement values WITHOUT mutating the master
  # data, so a before/after preview can be shown for confirmation. Returns a
  # list with idx, old_vals, new_vals, method, var_col, uid_col (or NULL).
  proposed_correction <- reactive({
    info <- outlier_info()
    if (is.null(info) || nrow(info$outlier_df) == 0) return(NULL)
    df <- uploaded_df()
    var_col <- info$var_col
    method <- input$outlier_correction_method
    uid_col <- user_setup$unique_id
    if (!uid_col %in% names(df)) return(NULL)
    outlier_uids <- info$outlier_df[[uid_col]]
    idx <- which(df[[uid_col]] %in% outlier_uids)
    # Use [[var_col]][idx] (not df[idx, var_col]) so we always get a vector;
    # df[idx, var_col] can return a 1-column data.frame, which as.numeric()
    # cannot coerce -> "'list' object cannot be coerced to type 'double'".
    old_vals <- suppressWarnings(as.numeric(df[[var_col]][idx]))

    new_vals <- if (method == "mean") {
      rep(mean(as.numeric(df[[var_col]][!df[[uid_col]] %in% outlier_uids]), na.rm = TRUE), length(idx))
    } else if (method == "median") {
      rep(median(as.numeric(df[[var_col]][!df[[uid_col]] %in% outlier_uids]), na.rm = TRUE), length(idx))
    } else if (method == "drop") {
      old_vals  # dropped -- no replacement
    } else if (method == "knn") {
      clean_median <- function() {
        rep(stats::median(as.numeric(df[[var_col]][-idx]), na.rm = TRUE), length(idx))
      }
      num_cols <- setdiff(names(df)[vapply(df, is.numeric, logical(1))], c(uid_col, var_col))

      if (length(num_cols) < 1) {
        clean_median()
      } else {
        # Bound BOTH dimensions of the distance matrix (see KNN_MAX_* above).
        # Donor columns: the most complete numeric variables, so the Gower
        # distance is computed on real values rather than mostly-NA columns.
        completeness <- vapply(df[num_cols], function(x) mean(!is.na(x)), numeric(1))
        keep_cols <- names(sort(completeness, decreasing = TRUE))[
          seq_len(min(KNN_MAX_DONOR_COLS, length(num_cols)))
        ]
        donor_cols <- unique(c(var_col, keep_cols))

        # Donor rows: an evenly spaced subsample of the non-outlier rows, with
        # the rows being imputed always placed FIRST so their positions are
        # known. Evenly spaced rather than sample(): an unseeded draw meant the
        # same correction run twice produced different imputed values, which
        # is not something an audit trail should have to explain.
        donor_pool <- setdiff(seq_len(nrow(df)), idx)
        if (length(donor_pool) > KNN_MAX_DONORS) {
          donor_pool <- donor_pool[unique(round(
            seq(1, length(donor_pool), length.out = KNN_MAX_DONORS)
          ))]
        }

        df_temp <- df[c(idx, donor_pool), donor_cols, drop = FALSE]
        df_temp[[var_col]] <- suppressWarnings(as.numeric(as.character(df_temp[[var_col]])))
        df_temp[[var_col]][seq_along(idx)] <- NA_real_

        imputed <- tryCatch(
          VIM::kNN(df_temp, variable = var_col, k = 5, imp_var = FALSE),
          error = function(e) NULL
        )
        if (is.null(imputed)) clean_median() else as.numeric(imputed[[var_col]][seq_along(idx)])
      }
    } else {
      old_vals
    }

    list(idx = idx, old_vals = old_vals, new_vals = as.numeric(new_vals),
         method = method, var_col = var_col, uid_col = uid_col,
         outlier_uids = outlier_uids, detect = input$outlier_method)
  })

  # Step 1: show a before/after preview modal. No data is mutated yet.
  observeEvent(input$btn_apply_outlier_correction, {
    # Computing the proposal is the expensive step (kNN especially), so the
    # overlay goes up BEFORE it runs rather than only on confirmation.
    waiter::waiter_show(html = waiter_content("Computing proposed correction..."),
                        color = "rgba(10, 30, 50, 0.65)")
    on.exit(waiter::waiter_hide(), add = TRUE)

    prop <- proposed_correction()
    req(prop)
    if (length(prop$idx) == 0) return()

    if (prop$method == "drop") {
      before_after <- tags$div(
        tags$p(class = "text-warning",
               paste("This will permanently DROP", length(prop$idx), "rows from the dataset.")),
        tags$p("The action is reversible only via the Audit Trail / Reset to Original Data.")
      )
    } else {
      before_n <- length(prop$old_vals)
      # projected distribution stats after replacing the outlier cells
      df_full <- as.numeric(uploaded_df()[[prop$var_col]])
      projected <- df_full
      projected[prop$idx] <- prop$new_vals
      mk_stats <- function(v) {
        v <- v[!is.na(v)]
        sprintf("mean = %.2f | median = %.2f | SD = %.2f | min = %.2f | max = %.2f",
                mean(v), median(v), stats::sd(v), min(v), max(v))
      }
      before_after <- tags$div(
        bslib::layout_columns(
          bslib::card(
            bslib::card_header(class = "small fw-bold", "Before"),
            bslib::card_body(class = "small", tags$code(mk_stats(df_full)))
          ),
          bslib::card(
            bslib::card_header(class = "small fw-bold", "After (projected)"),
            bslib::card_body(class = "small", tags$code(mk_stats(projected)))
          ),
          col_widths = c(6, 6)
        ),
        tags$hr(),
        tags$p(class = "text-muted small",
               paste0("Method: ", prop$method, " \u2014 affects ", before_n,
                      " value(s) in column '", prop$var_col, "'."))
      )
    }

    showModal(modalDialog(
      # "wand-magic-sparkles" is a Font Awesome name; bs_icon() threw on it and
      # the whole confirmation modal failed to open.
      title = tags$div(bsicons::bs_icon("magic", class = "text-primary me-2"),
                       "Confirm Outlier Correction"),
      before_after,
      easyClose = TRUE,
      footer = tagList(
        modalButton("Cancel"),
        actionButton(ns("btn_confirm_outlier_correction"), "Apply", class = "btn-success")
      )
    ))
  })

  # Step 2: the analyst confirmed -- perform the mutation + audit (original logic).
  observeEvent(input$btn_confirm_outlier_correction, {
    waiter::waiter_show(html = waiter_content(), color = "rgba(10, 30, 50, 0.65)")
    on.exit(waiter::waiter_hide(), add = TRUE)

    prop <- proposed_correction()
    req(prop)
    idx <- prop$idx
    if (length(idx) == 0) { removeModal(); return() }

    df <- uploaded_df()
    var_col <- prop$var_col
    method <- prop$method
    uid_col <- prop$uid_col
    outlier_uids <- prop$outlier_uids
    old_vals <- df[[var_col]][idx]   # vector, not a 1-col data.frame
    new_vals <- prop$new_vals

    if (method == "drop") {
      df <- df[-idx, ]
    } else {
      if (method == "knn") showNotification("KNN imputation complete.", type = "message", duration = 4)
      df[idx, var_col] <- new_vals
    }

    # Update audit trail: the method and its settings are the reason.
    outlier_reason <- sprintf("%s outliers on %s, corrected by %s%s", prop$detect %||% "flagged", var_col, method,
                              if (identical(method, "knn")) " (k = 5 nearest households on the numeric columns)" else "")
    if (method != "drop") {
      audit_rows <- data.frame(
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        uid = df[[uid_col]][idx],
        column = var_col,
        old_value = as.character(old_vals),
        new_value = as.character(new_vals),
        action = paste("Outlier correction:", method),
        user = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
        reason = outlier_reason,
        stringsAsFactors = FALSE
      )
      current_log <- modification_log()
      modification_log(dplyr::bind_rows(current_log, audit_rows))
    } else {
      audit_rows <- data.frame(
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        uid = outlier_uids,
        column = "ALL",
        old_value = "Row Existed",
        new_value = "Deleted",
        action = "Outlier deletion",
        user = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
        reason = outlier_reason,
        stringsAsFactors = FALSE
      )
      current_log <- modification_log()
      modification_log(dplyr::bind_rows(current_log, audit_rows))
    }

    uploaded_df(df)
    removeModal()
    showNotification(paste(length(idx), "outliers corrected and logged."), type = "message")
  })
}
