local_profile_dir <- function(env = parent.frame()) {
  tmp <- tempfile()
  old <- Sys.getenv("DECIDE_SESSION_DIR", unset = NA)
  Sys.setenv(DECIDE_SESSION_DIR = tmp)
  withr::defer({
    if (is.na(old)) Sys.unsetenv("DECIDE_SESSION_DIR") else Sys.setenv(DECIDE_SESSION_DIR = old)
    unlink(tmp, recursive = TRUE)
  }, envir = env)
  tmp
}

test_that("a profile round-trips through JSON without losing the mapping", {
  settings <- list(
    unique_id = "instanceID", date = "SvyDate", admin1 = "Province",
    admin2 = "Territoire", v_score = "Scoring_total", v_groups = "Scoring_Class",
    weight = "", disability = NULL, force_numeric = c("Scoring_total")
  )
  p <- DECIDE:::profile_from_settings(settings, name = "DRC round 3")

  expect_equal(p$name, "DRC round 3")
  expect_equal(p$mapping$unique_id, "instanceID")
  # Unmapped fields travel as null, never as "" (which would look like a column).
  expect_true(is.na(p$mapping$weight))
  expect_true(is.na(p$mapping$disability))
  expect_equal(p$force_numeric, "Scoring_total")

  back <- DECIDE:::profile_from_json(DECIDE:::profile_to_json(p))
  expect_equal(back$mapping$unique_id, "instanceID")
  expect_equal(back$mapping$admin2, "Territoire")
  expect_true(is.na(back$mapping$weight))
  expect_equal(back$force_numeric, "Scoring_total")
})

test_that("match_profile separates what it can place from what it cannot", {
  p <- DECIDE:::profile_from_settings(
    list(unique_id = "instanceID", admin1 = "Province", v_score = "OldScoreName"),
    name = "last-round"
  )
  # The form was renamed between rounds: OldScoreName is gone.
  m <- DECIDE:::match_profile(p, c("instanceID", "Province", "NewScoreName"))

  expect_equal(m$applied_n, 2L)
  expect_equal(sort(names(m$mapping)), c("admin1", "unique_id"))
  expect_equal(m$missing_n, 1L)
  expect_equal(m$missing[["v_score"]], "OldScoreName")
  # Nothing is silently mapped to a column that does not exist.
  expect_false("v_score" %in% names(m$mapping))
})

test_that("profiles are stored, listed and deleted per user", {
  local_profile_dir()

  a <- DECIDE:::profile_from_settings(list(unique_id = "id_a"), name = "Mali CFM")
  b <- DECIDE:::profile_from_settings(list(unique_id = "id_b"), name = "Mali CFM")
  DECIDE:::save_profile(a, user = "alice@wfp.org")
  DECIDE:::save_profile(b, user = "bob@wfp.org")

  expect_equal(DECIDE:::list_profiles("alice@wfp.org")$name, "Mali_CFM")
  expect_equal(DECIDE:::load_profile("Mali CFM", "alice@wfp.org")$mapping$unique_id, "id_a")
  expect_equal(DECIDE:::load_profile("Mali CFM", "bob@wfp.org")$mapping$unique_id, "id_b")
  expect_null(DECIDE:::load_profile("Mali CFM", "carla@wfp.org"))

  DECIDE:::delete_profile("Mali CFM", "alice@wfp.org")
  expect_equal(nrow(DECIDE:::list_profiles("alice@wfp.org")), 0)
  expect_equal(nrow(DECIDE:::list_profiles("bob@wfp.org")), 1)
})

test_that("a non-profile JSON file is rejected rather than half-applied", {
  expect_error(DECIDE:::profile_from_json('{"hello":"world"}'),
               "not a DECIDE setup profile")
  expect_error(
    DECIDE:::profile_from_json('{"schema":99,"mapping":{"unique_id":"x"}}'),
    "newer version"
  )
})
