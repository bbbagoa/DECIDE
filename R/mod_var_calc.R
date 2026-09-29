#' Variable calculator module
#'
#' A button that opens a dialog for building a new column from conditions
#' (yes/no) or a formula (numeric), with a preview before anything changes.
#' Used at both import points: registration data and assessment data.
#'
#' @param id module id
#' @param label Button label.
#' @noRd
mod_var_calc_ui <- function(id, label = "Variable calculator",
                            class = "btn-outline-primary btn-sm") {
  ns <- NS(id)
  actionButton(ns("open"), label, icon = icon("calculator"), class = class)
}

#' The calculator opened on bulk binarise (best split for vulnerability when
#' the server has an outcome)
#' @noRd
mod_var_calc_bulk_ui <- function(id, label = "Binarise variables",
                                 class = "btn-outline-secondary btn-sm") {
  ns <- NS(id)
  actionButton(ns("open_bulk"), label, icon = icon("wand-magic-sparkles"), class = class)
}

#' @param get_data Reactive returning the data frame.
#' @param set_data Function taking the updated data frame.
#' @param log Optional reactiveVal holding the modification log.
#' @param outcome Optional reactive returning list(y = 1/0 outcome, col = its
#'   column), or NULL: bulk binarise can then find each column's best split
#'   for vulnerability (`screen_variables()`).
#' @noRd
mod_var_calc_server <- function(id, get_data, set_data, log = NULL, phase = "Selection", outcome = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    n_cond <- reactiveVal(1L)
    # What was built and how, for the design report.
    created <- reactiveVal(data.frame(name = character(0), definition = character(0),
                                      created = character(0), stringsAsFactors = FALSE))

    cols <- reactive({
      df <- get_data()
      if (is.null(df)) character(0) else names(df)
    })

    get_outcome <- function() if (is.null(outcome)) NULL else tryCatch(outcome(), error = function(e) NULL)
    # A binarised variable is labelled after its source: "<source label>: <rule>"
    # (the source name when it has no label), so it reads in every picker.
    label_new <- function(new, src, rule) {
      lab <- var_label(src); lab <- ifelse(is.na(lab) | !nzchar(lab), src, lab)
      register_labels(add = list(labels = stats::setNames(paste0(lab, ": ", rule), new), codes = list(), cols = new))
    }
    opt_res <- reactiveVal(NULL)   # the last best-split preview

    open_modal <- function(type = "condition") {
      if (is.null(get_data())) {
        showNotification("Load the data first; the calculator adds columns to it.", type = "warning")
        return()
      }
      n_cond(1L); opt_res(NULL)
      has_y <- !is.null(get_outcome())
      bulk <- identical(type, "bulk")
      showModal(modalDialog(
        title = if (bulk) tagList(bsicons::bs_icon("magic"), " Binarise variables")
                else tagList(bsicons::bs_icon("calculator"), " Variable calculator"),
        size = if (bulk) "xl" else "l", easyClose = FALSE,
        footer = tagList(
          modalButton("Close"),
          actionButton(ns("preview"), "Preview", icon = icon("eye"), class = "btn-outline-primary"),
          actionButton(ns("create"), if (bulk) "Create variables" else "Create variable", icon = icon("plus"), class = "btn-primary")
        ),
        # Opened as "Binarise variables", the calculator's other modes stay out of sight.
        tags$div(style = if (bulk) "display: none;", bslib::layout_columns(
          col_widths = c(5, 4, 3), fill = FALSE,
          conditionalPanel(
            condition = sprintf("input['%s'] !== 'bulk'", ns("type")),
            textInput(ns("name"), "New variable name", placeholder = "e.g. Targ_HHDepRatio2plus", width = "100%")),
          radioButtons(ns("type"), "Build from",
                       choices = c("Conditions (yes/no)" = "condition", "Formula" = "formula",
                                   "R code" = "code", "Bulk binarise" = "bulk"),
                       selected = type, inline = TRUE),
          tags$div(class = "pt-4", checkboxInput(ns("replace"), "Replace if it exists", FALSE))
        )),
        conditionalPanel(
          condition = sprintf("input['%s'] === 'condition'", ns("type")),
          uiOutput(ns("cond_rows")),
          tags$div(
            class = "d-flex flex-wrap gap-3 align-items-end mt-2",
            actionButton(ns("add_cond"), "Add condition", icon = icon("plus"),
                         class = "btn-outline-secondary btn-sm"),
            radioButtons(ns("combine"), NULL, inline = TRUE,
                         choices = c("All must hold (AND)" = "all", "Any may hold (OR)" = "any")),
            radioButtons(ns("coding"), NULL, inline = TRUE,
                         choices = c("Code as 1 / 0" = "10", "Code as Yes / No" = "yesno"))
          ),
          tags$div(class = "small text-muted mt-1",
                   "Separate several values with commas for 'is one of'. A household with a missing value gets a missing result, not 'no'.")
        ),
        conditionalPanel(
          condition = sprintf("input['%s'] === 'formula'", ns("type")),
          bslib::layout_columns(
            col_widths = c(8, 4), fill = FALSE,
            textAreaInput(ns("formula"), "Formula", rows = 3, width = "100%",
                          placeholder = "e.g. (n_children + n_elderly) / pmax(n_adults, 1)"),
            tags$div(
              selectInput(ns("insert_col"), "Insert a column", choices = c("", cols()),
                          selectize = FALSE, width = "100%") |>
                tagAppendAttributes(
                  onchange = sprintf(
                    "var t=document.getElementById('%s'); var v=this.value; if(!v) return; var s=t.selectionStart||t.value.length; t.value=t.value.slice(0,s)+v+t.value.slice(s); t.dispatchEvent(new Event('input',{bubbles:true})); t.focus(); this.value='';",
                    ns("formula")), .cssSelector = "select")
            )
          ),
          tags$div(class = "small text-muted",
                   "Allowed: + - * / ^, comparisons, & | !, ifelse, is.na, round, abs, sqrt, log, pmin, pmax, ",
                   "rowSums(cbind(a, b), na.rm = TRUE), cut(x, breaks = c(0, 3, 6, Inf)), %in%. ",
                   "Column names only; no other functions.")
        ),
        # R code: several lines with intermediate variables, checked against
        # the same kind of whitelist as a formula before anything runs.
        conditionalPanel(
          condition = sprintf("input['%s'] === 'code'", ns("type")),
          textAreaInput(ns("code"), "R code", rows = 8, width = "100%",
                        placeholder = paste("dep <- n_children + n_elderly",
                                            "ratio <- dep / pmax(n_adults, 1)",
                                            "ratio[is.na(ratio)] <- 0",
                                            "ifelse(ratio >= 2, 1, 0)   # the last line is the new column", sep = "\n")) |>
            tagAppendAttributes(class = "font-monospace", .cssSelector = "textarea"),
          tags$div(class = "small text-muted",
                   "Paste R code working on the columns by name. Use intermediate variables (", tags$code("x <- ..."),
                   ", ", tags$code("x[cond] <- ..."), ") and ", tags$code("if / else"), "; the last line gives the new column. ",
                   "The formula functions are allowed, plus paste, paste0, grepl, sub, gsub, substr, quantile. ",
                   "No loops, no function definitions, no package calls: the code runs on the server, so anything that ",
                   "could reach files, the network or other code is refused.")
        ),
        # Bulk: many columns at once, one yes/no variable each: the best split
        # for vulnerability (needs the outcome), or one rule for all.
        conditionalPanel(
          condition = sprintf("input['%s'] === 'bulk'", ns("type")),
          shinyWidgets::radioGroupButtons(
            ns("bulk_method"), NULL, status = "outline-primary", justified = TRUE,
            choices = c(if (has_y) c("Best split for vulnerability" = "optimal"),
                        "One yes/no per answer" = "each", "Same rule for every column" = "rule"),
            selected = if (has_y) "optimal" else "rule"),
          conditionalPanel(
            condition = sprintf("input['%s'] === 'each'", ns("bulk_method")),
            tags$div(class = "small text-muted mb-2",
                     "For each column, one yes/no variable per answer (roof_Metal, roof_Thatch...): the way a question with several answers",
                     " enters a regression such as a proxy means test, or a scorecard. Columns with more than 30 answers are left out",
                     " (numbers, names and free text are not categories)."),
            checkboxInput(ns("bulk_ref"),
                          tagList("Leave out the most common answer (reference)",
                                  info_tip("A model with an intercept cannot estimate every answer of a question: one is left out and the others read against it. Keep this ticked for the proxy means test and the scorecard models; untick it to get every answer, e.g. for a ranking by deprivation counting.")),
                          value = TRUE)),
          if (has_y) conditionalPanel(
            condition = sprintf("input['%s'] === 'optimal'", ns("bulk_method")),
            tags$div(class = "small text-muted mb-2",
                     "For each column, the yes/no version that separates vulnerable households best: for a number, the cut-off with the largest gap in",
                     " vulnerability (each side at least 5% of the households); for 3 to 15 answers, the answers where vulnerability is above average.",
                     " Preview, untick what you do not want, and create: the new variables join the Criteria table.")),
          bslib::layout_columns(
            col_widths = c(8, 4), fill = FALSE,
            shinyWidgets::pickerInput(
              ns("bulk_cols"), "Columns to binarise", choices = cols(), multiple = TRUE, width = "100%",
              options = shinyWidgets::pickerOptions(container = "body", actionsBox = TRUE, liveSearch = TRUE,
                                                    selectedTextFormat = "count > 4")),
            tags$div(
              class = "wfp-inline-action",
              tags$label(class = "form-label", "Pick by name"),
              tags$div(class = "d-flex gap-2",
                       textInput(ns("bulk_match"), NULL, placeholder = "e.g. asset_", width = "100%"),
                       actionButton(ns("bulk_pick"), "Select matching", class = "btn-outline-secondary"))
            )
          ),
          if (has_y) conditionalPanel(
            condition = sprintf("input['%s'] === 'optimal'", ns("bulk_method")),
            tags$div(
              class = "d-flex flex-wrap align-items-center gap-2 mb-2",
              actionButton(ns("bulk_screen_all"), "Screen the entire database", icon = icon("magnifying-glass-chart"),
                           class = "btn-outline-primary btn-sm"),
              tags$span(class = "small text-muted",
                        "Every column that is not yes/no yet (outcome indicators and what cannot be observed at registration left out), with the best cut-off for each."))),
          conditionalPanel(
            condition = sprintf("input['%s'] === 'rule'", ns("bulk_method")),
            uiOutput(ns("bulk_hint"), class = "wfp-calc-hint"),
            bslib::layout_columns(
              col_widths = c(3, 4, 5), fill = FALSE,
              selectInput(ns("bulk_op"), "Rule", choices = calc_operators(), selected = "==",
                          width = "100%", selectize = FALSE),
              textInput(ns("bulk_val"), "Value", width = "100%"),
              tags$div())),
          bslib::layout_columns(
            col_widths = c(5, 7), fill = FALSE,
            conditionalPanel(
              condition = sprintf("input['%s'] !== 'each'", ns("bulk_method")),
              textInput(ns("bulk_suffix"),
                        tagList("New names end with", info_tip("Each new variable is named after its source column, followed by this ending, e.g. asset_radio_Bin (best split: hh_size_ge7_Bin). One yes/no per answer names them column_answer.")),
                        value = "_Bin", width = "100%")),
            tags$div(class = "pt-4", radioButtons(ns("bulk_coding"), NULL, inline = TRUE,
                         choices = c("Code as 1 / 0" = "10", "Code as Yes / No" = "yesno"),
                         selected = if (has_y) "yesno" else "10"))),
          conditionalPanel(
            condition = sprintf("input['%s'] === 'rule'", ns("bulk_method")),
            tags$div(class = "small text-muted",
                     "The same rule is applied to every selected column, e.g. 'equals Yes' on a block of asset questions, or 'at least 1' on counts. ",
                     "A missing value gives a missing result."))
        ),
        tags$hr(),
        uiOutput(ns("preview_ui")),
        tags$script(HTML(
          "window.wfpCalcPick = function(el, valId, opId) {
             var v = el.getAttribute('data-value'); var t = document.getElementById(valId);
             var op = (document.getElementById(opId) || {}).value;
             if ((op === 'in' || op === 'not_in') && t.value.trim()) {
               var parts = t.value.split(',').map(function(x){return x.trim()});
               if (parts.indexOf(v) < 0) t.value = t.value.replace(/[ ,]*$/, '') + ', ' + v;
             } else { t.value = v; }
             t.dispatchEvent(new Event('input', {bubbles: true})); t.dispatchEvent(new Event('change', {bubbles: true}));
           };"))
      ))
    }
    observeEvent(input$open, open_modal("condition"))
    observeEvent(input$open_bulk, open_modal("bulk"))
    optimal <- function() identical(input$type, "bulk") && identical(input$bulk_method, "optimal") && !is.null(get_outcome())

    # Every column that could become a yes/no criterion.
    non_binary <- function() {
      df <- get_data(); o <- get_outcome()
      cs <- setdiff(names(df), c(o$col, names(df)[startsWith(names(df), "_")]))
      cs[vapply(cs, function(cl) is.null(as_binary_criterion(df[[cl]])) && length(unique(stats::na.omit(df[[cl]]))) >= 3, logical(1))]
    }
    # Screen the entire database: select those columns and preview their best
    # splits in one go.
    observeEvent(input$bulk_screen_all, {
      cs <- non_binary()
      if (!length(cs)) { showNotification("Every column is yes/no already.", type = "message"); return() }
      shinyWidgets::updatePickerInput(session, "bulk_cols", selected = cs)
      d <- tryCatch(opt_compute(cs), error = function(e) e)
      if (inherits(d, "error")) {
        opt_res(NULL)
        output$preview_ui <- renderUI(tags$div(class = "alert alert-danger small mb-0", conditionMessage(d)))
        return()
      }
      opt_res(d)
      output$preview_ui <- renderUI(opt_table(d))
    })

    # Best split per selected column, against the outcome.
    opt_compute <- function(cs = input$bulk_cols) {
      df <- get_data(); o <- get_outcome()
      cs <- setdiff(intersect(cs %||% character(0), names(df)), o$col)
      if (!length(cs)) stop("Select the columns to binarise.", call. = FALSE)
      d <- screen_variables(df[, cs, drop = FALSE], o$y)
      d <- if (is.null(d)) NULL else d[d$kind != "yes/no", , drop = FALSE]
      if (is.null(d) || !nrow(d)) stop("None of the selected columns has a split that separates vulnerable households: they are yes/no already, constant, or not observable at registration.", call. = FALSE)
      suffix <- input$bulk_suffix %||% "_Bin"
      taken <- names(df)
      d$new_name <- vapply(seq_len(nrow(d)), function(i) {
        nm <- screen_new_name(d$variable[i], d$rule[[i]], taken, suffix = suffix); taken <<- c(taken, nm); nm
      }, character(1))
      attr(d, "skipped") <- setdiff(cs, d$variable)
      d
    }
    opt_table <- function(d) {
      pct <- function(v) sprintf("%.0f%%", 100 * v)
      skipped <- attr(d, "skipped")
      tagList(
        tags$div(class = "small fw-bold text-uppercase mb-1", sprintf("Preview: %d suggested yes/no variables", nrow(d))),
        tags$div(class = "wfp-model-table-wrap", tags$table(
          class = "wfp-model-table wfp-binarise-table",
          tags$thead(tags$tr(tags$th("Create"), tags$th("Yes/no version"), tags$th(class = "num", "Households yes"),
                             tags$th(class = "num", "Vulnerable if yes"), tags$th(class = "num", "if no"),
                             tags$th(class = "num", "Gap (pts)"), tags$th("Strength"))),
          tags$tbody(lapply(seq_len(nrow(d)), function(i) tags$tr(
            tags$td(class = "text-center", checkboxInput(ns(paste0("opt_use_", i)), NULL, value = d$strength[i] != "Not significant")),
            tags$td(tags$strong(d$new_name[i]), tags$div(class = "small text-muted", d$suggestion[i]),
                    if (nzchar(d$detail[i])) tags$div(class = "small text-muted", title = d$detail[i], "Answers: ", substr(d$detail[i], 1, 90),
                                                      if (nchar(d$detail[i]) > 90) "...")),
            tags$td(class = "num", pct(d$yes_share[i])),
            tags$td(class = "num", pct(d$vuln_yes[i])),
            tags$td(class = "num", pct(d$vuln_no[i])),
            tags$td(class = "num", sprintf("%+.0f", 100 * d$gap[i])),
            tags$td(class = paste("small fw-semibold", switch(d$strength[i], Strong = "text-success", Moderate = "text-primary",
                                                               Weak = "text-warning", "text-muted")), d$strength[i])))))),
        if (length(skipped)) tags$div(class = "small text-muted mt-1",
                                      sprintf("No suggestion for %d column(s) (already yes/no, constant, not observable, or no clear split): %s.",
                                              length(skipped), paste(utils::head(skipped, 15), collapse = ", ")),
                                      if (length(skipped) > 15) " ..."),
        tags$div(class = "small text-muted mt-1", "Ticked by default: the splits with a significant gap (chi-square p < 0.05).")
      )
    }

    observeEvent(input$add_cond, n_cond(min(n_cond() + 1L, 8L)))

    output$cond_rows <- renderUI({
      k <- n_cond()
      ops <- calc_operators()
      lapply(seq_len(k), function(i) tagList(
        bslib::layout_columns(
          col_widths = c(5, 3, 4), fill = FALSE,
          selectInput(ns(paste0("c_col_", i)), if (i == 1) "Column" else NULL,
                      choices = c("Choose a column" = "", cols()),
                      selected = isolate(input[[paste0("c_col_", i)]]) %||% "", width = "100%"),
          selectInput(ns(paste0("c_op_", i)), if (i == 1) "Test" else NULL, choices = ops,
                      selected = isolate(input[[paste0("c_op_", i)]]) %||% "==",
                      width = "100%", selectize = FALSE),
          textInput(ns(paste0("c_val_", i)), if (i == 1) "Value" else NULL,
                    value = isolate(input[[paste0("c_val_", i)]]) %||% "", width = "100%")
        ),
        uiOutput(ns(paste0("c_hint_", i)), class = "wfp-calc-hint")
      ))
    })

    # What the chosen column holds: its categories (click one to use it) or
    # its range, so the value is typed against the data rather than guessed.
    lapply(1:8, function(i) {
      output[[paste0("c_hint_", i)]] <- renderUI({
        col <- input[[paste0("c_col_", i)]]
        df <- get_data()
        if (!shiny::isTruthy(col) || is.null(df) || !col %in% names(df)) return(NULL)
        column_hint(df[[col]], ns(paste0("c_val_", i)), ns(paste0("c_op_", i)))
      })
    })

    observeEvent(input$bulk_pick, {
      pat <- trimws(input$bulk_match %||% "")
      if (!nzchar(pat)) return()
      hit <- grep(pat, cols(), fixed = TRUE, value = TRUE)
      shinyWidgets::updatePickerInput(session, "bulk_cols", selected = union(input$bulk_cols, hit))
      if (!length(hit)) showNotification(sprintf("No column name contains '%s'.", pat), type = "warning")
    })

    # What the selected columns hold together: their shared values (click to
    # use) or, when all numeric, their combined range.
    # counted on request: picking columns computes nothing
    hint_for <- reactiveVal(character(0))
    observeEvent(input$bulk_hint_go, hint_for(input$bulk_cols %||% character(0)))
    output$bulk_hint <- renderUI({
      df <- get_data(); cs <- intersect(input$bulk_cols %||% character(0), names(df))
      if (!length(cs)) return(NULL)
      if (!setequal(cs, intersect(hint_for(), names(df))))
        return(tags$div(class = "small", actionLink(ns("bulk_hint_go"), tagList(bsicons::bs_icon("tags"), " Show the values of these columns"))))
      if (all(vapply(df[cs], is.numeric, logical(1)))) {
        return(column_hint(unlist(df[cs], use.names = FALSE), ns("bulk_val"), ns("bulk_op")))
      }
      column_hint(unlist(lapply(df[cs], as.character), use.names = FALSE), ns("bulk_val"), ns("bulk_op"))
    })

    bulk_compute <- function() {
      df <- get_data()
      cs <- intersect(input$bulk_cols %||% character(0), names(df))
      if (!length(cs)) stop("Select the columns to binarise.", call. = FALSE)
      if (identical(input$bulk_method, "each")) {
        r <- calc_dummies(df, cs, reference = !isFALSE(input$bulk_ref), coding = input$bulk_coding %||% "10")
        if (!length(r$names)) stop("None of these columns has 2 to 30 answers.", call. = FALSE)
        clash <- intersect(r$names, names(df))
        if (length(clash) && !isTRUE(input$replace))
          stop("Already exist: ", paste(clash, collapse = ", "), ". Tick 'Replace if it exists'.", call. = FALSE)
        r$rule <- paste("=", r$answers)
        r$note <- if (length(r$skipped)) sprintf("Left out (fewer than 2 or more than 30 answers): %s.", paste(r$skipped, collapse = ", "))
        return(r)
      }
      # source name + ending, made valid (spaces, slashes, a leading digit)
      nms <- make.names(paste0(cs, input$bulk_suffix %||% "_Bin"))
      clash <- intersect(nms, names(df))
      if (length(clash) && !isTRUE(input$replace)) {
        stop("Already exist: ", paste(clash, collapse = ", "), ". Tick 'Replace if it exists' or change the ending.",
             call. = FALSE)
      }
      vals <- lapply(cs, function(cl) calc_condition(df, list(list(column = cl, op = input$bulk_op %||% "==",
                                                                    value = input$bulk_val %||% "")),
                                                     "all", input$bulk_coding %||% "10"))
      lab <- stats::setNames(names(calc_operators()), calc_operators())[[input$bulk_op %||% "=="]]
      rule <- if (input$bulk_op %in% c("is_missing", "not_missing")) lab else paste(lab, input$bulk_val)
      list(names = nms, values = vals, sources = cs, rule = rule,
           descriptions = sprintf("Bulk: %s %s", cs, rule))
    }

    conditions <- function() {
      lapply(seq_len(n_cond()), function(i) list(
        column = input[[paste0("c_col_", i)]], op = input[[paste0("c_op_", i)]] %||% "==",
        value = input[[paste0("c_val_", i)]] %||% ""))
    }

    # Returns list(values, description) or stops with a readable message.
    compute <- function() {
      df <- get_data()
      if (identical(input$type, "code")) {
        txt <- trimws(input$code %||% "")
        if (!nzchar(txt)) stop("Paste or write the R code.", call. = FALSE)
        return(list(values = calc_code(df, txt),
                    description = paste("R code:", gsub("\\s*\n\\s*", "; ", txt))))
      }
      if (identical(input$type, "formula")) {
        txt <- trimws(input$formula %||% "")
        if (!nzchar(txt)) stop("Write a formula.", call. = FALSE)
        list(values = calc_formula(df, txt), description = paste("Formula:", txt))
      } else {
        cn <- Filter(function(x) shiny::isTruthy(x$column), conditions())
        list(values = calc_condition(df, cn, input$combine %||% "all", input$coding %||% "10"),
             description = paste("Condition:", calc_describe_condition(cn, input$combine %||% "all")))
      }
    }

    summary_ui <- function(v, name) {
      miss <- sum(is.na(v))
      body <- if (is.numeric(v) && length(unique(stats::na.omit(v))) > 10) {
        q <- stats::quantile(v, c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
        tags$div(class = "small", sprintf("Min %.3g \u00b7 Q1 %.3g \u00b7 median %.3g \u00b7 Q3 %.3g \u00b7 max %.3g \u00b7 mean %.3g",
                                          q[1], q[2], q[3], q[4], q[5], mean(v, na.rm = TRUE)))
      } else {
        tb <- sort(table(v, useNA = "no"), decreasing = TRUE)
        tb <- utils::head(tb, 10)
        tags$table(class = "wfp-model-table", tags$thead(tags$tr(tags$th("Value"), tags$th(class = "num", "Households"), tags$th(class = "num", "Share"))),
                   tags$tbody(lapply(names(tb), function(k) tags$tr(
                     tags$td(k), tags$td(class = "num", format(tb[[k]], big.mark = ",")),
                     tags$td(class = "num", sprintf("%.1f%%", 100 * tb[[k]] / length(v)))))))
      }
      tagList(
        tags$div(class = "small fw-bold text-uppercase mb-1", "Preview of ", tags$code(name)),
        tags$div(class = "wfp-model-table-wrap p-2", body),
        tags$div(class = if (miss > 0) "small text-warning mt-1" else "small text-muted mt-1",
                 sprintf("%s of %s households missing.", format(miss, big.mark = ","), format(length(v), big.mark = ",")))
      )
    }

    # Computed once per click, from the inputs as they are at that moment.
    observeEvent(input$preview, {
      if (optimal()) {
        d <- tryCatch(opt_compute(), error = function(e) e)
        if (inherits(d, "error")) {
          opt_res(NULL)
          output$preview_ui <- renderUI(tags$div(class = "alert alert-danger small mb-0", conditionMessage(d)))
          return()
        }
        opt_res(d)
        output$preview_ui <- renderUI(opt_table(d))
        return()
      }
      if (identical(input$type, "bulk")) {
        r <- tryCatch(bulk_compute(), error = function(e) e)
        ui <- if (inherits(r, "error")) tags$div(class = "alert alert-danger small mb-0", conditionMessage(r)) else {
          yes <- function(v) mean(v %in% c(1, "Yes"), na.rm = TRUE)
          tagList(
            tags$div(class = "small fw-bold text-uppercase mb-1", sprintf("Preview: %d new variables", length(r$names))),
            if (!is.null(r$note)) tags$div(class = "small text-warning mb-1", r$note),
            tags$div(class = "wfp-model-table-wrap", tags$table(
              class = "wfp-model-table",
              tags$thead(tags$tr(tags$th("New variable"), tags$th("Rule"), tags$th(class = "num", "Meets it"),
                                 tags$th(class = "num", "Missing"))),
              tags$tbody(lapply(seq_along(r$names), function(i) tags$tr(
                tags$td(tags$strong(r$names[i])), tags$td(class = "small text-muted", sub("^Bulk: ", "", r$descriptions[i])),
                tags$td(class = "num", sprintf("%.1f%%", 100 * yes(r$values[[i]][!is.na(r$values[[i]])]))),
                tags$td(class = "num", format(sum(is.na(r$values[[i]])), big.mark = ",")))))))
          )
        }
        output$preview_ui <- renderUI(ui)
        return()
      }
      r <- tryCatch(compute(), error = function(e) e)
      nm <- trimws(input$name %||% "")
      ui <- if (inherits(r, "error")) tags$div(class = "alert alert-danger small mb-0", conditionMessage(r))
            else summary_ui(r$values, if (nzchar(nm)) nm else "new variable")
      output$preview_ui <- renderUI(ui)
    })

    observeEvent(input$create, {
      df <- get_data()
      if (optimal()) {
        d <- opt_res()
        if (is.null(d)) {
          # show what will be created first
          d <- tryCatch(opt_compute(), error = function(e) e)
          if (inherits(d, "error")) {
            output$preview_ui <- renderUI(tags$div(class = "alert alert-danger small mb-0", conditionMessage(d)))
          } else {
            opt_res(d); output$preview_ui <- renderUI(opt_table(d))
          }
          return()
        }
        use <- vapply(seq_len(nrow(d)), function(i) {
          v <- input[[paste0("opt_use_", i)]]
          if (is.null(v)) d$strength[i] != "Not significant" else isTRUE(v)
        }, logical(1))
        d <- d[use, , drop = FALSE]
        if (!nrow(d)) { showNotification("Tick at least one variable to create.", type = "warning"); return() }
        conds <- lapply(seq_len(nrow(d)), function(i) list(list(column = d$variable[i], op = d$rule[[i]]$op, value = d$rule[[i]]$value)))
        desc <- vapply(conds, function(cn) paste("Best split:", calc_describe_condition(cn)), character(1))
        for (i in seq_len(nrow(d))) df[[d$new_name[i]]] <- calc_condition(df, conds[[i]], "all", input$bulk_coding %||% "yesno")
        set_data(df)
        label_new(d$new_name, d$variable, vapply(seq_len(nrow(d)), function(i) {
          r <- d$rule[[i]]; if (identical(r$op, ">=")) paste("at least", r$value) else paste(strsplit(r$value, ",")[[1]], collapse = " or ")
        }, character(1)))
        now <- format(Sys.time(), "%Y-%m-%d %H:%M")
        created(rbind(created()[!created()$name %in% d$new_name, , drop = FALSE],
                      data.frame(name = d$new_name, definition = desc, created = now, stringsAsFactors = FALSE)))
        if (!is.null(log)) {
          entry <- data.frame(
            timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = "(all rows)",
            column = d$new_name, old_value = "", new_value = desc,
            action = paste0(phase, ": Variable created"), user = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
            reason = "Binarise: best split for vulnerability", stringsAsFactors = FALSE)
          log(rbind(log(), entry[, names(log()), drop = FALSE]))
        }
        removeModal()
        showNotification(sprintf("%d yes/no variable%s created (%s): they are in the Criteria table.", nrow(d),
                                 if (nrow(d) == 1) "" else "s", paste(d$new_name, collapse = ", ")),
                         type = "message", duration = 8)
        return()
      }
      if (identical(input$type, "bulk")) {
        r <- tryCatch(bulk_compute(), error = function(e) e)
        if (inherits(r, "error")) {
          output$preview_ui <- renderUI(tags$div(class = "alert alert-danger small mb-0", conditionMessage(r)))
          return()
        }
        for (i in seq_along(r$names)) df[[r$names[i]]] <- r$values[[i]]
        set_data(df)
        label_new(r$names, r$sources, r$rule)
        now <- format(Sys.time(), "%Y-%m-%d %H:%M")
        created(rbind(created()[!created()$name %in% r$names, , drop = FALSE],
                      data.frame(name = r$names, definition = r$descriptions, created = now,
                                 stringsAsFactors = FALSE)))
        if (!is.null(log)) {
          entry <- data.frame(
            timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = "(all rows)",
            column = r$names, old_value = "", new_value = r$descriptions,
            action = paste0(phase, ": Variable created"), user = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
            reason = "Variable calculator (bulk)", stringsAsFactors = FALSE)
          log(rbind(log(), entry[, names(log()), drop = FALSE]))
        }
        removeModal()
        showNotification(sprintf("%d variables created (%s...).", length(r$names), r$names[1]),
                         type = "message", duration = 8)
        return()
      }
      res <- tryCatch({
        nm <- calc_check_name(input$name, names(df), input$replace)
        r <- compute()
        list(name = nm, r = r)
      }, error = function(e) e)
      if (inherits(res, "error")) {
        output$preview_ui <- renderUI(tags$div(class = "alert alert-danger small mb-0", conditionMessage(res)))
        return()
      }
      df[[res$name]] <- res$r$values
      set_data(df)
      created(rbind(created()[created()$name != res$name, , drop = FALSE],
                    data.frame(name = res$name, definition = res$r$description,
                               created = format(Sys.time(), "%Y-%m-%d %H:%M"),
                               stringsAsFactors = FALSE)))
      if (!is.null(log)) {
        entry <- data.frame(
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = "(all rows)",
          column = res$name, old_value = if (isTRUE(input$replace) && res$name %in% names(get_data())) "(column overwritten)" else "", new_value = res$r$description,
          action = paste0(phase, ": Variable created"), user = Sys.getenv("USERNAME", Sys.getenv("USER", "")),
          reason = "Variable calculator", stringsAsFactors = FALSE)
        log(rbind(log(), entry[, names(log()), drop = FALSE]))
      }
      removeModal()
      showNotification(sprintf("'%s' added (%s).", res$name, res$r$description),
                       type = "message", duration = 8)
    })

    created
  })
}

#' Categories or range of a column, for the calculator's condition rows
#'
#' Numeric columns show their range and quartiles (and, when they take few
#' values, those values as chips); anything else shows its most frequent
#' values as chips that fill the Value box when clicked.
#' @noRd
column_hint <- function(x, val_id, op_id, max_values = 20) {
  if (is.factor(x)) x <- as.character(x)
  miss <- sum(is.na(x) | (is.character(x) & trimws(x) == ""))
  miss_txt <- if (miss) sprintf(" \u00b7 %s missing", format(miss, big.mark = ",")) else ""
  range_line <- NULL
  if (is.numeric(x) && any(!is.na(x))) {
    q <- stats::quantile(x, c(0, .25, .5, .75, 1), na.rm = TRUE, names = FALSE)
    range_line <- tags$div(
      class = "small text-muted",
      bsicons::bs_icon("rulers"),
      sprintf(" Numeric \u00b7 range %s to %s \u00b7 Q1 %s \u00b7 median %s \u00b7 Q3 %s \u00b7 mean %s%s",
              format(q[1], digits = 4), format(q[5], digits = 4), format(q[2], digits = 4),
              format(q[3], digits = 4), format(q[4], digits = 4),
              format(mean(x, na.rm = TRUE), digits = 4), miss_txt))
    if (length(unique(stats::na.omit(x))) > 12) return(range_line)
    x <- x[order(x)]
  }
  tb <- table(as.character(x), useNA = "no")
  tb <- if (is.numeric(x)) tb[order(as.numeric(names(tb)))] else sort(tb, decreasing = TRUE)
  shown <- utils::head(tb, max_values)
  tagList(range_line, tags$div(
    class = "small text-muted",
    bsicons::bs_icon("tags"),
    sprintf(" %d %s%s \u2014 click to use: ", length(tb), if (is.numeric(x)) "values" else "categories",
            if (is.null(range_line)) miss_txt else ""),
    lapply(names(shown), function(v) tags$button(
      type = "button", class = "wfp-calc-chip", `data-value` = v,
      onclick = sprintf("wfpCalcPick(this, '%s', '%s')", val_id, op_id),
      v, tags$span(class = "wfp-calc-chip-n", format(shown[[v]], big.mark = ",")))),
    if (length(tb) > max_values) tags$span(sprintf(" +%d more", length(tb) - max_values))
  ))
}
