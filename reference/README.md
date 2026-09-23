# Reference material

> The WFP guidance documents listed below are not included in this public
> repository; they are cited by their WFP document numbers.

Source documents behind the Scorecard tab. Kept here rather than in `data/`
because `data/` is reserved by R: `pkgload::load_all()` *executes* any `.R`
file it finds there, so the analysis script was being run on every load.

- `scorecard_analysis.R` — the APP-FA DRC targeting analysis (EFSA 2025) this
  tab reimplements. The scorecard itself comes from the logistic model's odds
  ratios; the XGBoost / random forest / elastic net sections compare models and
  inform variable selection, and are not needed to build the scorecard.
- `WFP-0000169093.pdf` — Targeting Advisory 1/2025, *Concerns Regarding the Use
  of Outcome Indicators During the Targeting Process*. The rule that outcome
  indicators (FCS, rCSI, LCSI, CARI, HHS …) must not be eligibility criteria.
- `WFP-0000167583.pdf` — Targeting Advisory 2/2025, *Methodological Note on
  Targeting Errors Measurement*. Design vs implementation errors, the
  contingency table, and the tolerance-band decision table.
- `WFP-0000169142.pdf` — Targeting Advisory 3/2025, *Using ROC Curves for
  Targeting Analysis*. Threshold selection as a programmatic decision.
- `WFP_Targeting_Prioritization_OGN_2021.pdf` — WFP *Targeting and
  Prioritization Operational Guidance Note* (January 2021, WFP-0000122035).
  The method catalogue, the design/selection/monitoring steps and the
  prioritisation rules the Beneficiary Selection approaches follow.
- `COMPLIANCE.md` — requirement-by-requirement map of this guidance (and the
  UNHCR-WFP Joint Hub and ICRC/IFRC material) against the app, with gaps.
