test_that("valid_phone keeps real numbers and the yes of a yes/no column", {
  vp <- DECIDE:::valid_phone
  expect_equal(vp(c("+243 812 345 678", "0812-345-678", "12345", "00000000", NA, "")),
               c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_equal(vp(c("Yes", "No", "oui", NA)), c(TRUE, FALSE, TRUE, FALSE))
})
