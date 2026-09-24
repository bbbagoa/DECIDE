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
#' @noRd
mod_setup_server <- function(id, r_data, parent_session, trigger_open = reactiveVal(0)) {
  # Takes reactive data as input
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    who <- app_user(session)

    # Bumped whenever the stored profile list changes, so the picker in the
    # modal re-renders without rebuilding the whole modal.
    profiles_changed <- reactiveVal(0)

    # 1. Initialize reactive storage for all 15 variables
    settings <- reactiveValues(
      unique_id = NULL,
      date = NULL,
      admin1 = NULL,
      admin2 = NULL,
      admin3 = NULL,
      admin4 = NULL,
      village = NULL,
      lon = NULL,
      lat = NULL,
      childU5 = NULL,
      hhh_sex = NULL,
      hhh_age = NULL,
      hhid_avail = NULL,
      residency = NULL,
      phone_avail = NULL,
      hh_size = NULL,
      disability = NULL,
      v_score = NULL,
      v_groups = NULL,
      eligibility = NULL,
      enumerator_id = NULL,
      weight = NULL,
      force_numeric = NULL
    )

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

    ###### ------------------  The Modal Form AccepInputs

    is_ready <- reactiveVal(FALSE)

    show_setup_modal <- function() {
      cols <- names(r_data())
      cols_plus_empty <- c("Select a column..." = "", cols)

      # Define guesses for all 15 variables
      g <- list(
        enum = find_guess(
          cols,
          c("enumerator", "enum_id", "enumerator_id", "enumid", "enqueteur")
        ),
        wgt = find_guess(
          cols,
          c("weight", "weights", "sampling_weight", "pond", "ponderation")
        ),
        uid = find_guess(
          cols,
          c("@_uuid", "@_index", "@_id", "index", "instanceID", "ID_menage")
        ),
        day = find_guess(cols, c("date", "today", "aujourdhui")),
        adm1 = find_guess(
          cols,
          c("admin1", "province", "region", "state", "adim1")
        ),
        adm2 = find_guess(
          cols,
          c("admin2", "district", "territoire", "department", "adim2")
        ),
        adm3 = find_guess(
          cols,
          c("admin3", "zonedesante", "zone", "commune", "circle", "adim3")
        ),
        adm4 = find_guess(
          cols,
          c("admin4", "ward", "airedesante", "neighborhood", "admi4")
        ),
        vill = find_guess(cols, c("village", "community", "locality", "site")),
        lon = find_guess(cols, c("lon", "longitude", "xcoord", "coord_x")),
        lat = find_guess(cols, c("lat", "latitude", "ycoord", "coord_y")),
        sex = find_guess(cols, c("sex", "gender", "genre", "hhh_sex")),
        age = find_guess(cols, c("HHHAge", "age", "birth", "hhh_age", "ageCM")),
        size = find_guess(
          cols,
          c("size", "members", "hh_size", "taille", "number")
        ),
        chU5 = find_guess(
          cols,
          c("childrenU5", "enfants", "chlid", "under5", "moins5ans")
        ),
        resi = find_guess(
          cols,
          c("residence", "deplaces", "idp", "typeofresid", "HHStatus")
        ),
        id = find_guess(
          cols,
          c("hhid", "identite", "id_available", "card", "identity")
        ),
        phon = find_guess(
          cols,
          c("phone", "tel", "mobile", "telephone", "sitel")
        ),
        dis = find_guess(
          cols,
          c(
            "disability",
            "handicap",
            "difficult",
            "malad",
            "maladie",
            "chronic"
          )
        ),
        scor = find_guess(
          cols,
          c("score", "vulnerability_score", "v_score", "scoring")
        ),
        grps = find_guess(
          cols,
          c("group", "vulnerability_groups", "v_groups", "class", "category")
        ),
        elig = find_guess(
          cols,
          c("eligibilite", "selection", "result", "choix")
        )
      )

      # Re-opening this modal must not discard a mapping that already exists
      # (restored session, or a previous Save Setup): the stored column wins
      # over the heuristic guess, otherwise Save Setup silently overwrites the
      # user's mapping with find_guess() output.
      keep <- c(day = "date", uid = "unique_id", enum = "enumerator_id",
                wgt = "weight", adm1 = "admin1", adm2 = "admin2",
                adm3 = "admin3", adm4 = "admin4", vill = "village",
                lon = "lon", lat = "lat", sex = "hhh_sex", age = "hhh_age",
                size = "hh_size", resi = "residency", id = "hhid_avail",
                phon = "phone_avail", dis = "disability", chU5 = "childU5",
                scor = "v_score", grps = "v_groups", elig = "eligibility")
      for (k in names(keep)) {
        saved <- settings[[keep[[k]]]]
        if (isTruthy(saved) && saved %in% cols) g[[k]] <- saved
      }

      showModal(modalDialog(
        title = "Select the appropriate variables",
        size = "xl",
        footer = tagList(
          modalButton("Cancel"),
          actionButton(ns("save"), "Save Setup", class = "btn-success")
        ),

        ### ----- Variable Lists

        # A mapping is the same work every round and every country office, so
        # it is savable, shareable and re-appliable rather than re-guessed.
        uiOutput(ns("profile_bar")),

        helpText(
          "Optional: Leave fields as 'Select a column...' if they do not exist in your dataset.
                 Stared fields (*) are mandatory"
        ),

        hr(),

        bslib::accordion(
          id = ns("setup_accordion"),
          open = "1. Identification",
          multiple = FALSE,

          bslib::accordion_panel(
            title = "1. Identification & Survey Design",
            icon = icon("fingerprint"),
            fluidRow(
              column(
                6,
                selectInput(
                  ns("date"),
                  "Data collection date *",
                  choices = cols,
                  selected = g$day
                )
              ),
              column(
                6,
                selectInput(
                  ns("unique_id"),
                  "Specify the unique identifier *",
                  choices = cols,
                  selected = g$uid
                )
              )
            ),
            fluidRow(
              column(
                6,
                selectInput(
                  ns("enumerator_id"),
                  "Enumerator ID",
                  choices = cols_plus_empty,
                  selected = g$enum
                )
              ),
              column(
                6,
                selectInput(
                  ns("weight"),
                  "Sampling weight",
                  choices = cols_plus_empty,
                  selected = g$wgt
                )
              )
            )
          ),
          
          bslib::accordion_panel(
            title = "2. Geographic Variables",
            icon = icon("map-location-dot"),
            fluidRow(
              column(
                3,
                selectInput(
                  ns("admin1"),
                  "Admin 1 Level *",
                  choices = cols,
                  selected = g$adm1
                )
              ),
              column(
                3,
                selectInput(
                  ns("admin2"),
                  "Admin 2 Level *",
                  choices = cols,
                  selected = g$adm2
                )
              ),
              column(
                3,
                selectInput(
                  ns("admin3"),
                  "Admin 3 Level *",
                  choices = cols,
                  selected = g$adm3
                )
              ),
              column(
                3,
                selectInput(
                  ns("admin4"),
                  "Admin 4 Level *",
                  choices = cols,
                  selected = g$adm4
                )
              )
            ),
            fluidRow(
              column(
                4,
                selectInput(
                  ns("village"),
                  "Village/Community *",
                  choices = cols,
                  selected = g$vill
                )
              ),
              column(
                4,
                selectInput(
                  ns("lon"),
                  "GPS Longitude *",
                  choices = cols,
                  selected = g$lon
                )
              ),
              column(
                4,
                selectInput(
                  ns("lat"),
                  "GPS Latitude *",
                  choices = cols,
                  selected = g$lat
                )
              )
            )
          ),
          
          bslib::accordion_panel(
            title = "3. Household Demographics",
            icon = icon("users"),
            fluidRow(
              column(
                3,
                selectInput(
                  ns("hhh_sex"),
                  "HH Head Sex *",
                  choices = cols,
                  selected = g$sex
                )
              ),
              column(
                3,
                selectInput(
                  ns("hhh_age"),
                  "HH Head Age *",
                  choices = cols,
                  selected = g$age
                )
              ),
              column(
                3,
                selectInput(
                  ns("hh_size"),
                  "Total HH Size *",
                  choices = cols,
                  selected = g$size
                )
              ),
              column(
                3,
                selectInput(
                  ns("residency"),
                  "Residence Type *",
                  choices = cols,
                  selected = g$resi
                )
              )
            ),
            fluidRow(
              column(
                3,
                selectInput(
                  ns("hhid_avail"),
                  "HH Head ID Available?",
                  choices = cols_plus_empty,
                  selected = g$id
                )
              ),
              column(
                3,
                selectInput(
                  ns("phone_avail"),
                  "HH Phone Available?",
                  choices = cols_plus_empty,
                  selected = g$phon
                )
              ),
              column(
                3,
                selectInput(
                  ns("disability"),
                  "HH Disability or Chronic Illness",
                  choices = cols_plus_empty,
                  selected = g$dis
                )
              ),
              column(
                3,
                selectInput(
                  ns("childU5"),
                  "Children Under 5 *",
                  choices = cols,
                  selected = g$chU5
                )
              )
            )
          ),
          
          bslib::accordion_panel(
            title = "4. Vulnerability & Scoring",
            icon = icon("shield-heart"),
            fluidRow(
              column(
                4,
                selectInput(
                  ns("v_score"),
                  "Vulnerability Score *",
                  choices = cols,
                  selected = g$scor
                )
              ),
              column(
                4,
                selectInput(
                  ns("v_groups"),
                  "Vulnerability Groups",
                  choices = cols_plus_empty,
                  selected = g$grps
                )
              ),
              column(
                4,
                selectInput(
                  ns("eligibility"),
                  "Eligibility",
                  choices = cols_plus_empty,
                  selected = g$elig
                )
              )
            )
          ),

        )
      ))
      # A mapping already made, or brought back with a restored session, wins
      # over the name guesses: reopening the setup must show what is in use.
      for (k in PROFILE_KEYS) {
        v <- settings[[k]]
        if (is.character(v) && length(v) == 1 && v %in% cols) updateSelectInput(session, k, selected = v)
      }
    }

    observeEvent(input$open_modal, {
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

    output$profile_bar <- renderUI({
      profiles_changed()
      saved <- list_profiles(who)
      choices <- if (nrow(saved) == 0) {
        c("No saved profiles yet" = "")
      } else {
        stats::setNames(saved$name, paste0(saved$name, "  (", format(saved$saved_at, "%Y-%m-%d %H:%M"), ")"))
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
                         class = "btn-primary btn-sm"),
            actionButton(ns("profile_save"), "Save", icon = icon("floppy-disk"),
                         class = "btn-success btn-sm"),
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
      req(shiny::isTruthy(input$profile_choice))
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
      save_profile(profile_from_settings(current_map(), name = nm), who)
      profiles_changed(profiles_changed() + 1)
      showNotification(paste0("Profile '", nm, "' saved."), type = "message")
    })

    observeEvent(input$profile_delete, {
      req(shiny::isTruthy(input$profile_choice))
      nm <- input$profile_choice
      delete_profile(nm, who)
      profiles_changed(profiles_changed() + 1)
      showNotification(paste0("Profile '", nm, "' deleted."), type = "message")
    })

    output$profile_download <- downloadHandler(
      filename = function() {
        nm <- profile_save_name()
        if (!nzchar(nm)) nm <- "setup-profile"
        paste0(sanitize_session_name(nm), ".json")
      },
      content = function(file) {
        nm <- profile_save_name()
        if (!nzchar(nm)) nm <- "setup-profile"
        writeLines(as.character(profile_to_json(profile_from_settings(current_map(), name = nm))),
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

    #### ---------- Inputs Checking and save

    # Validate and save helper. When force_cols is empty and numeric fields are
    # invalid, a modal is shown so the user can pick which columns to coerce.
    do_save <- function(force_cols = character()) {
      waiter::waiter_show(
        html = waiter_content(),
        color = "rgba(10, 30, 50, 0.65)"
      )
      on.exit(waiter::waiter_hide(), add = TRUE)

      df <- r_data()

      # 1. Collect all inputs
      map_list <- list(
        unique_id = input$unique_id,
        date = input$date,
        admin1 = input$admin1,
        admin2 = input$admin2,
        admin3 = input$admin3,
        admin4 = input$admin4,
        village = input$village,
        lon = input$lon,
        lat = input$lat,
        hhh_sex = input$hhh_sex,
        hhh_age = input$hhh_age,
        hh_size = input$hh_size,
        residency = input$residency,
        childU5 = input$childU5,
        hhid_avail = input$hhid_avail,
        phone_avail = input$phone_avail,
        disability = input$disability,
        v_score = input$v_score,
        v_groups = input$v_groups,
        eligibility = input$eligibility,
        enumerator_id = input$enumerator_id,
        weight = input$weight
      )

      # 2. Filter out empty strings (unmapped columns)
      actual_selections <- unlist(map_list)[unlist(map_list) != ""]

      # 2a. Check required fields
      required_fields <- c(
        "unique_id", "date", "admin1", "admin2", "admin3",
        "village", "lon", "lat", "hhh_sex", "hhh_age",
        "hh_size", "residency", "childU5", "v_score"
      )
      missing_fields <- required_fields[sapply(map_list[required_fields], function(x) is.null(x) || x == "")]
      if (length(missing_fields) > 0) {
        showNotification(
          paste("Please map all required fields:", paste(missing_fields, collapse = ", ")),
          type = "error",
          duration = 10
        )
        return()
      }

      # 2b. Check for Duplicates
      if (anyDuplicated(actual_selections) > 0) {
        showNotification("The same column is mapped to two fields.", type = "error")
        return()
      }

      # 3. Type Validation: Check if numeric fields are actually numeric
      numeric_fields <- c("hhh_age", "hh_size", "v_score", "lat", "lon", "weight")
      df_local <- df

      # How many filled-in values each forced column loses (text that does not
      # parse becomes blank); recorded so the audit trail can say so.
      blanked <- integer(0)
      if (length(force_cols) > 0) {
        for (col in force_cols) {
          if (isTruthy(col) && col %in% names(df_local)) {
            before <- df_local[[col]]
            df_local[[col]] <- suppressWarnings(as.numeric(as.character(before)))
            blanked[[col]] <- sum(!is.na(before) & nzchar(trimws(as.character(before))) & is.na(df_local[[col]]))
          }
        }
      }

      invalid_fields <- c()
      invalid_col_names <- c()
      for (field in numeric_fields) {
        col_name <- map_list[[field]]
        if (is.null(col_name) || col_name == "" || !col_name %in% names(df_local)) next
        if (!is.numeric(df_local[[col_name]])) {
          invalid_fields <- c(invalid_fields, field)
          invalid_col_names <- c(invalid_col_names, col_name)
        }
      }

      if (length(invalid_fields) > 0) {
        labels <- paste0(invalid_fields, " (", invalid_col_names, ")")
        showModal(modalDialog(
          title = "Non-numeric variables detected",
          "The following variables must be numeric but are currently text. Check the ones you want to force to numeric and click Force.",
          checkboxGroupInput(
            ns("force_numeric_cols"),
            "Variables to force to numeric",
            choices = setNames(invalid_col_names, labels),
            selected = invalid_col_names
          ),
          footer = tagList(
            modalButton("Cancel"),
            actionButton(ns("force_numeric_save"), "Force numeric", class = "btn-warning")
          )
        ))
        return()
      }

      r_data(df_local)
      df <- r_data()
      id_col <- input$unique_id

      # We use 'anyDuplicated' because it's extremely fast on 1GB data
      if (anyDuplicated(df[[id_col]]) > 0) {
        dup_count <- sum(duplicated(df[[id_col]]))

        showModal(modalDialog(
          title = "Non-Unique ID Detected",
          footer = modalButton("Dismiss"),
          status = "warning",
          tags$p(paste(
            "Error: The column selected as HH_ID contains",
            format(dup_count, big.mark = ","),
            "duplicate entries."
          )),
          tags$p(
            "Data cleaning and targeting require a unique identifier for every row.
             Please resolve these duplicates in your source file or select a different ID column."
          )
        ))
        return()
      }

      # 4. If all checks pass, save to reactiveValues
      for (name in names(map_list)) {
        settings[[name]] <- map_list[[name]]
      }
      settings$force_numeric <- force_cols[force_cols != "" & force_cols %in% names(df_local)]
      settings$coercion_blanked <- blanked

      removeModal()

      # Use parent_session to reach the main navbar outside the module
      bslib::nav_select(
        id = "main_nav",
        selected = "overview_panel",
        session = parent_session
      )

      if (is.null(input$unique_id)) {
        showNotification(
          "Error: The Unique ID is mandatory for data cleaning.",
          type = "error"
        )
      } else {
        is_ready(TRUE) # This triggers the nav_show in the main server
      }
    }

    observeEvent(input$save, {
      do_save(character())
    })

    observeEvent(input$force_numeric_save, {
      selected <- input$force_numeric_cols
      if (is.null(selected)) selected <- character()
      do_save(selected)
    })

    return(
      list(
        settings = settings,
        validated = is_ready
      )
    )
  })
}

## To be copied in the UI
# mod_setup_ui("setup_1")

## To be copied in the server
# mod_setup_server("setup_1")
