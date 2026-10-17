#' setup UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#' @importFrom shiny NS tagList
mod_setup_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # A placeholder that only shows the button when data is ready
    uiOutput(ns("setup_ui_container"))
  )
}

#' setup Server Functions
#'
#' The variable mapping works for any country's data: only the household
#' identifier and the top area level are required, columns are guessed from
#' their names, labels and content (`guess_mapping()`), and a review step
#' standardises values, reads the date, checks the content and says what the
#' data allow (`R/utils_mapping.R`).
#' @noRd
mod_setup_server <- function(id, r_data, parent_session, trigger_open = reactiveVal(0)) {
  # Takes reactive data as input
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    who <- app_user(session)

    # Bumped whenever the stored profile list changes, so the picker in the
    # modal re-renders without rebuilding the whole modal.
    profiles_changed <- reactiveVal(0)

    # 1. The mapping (field -> column in use), plus what the review decided
    settings <- do.call(reactiveValues, c(
      stats::setNames(rep(list(NULL), length(setup_keys())), setup_keys()),
      list(force_numeric = NULL, source_map = NULL, setup_plan = NULL, recode_maps = NULL,
           checks = NULL, readiness = NULL)))

    # 2. Render the button only when data is loaded
    output$setup_ui_container <- renderUI({
      req(r_data())
      actionButton(
        ns("open_modal"),
        "Variable Definition & Setup",
        class = "btn-primary btn-lg mt-3",
        icon = icon("sliders")
      )
    })

    ###### ------------------  The mapping form

    is_ready <- reactiveVal(FALSE)
    saved_n <- reactiveVal(0)          # bumped on every confirmed setup
    pending <- reactiveVal(NULL)       # the mapping between Save and Confirm
    pending_df <- NULL                 # its data (columns shared with r_data until changed)
    review_state <- reactiveVal(NULL)

    # The country office's newest profile, offered when nothing is mapped yet
    country_profile <- function(cols) {
      co <- settings$country_office %||% ""
      if (!nzchar(co)) return(NULL)
      saved <- list_profiles(who)
      for (nm in saved$name) {
        p <- load_profile(nm, who)
        if (!is.null(p) && identical(p$country %||% "", co)) {
          m <- match_profile(p, cols)
          if (m$applied_n >= 3) return(list(profile = p, match = m))
        }
      }
      NULL
    }

    show_setup_modal <- function(prefill = NULL) {
      df <- r_data(); req(df)
      cols <- names(df)
      labs <- label_registry(session)$labels
      g <- guess_mapping(df, labs)
      pick <- stats::setNames(g$column, g$key)
      conf <- stats::setNames(g$confidence, g$key)
      why <- stats::setNames(g$why, g$key)
      note <- NULL
      in_use <- isTruthy(settings$unique_id)
      if (is.null(prefill) && !in_use) {
        cp <- country_profile(cols)
        if (!is.null(cp)) {
          for (k in names(cp$match$mapping)) { pick[[k]] <- cp$match$mapping[[k]]; conf[[k]] <- "profile"; why[[k]] <- "from the country profile" }
          settings$recode_maps <- cp$profile$recodes
          note <- sprintf("Applied the %s profile '%s': %d of %d fields found.%s", settings$country_office, cp$profile$name,
                          cp$match$applied_n, cp$match$applied_n + cp$match$missing_n,
                          if (cp$match$missing_n) paste0(" Not in these data: ", paste(names(cp$match$missing), collapse = ", "), ".") else "")
        }
      }
      # A mapping already made (or restored with a session) wins over the guesses,
      # and a mapping sent back from the review wins over both.
      if (in_use) for (k in setup_keys()) {
        v <- settings$source_map[[k]] %||% settings[[k]]
        if (isTruthy(v) && v %in% cols) { pick[[k]] <- v; conf[[k]] <- "in use"; why[[k]] <- "the mapping in use" }
        else if (!is.null(settings$source_map)) { pick[[k]] <- ""; conf[[k]] <- "" }
      }
      if (!is.null(prefill)) for (k in names(prefill)) { pick[[k]] <- prefill[[k]] %||% ""; conf[[k]] <- if (nzchar(pick[[k]])) "in use" else "" }

      badge <- function(k) {
        cf <- conf[[k]]; if (!nzchar(cf) || !nzchar(pick[[k]])) return(NULL)
        txt <- switch(cf, high = "sure", medium = "likely", low = "check", profile = "profile", "in use" = "in use", cf)
        tags$span(class = paste0("tw-conf tw-conf-", gsub(" ", "-", cf)), title = paste("Suggested:", why[[k]]), txt)
      }
      field_input <- function(f) {
        k <- f$key
        empty <- if (isTRUE(f$required)) c("Choose a column..." = "") else c("Not in my data" = "")
        selectInput(ns(k), tagList(f$label, if (isTRUE(f$required)) tags$span(class = "text-danger", " *"), badge(k)),
                    choices = c(empty, cols), selected = pick[[k]], width = "100%")
      }
      panels <- lapply(seq_along(SETUP_GROUPS), function(gi) {
        fs <- Filter(function(f) f$group == gi, SETUP_FIELDS)
        bslib::accordion_panel(
          title = SETUP_GROUPS[gi], value = paste0("g", gi),
          icon = icon(c("fingerprint", "map-location-dot", "users", "shield-heart")[gi]),
          do.call(bslib::layout_columns, c(list(col_widths = 4, fill = FALSE), lapply(fs, field_input))))
      })

      showModal(modalDialog(
        title = "Select the appropriate variables",
        size = "xl",
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("save"), "Review and save", class = "btn-primary", icon = icon("arrow-right"))
        ),
        # A mapping is the same work every round and every country office, so
        # it is savable, shareable and re-appliable rather than re-guessed.
        uiOutput(ns("profile_bar")),
        if (!is.null(note)) tags$div(class = "alert alert-info py-2 small", bsicons::bs_icon("globe"), " ", note),
        tags$p(class = "small text-muted",
               "Only the household identifier and area level 1 are required (", tags$span(class = "text-danger", "*"), "). ",
               "Leave a field on ", tags$em("Not in my data"), " when your data do not have it: the parts of the app that need it are switched off, and the next step shows which. ",
               "Suggestions come from the column names, labels and content; the badge says how sure they are (hover for why). ",
               "A folded group says how many of its fields are mapped."),
        do.call(bslib::accordion, c(list(id = ns("setup_accordion"), open = "g1", multiple = FALSE), panels))
      ))
    }

    observeEvent(input$open_modal, {
      req(input$open_modal > 0)   # React buttons send an initial 0
      show_setup_modal()
    })

    observeEvent(trigger_open(), {
      req(trigger_open() > 0)
      show_setup_modal()
    })

    #### ---------- Setup profiles (save / apply / share a mapping)

    # The 22 setup inputs are named exactly like the profile keys, so the live
    # mapping is just a read of the inputs. Reading inputs rather than
    # `settings` lets the user save a profile before committing the setup.
    current_map <- function() {
      out <- lapply(PROFILE_KEYS, function(k) input[[k]])
      names(out) <- PROFILE_KEYS
      out
    }

    # What a profile saves: the live mapping plus the value standardisation,
    # the country office and the targeting design from the settings.
    profile_settings <- function() c(current_map(), list(
      force_numeric = settings$force_numeric, recodes = settings$recode_maps, country = settings$country_office,
      rules = settings$rules, scorecard = settings$scorecard))

    output$profile_bar <- renderUI({
      profiles_changed()
      saved <- list_profiles(who)
      choices <- if (nrow(saved) == 0) {
        c("No saved profiles yet" = "")
      } else {
        stats::setNames(saved$name, paste0(saved$name, "  (", fmt_datetime(saved$saved_at), ")"))
      }

      bslib::card(
        class = "mb-3 border-0 bg-body-tertiary",
        bslib::card_body(
          class = "py-2",
          bslib::layout_columns(
            col_widths = c(6, 6), fill = FALSE,
            selectInput(ns("profile_choice"), "Saved setup profile", choices = choices,
                        width = "100%", selectize = FALSE),
            textInput(ns("profile_name"), "Save current mapping as",
                      placeholder = "e.g. DRC CFM round 3", width = "100%")
          ),
          tags$div(
            class = "d-flex flex-wrap gap-2 align-items-center",
            actionButton(ns("profile_apply"), "Apply", icon = icon("wand-magic-sparkles"),
                         class = "btn-outline-primary btn-sm"),
            actionButton(ns("profile_save"), "Save", icon = icon("floppy-disk"),
                         class = "btn-outline-secondary btn-sm"),
            downloadButton(ns("profile_download"), "Export", icon = icon("download"),
                           class = "btn-outline-secondary btn-sm"),
            tags$div(
              class = "wfp-inline-file",
              fileInput(ns("profile_upload"), label = NULL, accept = ".json",
                        buttonLabel = "Import", placeholder = "profile.json", width = "230px")
            ),
            actionButton(ns("profile_delete"), label = NULL, icon = icon("trash"),
                         title = "Delete the selected profile",
                         class = "btn-outline-danger btn-sm")
          )
        )
      )
    })

    # Applying a profile is explicit about what it could not place: a form that
    # gained or renamed a question must not leave a field silently unmapped.
    apply_profile <- function(profile) {
      df <- r_data()
      req(df)
      m <- match_profile(profile, names(df))

      for (k in names(m$mapping)) {
        updateSelectInput(session, k, selected = m$mapping[[k]])
      }
      if (!is.null(profile$force_numeric) && length(profile$force_numeric)) {
        settings$force_numeric <- profile$force_numeric
      }
      # A profile carries the targeting design too, not just the mapping.
      if (!is.null(profile$rules)) settings$rules <- profile$rules
      if (!is.null(profile$scorecard)) settings$scorecard <- profile$scorecard
      if (!is.null(profile$recodes)) settings$recode_maps <- profile$recodes

      if (m$missing_n > 0) {
        detail <- paste0(names(m$missing), " -> ", unname(m$missing), collapse = "; ")
        showNotification(
          paste0("Applied ", m$applied_n, " of ", m$applied_n + m$missing_n,
                 " fields. Not found in this dataset: ", detail),
          type = "warning", duration = 15
        )
      } else {
        showNotification(paste0("Profile applied: ", m$applied_n, " fields mapped."),
                         type = "message")
      }
    }

    observeEvent(input$profile_apply, {
      need_ok(shiny::isTruthy(input$profile_choice), "Choose a saved profile first.")
      prof <- load_profile(input$profile_choice, who)
      if (is.null(prof)) {
        showNotification("Could not read that profile.", type = "error")
        return()
      }
      apply_profile(prof)
    })

    # Name to save under: the box if the user typed one, else overwrite the
    # profile they have selected.
    profile_save_name <- function() {
      nm <- trimws(input$profile_name %||% "")
      if (nzchar(nm)) return(nm)
      if (shiny::isTruthy(input$profile_choice)) return(input$profile_choice)
      ""
    }

    observeEvent(input$profile_save, {
      nm <- profile_save_name()
      if (!nzchar(nm)) {
        showNotification("Type a name for this profile first.", type = "error")
        return()
      }
      save_profile(profile_from_settings(profile_settings(), name = nm), who)
      profiles_changed(profiles_changed() + 1)
      showNotification(paste0("Profile '", nm, "' saved."), type = "message")
    })

    observeEvent(input$profile_delete, {
      need_ok(shiny::isTruthy(input$profile_choice), "Choose a saved profile first.")
      nm <- input$profile_choice
      delete_profile(nm, who)
      profiles_changed(profiles_changed() + 1)
      showNotification(paste0("Profile '", nm, "' deleted."), type = "message")
    })

    output$profile_download <- download_handler(
      filename = function() {
        nm <- profile_save_name()
        if (!nzchar(nm)) nm <- "setup-profile"
        paste0(sanitize_session_name(nm), ".json")
      },
      content = function(file) {
        nm <- profile_save_name()
        if (!nzchar(nm)) nm <- "setup-profile"
        writeLines(as.character(profile_to_json(profile_from_settings(profile_settings(), name = nm))),
                   file, useBytes = TRUE)
      }
    )

    observeEvent(input$profile_upload, {
      req(input$profile_upload)
      prof <- tryCatch(
        profile_from_json(paste(readLines(input$profile_upload$datapath, warn = FALSE), collapse = "\n")),
        error = function(e) {
          showNotification(paste("Could not read profile:", conditionMessage(e)),
                           type = "error", duration = 10)
          NULL
        }
      )
      req(prof)
      # Keep an imported profile around so it can be re-applied next round.
      save_profile(prof, who)
      profiles_changed(profiles_changed() + 1)
      apply_profile(prof)
    })

    #### ---------- Checks, review and save

    read_map <- function() stats::setNames(lapply(setup_keys(), function(k) input[[k]] %||% ""), setup_keys())

    # Save: blocking problems stop here (the mapping stays open); numeric
    # fields stored as text are offered for coercion; then the review.
    do_save <- function(force_cols = character()) {
      waiter::waiter_show(html = waiter_content("Checking the variable mapping\u2026"), color = "rgba(10, 30, 50, 0.65)")
      on.exit(waiter::waiter_hide(), add = TRUE)
      df <- r_data()
      map_list <- read_map()
      sel <- unlist(map_list); sel <- sel[nzchar(sel)]
      if (anyDuplicated(sel)) {
        d <- sel[sel %in% sel[duplicated(sel)]]
        showNotification(sprintf("Column '%s' is mapped to several fields (%s): one column per field.", d[1],
                                 paste(vapply(names(d), field_label, ""), collapse = ", ")), type = "error", duration = 10)
        return()
      }

      # Numeric fields stored as text (a date of birth in the age field is not)
      df_local <- df
      blanked <- integer(0)
      for (cl in force_cols) if (isTruthy(cl) && cl %in% names(df_local)) {
        before <- df_local[[cl]]
        df_local[[cl]] <- as_number(before)
        blanked[[cl]] <- sum(!is.na(before) & nzchar(trimws(as.character(before))) & is.na(df_local[[cl]]))
      }
      numeric_fields <- c("hhh_age", "hh_size", "childU5", "v_score", "lat", "lon", "weight")
      invalid <- character(0)
      for (k in numeric_fields) {
        cl <- map_list[[k]]
        if (!nzchar(cl) || !cl %in% names(df_local) || is.numeric(df_local[[cl]])) next
        if (k == "hhh_age" && parse_dates(df_local[[cl]], 500)$rate > 0.8) next
        invalid[[k]] <- cl
      }
      if (length(invalid)) {
        showModal(modalDialog(
          title = "Non-numeric variables detected",
          "The following variables must be numeric but are currently text. Check the ones you want to force to numeric and click Force.",
          checkboxGroupInput(ns("force_numeric_cols"), "Variables to force to numeric",
                             choices = stats::setNames(unname(invalid), paste0(vapply(names(invalid), field_label, ""), " (", invalid, ")")),
                             selected = unname(invalid)),
          footer = tagList(modalButton("Cancel"),
                           actionButton(ns("force_numeric_save"), "Force numeric", class = "btn-warning"))
        ))
        return()
      }

      chk <- tw_step(sprintf("check the content of %s households", format(nrow(df_local), big.mark = ",")), mapping_checks(df_local, map_list))
      blocks <- chk[chk$level == "block", , drop = FALSE]
      if (nrow(blocks)) {
        showNotification(tagList(tags$strong("Cannot continue:"), tags$ul(lapply(blocks$message, tags$li))),
                         type = "error", duration = 20)
        return()
      }
      pending_df <<- df_local
      pending(list(map = map_list, force = force_cols, blanked = blanked, checks = chk))
      show_review(df_local, map_list, chk)
    }

    observeEvent(input$save, do_save(character()))
    observeEvent(input$force_numeric_save, {
      do_save(input$force_numeric_cols %||% character())
    })

    # The review: values to standardise, the date, the checks, what the data allow
    show_review <- function(df, map, chk) {
      prior <- settings$recode_maps %||% list()
      rc <- list()
      for (f in Filter(function(f) !is.null(f$std), SETUP_FIELDS)) {
        cl <- map[[f$key]]; if (!nzchar(cl)) next
        s <- recode_suggest(df[[cl]], f$std)
        if (is.null(s)) next
        pr <- prior[[f$key]]
        if (length(pr)) { hit <- s$value %in% names(pr); s$standard[hit] <- unlist(pr[s$value[hit]]); s$assumed[hit] <- FALSE }
        if (isTRUE(attr(s, "needed")) || length(pr)) rc[[f$key]] <- s
      }
      dc <- map$date
      dinfo <- if (nzchar(dc)) { p <- parse_dates(df[[dc]]); if (!inherits(df[[dc]], c("Date", "POSIXt")) && p$rate > 0) p }
      dob <- map$hhh_age
      dob <- if (nzchar(dob) && !is.numeric(df[[dob]]) && parse_dates(df[[dob]], 500)$rate > 0.8) dob else NULL
      review_state(list(rc = rc, dob = dob, date = if (!is.null(dinfo)) dc))
      rd <- data_readiness(map)
      warns <- chk[chk$level == "warn", , drop = FALSE]

      rc_table <- function(k) {
        s <- rc[[k]]; f <- setup_field(k)
        tags$div(class = "mb-3",
          tags$div(class = "fw-semibold mb-1", f$label, tags$span(class = "text-muted small", sprintf(" (column %s)", map[[k]]))),
          if (any(s$assumed)) tags$div(class = "small text-warning mb-1", bsicons::bs_icon("exclamation-triangle"),
                                       " Numeric codes without labels: 1 = Male, 2 = Female assumed (DHS / MICS convention). Check against the questionnaire."),
          tags$table(class = "table table-sm tw-recode-table mb-0",
            tags$thead(tags$tr(tags$th("Value in the data"), tags$th(class = "text-end", "Households"), tags$th("Standard value"))),
            tags$tbody(lapply(seq_len(nrow(s)), function(i) tags$tr(
              tags$td(s$value[i]), tags$td(class = "text-end", format(s$n[i], big.mark = ",")),
              tags$td(selectInput(ns(sprintf("rc_%s_%d", k, i)), NULL, choices = c(std_levels(f$std), STD_KEEP, STD_MISSING),
                                  selected = s$standard[i], width = "100%")))))))
      }
      status_icon <- c(Available = "check-circle-fill", Partial = "dash-circle-fill", `Not available` = "x-circle-fill")
      status_cls <- c(Available = "text-success", Partial = "text-warning", `Not available` = "text-danger")

      showModal(modalDialog(
        title = tagList(bsicons::bs_icon("clipboard-check"), " Review before opening the analysis"),
        size = "xl",
        footer = tagList(actionButton(ns("review_back"), "Back to the mapping", icon = icon("arrow-left"), class = "btn-outline-secondary"),
                         actionButton(ns("review_confirm"), "Confirm and open the analysis", icon = icon("check"), class = "btn-primary")),
        bslib::layout_columns(
          col_widths = c(6, 6), fill = FALSE,
          tags$div(
            tags$h6(class = "tw-review-h", bsicons::bs_icon("translate"), " Values to standardise"),
            if (!length(rc)) tags$p(class = "small text-muted", "Nothing to standardise: the values already use the standard answers, or the fields are not mapped.")
            else tagList(tags$p(class = "small text-muted",
                                "Answers are written differently from one country to another (Homme / Female / 1...). Standard values make reports and exports comparable. ",
                                "The original columns are kept; the standardised ones are added with the suffix _std."),
                         lapply(names(rc), rc_table)),
            tags$h6(class = "tw-review-h mt-3", bsicons::bs_icon("calendar3"), " Dates and ages"),
            tags$ul(class = "small",
              if (!is.null(dinfo)) tags$li(sprintf("Collection date read as %s (%.0f%% of the values).", dinfo$format, 100 * dinfo$rate),
                                           if (isTRUE(dinfo$ambiguous)) tags$span(class = "text-warning", " Day and month could not be told apart: check a few dates."))
              else if (nzchar(dc)) tags$li("Collection date: already stored as dates.")
              else tags$li(class = "text-muted", "No collection date mapped."),
              if (!is.null(dob)) tags$li(sprintf("'%s' holds dates of birth: the head's age is computed at the collection date (new column %s_age).", dob, dob)))
          ),
          tags$div(
            tags$h6(class = "tw-review-h", bsicons::bs_icon("search"), " Checks on the content"),
            if (!nrow(warns)) tags$p(class = "small text-success", bsicons::bs_icon("check-circle"), " No problem found in the mapped columns.")
            else tagList(tags$p(class = "small text-muted", "These do not stop anything; they go to the activity log. Correct them in Data Quality or in the source file."),
                         tags$ul(class = "small", lapply(warns$message, tags$li))),
            tags$h6(class = "tw-review-h mt-3", bsicons::bs_icon("grid-3x3-gap"), " What these data allow"),
            tags$table(class = "table table-sm tw-ready-table",
              tags$tbody(lapply(seq_len(nrow(rd)), function(i) tags$tr(
                tags$td(class = "text-muted small", rd$area[i]),
                tags$td(bsicons::bs_icon(status_icon[[rd$status[i]]], class = status_cls[[rd$status[i]]]), " ", rd$feature[i]),
                tags$td(class = "small text-muted", rd$detail[i])))))
          )
        )
      ))
    }

    observeEvent(input$review_back, show_setup_modal(prefill = pending()$map))

    observeEvent(input$review_confirm, {
      p <- pending(); r <- review_state()
      need_ok(!is.null(p) && !is.null(pending_df), "Save the mapping first.")
      waiter::waiter_show(html = waiter_content("Applying the mapping\u2026"), color = "rgba(10, 30, 50, 0.65)")
      on.exit(waiter::waiter_hide(), add = TRUE)
      recodes <- list()
      for (k in names(r$rc)) {
        s <- r$rc[[k]]
        to <- vapply(seq_len(nrow(s)), function(i) input[[sprintf("rc_%s_%d", k, i)]] %||% s$standard[i], "")
        if (all(to == STD_KEEP)) next
        recodes[[k]] <- list(source = p$map[[k]], map = as.list(stats::setNames(to, s$value)))
      }
      plan <- list(force_numeric = p$force, date = if (!is.null(r$date)) list(column = r$date),
                   recodes = recodes, age_from_dob = if (!is.null(r$dob)) list(source = r$dob))
      res <- tw_step("apply the standardised values and dates", apply_setup_plan(pending_df, p$map, plan))
      new_cols <- setdiff(names(res$df), names(pending_df))
      r_data(res$df)
      if (length(new_cols)) register_labels(res$df[new_cols])
      for (k in setup_keys()) settings[[k]] <- res$map[[k]]
      settings$source_map <- p$map
      settings$setup_plan <- plan
      settings$recode_maps <- lapply(recodes, `[[`, "map")
      settings$force_numeric <- p$force[p$force != "" & p$force %in% names(res$df)]
      settings$coercion_blanked <- p$blanked
      settings$checks <- p$checks
      settings$readiness <- data_readiness(res$map)
      pending_df <<- NULL; pending(NULL)
      removeModal()
      waiter_log("open the Overview: KPIs, map and profiles")
      tw_nav("select", "overview_panel", session = parent_session)
      is_ready(TRUE)
      saved_n(saved_n() + 1)
    })

    # What the React import page shows beside its setup button
    # (react/src/pages/import/): the data in memory and whether it is mapped.
    output$state <- shinyreact::reactive_output({
      df <- r_data()
      if (is.null(df)) return(list(loaded = FALSE))
      keys <- setup_keys()
      mapped <- vapply(keys, function(k) shiny::isTruthy(settings[[k]]), logical(1))
      list(loaded = TRUE, rows = nrow(df), cols = ncol(df), source = settings$data_source %||% "",
           mapped = isTRUE(mapped[["unique_id"]]), fields = sum(mapped))
    })

    return(
      list(
        settings = settings,
        validated = is_ready,
        saved = saved_n
      )
    )
  })
}

## To be copied in the UI
# mod_setup_ui("setup_1")

## To be copied in the server
# mod_setup_server("setup_1")
