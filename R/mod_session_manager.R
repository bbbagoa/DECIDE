#' Session Manager Module UI
#'
#' Provides a restore-session modal and a small control menu for saving,
#' loading, and clearing persisted sessions.
#'
#' @param id module id
#' @import shiny
#' @noRd
mod_session_manager_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("restore_modal_container")),
    uiOutput(ns("session_menu"))
  )
}

#' Session Manager Module Server
#'
#' Handles auto-save, restore-on-startup, and manual session controls.
#'
#' @param id module id
#' @param uploaded_df reactiveVal holding the working data frame
#' @param user_setup reactiveValues holding the variable mapping
#' @param modification_log reactiveVal holding the audit log data frame
#' @param theme reactive expression returning the current theme choice
#'
#' @import shiny
#' @importFrom utils write.csv
#' @noRd
mod_session_manager_server <- function(
    id,
    uploaded_df,
    user_setup,
    modification_log,
    theme = reactive("wfp"),
    parent_session = NULL,
    moda_credentials = reactive(NULL),
    sync_trigger = reactiveVal(0),
    original_df = NULL,
    workspace = NULL
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Every session read/write below is scoped to this user, so two people on
    # the same server never see (or can decrypt) each other's households.
    # NULL on a local desktop run, which keeps the single-user layout.
    who <- app_user(session)

    # Each workstream (Design, Selection, Monitoring) is its own session file,
    # under its own name: loading a Design session names only the Design work.
    kinds <- names(session_kinds())
    session_names <- reactiveValues(design = NULL, selection = NULL, monitoring = NULL)
    any_named <- function() any(vapply(kinds, function(k) !is.null(isolate(session_names[[k]])), logical(1)))
    periodic <- reactiveVal(NULL)   # list(name, kinds, due) while the timed autosave is on
    periodic_minutes <- function() {
      m <- suppressWarnings(as.numeric(tw_env("AUTOSAVE_EVERY_MIN", "20")))
      if (is.na(m) || m < 1) 20 else m
    }
    default_name <- function() {
      nm <- unlist(lapply(kinds, function(k) isolate(session_names[[k]])))
      if (length(nm)) nm[1] else format(Sys.time(), "session_%Y-%m-%d_%Hh%M")
    }

    # Where the background writes (autosave + audit companion) go. Before the
    # user names a session they land in "autosave"; afterwards they follow the
    # named session, so it never goes stale while the user keeps working.
    persist_name <- function(kind) {
      session_stem(isolate(session_names[[kind]]) %||% "autosave", kind)
    }

    # What each workstream would save now.
    current_state <- function(kind, work = workspace_snapshot(workspace)) {
      isolate(workstream_state(kind, uploaded_df(), if (is.function(original_df)) original_df(),
                               reactiveValuesToList(user_setup), modification_log(), moda_credentials(), work))
    }
    save_kind <- function(kind, name, st) {
      page <- current_ui()
      save_session(
        uploaded_df = st$uploaded_df, user_setup = st$user_setup, modification_log = st$modification_log,
        theme = isolate(theme()), moda_credentials = st$moda_credentials, name = name, user = who,
        workspace = st$workspace, original_df = st$original_df, kind = kind, labels = label_registry(session),
        ui = if (identical(workstream_of_page(page$main_nav), kind)) page
      )
      assign(kind, workstream_signature(st), envir = sigs)
      # the page shows it if the connection is lost ("work saved at ...")
      try(session$sendCustomMessage("tw-saved-at", list(at = format(Sys.time(), "%H:%M"))), silent = TRUE)
    }
    sigs <- new.env(parent = emptyenv())   # last saved fingerprint per workstream
    kind_label <- function(kind) session_kinds()[[kind]]

    # Saved sessions as a grouped picker: one group per workstream.
    session_choices <- function(sessions) {
      lab <- c(session_kinds(), all = "Older sessions (all the work)")
      mb <- ifelse(sessions$size < 1024^2, sprintf("%.0f KB", sessions$size / 1024), sprintf("%.1f MB", sessions$size / 1024^2))
      opts <- stats::setNames(sessions$name, sprintf("%s (%s, %s)", sessions$label, format(sessions$saved_at, "%Y-%m-%d %H:%M"), mb))
      grp <- split(opts, factor(sessions$kind, levels = names(lab)))
      grp <- grp[lengths(grp) > 0]
      # a one-option group would render as a single option named after the group
      stats::setNames(lapply(grp, as.list), lab[names(grp)])
    }

    restore_session <- function(name) {
      waiter::waiter_show(
        html = waiter_content(paste0("Loading session \"", name, "\"...")),
        color = "rgba(10, 30, 50, 0.65)"
      )
      # The restored data is drawn after this function returns (the data, then
      # the page the user returns to), which on a large dataset takes longer
      # than reading the file: the overlay stays until the browser reports the
      # page has settled (www/busy.js), not just until the file is read.
      on.exit(session$sendCustomMessage("tw-when-settled", list(id = ns("restore_settled"))), add = TRUE)

      saved <- load_session(name, user = who)
      if (is.null(saved)) {
        showNotification(paste("Could not load session", name), type = "error")
        return()
      }

      # A workstream session puts back its own part and leaves the others'
      # work in memory as it is; an older session ("all") holds everything.
      kind <- saved$kind %||% "all"
      if (!is.null(saved$uploaded_df)) {
        uploaded_df(saved$uploaded_df)
        # The pristine import comes back as the Reset baseline; sessions saved
        # before it was stored fall back to the restored data.
        if (is.function(original_df)) original_df(saved$original_df %||% saved$uploaded_df)
      }
      if (!is.null(saved$user_setup)) {
        for (nm in names(saved$user_setup)) {
          user_setup[[nm]] <- saved$user_setup[[nm]]
        }
      }
      restored_log <- saved$modification_log
      companion_log <- log_for(load_audit_log(name, user = who), kind)
      if (is.data.frame(companion_log) &&
          (is.null(restored_log) || nrow(companion_log) > nrow(restored_log))) {
        restored_log <- companion_log
      }
      if (!is.null(restored_log)) modification_log(log_merge(isolate(modification_log()), restored_log, kind))
      if (!is.null(saved$moda_credentials) && is.function(moda_credentials)) {
        moda_credentials(saved$moda_credentials)
      }
      # Variable and value labels, back into the session's dictionary
      if (length(saved$labels)) register_labels(session = session, add = saved$labels)
      # Targeting Design, selection, spot-check and PDM work
      workspace_restore(workspace, saved$workspace)
      label <- sub("\\.(design|selection|monitoring)$", "", name)
      # A timed autosave belongs to the session it was set on: loading another
      # one stops it, so it never writes this content under the other name.
      p <- isolate(periodic())
      if (!is.null(p) && !identical(p$name, label)) {
        periodic(NULL)
        showNotification("The timed autosave was turned off: another session was loaded.", type = "message")
      }
      # An older session is saved back as three workstream sessions of the same name.
      for (k in if (kind == "all") kinds else kind) {
        session_names[[k]] <- label
        assign(k, workstream_signature(workstream_state(k, saved$uploaded_df, saved$original_df, saved$user_setup,
                                                        restored_log, NULL, saved$workspace)), envir = sigs)
      }

      if (!is.null(parent_session)) {
        # The registration-data pages open only when the session carries that
        # data (a design-only session waits for the registration round).
        if (!is.null(saved$uploaded_df)) {
          bslib::nav_show("main_nav", target = "overview_panel", session = parent_session)
          bslib::nav_show("main_nav", target = "dq_panel", session = parent_session)
          bslib::nav_show("main_nav", target = "spot_panel", session = parent_session)
          bslib::nav_show("main_nav", target = "ben_panel", session = parent_session)
        }
        # Back to the page the user was on.
        pg <- saved$ui$main_nav
        if (shiny::isTruthy(pg) && (!is.null(saved$uploaded_df) || !pg %in% c("overview_panel", "dq_panel", "spot_panel", "ben_panel"))) {
          bslib::nav_select("main_nav", pg, session = parent_session)
        }
      }
      shown <- if (kind == "all") label else sprintf("%s (%s)", label, kind_label(kind))
      # Say what came back, so the user can trust they are where they left.
      got <- session_contents(saved)
      if (length(got)) {
        showModal(modalDialog(
          title = tagList(bsicons::bs_icon("check2-circle"), sprintf(" Session \"%s\" restored", shown)),
          size = "m", easyClose = TRUE, footer = modalButton("Continue"),
          tags$p(class = "small text-muted", sprintf("Saved %s.", format(saved$saved_at %||% Sys.time(), "%Y-%m-%d %H:%M"))),
          tags$ul(class = "small", lapply(got, tags$li))
        ))
      }

      audit_add(modification_log, "Session", "Session loaded", shown)
      mark_saved()
      showNotification(paste("Session", shown, "loaded."), type = "message")
    }

    observeEvent(input$restore_settled, waiter::waiter_hide())

    # -------------------------------------------------------------------------
    # 1. Restore modal on startup
    # -------------------------------------------------------------------------
    output$restore_modal_container <- renderUI({
      # Arrived from "Save and start fresh": no restore prompt.
      if (grepl("(^|[?&])fresh=1", isolate(session$clientData$url_search) %||% "")) return(NULL)
      sessions <- list_saved_sessions(who)
      if (nrow(sessions) == 0) return(NULL)

      choices <- session_choices(sessions)

      showModal(modalDialog(
        title = "Restore a Saved Session",
        size = "m",
        easyClose = FALSE,
        footer = tagList(
          actionButton(ns("btn_start_fresh"), "Start Fresh", class = "btn-outline-secondary")
        ),
        p("Select a session to resume, or start fresh."),
        p(class = "small text-muted", "Design, Selection and Monitoring are saved as separate sessions: load one, then another from Load to work on both."),
        selectInput(ns("restore_session_choice"), "Saved sessions:", choices = choices, width = "100%"),
        bslib::layout_columns(
          actionButton(ns("btn_restore_load"), "Load Session", class = "btn-primary w-100"),
          actionButton(ns("btn_restore_delete"), "Delete Session", class = "btn-outline-danger w-100"),
          col_widths = c(6, 6)
        )
      ))
    })

    # "Start Fresh" only declines to restore. It used to call clear_session(),
    # which permanently deleted every saved session for a user who just wanted
    # to look around. Deleting stays behind the explicit Clear controls below.
    observeEvent(input$btn_start_fresh, {
      removeModal()
      showNotification("Starting fresh. Saved sessions are untouched.", type = "message")
    })

    observeEvent(input$btn_restore_load, {
      need_ok(shiny::isTruthy(input$restore_session_choice), "Choose a saved session first.")
      removeModal()
      restore_session(input$restore_session_choice)
    })

    observeEvent(input$btn_restore_delete, {
      need_ok(shiny::isTruthy(input$restore_session_choice), "Choose a saved session first.")
      name <- input$restore_session_choice
      delete_session(name, user = who)
      # Re-render the modal with the updated list
      output$restore_modal_container <- renderUI({
        sessions <- list_saved_sessions(who)
        if (nrow(sessions) == 0) {
          showModal(modalDialog(
            title = "Restore a Saved Session",
            size = "m",
            easyClose = FALSE,
            footer = actionButton(ns("btn_start_fresh"), "Start Fresh", class = "btn-outline-secondary"),
            p("No saved sessions remaining.")
          ))
          return()
        }
        choices <- session_choices(sessions)
        showModal(modalDialog(
          title = "Restore a Saved Session",
          size = "m",
          easyClose = FALSE,
          footer = actionButton(ns("btn_start_fresh"), "Start Fresh", class = "btn-outline-secondary"),
          p("Select a session to resume, or start fresh."),
          selectInput(ns("restore_session_choice"), "Saved sessions:", choices = choices, width = "100%"),
          bslib::layout_columns(
            actionButton(ns("btn_restore_load"), "Load Session", class = "btn-primary w-100"),
            actionButton(ns("btn_restore_delete"), "Delete Session", class = "btn-outline-danger w-100"),
            col_widths = c(6, 6)
          )
        ))
      })
      showNotification(paste("Session", name, "deleted."), type = "message")
    })

    # -------------------------------------------------------------------------
    # 2. Session control menu
    # -------------------------------------------------------------------------
    output$session_menu <- renderUI({
      # A restored session carries the form but never the API key, so the
      # button shows on the form alone and asks for the key when needed.
      has_moda <- !is.null(moda_credentials()) &&
        is.list(moda_credentials()) &&
        isTruthy(moda_credentials()$form_id)

      tags$div(
        class = "btn-group",
        role = "group",
        aria_label = "Session controls",
        if (has_moda) {
          actionButton(
            ns("btn_sync_moda"), title = "Fetch only the MODA submissions that are not in this session yet",
            "Refresh MODA",
            icon = icon("sync"),
            class = "btn-outline-info btn-sm"
          )
        },
        actionButton(
          ns("btn_save_session"), title = "Save session",
          "Save",
          icon = icon("floppy-disk"),
          class = "btn-success btn-sm"
        ),
        actionButton(
          ns("btn_new_session"), title = "Save this session and start a fresh one",
          "New",
          icon = icon("file-circle-plus"),
          class = "btn-outline-secondary btn-sm"
        ),
        actionButton(
          ns("btn_load_session"), title = "Load a saved session",
          "Load",
          icon = icon("folder-open"),
          class = "btn-info btn-sm"
        ),
        actionButton(
          ns("btn_clear_session"), title = "Delete saved sessions",
          "Clear",
          icon = icon("trash"),
          class = "btn-warning btn-sm"
        )
      )
    })

    observeEvent(input$btn_sync_moda, {
      cred <- moda_credentials()
      if (isTruthy(cred$token)) { sync_trigger(Sys.time()); return() }
      # A restored session has no key: use the one entered earlier in this session.
      known <- api_key_get(session, "moda")
      if (!is.null(known)) { cred$token <- known; moda_credentials(cred); sync_trigger(Sys.time()); return() }
      showModal(modalDialog(
        title = tagList(icon("sync"), " Refresh MODA data"), size = "s", easyClose = TRUE,
        tags$p(class = "small", sprintf("Form %s. The data already in this session is kept; only the submissions received since are fetched.",
                                        cred$form_id)),
        passwordInput(ns("sync_token"), "API Gateway Key", width = "100%"),
        tags$p(class = "small text-muted mb-0", "The key is kept in memory for this session only and is never saved."),
        footer = tagList(modalButton("Cancel"), actionButton(ns("sync_token_go"), "Refresh", class = "btn-primary", icon = icon("sync")))
      ))
    })
    observeEvent(input$sync_token_go, {
      tok <- trimws(input$sync_token %||% "")
      if (!nzchar(tok)) { showNotification("Enter the API key.", type = "warning"); return() }
      api_key_set(session, tok, "moda")
      cred <- moda_credentials(); cred$token <- tok
      moda_credentials(cred)
      removeModal()
      sync_trigger(Sys.time())
    })

    # The workstreams that hold work, each with what it would save.
    kinds_with_work <- function() {
      work <- workspace_snapshot(workspace)
      Filter(function(k) workstream_has_work(current_state(k, work), k), kinds)
    }
    kind_summary <- function(k) {
      st <- current_state(k)
      bits <- switch(k,
        design = if (!is.null(st$workspace$scorecard$data)) sprintf("assessment data, %s rows", format(nrow(st$workspace$scorecard$data), big.mark = ",")),
        selection = if (!is.null(st$uploaded_df)) sprintf("registration data, %s households", format(nrow(st$uploaded_df), big.mark = ",")),
        monitoring = paste(c(if (!is.null(st$workspace$pdm)) "PDM", if (!is.null(st$workspace$monitoring)) "process and report"), collapse = ", "))
      if (length(bits) && nzchar(bits)) sprintf("%s (%s)", kind_label(k), bits) else kind_label(k)
    }
    show_save_dialog <- function() {
      have <- kinds_with_work()
      if (!length(have)) {
        showNotification("Nothing to save: no dataset is loaded and no work has been done.", type = "error")
        return()
      }
      page_kind <- workstream_of_page(current_ui()$main_nav)
      showModal(modalDialog(
        title = "Save Session",
        size = "s",
        easyClose = TRUE,
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("btn_confirm_save"), "Save", class = "btn-primary", icon = icon("floppy-disk"))
        ),
        textInput(ns("save_session_name"), "Session name:", value = default_name(), width = "100%"),
        checkboxGroupInput(ns("save_kinds"), "Save", width = "100%",
                           choiceNames = lapply(have, kind_summary), choiceValues = have, selected = have),
        # Keep saving the same session on a timer (also above the autosave
        # size limit: this is a full save).
        checkboxInput(ns("save_every"), sprintf("Autosave this session every %d minutes", periodic_minutes()),
                      value = !is.null(isolate(periodic()))),
        tags$p(class = "small text-muted mb-0",
               "Each part is its own session file, so loading or saving one does not carry the others' data.",
               if (page_kind %in% have && length(have) > 1) " Untick the parts you do not want to save now.")
      ))
    }
    observeEvent(input$btn_save_session, show_save_dialog())

    # Save everything under `name`; FALSE (with a notice) when there is
    # nothing to save or no name.
    # Save the chosen workstreams under `name`, one file each; FALSE (with a
    # notice) when there is nothing to save or no name.
    save_as <- function(name, which = kinds, quiet = FALSE) {
      if (!shiny::isTruthy(name) || trimws(name) == "") {
        showNotification("Name the session first.", type = "error")
        return(FALSE)
      }
      name <- trimws(name)
      work <- workspace_snapshot(workspace)
      sts <- lapply(stats::setNames(which, which), current_state, work = work)
      sts <- sts[vapply(names(sts), function(k) workstream_has_work(sts[[k]], k), logical(1))]
      if (!length(sts)) {
        showNotification("Nothing to save: no dataset is loaded and no work has been done.", type = "error")
        return(FALSE)
      }
      waiter::waiter_show(
        html = waiter_content(if (quiet) "Autosaving the session..." else "Encrypting and saving session..."),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)
      for (k in names(sts)) {
        waiter_log(kind_label(k), "cmd")
        save_kind(k, name, sts[[k]])
        session_names[[k]] <- name
      }
      what <- paste(vapply(names(sts), kind_label, character(1)), collapse = ", ")
      if (quiet) {
        showNotification(sprintf("Autosaved %s (%s).", name, format(Sys.time(), "%H:%M")), type = "message", duration = 4)
      } else {
        audit_add(modification_log, "Session", "Session saved", sprintf("%s (%s)", name, what))
        showNotification(sprintf("Saved as %s: %s.", name, what), type = "message")
      }
      mark_saved()
      TRUE
    }

    observeEvent(input$btn_confirm_save, {
      need_ok(length(input$save_kinds) > 0, "Tick at least one part to save.")
      removeModal()
      ok <- save_as(input$save_session_name, input$save_kinds)
      if (isTRUE(ok) && isTRUE(input$save_every)) {
        periodic(list(name = trimws(input$save_session_name), kinds = input$save_kinds,
                      due = Sys.time() + 60 * periodic_minutes()))
        showNotification(sprintf("This session will be saved every %d minutes.", periodic_minutes()), type = "message")
      } else if (isTRUE(ok)) {
        periodic(NULL)
      }
    })

    # Autosave every N minutes, set from the save dialog: the same name and
    # parts, saved in full. TARGETWISE_AUTOSAVE_EVERY_MIN changes the period.
    observe({
      p <- periodic(); req(p)
      invalidateLater(60000)
      if (Sys.time() < p$due) return()
      isolate({
        save_as(p$name, p$kinds, quiet = TRUE)
        periodic(utils::modifyList(p, list(due = Sys.time() + 60 * periodic_minutes())))
      })
    })

    # Save this session, then start an empty one. The page reloads, which
    # resets every module; the saved session stays under Load.
    observeEvent(input$btn_new_session, {
      has_work <- !is.null(uploaded_df()) || length(workspace_snapshot(workspace)) > 0
      showModal(modalDialog(
        title = tagList(icon("file-circle-plus"), " Start a fresh session"),
        size = "s", easyClose = TRUE,
        if (has_work) tagList(
          tags$p(class = "small", "The current work is saved under this name, then the app starts empty. Load it again at any time from Load."),
          textInput(ns("new_session_name"), "Save the current session as", value = default_name(), width = "100%"))
        else tags$p(class = "small", "Nothing is loaded yet, so there is nothing to save."),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("btn_new_nosave"), if (has_work) "Discard and start fresh" else "Start fresh",
                       class = if (has_work) "btn-outline-danger" else "btn-primary"),
          if (has_work) actionButton(ns("btn_new_save"), "Save and start fresh", class = "btn-primary", icon = icon("floppy-disk")))
      ))
    })
    start_fresh <- function() {
      removeModal()
      waiter::waiter_show(html = waiter_content("Starting a fresh session..."), color = "rgba(10, 30, 50, 0.65)")
      session$sendCustomMessage("tw-fresh", list())
    }
    observeEvent(input$btn_new_save, {
      if (isTRUE(save_as(input$new_session_name))) start_fresh()
    })
    observeEvent(input$btn_new_nosave, start_fresh())

    observeEvent(input$btn_load_session, {
      sessions <- list_saved_sessions(who)
      if (nrow(sessions) == 0) {
        showNotification("No saved sessions found.", type = "warning")
        return()
      }

      choices <- session_choices(sessions)

      showModal(modalDialog(
        title = "Load Saved Session",
        size = "m",
        easyClose = TRUE,
        footer = modalButton("Close"),
        selectInput(ns("load_session_choice"), "Saved sessions:", choices = choices, width = "100%"),
        actionButton(ns("btn_menu_load"), "Load Session", class = "btn-primary w-100")
      ))
    })

    observeEvent(input$btn_menu_load, {
      need_ok(shiny::isTruthy(input$load_session_choice), "Choose a saved session first.")
      removeModal()
      restore_session(input$load_session_choice)
    })

    observeEvent(input$btn_clear_session, {
      sessions <- list_saved_sessions(who)
      if (nrow(sessions) == 0) {
        showNotification("No saved sessions to clear.", type = "warning")
        return()
      }

      choices <- session_choices(sessions)

      showModal(modalDialog(
        title = "Clear Saved Sessions",
        size = "m",
        easyClose = TRUE,
        footer = modalButton("Cancel"),
        selectInput(ns("delete_session_choice"), "Saved sessions:", choices = choices, width = "100%"),
        bslib::layout_columns(
          actionButton(ns("btn_menu_delete"), "Delete Selected", class = "btn-outline-danger w-100"),
          actionButton(ns("btn_delete_all_sessions"), "Clear All", class = "btn-danger w-100"),
          col_widths = c(6, 6)
        )
      ))
    })

    observeEvent(input$btn_menu_delete, {
      need_ok(shiny::isTruthy(input$delete_session_choice), "Choose a saved session first.")
      removeModal()
      delete_session(input$delete_session_choice, user = who)
      showNotification(paste("Session", input$delete_session_choice, "deleted."), type = "message")
    })

    observeEvent(input$btn_delete_all_sessions, {
      removeModal()
      clear_session(who)
      for (k in kinds) session_names[[k]] <- NULL
      periodic(NULL)
      showNotification("All saved sessions cleared.", type = "message")
    })

    # -------------------------------------------------------------------------
    # 3. Auto-save with debounce
    # -------------------------------------------------------------------------
    auto_save_trigger <- reactive({
      list(
        df = uploaded_df(),
        setup = reactiveValuesToList(user_setup),
        log = modification_log(),
        theme = theme()
      )
    })

    auto_save_trigger_d <- auto_save_trigger %>% shiny::debounce(2000)

    # Autosave only makes sense once the user has actually done something
    # (mapped variables or edited data); re-serialising a freshly imported
    # dataset is pure cost. Large datasets are skipped entirely (see
    # autosave_max_bytes()); the user is told once per session.
    autosave_skip_notified <- reactiveVal(FALSE)
    current_ui <- function() {
      if (is.null(parent_session)) return(NULL)
      list(main_nav = isolate(parent_session$input$main_nav))
    }

    # Each workstream is saved on its own, and only when it changed: a
    # selection edit no longer rewrites the design dataset.
    autosave <- function() {
      work <- workspace_snapshot(workspace)
      for (k in kinds) {
        st <- current_state(k, work)
        if (!workstream_has_work(st, k)) next
        if (identical(workstream_signature(st), sigs[[k]])) next
        if (as.numeric(utils::object.size(st)) > autosave_max_bytes()) {
          if (!autosave_skip_notified()) {
            autosave_skip_notified(TRUE)
            showNotification(
              sprintf("Autosave is off for this much data (%s). Use Save to keep your work.", kind_label(k)),
              type = "warning", duration = 8
            )
          }
          next
        }
        save_kind(k, persist_name(k), st)
      }
    }

    observeEvent(auto_save_trigger_d(), autosave(), ignoreInit = TRUE)

    # A closed connection ends the session when the app runs locally (only
    # Shiny Server and Connect reconnect): the laptop slept, or the browser
    # put the inactive tab to sleep. Save what changed before it goes; the
    # page offers to reload and restore it (www/busy.js).
    session$onSessionEnded(function() try(isolate(autosave()), silent = TRUE))

    # Work in the modules that writes no audit entry (moving the threshold,
    # editing a comment...) is checked every 30 seconds and saved when it changed.
    observe({
      invalidateLater(30000)
      autosave()
    })

    # -------------------------------------------------------------------------
    # 3b. Save reminder
    # -------------------------------------------------------------------------
    # After 20 minutes of work that is not saved under a name, a reminder with
    # Save now / Later. Not shown while autosave keeps a named session up to
    # date. A notification, not a dialog: a dialog would replace whatever
    # dialog the user is working in. TARGETWISE_SAVE_REMINDER_MIN changes the
    # delay (0 turns it off).
    reminder_minutes <- function() {
      m <- suppressWarnings(as.numeric(tw_env("SAVE_REMINDER_MIN", "20")))
      if (is.na(m)) 20 else m
    }
    saved_sig <- reactiveVal(NULL)
    dirty_since <- reactiveVal(NULL)
    reminded_at <- reactiveVal(NULL)
    state_sig <- function() {
      df <- isolate(uploaded_df()); lg <- isolate(modification_log())
      rlang::hash(list(workspace_signature(workspace_snapshot(workspace)),
                       if (!is.null(df)) c(dim(df), names(df)), if (!is.null(lg)) nrow(lg)))
    }
    mark_saved <- function() {
      saved_sig(state_sig()); dirty_since(NULL); reminded_at(NULL)
      removeNotification("save_reminder", session = session)
    }
    observe({
      mins <- reminder_minutes()
      if (!isTRUE(mins > 0)) return()
      invalidateLater(1000 * max(5, min(60, mins * 30)))
      has_work <- !is.null(isolate(uploaded_df())) || length(workspace_snapshot(workspace)) > 0
      covered <- (any_named() && !isolate(autosave_skip_notified())) || !is.null(isolate(periodic()))
      if (!has_work || covered || identical(state_sig(), isolate(saved_sig()))) { dirty_since(NULL); return() }
      if (is.null(isolate(dirty_since()))) dirty_since(Sys.time())
      last <- isolate(reminded_at())
      due <- difftime(Sys.time(), isolate(dirty_since()), units = "mins") >= mins &&
        (is.null(last) || difftime(Sys.time(), last, units = "mins") >= mins)
      if (!due) return()
      reminded_at(Sys.time())
      showNotification(
        id = "save_reminder", duration = NULL, type = "warning", closeButton = TRUE, session = session,
        ui = tagList(
          tags$strong(bsicons::bs_icon("floppy"), " Unsaved work"),
          tags$div(class = "small", sprintf("You have been working for %s minutes without saving this session.",
                                            format(round(as.numeric(difftime(Sys.time(), isolate(dirty_since()), units = "mins")))))),
          tags$div(class = "d-flex gap-2 mt-2",
                   actionButton(ns("remind_save"), "Save now", icon = icon("floppy-disk"), class = "btn-primary btn-sm"),
                   actionButton(ns("remind_later"), "Later", class = "btn-outline-secondary btn-sm"))))
    })
    observeEvent(input$remind_save, {
      removeNotification("save_reminder", session = session)
      show_save_dialog()
    })
    observeEvent(input$remind_later, {
      removeNotification("save_reminder", session = session)
      reminded_at(Sys.time())
    })

    # -------------------------------------------------------------------------
    # 4. Persist audit log immediately when it changes
    # -------------------------------------------------------------------------
    observeEvent(modification_log(), {
      req(modification_log())
      for (k in kinds) {
        lg <- log_for(modification_log(), k)
        if (is.null(isolate(session_names[[k]])) && !any(audit_phase(lg$action) != "Session")) next
        save_audit_log(lg, name = persist_name(k), user = who)
      }
    }, ignoreInit = TRUE)
  })
}
