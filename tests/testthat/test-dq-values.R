# Data Quality > Category values: look-alike answers grouped, one spelling suggested.

test_that("variants of one answer group, distinct answers stay apart", {
  x <- c(rep("Oui", 50), rep("oui ", 5), rep("OUI", 3), rep("Non", 40), "non", rep("Refugee", 9), "R\u00e9fugi\u00e9", "Refugie",
         rep("M", 10), rep("F", 9), NA, "")
  v <- DECIDE:::value_groups(x)
  sug <- stats::setNames(v$suggestion, v$value)
  expect_equal(unname(sug[c("oui ", "OUI", "non", "Refugie")]), c("Oui", "Oui", "Non", "Refugee"))
  expect_equal(unname(sug[c("Oui", "Non", "M", "F")]), c("", "", "", ""))   # the most common, and short answers, unchanged
  expect_equal(v$group[v$value == "M"], 0L)
  expect_false(any(is.na(v$value) | !nzchar(trimws(v$value))))
  expect_equal(sum(v$records), 129)
})

test_that("replacing values changes only those records, and a factor becomes text", {
  r <- DECIDE:::value_replace(factor(c("oui", "Oui", "Non", NA)), c(oui = "Oui"))
  expect_equal(r$x, c("Oui", "Oui", "Non", NA))
  expect_equal(r$n, 1)
})

test_that("only qualitative columns are offered, areas and ids left out", {
  d <- data.frame(id = sprintf("H%03d", 1:120), prov = rep(c("A", "B"), 60), sex = rep(c("Male", "male", "Female"), 40),
                  age = 1:120, stringsAsFactors = FALSE)
  expect_equal(DECIDE:::value_cols(d, list(unique_id = "id", admin1 = "prov")), "sex")
})

test_that("the same answer in other words is proposed as a translation, typos as spelling", {
  v <- DECIDE:::value_groups(c(rep("Male", 70), rep("male", 9), rep("Homme", 30), rep("Female", 50), rep("Femme", 20)))
  k <- stats::setNames(v$kind, v$value); sug <- stats::setNames(v$suggestion, v$value)
  expect_equal(unname(k[c("male", "Homme", "Femme")]), c("spelling", "translation", "translation"))
  expect_equal(unname(sug[c("Homme", "Femme")]), c("Male", "Female"))
  expect_equal(nrow(DECIDE:::value_groups(c("Homme", "Male"), synonyms = FALSE)[DECIDE:::value_groups(c("Homme", "Male"), synonyms = FALSE)$group > 0, ]), 0)
})

test_that("numbers among text answers get the text they stand for", {
  f <- DECIDE:::value_code_labels
  r <- f(c("Yes", "No", "1", "0"), c(50, 40, 10, 8))
  expect_equal(unname(r[c("1", "0")]), c("Yes", "No"))
  expect_equal(unname(f(c("Oui", "Non", "1", "2"), c(5, 5, 1, 1))[c("1", "2")]), c("Oui", "Non"))   # 2 = no when there is no 0
  expect_equal(unname(f(c("Homme", "Femme", "1", "2"), c(5, 5, 2, 2))[c("1", "2")]), c("Homme", "Femme"))
  lab <- f(c("Married", "Single", "1", "3"), c(5, 5, 2, 2), codes = c(Married = 1, Widowed = 3))   # value labels first
  expect_equal(unname(lab[c("1", "3")]), c("Married", "Widowed"))
  expect_equal(unname(attr(lab, "source")[c("1", "3")]), c("labels", "labels"))
  expect_length(f(c("Red", "Blue", "1"), c(3, 3, 1)), 0)                                          # nothing usual to guess
  expect_length(f(c("1", "2"), c(3, 3)), 0)                                                       # numbers only: not mixed
})
