test_that("run_app returns a Shiny app object", {
  app <- run_app()
  expect_s3_class(app, "shiny.appobj")
})
