# Browser check: the Location names chart's three views (similar names,
# sunburst, variant bars) and a click on a group selecting it in the table.
#   NOT_CRAN=true Rscript react/dev/test_location_views.R      (from the package root)
source("react/dev/e2e.R")
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
# the demo data with misspelt villages
d <- data.table::fread(file.path(tw_root, "inst/extdata/registration_demo.csv"))
d$Village[which(d$Village == "Village_04")[1:6]] <- "Vilage_04"
d$Village[which(d$Village == "Village_04")[1:3]] <- "Village_O4x"
d$Village[which(d$Village == "Village_09")[1:4]] <- "Villge_09"
f <- tempfile(fileext = ".csv"); data.table::fwrite(d, f)

app <- tw_launch()
js <- function(x) app$get_js(x)
wait <- function(s = 1) { Sys.sleep(s); tw_idle(app); Sys.sleep(.6) }
setr <- function(id, value) app$run_js(sprintf("(function(){var el=document.getElementById('%s');$(el).data('shiny-input-binding').receiveMessage(el,{value:%s});})()", id, jsonlite::toJSON(value, auto_unbox = TRUE)))
view <- function(lbl) app$run_js(sprintf("[...document.querySelectorAll('#dq_1-loc_view__ctl button, [id^=\"dq_1-loc_view\"] button')].find(b=>b.textContent.includes('%s')).click()", lbl))
drawn <- function() js("document.querySelectorAll('#dq_1-dq_location_view canvas').length") >= 1
note <- function() js("(document.querySelector('#dq_1-dq_location_view.tw-output-note')||{}).textContent||''")
tw_load_registration(app, f)
tw_go(app, "dq_panel")
app$run_js("[...document.querySelectorAll('.tw-tabs-nav button')].find(b=>b.textContent.includes('Location names')).click()"); wait()
setr("dq_1-norm_col", "Village"); wait(.5)
app$run_js("document.getElementById('dq_1-norm_show').click()"); wait(3)
ok(drawn() && !nzchar(note()), paste("similar names network drawn", note()))
tw_shot(app, "loc_network")
view("Sunburst"); wait(2)
ok(drawn() && grepl("rings", js("[...document.querySelectorAll('.tw-dq-note')].map(e=>e.textContent).join(' ')")), "sunburst drawn, its note shown")
tw_shot(app, "loc_sunburst")
view("Variant bars"); wait(2)
ok(drawn(), "variant bars drawn")
tw_shot(app, "loc_bars")
# a click on the first bar (the biggest group): canvas point inside its band
app$run_js("(function(){var c=document.querySelector('#dq_1-dq_location_view canvas'); var r=c.getBoundingClientRect();
  var x=r.left+r.width*0.45, y=r.top+30+(r.height-38)/4;
  ['mousemove','mousedown','mouseup','click'].forEach(function(t){c.dispatchEvent(new MouseEvent(t,{clientX:x,clientY:y,bubbles:true}));});})()")
wait(2)
chips <- js("[...document.querySelectorAll('.tw-dq-norm-sel .tw-dq-chip')].map(e=>e.firstChild.textContent).join(',')")
ok(grepl("Village_04", chips) && grepl("Vilage_04", chips), paste("the click selects the group:", chips))
ok(identical(js("document.getElementById('dq_1-correct_name__ctl').value"), "Village_04"), "most common spelling suggested")
tw_shot(app, "loc_bars_click")
top <- js("[...document.querySelectorAll('#dq_1-tab_location_norm tbody tr')].slice(0,2).map(r=>r.classList.contains('tw-dt-selected')).join(',')")
ok(identical(top, "true,true"), paste("the selected rows are on top:", top))
# the cross on a chip takes that name out of the selection
app$run_js("[...document.querySelectorAll('.tw-dq-norm-sel .tw-dq-chip')].find(e=>e.firstChild.textContent==='Vilage_04').querySelector('.tw-dq-chip-x').click()"); wait(2)
chips <- js("[...document.querySelectorAll('.tw-dq-norm-sel .tw-dq-chip')].map(e=>e.firstChild.textContent).join(',')")
ok(identical(chips, "Village_04"), paste("the cross removes Vilage_04:", chips))
tw_shot(app, "loc_chip_removed")
# a stricter similarity: Vilage_04 (90% alike) no longer counts as a variant
setr("dq_1-loc_similarity", 95); wait(2)
ok(grepl("No look-alike", note()), paste("95% similarity: no groups", note()))
setr("dq_1-loc_similarity", 80); wait(2)
ok(drawn() && !nzchar(note()), "80% again: groups back")
cat("errors:", tw_errors(app), "\n")
app$stop()
