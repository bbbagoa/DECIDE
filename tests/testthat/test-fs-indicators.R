# WFP food security indicators (R/utils_fs_indicators.R), on WFP's own sample
# surveys (fixtures/wfp, from github.com/WFP-VAM/RAMResourcesScripts/Static).
wfp <- function(n) utils::read.csv(testthat::test_path("fixtures", "wfp", n), na.strings = c("n/a", ""))

test_that("FCS follows WFP's weights, thresholds and data rules", {
  d <- wfp("FCS_Sample_Survey.csv")
  expect_true(fsi_status(d)$fcs$ok)
  r <- fsi_compute(d, "fcs")
  w <- c(FCSStap = 2, FCSPulse = 3, FCSDairy = 4, FCSPr = 4, FCSVeg = 1, FCSFruit = 1, FCSFat = 0.5, FCSSugar = 0.5)
  expect_equal(r$df$FCS, as.vector(as.matrix(d[names(w)]) %*% w))
  expect_equal(r$df$FCS[1], 49)
  expect_equal(r$df$FCSCat21, c("Poor", "Borderline", "Acceptable")[findInterval(r$df$FCS, c(21, 35), left.open = TRUE) + 1])
  r28 <- fsi_compute(d, "fcs", fcs_threshold = "28")
  expect_true("FCSCat28" %in% names(r28$df))
  # condiments are not counted; a day count outside 0-7 is missing, not 7
  d2 <- d[1:2, ]; d2$FCSCond <- 7; d2$FCSStap[2] <- 9
  r2 <- fsi_compute(d2, "fcs")
  expect_equal(r2$df$FCS[1], 49)
  expect_true(is.na(r2$df$FCS[2]))
  # staples from cereals and tubers when there is no FCSStap
  d3 <- d[1, ]; d3$FCSStapCer <- 3; d3$FCSStapTub <- 5; d3$FCSStap <- NULL
  expect_true(fsi_status(d3)$fcs$ok)
  expect_equal(fsi_compute(d3, "fcs")$df$FCS, 49 - 2 * 7 + 2 * 5)
})

test_that("rCSI and its IPC phases", {
  d <- wfp("RCSI_Sample_Survey.csv")
  r <- fsi_compute(d, "rcsi")
  expect_equal(r$df$rCSI, d$rCSILessQlty + 2 * d$rCSIBorrow + d$rCSIMealNb + d$rCSIMealSize + 3 * d$rCSIMealAdult)
  expect_equal(r$df$rCSI_IPC[r$df$rCSI <= 3], rep("Phase 1 (0-3)", sum(r$df$rCSI <= 3)))
  expect_equal(r$df$rCSI_Phase3plus, ifelse(r$df$rCSI >= 19, "Yes", "No"))
})

test_that("LCS: the most severe strategy used or exhausted, codes or labels", {
  d <- wfp("LHCS_FS_Sample_Survey.csv")
  r <- fsi_compute(d, "lcs_fs")
  hit <- function(p) Reduce(`|`, lapply(d[grepl(p, names(d))], function(x) x %in% c(20, 30)))
  expect_equal(r$df$Max_coping_behaviourFS,
               ifelse(hit("^Lcs_em_"), 4, ifelse(hit("^Lcs_crisis_"), 3, ifelse(hit("^Lcs_stress_"), 2, 1))))
  # the same answers as labels (an SPSS / form export read as text)
  lab <- d
  for (k in grep("^Lcs_", names(lab))) lab[[k]] <- c(`10` = "No, because we did not need to",
    `20` = "No, because we already sold those assets or have engaged in this activity within the last 12 months and cannot continue",
    `30` = "Yes", `9999` = "Not applicable")[as.character(lab[[k]])]
  expect_equal(fsi_compute(lab, "lcs_fs")$df$Max_coping_behaviourFS, r$df$Max_coping_behaviourFS)
  # essential needs, and the food version for the households buying food
  e <- wfp("LHCS_EN_Sample_Survey.csv")
  re <- fsi_compute(e, "lcs_en")
  expect_equal(re$df$Max_coping_behaviourFS, ifelse(e$LhCSIEnAccess.1 %in% 1, re$df$Max_coping_behaviourEN, 1))
})

test_that("CARI from its parts (FES and ECMEN versions), rounded as Stata does", {
  d <- wfp("CARI_Sample_Data.csv")
  st <- fsi_status(d)
  expect_true(st$cari$ok)
  expect_false(st$fcs$ok)
  r <- fsi_compute(d, "cari")
  fcs4 <- c(4, 3, 1)[d$FCSCat21]; fcs4[fcs4 == 1 & d$rCSI >= 4] <- 2
  cari <- floor((fcs4 + (d$Max_coping_behaviourFS + d$Foodexp_4pt) / 2) / 2 + 0.5)
  lab <- c("Food secure", "Marginally food secure", "Moderately food insecure", "Severely food insecure")
  expect_equal(r$df$CARI_FES, lab[cari])
  expect_equal(r$df$CARI_FES_2class, ifelse(cari >= 3, "Food insecure", "Food secure"))
  expect_false("CARI_FES_2class" %in% names(fsi_compute(d, "cari", cari_binary = FALSE)$df))
  econ <- ifelse(d$ECMEN_exclAsst == 1, 1, ifelse(d$ECMEN_exclAsst_SMEB == 1, 3, 4))
  cari_e <- floor((fcs4 + (d$Max_coping_behaviourFS + econ) / 2) / 2 + 0.5)
  expect_equal(fsi_compute(d, "cari", cari_version = "ECMEN")$df$CARI_ECMEN, lab[cari_e])
})

test_that("FES: monthly food share, gifts and own production counted, 4 classes", {
  n <- 3
  d <- data.frame(id = 1:n)
  for (i in FES_FOOD) for (s in c("Purch", "GiftAid", "Own")) d[[fes_name(i, s)]] <- 0
  for (i in FES_NF_1M) d[[fes_name(i, "Purch", TRUE, "1M")]] <- 0
  for (i in FES_NF_6M) d[[fes_name(i, "Purch", TRUE, "6M")]] <- 0
  expect_true(fsi_status(d)$fes$ok)
  expect_true(length(fsi_status(d)$fes$optional) > 0)   # non-food gifts absent: counted as 0
  d$HHExpFCer_Purch_MN_7D <- c(70, 70, 0); d$HHExpFCer_Own_MN_7D <- c(0, 70, 0)
  d$HHExpNFHyg_Purch_MN_1M <- c(300, 100, 0); d$HHExpNFRent_Purch_MN_6M <- c(0, 600, 0)
  r <- fsi_compute(d, "fes")
  f <- c(300, 600, 0); nf <- c(300, 200, 0)
  expect_equal(r$df$FES, c(f[1:2] / (f[1:2] + nf[1:2]), NA))
  expect_equal(r$df$Foodexp_4pt, c(2, 4, NA))
  # one purchase item missing: FES is not offered
  d$HHExpFOut_Purch_MN_7D <- NULL
  expect_false(fsi_status(d)$fes$ok)
  expect_true("HHExpFOut_Purch_MN_7D" %in% fsi_status(d)$fes$missing)
})

test_that("columns found under a form's group path, and indicators kept out of the criteria", {
  d <- wfp("RCSI_Sample_Survey.csv")
  names(d) <- sub("^rCSI", "grp_csi/rCSI", names(d))
  expect_true(fsi_status(d)$rcsi$ok)
  out <- unlist(fsi_outputs())
  expect_true(all(out %in% outcome_like_columns(out) | !is.na(unobservable_reason(out))))
})
