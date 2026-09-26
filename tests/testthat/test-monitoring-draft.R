tm <- function(f) utils::getFromNamespace(f, "TargetWise")

cfm <- data.frame(
  date = rep(c("2026-01-05", "2026-01-20", "2026-02-03", "2026-02-10"), 10),
  type = rep(c("Exclusion", "Exclusion", "Amount", "Other"), 10),
  channel = rep(c("Hotline", "Desk"), 20),
  status = rep(c("Resolved", "Resolved", "Resolved", "Open"), 10),
  stringsAsFactors = FALSE)
pdm_df <- data.frame(
  province = rep(c("Ituri", "Nord-Kivu"), each = 40),
  beneficiary = rep(c("Yes", "No"), 40),
  satisfied = rep(c("Yes", "Yes", "Yes", "No"), 20),
  lat = rep(c(1.5, -0.5), each = 40), lon = rep(c(30.1, 29.2), each = 40),
  stringsAsFactors = FALSE)

test_that("a template drafts the charts it finds columns for, each with a finding", {
  res <- tm("monitoring_draft")("process", process = list(cfm.csv = cfm))
  titles <- vapply(res$items, `[[`, character(1), "title")
  expect_true(all(c("Complaints by type", "Complaints by status", "Complaints over time") %in% titles))
  expect_true("Women's share of participants" %in% res$skipped)   # no participants data
  it <- res$items[[which(titles == "Complaints by type")]]
  expect_match(it$comment, "Exclusion comes first with 20 records (50% of the total)", fixed = TRUE)
  expect_identical(it$comment, it$caption)
  expect_equal(it$preset, "cfm_type")

  pdm <- tm("monitoring_draft")("pdm", pdm_df = pdm_df, pdm_name = "PDM round 1")
  expect_true(length(pdm$items) >= 2)
  expect_equal(pdm$items[[1]]$dataset, "PDM round 1")
})

test_that("findings say the highest, lowest and the gap, and warn on small groups", {
  cap <- tm("chart_caption")
  d <- data.frame(x = c("Beni", "Goma", "Bunia"), group = "All", value = c(62, 40, 30), n = c(50, 12, 40))
  s <- cap(d, list(type = "share"))
  expect_match(s, "Highest in Beni (62.0%", fixed = TRUE)
  expect_match(s, "lowest in Bunia (30.0%)", fixed = TRUE)
  expect_match(s, "1 category rests on fewer than 30 records", fixed = TRUE)
  tr <- data.frame(x = c("2026-01", "2026-02"), group = "All", value = c(10, 15), n = c(10, 15))
  expect_match(cap(tr, list(type = "trend")), "up 50% from 2026-01", fixed = TRUE)
})

test_that("headline indicators get a traffic light, and a round keeps them for the next", {
  items <- tm("monitoring_draft")("process", process = list(cfm.csv = cfm))$items
  p <- list(metrics = list(coverage_rate = 0.7, inclusion_error = 0.04, exclusion_error = 0.25), tolerance = c(0.05, 0.2))
  ind <- tm("monitoring_indicators")(p, items)
  expect_equal(ind$inclusion$band, "ok")
  expect_equal(ind$exclusion$band, "bad")
  expect_equal(ind$coverage$band, "warn")
  expect_equal(ind$resolved$value, 0.75)
  expect_equal(ind$complaints$value, 40)
  r1 <- tm("monitoring_round")("January", p, items)
  expect_equal(unname(r1$indicators[["exclusion"]]), 0.25)
  expect_equal(unname(r1$items[["Complaints by type"]][["Exclusion"]]), 20)
  html <- tm("monitoring_summary_html")(ind, prev = c(exclusion = 0.30, inclusion = 0.02), prev_label = "January")
  expect_match(html, "-5.0 pts", fixed = TRUE)      # exclusion fell: good
  expect_match(html, "mx-delta is-up", fixed = TRUE)
  expect_match(html, "mx-delta is-down", fixed = TRUE)  # inclusion rose: bad
})

test_that("a saved template is re-applied to the next round and the report shows the change", {
  items <- tm("monitoring_draft")("process", process = list(cfm.csv = cfm))$items
  tpl <- tm("template_from_items")(items)
  expect_null(tpl[[1]][["data"]])
  r1 <- tm("monitoring_round")("January", NULL, items)
  cfm2 <- rbind(cfm, cfm[cfm$type == "Exclusion", ])
  again <- tm("items_from_template")(tpl, process = list(`round2.csv` = cfm2))
  expect_equal(length(again$items), length(items))
  f <- withr::local_tempfile(fileext = ".html")
  tm("write_monitoring_report")(f, list(country_office = "Chad", recommendations = "Open a second desk in Beni. Train the hotline staff.",
                                        items = again$items, previous = list(r1)))
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, "Executive summary", fixed = TRUE)
  expect_match(html, "Change since January", fixed = TRUE)
  expect_match(html, "Open a second desk in Beni.", fixed = TRUE)
  expect_match(html, "Complaints resolved", fixed = TRUE)
})

test_that("the pre-export checks list what to look at", {
  d <- data.frame(x = c("Beni", "Goma"), group = "All", value = c(60, 40), n = c(12, 80))
  items <- list(list(title = "Women as % of participants", comment = "", spec = list(type = "share", value = "women", den = "participants"), data = d))
  w <- tm("monitoring_checks")(items, p = list(tolerance = c(0.05, 0.2)), texts = c(context = "", findings = "x", recommendations = "y"))
  expect_true(any(grepl("no title of its own", w)))
  expect_true(any(grepl("has no comment", w)))
  expect_true(any(grepl("1 category rests on fewer than 30 records (Beni)", w, fixed = TRUE)))
  expect_true(any(grepl("still the default 5-20%", w, fixed = TRUE)))
  expect_true(any(grepl("Context is empty", w)))
  expect_false(any(grepl("Key findings", w)))
})

test_that("the area map points carry the exclusion error of each area", {
  bu <- data.frame(unit = c("Ituri", "Nord-Kivu"), eligible = c(40, 20), selected = c(30, 20), coverage = c(0.75, 1))
  pts <- tm("monitoring_area_points")(pdm_df, "province", bu)
  expect_equal(pts$exclusion, c(0.25, 0))
  expect_equal(pts$lat, c(1.5, -0.5))
  expect_s3_class(tm("monitoring_area_map")(pts), "leaflet")
})

test_that("a draft does not take a registration list for complaints data", {
  reg <- data.frame(HHStatus = rep(c("Resident", "Returnee"), 30),
                    SvyDate = as.Date("2026-01-01") + 0:59, Province = rep(c("A", "B"), each = 30))
  d <- TargetWise:::monitoring_draft("process", NULL, list(registration_demo.csv = reg))
  expect_length(d$items, 0)
  cfm <- data.frame(complaint_type = rep(c("Exclusion", "Amount"), 30), status = rep(c("Resolved", "Open"), 30),
                    date_received = as.Date("2026-01-01") + 0:59)
  d2 <- TargetWise:::monitoring_draft("process", NULL, list(cfm_log.csv = cfm))
  expect_true(length(d2$items) >= 2)
})
