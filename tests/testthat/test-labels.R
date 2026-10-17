test_that("SPSS labels: categories become factors, numbers with a code stay numbers", {
  f <- withr::local_tempfile(fileext = ".sav")
  d <- data.frame(id = 1:4, age = c(34, 51, 99, 28), sex = c(1, 2, 2, 1))
  d$age <- haven::labelled(d$age, c("Don't know" = 99), label = "Age of the head of household")
  d$sex <- haven::labelled(d$sex, c(Male = 1, Female = 2), label = "Sex of the head of household")
  haven::write_sav(d, f)
  x <- DECIDE:::read_import_file(f, "sav")
  expect_true(is.numeric(x$age))
  expect_equal(as.numeric(x$age), c(34, 51, 99, 28))
  expect_equal(attr(x$age, "tw_codes"), c("Don't know" = 99))
  expect_true(is.factor(x$sex))
  expect_equal(as.character(x$sex), c("Male", "Female", "Female", "Male"))
  l <- DECIDE:::labels_of(x)
  expect_equal(l$labels[["sex"]], "Sex of the head of household")
  expect_equal(DECIDE:::codes_text(l$codes$sex), "1 = Male; 2 = Female")
})

test_that("the session dictionary survives filters, reaches exports and sessions", {
  s <- shiny::MockShinySession$new()
  x <- data.frame(HHHSex = c("Male", "Female"), n = 1:2)
  attr(x$HHHSex, "label") <- "Sex of the head of household"
  attr(x$HHHSex, "tw_codes") <- c(Male = "1", Female = "2")
  DECIDE:::register_labels(x, session = s)
  y <- x[x$n > 1, , drop = FALSE]          # the column attribute is gone...
  expect_null(attr(y$HHHSex, "label"))
  expect_equal(DECIDE:::var_label("HHHSex", s), "Sex of the head of household")  # ...the dictionary is not
  v <- DECIDE:::variables_table(c("HHHSex", "n"), s)
  expect_equal(v$Label, c("Sex of the head of household", ""))
  # every export gets a Variables sheet for the labelled columns it shows
  f <- withr::local_tempfile(fileext = ".xlsx")
  shiny::withReactiveDomain(s, {
    wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, "Data"); openxlsx::writeData(wb, "Data", y)
    DECIDE:::save_workbook_readonly(wb, f)
  })
  expect_true("Variables" %in% openxlsx::getSheetNames(f))
  expect_match(paste(unlist(openxlsx::read.xlsx(f, "Variables")), collapse = " "), "1 = Male; 2 = Female")
  # and a Markdown section for the reports
  expect_true(any(grepl("Sex of the head of household", DECIDE:::variables_md("HHHSex", s))))
})

test_that("MODA forms give question labels, and split choices read Question: Choice", {
  f <- withr::local_tempfile(fileext = ".xlsx")
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "survey"); openxlsx::addWorksheet(wb, "choices")
  openxlsx::writeData(wb, "survey", data.frame(type = c("select_one sex", "select_multiple src", "integer"),
                                               name = c("HHHSex", "income", "HHSize"),
                                               `label::English (en)` = c("Sex of the head", "Income sources", "Household size"),
                                               check.names = FALSE))
  openxlsx::writeData(wb, "choices", data.frame(list_name = c("sex", "sex", "src", "src"), name = c("1", "2", "crop", "trade"),
                                                `label::English (en)` = c("Male", "Female", "Crops", "Petty trade"),
                                                check.names = FALSE))
  openxlsx::saveWorkbook(wb, f)
  m <- DECIDE:::build_odk_label_map(f)
  df <- data.frame(HHHSex = c("1", "2"), income = c("crop trade", "crop"), HHSize = c(4, 6))
  out <- DECIDE:::apply_odk_labels(df, m)
  expect_equal(as.character(out$HHHSex), c("Male", "Female"))
  expect_equal(attr(out$HHHSex, "label"), "Sex of the head")
  expect_equal(attr(out$HHSize, "label"), "Household size")
  expect_equal(attr(out$income_trade, "label"), "Income sources: Petty trade")
  expect_equal(unname(attr(out$HHHSex, "tw_codes")[["Male"]]), "1")
})

test_that("value dropdowns read 'Code - Label', values unchanged", {
  s <- shiny::MockShinySession$new()
  x <- data.frame(sex = factor(c("Male", "Female")))
  attr(x$sex, "tw_codes") <- c(Male = 1, Female = 2)
  DECIDE:::register_labels(x, session = s)
  ch <- DECIDE:::value_choices(c("Female", "Male", "Other"), "sex", s)
  expect_equal(unname(ch), c("Female", "Male", "Other"))
  expect_equal(names(ch), c("2 - Female", "1 - Male", "Other"))
  expect_equal(DECIDE:::value_choices(c("a", "b"), "nocodes", s), c("a", "b"))
  expect_true("sex" %in% DECIDE:::label_registry(s)$cols)
})

test_that("admin areas get their labels: cascading lists, attached CSVs, old headers", {
  survey <- data.frame(type = c("select_one prov", "select_one dist", "select_one_from_file villages.csv", "select_one hh_status"),
                       name = c("admin1", "admin2", "village", "status"),
                       label = c("Province", "District", "Village", "Status"),
                       choice_filter = c(NA, "prov=${admin1}", NA, NA), stringsAsFactors = FALSE)
  # "list name" with a space, as older forms write it; district codes reused per province
  choices <- data.frame(`list name` = c("prov", "prov", "dist", "dist", "dist", "hh_status"),
                        name = c("P1", "P2", "01", "02", "01", "idp"),
                        label = c("North", "South", "Alpha", "Beta", "Gamma", "Displaced"),
                        prov = c(NA, NA, "P1", "P1", "P2", NA), check.names = FALSE, stringsAsFactors = FALSE)
  f <- withr::local_tempfile(fileext = ".xlsx")
  wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, "survey"); openxlsx::addWorksheet(wb, "choices")
  openxlsx::writeData(wb, "survey", survey); openxlsx::writeData(wb, "choices", choices); openxlsx::saveWorkbook(wb, f)
  csv <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(data.frame(name = c("v1", "v2"), label = c("Kasai village", "Lomami village")), csv, row.names = FALSE)

  m <- DECIDE:::build_odk_label_map(f, media = list(villages.csv = csv))
  expect_setequal(names(m), c("admin1", "admin2", "village", "status"))
  d <- data.frame(admin1 = c("P1", "P1", "P2"), admin2 = c("01", "02", "01"), village = c("v1", "v2", "v1"),
                  status = c("idp", "idp", "idp"), stringsAsFactors = FALSE)
  out <- DECIDE:::apply_odk_labels(d, m)
  expect_equal(as.vector(out$admin1), c("North", "North", "South"))
  expect_equal(as.vector(out$admin2), c("Alpha", "Beta", "Gamma"))     # "01" is Alpha in P1, Gamma in P2
  expect_equal(as.vector(out$village), c("Kasai village", "Lomami village", "Kasai village"))
  expect_equal(as.vector(out$status), rep("Displaced", 3))
  # without the attached file the codes stay, nothing breaks
  expect_false("village" %in% names(DECIDE:::build_odk_label_map(f)))
})
