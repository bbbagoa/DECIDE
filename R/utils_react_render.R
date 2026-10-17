#' React inputs, tables and charts (react/src/lib/): the server side
#'
#' Pages drawn by React keep their Shiny server code. Inputs keep their ids
#' (and `update*Input()` / `nav_select()` still reach them, see
#' react/src/lib/inputs.tsx); tables and charts are sent as data:
#' `render_react_table()` replaces `DT::renderDT()`, `render_echart()`
#' replaces `render_wfp_plotly()`.
#' @name react_render
NULL

#' Input types the React inputs send (`type` in useShinyInput)
#'
#' "tw.chr": a character vector, NULL when nothing is chosen (as a Shiny
#' select or picker); "tw.num": numbers, NULL when empty; "tw.date": Dates.
#' @noRd
tw_register_input_handlers <- function() {
  flat <- function(x) if (is.null(x) || !length(x)) NULL else unlist(x, use.names = FALSE)
  shiny::registerInputHandler("tw.chr", function(x, ...) {
    x <- flat(x); if (is.null(x)) NULL else as.character(x)
  }, force = TRUE)
  shiny::registerInputHandler("tw.num", function(x, ...) {
    x <- flat(x); if (is.null(x)) NULL else suppressWarnings(as.numeric(x))
  }, force = TRUE)
  shiny::registerInputHandler("tw.date", function(x, ...) {
    x <- flat(x); if (is.null(x)) NULL else suppressWarnings(as.Date(substr(as.character(x), 1, 10)))
  }, force = TRUE)
  invisible(NULL)
}

#' A table drawn by React (`<DataTable id>` in react/src/lib/table.tsx)
#'
#' Replaces `DT::renderDT()`. `expr` returns a data frame, or a DT widget
#' (`tw_datatable()` / `DT::datatable()`), whose data, column names, page
#' length, selection mode and row groups are kept (DT formatting is not: use
#' `formats` / `styles`). The client keeps DT's inputs: `<id>_rows_selected`
#' (row numbers in the data), `<id>_rows_all` (rows left by the search),
#' `<id>_cell_edit` (a data frame row, col, value; col counts from 1).
#' Above `server_rows` rows the paging, sorting and search run here.
#'
#' @param formats Named list, column -> "int", "num", "dec1", "dec2", "pct",
#'   "pct1" (a share 0-1), "date", "datetime", "text".
#' @param styles Named list, column -> list(map = list(<value> = c(bg =, color =)))
#'   or list(breaks = c(...), colors = c(...), text = c(...)) (bands, as
#'   DT::styleInterval: one more colour than breaks), list(bar = colour), or
#'   list(cell = c(bg =, color =)) for every non-empty cell of the column.
#' @param html Columns holding markup the app wrote (drawn as HTML; never
#'   put user data there unescaped).
#' @param editable Columns that can be edited (names), or TRUE for all.
#' @param group Column whose values start a band of rows (DT RowGroup).
#' @param labels Named list, column -> header text.
#' @param height Pixels for the scrolling body, or NULL (as tall as the page).
#' @noRd
render_react_table <- function(expr, page_size = NULL, selection = NULL, formats = list(), styles = list(),
                               html = character(), editable = NULL, group = NULL, labels = NULL,
                               empty = "No data.", server_rows = 5000, height = NULL,
                               env = parent.frame(), quoted = FALSE) {
  func <- shiny::installExprFunction(expr, "func", eval.env = env, quoted = quoted, label = "render_react_table")
  # the data is computed once; paging, sorting and search only slice it
  data_r <- shiny::reactive(func())
  shiny::createRenderFunction(function() data_r(), function(value, session, name, ...) {
    spec <- react_table_spec(value, page_size = page_size, selection = selection, group = group, labels = labels)
    if (is.null(spec)) return(NULL)
    react_table_payload(spec, session$input[[paste0(name, "_state")]], formats = formats, styles = styles,
                        html = html, editable = editable, empty = empty, server_rows = server_rows, height = height)
  })
}

#' The data and settings of a table, from a data frame or a DT widget
#' @noRd
react_table_spec <- function(value, page_size = NULL, selection = NULL, group = NULL, labels = NULL) {
  if (is.null(value)) return(NULL)
  sel <- selection; pl <- page_size; grp <- group; lab <- labels
  if (inherits(value, "datatables")) {
    x <- value$x
    df <- as.data.frame(x$data, stringsAsFactors = FALSE, check.names = FALSE)
    has_rn <- ncol(df) > 0 && names(df)[1] %in% c("", " ")
    th <- regmatches(x$container %||% "", gregexpr("<th[^>]*>(.*?)</th>", x$container %||% "", perl = TRUE))[[1]]
    th <- gsub("<[^>]+>", "", th)
    rg <- x$options$rowGroup$dataSrc
    if (is.null(grp) && length(rg) == 1) {
      k <- as.integer(rg) + 1L
      if (k <= ncol(df)) grp <- names(df)[k]
    }
    # rownames = TRUE puts them in a first, unnamed column
    if (has_rn) { df <- df[-1]; if (length(th) == ncol(df) + 1L) th <- th[-1] }
    if (is.null(lab) && length(th) == ncol(df)) lab <- stats::setNames(as.list(th), names(df))
    if (is.null(sel)) sel <- x$selection$mode %||% "none"
    if (is.null(pl)) pl <- x$options$pageLength
  } else df <- as.data.frame(value, stringsAsFactors = FALSE, check.names = FALSE)
  list(data = df, labels = lab %||% list(), selection = sel %||% "none", page_size = as.integer(pl %||% 15L),
       group = if (length(grp) == 1 && !is.na(grp) && grp %in% names(df)) grp else NULL)
}

#' What the client gets: columns, the rows to draw, their numbers in the data
#' @noRd
react_table_payload <- function(spec, st = NULL, formats = list(), styles = list(), html = character(),
                                editable = NULL, empty = "No data.", server_rows = 5000, height = NULL) {
  df <- spec$data
  total <- nrow(df)
  server <- total > server_rows
  idx <- seq_len(total)
  if (server) {
    q <- tolower(trimws(st$search %||% ""))
    if (nzchar(q)) {
      hit <- Reduce(`|`, lapply(df, function(x) grepl(q, tolower(as.character(x)), fixed = TRUE)), FALSE)
      idx <- which(hit)
    }
    sc <- st$sort %||% ""
    if (nzchar(sc) && sc %in% names(df)) idx <- idx[order(df[[sc]][idx], decreasing = isTRUE(st$desc), na.last = TRUE)]
    size <- as.integer(st$size %||% spec$page_size)
    page <- max(0L, as.integer(st$page %||% 0L))
    if (page * size >= length(idx)) page <- 0L
    keep <- idx[seq_len(min(size, max(0L, length(idx) - page * size))) + page * size]
  } else {
    page <- 0L
    keep <- idx
  }
  kind <- function(x) if (inherits(x, "POSIXt")) "datetime" else if (inherits(x, "Date")) "date"
                      else if (is.numeric(x)) "number" else if (is.logical(x)) "logical" else "text"
  cols <- lapply(names(df), function(k) {
    list(key = k, label = as.character(spec$labels[[k]] %||% k), type = kind(df[[k]]),
         format = formats[[k]], style = styles[[k]], html = k %in% html,
         editable = isTRUE(editable) || k %in% editable)
  })
  cell <- function(x) {
    if (inherits(x, "POSIXt")) return(format(x, "%Y-%m-%dT%H:%M:%S"))
    if (inherits(x, "Date")) return(format(x))
    if (is.factor(x)) return(as.character(x))
    if (is.list(x)) return(vapply(x, function(v) paste(as.character(unlist(v)), collapse = ", "), ""))
    x
  }
  sub <- df[keep, , drop = FALSE]
  cc <- lapply(sub, cell)
  rows <- lapply(seq_along(keep), function(i) unname(lapply(cc, function(v) {
    z <- v[[i]]
    if (length(z) != 1 || is.na(z)) NULL else z
  })))
  list(columns = cols, rows = rows, index = I(keep), total = total, filtered = length(idx), page = page,
       server = server, page_size = spec$page_size, selection = spec$selection, group = spec$group,
       empty = empty, height = height)
}

#' Select rows of a React table from the server (as DT::selectRows())
#' @param id The table's output id (inside a module: the id given to output$).
#' @param rows Row numbers in the data, or NULL to clear.
#' @noRd
react_table_select <- function(id, rows, session = shiny::getDefaultReactiveDomain()) {
  shinyreact::send_message(session, paste0(id, "__select"), list(rows = I(as.integer(rows %||% integer(0)))))
  invisible(NULL)
}

#' A chart drawn by ECharts (`<Chart id>` in react/src/lib/chart.tsx)
#'
#' Replaces `render_wfp_plotly()`. `expr` returns an ECharts option (a list,
#' https://echarts.apache.org/en/option.html), or a plotly chart, converted
#' by `plotly_to_echarts()` (bars, lines, scatter, box, pie, heatmap,
#' histogram, straight reference lines). Write new charts as options.
#' Formatters are named strings the client turns into functions: "fn:pct"
#' (0.25 -> 25%), "fn:pct1", "fn:num" (1,234), "fn:dec1", "fn:dec2",
#' "fn:tip" (a tooltip showing each data item's `tip` field, HTML allowed:
#' escape user text with htmltools::htmlEscape()). Colours and fonts come
#' from the WFP theme; leave them out unless they carry meaning.
#' @param height Pixels (attr(option, "height") wins), or NULL for 320.
#' @noRd
render_echart <- function(expr, height = NULL, env = parent.frame(), quoted = FALSE) {
  func <- shiny::installExprFunction(expr, "func", eval.env = env, quoted = quoted, label = "render_echart")
  shiny::createRenderFunction(func, function(value, session, name, ...) {
    if (is.null(value)) return(NULL)
    if (inherits(value, "plotly")) value <- plotly_to_echarts(value)
    h <- attr(value, "height") %||% height
    attr(value, "height") <- NULL
    list(option = value, height = h)
  })
}

#' A plotly chart as an ECharts option (best effort; see render_echart())
#' @noRd
plotly_to_echarts <- function(p) {
  b <- plotly::plotly_build(p)$x
  lay <- b$layout %||% list()
  tr <- Filter(function(t) !identical(t$visible, FALSE) && !identical(t$visible, "legendonly"), b$data %||% list())
  ax_title <- function(a) { t <- a$title; if (is.list(t)) t$text else t }
  is_pct <- function(a) grepl("%", a$tickformat %||% "") || identical(a$ticksuffix, "%")
  plain <- function(v) { if (is.null(v)) return(NULL); if (is.list(v)) v <- unlist(lapply(v, function(e) e %||% NA)); v }
  tipof <- function(t, n) {
    h <- plain(t$hovertext) %||% plain(t$text)
    if (is.null(h) || !length(h)) return(NULL)
    gsub("<extra>.*?</extra>", "", rep_len(as.character(h), n))
  }
  types <- vapply(tr, function(t) t$type %||% "scatter", "")
  out <- list(legend = list(show = !identical(lay$showlegend, FALSE) && length(tr) > 1, top = 0, type = "scroll"),
              grid = list(left = 8, right = 16, top = if (length(tr) > 1) 34 else 16, bottom = 8, containLabel = TRUE))
  if (!is.null(lay$title)) {
    tt <- if (is.list(lay$title)) lay$title$text else lay$title
    if (length(tt) && nzchar(tt)) out$title <- list(text = tt, textStyle = list(fontSize = 13))
  }
  if (length(tr) && all(types == "pie")) {
    out$series <- lapply(tr, function(t) {
      lab <- as.character(plain(t$labels)); val <- as.numeric(plain(t$values)); tip <- tipof(t, length(val))
      hole <- as.numeric(t$hole %||% 0)
      list(type = "pie", radius = c(paste0(round(hole * 70), "%"), "70%"), name = t$name %||% "",
           data = lapply(seq_along(val), function(i) c(list(name = lab[i], value = val[i]), if (!is.null(tip)) list(tip = tip[i]))))
    })
    has_tip <- any(vapply(tr, function(t) !is.null(t$text) || !is.null(t$hovertext), TRUE))
    out$tooltip <- list(trigger = "item", formatter = if (has_tip) "fn:tip" else NULL)
    out$grid <- NULL
    return(out)
  }
  if (any(types == "heatmap")) {
    t <- tr[[which(types == "heatmap")[1]]]
    z <- t$z
    if (is.list(z)) z <- do.call(rbind, lapply(z, function(r) as.numeric(plain(r))))
    z <- as.matrix(z)
    xs <- as.character(plain(t$x) %||% seq_len(ncol(z))); ys <- as.character(plain(t$y) %||% seq_len(nrow(z)))
    d <- list()
    for (i in seq_len(nrow(z))) for (j in seq_len(ncol(z))) d[[length(d) + 1]] <- list(j - 1, i - 1, if (is.na(z[i, j])) "-" else z[i, j])
    rng <- range(z, na.rm = TRUE)
    out$xAxis <- list(type = "category", data = xs, name = ax_title(lay$xaxis), nameLocation = "middle", nameGap = 28)
    out$yAxis <- list(type = "category", data = ys, name = ax_title(lay$yaxis))
    cols <- if (rng[1] >= 0) c("#e8f1f9", "#007DBC") else c("#c5192d", "#f4f6f8", "#007DBC")
    out$visualMap <- list(min = rng[1], max = rng[2], calculable = TRUE, orient = "horizontal", left = "center",
                          bottom = 0, inRange = list(color = cols))
    out$series <- list(list(type = "heatmap", data = d, label = list(show = length(d) <= 150, formatter = "fn:hmap")))
    out$tooltip <- list(trigger = "item")
    out$grid$bottom <- 48
    return(out)
  }
  horiz <- any(vapply(tr, function(t) identical(t$orientation, "h"), TRUE))
  xs_list <- lapply(tr, function(t) if (horiz) t$y else t$x)
  # unlist() drops the Date class: dates are read per trace
  dated <- any(vapply(xs_list, function(v) inherits(v, c("Date", "POSIXt")), TRUE))
  xs_all <- if (dated) as.character(do.call(c, lapply(xs_list, as.character))) else unlist(lapply(xs_list, plain))
  is_date <- dated || (is.character(xs_all) && length(xs_all) && all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}", xs_all)))
  cat_axis <- any(types %in% c("bar", "box", "violin")) || ((is.character(xs_all) || is.factor(xs_all)) && !is_date)
  cats <- if (cat_axis && !is.null(xs_all)) unique(as.character(xs_all)) else NULL
  if (cat_axis && is_date) cats <- sort(cats)
  # the category order plotly was told to keep
  ord <- (if (horiz) lay$yaxis else lay$xaxis)$categoryarray
  if (cat_axis && length(ord)) cats <- unique(c(as.character(plain(ord)), cats))
  stack <- identical(lay$barmode, "stack") || identical(lay$barmode, "relative")
  series <- list()
  for (t in tr) {
    ty <- t$type %||% "scatter"
    xv <- plain(if (horiz) t$y else t$x); yv <- plain(if (horiz) t$x else t$y)
    col <- t$marker$color %||% t$line$color
    if (ty %in% c("box", "violin")) {
      if (!is.null(t$q1)) {
        g <- as.character(plain(if (horiz) t$y else t$x) %||% t$name)
        d <- lapply(seq_along(g), function(i) list(name = g[i], value = c(
          (plain(t$lowerfence) %||% plain(t$q1))[i], plain(t$q1)[i], plain(t$median)[i], plain(t$q3)[i],
          (plain(t$upperfence) %||% plain(t$q3))[i])))
      } else {
        vals <- as.numeric(yv)
        grp <- if (is.null(xv)) rep(t$name %||% "", length(vals)) else as.character(xv)
        d <- lapply(unique(grp), function(k) list(name = k, value = grDevices::boxplot.stats(vals[grp == k & !is.na(vals)])$stats))
      }
      if (is.null(cats)) cats <- unique(unlist(lapply(d, `[[`, "name")))
      dd <- lapply(cats, function(k) { m <- Filter(function(e) identical(e$name, k), d); if (length(m)) m[[1]]$value else "-" })
      series[[length(series) + 1]] <- list(type = "boxplot", name = t$name %||% "", data = dd,
                                           itemStyle = if (is.character(col) && length(col) == 1) list(borderColor = col))
      next
    }
    if (ty == "histogram") {
      v <- plain(if (horiz) t$y else t$x)
      if (is.numeric(v)) {
        h <- graphics::hist(v[!is.na(v)], plot = FALSE)
        cats <- cats %||% format(h$mids)
        d <- h$counts
      } else {
        # a histogram of categories counts them
        cats <- cats %||% unique(as.character(v))
        d <- as.numeric(table(factor(as.character(v), levels = cats)))
      }
      cat_axis <- TRUE
      series[[length(series) + 1]] <- list(type = "bar", name = t$name %||% "", stack = if (stack) "s",
                                           barCategoryGap = if (is.numeric(v)) "2%", data = d)
      next
    }
    n <- length(yv); tip <- tipof(t, n)
    item <- function(i, v) {
      e <- list(value = v)
      if (!is.null(tip)) e$tip <- tip[i]
      if (length(col) > 1) e$itemStyle <- list(color = col[[i]])
      e
    }
    if (cat_axis) {
      pos <- match(as.character(xv), cats)
      d <- rep(list("-"), length(cats))
      for (i in seq_len(n)) if (!is.na(pos[i])) d[[pos[i]]] <- item(i, if (is.na(yv[[i]])) "-" else yv[[i]])
    } else {
      d <- lapply(seq_len(n), function(i) item(i, list(if (is_date) as.character(xv[[i]]) else xv[[i]], if (is.na(yv[[i]])) "-" else yv[[i]])))
    }
    mode <- t$mode %||% if (ty == "bar") "" else "markers"
    s <- if (ty == "bar") list(type = "bar", stack = if (stack) "s")
         else if (grepl("lines", mode)) list(type = "line", showSymbol = grepl("markers", mode),
                                             lineStyle = list(type = if ((t$line$dash %||% "solid") %in% c("dash", "dot", "dashdot")) "dashed" else "solid"),
                                             areaStyle = if (!is.null(t$fill) && !identical(t$fill, "none")) list(opacity = 0.25))
         else list(type = "scatter", symbolSize = as.numeric(t$marker$size %||% 6)[1], large = n > 5000)
    s$name <- t$name %||% ""
    s$data <- d
    if (is.character(col) && length(col) == 1) s$itemStyle <- list(color = col)
    if (identical(t$yaxis, "y2")) s$yAxisIndex <- 1
    series[[length(series) + 1]] <- s
  }
  xa <- lay$xaxis %||% list(); ya <- lay$yaxis %||% list()
  ca <- if (horiz) ya else xa
  va <- if (horiz) xa else ya
  cax <- if (cat_axis) list(type = "category", data = cats, name = ax_title(ca), nameLocation = "middle", nameGap = 28,
                            axisLabel = list(interval = if (length(cats) <= 30) 0 else "auto", hideOverlap = TRUE))
         else list(type = if (is_date) "time" else "value", name = ax_title(ca), nameLocation = "middle", nameGap = 28, scale = TRUE)
  vax <- list(type = "value", name = ax_title(va), nameLocation = "middle", nameGap = 40,
              axisLabel = if (is_pct(va)) list(formatter = "fn:pct"))
  rg <- va$range
  if (length(rg) == 2 && !identical(va$autorange, TRUE)) { vax$min <- rg[[1]]; vax$max <- rg[[2]] }
  if (horiz) {
    cax$inverse <- TRUE
    out$xAxis <- vax; out$yAxis <- cax
  } else {
    out$xAxis <- cax; out$yAxis <- vax
  }
  if (!is.null(lay$yaxis2)) out$yAxis <- list(out$yAxis, list(type = "value", name = ax_title(lay$yaxis2), splitLine = list(show = FALSE)))
  # straight lines among the shapes become reference lines on the first series
  ml <- list()
  for (sh in lay$shapes %||% list()) if (identical(sh$type, "line")) {
    if (!is.null(sh$x0) && identical(sh$x0, sh$x1) && !identical(sh$xref, "paper")) {
      ml[[length(ml) + 1]] <- if (horiz) list(yAxis = sh$x0) else list(xAxis = sh$x0)
    } else if (!is.null(sh$y0) && identical(sh$y0, sh$y1) && !identical(sh$yref, "paper")) {
      ml[[length(ml) + 1]] <- if (horiz) list(xAxis = sh$y0) else list(yAxis = sh$y0)
    }
  }
  if (length(ml) && length(series)) series[[1]]$markLine <- list(silent = TRUE, symbol = "none", label = list(show = FALSE),
                                                                 lineStyle = list(type = "dashed", color = "#5b6b7c"), data = ml)
  out$series <- series
  tips <- any(vapply(series, function(s) any(vapply(s$data, function(e) is.list(e) && !is.null(e$tip), TRUE)), TRUE))
  out$tooltip <- if (tips) list(trigger = "item", formatter = "fn:tip")
                 else list(trigger = if (cat_axis) "axis" else "item", axisPointer = list(type = "shadow"))
  out
}
