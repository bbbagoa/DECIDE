#' Identify rows with problematic character entries
#' @param data The 1GB dataframe to scan
#' @param target_cols A vector of column names to audit
#' @return A filtered dataframe of "bad" records
#' @importFrom utils head
find_bad_names <- function(data, target_cols) {
  if (length(target_cols) == 0) {
    return(data[0, ])
  } # Return empty if no columns selected

  data |>
    # Store the original row position so we can find it later for CRUD
    dplyr::filter(dplyr::if_any(
      dplyr::all_of(target_cols),
      ~ (is.na(.) |
        nchar(as.character(.)) < 2 |
        grepl("[0-9]", .) |
        tolower(as.character(.)) %in%
          c("none", "null", "test", "n/a", "unknown", "---", "."))
    ))
}


#' Helper to guess column names based on keywords
#'
#' @param cols Character vector of column names.
#' @param keywords Character vector of keywords to match.
#' @return The first matching column name, or an empty string.
#' @export
find_guess <- function(cols, keywords) {
  pattern <- paste(keywords, collapse = "|")
  match <- cols[grepl(pattern, cols, ignore.case = TRUE)]
  if (length(match) > 0) return(match[1]) else return("")
}

## Locations Function

get_location_summary <- function(data, col_name) {
  req(data, col_name)
  data |>
    dplyr::group_by(label = .data[[col_name]]) |>
    dplyr::summarise(count = n(), .groups = "drop") |>
    dplyr::arrange(label)
}

#' Coerce columns whose declared class does not match their contents
#'
#' openxlsx warns (and can write corrupt sheets) when a logical column
#' contains character values. This helper converts such columns to character
#' before exporting.
#'
#' @param df A data.frame.
#' @return A data.frame safe for `openxlsx::writeData()`.
#' @noRd
sanitize_for_excel <- function(df) {
  df[] <- lapply(df, function(x) {
    if (is.logical(x)) {
      non_na <- x[!is.na(x)]
      if (length(non_na) > 0) {
        txt <- tolower(as.character(non_na))
        if (!all(txt %in% c("true", "false", "1", "0", "yes", "no", "t", "f"))) {
          return(as.character(x))
        }
      }
    }
    x
  })
  df
}

#' Return a normalized weight vector from the setup mapping
#'
#' If no weight column is mapped, returns a vector of ones.
#' Missing weights are replaced with 0 and a warning is issued.
#'
#' @param df A data.frame.
#' @param settings A reactiveValues list with a `weight` element.
#' @return A numeric vector of weights with length `nrow(df)`.
#' @noRd
get_weights <- function(df, settings) {
  w_col <- settings$weight
  if (is.null(w_col) || !nzchar(w_col) || !w_col %in% names(df)) {
    return(rep(1, nrow(df)))
  }
  w <- as_number(df[[w_col]])
  w[is.na(w)] <- 0
  if (any(w < 0, na.rm = TRUE)) {
    warning("Negative sampling weights detected and set to 0.", call. = FALSE)
    w[w < 0] <- 0
  }
  w
}

#' Weighted count of rows
#'
#' @param df A data.frame.
#' @param settings Setup settings list.
#' @return Sum of weights.
#' @noRd
weighted_count <- function(df, settings) {
  sum(get_weights(df, settings), na.rm = TRUE)
}

#' Weighted sum of a numeric column
#'
#' @param df A data.frame.
#' @param col Column name to sum.
#' @param settings Setup settings list.
#' @return Weighted sum.
#' @noRd
weighted_sum <- function(df, col, settings) {
  if (!col %in% names(df)) return(0)
  x <- as_number(df[[col]])
  sum(x * get_weights(df, settings), na.rm = TRUE)
}

#' Weighted mean of a numeric column
#'
#' @param df A data.frame.
#' @param col Column name to average.
#' @param settings Setup settings list.
#' @return Weighted mean.
#' @noRd
weighted_mean <- function(df, col, settings) {
  if (!col %in% names(df)) return(NA_real_)
  x <- as_number(df[[col]])
  w <- get_weights(df, settings)
  valid <- !is.na(x) & !is.na(w) & w > 0
  if (sum(valid) == 0) return(NA_real_)
  sum(x[valid] * w[valid]) / sum(w[valid])
}

#' Weighted frequency table
#'
#' @param df A data.frame.
#' @param col Column name to tabulate.
#' @param settings Setup settings list.
#' @return A data.frame with columns `value` and `n` (weighted count).
#' @noRd
weighted_table <- function(df, col, settings) {
  if (!col %in% names(df)) {
    return(data.frame(value = character(), n = numeric(), stringsAsFactors = FALSE))
  }
  w <- get_weights(df, settings)
  x <- as.character(df[[col]])
  counts <- tapply(w, x, sum, na.rm = TRUE)
  out <- data.frame(
    value = names(counts),
    n = as.numeric(counts),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  out[order(out$n, decreasing = TRUE), , drop = FALSE]
}

#' Friendly waiter overlay content
#'
#' @return A `shiny.tag` with the custom loader and a friendly message.
#' @noRd
waiter_content <- function(message = "Working\u2026",
                            percent = NULL,
                            subtitle = NULL,
                            ns = NULL,
                           cancel_id = NULL) {
  has_pct <- !is.null(percent) && !is.na(percent)
  cancel_btn <- NULL
  if (!is.null(ns)) {
    input_id <- ns("cancel_download")
    cancel_btn <- tags$button(
      type = "button",
      class = "btn btn-sm btn-outline-secondary",
      onclick = sprintf(
        "Shiny.setInputValue('%s', Date.now(), {priority: 'event'});",
        input_id
      ),
      "Cancel"
    )
  }

  # A cross that stops a background task (bg_run()): it sets a root input the
  # app hears because the work runs in another process.
  cross <- if (!is.null(cancel_id)) tags$button(
    type = "button", class = "tw-wait-cancel", title = "Stop this task", `aria-label` = "Stop this task",
    onclick = sprintf("Shiny.setInputValue('%s', Date.now(), {priority: 'event'}); this.disabled = true;", cancel_id),
    HTML("&times;"))

  # A small card over a light scrim: spinner, one plain line, and a slim bar
  # when the progress is known. Every part is always there (hidden when
  # empty), so waiter_progress() can update it in place without redrawing.
  has_sub <- !is.null(subtitle) && !is.na(subtitle)
  hide <- function(show) if (show) NULL else "display:none"
  content <- tags$div(
    class = "wfp-wait", role = "status", `aria-live` = "polite",
    cross,
    tags$div(class = "wfp-wait-row",
             tags$span(class = "wfp-wait-ring"),
             tags$span(class = "wfp-wait-msg", message),
             tags$span(class = "wfp-wait-pct", style = hide(has_pct), if (has_pct) paste0(percent, "%"))),
    tags$div(class = "wfp-wait-bar", style = hide(has_pct),
             tags$span(style = paste0("width:", if (has_pct) percent else 0, "%"))),
    tags$div(class = "wfp-wait-sub", style = hide(has_sub), if (has_sub) subtitle),
    # The console of steps, filled by waiter_log() / tw_step() (www/busy.js).
    tags$div(class = "wfp-wait-log", style = "display:none"),
    cancel_btn
  )

  # waiter serialises this into a single-quoted JavaScript string without
  # escaping it, so one apostrophe ends the string and throws a SyntaxError
  # that kills the rest of that script block -- which is how the default
  # message ("we're running...") silently broke the page preloader. Any French
  # message would do the same ("l'assistance"). Pre-encoding the apostrophes
  # keeps the JS string intact; the browser decodes them back when the HTML is
  # inserted, including inside the cancel button's onclick.
  one_line <- gsub("[
]+", " ", paste(as.character(content), collapse = " "))
  HTML(gsub("'", "&#39;", one_line, fixed = TRUE))
}

#' Filter a data frame to rows whose date column falls inside a range
#'
#' Three things this guards that the inline version did not:
#' * `df[d >= lo & d <= hi, ]` injects an all-NA row for every row whose date is
#'   missing or unparseable, which then flows into every downstream KPI.
#' * `as.Date()` on a non-ISO character column throws ("character string is not
#'   in a standard unambiguous format"), surfacing as a raw error in the UI.
#' * The column was converted twice per filter pass -- needless at 1M rows.
#'
#' @param df A data.frame.
#' @param date_col Name of the mapped date column (may be NULL/"" /absent).
#' @param range Length-2 vector of dates (lower, upper), inclusive.
#' @return `df` filtered to the range; unchanged when the column or range is
#'   unusable, and with undated rows dropped rather than turned into NA rows.
#' @noRd
filter_by_date_range <- function(df, date_col, range) {
  if (is.null(df) || is.null(date_col) || !nzchar(date_col) || !date_col %in% names(df)) {
    return(df)
  }
  if (is.null(range) || length(range) < 2) {
    return(df)
  }

  d <- suppressWarnings(tryCatch(as.Date(df[[date_col]]), error = function(e) NULL))
  if (is.null(d)) {
    return(df)
  }

  lo <- suppressWarnings(tryCatch(as.Date(range[1]), error = function(e) NA))
  hi <- suppressWarnings(tryCatch(as.Date(range[2]), error = function(e) NA))
  if (is.na(lo) || is.na(hi)) {
    return(df)
  }

  keep <- which(d >= lo & d <= hi)
  # every row in range (the default, whole period): no copy of the table
  if (length(keep) == nrow(df)) return(df)
  df[keep, , drop = FALSE]
}

#' Build fuzzy-match groups from a character vector
#'
#' Two keys belong together when the whole texts are close: their edit
#' distance (letters added, removed or changed; case ignored) is at most
#' `max_dist`, or, with `similarity`, when 1 - distance / length of the longer
#' text reaches it (0.9 lets about one character in ten differ, so long names
#' allow more typos than short ones). `agrep()` was used before: it matches a
#' pattern anywhere INSIDE the other text, so with a share-of-length distance
#' "Jean Baptiste Mukendi" and "Marie Kahindo" fell in one group.
#'
#' @param keys Character vector of keys (e.g. pasted duplicate columns).
#' @param max_dist Maximum number of edits (used when `similarity` is NULL).
#' @param similarity Minimum similarity between 0 and 1, or NULL.
#' @param window Neighbours compared in each sorted order.
#' @return Integer vector of group IDs (0 = no near-match).
#' @noRd
fuzzy_match_groups <- function(keys, max_dist = 1, similarity = NULL, window = 10) {
  keys <- tolower(trimws(as.character(keys)))
  keys[is.na(keys)] <- ""
  # Each distinct text once: exact copies share its group.
  u <- unique(keys)
  idx <- match(keys, u)
  n <- length(u)
  len <- nchar(u)
  parent <- seq_len(n)
  find <- function(x) { while (parent[x] != x) x <- parent[x] <- parent[parent[x]]; x }

  # Sorted neighbourhood (the usual record-linkage shortcut): sort the texts,
  # compare each with its `window` next neighbours, then again sorted on the
  # reversed text so a typo near the start is caught too. Comparing every
  # pair took hours on a registration list; this is n x window comparisons.
  if (n > 1) {
    rev_txt <- vapply(strsplit(u, ""), function(ch) paste(rev(ch), collapse = ""), character(1))
    for (ord in list(order(u), order(rev_txt))) {
      for (k in seq_len(min(window, n - 1))) {
        a <- ord[seq_len(n - k)]; b <- ord[(k + 1):n]
        d <- stringdist::stringdist(u[a], u[b], method = "lv")
        close <- if (is.null(similarity)) d <= max_dist else 1 - d / pmax(len[a], len[b], 1) >= similarity
        for (m in which(close)) {
          ra <- find(a[m]); rb <- find(b[m])
          if (ra != rb) parent[max(ra, rb)] <- min(ra, rb)
        }
      }
    }
  }
  root <- vapply(seq_len(n), find, integer(1))
  # A text is in a group when it has a near match or an exact copy.
  size <- tabulate(root[idx], nbins = n)
  out <- ifelse(size[root[idx]] > 1, root[idx], 0L)
  out[out > 0] <- match(out[out > 0], unique(out[out > 0]))
  as.integer(out)
}

#' Count fully duplicated rows
#'
#' base `duplicated()` on a data.frame hashes column by column and scales
#' super-linearly: 6.1 s for 200k x 60, against 0.35 s for the same data via
#' data.table's radix ordering. The import summary used to skip the check
#' entirely above 50,000 rows for that reason, which is exactly the size where
#' a user most wants to know.
#'
#' List columns cannot be ordered, so they are dropped from the comparison and
#' reported, rather than the whole check failing.
#'
#' @param df A data frame.
#' @return Integer count of rows that repeat an earlier row.
#' @noRd
count_duplicate_rows <- function(df) {
  if (is.null(df) || nrow(df) == 0 || ncol(df) == 0) return(0L)
  keep <- !vapply(df, is.list, logical(1))
  if (!any(keep)) return(0L)
  dt <- data.table::as.data.table(df[, keep, drop = FALSE])
  sum(duplicated(dt))
}


#' Small info icon with a hover tooltip, for labels of technical inputs
#' @noRd
#' Columns that hold numbers
#'
#' Numeric columns, plus text or factor columns whose non-missing values are
#' (almost) all numbers: CSV and MODA exports often arrive as text. Missing
#' values do not count against a column (a sparsely answered count is still a
#' count), and only the first 2,000 answers are parsed so a wide 1 GB frame is
#' scanned quickly.
#' @noRd
quantitative_cols <- function(df, min_share = 0.9) {
  if (is.null(df) || !ncol(df)) return(character(0))
  ok <- vapply(df, function(v) {
    if (is.logical(v) || inherits(v, c("Date", "POSIXt", "difftime"))) return(FALSE)
    if (is.numeric(v)) return(TRUE)
    if (!is.character(v) && !is.factor(v)) return(FALSE)
    v <- utils::head(v[!is.na(v)], 5000)
    v <- as.character(v)
    v <- utils::head(v[nzchar(trimws(v))], 2000)
    length(v) > 0 && mean(!is.na(suppressWarnings(as.numeric(v)))) >= min_share
  }, logical(1))
  names(df)[ok]
}

#' Columns on which the records of each duplicate group disagree
#'
#' One pass per column (not per group and column): a group disagrees on a
#' column when it holds more than one distinct (group, value) pair.
#' @param df The duplicated records (only the data columns).
#' @param groups Group number of each record.
#' @return List named by group, each a character vector of column names
#'   (empty: the records are exact copies).
#' @noRd
duplicate_group_diffs <- function(df, groups) {
  ug <- unique(groups)
  gi <- match(groups, ug)
  m <- vapply(names(df), function(cl) {
    x <- as.character(df[[cl]])
    x[is.na(x)] <- "\001NA"
    first <- !duplicated(paste(gi, x, sep = "\r"))
    tabulate(gi[first], nbins = length(ug)) > 1
  }, logical(length(ug)))
  m <- matrix(m, nrow = length(ug), dimnames = list(NULL, names(df)))
  stats::setNames(lapply(seq_along(ug), function(i) colnames(m)[m[i, ]]), ug)
}

#' Grouped choices for a column picker
#'
#' Each group goes in as a list: Shiny shows a group holding a single column
#' as one option labelled with the group's name, not as a group.
#' @param ... Named character vectors (names, if any, are the labels).
#' @noRd
col_choice_groups <- function(...) {
  g <- list(...)
  g <- g[lengths(g) > 0]
  lapply(g, function(x) {
    if (is.null(names(x))) names(x) <- x
    as.list(x)
  })
}

#' Numbers from any column (via as.character: a factor's codes are not its values)
#' @noRd
as_number <- function(x) {
  # Already numbers: as they are. Going through as.character() turned 100,000
  # numbers into text and back on every chart (0.2 s a call on large data).
  if (is.numeric(x) && !is.factor(x)) return(as.numeric(x))
  # Categories, yes/no values and dates: as before (a category by its label).
  if (!is.character(x)) return(suppressWarnings(as.numeric(as.character(x))))
  suppressWarnings(as.numeric(x))
}

info_tip <- function(text) {
  bslib::tooltip(bsicons::bs_icon("info-circle", class = "wfp-tip", `aria-label` = "More information"), text)
}


#' Tooltip body: a title and items, each with a short explanation and a
#' reference for the technical detail
#' @param items List of lists with `name`, `text` and optional `ref`.
#' @noRd
tip_body <- function(title, items) {
  tags$div(
    class = "wfp-tip-body",
    tags$div(class = "wfp-tip-title", title),
    lapply(items, function(it) tags$div(
      class = "wfp-tip-item",
      tags$strong(it$name), " ", it$text,
      if (!is.null(it$ref)) tags$div(class = "wfp-tip-ref", it$ref)))
  )
}

#' The model choices explained, with references
#' @noRd
model_tip <- function() {
  info_tip(tip_body("How the weights are estimated", list(
    list(name = "Logistic regression.", text = "One model on all criteria; each criterion's effect is net of the others. The APP-FA reference.",
         ref = "Hosmer, Lemeshow & Sturdivant (2013), Applied Logistic Regression, 3rd ed., Wiley."),
    list(name = "Stepwise logistic.", text = "Logistic regression, then drops criteria that add nothing once the others are known (backward, AIC). Shorter card.",
         ref = "Venables & Ripley (2002), Modern Applied Statistics with S, ch. 6, Springer."),
    list(name = "Weight of evidence.", text = "Each criterion's own log odds ratio. Never fails on rare or overlapping criteria, but overlaps count twice.",
         ref = "Siddiqi (2017), Intelligent Credit Scoring, 2nd ed., Wiley."),
    list(name = "Boosted stumps.", text = "Gradient boosting with one split per tree: still one fixed number of points per criterion.",
         ref = "Friedman (2001), Greedy function approximation, Annals of Statistics 29(5); Chen & Guestrin (2016), XGBoost, KDD."),
    list(name = "Random forest, XGBoost, naive Bayes, neural network, SVM.", text = "Machine-learning models; each criterion's points are its average marginal effect on the model's log-odds, so the card stays additive. Compare their held-out AUC with the logistic card. SVM optimises a boundary rather than probabilities and can give weak points.",
         ref = "Breiman (2001), Machine Learning 45; Chen & Guestrin (2016), KDD; Hastie, Tibshirani & Friedman (2009), Elements of Statistical Learning; Cortes & Vapnik (1995), Machine Learning 20; marginal effects: Molnar (2022), Interpretable Machine Learning."),
    list(name = "Vulnerability index: PCA.", text = "Not a prediction model: the first principal component of the criteria, the weights that summarise how they vary together (for yes/no criteria, the same first dimension as multiple correspondence analysis). Turned so a higher index means more vulnerable; its errors are then measured against the outcome like any card. Check that the criteria share enough variation (KMO, Bartlett).",
         ref = "Filmer & Pritchett (2001), Demography 38(1); Vyas & Kumaranayake (2006), Health Policy and Planning 21(6); Kaiser (1974), Psychometrika 39."),
    list(name = "Vulnerability index: LDA.", text = "Fisher's linear discriminant: the weighted sum of the criteria that best separates vulnerable from other households, given how the criteria vary together. Supervised like logistic regression, but assumes equal spread in both groups.",
         ref = "Fisher (1936), Annals of Eugenics 7; Hastie, Tibshirani & Friedman (2009), Elements of Statistical Learning, ch. 4.")
  )))
}

#' What a PCA / LDA index says about itself, under the fitted model
#' @noRd
index_note <- function(ix) {
  pct <- function(v) sprintf("%.0f%%", 100 * v)
  if (identical(ix$type, "pca")) {
    # judged on the value shown (0.4995 reads 0.50, and is then "poor")
    ix$kmo <- round(ix$kmo, 2)
    kmo_word <- if (is.na(ix$kmo)) "not computable" else if (ix$kmo >= .8) "good" else if (ix$kmo >= .7) "middling" else
      if (ix$kmo >= .6) "mediocre" else if (ix$kmo >= .5) "poor" else "unacceptable"
    weak <- is.na(ix$kmo) || ix$kmo < .5 || isTRUE(ix$bartlett_p >= .05)
    tags$div(
      class = paste("small mt-2", if (weak) "alert alert-warning mb-0" else "text-muted"),
      bsicons::bs_icon("diagram-3"),
      tags$strong(sprintf(" Total variation explained: %s", pct(ix$share))),
      if (!is.null(ix$min_var)) sprintf(" (the fewest axes reaching the %s asked).", pct(ix$min_var)) else ".",
      if ((ix$axes %||% 1) > 1)
        sprintf(" PCA index on %d axes (%s). ", ix$axes,
                paste(sprintf("axis %d: %s, weight %.2f", seq_along(ix$axis_share), pct(ix$axis_share), ix$axis_weights), collapse = "; "))
      else " PCA index on the first component. ",
      sprintf("Kaiser's rule (eigenvalue above 1) would keep %d %s. Sampling adequacy (KMO) %s (%s); Bartlett's test p %s.",
              ix$kaiser %||% NA_integer_, if (isTRUE((ix$kaiser %||% 1) == 1)) "axis" else "axes",
              if (is.na(ix$kmo)) "n/a" else sprintf("%.2f", ix$kmo), kmo_word,
              if (ix$bartlett_p < .001) "< 0.001" else sprintf("= %.3f", ix$bartlett_p)),
      if (weak) " The criteria share little variation: one index summarises them poorly; prefer a model, or fewer and more related criteria.",
      " Weights are the index's own coefficients, scaled so the largest is 10; the points scheme does not apply.")
  } else if (isTRUE(ix$type %in% c("count", "mca", "cluster"))) {
    alpha <- if (is.na(ix$alpha %||% NA)) "n/a" else sprintf("%.2f", ix$alpha)
    tags$div(class = "small text-muted mt-2", bsicons::bs_icon("diagram-3"),
             switch(ix$type,
               count = " Deprivation count: each criterion met adds its points (1 by default; edit them in the table). ",
               mca = sprintf(" MCA index on %d axis(es): %s of the inertia explained in total, turned towards %s. ",
                             ix$axes %||% 1, pct(ix$share), anchor_text(ix$anchor)),
               cluster = sprintf(" %d household profiles (%s); targeted: profile %s, %s of the households. The points reproduce the targeted profiles. ",
                                 ix$k, cluster_algorithm_label(ix$algorithm),
                                 paste(ix$target, collapse = ", "), pct(sum(ix$size[ix$target])))),
             sprintf("Internal consistency (Cronbach's alpha) %s. No outcome: the errors cannot be measured.", alpha))
  } else {
    tags$div(class = "small text-muted mt-2", bsicons::bs_icon("diagram-3"),
             sprintf(" LDA index: separation between the two groups (Mahalanobis D\u00b2) %.2f.", ix$mahalanobis),
             " Weights are the discriminant's own coefficients, scaled so the largest is 10; the points scheme does not apply.")
  }
}


#' The app font, served from the package
#'
#' Commissioner (SIL Open Font License) ships in inst/app/www/fonts and is
#' declared with @font-face in wfp-ui.css, so the app looks the same with no
#' internet connection. bslib::font_google() downloaded it at run time, which
#' fails offline on a machine that never cached it.
#' @noRd
app_font <- function() {
  "Commissioner, 'Segoe UI', system-ui, -apple-system, Roboto, sans-serif"
}

#' Round every decimal number to 5 places (data frames, lists or vectors)
#'
#' Applied to everything the app computes and exports, so tables, workbooks
#' and reports never show floating-point noise such as 5.952380952381.
#' @noRd
round5 <- function(x) {
  if (is.data.frame(x)) { x[] <- lapply(x, round5); return(x) }
  if (is.double(x) && !inherits(x, c("Date", "POSIXt", "difftime"))) return(round(x, 5))
  x
}

#' openxlsx::writeData with numbers rounded to 5 decimals
#' @noRd
write_data <- function(wb, sheet, x, ...) {
  # ISO date text becomes real dates, shown day / month / year (zzz.R)
  if (is.data.frame(x)) x <- dates_from_text(x)
  openxlsx::writeData(wb, sheet, export_text(round5(x)), ...)
}

#' A number with up to 5 decimals, no trailing zeros (2.93274, 4)
#' @noRd
fmt5 <- function(x) format(round(as.numeric(x), 5), scientific = FALSE, drop0trailing = TRUE, trim = TRUE)

#' Verdict card: the Advisory's verdict as a status panel
#'
#' A household icon in the verdict's colour (reached / to review / missed),
#' a status badge, the Advisory's wording unchanged (interpretation and
#' action), and, when given, the two errors against their tolerance. The card
#' fades in only when the verdict changes (`animate`), so dragging the
#' threshold does not replay it; no motion for users who ask for less.
#' @param v A list from `error_verdict()`.
#' @param ... Extra content under the action (notes).
#' @param errors Optional c(inclusion = , exclusion = ) as proportions.
#' @param tolerance Optional c(lower, upper) as proportions.
#' @param stage "design" or "implementation" (the wording of the badge).
#' @noRd
verdict_card <- function(v, ..., animate = TRUE, errors = NULL, tolerance = NULL, stage = "design") {
  lvl <- if (isTRUE(v$level %in% c("good", "review", "redesign"))) v$level else "unknown"
  impl <- identical(stage, "implementation")
  status <- c(good = "Within tolerance", review = "Review recommended",
              redesign = if (impl) "Corrective action required" else "Redesign required",
              unknown = if (identical(v$level, "invalid")) "Tolerance not valid" else "Not enough data")[[lvl]]
  icon <- c(good = "house-check-fill", review = "house-exclamation-fill",
            redesign = "house-x-fill", unknown = "house-fill")[[lvl]]
  chip <- function(label, x) {
    if (is.null(x) || is.na(x)) return(NULL)
    up <- if (length(tolerance) == 2) tolerance[2] else NA
    lo <- if (length(tolerance) == 2) tolerance[1] else NA
    cls <- if (is.na(up)) "" else if (x <= lo) "is-ok" else if (x <= up) "is-mid" else "is-bad"
    tags$div(class = paste("vd-metric", cls),
             tags$span(class = "vd-metric-label", label),
             tags$span(class = "vd-metric-value", sprintf("%.1f%%", 100 * x)),
             if (!is.na(up)) tags$span(class = "vd-metric-tol", sprintf("good \u2264 %.0f%% \u00b7 limit \u2264 %.0f%%", 100 * lo, 100 * up)))
  }
  metrics <- if (length(errors)) tags$div(class = "vd-metrics",
                                          chip("Inclusion error", errors[["inclusion"]]),
                                          chip("Exclusion error", errors[["exclusion"]]))
  tags$div(
    class = paste("wfp-verdict", paste0("is-", lvl), if (!animate) "no-anim"), role = "status",
    tags$div(class = "vd-icon", bsicons::bs_icon(icon, size = "1.9rem")),
    tags$div(
      class = "vd-text",
      tags$div(class = "vd-head", tags$span(class = "vd-status", status)),
      tags$div(class = "vd-interp", v$interpretation),
      tags$div(class = "vd-action", tags$strong("Recommended action: "), v$action),
      metrics,
      ...
    )
  )
}

#' Countries with a WFP country office, offered in the country office picker
#'
#' Free text is accepted too (a regional bureau, a sub-office).
#' @noRd
wfp_country_offices <- function() {
  c("Afghanistan", "Algeria", "Angola", "Armenia", "Bangladesh", "Benin", "Bhutan", "Bolivia",
    "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Central African Republic", "Chad",
    "Colombia", "Congo", "C\u00f4te d'Ivoire", "Cuba", "Democratic Republic of the Congo",
    "Djibouti", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Eswatini", "Ethiopia",
    "Gambia", "Ghana", "Guatemala", "Guinea", "Guinea-Bissau", "Haiti", "Honduras", "India",
    "Indonesia", "Iran", "Iraq", "Jordan", "Kenya", "Kyrgyzstan", "Lao PDR", "Lebanon", "Lesotho",
    "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mozambique", "Myanmar",
    "Namibia", "Nepal", "Nicaragua", "Niger", "Nigeria", "Pakistan", "Palestine", "Peru",
    "Philippines", "Republic of Moldova", "Rwanda", "Sao Tome and Principe", "Senegal",
    "Sierra Leone", "Somalia", "South Sudan", "Sri Lanka", "Sudan", "Syria", "Tajikistan",
    "Tanzania", "Timor-Leste", "Togo", "T\u00fcrkiye", "Uganda", "Ukraine", "Venezuela",
    "Yemen", "Zambia", "Zimbabwe")
}

#' The splash shown while the app starts
#'
#' WFP logo, the name, the tagline and a slim progress line. Serialised to
#' one line with apostrophes encoded, as waiter needs (see waiter_content()).
#' @noRd
startup_splash <- function() {
  content <- tags$div(
    class = "tw-splash",
    tags$img(src = "www/wfp-logo-standard-white-en.png", alt = "WFP", class = "tw-splash-logo"),
    tags$div(class = "tw-splash-name", "TargetWise"),
    tags$div(class = "tw-splash-tagline", "Reaching the most vulnerable"),
    tags$div(class = "tw-splash-bar", tags$span()),
    tags$div(class = "tw-splash-sub", "Preparing your workspace\u2026")
  )
  one_line <- gsub("[
]+", " ", paste(as.character(content), collapse = " "))
  HTML(gsub("'", "&#39;", one_line, fixed = TRUE))
}

#' downloadHandler that tells the page when the file is built
#'
#' A download does not make Shiny busy, so without this a large export gives
#' no sign of life. www/busy.js shows "Preparing your file..." from the click
#' and hides it on this message. Use it for every download.
#' @noRd
download_handler <- function(filename, content, contentType = NULL, outputArgs = list()) {
  # Captured here: while the file is written there is no current session.
  session <- shiny::getDefaultReactiveDomain()
  shiny::downloadHandler(
    filename = filename,
    content = function(file) {
      on.exit(if (!is.null(session)) session$sendCustomMessage("tw-download-done", list()), add = TRUE)
      content(file)
    },
    contentType = contentType, outputArgs = outputArgs)
}

#' Stop a button's handler with a message instead of silently
#'
#' `req()` ends a handler without a word, which looks like a dead button.
#' Use this at the top of any handler that needs something first: the user is
#' told what is missing, then the handler stops the same way `req()` would.
#' @noRd
need_ok <- function(ok, message) {
  if (!isTRUE(ok)) {
    shiny::showNotification(message, type = "warning", duration = 6)
    shiny::req(FALSE)
  }
  invisible(TRUE)
}

#' Freeze a button until its condition holds (www/gates.js)
#'
#' A frozen button is greyed out, shows `reason` on hover, and tells it again
#' when clicked. Call inside an `observe()` so the state follows the data.
#' @param id Input id, unnamespaced (the session's namespace is applied).
#' @noRd
gate_button <- function(id, ok, reason, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) return(invisible(NULL))
  session$sendCustomMessage("tw-gate", list(id = session$ns(id), ok = isTRUE(ok), reason = reason))
  invisible(NULL)
}

#' Esri canvas basemaps (keyless): the Overview map and the report map
#' @noRd
esri_canvas <- function(layer) sprintf(
  "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_%s/MapServer/tile/{z}/{y}/{x}", layer)

#' @noRd
ESRI_ATTRIBUTION <- "Tiles &copy; Esri &mdash; Esri, HERE, Garmin, &copy; OpenStreetMap contributors"

#' The basemaps every map offers, in the layer menu's order
#' @noRd
BASE_GROUPS <- c("Light", "Dark", "Terrain", "Satellite", "Satellite (Clarity)")

#' Add the keyless Esri basemaps to a leaflet map
#'
#' Satellite is Esri World Imagery; "Satellite (Clarity)" is Esri's less
#' processed, often sharper version of it. Every layer zooms to level 21 and
#' enlarges its own deepest real tiles beyond them (maxNativeZoom) instead of
#' going grey, and asks for the sharper tiles of high-density screens
#' (detectRetina).
#' @param groups The basemaps to add (a subset of BASE_GROUPS).
#' @noRd
add_esri_bases <- function(m, groups = BASE_GROUPS) {
  opt <- function(native) leaflet::tileOptions(maxZoom = 21, maxNativeZoom = native, detectRetina = TRUE)
  # blankTile=false: where Esri has no imagery at a zoom it answers "not
  # found" instead of a grey "no data" picture, so the fallback below can
  # show the deepest imagery that exists there (level 19 in many towns, 17 in
  # much of the countryside)
  img <- "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}?blankTile=false"
  clarity <- "https://clarity.maptiles.arcgis.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}?blankTile=false"
  topo <- "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}"
  img_attr <- "Tiles &copy; Esri &mdash; Source: Esri, Maxar, Earthstar Geographics, and the GIS User Community"
  if ("Light" %in% groups) m <- m |>
    leaflet::addTiles(esri_canvas("Light_Gray_Base"), attribution = ESRI_ATTRIBUTION, group = "Light", options = opt(16)) |>
    leaflet::addTiles(esri_canvas("Light_Gray_Reference"), group = "Light", options = opt(16))
  if ("Dark" %in% groups) m <- m |>
    leaflet::addTiles(esri_canvas("Dark_Gray_Base"), attribution = ESRI_ATTRIBUTION, group = "Dark", options = opt(16)) |>
    leaflet::addTiles(esri_canvas("Dark_Gray_Reference"), group = "Dark", options = opt(16))
  if ("Terrain" %in% groups) m <- leaflet::addTiles(m, topo, attribution = ESRI_ATTRIBUTION, group = "Terrain", options = opt(19))
  if ("Satellite" %in% groups) m <- leaflet::addTiles(m, img, attribution = img_attr, group = "Satellite", options = opt(19))
  if ("Satellite (Clarity)" %in% groups) m <- leaflet::addTiles(m, clarity, attribution = img_attr, group = "Satellite (Clarity)", options = opt(19))
  htmlwidgets::onRender(m, ESRI_FALLBACK_JS)
}

# Where Esri has no satellite image at this zoom (a 404 with blankTile=false),
# the layer's native depth drops to the level below and Leaflet enlarges those
# tiles, so a village zoomed past its imagery shows the deepest real image
# instead of grey. Zooming back out past that level restores the full depth.
ESRI_FALLBACK_JS <- htmlwidgets::JS("function(el, x) {
  var map = this;
  function hook(layer) {
    if (!(layer instanceof L.TileLayer) || layer._twFb || !/World_Imagery/.test(layer._url || '')) return;
    layer._twFb = true;
    var full = layer.options.maxNativeZoom;
    layer.on('tileerror', function(e) {
      var z = e.coords.z;
      if (z < 1 || z > layer.options.maxNativeZoom) return;
      layer.options.maxNativeZoom = z - 1;
      clearTimeout(layer._twT);
      layer._twT = setTimeout(function() { if (layer._map) layer._resetView(); }, 50);
    });
    map.on('zoomend', function() {
      if (map.getZoom() <= layer.options.maxNativeZoom && layer.options.maxNativeZoom < full) layer.options.maxNativeZoom = full;
    });
  }
  map.eachLayer(hook);
  map.on('layeradd', function(e) { hook(e.layer); });
}")

#' The range a map opens on: the inner 99% of the points, padded
#'
#' One mis-keyed GPS fix would otherwise double the extent and shrink the real
#' cluster to a speck; every point is still drawn.
#' @noRd
map_fit_range <- function(x, p = 0.005) {
  x <- x[is.finite(x)]
  if (length(x) < 20) { r <- range(x); pad <- max(diff(r) * 0.05, 0.01); return(c(r[1] - pad, r[2] + pad)) }
  q <- stats::quantile(x, c(p, 1 - p), names = FALSE)
  if (q[1] == q[2]) q <- range(x)
  pad <- max(diff(q) * 0.05, 0.01)
  c(q[1] - pad, q[2] + pad)
}

#' Zoom a report map to its households
#' @noRd
fit_to_points <- function(m, lon, lat) {
  xr <- map_fit_range(lon); yr <- map_fit_range(lat)
  leaflet::fitBounds(m, xr[1], yr[1], xr[2], yr[2])
}

#' Chain area pickers: each level lists only the areas inside those picked above
#'
#' Owns the choices of every level (Admin 1 lists everything); a level keeps
#' whatever of its selection is still listed. Choices are sent only when they
#' change, so an open menu is not redrawn under the pointer.
#' @param ids Picker input ids, top level first.
#' @param cols Reactive or function: the data column of each level ("" or NULL
#'   when a level is not mapped).
#' @param data Reactive data.frame.
#' @param hint Optional function(k): values to select at level k while its
#'   picker is empty (a restored scope waiting for its choices).
#' @noRd
cascade_pickers <- function(session, input, ids, cols, data, hint = NULL) {
  sent <- list()
  observeEvent(data(), sent <<- list(), priority = 10)
  observe({
    df <- data(); req(df)
    cl <- cols()
    keep <- NULL
    for (k in seq_along(ids)) {
      col <- cl[k]
      # a level that is not mapped is not offered at all
      mapped <- !is.na(col) && nzchar(col) && col %in% names(df)
      session$sendCustomMessage("tw-input-visible", list(id = session$ns(ids[k]), show = mapped))
      if (!mapped) {
        if (length(sent[[ids[k]]])) {
          shinyWidgets::updatePickerInput(session, ids[k], choices = character(0), selected = character(0))
          sent[[ids[k]]] <<- character(0)
        }
        next
      }
      v <- as.character(df[[col]])
      ch <- sort(unique(stats::na.omit(if (is.null(keep)) v else v[keep])))
      cur <- input[[ids[k]]]
      if (!length(cur) && !is.null(hint)) cur <- isolate(hint(k))
      sel <- intersect(cur %||% character(0), ch)
      if (!identical(ch, sent[[ids[k]]]) || !setequal(sel, input[[ids[k]]] %||% character(0))) {
        # value labels shown as "code - label", like every value picker
        shinyWidgets::updatePickerInput(session, ids[k], choices = value_choices(ch, col, session), selected = sel)
        sent[[ids[k]]] <<- ch
      }
      if (length(sel)) keep <- (if (is.null(keep)) TRUE else keep) & v %in% sel
    }
  })
}

#' Update the open waiter in place (no redraw, so it does not flicker)
#'
#' For progress during long operations: changes the message, the percent bar
#' and the subtitle of the waiter already on screen. NULL leaves a part as is;
#' NA hides it.
#' @noRd
waiter_progress <- function(session, message = NULL, percent = NULL, subtitle = NULL) {
  session$sendCustomMessage("tw-wait-progress", list(message = message, percent = percent, subtitle = subtitle))
}

#' A line in the waiter's console
#'
#' Heavy operations say what they are doing, one line per step, under the
#' waiter on screen, like an installer log. `state` is "run" (under way),
#' "ok", "err" or "info"; a line sent again with the same `id` replaces the
#' earlier one. Does nothing outside a Shiny session (tests, scripts).
#' @noRd
waiter_log <- function(text, state = "info", id = NULL, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    # in the background worker: to the job's log file, which the waiter reads
    lf <- getOption("tw.log_file", "")
    if (nzchar(lf)) cat(sprintf("%s\t%s\t%s\n", state, id %||% "", gsub("[\t\r\n]+", " ", text)), file = lf, append = TRUE)
    return(invisible(NULL))
  }
  session$sendCustomMessage("tw-wait-log", list(text = text, state = state, id = id))
  invisible(NULL)
}

tw_log_ids <- new.env(parent = emptyenv())

#' Run one step of a heavy operation, logged in the waiter with its time
#'
#' `tw_step("read the csv file", fread(...))` shows the step under way, then
#' ticks it with the seconds it took (or marks it failed and lets the error
#' go on).
#' @noRd
tw_step <- function(label, expr, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session) && !nzchar(getOption("tw.log_file", ""))) return(expr)
  n <- (tw_log_ids$n %||% 0) + 1
  tw_log_ids$n <- n
  id <- paste0("step", n)
  waiter_log(label, "run", id, session)
  t0 <- proc.time()[["elapsed"]]
  # R's own messages and warnings go to the console too (they still reach R)
  out <- withCallingHandlers(expr,
    error = function(e) waiter_log(paste0(label, ": ", conditionMessage(e)), "err", id, session),
    message = function(m) waiter_log(trimws(conditionMessage(m)), "r", NULL, session),
    warning = function(w) waiter_log(paste("Warning:", conditionMessage(w)), "rwarn", NULL, session))
  waiter_log(sprintf("%s (%.1f s)", label, proc.time()[["elapsed"]] - t0), "ok", id, session)
  out
}

#' "13,208 rows x 1,294 columns"
#' @noRd
dim_text <- function(df) {
  sprintf("%s rows x %s columns", format(nrow(df), big.mark = ","), format(ncol(df), big.mark = ","))
}

#' The country office set in the app (session), or "" outside a session
#' @noRd
country_office_now <- function() {
  d <- shiny::getDefaultReactiveDomain()
  if (is.null(d)) return("")
  v <- tryCatch(d$rootScope()$userData$country_office, error = function(e) NULL)
  v <- as.character(v %||% "")[1]
  if (is.na(v)) "" else trimws(v)
}

#' A download's file name: stem, country office, date and time
#'
#' "Targeting_design_report_Mali_2026-09-25_14h30.html". The country is
#' written in plain letters (accents dropped, spaces as underscores) so the
#' name works on every system; without a country office it is left out.
#' @noRd
export_file_name <- function(stem, ext, time_format = "%Y-%m-%d_%Hh%M", country = country_office_now()) {
  co <- iconv(country %||% "", "UTF-8", "ASCII//TRANSLIT", sub = "")
  co <- gsub("^_+|_+$", "", gsub("[^A-Za-z0-9]+", "_", co %||% ""))
  paste0(stem, if (nzchar(co)) paste0("_", co), "_", format(Sys.time(), time_format), ".", ext)
}

#' Sidebars, one look everywhere (as on Targeting Monitoring)
#'
#' Numbered sections that fold, each with an icon (`side_step()` inside
#' `side_steps()`), then the page's actions in one block at the bottom
#' (`side_actions()`, kept in view while the sections scroll). Give the
#' sidebar `class = "wfp-side"`.
#'
#' One section is open at a time (opening one folds the others); a folded
#' section says what it holds in its header (`www/stepsummary.js`), so
#' folding hides no choice. `open = TRUE` opens the first section.
#' @noRd
side_steps <- function(..., id = NULL, open = TRUE) {
  if (isTRUE(open)) {
    first <- Filter(function(p) inherits(p, "shiny.tag"), list(...))[1]
    open <- if (length(first)) htmltools::tagGetAttribute(first[[1]], "data-value") else NULL
  }
  bslib::accordion(..., id = id, multiple = FALSE, open = open)
}

#' @noRd
side_step <- function(title, icon_name, ..., value = NULL) {
  bslib::accordion_panel(title = title, value = value %||% title, icon = bsicons::bs_icon(icon_name), ...)
}

#' @noRd
side_actions <- function(..., sticky = TRUE) {
  tags$div(class = paste("wfp-sb-actions", if (!sticky) "wfp-sb-actions-end"), ...)
}

# ---------------------------------------------------------------------------
# Dates as the app shows them: day / month / year
# ---------------------------------------------------------------------------
# Dates are stored as ISO (2026-10-01), which sorts and parses safely; they are
# SHOWN day first everywhere: pages, tables, reports, workbooks.
DATE_FMT <- "%d/%m/%Y"
DATETIME_FMT <- "%d/%m/%Y %H:%M"

#' A date from a Date, a date-time, or text in ISO or day/month/year form
#' @noRd
as_date_any <- function(x) {
  if (inherits(x, "Date")) return(as.Date(x))
  if (inherits(x, "POSIXt")) return(as.Date(x, tz = attr(x, "tzone") %||% ""))
  s <- trimws(as.character(x))
  d <- suppressWarnings(as.Date(substr(s, 1, 10), format = "%Y-%m-%d"))
  dmy <- is.na(d) & !is.na(s)
  if (any(dmy)) d[dmy] <- suppressWarnings(as.Date(substr(s[dmy], 1, 10), format = "%d/%m/%Y"))
  d
}

#' "01/10/2026" (empty for a missing date)
#' @noRd
fmt_date <- function(x = Sys.Date()) {
  d <- as_date_any(x)
  out <- format(d, DATE_FMT); out[is.na(d)] <- ""
  out
}

#' "01/10/2026 14:05" from a date-time or ISO text ("2026-10-01 14:05:09")
#' @noRd
fmt_datetime <- function(x = Sys.time()) {
  if (!inherits(x, "POSIXt")) {
    s <- trimws(as.character(x))
    x <- suppressWarnings(as.POSIXct(substr(s, 1, 19), tz = "", tryFormats = c("%Y-%m-%d %H:%M:%S", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M")))
  }
  out <- format(x, DATETIME_FMT); out[is.na(x)] <- ""
  out
}

#' Text columns that hold ISO dates or date-times, as Date / date-time
#'
#' Judged on up to 200 distinct values; anything else is left as it is.
#' @noRd
dates_from_text <- function(df) {
  for (k in seq_along(df)) {
    x <- df[[k]]
    if (!is.character(x)) next
    u <- utils::head(unique(x[!is.na(x) & nzchar(x)]), 200)
    if (!length(u)) next
    if (all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", u))) {
      d <- suppressWarnings(as.Date(x, format = "%Y-%m-%d")); if (!anyNA(d[!is.na(x) & nzchar(x)])) df[[k]] <- d
    } else if (all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}(:[0-9]{2})?", u))) {
      d <- suppressWarnings(as.POSIXct(substr(x, 1, 19), tz = "", tryFormats = c("%Y-%m-%d %H:%M:%S", "%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M")))
      if (!anyNA(d[!is.na(x) & nzchar(x)])) df[[k]] <- d
    }
  }
  df
}

#' DT::datatable() with dates shown day / month / year
#'
#' Date and date-time columns (and text columns holding ISO dates) are shown
#' as 01/10/2026 and 01/10/2026, 14:05 by the browser, while the table still
#' sorts them by date. Use it instead of DT::datatable() everywhere.
#' @noRd
tw_datatable <- function(data, ...) {
  if (!is.data.frame(data)) return(DT::datatable(data, ...))
  data <- dates_from_text(data)
  w <- DT::datatable(data, ...)
  is_d <- which(vapply(data, function(x) inherits(x, "Date"), logical(1)))
  is_t <- which(vapply(data, function(x) inherits(x, "POSIXt"), logical(1)))
  if (length(is_d)) w <- DT::formatDate(w, is_d, method = "toLocaleDateString", params = list("en-GB"))
  if (length(is_t)) w <- DT::formatDate(w, is_t, method = "toLocaleString",
                                        params = list("en-GB", list(year = "numeric", month = "2-digit", day = "2-digit",
                                                                    hour = "2-digit", minute = "2-digit")))
  w
}
