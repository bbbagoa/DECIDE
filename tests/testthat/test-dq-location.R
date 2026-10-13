dat <- data.frame(
  admin1 = c("North", "North", "North", "North", "South", "South", "South", "South"),
  village = c("Kabare", "Kabarre", "Village_04", "Village_06", "Mabalako", "Mabalakko", "Mabalaco", "Bunia"),
  count = c(410, 3, 50, 40, 388, 21, 9, 520), stringsAsFactors = FALSE)

test_that("look-alike names are grouped, the biggest group first", {
  g <- loc_similar_groups(dat, "village")
  expect_setequal(g$name, c("Kabare", "Kabarre", "Mabalako", "Mabalakko", "Mabalaco"))
  expect_equal(g$label[g$group == 2], rep("Kabare", 2))
  expect_equal(g$label[g$name == "Mabalaco"], "Mabalako")
  expect_equal(g$name[g$group == 1], c("Mabalako", "Mabalakko", "Mabalaco"))   # most common spelling first
  expect_false("Village_04" %in% g$name)                # numbers must match
  expect_equal(nrow(loc_similar_groups(dat, "village", max_groups = 1)), 3)
  expect_equal(nrow(loc_similar_groups(dat, "village", similarity = 0.95)), 0)   # stricter: none
})

test_that("the three views carry the groups the click selects", {
  g <- loc_similar_groups(dat, "village")
  net <- loc_network_option(g)
  expect_equal(length(net$series[[1]]$data), nrow(g))
  expect_equal(length(net$series[[1]]$links), nrow(g) - 2)
  expect_equal(vapply(net$series[[1]]$data, `[[`, 1, "group"), g$group)
  bars <- loc_bars_option(g)
  expect_equal(length(bars$series), 3)                 # Mabalako and two variants
  expect_equal(bars$series[[1]]$data[[2]]$name, "Kabare")
  sun <- loc_sunburst_option(dat)
  expect_equal(vapply(sun$series[[1]]$data, `[[`, "", "name"), c("North", "South"))
  expect_equal(sun$series[[1]]$data[[2]]$value, 938)
  expect_equal(nrow(loc_similar_groups(dat[8, ], "village")), 0)
})
