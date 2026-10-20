tm <- function(f) utils::getFromNamespace(f, "DECIDE")

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

test_that("a draft does not take a registration list for complaints data", {
  reg <- data.frame(HHStatus = rep(c("Resident", "Returnee"), 30),
                    SvyDate = as.Date("2026-01-01") + 0:59, Province = rep(c("A", "B"), each = 30))
  d <- DECIDE:::monitoring_draft("process", NULL, list(registration_demo.csv = reg))
  expect_length(d$items, 0)
  cfm <- data.frame(complaint_type = rep(c("Exclusion", "Amount"), 30), status = rep(c("Resolved", "Open"), 30),
                    date_received = as.Date("2026-01-01") + 0:59)
  d2 <- DECIDE:::monitoring_draft("process", NULL, list(cfm_log.csv = cfm))
  expect_true(length(d2$items) >= 2)
})

test_that("a template survives its file, with its comments and rounds, and nothing else is accepted", {
  items <- tm("monitoring_draft")("process", process = list(cfm.csv = cfm))$items
  items[[1]]$comment <- "<p>Most complaints were about exclusion; the desk in Beni was overloaded.</p>"
  t <- list(name = "CFM monthly", items = tm("template_from_items")(items, keep_comments = TRUE),
            texts = c(context = "<p>Hotline and desks, January.</p>", findings = "", recommendations = "<p>Open a second desk.</p>"),
            rounds = list(tm("monitoring_round")("January", NULL, items)))
  expect_equal(t$items[[1]]$comment, items[[1]]$comment)
  expect_null(t$items[[2]]$comment)                          # an untouched finding is not kept as a comment
  back <- tm("read_template_json")(tm("template_json")(t))
  expect_equal(back$name, "CFM monthly")
  expect_equal(back$texts[["recommendations"]], "<p>Open a second desk.</p>")
  expect_equal(back$rounds[[1]]$indicators, t$rounds[[1]]$indicators)
  expect_equal(back$rounds[[1]]$items, t$rounds[[1]]$items)
  a <- tm("items_from_template")(t$items, process = list(cfm.csv = cfm))$items
  b <- tm("items_from_template")(back$items, process = list(cfm.csv = cfm))$items
  expect_equal(lapply(b, `[[`, "data"), lapply(a, `[[`, "data"))  # the same charts on the same data
  expect_equal(b[[1]]$comment, items[[1]]$comment)                # the kept comment comes back
  expect_false(identical(b[[1]]$caption, b[[1]]$comment))         # with the new finding offered beside it
  expect_error(tm("read_template_json")('{"name": "x"}'), "not a DECIDE monitoring template")
  expect_error(tm("read_template_json")("not json"), "not a DECIDE monitoring template")
})

test_that("Monitoring saves a template with its texts, imports a shared one and drafts from it", {
  withr::local_envvar(DECIDE_SESSION_DIR = withr::local_tempdir())
  drafted <- tm("monitoring_draft")("process", process = list(cfm.csv = cfm))$items
  drafted[[1]]$comment <- "<p>Exclusion complaints concentrate in Beni.</p>"
  shared <- tempfile(fileext = ".json")
  shiny::testServer(DECIDE:::mod_monitoring_server, args = list(workspace = DECIDE:::workspace_new()), {
    items(drafted)
    session$setInputs(context = "<p>Hotline and desks.</p>", findings = "", recommendations = "<p>Open a second desk.</p>")
    session$setInputs(tpl_name = "CFM", tpl_round = "January", tpl_keep_texts = TRUE, tpl_save_go = 1)
    t <- saved_templates()[["CFM"]]
    expect_equal(t$texts[["context"]], "<p>Hotline and desks.</p>")
    expect_equal(t$items[[1]]$comment, "<p>Exclusion complaints concentrate in Beni.</p>")
    writeLines(DECIDE:::template_json(t), shared)
    session$setInputs(tpl_import = list(datapath = shared, name = "CFM_monitoring_template.json"))
    expect_true("CFM (2)" %in% names(saved_templates()))            # imported beside the original
    # next round: the imported template drafts the same charts on the new data
    datasets(list(round2.csv = rbind(cfm, cfm)))
    items(list())
    session$setInputs(tpl = "saved:CFM (2)", tpl_apply = 1)
    expect_equal(length(items()), length(drafted))
    expect_equal(items()[[1]]$comment, "<p>Exclusion complaints concentrate in Beni.</p>")
    expect_equal(length(previous_rounds()), 1)
  })
})
