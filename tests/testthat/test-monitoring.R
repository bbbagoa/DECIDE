tm <- function(f) utils::getFromNamespace(f, "DECIDE")

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
  expect_equal(tr$x, c("01/2026", "02/2026"))
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

test_that("a crosstab gives row, column and total percentages with a chi-square test", {
  df <- data.frame(sex = rep(c("F", "M"), c(60, 40)),
                   complaint = c(rep("yes", 45), rep("no", 15), rep("yes", 10), rep("no", 30)))
  d <- DECIDE:::chart_aggregate(df, list(type = "crosstab", x = "sex", group = "complaint", pct = "row"))
  expect_equal(d$value[d$x == "F" & d$group == "yes"], 75)
  expect_equal(sum(d$n), 100)
  dc <- DECIDE:::chart_aggregate(df, list(type = "crosstab", x = "sex", group = "complaint", pct = "col"))
  expect_equal(dc$value[dc$x == "F" & dc$group == "yes"], round(100 * 45 / 55, 2))
  tb <- DECIDE:::chart_table(d, list(type = "crosstab", x = "sex", pct = "row"))
  expect_equal(tb[tb$sex == "F", "yes"], "75.0% (45)")
  expect_equal(tb$Total[nrow(tb)], "100")
  tt <- DECIDE:::crosstab_test(d)
  expect_equal(tt$chi2, unname(suppressWarnings(stats::chisq.test(table(df$sex, df$complaint), correct = FALSE))$statistic))
  expect_match(DECIDE:::crosstab_test_text(tt), "related")
  expect_null(DECIDE:::crosstab_test(DECIDE:::chart_aggregate(df, list(type = "crosstab", x = "sex", group = "sex"))[1:2, ]))
})

test_that("two half-width items sit side by side in the monitoring report", {
  df <- data.frame(area = c("A", "A", "B"), sex = c("F", "M", "F"))
  mk <- function(id, width, display = "chart", type = "count") {
    sp <- list(type = type, x = "area", group = if (type == "crosstab") "sex" else "", pct = "row")
    list(id = id, source = "process", dataset = "d.csv", title = paste("Item", id), comment = "note",
         spec = sp, data = DECIDE:::chart_aggregate(df, sp), display = display, width = width)
  }
  items <- list(mk("a", "half"), mk("b", "half", "table", "crosstab"), mk("c", "half"))
  f <- withr::local_tempfile(fileext = ".html")
  DECIDE:::write_monitoring_report(f, list(items = items, kind = "Baseline"))
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_equal(lengths(regmatches(html, gregexpr('class="pair"', html))), 1)   # a+b paired, c alone
  expect_false(grepl("@@FIG|@@PAIR", html))
  expect_match(html, "Chi-square")
  expect_match(html, "Implementation accuracy (post-targeting survey, before distribution)", fixed = TRUE)
})

test_that("the officer's formatted texts and comments reach the monitoring report", {
  df <- data.frame(area = c("A", "A", "B"))
  sp <- list(type = "count", x = "area", group = "", style = "donut")
  it <- list(id = "a", source = "process", dataset = "d.csv", title = "Item", comment = "<p><i>seen</i> in <b>A</b></p>",
             spec = sp, data = DECIDE:::chart_aggregate(df, sp), display = "chart", width = "half")
  f <- withr::local_tempfile(fileext = ".html")
  DECIDE:::write_monitoring_report(f, list(items = list(it), context = "Plain\ntext",
                                               findings = '<p><span style="color: #c5192d">Low</span> coverage</p><script>x()</script>'))
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, '<div class="rich"><p>Plain<br>text</p></div>', fixed = TRUE)
  expect_match(html, '<div class="rich"><p><span style="color: #c5192d">Low</span> coverage</p></div>', fixed = TRUE)
  expect_match(html, '<div class="rich"><p><i>seen</i> in <b>A</b></p></div>', fixed = TRUE)
  expect_false(grepl("<script>x()", html, fixed = TRUE) || grepl("@@RICH", html))
  expect_match(html, "_Not written._|<em>Not written.</em>")   # recommendations left empty
})

test_that("value-axis bounds: blank is automatic, one blank end comes from the data", {
  d <- data.frame(x = c("a", "b"), group = "All", value = c(2, 10))
  expect_null(chart_axis_range(d, list(axis_min = NA, axis_max = NA)))
  expect_equal(chart_axis_range(d, list(axis_min = 5, axis_max = NA)), c(5, 10.8))
  expect_equal(chart_axis_range(d, list(axis_min = NA, axis_max = 50)), c(0, 50))
  expect_length(axis_bounds(NA, NA, c(0, 10)), 0)
  expect_equal(axis_bounds(NA, 20, c(0, 10))$range, c(0, 20))
})

test_that("chart builder: the Axes dialog sets the value-axis bounds, Automatic clears them", {
  df <- data.frame(area = c("A", "A", "B"), v = c(1, 2, 3))
  shiny::testServer(mod_chart_builder_server, args = list(data = shiny::reactive(df), source = shiny::reactive("x"),
                                                          add_item = function(...) NULL), {
    expect_true(is.na(spec()$axis_min))
    session$setInputs(ax_ymin = 5, ax_ymax = 50, ax_apply = 1)
    expect_equal(c(spec()$axis_min, spec()$axis_max), c(5, 50))
    session$setInputs(ax_reset = 1)
    expect_true(is.na(spec()$axis_max))
  })
})

test_that("chart builder refuses a By column with too many options", {
  df <- data.frame(site = paste0("s", seq_len(MAX_OPTIONS + 10)), v = 1)
  shiny::testServer(mod_chart_builder_server, args = list(data = shiny::reactive(df), source = shiny::reactive("x"),
                                                          add_item = function(...) NULL), {
    session$setInputs(type = "count", x = "site")
    expect_match(too_many(), "Too many options for site", fixed = TRUE)
    expect_null(agg())
  })
})
