#' Update check
#'
#' The package is not on CRAN, so users are not told about new versions by R.
#' At start-up the app reads the latest version from DESCRIPTION on the
#' GitHub repository. The repository is private: the check uses the access
#' token the package was installed with (GITHUB_PAT, or the git credential
#' store set by gitcreds::gitcreds_set()); without one it stays silent. An organisation
#' that hosts its own copy of the releases (a CRAN-like folder built by
#' dev/release.R) sets DECIDE_RELEASES_URL, and that copy is
#' checked first.
#'
#' The check is best effort: offline, blocked or a slow network simply mean
#' no message. It runs at most once a day per R process, and can be
#' turned off with DECIDE_UPDATE_CHECK=false (e.g. on a server where
#' the administrator updates the package).
#'
#' @name update_check
NULL

#' The GitHub repository the package is developed in
#' @noRd
update_repo <- function() "bbbagoa/DECIDE"

#' The public release repository (built by dev/release.R). Override with
#' DECIDE_RELEASES_URL, e.g. for an organisation's own server.
#' @noRd
release_repo_url <- function() {
  tw_env("RELEASES_URL", "")
}

#' Version published on the release repository, or NULL
#' @noRd
release_version <- function(url = release_repo_url(), timeout = 3) {
  if (!nzchar(url)) return(NULL)
  h <- curl::new_handle(timeout = timeout, connecttimeout = timeout)
  res <- tryCatch(curl::curl_fetch_memory(paste0(sub("/+$", "", url), "/src/contrib/PACKAGES"), handle = h),
                  error = function(e) NULL)
  # A file:// mirror (shared drive) reports status 0 on success.
  ok <- !is.null(res) && (res$status_code == 200 || (grepl("^file:", url) && res$status_code == 0))
  if (!ok) return(NULL)
  d <- tryCatch(read.dcf(textConnection(rawToChar(res$content))), error = function(e) NULL)
  if (is.null(d) || !all(c("Package", "Version") %in% colnames(d))) return(NULL)
  v <- d[d[, "Package"] == "DECIDE", "Version"]
  if (!length(v)) return(NULL)
  tryCatch(max(package_version(unname(v))), error = function(e) NULL)
}

.update_cache <- new.env(parent = emptyenv())

#' A GitHub token from the environment or the git credential store. Needed
#' since the repository is private (also lifts the anonymous rate limit).
#' @noRd
github_token <- function() {
  tok <- Sys.getenv("GITHUB_PAT", Sys.getenv("GITHUB_TOKEN", ""))
  if (!nzchar(tok) && requireNamespace("gitcreds", quietly = TRUE)) {
    tok <- tryCatch(gitcreds::gitcreds_get()$password, error = function(e) "")
  }
  tok
}

#' Latest version published on the repository, or NULL when it cannot be read
#' @noRd
remote_version <- function(repo = update_repo(), timeout = 3) {
  tok <- github_token()
  h <- curl::new_handle(timeout = timeout, connecttimeout = timeout)
  hdr <- list(Accept = "application/vnd.github.raw", `User-Agent` = "DECIDE")
  if (nzchar(tok)) hdr$Authorization <- paste("Bearer", tok)
  do.call(curl::handle_setheaders, c(list(h), hdr))
  res <- tryCatch(
    curl::curl_fetch_memory(sprintf("https://api.github.com/repos/%s/contents/DESCRIPTION", repo), handle = h),
    error = function(e) NULL)
  if (is.null(res) || res$status_code != 200) return(NULL)
  d <- tryCatch(read.dcf(textConnection(rawToChar(res$content))), error = function(e) NULL)
  if (is.null(d) || !"Version" %in% colnames(d)) return(NULL)
  tryCatch(package_version(unname(d[1, "Version"])), error = function(e) NULL)
}

#' Is `latest` newer than `installed`? FALSE when either is unknown.
#' @noRd
update_available <- function(installed, latest) {
  if (is.null(installed) || is.null(latest)) return(FALSE)
  isTRUE(package_version(latest) > package_version(installed))
}

#' Update status, checked at most once a day per R process
#' @return NULL when the check is off or failed, else a list with
#'   `installed`, `latest` and `available`.
#' @noRd
update_status <- function(max_age_hours = 24) {
  if (identical(tolower(tw_env("UPDATE_CHECK", "true")), "false")) return(NULL)
  hit <- .update_cache$status
  if (!is.null(hit) && difftime(Sys.time(), .update_cache$at, units = "hours") < max_age_hours) return(hit)
  installed <- tryCatch(utils::packageVersion("DECIDE"), error = function(e) NULL)
  source <- "releases"
  latest <- release_version()          # only when a mirror is configured
  if (is.null(latest)) { latest <- remote_version(); source <- "github" }
  status <- if (is.null(latest) || is.null(installed)) NULL else
    list(installed = installed, latest = latest, source = source,
         available = update_available(installed, latest))
  .update_cache$status <- status
  .update_cache$at <- Sys.time()
  status
}

#' The notice shown when a newer version exists
#' @noRd
update_notice <- function(status) {
  tags$div(
    tags$strong(sprintf("Update available: version %s", status$latest)),
    tags$div(class = "small", sprintf("You have %s. Close the app, then run in R:", status$installed)),
    tags$code(class = "small d-block mt-1",
              if (identical(status$source, "github")) sprintf('pak::pak("%s")', update_repo())
              else sprintf('install.packages("DECIDE", repos = c("%s", "https://cloud.r-project.org"))',
                           release_repo_url())),
    tags$div(class = "small mt-1", "Offline? Install the new offline bundle instead. What changed is listed in NEWS.md.")
  )
}
