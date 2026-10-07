# Spot Checking (`spot_panel`, module `spot_checking_1`)

Server: `R/mod_spot_checking.R` (unchanged logic), `R/utils_verification.R`
(`verification_field_chart()`, the agreement chart as an ECharts option).
Client: `SpotPage.tsx`, `spot.css`. Browser check: `react/dev/test_spot.R`.

## Behaviour tree

- sidebar (numbered folding steps, one open)
  - 1. Areas: Admin 1 / 2 / 3, multiple, Select all / None (`sc_admin1..3`);
    cascade_pickers() fills them, each level lists the areas inside those
    picked above, an unmapped level is hidden; folded: the areas picked
  - 2. Search (`sc_search`): any column holding the text; folded: the text
  - Apply (`sc_apply`, outline) and clear (x, `sc_clear`): notifications
    "Spot check filters and sample applied." / "... cleared."
  - "Back-check results": Verification report (HTML, `verif_report`) and
    Comparison (Excel, `verif_download`), both frozen until a comparison has
    run ("Run the comparison first.")
- figures (`sc_kpis`): Households in scope (with a valid phone number in
  remote mode), Share sampled, Sample size ("Draw the spot-check sample
  first." before), Back-check agreement (after the comparison)
- remote mode note: "n of N households in scope have a valid phone number in
  <col>", or a warning to choose the phone column
- tabs (`sc_tabs`, nav_select() works)
  - 1. Sample for checking
    - one band: Interview mode (Face to face / Remote (phone), `sc_mode`),
      Phone column (`sc_phone_col`, remote only, guessed from the mapping and
      the names), Sample size (`sc_sample_size`, 30), Applies to (whole scope
      or each Admin 1 / 2 / 3 / village, `sc_per_unit`), Method (Simple random,
      Systematic, PPS, `sc_sample_method`), Seed (`sc_seed`, 12345),
      **Draw sample** (`sc_draw`, the primary button)
    - card "Sampled households" (expand): Export sample (Excel,
      `download_spot`), Continue to verification (`sc_go_verify`); the list
      (`spot_table`): identification columns and a Details button that
      opens the record (`spot_view`, server modal)
  - 2. Verification
    - card "Back-check comparison"
      - 1 Verification data: File / MODA form (`verif_source`); file input
        (`verif_file`, Shiny's, hosted in `verif_file_ui`); MODA: Form ID,
        API key (prefilled from an earlier MODA import), Fetch (`verif_fetch`);
        status "n records loaded (source); k columns in common with the sample"
      - 2 Comparison: Match records on (`verif_key`, the household id),
        Fields to compare (`verif_cols`, every shared column), Tolerance
        (`verif_tolerance`), **Run comparison** (`verif_run`, primary)
      - empty states: "No verification data yet", then "Ready to compare"
    - after the comparison: Matched records (on key), Overall agreement
      (fields compared), Records with a discordance, Unmatched (not
      re-visited / not in the sample); Agreement by field (`verif_plot`,
      worst first, bars coloured 95%+ / 90-95% / below 90%, dashed lines at
      90 and 95); Field summary (`verif_field_table`, agreement banded the same
      way); Discordances (`verif_disc_table`)
- saved with the session (workspace "spot_checking"): applied filters and
  sample settings, verification data, comparison, key / fields / tolerance

## Checklist (browser, demo data, `react/dev/test_spot.R`: 29 PASS)

- [x] page drawn, no browser error, starts on the sample tab
- [x] 1,500 households in scope, 30 sampled, 20 rows a page
- [x] areas + Apply (483 in Ituri), Clear (1,500)
- [x] 12 per Admin 1, systematic: 36
- [x] remote mode: phone column shows, warning without a phone column
- [x] Details opens the record (server modal)
- [x] sample export (xlsx)
- [x] Continue opens Verification; empty state; report frozen
- [x] upload a re-collected file: status, key = instanceID, 20 fields
- [x] Run comparison: figures, chart, field summary, discordances; report unfrozen
- [x] verification report (HTML) and comparison workbook (xlsx) download
- [x] light and dark screenshots

## Deliberate divergences

- The four value boxes are one row of quiet figure cards with tinted icon
  chips; their values come from one JSON output (`sc_kpis`) instead of four
  textOutput()s (still defined, unused).
- The agreement chart colours bars by the reading of the agreement (the
  same bands as the Excel export) and marks 90% and 95%; it was all blue.
- Agreement in the field summary is a number shown as a percentage (sorts
  numerically) with the same bands.
- "Fields to compare" shows the chosen fields as chips that scroll inside
  the picker (pickerInput showed "20 fields").
- Server buttons drawn by React send 0 at start: `sc_apply`/`sc_draw`,
  `sc_clear`, `sc_go_verify`, `verif_fetch`, `verif_run` now `req(> 0)`.
- The page tells Shiny it is shown when it becomes active (`signalShown`):
  it is mounted hidden, and its download links and hosted file input stayed
  "hidden" (no href) until then.
