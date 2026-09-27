demo <- function() utils::read.csv(system.file("extdata", "assessment_demo.csv", package = "TargetWise"), stringsAsFactors = FALSE)
crit5 <- c("Targ_HHNoLight", "Targ_HHDepRatio2plus", "Targ_HHRemittance", "Targ_HHHousingTent", "Targ_HHOwnCattle2more")

test_that("every no-outcome method gives an additive card that ranks the vulnerable higher", {
  df <- demo()
  y <- TargetWise:::as_binary_outcome(df$FSI_CARI2_2class, "Food insecure")
  for (m in TargetWise:::unsupervised_model_choices()) {
    f <- TargetWise:::fit_unsupervised(df, crit5, m, anchor = "Targ_HHHousingTent", k = 3, seed = 1)
    expect_true(isTRUE(f$unsupervised), info = m)
    expect_true(all(f$weights$weight >= 0), info = m)
    if (m != "count") expect_equal(max(abs(f$weights$coefficient)), 10, info = m)
    sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(f$weights))$score
    expect_length(sc, nrow(df))
  }
  cnt <- TargetWise:::fit_unsupervised(df, crit5, "count")
  expect_true(all(cnt$weights$weight == 1))
  expect_true(is.finite(cnt$index$alpha))
})

test_that("with criteria that share a vulnerability signal, every ranking finds it", {
  # the outcome is only used to check, never to fit
  set.seed(11)
  n <- 1500
  v <- stats::rnorm(n)
  df <- as.data.frame(stats::setNames(lapply(1:6, function(j) ifelse(stats::runif(n) < stats::plogis(1.8 * v - 0.3 + j / 10), "Yes", "No")),
                                      paste0("d", 1:6)))
  y <- as.integer(v > 0.5)
  for (m in TargetWise:::unsupervised_model_choices()) {
    f <- TargetWise:::fit_unsupervised(df, names(df), m, anchor = "d1", k = 3, seed = 1)
    sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(f$weights))$score
    expect_gt(TargetWise:::roc_curve(sc, y)$auc, 0.75, label = m)
    if (identical(f$index$type, "cluster")) expect_gt(f$index$fidelity, 0.8, label = m)
  }
})

test_that("an index is turned towards the anchor criterion", {
  df <- demo()
  for (m in c("pca", "mca")) {
    f <- TargetWise:::fit_unsupervised(df, crit5, m, anchor = "Targ_HHOwnCattle2more")
    w <- f$weights
    expect_equal(w$direction[w$criterion == "Targ_HHOwnCattle2more"], "inclusion", info = m)
  }
})

test_that("cluster methods find profiles, rank them and reproduce the targeted ones", {
  df <- demo()
  for (m in TargetWise:::cluster_methods()) {
    f <- TargetWise:::fit_unsupervised(df, crit5, m, anchor = "Targ_HHHousingTent", k = 3, seed = 2)
    ix <- f$index
    expect_equal(ix$type, "cluster")
    expect_equal(ix$k, 3)
    expect_equal(sum(ix$size), 1, tolerance = 1e-9)
    expect_equal(dim(ix$profiles), c(5, 3))
    expect_equal(ix$target, ix$rank[1])                               # the most vulnerable by default
    # the points separate the targeted profile from the others
    sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(f$weights))$score
    expect_true(ix$fidelity > 0.5 && ix$fidelity <= 1, label = m)   # reported to the analyst
    # another choice of profiles changes the points
    f2 <- TargetWise:::fit_unsupervised(df, crit5, m, anchor = "Targ_HHHousingTent", k = 3, seed = 2, target = ix$rank[2])
    expect_false(isTRUE(all.equal(f$weights, f2$weights)))
  }
  expect_error(TargetWise:::profile_points(matrix(c(0, 1), 2), c(1, 1), c(TRUE, TRUE)), "not none or all")
})

test_that("latent class EM recovers two clear groups", {
  set.seed(5)
  g <- rep(1:2, each = 300)
  M <- sapply(1:6, function(j) rbinom(600, 1, ifelse(g == 1, 0.85, 0.15)))
  fit <- TargetWise:::lca_fit(M, rep(1, 600), 2, seed = 1)
  agree <- max(mean(fit$assign == g), mean(fit$assign != g))
  expect_gt(agree, 0.95)
})

test_that("stability, starting threshold and consistency behave", {
  df <- demo()
  st <- TargetWise:::selection_stability(df, crit5, "pca", share = 0.3, anchor = "Targ_HHHousingTent", B = 8)
  expect_true(st$jaccard > 0 && st$jaccard <= 1)
  expect_equal(st$draws, 8)
  expect_match(TargetWise:::stability_word(0.9), "stable")
  cnt <- TargetWise:::fit_unsupervised(df, crit5, "count")
  sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(cnt$weights))$score
  expect_equal(TargetWise:::unsupervised_start_threshold(cnt, sc), 5 / 3 - 1e-9)
  p <- TargetWise:::fit_unsupervised(df, crit5, "pca", anchor = "Targ_HHHousingTent")
  sp <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(p$weights))$score
  t <- TargetWise:::unsupervised_start_threshold(p, sp)
  expect_lte(mean(sp > t), 0.3)
  M <- cbind(a = rep(0:1, 50), b = rep(0:1, 50))
  expect_equal(TargetWise:::cronbach_alpha(M), 1)
})

test_that("Targeting Design runs end to end without an outcome indicator", {
  df <- demo()
  setup <- shiny::reactiveValues()
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = setup,
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(df)
    session$setInputs(framework_mode = "none", rank_label = "Vulnerability after the floods")
    expect_true(no_outcome())
    res <- screened()
    expect_false(is.null(res))
    expect_true(all(is.na(res$prev_vuln)))                              # nothing tested
    expect_null(qs_result())
    id <- function(k, x) paste0("rv", k, "_", gsub("[^A-Za-z0-9]", "_", x))
    do.call(session$setInputs, stats::setNames(as.list(res$criterion %in% crit5), id("use", res$criterion)))
    session$setInputs(nav_next_screening = 1)
    expect_setequal(ready_criteria(), crit5)
    session$setInputs(split_seed = 1, params_apply = 1)   # the settings dialog
    session$setInputs(model_method = "kmeans", anchor = "Targ_HHHousingTent")
    session$setInputs(n_clusters = 3, params_apply = 2)                 # the settings dialog
    expect_equal(model_params$n_clusters, 3)
    session$setInputs(run_fit = 1)
    f <- fitted()
    expect_true(isTRUE(f$unsupervised))
    expect_equal(f$index$type, "cluster")
    # target two profiles instead
    tg <- f$index$rank[1:2]
    do.call(session$setInputs, stats::setNames(as.list(seq_len(3) %in% tg), paste0("tgt_", seq_len(3))))
    session$setInputs(cluster_apply = 1)
    expect_setequal(fitted()$index$target, tg)
    session$setInputs(threshold = unsupervised_start_threshold(fitted(), scored()$score))
    expect_true(any(grepl("rationale for the ranking", missing_steps())))
    session$setInputs(tol_rationale = "<p>Profiles agreed with the cluster; verification sample planned.</p>")
    expect_length(missing_steps(), 0)
    session$setInputs(nav_adopt = 1)
    expect_false(is.null(setup$scorecard))                              # no tolerance check without errors
    h <- paste(readLines(output$download_report, warn = FALSE), collapse = "\n")
    expect_match(h, "Purpose of the ranking", fixed = TRUE)
    expect_match(h, "Validity without an outcome", fixed = TRUE)
    expect_match(h, "Household profiles", fixed = TRUE)
    expect_match(h, "not measured", fixed = TRUE)
    wb <- openxlsx::loadWorkbook(output$download)
    expect_true(length(openxlsx::sheets(wb)) > 0)
    session$setInputs(model_method = "count", run_fit = 2)
    expect_equal(fitted()$method, "count")
    expect_true(all(current_weights()$weight == 1))
  })
})

test_that("profile quality, concentration and rank stability measure what they say", {
  set.seed(5)
  g <- rep(1:2, each = 300)
  M <- sapply(1:6, function(j) rbinom(600, 1, ifelse(g == 1, 0.9, 0.1)))
  expect_gt(TargetWise:::silhouette_mean(M, g), 0.3)
  expect_lt(TargetWise:::silhouette_mean(M, sample(g)), 0.05)       # random profiles: no separation
  f <- TargetWise:::lca_fit(M, rep(1, 600), 2, seed = 1)
  expect_gt(TargetWise:::lca_entropy(f$posterior), 0.8)
  df <- as.data.frame(ifelse(M == 1, "Yes", "No")); names(df) <- paste0("c", 1:6)
  q <- TargetWise:::profile_quality(df, names(df), "lca", ks = 2:4, seed = 1)
  expect_equal(q$k, 2:4)
  expect_equal(which.max(q$silhouette), 1)                            # two profiles is right here
  fit <- TargetWise:::fit_unsupervised(df, names(df), "count")
  sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(fit$weights, threshold = 3))
  si <- TargetWise:::selection_insights(df, fit$weights, sc$eligible)
  expect_gt(si$ratio, 3)
  expect_gt(si$concentration, si$share)
  st <- TargetWise:::selection_stability(df, names(df), "count", share = 0.5, B = 5)
  expect_gt(st$spearman, 0.9)
})

test_that("a ranking says what it is in its card, workbook and report", {
  df <- demo()
  f <- TargetWise:::fit_unsupervised(df, crit5, "count")
  sc <- TargetWise:::build_scorecard(f$weights, outcome = NULL, threshold = 1, kind = "ranking")
  expect_true(TargetWise:::is_ranking(sc))
  expect_equal(TargetWise:::card_word(sc), "vulnerability ranking")
  expect_false(TargetWise:::is_ranking(TargetWise:::build_scorecard(f$weights)))
  wb <- TargetWise:::scorecard_workbook(sc, meta = list(Outcome = "none: households ranked without an outcome indicator"))
  tmp <- tempfile(fileext = ".xlsx"); openxlsx::saveWorkbook(wb, tmp)
  expect_equal(openxlsx::read.xlsx(tmp, "How to read", colNames = FALSE)[1, 1], "Vulnerability ranking")
  back <- TargetWise:::read_scorecard_workbook(tmp)
  expect_true(TargetWise:::is_ranking(back))                          # read back as a ranking
  md <- TargetWise:::design_report_md(list(no_outcome = TRUE, rank_label = "Floods", selected = list(n = 10, share = 0.1)))
  expect_match(md, "# Vulnerability ranking report", fixed = TRUE)
  expect_match(md, "## 2. Purpose of the ranking", fixed = TRUE)
  expect_match(md, "### Why a ranking", fixed = TRUE)
  expect_false(grepl("Vulnerability Framework", md, fixed = TRUE))
})

test_that("a ranking's errors can be measured once data carry an outcome", {
  set.seed(8)
  v <- rnorm(800); y <- as.integer(v > 0.3)
  score <- pmax(0, 2 * v + rnorm(800, 0, 0.8) + 2)
  cal <- TargetWise:::ranking_calibration(score, y, threshold = 2)
  expect_gt(cal$auc, 0.85)
  expect_true(cal$current$inclusion_error >= 0 && cal$current$inclusion_error <= 1)
  expect_false(is.na(cal$balanced$threshold))
  expect_error(TargetWise:::ranking_calibration(score, rep(1L, 800), 2), "one level")
})

test_that("without an anchor, more criteria met means more vulnerable", {
  df <- demo()
  for (m in c("pca", "mca", "kmeans")) {
    f <- TargetWise:::fit_unsupervised(df, crit5, m, anchor = "", k = 3, seed = 1)
    expect_true(is.na(f$index$anchor), info = m)
    sc <- TargetWise:::apply_scorecard(df, TargetWise:::build_scorecard(f$weights))$score
    met <- rowSums(TargetWise:::index_matrix(df, crit5))
    if (m != "kmeans") expect_gt(stats::cor(sc, met), 0)
  }
  expect_equal(TargetWise:::anchor_text(NA_character_), "the number of criteria met")
  expect_equal(TargetWise:::anchor_text("x"), "x")
})

test_that("the stability check leaves out refits that fail instead of stopping", {
  set.seed(4)
  n <- 300
  df <- data.frame(a = ifelse(runif(n) < 0.4, "Yes", "No"),
                   b = c("Yes", rep("No", n - 1)))                    # one household only: often constant in a resample
  st <- TargetWise:::selection_stability(df, c("a", "b"), "pca", share = 0.3, B = 10)
  expect_true(st$draws < 10)                                          # some refits failed and were left out
  expect_true(st$draws == 0 || (st$jaccard >= 0 && st$jaccard <= 1))
})

test_that("an adopted ranking tells Beneficiary Selection each household's rank, deprivations and profile", {
  df <- demo()
  f <- TargetWise:::fit_unsupervised(df, crit5, "kmeans", k = 3, seed = 2)
  sc <- TargetWise:::build_scorecard(f$weights, outcome = NULL, threshold = 2, kind = "ranking")
  sc$ranking <- list(label = "Floods", method = "k-means clusters", oriented_by = "the number of criteria met",
                     stability = 0.8, profiles = f$index$profiles, target = f$index$target)
  dep <- TargetWise:::ranking_deprivations(df, sc)
  expect_length(dep, nrow(df))
  expect_true(all(dep >= 0 & dep <= length(sc$items)))
  pr <- TargetWise:::ranking_profile_assign(df, sc)
  expect_true(all(pr %in% seq_len(3)))
  # on the data they were built on, most households land in their own profile
  expect_gt(mean(pr == f$index$assign), 0.8)
  score <- TargetWise:::apply_scorecard(df, sc)$score
  cols <- TargetWise:::ranking_columns(df, sc, score)
  expect_setequal(names(cols), c("priority_rank", "deprivations", "ranking_profile"))
  expect_equal(cols$priority_rank[which.max(score)], 1)
  expect_true(any(grepl("(targeted)", cols$ranking_profile, fixed = TRUE)))
  # a scorecard adds nothing
  expect_null(TargetWise:::ranking_columns(df, TargetWise:::build_scorecard(f$weights), score))
})

test_that("without an outcome, a decision tree describes the targeted profiles in rules", {
  skip_if_not_installed("rpart")
  expect_true("tree" %in% TargetWise:::unsupervised_model_choices())
  set.seed(11)
  n <- 1200
  v <- stats::rnorm(n)
  df <- as.data.frame(stats::setNames(lapply(1:6, function(j) ifelse(stats::runif(n) < stats::plogis(1.8 * v - 0.3 + j / 10), "Yes", "No")),
                                      paste0("d", 1:6)))
  f <- TargetWise:::fit_unsupervised(df, names(df), "tree", k = 3, seed = 1)
  ix <- f$index
  expect_equal(ix$type, "cluster")
  expect_equal(ix$algorithm, "tree")
  rl <- f$tree_rules
  expect_true(nrow(rl) >= 2)
  expect_true(all(grepl("= (yes|no)", rl$rule)))
  expect_gt(ix$fidelity, 0.8)                                         # the rules reproduce the profiles
  # another choice of profiles, other rules
  f2 <- TargetWise:::fit_unsupervised(df, names(df), "tree", k = 3, seed = 1, target = ix$rank[2])
  expect_false(identical(f$tree_rules$rule, f2$tree_rules$rule))
  expect_match(TargetWise:::cluster_algorithm_label("tree"), "decision tree")
})

test_that("without an outcome only names and identifiers are blocked", {
  expect_true(TargetWise:::is_identification_col("_uuid"))
  expect_true(TargetWise:::is_identification_col("respondent_name"))
  expect_true(TargetWise:::is_identification_col("start"))
  expect_false(TargetWise:::is_identification_col("start_business_Bin"))
  expect_false(TargetWise:::is_identification_col("Targ_HHNoLight"))
  df <- data.frame(FCS_poor = rep(c("Yes", "No"), 50), expenditure_high = rep(c("No", "Yes"), 50),
                   hh_id = rep(c(1, 0), 50), tent = rep(c("Yes", "No", "No", "Yes"), 25))
  strict <- TargetWise:::criterion_blockers(df, names(df), "", strict = TRUE)
  loose <- TargetWise:::criterion_blockers(df, names(df), "", strict = FALSE)
  expect_true(all(c("FCS_poor", "hh_id") %in% names(strict)))
  expect_setequal(names(loose), "hh_id")                            # only the identifier
  expect_match(loose[["hh_id"]], "identification")
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new()), {
    assessment_df(demo())
    session$setInputs(framework_mode = "none")
    expect_true("FSI_CARI2_2class" %in% screened()$criterion)     # an outcome indicator may rank
    session$setInputs(framework_mode = "outcome")
    expect_false("FSI_CARI2_2class" %in% eligible_criteria())
  })
})

test_that("the analyst can allow a blocked column back, and it is recorded", {
  log <- shiny::reactiveVal(data.frame(timestamp = character(0), uid = character(0), column = character(0), old_value = character(0),
                                       new_value = character(0), action = character(0), user = character(0), reason = character(0)))
  shiny::testServer(TargetWise:::mod_scorecard_server,
                    args = list(uploaded_df = shiny::reactiveVal(NULL), user_setup = shiny::reactiveValues(),
                                workspace = TargetWise:::workspace_new(), modification_log = log), {
    assessment_df(demo())
    session$setInputs(outcome_col = "FSI_CARI2_2class", outcome_pos = "Food insecure")
    blocked <- overridable()
    expect_true(length(blocked) > 0)
    col <- setdiff(blocked, "FSI_CARI2_2class")[1]
    expect_false(col %in% eligible_criteria())
    session$setInputs(allow_blocked = col, allow_reason = "A household characteristic here", allow_apply = 1)
    expect_true(col %in% eligible_criteria())
    expect_true(col %in% screened()$criterion)
    expect_false("FSI_CARI2_2class" %in% eligible_criteria())      # the outcome itself never
    lg <- shiny::isolate(log())
    expect_true(any(grepl("allowed as a criterion", lg$action)))
    expect_true(any(grepl("household characteristic", lg$reason)))
    expect_equal(TargetWise:::workspace_snapshot(workspace)$scorecard$allowed_blocked, col)
    # a second column, another note: each keeps its own
    col2 <- setdiff(blocked, c("FSI_CARI2_2class", col))[1]
    if (!is.na(col2)) {
      session$setInputs(allow_blocked = c(col, col2), allow_reason = "Observable by the registration team here", allow_apply = 2)
      notes <- allowed_reason()
      expect_equal(unname(notes[col]), "A household characteristic here")
      expect_equal(unname(notes[col2]), "Observable by the registration team here")
    }
  })
})
