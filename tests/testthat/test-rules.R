demo_df <- function() {
  data.frame(
    id = 1:8,
    score = c(25, 18, 17, 30, NA, 12, 22, 19),
    status = c("IDP", "Resident", "IDP", "Returnee", "IDP", "Resident", "", "Refugee"),
    sex = c("F", "M", "F", "F", "M", "F", "M", "F"),
    kids = c(3, 0, 2, 1, 4, 0, 1, 0),
    stringsAsFactors = FALSE
  )
}

demo_settings <- function() {
  list(v_score = "score", residency = "status", hhh_sex = "sex", childU5 = "kids")
}

one <- function(...) list(groups = list(list(rules = list(...))))
cond <- function(key, op, value = character(0)) {
  list(key = key, col = NA_character_, op = op, value = value)
}

test_that("an empty rule set keeps everyone", {
  df <- demo_df()
  ev <- TargetWise:::ruleset_eval(df, TargetWise:::ruleset_empty(), demo_settings())
  expect_true(all(ev$mask))
  expect_equal(ev$n_match, nrow(df))
})

test_that("conditions inside a group are ANDed", {
  df <- demo_df()
  rs <- one(cond("v_score", ">=", "18"), cond("residency", "in", c("IDP", "Returnee")))
  ev <- TargetWise:::ruleset_eval(df, rs, demo_settings())
  # rows 1 (25/IDP), 4 (30/Returnee). Row 3 is IDP but scores 17; row 2 scores
  # 18 but is Resident; row 5 is IDP but has no score.
  expect_equal(which(ev$mask), c(1L, 4L))
})

test_that("groups are ORed, so (A AND B) OR C works", {
  df <- demo_df()
  rs <- list(groups = list(
    list(rules = list(cond("v_score", ">=", "22"), cond("hhh_sex", "==", "F"))),
    list(rules = list(cond("childU5", ">=", "4")))
  ))
  ev <- TargetWise:::ruleset_eval(df, rs, demo_settings())
  # Group 1: rows 1 (25, F) and 4 (30, F). Group 2: row 5 (4 children).
  expect_equal(which(ev$mask), c(1L, 4L, 5L))
})

test_that("a missing value never qualifies a household, and is counted", {
  df <- demo_df()
  rs <- one(cond("v_score", ">=", "10"))
  ev <- TargetWise:::ruleset_eval(df, rs, demo_settings())
  expect_false(ev$mask[5])           # row 5 has no score
  expect_equal(ev$n_undecided, 1L)

  # Blank strings count as missing, not as a value that can pass "is none of".
  rs2 <- one(cond("residency", "not in", "Resident"))
  ev2 <- TargetWise:::ruleset_eval(df, rs2, demo_settings())
  expect_false(ev2$mask[7])          # row 7 has an empty status
  expect_true(ev2$mask[1])
})

test_that("string and numeric comparison are both reachable", {
  df <- demo_df()
  s <- demo_settings()
  expect_equal(which(TargetWise:::ruleset_eval(df, one(cond("hhh_sex", "==", "M")), s)$mask),
               c(2L, 5L, 7L))
  expect_equal(which(TargetWise:::ruleset_eval(df, one(cond("v_score", "<", "18")), s)$mask),
               c(3L, 6L))
  expect_equal(which(TargetWise:::ruleset_eval(df, one(cond("residency", "contains", "ref")), s)$mask),
               8L)
  expect_equal(which(TargetWise:::ruleset_eval(df, one(cond("v_score", "is missing")), s)$mask),
               5L)
  expect_equal(which(TargetWise:::ruleset_eval(df, one(cond("residency", "is missing")), s)$mask),
               7L)
})

test_that("a rule pointing at an unmapped field excludes rather than includes", {
  df <- demo_df()
  # disability was never mapped in these settings.
  rs <- one(cond("disability", "==", "Yes"))
  ev <- TargetWise:::ruleset_eval(df, rs, demo_settings())
  expect_false(any(ev$mask))
  expect_equal(ev$unresolved, "disability")
})

test_that("rules follow the mapping, so a renamed column still works", {
  df <- demo_df()
  names(df)[names(df) == "score"] <- "Scoring_total_v2"
  rs <- one(cond("v_score", ">=", "22"))
  s <- demo_settings()
  s$v_score <- "Scoring_total_v2"          # profile re-pointed at the new name
  # 1 (25), 4 (30) and 7 (exactly 22) all clear the threshold.
  expect_equal(which(TargetWise:::ruleset_eval(df, rs, s)$mask), c(1L, 4L, 7L))
})

test_that("a rule set describes itself for the report", {
  rs <- list(groups = list(
    list(rules = list(cond("v_score", ">=", "18"), cond("residency", "in", c("IDP", "Returnee")))),
    list(rules = list(cond("childU5", ">=", "4")))
  ))
  txt <- TargetWise:::ruleset_describe(rs, demo_settings(),
                                                c(v_score = "Vulnerability score",
                                                  residency = "Residence type",
                                                  childU5 = "Children under 5"))
  expect_match(txt, "Vulnerability score \\(score\\) is at least 18")
  expect_match(txt, "AND")
  expect_match(txt, "OR")
  expect_match(txt, "Children under 5")
  expect_match(TargetWise:::ruleset_describe(TargetWise:::ruleset_empty()),
               "No eligibility rules")
})

test_that("a rule set survives the profile round-trip", {
  rs <- one(cond("v_score", ">=", "18"), cond("residency", "in", c("IDP", "Returnee")))
  settings <- c(demo_settings(), list(unique_id = "id", rules = rs))
  p <- TargetWise:::profile_from_settings(settings, name = "with-rules")
  back <- TargetWise:::profile_from_json(TargetWise:::profile_to_json(p))

  ev <- TargetWise:::ruleset_eval(demo_df(), back$rules, demo_settings())
  expect_equal(which(ev$mask), c(1L, 4L))
})
