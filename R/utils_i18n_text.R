#' Server-side translation of generated text (the design report)
#'
#' The browser translator (inst/app/www/i18n.js) handles everything shown on
#' screen. Documents written on the server -- the HTML design report -- never
#' pass through it, so they are translated here with the same dictionary and
#' the same rules: exact strings, sprintf patterns with their values carried
#' over, table cells, then known phrases inside longer assembled text.
#'
#' @name i18n_text
NULL

#' The translation dictionary as a data frame (en, fr), read once
#' @noRd
i18n_dictionary <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      d <- tryCatch(jsonlite::fromJSON(i18n_path())$translation, error = function(e) NULL)
      cache <<- if (is.null(d) || !"fr" %in% names(d)) {
        data.frame(en = character(0), fr = character(0), stringsAsFactors = FALSE)
      } else {
        d <- d[!is.na(d$fr) & nzchar(d$fr), c("en", "fr")]
        d$key <- gsub("[[:space:]]+", " ", trimws(d$en))
        d
      }
    }
    cache
  }
})

#' Translate strings by exact (whitespace-normalised) match; others unchanged
#' @noRd
i18n_lookup <- function(text, lang = "en") {
  if (!identical(lang, "fr") || !length(text)) return(text)
  d <- i18n_dictionary()
  if (!nrow(d)) return(text)
  hit <- d$fr[match(gsub("[[:space:]]+", " ", trimws(text)), d$key)]
  ifelse(is.na(hit) | is.na(text), text, hit)
}

.i18n_spec <- "%[-+ 0#]*[0-9]*([.][0-9]+)?[sdfgixX]"

#' sprintf dictionary entries compiled to anchored regular expressions
#' @noRd
i18n_patterns <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) return(cache)
    d <- i18n_dictionary()
    fmt <- d[grepl(.i18n_spec, d$en, perl = TRUE), ]
    esc <- function(s) gsub("([][.*+?^${}()|\\\\])", "\\\\\\1", s, perl = TRUE)
    out <- lapply(seq_len(nrow(fmt)), function(i) {
      en <- gsub("%%", "\001", fmt$key[i], fixed = TRUE)
      n_en <- lengths(regmatches(en, gregexpr(.i18n_spec, en, perl = TRUE)))
      n_fr <- lengths(regmatches(fmt$fr[i], gregexpr(.i18n_spec, gsub("%%", "", fmt$fr[i], fixed = TRUE), perl = TRUE)))
      if (n_en != n_fr) return(NULL)
      parts <- strsplit(en, .i18n_spec, perl = TRUE)[[1]]
      if (length(parts) < n_en + 1) parts <- c(parts, rep("", n_en + 1 - length(parts)))
      if (nchar(gsub("[^A-Za-z]", "", paste(parts, collapse = ""))) < 3) return(NULL)
      re <- paste0("^", paste(vapply(parts, esc, ""), collapse = "(.+?)"), "$")
      list(re = gsub("\001", "%", re, fixed = TRUE), fr = fmt$fr[i])
    })
    cache <<- Filter(Negate(is.null), out)
    cache
  }
})

#' Translate one piece of text: exact, then sprintf pattern
#' @noRd
i18n_one <- function(s) {
  t <- i18n_lookup(s, "fr")
  if (!identical(t, s)) return(t)
  n <- gsub("[[:space:]]+", " ", trimws(s))
  for (p in i18n_patterns()) {
    m <- regmatches(n, regexec(p$re, n, perl = TRUE))[[1]]
    if (length(m)) {
      vals <- i18n_lookup(m[-1], "fr")
      out <- gsub("%%", "\001", p$fr, fixed = TRUE)
      for (v in vals) out <- sub(.i18n_spec, gsub("\\", "\\\\", v, fixed = TRUE), out, perl = TRUE)
      return(gsub("\001", "%", out, fixed = TRUE))
    }
  }
  s
}

#' Translate a block of Markdown line by line
#' @noRd
i18n_translate_block <- function(txt, lang = "en") {
  if (!identical(lang, "fr") || !nrow(i18n_dictionary())) return(txt)
  lines <- strsplit(txt, "\n", fixed = TRUE)[[1]]
  lines <- vapply(lines, function(l) {
    tl <- trimws(l)
    if (!nzchar(tl)) return(l)
    if (startsWith(tl, "|")) {
      cells <- strsplit(l, "|", fixed = TRUE)[[1]]
      return(paste(vapply(cells, function(cl) {
        tc <- trimws(cl)
        if (!nzchar(tc) || grepl("^-+$", tc)) cl else paste0(" ", i18n_one(tc), " ")
      }, ""), collapse = "|"))
    }
    whole <- i18n_one(l)
    if (!identical(whole, l)) return(whole)
    lead <- regmatches(l, regexpr("^[[:space:]]*(([-*>]|#+|[0-9]+[.])[[:space:]]+)?", l))
    body <- substring(l, nchar(lead) + 1)
    t <- i18n_one(body)
    if (!identical(t, body)) paste0(lead, t) else l
  }, "", USE.NAMES = FALSE)
  out <- paste(lines, collapse = "\n")
  d <- i18n_dictionary()
  long <- d[nchar(d$en) >= 12 & !grepl(.i18n_spec, d$en, perl = TRUE), ]
  long <- long[order(-nchar(long$en)), ]
  for (i in seq_len(nrow(long))) out <- gsub(long$en[i], long$fr[i], out, fixed = TRUE)
  out
}
