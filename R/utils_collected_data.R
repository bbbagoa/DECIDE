#' Shape collected-form data (MODA, Kobo, ODK) into plain columns
#'
#' Form servers return some answers in forms the analysis cannot use as they
#' are: a GPS point as one text ("lat lon altitude accuracy"), `_geolocation`
#' as a list, repeat groups and attachments as nested tables, and a
#' select-multiple answer as one text of space-separated choices. These
#' helpers split them into ordinary columns.
#' @name collected_data
#' @noRd
NULL

#' What each list column is, judged on all the pages together
#'
#' "geo" (`_geolocation`, or pairs of numbers), "table" (repeat groups,
#' attachments: nested tables) or "text". Decided once for all pages, so a
#' page where every answer happens to be empty is flattened the same way as
#' the others.
#' @noRd
list_column_kinds <- function(pages) {
  kinds <- list()
  for (p in pages) {
    if (!is.data.frame(p)) next
    for (nm in names(p)[vapply(p, is.list, logical(1))]) {
      x <- p[[nm]]
      k <- if (grepl("geolocation$", nm) || any(vapply(x, function(v) is.numeric(v) && length(v) == 2, logical(1)))) "geo"
           else if (any(vapply(x, is.data.frame, logical(1)))) "table" else "text"
      # geo and table win over text, which is what an all-empty page looks like
      if (is.null(kinds[[nm]]) || identical(kinds[[nm]], "text")) kinds[[nm]] <- k
    }
  }
  kinds
}

#' List columns of one downloaded page as plain columns
#'
#' geo -> `<name>_latitude`, `<name>_longitude`; table -> the number of
#' entries, `<name>_count`; text -> the values joined by "; ". Run on each page
#' before the pages are bound together, which would otherwise turn a list into
#' text such as "c(12.3, -1.5)".
#' @param kinds From `list_column_kinds()`; judged on this page alone if NULL.
#' @noRd
flatten_list_columns <- function(df, kinds = NULL) {
  if (!is.data.frame(df)) return(df)
  kinds <- kinds %||% list_column_kinds(list(df))
  for (nm in names(df)[vapply(df, is.list, logical(1))]) {
    x <- df[[nm]]
    new <- switch(kinds[[nm]] %||% "text",
      geo = {
        coord <- function(k) vapply(x, function(v) if (is.numeric(v) && length(v) == 2) as.numeric(v[k]) else NA_real_, numeric(1))
        stats::setNames(list(coord(1), coord(2)), paste0(nm, c("_latitude", "_longitude")))
      },
      table = stats::setNames(list(vapply(x, function(v) if (is.data.frame(v)) nrow(v) else 0L, integer(1))),
                              paste0(nm, "_count")),
      stats::setNames(list(vapply(x, function(v) {
        v <- unlist(v, use.names = FALSE)
        if (!length(v) || all(is.na(v))) NA_character_ else paste(v, collapse = "; ")
      }, character(1))), nm))
    df <- insert_columns(df, nm, new, drop = TRUE)
  }
  df
}

#' GPS answers split into latitude, longitude, altitude and precision
#'
#' Any text column whose answers all look like an ODK geopoint ("12.34
#' -1.56", optionally followed by altitude and accuracy) gets
#' `<name>_latitude`, `<name>_longitude` (and `_altitude`, `_precision` when
#' present) right after it. Coordinates outside the valid range leave the
#' column as it is.
#' @noRd
split_geopoints <- function(df) {
  num <- "-?[0-9]+(\\.[0-9]+)?"
  pat <- sprintf("^\\s*%s\\s+%s(\\s+%s){0,2}\\s*$", num, num, num)
  for (nm in names(df)) {
    x <- df[[nm]]
    if (!is.character(x)) next
    v <- x[!is.na(x) & nzchar(trimws(x))]
    # every answer a point, and decimals somewhere: "1 3" is a multi-select, not a place
    if (!length(v) || !all(grepl(pat, v)) || !any(grepl("\\.", v))) next
    parts <- strsplit(trimws(x), "\\s+")
    get <- function(k) vapply(parts, function(p) if (length(p) >= k) suppressWarnings(as.numeric(p[k])) else NA_real_, numeric(1))
    lat <- get(1); lon <- get(2)
    if (any(abs(lat) > 90, na.rm = TRUE) || any(abs(lon) > 180, na.rm = TRUE)) next
    new <- list(lat, lon)
    names(new) <- paste0(nm, c("_latitude", "_longitude"))
    alt <- get(3); acc <- get(4)
    if (any(!is.na(alt))) new[[paste0(nm, "_altitude")]] <- alt
    if (any(!is.na(acc))) new[[paste0(nm, "_precision")]] <- acc
    df <- insert_columns(df, nm, new[setdiff(names(new), names(df))])
  }
  df
}

#' One Yes/No column per choice of a select-multiple question
#'
#' @param x The answers: space-separated choice names (NA when not answered).
#' @param choices The question's choices, in form order.
#' @param yes_no The two labels, e.g. c("Yes", "No") or c("Oui", "Non").
#' @return A named list of character columns, `<name>_<choice>`.
#' @noRd
split_multiple <- function(x, choices, name, yes_no = import_yes_no()) {
  x <- as.character(x)
  uniq <- unique(x[!is.na(x)])
  sets <- strsplit(trimws(uniq), "\\s+")
  # Choices answered but missing from the form still get a column.
  choices <- unique(c(choices, unlist(sets, use.names = FALSE)))
  choices <- choices[!is.na(choices) & nzchar(choices)]
  at <- match(x, uniq)
  out <- lapply(choices, function(ch) {
    hit <- vapply(sets, function(s) ch %in% s, logical(1))
    v <- ifelse(hit[at], yes_no[1], yes_no[2])
    v[is.na(x)] <- NA_character_
    v
  })
  stats::setNames(out, paste0(name, "_", choices))
}

#' "Yes"/"No", or "Oui"/"Non" when the app is in French
#' @noRd
import_yes_no <- function() {
  s <- shiny::getDefaultReactiveDomain()
  lang <- if (is.null(s)) NULL else tryCatch(shiny::isolate(s$rootScope()$input$lang_selector), error = function(e) NULL)
  if (identical(lang, "fr")) c("Oui", "Non") else c("Yes", "No")
}

#' Does this column look like select-multiple answers?
#'
#' Every answer a set of choice codes separated by spaces: lower-case codes
#' or whole numbers (no decimals, capitals or punctuation, so GPS, dates,
#' place and household names do not qualify), no code twice in one answer,
#' 2 to 40 codes in all, and (from 20 answers) each code chosen at least
#' twice, which free text never is.
#' @noRd
looks_multiselect <- function(x) {
  if (!is.character(x)) return(FALSE)
  # Judged on the distinct answers, with how often each occurs, not on every
  # household: a 300k-row column has a handful of distinct values.
  u0 <- unique(x); u0 <- u0[!is.na(u0)]
  if (length(u0) > 20000) return(FALSE)
  times <- tabulate(match(x, u0), length(u0))
  v0 <- trimws(u0); keep <- nzchar(v0)
  v <- unique(v0[keep])
  # Quick rejections before splitting anything: identifiers and free text
  # have thousands of different answers; choice codes are lower-case words.
  if (length(v) < 2 || length(v) > 5000 || !any(grepl("\\s", v))) return(FALSE)
  if (!all(grepl("^[a-z0-9_-]+(\\s+[a-z0-9_-]+)*$", v))) return(FALSE)
  tk <- strsplit(v, "\\s+")
  all_t <- unlist(tk, use.names = FALSE)
  if (!all(grepl("^[a-z0-9_-]+$", all_t))) return(FALSE)
  if (any(vapply(tk, anyDuplicated, integer(1)) > 0)) return(FALSE)
  u <- unique(all_t)
  if (length(u) < 2 || length(u) > 40) return(FALSE)
  if (sum(times[keep]) >= 20) {
    # how many households used each choice
    per <- strsplit(v0[keep], "\\s+")
    used <- tapply(rep(times[keep], lengths(per)), unlist(per, use.names = FALSE), sum)
    if (any(used < 2)) return(FALSE)
  }
  TRUE
}

#' Split every select-multiple question into Yes/No columns
#'
#' @param known Named list: question -> its choices (from the form), split
#'   whatever the answers look like. Other text columns are split when
#'   `looks_multiselect()`. Columns already split in the source (Kobo / ODK
#'   exports: `question/choice` or `question.choice` holding 0/1 or
#'   True/False next to `question`) are relabelled Yes/No.
#' @noRd
split_multiselect <- function(df, known = list(), yes_no = import_yes_no()) {
  if (!is.data.frame(df) || !ncol(df)) return(df)
  # already split in the source: relabel
  for (nm in names(df)) {
    parent <- sub("[/.][^/.]+$", "", nm)
    if (identical(parent, nm) || !parent %in% names(df)) next
    v <- df[[nm]]
    s <- tolower(trimws(as.character(v)))
    ok <- is.na(s) | s %in% c("0", "1", "true", "false")
    if (!all(ok) || all(is.na(s))) next
    out <- ifelse(s %in% c("1", "true"), yes_no[1], yes_no[2])
    out[is.na(s)] <- NA_character_
    df[[nm]] <- out
  }
  for (nm in names(df)) {
    x <- df[[nm]]
    ch <- known[[nm]]
    if (is.null(ch) && !looks_multiselect(x)) next
    new <- split_multiple(x, ch %||% character(0), nm, yes_no)
    # Choice columns the source already has (question/choice, question.choice
    # or question_choice) are kept as they are.
    codes <- substring(names(new), nchar(nm) + 2L)
    have <- paste0(nm, rep(c("/", ".", "_"), each = length(codes)), codes) %in% names(df)
    if (is.null(ch) && any(have)) next
    df <- insert_columns(df, nm, new[setdiff(names(new), names(df))])
  }
  df
}

#' Put new columns right after `after` (optionally in its place)
#' @noRd
insert_columns <- function(df, after, new, drop = FALSE) {
  if (!length(new)) return(df)
  new <- as.data.frame(new, stringsAsFactors = FALSE, check.names = FALSE)
  i <- match(after, names(df))
  left <- df[, seq_len(if (drop) i - 1L else i), drop = FALSE]
  right <- if (i < ncol(df)) df[, (i + 1):ncol(df), drop = FALSE] else df[, 0, drop = FALSE]
  new <- new[, setdiff(names(new), c(names(left), names(right))), drop = FALSE]
  cbind(as.data.frame(left), new, as.data.frame(right))
}

#' What was done with a form definition, for the import summary
#'
#' @param before Column names before labels and splits.
#' @param df The data after them.
#' @param label_map From `build_odk_label_map()`, or NULL when the form
#'   definition could not be downloaded.
#' @return list of list(ok, text).
#' @noRd
form_import_notes <- function(before, df, label_map, downloaded = !is.null(label_map)) {
  added <- setdiff(names(df), before)
  gps <- sub("_latitude$", "", grep("_latitude$", added, value = TRUE))
  multi <- attr(label_map, "multiple") %||% character(0)
  multi <- multi[multi %in% before]
  labelled <- setdiff(intersect(names(label_map), before), multi)
  choice_cols <- if (length(multi)) added[Reduce(`|`, lapply(multi, function(m) startsWith(added, paste0(m, "_"))))] else character(0)
  lang <- attr(label_map, "label_column") %||% "label"
  c(
    if (!downloaded) list(list(ok = FALSE, text = "The form definition could not be downloaded: answers are shown as their codes, not their labels."))
    else if (is.null(label_map)) list(list(ok = TRUE, text = "Form definition read: it has no choice questions to label."))
    else list(list(ok = TRUE, text = sprintf("Choice labels applied to %d question%s (%s).", length(labelled) + length(multi),
                                             if (length(labelled) + length(multi) == 1) "" else "s", lang))),
    if (length(multi)) list(list(ok = TRUE, text = sprintf("%d select-multiple question%s split into %d Yes/No columns.",
                                                           length(multi), if (length(multi) == 1) "" else "s", length(choice_cols)))),
    if (length(gps)) list(list(ok = TRUE, text = sprintf("GPS split into latitude and longitude: %s.", paste(gps, collapse = ", "))))
  )
}
