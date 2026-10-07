# TargetWise

*Reaching the most vulnerable.*

**An R package and Shiny application for humanitarian targeting: design the targeting on assessment data, select beneficiaries on registration data, and check the selection on a post-targeting survey before distribution (or on post-distribution monitoring data).**

It follows the WFP *Targeting and Prioritization Operational Guidance Note* (2021) and the WFP APP-FA Targeting Advisories 1/2025 (outcome indicators are not criteria), 2/2025 (design vs implementation errors) and 3/2025 (ROC curves and thresholds). It is built for large registries (millions of rows), keeps an audit trail of every change, and documents each step in a self-contained report that serves as evidence for review and audit.

---

## Contents

1. [What it does](#what-it-does)
2. [Installation](#installation)
3. [Launching the app](#launching-the-app)
4. [Try it with the demo data](#try-it-with-the-demo-data)
5. [User guide](#user-guide)
6. [Data requirements](#data-requirements)
7. [Methods and references](#methods-and-references)
8. [Configuration](#configuration)
9. [Sessions, privacy and security](#sessions-privacy-and-security)
10. [Working with large data](#working-with-large-data)
11. [Deployment](#deployment)
12. [Development](#development)
13. [Citation, author and contact](#citation-author-and-contact)
14. [Licence](#licence)

---

## What it does

The app follows the targeting cycle in three phases, each working on its own dataset:

| Phase | Dataset | What you get |
|---|---|---|
| **1. Targeting Design** | Needs-assessment survey with a food-security outcome (e.g. CARI) | A weighted **scorecard** of household criteria, its eligibility threshold, design inclusion/exclusion errors, a verdict against your tolerance band, and a full HTML design report |
| **2. Beneficiary Selection** | Household registration list | Data-quality checks and corrections, spot-check sampling, and a beneficiary list produced by the targeting approach you choose (scorecard, categorical, hybrid, community-based, geographic, blanket), with prioritisation when resources are short |
| **3. Targeting Monitoring** | Post-targeting survey (preferred) or PDM | A verification sample of selected and non-selected households; implementation inclusion/exclusion errors and coverage, judged with the Advisory 2/2025 decision table, with a decision per area before distribution |

---

## Installation

### Requirements

- **R ≥ 4.6** (the package is developed and checked against R 4.6).
- **Rtools (Windows), required to build the package.** Installing from GitHub (route A), with renv, or from a clone builds TargetWise from its source, and R cannot do that without Rtools. Install the Rtools that matches your R version (**Rtools 4.6 for R 4.6**) from <https://cran.r-project.org/bin/windows/Rtools/>, keeping the default options, then restart R and check:

  ```r
  install.packages("pkgbuild")
  pkgbuild::check_build_tools(debug = TRUE)   # must end with TRUE
  ```

  On macOS the equivalent is the Xcode command line tools (`xcode-select --install` in a terminal); on Linux, `build-essential` (Debian/Ubuntu) or the "Development Tools" group (Fedora/RHEL). Only the offline installer (route B) works without Rtools: it ships the package already built.
- A modern browser (Chrome, Edge, Firefox).

The app runs entirely on your computer and **works offline** once installed; only the MODA/Kobo/ODK import and the map's background tiles need a connection. The repository is **private**: installing from GitHub needs an access token (a read-only key given by the maintainer). Choose the route that fits:

| Route | Internet needed | Needs |
|---|---|---|
| **A. From GitHub** (recommended) | Yes, to install | **Rtools** and an access token |
| **B. Offline installer** (Windows) | No | The installer file (no Rtools) |

### A. From GitHub (internet, Rtools, access token)

**0. Install Rtools** (Windows) as described under [Requirements](#requirements), and check that `pkgbuild::check_build_tools(debug = TRUE)` returns `TRUE`. Without it the installation stops with *"Could not find tools necessary to compile a package"*.

**1. Save the token once on the computer.** The maintainer gives you a token (it starts with `github_pat_`). In R or RStudio:

```r
install.packages(c("pak", "gitcreds"))
gitcreds::gitcreds_set()
```

When asked for a password or token, paste the token and press Enter. It is kept in Windows' credential manager (or the macOS keychain), not in a file, and every later install and update uses it. (Alternative: put the line `GITHUB_PAT=github_pat_...` in your `.Renviron` file, opened with `usethis::edit_r_environ()`, then restart R.)

**2. Install:**

```r
pak::pak("bbbagoa/TargetWise")
```

`pak` finds the token saved in step 1 (or in `GITHUB_PAT`) by itself.

Every dependency is installed from CRAN at the same time, and TargetWise itself is built with Rtools. The first installation takes a few minutes.

- **A given version** (for example the one your office validated): `pak::pak("bbbagoa/TargetWise@v0.1.0")`, using a tag from the [Releases](https://github.com/bbbagoa/TargetWise/releases) page.
- **The optional machine-learning models** (random forest, XGBoost, naive Bayes, neural network, SVM): `install.packages(c("ranger", "xgboost", "e1071", "nnet"))`.

**Common errors**
- `HTTP error 404. Not Found` (or `Bad credentials`): the token is missing, mistyped, expired, or does not give access to this repository. Run `gitcreds::gitcreds_set()` again with the current token (choose *Replace these credentials*); ask the maintainer for a new one if it expired.
- `HTTP error 403. API rate limit exceeded`: only without a token; set it as in step 1.
- `Could not find tools necessary to compile a package` (or `WARNING: Rtools is required to build R packages`): Rtools is missing, or its version does not match R (Rtools 4.6 for R 4.6). Install the matching Rtools, restart R, and check with `pkgbuild::check_build_tools(debug = TRUE)`. If you cannot install it (no admin rights), use the offline installer.
- Behind a proxy: set `Sys.setenv(https_proxy = "http://proxy:port")` before installing.

### B. Offline installer (Windows, no internet)

Ask the maintainer for the file `TargetWise_<version>_offline_windows_R<x.y>.zip`, shared by USB key, email or SharePoint. It contains the package and every package it depends on.

1. Install **R** of the version in the file name (e.g. R 4.6) if it is not installed. The bundle may include the R installer.
2. Unzip the file anywhere.
3. Open R or RStudio, set the working directory to the unzipped folder (R: *File > Change dir…*; RStudio: *Session > Set Working Directory > Choose Directory…*), and run:

```r
source("install.R")
```

4. Start the app any time with `TargetWise::run_app()`.

### Updating

**How you know an update is available.**
- **In the app.** When the app starts with an internet connection, it compares your version with the one on GitHub and shows a notice, *"Update available: version x.y.z"*, with the command to run. It checks at most once a day and is silent offline. Turn it off with `TARGETWISE_UPDATE_CHECK=false`.
- **By email.** On the repository page, click **Watch → Custom → Releases** (needs a free GitHub account).
- **Offline users** receive the new offline installer from the maintainer.

**How to update.** Close the app, restart R, and run `pak::pak("bbbagoa/TargetWise")` again (route A; the token saved in step 1 is reused), or `source("install.R")` from the new offline bundle (route B). **Then restart R once more** before `TargetWise::run_app()`: an R session that had the old version loaded keeps running it. The app checks this itself: started from a session that loaded an older installation, it stops with *"TargetWise was updated after this R session loaded it. Restart R…"*. The browser cannot keep the old version either: the app's styles and scripts get new addresses with every installation.

### For the maintainer: the access token

The repository is private, so installing needs a token that can read it. Create one **fine-grained, read-only** token for the users:

1. On GitHub: your photo › **Settings › Developer settings › Personal access tokens › Fine-grained tokens › Generate new token**.
2. **Token name**: e.g. `TargetWise install (read-only)`. **Expiration**: a date that suits you (e.g. one year; you will have to give out a new one then). **Resource owner**: your account.
3. **Repository access**: *Only select repositories* › `bbbagoa/TargetWise`.
4. **Permissions › Repository permissions › Contents: Read-only** (GitHub adds *Metadata: Read-only* by itself). Nothing else.
5. **Generate token**, copy it (it is shown once) and share it with the users through a private channel (not in an email to a list, not in the repository).

This token can only download the code, never change it. If it leaks, delete it on the same page and create a new one. People who contribute to the code are better added as collaborators (*Settings › Collaborators*) with their own accounts.

What changed in each version is listed in [NEWS.md](NEWS.md). Your saved sessions, setup profiles and country office setting are kept across updates.

### Reproducible install with renv (for deployments)

The repository ships an `renv.lock` with the exact package versions used in development (needs **Rtools**, as in route A):

```r
# in a clone of the repository
install.packages("renv")
renv::restore()        # installs the locked versions into a project library
renv::install(".")     # installs TargetWise itself
```

---

## Launching the app

```r
library(TargetWise)
run_app()
```

The app opens in your browser. Useful options:

```r
run_app(options = list(port = 4321, launch.browser = TRUE))   # fixed port
run_app(options = list(host = "0.0.0.0", port = 3838))        # reachable from other machines
```

Uploads up to **2 GB** are accepted by default.

---

## Try it with the demo data

Two synthetic datasets are installed with the package:

```r
system.file("extdata", "assessment_demo.csv",   package = "TargetWise")  # 1,500 households, CARI outcome
system.file("extdata", "registration_demo.csv", package = "TargetWise")  # 1,500 registered households
```

1. **Targeting Design**: load `assessment_demo.csv`. The outcome `FSI_CARI2_2class` is picked automatically.
2. **Beneficiary Selection › Load registration data**: load `registration_demo.csv`, then map the variables.

---

## User guide

### Welcome page

The Welcome page explains the three phases and links to each. The navbar has a **light/dark** switch (the app always opens in light mode), a **language** selector (English, French) and the **Session** toolbar (Save / Load / Clear).

### Phase 1: Targeting Design

A stepper across the top shows where you are: *Data → Vulnerability Framework → Criteria → Model & weights → Threshold & errors*. Click a step to jump to it. Each step ends with **Back** and **Continue** buttons. Continue stays disabled until the step is complete, and a message says what is missing.

**Load the assessment data.** Use the *Load assessment data* field, or *Use the dataset currently loaded* to reuse the registration data. The **Variable calculator** builds variables the data does not carry yet (see below).

1. **Vulnerability Framework.** Choose the food-security outcome and the level that means *vulnerable*. CARI-type variables with two levels are proposed first.
   **Welfare measured instead (consumption or expenditure)?** Choose *Welfare measure: proxy means test (PMT)*, the World Bank's method (Grosh & Baker 1995; Grosh et al. 2008). Pick the welfare variable (per household with the household size, or per person) and the poverty line per person, or the poorest share of households; the page checks the data requirements (sample size, welfare above zero, poverty rate, extreme values, households per proxy). Yes/no criteria are tested against being poor, and numeric proxies (household size, rooms) can be added. The settings sit on one line and apply once you click **Validate**. Models: least squares on log welfare per person, quantile regression at the poverty rate (usually lowers under-coverage; Brown, Ravallion & van de Walle 2018), ridge and lasso (cross-validated shrinkage), and random forest or XGBoost regressions (McBride & Nichols 2018), each validated on held-out households and comparable side by side. Accuracy is reported in PMT terms: leakage, under-coverage, coverage of the poor, targeting accuracy, targeting differential and the CGH indicator, with charts of selection by welfare decile, the errors as the cut-off moves, and residuals. Points are 100 x each coefficient (one point is about 1% less predicted welfare; numbers score per unit, a missing number takes the average), the threshold starts at the poverty line, and the page shows the predicted welfare per person each threshold stands for. Expect exclusion errors of 40-60% at typical coverage: the app says so and suggests the remedies.

   **No outcome indicator?** Choose *No outcome indicator: build a vulnerability ranking* (after a sudden shock, or with data from a partner or a registry). The criteria are then chosen rather than tested, and the model step offers **deprivation counting** (Alkire-Foster), a **PCA or MCA index** turned towards an *anchor criterion* you name as a clear sign of vulnerability, or **household profiles** from latent class analysis, k-means or Ward clustering (tick the profiles to target; the points reproduce them, with their fidelity shown). No inclusion or exclusion error can be measured: the threshold step shows internal consistency (Cronbach's alpha) and the stability of the selection over 20 resamples, and adoption needs the rationale. The result is called a **vulnerability ranking** (in the exports, the report and Beneficiary Selection). Validity figures stand in for errors: stability and rank agreement across resamples, Cronbach's alpha, profile separation (silhouette, entropy, a comparison of 2 to 8 profiles) and what the selection concentrates, by area too. Once PDM or verification data carry an outcome, **Monitoring > PDM > Calibrate the ranking** measures its errors and suggests a better threshold.
2. **Criteria.** One table lists every yes/no variable of the data (no model is fitted here). Columns that look like outcome indicators (FCS, rCSI, LCSI, CARI, HHS…) or cannot be observed at registration are refused, as Advisory 1/2025 requires; they are listed in a fold under the table.
   - Each row shows the **Use** tick, the share among vulnerable and other households, the odds ratio (95% interval on hover), the adjusted p-value of a one-variable test (likelihood-ratio or Fisher's exact, adjusted by Benjamini-Hochberg, Holm or Bonferroni), the variable it overlaps with most, and the share of missing answers.
   - The associated variables come ticked in **Use**, except the weaker of any pair correlated above the |r| cut-off. After changing the significance level, the adjustment or the cut-off, click **Run the tests** (this resets the ticks). **Continue to the model** sends the ticked criteria.
   - **Binarise variables** opens the variable calculator's bulk binarise. *Best split for vulnerability* finds, for each selected column (or every column with **Screen the entire database**), the cut-off (numbers) or answer group (3 to 15 answers) that separates vulnerable households best; preview the suggestions with their gap and strength, untick what you do not want, and create them (named `..._Bin` by default): they join the table. *Same rule for every column* applies one rule to a block of columns.
   - **Correlations** asks for a threshold, then lists the groups of ticked variables correlated at or above it and proposes the one to remove in each group; **Remove the ticked from Use** applies it. The design report lists the same pairs. New binarised variables are labelled after their source ("HHSize: at least 7").
   - The search box above the table filters it by variable name or label.
3. **Model & weights.** The sliders button beside the model opens its settings: hold-out % and seed, PCA/MCA axes, number of profiles, and **tuning by k-fold cross-validation** for the models with hyperparameters (decision tree, random forest, XGBoost, boosted stumps, SVM, neural network, naive Bayes). A **decision tree** also shows its rules.
    The settings are one band of three groups: *1. Model* (model, weighting scheme, stepwise selection: none, backward, forward or both directions, with AIC or BIC), *2. Criteria and data* (criteria in the model, optional survey weights, hold-out, seed) and *3. Comparison* (the models compared per variable and by AUC/ROC); **Fit model** closes the band. In detail:
   - **Model**: logistic regression, stepwise logistic, weight of evidence or boosted stumps. All give a fixed number of points per criterion.
   - **Weighting scheme**: odds ratio (APP-FA reference), log-odds, whole points out of 10, or equal weights.
   - **Hold-out** share and **seed**, **survey weights**, and optional **benchmarks** (random forest, gradient boosting).

   Click **Fit model**. The **Model estimates** table shows β, SE, the odds ratio with its 95% interval and a colour-coded p-value; points and the review flags (*Verifiable*, *Community-validated*) are editable in place. Below it:
   - **Model comparison**: held-out AUC of the card against the benchmarks.
   - **Each variable under every model**: a table and chart showing whether a weight is robust to the method.
   - Charts of weight/direction, prevalence and effect by model.

   **Iterate**: untick criteria in *Criteria in the model* or change any setting, then fit again. Every fit is kept in the **run history**, and **Restore** brings any run back.
5. **Threshold & errors.** A new fit starts at the threshold that minimises the larger of the two design errors. Helpers: **Minimise errors**, **Balance (Youden)** and **Fit to caseload**. The page shows:
   - the AUC, the eligible share, and the inclusion/exclusion error rates on a track with your **tolerance band** coloured in;
   - the **design error matrix** and the Advisory 2/2025 **verdict**;
   - the ROC curve, score distribution, score by vulnerability (boxplot), what drives the score, criteria met, and coverage by criterion.

   Record the **rationale** for the band and the threshold (Advisory 2/2025 requires it), then click **Adopt this scorecard**.

**Exports** (sidebar):
- **Scorecard (Excel)**: a workbook that Beneficiary Selection can load back.
- **Scorecard (JSON)**.
- **Design report (HTML)**: a single file documenting the data, calculated variables, outcome, kept variables, model, estimates, comparison, threshold, errors and verdict, plus a **Methods** section explaining every technique used, with references.
- **Registration form (XLSForm)**, once the design is adopted: a draft form for KoboToolbox, ODK or MODA to register households with the same criteria. It asks consent, the household ID, the enumerator, the areas (cascading lists from the registration data, when loaded), GPS, the head of household as beneficiary (first name, surname, third name if any, sex, date of birth and age, marital status, phone, identity document, optional photo, household size), an optional alternate recipient (names, sex, age, relationship, optional photo) and one question per criterion, and calculates in the background each criterion's points, the vulnerability score, eligibility at the adopted threshold and two vulnerability categories (quartile and quintile of the score on the design data). The questions and choices are in English and French (area names and criterion labels are copied from your data in both columns, to translate if needed). It is a draft: adjust the questions (criteria built in the calculator are asked under their names) and check it in your form builder before use. Unlike the other exports it is not locked, so it can be edited.

### Variable calculator

Available on the Targeting Design data card and on the registration import page. It has three modes:

- **Conditions (yes/no)**: combine tests (equals, is one of, at least, contains, is missing…) with AND/OR, coded 1/0 or Yes/No. Under each condition the app shows the column's **categories** (click one to use it) or its **range and quartiles**.
- **Formula**: numeric variables such as a dependency ratio, e.g. `(n_children + n_elderly) / pmax(n_adults, 1)`. Only column names and a whitelist of arithmetic and recoding functions are accepted.
- **Bulk binarise**: apply one rule to many similar columns at once. Pick the columns by name (*Select matching*), set the rule and a prefix (e.g. `Targ_`), and each column becomes a 0/1 variable. The preview lists every new variable with its prevalence.

Every variable created on the registration data is written to the **Audit Trail**, and variables created on the assessment data appear in the design report.

### Phase 2: Beneficiary Selection

1. **Load registration data**: a local file (Excel, SPSS, Stata, CSV, Parquet), or pull it from **MODA, Kobo Toolbox or ODK Central**.
2. **Variable Definition & Setup**: map your columns to the app's fields: unique ID, admin levels, GPS, household-head sex and age, household size, vulnerability score, eligibility, survey weights… Only the unique ID and area level 1 are required: leave the others on *Not in my data* when your data do not have them, and the parts of the app that need them are switched off with the reason. The app guesses the mapping from column names, labels (English, French, Spanish, Portuguese) and content, with a badge saying how sure it is. A review step then standardises the answers (Homme/Femme, PDI, Oui/Non, 1/2… into Male/Female, IDP, Yes/No; the original columns are kept), reads the collection date whatever its format, computes the head's age from a date of birth, checks the content (repeated IDs, GPS at 0,0 or far from the others, implausible ages or household sizes…) and shows what the data allow. Save the mapping as a setup profile: it carries the standardisation too, and your country office's profile is applied automatically on the next import.
3. **Overview**: one screen. The map fills the left half; on the right, the data collection stays in view (households, individuals, places, days, pace, enumerators, interview length, households per day by area) and three sections fold below it: who is in the data (head's sex and age, household size, children under 5, pregnant or lactating women, older people, disability, residence), their vulnerability (score, groups, eligibility, and how they differ across household profiles), and a free cross-tabulation. The figures follow the map: zoom on an area and they describe the households in view. Whatever is not mapped is left out. The Overview report exports the same content.
4. **Data Quality**: spelling and integrity, location name normalisation, missing data, outliers (IQR, z-score, MAD; mean, median or KNN imputation), duplicates, and enumerator performance. Every correction is logged.
5. **Spot Checking**: draw a verification sample (e.g. 10 %, OGN), export it, and compare the back-check.
6. **Selection**:
   - Choose the **targeting approach**: hybrid, scorecard/PMT, categorical, community-based, geographic, blanket or self-targeting.
   - Load an **adopted scorecard**, or its Excel export. A crosswalk auto-detects the matching registration columns.
   - Add eligibility rules, then **prioritise** (total caseload, or caseload per area, most vulnerable first).

   Eligible households cut by prioritisation are reported as **excluded by design**, not as exclusion errors. The export contains the selected list, the excluded-by-design list and the full metadata.
7. **Audit Trail**: every modification, exportable to Excel/CSV.

### Phase 3: Targeting Monitoring

**Measure implementation errors before distribution (recommended).** In step 0, draw the verification sample from the current selection: households selected and not selected, area by area (those excluded by design are left out), sized from a margin of error or a fixed number, with a reserve list. Survey them before any distribution, load the survey, match it on the household ID (the group comes from the list) and weight it from the sample design. Each area then gets its own errors and a decision: proceed, review the list first, or pause the distribution there. A post-distribution monitoring (PDM) survey can still be analysed, but it is the least preferred option: nothing can be undone after distribution, vulnerability may have changed, and the assistance itself may have changed some answers.

With a PDM extract (or a survey not drawn in the app), map the eligibility (ground truth) and beneficiary columns. Optionally also map a prioritised column, a breakdown unit and weights. Click **Compute accuracy** to get the implementation inclusion/exclusion errors, coverage, precision and recall, the confusion matrix, coverage by unit, and the Advisory 2/2025 implementation verdict.

---

## Data requirements

| Dataset | Must contain | Notes |
|---|---|---|
| Assessment | A food-security outcome with two levels (or one you can recode), and yes/no candidate criteria | Other columns can be binarised with the calculator. A survey-weight column is optional. |
| Registration | One row per household and a unique ID | Admin levels, GPS, household size, vulnerability score and weights are used when mapped. |
| PDM | An eligibility flag and a received-assistance flag | Yes/No, 1/0, TRUE/FALSE and eligible/ineligible are all understood. |

Accepted formats: `.xlsx`, `.xls`, `.sav`, `.dta`, `.csv`, `.parquet`. CSV and Parquet load fastest.

---

## Methods and references

Each design report's **Methods** section gives these explanations for the choices actually made. In brief:

| Method | Used for | Reference |
|---|---|---|
| Phi correlation and a findCorrelation-style drop rule | Flagging criteria that duplicate each other | Kuhn (2008), *J. Stat. Software* 28(5) (caret) |
| Likelihood-ratio test / Fisher's exact test | Quick screening of each candidate | Agresti (2013), *Categorical Data Analysis* |
| Benjamini–Hochberg, Holm, Bonferroni | Multiplicity adjustment | Benjamini & Hochberg (1995), *JRSS B* 57; Holm (1979) |
| Logistic regression | Scorecard weights (APP-FA reference) | Hosmer, Lemeshow & Sturdivant (2013), *Applied Logistic Regression* |
| Backward stepwise selection on AIC | Shorter card | Venables & Ripley (2002), *Modern Applied Statistics with S* |
| Weight of evidence | Robust univariate weights | Siddiqi (2017), *Intelligent Credit Scoring* |
| Boosted stumps (xgboost, depth 1) | Additive boosting-based weights | Friedman (2001), *Ann. Statist.* 29(5); Chen & Guestrin (2016), KDD |
| Random forest, gradient boosting | Benchmarks only | Breiman (2001), *Machine Learning* 45; Chen & Guestrin (2016) |
| Stratified hold-out, ROC and AUC | Honest accuracy | Fawcett (2006), *Pattern Recognition Letters* 27 |
| Youden's J, minimax threshold, caseload threshold | Threshold helpers | Youden (1950), *Cancer* 3 |
| Design and implementation errors, tolerance bands | Verdicts | WFP Targeting Advisory 2/2025; WFP Targeting OGN (2021) p. 59 |

`reference/COMPLIANCE.md` maps each requirement of the WFP guidance, and of UNHCR-WFP Joint Hub and ICRC/IFRC material, to what the app does and what remains a gap.

---

## Configuration

Set these environment variables, for example in `.Renviron` or in your hosting platform:

| Variable | Effect |
|---|---|
| `TARGETWISE_SESSION_PASSPHRASE` | Derive the session encryption key from this passphrase, so saved sessions open on any machine that shares it. Without it, a random per-install key is used. |
| `TARGETWISE_SESSION_DIR` | Where encrypted sessions are stored. Default: `tools::R_user_dir("TargetWise", "data")`. |
| `TARGETWISE_REQUIRE_AUTH` | `true` on any shared deployment: the app refuses anonymous use and keeps one session store per signed-in user. |
| `TARGETWISE_USER` | Fixed user name when the platform does not provide one (single-user installs). |
| `TARGETWISE_EXPORT_PASSWORD` | Password needed to unlock the exported Excel files. Without it, exports are still locked against accidental edits but Excel's *Unprotect Sheet* opens them. |
| `TARGETWISE_UPDATE_CHECK` | `false` turns off the start-up check for a newer version (e.g. on a server whose administrator manages updates). |
| `TARGETWISE_RELEASES_URL` | An organisation's own copy of the releases (a web address, or a `file:///` path to a shared drive), checked for updates instead of GitHub. |
| `GITHUB_PAT` | Optional GitHub token. Not needed (the repository is public); it only raises GitHub's limit on anonymous downloads for offices sharing one connection. |
| `TARGETWISE_AUTOSAVE_MAX_MB` | Datasets larger than this (default 200 MB) are not autosaved; use *Session › Save*. |

---

## Sessions, privacy and security

- Data is processed **in memory** in the R session and never sent anywhere else.
- **Sessions** hold the registration data, the variable mapping and the audit log, plus the work done in each phase: the whole Targeting Design (assessment data, calculated variables, selection, every model run, edited points, review ticks, threshold and rationale), the Beneficiary Selection settings, the spot-check sample and back-check, and the PDM analysis. Each phase is **its own session**: Save writes one file per phase that holds work (Targeting Design, Beneficiary Selection, Targeting Monitoring), and Load brings one back without touching the others, so a selection save never rewrites the design dataset. The adopted scorecard and the eligibility rules travel with the sessions that use them; sessions saved before the split load as they are. Datasets are stored as Parquet inside the session (about 7x smaller). They are **encrypted with libsodium** before being written to disk. They autosave once there is something worth saving, and can be restored on start-up.
- **MODA/ONA API tokens are never saved.**
- On shared servers, put the app behind the platform's authentication (Posit Connect, Shiny Server Pro, ShinyProxy) and set `TARGETWISE_REQUIRE_AUTH=true`.
- Every data change (corrections, deletions, created variables) is written to the audit trail.

---

## Working with large data

- Prefer **CSV** or **Parquet** for files over 100 MB; Excel is the slowest format to read.
- Charts and tables show summaries; very large tables are paged.
- Autosave skips datasets above the configured size; save explicitly from the Session menu.
- Memory: the whole dataset is held in the R session, so plan server RAM for a few times the file size per concurrent user.

---

## Deployment

- **Posit Connect**: the repository contains `app.R` (which calls `pkgload::load_all()` then `run_app()`) and a `manifest.json`. Regenerate it with `rsconnect::writeManifest()` after any dependency change, then deploy with `rsconnect::deployApp()`; see `dev/03_deploy.R`.
- **Shiny Server / ShinyProxy / Docker**: install the package in the image and run `TargetWise::run_app(options = list(host = "0.0.0.0", port = 3838))`. Behind ShinyProxy, the signed-in user is read from `SHINYPROXY_USERNAME`.

---

## Development

Developing, testing and building TargetWise need **Rtools** on Windows (see [Requirements](#requirements)).

```r
# in a clone of the repository
renv::restore()
devtools::load_all(); run_app()   # or source("dev/run_dev.R")
devtools::test()                  # unit and app tests (testthat, shinytest2)
devtools::check()                 # R CMD check
```

Layout: a standard **golem** package.

```
R/            modules (mod_*.R) and pure, unit-tested helpers (utils_*.R)
inst/app/www  stylesheets (wfp-ui.css holds the design tokens), scripts, logos, translations
inst/extdata  demo datasets
tests/        testthat suite, including shinytest2 app tests
reference/    WFP guidance documents and the compliance map (not in the built package)
dev/          development and deployment scripts
```

### Publishing an update (maintainer)

1. Bump `Version:` in `DESCRIPTION` (e.g. 0.1.0 → 0.2.0; use 0.1.1 for a bug fix). Users are only told about a new version when this number increases.
2. Add a section at the top of `NEWS.md` describing the changes.
3. Run `devtools::test()` and `devtools::check()`.
4. Build the release on Windows, with the same R version as your users and the matching **Rtools** (it builds the Windows binary that the offline installer ships, so users of route B do not need Rtools):

   ```r
   source("dev/release.R")
   release_build()                  # add include_r = TRUE to put the R installer in the bundle
   ```

   This produces `dist/repo/`, a package repository with the source and Windows builds of this package only, and `dist/TargetWise_<version>_offline_windows_R<x.y>.zip`, the offline installer with every dependency (about 270 MB). The script stops if any dependency fails to download.
5. Push to `main` and create a GitHub release tagged `v0.2.0` with the `NEWS.md` section as description. The in-app notice reads the version from `DESCRIPTION` on GitHub, so users see it from their next start.
6. Share the offline zip with offline users (attach it to the GitHub release as well).
7. Optional: an organisation that cannot reach GitHub can host `dist/repo/` on its own server or shared drive and point the app at it with `TARGETWISE_RELEASES_URL`; users then install with `install.packages("TargetWise", repos = c("<that address>", "https://cloud.r-project.org"))`.

`AGENTS.md` documents the architecture and conventions in detail. Report issues or suggest changes at <https://github.com/bbbagoa/TargetWise/issues>; pull requests are welcome.

---

## Citation, author and contact

**Author and maintainer:** Brice Baem BAGOA, Vulnerability Analysis and Mapping, World Food Programme.
**Email:** [brice.bagoa@outlook.com](mailto:brice.bagoa@outlook.com)
**GitHub:** <https://github.com/bbbagoa/TargetWise>

To cite:

> BAGOA, B. B. (2026). *TargetWise: a workflow for humanitarian targeting design, selection and monitoring* (Version 0.1.0) [R package]. https://github.com/bbbagoa/TargetWise

In R: `citation("TargetWise")`.

---

## Licence

GPL (≥ 3). See [LICENSE](LICENSE).
