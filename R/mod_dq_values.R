#' Data Quality sub-tab: Category values (UI)
#'
#' Drawn by the React page (react/src/pages/dq/ValuesTab.tsx).
#' @noRd
dq_values_ui <- function(ns) {
  # No inputs or outputs here: the React tab owns the ids (a second copy in
  # the page would make Shiny bind them twice).
  bslib::nav_panel(title = "Category values",
                   tags$p(class = "mt-3 text-muted", "Category values is drawn by the React page."))
}

#' Data Quality sub-tab: Category values (server)
#'
#' Every qualitative variable (`value_cols()`) is scanned with
#' `value_groups()`; the page gets one summary (output$val_view): per
#' variable its figures, a bar of its answers and its groups of look-alikes
#' or translations. The page sends back what to apply (input$val_apply:
#' changes = list of col, from, to), confirmed in a dialog, then applied to
#' the whole data and the audit trail; each application is kept as a before /
#' after line (output$val_view$history).
#' @noRd
dq_values_server <- function(input, output, session, ns, core) {
  dq_filtered_data <- core$dq_filtered_data
  uploaded_df <- core$uploaded_df
  user_setup <- core$user_setup
  modification_log <- core$modification_log

  # The similarity waits for Scan (settings wait for their button); the data
  # itself is followed, so a merge shows at once.
  sim <- reactiveVal(0.85)
  observeEvent(input$val_scan, {
    req(input$val_scan > 0)   # a React button sends 0 at start
    sim(min(100, max(50, as_number(input$val_similarity %||% 85))) / 100)
  })
  scan <- reactive({
    df <- dq_filtered_data(); req(df)
    vc <- value_cols(df, reactiveValuesToList(user_setup))
    s <- sim()
    stats::setNames(lapply(vc, function(cl) value_groups(df[[cl]], s)), vc)
  })

  history <- reactiveVal(list())

  # Variables marked clean: kept as they are, out of the figures and of
  # Apply all; the mark can be taken back (input$val_keep: col, keep).
  kept <- reactiveVal(character(0))
  observeEvent(input$val_keep, {
    k <- input$val_keep; col <- as.character(k$col)
    req(length(col) == 1, nzchar(col))
    on <- isTRUE(k$keep)
    kept(if (on) union(kept(), col) else setdiff(kept(), col))
    audit_add(modification_log, "Selection", if (on) "Category values kept as they are" else "Category values: mark as clean removed", col, column = col)
  })

  output$val_view <- shinyreact::reactive_output({
    sc <- tryCatch(scan(), error = function(e) NULL)
    if (is.null(sc)) return(NULL)
    lab <- function(cl) { l <- tryCatch(var_label(cl), error = function(e) NA); if (is.na(l) || identical(l, cl)) "" else l }
    vars <- lapply(names(sc), function(cl) {
      g <- sc[[cl]]
      fix <- nzchar(g$suggestion)
      groups <- lapply(setdiff(unique(g$group), 0L), function(k) {
        m <- g[g$group == k, , drop = FALSE]
        main <- m$value[!nzchar(m$suggestion)][1]
        list(id = k, target = main, translation = any(m$kind == "translation"), code = FALSE,
             members = lapply(seq_len(nrow(m)), function(i) list(value = m$value[i], n = m$records[i],
                                                                main = !nzchar(m$suggestion[i]), kind = m$kind[i])))
      })
      # numbers among text answers: the text each stands for joins the group
      # of that text (value labels first, else the usual codes)
      cm <- value_code_labels(g$value, g$records, tryCatch(label_registry()$codes[[cl]], error = function(e) NULL))
      src <- attr(cm, "source")
      for (num in names(cm)) {
        to <- cm[[num]]
        # the label's own group: where it is the target, or a variant (then its target)
        hit <- which(vapply(groups, function(gr) any(vapply(gr$members, function(mm) identical(mm$value, to), logical(1))), logical(1)))
        mem <- list(value = num, n = g$records[g$value == num][1], main = FALSE, kind = "code", source = src[[num]])
        if (length(hit)) {
          groups[[hit[1]]]$members <- c(groups[[hit[1]]]$members, list(mem)); groups[[hit[1]]]$code <- TRUE
        } else {
          groups[[length(groups) + 1]] <- list(id = 1000L + length(groups), target = to, translation = FALSE, code = TRUE,
            members = list(list(value = to, n = sum(g$records[g$value == to]), main = TRUE, kind = ""), mem))
        }
      }
      fix <- fix | g$value %in% names(cm)
      # the answers as a bar: the 8 most common, variants in amber
      top <- utils::head(order(-g$records), 8)
      keep <- cl %in% kept()
      # answers that are numbers among text answers (codes never labelled,
      # or typed in another field): unclean, whatever the spellings
      isnum <- grepl("^[[:space:]]*-?[0-9]+([.,][0-9]+)?[[:space:]]*$", g$value)
      mixed <- any(isnum) && any(!isnum)
      odd <- if (mixed) min(sum(g$records[isnum]), sum(g$records[!isnum])) else 0
      list(name = cl, label = lab(cl), distinct = nrow(g), records = sum(g$records),
           to_fix = if (keep) 0 else sum(g$records[fix]), variants = if (keep) 0 else sum(fix), kept = keep,
           mixed = mixed && !keep, odd = if (keep) 0 else odd,
           numbers = if (mixed) lapply(which(isnum)[order(-g$records[isnum])][seq_len(min(8, sum(isnum)))],
                                       function(i) list(value = g$value[i], n = g$records[i], to = if (g$value[i] %in% names(cm)) cm[[g$value[i]]] else "",
                                                        source = if (g$value[i] %in% names(src)) src[[g$value[i]]] else "")) else list(),
           would_fix = sum(g$records[fix]), groups = groups,
           bar = lapply(top, function(i) list(value = g$value[i], n = g$records[i], variant = fix[i])),
           rest = sum(g$records[-top]),
           values = lapply(seq_len(nrow(g)), function(i) list(value = g$value[i], n = g$records[i])))
    })
    bad <- function(v) v$to_fix + v$odd
    o <- order(-vapply(vars, bad, numeric(1)), vapply(vars, function(v) v$name, ""))
    vars <- vars[o]
    tot <- sum(vapply(vars, function(v) v$records, numeric(1)))
    fix <- sum(vapply(vars, function(v) v$to_fix, numeric(1)))
    odd <- sum(vapply(vars, function(v) v$odd, numeric(1)))
    list(sim = round(100 * sim()), variables = vars,
         totals = list(scanned = length(vars), to_harmonise = sum(vapply(vars, function(v) v$to_fix > 0 || v$mixed, logical(1))),
                       values = sum(vapply(vars, function(v) v$variants, numeric(1))), records = fix,
                       mixed = sum(vapply(vars, function(v) v$mixed, logical(1))),
                       consistent = if (tot > 0) 1 - (fix + odd) / tot else 1),
         history = rev(history()))
  })

  # What the page asks to apply, confirmed first
  pending <- reactiveVal(NULL)
  observeEvent(input$val_apply, {
    ch <- input$val_apply$changes
    df <- uploaded_df()
    changes <- Filter(Negate(is.null), lapply(ch, function(c) {
      col <- as.character(c$col); from <- as.character(unlist(c$from)); to <- trimws(as.character(unlist(c$to)))
      if (!length(col) || !col %in% names(df) || length(from) != length(to)) return(NULL)
      keep <- nzchar(to) & from != to & from %in% as.character(df[[col]])
      if (!any(keep)) return(NULL)
      list(col = col, map = stats::setNames(to[keep], from[keep]))
    }))
    need_ok(length(changes) > 0, "Nothing to apply: tick a group, or select values and type the value they become.")
    pending(changes)
    showModal(modalDialog(
      title = "Harmonise the values", size = "m", easyClose = TRUE,
      tags$p("These values will be replaced in the whole dataset:"),
      tags$div(style = "max-height: 300px; overflow-y: auto;",
               lapply(changes, function(ch) tagList(
                 tags$div(class = "fw-semibold mt-2", ch$col),
                 tags$ul(class = "mb-1", lapply(names(ch$map), function(k) tags$li(k, " \u2192 ", tags$b(ch$map[[k]]))))))),
      textAreaInput(ns("val_reason"), "Reason (optional)", rows = 2, width = "100%"),
      footer = tagList(modalButton("Cancel"), actionButton(ns("val_confirm"), "Replace", class = "btn-danger"))))
  })

  observeEvent(input$val_confirm, tw_guard("Harmonising the values", {
    changes <- pending(); req(changes)
    df <- uploaded_df(); before <- df
    reason <- trimws(as.character(input$val_reason %||% ""))
    distinct <- function(x) length(unique(x[!is.na(x) & nzchar(trimws(as.character(x)))]))
    logs <- list(); hist <- list(); total <- 0
    for (ch in changes) {
      r <- value_replace(df[[ch$col]], ch$map)
      df[[ch$col]] <- r$x; total <- total + r$n
      hist[[length(hist) + 1]] <- list(variable = ch$col, before = distinct(before[[ch$col]]), after = distinct(df[[ch$col]]),
                                       changed = r$n, values = length(ch$map), at = format(Sys.time(), "%H:%M"))
      for (to in unique(unname(ch$map))) {
        from <- names(ch$map)[ch$map == to]
        logs[[length(logs) + 1]] <- data.frame(
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"), uid = "BATCH_VALUES", column = ch$col,
          old_value = paste(from, collapse = ", "),
          new_value = sprintf("%s (%d rows)", to, sum(as.character(before[[ch$col]]) %in% from)),
          action = "Category values harmonised", user = session$user %||% "Admin", reason = reason, stringsAsFactors = FALSE)
      }
    }
    modification_log(rbind(modification_log(), do.call(rbind, logs)))
    uploaded_df(df)
    history(c(history(), hist))
    pending(NULL)
    removeModal()
    showNotification(sprintf("%d variable(s) harmonised, %s records changed.", length(changes), format(total, big.mark = ",")),
                     type = "message")
  }))
}
