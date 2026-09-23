#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_missing_ui <- function(ns) {
          bslib::nav_panel(
            title = "Missing Data Checking",
            icon = bsicons::bs_icon("clipboard-data"),

            tags$div(
              id = ns("dq_missing_data"),
              class = "p-3",

              # Toolbar: fields + geo level, then the action
              tags$div(
                class = "d-flex flex-wrap align-items-end gap-3",
                tags$div(
                  style = "flex: 1 1 320px; max-width: 560px;",
                  shinyWidgets::pickerInput(
                    inputId = ns("mandatory_vars"),
                    label = "Mandatory fields to check:",
                    choices = NULL, # Filled by server
                    multiple = TRUE,
                    width = "100%",
                    options = shinyWidgets::pickerOptions(
                      actionsBox = TRUE,
                      liveSearch = TRUE
                    )
                  )
                ),
                tags$div(
                  style = "flex: 0 1 200px;",
                  shinyWidgets::pickerInput(
                    inputId = ns("missing_geo_level"),
                    label = "Geo level:",
                    choices = c("Admin 1", "Admin 2", "Admin 3", "Admin 4", "Village"),
                    selected = "Admin 1",
                    width = "100%"
                  )
                ),
                tags$div(
                  class = "pb-3",
                  actionButton(
                    ns("btn_apply_missing"),
                    "Apply",
                    class = "btn-primary",
                    icon = icon("filter")
                  )
                )
              ),
              uiOutput(ns("missing_hint"))
            ),

            # Result cards are rendered server-side once an analysis has run
            # (see output$missing_results), so the tab isn't a wall of empty
            # cards before the first Apply.
            uiOutput(ns("missing_results"))
          )
}

#' Data Quality sub-tab server
#' Shares the parent module input/output/session/ns namespace.
#' @param input,output,session,ns parent module handles
#' @param core list with dq_filtered_data, uploaded_df, user_setup, modification_log
#' @import shiny
#' @noRd
dq_missing_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log
  applied_missing <- core$applied_missing

  has_missing_analysis <- reactive(!is.null(applied_missing$vars) && length(applied_missing$vars) > 0)

  output$missing_hint <- renderUI({
    if (!has_missing_analysis()) {
      empty_state("No missing-data check yet",
                  "Pick the fields that must be filled in, choose a geographic level, then click Apply.",
                  icon = "clipboard-data")
    }
  })

  # Headline numbers first, then one view per question: which fields,
  # which combinations, where.
  output$missing_results <- renderUI({
    req(has_missing_analysis())
    tagList(
      uiOutput(ns("missing_kpis")),
      bslib::navset_underline(
        bslib::nav_panel(
          title = tagList(bsicons::bs_icon("list-check"), " By field"),
          bslib::layout_columns(
            class = "mt-3",
            bslib::card(
              full_screen = TRUE,
              bslib::card_header("Completeness by field"),
              plotly::plotlyOutput(ns("plot_field_completeness"), height = "360px")
            ),
            bslib::card(
              full_screen = TRUE,
              bslib::card_header("Column health"),
              DT::DTOutput(ns("tab_col_health"), fill = FALSE)
            ),
            col_widths = c(7, 5)
          )
        ),
        bslib::nav_panel(
          title = tagList(bsicons::bs_icon("grid-3x3-gap"), " Patterns"),
          bslib::card(
            class = "mt-3", full_screen = TRUE,
            bslib::card_header("Which fields go missing together"),
            plotly::plotlyOutput(ns("plot_missing_upset"), height = "460px")
          )
        ),
        bslib::nav_panel(
          title = tagList(bsicons::bs_icon("geo-alt"), " By location"),
          bslib::card(
            class = "mt-3", full_screen = TRUE,
            bslib::card_header("Gap rate by location"),
            plotly::plotlyOutput(ns("plot_geo_missing_bars"), height = "420px")
          ),
          bslib::layout_columns(
            bslib::card(
              full_screen = TRUE,
              bslib::card_header("Categorical fields by location"),
              plotly::plotlyOutput(ns("plot_missing_qualitative"), height = "420px")
            ),
            bslib::card(
              full_screen = TRUE,
              bslib::card_header("Numeric fields by location"),
              plotly::plotlyOutput(ns("plot_missing_quantitative"), height = "420px")
            ),
            col_widths = c(6, 6)
          )
        )
      )
    )
  })

  # Missing cells per checked field (NA, "" or "NULL").
  field_health <- reactive({
    req(dq_filtered_data(), applied_missing$vars)
    df <- dq_filtered_data()
    vars <- intersect(as.character(applied_missing$vars), names(df))
    miss <- vapply(vars, function(v) sum(is.na(df[[v]]) | as.character(df[[v]]) %in% c("", "NULL")), numeric(1))
    comp <- if (nrow(df)) 100 * (1 - miss / nrow(df)) else rep(NA_real_, length(vars))
    data.frame(field = vars, missing = miss, completeness = round(comp, 1),
               status = ifelse(is.na(comp), "Review", ifelse(comp >= 95, "OK", ifelse(comp >= 90, "Review", "At risk"))),
               stringsAsFactors = FALSE)
  })

  output$missing_kpis <- renderUI({
    h <- field_health()
    g <- tryCatch(shared_gap_analysis(), error = function(e) NULL)
    n <- nrow(dq_filtered_data())
    gap_n <- if (is.null(g)) sum(rowSums(vapply(h$field, function(v) {
      x <- dq_filtered_data()[[v]]; is.na(x) | as.character(x) %in% c("", "NULL")
    }, logical(n))) > 0) else sum(g$is_incomplete)
    worst <- h[which.min(h$completeness), , drop = FALSE]
    bslib::layout_columns(
      class = "mt-3",
      col_widths = c(3, 3, 3, 3),
      bslib::value_box(title = "Complete records", value = if (n) sprintf("%.1f%%", 100 * (1 - gap_n / n)) else "\u2014",
                       showcase = bsicons::bs_icon("check2-circle"), theme = "success"),
      bslib::value_box(title = "Records with a gap", value = format(gap_n, big.mark = ","),
                       showcase = bsicons::bs_icon("exclamation-circle"), theme = "warning"),
      bslib::value_box(title = "Fields below 95%", value = sprintf("%d of %d", sum(h$completeness < 95, na.rm = TRUE), nrow(h)),
                       showcase = bsicons::bs_icon("list-check"), theme = "info"),
      bslib::value_box(title = "Least complete field",
                       value = if (nrow(worst)) sprintf("%s \u00b7 %.1f%%", worst$field, worst$completeness) else "\u2014",
                       showcase = bsicons::bs_icon("arrow-down-circle"), theme = "danger")
    )
  })

  output$plot_field_completeness <- render_wfp_plotly({
    h <- field_health(); req(nrow(h) > 0)
    h <- h[order(h$completeness, decreasing = TRUE), , drop = FALSE]
    h$field <- factor(h$field, levels = h$field)
    h$status <- factor(h$status, levels = c("OK", "Review", "At risk"))
    plotly::plot_ly(h, x = ~completeness, y = ~field, color = ~status, type = "bar", orientation = "h",
                    colors = c("#3f7e44", "#d08a00", "#c5192d"),
                    text = ~sprintf("%.1f%%", completeness), textposition = "outside", cliponaxis = FALSE,
                    customdata = ~missing,
                    hovertemplate = "%{y}: %{x:.1f}% complete<br>%{customdata} empty cells<extra></extra>") |>
      plotly::layout(xaxis = list(title = "Completeness (%)", range = c(0, 108)),
                     yaxis = list(title = "", automargin = TRUE), bargap = 0.35,
                     shapes = list(list(type = "line", x0 = 95, x1 = 95, y0 = 0, y1 = 1, yref = "paper",
                                        line = list(color = "rgba(128,128,128,.6)", dash = "dot"))),
                     legend = list(orientation = "h", x = 0, y = 1.08, xanchor = "left", yanchor = "bottom"))
  })

  #### --------------------- Missing Data Panel
  ## ----------------------------------------------------------------------------------

  #  Part A: Column Health Summary
  #  This calculates how many NA or empty values exist
  # in every column of your filtered dataset.

  output$tab_col_health <- DT::renderDT({
    req(dq_filtered_data(), applied_missing$vars)
    df <- dq_filtered_data() # Initial filtered data
    total_n <- nrow(df) # Total Rows in the dataset
    target_cols <- applied_missing$vars # Selected by User
    missing_counts <- sapply(df[target_cols], function(x) {
      sum(is.na(x) | as.character(x) == "" | as.character(x) == "NULL")
    })

    # Fast vectorized missingness check
    health <- data.frame(
      Variable = target_cols,
      Missing_Count = as.numeric(unname(missing_counts)),
      stringsAsFactors = FALSE
    ) |>
      dplyr::mutate(
        # total_n is 0 when the filters leave no rows; without the guard every
        # Completeness cell rendered "NaN%".
        Completeness = if (total_n > 0) {
          round((1 - (Missing_Count / total_n)) * 100, 1)
        } else {
          NA_real_
        },
        # D2: status bands turn the table from display into actionability.
        # >=95% OK (green), 90-95% Review (amber), <90% At risk (red).
        Status = dplyr::case_when(
          is.na(Completeness)        ~ "Review",
          Completeness >= 95         ~ "OK",
          Completeness >= 90         ~ "Review",
          TRUE                       ~ "At risk"
        )
      ) |>
      dplyr::arrange(dplyr::desc(Missing_Count))

    DT::datatable(
      health,
      colnames = c("Variable", "Empty Cells", "Completeness (%)", "Status"),
      options = list(pageLength = 20, dom = 'tip'),
      rownames = FALSE
    ) |>
      # This adds the % without changing the underlying numeric data
      DT::formatString(columns = "Completeness", suffix = "%") |>
      DT::formatStyle(0, target = 'row', lineHeight = '50%') |>
      # Color-band the Completeness cell and the Status badge
      # The band backgrounds are fixed pale tints in both themes, so the text
      # colour has to be pinned dark too -- inheriting the theme's near-white ink
      # made these cells unreadable in dark mode.
      DT::formatStyle(
        "Completeness",
        backgroundColor = DT::styleInterval(c(90, 95), c("#f8d7da", "#fff3cd", "#d4edda")),
        color = DT::styleInterval(c(90, 95), c("#842029", "#664d03", "#0f5132"))
      ) |>
      DT::formatStyle(
        "Status",
        backgroundColor = DT::styleEqual(c("OK", "Review", "At risk"), c("#d4edda", "#fff3cd", "#f8d7da")),
        color = DT::styleEqual(c("OK", "Review", "At risk"), c("#0f5132", "#664d03", "#842029")),
        fontWeight = "bold"
      )
  })

  # Part B: The "Incomplete"
  # Household ListThis reactive finds the rows where any of
  # the selected "Mandatory Pillars" are missing.

  # Apply missing-data analysis selections
  observeEvent(input$btn_apply_missing, {
    waiter::waiter_show(
      html = waiter_content(),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)

    applied_missing$vars <- input$mandatory_vars
    applied_missing$geo_level <- input$missing_geo_level
    showNotification("Missing-data analysis updated.", type = "message")
  })

  # 3. Update the Column PickerJust like we did for the Name Audit,
  # update the choices once the file is uploaded.

  observeEvent(uploaded_df(), {
    req(uploaded_df())
    cols <- names(uploaded_df())

    shinyWidgets::updatePickerInput(
      session = session,
      inputId = "mandatory_vars",
      choices = cols,
      selected = NULL # Let user pick what is mandatory
    )
  })

  # -------- Missiing Overlap Bar Charts

  output$plot_missing_qualitative <- render_wfp_plotly({
    req(dq_filtered_data(), applied_missing$vars, applied_missing$geo_level)
    df <- dq_filtered_data()

    # 1. Identify which selected variables are Qualitative (Character/Factor)
    selected_vars <- applied_missing$vars
    is_qual <- sapply(df[selected_vars], function(x) {
      is.character(x) || is.factor(x)
    })
    qual_vars <- selected_vars[is_qual]

    # Extract location anchor from user_setup
    geo_key <- tolower(gsub(" ", "", applied_missing$geo_level))
    real_geo_col <- user_setup[[geo_key]]

    # Safety Check: If no qualitative variables are chosen, exit gracefully
    req(length(qual_vars) > 0, !is.null(real_geo_col))
    qual_vars <- setdiff(qual_vars, real_geo_col)
    if (length(qual_vars) == 0) {
      return(NULL)
    }

    # 2. Reshape and compute percentages
    sub_df <- df |>
      dplyr::select(Location = all_of(real_geo_col), all_of(qual_vars)) |>
      dplyr::mutate(
        Location = as.character(Location),
        dplyr::across(all_of(qual_vars), as.character)
      )

    geo_stats <- sub_df |>
      tidyr::pivot_longer(
        cols = all_of(qual_vars),
        names_to = "Variable",
        values_to = "Value"
      ) |>
      dplyr::mutate(
        Is_Missing = is.na(Value) | Value == "" | Value == "NULL"
      ) |>
      dplyr::group_by(Location, Variable) |>
      dplyr::summarise(
        total = dplyr::n(),
        missing_n = sum(Is_Missing),
        .groups = "drop"
      ) |>
      dplyr::mutate(perc_missing = round((missing_n / total) * 100, 1)) |>
      dplyr::filter(missing_n > 0)

    req(nrow(geo_stats) > 0)

    gg_qual <- ggplot2::ggplot(
      geo_stats,
      ggplot2::aes(x = perc_missing, y = reorder(Location, perc_missing))
    ) +
      ggplot2::geom_col(fill = "#0A6EB4", alpha = 0.8) +
      ggplot2::facet_wrap(~Variable, scales = "free_y") +
      ggplot2::theme_minimal() +
      ggplot2::labs(x = "% Gaps (Categorical)", y = NULL) +
      ggplot2::theme(
        strip.text = ggplot2::element_text(color = "#0A6EB4", face = "bold")
      )

    plotly::ggplotly(gg_qual, height = 400) |>
      plotly::layout(
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)'
      )
  })

  ### ---------------- Quantiytative plot

  output$plot_missing_quantitative <- render_wfp_plotly({
    req(dq_filtered_data(), applied_missing$vars, applied_missing$geo_level)
    df <- dq_filtered_data()

    # 1. Identify which selected variables are Quantitative (Numeric/Integer/Double)
    selected_vars <- applied_missing$vars
    is_quant <- sapply(df[selected_vars], is.numeric)
    quant_vars <- selected_vars[is_quant]

    geo_key <- tolower(gsub(" ", "", applied_missing$geo_level))
    real_geo_col <- user_setup[[geo_key]]

    # Safety Check: If no numeric variables are chosen, exit gracefully
    req(length(quant_vars) > 0, !is.null(real_geo_col))

    # 2. Reshape and calculate missing metrics
    sub_df <- df |>
      dplyr::select(Location = all_of(real_geo_col), all_of(quant_vars)) |>
      dplyr::mutate(
        Location = as.character(Location),
        dplyr::across(all_of(quant_vars), as.character)
      )

    geo_stats <- sub_df |>
      tidyr::pivot_longer(
        cols = all_of(quant_vars),
        names_to = "Variable",
        values_to = "Value"
      ) |>
      dplyr::mutate(
        Is_Missing = is.na(Value) | Value == "" | Value == "NULL"
      ) |>
      dplyr::group_by(Location, Variable) |>
      dplyr::summarise(missing_n = sum(Is_Missing), .groups = "drop") |>
      dplyr::filter(missing_n > 0)

    req(nrow(geo_stats) > 0)

    # 3. Render as a Dot Plot (highly readable for numeric scale comparisons)
    gg_quant <- ggplot2::ggplot(
      geo_stats,
      ggplot2::aes(
        x = missing_n,
        y = reorder(Location, missing_n),
        color = Variable
      )
    ) +
      ggplot2::geom_segment(
        ggplot2::aes(x = 0, xend = missing_n, yend = Location),
        color = "grey50"
      ) +
      ggplot2::geom_point(size = 3) +
      ggplot2::scale_color_brewer(palette = "Oranges") + # Vibrant contrast color
      ggplot2::theme_minimal() +
      ggplot2::labs(x = "Total Volume of Missing Records", y = NULL)

    plotly::ggplotly(gg_quant, height = 400) |>
      plotly::layout(
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)'
      )
  })

  ## ------------------------ Nice upset graph
  # ----------------------------------------------------------------------------------

  # COMPUTE ONCE: This reactive sits in memory and updates all charts instantly
  shared_gap_analysis <- reactive({
    req(dq_filtered_data(), applied_missing$vars)
    df <- dq_filtered_data()
    pillars <- unlist(as.character(applied_missing$vars))

    req(length(pillars) >= 2)

    # 1. Fast Vectorized Matrix Layer. Unified missingness definition: NA, empty
    # string, or the literal "NULL" (matches the enumerator module's intent and
    # the column-health table above, so the modules no longer disagree).
    missing_matrix <- is.na(df[pillars]) |
      df[pillars] == "" |
      df[pillars] == "NULL"
    is_incomplete <- rowSums(missing_matrix) > 0

    # 2. Binary matrix for the UpSet engine
    binary_df <- as.data.frame(missing_matrix + 0L)

    # 3. D3: weighted incompleteness, so geo-gap and KPIs honour survey weights
    #    when a weight column is mapped (falls back to 1s = unweighted).
    weights <- get_weights(df, user_setup)
    weighted_total <- sum(weights, na.rm = TRUE)
    weighted_gapped <- sum(weights[is_incomplete], na.rm = TRUE)

    # Return a structured list containing all pre-computed elements
    list(
      df = df,
      pillars = pillars,
      missing_matrix = missing_matrix,
      is_incomplete = is_incomplete,
      binary_df = binary_df,
      total_rows = nrow(df),
      weights = weights,
      weighted_total = weighted_total,
      weighted_gapped = weighted_gapped,
      weighted_incomplete_rate = if (weighted_total > 0) weighted_gapped / weighted_total else NA_real_
    )
  })

  output$plot_missing_upset <- render_wfp_plotly({
    gap_data <- shared_gap_analysis()
    req(gap_data)

    pillars <- gap_data$pillars

    req(length(pillars) >= 2)

    # Reuse the matrix layer for total set sizes (bars on the left)
    set_sizes <- data.frame(
      Variable = as.character(pillars),
      Total_Missing = as.numeric(unname(colSums(gap_data$missing_matrix))),
      stringsAsFactors = FALSE
    )
    # --- STEP 3: THE HIGH-PERFORMANCE INTERSECTION ENGINE (Blazing Fast) ---
    # Convert the binary state directly to integers
    binary_df <- as.data.frame(gap_data$missing_matrix + 0L)

    # 1. Generate a quick unique hash identifier for each row combination
    # This works like data.table grouping but uses 100% native Base R
    combo_factor <- do.call(
      interaction,
      c(gap_data$binary_df, drop = TRUE, sep = "-")
    )
    counts <- tabulate(combo_factor)
    unique_combos <- levels(combo_factor)

    # 3. Build a summary table from the non-zero matches
    valid_idx <- which(counts > 0)

    # Reconstruct the matrix layout rows cleanly
    raw_combos <- strsplit(unique_combos[valid_idx], "-")
    combo_matrix <- as.data.frame(do.call(
      rbind,
      lapply(raw_combos, as.integer)
    ))
    names(combo_matrix) <- pillars
    combo_matrix$count <- counts[valid_idx]

    # 4. Filter out rows that are completely clean (all 0s)
    non_zero_rows <- rowSums(combo_matrix[pillars]) > 0
    combo_counts <- combo_matrix[non_zero_rows, ]

    # 5. Sort and slice top 8 rows using standard dplyr
    combo_counts <- combo_counts |>
      dplyr::arrange(dplyr::desc(count)) |>
      dplyr::slice_head(n = 15)

    req(nrow(combo_counts) > 0)

    # Re-create the compressed string identity ONLY for the top 8 rows (trivial data scale)
    combo_counts$combo <- apply(combo_counts[pillars], 1, paste, collapse = "-")

    plot_data <- data.frame(
      combo = rep(combo_counts$combo, each = length(pillars)),
      Intersection = rep(
        paste0("Set ", 1:nrow(combo_counts)),
        each = length(pillars)
      ),
      Variable = rep(pillars, times = nrow(combo_counts)),
      Count = rep(combo_counts$count, each = length(pillars)),
      stringsAsFactors = FALSE
    )

    plot_data$Is_In_Set <- sapply(1:nrow(plot_data), function(i) {
      vec <- as.integer(strsplit(plot_data$combo[i], "-")[[1]])
      var_idx <- which(pillars == plot_data$Variable[i])
      return(vec[var_idx] == 1)
    })

    # --- STEP 4: GENERATE INTEGRATED PLOTLY CANVAS WITH DOMAINS ---

    set_labels <- paste0("Set ", seq_len(nrow(combo_counts)))

    plotly::plot_ly(type = "scatter", mode = "none") |>
      # 1. Top: vertical bars, one per missingness pattern
      plotly::add_trace(
        data = combo_counts,
        x = set_labels,
        y = ~count,
        type = "bar",
        marker = list(color = "#0A6EB4"),
        hovertemplate = "%{y:,} records<extra></extra>",
        showlegend = FALSE,
        xaxis = "x",
        yaxis = "y"
      ) |>
      # 2. Bottom-left: total missing per field, growing towards the matrix
      plotly::add_trace(
        data = set_sizes,
        x = ~Total_Missing,
        y = ~Variable,
        type = "bar",
        orientation = "h",
        marker = list(color = "#26bde2"),
        hovertemplate = "%{y}: %{x:,} missing<extra></extra>",
        showlegend = FALSE,
        xaxis = "x2",
        yaxis = "y2"
      ) |>
      # 3. Bottom-right: the combination matrix
      plotly::add_trace(
        data = plot_data,
        x = ~Intersection,
        y = ~Variable,
        type = "scatter",
        mode = "markers",
        marker = list(
          size = 10,
          color = ~ ifelse(Is_In_Set, "#0A6EB4", "rgba(128,128,128,0.22)"),
          line = list(width = 0)
        ),
        hoverinfo = "skip",
        showlegend = FALSE,
        xaxis = "x3",
        yaxis = "y3"
      ) |>
      # --- STEP 5: MANUALLY ASSIGN THE AXIS GRID POSITIONS ---
      # Four quadrants share one canvas. The left column (0 - 0.16) holds the
      # per-field bars, the right column (0.28 - 1) the pattern bars and matrix;
      # the 0.16-0.28 gutter is where the field names and the top axis ticks go,
      # so nothing overlaps. Colors/fonts come from wfp_plotly().
      plotly::layout(
        # Top-right: pattern bars
        xaxis = list(
          visible = FALSE,
          domain = c(0.28, 1),
          type = "category",
          categoryorder = "array",
          categoryarray = set_labels
        ),
        yaxis = list(
          title = NULL,
          domain = c(0.56, 1),
          gridcolor = "rgba(128,128,128,0.2)",
          zeroline = FALSE
        ),

        # Bottom-left: per-field totals (reversed so bars end next to the matrix)
        xaxis2 = list(
          title = list(text = "Missing per field", standoff = 8),
          autorange = "reversed",
          domain = c(0, 0.16),
          gridcolor = "rgba(128,128,128,0.2)",
          zeroline = FALSE,
          side = "bottom"
        ),
        yaxis2 = list(
          showgrid = FALSE,
          domain = c(0, 0.46),
          type = "category",
          categoryorder = "array",
          categoryarray = as.character(pillars)
        ),

        # Bottom-right: the matrix, locked to both neighbours
        xaxis3 = list(
          title = list(text = "Missingness patterns, most frequent first", standoff = 8),
          domain = c(0.28, 1),
          type = "category",
          showticklabels = FALSE,
          showgrid = FALSE,
          zeroline = FALSE,
          matches = "x"
        ),
        yaxis3 = list(
          visible = FALSE,
          domain = c(0, 0.46),
          type = "category",
          matches = "y2"
        ),
        margin = list(t = 10, b = 40, l = 130, r = 16)
      )
  })

  ## ------------------- Lolipop Graph of missings per location
  # ---------------------------------------------------------------------------------

  output$plot_geo_missing_bars <- render_wfp_plotly({
    # 1. Pull the pre-calculated data bundle from memory
    gap_data <- shared_gap_analysis()
    req(gap_data, applied_missing$geo_level)

    # 2. Map location via user_setup
    geo_key <- tolower(gsub(" ", "", applied_missing$geo_level))
    real_geo_col <- user_setup[[geo_key]]
    req(!is.null(real_geo_col), real_geo_col %in% names(gap_data$df))

    # 3. Fast aggregate using your plain character vectors.
    # D3: honour survey weights when a weight column is mapped (so the gap rate
    # reflects the weighted population, consistent with the enumerator module).
    geo_vector <- as.character(gap_data$df[[real_geo_col]])
    weights <- gap_data$weights

    geo_summary <- data.frame(
      Location = geo_vector,
      Is_Incomplete = gap_data$is_incomplete,
      w = weights,
      stringsAsFactors = FALSE
    ) |>
      dplyr::group_by(Location) |>
      dplyr::summarise(
        Total_Households = dplyr::n(),
        Gapped_Households = sum(.data$Is_Incomplete),
        Weighted_Total = sum(.data$w, na.rm = TRUE),
        Weighted_Gapped = sum(.data$w * .data$Is_Incomplete, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::mutate(
        # Use the weighted rate when weights vary; else the raw rate
        Incompleteness_Rate = round(
          ifelse(.data$Weighted_Total > 0,
                 (.data$Weighted_Gapped / .data$Weighted_Total) * 100,
                 (.data$Gapped_Households / .data$Total_Households) * 100),
          1
        ),
        Hover_Text = paste0(
          Location,
          "<br>",
          format(round(.data$Weighted_Gapped), big.mark = ","), " / ",
          format(round(.data$Weighted_Total), big.mark = ","),
          " weighted HHs affected"
        )
      ) |>
      dplyr::filter(.data$Gapped_Households > 0) |>
      dplyr::arrange(dplyr::desc(.data$Incompleteness_Rate)) |>
      dplyr::slice_head(n = 50)

    req(nrow(geo_summary) > 0)

    # 4. Render the Lollipop
    plotly::plot_ly(
      data = geo_summary,
      x = ~Incompleteness_Rate,
      y = ~ reorder(Location, Incompleteness_Rate),
      type = "scatter",
      mode = "markers",
      marker = list(
        color = "#cb4b16",
        size = 10,
        line = list(width = 1, color = "#cb4c165b")
      ),
      error_x = list(
        type = "data",
        array = geo_summary$Incompleteness_Rate,
        symmetric = FALSE,
        arrayminus = rep(0, nrow(geo_summary)),
        color = "rgba(128,128,128,0.35)",
        thickness = 1.5,
        width = 0
      ),
      hoverinfo = "text",
      hovertext = ~Hover_Text,
      height = 600
    ) |>
      plotly::layout(
        title = list(
          text = paste(
            "Data Gaps Analysis by",
            applied_missing$geo_level,
            " : Showing first 50 locations"
          ),
          font = list(color = "#0A6EB4", size = 12),
          x = 0.15, # Left-aligned with the chart elements
          y = 1
        ),
        paper_bgcolor = "rgba(0,0,0,0)",
        plot_bgcolor = "rgba(0,0,0,0)",
        xaxis = list(
          title = "% Households with Gaps",
          autorange = TRUE,
          range = c(0, 100),
          gridcolor = "rgba(128,128,128,0.2)",
          side = "bottom"
        ),
        yaxis = list(title = "", showgrid = FALSE, type = "category"),
        margin = list(t = 10, b = 40, l = 120, r = 10)
      )

  })
}
