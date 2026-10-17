test_that("the translation file is well formed and complete for every language", {
  path <- DECIDE:::i18n_path()
  expect_true(file.exists(path))

  raw <- jsonlite::fromJSON(path, simplifyDataFrame = FALSE)
  langs <- unlist(raw$languages)
  expect_setequal(langs, c("en", "fr"))

  # Every entry must carry every language: a half-filled row is what produces
  # a French interface with random English strings in it.
  missing <- vapply(raw$translation, function(e) {
    any(!langs %in% names(e)) ||
      any(vapply(langs, function(l) !nzchar(e[[l]] %||% ""), logical(1)))
  }, logical(1))
  expect_equal(sum(missing), 0,
               info = paste("entries missing a language:",
                            paste(utils::head(which(missing), 5), collapse = ", ")))

  # The English string IS the key: shiny.i18n turns the table into a data
  # frame with those as row names, so a single duplicate stops the translator
  # constructing at all and the whole interface silently stays English.
  en <- vapply(raw$translation, function(e) e$en, character(1))
  expect_equal(anyDuplicated(en), 0L,
               info = paste("duplicated key:", en[anyDuplicated(en)]))
})

test_that("a translator returns the right language and falls back to English", {
  skip_if_not_installed("shiny.i18n")

  fr <- DECIDE:::app_i18n("fr")
  skip_if(is.null(fr), "shiny.i18n translator unavailable")
  expect_equal(DECIDE:::i18n_t(fr, "Overview"), "Vue d'ensemble")
  expect_equal(DECIDE:::i18n_t(fr, "Households"), "Ménages")

  en <- DECIDE:::app_i18n("en")
  expect_equal(DECIDE:::i18n_t(en, "Overview"), "Overview")

  # An untranslated string comes back as itself, not as a missing-key marker:
  # coverage is partial by design, so English must always be the fallback.
  expect_equal(DECIDE:::i18n_t(fr, "Some label nobody translated yet"),
               "Some label nobody translated yet")
})

test_that("the app still renders when the translation layer is unavailable", {
  # i18n_t(NULL, x) is the path taken if shiny.i18n or the JSON goes missing;
  # the interface must degrade to English rather than fail to start.
  expect_equal(DECIDE:::i18n_t(NULL, "Overview"), "Overview")
  expect_equal(DECIDE:::i18n_t(NULL, "Anything"), "Anything")
})

test_that("each translator is independent, so one user cannot change another's language", {
  skip_if_not_installed("shiny.i18n")
  a <- DECIDE:::app_i18n("fr")
  b <- DECIDE:::app_i18n("en")
  skip_if(is.null(a) || is.null(b), "shiny.i18n translator unavailable")
  expect_equal(DECIDE:::i18n_t(a, "Overview"), "Vue d'ensemble")
  expect_equal(DECIDE:::i18n_t(b, "Overview"), "Overview")
  # a is untouched by b existing.
  expect_equal(DECIDE:::i18n_t(a, "Overview"), "Vue d'ensemble")
})
