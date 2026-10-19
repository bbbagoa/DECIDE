#' Targeting Monitoring (phase 3)
#'
#' Three tabs: the PDM analysis (implementation errors, plus charts on any
#' PDM variable), targeting process (the officer's own datasets and charts:
#' complaints, community process, committees, participation...), and the
#' report, which gathers the implementation errors, every chart or table
#' added with its comment, and the officer's context, findings and
#' recommendations into one HTML Targeting Monitoring report.
#' @param id module id
#' @noRd
mod_monitoring_ui <- function(id) {
  ns <- NS(id)
  # The page is a fill container, so the tabs were squeezed to the window
  # height and the lower half (the chart builder's Add to report, the report
  # items) could not be scrolled to. This box takes the window height and
  # scrolls; nothing inside it is stretched.
  htmltools::bindFillRole(item = TRUE, tags$div(class = "wfp-scroll-page", bslib::navset_underline(
    id = ns("tabs"),
    bslib::nav_panel(
      value = "pdm", title = tagList(bsicons::bs_icon("bullseye"), " 1. Implementation errors"),
      mod_pdm_ui(ns("pdm"), explore = mod_chart_builder_ui(ns("pdm_charts"), presets = "PDM"))
    ),
    bslib::nav_panel(
      value = "process", title = tagList(bsicons::bs_icon("people"), " 2. Targeting process"),
      # Datasets and areas in a compact sidebar; the chart builder beside it.
      bslib::layout_sidebar(
        fillable = FALSE, class = "mt-3 wfp-mon-layout",
        sidebar = bslib::sidebar(
          width = 330, class = "wfp-mon-sidebar",
          bslib::accordion(
            id = ns("pm_setup"), multiple = FALSE, open = "data",
            bslib::accordion_panel(
              "Datasets", value = "data", icon = bsicons::bs_icon("cloud-upload"),
              tags$p(class = "small text-muted mb-2",
                     "Complaints and feedback, community sessions, targeting committees, participation of women and minorities, ",
                     "focus groups on the criteria. Load as many as you have."),
              fileInput(ns("pm_file"), NULL, width = "100%", placeholder = "Load a dataset",
                        accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet")),
              tags$div(class = "d-flex gap-2 align-items-end",
                       tags$div(class = "flex-fill", selectInput(ns("pm_active"), "Dataset to chart", choices = character(0), width = "100%")),
                       tags$div(class = "pb-3", actionButton(ns("pm_remove"), NULL, icon = icon("trash"), class = "btn-outline-danger btn-sm",
                                                             title = "Remove this dataset"))),
              tags$div(class = "mt-1 mb-2", mod_moda_import_ui(ns("pm_moda"))),
              uiOutput(ns("pm_status"))),
            bslib::accordion_panel(
              "Areas covered", value = "areas", icon = bsicons::bs_icon("geo-alt"),
              mod_area_scope_ui(ns("pm_scope"), title = NULL)))
        ),
        mod_chart_builder_ui(ns("pm_charts"), presets = c("Complaints and feedback (CFM)", "Community process"))
      )
    ),
    bslib::nav_panel(
      value = "report", title = tagList(bsicons::bs_icon("file-earmark-text"), " 3. Monitoring report"),
      bslib::layout_columns(
        class = "mt-3", col_widths = c(4, 8),
        bslib::card(
          bslib::card_header(bsicons::bs_icon("pencil"), " Your analysis"),
          bslib::card_body(
            # Start from a template: ready-made charts on the data loaded, or a
            # report saved from an earlier round (compared with it).
            # Open on arrival: a template is the quickest start; fold it to
            # build the charts yourself.
            tags$details(
              class = "wfp-mon-draft", open = NA,
              tags$summary(class = "small fw-bold", bsicons::bs_icon("magic"), " Start from a template, or build your own charts"),
              tags$p(class = "small text-muted mt-2 mb-2",
                     "Fills the report with ready-made charts from the data you loaded, each with a suggested finding you can edit. ",
                     "Your own charts and texts are kept unless you choose to replace them."),
              tags$div(class = "d-flex gap-2 align-items-end",
                       tags$div(class = "flex-fill", selectInput(ns("tpl"), NULL, choices = character(0), width = "100%")),
                       tags$div(class = "pb-3", actionButton(ns("tpl_apply"), "Draft", icon = icon("wand-magic-sparkles"),
                                                             class = "btn-outline-primary",
                                                             title = "Fill the report with this template's charts, with findings written from the numbers"))),
              tags$p(class = "small text-muted mb-1",
                     "Share a saved template with colleagues or another office as a file (charts and figures, never the data), or import one."),
              tags$div(class = "d-flex gap-2 flex-wrap align-items-start",
                       downloadButton(ns("tpl_export"), "Export", class = "btn-outline-secondary btn-sm",
                                      title = "Save the template picked above as a file"),
                       actionButton(ns("tpl_delete"), NULL, icon = icon("trash"), class = "btn-outline-danger btn-sm",
                                    title = "Delete the saved template picked above")),
              fileInput(ns("tpl_import"), NULL, accept = ".json", width = "100%", buttonLabel = "Import...",
                        placeholder = "A template file (.json)"),
              uiOutput(ns("rounds_note"))),
            rich_text_input(ns("context"), "Context", rows = 3,
                            placeholder = "Programme, area, period, targeting approach, who collected what."),
            rich_text_input(ns("findings"), "Key findings", rows = 3,
                            placeholder = "What worked, what did not, where and for whom."),
            rich_text_input(ns("recommendations"), "Recommendations", rows = 3,
                            placeholder = "What to change in the next round, and who does it."),
            checkboxInput(ns("include_pdm"), "Include the implementation errors (post-targeting survey or PDM)", value = TRUE),
            # Checked first (small groups, missing titles or comments...), then
            # downloaded through the hidden link below.
            actionButton(ns("report_check"), "Targeting monitoring report (HTML)", icon = icon("download"), class = "btn-primary w-100"),
            tags$div(class = "small text-muted mt-1", "The report is checked first (titles, comments, small groups); you can still export as it is."),
            # Next round starts from this one: same charts, change since this round.
            actionButton(ns("tpl_save"), "Save this report as a template", icon = icon("floppy-disk"),
                         class = "btn-outline-primary w-100 mt-2",
                         title = "Keep the charts (not the data) and this round's figures; next round, pick it and click Draft"),
            tags$div(style = "display:none", downloadButton(ns("report"), "Download")),
            tags$script(HTML("$(function(){Shiny.addCustomMessageHandler('tw-mon-download',function(m){var a=document.getElementById(m.id);if(a)a.click();});});"))
          )
        ),
        bslib::card(
          bslib::card_header(bsicons::bs_icon("collection"), " In the report"),
          bslib::card_body(uiOutput(ns("items_ui")))
        )
      )
    )
  )))
}

#' @noRd
mod_monitoring_server <- function(id, workspace = NULL, country_office = reactive(NULL), modification_log = NULL,
                                  user_setup = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    pdm <- mod_pdm_server("pdm", workspace, country_office = country_office, modification_log = modification_log,
                          user_setup = user_setup)

    items <- reactiveVal(list())
    add_item <- function(it) {
      items(c(items(), list(it)))
      audit_add(modification_log, "Monitoring", "Added to the monitoring report", it$title)
    }

    # --- targeting-process datasets -------------------------------------------
    datasets <- reactiveVal(list())
    observeEvent(input$pm_file, {
      f <- input$pm_file; req(f)
      ext <- tolower(tools::file_ext(f$name))
      if (!ext %in% c("xlsx", "xls", "sav", "dta", "csv", "parquet")) {
        showNotification(paste("Unsupported file type:", ext), type = "error"); return()
      }
      df <- tryCatch(as.data.frame(read_import_file(f$datapath, ext)), error = function(e) {
        showNotification(paste("Could not read file:", conditionMessage(e)), type = "error"); NULL })
      req(df)
      take_pm(df, f$name)
    })
    pm_forms <- reactiveVal(list())   # dataset name -> the MODA form it came from (saved; never the key)
    take_pm <- function(df, name, form = NULL) tw_guard("Loading the dataset", {
      fm <- pm_forms(); fm[[name]] <- form; pm_forms(fm)
      ds <- datasets(); ds[[name]] <- df; datasets(ds)
      updateSelectInput(session, "pm_active", choices = names(ds), selected = name)
      audit_add(modification_log, "Monitoring", "Targeting-process data loaded", sprintf("%s (%s rows)", name, nrow(df)))
    })
    # Datasets can also come from MODA / ONA forms, one per form.
    pm_moda <- mod_moda_import_server("pm_moda")
    observeEvent(pm_moda$data(), {
      df <- pm_moda$data(); req(df)
      take_pm(as.data.frame(df), pm_moda$label() %||% sprintf("MODA form %s", pm_moda$credentials()$form_id %||% ""),
              form = pm_moda$credentials()$form_id)
    })
    observeEvent(input$pm_remove, {
      req(input$pm_remove > 0)   # a React button sends 0 at start
      ds <- datasets(); need_ok(length(ds) > 0 && shiny::isTruthy(input$pm_active), "No dataset to remove.")
      ds[[input$pm_active]] <- NULL; datasets(ds)
      updateSelectInput(session, "pm_active", choices = names(ds), selected = if (length(ds)) names(ds)[1] else character(0))
    })
    output$pm_status <- renderUI({
      ds <- datasets()
      if (!length(ds)) return(NULL)
      tags$div(class = "wfp-norm-bar", tags$strong(sprintf("%d dataset%s", length(ds), if (length(ds) > 1) "s" else "")),
               lapply(names(ds), function(n) tags$span(class = "wfp-norm-chip", n, tags$em(format(nrow(ds[[n]]), big.mark = ",")))))
    })
    active_pm <- reactive({ ds <- datasets(); if (shiny::isTruthy(input$pm_active)) ds[[input$pm_active]] else NULL })
    mod_data_summary_server("pm_summary", active_pm, "Targeting process data")
    # the chosen dataset's new submissions, when it came from MODA
    mod_moda_refresh_server("pm_refresh", active_pm,
                            function(df) { ds <- datasets(); ds[[input$pm_active]] <- df; datasets(ds) },
                            reactive(if (shiny::isTruthy(input$pm_active)) pm_forms()[[input$pm_active]]),
                            "Targeting process data", log = modification_log, phase = "Monitoring")

    mod_chart_builder_server("pdm_charts", data = pdm$df, source = "pdm", add_item = add_item, presets = "PDM",
                             dataset_name = reactive({
                               a <- pdm$areas()
                               paste0(pdm$name(), if (!identical(a, "All areas")) paste0(" (", a, ")") else "")
                             }))
    # Charts cover the chosen areas; the dataset name says which.
    pm_scope <- mod_area_scope_server("pm_scope", active_pm, workspace, "pm_scope", modification_log, "Monitoring")
    mod_chart_builder_server("pm_charts", data = reactive(pm_scope$filter(active_pm())), source = "process",
                             dataset_name = reactive({
                               a <- pm_scope$text()
                               paste0(input$pm_active %||% "", if (!identical(a, "All areas")) paste0(" (", a, ")") else "")
                             }), add_item = add_item,
                             presets = c("Complaints and feedback (CFM)", "Community process"))

    observe(gate_button("pm_remove", length(datasets()) > 0, "No dataset loaded yet."))

    # --- templates, drafts and rounds ---------------------------------------------
    who <- app_user(session)
    saved_templates <- reactiveVal(tryCatch(app_setting_get("monitoring_templates", who), error = function(e) NULL) %||% list())
    previous_rounds <- reactiveVal(list())   # earlier rounds of the template in use, oldest first
    observe({
      bi <- monitoring_templates()
      ch <- list(`Ready-made` = as.list(stats::setNames(paste0("builtin:", names(bi)), vapply(bi, `[[`, character(1), "label"))))
      sv <- saved_templates()
      if (length(sv)) ch$`Saved from earlier rounds` <- as.list(stats::setNames(paste0("saved:", names(sv)),
        vapply(names(sv), function(n) sprintf("%s (%d round%s)", n, length(sv[[n]]$rounds), if (length(sv[[n]]$rounds) == 1) "" else "s"), character(1))))
      updateSelectInput(session, "tpl", choices = ch, selected = isolate(input$tpl))
    })
    pdm_label <- function() {
      a <- pdm$areas()
      paste0(pdm$name(), if (!identical(a, "All areas")) paste0(" (", a, ")") else "")
    }
    process_sets <- function() lapply(datasets(), function(df) tryCatch(pm_scope$filter(df), error = function(e) df))
    apply_template <- function(mode) {
      removeModal()
      sel <- input$tpl %||% ""
      res <- if (startsWith(sel, "builtin:")) {
        monitoring_draft(sub("^builtin:", "", sel), pdm$df(), process_sets(), pdm_label())
      } else {
        t <- saved_templates()[[sub("^saved:", "", sel)]]
        need_ok(!is.null(t), "Pick a template first.")
        previous_rounds(t$rounds %||% list())
        # the kept texts fill the boxes that are still empty
        for (k in intersect(names(t$texts), c("context", "findings", "recommendations")))
          if (!nzchar(trimws(rich_text(input[[k]] %||% ""))) && nzchar(trimws(rich_text(t$texts[[k]])))) update_rich_text(session, k, t$texts[[k]])
        items_from_template(t$items, pdm$df(), process_sets(), pdm_label())
      }
      if (!length(res$items)) {
        showNotification(paste("Nothing to draft: none of this template's charts found its columns.",
                               "Load the PDM data (tab 1) and the targeting-process datasets (tab 2) first."), type = "warning", duration = 10)
        return()
      }
      items(if (identical(mode, "add")) c(items(), res$items) else res$items)
      audit_add(modification_log, "Monitoring", "Report drafted from a template",
                sprintf("%s: %d charts", sel, length(res$items)))
      showNotification(paste0(sprintf("%d chart%s drafted, each with a finding written from its numbers: review and edit them.",
                                      length(res$items), if (length(res$items) == 1) "" else "s"),
                              if (length(res$skipped)) paste(" Not found in the data:", paste(res$skipped, collapse = ", "), ".") else ""),
                       type = "message", duration = 10)
    }
    observeEvent(input$tpl_apply, {
      req(input$tpl_apply > 0)
      need_ok(nzchar(input$tpl %||% ""), "Pick a template first.")
      if (!length(items())) return(apply_template("replace"))
      showModal(modalDialog(
        title = tagList(icon("wand-magic-sparkles"), " Draft from the template"), size = "s", easyClose = TRUE,
        tags$p(class = "small", sprintf("The report already has %d item%s.", length(items()), if (length(items()) == 1) "" else "s")),
        footer = tagList(modalButton("Cancel"),
                         actionButton(ns("tpl_add"), "Add to them", class = "btn-outline-primary"),
                         actionButton(ns("tpl_replace"), "Replace them", class = "btn-primary"))))
    })
    observeEvent(input$tpl_add, apply_template("add"))
    observeEvent(input$tpl_replace, apply_template("replace"))

    observeEvent(input$tpl_save, {
      req(input$tpl_save > 0)
      need_ok(length(items()) > 0, "Add charts to the report first: the template keeps them (without the data).")
      cur <- sub("^saved:", "", input$tpl %||% "")
      showModal(modalDialog(
        title = tagList(icon("floppy-disk"), " Save as template"), size = "m", easyClose = TRUE,
        tags$p(class = "small text-muted",
               "Keeps the charts (not the data) and this round's figures. Next round, pick the template and click Draft:",
               " the same charts are drawn on the new data and the report shows what changed since this round."),
        textInput(ns("tpl_name"), "Template name", value = if (startsWith(input$tpl %||% "", "saved:")) cur else "Monitoring report", width = "100%"),
        textInput(ns("tpl_round"), "This round", value = format(Sys.Date(), "%B %Y"), width = "100%"),
        checkboxInput(ns("tpl_keep_texts"), "Keep my comments and the report texts (context, findings, recommendations) as the starting point next round",
                      value = TRUE),
        footer = tagList(modalButton("Cancel"), actionButton(ns("tpl_save_go"), "Save", class = "btn-primary", icon = icon("floppy-disk")))))
    })
    observeEvent(input$tpl_save_go, {
      nm <- trimws(input$tpl_name %||% ""); rd <- trimws(input$tpl_round %||% "")
      need_ok(nzchar(nm) && nzchar(rd), "Name the template and the round.")
      sv <- saved_templates()
      t <- sv[[nm]] %||% list(name = nm, rounds = list())
      keep <- isTRUE(input$tpl_keep_texts)
      t$items <- template_from_items(items(), keep_comments = keep)
      t$texts <- if (keep) c(context = input$context %||% "", findings = input$findings %||% "",
                             recommendations = input$recommendations %||% "")
      t$rounds <- c(Filter(function(r) !identical(r$label, rd), t$rounds %||% list()),
                    list(monitoring_round(rd, report_pdm(checks = TRUE), items())))
      sv[[nm]] <- t
      saved_templates(sv)
      tryCatch(app_setting_set("monitoring_templates", sv, who), error = function(e) NULL)
      removeModal()
      # after the choices observer has sent the new list (it keeps the old pick)
      after_flush(session, function() updateSelectInput(session, "tpl", selected = paste0("saved:", nm)))
      audit_add(modification_log, "Monitoring", "Report saved as a template", sprintf("%s, round %s", nm, rd))
      showNotification(sprintf("Saved '%s' with the figures of %s.", nm, rd), type = "message")
    })
    # A template as a file, to share; and a shared one brought in.
    output$tpl_export <- download_handler(
      filename = function() paste0(gsub("[^A-Za-z0-9_-]+", "_", sub("^saved:", "", input$tpl %||% "template")), "_monitoring_template.json"),
      content = function(file) {
        t <- saved_templates()[[sub("^saved:", "", input$tpl %||% "")]]
        req(t)
        writeLines(template_json(t), file, useBytes = TRUE)
        audit_add(modification_log, "Monitoring", "Template exported", t$name %||% "")
      })
    observe(gate_button("tpl_export", startsWith(input$tpl %||% "", "saved:"),
                        "Pick one of your saved templates (under 'Saved from earlier rounds') to export it."))
    observeEvent(input$tpl_import, {
      f <- input$tpl_import; req(f)
      t <- tryCatch(read_template_json(paste(readLines(f$datapath, encoding = "UTF-8", warn = FALSE), collapse = "\n")),
                    error = function(e) e)
      need_ok(!inherits(t, "error"), if (inherits(t, "error")) conditionMessage(t) else "")
      sv <- saved_templates()
      nm <- t$name; k <- 2L
      while (nm %in% names(sv)) { nm <- sprintf("%s (%d)", t$name, k); k <- k + 1L }
      t$name <- nm
      sv[[nm]] <- t
      saved_templates(sv)
      tryCatch(app_setting_set("monitoring_templates", sv, who), error = function(e) NULL)
      # after the choices observer has sent the new list (it keeps the old pick)
      after_flush(session, function() updateSelectInput(session, "tpl", selected = paste0("saved:", nm)))
      audit_add(modification_log, "Monitoring", "Template imported", sprintf("%s (%d charts, %d rounds)", nm, length(t$items), length(t$rounds)))
      showNotification(sprintf("Template '%s' imported: %d charts, %d earlier round%s. Load this round's data, then click Draft.",
                               nm, length(t$items), length(t$rounds), if (length(t$rounds) == 1) "" else "s"), type = "message", duration = 10)
    })
    observeEvent(input$tpl_delete, {
      req(input$tpl_delete > 0)
      sel <- input$tpl %||% ""
      need_ok(startsWith(sel, "saved:"), "Pick one of your saved templates to delete (the ready-made ones stay).")
      sv <- saved_templates(); sv[[sub("^saved:", "", sel)]] <- NULL
      saved_templates(sv)
      tryCatch(app_setting_set("monitoring_templates", sv, who), error = function(e) NULL)
      showNotification("Template deleted.", type = "message")
    })
    output$rounds_note <- renderUI({
      r <- previous_rounds()
      if (!length(r)) return(NULL)
      last <- r[[length(r)]]
      tags$div(class = "small mt-1", bsicons::bs_icon("clock-history"),
               sprintf(" Compared with %s (%s)%s.", last$label, fmt_date(last$date),
                       if (length(r) > 1) sprintf(" and %d earlier round%s", length(r) - 1, if (length(r) > 2) "s" else "") else ""))
    })

    # --- the report's items: reorder, edit the comment, remove -------------------
    # The list is redrawn when items are added, removed, moved or resized, not
    # when a comment changes: a redraw would take the text from under the cursor.
    items_shape <- reactiveVal(NULL)
    redraw <- reactiveVal(0)   # a comment replaced from outside the editor
    observe(items_shape(list(redraw(), lapply(items(), function(it) it[c("id", "title", "width", "source", "dataset", "display")]))))
    output$items_ui <- renderUI({
      items_shape()
      its <- isolate(items())
      if (!length(its)) {
        return(empty_state("Nothing added yet",
                           "Build a chart or a table on the PDM or Targeting process tab and click Add to report.",
                           icon = "collection"))
      }
      js <- function(what, id) sprintf("Shiny.setInputValue('%s', {what: '%s', id: '%s', n: Math.random()})", ns("item_act"), what, id)
      half <- function(it) identical(it$width, "half")
      tagList(
        tags$p(class = "small text-muted mb-2",
               bsicons::bs_icon("grip-vertical"), " Drag an item by its handle to reorder. ",
               "Two half-width items next to each other sit side by side in the report."),
        tags$div(
        class = "wfp-items", `data-input` = ns("item_order"),
        lapply(seq_along(its), function(i) {
        it <- its[[i]]
        tags$div(
          class = paste("wfp-item", if (half(it)) "is-half"), `data-id` = it$id,
          tags$div(class = "wfp-item-head",
                   tags$span(class = "wfp-drag", title = "Drag to reorder", bsicons::bs_icon("grip-vertical")),
                   tags$span(class = "wfp-item-num", i),
                   tags$div(class = "flex-grow-1",
                            tags$strong(it$title),
                            tags$div(class = "small text-muted",
                                     if (identical(it$source, "pdm")) pdm$kind() else "Targeting process", " \u00b7 ",
                                     it$dataset, " \u00b7 ", if (identical(it$display, "table")) "table" else "chart")),
                   tags$div(class = "btn-group btn-group-sm",
                            tags$button(type = "button", class = "btn btn-outline-secondary",
                                        title = if (half(it)) "Make full width" else "Make half width (side by side)",
                                        onclick = js("width", it$id),
                                        bsicons::bs_icon(if (half(it)) "arrows-angle-expand" else "layout-split")),
                            tags$button(type = "button", class = "btn btn-outline-secondary", title = "Move up",
                                        onclick = js("up", it$id), icon("arrow-up")),
                            tags$button(type = "button", class = "btn btn-outline-secondary", title = "Move down",
                                        onclick = js("down", it$id), icon("arrow-down")),
                            tags$button(type = "button", class = "btn btn-outline-danger", title = "Remove",
                                        onclick = js("remove", it$id), icon("xmark")))),
          tags$div(class = "mt-2", rich_text_input(value = it$comment, placeholder = "Comment", rows = 2, compact = TRUE,
                                                   send = ns("item_comment"), item = it$id)),
          # The suggestion, unless the comment already says it.
          if (nzchar(it$caption %||% "") && !grepl(it$caption, rich_text(it$comment %||% ""), fixed = TRUE)) tags$div(
            class = "wfp-mon-suggest small",
            bsicons::bs_icon("lightbulb"), tags$span(class = "text-muted", " Suggested finding: "), it$caption, " ",
            tags$button(type = "button", class = "btn btn-link btn-sm p-0 align-baseline", onclick = js("caption", it$id),
                        "Use it"))
        )
      })))
    })
    observeEvent(input$item_order, {
      its <- items()
      ids <- vapply(its, `[[`, character(1), "id")
      ord <- match(unlist(input$item_order), ids)
      ord <- c(ord[!is.na(ord)], setdiff(seq_along(its), ord))
      items(its[ord])
    })
    observeEvent(input$item_act, {
      a <- input$item_act; its <- items()
      i <- which(vapply(its, `[[`, character(1), "id") == a$id); req(length(i) == 1)
      if (identical(a$what, "remove")) its <- its[-i]
      else if (identical(a$what, "width")) its[[i]]$width <- if (identical(its[[i]]$width, "half")) "full" else "half"
      else if (identical(a$what, "up") && i > 1) its[c(i - 1, i)] <- its[c(i, i - 1)]
      else if (identical(a$what, "down") && i < length(its)) its[c(i, i + 1)] <- its[c(i + 1, i)]
      else if (identical(a$what, "caption")) {
        old <- rich_text(its[[i]]$comment)
        its[[i]]$comment <- if (nzchar(old) && !grepl(its[[i]]$caption, old, fixed = TRUE)) paste(old, its[[i]]$caption) else its[[i]]$caption
        items(its); redraw(redraw() + 1)
        return()
      }
      items(its)
    })
    observeEvent(input$item_comment, {
      a <- input$item_comment; its <- items()
      i <- which(vapply(its, `[[`, character(1), "id") == a$id); req(length(i) == 1)
      its[[i]]$comment <- a$text
      items(its)
    })

    # --- the report --------------------------------------------------------------
    # The implementation errors as the report takes them (NULL when not
    # computed, or not included unless `checks`).
    report_pdm <- function(checks = FALSE) {
      r <- pdm$results()
      if (is.null(r) || (!checks && !isTRUE(input$include_pdm))) return(NULL)
      tol <- pdm$tolerance()
      list(metrics = r$metrics, n = r$n, by_unit = r$by_unit, excl_design = r$excl_design, tolerance = tol,
           elig_source = r$elig_source, weighting = r$weighting, strata = r$strata, no_nonbenef = r$no_nonbenef,
           kind = pdm$kind(), areas = pdm$areas(), unit_col = r$unit_col, decisions = r$decisions, matrix = r$matrix,
           verdict = tryCatch(error_verdict(r$metrics$inclusion_error, r$metrics$exclusion_error, tol[1], tol[2],
                                            stage = "implementation"), error = function(e) NULL))
    }
    observeEvent(input$report_check, {
      req(input$report_check > 0)
      w <- monitoring_checks(items(), report_pdm(checks = TRUE),
                             c(context = input$context %||% "", findings = input$findings %||% "",
                               recommendations = input$recommendations %||% ""),
                             include_pdm = isTRUE(input$include_pdm))
      if (!length(w)) return(session$sendCustomMessage("tw-mon-download", list(id = ns("report"))))
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("clipboard-check"), " Before you export"), size = "m", easyClose = TRUE,
        tags$p(class = "small text-muted", sprintf("%d point%s worth a look:", length(w), if (length(w) == 1) "" else "s")),
        tags$ul(class = "small wfp-mon-checks", lapply(w, tags$li)),
        footer = tagList(
          modalButton("Go back"),
          tags$button(type = "button", class = "btn btn-primary",
                      onclick = sprintf("document.getElementById('%s').click(); $('#shiny-modal').modal('hide');", ns("report")),
                      icon("download"), " Export anyway"))))
    })
    output$report <- download_handler(
      filename = function() export_file_name("Targeting_monitoring_report", "html", "%Y-%m-%d_%Hh%M"),
      content = function(file) {
        p <- report_pdm()
        lang <- session$rootScope()$input$lang_selector
        write_monitoring_report(file, list(country_office = country_office(), context = input$context,
                                           findings = input$findings, recommendations = input$recommendations,
                                           pdm = p, items = items(), kind = pdm$kind(),
                                           previous = previous_rounds(),
                                           variables_md = variables_md(unlist(lapply(items(), function(it)
                                             c(it$spec$x, it$spec$group, it$spec$value, it$spec$date, it$spec$den))), session)),
                                lang = if (identical(lang, "fr")) "fr" else "en")
        audit_add(modification_log, "Monitoring", "Monitoring report exported",
                  sprintf("%d charts and tables%s", length(items()), if (is.null(p)) "" else ", with implementation errors"))
      }
    )
    # The link is hidden: it must still be ready when clicked.
    outputOptions(output, "report", suspendWhenHidden = FALSE)

    # --- The React page (react/src/pages/monitoring/) --------------------------
    # The file inputs stay Shiny's (they stream the upload), drawn here and
    # hosted; rendered once and kept bound while their section is folded.
    output$pm_file_ui <- renderUI(fileInput(ns("pm_file"), NULL, width = "100%", placeholder = "Load a dataset",
                                            accept = c(".xlsx", ".xls", ".sav", ".dta", ".csv", ".parquet")))
    output$tpl_import_ui <- renderUI(fileInput(ns("tpl_import"), NULL, accept = ".json", width = "100%", buttonLabel = "Import...",
                                               placeholder = "A template file (.json)"))
    for (k in c("pm_file_ui", "tpl_import_ui"))
      outputOptions(output, k, suspendWhenHidden = FALSE)
    # The facts the page draws: the datasets, the earlier rounds, the report's items.
    output$mon_state <- shinyreact::reactive_output({
      ds <- datasets(); r <- previous_rounds(); its <- items()
      last <- if (length(r)) r[[length(r)]]
      list(
        datasets = lapply(names(ds), function(n) list(name = n, rows = nrow(ds[[n]]))),
        rounds = if (!is.null(last)) sprintf("Compared with %s (%s)%s.", last$label, fmt_date(last$date),
                                             if (length(r) > 1) sprintf(" and %d earlier round%s", length(r) - 1, if (length(r) > 2) "s" else "") else ""),
        redraw = redraw(),
        items = lapply(its, function(it) list(
          id = it$id, title = it$title, half = identical(it$width, "half"),
          source = if (identical(it$source, "pdm")) pdm$kind() else "Targeting process", dataset = it$dataset %||% "",
          display = if (identical(it$display, "table")) "table" else "chart",
          comment = rich_html(it$comment %||% "", empty = ""),
          # the suggestion, unless the comment already says it
          caption = if (nzchar(it$caption %||% "") && !grepl(it$caption, rich_text(it$comment %||% ""), fixed = TRUE)) it$caption else "")))
    })

    # --- saved with the session ------------------------------------------------------
    workspace_register(workspace, "monitoring",
      snapshot = function() {
        if (!length(datasets()) && !length(items()) && !length(previous_rounds()) &&
            !nzchar(paste0(input$context, input$findings, input$recommendations))) return(NULL)
        list(datasets = datasets(), active = input$pm_active, moda_forms = pm_forms(), items = items(),
             context = input$context, findings = input$findings, recommendations = input$recommendations,
             include_pdm = input$include_pdm, previous = previous_rounds(), template = input$tpl)
      },
      restore = function(s) {
        datasets(s$datasets %||% list()); items(s$items %||% list()); previous_rounds(s$previous %||% list())
        pm_forms(s$moda_forms %||% list())
        if (!is.null(s$template)) after_flush(session, function() updateSelectInput(session, "tpl", selected = s$template))
        updateSelectInput(session, "pm_active", choices = names(s$datasets %||% list()), selected = s$active)
        for (k in c("context", "findings", "recommendations")) update_rich_text(session, k, s[[k]] %||% "")
        if (!is.null(s$include_pdm)) updateCheckboxInput(session, "include_pdm", value = s$include_pdm)
      })
  })
}
