# Overview (`overview_panel`, module `overview_1`)

Server: `R/mod_overview.R`; builders' pure functions in `R/utils_overview.R`
(`gb_echart()`, `ct_frame()`, tested in `tests/testthat/test-overview-builders.R`).
Client: `OverviewPage.tsx`, `charts.tsx` (ECharts), `Builders.tsx`,
`MapView.tsx` + `mapgl.ts` (the map, loaded on demand), `overview.css`. Browser check: `react/dev/test_overview.R`.

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
  - the map (`MapView.tsx`; engine `mapgl.ts`, MapLibre + deck.gl, a chunk
    loaded the first time the page shows)
    - points from `map_points` (base64 float32 lon/lat pairs, `map_points_payload()`),
      colours from `map_colours` (one byte a point + palette + legend,
      `map_colour_codes()`); both wait while hidden (`useOutputVisibility` on the holder)
    - new data / filters: the view fits the points (inner 99%, `fit_range()`);
      a new colour keeps the view; a refused colour (too many options) puts
      the picker back (`refused`)
    - legend bottom right: categories with dots ("Not specified" in grey), a
      number as a ramp with five values
    - click on a point: `map_click` = list(i, nonce); the server's popup
      (id, Admin 2 · village, the colour variable and value) comes back as the
      module message `map_popup`
    - controls: zoom +/-, box zoom (button, or Shift + drag), zoom to the
      households, full screen (the map card), metric scale, attribution
    - basemap switcher (Light, Dark, Terrain (default), Satellite, Satellite
      (Clarity)); dark mode shows Dark, light mode the base chosen before;
      satellite 404 tiles replaced by the enlarged image above (`twsat://`)
    - `map_plot_bounds` (north, south, east, west) on every move, debounced
- data collection (always in view)
  - title "Data collection", chip "All N households" or
    "Map view: n of N households" + "show all" (`view_all`)
  - "Follow the map" switch (`view_follow`, off by default)
  - "Not available with these data:" strip
  - tiles: Households, Individuals, Communities, Days of collection, Households
    per day, Enumerators (each only when its field is mapped)
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
- [x] map: MapLibre + deck.gl canvases, 1,500 points, legend; recolour keeps the view; number ramp; popup on click; follow the map ("Map view: 142 of 1,500"), show all; basemap switch; dark basemap and back
- [x] 1.5 million households (`TW_BIG=<file> ... test_overview.R`): see "Large data" below
- [x] chip, follow switch, show all
- [x] table builder: rows / columns, counts, row % (totals 100%), mean (number picker shows), one-way, chi-square, too many options
- [x] chart builder: every type, with and without groups (14 combinations), too many options, Axes dialog
- [x] dark mode, light mode screenshots
- [ ] French labels of the new builder texts (t() falls back to English until www/translations.json has them)

## Deliberate divergences

- Map: MapLibre + deck.gl instead of leaflet + leafgl; the basemap is a
  select on the map (not leaflet's layers menu) and is the client's state
  (not saved on the server); every popup is built on click (leaflet carried
  them inline up to 20,000 points); no "Zoom to the households" fit padding
  of one degree on "show all" (it fits the households like the first view).

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

## Large data (map)

Measured 2026-10-07 on a synthetic file of 1,500,000 households
(registration_demo columns resampled, GPS jittered; Parquet, 42 MB):

| | demo (1,500) | 1,500,000 |
|---|---|---|
| `map_points` JSON | 16 KB | 16.0 MB (encode 0.18 s + toJSON 0.22 s) |
| `map_colours` JSON | 2 KB | 2.0 MB (0.12 s categories, 0.21 s number scale) |
| mapping confirmed -> points drawn (browser) | 1.7 s | 39.6 s (mostly the setup and the page's other figures on 1.5M rows, not the map) |

Recolour, popup, follow the map ("Map view: 865,192 of 1,500,000"), show
all and basemaps all pass at 1.5M. Panning in the headless test browser runs
on WARP (CPU WebGL): 60 fps without points, 1 fps with 1.5M outlined points,
3.3 fps without outlines, so above 200,000 points they are drawn without the
outline. A real GPU draws 1.5M deck.gl points at full frame rate.
`ui.js` grew by about 3.5 KB (MapView); MapLibre, deck.gl and the MapLibre
worker are the chunk `chunks/mapgl-*.js` (2.6 MB, 661 KB gzip), loaded the
first time the Overview shows.
