#' Long tasks in a background R process, with a cancel cross
#'
#' R serves the whole app on one thread: while a model fits, the app cannot
#' even hear a click. A task started with `bg_run()` runs in a second R
#' process (one per browser session, started on first use and kept warm), so
#' the app stays responsive and the waiter's cross can stop it: the process is
#' killed and the user carries on. The first task of a session also loads the
#' package in that process (a few seconds; from source, the same source folder,
#' see `tw_source_path()`). `DECIDE_BACKGROUND=false`, or a
#' session that is not a running app (unit tests, testServer), runs the task
#' inline as before.
#' @noRd
NULL

#' The background worker of this browser session
#' @noRd
bg_worker <- function(root) {
  w <- root$userData$tw_worker
  if (is.null(w) || !w$is_alive()) {
    w <- callr::r_session$new(wait = FALSE)
    root$userData$tw_worker <- w
    if (!isTRUE(root$userData$tw_worker_hook)) {
      root$userData$tw_worker_hook <- TRUE
      root$onSessionEnded(function() {
        ww <- root$userData$tw_worker
        if (!is.null(ww)) try(ww$kill(), silent = TRUE)
      })
    }
  }
  w
}

#' @noRd
#' The source folder when DECIDE runs from source (pkgload::load_all()),
#' else NULL. Another R process (the background worker) must then load that
#' folder too: `DECIDE:::` there would otherwise be the installed copy,
#' an older version.
#' @noRd
tw_source_path <- function() {
  if (!requireNamespace("pkgload", quietly = TRUE) || !pkgload::is_dev_package("DECIDE")) return(NULL)
  p <- getNamespaceInfo("DECIDE", "path")
  if (file.exists(file.path(p, "DESCRIPTION"))) normalizePath(p, winslash = "/") else NULL
}

#' @noRd
bg_enabled <- function() {
  !tolower(tw_env("BACKGROUND", "true")) %in% c("0", "false", "no", "off") &&
    shiny::isRunning() && requireNamespace("callr", quietly = TRUE)
}

#' Run `job(args)` in the background worker
#'
#' @param label What the waiter says ("Fitting the model...").
#' @param job A top-level package function taking one list argument (it is
#'   called in the worker as `DECIDE:::<name>(args)`, so it must not be a
#'   closure over the session).
#' @param args One list, sent to the worker (keep it small: only the columns
#'   the task needs).
#' @param on_done function(result), called in the session's reactive domain.
#' @param on_error function(message).
#' @noRd
bg_run <- function(label, job, args, on_done, on_error = function(msg) NULL,
                   session = shiny::getDefaultReactiveDomain()) {
  job_name <- deparse(substitute(job))
  in_domain <- function(fn) shiny::withReactiveDomain(session, shiny::isolate(fn()))
  if (!bg_enabled() || is.null(session)) {
    res <- tryCatch(list(ok = TRUE, value = job(args)), error = function(e) list(ok = FALSE, msg = conditionMessage(e)))
    if (res$ok) on_done(res$value) else on_error(res$msg)
    return(invisible(NULL))
  }
  root <- session$rootScope()
  cancel_id <- "tw_bg_cancel"
  start_val <- shiny::isolate(root$input[[cancel_id]]) %||% 0
  waiter::waiter_show(html = waiter_content(label, cancel_id = cancel_id), color = "rgba(10, 30, 50, 0.65)")
  waiter_log("running in a background R process: the cross above stops it", "info", session = session)
  w <- tryCatch(bg_worker(root), error = function(e) NULL)
  if (is.null(w)) {
    # No worker (callr failed): the task runs here, as before.
    on.exit(waiter::waiter_hide(), add = TRUE)
    res <- tryCatch(list(ok = TRUE, value = job(args)), error = function(e) list(ok = FALSE, msg = conditionMessage(e)))
    if (res$ok) on_done(res$value) else on_error(res$msg)
    return(invisible(NULL))
  }
  # From source, the worker loads the same folder once (the first job takes a
  # few seconds longer); installed, it loads the installed package.
  src <- tw_source_path()
  call <- eval(parse(text = sprintf(paste0(
    "function(a, log, src) { if (!is.null(src) && !isTRUE(getOption('tw.source_loaded'))) {",
    " suppressMessages(pkgload::load_all(src, quiet = TRUE, export_all = TRUE, helpers = FALSE)); options(tw.source_loaded = TRUE) };",
    " DECIDE:::bg_call(\"%s\", a, log) }"), job_name)), envir = globalenv())
  log_file <- tempfile("tw-job-", fileext = ".log"); seen <- 0L
  # the worker's steps and R messages, as they come
  relay <- function() {
    # the worker creates the log with its first line; until then, nothing to read
    if (!file.exists(log_file)) return(invisible())
    ln <- tryCatch(readLines(log_file, warn = FALSE, encoding = "UTF-8"), error = function(e) character(0))
    if (length(ln) > seen) for (x in ln[(seen + 1):length(ln)]) {
      p <- strsplit(x, "\t", fixed = TRUE)[[1]]
      if (length(p) >= 3) waiter_log(paste(p[-(1:2)], collapse = " "), p[1], if (nzchar(p[2])) paste0("bg-", p[2]), session)
    }
    seen <<- length(ln)
  }
  started <- FALSE
  t0 <- Sys.time()
  poll <- function() in_domain(function() {
    if (session$isClosed()) { try(w$kill(), silent = TRUE); return() }
    if (!identical(root$input[[cancel_id]] %||% 0, start_val)) {
      try(w$kill(), silent = TRUE)
      root$userData$tw_worker <- NULL
      waiter::waiter_hide()
      showNotification(sprintf("Stopped: %s", sub("[.]+$", "", label)), type = "warning", duration = 6)
      return()
    }
    st <- tryCatch(w$get_state(), error = function(e) "finished")
    if (!started) {
      if (st == "starting") {
        if (identical(w$poll_process(0), "ready")) try(w$read(), silent = TRUE)
      } else if (st == "idle") {
        w$call(call, list(args, log_file, src))
        started <<- TRUE
        waiter_log("load the package and the data in the worker", "run", id = "bg-run", session = session)
      } else {
        waiter::waiter_hide(); root$userData$tw_worker <- NULL
        on_error("The background process stopped. Try again.")
        return()
      }
      later::later(poll, 0.2)
      return()
    }
    relay()
    if (identical(w$poll_process(0), "ready")) {
      r <- tryCatch(w$read(), error = function(e) list(error = e))
      relay(); unlink(log_file)
      waiter_log(sprintf("done (%.1f s)", as.numeric(difftime(Sys.time(), t0, units = "secs"))), "ok", id = "bg-run", session = session)
      waiter::waiter_hide()
      if (is.null(r$error)) {
        on_done(r$result)
      } else {
        e <- r$error
        msg <- conditionMessage(if (inherits(e$parent, "condition")) e$parent else e)
        on_error(msg)
      }
      return()
    }
    waiter_log(sprintf("working (%.0f s)", as.numeric(difftime(Sys.time(), t0, units = "secs"))), "run", id = "bg-run", session = session)
    later::later(poll, 0.5)
  })
  later::later(poll, 0.1)
  invisible(NULL)
}

#' Run a job in the worker with its log: the steps (tw_step(), waiter_log())
#' and R's messages and warnings are written to `log`, which the waiter reads
#' while the job runs
#' @noRd
bg_call <- function(job_name, a, log) {
  old <- options(tw.log_file = log); on.exit(options(old), add = TRUE)
  line <- function(state, text) cat(sprintf("%s\t\t%s\n", state, gsub("[\t\r\n]+", " ", trimws(text))), file = log, append = TRUE)
  fn <- if (is.function(job_name)) job_name else get(job_name, envir = asNamespace("DECIDE"))
  withCallingHandlers(fn(a),
    message = function(m) { line("r", conditionMessage(m)); invokeRestart("muffleMessage") },
    warning = function(w) line("rwarn", paste("Warning:", conditionMessage(w))))
}

#' Targeting Design fit, run in the worker: the model, every model per
#' variable, and their comparison (AUC, ROC) from those same fits
#' @param a list(df, outcome_col, keep, outcome_pos, method, stepwise,
#'   stepwise_dir, scheme, sp, weights, compare, seed)
#' @noRd
design_fit_job <- function(a) {
  # a proxy means test: welfare per person on the proxies
  if (isTRUE(a$pmt)) {
    fit1 <- function(m) fit_pmt(a$df, a$pc, a$keep, a$line, m, rows = a$sp$train, test = a$sp$test,
                                weights = a$weights, stepwise = a$stepwise, stepwise_dir = a$stepwise_dir)
    out <- fit1(a$method)
    out$residuals <- tryCatch(residual_data_numeric(out$pmt$eval, held_out = length(a$sp$test) > 0), error = function(e) NULL)
    # the other PMT models on the same proxies and households
    fits <- c(list(out), lapply(setdiff(a$compare, a$method), function(m) {
      waiter_log(sprintf("Comparing: %s", model_label(m)))
      tryCatch(fit1(m), error = function(e) NULL)
    }))
    fits <- Filter(Negate(is.null), fits)
    bench <- list(pmt = TRUE, table = do.call(rbind, lapply(fits, pmt_compare_row)),
                  curves = stats::setNames(lapply(fits, function(f) pmt_error_curve(f$pmt$eval, f$pmt$log_line)),
                                           vapply(fits, function(f) model_label(f$method), character(1))))
    return(list(out = out, effects = NULL, bench = bench))
  }
  # without an outcome: a ranking, nothing to compare per variable
  if (isTRUE(a$unsupervised)) {
    # the number of profiles chosen by silhouette when asked
    kq <- NULL
    if (isTRUE(a$auto_k) && a$method %in% cluster_methods()) {
      kq <- profile_quality(a$df, a$keep, a$method, weights = a$weights, seed = a$seed %||% 123)
      if (!is.null(kq) && any(is.finite(kq$silhouette))) a$k <- kq$k[which.max(kq$silhouette)]
    }
    out <- fit_unsupervised(a$df, a$keep, a$method, a$anchor, a$weights, a$k, a$pca_axes, a$pca_min_var,
                            target = a$target, seed = a$seed %||% 123)
    if (!is.null(kq)) out$index$k_quality <- kq
    return(list(out = out, effects = NULL, bench = NULL))
  }
  out <- fit_scorecard_advanced(a$df, a$outcome_col, a$keep,
                                outcome_positive = a$outcome_pos, method = a$method,
                                stepwise = a$stepwise, stepwise_dir = a$stepwise_dir,
                                scheme = a$scheme, rows = a$sp$train, weights = a$weights,
                                pca_axes = a$pca_axes %||% 1, pca_min_var = a$pca_min_var,
                                tune = isTRUE(a$tune), folds = a$folds %||% 5)
  out$residuals <- tryCatch(residual_data(additive_score(a$df, out$weights), as_binary_outcome(a$df[[a$outcome_col]], a$outcome_pos),
                                          a$sp$train, if (length(a$sp$test)) a$sp$test else a$sp$train, a$weights),
                            error = function(e) NULL)
  eff <- tryCatch(model_effects(a$df, a$outcome_col, a$keep, a$outcome_pos,
                                rows = a$sp$train, weights = a$weights,
                                methods = unique(c(out$method, a$compare))),
                  error = function(e) NULL)
  # The comparison uses the fits made for the per-variable table, then those
  # fits (model objects, possibly large) stay in the worker.
  fits <- attr(eff, "fits")
  if (!is.null(eff)) attr(eff, "fits") <- NULL
  bench <- if (length(fits)) tryCatch(
    compare_models_auc(a$df, a$outcome_col, a$outcome_pos, a$sp, fits,
                       scorecard_score = apply_scorecard(a$df, build_scorecard(out$weights))$score),
    error = function(e) list(error = conditionMessage(e)))
  list(out = out, effects = eff, bench = bench)
}

#' Stability of a ranking without an outcome, run in the worker
#' @param a list(df, criteria, method, share, anchor, weights, k, pca_axes, pca_min_var)
#' @noRd
stability_job <- function(a) {
  selection_stability(a$df, a$criteria, a$method, a$share, anchor = a$anchor, weights = a$weights, k = a$k,
                      pca_axes = a$pca_axes %||% 1, pca_min_var = a$pca_min_var)
}

#' Profile quality for 2 to 8 profiles, run in the worker
#' @param a list(df, criteria, method, weights, seed)
#' @noRd
profile_quality_job <- function(a) profile_quality(a$df, a$criteria, a$method, weights = a$weights, seed = a$seed %||% 123)

#' File import, run in the worker (reading, encoding, multiple-choice split)
#' @param a list(path, ext)
#' @noRd
# Handed back as Parquet bytes (pack_frames(), labels kept): a text-heavy
# table crosses between the processes several times faster than as R objects.
import_job <- function(a) {
  df <- read_import_file(a$path, a$ext)
  tw_step("pack the table to hand it back (parquet)", pack_frames(df))
}
