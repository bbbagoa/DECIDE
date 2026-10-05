# Dates in every workbook written by the app: day / month / year (unless the
# user's own R session already chose a format).
.onLoad <- function(libname, pkgname) {
  if (is.null(getOption("openxlsx.dateFormat"))) options(openxlsx.dateFormat = "dd/mm/yyyy")
  if (is.null(getOption("openxlsx.datetimeFormat"))) options(openxlsx.datetimeFormat = "dd/mm/yyyy hh:mm")
  invisible()
}
