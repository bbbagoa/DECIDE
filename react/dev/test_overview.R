# Browser check of the React Overview (react/src/pages/overview/): ECharts
# charts, the table and chart builders.
# From the package root, after `cd react && npm run build`:
#   NOT_CRAN=true Rscript react/dev/test_overview.R
# Prints PASS / FAIL lines; screenshots go to TW_SHOTS (or tempdir()).
source("react/dev/e2e.R")
app <- tw_launch()
on.exit(app$stop())
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
js <- function(x) tw_js(app, x)
click <- function(id) { app$run_js(sprintf("document.getElementById('%s').click()", id)); Sys.sleep(1); tw_idle(app) }
txt <- function(sel) js(sprintf("(document.querySelector(%s)||{}).textContent||''", jsonlite::toJSON(sel, auto_unbox = TRUE)))
# React inputs take a value as a server update would (their hidden binding element)
set <- function(...) {
  a <- list(...)
  for (id in names(a)) app$run_js(sprintf("var e=$('#%s'); e.data('shiny-input-binding').receiveMessage(e[0], {value: %s})",
                                          id, jsonlite::toJSON(a[[id]], auto_unbox = TRUE)))
  Sys.sleep(1.2); tw_idle(app)
}
go <- function(label) {
  app$run_js(sprintf("Array.from(document.querySelectorAll('.tw-navbar .dropdown-item, .tw-navbar .nav-link')).find(a=>a.textContent.trim().endsWith('%s')).click()", label))
  Sys.sleep(1.5); tw_idle(app)
}
section <- function(title) {
  app$run_js(sprintf("var b=Array.from(document.querySelectorAll('.tw-rov-sec-head')).find(b=>b.textContent.includes('%s')); if (b.getAttribute('aria-expanded')!=='true') b.click()", title))
  Sys.sleep(1.5); tw_idle(app)
}
canvases <- function(sel) js(sprintf("Array.from(document.querySelectorAll('%s canvas')).filter(c=>c.offsetWidth>0).length", sel))
real_errors <- function() { e <- tw_errors(app); e[!(startsWith(e, "Error for ") & grepl(": [object Object]", e, fixed = TRUE))] }
ns <- function(x) paste0("overview_1-", x)
plot_note <- function() txt(sprintf("#%s.tw-output-note", ns("gb_plot")))

tw_go(app, "import_panel")
try(app$wait_for_js("!!document.querySelector('#file_import_1-file_in.shiny-bound-input')", timeout = 60000))
tw_load_registration(app)
go("Overview")
ok(js("document.querySelector('.tw-rov').offsetWidth > 0"), "the Overview shows")
ok(js("!document.querySelector('.recharts-wrapper, .recharts-surface')"), "no Recharts left")
ok(canvases(".tw-ov-daily") == 1, "households per day drawn (ECharts)")
ok(canvases(".tw-rov-sec.open") >= 3, paste("who is in the data: charts drawn:", canvases(".tw-rov-sec.open")))
tw_shot(app, "ov_who")
app$run_js("Array.from(document.querySelectorAll('.tw-seg-r .btn')).find(b=>b.textContent==='Total').click()"); Sys.sleep(1)
tw_shot(app, "ov_daily_total")
app$run_js("Array.from(document.querySelectorAll('.tw-seg-r .btn')).find(b=>b.textContent==='By area').click()"); Sys.sleep(.5)
section("Vulnerability")
ok(canvases(".tw-rov-sec.open") >= 2, paste("vulnerability charts drawn:", canvases(".tw-rov-sec.open")))
tw_shot(app, "ov_vuln")

# ---- Apply filter
# pick Ituri in the Admin 1 picker (react-select: type, then Enter)
app$run_js("var i=document.querySelector('.tw-rov-side input[id^=react-select]'); i.focus(); Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set.call(i,'Ituri'); i.dispatchEvent(new Event('input',{bubbles:true}));"); Sys.sleep(.6)
app$run_js("var i=document.querySelector('.tw-rov-side input[id^=react-select]'); i.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',keyCode:13,bubbles:true}))"); Sys.sleep(.6)
# the Overview's own buttons carry no id
app$run_js("Array.from(document.querySelectorAll('.tw-rov-actions button')).find(b=>b.textContent.includes('Apply')).click()"); Sys.sleep(1.5); tw_idle(app)
chip <- txt(".tw-ov-chip")
ok(grepl("All", chip) && !grepl("1,500", chip), paste("Apply filters the figures:", chip))
tw_shot(app, "ov_filtered")
app$run_js("document.querySelector('.tw-rov-actions button[title]').click()"); Sys.sleep(1.5); tw_idle(app)
ok(grepl("1,500", txt(".tw-ov-chip")), paste("Clear:", txt(".tw-ov-chip")))

# ---- Table builder
section("Table builder")
rows <- function() js(sprintf("document.querySelectorAll('#%s tbody tr').length", ns("ct_table")))
ok(rows() > 1, paste("cross-tab rows:", rows(), "caption:", txt(".tw-ob-caption")))
ok(grepl("Chi-square", txt(".tw-rov-sec.open .tw-ob-note")), "chi-square note")
tw_shot(app, "ov_table")
set(`overview_1-ct_stat` = "row")
ok(grepl("100.0%", txt(sprintf("#%s tbody", ns("ct_table")))), "row percentages: totals at 100%")
set(`overview_1-ct_stat` = "mean")
ok(js(sprintf("document.getElementById('%s__ctl').offsetParent !== null", ns("ct_value"))), "the number picker shows for a mean")
ok(grepl("Mean of", txt(".tw-ob-caption")), paste("mean:", txt(".tw-ob-caption")))
set(`overview_1-ct_stat` = "n", `overview_1-ct_col` = "")
ok(grepl("Total", txt(sprintf("#%s thead", ns("ct_table")))) && !grepl("Chi", txt(".tw-rov-sec.open .tw-ob-note")), "one-way table")
set(`overview_1-ct_row` = "instanceID")
ok(grepl("Too many options", txt(sprintf("#%s", ns("ct_table")))), paste("too many options refused:", substr(txt(sprintf("#%s", ns("ct_table"))), 1, 90)))
set(`overview_1-ct_row` = "HHStatus", `overview_1-ct_col` = "HHHSex", `overview_1-ct_stat` = "total")
tw_shot(app, "ov_table_total")

# ---- Chart builder: every chart type
section("Chart builder")
type <- function(label) { app$run_js(sprintf("Array.from(document.querySelectorAll('.tw-ob-bar .tw-seg .btn')).find(b=>b.textContent.trim()==='%s').click()", label)); Sys.sleep(1.2); tw_idle(app) }
types_shown <- function() js("Array.from(document.querySelectorAll('.tw-ob-bar .tw-seg .btn')).map(b=>b.textContent.trim()).join('|')")
drawn <- function() canvases(sprintf("#%s", ns("gb_plot"))) > 0 && !nzchar(plot_note())
check <- function(x, y, g, labels, shot) {
  set(`overview_1-gb_x` = x, `overview_1-gb_y` = y, `overview_1-gb_group` = g)
  ts <- types_shown()
  for (l in labels) {
    type(l)
    ok(drawn(), sprintf("%s ~ %s | %s: %s (%s) note: %s", x, y, g, l, ts, txt(sprintf("#%s", ns("gb_note")))))
    app$run_js(sprintf("document.querySelector('.tw-rov-sections').scrollTop = document.getElementById('%s').offsetTop - 60", ns("gb_plot"))); Sys.sleep(.4)
    tw_shot(app, paste0("ov_gb_", shot, "_", gsub("[^a-z0-9]+", "_", tolower(l))))
  }
}
check("HHHAge", "", "", c("Histogram", "Box plot"), "num")
check("HHHAge", "", "HHHSex", c("Histogram", "Box plot"), "num_g")
check("HHStatus", "", "", c("Bars (share of households)", "Bars (households)"), "cat")
check("HHStatus", "", "HHHSex", c("Bars (share of households)"), "cat_g")
check("HHHAge", "Scoring_total", "", c("Scatter with trend line", "Scatter"), "numnum")
check("HHHAge", "Scoring_total", "HHHSex", c("Scatter with trend line"), "numnum_g")
check("HHStatus", "Scoring_total", "", c("Box plot", "Mean", "Violin"), "catnum")
check("HHStatus", "Scoring_total", "HHHSex", c("Box plot", "Mean", "Violin"), "catnum_g")
check("HHStatus", "HHHSex", "", c("100% stacked bars", "Stacked bars (households)", "Side by side"), "catcat")
check("HHStatus", "HHHSex", "Province", c("100% stacked bars"), "catcat_g")
set(`overview_1-gb_x` = "HHStatus", `overview_1-gb_y` = "", `overview_1-gb_group` = "instanceID")
ok(grepl("Too many options", plot_note()), paste("too many options refused:", substr(plot_note(), 1, 80)))

# ---- Axes dialog (the server's)
set(`overview_1-gb_x` = "HHStatus", `overview_1-gb_y` = "Scoring_total", `overview_1-gb_group` = "")
type("Box plot")
click(ns("gb_axes"))
app$wait_for_js("!!document.getElementById('overview_1-gbax_ymin')", timeout = 15000)
app$set_inputs(`overview_1-gbax_ymin` = 0, `overview_1-gbax_ymax` = 50); Sys.sleep(.5)
click("overview_1-gbax_apply"); Sys.sleep(1)
ok(grepl("Axes (set)", txt(sprintf("#%s", ns("gb_axes"))), fixed = TRUE), paste("axes set:", txt(sprintf("#%s", ns("gb_axes")))))
tw_shot(app, "ov_gb_axes")

# ---- dark mode
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1.5)
tw_shot(app, "ov_gb_dark")
section("Table builder"); tw_shot(app, "ov_table_dark")
section("Vulnerability"); tw_shot(app, "ov_vuln_dark")
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1)
e <- real_errors()
ok(!length(e), paste("browser errors:", paste(head(e, 3), collapse = " | ")))
