#' Undo for the changes made to the data in this session
#'
#' Each logged change of the data keeps the data as it was just before
#' (unchanged columns are shared between the copies, so a column edit costs
#' little; a deletion copies the rows). Undoing a change puts that copy back,
#' which undoes the later changes too; the undo is itself logged, nothing is
#' taken out of the audit trail. A new baseline (an import, a restored
#' session, a MODA sync) starts afresh: work loaded from a session cannot be
#' undone.
#' @param data The working data (reactiveVal).
#' @param log The audit trail (reactiveVal).
#' @param baseline The pristine import (reactiveVal); a new one clears the steps.
#' @param max_steps Changes kept.
#' @param max_cells Above this size (rows x columns) no copy is kept.
#' @return list(steps = reactive list of list(id, before, from, to, action,
#'   at), undo = function(id)).
#' @noRd
undo_tracker <- function(data, log, baseline = NULL, max_steps = 15, max_cells = 2e7) {
  addr <- function(x) if (is.null(x)) "" else data.table::address(x)
  steps <- reactiveVal(list())
  st <- new.env()
  st$addr <- ""; st$base <- ""; st$prev <- NULL; st$n <- 0L; st$restoring <- FALSE; st$id <- 0L
  observe({
    cur <- data(); lg <- log(); b <- if (is.function(baseline)) baseline() else NULL
    n <- NROW(lg); a <- addr(cur); ba <- addr(b)
    isolate({
      if (!identical(ba, st$base)) {
        st$base <- ba; steps(list())            # new data, or a restored session
      } else if (!identical(a, st$addr) && !st$restoring && !is.null(st$prev) && n > st$n &&
                 as.numeric(nrow(st$prev)) * ncol(st$prev) <= max_cells) {
        st$id <- st$id + 1L
        s <- c(steps(), list(list(id = st$id, before = st$prev, from = st$n + 1L, to = n,
                                  action = sub("^(Design|Selection|Monitoring|Session): ", "", as.character(lg$action[n])),
                                  at = as.character(lg$timestamp[n]))))
        steps(utils::tail(s, max_steps))
      }
      st$restoring <- FALSE
      st$prev <- cur; st$addr <- a; st$n <- n
    })
  })
  undo <- function(id) {
    s <- isolate(steps())
    k <- which(vapply(s, function(x) x$id, integer(1)) == id)
    if (!length(k)) return(invisible(FALSE))
    later <- length(s) - k
    st$restoring <- TRUE
    data(s[[k]]$before)
    steps(s[seq_len(k - 1)])
    audit_add(log, "Session", "Change undone",
              sprintf("%s (logged %s)%s", s[[k]]$action, s[[k]]$at,
                      if (later) sprintf(", and %d later change%s", later, if (later == 1) "" else "s") else ""))
    invisible(TRUE)
  }
  list(steps = steps, undo = undo)
}
