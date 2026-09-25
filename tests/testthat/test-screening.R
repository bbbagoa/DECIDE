test_that("variable screening ranks variables and suggests yes/no versions", {
  set.seed(4)
  n <- 600
  y <- rbinom(n, 1, 0.4)
  df <- data.frame(
    tent = ifelse(runif(n) < 0.2 + 0.5 * y, "Yes", "No"),                     # strong yes/no
    hh_size = pmax(1, round(rnorm(n, 5 + 3 * y, 1.5))),                      # number: bigger when vulnerable
    water = sample(c("river", "well", "tap"), n, TRUE),                     # categories
    noise = runif(n), lat = runif(n), weight = runif(n), id = sprintf("h%04d", 1:n),
    stringsAsFactors = FALSE)
  df$water[y == 1 & runif(n) < 0.5] <- "river"
  s <- TargetWise:::screen_variables(df, y, exclude = "id")
  expect_true(all(c("tent", "hh_size", "water") %in% s$variable))
  expect_false(any(c("lat", "weight") %in% s$variable))          # coordinates and weights left out
  top <- s$variable[s$strength == "Strong"]
  expect_true(all(c("tent", "hh_size") %in% top))
  hs <- s[s$variable == "hh_size", ]
  expect_equal(hs$kind, "number")
  expect_equal(hs$rule[[1]]$op, ">=")
  expect_true(as.numeric(hs$rule[[1]]$value) %% 1 == 0)          # whole number cut-off
  w <- s[s$variable == "water", ]
  expect_equal(w$rule[[1]], list(op = "in", value = "river"))
  expect_null(s$rule[[which(s$variable == "tent")]])              # ready as it is
  expect_equal(s$strength[s$variable == "noise"], "Not significant")
  # the suggestion builds the variable it describes
  nm <- TargetWise:::screen_new_name("hh_size", hs$rule[[1]], names(df))
  v <- TargetWise:::calc_condition(df, list(list(column = "hh_size", op = ">=", value = hs$rule[[1]]$value)), coding = "yesno")
  expect_equal(mean(v == "Yes"), hs$yes_share)
  expect_match(nm, "^hh_size_ge[0-9]+$")
})

test_that("what a registration team cannot observe is never a criterion", {
  why <- TargetWise:::unobservable_reason
  blocked <- c("HHExpFood", "exp_food_1M", "Depense_sante", "FoodPrice", "LcsEN_reason", "LCS_Stress", "rCSILessQlty",
               "MEB_value", "UBT", "FCSStap", "HDDS_cereals", "phone_number", "TelNum", "mobile_number", "debt_amount", "HHEndettement")
  allowed <- c("Targ_HHCredAcc", "HHSize", "HHHSex", "Province", "hh_mobile_money", "displacement_reason", "Targ_HHHousingTent")
  expect_false(any(is.na(why(blocked))))
  expect_true(all(is.na(why(allowed))))
  df <- data.frame(HHExpFood = runif(50), phone_number = sample(c("Yes", "No"), 50, TRUE), tent = sample(c("Yes", "No"), 50, TRUE))
  b <- TargetWise:::criterion_blockers(df, names(df), "outcome")
  expect_match(b[["HHExpFood"]], "Not observable at registration (expenditure)", fixed = TRUE)
  expect_false("tent" %in% names(b))
  s <- TargetWise:::screen_variables(df, rbinom(50, 1, 0.5))
  expect_false(any(c("HHExpFood", "phone_number") %in% s$variable))
  expect_equal(TargetWise:::screen_new_name("score", list(op = ">=", value = "-1.51"), character(0)), "score_ge_m1_51")
})

test_that("screening odds ratios have 4 decimals at most", {
  set.seed(9); n <- 400; y <- rbinom(n, 1, 0.4)
  df <- data.frame(a = ifelse(runif(n) < 0.2 + 0.4 * y, "Yes", "No"), b = runif(n) * 7 + 3 * y, o = ifelse(y == 1, "V", "N"))
  dec <- function(x) { x <- x[!is.na(x)]; max(nchar(sub("^[^.]*[.]?", "", format(x, scientific = FALSE, drop0trailing = TRUE, trim = TRUE)))) }
  s <- TargetWise:::screen_variables(df, y, exclude = "o")
  expect_lte(dec(s$odds_ratio), 4)
  q <- TargetWise:::screen_criteria(df, "o", "a", outcome_positive = "V")
  expect_lte(dec(c(q$or, q$or_low, q$or_high)), 4)
})
