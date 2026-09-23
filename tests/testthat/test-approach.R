tm <- function(f) utils::getFromNamespace(f, "TargetWise")

reg <- function() {
  data.frame(
    id = sprintf("H%02d", 1:10),
    prov = c("A", "A", "A", "A", "A", "B", "B", "B", "B", "B"),
    status = c("IDP", "IDP", "Res", "Res", "IDP", "IDP", "Res", "Res", "IDP", "Res"),
    score = c(30, 12, 25, 5, NA, 28, 22, 8, 15, 40),
    comm = c("Yes", "No", "No", "Yes", "Yes", "No", "No", "Yes", "No", "No"),
    stringsAsFactors = FALSE
  )
}
st <- list(unique_id = "id", admin1 = "prov", residency = "status", v_score = "score")
sel <- function(...) tm("select_households")(reg(), st, ...)

test_that("blanket and geographic select by area only", {
  expect_true(all(sel(approach = "blanket")$eligible))
  g <- sel(approach = "geographic", area = list(admin1 = "B"))
  expect_equal(which(g$eligible), 6:10)
})

test_that("categorical uses filters and rules, and ignores the score", {
  c1 <- sel(approach = "categorical", filters = list(residency = "IDP"),
            score_range = c(20, 100))
  expect_equal(which(c1$eligible), c(1, 2, 5, 6, 9))   # score range ignored
})

test_that("scorecard falls back to the mapped score and drops unscored households", {
  s <- sel(approach = "scorecard", score_range = c(20, 100))
  expect_equal(which(s$eligible), c(1, 3, 6, 7, 10))    # row 5 has no score
  expect_equal(s$rank_by, "v_score")
})

test_that("hybrid 'both' intersects and 'either' unions -- and an empty side is neutral", {
  both <- sel(approach = "hybrid", filters = list(residency = "IDP"), score_range = c(20, 100))
  expect_equal(which(both$eligible), c(1, 6))
  either <- sel(approach = "hybrid", combine = "either",
                filters = list(residency = "IDP"), score_range = c(20, 100))
  expect_equal(which(either$eligible), c(1, 2, 3, 5, 6, 7, 9, 10))
  # No criteria set under 'either': the score alone decides, NOT everyone.
  e2 <- sel(approach = "hybrid", combine = "either", score_range = c(20, 100))
  expect_equal(which(e2$eligible), c(1, 3, 6, 7, 10))
  # And under 'both' the score alone decides too.
  b2 <- sel(approach = "hybrid", score_range = c(20, 100))
  expect_equal(which(b2$eligible), c(1, 3, 6, 7, 10))
})

test_that("community-based uses the community's own decision, and nothing without one", {
  cb <- sel(approach = "community", community = list(column = "comm", values = "Yes"))
  expect_equal(which(cb$eligible), c(1, 4, 5, 8))
  none <- sel(approach = "community")
  expect_false(any(none$eligible))
  expect_match(none$notes, "community's selection")
})

test_that("self-targeting produces no list", {
  s <- sel(approach = "self")
  expect_false(s$list_produced)
  expect_false(any(s$eligible))
})

test_that("prioritisation keeps the most vulnerable and marks the rest excluded by design", {
  # Everyone scored is eligible; caseload of 3 keeps the 3 highest scores.
  p <- sel(approach = "scorecard", prioritization = list(mode = "caseload", n = 3))
  expect_equal(sum(p$eligible), 9)                     # the NA score is not eligible
  expect_equal(which(p$prioritized), c(1, 6, 10))       # scores 30, 28, 40
  expect_true(all(p$prioritized <= p$eligible))         # never beyond the eligible
  # per area: 2 per province
  q <- sel(approach = "scorecard", prioritization = list(mode = "per_unit", n = 2, unit = "admin1"))
  expect_equal(which(q$prioritized), c(1, 3, 6, 10))    # A: 30,25  B: 40,28
  # excluded by design = eligible but not prioritised
  expect_equal(sum(q$eligible & !q$prioritized), 5)
})

test_that("prioritisation without anything to rank by is refused, not applied arbitrarily", {
  st2 <- st; st2$v_score <- NULL
  p <- tm("select_households")(reg(), st2, approach = "geographic",
                               prioritization = list(mode = "caseload", n = 3))
  expect_true(all(p$prioritized == p$eligible))
  expect_match(p$notes, "needs a score")
})

test_that("a scorecard, when adopted, takes precedence over the mapped score", {
  sc <- list(threshold = 0, items = list(
    list(criterion = "comm", direction = "inclusion", weight = 2)))
  s <- sel(approach = "scorecard", scorecard = sc, score_range = c(20, 100))
  expect_equal(which(s$eligible), c(1, 4, 5, 8))
  expect_equal(s$rank_by, "scorecard")
})

test_that("approach_js builds a membership test on the namespaced picker", {
  js <- TargetWise:::approach_js(shiny::NS("m"), c("hybrid", "scorecard"))
  expect_equal(js, "['hybrid','scorecard'].indexOf(input['m-ben_approach']) >= 0")
})
