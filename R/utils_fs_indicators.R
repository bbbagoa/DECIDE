#' WFP food security indicators: FCS, rCSI, LCS (FS and EN), FES, ECMEN, CARI
#'
#' Calculated as in WFP's RAM standardized scripts (the October 2025 Stata
#' versions, https://github.com/WFP-VAM/RAMResourcesScripts/tree/main/Indicators),
#' from the variables named in the WFP data dictionary. An indicator is offered
#' only when its variables are in the data (`fsi_status()`); `fsi_compute()`
#' adds the columns WFP's scripts create, under their names, plus a yes / no
#' version of each that Targeting Design can take as its outcome.
#' @name fs_indicators
NULL

#' Where the definitions come from (shown in the dialog and the audit trail)
#' @noRd
FSI_SOURCE <- "https://github.com/WFP-VAM/RAMResourcesScripts/tree/main/Indicators"

FCS_GROUPS <- c(FCSStap = 2, FCSPulse = 3, FCSDairy = 4, FCSPr = 4, FCSVeg = 1, FCSFruit = 1, FCSFat = 0.5, FCSSugar = 0.5)
RCSI_ITEMS <- c(rCSILessQlty = 1, rCSIBorrow = 2, rCSIMealNb = 1, rCSIMealSize = 1, rCSIMealAdult = 3)
FES_FOOD <- c("Cer", "Tub", "Puls", "Veg", "Frt", "AnimMeat", "AnimFish", "Fats", "Dairy", "Egg", "Sgr", "Cond", "Bev", "Out")
FES_NF_1M <- c("Hyg", "Transp", "Fuel", "Wat", "Elec", "Energ", "DwelSer", "Phone", "Recr", "AlcTobac")
FES_NF_6M <- c("MedServ", "MedGood", "Cloth", "EduFee", "EduGood", "Rent", "HHMaint", "HHSoft")

#' The indicators offered, in the order shown
#' @noRd
FSI_DEFS <- list(
  fcs = list(label = "Food Consumption Score (FCS)",
             about = "Days in the past 7 that the household ate each of 8 food groups, weighted by nutritional value."),
  rcsi = list(label = "Reduced Coping Strategies Index (rCSI)",
              about = "Five food-based coping strategies in the past 7 days, weighted by severity."),
  lcs_fs = list(label = "Livelihood Coping Strategies - food security (LCS-FS)",
                about = "The most severe livelihood coping strategy (stress, crisis, emergency) used in the past 30 days to cover food needs."),
  lcs_en = list(label = "Livelihood Coping Strategies - essential needs (LCS-EN)",
                about = "The same, to cover essential needs."),
  fes = list(label = "Food Expenditure Share (FES)",
             about = "Food's share of the household's monthly expenditure, including the value of food from gifts, aid and own production."),
  cari = list(label = "Consolidated Approach to Reporting Indicators of food security (CARI)",
              about = "Combines FCS (with rCSI) for current status with LCS-FS and FES (or ECMEN) for coping capacity.")
)

# -------------------------------------------------------------- finding columns

#' The data's column for a dictionary name, or NA
#'
#' Exact name first (case aside), then a name ending in it after a group path
#' (ODK / Kobo exports: "food/FCSStap", "grp_fcs.FCSStap").
#' @noRd
fsi_col <- function(cols, name) {
  hit <- cols[tolower(cols) == tolower(name)]
  if (length(hit)) return(hit[1])
  esc <- gsub("([.()|^$*+?\\[\\]{}])", "\\\\\\1", name, perl = TRUE)
  hit <- cols[grepl(paste0("[/.:-]", esc, "$"), cols, ignore.case = TRUE, perl = TRUE)]
  if (length(hit)) hit[1] else NA_character_
}

#' Columns of one LCS severity, e.g. "Lcs_stress_" (any strategy the CO chose)
#' @noRd
fsi_lcs_cols <- function(cols, prefix) {
  cols[grepl(paste0("(^|[/.:-])", prefix, "[A-Za-z0-9]"), cols, ignore.case = TRUE, perl = TRUE)]
}

#' FES / ECMEN column names for an item and source
#' @noRd
fes_name <- function(item, src, nf = FALSE, recall = "7D") {
  if (nf) sprintf("HHExpNF%s_%s_MN_%s", item, src, recall) else sprintf("HHExpF%s_%s_MN_7D", item, src)
}

# ------------------------------------------------------------------- values

#' Numbers from a column (text numbers too); anything else NA
#' @noRd
fsi_num <- function(x) suppressWarnings(as_number(x))

#' LCS answers as WFP codes: 10 no need, 20 already exhausted, 30 yes, 9999 n/a
#'
#' Numeric codes stay; answer labels (an SPSS / Stata or form export read as
#' text, in English or French) are read back to the codes.
#' @noRd
fsi_lcs_code <- function(x) {
  n <- fsi_num(x)
  if (all(is.na(n) == is.na(x))) return(n)
  t <- tolower(trimws(as.character(x)))
  out <- n
  ex <- grepl("already|exhaust|cannot continue|d\u00e9j\u00e0|epuis|\u00e9puis", t)
  out[is.na(n) & ex] <- 20
  out[is.na(n) & !ex & grepl("^(yes|oui|si|s\u00ed)\\b", t)] <- 30
  out[is.na(n) & !ex & grepl("did not need|not need|pas besoin|^no\\b|^non\\b", t)] <- 10
  out[is.na(n) & grepl("not applicable|non applicable|n/a|^na$", t)] <- 9999
  out
}

#' FCS category codes (1 poor, 2 borderline, 3 acceptable) from codes or labels
#' @noRd
fsi_fcs_cat_code <- function(x) {
  n <- fsi_num(x)
  t <- tolower(trimws(as.character(x)))
  n[is.na(n) & grepl("^poor|^pauvre|^faible", t)] <- 1
  n[is.na(n) & grepl("^borderline|^limite", t)] <- 2
  n[is.na(n) & grepl("^acceptable", t)] <- 3
  n[!n %in% 1:3] <- NA
  n
}

#' LCS maximum (1 none, 2 stress, 3 crisis, 4 emergency) from codes or labels
#' @noRd
fsi_lcs_max_code <- function(x) {
  n <- fsi_num(x)
  t <- tolower(as.character(x))
  n[is.na(n) & grepl("emergenc|urgence", t)] <- 4
  n[is.na(n) & grepl("crisis|crise", t)] <- 3
  n[is.na(n) & grepl("stress", t)] <- 2
  n[is.na(n) & grepl("none|no coping|not apply|aucune|pas de", t)] <- 1
  n[!n %in% 1:4] <- NA
  n
}

#' Stata's round(): halves go up (R's round() goes to the even number)
#' @noRd
round_half_up <- function(x) floor(x + 0.5)

yes_no <- function(x) ifelse(is.na(x), NA_character_, ifelse(x, "Yes", "No"))

# ------------------------------------------------------------------- status

#' What can be calculated from these data, and what is missing
#'
#' @param df The assessment data.
#' @return Named list (one per indicator in `FSI_DEFS`): `ok`, `found` (the
#'   data's columns used), `missing` (dictionary names not found), `optional`
#'   (used when present, counted as 0 otherwise), `note`, `outputs` (columns it
#'   writes) and `replace` (those already in the data).
#' @noRd
fsi_status <- function(df) {
  cols <- names(df)
  out <- list()
  have <- function(n) !is.na(fsi_col(cols, n))
  # FCS: the eight groups (staples as one column, or cereals and tubers apart)
  miss <- character(0)
  for (g in names(FCS_GROUPS)) {
    if (g == "FCSStap" && !have(g) && have("FCSStapCer") && have("FCSStapTub")) next
    if (!have(g)) miss <- c(miss, g)
  }
  out$fcs <- list(ok = !length(miss), missing = miss, optional = character(0),
                  note = if (!have("FCSStap") && have("FCSStapCer")) "Staples from FCSStapCer and FCSStapTub (the larger of the two)." else NULL)
  miss <- names(RCSI_ITEMS)[!vapply(names(RCSI_ITEMS), have, logical(1))]
  out$rcsi <- list(ok = !length(miss), missing = miss, optional = character(0))
  for (k in c("fs", "en")) {
    pre <- if (k == "fs") "Lcs_" else "LcsEN_"
    lv <- c(stress = "stress_", crisis = "crisis_", emergency = "em_")
    got <- lapply(lv, function(p) fsi_lcs_cols(cols, paste0(pre, p)))
    miss <- paste0(pre, lv[!lengths(got)], "...")
    n <- lengths(got)
    out[[paste0("lcs_", k)]] <- list(ok = all(n > 0), missing = miss, optional = character(0),
      note = if (all(n > 0)) sprintf("%d stress, %d crisis and %d emergency strategies found%s.", n[1], n[2], n[3],
                                      if (any(n != c(4, 3, 3))) " (the standard module asks 4, 3 and 3)" else "") else NULL)
  }
  # FES: every food item and non-food item, at least as purchases
  need <- c(fes_name(FES_FOOD, "Purch"), fes_name(FES_NF_1M, "Purch", TRUE, "1M"), fes_name(FES_NF_6M, "Purch", TRUE, "6M"))
  opt <- c(fes_name(FES_FOOD, "GiftAid"), fes_name(FES_FOOD, "Own"),
           fes_name(FES_NF_1M, "GiftAid", TRUE, "1M"), fes_name(FES_NF_6M, "GiftAid", TRUE, "6M"))
  miss <- need[!vapply(need, have, logical(1))]
  out$fes <- list(ok = !length(miss), missing = miss, optional = opt[!vapply(opt, have, logical(1))])
  # CARI: its parts, calculated now or already in the data
  parts <- list(
    fcs = out$fcs$ok || have("FCSCat21") || have("FCSCat28"),
    rcsi = out$rcsi$ok || have("rCSI"),
    lcs = out$lcs_fs$ok || have("Max_coping_behaviourFS"),
    fes = out$fes$ok || have("Foodexp_4pt"),
    ecmen = (have("ECMEN_exclAsst") && have("ECMEN_exclAsst_SMEB")) || out$fes$ok
  )
  miss <- c(if (!parts$fcs) "FCS (or FCSCat21 / FCSCat28)", if (!parts$rcsi) "rCSI",
            if (!parts$lcs) "LCS-FS (or Max_coping_behaviourFS)",
            if (!parts$fes && !parts$ecmen) "FES (or Foodexp_4pt) or ECMEN")
  out$cari <- list(ok = !length(miss), missing = miss, optional = character(0), parts = parts)
  outputs <- fsi_outputs()
  for (k in names(out)) {
    out[[k]]$outputs <- outputs[[k]]
    out[[k]]$replace <- intersect(outputs[[k]], cols)
  }
  out
}

#' Columns each indicator writes (CARI: both versions listed)
#' @noRd
fsi_outputs <- function(fcs_cat = "FCSCat21", cari = c("FES", "ECMEN")) {
  list(fcs = c("FCS", fcs_cat, "FCS_PoorBorderline"),
       rcsi = c("rCSI", "rCSI_IPC", "rCSI_Phase3plus"),
       lcs_fs = c("Max_coping_behaviourFS", "LCSFS_CrisisEmergency"),
       lcs_en = c("Max_coping_behaviourEN", "LCSEN_CrisisEmergency"),
       fes = c("HHExpF_1M", "HHExpNF_1M", "HHExp_1M", "FES", "Foodexp_4pt", "FES_High"),
       cari = unlist(lapply(cari, function(v) c(paste0("CARI_", v), paste0("CARI_", v, "_2class")))))
}

# ------------------------------------------------------------------ compute

#' The indicators, as columns
#'
#' @param df The assessment data.
#' @param which Indicator ids (names of `FSI_DEFS`).
#' @param fcs_threshold "21" (21 / 35, the default) or "28" (28 / 42, where
#'   sugar and oil are eaten nearly every day).
#' @param cari_version "FES" or "ECMEN".
#' @param meb,smeb Minimum (and survival) expenditure basket per person per
#'   month, for ECMEN.
#' @param hh_size Household size column, for ECMEN.
#' @param cari_binary Also write CARI in two classes: "Food insecure"
#'   (moderately or severely food insecure) and "Food secure" (food secure or
#'   marginally food secure), the usual outcome for a scorecard.
#' @return list(df, created (data frame: name, definition), labels (named
#'   character), summary (per indicator: a data frame category / households),
#'   notes (character)).
#' @noRd
fsi_compute <- function(df, which, fcs_threshold = "21", cari_version = "FES", meb = NA, smeb = NA, hh_size = NULL,
                        cari_binary = TRUE) {
  cols <- names(df)
  col <- function(n) { k <- fsi_col(cols, n); if (is.na(k)) NULL else df[[k]] }
  n <- nrow(df)
  created <- list(); labels <- character(0); summary <- list(); notes <- character(0)
  put <- function(name, value, label, definition) {
    df[[name]] <<- value
    labels[name] <<- label
    created[[length(created) + 1]] <<- data.frame(name = name, definition = definition, stringsAsFactors = FALSE)
  }
  tab <- function(x, levels = NULL) {
    f <- if (is.null(levels)) factor(x) else factor(x, levels = levels)
    t <- table(f, useNA = "ifany")
    data.frame(category = ifelse(is.na(names(t)), "Missing", names(t)), households = as.integer(t), stringsAsFactors = FALSE)
  }
  src <- sprintf("WFP RAM standardized script (%s)", FSI_SOURCE)
  fcs4 <- NULL; rcsi <- NULL; lcs_max <- NULL; fes4 <- NULL

  if ("fcs" %in% which) {
    day <- function(g) {
      v <- if (g == "FCSStap" && is.null(col(g))) pmax(fsi_num(col("FCSStapCer")), fsi_num(col("FCSStapTub")), na.rm = TRUE) else fsi_num(col(g))
      v[!is.na(v) & (v < 0 | v >= 8)] <- NA   # days outside 0-7 are errors, not 7
      v
    }
    fcs <- Reduce(`+`, lapply(names(FCS_GROUPS), function(g) day(g) * FCS_GROUPS[[g]]))
    fcs[!is.na(fcs) & (fcs < 0 | fcs >= 113)] <- NA
    lo <- if (identical(as.character(fcs_threshold), "28")) c(28, 42) else c(21, 35)
    catname <- paste0("FCSCat", lo[1])
    cat <- ifelse(is.na(fcs), NA, ifelse(fcs <= lo[1], 1, ifelse(fcs <= lo[2], 2, 3)))
    lab <- c("Poor", "Borderline", "Acceptable")
    put("FCS", fcs, "Food Consumption Score", paste0("FCS = 2 x staples + 3 x pulses + 4 x dairy + 4 x meat, fish, eggs + vegetables + fruit + 0.5 x oil + 0.5 x sugar (", src, ")"))
    put(catname, lab[cat], sprintf("FCS categories (thresholds %d / %d)", lo[1], lo[2]),
        sprintf("Poor: FCS <= %d; Borderline: %d < FCS <= %d; Acceptable: FCS > %d", lo[1], lo[1], lo[2], lo[2]))
    put("FCS_PoorBorderline", yes_no(cat %in% 1:2 & !is.na(cat)), "Poor or borderline food consumption",
        sprintf("Yes when FCS <= %d (poor or borderline)", lo[2]))
    df$FCS_PoorBorderline[is.na(cat)] <- NA
    summary$fcs <- tab(lab[cat], lab)
    fl <- sum(fcs < 14, na.rm = TRUE); fh <- sum(fcs > 100, na.rm = TRUE)
    if (fl + fh) notes <- c(notes, sprintf("FCS: %d household(s) below 14 and %d above 100, values WFP flags for a data quality check.", fl, fh))
    fcs4 <- c(4, 3, 1)[cat]
  } else {
    k <- fsi_col(cols, paste0("FCSCat", if (identical(as.character(fcs_threshold), "28")) "28" else "21"))
    if (is.na(k)) k <- fsi_col(cols, "FCSCat21")
    if (is.na(k)) k <- fsi_col(cols, "FCSCat28")
    if (!is.na(k)) fcs4 <- c(4, 3, 1)[fsi_fcs_cat_code(df[[k]])]
  }

  if ("rcsi" %in% which) {
    it <- function(v) { x <- fsi_num(col(v)); x[!is.na(x) & (x < 0 | x > 7)] <- NA; x }
    rcsi <- Reduce(`+`, lapply(names(RCSI_ITEMS), function(v) it(v) * RCSI_ITEMS[[v]]))
    rcsi[!is.na(rcsi) & (rcsi < 0 | rcsi > 56)] <- NA
    ph <- c("Phase 1 (0-3)", "Phase 2 (4-18)", "Phase 3+ (19 or more)")
    pc <- ifelse(is.na(rcsi), NA, ifelse(rcsi <= 3, 1, ifelse(rcsi <= 18, 2, 3)))
    put("rCSI", rcsi, "Reduced Coping Strategies Index",
        paste0("rCSI = less preferred food + 2 x borrowed food + fewer meals + smaller portions + 3 x adults ate less (", src, ")"))
    put("rCSI_IPC", ph[pc], "rCSI, IPC classification", "Phase 1: 0-3; Phase 2: 4-18; Phase 3+: 19 or more")
    put("rCSI_Phase3plus", yes_no(rcsi >= 19), "rCSI of 19 or more (IPC Phase 3+)", "Yes when rCSI >= 19")
    summary$rcsi <- tab(ph[pc], ph)
    fl <- sum(rcsi <= 3, na.rm = TRUE); fh <- sum(rcsi >= 42, na.rm = TRUE)
    if (fh) notes <- c(notes, sprintf("rCSI: %d household(s) at 42 or more, values WFP flags for a check unless the population is generally food insecure.", fh))
  } else {
    r <- col("rCSI")
    if (!is.null(r)) rcsi <- fsi_num(r)
  }

  lcs <- function(pre, tag) {
    lv <- list(stress = "stress_", crisis = "crisis_", emergency = "em_")
    used <- lapply(lv, function(p) {
      cs <- fsi_lcs_cols(cols, paste0(pre, p))
      if (!length(cs)) return(rep(FALSE, n))
      Reduce(`|`, lapply(cs, function(cl) fsi_lcs_code(df[[cl]]) %in% c(20, 30)))
    })
    mx <- ifelse(used$emergency, 4, ifelse(used$crisis, 3, ifelse(used$stress, 2, 1)))
    lab <- c("None", "Stress", "Crisis", "Emergency")
    list(max = mx, lab = lab)
  }
  if ("lcs_fs" %in% which) {
    r <- lcs("Lcs_", "FS")
    put("Max_coping_behaviourFS", r$max, "Most severe livelihood coping strategy, food (1 none, 2 stress, 3 crisis, 4 emergency)",
        paste0("Highest severity among the strategies used or already exhausted (answers 20 or 30) in the past 30 days to cover food needs (", src, ")"))
    put("LCSFS_CrisisEmergency", yes_no(r$max >= 3), "Crisis or emergency livelihood coping (food)", "Yes when Max_coping_behaviourFS is 3 or 4")
    summary$lcs_fs <- tab(r$lab[r$max], r$lab)
    lcs_max <- r$max
  } else {
    m <- col("Max_coping_behaviourFS")
    if (!is.null(m)) lcs_max <- fsi_lcs_max_code(m)
  }
  if ("lcs_en" %in% which) {
    r <- lcs("LcsEN_", "EN")
    put("Max_coping_behaviourEN", r$max, "Most severe livelihood coping strategy, essential needs (1 none, 2 stress, 3 crisis, 4 emergency)",
        paste0("Highest severity among the strategies used or already exhausted (answers 20 or 30) in the past 30 days to cover essential needs (", src, ")"))
    put("LCSEN_CrisisEmergency", yes_no(r$max >= 3), "Crisis or emergency livelihood coping (essential needs)", "Yes when Max_coping_behaviourEN is 3 or 4")
    summary$lcs_en <- tab(r$lab[r$max], r$lab)
    # WFP's script: the food version from the essential-needs module, for the
    # households whose coping was to buy food (LhCSIEnAccess1), when no LCS-FS
    acc <- fsi_col(cols, "LhCSIEnAccess1")
    if (is.na(acc)) acc <- fsi_col(cols, "LhCSIEnAccess.1")
    if (is.null(lcs_max) && !is.na(acc)) {
      fs <- ifelse(fsi_num(df[[acc]]) %in% 1, r$max, 1)
      put("Max_coping_behaviourFS", fs, "Most severe livelihood coping strategy, food, from the essential-needs module",
          "Max_coping_behaviourEN for households that adopted strategies to buy food (LhCSIEnAccess1), else 1 (WFP RAM script)")
      lcs_max <- fs
    }
  }

  fes_parts <- NULL
  if ("fes" %in% which || ("cari" %in% which && identical(cari_version, "ECMEN") && is.null(col("ECMEN_exclAsst")))) {
    z <- function(name) { v <- col(name); if (is.null(v)) rep(0, n) else { x <- fsi_num(v); x[is.na(x)] <- 0; x } }
    food <- function(s) Reduce(`+`, lapply(FES_FOOD, function(i) z(fes_name(i, s)))) * 30 / 7
    nf <- function(s) Reduce(`+`, lapply(FES_NF_1M, function(i) z(fes_name(i, s, TRUE, "1M")))) +
      Reduce(`+`, lapply(FES_NF_6M, function(i) z(fes_name(i, s, TRUE, "6M")))) / 6
    fes_parts <- list(food_purch = food("Purch"), food_gift = food("GiftAid"), food_own = food("Own"),
                      nf_purch = nf("Purch"), nf_gift = nf("GiftAid"))
  }
  if ("fes" %in% which) {
    f1 <- fes_parts$food_purch + fes_parts$food_gift + fes_parts$food_own
    nf1 <- fes_parts$nf_purch + fes_parts$nf_gift
    tot <- f1 + nf1
    fes <- ifelse(tot > 0, f1 / tot, NA)
    f4 <- ifelse(is.na(fes), NA, ifelse(fes < 0.5, 1, ifelse(fes < 0.65, 2, ifelse(fes < 0.75, 3, 4))))
    lab <- c("Low (<50%)", "Medium (50-65%)", "High (65-75%)", "Very high (75% or more)")
    put("HHExpF_1M", f1, "Monthly food expenditure and consumption value", "Purchases, gifts / aid and own production of 14 food groups over 7 days, x 30/7")
    put("HHExpNF_1M", nf1, "Monthly non-food expenditure", "30-day items + 6-month items / 6, purchases and gifts / aid")
    put("HHExp_1M", tot, "Monthly total expenditure", "HHExpF_1M + HHExpNF_1M")
    put("FES", fes, "Food expenditure share", paste0("FES = HHExpF_1M / HHExp_1M (", src, ")"))
    put("Foodexp_4pt", f4, "Food expenditure share, 4 classes (1 <50%, 2 50-65%, 3 65-75%, 4 75%+)", "1: FES < 0.50; 2: < 0.65; 3: < 0.75; 4: 0.75 or more")
    put("FES_High", yes_no(fes >= 0.65), "Food expenditure share of 65% or more", "Yes when FES >= 0.65")
    summary$fes <- tab(lab[f4], lab)
    if (sum(tot == 0, na.rm = TRUE)) notes <- c(notes, sprintf("FES: %d household(s) with no expenditure at all: FES left empty.", sum(tot == 0, na.rm = TRUE)))
    fes4 <- f4
  } else {
    v <- col("Foodexp_4pt")
    if (!is.null(v)) fes4 <- fsi_num(v)
  }

  if ("cari" %in% which) {
    ver <- if (identical(cari_version, "ECMEN")) "ECMEN" else "FES"
    if (is.null(fcs4) || is.null(rcsi) || is.null(lcs_max)) stop("CARI needs FCS categories, rCSI and LCS-FS.")
    fcs4b <- fcs4
    fcs4b[!is.na(fcs4b) & fcs4b == 1 & !is.na(rcsi) & rcsi >= 4] <- 2   # acceptable, but rCSI of 4 or more
    if (ver == "FES") {
      if (is.null(fes4)) stop("CARI (FES) needs the food expenditure share.")
      econ <- fes4
    } else {
      above <- col("ECMEN_exclAsst"); above_s <- col("ECMEN_exclAsst_SMEB")
      if (is.null(above) || is.null(above_s)) {
        if (is.null(fes_parts)) stop("CARI (ECMEN) needs the expenditure variables or ECMEN_exclAsst.")
        if (!is.finite(meb) || !is.finite(smeb)) stop("CARI (ECMEN) needs the MEB and the SMEB.")
        size <- if (length(hh_size) && hh_size %in% cols) fsi_num(df[[hh_size]]) else NULL
        if (is.null(size)) stop("CARI (ECMEN) needs the household size.")
        # expenditure without assistance: purchases and own production, less the
        # cash assistance consumed (WFP's ECMEN excluding assistance)
        exp <- fes_parts$food_purch + fes_parts$food_own + fes_parts$nf_purch
        cbt <- function(nm) { v <- col(nm); if (is.null(v)) rep(0, n) else { x <- fsi_num(v); x[is.na(x)] <- 0; x } }
        rec <- (cbt("HHAsstWFPCBTRecTot") + cbt("HHAsstUNNGOCBTRecTot")) / 3
        share <- col("HHAsstCBTCShare")
        med <- if (is.null(share)) NA else stats::median(fsi_num(share), na.rm = TRUE)
        cons <- if (is.finite(med)) rec * med / 100 else rep(0, n)
        pc <- ifelse(size > 0, (exp - cons) / size, NA)
        above <- as.integer(pc >= meb); above_s <- as.integer(pc >= smeb)
        put("PCExp_ECMEN", pc, "Monthly expenditure per person, excluding assistance (ECMEN)",
            "(food purchases and own production + non-food purchases - cash assistance consumed) / household size")
        put("ECMEN_exclAsst", above, sprintf("Expenditure per person at or above the MEB (%s)", format(meb, big.mark = ",")), "1 when PCExp_ECMEN >= MEB")
        put("ECMEN_exclAsst_SMEB", above_s, sprintf("Expenditure per person at or above the SMEB (%s)", format(smeb, big.mark = ",")), "1 when PCExp_ECMEN >= SMEB")
        if (!is.finite(med) && any(rec > 0)) notes <- c(notes, "ECMEN: no HHAsstCBTCShare column, so no cash assistance was deducted.")
      }
      a <- fsi_num(above); s <- fsi_num(above_s)
      econ <- ifelse(is.na(a), NA, ifelse(a == 1, 1, ifelse(!is.na(s) & s == 1, 3, 4)))
    }
    coping <- rowMeans(cbind(lcs_max, econ), na.rm = TRUE)
    coping[is.nan(coping)] <- NA
    cari <- round_half_up(rowMeans(cbind(fcs4b, coping), na.rm = TRUE))
    cari[is.nan(cari)] <- NA
    lab <- c("Food secure", "Marginally food secure", "Moderately food insecure", "Severely food insecure")
    nm <- paste0("CARI_", ver)
    put(nm, lab[cari], sprintf("CARI food security classification (%s)", ver),
        sprintf("Mean of current status (FCS, with rCSI) and coping capacity (mean of LCS-FS and %s), rounded (%s)", if (ver == "FES") "FES" else "ECMEN", src))
    if (isTRUE(cari_binary)) {
      put(paste0(nm, "_2class"), ifelse(is.na(cari), NA_character_, ifelse(cari >= 3, "Food insecure", "Food secure")),
          sprintf("CARI (%s) in two classes: food insecure (moderately or severely) or food secure", ver),
          sprintf("Food insecure when %s is moderately or severely food insecure (3 or 4); food secure otherwise (1 or 2)", nm))
      summary$cari_binary <- tab(ifelse(is.na(cari), NA, ifelse(cari >= 3, "Food insecure", "Food secure")), c("Food insecure", "Food secure"))
    }
    summary$cari <- tab(lab[cari], lab)
  }
  created <- if (length(created)) do.call(rbind, created) else data.frame(name = character(0), definition = character(0))
  created <- created[!duplicated(created$name, fromLast = TRUE), , drop = FALSE]
  list(df = df, created = created, labels = labels, summary = summary, notes = notes)
}
