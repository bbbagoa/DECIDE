# TargetWise 1.0.0

* The analyst decides last on blocked columns: under "Columns that cannot be criteria" (with or without an outcome), columns blocked by a rule (outcome indicator, not observable, identifier) can be allowed back as criteria, each with its own note (why). The choice is in the audit trail, saved with the session and listed in the report. The outcome itself, constants and non yes/no columns stay out.
* Model settings: the PCA variation preview is worked out once when the dialog opens; changing the axes or the minimum variation only updates its text. Nothing runs until Fit model.
* Without an outcome, only names and identification variables are blocked as criteria (`is_identification_col()`: ids, keys, names, phone numbers, form metadata); outcome indicators and what a registration team cannot observe may rank households. With an outcome the Advisory 1/2025 blocks stay, and identifiers are now blocked by name as well (`criterion_blockers(strict =)`).
* Without an outcome: **Decision tree (rules describing the profiles)**: k-means profiles, the ones to target chosen as for the other profile methods, and a tree that describes them in rules (shown in the app and the report); points from its average effects.
* A vulnerability ranking now scores every criterion met in the vulnerable direction (an inclusion criterion met, an exclusion criterion not met) instead of "inclusion minus exclusion, floored at zero". A profile defined by what households lack scored zero for everyone before; the points now reproduce the targeted profiles (fidelity 0.5-0.7 before, about 1.0 now on the demo data). Scorecards built on an outcome keep the APP-FA rule.
* An adopted vulnerability ranking now informs Beneficiary Selection: the export adds each household's priority rank, its deprivations and (profile methods) its nearest ranking profile; the export summary records the ranking's method, orientation and stability; the Composition tab shows the share selected by number of deprivations and by ranking profile (`ranking_columns()`, `ranking_deprivations()`, `ranking_profile_assign()`, `sc$ranking`).
* Design sidebar: "Use this scorecard / ranking" is the one primary action; the exports are a list with an icon and what each file is for (labels follow the mode without breaking the buttons).
* "Criteria among selected and other households" is a vertical chart, criteria ordered by the gap between the two groups.
* **Decision tree** model (rpart): additive points from its average effects, like the other machine-learning models, plus the tree's rules (each leaf: the answers leading to it, households, share vulnerable) in the app and the report.
* **Hyperparameter tuning by cross-validation** in the model settings for every model that has hyperparameters (tree, random forest, XGBoost, boosted stumps, SVM, neural network, naive Bayes): a small grid tried with k folds on the training households, the best cross-validated AUC kept and the model refitted (`tune_ml()`, `ml_grid()`); the grid is one click away and in the report. Without an outcome, cluster methods can choose their number of profiles automatically (best silhouette).
* Fixed: the stability check stopped with "values must be length 2" when a resampled refit failed (for example a criterion constant in the resample); such refits are now left out and the median is taken over the others.
* Model & weights: a settings button beside the model opens its settings in a dialog (PCA / MCA axes, number of profiles and seed for the cluster methods, hold-out % and seed for every model with an outcome); a line under the model says what is set. The settings are kept with the session (`model_params`).
* Ranking without an outcome: "Share selected by number of criteria met" takes the coverage chart's place on the threshold step.
* The page is built once per R process and reused (`app_ui()` keeps what `app_ui_build()` makes): later page loads take about 2.7 s instead of 7 to 8 s.
* Ranking without an outcome: the anchor criterion is optional. With none, more criteria met means more vulnerable (`anchor_text()`); the reports and the workbook say what oriented the ranking.
* Variation-explained charts (app and report) show up to 20 axes.
* A design built without an outcome is a **vulnerability ranking** everywhere: page buttons, the Excel export (Vulnerability_Ranking, its own "How to read"), the HTML report (Vulnerability ranking report: key-result gauges for selection, stability, consistency and concentration; Purpose of the ranking; Ranking method; Threshold and validity; a methods appendix written for rankings), Beneficiary Selection ("Apply the vulnerability ranking", its type in the selection export) and a workbook read back (`is_ranking()`, `card_word()`, `build_scorecard(kind =)`).
* Ranking validity: profile separation (silhouette), latent-class entropy and BIC, a "Compare 2 to 8 profiles" dialog, rank agreement across resamples (Spearman), what the selection concentrates (deprivations among the selected vs the others, share of all deprivations held) and the share selected by area. A households map shows every household on the first two components, coloured by profile or selection (app and report). For profiles, the starting threshold is the cut that best reproduces them.
* Monitoring, PDM: a **Calibrate the ranking** tab measures an adopted ranking's inclusion and exclusion errors, its AUC and a better threshold on PDM or verification data that carry an outcome (`ranking_calibration()`).
* **Targeting without an outcome indicator.** Vulnerability Framework has a switch "No outcome indicator: build a vulnerability ranking" for shocks without an assessment or data from partners and registries. Criteria are chosen, not tested (those met by 5% to 95% of households start ticked); the model step offers deprivation counting (Alkire-Foster), a PCA or MCA index turned towards an anchor criterion, and household profiles from latent class analysis, k-means or Ward clustering (you tick the profiles to target; a linear discriminant turns them into points, and its fidelity is shown). The threshold step replaces errors with the households selected, internal consistency (Cronbach's alpha) and the stability of the selection over 20 resamples (Jaccard). Adoption needs the rationale; the report and the workbook say that no error could be measured (`R/utils_unsupervised.R`).
* Design report: the PCA section shows the correlation circle (axes 1 and 2) instead of the loadings chart.
* PCA index: keep a number of axes, or a **minimum variation explained** (the fewest axes reaching it are kept). A preview under the setting gives the variation explained before fitting; the fit note leads with the total, and the scree chart adds the cumulative % line.
* LDA "Index by group" uses the same mirrored layout as the score distribution (shares of each group, no overlap).
* Every Targeting Design chart has an info tip: what it shows and how to read it (`CHART_HELP`, `chart_help()`, `R/utils_chart_help.R`).
* Design report: a PCA or LDA design gets its own section (axes kept, total and per-axis variation, KMO, Bartlett, or Mahalanobis D-squared; index weights with loadings or structure correlations; scree with cumulative %, loadings or structure charts) instead of the odds-ratio table, and every design lists each criterion's effect under every model compared.
* Criteria: the tests run by themselves only when the variables change; a change of significance level, adjustment or overlap cut-off waits for **Run the tests** (a notice says when the settings differ from the last run).
* Correlations asks for the threshold first and computes only on **Find correlated variables**.
* Binarise variables opens wide (every column visible) and labels each new variable after its source and rule ("HHSize: at least 7"), so the label shows in pickers and tables.
* Model & weights: three panels; Fit model sits under the comparison.
* Adoption: a design whose inclusion or exclusion error is above the upper tolerance can be adopted only with a short explanation, shown in the design report, the scorecard workbook and the audit trail. A tolerance band other than the default 5% - 20% needs the rationale filled in before adoption.
* Threshold step: the parameters and the rationale share the width equally, the rationale box as tall as the parameters.
* Save Session: "Autosave this session every 20 minutes" keeps saving the same session in full (`TARGETWISE_AUTOSAVE_EVERY_MIN` changes the period); loading another session turns it off.
* Score distribution (app and report): mirrored, vulnerable above the axis and not vulnerable below, each as a share of its own group on the same bins, so both groups stay visible.
* Fixed: 30 seconds after a Targeting Design session was restored, a safety timer touched the session even if the browser had closed meanwhile (an error in such a callback can stop the app).
* Report radars show their tooltip anywhere over a spoke's slice, not only over its name, with values as percentages.
* Targeting Design: Criteria Screening, Review, Correlations and Criteria Selection are now one step, **2. Criteria**: a single table (Use first) with each variable's shares, odds ratio, adjusted p-value (the screening runs by itself), strongest overlap and missing answers. Associated variables come ticked, less the weaker of any pair above the |r| cut-off; Continue sends the ticked criteria to the model. The table fits the page (names and labels wrap). The design has four steps; the report sections are renumbered. Older sessions open on the new table.
* Binarise variables (a button on the Criteria step) is the variable calculator's bulk binarise with a new method, **Best split for vulnerability**: for each selected column, the cut-off or answer group that separates vulnerable households best, previewed with its gap and strength, created with a tick (significant ones ticked by default) and logged. The suggestions no longer run on the Criteria page.
* Binarise variables names new variables `<column>_..._Bin` by default (an ending, not a prefix; names are made valid when the source has spaces or symbols), and **Screen the entire database** finds the best cut-off of every column that is not yes/no yet in one go.
* Correlations (a button on the Criteria step) lists only the groups of ticked variables correlated at or above the cut-off, with the one to remove in each group proposed (`correlated_groups()`); "Remove the ticked from Use" applies it. The design report lists the same high pairs, by group, with what was removed, instead of a correlation matrix.
* The Criteria table has a search box (variable names and labels).
* Model & weights: the settings are one band of three groups side by side (1. Model, 2. Criteria and data, 3. Comparison) with Fit model at the end. Stepwise selection is one dropdown (No stepwise, Backward, Forward, Both directions) with AIC or BIC beside it; older sessions keep their stepwise setting. Survey weights are optional, with a "(none)" choice.
* The random forest & boosting benchmark is gone: the model comparison (AUC, ROC) now covers the models chosen in "Models to compare", each scored as the sum of its effects, from the fits already made for the per-variable table (`compare_models_auc()`).
* Fixed: the Criteria table failed with "row names contain missing values" when a variable's gap could not be computed (answered only where the outcome is missing).
* The survey weights and area-scope column pickers use the styled dropdown (name and label), and every chained area picker (Areas covered, admin filters) lists labelled values as "code - label".
* The per-criterion "Validated by the community" tick is gone; the scorecard export still reminds that Advisory 1/2025 asks for community validation before implementation.
* Criteria tables: a variable's label shows under its name, without the hover.
* Points by criterion and What drives the score are lollipops, in the app and the report.
* Charts with many variables (radars, lollipops, columns; app lollipops past 20) write every other name, evenly spread, and give every name on hover.
* Vulnerable households by area keeps every area at a readable width and scrolls sideways instead of shrinking; the vulnerable part stays at the bottom, where the average line is measured from.
* Report tables longer than 12 rows show 10 and a "Show all" button (all rows are printed).
* The error and agreement cards at the top of the reports are semicircle gauges (zones, value arc, percentage in the middle).
* Every donut is 80% hollow with its largest share written in the middle (reports, chart builder, Overview).
* PCA and LDA indices also show a variable graph and a household graph: for PCA the correlation circle and the households on axes 1 and 2; for LDA each criterion's correlation with the index and the households on the index.
* Design report: every criterion is kept. Points by criterion and What drives the score are vertical columns (inclusion up, exclusion down); How common each criterion is and Coverage by criterion are radars. Only the correlation table stays at the 15 most relevant (full matrix in the Excel scorecard).
* Vulnerability Framework chart (app and report): every area, labels horizontal or vertical, the percentage printed on both parts of each column.
* Reports: charts side by side always have the same height.
* PCA index on several axes: the analyst chooses how many; the index averages the coordinates on the kept axes, each turned towards vulnerability and weighted by the variation it explains (Kaiser's rule shown as a guide). With PCA or LDA the model step shows their own charts (scree plot and loadings; index by group for LDA) instead of the logistic ones, and the weighting scheme is marked as not applying.
* Targeting Design, model step: two vulnerability indices from dimension reduction, PCA (first principal component, Filmer & Pritchett; the same first dimension as MCA for yes/no criteria) and LDA (Fisher's discriminant). Both are additive, turned so a higher index means more vulnerable, and go through the same threshold, errors, verdict and exports; PCA reports its variance explained, KMO and Bartlett's test, with a warning when the criteria share too little variation.
* The admin selector of the Vulnerability Framework chart uses the styled variable dropdown.
* Every dropdown listing variables shows the name in bold (and the label below when there is one); dropdowns listing answers read "Code - Label" (1 - Yes); tables show a variable's label under its name in the first column, and on hover elsewhere (Criteria Screening, Criteria Selection, models, data quality...).
* Targeting Design step bar: on every page it says what the step asks (or that it is done) and offers "Continue to" the next page; an earlier unfinished step is a small link back; every step in the bar opens its page, and Data opens the data section of the sidebar.
* Dropdowns: a labelled variable shows its name in bold with the label below it, small, in blue italics; items are separated by a hairline.
* Variable and value labels:
  * **SPSS / Stata imports:** a column becomes a category only when every value has a label; a number with a few labelled codes (99 = "Don't know") stays a number.
  * **MODA imports:** question labels come from the form; split select_multiple columns read "Question: Choice".
  * **One dictionary per session**, saved with it, so labels no longer disappear after a filter.
  * **Shown everywhere:** pickers read "name — label", table headers show the label on hover, every Excel export has a Variables sheet (name, label, value labels), and the reports end with a Variables section.
* Yes/no variables created in Criteria Screening (Binarise) are named with a Targ_ prefix (e.g. Targ_hh_size_ge7).
* Every sidebar has the Targeting Monitoring look: numbered sections that fold, each with an icon, and the page's actions in one block at the bottom (Overview, Data Quality, Spot Checking, Beneficiary Selection, Targeting Design).
* Interface pass after a full walkthrough:
  * the Overview date shows months again;
  * weighted counts say so ("94, weighted estimate, 60 records");
  * the language switch no longer logs errors;
  * the navbar fits narrow windows (no sideways scroll; wraps below 1,000 px);
  * Targeting Design has one slim step bar, a readable threshold slider and wrapping review tables;
  * one primary button per view;
  * the Data Quality sidebar uses the mapped names;
  * Spelling & Integrity, Outliers, Spot Checking, the Audit Trail and the PDM sidebar are clearer;
  * the Overview profile titles are readable;
  * more of the interface is in French.
* Targeting Design report: each per-variable chart shows the 15 most relevant variables (largest points, gap or share of the score) and says so; the Excel scorecard has a Report_tables sheet with every table in full.
* Monitoring report: Key findings come right after the Context.
* Long tasks (reading an imported file, fitting a Targeting Design model) run in a background R process: the page stays usable and a cross on the loader stops them.
* The loader stays up through tasks that run back to back and closes once everything is done, instead of blinking between them.
* Fuzzy duplicate matching is fast on large lists (sorted neighbourhood, a few seconds for 50,000 households; it used to run for hours) and catches typos in the first letter too. New dependency: stringdist.
* Targeting Monitoring report: start from a template (PDM targeting accuracy, process monitoring, donor brief) with a finding written from each chart's numbers; an executive summary with traffic lights, an error map and what to do; save the report as a template to compare the next round; checks before export. Everything that existed stays as it was.
* Data quality report (HTML) on the Data Quality sidebar: completeness, duplicate IDs and records, outliers in the mapped numbers, GPS, area-name spelling variants, enumerators to review and the corrections made.
* Spot-check report: insight tiles, agreement by enumerator and area, the most frequent changes, which way number answers move, households to re-check first; only the fields that need attention are tabled and the chart shows the 15 lowest. The Excel export adds By_enumerator / By_admin sheets. Export sample sits with the sample; the back-check exports are on the sidebar.
* Duplicates: no column is picked by default; fuzzy matching uses a similarity percentage on the whole text (it used to match inside longer texts and group unrelated records).
* Enumerator performance: taller charts, insight tiles (workload balance, interview length, busiest day, daily pace, empty answers), flagged enumerators and the team's usual range on the charts, and a daily workload heatmap.
* One loader for the whole app: the busy card and the full-screen waiter are the same card, with a console of the steps running in the background (reading, encoding, splitting, encrypting, fitting, MODA pages, panels redrawn).
* The design and implementation verdicts are a clear status panel: household icon, status, the Advisory's wording and both errors against the tolerance.
* Beneficiary Selection: the Accuracy tab is removed (accuracy belongs to Design and Monitoring), as is the accuracy section of the selection report and Excel summary.
* Criteria screening: the quick screening ticks the associated variables in Review the variables when it runs.
* Chart axis labels are horizontal or vertical, never slanted.
* Sessions are split by phase: Design, Selection and Monitoring each save to their own file and load beside the others; datasets are stored as Parquet inside the encrypted session (a 164 MB session became 18 MB + 5 MB). Autosave saves only the phase that changed.
* Restoring a Targeting Design on large data no longer loses the fitted model.
* Criteria screening: creating suggested yes/no variables now leads to the Quick screening tab; "Review the variables" is renamed "Review the variables"; odds ratios and their 95% CI show at most 4 decimals (huge ratios read "> 9999").
* Faster on large data (measured on 102,000 households): start 32 s to 21 s, import 20 s to 7 s, setup validation to Overview 17 s to 10 s.
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
* After a MODA import on any page (Design, PDM / baseline, targeting process), the MODA dialog closes and the "Data imported" summary confirms it: the form's name, the headline figures and what was done with the form definition (choice labels applied, in the app's language when the form has it; select-multiple questions split; GPS split; or that the definition could not be downloaded). The pages name their data source. The form definition request now sends the same key header as the data requests.
* PDM / baseline analysis: the beneficiary column can be any column with exactly two answers ("Beneficiary / Non-beneficiary", "Assisted / Not assisted", 1/0...); the officer confirms which answer means received assistance (guessed).
* Targeting Design: Criteria Screening now comes right after the Vulnerability Framework and screens every yes/no variable of the data (profile table, quick screening, correlation matrix, statistics, drops); variables with several answers and numbers get suggested yes/no versions (the answers above average, the best cut-off) created in one click; the kept variables pre-fill Criteria Selection, which feeds the model. Order: 1 Vulnerability Framework, 2 Criteria Screening, 3 Criteria Selection, 4 Model & weights, 5 Threshold & errors (guide and design report follow it).
* Variables a registration team cannot observe are blocked from screening and selection, with the reason: expenditure, prices, coping strategies and their reasons, MEB / UBT / transfer values, food consumption (FCS, HDDS and their food groups), phone numbers, indebtedness.
* Vulnerability Framework: the chart by area is 100% stacked columns (vulnerable / not vulnerable) with a dotted line at the overall share, also in the design report.
* Beneficiary Selection: "Caseload per area" sets each area's own caseload, in households or as shares of a total caseload (the shares must add up to 100%), with a required rationale. The dialog shows households, people, eligible households and eligible people per area with totals, and flags a caseload above the eligible households. The plan is its own table in the selection report (with the rationale) and a Caseload_per_area sheet in the export. "Allocate" splits a total caseload across the areas in one click: in proportion to eligible households, households, eligible people or people, or, when the data carries IPC figures, to the areas in IPC phase 3+, to eligible households weighted by IPC phase, or to the IPC phase 3+ population (exact totals; a suggested rationale is filled in).
* Data Quality: Edit on a flagged name no longer hangs; Edit, Save and Delete find the selected record reliably, and unmapped fields show a dash.
* Every download names the country office in its file name (e.g. Targeting_design_report_Mali_2026-09-25_14h30.html), and every report and Excel summary sheet shows it.
* Installation: the repository is private; README explains the read-only access token (creating it, saving it once with gitcreds, installing with pak). The update check uses that token.
* Criteria Screening is in four tabs, in working order: 1. Binarise: suggested cut-offs, 2. Quick screening (runs by itself; Bonferroni, Holm, Benjamini-Hochberg; "Tick only the associated ones"), 3. Review the variables, 4. Correlations and statistics (Select opens it).
* Criteria Selection reviews each criterion: observable at registration, not an outcome indicator, validated by the community (with "tick all" per column). Only criteria with all three go on to the model; the others are held back and listed. The reviews moved here from the model step, are kept with the session and feed the export and the adopted scorecard.
* Criteria Screening tables show 25 rows before scrolling (the suggestions table pages by 25); p-values show 4 decimals at most ("< 0.0001").
* Stepwise selection can run backward, forward or both ways (with AIC or BIC); the direction is kept in the run history and the session and described in the design report.
* The model runs on any chosen criteria: a missing criterion answer counts as "no", as it does in the score, instead of dropping the household (criteria asked to different subgroups used to leave "no complete rows"). The fit says how many answers were counted as "no"; Criteria Selection flags criteria with more than 20% missing; an empty survey-weight column gets its own message.
* Caseloads can be counted in people (beneficiaries, the default when household size is mapped) or in households: households are served most vulnerable first while the people served stay within the caseload; the per-area dialog, its flags, the allocation and the report table follow the chosen unit.
* A reminder after 20 minutes of work not saved under a name ("Save now" / "Later"); TARGETWISE_SAVE_REMINDER_MIN changes the delay, 0 turns it off.
* Caseload per area: a reference figure can be typed per area, its type chosen (IPC phase 3, 4, 5 or 3+ population, HNRP people in need or targeted; pre-filled when the data carries IPC figures); "Allocate" splits the total caseload in proportion to it; the figure is kept with the plan and shown, under its name, in the report and export table.
* Prioritisation rationale is mandatory: for the per-area plan (only a suggested wording is offered, never filled in) and for a total caseload.
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
