test_that("exports keep accents, other scripts and emoji, and drop what breaks a file", {
  et <- DECIDE:::export_text
  latin1 <- iconv("C\u00f4te d'Ivoire", "UTF-8", "latin1")      # as read from an old file
  df <- data.frame(place = c("C\u00f4te d'Ivoire", "\u0645\u0631\u062d\u0628\u0627", "Nyiragongo \u2014 \u00e9t\u00e9", "bad\x01char"),
                   n = 1:4, stringsAsFactors = FALSE)
  df$place[1] <- latin1
  out <- et(df)
  expect_true(all(validUTF8(out$place)))
  expect_equal(out$place[1], "C\u00f4te d'Ivoire")
  expect_equal(out$place[2], "\u0645\u0631\u062d\u0628\u0627")
  expect_equal(out$place[4], "badchar")
  expect_equal(nchar(et(strrep("a", 40000))), 32767)

  # round trip through Excel and CSV
  f <- withr::local_tempfile(fileext = ".xlsx")
  wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, "s")
  DECIDE:::write_data(wb, "s", df); openxlsx::saveWorkbook(wb, f)
  back <- openxlsx::read.xlsx(f, "s")
  expect_equal(back$place[1:3], out$place[1:3])

  csv <- withr::local_tempfile(fileext = ".csv")
  DECIDE:::write_csv_utf8(df, csv)
  raw <- readBin(csv, "raw", 3)
  expect_equal(raw, as.raw(c(0xEF, 0xBB, 0xBF)))                 # UTF-8 byte-order mark for Excel
  back2 <- data.table::fread(csv, encoding = "UTF-8")
  expect_equal(back2$place[1:3], out$place[1:3])
})
