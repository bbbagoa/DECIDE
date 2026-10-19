#' The selection logic: what decided who was eligible in Beneficiary Selection
#' (approach, the card with the threshold applied, the eligibility rules, the
#' community column), written as a .json file that Monitoring re-applies to
#' the survey answers. The Design card alone is not enough: Selection may
#' change its threshold and add rules.
#' @noRd
SELECTION_LOGIC_FORMAT <- "DECIDE selection logic"

#' Build the logic from Selection's applied settings
#'
#' @param applied Selection's applied settings (a list).
#' @param scorecard The card loaded in Selection (or NULL).
#' @param ruleset The eligibility rules (or NULL).
#' @param settings The setup mapping (rules keyed on a mapped field are
#'   written with the column they pointed at).
#' @param cols The registration data's column names.
#' @noRd
selection_logic <- function(applied, scorecard, ruleset, settings, cols) {
  ap <- applied$approach %||% "hybrid"
  sc <- NULL
  if (isTRUE(applied$use_scorecard %||% TRUE) && !scorecard_is_empty(scorecard)) {
    sc <- scorecard
    sc$threshold <- applied$sc_threshold %||% sc$threshold %||% 0
  }
  rs <- NULL
  if (!is.null(ruleset) && !ruleset_is_empty(ruleset)) {
    rs <- ruleset
    rs$groups <- lapply(rs$groups, function(g) {
      g$rules <- lapply(g$rules, function(r) {
        col <- rule_column(r, settings, cols)
        r$col <- if (is.na(col)) r$col else col
        r$key <- NA_character_
        r
      })
      g
    })
  }
  vs <- settings$v_score
  comm <- applied$comm_col
  list(
    format = SELECTION_LOGIC_FORMAT, version = 1L,
    created = format(Sys.time(), "%Y-%m-%d %H:%M"),
    country_office = as.character(settings$country_office %||% "")[1],
    approach = ap, approach_label = targeting_approaches()[[ap]]$label %||% ap,
    combine = applied$combine %||% "both",
    scorecard = sc,
    score = if (is.null(sc) && shiny::isTruthy(vs)) list(column = vs, min = applied$score_min, max = applied$score_max),
    rules = rs,
    community = if (shiny::isTruthy(comm)) list(column = comm, values = as.character(applied$comm_vals %||% character(0))),
    # for the record only: a survey cannot rank the whole population again
    prioritisation = list(mode = applied$prio_mode %||% "none", n = applied$prio_n, count = applied$prio_count),
    areas = tryCatch(areas_covered_text(applied), error = function(e) "")
  )
}

#' Write / read the logic file (.json)
#' @noRd
write_selection_logic <- function(logic, file) {
  writeLines(as.character(jsonlite::toJSON(logic, auto_unbox = TRUE, digits = NA, null = "null", pretty = TRUE)), file, useBytes = TRUE)
}

#' @noRd
read_selection_logic <- function(path) {
  x <- tryCatch(jsonlite::fromJSON(paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n"),
                                   simplifyVector = TRUE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE),
                error = function(e) NULL)
  if (!is.list(x) || !identical(x$format, SELECTION_LOGIC_FORMAT))
    stop("This is not a selection logic file: download it from Beneficiary Selection (Outputs, 'Selection logic').", call. = FALSE)
  if (!is.null(x$scorecard)) x$scorecard <- normalise_scorecard(x$scorecard)
  if (!is.null(x$rules)) x$rules <- normalise_ruleset(x$rules)
  x
}

#' A survey column by its name, then the same name in other case or
#' punctuation, or under a form's group path (NA when absent)
#' @noRd
survey_column <- function(df, name) {
  if (is.null(name) || !length(name) || is.na(name[1]) || !nzchar(name[1])) return(NA_character_)
  name <- name[1]
  if (name %in% names(df)) return(name)
  norm <- normalise_colname(sub(".*[/]", "", names(df)))
  hit <- names(df)[norm == normalise_colname(name)]
  if (length(hit)) hit[1] else NA_character_
}

#' Apply the selection logic to survey answers
#'
#' @return list(eligible, score, missing (what the data lack; nothing is
#'   computed then), note)
#' @noRd
logic_eligibility <- function(df, logic) {
  ap <- logic$approach %||% "hybrid"
  spec <- targeting_approaches()[[ap]]
  if (is.null(spec)) stop("Unknown targeting approach in the selection logic: ", ap, call. = FALSE)
  if (isFALSE(spec$list)) stop("Self-targeting produces no household list: take eligibility from a column.", call. = FALSE)
  missing <- character(0)
  sc <- logic$scorecard
  if (!scorecard_is_empty(sc)) {
    r <- card_resolve(df, sc); sc <- r$scorecard; missing <- c(missing, r$missing)
  }
  rs <- logic$rules
  if (!is.null(rs) && !ruleset_is_empty(rs)) {
    rs$groups <- lapply(rs$groups, function(g) {
      g$rules <- lapply(g$rules, function(r) {
        col <- survey_column(df, r$col)
        if (is.na(col)) missing <<- c(missing, r$col %||% "(unnamed rule)") else r$col <- col
        r$key <- NA_character_
        r
      })
      g
    })
  }
  vs <- if (!is.null(logic$score)) survey_column(df, logic$score$column)
  if (!is.null(logic$score) && is.na(vs)) missing <- c(missing, logic$score$column)
  comm <- logic$community
  if (!is.null(comm)) {
    cc <- survey_column(df, comm$column)
    if (is.na(cc)) missing <- c(missing, comm$column) else comm$column <- cc
  }
  missing <- unique(missing)
  if (length(missing)) return(list(eligible = NULL, score = NULL, missing = missing))
  s <- select_households(df, list(v_score = if (!is.null(vs)) vs), approach = ap, ruleset = rs, scorecard = sc,
                         score_range = c(logic$score$min %||% -Inf, logic$score$max %||% Inf),
                         combine = logic$combine %||% "both",
                         community = list(column = comm$column, values = unlist(comm$values)))
  list(eligible = s$eligible, score = s$score, missing = character(0))
}

#' What the logic says, in one sentence (Monitoring's note)
#' @noRd
logic_describe <- function(logic) {
  parts <- c(
    if (!scorecard_is_empty(logic$scorecard))
      sprintf("a %s of %d criteria, eligible when score > %s", card_word(logic$scorecard), length(logic$scorecard$items),
              fmt5(logic$scorecard$threshold %||% 0)),
    if (!is.null(logic$score)) sprintf("score column %s from %s to %s", logic$score$column, fmt5(logic$score$min), fmt5(logic$score$max)),
    if (!is.null(logic$rules) && !ruleset_is_empty(logic$rules))
      sprintf("%d eligibility rule(s)", sum(vapply(logic$rules$groups, function(g) length(g$rules), integer(1)))),
    if (!is.null(logic$community)) sprintf("community decision in %s", logic$community$column))
  sprintf("%s: %s (saved %s).", logic$approach_label %||% logic$approach,
          if (length(parts)) paste(parts, collapse = "; ") else "every household", logic$created %||% "")
}
