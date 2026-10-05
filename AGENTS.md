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
│   ├── utils_diagrams.R        # model diagrams as SVG (app + report): tree, forest plot, network, importance, dendrogram
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
2. **Overview**: one screen (no page scroll). The `leafgl` map fills the left half; the right half keeps the data collection in view (weighted figures as tiles, households per day by Admin 1 with the cumulative line) and folds three sections below it, one open at a time: Who is in the data (profile tiles and charts from every mapped characteristic), Vulnerability (score, groups ordered by severity, eligibility, and the chosen indicator across household profiles) and Explore two variables (weighted cross-tab and correlations). With the "Follow the map" switch on (`input$view_follow`, off by default) the figures follow the map view (`ov_in_view()` on the debounced `input$map_plot_bounds`).
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
| `overview` | `R/mod_overview.R` + `R/utils_overview.R` | One-screen map + insights (shares as rings: tiles with `share` go through `ov_tiles_html()`, used by the page and the report; `contingency()` and the chart builder (`ov_var_kind()`, `ov_chart_types()`, `ov_cor_text()`) for Explore; the map's box-zoom control is `box_zoom_js`, added with `onRender`). The insights are pure functions (`ov_collection()`, `ov_profile()`, `ov_vulnerability()`, `ov_cross()`, `ov_group_order()`) shared with the Overview report (`write_overview_report()`, which covers the filters and the map view); unweighted on the page and in its report (`ov_setup()` drops the weight: registration data lists every household); silent about what is not mapped. |
| `dq` | `R/mod_dq.R` + `R/mod_dq_*.R` | Data Quality orchestrator: shared admin/date filter pipeline, the master `dq_filtered_data`, the Reset-to-original action, and delegation to six sub-tab modules. |
| `dq_*` sub-tabs | `R/mod_dq_spelling.R` … `R/mod_dq_enumerator.R` | One file per DQ sub-tab. Each defines a `*_ui(ns)` and a `*_server(input, output, session, ns, core)` called from inside the orchestrator's `moduleServer` body, so they share the parent namespace (no input-id churn). |
| `spot_checking` | `R/mod_spot_checking.R` | Sampled-record review for spot verification. |
| `ben_selection` | `R/mod_ben_selection.R` | Beneficiary selection by admin level + vulnerability-score range; weighted counts and selection export. |
| `audit` | `R/mod_audit.R` | Modification log table with Excel/CSV export. |
| `monitoring` | `R/mod_monitoring.R` | **Targeting Monitoring** (phase 3), three tabs: the PDM analysis (`mod_pdm`, nested, returns its data and results), targeting process (any number of datasets) and the monitoring report. Charts and tables come from `mod_chart_builder.R` (ready-made presets + free builder); one aggregation, `chart_aggregate()` in `R/utils_monitoring.R`, feeds the plotly preview, the table view (`chart_table()`) and the billboarder charts of `write_monitoring_report()`. Report items (title, comment, spec, data) and the officer's context / findings / recommendations are saved with the session. |
| `pdm` | `R/mod_pdm.R` | **Implementation errors** tab (post-targeting survey preferred, PDM least preferred). Step 0 draws the verification sample from Beneficiary Selection's current selection (`selection` passed from `mod_ben_selection_server()`'s `$frame` through `app_server` and `mod_monitoring_server`): `ptm_draw()` stratifies by area x selected / not selected (excluded by design left out), `ptm_sample_workbook()` exports it, `sample_design()` is saved with the Monitoring workspace. The survey is matched on the household ID (`ptm_matched()`: group and area from the list), weighted "from the sample design" (`ptm_population()` -> `pdm_stratum_weights()`), and judged per area by `ptm_area_decisions()` (proceed / review / pause before distribution; lessons for the next round after a PDM). Before this: Loads its own Post-Distribution Monitoring extract (file upload), maps an eligibility ground truth + a beneficiary flag, and reports weighted inclusion / exclusion error, coverage, precision & recall via `targeting_metrics()` plus `coverage_by_unit()`. Eligibility comes from a PDM column, or from the adopted scorecard / eligibility rules applied to the PDM answers (`pdm_scorecard_eligibility()`, `ruleset_eval()`; a missing criterion refuses the calculation). Weighting: population sizes overall or per area -> `pdm_stratum_weights()` (w = N / n per group; the PDM surveys set numbers of beneficiaries and non-beneficiaries), a weight column, or none. No non-beneficiaries surveyed -> exclusion error and coverage NA. |
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

**Targeting accuracy** is measured in Targeting Design (design errors) and Monitoring (PDM); Beneficiary Selection has no accuracy tab, and its report and Excel summary carry none (removed: comparing a list with a mapped eligibility column there did not make sense). The primitives below remain for Design and PDM. It activates **only when an eligibility column is mapped** (graceful no-op otherwise). The selection is compared against a binary eligibility ground-truth normalised by `eligibility_flag()` (yes/1/true/eligible/… vs no/0/false/ineligible/…; ambiguous values → NA):
- `targeting_metrics()` computes weighted **coverage rate, selection ratio, inclusion error, exclusion error, precision, recall**.
- `coverage_by_unit()` produces a per-admin-unit coverage table.
- Selection runs through `select_households()` (`R/utils_approach.R`): the **targeting approach** picker decides which layers apply (area / criteria / score / community), and **prioritisation** (total caseload or caseload per admin unit, most vulnerable first) cuts the eligible list. Households cut there are **excluded by design** (Advisory 2/2025): reported separately and never counted as exclusion error — accuracy diagnostics compare the *eligible-by-design* mask, and the extra exclusion caused by prioritisation is shown on its own.
- The selection export is an openxlsx workbook: `Selected` (prioritised rows + `selection_score`), `Excluded_by_design` (when prioritisation cut anyone) and `Selection_Metadata` (approach, prioritisation, filters, rules, totals, accuracy, notes).
- `reference/COMPLIANCE.md` maps each requirement from the WFP Targeting OGN (2021), the APP-FA advisories and UNHCR-WFP Joint Hub / ICRC-IFRC material to what the app does, with the open gaps. Update it when a gap closes.

**Targeting Design (`mod_scorecard.R`)** — a stepper across the page (data → Vulnerability Framework → Criteria → model → threshold) shows what is done and the next action. Step 2 *Criteria* is one table (`output$criteria_table`, Use first): every yes/no variable of the data (`eligible_criteria()`, which excludes outcome indicators and `unobservable_reason()` columns) with its shares, the quick-screening test (`screen_criteria()`, run by itself and again when its settings change), its strongest overlap and missing answers. `run_qs()` sets the Use ticks: associated variables minus `drop_collinear()`'s suggestions (`corr_suggest()`). It runs by itself only when the candidate set changes; settings wait for **Run the tests** (`qs_params()` vs `qs_now()` drives the stale notice). **Binarise variables** is the calculator's bulk binarise (`mod_var_calc_bulk_ui()`; `mod_var_calc_server(outcome =)` adds the *best split for vulnerability* method: `screen_variables()` on the selected columns or, with "Screen the entire database", every column that is not yes/no; `screen_new_name(suffix = "_Bin")`, names made valid with `make.names()`), so the suggestions no longer run on the page; **Correlations** opens a dialog that asks the threshold first (`corr_request()`), then shows only the groups above it (`correlated_groups()`: pairs, union-find groups, `drop_collinear()` proposal) and removes the ticked from Use; the design report lists the same pairs (`corr_pairs`). The search box filters the rows in the browser (`twFilterRows()`, name and label cell only). Continue (`nav_next_screening`, also the flow bar's Continue) sends the ticked criteria to `criteria_sel()` = `ready_criteria()`, which feeds the model (`fit_criteria`); sessions from before the single table map `inputs$criteria` and step "criteria" onto it. There is no per-criterion community-validation tick any more (`review()` keeps what older sessions recorded). Step 3 (one settings band: model, criteria and data, comparison, then Fit) fits logistic, stepwise, weight-of-evidence or boosted-stump models, the PCA / LDA vulnerability indices (`index_effects()`: additive, oriented by the outcome, weights scaled to a maximum of 10, scheme forced to "coefficient", diagnostics in `fit$index`, left out of `model_effects()`), or machine-learning models (random forest, XGBoost, naive Bayes, neural network, SVM) whose points are average marginal effects (all additive, `R/utils_models.R`), keeps a run history with restore, compares the models chosen in "Models to compare" by AUC/ROC (`compare_models_auc()`, from the fits `model_effects()` made, dropped in the worker; `benchmark_models()` is no longer called), and shows estimates (editable points + review flags in one table, with the other compared models' effects per criterion, RF importance and an "Agree" sign check in the same rows: `coefficients_html(others =, importance =)`, `EFFECT_LABELS`) and the model comparison with the run history in one table (`comparison_html(tab, runs = run_rows())`), half width beside the held-out ROC; PMT and ranking fits keep `runs_ui`. Step 4 defaults the threshold to `balanced_threshold()` (minimises the larger of the two design errors), shows the error rates as tolerance tracks and the design matrix as a report table. **Design report (HTML)** in the sidebar writes one self-contained HTML file: the Markdown record converted with `commonmark`; the charts are billboarder widgets (`R/utils_report_plots.R`) whose JS/CSS `report_inline_deps()` inlines, laid out two per row where paired, so the file works offline (`R/utils_report.R`). The verdict on the Threshold and PDM tabs is `verdict_card()`: a status panel (household icon in the verdict colour, status badge, the Advisory's wording, the two errors against the tolerance via `errors` / `tolerance`, `stage = "implementation"` on PDM); it fades in only when the verdict changes. Loader: one waiter card for the whole app (`www/busy.js`), with a console fed by `waiter_log()` / `tw_step()` and the panels being redrawn.

**Variable calculator (`R/mod_var_calc.R`, `R/utils_calc.R`)** — on the registration import panel and the Targeting Design data card: yes/no variables from conditions, numeric ones from formulas. Formulas are parsed and checked against the column names and a whitelist of functions before they run — never widen that list to anything that reaches the file system, the network or the environment. Registration columns created this way are logged to the audit trail. An **R code** mode (`calc_code()`) runs a pasted multi-line block with local variables, `x[cond] <- v` and `if/else`; `calc_check_code()` walks it against `calc_code_functions()` (no loops, no `function`, no `$`/`::`, no eval/get/do.call) and assignments land in a scratch environment, never in the data. Python is deliberately not supported: it would need reticulate and cannot be sandboxed the same way.

**Distribution & correlation (`mod_overview.R`)** — a weighted cross-tabulation explorer with a chi-square p-value (`weighted_crosstab()`) and a weighted correlation matrix heatmap (`weighted_cor_matrix()`), in the Overview's "Explore two variables" section. `create_profile_plot()` (weight-aware boxplots / bars, a plain distribution without a view column) stays for other uses.

**Outlier detection (`mod_dq_outliers.R`, `R/utils_outliers.R`)** — any numeric column (`quantitative_cols()`: numeric, or text/factor whose answers parse as numbers), mapped fields first. Three methods with method-appropriate thresholds: **IQR** (Tukey multiplier, default 1.5), **Z-score** (default 3 SD), and **modified Z-score / MAD** (default 3.5, the Iglewicz–Hoaglin cut-off), or "allowed range only". An **allowed range** per variable (suggested for hh_size / hhh_age / childU5, remembered per variable in the session) flags impossible values whatever the distribution; the effective limits are the tighter of the two. The *Most extreme values* tab has insight tiles (direction, most extreme, concentration on an enumerator or area, repeated 99-style codes via `sentinel_codes()`) and a selectable table: correct selected, set a value, or **mark as verified** (logged as "Outlier verified (kept)" and read back by `verified_uids()`, so they stop being flagged). *All numeric variables* audits every numeric column at once (`numeric_audit()`). Corrections: cap at the limits / set to missing / median / mean / **KNN via `VIM::kNN`** / drop, each previewed before/after, with a reason, logged per value.

**Duplicates (`mod_dq_duplicates.R`)** — groups shown as DT RowGroup bands, with the columns that differ inside each group (`duplicate_group_diffs()`, one vectorised pass per column; skipped above 50k duplicated rows) and exact copies marked. Rows are selectable (all but the first of each group, exact copies), a Compare modal shows a group side by side with differing fields first, and deletion (from the table or the modal) finds rows back by id AND content, so one of two records sharing an id is removed, logged as "Duplicate deletion".

**Data-quality flags** — `enumerator_flags()` flags an enumerator ("Review") when their mean interview duration is outside the cohort IQR fences, their missingness exceeds cohort mean + 2 SD, or (date mapped) one day's interviews exceed the team's Q3 + 1.5 IQR of enumerator-days; each flag carries its reason in words, shown on the *Flagged enumerators* tab with their interviews one click away. The column-health table adds a colored `Status` band (OK ≥95% / Review 90–95% / At risk <90%). Missingness is now **weight-aware** and uses a unified definition (NA / `""` / `"NULL"`) across the missing-data and enumerator modules.

**Map (`mod_overview.R`)** — points only (per-row WebGL via `leafgl`); the "Colour by" picker recolours them in place through `leafletProxy` (`add_map_points()`), keeping the view; a resize redraws the WebGL points (leafgl wipes them otherwise). Basemaps come from `add_esri_bases()` (`BASE_GROUPS`, also the report maps): satellite tiles use `?blankTile=false`, so a missing tile is a 404, and `ESRI_FALLBACK_JS` then lowers that layer's `maxNativeZoom` and calls `_resetView()` (not `redraw()`, which keeps the tile zoom) so Leaflet enlarges the deepest real imagery.

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
7. Sessions are split by workstream (`session_kinds()`: design / selection / monitoring): `workstream_state()` picks each one's part (workspace keys by `workstream_of()`, audit entries by phase via `log_for()`, Selection alone carries `uploaded_df` / MODA / the full `user_setup`; Design and Monitoring carry `scorecard`, `rules`, `country_office`), saved as `<name>.<kind>.rds` (`session_stem()`); a load merges its audit entries back with `log_merge()` and leaves the other workstreams in memory. Older files without a suffix hold everything (kind "all"). `save_session()` stores data frames of 1,000+ rows as Parquet (`pack_frames()` / `unpack_frames()`, column attributes kept). A new module's work belongs to Selection unless `workstream_of()` says otherwise. Session state (`uploaded_df`, the pristine `original_df` when it differs from it (Reset baseline), `user_setup`, `modification_log`, theme, MODA credentials minus token, and the **workspace**: each module's work registered with `workspace_register(workspace, key, snapshot, restore)`: Targeting Design, Ben. Selection, Spot Checking, PDM) is encrypted and persisted to the user data directory via `utils_session.R`; the session manager offers restore-on-startup, manual save/load/clear, and debounced autosave.

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
- Selectize lists are capped at 1,000 options by default; `dropdowns.js` lifts that cap on every instance and moves the menu to the body, including after `updateSelectInput(choices=)` rebuilds it (`shiny:updateinput`), so wide MODA forms list all their columns. Group picker choices with `col_choice_groups()` (a one-column group otherwise renders as a single option labelled with the group name).
- The app opens in the OS default browser (`open_in_default_browser()` in `run_app.R`), not the IDE viewer.
- **Exports are read-only**: write every workbook with `save_workbook_readonly()` (or `write_xlsx_readonly()` for a single table), never `openxlsx::saveWorkbook()` directly, and do not add CSV downloads (a CSV cannot be protected). `TARGETWISE_EXPORT_PASSWORD` sets the unlock password. The selection export can split into one workbook per area, zipped (`zip::zipr`, names from `area_file_suffix()`); its audit-trail sheet is opt-in.
- **Version**: stays at 1.0.0 until the maintainer says otherwise.
- **Settings wait for their button**: a parameter input (select, picker, numeric, slider, checkbox, text) must not trigger a computation by itself. Keep what it drives in a `reactiveVal` set by the go-ahead button (`fw_applied`, `pmt_applied`, `thr_applied` / `tol_applied`, `map_set`, `ol_applied`, `name_cols`, `norm_level`, Selection's `applied`), read that value downstream, and show a small note when the inputs differ from what is applied. Pure display toggles (a chart's Total / By area, a picker that only switches between views already computed) may stay live. **Exception: chart builders** (Monitoring `mod_chart_builder.R`, Overview chart and table builders) update live as fields change, with axis bounds in an Axes dialog (`axis_button()` / `axis_dialog()` / `axis_read()` in `R/utils_overview.R`; blank = automatic, `chart_axis_range()` / `axis_bounds()`; plotly.js 2.25 has no `autorangeoptions`, so a blank end comes from the data). `tests/testthat/test-gating.R` pins the Targeting Design ones.
- **Prerequisites**: never let a button do nothing. Start handlers with `need_ok(condition, "what is missing")` instead of a bare `req()`, and freeze key buttons with `gate_button(id, ok, reason)` inside an `observe()` (`www/gates.js`: greyed out, reason on hover and as a notice on click). `mod_scorecard.R` has its own local `gate()` for its step gates; do not name helpers `gate`.
- **Areas covered** (`R/mod_area_scope.R`): the area pickers are a scope, not a targeting layer. Selection filters its data by the mapped admin levels before `select_households()` (which gets `area = list()`); Design, PDM and targeting process use `mod_area_scope` on any column. Modules keep the whole data (`full_df`, `assessment_all`, `pdm_all`) and read the covered part through a getter/setter (`assessment_df()` reads scoped, `assessment_df(x)` stores whole); sessions and the variable calculator use the whole data. Reports print `areas_covered_text()` / `scope_text()`.
- **No outcome indicator** (`input$framework_mode == "none"`, `no_outcome()` in `mod_scorecard.R`): `outcome_binary()` stops (req), the candidate table has no test columns, the model list is `unsupervised_model_choices()` and fits go through `fit_unsupervised()` (`R/utils_unsupervised.R`: counting, PCA via `index_effects()` with the anchor as `.y`, `mca_effects()`, `lca_fit()` / k-means / Ward via `cluster_assign()`, `profile_points()` LDA surrogate with `index$fidelity`). The fit object has the supervised shape plus `unsupervised = TRUE`, so scoring, adoption and Selection are unchanged. Threshold: `unsupervised_start_threshold()`, `selection_stability()` (in `stability_job`). UI parts that need an outcome are wrapped in `with_outcome()` / `without_outcome()` in `mod_scorecard_ui()`; the Excel export writes "not measured: no outcome indicator" for the error fields. `model_label()` names a method from either list.
- **Proxy means test** (validated setup in `pmt_applied()`: `pmt_pc()` / `pmt_line_value()` read it, never the inputs, and the Validate button `pmt_validate` sets it; models `pmt_model_choices()` via `pmt_estimate()`: OLS, `qr_irls()`, `pen_fit()` ridge / lasso, `pmt_ml_effects()` random forest / XGBoost; accuracy `pmt_accuracy()` (leakage, under-coverage, coverage, accuracy, differential, CGH), charts from `fit$pmt$eval` via `pmt_error_curve()` / `pmt_decile_coverage()`; compared models in `bench()` with `pmt = TRUE`. PMT wording: `W()` on the page, and `options(tw.terms = "pmt")` around a report or workbook, which `i18n_lookup()` / `i18n_translate_block()` apply through `tw_terms()` / `pmt_wording()`; `input$framework_mode == "pmt"`, `pmt()` in `mod_scorecard.R`, `R/utils_pmt.R`): the outcome is being poor (`outcome_binary()` = `pmt_poor(pmt_pc(), pmt_line_value())`); use `oc()` / `opos()` for the outcome column and level, never `input$outcome_col`, and `framework_ready()` for the step-1 gate. UI parts only for a binary outcome or only for PMT go in `binary_only()` / `pmt_only()`. Fits go through `design_fit_job(a$pmt)` -> `fit_pmt()` (OLS or `qr_irls()`); weights carry `type` ("binary"/"numeric") and `mean` (value for a missing number), and points = 100 x |coefficient|. Cards have `kind = "pmt"` and `sc$pmt` (intercept, line); `apply_scorecard()` scores numeric items per unit and never floors a PMT score, so the threshold slider starts at `score_min()`. The workbook's `Type` / `Value if missing` columns and the Design fields `PMT intercept` / `Poverty line (per person)` round-trip it (`is_pmt()`).
- **Rankings downstream**: the card carries `kind = "ranking"` (`is_ranking()` also reads an Outcome starting with "none" from a workbook); `card_word()` names it. Reports branch on `x$no_outcome` (`report_rank_cards()`, `ranking_report_methods()`, `ranking_report_plots()`); PDM's "Calibrate the ranking" tab uses `ranking_calibration()` on `pdm_scorecard_eligibility()$score`. Validity helpers: `silhouette_mean()`, `lca_entropy()`, `profile_quality()` (in `profile_quality_job`), `selection_insights()`.
- **Model settings** live in `model_params` (reactiveValues in `mod_scorecard.R`: `pca_mode`, `pca_axes`, `pca_min_var`, `n_clusters`, `holdout_pct`, `split_seed`), set only through the settings dialog (`params_apply`); fits read them, never the dialog's inputs. Tests set the dialog inputs then `params_apply`.
- **The page is cached** per R process (`app_ui()` / `app_ui_build()`); anything request-dependent must not go into the page build.
- **Machine-learning training** goes through `ml_fit_predict(method, m, y, w, params)` (fit and cross-validation alike); `ml_effects(params =)` turns it into additive points. `tune_ml()` runs k-fold CV over `ml_grid()` (tunable: `tunable_models()`) when `fit_scorecard_advanced(tune = TRUE)`; the result is `fit$tuning`. The tree's rules are `fit$tree_rules` (`tree_rules()`). rpart is in Suggests: run renv::snapshot() and rsconnect::writeManifest() before deploying.
- **A ranking in Selection**: adoption stores `sc$ranking` (label, method, orientation, stability, alpha, profiles, target); `ranking_columns()` adds `priority_rank`, `deprivations`, `ranking_profile` to the selection export, and the Composition tab's `ranking_comp` charts use `ranking_view()`. Mode-dependent labels inside buttons use `with_outcome()` / `without_outcome()`; `wfp-ui.css` keeps them inline via `.shiny-conditional--shown`.
- **Ranking scores**: `apply_scorecard()` scores a ranking (`is_ranking()`) as the points of every criterion met in the vulnerable direction (exclusion criteria score when NOT met), no floor; build ranking cards with `build_scorecard(kind = "ranking")` wherever the score is read. The no-outcome "tree" method is k-means profiles described by `rpart` (`index$rules`, `fit$tree_rules`).
- **Blocked columns** are `blockers()` minus `allowed_blocked()` (overridable: the rule-based blocks, `overridable()`); overrides are audited, saved with the session and reported (`x$allowed_blocked`).
- **Variable mapping** (`R/utils_mapping.R`, `mod_setup.R`): the fields are `SETUP_FIELDS` (label, group, kind, synonyms in EN/FR/ES/PT, `std` for value standardisation); only `unique_id` and `admin1` are required and every field has an empty "Not in my data" choice. `guess_mapping()` scores names and labels (`name_score()`, whole words, `SYN_WEAK` generic words) and content (`content_score()`). Save runs `mapping_checks()` (block: id missing/repeated, area levels not from the top; the rest warn), then a review modal: `recode_suggest()` per standardised field (inputs `rc_<field>_<i>`), date format (`parse_dates()`), age from a date of birth, checks and `data_readiness()`. Confirm applies `apply_setup_plan()` (new `<col>_std` / `<col>_age` columns, the date column converted to Date in place) and sets `settings$source_map`, `setup_plan`, `recode_maps`, `checks`, `readiness`; `app_server` audits every confirmed setup (`setup_result$saved()`) and applies the plan to the Reset baseline. Outputs that need a field call `need_mapped(user_setup, key)` (a validate() message, `short = TRUE` in value boxes) rather than a bare `req()`. A new feature that needs a field: add it to `READINESS_FEATURES`. Profiles carry `recodes` and `country`; the country office's newest profile is applied when nothing is mapped yet.
- **Model diagrams** (`R/utils_diagrams.R`): `fit$diagram = list(kind, data)` from `model_diagram()` (logit forest, rpart tree, nnet network, ranger / xgboost importance) or, for Ward, `dendro_structure()` via `cluster_assign()`'s `dendro` attribute; `diagram_svg()` draws it in the `diagram_ui` card and the report's `@@DIAGRAM@@` block. SVGs scale to their container; `pick_layout()` chooses the orientation (tree top-down or left-to-right, network left-to-right or top-down) and one or two columns (forest, importance): the shortest on screen whose text stays readable. `model_params$diagram` switches it off (settings dialog, `diagram_models()`). SVM has no agreed diagram in many dimensions and gets none.
- **Large-data rendering**: group with `sum_by()` / data.table, not `tapply()` / `aggregate()` on 100k+ rows; judge columns on their distinct values (`looks_multiselect()`, number checks); the map sends popups only up to `MAP_POPUP_MAX` points (above, `input$map_plot_glify_click` builds the one clicked); the chart builder draws at most `GB_MAX_POINTS` points (scattergl) and box plots from server-side five numbers (`box_plot()`). Background jobs hand large tables back with `pack_frames()` (fread `IDate` is converted first). The waiter console shows worker steps and R messages: jobs run through `bg_call()` with a log file, and `waiter_log()` writes there when `getOption("tw.log_file")` is set.
- **Cores and answer patterns** (`R/utils_parallel.R`): pass `tw_cores()` to anything with threads (ranger `num.threads`, xgboost `nthread`); spread independent refits with `tw_lapply(X, FUN, big =)` (PSOCK workers load the installed package; falls back to `lapply`; draw random numbers before it so results do not depend on the cores; `TARGETWISE_PARALLEL=false` turns it off). Logistic fits on yes/no criteria run on `collapse_rows()` with `weights = .n` when every household counts the same; set `model$tw_n` to the number of households.
- **SVM speed**: no `probability = TRUE` (libsvm refits 5 times for it); Platt scaling is one logistic fit on the decision values. Training capped at 3,000 households, tuning at 2,000, effects on 2,000; `ml_effects()` scores each distinct answer pattern once in one call.
- **Full screen**: chart cards on the design page are `bslib::card(full_screen = TRUE, ...)` (the "Expand" corner button); give a new chart card the same, with the `plotlyOutput()` as a direct child of the card so it stretches when expanded.
- **Chart help**: every plotly chart on the design page has an entry in `CHART_HELP` (`R/utils_chart_help.R`: what it shows, how to read it) shown by `chart_help(id)` in its card header; `tests/testthat/test-chart-help.R` fails when a new chart has none.
- **PCA axes**: `index_effects(axes =, min_var =)` / `fit_scorecard_advanced(pca_axes =, pca_min_var =)`; `pca_variance()` previews the shares before fitting. Report sections for PCA/LDA come from `x$index` (+ `index_structure` for LDA) and `design_report_index_plots()`.
- **Adoption** (`adopt_scorecard()` -> `do_adopt()`): errors above the upper tolerance (`beyond_tolerance()`) need an explanation in a dialog (`exceed_note()`, saved with the session, in the report, the workbook and the audit trail); a band other than `TOL_DEFAULT` (5, 20) needs the rationale (`missing_steps()`).
- **Lost connection (local runs)**: `session$allowReconnect(TRUE)` only reconnects under Shiny Server or Connect; locally a closed socket ends the session. The session manager autosaves on `onSessionEnded`, sends `tw-saved-at` after each autosave, and `www/busy.js` replaces Shiny's grey overlay with a "connection lost" card and a Reload button (restore prompt next). It also holds a Web Lock so Chromium does not freeze the tab.
- **Timed autosave**: the Save dialog's "Autosave this session every 20 minutes" sets `periodic()` in `mod_session_manager.R` (full saves under the same name, `TARGETWISE_AUTOSAVE_EVERY_MIN`); loading another session turns it off.
- **Stepwise** is an option (`stepwise = "none"|"aic"|"bic"` in `fit_scorecard_advanced()`), applied before any model; on the page it is one dropdown, `input$stepwise` = "none"|"backward"|"forward"|"both" (the direction), plus `input$stepwise_ic` (AIC/BIC). Old sessions' `stepwise_on` / `stepwise_dir` and `method = "stepwise"` (logistic + backward AIC) are mapped on restore.
- **Loading feedback, downloads**: use `download_handler()` (not `downloadHandler()`); it tells `www/busy.js` when the file is ready, which hides "Preparing your file...". `busy.js` also shows "Working..." after 0.7 s of server work, and `tw-when-settled` lets the session restore keep its waiter until the page is idle. Shiny custom message handlers must take one argument, or registration fails silently.
- **Report texts** use `rich_text_input()` / `update_rich_text()` (`R/utils_richtext.R`, `www/richtext.js`), which return HTML. Put them in reports only through `rich_html()` (whitelist sanitiser, also escapes plain text from older sessions) as a raw block placeholder, and use `rich_text()` for Excel cells and audit reasons.
- **`conditionalPanel()` in a flex row**: a shown panel is `display: contents`, so its own `style`/`class` sizing is ignored (and a `d-flex` class on it overrides the hiding). Put the sizing on a div inside it (`.wfp-oneline` rows in Spot Checking).
- **Admin pickers** are chained with `cascade_pickers(session, input, ids, cols, data)` (`R/utils_helpers.R`); it owns every level's choices, so do not set them elsewhere.
- **Chart builder styles**: `spec$style` (`chart_styles()`, `chart_style()`), drawn by the plotly preview and `monitoring_item_chart()`; pies and donuts sum the split (`chart_pie_data()`).
- **MODA** can feed any dataset: put `mod_moda_import_ui(ns("moda"))` beside the file input and send `mod_moda_import_server("moda")$data()` through the same take-the-data function as the file (Design, PDM, targeting process do this).
- **New session** (session toolbar) saves, then reloads with `?fresh=1` (`tw-fresh` handler in `busy.js`), which skips the restore prompt.
- **Report charts**: category shares go through `rp_share_charts()` (up to three donuts on one row, bars for the rest); report maps call `fit_to_points()`. The data summary falls back to `socioeconomic_indicators()` when no vulnerability is mapped.
- **Monitoring templates** (`mod_monitoring.R`, `R/utils_monitoring_draft.R`): saved per user in app settings (`monitoring_templates`): `template_from_items(keep_comments =)` (charts without data, the officer's comments), `t$texts` (context, findings, recommendations), `t$rounds` (`monitoring_round()`). Shared as JSON only (`template_json()` / `read_template_json()`, format "TargetWise monitoring template"), never as an R object. `items_from_template()` redraws each chart on the dataset of the same name, else the first loaded dataset where its columns exist; the rest are reported as skipped.
- **Reports**: the selection report is `write_selection_report()` (`R/utils_selection_report.R`, map via leaflet, points capped at 20,000); its sections come from the same `selection_sections()` as the Excel summary. Monitoring report items carry `width` ("half" pairs two consecutive items into one `.pair` block); order and width are edited by drag and drop (`www/sortable.js`). Chart specs support `type = "crosstab"` with `pct` (row/col/total/count) and `crosstab_test()` (chi-square, Cramer's V).
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
- **Labels**: variable/value labels live in the session dictionary (`register_labels()`, `var_label()`, `variables_table()`, `R/utils_labels.R`), not only on column attributes (lost at the first row filter). Every new import path must call `register_labels(df)`. `www/labels.js` decorates pickers and table headers in the browser; `save_workbook_readonly()` adds the Variables sheet by itself. SPSS/Stata go through `labelled_to_plain()`, never `haven::as_factor()` on the whole frame.
- **Area levels**: offer only mapped levels. `cascade_pickers()` hides the picker of an unmapped level (`tw-input-visible` message, `www/stepsummary.js`); level pickers use `mapped_level_choices()`. Builders offer `analysis_cols()` (no identifiers, names, phone numbers, free text).
- **Accordions open one section at a time** everywhere (`side_steps()` names its first section open; `multiple = FALSE` with a single `open`, bslib refuses several). A folded section says what it holds in its header (`www/stepsummary.js`: choices of its selects and text inputs, "k of n set" for groups of plain selects). Keep the page's main action out of the folding sections (`side_actions()`), as Targeting Design does with "Use this scorecard".
- **Sidebars**: build them with `side_steps(side_step("1. Title", "icon", ...), ...)` and `side_actions(...)` for the buttons, on `bslib::sidebar(class = "wfp-side")` (no sidebar title): the same numbered, folding sections everywhere.
- **Background tasks**: `bg_run(label, job, args, on_done, on_error)` (`R/utils_background.R`) runs a top-level job function (e.g. `design_fit_job`, `import_job`) in one warm `callr::r_session` per browser session; the waiter gets a cross (`waiter_content(cancel_id =)`) that kills it. Jobs run in the worker as `TargetWise:::<job>(args)`, i.e. from the INSTALLED package; send only the columns needed. Outside a running app (tests) or with `TARGETWISE_BACKGROUND=false` they run inline. shinytest2 apps also load the installed package: install before a browser check.
- **Fuzzy matching**: `fuzzy_match_groups()` is sorted-neighbourhood + `stringdist` (never all pairs). Monitoring drafts only put complaints / community presets on data that looks like it (`draft_topic_ok()`).
- **Numbers**: convert with `as_number(x)`, never `as.numeric(as.character(x))` (0.2 s per call on 100k numeric rows; `as_number` skips the text round trip for numeric columns). `run_app()` turns the JIT compiler off while the app runs (it spent ~9 s compiling the server closures); the package is byte-compiled at install.
- **Too many options**: a variable drawn as categories (map colours, table / chart builders, monitoring charts) goes through `too_many_options(x, label)` (`MAX_OPTIONS` = 30, `R/utils_overview.R`) and is refused with its message, never lumped or drawn with dozens of colours.
- **Updates and caches** (`R/zzz.R`): `.onLoad` records the installation's `Built` stamp (`tw_state$built`); `run_app()` stops when `tw_updated_since_load()` (the package was reinstalled under the session), and `bundle_resources(version = tw_resource_version())` serves www/ under the package version plus the build time, so browsers never reuse a previous installation's CSS/JS while the version stays 1.0.0.
- **Never filter rows with a bare comparison**: `df[x >= lo & x <= hi, ]` turns every `NA` in `x` into a whole row of `NA`s in the result, which then flows into KPIs, charts and exports as phantom records. Wrap the condition in `which()` (or use `filter_by_date_range()` for dates).

### Large-data considerations

- The app explicitly targets 1 GB+ datasets and keeps the full data frame in memory.
- Vectorized base R / dplyr is preferred over row-wise operations.
- **Text encoding**: every file import ends in `utf8_frame()` (`R/mod_file_import.R`): values that are not valid UTF-8 are read as Windows-1252 and converted, the rest marked UTF-8, factor levels and names included, BOM stripped. API text is marked UTF-8 after `rawToChar()`. Any new reader must go through `read_import_file()` or `utf8_frame()`. `tests/testthat/test-encoding.R` round-trips every format.
- **Import formats**: `.xlsx/.xls` (readxl — slowest, XML), `.sav/.dta` (haven), `.csv` (`data.table::fread`, multi-threaded) and `.parquet` (`nanoparquet`, columnar, 5–10× smaller uploads). All go through `read_import_file()` in `mod_file_import.R`.
- **Collected-form data** (`R/utils_collected_data.R`): `harmonize_pages()` flattens list columns first (`list_column_kinds()` decides geo / table / text over all pages), `apply_odk_labels()` splits select_multiple questions into `<question>_<choice>` Yes/No columns (`import_yes_no()`: Oui/Non in French) (`split_multiple()`, from the XLSForm's `attr(label_map, "multiple")`), `split_multiselect()` (called by `read_import_file()` and every form-server path) splits the others it recognises (`looks_multiselect()`) and relabels already-split export columns, and `split_geopoints()` splits GPS text (decimals required) into `_latitude`/`_longitude`/`_altitude`/`_precision`. MODA checks the form first (`moda_form_info()`) and confirms before downloading.
- **Loader progress**: update a shown waiter with `waiter_progress(session, message, percent, subtitle)` (in place, `tw-wait-progress` in `busy.js`), not `w$update(html = ...)`, which redraws it and flickers.
- **App settings** (country office): `app_setting_get()` / `app_setting_set()` in `R/utils_session.R`, stored in `app.settings` (never a `.rds` name: sessions are `<name>.rds` in the same folder and a session named "settings" used to overwrite them).
- **API keys**: `api_key_get(session, provider)` / `api_key_set()` (`R/utils_moda_fetch.R`) keep the first key typed in the browser session (root `userData`, memory only) and prefill every key field; never persist them.
- **MODA download engine**: `moda_fetch_pages()` (`R/utils_moda_fetch.R`) is the only MODA page loop (import and re-sync): gzip, page 1 alone then 4 pages in flight, stall-based timeout (`low_speed_limit`), retries with backoff on network errors / 429 / 5xx, cancel. Its callbacks run from `later()`; the engine calls them inside the caller's reactive domain, isolated, and turns an error in them into a failed download (an uncaught error in a `later()` callback stops the whole app). curl's `fail` callback gets a classed string, not a condition: read it with `curl_error_text()`, never `conditionMessage()`. Tested against a local httpuv server in `tests/testthat/test-moda-fetch.R`.
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
- **Known heavy spots at 1 GB**: the spot-check search (`apply(df, 1, ...)` coerces the whole frame to a character matrix), fuzzy duplicate matching (`agrep` all-pairs, uncapped), `VIM::kNN` imputation over the full frame, and the profile/outlier charts which ship un-aggregated rows to the browser.
- **GPS check**: there is no dedicated GPS-check DQ sub-tab; GPS issues surface only implicitly (records with missing lon/lat are dropped from the map).
- **Node.js packages** (`package.json`) are declared but unused.

---

The README is the user-facing guide (install, launch, workflow, methods, configuration, deployment, citation). Keep it in sync with features; personal/contact details live only there and in DESCRIPTION, never in the app UI. R code must stay ASCII-only (use \u escapes in strings) so `R CMD check` stays clean.

*Last updated: 2026-09-23. This guide reflects the actual state of the repository (`boosted_ai` branch); if you restructure the project, please update this file accordingly.*
