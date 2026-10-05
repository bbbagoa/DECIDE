test_that("resources are served under a version that changes with each installation", {
  old <- tw_state$built
  on.exit(tw_state$built <- old)
  tw_state$built <- "R 4.6.1; ; 2026-10-05 17:02:11 UTC; windows"
  v <- tw_resource_version()
  expect_equal(v, paste0(as.character(utils::packageVersion("TargetWise")), ".20261005.170211"))
  expect_s3_class(package_version(v), "package_version")
  tw_state$built <- "R 4.6.1; ; 2026-10-06 08:00:00 UTC; windows"
  expect_false(identical(tw_resource_version(), v))
  tw_state$built <- NA_character_          # from source: still a valid version
  expect_s3_class(package_version(tw_resource_version()), "package_version")
})

test_that("an installation newer than the loaded one is noticed", {
  old <- tw_state$built
  on.exit(tw_state$built <- old)
  tw_state$built <- NA_character_
  expect_false(tw_updated_since_load())    # running from source: no check
  now <- tw_build_stamp()
  skip_if(is.na(now), "TargetWise is not installed")
  tw_state$built <- now
  expect_false(tw_updated_since_load())
  tw_state$built <- "R 4.6.1; ; 2000-01-01 00:00:00 UTC; windows"
  expect_true(tw_updated_since_load())
})
