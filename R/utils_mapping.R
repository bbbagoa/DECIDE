#' Variable mapping that works for any country's data
#'
#' The fields the app knows about, how to guess them from a dataset (names,
#' labels and content, in English, French, Spanish and Portuguese), the checks
#' on what they contain, the standardisation of their values (sex, residency,
#' yes/no), dates read whatever their format, and what each part of the app
#' can do with the fields that were mapped. Only the household identifier and
#' the top area level are required: everything else is optional, and what is
#' missing switches the features that need it off, with the reason.
#' @name mapping
#' @noRd
NULL

#' The fields of the setup, in display order
#'
#' kind drives the content checks and the guess; std the value
#' standardisation (NULL: none).
#' @noRd
SETUP_FIELDS <- list(
  list(key = "unique_id", label = "Household identifier", group = 1, kind = "id", required = TRUE,
       syn = c("uuid", "instanceid", "instance id", "id", "index", "household id", "hh id", "hhid", "id menage", "code menage",
               "menage id", "key", "record id", "id hogar", "codigo hogar", "id agregado", "id domicilio")),
  list(key = "date", label = "Data collection date", group = 1, kind = "date",
       syn = c("date", "today", "survey date", "svydate", "interview date", "start", "submission time", "date enquete",
               "date entretien", "aujourdhui", "fecha", "fecha encuesta", "data", "data entrevista")),
  list(key = "enumerator_id", label = "Enumerator", group = 1, kind = "category",
       syn = c("enumerator", "enum", "enum id", "interviewer", "enqueteur", "enqueteur id", "agent", "encuestador",
               "entrevistador", "recenseur", "username")),
  list(key = "weight", label = "Sampling weight", group = 1, kind = "weight",
       syn = c("weight", "weights", "wgt", "sampling weight", "pond", "ponderation", "poids", "peso", "factor expansion", "fexp")),
  list(key = "admin1", label = "Area level 1 (e.g. region, province)", group = 2, kind = "area", required = TRUE,
       syn = c("admin1", "adm1", "adim1", "province", "region", "state", "governorate", "gouvernorat", "provincia",
               "departamento", "estado", "wilaya", "oblast", "adm 1", "admin 1")),
  list(key = "admin2", label = "Area level 2 (e.g. district)", group = 2, kind = "area",
       syn = c("admin2", "adm2", "adim2", "district", "territoire", "department", "departement", "prefecture", "municipio",
               "cercle", "county", "adm 2", "admin 2", "distrito")),
  list(key = "admin3", label = "Area level 3 (e.g. commune)", group = 2, kind = "area",
       syn = c("admin3", "adm3", "adim3", "commune", "sub district", "subdistrict", "zone de sante", "zonesante", "health zone",
               "upazila", "sous prefecture", "chiefdom", "municipality", "arrondissement", "woreda", "lga", "adm 3", "admin 3")),
  list(key = "admin4", label = "Area level 4 (e.g. ward)", group = 2, kind = "area",
       syn = c("admin4", "adm4", "admi4", "ward", "aire de sante", "airedesante", "groupement", "kebele", "union", "quartier",
               "sector", "secteur", "adm 4", "admin 4", "barrio")),
  list(key = "village", label = "Village / community / site", group = 2, kind = "area",
       syn = c("village", "community", "communaute", "localite", "locality", "site", "camp", "settlement", "comunidad",
               "aldea", "vereda", "bairro", "colline", "localidad", "povoado")),
  list(key = "lon", label = "GPS longitude", group = 2, kind = "lon",
       syn = c("lon", "long", "longitude", "gps longitude", "coord x", "xcoord", "x coord", "geopoint longitude", "longitud")),
  list(key = "lat", label = "GPS latitude", group = 2, kind = "lat",
       syn = c("lat", "latitude", "gps latitude", "coord y", "ycoord", "y coord", "geopoint latitude", "latitud")),
  list(key = "hhh_sex", label = "Sex of the head of household", group = 3, kind = "sex", std = "sex",
       syn = c("sex", "gender", "genre", "sexe", "sexo", "hhh sex", "hhhsex", "sex head", "sexe chef", "sexo jefe", "sex hhh")),
  list(key = "hhh_age", label = "Age of the head of household (or date of birth)", group = 3, kind = "age",
       syn = c("age", "hhh age", "hhhage", "age head", "age chef", "age cm", "agecm", "edad", "edad jefe", "idade",
               "birth", "date of birth", "dob", "naissance", "date naissance", "nacimiento", "fecha nacimiento")),
  list(key = "hh_size", label = "Household size", group = 3, kind = "size",
       syn = c("hh size", "hhsize", "household size", "size", "taille", "taille menage", "members", "nb membres",
               "nombre personnes", "total members", "family size", "tamano hogar", "tamanho agregado", "miembros")),
  list(key = "residency", label = "Residence status (resident, IDP, refugee...)", group = 3, kind = "category", std = "residency",
       syn = c("residency", "residence", "resident", "status", "hh status", "hhstatus", "displacement", "displaced", "idp",
               "statut", "statut residence", "deplace", "refugee", "migration status", "tipo residencia", "condicion", "estatuto")),
  list(key = "childU5", label = "Children under 5", group = 3, kind = "count",
       syn = c("under5", "u5", "children under 5", "child u5", "childu5", "childrenu5", "enfants moins 5", "moins5ans",
               "moins 5 ans", "menores 5", "ninos menores 5", "criancas menores 5")),
  list(key = "plw", label = "Pregnant or lactating women (number, or yes/no)", group = 3, kind = "count",
       syn = c("plw", "pregnant", "lactating", "pregnant lactating", "pregnant or lactating", "enceinte", "enceintes", "allaitante",
               "allaitantes", "fefa", "femmes enceintes", "embarazada", "embarazadas", "lactante", "gestante", "gestantes", "lactantes")),
  list(key = "elderly", label = "Older people, 60 and over (number, or yes/no)", group = 3, kind = "count",
       syn = c("elderly", "older", "older persons", "aged 60", "over 60", "60 plus", "60plus", "above 60", "personnes agees",
               "personne agee", "aines", "plus 60", "60 ans", "mayores", "adultos mayores", "idosos", "idoso", "old people")),
  list(key = "hhid_avail", label = "Head has an ID document", group = 3, kind = "yesno", std = "yesno",
       syn = c("id available", "id card", "identity", "identity card", "piece identite", "carte identite", "documento",
               "documento identidad", "hhid avail")),
  list(key = "phone_avail", label = "Household has a phone", group = 3, kind = "yesno", std = "yesno",
       syn = c("phone", "telephone", "mobile", "tel", "celular", "telefono", "sim", "phone avail")),
  list(key = "disability", label = "Disability or chronic illness in the household", group = 3, kind = "yesno", std = "yesno",
       syn = c("disability", "disabled", "handicap", "chronic", "chronic illness", "maladie chronique", "discapacidad",
               "deficiencia", "illness", "difficulty")),
  list(key = "v_score", label = "Vulnerability score", group = 4, kind = "score",
       syn = c("score", "vulnerability score", "v score", "scoring", "score total", "scoring total", "puntaje", "pontuacao", "pmt score")),
  list(key = "v_groups", label = "Vulnerability groups", group = 4, kind = "category",
       syn = c("vulnerability group", "vulnerability groups", "v groups", "class", "scoring class", "categorie", "groupe",
               "vuln group", "nivel vulnerabilidad", "categoria")),
  list(key = "eligibility", label = "Eligibility", group = 4, kind = "category",
       syn = c("eligibility", "eligible", "eligibilite", "selection", "selected", "retenu", "beneficiary", "beneficiaire",
               "elegible", "elegivel", "choix"))
)

SETUP_GROUPS <- c("1. Identification & survey design", "2. Areas and location", "3. Household", "4. Vulnerability")

#' Field keys, and one field's definition / label
#' @noRd
setup_keys <- function() vapply(SETUP_FIELDS, `[[`, "", "key")
setup_field <- function(key) SETUP_FIELDS[[match(key, setup_keys())]]
field_label <- function(key) {
  i <- match(key, setup_keys())
  if (is.na(i)) key else SETUP_FIELDS[[i]]$label
}

# lower case, accents and punctuation removed, words separated by one space
norm_name <- function(x) {
  x <- iconv(as.character(x), "UTF-8", "ASCII//TRANSLIT", sub = "")
  x <- gsub("([a-z])([A-Z])", "\\1 \\2", x)                 # camelCase -> camel case
  x <- tolower(gsub("[^A-Za-z0-9]+", " ", x))
  trimws(gsub("\\s+", " ", x))
}

#' How well a column name (or label) matches a field's synonyms (0-1)
#'
#' Whole words only, so "age" does not match "village" and "id" does not match
#' "idp". The name squeezed of its separators must also match exactly or
#' start with the synonym (hhsize, HHHSex).
#' @noRd
# single generic words: a match on them alone is weaker evidence
SYN_WEAK <- c("id", "index", "key", "data", "start", "status", "size", "score", "class", "long", "tel", "sim", "agent",
              "username", "local", "site", "zone", "union", "sector", "groupe", "categorie", "categoria", "selection", "choix")

name_score <- function(name, syn) {
  n <- norm_name(name); if (!nzchar(n)) return(0)
  words <- strsplit(n, " ", fixed = TRUE)[[1]]
  squeezed <- gsub(" ", "", n, fixed = TRUE)
  best <- 0
  for (s in syn) {
    sn <- norm_name(s); sq <- gsub(" ", "", sn, fixed = TRUE)
    sc <- if (identical(n, sn) || identical(squeezed, sq)) 1
          else if (grepl(paste0("(^| )", sn, "( |$)"), n)) 0.85
          else if (nchar(sq) >= 4 && startsWith(squeezed, sq)) 0.7
          else if (nchar(sq) >= 5 && grepl(sq, squeezed, fixed = TRUE)) 0.55
          else if (nchar(sq) >= 3 && length(words) > 1 && sq %in% words) 0.6
          else 0
    if (sn %in% SYN_WEAK && sc < 1) sc <- sc * 0.7
    best <- max(best, sc)
  }
  best
}

# vocabularies for the value standardisation (lower case, no accents)
STD_VOCAB <- list(
  sex = list(Male = c("m", "male", "man", "men", "homme", "h", "masculin", "masculino", "hombre", "varon", "boy"),
             Female = c("f", "female", "woman", "women", "femme", "feminin", "femenino", "feminino", "mujer", "mulher", "girl")),
  yesno = list(Yes = c("yes", "y", "oui", "o", "si", "sim", "true", "vrai", "1"),
               No = c("no", "n", "non", "nao", "false", "faux", "0")),
  residency = list(IDP = c("idp", "idps", "displaced", "deplace", "deplaces", "deplacee", "pdi", "desplazado", "desplazada", "deslocado",
                           "internally displaced", "internally displaced person"),
                   Refugee = c("refugee", "refugees", "refugie", "refugiee", "refugies", "refugiado", "refugiada", "asylum seeker", "demandeur asile"),
                   Returnee = c("returnee", "returnees", "retourne", "retournee", "retournes", "retornado", "retornada", "returned", "rapatrie", "repatrie"),
                   Migrant = c("migrant", "migrants", "migrante"),
                   Resident = c("resident", "residents", "host", "host community", "hote", "famille hote", "population hote", "local",
                                "residente", "autochtone", "non displaced", "non deplace", "communaute hote"),
                   Other = c("other", "others", "autre", "autres", "otro", "otra", "otros", "outro", "outra"))
)
STD_KEEP <- "(keep as is)"
STD_MISSING <- "(set as missing)"
std_levels <- function(std) names(STD_VOCAB[[std]])

#' Suggested standard value for each distinct value of a column
#'
#' @return data.frame(value, n, standard, assumed) or NULL when the column
#'   has too many distinct values to be a category. `needed` (attribute) is
#'   FALSE when every value already is a standard one.
#' @noRd
recode_suggest <- function(x, std, max_values = 15) {
  v <- as.character(x); v <- v[!is.na(v) & nzchar(trimws(v))]
  if (!length(v)) return(NULL)
  tab <- sort(table(v), decreasing = TRUE)
  if (length(tab) > max_values) return(NULL)
  vals <- names(tab); nv <- norm_name(vals)
  voc <- STD_VOCAB[[std]]
  # an exact answer first, then a known phrase inside the answer ("IDP on
  # site"), in the vocabulary's order (IDP before host: "IDP host family")
  standard <- vapply(nv, function(z) {
    hit <- names(voc)[vapply(voc, function(words) z %in% words, logical(1))]
    if (!length(hit)) hit <- names(voc)[vapply(voc, function(words)
      any(nchar(words) > 1 & vapply(words, function(w) grepl(paste0("(^| )", w, "( |$)"), z), logical(1))), logical(1))]
    if (length(hit)) hit[1] else NA_character_
  }, character(1))
  assumed <- rep(FALSE, length(vals))
  # numeric codes without labels: 1/2 is male/female in DHS and MICS
  if (identical(std, "sex") && all(is.na(standard)) && setequal(nv, c("1", "2"))) {
    standard <- ifelse(nv == "1", "Male", "Female"); assumed[] <- TRUE
  }
  standard[is.na(standard)] <- STD_KEEP
  out <- data.frame(value = vals, n = as.integer(tab), standard = unname(standard), assumed = assumed, stringsAsFactors = FALSE)
  attr(out, "needed") <- !all(out$value == out$standard | out$standard == STD_KEEP) || any(out$assumed)
  out
}

#' Apply a value map (value -> standard, keep, missing) to a column
#' @noRd
apply_recode <- function(x, map) {
  v <- as.character(x); out <- v
  for (k in names(map)) {
    to <- map[[k]]; hit <- which(v == k)
    if (identical(to, STD_KEEP)) next
    out[hit] <- if (identical(to, STD_MISSING)) NA_character_ else to
  }
  out
}

#' Read dates whatever their format
#'
#' Date and date-time columns pass through; Excel serial numbers become dates;
#' text is tried as year-month-day, day-month-year and month-day-year (with or
#' without a time) and the order that reads most values wins. Day and month
#' can only be told apart when some value has a number above 12 in one of the
#' two places; otherwise day-month-year is assumed and flagged.
#' @return list(date, format, rate, ambiguous)
#' @noRd
parse_dates <- function(x, sample_n = 5000) {
  if (inherits(x, "Date")) return(list(date = x, format = "date", rate = mean(!is.na(x)), ambiguous = FALSE))
  if (inherits(x, "POSIXt")) return(list(date = as.Date(x), format = "date and time", rate = mean(!is.na(x)), ambiguous = FALSE))
  if (is.numeric(x)) {
    ok <- x[is.finite(x)]
    if (length(ok) && mean(ok > 20000 & ok < 80000) > 0.95)
      return(list(date = as.Date(x, origin = "1899-12-30"), format = "Excel serial number", rate = mean(is.finite(x)), ambiguous = FALSE))
    return(list(date = rep(as.Date(NA), length(x)), format = "", rate = 0, ambiguous = FALSE))
  }
  v <- trimws(as.character(x)); has <- !is.na(v) & nzchar(v)
  if (!any(has)) return(list(date = rep(as.Date(NA), length(x)), format = "", rate = 0, ambiguous = FALSE))
  set.seed(1)
  smp <- v[has]; if (length(smp) > sample_n) smp <- sample(smp, sample_n)
  orders <- list(ymd = c("Ymd", "Ymd HMS", "Ymd HM"), dmy = c("dmY", "dmY HMS", "dmY HM", "dmy"), mdy = c("mdY", "mdY HMS", "mdY HM", "mdy"))
  rd <- function(z, o) suppressWarnings(as.Date(lubridate::parse_date_time(z, orders = o, quiet = TRUE, exact = FALSE)))
  rate <- vapply(orders, function(o) mean(!is.na(rd(smp, o))), numeric(1))
  # day or month first: a number above 12 in the first place means the day comes first
  parts <- regmatches(smp, regexec("^(\\d{1,2})[/.-](\\d{1,2})[/.-]\\d{2,4}", smp))
  a <- suppressWarnings(as.integer(vapply(parts, function(p) if (length(p) == 3) p[2] else NA_character_, "")))
  b <- suppressWarnings(as.integer(vapply(parts, function(p) if (length(p) == 3) p[3] else NA_character_, "")))
  day_first <- any(a > 12, na.rm = TRUE); month_first <- any(b > 12, na.rm = TRUE)
  if (max(rate) == 0) return(list(date = rep(as.Date(NA), length(x)), format = "", rate = 0, ambiguous = FALSE))
  ambiguous <- FALSE
  if (rate[["ymd"]] > max(rate[["dmy"]], rate[["mdy"]]) + 0.01) best <- "ymd"
  else if (day_first && !month_first) best <- "dmy"
  else if (month_first && !day_first) best <- "mdy"
  else {
    best <- if (rate[["mdy"]] > rate[["dmy"]] + 0.01) "mdy" else "dmy"
    ambiguous <- any(!is.na(a))            # day and month both 12 or less everywhere
  }
  d <- rep(as.Date(NA), length(x)); d[has] <- rd(v[has], orders[[best]])
  list(date = d, format = c(ymd = "year-month-day", dmy = "day/month/year", mdy = "month/day/year")[[best]],
       rate = mean(!is.na(d[has])), ambiguous = ambiguous)
}

# ---- Guessing -------------------------------------------------------------

#' How plausible a column's content is for a kind of field (0-1), on a sample
#' @noRd
content_score <- function(x, kind) {
  n <- length(x); if (!n) return(0)
  miss <- is.na(x) | (is.character(x) & !nzchar(trimws(as.character(x))))
  v <- x[!miss]; if (!length(v)) return(0)
  num <- if (is.numeric(v)) v else suppressWarnings(as.numeric(as.character(v)))
  numeric_share <- mean(!is.na(num))
  nd <- length(unique(v))
  num_ok <- num[!is.na(num)]
  intish <- if (length(num_ok)) mean(abs(num_ok - round(num_ok)) < 1e-9) else 0
  within <- function(lo, hi) if (length(num_ok)) mean(num_ok >= lo & num_ok <= hi) else 0
  switch(kind,
    id = if (nd == length(v)) 1 else nd / length(v) * 0.4,
    date = if (inherits(v, c("Date", "POSIXt"))) 1 else if (numeric_share > 0.9 && !inherits(v, c("Date", "POSIXt"))) 0.1 else parse_dates(v, 500)$rate,
    area = if (numeric_share > 0.9) 0.15 else if (nd >= 2 && nd <= max(3, length(v) / 3)) 0.8 else 0.2,
    category = if (nd >= 2 && nd <= 30) 0.7 else 0.1,
    lon = if (numeric_share > 0.95) within(-180, 180) * (1 - intish) else 0,
    lat = if (numeric_share > 0.95) within(-90, 90) * (1 - intish) else 0,
    sex = if (nd >= 2 && nd <= 3) { s <- recode_suggest(v, "sex"); if (!is.null(s) && all(s$standard != STD_KEEP)) 1 else 0.5 } else 0,
    age = if (numeric_share > 0.9) within(12, 110) else if (parse_dates(v, 500)$rate > 0.8) 0.8 else 0,
    size = if (numeric_share > 0.9) within(1, 40) * intish else 0,
    count = if (numeric_share > 0.9) within(0, 20) * intish else 0,
    yesno = if (nd == 2) 1 else if (nd == 3) 0.4 else 0,
    score = if (numeric_share > 0.9) (if (nd > 5) 0.9 else 0.4) else 0,
    weight = if (numeric_share > 0.9 && all(num_ok > 0)) (if (intish < 0.9) 1 else 0.4) else 0,
    0.3)
}

#' Guess the mapping of a dataset
#'
#' Every field is scored against every column: name (and label) against the
#' field's synonyms in four languages, then the content on a sample. A column
#' is used once, best matches first. Only the identifier may be guessed from
#' content alone (a column whose values are all different).
#' @param labels Named character: column -> label (from the session dictionary).
#' @return data.frame(key, column, confidence ("high"/"medium"/"low"/""), why)
#' @noRd
guess_mapping <- function(df, labels = NULL, sample_n = 3000) {
  cols <- names(df)
  set.seed(1)
  rows <- if (nrow(df) > sample_n) sample.int(nrow(df), sample_n) else seq_len(nrow(df))
  cand <- list()
  for (f in SETUP_FIELDS) {
    for (cl in cols) {
      ns <- name_score(cl, f$syn)
      lb <- if (!is.null(labels) && cl %in% names(labels)) labels[[cl]] else NA
      ls <- if (!is.na(lb)) 0.9 * name_score(lb, f$syn) else 0
      nm <- max(ns, ls)
      if (nm == 0 && !identical(f$kind, "id")) next
      cs <- content_score(df[[cl]][rows], f$kind)
      if (nm == 0 && cs < 1) next                              # content alone: only a fully unique id
      score <- if (nm == 0) 0.45 else 0.6 * nm + 0.4 * cs
      why <- paste0(if (nm > 0) sprintf("%s matches", if (ls > ns) "label" else "name") else "values all different",
                    if (nm > 0) sprintf("; content %s", if (cs >= 0.8) "fits" else if (cs >= 0.4) "partly fits" else "does not fit") else "")
      cand[[length(cand) + 1]] <- data.frame(key = f$key, column = cl, score = score, why = why, stringsAsFactors = FALSE)
    }
  }
  out <- data.frame(key = setup_keys(), column = "", confidence = "", why = "", stringsAsFactors = FALSE)
  if (!length(cand)) return(out)
  cand <- do.call(rbind, cand)
  cand <- cand[cand$score >= 0.35, , drop = FALSE]
  cand <- cand[order(-cand$score), , drop = FALSE]
  used <- character(0)
  for (i in seq_len(nrow(cand))) {
    k <- cand$key[i]; cl <- cand$column[i]; j <- match(k, out$key)
    if (nzchar(out$column[j]) || cl %in% used) next
    out$column[j] <- cl; used <- c(used, cl)
    out$confidence[j] <- if (cand$score[i] >= 0.75) "high" else if (cand$score[i] >= 0.5) "medium" else "low"
    out$why[j] <- cand$why[i]
  }
  out
}

# ---- Checks on the content --------------------------------------------------

#' Checks on what the mapped columns contain
#'
#' "block" stops the setup (no identifier, repeated or missing identifiers,
#' area levels not mapped from the top); "warn" is reported, kept in the audit
#' trail and does not stop anything.
#' @param map Named list field -> column ("" or NULL when not mapped).
#' @return data.frame(field, level, message)
#' @noRd
mapping_checks <- function(df, map) {
  col <- function(k) { v <- map[[k]]; if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1]) || !v[1] %in% names(df)) NULL else v[1] }
  out <- list()
  add <- function(field, level, msg) out[[length(out) + 1]] <<- data.frame(field = field, level = level, message = msg, stringsAsFactors = FALSE)
  n <- nrow(df); fmt <- function(k) format(k, big.mark = ",")
  share <- function(k) sprintf("%s (%.1f%%)", fmt(k), 100 * k / max(n, 1))
  # identifier
  id <- col("unique_id")
  if (is.null(id)) add("unique_id", "block", "Map the household identifier: every household needs one to be checked, corrected and selected.")
  else {
    v <- df[[id]]; blank <- sum(is.na(v) | !nzchar(trimws(as.character(v))))
    if (blank) add("unique_id", "block", sprintf("%s households have no identifier.", share(blank)))
    if (anyDuplicated(v[!(is.na(v) | !nzchar(trimws(as.character(v))))])) {
      d <- sum(duplicated(v[!is.na(v)]))
      add("unique_id", "block", sprintf("%s identifiers are repeated: resolve them in the source file or choose another identifier column.", share(d)))
    }
  }
  # areas: from the top, and each level finer than the one above
  lv <- c("admin1", "admin2", "admin3", "admin4", "village")
  mapped <- vapply(lv, function(k) !is.null(col(k)), logical(1))
  if (!mapped[1]) add("admin1", "block", "Map at least the top area level (level 1): selection, filters and checks by area need it.")
  gap <- which(!mapped[1:4])[1]
  if (!is.na(gap) && any(mapped[seq(gap, 4)])) add(lv[gap], "block", sprintf("Area levels must be mapped from the top: %s is empty but a lower level is mapped.", field_label(lv[gap])))
  nd <- vapply(lv, function(k) if (mapped[[k]]) length(unique(df[[col(k)]])) else NA_integer_, integer(1))
  prev <- NA
  for (k in lv) if (mapped[[k]]) {
    if (!is.na(prev) && nd[[k]] < nd[[prev]]) add(k, "warn", sprintf("%s has fewer areas (%d) than %s (%d): are the levels in the right order?", field_label(k), nd[[k]], field_label(prev), nd[[prev]]))
    blank <- sum(is.na(df[[col(k)]]) | !nzchar(trimws(as.character(df[[col(k)]]))))
    if (blank / max(n, 1) > 0.02) add(k, "warn", sprintf("%s: %s households have no area.", field_label(k), share(blank)))
    prev <- k
  }
  # date
  if (!is.null(col("date"))) {
    p <- parse_dates(df[[col("date")]])
    if (p$rate < 0.95) add("date", "warn", sprintf("Collection date: %.0f%% of the values could not be read as dates.", 100 * (1 - p$rate)))
    d <- p$date[!is.na(p$date)]
    if (length(d)) {
      fut <- sum(d > Sys.Date() + 1); old <- sum(d < as.Date("2000-01-01"))
      if (fut) add("date", "warn", sprintf("Collection date: %s households are dated in the future.", share(fut)))
      if (old) add("date", "warn", sprintf("Collection date: %s households are dated before 2000.", share(old)))
    }
    if (isTRUE(p$ambiguous)) add("date", "warn", "Collection date: day and month cannot be told apart (no value above 12); read as day/month/year.")
  }
  # GPS
  lo <- col("lon"); la <- col("lat")
  if (xor(is.null(lo), is.null(la))) add(if (is.null(lo)) "lon" else "lat", "warn", "Only one GPS coordinate is mapped: the map and the GPS checks need both.")
  if (!is.null(lo) && !is.null(la)) {
    x <- as_number(df[[lo]]); y <- as_number(df[[la]]); ok <- is.finite(x) & is.finite(y)
    bad <- sum(ok & (abs(x) > 180 | abs(y) > 90)); zero <- sum(ok & x == 0 & y == 0)
    if (bad) add("lat", "warn", sprintf("GPS: %s points are outside the valid range (latitude -90 to 90, longitude -180 to 180).", share(bad)))
    if (zero) add("lat", "warn", sprintf("GPS: %s points are at 0,0 (a missing position recorded as zero).", share(zero)))
    ok <- ok & abs(x) <= 180 & abs(y) <= 90 & !(x == 0 & y == 0)
    if (sum(ok) > 10) {
      if (mean(abs(y[ok]) > abs(x[ok])) > 0.9 && any(abs(y[ok]) > 90)) add("lat", "warn", "GPS: latitude and longitude look swapped.")
      far <- sum(ok & (abs(x - stats::median(x[ok])) > 5 | abs(y - stats::median(y[ok])) > 5))
      if (far) add("lat", "warn", sprintf("GPS: %s points are more than 5 degrees from the others (a typo, a swapped sign or a device error).", share(far)))
    }
    miss <- sum(!is.finite(x) | !is.finite(y))
    if (miss / max(n, 1) > 0.05) add("lat", "warn", sprintf("GPS: %s households have no position and will not be on the map.", share(miss)))
  }
  # demographics
  if (!is.null(col("hhh_age"))) {
    a <- as_number(df[[col("hhh_age")]])
    if (mean(is.na(a)) < 0.5) {
      k <- sum(is.finite(a) & (a < 12 | a > 110))
      if (k) add("hhh_age", "warn", sprintf("Head's age: %s values are below 12 or above 110.", share(k)))
    }
  }
  if (!is.null(col("hh_size"))) {
    s <- as_number(df[[col("hh_size")]])
    k <- sum(is.finite(s) & (s < 1 | s > 40)); nf <- sum(is.finite(s) & abs(s - round(s)) > 1e-9)
    if (k) add("hh_size", "warn", sprintf("Household size: %s values are below 1 or above 40.", share(k)))
    if (nf) add("hh_size", "warn", sprintf("Household size: %s values are not whole numbers.", share(nf)))
    if (!is.null(col("childU5"))) {
      u <- as_number(df[[col("childU5")]]); k <- sum(is.finite(u) & is.finite(s) & u > s)
      if (k) add("childU5", "warn", sprintf("Children under 5: %s households have more children under 5 than members.", share(k)))
    }
  }
  if (!is.null(col("weight"))) {
    w <- as_number(df[[col("weight")]]); k <- sum(!is.finite(w) | w <= 0)
    if (k) add("weight", "warn", sprintf("Sampling weight: %s households have a missing, zero or negative weight (they count for nothing in weighted figures).", share(k)))
  }
  if (!length(out)) return(data.frame(field = character(0), level = character(0), message = character(0)))
  do.call(rbind, out)
}

# ---- What the data allow ----------------------------------------------------

# Each feature: fields it needs (all), fields of which it needs one (any), and
# fields that complete it (partial without them).
READINESS_FEATURES <- list(
  list(area = "Overview", feature = "Household counts", all = "unique_id"),
  list(area = "Overview", feature = "Individual counts", all = "hh_size"),
  list(area = "Overview", feature = "Filters and breakdowns by area", all = "admin1", more = c("admin2", "admin3")),
  list(area = "Overview", feature = "Filter by date, daily collection chart", all = "date"),
  list(area = "Overview", feature = "Map of the households", all = c("lon", "lat"), more = "v_groups"),
  list(area = "Overview", feature = "Vulnerability summary and eligibility", any = c("v_groups", "eligibility", "v_score")),
  list(area = "Overview", feature = "Household profiles", any = c("hhh_sex", "hhh_age", "hh_size", "residency", "childU5", "disability", "plw", "elderly"),
       more = c("hhh_sex", "hhh_age", "hh_size", "residency", "childU5", "disability")),
  list(area = "Data quality", feature = "Spelling and integrity", all = "unique_id", more = c("admin1", "village", "hhh_sex")),
  list(area = "Data quality", feature = "Location names", all = "admin1", more = c("admin2", "admin3", "admin4", "village")),
  list(area = "Data quality", feature = "Missing data", all = "unique_id", more = "admin1"),
  list(area = "Data quality", feature = "Outliers", all = "unique_id", more = c("enumerator_id", "admin1")),
  list(area = "Data quality", feature = "Duplicates", all = "unique_id"),
  list(area = "Data quality", feature = "Enumerator performance", all = "enumerator_id", more = "date"),
  list(area = "Data quality", feature = "GPS checks", all = c("lon", "lat")),
  list(area = "Spot checking", feature = "Sampling and back-checks", all = "unique_id", more = c("admin1", "phone_avail")),
  list(area = "Selection", feature = "Selection by area and caseload per area", all = "admin1"),
  list(area = "Selection", feature = "Selection by an existing vulnerability score", all = "v_score"),
  list(area = "Selection", feature = "Individuals reached", all = "hh_size")
)

#' What each part of the app can do with the fields mapped
#' @return data.frame(area, feature, status ("Available"/"Partial"/"Not available"), detail)
#' @noRd
data_readiness <- function(map) {
  has <- function(k) { v <- map[[k]]; !is.null(v) && length(v) && !is.na(v[1]) && nzchar(v[1]) }
  labs <- function(ks) paste(tolower(vapply(ks, field_label, "")), collapse = ", ")
  do.call(rbind, lapply(READINESS_FEATURES, function(f) {
    miss_all <- Filter(Negate(has), f$all %||% character(0))
    any_ok <- is.null(f$any) || any(vapply(f$any, has, logical(1)))
    miss_more <- Filter(Negate(has), f$more %||% character(0))
    if (length(miss_all) || !any_ok) {
      status <- "Not available"
      detail <- paste("Needs", if (length(miss_all)) labs(miss_all) else paste("one of:", labs(f$any)))
    } else if (length(miss_more)) {
      status <- "Partial"; detail <- paste("Without", labs(miss_more))
    } else { status <- "Available"; detail <- "" }
    data.frame(area = f$area, feature = f$feature, status = status, detail = detail, stringsAsFactors = FALSE)
  }))
}

#' Stop an output with the reason when a field it needs is not mapped
#'
#' validate() shows the message in place of the output, so a chart that cannot
#' be drawn says why instead of staying blank.
#' @noRd
need_mapped <- function(setup, ..., short = FALSE) {
  for (k in c(...)) {
    v <- setup[[k]]
    shiny::validate(shiny::need(shiny::isTruthy(v),
      if (short) "not mapped" else sprintf("Not in these data: %s is not mapped (Import, Variable Definition & Setup).", tolower(field_label(k)))))
  }
  invisible(TRUE)
}

#' Setup transformations applied to a data frame (and to the Reset baseline)
#'
#' Forced numeric columns; the collection date read as a date; standardised
#' values in new `<column>_std` columns; age from a date of birth in
#' `<column>_age`. Returns the data and the final mapping (fields pointing at
#' the new columns).
#' @param plan list(force_numeric, date = list(column, order), recodes =
#'   list(field = list(source, map)), age_from_dob = list(source, ref_date_col))
#' @noRd
apply_setup_plan <- function(df, map, plan) {
  for (cl in intersect(plan$force_numeric %||% character(0), names(df))) df[[cl]] <- as_number(df[[cl]])
  dc <- plan$date$column
  if (!is.null(dc) && dc %in% names(df) && !inherits(df[[dc]], c("Date", "POSIXt"))) {
    p <- parse_dates(df[[dc]]); if (p$rate > 0) df[[dc]] <- p$date
  }
  for (k in names(plan$recodes %||% list())) {
    r <- plan$recodes[[k]]
    if (is.null(r$source) || !r$source %in% names(df)) next
    target <- paste0(r$source, "_std")
    df[[target]] <- apply_recode(df[[r$source]], r$map)
    attr(df[[target]], "label") <- paste0(field_label(k), " (standardised)")
    map[[k]] <- target
  }
  a <- plan$age_from_dob
  if (!is.null(a$source) && a$source %in% names(df)) {
    dob <- parse_dates(df[[a$source]])$date
    ref <- if (!is.null(dc) && dc %in% names(df)) as.Date(df[[dc]]) else rep(Sys.Date(), nrow(df))
    ref[is.na(ref)] <- Sys.Date()
    age <- floor(as.numeric(ref - dob) / 365.25)
    age[!is.finite(age) | age < 0] <- NA
    target <- paste0(a$source, "_age")
    df[[target]] <- age
    attr(df[[target]], "label") <- "Age of the head of household (from the date of birth)"
    map[["hhh_age"]] <- target
  }
  list(df = df, map = map)
}

#' The mapped area levels for a level picker: "Admin 1 - Province" -> "Admin 1"
#' (only the levels mapped, each with its column, so no level shows twice
#' under generic names)
#' @noRd
mapped_level_choices <- function(setup) {
  lv <- c(admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4", village = "Village")
  cols <- vapply(names(lv), function(k) { v <- as.character(setup[[k]] %||% "")[1]; if (is.na(v)) "" else v }, "")
  keep <- nzchar(cols)
  if (!any(keep)) return(c("Admin 1" = "Admin 1"))
  stats::setNames(unname(lv[keep]), sprintf("%s \u00b7 %s", lv[keep], cols[keep]))
}
