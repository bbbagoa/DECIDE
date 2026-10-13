#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_location_ui <- function(ns) {
          bslib::nav_panel(
            title = "Location names normalization",
            icon = bsicons::bs_icon("spellcheck"),

            tags$div(
              id = ns("dq_individual_locations_section"),
              class = "p-3",
              p(
                "This Panel allows you to standardize location spelling across your dataset. 
                Select Locations Levels to Check"
              ),

              # Toolbar: level + new spelling on the left, actions on the right
              # (same flex pattern as the Spelling and Missing Data sub-tabs)
              tags$div(
                class = "d-flex flex-wrap align-items-end gap-3",
                tags$div(
                  style = "flex: 0 1 220px;",
                  shinyWidgets::pickerInput(
                    inputId = ns("norm_col"),
                    label = "Level to review:",
                    choices = c(
                      "Admin 1",
                      "Admin 2",
                      "Admin 3",
                      "Admin 4",
                      "Village"
                    ),
                    selected = "Admin 1",
                    multiple = FALSE,
                    width = "100%",
                    options = shinyWidgets::pickerOptions(
                      liveSearch = TRUE, # Let users type to find 'Admin 4' quickly
                      size = 10 # Limits the dropdown height
                    )
                  )
                ),
                tags$div(class = "pb-3", actionButton(ns("norm_show"), "Show names", icon = icon("list-ul"), class = "btn-primary")),
                tags$div(
                  style = "flex: 1 1 240px; max-width: 340px;",
                  tags$label(class = "control-label", `for` = ns("correct_name"), "Correct spelling:"),
                  shinyWidgets::textInputIcon(
                    inputId = ns("correct_name"),
                    label = NULL, # Label rendered above so the row aligns
                    placeholder = "New spelling...",
                    icon = icon("pen"),
                    width = "100%"
                  )
                ),
                tags$div(
                  class = "d-flex align-items-end gap-2 ms-auto pb-3",
                  actionButton(
                    ns("btn_apply_norm"),
                    "Apply to selected",
                    class = "btn-primary"
                  ),
                  actionButton(
                    ns("btn_select_shown"),
                    "Select all shown",
                    icon = icon("check-double"),
                    class = "btn-outline-secondary",
                    title = "Select every row matching the table search"
                  ),
                  actionButton(
                    ns("btn_clear_selection"),
                    "Deselect all",
                    icon = icon("eraser"),
                    class = "btn-outline-secondary"
                  ),
                  downloadButton(
                    ns("download_locations"),
                    "Export",
                    class = "btn-outline-secondary"
                  )
                )
              ),
              uiOutput(ns("location_hint")),
              uiOutput(ns("norm_selection")),
              # The Table showing frequencies

              bslib::layout_columns(
                DT::DTOutput(ns("tab_location_norm"), fill = FALSE),
                plotly::plotlyOutput(ns("dq_location_view"), height = "600px"),
                col_widths = c(6, 6)
              ),
            )
          )
}

#' Data Quality sub-tab server
#' Shares the parent module input/output/session/ns namespace.
#' @param input,output,session,ns parent module handles
#' @param core list with dq_filtered_data, uploaded_df, user_setup, modification_log
#' @import shiny
#' @noRd
dq_location_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  # only the mapped levels, each with its column
  observe({
    ch <- mapped_level_choices(reactiveValuesToList(user_setup))
    cur <- isolate(input$norm_col)
    shinyWidgets::updatePickerInput(session, "norm_col", choices = ch, selected = if (isTRUE(cur %in% ch)) cur else unname(ch[1]))
  })

  ## --------------- Administrative Spelling Corrections
  # ------------------------------------------------------------------------------------

  ### -------------------- Definition of the Reactive Table
  # Resolve the mapped column for every level up to the selected one. Levels the
  # user never mapped come back NULL from `user_setup`; dropping them here keeps
  # `all_of()` from erroring into the UI when someone picks e.g. Village on a
  # dataset that only maps Admin 1-2.
  # The level is summarised on Show names: picking it computes nothing.
  norm_level <- reactiveVal(NULL)
  observeEvent(input$norm_show, {
    req(input$norm_show > 0)   # a React button sends 0 at start
    need_ok(shiny::isTruthy(input$norm_col), "Choose the level to review.")
    norm_level(input$norm_col)
  })
  norm_cols <- reactive({
    req(norm_level())
    df <- dq_filtered_data()
    if (is.null(df)) return(character(0))

    all_levels <- c("admin1", "admin2", "admin3", "admin4", "village")
    selected_label <- tolower(gsub(" ", "", norm_level()))
    current_idx <- which(all_levels == selected_label)
    if (length(current_idx) == 0) return(character(0))

    resolve <- function(x) {
      v <- user_setup[[x]]
      if (is.null(v) || !nzchar(as.character(v)[1])) return(NA_character_)
      v <- as.character(v)[1]
      if (!v %in% names(df)) return(NA_character_)
      v
    }

    # The selected level must itself be mapped: if it is not, showing its parent
    # columns would silently retarget the batch rename at the parent level.
    if (is.na(resolve(selected_label))) return(character(0))

    cols <- vapply(all_levels[seq_len(current_idx)], resolve, character(1))
    unique(unname(cols[!is.na(cols)]))
  })

  # what to say before the names show (React, LocationTab.tsx)
  output$location_hint <- shinyreact::reactive_output({
    if (is.null(norm_level())) return(list(state = "none"))
    if (length(norm_cols()) == 0) return(list(state = "unmapped", level = norm_level()))
    NULL
  })

  norm_data_summary <- reactive({
    req(dq_filtered_data())
    real_cols <- norm_cols()
    req(length(real_cols) > 0)

    # Perform the heavy lifting once
    dq_filtered_data() |>
      dplyr::group_by(dplyr::across(dplyr::all_of(real_cols))) |>
      dplyr::summarise(count = dplyr::n(), .groups = "drop") |>
      dplyr::arrange(dplyr::desc(count))
  })

  # 1. Render the Summary Table
  # drawn by React (react/src/pages/dq/LocationTab.tsx)
  output$tab_location_norm <- render_react_table(norm_data_summary(), page_size = 100, selection = "multiple",
                                                 formats = list(count = "int"), labels = list(count = "Records"),
                                                 height = 560)

  # 2. Batch Update Logic

  # Create a small storage for the pending batch
  current_norm_batch <- reactiveVal(NULL)

  ## ------------- Select every row matching the search box
  observeEvent(input$btn_select_shown, {
    req(input$btn_select_shown > 0)
    shown <- input$tab_location_norm_rows_all
    if (!length(shown)) return()
    react_table_select("tab_location_norm", union(input$tab_location_norm_rows_selected, shown))
  })

  # What is selected, and a suggested correct spelling: the most common of
  # the selected names (only while the field is empty).
  # drawn by React (LocationTab.tsx): one chip per selected name, its records
  output$norm_selection <- shinyreact::reactive_output({
    rows <- input$tab_location_norm_rows_selected
    cols <- norm_cols()
    if (!length(rows) || !length(cols)) return(list())
    d <- norm_data_summary()
    rows <- rows[rows >= 1 & rows <= nrow(d)]
    col <- cols[length(cols)]
    nm <- as.character(d[[col]][rows]); n <- d$count[rows]
    agg <- tapply(n, nm, sum); agg <- sort(agg, decreasing = TRUE)
    lapply(names(agg), function(x) list(name = x, n = unname(agg[[x]])))
  })
  observeEvent(input$tab_location_norm_rows_selected, {
    if (nzchar(trimws(input$correct_name %||% ""))) return()
    d <- norm_data_summary(); cols <- norm_cols(); rows <- input$tab_location_norm_rows_selected
    rows <- rows[rows >= 1 & rows <= nrow(d)]
    if (!length(rows) || !length(cols)) return()
    col <- cols[length(cols)]
    agg <- tapply(d$count[rows], as.character(d[[col]][rows]), sum)
    updateTextInput(session, "correct_name", value = names(agg)[which.max(agg)])
  }, ignoreNULL = TRUE)

  ## ------------- Deselect

  observeEvent(input$btn_clear_selection, {
    req(input$btn_clear_selection > 0)
    react_table_select("tab_location_norm", NULL)

    # Optional: Show a quick notification at the top
    showNotification(
      "All selections cleared.",
      type = "message"
    )
  })

  ## ------------- Trigger the Merge and Show Modal for confirmation

  observeEvent(input$btn_apply_norm, {
    req(input$btn_apply_norm > 0)
    # 1. Identify what needs to be changed
    selected_rows <- input$tab_location_norm_rows_selected
    need_ok(length(selected_rows) > 0 && shiny::isTruthy(input$correct_name), "Select the names to merge and type the correct name first.")

    # 2. Check if anything is selected
    if (length(selected_rows) == 0) {
      showNotification(
        "No rows selected! Please click on the table rows first.",
        type = "warning"
      )
      return()
    }

    # Identify the target column (the most granular one selected). norm_cols()
    # already dropped unmapped levels, so the last entry is the one being edited.
    resolved <- norm_cols()
    if (length(resolved) == 0) {
      showNotification("This administrative level is not mapped to a column.", type = "error")
      return()
    }
    real_col <- resolved[length(resolved)]

    # Re-run the summary on filtered data to get the labels of selected rows
    summary_df <- norm_data_summary()
    selected_rows <- selected_rows[selected_rows >= 1 & selected_rows <= nrow(summary_df)]
    req(length(selected_rows) > 0)

    wrong_names <- unique(as.character(summary_df[[real_col]][selected_rows]))

    ## -------------- Show Modal for Confirmation

    # 2. Show the Warning Modal
    showModal(modalDialog(
      title = "Confirm Permanent Batch Merge",
      size = "m",
      status = "warning",
      tags$p("You are about to merge the following variations:"),
      tags$div(
        style = "padding: 10px; border-radius: 5px; max-height: 150px; overflow-y: auto;",
        tags$ul(lapply(wrong_names, tags$li))
      ),
      tags$p(
        style = "margin-top: 15px;",
        HTML(paste0("All will be renamed to: <b>", input$correct_name, "</b>"))
      ),
      tags$p(tags$i(
        "This action will affect the entire dataset and cannot be undone."
      )),
      textAreaInput(
        ns("reason_norm_merge"),
        "Reason (optional)",
        rows = 2,
        placeholder = "Optional: reason for this normalization"
      ),

      footer = tagList(
        modalButton("Cancel"),
        actionButton(
          ns("btn_confirm_norm_merge"),
          "Yes, Merge All",
          class = "btn-danger"
        )
      )
    ))
    # Store the list in a temporary reactive so the next step can see it
    current_norm_batch(list(names = wrong_names, col = real_col))
  })

  ### -----------------------  Confirm Merge !

  observeEvent(input$btn_confirm_norm_merge, {
    req(current_norm_batch(), input$correct_name)
    batch <- current_norm_batch()

    df_master <- uploaded_df()

    df_master[[batch$col]] <- as.character(df_master[[batch$col]])
    hit <- df_master[[batch$col]] %in% batch$names
    df_master[[batch$col]][hit] <- input$correct_name

    merge_reason <- input$reason_norm_merge %||% ""
    merge_reason <- if (shiny::isTruthy(merge_reason)) trimws(as.character(merge_reason)) else ""

    # 4. LOG THE ACTION
    new_log <- data.frame(
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      uid = "BATCH_NORM",
      column = batch$col,
      old_value = paste(batch$names, collapse = ", "),
      new_value = sprintf("%s (%d rows)", input$correct_name, sum(hit)),
      action = "Batch location normalization",
      user = session$user %||% "Admin",
      reason = merge_reason,
      stringsAsFactors = FALSE
    )
    modification_log(rbind(modification_log(), new_log))

    # 5. SYNC EVERYTHING
    uploaded_df(df_master)

    # UI updates automatically via reactive chain

    removeModal()

    showNotification(
      paste(
        "Updated",
        length(batch$names),
        "variations to",
        input$correct_name,
        "for variable",
        batch$col
      ),
      type = "message"
    )
  })

  ### ----------------- Download Locations Button Logic

  output$download_locations <- download_handler(
    filename = function() {
      export_file_name("Targeting_LocationsCheck", "xlsx", "%Y-%m-%d_%Hh%Mm%Ss")
    },
    content = function(file) {
      export_data <- sanitize_for_excel(norm_data_summary())
      req(nrow(export_data) > 0)

      # 1. Create a workbook object
      wb <- openxlsx::createWorkbook()
      openxlsx::addWorksheet(wb, "LocationCheck_Results")

      # 2. Define the header style (Cyan background, White bold text)
      header_style <- openxlsx::createStyle(
        fgFill = "#005f73",
        halign = "left",
        fontColour = "#FFFFFF",
        textDecoration = "bold",
        border = "Bottom"
      )

      # 3. Write the data
      write_data(wb, "LocationCheck_Results", export_data)

      # 4. Apply the style to the first row (the header)
      openxlsx::addStyle(
        wb,
        sheet = "LocationCheck_Results",
        style = header_style,
        rows = 1,
        cols = 1:ncol(export_data),
        gridExpand = TRUE
      )

      # 5. Optional: Auto-adjust column widths so it looks professional
      openxlsx::setColWidths(
        wb,
        "LocationCheck_Results",
        cols = 1:ncol(export_data),
        widths = "auto"
      )

      # 6. Save
      save_workbook_readonly(wb, file)
    }
  )

  ## --------- The names as a chart: similar names (network), the nesting
  ## (sunburst) or variant groups (bars); input$loc_view is a display toggle
  # the similarity rate redraws the chart as it changes (a display setting)
  loc_similarity <- debounce(reactive({
    x <- suppressWarnings(as.numeric(input$loc_similarity))
    if (!length(x) || is.na(x)) 80 else min(100, max(50, x))
  }), 400)
  loc_groups <- reactive({
    dat <- norm_data_summary(); cols <- norm_cols()
    req(dat, nrow(dat) > 0)
    loc_similar_groups(dat, cols[length(cols)], similarity = loc_similarity() / 100)
  })
  output$dq_location_view <- render_echart({
    view <- input$loc_view %||% "similar"
    if (identical(view, "sunburst")) {
      dat <- norm_data_summary(); req(dat, nrow(dat) > 0)
      return(loc_sunburst_option(dat))
    }
    g <- loc_groups()
    validate(need(nrow(g) > 0, "No look-alike names at this level."))
    if (identical(view, "bars")) loc_bars_option(g) else loc_network_option(g)
  }, height = 560)

  # a click on a name or a bar selects its whole group in the table and
  # suggests the most common spelling
  observeEvent(input$dq_location_view_click, {
    k <- suppressWarnings(as.integer(input$dq_location_view_click$data$group))
    if (!length(k) || is.na(k)) return()
    g <- loc_groups(); g <- g[g$group == k, , drop = FALSE]
    if (!nrow(g)) return()
    d <- norm_data_summary(); cols <- norm_cols()
    react_table_select("tab_location_norm", which(as.character(d[[cols[length(cols)]]]) %in% g$name))
    updateTextInput(session, "correct_name", value = g$label[1])
  })

  # the cross on a selected name's chip takes its rows out of the selection
  observeEvent(input$norm_unselect, {
    nm <- input$norm_unselect$name
    rows <- input$tab_location_norm_rows_selected
    if (is.null(nm) || !length(rows)) return()
    d <- norm_data_summary(); cols <- norm_cols()
    keep <- rows[rows >= 1 & rows <= nrow(d)]
    keep <- keep[as.character(d[[cols[length(cols)]]][keep]) != nm]
    react_table_select("tab_location_norm", if (length(keep)) keep else NULL)
    # the suggested spelling was the name taken out: suggest from the rest
    if (identical(trimws(input$correct_name %||% ""), trimws(nm))) {
      agg <- if (length(keep)) tapply(d$count[keep], as.character(d[[cols[length(cols)]]][keep]), sum)
      updateTextInput(session, "correct_name", value = if (length(agg)) names(agg)[which.max(agg)] else "")
    }
  })

  workspace_register(core$workspace, "dq_location",
    snapshot = function() {
      if (is.null(uploaded_df()) || is.null(input$loc_view)) return(NULL)
      list(view = input$loc_view, similarity = input$loc_similarity)
    },
    restore = function(s) after_flush(session, function() {
      updateRadioButtons(session, "loc_view", selected = s$view)
      if (length(s$similarity)) updateNumericInput(session, "loc_similarity", value = s$similarity)
    }))
}
