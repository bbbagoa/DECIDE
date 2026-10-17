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
  s <- DECIDE:::screen_variables(df, y, exclude = "id")
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
  nm <- DECIDE:::screen_new_name("hh_size", hs$rule[[1]], names(df))
  v <- DECIDE:::calc_condition(df, list(list(column = "hh_size", op = ">=", value = hs$rule[[1]]$value)), coding = "yesno")
  expect_equal(mean(v == "Yes"), hs$yes_share)
  expect_match(nm, "^hh_size_ge[0-9]+_Bin$")
})

test_that("what a registration team cannot observe is never a criterion", {
  why <- DECIDE:::unobservable_reason
  blocked <- c("HHExpFood", "exp_food_1M", "Depense_sante", "FoodPrice", "LcsEN_reason", "LCS_Stress", "rCSILessQlty",
               "MEB_value", "UBT", "FCSStap", "HDDS_cereals", "phone_number", "TelNum", "mobile_number", "debt_amount", "HHEndettement")
  allowed <- c("Targ_HHCredAcc", "HHSize", "HHHSex", "Province", "hh_mobile_money", "displacement_reason", "Targ_HHHousingTent")
  expect_false(any(is.na(why(blocked))))
  expect_true(all(is.na(why(allowed))))
  df <- data.frame(HHExpFood = runif(50), phone_number = sample(c("Yes", "No"), 50, TRUE), tent = sample(c("Yes", "No"), 50, TRUE))
  b <- DECIDE:::criterion_blockers(df, names(df), "outcome")
  expect_match(b[["HHExpFood"]], "Not observable at registration (expenditure)", fixed = TRUE)
  expect_false("tent" %in% names(b))
  s <- DECIDE:::screen_variables(df, rbinom(50, 1, 0.5))
  expect_false(any(c("HHExpFood", "phone_number") %in% s$variable))
  expect_equal(DECIDE:::screen_new_name("score", list(op = ">=", value = "-1.51"), character(0)), "score_ge_m1_51_Bin")
  expect_equal(DECIDE:::screen_new_name("hh size/2", list(op = "in", value = "a"), character(0)), "hh.size.2_grp_Bin")   # made valid
})

test_that("screening odds ratios have 4 decimals at most", {
  set.seed(9); n <- 400; y <- rbinom(n, 1, 0.4)
  df <- data.frame(a = ifelse(runif(n) < 0.2 + 0.4 * y, "Yes", "No"), b = runif(n) * 7 + 3 * y, o = ifelse(y == 1, "V", "N"))
  dec <- function(x) { x <- x[!is.na(x)]; max(nchar(sub("^[^.]*[.]?", "", format(x, scientific = FALSE, drop0trailing = TRUE, trim = TRUE)))) }
  s <- DECIDE:::screen_variables(df, y, exclude = "o")
  expect_lte(dec(s$odds_ratio), 4)
  q <- DECIDE:::screen_criteria(df, "o", "a", outcome_positive = "V")
  expect_lte(dec(c(q$or, q$or_low, q$or_high)), 4)
})

test_that("the calculator's bulk binarise creates the best split for vulnerability", {
  set.seed(4)
  n <- 600
  y <- rbinom(n, 1, 0.4)
  df <- data.frame(hh_size = pmax(1, round(rnorm(n, 5 + 3 * y, 1.5))), noise = runif(n),
                   water = ifelse(y == 1 & runif(n) < 0.6, "river", sample(c("well", "tap"), n, TRUE)))
  store <- shiny::reactiveVal(df)
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0),
                                       old_value = character(0), new_value = character(0), action = character(0),
                                       user = character(0), reason = character(0)))
  shiny::testServer(DECIDE:::mod_var_calc_server,
                    args = list(get_data = store, set_data = function(d) store(d), log = log, phase = "Design",
                                outcome = shiny::reactive(list(y = y, col = "outcome"))), {
    session$setInputs(type = "bulk", bulk_method = "optimal", bulk_cols = c("hh_size", "water", "noise"),
                      bulk_coding = "yesno")
    session$setInputs(preview = 1)
    d <- opt_res()
    expect_true(all(c("hh_size", "water") %in% d$variable))
    session$setInputs(create = 1)
    # each new variable is labelled after its source and rule
    expect_equal(DECIDE:::var_label("water_grp_Bin", session), "water: river")
    # Screen the whole dataset: every column that is not yes/no yet, at once
    session$setInputs(bulk_screen_all = 1)
    expect_true(all(c("hh_size", "water") %in% opt_res()$variable))
  })
  made <- setdiff(names(shiny::isolate(store())), names(df))
  expect_true(any(grepl("^hh_size_ge[0-9]+_Bin$", made)))   # the default ending
  expect_true("water_grp_Bin" %in% made)
  expect_false(any(grepl("noise", made)))                    # not significant: not ticked by default
  expect_true(all(grepl("Best split", shiny::isolate(log())$new_value)))
})

test_that("correlated variables are grouped and one of each pair is proposed for removal", {
  set.seed(7)
  n <- 500
  a <- rbinom(n, 1, 0.4)
  flip <- function(x, p) ifelse(runif(n) < p, 1 - x, x)
  e <- rbinom(n, 1, 0.5)
  df <- data.frame(a = a, b = flip(a, 0.02), c = flip(a, 0.03), d = rbinom(n, 1, 0.3), e = e, f = flip(e, 0.02))
  cg <- DECIDE:::correlated_groups(df, names(df), cutoff = 0.8)
  expect_length(cg$groups, 2)
  expect_setequal(unlist(cg$groups), c("a", "b", "c", "e", "f"))       # d correlates with nobody
  expect_true(all(abs(cg$pairs$r) >= 0.8))
  # after the proposal no pair above the cut-off remains, and each group keeps a member
  kept <- setdiff(names(df), names(cg$drop))
  expect_length(DECIDE:::correlated_groups(df, kept, 0.8)$groups, 0)
  expect_true(all(vapply(cg$groups, function(g) any(g %in% kept), logical(1))))
  expect_length(DECIDE:::correlated_groups(df, c("a", "d"), 0.8)$groups, 0)
})
