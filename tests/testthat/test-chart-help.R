test_that("every Targeting Design chart says what it shows and how to read it", {
  src <- paste(readLines(test_path("..", "..", "R", "mod_scorecard.R"), warn = FALSE), collapse = "\n")
  # the charts the React page draws (render_echart) and the one left in a Shiny dialog (plotlyOutput)
  ids <- c(sub(" <- render_echart$", "", sub("^output[$]", "", regmatches(src, gregexpr("output[$][a-z_0-9]+ <- render_echart", src))[[1]])),
           sub('.*"([a-z_0-9]+)"$', "\\1", regmatches(src, gregexpr('plotlyOutput[(]ns[(]"[a-z_0-9]+"', src))[[1]]))
  ids <- unique(ids)
  help <- DECIDE:::CHART_HELP
  expect_true(length(ids) > 10)
  expect_equal(setdiff(ids, names(help)), character(0))
  for (h in help) expect_true(nzchar(h$shows) && nzchar(h$read))
  expect_match(as.character(DECIDE:::chart_help("score_plot")), "How to read it")

  # the React page shows each chart with its help (ChartCard / ChartPane / ChartHelp)
  dir <- test_path("..", "..", "react", "src", "pages", "design")
  skip_if_not(dir.exists(dir), "the React sources are not here (installed package)")
  tsx <- paste(unlist(lapply(list.files(dir, "[.]tsx$", full.names = TRUE), readLines, warn = FALSE)), collapse = "\n")
  shown <- unique(c(sub('.*id="', "", sub('"$', "", regmatches(tsx, gregexpr('(ChartCard|ChartPane|ChartHelp) id="[a-z_0-9]+"', tsx))[[1]])),
                    sub('^C[(]"', "", sub('"$', "", regmatches(tsx, gregexpr('C[(]"[a-z_0-9]+"', tsx))[[1]]))))
  expect_equal(setdiff(setdiff(ids, "pq_plot"), shown), character(0))
})

test_that("the mirrored distribution draws both groups as shares of their own size", {
  set.seed(3)
  p <- DECIDE:::mirrored_hist_plot(c(rnorm(100, 2), rnorm(400, 0)), rep(c(TRUE, FALSE), c(100, 400)), 1)
  b <- plotly::plotly_build(p)$x$data
  expect_length(b, 2)
  expect_equal(sum(b[[1]]$y), 100, tolerance = 1e-6)
  expect_equal(sum(-b[[2]]$y), 100, tolerance = 1e-6)
  # the same on the React page (an ECharts option): each group sums to 100%
  o <- DECIDE:::ec_mirrored(c(rnorm(100, 2), rnorm(400, 0)), rep(c(TRUE, FALSE), c(100, 400)), 1)
  v <- function(s) vapply(s$data, function(d) d$value[[2]], numeric(1))
  expect_equal(sum(v(o$series[[1]])), 100, tolerance = 0.05)
  expect_equal(sum(-v(o$series[[2]])), 100, tolerance = 0.05)
  expect_equal(o$series[[1]]$markLine$data[[1]]$xAxis, 1)
})
