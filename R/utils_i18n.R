#' Interface translation (English / French)
#'
#' Many country offices this is built for work in French, while the
#' interface was written in English -- the DRC test dataset is French data
#' behind English labels.
#'
#' Translations live in `inst/app/www/translations.json` in shiny.i18n's
#' key-value shape: the English string *is* the key, so an untranslated string
#' falls back to English rather than showing a missing-key placeholder. Adding
#' a language means adding it to `languages` and to each entry.
#'
#' COVERAGE IS PARTIAL. The navigation, the welcome page, the dashboard
#' filters, the headline KPIs and the common buttons are translated. Analysis
#' labels deeper in the Data Quality, Spot Checking and PDM tabs are not yet:
#' wrap them in `i18n$t()` and add the entry to the JSON as they are touched.
#'
#' @name i18n
NULL

#' Path to the bundled translation file
#' @noRd
i18n_path <- function() {
  app_sys("app/www/translations.json")
}

#' Languages the app offers, labelled in their own language
#' @noRd
i18n_languages <- function() {
  c("English" = "en", "Fran\u00e7ais" = "fr")
}

#' Build a translator for one session
#'
#' A Translator is an R6 object holding the selected language as mutable
#' state, so it must never be shared: one global instance would mean the last
#' person to switch language changed it for everyone else on the server.
#'
#' Returns `NULL` when shiny.i18n or the translation file is unavailable, and
#' every caller goes through `i18n_t()`, so a missing translation layer
#' degrades to plain English instead of failing to start.
#'
#' @return A `shiny.i18n::Translator`, or `NULL`.
#' @noRd
app_i18n <- function(language = "en") {
  if (!requireNamespace("shiny.i18n", quietly = TRUE)) return(NULL)
  path <- i18n_path()
  if (!nzchar(path) || !file.exists(path)) return(NULL)
  tr <- tryCatch(shiny.i18n::Translator$new(translation_json_path = path),
                 error = function(e) NULL)
  if (is.null(tr)) return(NULL)
  tryCatch(tr$set_translation_language(language), error = function(e) NULL)
  tr
}

#' Translate one string, falling back to the string itself
#'
#' @param i18n A translator or `NULL`.
#' @param text The English source string, which is also the lookup key.
#' @noRd
i18n_t <- function(i18n, text) {
  if (is.null(i18n)) return(text)
  out <- tryCatch(i18n$t(text), error = function(e) text)
  if (is.null(out) || !length(out)) text else out
}
