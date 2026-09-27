test_that("SPSS labels: categories become factors, numbers with a code stay numbers", {
  f <- withr::local_tempfile(fileext = ".sav")
  d <- data.frame(id = 1:4, age = c(34, 51, 99, 28), sex = c(1, 2, 2, 1))
  d$age <- haven::labelled(d$age, c("Don't know" = 99), label = "Age of the head of household")
  d$sex <- haven::labelled(d$sex, c(Male = 1, Female = 2), label = "Sex of the head of household")
  haven::write_sav(d, f)
  x <- TargetWise:::read_import_file(f, "sav")
  expect_true(is.numeric(x$age))
  expect_equal(as.numeric(x$age), c(34, 51, 99, 28))
  expect_equal(attr(x$age, "tw_codes"), c("Don't know" = 99))
  expect_true(is.factor(x$sex))
  expect_equal(as.character(x$sex), c("Male", "Female", "Female", "Male"))
  l <- TargetWise:::labels_of(x)
  expect_equal(l$labels[["sex"]], "Sex of the head of household")
  expect_equal(TargetWise:::codes_text(l$codes$sex), "1 = Male; 2 = Female")
})

test_that("the session dictionary survives filters, reaches exports and sessions", {
  s <- shiny::MockShinySession$new()
  x <- data.frame(HHHSex = c("Male", "Female"), n = 1:2)
  attr(x$HHHSex, "label") <- "Sex of the head of household"
  attr(x$HHHSex, "tw_codes") <- c(Male = "1", Female = "2")
  TargetWise:::register_labels(x, session = s)
  y <- x[x$n > 1, , drop = FALSE]          # the column attribute is gone...
  expect_null(attr(y$HHHSex, "label"))
  expect_equal(TargetWise:::var_label("HHHSex", s), "Sex of the head of household")  # ...the dictionary is not
  v <- TargetWise:::variables_table(c("HHHSex", "n"), s)
  expect_equal(v$Label, c("Sex of the head of household", ""))
  # every export gets a Variables sheet for the labelled columns it shows
  f <- withr::local_tempfile(fileext = ".xlsx")
  shiny::withReactiveDomain(s, {
    wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, "Data"); openxlsx::writeData(wb, "Data", y)
    TargetWise:::save_workbook_readonly(wb, f)
  })
  expect_true("Variables" %in% openxlsx::getSheetNames(f))
  expect_match(paste(unlist(openxlsx::read.xlsx(f, "Variables")), collapse = " "), "1 = Male; 2 = Female")
  # and a Markdown section for the reports
  expect_true(any(grepl("Sex of the head of household", TargetWise:::variables_md("HHHSex", s))))
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
  m <- TargetWise:::build_odk_label_map(f)
  df <- data.frame(HHHSex = c("1", "2"), income = c("crop trade", "crop"), HHSize = c(4, 6))
  out <- TargetWise:::apply_odk_labels(df, m)
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
  TargetWise:::register_labels(x, session = s)
  ch <- TargetWise:::value_choices(c("Female", "Male", "Other"), "sex", s)
  expect_equal(unname(ch), c("Female", "Male", "Other"))
  expect_equal(names(ch), c("2 - Female", "1 - Male", "Other"))
  expect_equal(TargetWise:::value_choices(c("a", "b"), "nocodes", s), c("a", "b"))
  expect_true("sex" %in% TargetWise:::label_registry(s)$cols)
})
