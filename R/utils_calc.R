#' Variable calculator
#'
#' Builds new columns at import time, on the registration data or the
#' assessment data: yes/no variables from conditions (the binarised criteria a
#' scorecard needs, a two-level outcome from CARI) and numeric variables from
#' formulas (dependency ratio, household-size bands).
#'
#' Formulas are user text evaluated on the server, so they are checked before
#' they run: every name must be a column, and every function must be on a
#' short list of arithmetic, comparison and recoding functions. Anything else
#' -- `system()`, `::`, `$`, assignment -- is refused.
#'
#' @name variable_calculator
NULL

#' Operators offered by the condition builder
#' @noRd
calc_operators <- function() {
  c("equals" = "==", "is not" = "!=", "greater than" = ">", "at least" = ">=",
    "less than" = "<", "at most" = "<=", "is one of" = "in", "is none of" = "not_in",
    "contains" = "contains", "is missing" = "is_missing", "is not missing" = "not_missing")
}

#' Evaluate one condition
#'
#' A household whose value is missing gets NA (unknown), not FALSE, except
#' for the missing / not-missing tests themselves.
#' @noRd
calc_one_condition <- function(x, op, value) {
  if (op == "is_missing") return(is.na(x) | (is.character(x) & trimws(x) == ""))
  if (op == "not_missing") return(!(is.na(x) | (is.character(x) & trimws(x) == "")))
  vals <- trimws(strsplit(as.character(value %||% ""), ",", fixed = TRUE)[[1]])
  num <- is.numeric(x) || inherits(x, "Date")
  if (op %in% c(">", ">=", "<", "<=")) {
    xv <- suppressWarnings(as.numeric(x))
    v <- suppressWarnings(as.numeric(vals[1]))
    if (is.na(v)) stop("'", value, "' is not a number.", call. = FALSE)
    return(switch(op, ">" = xv > v, ">=" = xv >= v, "<" = xv < v, "<=" = xv <= v))
  }
  xs <- if (num) x else trimws(as.character(x))
  cmp <- if (num) suppressWarnings(as.numeric(vals)) else vals
  out <- switch(op,
    "==" = xs == cmp[1],
    "!=" = xs != cmp[1],
    "in" = xs %in% cmp,
    "not_in" = !(xs %in% cmp),
    "contains" = grepl(tolower(vals[1]), tolower(as.character(x)), fixed = TRUE),
    stop("Unknown operator: ", op, call. = FALSE))
  out[is.na(x)] <- NA
  out
}

#' Combine conditions into a yes/no variable
#'
#' @param conditions List of lists with `column`, `op`, `value`.
#' @param combine "all" (AND) or "any" (OR).
#' @param coding "10" for 1/0, "yesno" for "Yes"/"No".
#' @noRd
calc_condition <- function(df, conditions, combine = "all", coding = "10") {
  if (!length(conditions)) stop("Add at least one condition.", call. = FALSE)
  parts <- lapply(conditions, function(cn) {
    if (!shiny::isTruthy(cn$column) || !cn$column %in% names(df)) {
      stop("Choose a column for every condition.", call. = FALSE)
    }
    calc_one_condition(df[[cn$column]], cn$op, cn$value)
  })
  # Three-valued logic: under ALL a known FALSE decides even if another part
  # is unknown; under ANY a known TRUE does.
  res <- Reduce(if (identical(combine, "any")) `|` else `&`, parts)
  if (identical(coding, "yesno")) ifelse(res, "Yes", "No") else as.integer(res)
}

#' Plain-language description of a condition set, for the audit trail
#' @noRd
calc_describe_condition <- function(conditions, combine = "all") {
  lab <- stats::setNames(names(calc_operators()), calc_operators())
  txt <- vapply(conditions, function(cn) {
    if (cn$op %in% c("is_missing", "not_missing")) sprintf("%s %s", cn$column, lab[[cn$op]])
    else sprintf("%s %s %s", cn$column, lab[[cn$op]], cn$value)
  }, character(1))
  paste(txt, collapse = if (identical(combine, "any")) " OR " else " AND ")
}

#' Functions a formula may call
#' @noRd
calc_allowed_functions <- function() {
  c("+", "-", "*", "/", "^", "%%", "%/%", "(",
    "==", "!=", "<", ">", "<=", ">=", "&", "|", "!", "%in%",
    "ifelse", "is.na", "abs", "round", "floor", "ceiling", "sqrt", "log", "log10", "exp",
    "pmin", "pmax", "as.numeric", "as.integer", "as.character", "nchar", "tolower",
    "toupper", "trimws", "c", "cut", "rowSums", "rowMeans", "cbind", "sum", "mean",
    "min", "max", "median", "sd")
}

#' Check a formula's syntax tree against the column names and the allowed
#' functions; returns the parsed expression or stops with a readable message.
#' @noRd
calc_check_formula <- function(expr_text, columns) {
  ex <- tryCatch(parse(text = expr_text, keep.source = FALSE),
                 error = function(e) stop("The formula does not parse: ", conditionMessage(e), call. = FALSE))
  if (length(ex) != 1) stop("Write a single expression.", call. = FALSE)
  ok_fun <- calc_allowed_functions()
  walk <- function(node) {
    if (is.call(node)) {
      fn <- node[[1]]
      if (!is.symbol(fn) || !as.character(fn) %in% ok_fun) {
        stop("Function not allowed in a formula: ", deparse(fn)[1], call. = FALSE)
      }
      args <- as.list(node)[-1]
      # Named arguments (na.rm = TRUE, breaks = ...) are fine; their names are
      # not symbols to look up.
      for (a in args) walk(a)
    } else if (is.symbol(node)) {
      nm <- as.character(node)
      if (nzchar(nm) && !nm %in% c(columns, "TRUE", "FALSE", "T", "F", "NA", "Inf", "NaN")) {
        stop("Unknown column: ", nm, call. = FALSE)
      }
    }
    invisible(TRUE)
  }
  walk(ex[[1]])
  ex[[1]]
}

#' Evaluate a checked formula on the data
#' @noRd
calc_formula <- function(df, expr_text) {
  ex <- calc_check_formula(expr_text, names(df))
  fns <- calc_allowed_functions()
  # stats for median/sd; its namespace reaches base for the rest.
  env <- list2env(mget(fns, envir = asNamespace("stats"), inherits = TRUE), parent = emptyenv())
  env$`TRUE` <- TRUE; env$`FALSE` <- FALSE; env$T <- TRUE; env$F <- FALSE
  out <- eval(ex, envir = df, enclos = env)
  if (is.factor(out)) out <- as.character(out)
  if (length(out) == 1) out <- rep(out, nrow(df))
  if (length(out) != nrow(df)) stop("The formula must give one value per row.", call. = FALSE)
  round5(out)
}

#' A new name must be a usable, unused column name
#' @noRd
calc_check_name <- function(name, columns, replace = FALSE) {
  name <- trimws(name %||% "")
  if (!nzchar(name)) stop("Give the new variable a name.", call. = FALSE)
  if (!identical(make.names(name), name)) {
    stop("Use letters, digits, dots and underscores only, starting with a letter (e.g. ",
         make.names(name), ").", call. = FALSE)
  }
  if (name %in% columns && !isTRUE(replace)) {
    stop("A column called '", name, "' already exists. Tick 'Replace' to overwrite it.", call. = FALSE)
  }
  name
}

#' Functions an R code block may call: the formula list, plus assignment,
#' braces, if/else, indexing and a few text helpers. Nothing that reaches the
#' file system, the network, the environment or other code (no `$`, `::`,
#' `function`, loops, `eval`, `get`, `do.call`...).
#' @noRd
calc_code_functions <- function() {
  c(calc_allowed_functions(), "{", "<-", "=", "if", "[", "[<-", "length", "any", "all", "xor",
    "is.finite", "paste", "paste0", "grepl", "sub", "gsub", "substr", "startsWith", "endsWith", "quantile")
}

#' Check an R code block: several lines, local variables, the last value is
#' the new column. Returns the parsed expressions or stops with a message.
#' @noRd
calc_check_code <- function(code, columns) {
  ex <- tryCatch(parse(text = code, keep.source = FALSE),
                 error = function(e) stop("The code does not parse: ", conditionMessage(e), call. = FALSE))
  if (!length(ex)) stop("Write some code.", call. = FALSE)
  ok_fun <- calc_code_functions()
  known <- c(columns, "TRUE", "FALSE", "T", "F", "NA", "Inf", "NaN")
  walk <- function(node) {
    if (is.call(node)) {
      fn <- node[[1]]
      if (!is.symbol(fn) || !as.character(fn) %in% ok_fun) {
        stop("Function not allowed in code: ", deparse(fn)[1], call. = FALSE)
      }
      if (as.character(fn) %in% c("<-", "=")) {
        lhs <- node[[2]]
        indexed <- is.call(lhs) && identical(lhs[[1]], as.name("[")) && is.symbol(lhs[[2]])
        if (!is.symbol(lhs) && !indexed) stop("Assign to a plain name, e.g. ratio <- a / b.", call. = FALSE)
        walk(node[[3]])
        target <- as.character(if (indexed) lhs[[2]] else lhs)
        if (indexed) {
          if (!target %in% known) stop("Unknown column or variable: ", target, call. = FALSE)
          for (a in as.list(lhs)[-(1:2)]) walk(a)
        }
        known <<- unique(c(known, target))
        return(invisible(TRUE))
      }
      for (a in as.list(node)[-1]) walk(a)
    } else if (is.symbol(node)) {
      nm <- as.character(node)
      if (nzchar(nm) && !nm %in% known) stop("Unknown column or variable: ", nm, call. = FALSE)
    }
    invisible(TRUE)
  }
  for (e in ex) walk(e)
  ex
}

#' Run a checked R code block on the data; the last line's value is the column
#' @noRd
calc_code <- function(df, code) {
  ex <- calc_check_code(code, names(df))
  fns <- calc_code_functions()
  fenv <- list2env(mget(fns, envir = asNamespace("stats"), inherits = TRUE), parent = emptyenv())
  fenv$`TRUE` <- TRUE; fenv$`FALSE` <- FALSE; fenv$T <- TRUE; fenv$F <- FALSE
  # Columns are read from here; the code's own variables land one level up,
  # so an assignment never touches the data.
  work <- new.env(parent = list2env(as.list(df), parent = fenv))
  out <- NULL
  for (e in ex) out <- eval(e, work)
  if (is.factor(out)) out <- as.character(out)
  if (length(out) == 1) out <- rep(out, nrow(df))
  if (length(out) != nrow(df)) stop("The last line must give one value per row.", call. = FALSE)
  round5(out)
}
