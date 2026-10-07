#' Normalise a vector for like-for-like comparison
#'
#' Trims whitespace, treats the usual "empty" spellings as `NA`, and optionally
#' folds case. Used so that `" Yes "`, `"yes"` and `"YES"` are not reported as
#' three different answers during a back-check.
#'
#' @param x A vector of any type.
#' @param ignore_case Logical; fold to lower case before comparing.
#' @return A character vector the same length as `x`.
#' @noRd
normalise_for_compare <- function(x, ignore_case = TRUE) {
  v <- trimws(as.character(x))
  v[v %in% c("", "NA", "NULL", "N/A", "n/a", ".", "-")] <- NA_character_
  if (isTRUE(ignore_case)) v <- tolower(v)
  v
}

#' Element-wise agreement between two vectors
#'
#' Two missing values agree; one missing value does not. Numeric-looking pairs
#' are compared with a tolerance so that 10 and 10.0 (or a rounded re-entry)
#' are not flagged, everything else is compared as normalised text.
#'
#' @param a,b Vectors of equal length.
#' @param numeric_tolerance Absolute tolerance for numeric comparison.
#' @param ignore_case Logical; passed to `normalise_for_compare()`.
#' @return Logical vector: `TRUE` where the pair agrees.
#' @noRd
values_agree <- function(a, b, numeric_tolerance = 0, ignore_case = TRUE) {
  na <- as_number(a)
  nb <- as_number(b)

  # Treat the column as numeric only when BOTH sides parse cleanly wherever
  # they are present; otherwise a numeric-looking text column (IDs with leading
  # zeros, codes) would be compared on its numeric value and lose information.
  a_ok <- !is.na(na) | is.na(a)
  b_ok <- !is.na(nb) | is.na(b)
  numeric_mode <- all(a_ok) && all(b_ok) && (any(!is.na(na)) || any(!is.na(nb)))

  if (numeric_mode) {
    both_na <- is.na(na) & is.na(nb)
    one_na <- xor(is.na(na), is.na(nb))
    out <- rep(FALSE, length(na))
    out[both_na] <- TRUE
    cmp <- !both_na & !one_na
    out[cmp] <- abs(na[cmp] - nb[cmp]) <= numeric_tolerance
    return(out)
  }

  sa <- normalise_for_compare(a, ignore_case)
  sb <- normalise_for_compare(b, ignore_case)
  both_na <- is.na(sa) & is.na(sb)
  out <- rep(FALSE, length(sa))
  out[both_na] <- TRUE
  cmp <- !is.na(sa) & !is.na(sb)
  out[cmp] <- sa[cmp] == sb[cmp]
  out
}

#' Compare a verification (back-check) dataset against the original records
#'
#' Joins the two datasets on `key_col`, compares every requested column, and
#' reports both a per-field agreement summary and a long table of the individual
#' discordances so an enumerator's answers can be reviewed one by one.
#'
#' Records present on only one side are counted but never compared; duplicate
#' keys keep their first occurrence, because a back-check is expected to hold at
#' most one revisit per household.
#'
#' @param original A data.frame of the originally collected records.
#' @param verification A data.frame of the re-collected / verification records.
#' @param key_col Name of the household identifier, present in both frames.
#' @param cols Columns to compare. `NULL` (default) uses every column the two
#'   frames share, excluding `key_col`.
#' @param numeric_tolerance Absolute tolerance for numeric comparisons.
#' @param ignore_case Logical; compare text case-insensitively.
#' @return A list with `key_col`, `matched_n`, `only_original_n`,
#'   `only_verification_n`, `cols`, `field_summary`, `discordances`,
#'   `records_with_discordance` and `overall_agreement`; or `NULL` when the
#'   inputs are unusable.
#' @noRd
compare_verification <- function(original, verification, key_col, cols = NULL,
                                 numeric_tolerance = 0, ignore_case = TRUE) {
  if (is.null(original) || is.null(verification)) return(NULL)
  if (is.null(key_col) || !nzchar(key_col)) return(NULL)
  if (!key_col %in% names(original) || !key_col %in% names(verification)) return(NULL)

  o_key <- as.character(original[[key_col]])
  v_key <- as.character(verification[[key_col]])

  o_keep <- !duplicated(o_key) & !is.na(o_key) & nzchar(o_key)
  v_keep <- !duplicated(v_key) & !is.na(v_key) & nzchar(v_key)
  o <- original[o_keep, , drop = FALSE]
  v <- verification[v_keep, , drop = FALSE]
  o_key <- o_key[o_keep]
  v_key <- v_key[v_keep]

  common <- intersect(o_key, v_key)
  oi <- match(common, o_key)
  vi <- match(common, v_key)

  if (is.null(cols)) {
    cols <- setdiff(intersect(names(o), names(v)), key_col)
  } else {
    cols <- setdiff(intersect(cols, intersect(names(o), names(v))), key_col)
  }

  empty_summary <- data.frame(
    variable = character(), compared = integer(), agree = integer(),
    disagree = integer(), agreement_rate = numeric(), stringsAsFactors = FALSE
  )
  empty_disc <- data.frame(
    key = character(), variable = character(),
    original = character(), verification = character(), stringsAsFactors = FALSE
  )

  if (length(common) == 0 || length(cols) == 0) {
    return(list(
      key_col = key_col,
      matched_n = length(common),
      only_original_n = length(setdiff(o_key, v_key)),
      only_verification_n = length(setdiff(v_key, o_key)),
      cols = cols,
      field_summary = empty_summary,
      discordances = empty_disc,
      records_with_discordance = 0L,
      overall_agreement = NA_real_
    ))
  }

  summaries <- vector("list", length(cols))
  disc_parts <- vector("list", length(cols))
  # Per-record flag: did this household disagree on at least one field?
  any_disc <- rep(FALSE, length(common))

  for (i in seq_along(cols)) {
    col <- cols[i]
    a <- o[[col]][oi]
    b <- v[[col]][vi]
    ok <- values_agree(a, b, numeric_tolerance = numeric_tolerance, ignore_case = ignore_case)

    summaries[[i]] <- data.frame(
      variable = col,
      compared = length(ok),
      agree = sum(ok),
      disagree = sum(!ok),
      agreement_rate = if (length(ok) > 0) sum(ok) / length(ok) else NA_real_,
      stringsAsFactors = FALSE
    )

    bad <- which(!ok)
    if (length(bad) > 0) {
      any_disc[bad] <- TRUE
      disc_parts[[i]] <- data.frame(
        key = common[bad],
        variable = col,
        original = as.character(a[bad]),
        verification = as.character(b[bad]),
        stringsAsFactors = FALSE
      )
    }
  }

  field_summary <- do.call(rbind, summaries)
  field_summary <- field_summary[order(field_summary$agreement_rate,
                                       -field_summary$disagree), , drop = FALSE]

  disc_parts <- Filter(Negate(is.null), disc_parts)
  discordances <- if (length(disc_parts) > 0) do.call(rbind, disc_parts) else empty_disc

  total_cmp <- sum(field_summary$compared)
  list(
    key_col = key_col,
    matched_n = length(common),
    only_original_n = length(setdiff(o_key, v_key)),
    only_verification_n = length(setdiff(v_key, o_key)),
    cols = cols,
    field_summary = field_summary,
    discordances = discordances,
    records_with_discordance = sum(any_disc),
    overall_agreement = if (total_cmp > 0) sum(field_summary$agree) / total_cmp else NA_real_
  )
}

#' What the back-check says beyond the field table
#'
#' Where the discordances concentrate (by enumerator, by area), the answers
#' that most often change between the two rounds, the households with the
#' most discordances, and, for number fields, whether the back-check tends to
#' record more or less. Everything is computed from `compare_verification()`
#' plus the original records (for the enumerator and the areas).
#'
#' @param r Output of `compare_verification()`.
#' @param original Original records (the sample), with `r$key_col`.
#' @param groups Named character vector: label -> column in `original`
#'   (e.g. c(Enumerator = "enum", "Admin 1" = "province")).
#' @param matched Keys present in both rounds (the households compared).
#' @return list(by_group, patterns, households, direction), or NULL.
#' @noRd
verification_insights <- function(r, original = NULL, groups = character(0), matched = NULL) {
  if (is.null(r) || !r$matched_n || !length(r$cols)) return(NULL)
  d <- r$discordances
  n_fields <- length(r$cols)
  keys <- if (!is.null(original) && r$key_col %in% names(original)) as.character(original[[r$key_col]]) else character(0)
  if (length(keys) && !is.null(matched)) {
    keep <- keys %in% as.character(matched)
    original <- original[keep, , drop = FALSE]; keys <- keys[keep]
  }

  # Agreement per enumerator / area: answers that agree among those compared.
  by_group <- list()
  for (lab in names(groups)) {
    col <- groups[[lab]]
    if (!length(keys) || !nzchar(col) || !col %in% names(original)) next
    g <- as.character(original[[col]]); g[is.na(g) | !nzchar(trimws(g))] <- "(missing)"
    first <- !duplicated(keys)
    map <- stats::setNames(g[first], keys[first])
    hh <- table(map)
    dg <- if (nrow(d)) table(factor(map[d$key], levels = names(hh))) else hh * 0
    hd <- if (nrow(d)) table(factor(map[unique(d$key)], levels = names(hh))) else hh * 0
    out <- data.frame(group = names(hh), households = as.integer(hh),
                      with_discordance = as.integer(hd[names(hh)]),
                      discordant_answers = as.integer(dg[names(hh)]), stringsAsFactors = FALSE)
    out$agreement <- 1 - out$discordant_answers / pmax(1, out$households * n_fields)
    out <- out[order(out$agreement, -out$households), , drop = FALSE]
    rownames(out) <- NULL
    by_group[[lab]] <- out
  }

  # The answers that most often change, per field.
  patterns <- NULL
  if (nrow(d)) {
    o <- ifelse(is.na(d$original) | !nzchar(trimws(d$original)), "(blank)", trimws(d$original))
    v <- ifelse(is.na(d$verification) | !nzchar(trimws(d$verification)), "(blank)", trimws(d$verification))
    p <- stats::aggregate(list(n = rep(1L, nrow(d))), list(field = d$variable, first = o, back = v), sum)
    patterns <- utils::head(p[order(-p$n, p$field), , drop = FALSE], 15)
    rownames(patterns) <- NULL
  }

  # Households with the most discordances.
  households <- NULL
  if (nrow(d)) {
    per <- split(d$variable, d$key)
    households <- data.frame(household = names(per), fields = lengths(per),
                             which = vapply(per, function(f) paste(utils::head(unique(f), 6), collapse = ", "), character(1)),
                             stringsAsFactors = FALSE)
    households <- utils::head(households[order(-households$fields, households$household), , drop = FALSE], 15)
    rownames(households) <- NULL
  }

  # Number fields: does the back-check record more, or less?
  direction <- NULL
  if (nrow(d)) {
    a <- suppressWarnings(as.numeric(d$original)); b <- suppressWarnings(as.numeric(d$verification))
    ok <- !is.na(a) & !is.na(b)
    if (any(ok)) {
      s <- stats::aggregate(list(higher = b[ok] > a[ok], lower = b[ok] < a[ok], gap = b[ok] - a[ok]),
                            list(field = d$variable[ok]), function(x) if (is.logical(x)) sum(x) else mean(x))
      direction <- s[order(-(s$higher + s$lower)), , drop = FALSE]
      rownames(direction) <- NULL
    }
  }
  list(by_group = by_group, patterns = patterns, households = households, direction = direction)
}

#' Agreement by field as an ECharts option (the Spot Checking page)
#'
#' Worst-agreeing fields at the top; bars coloured by the reading of the
#' agreement (95% or more, 90-95%, below 90%), dashed lines at 90 and 95.
#' @param fs `compare_verification()$field_summary`.
#' @noRd
verification_field_chart <- function(fs) {
  fs <- fs[order(fs$agreement_rate), , drop = FALSE]
  pct <- 100 * fs$agreement_rate
  col <- ifelse(is.na(pct), "#8a96a3", ifelse(pct >= 95, "#3f7e44", ifelse(pct >= 90, "#f7b825", "#c5192d")))
  esc <- htmltools::htmlEscape
  opt <- list(
    grid = list(left = 8, right = 44, top = 8, bottom = 30, containLabel = TRUE),
    tooltip = list(trigger = "item", formatter = "fn:tip"),
    xAxis = list(type = "value", min = 0, max = 100, name = "% agreement", nameLocation = "middle", nameGap = 24),
    yAxis = list(type = "category", inverse = TRUE, data = I(as.character(fs$variable))),
    series = list(list(
      type = "bar", barMaxWidth = 18,
      data = lapply(seq_len(nrow(fs)), function(i) list(
        value = if (is.na(pct[i])) "-" else round(pct[i], 1), itemStyle = list(color = col[i]),
        tip = sprintf("<b>%s</b><br>%s agreement<br>%s of %s answers agree", esc(fs$variable[i]),
                      if (is.na(pct[i])) "n/a" else sprintf("%.1f%%", pct[i]),
                      format(fs$agree[i], big.mark = ","), format(fs$compared[i], big.mark = ",")))),
      label = list(show = TRUE, position = "right", formatter = "{c}%", fontSize = 10, textBorderWidth = 0),
      markLine = list(silent = TRUE, symbol = "none", label = list(show = FALSE),
                      lineStyle = list(type = "dashed", color = "#8a96a3"),
                      data = list(list(xAxis = 90), list(xAxis = 95))))))
  attr(opt, "height") <- max(240, 26 * nrow(fs) + 70)
  opt
}
