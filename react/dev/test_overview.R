# Browser check of the React Overview (react/src/pages/overview/): the map
# (MapLibre + deck.gl), ECharts charts, the table and chart builders.
# From the package root, after `cd react && npm run build`:
#   NOT_CRAN=true Rscript react/dev/test_overview.R
# With TW_BIG=<a registration file> (e.g. 1.5 million rows, registration_demo
# columns), only the map is checked, with timings.
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

big <- Sys.getenv("TW_BIG")
tw_go(app, "import_panel")
try(app$wait_for_js("!!document.querySelector('#file_import_1-file_in.shiny-bound-input')", timeout = 60000))
# time from the mapping confirmed (data loaded) to the points drawn, in the browser
app$run_js("window.__t0=null; window.__tDrawn=null; document.addEventListener('click', function(e){ if (e.target.closest && e.target.closest('#setup_1-review_confirm')) window.__t0=performance.now(); }, true); (function poll(){var h=document.querySelector('.tw-map-holder'); if(h && +h.dataset.points>0 && window.__t0){window.__tDrawn=performance.now()-window.__t0;} else setTimeout(poll,20);})();")
t_load <- system.time(if (nzchar(big)) tw_load_registration(app, big) else tw_load_registration(app))[["elapsed"]]
go("Overview")
ok(js("document.querySelector('.tw-rov').offsetWidth > 0"), "the Overview shows")

# ---- The map (MapLibre basemap, deck.gl points)
M <- "document.querySelector('.tw-map-gl').twMap"
try(app$wait_for_js("+document.querySelector('.tw-map-holder').dataset.points > 0", timeout = 300000))
n_pts <- js("+document.querySelector('.tw-map-holder').dataset.points")
cat(sprintf("TIME import + setup (test driver) %.1fs; mapping confirmed -> points drawn %.2fs
", t_load, js("window.__tDrawn || NaN") / 1000))
ok(n_pts > 1000, paste("map points drawn:", n_pts))
ok(js("document.querySelectorAll('.tw-map-gl canvas').length >= 2 && !!document.querySelector('.tw-map-gl .maplibregl-canvas')"), "MapLibre and deck.gl canvases")
ok(nzchar(txt(".tw-map-legend")), paste("legend:", substr(txt(".tw-map-legend"), 1, 80)))
tw_shot(app, "ov_map")
view <- function() js(sprintf("(function(){var m=%s.map, c=m.getCenter(); return [c.lng, c.lat, m.getZoom()].map(v=>+v.toFixed(5)).join(',')})()", M))
sel_map <- function(sel, v) {
  app$run_js(sprintf("var s=document.querySelector('%s'); Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype,'value').set.call(s,'%s'); s.dispatchEvent(new Event('change',{bubbles:true}))", sel, v))
  Sys.sleep(2); tw_idle(app)
}
# zoom in a little, then recolour: the view stays
app$run_js(sprintf("%s.map.jumpTo({zoom: %s.map.getZoom() + 1})", M, M)); Sys.sleep(1.5); tw_idle(app)
v0 <- view(); lg0 <- txt(".tw-map-legend")
sel_map(".tw-rov-map .wfp-map-toolbar select", "HHHSex")
ok(grepl("HHHSex", txt(".tw-map-legend")) && !identical(lg0, txt(".tw-map-legend")), paste("recoloured:", substr(txt(".tw-map-legend"), 1, 60)))
ok(identical(view(), v0), paste("recolour keeps the view:", v0, "->", view()))
sel_map(".tw-rov-map .wfp-map-toolbar select", "Scoring_total")
ok(js("!!document.querySelector('.tw-map-ramp')"), "a number: colour ramp legend")
tw_shot(app, "ov_map_numeric")
# a click on a point: the server's popup
pt <- js(sprintf("(function(){var t=%s, r=t.map.getCanvas().getBoundingClientRect(), best=null, bd=1e9; for (var i=0;i<Math.min(3000,t.n);i++){var p=t.screen(i); if(!p) continue; var d=Math.hypot(p.x-(r.left+r.width/2),p.y-(r.top+r.height/2)); if(d<bd){bd=d;best=p;}} return best})()", M))
cdp <- app$get_chromote_session()
for (ty in c("mouseMoved", "mousePressed", "mouseReleased"))
  cdp$Input$dispatchMouseEvent(type = ty, x = pt$x, y = pt$y, button = "left", clickCount = if (ty == "mouseMoved") 0 else 1)
try(app$wait_for_js("!!document.querySelector('.maplibregl-popup .wfp-map-pop')", timeout = 15000))
ok(grepl("reg:", txt(".maplibregl-popup .wfp-map-pop")), paste("popup on click:", txt(".maplibregl-popup .wfp-map-pop")))
tw_shot(app, "ov_map_popup")
# follow the map: zoomed in, the figures describe the households in view
app$run_js("document.querySelector('.tw-ov-follow input').click()"); Sys.sleep(1)
app$run_js(sprintf("%s.map.jumpTo({zoom: %s.map.getZoom() + 2})", M, M)); Sys.sleep(3); tw_idle(app)
chip <- txt(".tw-ov-chip")
ok(grepl("Map view:", chip), paste("follow the map:", chip))
tw_shot(app, "ov_map_follow")
app$run_js("document.querySelector('.tw-ov-chip a').click()"); Sys.sleep(3); tw_idle(app)
ok(grepl("^All", trimws(txt(".tw-ov-chip"))), paste("show all:", txt(".tw-ov-chip")))
# basemaps
src <- function() js(sprintf("%s.map.getStyle().sources.b0.tiles[0]", M))
sel_map(".tw-map-base", "Satellite"); Sys.sleep(2)
ok(grepl("World_Imagery", src()), paste("basemap switch:", src()))
tw_shot(app, "ov_map_satellite")
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(3)
ok(grepl("Dark_Gray", src()), paste("dark mode, dark basemap:", src()))
tw_shot(app, "ov_map_dark")
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(2)
ok(grepl("World_Imagery", src()), paste("light again: back to the chosen basemap:", src()))
sel_map(".tw-map-base", "Terrain")
# responsiveness: frames per second while panning and zooming (3 s)
app$run_js(sprintf("window.__fps=null; (function(){var m=%s.map, frames=0, t0=performance.now(), worst=0, last=t0; function f(){var t=performance.now(); worst=Math.max(worst,t-last); last=t; frames++; if(t-t0<3000) requestAnimationFrame(f); else window.__fps=[frames/((t-t0)/1000), worst];} requestAnimationFrame(f); m.panBy([300,0],{duration:1000}); setTimeout(()=>m.panBy([-300,150],{duration:1000}),1000); setTimeout(()=>m.zoomIn({duration:800}),2000);})()", M))
Sys.sleep(4)
fps <- js("window.__fps")
cat(sprintf("PAN %.0f frames/s, longest frame %.0f ms (headless Chrome)
", fps[[1]], fps[[2]]))
if (nzchar(big)) {
  e <- real_errors()
  ok(!length(e), paste("browser errors:", paste(head(e, 3), collapse = " | ")))
  quit(save = "no")
}
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
