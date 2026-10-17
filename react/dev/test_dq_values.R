# Browser check of Data Quality > Category values (react/src/pages/dq/ValuesTab.tsx).
# From the package root, after `cd react && npm run build`:
#   NOT_CRAN=true Rscript react/dev/test_dq_values.R
# Prints PASS / FAIL lines; screenshots go to TW_SHOTS (or tempdir()).
source("react/dev/e2e.R")
app <- tw_launch()
on.exit(app$stop())
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
js <- function(x) tw_js(app, x)
click <- function(id) { app$run_js(sprintf("document.getElementById('%s').click()", id)); Sys.sleep(1); tw_idle(app) }
txt <- function(sel) js(sprintf("(document.querySelector(%s)||{}).textContent||''", jsonlite::toJSON(sel, auto_unbox = TRUE)))
set <- function(...) { app$set_inputs(..., allow_no_input_binding_ = TRUE); Sys.sleep(1); tw_idle(app) }
# a React input takes a value as from the server's update*Input() (its hidden binding)
setr <- function(id, value) {
  app$run_js(sprintf("(function(){var el=document.getElementById('%s');$(el).data('shiny-input-binding').receiveMessage(el,{value:%s});})()",
                     id, jsonlite::toJSON(value, auto_unbox = length(value) == 1 && !is.list(value))))
  Sys.sleep(1); tw_idle(app)
}
modal_click <- function(id) { app$wait_for_js(sprintf("!!document.getElementById('%s')", id), timeout = 30000); Sys.sleep(.5); click(id); Sys.sleep(3); tw_idle(app) }
rows_in <- function(id) js(sprintf("document.querySelectorAll('#%s tbody tr:not(.tw-dt-group)').length", id))
audit_n <- function() js("(function(){var t=document.querySelector('#audit_1-tab_mod_log .tw-dt-foot span');return t?t.textContent:'';})()")
tab <- function(v) setr("dq_1-dq_tabs", v)
# the navbar's links (setting input$main_nav alone does not move the React shell)
nav <- function(label) {
  app$run_js(sprintf("(function(){var a=Array.from(document.querySelectorAll('.tw-navbar a')).find(e=>e.textContent.trim()===%s);if(a)a.click();})()",
                     jsonlite::toJSON(label, auto_unbox = TRUE)))
  Sys.sleep(1.5); tw_idle(app)
}
go_dq <- function() nav("Data Quality")
go_audit <- function() nav("Activity Log")

tw_go(app, "import_panel")
try(app$wait_for_js("!!document.querySelector('#file_import_1-file_in.shiny-bound-input')", timeout = 60000))
# the demo registration data with the sex typed several ways
d <- utils::read.csv(file.path(tw_root, "inst/extdata/registration_demo.csv"), stringsAsFactors = FALSE)
set.seed(1); k <- sample(nrow(d), 120); d$HHHSex[k] <- tolower(d$HHHSex[k]); d$HHHSex[k[1:20]] <- paste0(" ", toupper(d$HHHSex[k[1:20]]), " ")
k2 <- sample(nrow(d), 80); d$HHStatus[k2] <- tolower(d$HHStatus[k2])
# a yes / no answer with some codes typed as numbers: text and numbers mixed
d$HasPhone <- sample(c("Yes", "No"), nrow(d), TRUE); d$HasPhone[sample(nrow(d), 30)] <- sample(c("1", "0"), 30, TRUE)
dat <- file.path(tempdir(), "reg_values.csv"); utils::write.csv(d, dat, row.names = FALSE)
tw_load_registration(app, dat)
go_dq()
tab("Category values")
app$wait_for_js("document.querySelectorAll('.tw-val-var').length > 0", timeout = 60000)
cards <- js("Array.from(document.querySelectorAll('.tw-val-var')).map(e => e.querySelector('.tw-val-var-name').textContent + ':' + ((e.querySelector('.tw-val-chip')||{}).textContent||'')).join(' | ')")
ok(grepl("HHHSex:[0-9]+ to merge", cards) && grepl("HHStatus:[0-9]+ to merge", cards), paste("variable cards:", substr(cards, 1, 200)))
ring <- txt(".tw-val-ring")
ok(grepl("%", ring), paste("consistency ring:", ring))
app$run_js("Array.from(document.querySelectorAll('.tw-val-var')).find(e => e.textContent.startsWith('HasPhone')).click()"); Sys.sleep(1)
ok(grepl("Text and numbers are mixed", txt(".tw-val-detail")) && !grepl("Text + numbers", js("Array.from(document.querySelectorAll('.tw-val-var')).map(e => e.textContent).join('|')"), fixed = TRUE),
   "text mixed with numbers: told in the correction panel, no badge on the variable")
codes <- js("Array.from(document.querySelectorAll('.tw-val-group')).map(g => g.querySelector('input.form-control').value + ' <- ' + Array.from(g.querySelectorAll('.tw-val-vchip.code')).map(c => c.querySelector('span').textContent).join(',')).join(' | ')")
ok(grepl("Yes <- 1", codes) && grepl("No <- 0", codes), paste("codes suggested as the text they stand for:", codes))
tw_shot(app, "dq_values_codes")
ok(js("new Set(Array.from(document.querySelector('.tw-val-var .tw-val-bar').children).map(e => e.style.background.slice(0, 22))).size") > 1, "each answer has its own colour")
# the variable with most to fix opens first; pick HHHSex
app$run_js("Array.from(document.querySelectorAll('.tw-val-var')).find(e => e.textContent.startsWith('HHHSex')).click()"); Sys.sleep(1)
ng <- js("document.querySelectorAll('.tw-val-group').length")
ok(ng >= 2, paste("group cards:", ng))
ok(js("document.querySelectorAll('.tw-val-group mark.soft').length") > 0, "case differences are highlighted")
ok(grepl("Nothing applied yet", txt(".tw-val-hist-panel")), "the changes panel sits beside the corrections")
w <- js("Array.from(document.querySelector('.tw-val-main').children).map(e => Math.round(e.getBoundingClientRect().width)).join(',')")
ok(length(strsplit(w, ",")[[1]]) == 3, paste("three panels, widths:", w))
tw_shot(app, "dq_values")
app$run_js("Array.from(document.querySelectorAll('.tw-val-detail-head button')).find(b => b.textContent.includes('Apply this variable')).click()"); Sys.sleep(1)
modal_click("dq_1-val_confirm")
app$wait_for_js("!!document.querySelector('.tw-val-hist')", timeout = 30000)
h <- txt(".tw-val-hist")
ok(grepl("HHHSex", h) && grepl("6[[:space:]]*→[[:space:]]*2[[:space:]]*distinct values", h), paste("before / after:", h))
cards2 <- js("Array.from(document.querySelectorAll('.tw-val-var')).map(e => e.querySelector('.tw-val-var-name').textContent + ':' + ((e.querySelector('.tw-val-chip')||{}).textContent||'')).join(' | ')")
ok(grepl("HHHSex:Clean", cards2), paste("HHHSex now clean:", substr(cards2, 1, 160)))
# mark a variable clean: kept as it is, out of the figures; then undo
app$run_js("Array.from(document.querySelectorAll('.tw-val-var')).find(e => e.textContent.startsWith('HHStatus')).click()"); Sys.sleep(.5)
before <- txt(".tw-val-figs")
app$run_js("Array.from(document.querySelectorAll('.tw-val-detail-head button')).find(b => b.textContent.includes('Mark as clean')).click()"); Sys.sleep(2); tw_idle(app)
cards3 <- js("Array.from(document.querySelectorAll('.tw-val-var')).map(e => e.querySelector('.tw-val-var-name').textContent + ':' + ((e.querySelector('.tw-val-chip')||{}).textContent||'')).join(' | ')")
ok(grepl("HHStatus:Kept as is", cards3) && grepl("Marked as clean", txt(".tw-val-detail")), paste("marked clean:", substr(cards3, 1, 120)))
app$run_js("Array.from(document.querySelectorAll('.tw-val-detail-head button')).find(b => b.textContent.includes('Undo')).click()"); Sys.sleep(2); tw_idle(app)
ok(!grepl("Kept as is", js("Array.from(document.querySelectorAll('.tw-val-var')).map(e => e.textContent).join('|')")), "undo brings it back")
# an edited target goes through Apply all ticked
app$run_js("Array.from(document.querySelectorAll('.tw-val-var')).find(e => e.textContent.startsWith('HHStatus')).click()"); Sys.sleep(1)
app$run_js("(function(){var g=Array.from(document.querySelectorAll('.tw-val-group')).find(x=>x.querySelector('input.form-control').value==='Resident'); var i=g.querySelector('input.form-control'); var set=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; set.call(i,'Resident (host)'); i.dispatchEvent(new Event('input',{bubbles:true}));})()"); Sys.sleep(1)
app$run_js("Array.from(document.querySelectorAll('.tw-val-head-go button')).find(b => b.textContent.includes('Apply all ticked')).click()"); Sys.sleep(1)
modal_click("dq_1-val_confirm")
# a merge by hand: two answers become one
app$run_js("Array.from(document.querySelectorAll('.tw-val-manual .tw-val-vchip')).slice(0, 2).forEach(b => b.click())"); Sys.sleep(.5)
app$run_js("(function(){var i=document.querySelector('.tw-val-manual-go input'); var set=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; set.call(i,'Merged by hand'); i.dispatchEvent(new Event('input',{bubbles:true}));})()"); Sys.sleep(.5)
app$run_js("document.querySelector('.tw-val-manual-go button').click()"); Sys.sleep(1)
modal_click("dq_1-val_confirm")
tw_shot(app, "dq_values_after")
go_audit()
au <- txt("#audit_1-tab_mod_log")
ok(grepl("Category values harmonised", au), "activity log records the changes")
ok(grepl("Resident (host)", au, fixed = TRUE), "the edited target was applied")
ok(grepl("Merged by hand", au, fixed = TRUE), "the merge by hand was applied")
go_dq(); tab("Category values"); Sys.sleep(1)
ok(grepl("5[[:space:]]*→[[:space:]]*4[[:space:]]*distinct values", txt(".tw-val-hist")), paste("two answers merged by hand: one fewer value:", txt(".tw-val-hist")))
# ---- audit trail: insights, and undo of the changes made in this session
go_audit(); Sys.sleep(1.5); tw_idle(app)
ok(grepl("Changes you can undo", txt(".tw-audit-tiles")), paste("audit insights:", substr(txt(".tw-audit-tiles"), 1, 160)))
nb <- js("document.querySelectorAll('#audit_1-tab_mod_log .tw-undo-btn').length")
ok(nb == 3, paste("an Undo button per data change of this session:", nb))
tw_shot(app, "audit_undo")
app$run_js("Array.from(document.querySelectorAll('#audit_1-tab_mod_log .tw-undo-btn')).pop().click()"); Sys.sleep(1.5)
ok(grepl("2 later changes", js("(document.querySelector('.modal.show')||{}).textContent||''")), "the dialog says the later changes go too")
modal_click("audit_1-undo_ok")
ok(js("document.querySelectorAll('#audit_1-tab_mod_log .tw-undo-btn').length") == 0, "nothing left to undo")
ok(grepl("Change undone", txt("#audit_1-tab_mod_log")), "the undo is logged")
go_dq(); tab("Category values"); Sys.sleep(2); tw_idle(app)
cards4 <- js("Array.from(document.querySelectorAll('.tw-val-var')).map(e => e.querySelector('.tw-val-var-name').textContent + ':' + ((e.querySelector('.tw-val-chip')||{}).textContent||'')).join(' | ')")
ok(grepl("HHHSex:[0-9]+ to merge", cards4), paste("the data is back as before:", substr(cards4, 1, 120)))
err <- grep("^Error for ", tw_errors(app), value = TRUE, invert = TRUE)
ok(!length(err), paste("browser errors:", paste(err, collapse = " || ")))
