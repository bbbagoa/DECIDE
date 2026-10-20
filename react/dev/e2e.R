# Browser checks of the React pages: launch the app from source and get to a
# page with data loaded. Source it from a test script run at the package root:
#   source("react/dev/e2e.R")
#   app <- tw_launch()                 # the app, on a free port, own session folder
#   tw_load_registration(app)          # demo registration data imported and mapped
#   tw_go(app, "dq_panel")             # a page by its value
#   tw_click(app, "dq_1-btn_apply")    # a React button (app$click() is for Shiny buttons)
#   tw_shot(app, "dq")                 # screenshot to TW_SHOTS (or tempdir())
#   tw_errors(app)                     # browser errors so far
# Never R CMD INSTALL for a check: other apps run from the installed package.
# The app runs from source (pkgload) with background jobs inline, so it runs
# this worktree's code. Rebuild the client first: cd react && npm run build.
tw_root <- normalizePath(getwd())
stopifnot(file.exists(file.path(tw_root, "DESCRIPTION")))

#' background = TRUE: long tasks run in the background R process, as for users
#' (the worker loads this source folder, see tw_source_path()); FALSE (the
#' default, faster to start): inline.
tw_launch <- function(width = 1500, height = 950, background = FALSE, store = NULL) {
  dir <- tempfile("twapp")
  dir.create(dir)
  store <- store %||% tempfile("twstore")   # a folder of saved sessions to start with, or a new one
  writeLines(c(
    sprintf('Sys.setenv(DECIDE_BACKGROUND = "%s", DECIDE_UPDATE_CHECK = "false", DECIDE_SESSION_DIR = "%s")',
            if (background) "true" else "false", gsub("\\\\", "/", store)),
    sprintf('pkgload::load_all("%s", quiet = TRUE, export_all = TRUE)', gsub("\\\\", "/", tw_root)),
    "options(shiny.maxRequestSize = 2 * 1024^3)",
    "shiny::shinyApp(app_ui, app_server)"
  ), file.path(dir, "app.R"))
  cm <- chromote::default_chromote_object()
  cm$default_timeout <- 180
  app <- shinytest2::AppDriver$new(dir, width = width, height = height, load_timeout = 300000, timeout = 120000)
  Sys.sleep(4)
  tw_idle(app)
  app
}

tw_idle <- function(app, t = 120000) invisible(try(app$wait_for_idle(timeout = t), silent = TRUE))
tw_js <- function(app, x) app$get_js(x)

#' Go to a page by its value, by clicking its navbar link (the React shell keeps
#' the page it shows; setting input$main_nav alone does not move it). Labels as
#' in react/src/App.tsx (English).
TW_PAGES <- c(welcome_panel = "Welcome", scorecard_panel = "Targeting Design", import_panel = "Load registration data",
              overview_panel = "Overview", dq_panel = "Data Quality", spot_panel = "Spot Checking", ben_panel = "Selection",
              pdm_panel = "Targeting Monitoring", modif_logs = "Activity Log")
tw_go <- function(app, page) {
  hit <- tw_js(app, sprintf(
    "(function(){var a=[].slice.call(document.querySelectorAll('.tw-navbar a')).filter(function(x){return x.textContent.trim()==='%s'})[0];if(a)a.click();return !!a})()",
    TW_PAGES[[page]]))
  if (!isTRUE(hit)) app$set_inputs(main_nav = page, allow_no_input_binding_ = TRUE)
  Sys.sleep(1.5)
  tw_idle(app)
}

#' Click a React button (ActionButton): shinytest2's app$click() needs a Shiny
#' input binding, which React buttons do not have (their clicks reach the server once).
tw_click <- function(app, id) {
  tw_js(app, sprintf("(function(){var b=document.getElementById('%s');if(b)b.click();return !!b})()", id))
  Sys.sleep(0.5)
  tw_idle(app)
}

#' Import a registration file on "Load registration data" and confirm the mapping
#' (auto-guessed). Keeps the Shiny page's ids: file_import_1-file_in,
#' btn_import_to_setup, setup_1-save, setup_1-review_confirm.
tw_load_registration <- function(app, file = file.path(tw_root, "inst/extdata/registration_demo.csv")) {
  tw_go(app, "import_panel")
  app$upload_file(`file_import_1-file_in` = file)
  app$wait_for_js("!!document.getElementById('btn_import_to_setup')", timeout = 120000)
  tw_idle(app)
  app$click("btn_import_to_setup"); tw_idle(app)
  app$wait_for_js("!!document.querySelector('#setup_1-save.shiny-bound-input')", timeout = 120000)
  app$click("setup_1-save"); tw_idle(app)
  app$wait_for_js("!!document.querySelector('#setup_1-review_confirm.shiny-bound-input')", timeout = 120000)
  app$click("setup_1-review_confirm"); tw_idle(app)
  Sys.sleep(3)
  invisible(app)
}

tw_shot <- function(app, name) {
  f <- file.path(Sys.getenv("TW_SHOTS", tempdir()), paste0(name, ".png"))
  unlink(f)
  app$get_screenshot(f)
  invisible(f)
}

tw_errors <- function(app) {
  lg <- as.data.frame(app$get_logs())
  # shinyreact logs every validate() message as "Error for <id>": an expected
  # state, not an error. R errors still show ("Warning: Error in ...").
  e <- grep("rror|Uncaught", lg$message, value = TRUE)
  e[!grepl("Error for [^ ]+: ", e) | grepl("Uncaught", e)]
}
