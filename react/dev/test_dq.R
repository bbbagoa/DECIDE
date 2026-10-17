# Browser check of the React Data Quality page (react/src/pages/dq/).
# From the package root, after `cd react && npm run build`:
#   NOT_CRAN=true Rscript react/dev/test_dq.R
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
# the demo registration data plus an enumerator, interview start / end times and
# 5 records registered twice (react/dev/test_dq_data.R writes it), so every tab has work
dat <- file.path(tempdir(), "reg_enum.csv")
source("react/dev/test_dq_data.R"); write_dq_test_data(dat)
tw_load_registration(app, dat)
go_dq()
ok(js("!!document.querySelector('.tw-dq')"), "the React page is drawn")
ok(grepl("1,505", txt("#dq_1-dq_filtered_rows")), paste("filtered rows:", txt("#dq_1-dq_filtered_rows")))
tw_shot(app, "dq_health_empty")

# ---- health check: runs by itself on light data, Review switches tabs
try(app$wait_for_js("document.querySelectorAll('.tw-hc-row').length > 0", timeout = 30000), silent = TRUE)
n_hc <- js("document.querySelectorAll('.tw-hc-row').length")
ok(n_hc == 6, paste("health check ran by itself, rows:", n_hc))
ok(!js("!!document.getElementById('dq_1-hc_run')"), "no Run button on light data")
ok(grepl("Checked automatically", txt(".tw-hc-side")) && grepl("Answers filled in", txt(".tw-hc-side")), paste("side panel:", substr(txt(".tw-hc-side"), 1, 160)))
Sys.sleep(2); tw_idle(app)
ok(js("document.querySelectorAll('#dq_1-hc_missing_plot canvas, #dq_1-hc_area_plot canvas, #dq_1-hc_daily_plot canvas').length") >= 3, "three quick charts")
tw_shot(app, "dq_health")
app$run_js("Array.from(document.querySelectorAll('.tw-hc-row')).find(r=>r.textContent.includes('Outliers')).querySelector('button').click()")
Sys.sleep(1.5); tw_idle(app)
ok(identical(app$get_value(input = "dq_1-dq_tabs"), "Outliers"), "Review opens the Outliers tab")
ok(js("Array.from(document.querySelectorAll('.tw-dq .tw-tabs-nav .nav-link.active')).map(e=>e.textContent).join('|')") == "Outliers" ||
   grepl("Outliers", js("document.querySelector('.tw-dq .tw-tabs-nav .nav-link.active').textContent")), "the Outliers tab shows")

# ---- filters
setr("dq_1-dq_filter_adm1", list("Ituri"))
click("dq_1-btn_apply_dq_filters")
f1 <- txt("#dq_1-dq_filtered_rows")
ok(!grepl("1,505", f1) && grepl("filtered", f1), paste("Apply filters:", f1))
click("dq_1-btn_clear_dq_filters")
ok(grepl("1,505", txt("#dq_1-dq_filtered_rows")), "Clear filters")

# ---- outliers: check, charts, correction with preview
setr("dq_1-outlier_var", "HHHAge")
Sys.sleep(1); tw_idle(app)
ok(grepl("range", txt(".tw-dq-hint")), paste("range hint:", txt(".tw-dq-hint")))
setr("dq_1-range_max", 80)   # an allowed range that flags the oldest heads
Sys.sleep(2); tw_idle(app)   # no Check button: the tab redraws as the settings change
ok(nzchar(txt("#dq_1-outlier_total")), paste("outliers checked:", txt("#dq_1-outlier_total"), "flagged:", txt("#dq_1-outlier_count")))
ch <- js("document.querySelectorAll('#dq_1-plot_outlier_hist canvas, #dq_1-plot_outlier_box canvas').length")
ok(ch >= 2, paste("distribution charts:", ch))
tw_shot(app, "dq_outliers")
setr("dq_1-outlier_tabs", "where"); tw_shot(app, "dq_outliers_where")
setr("dq_1-range_min", 90); Sys.sleep(1); tw_idle(app)
ok(grepl("above the maximum", txt(".tw-dq-hint")), paste("inverted range hint:", txt(".tw-dq-hint")))
setr("dq_1-range_min", ""); Sys.sleep(1.5); tw_idle(app)
setr("dq_1-outlier_tabs", "flagged"); Sys.sleep(1.5); tw_idle(app)
ok(rows_in("dq_1-ol_table") > 0, paste("flagged table rows:", rows_in("dq_1-ol_table")))
n_ins <- js("document.querySelectorAll('.tw-dq-ol-insights .tw-dq-insight').length")
ok(n_ins >= 2, paste("outlier insight cards:", n_ins, js("Array.from(document.querySelectorAll('.tw-dq-ol-insights .tw-dq-insight-label')).map(e=>e.textContent).join(' | ')")))

tw_shot(app, "dq_outliers_flagged")
a0 <- NULL
go_audit(); a0 <- audit_n(); go_dq()
setr("dq_1-outlier_correction_method", "cap")
click("dq_1-btn_apply_outlier_correction")
Sys.sleep(1)
ok(js("!!document.querySelector('.modal.show')") && grepl("Before", js("document.querySelector('.modal.show').textContent")), "correction preview opens")
tw_shot(app, "dq_outliers_preview")
modal_click("dq_1-btn_confirm_outlier_correction")
go_audit(); a1 <- audit_n(); tw_shot(app, "dq_audit_after_outliers"); go_dq()
ok(!identical(a0, a1), paste("audit after outlier correction:", a0, "->", a1))
setr("dq_1-outlier_tabs", "all"); Sys.sleep(.5)
scan_empty <- function() js("Array.from(document.querySelectorAll('.wfp-empty')).some(e=>e.offsetParent && e.textContent.includes('Audit all numeric'))")
ok(scan_empty(), "numeric audit empty state")
click("dq_1-ol_scan")
ok(!scan_empty(), "empty state gone after the audit")
ok(rows_in("dq_1-ol_scan_table") > 0, paste("numeric audit rows:", rows_in("dq_1-ol_scan_table")))
tw_shot(app, "dq_outliers_all")
# HHSize holds a "99" code (test data): its card's "Select them" link selects those rows (input$ol_pick)
setr("dq_1-outlier_var", "HHSize"); setr("dq_1-outlier_tabs", "flagged"); Sys.sleep(2); tw_idle(app)
labs <- js("Array.from(document.querySelectorAll('.tw-dq-ol-insights .tw-dq-insight-label')).map(e=>e.textContent).join(' | ')")
ok(grepl("Looks like a code", labs), paste("HHSize insights:", labs))
app$run_js("Array.from(document.querySelectorAll('.tw-dq-insight-pick')).pop().click()"); Sys.sleep(2); tw_idle(app)
ok(grepl("^6 selected", txt("#dq_1-ol_selected_n")), paste("Select link:", txt("#dq_1-ol_selected_n")))
tw_shot(app, "dq_outliers_insights")
click("dq_1-ol_select_none")

# ---- spelling: check names, edit one record
tab("Spelling & Integrity")
ok(grepl("Pick the name columns", txt(".tw-dq-names-empty")), "spelling: pick-columns state")
setr("dq_1-dq_name_cols", c("Village", "Airedesante"))
click("dq_1-dq_names_check")
# wait for the result (flagged rows, or the empty state), not a fixed second
try(app$wait_for_js("document.querySelectorAll('#dq_1-dq_names_redflags tbody tr').length > 0 || /No suspicious/.test((document.querySelector('.tw-dq-names-empty')||{}).textContent||'')", timeout = 30000), silent = TRUE)
n_bad <- rows_in("dq_1-dq_names_redflags")
cat("spelling: flagged rows", n_bad, "metric", txt(".tw-dq-metric"), "\n")
tw_shot(app, "dq_spelling")
if (n_bad > 0) {
  app$run_js("document.querySelector('#dq_1-dq_names_redflags tbody tr').click()"); Sys.sleep(1); tw_idle(app)
  click("dq_1-btn_open_edit")
  ok(js("!!document.querySelector('.modal.show')"), "edit dialog opens")
  app$wait_for_js("!!document.getElementById('dq_1-edit_Village')", timeout = 30000)
  app$set_inputs(`dq_1-edit_Village` = "Village_fixed"); Sys.sleep(.5)
  modal_click("dq_1-btn_save_dq")
  go_audit(); a2 <- audit_n(); go_dq()
  ok(!identical(a1, a2), paste("audit after name edit:", a1, "->", a2))
  # several records selected, deleted at once with a reason
  tab("Spelling & Integrity"); Sys.sleep(1)
  mcount <- function() as.numeric(gsub(",", "", js("document.querySelector('.tw-dq-metric-value').firstChild.textContent")))
  b1 <- rows_in("dq_1-dq_names_redflags"); m1 <- mcount()
  app$run_js("Array.from(document.querySelectorAll('#dq_1-dq_names_redflags tbody tr')).slice(0, 2).forEach(r => (r.querySelector('input[type=checkbox]') || r).click())"); Sys.sleep(1); tw_idle(app)
  ok(grepl("Delete selected (2)", txt("#dq_1-btn_delete_selected"), fixed = TRUE), paste("delete button counts the selection:", txt("#dq_1-btn_delete_selected")))
  click("dq_1-btn_delete_selected")
  app$wait_for_js("!!document.getElementById('dq_1-reason_delete_selected')", timeout = 20000)
  app$set_inputs(`dq_1-reason_delete_selected` = "Test records"); Sys.sleep(.5)
  modal_click("dq_1-btn_confirm_delete_selected")
  m2 <- mcount()
  ok(m1 - m2 == 2, paste("two records deleted:", m1, "->", m2))
} else {
  # nothing flagged: the empty state says so
  ok(grepl("No suspicious", txt(".tw-dq-names-empty")), "spelling empty state")
  a2 <- a1
}

# ---- location names: show, select, merge
tab("Location names normalization")
ok(js("Array.from(document.querySelectorAll('.wfp-empty')).some(e=>e.offsetParent && e.textContent.includes('Choose a level'))"), "location: choose-a-level state")
ok(grepl("Click the rows", txt(".tw-dq-norm-sel")), "location: selection hint")
setr("dq_1-norm_col", "Admin 2")
click("dq_1-norm_show")
ok(rows_in("dq_1-tab_location_norm") > 0, paste("location rows:", rows_in("dq_1-tab_location_norm")))
ok(js("document.querySelectorAll('#dq_1-dq_location_view canvas').length") >= 1 || grepl("No look-alike", txt("#dq_1-dq_location_view")), "location chart drawn (or no look-alikes said)")
app$run_js("var r=document.querySelectorAll('#dq_1-tab_location_norm tbody tr'); r[0].click(); r[1].click();"); Sys.sleep(1.5); tw_idle(app)
nchips <- js("document.querySelectorAll('.tw-dq-norm-sel .tw-dq-chip').length")
ok(nchips >= 1, paste("location selection chips:", nchips, txt(".tw-dq-norm-sel")))
ok(nzchar(js("document.getElementById('dq_1-correct_name__ctl').value")), paste("suggested spelling:", js("document.getElementById('dq_1-correct_name__ctl').value")))
tw_shot(app, "dq_location")

# ---- missing data
tab("Missing Data Checking")
ok(js("Array.from(document.querySelectorAll('.wfp-empty')).some(e=>e.offsetParent && e.textContent.includes('No missing-data check'))"), "missing: empty state")
setr("dq_1-mandatory_vars", c("HHHSex", "HHHAge", "HHSize", "HHStatus", "HHSize24M", "Scoring_total"))
click("dq_1-btn_apply_missing")
Sys.sleep(1)
ok(js("document.querySelectorAll('#dq_1-plot_field_completeness canvas').length") >= 1, "completeness chart")
kv <- js("Array.from(document.querySelectorAll('.tw-dq-kpi-value')).filter(e=>e.offsetParent).map(e=>e.textContent).join(' ')")
ok(grepl("%", kv), paste("missing figures:", kv))
ok(rows_in("dq_1-tab_col_health") == 6, paste("column health rows:", rows_in("dq_1-tab_col_health")))
tw_shot(app, "dq_missing")
app$run_js("Array.from(document.querySelectorAll('.tw-dq .tw-tab-panel .nav-link')).find(b=>b.textContent.includes('Patterns')).click()"); Sys.sleep(1.5)
tw_shot(app, "dq_missing_patterns")
app$run_js("Array.from(document.querySelectorAll('.tw-dq .tw-tab-panel .nav-link')).find(b=>b.textContent.includes('By location')).click()"); Sys.sleep(1.5)
tw_shot(app, "dq_missing_location")

# ---- duplicates: find, select, delete
tab("Duplicates")
ok(js("Array.from(document.querySelectorAll('.wfp-empty')).some(e=>e.offsetParent && e.textContent.includes('No duplicate analysis'))"), "duplicates: empty state")
setr("dq_1-duplicate_vars", c("Province", "Territoire", "HHHSex", "HHSize"))
click("dq_1-btn_refresh_duplicates"); Sys.sleep(3); tw_idle(app)
nd <- rows_in("dq_1-dq_duplicate_table")
ok(nd > 0, paste("duplicate rows on the page:", nd, "groups:", txt("#dq_1-dup_groups")))
tw_shot(app, "dq_duplicates")
click("dq_1-dup_sel_extra")
ok(grepl("selected", txt("#dq_1-dup_selected_n")), paste("selection:", txt("#dq_1-dup_selected_n")))
click("dq_1-dup_delete")
modal_click("dq_1-dup_delete_ok")
go_audit(); a3 <- audit_n(); go_dq()
ok(!identical(a2, a3), paste("audit after duplicate deletion:", a2, "->", a3))
ok(!grepl("1,505", txt("#dq_1-dq_filtered_rows")), paste("records left:", txt("#dq_1-dq_filtered_rows")))

# ---- enumerators
tab("Enumerator Performance"); Sys.sleep(2)
ok(nzchar(txt("#dq_1-enum_active")), paste("active enumerators:", txt("#dq_1-enum_active"), "flagged:", txt("#dq_1-enum_flagged")))
ok(grepl("enum_03", js("Array.from(document.querySelectorAll('.tw-dq-enum-card')).map(e=>e.textContent).join('|')")), "the fast enumerator is flagged")
ok(grepl("IQR fences", txt(".tw-dq-rules")), paste("rules:", txt(".tw-dq-rules")))
app$run_js("Array.from(document.querySelectorAll('.tw-dq-enum-card')).find(e=>e.textContent.includes('enum_03')).querySelector('button').click()")
Sys.sleep(2); tw_idle(app)
try(app$wait_for_js("document.querySelectorAll('.tw-dialog-backdrop #dq_1-enum_recs tbody tr').length > 0", timeout = 20000), silent = TRUE)
cat("dialogs open:", js("document.querySelectorAll('.tw-dialog-backdrop').length"), "
")
ok(grepl("enum_03", js("Array.from(document.querySelectorAll('.tw-dialog-backdrop')).map(e => e.textContent).join(' | ')")) &&
   js("document.querySelectorAll('.tw-dialog-backdrop #dq_1-enum_recs tbody tr').length") > 0, "See their interviews opens the React dialog with its table")
tw_shot(app, "dq_enum_interviews")
app$run_js("document.dispatchEvent(new KeyboardEvent('keydown', {key: 'Escape'}))"); Sys.sleep(1)
ok(!grepl("enum_03", js("Array.from(document.querySelectorAll('.tw-dialog-backdrop')).map(e => e.textContent).join(' | ')")), "Escape closes it")
tw_shot(app, "dq_enumerators")
app$run_js("Array.from(document.querySelectorAll('.tw-dq .tw-tab-panel .nav-link')).find(b=>b.textContent.includes('Workload')).click()"); Sys.sleep(2)
n_sp <- js("Array.from(document.querySelectorAll('.tw-dq-insight-label')).filter(e=>e.offsetParent).map(e=>e.textContent).join('|')")
ok(grepl("Workload balance", n_sp), paste("workload insights:", n_sp))
ok(js("document.querySelectorAll('#dq_1-enum_interviews_plot canvas, #dq_1-enum_duration_plot canvas, #dq_1-enum_daily_plot canvas').length") >= 3, "workload charts")
tw_shot(app, "dq_enumerators_speed")
app$run_js("Array.from(document.querySelectorAll('.tw-dq .tw-tab-panel .nav-link')).find(b=>b.textContent.includes('Performance table')).click()"); Sys.sleep(2)
ok(rows_in("dq_1-enum_metrics_table") > 0, paste("metrics rows:", rows_in("dq_1-enum_metrics_table")))
tw_shot(app, "dq_enumerators_table")

# ---- reset to original
click("dq_1-btn_reset_data")
modal_click("dq_1-confirm_reset")
ok(grepl("1,505", txt("#dq_1-dq_filtered_rows")), paste("reset:", txt("#dq_1-dq_filtered_rows")))

# ---- dark mode
tab("Outliers")
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1.5)
tw_shot(app, "dq_outliers_dark")
tab("Health check"); tw_shot(app, "dq_health_dark")
tab("Duplicates"); tw_shot(app, "dq_duplicates_dark")
tab("Location names normalization"); tw_shot(app, "dq_location_dark")
tab("Enumerator Performance"); tw_shot(app, "dq_enumerators_dark")
tab("Outliers"); setr("dq_1-outlier_tabs", "flagged"); tw_shot(app, "dq_outliers_flagged_dark")
tab("Missing Data Checking"); tw_shot(app, "dq_missing_dark")

# shinyreact logs every output message (validation included) as "Error for <id>";
# the messages the DQ outputs show must be validation notes, not R errors
notes <- js("Array.from(document.querySelectorAll('.tw-dq .tw-output-note, .tw-dq .shiny-output-error')).map(e=>e.id+': '+e.textContent).join(' | ')")
cat("messages shown:", notes, "
")
e <- grep("Error for", tw_errors(app), invert = TRUE, value = TRUE)
ok(!length(e), paste("browser errors (other than output messages):", paste(e, collapse = " | ")))
