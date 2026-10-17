
# Two MODA pages as ONA returns them: a GPS answer as one text, _geolocation
# as [lat, lon], a select_multiple as space-separated names, a repeat group
# and attachments as nested tables.
ona_pages <- function() {
  p1 <- '[{"_id": 1, "grp/gps": "12.6392 -8.0029 350 4.5", "_geolocation": [12.6392, -8.0029],
          "grp/assets": "radio bike", "grp/sex": "f",
          "members": [{"members/age": 30}, {"members/age": 5}],
          "_attachments": [{"filename": "a.jpg"}]},
         {"_id": 2, "grp/gps": "14.4974 -4.1983 280 6", "_geolocation": [14.4974, -4.1983],
          "grp/assets": "none", "grp/sex": "m", "members": [], "_attachments": []}]'
  p2 <- '[{"_id": 3, "grp/gps": null, "_geolocation": [null, null], "grp/assets": null, "grp/sex": "f",
          "members": [{"members/age": 41}], "_attachments": []}]'
  lapply(c(p1, p2), jsonlite::fromJSON, flatten = TRUE)
}
xlsform <- function() {
  f <- withr::local_tempfile(fileext = ".xlsx", .local_envir = parent.frame())
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "survey"); openxlsx::addWorksheet(wb, "choices")
  openxlsx::writeData(wb, "survey", data.frame(type = c("geopoint", "select_multiple assets", "select_one sex"),
                                                name = c("gps", "assets", "sex"), label = c("GPS", "Assets", "Sex")))
  openxlsx::writeData(wb, "choices", data.frame(list_name = c("assets", "assets", "assets", "assets", "sex", "sex"),
                                                 name = c("radio", "bike", "phone", "none", "f", "m"),
                                                 label = c("Radio", "Bicycle", "Mobile phone", "None", "Female", "Male")))
  openxlsx::saveWorkbook(wb, f)
  f
}

test_that("a MODA download comes out as plain columns: GPS, geolocation, multi-select, repeats", {
  tw <- function(f) utils::getFromNamespace(f, "DECIDE")
  pages <- tw("harmonize_pages")(ona_pages())
  df <- dplyr::bind_rows(pages)
  names(df) <- tw("make_unique_names")(tw("strip_prefix")(names(df)))
  df <- tw("apply_odk_labels")(df, tw("build_odk_label_map")(xlsform()))
  df <- tw("split_geopoints")(df)

  # location: from the GPS question and from _geolocation, as numbers
  expect_equal(df$gps_latitude, c(12.6392, 14.4974, NA))
  expect_equal(df$gps_longitude, c(-8.0029, -4.1983, NA))
  expect_equal(df$gps_altitude, c(350, 280, NA))
  expect_equal(df$gps_precision, c(4.5, 6, NA))
  expect_equal(df$`_geolocation_latitude`, c(12.6392, 14.4974, NA))
  expect_equal(df$`_geolocation_longitude`, c(-8.0029, -4.1983, NA))
  expect_false(any(grepl("^c\\(", as.character(unlist(df)))))
  # the setup finds them
  expect_equal(tw("find_guess")(names(df), c("lat", "latitude")), "gps_latitude")

  # select_multiple: one Yes/No column per choice, next to the question
  expect_equal(as.character(df$assets_radio), c("Yes", "No", NA)); expect_equal(as.character(df$assets_bike), c("Yes", "No", NA))
  expect_equal(as.character(df$assets_phone), c("No", "No", NA)); expect_equal(as.character(df$assets_none), c("No", "Yes", NA))
  expect_equal(as.character(df$assets), c("Radio; Bicycle", "None", NA))
  i <- match("assets", names(df))
  expect_equal(names(df)[i + 1:4], c("assets_radio", "assets_bike", "assets_phone", "assets_none"))
  # select_one: labelled, not split
  expect_equal(as.character(df$sex), c("Female", "Male", "Female"))
  expect_false("sex_f" %in% names(df))

  # repeat groups and attachments: how many entries
  expect_equal(df$members_count, c(2L, 0L, 1L))
  expect_equal(df$`_attachments_count`, c(1L, 0L, 0L))
})

test_that("GPS-like text is only split when every answer is a valid point", {
  sg <- utils::getFromNamespace("split_geopoints", "DECIDE")
  d <- data.frame(id = 1:3, loc = c("1.5 2.5", "3 4", NA), code = c("12 34", "56 78", "9 10"),
                  note = c("12.1 3.4", "hello", NA), bad = c("95 10", "1 2", NA), stringsAsFactors = FALSE)
  out <- sg(d)
  expect_equal(out$loc_latitude, c(1.5, 3, NA))
  expect_equal(names(out)[1:4], c("id", "loc", "loc_latitude", "loc_longitude"))
  expect_false("note_latitude" %in% names(out))     # not every answer is a point
  expect_false("bad_latitude" %in% names(out))      # latitude 95 is impossible
  # whole numbers are not a place ("1 3" is a multi-select answer)
  expect_false("code_latitude" %in% names(out))
})

test_that("the import summary says what was done with the form", {
  tw <- function(f) utils::getFromNamespace(f, "DECIDE")
  pages <- tw("harmonize_pages")(ona_pages())
  df <- dplyr::bind_rows(pages)
  names(df) <- tw("make_unique_names")(tw("strip_prefix")(names(df)))
  before <- names(df)
  lm <- tw("build_odk_label_map")(xlsform())
  df <- tw("split_geopoints")(tw("apply_odk_labels")(df, lm))
  notes <- vapply(tw("form_import_notes")(before, df, lm, downloaded = TRUE), `[[`, "", "text")
  expect_equal(notes[1], "Choice labels applied to 2 questions (label).")
  expect_equal(notes[2], "1 select-multiple question split into 4 Yes/No columns.")
  expect_equal(notes[3], "GPS split into latitude and longitude: gps.")
  no_form <- tw("form_import_notes")(before, df, NULL, downloaded = FALSE)
  expect_false(no_form[[1]]$ok); expect_match(no_form[[1]]$text, "could not be downloaded")
  html <- as.character(tw("import_summary_modal")(df, label = "MODA: Enquete PDM (form 123)",
                                                  notes = tw("form_import_notes")(before, df, lm, TRUE)))
  expect_match(html, "Data imported", fixed = TRUE)
  expect_match(html, "MODA: Enquete PDM (form 123)", fixed = TRUE)
  expect_match(html, "From the form", fixed = TRUE)
  expect_match(html, "Continue with this data", fixed = TRUE)
})

test_that("the label column follows the app language when the form has several", {
  tw <- function(f) utils::getFromNamespace(f, "DECIDE")
  f <- withr::local_tempfile(fileext = ".xlsx")
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "survey"); openxlsx::addWorksheet(wb, "choices")
  openxlsx::writeData(wb, "survey", data.frame(type = "select_one sex", name = "sex"))
  openxlsx::writeData(wb, "choices", data.frame(list_name = "sex", name = c("f", "m"),
                                                 "label::French (fr)" = c("Femme", "Homme"),
                                                 "label::English (en)" = c("Female", "Male"), check.names = FALSE))
  openxlsx::saveWorkbook(wb, f)
  lm <- tw("build_odk_label_map")(f)            # outside a session: English
  expect_equal(unname(lm$sex[c("f", "m")]), c("Female", "Male"))
  expect_equal(attr(lm, "label_column"), "label::English (en)")
})
