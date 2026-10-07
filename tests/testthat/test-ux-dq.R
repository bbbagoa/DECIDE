test_that("the Outliers tab starts on a quantity, never a coordinate", {
  f <- TargetWise:::outlier_default_var
  expect_equal(f(c("lon", "lat", "HHSize", "score"), c(HHSize = "hh_size", score = "v_score"), list(lon = "lon", lat = "lat")), "HHSize")
  expect_equal(f(c("lon", "lat", "score"), c(score = "v_score"), list()), "score")
  expect_equal(f(c("lon", "lat", "_index", "members"), character(0), list(lon = "lon")), "members")
})

test_that("the audit trail shows the action without its phase and hides empty columns", {
  log <- shiny::reactiveVal(data.frame(timestamp = "2026-01-01 10:00:00", uid = "", column = "", old_value = "",
                                       new_value = "x", action = "Selection: Selection criteria applied",
                                       user = "a", reason = "", stringsAsFactors = FALSE))
  shiny::testServer(TargetWise:::mod_audit_server, args = list(modification_log = log), {
    session$setInputs(phase = "All")
    # render_react_table(): the columns the React table draws
    heads <- vapply(output$tab_mod_log$columns, function(c) c$label, "")
    expect_true("Action" %in% heads)
    expect_false("Old value" %in% heads)
    expect_false("Reason" %in% heads)
  })
})
