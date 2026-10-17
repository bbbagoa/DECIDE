#' Audit Trail Module UI
#'
#' A page of its own: the log covers the whole app -- design decisions,
#' registration data changes, selection, monitoring and sessions.
#' @param id module id
#' @noRd
mod_audit_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::card(
      bslib::card_header(
        tags$div(
          class = "d-flex justify-content-between align-items-center gap-2 flex-wrap",
          tags$span(bsicons::bs_icon("clock-history"), " Activity log"),
          tags$div(
            class = "d-flex align-items-center gap-2",
            shinyWidgets::radioGroupButtons(
              ns("phase"), NULL, choices = c("All", audit_phases()), selected = "All",
              size = "sm", status = "outline-primary"
            ),
            downloadButton(ns("download_full_log"), "Export", class = "btn-outline-primary btn-sm")
          )
        )
      ),
      bslib::card_body(
        tags$p(class = "small text-muted mb-2",
               "Every change to the data and every decision, across the three phases: who, when, what and why."),
        DT::DTOutput(ns("tab_mod_log"), fill = FALSE)
      )
    )
  )
}

#' The phases an audit entry can belong to, in app order
#' @noRd
audit_phases <- function() c("Design", "Selection", "Monitoring", "Session")

#' Which phase an entry belongs to, from its action
#'
#' Entries written through `audit_add()` carry a "Phase: " prefix; the older
#' data-quality entries have none and belong to the registration data.
#' @noRd
audit_phase <- function(action) {
  p <- sub("^(Design|Selection|Monitoring|Session): .*$", "\\1", action)
  ifelse(p %in% audit_phases(), p, "Selection")
}

#' Audit Trail Module Server
#'
#' @param id module id
#' @param modification_log reactiveVal holding the log dataframe
#' @import shiny
#' @importFrom utils write.csv
#' @noRd
mod_audit_server <- function(id, modification_log, undo = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    steps <- function() if (is.null(undo)) list() else undo$steps()
    shown <- reactive({
      dat <- modification_log()
      req(dat)
      dat <- data.frame(phase = audit_phase(dat$action), dat, .row = seq_len(nrow(dat)), stringsAsFactors = FALSE)
      if (!identical(input$phase %||% "All", "All")) dat <- dat[dat$phase == input$phase, , drop = FALSE]
      dat[order(dat$timestamp, dat$.row, decreasing = TRUE), , drop = FALSE]
    })

    # drawn by React (react/src/pages/audit/): same table, same input$phase
    output$tab_mod_log <- render_react_table({
      dat <- shown()
      # Undo, on the last entry of each change made to the data in this session
      s <- steps()
      to <- vapply(s, function(x) x$to, integer(1)); ids <- vapply(s, function(x) x$id, integer(1))
      undo_col <- ifelse(dat$.row %in% to, sprintf(
        "<button type=\"button\" class=\"btn btn-sm btn-outline-secondary tw-undo-btn\" onclick=\"Shiny.setInputValue('%s', {id: %d, at: Date.now()}, {priority: 'event'})\">Undo</button>",
        ns("undo"), ids[match(dat$.row, to)]), "")
      dat$.row <- NULL
      # The Phase column says it already: the action without its "Phase: ".
      dat$action <- sub("^(Design|Selection|Monitoring|Session): ", "", dat$action)
      names(dat) <- c("Phase", "When", "Record", "Field", "Old value", "New value", "Action", "User", "Reason")[seq_along(dat)]
      # Columns empty in every row shown (most entries are decisions, not
      # edits of a value) are left out; the export keeps them all.
      empty <- vapply(dat, function(x) all(is.na(x) | !nzchar(trimws(as.character(x)))), logical(1))
      dat <- dat[, !empty | names(dat) %in% c("Phase", "When", "Action"), drop = FALSE]
      if (any(nzchar(undo_col))) dat$Undo <- undo_col
      tw_datatable(dat, options = list(pageLength = 15, scrollX = TRUE,
                                        language = list(emptyTable = "Nothing logged yet.")),
                    rownames = FALSE)
    }, html = "Undo", labels = list(Undo = ""), empty = "Nothing logged yet.")

    # Undo: say what goes back, then put the data as it was
    pending <- reactiveVal(NULL)
    observeEvent(input$undo, {
      id <- as.integer(input$undo$id); s <- steps()
      k <- which(vapply(s, function(x) x$id, integer(1)) == id)
      need_ok(length(k) == 1, "This change can no longer be undone.")
      later <- length(s) - k
      pending(id)
      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("arrow-counterclockwise"), " Undo a change"), size = "m", easyClose = TRUE,
        tags$p("The data goes back to what it was before:"),
        tags$p(tags$b(s[[k]]$action), tags$span(class = "text-muted", sprintf(" (logged %s)", s[[k]]$at))),
        if (later) tags$div(class = "alert alert-warning small py-2",
                            sprintf("The %d later change%s to the data will be undone too: %s.", later, if (later == 1) "" else "s",
                                    paste(vapply(s[(k + 1):length(s)], function(x) x$action, ""), collapse = "; "))),
        tags$p(class = "small text-muted", "The activity log keeps every entry and records the undo."),
        footer = tagList(modalButton("Cancel"), actionButton(ns("undo_ok"), "Undo", class = "btn-warning"))))
    })
    observeEvent(input$undo_ok, tw_guard("Undoing the change", {
      req(pending(), undo)
      undo$undo(pending()); pending(NULL); removeModal()
      showNotification("Change undone: the data is back as it was before it.", type = "message")
    }))

    # Quick insights: what was done, by phase and by kind, what can be undone
    output$audit_facts <- shinyreact::reactive_output({
      dat <- modification_log()
      if (is.null(dat) || !nrow(dat)) return(list(n = 0))
      act <- sub("^(Design|Selection|Monitoring|Session): ", "", dat$action)
      ph <- audit_phase(dat$action)
      edits <- sum(nzchar(trimws(as.character(dat$old_value %||% ""))) & !dat$column %in% c("", "ALL", "ALL_RECORD"), na.rm = TRUE)
      tab <- sort(table(act), decreasing = TRUE)
      list(n = nrow(dat), deleted = length(deleted_uids(dat)), edits = edits, undoable = length(steps()),
           phases = lapply(c("Design", "Selection", "Monitoring", "Session"), function(p) list(phase = p, n = sum(ph == p))),
           kinds = length(tab), last = as.character(max(dat$timestamp, na.rm = TRUE)))
    })
    output$audit_types_plot <- render_echart({
      dat <- modification_log(); req(dat, nrow(dat) > 0)
      act <- sub("^(Design|Selection|Monitoring|Session): ", "", dat$action)
      tab <- utils::head(sort(table(act), decreasing = TRUE), 10)
      opt <- list(
        tooltip = list(trigger = "axis", axisPointer = list(type = "shadow")),
        grid = list(left = 8, right = 18, top = 8, bottom = 8, containLabel = TRUE),
        xAxis = list(type = "value", minInterval = 1),
        yAxis = list(type = "category", data = names(tab), inverse = TRUE, axisLabel = list(width = 170, overflow = "truncate")),
        series = list(list(type = "bar", name = "Entries", data = as.integer(tab), barMaxWidth = 16,
                           itemStyle = list(color = "#007DBC", borderRadius = c(0, 3, 3, 0)))))
      attr(opt, "height") <- max(200, 40 + 24 * length(tab)); opt
    })

    output$download_full_log <- download_handler(
      filename = function() {
        export_file_name("Targeting_Activity_Log", "xlsx", "%Y-%m-%d_%Hh%Mm%Ss")
      },
      content = function(file) {
        dat <- modification_log()
        if (!is.null(dat)) {
          dat <- data.frame(phase = audit_phase(dat$action), dat, stringsAsFactors = FALSE)
          dat$timestamp <- fmt_datetime(dat$timestamp)
        }
        write_xlsx_readonly(dat %||% data.frame(Message = "Nothing logged yet."), file, "Activity_log")
      }
    )
  })
}

#' Add one entry to the audit trail
#'
#' @param log The app's `modification_log` reactiveVal (NULL: no-op, so a
#'   module works on its own in tests).
#' @param phase One of `audit_phases()`.
#' @param action What happened ("Scorecard adopted").
#' @param detail The new state, in words.
#' @noRd
audit_add <- function(log, phase, action, detail = "", column = "", reason = "", uid = "") {
  if (!is.function(log)) return(invisible(NULL))
  cur <- shiny::isolate(log())
  entry <- data.frame(timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = uid, column = column,
                      old_value = "", new_value = as.character(detail),
                      action = paste0(phase, ": ", action),
                      user = Sys.getenv("USERNAME", Sys.getenv("USER", "")), reason = reason,
                      stringsAsFactors = FALSE)
  if (is.null(cur)) { log(entry); return(invisible(NULL)) }
  for (nm in setdiff(names(cur), names(entry))) entry[[nm]] <- ""
  log(rbind(cur, entry[, names(cur), drop = FALSE]))
  invisible(NULL)
}

#' Record ids deleted during data cleaning, read from the audit trail
#' @noRd
deleted_uids <- function(log) {
  if (is.null(log) || !nrow(log)) return(character(0))
  del <- grepl("delet", log$action, ignore.case = TRUE) & !log$uid %in% c("", "BULK_DELETE", "(all rows)")
  unique(as.character(log$uid[del]))
}
