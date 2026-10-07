# Targeting Design (`scorecard_panel`, module `scorecard_1`)

Server: `R/mod_scorecard.R` (unchanged logic; every input and output id kept).
Client: this folder. `mod_scorecard_ui()` is now a stub (the page is React).

| File | What |
|---|---|
| `DesignPage.tsx` | sidebar (data, areas, exports, adopt), the stepper, the four step panels (`input$steps`) |
| `StepFramework.tsx` | 1. outcome / PMT welfare / no outcome, summaries, vulnerable households by area |
| `StepCriteria.tsx` | 2. quick-screening settings, the criteria table (Use ticks), numeric PMT proxies, notes |
| `StepModel.tsx` | 3. settings band, More options, estimates with editable points, comparison and run history, diagnostics |
| `StepThreshold.tsx` | 4. slider, tolerance, helpers, rationale, error tracks, matrix, verdict, explore tabs, ranking figures |
| `facts.tsx` | what was server HTML, now drawn from facts: blocked columns (+ allowing them back), fit note and notes on the fit, cluster profiles (Target ticks), diagram and tree rules, PMT accuracy, stability and concentration, the stale notes |
| `shared.tsx` | ids, tips, chart cards with help, gates, step footers, always-mounted dialog, row inputs, error boundary |
| `types.ts` | the JSON the server sends |

## The server side (what changed)

- JSON outputs (`shinyreact::reactive_output`), section "The React page" of the module:
  `sc_meta` (model and scheme choices, CHART_HELP, defaults), `sc_flow` (stepper, step
  footers, gates, "settings wait for their button" notes, fit facts, params line, adoption),
  `sc_framework` (outcome / PMT summaries and data requirements), `sc_criteria` (the table),
  `sc_pmt_numeric`, `sc_estimates`, `sc_comparison` (models compared + run history),
  `sc_slider`, `sc_threshold` (errors, matrix, verdict, PMT wording), and (07/10/2026) `sc_blocked`
  (columns that cannot be criteria, allowed ones, picker reset by its stamp), `sc_fit` (tuning, profiles
  chosen, summary line, index facts `index_note_facts()`, PMT figures `pmt_fit_figs()`, convergence,
  notes on the fit), `sc_profiles` (cluster profiles, Target ticks `tgt_<j>` reset by the stamp; the
  "Ticked: ..." line is counted in the page), `sc_diagram` (the report's SVG from `diagram_svg()` with
  its title and help, injected as app-written markup; the tree's rules), `sc_pmt_accuracy`
  (`pmt_accuracy_figs()`), `sc_ranking` (stability result, selection insights) and `sc_stale` (points
  edited, threshold / tolerance not applied, the PMT cut-off in welfare: cheap, always computed).
  They replace the renderUI outputs blocked_note, fit_note, fit_details, cluster_ui, profile_pick_note,
  diagram_ui, tree_ui, pmt_accuracy_ui, stability_ui, insights_ui, points_stale, thr_stale, pmt_thr_note.
  Sentences are written in the page (templates with %s through `t()`), so they translate.
  They replace the renderUI outputs flow, data_status, nav_*, gate_*, fw_note(_none),
  pmt_setup_note, outcome_summary, pmt_summary, pmt_numeric_table, vuln_area_ui,
  criteria_table, criteria_strip, qs_stale, params_summary, scheme_apply_ui, runs_ui,
  weights_ui, comparison_ui, comparison_table, threshold_ui, kpi_incl/excl(_gauge),
  error_matrix, verdict, weights_charts.
- Tables whose rows hold inputs (Use ticks `rvuse_*`, points `w_*`, PMT proxies `pnum_*`)
  carry a `stamp`: each time the server sends them again the inputs take the values sent,
  as the Shiny renderUI redraw did (and only then).
- Charts: 30 `render_wfp_plotly` -> `render_echart` with ECharts options written in
  `R/utils_scorecard_echarts.R` (lollipops, mirrored distributions, ROC, box plots,
  grouped bars, scatter maps, heatmap, correlation circle, error curves). `pq_plot` stays
  plotly: it is drawn inside a Shiny dialog (showModal).
- Every observer of a button the page draws starts with `req(input$x > 0)`.
- Hosted (server renderUI into holders, suspendWhenHidden = FALSE): `host_file`
  (fileInput: it streams the upload) and `host_rationale` (rich_text_input). MODA,
  calculator, bulk binarise and areas covered are the shared components
  (`ModaImport`, `VarCalc`, `VarCalcBulk`, `AreaScope`) on the sub-modules' ids.
- No server HTML left on the page itself. Dialogs (correlations, model settings, tuning grid,
  profile quality, percentiles, adoption beyond tolerance, design guide) stay Shiny's.
- Hidden outputs wait: the costly JSON outputs are tied to the section that shows them
  (`useOutputVisibility`): `sc_framework` (step 1), `sc_criteria`, `sc_pmt_numeric`, `sc_blocked`
  (step 2, the blocked list only while its details are open), `sc_estimates`, `sc_comparison`,
  `sc_fit`, `sc_profiles` (step 3), `sc_diagram` ("More diagnostics" open), `sc_threshold`,
  `sc_pmt_accuracy` (step 4 with an outcome), `sc_ranking` (step 4 without). `sc_meta`, `sc_flow`,
  `sc_slider` and `sc_stale` always compute (the page lays itself out from them).
- Buttons inside these components (`allow_apply`, `show_tuning`, `cluster_apply`, `profile_quality`,
  `run_stability`) stay mounted (hidden with `Show`) and their observers start with `req(input$x > 0)`.
- Downloads (`download`, `download_json`, `download_report`, `download_xlsform`,
  `dl_model_tables2`) are not suspended while hidden (they sit in a folded section).

## Behaviour tree

- sidebar: 1. Assessment data (file drop zone, MODA, Calculator, How it works, status:
  rows x columns and source), 2. Areas covered, 3. Exports (scorecard / ranking workbook,
  card JSON, design / ranking report, XLSForm draft, frozen until adopted); one section open
  at a time; below: Use this scorecard / PMT / ranking (frozen until every step is done) and
  the adoption status
- stepper: Data, Vulnerability Framework (Welfare measure for a PMT), Criteria, Model &
  weights, Threshold & errors, Adopted; done / current / next; each step one click away
  (Data opens the sidebar section); "On this step" line, an earlier unfinished step with a
  way back, Continue (from Criteria it sends the ticks)
- 1. framework: three modes (segmented); outcome + vulnerable level + Validate (stale note),
  KPIs (households, vulnerable %, not vulnerable %), unbalanced-outcome warning; PMT:
  explanation and guidance, welfare / unit / household size / line mode / line or share +
  Validate, KPIs and data requirements; no outcome: explanation, what the ranking stands for +
  Validate; vulnerable (poor) households by area: area picker, 100% stacked columns with the
  overall line (scrolls past 30 areas)
- 2. criteria: gate when the framework is not validated; significance, adjustment, overlap
  cut-off, Run the tests (stale note); counts strip (variables, associated, repeating, ticked),
  search (name and label), Binarise variables, Correlations (dialog); the table (Use, variable
  + label, shares among vulnerable / others with bars, odds ratio with CI whisker, adjusted p
  with direction, overlap, missing); no outcome: households yes; PMT: numeric proxies table;
  how to read; columns that cannot be criteria (and allowing them back)
- 3. model: gate; band: model + settings gear + params line (change), weighting scheme, notes
  per mode; criteria in the model (select all / none); anchor (no outcome), More options
  (survey weights, models to compare / PMT models, stepwise + AIC/BIC), its summary line, Fit;
  model and scheme notes, Apply this scheme to the fitted model; fit note; run history (PMT,
  ranking); cluster profiles; estimates (beta, SE, OR whisker, p pill, direction, editable
  points, other models' effects, RF importance, agreement), Apply points (stale note), Reset,
  Export; notes on the fit; comparison (models compared with AUC bars, best marked, run history
  with Restore / Remove) and the ROC of the compared models; PMT comparison + error trade-off;
  More diagnostics: diagram, tree rules, the charts of the model kind
- 4. threshold: gate; slider + number box (0 .. max score), tolerance lower / upper, caseload,
  Minimise errors, Balance (Youden), At the poverty line (PMT), Fit to caseload, Apply (stale
  note), threshold note; rationale editor; with an outcome: evaluation note, PMT accuracy, AUC,
  eligible, inclusion and exclusion error on tolerance tracks, error matrix, verdict (fades in
  only when it changes); without: households selected, internal consistency, stability (check),
  what the selection concentrates, share selected by area, ranking distribution, criteria
  among selected; explore the threshold (3 tabs, two charts each, full screen), Score
  percentiles (dialog); footer: Adopt (explanation dialog beyond tolerance) or "Adopted" pill

## Checklist (browser, `react/dev/test_design.R`, all PASS 07/10/2026)

- [x] upload `assessment_demo.csv` (+ a welfare column), status line, outcome guessed
- [x] binary outcome validated, KPIs, vulnerable households by area chart
- [x] criteria table, ticks reach the server, untick / re-tick, search, Run the tests + stale note
- [x] correlations dialog (find groups)
- [x] fit logistic + compare logit / WoE / random forest; estimates; comparison table + ROC
- [x] edit a point -> stale note -> Apply points; diagnostics (forest plot SVG, charts)
- [x] second fit (XGBoost), history, Restore run #1
- [x] Minimise errors, tolerance change -> stale note -> Apply -> verdict uses 30%
- [x] explore tabs (6 charts), percentiles dialog computes
- [x] adopt (beyond tolerance: explanation dialog), status "Adopted"
- [x] downloads: design report (HTML, 1 MB), scorecard workbook (xlsx), XLSForm (xlsx), card (JSON)
- [x] PMT: validate (poorest 30%), summary, criteria, fit, threshold and verdict
- [x] no outcome: validate, criteria, deprivation count fit, k-means profiles (target table), threshold, selection KPIs
- [x] light and dark screenshots of every step; no browser errors
- [ ] session save / restore through the React page (server logic unchanged; not driven in the browser)
- [x] fit note, notes on the fit, diagram (forest plot SVG), tree rules, cluster profiles (tick -> note -> Target),
      PMT figures and accuracy, PMT cut-off note, stability check and concentration, stale notes; light and dark
- [x] hidden step: `sc_estimates` suspended while the threshold step shows
- [ ] French labels: the strings of facts.tsx are in www/translations.json; older strings of the page partly not

## Deliberate divergences

- One stepper: the step tabs row is gone; the stepper (and each step's footer) navigates.
- Charts are ECharts (same data, hovers say the same things); `pq_plot` stays plotly in its dialog.
- The cluster profiles table sits right after the fit (it is the step's main choice for
  clusters), no longer folded inside "More diagnostics".
- Estimates of a ranking hide the SE / odds ratio / p columns (always empty there).
- Help: an info icon with a hover card on every chart and setting, instead of bslib tooltips.
- Threshold: a number box beside the slider (same input).
- The verdict icon is one house in the verdict's colour (the Shiny page had three house icons).
