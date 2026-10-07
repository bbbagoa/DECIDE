# Browser check of the React Spot Checking page (react/src/pages/spot/).
# From the package root, after `cd react && npm run build`:
#   NOT_CRAN=true Rscript react/dev/test_spot.R
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
  Sys.sleep(1); tw_idle(app)
}
rows_in <- function(id) js(sprintf("document.querySelectorAll('#%s tbody tr:not(.tw-dt-group)').length", id))
tab <- function(label) { app$run_js(sprintf("Array.from(document.querySelectorAll('.tw-spot .tw-tabs-nav .nav-link')).find(b=>b.textContent.includes('%s')).click()", label)); Sys.sleep(1); tw_idle(app) }
kpi <- function(i) js(sprintf("(document.querySelectorAll('.tw-spot-kpi-value')[%d]||{}).textContent||''", i))
ns <- function(x) paste0("spot_checking_1-", x)
# through the navbar (tw_go() sets input$main_nav, which the React shell does not follow)
go <- function(label) {
  app$run_js(sprintf("Array.from(document.querySelectorAll('.tw-navbar .dropdown-item, .tw-navbar .nav-link')).find(a=>a.textContent.trim().endsWith('%s')).click()", label))
  Sys.sleep(1.5); tw_idle(app)
}

tw_go(app, "import_panel")
try(app$wait_for_js("!!document.querySelector('#file_import_1-file_in.shiny-bound-input')", timeout = 60000))
tw_load_registration(app)
go("Spot Checking")
ok(js("document.querySelector('.tw-spot').offsetWidth > 0"), "the page shows")
ok(js("!!document.querySelector('.tw-spot')"), "the React page is drawn")
# validation messages (req / need) are logged as "Error for <id>: [object Object]"
real_errors <- function() { e <- tw_errors(app); e[!(startsWith(e, "Error for ") & grepl(": [object Object]", e, fixed = TRUE))] }
ok(!length(real_errors()), paste("no browser error after load", paste(head(real_errors(), 2), collapse = " | ")))
ok(identical(app$get_value(input = ns("sc_tabs")), "sample"), "starts on the sample tab (the 0 of Continue is ignored)")
ok(kpi(0) == "1,500", paste("households in scope:", kpi(0)))
ok(rows_in(ns("spot_table")) == 20, paste("sample rows on the first page:", rows_in(ns("spot_table"))))
ok(kpi(2) == "30", paste("sample size:", kpi(2)))
tw_shot(app, "spot_sample")

# ---- areas cascade, Apply, draw a larger sample with another method
ch <- js(sprintf("document.getElementById('%s') ? 1 : 0", ns("sc_admin1")))
set(`spot_checking_1-sc_admin1` = "Ituri")
click(ns("sc_apply"))
p1 <- kpi(0)
ok(p1 != "1,500" && nzchar(p1), paste("Apply filters the scope:", p1))
click(ns("sc_clear"))
ok(kpi(0) == "1,500", "Clear brings every household back")
set(`spot_checking_1-sc_sample_size` = 12, `spot_checking_1-sc_sample_method` = "systematic", `spot_checking_1-sc_per_unit` = "admin1")
click(ns("sc_draw"))
ok(kpi(2) == "36", paste("12 per Admin 1 (3 provinces), systematic:", kpi(2), "share", kpi(1)))
set(`spot_checking_1-sc_per_unit` = "all", `spot_checking_1-sc_sample_method` = "random", `spot_checking_1-sc_sample_size` = 30)
click(ns("sc_draw"))
ok(kpi(2) == "30", paste("back to 30:", kpi(2)))

# ---- remote mode: the phone column shows, the note says how many are reachable
app$run_js("Array.from(document.querySelectorAll('.tw-spot .tw-seg .btn')).find(b=>b.textContent.includes('Remote')).click()"); Sys.sleep(1)
ok(js(sprintf("!!document.getElementById('%s__ctl') && document.getElementById('%s__ctl').offsetParent !== null", ns("sc_phone_col"), ns("sc_phone_col"))),
   "the phone column picker shows in remote mode")
click(ns("sc_draw"))
ok(grepl("Remote check", txt(".tw-spot .tw-notice")), paste("remote note:", substr(txt(".tw-spot .tw-notice"), 1, 120)))
tw_shot(app, "spot_remote")
app$run_js("Array.from(document.querySelectorAll('.tw-spot .tw-seg .btn')).find(b=>b.textContent.includes('Face')).click()"); Sys.sleep(1)
click(ns("sc_draw"))

# ---- record details
app$run_js(sprintf("document.querySelector('#%s .wfp-details-btn').click()", ns("spot_table"))); Sys.sleep(1.5); tw_idle(app)
ok(js("!!document.querySelector('.modal.show .wfp-record-detail')"), "Details opens the record")
app$run_js("document.querySelector('.modal.show .btn[data-dismiss], .modal.show [data-bs-dismiss]').click()"); Sys.sleep(1)

# ---- sample export
f <- tryCatch(app$get_download(ns("download_spot")), error = function(e) NA)
ok(!is.na(f) && file.exists(f) && grepl("xlsx$", f), paste("sample export:", basename(f)))

# ---- verification: Continue, load a re-collected file, compare
click(ns("sc_go_verify"))
ok(identical(app$get_value(input = ns("sc_tabs")), "verify"), "Continue opens the verification tab")
ok(grepl("No verification data yet", txt(".tw-spot")), "empty state before any data")
gate <- js(sprintf("document.getElementById('%s').classList.contains('tw-frozen')", ns("verif_report")))
ok(isTRUE(gate), "report frozen before the comparison")
d <- data.table::fread(file.path(tw_root, "inst/extdata/registration_demo.csv"), data.table = FALSE)
set.seed(3); k <- sample(nrow(d), 300); d$HHSize[k] <- d$HHSize[k] + 1
vf <- file.path(tempdir(), "backcheck.csv"); data.table::fwrite(d, vf)
app$wait_for_js("!!document.querySelector('#spot_checking_1-verif_file.shiny-bound-input')", timeout = 30000)
app$upload_file(`spot_checking_1-verif_file` = vf); Sys.sleep(2); tw_idle(app)
ok(grepl("records loaded", txt(".tw-spot")), paste("status:", regmatches(txt(".tw-spot"), regexpr("[0-9,]+ records loaded[^.]*", txt(".tw-spot")))))
ok(grepl("Ready to compare", txt(".tw-spot")), "ready to compare")
key <- app$get_value(input = ns("verif_key")); cols <- app$get_value(input = ns("verif_cols"))
ok(identical(key, "instanceID") && length(cols) > 5, paste("key", key, "and", length(cols), "fields"))
click(ns("verif_run"))
ok(js(sprintf("document.querySelectorAll('#%s canvas').length", ns("verif_plot"))) > 0, "agreement chart drawn")
ok(rows_in(ns("verif_field_table")) > 0, paste("field summary rows:", rows_in(ns("verif_field_table"))))
ok(rows_in(ns("verif_disc_table")) > 0, paste("discordance rows:", rows_in(ns("verif_disc_table"))))
ok(grepl("%", kpi(3)), paste("agreement on the top figures:", kpi(3)))
ok(!isTRUE(js(sprintf("document.getElementById('%s').classList.contains('tw-frozen')", ns("verif_report")))), "report unfrozen")
tw_shot(app, "spot_verify")
app$run_js("document.querySelector('.tw-spot .tw-side-main').scrollTop = 99999"); Sys.sleep(1)
tw_shot(app, "spot_verify_results")
f <- tryCatch(app$get_download(ns("verif_report")), error = function(e) NA)
ok(!is.na(f) && file.exists(f) && any(grepl("Back-check|back-check|agreement", readLines(f, warn = FALSE))), paste("verification report:", basename(f), if (!is.na(f)) file.size(f)))
f <- tryCatch(app$get_download(ns("verif_download")), error = function(e) NA)
ok(!is.na(f) && file.exists(f) && grepl("xlsx$", f), paste("comparison workbook:", basename(f)))

# ---- dark mode
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1.5)
tw_shot(app, "spot_verify_dark")
app$run_js("document.querySelector('.tw-spot .tw-side-main').scrollTop = 0"); Sys.sleep(.5)
tw_shot(app, "spot_verify_dark_top")
tab("1. Sample"); tw_shot(app, "spot_sample_dark")
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1)
e <- real_errors()
ok(!length(e), paste("browser errors:", paste(head(e, 3), collapse = " | ")))
