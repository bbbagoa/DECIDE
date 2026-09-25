# TargetWise 1.0.0

* The app opens in your default browser, not the RStudio/Positron viewer.
* Column lists show every variable: wide forms (over 1,000 columns), sparsely answered number columns and factor name columns were missing from some lists.
* Outliers: any numeric variable can be checked; an allowed range per variable flags impossible values whatever the distribution; new corrections (cap at the limits, set to missing); the Most extreme values tab gives insights (direction, concentration on an enumerator or area, 99-style codes) and acts on selected rows (correct, set a value, mark as verified); an All numeric variables tab checks every column at once.
* Duplicates: groups shown as bands with the columns that differ, exact copies marked, side-by-side comparison, and deletion of selected records with a reason.
* Enumerator performance: a Flagged enumerators tab says why each one is flagged (short or long interviews, missing answers, an unusually busy day) and opens their interviews.
* Beneficiary selection: the Household criteria filters were removed (the eligibility rules cover them); variable calculator in the sidebar; a download button on the Beneficiary list; a richer Composition tab (who is served, by area, selected vs not selected); a By_area sheet in the Excel export.
* Variable calculator: an R code mode for multi-line calculations, checked before it runs.
* Targeting Monitoring pages and the sidebars scroll again, so every option and the Add to report button can be reached.
* Report error cards have a quieter, more professional look.
* Restoring a session brings back every dataset (registration, assessment, PDM, targeting process, and the original import used by Reset), and the variable setup reopens on the restored mapping.
* Every Excel export is locked for editing (set `TARGETWISE_EXPORT_PASSWORD` to require a password to unlock); the exports that were CSV are now locked Excel workbooks.
* Beneficiary list export: the audit trail is optional (tick box), and the list can be exported as one workbook per area (Admin 1 down to village) in a zip, each file named after its area.
* A "Working..." indicator appears whenever the app takes more than a moment, and "Preparing your file..." until a download is ready; a restored session keeps its loader until the page has settled.
* Beneficiary selection report (HTML): headline figures, data and preparation, the selection design, who was selected (by area, selected vs not selected), a map of selected and non-selected households, and accuracy.
* Targeting Design: the screening table explains each candidate (share among the vulnerable and the others, a plain-language reading); quick screening shows odds ratios, adjusted p-values and a verdict; choose which models to compare per variable (the quick ones by default).
* Design report: smaller, borderless error cards and the full design error matrix in a neutral table.
* Targeting Monitoring: PDM or baseline data; crosstabs with row, column or total percentages and a chi-square test in the chart and table builder; report items can be dragged into order and set to half width to sit side by side.
* PDM analysis: required columns start empty instead of defaulting to the first column; the selected entry of every dropdown is readable.
* Tagline "Reaching the most vulnerable" (French: "Atteindre les plus vulnerables"); WFP logo | TargetWise on the Welcome page and the navbar; smoother navbar hover and menu animations.
* Loaders say what is running ("Fit model...", "Updating: ...", "Preparing: ...") and share the full-screen waiter's design; every blocking step names itself.
* Buttons that need something first are frozen until it is there, with the reason on hover and as a notice when clicked; handlers say what is missing instead of doing nothing.
* Selection report: area summary at Admin 3 (or 2) instead of a long list, a beneficiary profile (female-headed, displacement, disability, chronic illness, marital status, household size) with pictograms and donut charts, and an OpenStreetMap background that needs no API key.
* Stepwise selection (AIC or BIC) is an option for every model, not a model of its own.
* Targeting Design: "How the design works" guide (seven steps, methods, technical details, references) replaces the reload button.
* Selection report: area summary grouped Admin 1 > Admin 2 with highlighted subtotals and total; compact table rows in every report; selection rates across socio-demographic groups (head's sex, residency, marital status, disability, chronic illness, age and household-size bands) with the widest gaps in words; no information repeated between the profile tiles and charts; an explained accuracy section (inclusion and exclusion errors with their matrix, as designed and after prioritisation, coverage, precision, recall); a 5:3 map on the Overview's Esri basemaps (light, terrain, satellite), which also work when the report is opened from a file.
* Areas covered: the area pickers are the scope of an analysis, not a criterion. Households outside the chosen areas are left out of every count, list and report, and each report says which areas it covers. Beneficiary Selection uses the mapped admin levels (for every approach); Targeting Design, the PDM/baseline analysis and targeting process get the same control on any area column of their data (saved with the session, logged in the audit trail).
* Overview: "Data summary report (HTML)": key figures, coverage, households by Admin 1 > Admin 2, collection over time and by enumerator, who was surveyed, vulnerability, and a map; covers the Overview's filters.
* Esri Terrain is the default basemap on every map (the others stay selectable). Monitoring pages and the Design page reorganised: set-up in a compact sidebar, data card and analysis chain side by side. "Process monitoring" is now "Targeting process".
* Design progress chart: back and next arrows. Design steps renamed: Vulnerability Framework, Criteria Selection, Criteria Screening.
* Reports: at most three donuts, on one row; other categories as bar charts; no borders around charts; maps open zoomed on the households. The data summary shows socio-economic indicators found in the data (food consumption, coping, income, shelter, water...) when no vulnerability is mapped.
* Welcome page: the WFP Targeting and Prioritization Operational Guidance Note (2021) is the first methodological reference.
* Dropdowns whose variables are refreshed (chart builder and others) are no longer cut off and list every variable.
* Report texts (monitoring context, findings, recommendations, chart comments, threshold rationale) have a formatting toolbar: paragraph style, size, bold, italic, underline, strikethrough, text and highlight colours, lists, alignment, links. The formatting carries into the HTML reports (cleaned of anything that could run); Excel and the audit trail get the plain text.
* Chart builder: choose the chart style (bars, columns, donut, pie, line, area); the report draws the same style.
* Admin filters are chained everywhere (Overview, Data Quality, Beneficiary Selection, Areas covered): Admin 2 lists only the areas inside the chosen Admin 1, Admin 3 inside those, and valid selections are kept.
* Targeting Monitoring: the set-up sidebar fits the window, so every step and the Compute button can be reached.
* Assessment data (Design), PDM / baseline data and targeting-process datasets can be imported from MODA, like the registration data.
* Session toolbar: New saves the current session and starts an empty one (or starts fresh without saving).
* Welcome page: the methodological references are credited to the WFP VAM Needs Assessment and Targeting Unit.
* Targeting Design: MODA, How it works and Calculator side by side; candidate criteria beside the blocked columns, with the selected ones listed; a chart of vulnerable households by area under the Vulnerability Framework, also in the design report; threshold controls on one side and the rationale on the other; the progress chart numbers its steps like the tabs, and the guidance under it follows the current tab (back to an unfinished step, or on to the next).
* Spot Checking: the sampling controls sit on top of the Sample tab (Draw sample); the verification controls are one panel in two numbered parts (verification data, comparison) with the actions at its foot; the area filters are chained like the others.
* Special characters (accents, cedillas, curly apostrophes, the euro sign, Arabic) read correctly from every format: CSV in UTF-8 (with or without BOM) or Windows-1252 (Excel on a French or Spanish Windows, semicolons), Excel, SPSS and Stata (value labels included), Parquet and MODA; they stay intact in the reports and Excel exports.
* MODA downloads are faster and survive a poor connection: responses are compressed, pages come four at a time once the first one gives the total, a slow page is waited for as long as data keeps flowing, and a failed page is retried (up to four times, with a growing pause) instead of stopping the download. The "no applicable method for conditionMessage" error on a timeout is fixed.
* The first MODA (or Kobo / ODK) API key entered is filled in for every later import in the same session (registration, assessment, PDM, targeting process, spot-check verification, Refresh MODA); only the form ID changes, and the key can still be edited. It stays in memory and is never saved.
* MODA, Kobo and ODK imports go through the same text handling as file imports, so accents and other scripts arrive intact.
* MODA: Sync Now first shows the form (title, number of submissions, last one received) and downloads on confirmation; a refused key or an unknown form ID is said before anything is downloaded; the loaders name the form. Download progress is written into the loader in place, so it no longer flickers between pages, and the small "Working..." card no longer blinks over a full-screen loader.
* MODA, Kobo and ODK data come as plain columns: GPS answers split into latitude, longitude, altitude and precision (the variable setup finds them), _geolocation into latitude and longitude, each select-multiple question into one Yes/No column per choice (Oui/Non when the app is in French; the question keeps its labels joined by "; "), repeat groups and attachments into counts.
* Select-multiple questions are split at every import, whatever the source (CSV, Excel, SPSS, Stata, Parquet, MODA, Kobo, ODK): the form says which questions they are when MODA provides it; otherwise a column is split when every answer is a set of choice codes. Choice columns a Kobo or ODK export already has (question/choice, 0/1 or True/False) are relabelled Yes/No.
* The import summary is a cleaner dialog: the source, four headline figures, data quality and variable types side by side, and the first variables.
* Fixed: saving the country office crashed with "incompatible types (from raw to character)" on computers where a session had been saved under the name "settings", which overwrote the settings file. Settings now live in their own file (app.settings); older settings are carried over, and a session named "settings" stays a session.
* On a narrow window (a browser zoom above about 110% on a laptop) the app sets its base text size to 90%, as a 90% zoom would, so the pages keep their layout.
* The app keeps an idle page connected (a keep-alive every 30 seconds) and picks a dropped connection up again where the server allows it, so a quiet session is not lost.
* The "By area" chart of the Composition tab no longer fails ("unknown colour name").
* The country-office settings file is no longer listed as a saved session.
* Sessions also keep the Data Quality settings (filters, outlier variable, method and allowed ranges, duplicate columns, missing-data analysis) and the quick-screening result; after a restore, "Refresh MODA" fetches only the new submissions (the API key is asked for, never saved).

# TargetWise 0.1.0

## Latest changes
* Renamed **TargetWise** (formerly TargetingMonitorApp). Settings are now `TARGETWISE_*` (the old `TARGETING_MONITOR_*` names still work) and sessions saved under the old name are brought over on first start.
* Sessions: design-only and monitoring-only work is autosaved (every 30 s when it changed); a restore returns to the page you were on, says what it brought back, and opens the selection pages only when registration data is part of the session. Verified end to end: a design saved, restored weeks later, registration data imported, scorecard applied, report regenerated; a monitoring round saved and its report regenerated.
* Exports: every Excel and CSV export keeps accents and non-Latin scripts (UTF-8, CSV with a byte-order mark for Excel); the spot-check sample and back-check are formatted workbooks.
* PDM analysis page reorganised into four setup steps and result tabs.
* Light/dark switch no longer reshapes the page.
* Implementation errors: eligibility can be re-established by applying the adopted scorecard or the eligibility rules to the PDM answers; beneficiaries and non-beneficiaries are weighted by their population sizes (overall or per area), so the exclusion error is not understated; with only beneficiaries surveyed, the exclusion error is reported as not measurable.
* Targeting Monitoring: PDM analysis, targeting process (complaints, community process, committees, participation of women and minorities, focus group discussions) with a chart and table builder, and a Targeting Monitoring report (HTML) with the implementation errors and the officer's comments.
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
