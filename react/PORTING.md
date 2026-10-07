# Porting a page to React (shinyreact)

The app is a React client (`react/src`, built to `inst/app/react/ui.js`) on the
same Shiny server. A page is ported when `react/src/pages/<name>/index.tsx`
exists: it exports `page` (the page value, e.g. `"dq_panel"`) and a default
component `({ active, t })`. The shell finds it, stops rendering the Shiny
page for it (`input$tw_ported`, `render_legacy_pages()`), and shows it.

**The rule: keep the server, redraw the client.** Every input keeps its id,
every output its id, every observer its logic. Only the UI function
(`mod_<x>_ui`) is replaced by the React page, and the render functions of
tables and charts change. Session save/restore, `update*Input()`,
`nav_select()`, `gate_button()`, `need_ok()`, showModal() dialogs, downloads
and the audit trail keep working because the ids do.

Reference pages: `src/pages/audit/` (small, toolkit only) and
`src/pages/overview/` (large: JSON outputs, hosted map and builders).
The toolkit is `src/lib/`, tested by `dev/gallery/` (`npm run gallery`, then
`NOT_CRAN=true Rscript react/dev/gallery/test.R` from the package root).

## The toolkit (src/lib)

Ids are full ids: inside module `dq_1`, input `x` is `"dq_1-x"`
(`const ns = (x: string) => "dq_1-" + x`).

| Shiny | React | Notes |
|---|---|---|
| selectInput / selectizeInput / pickerInput | `SelectInput` (`multiple`, `actions` for select all / none) | R gets a character vector; multiple empty = NULL. Choices: `string[]`, `{label: value}` or `Choice[]` (with `group`). |
| numericInput | `NumericInput` | NULL when empty |
| textInput / textAreaInput / passwordInput | `TextInput` (`area`, `password`) | |
| checkboxInput / input_switch / materialSwitch | `CheckboxInput` (`asSwitch`) | |
| radioButtons / radioGroupButtons | `RadioInput` (`buttons` for the segmented look) | |
| checkboxGroupInput | `CheckboxGroupInput` | |
| sliderInput | `SliderInput` (one value or `[lo, hi]`) | |
| dateInput / dateRangeInput / airDatepickerInput | `DateInput` (`range`) | R gets Dates |
| actionButton / actionLink | `ActionButton` (`link`) | counts from 0: server observers on it need `req(input$x > 0)` (or `> 0` in an if) since React sends the initial 0. `gate_button()` works. |
| downloadButton | `DownloadButton` | the server's `download_handler()` unchanged |
| uiOutput / renderUI | `HostedUI` | keep for fileInput, leaflet, rich_text_input(), and server HTML that is not worth redrawing. Shiny binds inputs inside it. |
| textOutput | `TextOutput` | |
| DTOutput / renderDT | `DataTable` + `render_react_table()` | see below |
| plotlyOutput / render_wfp_plotly | `Chart` + `render_echart()` | see below |
| card(full_screen = TRUE) | `Card` (`full`) | |
| layout_sidebar + side_steps / side_actions | `SidebarLayout` + `Steps` + `SideActions` | one step open at a time; give folded steps a `summary` |
| navset_* (with id) | `Tabs` (`id` makes it input$<id>; nav_select() works) | panels stay mounted |
| accordion | `Steps`, or a local open/closed state | |
| value boxes | `Tiles` in `src/components/Figures.tsx`, or a small card | |
| empty_state() | `EmptyState` (Figures.tsx) | |
| notices / callouts | `Notice` | |

Server updates reach React inputs unchanged: `update*Input()`,
`updatePickerInput()`, `nav_select()` messages go to a hidden element with
the input's id (`useServerUpdates`). So the visible control never uses the
id itself; `ActionButton` and `DownloadButton` do (for gates).

`cascade_pickers()` and its `tw-input-visible` message work (a hidden level's
`Field` disappears).

Show / hide by input value (conditionalPanel): read the value in React with
`useShinyInputValue(id)` (or keep the `useShinyInput` state) and render
conditionally. For conditions on server state, send the state as a JSON
output (`shinyreact::reactive_output()`, read with `useShinyOutputValue`),
as the Overview does (`ov_meta`, `ov_view`).

Server text in the UI (counts, summaries, status lines) that the Shiny page
built with renderUI: either keep `HostedUI` (fine for rich server HTML) or,
better, send the facts as a `reactive_output()` list and draw them in React.
Prefer the second for anything the user looks at often (KPIs, tiles, step
status, lists).

Dialogs: `showModal()` dialogs stay Shiny's (Bootstrap, styled by
wfp-ui.css) and their inputs are Shiny inputs. Leave them. `Dialog` (layout)
is for dialogs that exist only in the client.

## Tables: render_react_table()

Replace `DT::renderDT({...})` by `render_react_table({...}, ...)`. The
expression may still return the `tw_datatable()` / `DT::datatable()` widget:
its data, colnames, pageLength, selection mode and RowGroup are read from it.
DT formatting (formatStyle, formatPercentage, ...) is not; say it with:

- `formats = list(col = "int" | "num" | "dec1" | "dec2" | "pct" | "pct1" | "date" | "datetime" | "text")`
  (pct: the value is a share 0-1)
- `styles = list(col = list(map = list(OK = c(bg = "#d7ead8", color = "#1f2a37"))))`,
  bands `list(breaks = c(90, 95), colors = c(red, amber, green))` (DT::styleInterval),
  data bars `list(bar = "#0A6EB4")`
- `html = "col"` for cells holding markup the app wrote (escape user text)
- `editable = c("col")` -> `input$<id>_cell_edit` = list(row, col (data frame column, from 1), value)
- `group = "col"` (bands of rows), `labels = list(col = "Header")`, `empty = "Nothing yet."`
- `server_rows` (5000): above, paging / sort / search run on the server.

Inputs kept: `<id>_rows_selected` (row numbers in the data), `<id>_rows_all`.
`DT::selectRows(proxy, rows)` becomes `react_table_select("<output id>", rows)`
(inside a module: the un-namespaced id; it uses the module session).
Remove `dataTableProxy()` calls.

In React: `<DataTable id={ns("tab")} />` (`height`, `toolbar`, `searchable`, `compact`).

## Charts: render_echart()

Replace `render_wfp_plotly({...})` by `render_echart({...})`. A plotly
object is converted (`plotly_to_echarts()`: bar, stacked bar, line, scatter,
box, pie/donut, heatmap, histogram, straight reference lines). Check each
chart in the browser; when the conversion falls short, return an ECharts
option instead (a nested list, https://echarts.apache.org/en/option.html):

```r
render_echart({
  d <- by_day()
  list(
    tooltip = list(trigger = "axis"),
    xAxis = list(type = "category", data = format(d$day, "%d/%m")),
    yAxis = list(type = "value"),
    series = list(list(type = "bar", name = "Households", data = d$n))
  )
}, height = 260)
```

Formatters are names: `"fn:pct"`, `"fn:pct1"`, `"fn:num"`, `"fn:dec1"`,
`"fn:dec2"`, `"fn:tip"` (tooltip = each data item's `tip`, so put the hover
text in `data = list(list(value = 3, tip = "<b>3</b> households"))`; escape
user text with `htmltools::htmlEscape()`). Colours and fonts come from the
theme (WFP palette, light and dark); set colours only when they carry
meaning (verdict colours, severity). `attr(option, "height") <- 400` sets
the height from the server. Do not use JS functions (JSON cannot carry them).

In React: `<Chart id={ns("plot")} height={300} />`, usually inside
`<Card title=... full>`. Validation messages (`need()`) show in its place.

Every chart that had a `chart_help()` entry keeps it: put the help text in
the card (the server's `CHART_HELP` entry, e.g. as a `title` tooltip on an
info icon). The chart-help test (`tests/testthat/test-chart-help.R`) reads
R code; keep `chart_help(id)` references valid or update the test.

## Hidden outputs wait (performance)

Shiny pauses an output while it is hidden (`suspendWhenHidden`, the default),
and computes it when it shows. React outputs report it: `Chart` and
`DataTable` do it themselves (`src/lib/visibility.ts`). A JSON output
(`reactive_output()`) that is costly to compute must say where it is drawn:
`const ref = useRef<HTMLDivElement>(null); useOutputVisibility(ns("ov_profile"), ref);`
on the section that shows it. Cheap state outputs (step status, metadata a
page needs to lay itself out) need nothing. `suspendWhenHidden = FALSE` on
an output keeps it computing while hidden: only for what must exist before
it is seen (file inputs, downloads in folded sections).

## Code loaded on demand

`ui.js` is an ES module; heavy libraries are separate chunks loaded the
first time they are needed (`import()`): ECharts (`src/lib/echarts-core.ts`:
register a new chart type or component there, or it will not draw) and the
map. Do not import a heavy library statically from a page.

## Conventions (from AGENTS.md, still true)

- One `btn-primary` per view; the rest outline. Destructive: `outline-danger`.
- Settings wait for their button: the server already reads applied values;
  do not add live computation in React that the server code did not have.
- Card headers are quiet labels; icons from lucide-react (`size={15}`).
- English labels through `t("...")` (www/translations.json has the French).
- No hardcoded text colours on charts; WFP hexes for meaning only.
- Dark mode: use Bootstrap / token variables (`var(--bs-body-bg)`,
  `var(--bs-secondary-color)`, `var(--wfp-blue)`), never fixed light colours
  for surfaces or text.
- Large data: never send the whole data set to the client; tables page on
  the server above 5,000 rows; charts get aggregates.
- R code stays ASCII (`\u` escapes); keep R files parseable at all times.

## Files and working together

- A page's React code lives in `react/src/pages/<name>/` (components, its own
  `.css` imported by its components, its `PORT.md`: behaviour tree, checklist,
  deliberate divergences).
- Do not edit `src/App.tsx`, `src/lib/*`, `src/components/*`, `src/shiny.ts`,
  `R/utils_react*.R`, `R/app_server.R`, `R/app_ui.R` in a page port. If the
  toolkit needs a fix, make the smallest fix, keep the gallery passing, and
  say so in your report.
- Shared R helpers (`R/utils_*.R`) used by other pages: add, do not change
  behaviour others rely on.
- Build: `cd react && npm run build` (locked; safe when others build).
  Typecheck: `npm run typecheck` and look at your own files' errors.
- Test: a script using `react/dev/e2e.R` (`tw_launch()`,
  `tw_load_registration()`, `tw_go()`, `tw_shot()`, `tw_errors()`), run with
  `NOT_CRAN=true Rscript <script>` from the package root. Never
  `R CMD INSTALL` (other apps run from the installed package).
- Unit tests: `Rscript -e "devtools::test(filter = '<name>')"` for the R
  files you touched.
