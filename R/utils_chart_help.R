#' What each Targeting Design chart shows and how to read it
#'
#' One entry per chart output id: `shows` (what is drawn) and `read` (how to
#' read it, what to look for). `chart_help()` turns an entry into the info
#' tip beside the chart's title.
#' @noRd
CHART_HELP <- list(
  pmt_decile_plot = list(
    shows = "For each tenth of households ranked by measured welfare per person (D1 the poorest), the share the PMT selects at the current cut-off. Blue deciles are those below the poverty line.",
    read = "A good PMT selects most of the blue deciles and little of the grey ones. Selection that falls slowly across the deciles means the proxies separate the poor badly: under-coverage at the bottom and leakage at the top."),
  pmt_curve_plot = list(
    shows = "The two PMT errors for every cut-off from half to twice the poverty line: leakage (non-poor among those selected) and under-coverage (poor left out). The dashed line is the current cut-off.",
    read = "Raising the cut-off above the line lowers under-coverage and raises leakage, and the reverse. Choose where the programme can accept the trade-off; in emergencies the OGN puts under-coverage first."),
  pmt_resid_plot = list(
    shows = "Measured minus predicted log welfare per person for each evaluation household, against the predicted value. The red dotted line is the poverty line.",
    read = "The cloud should sit around zero everywhere. Points far above zero near the line are households predicted poor that are not; far below, poor households predicted better off. A downward slope means the model pulls everyone to the middle, the usual cause of under-coverage."),
  pmt_compare_plot = list(
    shows = "Each compared PMT model's leakage (across) against its under-coverage (up) as the cut-off moves from half to twice the poverty line.",
    read = "The curve closest to the bottom-left corner gives the fewest errors of both kinds. Curves that cross mean one model is better at a strict cut-off and another at a generous one."),
  pmt_fit_plot = list(
    shows = "Each household's predicted welfare per person against its measured welfare (both in logs), on the evaluation households. The dashed lines are the poverty line on each axis.",
    read = "Points near the diagonal are well predicted. Bottom-right: predicted poor but not poor (inclusion errors); top-left: poor but predicted not poor (exclusion errors). A cloud flatter than the diagonal is the usual PMT pattern: the poorest are predicted too well-off, the richest too poor."),
  vuln_area_plot = list(
    shows = "For each area, the share of households on the vulnerable side of the outcome (red) and the rest (green). The dotted line is the share over all areas.",
    read = "Columns well above the line are the areas where vulnerability concentrates; if they differ a lot, geographic targeting or area quotas may matter as much as household criteria."),
  roc_plot = list(
    shows = "How well the score ranks households: for every possible threshold, the share of vulnerable households selected (up) against the share of non-vulnerable ones selected (right).",
    read = "The closer the curve hugs the top-left corner, the better; the diagonal is random selection. The area under it (AUC) sums this up: 0.5 random, above 0.7 useful, above 0.8 good. The dot is the current threshold."),
  score_hist_plot = list(
    shows = "How the score spreads over all the households: a histogram, its density curve and the threshold as a dotted line. Bars right of the line are the eligible households.",
    read = "A threshold in a dip of the curve separates households cleanly; one on a peak puts many households with almost the same score on either side, so small changes to it move many of them."),
  score_plot = list(
    shows = "The score of vulnerable households (above the axis) and of the others (below), each as a share of its own group, on the same score bins. The dashed line is the threshold.",
    read = "The less the two shapes overlap, the better the score separates the groups. Vulnerable households left of the line are excluded by mistake; non-vulnerable ones right of it are included by mistake."),
  box_plot = list(
    shows = "The spread of the score in each group: the box holds the middle half of the households, the line inside is the median, the dashed line the mean; the horizontal line is the threshold.",
    read = "Boxes far apart mean the score separates the groups well. The part of the vulnerable box below the threshold and of the other box above it are the errors."),
  contribution_plot = list(
    shows = "Each criterion's share of all the points given across the households: its weight times how many households meet it.",
    read = "A criterion near the top does most of the work in the score. A heavy weight on a rare criterion moves few households; a light one on a common criterion can matter more."),
  met_plot = list(
    shows = "How many criteria each household meets, for the households the threshold makes eligible and for the others.",
    read = "Eligible households should meet more criteria. If both groups meet the same number, the threshold hinges on a few criteria; check they are the ones you trust."),
  coverage_plot = list(
    shows = "Of the households meeting each criterion, the share the current threshold makes eligible, among vulnerable and among other households.",
    read = "A criterion whose vulnerable holders are poorly covered carries little weight in practice. A high share among non-vulnerable holders points to an inclusion-error source."),
  weights_plot = list(
    shows = "The points each criterion adds (inclusion, right) or removes (exclusion, left) in the score.",
    read = "Longer bars weigh more. Check every direction makes sense on the ground: an inclusion criterion should describe vulnerable households."),
  prevalence_plot = list(
    shows = "How common each criterion is among vulnerable households and among the others.",
    read = "The wider the gap between the two bars, the more the criterion separates the groups. Criteria met by almost everyone or almost no one separate little."),
  effects_plot = list(
    shows = "Each criterion's effect (log-odds) under every model compared.",
    read = "Dots close together mean the effect is robust to the method; dots spread out or on both sides of zero mean it depends on the model: treat that weight with care."),
  pca_scree = list(
    shows = "How much of the criteria's variation each PCA axis explains (bars, eigenvalues) and the cumulative share (line). Blue bars are the axes the index keeps.",
    read = "The first axes should stand out. Kaiser's rule keeps axes with an eigenvalue above 1 (dashed line); the red line tells how much the index explains in total."),
  pca_loadings = list(
    shows = "How strongly each criterion weighs on each axis kept, turned so that higher means more vulnerable.",
    read = "Criteria with large loadings define the axis. Criteria near zero on every axis kept barely enter the index."),
  pca_var_map = list(
    shows = "The correlation circle: each criterion as an arrow on axes 1 and 2.",
    read = "Long arrows are well represented by these two axes. Arrows pointing the same way move together; opposite arrows move against each other; arrows at right angles are unrelated."),
  pca_ind_map = list(
    shows = "Every household placed on axes 1 and 2, coloured by the outcome.",
    read = "If vulnerable and other households form separate clouds along axis 1, the index separates them; clouds on top of each other mean it does not."),
  lda_scores = list(
    shows = "The index of vulnerable households (above the axis) and of the others (below), each as a share of its own group, on the same bins.",
    read = "The less the two shapes overlap, the better the discriminant separates the groups; the gap between their centres is what LDA maximises."),
  lda_var_map = list(
    shows = "Each criterion's correlation with the index (structure correlation).",
    read = "Criteria with a large correlation are the ones the index rests on; blue raises the index, red lowers it."),
  lda_ind_map = list(
    shows = "Every household's index value, by group, with the box of the middle half.",
    read = "Boxes far apart mean the groups are well separated; overlapping boxes mean many households would be misclassified whatever the threshold."),
  rank_plot = list(
    shows = "How the households spread along the score of the ranking; the dashed line is the threshold.",
    read = "Households right of the line are selected. A clear gap or a step in the shape is a natural place for the threshold; a smooth shape means the cut is a caseload decision."),
  sel_prev_plot = list(
    shows = "The share of selected and of other households meeting each criterion, criteria ordered by the gap between the two (largest first).",
    read = "The ranking should concentrate the deprivations among the selected households. A criterion as common on both sides is not driving the selection."),
  dep_count_plot = list(
    shows = "How many weighted deprivations households have; blue bars are above the threshold.",
    read = "The threshold is the number of deprivations that defines vulnerability (a third of the criteria in the global MPI). Move it to where the programme draws the line."),
  cluster_plot = list(
    shows = "Each profile (column, most vulnerable first) and the share of its households meeting each criterion (darker = more).",
    read = "Profiles differ where the colours differ. Name each profile from its darkest cells and target the ones that match vulnerability in this context."),
  unsup_map = list(
    shows = "Every household (a sample of 3,000 on large data) on the first two principal components of the criteria, coloured by profile or by selection. Component 1 is turned towards the anchor criterion.",
    read = "Selected households (or the targeted profiles) should sit together, mostly towards the right. Profiles that overlap a lot are hard to tell apart on these criteria."),
  cov_area_plot = list(
    shows = "The share of households the ranking selects in each area; the dotted line is the share overall.",
    read = "Areas far above the line concentrate the selection. Check this matches what is known of the area; a whole area near zero may call for area quotas or a geographic layer."),
  pq_plot = list(
    shows = "The separation of the profiles (silhouette) and, for latent classes, the certainty of the classification (entropy), for 2 to 8 profiles.",
    read = "Prefer the number where the silhouette peaks, with no profile too small to act on."),
  sel_by_met_plot = list(
    shows = "For households meeting 0, 1, 2... criteria, the share the threshold selects.",
    read = "A ranking should select more of the households that meet more criteria: the bars should rise to the right. A jump shows where the threshold cuts in terms of criteria met."),
  comparison_roc = list(
    shows = "The ROC curve of the scorecard and of every compared model, on the held-out households.",
    read = "Curves on top of each other mean the simple scorecard loses little against the other models; a curve clearly above the scorecard shows what the card gives up.")
)

#' The info tip for a chart: what it shows and how to read it
#' @noRd
chart_help <- function(id) {
  h <- CHART_HELP[[id]]
  if (is.null(h)) return(NULL)
  info_tip(tip_body("About this chart", list(list(name = "What it shows.", text = h$shows),
                                             list(name = "How to read it.", text = h$read))))
}
