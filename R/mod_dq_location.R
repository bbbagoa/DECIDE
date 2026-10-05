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
                plotly::plotlyOutput(ns("dq_location_treemap"), height = "600px"),
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

  output$location_hint <- renderUI({
    if (is.null(norm_level())) return(empty_state("Choose a level", "Pick the level to review, then click Show names.", icon = "signpost-split"))
    if (length(norm_cols()) == 0) {
      empty_state(
        "This level is not mapped",
        paste0(
          "No column is mapped to ", norm_level() %||% "this level",
          ". Map it in Setup, or pick a level your dataset provides."
        ),
        icon = "signpost-split"
      )
    }
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
  output$tab_location_norm <- DT::renderDT(
    {
      tw_datatable(
        norm_data_summary(),
        selection = "multiple",
        options = list(
          stateSave = TRUE, # KEY: Remembers search/filters in the browser
          pageLength = 100,
          language = list(search = "", searchPlaceholder = "Search, e.g. kivu"),
          scrollX = TRUE,
          scrollY = "500px",
          autoWidth = FALSE,
          columnDefs = list(list(className = 'dt-nowrap', targets = "_all")),
          dom = 'frtip'
        )
      )
    },
    server = TRUE
  )

  # 2. Batch Update Logic

  # Create a small storage for the pending batch
  current_norm_batch <- reactiveVal(NULL)

  ## ------------- Select every row matching the search box
  observeEvent(input$btn_select_shown, {
    shown <- input$tab_location_norm_rows_all
    if (!length(shown)) return()
    DT::selectRows(DT::dataTableProxy("tab_location_norm"), union(input$tab_location_norm_rows_selected, shown))
  })

  # What is selected, and a suggested correct spelling: the most common of
  # the selected names (only while the field is empty).
  output$norm_selection <- renderUI({
    rows <- input$tab_location_norm_rows_selected
    cols <- norm_cols()
    if (!length(rows) || !length(cols)) {
      return(tags$div(class = "wfp-norm-bar is-empty small text-muted",
                      bsicons::bs_icon("hand-index"), " Click the rows to merge, or search and use Select all shown."))
    }
    d <- norm_data_summary()
    rows <- rows[rows >= 1 & rows <= nrow(d)]
    col <- cols[length(cols)]
    nm <- as.character(d[[col]][rows]); n <- d$count[rows]
    agg <- tapply(n, nm, sum); agg <- sort(agg, decreasing = TRUE)
    tags$div(class = "wfp-norm-bar",
             tags$strong(sprintf("%d selected", length(agg))),
             lapply(names(agg), function(x) tags$span(class = "wfp-norm-chip", x, tags$em(agg[[x]]))))
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
    # 'tab_location_norm' should be the ID of your DT output
    proxy <- DT::dataTableProxy("tab_location_norm")

    # Passing NULL tells the table to clear all highlights
    DT::selectRows(proxy, NULL)

    # Optional: Show a quick notification at the top
    showNotification(
      "All selections cleared.",
      type = "message"
    )
  })

  ## ------------- Trigger the Merge and Show Modal for confirmation

  observeEvent(input$btn_apply_norm, {
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

  ## --------- Similarity Tree Map

  output$dq_location_treemap <- render_wfp_plotly({
    # 1. Get the hierarchical summary
    dat <- norm_data_summary()
    req(dat, nrow(dat) > 0)

    # 2. Identify columns (e.g., Admin 1, Admin 2, Admin 3)
    # Ensure we only use the columns that exist in the summary
    cols_present <- setdiff(names(dat), "count")
    n_levels <- length(cols_present)

    # 3. Initialize the lists for Plotly
    all_ids <- c()
    all_labels <- c()
    all_parents <- c()
    all_values <- c()

    # 4. Loop through each level to build the hierarchy
    for (i in 1:n_levels) {
      # Current level unique path (e.g., "Prov A - Dist B")
      ids <- apply(dat[, 1:i, drop = FALSE], 1, paste, collapse = " - ")

      # Label is just the name of the current item (e.g., "Dist B")
      labels <- as.character(dat[[cols_present[i]]])

      # Parent is the path of the level above
      if (i == 1) {
        parents <- rep("", nrow(dat)) # Root has no parent
      } else {
        parents <- apply(
          dat[, 1:(i - 1), drop = FALSE],
          1,
          paste,
          collapse = " - "
        )
      }

      all_ids <- c(all_ids, ids)
      all_labels <- c(all_labels, labels)
      all_parents <- c(all_parents, parents)
      all_values <- c(all_values, dat$count)
    }

    # 5. Remove Duplicate IDs (Crucial: multiple villages share the same Admin 1 parent)
    # We aggregate the values so parents get the sum of their children
    final_df <- data.frame(
      ids = all_ids,
      labels = all_labels,
      parents = all_parents,
      values = all_values,
      stringsAsFactors = FALSE
    ) |>
      dplyr::group_by(ids, labels, parents) |>
      dplyr::summarise(values = sum(values), .groups = "drop") |>
      dplyr::mutate(level = stringr::str_count(ids, " - "))

    # 6. Final Plot
    plotly::plot_ly(
      data = final_df,
      type = "treemap",
      ids = ~ids,
      labels = ~labels,
      parents = ~parents,
      values = ~values,
      # color = ~level,
      # colors = "Blues",
      branchvalues = "total",
      # Token blues rather than the stock "Mint" scale (see AGENTS.md > chart colors)
      marker = list(colorscale = list(c(0, "#cfe3f3"), c(1, "#0A6EB4"))),
      textinfo = "label+value"
    ) |>
      plotly::layout(
        autosize = TRUE,
        margin = list(t = 0, l = 0, r = 0, b = 0)
      )
  })
}
