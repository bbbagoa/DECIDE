#' Variable and value labels
#'
#' SPSS / Stata files carry a label per variable ("Sex of the head of
#' household") and labels for coded values (1 = Male). MODA forms carry the
#' same in their XLSForm (question labels, choice labels). The app works on
#' column names, so the labels are kept in one dictionary per browser session
#' (`register_labels()`): column attributes alone are lost at the first row
#' filter. The dictionary is saved with the sessions, sent to the browser
#' (www/labels.js shows "name - label" in pickers and table headers), and
#' written as a Variables sheet in the Excel exports and a Variables section
#' in the reports.
#' @noRd
NULL

#' Labelled SPSS / Stata columns as plain R columns
#'
#' A column becomes a category only when every value it holds has a label
#' (sex 1/2 -> Male/Female). A number with a few labelled codes (age, with
#' 99 = "Don't know") stays a number: turning it into a category made the
#' setup ask to force it back to numbers, and hid the 99 code. Either way the
#' variable label stays on the column (`label`) and the value labels are kept
#' as `tw_codes` (named: label -> code).
#' @noRd
labelled_to_plain <- function(df) {
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  for (k in seq_along(df)) {
    x <- df[[k]]
    lab <- attr(x, "label", exact = TRUE)
    vals <- attr(x, "labels", exact = TRUE)
    if (inherits(x, "haven_labelled")) {
      v <- unclass(x)
      attributes(v) <- NULL
      has <- !is.na(v)
      if (length(vals) && all(v[has] %in% vals)) {
        out <- factor(match(v, vals), levels = seq_along(vals), labels = names(vals))
        # labels no household carries are dropped, as haven::as_factor does
        out <- droplevels(out)
      } else {
        out <- v
      }
      if (length(vals)) attr(out, "tw_codes") <- vals
      if (!is.null(lab)) attr(out, "label") <- as.character(lab)[1]
      df[[k]] <- out
    } else if (!is.null(lab)) {
      attr(df[[k]], "format.spss") <- NULL
      attr(df[[k]], "format.stata") <- NULL
    }
  }
  df
}

#' Variable labels and value labels carried by a data frame's columns
#' @return list(labels = named character, codes = named list)
#' @noRd
labels_of <- function(df) {
  if (is.null(df) || !ncol(df)) return(list(labels = character(0), codes = list()))
  lab <- vapply(df, function(x) {
    l <- attr(x, "label", exact = TRUE)
    if (is.null(l) || !length(l) || is.na(l[1]) || !nzchar(trimws(l[1]))) NA_character_ else trimws(as.character(l[1]))
  }, character(1))
  codes <- lapply(df, function(x) attr(x, "tw_codes", exact = TRUE))
  codes <- codes[!vapply(codes, is.null, logical(1))]
  list(labels = lab[!is.na(lab)], codes = codes, cols = names(df))
}

#' The session's label dictionary (root session userData)
#' @noRd
label_registry <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) return(list(labels = character(0), codes = list()))
  root <- tryCatch(session$rootScope(), error = function(e) session)
  root$userData$tw_labels %||% list(labels = character(0), codes = list())
}

#' Add the labels of `df` (or given ones) to the session's dictionary and
#' send them to the browser. Outside a session it does nothing.
#' @noRd
register_labels <- function(df = NULL, session = shiny::getDefaultReactiveDomain(), add = NULL) {
  if (is.null(session)) return(invisible(NULL))
  root <- tryCatch(session$rootScope(), error = function(e) session)
  new <- add %||% labels_of(df)
  if (!length(new$labels) && !length(new$codes) && !length(new$cols)) return(invisible(NULL))
  reg <- label_registry(root)
  if (length(new$labels)) reg$labels[names(new$labels)] <- new$labels
  if (length(new$codes)) reg$codes[names(new$codes)] <- new$codes
  reg$cols <- unique(c(reg$cols, new$cols))
  root$userData$tw_labels <- reg
  root$sendCustomMessage("tw-labels", list(labels = as.list(reg$labels), cols = as.list(reg$cols)))
  invisible(NULL)
}

#' A column's label, or NA
#' @noRd
var_label <- function(col, session = shiny::getDefaultReactiveDomain()) {
  l <- label_registry(session)$labels
  unname(ifelse(col %in% names(l), l[col], NA_character_))
}

#' Answers of a column for a dropdown: "1 - Yes" when the value has a code
#'
#' The values stay what the app works with (the labels); only the text shown
#' carries the code, from the session's dictionary.
#' @noRd
value_choices <- function(values, col, session = shiny::getDefaultReactiveDomain()) {
  values <- as.character(values)
  if (!length(values)) return(values)
  codes <- if (is.null(col) || !nzchar(col %||% "")) NULL else label_registry(session)$codes[[col]]
  if (is.null(codes) || !length(codes)) return(values)
  code <- unname(codes[values])
  stats::setNames(values, ifelse(is.na(code), values, paste(code, "-", values)))
}

#' "1 = Male; 2 = Female"
#' @noRd
codes_text <- function(codes) {
  if (is.null(codes) || !length(codes)) return("")
  paste(sprintf("%s = %s", unname(codes), names(codes)), collapse = "; ")
}

#' The dictionary for some columns: name, label, value labels
#' @return data.frame, or NULL when none of the columns has a label.
#' @noRd
variables_table <- function(cols, session = shiny::getDefaultReactiveDomain()) {
  reg <- label_registry(session)
  cols <- unique(as.character(cols))
  has <- cols %in% c(names(reg$labels), names(reg$codes))
  if (!any(has)) return(NULL)
  data.frame(Variable = cols,
             Label = ifelse(cols %in% names(reg$labels), reg$labels[cols], ""),
             `Value labels` = vapply(cols, function(k) codes_text(reg$codes[[k]]), character(1)),
             check.names = FALSE, stringsAsFactors = FALSE, row.names = NULL)
}

#' Add a Variables sheet (name, label, value labels) to an export workbook
#' @noRd
xl_variables_sheet <- function(wb, cols, session = shiny::getDefaultReactiveDomain()) {
  v <- variables_table(cols, session)
  if (is.null(v) || "Variables" %in% names(wb)) return(invisible(wb))
  xl_data_sheet(wb, "Variables", v)
  invisible(wb)
}

#' The Variables section of a report (Markdown), or NULL
#' @noRd
variables_md <- function(cols, session = shiny::getDefaultReactiveDomain(), title = "## Variables") {
  v <- variables_table(cols, session)
  if (is.null(v)) return(NULL)
  c(title, "", "The variables this report uses, with their labels from the data or the form.", "", md_table(v), "")
}
