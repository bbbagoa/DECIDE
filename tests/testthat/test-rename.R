test_that("settings are read under the new name, with the old name as fallback", {
  tw <- TargetWise:::tw_env
  withr::local_envvar(c(TARGETWISE_UPDATE_CHECK = NA, TARGETING_MONITOR_UPDATE_CHECK = "false"))
  expect_equal(tw("UPDATE_CHECK", "true"), "false")
  withr::local_envvar(c(TARGETWISE_UPDATE_CHECK = "true"))
  expect_equal(tw("UPDATE_CHECK", "x"), "true")          # the new name wins
  withr::local_envvar(c(TARGETWISE_UPDATE_CHECK = NA, TARGETING_MONITOR_UPDATE_CHECK = NA))
  expect_equal(tw("UPDATE_CHECK", "default"), "default")
})

test_that("sessions saved under the old name are brought over on first start", {
  home <- withr::local_tempdir()
  withr::local_envvar(c(R_USER_DATA_DIR = home, TARGETWISE_SESSION_DIR = NA, TARGETING_MONITOR_SESSION_DIR = NA))
  old <- tools::R_user_dir("TargetingMonitorApp", which = "data")
  dir.create(old, recursive = TRUE)
  writeLines("key", file.path(old, "session.key")); writeLines("s", file.path(old, "work.rds"))
  new <- TargetWise:::get_session_dir()
  expect_equal(normalizePath(new), normalizePath(tools::R_user_dir("TargetWise", which = "data")))
  expect_true(all(file.exists(file.path(new, c("session.key", "work.rds")))))
})
