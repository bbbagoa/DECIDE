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
