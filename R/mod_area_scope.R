#' Areas covered by an analysis
#'
#' The area pickers are not a targeting criterion: they set which part of the
#' data an analysis covers. Households outside the chosen areas leave the
#' analysis altogether (they are not counted as "not selected"), and every
#' report states the areas it covers.
#'
#' Used where the data has no variable mapping (Targeting Design, the PDM or
#' baseline analysis, targeting process): two levels, each a column of the
#' data and the areas to keep. Beneficiary Selection uses the mapped admin
#' levels instead, with `areas_covered_text()` for its reports.
#'
#' @param id module id
#' @noRd
mod_area_scope_ui <- function(id, title = "Areas covered") {
  ns <- NS(id)
  lvl <- function(k, label) tags$div(
    class = "wfp-scope-level",
    selectInput(ns(paste0("col", k)), paste(label, "column"), choices = c("(none)" = ""), width = "100%", selectize = FALSE),
    shinyWidgets::pickerInput(ns(paste0("val", k)), NULL, choices = character(0), multiple = TRUE, width = "100%",
                              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE,
                                                                    noneSelectedText = "All areas",
                                                                    selectedTextFormat = "count > 2")))
  tags$div(
    class = "wfp-scope",
    if (!is.null(title)) tags$div(class = "wfp-scope-head", bsicons::bs_icon("geo-alt"), " ", title,
             info_tip("Which part of the data this analysis covers. Households outside these areas are left out of the analysis entirely (they are not counted as not selected), and the reports say which areas are covered."))
    else tags$p(class = "small text-muted mb-2", "Leave empty to cover every area. Records outside the chosen areas are left out of this analysis and its report."),
    lvl(1, "First level"), lvl(2, "Second level"),
    tags$div(class = "d-flex gap-2",
             actionButton(ns("apply"), "Apply areas", icon = icon("filter"), class = "btn-outline-primary btn-sm flex-fill"),
             actionButton(ns("clear"), NULL, icon = icon("xmark"), class = "btn-outline-secondary btn-sm", title = "All areas")),
    tags$div(class = "small text-muted mt-1", textOutput(ns("status"), inline = TRUE))
  )
}

#' @param data Reactive: the full data (the scope never changes it).
#' @param workspace,key Optional: save the scope with the session.
#' @return list(filter = function(df), text = reactive(), applied = reactive())
#' @noRd
mod_area_scope_server <- function(id, data, workspace = NULL, key = NULL, log = NULL, phase = "Design") {
  moduleServer(id, function(input, output, session) {
    applied <- reactiveVal(list())    # list(list(col, values), ...)
    pending <- reactiveVal(NULL)      # a restored scope waiting for its data

    guesses <- list(c("admin1", "adm1", "province", "region", "state", "governorate", "departement", "department"),
                    c("admin2", "adm2", "district", "territoire", "territory", "county", "commune", "cercle", "lga"))
    observeEvent(data(), {
      df <- data(); req(df)
      cols <- names(df)
      keep <- cols[vapply(df, function(v) { k <- length(unique(v)); k >= 2 && k <= 500 }, logical(1))]
      for (k in 1:2) {
        cur <- isolate(input[[paste0("col", k)]])
        want <- pending()[[k]]$col %||% if (isTruthy(cur) && cur %in% keep) cur else find_guess(keep, guesses[[k]])
        updateSelectInput(session, paste0("col", k), choices = c("(none)" = "", keep),
                          selected = if (isTRUE(want %in% keep)) want else "")
      }
    })
    for (k in 1:2) local({
      kk <- k
      observeEvent(input[[paste0("col", kk)]], {
        df <- data(); cl <- input[[paste0("col", kk)]]
        ch <- if (!is.null(df) && isTruthy(cl) && cl %in% names(df)) sort(unique(as.character(stats::na.omit(df[[cl]])))) else character(0)
        sel <- intersect(pending()[[kk]]$values %||% character(0), ch)
        shinyWidgets::updatePickerInput(session, paste0("val", kk), choices = ch, selected = sel)
        if (kk == 2 && length(pending())) { applied(pending()); pending(NULL) }
      }, ignoreNULL = FALSE)
    })

    observeEvent(input$apply, {
      sc <- Filter(function(s) isTruthy(s$col) && length(s$values),
                   lapply(1:2, function(k) list(col = input[[paste0("col", k)]], values = input[[paste0("val", k)]])))
      applied(sc)
      audit_add(log, phase, "Areas covered set", scope_text(sc))
    })
    observeEvent(input$clear, {
      for (k in 1:2) shinyWidgets::updatePickerInput(session, paste0("val", k), selected = character(0))
      applied(list())
      audit_add(log, phase, "Areas covered set", "all areas")
    })

    filter <- function(df) {
      if (is.null(df)) return(df)
      keep <- rep(TRUE, nrow(df))
      for (s in applied()) if (s$col %in% names(df)) keep <- keep & as.character(df[[s$col]]) %in% s$values
      if (all(keep)) df else df[which(keep), , drop = FALSE]
    }
    text <- reactive(scope_text(applied()))
    output$status <- renderText({
      df <- data()
      if (is.null(df) || !length(applied())) return("All areas.")
      sprintf("%s (%s of %s records).", text(), format(nrow(filter(df)), big.mark = ","), format(nrow(df), big.mark = ","))
    })

    if (!is.null(key)) workspace_register(workspace, key,
      snapshot = function() if (length(applied())) list(scope = applied()) else NULL,
      restore = function(s) { pending(s$scope); applied(s$scope %||% list()) })

    list(filter = filter, text = text, applied = applied)
  })
}

#' A scope in words: "Province: Ituri, Nord-Kivu; Territoire: Beni" or "All areas"
#' @noRd
scope_text <- function(sc) {
  if (!length(sc)) return("All areas")
  paste(vapply(sc, function(s) sprintf("%s: %s", s$col, paste(s$values, collapse = ", ")), character(1)), collapse = "; ")
}

#' The areas covered by a Beneficiary Selection, from its mapped admin levels
#' @noRd
areas_covered_text <- function(applied) {
  lv <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3")
  parts <- Filter(Negate(is.null), lapply(names(lv), function(k) {
    v <- applied[[k]]
    if (length(v)) sprintf("%s: %s", lv[[k]], paste(v, collapse = ", "))
  }))
  if (length(parts)) paste(parts, collapse = "; ") else "All areas"
}
