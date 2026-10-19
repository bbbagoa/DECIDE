# Browser check of the React Targeting Monitoring page (react/src/pages/monitoring).
# Run from the package root: NOT_CRAN=true Rscript react/dev/test_monitoring.R
source("react/dev/e2e.R")
ok <- function(cond, what) { cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n"); invisible(cond) }
# a React input set as the server would (update*Input): the toolkit's hidden binding takes it
tw_set <- function(app, id, value) {
  app$run_js(sprintf("(function(){var el=document.getElementById(%s);$(el).data('shiny-input-binding').receiveMessage(el,%s);})()",
                     jsonlite::toJSON(id, auto_unbox = TRUE), jsonlite::toJSON(list(value = value), auto_unbox = TRUE)))
  Sys.sleep(0.6); tw_idle(app)
}
txt <- function(app, sel) app$get_js(sprintf("(document.querySelector(%s)||{}).textContent||''", jsonlite::toJSON(sel, auto_unbox = TRUE)))
# React buttons are not Shiny-bound elements: click them in the page
click <- function(app, id) { app$run_js(sprintf("document.getElementById('%s').click()", id)); Sys.sleep(0.8); tw_idle(app) }
P <- "monitoring_1-pdm-"

app <- tw_launch()
# through the navbar (the React shell keeps the current page)
app$run_js("Array.from(document.querySelectorAll('.tw-navbar .nav-link')).find(a=>a.textContent.includes('Targeting Monitoring')).click()")
Sys.sleep(1.5); tw_idle(app)
app$wait_for_js("!!document.querySelector('#monitoring_1-pdm-pdm_file.shiny-bound-input')", timeout = 120000)
Sys.sleep(3)
tw_shot(app, "mon_01_empty")
ok(grepl("No survey data loaded", txt(app, ".tw-mon")), "empty state before any data")
tw_set(app, paste0(P, "pdm_tabs"), "calibrate"); Sys.sleep(1)
ok(grepl("No vulnerability ranking loaded", txt(app, ".tw-mon-calib")), "calibration tab: no ranking loaded")
tw_set(app, paste0(P, "pdm_tabs"), "errors")

# --- tab 1: survey data, mapping, compute
app$upload_file(`monitoring_1-pdm-pdm_file` = file.path(tw_root, "inst/extdata/assessment_demo.csv"))
tw_idle(app)
try(app$wait_for_js("document.querySelector('.tw-mon').textContent.includes('1,500 records')", timeout = 30000), silent = TRUE)
ok(grepl("1,500 records", txt(app, ".tw-mon")), "survey loaded (1,500 records)")
click(app, paste0(P, "fsi-open")); Sys.sleep(1.5)
ok(app$get_js("!!document.querySelector('.modal.show #monitoring_1-pdm-fsi-compute')"), "food security indicators dialog opens on the survey")
app$run_js("$('#shiny-modal').modal('hide')"); Sys.sleep(1)
tw_set(app, paste0(P, "benef_source"), "column")
tw_set(app, paste0(P, "pdm_beneficiary"), "Targ_HHRemittance"); Sys.sleep(1)
radio <- app$get_js(sprintf("Array.from(document.querySelectorAll('[id=\"%spdm_benef_level__ctl\"] input')).map(i => (i.checked ? '*' : '') + i.nextElementSibling.textContent).join('|')", P))
ok(length(strsplit(radio, "|", fixed = TRUE)[[1]]) == 2 && grepl("\\*", radio), paste("answer meaning received: React radio from JSON, one picked:", radio))
tw_set(app, paste0(P, "pdm_elig_source"), "logic"); Sys.sleep(1)
ok(grepl("Load the selection logic", txt(app, ".tw-mon")), "eligibility note: no selection logic loaded")
tw_set(app, paste0(P, "pdm_elig_source"), "column")
tw_set(app, paste0(P, "pdm_eligibility"), "rCSI_high")
tw_set(app, paste0(P, "pdm_weight_mode"), "none")
tw_set(app, paste0(P, "pdm_unit"), "Province")
click(app, paste0(P, "pdm_run")); tw_idle(app); Sys.sleep(2)
ok(app$get_js("document.querySelectorAll('.shiny-notification').length") == 1, "one click, one computation (one notification)")
body <- txt(app, ".tw-mon")
ok(grepl("[0-9]%", txt(app, ".tw-mon .sc-cm")) && !nzchar(txt(app, ".tw-mon-kpis")) && !nzchar(txt(app, ".tw-mon-verdict")),
   "errors in the matrix, no KPI tiles or verdict card")
ok(grepl("Decision and coverage by area", body) && grepl("Coverage", txt(app, ".tw-mon .tw-table")), "decision and coverage by area in one table")
ok(app$get_js("document.querySelectorAll('.tw-mon .tw-table .tw-mon-err[class*=is-]').length") > 0, "area errors coloured by the tolerance band")
nlv <- app$get_js("document.querySelectorAll('#pdm-area-level option').length")
rows1 <- app$get_js("document.querySelectorAll('.tw-mon .tw-table tbody tr').length")
app$run_js("var s=document.getElementById('pdm-area-level');Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype,'value').set.call(s,String(s.options.length-1));s.dispatchEvent(new Event('change',{bubbles:true}))"); Sys.sleep(0.5)
rows2 <- app$get_js("document.querySelectorAll('.tw-mon .tw-table tbody tr').length")
ok(nlv > 1 && rows2 != rows1, paste("area level picker:", nlv, "levels,", rows1, "->", rows2, "rows"))
xf <- app$get_download(paste0(P, "pdm_download"))
xs <- openxlsx::getSheetNames(xf)
ok(identical(xs[1:2], c("Summary", "Matrix")) && sum(startsWith(xs, "Areas - ")) == nlv, paste("Excel export follows the page:", paste(xs, collapse = ", ")))
if (nzchar(Sys.getenv("TW_SHOTS"))) file.copy(xf, file.path(Sys.getenv("TW_SHOTS"), "implementation_errors.xlsx"), overwrite = TRUE)
tw_set(app, paste0(P, "tol_upper"), 6); Sys.sleep(1.5)
ok(grepl("5%-6%", txt(app, ".tw-mon .sc-cm + div")), "matrix follows the tolerance")
tw_set(app, paste0(P, "tol_upper"), 20); Sys.sleep(1)
tw_shot(app, "mon_02_errors")
Sys.sleep(1)  # the details are on the errors tab
ok(app$get_js(sprintf("!!document.querySelector('#%spdm_plot canvas') && !!document.querySelector('#%spdm_cov_plot canvas')", P, P)), "errors chart and coverage chart drawn")
ok(grepl("Inclusion error", txt(app, ".tw-mon .sc-cm")), "implementation matrix drawn")
tw_shot(app, "mon_03_details")

# population sizes per area: the editable table
tw_set(app, paste0(P, "pdm_weight_mode"), "population")
tw_set(app, paste0(P, "pop_scope"), "unit"); Sys.sleep(1)
edit <- function(row, col, value) {
  app$run_js(sprintf("(function(){var t=document.getElementById('%spop_table');var td=t.querySelectorAll('tbody tr')[%d].querySelectorAll('td')[%d];
    td.dispatchEvent(new MouseEvent('dblclick',{bubbles:true}));
    setTimeout(function(){var i=t.querySelector('tbody input');var s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set;
      s.call(i,'%s');i.dispatchEvent(new Event('input',{bubbles:true}));i.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',bubbles:true}));},200);})()",
    P, row, col, value))
  Sys.sleep(1.5); tw_idle(app)
}
for (r in 0:2) { edit(r, 3, "5000"); edit(r, 4, "20000") }
ok(grepl("20,000", txt(app, sprintf("#%spop_table", P))), "population table edited (cell edit reached the server)")
tw_shot(app, "mon_04_population")
click(app, paste0(P, "pdm_run")); tw_idle(app); Sys.sleep(2)
ok(grepl("population sizes per area", txt(app, ".tw-mon")), "errors weighted by the sizes typed in")

# --- tab 1: explore (chart builder on the PDM data)
tw_set(app, paste0(P, "pdm_tabs"), "explore")
B <- "monitoring_1-pdm_charts-"
tw_set(app, paste0(B, "x"), "Province"); tw_set(app, paste0(B, "group"), "HHHSex"); Sys.sleep(1)
ok(app$get_js(sprintf("!!document.querySelector('#%spreview canvas')", B)), "builder preview drawn (PDM)")
tw_set(app, paste0(B, "style"), "donut"); Sys.sleep(1)
ok(grepl("pie or donut shows one series", txt(app, ".tw-mon .tw-cb .tw-cb-note")), "pie note above the preview")
tw_set(app, paste0(B, "type"), "crosstab"); tw_set(app, paste0(B, "style"), "column"); Sys.sleep(1.5)
ok(grepl("Chi-square", txt(app, ".tw-mon .tw-cb .tw-cb-note")), paste("crosstab test note:", substr(txt(app, ".tw-mon .tw-cb .tw-cb-note"), 1, 60)))
tw_set(app, paste0(B, "type"), "count"); Sys.sleep(1)
tw_click(app, paste0(B, "colours")); Sys.sleep(1)
ok(app$get_js("document.querySelectorAll('.modal input[type=color]').length") >= 2, "colours dialog: one picker per series")
tw_shot(app, "mon_05b_colours")
tw_js(app, "(function(){var c=document.querySelector('.modal input[type=color]');c.value='#123456';c.dispatchEvent(new Event('input',{bubbles:true}));return 1})()")
tw_click(app, paste0(B, "col_apply")); Sys.sleep(1.5)
ok(grepl("Colours (set)", txt(app, ".tw-mon .tw-cb"), fixed = TRUE), "colours applied: the button says so")
tw_set(app, paste0(B, "title"), "Households by province and sex")
tw_shot(app, "mon_05_explore")
tw_set(app, paste0(B, "display"), "table"); Sys.sleep(1)
ok(grepl("Total", txt(app, sprintf("#%spreview_table", B))), "builder table view")
tw_set(app, paste0(B, "display"), "chart")
click(app, paste0(B, "add")); tw_idle(app)

# --- tab 2: targeting process
tw_set(app, "monitoring_1-tabs", "process"); Sys.sleep(1)
ok(grepl("No data yet", app$get_js("document.querySelectorAll('.tw-mon .tw-cb')[1].textContent")), "process builder: empty state before a dataset")
app$upload_file(`monitoring_1-pm_file` = file.path(tw_root, "inst/extdata/registration_demo.csv")); tw_idle(app); Sys.sleep(2)
ok(grepl("registration_demo.csv", txt(app, ".tw-mon-chips")), "process dataset listed")
C <- "monitoring_1-pm_charts-"
tw_set(app, paste0(C, "x"), "HHStatus"); tw_set(app, paste0(C, "style"), "donut"); Sys.sleep(1)
ok(app$get_js(sprintf("!!document.querySelector('#%spreview canvas')", C)), "builder preview drawn (process, donut)")
tw_set(app, paste0(C, "title"), "Households by status")
tw_shot(app, "mon_06_process")
click(app, paste0(C, "add")); tw_idle(app)
tw_set(app, paste0(C, "type"), "trend"); tw_set(app, paste0(C, "date"), "SvyDate"); tw_set(app, paste0(C, "style"), "auto"); Sys.sleep(1)
tw_set(app, paste0(C, "title"), "Registrations per month")
click(app, paste0(C, "add")); tw_idle(app)

# --- tab 3: the report
tw_set(app, "monitoring_1-tabs", "report"); Sys.sleep(1)
titles <- function() app$get_js("Array.from(document.querySelectorAll('.tw-mon-item-title')).map(e=>e.innerText).join('|')")
ok(length(strsplit(titles(), "|", fixed = TRUE)[[1]]) == 3, paste("three items in the report:", titles()))
ok(txt(app, ".tw-mon-tabcount") == "3" && grepl("Report builder", txt(app, ".tw-mon > .tw-tabs > .tw-tabs-nav")), paste("Report builder tab counts the items:", txt(app, ".tw-mon-tabcount")))
app$run_js("document.querySelectorAll('.tw-mon-item')[0].querySelector('button[title^=\"Make half\"]').click()"); tw_idle(app); Sys.sleep(1)
app$run_js("document.querySelectorAll('.tw-mon-item')[1].querySelector('button[title^=\"Make half\"]').click()"); tw_idle(app); Sys.sleep(1)
ok(app$get_js("document.querySelectorAll('.tw-mon-item.is-half').length") == 2, "two items made half width")
before <- titles()
app$run_js("document.querySelectorAll('.tw-mon-item')[2].querySelector('button[title=\"Move up\"]').click()"); tw_idle(app); Sys.sleep(1)
ok(!identical(titles(), before), paste("moved up:", titles()))
# drag the last item onto the first
app$run_js("(function(){var its=document.querySelectorAll('.tw-mon-item');var a=its[2],b=its[0];
  a.querySelector('.tw-mon-drag').dispatchEvent(new MouseEvent('mousedown',{bubbles:true}));
  setTimeout(function(){var dt=new DataTransfer();a.dispatchEvent(new DragEvent('dragstart',{bubbles:true,dataTransfer:dt}));
    setTimeout(function(){b.dispatchEvent(new DragEvent('dragover',{bubbles:true,cancelable:true,dataTransfer:dt}));
      b.dispatchEvent(new DragEvent('drop',{bubbles:true,cancelable:true,dataTransfer:dt}));a.dispatchEvent(new DragEvent('dragend',{bubbles:true,dataTransfer:dt}));},100);},100);})()")
Sys.sleep(1.5); tw_idle(app)
before2 <- strsplit(before, "|", fixed = TRUE)[[1]]
after <- strsplit(titles(), "|", fixed = TRUE)[[1]]
ok(length(after) == 3 && !identical(titles(), before) , paste("dragged:", titles()))
# a comment typed in an item reaches the server; a report text too
app$run_js("(function(){var e=document.querySelector('.tw-mon-item .tw-rich');e.focus();document.execCommand('insertText',false,'Women are under-represented.');})()")
tw_set(app, "monitoring_1-context", "<p>Pilot round, three provinces.</p>")
Sys.sleep(1.5); tw_idle(app)
tw_shot(app, "mon_07_report")
ok(isTRUE(app$get_js("!!window.twMonDl")), "download message handler registered (check without warnings downloads at once)")
# the check, then the download
click(app, "monitoring_1-report_check"); tw_idle(app); Sys.sleep(1)
ok(grepl("Before you export", txt(app, "#shiny-modal")), "report check lists what to look at first")
app$run_js("$('#shiny-modal').modal('hide')"); Sys.sleep(1)
f <- app$get_download("monitoring_1-report")
rh <- paste(readLines(f, encoding = "UTF-8", warn = FALSE), collapse = "
")
ok(grepl("Eligibility vs. assistance received", rh) && grepl("Decision and coverage by area", rh) && !grepl("class=\"leaflet html-widget", rh),
   "report: matrix and one area table, no map")
if (nzchar(Sys.getenv("TW_SHOTS"))) file.copy(f, file.path(Sys.getenv("TW_SHOTS"), "monitoring_report.html"), overwrite = TRUE)
html <- paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
ok(file.size(f) > 10000 && grepl("Households by status", html) && grepl("Women are under-represented", html) && grepl("Pilot round", html),
   sprintf("monitoring report downloaded (%s KB) with items, comment and context", round(file.size(f) / 1024)))

# template: save, export as JSON
click(app, "monitoring_1-tpl_save"); tw_idle(app); Sys.sleep(1)
app$set_inputs(`monitoring_1-tpl_name` = "E2E template"); click(app, "monitoring_1-tpl_save_go"); tw_idle(app); Sys.sleep(1)
j <- app$get_download("monitoring_1-tpl_export")
js <- jsonlite::fromJSON(j, simplifyVector = FALSE)
ok(identical(js$format, "DECIDE monitoring template") || grepl("DECIDE monitoring template", paste(readLines(j, warn = FALSE), collapse = "")),
   sprintf("template exported as JSON (%d items)", length(js$items)))

# --- calibrate a vulnerability ranking: its file loaded in Monitoring itself
card <- list(kind = "ranking", outcome = "none (ranking)", threshold = 1, created = format(Sys.Date()),
             items = list(list(criterion = "Targ_HHHousingTent", direction = "inclusion", weight = 1),
                          list(criterion = "Targ_HHNoLight", direction = "inclusion", weight = 1),
                          list(criterion = "Targ_HHDepRatio2plus", direction = "inclusion", weight = 1),
                          list(criterion = "Targ_HHOwnCattle2more", direction = "exclusion", weight = 1)))
# the selection logic file of a Selection that used this ranking
logic <- list(format = "DECIDE selection logic", version = 1, created = format(Sys.time()), approach = "scorecard",
              approach_label = "Scorecard / proxy means test", combine = "both", scorecard = card)
jf <- file.path(tempdir(), "logic_mon.json"); jsonlite::write_json(logic, jf, auto_unbox = TRUE)
app$run_js("Array.from(document.querySelectorAll('.tw-navbar .nav-link')).find(a=>a.textContent.includes('Targeting Monitoring')).click()")
Sys.sleep(1.5); tw_idle(app)
app$upload_file(`monitoring_1-pdm-pdm_logic_file` = jf); tw_idle(app); Sys.sleep(1)
tw_set(app, "monitoring_1-tabs", "pdm"); tw_set(app, paste0(P, "pdm_tabs"), "calibrate"); Sys.sleep(1.5)
ok(app$get_js(sprintf("!!document.getElementById('%scalib_run') && document.getElementById('%scalib_run').offsetParent !== null", P, P)),
   "calibration tab: outcome, level and Measure shown with a ranking adopted")
ok(!grepl("cannot be scored", txt(app, ".tw-mon-calib")), "the survey has the ranking's criteria")
tw_set(app, paste0(P, "calib_outcome"), "FSI_CARI2_2class"); Sys.sleep(1.5)
lvl <- app$get_js(sprintf("(document.getElementById('%scalib_pos__ctl')||{closest:()=>null}).closest('.tw-field').textContent", P))
ok(nzchar(gsub("Level meaning vulnerable", "", lvl)), paste("level filled by the server:", lvl))
click(app, paste0(P, "calib_run")); Sys.sleep(2); tw_idle(app)
cal <- txt(app, ".tw-mon-calib")
ok(grepl("AUC of the ranking", cal) && grepl("[0-9]\\.[0-9]{3}", txt(app, ".tw-mon-calib .tw-mon-kpis")), paste("calibration measured:", substr(txt(app, ".tw-mon-calib .tw-mon-kpis"), 1, 120)))
ok(grepl("threshold that keeps both errors lowest|No threshold does better", cal), "best threshold stated")
tw_shot(app, "mon_12_calibrate")

# dark mode
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1.5)
tw_shot(app, "mon_08_report_dark")
tw_set(app, "monitoring_1-tabs", "pdm"); tw_set(app, paste0(P, "pdm_tabs"), "errors"); Sys.sleep(1)
tw_shot(app, "mon_09_errors_dark")
tw_set(app, paste0(P, "pdm_tabs"), "calibrate"); Sys.sleep(1)
tw_shot(app, "mon_12_calibrate_dark")
tw_set(app, paste0(P, "pdm_tabs"), "explore"); Sys.sleep(1)
tw_shot(app, "mon_10_explore_dark")
tw_set(app, "monitoring_1-tabs", "process"); Sys.sleep(1)
tw_shot(app, "mon_11_process_dark")

# errors of this page (other pages are checked by their own scripts)
e <- grep("monitoring", tw_errors(app), value = TRUE)
ok(!length(e), paste("no browser errors on this page", paste(utils::head(e, 5), collapse = " / ")))
cat("all browser errors:", length(tw_errors(app)), "
")
app$stop()
