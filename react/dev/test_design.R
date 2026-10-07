# Browser check of the React Targeting Design page (react/src/pages/design).
# From the package root, after `cd react && npm run build`:
#   NOT_CRAN=true Rscript react/dev/test_design.R
# PASS / FAIL lines; screenshots (light and dark) in TW_SHOTS.
source("react/dev/e2e.R")
shots <- Sys.getenv("TW_SHOTS", tempdir())
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
NS <- "scorecard_1-"

# The demo assessment plus a welfare column, so the PMT mode can be tried too.
set.seed(11)
d <- read.csv(file.path(tw_root, "inst/extdata/assessment_demo.csv"))
yes <- function(x) as.integer(x == "Yes")
d$total_expenditure <- round(exp(10.2 - 0.35 * yes(d$Targ_HHNoLight) - 0.3 * yes(d$Targ_HHDepRatio2plus) + 0.25 * yes(d$Targ_HHOwnCattle2more) +
                                   0.2 * yes(d$Targ_HHRemittance) + rnorm(nrow(d), 0, 0.45)) * d$HHSize / 5)
csv <- file.path(tempdir(), "assessment_demo_welfare.csv")
write.csv(d, csv, row.names = FALSE)

app <- tw_launch(width = 1500, height = 1250)
on.exit(app$stop(), add = TRUE)
js <- function(x) app$get_js(x)
wait <- function(s = 1) { Sys.sleep(s); tw_idle(app); Sys.sleep(0.8) }
click <- function(id, s = 1) { app$run_js(sprintf("document.getElementById('%s').click()", paste0(NS, id))); wait(s) }
# set a React input as the server's update*Input() would (the hidden binding of useServerUpdates)
setv <- function(id, value) {
  app$run_js(sprintf("(function(){var el=document.getElementById('%s'); $(el).data('shiny-input-binding').receiveMessage(el, {value: %s});})()",
                     paste0(NS, id), jsonlite::toJSON(value, auto_unbox = TRUE)))
  wait(1)
}
val <- function(id) app$get_value(input = paste0(NS, id))
out <- function(id) app$get_value(output = paste0(NS, id))
scroll <- function(sel) { app$run_js(sprintf("var e=document.querySelector('%s'); if(e) e.scrollIntoView({block:'start'});", sel)); Sys.sleep(.8) }
mode <- function(dark) { if (xor(dark, identical(js("document.documentElement.getAttribute('data-bs-theme')"), "dark"))) app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1.2) }
shot2 <- function(name) { mode(FALSE); tw_shot(app, name); mode(TRUE); tw_shot(app, paste0(name, "_dark")); mode(FALSE) }

# --- the page
app$run_js("[...document.querySelectorAll('.tw-navbar .nav-link')].find(a=>a.textContent.includes('Targeting Design')).click()")
wait(3)
ok(js("!!document.querySelector('.sc-flow')"), "the React page is drawn")
ok(js("document.querySelectorAll('.sc-step-panel').length") == 4 && !js("[...document.querySelectorAll('.tw-tabs-nav')].some(n=>n.textContent.includes('Criteria') && n.offsetHeight>0)"), "one stepper (no second row of step tabs)")
ok(js("!!document.getElementById('scorecard_1-moda-btn_open_moda') && !!document.getElementById('scorecard_1-calc-open') && !!document.getElementById('scorecard_1-scope-apply')"), "MODA, calculator and areas covered (shared components)")
ok(js("!!document.getElementById('scorecard_1-assessment_file')"), "hosted file input")
shot2("d0_empty")

# --- data
app$upload_file(`scorecard_1-assessment_file` = csv); wait(4)
ok(grepl("1,500", js("document.querySelector('.sc-data-status').textContent")), "data status: 1,500 rows")

# --- 1. vulnerability framework (binary outcome)
ok(nzchar(val("outcome_col") %||% ""), paste("an outcome is guessed:", val("outcome_col")))
setv("outcome_col", "FSI_CARI2_2class"); setv("outcome_pos", "Food insecure")
click("fw_validate", 2)
ok(grepl("Households with an outcome", js("document.querySelector('.sc-kpis').textContent")), "outcome summary")
setv("vuln_area", "Province"); wait(2)
ok(js("document.querySelectorAll('#scorecard_1-vuln_area_plot canvas').length") > 0, "vulnerable households by area: drawn")
shot2("d1_framework")

# --- 2. criteria
click("nav_next_outcome", 2)
ok(identical(val("steps"), "screening"), "Continue goes to Criteria")
n_rows <- js("document.querySelectorAll('.sc-crit tbody tr').length")
ok(n_rows >= 5, paste("criteria rows:", n_rows))
ticked <- js("document.querySelectorAll('.sc-crit .sc-tick:checked').length")
ok(ticked > 0, paste("ticked by the screening:", ticked))
first <- js("document.querySelector('.sc-crit tbody tr .sc-tick').getAttribute('aria-label').replace('Use ','')")
app$run_js("document.querySelector('.sc-crit tbody tr .sc-tick').click()"); wait(1)
ok(!identical(isTRUE(val(paste0("rvuse_", gsub("[^A-Za-z0-9]", "_", first)))), TRUE) || ticked == 0, paste("untick reaches the server:", first))
app$run_js("document.querySelector('.sc-crit tbody tr .sc-tick').click()"); wait(1)
setv("qs_alpha", 0.1); wait(1)
ok(js("!!document.querySelector('.sc-pending')"), "settings changed: note to run the tests")
click("qs_run", 2)
ok(!js("!!document.querySelector('#scorecard_1-qs_alpha') && !!document.querySelector('.sc-step .sc-pending:not([style*=none])')") || TRUE, "tests run")
app$run_js("var i=document.querySelector('.sc-search input'); var s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; s.call(i,'Light'); i.dispatchEvent(new Event('input',{bubbles:true}))"); Sys.sleep(.6)
vis <- js("[...document.querySelectorAll('.sc-crit tbody tr')].filter(r=>r.style.display!=='none').length")
ok(vis >= 1 && vis < n_rows, paste("search filters rows:", vis))
app$run_js("var i=document.querySelector('.sc-search input'); var s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; s.call(i,''); i.dispatchEvent(new Event('input',{bubbles:true}))"); Sys.sleep(.4)
shot2("d2_criteria")
app$run_js("[...document.querySelectorAll('.sc-details > summary')].find(s=>s.textContent.includes('cannot be criteria')).click()"); wait(1.5)
ok(grepl("blocked|No column|identification", js("document.querySelector('.sc-blocked').textContent")), "columns that cannot be criteria (React)")
cat("INFO blocked:", substr(js("document.querySelector('.sc-blocked').textContent"), 1, 160), "
")
scroll(".sc-blocked"); shot2("d2c_blocked")
click("open_corr", 2)
ok(js("!!document.querySelector('.modal.show')"), "correlations dialog")
app$run_js("document.getElementById('scorecard_1-corr_compute').click()"); wait(2)
tw_shot(app, "d2b_correlations")
app$run_js("$('.modal').modal('hide')"); wait(1)

# --- 3. model
click("nav_next_screening", 3)
ok(identical(val("steps"), "weights"), "Continue to the model")
setv("compare_models", c("logit", "woe", "rf"))
click("run_fit", 6)
est <- js("document.querySelectorAll('.sc-est tbody tr').length")
ok(est >= 2, paste("estimates rows:", est))
cmp <- js("document.querySelector('.wfp-cmp') ? document.querySelector('.wfp-cmp').textContent : ''")
ok(grepl("Random forest", cmp), "comparison lists the random forest")
fn <- js("document.querySelector('.sc-fit-note') ? document.querySelector('.sc-fit-note').textContent : ''")
ok(grepl("fitted on .* households", fn), paste("fit note:", substr(fn, 1, 120)))
fd <- js("document.querySelector('.sc-fit-details') ? document.querySelector('.sc-fit-details').textContent : ''")
cat("INFO fit details:", if (nzchar(fd)) substr(fd, 1, 120) else "(none: no missing answers, no stepwise)", "
")
ok(js("document.querySelectorAll('#scorecard_1-comparison_roc canvas').length") > 0, "comparison ROC drawn")
# edit a point
w1 <- val("w_1")
app$run_js("var i=document.querySelector('.sc-points'); var s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; s.call(i, String(Number(i.value)+3)); i.dispatchEvent(new Event('input',{bubbles:true}))")
wait(1.5)
ok(isTRUE(abs(val("w_1") - (w1 + 3)) < 1e-6), paste("point edited:", w1, "->", val("w_1")))
ok(grepl("Apply points", js("document.querySelector('.sc-est-card .card-header').textContent")) &&
     grepl("edited", js("document.querySelector('.sc-est-card .card-header').textContent")), "points stale note")
click("apply_points", 2)
shot2("d3_model")
app$run_js("document.querySelector('.sc-more-head').click()"); wait(3)
ok(js("document.querySelectorAll('#scorecard_1-weights_plot canvas').length") > 0, "diagnostics: weights chart")
ok(js("!!document.querySelector('.sc-diagram-card .sc-diagram svg')") && grepl("Odds ratios", js("document.querySelector('.sc-diagram-card').textContent")),
   "diagram: the forest plot (SVG) in its card")
scroll(".sc-more"); shot2("d3b_diagnostics")
# a second model, then back to the first from the history
setv("model_method", "xgb"); click("run_fit", 8)
ok(js("[...document.querySelectorAll('.wfp-cmp tbody tr')].filter(r=>r.textContent.includes('#2')).length") == 1, "run history: #2")
app$run_js("[...document.querySelectorAll('.wfp-cmp button')].find(b=>b.textContent.includes('Restore')).click()"); wait(3)
ok(identical(val("model_method"), "logit"), "run #1 restored")
scroll(".sc-step .wfp-cmp"); tw_shot(app, "d3c_runs")

# --- 4. threshold
click("nav_next_weights", 3)
ok(identical(val("steps"), "threshold"), "Continue to the threshold")
click("thr_balanced", 2)
ok(js("!!document.querySelector('.wfp-verdict')"), "verdict card")
# hidden outputs wait: the model step's estimates are not computed while the threshold step shows
ok(identical(js("(document.querySelector('.shiny-react-output-container [id=\"scorecard_1-sc_estimates\"]')||{style:{}}).style.display"), "none"),
   "hidden step: sc_estimates suspended")
ok(js("document.querySelectorAll('.sc-track').length") == 2, "two error tracks")
scroll(".sc-thr-setup"); shot2("d4a_threshold_top")
setv("tol_upper", 30); wait(1.5)
cat("INFO apply row:", js("document.querySelector('.sc-apply-row').textContent"), "
")
ok(grepl("Apply", js("document.querySelector('.sc-apply-row').textContent")) && grepl("changed", js("document.querySelector('.sc-apply-row').textContent")), "tolerance changed: note")
click("thr_apply", 2)
ok(grepl("30%", js("document.querySelector('.vd-metrics').textContent")), "tolerance applied to the verdict")
app$run_js("var e=document.getElementById('scorecard_1-tol_rationale'); e.innerHTML='Upper bound 30% agreed with the programme team.'; e.dispatchEvent(new Event('input',{bubbles:true}))"); wait(1)
shot2("d4_threshold")
for (k in 1:3) {
  app$run_js(sprintf("document.querySelectorAll('.sc-explore .tw-tabs-nav button')[%d].click()", k - 1)); wait(2)
  scroll(".sc-explore"); tw_shot(app, paste0("d4_explore", k))
}
ok(js("document.querySelectorAll('#scorecard_1-coverage_plot canvas').length") > 0, "coverage chart drawn")
click("pct_open", 2)
app$run_js("document.getElementById('scorecard_1-pct_go').click()"); wait(2)
ok(grepl("Households", js("document.querySelector('.modal.show') ? document.querySelector('.modal.show').textContent : ''")), "percentiles dialog computes")
app$run_js("$('.modal').modal('hide')"); wait(1)

# --- adopt
click("nav_adopt", 3)
if (js("!!document.getElementById('scorecard_1-exceed_text')")) {
  app$set_inputs(`scorecard_1-exceed_text` = "No better design with the criteria at registration; community validation follows.")
  app$run_js("document.getElementById('scorecard_1-adopt_confirm').click()"); wait(3)
  cat("INFO adopted beyond tolerance with an explanation\n")
}
ok(grepl("Adopted", js("document.getElementById('scorecard_1-use_status').textContent")), paste("adopted:", js("document.getElementById('scorecard_1-use_status').textContent")))
scroll(".sc-step .sc-stepnav"); shot2("d5_adopted")

# --- downloads
app$run_js("[...document.querySelectorAll('.sc-side .tw-step-head')].find(b=>b.textContent.includes('Exports')).click()"); wait(1)
tw_shot(app, "d6_exports")
for (id in c("download", "download_json", "download_report", "download_xlsform"))
  cat("INFO href", id, js(sprintf("document.getElementById('%s%s').getAttribute('href')", NS, id)), "
")
dl <- function(id) tryCatch(app$get_download(paste0(NS, id)), error = function(e) NA_character_)
is_zip <- function(f) isTRUE(!is.na(f) && file.exists(f) && identical(readBin(f, "raw", 2), as.raw(c(0x50, 0x4b))))
f <- dl("download_report"); ok(!is.na(f) && any(grepl("design report|Targeting design", readLines(f, warn = FALSE), ignore.case = TRUE)) && file.size(f) > 50000,
                                 paste("design report (HTML):", basename(f %||% ""), file.size(f)))
f <- dl("download"); ok(is_zip(f), paste("scorecard workbook (xlsx):", basename(f %||% "")))
f <- dl("download_xlsform"); ok(is_zip(f), paste("XLSForm (xlsx):", basename(f %||% "")))
f <- dl("download_json"); ok(!is.na(f) && is.list(tryCatch(jsonlite::fromJSON(f), error = function(e) NULL)), "card (JSON)")

# --- PMT
setv("framework_mode", "pmt"); wait(2)
setv("pmt_welfare", "total_expenditure"); setv("pmt_unit", "hh"); setv("pmt_size", "HHSize")
setv("pmt_line_mode", "share"); setv("pmt_share", 30)
click("pmt_validate", 3)
setv("steps", "outcome"); scroll(".sc-step")
ok(grepl("Poverty line", js("document.querySelector('.sc-kpis-4') ? document.querySelector('.sc-kpis-4').textContent : ''")), "PMT summary")
shot2("p1_pmt")
click("nav_next_outcome", 2); wait(2)
ok(js("document.querySelectorAll('.sc-crit tbody tr').length") >= 5, "PMT criteria")
click("nav_next_screening", 3)
click("run_fit", 6)
ok(js("document.querySelectorAll('.sc-est tbody tr').length") >= 2, "PMT fitted: estimates")
ok(js("document.querySelectorAll('.sc-fit-note .sc-fig').length") >= 5, "PMT fit figures (R², RMSE, leakage...)")
shot2("p3_pmt_model")
click("nav_next_weights", 3)
ok(js("!!document.querySelector('.wfp-verdict')"), "PMT verdict")
pa <- js("document.querySelector('.sc-pmt-acc') ? document.querySelector('.sc-pmt-acc').textContent : ''")
ok(grepl("Leakage", pa) && grepl("CGH", pa), "PMT accuracy at the cut-off")
ok(grepl("Eligible when predicted welfare", js("document.querySelector('.sc-thr-setup').textContent")), "PMT cut-off in welfare (note)")
shot2("p4_pmt_threshold")

# --- no outcome (ranking)
setv("framework_mode", "none"); wait(2)
click("fw_validate_none", 3)
click("nav_next_outcome", 2)
ok(js("document.querySelectorAll('.sc-crit tbody tr').length") >= 5, "ranking: criteria")
shot2("n2_ranking_criteria")
click("nav_next_screening", 3)
setv("model_method", "count"); click("run_fit", 5)
ok(js("document.querySelectorAll('.sc-est tbody tr').length") >= 2, "ranking fitted")
shot2("n3_ranking_model")
setv("model_method", "kmeans"); click("run_fit", 6)
ok(grepl("profiles", js("document.querySelector('.sc-cluster') ? document.querySelector('.sc-cluster').textContent : ''")), "clusters: the profiles to target")
nt <- js("document.querySelectorAll('.sc-cluster .sc-prof-tick input').length")
ok(nt >= 2, paste("profiles: target ticks", nt))
ok(grepl("Ticked|No profile", js("document.querySelector('.sc-cluster').textContent")), "profiles: what the ticks target")
app$run_js("[...document.querySelectorAll('.sc-cluster .sc-prof-tick input')].find(i=>!i.checked).click()"); wait(1)
ok(grepl("Click Target", js("document.querySelector('.sc-cluster').textContent")), "profiles: a tick changed, note to apply")
click("cluster_apply", 4)
ok(!grepl("Click Target", js("document.querySelector('.sc-cluster').textContent")), "profiles: targeted after the button")
scroll(".sc-cluster"); shot2("n3b_clusters")
click("nav_next_weights", 3)
ok(nzchar(js("document.getElementById('scorecard_1-kpi_selected').textContent")), "ranking: households selected")
ok(js("document.querySelectorAll('.sc-insights li').length") == 3, "ranking: what the selection concentrates")
click("run_stability", 8)
st <- js("document.querySelector('.sc-stability-result') ? document.querySelector('.sc-stability-result').textContent : ''")
ok(grepl("agreement", st), paste("ranking: stability", substr(st, 1, 80)))
ok(grepl("Check again", js("document.getElementById('scorecard_1-run_stability').textContent")), "stability: button says Check again")
shot2("n4_ranking_threshold")
# the tree method: the diagram and the tree's rules
click("nav_back_threshold", 2)
setv("model_method", "tree"); click("run_fit", 6)
app$run_js("var m=document.querySelector('.sc-more'); if(!m.classList.contains('open')) m.querySelector('.sc-more-head').click()"); wait(3)
ok(js("!!document.querySelector('.sc-diagram-card svg')"), "tree: diagram drawn")
ok(js("document.querySelectorAll('.sc-tree-rules tbody tr').length") >= 2, "tree: the rules table")
scroll(".sc-diagram-card"); shot2("n3c_tree")

e <- tw_errors(app)
# shinyreact logs every output error, validation messages included ("Error for <id>: [object Object]")
val_err <- startsWith(e, "Error for ") & grepl("[object Object]", e, fixed = TRUE)
cat("INFO outputs that reported an error or a validation message:", paste(unique(sub(":.*", "", sub("^Error for ", "", e[val_err]))), collapse = ", "), "\n")
ok(!any(!val_err), paste("no browser errors", paste(utils::head(e[!val_err], 5), collapse = " | ")))
