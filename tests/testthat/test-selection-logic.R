test_that("the selection logic round-trips and is applied to survey answers as in Selection", {
  reg <- data.frame(tent = c(1, 1, 0, 0, 1), light = c(1, 0, 1, 0, 1), size = c(6, 2, 7, 3, 9))
  card <- build_scorecard(data.frame(criterion = c("tent", "light"), direction = "inclusion", weight = c(2, 1)), threshold = 1)
  rules <- list(groups = list(list(rules = list(list(key = "hh_size", col = NA_character_, op = ">=", value = "5")))))
  applied <- list(approach = "hybrid", combine = "both", use_scorecard = TRUE, sc_threshold = 2, prio_mode = "none")
  lg <- selection_logic(applied, card, rules, list(hh_size = "size"), names(reg))
  expect_equal(lg$scorecard$threshold, 2)                          # the threshold applied in Selection, not the card's
  expect_equal(lg$rules$groups[[1]]$rules[[1]]$col, "size")        # a mapped field written as its column
  f <- tempfile(fileext = ".json"); write_selection_logic(lg, f)
  back <- read_selection_logic(f)
  sel <- select_households(reg, list(hh_size = "size"), approach = "hybrid", ruleset = rules,
                           scorecard = modifyList(card, list(threshold = 2)), combine = "both")$eligible
  # the survey: other case, a form group path, same answers
  sv <- data.frame(`grp/Tent` = reg$tent, LIGHT = reg$light, Size = reg$size, check.names = FALSE)
  r <- logic_eligibility(sv, back)
  expect_length(r$missing, 0)
  expect_equal(r$eligible, sel)
  expect_equal(r$eligible, c(TRUE, FALSE, FALSE, FALSE, TRUE))
  # a column the survey lacks refuses the calculation
  expect_equal(logic_eligibility(sv[c("LIGHT", "Size")], back)$missing, "tent")
  expect_match(logic_describe(back), "Hybrid.*score > 2.*1 eligibility rule")
  g <- tempfile(fileext = ".json"); writeLines('{"items": []}', g)
  expect_error(read_selection_logic(g), "not a selection logic file")
})
