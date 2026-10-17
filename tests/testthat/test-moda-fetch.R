
# A local stand-in for the MODA API: `n` records served `page_size` at a
# time, a Link header naming the last page, and page 2 failing once (503).
fake_moda <- function(n = 2500, page_size = 1000) {
  hits <- new.env(); hits$log <- character(0); hits$failed <- FALSE
  last <- ceiling(n / page_size)
  app <- list(call = function(req) {
    q <- shiny::parseQueryString(req$QUERY_STRING)
    pg <- as.integer(q$page)
    hits$log <- c(hits$log, paste0(pg, "|", req$HTTP_ACCEPT_ENCODING %||% ""))
    if (pg == 2 && !hits$failed) {
      hits$failed <- TRUE
      return(list(status = 503L, headers = list("Content-Type" = "text/plain"), body = "busy"))
    }
    ids <- seq((pg - 1) * page_size + 1, min(n, pg * page_size))
    ids <- ids[ids <= n]
    body <- jsonlite::toJSON(data.frame(`_id` = ids, village = paste0("S\u00e9gou ", ids), check.names = FALSE))
    list(status = 200L,
         headers = list("Content-Type" = "application/json; charset=utf-8",
                        Link = sprintf('<http://x/?page=2&page_size=%d>; rel="next", <http://x/?page=%d&page_size=%d>; rel="last"',
                                       page_size, last, page_size)),
         body = as.character(body))
  })
  port <- httpuv::randomPort()
  srv <- httpuv::startServer("127.0.0.1", port, app)
  list(url = sprintf("http://127.0.0.1:%d/data", port), stop = function() srv$stop(), hits = hits)
}
run_until <- function(done, secs = 30) {
  t0 <- Sys.time()
  while (!done() && difftime(Sys.time(), t0, units = "secs") < secs) later::run_now(0.05)
}

test_that("the MODA engine gets every page, in order, retrying a failed one", {
  srv <- fake_moda(); on.exit(srv$stop())
  out <- new.env(); out$pages <- NULL; out$err <- NULL; out$prog <- 0
  DECIDE:::moda_fetch_pages(
    page_url = function(pg) paste0(srv$url, "?page=", pg, "&page_size=1000"),
    token = "t", page_size = 1000L,
    progress = function(done, total, rows) out$prog <- out$prog + 1,
    finished = function(pages) out$pages <- pages,
    failed = function(msg, cancelled = FALSE) out$err <- msg)
  run_until(function() !is.null(out$pages) || !is.null(out$err))
  expect_null(out$err)
  df <- dplyr::bind_rows(out$pages)
  expect_equal(nrow(df), 2500)
  expect_equal(df$`_id`, 1:2500)                          # page order kept
  expect_equal(df$village[1], "S\u00e9gou 1")             # UTF-8 kept
  expect_true(srv$hits$failed)                             # the 503 happened and was retried
  expect_true(all(grepl("gzip", sub("^[0-9]+\\|", "", srv$hits$log))))   # compression asked for
  expect_equal(out$prog, 3)
})

test_that("a network failure ends with a message, not an R error", {
  expect_equal(DECIDE:::curl_error_text(structure("Timeout was reached", class = c("curl_error_operation_timedout", "curl_error", "character"))),
               "Timeout was reached")
  expect_equal(DECIDE:::curl_error_text(simpleError("boom")), "boom")
  out <- new.env(); out$err <- NULL
  port <- httpuv::randomPort()                              # nothing listens there
  DECIDE:::moda_fetch_pages(
    page_url = function(pg) sprintf("http://127.0.0.1:%d/x?page=%d", port, pg),
    token = "t", retries = 1L,
    finished = function(pages) out$err <- "finished?",
    failed = function(msg, cancelled = FALSE) out$err <- msg)
  run_until(function() !is.null(out$err), 20)
  expect_match(out$err, "Page 1 could not be downloaded after 1 attempts")
})

test_that("cancelling stops the download", {
  srv <- fake_moda(n = 50000); on.exit(srv$stop())
  out <- new.env(); out$msg <- NULL; out$stop <- FALSE
  DECIDE:::moda_fetch_pages(
    page_url = function(pg) paste0(srv$url, "?page=", pg, "&page_size=1000"),
    token = "t", page_size = 1000L,
    progress = function(done, total, rows) if (done >= 2) out$stop <- TRUE,
    finished = function(pages) out$msg <- "finished",
    failed = function(msg, cancelled = FALSE) out$msg <- if (cancelled) "cancelled" else msg,
    cancelled = function() out$stop)
  run_until(function() !is.null(out$msg))
  expect_equal(out$msg, "cancelled")
})

test_that("the first API key is remembered for the session, per server, in memory only", {
  s <- shiny::MockShinySession$new()
  expect_null(DECIDE:::api_key_get(s))
  DECIDE:::api_key_set(s, "  KEY-1  ")
  expect_equal(DECIDE:::api_key_get(s), "KEY-1")
  DECIDE:::api_key_set(s, "")                      # a blank field does not erase it
  expect_equal(DECIDE:::api_key_get(s), "KEY-1")
  DECIDE:::api_key_set(s, "KOBO", "kobo")
  expect_equal(DECIDE:::api_key_get(s, "kobo"), "KOBO")
  expect_equal(DECIDE:::api_key_get(s), "KEY-1")
  DECIDE:::api_key_set(s, "KEY-2")                 # the user can change it
  expect_equal(DECIDE:::api_key_get(s), "KEY-2")
})

test_that("the form is identified before the download: title, submissions, or why not", {
  skip_if_not_installed("callr")
  # The check is a blocking call, so the fake MODA runs in another R process.
  port <- httpuv::randomPort()
  srv <- callr::r_bg(function(port) {
    `%||%` <- function(a, b) if (is.null(a)) b else a
    app <- list(call = function(req) {
      id <- sub(".*/forms/", "", req$PATH_INFO)
      if (!grepl("GOOD", req$HTTP_AUTHORIZATION %||% "")) return(list(status = 401L, headers = list(), body = "no"))
      if (id != "123") return(list(status = 404L, headers = list(), body = "no"))
      list(status = 200L, headers = list("Content-Type" = "application/json; charset=utf-8"),
           body = as.character(jsonlite::toJSON(list(title = "Enqu\u00eate PDM S\u00e9gou", id_string = "pdm_segou",
                                                     num_of_submissions = 2500, last_submission_time = "2026-09-20T10:15:00"),
                                                auto_unbox = TRUE)))
    })
    httpuv::startServer("127.0.0.1", port, app)
    httpuv::service(Inf)
  }, args = list(port))
  on.exit(srv$kill())
  base <- sprintf("http://127.0.0.1:%d/forms", port)
  ok <- NULL
  for (i in 1:40) { ok <- DECIDE:::moda_form_info("123", "GOOD", base = base); if (!is.na(ok$status %||% 200L)) break; Sys.sleep(0.25) }
  expect_true(ok$ok)
  expect_equal(ok$title, "Enqu\u00eate PDM S\u00e9gou")
  expect_equal(ok$submissions, 2500)
  expect_equal(DECIDE:::moda_form_label(ok, "123"), "Enqu\u00eate PDM S\u00e9gou (form 123)")
  bad_key <- DECIDE:::moda_form_info("123", "BAD", base = base)
  expect_false(bad_key$ok); expect_equal(bad_key$status, 401L); expect_match(bad_key$message, "refused the API key")
  no_form <- DECIDE:::moda_form_info("999", "GOOD", base = base)
  expect_equal(no_form$status, 404L); expect_match(no_form$message, "No form with ID 999")
  down <- DECIDE:::moda_form_info("123", "GOOD", base = sprintf("http://127.0.0.1:%d/forms", httpuv::randomPort()))
  expect_false(down$ok); expect_true(is.na(down$status))
})
