# Browser check: Targeting Design data that came from a MODA form offers
# "Refresh from MODA" after a restore (the form is saved, never the key).
#   NOT_CRAN=true Rscript react/dev/test_moda_refresh.R      (from the package root)
source("react/dev/e2e.R")
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
suppressMessages(pkgload::load_all(tw_root, quiet = TRUE, export_all = TRUE))
store <- tempfile("twstore"); dir.create(store)
Sys.setenv(TARGETWISE_SESSION_DIR = store)

# 1. a Design session saved from the app
app <- tw_launch(store = store)
js <- function(x) app$get_js(x)
tw_go(app, "scorecard_panel")
app$upload_file(`scorecard_1-assessment_file` = file.path(tw_root, "inst/extdata/assessment_demo.csv")); Sys.sleep(4); tw_idle(app)
ok(!js("!!document.getElementById('scorecard_1-moda_refresh-go')"), "no refresh for data from a file")
tw_click(app, "session_manager_1-btn_save_session"); Sys.sleep(1.5)
app$set_inputs(`session_manager_1-save_session_name` = "t1"); app$click("session_manager_1-btn_confirm_save"); Sys.sleep(4); tw_idle(app)
app$stop()
f <- list.files(store, pattern = "^t1\\.design\\.rds$")
ok(length(f) == 1, paste("design session saved:", paste(f, collapse = ", ")))

# 2. as if the data had come from MODA form 123456
s <- load_session("t1.design")
s$workspace$scorecard$moda_form <- "123456"
save_session(uploaded_df = s$uploaded_df, user_setup = s$user_setup, modification_log = s$modification_log,
             name = "t1", kind = "design", workspace = s$workspace, labels = s$labels)

# 3. a fresh app restores it
app <- tw_launch(store = store)
app$wait_for_js("!!document.getElementById('session_manager_1-restore_session_choice')", timeout = 60000); tw_idle(app)
app$set_inputs(`session_manager_1-restore_session_choice` = "t1.design")
app$click("session_manager_1-btn_restore_load"); Sys.sleep(6); tw_idle(app); Sys.sleep(2)
tw_go(app, "scorecard_panel")
ok(js("!!document.getElementById('scorecard_1-moda_refresh-go')"), "Refresh from MODA after the restore")
tw_click(app, "scorecard_1-moda_refresh-go"); Sys.sleep(1.5)
m <- js("(document.querySelector('.modal.show')||{}).innerText || ''")
ok(grepl("123456", m) && js("!!document.getElementById('scorecard_1-moda_refresh-token')"), "it asks for the key, for form 123456")
tw_shot(app, "moda_refresh_design")
cat("errors:", tw_errors(app), "\n")
app$stop()
