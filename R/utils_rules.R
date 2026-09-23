#' Eligibility rules
#'
#' Targeting in the app used to mean "one numeric score between two sliders".
#' Real country-office designs combine categorical, demographic and geographic
#' criteria -- "IDP or returnee households with a score of at least 18", "any
#' household with a disabled member", "female-headed with children under 5".
#'
#' A rule set is held in disjunctive normal form: a household qualifies when it
#' matches **all** conditions in **any** group. Every boolean expression can be
#' written that way, so one level of nesting is enough for any design while
#' staying buildable in a form.
#'
#' Conditions point at a *setup key* (`v_score`, `residency`, ...) rather than a
#' raw column wherever possible, so a rule set travels with a setup profile and
#' survives a column being renamed between rounds.
#'
#' @name rules
NULL

#' Operators a condition can use
#'
#' Labels are what the user picks; the names are stored in the rule set.
#' @noRd
rule_ops <- function() {
  c(
    "is"                = "==",
    "is not"            = "!=",
    "is at least"       = ">=",
    "is more than"      = ">",
    "is at most"        = "<=",
    "is less than"      = "<",
    "is one of"         = "in",
    "is none of"        = "not in",
    "contains"          = "contains",
    "is missing"        = "is missing",
    "is not missing"    = "not missing"
  )
}

#' Operators that take no value
#' @noRd
rule_ops_no_value <- c("is missing", "not missing")

#' Operators that take a list of values
#' @noRd
rule_ops_multi <- c("in", "not in")

#' An empty rule set (one empty group)
#' @noRd
ruleset_empty <- function() {
  list(groups = list(list(rules = list())))
}

#' Whether a rule set would filter anything
#' @noRd
ruleset_is_empty <- function(ruleset) {
  if (is.null(ruleset) || is.null(ruleset$groups)) return(TRUE)
  n <- sum(vapply(ruleset$groups, function(g) length(g$rules %||% list()), integer(1)))
  n == 0L
}

#' Blank-aware missingness
#'
#' Survey exports carry empty strings and literal "NULL" as often as real NAs;
#' treating those as present is how an unanswered question silently qualifies a
#' household.
#' @noRd
is_blank_value <- function(x) {
  if (is.character(x)) return(is.na(x) | trimws(x) == "" | x == "NULL")
  is.na(x)
}

#' Resolve the column a condition refers to
#'
#' @return The column name, or `NA_character_` when it cannot be resolved.
#' @noRd
rule_column <- function(rule, settings, cols) {
  key <- rule$key
  if (!is.null(key) && length(key) == 1 && !is.na(key) && nzchar(key)) {
    mapped <- settings[[key]]
    if (!is.null(mapped) && length(mapped) == 1 && !is.na(mapped) &&
        nzchar(mapped) && mapped %in% cols) {
      return(mapped)
    }
  }
  col <- rule$col
  if (!is.null(col) && length(col) == 1 && !is.na(col) && nzchar(col) && col %in% cols) {
    return(col)
  }
  NA_character_
}

#' Evaluate one condition
#'
#' @return A logical vector with one entry per row. `NA` where the condition
#'   could not be decided for that household; the caller decides what that
#'   means (it never silently counts as a match).
#' @noRd
rule_eval <- function(df, rule, settings) {
  n <- nrow(df)
  col <- rule_column(rule, settings, names(df))
  if (is.na(col)) return(rep(NA, n))

  x <- df[[col]]
  if (inherits(x, "haven_labelled")) x <- haven::as_factor(x)
  op <- rule$op %||% "=="
  val <- rule$value
  if (is.null(val)) val <- character(0)
  val <- as.character(val)
  val <- val[!is.na(val) & nzchar(val)]

  if (op == "is missing")  return(is_blank_value(x))
  if (op == "not missing") return(!is_blank_value(x))

  if (length(val) == 0) return(rep(NA, n))

  if (op %in% rule_ops_multi) {
    hit <- as.character(x) %in% val
    # A blank cannot match a listed value, and must not pass "is none of".
    hit[is_blank_value(x)] <- NA
    return(if (op == "in") hit else !hit)
  }

  if (op == "contains") {
    # grepl() ignores ignore.case when fixed = TRUE, so fold the case by hand
    # rather than dropping fixed (a value like "(" would become a bad regex).
    out <- grepl(tolower(val[1]), tolower(as.character(x)), fixed = TRUE)
    out[is_blank_value(x)] <- NA
    return(out)
  }

  # Numeric comparison when both sides make sense as numbers; otherwise fall
  # back to string equality (so "is"/"is not" work on categories too).
  nv <- suppressWarnings(as.numeric(val[1]))
  nx <- suppressWarnings(as.numeric(as.character(x)))
  if (!is.na(nv) && any(!is.na(nx))) {
    out <- switch(op,
      "==" = nx == nv, "!=" = nx != nv,
      ">"  = nx >  nv, ">=" = nx >= nv,
      "<"  = nx <  nv, "<=" = nx <= nv,
      rep(NA, n)
    )
    return(out)
  }

  sx <- as.character(x)
  out <- switch(op, "==" = sx == val[1], "!=" = sx != val[1], rep(NA, n))
  out[is_blank_value(x)] <- NA
  out
}

#' Evaluate a whole rule set
#'
#' A household qualifies when it matches every condition in at least one group.
#' Undecidable conditions (missing value, unresolvable column) never qualify a
#' household -- in targeting, an unanswered question is not a yes -- but they
#' are counted and reported so the reason is visible.
#'
#' @param df Data frame to evaluate.
#' @param ruleset A rule set (see `ruleset_empty()`).
#' @param settings The setup mapping.
#' @return A list with `mask` (logical, one per row), `n_match`,
#'   `n_undecided` (rows that failed only because something was missing) and
#'   `unresolved` (setup keys / columns no condition could point at).
#' @noRd
ruleset_eval <- function(df, ruleset, settings) {
  n <- nrow(df)
  if (ruleset_is_empty(ruleset)) {
    return(list(mask = rep(TRUE, n), n_match = n, n_undecided = 0L, unresolved = character(0)))
  }

  unresolved <- character(0)
  group_masks <- list()
  group_undecided <- list()

  for (g in ruleset$groups) {
    rules <- g$rules %||% list()
    if (length(rules) == 0) next

    mask <- rep(TRUE, n)
    undecided <- rep(FALSE, n)
    for (r in rules) {
      if (is.na(rule_column(r, settings, names(df)))) {
        unresolved <- c(unresolved, r$key %||% r$col %||% "(unnamed)")
      }
      v <- rule_eval(df, r, settings)
      undecided <- undecided | is.na(v)
      v[is.na(v)] <- FALSE
      mask <- mask & v
    }
    group_masks[[length(group_masks) + 1]] <- mask
    group_undecided[[length(group_undecided) + 1]] <- undecided
  }

  if (length(group_masks) == 0) {
    return(list(mask = rep(TRUE, n), n_match = n, n_undecided = 0L, unresolved = unique(unresolved)))
  }

  mask <- Reduce(`|`, group_masks)
  undecided <- Reduce(`&`, group_undecided)
  list(
    mask = mask,
    n_match = sum(mask),
    n_undecided = sum(undecided & !mask),
    unresolved = unique(unresolved)
  )
}

#' Put a parsed rule set back into its canonical shape
#'
#' `jsonlite` hands back whatever shape the file had; this makes every rule a
#' plain list with the fields the evaluator expects, so a hand-edited or
#' round-tripped profile behaves like one built in the UI.
#' @noRd
normalise_ruleset <- function(ruleset) {
  if (is.null(ruleset)) return(NULL)
  groups <- ruleset$groups
  if (is.null(groups) || length(groups) == 0) return(ruleset_empty())

  chr1 <- function(v, default = NA_character_) {
    if (is.null(v) || length(v) == 0) return(default)
    v <- as.character(v)[1]
    if (is.na(v) || !nzchar(v)) default else v
  }

  out <- lapply(groups, function(g) {
    rules <- g$rules
    if (is.null(rules)) rules <- list()
    list(rules = lapply(rules, function(r) {
      value <- r$value
      value <- if (is.null(value)) character(0) else as.character(unlist(value, use.names = FALSE))
      list(
        key = chr1(r$key),
        col = chr1(r$col),
        op = chr1(r$op, "=="),
        value = value[!is.na(value) & nzchar(value)]
      )
    }))
  })
  list(groups = Filter(function(g) length(g$rules) > 0, out))
}

#' A human-readable rendering of a rule set
#'
#' Goes into the selection report, so the criteria that produced a beneficiary
#' list are recorded alongside it rather than living in someone's head.
#' @noRd
ruleset_describe <- function(ruleset, settings = NULL, labels = NULL) {
  if (ruleset_is_empty(ruleset)) return("No eligibility rules (all households qualify).")

  op_label <- stats::setNames(names(rule_ops()), unname(rule_ops()))

  field_name <- function(r) {
    key <- r$key
    if (!is.null(key) && length(key) == 1 && !is.na(key) && nzchar(key)) {
      lbl <- if (!is.null(labels) && key %in% names(labels)) labels[[key]] else key
      mapped <- if (!is.null(settings)) settings[[key]] else NULL
      if (!is.null(mapped) && length(mapped) == 1 && !is.na(mapped) && nzchar(mapped)) {
        return(paste0(lbl, " (", mapped, ")"))
      }
      return(lbl)
    }
    r$col %||% "(unmapped field)"
  }

  describe_rule <- function(r) {
    op <- r$op %||% "=="
    lbl <- op_label[[op]] %||% op
    if (op %in% rule_ops_no_value) return(paste(field_name(r), lbl))
    paste(field_name(r), lbl, paste(r$value, collapse = ", "))
  }

  groups <- Filter(function(g) length(g$rules %||% list()) > 0, ruleset$groups)
  txt <- vapply(groups, function(g) {
    paste0("(", paste(vapply(g$rules, describe_rule, character(1)), collapse = " AND "), ")")
  }, character(1))

  paste("Eligible if", paste(txt, collapse = " OR "))
}
