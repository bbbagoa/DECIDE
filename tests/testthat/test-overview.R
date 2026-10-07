# Overview insights (R/utils_overview.R) and the Overview report

ov_fixture <- function() utils::read.csv(testthat::test_path("fixtures", "mini_targeting.csv"), stringsAsFactors = FALSE)
ov_setup <- function() list(unique_id = "instanceID", date = "SvyDate", enumerator_id = "enumerator", admin1 = "Province",
                            admin2 = "Territoire", village = "Village", lon = "lon", lat = "lat", hhh_sex = "HHHSex",
                            hhh_age = "HHHAge", hh_size = "HHSize", residency = "HHStatus", childU5 = "childU5",
                            disability = "disability", v_score = "score", v_groups = "score_class", eligibility = "eligible",
                            weight = "weight")
tile_values <- function(tiles) stats::setNames(vapply(tiles, `[[`, "", "value"), vapply(tiles, `[[`, "", "label"))

test_that("the collection figures are weighted and follow what is mapped", {
  d <- ov_fixture()
  cl <- TargetWise:::ov_collection(d, ov_setup())
  v <- tile_values(cl$tiles)
  expect_equal(v[["Households"]], format(round(sum(d$weight)), big.mark = ","))
  expect_equal(v[["Days of collection"]], as.character(length(unique(d$SvyDate))))
  expect_equal(sum(cl$daily$n), sum(d$weight))
  expect_setequal(unique(cl$daily$area), unique(d$Province))
  # only the id and an area: households and nothing invented
  m <- TargetWise:::ov_collection(d, list(unique_id = "instanceID", admin1 = "Province"))
  expect_equal(names(tile_values(m$tiles)), "Households")
  expect_null(m$daily)
})

test_that("the profile uses every mapped characteristic, and counts or yes/no alike", {
  d <- ov_fixture(); d$plw <- ifelse(seq_len(nrow(d)) %% 3 == 0, "Oui", "Non"); d$older <- rep(c(0, 1, 2), 20)
  pr <- TargetWise:::ov_profile(d, c(ov_setup()[c("hhh_sex", "hhh_age", "hh_size", "childU5", "residency")], list(plw = "plw", elderly = "older")))
  v <- tile_values(pr$tiles)
  expect_equal(v[["With pregnant or lactating women"]], "33%")
  expect_equal(v[["With people aged 60+"]], "67%")
  expect_equal(v[["Female-headed"]], sprintf("%.0f%%", 100 * mean(d$HHHSex == "Female")))
  expect_setequal(names(pr$charts), c("age", "size", "u5", "residency"))       # sex: the female-headed ring
  expect_equal(sum(pr$charts$size$data$n), nrow(d))
  expect_null(TargetWise:::ov_profile(d, list(unique_id = "instanceID")))
})

test_that("groups are ordered from least to most vulnerable", {
  og <- TargetWise:::ov_group_order
  expect_equal(og(c("Severe", "Low", "High", "Moderate")), c("Low", "Moderate", "High", "Severe"))
  expect_equal(og(c("3-C", "1-A", "2-B")), c("1-A", "2-B", "3-C"))
  expect_equal(og(c("B", "A", "C"), score = c(5, 1, 9)), c("A", "B", "C"))           # by the mean score
})

test_that("vulnerability is summarised and crossed with the household profile", {
  d <- ov_fixture()
  v <- TargetWise:::ov_vulnerability(d, ov_setup())
  expect_equal(v$indicator, "eligible")
  expect_equal(v$groups$group, c("1-Low", "2-Moderate", "3-High", "4-Severe"))
  expect_equal(v$top_groups, c("3-High", "4-Severe"))
  expect_true(all(c("Head of household", "Household size", "Residence status") %in% v$cross$dimension))
  fem <- v$cross[v$cross$category == "Female-headed", ]
  f <- d$HHHSex == "Female"; el <- d$eligible == "Eligible"
  expect_equal(fem$value, sum(d$weight[f & el]) / sum(d$weight[f]), tolerance = 1e-9)
  s <- TargetWise:::ov_vulnerability(d, ov_setup(), indicator = "score")
  expect_equal(s$indicator_label, "Mean vulnerability score")
  expect_null(TargetWise:::ov_vulnerability(d, list(unique_id = "instanceID")))
})

test_that("the map view keeps the households inside it, or all when all are in view", {
  x <- c(1, 2, 3, 4); y <- c(1, 2, 3, 4)
  expect_equal(TargetWise:::ov_in_view(x, y, 11:14, list(north = 2.5, south = 0, east = 2.5, west = 0)), 11:12)
  expect_null(TargetWise:::ov_in_view(x, y, 11:14, list(north = 10, south = -10, east = 10, west = -10)))
  expect_null(TargetWise:::ov_in_view(x, y, 11:14, NULL))
})

test_that("the Overview report is written with and without the optional fields", {
  d <- ov_fixture()
  f <- withr::local_tempfile(fileext = ".html")
  TargetWise:::write_overview_report(f, d, ov_setup(), list(n_total = 60, view = "Map view: 32 of 60 households"))
  html <- paste(readLines(f, warn = FALSE), collapse = "\n")
  for (h in c("Data collection", "Who is in the data", "Vulnerability", "Across household profiles", "Map view: 32 of 60")) expect_match(html, h, fixed = TRUE)
  g <- withr::local_tempfile(fileext = ".html")
  TargetWise:::write_overview_report(g, d, list(unique_id = "instanceID", admin1 = "Province"), list(n_total = 60))
  html <- paste(readLines(g, warn = FALSE), collapse = "\n")
  expect_false(grepl("Who is in the data", html, fixed = TRUE))
})

test_that("the contingency table adds up, whatever the cells show", {
  d <- ov_fixture(); w <- d$weight
  n <- TargetWise:::contingency(d, "HHStatus", "HHHSex", w, "n")$table
  expect_equal(n["Total", "Total"], sum(w[nzchar(d$HHStatus)]))
  expect_equal(unname(n[-nrow(n), "Total"]), unname(rowSums(n[-nrow(n), -ncol(n)])))
  r <- TargetWise:::contingency(d, "HHStatus", "HHHSex", w, "row")$table
  expect_true(all(abs(r[, "Total"] - 100) < 1e-9))
  cc <- TargetWise:::contingency(d, "HHStatus", "HHHSex", w, "col")$table
  expect_true(all(abs(cc["Total", ] - 100) < 1e-9))
  m <- TargetWise:::contingency(d, "HHStatus", "HHHSex", w, "mean", "HHSize")$table
  k <- nzchar(d$HHStatus)                                                       # a blank answer is left out
  expect_equal(m["Total", "Total"], sum(w[k] * d$HHSize[k]) / sum(w[k]), tolerance = 1e-9)
  one <- TargetWise:::contingency(d, "HHHAge", NULL, NULL, "n")
  expect_equal(ncol(one$table), 1); expect_equal(nrow(one$table), 6)            # a number: five ranges and the total
  expect_true(is.na(one$chi))
})

test_that("shares are drawn as rings and the other figures as cards", {
  h <- TargetWise:::ov_tiles_html(list(list(label = "Female-headed", value = "53%", share = 0.53),
                                       list(label = "Head's age", value = "48", sub = "median")))
  expect_equal(lengths(regmatches(h, gregexpr('class="tw-donut"', h))), 1)
  six <- TargetWise:::ov_tiles_html(lapply(1:6, function(i) list(label = paste("S", i), value = "10%", share = 0.1)))
  expect_equal(lengths(regmatches(six, gregexpr("class=\"tw-donut\"", six))), 5)   # the sixth share is a card, above the rings
  expect_lt(regexpr("tw-tile", six), regexpr("tw-donut", six))
  expect_match(h, "data-key=\"Head's age\"", fixed = TRUE)
  expect_match(h, ">53%</text>", fixed = TRUE)
})

test_that("the chart builder picks the charts that fit the two variables", {
  kind <- TargetWise:::ov_var_kind
  expect_equal(kind(runif(50)), "num")
  expect_equal(kind(as.character(round(runif(50) * 100, 1))), "num")          # numbers stored as text
  expect_equal(kind(c(1, 2, 3, 1)), "cat")                                     # a few values: a category
  expect_equal(kind(c("Tap", "Well")), "cat")
  types <- TargetWise:::ov_chart_types
  expect_equal(unname(types("num", "num")[1]), "scatter_trend")
  expect_equal(unname(types("cat", "num")[1]), "box")
  expect_equal(unname(types("num", "cat")[1]), "box")
  expect_equal(unname(types("cat", "cat")[1]), "stack100")
  expect_equal(unname(types("num", "none")[1]), "hist")
  expect_match(TargetWise:::ov_cor_text(1:10, (1:10) * 2), "^r = 1.00")
})

test_that("the builders never offer identifiers, names or free text", {
  d <- data.frame(instanceID = sprintf("u%d", 1:60), hh_name = sprintf("Name %d", 1:60), phone_number = 1:60,
                  water = rep(c("Tap", "Well"), 30), income = runif(60), comment = sprintf("free text %d", 1:60),
                  stringsAsFactors = FALSE)
  expect_equal(TargetWise:::analysis_cols(d), c("water", "income"))
})

test_that("level pickers list only the mapped levels, with their columns", {
  ch <- TargetWise:::mapped_level_choices(list(admin1 = "Province", admin2 = "", village = "Village"))
  expect_equal(unname(ch), c("Admin 1", "Village"))
  expect_match(names(ch)[1], "Province")
})

test_that("too_many_options: a message above MAX_OPTIONS answers, NULL below", {
  expect_null(too_many_options(c("a", "b", NA, ""), "x"))
  many <- paste0("v", seq_len(MAX_OPTIONS + 5))
  msg <- too_many_options(many, "Village")
  expect_match(msg, "Too many options for Village (35 different answers)", fixed = TRUE)
  expect_equal(n_options(factor(c("a", "a", NA))), 1)
})

test_that("the map's points and colours travel as compact binary", {
  p <- TargetWise:::map_points_payload(c(29.25, -1.5), c(-0.59, 10.125), c(1, 2, 3, 4))
  r <- jsonlite::base64_dec(p$pos)
  expect_equal(p$n, 2)
  expect_false(grepl("\n", p$pos, fixed = TRUE))
  expect_equal(readBin(r, "numeric", n = 4, size = 4, endian = "little"), c(29.25, -0.59, -1.5, 10.125), tolerance = 1e-6)
  cc <- TargetWise:::map_colour_codes(c("b", "a", NA, " ", "b"))
  expect_equal(as.integer(jsonlite::base64_dec(cc$code)), c(1L, 0L, 2L, 2L, 1L))
  expect_equal(unclass(cc$legend$labels), c("a", "b", "Not specified"))
  expect_equal(length(cc$palette), 3)
  nn <- TargetWise:::map_colour_codes(c(1:20, NA))
  code <- as.integer(jsonlite::base64_dec(nn$code))
  expect_true(nn$legend$numeric)
  expect_equal(code[c(1, 20, 21)], c(0L, 254L, 255L))
  expect_equal(length(nn$palette), 256)
})
