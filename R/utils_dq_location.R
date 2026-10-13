# Location names: the three views of the names at the reviewed level
# (react/src/pages/dq/LocationTab.tsx): similar names as a network, the
# nesting as a sunburst, groups of variants as stacked bars.

LOC_VARIANT_COLOURS <- c("#f7b825", "#c5192d", "#8a5cc7")

#' Names that look alike, grouped
#'
#' @param dat One row per combination of the levels, with `count`
#'   (`norm_data_summary()`).
#' @param col The reviewed level's column.
#' @param max_groups Keep the biggest groups (by records).
#' @param similarity How alike two names must be, 0-1 (`fuzzy_match_groups()`).
#' @return One row per name that has a look-alike: `name`, `count`, `group`
#'   (1 = the biggest group), `label` (the group's most common spelling),
#'   names inside a group most common first.
#' @noRd
loc_similar_groups <- function(dat, col, max_groups = 60, similarity = 0.8) {
  nm <- as.character(dat[[col]])
  keep <- !is.na(nm) & nzchar(trimws(nm))
  n <- tapply(dat$count[keep], nm[keep], sum)
  out <- data.frame(name = names(n), count = as.numeric(n), stringsAsFactors = FALSE)
  if (nrow(out) < 2) return(out[0, ])
  # 0.8: one letter in five may differ (Djugu / Djougou, Mabalako / Mabalakko)
  out$group <- fuzzy_match_groups(out$name, similarity = similarity)
  # Village_04 and Village_06 are two places: numbers must match
  out$group <- ifelse(out$group > 0, paste(out$group, gsub("[^0-9]", "", out$name)), "0")
  out$group[!out$group %in% out$group[duplicated(out$group)]] <- "0"
  out <- out[out$group != "0", , drop = FALSE]
  out$group <- match(out$group, unique(out$group))
  if (!nrow(out)) return(transform(out, label = character(0)))
  tot <- tapply(out$count, out$group, sum)
  rank <- rank(-tot, ties.method = "first")
  out$group <- unname(rank[as.character(out$group)])
  out <- out[out$group <= max_groups, , drop = FALSE]
  out <- out[order(out$group, -out$count, out$name), , drop = FALSE]
  out$label <- trimws(out$name[match(out$group, out$group)])
  rownames(out) <- NULL
  out
}

loc_tip <- function(name, count, extra = NULL) {
  sprintf("<b>&quot;%s&quot;</b><br>%s records%s", htmltools::htmlEscape(name),
          format(count, big.mark = ","), if (is.null(extra)) "" else paste0("<br>", extra))
}

#' Similar names as a force graph: one bubble per name, sized by records,
#' linked to the most common spelling of its group
#' @noRd
loc_network_option <- function(g) {
  big <- max(g$count)
  nodes <- lapply(seq_len(nrow(g)), function(i) list(
    id = as.character(i), name = g$name[i], value = g$count[i], category = g$group[i] - 1L, group = g$group[i],
    symbolSize = round(10 + 38 * sqrt(g$count[i] / big), 1),
    tip = loc_tip(g$name[i], g$count[i], paste("Group:", htmltools::htmlEscape(g$label[i])))))
  head_of <- match(g$group, g$group)
  links <- lapply(which(head_of != seq_len(nrow(g))), function(i)
    list(source = as.character(head_of[i]), target = as.character(i), tip = "Similar spelling"))
  dq_compact(list(
    tooltip = list(trigger = "item", formatter = "fn:tip"),
    series = list(list(
      type = "graph", layout = "force", roam = TRUE, draggable = TRUE, data = nodes, links = links,
      categories = lapply(unique(g$label[order(g$group)]), function(x) list(name = x)),
      force = list(repulsion = 120, edgeLength = I(c(20, 60)), gravity = 0.1),
      label = list(show = TRUE, position = "right", fontSize = 10),
      labelLayout = list(hideOverlap = TRUE),
      lineStyle = list(color = "source", width = 2, opacity = 0.6, curveness = 0.1),
      emphasis = list(focus = "adjacency", lineStyle = list(width = 4))
    ))
  ))
}

#' The levels as a sunburst: the top level in the centre, sized by records;
#' only segments wide enough carry a label
#' @noRd
loc_sunburst_option <- function(dat) {
  lv <- setdiff(names(dat), "count")
  node <- function(d, k) {
    if (k > length(lv)) return(NULL)
    key <- as.character(d[[lv[k]]]); key[is.na(key)] <- "(missing)"
    lapply(split(seq_len(nrow(d)), factor(key, levels = unique(key))), function(i) {
      kids <- node(d[i, , drop = FALSE], k + 1)
      c(list(name = key[i[1]], value = sum(d$count[i])), if (length(kids)) list(children = unname(kids)))
    }) |> unname()
  }
  L <- length(lv); step <- 83 / L
  ring <- function(k) list(r0 = sprintf("%.0f%%", 12 + (k - 1) * step), r = sprintf("%.0f%%", 12 + k * step),
                           itemStyle = list(opacity = 1 - 0.12 * (k - 1)))
  dq_compact(list(
    tooltip = list(trigger = "item", formatter = "{b}<br><b>{c}</b> records"),
    series = list(list(
      type = "sunburst", name = "All records", data = node(dat, 1), radius = I(c("12%", "95%")),
      nodeClick = "rootToNode",
      itemStyle = list(borderColor = "rgba(255,255,255,0.7)", borderWidth = 1),
      label = list(rotate = "radial", fontSize = 10, color = "#fff", minAngle = 8),
      levels = c(list(list(r0 = "0%", r = "12%")), lapply(seq_len(L), ring))
    ))
  ))
}

#' Groups of similar names as stacked bars: the most common spelling in
#' blue, the variants after it
#' @noRd
loc_bars_option <- function(g) {
  labs <- unique(g$label[order(g$group)])
  pos <- ave(g$count, g$group, FUN = seq_along)
  tot <- tapply(g$count, g$group, sum)
  series <- lapply(seq_len(max(pos)), function(k) {
    rows <- lapply(seq_along(labs), function(j) {
      i <- which(g$group == j & pos == k)
      if (!length(i)) return(list(value = 0, group = j))
      list(value = g$count[i], name = g$name[i], group = j, tip = loc_tip(g$name[i], g$count[i]),
           label = list(show = g$count[i] / tot[[j]] >= 0.12))
    })
    list(type = "bar", stack = "names", name = if (k == 1) "Most common spelling" else sprintf("Variant %d", k - 1),
         itemStyle = list(color = if (k == 1) "#0A6EB4" else LOC_VARIANT_COLOURS[(k - 2) %% 3 + 1]),
         label = list(show = TRUE, position = "inside", formatter = "{b}", fontSize = 10, color = "#fff"),
         data = rows)
  })
  opt <- dq_compact(list(
    tooltip = list(trigger = "item", formatter = "fn:tip"),
    legend = list(top = 0, data = I(vapply(series[seq_len(min(4, length(series)))], `[[`, "", "name"))),
    grid = list(left = 8, right = 16, top = 30, bottom = 30, containLabel = TRUE),
    xAxis = list(type = "value", name = "Records", nameLocation = "middle", nameGap = 24),
    yAxis = list(type = "category", data = I(labs), inverse = TRUE),
    series = series
  ))
  attr(opt, "height") <- max(320, 24 * length(labs) + 80)
  opt
}
