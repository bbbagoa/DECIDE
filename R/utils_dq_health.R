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

  # empty, one-letter or placeholder area names (digits are fine: "Site 3")
  areas <- unlist(Filter(Negate(is.null), lapply(c("admin1", "admin2", "admin3", "admin4", "village"), col)))
  out[[4]] <- if (!length(areas)) row("Names and spelling", "Spelling & Integrity", "No area mapped", "na") else {
    bad <- Reduce(`|`, lapply(areas, function(a) { v <- trimws(as.character(df[[a]]))
      is.na(v) | nchar(v) < 2 | tolower(v) %in% c("none", "null", "test", "n/a", "na", "unknown", "---", ".", "-") }))
    b <- sum(bad)
    row("Names and spelling", "Spelling & Integrity",
        if (b) sprintf("%s records with an empty or placeholder area name", num(b)) else "Area names look complete",
        if (b) "review" else "ok")
  }

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

#' One insight card of a Data Quality tab, as data for the React page
#'
#' @param icon A name the page maps to an icon (react/src/pages/dq/Insights.tsx).
#' @param pick Optional action: list(what, value, label), sent back as input$ol_pick.
#' @noRd
dq_insight <- function(icon, label, value = NULL, sub = NULL, pick = NULL) {
  list(icon = icon, label = label, value = if (is.null(value)) NULL else as.character(value), sub = sub, pick = pick)
}
