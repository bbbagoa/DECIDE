#' Read a TargetWise setting from the environment
#'
#' Settings are named TARGETWISE_<NAME>. The names used before the app was
#' renamed (TARGETING_MONITOR_<NAME>) are still read, so existing setups,
#' deployments and session passphrases keep working.
#' @noRd
tw_env <- function(name, unset = "") {
  v <- Sys.getenv(paste0("TARGETWISE_", name), unset = NA)
  if (is.na(v)) v <- Sys.getenv(paste0("TARGETING_MONITOR_", name), unset = unset)
  v
}

#' The authenticated user this Shiny session belongs to
#'
#' Posit Connect, Shiny Server Pro and ShinyProxy all put the signed-in user on
#' `session$user`; ShinyProxy also exports it in the environment. We never
#' authenticate anyone ourselves -- rolling our own login for an app holding
#' household PII would be strictly worse than deferring to the platform.
#'
#' @param session A Shiny session object.
#' @return A single user string, or `NULL` when the app runs unauthenticated
#'   (a local desktop run).
#' @noRd
app_user <- function(session = shiny::getDefaultReactiveDomain()) {
  u <- NULL
  if (!is.null(session) && !is.null(session$user)) u <- session$user
  if (is.null(u) || !nzchar(as.character(u)[1])) u <- Sys.getenv("SHINYPROXY_USERNAME", "")
  if (!nzchar(u)) u <- tw_env("USER", "")
  if (!nzchar(u)) return(NULL)
  as.character(u)[1]
}

#' Whether an authenticated user is required before any data may be loaded
#'
#' Set `TARGETWISE_REQUIRE_AUTH=true` on any shared deployment. The app
#' then refuses to run when the platform has not identified the user, instead
#' of silently dropping every visitor into one shared session store.
#'
#' @return Logical.
#' @noRd
require_auth <- function() {
  tolower(tw_env("REQUIRE_AUTH", "false")) %in%
    c("1", "true", "yes", "on")
}

#' Get the application session directory
#'
#' Returns a per-user directory suitable for persisting session data.
#' Creates the directory if it does not exist.
#'
#' The optional environment variable `TARGETWISE_SESSION_DIR` overrides
#' the default user data directory. This is useful for tests and ephemeral
#' deployments.
#'
#' `R_user_dir()` is per *OS* user, not per Shiny session. On a shared server
#' every visitor runs as the same OS user, so without `user` they would all
#' share one session store and one encryption key -- meaning any of them could
#' restore another one's households. Passing `user` gives each their own
#' subdirectory and their own key.
#'
#' @param user Authenticated user (see `app_user()`), or `NULL` for a local
#'   single-user run.
#' @return A character string with the path to the session directory.
#' @noRd
get_session_dir <- function(user = NULL) {
  env_dir <- tw_env("SESSION_DIR", "")
  base <- if (nzchar(env_dir)) env_dir else tools::R_user_dir("TargetWise", which = "data")
  # First start after the rename: bring the sessions, audit logs, settings
  # and the encryption key over from the old folder, so no work is lost.
  if (!nzchar(env_dir) && !dir.exists(base)) {
    old <- tools::R_user_dir("TargetingMonitorApp", which = "data")
    if (dir.exists(old)) {
      dir.create(base, recursive = TRUE, showWarnings = FALSE)
      file.copy(list.files(old, full.names = TRUE, all.files = TRUE, no.. = TRUE), base, recursive = TRUE)
    }
  }

  dir <- if (is.null(user) || !nzchar(user)) {
    base
  } else {
    file.path(base, "users", sanitize_session_name(user))
  }
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  dir
}

#' Path to a named session file
#'
#' @param name Character session name.
#' @return A character string with the session RDS file path.
#' @noRd
sanitize_session_name <- function(name) {
  # Replace any character that is not alphanumeric, dash, or underscore with underscore
  name <- gsub("[^a-zA-Z0-9_-]", "_", name)
  # Collapse multiple underscores
  name <- gsub("_+", "_", name)
  # Remove leading/trailing underscores
  name <- gsub("^_|_$", "", name)
  if (name == "") name <- "session"
  name
}

get_session_file <- function(name = "default", user = NULL) {
  name <- sanitize_session_name(name)
  file.path(get_session_dir(user), paste0(name, ".rds"))
}

#' List all saved sessions
#'
#' @return A data frame with columns `name` and `saved_at`.
#' @noRd
list_saved_sessions <- function(user = NULL) {
  dir <- get_session_dir(user)
  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)
  # Audit-log companions (<name>_audit.rds) are not sessions
  files <- files[!grepl("_audit\\.rds$", files)]
  if (length(files) == 0) {
    return(data.frame(name = character(), saved_at = as.POSIXct(character()), stringsAsFactors = FALSE))
  }

  info <- file.info(files)
  names <- tools::file_path_sans_ext(basename(files))
  df <- data.frame(
    name = names,
    saved_at = info$mtime,
    row.names = NULL,
    stringsAsFactors = FALSE
  )
  df[order(df$saved_at, decreasing = TRUE), , drop = FALSE]
}

#' Default session encryption passphrase
#'
#' The passphrase can be overridden with the environment variable
#' `TARGETWISE_SESSION_PASSPHRASE`. When set, the key is derived from it
#' (so sessions remain portable across machines that share the passphrase).
#'
#' When the env var is unset, a per-install random key file is used instead (see
#' `get_or_create_session_key()`), so that a saved session can only be decrypted
#' on the machine that created it.
#'
#' @return A single character string, or `NA_character_` when no passphrase has
#'   been configured ( signalling that the per-install key should be used).
#' @noRd
session_passphrase <- function() {
  pw <- tw_env("SESSION_PASSPHRASE", NA)
  pw
}

#' Path to the per-install session key file
#'
#' Stored under the user config directory so it is unique to this installation.
#' Overridable via `TARGETWISE_SESSION_DIR` for tests / ephemeral hosts.
#'
#' @return A character string with the key file path.
#' @noRd
get_session_key_file <- function(user = NULL) {
  file.path(get_session_dir(user), "session.key")
}

#' Load or generate the per-install session key
#'
#' On first use a random 32-byte key is generated with `sodium::keygen()` and
#' written to the key file. Subsequent calls read it back. The key never leaves
#' the machine, so sessions encrypted with it cannot be decrypted elsewhere.
#'
#' @return A raw 32-byte key suitable for `sodium::data_encrypt()`.
#' @noRd
get_or_create_session_key <- function(user = NULL) {
  key_file <- get_session_key_file(user)
  if (file.exists(key_file)) {
    key <- tryCatch(
      readRDS(key_file),
      error = function(e) NULL
    )
    if (!is.null(key)) return(key)
  }
  # First use: generate a fresh random key and persist it
  key <- sodium::keygen()
  saveRDS(key, key_file)
  key
}

#' Derive a sodium encryption key for session encryption
#'
#' If `TARGETWISE_SESSION_PASSPHRASE` is set, the key is derived from it
#' (portable across machines sharing the passphrase). Otherwise the per-install
#' random key file is used.
#'
#' @param passphrase Character passphrase. When `NA` (the default), the env var
#'   and then the per-install key file are consulted.
#' @return A raw 32-byte key suitable for `sodium::data_encrypt()`.
#' @noRd
derive_session_key <- function(passphrase = session_passphrase(), user = NULL) {
  if (!is.na(passphrase) && nzchar(passphrase)) {
    return(sodium::hash(charToRaw(passphrase), size = 32L))
  }
  get_or_create_session_key(user)
}

#' Encrypt a session state object
#'
#' @param state An R object to encrypt.
#' @param passphrase Character passphrase.
#' @return A raw vector that can be saved with `saveRDS()`.
#' @noRd
encrypt_session <- function(state, passphrase = session_passphrase(), user = NULL) {
  # Native byte order: skips the XDR byte-swap on every numeric, about twice
  # as fast on large frames; unserialize() reads both formats.
  serialized <- serialize(state, NULL, xdr = FALSE)
  sodium::data_encrypt(serialized, derive_session_key(passphrase, user))
}

#' Decrypt a session state raw vector
#'
#' @param cipher A raw vector produced by `encrypt_session()`.
#' @param passphrase Character passphrase.
#' @return The decrypted R object.
#' @noRd
decrypt_session <- function(cipher, passphrase = session_passphrase(), user = NULL) {
  serialized <- sodium::data_decrypt(cipher, derive_session_key(passphrase, user))
  unserialize(serialized)
}

#' Save the current application session
#'
#' Session files are encrypted with a passphrase-derived key using `sodium`.
#' MODA API tokens are never persisted: the token is set to `NULL` before the
#' credentials are encrypted.
#'
#' @param uploaded_df A data frame or `NULL`.
#' @param user_setup A named list of user setup mappings.
#' @param modification_log A data frame containing the audit log.
#' @param theme Character string with the current theme choice.
#' @param name Character session name.
#' @param workspace Module snapshots from `workspace_snapshot()`.
#'
#' @return Invisibly returns the path to the saved session file.
#' @noRd
save_session <- function(uploaded_df, user_setup, modification_log, theme = "wfp",
                          moda_credentials = NULL, name = "default", user = NULL,
                          workspace = NULL, ui = NULL, original_df = NULL) {
  session_file <- get_session_file(name, user)

  # Never persist the MODA API token in session files
  if (is.list(moda_credentials) && !is.null(moda_credentials$token)) {
    moda_credentials$token <- NULL
  }

  state <- list(
    uploaded_df = uploaded_df,
    # The pristine import (Reset baseline), kept only once it differs from the
    # working data, so an unedited session does not store the data twice.
    original_df = if (!is.null(original_df) && !identical(original_df, uploaded_df)) original_df,
    user_setup = user_setup,
    modification_log = modification_log,
    theme = theme,
    moda_credentials = moda_credentials,
    workspace = workspace,
    ui = ui,
    saved_at = Sys.time(),
    name = name
  )

  cipher <- encrypt_session(state, user = user)
  # The ciphertext is incompressible, so gzip in saveRDS() would only burn CPU
  # (it dominated the 20 s save of a 174k-row dataset). readRDS() auto-detects.
  saveRDS(cipher, session_file, compress = FALSE)
  invisible(session_file)
}

#' Size threshold (bytes) above which the debounced autosave is skipped
#'
#' Autosave serialises + encrypts + writes the whole dataset after every change;
#' for large data (the app targets ~1 GB) that blocks the session for tens of
#' seconds, so it is left to the explicit Save button instead. Override with
#' `TARGETWISE_AUTOSAVE_MAX_MB`.
#' @noRd
autosave_max_bytes <- function() {
  mb <- suppressWarnings(as.numeric(tw_env("AUTOSAVE_MAX_MB", "200")))
  if (is.na(mb) || mb <= 0) mb <- 200
  mb * 1024^2
}

#' Load a named application session
#'
#' Supports both encrypted session files produced by `save_session()` and
#' legacy plain RDS files.
#'
#' @param name Character session name.
#' @return A list containing the saved state, or `NULL` if no session exists.
#' @noRd
load_session <- function(name = "default", user = NULL) {
  session_file <- get_session_file(name, user)
  if (!file.exists(session_file)) {
    return(NULL)
  }

  tryCatch(
    {
      raw_or_state <- readRDS(session_file)
      if (is.raw(raw_or_state)) {
        decrypt_session(raw_or_state, user = user)
      } else {
        raw_or_state
      }
    },
    error = function(e) {
      warning("Failed to load session '", name, "': ", conditionMessage(e))
      NULL
    }
  )
}

#' Check whether any saved session exists
#'
#' @return Logical.
#' @noRd
has_saved_session <- function(user = NULL) {
  nrow(list_saved_sessions(user)) > 0
}

#' Delete a named saved session
#'
#' @param name Character session name.
#' @return Invisibly returns `TRUE` if the file was removed.
#' @noRd
delete_session <- function(name, user = NULL) {
  session_file <- get_session_file(name, user)
  if (file.exists(session_file)) file.remove(session_file)
  audit_file <- file.path(get_session_dir(user), paste0(sanitize_session_name(name), "_audit.rds"))
  if (file.exists(audit_file)) file.remove(audit_file)
  invisible(TRUE)
}

#' Remove all saved sessions
#'
#' @return Invisibly returns `TRUE` if files were removed.
#' @noRd
clear_session <- function(user = NULL) {
  dir <- get_session_dir(user)
  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)
  if (length(files) > 0) {
    file.remove(files)
  }
  invisible(TRUE)
}

#' Save the audit log to disk
#'
#' @param modification_log A data frame containing the audit log.
#' @param name Character session name.
#'
#' @return Invisibly returns the path to the saved audit log file.
#' @noRd
save_audit_log <- function(modification_log, name = "default", user = NULL) {
  name <- sanitize_session_name(name)
  audit_file <- file.path(get_session_dir(user), paste0(name, "_audit.rds"))
  saveRDS(modification_log, audit_file)
  invisible(audit_file)
}

#' Load a persisted audit log
#'
#' @param name Character session name.
#' @return A data frame, or `NULL` if no audit log exists.
#' @noRd
load_audit_log <- function(name = "default", user = NULL) {
  name <- sanitize_session_name(name)
  audit_file <- file.path(get_session_dir(user), paste0(name, "_audit.rds"))
  if (!file.exists(audit_file)) {
    return(NULL)
  }
  tryCatch(
    readRDS(audit_file),
    error = function(e) {
      warning("Failed to load audit log: ", conditionMessage(e))
      NULL
    }
  )
}

#' Module work saved with a session
#'
#' A session file used to hold only the registration data, its mapping and
#' the audit log, so a restored session lost the Targeting Design, the
#' selection settings, the spot-check back-check and the PDM analysis. Each of
#' those modules now registers how to snapshot its state and how to put it
#' back; the session manager saves and restores them all together.
#' @noRd
workspace_new <- function() new.env(parent = emptyenv())

#' @noRd
workspace_register <- function(ws, key, snapshot, restore) {
  if (is.environment(ws)) assign(key, list(snapshot = snapshot, restore = restore), envir = ws)
  invisible(NULL)
}

#' Snapshots of every registered module; NULL entries mean "nothing done yet"
#' @noRd
workspace_snapshot <- function(ws) {
  if (!is.environment(ws)) return(NULL)
  out <- lapply(stats::setNames(ls(ws), ls(ws)), function(k) {
    tryCatch(shiny::isolate(ws[[k]]$snapshot()), error = function(e) NULL)
  })
  Filter(Negate(is.null), out)
}

#' @noRd
workspace_restore <- function(ws, saved) {
  if (!is.environment(ws) || !length(saved)) return(invisible(NULL))
  for (k in intersect(names(saved), ls(ws))) {
    tryCatch(ws[[k]]$restore(saved[[k]]),
             error = function(e) warning("Could not restore ", k, ": ", conditionMessage(e), call. = FALSE))
  }
  invisible(NULL)
}

#' Run `fn` once the current reactive flush has settled
#'
#' Restoring a dataset sets off the observers that reset a module's filters
#' and choices; saved selections must land after them, not be wiped by them.
#' @noRd
after_flush <- function(session, fn) {
  session$onFlushed(function() shiny::withReactiveDomain(session, shiny::isolate(fn())), once = TRUE)
}

#' Small per-install settings (the country office), kept next to the sessions
#'
#' Unlike a session they are not encrypted: they hold no household data.
#' @noRd
app_setting_get <- function(key, user = NULL) {
  f <- file.path(get_session_dir(user), "settings.rds")
  if (!file.exists(f)) return(NULL)
  tryCatch(readRDS(f)[[key]], error = function(e) NULL)
}

#' @noRd
app_setting_set <- function(key, value, user = NULL) {
  f <- file.path(get_session_dir(user), "settings.rds")
  s <- if (file.exists(f)) tryCatch(readRDS(f), error = function(e) list()) else list()
  s[[key]] <- value
  saveRDS(s, f)
  invisible(value)
}

#' A cheap fingerprint of the module work, to autosave only when it changed
#'
#' Data frames count by their shape and column names (their values change
#' through actions that are logged, which trigger a save on their own);
#' everything else by content.
#' @noRd
workspace_signature <- function(x) {
  strip <- function(v) {
    if (is.data.frame(v)) return(list(dim(v), names(v)))
    if (is.list(v)) return(lapply(v, strip))
    v
  }
  rlang::hash(strip(x))
}

#' What a restored session brought back, in one line per part
#' @noRd
session_contents <- function(saved) {
  w <- saved$workspace %||% list()
  sc <- saved$user_setup$scorecard
  c(
    if (!is.null(saved$uploaded_df)) sprintf("Registration data: %s households", format(nrow(saved$uploaded_df), big.mark = ",")),
    if (!is.null(saved$original_df)) sprintf("Original import (Reset baseline): %s households", format(nrow(saved$original_df), big.mark = ",")),
    if (!is.null(w$scorecard)) paste0("Targeting Design: ",
      if (!is.null(w$scorecard$data)) sprintf("assessment data (%s rows)", format(nrow(w$scorecard$data), big.mark = ",")) else "",
      if (length(w$scorecard$runs)) sprintf(", %d model run(s)", length(w$scorecard$runs)) else "",
      if (!is.null(sc) && length(sc$items) && identical(sc$source, "design")) sprintf(", scorecard adopted %s", sc$adopted_at %||% "") else ""),
    if (is.null(w$scorecard) && !is.null(sc) && length(sc$items)) "Scorecard in use (loaded from a workbook)",
    if (!is.null(w$ben_selection)) "Beneficiary Selection settings",
    if (!is.null(w$spot_checking)) paste0("Spot check sample",
                                          if (!is.null(w$spot_checking$comparison)) " and back-check comparison" else ""),
    if (!is.null(w$pdm)) paste0("PDM data (", format(nrow(w$pdm$df), big.mark = ","), " rows)",
                                if (!is.null(w$pdm$results)) " with implementation errors" else ""),
    if (!is.null(w$monitoring)) sprintf("Monitoring: %d dataset(s), %d report item(s)",
                                        length(w$monitoring$datasets), length(w$monitoring$items)),
    if (!is.null(saved$modification_log)) sprintf("Audit trail: %s entries", format(nrow(saved$modification_log), big.mark = ","))
  )
}
