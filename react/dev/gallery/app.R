# The toolkit gallery's server (see gallery.tsx). Run from the package root:
#   shiny::runApp("react/dev/gallery")   (build first: cd react; npm run gallery)
root <- normalizePath(file.path(getwd(), if (dir.exists("react")) "." else "../../.."))
pkgload::load_all(root, quiet = TRUE, export_all = TRUE)
library(shiny)

ui <- shinyreact::page_react(
  src_dir = file.path(root, "react", "dev", "gallery", "www"), title = "Gallery",
  theme = bslib::bs_theme(version = 5, primary = "#0A6EB4"),
  tags$head(golem_add_external_resources())
)

server <- function(input, output, session) {
  output$state <- shinyreact::reactive_output({
    keys <- c("sel", "pick", "rad", "cg", "num", "txt", "sld", "dr", "chk", "tabs", "upd", "gated",
              "tbl_rows_selected", "tbl_rows_all", "tbl_cell_edit", "big_rows_selected")
    out <- lapply(keys, function(k) { v <- input[[k]]; if (is.null(v)) "NULL" else list(class = class(v)[1], value = if (inherits(v, "Date")) format(v) else v) })
    stats::setNames(out, keys)
  })
  observe(gate_button("gated", FALSE, "Not yet: this button is frozen."))
  observeEvent(input$upd, {
    req(input$upd > 0)
    updateSelectInput(session, "sel", choices = c("x", "y", "z"), selected = "y")
    shinyWidgets::updatePickerInput(session, "pick", choices = c(One = "1", Two = "2"), selected = c("1", "2"))
    updateRadioButtons(session, "rad", selected = "three")
    updateNumericInput(session, "num", value = 42)
    updateTextInput(session, "txt", value = "from the server")
    updateSliderInput(session, "sld", value = c(20, 30))
    updateCheckboxInput(session, "chk", value = TRUE)
    updateCheckboxGroupInput(session, "cg", selected = "y")
    updateDateRangeInput(session, "dr", start = "2026-01-01", end = "2026-02-01")
    bslib::nav_select("tabs", "tables")
  })
  observeEvent(input$selrows, { req(input$selrows > 0); react_table_select("tbl", 1:3) })
  output$tbl <- render_react_table({
    d <- data.frame(id = 1:40, name = paste("Household", 1:40), size = (1:40 %% 9) + 1,
                    share = (1:40) / 40, status = rep(c("OK", "Review", "At risk", "OK"), 10),
                    when = as.Date("2026-01-01") + 0:39, stringsAsFactors = FALSE)
    tw_datatable(d, selection = "multiple", options = list(pageLength = 10), rownames = FALSE,
                 colnames = c("ID", "Name", "Size", "Share", "Status", "Date"))
  }, formats = list(share = "pct"), editable = "name",
     styles = list(status = list(map = list(OK = c(bg = "#d7ead8"), Review = c(bg = "#fdeec4"), `At risk` = c(bg = "#f6d2d6"))),
                   size = list(bar = "#0A6EB4")))
  output$big <- render_react_table(data.frame(i = 1:20000, g = sample(letters, 20000, TRUE), x = round(runif(20000), 3)),
                                   selection = "single", server_rows = 5000)
  set.seed(1)
  df <- data.frame(g = rep(c("North", "South", "East"), each = 50), sex = rep(c("F", "M"), 75), v = rnorm(150, 50, 10))
  output$c_bar <- render_echart(plotly::plot_ly(x = c("A", "B", "C"), y = c(3, 5, 2), type = "bar", text = c("three", "five", "two"), hoverinfo = "text"))
  output$c_hbar <- render_echart({
    plotly::plot_ly(df, y = ~g, color = ~sex, type = "histogram", orientation = "h") |> plotly::layout(barmode = "stack")
  })
  output$c_line <- render_echart(plotly::plot_ly(x = as.Date("2026-01-01") + 0:20, y = cumsum(1:21), type = "scatter", mode = "lines+markers"))
  output$c_scatter <- render_echart(plotly::plot_ly(df, x = ~v, y = ~v * 2 + rnorm(150), type = "scatter", mode = "markers"))
  output$c_box <- render_echart(plotly::plot_ly(df, x = ~g, y = ~v, type = "box"))
  output$c_pie <- render_echart(plotly::plot_ly(labels = c("Yes", "No"), values = c(70, 30), type = "pie", hole = 0.5))
  output$c_heat <- render_echart(plotly::plot_ly(z = matrix(c(1, .5, .2, .5, 1, -.3, .2, -.3, 1), 3), x = c("a", "b", "c"), y = c("a", "b", "c"), type = "heatmap"))
  output$c_hist <- render_echart(plotly::plot_ly(x = df$v, type = "histogram"))
  output$c_option <- render_echart(list(
    xAxis = list(type = "category", data = c("Mon", "Tue", "Wed")), yAxis = list(type = "value", axisLabel = list(formatter = "fn:pct")),
    tooltip = list(trigger = "item", formatter = "fn:tip"),
    series = list(list(type = "bar", data = list(list(value = .2, tip = "<b>20%</b> on Monday"), list(value = .5, tip = "half"), list(value = .8, tip = "most"))))
  ))
  output$dl <- download_handler(filename = function() "gallery.xlsx", content = function(file) write_xlsx_readonly(data.frame(a = 1), file, "a"))
}

shinyApp(ui, server)
