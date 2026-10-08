// Step 4, the threshold and the errors: the slider and the tolerance band
// count once applied (thr_apply); the errors on their tolerance tracks, the
// error matrix and the verdict (Targeting Advisories 2 and 3/2025); then the
// charts, two per tab. Without an outcome: the selection, its consistency
// and stability. The footer adopts the design (nav_adopt).
import { useEffect, useRef, useState } from "react";
import {
  ArrowLeft, BadgeCheck, CircleCheck, CircleX, ClipboardCheck, Crosshair, Gauge, Grid3x3, House, Lightbulb, MapPin, Percent,
  Ruler, Search, Shuffle, Sigma, TriangleAlert, Users,
} from "lucide-react";
import { useShinyInput, useShinyOutputValue } from "@/shiny";
import { ActionButton, HostedUI, NumericInput, SelectInput, TextOutput, useServerUpdates } from "@/lib/inputs";
import { Card, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { useOutputVisibility } from "@/lib/visibility";
import { InsightsList, PmtAccuracyCard, PmtLineNote, StabilityBody, StaleNote, useStale } from "./facts";
import { ChartHelp, ChartPane, Gate, Show, StepNav, Tip, fmt5, int, isNum, ns, type T } from "./shared";
import { Kpi } from "./StepFramework";
import type { Flow, Meta, Mode, RankingFacts, Slider, Thresh } from "./types";

export function StepThreshold({ flow, meta, mode, t }: { flow?: Flow; meta?: Meta; mode: Mode; t: T }) {
  const th = useShinyOutputValue<Thresh>(ns("sc_threshold"));
  const nof = mode === "none", pmt = mode === "pmt";
  const adopted = !!flow?.nav.threshold.adopted;
  const stale = useStale();
  const rk = useShinyOutputValue<RankingFacts>(ns("sc_ranking"));
  // computed only while shown (PORTING.md, "Hidden outputs wait")
  const withRef = useRef<HTMLDivElement>(null), noRef = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("sc_threshold"), withRef);
  useOutputVisibility(ns("sc_pmt_accuracy"), withRef);
  useOutputVisibility(ns("sc_ranking"), noRef);
  return (
    <div className="sc-step">
      <p className="sc-lead">{t("Choosing the eligibility threshold is a programmatic decision, not a mechanical one (Targeting Advisory 3/2025). The curve shows the whole trade-off; the band below is your tolerance for error.")}</p>
      <Gate show={!!flow && flow.gates.threshold} text={t("The threshold is chosen against the errors a scored design produces, so fit the weights first.")}
            btn="back_to_weights" label={t("Back to Model & weights")} />

      {/* every eligibility control on one line; the rationale below */}
      <div className="sc-setup-panel sc-thr-setup">
        <div className="sc-thr-row tw-align tw-align-bottom">
          <ThresholdSlider t={t} />
          <Show when={!nof} style={{ display: "contents" }}>
            <NumericInput id={ns("tol_lower")} value={meta?.tol_default[0] ?? 5} min={0} max={49} step={1} className="sc-thr-num"
                          label={<>{t("Lower %")} <Tip>{t("Lower bound of the tolerance band (Advisory 2/2025). Errors below it are acceptable without action. Changing the default (5%) needs an explanation in the rationale.")}</Tip></>} />
            <NumericInput id={ns("tol_upper")} value={meta?.tol_default[1] ?? 20} min={1} max={49} step={1} className="sc-thr-num"
                          label={<>{t("Upper %")} <Tip>{t("Upper bound of the tolerance band. Errors above it call for a redesign; it can never reach 50% (no better than random). Changing the default (20%) needs an explanation in the rationale.")}</Tip></>} />
          </Show>
          <NumericInput id={ns("caseload_pct")} min={1} max={100} step={1} className="sc-thr-caseload"
                        label={<>{t("Caseload (%)")} <Tip>{t("Share of households the programme can serve. Used by 'Fit to caseload' to set the highest threshold that stays within it.")}</Tip></>} />
          <div className="tw-field sc-thr-suggest">
            <label className="form-label">{t("Suggest")}</label>
            <div className="sc-thr-btns">
              <Show as="span" when={!nof} style={{ display: "contents" }}>
                <ActionButton id={ns("thr_balanced")} label={t("Minimise errors")} icon={<Crosshair size={13} />}
                              title={t("Sets the threshold where the larger of the inclusion and exclusion errors is smallest, so neither is traded away for the other.")} />
                <ActionButton id={ns("thr_youden")} label={t("Balance (Youden)")} icon={<Gauge size={13} />}
                              title={t("Youden's J: picks the threshold maximising sensitivity + specificity - 1, the point of the ROC curve furthest from the diagonal (Targeting Advisory 3/2025; Youden 1950).")} />
              </Show>
              <Show as="span" when={pmt} style={{ display: "contents" }}>
                <ActionButton id={ns("thr_line")} label={t("At the poverty line")} icon={<Ruler size={13} />}
                              title={t("Eligible when predicted welfare per person is at or below the poverty line: the standard PMT cut-off. A cut-off above the line lowers exclusion errors at the cost of inclusion errors (Brown, Ravallion & van de Walle 2018).")} />
              </Show>
              <ActionButton id={ns("thr_caseload")} label={t("Fit to caseload")} icon={<Users size={13} />}
                            title={t("Sets the threshold so no more than the caseload share of households is eligible.")} />
            </div>
          </div>
          <ActionButton id={ns("thr_apply")} label={t("Apply")} icon={<CircleCheck size={14} />} variant="primary" size="md" className="sc-thr-apply" />
        </div>
        <StaleNote show={!!stale?.thr}>{t("Threshold or tolerance changed: click Apply to update the errors and charts.")}</StaleNote>
        <div className="small text-muted mt-1"><TextOutput id={ns("thr_note")} /></div>
        <Show when={pmt} className="small mt-1"><PmtLineNote stale={stale} t={t} /></Show>
      </div>
      {/* with an outcome: the metrics (2 x 2) beside the rationale; without, the rationale alone */}
      <Show when={!nof} className="small text-muted"><TextOutput id={ns("eval_note")} /></Show>
      <div className={`sc-thr-mid${nof ? " one" : ""}`}>
        <Show when={!nof}>
          <div className="sc-kpis sc-kpis-2x2">
            <Kpi label={<TextOutput id={ns("kpi_auc_title")} />} value={<TextOutput id={ns("kpi_auc")} />} tone="primary" />
            <Kpi label={pmt ? t("Selected (predicted poor)") : t("Eligible households")} value={<TextOutput id={ns("kpi_elig")} />} tone="info" />
            {th ? <>
              <ErrorTrack which="incl" th={th} t={t} />
              <ErrorTrack which="excl" th={th} t={t} />
            </> : <><Kpi label={t("Inclusion error")} value={"–"} /><Kpi label={t("Exclusion error")} value={"–"} /></>}
          </div>
        </Show>
        <div className="sc-setup-panel sc-rationale">
          <div className="form-label sc-label">{t("Rationale for the band and the threshold")}{" "}
            <Tip>{t("Required by Targeting Advisory 2/2025; it goes into the exported scorecard and the design report.")}</Tip></div>
          <HostedUI id={ns("host_rationale")} />
        </div>
      </div>

      {/* without an outcome: the selection, its consistency and stability */}
      <Show when={nof}>
        <div ref={noRef} className="sc-stack">
        <div className="sc-kpis sc-kpis-ranking">
          <Kpi label={t("Households selected")} value={<TextOutput id={ns("kpi_selected")} />} tone="info" />
          <Kpi label={<>{t("Internal consistency")} <Tip>{t("Cronbach's alpha of the criteria: how far they measure one thing. Above 0.7 is usually read as consistent; low values are expected when the criteria cover different dimensions of vulnerability on purpose.")}</Tip></>}
               value={<TextOutput id={ns("kpi_alpha")} />} />
          <Card title={t("Stability of the selection")} icon={<Shuffle size={15} />} className="sc-stability"
                help={<Tip>{t("The design is refitted on 20 resamples of the households; each refit selects the same share of households. The agreement with the design's own selection (Jaccard index) says how much the targeting depends on who happened to be in the data.")}</Tip>}>
            <StabilityBody r={rk} t={t} />
          </Card>
        </div>
        <div className="sc-grid-2 sc-top">
          <Card title={t("What the selection concentrates")} icon={<Lightbulb size={15} />}
                help={<Tip>{t("A household's deprivations are the criteria it meets in the vulnerable direction (an inclusion criterion met, an exclusion criterion not met).")}</Tip>}>
            <InsightsList r={rk} t={t} />
          </Card>
          <Card full title={t("Share selected by area")} icon={<MapPin size={15} />} help={<ChartHelp id="cov_area_plot" meta={meta} t={t} />}
                actions={<div className="sc-card-select"><SelectInput id={ns("cov_area")} choices={[{ value: "", label: t("(none)") }]} value="" clearable={false} /></div>}>
            <Chart id={ns("cov_area_plot")} height={320} />
          </Card>
        </div>
        <div className="sc-grid-2">
          <Card full title={t("Ranking distribution")} icon={<Sigma size={15} />} help={<ChartHelp id="rank_plot" meta={meta} t={t} />}><Chart id={ns("rank_plot")} height={400} /></Card>
          <Card full title={t("Criteria among selected and other households")} icon={<ClipboardCheck size={15} />} help={<ChartHelp id="sel_prev_plot" meta={meta} t={t} />}><Chart id={ns("sel_prev_plot")} height={400} /></Card>
        </div>
        </div>
      </Show>

      {/* with an outcome: the errors, the matrix and the verdict */}
      <Show when={!nof}>
        <div ref={withRef} className="sc-stack">
        <Show when={pmt}><PmtAccuracyCard t={t} /></Show>
        <div className="sc-grid-75">
          <Card title={pmt ? t("PMT targeting matrix") : t("Design error matrix")} icon={<Grid3x3 size={15} />}>
            {th ? <ErrorMatrix th={th} t={t} /> : <div className="small text-muted">{t("Fit a model and set a threshold to see the matrix.")}</div>}
          </Card>
          <Card title={t("Verdict")} icon={<BadgeCheck size={15} />}>
            {th ? <Verdict th={th} t={t} /> : <div className="small text-muted">{t("The verdict follows the errors.")}</div>}
          </Card>
        </div>
        </div>
      </Show>

      <Card full title={t("Explore the threshold")} icon={<Search size={15} />} className="sc-explore"
            actions={<ActionButton id={ns("pct_open")} label={t("Score percentiles")} icon={<Percent size={13} />} variant="outline-secondary"
                                   title={t("Households between the percentiles of the score you choose, with an Excel export")} />}>
        <Tabs id={ns("thr_explore")} tabs={[
          {
            value: "sep", label: t("How well it separates"), content: nof
              ? <div className="small text-muted p-2">{t("Needs an outcome indicator: see the ranking distribution above.")}</div>
              : <div className="sc-grid-2"><ChartPane id="roc_plot" title={t("ROC curve")} meta={meta} t={t} /><ChartPane id="box_plot" title={t("Score by group")} meta={meta} t={t} /></div>,
          },
          {
            value: "fall", label: t("Where households fall"), content: (
              <div className="sc-grid-2">
                {nof ? <div className="small text-muted p-2">{t("Score distribution: needs an outcome indicator.")}</div>
                  : <ChartPane id="score_plot" title={t("Score distribution")} meta={meta} t={t} />}
                <ChartPane id="met_plot" title={t("Criteria met, eligible vs not")} meta={meta} t={t} />
              </div>
            ),
          },
          {
            value: "drive", label: t("What drives it"), content: (
              <div className="sc-grid-2">
                <ChartPane id="contribution_plot" title={t("What drives the score")} height={640} meta={meta} t={t} />
                {nof ? <ChartPane id="sel_by_met_plot" title={t("Share selected by number of criteria met")} height={640} meta={meta} t={t} />
                  : <ChartPane id="coverage_plot" title={t("Coverage by criterion")} height={640} meta={meta} t={t} />}
              </div>
            ),
          },
        ]} />
      </Card>

      <StepNav back="nav_back_threshold" backLabel={t("Back to Model & weights")}
               nav={adopted ? { ok: true, done: `${t("Adopted")} ${flow?.nav.threshold.adopted_at ?? ""}. ${t("Any change to the design withdraws the adoption.")}`, todo: "" } : flow?.nav.threshold}
               next="nav_adopt" nextLabel={nof ? t("Adopt this ranking") : pmt ? t("Adopt this PMT") : `${t("Adopt this scorecard")}`}
               nextIcon={<CircleCheck size={14} />} t={t}
               after={adopted ? <span className="sc-adopted-pill"><BadgeCheck size={14} /> {t("Adopted")}</span> : null} />
    </div>
  );
}

/** The threshold: a slider and a number box on the same input */
function ThresholdSlider({ t }: { t: T }) {
  const s = useShinyOutputValue<Slider>(ns("sc_slider"));
  const [v, setV] = useShinyInput<number | null>(ns("threshold"), null, { debounceMs: 250, type: "tw.num" });
  const [lim, setLim] = useState({ min: 0, max: 10 });
  const last = useRef<number | null>(null);
  useEffect(() => {
    if (!s || last.current === s.stamp) return;
    last.current = s.stamp;
    setLim({ min: s.min, max: s.max });
    setV(s.value);
  }, [s]); // eslint-disable-line
  useServerUpdates(ns("threshold"), (u) => {
    if (u.min !== undefined || u.max !== undefined) setLim((l) => ({ min: u.min ?? l.min, max: u.max ?? l.max }));
    if (u.value !== undefined && u.value !== null) setV(Number(u.value));
  });
  const [text, setText] = useState("");
  useEffect(() => { setText(isNum(v) ? fmt5(v) : ""); }, [v]);
  const cur = isNum(v) ? v : lim.min;
  return (
    <div className="tw-field sc-threshold">
      <label className="form-label" htmlFor={`${ns("threshold")}__num`}>{t("Eligible when score is above")}{" "}
        <Tip>{t("Households scoring strictly above this value are eligible. Moving it trades inclusion error against exclusion error.")}</Tip></label>
      <div className="sc-threshold-row">
        <input type="range" className="form-range" min={lim.min} max={lim.max} step={0.0001} value={cur} aria-label={t("Threshold")}
               onChange={(e) => setV(Number(e.target.value))} />
        <input id={`${ns("threshold")}__num`} type="number" className="form-control form-control-sm" step="any" value={text}
               onChange={(e) => { setText(e.target.value); const n = Number(e.target.value); if (e.target.value !== "" && isFinite(n)) setV(Math.min(Math.max(n, lim.min), lim.max)); }} />
      </div>
      <div className="sc-threshold-scale"><span>{fmt5(lim.min)}</span><span>{fmt5(lim.max)}</span></div>
    </div>
  );
}

/** An error rate on a 0-50% track with the tolerance band drawn in */
function ErrorTrack({ which, th, t }: { which: "incl" | "excl"; th: Thresh; t: T }) {
  const e = th.e;
  const v = which === "incl" ? e.inclusion_error : e.exclusion_error;
  const numer = which === "incl" ? e.included_not_in_need : e.excluded_in_need;
  const denom = which === "incl" ? e.correctly_included + e.included_not_in_need : e.correctly_included + e.excluded_in_need;
  const band = !isNum(v) ? "na" : v <= th.lower ? "good" : v <= th.upper ? "review" : "bad";
  const pos = (x: number) => `${(100 * Math.min(Math.max(x, 0), 0.5)) / 0.5}%`;
  return (
    <div className={`sc-track is-${band}`}>
      <div className="sc-track-head">
        <span className="sc-kpi-label">{which === "incl" ? th.words.incl : th.words.excl}</span>
        <span className="sc-track-value">{isNum(v) ? `${(100 * v).toFixed(1)}%` : "n/a"}</span>
      </div>
      <div className="sc-track-bar" aria-hidden="true">
        <span className="zone good" style={{ width: pos(th.lower) }} />
        <span className="zone review" style={{ left: pos(th.lower), width: `${(100 * (Math.min(th.upper, 0.5) - Math.min(th.lower, 0.5))) / 0.5}%` }} />
        <span className="zone bad" style={{ left: pos(th.upper), right: 0 }} />
        {isNum(v) ? <span className="marker" style={{ left: pos(v) }} /> : null}
      </div>
      <div className="sc-track-scale">
        <span style={{ left: pos(th.lower) }}>{Math.round(100 * th.lower)}%</span>
        <span style={{ left: pos(th.upper) }}>{Math.round(100 * th.upper)}%</span>
        <span className="end-r">50%</span>
      </div>
      <div className="sc-kpi-sub">{int(numer)} / {int(denom)} {"—"} {which === "incl" ? th.words.incl_mean : th.words.excl_mean}</div>
    </div>
  );
}

/** The contingency table of Targeting Advisory 2/2025 with this design's counts */
function ErrorMatrix({ th, t }: { th: Thresh; t: T }) {
  const e = th.e, w = th.words;
  const nElig = e.correctly_included + e.included_not_in_need, nNot = e.excluded_in_need + e.correctly_excluded;
  const nVuln = e.correctly_included + e.excluded_in_need, nNo = e.included_not_in_need + e.correctly_excluded;
  const pc = (x: number, d: number) => (!d ? "-" : `${((100 * x) / d).toFixed(1)}%`);
  const cell = (n: number, row: number, label: string, kind: string, icon: React.ReactNode) => (
    <td className={`wfp-cm-cell ${kind}`}>
      <div className="wfp-cm-label">{icon} {label}</div>
      <div className="wfp-cm-count">{int(n)}</div>
      <div className="wfp-cm-share"><span>{pc(n, row)} {t("of row")}</span><span>{pc(n, e.n)} {t("of all")}</span></div>
    </td>
  );
  return (
    <>
      <div className="wfp-cm-wrap">
        <table className="wfp-matrix wfp-cm">
          <thead>
            <tr>
              <th className="wfp-cm-corner" colSpan={2} rowSpan={2}><div className="wfp-cm-axis">{w.axis_row}</div><div className="wfp-cm-axis">{w.axis_col}</div></th>
              <th className="wfp-cm-group" colSpan={2}>{th.pmt ? t("Welfare per person:") : t("Outcome:")} <strong>{th.outcome}</strong></th>
              <th className="wfp-cm-tot-head" rowSpan={2}>{t("Total")}</th>
            </tr>
            <tr>
              <th className="wfp-cm-col">{w.vuln}<div className="wfp-cm-sub">{th.opos}</div></th>
              <th className="wfp-cm-col">{w.notvuln}</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <th className="wfp-cm-rowgroup" rowSpan={2}><span>{w.card}</span></th>
              <th className="wfp-cm-row">{w.elig}<div className="wfp-cm-sub">{t("score >")} {th.threshold}</div></th>
              {cell(e.correctly_included, nElig, t("Correctly included"), "ok", <CircleCheck size={13} />)}
              {cell(e.included_not_in_need, nElig, w.incl, "err-incl", <CircleX size={13} />)}
              <td className="wfp-cm-tot">{int(nElig)}<div className="wfp-cm-sub">{pc(nElig, e.n)}</div></td>
            </tr>
            <tr>
              <th className="wfp-cm-row">{w.notelig}</th>
              {cell(e.excluded_in_need, nNot, w.excl, "err-excl", <TriangleAlert size={13} />)}
              {cell(e.correctly_excluded, nNot, t("Correctly excluded"), "ok", <CircleCheck size={13} />)}
              <td className="wfp-cm-tot">{int(nNot)}<div className="wfp-cm-sub">{pc(nNot, e.n)}</div></td>
            </tr>
            <tr className="wfp-matrix-totals-row">
              <th className="wfp-cm-row wfp-cm-tot-label" colSpan={2}>{t("Total")}</th>
              <td className="wfp-cm-tot">{int(nVuln)}<div className="wfp-cm-sub">{pc(nVuln, e.n)}</div></td>
              <td className="wfp-cm-tot">{int(nNo)}<div className="wfp-cm-sub">{pc(nNo, e.n)}</div></td>
              <td className="wfp-cm-tot wfp-cm-grand">{int(e.n)}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div className="small text-muted mt-2">{t("Valid for direct household-level assistance (Tier 1) only. In emergencies the OGN gives priority to reducing exclusion errors; inclusion errors are more acceptable.")}</div>
    </>
  );
}

const STATUS: Record<string, string> = { good: "Within tolerance", review: "Review recommended", redesign: "Redesign required", unknown: "Not enough data", invalid: "Tolerance not valid" };

/** The Advisory's verdict as a status panel; it fades in only when it changes */
function Verdict({ th, t }: { th: Thresh; t: T }) {
  const v = th.verdict;
  const lvl = ["good", "review", "redesign"].includes(v.level) ? v.level : "unknown";
  const seen = useRef<string | null>(null);
  const animate = seen.current !== v.level;
  useEffect(() => { seen.current = v.level; }, [v.level]);
  const chip = (label: string, x: number | null) => {
    if (!isNum(x)) return null;
    const cls = x <= th.lower ? "is-ok" : x <= th.upper ? "is-mid" : "is-bad";
    return (
      <div className={`vd-metric ${cls}`}>
        <span className="vd-metric-label">{label}</span>
        <span className="vd-metric-value">{(100 * x).toFixed(1)}%</span>
        <span className="vd-metric-tol">{t("good")} {"≤"} {Math.round(100 * th.lower)}% {"·"} {t("limit")} {"≤"} {Math.round(100 * th.upper)}%</span>
      </div>
    );
  };
  return (
    <div className={`wfp-verdict is-${lvl}${animate ? "" : " no-anim"}`} role="status" key={v.level}>
      <div className="vd-icon"><House size={30} strokeWidth={2.2} /></div>
      <div className="vd-text">
        <div className="vd-head"><span className="vd-status">{t(STATUS[v.level] ?? STATUS.unknown)}</span></div>
        <div className="vd-interp">{t(v.interpretation)}</div>
        <div className="vd-action"><strong>{t("Recommended action:")} </strong>{t(v.action)}</div>
        <div className="vd-metrics">{chip(th.words.incl, th.e.inclusion_error)}{chip(th.words.excl, th.e.exclusion_error)}</div>
        <div className="small mt-2 text-muted">
          {t("Judged against a tolerance band of %s.").replace("%s", `${Math.round(100 * th.lower)}%-${Math.round(100 * th.upper)}%`)}{" "}
          {t("Targeting Advisory 2/2025 observes design errors of 5-20% across country offices.")}
        </div>
      </div>
    </div>
  );
}

