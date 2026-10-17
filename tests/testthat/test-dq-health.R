test_that("dq_health finds repeated ids, gaps, outliers, odd names and spelling variants", {
  df <- data.frame(
    id = c(1, 1, 2:20), prov = c("Ituri", "Iturri", rep("Ituri", 17), "", "Nord-Kivu"),
    size = c(rep(5, 19), 60, 4), age = c(rep(40, 20), NA),
    head_name = c("A", "Jean K4sereka", rep("Marie Bisimwa", 18), "test"), stringsAsFactors = FALSE)
  h <- dq_health(df, list(unique_id = "id", admin1 = "prov", hh_size = "size", hhh_age = "age"))
  expect_equal(nrow(h), 6)
  st <- stats::setNames(h$status, h$check)
  expect_equal(unname(st["Duplicates"]), "review")
  expect_equal(unname(st["Outliers"]), "review")
  expect_equal(unname(st["Names and spelling"]), "review")   # people's names: one letter, a digit, a placeholder
  expect_match(h$found[h$check == "Names and spelling"], "^3 records.*head_name")
  expect_equal(dq_health(df[c("id", "prov")], list(unique_id = "id", admin1 = "prov"))$status[4], "na")   # no name column
  expect_equal(unname(st["Location names"]), "review")
  expect_equal(unname(st["Enumerators"]), "na")
  expect_true(all(h$tab %in% c("Duplicates", "Missing Data Checking", "Outliers", "Spelling & Integrity",
                               "Location names normalization", "Enumerator Performance")))
})
