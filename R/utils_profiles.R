#' Setup profiles: a reusable variable mapping
#'
#' The variable mapping used to live only in the running session, so every new
#' round and every new country office re-did the same 22 dropdowns and re-ran
#' the same guesses. A profile is that mapping (plus the numeric coercions and
#' the eligibility rules) written to a small JSON file, so it can be applied to
#' next month's export, shared with a colleague, or kept in version control
#' next to the form.
#'
#' Profiles live beside the sessions, scoped to the same user.
#'
#' @name profiles
NULL

# Bump when the on-disk shape changes in a way older readers cannot handle.
PROFILE_SCHEMA <- 1L

# The mapping keys a profile carries. Kept explicit rather than derived from
# the reactiveValues so that an unrelated key added to the setup module never
# silently ends up in a shared file.
PROFILE_KEYS <- c(
  "unique_id", "date", "admin1", "admin2", "admin3", "admin4", "village",
  "lon", "lat", "hhh_sex", "hhh_age", "hh_size", "residency", "childU5",
  "plw", "elderly",
  "hhid_avail", "phone_avail", "disability", "v_score", "v_groups",
  "eligibility", "enumerator_id", "weight"
)

#' Directory holding this user's profiles
#' @noRd
get_profile_dir <- function(user = NULL) {
  dir <- file.path(get_session_dir(user), "profiles")
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dir
}

#' Path to a named profile file
#' @noRd
get_profile_file <- function(name, user = NULL) {
  file.path(get_profile_dir(user), paste0(sanitize_session_name(name), ".json"))
}

#' Build a profile from the live setup settings
#'
#' @param settings The setup `reactiveValues` (or a plain named list).
#' @param name Profile name.
#' @param rules Optional eligibility rule set (see `R/utils_rules.R`).
#' @return A named list ready for `profile_to_json()`.
#' @noRd
profile_from_settings <- function(settings, name = "profile", rules = NULL) {
  # The eligibility rule set and the scorecard live on the same settings
  # object, so a profile carries the whole targeting design and not just the
  # column mapping.
  if (is.null(rules)) rules <- settings[["rules"]]
  scorecard <- settings[["scorecard"]]
  get <- function(k) {
    v <- settings[[k]]
    if (is.null(v) || length(v) == 0) return(NA_character_)
    v <- as.character(v)[1]
    if (is.na(v) || !nzchar(v)) NA_character_ else v
  }
  mapping <- stats::setNames(lapply(PROFILE_KEYS, get), PROFILE_KEYS)

  force_numeric <- settings[["force_numeric"]]
  if (is.null(force_numeric)) force_numeric <- character(0)

  list(
    schema = PROFILE_SCHEMA,
    name = as.character(name)[1],
    created = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    app_version = as.character(utils::packageVersion("DECIDE")),
    mapping = mapping,
    force_numeric = as.character(force_numeric),
    # how each country writes its answers (field -> value -> standard), and
    # the country office, so the profile is offered to that office next time
    recodes = settings[["recodes"]] %||% settings[["recode_maps"]],
    country = { co <- settings[["country"]] %||% settings[["country_office"]]; if (is.null(co) || !nzchar(co[1])) NULL else as.character(co)[1] },
    rules = rules,
    scorecard = scorecard
  )
}

#' Serialise / parse a profile
#'
#' `auto_unbox` keeps single strings as strings rather than one-element arrays,
#' so the file stays readable and hand-editable.
#' @noRd
profile_to_json <- function(profile) {
  jsonlite::toJSON(profile, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null")
}

#' @rdname profile_to_json
#' @noRd
profile_from_json <- function(txt) {
  # simplifyDataFrame would turn the nested groups/rules arrays into data
  # frames, and the rule set would come back as something ruleset_eval cannot
  # read -- which silently matches every household.
  p <- jsonlite::fromJSON(txt, simplifyVector = TRUE,
                          simplifyDataFrame = FALSE, simplifyMatrix = FALSE)
  if (!is.list(p) || is.null(p$mapping)) {
    stop("This file is not a DECIDE setup profile.", call. = FALSE)
  }
  if (!is.null(p$schema) && as.integer(p$schema) > PROFILE_SCHEMA) {
    stop("This profile was written by a newer version of the app.", call. = FALSE)
  }
  # fromJSON gives a named list for the mapping object; normalise to character.
  p$mapping <- lapply(p$mapping, function(v) {
    if (is.null(v) || length(v) == 0) return(NA_character_)
    v <- as.character(v)[1]
    if (is.na(v) || !nzchar(v)) NA_character_ else v
  })
  if (is.null(p$force_numeric)) p$force_numeric <- character(0)
  p$force_numeric <- as.character(unlist(p$force_numeric, use.names = FALSE))
  if (!is.null(p$recodes)) p$recodes <- lapply(p$recodes, function(m) as.list(vapply(m, function(v) as.character(v)[1], "")))
  if (!is.null(p$country)) p$country <- as.character(p$country)[1]
  if (!is.null(p$rules)) p$rules <- normalise_ruleset(p$rules)
  if (!is.null(p$scorecard)) p$scorecard <- normalise_scorecard(p$scorecard)
  p
}

#' Match a profile against the columns actually present in a dataset
#'
#' A profile written for last month's export will not line up perfectly with a
#' form that gained or renamed a question, so applying one has to be explicit
#' about what it could not place instead of silently mapping a field to
#' nothing (which is how an unmapped field ends up pointing at column 1).
#'
#' @param profile A profile list.
#' @param cols Character vector of column names in the target dataset.
#' @return A list with `mapping` (only the keys whose column exists),
#'   `missing` (keys whose stored column is absent, with the column named) and
#'   `applied_n` / `missing_n` counts.
#' @noRd
match_profile <- function(profile, cols) {
  mapping <- profile$mapping %||% list()
  ok <- list()
  missing <- character(0)
  for (k in names(mapping)) {
    v <- mapping[[k]]
    if (is.null(v) || length(v) != 1 || is.na(v)) next
    if (v %in% cols) {
      ok[[k]] <- v
    } else {
      missing[[k]] <- v
    }
  }
  list(
    mapping = ok,
    missing = missing,
    applied_n = length(ok),
    missing_n = length(missing)
  )
}

#' List, read, write and delete stored profiles
#'
#' @param user Authenticated user, or `NULL` for a local run.
#' @return `list_profiles()` returns a data frame of `name` and `saved_at`
#'   (newest first); the others act on a single profile.
#' @noRd
list_profiles <- function(user = NULL) {
  dir <- get_profile_dir(user)
  files <- list.files(dir, pattern = "[.]json$", full.names = TRUE)
  if (length(files) == 0) {
    return(data.frame(name = character(), saved_at = as.POSIXct(character()),
                      stringsAsFactors = FALSE))
  }
  info <- file.info(files)
  df <- data.frame(
    name = tools::file_path_sans_ext(basename(files)),
    saved_at = info$mtime,
    row.names = NULL,
    stringsAsFactors = FALSE
  )
  df[order(df$saved_at, decreasing = TRUE), , drop = FALSE]
}

#' @rdname list_profiles
#' @noRd
save_profile <- function(profile, user = NULL) {
  f <- get_profile_file(profile$name, user)
  writeLines(as.character(profile_to_json(profile)), f, useBytes = TRUE)
  invisible(f)
}

#' @rdname list_profiles
#' @noRd
load_profile <- function(name, user = NULL) {
  f <- get_profile_file(name, user)
  if (!file.exists(f)) return(NULL)
  tryCatch(
    profile_from_json(paste(readLines(f, warn = FALSE), collapse = "\n")),
    error = function(e) {
      warning("Could not read profile '", name, "': ", conditionMessage(e))
      NULL
    }
  )
}

#' @rdname list_profiles
#' @noRd
delete_profile <- function(name, user = NULL) {
  f <- get_profile_file(name, user)
  if (file.exists(f)) file.remove(f)
  invisible(TRUE)
}
