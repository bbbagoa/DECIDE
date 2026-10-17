#' Data-quality health check: one row per check, with what it found
#'
#' A quick pass over the data in scope with the same rules as the Data Quality
#' tabs (which hold the detail and the corrections, and the DQ report the full
#' record): repeated IDs, missing answers, outliers in the mapped numbers,
#' empty or odd area names, spelling variants of area names, and flagged
#' enumerators.
#'
#' @param df Data in scope.
#' @param setup The variable mapping (`user_setup`, or a list with the same keys).
#' @return data.frame(check, tab, found, status) where `status` is "ok",
#'   "review" or "na" (field not mapped) and `tab` is the Data Quality tab
#'   that handles it.
#' @noRd
dq_health <- function(df, setup) {
  col <- function(k) { cl <- setup[[k]]; if (length(cl) == 1 && !is.na(cl) && nzchar(cl) && cl %in% names(df)) cl else NULL }
  num <- function(v) format(v, big.mark = ",")
  row <- function(check, tab, found, status) data.frame(check = check, tab = tab, found = found, status = status, stringsAsFactors = FALSE)
  n <- nrow(df)
  out <- list()

  # repeated household IDs
  id <- col("unique_id")
  out[[1]] <- if (is.null(id)) row("Duplicates", "Duplicates", "No household ID mapped", "na") else {
    v <- df[[id]]; ok <- !is.na(v) & nzchar(trimws(as.character(v)))
    d <- sum(ok & (duplicated(v) | duplicated(v, fromLast = TRUE)))
    row("Duplicates", "Duplicates",
        if (d) sprintf("%s records share a household ID", num(d)) else "Every household ID is unique",
        if (d) "review" else "ok")
  }

  # missing answers, one column at a time (no n x p temporary)
  miss <- vapply(df, function(v) { if (!n) return(0); m <- is.na(v); if (is.character(v)) m <- m | !nzchar(trimws(v)) | v == "NULL"; mean(m) }, numeric(1))
  gaps <- sum(miss > 0.10)
  out[[2]] <- row("Missing answers", "Missing Data Checking",
                  sprintf("%s of %s columns miss more than 10%% of answers (%.1f%% of all answers missing)",
                          num(gaps), num(length(miss)), 100 * if (length(miss)) mean(miss) else 0),
                  if (gaps) "review" else "ok")

  # outliers in the mapped numbers (IQR fences, as on the Outliers tab)
  keys <- c(hh_size = "Household size", hhh_age = "Age of the head", childU5 = "Children under 5")
  cols <- Filter(Negate(is.null), lapply(names(keys), col))
  out[[3]] <- if (!length(cols)) row("Outliers", "Outliers", "No household size, age or children under 5 mapped", "na") else {
    a <- numeric_audit(df, unlist(cols))
    k <- sum(a$flagged)
    row("Outliers", "Outliers",
        if (k) sprintf("%s unusual values in %s", num(k), paste(a$variable[a$flagged > 0], collapse = ", ")) else "No unusual value in the mapped numbers",
        if (k) "review" else "ok")
  }

  # people's names (household head, beneficiary...): the Spelling & Integrity
  # rules (empty, one letter, digits, placeholders) on the name columns found
  nm <- name_cols_guess(df, setup)
  out[[4]] <- if (!length(nm)) row("Names and spelling", "Spelling & Integrity", "No name column found (choose them in Spelling & Integrity)", "na") else {
    b <- nrow(find_bad_names(df, nm))
    row("Names and spelling", "Spelling & Integrity",
        if (b) sprintf("%s records with an empty, too short, placeholder or digit-containing name (%s)", num(b), paste(nm, collapse = ", "))
        else sprintf("Names look complete (%s)", paste(nm, collapse = ", ")),
        if (b) "review" else "ok")
  }

  areas <- unlist(Filter(Negate(is.null), lapply(c("admin1", "admin2", "admin3", "admin4", "village"), col)))
  # spelling variants of the same area name (one typo apart)
  out[[5]] <- if (!length(areas)) row("Location names", "Location names normalization", "No area mapped", "na") else {
    v <- sum(vapply(areas, function(a) {
      u <- unique(as.character(df[[a]])); u <- u[!is.na(u) & nzchar(trimws(u))]
      if (length(u) < 2) return(0L)
      g <- fuzzy_match_groups(u, max_dist = 1)
      as.integer(sum(g > 0))
    }, integer(1)))
    row("Location names", "Location names normalization",
        if (v) sprintf("%s area names have a near-identical spelling", num(v)) else "No near-identical area names",
        if (v) "review" else "ok")
  }

  # enumerators flagged against the team
  out[[6]] <- if (is.null(col("enumerator_id"))) row("Enumerators", "Enumerator Performance", "No enumerator mapped", "na") else {
    m <- tryCatch(enumerator_metrics(df, setup), error = function(e) NULL)
    if (is.null(m) || !nrow(m)) row("Enumerators", "Enumerator Performance", "Not enough interviews to compare", "na") else {
      f <- sum(m$flag == "Review")
      row("Enumerators", "Enumerator Performance",
          if (f) sprintf("%s of %s enumerators flagged for review", num(f), num(nrow(m))) else sprintf("All %s enumerators in line with the team", num(nrow(m))),
          if (f) "review" else "ok")
    }
  }
  do.call(rbind, out)
}

#' Columns holding people's names: text columns named like a name (name,
#' nom, prenom, surname...), not the mapped areas, not the survey staff
#' @noRd
name_cols_guess <- function(df, setup) {
  mapped <- unlist(lapply(c("unique_id", "admin1", "admin2", "admin3", "admin4", "village", "enumerator_id"), function(k) {
    v <- as.character(setup[[k]] %||% "")[1]; if (!is.na(v) && nzchar(v)) v }))
  cols <- setdiff(names(df), mapped)
  cols <- cols[grepl("name|nom|prenom|surname|beneficiaire", cols, ignore.case = TRUE) & !grepl("^@?_", cols) &
               !grepl("enum|agent|surveyor|interview|supervis|admin|village|site|province|territ|zone|aire|region|district|commune|locali", cols, ignore.case = TRUE)]
  Filter(function(cl) is.character(df[[cl]]) || is.factor(df[[cl]]), cols)
}

#' Data small enough for the health check to run by itself when its tab
#' opens (rows x columns); above it the page asks for a click.
#' 5 million cells by default (e.g. 100,000 records x 50 columns);
#' TARGETWISE_HEALTH_AUTO_CELLS sets another size.
#' @noRd
health_auto_cells <- function() {
  v <- suppressWarnings(as.numeric(tw_env("HEALTH_AUTO_CELLS", "")))
  if (length(v) == 1 && !is.na(v) && v >= 0) v else 5e6
}

#' What the health check shows beside its rows: completeness, the columns
#' that miss most, interviews per day and records per area
#' @return list(records, variables, completeness, dup_share, missing
#'   (data.frame var, pct), daily (data.frame day, n) or NULL, areas
#'   (data.frame area, n) or NULL, area_level)
#' @noRd
dq_health_overview <- function(df, setup) {
  col <- function(k) { cl <- setup[[k]]; if (length(cl) == 1 && !is.na(cl) && nzchar(cl) && cl %in% names(df)) cl else NULL }
  n <- nrow(df)
  miss <- vapply(df, function(v) { if (!n) return(0); m <- is.na(v); if (is.character(v)) m <- m | !nzchar(trimws(v)) | v == "NULL"; mean(m) }, numeric(1))
  top <- utils::head(sort(miss[miss > 0], decreasing = TRUE), 12)
  id <- col("unique_id")
  dup <- if (is.null(id)) NA_real_ else { v <- df[[id]]; mean(!is.na(v) & (duplicated(v) | duplicated(v, fromLast = TRUE))) }
  daily <- NULL
  dc <- col("date")
  if (!is.null(dc)) {
    d <- suppressWarnings(as.Date(df[[dc]]))
    if (any(!is.na(d))) { tb <- table(d[!is.na(d)]); daily <- data.frame(day = names(tb), n = as.integer(tb), stringsAsFactors = FALSE) }
  }
  areas <- NULL; lvl <- ""
  for (k in c("admin1", "admin2")) {
    a <- col(k)
    if (!is.null(a)) {
      tb <- sort(table(as.character(df[[a]]), useNA = "no"), decreasing = TRUE)
      areas <- data.frame(area = utils::head(names(tb), 15), n = utils::head(as.integer(tb), 15), stringsAsFactors = FALSE)
      lvl <- a; break
    }
  }
  list(records = n, variables = ncol(df), completeness = if (length(miss)) 1 - mean(miss) else 1, dup_share = dup,
       missing = data.frame(var = names(top), pct = round(100 * unname(top), 1), stringsAsFactors = FALSE),
       daily = daily, areas = areas, area_level = lvl)
}

#' One insight card of a Data Quality tab, as data for the React page
#'
#' @param icon A name the page maps to an icon (react/src/pages/dq/Insights.tsx).
#' @param pick Optional action: list(what, value, label), sent back as input$ol_pick.
#' @noRd
dq_insight <- function(icon, label, value = NULL, sub = NULL, pick = NULL) {
  list(icon = icon, label = label, value = if (is.null(value)) NULL else as.character(value), sub = sub, pick = pick)
}
