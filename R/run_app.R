#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @import shiny
#' @import bsicons
#' @import bslib
#' @import dplyr
#' @import ggplot2
#' @import golem
#' @import haven
#' @import htmltools
#' @import leafgl
#' @import leaflet
#' @import lubridate
#' @import openxlsx
#' @import readxl
#' @import rlang
#' @import sf
#' @import shinycssloaders
#' @import stringr
#' @import thematic
#' @import tidyr
#' @import tools
#' @import waiter
#' @importFrom stats as.formula median quantile reorder sd setNames
#' @importFrom utils object.size write.csv
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  # Ensure large targeting datasets can be uploaded
  if (is.null(getOption("shiny.maxRequestSize")) ||
      getOption("shiny.maxRequestSize") < 2 * 1024^3) {
    options(shiny.maxRequestSize = 2 * 1024^3)
  }

  # Open directly in the user's default browser, ignoring IDE viewer settings
  options(shiny.launch.browser = TRUE)
  options$launch.browser <- TRUE

  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}
