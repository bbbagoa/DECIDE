#' Global variables used in dplyr / data-masked expressions
#'
#' This silences R CMD check NOTES for column names created inside
#' dplyr::mutate(), dplyr::summarise(), plotly, and leaflet calls.
#'
#' @noRd
utils::globalVariables(c(
  "Count", "Demo", "Gapped_Households", "Households", "Incompleteness_Rate",
  "Individuals", "Is_Incomplete", "Is_Missing", "Location", "Missing_Count",
  "Total_Households", "Value", "Variable", "Vulnerability", "label", "lat",
  "lng", "missing_n", "perc_missing", "timestamp", "total", "value", "values",
  ".w"
))
