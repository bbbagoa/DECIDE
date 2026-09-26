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
    shiny::shinyApp(ui = app_ui, server = app_server),
    name = "targeting-smoke", height = 1200, width = 1600,
    load_timeout = 240 * 1000, timeout = 30 * 1000
  )
  withr::defer(app$stop())

  # Only the panels that read the registration data wait for the mapping.
  # Targeting Design and Targeting Monitoring load their own datasets, so they
  # must be reachable from a cold start -- a country office designing a
  # scorecard has no registration list yet.
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

  # Overview is reachable and counts what the fixture contains. Both headline
  # KPIs are weighted, so the fixture's sampling weights are the expectation.
  values <- app$get_values(output = c("overview_1-stat_hh", "overview_1-stat_indiv"))
  expect_equal(values$output[["overview_1-stat_hh"]],
               format(round(sum(expected$weight)), big.mark = ","))
  expect_equal(values$output[["overview_1-stat_indiv"]],
               format(round(sum(expected$weight * expected$HHSize)), big.mark = ","))

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
    shiny::shinyApp(ui = app_ui, server = app_server),
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
