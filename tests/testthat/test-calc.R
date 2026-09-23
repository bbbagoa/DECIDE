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
