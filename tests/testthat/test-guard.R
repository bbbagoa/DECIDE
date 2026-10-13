test_that("tw_guard turns an error into a notice and keeps req() quiet", {
  s <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(s, {
    expect_equal(tw_guard("Adding", 1 + 1), 2)
    expect_message(out <- tw_guard("Merging the names", stop("column not found")), "Merging the names failed: column not found")
    expect_null(out)
    expect_error(tw_guard("Checking", shiny::req(FALSE)), class = "shiny.silent.error")
    expect_error(tw_guard("Checking", shiny::validate(shiny::need(FALSE, "no"))), class = "validation")
  })
  # a return() in the body leaves the handler, as it did unwrapped
  f <- function() { tw_guard("Early", { return("early"); "late" }); "after" }
  expect_equal(f(), "early")
})

test_that("an observer that fails inside tw_guard leaves the session running", {
  srv <- function(id) shiny::moduleServer(id, function(input, output, session) {
    n <- shiny::reactiveVal(0)
    shiny::observeEvent(input$go, tw_guard("Merging the names", { if (input$go == 1) stop("boom"); n(n() + 1) }))
    output$n <- shiny::renderText(n())
  })
  shiny::testServer(srv, {
    expect_message(session$setInputs(go = 1), "boom")   # unwrapped, this ended the session
    session$setInputs(go = 2)
    expect_equal(output$n, "1")
  })
})
