# TargetWise 0.2.0

* The app opens in your default browser, not the RStudio/Positron viewer.
* Column lists show every variable: wide forms (over 1,000 columns), sparsely answered number columns and factor name columns were missing from some lists.
* Outliers: any numeric variable can be checked; an allowed range per variable flags impossible values whatever the distribution; new corrections (cap at the limits, set to missing); the Most extreme values tab gives insights (direction, concentration on an enumerator or area, 99-style codes) and acts on selected rows (correct, set a value, mark as verified); an All numeric variables tab checks every column at once.
* Duplicates: groups shown as bands with the columns that differ, exact copies marked, side-by-side comparison, and deletion of selected records with a reason.
* Enumerator performance: a Flagged enumerators tab says why each one is flagged (short or long interviews, missing answers, an unusually busy day) and opens their interviews.
* Beneficiary selection: the Household criteria filters were removed (the eligibility rules cover them); variable calculator in the sidebar; a download button on the Beneficiary list; a richer Composition tab (who is served, by area, selected vs not selected); a By_area sheet in the Excel export.
* Variable calculator: an R code mode for multi-line calculations, checked before it runs.
* Targeting Monitoring pages and the sidebars scroll again, so every option and the Add to report button can be reached.
* Report error cards have a quieter, more professional look.

# TargetWise 0.1.0

## Latest changes
* Renamed **TargetWise** (formerly TargetingMonitorApp). Settings are now `TARGETWISE_*` (the old `TARGETING_MONITOR_*` names still work) and sessions saved under the old name are brought over on first start.
* Sessions: design-only and monitoring-only work is autosaved (every 30 s when it changed); a restore returns to the page you were on, says what it brought back, and opens the selection pages only when registration data is part of the session. Verified end to end: a design saved, restored weeks later, registration data imported, scorecard applied, report regenerated; a monitoring round saved and its report regenerated.
* Exports: every Excel and CSV export keeps accents and non-Latin scripts (UTF-8, CSV with a byte-order mark for Excel); the spot-check sample and back-check are formatted workbooks.
* PDM analysis page reorganised into four setup steps and result tabs.
* Light/dark switch no longer reshapes the page.
* Implementation errors: eligibility can be re-established by applying the adopted scorecard or the eligibility rules to the PDM answers; beneficiaries and non-beneficiaries are weighted by their population sizes (overall or per area), so the exclusion error is not understated; with only beneficiaries surveyed, the exclusion error is reported as not measurable.
* Targeting Monitoring: PDM analysis, process monitoring (complaints, community process, committees, participation of women and minorities, focus group discussions) with a chart and table builder, and a Targeting Monitoring report (HTML) with the implementation errors and the officer's comments.
* Beneficiary selection export: choose the variables to export.
* Saved sessions now keep all the work: the Targeting Design (assessment data, calculated variables, outcome, criteria, selection, every model run, edited points and review ticks, threshold, rationale, current step), the Beneficiary Selection settings, the spot-check sample and back-check, and the PDM analysis.
* Machine-learning models in Targeting Design: random forest, XGBoost, naive Bayes, neural network and SVM, turned into additive cards through average marginal effects.
* Numbers are rounded to 5 decimals across tables and exports.
* The design report's charts are interactive (billboarder), paired side by side, and the report header was redesigned; the file still works offline.
* The design and implementation verdicts are shown as an animated target: bullseye, near miss or miss.
* Full French translation; Spanish dropped.

First release as an installable package.

## Targeting Design
* Guided five-step design (outcome, criteria, variable selection, model and weights, threshold and errors) with a progress stepper and Back / Continue on every step.
* Variable selection by descriptive statistics and a correlation matrix, with an optional quick screening dialog.
* Four additive models (logistic, stepwise, weight of evidence, boosted stumps), four weighting schemes, hold-out validation, survey weights, benchmarks and a run history with restore.
* Threshold helpers (minimise errors, Youden, caseload), design error matrix, tolerance band and the Targeting Advisory 2/2025 verdict.
* Exports: scorecard workbook (reloadable in Beneficiary Selection), JSON, and a self-contained HTML design report with a Methods section.

## Beneficiary Selection
* Targeting approaches (hybrid, scorecard/PMT, categorical, community-based, geographic, blanket, self-targeting) with prioritisation; excluded-by-design households reported separately.
* Data quality, spot checking, audit trail, MODA / Kobo / ODK import.

## Targeting Monitoring
* Implementation errors on PDM data with the Advisory 2/2025 implementation decision table.

## Tools
* Variable calculator (conditions, formulas, bulk binarise) on the assessment and registration data.
* Update check: the app tells users when a newer version is published on the repository.
