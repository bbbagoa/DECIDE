# Browser check of the React Welcome and Load registration data pages, and of
# the shared components they use (FileImport, ModaImport, VarCalc, SessionToolbar).
#   NOT_CRAN=true Rscript react/dev/test_welcome_import.R   (from the package root)
source("react/dev/e2e.R")
ok <- function(cond, what) { cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n"); invisible(isTRUE(cond)) }
nav <- function() app$get_value(input = "main_nav")
modal_open <- function() isTRUE(tw_js(app, "!!document.querySelector('.modal.show')"))
close_modal <- function() { tw_js(app, "(function(){var b=document.querySelector('#shiny-modal [data-bs-dismiss=modal], #shiny-modal [data-dismiss=modal]');if(b)b.click();return !!b})()"); try(app$wait_for_js("!document.querySelector('.modal.show')", timeout = 10000)); Sys.sleep(0.5) }
set_lang <- function(l) tw_js(app, sprintf(
  "(function(){var s=document.querySelector('.mini-theme-selector select');var f=Object.getOwnPropertyDescriptor(HTMLSelectElement.prototype,'value').set;f.call(s,'%s');s.dispatchEvent(new Event('change',{bubbles:true}));return true})()", l))

app <- tw_launch()
on.exit(app$stop(), add = TRUE)

# --- Welcome: no button fires on its initial 0, nothing opens by itself
ok(identical(nav(), "welcome_panel"), "starts on Welcome (no shortcut fired at start)")
ok(!modal_open(), "no dialog opened at start")
ok(isTRUE(tw_js(app, "!!document.getElementById('go_design') && !document.getElementById('pg_welcome_panel')?.children.length")),
   "Welcome drawn by React (no hosted Shiny page)")
Sys.sleep(1)
ok(grepl("1.0.0|development", tw_js(app, "document.querySelector('.tw-wl-release').innerText")), "version shown")
tw_shot(app, "welcome_light")
tw_js(app, "document.querySelector('.tw-mode-btn').click(); true"); Sys.sleep(1.5)
tw_shot(app, "welcome_dark")
tw_js(app, "document.querySelector('.tw-mode-btn').click(); true"); Sys.sleep(1)
set_lang("fr"); Sys.sleep(2)
ok(grepl("Par o", tw_js(app, "document.querySelector('.tw-wl').textContent")), "French labels on Welcome")
tw_shot(app, "welcome_fr")
set_lang("en"); Sys.sleep(1)

# --- registration import end to end, from Welcome: the import page was never
# shown, so this also checks that its file input is ready while hidden
ok(isTRUE(tw_js(app, "!!document.getElementById('file_import_1-file_in')")), "file input ready on the hidden import page")
tw_load_registration(app)
ok(identical(nav(), "overview_panel"), "after setup: Overview")

# --- the three shortcuts
for (b in list(c("go_design", "scorecard_panel"), c("go_monitor", "pdm_panel"), c("go_import", "import_panel"))) {
  tw_go(app, "welcome_panel")
  tw_click(app, b[1]); Sys.sleep(1.5); tw_idle(app)
  ok(identical(nav(), b[2]), paste(b[1], "->", b[2]))
}
Sys.sleep(1)
st <- tw_js(app, "document.querySelector('.tw-imp-status').innerText")
ok(grepl("Variables mapped", st), paste("status strip:", gsub("\n", " | ", st)))
ok(grepl("registration_demo.csv", tw_js(app, "document.querySelector('.tw-file-ok')?.innerText || ''")), "file line names the file")
tw_shot(app, "import_loaded")

# --- MODA dialog fields (no API call)
tw_click(app, "moda_import_1-btn_open_moda"); Sys.sleep(1); tw_idle(app)
try(app$wait_for_js("!!document.getElementById('moda_import_1-form_id')", timeout = 20000))
ok(isTRUE(tw_js(app, "!!document.getElementById('moda_import_1-form_id') && !!document.getElementById('moda_import_1-token') && !!document.getElementById('moda_import_1-provider')")),
   "MODA dialog: server, form ID and key fields")
ok(identical(tw_js(app, "document.querySelectorAll('.modal').length"), 1L), "one click opens one dialog")
tw_shot(app, "import_moda")
close_modal()

# --- variable calculator: a yes/no variable, audited
tw_click(app, "calc_reg-open"); Sys.sleep(2); tw_idle(app)
ok(modal_open(), "calculator dialog opens")
try(app$wait_for_js("!!document.getElementById('calc_reg-c_col_1')", timeout = 30000))
app$set_inputs(`calc_reg-name` = "big_household"); tw_idle(app)
app$set_inputs(`calc_reg-c_col_1` = "HHSize"); tw_idle(app)
app$set_inputs(`calc_reg-c_op_1` = ">="); app$set_inputs(`calc_reg-c_val_1` = "8"); tw_idle(app)
tw_shot(app, "import_calc")
app$click("calc_reg-create"); Sys.sleep(2); tw_idle(app)
ok(!modal_open(), "calculator closes after Create")
st2 <- tw_js(app, "document.querySelector('.tw-imp-status').innerText")
ncols <- function(s) as.integer(gsub(",", "", sub("^.*?([0-9,]+) columns.*$", "\\1", gsub("\n", " ", s), perl = TRUE)))
ok(ncols(st2) == ncols(st) + 1L, paste("column count +1:", gsub("\n", " | ", st2)))
tw_go(app, "modif_logs"); Sys.sleep(1.5)
ok(grepl("big_household", tw_js(app, "document.querySelector('.tw-audit').innerText")), "variable created is in the audit trail")

# --- session toolbar: Save opens its dialog (and nothing opened at start)
tw_click(app, "session_manager_1-btn_save_session"); Sys.sleep(1.5); tw_idle(app)
ok(modal_open(), "Save opens the save dialog")
close_modal()
tw_go(app, "import_panel")
tw_js(app, "document.querySelector('.tw-mode-btn').click(); true"); Sys.sleep(1.5)
tw_shot(app, "import_dark")
set_lang("fr"); Sys.sleep(2)
ok(grepl("Avant de commencer", tw_js(app, "document.querySelector('.tw-imp').textContent")), "French labels on the import page")
tw_shot(app, "import_fr")

e <- grep("calc_reg|moda_import|file_import|setup_1|session_manager|welcome", tw_errors(app), value = TRUE)
ok(!length(e), paste("browser errors:", paste(e, collapse = " / ")))
cat("other browser errors (not these pages):\n"); print(unique(sub("\n.*", "", tw_errors(app))))
