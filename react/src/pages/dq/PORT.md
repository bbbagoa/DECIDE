# Data Quality (`dq_panel`, module `dq_1`)

Server: `R/mod_dq.R` (orchestrator, filters, reset, report, the shared
ECharts helpers `dq_hbar()` / `dq_heatmap()` / `dq_compact()`) and
`R/mod_dq_*.R` (one file per tab). Client: this folder, one component per tab
(`HealthTab`, `SpellingTab`, `LocationTab`, `MissingTab`, `OutliersTab`,
`DuplicatesTab`, `EnumeratorTab`), shared bits in `common.tsx`, styles in
`dq.css`. Browser check: `react/dev/test_dq.R` (data: `react/dev/test_dq_data.R`).

## Behaviour tree

- sidebar (numbered folding steps, one open)
  - 1. Areas: Admin 1-3 pickers (`dq_filter_adm1..3`), multi, Select all / None;
    labelled with the mapped column ("Province:"); a level lists only the areas
    inside those picked above, an unmapped level is hidden (`cascade_pickers()`)
  - 2. Interview dates (only when a date is mapped): a range (`dq_filter_date`),
    bounds and start from `output$dq_meta`, reset by the server on load / clear
  - Apply (`btn_apply_dq_filters`, the only primary) applies them; nothing before
  - clear (x, `btn_clear_dq_filters`): areas emptied, dates back to the full range
  - Data quality report (HTML) download (`dq_report`)
  - Reset to original data (`btn_reset_data`, outline-danger) -> server dialog ->
    `confirm_reset`: the imported data back, an audit entry
  - "N filtered records" (`dq_filtered_rows`)
- tabs `input$dq_tabs` (values = the Shiny titles, so `nav_select()` works)
  - Health check: Run (`hc_run`) -> six checks (`output$hc_table`, JSON): icon,
    check, what was found, status pill, Review (sets `hc_go` -> the server
    selects that tab); summary pills; "Checked on N records, <time>"
  - Spelling & Integrity: name columns (`dq_name_cols`), Check names
    (`dq_names_check`), invalid-records figure (`dq_names_metric`, JSON);
    Edit selected (`btn_open_edit`, gated on a selected row) -> server dialog
    (edit / delete with reason); Delete rows with missing names
    (`btn_delete_all_missing`) -> dialog with required reason; Export
    (`download_audit`); empty state (`dq_names_empty`); table
    `dq_names_redflags` (single selection, 50 rows)
  - Location names: level (`norm_col`, mapped levels only), Show names
    (`norm_show`), Correct spelling (`correct_name`, suggested from the
    selection); Apply to selected (`btn_apply_norm`) -> confirm dialog -> merge
    + audit; Select all shown (`btn_select_shown`, the rows left by the search),
    Deselect all, Export; hint (`location_hint`, JSON: choose a level / level
    not mapped), selection chips (`norm_selection`, JSON: name + records); table `tab_location_norm` (multiple, 100 rows) and the
    hierarchy treemap `dq_location_treemap` (click zooms, breadcrumb)
  - Missing data: mandatory fields (`mandatory_vars`), geographic level
    (`missing_geo_level`), Apply (`btn_apply_missing`); hint; once applied
    (`missing_results`, JSON): four figures (`missing_kpis`, JSON) and three
    tabs: By field (completeness bars coloured by band with the 95% line;
    column-health table with banded Completeness and Status), Patterns (UpSet:
    pattern bars, per-field totals, matrix with joining lines), By location (gap
    rate bars, top 50; categorical and numeric fields x location heatmaps)
  - Outliers: variable (`outlier_var`, mapped fields first), method
    (`outlier_method`), its threshold slider (`outlier_threshold`, range and
    default per method, none for "Allowed range only"), allowed range
    (`range_min` / `range_max`, remembered per variable, suggested for mapped
    fields), correction (`outlier_correction_method`) -- redrawn as they change (no Check button: the exception to "settings wait for their button");
    Correct all flagged (`btn_apply_outlier_correction`, gated) -> preview
    dialog (before / after stats, first 8 values, reason) -> Apply + audit;
    range hint, stale-settings note (`ol_stale`); four figures
    (`outlier_total`, `outlier_count` + `outlier_verified`, `outlier_rate`,
    `outlier_bounds` + `outlier_bounds_src`); tabs `input$outlier_tabs`:
    - Distribution: histogram with bounds (red dashed) and allowed range (blue
      dotted); box plots by Admin 1 with the points beyond the whiskers
    - Where they come from: flag rate by Admin 1 and by enumerator
    - Most extreme values: insights (`outlier_insights`, JSON, `Insights.tsx`;
      their "Select ..." links send `ol_pick` = {what, value, n}), table `ol_table` (multiple, Flag
      coloured, Details -> `ol_view` dialog), Select all / Clear, "n selected",
      Correct selected, Set a value (dialog -> preview), Mark as verified
      (dialog with required reason), Export
    - All numeric variables: Audit all (`ol_scan`), empty state, table
      `ol_scan_table` (flag-rate bars); a row opens that variable on Distribution
  - Duplicates: columns (`duplicate_vars`), Fuzzy matching switch, Similarity
    slider (dimmed when fuzzy is off), Find duplicates, Export; four figures
    (`dup_total`, `dup_count`, `dup_groups`, `dup_exact`); hint; when found
    (`dup_has_rows`, JSON): the groups card, Select all but the first / exact
    copies / Clear, "n selected", Delete selected (dialog, warns when a group
    loses every record) ; table `dq_duplicate_table`: one band per group
    ("Group k · n records · differ in m column(s)"), Differs in, Copy, Compare
    (-> `dup_compare` dialog: side by side, differing fields first, delete
    ticked records) and Details (-> `dup_view`)
  - Enumerators: when no enumerator is mapped, one empty state
    (`enum_state`, JSON); else four figures, tabs Flagged enumerators (rules,
    Export flagged, cards with reasons and "See their interviews" -> dialog with
    the records table, Details), Workload and speed (insights; interviews by
    enumerator with the median; average duration with the usual band; interviews
    per day heatmap), Performance table (metrics with Review / OK pills; empty
    answers with the team limit)

## Checklist (browser, `react/dev/test_dq.R`, 07/10/2026)

- [x] page drawn, filtered-rows text, light and dark
- [x] Areas filter + Apply (485 of 1,505), Clear (1,505)
- [x] Health check runs (6 rows), Review opens the tab (`nav_select`)
- [x] Outliers: Check, figures, histogram / box / rates, flagged table,
      correction preview -> Apply -> 40 audit entries; numeric audit table
- [x] Spelling: Check names, row select, Edit dialog, save -> audit entry
- [x] Location: Show names, table, treemap, selection chips, suggested spelling
- [x] Missing data: Apply, figures, completeness chart, column health (6 rows),
      Patterns, By location
- [x] Duplicates: Find (72 groups, bands), select all but the first, Delete ->
      audit entries, records left
- [x] Enumerators (test data with an enumerator and start / end times):
      figures, the fast enumerator flagged, charts, metrics table
- [x] Reset to original data (1,505 again)
- [x] server facts as JSON, drawn by React (07/10/2026): empty states
      (spelling, location, missing, duplicates, numeric audit), range hints
      (suggested, inverted), location chips, outlier insights + "Select them"
      (6 coded 99s selected), enumerator rules + flagged cards + "See their
      interviews" dialog, workload insights; light and dark
- [x] no browser error other than shinyreact's log of output messages
      (validation notes such as "No gaps in these fields.") -- the 07/10 run
      also logged a deck.gl `onAfterRender` error from the Overview map chunk
      (not this page)

## Deliberate divergences

- One primary button per view: Show names, Edit selected and Correct all
  flagged are outline buttons now (the tab's main action stays primary).
- Missing data "by location": the faceted ggplot bars (categorical) and the
  dot plot (numeric) are heatmaps of fields x locations (40 locations with the
  most gaps), easier to read at a glance; the gap-rate lollipop is a bar chart.
- Location treemap: ECharts treemap (two levels shown, click to zoom).
- Duplicates table: the columns can be sorted (DT had ordering off); sorting
  breaks the group bands until sorted back. "Differs in" is no longer amber.
- Health check table, the missing-data figures, the invalid-names figure, the
  missing-results switch and the duplicates switch are JSON outputs under the
  same ids (`hc_table`, `missing_kpis`, `dq_names_metric`, `missing_results`,
  `dup_has_rows`); the threshold slider is drawn by React (the server's
  `outlier_threshold_ui` is gone).
- Enumerator tab: when no enumerator is mapped, one empty state instead of the
  validation message in every output.
- No hosted server HTML left on the page: the hints, empty states, outlier
  insights, enumerator rules / flagged cards / workload insights and location
  chips are JSON outputs under their old ids (`dup_hint`, `dq_names_empty`,
  `location_hint`, `norm_selection`, `range_hint`, `outlier_insights`,
  `enum_flagged_ui` (now with the rules: `enum_rules` is gone),
  `enum_speed_insights`). `missing_hint` is gone (the tab reads
  `missing_results`), `ol_scan_empty` too (the tab reads `input$ol_scan`).
  Insight cards come from `dq_insight()` (R/utils_dq_health.R). Server-composed
  sentences (insight subs, enumerator reasons) stay English, as before.
- Hidden outputs wait: `hc_table`, `missing_kpis`, `outlier_insights`,
  `enum_flagged_ui`, `enum_speed_insights` are tracked with
  `useOutputVisibility()` on their section; the cheap state outputs
  (`dq_meta`, `missing_results`, `dup_has_rows`, `enum_state`, hints) are not.
- Every dialog (showModal) is Shiny's; the enumerator's records table in its
  dialog stays a DT table.
- The Shiny UI functions (`mod_dq_ui()`, `dq_*_ui()`) are kept (the legacy
  page cache still builds them) but no longer shown.
