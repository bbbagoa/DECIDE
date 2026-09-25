#' moda_import UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_moda_import_ui <- function(id, label = "Import from a server", class = "btn-outline-secondary w-100") {
  ns <- NS(id)
  tagList(
    actionButton(
      ns("btn_open_moda"),
      label,
      class = class,
      icon = icon("cloud-download"),
      title = "Import from a MODA / ONA form"
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
  # Lists (_geolocation, repeat groups, attachments) become plain columns
  # first; the type coercion below would turn them into "c(12.3, -1.5)".
  kinds <- list_column_kinds(pages)
  pages <- lapply(pages, flatten_list_columns, kinds = kinds)
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
  # The label column in the app's language when the form has one
  # (label::French, label::English (en)...), else the first.
  labs <- grep("^label", names(choices), value = TRUE)
  want <- if (identical(import_yes_no()[1], "Oui")) "fran|french|[(]fr[)]" else "english|[(]en[)]"
  choice_label_col <- c(grep(want, labs, value = TRUE, ignore.case = TRUE), labs)[1]

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

  attr(label_map, "label_column") <- choice_label_col
  # Which questions are select_multiple: they are split into Yes/No columns.
  attr(label_map, "multiple") <- unique(survey$var_name[grepl("^select_multiple", as.character(survey[[type_col]]))])
  label_map
}

# Try to download the ODK XLSForm definition from MODA using the same token
download_moda_xlsform <- function(form_id, token) {
  url <- paste0("https://api.moda.wfp.org/api/v1/forms/", form_id, "/form.xlsx")
  tmp <- tempfile(fileext = ".xlsx")

  res <- httr::GET(
    url,
    httr::add_headers(Authorization = paste("Token", token)),
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

  multiple <- attr(label_map, "multiple") %||% character(0)
  for (var in names(label_map)) {
    if (!var %in% names(df)) next
    lookup <- label_map[[var]]
    old_vals <- as.character(df[[var]])
    is_multiple <- var %in% multiple || any(grepl("\\s", old_vals[!is.na(old_vals)]))

    if (is_multiple) {
      # One 0/1 column per choice (<question>_<choice>), next to the question.
      df <- insert_columns(df, var, split_multiple(old_vals, names(lookup), var))
      # select_multiple: space-separated names. Translate each distinct value
      # once (a 1M-row column usually has a few hundred distinct combinations)
      # instead of splitting every row. Labels are joined with "; ": they can
      # contain spaces themselves.
      uniq <- unique(old_vals[!is.na(old_vals)])
      translated <- vapply(strsplit(uniq, "\\s+", perl = TRUE), function(parts) {
        labelled <- lookup[parts]
        labelled[is.na(labelled)] <- parts[is.na(labelled)]
        paste(labelled, collapse = "; ")
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
    html = waiter_content(sprintf("Checking MODA form %s...", form_id), percent = 0),
    color = "rgba(10, 30, 50, 0.65)"
  )
  w$show()
  if (!is.null(session)) session$flushOutput()
  info <- moda_form_info(form_id, token)
  if (!isTRUE(info$ok) && !is.na(info$status)) {
    w$hide()
    if (is.function(on_error)) on_error(info$message)
    return(invisible(NULL))
  }
  label <- moda_form_label(info, form_id)
  if (!is.null(session)) waiter_progress(session, message = paste("Downloading", label), subtitle = "Connecting to MODA...")

  handle_error <- function(msg) {
    w$hide()
    if (is.function(on_error)) on_error(msg)
  }

  finalize <- function() {
    if (state$done) return()
    state$done <- TRUE
    on.exit(w$hide(), add = TRUE)
    # Each step written into the loader in place (no redraw).
    step <- function(msg) if (!is.null(session)) waiter_progress(session, message = msg, percent = 100, subtitle = "") else
      w$update(html = waiter_content(msg))

    if (length(state$all_pages) == 0) {
      # An incremental re-sync that finds nothing is a success, not an error
      if (!is.null(existing_df) && nrow(existing_df) > 0 && is.function(on_success)) {
        on_success(list(df = existing_df, added = 0L, total = nrow(existing_df)))
      } else {
        handle_error("No new submissions found.")
      }
      return()
    }

    step(paste("Reading the submissions of", label))
    state$all_pages <- harmonize_pages(state$all_pages)
    df <- dplyr::bind_rows(state$all_pages)
    state$all_pages <- NULL   # release the per-page copies before merging
    names(df) <- make_unique_names(strip_prefix(names(df)))
    df <- utf8_frame(df)   # same text handling as file imports

    step(paste("Downloading the form definition of", label))
    odk_path <- download_moda_xlsform(form_id, token)

    step("Applying choice labels...")
    label_map <- build_odk_label_map(odk_path)
    df <- apply_odk_labels(df, label_map)
    df <- split_multiselect(split_geopoints(df))   # GPS -> coordinates; multi-selects the form did not name -> Yes/No columns

    step("Merging with the data already loaded...")
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

  moda_fetch_pages(
    page_url = function(pg) paste0(base_url, "/", form_id, ".json?page=", pg, "&page_size=", page_size, query),
    token = token, page_size = page_size,
    progress = function(done, total, rows) {
      if (is.null(session)) return()
      waiter_progress(session,
        percent = if (is.na(total)) NULL else round(100 * done / total),
        subtitle = paste0(if (is.na(total)) paste(done, "pages") else paste0(done, "/", total, " pages"), " \u00b7 ",
                          prettyNum(rows, big.mark = ",", scientific = FALSE), " records"))
      session$flushOutput()
    },
    finished = function(pages) { state$all_pages <- pages; finalize() },
    failed = function(msg, cancelled = FALSE) handle_error(msg),
    cancelled = function() !is.null(session) && session$isClosed()
  )
  invisible(NULL)
}

mod_moda_import_server <- function(id, summary = TRUE) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # What was imported, for the "Data imported" dialog: the form's name and
    # what was done with its definition.
    import_label <- reactiveVal(NULL)
    import_notes <- reactiveVal(NULL)
    # Close the MODA dialog and confirm the import with the summary, unless
    # the caller shows its own (the registration import does).
    confirm_import <- function(df) {
      removeModal()
      if (isTRUE(summary)) showModal(import_summary_modal(df, label = import_label(), notes = import_notes()))
    }

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
        # The key typed for the first import is offered for every later one.
        passwordInput(ns("token"), paste0(p$token_label, ":"), width = "100%",
                      value = api_key_get(session, input$provider %||% "moda") %||% ""),
        if (!is.null(api_key_get(session, input$provider %||% "moda")))
          tags$div(class = "small text-muted mt-n2 mb-2", bsicons::bs_icon("key"),
                   " The key entered earlier in this session is filled in; change it if needed. It is never saved.")
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
      api_key_set(session, input$token, prov)
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
            waiter_progress(session, message = paste0("Downloading from ", p$label, "..."),
                            subtitle = paste(format(rows, big.mark = ","), "records so far"))
            session$flushOutput()
          }
        ),
        error = function(e) {
          show_moda_status("danger", paste("Download failed:", conditionMessage(e)))
          NULL
        }
      )
      req(df)
      df <- split_multiselect(split_geopoints(flatten_list_columns(utf8_frame(df))))

      if (nrow(df) == 0) {
        show_moda_status("warning", "The form has no submissions yet.")
        return()
      }
      import_label(paste0(p$label, ": form ", input$form_id))
      import_notes(list(list(ok = FALSE, text = paste("Choice labels are not applied for", p$label, "(values arrive as stored)."))))
      moda_data(df)
      confirm_import(df)
    })

    # MODA: Sync Now first checks the form (title, submissions, last one
    # received) and asks for confirmation; Download then fetches it.
    moda_pending <- reactiveVal(NULL)
    observeEvent(input$do_sync, {
      req(identical(input$provider %||% "moda", "moda"))
      req(!download_running())
      form_id <- trimws(input$form_id %||% ""); token <- trimws(input$token %||% "")
      if (!nzchar(form_id) || !nzchar(token)) {
        show_moda_status("warning", "Enter the form ID and the API key.")
        return()
      }
      api_key_set(session, token, "moda")
      w <- waiter::Waiter$new(html = waiter_content(sprintf("Checking MODA form %s...", form_id)),
                              color = "rgba(10, 30, 50, 0.65)")
      w$show(); on.exit(w$hide(), add = TRUE)
      session$flushOutput()
      info <- moda_form_info(form_id, token)
      moda_pending(list(form_id = form_id, token = token, info = info))
      # A refused key or an unknown form stops here; an unreachable forms
      # endpoint still lets the officer try the download.
      if (!isTRUE(info$ok) && !is.na(info$status)) {
        show_moda_status("danger", info$message)
        return()
      }
      when <- if (isTRUE(info$ok) && nzchar(info$last)) format(as.POSIXct(substr(info$last, 1, 19), format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"), "%d %b %Y %H:%M") else NA
      output$sync_status <- renderUI(tags$div(
        class = "wfp-moda-confirm mt-3",
        if (isTRUE(info$ok)) tagList(
          tags$div(class = "small text-muted", "Form to download"),
          tags$div(class = "wfp-moda-title", info$title),
          tags$div(class = "small text-muted mb-2",
                   paste(c(sprintf("ID %s", form_id), if (nzchar(info$id_string)) info$id_string,
                           if (!is.na(info$submissions)) sprintf("%s submissions", format(info$submissions, big.mark = ",")),
                           if (!is.na(when)) paste("last received", when)), collapse = " \u00b7 ")))
        else tags$div(class = "small text-warning mb-2", bsicons::bs_icon("exclamation-triangle"), " ", info$message,
                      " You can still try the download."),
        tags$div(class = "d-flex gap-2 justify-content-end",
                 actionButton(ns("moda_change"), "Change form", class = "btn-outline-secondary btn-sm"),
                 actionButton(ns("moda_confirm"), if (isTRUE(info$ok)) "Download" else "Download anyway",
                              icon = icon("cloud-arrow-down"), class = "btn-primary btn-sm"))
      ))
    })
    observeEvent(input$moda_change, { moda_pending(NULL); output$sync_status <- renderUI(NULL) })

    observeEvent(input$moda_confirm, {
      pend <- moda_pending(); req(pend)
      req(!download_running())
      output$sync_status <- renderUI(NULL)

      # Reset cancellation flag at the start of every sync
      cancel_requested(FALSE)
      download_running(TRUE)

      form_id <- pend$form_id; token <- pend$token
      label <- moda_form_label(pend$info, form_id)
      w <- waiter::Waiter$new(
        html = waiter_content(paste0("Downloading ", label), percent = 0,
                              subtitle = "Connecting to MODA...", ns = ns),
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

      show_status <- function(type, msg) {
        hide_moda_waiter()
        download_running(FALSE)
        show_moda_status(type, msg)
      }

      finalize <- function() {
        if (state$done) return()
        state$done <- TRUE

        on.exit({
          download_running(FALSE)
          w$hide()
        }, add = TRUE)

        if (length(state$all_pages) == 0) {
          show_status("info", "No submissions found for this form ID.")
          return()
        }

        waiter_progress(session, message = paste0("Reading ", prettyNum(state$total_rows, big.mark = ",", scientific = FALSE),
                                                  " submissions of ", label), percent = 100, subtitle = "")

        state$all_pages <- harmonize_pages(state$all_pages)
        df <- dplyr::bind_rows(state$all_pages)
        state$all_pages <- NULL   # release the per-page copies
        names(df) <- make_unique_names(strip_prefix(names(df)))
        df <- utf8_frame(df)   # same text handling as file imports
        before <- names(df)

        # Download the XLSForm definition from MODA and apply choice labels
        waiter_progress(session, message = paste("Downloading the form definition of", label))
        odk_path <- download_moda_xlsform(form_id, token)

        waiter_progress(session, message = "Applying choice labels...")
        label_map <- build_odk_label_map(odk_path)
        df <- apply_odk_labels(df, label_map)
        df <- split_multiselect(split_geopoints(df))   # GPS -> coordinates; multi-selects the form did not name -> Yes/No columns

        waiter_progress(session, message = "Finalizing...")
        import_label(paste("MODA:", label))
        import_notes(form_import_notes(before, df, label_map, downloaded = !is.null(odk_path)))
        moda_data(df)
        moda_credentials(list(form_id = form_id, token = token))

        confirm_import(df)
      }

      moda_fetch_pages(
        page_url = function(pg) paste0(base_url, "/", form_id, ".json?page=", pg, "&page_size=", page_size),
        token = token, page_size = page_size,
        progress = function(done, total, rows) {
          state$total_rows <- rows
          # Written into the loader in place: no redraw, no flicker.
          waiter_progress(session,
            percent = if (is.na(total)) NULL else round(100 * done / total),
            subtitle = paste0(if (is.na(total)) paste(done, "pages") else paste0(done, "/", total, " pages"), " \u00b7 ",
                              prettyNum(rows, big.mark = ",", scientific = FALSE), " records"))
          session$flushOutput()
        },
        # The engine calls back from later(), outside any reactive context.
        finished = function(pages) isolate({ state$all_pages <- pages; finalize() }),
        failed = function(msg, cancelled = FALSE) isolate(show_status(if (cancelled) "info" else "danger", msg)),
        cancelled = function() session$isClosed() || isTRUE(isolate(cancel_requested()))
      )
    })

    # Return the reactive data and credentials so the main server can use them
    return(list(data = moda_data, credentials = moda_credentials, label = import_label, notes = import_notes))
  })
}


## To be copied in the UI
# mod_moda_import_ui("moda_import_1")

## To be copied in the server
# mod_moda_import_server("moda_import_1")
