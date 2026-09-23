# Targeting guidance compliance map

What the app does against each requirement that published targeting guidance
places on a tool like it, and what it does not do yet. Organisational
requirements (working groups, field-level agreements, consent, SEA channels)
are out of scope for software and are not listed.

Status: **Done** = implemented and tested; **Partial** = covered in part (the
gap is stated); **Gap** = not implemented.

## Sources

| Short | Document | Where |
|---|---|---|
| OGN | WFP, *Targeting and Prioritization Operational Guidance Note*, January 2021 (WFP-0000122035) | `reference/WFP_Targeting_Prioritization_OGN_2021.pdf` |
| ADV1–3 | WFP APP-FA Targeting Advisories 1/2025 (outcome indicators as criteria), 2/2025 (design vs implementation errors), 3/2025 (ROC, thresholds, model comparison) | `reference/` |
| CC | UNHCR-WFP Joint Hub, *Community consultations to inform targeting and prioritization* | Joint Hub site |
| MM | UNHCR-WFP Joint Hub, *Mixed methods for better targeting* | Joint Hub site |
| RC | UNU-MERIT for the Joint Hub, *Targeting in refugee contexts: costs* | Joint Hub site |
| IFRC | ICRC/IFRC Livelihoods Centre, *Targeting in urban and rural contexts* | livelihoodscentre.org |

Could not be retrieved (access-controlled download pages): the UNHCR-WFP
*Joint Guidance: Targeting of assistance to meet basic needs*, the UNHCR-WFP
*Joint Principles for Targeting Assistance*, and the ICRC EcoSec *Targeting,
selection and prioritization* guidance. Drop the PDFs into `reference/` to have
them added to this map.

## Design (phase 1, assessment data)

| # | Requirement | Source | Status | In the app |
|---|---|---|---|---|
| 1 | Offer the method catalogue and allow combinations | OGN p19, p24 | Done | Beneficiary Selection › *Targeting approach*: hybrid, scorecard/PMT, categorical, community-based, geographic, blanket, self-targeting (`R/utils_approach.R`) |
| 2 | Consider blanket assistance when few households are not vulnerable | OGN p18 | Gap | No prompt from the outcome prevalence |
| 3 | Screen candidate criteria against the outcome statistically | OGN p29 | Done | Variable selection › Quick screening (likelihood-ratio / Fisher tests, multiplicity adjustment), then correlation matrix and descriptive statistics before dropping |
| 4 | Find cut-offs for continuous variables (household size, dependency ratio) | OGN p29 | Gap | Criteria must arrive binarised; no variable constructor yet |
| 5 | Design errors on assessment data, plus a profile of the wrongly included/excluded | OGN p30 | Partial | Design error matrix and verdict; no profile of the error cells |
| 6 | Cumulative error table as criteria are added | OGN p34 | Gap | |
| 7 | Compare methods / criteria sets | OGN p31, ADV3 | Done | Model comparison (logistic, random forest, XGBoost, the scorecard as adopted) on held-out data; four weighting schemes |
| 8 | Standard error formulas; exclusion errors first in emergencies | OGN p59, ADV2 | Done | `design_errors()`, `targeting_metrics()`; caption under the matrix |
| 9 | Error estimates are valid only for Tier 1 assistance | OGN p30 | Done | Caption under the design matrix |
| 10 | Criteria are evidence-based, sensitive, specific, feasible, acceptable, verifiable | OGN p28, ADV1 | Partial | Outcome indicators blocked as criteria; per-criterion *Verifiable* and *Community validated* flags. The other four qualities are not recorded |
| 11 | Protection / "critical" criteria that give access on their own | OGN p30, IFRC p7 | Done | Hybrid with *Either (criteria OR score)*, or OR-groups in Eligibility rules |
| 12 | Qualitative validation recorded next to the quantitative one | OGN p31, CC p9, MM | Partial | *Community validated* flag per criterion; no notes or frequency of mention |
| 13 | Date the weights; review every 2–3 years (annually in dynamic contexts) | OGN p31, p51, RC p22 | Done | Scorecard records *Designed on*; Beneficiary Selection warns after 24 months |
| 14 | Threshold and tolerance rationale documented | ADV2, ADV3 | Done | Youden and caseload helpers; threshold rationale required in the export |

## Selection (phase 2, registration data)

| # | Requirement | Source | Status | In the app |
|---|---|---|---|---|
| 15 | Check registry completeness and quality against the criteria | OGN p39 | Done | Data Quality tabs; scorecard crosswalk and readiness (unmapped criteria flagged) |
| 16 | Threshold reflects budget, transfer size and frequency | OGN p26 | Partial | Caseload threshold on Design; caseload prioritisation on Selection. Transfer value and frequency are not modelled |
| 17 | Tiered assistance (higher value for the most vulnerable) | OGN p46 | Gap | Score bands exist on Design, but tiers are not carried into the list |
| 18 | Prioritise by tightening the rule, and show the extra exclusion | OGN p33, p47 | Done | Prioritisation (total or per-area caseload, most vulnerable first); accuracy panel shows the extra points of exclusion |
| 19 | Per-area prioritisation | OGN p24 | Partial | Caseload per Admin 1/2/3. Ranking the areas by vulnerability share is not automated |
| 20 | Keep "not eligible" separate from "eligible but not prioritised" | OGN p46, ADV2 | Done | *Excluded by design* reported separately, exported on its own sheet and not counted as exclusion error (Selection and PDM) |
| 21 | Plain-language record of criteria, threshold and ceiling | OGN p36, p55 | Partial | `Selection_Metadata` sheet (approach, rules, prioritisation, notes) and the scorecard workbook; no one-page entitlement sheet |
| 22 | Appeals: log them and re-run eligibility after data updates | OGN p36–37 | Gap | The Audit Trail logs data corrections, not appeals |
| 23 | Complaints and feedback analysis | OGN p48, p64 | Gap | |
| 24 | Verification revisits (~10%), including non-selected households | OGN p48, p58, IFRC p12 | Partial | Spot Checking samples the registry (selected or not) and compares the back-check; the verifier is not recorded |
| 25 | Data minimisation | OGN p10, p40 | Gap | The selection export includes every column |

## Monitoring (phase 3, PDM data)

| # | Requirement | Source | Status | In the app |
|---|---|---|---|---|
| 26 | PDM covers non-beneficiaries; implementation errors judged by their own table | OGN p49, ADV2 | Done | PDM tab; Advisory 2 implementation decision table (`implementation_verdict()`) |
| 27 | Keep excluded-by-design out of implementation exclusion errors | ADV2 | Done | Optional *Prioritised column* on the PDM tab |
| 28 | Stratify by modality / transfer value | OGN p49 | Partial | *Break down by* any column; no dedicated modality view |
| 29 | Warn about reporting bias once criteria are known | OGN p51 | Gap | |
| 30 | Outcomes before and after a prioritisation change | OGN p50 | Gap | |
| 31 | Check assisted households meet the observable criteria | OGN p48 | Gap | |
| 32 | A living decision record (method, rationale, criteria, validation) | OGN p55 | Partial | Spread over the scorecard workbook and the selection metadata; no single consolidated document |

## Priorities for the next round

Items 6 and 5 (cumulative and profiled design errors), 4 and 16 (variable
constructor), 17 (tiers), 22–23 (appeals and complaints log) and 25 (export
column selection) are the largest remaining gaps.
