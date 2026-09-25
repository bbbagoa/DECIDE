#' The "Data imported" summary dialog
#'
#' Shown after every import (registration file or MODA, and the MODA imports
#' of the other pages): the source, four headline figures, data quality,
#' variable types, the first variables and, for a form server, what was done
#' with the form definition (`notes`: list of list(ok, text)).
#' @param footer The dialog's buttons.
#' @noRd
import_summary_modal <- function(df, label = "File upload", footer = modalButton("Continue with this data"), notes = NULL) {
  n_rows <- nrow(df)
  n_cols <- ncol(df)
  mem_size <- format(object.size(df), units = "auto", standard = "SI", digits = 1)

  # One pass over the columns with a single running row mask, so memory stays
  # O(rows) instead of materialising an n x p logical matrix (800 MB for a
  # 1M x 200 dataset).
  total_missing <- 0
  row_has_missing <- logical(n_rows)
  empty_cols <- 0L
  for (x in df) {
    m <- if (is.character(x)) is.na(x) | x == "" | x == "NULL" else is.na(x)
    k <- sum(m)
    total_missing <- total_missing + k
    if (n_rows > 0 && k == n_rows) empty_cols <- empty_cols + 1L
    row_has_missing <- row_has_missing | m
  }
  rows_with_missing <- sum(row_has_missing)

  # base duplicated() on a data.frame hashes column by column and scales
  # super-linearly (6.1 s at 200k x 60). data.table's forder does the same
  # job in 0.35 s -- measured 17x, identical counts -- so the old 50k cutoff,
  # which used to leave large imports with "not checked", is gone. The
  # remaining ceiling is memory: at ~1M rows this is still one full pass.
  dup_rows <- count_duplicate_rows(df)

  # Variable types in words.
  kind <- vapply(df, function(x) {
    if (inherits(x, c("Date", "POSIXt"))) "Dates" else if (is.factor(x)) "Categories"
    else if (is.logical(x)) "Yes / no" else if (is.numeric(x)) "Numbers"
    else if (is.character(x)) "Text" else "Other"
  }, character(1))
  kinds <- sort(table(kind), decreasing = TRUE)

  num <- function(v) format(v, big.mark = ",")
  pct <- function(a, b) if (b > 0) sprintf("%.1f%%", 100 * a / b) else "0%"
  stat <- function(label, value, sub = NULL) tags$div(
    class = "tw-imp-stat",
    tags$div(class = "tw-imp-label", label),
    tags$div(class = "tw-imp-value", value),
    if (!is.null(sub)) tags$div(class = "tw-imp-sub", sub))
  row <- function(label, value, flag = FALSE) tags$div(
    class = "tw-imp-row",
    tags$span(label),
    tags$span(class = if (flag) "tw-imp-flag" else NULL, value))
  shown <- utils::head(names(df), 14)
  src <- label

  modalDialog(
    title = tags$div(
      class = "tw-imp-head",
      tags$span(class = "tw-imp-icon", bsicons::bs_icon("check2")),
      tags$div(tags$div(class = "tw-imp-title", "Data imported"),
               tags$div(class = "tw-imp-source", src))
    ),
    size = "l",
    easyClose = FALSE,
    footer = footer,
    tags$div(
      class = "tw-imp",
      tags$div(
        class = "tw-imp-stats",
        stat("Records", num(n_rows)),
        stat("Variables", num(n_cols)),
        stat("Missing cells", num(total_missing), pct(total_missing, n_rows * n_cols)),
        stat("Size in memory", mem_size)
      ),
      # What was done with the form definition (MODA): labels, splits.
      if (length(notes)) tags$div(
        class = "tw-imp-panel tw-imp-notes mb-3",
        tags$div(class = "tw-imp-panel-title", "From the form"),
        lapply(notes, function(n) tags$div(
          class = paste("tw-imp-note-line", if (isTRUE(n$ok)) "is-ok" else "is-warn"),
          bsicons::bs_icon(if (isTRUE(n$ok)) "check-circle-fill" else "exclamation-triangle-fill"), " ", n$text))),
      tags$div(
        class = "tw-imp-cols",
        tags$div(
          class = "tw-imp-panel",
          tags$div(class = "tw-imp-panel-title", "Data quality"),
          row("Records with a missing answer", sprintf("%s (%s)", num(rows_with_missing), pct(rows_with_missing, n_rows))),
          row("Duplicate records",
              if (is.na(dup_rows)) "not checked" else num(dup_rows), flag = isTRUE(dup_rows > 0)),
          row("Empty variables", num(empty_cols), flag = empty_cols > 0),
          tags$div(class = "tw-imp-note", "Details and corrections: Data Quality, after the variable setup.")
        ),
        tags$div(
          class = "tw-imp-panel",
          tags$div(class = "tw-imp-panel-title", "Variable types"),
          lapply(names(kinds), function(k) row(k, num(as.integer(kinds[[k]]))))
        )
      ),
      tags$div(
        class = "tw-imp-panel mt-3",
        tags$div(class = "tw-imp-panel-title", "Variables"),
        tags$div(class = "tw-imp-chips",
                 lapply(shown, function(v) tags$span(class = "tw-imp-chip", v)),
                 if (n_cols > length(shown)) tags$span(class = "tw-imp-more", sprintf("+%s more", num(n_cols - length(shown)))))
      )
    )
  )
}
