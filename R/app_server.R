#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Nothing here ends a session on inactivity. A dropped connection (laptop
  # asleep, a network that closes quiet sockets) is picked up again with the
  # work in memory where the server allows it; www/busy.js also sends a
  # keep-alive every 30 s so an idle page is not taken for a closed one.
  session$allowReconnect(TRUE)

  # The audit trail, shared by every phase.
  modification_log <- reactiveVal(
    data.frame(
      timestamp = character(),
      uid = character(),
      column = character(),
      old_value = character(),
      new_value = character(),
      action = character(),
      user = character(),
      reason = character(),
      stringsAsFactors = FALSE
    )
  )
  # Every DataTable scrolls inside its own frame, header pinned, instead of
  # stretching the page; short tables shrink to their rows.
  options(DT.options = utils::modifyList(getOption("DT.options", list()),
                                         list(scrollY = "440px", scrollCollapse = TRUE, scrollX = TRUE)))
  # New version on GitHub? Checked after the first paint, at most once a day
  # per R process, silently skipped offline or without access.
  later::later(function() {
    st <- tryCatch(update_status(), error = function(e) NULL)
    if (isTRUE(st$available)) {
      tryCatch(showNotification(update_notice(st), duration = NULL, type = "message", session = session),
               error = function(e) NULL)
    }
  }, delay = 2)

  # ---------------------------------------------------------------------------
  # Access gate. We never authenticate anyone ourselves: Posit Connect, Shiny
  # Server Pro and ShinyProxy all hand us the signed-in user, and writing our
  # own login for an app holding household PII would be strictly worse. What we
  # DO enforce is that on a shared deployment nobody gets in anonymously --
  # otherwise every visitor shares one session store and one encryption key.
  # Enable with TARGETWISE_REQUIRE_AUTH=true.
  # ---------------------------------------------------------------------------
  if (require_auth() && is.null(app_user(session))) {
    showModal(modalDialog(
      title = tags$div(bsicons::bs_icon("shield-lock", class = "text-danger me-2"), "Sign-in required"),
      size = "m", easyClose = FALSE, footer = NULL,
      tags$p("This deployment requires an authenticated user, but the hosting ",
             "platform did not provide one."),
      tags$p(class = "text-muted small",
             "Ask your administrator to enable authentication in front of the app ",
             "(Posit Connect, Shiny Server Pro or ShinyProxy), or unset ",
             tags$code("TARGETWISE_REQUIRE_AUTH"), " for local use.")
    ))
    return(invisible(NULL))
  }

  # Auto-match plot colors to the selected theme (re-applies on theme swaps)
  # Fonts come from the bundled stylesheet (offline-safe); thematic only
  # re-themes colours.
  thematic::thematic_shiny()

  # Language. shiny.i18n swaps the tagged strings client-side, so switching
  # costs no re-render. Labels rendered from the server are not tagged yet --
  # see the coverage note in R/utils_i18n.R.
  observeEvent(input$lang_selector, {
    if (requireNamespace("shiny.i18n", quietly = TRUE)) {
      shiny.i18n::update_lang(input$lang_selector, session)
    }
  }, ignoreInit = TRUE)

  # Loading feedback is per output (see the `.recalculating` rules in
  # wfp-ui.css); the full-page waiter is reserved for blocking operations
  # (imports, setup validation, session save/load, data corrections).

  # ---------------------------------------------------------------------------
  # Theming: one WFP palette, in a light and a dark variant.
  #
  # input_dark_mode() flips between them and `wfp_theme()` rebuilds the bslib
  # theme. Semantic colours are lightened in dark mode -- the light-mode
  # success green and danger red do not carry enough contrast on a dark
  # surface to be read at small sizes.
  # ---------------------------------------------------------------------------
  # One theme: the WFP palette, in a light and a dark variant. Bootswatch
  # presets used to be offered alongside it, but each needed its own contrast
  # pass in two modes and none of them is a WFP design.
  wfp_theme <- function(dark = FALSE) {
    bslib::bs_theme(
      version = 5,
      bg = if (dark) "#0e1422" else "#ffffff",
      fg = if (dark) "#e6ebf2" else "#1f2a37",
      primary = "#0A6EB4",
      secondary = "#f7b825",
      success = if (dark) "#5aa661" else "#3f7e44",
      info = if (dark) "#4fd0ef" else "#26bde2",
      warning = "#f7b825",
      danger = if (dark) "#e8536a" else "#c5192d",
      base_font = app_font(),
      code_font = app_font()
      # No Bootswatch preset for dark: "darkly" brought its own paddings, font
      # sizes and input heights, so every switch reshaped the page. Dark is
      # the same theme with dark colours (and the tokens in wfp-ui.css).
    )
  }

  # Default to WFP light. is_dark tracks the toggle (defaults to FALSE before
  # the toggle has fired).
  is_dark <- reactiveVal(FALSE)

  apply_current_theme <- function() {
    session$setCurrentTheme(wfp_theme(is_dark()))
  }

  observeEvent(input$dark_mode, {
    # bslib reports the color mode as the string "light" / "dark". Its initial
    # value follows the OS preference, so we do not ignoreInit here -- but only
    # recompile the theme when the mode actually differs from what is applied.
    # Bootstrap 5.3 colour modes do the switch: the toggle sets
    # data-bs-theme="dark" and wfp-ui.css re-points its colour tokens. The
    # theme is not recompiled -- setCurrentTheme() re-inserted Bootstrap after
    # the app's stylesheet, whose sizes then lost to Bootstrap's defaults and
    # every switch reshaped buttons, inputs and text. Charts redraw with the
    # mode (render_wfp_plotly) and the map swaps its base layer.
    is_dark(identical(input$dark_mode, "dark"))
  })

  ## ===================================================================================
  #  ------------------- Overview and Welcome Panel Server Side
  ## -----------------------------------------------------------------------------------

  #### ----------- Data Importation Module call
  # -----------------------------------------------------------------------------------------

  # 0. Create the "Working Version" box
  uploaded_df <- reactiveVal(NULL)
  original_df <- reactiveVal(NULL)
  setup_trigger <- reactiveVal(0)

  # Helper: show a fancy import summary modal with a button to variable setup
  show_import_summary <- function(df, source = "File") {
    waiter::waiter_show(
      html = waiter_content("Summarising the imported data\u2026"),
      color = "rgba(10, 30, 50, 0.65)"
    )
    on.exit(waiter::waiter_hide(), add = TRUE)
    if (!is.null(session) && exists("flushOutput", session)) {
      try(session$flushOutput(), silent = TRUE)
    }

    # Compute summary statistics
    n_rows <- nrow(df)
    n_cols <- ncol(df)
    mem_size <- format(object.size(df), units = "auto")

    col_classes <- sapply(df, function(x) class(x)[1])
    col_types <- sort(table(col_classes), decreasing = TRUE)
    type_summary <- paste(
      names(col_types),
      paste0("(", col_types, ")"),
      collapse = " | "
    )

    # One pass over the columns with a single running row mask, so memory stays
    # O(rows) instead of materialising an n x p logical matrix (800 MB for a
    # 1M x 200 dataset).
    total_missing <- 0
    row_has_missing <- logical(n_rows)
    for (x in df) {
      m <- if (is.character(x)) is.na(x) | x == "" | x == "NULL" else is.na(x)
      total_missing <- total_missing + sum(m)
      row_has_missing <- row_has_missing | m
    }
    rows_with_missing <- sum(row_has_missing)

    # base duplicated() on a data.frame hashes column by column and scales
    # super-linearly (6.1 s at 200k x 60). data.table's forder does the same
    # job in 0.35 s -- measured 17x, identical counts -- so the old 50k cutoff,
    # which used to leave large imports with "not checked", is gone. The
    # remaining ceiling is memory: at ~1M rows this is still one full pass.
    dup_rows <- count_duplicate_rows(df)

    top_cols <- paste(head(names(df), 10), collapse = ", ")
    if (ncol(df) > 10) {
      top_cols <- paste0(top_cols, ", ...")
    }

    # Build type badges
    type_badges <- lapply(seq_along(col_types), function(i) {
      type_name <- names(col_types)[i]
      type_count <- col_types[i]
      badge_color <- switch(
        type_name,
        "numeric" = "primary",
        "integer" = "primary",
        "character" = "secondary",
        "factor" = "success",
        "Date" = "info",
        "POSIXct" = "info",
        "dark"
      )
      tags$span(
        class = paste0("badge bg-", badge_color, " me-1 mb-1"),
        paste0(type_name, ": ", type_count)
      )
    })

    showModal(modalDialog(
      title = tags$div(
        bsicons::bs_icon("check-circle-fill", class = "text-success me-2"),
        paste(source, "Import Successful")
      ),
      size = "l",
      easyClose = FALSE,
      footer = tagList(
        modalButton("Cancel / Upload Another"),
        actionButton("btn_import_to_setup", "Proceed to Variable Setup", class = "btn-primary", icon = icon("sliders"))
      ),

      # Top KPIs (extra compact)
      bslib::layout_columns(
        fill = FALSE,
        bslib::value_box(
          title = tags$span(class = "small text-uppercase", "Observations"),
          value = tags$span(class = "fs-5", format(n_rows, big.mark = ",")),
          showcase = bsicons::bs_icon("database"),
          showcase_layout = bslib::showcase_top_right(width = "1.5rem"),
          theme = "primary",
          class = "border-0 shadow-sm small"
        ),
        bslib::value_box(
          title = tags$span(class = "small text-uppercase", "Variables"),
          value = tags$span(class = "fs-5", format(n_cols, big.mark = ",")),
          showcase = bsicons::bs_icon("columns-gap"),
          showcase_layout = bslib::showcase_top_right(width = "1.5rem"),
          theme = "secondary",
          class = "border-0 shadow-sm small"
        ),
        bslib::value_box(
          title = tags$span(class = "small text-uppercase", "Memory"),
          value = tags$span(class = "fs-5", mem_size),
          showcase = bsicons::bs_icon("cpu"),
          showcase_layout = bslib::showcase_top_right(width = "1.5rem"),
          theme = "info",
          class = "border-0 shadow-sm small"
        ),
        bslib::value_box(
          title = tags$span(class = "small text-uppercase", "Missing"),
          value = tags$span(class = "fs-5", format(total_missing, big.mark = ",")),
          showcase = bsicons::bs_icon("exclamation-triangle"),
          showcase_layout = bslib::showcase_top_right(width = "1.5rem"),
          theme = "warning",
          class = "border-0 shadow-sm small"
        ),
        col_widths = c(3, 3, 3, 3)
      ),

      tags$hr(class = "my-2"),

      # Additional details (extra compact cards)
      bslib::layout_columns(
        fill = FALSE,
        bslib::card(
          full_screen = FALSE,
          class = "border-0 shadow-sm small",
          bslib::card_header(class = "py-1 small fw-bold", "Column Types"),
          bslib::card_body(
            padding = 1,
            gap = 1,
            tags$div(class = "d-flex flex-wrap", type_badges)
          )
        ),
        bslib::card(
          full_screen = FALSE,
          class = "border-0 shadow-sm small",
          bslib::card_header(class = "py-1 small fw-bold", "Data Quality Snapshot"),
          bslib::card_body(
            padding = 1,
            gap = 1,
            tags$ul(
              class = "list-group list-group-flush",
              tags$li(class = "list-group-item py-0", tags$strong("Rows with missing: "), format(rows_with_missing, big.mark = ",")),
              tags$li(
                class = "list-group-item py-0", tags$strong("Duplicate rows: "),
                if (is.na(dup_rows)) tags$span(class = "text-muted", "not checked for large files \u2014 see Data Quality \u203a Duplicates")
                else format(dup_rows, big.mark = ",")
              ),
              tags$li(class = "list-group-item py-0", tags$strong("Missing cells: "), format(total_missing, big.mark = ","))
            )
          )
        ),
        col_widths = c(6, 6)
      ),

      bslib::card(
        class = "mt-2 border-0 shadow-sm small",
        full_screen = FALSE,
        bslib::card_header(class = "py-1 small fw-bold", "First Variables"),
        bslib::card_body(
          padding = 1,
          gap = 0,
          tags$p(class = "text-muted small mb-1", "First 10 variables:"),
          tags$code(top_cols, style = "font-size: 0.8rem; word-break: break-word;")
        )
      )
    ))
  }

  # 1. Start the module and capture the returned reactive dataframe
  # Note: Use the same ID as in the UI ("file_import_1")
  raw_import <- mod_file_import_server("file_import_1", display = FALSE)
  moda_import_result <- mod_moda_import_server("moda_import_1")
  moda_import <- moda_import_result$data
  moda_import_credentials <- moda_import_result$credentials

  # Store MODA credentials so sessions can be re-synced
  current_moda_credentials <- reactiveVal(NULL)

  # Pending import state used when data is already in memory
  pending_df <- reactiveVal(NULL)
  pending_source <- reactiveVal(NULL)

  process_import <- function(df, source) {
    uploaded_df(df)
    original_df(df)
    src <- if (identical(source, "File")) "file upload" else
      sprintf("MODA form %s", current_moda_credentials()$form_id %||% "")
    # What the list will be traced back to; shown in the selection export.
    user_setup$data_source <- sprintf("%s, %s rows, %s columns, imported %s", src,
                                      format(nrow(df), big.mark = ","), ncol(df), format(Sys.time(), "%Y-%m-%d %H:%M"))
    audit_add(modification_log, "Selection", "Registration data imported", user_setup$data_source)
    show_import_summary(df, source = source)
  }

  show_override_modal <- function(source) {
    showModal(modalDialog(
      title = tags$div(
        bsicons::bs_icon("exclamation-triangle-fill", class = "text-warning me-2"),
        "Data already in memory"
      ),
      tags$p(
        "You already have a dataset loaded in memory. Importing a new",
        tags$strong(source),
        "will override the current data."
      ),
      tags$p("Click Continue to proceed or Cancel to keep the existing dataset."),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("btn_confirm_override", "Continue", class = "btn-warning")
      ),
      easyClose = TRUE
    ))
  }

  observeEvent(input$btn_confirm_override, {
    req(pending_df())
    process_import(pending_df(), pending_source())
    pending_df(NULL)
    pending_source(NULL)
  })

  # 3. Every time a new file is imported, copy it into the working version
  observeEvent(raw_import(), {
    req(raw_import())
    current_moda_credentials(NULL)
    if (!is.null(uploaded_df())) {
      pending_df(raw_import())
      pending_source("File")
      show_override_modal("File")
    } else {
      process_import(raw_import(), "File")
    }
  })

  # 4. MODA import also feeds the working version
  observeEvent(moda_import(), {
    req(moda_import())
    if (!is.null(moda_import_credentials())) {
      current_moda_credentials(moda_import_credentials())
    }
    if (!is.null(uploaded_df())) {
      pending_df(moda_import())
      pending_source("MODA")
      show_override_modal("MODA")
    } else {
      process_import(moda_import(), "MODA")
    }
  })

  # 2. Example: Create a reactive output using the uploaded data
  output$row_count <- renderText({
    # Use req() to wait for data, then call with ()
    req(uploaded_df())
    nrow(uploaded_df())
  })

  #### ----------- Variable Setup Module call
  # -----------------------------------------------------------------------------------------

  # 3. Start Setup Module and PASS the data to it
  setup_result <- mod_setup_server(
    "setup_1",
    r_data = uploaded_df,
    parent_session = session,
    trigger_open = setup_trigger
  )

  # Open variable setup from import summary modal
  observeEvent(input$btn_import_to_setup, {
    removeModal()
    setup_trigger(isolate(setup_trigger()) + 1)
  })
  user_setup <- setup_result$settings

  # -----------------------------------------------------------------------------------------
  # ------------------ Hide Tabs on open
  # -----------------------------------------------------------------------------------------

  # 1. Hide tabs when the app starts
  # Only the panels that read the household registration data wait for the
  # variable mapping. Targeting Design runs on assessment data and Targeting
  # Monitoring on PDM data, both loaded inside their own tabs, so gating them
  # on a registration import nobody has done yet would be wrong -- a country
  # office designing a scorecard has no registration list yet.
  observe({
    bslib::nav_hide("main_nav", target = "overview_panel")
    bslib::nav_hide("main_nav", target = "dq_panel")
    bslib::nav_hide("main_nav", target = "spot_panel")
    bslib::nav_hide("main_nav", target = "ben_panel")
  })

  # Landing-page shortcuts into each phase.
  observeEvent(input$go_design, bslib::nav_select("main_nav", "scorecard_panel"))
  observeEvent(input$go_import, bslib::nav_select("main_nav", "import_panel"))
  observeEvent(input$go_monitor, bslib::nav_select("main_nav", "pdm_panel"))

  # 2. Watch for the 'Validation' signal from your setup module
  observeEvent(setup_result$validated(), {
    req(setup_result$validated() == TRUE)

    # REVEAL the panels
    bslib::nav_show("main_nav", target = "overview_panel")
    bslib::nav_show("main_nav", target = "dq_panel")
    bslib::nav_show("main_nav", target = "spot_panel")
    bslib::nav_show("main_nav", target = "ben_panel")

    # The mapping and any forced numeric columns go on the record, and the
    # Reset baseline gets the same coercion so a reset does not undo it.
    keys <- c("unique_id", "date", "admin1", "admin2", "admin3", "admin4", "village", "hh_size",
              "hhh_sex", "hhh_age", "v_score", "v_groups", "eligibility", "weight")
    mapped <- vapply(keys, function(k) as.character(user_setup[[k]] %||% "")[1], character(1))
    audit_add(modification_log, "Selection", "Variables mapped",
              paste(sprintf("%s = %s", keys[nzchar(mapped)], mapped[nzchar(mapped)]), collapse = "; "))
    fc <- user_setup$force_numeric
    if (length(fc)) {
      bl <- user_setup$coercion_blanked %||% integer(0)
      audit_add(modification_log, "Selection", "Columns forced to numeric",
                paste(sprintf("%s (%s values not numeric, set blank)", fc, bl[fc] %||% 0), collapse = "; "))
      o <- original_df()
      if (!is.null(o)) {
        for (cl in intersect(fc, names(o))) o[[cl]] <- suppressWarnings(as.numeric(as.character(o[[cl]])))
        original_df(o)
      }
    }

    # JUMP to the Overview automatically
    bslib::nav_select("main_nav", selected = "overview_panel")

    showNotification("Variables mapped. The analysis tabs are now open.", type = "message")
  })


  # ---------------------------------------------------------------------------
  # Country office: remembered per install, carried by sessions (user_setup),
  # printed on the reports and exports.
  # ---------------------------------------------------------------------------
  co_user <- app_user(session)
  isolate({
    co <- app_setting_get("country_office", co_user)
    if (shiny::isTruthy(co)) user_setup$country_office <- co
  })
  output$co_badge <- renderUI({
    co <- user_setup$country_office
    actionButton("co_open", if (shiny::isTruthy(co)) co else "Set country office",
                 icon = icon("location-dot"), class = "btn-sm wfp-co-btn",
                 title = "Country office: shown on every report and export")
  })
  observeEvent(input$co_open, {
    showModal(modalDialog(
      title = "Country office", size = "s", easyClose = TRUE,
      selectizeInput("co_value", NULL, choices = c("", wfp_country_offices()),
                     selected = user_setup$country_office %||% "", width = "100%",
                     options = list(create = TRUE, placeholder = "Pick or type a country office")),
      tags$p(class = "small text-muted mb-0",
             "Written on the design report, the scorecard, the selection and the PDM exports."),
      footer = tagList(modalButton("Cancel"), actionButton("co_save", "Save", class = "btn-primary"))
    ))
  })
  observeEvent(input$co_save, {
    v <- trimws(input$co_value %||% "")
    if (!identical(v, user_setup$country_office %||% "")) {
      audit_add(modification_log, "Session", "Country office set", if (nzchar(v)) v else "(none)")
    }
    user_setup$country_office <- if (nzchar(v)) v else NULL
    app_setting_set("country_office", if (nzchar(v)) v else NULL, co_user)
    removeModal()
  })

  #### ----------- Welcome Panel Filters Admin1, 2 and 3
  mod_overview_server("overview_1", uploaded_df, user_setup)
  # Each module registers its work here so a saved session carries it.
  workspace <- workspace_new()
  mod_spot_checking_server("spot_checking_1", uploaded_df, user_setup, workspace)
  mod_ben_selection_server("ben_selection_1", uploaded_df, user_setup, workspace, modification_log)
  # The scorecard is built on the assessment data currently loaded, and stores
  # the finished card on user_setup so it travels in the setup profile and can
  # be applied by Beneficiary Selection.
  mod_scorecard_server("scorecard_1", uploaded_df, user_setup, workspace, modification_log)
  # PDM accuracy works off its own uploaded extract, so it takes no app state.
  # Targeting Monitoring: the PDM analysis, targeting process and the report.
  mod_monitoring_server("monitoring_1", workspace, country_office = reactive(user_setup$country_office),
                        modification_log = modification_log, user_setup = user_setup)

  ## ===================================================================================
  #  ------------------- Data Quality Panel Server Side
  ## -----------------------------------------------------------------------------------

  # Initialize the modification log as a reactiveVal in the global app state

  mod_dq_server("dq_1", uploaded_df, user_setup, modification_log, original_df, workspace = workspace)

  ## ===================================================================================
  #  ------------------- Audit Trail Server Side
  ## -----------------------------------------------------------------------------------
  mod_audit_server("audit_1", modification_log)

  # Variable calculator on the registration data; every column it creates is
  # recorded in the audit trail.
  mod_var_calc_server("calc_reg", uploaded_df, function(df) uploaded_df(df), modification_log)

  ## ===================================================================================
  #  ------------------- Session Persistence
  ## -----------------------------------------------------------------------------------
  sync_trigger <- reactiveVal(0)

  mod_session_manager_server(
    "session_manager_1",
    uploaded_df = uploaded_df,
    user_setup = user_setup,
    modification_log = modification_log,
    theme = reactive("wfp"),
    parent_session = session,
    moda_credentials = current_moda_credentials,
    sync_trigger = sync_trigger,
    original_df = original_df,
    workspace = workspace
  )

  # ---------------------------------------------------------------------------
  # Re-sync MODA data when the user clicks the Sync MODA session button
  # ---------------------------------------------------------------------------
  observeEvent(sync_trigger(), {
    req(current_moda_credentials())
    cred <- current_moda_credentials()
    req(cred$form_id, cred$token)

    moda_async_fetch(
      form_id = cred$form_id,
      token = cred$token,
      existing_df = uploaded_df(),
      # Must stay at MODA_PAGE_SIZE: at 10 this was 100x the round trips, and
      # the `nrow(page) < page_size` stop condition truncated the sync on any
      # page returning fewer than 10 records.
      page_size = MODA_PAGE_SIZE,
      session = session,
      on_success = function(result) {
        # Only new records are added. Records deleted during data cleaning
        # stay deleted, and the Reset baseline keeps the original import plus
        # the new records, not the cleaned data.
        prev <- isolate(uploaded_df())
        key <- if ("_id" %in% names(result$df) && "_id" %in% names(prev)) "_id" else user_setup$unique_id
        is_new <- if (shiny::isTruthy(key) && key %in% names(prev)) !(as.character(result$df[[key]]) %in% as.character(prev[[key]])) else rep(FALSE, nrow(result$df))
        uid <- user_setup$unique_id
        gone <- deleted_uids(isolate(modification_log()))
        drop <- is_new & shiny::isTruthy(uid) & uid %in% names(result$df) & as.character(result$df[[uid]] %||% "") %in% gone
        new_df <- result$df[!drop, , drop = FALSE]
        uploaded_df(new_df)
        added <- new_df[is_new[!drop], , drop = FALSE]
        o <- isolate(original_df())
        if (nrow(added)) original_df(tryCatch(dplyr::bind_rows(o, added), error = function(e) o))
        audit_add(modification_log, "Selection", "MODA sync",
                  sprintf("form %s: %s new records added%s", cred$form_id, format(nrow(added), big.mark = ","),
                          if (any(drop)) sprintf(", %d previously deleted records kept out", sum(drop)) else ""))
        result$added <- nrow(added)
        showModal(modalDialog(
          title = tags$div(icon("cloud-arrow-down"), " MODA Sync Complete"),
          size = "m",
          easyClose = TRUE,
          footer = modalButton("Close"),
          tags$p(
            prettyNum(result$added, big.mark = ",", scientific = FALSE),
            " new records were added."
          ),
          tags$p(
            "Total records in session: ",
            tags$strong(prettyNum(result$total, big.mark = ",", scientific = FALSE))
          ),
          tags$p(class = "text-muted small", "Your variable mapping has been kept.")
        ), session = session)
      },
      on_error = function(msg) {
        showNotification(paste("MODA sync failed:", msg), type = "error", duration = NULL, session = session)
      }
    )
  }, ignoreInit = TRUE)
}
