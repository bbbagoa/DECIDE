#' Draft registration form (XLSForm) from an adopted scorecard
#'
#' The adopted design becomes a draft KoboToolbox / ODK / MODA form for
#' household registration: identification (household ID, enumerator, the area
#' levels as cascading lists, GPS), one required question per criterion, and
#' hidden calculations that rebuild the vulnerability score exactly as
#' `apply_scorecard()` does, the eligibility at the adopted threshold, and two
#' vulnerability categories cut at the quartiles and quintiles of the score on
#' the design data. It is a draft: the CO rewrites questions (criteria built in
#' the calculator are asked as they are named) and checks it in the form
#' builder before use. TargetWise recomputes eligibility at Selection anyway;
#' the form's own score is a field check, hidden from enumerators.
#'
#' @param sc The adopted scorecard (`build_scorecard()` shape).
#' @param cuts list(quartiles = 3 cut points, quintiles = 4 cut points).
#' @param areas Optional data.frame of the area levels, top first, columns
#'   named as in the registration data; NULL asks them as text.
#' @param labels Named character: question label per criterion (default: its
#'   own label).
#' @param title Form title.
#' @return list(survey, choices, settings, readme) data frames.
#' @noRd
xlsform_draft <- function(sc, cuts = list(), areas = NULL, labels = character(0), title = "TargetWise household registration") {
  safe <- function(x) {
    n <- gsub("[^A-Za-z0-9_.-]", "_", as.character(x))
    n <- ifelse(grepl("^[A-Za-z_]", n), n, paste0("_", n))
    make.unique(n, sep = "_")
  }
  num <- function(x) fmt5(round(as.numeric(x), 5))
  rows <- list()
  add <- function(type, name = "", label = "", required = "", relevant = "", calculation = "",
                  constraint = "", choice_filter = "", hint = "", appearance = "") {
    rows[[length(rows) + 1]] <<- data.frame(type = type, name = name, label = label, hint = hint, required = required,
                                            relevant = relevant, constraint = constraint, calculation = calculation,
                                            choice_filter = choice_filter, appearance = appearance, stringsAsFactors = FALSE)
  }
  ch <- list()
  choice <- function(list_name, name, label, extra = NULL) {
    d <- data.frame(list_name = list_name, name = name, label = label, stringsAsFactors = FALSE)
    if (!is.null(extra)) d <- cbind(d, extra, stringsAsFactors = FALSE)
    ch[[length(ch) + 1]] <<- d
  }
  choice("yes_no", c("1", "0"), c("Yes", "No"))

  # metadata and consent
  add("start", "start"); add("end", "end"); add("today", "today"); add("deviceid", "deviceid")
  add("select_one yes_no", "consent", "Does the household agree to be registered?", required = "yes")
  ok <- "${consent} = '1'"

  # identification
  add("begin_group", "household", "Household identification", relevant = ok)
  add("text", "household_id", "Household ID", required = "yes")
  add("text", "enumerator", "Enumerator (name or code)", required = "yes")
  if (!is.null(areas) && ncol(areas)) {
    lv <- names(areas); qn <- safe(lv)
    a <- unique(areas[stats::complete.cases(areas), , drop = FALSE])
    for (k in seq_along(lv)) {
      parents <- seq_len(k - 1)
      d <- unique(a[, c(parents, k), drop = FALSE])
      codes <- function(v) gsub("[[:space:]]+", "_", trimws(as.character(v)))
      extra <- if (length(parents)) stats::setNames(as.data.frame(lapply(d[parents], codes), stringsAsFactors = FALSE), qn[parents]) else NULL
      choice(qn[k], codes(d[[k]]), as.character(d[[k]]), extra)
      flt <- if (length(parents)) paste(sprintf("%s = ${%s}", qn[parents], qn[parents]), collapse = " and ") else ""
      add(paste("select_one", qn[k]), qn[k], lv[k], required = "yes", choice_filter = flt)
    }
  } else {
    for (k in 1:3) add("text", paste0("admin", k), sprintf("Area level %d", k), required = if (k == 1) "yes" else "")
  }
  add("geopoint", "gps", "GPS location", appearance = "maps")
  add("end_group", "household")

  # the beneficiary: the head of household's identity (names mapped back by
  # the column mapping: hhh_sex, hhh_age, hh_size)
  bio <- c("hhh_first_name", "hhh_last_name", "hhh_other_name", "hhh_sex", "hhh_dob", "hhh_age",
           "hhh_marital_status", "hhh_phone", "hhh_id_type", "hhh_id_number", "hhh_photo", "hh_size",
           "has_alternate", "alternate", "alt_first_name", "alt_last_name", "alt_other_name", "alt_sex", "alt_age",
           "alt_relation", "alt_photo")
  add("begin_group", "beneficiary", "Head of household (beneficiary)", relevant = ok)
  add("text", "hhh_first_name", "First name", required = "yes")
  add("text", "hhh_last_name", "Surname (family name)", required = "yes")
  add("text", "hhh_other_name", "Third or other name (if any)")
  add("select_one sex", "hhh_sex", "Sex", required = "yes")
  add("date", "hhh_dob", "Date of birth (if known)", constraint = ". <= today()")
  add("integer", "hhh_age", "Age (years)", required = "yes", constraint = ". >= 10 and . <= 120",
      hint = "Completed years; from the date of birth when known")
  add("select_one marital", "hhh_marital_status", "Marital status", required = "yes")
  add("text", "hhh_phone", "Phone number (if any)", appearance = "numbers")
  add("select_one id_type", "hhh_id_type", "Identity document (if any)")
  add("text", "hhh_id_number", "Document number", relevant = "${hhh_id_type} != '' and ${hhh_id_type} != 'none'")
  add("image", "hhh_photo", "Photo of the head of household (optional)", appearance = "new-front")
  add("integer", "hh_size", "Number of household members (including the head)", required = "yes", constraint = ". >= 1 and . <= 50")
  add("end_group", "beneficiary")

  # an alternate recipient, who can collect the assistance for the household
  add("select_one yes_no", "has_alternate", "Is there an alternate recipient?", relevant = ok)
  alt <- "${has_alternate} = '1'"
  add("begin_group", "alternate", "Alternate recipient", relevant = alt)
  add("text", "alt_first_name", "First name", required = "yes")
  add("text", "alt_last_name", "Surname (family name)", required = "yes")
  add("text", "alt_other_name", "Third or other name (if any)")
  add("select_one sex", "alt_sex", "Sex", required = "yes")
  add("integer", "alt_age", "Age (years)", required = "yes", constraint = ". >= 15 and . <= 120")
  add("select_one relation", "alt_relation", "Relationship to the head of household")
  add("image", "alt_photo", "Photo of the alternate recipient (optional)", appearance = "new-front")
  add("end_group", "alternate")
  choice("relation", c("spouse", "child", "parent", "sibling", "other_relative", "not_related"),
         c("Spouse", "Son or daughter", "Father or mother", "Brother or sister", "Other relative", "Not related"))
  choice("sex", c("male", "female"), c("Male", "Female"))
  choice("marital", c("single", "married", "widowed", "divorced", "separated", "other"),
         c("Single", "Married or living together", "Widowed", "Divorced", "Separated", "Other"))
  choice("id_type", c("national_id", "voter_card", "passport", "refugee_id", "birth_certificate", "other", "none"),
         c("National ID card", "Voter card", "Passport", "Refugee / asylum seeker ID", "Birth certificate", "Other", "None"))

  # one question per criterion
  items <- sc$items
  cn <- safe(vapply(items, function(it) it$criterion, character(1)))
  taken <- cn %in% c(bio, "consent", "household_id", "enumerator", "gps", "start", "end", "today", "deviceid",
                     if (!is.null(areas)) safe(names(areas)) else paste0("admin", 1:3))
  cn[taken] <- paste0(cn[taken], "_crit")
  add("begin_group", "criteria", "Household characteristics", relevant = ok)
  for (i in seq_along(items)) {
    it <- items[[i]]
    lab <- if (it$criterion %in% names(labels)) labels[[it$criterion]] else it$label %||% it$criterion
    if (identical(it$type, "numeric")) add("decimal", cn[i], lab, required = "yes", constraint = ". >= 0")
    else add("select_one yes_no", cn[i], lab, required = "yes")
  }
  add("end_group", "criteria")

  # the score, as apply_scorecard() computes it (hidden calculations)
  rk <- is_ranking(sc); pm <- is_pmt(sc)
  pts <- paste0("pts_", cn)
  for (i in seq_along(items)) {
    it <- items[[i]]; w <- num(it$weight); q <- sprintf("${%s}", cn[i])
    excl <- identical(it$direction, "exclusion")
    f <- if (identical(it$type, "numeric")) sprintf("%s * %s%s", if (excl) "-1" else "1", q, paste0(" * ", w))
         else if (excl && rk) sprintf("if(%s = '1', 0, %s)", q, w)
         else sprintf("if(%s = '1', %s, 0)", q, if (excl) paste0("-", w) else w)
    if (identical(score_floor(sc), "items")) f <- sprintf("if((%s) < 0, 0, %s)", f, f)
    add("calculate", pts[i], calculation = f)
  }
  add("calculate", "vuln_score_raw", calculation = if (length(pts)) paste(sprintf("${%s}", pts), collapse = " + ") else "0")
  add("calculate", "vuln_score", calculation = if (pm || !identical(score_floor(sc), "total")) "${vuln_score_raw}" else "if(${vuln_score_raw} < 0, 0, ${vuln_score_raw})")
  add("calculate", "eligible", calculation = sprintf("if(${vuln_score} > %s, 1, 0)", num(sc$threshold %||% 0)))
  band <- function(cut) {
    cut <- sort(unique(cut[is.finite(cut)]))
    if (!length(cut)) return("1")
    out <- as.character(length(cut) + 1)
    for (k in rev(seq_along(cut))) out <- sprintf("if(${vuln_score} <= %s, %d, %s)", num(cut[k]), k, out)
    out
  }
  add("calculate", "vuln_quartile", calculation = band(cuts$quartiles))
  add("calculate", "vuln_quintile", calculation = band(cuts$quintiles))
  add("calculate", "scorecard_adopted", calculation = sprintf("'%s'", gsub("'", "", sc$adopted_at %||% sc$created %||% "")))

  survey <- do.call(rbind, rows)
  # both languages: English (the default) and French
  bil <- function(d, cols) {
    for (cl in intersect(cols, names(d))) {
      at <- match(cl, names(d))
      en <- d[[cl]]; frv <- ifelse(nzchar(en), xlsform_fr(en), "")
      d <- data.frame(d[seq_len(at - 1)], stats::setNames(data.frame(en, frv, stringsAsFactors = FALSE),
                                                          paste0(cl, c("::English (en)", "::French (fr)"))),
                      d[-seq_len(at)], check.names = FALSE, stringsAsFactors = FALSE)
    }
    d
  }
  survey <- bil(survey, c("label", "hint"))
  choices <- Reduce(function(a, b) { for (c in setdiff(names(b), names(a))) a[[c]] <- ""
                                     for (c in setdiff(names(a), names(b))) b[[c]] <- ""
                                     rbind(a, b[names(a)]) }, ch)
  choices <- bil(choices, "label")
  form_id <- paste0("targetwise_registration_", format(Sys.Date(), "%Y%m%d"))
  settings <- data.frame(form_title = title, form_id = form_id, version = format(Sys.time(), "%Y%m%d%H%M"),
                         default_language = "English (en)", stringsAsFactors = FALSE)
  kind <- if (pm) "proxy means test" else if (rk) "vulnerability ranking" else "scorecard"
  readme <- data.frame(
    Item = c("What this is", "Made from", "Score", "Eligible", "Vulnerability categories", "Questions", "Before use",
             "Enumerators", "Back in TargetWise"),
    Note = c("A DRAFT registration form for KoboToolbox, ODK or MODA, made by TargetWise from the adopted design. Adjust and correct it before use.",
             sprintf("The adopted %s (%d criteria, adopted %s, eligible when the score is above %s).", kind, length(items),
                     sc$adopted_at %||% "-", num(sc$threshold %||% 0)),
             "vuln_score rebuilds the design's score from the answers (points per criterion, exclusion criteria subtract; never below 0 except for a PMT).",
             "eligible = 1 when vuln_score is above the adopted threshold.",
             sprintf("vuln_quartile (1-4) and vuln_quintile (1-5): the score's quartile and quintile on the design data (cut points %s and %s); higher = more vulnerable.",
                     paste(num(sort(unique(cuts$quartiles))), collapse = ", "), paste(num(sort(unique(cuts$quintiles))), collapse = ", ")),
             "Household identification (consent, ID, enumerator, areas, GPS) and the head of household as beneficiary (names, sex, date of birth and age, marital status, phone, identity document, optional photo, household size), with an optional alternate recipient (names, sex, age, relationship, optional photo). One required question per criterion, named as in the design. Criteria built in the calculator are asked as they are named: rewrite them as the questions they come from, with calculations if needed. Yes/no answers are stored as 1/0.",
             "Upload it once to KoboToolbox / MODA or ODK's online converter to check it; this file was not validated by TargetWise.",
             "Keep the calculated score hidden from enumerators: a visible score invites answers that change it.",
             "Load the registration data in Beneficiary Selection: TargetWise recomputes the score and eligibility from the answers; the form's own score is a field check."),
    stringsAsFactors = FALSE)
  list(survey = survey, choices = choices, settings = settings, readme = readme)
}

#' French labels of the form's own questions and choices
#' @noRd
XLSFORM_FR <- c(
  "Does the household agree to be registered?" = "Le m\u00e9nage accepte-t-il d'\u00eatre enregistr\u00e9 ?",
  "Household identification" = "Identification du m\u00e9nage",
  "Household ID" = "Identifiant du m\u00e9nage",
  "Enumerator (name or code)" = "Enqu\u00eateur (nom ou code)",
  "GPS location" = "Position GPS",
  "Head of household (beneficiary)" = "Chef de m\u00e9nage (b\u00e9n\u00e9ficiaire)",
  "First name" = "Pr\u00e9nom",
  "Surname (family name)" = "Nom de famille",
  "Third or other name (if any)" = "Post-nom ou autre nom (le cas \u00e9ch\u00e9ant)",
  "Sex" = "Sexe",
  "Date of birth (if known)" = "Date de naissance (si connue)",
  "Age (years)" = "\u00c2ge (ann\u00e9es)",
  "Completed years; from the date of birth when known" = "Ann\u00e9es r\u00e9volues ; d'apr\u00e8s la date de naissance si elle est connue",
  "Marital status" = "\u00c9tat civil",
  "Phone number (if any)" = "Num\u00e9ro de t\u00e9l\u00e9phone (le cas \u00e9ch\u00e9ant)",
  "Identity document (if any)" = "Pi\u00e8ce d'identit\u00e9 (le cas \u00e9ch\u00e9ant)",
  "Document number" = "Num\u00e9ro du document",
  "Photo of the head of household (optional)" = "Photo du chef de m\u00e9nage (facultatif)",
  "Number of household members (including the head)" = "Nombre de membres du m\u00e9nage (chef compris)",
  "Is there an alternate recipient?" = "Y a-t-il un r\u00e9cipiendaire suppl\u00e9ant ?",
  "Alternate recipient" = "R\u00e9cipiendaire suppl\u00e9ant",
  "Relationship to the head of household" = "Lien avec le chef de m\u00e9nage",
  "Photo of the alternate recipient (optional)" = "Photo du r\u00e9cipiendaire suppl\u00e9ant (facultatif)",
  "Household characteristics" = "Caract\u00e9ristiques du m\u00e9nage",
  "Yes" = "Oui",
  "No" = "Non",
  "Male" = "Homme",
  "Female" = "Femme",
  "Single" = "C\u00e9libataire",
  "Married or living together" = "Mari\u00e9(e) ou en union libre",
  "Widowed" = "Veuf ou veuve",
  "Divorced" = "Divorc\u00e9(e)",
  "Separated" = "S\u00e9par\u00e9(e)",
  "Other" = "Autre",
  "National ID card" = "Carte d'identit\u00e9 nationale",
  "Voter card" = "Carte d'\u00e9lecteur",
  "Passport" = "Passeport",
  "Refugee / asylum seeker ID" = "Carte de r\u00e9fugi\u00e9 ou de demandeur d'asile",
  "Birth certificate" = "Acte de naissance",
  "None" = "Aucune",
  "Spouse" = "Conjoint(e)",
  "Son or daughter" = "Fils ou fille",
  "Father or mother" = "P\u00e8re ou m\u00e8re",
  "Brother or sister" = "Fr\u00e8re ou s\u0153ur",
  "Other relative" = "Autre parent",
  "Not related" = "Sans lien de parent\u00e9"
)

#' The French of an English label: the dictionary, "Area level n", else the
#' text itself (area names and criterion labels come from the data)
#' @noRd
xlsform_fr <- function(x) {
  out <- ifelse(x %in% names(XLSFORM_FR), XLSFORM_FR[x], x)
  lv <- grepl("^Area level [0-9]+$", x)
  out[lv] <- sub("^Area level ", "Niveau administratif ", x[lv])
  unname(out)
}

#' Write a draft XLSForm. Deliberately NOT read-only (the one exception to the
#' locked exports): the CO edits this form before using it.
#' @noRd
xlsform_write <- function(x, file) {
  wb <- openxlsx::createWorkbook()
  for (nm in c("survey", "choices", "settings")) xl_data_sheet(wb, nm, x[[nm]])
  xl_summary_sheet(wb, "About this draft", "Draft registration form (XLSForm)",
                   paste("Made by TargetWise on", fmt_date(), "- adjust it, then check it in the form builder"),
                   list("This draft" = stats::setNames(x$readme$Note, x$readme$Item)))
  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)   # not locked: the CO edits this form
  invisible(file)
}
