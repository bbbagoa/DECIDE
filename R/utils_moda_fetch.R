#' Download every page of a MODA (ONA) form, several at a time
#'
#' The one download engine behind the MODA import and the MODA re-sync.
#' Non-blocking (curl multi pool driven by `later`), so the session stays
#' responsive and Cancel works.
#'
#' * Page 1 comes alone; its `Link` header gives the number of pages, then up
#'   to `concurrency` pages are in flight at once. Without that header the
#'   pages come one after another until a short page.
#' * Responses are gzip-compressed (JSON shrinks about tenfold).
#' * A request is dropped only when the connection stalls (under 1 KB/s for
#'   `stall_s` seconds), not after a fixed time, so a large page on a slow
#'   line still arrives.
#' * A failed page (network error, timeout, HTTP 429 or 5xx) is retried up to
#'   `retries` times, waiting 2, 4, 8... seconds; the pages already received
#'   are kept.
#'
#' @param page_url function(page) -> URL of that page.
#' @param progress function(pages_done, total_pages, rows) (total NA if unknown).
#' @param finished function(pages): the data frames, in page order.
#' @param failed function(message, cancelled).
#' @param cancelled function() TRUE to stop.
#' @noRd
moda_fetch_pages <- function(page_url, token, page_size = MODA_PAGE_SIZE, concurrency = 4L, retries = 4L,
                             stall_s = 90L, progress = function(...) NULL, finished = function(pages) NULL,
                             failed = function(msg, cancelled = FALSE) NULL, cancelled = function() FALSE) {
  st <- new.env()
  st$pages <- list(); st$got <- integer(0); st$rows <- 0
  st$total <- NA_integer_          # pages announced by the server
  st$stop_at <- NA_integer_        # first short page: nothing after it
  st$next_page <- 1L; st$inflight <- 0L; st$tries <- list(); st$done <- FALSE
  pool <- curl::new_pool(total_con = concurrency, host_con = concurrency)
  handles <- list()
  # The callbacks run from later(), outside Shiny's reactive context, and an
  # error there stops the whole app. Run them in the caller's session, isolated,
  # and turn any error into a failed download.
  domain <- shiny::getDefaultReactiveDomain()
  in_session <- function(f, ...) {
    args <- list(...)
    shiny::withReactiveDomain(domain, shiny::isolate(do.call(f, args)))
  }
  guarded <- function(f) function(...) {
    tryCatch(f(...), error = function(e) {
      if (!st$done) {
        end()
        tryCatch(in_session(failed, paste("Download stopped:", conditionMessage(e)), FALSE),
                 error = function(e2) warning("MODA download: ", conditionMessage(e2), call. = FALSE))
      }
    })
  }

  # The last page to fetch; Inf while neither the server nor a short page has said.
  last_page <- function() {
    k <- c(st$total, st$stop_at)
    if (all(is.na(k))) Inf else min(k, na.rm = TRUE)
  }
  end <- function() {
    st$done <- TRUE
    for (h in handles) try(curl::multi_cancel(h), silent = TRUE)
  }
  fail <- function(msg, was_cancelled = FALSE) {
    if (st$done) return()
    end()
    in_session(failed, msg, was_cancelled)
  }
  check_finished <- function() {
    lp <- last_page()
    if (is.finite(lp) && all(seq_len(lp) %in% st$got)) {
      st$done <- TRUE
      keep <- st$pages[as.character(sort(st$got[st$got <= lp]))]
      in_session(finished, Filter(function(p) is.data.frame(p) && nrow(p) > 0, unname(keep)))
    }
  }
  retry <- function(p, why) {
    n <- (st$tries[[as.character(p)]] %||% 0L) + 1L
    st$tries[[as.character(p)]] <- n
    if (n > retries) return(fail(sprintf("Page %d could not be downloaded after %d attempts: %s", p, retries, why)))
    later::later(guarded(function() if (!st$done) start(p)), delay = 2^n)
  }
  got_page <- function(p, res) {
    st$inflight <- st$inflight - 1L
    handles[[as.character(p)]] <<- NULL
    if (st$done) return()
    code <- res$status_code
    if (code == 429 || code >= 500) return(retry(p, paste("HTTP", code)))
    if (code != 200) return(fail(paste("MODA returned HTTP", code)))
    if (p == 1L && is.na(st$total)) {
      hdrs <- curl::parse_headers_list(res$headers)
      st$total <- parse_total_pages(hdrs[["link"]])
    }
    txt <- rawToChar(res$content); Encoding(txt) <- "UTF-8"
    df <- tryCatch(jsonlite::fromJSON(txt, flatten = TRUE), error = function(e) e)
    if (inherits(df, "error")) return(retry(p, "the response could not be read"))
    n <- if (is.data.frame(df)) nrow(df) else 0L
    if (n > 0) { st$pages[[as.character(p)]] <- df; st$rows <- st$rows + n }
    st$got <- c(st$got, p)
    if (n < page_size) st$stop_at <- min(st$stop_at, p, na.rm = TRUE)
    in_session(progress, length(st$got), if (is.finite(last_page())) last_page() else NA_integer_, st$rows)
    check_finished()
    launch()
  }
  start <- function(p) {
    if (st$done) return()
    h <- curl::new_handle()
    curl::handle_setopt(h, url = page_url(p), connecttimeout = 30L, followlocation = TRUE,
                        accept_encoding = "gzip, deflate",
                        low_speed_limit = 1000L, low_speed_time = as.integer(stall_s))
    curl::handle_setheaders(h, Authorization = paste("Token", token), `User-Agent` = "DECIDE",
                            Accept = "application/json")
    handles[[as.character(p)]] <<- h
    st$inflight <- st$inflight + 1L
    curl::multi_add(h, pool = pool,
                    done = guarded(function(res) got_page(p, res)),
                    fail = guarded(function(err) {
                      st$inflight <- st$inflight - 1L
                      handles[[as.character(p)]] <<- NULL
                      if (!st$done) retry(p, curl_error_text(err))
                    }))
  }
  launch <- function() {
    # One page at a time until the server says how many there are.
    limit <- if (is.na(st$total)) 1L else concurrency
    while (!st$done && st$inflight < limit && st$next_page <= last_page() &&
           !(is.na(st$total) && is.na(st$stop_at) && st$next_page > max(c(0L, st$got)) + 1L)) {
      start(st$next_page)
      st$next_page <- st$next_page + 1L
    }
  }
  tick <- guarded(function() {
    if (st$done) return()
    if (isTRUE(in_session(cancelled))) return(fail("Download cancelled by user.", TRUE))
    curl::multi_run(timeout = 0.1, poll = TRUE, pool = pool)
    later::later(tick, delay = 0.05)
  })
  guarded(launch)()
  tick()
  invisible(st)
}

#' The text of a curl failure
#'
#' curl hands the `fail` callback a classed string, not a condition, so
#' `conditionMessage()` on it errors (and a failed page used to stop the whole
#' download with that error).
#' @noRd
curl_error_text <- function(err) {
  if (inherits(err, "condition")) return(conditionMessage(err))
  msg <- paste(as.character(err), collapse = " ")
  if (!nzchar(msg)) "network error" else msg
}

#' The API key typed in this browser session, per server
#'
#' The first key entered becomes the default for every later import (MODA
#' registration, assessment, PDM, targeting process, spot-check verification,
#' re-sync); only the form ID changes. Kept in the session's memory only: it
#' is never written to disk or into a saved session.
#' @noRd
api_key_get <- function(session, provider = "moda") {
  keys <- session$rootScope()$userData$api_keys
  if (is.null(keys)) NULL else keys[[provider]]
}

#' Remember a key for the rest of the browser session (blank keys ignored)
#' @noRd
api_key_set <- function(session, key, provider = "moda") {
  key <- trimws(key %||% "")
  if (!nzchar(key)) return(invisible(NULL))
  ud <- session$rootScope()$userData
  keys <- ud$api_keys %||% list()
  keys[[provider]] <- key
  ud$api_keys <- keys
  invisible(key)
}

#' What a MODA form is, before downloading it
#'
#' One quick call to the ONA forms endpoint: the title, the number of
#' submissions and when the last one came in, so the officer can confirm it is
#' the right form. Also tells a refused key from a wrong form ID.
#' @return list(ok = TRUE, title, id_string, submissions, last) or
#'   list(ok = FALSE, status, message).
#' @noRd
moda_form_info <- function(form_id, token, base = "https://api.moda.wfp.org/api/v1/forms", timeout = 20L) {
  h <- curl::new_handle()
  curl::handle_setopt(h, connecttimeout = 15L, timeout = as.integer(timeout), followlocation = TRUE,
                      accept_encoding = "gzip, deflate")
  curl::handle_setheaders(h, Authorization = paste("Token", token), Accept = "application/json",
                          `User-Agent` = "DECIDE")
  res <- tryCatch(curl::curl_fetch_memory(paste0(base, "/", utils::URLencode(trimws(form_id), reserved = TRUE)), handle = h),
                  error = function(e) e)
  if (inherits(res, "error"))
    return(list(ok = FALSE, status = NA_integer_,
                message = paste("MODA could not be reached to check the form:", conditionMessage(res))))
  code <- res$status_code
  if (code %in% c(401L, 403L))
    return(list(ok = FALSE, status = code, message = "MODA refused the API key. Check the key (it is the API Gateway Key of your MODA account)."))
  if (code == 404L)
    return(list(ok = FALSE, status = code, message = sprintf("No form with ID %s on MODA, or this key cannot see it.", form_id)))
  if (code != 200L)
    return(list(ok = FALSE, status = code, message = sprintf("MODA returned HTTP %d while checking the form.", code)))
  txt <- rawToChar(res$content); Encoding(txt) <- "UTF-8"
  j <- tryCatch(jsonlite::fromJSON(txt, simplifyVector = TRUE), error = function(e) NULL)
  if (!is.list(j)) return(list(ok = FALSE, status = code, message = "MODA's answer about the form could not be read."))
  pick <- function(k) { v <- j[[k]]; if (is.null(v) || !length(v) || all(is.na(v))) NULL else v[[1]] }
  list(ok = TRUE,
       title = as.character(pick("title") %||% pick("id_string") %||% paste("Form", form_id)),
       id_string = as.character(pick("id_string") %||% ""),
       submissions = suppressWarnings(as.numeric(pick("num_of_submissions") %||% NA)),
       last = as.character(pick("last_submission_time") %||% ""))
}

#' A form in words for loaders and messages: "Title (form 123456)"
#' @noRd
moda_form_label <- function(info, form_id) {
  if (isTRUE(info$ok) && nzchar(info$title %||% "")) sprintf("%s (form %s)", info$title, form_id) else sprintf("form %s", form_id)
}
