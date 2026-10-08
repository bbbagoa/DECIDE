# Browser check: a model fit runs in the background R process from source
# (the worker loads this folder), with the cancel cross, and Cancel stops it.
#   NOT_CRAN=true Rscript react/dev/test_background.R
source("react/dev/e2e.R")
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
app <- tw_launch(background = TRUE)
js <- function(x) app$get_js(x)
NS <- "scorecard_1-"
setv <- function(id, value) app$run_js(sprintf("(function(){var el=document.querySelector('.shiny-bound-input#%s'); $(el).data('shiny-input-binding').receiveMessage(el, {value: %s});})()", paste0(NS, id), jsonlite::toJSON(value, auto_unbox = TRUE)))
tw_go(app, "scorecard_panel")
app$upload_file(`scorecard_1-assessment_file` = file.path(tw_root, "inst/extdata/assessment_demo.csv")); Sys.sleep(4); tw_idle(app)
tw_click(app, paste0(NS, "fw_validate")); Sys.sleep(2)
tw_click(app, paste0(NS, "nav_next_outcome")); Sys.sleep(2)
tw_click(app, paste0(NS, "nav_next_screening")); Sys.sleep(3); tw_idle(app)
# the first job also loads this source folder in the worker: slow enough to watch
setv("model_method", "xgb"); Sys.sleep(1)
app$run_js(sprintf("document.getElementById('%srun_fit').click()", NS)); Sys.sleep(3)
cross <- js("!!document.querySelector('.tw-wait-cancel') && document.querySelector('.tw-wait-cancel').offsetParent !== null")
ok(cross, "the loader has the cancel cross"); tw_shot(app, "bg_loader")
log <- js("(document.querySelector('.waiter-overlay')||{}).innerText || ''")
ok(grepl("background", log, ignore.case = TRUE), "it runs in the background process")
# the app still answers while the worker fits: a click on the dark-mode switch changes the page
app$run_js("document.querySelector('.tw-mode-btn').click()"); Sys.sleep(1)
ok(identical(js("document.documentElement.getAttribute('data-bs-theme')"), "dark"), "the app stays responsive during the fit")
app$run_js("document.querySelector('.tw-mode-btn').click()")
# let it finish (the first job also loads the source in the worker)
done <- FALSE
for (i in 1:120) { Sys.sleep(2); if (!js("!!document.querySelector('.waiter-overlay')")) { done <- TRUE; break } }
ok(done, "the fit finishes in the background")
fn <- js("(document.querySelector('.sc-fit-note')||{}).textContent || ''")
ok(grepl("fitted on .* households", fn), paste("the result comes back to the page:", substr(fn, 1, 80)))
# a second fit, cancelled
app$run_js(sprintf("document.getElementById('%srun_fit').click()", NS)); Sys.sleep(0.6)
app$run_js("var b=document.querySelector('.tw-wait-cancel'); if (b) b.click();"); Sys.sleep(3)
ok(!js("!!document.querySelector('.waiter-overlay')") && grepl("Stopped", js("document.body.innerText")), "Cancel stops it")
cat("errors:", tw_errors(app), "\n")
app$stop()
