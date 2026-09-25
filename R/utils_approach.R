#' Targeting approaches
#'
#' WFP's Targeting and Prioritization Operational Guidance recognises several
#' approaches -- blanket, geographic, categorical (status-based), community-
#' based, proxy means test / scorecard, self-targeting and hybrids of these --
#' with prioritisation layered on top when resources do not cover everyone
#' eligible. The app used to apply every control it had at once; each approach
#' now says which of them it uses, so the list produced matches the design that
#' was approved and the export records which one it was.
#'
#' Selection happens in two stages, as Targeting Advisory 2/2025 requires:
#'
#' 1. **Eligible by design** -- who the approach says qualifies.
#' 2. **Prioritised** -- who is served once a caseload or per-area cap is
#'    applied. Eligible households cut at this stage are *excluded by design*:
#'    they are not targeting errors, must not be counted as exclusion errors,
#'    and are reported separately because they are unmet need.
#'
#' @name approaches
NULL

#' The approaches the app can apply
#'
#' `gates` lists the selection layers the approach uses. `list` is FALSE where
#' the approach does not produce a household list at all.
#' @noRd
targeting_approaches <- function() {
  list(
    hybrid = list(
      label = "Hybrid (criteria + score)",
      gates = c("area", "criteria", "score"),
      description = paste(
        "Combines categorical criteria with a score. 'Both' requires a household",
        "to meet the criteria AND pass the score; 'either' admits households that",
        "meet the criteria OR pass the score (e.g. groups that are always eligible",
        "plus a scorecard for everyone else).")),
    scorecard = list(
      label = "Scorecard / proxy means test",
      gates = c("area", "score"),
      description = paste(
        "Households are ranked by a weighted scorecard built from assessment data",
        "(Targeting Design), or by the mapped vulnerability score, and qualify above",
        "a threshold.")),
    categorical = list(
      label = "Categorical / status-based",
      gates = c("area", "criteria"),
      description = paste(
        "Households qualify by observable characteristics or status (e.g. IDP",
        "households, female-headed households with children under 5), set with the",
        "filters and eligibility rules below.")),
    community = list(
      label = "Community-based",
      gates = c("area", "community"),
      description = paste(
        "The community identifies the households. Select the column that records",
        "the community's decision; the app verifies and documents the list rather",
        "than producing it.")),
    geographic = list(
      label = "Geographic",
      gates = c("area"),
      description = paste(
        "Every household in the areas covered (chosen in the sidebar). Use when vulnerability is",
        "concentrated geographically and household-level criteria add little.")),
    blanket = list(
      label = "Blanket",
      gates = character(0),
      description = paste(
        "Every registered household in the areas covered, with no household criteria. Appropriate",
        "for acute emergencies where needs are near-universal.")),
    self = list(
      label = "Self-targeting",
      gates = character(0),
      list = FALSE,
      description = paste(
        "Assistance is designed so that only those in need take it up (e.g. work",
        "requirements, commodity choice). No household list is produced; the page",
        "shows the registered population for monitoring only."))
  )
}

#' Choices for the approach picker
#' @noRd
targeting_approach_choices <- function() {
  a <- targeting_approaches()
  stats::setNames(names(a), vapply(a, function(x) x$label, character(1)))
}

#' conditionalPanel condition: the approach picker is one of `approaches`
#' @noRd
approach_js <- function(ns, approaches) {
  sprintf("[%s].indexOf(input['%s']) >= 0",
          paste0("'", approaches, "'", collapse = ","), ns("ben_approach"))
}

#' Mask for an area selection
#'
#' @param area Named list: admin1/admin2/admin3 -> selected values (NULL = all).
#' @noRd
area_mask <- function(df, settings, area) {
  keep <- rep(TRUE, nrow(df))
  for (lvl in c("admin1", "admin2", "admin3")) {
    col <- settings[[lvl]]
    sel <- area[[lvl]]
    if (shiny::isTruthy(col) && col %in% names(df) && length(sel)) {
      keep <- keep & (as.character(df[[col]]) %in% as.character(sel))
    }
  }
  keep
}

#' Mask for the simple attribute filters (one dropdown per mapped variable)
#'
#' @param filters Named list: setup key -> selected values.
#' @noRd
filters_mask <- function(df, settings, filters) {
  keep <- rep(TRUE, nrow(df))
  for (k in names(filters)) {
    col <- settings[[k]]
    sel <- filters[[k]]
    if (shiny::isTruthy(col) && col %in% names(df) && length(sel)) {
      keep <- keep & (as.character(df[[col]]) %in% as.character(sel))
    }
  }
  keep
}

#' Select households under a targeting approach
#'
#' @param df Registration data.
#' @param settings Setup mapping (unique_id, admin1..3, v_score, ...).
#' @param approach Name of an entry in `targeting_approaches()`.
#' @param area,filters See `area_mask()` / `filters_mask()`.
#' @param ruleset Eligibility rule set (see `R/utils_rules.R`), or NULL.
#' @param scorecard Adopted scorecard, or NULL. When NULL the mapped
#'   vulnerability score and `score_range` stand in for it.
#' @param score_range Numeric length-2 range on the mapped vulnerability score.
#' @param combine For hybrid: "both" (criteria AND score) or "either".
#' @param community List with `column` and `values` meaning "selected by the
#'   community".
#' @param prioritization List with `mode` ("none", "caseload", "per_unit"),
#'   `n` (households) and `unit` (setup key of the admin level for per-unit).
#' @return A list with logical `eligible` and `prioritized` (one per row),
#'   numeric `score` (NA where no score applies), `rank_by`, `list_produced`
#'   and `notes`.
#' @noRd
select_households <- function(df, settings, approach = "hybrid",
                              area = list(), filters = list(), ruleset = NULL,
                              scorecard = NULL, score_range = c(-Inf, Inf),
                              combine = "both", community = list(),
                              prioritization = list(mode = "none")) {
  n <- nrow(df)
  spec <- targeting_approaches()[[approach]]
  if (is.null(spec)) stop("Unknown targeting approach: ", approach, call. = FALSE)
  gates <- spec$gates
  notes <- character(0)

  if (isFALSE(spec$list)) {
    return(list(eligible = rep(FALSE, n), prioritized = rep(FALSE, n),
                score = rep(NA_real_, n), rank_by = NA_character_,
                list_produced = FALSE,
                notes = "Self-targeting produces no household list."))
  }

  keep <- rep(TRUE, n)
  if ("area" %in% gates) keep <- keep & area_mask(df, settings, area)

  # Criteria: the attribute filters and the eligibility rules together.
  crit <- NULL
  crit_active <- FALSE
  if ("criteria" %in% gates) {
    crit <- filters_mask(df, settings, filters)
    crit_active <- any(vapply(filters, length, integer(1)) > 0)
    if (!is.null(ruleset) && !ruleset_is_empty(ruleset)) {
      crit <- crit & ruleset_eval(df, ruleset, settings)$mask
      crit_active <- TRUE
    }
  }

  # Score: the adopted scorecard, or the mapped pre-computed score.
  score <- rep(NA_real_, n)
  scored <- NULL
  rank_by <- NA_character_
  if ("score" %in% gates) {
    if (!is.null(scorecard) && !scorecard_is_empty(scorecard)) {
      r <- apply_scorecard(df, scorecard)
      score <- r$score
      scored <- r$eligible
      rank_by <- "scorecard"
      if (length(r$missing_criteria)) {
        notes <- c(notes, sprintf("%d scorecard criteria are not mapped to this dataset and score nobody.",
                                  length(r$missing_criteria)))
      }
    } else if (shiny::isTruthy(settings$v_score) && settings$v_score %in% names(df)) {
      score <- as_number(df[[settings$v_score]])
      lo <- score_range[1]; hi <- score_range[2]
      # which() semantics: an unscorable household does not qualify.
      scored <- !is.na(score) & score >= lo & score <= hi
      rank_by <- "v_score"
    } else {
      notes <- c(notes, "No scorecard adopted and no vulnerability score mapped: the score layer selects nobody.")
      scored <- rep(FALSE, n)
    }
  }

  if (approach == "hybrid") {
    both <- identical(combine, "both")
    # No criteria set is not "every household meets the criteria": under
    # 'either' that would admit everyone and make the score irrelevant. An
    # unset side is neutral -- TRUE under 'both', FALSE under 'either'.
    c1 <- if (crit_active) crit else rep(both, n)
    s1 <- scored %||% rep(both, n)
    keep <- keep & (if (both) c1 & s1 else c1 | s1)
  } else {
    if (!is.null(crit)) keep <- keep & crit
    if (!is.null(scored)) keep <- keep & scored
  }

  if ("community" %in% gates) {
    col <- community$column
    vals <- community$values
    if (shiny::isTruthy(col) && col %in% names(df) && length(vals)) {
      keep <- keep & (as.character(df[[col]]) %in% as.character(vals))
    } else {
      notes <- c(notes, "Choose the column and value(s) that record the community's selection.")
      keep <- rep(FALSE, n)
    }
  }

  eligible <- keep & !is.na(keep)

  # Prioritisation: rank the eligible and keep the top of the list.
  prioritized <- eligible
  mode <- prioritization$mode %||% "none"
  cap <- suppressWarnings(as.numeric(prioritization$n))
  # Per area, each area can have its own caseload (named: area -> households).
  quotas <- prioritization$quotas
  has_quotas <- identical(mode, "per_unit") && length(quotas) > 0
  if (!identical(mode, "none") && (isTRUE(cap > 0) || has_quotas)) {
    rank_score <- score
    if (all(is.na(rank_score)) && shiny::isTruthy(settings$v_score) &&
        settings$v_score %in% names(df)) {
      rank_score <- as_number(df[[settings$v_score]])
      rank_by <- "v_score"
    }
    if (all(is.na(rank_score))) {
      notes <- c(notes, paste("Prioritisation needs a score to rank households by;",
                              "adopt a scorecard or map a vulnerability score. Not applied."))
    } else {
      # Most vulnerable first; unscored last; ties keep the original order so
      # the result is reproducible.
      ord_key <- ifelse(is.na(rank_score), -Inf, rank_score)
      # A caseload counted in people (beneficiaries): households are taken in
      # order while the people served stay within it. In households: the
      # first k households.
      hs <- settings$hh_size
      size <- if (identical(prioritization$count, "people") && shiny::isTruthy(hs) && hs %in% names(df)) {
        z <- as_number(df[[hs]]); z[is.na(z) | z < 0] <- 1; z
      }
      take <- function(idx, k) {
        if (is.null(size)) return(utils::head(idx, round(k)))
        idx[cumsum(size[idx]) <= k]
      }
      if (identical(mode, "caseload")) {
        idx <- which(eligible)
        idx <- idx[order(-ord_key[idx], idx)]
        prioritized <- rep(FALSE, n)
        prioritized[take(idx, cap)] <- TRUE
      } else if (identical(mode, "per_unit")) {
        ucol <- settings[[prioritization$unit %||% "admin1"]]
        if (shiny::isTruthy(ucol) && ucol %in% names(df)) {
          prioritized <- rep(FALSE, n)
          unit <- as.character(df[[ucol]])
          for (u in unique(unit[eligible])) {
            idx <- which(eligible & unit == u)
            idx <- idx[order(-ord_key[idx], idx)]
            # An area left out of the caseload plan serves no one.
            k <- if (has_quotas) suppressWarnings(as.numeric(quotas[[u]] %||% 0)) else cap
            if (isTRUE(k > 0)) prioritized[take(idx, k)] <- TRUE
          }
        } else {
          notes <- c(notes, "The area level chosen for the per-area cap is not mapped. Not applied.")
        }
      }
    }
  }

  list(eligible = eligible, prioritized = prioritized, score = score,
       rank_by = rank_by, list_produced = TRUE, notes = notes)
}

#' Split a whole total in proportion to weights, summing exactly to the total
#'
#' Largest-remainder rounding: each area gets the whole part of its share,
#' and the units left go to the largest remainders.
#' @noRd
allocate_total <- function(weights, total) {
  w <- as.numeric(weights); w[is.na(w) | w < 0] <- 0
  if (!length(w) || sum(w) == 0 || !isTRUE(total > 0)) return(rep(0, length(w)))
  raw <- total * w / sum(w)
  out <- floor(raw)
  left <- round(total - sum(out))
  if (left > 0) {
    ord <- order(raw - out, w, decreasing = TRUE)
    out[ord[seq_len(left)]] <- out[ord[seq_len(left)]] + 1
  }
  out
}

#' IPC figures per area, when the data carries them
#'
#' A column naming IPC phases (1-5, or text such as "Phase 3") gives each
#' area its most frequent phase; a numeric column naming the IPC phase 3+
#' population gives each area its figure (the largest value, as it is
#' repeated on every household of the area).
#' @return list(phase = named numeric or NULL, pop = named numeric or NULL,
#'   phase_col, pop_col).
#' @noRd
ipc_by_area <- function(df, area) {
  cols <- names(df)[grepl("ipc", names(df), ignore.case = TRUE)]
  pop_col <- cols[grepl("pop|3plus|3_plus|p3|phase3|people|pin", cols, ignore.case = TRUE)][1]
  phase_col <- setdiff(cols, pop_col)[grepl("phase|ipc$|class|level", setdiff(cols, pop_col), ignore.case = TRUE)][1]
  if (is.na(phase_col)) phase_col <- setdiff(cols, pop_col)[1]
  u <- as.character(area)
  out <- list(phase = NULL, pop = NULL, phase_col = NA_character_, pop_col = NA_character_)
  if (!is.na(phase_col)) {
    ph <- suppressWarnings(as.numeric(sub("^\\D*([1-5]).*$", "\\1", as.character(df[[phase_col]]))))
    ph[!ph %in% 1:5] <- NA
    if (any(!is.na(ph))) {
      m <- tapply(ph, u, function(v) { v <- v[!is.na(v)]; if (!length(v)) NA_real_ else as.numeric(names(which.max(table(v)))) })
      out$phase <- m; out$phase_col <- phase_col
    }
  }
  if (!is.na(pop_col)) {
    pv <- as_number(df[[pop_col]])
    if (any(!is.na(pv))) {
      out$pop <- tapply(pv, u, function(v) if (all(is.na(v))) NA_real_ else max(v, na.rm = TRUE))
      out$pop_col <- pop_col
    }
  }
  out
}
