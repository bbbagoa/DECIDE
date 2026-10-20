test_that("update availability compares versions and tolerates unknowns", {
  ua <- DECIDE:::update_available
  expect_true(ua("0.1.0", "0.2.0"))
  expect_true(ua("0.1.0", "0.1.0.9000"))
  expect_false(ua("0.2.0", "0.2.0"))
  expect_false(ua("0.3.0", "0.2.0"))
  expect_false(ua(NULL, "0.2.0"))
  expect_false(ua("0.1.0", NULL))
})

test_that("the update check can be switched off", {
  withr::local_envvar(DECIDE_UPDATE_CHECK = "false")
  expect_null(DECIDE:::update_status())
})

test_that("the release repository index is read and compared", {
  dir <- withr::local_tempdir()
  dir.create(file.path(dir, "src", "contrib"), recursive = TRUE)
  writeLines(c("Package: DECIDE", "Version: 9.9.9", "", "Package: other", "Version: 1.0"),
             file.path(dir, "src", "contrib", "PACKAGES"))
  url <- paste0("file:///", normalizePath(dir, winslash = "/"))
  expect_equal(as.character(DECIDE:::release_version(url)), "9.9.9")
  expect_null(DECIDE:::release_version(paste0(url, "/missing")))
})
