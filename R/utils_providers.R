#' Survey data providers
#'
#' MODA is WFP's ONA instance, but country offices also collect on Kobo
#' Toolbox and ODK Central, and both are commonly self-hosted. The three APIs
#' differ only in the URL shape, the authorisation header and where the rows
#' sit in the response, so they are described as data here rather than as three
#' copies of a download loop.
#'
#' MODA keeps its own asynchronous, resumable client in `R/mod_moda_import.R`
#' (it is the path that has to survive a 170k-row sync over a field
#' connection). Kobo and ODK use the straightforward paged fetch below, which
#' blocks with a progress waiter.
#'
#' @name providers
NULL

#' The providers the app can pull from
#'
#' Each entry describes: the human label, whether the server URL is fixed,
#' what identifies a form, and how to build a request and read a response.
#' @noRd
survey_providers <- function() {
  list(
    moda = list(
      label = "MODA (WFP ONA)",
      server = "https://api.moda.wfp.org",
      server_fixed = TRUE,
      needs_project = FALSE,
      form_label = "Form ID (numerical)",
      form_placeholder = "e.g. 123456",
      token_label = "API Gateway Key",
      auth = function(token) c(Authorization = paste("Token", token)),
      page_url = function(server, project, form, page, page_size, query) {
        paste0(server, "/api/v1/data/", form,
               "?page=", page, "&page_size=", page_size, query)
      },
      rows = function(parsed) parsed
    ),

    kobo = list(
      label = "Kobo Toolbox",
      server = "https://kf.kobotoolbox.org",
      server_fixed = FALSE,
      needs_project = FALSE,
      form_label = "Asset UID",
      form_placeholder = "e.g. aBcDeFgHiJkLmNoPqRsTuV",
      token_label = "API token",
      auth = function(token) c(Authorization = paste("Token", token)),
      # KPI v2 paginates with limit/start rather than page numbers.
      page_url = function(server, project, form, page, page_size, query) {
        paste0(server, "/api/v2/assets/", form, "/data/?format=json",
               "&limit=", page_size, "&start=", (page - 1) * page_size, query)
      },
      rows = function(parsed) parsed$results
    ),

    odk = list(
      label = "ODK Central",
      server = "https://central.example.org",
      server_fixed = FALSE,
      needs_project = TRUE,
      form_label = "Form ID (xmlFormId)",
      form_placeholder = "e.g. household_registration",
      token_label = "Session token",
      auth = function(token) c(Authorization = paste("Bearer", token)),
      # OData. $expand=* pulls repeat groups in with the parent submission.
      page_url = function(server, project, form, page, page_size, query) {
        paste0(server, "/v1/projects/", project, "/forms/", form,
               ".svc/Submissions?$top=", page_size,
               "&$skip=", (page - 1) * page_size, "&$expand=*", query)
      },
      rows = function(parsed) parsed$value
    )
  )
}

#' Look a provider up, failing loudly on an unknown name
#' @noRd
get_provider <- function(name) {
  p <- survey_providers()[[name]]
  if (is.null(p)) stop("Unknown survey provider: ", name, call. = FALSE)
  p
}

#' Choices for the provider dropdown
#' @noRd
provider_choices <- function() {
  p <- survey_providers()
  stats::setNames(names(p), vapply(p, function(x) x$label, character(1)))
}

#' Rows out of one page of a provider response
#'
#' Returns an empty list rather than NULL when a page has no rows, so callers
#' can treat "no more data" and "no data at all" the same way.
#' @noRd
provider_page_rows <- function(provider, parsed) {
  rows <- get_provider(provider)$rows(parsed)
  if (is.null(rows)) return(list())
  if (is.data.frame(rows)) return(rows)
  rows
}

#' Build the URL for one page
#'
#' @param server Base server URL (trailing slashes are tolerated).
#' @param project Project id (ODK Central only).
#' @param form Form identifier.
#' @param page 1-based page number.
#' @noRd
provider_page_url <- function(provider, server, project, form, page,
                              page_size = 1000L, query = "") {
  p <- get_provider(provider)
  if (p$server_fixed || !nzchar(server %||% "")) server <- p$server
  server <- sub("/+$", "", server)
  if (isTRUE(p$needs_project) && !nzchar(as.character(project %||% ""))) {
    stop("ODK Central needs a project id.", call. = FALSE)
  }
  p$page_url(server, project, form, page, page_size, query %||% "")
}

#' Fetch every page from a provider and return one data frame
#'
#' Paged, synchronous and deliberately simple: it stops when a page comes back
#' with fewer rows than asked for. Column harmonisation is shared with the MODA
#' path so a mixed set of pages does not produce ragged columns.
#'
#' @param progress Optional `function(page, rows_so_far)` called after each page.
#' @param max_pages Safety stop, so a provider that ignores paging parameters
#'   cannot spin forever.
#' @return A data frame (zero rows if the form has no submissions).
#' @noRd
provider_fetch <- function(provider, server, project, form, token,
                           page_size = 1000L, max_pages = 500L,
                           progress = NULL, fetch_page = NULL) {
  p <- get_provider(provider)
  headers <- p$auth(token)

  # Injectable so the paging and assembly can be tested without a server.
  if (is.null(fetch_page)) {
    fetch_page <- function(url, headers) {
      h <- curl::new_handle()
      curl::handle_setheaders(h, .list = as.list(headers))
      # Compressed transfer: survey payloads are highly repetitive JSON and a
      # field connection is the binding constraint.
      curl::handle_setopt(h, accept_encoding = "gzip, deflate")
      res <- curl::curl_fetch_memory(url, handle = h)
      if (res$status_code >= 400) {
        stop("Server returned HTTP ", res$status_code, call. = FALSE)
      }
      txt <- rawToChar(res$content); Encoding(txt) <- "UTF-8"
      jsonlite::fromJSON(txt, simplifyDataFrame = TRUE, flatten = TRUE)
    }
  }

  pages <- list()
  total <- 0L
  for (page in seq_len(max_pages)) {
    url <- provider_page_url(provider, server, project, form, page, page_size)
    parsed <- fetch_page(url, headers)
    rows <- provider_page_rows(provider, parsed)

    n <- if (is.data.frame(rows)) nrow(rows) else length(rows)
    if (n == 0) break

    pages[[length(pages) + 1]] <- if (is.data.frame(rows)) {
      rows
    } else {
      jsonlite::fromJSON(jsonlite::toJSON(rows, auto_unbox = TRUE),
                         simplifyDataFrame = TRUE, flatten = TRUE)
    }
    total <- total + n
    if (is.function(progress)) progress(page, total)
    if (n < page_size) break
  }

  if (length(pages) == 0) return(data.frame())

  out <- do.call(rbind, harmonize_pages(pages))
  names(out) <- make_unique_names(strip_prefix(names(out)))
  out
}
