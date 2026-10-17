tw <- function(f) utils::getFromNamespace(f, "DECIDE")

test_that("select-multiple answers are recognised, look-alikes are not", {
  ms <- tw("looks_multiselect")
  expect_true(ms(c("radio bike", "none", NA, "radio", "bike phone")))
  expect_true(ms(c("1 3", "2", "1 2 3", NA)))                          # numeric choice codes
  expect_false(ms(c("Nord Kivu", "Sud Kivu", "Ituri")))                  # place names
  expect_false(ms(c("Household 01", "Household 02")))                   # names
  expect_false(ms(c("2026-03-01 10:00:00", "2026-03-02 11:00:00")))     # date-times
  expect_false(ms(c("12.6392 -8.0029", "14.49 -4.19")))                 # GPS
  expect_false(ms(c("radio radio", "bike")))                             # a code twice
  expect_false(ms(c("single", "values", "only")))                        # nothing multiple
  sentences <- c("no money for food", "the road is closed", "we have no seeds", rep(c("radio", "bike"), 10))
  expect_false(ms(sentences))                                            # free text: one-off words
  expect_false(ms(1:5))
})

test_that("every select-multiple question becomes Yes/No columns, next to it", {
  d <- data.frame(id = 1:4, assets = c("radio bike", "none", NA, "radio"), region = c("Nord Kivu", "Sud Kivu", "Ituri", "Ituri"),
                  stringsAsFactors = FALSE)
  out <- tw("split_multiselect")(d, yes_no = c("Yes", "No"))
  expect_equal(names(out), c("id", "assets", "assets_radio", "assets_bike", "assets_none", "region"))
  expect_equal(out$assets_radio, c("Yes", "No", NA, "Yes"))
  expect_equal(out$assets_none, c("No", "Yes", NA, "No"))
  expect_equal(out$assets, d$assets)                                     # the question is kept
  fr <- tw("split_multiselect")(d, yes_no = c("Oui", "Non"))
  expect_equal(fr$assets_bike, c("Oui", "Non", NA, "Non"))
  # a question the form names is split even when its answers look plain
  k <- tw("split_multiselect")(data.frame(q = c("a", "b")), known = list(q = c("a", "b", "c")), yes_no = c("Yes", "No"))
  expect_equal(k$q_c, c("No", "No"))
})

test_that("choice columns already split by Kobo / ODK are relabelled Yes/No, not split again", {
  d <- data.frame(assets = c("radio bike", "bike"), "assets/radio" = c(1, 0), "assets/bike" = c("True", "True"),
                  other = c(1, 0), check.names = FALSE, stringsAsFactors = FALSE)
  out <- tw("split_multiselect")(d, yes_no = c("Yes", "No"))
  expect_equal(out$`assets/radio`, c("Yes", "No"))
  expect_equal(out$`assets/bike`, c("Yes", "Yes"))
  expect_equal(out$other, c(1, 0))                                       # no parent question: left alone
  expect_false(any(c("assets_radio", "assets_bike") %in% names(out)))   # not split twice
})

test_that("file imports split select-multiples and leave the demo data as it is", {
  f <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(data.frame(id = 1:3, assets = c("radio bike", "none", "radio")), f)
  got <- tw("read_import_file")(f, "csv")
  expect_equal(got$assets_bike, c("Yes", "No", "No"))
  for (p in c(system.file("extdata", "registration_demo.csv", package = "DECIDE"),
              system.file("extdata", "assessment_demo.csv", package = "DECIDE"),
              testthat::test_path("fixtures", "mini_targeting.csv"))) {
    raw <- data.table::fread(p, data.table = FALSE)
    expect_equal(names(tw("read_import_file")(p, "csv")), names(raw), info = basename(p))
  }
})
