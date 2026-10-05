#' Data quality report: everything the Data Quality page checks, in one record
#'
#' `dq_report_data()` computes the summary from the data in scope and the
#' audit trail, whether or not each Data Quality tab was opened: completeness
#' of the mapped fields and of all columns, duplicate ids and records,
#' outliers in the mapped numbers, GPS, spelling variants of the area names,
#' enumerators to review, and the corrections made. `write_dq_report()` writes
#' it as one self-contained HTML page (see `report_write_page()`).
#' @noRd
NULL

#' Mapped fields, with the name the report uses
#' @noRd
dq_field_labels <- function() {
  c(unique_id = "Household ID", date = "Interview date", enumerator_id = "Enumerator",
    admin1 = "Admin 1", admin2 = "Admin 2", admin3 = "Admin 3", admin4 = "Admin 4", village = "Village",
    lon = "Longitude", lat = "Latitude", hhh_sex = "Head of household sex", hhh_age = "Head of household age",
    hh_size = "Household size", residency = "Residency status", childU5 = "Children under 5",
    disability = "Disability", v_score = "Vulnerability score", v_groups = "Vulnerability group",
    eligibility = "Eligibility", weight = "Sampling weight")
}

#' @param df The data in scope.
#' @param setup The variable mapping (a list, as `reactiveValuesToList(user_setup)`).
#' @param log The audit trail (may be NULL).
#' @noRd
dq_report_data <- function(df, setup, log = NULL) {
  col_of <- function(k) {
    v <- as.character(setup[[k]] %||% "")[1]
    if (is.na(v) || !nzchar(v) || !v %in% names(df)) NULL else v
  }
  labels <- dq_field_labels()
  mapped <- Filter(Negate(is.null), lapply(stats::setNames(names(labels), names(labels)), col_of))
  n <- nrow(df)
  blank <- function(x) is.na(x) | (is.character(x) & !nzchar(trimws(x))) | (is.factor(x) & !nzchar(trimws(as.character(x))))

  # Completeness: the mapped fields, then every column.
  miss_field <- vapply(mapped, function(cl) mean(blank(df[[cl]])), numeric(1))
  fields <- data.frame(field = unname(labels[names(mapped)]), column = unname(unlist(mapped)),
                       missing = unname(miss_field), stringsAsFactors = FALSE)
  fields <- fields[order(-fields$missing), , drop = FALSE]
  miss_all <- vapply(df, function(x) mean(blank(x)), numeric(1))
  columns <- data.frame(column = names(miss_all), missing = unname(miss_all), stringsAsFactors = FALSE)
  columns <- columns[order(-columns$missing), , drop = FALSE]
  required <- intersect(c("unique_id", "date", "admin1", "admin2", "hhh_sex", "hhh_age", "hh_size"), names(mapped))
  any_req_missing <- if (length(required)) {
    m <- rep(FALSE, n)
    for (k in required) m <- m | blank(df[[mapped[[k]]]])
    sum(m)
  } else NA_integer_

  # Duplicates.
  id <- mapped$unique_id
  dup_ids <- if (!is.null(id)) {
    v <- as.character(df[[id]]); v <- v[!is.na(v) & nzchar(v)]
    d <- unique(v[duplicated(v)])
    list(ids = length(d), records = sum(v %in% d), examples = utils::head(d, 5))
  }
  exact <- tryCatch(count_duplicate_rows(df), error = function(e) NA_integer_)

  # Outliers in the mapped numbers (IQR 1.5 and the suggested allowed ranges).
  num_keys <- intersect(c("hh_size", "hhh_age", "childU5", "v_score"), names(mapped))
  num_cols <- unlist(mapped[num_keys])
  outliers <- if (length(num_cols)) {
    ranges <- stats::setNames(lapply(num_keys, suggested_range), num_cols)
    numeric_audit(df, num_cols, "IQR", 1.5, ranges = ranges,
                  labels = stats::setNames(unname(labels[num_keys]), num_cols))
  }

  # GPS.
  gps <- NULL
  if (!is.null(mapped$lat) && !is.null(mapped$lon)) {
    la <- as_number(df[[mapped$lat]]); lo <- as_number(df[[mapped$lon]])
    has <- !is.na(la) & !is.na(lo)
    bad <- has & (abs(la) > 90 | abs(lo) > 180 | (la == 0 & lo == 0))
    gps <- list(with = sum(has & !bad), missing = sum(!has), invalid = sum(bad))
  }

  # Area names: distinct values and likely spelling variants.
  areas <- list()
  for (k in intersect(c("admin1", "admin2", "admin3", "village"), names(mapped))) {
    v <- unique(trimws(as.character(df[[mapped[[k]]]])))
    v <- v[!is.na(v) & nzchar(v)]
    var <- character(0)
    if (length(v) >= 2 && length(v) <= 2000) {
      g <- fuzzy_match_groups(v, max_dist = 1)
      grp <- split(v[g > 0], g[g > 0])
      var <- vapply(grp, function(x) paste(sort(x), collapse = " / "), character(1))
    }
    areas[[labels[[k]]]] <- list(distinct = length(v), variants = unname(var))
  }

  # Enumerators.
  enumerators <- if (!is.null(mapped$enumerator_id)) tryCatch(enumerator_metrics(df, setup), error = function(e) NULL)

  # Corrections made (the registration data's entries of the audit trail).
  corrections <- NULL
  if (is.data.frame(log) && nrow(log)) {
    lg <- log[audit_phase(log$action) == "Selection", , drop = FALSE]
    if (nrow(lg)) {
      act <- sub("^Selection: ", "", lg$action)
      corrections <- list(by_action = sort(table(act), decreasing = TRUE),
                          deleted = length(deleted_uids(lg)),
                          recent = utils::tail(lg, 15))
    }
  }

  dates <- if (!is.null(mapped$date)) suppressWarnings(as.Date(df[[mapped$date]]))
  list(n = n, ncol = ncol(df), mapped = mapped,
       date_range = if (length(dates) && any(!is.na(dates))) range(dates, na.rm = TRUE),
       fields = fields, columns = columns, required = unname(labels[required]), any_req_missing = any_req_missing,
       completeness = if (nrow(fields)) 1 - mean(fields$missing) else NA_real_,
       dup_ids = dup_ids, exact = exact, outliers = outliers, gps = gps, areas = areas,
       enumerators = enumerators, corrections = corrections)
}

#' @param x Output of `dq_report_data()`, plus `country_office` and `scope`.
#' @noRd
write_dq_report <- function(file, x, lang = "en") {
  pct <- function(v) ifelse(is.na(v), "n/a", sprintf("%.1f%%", 100 * v))
  num <- function(v) format(v, big.mark = ",")
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  n_sec <- 0
  sec <- function(title) { n_sec <<- n_sec + 1; add(sprintf("## %d. %s", n_sec, title), "") }

  add("# Data quality report", "",
      "A summary of the checks run on the registration data in scope: completeness, duplicates, outliers,",
      "GPS, area names and enumerators, and the corrections made so far. Figures are for the data as it stands now.", "",
      "## Key results", "", "@@TILES@@", "")

  sec("Data in scope")
  add(sprintf("- Records: **%s**; columns: %s", num(x$n), num(x$ncol)),
      sprintf("- Areas covered: %s", x$scope %||% "All areas"),
      if (!is.null(x$date_range)) sprintf("- Interview dates: %s to %s", format(x$date_range[1]), format(x$date_range[2])) else NULL,
      sprintf("- Mapped fields: %d", length(x$mapped)), "")

  sec("Completeness")
  f <- x$fields
  gaps <- f[f$missing > 0.05, , drop = FALSE]
  full <- f$field[f$missing == 0]
  add("Share of records where each mapped field is empty.", "", "@@FIG:missing@@", "")
  if (nrow(gaps)) {
    add("### Mapped fields with more than 5% empty", "",
        md_table(data.frame(Field = gaps$field, Column = gaps$column, Empty = pct(gaps$missing), check.names = FALSE)), "")
  } else add("_Every mapped field is at least 95% complete._", "")
  if (length(full)) add(sprintf("**Complete in every record:** %s.", paste(full, collapse = ", ")), "")
  if (!is.na(x$any_req_missing)) {
    add(sprintf("%s records (%s) miss at least one of the core fields (%s).", num(x$any_req_missing),
                pct(x$any_req_missing / max(1, x$n)), paste(x$required, collapse = ", ")), "")
  }
  top <- utils::head(x$columns[x$columns$missing > 0, , drop = FALSE], 10)
  if (nrow(top)) add("### Columns with the most empty answers (all columns)", "",
                     md_table(data.frame(Column = top$column, Empty = pct(top$missing), check.names = FALSE)), "")

  sec("Duplicates")
  if (!is.null(x$dup_ids)) {
    add(if (x$dup_ids$ids) sprintf("- **%s household IDs are used more than once**, on %s records (for example %s).",
                                   num(x$dup_ids$ids), num(x$dup_ids$records), paste(x$dup_ids$examples, collapse = ", "))
        else "- Every household ID is unique.")
  }
  add(if (is.na(x$exact)) "- Identical records: not checked." else if (x$exact) sprintf("- %s records repeat an earlier record in every column.", num(x$exact)) else "- No record repeats another in every column.",
      "- Duplicates on other columns (name, phone, location...) are checked in the Duplicates tab, on the columns you choose.", "")

  sec("Outliers in the mapped numbers")
  o <- x$outliers
  if (is.null(o) || !nrow(o)) {
    add("_No numeric field is mapped (household size, head's age, children under 5, score)._", "")
  } else {
    add("Values outside the IQR fences (1.5 x IQR) or the allowed range. Values verified and kept in the Outliers tab are included here.", "",
        md_table(data.frame(Field = ifelse(nzchar(o$mapped), o$mapped, o$variable), Answered = o$answered,
                            Min = o$min, Median = o$median, Max = o$max, `Allowed range` = o$allowed,
                            Flagged = o$flagged, `Flagged (%)` = o$flagged_pct, check.names = FALSE)), "")
  }

  if (!is.null(x$gps)) {
    sec("GPS")
    add(sprintf("- With valid coordinates: %s (%s)", num(x$gps$with), pct(x$gps$with / max(1, x$n))),
        sprintf("- Missing coordinates: %s", num(x$gps$missing)),
        sprintf("- Invalid coordinates (out of range, or 0,0): %s", num(x$gps$invalid)), "")
  }

  if (length(x$areas)) {
    sec("Area names")
    add("Names that differ by one letter are likely spelling variants of the same place; the Location names tab normalises them.", "",
        md_table(data.frame(Level = names(x$areas),
                            `Distinct names` = vapply(x$areas, function(a) a$distinct, numeric(1)),
                            `Possible variants` = vapply(x$areas, function(a) length(a$variants), numeric(1)),
                            Examples = vapply(x$areas, function(a) paste(utils::head(a$variants, 3), collapse = "; "), character(1)),
                            check.names = FALSE)), "")
  }

  e <- x$enumerators
  if (!is.null(e) && nrow(e)) {
    sec("Enumerators")
    rv <- e[e$flag == "Review", , drop = FALSE]
    add(sprintf("%d enumerators; **%d to review** (short or long interviews, many empty answers, or an unusually busy day).",
                nrow(e), nrow(rv)), "")
    if (nrow(rv)) {
      shown <- utils::head(rv[order(-rv$interviews), , drop = FALSE], 15)
      add(md_table(data.frame(Enumerator = shown$enumerator_id, Interviews = round(shown$interviews),
                              Why = shown$reasons, check.names = FALSE)),
          if (nrow(rv) > 15) sprintf("_15 of %d shown; the Enumerator performance tab lists them all._", nrow(rv)) else NULL, "")
    }
  }

  sec("Corrections made")
  cr <- x$corrections
  if (is.null(cr)) {
    add("_No correction has been recorded on this data yet._", "")
  } else {
    add(sprintf("%s entries in the audit trail; %s records deleted.", num(sum(cr$by_action)), num(cr$deleted)), "",
        md_table(data.frame(Action = names(cr$by_action), Entries = as.integer(cr$by_action), check.names = FALSE)), "")
    rc <- cr$recent
    add("### The latest entries", "",
        md_table(data.frame(When = rc$timestamp, Action = sub("^Selection: ", "", rc$action),
                            Detail = substr(paste(rc$column, rc$new_value), 1, 120), check.names = FALSE)),
        "_The full history is in the Audit Trail._", "")
  }

  if (length(x$variables_md)) add(x$variables_md)
  sec("Method")
  add("Empty means missing, blank text or \"NULL\". Outliers use Tukey's fences (quartiles +/- 1.5 x IQR) combined with an allowed range",
      "for household size (1-30), head's age (12-110) and children under 5 (0-10). Spelling variants are names within one edit of each other.",
      "Enumerator flags compare each enumerator with the team: interview length outside the IQR fences, empty answers above the team mean + 2 SD,",
      "or a day far busier than usual.", "")

  plots <- list()
  if (nrow(f)) {
    fd <- utils::head(f, 15)
    d <- data.frame(field = fd$field, empty = round(100 * fd$missing, 1))
    names(d)[2] <- i18n_lookup("Empty (%)", lang)
    plots$missing <- rp_hbars(d, stats::setNames("#0A6EB4", names(d)[2]), i18n_lookup("Empty (%)", lang))
  }
  report_write_page(
    file, paste(L, collapse = "\n"), plots,
    captions = c(missing = if (nrow(f) > 15) "Empty answers by mapped field (the 15 highest)" else "Empty answers by mapped field"),
    lang = lang, title = "Data quality report", record = "Data quality record",
    meta = c("Country office" = x$country_office %||% "",
             "Generated" = fmt_datetime(),
             "Records" = num(x$n)),
    footer = "This record documents the quality of the registration data before selection.",
    blocks = list("@@TILES@@" = profile_tiles(dq_tiles(x), lang)))
}

#' Headline tiles of the data quality report
#' @noRd
dq_tiles <- function(x) {
  tile <- function(icon, value, label, sub) list(icon = icon, value = value, label = label, sub = sub)
  e <- x$enumerators
  o <- x$outliers
  list(
    tile("family", format(x$n, big.mark = ","), "Records in scope", sprintf("%d columns", x$ncol)),
    tile("field", if (is.na(x$completeness)) "n/a" else sprintf("%.1f%%", 100 * x$completeness), "Completeness",
         "of the mapped fields, on average"),
    tile("flag", format(if (is.null(x$dup_ids)) 0 else x$dup_ids$ids, big.mark = ","), "Duplicated household IDs",
         if (is.null(x$dup_ids)) "no ID mapped" else sprintf("on %s records", format(x$dup_ids$records, big.mark = ","))),
    tile("health", format(if (is.null(o)) 0 else sum(o$flagged), big.mark = ","), "Values flagged as outliers",
         "in the mapped numbers"),
    tile("person", if (is.null(e)) "n/a" else as.character(sum(e$flag == "Review")), "Enumerators to review",
         if (is.null(e)) "no enumerator mapped" else sprintf("of %d", nrow(e))),
    tile("shelter", format(if (is.null(x$corrections)) 0 else sum(x$corrections$by_action), big.mark = ","),
         "Corrections recorded", "in the audit trail"))
}
