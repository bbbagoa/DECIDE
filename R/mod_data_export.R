#' Download the data as it is now (after cleaning), in several formats
#' (React: components/DataExport.tsx)
#'
#' One download per format: `<id>-xlsx` (read-only workbook, as every export,
#' with the Variables sheet), `<id>-sav` (SPSS), `<id>-dta` (Stata), `<id>-parquet`.
#' Variable labels from the session dictionary go into the SPSS and Stata files.
#' No CSV: a CSV cannot be protected (AGENTS.md, exports are read-only).
#' Each download is written to the audit trail.
#'
#' @param get_data A reactive (or function) returning the data frame.
#' @param name What the data is, for the file name and the audit trail.
#' @param log The app's modification log.
#' @noRd
mod_data_export_server <- function(id, get_data, name = "Data", log = NULL, phase = "Selection") {
  moduleServer(id, function(input, output, session) {
    stem <- gsub("[^A-Za-z0-9]+", "_", name)
    data_now <- function() {
      df <- tryCatch(get_data(), error = function(e) NULL)
      if (is.null(df) || !nrow(df)) stop("No data loaded yet.")
      as.data.frame(df)
    }
    labels_now <- function(cols) {
      l <- tryCatch(label_registry()$labels, error = function(e) NULL)
      if (is.null(l)) return(character(0))
      l <- l[names(l) %in% cols]
      l[!is.na(l) & nzchar(l)]
    }
    audit <- function(fmt, df) {
      audit_add(log, phase, "Data exported", sprintf("%s, %s rows x %s columns, %s", name,
                format(nrow(df), big.mark = ","), ncol(df), fmt))
    }
    # haven: names Stata accepts (32 characters, letters, digits, _), labels kept
    for_haven <- function(df, stata = FALSE) {
      labs <- labels_now(names(df))
      for (k in names(df)) {
        x <- df[[k]]
        if (is.list(x)) x <- vapply(x, function(v) paste(as.character(unlist(v)), collapse = ", "), "")
        if (is.factor(x)) x <- as.character(x)
        if (inherits(x, "POSIXlt")) x <- as.POSIXct(x)
        if (k %in% names(labs)) attr(x, "label") <- unname(labs[[k]])
        df[[k]] <- x
      }
      if (stata) {
        nm <- gsub("[^A-Za-z0-9_]", "_", names(df))
        nm <- ifelse(grepl("^[A-Za-z_]", nm), nm, paste0("v", nm))
        names(df) <- make.unique(substr(nm, 1, 32), sep = "_")
        # Stata strings: at most 2045 bytes each
        for (k in names(df)) if (is.character(df[[k]])) df[[k]] <- substr(df[[k]], 1, 2000)
      }
      df
    }
    output$xlsx <- download_handler(
      filename = function() export_file_name(stem, "xlsx"),
      content = function(file) {
        df <- data_now()
        if (nrow(df) > 1048575) stop("Too many rows for Excel (1,048,575 at most): download it as Parquet, SPSS or Stata.")
        write_xlsx_readonly(df, file, "Data")
        audit("Excel (read-only)", df)
      })
    output$sav <- download_handler(
      filename = function() export_file_name(stem, "sav"),
      content = function(file) { df <- data_now(); haven::write_sav(for_haven(df), file); audit("SPSS (.sav)", df) })
    output$dta <- download_handler(
      filename = function() export_file_name(stem, "dta"),
      content = function(file) { df <- data_now(); haven::write_dta(for_haven(df, stata = TRUE), file, version = 15); audit("Stata (.dta)", df) })
    output$parquet <- download_handler(
      filename = function() export_file_name(stem, "parquet"),
      content = function(file) {
        df <- data_now()
        for (k in names(df)) if (is.list(df[[k]])) df[[k]] <- vapply(df[[k]], function(v) paste(as.character(unlist(v)), collapse = ", "), "")
        nanoparquet::write_parquet(df, file)
        audit("Parquet", df)
      })
    for (k in c("xlsx", "sav", "dta", "parquet")) shiny::outputOptions(output, k, suspendWhenHidden = FALSE)
    invisible(NULL)
  })
}
