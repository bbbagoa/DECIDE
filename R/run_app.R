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
  # Updated since this R session loaded it: the session still holds the old
  # code, and mixing it with the new files breaks downloads. Stop and say so.
  if (tw_updated_since_load()) {
    stop("DECIDE was updated after this R session loaded it. Restart R ",
         "(RStudio / Positron: Session > Restart R), then run DECIDE::run_app() again.",
         call. = FALSE)
  }

  # Ensure large targeting datasets can be uploaded
  if (is.null(getOption("shiny.maxRequestSize")) ||
      getOption("shiny.maxRequestSize") < 2 * 1024^3) {
    options(shiny.maxRequestSize = 2 * 1024^3)
  }

  # Open in the system's default browser. `TRUE` is not enough: it goes through
  # getOption("browser"), which RStudio and Positron replace with their own
  # viewer. Handing the URL to the OS file association bypasses both.
  options(shiny.launch.browser = open_in_default_browser)
  options$launch.browser <- open_in_default_browser

  # R's just-in-time compiler compiles every large server function the first
  # time it runs (measured: ~9 s of a session on 100k households, and the
  # first import 2.5x slower). The package code is already byte-compiled at
  # installation, so turning it off costs nothing here. The previous level
  # comes back when the app stops.
  jit <- compiler::enableJIT(0)
  on_start <- onStart
  onStart <- function() {
    shiny::onStop(function() compiler::enableJIT(jit))
    if (is.function(on_start)) on_start()
  }

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

#' Open a URL in the operating system's default browser
#'
#' `browser = NULL` on Windows uses the file association (shell.exec); macOS
#' and Linux have `open` / `xdg-open` for the same job.
#' @noRd
open_in_default_browser <- function(url) {
  browser <- switch(Sys.info()[["sysname"]], Windows = NULL, Darwin = "open", "xdg-open")
  utils::browseURL(url, browser = browser)
}
