# Targeting Monitoring (pdm_panel) - React port

Module `monitoring_1` (R/mod_monitoring.R), with the nested PDM module
`monitoring_1-pdm` (R/mod_pdm.R) and two chart builders (R/mod_chart_builder.R):
`monitoring_1-pdm_charts` (PDM presets) and `monitoring_1-pm_charts` (CFM and
community-process presets). Browser check: `NOT_CRAN=true Rscript react/dev/test_monitoring.R`.

## Behaviour tree

- Tabs `input$monitoring_1-tabs` (pdm / process / report), every panel mounted.
- **1. Implementation errors** (PdmTab.tsx): sidebar of folding steps
  - 0. Verification sample: area level (filled by the server), size mode (margin / fixed), margin or n, reserve, seed;
    Draw the sample (`ptm_draw`), Sample list (`ptm_download`, gated); status from `pdm_state$sample`.
  - 1. Survey data: kind (Baseline / PDM, note follows it), file (hosted `pdm_file_ui`), MODA (`ModaImport`), status from `pdm_state$data`.
  - Areas covered (`AreaScope`, module `monitoring_1-pdm-scope`).
  - 2. Selected households: from the sample list (ID column, match line from `pdm_state$match`) or a column
    (hosted `benef_level_ui` radio); prioritised column; area column.
  - 3. Who was eligible: column / scorecard / rules; hosted `pdm_elig_note`.
  - 4. Weighting: design / population (overall numbers, or per area -> editable table) / column / none.
  - Actions: Compute (`pdm_run`, the one primary), Export (Excel, gated).
  - Main: population table (`pop_table`, editable last two columns), empty states, tabs `pdm_tabs`:
    errors (KPIs, how computed, decision by area, tolerance inputs, hosted verdict card with the excluded by design),
    details (confusion table, error decomposition chart, coverage by area), calibrate (hosted `calib_ui`),
    explore (chart builder).
- **2. Targeting process** (ProcessTab.tsx): datasets step (hosted `pm_file_ui`, dataset picker, remove, MODA,
  chips from `mon_state$datasets`), areas covered (`AreaScope`); chart builder on the picked dataset.
- **Chart builder** (ChartBuilder.tsx): presets / display / type / style + Axes dialog (Shiny modal) / By /
  date + period / number / out of / split / percentages / only where + values; live preview (`preview`,
  `render_echart(chart_echart_option())`) or table (`preview_table`); title, comment (rich text), Add to report.
  Choices from `cb_meta`, state from `cb_state`.
- **3. Monitoring report** (ReportTab.tsx): template (pick, Draft, Export JSON, Delete, Import file hosted
  `tpl_import_ui`, rounds line), Context / Key findings / Recommendations (rich text, Shiny inputs), include
  PDM, report check (`report_check` -> Shiny modal or `tw-mon-download` -> hidden `report` link), save as
  template (Shiny modal). Items from `mon_state$items`: drag by the handle (`item_order`), width / up / down /
  remove / use the suggested finding (`item_act`), comment editors (`item_comment` via www/richtext.js).

## Checklist (browser-verified, react/dev/test_monitoring.R)

- [x] page renders, three tabs; empty state before data
- [x] survey upload (assessment_demo.csv), column mapping, compute: KPIs, decision by area, verdict
- [x] one click reaches the server once (one notification)
- [x] details: confusion table, error decomposition chart, coverage by area
- [x] population sizes per area: cell edits reach the server, errors weighted by them
- [x] PDM chart builder: live preview, split, column style, table view, Add to report
- [x] process dataset (registration_demo.csv) listed; donut preview; trend; Add to report
- [x] report: 3 items, half width (side by side), move up, drag and drop reorder
- [x] item comment and context text reach the report; report check modal; HTML report downloads
- [x] save as template, template selected after save, exported as JSON
- [x] light and dark screenshots; no browser error from this page
- [ ] sample draw from a real selection (needs Beneficiary Selection applied; covered by tests/testthat/test-ptm.R)
- [ ] MODA import and the calibration tab with an adopted ranking (server unchanged; not driven in the browser)

## Deliberate divergences

- Status lines, KPIs, the decision table, dataset chips, rounds note and the report items are drawn from
  JSON facts (`pdm_state`, `mon_state`, `cb_state`) instead of server HTML; the renderUI outputs they
  replaced (`ptm_status`, `pdm_file_status`, `ptm_match`, `pdm_hint`, `pdm_results`, `decisions_ui`,
  `pm_status`, `rounds_note`, `items_ui`, `kind_note`) are kept on the server, unbound.
- The rich text editors are drawn in React with the same markup (www/richtext.js listens on the document);
  editors with an id are bound with `Shiny.bindAll()`, so `update_rich_text()` still reaches them.
- Drag and drop is native HTML5 in React (www/sortable.js not used); the order still goes to `input$item_order`.
- Coverage by area keeps the coverage as a number (formatted as a percentage, with a data bar) instead of text.
- After saving or importing a template, the new template is selected after the choices are redrawn
  (`after_flush()`); before, the choices observer put the old pick back.
