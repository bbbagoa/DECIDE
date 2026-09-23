#' Columns that identify a household in a record listing
#'
#' Record lists show who a row is, not everything about it: the mapped
#' administrative hierarchy (Admin 1 down to village) plus any name-like
#' columns. Everything else moves behind the per-row Details modal.
#'
#' @param df A data.frame to pick columns from.
#' @param settings Setup mapping (`reactiveValues` or plain list).
#' @param max_name_cols Maximum number of detected name columns to include.
#' @return A character vector of column names, in display order. Columns that
#'   are unmapped or absent from `df` are dropped.
#' @noRd
identification_cols <- function(df, settings, max_name_cols = 2) {
  if (is.null(df) || !is.data.frame(df) || ncol(df) == 0) return(character(0))

  keys <- c("unique_id", "admin1", "admin2", "admin3", "admin4", "village")
  mapped <- vapply(keys, function(k) {
    v <- tryCatch(settings[[k]], error = function(e) NULL)
    if (is.null(v) || !nzchar(as.character(v)[1])) NA_character_ else as.character(v)[1]
  }, character(1))
  cols <- unname(mapped[!is.na(mapped)])
  cols <- cols[cols %in% names(df)]

  # Name-like columns are not part of the setup mapping, so they are detected.
  # ODK metadata (_id, @_uuid, ...) is never a name.
  name_pat <- "(^|[._])(noms?|names?|prenoms?|firstname|lastname|surname|chef|beneficiaire)"
  cand <- grep(name_pat, names(df), ignore.case = TRUE, value = TRUE, perl = TRUE)
  cand <- cand[!grepl("^@?_", cand)]
  cand <- setdiff(cand, cols)

  # A column mapped to an ANALYTICAL setup key is not an identifier. Without
  # this, `nom_enqueteur` (mapped to enumerator_id) matches on its "nom" prefix
  # and crowds out the household's own name.
  analytic_keys <- c("enumerator_id", "hhh_sex", "hhh_age", "hh_size", "v_score",
                     "v_groups", "eligibility", "residency", "childU5",
                     "disability", "weight", "date", "lon", "lat")
  analytic <- vapply(analytic_keys, function(k) {
    v <- tryCatch(settings[[k]], error = function(e) NULL)
    if (is.null(v) || !nzchar(as.character(v)[1])) NA_character_ else as.character(v)[1]
  }, character(1))
  cand <- setdiff(cand, unname(analytic[!is.na(analytic)]))

  # Whoever ran the interview is not who the row is about: rank survey-staff
  # names last so the household's name wins the limited slots.
  staff_pat <- "(enqueteur|enumerat|agent|surveyor|interviewer|supervis)"
  is_staff <- grepl(staff_pat, cand, ignore.case = TRUE, perl = TRUE)
  cand <- c(cand[!is_staff], cand[is_staff])

  unique(c(cols, utils::head(cand, max_name_cols)))
}

#' HTML for the per-row Details buttons
#'
#' Each button hands its row key back to Shiny as an input event. The key is
#' HTML-escaped and its quotes are entity-encoded, so an apostrophe in a value
#' cannot break out of the onclick handler.
#'
#' @param keys Character vector of row keys (unique id, or row position).
#' @param input_id Fully namespaced input id to set.
#' @return A character vector of HTML button markup.
#' @noRd
record_detail_buttons <- function(keys, input_id) {
  safe <- gsub("'", "&#39;", htmltools::htmlEscape(as.character(keys)), fixed = TRUE)
  sprintf(
    paste0("<button type='button' class='wfp-details-btn' title='Open this record' ",
           "onclick=\"Shiny.setInputValue('%s', '%s', {priority:'event'})\">",
           # eye, label, chevron (inline SVG: no icon font needed inside DT)
           "<svg viewBox='0 0 16 16' aria-hidden='true'><path d='M1 8s2.6-4.5 7-4.5S15 8 15 8s-2.6 4.5-7 4.5S1 8 1 8z' ",
           "fill='none' stroke='currentColor' stroke-width='1.4'/><circle cx='8' cy='8' r='2' fill='currentColor'/></svg>",
           "<span>Details</span>",
           "<svg class='wfp-details-chev' viewBox='0 0 16 16' aria-hidden='true'><path d='M6 3.5 10.5 8 6 12.5' ",
           "fill='none' stroke='currentColor' stroke-width='1.6' stroke-linecap='round' stroke-linejoin='round'/></svg>",
           "</button>"),
    input_id, safe
  )
}

#' Render a record listing trimmed to its identifying columns
#'
#' @param df A data.frame of records.
#' @param settings Setup mapping.
#' @param ns Namespace function (pass `session$ns`, not an ambient `ns`).
#' @param view_id Input id the Details buttons should set.
#' @param extra_cols Extra columns to keep alongside the identifiers.
#' @param page_length Rows per page.
#' @return A `DT::datatable`.
#' @noRd
record_table <- function(df, settings, ns, view_id, extra_cols = character(0),
                         page_length = 20) {
  id_cols <- identification_cols(df, settings)
  extra_cols <- intersect(extra_cols, names(df))
  show <- unique(c(id_cols, extra_cols))
  # Never render an empty grid: fall back to the first few columns.
  if (length(show) == 0) show <- utils::head(names(df), 5)

  out <- df[, show, drop = FALSE]
  out[] <- lapply(out, as.character)

  uid <- tryCatch(settings$unique_id, error = function(e) NULL)
  keys <- if (!is.null(uid) && nzchar(uid) && uid %in% names(df)) {
    as.character(df[[uid]])
  } else {
    as.character(seq_len(nrow(df)))
  }
  out[["Details"]] <- record_detail_buttons(keys, ns(view_id))

  DT::datatable(
    out,
    rownames = FALSE,
    escape = FALSE,       # the Details column is markup
    selection = "none",
    options = list(
      pageLength = page_length,
      scrollX = TRUE,
      columnDefs = list(list(orderable = FALSE, searchable = FALSE,
                             targets = ncol(out) - 1L))
    )
  )
}

#' Locate the record a Details button refers to
#'
#' Matches on the mapped unique id when there is one (stable across sorting and
#' re-rendering), and falls back to row position otherwise.
#'
#' @param df The data.frame the table was rendered from.
#' @param settings Setup mapping.
#' @param key The value emitted by the Details button.
#' @return A one-row data.frame, or a zero-row frame when nothing matches.
#' @noRd
find_record <- function(df, settings, key) {
  if (is.null(df) || !is.data.frame(df) || nrow(df) == 0 || is.null(key)) {
    return(df[0, , drop = FALSE])
  }
  uid <- tryCatch(settings$unique_id, error = function(e) NULL)
  hit <- if (!is.null(uid) && nzchar(uid) && uid %in% names(df)) {
    df[which(as.character(df[[uid]]) == as.character(key)), , drop = FALSE]
  } else {
    idx <- suppressWarnings(as.integer(key))
    if (is.na(idx) || idx < 1 || idx > nrow(df)) df[0, , drop = FALSE] else df[idx, , drop = FALSE]
  }
  utils::head(hit, 1)
}

#' A modal showing every field of one record
#'
#' Survey fields come first; ODK/MODA metadata is tucked into a collapsed
#' section so it does not bury the substance.
#'
#' @param row A one-row data.frame.
#' @param title Modal title.
#' @return A `modalDialog`.
#' @noRd
record_detail_modal <- function(row, title = "Record details") {
  if (is.null(row) || !is.data.frame(row) || nrow(row) == 0) {
    return(modalDialog(
      title = title, size = "m", easyClose = TRUE,
      footer = modalButton("Close"),
      empty_state("Record not found",
                  "It may have been edited or removed since this list was drawn.",
                  icon = "question-circle")
    ))
  }

  vals <- vapply(names(row), function(nm) {
    v <- row[[nm]][1]
    v <- as.character(v)
    if (length(v) == 0 || is.na(v) || !nzchar(trimws(v))) "\u2014" else v
  }, character(1))

  is_meta <- grepl("^@?_", names(vals))

  grid <- function(keys) {
    if (length(keys) == 0) return(NULL)
    tags$div(
      class = "wfp-record-detail",
      lapply(keys, function(nm) {
        tags$div(
          class = "wfp-record-field",
          tags$div(class = "wfp-record-label", nm),
          tags$div(class = "wfp-record-value", vals[[nm]])
        )
      })
    )
  }

  modalDialog(
    title = title,
    size = "l",
    easyClose = TRUE,
    footer = modalButton("Close"),
    grid(names(vals)[!is_meta]),
    if (any(is_meta)) {
      tags$details(
        class = "mt-3",
        tags$summary(class = "text-muted small", "Form metadata"),
        grid(names(vals)[is_meta])
      )
    }
  )
}


#' Formatted Excel sheets for exports
#'
#' `xl_summary_sheet()` writes a title block and labelled sections (field /
#' value pairs); `xl_data_sheet()` writes a table with a styled header, frozen
#' first row, filters and column widths fitted to the content.
#' @noRd
xl_summary_sheet <- function(wb, sheet, title, subtitle, sections) {
  openxlsx::addWorksheet(wb, sheet, gridLines = FALSE)
  s_title <- openxlsx::createStyle(fontSize = 16, textDecoration = "bold", fontColour = "#0A6EB4")
  s_sub <- openxlsx::createStyle(fontSize = 10, fontColour = "#5B6B7E")
  s_sec <- openxlsx::createStyle(fontSize = 10, textDecoration = "bold", fontColour = "#FFFFFF", fgFill = "#0A6EB4")
  s_key <- openxlsx::createStyle(fontSize = 10, fontColour = "#5B6B7E", valign = "top",
                                 border = "bottom", borderColour = "#DFE6EE")
  s_val <- openxlsx::createStyle(fontSize = 10, wrapText = TRUE, valign = "top",
                                 border = "bottom", borderColour = "#DFE6EE")
  openxlsx::writeData(wb, sheet, export_text(title), startRow = 1, startCol = 1)
  openxlsx::addStyle(wb, sheet, s_title, rows = 1, cols = 1)
  openxlsx::writeData(wb, sheet, export_text(subtitle), startRow = 2, startCol = 1)
  openxlsx::addStyle(wb, sheet, s_sub, rows = 2, cols = 1)
  r <- 4
  for (nm in names(sections)) {
    openxlsx::writeData(wb, sheet, export_text(nm), startRow = r, startCol = 1)
    openxlsx::writeData(wb, sheet, "", startRow = r, startCol = 2)
    openxlsx::addStyle(wb, sheet, s_sec, rows = r, cols = 1:2)
    kv <- sections[[nm]]
    d <- data.frame(Field = names(kv), Value = unname(as.character(kv)), stringsAsFactors = FALSE)
    openxlsx::writeData(wb, sheet, export_text(d), startRow = r + 1, startCol = 1, colNames = FALSE)
    rows <- (r + 1):(r + nrow(d))
    openxlsx::addStyle(wb, sheet, s_key, rows = rows, cols = 1, gridExpand = TRUE)
    openxlsx::addStyle(wb, sheet, s_val, rows = rows, cols = 2, gridExpand = TRUE)
    r <- r + nrow(d) + 2
  }
  openxlsx::setColWidths(wb, sheet, cols = 1:2, widths = c(34, 90))
  invisible(wb)
}

#' @noRd
xl_data_sheet <- function(wb, sheet, df) {
  openxlsx::addWorksheet(wb, sheet)
  head <- openxlsx::createStyle(fontSize = 10, textDecoration = "bold", fontColour = "#FFFFFF",
                                fgFill = "#0A6EB4", border = "bottom", borderColour = "#085A93",
                                halign = "left", valign = "center")
  write_data(wb, sheet, df, headerStyle = head, withFilter = TRUE)
  openxlsx::freezePane(wb, sheet, firstRow = TRUE)
  openxlsx::setRowHeights(wb, sheet, rows = 1, heights = 22)
  if (nrow(df)) {
    openxlsx::addStyle(wb, sheet, openxlsx::createStyle(fontSize = 10), rows = 2:(nrow(df) + 1),
                       cols = seq_along(df), gridExpand = TRUE)
  }
  # widths from the header and the first rows, capped so free text stays readable
  w <- vapply(seq_along(df), function(j) {
    v <- utils::head(as.character(df[[j]]), 200)
    min(45, max(10, nchar(names(df)[j]) + 2, suppressWarnings(max(nchar(v), na.rm = TRUE)) + 2))
  }, numeric(1))
  openxlsx::setColWidths(wb, sheet, cols = seq_along(df), widths = w)
  invisible(wb)
}

#' Text made safe for any export
#'
#' Every exported table passes through here so names like "C\u00f4te d'Ivoire",
#' Arabic or Cyrillic place names survive the trip to Excel or CSV:
#' labelled SPSS/Stata values become their labels, factors become text, all
#' text is re-encoded to UTF-8 (bytes that cannot be, typically from an old
#' Latin-1 file, are dropped rather than breaking the file), control
#' characters that make an .xlsx unreadable are removed, and cells are cut at
#' Excel's 32,767-character limit.
#' @noRd
export_text <- function(x) {
  clean <- function(v) {
    v <- enc2utf8(as.character(v))
    bad <- !is.na(v) & !validUTF8(v)
    if (any(bad)) v[bad] <- iconv(v[bad], "latin1", "UTF-8", sub = "")
    v <- gsub("[\x01-\x08\x0B\x0C\x0E-\x1F\x7F]", "", v, perl = TRUE)
    long <- !is.na(v) & nchar(v) > 32767
    if (any(long)) v[long] <- substr(v[long], 1, 32767)
    v
  }
  if (!is.data.frame(x)) return(if (is.character(x) || is.factor(x)) clean(x) else x)
  x[] <- lapply(x, function(col) {
    if (inherits(col, "haven_labelled")) col <- haven::as_factor(col)
    if (is.factor(col) || is.character(col)) clean(col) else col
  })
  names(x) <- clean(names(x))
  x
}

#' A CSV that Excel opens with every accent intact: UTF-8 with a byte-order mark
#' @noRd
write_csv_utf8 <- function(df, file) {
  data.table::fwrite(export_text(as.data.frame(df)), file, bom = TRUE, na = "")
  invisible(file)
}
