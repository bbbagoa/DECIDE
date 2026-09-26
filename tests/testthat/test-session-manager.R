test_that("session name sanitization handles special characters", {
  expect_equal(TargetWise:::sanitize_session_name("My Session"), "My_Session")
  expect_equal(TargetWise:::sanitize_session_name("Session #1!"), "Session_1")
  expect_equal(TargetWise:::sanitize_session_name("  leading trailing  "), "leading_trailing")
  expect_equal(TargetWise:::sanitize_session_name("!!!"), "session")
})

test_that("named session save/load roundtrip works in temp dir", {
  tmp_dir <- tempfile()
  dir.create(tmp_dir, recursive = TRUE)

  df <- data.frame(id = 1:3, value = letters[1:3], stringsAsFactors = FALSE)
  setup <- list(date = "date_col", admin1 = "adm1")
  log <- data.frame(
    timestamp = Sys.time(),
    uid = "1",
    column = "value",
    old_value = "a",
    new_value = "A",
    action = "test",
    stringsAsFactors = FALSE
  )

  session_file <- file.path(tmp_dir, "my_session.rds")
  session_data <- list(
    uploaded_df = df,
    user_setup = setup,
    modification_log = log,
    theme = "wfp",
    saved_at = Sys.time(),
    name = "my_session"
  )
  saveRDS(session_data, session_file)

  loaded <- readRDS(session_file)
  expect_equal(loaded$uploaded_df, df)
  expect_equal(loaded$user_setup, setup)
  expect_equal(loaded$modification_log, log)
  expect_equal(loaded$name, "my_session")
})

test_that("audit-log companions are not listed as sessions and are deleted with them", {
  tmp_dir <- tempfile()
  old <- Sys.getenv("TARGETWISE_SESSION_DIR", unset = NA)
  Sys.setenv(TARGETWISE_SESSION_DIR = tmp_dir)
  on.exit({
    if (is.na(old)) Sys.unsetenv("TARGETWISE_SESSION_DIR") else Sys.setenv(TARGETWISE_SESSION_DIR = old)
    unlink(tmp_dir, recursive = TRUE)
  }, add = TRUE)

  df <- data.frame(id = 1:2)
  log <- data.frame(uid = "1", action = "edit", stringsAsFactors = FALSE)
  TargetWise:::save_session(df, list(unique_id = "id"), log, theme = "wfp", name = "Field Trip")
  TargetWise:::save_audit_log(log, name = "Field Trip")

  expect_equal(TargetWise:::list_saved_sessions()$name, "Field_Trip")

  TargetWise:::delete_session("Field Trip")
  expect_equal(nrow(TargetWise:::list_saved_sessions()), 0)
  expect_false(file.exists(file.path(tmp_dir, "Field_Trip_audit.rds")))
})

test_that("the audit companion is readable back (restore prefers it when longer)", {
  tmp_dir <- tempfile()
  old <- Sys.getenv("TARGETWISE_SESSION_DIR", unset = NA)
  Sys.setenv(TARGETWISE_SESSION_DIR = tmp_dir)
  on.exit({
    if (is.na(old)) Sys.unsetenv("TARGETWISE_SESSION_DIR") else Sys.setenv(TARGETWISE_SESSION_DIR = old)
    unlink(tmp_dir, recursive = TRUE)
  }, add = TRUE)

  df <- data.frame(id = 1:2)
  saved_log <- data.frame(uid = "1", action = "edit", stringsAsFactors = FALSE)
  TargetWise:::save_session(df, list(unique_id = "id"), saved_log, name = "autosave")

  # Two more corrections happen after the last session write.
  later_log <- data.frame(uid = c("1", "2", "3"), action = "edit", stringsAsFactors = FALSE)
  TargetWise:::save_audit_log(later_log, name = "autosave")

  companion <- TargetWise:::load_audit_log("autosave")
  expect_s3_class(companion, "data.frame")
  expect_gt(nrow(companion), nrow(TargetWise:::load_session("autosave")$modification_log))
  expect_null(TargetWise:::load_audit_log("never_saved"))
})

test_that("session storage is isolated per authenticated user", {
  tmp_dir <- tempfile()
  old <- Sys.getenv("TARGETWISE_SESSION_DIR", unset = NA)
  Sys.setenv(TARGETWISE_SESSION_DIR = tmp_dir)
  on.exit({
    if (is.na(old)) Sys.unsetenv("TARGETWISE_SESSION_DIR") else Sys.setenv(TARGETWISE_SESSION_DIR = old)
    unlink(tmp_dir, recursive = TRUE)
  }, add = TRUE)

  alice <- data.frame(id = 1:2, name = c("A", "B"), stringsAsFactors = FALSE)
  bob <- data.frame(id = 3:4, name = c("C", "D"), stringsAsFactors = FALSE)
  TargetWise:::save_session(alice, list(unique_id = "id"), NULL, name = "round1", user = "alice@wfp.org")
  TargetWise:::save_session(bob, list(unique_id = "id"), NULL, name = "round1", user = "bob@wfp.org")

  # Same session name, different users: neither sees nor overwrites the other.
  expect_equal(TargetWise:::load_session("round1", user = "alice@wfp.org")$uploaded_df, alice)
  expect_equal(TargetWise:::load_session("round1", user = "bob@wfp.org")$uploaded_df, bob)

  # Each user only lists their own, and the anonymous store stays empty.
  expect_equal(TargetWise:::list_saved_sessions("alice@wfp.org")$name, "round1")
  expect_equal(nrow(TargetWise:::list_saved_sessions()), 0)

  # Per-user keys: alice's key cannot decrypt bob's file.
  bob_file <- TargetWise:::get_session_file("round1", user = "bob@wfp.org")
  expect_error(
    TargetWise:::decrypt_session(readRDS(bob_file), user = "alice@wfp.org"),
    regexp = "."
  )

  # Clearing one user leaves the other intact.
  TargetWise:::clear_session("alice@wfp.org")
  expect_equal(nrow(TargetWise:::list_saved_sessions("alice@wfp.org")), 0)
  expect_equal(nrow(TargetWise:::list_saved_sessions("bob@wfp.org")), 1)
})

test_that("require_auth reads the environment switch", {
  old <- Sys.getenv("TARGETWISE_REQUIRE_AUTH", unset = NA)
  on.exit(if (is.na(old)) Sys.unsetenv("TARGETWISE_REQUIRE_AUTH") else Sys.setenv(TARGETWISE_REQUIRE_AUTH = old), add = TRUE)
  Sys.unsetenv("TARGETWISE_REQUIRE_AUTH")
  expect_false(TargetWise:::require_auth())
  Sys.setenv(TARGETWISE_REQUIRE_AUTH = "true")
  expect_true(TargetWise:::require_auth())
  Sys.setenv(TARGETWISE_REQUIRE_AUTH = "no")
  expect_false(TargetWise:::require_auth())
})

test_that("app_user falls back through platform, env, then anonymous", {
  old <- Sys.getenv("TARGETWISE_USER", unset = NA)
  on.exit(if (is.na(old)) Sys.unsetenv("TARGETWISE_USER") else Sys.setenv(TARGETWISE_USER = old), add = TRUE)
  Sys.unsetenv("TARGETWISE_USER")
  expect_null(TargetWise:::app_user(NULL))
  expect_equal(TargetWise:::app_user(list(user = "carla@wfp.org")), "carla@wfp.org")
  Sys.setenv(TARGETWISE_USER = "env-user")
  expect_equal(TargetWise:::app_user(NULL), "env-user")
  # A platform-supplied user always wins over the environment fallback.
  expect_equal(TargetWise:::app_user(list(user = "carla@wfp.org")), "carla@wfp.org")
})

test_that("a session keeps the original import only when it differs from the working data", {
  withr::local_envvar(TARGETWISE_SESSION_DIR = withr::local_tempdir())
  orig <- data.frame(id = 1:3, x = c(1, 2, 3))
  edited <- orig[-2, ]
  TargetWise:::save_session(edited, list(), NULL, name = "o1", original_df = orig)
  expect_equal(TargetWise:::load_session("o1")$original_df, orig)
  TargetWise:::save_session(orig, list(), NULL, name = "o2", original_df = orig)
  expect_null(TargetWise:::load_session("o2")$original_df)   # not stored twice
})

test_that("the country-office settings file is not listed as a saved session", {
  withr::local_envvar(TARGETWISE_SESSION_DIR = withr::local_tempdir())
  TargetWise:::save_session(data.frame(a = 1), list(), NULL, name = "real")
  TargetWise:::app_setting_set("country_office", "Mali")
  expect_equal(TargetWise:::list_saved_sessions()$name, "real")
})

test_that("a session saved as 'settings' no longer breaks the country office (raw to character)", {
  dir <- withr::local_tempdir()
  withr::local_envvar(TARGETWISE_SESSION_DIR = dir)
  # The state of the computer that crashed: settings.rds holds an encrypted
  # session (raw bytes), as when a session was saved under the name "settings".
  TargetWise:::save_session(data.frame(a = 1:3), list(admin1 = "a"), data.frame(), name = "settings")
  expect_true(is.raw(readRDS(file.path(dir, "settings.rds"))))
  expect_silent(TargetWise:::app_setting_set("country_office", "Mali"))
  expect_equal(TargetWise:::app_setting_get("country_office"), "Mali")
  # the session is still there, listed and loadable
  expect_true("settings" %in% TargetWise:::list_saved_sessions()$name)
  expect_equal(TargetWise:::load_session("settings")$uploaded_df$a, 1:3)
  # and saving a session called "settings" again leaves the country office alone
  TargetWise:::save_session(data.frame(a = 4), list(), data.frame(), name = "settings")
  expect_equal(TargetWise:::app_setting_get("country_office"), "Mali")
})

test_that("settings from an older version (a list in settings.rds) are carried over once", {
  dir <- withr::local_tempdir()
  withr::local_envvar(TARGETWISE_SESSION_DIR = dir)
  saveRDS(list(country_office = "Niger"), file.path(dir, "settings.rds"))
  expect_equal(TargetWise:::app_setting_get("country_office"), "Niger")
  expect_false(file.exists(file.path(dir, "settings.rds")))
  expect_false("settings" %in% TargetWise:::list_saved_sessions()$name)
  # anything unreadable in the settings file reads as no settings, not an error
  writeLines("garbage", file.path(dir, "app.settings"))
  expect_null(TargetWise:::app_setting_get("country_office"))
  expect_silent(TargetWise:::app_setting_set("country_office", "Chad"))
  expect_equal(TargetWise:::app_setting_get("country_office"), "Chad")
})

test_that("large frames go through Parquet and come back identical", {
  n <- 1500
  d <- data.frame(id = sprintf("h%04d", 1:n), size = c(NA, 2:n), score = runif(n),
                  sex = factor(sample(c("M", "F", NA), n, TRUE), levels = c("M", "F")),
                  day = as.Date("2026-01-01") + 0:(n - 1),
                  at = as.POSIXct("2026-01-01 10:00", tz = "Africa/Kinshasa") + 1:n,
                  ok = sample(c(TRUE, FALSE, NA), n, TRUE), stringsAsFactors = FALSE)
  attr(d$size, "label") <- "Household size"
  attr(d, "label") <- "Registration"
  p <- TargetWise:::pack_frames(list(a = list(df = d), small = d[1:5, ]))
  expect_s3_class(p$a$df, "tw_parquet")
  expect_true(is.data.frame(p$small))
  back <- TargetWise:::unpack_frames(p)$a$df
  expect_equal(back, d)
  expect_identical(levels(back$sex), c("M", "F"))
  expect_identical(attr(back$size, "label"), "Household size")
  expect_identical(attr(back$at, "tzone"), "Africa/Kinshasa")
  # a list column stays as it is
  d$l <- I(as.list(1:n))
  expect_true(is.data.frame(TargetWise:::frame_to_parquet(d)))
})

test_that("each workstream saves its own part and loads beside the others", {
  withr::local_envvar(TARGETWISE_SESSION_DIR = withr::local_tempdir())
  log <- data.frame(timestamp = c("2026-01-01 10:00:00", "2026-01-01 11:00:00", "2026-01-01 12:00:00"),
                    action = c("Design: Model fitted", "Duplicate deletion", "Monitoring: PDM loaded"),
                    stringsAsFactors = FALSE)
  setup <- list(unique_id = "id", scorecard = list(items = list(1)), rules = list("r"), country_office = "Chad")
  work <- list(scorecard = list(data = data.frame(x = 1:3)), ben_selection = list(a = 1), pdm = list(df = data.frame(y = 1)))
  st <- function(k) TargetWise:::workstream_state(k, data.frame(id = 1:4), NULL, setup, log, list(form_id = "1"), work)
  d <- st("design"); s <- st("selection"); m <- st("monitoring")
  expect_null(d$uploaded_df); expect_equal(names(d$workspace), "scorecard")
  expect_equal(sort(names(d$user_setup)), c("country_office", "scorecard"))
  expect_equal(d$modification_log$action, "Design: Model fitted")
  expect_equal(nrow(s$uploaded_df), 4); expect_equal(names(s$workspace), "ben_selection")
  expect_equal(s$modification_log$action, "Duplicate deletion")
  expect_equal(names(m$workspace), "pdm"); expect_true("rules" %in% names(m$user_setup))

  TargetWise:::save_session(d$uploaded_df, d$user_setup, d$modification_log, name = "Chad 2026",
                            workspace = d$workspace, kind = "design")
  TargetWise:::save_session(s$uploaded_df, s$user_setup, s$modification_log, name = "Chad 2026",
                            workspace = s$workspace, kind = "selection")
  l <- TargetWise:::list_saved_sessions()
  expect_setequal(l$name, c("Chad_2026.design", "Chad_2026.selection"))
  expect_setequal(l$kind, c("design", "selection"))
  expect_equal(unique(l$label), "Chad_2026")
  got <- TargetWise:::load_session("Chad_2026.design")
  expect_equal(got$kind, "design"); expect_null(got$uploaded_df)
  # loading Design puts its entries back and keeps the other phases' ones
  merged <- TargetWise:::log_merge(log[2:3, ], got$modification_log, "design")
  expect_equal(merged$action, log$action)
  TargetWise:::delete_session("Chad_2026.design")
  expect_equal(TargetWise:::list_saved_sessions()$name, "Chad_2026.selection")
})

test_that("Save writes one session per workstream and Load brings one back beside the rest", {
  withr::local_envvar(TARGETWISE_SESSION_DIR = withr::local_tempdir(), TARGETWISE_SAVE_REMINDER_MIN = "0")
  ws <- TargetWise:::workspace_new()
  design <- NULL
  TargetWise:::workspace_register(ws, "scorecard", function() list(data = data.frame(x = 1:3), threshold = 2),
                                  function(s) design <<- s)
  df <- shiny::reactiveVal(data.frame(id = 1:5))
  setup <- shiny::reactiveValues(unique_id = "id", country_office = "Chad")
  log <- shiny::reactiveVal(data.frame(timestamp = "2026-01-01 10:00:00", action = "Duplicate deletion", stringsAsFactors = FALSE))
  shiny::testServer(TargetWise:::mod_session_manager_server,
                    args = list(uploaded_df = df, user_setup = setup, modification_log = log, workspace = ws), {
    session$setInputs(save_session_name = "Chad", save_kinds = c("design", "selection"), btn_confirm_save = 1)
    l <- TargetWise:::list_saved_sessions()
    expect_setequal(l$name, c("Chad.design", "Chad.selection"))
    expect_null(TargetWise:::load_session("Chad.design")$uploaded_df)
    expect_equal(nrow(TargetWise:::load_session("Chad.selection")$uploaded_df), 5)

    # Loading the Design session leaves the registration data in memory.
    df(data.frame(id = 1:9))
    session$setInputs(load_session_choice = "Chad.design", btn_menu_load = 1)
    expect_equal(design$threshold, 2)
    expect_equal(nrow(df()), 9)
    expect_equal(session_names$design, "Chad")
  })
})
