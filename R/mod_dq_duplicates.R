#' Data Quality sub-tab UI
#' @param ns namespace function from the parent module
#' @import shiny
#' @noRd
dq_duplicates_ui <- function(ns) {
  bslib::nav_panel(
    title = "Duplicates",
    icon = bsicons::bs_icon("copy"),
    tags$div(
      class = "p-3",
      tags$div(
        class = "d-flex flex-wrap align-items-end gap-3 wfp-dq-toolbar",
        tags$div(style = "flex: 1 1 320px; max-width: 520px;",
          shinyWidgets::pickerInput(
            inputId = ns("duplicate_vars"), label = "Columns that identify a household", width = "100%",
            choices = NULL, multiple = TRUE,
            options = shinyWidgets::pickerOptions(actionsBox = TRUE, liveSearch = TRUE, container = "body",
                                                  selectedTextFormat = "count > 3"))),
        tags$div(class = "pb-3",
          shinyWidgets::awesomeCheckbox(inputId = ns("duplicate_fuzzy"), label = "Fuzzy matching", value = FALSE)),
        tags$div(style = "flex: 0 1 200px;",
          sliderInput(ns("duplicate_fuzzy_dist"), "Max string distance", min = 0, max = 5, value = 1, step = 1, width = "100%")),
        tags$div(class = "d-flex gap-2 pb-3",
          actionButton(ns("btn_refresh_duplicates"), "Find duplicates", class = "btn-primary", icon = icon("magnifying-glass")),
          downloadButton(ns("download_duplicates"), "Export", class = "btn-outline-secondary"))
      )
    ),
    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      bslib::value_box(title = "Records checked", value = textOutput(ns("dup_total")),
                       showcase = bsicons::bs_icon("list-ol"), theme = "primary"),
      bslib::value_box(title = "Duplicate records", value = textOutput(ns("dup_count")),
                       showcase = bsicons::bs_icon("copy"), theme = "warning"),
      bslib::value_box(title = "Duplicate groups", value = textOutput(ns("dup_groups")),
                       showcase = bsicons::bs_icon("diagram-3"), theme = "info"),
      bslib::value_box(title = "Exact copies", value = textOutput(ns("dup_exact")),
                       "identical on every column: safe to remove",
                       showcase = bsicons::bs_icon("files"), theme = "danger")
    ),
    uiOutput(ns("dup_hint")),
    conditionalPanel(
      sprintf("output['%s']", ns("dup_has_rows")),
      bslib::card(
        full_screen = TRUE,
        bslib::card_header(bsicons::bs_icon("copy"), " Duplicate groups"),
        bslib::card_body(
          tags$div(
            class = "d-flex flex-wrap align-items-center gap-2 mb-1",
            actionButton(ns("dup_sel_extra"), "Select all but the first of each group", class = "btn-outline-secondary btn-sm"),
            actionButton(ns("dup_sel_exact"), "Select exact copies", class = "btn-outline-secondary btn-sm"),
            actionButton(ns("dup_sel_none"), "Clear selection", class = "btn-outline-secondary btn-sm"),
            tags$span(class = "small text-muted", textOutput(ns("dup_selected_n"), inline = TRUE)),
            actionButton(ns("dup_delete"), "Delete selected", class = "btn-outline-danger btn-sm ms-auto", icon = icon("trash"))
          ),
          tags$div(class = "small text-muted mb-2",
                   "Each band is one group. 'Differs in' lists the columns where its records disagree; ",
                   "none means exact copies. Compare shows a group side by side, and you can delete from there too."),
          DT::DTOutput(ns("dq_duplicate_table"), fill = FALSE)
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
dq_duplicates_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  # Bookkeeping columns added to the duplicated records.
  internal <- c(".dup_group", ".group_size", ".differs", ".n_differs", ".exact")

  observeEvent(uploaded_df(), {
    req(uploaded_df())
    cols <- names(uploaded_df())
    # A restored session's columns win over whatever the picker holds now:
    # this observer also runs when the restored data arrives.
    cur <- intersect(isolate(restored_vars()) %||% isolate(input$duplicate_vars) %||% character(0), cols)
    if (!length(cur) && !is.null(user_setup$unique_id) && user_setup$unique_id %in% cols) {
      cur <- user_setup$unique_id
    }
    shinyWidgets::updatePickerInput(session = session, inputId = "duplicate_vars", choices = cols, selected = cur)
  })

  # Re-run after a deletion so the table shows what is left.
  rerun <- reactiveVal(0)
  restored_vars <- reactiveVal(NULL)

  # Saved with the session: the columns and the matching settings.
  workspace_register(core$workspace, "dq_duplicates",
    snapshot = function() {
      if (is.null(uploaded_df()) || !length(input$duplicate_vars)) return(NULL)
      list(vars = input$duplicate_vars, fuzzy = input$duplicate_fuzzy, dist = input$duplicate_fuzzy_dist)
    },
    restore = function(s) {
      restored_vars(s$vars)
      after_flush(session, function() {
        shinyWidgets::updatePickerInput(session, "duplicate_vars", selected = s$vars)
        shinyWidgets::updateAwesomeCheckbox(session, "duplicate_fuzzy", value = isTRUE(s$fuzzy))
        if (!is.null(s$dist)) updateSliderInput(session, "duplicate_fuzzy_dist", value = s$dist)
      })
    })

  duplicate_analysis <- eventReactive(list(input$btn_refresh_duplicates, rerun()), {
    req(dq_filtered_data(), input$duplicate_vars)
    df <- dq_filtered_data()
    vars <- input$duplicate_vars
    req(all(vars %in% names(df)))

    use_fuzzy <- isTRUE(input$duplicate_fuzzy)
    max_dist <- as.integer(input$duplicate_fuzzy_dist)

    if (use_fuzzy && max_dist > 0) {
      key <- do.call(paste, c(df[vars], list(sep = "|")))
      groups <- fuzzy_match_groups(key, max_dist = max_dist)
      dup_index <- groups > 0
      dup_df <- df[dup_index, , drop = FALSE]
      dup_df$.dup_group <- groups[dup_index]
    } else {
      dup_index <- duplicated(df[vars]) | duplicated(df[vars], fromLast = TRUE)
      dup_df <- df[dup_index, , drop = FALSE]
      dup_df$.dup_group <- as.integer(factor(do.call(paste, c(dup_df[vars], list(sep = "|")))))
    }
    dup_df <- dup_df[order(dup_df$.dup_group), , drop = FALSE]
    data_cols <- setdiff(names(dup_df), internal)

    if (nrow(dup_df) > 0) {
      dup_df$.group_size <- as.integer(stats::ave(dup_df$.dup_group, dup_df$.dup_group, FUN = length))
      # Which columns disagree within each group: the whole point of looking.
      # ponytail: skipped above 50k duplicated rows to keep the tab responsive.
      if (nrow(dup_df) <= 50000) {
        diffs <- duplicate_group_diffs(dup_df[data_cols], dup_df$.dup_group)
        per_row <- diffs[as.character(dup_df$.dup_group)]
        dup_df$.differs <- vapply(per_row, paste, character(1), collapse = ", ")
        dup_df$.n_differs <- lengths(per_row)
      } else {
        dup_df$.differs <- NA_character_
        dup_df$.n_differs <- NA_integer_
      }
      dup_df$.exact <- duplicated(dup_df[data_cols])
    }

    list(total = nrow(df), dup_count = sum(dup_index),
         dup_groups = dplyr::n_distinct(dup_df$.dup_group),
         exact = if (nrow(dup_df)) sum(dup_df$.exact) else 0L,
         dup_df = dup_df, vars = vars, data_cols = data_cols)
  }, ignoreNULL = FALSE)

  # NULL until the user has run the analysis (req() inside the eventReactive
  # raises a silent error, which tryCatch turns into NULL for the placeholders)
  analysis_or_null <- reactive(tryCatch(duplicate_analysis(), error = function(e) NULL))

  kpi <- function(field) renderText({
    a <- analysis_or_null()
    if (is.null(a)) "\u2014" else format(a[[field]], big.mark = ",")
  })
  output$dup_total  <- kpi("total")
  output$dup_count  <- kpi("dup_count")
  output$dup_groups <- kpi("dup_groups")
  output$dup_exact  <- kpi("exact")

  output$dup_has_rows <- reactive({
    a <- analysis_or_null()
    !is.null(a) && nrow(a$dup_df) > 0
  })
  outputOptions(output, "dup_has_rows", suspendWhenHidden = FALSE)

  output$dup_hint <- renderUI({
    a <- analysis_or_null()
    if (is.null(a)) {
      empty_state("No duplicate analysis yet",
                  "Choose the columns that identify a record, then click Find duplicates.", icon = "copy")
    } else if (nrow(a$dup_df) == 0) {
      empty_state("No duplicates found",
                  paste0("Checked ", format(a$total, big.mark = ","), " records on the selected columns."), icon = "check2-circle")
    }
  })

  short_list <- function(x) vapply(x, function(s) {
    if (is.na(s)) return("")
    p <- strsplit(s, ", ", fixed = TRUE)[[1]]
    if (!length(p)) "\u2014 identical" else if (length(p) > 4) paste0(paste(p[1:4], collapse = ", "), " +", length(p) - 4)
    else paste(p, collapse = ", ")
  }, character(1), USE.NAMES = FALSE)

  output$dq_duplicate_table <- DT::renderDT({
    a <- analysis_or_null()
    req(a, nrow(a$dup_df) > 0)
    d <- a$dup_df
    show_cols <- unique(c(identification_cols(d, user_setup), a$vars))
    out <- d[, show_cols, drop = FALSE]
    out[] <- lapply(out, as.character)
    grp <- sprintf("Group %d \u00b7 %d records%s", d$.dup_group, d$.group_size,
                   ifelse(is.na(d$.n_differs), "",
                          ifelse(d$.n_differs == 0, " \u00b7 exact copies",
                                 sprintf(" \u00b7 differ in %d column(s)", d$.n_differs))))
    out <- cbind(Group = grp, out, stringsAsFactors = FALSE)
    out$`Differs in` <- short_list(d$.differs)
    out$Copy <- ifelse(d$.exact, "Exact copy", "")
    out$Compare <- sprintf(
      paste0("<button type='button' class='wfp-details-btn' title='Compare this group side by side' ",
             "onclick=\"event.stopPropagation(); Shiny.setInputValue('%s', %d, {priority:'event'})\"><span>Compare</span></button>"),
      ns("dup_compare"), d$.dup_group)
    # Row position, not the id: the id itself may be what is duplicated.
    out$Details <- record_detail_buttons(seq_len(nrow(d)), ns("dup_view"))
    n <- ncol(out)
    DT::datatable(
      out, rownames = FALSE, selection = "multiple", class = "compact hover",
      escape = setdiff(names(out), c("Compare", "Details")),
      extensions = "RowGroup",
      options = list(
        pageLength = 25, scrollX = TRUE, ordering = FALSE,
        rowGroup = list(dataSrc = 0),
        columnDefs = list(list(visible = FALSE, targets = 0),
                          list(searchable = FALSE, targets = c(n - 2L, n - 1L))))
    ) |>
      DT::formatStyle("Copy", color = "#c5192d", fontWeight = "600") |>
      DT::formatStyle("Differs in", color = "#b07800")
  })
  dup_proxy <- DT::dataTableProxy("dq_duplicate_table", session = session)

  selected <- reactive(input$dq_duplicate_table_rows_selected %||% integer(0))
  output$dup_selected_n <- renderText({
    k <- length(selected())
    if (k) sprintf("%s selected", format(k, big.mark = ",")) else ""
  })

  observe({
    has <- tryCatch(nrow(analysis_or_null()$dup_df) > 0, error = function(e) FALSE)
    for (b in c("dup_sel_extra", "dup_sel_exact", "dup_delete", "download_duplicates"))
      gate_button(b, isTRUE(has), "Click Find duplicates first; there is nothing to act on yet.")
  })

  observeEvent(input$dup_sel_extra, {
    a <- analysis_or_null(); need_ok(!is.null(a), "Click Find duplicates first.")
    DT::selectRows(dup_proxy, which(duplicated(a$dup_df$.dup_group)))
  })
  observeEvent(input$dup_sel_exact, {
    a <- analysis_or_null(); need_ok(!is.null(a), "Click Find duplicates first.")
    hit <- which(a$dup_df$.exact)
    DT::selectRows(dup_proxy, hit)
    if (!length(hit)) showNotification("No exact copies: every duplicate differs somewhere.", type = "message")
  })
  observeEvent(input$dup_sel_none, DT::selectRows(dup_proxy, NULL))

  observeEvent(input$dup_view, {
    a <- analysis_or_null(); req(a)
    i <- suppressWarnings(as.integer(input$dup_view))
    req(!is.na(i), i >= 1, i <= nrow(a$dup_df))
    showModal(record_detail_modal(a$dup_df[i, a$data_cols, drop = FALSE],
                                  title = paste("Duplicate record, group", a$dup_df$.dup_group[i])))
  })

  # --- one group, side by side ----------------------------------------------
  observeEvent(input$dup_compare, {
    a <- analysis_or_null(); req(a)
    rows <- which(a$dup_df$.dup_group == input$dup_compare)
    req(length(rows))
    g <- a$dup_df[rows, a$data_cols, drop = FALSE]
    uid <- user_setup$unique_id
    heads <- if (shiny::isTruthy(uid) && uid %in% names(g)) sprintf("%d. %s", seq_along(rows), g[[uid]])
             else sprintf("Record %d", seq_along(rows))
    differs <- a$data_cols[vapply(g, function(x) length(unique(as.character(x))) > 1, logical(1))]
    same <- setdiff(a$data_cols, differs)
    field_rows <- function(cols, cls) lapply(cols, function(cl) tags$tr(
      class = cls, tags$th(cl), lapply(g[[cl]], function(v) tags$td(if (is.na(v)) tags$em("missing") else as.character(v)))))
    showModal(modalDialog(
      title = tagList(bsicons::bs_icon("layout-split"), sprintf(" Group %s: %d records", input$dup_compare, length(rows))),
      size = "xl", easyClose = TRUE,
      tags$p(class = "small text-muted",
             if (length(differs)) sprintf("They differ in %d of %d columns, shown first.", length(differs), length(a$data_cols))
             else "They are identical on every column: keep one."),
      tags$div(class = "wfp-model-table-wrap wfp-dup-compare",
               tags$table(class = "wfp-model-table",
                          tags$thead(tags$tr(tags$th("Column"), lapply(heads, tags$th))),
                          tags$tbody(field_rows(differs, "wfp-dup-diff"),
                                     if (length(same)) tags$tr(tags$td(colspan = length(rows) + 1, class = "small text-muted",
                                                                       sprintf("%d identical column(s):", length(same)))),
                                     field_rows(same, "wfp-dup-same")))),
      tags$hr(),
      checkboxGroupInput(ns("dup_cmp_del"), "Records to delete", inline = TRUE,
                         choices = stats::setNames(rows, heads)),
      textInput(ns("dup_cmp_reason"), "Reason (written to the audit trail)", width = "100%",
                placeholder = "e.g. same household registered twice"),
      footer = tagList(modalButton("Close"),
                       actionButton(ns("dup_cmp_delete"), "Delete ticked records", class = "btn-outline-danger", icon = icon("trash")))
    ))
  })

  # --- deleting ----------------------------------------------------------------
  # Rows are found back in the full data by id AND content, so deleting one of
  # two records sharing an id removes that one, and one of two exact copies
  # removes exactly one.
  delete_rows <- function(rows, note) {
    a <- analysis_or_null(); req(a)
    d <- a$dup_df[rows, a$data_cols, drop = FALSE]
    full <- uploaded_df()
    cols <- intersect(a$data_cols, names(full))
    uid <- user_setup$unique_id
    has_uid <- shiny::isTruthy(uid) && uid %in% names(full)
    cand <- if (has_uid) which(as.character(full[[uid]]) %in% as.character(d[[uid]])) else seq_len(nrow(full))
    fp <- function(x) do.call(paste, c(lapply(x[cols], function(v) { v <- as.character(v); v[is.na(v)] <- "\001"; v }),
                                       list(sep = "\037")))
    kc <- fp(full[cand, , drop = FALSE])
    hit <- integer(0)
    for (k in fp(d)) {
      j <- which(kc == k & !(cand %in% hit))[1]
      if (!is.na(j)) hit <- c(hit, cand[j])
    }
    if (!length(hit)) {
      showNotification("These records are no longer in the data (edited or deleted since the analysis).", type = "warning")
      return(invisible(FALSE))
    }
    ids <- if (has_uid) as.character(full[[uid]][hit]) else as.character(hit)
    uploaded_df(full[-hit, , drop = FALSE])
    reason <- sprintf("Duplicate on %s%s", paste(a$vars, collapse = " + "), if (nzchar(note)) paste0(": ", note) else "")
    modification_log(dplyr::bind_rows(modification_log(), data.frame(
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = ids, column = "ALL",
      old_value = "Row Existed", new_value = "Deleted", action = "Duplicate deletion",
      user = Sys.getenv("USERNAME", Sys.getenv("USER", "")), reason = reason, stringsAsFactors = FALSE)))
    rerun(rerun() + 1)
    showNotification(sprintf("%d duplicate record(s) deleted and logged.", length(hit)), type = "warning")
    invisible(TRUE)
  }

  observeEvent(input$dup_delete, {
    rows <- selected()
    if (!length(rows)) { showNotification("Select the records to delete first.", type = "warning"); return() }
    a <- analysis_or_null(); req(a)
    whole <- tapply(seq_len(nrow(a$dup_df)) %in% rows, a$dup_df$.dup_group, all)
    showModal(modalDialog(
      title = tagList(bsicons::bs_icon("trash"), " Delete duplicate records"),
      tags$p(sprintf("%d record(s) will be removed from the data.", length(rows))),
      if (any(whole)) tags$div(class = "alert alert-warning small",
                               sprintf("%d group(s) would lose every record. Keep at least one per group unless all are wrong.", sum(whole))),
      textInput(ns("dup_reason"), "Reason (written to the audit trail)", width = "100%",
                placeholder = "e.g. same household registered twice"),
      easyClose = TRUE,
      footer = tagList(modalButton("Cancel"), actionButton(ns("dup_delete_ok"), "Delete", class = "btn-danger"))
    ))
  })
  observeEvent(input$dup_delete_ok, {
    removeModal()
    delete_rows(selected(), trimws(input$dup_reason %||% ""))
  })
  observeEvent(input$dup_cmp_delete, {
    rows <- as.integer(input$dup_cmp_del %||% integer(0))
    if (!length(rows)) { showNotification("Tick the records to delete.", type = "warning"); return() }
    removeModal()
    delete_rows(rows, trimws(input$dup_cmp_reason %||% ""))
  })

  output$download_duplicates <- download_handler(
    filename = function() export_file_name("Targeting_Duplicates", "xlsx", "%Y-%m-%d_%Hh%Mm%Ss"),
    content = function(file) {
      a <- analysis_or_null()
      if (is.null(a) || nrow(a$dup_df) == 0) {
        write_xlsx_readonly(data.frame(Message = "No duplicates found"), file, "Duplicates")
      } else {
        d <- a$dup_df
        names(d)[match(c(".dup_group", ".differs"), names(d))] <- c("duplicate_group", "differs_in")
        write_xlsx_readonly(d[, setdiff(names(d), c(".group_size", ".n_differs", ".exact")), drop = FALSE], file, "Duplicates")
      }
    }
  )
}
