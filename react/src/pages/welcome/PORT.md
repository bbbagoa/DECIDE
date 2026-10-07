# Welcome (`welcome_panel`)

Was `mod_welcome_ui()` (R/mod_welcome.R). Server: `mod_welcome_server()`
(same file, called from `app_server()`): the three shortcuts and
`output$welcome_meta` (package version).

## Behaviour tree (Shiny page)

- hero: eyebrow "WFP Vulnerability Analysis and Mapping", WFP logo | TargetWise,
  tagline "Reaching the most vulnerable", amber rule, one-paragraph lead
- three phase cards, numbered 1-3, each with an icon, a dataset chip and a
  paragraph: Targeting Design (needs-assessment data), Beneficiary Selection
  (household registration data), Targeting Monitoring (PDM data)
- "Where to start": four numbered hints, then three buttons
  - `go_design` "Start a targeting design" (primary) -> Targeting Design
  - `go_import` "Load registration data" -> Load registration data
  - `go_monitor` "Open monitoring" -> Targeting Monitoring
- "Methodological basis": the unit, four references (WFP 2021, Advisories 1-3/2025)
- About / Release: description, README pointer; version, licence, built with
- every label follows the language picker (www/translations.json)
- loads nothing

## Checklist (browser, react/dev/test_welcome_import.R)

- [x] hero, phases, where to start, references, about, version
- [x] go_design / go_import / go_monitor navigate; nothing fires at start-up (React sends 0)
- [x] light and dark mode
- [x] French

## Deliberate divergences

- Each shortcut sits at the foot of its phase card instead of in a row under
  "Where to start"; that card keeps the three hints, and the fourth ("Each
  phase loads its own dataset...") is a note under them.
- "Built with" reads "R, Shiny, React".
- The shortcut observers moved from `app_server()` into `mod_welcome_server()`
  with `req(input$go_* > 0)`.
