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
          tags$span(bsicons::bs_icon("clock-history"), " Audit trail"),
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
mod_audit_server <- function(id, modification_log) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    shown <- reactive({
      dat <- modification_log()
      req(dat)
      dat <- data.frame(phase = audit_phase(dat$action), dat, stringsAsFactors = FALSE)
      if (!identical(input$phase %||% "All", "All")) dat <- dat[dat$phase == input$phase, , drop = FALSE]
      dat[order(dat$timestamp, decreasing = TRUE), , drop = FALSE]
    })

    # drawn by React (react/src/pages/audit/): same table, same input$phase
    output$tab_mod_log <- render_react_table({
      dat <- shown()
      # The Phase column says it already: the action without its "Phase: ".
      dat$action <- sub("^(Design|Selection|Monitoring|Session): ", "", dat$action)
      names(dat) <- c("Phase", "When", "Record", "Field", "Old value", "New value", "Action", "User", "Reason")[seq_along(dat)]
      # Columns empty in every row shown (most entries are decisions, not
      # edits of a value) are left out; the export keeps them all.
      empty <- vapply(dat, function(x) all(is.na(x) | !nzchar(trimws(as.character(x)))), logical(1))
      dat <- dat[, !empty | names(dat) %in% c("Phase", "When", "Action"), drop = FALSE]
      tw_datatable(dat, options = list(pageLength = 15, scrollX = TRUE,
                                        language = list(emptyTable = "Nothing logged yet.")),
                    rownames = FALSE)
    }, empty = "Nothing logged yet.")

    output$download_full_log <- download_handler(
      filename = function() {
        export_file_name("Targeting_Audit_Log", "xlsx", "%Y-%m-%d_%Hh%Mm%Ss")
      },
      content = function(file) {
        dat <- modification_log()
        if (!is.null(dat)) {
          dat <- data.frame(phase = audit_phase(dat$action), dat, stringsAsFactors = FALSE)
          dat$timestamp <- fmt_datetime(dat$timestamp)
        }
        write_xlsx_readonly(dat %||% data.frame(Message = "Nothing logged yet."), file, "Audit_trail")
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
