#' Food security indicators: the dialog that calculates them (Targeting Design)
#'
#' Opened by the "Food security indicators" button of the Vulnerability
#' Framework step (React: StepFramework.tsx, input `<ns>-open`). Lists FCS,
#' rCSI, LCS-FS, LCS-EN, FES and CARI with what each needs from the WFP data
#' dictionary; only those whose variables are in the data can be ticked.
#' Compute adds WFP's columns to the assessment data (whole data, not the
#' covered areas), labels them, lists them with the calculated variables
#' (design report, session) and writes the audit trail. The calculations are
#' `fsi_compute()` (R/utils_fs_indicators.R).
#'
#' @param get_data,set_data The assessment data (whole).
#' @param log The app's modification log.
#' @param created The calculator's table of created variables (a reactiveVal
#'   with name, definition, created), or NULL.
#' @noRd
mod_fs_indicators_server <- function(id, get_data, set_data, log = NULL, created = NULL, phase = "Design") {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$open, {
      req(input$open > 0)   # a React button sends 0 at start
      df <- get_data()
      need_ok(!is.null(df), "Load the data first: the indicators are calculated from it.")
      showModal(fsi_dialog(ns, fsi_status(df), names(df)))
    })

    observeEvent(input$compute, tw_guard("Calculating the indicators", {
      req(input$compute > 0)
      df <- get_data()
      need_ok(!is.null(df), "Load the data first.")
      st <- fsi_status(df)
      which <- names(FSI_DEFS)[vapply(names(FSI_DEFS), function(k) isTRUE(st[[k]]$ok) && isTRUE(input[[paste0("use_", k)]]), logical(1))]
      need_ok(length(which) > 0, "Tick at least one indicator to calculate.")
      ver <- input$cari_version %||% "FES"
      res <- tryCatch(
        fsi_compute(df, which, fcs_threshold = input$fcs_threshold %||% "21", cari_version = ver,
                    meb = suppressWarnings(as.numeric(input$meb)), smeb = suppressWarnings(as.numeric(input$smeb)),
                    hh_size = input$hh_size, cari_binary = !isFALSE(input$cari_binary)),
        error = function(e) e)
      if (inherits(res, "error")) {
        showNotification(conditionMessage(res), type = "error", duration = 8)
        return()
      }
      set_data(res$df)
      register_labels(add = list(labels = res$labels, codes = list(), cols = names(res$labels)))
      if (is.function(created)) {
        cur <- created()
        add <- data.frame(name = res$created$name, definition = res$created$definition,
                          created = format(Sys.time(), "%Y-%m-%d %H:%M"), stringsAsFactors = FALSE)
        keep <- if (is.null(cur)) NULL else cur[!cur$name %in% add$name, , drop = FALSE]
        created(if (is.null(keep)) add else rbind(keep, add[, names(keep), drop = FALSE]))
      }
      labs <- vapply(which, function(k) FSI_DEFS[[k]]$label, "")
      audit_add(log, phase, "Food security indicators calculated",
                sprintf("%s. Columns: %s. Definitions: WFP RAM standardized scripts (%s).%s",
                        paste(labs, collapse = "; "), paste(res$created$name, collapse = ", "), FSI_SOURCE,
                        if ("cari" %in% which) paste0(" CARI version: ", ver, if (identical(ver, "ECMEN"))
                          sprintf(" (MEB %s, SMEB %s per person per month)", input$meb, input$smeb) else "", ".") else ""))
      showModal(fsi_result_dialog(res, which))
    }))
  })
}

#' The dialog: each indicator, what it needs, the options
#' @noRd
fsi_dialog <- function(ns, st, cols) {
  short <- function(x, n = 8) if (length(x) <= n) paste(x, collapse = ", ") else paste0(paste(x[seq_len(n)], collapse = ", "), sprintf(" and %d more", length(x) - n))
  row <- function(k) {
    s <- st[[k]]; d <- FSI_DEFS[[k]]
    status <- if (isTRUE(s$ok)) {
      tags$div(class = "small text-success", bsicons::bs_icon("check-circle"), " ",
               if (length(s$note)) s$note else "The variables it needs are in the data.")
    } else {
      tags$div(class = "small text-danger", bsicons::bs_icon("x-circle"), " Not in the data: ", tags$code(short(s$missing)))
    }
    extra <- tagList(
      if (isTRUE(s$ok) && length(s$optional))
        tags$div(class = "small text-muted", sprintf("%d gift / aid or own-production column(s) are not in the data: counted as 0 (%s).",
                                                     length(s$optional), short(s$optional, 3))),
      if (isTRUE(s$ok) && length(s$replace))
        tags$div(class = "small text-warning", bsicons::bs_icon("exclamation-triangle"), " Already in the data, will be recalculated: ",
                 paste(s$replace, collapse = ", "))
    )
    tags$div(class = paste("tw-fsi-row", if (!isTRUE(s$ok)) "tw-fsi-off"),
      if (isTRUE(s$ok)) checkboxInput(ns(paste0("use_", k)), tags$strong(d$label), value = k %in% c("fcs", "rcsi", "lcs_fs", "fes", "cari"))
      else tags$div(class = "fw-semibold text-muted mb-1", d$label),
      tags$div(class = "small text-muted mb-1", d$about),
      status, extra)
  }
  cari_ok <- isTRUE(st$cari$ok)
  versions <- c(if (isTRUE(st$cari$parts$fes)) c("With the food expenditure share (FES)" = "FES"),
                if (isTRUE(st$cari$parts$ecmen)) c("With economic capacity (ECMEN, needs the MEB)" = "ECMEN"))
  has_flags <- !is.na(fsi_col(cols, "ECMEN_exclAsst")) && !is.na(fsi_col(cols, "ECMEN_exclAsst_SMEB"))
  size_guess <- fsi_col(cols, "HHSize")
  if (is.na(size_guess)) size_guess <- cols[grepl("hh_?size|household_?size|taille", cols, ignore.case = TRUE)][1]
  modalDialog(
    title = tagList(bsicons::bs_icon("basket"), " Food security indicators"),
    size = "l", easyClose = FALSE,
    footer = tagList(modalButton("Cancel"),
                     actionButton(ns("compute"), "Calculate", icon = icon("calculator"), class = "btn-primary")),
    tags$p(class = "small",
           "Calculated as in WFP's standardized scripts (RAM, October 2025 versions), from the variables named in the WFP data dictionary. ",
           "An indicator can be ticked only when its variables are in the data. The new columns are added to the data; ",
           "each has a yes / no version you can choose as the outcome (Targeting Design) or as who was eligible (Monitoring). ",
           tags$a(href = FSI_SOURCE, target = "_blank", "WFP scripts and dictionary")),
    tags$div(class = "tw-fsi-list", lapply(names(FSI_DEFS), row)),
    tags$hr(),
    tags$div(class = "row g-3",
      tags$div(class = "col-md-6",
        radioButtons(ns("fcs_threshold"), "FCS thresholds",
                     choices = c("21 / 35 (standard)" = "21", "28 / 42 (sugar and oil eaten almost daily)" = "28"),
                     selected = "21")),
      if (cari_ok && length(versions)) tags$div(class = "col-md-6",
        radioButtons(ns("cari_version"), "CARI version", choices = versions, selected = versions[1]),
        checkboxInput(ns("cari_binary"), "Binary food insecurity: food insecure = moderately + severely food insecure", value = TRUE))),
    if (cari_ok && "ECMEN" %in% versions) conditionalPanel(
      condition = sprintf("input['%s'] === 'ECMEN'", ns("cari_version")),
      if (has_flags) tags$p(class = "small text-muted", "ECMEN_exclAsst and ECMEN_exclAsst_SMEB are in the data: they are used as they are.")
      else tags$div(class = "row g-3",
        tags$div(class = "col-md-4", numericInput(ns("meb"), "MEB per person per month", value = NA, min = 0)),
        tags$div(class = "col-md-4", numericInput(ns("smeb"), "SMEB per person per month", value = NA, min = 0)),
        tags$div(class = "col-md-4", selectInput(ns("hh_size"), "Household size", choices = cols, selected = size_guess)),
        tags$p(class = "small text-muted col-12 mb-0",
               "Expenditure per person excluding assistance (food purchases and own production, non-food purchases, less the cash assistance consumed), compared with the MEB and the SMEB, in the survey's currency.")))
  )
}

#' After the calculation: what each indicator gives
#' @noRd
fsi_result_dialog <- function(res, which) {
  tbl <- function(d) {
    tot <- sum(d$households)
    tags$table(class = "table table-sm mb-2", style = "max-width: 460px;",
      tags$thead(tags$tr(tags$th("Category"), tags$th(class = "text-end", "Households"), tags$th(class = "text-end", "%"))),
      tags$tbody(lapply(seq_len(nrow(d)), function(i) tags$tr(
        tags$td(d$category[i]), tags$td(class = "text-end", format(d$households[i], big.mark = ",")),
        tags$td(class = "text-end", if (tot) sprintf("%.1f", 100 * d$households[i] / tot) else "")))))
  }
  yn <- res$created$name[grepl("(_PoorBorderline|_Phase3plus|_CrisisEmergency|^FES_High|_2class)$", res$created$name)]
  cari2 <- res$created$name[grepl("^CARI_.*_2class$", res$created$name)]
  modalDialog(
    title = tagList(bsicons::bs_icon("check-circle"), " Food security indicators calculated"),
    size = "l", easyClose = TRUE, footer = modalButton("Close"),
    lapply(intersect(names(FSI_DEFS), which), function(k) if (!is.null(res$summary[[k]])) tagList(
      tags$h6(class = "mt-2", FSI_DEFS[[k]]$label), tbl(res$summary[[k]]),
      if (k == "cari" && !is.null(res$summary$cari_binary)) tagList(
        tags$h6(class = "mt-2", "CARI, binary food insecurity (moderately + severely food insecure)"), tbl(res$summary$cari_binary)))),
    if (length(res$notes)) tags$div(class = "alert alert-warning small py-2", lapply(res$notes, tags$div)),
    tags$p(class = "small mb-1", tags$strong("Columns added: "), paste(res$created$name, collapse = ", ")),
    if (length(yn)) tags$p(class = "small text-muted mb-0",
      "To use one as the outcome, choose it in 'Outcome variable' (for example ", tags$code(if (length(cari2)) cari2[1] else yn[length(yn)]),
      if (length(cari2)) ") with 'Food insecure' as the vulnerable level, then Validate." else ") with 'Yes' as the vulnerable level, then Validate.")
  )
}
