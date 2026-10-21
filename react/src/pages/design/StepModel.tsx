// Step 3, the model and the weights: one settings band (model, criteria,
// comparison) and Fit, the estimates with the points editable in place
// (inputs w_1, w_2...; Apply points), the model comparison with the run
// history, and the diagnostics folded below.
import { useEffect, useRef, useState, type ReactNode } from "react";
import {
  ArrowRight, BarChart3, ChevronDown, Download, Play, RotateCcw, SlidersHorizontal, Table2, Trash2, Trophy,
} from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton, SelectInput, TextOutput } from "@/lib/inputs";
import { Card, signalShown } from "@/lib/layout";
import { useOutputVisibility } from "@/lib/visibility";
import { EmptyState } from "@/components/Figures";
import {
  ChartCard, ChartHelp, DirBadge, Gate, KeepDialog, OrCell, PLegend, PPill, Show, StepNav, Tip, TipList, isNum, ns, sendEvent,
  useRowInput, type T,
} from "./shared";
import { DiagramCards, FitDetails, FitNote, ProfilesCard, StaleNote, useStale } from "./facts";
import type { Comparison, EstRow, Estimates, Flow, Meta, Mode, Run } from "./types";

const STEPWISE = (t: T) => [
  { value: "none", label: t("No stepwise") }, { value: "backward", label: t("Backward") },
  { value: "forward", label: t("Forward") }, { value: "both", label: t("Both directions") },
];

export function StepModel({ flow, meta, mode, t }: { flow?: Flow; meta?: Meta; mode: Mode; t: T }) {
  const method = useShinyInputValue<string>(ns("model_method")) ?? "logit";
  const stepwise = useShinyInputValue<string>(ns("stepwise")) ?? "none";
  const [more, setMore] = useState(false);
  const nof = mode === "none", pmt = mode === "pmt";
  const gear = !nof || !!meta?.axes.includes(method) || !!meta?.clusters.includes(method);
  const fit = flow?.fit;
  // computed only while this step shows (PORTING.md, "Hidden outputs wait")
  const ref = useRef<HTMLDivElement>(null);
  for (const id of ["sc_estimates", "sc_comparison", "sc_fit", "sc_profiles"]) useOutputVisibility(ns(id), ref); // eslint-disable-line

  return (
    <div className="sc-step" ref={ref}>
      <p className="sc-lead">{t("Fit a model on the retained criteria and turn it into points. Adjust any weight where local knowledge says the model is wrong -- the reference analysis does exactly this.")}</p>
      <Gate show={!!flow && flow.gates.weights} text={t("Weights come from a model fitted on the chosen criteria, so choose them first.")}
            btn="back_to_criteria" label={t("Back to Criteria")} />

      {/* one band: the model, what it is fitted on, the comparison and Fit */}
      <div className="sc-band">
        <div className="sc-band-group">
          <div className="sc-band-label">1. {t("Model")}</div>
          <div className="sc-model-row">
            <SelectInput id={ns("model_method")} value="logit" clearable={false} className="flex-grow-1" choices={meta?.models.outcome}
                         label={<>{t("Model")} <ModelTip t={t} /></>} />
            <Show when={gear} className="sc-model-gear">
              <ActionButton id={ns("model_params")} icon={<SlidersHorizontal size={14} />} variant="outline-secondary" title={t("Settings of this model")} />
            </Show>
          </div>
          <Show when={!!flow?.params} className="sc-params-line">
            <SlidersHorizontal size={12} /> <span>{flow?.params ?? ""}</span> {"·"}{" "}
            <ActionButton id={ns("model_params2")} label={t("change")} link />
          </Show>
          <Show when={mode === "outcome"}>
            <SelectInput id={ns("model_scheme")} value="odds_ratio" clearable={false} choices={meta?.schemes}
                         label={<>{t("Weighting scheme")} <Tip>{t("How model coefficients become points: odds ratios (APP-FA reference), log-odds, whole points out of 10, or 1 point per criterion.")}</Tip></>} />
          </Show>
          <Show when={nof} className="small text-muted"><TextOutput id={ns("unsup_note")} /></Show>
          <Show when={pmt} className="small text-muted">{t("Points: 100 × each proxy's coefficient on log welfare per person, so one point is about 1% less predicted welfare; a numeric proxy scores per unit.")}</Show>
        </div>
        <div className="sc-band-group">
          <div className="sc-band-label">2. {t("Criteria and data")}</div>
          <SelectInput id={ns("fit_criteria")} label={t("Criteria in the model")} multiple actions placeholder={t("Nothing selected")} />
        </div>
        <div className="sc-band-group">
          <div className="sc-band-label">3. {nof ? t("Orientation") : t("Comparison")}</div>
          <Show when={nof}>
            <SelectInput id={ns("anchor")} value="" clearable={false}
                         choices={[{ value: "", label: t("(none: more criteria met = more vulnerable)") }]}
                         label={<>{t("Anchor criterion (optional)")} <Tip>{t("Sets the direction of the ranking: a PCA or MCA axis has no direction of its own, so the index is turned so that this criterion raises it, and the cluster profiles are ranked on it. Choose a criterion that clearly marks vulnerability here. With none, more criteria met means more vulnerable (tick criteria so that yes = deprived). Deprivation counting does not use it.")}</Tip></>} />
          </Show>
          <button type="button" className="btn btn-outline-secondary btn-sm w-100" onClick={() => setMore(true)}>
            <SlidersHorizontal size={13} /> {t("More options")}
          </button>
          <div className="small text-muted mt-1 mb-2"><TextOutput id={ns("fit_more_summary")} /></div>
          <ActionButton id={ns("run_fit")} label={t("Fit model")} icon={<Play size={14} />} variant="primary" size="md" className="w-100 sc-fit-btn"
                        title={t("Fits the chosen model on the training households, turns it into points, and adds the fit to the run history.")} />
        </div>
      </div>

      <KeepDialog open={more} onClose={() => setMore(false)} title={<><SlidersHorizontal size={16} /> {t("More options")}</>}
                  footer={<><span className="small text-muted me-auto">{t("Applied at the next Fit.")}</span>
                    <button type="button" className="btn btn-primary" onClick={() => setMore(false)}>{t("Done")}</button></>}>
        {meta ? (
          <>
            <SelectInput id={ns("model_weights")} value="" clearable={false} choices={[{ value: "", label: t("(none)") }]}
                         label={<>{t("Survey weights (optional)")} <Tip>{t("Sampling weight column. When set, the model counts each household by its weight so the estimates represent the population, not the sample.")}</Tip></>} />
            <Show when={mode === "outcome"}>
              <SelectInput id={ns("compare_models")} multiple actions choices={meta.models.outcome} value={meta.compare_default}
                           label={<>{t("Models to compare")} <Tip>{t("Models fitted next to the chosen one: each variable's effect under every model, and each model's AUC and ROC on the held-out households. Machine-learning models are slow on large data: add them only when you need them.")}</Tip></>} />
            </Show>
            <Show when={pmt}>
              <SelectInput id={ns("pmt_compare")} multiple actions choices={meta.models.pmt} value={meta.pmt_compare_default}
                           label={<>{t("Models to compare")} <Tip>{t("Other PMT models fitted on the same proxies and households: R-squared on held-out households, leakage and under-coverage at the line, and how both errors move with the cut-off.")}</Tip></>} />
            </Show>
            <Show when={!nof} className="sc-pair">
              <SelectInput id={ns("stepwise")} value="none" clearable={false} choices={STEPWISE(t)}
                           label={<>{t("Stepwise")} <Tip>{t("Selection of the criteria before fitting, for any model. Backward removes criteria from the full set, forward adds them from none, both directions adds and may remove again.")}</Tip></>} />
              <Show when={stepwise !== "none"}>
                <SelectInput id={ns("stepwise_ic")} value="aic" clearable={false} choices={[{ value: "aic", label: "AIC" }, { value: "bic", label: "BIC" }]}
                             label={<>{t("Criterion")} <Tip>{t("AIC is the usual choice; BIC penalises each criterion more (log of the sample size) and keeps fewer.")}</Tip></>} />
              </Show>
            </Show>
          </>
        ) : null}
      </KeepDialog>

      <div className="sc-notes small text-muted">
        <TextOutput id={ns("model_note")} /> <TextOutput id={ns("scheme_note")} />{" "}
        <Show as="span" when={!!flow?.scheme_apply}><ActionButton id={ns("scheme_apply")} label={t("Apply this scheme to the fitted model")} link /></Show>
      </div>
      <FitNote t={t} />

      <RunsOnly t={t} show={!!fit && !fit.runs_inline} />

      {/* clusters: the profiles to target first (with their own Shiny controls) */}
      <ProfilesCard t={t} />
      <Estimates t={t} />
      <FitDetails t={t} />
      <ComparisonView meta={meta} t={t} />

      <Diagnostics fit={fit ?? null} meta={meta} t={t} />

      <StepNav back="nav_back_weights" backLabel={t("Back to Criteria")} nav={flow?.nav.weights}
               next="nav_next_weights" nextLabel={t("Continue to Threshold & errors")} t={t} />
    </div>
  );
}

function ModelTip({ t }: { t: T }) {
  return (
    <Tip>
      <TipList title={t("How the weights are estimated")} items={[
        { name: t("Logistic regression."), text: t("One model on all criteria; each criterion's effect is net of the others. The APP-FA reference."), ref: "Hosmer, Lemeshow & Sturdivant (2013), Applied Logistic Regression, 3rd ed., Wiley." },
        { name: t("Weight of evidence."), text: t("Each criterion's own log odds ratio. Never fails on rare or overlapping criteria, but overlaps count twice."), ref: "Siddiqi (2017), Intelligent Credit Scoring, 2nd ed., Wiley." },
        { name: t("Boosted stumps."), text: t("Gradient boosting with one split per tree: still one fixed number of points per criterion."), ref: "Friedman (2001), Annals of Statistics 29(5); Chen & Guestrin (2016), XGBoost, KDD." },
        { name: t("Random forest, XGBoost, naive Bayes, neural network, SVM."), text: t("Machine-learning models; each criterion's points are its average marginal effect on the model's log-odds, so the card stays additive. Compare their held-out AUC with the logistic card. SVM optimises a boundary rather than probabilities and can give weak points."), ref: "Breiman (2001); Chen & Guestrin (2016); Hastie, Tibshirani & Friedman (2009); Cortes & Vapnik (1995); Molnar (2022), Interpretable Machine Learning." },
        { name: t("Vulnerability index: PCA."), text: t("Not a prediction model: the first principal component of the criteria, turned so a higher index means more vulnerable; its errors are then measured against the outcome like any card. Check that the criteria share enough variation (KMO, Bartlett)."), ref: "Filmer & Pritchett (2001), Demography 38(1); Vyas & Kumaranayake (2006), Health Policy and Planning 21(6)." },
        { name: t("Vulnerability index: LDA."), text: t("Fisher's linear discriminant: the weighted sum of the criteria that best separates vulnerable from other households. Supervised like logistic regression, but assumes equal spread in both groups."), ref: "Fisher (1936), Annals of Eugenics 7." },
      ]} />
    </Tip>
  );
}

/* ----------------------------------------------------------- estimates */

function Estimates({ t }: { t: T }) {
  const est = useShinyOutputValue<Estimates>(ns("sc_estimates"));
  const stale = useStale();
  return (
    <Card title={t("Model estimates")} icon={<Table2 size={15} />} className="sc-est-card"
          actions={<>
            <StaleNote show={!!stale?.points}>{t("Points edited: click Apply points.")}</StaleNote>
            <ActionButton id={ns("apply_points")} label={t("Apply points")} icon={<ArrowRight size={13} />} variant="primary" />
            <ActionButton id={ns("reset_weights")} label={t("Reset to model values")} icon={<RotateCcw size={13} />} variant="outline-secondary" />
            <DownloadButton id={ns("dl_model_tables2")} label={t("Export (Excel)")} icon={<Download size={13} />} />
          </>}>
      {!est ? <EmptyState title={t("No model yet")} sub={t("Set the model above, then click Fit model.")} /> : (
        <>
          {est.pmt ? <PmtTable est={est} t={t} /> : <CardTable est={est} t={t} />}
          {est.fit_line ? <div className="small text-muted mt-2">{est.fit_line}</div> : null}
          {!est.pmt && est.others.length ? (
            <div className="small text-muted mt-1">
              {t("Other models: log-odds effect of each criterion, fitted on the same training households; a dash means the model dropped it.")}{" "}
              <span className="wfp-agree-yes">{"✔"}</span> {t("same direction under every model,")}{" "}
              <span className="wfp-agree-no">{"⚠"}</span> {t("the direction differs: worth a second look.")}
            </div>
          ) : null}
          {est.pmt ? <div className="small text-muted mt-2">{t("Inclusion: the proxy lowers predicted welfare, so it adds points. Points = 100 × |β|.")}</div> : null}
          {est.rows.some((r) => isNum(r.p)) ? <PLegend t={t} /> : null}
          <div className="small text-muted mt-2">
            {t("Every criterion here is observable at registration and not an outcome indicator (Targeting Advisory 1/2025); validate them with the community before implementation.")}
          </div>
        </>
      )}
    </Card>
  );
}

function PointCell({ row, stamp, t }: { row: EstRow; stamp: number; t: T }) {
  const [v, setV] = useRowInput<number | null>(ns(row.id), row.points, stamp, "tw.num");
  const [text, setText] = useState(v === null || v === undefined ? "" : String(v));
  useEffect(() => { if (v === null || v === undefined) { if (text !== "" && !isNaN(Number(text))) setText(""); } else if (Number(text) !== v) setText(String(v)); }, [v]); // eslint-disable-line
  const edited = isNum(row.points) && isNum(v) && Math.abs(v - row.points) > 1e-9;
  return (
    <input type="number" className={`form-control form-control-sm sc-points${edited ? " is-edited" : ""}`} min={0} step={0.01} value={text}
           aria-label={`${t("Points")} ${row.criterion}`}
           onChange={(e) => { setText(e.target.value); const n = e.target.value === "" ? null : Number(e.target.value); if (n === null || !isNaN(n)) setV(n); }} />
  );
}

const sgn = (x: number | null, d: number) => (isNum(x) ? `${x >= 0 ? "+" : ""}${x.toFixed(d)}` : "-");

function CardTable({ est, t }: { est: Estimates; t: T }) {
  const oth = est.others;
  const nOth = oth.length + (est.has_imp ? 1 : 0) + 1;
  // a ranking has no standard errors, odds ratios or p-values: no empty columns
  const has = (k: "se" | "or" | "p") => est.rows.some((r) => isNum(r[k]));
  const [hasSe, hasOr, hasP] = [has("se"), has("or"), has("p")];
  const nMain = 4 + (hasSe ? 1 : 0) + (hasOr ? 1 : 0) + (hasP ? 1 : 0);
  return (
    <div className="wfp-model-table-wrap">
      <table className="wfp-model-table sc-est">
        <thead>
          {oth.length ? (
            <tr className="wfp-grp-row">
              <th colSpan={nMain}>{t("Chosen model")}</th>
              <th colSpan={nOth} className="wfp-oth-first">{t("Under the other models (log-odds)")}</th>
            </tr>
          ) : null}
          <tr>
            <th>{t("Criterion")}</th><th className="num" style={{ textTransform: "none" }}>{"β"}</th>
            {hasSe ? <th className="num">SE</th> : null}{hasOr ? <th>{t("Odds ratio (95% CI)")}</th> : null}{hasP ? <th className="num">p</th> : null}
            <th>{t("Direction")}</th><th className="num">{t("Points")}</th>
            {oth.map((m, k) => <th key={m} className={`num${k === 0 ? " wfp-oth-first" : ""}`}>{m}</th>)}
            {est.has_imp ? <th className="num">{t("RF importance")}</th> : null}
            {oth.length ? <th className="text-center">{t("Agree")}</th> : null}
          </tr>
        </thead>
        <tbody>
          {est.rows.map((r) => (
            <tr key={r.id}>
              <td className="tw-var"><strong>{r.criterion}</strong></td>
              <td className="num">{sgn(r.beta, 3)}</td>
              {hasSe ? <td className="num">{isNum(r.se) ? r.se.toFixed(3) : "-"}</td> : null}
              {hasOr ? <td><OrCell or={r.or} lo={r.or_low} hi={r.or_high} /></td> : null}
              {hasP ? <td className="num"><PPill p={r.p} /></td> : null}
              <td><DirBadge d={r.dir} t={t} /></td>
              <td className="num"><PointCell row={r} stamp={est.stamp} t={t} /></td>
              {oth.map((m, k) => {
                const v = r.others[k];
                return <td key={m} className={`num${k === 0 ? " wfp-oth-first" : ""}${isNum(v) ? (v >= 0 ? " wfp-eff-pos" : " wfp-eff-neg") : " text-muted"}`}>{isNum(v) ? sgn(v, 2) : "—"}</td>;
              })}
              {est.has_imp ? <td className="num">{isNum(r.imp) ? `${Math.round(100 * r.imp)}%` : "—"}</td> : null}
              {oth.length ? (
                <td className="text-center">
                  {r.agree === null ? <span className="text-muted">{"—"}</span>
                    : r.agree ? <span className="wfp-agree-yes" title={t("Same direction under every model")}>{"✔"}</span>
                    : <span className="wfp-agree-no" title={t("The direction differs between models: worth a second look")}>{"⚠"}</span>}
                </td>
              ) : null}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function PmtTable({ est, t }: { est: Estimates; t: T }) {
  return (
    <div className="wfp-model-table-wrap">
      <table className="wfp-model-table sc-est">
        <thead><tr>
          <th>{t("Proxy")}</th><th className="num">{"β"} ({t("log welfare")})</th><th className="num">SE</th>
          <th className="num">{t("Effect on welfare")} <Tip>{t("How much higher (+) or lower (-) predicted welfare per person is for a household with this characteristic, or per unit of a number, all else equal.")}</Tip></th>
          <th className="num">p</th><th>{t("Direction")}</th><th className="num">{t("Points")}</th>
        </tr></thead>
        <tbody>
          {est.rows.map((r) => (
            <tr key={r.id}>
              <td className="tw-var"><strong>{r.criterion}</strong>{r.numeric ? <span className="small text-muted"> ({t("per unit")})</span> : null}</td>
              <td className="num">{sgn(r.beta, 4)}</td>
              <td className="num">{isNum(r.se) ? r.se.toFixed(4) : "-"}</td>
              <td className="num">{isNum(r.beta) ? `${sgn(100 * (Math.exp(r.beta) - 1), 1)}%` : "-"}</td>
              <td className="num"><PPill p={r.p} /></td>
              <td><DirBadge d={r.dir} t={t} /></td>
              <td className="num"><PointCell row={r} stamp={est.stamp} t={t} /></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/* ---------------------------------------------- comparison and history */

function AucBar({ x }: { x: number | null | undefined }) {
  if (!isNum(x)) return <span className="text-muted">-</span>;
  return (
    <div className="wfp-auc">
      <span className="wfp-auc-bar" style={{ width: `${Math.round(100 * Math.max(0, (x - 0.5) / 0.5))}%` }} />
      <span className="wfp-auc-num">{x.toFixed(3)}</span>
    </div>
  );
}

function RunActions({ r, t }: { r: Run; t: T }) {
  if (r.current) return <span className="wfp-kept">{"✓"} {t("shown")}</span>;
  return (
    <span className="d-inline-flex gap-1">
      <button type="button" className="btn btn-outline-primary btn-sm" onClick={() => sendEvent(ns("restore_run"), r.id)}>{t("Restore")}</button>
      <button type="button" className="btn btn-outline-danger btn-sm" title={t("Remove this fit from the history")} aria-label={t("Remove this fit from the history")}
              onClick={() => sendEvent(ns("delete_run"), r.id)}><Trash2 size={13} /></button>
    </span>
  );
}

/** The run history on its own (PMT and rankings; scorecards show it in the comparison) */
function RunsOnly({ show, t }: { show: boolean; t: T }) {
  const c = useShinyOutputValue<Comparison>(ns("sc_comparison"));
  if (!show || !c || !c.runs.length) return null;
  return (
    <details className="sc-runs" open>
      <summary>{`${t(c.title)} (${c.runs.length} ${c.runs.length === 1 ? t("fit") : t("fits")})`} {"—"} {t("best highlighted")}</summary>
      <div className="wfp-model-table-wrap mt-2">
        <table className="wfp-model-table">
          <thead><tr><th>{t("Run")}</th><th>{t("Model")}</th><th>{t("Scheme")}</th><th className="num">{t("Criteria")}</th><th className="num">AUC</th><th /></tr></thead>
          <tbody>
            {c.runs.map((r) => (
              <tr key={r.id} className={`${r.current ? "is-current" : ""} ${r.best ? "is-best" : ""}`}>
                <td><strong>#{r.id}</strong> <span className="text-muted small ms-1">{r.at}</span></td>
                <td>{r.model}</td><td>{t(r.scheme)}</td><td className="num">{r.criteria}</td>
                <td className="num">{isNum(r.auc) ? <><strong>{r.auc.toFixed(3)}</strong> <span className="text-muted small">{r.held_out ? t("held out") : t("training")}</span></> : <span className="text-muted">{"–"} {t("no outcome")}</span>}</td>
                <td><RunActions r={r} t={t} /></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </details>
  );
}

function ComparisonView({ meta, t }: { meta?: Meta; t: T }) {
  const c = useShinyOutputValue<Comparison>(ns("sc_comparison"));
  if (!c || c.kind === "none") return null;
  if (c.kind === "pmt") {
    const tab = c.table ?? [];
    if (tab.length < 2) {
      return (
        <Card title={t("PMT model comparison")} icon={<Trophy size={15} />}>
          <EmptyState title={t("No comparison yet")} sub={t("Choose other models in “Models to compare” above and fit again.")} />
        </Card>
      );
    }
    const best = Math.max(...tab.map((r) => (isNum(r.r2_test) ? (r.r2_test as number) : -Infinity)));
    const pc = (v: unknown) => (isNum(v) ? `${(100 * v).toFixed(1)}%` : "-");
    const nm = (v: unknown, d = 3) => (isNum(v) ? v.toFixed(d) : "-");
    return (
      <div className="sc-grid-75">
        <Card title={t("PMT model comparison")} icon={<Trophy size={15} />}>
          <div className="wfp-model-table-wrap">
            <table className="wfp-model-table">
              <thead><tr><th>{t("Model")}</th><th className="num">{t("Proxies")}</th><th className="num">{"R²"} {t("training")}</th><th className="num">{"R²"} {t("held out")}</th>
                <th className="num">{t("Leakage")}</th><th className="num">{t("Under-coverage")}</th><th className="num">{t("Accuracy")}</th><th className="num">CGH</th></tr></thead>
              <tbody>
                {tab.map((r, i) => {
                  const top = r.r2_test === best;
                  return (
                    <tr key={i} className={top ? "is-best" : undefined}>
                      <td><strong>{String(r.model)}</strong>{top ? <span className="wfp-kept ms-2"><Trophy size={12} /> {t("best R²")}</span> : null}</td>
                      <td className="num">{String(r.proxies ?? "")}</td><td className="num">{nm(r.r2_train)}</td><td className="num">{nm(r.r2_test)}</td>
                      <td className="num">{pc(r.inclusion_error)}</td><td className="num">{pc(r.exclusion_error)}</td><td className="num">{pc(r.accuracy)}</td><td className="num">{nm(r.cgh, 2)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          <div className="small text-muted mt-2">{t("Measured on the held-out households with the cut-off at the poverty line. The best held-out R² is marked; a model with a lower R² can still have lower under-coverage (quantile regression usually does).")}</div>
        </Card>
        <ChartCard id="pmt_compare_plot" title={t("Error trade-off by model")} icon={<BarChart3 size={15} />} height={360} meta={meta} t={t} />
      </div>
    );
  }
  const tab = c.table ?? [];
  const best = Math.max(...tab.map((r) => (isNum(r.auc_test) ? (r.auc_test as number) : -Infinity)));
  return (
    <div className="sc-grid-75">
      <Card title={t("Model comparison")} icon={<Trophy size={15} />} className="sc-cmp-card">
        {c.why ? <div className="small text-muted mb-2">{t("No comparison yet.")} {t(c.why)}</div> : null}
        {tab.length || c.runs.length ? (
          <div className="wfp-model-table-wrap">
            <table className="wfp-model-table wfp-cmp">
              <thead><tr><th>{t("Model")}</th><th className="num">{t("Criteria")}</th><th>{t("AUC (training)")}</th><th>{t("AUC (held out)")}</th><th /></tr></thead>
              <tbody>
                {tab.length ? <tr className="wfp-band-row"><td colSpan={5}>{t("This fit: the models compared")}</td></tr> : null}
                {tab.map((r, i) => {
                  const top = r.auc_test === best;
                  return (
                    <tr key={i} className={top ? "is-best" : undefined}>
                      <td><strong>{String(r.model)}</strong>{top ? <span className="wfp-kept ms-2"><Trophy size={12} /> {t("best")}</span> : null}</td>
                      <td className="num">{isNum(r.criteria) ? r.criteria : ""}</td>
                      <td><AucBar x={r.auc_train as number} /></td><td><AucBar x={r.auc_test as number} /></td><td />
                    </tr>
                  );
                })}
                {c.runs.length ? <tr className="wfp-band-row"><td colSpan={5}>{`${t(c.title)} (${c.runs.length} ${c.runs.length === 1 ? t("fit") : t("fits")})`}</td></tr> : null}
                {c.runs.map((r) => (
                  <tr key={`run${r.id}`} className={`${r.current ? "is-current" : ""} ${r.best ? "is-best-run" : ""}`}>
                    <td><strong>#{r.id}</strong> {r.model}<div className="text-muted small">{t(r.scheme)} {"·"} {r.at}</div></td>
                    <td className="num">{r.criteria}</td>
                    <td>{isNum(r.auc) && !r.held_out ? <strong>{r.auc.toFixed(3)}</strong> : <span className="text-muted">{"—"}</span>}</td>
                    <td>{isNum(r.auc) && r.held_out ? <strong>{r.auc.toFixed(3)}</strong> : <span className="text-muted">{"—"}</span>}</td>
                    <td><RunActions r={r} t={t} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}
        <div className="small text-muted mt-2">
          {t("AUC on the held-out households is the honest figure. Each model is scored as the sum of its effects; if the machine-learning models barely beat the logistic one, more complex models are not needed. The gap between a model and the scorecard is the price of the weighting scheme and of flooring scores at zero.")}
        </div>
      </Card>
      <Show when={!c.why}>
        <ChartCard id="comparison_roc" title={t("ROC, held-out households")} icon={<BarChart3 size={15} />} height={340} meta={meta} t={t} />
      </Show>
    </div>
  );
}

/* --------------------------------------------------------- diagnostics */

function Diagnostics({ fit, meta, t }: { fit: Flow["fit"]; meta?: Meta; t: T }) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => { if (open) signalShown(ref.current, true); }, [open, fit?.method, fit?.index]);
  useOutputVisibility(ns("sc_diagram"), ref);
  if (!fit) return null;
  const im = fit.index, C = (id: string, title: string, h = 480) => <ChartCard key={id} id={id} title={title} height={h} meta={meta} t={t} />;
  let charts: ReactNode;
  if (fit.pmt) {
    charts = <>
      <div className="sc-grid-2">{C("weights_plot", t("Points and direction"), 440)}{C("pmt_fit_plot", t("Predicted against measured welfare"), 440)}</div>
      <div className="sc-grid-3">{C("pmt_decile_plot", t("Selected by decile of measured welfare"), 400)}{C("pmt_curve_plot", t("Leakage and under-coverage as the cut-off moves"), 400)}{C("pmt_resid_plot", t("Prediction errors (residuals)"), 400)}</div>
    </>;
  } else if (im === "pca") {
    charts = <>
      <div className="sc-grid-3">{C("weights_plot", t("Weight and direction"))}{C("pca_scree", t("Variation explained by each axis"))}{C("pca_loadings", t("Loadings on the axes kept"))}</div>
      <div className="sc-grid-2">{C("pca_var_map", t("Variables: correlation circle, axes 1 and 2"))}{C("pca_ind_map", t("Households on axes 1 and 2"))}</div>
    </>;
  } else if (im === "mca") {
    charts = <>
      <div className="sc-grid-3">{C("weights_plot", t("Weight and direction"))}{C("pca_scree", t("Variation explained by each axis"))}{C("pca_loadings", t("Weights on the axes kept"))}</div>
      {C("unsup_map", t("Households on the first two components"))}
    </>;
  } else if (im === "count") {
    charts = <div className="sc-grid-3">{C("weights_plot", t("Weight of each deprivation"))}{C("dep_count_plot", t("Weighted deprivations per household"))}{C("unsup_map", t("Households on the first two components"))}</div>;
  } else if (fit.cluster) {
    // the profiles get the full width (a row per criterion), the two others share the next row
    charts = <>
      {C("cluster_plot", t("Profiles: share of households meeting each criterion"))}
      <div className="sc-grid-2">{C("unsup_map", t("Households by profile, first two components"))}{C("weights_plot", t("Points that reproduce the targeted profiles"))}</div>
    </>;
  } else if (im === "lda") {
    charts = <>
      <div className="sc-grid-3">{C("weights_plot", t("Weight and direction"))}{C("prevalence_plot", t("How common each criterion is"))}{C("lda_scores", t("Index by group"))}</div>
      <div className="sc-grid-2">{C("lda_var_map", t("Variables: correlation of each criterion with the index"))}{C("lda_ind_map", t("Households on the index"))}</div>
    </>;
  } else {
    charts = <div className="sc-grid-3">{C("weights_plot", t("Weight and direction"))}{C("prevalence_plot", t("How common each criterion is"))}{C("effects_plot", t("Effect by model"))}</div>;
  }
  return (
    <section className={`sc-more${open ? " open" : ""}`}>
      <button type="button" className="sc-more-head" aria-expanded={open} onClick={() => setOpen(!open)}>
        <BarChart3 size={15} /> <span>{t("More diagnostics: diagram, residuals, decision rules and charts")}</span>
        <ChevronDown size={15} className="sc-more-chev" />
      </button>
      <div ref={ref} className="sc-more-body" style={{ display: open ? undefined : "none" }}>
        <DiagramCards t={t} />
        {charts}
      </div>
    </section>
  );
}

