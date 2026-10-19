# Builds inst/extdata/survey_demo.csv: a synthetic post-targeting survey of the
# households in registration_demo.csv (same IDs, row for row), so that any
# monitoring sample drawn in Beneficiary Selection is found in it.
#
# The enumerators re-measured the criteria a month after registration and
# about 8% of each answer changed, so a scorecard or ranking applied to these
# answers disagrees with the selection for some households: that is the
# implementation error the Monitoring tab measures. The criteria carry both the
# registration's names and the assessment's, so a scorecard designed on
# assessment_demo.csv finds them as well. received_assistance (with 6% noise)
# serves the "A column in the survey" route, as a PDM would.
#
# Run from the project root: Rscript dev/make_survey_demo.R

reg <- utils::read.csv("inst/extdata/registration_demo.csv", stringsAsFactors = FALSE)
ass <- utils::read.csv("inst/extdata/assessment_demo.csv", stringsAsFactors = FALSE)
stopifnot(nrow(reg) == nrow(ass), all(reg$lon == ass$lon & reg$lat == ass$lat))

set.seed(2026)
n <- nrow(reg)
flip <- function(x, p, yes = "Yes", no = "No") {
  f <- stats::runif(length(x)) < p
  x[f] <- ifelse(x[f] == yes, no, yes)
  x
}

sv <- reg[, c("instanceID", "Province", "Territoire", "Zonesante", "Airedesante", "Village",
              "lon", "lat", "HHHSex", "HHHAge", "HHSize", "HHStatus")]
sv$SurveyDate <- format(as.Date(reg$SvyDate) + sample(28:45, n, replace = TRUE))
sv$Enumerator <- sprintf("ENUM_%02d", sample(1:12, n, replace = TRUE))

# criteria, re-measured: registration name -> assessment name
pairs <- c(Targ_HHHousingTent = "Targ_HHHousingTent", targ_hhnolight = "Targ_HHNoLight",
           DepRatio2plus = "Targ_HHDepRatio2plus", Targ_HHOwnCattle2mor = "Targ_HHOwnCattle2more",
           hh_receives_money = "Targ_HHRemittance")
for (r in names(pairs)) {
  v <- flip(reg[[r]], 0.08)
  sv[[r]] <- v
  if (pairs[[r]] != r) sv[[pairs[[r]]]] <- v
}
for (a in c("Targ_HHChildWork", "Targ_HHSepChild", "Targ_HHCredAcc")) sv[[a]] <- flip(ass[[a]], 0.08)

# food security outcome at the time of the survey
sv$FSI_CARI2_2class <- flip(ass$FSI_CARI2_2class, 0.05, "Food insecure", "Food secure")
sv$FCS_class <- ass$FCS_class
sv$rCSI_high <- flip(ass$rCSI_high, 0.05)

# what a PDM would ask: did the household receive assistance
sv$received_assistance <- flip(ifelse(reg$Scoring_total > stats::median(reg$Scoring_total), "Yes", "No"), 0.06)

utils::write.csv(sv, "inst/extdata/survey_demo.csv", row.names = FALSE)
cat("survey_demo.csv:", nrow(sv), "households,", ncol(sv), "columns\n")
