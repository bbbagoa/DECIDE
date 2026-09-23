tm <- function(f) utils::getFromNamespace(f, "TargetWise")

# A synthetic assessment where the truth is known: vulnerability is driven by
# two inclusion criteria and suppressed by one exclusion criterion, and two
# further columns are pure noise.
demo_assessment <- function(n = 1200, seed = 42) {
  set.seed(seed)
  tent <- rbinom(n, 1, 0.30)
  nolight <- rbinom(n, 1, 0.35)
  cattle <- rbinom(n, 1, 0.20)
  noise1 <- rbinom(n, 1, 0.50)
  noise2 <- rbinom(n, 1, 0.10)
  lp <- -0.4 + 1.6 * tent + 1.2 * nolight - 1.5 * cattle
  y <- rbinom(n, 1, 1 / (1 + exp(-lp)))
  data.frame(
    hh = sprintf("HH%04d", seq_len(n)),
    Targ_HHHousingTent = ifelse(tent == 1, "Yes", "No"),
    Targ_HHNoLight = ifelse(nolight == 1, "Yes", "No"),
    Targ_HHOwnCattle2more = ifelse(cattle == 1, "Yes", "No"),
    Targ_Noise1 = ifelse(noise1 == 1, "Yes", "No"),
    Targ_Noise2 = ifelse(noise2 == 1, "Yes", "No"),
    FSI_CARI2_2class = ifelse(y == 1, "Food insecure", "Food secure"),
    FCS_class = sample(c("Poor", "Acceptable"), n, TRUE),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# Advisory Issue 1/2025: outcome indicators are not eligibility criteria
# ---------------------------------------------------------------------------

test_that("food-security outcome indicators are recognised by name", {
  cols <- c("FCS", "fcs_class", "rCSI", "LCSI_cat", "FSI_CARI2_2class",
            "HHS_score", "food_consumption_score", "hdds", "FES_share",
            "IPC_phase", "MealsPerDay")
  expect_setequal(tm("outcome_like_columns")(cols), cols)

  # Legitimate vulnerability criteria are not caught. HHSize is the trap: an
  # unbounded "hhs" pattern swallows household size, which is both a perfectly
  # good criterion and one of the most common columns in a WFP dataset.
  ok <- c("Targ_HHHousingTent", "Targ_HHDepRatio2plus", "HHSize", "HHSize24M",
          "AgeHHH", "Targ_HHOwnCattle2more", "Targ_HHNoLight", "admin1",
          "Village", "HHStatus", "Confession")
  expect_equal(tm("outcome_like_columns")(ok), character(0))
})

test_that("the outcome and outcome-like columns are blocked as criteria, with a reason", {
  df <- demo_assessment(200)
  blockers <- tm("criterion_blockers")(
    df,
    c("Targ_HHHousingTent", "FSI_CARI2_2class", "FCS_class", "hh"),
    outcome = "FSI_CARI2_2class"
  )

  expect_false("Targ_HHHousingTent" %in% names(blockers))
  expect_match(blockers[["FSI_CARI2_2class"]], "outcome the scorecard predicts")
  expect_match(blockers[["FCS_class"]], "Targeting Advisory 1/2025")
  expect_match(blockers[["hh"]], "Not binary")
})

# ---------------------------------------------------------------------------
# Coercion
# ---------------------------------------------------------------------------

test_that("the vulnerable level is chosen by meaning, not alphabetically", {
  g <- tm("guess_positive_level")
  # The trap: "Food insecure" sorts FIRST and contains the substring "secure".
  # Taking the second sorted level, or matching "secur", inverts the whole
  # scorecard -- every inclusion criterion becomes an exclusion criterion.
  expect_equal(g(c("Food insecure", "Food secure")), "Food insecure")
  expect_equal(g(c("Food secure", "Food insecure")), "Food insecure")
  expect_equal(g(c("No", "Yes")), "Yes")
  expect_equal(g(c("Non", "Oui")), "Oui")
  expect_equal(g(c("Acceptable", "Poor")), "Poor")
  expect_equal(g(c("Not vulnerable", "Vulnerable")), "Vulnerable")
  # Nothing recognisable: deterministic, and the UI offers an override.
  expect_equal(g(c("Alpha", "Beta")), "Beta")
})

test_that("an explicit positive level always overrides the guess", {
  x <- c("Food insecure", "Food secure", "Food insecure")
  expect_equal(tm("as_binary_outcome")(x, "Food insecure"), c(1L, 0L, 1L))
  # Deliberately inverted, to prove the argument is honoured rather than
  # second-guessed.
  expect_equal(tm("as_binary_outcome")(x, "Food secure"), c(0L, 1L, 0L))
})

test_that("binary criteria are recognised however they are coded", {
  f <- tm("as_binary_criterion")
  expect_equal(f(c("Yes", "No", "Yes")), c(1L, 0L, 1L))
  expect_equal(f(c(TRUE, FALSE)), c(1L, 0L))
  expect_equal(f(c(1, 0, 1)), c(1L, 0L, 1L))
  expect_equal(f(c("Oui", "Non")), c(1L, 0L))
  # Blank strings are missing, not a third level.
  expect_equal(f(c("Yes", "", "No")), c(1L, NA, 0L))
  # Three levels or a continuous column is not a criterion.
  expect_null(f(c("a", "b", "c")))
  expect_null(f(c(1, 5, 9)))
})

# ---------------------------------------------------------------------------
# Screening
# ---------------------------------------------------------------------------

test_that("screening finds the real drivers and their direction, not the noise", {
  df <- demo_assessment()
  res <- tm("screen_criteria")(
    df, "FSI_CARI2_2class",
    c("Targ_HHHousingTent", "Targ_HHNoLight", "Targ_HHOwnCattle2more",
      "Targ_Noise1", "Targ_Noise2"),
    outcome_positive = "Food insecure"
  )

  sig <- res[res$significant, ]
  expect_setequal(sig$criterion,
                  c("Targ_HHHousingTent", "Targ_HHNoLight", "Targ_HHOwnCattle2more"))

  dir <- stats::setNames(res$direction, res$criterion)
  expect_equal(dir[["Targ_HHHousingTent"]], "inclusion")
  expect_equal(dir[["Targ_HHNoLight"]], "inclusion")
  expect_equal(dir[["Targ_HHOwnCattle2more"]], "exclusion")

  # Odds ratios recover the planted effects (exp(1.6), exp(1.2), exp(-1.5)).
  or <- stats::setNames(res$or, res$criterion)
  expect_gt(or[["Targ_HHHousingTent"]], 3)
  expect_lt(or[["Targ_HHOwnCattle2more"]], 0.45)

  # Adjusted p-values are never smaller than the raw ones.
  expect_true(all(res$p_adj >= res$p_value - 1e-12, na.rm = TRUE))
})

test_that("a constant criterion is reported rather than crashing the screen", {
  df <- demo_assessment(200)
  df$Targ_AllNo <- "No"
  res <- tm("screen_criteria")(df, "FSI_CARI2_2class",
                               c("Targ_HHHousingTent", "Targ_AllNo"),
                               outcome_positive = "Food insecure")
  row <- res[res$criterion == "Targ_AllNo", ]
  expect_equal(row$test, "constant")
  expect_false(row$significant)
})

# ---------------------------------------------------------------------------
# Collinearity
# ---------------------------------------------------------------------------

test_that("a duplicated criterion is dropped so its effect is not counted twice", {
  df <- demo_assessment(400)
  df$Targ_TentCopy <- df$Targ_HHHousingTent          # perfectly collinear
  res <- tm("drop_collinear")(
    df, c("Targ_HHHousingTent", "Targ_TentCopy", "Targ_HHNoLight"), cutoff = 0.8
  )
  expect_length(res$keep, 2)
  expect_true("Targ_HHNoLight" %in% res$keep)
  expect_equal(length(res$dropped), 1)
  expect_true(names(res$dropped) %in% c("Targ_HHHousingTent", "Targ_TentCopy"))
})

# ---------------------------------------------------------------------------
# Model and scoring
# ---------------------------------------------------------------------------

test_that("the fitted weights are odds ratios pointing the right way", {
  df <- demo_assessment()
  fit <- tm("fit_scorecard_model")(
    df, "FSI_CARI2_2class",
    c("Targ_HHHousingTent", "Targ_HHNoLight", "Targ_HHOwnCattle2more"),
    outcome_positive = "Food insecure"
  )

  expect_true(fit$converged)
  expect_equal(nrow(fit$weights), 3)
  w <- stats::setNames(fit$weights$odds_ratio, fit$weights$criterion)
  expect_gt(w[["Targ_HHHousingTent"]], 1)
  expect_lt(w[["Targ_HHOwnCattle2more"]], 1)
  # weight is the rounded odds ratio, which is what the paper scorecard uses.
  expect_equal(fit$weights$weight, round(fit$weights$odds_ratio, 2))
})

test_that("scoring adds inclusion points, subtracts exclusion points and floors at zero", {
  sc <- list(
    outcome = "FSI", outcome_positive = "Food insecure", threshold = 0,
    items = list(
      list(criterion = "a", direction = "inclusion", weight = 2.5),
      list(criterion = "b", direction = "inclusion", weight = 1.5),
      list(criterion = "c", direction = "exclusion", weight = 3.0)
    )
  )
  df <- data.frame(
    a = c("Yes", "Yes", "No",  "No"),
    b = c("Yes", "No",  "No",  "Yes"),
    c = c("No",  "Yes", "Yes", "Yes"),
    stringsAsFactors = FALSE
  )
  out <- tm("apply_scorecard")(df, sc)

  expect_equal(out$score, c(4.0, -0.5 + 0.5, 0, 0))   # 4.0, 0 (floored), 0, 0
  expect_equal(out$score[2], 0)                        # 2.5 - 3.0 floored to 0
  expect_equal(out$eligible, c(TRUE, FALSE, FALSE, FALSE))
  expect_equal(out$missing_criteria, character(0))
})

test_that("a criterion missing from the data is reported, not silently scored as failed", {
  sc <- list(threshold = 0, items = list(
    list(criterion = "a", direction = "inclusion", weight = 2),
    list(criterion = "gone_in_this_round", direction = "inclusion", weight = 5)
  ))
  df <- data.frame(a = c("Yes", "No"), stringsAsFactors = FALSE)
  out <- tm("apply_scorecard")(df, sc)
  expect_equal(out$score, c(2, 0))
  expect_equal(out$missing_criteria, "gone_in_this_round")
})

# ---------------------------------------------------------------------------
# ROC (Advisory Issue 3/2025)
# ---------------------------------------------------------------------------

test_that("AUC is 1 for a perfect score, 0.5 for a useless one", {
  y <- rep(c(1, 0), each = 50)
  perfect <- c(runif(50, 0.6, 1), runif(50, 0, 0.4))
  expect_equal(tm("roc_curve")(perfect, y)$auc, 1)

  set.seed(9)
  useless <- runif(100)
  expect_equal(tm("roc_curve")(useless, y)$auc, 0.5, tolerance = 0.12)
})

test_that("the ROC curve carries the design errors at every threshold", {
  df <- demo_assessment()
  y <- tm("as_binary_outcome")(df$FSI_CARI2_2class, positive = "Food insecure")
  fit <- tm("fit_scorecard_model")(
    df, "FSI_CARI2_2class",
    c("Targ_HHHousingTent", "Targ_HHNoLight", "Targ_HHOwnCattle2more"),
    outcome_positive = "Food insecure"
  )
  sc <- tm("build_scorecard")(fit$weights, threshold = 0)
  sc$outcome_positive <- "Food insecure"
  scored <- tm("apply_scorecard")(df, sc)

  r <- tm("roc_curve")(scored$score, y)
  expect_gt(r$auc, 0.6)
  expect_true(all(r$curve$tpr >= 0 & r$curve$tpr <= 1))
  expect_true(all(r$curve$exclusion_error >= 0 & r$curve$exclusion_error <= 1))

  # Raising the bar can only exclude more people, never fewer.
  ord <- order(r$curve$threshold)
  expect_true(!is.unsorted(r$curve$exclusion_error[ord]))
})

# ---------------------------------------------------------------------------
# Design errors (Advisory Issue 2/2025)
# ---------------------------------------------------------------------------

test_that("design errors reproduce the advisory's worked example", {
  # Advisory Issue 2/2025, page 4: eligible 40 vulnerable / 10 not,
  # not eligible 30 vulnerable / 20 not. Inclusion 20%, exclusion 43%.
  eligible   <- c(rep(TRUE, 50), rep(FALSE, 50))
  vulnerable <- c(rep(TRUE, 40), rep(FALSE, 10), rep(TRUE, 30), rep(FALSE, 20))

  e <- tm("design_errors")(eligible, vulnerable)
  expect_equal(e$inclusion_error, 10 / 50)
  expect_equal(round(e$exclusion_error, 4), round(30 / 70, 4))
  expect_equal(round(100 * e$inclusion_error), 20)
  expect_equal(round(100 * e$exclusion_error), 43)
  expect_equal(e$correctly_included, 40)
  expect_equal(e$correctly_excluded, 20)
})

test_that("the verdict follows the advisory's decision table", {
  v <- tm("error_verdict")

  expect_equal(v(0.04, 0.03)$level, "good")
  expect_equal(v(0.04, 0.15)$level, "review")
  expect_equal(v(0.15, 0.04)$level, "review")
  expect_equal(v(0.04, 0.35)$level, "redesign")
  expect_equal(v(0.35, 0.04)$level, "redesign")
  expect_equal(v(0.35, 0.35)$level, "redesign")
  expect_match(v(0.35, 0.35)$action, "Fully review")

  # An upper tolerance at or above 50% is refused: at 50% the design is no
  # better than random selection, which the advisory states outright.
  expect_error(v(0.1, 0.1, lower = 0.05, upper = 0.5), "no better than random")
  expect_equal(v(NA_real_, 0.1)$level, "unknown")
})

# ---------------------------------------------------------------------------
# Bands
# ---------------------------------------------------------------------------

test_that("score bands split only the households that actually score", {
  score <- c(rep(0, 40), seq(1, 20, length.out = 200))
  q4 <- tm("score_bands")(score, 4L)
  expect_equal(nrow(q4), 4)
  expect_equal(sum(q4$households), 200)       # the 40 zero-scorers are excluded
  expect_true(all(diff(q4$from) > 0))

  q5 <- tm("score_bands")(score, 5L)
  expect_equal(nrow(q5), 5)
  expect_equal(sum(q5$households), 200)

  expect_equal(nrow(tm("score_bands")(c(0, 0, 0), 4L)), 0)
})

# ---------------------------------------------------------------------------
# Persistence: the scorecard travels inside the setup profile
# ---------------------------------------------------------------------------

test_that("a scorecard survives the profile round-trip and still scores the same", {
  df <- demo_assessment(600)
  fit <- tm("fit_scorecard_model")(
    df, "FSI_CARI2_2class",
    c("Targ_HHHousingTent", "Targ_HHNoLight", "Targ_HHOwnCattle2more"),
    outcome_positive = "Food insecure"
  )
  sc <- tm("build_scorecard")(fit$weights, outcome = "FSI_CARI2_2class",
                              outcome_positive = "Food insecure", threshold = 1.5)
  before <- tm("apply_scorecard")(df, sc)

  settings <- list(unique_id = "hh", scorecard = sc)
  p <- tm("profile_from_settings")(settings, name = "with-scorecard")
  back <- tm("profile_from_json")(tm("profile_to_json")(p))

  expect_equal(back$scorecard$outcome, "FSI_CARI2_2class")
  expect_equal(back$scorecard$outcome_positive, "Food insecure")
  expect_equal(back$scorecard$threshold, 1.5)
  expect_equal(length(back$scorecard$items), length(sc$items))

  after <- tm("apply_scorecard")(df, back$scorecard)
  expect_equal(after$score, before$score)
  expect_equal(after$eligible, before$eligible)
})

test_that("a malformed scorecard item is dropped, not scored as zero-weight", {
  raw <- list(
    outcome = "FSI", outcome_positive = "Food insecure", threshold = "2",
    items = list(
      list(criterion = "a", direction = "inclusion", weight = "2.5"),
      list(criterion = "b", direction = "wat", weight = 1),
      list(criterion = NULL, direction = "inclusion", weight = 9),
      list(criterion = "d", direction = "exclusion", weight = NULL)
    )
  )
  sc <- tm("normalise_scorecard")(raw)
  expect_equal(sc$threshold, 2)
  expect_equal(length(sc$items), 2)
  expect_equal(vapply(sc$items, function(i) i$criterion, character(1)), c("a", "b"))
  # An unrecognised direction defaults to inclusion rather than silently
  # flipping a criterion's sign.
  expect_equal(sc$items[[2]]$direction, "inclusion")
  expect_equal(sc$items[[1]]$weight, 2.5)
})

# ---------------------------------------------------------------------------
# Crosswalk: applying a scorecard to a differently-named dataset
# ---------------------------------------------------------------------------

test_that("criteria are matched to registration columns by exact, case, shape then distance", {
  sc <- list(threshold = 0, items = list(
    list(criterion = "Targ_HHNoLight",     direction = "inclusion", weight = 2),
    list(criterion = "Targ_HHHousingTent", direction = "inclusion", weight = 3),
    list(criterion = "Targ_HHOwnCattle",   direction = "exclusion", weight = 1),
    list(criterion = "Targ_HHRemittance",  direction = "exclusion", weight = 1),
    list(criterion = "Targ_HHNothingLikeThis", direction = "inclusion", weight = 1)
  ))
  reg <- data.frame(
    Targ_HHNoLight   = c("Yes", "No"),       # exact
    targ_hhhousingtent = c("Yes", "No"),     # case only
    NoCattle_HH      = c("Yes", "No"),       # decoy, should not win
    OwnCattle        = c("Yes", "No"),       # normalised (Targ_/HH stripped)
    Targ_HHRemittence = c("Yes", "No"),      # misspelled -> approximate
    age              = c(30, 40),            # not binary, never offered
    stringsAsFactors = FALSE
  )

  m <- tm("match_scorecard_columns")(sc, reg)
  by <- stats::setNames(m$column, m$criterion)
  meth <- stats::setNames(m$method, m$criterion)

  expect_equal(by[["Targ_HHNoLight"]], "Targ_HHNoLight");        expect_equal(meth[["Targ_HHNoLight"]], "exact")
  expect_equal(by[["Targ_HHHousingTent"]], "targ_hhhousingtent"); expect_equal(meth[["Targ_HHHousingTent"]], "case")
  expect_equal(by[["Targ_HHOwnCattle"]], "OwnCattle");            expect_equal(meth[["Targ_HHOwnCattle"]], "normalised")
  expect_equal(by[["Targ_HHRemittance"]], "Targ_HHRemittence");   expect_equal(meth[["Targ_HHRemittance"]], "approximate")

  # No plausible match is better than a wrong one.
  expect_true(is.na(by[["Targ_HHNothingLikeThis"]]))
  expect_equal(meth[["Targ_HHNothingLikeThis"]], "none")

  # A continuous column is never proposed: a criterion is a yes/no.
  expect_false("age" %in% m$column)
})

test_that("a mapped scorecard scores the registration data through the crosswalk", {
  sc <- list(threshold = 0, items = list(
    list(criterion = "Targ_HHNoLight",     direction = "inclusion", weight = 2),
    list(criterion = "Targ_HHOwnCattle",   direction = "exclusion", weight = 1)
  ))
  reg <- data.frame(
    light_missing = c("Yes", "Yes", "No", "No"),
    cattle_owned  = c("No",  "Yes", "Yes", "No"),
    stringsAsFactors = FALSE
  )

  # Unmapped, the criteria name columns that do not exist: nobody scores, and
  # the fact is reported rather than looking like a legitimate zero.
  before <- tm("apply_scorecard")(reg, sc)
  expect_equal(before$score, rep(0, 4))
  expect_setequal(before$missing_criteria, c("Targ_HHNoLight", "Targ_HHOwnCattle"))

  mapped <- tm("apply_scorecard_mapping")(sc, c(
    Targ_HHNoLight = "light_missing", Targ_HHOwnCattle = "cattle_owned"
  ))
  after <- tm("apply_scorecard")(reg, mapped)
  expect_equal(after$score, c(2, 1, 0, 0))     # 2, 2-1, 0-1 floored, 0
  expect_equal(after$missing_criteria, character(0))
  expect_equal(after$eligible, c(TRUE, TRUE, FALSE, FALSE))
})

test_that("readiness reports exactly which criteria have nowhere to read from", {
  sc <- list(threshold = 0, items = list(
    list(criterion = "a", direction = "inclusion", weight = 1, column = "col_a"),
    list(criterion = "b", direction = "inclusion", weight = 1, column = NA_character_),
    list(criterion = "c", direction = "inclusion", weight = 1, column = "gone")
  ))
  df <- data.frame(col_a = 1:2, b = 1:2, stringsAsFactors = FALSE)
  r <- tm("scorecard_readiness")(sc, df)
  expect_equal(r$n, 3)
  expect_equal(r$mapped, 2)          # col_a, and b falling back to its own name
  expect_equal(r$unmapped, 1)
  expect_equal(r$missing, "gone")
  expect_false(r$ready)
})

# ---------------------------------------------------------------------------
# The workbook is a deliverable AND a machine input
# ---------------------------------------------------------------------------

test_that("a scorecard survives the Excel round-trip, including a hand-edited crosswalk", {
  skip_if_not_installed("openxlsx")
  df <- demo_assessment(400)
  fit <- tm("fit_scorecard_model")(
    df, "FSI_CARI2_2class",
    c("Targ_HHHousingTent", "Targ_HHNoLight", "Targ_HHOwnCattle2more"),
    outcome_positive = "Food insecure"
  )
  sc <- tm("build_scorecard")(fit$weights, outcome = "FSI_CARI2_2class",
                              outcome_positive = "Food insecure", threshold = 1.25)

  meta <- list(Outcome = "FSI_CARI2_2class", `Vulnerable level` = "Food insecure",
               `Eligibility threshold` = "score > 1.25", `Designed on` = "2023-01-15")
  wb <- tm("scorecard_workbook")(sc, meta = meta)
  f <- withr::local_tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(wb, f, overwrite = TRUE)

  back <- tm("read_scorecard_workbook")(f)
  expect_equal(length(back$items), length(sc$items))
  expect_equal(back$outcome, "FSI_CARI2_2class")
  expect_equal(back$outcome_positive, "Food insecure")
  expect_equal(back$threshold, 1.25)
  # The design date survives the round trip, so staleness can be flagged.
  expect_equal(back$created, "2023-01-15")
  expect_gt(tm("scorecard_age_months")(back, today = as.Date("2026-01-15")), 35)
  expect_true(is.na(tm("scorecard_age_months")(list(created = NA))))

  w_before <- vapply(sc$items, function(i) i$weight, numeric(1))
  w_after <- vapply(back$items, function(i) i$weight, numeric(1))
  expect_equal(w_after, w_before)
  expect_equal(vapply(back$items, function(i) i$direction, character(1)),
               vapply(sc$items, function(i) i$direction, character(1)))

  # Scores identically on the data it was built from.
  expect_equal(tm("apply_scorecard")(df, back)$score,
               tm("apply_scorecard")(df, sc)$score)

  # A crosswalk typed into the sheet by hand comes back with the card.
  mapped <- tm("apply_scorecard_mapping")(sc, stats::setNames(
    paste0("reg_", seq_along(sc$items)), vapply(sc$items, function(i) i$criterion, character(1))
  ))
  wb2 <- tm("scorecard_workbook")(mapped, meta = meta)
  f2 <- withr::local_tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(wb2, f2, overwrite = TRUE)
  back2 <- tm("read_scorecard_workbook")(f2)
  expect_equal(vapply(back2$items, function(i) i$column, character(1)),
               paste0("reg_", seq_along(sc$items)))
})

test_that("a workbook that is not a scorecard is refused with a reason", {
  skip_if_not_installed("openxlsx")
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Sheet1")
  openxlsx::writeData(wb, "Sheet1", data.frame(a = 1:3))
  f <- withr::local_tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(wb, f, overwrite = TRUE)
  expect_error(tm("read_scorecard_workbook")(f), "no 'Scorecard' sheet")

  # Right sheet name, wrong headers: rejected rather than half-read.
  wb2 <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb2, "Scorecard")
  openxlsx::writeData(wb2, "Scorecard", data.frame(Thing = "x", Amount = 1))
  f2 <- withr::local_tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(wb2, f2, overwrite = TRUE)
  expect_error(tm("read_scorecard_workbook")(f2), "missing the column")
})

test_that("balanced_threshold minimises the larger of the two design errors", {
  bt <- utils::getFromNamespace("balanced_threshold", "TargetWise")
  de <- utils::getFromNamespace("design_errors", "TargetWise")
  set.seed(3)
  y <- rbinom(600, 1, 0.45)
  s <- round(pmax(0, 3 * y + rnorm(600, 0, 1.6)), 1)
  r <- bt(s, y)
  e <- de(s > r$threshold, y == 1)
  expect_equal(r$inclusion_error, e$inclusion_error)
  expect_equal(r$exclusion_error, e$exclusion_error)
  # No other cut-point has a smaller worst error.
  worst <- vapply(sort(unique(c(0, s))), function(t) {
    x <- de(s > t, y == 1); max(ifelse(is.na(x$inclusion_error), 1, x$inclusion_error), x$exclusion_error)
  }, numeric(1))
  expect_equal(max(r$inclusion_error, r$exclusion_error), min(worst))
  expect_true(is.na(bt(s, rep(1, 600))$threshold))
})
