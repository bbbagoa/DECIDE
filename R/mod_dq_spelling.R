#' Spelling & Integrity sub-tab UI (Data Quality)
#'
#' @param ns namespace function from the parent module
#' @import shiny
#' @importFrom bslib nav_panel layout_columns
#' @noRd
dq_spelling_ui <- function(ns) {
  bslib::nav_panel(
    id = ns("spelling_panel"),
    title = "Spelling & Integrity",
    icon = bsicons::bs_icon("spellcheck"),

    # --- SECTION 1: INDIVIDUAL NAMES (Modal-based) ---
    tags$div(
      id = ns("dq_individual_names_section"),
      class = "p-3",

      # Toolbar: picker + metric on the left, actions grouped on the right
      tags$div(
        class = "d-flex flex-wrap align-items-end gap-3 mb-3",
        tags$div(
          style = "flex: 1 1 320px; max-width: 520px;",
          shinyWidgets::pickerInput(
            inputId = ns("dq_name_cols"),
            label = "Name columns to audit (head of household & alternates)",
            choices = NULL, # Populated dynamically from raw data
            multiple = TRUE,
            width = "100%",
            options = shinyWidgets::pickerOptions(
              actionsBox = TRUE,
              container = "body",
              size = 10, # rows shown before the list scrolls (a number, not a CSS height)
              virtualScroll = 600, # PERFORMANCE: Use for large numbers of variables
              liveSearch = TRUE,
              title = "Select all columns representing names..."
            )
          )
        ),
        tags$div(
          class = "pb-2",
          tags$div(class = "small text-muted text-uppercase", style = "letter-spacing: .05em;", "Invalid records"),
          tags$div(class = "fs-5 fw-semibold", uiOutput(ns("dq_names_metric"), inline = TRUE))
        ),
        tags$div(
          class = "d-flex gap-2 ms-auto pb-2",
          actionButton(ns("btn_open_edit"), "Edit selected", class = "btn-primary", icon = icon("edit")),
          actionButton(ns("btn_delete_all_missing"), "Delete rows with missing names",
                       class = "btn-outline-danger", icon = icon("trash")),
          downloadButton(ns("download_audit"), "Export", class = "btn-outline-secondary")
        )
      ),
      DT::DTOutput(ns("dq_names_redflags"), fill = FALSE)
    )
  )
}

#' Spelling & Integrity sub-tab (Data Quality)
#'
#' Extracted from mod_dq.R. Shares the parent module's input/output/session/ns
#' namespace, so every input$/output$ id is unchanged. Shared reactive state is
#' received via `core` and aliased locally so the body reads identically to the
#' original.
#'
#' @param input,output,session,ns parent module's Shiny handles
#' @param core list with dq_filtered_data, uploaded_df, user_setup,
#'   modification_log (reactive handles)
#' @import shiny
#' @noRd
dq_spelling_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  #  ------------------- Checking Names with Red flags
  ## -----------------------------------------------------------------------------------

  # 1. Define the reactive filter for 1GB data
  bad_data_reactive <- reactive({
    req(dq_filtered_data(), input$dq_name_cols, user_setup$unique_id)

    # Perform the high-performance scan
    find_bad_names(dq_filtered_data(), input$dq_name_cols)
  })

  # 1. Update choices based on uploaded data
  observeEvent(
    dq_filtered_data(),
    {
      # Text-like columns: .sav/.dta imports hold their names as factors.
      char_logic <- vapply(dq_filtered_data(), function(x) is.character(x) || is.factor(x), logical(1))
      all_char_cols <- names(dq_filtered_data())[char_logic]

      shinyWidgets::updatePickerInput(
        session,
        "dq_name_cols",
        choices = all_char_cols,
        selected = input$dq_name_cols %||% NULL
      )
    }
    # No ignoreInit: when the data was already loaded (a restored session),
    # skipping the first run left the list empty until the data next changed.
  )

  # 2. Reactive table for "Bad Names"
  output$dq_names_redflags <- DT::renderDT(
    {
      req(bad_data_reactive(), input$dq_name_cols)

      cols <- isolate(input$dq_name_cols)

      df <- isolate(find_bad_names(dq_filtered_data(), cols))
      req(nrow(df) > 0)

      # cols <- isolate(input$dq_name_cols)
      # df <- isolate(bad_data_reactive())
      # req(df)

      # Efficiently filter rows where ANY selected column has a "bad name"
      # We use a 1,000 row limit for the UI, but the scan happens on the 1GB file
      # Lets call the function find_bad_names
      bad_rows <- df |>
        dplyr::select(
          user_setup$unique_id,
          # user_setup$admin1,
          # user_setup$admin2,
          user_setup$admin3,
          user_setup$admin4,
          user_setup$village,
          user_setup$hhh_sex,
          cols
        )

      bad_rows <- isolate(bad_rows)
      req(nrow(bad_rows) > 0) ## Continue while there is still data

      DT::datatable(
        bad_rows,
        # escape = FALSE, # Required to render the HTML button
        rownames = FALSE,
        selection = "single", # ALLOWS SELECTING ONE ROW
        # extensions = 'Buttons',
        filter = "none",
        options = list(
          stateSave = TRUE, # KEY: Remembers search/filters in the browser
          pageLength = 50,
          scrollX = TRUE,
          scrollY = "400px",
          autoWidth = FALSE,
          columnDefs = list(list(className = 'dt-nowrap', targets = "_all")),
          dom = 'frtip'
        )
      ) |>
        DT::formatStyle(0, target = 'row', lineHeight = '50%')
    },
    server = TRUE
  )

  ## ------ Metric for % of bad names

  output$dq_names_metric <- renderUI({
    req(dq_filtered_data(), input$dq_name_cols)

    # Use the same logic we used for the table filter
    total_records <- nrow(dq_filtered_data())

    # Count rows where ANY selected column has a bad name
    # For 1GB, we count first to avoid pulling the whole dataframe
    bad_count <- bad_data_reactive() |>
      nrow()

    bad_pct <- round((bad_count / total_records) * 100, 1)

    HTML(paste0(
      "<span style='color:#0A6EB4; font-weight:bold;'>",
      format(bad_count, big.mark = ","),
      "</span> ",
      "(<span style='color:#c5192d;'>",
      bad_pct,
      "%</span> of selected)"
    ))
  })

  ### ----------------- Download Button Logic

  output$download_audit <- downloadHandler(
    filename = function() {
      paste0(
        "Targeting_NamesCheck_",
        format(Sys.time(), "%Y-%m-%d_%Hh%Mm%Ss"),
        ".xlsx"
      )
    },
    content = function(file) {
      export_data <- sanitize_for_excel(bad_data_reactive())
      req(nrow(export_data) > 0)

      # 1. Create a workbook object
      wb <- openxlsx::createWorkbook()
      openxlsx::addWorksheet(wb, "NamesCheck_Results")

      # 2. Define the header style (Cyan background, White bold text)
      header_style <- openxlsx::createStyle(
        fgFill = "#005f73",
        halign = "left",
        fontColour = "#FFFFFF",
        textDecoration = "bold",
        border = "Bottom"
      )

      # 3. Write the data
      write_data(wb, "NamesCheck_Results", export_data)

      # 4. Apply the style to the first row (the header)
      openxlsx::addStyle(
        wb,
        sheet = "NamesCheck_Results",
        style = header_style,
        rows = 1,
        cols = 1:ncol(export_data),
        gridExpand = TRUE
      )

      # 5. Optional: Auto-adjust column widths so it looks professional
      openxlsx::setColWidths(
        wb,
        "NamesCheck_Results",
        cols = 1:ncol(export_data),
        widths = "auto"
      )

      # 6. Save
      openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
    }
  )

  # 2. The Logic to Open the Modal based on Selection
  # -------------------------------------------------------------

  observeEvent(input$btn_open_edit, {
    selected_idx <- input$dq_names_redflags_rows_selected
    req(selected_idx)

    if (is.null(selected_idx)) {
      showNotification(
        "Please select a record in the table first.",
        type = "warning"
      )
      return()
    }

    # Fetch the specific record from your reactive audit data
    record <- bad_data_reactive()[selected_idx, user_setup$unique_id]

    full_record <- dq_filtered_data() |>
      dplyr::filter(
        .data[[user_setup$unique_id]] == record[[user_setup$unique_id]]
      )

    showModal(modalDialog(
      title = paste("Household Review: ", record[[user_setup$unique_id]]),
      size = "xl",
      easyClose = FALSE,

      # --- MODAL BODY ---
      fluidRow(
        # LEFT: CONTEXTUAL INFO
        column(
          4,
          bslib::card(
            height = "100%",
            bslib::card_header("Location Context"),
            tags$div(
              style = "font-size: 12px;",
              tags$p(tags$b("Admin 1: "), full_record[[user_setup$admin1]]),
              tags$p(tags$b("Admin 2: "), full_record[[user_setup$admin2]]),
              tags$p(tags$b("Admin 3: "), full_record[[user_setup$admin3]]),
              tags$p(tags$b("Admin 4: "), full_record[[user_setup$admin4]]),
              tags$p(tags$b("Community: "), full_record[[user_setup$village]]),
              tags$p(
                tags$b("HH Head Sex: "),
                full_record[[user_setup$hhh_sex]]
              ),
              tags$p(
                tags$b("HH Head Age: "),
                full_record[[user_setup$hhh_age]]
              ),
              tags$p(tags$b("HH Size: "), full_record[[user_setup$hh_size]]),
              tags$p(tags$b("Residency: "), full_record[[user_setup$residency]])
            ),
            hr(),
            # Vulnerability Status Boxes
            tags$h6("Vulenrability and Eligibility"),
            tags$div(
              style = "font-size: 12px;",
              tags$p(
                tags$b("Vulnerability Score: "),
                full_record[[user_setup$v_score]]
              ),
              tags$p(
                tags$b("Vulnerability Group : "),
                full_record[[user_setup$v_groups]]
              ),
              tags$p(
                tags$b("Eligibility : "),
                full_record[[user_setup$eligibility]]
              )
            )
          )
        ),

        # RIGHT: EDITABLE FIELDS
        column(
          8,
          bslib::card(
            bslib::card_header("Edit values"),
            # Automatically generate inputs for all columns currently being audited
            lapply(input$dq_name_cols, function(col) {
              textInput(
                # MUST be namespaced: without ns() the input is created outside
                # the module, input[["edit_<col>"]] below reads NULL, and the
                # save handler writes "" over the value it was meant to correct.
                ns(paste0("edit_", col)),
                paste("Correct", col, ":", full_record[[col]]),
                # full_record, NOT record: `record` is a one-COLUMN slice (just
                # the unique id), so record[[col]] is NULL and every box opened
                # empty. With namespaced inputs now actually wired up, saving
                # would then blank every field the user didn't retype.
                value = full_record[[col]],
                placeholder = full_record[[col]]
              )
            }),
            textAreaInput(
              ns("reason_edit_record"),
              "Reason (optional)",
              rows = 2,
              placeholder = "Optional: reason for this edit"
            )
          )
        )
      ),

      # --- FOOTER WITH CRUD ACTIONS ---
      footer = tagList(
        # DELETE ACTION (Red)
        actionButton(
          ns("btn_delete_rec"),
          "Delete Record",
          class = "btn-danger",
          icon = icon("trash"),
          style = "float: left;"
        ),

        modalButton("Cancel"),

        # SAVE ACTION (Green)
        actionButton(
          ns("btn_save_dq"),
          "Save Changes",
          class = "btn-success",
          icon = icon("save")
        )
      )
    ))
  })

  ## --------------------   Delete Confirmation !
  # ------------------------------------------------------------------

  ## --- Modal for delete Confirmation

  observeEvent(input$btn_delete_rec, {
    showModal(modalDialog(
      title = "Confirm Deletion",
      "Are you sure you want to remove this household from the dataset? This action will be logged.",
      textAreaInput(
        ns("reason_delete_rec"),
        "Reason / Justification",
        rows = 3,
        placeholder = "Required: explain why this record is being removed"
      ),
      footer = tagList(
        modalButton("No, Cancel"),
        actionButton(
          ns("btn_confirm_delete"),
          "Yes, Delete Permanently",
          class = "btn-danger"
        )
      )
    ))
  })

  ## ---- Delete and log the action

  observeEvent(input$btn_confirm_delete, {
    reason <- input$reason_delete_rec
    if (!shiny::isTruthy(reason) || trimws(reason) == "") {
      showNotification(
        "Give a reason for the change first.",
        type = "error"
      )
      return()
    }

    df <- isolate(uploaded_df())
    selected_idx <- isolate(input$dq_names_redflags_rows_selected)
    record <- isolate(bad_data_reactive()[selected_idx, user_setup$unique_id])

    # 1. Log the deletion
    new_log <- data.frame(
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      uid = as.character(record[[user_setup$unique_id]]),
      column = "ALL_RECORD",
      old_value = "ACTIVE",
      new_value = "DELETED",
      action = "Delete record",
      user = session$user %||% "Admin",
      reason = trimws(reason),
      stringsAsFactors = FALSE
    )
    modification_log(rbind(modification_log(), new_log))

    # 2. Filter out the deleted row from the 1GB file
    df_new <- df |>
      dplyr::filter(
        .data[[user_setup$unique_id]] != record[[user_setup$unique_id]]
      )

    uploaded_df(df_new)

    # Reactive refresh will handle the UI update automatically

    removeModal() # Close confirmation
    showNotification("Record deleted and logged.", type = "warning")
  })

  ## ---------------------------- Bulk Delete empty rows

  # Reactive to hold IDs between the bulk-delete modal steps
  ids_for_purge <- reactiveVal(NULL)

  observeEvent(input$btn_delete_all_missing, {
    # 1. Get current state
    df <- isolate(uploaded_df())
    filtered_df <- isolate(dq_filtered_data())
    target_cols <- isolate(input$dq_name_cols)
    id_col <- user_setup$unique_id

    req(df, target_cols, id_col)

    # 2. Identify rows where ALL selected columns are empty/NA
    # We use rowSums to check if the 'Empty condition' is true for the whole row
    is_totally_empty <- rowSums(sapply(filtered_df[target_cols], function(x) {
      is.na(x) |
        nchar(as.character(x)) < 2 |
        tolower(as.character(x)) %in% c("none", "null", "n/a", "")
    })) ==
      length(target_cols)

    ids_to_remove <- filtered_df[[id_col]][is_totally_empty]
    count_to_remove <- length(ids_to_remove)

    if (count_to_remove == 0) {
      showNotification(
        "No records found with all selected columns empty.",
        type = "message"
      )
      return()
    }

    # Store IDs in a temporary reactive to use in the confirmation step
    ids_for_purge(ids_to_remove)

    # 3. Confirmation Modal with required reason
    showModal(modalDialog(
      title = "Empty Names Bulk Deletion",
      tags$p(paste(
        "Found",
        count_to_remove,
        "records where ALL selected columns are empty."
      )),
      tags$p("Records with at least one valid name will be kept."),
      textAreaInput(
        ns("reason_bulk_delete"),
        "Reason / Justification",
        rows = 3,
        placeholder = "Required: explain why these records are being removed"
      ),
      footer = tagList(
        modalButton("Cancel"),
        actionButton(
          ns("btn_confirm_surgical_bulk"),
          "Yes, Remove Empty Rows",
          class = "btn-danger"
        )
      )
    ))
  })

  observeEvent(input$btn_confirm_surgical_bulk, {
    req(ids_for_purge())

    reason <- input$reason_bulk_delete
    if (!shiny::isTruthy(reason) || trimws(reason) == "") {
      showNotification(
        "Give a reason for the change first.",
        type = "error"
      )
      return()
    }

    df <- isolate(uploaded_df())
    id_col <- user_setup$unique_id

    # Remove only the targeted IDs
    df_new <- df[!df[[id_col]] %in% ids_for_purge(), ]

    # Update Master
    n_purged <- length(ids_for_purge())

    # Update Master
    uploaded_df(df_new)

    # Log the purge
    # One row per deleted record, so each can be traced (and kept out of a
    # later MODA sync).
    new_log <- data.frame(
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      uid = as.character(ids_for_purge()),
      column = "ALL_RECORD",
      old_value = "Row existed",
      new_value = "DELETED",
      action = "Bulk delete empty names",
      user = session$user %||% "Admin",
      reason = trimws(reason),
      stringsAsFactors = FALSE
    )
    modification_log(rbind(modification_log(), new_log))
    removeModal()
    ids_for_purge(NULL)
    showNotification(
      paste("Removed", n_purged, "empty records."),
      type = "warning"
    )
  })

  ## ----------------- Edit Selected HH
  # -----------------------------------------------------------------------

  observeEvent(input$btn_save_dq, {
    # 1. Access the master data and setup info

    # print("Save button detected!") # Debugging line

    df <- isolate(uploaded_df())
    id_col <- isolate(user_setup$unique_id)

    # 2. Identify the specific record using the selected row from the audit
    # table. Pull the COLUMN first: the red-flag table is a tibble (haven
    # imports are tibbles, and dplyr::filter keeps them that way), so
    # `tbl[i, j]` returns a 1x1 tibble rather than a scalar. That made the
    # `df[[id_col]] == target_id` match below find nothing, so the save
    # aborted at the `length(match_idx) == 0` guard without any message.
    selected_idx <- input$dq_names_redflags_rows_selected
    target_id <- as.character(bad_data_reactive()[[id_col]][selected_idx])

    # 1. Safety Gate: Ensure a row is actually selected
    req(selected_idx, target_id)

    if (length(target_id) == 0 || is.na(target_id)) {
      showNotification(
        "Error: Selection lost. Please re-select the row.",
        type = "error"
      )
      return()
    }

    # 3. Locate the row once
    match_idx <- which(df[[id_col]] == target_id)
    if (length(match_idx) == 0) {
      return()
    } # Record gone or ID changed

    edit_reason <- input$reason_edit_record %||% ""
    edit_reason <- if (shiny::isTruthy(edit_reason)) trimws(as.character(edit_reason)) else ""

    # 3. Process each audited column
    for (col in input$dq_name_cols) {
      # Get values and ensure they are at least length 1 strings
      new_val <- as.character(input[[paste0("edit_", col)]] %||% "")
      old_val <- as.character(df[match_idx, col] %||% "")

      # 4. Only act if the user actually changed the text
      if (!identical(as.character(new_val), as.character(old_val))) {
        # LOG THE CHANGE
        new_log_entry <- data.frame(
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          uid = as.character(target_id),
          column = col,
          old_value = if (is.na(old_val)) "EMPTY" else as.character(old_val),
          new_value = if (is.na(new_val)) "EMPTY" else as.character(new_val),
          action = "Edit record",
          user = session$user %||% "Admin",
          reason = edit_reason,
          stringsAsFactors = FALSE
        )

        # UPDATE THE MASTER DATA in memory
        df[df[[id_col]] == target_id, col] <- new_val
        # Update the reactive log
        modification_log(rbind(modification_log(), new_log_entry))
      }
    }

    # 5. TRIGGER GLOBAL REFRESH
    uploaded_df(df)

    # 6. UI Cleanup
    removeModal()
    showNotification("Record updated and change logged.", type = "message")
  })
}
