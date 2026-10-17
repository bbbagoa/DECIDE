test_that("settings are read under the new name, with the old name as fallback", {
  tw <- DECIDE:::tw_env
  withr::local_envvar(c(DECIDE_UPDATE_CHECK = NA, TARGETWISE_UPDATE_CHECK = NA, TARGETING_MONITOR_UPDATE_CHECK = "false"))
  expect_equal(tw("UPDATE_CHECK", "true"), "false")
  withr::local_envvar(c(TARGETWISE_UPDATE_CHECK = "true"))
  expect_equal(tw("UPDATE_CHECK", "x"), "true")          # the new name wins
  withr::local_envvar(c(TARGETWISE_UPDATE_CHECK = NA, TARGETING_MONITOR_UPDATE_CHECK = NA))
  expect_equal(tw("UPDATE_CHECK", "default"), "default")
})

test_that("sessions saved under the old name are brought over on first start", {
  home <- withr::local_tempdir()
  withr::local_envvar(c(R_USER_DATA_DIR = home, DECIDE_SESSION_DIR = NA, TARGETWISE_SESSION_DIR = NA, TARGETING_MONITOR_SESSION_DIR = NA))
  old <- tools::R_user_dir("TargetingMonitorApp", which = "data")
  dir.create(old, recursive = TRUE)
  writeLines("key", file.path(old, "session.key")); writeLines("s", file.path(old, "work.rds"))
  new <- DECIDE:::get_session_dir()
  expect_equal(normalizePath(new), normalizePath(tools::R_user_dir("DECIDE", which = "data")))
  expect_true(all(file.exists(file.path(new, c("session.key", "work.rds")))))
})

test_that("DECIDE_ settings win over the TargetWise ones, which still work", {
  tw <- DECIDE:::tw_env
  withr::local_envvar(c(DECIDE_CORES = NA, TARGETWISE_CORES = "3", TARGETING_MONITOR_CORES = NA))
  expect_equal(tw("CORES", ""), "3")
  withr::local_envvar(c(DECIDE_CORES = "5"))
  expect_equal(tw("CORES", ""), "5")
})

test_that("the TargetWise folder (sessions, key, settings) is brought over, the newer name first", {
  home <- withr::local_tempdir()
  withr::local_envvar(c(R_USER_DATA_DIR = home, DECIDE_SESSION_DIR = NA, TARGETWISE_SESSION_DIR = NA, TARGETING_MONITOR_SESSION_DIR = NA))
  tw_old <- tools::R_user_dir("TargetWise", which = "data"); oldest <- tools::R_user_dir("TargetingMonitorApp", which = "data")
  dir.create(tw_old, recursive = TRUE); dir.create(oldest, recursive = TRUE)
  writeLines("tw-key", file.path(tw_old, "session.key")); writeLines("old-key", file.path(oldest, "session.key"))
  new <- DECIDE:::get_session_dir()
  expect_equal(readLines(file.path(new, "session.key")), "tw-key")
  expect_true(dir.exists(tw_old))                          # a copy: the old folder stays
})

test_that("monitoring templates saved under the old name still open", {
  j <- jsonlite::toJSON(list(format = "TargetWise monitoring template", name = "Round 1",
                             items = list(list(title = "Complaints", spec = list(x = "type")))), auto_unbox = TRUE)
  expect_equal(DECIDE:::read_template_json(j)$name, "Round 1")
  expect_error(DECIDE:::read_template_json('{"format": "something else"}'), "not a DECIDE monitoring template")
})
