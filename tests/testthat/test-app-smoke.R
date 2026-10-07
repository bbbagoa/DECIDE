# End-to-end smoke test.
#
# The unit tests cover the analytics; what keeps breaking is the *wiring* --
# a module server that never defined `ns`, a modal that replaced the one
# underneath it, a nav panel that was never mounted, an output whose observer
# never fired. None of that is visible to testthat, so this drives the real
# app: import a file, map the variables, and check the tabs and the headline
# numbers come out right.

# The first page load builds the theme and can pass chromote's default 10 s.
options(chromote.timeout = 120)

skip_if_no_app_driver <- function() {
  testthat::skip_if_not_installed("shinytest2")
  testthat::skip_if_not_installed("chromote")
  testthat::skip_if(
    is.null(tryCatch(chromote::find_chrome(), error = function(e) NULL)),
    "no Chrome available for shinytest2"
  )
  # The first page load builds the theme and can pass chromote's default
  # 10 s; the option alone is read too late once the browser object exists.
  cm <- tryCatch(chromote::default_chromote_object(), error = function(e) NULL)
  testthat::skip_if(is.null(cm), "Chrome could not be started for shinytest2")
  cm$default_timeout <- 120
}

# The app the tests drive. From a source checkout (devtools::test()), an app
# folder that loads this source: an app object would be run by a child process
# that loads the INSTALLED TargetWise, mixing two versions. Background jobs run
# inline for the same reason (the worker loads the installed package).
smoke_app <- function(envir = parent.frame()) {
  root <- normalizePath(testthat::test_path("..", ".."), winslash = "/", mustWork = FALSE)
  if (!file.exists(file.path(root, "DESCRIPTION"))) return(shiny::shinyApp(ui = app_ui, server = app_server))
  dir <- withr::local_tempdir(.local_envir = envir)
  writeLines(c('Sys.setenv(TARGETWISE_BACKGROUND = "false")',
               sprintf('pkgload::load_all("%s", quiet = TRUE, export_all = TRUE)', root),
               "shiny::shinyApp(app_ui, app_server)"), file.path(dir, "app.R"))
  dir
}

# The value of an Overview figure (tiles carry their label as data-key)
tile <- function(app, key) {
  app$wait_for_js(sprintf("!!document.querySelector('.tw-rov-collection .tw-tile[data-key=\"%s\"]')", key), timeout = 60 * 1000)
  app$get_js(sprintf("document.querySelector('.tw-rov-collection .tw-tile[data-key=\"%s\"] .tw-tile-value').textContent", key))
}

# The mapping the fixture needs. Keys are the setup inputs.
fixture_mapping <- function() {
  list(
    unique_id = "instanceID", date = "SvyDate", enumerator_id = "enumerator",
    admin1 = "Province", admin2 = "Territoire", admin3 = "Zonesante",
    admin4 = "Airedesante", village = "Village", lon = "lon", lat = "lat",
    hhh_sex = "HHHSex", hhh_age = "HHHAge", hh_size = "HHSize",
    residency = "HHStatus", childU5 = "childU5", disability = "disability",
    v_score = "score", v_groups = "score_class", eligibility = "eligible",
    weight = "weight"
  )
}

# load_timeout is generous on purpose: the first launch after an install
# rebuilds the theme and fetches the Commissioner font (bslib::font_google),
# which has exceeded 90 s on a cold cache and failed the suite at start-up.
test_that("the app boots, imports, maps variables and reveals the analysis tabs", {
  skip_if_no_app_driver()
  skip_on_cran()

  fixture <- testthat::test_path("fixtures", "mini_targeting.csv")
  expect_true(file.exists(fixture))
  expected <- utils::read.csv(fixture, stringsAsFactors = FALSE)

  # Keep the session store out of the developer's real one.
  store <- withr::local_tempdir()
  withr::local_envvar(c(TARGETWISE_SESSION_DIR = store, TARGETWISE_UPDATE_CHECK = "false"))

  app <- shinytest2::AppDriver$new(
    smoke_app(),
    name = "targeting-smoke", height = 1200, width = 1600,
    load_timeout = 240 * 1000, timeout = 30 * 1000
  )
  withr::defer(app$stop())

  # Only the panels that read the registration data wait for the mapping.
  # Targeting Design and Targeting Monitoring load their own datasets, so they
  # must be reachable from a cold start -- a country office designing a
  # scorecard has no registration list yet.
  # The React shell starts with them hidden; the server confirms after the
  # client's handshake (tw_nav_state()).
  # nav_hide() runs in an observe(), so the panels are visible for the instant
  # between the page painting and the first flush. Without this wait the
  # assertion below is a coin flip -- it failed once in a full-suite run and
  # passed on its own.
  app$wait_for_idle(timeout = 30 * 1000)
  # Idle is not enough under a loaded full-suite run: wait for the hide itself
  # (a timeout falls through to the assertion, which then reports it).
  try(app$wait_for_js(
    "(function(){var a=document.querySelector('a[data-value=overview_panel]');
      return !a || getComputedStyle(a.parentElement).display === 'none';})()",
    timeout = 30 * 1000), silent = TRUE)

  vis <- function(panels) {
    app$get_js(sprintf(
      "JSON.stringify(%s.map(function(v){
          var a = document.querySelector('a[data-value=' + v + ']');
          return !!a && getComputedStyle(a.parentElement).display !== 'none';
       }))", jsonlite::toJSON(panels)))
  }
  expect_equal(
    jsonlite::fromJSON(vis(c("overview_panel", "dq_panel", "spot_panel", "ben_panel"))),
    rep(FALSE, 4)
  )
  # The audit trail spans every phase, so it is there from the start too.
  expect_equal(
    jsonlite::fromJSON(vis(c("welcome_panel", "import_panel",
                             "scorecard_panel", "pdm_panel", "modif_logs"))),
    rep(TRUE, 5)
  )

  # No saved sessions in a fresh store, so no restore modal to dismiss.
  app$upload_file(`file_import_1-file_in` = fixture)
  # The file is read in the background worker, so the page is idle before the
  # import summary shows: wait for the summary itself.
  app$wait_for_js("!!document.getElementById('btn_import_to_setup')", timeout = 90 * 1000)
  app$wait_for_idle(timeout = 60 * 1000)

  # The import summary offers the way into variable setup.
  app$click("btn_import_to_setup")
  app$wait_for_idle(timeout = 30 * 1000)

  app$set_inputs(!!!stats::setNames(fixture_mapping(),
                                    paste0("setup_1-", names(fixture_mapping()))))
  app$wait_for_idle(timeout = 30 * 1000)
  app$click("setup_1-save")
  app$wait_for_idle(timeout = 60 * 1000)
  # The review (values, dates, checks, what the data allow) comes before the analysis.
  expect_true(app$get_js("!!document.getElementById('setup_1-review_confirm')"))
  app$click("setup_1-review_confirm")
  app$wait_for_idle(timeout = 60 * 1000)

  # Overview is reachable and counts what the fixture contains.
  values <- list(output = list(`overview_1-stat_hh` = tile(app, "Households"), `overview_1-stat_indiv` = tile(app, "Individuals")))
  # registration data: every household counts once, whatever weight is mapped
  expect_equal(values$output[["overview_1-stat_hh"]], format(nrow(expected), big.mark = ","))
  expect_equal(values$output[["overview_1-stat_indiv"]], format(sum(expected$HHSize), big.mark = ","))

  # Every analysis panel is now visible (they start hidden).
  expect_equal(
    jsonlite::fromJSON(vis(c("overview_panel", "dq_panel", "spot_panel",
                             "ben_panel", "modif_logs", "scorecard_panel",
                             "pdm_panel", "import_panel"))),
    rep(TRUE, 8)
  )

  # Nothing errored anywhere on the page.
  errors <- app$get_js(
    "JSON.stringify(Array.from(document.querySelectorAll('.shiny-output-error'))
       .filter(function(d){return d.offsetParent !== null})
       .map(function(d){return (d.textContent||'').trim().slice(0,160)}))"
  )
  expect_equal(unlist(jsonlite::fromJSON(errors)), NULL)
})

test_that("a saved setup profile reapplies to a fresh import of the same form", {
  skip_if_no_app_driver()
  skip_on_cran()

  fixture <- testthat::test_path("fixtures", "mini_targeting.csv")
  store <- withr::local_tempdir()
  withr::local_envvar(c(TARGETWISE_SESSION_DIR = store, TARGETWISE_UPDATE_CHECK = "false"))

  # Plant a profile the way the setup modal would have written it.
  mapping <- fixture_mapping()
  save_profile(profile_from_settings(mapping, name = "smoke"), user = NULL)

  app <- shinytest2::AppDriver$new(
    smoke_app(parent.frame()),
    name = "targeting-profile", height = 1200, width = 1600,
    load_timeout = 240 * 1000, timeout = 30 * 1000
  )
  withr::defer(app$stop())

  app$upload_file(`file_import_1-file_in` = fixture)
  # The file is read in the background worker, so the page is idle before the
  # import summary shows: wait for the summary itself.
  app$wait_for_js("!!document.getElementById('btn_import_to_setup')", timeout = 90 * 1000)
  app$wait_for_idle(timeout = 60 * 1000)
  app$click("btn_import_to_setup")
  app$wait_for_idle(timeout = 30 * 1000)

  # Picking a profile changes no output on its own; only Apply does.
  app$set_inputs(`setup_1-profile_choice` = "smoke", wait_ = FALSE)
  app$click("setup_1-profile_apply")
  app$wait_for_idle(timeout = 30 * 1000)

  got <- app$get_values(input = paste0("setup_1-", names(mapping)))$input
  for (k in names(mapping)) {
    expect_equal(got[[paste0("setup_1-", k)]], mapping[[k]],
                 info = paste("profile did not restore", k))
  }
})


# Open every analysis panel and every tab inside it, and return the errors
# shown anywhere on the way.
visible_errors_everywhere <- function(app) {
  errs <- character(0)
  grab <- function() unlist(jsonlite::fromJSON(app$get_js(
    "JSON.stringify(Array.from(document.querySelectorAll('.shiny-output-error'))
       .filter(function(d){return d.offsetParent !== null && !d.classList.contains('shiny-output-error-validation')})
       .map(function(d){return (d.textContent||'').trim().slice(0,160)}))")))
  for (panel in c("overview_panel", "dq_panel", "spot_panel", "ben_panel")) {
    app$run_js(sprintf("document.querySelector('a[data-value=%s]').click()", panel))
    app$wait_for_idle(timeout = 60 * 1000)
    errs <- c(errs, grab())
    n <- app$get_js(sprintf("document.querySelectorAll('.tw-page[data-value=%s] .tw-tabs-nav .nav-link').length", panel))
    for (i in seq_len(n) - 1) {
      app$run_js(sprintf("document.querySelectorAll('.tw-page[data-value=%s] .tw-tabs-nav .nav-link')[%d].click()", panel, i))
      app$wait_for_idle(timeout = 60 * 1000)
      errs <- c(errs, grab())
    }
  }
  unique(errs)
}

start_app <- function(name) {
  store <- withr::local_tempdir(.local_envir = parent.frame())
  withr::local_envvar(c(TARGETWISE_SESSION_DIR = store, TARGETWISE_UPDATE_CHECK = "false"), .local_envir = parent.frame())
  app <- shinytest2::AppDriver$new(
    smoke_app(),
    name = name, height = 1200, width = 1600,
    load_timeout = 240 * 1000, timeout = 30 * 1000
  )
  withr::defer(app$stop(), envir = parent.frame())
  app
}

import_and_open_setup <- function(app, file) {
  app$upload_file(`file_import_1-file_in` = file)
  app$wait_for_js("!!document.getElementById('btn_import_to_setup')", timeout = 90 * 1000)
  app$wait_for_idle(timeout = 60 * 1000)
  app$click("btn_import_to_setup")
  app$wait_for_idle(timeout = 30 * 1000)
}

test_that("with only the id and one area level mapped, every tab opens without an error", {
  skip_if_no_app_driver()
  skip_on_cran()
  app <- start_app("targeting-minimal")
  import_and_open_setup(app, testthat::test_path("fixtures", "mini_targeting.csv"))
  keys <- TargetWise:::setup_keys()
  minimal <- stats::setNames(as.list(rep("", length(keys))), keys)
  minimal$unique_id <- "instanceID"; minimal$admin1 <- "Province"
  app$set_inputs(!!!stats::setNames(minimal, paste0("setup_1-", names(minimal))))
  app$wait_for_idle(timeout = 30 * 1000)
  app$click("setup_1-save")
  app$wait_for_idle(timeout = 60 * 1000)
  app$click("setup_1-review_confirm")
  app$wait_for_idle(timeout = 60 * 1000)

  # the counts that need nothing else still come out; the others say why
  expect_equal(tile(app, "Households"), "60")
  expect_true(app$get_js("!!document.querySelector('.tw-ready-strip')"))
  expect_equal(visible_errors_everywhere(app), character(0))
})

test_that("a French export is guessed, standardised and opens without an error", {
  skip_if_no_app_driver()
  skip_on_cran()
  d <- utils::read.csv(testthat::test_path("fixtures", "mini_targeting.csv"), stringsAsFactors = FALSE)
  fr <- data.frame(code_menage = d$instanceID, date_enquete = format(as.Date(d$SvyDate), "%d/%m/%Y"),
                   enqueteur = d$enumerator, province = d$Province, territoire = d$Territoire,
                   gps_latitude = d$lat, gps_longitude = d$lon,
                   sexe_chef = ifelse(d$HHHSex == "Male", "Homme", "Femme"), taille_menage = d$HHSize,
                   handicap = ifelse(d$disability == "Yes", "Oui", "Non"), stringsAsFactors = FALSE)
  f <- withr::local_tempfile(fileext = ".csv"); utils::write.csv(fr, f, row.names = FALSE)
  app <- start_app("targeting-french")
  import_and_open_setup(app, f)
  got <- app$get_values(input = c("setup_1-unique_id", "setup_1-date", "setup_1-hhh_sex", "setup_1-lat"))$input
  expect_equal(unlist(got[c("setup_1-unique_id", "setup_1-date", "setup_1-hhh_sex", "setup_1-lat")]),
               c(`setup_1-unique_id` = "code_menage", `setup_1-date` = "date_enquete", `setup_1-hhh_sex` = "sexe_chef", `setup_1-lat` = "gps_latitude"))
  app$click("setup_1-save")
  app$wait_for_idle(timeout = 60 * 1000)
  # Homme / Femme are offered as Male / Female
  rc <- app$get_values(input = c("setup_1-rc_hhh_sex_1", "setup_1-rc_hhh_sex_2"))$input
  expect_setequal(unname(unlist(rc)), c("Male", "Female"))
  app$click("setup_1-review_confirm")
  app$wait_for_idle(timeout = 60 * 1000)
  expect_equal(visible_errors_everywhere(app), character(0))
})

test_that("the country office's profile is offered on a fresh import", {
  skip_if_no_app_driver()
  skip_on_cran()
  store <- withr::local_tempdir()
  withr::local_envvar(c(TARGETWISE_SESSION_DIR = store, TARGETWISE_UPDATE_CHECK = "false"))
  TargetWise:::app_setting_set("country_office", "Chad", NULL)
  prof <- TargetWise:::profile_from_settings(
    c(fixture_mapping()[c("unique_id", "admin1", "admin2", "hhh_sex")], list(recode_maps = list(hhh_sex = list(Female = "Female", Male = "Male")),
                                                                              country_office = "Chad")), name = "chad-round-2")
  save_profile(prof, user = NULL)
  app <- shinytest2::AppDriver$new(
    smoke_app(),
    name = "targeting-country", height = 1200, width = 1600,
    load_timeout = 240 * 1000, timeout = 30 * 1000
  )
  withr::defer(app$stop())
  import_and_open_setup(app, testthat::test_path("fixtures", "mini_targeting.csv"))
  expect_match(app$get_js("(document.querySelector('.modal .alert-info')||{}).textContent || ''"), "Applied the Chad profile 'chad-round-2'")
  expect_equal(app$get_js("document.querySelectorAll('.modal .tw-conf-profile').length"), 4)
})
