# Browser check: the food security indicators dialog on Targeting Design.
#   NOT_CRAN=true Rscript react/dev/test_fsi.R      (from the package root)
# Data: the demo assessment plus WFP-named variables for FCS, rCSI, LCS-FS and
# FES (one FES purchase column left out first, so FES must be refused).
source("react/dev/e2e.R")
ok <- function(cond, what) cat(if (isTRUE(cond)) "PASS" else "FAIL", what, "\n")
set.seed(7)
d <- utils::read.csv(file.path(tw_root, "inst/extdata/assessment_demo.csv"), stringsAsFactors = FALSE)
n <- nrow(d)
days <- function(p) pmin(7, stats::rbinom(n, 7, p))
for (g in c("FCSStap", "FCSPulse", "FCSDairy", "FCSPr", "FCSVeg", "FCSFruit", "FCSFat", "FCSSugar", "FCSCond"))
  d[[g]] <- days(c(FCSStap = .95, FCSPulse = .4, FCSDairy = .15, FCSPr = .3, FCSVeg = .6, FCSFruit = .2, FCSFat = .6, FCSSugar = .5, FCSCond = .9)[[g]])
for (v in c("rCSILessQlty", "rCSIBorrow", "rCSIMealNb", "rCSIMealSize", "rCSIMealAdult")) d[[v]] <- days(.3)
lcs <- c("Lcs_stress_DomAsset", "Lcs_stress_Utilities", "Lcs_stress_Saving", "Lcs_stress_BorrowCash", "Lcs_crisis_ProdAssets",
         "Lcs_crisis_Health", "Lcs_crisis_OutSchool", "Lcs_em_ResAsset", "Lcs_em_Begged", "Lcs_em_IllegalAct")
for (v in lcs) d[[v]] <- sample(c(10, 20, 30, 9999), n, TRUE, prob = c(.6, .1, .2, .1))
food <- c("Cer", "Tub", "Puls", "Veg", "Frt", "AnimMeat", "AnimFish", "Fats", "Dairy", "Egg", "Sgr", "Cond", "Bev", "Out")
for (i in food) { d[[sprintf("HHExpF%s_Purch_MN_7D", i)]] <- round(stats::rexp(n, 1 / 800)); d[[sprintf("HHExpF%s_Own_MN_7D", i)]] <- round(stats::rexp(n, 1 / 200)) }
for (i in c("Hyg", "Transp", "Fuel", "Wat", "Elec", "Energ", "DwelSer", "Phone", "Recr", "AlcTobac")) d[[sprintf("HHExpNF%s_Purch_MN_1M", i)]] <- round(stats::rexp(n, 1 / 1500))
for (i in c("MedServ", "MedGood", "Cloth", "EduFee", "EduGood", "Rent", "HHMaint", "HHSoft")) d[[sprintf("HHExpNF%s_Purch_MN_6M", i)]] <- round(stats::rexp(n, 1 / 6000))
full <- file.path(tempdir(), "assessment_fsi.csv"); utils::write.csv(d, full, row.names = FALSE)
part <- file.path(tempdir(), "assessment_fsi_nofes.csv"); utils::write.csv(d[setdiff(names(d), "HHExpFOut_Purch_MN_7D")], part, row.names = FALSE)

app <- tw_launch()
NS <- "scorecard_1-"
js <- function(x) app$get_js(x)
wait <- function(s = 1) { Sys.sleep(s); tw_idle(app); Sys.sleep(0.6) }
modal <- function() js("(document.querySelector('.modal.show .modal-body')||{}).innerText || ''")
tw_go(app, "scorecard_panel"); wait(2)

# --- data without one FES purchase column: FES refused, the others offered
app$upload_file(`scorecard_1-assessment_file` = part); wait(4)
ok(js("!!document.querySelector('.sc-data-tools #scorecard_1-fsi-open')"), "the button is with the data buttons")
tw_shot(app, "fsi_sidebar")
tw_click(app, paste0(NS, "fsi-open")); wait(2)
m <- modal()
ok(grepl("Food Consumption Score", m) && grepl("CARI", m), "the dialog lists the indicators")
ok(js("!!document.getElementById('scorecard_1-fsi-use_fcs') && !!document.getElementById('scorecard_1-fsi-use_rcsi') && !!document.getElementById('scorecard_1-fsi-use_lcs_fs')"), "FCS, rCSI and LCS-FS can be ticked")
ok(!js("!!document.getElementById('scorecard_1-fsi-use_fes')") && grepl("HHExpFOut_Purch_MN_7D", m), "FES refused, the missing column named")
ok(!js("!!document.getElementById('scorecard_1-fsi-use_lcs_en')"), "LCS-EN refused (no LcsEN_ columns)")
ok(!js("!!document.getElementById('scorecard_1-fsi-use_cari')"), "CARI refused without FES or ECMEN")
tw_shot(app, "fsi_dialog_partial")
app$run_js("document.querySelector('.modal.show .modal-footer button[data-dismiss], .modal.show .modal-footer button[data-bs-dismiss]').click()"); wait(1)

# --- full data: everything but LCS-EN, CARI with FES
app$upload_file(`scorecard_1-assessment_file` = full); wait(4)
tw_click(app, paste0(NS, "fsi-open")); wait(2)
ok(js("!!document.getElementById('scorecard_1-fsi-use_fes') && !!document.getElementById('scorecard_1-fsi-use_cari')"), "with every FES column: FES and CARI offered")
ok(grepl("counted as 0", modal()), "missing gift / aid columns said to count as 0")
tw_shot(app, "fsi_dialog_full")
app$click(paste0(NS, "fsi-compute")); wait(4)
m <- modal()
ok(grepl("calculated", js("(document.querySelector('.modal.show .modal-title')||{}).innerText || ''")), "result dialog")
ok(grepl("Acceptable", m) && grepl("Phase 1", m) && grepl("Emergency", m) && grepl("Very high", m) && grepl("food secure", m, ignore.case = TRUE), "a table per indicator")
ok(grepl("CARI_FES_2class", m) && grepl("binary food insecurity", m, ignore.case = TRUE), "binary CARI added (option ticked by default), outcome suggested")
tw_shot(app, "fsi_result")
app$run_js("document.querySelector('.modal.show .modal-footer button').click()"); wait(1.5)
ch <- js("JSON.stringify([...document.querySelectorAll('#scorecard_1-outcome_col__ctl')].length)")
# the outcome picker offers the new yes / no columns, CARI first
app$run_js("var c=document.querySelector('#scorecard_1-outcome_col__ctl'); c.focus(); c.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowDown',keyCode:40,bubbles:true}))"); Sys.sleep(1)
opts <- js("[...document.querySelectorAll('.tw-select__option')].map(o=>o.textContent).join(' | ')")
ok(grepl("CARI_FES_2class", opts), paste("outcome choices include CARI_FES_2class:", substr(opts, 1, 160)))
tw_shot(app, "fsi_outcome")
app$run_js("document.activeElement.blur()")
# audit trail
tw_go(app, "modif_logs"); wait(1.5)
ok(grepl("Food security indicators calculated", js("document.querySelector('#audit_1-tab_mod_log').innerText")), "audit trail entry")
cat("errors:", tw_errors(app), "\n")
app$stop()
