# Undo: a logged change of the data in this session can be undone (with the
# later ones); a new baseline (import, restored session) starts afresh.

test_that("undo puts the data back as it was, undoes later changes and logs it", {
  shiny::testServer(function(input, output, session) {
    data <- shiny::reactiveVal(NULL)
    log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                         new_value = character(0), action = character(0), user = character(0), reason = character(0)))
    base <- shiny::reactiveVal(NULL)
    u <- DECIDE:::undo_tracker(data, log, base)
  }, {
    d0 <- data.frame(id = 1:5, sex = c("Male", "male", "Female", "female", "Male"), stringsAsFactors = FALSE)
    base(d0); data(d0); session$flushReact()
    expect_length(u$steps(), 0)                                   # the import itself is not a step
    d1 <- d0; d1$sex[2] <- "Male"
    data(d1); DECIDE:::audit_add(log, "Selection", "Category values harmonised", "male -> Male"); session$flushReact()
    d2 <- d1[-5, ]
    data(d2); DECIDE:::audit_add(log, "Selection", "Delete record", "5"); session$flushReact()
    DECIDE:::audit_add(log, "Design", "Scorecard adopted"); session$flushReact()   # a decision: no step
    s <- u$steps()
    expect_length(s, 2)
    expect_equal(s[[2]]$action, "Delete record")
    u$undo(s[[1]]$id); session$flushReact()
    expect_identical(data(), d0)                                  # both changes undone
    expect_length(u$steps(), 0)
    expect_match(utils::tail(log()$action, 1), "Change undone")
    expect_match(utils::tail(log()$new_value, 1), "1 later change")
    # a new baseline (a restored session) clears what could be undone
    d3 <- d0; d3$sex[4] <- "Female"; data(d3); DECIDE:::audit_add(log, "Selection", "Edit", ""); session$flushReact()
    expect_length(u$steps(), 1)
    base(d3); session$flushReact()
    expect_length(u$steps(), 0)
  })
})
