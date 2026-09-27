test_that("every Targeting Design chart says what it shows and how to read it", {
  src <- paste(readLines(test_path("..", "..", "R", "mod_scorecard.R"), warn = FALSE), collapse = "\n")
  ids <- unique(c(regmatches(src, gregexpr('plotlyOutput[(]ns[(]"[a-z_0-9]+"', src))[[1]],
                  regmatches(src, gregexpr('chart[(]"[^"]+", "[^"]+", "[a-z_0-9]+"', src))[[1]]))
  ids <- unique(sub('.*"([a-z_0-9]+)"$', "\\1", ids))
  ids <- setdiff(ids, "id")
  help <- TargetWise:::CHART_HELP
  expect_true(length(ids) > 10)
  expect_equal(setdiff(ids, names(help)), character(0))
  for (h in help) expect_true(nzchar(h$shows) && nzchar(h$read))
  expect_match(as.character(TargetWise:::chart_help("score_plot")), "How to read it")
})

test_that("the mirrored distribution draws both groups as shares of their own size", {
  set.seed(3)
  p <- TargetWise:::mirrored_hist_plot(c(rnorm(100, 2), rnorm(400, 0)), rep(c(TRUE, FALSE), c(100, 400)), 1)
  b <- plotly::plotly_build(p)$x$data
  expect_length(b, 2)
  expect_equal(sum(b[[1]]$y), 100, tolerance = 1e-6)
  expect_equal(sum(-b[[2]]$y), 100, tolerance = 1e-6)
})
