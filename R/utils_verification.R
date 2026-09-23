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
  na <- suppressWarnings(as.numeric(as.character(a)))
  nb <- suppressWarnings(as.numeric(as.character(b)))

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
