# Browser check: a session whose data came from a MODA form offers
# "Refresh MODA" once it is restored (the form is saved, never the API key).
#   NOT_CRAN=true Rscript react/dev/test_moda_restore.R      (from the package root)
source("react/dev/e2e.R")
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
suppressMessages(pkgload::load_all(tw_root, quiet = TRUE, export_all = TRUE))
store <- tempfile("twstore"); dir.create(store)
Sys.setenv(DECIDE_SESSION_DIR = store)
d <- utils::read.csv(file.path(tw_root, "inst/extdata/registration_demo.csv"), stringsAsFactors = FALSE)
save_session(uploaded_df = d, user_setup = list(unique_id = "instanceID", admin1 = "Province", data_source = "MODA form 123456"),
             modification_log = NULL, moda_credentials = list(form_id = "123456", token = "secret"),
             name = "from_moda", kind = "selection")
app <- tw_launch(store = store)
js <- function(x) app$get_js(x)
ok(!js("!!document.getElementById('session_manager_1-btn_sync_moda')"), "no Refresh MODA before anything is loaded")
# the restore prompt at start-up
app$wait_for_js("!!document.getElementById('session_manager_1-btn_restore_load')", timeout = 60000)
tw_idle(app)
app$click("session_manager_1-btn_restore_load"); Sys.sleep(5); tw_idle(app); Sys.sleep(2)
ok(js("!!document.getElementById('session_manager_1-btn_sync_moda')"), "Refresh MODA after restoring a MODA session")
cat("toolbar:", js("document.querySelector('.session-toolbar') ? document.querySelector('.session-toolbar').innerText : ''"), "\n")
tw_shot(app, "moda_restore")
cat("errors:", tw_errors(app), "\n")
app$stop()
