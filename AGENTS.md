# Agent Guide for TargetWise

This document is intended for AI coding agents working on the `TargetWise` project. It describes the project's purpose, architecture, technology stack, development workflow, and conventions as they actually exist in the codebase today.

---

## Project Overview

**TargetWise** is an R-based Shiny dashboard for humanitarian targeting analysis. It is designed to help analysts identify and prioritize vulnerable households by importing large household-level datasets (Excel, SPSS, or Stata), mapping them geographically, and providing interactive summaries, data-quality checks, and an audit trail for modifications.

The project is structured as a **Golem package** — an R package that bundles a Shiny application. This means it uses standard R package conventions (`DESCRIPTION`, `NAMESPACE`, `R/`, `inst/`, `man/`) and is deployed as a package rather than a single standalone Shiny script.

Key business concepts in the app:

- **Targeting data**: household-level survey records with geographic, demographic, and vulnerability variables.
- **Variable mapping**: users map their own column names to a fixed set of required/optional fields (for example, `admin1`, `admin2`, `admin3`, `admin4`, `village`, `lon`, `lat`, `hhh_sex`, `hhh_age`, `hh_size`, `v_score`, `v_groups`, `eligibility`, etc.).
- **Large-data mode**: the app is explicitly optimized for datasets up to roughly 1.5–2 GB and millions of rows, using in-memory reactive data frames, vectorized operations, and spinner-based feedback (`waiter`).

---

## Technology Stack

### Core runtime

- **R** (lockfile built against R 4.6.0; see `renv.lock` and `manifest.json`).
- **Shiny** for the interactive web application.
- **Golem** for packaging the Shiny app.
- **bslib** for Bootstrap 5 / Bootswatch theming.

### Major R dependencies used in code

- `shiny`, `bslib`, `bsicons`, `shinyWidgets`, `shinycssloaders`, `waiter`
- `dplyr`, `tidyr`, `rlang`, `lubridate`, `stringr`
- `plotly`, `ggplot2`, `thematic`
- `DT`
- `leaflet`, `leafgl`, `sf`
- `readxl`, `haven`, `openxlsx`, `data.table` (CSV import), `nanoparquet` (Parquet import)
- `httr`, `curl`, `jsonlite` (for the MODA/ONA API import module)
- `sodium` (encrypted session persistence)
- `VIM` (K-nearest-neighbor imputation in the Outliers DQ sub-tab)
- `config`, `pkgload`, `later`

See `DESCRIPTION` for the declared `Imports` and `renv.lock` / `manifest.json` for the full resolved dependency tree.

### Other files / artifacts

- `package.json` exists at the project root and declares Node dependencies (`@supabase/supabase-js`, `dotenv`). There is **no active JavaScript/Node server code** in the repository; these packages appear to be placeholder or future-use dependencies and are not imported by the R application.
- `manifest.json` is a Posit Connect deployment manifest and should be regenerated with `rsconnect::writeManifest()` whenever package dependencies change.
- `renv.lock` is the `renv` lockfile. `renv/settings.json` configures `renv` with `snapshot.type: "explicit"`.

---

## Project Structure

```text
TargetWise/
├── R/                          # R package source code
│   ├── app_ui.R                # Main UI definition (bslib page_navbar + tabs)
│   ├── app_server.R            # Main server logic: import orchestration, tab reveal, session manager
│   ├── run_app.R               # golem entry point: run_app()
│   ├── app_config.R            # app_sys() and get_golem_config()
│   ├── mod_file_import.R       # Shiny module: file upload (xlsx/sav/dta)
│   ├── mod_setup.R             # Shiny module: variable mapping / setup modal
│   ├── mod_moda_import.R       # Shiny module: MODA/ONA API import (WIRED INTO main flow)
│   ├── mod_overview.R          # Shiny module: Overview dashboard (KPIs, map, profiles)
│   ├── mod_dq.R                # Data Quality orchestrator (sidebar + core + sub-tab delegation)
│   ├── mod_dq_spelling.R       # DQ sub-tab: Spelling & Integrity
│   ├── mod_dq_location.R       # DQ sub-tab: Location name normalization
│   ├── mod_dq_missing.R        # DQ sub-tab: Missing Data Checking
│   ├── mod_dq_outliers.R       # DQ sub-tab: Outliers
│   ├── mod_dq_duplicates.R     # DQ sub-tab: Duplicates
│   ├── mod_dq_enumerator.R     # DQ sub-tab: Enumerator Performance
│   ├── mod_spot_checking.R     # Shiny module: Spot Checking (sampled-record review)
│   ├── mod_ben_selection.R     # Shiny module: Beneficiary Selection (criteria + weighted export)
│   ├── mod_audit.R             # Shiny module: Audit Trail (modification log + export)
│   ├── mod_pdm.R               # Shiny module: PDM / targeting-accuracy tab (own upload, inclusion/exclusion error)
│   ├── mod_session_manager.R   # Shiny module: session save/load/clear + autosave + MODA re-sync
│   ├── utils_verification.R    # compare_verification(): spot-check back-check engine (agreement + discordances)
│   ├── utils_helpers.R         # find_bad_names(), weighted stats, fuzzy_match_groups, filter_by_date_range(), waiter_content()
│   ├── utils_targeting.R       # targeting-accuracy & distribution primitives (coverage, inclusion/exclusion error, Lorenz/Gini, weighted crosstab/cor)
│   ├── utils_approach.R        # targeting approaches (hybrid, scorecard/PMT, categorical, community, geographic, blanket, self) + select_households() with prioritisation
│   ├── utils_session.R         # encrypted session persistence (sodium), per-install key
│   ├── utils_plots.R           # create_profile_plot() (weight-aware boxplots/bars)
│   ├── utils_outliers.R        # outlier_bounds/_reason/_limits, allowed ranges, sentinel codes, numeric_audit(), verified_uids()
│   └── utils_globals.R         # global option helpers
├── tests/
│   └── testthat/               # Unit tests (helpers, session manager, session crypto, app)
├── inst/
│   ├── extdata/                # Demo datasets (assessment_demo.csv, registration_demo.csv) for users
│   ├── app/www/                # Static assets: WFP logos, favicon, custom.css, wfp-ui.css (design tokens + soft-modern/dark theme)
│   └── golem-config.yml        # Golem environment config
├── dev/                        # Development / deployment helper scripts
│   ├── 01_start.R              # Golem project bootstrap
│   ├── 02_dev.R                # Recommended dev workflow
│   ├── 03_deploy.R             # Deployment commands (Posit, Docker, CRAN)
│   ├── run_dev.R               # Local development runner
│   └── config_attachment.yaml  # attachment::att_amend_desc() config
├── man/                        # Rd documentation (auto-generated by roxygen2)
├── app.R                       # Explicit deployment entry point
├── DESCRIPTION                 # R package metadata and dependencies
├── NAMESPACE                   # Exported/imported symbols (auto-generated)
├── renv.lock                   # renv dependency lockfile
├── manifest.json               # Posit Connect deployment manifest
├── package.json                # Node dependencies (currently unused by R app)
└── README.md                   # Human-readable project description
```

---

## Application Architecture

### Golem package pattern

The app follows the standard Golem pattern:

1. `app.R` is the deployment entry point. It calls `pkgload::load_all()` and then `run_app()`.
2. `run_app()` (in `R/run_app.R`) wraps `shinyApp(ui = app_ui, server = app_server)` with `golem::with_golem_options()`.
3. `app_ui()` builds the UI with `bslib::page_navbar()`.
4. `app_server()` contains the server logic.

### UI tabs

The application is organized into a top navigation bar with the following panels:

1. **Welcome**: landing page with data-upload instructions, the file-import module, and the MODA API import module side by side.
2. **Overview**: main dashboard with KPI value boxes (incl. sampling-weighted counts and a daily-sync-rate sparkline), an interactive `leafgl` map, vulnerability table, eligibility donut, and six demographic profile plots.
3. **Data Quality**: a shared admin/date filter sidebar plus six functional sub-tabs — Spelling & Integrity, Location names normalization, Missing Data Checking, Outliers, Duplicates, and Enumerator Performance.
4. **Spot Checking**: sampled-record review for spot verification.
5. **Ben. Selection**: beneficiary selection by admin level and vulnerability-score range, with household/individual counts, a Composition tab (insight tiles, served / excluded-by-design / not eligible by area, selected-vs-not profile via `selection_profile()`), the variable calculator in the sidebar, and a selection export (also reachable from the Beneficiary list tab) with a `By_area` sheet (`selection_by_area()`). The old sidebar "Household criteria" pickers were removed: the eligibility rules cover them on any column.
6. **Audit Trail**: a top-level page (not under Beneficiary Selection), visible from the start, covering all phases. Entries written with `audit_add(log, phase, action, detail)` carry a `Design:`/`Selection:`/`Monitoring:`/`Session:` prefix that `audit_phase()` reads for the phase filter; older DQ entries without a prefix count as Selection. `deleted_uids()` reads deleted record ids back, so a MODA re-sync keeps them out.

The Overview, Data Quality, Spot Checking, Ben. Selection, and Audit Trail tabs are hidden until the user completes setup validation.

### Module divisions

| Module | File | Responsibility |
|---|---|---|
| `file_import` | `R/mod_file_import.R` | Upload `.xlsx`, `.sav`, or `.dta` files and return a reactive data frame. |
| `moda_import` | `R/mod_moda_import.R` | Direct import (and re-sync) from the WFP MODA (ONA) API using a Form ID + API Gateway Key. Wired into the Welcome panel and re-triggerable via the session toolbar's **Sync MODA** button. |
| `setup` | `R/mod_setup.R` | Modal form for mapping user columns to the app's variable schema; performs validation (required fields, duplicates, numeric coercion, unique-ID check). Auto-guesses columns with `find_guess()`. |
| `overview` | `R/mod_overview.R` | KPI value boxes, leafgl map, vulnerability table, eligibility donut, demographic profile plots; supports sampling-weighted metrics. |
| `dq` | `R/mod_dq.R` + `R/mod_dq_*.R` | Data Quality orchestrator: shared admin/date filter pipeline, the master `dq_filtered_data`, the Reset-to-original action, and delegation to six sub-tab modules. |
| `dq_*` sub-tabs | `R/mod_dq_spelling.R` … `R/mod_dq_enumerator.R` | One file per DQ sub-tab. Each defines a `*_ui(ns)` and a `*_server(input, output, session, ns, core)` called from inside the orchestrator's `moduleServer` body, so they share the parent namespace (no input-id churn). |
| `spot_checking` | `R/mod_spot_checking.R` | Sampled-record review for spot verification. |
| `ben_selection` | `R/mod_ben_selection.R` | Beneficiary selection by admin level + vulnerability-score range; weighted counts and selection export. |
| `audit` | `R/mod_audit.R` | Modification log table with Excel/CSV export. |
| `monitoring` | `R/mod_monitoring.R` | **Targeting Monitoring** (phase 3), three tabs: the PDM analysis (`mod_pdm`, nested, returns its data and results), process monitoring (any number of datasets) and the monitoring report. Charts and tables come from `mod_chart_builder.R` (ready-made presets + free builder); one aggregation, `chart_aggregate()` in `R/utils_monitoring.R`, feeds the plotly preview, the table view (`chart_table()`) and the billboarder charts of `write_monitoring_report()`. Report items (title, comment, spec, data) and the officer's context / findings / recommendations are saved with the session. |
| `pdm` | `R/mod_pdm.R` | **PDM Accuracy** tab. Loads its own Post-Distribution Monitoring extract (file upload), maps an eligibility ground truth + a beneficiary flag, and reports weighted inclusion / exclusion error, coverage, precision & recall via `targeting_metrics()` plus `coverage_by_unit()`. Eligibility comes from a PDM column, or from the adopted scorecard / eligibility rules applied to the PDM answers (`pdm_scorecard_eligibility()`, `ruleset_eval()`; a missing criterion refuses the calculation). Weighting: population sizes overall or per area -> `pdm_stratum_weights()` (w = N / n per group; the PDM surveys set numbers of beneficiaries and non-beneficiaries), a weight column, or none. No non-beneficiaries surveyed -> exclusion error and coverage NA. |
| `session_manager` | `R/mod_session_manager.R` | Save / load / clear sessions, debounced autosave, restore-on-startup modal, and the MODA re-sync trigger. |

### Data-Quality sub-module layout

`mod_dq.R` is a thin orchestrator. The shared sidebar filter and the master `dq_filtered_data <- reactive({...})` live in the orchestrator and are bundled into a `core` list that is passed to each sub-tab server:

```r
core <- list(
  dq_filtered_data = dq_filtered_data,
  uploaded_df      = uploaded_df,
  user_setup       = user_setup,
  modification_log = modification_log
)
dq_spelling_server(input, output, session, ns, core)
dq_location_server(input, output, session, ns, core)
# ...missing, outliers, duplicates, enumerator
```

Each `*_server` aliases those names locally (e.g. `dq_filtered_data <- core$dq_filtered_data`) so its body reads identically to the pre-split monolith. Because the sub-servers are plain functions invoked synchronously inside the orchestrator's `moduleServer` body, they share its reactive domain — `observeEvent`/`reactive`/`observe` register correctly, and every `input$xxx`/`output$xxx` reference resolves unchanged. Mutating sub-tabs still write back to the shared `uploaded_df()` reactive, which is the single source of truth. The **Reset to Original Data** action stays in the orchestrator (it uses `original_df` directly).

### Analytical methods

The app's analytical primitives live in `R/utils_targeting.R` as pure, unit-tested functions (`tests/testthat/test-targeting.R`), so the modules stay focused on UI + wiring.

**Targeting accuracy (`mod_ben_selection.R`)** — activates **only when an eligibility column is mapped** (graceful no-op otherwise). The selection is compared against a binary eligibility ground-truth normalised by `eligibility_flag()` (yes/1/true/eligible/… vs no/0/false/ineligible/…; ambiguous values → NA):
- `targeting_metrics()` computes weighted **coverage rate, selection ratio, inclusion error, exclusion error, precision, recall**.
- `coverage_by_unit()` produces a per-admin-unit coverage table.
- Selection runs through `select_households()` (`R/utils_approach.R`): the **targeting approach** picker decides which layers apply (area / criteria / score / community), and **prioritisation** (total caseload or caseload per admin unit, most vulnerable first) cuts the eligible list. Households cut there are **excluded by design** (Advisory 2/2025): reported separately and never counted as exclusion error — accuracy diagnostics compare the *eligible-by-design* mask, and the extra exclusion caused by prioritisation is shown on its own.
- The selection export is an openxlsx workbook: `Selected` (prioritised rows + `selection_score`), `Excluded_by_design` (when prioritisation cut anyone) and `Selection_Metadata` (approach, prioritisation, filters, rules, totals, accuracy, notes).
- `reference/COMPLIANCE.md` maps each requirement from the WFP Targeting OGN (2021), the APP-FA advisories and UNHCR-WFP Joint Hub / ICRC-IFRC material to what the app does, with the open gaps. Update it when a gap closes.

**Targeting Design (`mod_scorecard.R`)** — a stepper across the page (data → outcome → criteria → screening → model → threshold) shows what is done and the next action. Step 3 *Variable selection* screens criteria, then shows the correlation matrix and descriptive statistics of the ticked variables before the analyst drops any (styled HTML table, colour-coded p-values, `R/utils_model_tables.R`). Step 4 fits logistic, stepwise, weight-of-evidence or boosted-stump models, or machine-learning models (random forest, XGBoost, naive Bayes, neural network, SVM) whose points are average marginal effects (all additive, `R/utils_models.R`), keeps a run history with restore, and shows estimates (editable points + review flags in one table) and the model comparison. Step 5 defaults the threshold to `balanced_threshold()` (minimises the larger of the two design errors), shows the error rates as tolerance tracks and the design matrix as a report table. **Design report (HTML)** in the sidebar writes one self-contained HTML file: the Markdown record converted with `commonmark`; the charts are billboarder widgets (`R/utils_report_plots.R`) whose JS/CSS `report_inline_deps()` inlines, laid out two per row where paired, so the file works offline (`R/utils_report.R`). The verdict on the Threshold and PDM tabs is `verdict_card()` (CSS-only archery animation, replayed only when the verdict changes, off under reduced motion).

**Variable calculator (`R/mod_var_calc.R`, `R/utils_calc.R`)** — on the registration import panel and the Targeting Design data card: yes/no variables from conditions, numeric ones from formulas. Formulas are parsed and checked against the column names and a whitelist of functions before they run — never widen that list to anything that reaches the file system, the network or the environment. Registration columns created this way are logged to the audit trail. An **R code** mode (`calc_code()`) runs a pasted multi-line block with local variables, `x[cond] <- v` and `if/else`; `calc_check_code()` walks it against `calc_code_functions()` (no loops, no `function`, no `$`/`::`, no eval/get/do.call) and assignments land in a scratch environment, never in the data. Python is deliberately not supported: it would need reticulate and cannot be sandboxed the same way.

**Distribution & correlation (`mod_overview.R`)** — weighted Lorenz curve + **Gini** coefficient of the vulnerability score (`weighted_lorenz()`), a weighted cross-tabulation explorer with a chi-square p-value (`weighted_crosstab()`), and a weighted correlation matrix heatmap (`weighted_cor_matrix()`). Profile plots (`create_profile_plot`) are weight-aware: boxplot branches use weighted quantiles (`weighted_boxplot_summary()`), the categorical branch uses weighted counts.

**Outlier detection (`mod_dq_outliers.R`, `R/utils_outliers.R`)** — any numeric column (`quantitative_cols()`: numeric, or text/factor whose answers parse as numbers), mapped fields first. Three methods with method-appropriate thresholds: **IQR** (Tukey multiplier, default 1.5), **Z-score** (default 3 SD), and **modified Z-score / MAD** (default 3.5, the Iglewicz–Hoaglin cut-off), or "allowed range only". An **allowed range** per variable (suggested for hh_size / hhh_age / childU5, remembered per variable in the session) flags impossible values whatever the distribution; the effective limits are the tighter of the two. The *Most extreme values* tab has insight tiles (direction, most extreme, concentration on an enumerator or area, repeated 99-style codes via `sentinel_codes()`) and a selectable table: correct selected, set a value, or **mark as verified** (logged as "Outlier verified (kept)" and read back by `verified_uids()`, so they stop being flagged). *All numeric variables* audits every numeric column at once (`numeric_audit()`). Corrections: cap at the limits / set to missing / median / mean / **KNN via `VIM::kNN`** / drop, each previewed before/after, with a reason, logged per value.

**Duplicates (`mod_dq_duplicates.R`)** — groups shown as DT RowGroup bands, with the columns that differ inside each group (`duplicate_group_diffs()`, one vectorised pass per column; skipped above 50k duplicated rows) and exact copies marked. Rows are selectable (all but the first of each group, exact copies), a Compare modal shows a group side by side with differing fields first, and deletion (from the table or the modal) finds rows back by id AND content, so one of two records sharing an id is removed, logged as "Duplicate deletion".

**Data-quality flags** — `enumerator_flags()` flags an enumerator ("Review") when their mean interview duration is outside the cohort IQR fences, their missingness exceeds cohort mean + 2 SD, or (date mapped) one day's interviews exceed the team's Q3 + 1.5 IQR of enumerator-days; each flag carries its reason in words, shown on the *Flagged enumerators* tab with their interviews one click away. The column-health table adds a colored `Status` band (OK ≥95% / Review 90–95% / At risk <90%). Missingness is now **weight-aware** and uses a unified definition (NA / `""` / `"NULL"`) across the missing-data and enumerator modules.

**Map (`mod_overview.R`)** — a mode toggle between **Points** (per-row WebGL via `leafgl`) and **Choropleth** (one weighted-mean-score circle-marker per admin-unit centroid, radius ∝ weighted household count). Choropleth needs no shapefile dependency.

### Reports and exports

- HTML reports share `report_write_page()` (`R/utils_report.R`): Markdown body -> commonmark, `@@FIG:a,b@@` placeholders -> billboarder charts side by side, raw HTML `blocks`, TOC, WFP header band with a meta list, everything inlined (works offline). The design report (`write_design_report()`) and the spot-check verification report (`write_verification_report()`, `R/utils_verification_report.R`) both use it.
- Formatted Excel sheets: `xl_summary_sheet()` (title + labelled sections) and `xl_data_sheet()` (styled header, frozen row, filters, fitted widths) in `R/utils_tables.R`. The selection export records the data source (`user_setup$data_source`, set on import), the data-preparation counts from the audit trail, calculated variables, variable mapping, scorecard and accuracy, plus an `Audit_trail` sheet.
- Beneficiary Selection counts households, unweighted (no survey weights in selection).
- Every DataTable scrolls inside its own frame (`DT.options` set in `app_server()`), header pinned.

### Data flow

1. User uploads a file via the file-import module, or pulls from the MODA API. Both feed `app_server()`; if data is already in memory, an override confirmation modal is shown.
2. The reactive `uploaded_df` (and a pristine `original_df`) in `app_server()` receive the data.
3. The setup module lets the user map columns (auto-guessed).
4. On successful validation, additional tabs are revealed and the app navigates to **Overview**.
5. All downstream outputs (map, tables, plots, DQ tools) read from `uploaded_df()` and the user setup mapping (`user_setup`).
6. Data-quality edits (name corrections, record deletions, location normalization, outlier correction) mutate `uploaded_df()` in memory and append entries to `modification_log()`.
7. Session state (`uploaded_df`, the pristine `original_df` when it differs from it (Reset baseline), `user_setup`, `modification_log`, theme, MODA credentials minus token, and the **workspace**: each module's work registered with `workspace_register(workspace, key, snapshot, restore)`: Targeting Design, Ben. Selection, Spot Checking, PDM) is encrypted and persisted to the user data directory via `utils_session.R`; the session manager offers restore-on-startup, manual save/load/clear, and debounced autosave.

### Important runtime options

`app.R` sets:

```r
options(viewer = NULL)
options(shiny.launch.browser = TRUE)
options(shiny.maxRequestSize = 2 * 1024^3)  # 2 GB upload limit
```

`dev/run_dev.R` sets the same 2 GB upload limit and `shiny.sanitize.errors = FALSE` for clearer errors during development.

---

## Build, Run, and Test Commands

### Local development

Run the app in development mode from the project root:

```r
source("dev/run_dev.R")
```

`dev/run_dev.R` does the following:

- Sets production/dev options.
- Detaches attached packages.
- Calls `golem::document_and_reload()` to rebuild documentation and reload the package.
- Calls `run_app()`.

### Deployment entry point

`app.R` is the file used by Posit Connect / Shiny Server:

```r
library(golem)
pkgload::load_all(export_all = FALSE)
run_app()
```

### Dependency management

The project uses `renv`. The lockfile is `renv.lock`.

```r
# Restore the environment from the lockfile
renv::restore()

# After adding/removing R package dependencies, update DESCRIPTION and the lockfile
attachment::att_amend_desc()   # updates DESCRIPTION from code
renv::snapshot()               # updates renv.lock
```

`dev/02_dev.R` documents the intended workflow: use `attachment::att_amend_desc()` to keep `DESCRIPTION` in sync with `library()` and `::` usage in the code.

### Documentation

The project uses `roxygen2`. The `NAMESPACE` and `man/` files are auto-generated.

```r
devtools::document()
# or
golem::document_and_reload()
```

### Testing

The package has a `testthat` suite under `tests/testthat/`. Existing files cover helper logic (`find_guess`, `find_bad_names`, `get_location_summary`, MODA `parse_total_pages`/`harmonize_pages`, weighted statistics, `fuzzy_match_groups`), the targeting-analytic primitives in `utils_targeting.R` (`targeting_metrics`, `weighted_quantile`/`weighted_lorenz`/Gini, `weighted_crosstab`, `weighted_cor`/`_matrix`), session name sanitization, session save/load round-trips, and the sodium `encrypt_session`/`decrypt_session` crypto pipeline.

```r
devtools::test()          # run the suite
usethis::use_test("<name>")  # add a new test file
```

Note: some tests source helpers directly (e.g. `TargetWise:::harmonize_pages`), so the package must be installed/loaded for the internal-symbol tests to resolve.

### Package check and build

```r
devtools::check()   # run R CMD check
devtools::build()   # build the .tar.gz package
```

### Posit Connect deployment

The project is already configured for Posit Connect (`connect.posit.cloud`) with deployment records under `rsconnect/`. The deployment script in `dev/03_deploy.R` shows the intended workflow:

```r
rsconnect::writeManifest()
rsconnect::deployApp(
  appName = desc::desc_get_field("Package"),
  appTitle = desc::desc_get_field("Package"),
  appFiles = c("R/", "inst/", "data/", "NAMESPACE", "DESCRIPTION", "app.R"),
  appId = rsconnect::deployments(".")$appID,
  lint = FALSE,
  forceUpdate = TRUE
)
```

**Note:** `manifest.json` is large and tracks the full dependency tree. Regenerate it after any package change.

---

## Code Style and Conventions

### Language

All code comments, documentation, and UI labels in the project are in **English**. User-facing messages are also in English.

### File naming

- Golem module files: `mod_<name>.R`
- Helper files: `utils_<name>.R` or `fct_<name>.R` (currently `utils_helpers.R` and `utils_plots.R`)
- Entry points: `app.R`, `R/run_app.R`
- Dev scripts: `dev/01_start.R`, `dev/02_dev.R`, `dev/03_deploy.R`, `dev/run_dev.R`

### Module pattern

Modules follow the standard Shiny/Golem convention:

```r
mod_<name>_ui <- function(id) {
  ns <- NS(id)
  tagList(...)
}

mod_<name>_server <- function(id, ...) {
  moduleServer(id, function(input, output, session) {
    # module logic
  })
}
```

### Naming conventions in code

- `snake_case` is used throughout.
- UI input IDs are descriptive and often prefixed by panel, for example `filter_admin1`, `dq_filter_adm1`, `btn_apply_norm`.
- The setup module returns a `reactiveValues` object named `settings` with fixed keys such as `unique_id`, `date`, `admin1` through `admin4`, `village`, `lon`, `lat`, `hhh_sex`, `hhh_age`, `hh_size`, `residency`, `childU5`, `v_score`, `v_groups`, `eligibility`, etc.

### Reactive patterns

- The master dataset is held in `uploaded_df <- reactiveVal(NULL)`.
- Filtered views (`filtered_data`, `dq_filtered_data`) are `reactive({...})` and depend on `uploaded_df()` plus filter inputs.
- Shared, expensive computations are cached in dedicated reactives (for example, `shared_gap_analysis()` for missing-data charts) to avoid recomputation.
- `isolate()` is used in a few places to avoid reactive cascades when reading `uploaded_df()` inside data-quality reactives.

### UI theming

The visual layer is token-driven and lives in two stylesheets under `inst/app/www/`, both auto-bundled by Golem's `bundle_resources()` (loaded alphabetically, so `wfp-ui.css` overrides `custom.css`):

- **`custom.css`** — base helpers (scrollbars, picker sizing, the WFP loader animation).
- **`wfp-ui.css`** — the soft-modern refresh + the **design-token system**. Defines `:root` variables (`--wfp-blue`, `--card-radius`, `--shadow-soft`, `--surface`, `--border`, accent tints, …) and a `[data-bs-theme="dark"]` block that re-points those variables, so the whole app flips consistently between light and dark. Styling for cards, value-boxes, buttons, sidebar, navbar, DataTables, modals, notifications, and the waiter all reference tokens. **When adding UI, prefer tokens over hardcoded hexes.**

**One theme, two modes** (wired in `app_server.R` via `wfp_theme(dark)`):
- The **dark-mode toggle** (`bslib::input_dark_mode(id = "dark_mode", mode = "light")`) flips between WFP-light and **WFP-dark** (dark surfaces `#0e1422`/`#1b2333`). The app always opens in light mode, whatever the OS preference. bslib reports the mode as the **string** `"light"`/`"dark"`, not a logical.
- `thematic::thematic_shiny()` re-themes plotly/ggplot on every swap — so **do not hardcode text/tick colors in chart code**; leave them unset and thematic supplies theme-aware values. Gridlines use the neutral `rgba(128,128,128,0.2)` so they read on both light and dark surfaces.
- App font is **Commissioner** (`bslib::font_google("Commissioner")` in both `app_ui.R` and the `wfp_theme()` factory, plus a Google Fonts `@import` in `wfp-ui.css` for Bootswatch presets). It is set in four places that must stay in sync: the `app_ui.R` theme, both branches of `wfp_theme()`, the CSS `@import` + font stacks, and the plotly font in `wfp_plotly()`.

**Style guidelines for new code (the look is deliberately restrained — accent is reserved for icons, active states and the one primary action per view):**
- Card headers are quiet section labels (small uppercase, muted, hairline divider) — never pass `bg-*`/`text-white` classes to `card_header()`; the stylesheet neutralises them anyway. A leading `bsicons::bs_icon()` in a header picks up the brand blue automatically.
- Value boxes: rely on the global `.bslib-value-box` token styling; pass `theme = "primary|info|success|warning|danger|secondary|dark"` to tint the **icon chip** (the surface itself stays neutral) — don't add inline bg/shadow classes. A widget used as `showcase` is capped at 64px high so it can't stretch the KPI row.
- Buttons: one solid `btn-primary` per view for the main action; exports, deselect, cancel and other secondary actions use `btn-outline-primary` / `btn-outline-secondary` (rendered neutral grey, not amber); destructive actions use `btn-outline-danger`. `radioGroupButtons` toggles use `status = "outline-primary"`. The navbar session toolbar is styled uniformly by `.session-toolbar` regardless of the button classes.
- Tall panels (Overview, DQ, Spot Checking, Ben. Selection) use `layout_sidebar(fillable = FALSE)` so the page scrolls; in a fill container a row like the map/summary pair collapses to zero height once the content below it grows. A panel without a sidebar (Targeting Monitoring) wraps its content in a fill-item `div.wfp-scroll-page` that scrolls itself. Sidebar content scrolls on its own (`.sidebar-content` is height-bounded in `wfp-ui.css`), because `.sidebar` is `overflow: visible` so menus are not clipped.
- Selectize lists are capped at 1,000 options by default; `dropdowns.js` lifts that cap on every instance, so wide MODA forms list all their columns. Group picker choices with `col_choice_groups()` (a one-column group otherwise renders as a single option labelled with the group name).
- The app opens in the OS default browser (`open_in_default_browser()` in `run_app.R`), not the IDE viewer.
- **Exports are read-only**: write every workbook with `save_workbook_readonly()` (or `write_xlsx_readonly()` for a single table), never `openxlsx::saveWorkbook()` directly, and do not add CSV downloads (a CSV cannot be protected). `TARGETWISE_EXPORT_PASSWORD` sets the unlock password. The selection export can split into one workbook per area, zipped (`zip::zipr`, names from `area_file_suffix()`); its audit-trail sheet is opt-in.
- **Version**: stays at 1.0.0 until the maintainer says otherwise.
- **Charts**: every plotly output is rendered with `render_wfp_plotly()` (not `plotly::renderPlotly()`), which pipes the chart through `wfp_plotly()` — Commissioner font, token colorway, transparent surfaces, neutral gridlines, dark hover labels, no modebar. It only fills layout keys the chart hasn't set, so per-chart margins/axes still win; don't repeat `paper_bgcolor`/`config(displayModeBar)` boilerplate in new charts.
- **Loading feedback**: there is deliberately no whole-page `waiter_on_busy()`. Shiny's `.recalculating` class drives a per-output fade + ring spinner from `wfp-ui.css`; reserve `waiter_show()` / `Waiter$new()` for operations that block the session (imports, setup validation, session save/load, data corrections, reset). Analyses that need a user action first show `empty_state(title, subtitle, icon)` via a `uiOutput` until they have run (see Duplicates / Missing Data).
- Chart colors: use WFP token hexes (`#0A6EB4`, `#f7b825`, `#26bde2`, `#3f7e44`, `#c5192d`) rather than the legacy Solarized palette (`#2aa198`, `#586e75`, …) — the Solarized colors were migrated out of the Overview charts; keep them out.
- DataTables: the global `.dataTable` rules already handle font size, header styling, and theme-aware row hover — you generally don't need per-table `formatStyle(fontSize=...)`. If you *do* set a `backgroundColor` band, pin an explicit `color` alongside it: the tints are fixed in both themes, so text left to inherit becomes near-white-on-pale in dark mode.
- **`bsicons::bs_icon()` takes Bootstrap Icons names, `shiny::icon()` takes Font Awesome names — and mixing them fails loudly but invisibly.** A wrong name makes `bs_icon()` throw, which renders as `Error: [object Object]` in a value box, or kills the whole `showModal()` call so a button silently does nothing. Three of these were live in the codebase at once (`arrow-right-to-bracket`, `arrow-right-from-bracket`, `scale-balanced`, `wand-magic-sparkles` — all Font Awesome). Validate names against the real package rather than by eye; the scan that catches every call site is:
  ```r
  got <- regmatches(txt, gregexpr('bs_icon[(][ ]*"[^"]+"', txt))  # over R/*.R
  tryCatch(bsicons::bs_icon(nm), error = function(e) "INVALID")
  ```
- **Namespace every input you build inside a module** — including ones generated in a `lapply()` inside a modal or `renderUI`. `textInput(paste0("edit_", col), …)` looks fine and is silently unreachable: the input lands outside the module, `input[["edit_<col>"]]` reads `NULL`, and a `%||% ""` fallback then writes an empty string over real data. Same trap for `actionButton()` — the observer simply never fires. Always `ns(...)`.
- **Never filter rows with a bare comparison**: `df[x >= lo & x <= hi, ]` turns every `NA` in `x` into a whole row of `NA`s in the result, which then flows into KPIs, charts and exports as phantom records. Wrap the condition in `which()` (or use `filter_by_date_range()` for dates).

### Large-data considerations

- The app explicitly targets 1 GB+ datasets and keeps the full data frame in memory.
- Vectorized base R / dplyr is preferred over row-wise operations.
- **Import formats**: `.xlsx/.xls` (readxl — slowest, XML), `.sav/.dta` (haven), `.csv` (`data.table::fread`, multi-threaded) and `.parquet` (`nanoparquet`, columnar, 5–10× smaller uploads). All go through `read_import_file()` in `mod_file_import.R`.
- **MODA paging**: `MODA_PAGE_SIZE` (1,000; ONA caps at 10,000) — never go back to tiny pages, a 20k-row form at `page_size = 10` was ~2,000 sequential round-trips and the 10,000-page loop guard silently truncated forms above 100k rows. Re-sync is incremental: `moda_incremental_query()` adds an ONA `query` filter on the newest `_submission_time` already in memory, and the `_id`/`_uuid` diff remains as a safety net.
- **Never build an n × p temporary**: the import summary computes missingness with a single running row mask (one column at a time) and skips the full-row `duplicated(df)` above 50k rows (it took 38 s at 174k rows) — the DQ Duplicates tab covers that on user-chosen keys.
- **Autosave is gated**: it only fires once there is something worth saving (a mapping or an audit-log entry) and is skipped when the dataset exceeds `autosave_max_bytes()` (200 MB, override with `TARGETWISE_AUTOSAVE_MAX_MB`); the user is told once to use Session › Save. Session files are written with `compress = FALSE` because the sodium ciphertext is incompressible — gzip dominated a 20 s save.
- Charts and tables are often limited (for example, top 50 locations, top 15 missing-data combinations) to keep rendering fast.
- `waiter::autoWaiter()` and `waiter::waiterPreloader()` provide loading feedback for long-running outputs.

---

## Security and Data Handling

- **Local / in-memory processing**: uploaded data is read into the R session memory and mutated reactively. The only external storage is the encrypted session files described below.
- **No secrets in repository**: MODA API tokens are entered at runtime via a password input and are never persisted — `save_session()` explicitly nulls the token before the credentials are encrypted and written.
- **Session persistence** (`R/utils_session.R`): session `.rds` files are encrypted with `sodium`. The encryption key is derived in one of two ways:
  - If `TARGETWISE_SESSION_PASSPHRASE` is set, the key is derived from it (portable across machines that share the passphrase).
  - Otherwise a **per-install random key** (`sodium::keygen()`) is generated on first use and stored under `tools::R_user_dir("TargetWise", "data")/session.key`. Sessions then only decrypt on the machine that created them.
  - `TARGETWISE_SESSION_DIR` overrides the storage location (useful for tests / ephemeral hosts).
- **Audit logging**: data-quality edits, deletions, location-name normalizations, and outlier corrections are appended to a reactive `modification_log` and can be exported to Excel/CSV.
- **File upload limits**: `shiny.maxRequestSize` is set to 2 GB in both `app.R` and `dev/run_dev.R`; the import module enforces the same 2 GB cap.
- **Note on Node dependencies**: `package.json` contains `@supabase/supabase-js` and `dotenv`, but no R code references them and no Node runtime is part of the build. Treat these as unused unless a future feature wires them in.

---

## Deployment Notes

- Primary target is **Posit Connect** (`connect.posit.cloud`), as evidenced by `manifest.json`, `rsconnect/` deployment records, and `dev/03_deploy.R`.
- `dev/03_deploy.R` also lists Docker, ShinyProxy, ShinyApps.io, and Shiny Server options via Golem helpers, but these have not been generated in the repository.
- The deployment record `rsconnect/documents/app.R/connect.posit.cloud/bbbagoa/TargetWise.dcf` points to an existing Posit Cloud content item.

---

## Common Tasks for Agents

### Make a module's work survive a saved session

Take `workspace` as a server argument and call `workspace_register(workspace, "<key>", snapshot = function() list(...), restore = function(s) ...)`. `snapshot` returns `NULL` when there is nothing to save. If loading the data resets the module's inputs (observers on `uploaded_df()`), apply the saved values inside `after_flush(session, ...)`. If input round trips through the browser would rebuild state (as in Targeting Design), guard the rebuilding observers the way `restoring()` does in `mod_scorecard.R`.

### Add a new dependency

1. Use `library(pkg)` or `pkg::fun()` in the code.
2. Run `attachment::att_amend_desc()` to update `DESCRIPTION`.
3. Run `renv::snapshot()` to update `renv.lock`.
4. Regenerate `manifest.json` with `rsconnect::writeManifest()` if deploying to Posit Connect.

### Add a new module

For a **top-level tab module**, use the Golem helper or follow the existing pattern:

```r
golem::add_module(name = "my_module", with_test = TRUE)
```

Then wire `mod_my_module_ui("my_module_1")` and `mod_my_module_server("my_module_1", ...)` into `app_ui.R` / `app_server.R`.

For a **new Data Quality sub-tab**, add `R/mod_dq_<name>.R` defining `dq_<name>_ui(ns)` and `dq_<name>_server(input, output, session, ns, core)` (alias the shared reactives from `core`, as the existing sub-tabs do), then add one line each to `mod_dq_ui` (`dq_<name>_ui(ns)`) and `mod_dq_server` (`dq_<name>_server(input, output, session, ns, core)`). No other wiring is needed.

### Add a helper function

Place reusable logic in `R/utils_helpers.R` or a new `R/utils_*.R` / `R/fct_*.R` file. Document with `roxygen2` and run `devtools::document()`.

### Update documentation

```r
devtools::document()
golem::document_and_reload()
```

### Regenerate the Posit Connect manifest

```r
rsconnect::writeManifest()
```

---

## Known Gaps and Placeholders

- **Test coverage is helper-focused**: unit tests exist for helpers, the targeting-analytic primitives, session crypto, the session manager, and the row-filter helpers, but there are no Shiny module / UI integration tests yet (`shinytest2` is not set up) and no CI — the suite only runs when someone runs it locally.
- **Setup mappings cannot be left blank**: every mandatory `selectInput` in `mod_setup.R` uses `choices = cols` with no empty placeholder, so when `find_guess()` returns `""` the input silently falls back to the dataset's *first column* and the missing-field validation can never fire. A field you never consciously mapped may be pointing at an arbitrary column.
- **Known heavy spots at 1 GB**: the spot-check search (`apply(df, 1, ...)` coerces the whole frame to a character matrix), fuzzy duplicate matching (`agrep` all-pairs, uncapped), `VIM::kNN` imputation over the full frame, and the profile/outlier charts which ship un-aggregated rows to the browser.
- **GPS check**: there is no dedicated GPS-check DQ sub-tab; GPS issues surface only implicitly (records with missing lon/lat are dropped from the map).
- **Choropleth has no shapefile**: the map's choropleth mode uses admin-centroid circle markers, not true polygons (intentional — avoids a shapefile/boundary dependency).
- **Node.js packages** (`package.json`) are declared but unused.

---

The README is the user-facing guide (install, launch, workflow, methods, configuration, deployment, citation). Keep it in sync with features; personal/contact details live only there and in DESCRIPTION, never in the app UI. R code must stay ASCII-only (use \u escapes in strings) so `R CMD check` stays clean.

*Last updated: 2026-09-23. This guide reflects the actual state of the repository (`boosted_ai` branch); if you restructure the project, please update this file accordingly.*
