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
                    class = "btn-outline-primary",
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

  # only the mapped levels, each with its column
  observe({
    ch <- mapped_level_choices(reactiveValuesToList(user_setup))
    cur <- isolate(input$missing_geo_level)
    shinyWidgets::updatePickerInput(session, "missing_geo_level", choices = ch, selected = if (isTRUE(cur %in% ch)) cur else unname(ch[1]))
  })

  has_missing_analysis <- reactive(!is.null(applied_missing$vars) && length(applied_missing$vars) > 0)

  # Headline numbers first, then one view per question: which fields,
  # which combinations, where.
  # Whether a check has run: the React page shows the results layout then
  # (react/src/pages/dq/MissingTab.tsx).
  output$missing_results <- shinyreact::reactive_output(isTRUE(has_missing_analysis()))

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

  output$missing_kpis <- shinyreact::reactive_output({
    h <- field_health()
    g <- tryCatch(shared_gap_analysis(), error = function(e) NULL)
    n <- nrow(dq_filtered_data())
    gap_n <- if (is.null(g)) sum(rowSums(vapply(h$field, function(v) {
      x <- dq_filtered_data()[[v]]; is.na(x) | as.character(x) %in% c("", "NULL")
    }, logical(n))) > 0) else sum(g$is_incomplete)
    worst <- h[which.min(h$completeness), , drop = FALSE]
    list(
      list(label = "Complete records", value = if (n) sprintf("%.1f%%", 100 * (1 - gap_n / n)) else "—",
           sub = sprintf("of %s records", format(n, big.mark = ",")), tone = "ok"),
      list(label = "Records with a gap", value = format(gap_n, big.mark = ","), sub = "at least one checked field empty", tone = "warn"),
      list(label = "Fields below 95%", value = sprintf("%d of %d", sum(h$completeness < 95, na.rm = TRUE), nrow(h)),
           sub = "completeness under the OK band", tone = "info"),
      list(label = "Least complete field", value = if (nrow(worst)) sprintf("%.1f%%", worst$completeness) else "—",
           sub = if (nrow(worst)) worst$field else "", tone = "bad"))
  })

  output$plot_field_completeness <- render_echart({
    h <- field_health(); req(nrow(h) > 0)
    h <- h[order(h$completeness), , drop = FALSE]
    band_col <- c(OK = "#3f7e44", Review = "#d08a00", `At risk` = "#c5192d")
    dq_hbar(h$field, h$completeness, color = unname(band_col[h$status]),
            tips = sprintf("<b>%s</b><br>%.1f%% complete<br>%s empty cells", htmltools::htmlEscape(h$field), h$completeness,
                           format(h$missing, big.mark = ",")),
            x_name = "Completeness (%)", x_min = 0, x_max = 100, bar_labels = "fn:dec1",
            lines = list(list(x = 95, label = "95%", color = "#5b6b7c")))
  })

  #### --------------------- Missing Data Panel
  ## ----------------------------------------------------------------------------------

  #  Part A: Column Health Summary
  #  This calculates how many NA or empty values exist
  # in every column of your filtered dataset.

  output$tab_col_health <- render_react_table({
    req(dq_filtered_data(), applied_missing$vars)
    df <- dq_filtered_data() # Initial filtered data
    total_n <- nrow(df) # Total Rows in the dataset
    target_cols <- applied_missing$vars # Selected by User
    missing_counts <- sapply(df[target_cols], function(x) {
      sum(is.na(x) | as.character(x) == "" | as.character(x) == "NULL")
    })

    # Fast vectorized missingness check
    data.frame(
      Variable = target_cols,
      Missing_Count = as.numeric(unname(missing_counts)),
      stringsAsFactors = FALSE
    ) |>
      dplyr::mutate(
        # total_n is 0 when the filters leave no rows (no NaN%)
        Completeness = if (total_n > 0) round((1 - (Missing_Count / total_n)) * 100, 1) else NA_real_,
        # status bands: >=95% OK (green), 90-95% Review (amber), <90% At risk (red)
        Status = dplyr::case_when(
          is.na(Completeness)        ~ "Review",
          Completeness >= 95         ~ "OK",
          Completeness >= 90         ~ "Review",
          TRUE                       ~ "At risk"
        )
      ) |>
      dplyr::arrange(dplyr::desc(Missing_Count))
  }, page_size = 20,
  labels = list(Missing_Count = "Empty cells", Completeness = "Completeness (%)"),
  formats = list(Missing_Count = "int", Completeness = "dec1"),
  # pale bands with dark text pinned (they stay pale in dark mode)
  styles = list(
    Completeness = list(breaks = c(90, 95), colors = c("#f8d7da", "#fff3cd", "#d4edda"), text = c("#842029", "#664d03", "#0f5132")),
    Status = list(map = list(OK = list(bg = "#d4edda", color = "#0f5132"), Review = list(bg = "#fff3cd", color = "#664d03"),
                             `At risk` = list(bg = "#f8d7da", color = "#842029")))))

  # Part B: The "Incomplete"
  # Household ListThis reactive finds the rows where any of
  # the selected "Mandatory Pillars" are missing.

  # Apply missing-data analysis selections
  observeEvent(input$btn_apply_missing, {
    req(input$btn_apply_missing > 0)   # a React button sends 0 at start
    waiter::waiter_show(
      html = waiter_content("Analysing missing data\u2026"),
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

  output$plot_missing_qualitative <- render_echart({
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
    req(!is.null(real_geo_col))
    qual_vars <- setdiff(qual_vars, real_geo_col)
    validate(need(length(qual_vars) > 0, "No categorical field among the fields checked."))

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

    validate(need(nrow(geo_stats) > 0, "No gaps in these fields."))

    # locations by fields, the share of gaps in each cell
    dq_missing_heat(geo_stats, "perc_missing", "% of answers empty", "%")
  })

  ### ---------------- Quantiytative plot

  output$plot_missing_quantitative <- render_echart({
    req(dq_filtered_data(), applied_missing$vars, applied_missing$geo_level)
    df <- dq_filtered_data()

    # 1. Identify which selected variables are Quantitative (Numeric/Integer/Double)
    selected_vars <- applied_missing$vars
    is_quant <- sapply(df[selected_vars], is.numeric)
    quant_vars <- selected_vars[is_quant]

    geo_key <- tolower(gsub(" ", "", applied_missing$geo_level))
    real_geo_col <- user_setup[[geo_key]]

    # Safety Check: If no numeric variables are chosen, exit gracefully
    req(!is.null(real_geo_col))
    validate(need(length(quant_vars) > 0, "No numeric field among the fields checked."))

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

    validate(need(nrow(geo_stats) > 0, "No gaps in these fields."))

    # locations by fields, the number of empty answers in each cell
    dq_missing_heat(geo_stats, "missing_n", "empty answers", " empty")
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

  output$plot_missing_upset <- render_echart({
    validate(need(length(applied_missing$vars) >= 2, "Check at least two fields to see which go missing together."))
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

    validate(need(nrow(combo_counts) > 0, "No record misses any of these fields."))
    dq_upset_option(combo_counts, pillars, set_sizes)
  })

  ## ------------------- Lolipop Graph of missings per location
  # ---------------------------------------------------------------------------------

  output$plot_geo_missing_bars <- render_echart({
    validate(need(length(applied_missing$vars) >= 2, "Check at least two fields to compare the locations."))
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

    validate(need(nrow(geo_summary) > 0, "No location has a gap."))

    # 4. The gap rate by location, highest first
    dq_hbar(geo_summary$Location, geo_summary$Incompleteness_Rate, color = "#c5192d",
            tips = sprintf("<b>%s</b><br>%.1f%% of households with a gap<br>%s / %s households", htmltools::htmlEscape(geo_summary$Location),
                           geo_summary$Incompleteness_Rate, format(round(geo_summary$Weighted_Gapped), big.mark = ","),
                           format(round(geo_summary$Weighted_Total), big.mark = ",")),
            x_name = "% households with gaps", x_min = 0, x_max = 100, bar_labels = "fn:dec1")
  })
}

#' Locations by fields: the gaps of each field in each location, as a heatmap
#' (the 40 locations with the most gaps)
#' @param st data.frame(Location, Variable, <value>).
#' @noRd
dq_missing_heat <- function(st, value, name, suffix) {
  loc <- tapply(st[[value]], st$Location, sum)
  loc <- names(sort(loc, decreasing = TRUE))[seq_len(min(40, length(loc)))]
  vars <- sort(unique(st$Variable))
  z <- matrix(0, length(loc), length(vars))
  hit <- st$Location %in% loc
  z[cbind(match(st$Location[hit], loc), match(st$Variable[hit], vars))] <- st[[value]][hit]
  dq_heatmap(vars, loc, z, name = name, tip_suffix = suffix, label_fmt = "fn:hmap")
}

#' Which fields go missing together (an UpSet chart): bars of the most frequent
#' patterns on top, the fields' totals bottom left, the patterns' matrix bottom
#' right
#' @param combos One row per pattern: a 0/1 column per field, `count`.
#' @param pillars The fields, in order. @param sizes data.frame(Variable, Total_Missing).
#' @noRd
dq_upset_option <- function(combos, pillars, sizes) {
  sets <- paste0("Set ", seq_len(nrow(combos)))
  esc <- function(x) htmltools::htmlEscape(as.character(x))
  members <- vapply(seq_len(nrow(combos)), function(i) paste(esc(pillars[unlist(combos[i, pillars]) == 1]), collapse = ", "), "")
  dots <- list()
  for (i in seq_along(sets)) for (j in seq_along(pillars)) {
    on <- combos[[pillars[j]]][i] == 1
    dots[[length(dots) + 1]] <- list(value = list(i - 1, j - 1), symbolSize = if (on) 11 else 7,
                                     itemStyle = list(color = if (on) "#007DBC" else "rgba(128,128,128,0.25)"),
                                     tip = sprintf("<b>%s</b>: %s", sets[i], members[i]))
  }
  # the lines joining the fields of a pattern
  links <- lapply(seq_along(sets), function(i) {
    on <- which(unlist(combos[i, pillars]) == 1) - 1
    if (length(on) < 2) return(NULL)
    list(list(coord = list(i - 1, min(on))), list(coord = list(i - 1, max(on))))
  })
  links <- Filter(Negate(is.null), links)
  dot_series <- list(type = "scatter", xAxisIndex = 2, yAxisIndex = 2, data = dots, z = 3)
  if (length(links)) dot_series$markLine <- list(silent = TRUE, symbol = "none", label = list(show = FALSE),
                                                 lineStyle = list(color = "#007DBC", width = 2, type = "solid"), data = links)
  o <- list(
    tooltip = list(trigger = "item", formatter = "fn:tip"),
    grid = list(
      list(left = "30%", right = 16, top = 12, height = "46%"),
      list(left = 16, width = "14%", top = "62%", bottom = 36),
      list(left = "30%", right = 16, top = "62%", bottom = 36)),
    xAxis = list(
      list(gridIndex = 0, type = "category", data = I(sets), axisLabel = list(show = FALSE), axisTick = list(show = FALSE)),
      list(gridIndex = 1, type = "value", inverse = TRUE, name = "Missing per field", nameLocation = "middle", nameGap = 22,
           axisLabel = list(fontSize = 9, hideOverlap = TRUE)),
      list(gridIndex = 2, type = "category", data = I(sets), name = "Missingness patterns, most frequent first",
           nameLocation = "middle", nameGap = 22, axisLabel = list(show = FALSE), axisTick = list(show = FALSE),
           axisLine = list(show = FALSE))),
    yAxis = list(
      list(gridIndex = 0, type = "value", name = "Records", axisLabel = list(formatter = "fn:num")),
      list(gridIndex = 1, type = "category", data = I(pillars), inverse = TRUE, position = "right",
           axisLabel = list(interval = 0, margin = 10, width = 130, overflow = "truncate"), axisTick = list(show = FALSE)),
      list(gridIndex = 2, type = "category", data = I(pillars), inverse = TRUE, axisLabel = list(show = FALSE),
           axisTick = list(show = FALSE), axisLine = list(show = FALSE), splitLine = list(show = TRUE))),
    series = list(
      list(type = "bar", xAxisIndex = 0, yAxisIndex = 0, barMaxWidth = 28, itemStyle = list(color = "#007DBC"),
           label = list(show = TRUE, position = "top", fontSize = 10, formatter = "fn:num", color = "#8a96a3", textBorderWidth = 0),
           data = lapply(seq_along(sets), function(i) list(value = combos$count[i],
             tip = sprintf("<b>%s</b>: %s records<br>%s", sets[i], format(combos$count[i], big.mark = ","), members[i])))),
      list(type = "bar", xAxisIndex = 1, yAxisIndex = 1, barMaxWidth = 14, itemStyle = list(color = "#26bde2"),
           data = lapply(seq_along(pillars), function(j) {
             v <- sizes$Total_Missing[match(pillars[j], sizes$Variable)]
             list(value = v, tip = sprintf("<b>%s</b>: %s missing", esc(pillars[j]), format(v, big.mark = ",")))
           })),
      dot_series))
  attr(o, "height") <- max(420, 200 + 30 * length(pillars))
  o
}
