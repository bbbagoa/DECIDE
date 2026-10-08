test_that("data_summary() describes every column by its kind", {
  d <- data.frame(
    id = sprintf("hh%03d", 1:100), area = rep(c("North", "South", "East", NA), 25),
    size = c(1:99, NA), yes = rep(c(0, 1), 50), when = as.Date("2026-01-01") + 0:99,
    note = c(rep("ok", 40), rep("late", 30), paste("free", 1:30)), empty = NA, stringsAsFactors = FALSE)
  d$area[5] <- "  "
  s <- data_summary(d, labels = c(size = "Household size"))
  k <- stats::setNames(vapply(s$vars, `[[`, "", "kind"), names(d))
  expect_equal(unname(k), c("id", "category", "number", "category", "date", "text", "empty"))
  v <- s$vars[[2]]
  expect_equal(v$missing, 26)                       # NA and a blank
  expect_equal(sum(vapply(v$levels, `[[`, 0, "n")), 74)
  num <- s$vars[[3]]
  expect_equal(num$label, "Household size")
  expect_equal(num$stats$median, 50)
  expect_equal(sum(num$hist$counts), 99)
  expect_equal(s$vars[[4]]$levels[[1]]$value, "0")  # numeric codes in their order
  expect_equal(s$vars[[5]]$range, c("2026-01-01", "2026-04-10"))
  expect_equal(s$vars[[6]]$top[[1]]$value, "ok")
  f <- data_summary_frame(s)
  expect_equal(nrow(f), ncol(d))
  expect_true(grepl("North (24)", f$`Values (count)`[2], fixed = TRUE))
})
