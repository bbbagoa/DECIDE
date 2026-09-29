#' Targeting scorecard construction
#'
#' Builds a weighted eligibility scorecard from needs-assessment data, the way
#' the APP-FA targeting analysis does it: binarised socio-economic criteria are
#' screened against a binary food-security outcome, a multivariable logistic
#' regression is fitted, and each retained criterion is given a weight equal to
#' its odds ratio. A household's score is the sum of its inclusion weights minus
#' the sum of its exclusion weights, floored at zero.
#'
#' Three corporate advisories shape what this is allowed to do:
#'
#' * Issue 1/2025 -- outcome indicators (FCS, rCSI, LCSI, CARI, HHS ...) measure
#'   the symptom of food insecurity, not the household's intrinsic
#'   vulnerability. They are the *outcome* the scorecard predicts and must never
#'   become criteria themselves. `outcome_like_columns()` enforces that.
#' * Issue 2/2025 -- design errors are computed from the eligibility x
#'   vulnerability table, and COs set a lower/upper tolerance band (typically
#'   5-20%, and an upper bound can never reach 50% or targeting is no better
#'   than random). `design_errors()` and `error_verdict()`.
#' * Issue 3/2025 -- the eligibility threshold is a programmatic decision, so
#'   the whole trade-off curve is shown rather than one number. `roc_curve()`.
#'
#' Only `stats::glm` is used. The reference script also fits XGBoost, random
#' forest and elastic net, but those inform variable selection and model
#' comparison; the scorecard itself is built from the logistic coefficients.
#' Keeping it to base R means no new dependency and a model a targeting officer
#' can read off the table.
#'
#' @name scorecard
NULL

# ---------------------------------------------------------------------------
# Outcome-indicator guard (Advisory Issue 1/2025)
# ---------------------------------------------------------------------------

#' Patterns that identify a food-security outcome indicator
#'
#' Matched against column names case-insensitively. Deliberately broad: a false
#' positive costs the user one click to override, a false negative puts the
#' symptom being predicted back in as a predictor.
#' @noRd
# Short acronyms, matched only when not glued to another word. Unbounded,
# "hhs" matches HHSize -- household size, one of the most common columns in a
# WFP dataset and a perfectly good criterion.
OUTCOME_ACRONYMS <- c("fcs", "rcsi", "csi", "lcsi", "lcsfs", "cari", "fsi",
                      "hhs", "hdds", "mahfp", "fes")

# Phrases, which are specific enough to match anywhere in the name.
OUTCOME_PHRASES <- c("food_?consumption", "livelihood_?coping", "coping_?strateg",
                     "food_?security_?(index|class|status|score)", "food_?insecur",
                     "hunger_?scale", "diet(ary)?_?diversity",
                     "food_?expenditure_?share", "ipc_?phase",
                     "meals_?per_?day", "meal_?freq")

OUTCOME_PATTERNS <- c(
  paste0("(?<![a-zA-Z])", OUTCOME_ACRONYMS, "(?![a-zA-Z])"),
  OUTCOME_PHRASES
)

#' Variables a registration team cannot observe or verify
#'
#' Not criteria, whatever their association with vulnerability: expenditure,
#' prices, coping strategies and their reasons, the minimum expenditure basket
#' and transfer values, food consumption, phone numbers, indebtedness. Matched
#' on column names, case-insensitively; each group gives the reason shown.
#' @noRd
UNOBSERVABLE_PATTERNS <- list(
  "expenditure" = "expend|hh_?exp|(?<![a-z])exp_|d[\u00e9e]pense|spend|(?<![a-z])cost|(?<![a-z])co[\u00fbu]t",
  "prices" = "price|(?<![a-z])prix",
  # coping strategies, and the reasons given for them (a displacement reason
  # is observable; a reason for using a coping strategy is not)
  "coping strategies" = paste0("coping|strat[\u00e9e]g|(?<![a-z])(lcs|lhcs|rcsi|csi)",
                               "|(lcs|coping|strat|csi)[a-z0-9_]*(reason|raison|motif)|(reason|raison|motif)[a-z0-9_]*(lcs|coping|strat)"),
  "the minimum expenditure basket or transfer values" = "(?<![a-z])s?meb(?![a-z])|(?<![a-z])ubt(?![a-z])|transfer_?value",
  "food consumption" = "^(fcs|hdds|fcg|fies|hwise)|food_?cons|consommation",
  "phone numbers" = "phone|t[\u00e9e]l[\u00e9e]phone|(?<![a-z])tel(_?(num|no|number)|(?![a-z]))|(?<![a-z])mobile_?(no|num|number)|portable|msisdn|num[\u00e9e]ro_?tel",
  "indebtedness" = "debt|dette|endett"
)

#' Why a column cannot be observed at registration, or NA
#' @noRd
unobservable_reason <- function(cols) {
  vapply(cols, function(cl) {
    for (g in names(UNOBSERVABLE_PATTERNS)) if (grepl(UNOBSERVABLE_PATTERNS[[g]], cl, ignore.case = TRUE, perl = TRUE)) return(g)
    NA_character_
  }, character(1), USE.NAMES = FALSE)
}

#' Outcome indicators ranked by how likely they are to BE the outcome
#'
#' CARI is the standard WFP vulnerability classification and is what a country
#' office normally predicts, so it is offered first; a two-level version of it
#' is offered before a four-level one, since the scorecard needs a binary
#' outcome. Everything else follows in rough order of how often it is the thing
#' being modelled.
#' @noRd
OUTCOME_PREFERENCE <- c("cari", "fsi", "food_?security", "food_?insecur",
                        "ipc", "fcs", "hhs", "rcsi", "lcsi")

#' Order candidate outcome columns, best guess first
#'
#' @param cols Outcome-like column names (already filtered).
#' @param df Optional data, used to prefer columns that are already binary.
#' @noRd
rank_outcome_candidates <- function(cols, df = NULL) {
  if (length(cols) == 0) return(cols)
  rank_of <- function(cl) {
    for (i in seq_along(OUTCOME_PREFERENCE)) {
      if (grepl(OUTCOME_PREFERENCE[i], cl, ignore.case = TRUE, perl = TRUE)) return(i)
    }
    length(OUTCOME_PREFERENCE) + 1L
  }
  r <- vapply(cols, rank_of, integer(1))
  # A column that is already binary can be used as-is; one that is not would
  # have to be recoded first, so it sorts after.
  binary <- if (is.null(df)) rep(TRUE, length(cols)) else
    vapply(cols, function(cl) !is.null(as_binary_criterion(df[[cl]])), logical(1))
  cols[order(r, !binary, nchar(cols))]
}

#' Which of these columns look like outcome indicators
#'
#' @param cols Character vector of column names.
#' @return The subset that matches an outcome pattern.
#' @noRd
outcome_like_columns <- function(cols) {
  if (length(cols) == 0) return(character(0))
  pat <- paste0("(", paste(OUTCOME_PATTERNS, collapse = "|"), ")")
  cols[grepl(pat, cols, ignore.case = TRUE, perl = TRUE)]
}

#' Reasons a column cannot be used as an eligibility criterion
#'
#' Returns a short human sentence per rejected column, so the UI can say why
#' rather than silently dropping it.
#'
#' @param df The assessment data.
#' @param cols Candidate criterion columns.
#' @param outcome The outcome column name.
#' @return A named character vector: names are columns, values are reasons.
#'   Columns that are fine do not appear.
#' @noRd
criterion_blockers <- function(df, cols, outcome, strict = TRUE) {
  out <- character(0)
  for (cl in cols) {
    if (identical(cl, outcome)) {
      out[[cl]] <- "This is the outcome the scorecard predicts."
      next
    }
    # names and identification variables are never criteria
    if (is_identification_col(cl)) {
      out[[cl]] <- "A name or identification variable: it identifies a household, it does not describe it."
      next
    }
    # Without an outcome (strict = FALSE) outcome indicators and what a
    # registration team cannot observe may rank households: after a shock
    # they are often the best signal there is.
    if (strict && cl %in% outcome_like_columns(cl)) {
      out[[cl]] <- paste(
        "Looks like a food-security outcome indicator. Outcome indicators",
        "measure the symptom of food insecurity, not intrinsic vulnerability,",
        "and corporate guidance (Targeting Advisory 1/2025) rules them out as",
        "eligibility criteria."
      )
      next
    }
    why <- if (strict) unobservable_reason(cl) else NA_character_
    if (!is.na(why)) {
      out[[cl]] <- sprintf(paste("Not observable at registration (%s): a registration team cannot see or verify it,",
                                 "so it is not a criterion, whatever its link with vulnerability."), why)
      next
    }
    x <- df[[cl]]
    if (is.null(x)) {
      out[[cl]] <- "Column not found in the data."
      next
    }
    b <- as_binary_criterion(x)
    if (is.null(b)) {
      u <- unique(x[!is.na(x)])
      out[[cl]] <- if (length(u) < 2) {
        "Constant: every household has the same value."
      } else {
        "Not binary. Criteria must be yes/no; binarise it first."
      }
      next
    }
    ok <- !is.na(b)
    if (!any(ok) || length(unique(b[ok])) < 2) {
      out[[cl]] <- "Constant: every household has the same value."
    }
  }
  out
}

# ---------------------------------------------------------------------------
# Coercion
# ---------------------------------------------------------------------------

#' Which of two levels means "the bad one"
#'
#' Getting this backwards silently inverts the entire scorecard: every
#' inclusion criterion becomes an exclusion criterion and the score ranks the
#' least vulnerable first. Sorting alphabetically is not safe -- "Food
#' insecure" sorts before "Food secure" -- so the level is chosen by meaning,
#' and the positive hints are checked first because "insecure" contains
#' "secure".
#'
#' @param levels Exactly two distinct level labels.
#' @return The level that means vulnerable / yes / the condition is present.
#' @noRd
POSITIVE_HINTS <- c("insecur", "ins\u00e9cur", "vulnerab", "vuln\u00e9rab", "severe",
                    "s\u00e9v\u00e8re", "poor", "pauvre", "crisis", "deficit", "d\u00e9ficit",
                    "yes", "oui", "s\u00ed", "true", "eligible", "\u00e9ligible", "present")
NEGATIVE_HINTS <- c("secur", "s\u00e9cur", "acceptable", "not vulnerab", "non vulnerab",
                    "^no$", "^non$", "false", "absent", "none", "aucun")

guess_positive_level <- function(levels) {
  if (length(levels) != 2) return(NA_character_)
  hit <- function(x, pats) any(vapply(pats, function(p)
    grepl(p, x, ignore.case = TRUE, perl = TRUE), logical(1)))

  pos <- vapply(levels, hit, logical(1), pats = POSITIVE_HINTS)
  if (sum(pos) == 1) return(levels[pos])

  neg <- vapply(levels, hit, logical(1), pats = NEGATIVE_HINTS)
  if (sum(neg) == 1) return(levels[!neg])

  # Nothing recognisable: deterministic, and the UI always offers an override.
  levels[2]
}

#' Coerce a column to a 0/1 criterion, or NULL when it is not binary
#'
#' Accepts 0/1, TRUE/FALSE, and two-level categoricals including the Yes/No
#' coding the reference analysis uses. The "positive" level is Yes/True/1 where
#' recognisable, otherwise the second sorted level, so the direction is at
#' least deterministic.
#' @noRd
as_binary_criterion <- function(x) {
  if (inherits(x, "haven_labelled")) x <- haven::as_factor(x)
  if (is.logical(x)) return(as.integer(x))
  if (is.numeric(x)) {
    u <- unique(x[!is.na(x)])
    if (length(u) <= 2 && all(u %in% c(0, 1))) return(as.integer(x))
    return(NULL)
  }
  v <- as.character(x)
  v[!is.na(v) & trimws(v) == ""] <- NA
  u <- sort(unique(v[!is.na(v)]))
  if (length(u) != 2) return(NULL)
  as.integer(v == guess_positive_level(u))
}

#' Coerce the outcome to 0/1, where 1 means "vulnerable / food insecure"
#'
#' @param x The outcome column.
#' @param positive Optional label to treat as 1. When omitted, the same rules
#'   as `as_binary_criterion()` apply.
#' @noRd
as_binary_outcome <- function(x, positive = NULL) {
  if (inherits(x, "haven_labelled")) x <- haven::as_factor(x)
  if (!is.null(positive) && length(positive) == 1 && !is.na(positive) && nzchar(positive)) {
    v <- as.character(x)
    out <- as.integer(v == positive)
    out[is.na(v) | trimws(v) == ""] <- NA
    return(out)
  }
  as_binary_criterion(x)
}

#' Distinct values of a column, for choosing which level means "vulnerable"
#' @noRd
outcome_levels <- function(x) {
  if (inherits(x, "haven_labelled")) x <- haven::as_factor(x)
  v <- as.character(x)
  v <- v[!is.na(v) & nzchar(trimws(v))]
  sort(unique(v))
}

# ---------------------------------------------------------------------------
# Step 1: univariate screening
# ---------------------------------------------------------------------------

#' Screen each candidate criterion against the outcome
#'
#' One logistic regression per criterion, compared to the intercept-only model
#' with a likelihood-ratio test, falling back to Fisher's exact test on the 2x2
#' table when the GLM cannot be fitted (complete separation, tiny cells). Zero
#' cells get a Haldane-Anscombe 0.5 correction so the odds ratio stays finite.
#'
#' p-values are adjusted across criteria -- screening 80 candidates at
#' alpha = 0.05 would otherwise be expected to hand back four significant
#' variables that are pure noise.
#'
#' @param df Assessment data.
#' @param outcome Name of the binary outcome column (1 = vulnerable).
#' @param criteria Candidate criterion columns.
#' @param alpha Significance level applied to the adjusted p-value.
#' @param adjust Method for `stats::p.adjust` ("BH" by default).
#' @return A data frame ordered by adjusted p-value, with `direction`
#'   ("inclusion" when OR > 1, "exclusion" when OR < 1).
#' @noRd
screen_criteria <- function(df, outcome, criteria, alpha = 0.05, adjust = "BH",
                            outcome_positive = NULL) {
  y <- as_binary_outcome(df[[outcome]], outcome_positive)
  if (is.null(y)) stop("The outcome must be binary (two levels).", call. = FALSE)

  rows <- lapply(criteria, function(cl) {
    base <- data.frame(
      criterion = cl, n = 0L, n_yes = 0L, prevalence = NA_real_,
      test = NA_character_, p_value = NA_real_, p_adj = NA_real_,
      or = NA_real_, or_low = NA_real_, or_high = NA_real_,
      stringsAsFactors = FALSE
    )
    x <- as_binary_criterion(df[[cl]])
    if (is.null(x)) {
      # NULL means "not two levels": either constant, or not a criterion at all.
      u <- unique(df[[cl]][!is.na(df[[cl]])])
      base$test <- if (length(u) < 2) "constant" else "not binary"
      return(base)
    }

    keep <- !is.na(x) & !is.na(y)
    xx <- x[keep]; yy <- y[keep]
    base$n <- length(xx)
    base$n_yes <- sum(xx)
    base$prevalence <- if (length(xx)) mean(xx) else NA_real_
    if (length(xx) == 0 || length(unique(xx)) < 2 || length(unique(yy)) < 2) {
      base$test <- "constant"
      return(base)
    }

    # two yes/no columns: four answer patterns, whatever the number of households
    d <- collapse_rows(data.frame(y = yy, x = xx), c("y", "x"))
    m1 <- tryCatch(stats::glm(y ~ x, data = d, family = stats::binomial(), weights = .n),
                   error = function(e) NULL, warning = function(w) NULL)
    if (!is.null(m1)) {
      m0 <- stats::glm(y ~ 1, data = d, family = stats::binomial(), weights = .n)
      a <- tryCatch(stats::anova(m0, m1, test = "Chisq"), error = function(e) NULL)
      cf <- summary(m1)$coefficients
      if (!is.null(a) && nrow(cf) >= 2 && is.finite(a$`Pr(>Chi)`[2])) {
        beta <- cf[2, 1]; se <- cf[2, 2]
        base$test <- "LR"
        base$p_value <- a$`Pr(>Chi)`[2]
        base$or <- exp(beta)
        base$or_low <- exp(beta - 1.96 * se)
        base$or_high <- exp(beta + 1.96 * se)
        return(base)
      }
    }

    # Fisher fallback on the 2x2 table.
    tab <- table(factor(yy, levels = c(0, 1)), factor(xx, levels = c(0, 1)))
    if (all(dim(tab) == c(2, 2))) {
      ft <- tryCatch(stats::fisher.test(tab), error = function(e) NULL)
      cells <- as.numeric(tab)
      if (any(cells == 0)) cells <- cells + 0.5   # Haldane-Anscombe
      # tab is [y, x]: a = y0x0, b = y1x0, c = y0x1, d = y1x1
      a_ <- cells[1]; b_ <- cells[2]; c_ <- cells[3]; d_ <- cells[4]
      or <- (a_ * d_) / (b_ * c_)
      se <- sqrt(1 / a_ + 1 / b_ + 1 / c_ + 1 / d_)
      base$test <- "Fisher"
      base$p_value <- if (is.null(ft)) NA_real_ else unname(ft$p.value)
      base$or <- or
      base$or_low <- exp(log(or) - 1.96 * se)
      base$or_high <- exp(log(or) + 1.96 * se)
    }
    base
  })

  out <- do.call(rbind, rows)
  out$p_adj <- stats::p.adjust(out$p_value, method = adjust)
  out$significant <- !is.na(out$p_adj) & out$p_adj < alpha
  out$direction <- ifelse(is.na(out$or), NA_character_,
                          ifelse(out$or > 1, "inclusion", "exclusion"))
  out <- round5(out[order(out$p_adj, na.last = TRUE), , drop = FALSE])
  # Odds ratios to 4 decimals at most, wherever they are shown or exported.
  for (k in c("or", "or_low", "or_high")) out[[k]] <- round(out[[k]], 4)
  rownames(out) <- NULL
  out
}

# ---------------------------------------------------------------------------
# Step 2: collinearity
# ---------------------------------------------------------------------------

#' Drop criteria that duplicate each other
#'
#' Same idea as `caret::findCorrelation`: while any pair exceeds the cutoff,
#' remove whichever of the two has the larger mean absolute correlation with
#' everything else. Two criteria that say the same thing would otherwise split
#' one effect into two weights and double-count it in the score.
#'
#' @return A list with `keep` and `dropped` (named by the partner that beat it).
#' @noRd
#' Groups of criteria correlated at or above a cut-off
#'
#' Pairs with |r| >= `cutoff` are linked, and linked pairs form a group. The
#' proposal comes from `drop_collinear()`: the members to remove so that no
#' pair above the cut-off remains (one of each pair, the one overlapping most
#' with the others).
#' @return list(pairs = data.frame(group, a, b, r), groups = list of members,
#'   drop = named character: removed -> the variable it repeats)
#' @noRd
correlated_groups <- function(df, criteria, cutoff = 0.8) {
  none <- list(pairs = data.frame(group = integer(0), a = character(0), b = character(0), r = numeric(0),
                                  stringsAsFactors = FALSE),
               groups = list(), drop = character(0))
  if (length(criteria) < 2) return(none)
  cm <- criteria_cor(df, criteria)
  hit <- which(!is.na(cm) & abs(cm) >= cutoff & upper.tri(cm), arr.ind = TRUE)
  if (!nrow(hit)) return(none)
  root <- seq_along(criteria)
  find <- function(i) { while (root[i] != i) i <- root[i]; i }
  for (k in seq_len(nrow(hit))) {
    a <- find(hit[k, 1]); b <- find(hit[k, 2])
    if (a != b) root[b] <- a
  }
  top <- vapply(seq_along(criteria), find, integer(1))
  involved <- sort(unique(c(hit)))
  gid <- match(top, unique(top[involved]))
  pairs <- data.frame(group = gid[hit[, 1]], a = criteria[hit[, 1]], b = criteria[hit[, 2]], r = cm[hit],
                      stringsAsFactors = FALSE)
  pairs <- pairs[order(pairs$group, -abs(pairs$r)), , drop = FALSE]
  rownames(pairs) <- NULL
  groups <- lapply(sort(unique(gid[involved])), function(g) criteria[involved][gid[involved] == g])
  drop <- drop_collinear(df, criteria, cutoff = cutoff)$dropped
  list(pairs = pairs, groups = groups, drop = drop[names(drop) %in% criteria[involved]])
}

drop_collinear <- function(df, criteria, cutoff = 0.8) {
  if (length(criteria) < 2) return(list(keep = criteria, dropped = character(0)))
  m <- vapply(criteria, function(cl) as.numeric(as_binary_criterion(df[[cl]])),
              numeric(nrow(df)))
  m <- as.matrix(m)
  colnames(m) <- criteria
  keep_cols <- apply(m, 2, function(v) length(unique(v[!is.na(v)])) > 1)
  m <- m[, keep_cols, drop = FALSE]
  if (ncol(m) < 2) return(list(keep = colnames(m), dropped = character(0)))

  cm <- suppressWarnings(stats::cor(m, use = "pairwise.complete.obs"))
  cm[is.na(cm)] <- 0
  diag(cm) <- 0
  dropped <- character(0)

  repeat {
    a <- abs(cm)
    if (max(a) <= cutoff) break
    idx <- which(a == max(a), arr.ind = TRUE)[1, ]
    i <- idx[[1]]; j <- idx[[2]]
    mi <- mean(a[i, ]); mj <- mean(a[j, ])
    drop <- if (mi >= mj) i else j
    partner <- if (drop == i) j else i
    dropped[[colnames(cm)[drop]]] <- colnames(cm)[partner]
    cm <- cm[-drop, -drop, drop = FALSE]
    if (ncol(cm) < 2) break
  }

  list(keep = colnames(cm), dropped = dropped)
}

# ---------------------------------------------------------------------------
# Step 3: the multivariable model and the weights
# ---------------------------------------------------------------------------

#' Fit the scorecard model and turn it into weights
#'
#' Weights are the odds ratios, which is what makes the result a scorecard a
#' field officer can apply on paper: each criterion a household meets adds (or
#' subtracts) a fixed number of points.
#'
#' @param df Assessment data.
#' @param outcome Binary outcome column.
#' @param criteria Criterion columns to enter the model together.
#' @return A list with `weights` (data frame: criterion, direction, coefficient,
#'   odds_ratio, weight, p_value), `model`, `n` and `converged`.
#' @noRd
fit_scorecard_model <- function(df, outcome, criteria, outcome_positive = NULL) {
  y <- as_binary_outcome(df[[outcome]], outcome_positive)
  if (is.null(y)) stop("The outcome must be binary (two levels).", call. = FALSE)
  if (length(criteria) == 0) stop("No criteria to model.", call. = FALSE)

  X <- as.data.frame(lapply(criteria, function(cl) as_binary_criterion(df[[cl]])))
  names(X) <- criteria
  # A missing answer counts as "no", as it does in the score (it scores
  # nothing). Keeping only households that answered every criterion left no
  # row at all when criteria were asked to different subgroups.
  filled <- vapply(criteria, function(cl) sum(is.na(X[[cl]]) & !is.na(y)), integer(1))
  for (cl in criteria) X[[cl]][is.na(X[[cl]])] <- 0L
  X$.y <- y
  X <- X[stats::complete.cases(X), , drop = FALSE]
  if (nrow(X) == 0) stop("No household has an answer for the outcome.", call. = FALSE)

  keep <- vapply(criteria, function(cl) length(unique(X[[cl]])) > 1, logical(1))
  criteria <- criteria[keep]
  if (length(criteria) == 0) stop("Every criterion is constant once NAs are removed.", call. = FALSE)

  fml <- stats::reformulate(criteria, response = ".y")
  converged <- TRUE
  # one row per answer pattern, with its count: the same fit, much faster on large data
  Xg <- if (nrow(X) > 2000) collapse_rows(X, c(criteria, ".y")) else transform(X, .n = 1)
  model <- withCallingHandlers(
    stats::glm(fml, data = Xg, family = stats::binomial(), weights = .n),
    warning = function(w) {
      # Separation shows up as "fitted probabilities numerically 0 or 1"; the
      # model still returns, but the caller should be told the weights on the
      # separating criterion are not trustworthy.
      converged <<- FALSE
      invokeRestart("muffleWarning")
    }
  )

  cf <- summary(model)$coefficients
  rows <- rownames(cf)
  rows <- rows[rows != "(Intercept)"]

  weights <- data.frame(
    criterion = rows,
    coefficient = cf[rows, 1],
    odds_ratio = exp(cf[rows, 1]),
    p_value = cf[rows, 4],
    stringsAsFactors = FALSE
  )
  weights$direction <- ifelse(weights$odds_ratio > 1, "inclusion", "exclusion")
  weights$weight <- round(weights$odds_ratio, 2)
  weights <- weights[order(-abs(weights$coefficient)), , drop = FALSE]
  rownames(weights) <- NULL

  model$tw_n <- nrow(X)
  list(weights = weights, model = model, n = nrow(X), filled = filled[filled > 0],
       converged = converged && isTRUE(model$converged))
}

# ---------------------------------------------------------------------------
# Step 4: scoring
# ---------------------------------------------------------------------------

#' An empty scorecard
#' @noRd
scorecard_empty <- function() {
  list(
    outcome = NA_character_,
    outcome_positive = NA_character_,
    threshold = 0,
    items = list()
  )
}

#' Whether a scorecard can score anything
#' @noRd
scorecard_is_empty <- function(sc) {
  is.null(sc) || is.null(sc$items) || length(sc$items) == 0
}

#' What an adoption commits to
#'
#' The outcome, the threshold and every criterion's direction, points and
#' review flags, as one string. An adopted card keeps the fingerprint of the
#' design it came from; when the design no longer matches it, the adoption no
#' longer describes what is on screen and is withdrawn.
#' @noRd
scorecard_fingerprint <- function(sc) {
  if (scorecard_is_empty(sc)) return(NA_character_)
  items <- vapply(sc$items, function(it) sprintf("%s|%s|%s|%d|%d", it$criterion, it$direction,
                                                 fmt5(it$weight), isTRUE(it$verifiable), isTRUE(it$validated)),
                  character(1))
  paste(c(sc$outcome %||% "", sc$outcome_positive %||% "", fmt5(sc$threshold %||% 0), items), collapse = "~")
}

#' Build a scorecard object from fitted weights
#'
#' @param weights The `weights` data frame from `fit_scorecard_model()`, after
#'   any manual edits.
#' @param outcome,outcome_positive Recorded for provenance.
#' @param threshold Score at or above which a household is eligible. The
#'   reference analysis uses "greater than zero"; anything else is a
#'   programmatic decision to be made on the ROC curve.
#' @noRd
build_scorecard <- function(weights, outcome = NA_character_,
                            outcome_positive = NA_character_, threshold = 0, kind = "scorecard", pmt = NULL) {
  items <- lapply(seq_len(nrow(weights)), function(i) {
    list(
      criterion = weights$criterion[i],
      label = weights$label[i] %||% weights$criterion[i],
      direction = weights$direction[i],
      weight = as.numeric(weights$weight[i]),
      # Which column of the dataset being scored carries this criterion. NA
      # means "the criterion name itself", which is the case on the assessment
      # data it was built from.
      column = NA_character_,
      # Targeting Advisory 1/2025: criteria must be observable and verifiable,
      # and validated through community consultation before use. Recorded per
      # criterion so the export shows which ones have not been.
      verifiable = isTRUE(weights$verifiable[i]),
      validated = isTRUE(weights$validated[i]),
      # A PMT's numeric proxies (household size, rooms): points per unit, and
      # the value a missing answer takes (the training mean).
      type = if (identical(weights$type[i], "numeric")) "numeric" else "binary",
      mean = if (identical(weights$type[i], "numeric")) as.numeric(weights$mean[i]) else NA_real_
    )
  })
  # The OGN asks for scorecard weights to be revisited as new assessment
  # data arrives (every 2-3 years in stable contexts, annually in dynamic
  # ones), so the card records when it was designed.
  # kind: "scorecard" (predicts an outcome), "ranking" (no outcome indicator)
  # or "pmt" (predicts welfare; `pmt` holds the intercept and the line)
  list(outcome = outcome, outcome_positive = outcome_positive,
       threshold = as.numeric(threshold), items = items,
       created = format(Sys.Date()), kind = kind, pmt = pmt)
}

#' Months since a scorecard was designed, or NA when not recorded
#' @noRd
scorecard_age_months <- function(sc, today = Sys.Date()) {
  d <- suppressWarnings(as.Date(sc$created %||% NA_character_))
  if (is.na(d)) return(NA_real_)
  as.numeric(today - d) / 30.44
}

#' Score every household
#'
#' Score = sum of the weights of the inclusion criteria the household meets,
#' minus the sum of the weights of the exclusion criteria it meets, floored at
#' zero (a household cannot be less than not-vulnerable).
#'
#' A criterion whose column is missing from `df` contributes nothing and is
#' reported, rather than silently scoring every household as if they failed it.
#'
#' @return A list with `score`, `eligible`, `missing_criteria` and `detail`
#'   (one column per criterion, the points it contributed).
#' @noRd
apply_scorecard <- function(df, scorecard) {
  n <- nrow(df)
  if (scorecard_is_empty(scorecard)) {
    return(list(score = rep(0, n), eligible = rep(FALSE, n),
                missing_criteria = character(0), detail = data.frame()))
  }

  missing <- character(0)
  detail <- list()
  score <- rep(0, n)
  # A vulnerability ranking counts the points of every criterion met in the
  # vulnerable direction: an inclusion criterion met, an exclusion criterion
  # NOT met. It orders households as the unfloored sum and never needs the
  # floor, so a profile defined by what households lack still scores.
  rk <- is_ranking(scorecard)

  for (it in scorecard$items) {
    # A crosswalk (see match_scorecard_columns()) points the criterion at a
    # differently-named column in the registration data.
    cl <- it$column
    if (is.null(cl) || length(cl) != 1 || is.na(cl) || !nzchar(cl)) cl <- it$criterion
    if (!cl %in% names(df)) {
      missing <- c(missing, it$criterion)
      next
    }
    if (identical(it$type, "numeric")) {
      # a PMT's numeric proxy: points per unit, a missing value at the mean
      x <- as_number(df[[cl]])
      x[is.na(x)] <- if (is.finite(it$mean %||% NA_real_)) it$mean else 0
    } else {
      x <- as_binary_criterion(df[[cl]])
      if (is.null(x)) {
        missing <- c(missing, it$criterion)
        next
      }
      x[is.na(x)] <- 0L     # an unmet criterion is not a met criterion
    }
    pts <- x * as.numeric(it$weight)
    if (identical(it$direction, "exclusion")) pts <- if (rk) (1 - x) * as.numeric(it$weight) else -pts
    detail[[cl]] <- pts
    score <- score + pts
  }

  # A PMT score is predicted welfare turned around (100 x (intercept -
  # predicted log welfare)): negative for the better-off, never floored.
  score <- round(if (is_pmt(scorecard)) score else pmax(score, 0), 5)
  list(
    score = score,
    eligible = score > (scorecard$threshold %||% 0),
    missing_criteria = missing,
    detail = if (length(detail)) as.data.frame(detail) else data.frame()
  )
}

# ---------------------------------------------------------------------------
# Step 5: ROC and threshold choice (Advisory Issue 3/2025)
# ---------------------------------------------------------------------------

#' ROC curve and AUC for a continuous score against a binary outcome
#'
#' Computed directly rather than via a package: sort by score, sweep every
#' distinct cut-point, and accumulate true and false positives. AUC comes from
#' the Mann-Whitney statistic, which handles ties exactly.
#'
#' @return A list with `curve` (threshold, tpr, fpr, inclusion_error,
#'   exclusion_error, n_eligible), `auc`, and `youden` (the cut-point maximising
#'   sensitivity + specificity - 1).
#' @noRd
roc_curve <- function(score, outcome) {
  keep <- !is.na(score) & !is.na(outcome)
  s <- as.numeric(score)[keep]
  y <- as.integer(outcome)[keep]
  npos <- sum(y == 1); nneg <- sum(y == 0)
  if (npos == 0 || nneg == 0 || length(s) == 0) {
    return(list(curve = data.frame(), auc = NA_real_, youden = NA_real_))
  }

  # Thresholds are "eligible when score > t", so sweep just below each distinct
  # score plus one point above the maximum (nobody eligible).
  cuts <- sort(unique(s), decreasing = TRUE)
  cuts <- c(cuts, min(s) - 1)
  cuts <- sort(unique(c(cuts, cuts - .Machine$double.eps)), decreasing = TRUE)

  tp <- vapply(cuts, function(t) sum(s > t & y == 1), numeric(1))
  fp <- vapply(cuts, function(t) sum(s > t & y == 0), numeric(1))

  curve <- data.frame(
    threshold = cuts,
    n_eligible = tp + fp,
    tpr = tp / npos,
    fpr = fp / nneg,
    stringsAsFactors = FALSE
  )
  # Design errors, in the advisory's own terms (Issue 2/2025).
  curve$inclusion_error <- ifelse(curve$n_eligible > 0, fp / (tp + fp), NA_real_)
  curve$exclusion_error <- (npos - tp) / npos

  # Mann-Whitney AUC: the probability a random vulnerable household scores
  # above a random non-vulnerable one, with ties counting a half.
  r <- rank(s)
  auc <- (sum(r[y == 1]) - npos * (npos + 1) / 2) / (npos * nneg)

  j <- curve$tpr - curve$fpr
  youden <- curve$threshold[which.max(j)]

  list(curve = curve[order(curve$fpr, curve$tpr), , drop = FALSE],
       auc = auc, youden = youden)
}

# ---------------------------------------------------------------------------
# Step 6: design errors (Advisory Issue 2/2025)
# ---------------------------------------------------------------------------

#' Design inclusion and exclusion errors
#'
#' Using the advisory's contingency table, where rows are eligibility and
#' columns are vulnerability:
#'
#'   inclusion error = not-vulnerable-but-eligible / all eligible
#'   exclusion error = vulnerable-but-not-eligible / all vulnerable
#'
#' @param eligible Logical vector.
#' @param vulnerable Logical or 0/1 vector (the outcome).
#' @noRd
design_errors <- function(eligible, vulnerable) {
  keep <- !is.na(eligible) & !is.na(vulnerable)
  e <- as.logical(eligible)[keep]
  v <- as.logical(vulnerable)[keep]

  a <- sum(e & v)     # correctly included
  b <- sum(!e & v)    # design exclusion error cell
  cc <- sum(e & !v)   # design inclusion error cell
  d <- sum(!e & !v)   # correctly excluded

  list(
    n = length(e),
    correctly_included = a, excluded_in_need = b,
    included_not_in_need = cc, correctly_excluded = d,
    inclusion_error = if ((a + cc) > 0) cc / (a + cc) else NA_real_,
    exclusion_error = if ((a + b) > 0) b / (a + b) else NA_real_,
    coverage = if (length(e) > 0) (a + cc) / length(e) else NA_real_
  )
}

#' Threshold that keeps both design errors as low as possible
#'
#' Picks the cut-point minimising the larger of the two errors (minimax), so
#' neither is traded away for the other; ties go to the smaller sum, then the
#' lower threshold. Minimising the sum instead tends to select almost
#' everyone when most households are vulnerable, which is not a targeting
#' decision. If no cut-point beats selecting everyone, the result says so --
#' a hint that blanket assistance may be the better design (OGN, 2021).
#'
#' @param score Numeric scores; eligible means `score > threshold`.
#' @param vulnerable Logical or 0/1 outcome.
#' @return A list with `threshold`, `inclusion_error`, `exclusion_error`.
#' @noRd
balanced_threshold <- function(score, vulnerable) {
  ok <- !is.na(score) & !is.na(vulnerable)
  s <- score[ok]; v <- as.logical(vulnerable[ok])
  if (!length(s) || !any(v) || all(v)) {
    return(list(threshold = NA_real_, inclusion_error = NA_real_, exclusion_error = NA_real_))
  }
  cand <- sort(unique(c(0, s)))
  sv <- sort(s[v]); sn <- sort(s[!v])
  tp <- length(sv) - findInterval(cand, sv)   # vulnerable with score > t
  fp <- length(sn) - findInterval(cand, sn)
  incl <- ifelse(tp + fp > 0, fp / (tp + fp), NA_real_)
  excl <- (length(sv) - tp) / length(sv)
  worst <- pmax(ifelse(is.na(incl), 1, incl), excl)
  i <- order(worst, ifelse(is.na(incl), 1, incl) + excl, cand)[1]
  list(threshold = cand[i], inclusion_error = incl[i], exclusion_error = excl[i])
}

#' Interpret the error pair against the CO's tolerance band
#'
#' Implements the decision table in Advisory Issue 2/2025. The upper threshold
#' can never reach 50%: at that point the targeting is no better than picking
#' households at random, which the advisory says explicitly.
#'
#' @param lower,upper Tolerance band as proportions (0.05 and 0.20 by default).
#' @return A list with `level` ("good", "review", "redesign"), `interpretation`
#'   and `action`.
#' @noRd
#' The default tolerance band of the design errors, in % (Advisory 2/2025);
#' a design that changes it has to say why.
#' @noRd
TOL_DEFAULT <- c(5, 20)

error_verdict <- function(inclusion_error, exclusion_error, lower = 0.05, upper = 0.20,
                          stage = c("design", "implementation")) {
  stage <- match.arg(stage)
  if (!is.finite(upper) || upper >= 0.5) {
    stop("The upper tolerance must stay below 50%: at 50% targeting is no ",
         "better than random selection.", call. = FALSE)
  }
  if (is.finite(lower) && lower > upper) {
    stop("The lower tolerance cannot be above the upper one.", call. = FALSE)
  }
  if (is.na(inclusion_error) || is.na(exclusion_error)) {
    return(list(level = "unknown",
                interpretation = if (stage == "design")
                  "Not enough data to judge the targeting design."
                else "Not enough data to judge the implementation.",
                action = "Check that the eligibility and the assistance status both apply to these households."))
  }
  if (stage == "implementation") {
    return(implementation_verdict(inclusion_error, exclusion_error, lower, upper))
  }

  band <- function(x) if (x <= lower) 1L else if (x <= upper) 2L else 3L
  i <- band(inclusion_error); e <- band(exclusion_error)

  if (i == 1L && e == 1L) {
    return(list(level = "good",
                interpretation = "The vulnerability framework and eligibility criteria correctly identify the most vulnerable households.",
                action = "The targeting design fits vulnerability patterns and can be implemented."))
  }
  if (e == 3L && i == 1L) {
    return(list(level = "redesign",
                interpretation = "The targeting design is not sensitive enough to the vulnerability of the targeted population.",
                action = "Repeat the targeting design analysis to ensure it fits the vulnerability framework."))
  }
  if (i == 3L && e == 1L) {
    return(list(level = "redesign",
                interpretation = "The targeting design is not sensitive enough to the vulnerability of the targeted population.",
                action = "Repeat the targeting design analysis to ensure it fits the vulnerability framework."))
  }
  if (i == 3L && e == 3L) {
    return(list(level = "redesign",
                interpretation = "The targeting design does not effectively identify the most vulnerable.",
                action = "Fully review the targeting design and vulnerability framework. Potentially re-evaluate the methodology or switch to blanket assistance."))
  }
  if (i == 1L && e == 2L) {
    return(list(level = "review",
                interpretation = "The design fits vulnerability patterns, but the planned caseload may be too small given overall vulnerability.",
                action = "If feasible, reconsider the caseload allocation; otherwise the design is good to move forward."))
  }
  if (i == 2L && e == 1L) {
    return(list(level = "review",
                interpretation = "The design fits vulnerability patterns, but it may include criteria that do not identify the most vulnerable, or the caseload may be too large.",
                action = "If feasible, reconsider the caseload allocation; otherwise the design is good to move forward."))
  }
  if (i == 2L && e == 3L) {
    return(list(level = "redesign",
                interpretation = "The design likely underestimates vulnerability, risking inclusion of less vulnerable households and exclusion of those in need.",
                action = "Reassess the eligibility criteria against the assessment data and validate with community feedback."))
  }
  if (i == 3L && e == 2L) {
    return(list(level = "redesign",
                interpretation = "The targeting design does not match vulnerability trends and may be driven by poorly calibrated criteria.",
                action = "Reassess eligibility thresholds and targeting criteria to ensure alignment with vulnerability data."))
  }
  list(level = "review",
       interpretation = "The design may suffer from incorrect eligibility criteria or a mismatch between overall vulnerability and caseload allocation.",
       action = "If feasible, reconsider the caseload allocation and design; otherwise ensure a thorough community validation process.")
}

# ---------------------------------------------------------------------------
# Step 7: score bands
# ---------------------------------------------------------------------------

#' The implementation-error decision table (Targeting Advisory 2/2025, p. 8)
#'
#' Implementation errors are read differently from design errors: the question
#' is no longer whether the criteria are right but whether they were applied
#' correctly on the ground, so the interpretations point at cooperating
#' partners, list creation and possible manipulation rather than at the model.
#' The wording below follows the advisory's table cell by cell.
#' @noRd
implementation_verdict <- function(inclusion_error, exclusion_error, lower, upper) {
  band <- function(x) if (x <= lower) 1L else if (x <= upper) 2L else 3L
  key <- paste0(band(inclusion_error), band(exclusion_error))

  poorly <- "The targeting process was not effectively implemented, the eligibility criteria may have been poorly understood or inconsistently applied."
  cells <- list(
    "11" = list("good",
      "The implementation process was well done, the eligibility criteria correctly identify the most vulnerable.",
      "No adjustments required."),
    "12" = list("review",
      "The implementation process was well done, but there may have been issues with the application of the eligibility criteria.",
      "Review the PDM data and update the targeting design, review/cross-check internal beneficiary list creation processes."),
    "13" = list("redesign", poorly,
      "Evaluate the ability of CPs to conduct the targeting process or re-evaluate the precision of the eligibility criteria."),
    "21" = list("review",
      "The eligibility criteria correctly identified the most vulnerable, but the process had issues, such as misinterpretation of the criteria or manipulation of the final lists.",
      "Conduct a re-evaluation of the targeting process, re-train the CPs, to reduce the chance of manipulation during the next round."),
    "22" = list("review",
      "The targeting implementation may not have been applied consistently or transparently, leading to a misalignment between intended and actual beneficiary selection.",
      "Review the implementation process for inconsistencies or deviations. Strengthen field-level guidance and re-train CPs to improve application of eligibility criteria."),
    "23" = list("redesign",
      "The targeting process was not effectively implemented, and the eligibility criteria may have been poorly understood or inconsistently applied.",
      "Reassess the eligibility criteria against the assessment data and validate with community feedback."),
    "31" = list("redesign", poorly,
      "A full investigation of the process is required due to risk of potential undue influence. Evaluate the ability of CPs to conduct the targeting process or re-evaluate the precision of the eligibility criteria to correctly identify the most vulnerable."),
    "32" = list("redesign", poorly,
      "Conduct a comprehensive review of the implementation process. Re-train CPs on eligibility criteria and strengthen supervision mechanisms to ensure consistent and accurate application."),
    "33" = list("redesign",
      "The targeting process experienced issues during the implementation.",
      "A full re-evaluation of the targeting implementation and the IDM processes is required.")
  )
  c <- cells[[key]]
  list(level = c[[1]], interpretation = c[[2]], action = c[[3]])
}

#' Quantile bands of the score among scoring households
#'
#' Households scoring zero are excluded, as in the reference analysis: they are
#' not eligible under any threshold, so including them would compress the bands
#' of the households that actually differ.
#'
#' @param n_bands 4 for quartiles, 5 for quintiles.
#' @noRd
score_bands <- function(score, n_bands = 4L) {
  s <- score[!is.na(score) & score > 0]
  if (length(s) < n_bands) return(data.frame())
  qs <- stats::quantile(s, probs = seq(0, 1, length.out = n_bands + 1L), na.rm = TRUE)
  br <- unique(qs)
  if (length(br) < 2) return(data.frame())
  band <- cut(s, breaks = br, include.lowest = TRUE, labels = FALSE)
  data.frame(
    band = seq_along(br[-1]),
    from = round(br[-length(br)], 2),
    to = round(br[-1], 2),
    households = as.integer(table(factor(band, levels = seq_along(br[-1])))),
    stringsAsFactors = FALSE
  )
}

#' Put a parsed scorecard back into its canonical shape
#'
#' Same problem as `normalise_ruleset()`: a scorecard that has crossed JSON
#' comes back with whatever shape the file had, and one that silently fails to
#' parse would score every household zero. Every item is forced into the three
#' fields `apply_scorecard()` needs, and anything without a criterion or a
#' usable weight is dropped rather than contributing nothing in silence.
#' @noRd
normalise_scorecard <- function(sc) {
  if (is.null(sc)) return(NULL)
  items <- sc$items
  if (is.null(items) || length(items) == 0) return(scorecard_empty())

  chr1 <- function(v, default = NA_character_) {
    if (is.null(v) || length(v) == 0) return(default)
    v <- as.character(v)[1]
    if (is.na(v) || !nzchar(v)) default else v
  }
  num1 <- function(v, default = NA_real_) {
    if (is.null(v) || length(v) == 0) return(default)
    v <- suppressWarnings(as.numeric(v)[1])
    if (is.na(v)) default else v
  }

  out <- lapply(items, function(it) {
    dir <- chr1(it$direction, "inclusion")
    list(
      criterion = chr1(it$criterion),
      label = chr1(it$label, chr1(it$criterion)),
      direction = if (identical(dir, "exclusion")) "exclusion" else "inclusion",
      weight = num1(it$weight),
      column = chr1(it$column),
      verifiable = isTRUE(as.logical(it$verifiable)),
      validated = isTRUE(as.logical(it$validated)),
      type = if (identical(chr1(it$type), "numeric")) "numeric" else "binary",
      mean = num1(it$mean)
    )
  })
  out <- Filter(function(it) !is.na(it$criterion) && !is.na(it$weight), out)

  list(
    outcome = chr1(sc$outcome),
    outcome_positive = chr1(sc$outcome_positive),
    threshold = num1(sc$threshold, 0),
    items = out,
    created = chr1(sc$created),
    kind = chr1(sc$kind, "scorecard"),
    pmt = sc$pmt
  )
}

# ---------------------------------------------------------------------------
# Crosswalk: scorecard criteria -> columns in another dataset
# ---------------------------------------------------------------------------

#' Normalise a column name for matching
#'
#' Drops the prefixes the reference analysis uses for engineered criteria
#' (`Targ_`, `HH`), separators and case, so `Targ_HHNoLight`, `targ_hh_nolight`
#' and `NoLight` all reduce to the same key.
#' @noRd
normalise_colname <- function(x) {
  x <- tolower(as.character(x))
  x <- gsub("^targ[_.]?", "", x)
  x <- gsub("[^a-z0-9]", "", x)
  x <- gsub("^hh", "", x)
  x
}

#' Match scorecard criteria to the columns of a dataset
#'
#' A scorecard is designed on assessment data and applied to registration data,
#' and the two rarely use the same column names. This proposes a mapping and
#' says how confident it is, so the user confirms rather than discovers later
#' that half the criteria scored nobody.
#'
#' Four passes, best first: exact, case-insensitive, normalised (see
#' `normalise_colname()`), then approximate string distance. Only binary
#' columns are offered -- a criterion is a yes/no, so a continuous column
#' cannot satisfy it without being derived first.
#'
#' @param scorecard A scorecard.
#' @param df The dataset to apply it to.
#' @param min_similarity Approximate matches below this are not proposed.
#' @return A data frame with one row per criterion: `criterion`, `column`
#'   (NA when nothing was found), `method` and `similarity`.
#' @noRd
match_scorecard_columns <- function(scorecard, df, min_similarity = 0.82) {
  items <- scorecard$items %||% list()
  if (length(items) == 0 || is.null(df) || ncol(df) == 0) {
    return(data.frame(criterion = character(), column = character(),
                      method = character(), similarity = numeric(),
                      stringsAsFactors = FALSE))
  }

  cols <- names(df)
  binary <- vapply(cols, function(cl) !is.null(as_binary_criterion(df[[cl]])), logical(1))
  usable <- cols[binary]

  norm_usable <- normalise_colname(usable)
  lower_usable <- tolower(usable)

  rows <- lapply(items, function(it) {
    crit <- it$criterion
    out <- list(criterion = crit, column = NA_character_,
                method = "none", similarity = 0)

    if (crit %in% usable) {
      out$column <- crit; out$method <- "exact"; out$similarity <- 1
      return(as.data.frame(out, stringsAsFactors = FALSE))
    }
    i <- match(tolower(crit), lower_usable)
    if (!is.na(i)) {
      out$column <- usable[i]; out$method <- "case"; out$similarity <- 1
      return(as.data.frame(out, stringsAsFactors = FALSE))
    }
    i <- match(normalise_colname(crit), norm_usable)
    if (!is.na(i)) {
      out$column <- usable[i]; out$method <- "normalised"; out$similarity <- 0.95
      return(as.data.frame(out, stringsAsFactors = FALSE))
    }

    # Approximate, on the normalised forms so a shared prefix does not
    # dominate the distance.
    target <- normalise_colname(crit)
    if (nzchar(target) && length(norm_usable)) {
      d <- utils::adist(target, norm_usable)[1, ]
      sim <- 1 - d / pmax(nchar(target), nchar(norm_usable), 1)
      j <- which.max(sim)
      if (length(j) == 1 && sim[j] >= min_similarity) {
        out$column <- usable[j]; out$method <- "approximate"
        out$similarity <- round(sim[j], 3)
      }
    }
    as.data.frame(out, stringsAsFactors = FALSE)
  })

  do.call(rbind, rows)
}

#' Point a scorecard's criteria at columns of another dataset
#'
#' Sets each item's `column`, which is what `apply_scorecard()` reads. The
#' criterion name is kept so the card can still be recognised, re-matched
#' against a different dataset, and reported on.
#'
#' @param scorecard A scorecard.
#' @param mapping Named character vector or list: criterion -> column. An
#'   entry that is `NA` or empty unsets the mapping for that criterion.
#' @noRd
apply_scorecard_mapping <- function(scorecard, mapping) {
  if (scorecard_is_empty(scorecard)) return(scorecard)
  mapping <- unlist(mapping)
  scorecard$items <- lapply(scorecard$items, function(it) {
    v <- mapping[[it$criterion]]
    it$column <- if (is.null(v) || is.na(v) || !nzchar(v)) NA_character_ else as.character(v)
    it
  })
  scorecard
}

#' How ready a scorecard is to be applied to a dataset
#'
#' @return A list with `mapped`, `unmapped`, `missing` (mapped to a column the
#'   data does not have) and `ready`.
#' @noRd
scorecard_readiness <- function(scorecard, df) {
  items <- scorecard$items %||% list()
  cols <- if (is.null(df)) character(0) else names(df)
  target <- vapply(items, function(it) {
    v <- it$column
    if (is.null(v) || length(v) != 1 || is.na(v) || !nzchar(v)) it$criterion else v
  }, character(1))
  present <- target %in% cols
  list(
    n = length(items),
    mapped = sum(present),
    unmapped = sum(!present),
    missing = target[!present],
    ready = length(items) > 0 && all(present)
  )
}

# ---------------------------------------------------------------------------
# The scorecard workbook: written to be read back
# ---------------------------------------------------------------------------

# Sheet + header the reader looks for. Changing either breaks round-tripping,
# so they are named once and used by both sides.
SCORECARD_SHEET <- "Scorecard"
SCORECARD_HEADER <- c("Criterion", "Label", "Direction", "Weight", "Registration column",
                      "Verifiable", "Community validated", "Type", "Value if missing")

#' The scorecard as a data frame, in the workbook's own shape
#' @noRd
scorecard_frame <- function(scorecard) {
  items <- scorecard$items %||% list()
  if (length(items) == 0) {
    out <- as.data.frame(matrix(nrow = 0, ncol = length(SCORECARD_HEADER)))
    names(out) <- SCORECARD_HEADER
    return(out)
  }
  chr <- function(f, default = NA_character_) {
    vapply(items, function(it) {
      v <- it[[f]]
      if (is.null(v) || length(v) != 1 || is.na(v)) default else as.character(v)
    }, character(1))
  }
  out <- data.frame(
    chr("criterion"),
    chr("label"),
    chr("direction", "inclusion"),
    vapply(items, function(it) as.numeric(it$weight), numeric(1)),
    chr("column"),
    ifelse(vapply(items, function(it) isTRUE(it$verifiable), logical(1)), "Yes", "No"),
    ifelse(vapply(items, function(it) isTRUE(it$validated), logical(1)), "Yes", "No"),
    ifelse(vapply(items, function(it) identical(it$type, "numeric"), logical(1)), "number", "yes/no"),
    vapply(items, function(it) if (identical(it$type, "numeric")) as.numeric(it$mean %||% NA_real_) else NA_real_, numeric(1)),
    stringsAsFactors = FALSE
  )
  names(out) <- SCORECARD_HEADER
  out
}

#' Write a styled, self-describing scorecard workbook
#'
#' The file is a deliverable and a machine input at once: a country office
#' reads it, and Beneficiary Selection loads it back to score a registration
#' list. It therefore leads with a How-to-read sheet, and the Scorecard sheet
#' keeps a fixed header so `read_scorecard_workbook()` can find it.
#'
#' @param scorecard The scorecard.
#' @param meta Named list of design facts (outcome, threshold, errors, AUC...).
#' @param screening Optional screening table.
#' @param bands Optional list of band tables, named.
#' @param roc Optional ROC curve data frame.
#' @return An `openxlsx` Workbook.
#' @noRd
scorecard_workbook <- function(scorecard, meta = list(), screening = NULL,
                               bands = list(), roc = NULL, comparison = NULL,
                               report_tables = list()) {
  wb <- openxlsx::createWorkbook()

  title <- openxlsx::createStyle(fontSize = 14, textDecoration = "bold",
                                 fontColour = "#0A6EB4")
  head_st <- openxlsx::createStyle(fgFill = "#0A6EB4", fontColour = "#FFFFFF",
                                   textDecoration = "bold", halign = "left",
                                   border = "TopBottom", borderColour = "#07456F")
  lab_st <- openxlsx::createStyle(textDecoration = "bold")
  incl_st <- openxlsx::createStyle(fgFill = "#E8F3EA")
  excl_st <- openxlsx::createStyle(fgFill = "#FDF0D5")
  num2 <- openxlsx::createStyle(numFmt = "0.00")
  wrap <- openxlsx::createStyle(wrapText = TRUE, valign = "top")

  # --- How to read ---------------------------------------------------------
  openxlsx::addWorksheet(wb, "How to read")
  guide <- data.frame(
    Section = c(
      "What this is", "Scorecard", "How a score is built", "Registration column",
      "Design", "Screening", "Bands", "ROC", "Reloading this file"
    ),
    Explanation = c(
      "A targeting scorecard: weighted household criteria that produce an eligibility score. Built on needs-assessment data.",
      "One row per criterion. Weight is the odds ratio from the logistic model, rounded, and may have been adjusted by hand.",
      "Add the weight of every inclusion criterion the household meets, subtract the weight of every exclusion criterion it meets, and floor the result at zero.",
      "Optional. The column in the REGISTRATION data that carries this criterion, when it is named differently there. Leave blank to use the criterion name.",
      "The outcome modelled, the eligibility threshold, and the design errors this card produced on the assessment data.",
      "Every candidate criterion tested, with its odds ratio and adjusted p-value, including the ones that were rejected.",
      "Quartiles and quintiles of the score among households that score above zero.",
      "The full trade-off curve: for each threshold, the recall and the two design errors.",
      "Load this file in Beneficiary Selection to score a registration list. Only the Scorecard sheet is read; its column headers must not be renamed."
    ),
    stringsAsFactors = FALSE
  )
  if (is_ranking(scorecard)) {
    # a vulnerability ranking: no outcome, so no error, screening or ROC
    guide <- data.frame(
      Section = c("What this is", "Scorecard sheet", "How a score is built", "Registration column", "Design",
                  "Validity", "Bands", "Reloading this file", "Measuring the errors"),
      Explanation = c(
        "A vulnerability ranking: household criteria and points that order households when no food-security outcome indicator was available. The threshold is a programmatic decision (caseload, budget).",
        "One row per criterion with its points, from the ranking method (deprivation counting, PCA / MCA index or household profiles).",
        "Add the points of every criterion the household meets in the vulnerable direction: an inclusion criterion it meets, or an exclusion criterion it does NOT meet.",
        "Optional. The column in the REGISTRATION data that carries this criterion, when it is named differently there. Leave blank to use the criterion name.",
        "The method, the anchor criterion, the threshold, and the validity figures that stand in for errors: stability of the selection, internal consistency, profile separation.",
        "Inclusion and exclusion errors are not measured: there was no outcome. Report_tables holds the profiles and the share selected by area when available.",
        "Quartiles and quintiles of the score among households that score above zero.",
        "Load this file in Beneficiary Selection to rank a registration list. Only the Scorecard sheet is read; its column headers must not be renamed.",
        "Apply it to a verification sample or PDM data with a food-security outcome (Monitoring, PDM) to measure the errors and recalibrate the threshold."),
      stringsAsFactors = FALSE)
  }
  if (is_pmt(scorecard)) {
    guide <- data.frame(
      Section = c("What this is", "Scorecard sheet", "How a score is built", "From score to welfare", "Registration column",
                  "Design", "Accuracy", "Reloading this file", "Review"),
      Explanation = c(
        "A proxy means test (PMT): household characteristics a registration team can observe, weighted by a model of welfare (consumption or expenditure per person) estimated on a survey that measured it. A household is eligible when its predicted welfare is below the cut-off.",
        "One row per proxy. Points are 100 x the proxy's coefficient on log welfare per person (one point is about 1% less predicted welfare). Type 'number' proxies score per unit; 'Value if missing' is used when the answer is missing.",
        "Add the points of every inclusion proxy the household has (per unit for numbers), subtract those of every exclusion proxy. The score is not floored at zero.",
        "Predicted welfare per person = exp(PMT intercept - score / 100). The Design sheet gives the intercept, the poverty line and the welfare the threshold stands for.",
        "Optional. The column in the REGISTRATION data that carries this proxy, when it is named differently there. Leave blank to use the proxy name.",
        "The welfare measure, the poverty line, the model, its R-squared in and out of sample, and the threshold.",
        "Leakage (inclusion error: non-poor among the selected), under-coverage (exclusion error: poor not selected), coverage of the poor, targeting accuracy, the targeting differential and the CGH indicator, measured on held-out households. Report_tables holds the error curves by cut-off, selection by welfare decile and the model comparison.",
        "Load this file in Beneficiary Selection to score a registration list. Only the Scorecard sheet and the Design fields Outcome, Eligibility threshold, PMT intercept and Poverty line are read; do not rename their headers.",
        "Re-estimate the PMT when a new welfare survey is available (every 3 to 5 years, sooner after a shock or high inflation), and update the line with prices."),
      stringsAsFactors = FALSE)
    # PMT words in the descriptive fields; the fields read back keep their names
    keep <- c("Outcome", "Vulnerable level", "Eligibility threshold", "Designed on", "PMT intercept", "Poverty line (per person)")
    if (length(meta)) names(meta) <- ifelse(names(meta) %in% keep, names(meta), pmt_wording(names(meta)))
    if (length(report_tables)) names(report_tables) <- pmt_wording(names(report_tables))
  }
  write_data(wb, "How to read", if (is_ranking(scorecard)) "Vulnerability ranking" else if (is_pmt(scorecard)) "Proxy means test (PMT)" else "Targeting scorecard", startRow = 1)
  openxlsx::addStyle(wb, "How to read", title, rows = 1, cols = 1)
  write_data(wb, "How to read", guide, startRow = 3, headerStyle = head_st)
  openxlsx::addStyle(wb, "How to read", lab_st, rows = 4:(3 + nrow(guide)), cols = 1, gridExpand = TRUE)
  openxlsx::addStyle(wb, "How to read", wrap, rows = 4:(3 + nrow(guide)), cols = 2, gridExpand = TRUE)
  openxlsx::setColWidths(wb, "How to read", cols = 1:2, widths = c(24, 110))

  # --- Scorecard -----------------------------------------------------------
  sc_df <- scorecard_frame(scorecard)
  openxlsx::addWorksheet(wb, SCORECARD_SHEET)
  write_data(wb, SCORECARD_SHEET, sc_df, headerStyle = head_st)
  if (nrow(sc_df) > 0) {
    incl <- which(sc_df$Direction == "inclusion") + 1
    excl <- which(sc_df$Direction == "exclusion") + 1
    if (length(incl)) openxlsx::addStyle(wb, SCORECARD_SHEET, incl_st, rows = incl,
                                         cols = 1:ncol(sc_df), gridExpand = TRUE, stack = TRUE)
    if (length(excl)) openxlsx::addStyle(wb, SCORECARD_SHEET, excl_st, rows = excl,
                                         cols = 1:ncol(sc_df), gridExpand = TRUE, stack = TRUE)
    openxlsx::addStyle(wb, SCORECARD_SHEET, num2, rows = 2:(nrow(sc_df) + 1),
                       cols = 4, gridExpand = TRUE, stack = TRUE)
  }
  openxlsx::setColWidths(wb, SCORECARD_SHEET, cols = 1:7, widths = c(34, 34, 14, 10, 28, 12, 20))
  openxlsx::freezePane(wb, SCORECARD_SHEET, firstRow = TRUE)

  # --- Design --------------------------------------------------------------
  openxlsx::addWorksheet(wb, "Design")
  if (length(meta)) {
    md <- data.frame(Field = names(meta),
                     Value = vapply(meta, function(v) paste(as.character(v), collapse = ", "), character(1)),
                     stringsAsFactors = FALSE)
    write_data(wb, "Design", md, headerStyle = head_st)
    openxlsx::addStyle(wb, "Design", lab_st, rows = 2:(nrow(md) + 1), cols = 1, gridExpand = TRUE)
    openxlsx::addStyle(wb, "Design", wrap, rows = 2:(nrow(md) + 1), cols = 2, gridExpand = TRUE)
  }
  openxlsx::setColWidths(wb, "Design", cols = 1:2, widths = c(28, 96))

  if (!is.null(screening) && nrow(screening) > 0) {
    openxlsx::addWorksheet(wb, "Screening")
    write_data(wb, "Screening", sanitize_for_excel(screening), headerStyle = head_st)
    openxlsx::setColWidths(wb, "Screening", cols = 1:ncol(screening), widths = "auto")
    openxlsx::freezePane(wb, "Screening", firstRow = TRUE)
  }

  for (nm in names(bands)) {
    b <- bands[[nm]]
    if (is.null(b) || nrow(b) == 0) next
    openxlsx::addWorksheet(wb, nm)
    write_data(wb, nm, b, headerStyle = head_st)
    openxlsx::setColWidths(wb, nm, cols = 1:ncol(b), widths = "auto")
  }

  if (!is.null(comparison) && nrow(comparison) > 0) {
    openxlsx::addWorksheet(wb, "Model comparison")
    names(comparison) <- c("Model", "Criteria", "AUC (training)", "AUC (held out)")
    write_data(wb, "Model comparison", comparison, headerStyle = head_st)
    openxlsx::setColWidths(wb, "Model comparison", cols = 1:4, widths = c(34, 10, 16, 16))
  }

  if (!is.null(roc) && nrow(roc) > 0) {
    openxlsx::addWorksheet(wb, "ROC")
    write_data(wb, "ROC", roc, headerStyle = head_st)
    openxlsx::setColWidths(wb, "ROC", cols = 1:ncol(roc), widths = "auto")
  }


  # Everything the design report shortens (its charts show the 15 most
  # relevant variables), in full: one titled table after another.
  report_tables <- Filter(function(t) is.data.frame(t) && nrow(t) > 0, report_tables)
  if (length(report_tables)) {
    openxlsx::addWorksheet(wb, "Report_tables")
    openxlsx::writeData(wb, "Report_tables", "Full tables behind the design report charts", startRow = 1)
    openxlsx::addStyle(wb, "Report_tables", title, rows = 1, cols = 1)
    row <- 3
    for (nm in names(report_tables)) {
      t <- round5(report_tables[[nm]])
      openxlsx::writeData(wb, "Report_tables", nm, startRow = row)
      openxlsx::addStyle(wb, "Report_tables", lab_st, rows = row, cols = 1)
      openxlsx::writeData(wb, "Report_tables", t, startRow = row + 1, headerStyle = head_st)
      row <- row + nrow(t) + 4
    }
    openxlsx::setColWidths(wb, "Report_tables", cols = 1:12, widths = c(34, rep(16, 11)))
  }
  wb
}

#' Read a scorecard back out of a workbook
#'
#' Tolerant on purpose: the file is meant to be edited by hand between being
#' written and being loaded, so weights may be retyped and a registration
#' column filled in. What it will not do is guess -- a sheet without the
#' expected headers is rejected rather than half-read.
#'
#' @param path Path to the .xlsx file.
#' @return A scorecard, or throws with a message naming what was wrong.
#' @noRd
read_scorecard_workbook <- function(path) {
  sheets <- tryCatch(openxlsx::getSheetNames(path),
                     error = function(e) stop("Could not open the workbook: ",
                                              conditionMessage(e), call. = FALSE))
  if (!SCORECARD_SHEET %in% sheets) {
    stop("This workbook has no '", SCORECARD_SHEET, "' sheet. Export one from ",
         "the Targeting Design tab first.", call. = FALSE)
  }

  df <- openxlsx::read.xlsx(path, sheet = SCORECARD_SHEET)
  if (is.null(df) || nrow(df) == 0) stop("The Scorecard sheet is empty.", call. = FALSE)

  # openxlsx turns spaces in headers into dots.
  names(df) <- gsub("[.]", " ", names(df))
  need <- c("Criterion", "Direction", "Weight")
  miss <- setdiff(need, names(df))
  if (length(miss)) {
    stop("The Scorecard sheet is missing the column(s): ", paste(miss, collapse = ", "),
         ". Do not rename the headers.", call. = FALSE)
  }

  get <- function(nm) if (nm %in% names(df)) df[[nm]] else rep(NA, nrow(df))
  items <- lapply(seq_len(nrow(df)), function(i) {
    list(
      criterion = as.character(df$Criterion[i]),
      label = as.character(get("Label")[i]),
      direction = if (identical(tolower(as.character(df$Direction[i])), "exclusion"))
        "exclusion" else "inclusion",
      weight = suppressWarnings(as.numeric(df$Weight[i])),
      column = as.character(get("Registration column")[i]),
      verifiable = identical(tolower(as.character(get("Verifiable")[i])), "yes"),
      validated = identical(tolower(as.character(get("Community validated")[i])), "yes"),
      type = if (identical(tolower(as.character(get("Type")[i])), "number")) "numeric" else "binary",
      mean = suppressWarnings(as.numeric(get("Value if missing")[i]))
    )
  })

  sc <- normalise_scorecard(list(items = items, threshold = 0))

  # The design sheet carries the outcome and threshold when it is present.
  if ("Design" %in% sheets) {
    d <- tryCatch(openxlsx::read.xlsx(path, sheet = "Design"), error = function(e) NULL)
    if (!is.null(d) && all(c("Field", "Value") %in% names(d))) {
      pick <- function(f) {
        v <- d$Value[match(f, d$Field)]
        if (length(v) == 1 && !is.na(v)) as.character(v) else NA_character_
      }
      sc$outcome <- pick("Outcome")
      sc$outcome_positive <- pick("Vulnerable level")
      thr <- suppressWarnings(as.numeric(gsub("[^0-9.-]", "", pick("Eligibility threshold"))))
      if (!is.na(thr)) sc$threshold <- thr
      sc$created <- pick("Designed on")
      # a proxy means test: the intercept and the line turn a score back
      # into predicted welfare
      if (isTRUE(grepl("^PMT", sc$outcome %||% ""))) {
        sc$kind <- "pmt"
        sc$pmt <- list(intercept = suppressWarnings(as.numeric(pick("PMT intercept"))),
                       line = suppressWarnings(as.numeric(pick("Poverty line (per person)"))))
      }
    }
  }

  if (length(sc$items) == 0) {
    stop("No usable criteria in the Scorecard sheet: every row needs a ",
         "Criterion and a numeric Weight.", call. = FALSE)
  }
  sc
}

#' Vulnerable households by area
#'
#' @param area Area of each household (any type; missing -> "(missing)").
#' @param y 1 = vulnerable, 0 = not, NA = no outcome (left out).
#' @return data.frame(area, households, vulnerable, share), most vulnerable
#'   first, or NULL when nothing has an outcome.
#' @noRd
vulnerability_by_area <- function(area, y) {
  ok <- !is.na(y)
  if (!any(ok)) return(NULL)
  a <- as.character(area[ok]); a[is.na(a) | !nzchar(trimws(a))] <- "(missing)"
  v <- y[ok] == 1
  n <- tapply(v, a, length); k <- tapply(v, a, sum)
  out <- data.frame(area = names(n), households = as.integer(n), vulnerable = as.integer(k[names(n)]),
                    stringsAsFactors = FALSE)
  out$share <- out$vulnerable / out$households
  out <- out[order(-out$share, -out$households), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' Is this card a vulnerability ranking (built without an outcome indicator)?
#' @noRd
is_ranking <- function(sc) identical(sc$kind, "ranking") ||
  (!is.null(sc$outcome) && isTRUE(grepl("^none", sc$outcome %||% "")))

#' The word for a card: "ranking" or "scorecard"
#' @noRd
card_word <- function(sc) if (is_ranking(sc)) "vulnerability ranking" else "scorecard"

#' A name or identification column (ids, keys, names, phone numbers, form
#' metadata): never a criterion
#' @noRd
is_identification_col <- function(cl) {
  n <- tolower(cl)
  startsWith(n, "_") ||
    grepl("(^|[_. ])(id|uuid|guid|key|instanceid|instance_id|record_id|hh_?id|household_?id|case_?id|unique_?id|ind_?id|nid|cin|national_?id|passport)($|[_. ])", n) ||
    grepl("(^|[_. ])(name|names|nom|noms|prenom|surname|first_?name|last_?name|full_?name|respondent_?name|hhh_?name|head_?name)($|[_. ])", n) ||
    grepl("(^|[_. ])(phone|telephone|tel|mobile|msisdn|gsm|contact_?number|phone_?number)($|[_. ])", n) ||
    grepl("^(instanceid|deviceid|subscriberid|simserial|start|end|today|username|audit)$", n) ||
    grepl("^(formhub|meta)([_./]|$)", n)
}
