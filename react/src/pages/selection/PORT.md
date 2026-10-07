# Beneficiary Selection (`ben_panel`, module `ben_selection_1`)

Server: `R/mod_ben_selection.R` (logic unchanged). Client: `SelectionPage.tsx`,
`selection.css`. Browser check: `NOT_CRAN=true Rscript react/dev/test_selection.R`
(`TW_BIG=1` for 30,000 rows, server paging).

## Behaviour tree

- sidebar
  - 1. Areas covered (folding step; summary "Every area" / "n chosen"):
    Admin 1-3 multi pickers (`ben_admin1..3`), chained by `cascade_pickers()`
    (a level not mapped is hidden); select all / none
  - not-applied note (`ben_pending`: areas covered, approach, score, community
    decision, prioritisation that differ from the applied selection)
  - **Apply selection** (`ben_apply`, the page's one primary button) + clear (x, `ben_clear`)
  - Export selection (Excel) (`export_open`, gated until someone is served) -> the
    server's dialog: variables, score column, audit sheet opt-in, one workbook
    or one per area (zip), Download (`download_selection`)
  - Selection report (HTML) (`selection_report`, gated)
  - Variable calculator (`components/VarCalc`, `calc-open`)
- KPI row: Selected households / individuals ("not mapped" without household
  size), Eligible by design, Excluded by design (`ben_total`, `ben_indiv`,
  `ben_eligible`, `ben_cut`)
- selection note (`selection_note`): "<approach>: n eligible by design, n
  prioritised, n excluded by design (unmet need...)", notes in amber;
  self-targeting: "no household list is produced."
- tabs (`ben_tabs`)
  - Selection design: numbered cards, only the steps the approach uses
    (numbering skips the others; hidden inputs stay mounted)
    - Approach (`ben_approach`) + its description; hybrid: combine both / either (`ben_combine`)
    - Eligibility rules (hybrid, categorical): Edit eligibility rules (`btn_rules`,
      the server's rule builder dialog), summary (`rules_summary`)
    - Score (hybrid, scorecard): with a card: switch "Apply the <scorecard |
      vulnerability ranking> (n criteria)" (`use_scorecard`), threshold
      (`scorecard_threshold`, set to the card's threshold when a new card
      arrives), mapping note (`scorecard_note`, hosted), Match columns
      (`sc_rematch`, crosswalk dialog); without a card (or switched off):
      min / max vulnerability score sliders (`ben_score_min/max`, range from the
      data); file loader (`sc_file`, hosted in `scorecard_ui`) -> crosswalk dialog
    - Community decision (community): column (`ben_comm_col`), values (`ben_comm_vals`)
    - Prioritisation (all but self-targeting): none / total caseload / caseload
      per area (`ben_prio_mode`); counted in people / households
      (`ben_prio_count`, households only without household size); total:
      caseload (`ben_prio_n`) + rationale (`ben_prio_rationale`, required on
      Apply); per area: level (`ben_quota_unit`, mapped levels), "Set the
      caseload per area..." (`quota_open`, the server's dialog with allocation
      methods, IPC / HNRP figures, rationale), summary (`quota_summary`, hosted)
    - footer: note (or what is not applied yet) + outline Apply selection (clicks `ben_apply`)
  - Composition
    - insight tiles (`comp_insights`): households served, people served,
      female-headed, unmet need, areas with eligible households nobody served;
      nobody selected: empty state
    - Eligibility and vulnerability mix (`ben_validation_plot`, horizontal bars
      with count and share); not mapped: one line, the area chart takes the row
    - By area: served / excluded by design / not eligible (`ben_area_plot`,
      stacked, top 25 Admin 1)
    - Who is selected, compared with who is not (`ben_profile`): table, notable
      gaps bold blue; messages when it cannot compare
    - vulnerability ranking in use: Share selected by number of deprivations
      (`rank_dep_plot`), Selected households by ranking profile
      (`rank_prof_plot`, when the ranking has profiles), with their help tips
  - Beneficiary list: identification columns + Details (`ben_table`,
    `ben_view` opens the record dialog), search / sort / pages (server above
    5,000 rows), "Download the list (Excel)" (same as `export_open`)

## Checklist (verified in the browser, react/dev/test_selection.R)

- [x] KPIs and note drawn after the mapping
- [x] settings wait for Apply: approach / prioritisation / threshold / caseloads
      noted as not applied, counts unchanged until Apply, note gone after
- [x] total caseload (300 households): 300 served, 1,200 excluded by design
- [x] caseload per area dialog: saved, summary shown, applied (120 served)
- [x] rules dialog opens
- [x] Composition: insight tiles, area chart, mix chart (or its line), profile table
- [x] vulnerability ranking loaded from a file through the crosswalk: switch
      label, threshold from the card, ranking chart
- [x] list: rows, Details dialog, next page (server-paged at 6,140 rows with TW_BIG=1)
- [x] Excel export: Summary, Selected (300 rows), By_area, Excluded_by_design;
      Audit_trail only when opted in; per-area zip (3 workbooks)
- [x] HTML report downloads
- [x] light and dark screenshots; no browser errors other than shinyreact's
      "Error for <id>" log of validate() messages

## Deliberate divergences

- Server facts as JSON: `selection_note`, `comp_insights`, `ben_profile` became
  `shinyreact::reactive_output()`; new `ben_meta` (approaches, card, ranking)
  and `ben_pending` (the not-applied note, which the Shiny page did not have).
  `ranking_comp` (renderUI) is gone: the client shows the ranking charts from `ben_meta`.
- `scorecard_ui` now hosts only the file loader; the card switch, threshold and
  Match columns are React. A new card resets the threshold input to the card's
  threshold (the Shiny page kept the previous input value).
- Charts are ECharts options written for the page (not converted plotly).
- React buttons send an initial 0: `ben_apply`, `ben_clear`, `export_open`,
  `btn_rules`, `quota_open`, `sc_rematch` observers start with `req(input$x > 0)`.
- `mod_ben_selection_ui()` is kept for `legacy_pages()` but no longer drawn.
