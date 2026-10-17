# The three APIs differ in URL shape, auth header and where the rows sit.
# These tests pin all three without a network: a fake page-fetcher stands in
# for the server, so paging, assembly and column harmonisation are exercised
# end to end.
#
# NOTE: a live sync against a real Kobo or ODK Central server has not been
# run -- that needs credentials. What is verified here is the request the app
# would send and how it reads the documented response shape.

test_that("each provider builds the request its API documents", {
  expect_equal(
    DECIDE:::provider_page_url("moda", NULL, NULL, "123456", page = 2, page_size = 500),
    "https://api.moda.wfp.org/api/v1/data/123456?page=2&page_size=500"
  )

  # Kobo KPI v2 pages with limit/start, not page numbers.
  expect_equal(
    DECIDE:::provider_page_url("kobo", "https://kf.kobotoolbox.org", NULL,
                                            "aXYZ", page = 3, page_size = 200),
    "https://kf.kobotoolbox.org/api/v2/assets/aXYZ/data/?format=json&limit=200&start=400"
  )

  # ODK Central is OData; $expand=* brings repeat groups along.
  expect_equal(
    DECIDE:::provider_page_url("odk", "https://central.example.org/", "7",
                                            "hh_registration", page = 1, page_size = 100),
    "https://central.example.org/v1/projects/7/forms/hh_registration.svc/Submissions?$top=100&$skip=0&$expand=*"
  )
})

test_that("a self-hosted server URL is honoured, and a fixed one is not overridable", {
  expect_match(
    DECIDE:::provider_page_url("kobo", "https://kobo.example.org", NULL, "a", 1, 10),
    "^https://kobo\\.example\\.org/"
  )
  # MODA is WFP's own instance; a stray server value must not redirect it.
  expect_match(
    DECIDE:::provider_page_url("moda", "https://evil.example.com", NULL, "1", 1, 10),
    "^https://api\\.moda\\.wfp\\.org/"
  )
})

test_that("ODK Central refuses to build a request without a project id", {
  expect_error(
    DECIDE:::provider_page_url("odk", "https://central.example.org", "", "form", 1, 10),
    "project id"
  )
})

test_that("auth headers match each API", {
  p <- DECIDE:::survey_providers()
  expect_equal(unname(p$moda$auth("abc")), "Token abc")
  expect_equal(unname(p$kobo$auth("abc")), "Token abc")
  expect_equal(unname(p$odk$auth("abc")), "Bearer abc")
  expect_error(DECIDE:::get_provider("surveycto"), "Unknown survey provider")
})

test_that("rows are read from the right place in each response shape", {
  rows <- data.frame(a = 1:2, b = c("x", "y"), stringsAsFactors = FALSE)
  expect_equal(DECIDE:::provider_page_rows("moda", rows), rows)
  expect_equal(DECIDE:::provider_page_rows("kobo", list(count = 2, results = rows)), rows)
  expect_equal(DECIDE:::provider_page_rows("odk", list(value = rows)), rows)
  # An empty page is an empty list, never NULL, so callers can stop cleanly.
  expect_equal(DECIDE:::provider_page_rows("kobo", list(count = 0)), list())
})

test_that("paging stops on a short page and assembles every row", {
  # Two full pages then a short one: 250 rows in total.
  make_page <- function(from, n) {
    data.frame(`_id` = seq(from, length.out = n),
               `group/name` = paste0("HH", seq(from, length.out = n)),
               check.names = FALSE, stringsAsFactors = FALSE)
  }
  seen <- character(0)
  fake <- function(url, headers) {
    seen <<- c(seen, url)
    page <- as.integer(sub(".*start=(\\d+).*", "\\1", url)) / 100 + 1
    n <- if (page < 3) 100 else 50
    list(count = 250, results = make_page((page - 1) * 100 + 1, n))
  }

  out <- DECIDE:::provider_fetch(
    "kobo", "https://kf.kobotoolbox.org", NULL, "aXYZ", "tok",
    page_size = 100, fetch_page = fake
  )

  expect_equal(nrow(out), 250)
  expect_length(seen, 3)                       # stopped on the short page
  # Nested group prefixes are stripped the same way as on the MODA path.
  expect_true("name" %in% names(out))
  expect_equal(out$name[1], "HH1")
  expect_equal(out$name[250], "HH250")
})

test_that("a form with no submissions returns an empty frame rather than erroring", {
  fake <- function(url, headers) list(count = 0, results = NULL)
  out <- DECIDE:::provider_fetch("kobo", "https://kf.kobotoolbox.org", NULL,
                                              "aXYZ", "tok", fetch_page = fake)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 0)
})

test_that("a server that ignores paging cannot spin forever", {
  # Always returns a full page, so only max_pages stops it.
  fake <- function(url, headers) {
    list(count = 1e9, results = data.frame(id = 1:10, stringsAsFactors = FALSE))
  }
  out <- DECIDE:::provider_fetch("kobo", "https://kf.kobotoolbox.org", NULL,
                                              "aXYZ", "tok", page_size = 10,
                                              max_pages = 4, fetch_page = fake)
  expect_equal(nrow(out), 40)
})

test_that("an HTTP error is reported rather than silently returning nothing", {
  fake <- function(url, headers) stop("Server returned HTTP 401")
  expect_error(
    DECIDE:::provider_fetch("kobo", "https://kf.kobotoolbox.org", NULL,
                                         "aXYZ", "bad-token", fetch_page = fake),
    "401"
  )
})
