# Porting DECIDE to the shinyreact `ui.tsx` pattern

**Status (07/10/2026):** the whole app runs on a React shell (`react/src/App.tsx`,
built to `inst/app/react/ui.js`, served by `shinyreact::page_react()`). Every
page not yet ported is the Shiny page, hosted in its `pg_<value>` holder.
Ported: **Overview**, **Audit Trail**. Next: Welcome, then the others,
Targeting Design last.

---

## The shell

- navbar, left to right: WFP logo | DECIDE, then
  - Welcome (`welcome_panel`)
  - 1. Targeting Design (`scorecard_panel`)
  - 2. Beneficiary Selection, a menu: Load registration data (`import_panel`),
    Overview (`overview_panel`), Data Quality (`dq_panel`), Spot Checking
    (`spot_panel`), Selection (`ben_panel`)
  - 3. Targeting Monitoring (`pdm_panel`)
  - Audit Trail (`modif_logs`)
- right of the navbar: country office badge (`co_badge`, hosted), Language
  (English / Français, `input$lang_selector`), Session toolbar (hosted
  `mod_session_manager_ui`), light / dark switch (`input$dark_mode`, "light" |
  "dark"; opens light)
- the current page is `input$main_nav`, "welcome_panel" at start
- Overview, Data Quality, Spot Checking and Selection are hidden until the
  variables are mapped (`tw_nav("hide"/"show")` -> message "tw-nav-state", sent once the client
  sets `input$tw_client_ready` and on every change; the client starts with them hidden)
- the server moves to a page with `tw_nav("select", page)` (after setup: Overview;
  after a session restore: the page saved; Welcome's three buttons)
- a page keeps its state when you leave it and come back
- labels in English or French from `www/translations.json`

## Overview (`overview_panel`, module `overview_1`)

### Behaviour tree

- one screen: sidebar | map (left half) | figures (right half)
- sidebar
  - 1. Areas: Admin 1, Admin 2, Admin 3, multi-select, searchable; a level lists
    only the areas inside those picked above; a level not mapped is not shown
  - 2. Interview dates: a range, starts at the first and last interview date
  - **Apply** (`btn_apply_filters`) sets the filters; nothing changes before it
    - notification "Filters applied."
  - clear (x, `btn_clear_filters`): empties the areas, dates back to the full
    range; notification "Filters cleared."
  - Overview report (HTML) download (`overview_report`), greyed until data is mapped
- map card
  - "Colour by": the mapped fields (Vulnerability group first when mapped,
    `map_var`); a field with more than 30 answers is refused with a warning
  - WebGL points, legend, Esri basemaps, box zoom (kept: the leaflet widget, hosted)
- data collection (always in view)
  - title "Data collection", chip "All N households" or
    "Map view: n of N households" + "show all" (`view_all`)
  - "Follow the map" switch (`view_follow`, off by default): on, every figure
    describes the households in the map view and follows it (debounced 600 ms)
  - "Not available with these data:" strip of features the mapping cannot give (verify)
  - tiles: Households, Individuals, Communities, Days of collection, Households
    per day, Enumerators (each only when its field is mapped),
    sub-line on hover
  - "Households per day": bars per day, stacked by Admin 1 (top 5 + Other areas)
    or one total; dotted cumulative line on a right axis; **Total / By area**
    toggle (display only, default By area)
    - no date mapped: "Not in these data: map the data collection date to see the daily submissions."
- sections, one open at a time (Who is in the data open)
  - Who is in the data: tiles (Head's age, Household size...) and rings for
    shares (Female-headed, With children under 5...), at most 5 rings; small
    charts: Age of the head, Household size, Children under 5 per household
    (columns with % on top), Residence status (horizontal bars)
    - nothing mapped: empty state "No household characteristic is mapped"
  - Vulnerability: Households by vulnerability group (bars coloured by
    severity, most vulnerable last), Distribution of the vulnerability score
    (columns); Across household profiles: one bar per category, coloured by
    dimension, dotted line at the overall value; indicator picker (Share
    eligible / Share in the most vulnerable groups / Mean score) switches views
    already computed
    - nothing mapped: empty state "No vulnerability variable is mapped"
  - Table builder, Chart builder (kept: the Shiny builders, hosted)

### Checklist

- [x] sidebar areas cascade, dates, Apply / clear, notifications
- [ ] report download
- [x] map hosted, colour by
- [x] chip, follow switch, show all
- [ ] readiness strip
- [x] collection tiles
- [x] daily chart, Total / By area, cumulative line, empty state
- [x] who: tiles, rings, four charts, empty state
- [x] vulnerability: groups, score, cross + indicator, empty state
- [x] table and chart builders hosted
- [x] dark mode, French labels

### Deliberate divergences

- Charts are drawn by Recharts instead of plotly (the point of the port);
  hovers say the same things.
- The table and chart builders stay the Shiny builders for now (hosted).

---

## Audit Trail (`modif_logs`, module `audit_1`)

- card "Audit trail": phase buttons All | Design | Selection | Monitoring |
  Session, Export (xlsx, read-only, every column, server download
  `download_full_log`)
- one line of help, a search box (all columns)
- table, newest first: Phase, When, Action always; Record, Field, Old value,
  New value, User, Reason only when a row shown has one; click a header to
  sort; 15 rows a page; "Nothing logged yet." / "No entry matches."
- data: `output$audit_rows` (every entry, the action without its "Phase: ")

### Checklist

- [x] rows and columns after an import and setup
- [x] phase filter, empty message
- [x] export (4 rows)
- [x] dark mode
