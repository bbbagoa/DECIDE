#' moda_import UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_moda_import_ui <- function(id) {
  ns <- NS(id)
  tagList(
    actionButton(
      ns("btn_open_moda"),
      "Import from a server",
      class = "btn-outline-secondary w-100",
      icon = icon("cloud-download")
    )
  )
}

#' moda_import Server Functions
#'
#' @noRd

# Make stripped names unique without changing non-duplicated names
make_unique_names <- function(x) {
  seen <- character()
  out <- character(length(x))
  for (i in seq_along(x)) {
    nm <- x[i]
    if (nm %in% seen) {
      k <- 1
      candidate <- paste0(nm, "_", k)
      while (candidate %in% seen) {
        k <- k + 1
        candidate <- paste0(nm, "_", k)
      }
      nm <- candidate
    }
    out[i] <- nm
    seen <- c(seen, nm)
  }
  out
}

# Strip group prefixes from ODK/MODA variable names (handles / or . separators)
strip_prefix <- function(x) {
  vapply(strsplit(x, "[/.]", perl = TRUE), function(y) y[length(y)], character(1))
}

#' @importFrom jsonlite fromJSON
# Helpers for paginated MODA JSON downloads.
# Extract the total number of pages from an ONA Link header, e.g.
# <...?page=2&page_size=...>; rel="next", <...?page=10&page_size=...>; rel="last"
parse_total_pages <- function(link_header) {
  if (is.null(link_header) || length(link_header) == 0 || !nzchar(link_header)) {
    return(NA_integer_)
  }
  last_links <- regmatches(link_header, regexpr('<[^>]+>; rel="last"', link_header))
  if (length(last_links) == 0 || length(last_links[[1]]) == 0) {
    return(NA_integer_)
  }
  last_link <- last_links[[1]]
  page_matches <- regmatches(last_link, regexpr('page=[0-9]+', last_link))
  if (length(page_matches) == 0 || length(page_matches[[1]]) == 0) {
    return(NA_integer_)
  }
  as.integer(sub("page=", "", page_matches[[1]]))
}

# When MODA paginates, the same column can have different types across chunks
# (e.g. `_duration` is character in some pages and double in others).
# This helper picks a common type for each column and coerces every page to it
# before binding rows.
harmonize_pages <- function(pages) {
  all_names <- unique(unlist(lapply(pages, names), use.names = FALSE))

  target_types <- sapply(all_names, function(nm) {
    can_be_numeric <- TRUE
    for (p in pages) {
      if (!nm %in% names(p)) next
      x <- p[[nm]]
      cl <- class(x)[1]
      if (cl == "character") {
        vals <- x[!is.na(x)]
        if (length(vals) > 0) {
          converted <- suppressWarnings(as.numeric(trimws(vals)))
          if (any(is.na(converted))) can_be_numeric <- FALSE
        }
      } else if (!cl %in% c("numeric", "integer", "double")) {
        can_be_numeric <- FALSE
      }
      if (!can_be_numeric) break
    }
    if (can_be_numeric) "numeric" else "character"
  }, simplify = FALSE, USE.NAMES = TRUE)

  lapply(pages, function(p) {
    for (nm in names(p)) {
      if (target_types[[nm]] == "numeric") {
        p[[nm]] <- suppressWarnings(as.numeric(trimws(as.character(p[[nm]]))))
      } else {
        p[[nm]] <- as.character(p[[nm]])
      }
    }
    p
  })
}

# Read an optional ODK XLSForm and build a list of choice-label mappings per variable
build_odk_label_map <- function(odk_path) {
  if (is.null(odk_path) || !file.exists(odk_path)) {
    return(NULL)
  }

  sheets <- readxl::excel_sheets(odk_path)
  if (!all(c("survey", "choices") %in% sheets)) {
    return(NULL)
  }

  survey <- readxl::read_excel(odk_path, sheet = "survey")
  choices <- readxl::read_excel(odk_path, sheet = "choices")

  type_col <- "type"
  name_col <- "name"
  list_name_col <- "list_name"
  choice_name_col <- "name"
  choice_label_col <- grep("^label", names(choices), value = TRUE)[1]

  if (is.na(choice_label_col)) {
    return(NULL)
  }

  # Keep only select rows and parse the list_name
  select_rows <- survey[[type_col]] %in% c("select_one", "select_multiple") |
    grepl("^(select_one|select_multiple)\\s", survey[[type_col]])
  survey <- survey[select_rows, , drop = FALSE]

  if (nrow(survey) == 0) {
    return(NULL)
  }

  survey$list_name <- vapply(strsplit(as.character(survey[[type_col]]), "\\s+", perl = TRUE), function(y) {
    if (length(y) >= 2) y[2] else NA_character_
  }, character(1))

  # Strip prefixes from survey variable names to match MODA columns
  survey$var_name <- strip_prefix(as.character(survey[[name_col]]))

  # Build a named list: var_name -> function(value) label
  label_map <- list()
  for (var in unique(survey$var_name)) {
    list_names <- unique(stats::na.omit(survey$list_name[survey$var_name == var]))
    if (length(list_names) == 0) next

    # Combine all choice lists mapped to this variable (rare, but possible)
    list_choices <- choices[choices[[list_name_col]] %in% list_names, , drop = FALSE]
    if (nrow(list_choices) == 0) next

    lookup <- stats::setNames(
      as.character(list_choices[[choice_label_col]]),
      as.character(list_choices[[choice_name_col]])
    )

    label_map[[var]] <- lookup
  }

  label_map
}

# Try to download the ODK XLSForm definition from MODA using the same token
download_moda_xlsform <- function(form_id, token) {
  url <- paste0("https://api.moda.wfp.org/api/v1/forms/", form_id, "/form.xlsx")
  tmp <- tempfile(fileext = ".xlsx")

  res <- httr::GET(
    url,
    httr::add_headers(Authorization = paste("Token ", token)),
    httr::write_disk(tmp, overwrite = TRUE),
    httr::timeout(600)
  )

  if (httr::status_code(res) == 200) {
    return(tmp)
  }
  NULL
}

# Apply choice labels to a MODA dataframe using an ODK label map
apply_odk_labels <- function(df, label_map) {
  if (is.null(label_map) || length(label_map) == 0) {
    return(df)
  }

  for (var in names(label_map)) {
    if (!var %in% names(df)) next
    lookup <- label_map[[var]]
    old_vals <- as.character(df[[var]])
    is_multiple <- any(grepl("\\s", old_vals[!is.na(old_vals)]))

    if (is_multiple) {
      # select_multiple: space-separated names. Translate each distinct value
      # once (a 1M-row column usually has a few hundred distinct combinations)
      # instead of splitting every row.
      uniq <- unique(old_vals[!is.na(old_vals)])
      translated <- vapply(strsplit(uniq, "\\s+", perl = TRUE), function(parts) {
        labelled <- lookup[parts]
        labelled[is.na(labelled)] <- parts[is.na(labelled)]
        paste(labelled, collapse = " ")
      }, character(1))
      new_vals <- translated[match(old_vals, uniq)]
    } else {
      new_vals <- lookup[old_vals]
      new_vals[is.na(new_vals) & !is.na(old_vals)] <- old_vals[is.na(new_vals) & !is.na(old_vals)]
    }

    df[[var]] <- new_vals
  }

  df
}

# Records per request. ONA accepts page sizes up to 10,000; 1,000 keeps each
# JSON payload small enough to parse quickly while cutting a 20k-row form from
# ~2,000 round-trips (at the old page_size = 10) to 20.
MODA_PAGE_SIZE <- 1000L

# ONA `query` filter so a re-sync only fetches submissions newer than what is
# already in memory. Returns "" when no `_submission_time` column is present.
moda_incremental_query <- function(existing_df) {
  if (is.null(existing_df) || !"_submission_time" %in% names(existing_df)) return("")
  ts <- as.character(existing_df[["_submission_time"]])
  ts <- ts[!is.na(ts) & nzchar(ts)]
  if (length(ts) == 0) return("")
  q <- sprintf('{"_submission_time":{"$gt":"%s"}}', max(ts))
  paste0("&query=", utils::URLencode(q, reserved = TRUE))
}

# Asynchronously fetch MODA submissions and merge them with an existing dataset.
# Returns the combined data.frame to `on_success(list(df = ..., added = ..., total = ...))`.
moda_async_fetch <- function(form_id, token, existing_df = NULL, page_size = MODA_PAGE_SIZE,
                              session = NULL,
                              on_success = NULL, on_error = NULL) {
  base_url <- "https://api.moda.wfp.org/api/v1/data"
  query <- moda_incremental_query(existing_df)

  state <- new.env()
  state$page <- 1
  state$all_pages <- list()
  state$total_rows <- 0
  state$total_pages <- NA_integer_
  state$done <- FALSE

  w <- waiter::Waiter$new(
    html = waiter_content("Syncing MODA data...", percent = 0),
    color = "rgba(10, 30, 50, 0.65)"
  )
  w$show()
  if (!is.null(session)) session$flushOutput()

  handle_error <- function(msg) {
    w$hide()
    if (is.function(on_error)) on_error(msg)
  }

  finalize <- function() {
    if (state$done) return()
    state$done <- TRUE
    on.exit(w$hide(), add = TRUE)

    if (length(state$all_pages) == 0) {
      # An incremental re-sync that finds nothing is a success, not an error
      if (!is.null(existing_df) && nrow(existing_df) > 0 && is.function(on_success)) {
        on_success(list(df = existing_df, added = 0L, total = nrow(existing_df)))
      } else {
        handle_error("No new submissions found.")
      }
      return()
    }

    w$update(html = waiter_content("Reading submissions..."))
    state$all_pages <- harmonize_pages(state$all_pages)
    df <- dplyr::bind_rows(state$all_pages)
    state$all_pages <- NULL   # release the per-page copies before merging
    names(df) <- make_unique_names(strip_prefix(names(df)))

    w$update(html = waiter_content("Downloading form definition..."))
    odk_path <- download_moda_xlsform(form_id, token)

    w$update(html = waiter_content("Applying choice labels..."))
    label_map <- build_odk_label_map(odk_path)
    df <- apply_odk_labels(df, label_map)

    w$update(html = waiter_content("Merging with existing data..."))
    if (!is.null(existing_df) && nrow(existing_df) > 0) {
      id_col <- intersect(c("_id", "_uuid"), names(existing_df))[1]
      new_id_col <- intersect(c("_id", "_uuid"), names(df))[1]
      if (!is.null(id_col) && !is.null(new_id_col)) {
        existing_ids <- as.character(existing_df[[id_col]])
        new_ids <- as.character(df[[new_id_col]])
        df <- df[!new_ids %in% existing_ids, , drop = FALSE]
      }
      combined <- dplyr::bind_rows(existing_df, df)
    } else {
      combined <- df
    }

    if (is.function(on_success)) {
      on_success(list(df = combined, added = nrow(df), total = nrow(combined)))
    }
  }

  fetch_chunk <- function() {
    if (state$done || (!is.null(session) && session$isClosed())) return()

    url <- paste0(base_url, "/", form_id, ".json?page=", state$page, "&page_size=", page_size, query)

    page_msg <- if (is.na(state$total_pages)) {
      paste("chunk", state$page)
    } else {
      paste0("chunk ", state$page, "/", state$total_pages)
    }
    records_msg <- if (state$total_rows > 0) {
      paste0(prettyNum(state$total_rows, big.mark = ",", scientific = FALSE), " records so far")
    } else {
      "Starting download..."
    }
    pct <- if (is.na(state$total_pages)) NULL else round(100 * (state$page - 1) / state$total_pages, 0)
    w$update(html = waiter_content(
      message = "Downloading MODA data...",
      percent = pct,
      subtitle = paste0(page_msg, " | ", records_msg)
    ))
    if (!is.null(session)) session$flushOutput()

    pool <- curl::new_pool()
    h <- curl::new_handle()
    curl::handle_setopt(h, url = url, connecttimeout = 15L, timeout = 60L, followlocation = TRUE)
    curl::handle_setheaders(
      h,
      Authorization = paste("Token ", token),
      `User-Agent` = "TargetWise/0.1",
      Accept = "application/json"
    )
    state$response_done <- FALSE

    on_done <- function(res) {
      if (state$done || state$response_done) return()
      state$response_done <- TRUE

      if (res$status_code != 200) {
        handle_error(paste("MODA returned HTTP", res$status_code))
        return()
      }

      if (is.na(state$total_pages)) {
        hdrs <- curl::parse_headers_list(res$headers)
        state$total_pages <- parse_total_pages(hdrs[["link"]])
      }

      txt <- rawToChar(res$content)
      df_page <- jsonlite::fromJSON(txt, flatten = TRUE)

      if (!is.data.frame(df_page) || nrow(df_page) == 0) {
        finalize()
        return()
      }

      state$all_pages[[state$page]] <- df_page
      state$total_rows <- state$total_rows + nrow(df_page)

      page_msg_done <- if (is.na(state$total_pages)) {
        paste("chunk", state$page)
      } else {
        paste0("chunk ", state$page, "/", state$total_pages)
      }
      pct_done <- if (is.na(state$total_pages)) NULL else round(100 * state$page / state$total_pages, 0)
      w$update(html = waiter_content(
        message = "Downloading MODA data...",
        percent = pct_done,
        subtitle = paste0(
          page_msg_done, " | ",
          prettyNum(state$total_rows, big.mark = ",", scientific = FALSE), " records downloaded"
        )
      ))
      if (!is.null(session)) session$flushOutput()

      if (nrow(df_page) < page_size) {
        finalize()
        return()
      }

      state$page <- state$page + 1
      if (state$page > 10000) {
        finalize()
        return()
      }

      later::later(fetch_chunk, delay = 0)
    }

    on_fail <- function(err) {
      if (state$done || state$response_done) return()
      state$response_done <- TRUE
      handle_error(conditionMessage(err))
    }

    curl::multi_add(h, done = on_done, fail = on_fail, pool = pool)

    poll <- function() {
      if (state$done || state$response_done) return()
      res <- curl::multi_run(timeout = 0.2, pool = pool)
      if (res$pending == 0 && !state$response_done) {
        state$empty_ticks <- if (is.null(state$empty_ticks)) 1 else state$empty_ticks + 1
        if (state$empty_ticks > 5) {
          state$response_done <- TRUE
          handle_error(
            paste0(
              "Connection closed before a response was received. ",
              "(success=", res$success, ", error=", res$error, ")"
            )
          )
          return()
        }
      } else {
        state$empty_ticks <- 0
      }
      later::later(poll, delay = 0.1)
    }

    poll()
  }

  fetch_chunk()
}

mod_moda_import_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # This reactive will hold the downloaded data
    moda_data <- reactiveVal(NULL)

    # Tracks whether the user clicked Cancel on the MODA download waiter
    cancel_requested <- reactiveVal(FALSE)

    # Prevents starting two overlapping MODA downloads
    download_running <- reactiveVal(FALSE)

    # Stores MODA form ID + token so the session can be re-synced later
    moda_credentials <- reactiveVal(NULL)

    # Reference to the currently active MODA waiter, so Cancel can hide/resume it
    current_waiter <- reactiveVal(NULL)

    # Active curl pool for the in-flight chunk; the timer below drives it.
    active_pool <- reactiveVal(NULL)

    # Shared state env for the current download, so the timer observer can see it.
    download_state <- reactiveVal(NULL)

    # Helper to render status messages without needing the local do_sync closure
    show_moda_status <- function(type, msg) {
      output$sync_status <- renderUI({
        tags$div(
          class = paste("alert", paste0("alert-", type), "mt-3"),
          icon(switch(type,
            success = "check-circle",
            info = "info-circle",
            "exclamation-circle"
          )),
          if (type == "danger") " Error: " else " ",
          msg
        )
      })
    }

    hide_moda_waiter <- function() {
      w <- current_waiter()
      if (!is.null(w)) w$hide()
    }

    # Drives the non-blocking curl pool at ~10 ticks per second, but only
    # while a download is actually in flight. This used to be a bare
    # reactiveTimer(100), which kept every session -- including ones that never
    # touch MODA -- flushing the whole reactive graph ten times a second for as
    # long as the browser tab stayed open.
    #
    # The body is isolated because it writes the same reactives it reads; the
    # invalidateLater above is what keeps it ticking.
    observe({
      if (!isTRUE(download_running())) return()
      invalidateLater(100, session)

      isolate({
      state <- download_state()
      pool <- active_pool()
      if (is.null(state) || is.null(pool) || state$done) return()

      if (cancel_requested()) {
        state$done <- TRUE
        curl::multi_cancel(pool)
        active_pool(NULL)
        download_state(NULL)
        hide_moda_waiter()
        download_running(FALSE)
        show_moda_status("info", "Download cancelled by user.")
        return()
      }

      if (state$response_done) {
        active_pool(NULL)
        download_state(NULL)
        return()
      }

      res <- curl::multi_run(timeout = 0.2, pool = pool)
      if (res$pending == 0 && !state$response_done) {
        state$empty_ticks <- if (is.null(state$empty_ticks)) 1 else state$empty_ticks + 1
        if (state$empty_ticks > 5) {
          state$response_done <- TRUE
          active_pool(NULL)
          download_state(NULL)
          hide_moda_waiter()
          download_running(FALSE)
          show_moda_status(
            "danger",
            paste0(
              "Connection closed before a response was received. ",
              "(success=", res$success, ", error=", res$error, ")"
            )
          )
        }
      } else {
        state$empty_ticks <- 0
      }
      })
    })

    observeEvent(input$cancel_download, {
      if (!is.null(current_waiter())) current_waiter()$hide()
      showModal(modalDialog(
        title = tags$div(icon("hand"), " Cancel MODA download?"),
        size = "s",
        easyClose = FALSE,
        footer = tagList(
          actionButton(ns("btn_keep_downloading"), "Keep downloading", class = "btn-primary"),
          actionButton(ns("btn_confirm_cancel"), "Yes, cancel", class = "btn-outline-danger")
        ),
        "Are you sure you want to stop the MODA download? Any records already downloaded will be discarded."
      ))
    })

    observeEvent(input$btn_keep_downloading, {
      removeModal()
      if (!is.null(current_waiter())) current_waiter()$show()
    })

    observeEvent(input$btn_confirm_cancel, {
      removeModal()
      cancel_requested(TRUE)
    })

    observeEvent(input$btn_open_moda, {
      showModal(modalDialog(
        title = "Import from a data collection server",
        size = "m",
        easyClose = TRUE,
        footer = modalButton("Close"),
        selectInput(ns("provider"), "Server:", choices = provider_choices(),
                    selected = "moda", width = "100%"),
        uiOutput(ns("provider_fields")),
        uiOutput(ns("provider_note")),

        actionButton(
          ns("do_sync"),
          "Sync Now",
          class = "btn-primary w-100",
          icon = icon("sync")
        ),

        hr(),
        uiOutput(ns("sync_status"))
      ))
    })

    # Each provider identifies a form differently, and Kobo / ODK can be
    # self-hosted, so the credential fields follow the chosen server.
    output$provider_fields <- renderUI({
      p <- get_provider(input$provider %||% "moda")
      tagList(
        if (!isTRUE(p$server_fixed)) {
          textInput(ns("server"), "Server URL:", value = p$server, width = "100%")
        },
        if (isTRUE(p$needs_project)) {
          textInput(ns("project"), "Project ID:", placeholder = "e.g. 3", width = "100%")
        },
        textInput(ns("form_id"), paste0(p$form_label, ":"),
                  placeholder = p$form_placeholder, width = "100%"),
        passwordInput(ns("token"), paste0(p$token_label, ":"), width = "100%")
      )
    })

    output$provider_note <- renderUI({
      prov <- input$provider %||% "moda"
      tags$p(
        class = "text-muted small mt-2",
        icon("info-circle"), " ",
        if (identical(prov, "moda")) {
          "Downloads submissions and applies choice labels from the MODA form definition."
        } else {
          paste("Downloads all submissions page by page. Choice labels are not",
                "applied for this server, so values arrive as they are stored.")
        }
      )
    })

    # Kobo and ODK use the simple paged fetch; MODA keeps its own asynchronous,
    # resumable client below, which is the path that has to survive a large
    # sync over a field connection.
    observeEvent(input$do_sync, {
      prov <- input$provider %||% "moda"
      if (identical(prov, "moda")) return()
      req(input$form_id, input$token)
      req(!download_running())

      p <- get_provider(prov)
      download_running(TRUE)
      on.exit(download_running(FALSE), add = TRUE)

      w <- waiter::Waiter$new(
        html = waiter_content(paste0("Connecting to ", p$label, "..."), percent = 0),
        color = "rgba(10, 30, 50, 0.65)"
      )
      w$show()
      session$flushOutput()
      on.exit(w$hide(), add = TRUE)

      df <- tryCatch(
        provider_fetch(
          provider = prov,
          server = input$server %||% p$server,
          project = input$project,
          form = input$form_id,
          token = input$token,
          page_size = MODA_PAGE_SIZE,
          progress = function(page, rows) {
            w$update(html = waiter_content(
              paste0("Downloading from ", p$label, "..."),
              subtitle = paste(format(rows, big.mark = ","), "records so far")
            ))
          }
        ),
        error = function(e) {
          show_moda_status("danger", paste("Download failed:", conditionMessage(e)))
          NULL
        }
      )
      req(df)

      if (nrow(df) == 0) {
        show_moda_status("warning", "The form has no submissions yet.")
        return()
      }
      removeModal()
      moda_data(df)
      showNotification(
        paste0(format(nrow(df), big.mark = ","), " records imported from ", p$label, "."),
        type = "message"
      )
    })

    observeEvent(input$do_sync, {
      req(identical(input$provider %||% "moda", "moda"))
      req(input$form_id, input$token)
      req(!download_running())

      # Reset cancellation flag at the start of every sync
      cancel_requested(FALSE)
      download_running(TRUE)

      w <- waiter::Waiter$new(
        html = waiter_content("Connecting to MODA server...", percent = 0, ns = ns),
        color = "rgba(10, 30, 50, 0.65)"
      )
      w$show()
      session$flushOutput()
      current_waiter(w)

      base_url <- "https://api.moda.wfp.org/api/v1/data"
      page_size <- MODA_PAGE_SIZE

      state <- new.env()
      state$page <- 1
      state$all_pages <- list()
      state$total_rows <- 0
      state$total_pages <- NA_integer_
      state$done <- FALSE
      download_state(state)

      show_status <- function(type, msg) {
        hide_moda_waiter()
        download_running(FALSE)
        active_pool(NULL)
        download_state(NULL)
        show_moda_status(type, msg)
      }

      finalize <- function() {
        if (state$done) return()
        state$done <- TRUE

        on.exit({
          download_running(FALSE)
          active_pool(NULL)
          download_state(NULL)
          w$hide()
        }, add = TRUE)

        if (length(state$all_pages) == 0) {
          show_status("info", "No submissions found for this form ID.")
          return()
        }

        w$update(html = waiter_content(
          paste0("Reading ", prettyNum(state$total_rows, big.mark = ",", scientific = FALSE), " submissions..."),
          ns = ns
        ))

        state$all_pages <- harmonize_pages(state$all_pages)
        df <- dplyr::bind_rows(state$all_pages)
        state$all_pages <- NULL   # release the per-page copies
        names(df) <- make_unique_names(strip_prefix(names(df)))

        # Download the XLSForm definition from MODA and apply choice labels
        w$update(html = waiter_content("Downloading form definition...", ns = ns))
        odk_path <- download_moda_xlsform(input$form_id, input$token)

        w$update(html = waiter_content("Applying choice labels...", ns = ns))
        label_map <- build_odk_label_map(odk_path)
        df <- apply_odk_labels(df, label_map)

        w$update(html = waiter_content("Finalizing...", ns = ns))
        moda_data(df)
        moda_credentials(list(form_id = input$form_id, token = input$token))

        label_msg <- if (!is.null(label_map)) " (choice labels applied)" else ""
        output$sync_status <- renderUI({
          tags$div(
            class = "alert alert-success mt-3",
            icon("check-circle"),
            " Success: ", prettyNum(nrow(df), big.mark = ",", scientific = FALSE), " records synced.", label_msg
          )
        })
      }

      fetch_chunk <- function() {
        if (state$done || session$isClosed()) return()
        if (cancel_requested()) {
          show_status("info", "Download cancelled by user.")
          return()
        }

        url <- paste0(base_url, "/", input$form_id, ".json?page=", state$page, "&page_size=", page_size)

        page_msg <- if (is.na(state$total_pages)) {
          paste("chunk", state$page)
        } else {
          paste0("chunk ", state$page, "/", state$total_pages)
        }
        records_msg <- if (state$total_rows > 0) {
          paste0(prettyNum(state$total_rows, big.mark = ",", scientific = FALSE), " records so far")
        } else {
          "Starting download..."
        }
        pct <- if (is.na(state$total_pages)) NULL else round(100 * (state$page - 1) / state$total_pages, 0)

        w$update(html = waiter_content(
          message = "Downloading MODA data...",
          percent = pct,
          subtitle = paste0(page_msg, " | ", records_msg),
          ns = ns
        ))
        session$flushOutput()

        # Use curl's non-blocking multi interface so the R session stays responsive
        # and the Cancel button works even while a request is in flight.
        pool <- curl::new_pool()
        h <- curl::new_handle()
        curl::handle_setopt(h, url = url, connecttimeout = 15L, timeout = 60L, followlocation = TRUE)
        curl::handle_setheaders(
          h,
          Authorization = paste("Token ", input$token),
          `User-Agent` = "TargetWise/0.1",
          Accept = "application/json"
        )
        state$response_done <- FALSE

        on_done <- function(res) {
          if (state$done || state$response_done) return()
          state$response_done <- TRUE

          if (res$status_code != 200) {
            show_status("danger", paste("MODA returned HTTP", res$status_code))
            return()
          }

          if (is.na(state$total_pages)) {
            hdrs <- curl::parse_headers_list(res$headers)
            state$total_pages <- parse_total_pages(hdrs[["link"]])
          }

          txt <- rawToChar(res$content)
          df_page <- jsonlite::fromJSON(txt, flatten = TRUE)

          if (!is.data.frame(df_page) || nrow(df_page) == 0) {
            finalize()
            return()
          }

          state$all_pages[[state$page]] <- df_page
          state$total_rows <- state$total_rows + nrow(df_page)

          page_msg_done <- if (is.na(state$total_pages)) {
            paste("chunk", state$page)
          } else {
            paste0("chunk ", state$page, "/", state$total_pages)
          }
          pct_done <- if (is.na(state$total_pages)) NULL else round(100 * state$page / state$total_pages, 0)
          w$update(html = waiter_content(
            message = "Downloading MODA data...",
            percent = pct_done,
            subtitle = paste0(
              page_msg_done, " | ",
              prettyNum(state$total_rows, big.mark = ",", scientific = FALSE), " records downloaded"
            ),
            ns = ns
          ))
          session$flushOutput()

          if (nrow(df_page) < page_size) {
            finalize()
            return()
          }

          state$page <- state$page + 1
          if (state$page > 10000) {
            finalize()
            return()
          }

          fetch_chunk()
        }

        on_fail <- function(err) {
          if (state$done || state$response_done) return()
          state$response_done <- TRUE
          active_pool(NULL)
          show_status("danger", conditionMessage(err))
        }

        curl::multi_add(h, done = on_done, fail = on_fail, pool = pool)
        active_pool(pool)
      }

      fetch_chunk()
    })

    # Return the reactive data and credentials so the main server can use them
    return(list(data = moda_data, credentials = moda_credentials))
  })
}


## To be copied in the UI
# mod_moda_import_ui("moda_import_1")

## To be copied in the server
# mod_moda_import_server("moda_import_1")
