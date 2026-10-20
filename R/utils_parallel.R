#' Speed on large data: every core, and one row per answer pattern
#'
#' The app runs on laptops and servers alike: it uses all the cores the
#' machine has (`DECIDE_CORES` caps it). Models with their own threads
#' (ranger, xgboost) get them directly; independent refits (tuning of the
#' single-threaded models, stability resamples) are spread over worker
#' processes when the data is large enough to be worth it.
#' @name speed
#' @noRd
NULL

#' Cores to use: all of this machine's, or DECIDE_CORES when set lower
#' @noRd
tw_cores <- function() {
  n <- suppressWarnings(parallel::detectCores(logical = TRUE))
  if (is.na(n) || n < 1) n <- 1L
  cap <- suppressWarnings(as.integer(tw_env("CORES", "")))
  if (!is.na(cap) && cap >= 1) n <- min(n, cap)
  as.integer(n)
}

#' lapply over worker processes when it pays, else plain lapply
#'
#' Each worker loads the installed DECIDE; a worker that cannot makes the
#' whole call fall back to plain lapply, so the result never depends on the
#' machine. When the app runs from source (pkgload), the work stays serial:
#' the workers would run the installed copy, an older version.
#' @param big Whether the work is heavy enough for workers (their start-up
#'   costs about a second).
#' @noRd
tw_lapply <- function(X, FUN, big = TRUE) {
  k <- min(tw_cores(), length(X))
  # from source the workers would load the installed (older) package: serial
  if (!big || k < 2 || identical(tw_env("PARALLEL"), "false") || !is.null(tw_source_path())) return(lapply(X, FUN))
  out <- tryCatch({
    cl <- parallel::makePSOCKcluster(k)
    on.exit(parallel::stopCluster(cl), add = TRUE)
    parallel::clusterEvalQ(cl, { suppressPackageStartupMessages(loadNamespace("DECIDE")); NULL })
    parallel::parLapply(cl, X, FUN)
  }, error = function(e) NULL)
  if (is.null(out)) lapply(X, FUN) else out
}

# data.table syntax (by =, .N) inside the package
.datatable.aware <- TRUE

#' One row per distinct combination of `cols`, with its count in `.n`
#'
#' A logistic model on yes/no criteria fitted to these rows, weighted by
#' `.n`, has exactly the likelihood of the model on every household: same
#' estimates, standard errors, deviance and AIC, in a fraction of the time
#' (a million households usually share a few thousand answer patterns).
#' @noRd
collapse_rows <- function(X, cols) {
  dt <- data.table::as.data.table(X[cols])
  as.data.frame(dt[, list(.n = .N), by = cols])
}
