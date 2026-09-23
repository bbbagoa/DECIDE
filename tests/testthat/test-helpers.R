test_that("find_guess matches keywords case-insensitively", {
  cols <- c("HH_ID", "age_head", "vulnerability_score", "date_col")
  expect_equal(find_guess(cols, c("uuid", "id")), "HH_ID")
  expect_equal(find_guess(cols, c("score", "scoring")), "vulnerability_score")
  expect_equal(find_guess(cols, c("nonexistent")), "")
})

test_that("find_bad_names flags problematic entries", {
  df <- data.frame(
    name = c("John", "Jane", "test", "x", "123", NA),
    value = 1:6,
    stringsAsFactors = FALSE
  )
  bad <- find_bad_names(df, "name")
  expect_true(all(bad$name %in% c("test", "x", "123", NA)))
})

test_that("get_location_summary aggregates counts", {
  df <- data.frame(
    location = c("A", "A", "B", "B", "B"),
    stringsAsFactors = FALSE
  )
  res <- get_location_summary(df, "location")
  expect_equal(nrow(res), 2)
  expect_equal(res$count[res$label == "B"], 3)
})

test_that("parse_total_pages extracts last page from ONA Link header", {
  link <- paste0(
    '<https://api.moda.wfp.org/api/v1/data/123.json?page=2&page_size=4>; rel="next", ',
    '<https://api.moda.wfp.org/api/v1/data/123.json?page=10&page_size=4>; rel="last"'
  )
  expect_equal(TargetWise:::parse_total_pages(link), 10L)
})

test_that("parse_total_pages returns NA when Link header is missing", {
  expect_equal(TargetWise:::parse_total_pages(NULL), NA_integer_)
  expect_equal(TargetWise:::parse_total_pages(""), NA_integer_)
  expect_equal(
    TargetWise:::parse_total_pages('<.../data/123?page=2>; rel="next"'),
    NA_integer_
  )
})

test_that("harmonize_pages reconciles mixed character/numeric columns", {
  pages <- list(
    data.frame(a = 1:2, b = c("x", "y"), stringsAsFactors = FALSE),
    data.frame(a = c("3", "4"), b = c("z", "w"), stringsAsFactors = FALSE)
  )
  out <- TargetWise:::harmonize_pages(pages)
  expect_type(out[[1]]$a, "double")
  expect_type(out[[2]]$a, "double")
  expect_type(out[[1]]$b, "character")
})

# ---- Weighted statistics (utils_helpers.R) ---------------------------------

test_that("get_weights returns a vector of ones when no weight column is mapped", {
  df <- data.frame(id = 1:4, stringsAsFactors = FALSE)
  settings <- list(weight = "")
  expect_equal(get_weights(df, settings), rep(1, 4))
})

test_that("get_weights returns ones when the weight column is absent", {
  df <- data.frame(id = 1:3, stringsAsFactors = FALSE)
  settings <- list(weight = "w")
  expect_equal(get_weights(df, settings), rep(1, 3))
})

test_that("get_weights coerces, fills missing with 0 and zeroes negatives", {
  df <- data.frame(w = c("1.5", NA, -2, 3), stringsAsFactors = FALSE)
  settings <- list(weight = "w")
  expect_equal(get_weights(df, settings), c(1.5, 0, 0, 3))
})

test_that("weighted_count and weighted_sum respect weights", {
  df <- data.frame(v = c(10, 20, 30), w = c(1, 2, 3), stringsAsFactors = FALSE)
  settings <- list(weight = "w")
  expect_equal(weighted_count(df, settings), 6)
  expect_equal(weighted_sum(df, "v", settings), 10 * 1 + 20 * 2 + 30 * 3)
})

test_that("weighted_mean ignores rows with missing value, keeps positive weights", {
  df <- data.frame(v = c(10, 20, NA, 40), w = c(1, 1, 1, 3), stringsAsFactors = FALSE)
  settings <- list(weight = "w")
  # Row 3 (v=NA) is excluded; rows 1,2,4 are valid:
  # (10*1 + 20*1 + 40*3) / (1 + 1 + 3) = 150 / 5 = 30
  expect_equal(weighted_mean(df, "v", settings), 30)
  # missing column -> NA
  expect_true(is.na(weighted_mean(df, "nope", settings)))
})

test_that("weighted_table aggregates weighted counts by value", {
  df <- data.frame(g = c("a", "a", "b", "b"), w = c(1, 1, 2, 2), stringsAsFactors = FALSE)
  settings <- list(weight = "w")
  tab <- weighted_table(df, "g", settings)
  expect_equal(tab$n[tab$value == "a"], 2)
  expect_equal(tab$n[tab$value == "b"], 4)
})

# ---- fuzzy_match_groups (utils_helpers.R) ----------------------------------

test_that("fuzzy_match_groups groups near-matches and leaves loners as 0", {
  keys <- c("Kananga", "Kananga", "Kananga", "Goma", "Goma", "Bukavu", "Xq")
  groups <- fuzzy_match_groups(keys)
  # The three identical Kananga share a group (>0)
  kan_group <- groups[keys == "Kananga"][1]
  expect_true(kan_group > 0)
  expect_true(all(groups[keys == "Kananga"] == kan_group))
  # Gomas also share a (different) group
  goma_group <- groups[keys == "Goma"][1]
  expect_true(goma_group > 0)
  expect_true(all(groups[keys == "Goma"] == goma_group))
  expect_false(goma_group == kan_group)
  # The lone outlier with no near-neighbour gets group 0
  expect_equal(groups[keys == "Xq"], 0)
})

test_that("fuzzy_match_groups is case-insensitive", {
  keys <- c("Kananga", "kananga")
  groups <- fuzzy_match_groups(keys)
  expect_equal(groups[1], groups[2])
  expect_true(groups[1] > 0)
})

test_that("fuzzy_match_groups returns 0 for every fully-unique key set", {
  keys <- c("alpha", "bravo", "charlie")
  groups <- fuzzy_match_groups(keys)
  expect_true(all(groups == 0))
})


test_that("waiter content survives an apostrophe in the message", {
  # waiter drops this HTML into a single-quoted JS string, so a raw ' would
  # end the string and throw a SyntaxError that kills the script block.
  html <- as.character(TargetWise:::waiter_content("Chargement de l'assistance"))
  expect_false(grepl("'", html, fixed = TRUE))
  expect_true(grepl("l&#39;assistance", html, fixed = TRUE))

  # The cancel button's inline onclick is quoted the same way and must survive.
  with_btn <- as.character(TargetWise:::waiter_content("Working", ns = function(x) paste0("mod-", x)))
  expect_false(grepl("'", with_btn, fixed = TRUE))

  # Still one line, since waiter cannot cope with embedded newlines either.
  expect_equal(length(html), 1L)
  expect_false(grepl("\n", html, fixed = TRUE))
})
