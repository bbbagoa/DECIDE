test_that("the chart builder draws every chart type as an ECharts option", {
  set.seed(1)
  n <- 400
  d <- data.frame(age = round(runif(n, 18, 80)), score = rnorm(n, 50, 10),
                  sex = sample(c("Male", "Female"), n, TRUE), status = sample(c("Resident", "IDP", "Returnee"), n, TRUE),
                  stringsAsFactors = FALSE)
  gb <- function(...) DECIDE:::gb_echart(d, ...)
  json <- function(o) jsonlite::toJSON(o, auto_unbox = TRUE, null = "null", na = "null")
  cases <- list(
    list("age", NULL, NULL, "hist", "bar"), list("age", NULL, "sex", "hist", "bar"), list("age", NULL, "sex", "box", "boxplot"),
    list("status", NULL, NULL, "bars", "bar"), list("status", NULL, "sex", "bars_n", "bar"),
    list("age", "score", NULL, "scatter_trend", "line"), list("age", "score", "sex", "scatter", "scatter"),
    list("status", "score", NULL, "box", "boxplot"), list("status", "score", "sex", "mean", "boxplot"),
    list("status", "score", "sex", "violin", "bar"),
    list("status", "sex", NULL, "stack100", "bar"), list("status", "sex", NULL, "dodge", "bar"), list("status", "sex", "status", "stack", "bar"))
  for (cs in cases) {
    r <- gb(cs[[1]], cs[[2]], cs[[3]], cs[[4]])
    types <- vapply(r$option$series, function(s) s$type, "")
    expect_true(cs[[5]] %in% types, info = paste(cs[[4]], cs[[3]] %||% ""))
    expect_true(nzchar(r$note))
    expect_silent(json(r$option))
  }
  # 100% stacked bars add up to 100 in each category
  r <- gb("status", "sex", NULL, "stack100")
  tot <- Reduce(`+`, lapply(r$option$series, function(s) vapply(s$data, function(e) e$value, 0)))
  expect_equal(tot, rep(100, 3), tolerance = 0.2)
  # a grouped two-category chart is one panel per group
  r <- DECIDE:::gb_echart(transform(d, region = sample(c("A", "B", "C", "D"), n, TRUE)), "status", "sex", "region", "stack")
  expect_length(r$option$grid, 4)
  # axes typed in the dialog bound the value axis; scatters are capped
  r <- gb("status", "score", NULL, "box", axes = list(ymin = 0, ymax = 100))
  expect_equal(c(r$option$yAxis$min, r$option$yAxis$max), c(0, 100))
  r <- gb("age", "score", NULL, "scatter", max_points = 50)
  expect_equal(nrow(r$option$series[[1]]$data), 50)
  expect_match(r$note, "400 pairs")
})

test_that("the cross-tab frame keeps the totals and gives shares for percentages", {
  d <- data.frame(a = rep(c("x", "y"), c(30, 70)), b = rep(c("u", "v"), 50), stringsAsFactors = FALSE)
  ct <- DECIDE:::contingency(d, "a", "b", NULL, "row")
  f <- DECIDE:::ct_frame(ct, "A", "Share of each row (%)")
  expect_equal(names(f$data), c("row", "c1", "c2", "c3"))
  expect_equal(unlist(f$labels[c("c1", "c2", "c3")]), c(c1 = "u", c2 = "v", c3 = "Total"))
  expect_equal(f$data$c3, c(1, 1, 1))
  expect_equal(f$formats$c1, "pct1")
  expect_null(f$styles$c3)                       # the totals are not shaded
  n <- DECIDE:::ct_frame(DECIDE:::contingency(d, "a", NULL, NULL, "n"), "A", "Households")
  expect_equal(n$data$c1, c(70, 30, 100))            # most frequent first
})
