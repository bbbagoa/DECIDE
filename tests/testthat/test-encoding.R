
# Names and answers with accents, cedillas, apostrophes, Arabic and emoji-free
# symbols, as field data carries them. Written with \u escapes so this file
# stays ASCII.
enc_sample <- function() {
  data.frame(
    id = 1:4,
    "R\u00e9gion" = c("S\u00e9gou", "K\u00e9dougou", "Mopti \u2013 Centre", "Nord-Kivu"),
    village = c("Kanf\u00e9", "\u00c7a\u00e9", "B\u00e9nou\u00e9 d\u2019en haut", "\u0627\u0644\u0645\u0648\u0635\u0644"),
    note = c("\u0153uvre", "caf\u00e9 \u20ac5", "na\u00efve", "\u00fc\u00f1\u00ee"),
    check.names = FALSE, stringsAsFactors = FALSE
  )
}
read_back <- function(path, ext) TargetWise:::read_import_file(path, ext)
expect_same_text <- function(got, want) {
  expect_equal(names(got), names(want))
  for (k in c("R\u00e9gion", "village", "note")) {
    expect_equal(as.character(got[[k]]), want[[k]], info = k)
    expect_true(all(validUTF8(as.character(got[[k]]))), info = k)
  }
}

test_that("special characters survive every import format", {
  want <- enc_sample()
  dir <- withr::local_tempdir()

  # CSV, UTF-8 without and with a byte-order mark (Excel's "CSV UTF-8")
  f <- file.path(dir, "utf8.csv")
  data.table::fwrite(want, f)
  expect_same_text(read_back(f, "csv"), want)
  f <- file.path(dir, "bom.csv")
  data.table::fwrite(want, f, bom = TRUE)
  expect_same_text(read_back(f, "csv"), want)

  # CSV from Excel on a French Windows: Windows-1252, semicolons. Arabic cannot
  # be written in that encoding, so that row is left out.
  w <- want[1:3, ]
  f <- file.path(dir, "cp1252.csv")
  lines <- c(paste(names(w), collapse = ";"), apply(w, 1, paste, collapse = ";"))
  writeBin(unlist(lapply(paste0(lines, "\r\n"), function(l) iconv(l, "UTF-8", "CP1252", toRaw = TRUE)[[1]])), f)
  expect_false(validUTF8(rawToChar(readBin(f, "raw", 1e4))))
  got <- read_back(f, "csv")
  expect_same_text(got, w)

  # Excel
  f <- file.path(dir, "x.xlsx")
  openxlsx::write.xlsx(want, f)
  expect_same_text(read_back(f, "xlsx"), want)

  # SPSS and Stata, with value labels carrying accents too
  lab <- want
  lab$sexe <- haven::labelled(c(1, 2, 1, 2), c("F\u00e9minin" = 1, "Masculin" = 2))
  f <- file.path(dir, "x.sav")
  haven::write_sav(lab, f)
  got <- read_back(f, "sav")
  expect_same_text(got[names(want)], want)
  expect_equal(as.character(got$sexe), c("F\u00e9minin", "Masculin", "F\u00e9minin", "Masculin"))
  f <- file.path(dir, "x.dta")
  names(lab)[2] <- "Region"            # Stata names are plain identifiers
  haven::write_dta(lab, f)
  got <- read_back(f, "dta")
  expect_equal(got$village, want$village, ignore_attr = TRUE)
  expect_equal(as.character(got$sexe)[1], "F\u00e9minin")

  # Parquet
  f <- file.path(dir, "x.parquet")
  nanoparquet::write_parquet(want, f)
  expect_same_text(read_back(f, "parquet"), want)
})

test_that("text in another encoding is converted value by value", {
  u <- TargetWise:::utf8_text
  latin <- iconv("S\u00e9gou", "UTF-8", "CP1252")
  Encoding(latin) <- "unknown"
  x <- u(c(latin, "K\u00e9dougou", NA, "plain"))
  expect_equal(x, c("S\u00e9gou", "K\u00e9dougou", NA, "plain"))
  expect_true(all(validUTF8(x[!is.na(x)])))
  f <- TargetWise:::utf8_frame(data.frame("\ufeffid" = 1, v = factor(latin), check.names = FALSE))
  expect_equal(names(f), c("id", "v"))
  expect_equal(levels(f$v), "S\u00e9gou")
})

test_that("special characters reach the reports and Excel exports intact", {
  want <- enc_sample()
  f <- withr::local_tempfile(fileext = ".html")
  TargetWise:::report_write_page(f, "# R\u00e9sum\u00e9\n\nS\u00e9gou, \u0627\u0644\u0645\u0648\u0635\u0644, caf\u00e9 \u20ac5",
                                 title = "Test", record = "Test")
  html <- paste(readLines(f, encoding = "UTF-8"), collapse = "\n")
  expect_match(html, "S\u00e9gou, \u0627\u0644\u0645\u0648\u0635\u0644, caf\u00e9 \u20ac5", fixed = TRUE)
  expect_match(html, '<meta charset="utf-8">', fixed = TRUE)
  x <- withr::local_tempfile(fileext = ".xlsx")
  TargetWise:::write_xlsx_readonly(want, x)
  back <- readxl::read_excel(x)
  expect_equal(back$village, want$village)
  expect_equal(names(back), names(want))
})
