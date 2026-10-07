# Load registration data (`import_panel`)

Was `mod_import_panel_ui()` (R/mod_welcome.R). Modules, unchanged ids:
`file_import_1` (R/mod_file_import.R), `moda_import_1` (R/mod_moda_import.R),
`calc_reg` (R/mod_var_calc.R), `setup_1` (R/mod_setup.R). The import
orchestration stays in `app_server()` (`process_import()`, override warning,
import summary with `btn_import_to_setup`).

## Behaviour tree (Shiny page)

- title "Load household registration data", one line under it
- card "Household registration data"
  - formats line (xlsx, sav, dta, csv, parquet; MODA, Kobo, ODK)
  - one row: file upload (`file_import_1-file_in`, 2 GB, read in the background
    with a cancellable loader) | "Or pull from a server" (`moda_import_1-btn_open_moda`)
    | "Missing a variable?" (`calc_reg-open`)
  - once data is in memory: "Variable Definition & Setup" (`setup_1-open_modal`)
  - after a file: "File loaded."
- card "Before you start, check your data": five checks
- dialogs (all Shiny's, showModal()):
  - data already in memory -> "Continue" (`btn_confirm_override`) / Cancel
  - import summary -> "Continue to variable setup" (`btn_import_to_setup`)
  - mapping (`setup_1-save`) -> review (`setup_1-review_confirm`) -> Overview,
    analysis pages shown, audit entry
  - MODA / Kobo / ODK: server, server URL, project, form ID, key, Sync Now,
    form confirmation, download progress with cancel
  - variable calculator: conditions / formula / R code / bulk, preview, create
    (column added to the data and audited)

## Checklist (browser, react/dev/test_welcome_import.R)

- [x] file input hosted in the drop zone, ready even before the page is shown
- [x] registration_demo.csv end to end (summary, mapping, review, Overview)
- [x] status strip: rows, columns, source, "Variables mapped (n)", setup button
- [x] "<file> - n rows - m columns" line under the drop zone
- [x] MODA dialog: server, form ID, key; one click opens one dialog
- [x] variable calculator: yes/no variable created, column count +1, in the audit trail
- [x] light and dark mode, French

## Deliberate divergences

- The setup button sits in a status strip that says what is in memory (rows,
  columns, source, mapped or not); it is the page's primary action until the
  data is mapped, then outline. Before any data the strip says what to do.
- The file input is Shiny's `fileInput`, drawn by the server in
  `output$file_ui` (no React equivalent: it streams the upload) and hosted in
  a drop zone; its "Browse..." / "No file selected" are not translated.
- Checks 2 and 3 are reworded into full sentences ("Fewer and shorter value
  labels...", "coordinates are left off the map").
