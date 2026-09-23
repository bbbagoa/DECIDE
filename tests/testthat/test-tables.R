# Record-listing helpers: which columns identify a row, and finding a row again

fake_setup <- function(...) {
  s <- list(unique_id = "uid", admin1 = "Prov", admin2 = "Terr",
            admin3 = "", admin4 = NULL, village = "Vil")
  utils::modifyList(s, list(...))
}

fake_df <- function() {
  data.frame(
    uid = c("a", "b"),
    Prov = c("P1", "P2"),
    Terr = c("T1", "T2"),
    Vil = c("V1", "V2"),
    Nom_cm = c("BORA", "NEEMA"),
    Prenom_cm = c("A", "B"),
    HHSize = c(5, 6),
    `_uuid` = c("u1", "u2"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

test_that("identification_cols keeps mapped admin levels in hierarchy order", {
  cols <- identification_cols(fake_df(), fake_setup())
  expect_equal(cols[1:4], c("uid", "Prov", "Terr", "Vil"))
})

test_that("identification_cols drops unmapped and absent levels", {
  cols <- identification_cols(fake_df(), fake_setup())
  # admin3 is "" and admin4 is NULL -> neither should appear
  expect_false(any(cols == ""))
  expect_length(setdiff(c("uid", "Prov", "Terr", "Vil"), cols), 0)

  # a mapped column that isn't in the data is dropped rather than erroring
  cols2 <- identification_cols(fake_df(), fake_setup(admin1 = "NotThere"))
  expect_false("NotThere" %in% cols2)
})

test_that("identification_cols detects name columns and caps how many", {
  cols <- identification_cols(fake_df(), fake_setup())
  expect_true(any(grepl("Nom_cm|Prenom_cm", cols)))
  # default cap is 2 name columns
  expect_lte(sum(cols %in% c("Nom_cm", "Prenom_cm")), 2)

  one <- identification_cols(fake_df(), fake_setup(), max_name_cols = 1)
  expect_equal(sum(one %in% c("Nom_cm", "Prenom_cm")), 1)
})

test_that("identification_cols never treats ODK metadata as a name", {
  df <- fake_df()
  df$`_submitted_by_name` <- c("x", "y")
  cols <- identification_cols(df, fake_setup())
  expect_false("_submitted_by_name" %in% cols)
})

test_that("identification_cols excludes analytical columns", {
  cols <- identification_cols(fake_df(), fake_setup())
  expect_false("HHSize" %in% cols)
})

test_that("identification_cols copes with an empty or absent frame", {
  expect_equal(identification_cols(NULL, fake_setup()), character(0))
  expect_equal(identification_cols(data.frame(), fake_setup()), character(0))
})

test_that("record_detail_buttons neutralises quotes in the row key", {
  html <- record_detail_buttons("O'Brien", "mod-view")
  expect_false(grepl("'O'Brien'", html, fixed = TRUE))
  expect_true(grepl("&#39;", html, fixed = TRUE))
  expect_true(grepl("mod-view", html, fixed = TRUE))
})

test_that("find_record matches on the unique id, not row order", {
  df <- fake_df()
  row <- find_record(df, fake_setup(), "b")
  expect_equal(nrow(row), 1)
  expect_equal(row$Nom_cm, "NEEMA")
})

test_that("find_record falls back to position when no id is mapped", {
  df <- fake_df()
  row <- find_record(df, fake_setup(unique_id = ""), "2")
  expect_equal(nrow(row), 1)
  expect_equal(row$Nom_cm, "NEEMA")
})

test_that("find_record returns zero rows for an unknown or out-of-range key", {
  df <- fake_df()
  expect_equal(nrow(find_record(df, fake_setup(), "zzz")), 0)
  expect_equal(nrow(find_record(df, fake_setup(unique_id = ""), "99")), 0)
  expect_equal(nrow(find_record(df, fake_setup(), NULL)), 0)
})

test_that("find_record returns a single row even if the id is duplicated", {
  df <- rbind(fake_df(), fake_df())
  expect_equal(nrow(find_record(df, fake_setup(), "a")), 1)
})

# The enumerator's name matches the same "nom"/"name" patterns as the
# household's, and used to win the limited name slots.

staff_df <- function() {
  data.frame(
    uid = "a", Prov = "P", Terr = "T", Vil = "V",
    nom_enqueteur = "FIELD STAFF",
    Nom_cm = "BORA",
    Prenom_cm = "AMINA",
    stringsAsFactors = FALSE
  )
}

test_that("a name column mapped to an analytical key is not an identifier", {
  cols <- identification_cols(staff_df(), fake_setup(enumerator_id = "nom_enqueteur"))
  expect_false("nom_enqueteur" %in% cols)
  expect_true(all(c("Nom_cm", "Prenom_cm") %in% cols))
})

test_that("survey-staff names rank below household names when unmapped", {
  # enumerator_id deliberately NOT mapped, so exclusion cannot do the work
  cols <- identification_cols(staff_df(), fake_setup(), max_name_cols = 2)
  expect_true(all(c("Nom_cm", "Prenom_cm") %in% cols))
  expect_false("nom_enqueteur" %in% cols)
})

test_that("a staff name is still offered when there is no household name", {
  df <- data.frame(uid = "a", Prov = "P", Terr = "T", Vil = "V",
                   nom_enqueteur = "FIELD STAFF", stringsAsFactors = FALSE)
  cols <- identification_cols(df, fake_setup())
  expect_true("nom_enqueteur" %in% cols)
})

test_that("other analytical mappings are excluded from name detection", {
  df <- data.frame(uid = "a", Prov = "P", Terr = "T", Vil = "V",
                   name_of_head_sex = "F", Nom_cm = "BORA", stringsAsFactors = FALSE)
  cols <- identification_cols(df, fake_setup(hhh_sex = "name_of_head_sex"))
  expect_false("name_of_head_sex" %in% cols)
  expect_true("Nom_cm" %in% cols)
})
