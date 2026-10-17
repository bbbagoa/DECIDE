# Dates in every workbook written by the app: day / month / year (unless the
# user's own R session already chose a format).
.onLoad <- function(libname, pkgname) {
  if (is.null(getOption("openxlsx.dateFormat"))) options(openxlsx.dateFormat = "dd/mm/yyyy")
  if (is.null(getOption("openxlsx.datetimeFormat"))) options(openxlsx.datetimeFormat = "dd/mm/yyyy hh:mm")
  # Which installation this R session loaded, to notice an update made since
  tw_state$built <- tw_build_stamp()
  # React inputs (react/src/lib/inputs.tsx): vectors as Shiny's own inputs send them
  tw_register_input_handlers()
  invisible()
}

tw_state <- new.env(parent = emptyenv())

#' When the installed package was built (the `Built` field, read from disk),
#' or NA when it runs from source (`load_all()`)
#' @noRd
tw_build_stamp <- function() {
  b <- tryCatch(utils::packageDescription("DECIDE", fields = "Built"), error = function(e) NA_character_)
  if (length(b) != 1 || is.na(b)) NA_character_ else b
}

#' TRUE when DECIDE was reinstalled after this R session loaded it: the
#' session would run the old code (and break when it reads the new files)
#' @noRd
tw_updated_since_load <- function() {
  was <- tw_state$built %||% NA_character_
  now <- tw_build_stamp()
  !is.na(was) && !is.na(now) && !identical(was, now)
}

#' The version the app's stylesheets and scripts are served under: the
#' package version plus when it was built, so each installation has new
#' addresses and the browser cannot keep the previous update's files
#' @noRd
tw_resource_version <- function() {
  b <- tw_state$built %||% NA_character_
  t <- if (is.na(b)) NA_character_ else regmatches(b, regexpr("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}", b))
  stamp <- if (length(t) == 1 && !is.na(t)) t else format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  d <- gsub("[^0-9]", "", stamp)
  paste(as.character(utils::packageVersion("DECIDE")), substr(d, 1, 8), substr(d, 9, 14), sep = ".")
}
