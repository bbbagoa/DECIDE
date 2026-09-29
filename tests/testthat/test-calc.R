tm <- function(f) utils::getFromNamespace(f, "TargetWise")

df <- data.frame(size = c(6, 2, NA, 9), head = c("Female", "Male", "Female", " Male "),
                 dep = c(4, 1, 2, 3), work = c(2, 1, 0, 3), stringsAsFactors = FALSE)

test_that("conditions combine with three-valued logic and code as asked", {
  cond <- list(list(column = "size", op = ">=", value = "6"),
               list(column = "head", op = "==", value = "Female"))
  expect_equal(tm("calc_condition")(df, cond, "all"), c(1L, 0L, NA, 0L))
  # Under ANY a known TRUE decides even when the other part is unknown.
  expect_equal(tm("calc_condition")(df, cond, "any", "yesno"), c("Yes", "No", "Yes", "Yes"))
  expect_equal(tm("calc_condition")(df, list(list(column = "size", op = "is_missing", value = "")))[3], 1L)
  expect_equal(tm("calc_condition")(df, list(list(column = "head", op = "in", value = "Male, Other"))),
               c(0L, 1L, 0L, 1L))
  expect_error(tm("calc_condition")(df, list(list(column = "size", op = ">", value = "abc"))), "not a number")
  expect_match(tm("calc_describe_condition")(cond, "all"), "size at least 6 AND head equals Female")
})

test_that("formulas compute on columns and refuse anything else", {
  expect_equal(tm("calc_formula")(df, "dep / pmax(work, 1)"), c(2, 1, 2, 1))
  expect_equal(tm("calc_formula")(df, "ifelse(size >= 6, 1, 0)"), c(1, 0, NA, 1))
  expect_equal(tm("calc_formula")(df, "rowSums(cbind(dep, work), na.rm = TRUE)"), c(6, 2, 2, 6))
  expect_equal(tm("calc_formula")(df, "1"), rep(1, 4))
  expect_error(tm("calc_formula")(df, "system('whoami')"), "not allowed")
  expect_error(tm("calc_formula")(df, "base::sum(dep)"), "not allowed")
  expect_error(tm("calc_formula")(df, "df$dep"), "not allowed")
  expect_error(tm("calc_formula")(df, "x <- 1"), "not allowed")
  expect_error(tm("calc_formula")(df, "missing_col * 2"), "Unknown column")
  expect_error(tm("calc_formula")(df, "sum(dep)"), NA)   # a scalar is recycled
})

test_that("new names must be valid and not clash", {
  expect_equal(tm("calc_check_name")("dep_ratio", names(df)), "dep_ratio")
  expect_error(tm("calc_check_name")("dep ratio", names(df)), "letters")
  expect_error(tm("calc_check_name")("size", names(df)), "already exists")
  expect_equal(tm("calc_check_name")("size", names(df), replace = TRUE), "size")
})

test_that("an R code block computes a column and refuses anything unsafe", {
  df <- data.frame(dep = c(4, 1, 2, 5), work = c(2, 1, 0, 5), size = c(6, 2, NA, 10))
  code <- "ratio <- dep / pmax(work, 1)\nratio[is.na(size)] <- 0\nifelse(ratio >= 2, 1, 0)"
  expect_equal(tm("calc_code")(df, code), c(1, 0, 0, 0))
  expect_equal(tm("calc_code")(df, "x = size\nif (TRUE) x * 2"), c(12, 4, NA, 20))
  expect_equal(df$dep, c(4, 1, 2, 5))   # the data is never modified
  expect_error(tm("calc_code")(df, "system('whoami')"), "not allowed")
  expect_error(tm("calc_code")(df, "f <- function() 1"), "not allowed")
  expect_error(tm("calc_code")(df, "for (i in 1:3) dep"), "not allowed")
  expect_error(tm("calc_code")(df, "df$dep"), "not allowed")
  expect_error(tm("calc_code")(df, "base::sum(dep)"), "not allowed")
  expect_error(tm("calc_code")(df, "do.call('system', list('whoami'))"), "not allowed")
  expect_error(tm("calc_code")(df, "y[1] <- 2"), "Unknown")
  expect_error(tm("calc_code")(df, "names(x) <- 'a'"), "not allowed|plain name")
  expect_error(tm("calc_code")(df, "c(1, 2)"), "one value per row")
})

test_that("one yes/no per answer: a reference left out, missing kept, non-categories refused", {
  d <- data.frame(roof = c("Metal", "Thatch", "Metal", NA, "Tile", "Metal"), id = 1:6,
                  water = c("Tap", "Well", "Tap", "Tap", "", "Well"))
  r <- TargetWise:::calc_dummies(d, c("roof", "id", "water"), max_answers = 5)
  expect_equal(r$names, c("roof_Thatch", "roof_Tile", "water_Well"))   # Metal and Tap are the references
  expect_equal(r$values[[1]], c(0L, 1L, 0L, NA, 0L, 0L))
  expect_true(is.na(r$values[[3]][5]))                                  # a blank answer is missing
  expect_equal(r$skipped, "id")
  all <- TargetWise:::calc_dummies(d, "roof", reference = FALSE, coding = "yesno")
  expect_equal(all$names, c("roof_Metal", "roof_Thatch", "roof_Tile"))
  expect_equal(all$values[[1]], c("Yes", "No", "Yes", NA, "No", "Yes"))
})
