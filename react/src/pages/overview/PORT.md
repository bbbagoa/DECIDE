# Overview (`overview_panel`, module `overview_1`)

Server: `R/mod_overview.R`; builders' pure functions in `R/utils_overview.R`
(`gb_echart()`, `ct_frame()`, tested in `tests/testthat/test-overview-builders.R`).
Client: `OverviewPage.tsx`, `charts.tsx` (ECharts), `Builders.tsx`,
`overview.css`. Browser check: `react/dev/test_overview.R`.

## Behaviour tree

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
  - "Follow the map" switch (`view_follow`, off by default)
  - "Not available with these data:" strip
  - tiles: Households, Individuals, Communities, Days of collection, Households
    per day, Enumerators, Interview length (each only when its field is mapped)
  - "Households per day" (ECharts): bars per day, stacked by Admin 1 or one
    total, dashed cumulative line on a right axis; hover: the day, each area,
    "In all"; **Total / By area** toggle (display only, default By area)
    - no date mapped: "Not in these data: map the data collection date..."
- sections, one open at a time (Who is in the data open)
  - Who is in the data: tiles and rings; small charts (ECharts): Age of the
    head, Household size, Children under 5 (columns, % on top), Residence
    status (horizontal bars, % at the end); hover: share and households
  - Vulnerability: Households by vulnerability group (bars coloured by
    severity), Distribution of the vulnerability score (columns); Across
    household profiles: one bar per category coloured by dimension, dashed
    line at the overall value (with a legend entry), indicator picker
  - **Table builder** (React, follows the fields as they change)
    - Rows (`ct_row`), Columns (`ct_col`, or none: one-way), Cells
      (`ct_stat`: Households, Row %, Column %, Total %, Mean / Sum of a
      number), Number (`ct_value`, only for a mean or a sum)
    - caption (`ct_info`): what the cells show, households, the column variable
    - the table (`ct_table`, render_react_table payload): one row per row
      category and Total, one column per column category and Total; cells
      shaded light to blue (totals not shaded), sortable
    - chi-square note under two-way counts or percentages
    - refusals in place of the table: too many options (more than 30
      answers), "Choose the number to average or sum.", "No household has an
      answer for these variables."
  - **Chart builder** (React, follows the fields as they change)
    - Variable (`gb_x`), Against (`gb_y`), Grouped by (`gb_group`)
    - chart type as a segmented control (`gb_type`, from `gb_meta`): one
      number: Histogram / Box plot; one category: Bars (share) / Bars
      (households); two numbers: Scatter with trend line / Scatter; a
      category and a number: Box plot / Mean / Violin; two categories: 100%
      stacked / Stacked / Side by side (one panel per group)
    - Axes (`gb_axes`, "Axes (set)" when bounds are set): the server's dialog
      (`axis_dialog()`, Y and X bounds, Automatic / Cancel / Apply)
    - chart (`gb_plot`, render_echart) and note (`gb_note`: households, mean
      and median, or r and Spearman per group)
    - too many options refused with its message in place of the chart

## Checklist (browser, demo data, `react/dev/test_overview.R`: 37 PASS)

- [x] Recharts gone (no Recharts element; `recharts` uninstalled)
- [x] households per day, who, vulnerability charts drawn by ECharts, same content
- [x] sidebar areas cascade, Apply (483 in Ituri) / clear (1,500)
- [x] report download (HTML, checked separately)
- [x] map hosted, colour by
- [x] chip, follow switch, show all
- [x] table builder: rows / columns, counts, row % (totals 100%), mean (number picker shows), one-way, chi-square, too many options
- [x] chart builder: every type, with and without groups (14 combinations), too many options, Axes dialog
- [x] dark mode, light mode screenshots
- [ ] French labels of the new builder texts (t() falls back to English until www/translations.json has them)

## Deliberate divergences

- Charts drawn by ECharts (one chart library for the app); hovers say the
  same things.
- Mean chart: the mean as a mark with its 95% interval as whiskers (ECharts
  has no error bars), no bar under it.
- Violin: the density of each category drawn as stacked horizontal bars on
  48 bins of the number (ECharts has no violin); the hover gives the
  median, quartiles and households. Drawn from at most 20,000 households.
- Grouped two-category charts: one panel per group, the y title moved to the
  note ("bars: % of households · one panel per <group>").
- Histogram X bounds (Axes) recompute the bins within the bounds (a category
  axis of bins).
- Cross-tab: no "column variable" banner above the columns (the caption
  names it); the Total row sorts with the others.
- The old renderUI builders (`table_ui`, `chart_ui`, `gb_type_ui`) and
  their plotly chart are gone; `axis_button()` relabelling by
  updateActionButton() replaced by `gb_meta$axes_set`.
