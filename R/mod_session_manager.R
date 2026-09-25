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

    current_session_name <- reactiveVal("default")

    # Where the background writes (autosave + audit companion) go. Before the
    # user names a session they land in "autosave"; afterwards they follow the
    # named session, so it never goes stale while the user keeps working.
    persist_name <- function() {
      nm <- current_session_name()
      if (identical(nm, "default")) "autosave" else nm
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
      companion_log <- load_audit_log(name, user = who)
      if (is.data.frame(companion_log) &&
          (is.null(restored_log) || nrow(companion_log) > nrow(restored_log))) {
        restored_log <- companion_log
      }
      if (!is.null(restored_log)) modification_log(restored_log)
      if (!is.null(saved$moda_credentials) && is.function(moda_credentials)) {
        moda_credentials(saved$moda_credentials)
      }
      # Targeting Design, selection, spot-check and PDM work
      workspace_restore(workspace, saved$workspace)
      current_session_name(name)

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
      last_sig(workspace_signature(saved$workspace))

      # Say what came back, so the user can trust they are where they left.
      got <- session_contents(saved)
      if (length(got)) {
        showModal(modalDialog(
          title = tagList(bsicons::bs_icon("check2-circle"), sprintf(" Session \"%s\" restored", name)),
          size = "m", easyClose = TRUE, footer = modalButton("Continue"),
          tags$p(class = "small text-muted", sprintf("Saved %s.", format(saved$saved_at %||% Sys.time(), "%Y-%m-%d %H:%M"))),
          tags$ul(class = "small", lapply(got, tags$li))
        ))
      }

      audit_add(modification_log, "Session", "Session loaded", name)
      showNotification(paste("Session", name, "loaded."), type = "message")
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

      choices <- setNames(sessions$name, paste0(sessions$name, " (", format(sessions$saved_at, "%Y-%m-%d %H:%M"), ")"))

      showModal(modalDialog(
        title = "Restore a Saved Session",
        size = "m",
        easyClose = FALSE,
        footer = tagList(
          actionButton(ns("btn_start_fresh"), "Start Fresh", class = "btn-outline-secondary")
        ),
        p("Select a session to resume, or start fresh."),
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
      current_session_name("default")
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
        choices <- setNames(sessions$name, paste0(sessions$name, " (", format(sessions$saved_at, "%Y-%m-%d %H:%M"), ")"))
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

    observeEvent(input$btn_save_session, {
      showModal(modalDialog(
        title = "Save Session",
        size = "s",
        easyClose = TRUE,
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("btn_confirm_save"), "Save", class = "btn-primary", icon = icon("floppy-disk"))
        ),
        textInput(ns("save_session_name"), "Session name:", value = current_session_name(), width = "100%")
      ))
    })

    # Save everything under `name`; FALSE (with a notice) when there is
    # nothing to save or no name.
    save_as <- function(name) {
      if (!shiny::isTruthy(name) || trimws(name) == "") {
        showNotification("Name the session first.", type = "error")
        return(FALSE)
      }
      name <- trimws(name)
      work <- workspace_snapshot(workspace)
      if (is.null(uploaded_df()) && !length(work)) {
        showNotification("Nothing to save: no dataset is loaded and no work has been done.", type = "error")
        return(FALSE)
      }
      waiter::waiter_show(
        html = waiter_content("Encrypting and saving session..."),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)
      save_session(
        uploaded_df = uploaded_df(),
        user_setup = reactiveValuesToList(user_setup),
        modification_log = modification_log(),
        theme = theme(),
        moda_credentials = moda_credentials(),
        name = name,
        user = who,
        workspace = work,
        ui = current_ui(),
        original_df = if (is.function(original_df)) original_df()
      )
      last_sig(workspace_signature(work))
      current_session_name(name)
      audit_add(modification_log, "Session", "Session saved", name)
      showNotification(paste("Session saved as", name), type = "message")
      TRUE
    }

    observeEvent(input$btn_confirm_save, {
      removeModal()
      save_as(input$save_session_name)
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
          textInput(ns("new_session_name"), "Save the current session as", value = if (identical(current_session_name(), "default"))
            format(Sys.time(), "session_%Y-%m-%d_%Hh%M") else current_session_name(), width = "100%"))
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

      choices <- setNames(sessions$name, paste0(sessions$name, " (", format(sessions$saved_at, "%Y-%m-%d %H:%M"), ")"))

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

      choices <- setNames(sessions$name, paste0(sessions$name, " (", format(sessions$saved_at, "%Y-%m-%d %H:%M"), ")"))

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
      current_session_name("default")
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
    last_sig <- reactiveVal(NULL)
    current_ui <- function() {
      if (is.null(parent_session)) return(NULL)
      list(main_nav = isolate(parent_session$input$main_nav))
    }

    autosave <- function(state, work) {
      has_work <- (!is.null(state$log) && nrow(state$log) > 0) || length(work) > 0 ||
        any(vapply(state$setup, function(x) is.character(x) && length(x) == 1 && nzchar(x), logical(1)))
      if (!has_work || (is.null(state$df) && !length(work))) return()

      size <- as.numeric(utils::object.size(state$df)) + as.numeric(utils::object.size(work)) +
        if (is.function(original_df)) as.numeric(utils::object.size(isolate(original_df()))) else 0
      if (size > autosave_max_bytes()) {
        if (!autosave_skip_notified()) {
          autosave_skip_notified(TRUE)
          showNotification(
            "Autosave is off for this much data. Use Session \u203a Save to keep your work.",
            type = "warning", duration = 8
          )
        }
        return()
      }
      save_session(
        uploaded_df = state$df,
        user_setup = state$setup,
        modification_log = state$log,
        theme = state$theme,
        moda_credentials = moda_credentials(),
        name = persist_name(),
        user = who,
        workspace = work,
        ui = current_ui(),
        original_df = if (is.function(original_df)) isolate(original_df())
      )
      last_sig(workspace_signature(work))
    }

    observeEvent(auto_save_trigger_d(), {
      autosave(auto_save_trigger_d(), workspace_snapshot(workspace))
    }, ignoreInit = TRUE)

    # Work in the modules that writes no audit entry (moving the threshold,
    # editing a comment...) is checked every 30 seconds and saved when it changed.
    observe({
      invalidateLater(30000)
      work <- workspace_snapshot(workspace)
      if (!length(work)) return()
      sig <- workspace_signature(work)
      if (identical(sig, isolate(last_sig()))) return()
      autosave(isolate(list(df = uploaded_df(), setup = reactiveValuesToList(user_setup),
                            log = modification_log(), theme = theme())), work)
    })

    # -------------------------------------------------------------------------
    # 4. Persist audit log immediately when it changes
    # -------------------------------------------------------------------------
    observeEvent(modification_log(), {
      req(modification_log())
      save_audit_log(modification_log(), name = persist_name(), user = who)
    }, ignoreInit = TRUE)
  })
}
