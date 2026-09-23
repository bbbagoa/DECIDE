#' Welcome / landing page
#'
#' Explains what the app is for and how the three phases fit together. It
#' deliberately loads nothing: importing household registration data is part of
#' beneficiary selection, so it lives in that phase, and the assessment and PDM
#' extracts are loaded inside the tabs that use them.
#'
#' @param tr Translator function from `app_ui()`, so the page follows the
#'   language picker like the rest of the chrome.
#' @import shiny
#' @noRd
mod_welcome_ui <- function(tr = function(x) x) {

  # One phase of the targeting cycle: a numbered card naming the dataset it
  # consumes, so the three-dataset split is the first thing the page teaches.
  phase <- function(n, title, dataset, body, icon_name) {
    tags$div(
      class = "wfp-phase",
      bslib::card(
        class = "wfp-lift",
        bslib::card_header(
          tags$div(
            class = "d-flex align-items-center gap-2",
            tags$span(class = "wfp-phase-number", n),
            bsicons::bs_icon(icon_name),
            tags$span(class = "fw-bold", title)
          )
        ),
        bslib::card_body(
          tags$div(
            class = "wfp-phase-dataset mb-2",
            bsicons::bs_icon("database"), dataset
          ),
          tags$p(class = "small mb-0", body)
        )
      )
    )
  }

  app_version <- tryCatch(
    as.character(utils::packageVersion("TargetWise")),
    error = function(e) "development"
  )

  tagList(
    tags$div(
      class = "wfp-welcome",

      # --- Hero -----------------------------------------------------------
      tags$div(
        class = "wfp-hero text-center",
        tags$div(class = "wfp-eyebrow", tr("WFP Vulnerability Analysis and Mapping")),
        h1("TargetWise"),
        # The tagline stands on its own line, set apart from the description
        # by the rule below it.
        tags$div(class = "wfp-hero-tagline", tags$span(tr("Reach the right people"))),
        tags$div(class = "wfp-hero-rule"),
        tags$p(
          class = "wfp-hero-lead",
          tr("A workflow for designing, applying and checking humanitarian targeting: build an evidence-based scorecard from assessment data, use it to select beneficiaries from registration data, then measure what actually reached households.")
        )
      ),

      # --- The three phases ------------------------------------------------
      bslib::layout_columns(
        col_widths = c(4, 4, 4), fill = FALSE, class = "mb-4",
        phase(
          "1", tr("Targeting Design"), tr("Needs-assessment data"),
          tr("Screen candidate eligibility criteria against a food-security outcome, fit a scorecard, and see the inclusion and exclusion errors your design would produce before anyone is served."),
          "card-checklist"
        ),
        phase(
          "2", tr("Beneficiary Selection"), tr("Household registration data"),
          tr("Load and clean the registration data, spot-check it against field verification, then apply the scorecard and your eligibility rules to produce the beneficiary list."),
          "person-check"
        ),
        phase(
          "3", tr("Targeting Monitoring"), tr("Post-distribution monitoring data"),
          tr("Compare who was eligible with who actually received assistance, and measure the errors introduced during implementation rather than in the design."),
          "bullseye"
        )
      ),

      # --- Where to start --------------------------------------------------
      bslib::card(
        class = "mb-4",
        bslib::card_header(bsicons::bs_icon("signpost-split"), " ", tr("Where to start")),
        bslib::card_body(
          tags$ol(
            class = "mb-0",
            tags$li(tr("Designing a new targeting approach? Start with Targeting Design and load your assessment extract there.")),
            tags$li(tr("Already have a design and need the beneficiary list? Go to Beneficiary Selection and load the registration data.")),
            tags$li(tr("Checking a completed distribution? Go to Targeting Monitoring and load the PDM extract.")),
            tags$li(tr("Each phase loads its own dataset. Nothing you load in one phase overwrites another."))
          ),
          tags$div(
            class = "d-flex flex-wrap gap-2 mt-3",
            actionButton("go_design", tr("Start a targeting design"),
                         icon = icon("scale-balanced"), class = "btn-primary"),
            actionButton("go_import", tr("Load registration data"),
                         icon = icon("upload"), class = "btn-outline-primary"),
            actionButton("go_monitor", tr("Open monitoring"),
                         icon = icon("bullseye"), class = "btn-outline-secondary")
          )
        )
      ),

      # --- Method note + references ---------------------------------------
      bslib::layout_columns(
        col_widths = c(7, 5), fill = FALSE, class = "mb-4",

        bslib::card(
          class = "wfp-lift",
          bslib::card_header(bsicons::bs_icon("shield-check"), " ",
                             tr("What the app will not let you do")),
          bslib::card_body(
            tags$p(
              class = "small",
              tr("Food-security outcome indicators (FCS, rCSI, LCSI, CARI, HHS and the like) measure the symptom of food insecurity, not a household's intrinsic vulnerability. They move with the season and with assistance itself, and if they are used to select households they can no longer be used to validate that selection.")
            ),
            tags$p(
              class = "small mb-0",
              tr("They are therefore refused as eligibility criteria, in line with WFP Targeting Advisory 1/2025. Use them as the outcome your scorecard predicts.")
            )
          )
        ),

        bslib::card(
          class = "wfp-lift",
          bslib::card_header(bsicons::bs_icon("journal-bookmark"), " ", tr("Methodological basis")),
          bslib::card_body(
            tags$div(class = "wfp-credit-label", tr("WFP Assessment and Targeting Unit (APP-FA)")),
            tags$ul(
              class = "small mb-0 ps-3",
              tags$li(tags$strong("Advisory 1/2025"), " \u2014 ",
                      tr("Concerns regarding the use of outcome indicators during the targeting process")),
              tags$li(tags$strong("Advisory 2/2025"), " \u2014 ",
                      tr("Methodological note on targeting errors measurement")),
              tags$li(tags$strong("Advisory 3/2025"), " \u2014 ",
                      tr("Using ROC curves for targeting analysis"))
            )
          )
        )
      ),

      # --- About -------------------------------------------------------------
      # No personal details in the app itself: authorship, citation and
      # contact live in the README distributed with the package.
      bslib::card(
        class = "wfp-credits",
        bslib::card_body(
          bslib::layout_columns(
            col_widths = c(8, 4), fill = FALSE,

            tags$div(
              tags$div(class = "wfp-credit-label", tr("About")),
              tags$div(
                class = "small",
                tr("Open-source R package for humanitarian targeting: design on assessment data, beneficiary selection on registration data, and monitoring on PDM data. "),
                tr("Documentation, how to cite and how to report an issue are in the README distributed with the package.")
              )
            ),

            tags$div(
              tags$div(class = "wfp-credit-label", tr("Release")),
              tags$div(
                class = "small",
                tags$div(tags$strong(tr("Version: ")), app_version),
                tags$div(tags$strong(tr("Licence: ")), "GPL (>= 3)"),
                tags$div(tags$strong(tr("Built with: ")), "R, Shiny, bslib")
              )
            )
          )
        )
      )
    )
  )
}

#' Registration-data import panel
#'
#' The first step of beneficiary selection, not a landing page: this is where
#' the household registration data enters the app and the variable mapping is
#' defined.
#'
#' @param tr Translator function from `app_ui()`.
#' @import shiny
#' @noRd
mod_import_panel_ui <- function(tr = function(x) x) {
  tags$div(
    class = "wfp-import-panel",
    tags$div(
      class = "text-center mb-3",
      h4(tr("Load household registration data"), class = "text-primary mb-1"),
      tags$p(class = "text-muted",
             tr("The list of households you will clean, check and select beneficiaries from."))
    ),

    bslib::card(
      class = "mb-3",
      bslib::card_header(bsicons::bs_icon("clipboard-data"), " ", tr("Household registration data")),
      bslib::card_body(
        tags$p(class = "text-muted mb-2",
               tr("Excel (.xlsx), SPSS (.sav), Stata (.dta), CSV or Parquet; CSV and Parquet load fastest for large files. You can also pull the data from MODA, Kobo Toolbox or ODK Central.")),
        # Load, pull, or extend the data: one row, as on Targeting Design.
        bslib::layout_columns(
          col_widths = c(6, 3, 3), fill = FALSE,
          mod_file_import_ui("file_import_1", display = FALSE),
          tags$div(
            class = "wfp-inline-action",
            tags$label(class = "form-label", tr("Or pull from a server")),
            mod_moda_import_ui("moda_import_1")
          ),
          tags$div(
            class = "wfp-inline-action",
            tags$label(class = "form-label", tr("Missing a variable?")),
            mod_var_calc_ui("calc_reg", "Variable calculator", class = "btn-outline-secondary w-100")
          )
        ),
        tags$div(
          class = "d-flex justify-content-center align-items-center gap-2 mt-2 flex-wrap",
          mod_setup_ui("setup_1")
        )
      )
    ),

    bslib::card(
      class = "mt-3",
      bslib::card_header(bsicons::bs_icon("list-check"), " ",
                         tr("Before you start, check your data")),
      bslib::card_body(
        tags$ul(
          class = "list-group list-group-flush",
          tags$li(
            class = "list-group-item bg-transparent",
            span(class = "fw-bold text-secondary", "1."),
            tr(" Ensure quantitative variables (Age, HH Size, Scores) are formatted as "),
            code("numeric"), tr(" in your source file.")
          ),
          tags$li(
            class = "list-group-item bg-transparent",
            span(class = "fw-bold text-secondary", "2."),
            " ", tr("Vulnerability scales must be "), code("ordered"),
            tr(" (e.g., 1 to 5). Less and shorter "), code("value labels"),
            tr(" are recommended for qualitative variables")
          ),
          tags$li(
            class = "list-group-item bg-transparent",
            span(class = "fw-bold text-secondary", "3."),
            " ", tr("Records with missing "), code("Long/Lat"),
            tr(" coordinates will be automatically ignored on the map.")
          ),
          tags$li(
            class = "list-group-item bg-transparent",
            span(class = "fw-bold text-secondary", "4."),
            " ", tr("Verify that Administrative names are consistent across all levels to avoid filtering errors.")
          ),
          tags$li(
            class = "list-group-item bg-transparent",
            span(class = "fw-bold text-secondary", "5."),
            " ", tr("Do not remove or rename the "), code("start"), " / ", code("end"),
            tr(" variables. They are essential for computing survey duration and tracking operational speed.")
          )
        )
      )
    )
  )
}
