tm <- function(f) utils::getFromNamespace(f, "TargetWise")

pm <- data.frame(
  date = c("2026-01-05", "2026-01-20", "2026-02-03", "2026-02-10", "2026-02-11"),
  province = c("Ituri", "Ituri", "Nord-Kivu", "Nord-Kivu", "Sud-Kivu"),
  activity = c("Committee meeting", "FGD criteria", "FGD criteria", "Committee meeting", "Sensitisation"),
  participants_total = c(20, 15, 30, 10, 25),
  women = c(8, 9, 12, 5, 10),
  stringsAsFactors = FALSE
)

test_that("chart_aggregate counts, totals, averages, shares and trends", {
  agg <- tm("chart_aggregate")
  n <- agg(pm, list(type = "count", x = "province"))
  expect_equal(n$value[n$x == "Ituri"], 2)
  s <- agg(pm, list(type = "sum", x = "province", value = "participants_total"))
  expect_equal(s$value[s$x == "Nord-Kivu"], 40)
  sh <- agg(pm, list(type = "share", x = "province", value = "women", den = "participants_total"))
  expect_equal(sh$value[sh$x == "Ituri"], round(100 * 17 / 35, 2))
  tr <- agg(pm, list(type = "trend", date = "date", period = "month"))
  expect_equal(tr$x, c("2026-01", "2026-02"))
  expect_equal(tr$value, c(2, 3))
  f <- agg(pm, list(type = "count", x = "province", filter_col = "activity", filter_vals = "FGD criteria"))
  expect_equal(sum(f$value), 2)
  expect_null(agg(pm, list(type = "sum", x = "province")))  # no number column chosen
})

test_that("chart_table adds totals and shares", {
  d <- tm("chart_aggregate")(pm, list(type = "count", x = "province", group = "activity"))
  t <- tm("chart_table")(d, list(type = "count", x = "province"))
  expect_equal(tail(t$province, 1), "Total")
  expect_equal(tail(t$Total, 1), 5)
  expect_true("% of total" %in% names(t))
})

test_that("presets find their columns, including the filter values", {
  pr <- tm("chart_presets")()
  sp <- tm("apply_preset")(pr[["Community process"]]$com_women, pm)
  expect_equal(sp$value, "women"); expect_equal(sp$den, "participants_total"); expect_equal(sp$x, "province")
  fgd <- tm("apply_preset")(pr[["Community process"]]$com_fgd, pm)
  expect_equal(fgd$filter_col, "activity"); expect_equal(fgd$filter_vals, "FGD criteria")
})

test_that("the monitoring report carries the errors, charts, tables and comments", {
  agg <- tm("chart_aggregate")
  it1 <- list(id = "a1", source = "process", dataset = "pm.csv", title = "Women's share", comment = "Below target in Ituri.",
              spec = list(type = "share", x = "province", value = "women", den = "participants_total"), display = "chart",
              data = agg(pm, list(type = "share", x = "province", value = "women", den = "participants_total")))
  it2 <- list(id = "a2", source = "process", dataset = "pm.csv", title = "Sessions by type", comment = "",
              spec = list(type = "count", x = "activity"), display = "table",
              data = agg(pm, list(type = "count", x = "activity")))
  f <- withr::local_tempfile(fileext = ".html")
  tm("write_monitoring_report")(f, list(
    country_office = "Chad", context = "Round 1.", findings = "", recommendations = "Hold FGDs earlier.",
    pdm = list(metrics = list(inclusion_error = .12, exclusion_error = .3, coverage_rate = .7, precision = .88, recall = .7),
               n = 400, tolerance = c(.05, .2), verdict = list(interpretation = "OK", action = "None")),
    items = list(it1, it2)))
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, "Targeting monitoring report", fixed = TRUE)
  expect_match(html, "Implementation inclusion error", fixed = TRUE)
  expect_match(html, "Below target in Ituri.", fixed = TRUE)
  expect_match(html, "<figure class=\"fig\">", fixed = TRUE)
  expect_match(html, "Committee meeting", fixed = TRUE)   # the table item
  expect_match(html, "Hold FGDs earlier.", fixed = TRUE)
  expect_false(grepl("@@(FIG|IMPL)", html))
})
