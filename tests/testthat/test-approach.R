tm <- function(f) utils::getFromNamespace(f, "DECIDE")

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
  js <- DECIDE:::approach_js(shiny::NS("m"), c("hybrid", "scorecard"))
  expect_equal(js, "['hybrid','scorecard'].indexOf(input['m-ben_approach']) >= 0")
})

test_that("each area can have its own caseload, most vulnerable first", {
  df <- data.frame(area = rep(c("A", "B", "C"), each = 10), score = rep(10:1, 3))
  st <- list(admin1 = "area", v_score = "score")
  r <- DECIDE:::select_households(df, st, approach = "blanket",
         prioritization = list(mode = "per_unit", unit = "admin1", quotas = list(A = 3, B = 7, C = 0)))
  served <- tapply(r$prioritized, df$area, sum)
  expect_equal(as.integer(served), c(3L, 7L, 0L))
  expect_equal(df$score[r$prioritized & df$area == "A"], 10:8)          # the most vulnerable
  # an area missing from the plan serves no one; without a plan the single cap applies
  r2 <- DECIDE:::select_households(df, st, approach = "blanket",
          prioritization = list(mode = "per_unit", unit = "admin1", quotas = list(A = 2)))
  expect_equal(as.integer(tapply(r2$prioritized, df$area, sum)), c(2L, 0L, 0L))
  r3 <- DECIDE:::select_households(df, st, approach = "blanket",
          prioritization = list(mode = "per_unit", unit = "admin1", n = 4))
  expect_equal(as.integer(tapply(r3$prioritized, df$area, sum)), c(4L, 4L, 4L))
})

test_that("a total caseload is split in proportion, summing exactly", {
  a <- DECIDE:::allocate_total
  expect_equal(a(c(21, 19, 18), 30), c(11, 10, 9))
  expect_equal(sum(a(c(1, 1, 1), 100)), 100)
  expect_equal(a(c(1, 1, 1), 1000) / 10, c(33.4, 33.3, 33.3))
  expect_equal(a(c(5, 0, NA), 10), c(10, 0, 0))
  expect_equal(a(c(0, 0), 10), c(0, 0))
})

test_that("IPC figures are read per area when the data has them", {
  df <- data.frame(prov = c("A", "A", "B", "B", "C"), ipc_phase = c("Phase 3", "Phase 3", "2", "2", "4"),
                   ipc3plus_pop = c(1200, 1200, 300, 300, 5000))
  r <- DECIDE:::ipc_by_area(df, df$prov)
  expect_equal(as.numeric(r$phase[c("A", "B", "C")]), c(3, 2, 4))
  expect_equal(as.numeric(r$pop[c("A", "B", "C")]), c(1200, 300, 5000))
  expect_equal(r$phase_col, "ipc_phase"); expect_equal(r$pop_col, "ipc3plus_pop")
  none <- DECIDE:::ipc_by_area(data.frame(prov = "A", x = 1), "A")
  expect_null(none$phase); expect_null(none$pop)
})

test_that("a caseload counted in people serves households until the people are reached", {
  df <- data.frame(area = rep(c("A", "B"), each = 5), score = rep(5:1, 2), size = c(4, 3, 6, 2, 5, 1, 1, 1, 1, 1))
  st <- list(admin1 = "area", v_score = "score", hh_size = "size")
  r <- DECIDE:::select_households(df, st, approach = "blanket",
         prioritization = list(mode = "per_unit", unit = "admin1", count = "people", quotas = list(A = 10, B = 3)))
  expect_equal(df$size[r$prioritized & df$area == "A"], c(4, 3))       # 4 + 3 = 7; the next (6) would pass 10
  expect_equal(sum(r$prioritized & df$area == "B"), 3)
  t <- DECIDE:::select_households(df, st, approach = "blanket",
         prioritization = list(mode = "caseload", n = 8, count = "people"))
  expect_lte(sum(df$size[t$prioritized]), 8)
  h <- DECIDE:::select_households(df, st, approach = "blanket",
         prioritization = list(mode = "caseload", n = 3, count = "households"))
  expect_equal(sum(h$prioritized), 3)
})
