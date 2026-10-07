# Browser check of the React toolkit (src/lib) against the gallery app.
# From the package root, after `cd react; npm run gallery`:
#   NOT_CRAN=true Rscript react/dev/gallery/test.R
# Prints PASS / FAIL lines; screenshots go to tempdir() unless GALLERY_SHOTS is set.
shots <- Sys.getenv("GALLERY_SHOTS", tempdir())
unlink(file.path(shots, c("gallery_charts.png", "gallery_tables.png", "gallery_dark.png")))
app <- shinytest2::AppDriver$new("react/dev/gallery", height = 1000, width = 1500, load_timeout = 120000, timeout = 60000)
on.exit(app$stop())
Sys.sleep(3); app$wait_for_idle()
js <- function(x) app$get_js(x)
st <- function() jsonlite::fromJSON(js("document.getElementById('state').textContent"), simplifyVector = FALSE)
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")

s <- st()
ok(identical(s$sel$value, "a") && identical(s$sel$class, "character"), "select starts at its value")
ok(identical(s$pick, "NULL"), "empty picker is NULL")
ok(identical(s$num$value, 5L) || identical(s$num$value, 5), "numeric starts at 5")
ok(identical(s$tabs$value, "charts"), "tabs input")
ok(identical(s$sld$class, "numeric") && length(s$sld$value) == 2, "range slider is a numeric pair")
charts <- js("Array.from(document.querySelectorAll('.tw-echart canvas')).length")
ok(charts >= 9, paste("charts drawn:", charts))
app$get_screenshot(file.path(shots, "gallery_charts.png"))

# frozen button: no click reaches the server
app$run_js("document.getElementById('gated').click()"); Sys.sleep(.5)
ok(identical(st()$gated$value, 0L) || identical(st()$gated$value, 0), "gated button frozen")

# server updates reach the React inputs
app$run_js("document.getElementById('upd').click()"); Sys.sleep(1.5); app$wait_for_idle()
s <- st()
ok(identical(s$sel$value, "y"), "updateSelectInput")
ok(identical(unlist(s$pick$value), c("1", "2")), "updatePickerInput")
ok(identical(s$rad$value, "three"), "updateRadioButtons")
ok(isTRUE(as.numeric(s$num$value) == 42), "updateNumericInput")
ok(identical(s$txt$value, "from the server"), "updateTextInput")
ok(identical(as.numeric(unlist(s$sld$value)), c(20, 30)), "updateSliderInput")
ok(isTRUE(s$chk$value), "updateCheckboxInput")
ok(identical(unlist(s$cg$value), "y"), "updateCheckboxGroupInput")
ok(identical(unlist(s$dr$value), c("2026-01-01", "2026-02-01")) && identical(s$dr$class, "Date"), "updateDateRangeInput (Dates)")
ok(identical(s$tabs$value, "tables"), "nav_select")

# tables
ok(js("document.querySelectorAll('#tbl tbody tr').length") == 10, "page of 10 rows")
ok(grepl("Household", js("document.querySelector('#tbl thead').textContent")) == FALSE &&
     grepl("Name", js("document.querySelector('#tbl thead').textContent")), "colnames from the DT widget")
app$run_js("document.querySelectorAll('#tbl tbody tr')[1].click()"); Sys.sleep(.5)
ok(identical(as.numeric(unlist(st()$tbl_rows_selected$value)), 2), "row selection = data row")
app$run_js("document.getElementById('selrows').click()"); Sys.sleep(1)
ok(identical(as.numeric(unlist(st()$tbl_rows_selected$value)), c(1, 2, 3)), "react_table_select")
app$run_js("var i=document.querySelector('#tbl .tw-search input'); var set=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set; set.call(i,'Household 3'); i.dispatchEvent(new Event('input',{bubbles:true}))"); Sys.sleep(1)
ok(length(unlist(st()$tbl_rows_all$value)) == 11, "search -> rows_all (3, 30-39)")
ok(grepl("20,000", js("document.querySelector('#big .tw-dt-foot').textContent")), "server table total")
app$run_js("document.querySelector('#big .tw-dt-foot .btn-group button:last-child').click()"); Sys.sleep(1.5)
ok(grepl("^16-30", trimws(js("document.querySelector('#big .tw-dt-foot span').textContent"))), "server paging")
app$get_screenshot(file.path(shots, "gallery_tables.png"))
app$run_js("document.documentElement.setAttribute('data-bs-theme','dark'); document.querySelectorAll('.tw-tabs-nav button')[0].click()"); Sys.sleep(1.5)
app$get_screenshot(file.path(shots, "gallery_dark.png"))
lg <- as.data.frame(app$get_logs()); e <- grep("rror|Uncaught", lg$message, value = TRUE)
ok(!length(e), paste("no errors", paste(utils::head(e, 5), collapse = " | ")))
