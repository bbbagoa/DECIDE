# Variable mapping for any country's data (R/utils_mapping.R)

fixture <- function() utils::read.csv(testthat::test_path("fixtures", "mini_targeting.csv"), stringsAsFactors = FALSE)

# The same households as a French-speaking office would export them.
french <- function() {
  d <- fixture()
  out <- data.frame(
    code_menage = d$instanceID,
    date_enquete = format(as.Date(d$SvyDate), "%d/%m/%Y"),
    enqueteur = d$enumerator,
    province = d$Province, territoire = d$Territoire, zone_de_sante = d$Zonesante,
    localite = d$Village,
    gps_latitude = d$lat, gps_longitude = d$lon,
    sexe_chef = ifelse(d$HHHSex == "Male", "Homme", "Femme"),
    date_naissance_chef = format(as.Date(d$SvyDate) - round(d$HHHAge * 365.25) - 30, "%d/%m/%Y"),
    taille_menage = d$HHSize,
    statut_residence = c(`IDP host family` = "PDI famille d'accueil", `IDP on site` = "PDI sur site", Refugee = "Refugie",
                         Resident = "Resident", Returnee = "Retourne")[d$HHStatus],
    handicap = ifelse(d$disability == "Yes", "Oui", "Non"),
    stringsAsFactors = FALSE)
  out$statut_residence[is.na(out$statut_residence)] <- ""
  out
}

test_that("names match on whole words, in several languages", {
  expect_equal(DECIDE:::name_score("Village", c("age", "hhh age")), 0)       # "age" is not in "village"
  expect_equal(DECIDE:::name_score("HHHAge", c("age", "hhh age")), 1)
  expect_equal(DECIDE:::name_score("idp_status", c("id")), 0)                # "id" is not in "idp"
  expect_gt(DECIDE:::name_score("taille_menage", DECIDE:::setup_field("hh_size")$syn), 0.8)
  expect_gt(DECIDE:::name_score("sexe_chef", DECIDE:::setup_field("hhh_sex")$syn), 0.8)
  # a generic word is weaker evidence than a specific one
  expect_lt(DECIDE:::name_score("FCS_class", DECIDE:::setup_field("v_groups")$syn), 0.75)
})

test_that("the guess finds every field of the English and the French export", {
  g <- DECIDE:::guess_mapping(fixture())
  got <- stats::setNames(g$column, g$key)
  expect_equal(unname(got[c("unique_id", "date", "admin1", "admin2", "admin3", "lon", "lat", "hhh_sex", "hhh_age", "hh_size", "residency")]),
               c("instanceID", "SvyDate", "Province", "Territoire", "Zonesante", "lon", "lat", "HHHSex", "HHHAge", "HHSize", "HHStatus"))
  f <- DECIDE:::guess_mapping(french())
  got <- stats::setNames(f$column, f$key)
  expect_equal(unname(got[c("unique_id", "date", "enumerator_id", "admin1", "admin2", "admin3", "village", "lon", "lat",
                            "hhh_sex", "hhh_age", "hh_size", "residency", "disability")]),
               c("code_menage", "date_enquete", "enqueteur", "province", "territoire", "zone_de_sante", "localite",
                 "gps_longitude", "gps_latitude", "sexe_chef", "date_naissance_chef", "taille_menage", "statut_residence", "handicap"))
  expect_true(all(f$confidence[nzchar(f$column)] %in% c("high", "medium", "low")))
  expect_equal(sum(duplicated(f$column[nzchar(f$column)])), 0)                  # a column is used once
})

test_that("labels help when names say nothing, and a fully unique column can be the id", {
  d <- data.frame(q1 = sprintf("H%03d", 1:50), q2 = rep(c("Nord", "Sud"), 25), q3 = sample(1:9, 50, TRUE), stringsAsFactors = FALSE)
  g <- DECIDE:::guess_mapping(d, labels = c(q2 = "Province", q3 = "Taille du menage"))
  got <- stats::setNames(g$column, g$key)
  expect_equal(unname(got[c("unique_id", "admin1", "hh_size")]), c("q1", "q2", "q3"))
})

test_that("dates are read whatever their format", {
  pd <- DECIDE:::parse_dates
  expect_equal(pd(c("27/09/2026", "01/02/2026"))$date, as.Date(c("2026-09-27", "2026-02-01")))
  expect_equal(pd(c("09/27/2026", "02/01/2026"))$date, as.Date(c("2026-09-27", "2026-02-01")))
  a <- pd(c("01/02/2026", "03/04/2026"))
  expect_true(a$ambiguous); expect_equal(a$format, "day/month/year")
  expect_equal(pd("2026-09-27 10:15:00")$date, as.Date("2026-09-27"))
  expect_equal(pd(c(46000, 46001))$format, "Excel serial number")
  expect_equal(pd(as.Date("2026-01-05"))$date, as.Date("2026-01-05"))
  expect_equal(pd(c("Ituri", "Beni"))$rate, 0)
})

test_that("values are standardised, and numeric sex codes are flagged as assumed", {
  s <- DECIDE:::recode_suggest(c("Homme", "Femme", "Femme", NA, ""), "sex")
  expect_equal(s$standard[match(c("Homme", "Femme"), s$value)], c("Male", "Female"))
  expect_true(attr(s, "needed"))
  expect_false(attr(DECIDE:::recode_suggest(c("Male", "Female"), "sex"), "needed"))
  n <- DECIDE:::recode_suggest(c(1, 2, 2), "sex")
  expect_true(all(n$assumed)); expect_true(attr(n, "needed"))
  r <- DECIDE:::recode_suggest(c("PDI sur site", "PDI famille d'accueil", "Refugie", "Retourne", "Resident", "autre", "x"), "residency")
  expect_equal(r$standard[match(c("PDI sur site", "PDI famille d'accueil", "Refugie", "Retourne", "Resident", "autre", "x"), r$value)],
               c("IDP", "IDP", "Refugee", "Returnee", "Resident", "Other", DECIDE:::STD_KEEP))
  expect_null(DECIDE:::recode_suggest(as.character(1:40), "sex"))           # not a category
  expect_equal(DECIDE:::apply_recode(c("Oui", "Non", "NSP"), list(Oui = "Yes", Non = "No", NSP = DECIDE:::STD_MISSING)),
               c("Yes", "No", NA))
})

test_that("checks block only what cannot be worked around", {
  d <- fixture()
  map <- list(unique_id = "instanceID", admin1 = "Province")
  expect_false(any(DECIDE:::mapping_checks(d, map)$level == "block"))
  expect_true(any(DECIDE:::mapping_checks(d, list(admin1 = "Province"))$level == "block"))     # no id
  d2 <- d; d2$instanceID[2] <- d2$instanceID[1]
  rep_id <- DECIDE:::mapping_checks(d2, map)
  expect_true(any(rep_id$level == "warn" & grepl("repeated", rep_id$message)))     # reported, cleaned in Duplicates
  expect_false(any(rep_id$level == "block"))
  gap <- DECIDE:::mapping_checks(d, list(unique_id = "instanceID", admin1 = "Province", admin3 = "Zonesante"))
  expect_true(any(gap$level == "block" & gap$field == "admin2"))                 # levels from the top
  d3 <- d; d3$lat[1:3] <- 0; d3$lon[1:3] <- 0; d3$lat[4] <- 35
  w <- DECIDE:::mapping_checks(d3, c(map, lon = "lon", lat = "lat"))
  expect_true(all(w$level[w$field == "lat"] == "warn"))
  expect_match(paste(w$message, collapse = " "), "0,0")
  expect_match(paste(w$message, collapse = " "), "more than 5 degrees")
  u5 <- DECIDE:::mapping_checks(d, c(map, hh_size = "HHSize", childU5 = "childU5"))
  expect_match(paste(u5$message, collapse = " "), "more children under 5 than members")
})

test_that("readiness says what each part of the app can do", {
  rd <- DECIDE:::data_readiness(list(unique_id = "id", admin1 = "a1"))
  st <- stats::setNames(rd$status, rd$feature)
  expect_equal(st[["Household counts"]], "Available")                            # no weight needed
  expect_equal(st[["Map of the households"]], "Not available")
  expect_equal(st[["Duplicates"]], "Available")
  expect_equal(st[["Household profiles"]], "Not available")
  expect_match(rd$detail[rd$feature == "Map of the households"], "gps longitude, gps latitude")
  full <- DECIDE:::data_readiness(as.list(stats::setNames(DECIDE:::setup_keys(), DECIDE:::setup_keys())))
  expect_true(all(full$status == "Available"))
})

test_that("the plan standardises into new columns, reads dates and derives age", {
  d <- french()
  map <- list(unique_id = "code_menage", date = "date_enquete", hhh_sex = "sexe_chef", hhh_age = "date_naissance_chef")
  plan <- list(date = list(column = "date_enquete"),
               recodes = list(hhh_sex = list(source = "sexe_chef", map = list(Homme = "Male", Femme = "Female"))),
               age_from_dob = list(source = "date_naissance_chef"))
  res <- DECIDE:::apply_setup_plan(d, map, plan)
  expect_s3_class(res$df$date_enquete, "Date")
  expect_equal(res$map$hhh_sex, "sexe_chef_std")
  expect_equal(res$df$sexe_chef, d$sexe_chef)                                   # the original is kept
  expect_setequal(unique(res$df$sexe_chef_std), c("Male", "Female"))
  expect_equal(res$map$hhh_age, "date_naissance_chef_age")
  expect_equal(res$df$date_naissance_chef_age, fixture()$HHHAge, ignore_attr = TRUE)   # the ages back from the dates of birth
})

test_that("a profile carries the value standardisation and the country", {
  p <- DECIDE:::profile_from_settings(list(unique_id = "code_menage", recode_maps = list(hhh_sex = list(Homme = "Male")),
                                               country_office = "Chad"), name = "td")
  back <- DECIDE:::profile_from_json(DECIDE:::profile_to_json(p))
  expect_equal(back$country, "Chad")
  expect_equal(back$recodes$hhh_sex$Homme, "Male")
})
