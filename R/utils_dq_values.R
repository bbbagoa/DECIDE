#' Category values: harmonise the answers of a qualitative variable
#'
#' The same answer is often typed several ways across enumerators and forms
#' ("Oui", "oui ", "OUI", "Femme" / "femme"). These helpers find the
#' qualitative variables, group the look-alike values and suggest one spelling
#' per group (the most common); Data Quality > Category values applies them.
#' @name dq_values
#' @noRd
NULL

#' Qualitative variables worth harmonising: text or factor columns with a few
#' hundred distinct answers at most, not identifiers, names or free text, and
#' not the mapped area columns (Location names covers those)
#' @noRd
value_cols <- function(df, settings = list(), max_values = 300) {
  if (is.null(df) || !ncol(df)) return(character(0))
  areas <- unlist(lapply(c("admin1", "admin2", "admin3", "admin4", "village", "unique_id"), function(k) {
    v <- as.character(settings[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v)) v
  }))
  cols <- setdiff(analysis_cols(df), areas)
  Filter(function(cl) {
    x <- df[[cl]]
    if (!(is.character(x) || is.factor(x))) return(FALSE)
    n <- length(unique(x[!is.na(x)]))
    n >= 2 && n <= max_values
  }, cols)
}

#' A value reduced to what a spelling variant does not change: case, accents,
#' punctuation, repeated spaces
#' @noRd
value_key <- function(x) {
  k <- iconv(as.character(x), to = "ASCII//TRANSLIT", sub = "")
  k[is.na(k)] <- as.character(x)[is.na(k)]
  k <- tolower(gsub("[[:punct:]]+", " ", k))
  trimws(gsub("\\s+", " ", k))
}

#' The same answer in other words, across the languages forms use (keys as
#' `value_key()` gives them). A set only joins values found in the same
#' variable; the most common of them is suggested. These are judgement calls,
#' not typos: the page leaves them unticked.
#' @noRd
VALUE_SYNONYMS <- list(
  c("yes", "oui", "si", "sim", "y", "o"),
  c("no", "non", "nao", "n"),
  c("male", "homme", "masculin", "hombre", "masculino", "m"),
  c("female", "femme", "feminin", "mujer", "femenino", "feminino", "f"),
  c("idp", "pdi", "displaced", "deplace", "deplaces", "deplacee", "desplazado", "deslocado", "idps"),
  c("refugee", "refugie", "refugies", "refugiee", "refugiado", "refugees"),
  c("returnee", "retourne", "retournes", "rapatrie", "retornado", "returnees"),
  c("resident", "residents", "residente", "resident population", "population residente"),
  c("host community", "communaute hote", "communaute d accueil", "comunidad de acogida")
)

#' The values of a variable, their records, and groups of look-alikes
#'
#' Values that are the same once case, accents, punctuation and spaces are
#' set aside always group; others group when their keys are at least
#' `similarity` alike (`fuzzy_match_groups()`). Short answers ("M" / "F",
#' "Oui" / "Non") stay apart at the default 85%. With `synonyms`, groups that
#' are the same answer in other words (`VALUE_SYNONYMS`) join, their values
#' marked "translation".
#' @return data.frame(value, records, group (0 = alone), suggestion (the
#'   group's most common value; "" when alone or already it), kind
#'   ("spelling" / "translation" for a value with a suggestion, else "")),
#'   groups first.
#' @noRd
value_groups <- function(x, similarity = 0.85, synonyms = TRUE) {
  v <- as.character(x)
  v <- v[!is.na(v) & nzchar(trimws(v))]
  if (!length(v)) return(data.frame(value = character(0), records = integer(0), group = integer(0),
                                    suggestion = character(0), kind = character(0)))
  tab <- table(v)
  out <- data.frame(value = names(tab), records = as.integer(tab), stringsAsFactors = FALSE)
  key <- value_key(out$value)
  g <- fuzzy_match_groups(key, similarity = similarity)
  # identical keys always share a group, whatever the similarity
  same <- match(key, key)
  for (i in which(same != seq_along(same))) {
    a <- g[same[i]]; b <- g[i]
    if (a == 0 && b == 0) { g[c(same[i], i)] <- max(g) + 1L }
    else if (a == 0) g[same[i]] <- b
    else if (b == 0) g[i] <- a
    else if (a != b) g[g == b] <- a
  }
  # spelling units (a group, or a value alone), then synonyms join units
  unit <- ifelse(g > 0, g, max(g) + seq_along(g))
  spell <- unit
  if (synonyms) for (set in VALUE_SYNONYMS) {
    u <- unique(unit[key %in% set])
    if (length(u) > 1) unit[unit %in% u] <- u[1]
  }
  size <- table(unit)
  g <- ifelse(size[as.character(unit)] > 1, unit, 0L)
  out$group <- as.integer(g)
  out$suggestion <- ""; out$kind <- ""
  for (k in setdiff(unique(g), 0L)) {
    m <- which(g == k)
    best <- m[order(-out$records[m], out$value[m])][1]
    var <- m[m != best]
    out$suggestion[var] <- out$value[best]
    out$kind[var] <- ifelse(spell[var] == spell[best], "spelling", "translation")
  }
  # renumber, groups first (largest first), then the values alone
  gs <- setdiff(unique(out$group), 0L)
  tot <- vapply(gs, function(k) sum(out$records[out$group == k]), numeric(1))
  out$group <- match(out$group, gs[order(-tot)], nomatch = 0L)
  out <- out[order(out$group == 0, out$group, -out$records), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' The text a number stands for, in a variable mixing text and numbers
#'
#' From the variable's value labels when it has some (SPSS / Stata codes, a
#' form's choices), else from the usual codes: yes / no answers 1 = yes,
#' 0 = no (2 = no when there is no 0); sex 1 = male, 2 = female. The text is
#' the spelling already in the variable (Oui, Homme...) when there is one.
#' @param values,records The variable's distinct values and their records.
#' @param codes Its value labels (named: label -> code), or NULL.
#' @return Named character: number -> text, with attribute "source"
#'   ("labels" / "usual") per number.
#' @noRd
value_code_labels <- function(values, records, codes = NULL) {
  isnum <- grepl("^[[:space:]]*-?[0-9]+([.,][0-9]+)?[[:space:]]*$", values)
  out <- character(0); src <- character(0)
  if (!any(isnum) || all(isnum)) return(structure(out, source = src))
  nums <- values[isnum]; n <- trimws(nums)
  txt <- values[!isnum]; trec <- records[!isnum]; key <- value_key(txt)
  # the spelling in the data for a label, else the label itself
  spelt <- function(lab) { m <- which(key == value_key(lab)); if (length(m)) txt[m][which.max(trec[m])] else lab }
  if (length(codes)) {
    lab <- names(codes)[match(n, trimws(as.character(codes)))]
    ok <- !is.na(lab) & nzchar(lab)
    out[nums[ok]] <- vapply(lab[ok], spelt, ""); src[nums[ok]] <- "labels"
  }
  pick <- function(set) { m <- which(key %in% set); if (length(m)) txt[m][which.max(trec[m])] }
  yes <- pick(VALUE_SYNONYMS[[1]]); no <- pick(VALUE_SYNONYMS[[2]])
  male <- pick(VALUE_SYNONYMS[[3]]); female <- pick(VALUE_SYNONYMS[[4]])
  conv <- if (!is.null(yes) && !is.null(no)) { cv <- c("1" = yes, "0" = no); if (!"0" %in% n) cv["2"] <- no; cv }
          else if (!is.null(male) && !is.null(female)) c("1" = male, "2" = female)
  todo <- nums[!nums %in% names(out) & n %in% names(conv)]
  if (length(todo)) { out[todo] <- unname(conv[trimws(todo)]); src[todo] <- "usual" }
  structure(out, source = src)
}

#' Replace values of a column; a factor becomes text. Returns the column and
#' how many records changed.
#' @param map Named character: old value -> new value.
#' @noRd
value_replace <- function(x, map) {
  y <- as.character(x)
  hit <- !is.na(y) & y %in% names(map)
  y[hit] <- unname(map[y[hit]])
  list(x = y, n = sum(hit))
}
