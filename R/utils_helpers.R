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
  w <- suppressWarnings(as.numeric(as.character(df[[w_col]])))
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
  x <- suppressWarnings(as.numeric(as.character(df[[col]])))
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
  x <- suppressWarnings(as.numeric(as.character(df[[col]])))
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
                            ns = NULL) {
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

  # A small card over a light scrim: spinner, one plain line, and a slim bar
  # when the progress is known.
  content <- tags$div(
    class = "wfp-wait", role = "status", `aria-live` = "polite",
    tags$div(class = "wfp-wait-row",
             tags$span(class = "wfp-wait-ring"),
             tags$span(class = "wfp-wait-msg", message),
             if (has_pct) tags$span(class = "wfp-wait-pct", paste0(percent, "%"))),
    if (has_pct) tags$div(class = "wfp-wait-bar", tags$span(style = paste0("width:", percent, "%"))),
    if (!is.null(subtitle) && !is.na(subtitle)) tags$div(class = "wfp-wait-sub", subtitle),
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

  df[which(d >= lo & d <= hi), , drop = FALSE]
}

#' Build fuzzy-match groups from a character vector
#'
#' Uses base R `agrep` to assign group numbers to strings that are within
#' `max_dist` of each other. Strings without any near-match receive group 0.
#' This is intentionally simple to avoid an extra package dependency.
#'
#' @param keys Character vector of keys (e.g. pasted duplicate columns).
#' @param max_dist Maximum string distance passed to `agrep`.
#' @return Integer vector of group IDs (0 = no near-match).
#' @noRd
fuzzy_match_groups <- function(keys, max_dist = 1) {
  keys <- as.character(keys)
  n <- length(keys)
  groups <- integer(n)
  next_group <- 1L

  for (i in seq_len(n)) {
    if (groups[i] > 0) next
    matches <- agrep(
      pattern = keys[i],
      x = keys,
      max.distance = max_dist,
      ignore.case = TRUE,
      fixed = FALSE
    )
    if (length(matches) > 1) {
      groups[matches] <- next_group
      next_group <- next_group + 1L
    }
  }
  groups
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
         ref = "Breiman (2001), Machine Learning 45; Chen & Guestrin (2016), KDD; Hastie, Tibshirani & Friedman (2009), Elements of Statistical Learning; Cortes & Vapnik (1995), Machine Learning 20; marginal effects: Molnar (2022), Interpretable Machine Learning.")
  )))
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
write_data <- function(wb, sheet, x, ...) openxlsx::writeData(wb, sheet, export_text(round5(x)), ...)

#' A number with up to 5 decimals, no trailing zeros (2.93274, 4)
#' @noRd
fmt5 <- function(x) format(round(as.numeric(x), 5), scientific = FALSE, drop0trailing = TRUE, trim = TRUE)

#' Verdict card with a small archery animation
#'
#' The Advisory's wording stays as it is; the card adds a headline and an
#' animated target: the arrow hits the bullseye (with confetti) when both
#' errors are within tolerance, lands in an outer ring when the design needs a
#' second look, and misses when it needs redesigning. `animate = FALSE` shows
#' the final frame, so dragging the threshold does not replay the animation
#' until the verdict actually changes. Motion is off for users who ask their
#' system for reduced motion.
#' @param v A list from `error_verdict()`.
#' @param ... Extra content under the action (notes).
#' @noRd
verdict_card <- function(v, ..., animate = TRUE) {
  lvl <- if (isTRUE(v$level %in% c("good", "review", "redesign"))) v$level else "unknown"
  head <- c(good = "Bullseye!", review = "Close, but not quite a bullseye",
            redesign = "Missed the target", unknown = "Hard to say yet")[[lvl]]
  sub <- c(good = "Both errors are within tolerance.", review = "Nearly there: worth a second look.",
           redesign = "Back to the drawing board.", unknown = "Not enough to judge.")[[lvl]]
  # where the arrow tip lands, and at what angle
  pose <- c(good = "translate(70,50)", review = "translate(88,34) rotate(-8)",
            redesign = "translate(126,90) rotate(26)", unknown = "translate(70,50)")[[lvl]]
  confetti <- if (lvl == "good") lapply(1:12, function(i) {
    a <- 2 * pi * i / 12
    tags$i(style = sprintf("--dx:%.0fpx;--dy:%.0fpx;--c:%s;--r:%ddeg", 70 * cos(a), 60 * sin(a),
                           c("#0A6EB4", "#f7b825", "#26bde2", "#3f7e44", "#c5192d")[i %% 5 + 1], 40 * i))
  })
  svg <- HTML(sprintf(paste0(
    '<svg class="vd-svg" viewBox="0 0 130 100" aria-hidden="true">',
    '<g class="vd-target">',
    '<circle cx="70" cy="50" r="38" fill="#c5192d"/><circle cx="70" cy="50" r="29" fill="#fff"/>',
    '<circle cx="70" cy="50" r="20" fill="#c5192d"/><circle cx="70" cy="50" r="11" fill="#fff"/>',
    '<circle cx="70" cy="50" r="4" fill="#c5192d"/></g>',
    '%s',
    '</svg>'),
    if (lvl == "unknown") '<text class="vd-q" x="70" y="62" text-anchor="middle">?</text>' else sprintf(paste0(
      '<g transform="%s"><g class="vd-arrow">',
      '<line x1="-6" y1="0" x2="-52" y2="0" stroke="#1f2a37" stroke-width="3" stroke-linecap="round"/>',
      '<path d="M0 0 L-10 -5 L-10 5 Z" fill="#1f2a37"/>',
      '<path d="M-46 0 L-56 -8 L-50 -8 L-40 0 L-50 8 L-56 8 Z" fill="#f7b825"/>',
      '</g></g>'), pose)))
  tags$div(
    class = paste("wfp-verdict", paste0("is-", lvl), if (!animate) "no-anim"), role = "status",
    tags$div(class = "vd-stage", svg, if (length(confetti)) tags$div(class = "vd-confetti", confetti)),
    tags$div(
      class = "vd-text",
      tags$div(class = "vd-head", head, tags$span(class = "vd-sub", sub)),
      tags$div(class = "vd-interp", v$interpretation),
      tags$div(class = "vd-action", tags$em("Action: "), v$action),
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
    tags$div(class = "tw-splash-tagline", "Reach the right people"),
    tags$div(class = "tw-splash-bar", tags$span()),
    tags$div(class = "tw-splash-sub", "Preparing your workspace\u2026")
  )
  one_line <- gsub("[
]+", " ", paste(as.character(content), collapse = " "))
  HTML(gsub("'", "&#39;", one_line, fixed = TRUE))
}
