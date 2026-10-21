#' Model diagrams, drawn as SVG so the app and the offline report show the
#' same picture. One per model where the representation is standard:
#' decision tree (the tree), logistic regression (forest plot of odds
#' ratios), neural network (network diagram), random forest / boosting
#' (variable importance), Ward clustering (dendrogram). The SVGs scale to the
#' width of their container.
#' @name model_diagrams
#' @noRd
NULL

#' Models that have a diagram
#' @noRd
# (boosted stumps are additive: their points are the whole model, nothing more to draw)
diagram_models <- function() c("logit", "tree", "nnet", "rf", "xgb", "hclust")

#' The diagram's data for a fitted model (NULL when it has none)
#' @param model The fitted object (rpart, nnet, ranger, xgb.Booster), or NULL.
#' @param weights The weights table (logistic forest plot).
#' @noRd
model_diagram <- function(method, model = NULL, weights = NULL) {
  tryCatch(switch(method,
    logit = if (!is.null(weights) && any(is.finite(weights$or_low)))
      list(kind = "forest", data = weights[, c("criterion", "odds_ratio", "or_low", "or_high", "p_value")]),
    tree = if (inherits(model, "rpart") && nrow(model$frame) > 1) list(kind = "tree", data = tree_structure(model)),
    nnet = if (inherits(model, "nnet")) list(kind = "network", data = network_structure(model)),
    rf = if (inherits(model, "ranger") && length(model$variable.importance))
      list(kind = "importance", data = importance_table(model$variable.importance), measure = "Mean decrease in Gini impurity"),
    xgb = if (inherits(model, "xgb.Booster")) {
      im <- xgboost::xgb.importance(model = model)
      list(kind = "importance", data = importance_table(stats::setNames(im$Gain, im$Feature)), measure = "Share of the gain")
    },
    NULL), error = function(e) NULL)
}

importance_table <- function(v) {
  v <- v[is.finite(v) & v > 0]
  if (!length(v)) return(NULL)
  v <- sort(v, decreasing = TRUE)
  data.frame(criterion = names(v), importance = round(100 * v / max(v), 1), stringsAsFactors = FALSE)
}

#' Title and how to read each kind of diagram (app card and report)
#' @noRd
diagram_title <- function(kind) switch(kind,
  tree = "Decision tree", forest = "Odds ratios with 95% intervals", network = "Neural network",
  importance = "Variable importance", dendrogram = "Dendrogram of the households", "Model diagram")
diagram_help <- function(kind, nof = FALSE) switch(kind,
  tree = paste("Read from the top (or the left): each box asks one question, the household follows the yes or no branch until it reaches a leaf.",
               if (nof) "A leaf shows the share of its households in the targeted profiles," else "A leaf shows the share of its training households that is vulnerable,",
               "coloured from green (low) to red (high), and how many households reached it."),
  forest = "Each criterion's odds ratio (square) and 95% confidence interval (line), on a log scale. Right of 1 (red): households meeting it are more likely vulnerable; left (green): less likely. A pale square is not significant at 5%; an interval crossing 1 cannot be told apart from no effect.",
  network = "Criteria on the left feed the hidden units in the middle, which feed the output on the right. Line thickness is the size of a connection's weight; blue lines push up, amber lines push down. A hidden unit mixes several criteria, so single weights are not effects: the points on the card are the network's average effects. Bias terms are not drawn.",
  importance = "How much each criterion contributes to the model's splits, relative to the most important one (100). Importance says how much the model uses a criterion, not in which direction: the points on the card give the direction.",
  dendrogram = "Households are merged bottom-up, the most similar first; the height of a join is how different the two groups are. The dashed line is where the tree is cut into the profiles. Leaves are small groups of similar households (their size under the square), coloured by profile; targeted profiles are outlined.",
  "")

#' The diagram as SVG (dispatch on its kind)
#' @noRd
diagram_svg <- function(d, share_label = "vulnerable") {
  if (is.null(d) || is.null(d$data)) return("")
  switch(d$kind,
         tree = tree_svg(d$data, share_label),
         forest = forest_svg(d$data),
         network = network_svg(d$data, if (identical(share_label, "vulnerable")) "Vulnerable" else "Targeted"),
         importance = importance_svg(d$data, d$measure %||% "Importance"),
         dendrogram = dendrogram_svg(d$data),
         "")
}

#' Which of several layouts (each c(W, H)) to draw: among those whose text
#' stays readable once shrunk to the panel's width (at least 65% of its
#' size), the one that is shortest on screen; if none is, the least shrunk.
#' @noRd
pick_layout <- function(sizes, box_w = 1100, min_scale = 0.65) {
  scale <- vapply(sizes, function(s) min(1, box_w / s[1]), numeric(1))
  shown_h <- vapply(seq_along(sizes), function(i) sizes[[i]][2] * scale[i], numeric(1))
  ok <- which(scale >= min_scale)
  if (length(ok)) ok[which.min(shown_h[ok])] else which.max(scale)
}

#' One or two columns for a list of rows, by pick_layout()
#' @noRd
diagram_columns <- function(n, col_w, row_h, extra_h) {
  if (n <= 6) return(1L)
  pick_layout(list(c(col_w, n * row_h + extra_h), c(2 * col_w, ceiling(n / 2) * row_h + extra_h)))
}

# An SVG that scales to its container, never wider than its natural size
svg_wrap <- function(W, H, label, css, parts) {
  paste0('<div class="tw-diagram"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ', round(W), ' ', round(H),
         '" width="100%" style="max-width:', round(W), 'px;height:auto" preserveAspectRatio="xMidYMin meet" role="img" aria-label="',
         label, '"><style>', css, '</style>', paste(parts, collapse = ""), '</svg></div>')
}
svg_font <- function(w, px) sprintf("font:%s %spx 'Open Sans',system-ui,sans-serif", w, px)
svg_esc <- function(x) htmltools::htmlEscape(x)
svg_short <- function(v, n) ifelse(nchar(v) > n, paste0(substr(v, 1, n - 1), "..."), v)

# green (low) -> amber -> red (high)
diagram_colour <- function(p) {
  p <- min(max(p, 0), 1)
  stops <- rbind(c(63, 126, 68), c(208, 138, 0), c(197, 25, 45))
  i <- if (p <= 0.5) 1 else 2; t <- if (p <= 0.5) p / 0.5 else (p - 0.5) / 0.5
  rgb <- round(stops[i, ] + t * (stops[i + 1, ] - stops[i, ]))
  sprintf("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
}

# ---- Decision tree --------------------------------------------------------

#' The nodes of a fitted rpart tree, for drawing
#' @return data.frame(node, parent, depth, var, answer ("yes"/"no" on the
#'   branch into the node), n, share (of the second class), leaf)
#' @noRd
tree_structure <- function(fit) {
  fr <- fit$frame
  node <- as.integer(rownames(fr))
  lab <- labels(fit)
  # the branch into a node: "x>=0.5" means the answer is yes, "x< 0.5" no
  answer <- ifelse(node == 1L, "", ifelse(grepl(">=", lab, fixed = TRUE), "yes", "no"))
  prob <- fr$yval2[, ncol(fr$yval2) - 1]
  data.frame(node = node, parent = ifelse(node == 1L, NA_integer_, node %/% 2L),
             depth = floor(log2(node)), var = ifelse(fr$var == "<leaf>", NA_character_, as.character(fr$var)),
             answer = answer, n = fr$n, share = round(prob, 4), leaf = fr$var == "<leaf>",
             stringsAsFactors = FALSE)
}

#' The decision tree as an SVG diagram
#'
#' Questions in white boxes, branches labelled yes / no, leaves coloured by
#' the share (green low, red high) with their households. The tree hangs from
#' the top or grows left to right, whichever is shorter on screen while
#' staying readable (pick_layout()).
#' @param share_label What the share is ("vulnerable", "targeted").
#' @noRd
tree_svg <- function(ts, share_label = "vulnerable") {
  if (is.null(ts) || !nrow(ts)) return("")
  # leaves in the tree's own order, parents centred over their children
  ord <- integer(0)
  walk <- function(nd) {
    kids <- ts$node[!is.na(ts$parent) & ts$parent == nd]
    if (!length(kids)) { ord <<- c(ord, nd); return(invisible()) }
    for (k in sort(kids)) walk(k)
  }
  walk(1L)
  b <- stats::setNames(rep(NA_real_, nrow(ts)), ts$node)
  b[as.character(ord)] <- seq_along(ord) - 1
  for (d in rev(sort(unique(ts$depth)))) for (nd in ts$node[ts$depth == d & !ts$leaf]) {
    kids <- ts$node[!is.na(ts$parent) & ts$parent == nd]
    b[as.character(nd)] <- mean(b[as.character(kids)])
  }
  # top-down or left-to-right, whichever is shorter on screen and readable
  bw <- 168; bh <- 58; L <- length(ord); D <- max(ts$depth) + 1
  side <- pick_layout(list(c(L * 186 + 2, D * 116 - 38), c(D * 238 - 50, L * 70 + 8))) == 2L
  if (side) { sb <- bh + 12; sd <- bw + 70 } else { sb <- bw + 18; sd <- bh + 58 }
  depth <- stats::setNames(ts$depth, ts$node)
  # top-left corner of each box
  bx <- function(nd) { k <- as.character(nd); if (side) depth[[k]] * sd + 10 else b[[k]] * sb + 10 }
  by <- function(nd) { k <- as.character(nd); if (side) b[[k]] * sb + 10 else depth[[k]] * sd + 10 }
  W <- if (side) (max(ts$depth) + 1) * sd - 70 + 20 else length(ord) * sb - 18 + 20
  H <- if (side) length(ord) * sb - 12 + 20 else (max(ts$depth) + 1) * sd - 58 + 20
  parts <- character(0)
  for (i in which(!is.na(ts$parent))) {
    p <- ts$parent[i]; c <- ts$node[i]
    if (side) {
      x1 <- bx(p) + bw; y1 <- by(p) + bh / 2; x2 <- bx(c); y2 <- by(c) + bh / 2; mx <- (x1 + x2) / 2
      path <- sprintf("M%.1f,%.1f C%.1f,%.1f %.1f,%.1f %.1f,%.1f", x1, y1, mx, y1, mx, y2, x2, y2)
      lx <- mx; ly <- (y1 + y2) / 2 - 4
    } else {
      x1 <- bx(p) + bw / 2; y1 <- by(p) + bh; x2 <- bx(c) + bw / 2; y2 <- by(c); my <- (y1 + y2) / 2
      path <- sprintf("M%.1f,%.1f C%.1f,%.1f %.1f,%.1f %.1f,%.1f", x1, y1, x1, my, x2, my, x2, y2)
      lx <- (x1 + x2) / 2; ly <- my - 3
    }
    parts <- c(parts,
      sprintf('<path d="%s" fill="none" stroke="#9aa5b1" stroke-width="1.5"/>', path),
      sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="ans %s">%s</text>', lx, ly, ts$answer[i], ts$answer[i]))
  }
  for (i in seq_len(nrow(ts))) {
    cx <- bx(ts$node[i]); cy <- by(ts$node[i]); col <- diagram_colour(ts$share[i])
    if (ts$leaf[i]) {
      parts <- c(parts,
        sprintf('<rect x="%.1f" y="%.1f" width="%d" height="%d" rx="9" fill="%s" fill-opacity="0.14" stroke="%s" stroke-width="1.6"/>', cx, cy, bw, bh, col, col),
        sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="big" fill="%s">%s%%</text>', cx + bw / 2, cy + 25, col, round(100 * ts$share[i])),
        sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="small">%s &#183; %s households</text>', cx + bw / 2, cy + 44,
                svg_esc(share_label), format(ts$n[i], big.mark = ",")))
    } else {
      v <- ts$var[i]
      parts <- c(parts,
        sprintf('<rect x="%.1f" y="%.1f" width="%d" height="%d" rx="9" fill="#ffffff" stroke="#007DBC" stroke-width="1.4"><title>%s</title></rect>', cx, cy, bw, bh, svg_esc(v)),
        sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="q">%s?</text>', cx + bw / 2, cy + 23, svg_esc(svg_short(v, 24))),
        sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="small">%s households &#183; %s%% %s</text>', cx + bw / 2, cy + 42,
                format(ts$n[i], big.mark = ","), round(100 * ts$share[i]), svg_esc(share_label)))
    }
  }
  svg_wrap(W, H, "Decision tree",
           paste0(".q{", svg_font(600, 12), ";fill:#1f2a37}.big{", svg_font(700, 18), "}.small{", svg_font(400, 10.5), ";fill:#5b6b7c}",
                  ".ans{", svg_font(600, 11), "}.ans.yes{fill:#c5192d}.ans.no{fill:#3f7e44}"), parts)
}

# ---- Logistic regression: forest plot -------------------------------------

#' Forest plot of a logistic model: each criterion's odds ratio with its 95%
#' interval on a log scale, 1 marked. A long list is split into two columns
#' on the same scale when that is shorter on screen.
#' @param w The weights table (criterion, odds_ratio, or_low, or_high, p_value).
#' @noRd
forest_svg <- function(w) {
  w <- w[is.finite(w$odds_ratio) & is.finite(w$or_low) & is.finite(w$or_high), , drop = FALSE]
  if (!nrow(w)) return("")
  w <- w[order(-w$odds_ratio), , drop = FALSE]
  lw <- 220; pw <- 340; rh <- 26; top <- 30; cw <- lw + pw + 130
  lo <- log(min(w$or_low, 0.8)); hi <- log(max(w$or_high, 1.25))
  ticks <- c(0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50); ticks <- ticks[log(ticks) >= lo & log(ticks) <= hi]
  cols <- diagram_columns(nrow(w), cw, rh, top + 34)
  per <- ceiling(nrow(w) / cols)
  H <- top + per * rh + 34; W <- cols * cw
  parts <- character(0)
  for (cc in seq_len(cols)) {
    x0 <- (cc - 1) * cw
    sx <- function(v) x0 + lw + (log(v) - lo) / (hi - lo) * pw
    parts <- c(parts,
      vapply(ticks, function(t) sprintf('<line x1="%.1f" x2="%.1f" y1="%d" y2="%d" stroke="%s" stroke-dasharray="%s"/><text x="%.1f" y="%d" text-anchor="middle" class="tick">%s</text>',
                                       sx(t), sx(t), top - 6, H - 28, if (t == 1) "#1f2a37" else "#d6dde5", if (t == 1) "4 3" else "", sx(t), H - 12, format(t)), character(1)),
      sprintf('<text x="%.1f" y="16" text-anchor="start" class="head">&#8592; less likely vulnerable</text>', x0 + lw),
      sprintf('<text x="%.1f" y="16" text-anchor="end" class="head">more likely vulnerable &#8594;</text>', x0 + lw + pw))
    for (i in intersect(seq_len(per) + (cc - 1) * per, seq_len(nrow(w)))) {
      yy <- top + ((i - 1) %% per) * rh + rh / 2
      col <- if (w$odds_ratio[i] >= 1) "#c5192d" else "#3f7e44"
      sig <- isTRUE(w$p_value[i] < 0.05)
      v <- w$criterion[i]
      parts <- c(parts,
        sprintf('<text x="%.1f" y="%.1f" text-anchor="end" class="lab"><title>%s</title>%s</text>', x0 + lw - 10, yy + 4, svg_esc(v), svg_esc(svg_short(v, 30))),
        sprintf('<line x1="%.1f" x2="%.1f" y1="%.1f" y2="%.1f" stroke="%s" stroke-width="2"/>', sx(w$or_low[i]), sx(w$or_high[i]), yy, yy, col),
        sprintf('<rect x="%.1f" y="%.1f" width="10" height="10" fill="%s" fill-opacity="%s" stroke="%s"/>', sx(w$odds_ratio[i]) - 5, yy - 5, col, if (sig) "1" else "0.25", col),
        sprintf('<text x="%.1f" y="%.1f" class="val">%s (%s-%s)</text>', x0 + lw + pw + 8, yy + 4,
                sprintf("%.2f", w$odds_ratio[i]), sprintf("%.2f", w$or_low[i]), sprintf("%.2f", w$or_high[i])))
    }
  }
  svg_wrap(W, H, "Odds ratios with 95% intervals",
           paste0(".lab{", svg_font(500, 11.5), ";fill:#1f2a37}.val{", svg_font(400, 10.5), ";fill:#5b6b7c}",
                  ".tick{", svg_font(400, 10), ";fill:#5b6b7c}.head{", svg_font(600, 10.5), ";fill:#5b6b7c}"), parts)
}

# ---- Neural network -------------------------------------------------------

#' The connections of a one-hidden-layer nnet (biases left out)
#' @return list(inputs, n_hidden, edges = data.frame(from, to, weight, layer))
#' @noRd
network_structure <- function(fit) {
  ni <- fit$n[1]; nh <- fit$n[2]; no <- fit$n[3]
  if (!nh) return(NULL)
  edges <- do.call(rbind, lapply(seq_len(nh + no), function(j) {
    u <- ni + j                                   # the unit fed (0 is the bias)
    idx <- seq_len(fit$nconn[u + 2] - fit$nconn[u + 1]) + fit$nconn[u + 1]
    src <- fit$conn[idx]; keep <- src > 0
    data.frame(from = src[keep], to = u, weight = fit$wts[idx][keep])
  }))
  edges$layer <- ifelse(edges$to <= ni + nh, 1L, 2L)
  edges <- edges[edges$layer == 1L | edges$from > ni, , drop = FALSE]   # no skip-layer links
  list(inputs = fit$coefnames, n_hidden = nh, edges = edges)
}

#' The network left to right, or top to bottom (criteria along the top,
#' labels slanted) when that is shorter on screen
#' @noRd
network_svg <- function(net, out_label = "Vulnerable") {
  if (is.null(net)) return("")
  ni <- length(net$inputs); nh <- net$n_hidden
  lr <- c(760, max(ni, nh) * 24 + 40)
  tb <- c(max(ni, nh) * 34 + 380, 430)    # + room for the last slanted labels
  down <- pick_layout(list(lr, tb)) == 2L
  W <- if (down) tb[1] else lr[1]; H <- if (down) tb[2] else lr[2]
  if (down) {
    span <- W - 380
    p_in <- function(k) c(200 + (k - 0.5) * span / ni, 150)
    p_hid <- function(k) c(200 + (k - 0.5) * span / nh, 280)
    p_out <- c(200 + span / 2, 390)
  } else {
    p_in <- function(k) c(230, 20 + (k - 0.5) * (H - 40) / ni)
    p_hid <- function(k) c(470, 20 + (k - 0.5) * (H - 40) / nh)
    p_out <- c(680, H / 2)
  }
  e <- net$edges; mx <- max(abs(e$weight))
  pos <- function(u) if (u <= ni) p_in(u) else if (u <= ni + nh) p_hid(u - ni) else p_out
  parts <- vapply(seq_len(nrow(e)), function(i) {
    a <- pos(e$from[i]); b <- pos(e$to[i])
    sprintf('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="%.2f" stroke-opacity="0.6"><title>%.3f</title></line>',
            a[1], a[2], b[1], b[2], if (e$weight[i] >= 0) "#007DBC" else "#e0a100", 0.4 + 5 * abs(e$weight[i]) / mx, e$weight[i])
  }, character(1))
  node <- function(p, fill, txt = "") sprintf('<circle cx="%.1f" cy="%.1f" r="9" fill="%s" stroke="#1f2a37" stroke-width="0.8"/>%s', p[1], p[2], fill, txt)
  in_label <- function(k) {
    p <- p_in(k); v <- net$inputs[k]
    if (down) sprintf('<text x="%.1f" y="%.1f" text-anchor="start" class="lab" transform="rotate(-40 %.1f %.1f)"><title>%s</title>%s</text>',
                      p[1] + 2, p[2] - 16, p[1] + 2, p[2] - 16, svg_esc(v), svg_esc(svg_short(v, 26)))
    else sprintf('<text x="%.1f" y="%.1f" text-anchor="end" class="lab"><title>%s</title>%s</text>', p[1] - 16, p[2] + 4, svg_esc(v), svg_esc(svg_short(v, 32)))
  }
  heads <- if (down) '<text x="12" y="154" class="head">Criteria</text><text x="12" y="284" class="head">Hidden units</text><text x="12" y="394" class="head">Output</text>'
           else '<text x="230" y="12" text-anchor="middle" class="head">Criteria</text><text x="470" y="12" text-anchor="middle" class="head">Hidden units</text><text x="680" y="12" text-anchor="middle" class="head">Output</text>'
  parts <- c(parts,
    vapply(seq_len(ni), function(k) paste0(node(p_in(k), "#ffffff"), in_label(k)), character(1)),
    vapply(seq_len(nh), function(k) node(p_hid(k), "#dcebf7",
      sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="tick">H%d</text>', p_hid(k)[1], p_hid(k)[2] + 3.5, k)), character(1)),
    node(p_out, "#c5192d"),
    if (down) sprintf('<text x="%.1f" y="%.1f" class="lab">%s</text>', p_out[1] + 16, p_out[2] + 4, svg_esc(out_label))
    else sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="lab">%s</text>', p_out[1], p_out[2] + 26, svg_esc(out_label)),
    heads)
  svg_wrap(W, H, "Neural network",
           paste0(".lab{", svg_font(500, 11.5), ";fill:#1f2a37}.tick{", svg_font(600, 8.5), ";fill:#1f2a37}.head{", svg_font(600, 10.5), ";fill:#5b6b7c}"), parts)
}

# ---- Variable importance --------------------------------------------------

importance_svg <- function(im, measure = "Importance") {
  if (is.null(im) || !nrow(im)) return("")
  im <- utils::head(im, 40)
  lw <- 230; pw <- 380; rh <- 22; top <- 26; cw <- lw + pw + 60
  cols <- diagram_columns(nrow(im), cw, rh, top + 10)
  per <- ceiling(nrow(im) / cols)
  H <- top + per * rh + 10; W <- cols * cw
  parts <- sprintf('<text x="%d" y="14" class="head">%s, relative to the most important criterion (100)</text>', lw, svg_esc(measure))
  for (i in seq_len(nrow(im))) {
    x0 <- ((i - 1) %/% per) * cw; y <- top + ((i - 1) %% per) * rh
    parts <- c(parts,
      sprintf('<text x="%d" y="%.1f" text-anchor="end" class="lab"><title>%s</title>%s</text>', x0 + lw - 10, y + 14, svg_esc(im$criterion[i]), svg_esc(svg_short(im$criterion[i], 32))),
      sprintf('<rect x="%d" y="%.1f" width="%.1f" height="14" rx="3" fill="#007DBC" fill-opacity="%.2f"/>', x0 + lw, y + 3, max(1, pw * im$importance[i] / 100), 0.35 + 0.65 * im$importance[i] / 100),
      sprintf('<text x="%.1f" y="%.1f" class="val">%s</text>', x0 + lw + pw * im$importance[i] / 100 + 6, y + 14, format(im$importance[i])))
  }
  svg_wrap(W, H, "Variable importance",
           paste0(".lab{", svg_font(500, 11.5), ";fill:#1f2a37}.val{", svg_font(400, 10.5), ";fill:#5b6b7c}.head{", svg_font(600, 10.5), ";fill:#5b6b7c}"), parts)
}

# ---- Ward dendrogram ------------------------------------------------------

#' The top of a Ward tree, down to at most `leaves` small groups
#' @return list(leaves = data.frame(id, x, size, profile), joins =
#'   data.frame(id, left, right, height), cut, k, target)
#' @noRd
dendro_structure <- function(hc, k, leaves = 30) {
  n <- length(hc$order); L <- min(leaves, n)
  g <- stats::cutree(hc, L); prof <- stats::cutree(hc, k)
  one_obs <- function(r) { while (r > 0) r <- hc$merge[r, 1]; -r }
  ref <- function(r) if (r < 0 || r <= n - L) paste0("g", g[one_obs(r)]) else paste0("m", r)
  lv <- unique(g[hc$order])
  leaf <- data.frame(id = paste0("g", lv), x = seq_along(lv), size = as.vector(table(g)[as.character(lv)]),
                     profile = prof[match(lv, g)], stringsAsFactors = FALSE)
  top <- if (L > 1) seq(n - L + 1, n - 1) else integer(0)
  joins <- data.frame(id = paste0("m", top), left = vapply(top, function(j) ref(hc$merge[j, 1]), ""),
                      right = vapply(top, function(j) ref(hc$merge[j, 2]), ""), height = hc$height[top], stringsAsFactors = FALSE)
  cut <- if (k > 1 && k < n) mean(hc$height[c(n - k, n - k + 1)]) else NA_real_
  list(leaves = leaf, joins = joins, cut = cut, k = k, target = integer(0))
}

dendrogram_svg <- function(dd) {
  if (is.null(dd) || !nrow(dd$joins)) return("")
  lf <- dd$leaves; jn <- dd$joins
  pal <- c("#007DBC", "#f7b825", "#26bde2", "#3f7e44", "#c5192d", "#8e5ea2", "#5b6b7c", "#e67e22")
  sw <- 30; base <- 300; top <- 20; H <- 360
  profs <- sort(unique(lf$profile))
  W <- max(nrow(lf) * sw + 90, 60 + length(profs) * 135)
  hmax <- max(jn$height)
  yof <- function(h) base - (base - top) * h / hmax
  x <- stats::setNames(60 + (lf$x - 0.5) * sw, lf$id); y <- stats::setNames(rep(base, nrow(lf)), lf$id)
  parts <- sprintf('<text x="14" y="%d" class="tick" transform="rotate(-90 14 %d)" text-anchor="middle">distance at the join</text>',
                   (base + top) %/% 2, (base + top) %/% 2)
  for (i in seq_len(nrow(jn))) {
    a <- jn$left[i]; b <- jn$right[i]; yy <- yof(jn$height[i])
    parts <- c(parts, sprintf('<path d="M%.1f,%.1f V%.1f H%.1f V%.1f" fill="none" stroke="#7b8794" stroke-width="1.3"/>',
                              x[[a]], y[[a]], yy, x[[b]], y[[b]]))
    x[jn$id[i]] <- (x[[a]] + x[[b]]) / 2; y[jn$id[i]] <- yy
  }
  for (i in seq_len(nrow(lf))) {
    col <- pal[(lf$profile[i] - 1) %% length(pal) + 1]; tg <- lf$profile[i] %in% dd$target
    parts <- c(parts,
      sprintf('<rect x="%.1f" y="%d" width="14" height="14" rx="3" fill="%s" stroke="%s" stroke-width="%s"><title>Profile %d, %s households</title></rect>',
              x[[lf$id[i]]] - 7, base + 4, col, if (tg) "#1f2a37" else col, if (tg) "2" else "1", lf$profile[i], format(lf$size[i], big.mark = ",")),
      sprintf('<text x="%.1f" y="%d" text-anchor="middle" class="tick">%s</text>', x[[lf$id[i]]], base + 32, format(lf$size[i], big.mark = ",")))
  }
  if (is.finite(dd$cut)) parts <- c(parts,
    sprintf('<line x1="50" x2="%d" y1="%.1f" y2="%.1f" stroke="#c5192d" stroke-dasharray="5 4"/><text x="%d" y="%.1f" text-anchor="end" class="cut">cut: %d profiles</text>',
            W - 10, yof(dd$cut), yof(dd$cut), W - 10, yof(dd$cut) - 5, dd$k))
  leg <- vapply(seq_along(profs), function(j) sprintf('<rect x="%d" y="%d" width="12" height="12" rx="2" fill="%s"/><text x="%d" y="%d" class="lab">Profile %d%s</text>',
    60 + (j - 1) * 135, H - 14, pal[(profs[j] - 1) %% length(pal) + 1], 76 + (j - 1) * 135, H - 3, profs[j],
    if (profs[j] %in% dd$target) " (targeted)" else ""), character(1))
  svg_wrap(W, H + 6, "Dendrogram",
           paste0(".lab{", svg_font(500, 11), ";fill:#1f2a37}.tick{", svg_font(400, 9.5), ";fill:#5b6b7c}.cut{", svg_font(600, 10.5), ";fill:#c5192d}"),
           c(parts, leg))
}

# ---- Residual diagnostics -------------------------------------------------

#' Residual diagnostics of a fitted model, drawn like the diagrams (app card
#' and report). A yes/no outcome: the model's additive score made a
#' probability by one logistic fit on the training households (the logistic
#' model's own fit), residual = outcome - probability on the held-out
#' households (training ones when none are held out); binned residuals
#' (Gelman and Hill) and calibration by tenth. A PMT: measured - predicted log
#' welfare; residuals against predicted, normal Q-Q, scale-location, histogram.
#' @param score The model's score, one per row; `y` the 0/1 outcome.
#' @param train,eval Row indices; `w` optional survey weights, one per row.
#' @noRd
residual_data <- function(score, y, train, eval, w = NULL) {
  if (is.null(score)) return(NULL)
  keep <- function(r) r[!is.na(y[r]) & is.finite(score[r])]
  train <- keep(train); held_out <- !identical(train, keep(eval)); eval <- keep(eval)
  if (length(train) < 20 || length(eval) < 20 || length(unique(y[train])) < 2) return(NULL)
  w <- if (is.null(w)) rep(1, length(y)) else { w <- suppressWarnings(as.numeric(w)); w[!is.finite(w) | w < 0] <- 0; w }
  d <- data.frame(y = y[train], s = score[train], w = w[train])
  b <- stats::coef(suppressWarnings(stats::glm(y ~ s, stats::binomial(), d, weights = w)))
  if (!all(is.finite(b))) return(NULL)
  p <- stats::plogis(b[1] + b[2] * score[eval]); yy <- y[eval]; ww <- w[eval]
  bins <- function(g) {
    k <- ceiling(g * rank(p, ties.method = "first") / length(p))
    sw <- rowsum(ww, k)[, 1]; n <- tabulate(k, g)
    pm <- rowsum(ww * p, k)[, 1] / sw
    data.frame(p = pm, obs = rowsum(ww * yy, k)[, 1] / sw, n = n, se = sqrt(pm * (1 - pm) / n))
  }
  bn <- bins(max(5L, min(20L, floor(sqrt(length(p))))))
  # randomized quantile residuals (Dunn and Smyth 1996): standard normal when
  # the model is right, so the Q-Q and the histogram read as for a PMT
  set.seed(1)
  u <- ifelse(yy == 1, stats::runif(length(p), 1 - p, 1), stats::runif(length(p), 0, 1 - p))
  c(list(kind = "binary", n = length(eval), held_out = held_out,
         binned = data.frame(p = bn$p, r = bn$obs - bn$p, se = bn$se, n = bn$n), calib = bins(10L)[, c("p", "obs", "n")]),
    residual_normality(stats::qnorm(pmin(pmax(u, 1e-9), 1 - 1e-9))))
}

# Q-Q points and histogram of standardised residuals
residual_normality <- function(z) {
  pr <- stats::ppoints(200)
  h <- graphics::hist(pmax(pmin(z, 4.99), -4.99), breaks = seq(-5, 5, by = 0.5), plot = FALSE)
  list(qq = data.frame(theory = stats::qnorm(pr), sample = unname(stats::quantile(z, pr))),
       hist = data.frame(mid = h$mids, density = h$density))
}

#' The same for a PMT, from its evaluation households (actual, predicted, w)
#' @noRd
residual_data_numeric <- function(e, held_out = TRUE) {
  if (is.null(e)) return(NULL)
  e <- e[is.finite(e$actual) & is.finite(e$predicted), , drop = FALSE]
  if (nrow(e) < 20) return(NULL)
  w <- if (is.null(e$w)) rep(1, nrow(e)) else e$w
  r <- e$actual - e$predicted
  sigma <- sqrt(sum(w * r^2) / sum(w)); if (!is.finite(sigma) || sigma == 0) return(NULL)
  z <- r / sigma
  k <- ceiling(10 * rank(e$predicted, ties.method = "first") / nrow(e))
  sw <- rowsum(w, k)[, 1]
  trend <- data.frame(x = rowsum(w * e$predicted, k)[, 1] / sw, r = rowsum(w * r, k)[, 1] / sw,
                      spread = rowsum(w * sqrt(abs(z)), k)[, 1] / sw)
  set.seed(1); s <- if (nrow(e) > 1500) sort(sample.int(nrow(e), 1500)) else seq_len(nrow(e))
  c(list(kind = "numeric", n = nrow(e), held_out = held_out, sigma = sigma,
         points = data.frame(x = e$predicted[s], r = r[s], z = z[s]), trend = trend),
    residual_normality(z))
}

#' Title and how to read the residual diagnostics (app card and report)
#' @noRd
residual_title <- function() "Residual diagnostics"
residual_help <- function(r) if (identical(r$kind, "numeric"))
  paste("Residuals are the measured minus the predicted log welfare per person, on the held-out households (training ones when none are held out).",
        "Residuals against predicted: a cloud centred on zero at every level; the amber line (the average by tenth) should stay flat, a slope means some households are predicted too well-off or too poor.",
        "Normal Q-Q: the standardised residuals against a normal distribution; points off the line at the ends mean a few households are badly predicted.",
        "Scale-location: the spread of the residuals against predicted welfare; a rising line means the errors grow with welfare.",
        "Histogram: the standardised residuals with the normal curve.") else
  paste("Residuals are the outcome (1 vulnerable, 0 not) minus the probability the model gives, on the held-out households (training ones when none are held out); the model's score is made a probability by one logistic fit on the training households.",
        "Binned residuals: households grouped by predicted probability, each dot a group's average residual; about 95% of the dots should fall inside the shaded band (2 standard errors), red dots are ranges where the model is off.",
        "Calibration: the observed share vulnerable against the predicted probability, by tenth; a well calibrated model follows the dashed diagonal.",
        "Normal Q-Q and histogram: randomized quantile residuals (Dunn and Smyth), which follow a standard normal distribution when the model is right; points off the line, or bars away from the curve, show where it is not.")

# One chart panel: frame, grid, ticks, axis titles; `draw(sx, sy)` adds the marks
rd_panel <- function(x0, y0, xr, yr, title, xlab, ylab, draw, pw = 440, ph = 300) {
  if (diff(xr) <= 0) xr <- xr + c(-0.5, 0.5)
  if (diff(yr) <= 0) yr <- yr + c(-0.5, 0.5)
  l <- x0 + 56; r <- x0 + pw - 14; t <- y0 + 30; b <- y0 + ph - 44
  sx <- function(v) l + (v - xr[1]) / diff(xr) * (r - l)
  sy <- function(v) b - (v - yr[1]) / diff(yr) * (b - t)
  xt <- pretty(xr, 5); xt <- xt[xt >= xr[1] & xt <= xr[2]]
  yt <- pretty(yr, 5); yt <- yt[yt >= yr[1] & yt <= yr[2]]
  c(sprintf('<text x="%.1f" y="%.1f" class="head">%s</text>', l, y0 + 16, svg_esc(title)),
    sprintf('<line x1="%.1f" x2="%.1f" y1="%.1f" y2="%.1f" stroke="#e6ebf0"/><text x="%.1f" y="%.1f" text-anchor="end" class="tick">%s</text>',
            l, r, sy(yt), sy(yt), l - 6, sy(yt) + 3.5, format(yt)),
    sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="tick">%s</text>', sx(xt), b + 15, format(xt)),
    sprintf('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="none" stroke="#c9d3dd"/>', l, t, r - l, b - t),
    sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="ax">%s</text>', (l + r) / 2, b + 34, svg_esc(xlab)),
    sprintf('<text transform="translate(%.1f %.1f) rotate(-90)" text-anchor="middle" class="ax">%s</text>', x0 + 14, (t + b) / 2, svg_esc(ylab)),
    draw(sx, sy))
}
rd_dots <- function(sx, sy, x, y, col = "#007DBC", r = 4, op = 0.9)
  sprintf('<circle cx="%.1f" cy="%.1f" r="%s" fill="%s" fill-opacity="%s"/>', sx(x), sy(y), r, col, op)
rd_line <- function(sx, sy, x, y, col, dash = "", width = 2)
  sprintf('<polyline points="%s" fill="none" stroke="%s" stroke-width="%s" stroke-dasharray="%s"/>',
          paste(sprintf("%.1f,%.1f", sx(x), sy(y)), collapse = " "), col, width, dash)

rd_qq <- function(rd, x0, y0, title = "Normal Q-Q") {
  q <- rd$qq; r <- range(c(q$theory, q$sample)); r <- r + c(-1, 1) * 0.05 * diff(r)
  rd_panel(x0, y0, range(q$theory) + c(-0.15, 0.15), r, title, "Normal quantiles", "Standardised residuals",
    function(sx, sy) c(rd_line(sx, sy, range(q$theory), range(q$theory), "#5b6b7c", "4 3", 1), rd_dots(sx, sy, q$theory, q$sample, r = 2.5)))
}
rd_hist <- function(rd, x0, y0) {
  h <- rd$hist; zz <- seq(-5, 5, by = 0.1)
  rd_panel(x0, y0, c(-5, 5), c(0, max(h$density, 0.42) * 1.05), "Histogram against the normal curve", "Standardised residual", "Density",
    function(sx, sy) c(sprintf('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="#007DBC" fill-opacity="0.55"/>',
                               sx(h$mid - 0.25) + 0.5, sy(h$density), sx(h$mid + 0.25) - sx(h$mid - 0.25) - 1, sy(0) - sy(h$density)),
                       rd_line(sx, sy, zz, stats::dnorm(zz), "#c5192d", "", 1.5)))
}

#' The residual diagnostics as SVG (four panels)
#' @noRd
residual_svg <- function(rd) {
  if (is.null(rd)) return("")
  pad <- function(v, m = 0.05) { r <- range(v, na.rm = TRUE); r + c(-1, 1) * m * max(diff(r), 1e-6) }
  if (identical(rd$kind, "binary")) {
    bn <- rd$binned; cb <- rd$calib
    out <- abs(bn$r) > 2 * bn$se
    ym <- max(abs(c(bn$r, 2 * bn$se)), 0.02) * 1.1
    o <- order(bn$p)
    p1 <- rd_panel(0, 0, pad(bn$p), c(-ym, ym),
      sprintf("Binned residuals (%d of %d groups outside the band)", sum(out), nrow(bn)),
      "Predicted probability", "Average residual", function(sx, sy) c(
        sprintf('<polygon points="%s" fill="#e8f1f8"/>', paste(sprintf("%.1f,%.1f", sx(c(bn$p[o], rev(bn$p[o]))), sy(c(2 * bn$se[o], -2 * rev(bn$se[o])))), collapse = " ")),
        rd_line(sx, sy, range(bn$p), c(0, 0), "#5b6b7c", "4 3", 1),
        rd_dots(sx, sy, bn$p, bn$r, ifelse(out, "#c5192d", "#007DBC"))))
    p2 <- rd_panel(440, 0, c(0, 1), c(0, 1), "Calibration by tenth", "Predicted probability", "Observed share vulnerable",
      function(sx, sy) c(rd_line(sx, sy, c(0, 1), c(0, 1), "#5b6b7c", "4 3", 1),
                         rd_line(sx, sy, cb$p, cb$obs, "#007DBC", "", 1.5), rd_dots(sx, sy, cb$p, cb$obs)))
    W <- 880; H <- 600; parts <- c(p1, p2, rd_qq(rd, 0, 300, "Normal Q-Q (randomized quantile residuals)"), rd_hist(rd, 440, 300))
  } else {
    pt <- rd$points; tr <- rd$trend
    p1 <- rd_panel(0, 0, pad(pt$x), pad(pt$r), "Residuals against predicted", "Predicted log welfare", "Measured - predicted",
      function(sx, sy) c(rd_dots(sx, sy, pt$x, pt$r, r = 2, op = 0.35), rd_line(sx, sy, range(pt$x), c(0, 0), "#5b6b7c", "4 3", 1),
                         rd_line(sx, sy, tr$x, tr$r, "#f7b825", "", 2.5)))
    p2 <- rd_qq(rd, 440, 0)
    p3 <- rd_panel(0, 300, pad(pt$x), c(0, max(sqrt(abs(pt$z)), tr$spread) * 1.05), "Scale-location", "Predicted log welfare", "Root of |standardised residual|",
      function(sx, sy) c(rd_dots(sx, sy, pt$x, sqrt(abs(pt$z)), r = 2, op = 0.35), rd_line(sx, sy, tr$x, tr$spread, "#f7b825", "", 2.5)))
    W <- 880; H <- 600; parts <- c(p1, p2, p3, rd_hist(rd, 440, 300))
  }
  note <- sprintf('<text x="%d" y="%d" text-anchor="end" class="tick">%s households, %s</text>', W - 14, H + 14,
                  format(rd$n, big.mark = ","), if (isTRUE(rd$held_out)) "held out" else "training (none held out)")
  svg_wrap(W, H + 20, "Residual diagnostics",
           paste0(".head{", svg_font(600, 11.5), ";fill:#1f2a37}.tick{", svg_font(400, 10), ";fill:#5b6b7c}.ax{", svg_font(500, 10.5), ";fill:#5b6b7c}"),
           c(parts, note))
}
