# Browser check of the React Beneficiary Selection page (ben_panel).
#   NOT_CRAN=true Rscript react/dev/test_selection.R   (from the package root)
# TW_BIG=1 loads a 30,000-row copy of the demo data (server-side paging).
source("react/dev/e2e.R")
ns <- function(x) paste0("ben_selection_1-", x)
ok <- function(cond, what) { cat(if (isTRUE(cond)) "PASS" else "FAIL", "-", what, "\n"); invisible(cond) }

file <- file.path(tw_root, "inst/extdata/registration_demo.csv")
if (nzchar(Sys.getenv("TW_BIG"))) {
  d <- utils::read.csv(file, stringsAsFactors = FALSE)
  big <- d[rep(seq_len(nrow(d)), 20), ]
  big$instanceID <- sprintf("reg:%06d", seq_len(nrow(big)))
  file <- file.path(tempdir(), "registration_big.csv")
  utils::write.csv(big, file, row.names = FALSE)
}

app <- tw_launch()
# the import page's file input is drawn by the server: wait for it first
tw_go(app, "import_panel")
app$wait_for_js("!!document.querySelector('#file_import_1-file_in.shiny-bound-input')", timeout = 120000)
tw_load_registration(app, file)
# through the navbar (tw_go() sets input$main_nav only, the React shell does not follow it)
tw_js(app, "document.querySelector('.tw-navbar .dropdown-toggle').click(); true")
Sys.sleep(0.5)
tw_js(app, "Array.from(document.querySelectorAll('.tw-navbar .dropdown-item')).find(a => a.textContent.trim() === 'Selection').click(); true")
Sys.sleep(2); tw_idle(app)
txt <- function(id) tw_js(app, sprintf("(document.getElementById('%s')||{}).textContent || ''", id))
num <- function(id) as.numeric(gsub("[^0-9.]", "", txt(ns(id))))
pending <- function() tw_js(app, "Array.from(document.querySelectorAll('.tw-sel-bar-pending')).map(e => e.textContent).join(' | ')")
tw_shot(app, "sel_design_light")

n0 <- num("ben_total")
ok(is.finite(n0) && n0 > 0, sprintf("KPIs drawn (selected households %s)", n0))
kp <- tw_js(app, "(document.querySelector('.tw-sel-kpis')||{}).textContent||''")
ok(grepl("people", kp) && grepl("of eligible", kp), paste("KPIs give households, people and shares:", substr(kp, 1, 200)))
ok(!nzchar(pending()), "no pending note at start")

# react-select: type an option and press Enter
b <- app$get_chromote_session()
pick <- function(id, text) {
  tw_js(app, sprintf("(() => { const el = document.getElementById('%s__ctl'); el.focus(); return true; })()", ns(id)))
  b$Input$insertText(text = text); Sys.sleep(0.6)
  b$Input$dispatchKeyEvent(type = "keyDown", key = "Enter", code = "Enter", windowsVirtualKeyCode = 13)
  b$Input$dispatchKeyEvent(type = "keyUp", key = "Enter", code = "Enter", windowsVirtualKeyCode = 13)
  Sys.sleep(1); tw_idle(app)
}
typein <- function(id, text) {
  tw_js(app, sprintf("(() => { const el = document.getElementById('%s__ctl'); el.focus(); el.select && el.select(); return true; })()", ns(id)))
  b$Input$insertText(text = text); Sys.sleep(0.8); tw_idle(app)
}
close_modal <- function() { tw_js(app, "$('#shiny-modal').modal('hide'); true"); Sys.sleep(1.2) }
click <- function(sel) { tw_js(app, sprintf("(() => { const e = document.querySelector(\"%s\"); if (e) e.click(); return !!e; })()", sel)); Sys.sleep(1); tw_idle(app) }

# settings wait for Apply
pick("ben_approach", "Geographic")
ok(grepl("approach", pending()), paste("approach change noted before Apply:", pending()))
ok(identical(num("ben_total"), n0), "counts unchanged before Apply")
click(paste0("#", ns("ben_apply"))); Sys.sleep(1); tw_idle(app)
ok(!nzchar(pending()), "pending note gone after Apply")
n_geo <- num("ben_total")
ok(is.finite(n_geo), sprintf("geographic: %s households", n_geo))

# prioritisation: total caseload of 300 households
click(sprintf("#%s__ctl button:nth-child(2)", ns("ben_prio_mode")))
ok(grepl("prioritisation", pending()), "prioritisation change noted")
tw_js(app, sprintf("(function(){var e=$('#%s');e.data('shiny-input-binding').receiveMessage(e[0],{value:'households'});return true})()", ns("ben_prio_count"))); Sys.sleep(1); tw_idle(app)
typein("ben_prio_n", "300")
typein("ben_prio_rationale", "Funding for the first round.")
tw_shot(app, "sel_design_pending")
click(paste0("#", ns("ben_apply"))); Sys.sleep(1); tw_idle(app)
ok(identical(num("ben_total"), 300), sprintf("caseload applied: %s served", num("ben_total")))
ok(num("ben_cut") > 0, sprintf("excluded by design: %s", num("ben_cut")))
ok(grepl("excluded by design", txt("ben_selection_1-selection_note") %||% "") || grepl("excluded by design", tw_js(app, "document.querySelector('.tw-sel-note').textContent")), "selection note says excluded by design")

# composition
click(".tw-sel .tw-tabs-nav li:nth-child(2) button")
Sys.sleep(2); tw_idle(app)
ok(tw_js(app, "document.querySelectorAll('.tw-sel-insight').length") >= 2, "insight tiles")
ok(tw_js(app, sprintf("!!document.querySelector('#%s canvas')", ns("ben_area_plot"))), "area chart drawn")
ok(tw_js(app, sprintf("!!document.querySelector('#%s canvas')", ns("ben_validation_plot"))) || grepl("Map eligibility", tw_js(app, "document.querySelector('.tw-sel-comp').textContent")), "mix chart drawn or explained")
ok(tw_js(app, "document.querySelectorAll('.tw-sel-prof tbody tr').length") > 0, "profile table")
tw_shot(app, "sel_comp_light")

# list
click(".tw-sel .tw-tabs-nav li:nth-child(3) button")
Sys.sleep(2); tw_idle(app)
foot <- tw_js(app, sprintf("(document.querySelector('#%s .tw-dt-foot')||{}).textContent||''", ns("ben_table")))
ok(grepl("of 300", foot), paste("list footer:", foot))
ok(tw_js(app, sprintf("document.querySelectorAll('#%s tbody tr').length", ns("ben_table"))) > 0, "list rows")
click(sprintf("#%s .wfp-details-btn", ns("ben_table")))
ok(tw_js(app, "!!document.querySelector('.modal.show')"), "Details opens the record")
close_modal()
Sys.sleep(1)
tw_shot(app, "sel_list_light")

# exports
click(paste0("#", ns("export_open"))); Sys.sleep(1.5); tw_idle(app)
ok(tw_js(app, sprintf("!!document.getElementById('%s')", ns("download_selection"))), "export dialog open")
cat("export picker:", tw_js(app, "Array.from(document.querySelectorAll('.modal .filter-option-inner-inner')).map(e => e.textContent).join(' | ')"),
    "; modals:", tw_js(app, "document.querySelectorAll('.modal').length"), "
")
f <- app$get_download(ns("download_selection"))
sh <- openxlsx::getSheetNames(f)
ok(all(c("Summary", "Selected", "Excluded_by_design") %in% sh) && !"Activity_log" %in% sh, paste("workbook sheets:", paste(sh, collapse = ", ")))
ok(nrow(openxlsx::read.xlsx(f, "Selected")) == 300, "Selected sheet has 300 rows")
app$set_inputs(!!ns("export_audit") := TRUE); tw_idle(app)
f2 <- app$get_download(ns("download_selection"))
ok("Activity_log" %in% openxlsx::getSheetNames(f2), "audit sheet when opted in")
app$set_inputs(!!ns("export_split") := "area"); tw_idle(app)
z <- app$get_download(ns("download_selection"))
zl <- utils::unzip(z, list = TRUE)$Name
ok(length(zl) > 1 && all(grepl("\\.xlsx$", zl)), paste("per-area zip:", length(zl), "files"))
close_modal()
Sys.sleep(1)
r <- app$get_download(ns("selection_report"))
ok(file.size(r) > 50000 && any(grepl("Beneficiary", readLines(r, n = 200, warn = FALSE))), sprintf("HTML report (%s bytes)", file.size(r)))

# dark mode
click(".tw-mode-btn"); Sys.sleep(1)
tw_shot(app, "sel_list_dark")
click(".tw-sel .tw-tabs-nav li:nth-child(2) button"); Sys.sleep(1.5)
tw_shot(app, "sel_comp_dark")
click(".tw-sel .tw-tabs-nav li:nth-child(1) button"); Sys.sleep(1)
tw_shot(app, "sel_design_dark")

# clear
click(paste0("#", ns("ben_clear"))); Sys.sleep(1); tw_idle(app)
ok(num("ben_cut") == 0, "clear: no prioritisation")

# caseload per area (the server's dialog), then the rules dialog
click(sprintf("#%s__ctl button:nth-child(3)", ns("ben_prio_mode")))
tw_js(app, sprintf("(function(){var e=$('#%s');e.data('shiny-input-binding').receiveMessage(e[0],{value:'households'});return true})()", ns("ben_prio_count"))); Sys.sleep(1); tw_idle(app)
ok(grepl("No caseload set", tw_js(app, "(document.querySelector('.tw-sel-quota')||{}).textContent||''")), "caseload summary: none set yet")
click(paste0("#", ns("quota_open"))); Sys.sleep(1.5); tw_idle(app)
ok(tw_js(app, sprintf("!!document.getElementById('%s')", ns("quota_save"))), "caseload dialog open")
app$set_inputs(!!ns("quota_1") := 50, !!ns("quota_2") := 40, !!ns("quota_3") := 30, !!ns("quota_rationale") := "Partner capacity.")
app$click(ns("quota_save")); Sys.sleep(1.5); tw_idle(app)
qs <- tw_js(app, "(document.querySelector('.tw-sel-quota')||{}).textContent||''")
ok(grepl("120 households in 3 areas", qs), paste("caseload summary:", qs))
ok(grepl("prioritisation", pending()), "caseloads wait for Apply")
click(paste0("#", ns("ben_apply"))); Sys.sleep(1); tw_idle(app)
ok(identical(num("ben_total"), 120), sprintf("caseload per area applied: %s served", num("ben_total")))
click(sprintf("#%s__ctl button:nth-child(1)", ns("ben_prio_mode")))
click(paste0("#", ns("btn_rules"))); Sys.sleep(1.5); tw_idle(app)
ok(tw_js(app, sprintf("!!document.getElementById('%s')", ns("rules_save"))), "rules dialog open")
close_modal()

# a vulnerability ranking loaded from a file (crosswalk dialog), then its threshold
pick("ben_approach", "Hybrid")
click(paste0("#", ns("ben_apply"))); Sys.sleep(1); tw_idle(app)
n_all <- num("ben_total")
card <- list(kind = "ranking", outcome = "none (ranking)", threshold = 1, created = format(Sys.Date()),
             items = list(list(criterion = "Targ_HHHousingTent", direction = "inclusion", weight = 1),
                          list(criterion = "targ_hhnolight", direction = "inclusion", weight = 1),
                          list(criterion = "DepRatio2plus", direction = "inclusion", weight = 1),
                          list(criterion = "Targ_HHOwnCattle2mor", direction = "exclusion", weight = 1)))
jf <- file.path(tempdir(), "ranking.json"); jsonlite::write_json(card, jf, auto_unbox = TRUE)
app$wait_for_js(sprintf("!!document.querySelector('#%s.shiny-bound-input')", ns("sc_file")), timeout = 30000)
app$upload_file(!!ns("sc_file") := jf); tw_idle(app); Sys.sleep(1)
app$click(ns("xwalk_apply")); Sys.sleep(1.5); tw_idle(app)
lab <- tw_js(app, "(document.querySelector('.tw-sel-bar-score .tw-sel-bar-cap')||{}).textContent||''")
ok(grepl("vulnerability ranking", lab, ignore.case = TRUE), paste("card group:", lab))
scn <- tw_js(app, "(document.querySelector('.tw-sel-scnote')||{}).textContent||''")
ok(grepl("All 4 criteria mapped", scn) && grepl("calibrate it in Monitoring", scn), paste("scorecard note (React):", scn))
thr <- tw_js(app, sprintf("document.getElementById('%s__ctl').value", ns("scorecard_threshold")))
ok(identical(as.character(thr), "1"), paste("threshold starts at the card's:", thr))
n_card <- num("ben_total")
ok(is.finite(n_card) && n_card < n_all, sprintf("card in use: %s of %s households", n_card, n_all))
# a slider now: moved as a server update would
tw_js(app, sprintf("(function(){var e=$('#%s');e.data('shiny-input-binding').receiveMessage(e[0],{value:2});return true})()", ns("scorecard_threshold"))); Sys.sleep(1); tw_idle(app)
ok(tw_js(app, sprintf("document.getElementById('%s__ctl').type", ns("scorecard_threshold"))) == "range", "the threshold is a slider")
ok(grepl("score", pending()), paste("threshold change noted:", pending()))
ok(identical(num("ben_total"), n_card), "count waits for Apply")
tw_shot(app, "sel_design_card_dark")
click(paste0("#", ns("ben_apply"))); Sys.sleep(1); tw_idle(app)
ok(num("ben_total") < n_card && !nzchar(pending()), sprintf("threshold 2 applied: %s households", num("ben_total")))
click(".tw-sel .tw-tabs-nav li:nth-child(2) button"); Sys.sleep(2); tw_idle(app)
ok(tw_js(app, sprintf("!!document.querySelector('#%s canvas')", ns("rank_dep_plot"))), "ranking chart (share selected by deprivations)")
tw_js(app, sprintf("document.getElementById('%s').scrollIntoView(); true", ns("rank_dep_plot"))); Sys.sleep(1)
tw_shot(app, "sel_comp_ranking_dark")
click(".tw-mode-btn"); Sys.sleep(1)
tw_shot(app, "sel_comp_ranking_light")

# the list pages (on the server above 5,000 rows: TW_BIG=1)
click(".tw-sel .tw-tabs-nav li:nth-child(3) button"); Sys.sleep(2); tw_idle(app)
first <- function() tw_js(app, sprintf("(document.querySelector('#%s tbody tr td')||{}).textContent||''", ns("ben_table")))
foot <- function() tw_js(app, sprintf("(document.querySelector('#%s .tw-dt-foot span')||{}).textContent||''", ns("ben_table")))
f1 <- foot(); r1 <- first()
click(sprintf("#%s [aria-label='Next page']", ns("ben_table"))); Sys.sleep(1.5); tw_idle(app)
ok(first() != r1 && grepl("^21-40", foot()), sprintf("next page: %s -> %s", f1, foot()))

# the summary by area under the design
click(".tw-sel .tw-tabs-nav li:nth-child(1) button"); Sys.sleep(1.5); tw_idle(app)
nr <- tw_js(app, sprintf("document.querySelectorAll('#%s tbody tr').length", ns("sel_by_area")))
ok(nr > 1, paste("summary by area rows:", nr, substr(txt(ns("sel_by_area")), 1, 120)))

# the monitoring sample: a dialog, a workbook, then Monitoring reads it back
click(paste0("#", ns("mon_open"))); Sys.sleep(1.5); tw_idle(app)
ok(tw_js(app, sprintf("!!document.querySelector('.modal.show #%s')", ns("mon_draw"))), "monitoring sample dialog open")
app$set_inputs(!!ns("mon_size_mode") := "fixed", wait_ = FALSE); Sys.sleep(0.5)
app$set_inputs(!!ns("mon_n") := 20, !!ns("mon_reserve") := 25, wait_ = FALSE); Sys.sleep(0.5)
app$click(ns("mon_draw")); Sys.sleep(2); tw_idle(app)
ok(grepl("households to survey", tw_js(app, "(document.querySelector('.modal.show .alert')||{}).textContent||''")), "drawn: summary in the dialog")
sf <- app$get_download(ns("mon_download"))
sh <- openxlsx::getSheetNames(sf)
ok(all(c("How to use", "Sample", "Replacements", "Design", "Settings") %in% sh), paste("sample workbook sheets:", paste(sh, collapse = ", ")))
sm <- openxlsx::read.xlsx(sf, "Sample")
ok(all(c("household_id", "eligibility", "sample_area") %in% names(sm)) && setequal(unique(sm$eligibility), c("Eligible", "Not eligible")),
   paste("sample columns:", paste(head(names(sm), 12), collapse = ", ")))
ok(nrow(openxlsx::read.xlsx(sf, "Replacements")) > 0, "replacements on their own sheet")
close_modal()
# Monitoring: the survey (the sample's households, their eligibility re-measured) and the sample list
svf <- file.path(tw_root, "inst/extdata/survey_demo.csv")  # every registered household, re-measured
tw_js(app, "Array.from(document.querySelectorAll('.tw-navbar .nav-link')).find(a=>a.textContent.includes('Targeting Monitoring')).click(); true")
Sys.sleep(1.5); tw_idle(app)
app$wait_for_js("!!document.querySelector('#monitoring_1-pdm-pdm_file.shiny-bound-input')", timeout = 60000)
ok(grepl("How to measure the implementation errors", tw_js(app, "document.querySelector('.tw-mon').textContent")), "instructions shown")
app$upload_file(`monitoring_1-pdm-pdm_file` = svf); Sys.sleep(2); tw_idle(app)
app$wait_for_js("!!document.querySelector('#monitoring_1-pdm-ptm_sample_file.shiny-bound-input')", timeout = 30000)
app$upload_file(`monitoring_1-pdm-ptm_sample_file` = sf); Sys.sleep(2); tw_idle(app)
mon <- tw_js(app, "document.querySelector('.tw-mon').textContent")
ok(grepl("surveyed households found in the sample list", mon), paste("matched:", regmatches(mon, regexpr("[0-9,]+ of [0-9,]+ surveyed households found", mon))))
ms <- function(id, v) tw_js(app, sprintf("(function(){var el=document.getElementById('monitoring_1-pdm-%s');$(el).data('shiny-input-binding').receiveMessage(el,{value:%s});return true})()",
                                         id, jsonlite::toJSON(v, auto_unbox = TRUE)))
# Monitoring stands alone: Selection's logic (card, threshold applied, rules)
# is downloaded there and loaded in Monitoring from its file
lf <- app$get_download(ns("download_logic"))
lg <- jsonlite::fromJSON(lf, simplifyVector = FALSE)
ok(identical(lg$format, "DECIDE selection logic") && length(lg$scorecard$items) == 4,
   paste("selection logic downloaded:", lg$approach, "threshold", lg$scorecard$threshold))
app$upload_file(`monitoring_1-pdm-pdm_logic_file` = lf); tw_idle(app); Sys.sleep(1)
ms("ptm_id", "instanceID"); Sys.sleep(1); ms("pdm_elig_source", "logic"); Sys.sleep(1); tw_idle(app)
tw_js(app, "document.getElementById('monitoring_1-pdm-pdm_run').click(); true"); Sys.sleep(3); tw_idle(app)
ok(grepl("[0-9]%", tw_js(app, "(document.querySelector('.tw-mon .sc-cm')||{}).textContent||''")),
   paste("errors computed from the sample:", tw_js(app, "(document.querySelector('.tw-mon .sc-cm')||{}).textContent||''")))
tw_shot(app, "mon_from_sample")
kpi_list <- tw_js(app, "(document.querySelector('.tw-mon .sc-cm')||{}).textContent||''")

# the survey alone: the sample's households with the list's columns kept (as a
# preloaded form would) and their answers; nothing uploaded in step 2
ok("sample_group_size" %in% names(sm), "the sample list carries each group's size")
sv <- utils::read.csv(svf, stringsAsFactors = FALSE)
# the demo survey has every household, so the list route also surveyed the
# replacements: keep both sheets for the same households
keepc <- c("household_id", "eligibility", "sample_area", "sample_group_size")
pre <- rbind(sm[keepc], openxlsx::read.xlsx(sf, "Replacements")[keepc])
alone <- cbind(pre, sv[match(pre$household_id, sv$instanceID), setdiff(names(sv), names(sm)), drop = FALSE])
af <- file.path(tempdir(), "survey_alone.csv"); utils::write.csv(alone, af, row.names = FALSE)
app$upload_file(`monitoring_1-pdm-pdm_file` = af); Sys.sleep(2); tw_idle(app)
mon <- tw_js(app, "document.querySelector('.tw-mon').textContent")
ok(grepl("Read from the survey", mon), "sample read from the survey, nothing to upload")
ms("pdm_elig_source", "logic"); Sys.sleep(1); tw_idle(app)
tw_js(app, "document.getElementById('monitoring_1-pdm-pdm_run').click(); true"); Sys.sleep(3); tw_idle(app)
kpi_alone <- tw_js(app, "(document.querySelector('.tw-mon .sc-cm')||{}).textContent||''")
ok(identical(kpi_alone, kpi_list), paste("same errors from the survey alone:", kpi_alone))
tw_shot(app, "mon_survey_alone")
cm <- tw_js(app, "(document.querySelector('.tw-mon .sc-cm')||{}).textContent||''")
ok(grepl("Inclusion error", cm) && grepl("surveyed", cm), paste("implementation matrix:", substr(cm, 1, 160)))
tw_shot(app, "mon_matrix")

# shinyreact logs every output error, validate() messages included, as "Error for <id>"
notes <- tw_js(app, "Array.from(document.querySelectorAll('[id^=\"ben_selection_1-\"].tw-output-note')).map(e => e.id + ': ' + e.textContent).join(' | ')")
cat("output notes on the page:", notes, "
")
err <- grep("^Error for ", tw_errors(app), value = TRUE, invert = TRUE)
ok(!length(err), paste("browser errors:", paste(err, collapse = " || ")))
app$stop()
