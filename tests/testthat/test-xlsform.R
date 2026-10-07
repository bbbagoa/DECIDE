test_that("the draft XLSForm rebuilds the score, eligibility and both categories", {
  w <- data.frame(criterion = c("no_latrine", "owns_cattle"), label = c("No latrine", "Owns 2+ cattle"),
                  direction = c("inclusion", "exclusion"), weight = c(3, 1.5), stringsAsFactors = FALSE)
  sc <- build_scorecard(w, threshold = 2)
  sc$adopted_at <- "07/10/2026 10:00"
  areas <- data.frame(Province = c("Ituri", "Ituri", "Nord Kivu"), Territoire = c("Djugu", "Irumu", "Beni"))
  x <- xlsform_draft(sc, cuts = list(quartiles = c(0, 1.5, 3), quintiles = c(0, 1, 2, 3)), areas = areas)
  s <- x$survey
  expect_true(all(c("type", "name", "label::English (en)", "label::French (fr)", "calculation", "choice_filter") %in% names(s)))
  expect_equal(s[["label::French (fr)"]][s$name == "hhh_first_name"], "Pr\u00e9nom")
  expect_equal(s[["label::French (fr)"]][s$name == "admin1"], character(0))   # areas from the data here
  expect_equal(s[["label::French (fr)"]][s$name == "no_latrine"], "No latrine")  # data labels copied as they are
  expect_equal(x$choices[["label::French (fr)"]][x$choices$list_name == "yes_no"], c("Oui", "Non"))
  expect_equal(x$settings$default_language, "English (en)")
  expect_equal(s$type[s$name == "no_latrine"], "select_one yes_no")
  expect_equal(s$calculation[s$name == "pts_no_latrine"], "if(${no_latrine} = '1', 3, 0)")
  expect_equal(s$calculation[s$name == "pts_owns_cattle"], "if(${owns_cattle} = '1', -1.5, 0)")
  expect_equal(s$calculation[s$name == "eligible"], "if(${vuln_score} > 2, 1, 0)")
  expect_true(startsWith(s$calculation[s$name == "vuln_score"], "if(${vuln_score_raw} < 0, 0"))
  expect_equal(s$calculation[s$name == "vuln_quartile"],
               "if(${vuln_score} <= 0, 1, if(${vuln_score} <= 1.5, 2, if(${vuln_score} <= 3, 3, 4)))")
  expect_true(endsWith(s$calculation[s$name == "vuln_quintile"], ", 5))))"))
  # cascading areas: the territory list is filtered by the province
  expect_equal(s$choice_filter[s$name == "Territoire"], "Province = ${Province}")
  terr <- x$choices[x$choices$list_name == "Territoire", ]
  expect_equal(terr$Province[terr$name == "Beni"], "Nord_Kivu")
  expect_equal(x$choices$name[x$choices$list_name == "yes_no"], c("1", "0"))
  f <- tempfile(fileext = ".xlsx"); xlsform_write(x, f)
  expect_equal(openxlsx::getSheetNames(f), c("survey", "choices", "settings", "About this draft"))
})

test_that("a PMT draft is not floored and scores numeric proxies per unit", {
  w <- data.frame(criterion = c("rooms", "no_roof"), label = c("Rooms", "No roof"), direction = c("exclusion", "inclusion"),
                  weight = c(12, 30), type = c("numeric", "binary"), mean = c(2.4, NA), stringsAsFactors = FALSE)
  sc <- build_scorecard(w, threshold = 10, kind = "pmt", pmt = list(intercept = 5, line = 100))
  s <- xlsform_draft(sc)$survey
  expect_equal(s$type[s$name == "rooms"], "decimal")
  expect_equal(s$calculation[s$name == "pts_rooms"], "-1 * ${rooms} * 12")
  expect_equal(s$calculation[s$name == "vuln_score"], "${vuln_score_raw}")
  expect_true("admin1" %in% s$name)   # no area data: asked as text
})

test_that("the draft asks the beneficiary's identity and keeps criterion names unique", {
  w <- data.frame(criterion = c("hh_size", "no_roof"), label = c("Large household", "No roof"),
                  direction = c("inclusion", "inclusion"), weight = c(1, 2), stringsAsFactors = FALSE)
  x <- xlsform_draft(build_scorecard(w, threshold = 1))
  s <- x$survey
  expect_true(all(c("hhh_first_name", "hhh_last_name", "hhh_other_name", "hhh_sex", "hhh_dob", "hhh_age",
                    "hhh_marital_status", "hhh_phone", "hhh_id_type", "hhh_id_number", "hh_size") %in% s$name))
  expect_equal(s$required[s$name == "hhh_other_name"], "")
  expect_true("hh_size_crit" %in% s$name)                 # the criterion does not clash with the household size question
  expect_false(any(duplicated(s$name[!s$type %in% c("end_group")])))
  expect_true(all(c("sex", "marital", "id_type", "relation") %in% x$choices$list_name))
  expect_equal(s$type[s$name == "hhh_photo"], "image")
  expect_equal(s$relevant[s$name == "alternate" & s$type == "begin_group"], "${has_alternate} = '1'")
  expect_true(all(c("alt_first_name", "alt_last_name", "alt_sex", "alt_age", "alt_photo") %in% s$name))
  expect_equal(s$required[s$name == "alt_photo"], "")
})
