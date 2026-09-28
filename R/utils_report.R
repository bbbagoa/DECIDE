#' Targeting design report
#'
#' A Markdown record of how a scorecard was built, from the assessment data to
#' the adopted threshold: the data, the variables calculated, the outcome, the
#' criteria considered and why some were excluded, the screening, every model
#' run, the estimates, the comparison, the threshold and its rationale, and
#' the design errors with the verdict, written as one self-contained HTML
#' document (figures embedded), so the record opens in any
#' browser and can be filed with the targeting decision (OGN, 2021: the targeting
#' rationale must be documented and kept as a living record).
#'
#' @name design_report
NULL

#' A data frame as a Markdown table
#' @noRd
md_table <- function(df, digits = 3) {
  if (is.null(df) || !nrow(df)) return("_None._")
  fmt <- function(v) {
    if (is.numeric(v)) ifelse(is.na(v), "",
                              ifelse(v == round(v), format(round(v), big.mark = ",", trim = TRUE),
                                     format(round(v, 5), big.mark = ",", trim = TRUE,
                                            scientific = FALSE, drop0trailing = TRUE)))
    else ifelse(is.na(v), "", gsub("|", "\\|", as.character(v), fixed = TRUE))
  }
  body <- vapply(seq_len(nrow(df)), function(i)
    paste0("| ", paste(vapply(df, function(col) fmt(col[i]), character(1)), collapse = " | "), " |"),
    character(1))
  c(paste0("| ", paste(names(df), collapse = " | "), " |"),
    paste0("|", paste(rep(" --- ", ncol(df)), collapse = "|"), "|"),
    body)
}

md_p <- function(p) ifelse(is.na(p), "", ifelse(p < 0.001, "<0.001", sprintf("%.3f", p)))
yn <- function(v, n) if (is.null(v)) rep("", n) else ifelse(v %in% TRUE, "yes", "no")
md_pct <- function(x) ifelse(is.na(x), "n/a", sprintf("%.1f%%", 100 * x))

#' Build the Markdown text
#'
#' @param x Named list of the design's pieces (see the module's report
#'   handler for the fields); missing pieces are reported as not done.
#' @param figures Keys of the figures available. Each `fig()` call leaves a
#'   placeholder that `write_design_report()` replaces with the charts; keys
#'   given together are laid out side by side.
#' @noRd
design_report_md <- function(x, figures = character(0)) {
  L <- character(0)
  add <- function(...) L <<- c(L, ...)
  fig <- function(...) {
    keys <- intersect(c(...), figures)
    if (length(keys)) add(sprintf("@@FIG:%s@@", paste(keys, collapse = ",")), "")
  }

  nof <- isTRUE(x$no_outcome)
  if (nof) {
    add("# Vulnerability ranking report", "",
        sprintf("_Generated %s by TargetWise._", x$generated %||% format(Sys.time(), "%Y-%m-%d %H:%M")), "",
        "This document records how households were ranked without an outcome indicator, from the data to the ranking",
        "and its threshold, so the ranking can be reviewed, reproduced and challenged.", "",
        "## Key results", "", "@@RANK_CARDS@@", "")
  } else {
    add("# Targeting design report", "",
        sprintf("_Generated %s by TargetWise._", x$generated %||% format(Sys.time(), "%Y-%m-%d %H:%M")), "",
        "This document records every step from the assessment data to the scorecard, so the design can be",
        "reviewed, reproduced and challenged.", "")
    if (!is.null(x$errors)) add("## Key results", "", "@@ERRORS@@", "")
  }

  add(if (nof) "## 1. Data" else "## 1. Assessment data", "",
      sprintf("- Source: %s", x$source %||% "not recorded"),
      sprintf("- Areas covered: %s", x$areas %||% "All areas"),
      sprintf("- Households: %s; variables: %s", format(x$n_rows %||% NA, big.mark = ","), x$n_cols %||% NA), "")

  add("### Variables calculated", "")
  if (is.null(x$calc_vars) || !nrow(x$calc_vars)) add("_No variable was calculated in the app; all come from the source file._", "")
  else add(md_table(stats::setNames(x$calc_vars, c("Variable", "Definition", "Created"))), "")

  if (nof) {
    add("## 2. Purpose of the ranking", "",
        if (shiny::isTruthy(x$rank_label)) sprintf("The ranking stands for: **%s**.", x$rank_label) else "_What the ranking stands for was not recorded._", "",
        "No food-security outcome indicator was available (for example after a sudden shock, or with data from a partner or a registry).",
        "Households were therefore ranked on the criteria chosen below, not against an outcome: the criteria were not tested, and no inclusion",
        "or exclusion error can be measured. Internal consistency, the stability of the selection and what the selection concentrates stand in",
        "for them until a verification sample or a post-distribution monitoring survey with an outcome measures the errors (Monitoring, PDM).", "")
  } else {
  add("## 2. Vulnerability Framework", "")
  if (!shiny::isTruthy(x$outcome)) add("_No outcome chosen._", "") else add(
    sprintf("- Outcome variable: `%s`", x$outcome),
    sprintf("- Level treated as vulnerable: **%s**", x$outcome_pos %||% "n/a"),
    sprintf("- Vulnerable households: %s of %s (%s)", format(x$n_vuln %||% NA, big.mark = ","),
            format(x$n_outcome %||% NA, big.mark = ","), md_pct(x$prevalence)),
    "", "Outcome indicators (FCS, rCSI, LCSI, CARI and similar) are the outcome the scorecard predicts and",
    "are never used as eligibility criteria (Targeting Advisory 1/2025).", "")
  va <- x$vuln_area
  if (!is.null(va) && nrow(va)) {
    add("### Vulnerable households by area", "",
        sprintf("Share of households on the vulnerable side of the outcome, by `%s`%s.", x$vuln_area_col %||% "area",
                if (nrow(va) > 30) " (the 30 areas with the highest share are charted)" else ""), "")
    fig("vuln_area")
    add(md_table(data.frame(Area = va$area, Households = format(va$households, big.mark = ","),
                            Vulnerable = format(va$vulnerable, big.mark = ","),
                            `Share vulnerable` = sprintf("%.1f%%", 100 * va$share), check.names = FALSE)), "")
  }
  }

  add("## 3. Criteria", "")
  ab <- x$allowed_blocked
  if (length(ab)) {
    notes <- x$allowed_reason %||% character(0)
    note_of <- function(a) { v <- if (length(notes) == 1 && is.null(names(notes))) notes else notes[a]; if (is.na(v) || !nzchar(v)) "no note given" else v }
    add(sprintf("**Allowed by the analyst although blocked by a rule:** %s.", paste0("`", names(ab), "`", collapse = ", ")), "",
        md_table(data.frame(Column = names(ab), `Rule that blocked it` = unname(ab),
                            `Analyst's note` = vapply(names(ab), note_of, character(1)), check.names = FALSE)), "")
  }
  if (is.null(x$screening)) add("_No variables were selected._", "") else {
    s <- x$screening
    if (nof) {
      add(sprintf("The analyst chose the criteria that describe vulnerability in this context (nothing to test them against); pairs correlated above **|r| = %s** were flagged so one situation is not counted twice.",
                  x$screen_settings$corr %||% 0.8), "",
          "Share of households meeting each criterion kept:", "",
          md_table(data.frame(Criterion = s$criterion, `Households meeting it` = md_pct(s$prevalence), Missing = md_pct(s$missing),
                              check.names = FALSE)[s$retained, , drop = FALSE]), "")
    } else {
    add(sprintf("Every yes/no variable of the data was compared with the vulnerability framework before any criterion was chosen; the analyst kept variables from their descriptive statistics and correlations (no model fitted at this step); pairs correlated above **|r| = %s** were flagged.",
                x$screen_settings$corr %||% 0.8), "",
        "Descriptive statistics of the variables kept:", "",
        md_table(data.frame(
          Criterion = s$criterion, Prevalence = md_pct(s$prevalence),
          Vulnerable = md_pct(s$prev_vuln), `Not vulnerable` = md_pct(s$prev_not),
          `Gap (pts)` = round(100 * s$gap, 1), Missing = md_pct(s$missing),
          check.names = FALSE)[s$retained, , drop = FALSE]), "")
    fig("prevalence")
    }
    cp <- x$corr_pairs
    cut <- x$screen_settings$corr %||% 0.8
    if (is.null(cp) || !nrow(cp)) add(sprintf("No two of the variables considered were correlated at or above |r| = %s.", cut), "")
    else add(sprintf("Pairs of variables correlated at or above **|r| = %s**, by group (one variable of each group is enough):", cut), "",
             md_table(data.frame(Group = cp$group, `Variable A` = cp$a, `Variable B` = cp$b, r = sprintf("%.2f", cp$r),
                                 Removed = cp$removed, check.names = FALSE)), "")
    n_drop <- sum(!s$retained)
    if (n_drop) add(sprintf("%d candidate(s) were dropped%s.", n_drop,
      if (length(x$collinear)) sprintf(", %d of them because they duplicated a stronger variable", length(x$collinear)) else ""), "")
  }


  kept <- if (is.null(x$screening)) character(0) else x$screening$criterion[x$screening$retained]
  chosen <- x$candidates %||% character(0)
  add(sprintf("%d variables were ticked; **%d criteria went to the model**: %s.",
              length(kept), length(chosen),
              if (length(chosen)) paste0("`", chosen, "`", collapse = ", ") else "none"), "")

  add(if (nof) "## 4. Ranking method" else "## 4. Model", "")
  if (is.null(x$model)) add("_No model was fitted._", "") else if (nof) {
    m <- x$model
    add(sprintf("- Method: **%s**", m$method),
        sprintf("- Oriented by: %s", if (is.na(x$index$anchor %||% NA)) "the number of criteria met (no anchor criterion)" else sprintf("the anchor criterion `%s`", x$index$anchor)),
        sprintf("- Households ranked: %s", format(m$n_train, big.mark = ",")),
        sprintf("- Survey weights: %s", if (shiny::isTruthy(m$weights)) paste0("`", m$weights, "`") else "none"),
        if (length(m$dropped)) sprintf("- Left out (constant): %s", paste0("`", m$dropped, "`", collapse = ", ")), "")
    if (!is.null(x$runs) && nrow(x$runs) > 1) add("### Iterations", "",
      sprintf("%d rankings were fitted; the one shown is marked.", nrow(x$runs)), "", md_table(x$runs[, setdiff(names(x$runs), "AUC"), drop = FALSE]), "")
  }
  if (!is.null(x$model)) {
    m <- x$model
    if (!nof) add(sprintf("- Model: **%s**", m$method),
        sprintf("- Weighting scheme: **%s**", m$scheme),
        sprintf("- Stepwise selection of the criteria: %s",
                if ((m$stepwise %||% "none") %in% c("aic", "bic")) sprintf("**%s, %s**", m$stepwise_dir %||% "backward", toupper(m$stepwise)) else "none"),
        sprintf("- Training households: %s; held out for evaluation: %s (seed %s)",
                format(m$n_train, big.mark = ","), format(m$n_test, big.mark = ","), m$seed),
        sprintf("- Survey weights: %s", if (shiny::isTruthy(m$weights)) paste0("`", m$weights, "`") else "none"),
        if (length(m$dropped)) sprintf("- Removed by the model: %s", paste0("`", m$dropped, "`", collapse = ", ")),
        if (!is.null(m$fit_stats)) sprintf("- Fit: %s", m$fit_stats),
        if (isFALSE(m$converged)) "- **Warning:** the model did not converge cleanly (likely complete separation).",
        "")
    if (!nof && !is.null(x$runs) && nrow(x$runs) > 1) add("### Iterations", "",
      sprintf("%d fits were run; the one adopted is marked.", nrow(x$runs)), "", md_table(x$runs), "")
    w <- x$estimates
    ix <- x$index
    if (!is.null(ix)) {
      # PCA / LDA: an index, not a log-odds model; its own diagnostics and weights
      pct <- function(v) sprintf("%.1f%%", 100 * v)
      if (identical(ix$type, "pca")) {
        add("### The PCA index", "",
            sprintf("- Axes kept: **%d**%s", ix$axes %||% 1,
                    if (!is.null(ix$min_var)) sprintf(" (the fewest reaching the %s of variation asked)", pct(ix$min_var)) else ""),
            sprintf("- Total variation explained: **%s**", pct(ix$share)),
            if (length(ix$axis_share) > 1) sprintf("- By axis: %s", paste(sprintf("axis %d %s (weight %.2f)", seq_along(ix$axis_share),
                                                                                    pct(ix$axis_share), ix$axis_weights), collapse = "; ")),
            sprintf("- Kaiser's rule (eigenvalue above 1) would keep %d axis(es)", ix$kaiser %||% NA_integer_),
            sprintf("- Sampling adequacy (KMO): %s; Bartlett's test of sphericity: p %s",
                    if (is.na(ix$kmo %||% NA)) "n/a" else sprintf("%.2f", ix$kmo),
                    if (is.null(ix$bartlett_p)) "n/a" else if (ix$bartlett_p < .001) "< 0.001" else sprintf("= %.3f", ix$bartlett_p)),
            "- Each axis is turned so that a higher coordinate means more vulnerable; the index averages the axes kept, weighted by the variation they explain.", "")
        # (not `L`: that is this function's text)
        ld <- ix$axis_loadings
        tab <- data.frame(Criterion = w$criterion, Direction = w$direction, `Index coefficient` = round(w$coefficient, 4),
                          Points = round(w$weight, 2), check.names = FALSE)
        if (!is.null(ld)) for (j in seq_len(ncol(ld))) tab[[sprintf("Loading axis %d", j)]] <- round(ld[match(w$criterion, rownames(ld)), j], 3)
        add("### Index weights", "", md_table(tab), "",
            if (nof) "Score = the points of every criterion met in the vulnerable direction (an inclusion criterion met, an exclusion criterion not met). Points are the index coefficients scaled so the largest is 10."
            else "Score = sum of the points of the criteria met, floored at zero. Points are the index coefficients scaled so the largest is 10.", "")
        fig("pca_scree", "pca_circle")
      } else if (identical(ix$type, "count")) {
        add("### Deprivation count", "",
            "- Each criterion met adds its points; a household is selected when its weighted deprivations exceed the threshold (Alkire-Foster).",
            sprintf("- Internal consistency (Cronbach's alpha): %s", if (is.na(ix$alpha %||% NA)) "n/a" else sprintf("%.2f", ix$alpha)), "")
        add("### Weights", "", md_table(data.frame(Criterion = w$criterion, Points = round(w$weight, 2), check.names = FALSE)), "")
      } else if (identical(ix$type, "mca")) {
        add("### The MCA index", "",
            sprintf("- Axes kept: **%d**; inertia explained: **%s**", ix$axes %||% 1, pct(ix$share)),
            sprintf("- Turned so that %s raises the index", if (is.na(ix$anchor %||% NA)) "the number of criteria met" else sprintf("the anchor criterion `%s`", ix$anchor)),
            sprintf("- Internal consistency (Cronbach's alpha): %s", if (is.na(ix$alpha %||% NA)) "n/a" else sprintf("%.2f", ix$alpha)), "")
        add("### Index weights", "", md_table(data.frame(Criterion = w$criterion, Direction = w$direction,
            `Index coefficient` = round(w$coefficient, 4), Points = round(w$weight, 2), check.names = FALSE)), "")
        fig("pca_scree")
      } else if (identical(ix$type, "cluster")) {
        alg <- cluster_algorithm_label(ix$algorithm)
        add("### Household profiles", "",
            sprintf("- %d profiles found by %s; profiles ranked on the first component turned towards %s", ix$k, alg,
                    if (is.na(ix$anchor %||% NA)) "the number of criteria met" else sprintf("`%s`", ix$anchor)),
            sprintf("- Targeted: profile %s (%s of the households)", paste(ix$target, collapse = ", "), pct(sum(ix$size[ix$target]))),
            "- The points are a linear discriminant that reproduces the targeted profiles, so the card can be applied at registration.",
            if (!is.null(ix$fidelity)) sprintf("- How well the points reproduce the targeted profiles: AUC **%.2f**", ix$fidelity), "")
        pr <- ix$profiles[, ix$rank, drop = FALSE]
        tab <- data.frame(Criterion = rownames(pr), round(100 * pr, 0), check.names = FALSE)
        names(tab)[-1] <- sprintf("%s (%s)%s", colnames(pr), pct(ix$size[ix$rank]), ifelse(ix$rank %in% ix$target, " *", ""))
        add("Share of households meeting each criterion, by profile (%; * = targeted):", "", md_table(tab), "")
        add("### Points", "", md_table(data.frame(Criterion = w$criterion, Direction = w$direction,
            Points = round(w$weight, 2), check.names = FALSE)), "")
        fig("cluster_profiles")
      } else {
        add("### The LDA index", "",
            sprintf("- Separation between the two groups (Mahalanobis D\u00b2): **%.2f**", ix$mahalanobis %||% NA_real_),
            "- The discriminant is turned so that a higher index means more vulnerable.", "")
        st <- x$index_structure
        add("### Index weights", "", md_table(data.frame(
          Criterion = w$criterion, Direction = w$direction, `Index coefficient` = round(w$coefficient, 4),
          Points = round(w$weight, 2),
          `Correlation with the index` = if (length(st)) round(unname(st[w$criterion]), 3) else NA, check.names = FALSE)), "",
          "Score = sum of the points of the criteria met, floored at zero. Points are the discriminant coefficients scaled so the largest is 10.", "")
        fig("lda_structure")
      }
      fig("weights", "comparison_roc")
    } else {
      add("### Estimates and points", "")
      add(md_table(data.frame(
        Criterion = w$criterion, Beta = round(w$coefficient, 3),
        SE = if (is.null(w$std_error)) NA else round(w$std_error, 3),
        `Odds ratio` = round(w$odds_ratio, 2),
        `95% CI` = if (is.null(w$or_low)) "" else ifelse(is.na(w$or_low), "", paste0(fmt_ratio(w$or_low), "-", fmt_ratio(w$or_high))),
        p = md_p(w$p_value), Direction = w$direction, Points = round(w$weight, 2),
        Verifiable = yn(w$verifiable, nrow(w)),
        `Community validated` = yn(w$validated, nrow(w)), check.names = FALSE)), "",
        "Score = sum of the points of the inclusion criteria met minus those of the exclusion criteria met, floored at zero.", "")
      fig("weights", "comparison_roc")
    }
    # hyperparameters tuned by cross-validation, and the decision tree's rules
    tn <- x$model$tuning
    if (!is.null(tn)) {
      add("### Hyperparameter tuning", "",
          sprintf("Tuned by **%d-fold cross-validation** on %s training households: every setting of a small grid was fitted on %d folds and scored on the one left out; the setting with the best cross-validated AUC was kept (**%s**, AUC %.3f) and the model refitted with it.",
                  tn$folds, format(tn$n, big.mark = ","), tn$folds - 1,
                  paste(sprintf("%s = %s", names(tn$best), vapply(tn$best, function(v) format(signif(v, 3)), character(1))), collapse = ", "), tn$best_auc), "",
          md_table(utils::head(tn$table, 10)), "")
    }
    dg <- x$model$diagram
    if (!is.null(dg) && nzchar(diagram_svg(dg))) add(paste("###", diagram_title(dg$kind)), "", diagram_help(dg$kind, nof), "", "@@DIAGRAM@@", "")
    rl <- x$model$tree_rules
    if (!is.null(rl) && nrow(rl)) add("### Decision tree rules", "",
      if (nof) "Each leaf of the tree: the answers that lead to it, the households it holds and the share of them in the targeted profiles. The points of the ranking are the tree's average effects; the rules show what the tree itself does."
      else "Each leaf of the tree: the answers that lead to it, the training households it holds and the share of them that is vulnerable. The points of the card are the tree's average effects; the rules show what the tree itself does.", "",
      md_table(stats::setNames(data.frame(rl$rule, format(rl$households, big.mark = ","), md_pct(rl$share_vulnerable)),
                               c("If the household...", "Households", if (nof) "In targeted profiles" else "Vulnerable"))), "")
    kq <- x$model$k_quality
    if (!is.null(kq)) add(sprintf("The number of profiles (%d) was chosen automatically: the best silhouette among 2 to 8 profiles.", x$index$k %||% NA), "",
                          md_table(data.frame(Profiles = kq$k, Silhouette = round(kq$silhouette, 3), `Smallest profile` = md_pct(kq$smallest), check.names = FALSE)), "")
    # Each criterion's effect under every model compared (log-odds)
    ef <- x$effects
    if (!is.null(ef) && nrow(ef)) {
      models <- unique(ef$model)
      tab <- data.frame(Criterion = unique(ef$criterion), check.names = FALSE)
      for (m in models) tab[[m]] <- vapply(tab$Criterion, function(cr) {
        v <- ef$effect[ef$criterion == cr & ef$model == m][1]; if (is.na(v)) "-" else sprintf("%+.3f", v) }, character(1))
      add("### Each criterion under every model", "",
          "Effect of each criterion (log-odds) under every model compared; a dash means the model dropped it. Effects that agree across models are robust to the method.", "",
          md_table(tab), "")
    }
  }

  if (!is.null(x$comparison) && nrow(x$comparison)) {
    add("### Model comparison", "",
        "AUC on the held-out households, which the models never saw (Targeting Advisory 3/2025).", "",
        md_table(data.frame(Model = x$comparison$model, Criteria = x$comparison$criteria,
                            `AUC (training)` = round(x$comparison$auc_train, 3),
                            `AUC (held out)` = round(x$comparison$auc_test, 3), check.names = FALSE)), "")
  }

  add(if (nof) "## 5. Threshold and validity" else "## 5. Threshold and design errors", "")
  if (nof) {
    st <- x$stability; si <- x$insights; ix <- x$index %||% list()
    add(sprintf("- Selected when score > **%s**: %s households (%s)", fmt5(x$threshold %||% 0),
                format(x$selected$n %||% NA, big.mark = ","), md_pct(x$selected$share %||% NA)),
        if (shiny::isTruthy(x$threshold_note)) sprintf("- How it was chosen: %s", x$threshold_note),
        "", "### Validity without an outcome", "",
        sprintf("- **Stability of the selection:** %s", if (is.null(st)) "not checked" else
          sprintf("%s, %.0f%% agreement (Jaccard index, median of %d refits on resampled households; 10th-90th percentile %.0f%%-%.0f%%)",
                  stability_word(st$jaccard), 100 * st$jaccard, st$draws, 100 * st$low, 100 * st$high)),
        if (!is.null(st$spearman) && is.finite(st$spearman)) sprintf("- **Rank agreement across resamples** (Spearman): %.2f", st$spearman),
        sprintf("- **Internal consistency** (Cronbach's alpha): %s", if (is.na(ix$alpha %||% NA)) "n/a" else sprintf("%.2f", ix$alpha)),
        if (!is.null(ix$silhouette)) sprintf("- **Separation of the profiles** (mean silhouette width): %s", if (is.na(ix$silhouette)) "n/a" else sprintf("%.2f", ix$silhouette)),
        if (!is.null(ix$entropy)) sprintf("- **Classification certainty** (entropy): %.2f", ix$entropy),
        if (!is.null(ix$fidelity)) sprintf("- **How well the points reproduce the targeted profiles** (AUC): %.2f", ix$fidelity),
        if (!is.null(si)) sprintf("- **Concentration:** the selected households have %.1f times as many deprivations as the others (%.1f against %.1f of %d criteria) and hold %s of all deprivations.",
                                  si$ratio, si$mean_sel, si$mean_not, si$n_criteria, md_pct(si$concentration)),
        "- **Inclusion and exclusion errors: not measured** (no outcome indicator). Measure them on a verification sample or the PDM (Monitoring) before scaling up.", "")
    add(ranking_validity_reading(x))
    fig("rank_hist", "households_map")
    ca <- x$cov_area
    if (!is.null(ca) && nrow(ca)) {
      add("### Share selected by area", "", sprintf("By `%s`.", x$cov_area_col %||% "area"), "")
      fig("cov_area")
      add(md_table(data.frame(Area = ca$area, Households = format(ca$n, big.mark = ","), `Share selected` = md_pct(ca$share),
                              check.names = FALSE)), "")
    }
    add("**Rationale recorded by the team:**", "",
        if (nzchar(rich_html(x$rationale))) "@@RATIONALE@@" else "> _Not documented._", "")
  } else if (is.null(x$errors)) add("_Not evaluated._", "") else {
    e <- x$errors
    add("@@ERRORS@@", "",
        sprintf("- Eligible when score > **%s**", fmt5(x$threshold %||% 0)),
        if (shiny::isTruthy(x$threshold_note)) sprintf("- How it was chosen: %s", x$threshold_note),
        sprintf("- Tolerance band: %.0f%% - %.0f%%", 100 * x$tolerance[1], 100 * x$tolerance[2]),
        sprintf("- Evaluated on: %s", x$eval_note %||% "all households"),
        sprintf("- AUC: %s", if (is.na(x$auc %||% NA)) "n/a" else sprintf("%.3f", x$auc)), "",
        if (isTRUE(x$tolerance_changed)) "- The tolerance band differs from the default (5% - 20%); the rationale below says why.",
        "**Rationale recorded by the team:**", "",
        if (nzchar(rich_html(x$rationale))) "@@RATIONALE@@" else "> _Not documented. Targeting Advisory 2/2025 requires it._",
        if (shiny::isTruthy(x$exceed_note)) c("", "**Adopted although errors are beyond the tolerance, because:**", "",
                                             paste(">", gsub("\n", "\n> ", x$exceed_note, fixed = TRUE))),
        "", "### Design error matrix", "", "@@MATRIX@@", "",
        sprintf("- **Inclusion error** %s = %s / %s: of everyone selected, the share who did not need assistance.",
                md_pct(e$inclusion_error), e$included_not_in_need, e$correctly_included + e$included_not_in_need),
        sprintf("- **Exclusion error** %s = %s / %s: of everyone who needed assistance, the share left out.",
                md_pct(e$exclusion_error), e$excluded_in_need, e$correctly_included + e$excluded_in_need),
        "", "Valid for direct household-level (Tier 1) assistance only.", "")
    if (!is.null(x$verdict)) add("### Verdict (Targeting Advisory 2/2025)", "",
      sprintf("**%s**", x$verdict$interpretation), "", sprintf("Action: %s", x$verdict$action), "")
    fig("roc", "scores")
    fig("box", "met")
    fig("drivers", "coverage")
  }

  add("## 6. Adoption", "")
  word <- if (nof) "vulnerability ranking" else "scorecard"
  if (isTRUE(x$adopted)) {
    add(sprintf("**Adopted%s.** This exact design (criteria, points, threshold) is the %s Beneficiary Selection applies. Any later change to the design withdraws the adoption until it is approved again.",
                if (shiny::isTruthy(x$adopted_at)) paste0(" on ", x$adopted_at) else "", word), "")
  } else {
    add("**Not adopted.** This report documents a draft: Beneficiary Selection does not use it until it is adopted, after every step above.", "",
        if (isTRUE(x$other_in_use)) "A different scorecard, loaded from a workbook, is currently in use." else NULL, "")
  }

  add(if (nof) ranking_report_methods(x) else design_report_methods(x))
  paste(L, collapse = "\n")
}

#' How to read the validity checks of a ranking, with this design's values
#'
#' Without an outcome, accuracy (inclusion / exclusion error) cannot be
#' measured: the checks say whether the ranking is coherent, reproducible and
#' does what it claims. Each row gives the value, what it means here and what
#' it cannot tell.
#' @noRd
ranking_validity_reading <- function(x) {
  st <- x$stability; si <- x$insights; ix <- x$index %||% list()
  meth <- x$model$method_code %||% ""; cl <- identical(ix$type, "cluster")
  num <- function(v, d = 2) if (is.null(v) || !is.finite(v)) "n/a" else formatC(v, format = "f", digits = d)
  band <- function(v, cuts, words) if (is.null(v) || !is.finite(v)) "Not computed." else words[findInterval(v, cuts) + 1]
  rows <- list()
  row <- function(check, value, reading, limit) rows[[length(rows) + 1]] <<- data.frame(
    Check = check, Value = value, `What it means here` = reading, `What it cannot tell` = limit, check.names = FALSE)
  a <- ix$alpha
  row("Internal consistency (Cronbach's alpha)", num(a),
      paste(band(a, c(.5, .7), c("The criteria barely go together (below 0.5).", "Weak consistency (0.5-0.7).", "The criteria form a consistent scale (0.7 and above).")),
            if (identical(meth, "count")) "A deprivation count is multidimensional on purpose, so a low value is expected and not a flaw."
            else if (meth %in% c("pca", "mca")) "An index assumes one dominant dimension: a low value weakens it; check the variation the first axis explains."
            else ""),
      "Alpha rises with the number of criteria, so many weak criteria can look consistent. Consistency is not accuracy.")
  row("Stability of the selection (Jaccard)", if (is.null(st)) "not checked" else sprintf("%.0f%% (%.0f%%-%.0f%%)", 100 * st$jaccard, 100 * st$low, 100 * st$high),
      if (is.null(st)) "Run the stability check before adopting: an unstable list depends on who happened to be surveyed."
      else paste0(band(st$jaccard, c(.5, .7, .85), c("Very unstable (below 50%): ", "Unstable (50-70%): ", "Fairly stable (70-85%): ", "Stable (85% and above): ")),
                  sprintf("of the households selected by the design or by a refit on resampled households, %.0f%% are selected by both (median of %d refits; 10th-90th percentile in brackets).",
                          100 * st$jaccard, st$draws),
                  if (st$jaccard < .7) " Rare criteria, weakly separated profiles or many correlated criteria usually cause it." else ""),
      "A consistently wrong ranking is perfectly stable: stability measures dependence on the sample, not correctness. It depends on the share selected, so compare designs at the same threshold.")
  if (!is.null(st$spearman) && is.finite(st$spearman))
    row("Rank agreement (Spearman)", num(st$spearman),
        "How far households keep their order across the refits, over the whole ranking and not only at the cut (1 = same order).",
        "Households tied on the same score are ordered arbitrarily, which lowers it for coarse scores.")
  if (cl) {
    row("Separation of the profiles (silhouette)", num(ix$silhouette),
        band(ix$silhouette, c(.25, .5), c("Hardly any structure (below 0.25): the profiles cut through a continuum.",
                                          "Weak but real profiles (0.25-0.5).", "Clearly separated profiles (0.5 and above).")),
        "Well separated profiles need not be the vulnerable ones: the team's choice of targeted profiles carries that.")
    if (!is.null(ix$entropy) && is.finite(ix$entropy))
      row("Classification certainty (entropy, latent classes)", num(ix$entropy),
          band(ix$entropy, .8, c("Many households sit between classes (below 0.8).", "Households belong clearly to one class (0.8 and above).")),
          "Says nothing about which class is vulnerable.")
    if (!is.null(ix$fidelity))
      row("Fidelity of the points (AUC)", num(ix$fidelity),
          paste("The additive points applied at registration reproduce the targeted profiles",
                band(ix$fidelity, c(.8, .9), c("only partly (below 0.8): some targeted households score low, because the profiles are not a straight cut through the criteria.",
                                               "mostly (0.8-0.9).", "faithfully (0.9 and above)."))),
          "Measured against the profiles, not against need.")
  }
  if (!is.null(si))
    row("Concentration of deprivations", sprintf("%.1fx, %s", si$ratio, md_pct(si$concentration)),
        sprintf("The selected households meet %.1f times as many criteria in the vulnerable direction as the others and hold %s of all deprivations.",
                si$ratio, md_pct(si$concentration)),
        "Partly circular: the selection is made on these criteria, so the selected always carry more of them. Use it to compare designs at the same threshold and to spot criteria or areas the ranking barely reaches.")
  row("Inclusion and exclusion errors", "not measured",
      "Without an outcome indicator there is nothing to compare the selection with.",
      "Only an external reference measures accuracy: post-distribution monitoring (Monitoring, PDM, 'Calibrate the ranking'), community validation or an outcome collected on a sub-sample.")
  tab <- do.call(rbind, rows)
  c("### How to read these checks", "",
    "Without an outcome indicator, accuracy in the usual sense cannot be measured. These checks say whether the ranking is **coherent** (the criteria or profiles form a real structure), **reproducible** (the list does not depend on who happened to be surveyed) and **does what it claims** (the points reproduce the chosen profiles; the selection concentrates the deprivations). They are necessary conditions for good targeting, not proof of it.", "",
    md_table(tab), "",
    "**Reading order.** 1) Is there a structure worth ranking on: alpha for an index, silhouette and entropy for profiles. 2) Is the selection at least fairly stable (70% or more) at the chosen threshold. 3) For profiles, do the points reproduce them. 4) Does the selection look sensible: concentration, share selected by area. 5) After distribution, calibrate the ranking on post-distribution monitoring data: that is its accuracy test.", "")
}

#' Methods appendix of a vulnerability ranking (no outcome indicator)
#' @noRd
ranking_report_methods <- function(x) {
  ix <- x$index %||% list(); meth <- x$model$method_code %||% ""
  L <- c("## 7. Methods", "", "How each number in this report was produced.", "")
  item <- function(title, ...) L <<- c(L, sprintf("### %s", title), "", paste0(...), "")
  item("Why a ranking",
       "Without an outcome indicator there is nothing to predict: households are ordered on criteria the team chose, and the threshold ",
       "is a programmatic decision (caseload, budget). This is the situation of a sudden shock before any assessment, or of data from a partner or a registry.")
  switch(if (identical(ix$type, "cluster")) "cluster" else meth,
    count = item("Deprivation counting (Alkire-Foster)",
                 "Each criterion is a deprivation (a 'yes' means deprived); a household's score is the sum of the points of its deprivations, ",
                 "and it is selected when that sum exceeds the threshold (the dual cut-off method of Alkire & Foster 2011; the global MPI uses a third of the weighted indicators)."),
    pca = item("PCA index",
               "Principal component analysis of the 0/1 criteria (correlation matrix, survey weights when set). The first component(s) summarise ",
               "what the criteria share; each is turned so that the anchor criterion raises it, and the index averages the axes kept, weighted by the ",
               "variation they explain (the asset-index method of Filmer & Pritchett 2001). Points are the index coefficients scaled so the largest is 10."),
    mca = item("MCA index",
               "Multiple correspondence analysis of the criteria's answers (both yes and no of each criterion). A household's coordinate is the average of ",
               "its answers' coordinates, so the index is additive: points = (coordinate of yes - coordinate of no) / number of criteria, averaged over ",
               "the axes kept and turned towards the anchor criterion. Rare answers weigh more than in PCA."),
    cluster = item("Household profiles",
                   c(lca = "Latent class analysis: a mixture of independent yes/no answers fitted by EM from several random starts (the best likelihood kept). ",
                     kmeans = "k-means on the 0/1 criteria (10 random starts). ",
                     hclust = "Hierarchical clustering with Ward's criterion (on a sample of 5,000 households above that size, the others joining the nearest profile). ",
                     tree = "k-means on the 0/1 criteria (10 random starts); a classification tree (rpart) then describes the targeted profiles in rules, and its average effects give the points. ")[[ix$algorithm %||% "kmeans"]],
                   "Profiles are ranked on the first principal component turned towards the anchor criterion; the team chose the profiles to target. ",
                   "A linear discriminant between the targeted profiles and the others gives additive points, so the ranking can be applied at registration; ",
                   "its AUC against profile membership says how faithfully."),
    NULL)
  item("Stability of the selection",
       "The design is refitted on 20 bootstrap resamples of the households; each refit scores every household and selects the same share. ",
       "The Jaccard index (households selected by both / by either) compares each refit's selection with the design's; the median and the ",
       "10th-90th percentiles are reported. Spearman's correlation compares the order of the households. Above 0.85 reads as stable, 0.7-0.85 fairly stable, 0.5-0.7 unstable, below 0.5 very unstable. ",
       "Each refit uses the same method and settings; a refit that fails (a criterion constant in the resample) is left out. The check measures ",
       "sensitivity to the sample, not correctness, and depends on the share selected.")
  item("Internal consistency",
       "Cronbach's alpha of the 0/1 criteria: how far they measure one thing. Low values are expected when the criteria cover different ",
       "dimensions of vulnerability on purpose; they then call for counting or profiles rather than a single index. Computed on the survey weights ",
       "when set (for 0/1 criteria it equals the Kuder-Richardson KR-20). 0.7 and above reads as consistent, 0.5-0.7 weak; alpha rises with the number of criteria.")
  if (identical(ix$type, "cluster")) item("Separation of the profiles",
       "Mean silhouette width (on up to 2,000 households): for each household, how much closer it is to its own profile than to the nearest other one, ",
       "from -1 to 1 (above 0.5 clear, 0.25-0.5 weak but real). For latent classes, the entropy of the class probabilities (above 0.8 clear) and the BIC (lower is better).")
  item("Concentration",
       "A household's deprivations are the criteria it meets in the vulnerable direction. The report compares their mean among the selected and the ",
       "others, and the share of all deprivations the selected hold. Because the selection is made on the same criteria, the selected always carry ",
       "more of them: the figures compare designs and show where the ranking reaches, they do not validate it.")
  item("Measuring the errors later",
       "Apply the adopted ranking to a verification sample or to post-distribution monitoring data that carry a food-security outcome ",
       "(Monitoring, PDM): the inclusion and exclusion errors, the AUC and a better threshold then become measurable, and the design can be recalibrated.")
  L
}

#' Methods appendix: every technique the design used, explained
#'
#' Written from what was actually run (the model and scheme chosen, whether a
#' hold-out, survey weights, benchmarks or quick screening were used, and how
#' the threshold was set), so the record states its methods rather than a
#' generic list.
#' @noRd
design_report_methods <- function(x) {
  m <- x$model %||% list()
  L <- c("## 7. Methods", "",
         "How each number in this report was produced.", "")
  item <- function(title, ...) L <<- c(L, sprintf("### %s", title), "", paste0(...), "")

  item("Outcome",
       sprintf("The outcome `%s` was recoded to two classes: households at level **%s** count as vulnerable (1), all others as not vulnerable (0). ",
               x$outcome %||% "", x$outcome_pos %||% ""),
       "Outcome indicators are what the scorecard predicts and are never used as criteria (Targeting Advisory 1/2025).")

  item("Descriptive statistics",
       "For each yes/no criterion: its **prevalence** (share of households meeting it), its prevalence among vulnerable and among ",
       "not-vulnerable households, and the **gap** between the two in percentage points. A large positive gap marks an ",
       "inclusion criterion, a large negative one an exclusion criterion; a gap near zero means the criterion separates nobody.")

  item("Correlation between criteria",
       sprintf("Pairwise **phi coefficients** (Pearson correlation of two 0/1 variables) on complete pairs. Pairs at or above |r| = %s were flagged: ",
               x$screen_settings$corr %||% 0.8),
       "while any flagged pair remained, the member with the larger mean absolute correlation with all others was proposed for dropping ",
       "(the rule used by `caret::findCorrelation`), because two criteria that say the same thing would split one effect in two and count it twice. ",
       "The analyst confirmed or overrode each proposal.")

  if (!is.null(x$quick_screen)) item("Quick screening (optional aid)",
       "Each candidate was tested on its own against the outcome: a logistic regression of the outcome on that one criterion, ",
       "compared with an intercept-only model by a **likelihood-ratio test**; where that model could not be estimated, ",
       "**Fisher's exact test** on the 2x2 table. p-values were adjusted for the number of candidates by the **",
       x$quick_screen$adjust, "** method and compared with a significance level of ", x$quick_screen$alpha,
       ". The result only informed which candidates were ticked. References: Agresti (2013), *Categorical Data Analysis*, 3rd ed.; ",
       "Benjamini & Hochberg (1995), *JRSS B* 57.")

  if (length(m)) {
    if (isTRUE(m$n_test > 0)) item("Hold-out validation",
       sprintf("Households were split at random, stratified by the outcome so both parts keep the same share of vulnerable households: %s for fitting, %s held out (seed %s). ",
               format(m$n_train, big.mark = ","), format(m$n_test, big.mark = ","), m$seed),
       "Every error rate, AUC and chart of the threshold step is measured on the held-out households the model never saw, so they are not flattered by overfitting.")
    if (shiny::isTruthy(m$weights)) item("Survey weights",
       sprintf("Each household counted in the model by its sampling weight `%s`, normalised to a mean of 1 so the sample size, and therefore the standard errors, keep their scale.", m$weights))

    if ((m$stepwise %||% "none") %in% c("aic", "bic")) item(sprintf("Stepwise selection (%s, %s)", m$stepwise_dir %||% "backward", toupper(m$stepwise)),
       paste("Reference: Venables & Ripley (2002), *Modern Applied Statistics with S*, ch. 6. Before the model is fitted, the criteria go through",
             switch(m$stepwise_dir %||% "backward",
               forward = "**forward stepwise selection** on a logistic fit: starting from no criterion, the one whose addition lowers the information criterion most is added, one at a time, until no addition lowers it.",
               both = "**stepwise selection in both directions** on a logistic fit: starting from no criterion, criteria are added one at a time, and one added earlier is removed again whenever that lowers the information criterion, until no step lowers it.",
               "**backward stepwise selection** on a logistic fit: one at a time, the criterion whose removal lowers the information criterion most is dropped, until no removal lowers it."),
             "AIC = 2k - 2 log L; BIC = k log(n) - 2 log L, a heavier penalty per criterion, so BIC keeps fewer.",
             "The chosen model is then fitted on the criteria that remain, so every model can be made shorter the same way."))
    item(sprintf("Model: %s", m$method %||% ""), switch(m$method_code %||% "logit",
      logit = paste("Reference: Hosmer, Lemeshow & Sturdivant (2013), *Applied Logistic Regression*, 3rd ed. A **logistic regression** of the outcome on all kept criteria: log(p / (1 - p)) = b0 + b1 x1 + ... + bk xk, where p is the probability of being vulnerable and each x is 0/1. Each coefficient b is the change in log-odds when the criterion is met, **net of the other criteria**; exp(b) is its odds ratio. Standard errors and p-values come from the Wald test; the 95% interval is b +/- 1.96 SE."),
      stepwise = paste("Reference: Venables & Ripley (2002), *Modern Applied Statistics with S*, ch. 6. A logistic regression followed by **backward stepwise selection** on the Akaike Information Criterion (AIC = 2k - 2 log L): criteria are removed one at a time while doing so lowers the AIC, i.e. while the fit lost is smaller than the complexity saved. The result is a shorter card with the criteria that add information once the others are known."),
      woe = paste("Reference: Siddiqi (2017), *Intelligent Credit Scoring*, 2nd ed. **Weight of evidence**: each criterion's effect is its own log odds ratio against the outcome, log((a d) / (b c)) from its 2x2 table, with 0.5 added to every cell (Haldane correction) so empty cells stay finite. It never fails on separation or correlated criteria, but effects are not net of the other criteria, so overlapping criteria count twice."),
      rf = paste("References: Breiman (2001), *Machine Learning* 45; Molnar (2022), *Interpretable Machine Learning*. A **random forest** (ranger, 500 trees) of the outcome on the kept criteria. A forest has no coefficients, so each criterion's points are its **average marginal effect**: every household is scored with the criterion set to 1 and to 0, all else unchanged, and the mean difference in predicted log-odds is the criterion's effect. The card is additive; the interactions the forest captures are averaged out, and the held-out AUC shows what that costs."),
      xgb = paste("References: Chen & Guestrin (2016), XGBoost, KDD; Molnar (2022). **XGBoost** (gradient-boosted trees, depth 3, learning rate 0.1, 200 rounds). Points are the average marginal effects on the log-odds scale, computed as for the random forest."),
      svm = paste("References: Cortes & Vapnik (1995), *Machine Learning* 20; Molnar (2022). A **support vector machine** (radial kernel, Platt-scaled probabilities; trained on at most 3,000 households). Points are the average marginal effects on the log-odds scale, computed as for the random forest. An SVM optimises a class boundary rather than probabilities, so criteria that never move a household across it receive close to zero points."),
      nb = paste("Reference: Hastie, Tibshirani & Friedman (2009), *The Elements of Statistical Learning*, ch. 6. **Naive Bayes** (Laplace smoothing): the evidence of each criterion combined as if the criteria were independent given the outcome. Points are the average marginal effects on the log-odds scale, computed as for the random forest."),
      nnet = paste("Reference: Ripley (1996), *Pattern Recognition and Neural Networks*. A **neural network** with one hidden layer of 5 units and weight decay 0.01 (nnet). Points are the average marginal effects on the log-odds scale, computed as for the random forest."),
      stumps = paste("References: Friedman (2001), *Annals of Statistics* 29(5); Chen & Guestrin (2016), XGBoost, KDD. **Boosted stumps**: gradient boosting (xgboost, 300 rounds, learning rate 0.1) restricted to trees with a single split. With 0/1 criteria each tree depends on one criterion only, so the model is exactly additive; each criterion's effect is the difference in its contribution (SHAP value) between households that meet it and those that do not, on the log-odds scale."),
      ""))

    item(sprintf("From model to points: %s", m$scheme %||% ""), switch(m$scheme_code %||% "odds_ratio",
      odds_ratio = "Each criterion is worth its **odds ratio** exp(b), the APP-FA reference method. Inclusion criteria (OR > 1) add points, exclusion criteria (OR < 1) subtract theirs.",
      coefficient = "Each criterion is worth its **log-odds coefficient** |b|, so the score is the model's own linear predictor without the intercept; inclusion and exclusion criteria weigh symmetrically.",
      points = "Coefficients rescaled so the strongest criterion is worth **10 points**, rounded to whole numbers (minimum 1): points = round(10 |b| / max |b|).",
      equal = "Every inclusion criterion is worth **1 point** and every exclusion criterion subtracts 1; the model only decides which criteria are kept and their direction.",
      ""),
      " **Score** = sum of the points of the inclusion criteria a household meets, minus those of the exclusion criteria it meets, floored at zero.")

    if (!is.null(m$fit_stats)) item("Model fit",
       "AIC measures fit penalised for the number of criteria (lower is better when comparing fits on the same data). ",
       "**McFadden pseudo-R\u00b2** = 1 - log L(model) / log L(intercept only): the share of the outcome's uncertainty the criteria explain (0.2 to 0.4 is a good fit for this kind of model). ",
       "Values here: ", m$fit_stats, ".")
  }

  if (!is.null(x$comparison) && nrow(x$comparison)) item("Model comparison",
       "The scorecard's ranking was compared on the held-out households with a logistic model's probabilities, a **random forest** ",
       "(ranger, 300 trees) and **gradient boosting** (xgboost, depth 3, learning rate 0.1, 150 rounds) fitted on the same criteria. ",
       "The benchmarks are not used for targeting: they show how much accuracy the simple additive card gives up (Targeting Advisory 3/2025). ",
       "References: Breiman (2001), *Machine Learning* 45; Chen & Guestrin (2016), XGBoost, KDD.")

  item("ROC curve and AUC",
       "For every possible threshold, the **recall** (share of vulnerable households made eligible) is plotted against the **false-positive rate** ",
       "(share of not-vulnerable households made eligible). The **AUC** is the area under that curve: the probability that a randomly chosen ",
       "vulnerable household scores higher than a randomly chosen not-vulnerable one (0.5 = random, 1 = perfect).")

  item("Choosing the threshold",
       "Three helpers were available, all of which only move the threshold, which stays a programmatic decision (Targeting Advisory 3/2025): ",
       "**Minimise errors** picks the cut-point minimising the larger of the inclusion and exclusion errors (minimax), so neither is traded away for the other; ",
       "**Youden's J** picks the point maximising recall + specificity - 1 (Youden 1950, *Cancer* 3); ",
       "**Fit to caseload** picks the highest threshold at which no more than the given share of households is eligible. ",
       if (shiny::isTruthy(x$threshold_note)) paste0("Here: ", x$threshold_note) else "")

  item("Design errors and verdict",
       "On the evaluation households, eligibility (score above the threshold) is crossed with the outcome. ",
       "**Inclusion error** = eligible but not vulnerable / all eligible; **exclusion error** = vulnerable but not eligible / all vulnerable ",
       "(Targeting Advisory 2/2025; WFP Targeting OGN 2021, p. 59). Each is compared with the tolerance band ",
       sprintf("(%.0f%% - %.0f%%): below the lower bound is acceptable, above the upper bound calls for redesign, and the combination gives the verdict from the Advisory's decision table. ",
               100 * (x$tolerance[1] %||% .05), 100 * (x$tolerance[2] %||% .2)),
       "These are design errors, valid for direct household-level (Tier 1) assistance; implementation errors are measured separately on PDM data.")
  L
}

#' Captions of the report figures
#' @noRd
design_report_captions <- function() {
  c(vuln_area = "Vulnerable households by area", prevalence = "How common each criterion is", correlation = "Correlation between the selected variables",
    weights = "Points by criterion", comparison_roc = "ROC, held-out households",
    cluster_profiles = "Profiles: share of households meeting each criterion",
    rank_hist = "Ranking distribution (threshold marked)", households_map = "Households on the first two components",
    cov_area = "Share selected by area",
    pca_scree = "Variation explained by each axis (cumulative % on the right)", pca_circle = "Variables: correlation circle, axes 1 and 2",
    lda_structure = "Correlation of each criterion with the index",
    roc = "ROC curve with the chosen threshold", scores = "Score distribution by outcome",
    box = "Score by vulnerability", drivers = "What actually drives the score",
    met = "Criteria met, eligible vs not", coverage = "Coverage by criterion")
}

#' Write the report as one self-contained HTML file
#'
#' The Markdown is converted with commonmark (tables enabled). The charts are
#' billboarder widgets: their HTML is dropped in where the Markdown left a
#' placeholder, and the JavaScript and CSS they need are inlined once, so the
#' single file opens in any browser without a network, can be emailed or
#' filed, and prints the charts as vector graphics.
#' @noRd
write_design_report <- function(file, x, plots = list(), lang = "en") {
  md <- design_report_md(x, names(plots))
  if (length(x$variables_md)) md <- paste(c(md, x$variables_md), collapse = "\n")
  # Charts capped to the most relevant variables say so under their title.
  caps <- design_report_captions()
  for (k in names(plots)) {
    of <- attr(plots[[k]], "tw_of")
    if (!is.null(of)) caps[[k]] <- sprintf("%s (the %d most relevant of %d; all of them are in the Excel scorecard, sheet Report_tables)",
                                          caps[[k]] %||% k, of[["shown"]], of[["of"]])
  }
  nof <- isTRUE(x$no_outcome)
  report_write_page(
    file, md, plots, captions = caps, lang = lang,
    title = if (nof) "Vulnerability ranking report" else "Targeting design report",
    record = if (nof) "Vulnerability ranking record" else "Targeting design record",
    meta = c("Country office" = x$country_office %||% "",
             "Generated" = x$generated %||% format(Sys.time(), "%Y-%m-%d %H:%M"),
             "Status" = if (isTRUE(x$adopted)) "Adopted" else "Draft, not adopted",
             "Source" = x$source %||% "",
             "Areas covered" = x$areas %||% "All areas"),
    footer = "This record documents the design so it can be reviewed, reproduced and challenged.",
    blocks = list("@@RATIONALE@@" = sprintf('<div class="rich">%s</div>', rich_html(x$rationale)),
                  "@@RANK_CARDS@@" = if (nof) report_rank_cards(x, lang) else "",
                  "@@DIAGRAM@@" = diagram_svg(x$model$diagram, if (nof) "targeted" else "vulnerable"),
                  "@@ERRORS@@" = report_error_cards(x, lang),
                  "@@MATRIX@@" = report_error_matrix(x$errors, x$threshold, x$outcome, x$outcome_pos, lang)))
}

#' The design error matrix as in the app, in the report's neutral style
#'
#' Each cell: what it is, the count, and its share of the row and of all
#' households; totals on the right and at the bottom. The two error cells are
#' marked by their label in bold, not by colour.
#' @noRd
report_error_matrix <- function(e, threshold = NULL, outcome = NULL, outcome_pos = NULL, lang = "en",
                                row_title = "Scorecard decision", row_labels = c("Eligible", "Not eligible"),
                                col_title = "Outcome", col_value = outcome, col_labels = c("Vulnerable", "Not vulnerable")) {
  if (is.null(e) || is.null(e$n) || e$n == 0) return("")
  tr <- function(t) htmltools::htmlEscape(i18n_lookup(t, lang))
  esc <- function(t) htmltools::htmlEscape(t %||% "")
  num <- function(x) format(round(x), big.mark = ",")
  pct <- function(x, d) if (is.na(d) || d == 0) "\u2013" else sprintf("%.1f%%", 100 * x / d)
  n_elig <- e$correctly_included + e$included_not_in_need
  n_not <- e$excluded_in_need + e$correctly_excluded
  n_vuln <- e$correctly_included + e$excluded_in_need
  n_novuln <- e$included_not_in_need + e$correctly_excluded
  cell <- function(count, row_total, label, err = FALSE) sprintf(
    '<td class="%s"><div class="m-label">%s</div><div class="m-count">%s</div><div class="m-share">%s %s \u00b7 %s %s</div></td>',
    if (err) "m-cell m-err" else "m-cell", tr(label), num(count),
    pct(count, row_total), tr("of row"), pct(count, e$n), tr("of all"))
  tot <- function(x) sprintf('<td class="m-tot"><div class="m-count">%s</div><div class="m-share">%s</div></td>', num(x), pct(x, e$n))
  paste0(
    '<div class="err-matrix-wrap"><table class="err-matrix"><thead>',
    '<tr><th class="m-corner" rowspan="2">', tr(row_title), '</th>',
    '<th colspan="2">', tr(col_title), if (nzchar(col_value %||% "")) paste0(": <code>", esc(col_value), "</code>") else "", '</th>',
    '<th class="m-tot-head" rowspan="2">', tr("Total"), '</th></tr>',
    '<tr><th>', tr(col_labels[1]), if (nzchar(outcome_pos %||% "")) paste0('<div class="m-sub">', esc(outcome_pos), '</div>') else "",
    '</th><th>', tr(col_labels[2]), '</th></tr></thead><tbody>',
    '<tr><th class="m-row">', tr(row_labels[1]),
    if (!is.null(threshold)) sprintf('<div class="m-sub">%s > %s</div>', tr("score"), fmt5(threshold)) else "", '</th>',
    cell(e$correctly_included, n_elig, "Correctly included"),
    cell(e$included_not_in_need, n_elig, "Inclusion error", err = TRUE), tot(n_elig), '</tr>',
    '<tr><th class="m-row">', tr(row_labels[2]), '</th>',
    cell(e$excluded_in_need, n_not, "Exclusion error", err = TRUE),
    cell(e$correctly_excluded, n_not, "Correctly excluded"), tot(n_not), '</tr>',
    '<tr class="m-total"><th class="m-row">', tr("Total"), '</th>', tot(n_vuln), tot(n_novuln),
    sprintf('<td class="m-tot m-grand"><div class="m-count">%s</div></td>', num(e$n)), '</tr>',
    '</tbody></table></div>')
}

#' Write one self-contained HTML report page
#'
#' Shared by every report of the app (design, verification): Markdown body
#' converted with commonmark and translated; `@@FIG:a,b@@` placeholders become
#' charts side by side (billboarder widgets, or plain htmltools tags); other
#' `blocks` are raw HTML swapped for their placeholder paragraph; a table of
#' contents from the section headings; the WFP header band with the meta list
#' on the right. Scripts, stylesheets, the font and the logo are all inlined,
#' so the one file works offline and can be emailed or filed.
#' @param meta Named character vector shown in the header (empty values skipped;
#'   names and values pass through the translator).
#' @noRd
report_write_page <- function(file, md, plots = list(), captions = character(0), lang = "en",
                              title, record, meta = character(0), footer = "", blocks = list()) {
  # Every report names its country office, filled in here when a caller did
  # not pass it.
  co <- country_office_now()
  if (nzchar(co)) {
    if (!"Country office" %in% names(meta)) meta <- c("Country office" = co, meta)
    else if (!nzchar(meta[["Country office"]] %||% "")) meta[["Country office"]] <- co
  }
  # Charts side by side get the same height (the tallest one's): charts named
  # together in one placeholder ("@@FIG:a,b@@") and the charts of one raw
  # block (the monitoring report's paired items).
  groups <- c(
    lapply(regmatches(md, gregexpr("@@FIG:[A-Za-z0-9_,]+@@", md))[[1]],
           function(ph) strsplit(sub("^@@FIG:(.*)@@$", "\\1", ph), ",", fixed = TRUE)[[1]]),
    lapply(blocks, function(b) sub("^@@FIG:(.*)@@$", "\\1",
                                   regmatches(b, gregexpr("@@FIG:[A-Za-z0-9_]+@@", b))[[1]])))
  for (g in groups) {
    g <- intersect(g, names(plots))
    if (length(g) < 2) next
    h <- vapply(g, function(k) { v <- plots[[k]]$height; if (is.numeric(v) && length(v) == 1) v else NA_real_ }, numeric(1))
    if (all(is.na(h))) next
    for (k in g[!is.na(h)]) plots[[k]]$height <- max(h, na.rm = TRUE)
  }
  figs <- list(); deps <- list()
  for (nm in names(plots)) {
    r <- tryCatch(htmltools::renderTags(plots[[nm]]), error = function(e) NULL)
    if (is.null(r)) next
    figs[[nm]] <- r$html
    deps <- c(deps, r$dependencies)
  }
  body <- commonmark::markdown_html(i18n_translate_block(md, lang), extensions = TRUE)
  # The title lives in the header band.
  body <- sub("<h1>[^<]*</h1>\\s*", "", body)
  for (ph in names(blocks)) body <- gsub(sprintf("<p>%s</p>", ph), blocks[[ph]], body, fixed = TRUE)
  # Placeholders -> figures, side by side when several share a row.
  for (ph in unique(regmatches(body, gregexpr("@@FIG:[A-Za-z0-9_,]+@@", body))[[1]])) {
    keys <- intersect(strsplit(sub("^@@FIG:(.*)@@$", "\\1", ph), ",", fixed = TRUE)[[1]], names(figs))
    cells <- vapply(keys, function(k) sprintf(
      '<figure class="fig"><figcaption>%s</figcaption><div class="fig-body">%s</div></figure>',
      htmltools::htmlEscape(i18n_lookup(captions[k] %||% k, lang)), figs[[k]]), character(1))
    row <- if (length(keys)) sprintf('<div class="fig-row n%d">%s</div>', length(keys), paste(cells, collapse = "")) else ""
    body <- sub(sprintf("<p>%s</p>", ph), row, body, fixed = TRUE)
  }
  # Table of contents from the section headings, with anchors to jump to.
  heads <- regmatches(body, gregexpr("<h2>(.*?)</h2>", body, perl = TRUE))[[1]]
  toc <- ""
  if (length(heads)) {
    titles <- sub("^<h2>(.*)</h2>$", "\\1", heads, perl = TRUE)
    for (i in seq_along(heads)) body <- sub(heads[i], sprintf('<h2 id="sec-%d">%s</h2>', i, titles[i]), body, fixed = TRUE)
    toc <- paste0('<nav class="toc"><div class="toc-title">', i18n_lookup("Contents", lang), '</div><ol>',
                  paste(sprintf('<li><a href="#sec-%d">%s</a></li>', seq_along(titles), titles), collapse = ""),
                  '</ol></nav>')
  }
  esc <- function(v) htmltools::htmlEscape(as.character(v))
  tr <- function(v) esc(i18n_lookup(v, lang))
  meta <- meta[nzchar(meta)]
  co <- meta["Country office"]
  html <- paste0(
    '<!DOCTYPE html>\n<html lang="', if (identical(lang, "fr")) "fr" else "en", '"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    '<title>', tr(title), '</title>',
    '<style>', report_font_face(), design_report_css(), '</style>',
    report_inline_deps(deps), '</head><body>',
    '<header class="band"><div class="wrap band-inner">',
    '<div class="band-logo">', report_logo(), '</div>',
    '<div class="band-title"><div class="eyebrow">', "TargetWise", ' <span class="eyebrow-tag">', tr("Reaching the most vulnerable"), '</span></div>',
    '<h1>', tr(title), '</h1>',
    '<div class="sub">', if (!is.na(co)) paste0(esc(co), ' \u00b7 '), tr(record), '</div></div>',
    '<dl class="band-meta">',
    paste0('<dt>', vapply(names(meta), tr, character(1)), '</dt><dd>', vapply(meta, tr, character(1)), '</dd>', collapse = ""),
    '</dl></div></header>',
    '<div class="wrap layout">', toc, '<main>', body, '</main></div>',
    '<footer class="wrap">', tr("Generated"), ' ', esc(format(Sys.time(), "%Y-%m-%d %H:%M")), '. ', tr(footer), '</footer>',
    # Long tables show their first 10 rows and a button for the rest (all
    # rows are printed).
    '<script>(function(){document.querySelectorAll("main table:not(.bt)").forEach(function(t){',
    'var rows=t.tBodies.length?Array.from(t.tBodies[0].rows):[];if(rows.length<=12)return;',
    'rows.slice(10).forEach(function(r){r.classList.add("tw-more-row");});',
    'var b=document.createElement("button");b.className="tw-more-btn";b.type="button";',
    'var more="', tr("Show all"), ' "+rows.length+" ', tr("rows"), '",less="', tr("Show fewer"), '";b.textContent=more;',
    'b.addEventListener("click",function(){var open=b.getAttribute("data-open")==="1";',
    'rows.slice(10).forEach(function(r){r.style.display=open?"":"table-row";});',
    'b.setAttribute("data-open",open?"0":"1");b.textContent=open?more:less;});',
    't.parentNode.insertBefore(b,t.nextSibling);});})();</script>',
    '</body></html>')
  writeLines(enc2utf8(html), file, useBytes = TRUE)
  invisible(file)
}

#' The two design errors as highlighted cards
#'
#' Each shows the rate, where it falls against the tolerance band (a track
#' from 0 to 50% with the band's two bounds marked), and the counts behind it.
#' @noRd
#' One gauge card of a report: value, status pill, coloured zones with a
#' marker, scale ticks and a detail line
#'
#' @param zones Named numeric vector of zone upper bounds on the gauge's
#'   scale, in order, named by class ("ok", "warn", "bad").
#' @noRd
report_gauge_card <- function(label, v, band, state, sub, detail, icon = "", zones, max = 0.5, min = 0, ticks = NULL,
                              value_text = NULL, tick_fmt = function(t) sprintf("%s%%", round(100 * t))) {
  # A semicircle gauge drawn in SVG (works offline, prints): the zones as a
  # faint coloured track, the value as an arc in the verdict's colour, the
  # percentage in the middle, the zone limits around the arc.
  frac <- function(x) (base::min(base::max(x, min), max) - min) / (max - min)
  cx <- 110; cy <- 104; r <- 84
  pt <- function(f) c(cx - r * cos(pi * f), cy - r * sin(pi * f))
  arc <- function(f1, f2, col, w, op = 1) {
    if (f2 <= f1) return("")
    a <- pt(f1); b <- pt(f2)
    sprintf('<path d="M %.2f %.2f A %d %d 0 0 1 %.2f %.2f" fill="none" stroke="%s" stroke-width="%d" stroke-opacity="%.2f"/>',
            a[1], a[2], r, r, b[1], b[2], col, w, op)
  }
  zc <- c(ok = "#3f7e44", warn = "#d08a00", bad = "#c5192d", na = "#8a96a3")
  lo <- c(min, utils::head(unname(zones), -1))
  track <- paste(vapply(seq_along(zones), function(k)
    arc(frac(lo[k]), frac(unname(zones)[k]), zc[[names(zones)[k]]] %||% "#8a96a3", 16, 0.22), character(1)), collapse = "")
  val <- if (is.na(v)) "" else arc(0, base::max(frac(v), 0.004), zc[[band]] %||% "#1f2a37", 16)
  ticks <- sort(unique(c(min, ticks %||% utils::head(unname(zones), -1), max)))
  tick_txt <- paste(vapply(ticks, function(t) {
    q <- pt(frac(t)); qq <- c(cx + (q[1] - cx) * 1.2, cy + (q[2] - cy) * 1.2)
    sprintf('<text x="%.1f" y="%.1f" text-anchor="middle" class="g-tick">%s</text>', qq[1], qq[2] + 4, tick_fmt(t))
  }, character(1)), collapse = "")
  dial <- sprintf(paste0('<svg class="err-dial" viewBox="0 0 220 124" role="img" aria-label="%s">',
                         '%s%s%s<text x="%d" y="%d" text-anchor="middle" class="g-value">%s</text></svg>'),
                  htmltools::htmlEscape(label), track, val, tick_txt, cx, cy - 6,
                  value_text %||% (if (is.na(v)) "n/a" else sprintf("%.1f%%", 100 * v)))
  sprintf(paste0(
    '<div class="err-card is-%s">',
    '<div class="err-top"><span class="err-ico">%s</span><span class="err-label">%s</span><span class="err-pill">%s</span></div>',
    '%s<div class="err-sub err-sub-center">%s</div>',
    '<div class="err-detail">%s</div></div>'),
    band, icon, label, state, dial, sub, detail)
}

report_error_cards <- function(x, lang = "en") {
  e <- x$errors
  if (is.null(e)) return("")
  tr <- function(t) htmltools::htmlEscape(i18n_lookup(t, lang))
  tol <- x$tolerance %||% c(0.05, 0.20)
  # The gauge runs 0-50%: at 50% targeting is no better than chance.
  card <- function(label, v, num, den, what, icon) {
    band <- if (is.na(v)) "na" else if (v <= tol[1]) "ok" else if (v <= tol[2]) "warn" else "bad"
    state <- c(ok = "Within tolerance", warn = "In the review band", bad = "Beyond tolerance", na = "Not available")[[band]]
    report_gauge_card(tr(label), v, band, tr(state), tr(what),
                      sprintf("<strong>%s</strong> %s <strong>%s</strong> %s", format(num, big.mark = ","), tr("of"),
                              format(den, big.mark = ","), tr("households")),
                      icon, zones = c(ok = tol[1], warn = tol[2], bad = 0.5), max = 0.5)
  }
  # small inline icons (no icon font in the report)
  ico_in <- '<svg viewBox="0 0 16 16"><path d="M2 8h8M7 4.5 10.5 8 7 11.5M13 3v10" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  ico_out <- '<svg viewBox="0 0 16 16"><path d="M3 3v10M6 8h8M11 4.5 14.5 8 11 11.5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>'
  sel <- e$correctly_included + e$included_not_in_need
  need <- e$correctly_included + e$excluded_in_need
  paste0(
    '<div class="err-cards">',
    card("Inclusion error", e$inclusion_error, e$included_not_in_need, sel,
         "Selected households who did not need assistance", ico_in),
    card("Exclusion error", e$exclusion_error, e$excluded_in_need, need,
         "Households in need who were left out", ico_out),
    '</div>',
    sprintf('<p class="err-note">%s %.0f%%\u2013%.0f%%.%s</p>', tr("Tolerance band"), 100 * tol[1], 100 * tol[2],
            if (!is.null(x$verdict)) paste0(" <strong>", tr(x$verdict$interpretation), "</strong>") else ""))
}

#' Inline the scripts and stylesheets of the report's widgets
#' @noRd
report_inline_deps <- function(deps) {
  if (!length(deps)) return("")
  deps <- htmltools::resolveDependencies(deps)
  read <- function(d, f) {
    path <- file.path(d$src$file, f)
    if (!file.exists(path)) return("")
    paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }
  paste(unlist(lapply(deps, function(d) {
    css <- vapply(unlist(d$stylesheet), function(f) sprintf("<style>%s</style>", read(d, f)), character(1))
    js <- vapply(unlist(lapply(d$script, function(sc) if (is.list(sc)) sc$src else sc)),
                 function(f) sprintf("<script>%s</script>", gsub("</script", "<\\\\/script", read(d, f), fixed = TRUE)),
                 character(1))
    c(css, js)
  })), collapse = "\n")
}

#' Print-friendly stylesheet for the HTML report
#' @noRd
design_report_css <- function() {
  "
  :root { --blue:#0A6EB4; --ink:#1f2a37; --muted:#5b6b7e; --line:#dfe6ee; --tint:#f3f6fa; }
  .tw-figs { display: flex; flex-wrap: wrap; align-items: center; gap: 10px 18px; margin: 12px 0 22px; }
  .tw-figs:not(.tw-figs-cards) { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); }
  .tw-glance { border-left: 4px solid var(--blue); background: var(--tint); border-radius: 0 10px 10px 0; padding: 12px 18px; margin: 8px 0 18px; }
  .tw-glance ul { margin: 0; padding-left: 18px; } .tw-glance li { margin: 5px 0; line-height: 1.5; }
  .tw-meta { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 0 24px; margin: 8px 0 18px; }
  .tw-meta div { border-bottom: 1px solid var(--line); padding: 8px 0; }
  .tw-meta dt { font-size: 11px; text-transform: uppercase; letter-spacing: .04em; color: var(--muted); font-weight: 600; }
  .tw-meta dd { margin: 2px 0 0; font-size: 14px; }
  table.bt { width: 100%; border-collapse: collapse; margin: 8px 0 6px; font-size: 13px; }
  table.bt th { text-align: left; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; color: var(--muted); font-weight: 600; padding: 6px 8px; border-bottom: 2px solid var(--line); }
  table.bt td { padding: 5px 8px; border-bottom: 1px solid var(--line); vertical-align: middle; }
  table.bt .num { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
  table.bt tr.bt-group th { background: var(--tint); color: var(--ink); text-transform: none; letter-spacing: 0; font-size: 12px; border-bottom: 1px solid var(--line); padding-top: 8px; }
  table.bt .bt-label { width: 32%; }
  table.bt .bt-cell { width: 50%; }
  .bt-wrap { display: flex; align-items: center; gap: 10px; }
  .bt-track { position: relative; flex: 1; height: 12px; background: #eef2f6; border-radius: 6px; }
  .bt-bar { position: absolute; left: 0; top: 0; bottom: 0; border-radius: 6px; }
  .bt-mark { position: absolute; top: -3px; bottom: -3px; width: 0; border-left: 2px dashed var(--ink); opacity: .55; }
  .bt-val { width: 44px; text-align: right; font-weight: 600; font-variant-numeric: tabular-nums; }
  .bt-note { font-size: 12px; color: var(--muted); margin-bottom: 18px; }
  .bt-mark-key { display: inline-block; width: 0; height: 12px; border-left: 2px dashed var(--ink); opacity: .55; vertical-align: -2px; margin-right: 4px; }
  .tw-donut { width: 104px; text-align: center; color: var(--ink); }
  .tw-donut svg { display: block; margin: 0 auto; }
  .tw-donut-label { font-size: 12px; line-height: 1.2; color: var(--muted); margin-top: 3px; }
  .tw-figs .tw-tile { background: var(--tint); border-radius: 10px; padding: 8px 12px; min-width: 140px; }
  .tw-figs .tw-tile-label { font-size: 12px; color: var(--muted); }
  .tw-figs .tw-tile-value { font-size: 20px; font-weight: 700; }
  .tw-figs .tw-tile-sub { font-size: 11px; color: var(--muted); }
  * { box-sizing: border-box; }
  body { margin:0; font-family: Commissioner, 'Segoe UI', system-ui, sans-serif; color: var(--ink);
         font-size: 15px; line-height: 1.6; background: #fff; }
  .wrap { width: 80%; margin: 0 auto; padding: 0 12px; }
  .band-inner { display: grid; grid-template-columns: auto minmax(0, 1fr) auto; align-items: center; gap: 28px; }
  .band-logo { padding-right: 28px; border-right: 1px solid rgba(255,255,255,.35); display: flex; align-items: center; }
  .band-logo img { height: 58px; width: auto; display: block; margin: 0; border: 0; border-radius: 0; }
  .band-title .eyebrow .eyebrow-tag { font-weight: 500; opacity: .85; text-transform: none; letter-spacing: .02em; margin-left: 6px; }
  .band-title .eyebrow { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .12em; opacity: .8; }
  .band-title h1 { color: #fff; font-size: 30px; font-weight: 700; letter-spacing: -.02em; line-height: 1.15; margin: 4px 0 2px; }
  .band-meta { margin: 0; font-size: 12px; text-align: right; display: grid; grid-template-columns: auto auto; gap: 2px 10px; }
  .band-meta dt { opacity: .7; text-transform: uppercase; letter-spacing: .08em; font-size: 10.5px; align-self: center; }
  .band-meta dd { margin: 0; font-weight: 600; text-align: left; max-width: 260px; overflow-wrap: anywhere; }
  .err-cards { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; margin: 14px 0 8px; max-width: 720px; }
  /* Restrained: the status colour appears only as a thin left rule and the
     dot on the status label; the number, gauge and marker stay neutral. */
  .err-card { --c: #6c757d; position: relative; overflow: hidden;
    border: 0; border-radius: 8px; padding: 12px 16px 10px; background: var(--tint); }
  .err-card.is-ok { --c: #3f7e44; }
  .err-card.is-warn { --c: #b87700; }
  .err-card.is-bad { --c: #c5192d; }
  .err-top { position: relative; display: flex; align-items: center; gap: 10px; }
  .err-ico { width: 26px; height: 26px; border-radius: 7px; display: inline-flex; align-items: center; justify-content: center;
    background: var(--tint); color: var(--muted); flex: none; }
  .err-ico svg { width: 15px; height: 15px; }
  .err-label { font-size: 11.5px; font-weight: 700; text-transform: uppercase; letter-spacing: .07em; color: var(--muted); flex: 1; }
  .err-pill { display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; font-weight: 600; color: var(--ink);
    white-space: nowrap; }
  .err-pill::before { content: ''; width: 8px; height: 8px; border-radius: 50%; background: var(--c); }
  .err-value { position: relative; font-size: 28px; font-weight: 700; letter-spacing: -.02em; line-height: 1; margin: 10px 0 3px;
    color: var(--ink); font-variant-numeric: tabular-nums; }
  .err-sub { position: relative; font-size: 12px; color: var(--muted); margin-bottom: 24px; }
  .err-gauge { position: relative; height: 6px; margin: 0 2px; }
  .err-zones { display: flex; height: 100%; border-radius: 999px; overflow: hidden; background: #eef1f5; }
  .err-zones .z.ok { background: #eef1f5; } .err-zones .z.warn { background: #cfd6df; }
  .err-zones .z.bad { background: #eef1f5; }
  .err-gauge .mk { position: absolute; top: 50%; width: 14px; height: 14px; margin: -7px 0 0 -7px; border-radius: 50%;
    background: #fff; border: 3px solid var(--ink); }
  .err-gauge .mk em { position: absolute; bottom: 18px; left: 50%; transform: translateX(-50%); font-style: normal;
    font-size: 11px; font-weight: 700; color: var(--ink); white-space: nowrap; }
  .err-scale { position: relative; height: 16px; margin: 6px 2px 0; font-size: 10.5px; color: var(--muted); font-variant-numeric: tabular-nums; }
  .err-scale span { position: absolute; transform: translateX(-50%); }
  .err-scale span:first-child { transform: none; } .err-scale span:last-child { transform: translateX(-100%); }
  .err-dial { display: block; width: 100%; max-width: 250px; margin: 6px auto 0; overflow: visible; }
  .err-dial .g-value { font-size: 26px; font-weight: 700; fill: var(--ink); font-variant-numeric: tabular-nums; }
  .err-dial .g-tick { font-size: 10px; fill: var(--muted); }
  .err-sub-center { text-align: center; margin-bottom: 6px; }
  .err-detail { position: relative; font-size: 12px; color: var(--muted); margin-top: 8px; padding-top: 8px; border-top: 1px solid rgba(15,40,70,.08); }
  .kpis { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin: 14px 0 10px; }
  .kpi { background: var(--tint); border-radius: 8px; padding: 12px 14px; }
  .kpi-label { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); }
  .kpi-value { font-size: 26px; font-weight: 700; color: var(--ink); line-height: 1.2; margin-top: 4px; font-variant-numeric: tabular-nums; }
  .kpi-sub { font-size: 12px; color: var(--muted); }
  .fig .leaflet-container { border-radius: 6px; }
  /* The map is 3 high for 5 wide, whatever the page width. */
  .fig .leaflet.html-widget { aspect-ratio: 5 / 3; height: auto !important; max-height: 90vh; }
  .ptiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 12px; margin: 12px 0 16px; }
  .ptile { display: flex; gap: 12px; align-items: center; background: var(--tint); border-radius: 8px; padding: 12px 14px; }
  .ptile-ico { flex: none; width: 44px; height: 44px; border-radius: 50%; background: var(--blue); display: flex; align-items: center; justify-content: center; }
  .ptile-ico svg { width: 26px; height: 26px; fill: #fff; }
  .ptile-value { font-size: 22px; font-weight: 700; line-height: 1.1; color: var(--ink); font-variant-numeric: tabular-nums; }
  .ptile-label { font-size: 12px; font-weight: 600; color: var(--ink); }
  .ptile-sub { font-size: 11.5px; color: var(--muted); }
  .err-matrix-wrap { overflow-x: auto; margin: 10px 0 12px; }
  .area-sum-wrap { overflow-x: auto; margin: 8px 0 14px; }
  .area-sum { border-collapse: collapse; width: 100%; font-size: 12px; font-variant-numeric: tabular-nums; }
  .area-sum th, .area-sum td { padding: 3px 8px; border-bottom: 1px solid var(--line); line-height: 1.35; white-space: nowrap; }
  .area-sum th { background: var(--tint); font-size: 10.5px; text-transform: uppercase; letter-spacing: .04em; color: var(--muted); text-align: left; }
  .area-sum .num { text-align: right; }
  .area-sum tr.a-unit td:first-child { padding-left: 22px; color: var(--ink); }
  .area-sum tr.a-group td { background: #eef3f9; font-weight: 700; border-top: 1px solid #c9d3de; }
  .area-sum tr.a-total td { background: #dfe8f2; font-weight: 700; border-top: 2px solid #9fb2c8; }
  .err-matrix { border-collapse: collapse; width: 100%; max-width: 760px; font-size: 13px; font-variant-numeric: tabular-nums; }
  .err-matrix th, .err-matrix td { border: 1px solid var(--line); padding: 8px 12px; text-align: left; vertical-align: top; }
  .err-matrix thead th { background: var(--tint); font-size: 11.5px; font-weight: 700; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); }
  .err-matrix th.m-row { background: #fff; font-weight: 600; color: var(--ink); white-space: nowrap; }
  .err-matrix .m-corner { vertical-align: bottom; }
  .err-matrix .m-sub { font-size: 11px; font-weight: 400; color: var(--muted); text-transform: none; letter-spacing: 0; }
  .err-matrix .m-label { font-size: 11.5px; color: var(--muted); }
  .err-matrix .m-err .m-label { color: var(--ink); font-weight: 700; }
  .err-matrix .m-count { font-size: 18px; font-weight: 700; color: var(--ink); line-height: 1.3; }
  .err-matrix .m-share { font-size: 11px; color: var(--muted); }
  .err-matrix .m-tot { background: var(--tint); }
  .tw-diagram { overflow-x: auto; margin: 12px 0 22px; }
  .err-matrix tr.m-total th, .err-matrix tr.m-total td { border-top: 2px solid #c9d3de; }
  .err-detail strong { color: var(--ink); font-weight: 700; }
  .err-note { font-size: 13px; color: var(--muted); margin: 8px 0 18px; }
  .err-note strong { color: var(--ink); font-weight: 600; }
  @media print { .err-card { -webkit-print-color-adjust: exact; print-color-adjust: exact; } }
  .fig-row { display: grid; gap: 18px; margin: 16px 0 26px; }
  .pair { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 22px; margin: 8px 0 22px; align-items: start; }
  .pair-cell h3 { margin-top: 6px; }
  .pair-cell .fig-row { margin: 8px 0 10px; }
  .pair-cell table { font-size: 12.5px; }
  .pair-cell .note { font-size: 12px; color: var(--muted); margin: 4px 0; }
  @media (max-width: 900px) { .pair { grid-template-columns: 1fr; } }
  .fig-body { overflow-x: auto; }
  .tw-more-row { display: none; }
  .tw-more-btn { margin: 4px 0 14px; padding: 4px 12px; border: 1px solid #c9d6e3; border-radius: 6px; background: #fff; color: #0A6EB4; font: inherit; font-size: 12.5px; cursor: pointer; }
  .tw-more-btn:hover { background: #f1f6fb; }
  @media print { .tw-more-row { display: table-row !important; } .tw-more-btn { display: none; } }
  .fig-row.n2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .fig-row.n3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
  .rich { margin: 0 0 14px; padding: 8px 14px; border-left: 3px solid #0A6EB4; background: #f6f9fc; border-radius: 0 8px 8px 0; }
  .rich p, .rich div { margin: 0 0 6px; } .rich h3, .rich h4 { margin: 6px 0; } .rich ul, .rich ol { margin: 0 0 6px; }
  .fig { margin: 0; padding: 6px 4px 4px; border: 0; background: transparent; }
  .fig figcaption:empty { display: none; }
  .fig figcaption { text-align: left; color: var(--ink); font-weight: 600; font-size: 13px; margin-bottom: 6px; }
  .fig .bb text { font-family: Commissioner, 'Segoe UI', sans-serif; fill: #3c4a5c; }
  .fig .bb .bb-chart-arc text { fill: #fff; font-weight: 600; }
  .fig .bb-legend-item text { font-size: 12px; }
  .corr-wrap { overflow-x: auto; }
  table.corr { width: auto; margin: 4px 0; font-size: 12px; }
  table.corr th, table.corr td { padding: 4px 5px; border: 0; text-align: center; font-size: 11px; }
  table.corr thead th { background: none; vertical-align: bottom; height: 110px; }
  table.corr thead th span { writing-mode: vertical-rl; transform: rotate(180deg); white-space: nowrap; text-transform: none; letter-spacing: 0; }
  table.corr th.rh { background: none; text-align: right; text-transform: none; letter-spacing: 0; color: var(--ink); font-size: 11px;
                     max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  table.corr td { min-width: 36px; border-radius: 4px; font-variant-numeric: tabular-nums; }
  table.corr td.blank { background: none; }
  .layout { display: grid; grid-template-columns: 240px minmax(0, 1fr); gap: 36px; align-items: start; }
  .toc { position: sticky; top: 16px; margin-top: 28px; padding: 14px 16px; background: var(--tint);
         border: 1px solid var(--line); border-radius: 10px; font-size: 13px; }
  .toc-title { font-weight: 700; text-transform: uppercase; letter-spacing: .06em; font-size: 11px; color: var(--muted); margin-bottom: 6px; }
  .toc ol { margin: 0; padding-left: 0; list-style: none; } .toc li { margin: 4px 0; }
  .toc a { color: var(--ink); text-decoration: none; } .toc a:hover { color: var(--blue); }
  h2 { scroll-margin-top: 16px; }
  @media (max-width: 900px) { .wrap { width: auto; } .layout { grid-template-columns: 1fr; } .toc { position: static; }
    .fig-row.n2, .fig-row.n3, .err-cards { grid-template-columns: 1fr; } .band-inner { grid-template-columns: 1fr; } .band-logo { border: 0; padding: 0; } .band-meta { text-align: left; } }
  .band { background: var(--blue); color: #fff; padding: 26px 0; }
  .sub { opacity: .85; font-size: 13px; }
  main { padding-top: 12px; }
  h1 { font-size: 30px; letter-spacing: -.02em; margin: 26px 0 4px; }
  h2 { font-size: 20px; color: var(--blue); margin: 36px 0 10px; padding-bottom: 6px; border-bottom: 1px solid var(--line); }
  h3 { font-size: 15px; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); margin: 24px 0 8px; }
  p, li { color: var(--ink); }
  em { color: var(--muted); }
  code { background: var(--tint); padding: 1px 5px; border-radius: 4px; font-size: 13px; }
  blockquote { margin: 10px 0; padding: 10px 14px; background: var(--tint); border-left: 3px solid var(--blue); border-radius: 0 6px 6px 0; }
  table { border-collapse: collapse; width: 100%; margin: 8px 0 16px; font-size: 12.5px; font-variant-numeric: tabular-nums; }
  th { background: var(--tint); color: var(--muted); text-align: left; font-size: 11px; text-transform: uppercase;
       letter-spacing: .05em; padding: 5px 10px; border-bottom: 1px solid var(--line); }
  td { padding: 3px 10px; line-height: 1.4; border-bottom: 1px solid var(--line); }
  tr:last-child td { border-bottom: 0; }
  img { display: block; max-width: 100%; margin: 12px auto 22px; border: 1px solid var(--line); border-radius: 8px; }
  figure img { width: 100%; max-width: 860px; }
  figure { margin: 14px 0 24px; } figure img { margin: 0 auto 6px; }
  figcaption { text-align: center; color: var(--muted); font-size: 12px; }
  footer { color: var(--muted); font-size: 12px; padding: 28px 28px 40px; border-top: 1px solid var(--line); margin-top: 36px; }
  @media print { .wrap { width: auto; } .layout { display: block; } .toc { position: static; page-break-after: always; }
                 .band { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
                 h2 { page-break-after: avoid; } img, table, .fig { page-break-inside: avoid; } }
  "
}


#' The bundled font, embedded so the report is fully self-contained offline
#' @noRd
report_font_face <- function() {
  f <- app_sys("app/www/fonts/commissioner-latin.woff2")
  if (!nzchar(f) || !file.exists(f)) return("")
  b64 <- gsub("[\r\n]", "", jsonlite::base64_enc(readBin(f, "raw", file.info(f)$size)))
  sprintf('@font-face { font-family: Commissioner; font-weight: 300 800; src: url(data:font/woff2;base64,%s) format("woff2"); }', b64)
}


#' The WFP logo (white, for the blue header band), embedded as base64
#' @noRd
report_logo <- function() {
  f <- app_sys("app/www/wfp-logo-standard-white-en.png")
  if (!nzchar(f) || !file.exists(f)) return("")
  b64 <- gsub("[\r\n]", "", jsonlite::base64_enc(readBin(f, "raw", file.info(f)$size)))
  sprintf('<img src="data:image/png;base64,%s" alt="WFP">', b64)
}

#' Key results of a vulnerability ranking: selection, stability, consistency
#' and concentration, as gauge cards
#' @noRd
report_rank_cards <- function(x, lang = "en") {
  tr <- function(t) htmltools::htmlEscape(i18n_lookup(t, lang))
  st <- x$stability; si <- x$insights; a <- x$index$alpha %||% NA_real_
  band_hi <- function(v, bad, warn) if (is.na(v)) "na" else if (v < bad) "bad" else if (v < warn) "warn" else "ok"
  cards <- c(
    report_gauge_card(tr("Households selected"), x$selected$share %||% NA_real_, "ok", tr("Programme decision"),
                      tr("Selected above the threshold"),
                      sprintf("<strong>%s</strong> %s", format(x$selected$n %||% NA, big.mark = ","), tr("households")),
                      "", zones = c(ok = 1), max = 1),
    report_gauge_card(tr("Stability of the selection"), st$jaccard %||% NA_real_, band_hi(st$jaccard %||% NA, .5, .85),
                      tr(if (is.null(st)) "Not checked" else local({ w <- stability_word(st$jaccard); paste0(toupper(substr(w, 1, 1)), substring(w, 2)) })),
                      tr("Same households selected across resamples"),
                      if (is.null(st)) tr("Run the stability check") else sprintf("%s %d %s", tr("median of"), st$draws, tr("refits")),
                      "", zones = c(bad = .5, warn = .85, ok = 1), max = 1),
    report_gauge_card(tr("Internal consistency"), if (is.na(a)) NA_real_ else max(0, a), band_hi(a, .5, .7),
                      tr("Cronbach's alpha"), tr("How far the criteria measure one thing"),
                      if (is.na(a)) "n/a" else sprintf("alpha <strong>%.2f</strong>", a),
                      "", zones = c(bad = .5, warn = .7, ok = 1), max = 1,
                      value_text = if (is.na(a)) "n/a" else sprintf("%.2f", a), tick_fmt = function(t) sprintf("%.1f", t)),
    if (!is.null(si)) report_gauge_card(tr("Deprivations held by the selected"), si$concentration, "ok",
                      sprintf("%.1f x", si$ratio), tr("Share of all deprivations"),
                      sprintf("%s %.0f%% %s", tr("by the"), 100 * si$share, tr("of households selected")),
                      "", zones = c(ok = 1), max = 1))
  paste0('<div class="err-cards">', paste(cards, collapse = ""), '</div>')
}
