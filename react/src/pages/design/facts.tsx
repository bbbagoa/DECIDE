// What the server sends as facts (JSON) where the Shiny page sent HTML:
// columns that cannot be criteria, the fit in figures, the notes on the fit,
// the cluster profiles to target, the model diagram and the tree's rules,
// the PMT accuracy, and the ranking's stability and concentration. The
// sentences are written here, so they translate. Buttons are never
// unmounted (a button that mounts again sends its count, which the server
// would take as a click): they are hidden with Show.
import { useEffect, useRef, useState, type ReactNode } from "react";
import { Check, EyeOff, Network, IdCard, Info, LockOpen, Scissors, ShieldAlert, Shuffle, SlidersHorizontal, Target, TriangleAlert, Users } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, SelectInput, TextInput } from "@/lib/inputs";
import { Card, Notice } from "@/lib/layout";
import { useOutputVisibility } from "@/lib/visibility";
import { Pending, Show, Tip, int, isNum, ns, useRowInput, type T } from "./shared";
import type { Blocked, DiagramFacts, Fig, FitFacts, IndexFacts, PmtAccuracy, Profiles, RankingFacts, Stale } from "./types";

/** "%s" in a translated sentence, replaced in order */
export const fill = (s: string, ...a: (string | number)[]) => a.reduce<string>((x, v) => x.replace("%s", String(v)), s);
const pc0 = (x: number | null | undefined) => (isNum(x) ? `${Math.round(100 * x)}%` : "n/a");
const d2 = (x: number | null | undefined) => (isNum(x) ? x.toFixed(2) : "n/a");

/** The cheap notes that a setting waits for its button (and the PMT cut-off in welfare) */
export function useStale() {
  return useShinyOutputValue<Stale>(ns("sc_stale"));
}

/* ------------------------------------------------- step 2: blocked columns */

const BLOCK_KINDS = {
  outcome: {
    icon: <ShieldAlert size={14} />, head: "%s column(s) blocked as outcome indicators",
    text: "Outcome indicators reflect a household's current food consumption, which moves with the season and with assistance itself. Targeting on them is reactive rather than preventive, and they cannot then be used to validate the targeting.",
  },
  unobs: {
    icon: <EyeOff size={14} />, head: "%s column(s) not observable at registration",
    text: "Expenditure, prices, coping strategies and their reasons, MEB and transfer values, food consumption, phone numbers and indebtedness cannot be seen or verified by a registration team, so they are not criteria.",
  },
  ids: {
    icon: <IdCard size={14} />, head: "%s name or identification column(s)",
    text: "Identifiers, names, phone numbers and form metadata identify a household; they do not describe it.",
  },
} as const;

/** Columns that cannot be criteria, by reason, and allowing some back (audited) */
export function BlockedNote({ t }: { t: T }) {
  const b = useShinyOutputValue<Blocked>(ns("sc_blocked"));
  const ref = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("sc_blocked"), ref);
  const some = !!b && !b.none;
  const ov = some ? b.overridable : [];
  return (
    <div ref={ref} className="sc-blocked">
      {b?.none ? <div className="text-muted">{t("No column is blocked.")}</div> : null}
      <Show when={some} className="tw-notice tw-notice-info sc-blocked-box">
        <div className="sc-stack">
          {some ? b.groups.map((g) => (
            <div key={g.kind}>
              <strong className="sc-blocked-head">{BLOCK_KINDS[g.kind].icon} {fill(t(BLOCK_KINDS[g.kind].head), g.n)}</strong>
              <p className="small mb-1 mt-1">{t(BLOCK_KINDS[g.kind].text)}</p>
              <div className="small sc-blocked-cols">{g.cols.join(", ")}{g.more ? ", ..." : ""}</div>
            </div>
          )) : null}
          {some && b.nof ? (
            <p className="small mb-0">
              {t("Without an outcome, outcome indicators (FCS, rCSI, CARI...) and what a registration team cannot observe are allowed: they may rank households.")}{" "}
              {t("Remember that a criterion the registration cannot collect cannot be applied in Beneficiary Selection.")}
            </p>
          ) : null}
          <Show when={ov.length > 0} className="sc-allow">
            <strong><LockOpen size={14} /> {t("Allow some of them anyway")}</strong>
            <p className="small text-muted mb-1">{t("The blocking rules read column names and can be wrong. You decide: an allowed column joins the candidates, and the choice and its reason go to the activity log and the report.")}</p>
            {some && b.allowed.length ? (
              <div className="small">
                <Check size={13} className="sc-ok-icon" /> {t("Allowed:")}
                <ul className="mb-0">
                  {b.allowed.map((a) => <li key={a.col}><code>{a.col}</code> {"—"} <em>{a.note ?? t("no note given")}</em></li>)}
                </ul>
              </div>
            ) : null}
            {/* sent again (new stamp): the picker shows the allowed columns, as the Shiny redraw did */}
            <SelectInput key={some ? b.stamp : 0} id={ns("allow_blocked")} multiple actions choices={ov}
                         value={some ? b.allowed.map((a) => a.col) : []} label={t("Columns to allow")} placeholder={t("Choose blocked columns to allow")} />
            <TextInput id={ns("allow_reason")} label={<>{t("Note (why)")} <Tip>{t("A short explanation, recorded for the columns allowed now: it goes to the activity log and the design report.")}</Tip></>}
                       placeholder={t("e.g. a household characteristic despite its name; observable by the registration team here")} />
            <div><ActionButton id={ns("allow_apply")} label={t("Allow as criteria")} icon={<LockOpen size={13} />} /></div>
          </Show>
        </div>
      </Show>
    </div>
  );
}

/* --------------------------------------------------------- step 3: the fit */

function FigGrid({ figs, t }: { figs: Fig[]; t: T }) {
  return (
    <div className="sc-figs">
      {figs.map((f) => (
        <div key={f.title} className="sc-fig">
          <div className="sc-fig-title">{t(f.title)}{f.tip ? <Tip>{t(f.tip)}</Tip> : null}</div>
          <div className="sc-fig-value">{f.value}</div>
          {f.sub ? <div className="sc-fig-sub">{fill(t(f.sub), f.arg ? t(f.arg) : "")}</div> : null}
        </div>
      ))}
    </div>
  );
}

function IndexNote({ ix, t }: { ix: IndexFacts; t: T }) {
  if (ix.type === "pca") {
    const axes = ix.axes > 1
      ? fill(t("PCA index on %s axes (%s)."), ix.axes, ix.axis_share.map((s, i) => fill(t("axis %s: %s, weight %s"), i + 1, pc0(s), d2(ix.axis_weights[i]))).join("; "))
      : t("PCA index on the first component.");
    const kaiser = ix.kaiser === 1 ? t("Kaiser's rule (eigenvalue above 1) would keep 1 axis.") : fill(t("Kaiser's rule (eigenvalue above 1) would keep %s axes."), isNum(ix.kaiser) ? ix.kaiser : "n/a");
    const bart = !isNum(ix.bartlett_p) ? "n/a" : ix.bartlett_p < 0.001 ? "< 0.001" : `= ${ix.bartlett_p.toFixed(3)}`;
    const body = (
      <>
        <strong>{fill(t("Total variation explained: %s"), pc0(ix.share))}</strong>
        {isNum(ix.min_var) ? ` ${fill(t("(the fewest axes reaching the %s asked)."), pc0(ix.min_var))}` : "."}{" "}
        {axes} {kaiser}{" "}
        {fill(t("Sampling adequacy (KMO) %s (%s); Bartlett's test p %s."), isNum(ix.kmo) ? ix.kmo.toFixed(2) : "n/a", t(ix.kmo_word), bart)}
        {ix.weak ? ` ${t("The criteria share little variation: one index summarises them poorly; prefer a model, or fewer and more related criteria.")}` : ""}{" "}
        {t("Weights are the index's own coefficients, scaled so the largest is 10; the points scheme does not apply.")}
      </>
    );
    return ix.weak ? <Notice kind="warning">{body}</Notice> : <div className="small text-muted"><Network size={13} /> {body}</div>;
  }
  if (ix.type === "lda") {
    return (
      <div className="small text-muted"><Network size={13} />{" "}
        {fill(t("LDA index: separation between the two groups (Mahalanobis D²) %s."), d2(ix.mahalanobis))}{" "}
        {t("Weights are the discriminant's own coefficients, scaled so the largest is 10; the points scheme does not apply.")}
      </div>
    );
  }
  const lead = ix.type === "count" ? t("Deprivation count: each criterion met adds its points (1 by default; edit them in the table).")
    : ix.type === "mca" ? fill(t("MCA index on %s axis(es): %s of the inertia explained in total, turned towards %s."), ix.axes, pc0(ix.share), t(ix.anchor))
    : fill(t("%s household profiles (%s); targeted: profile %s, %s of the households. The points reproduce the targeted profiles."),
           ix.k ?? "", t(ix.algorithm ?? ""), ix.target.join(", "), pc0(ix.target_share));
  return (
    <div className="small text-muted"><Network size={13} /> {lead}{" "}
      {fill(t("Internal consistency (Cronbach's alpha) %s. No outcome: the errors cannot be measured."), d2(ix.alpha))}
    </div>
  );
}

/** The fit in figures, under the model settings */
export function FitNote({ t }: { t: T }) {
  const f = useShinyOutputValue<FitFacts>(ns("sc_fit"));
  return (
    <div className="sc-fit-note" style={f ? undefined : { display: "none" }}>
      <Show when={!!f?.tuning} className="small text-muted">
        {f?.tuning ? <><SlidersHorizontal size={12} /> {fill(t("Tuned by %s-fold cross-validation on %s training households: %s (cross-validated AUC %s)."),
          f.tuning.folds, int(f.tuning.n), f.tuning.best, f.tuning.auc.toFixed(3))}{" "}</> : null}
        <ActionButton id={ns("show_tuning")} label={t("See the grid")} link />
      </Show>
      {f?.k_auto ? (
        <div className="small text-muted"><SlidersHorizontal size={12} /> {fill(t("Number of profiles chosen automatically: %s (best silhouette %s among 2 to 8)."), f.k_auto.k, d2(f.k_auto.silhouette))}</div>
      ) : null}
      {f ? (
        <div className="small text-muted">
          {f.held_out
            ? fill(t("%s, fitted on %s households, %s held out for evaluation; %s criteria kept."), t(f.model), int(f.n), int(f.held_out), f.kept)
            : fill(t("%s, fitted on %s households; %s criteria kept."), t(f.model), int(f.n), f.kept)}
        </div>
      ) : null}
      {f?.index ? <IndexNote ix={f.index} t={t} /> : null}
      {f?.pmt ? (
        <div className="sc-stack">
          <FigGrid figs={f.pmt.figs} t={t} />
          {f.pmt.nonpositive > 0 ? <div className="small text-muted"><Info size={13} /> {fill(t("%s households with zero or negative welfare were left out of the fit (they cannot be logged)."), int(f.pmt.nonpositive))}</div> : null}
          {f.pmt.under ? (
            <Notice kind="warning">
              {fill(t("Under-coverage of %s: that share of poor households is predicted above the line. This is common for PMTs (Brown, Ravallion & van de Walle 2018 find 40-60% at typical coverage)."), f.pmt.under)}{" "}
              {t("Consider the quantile regression, a cut-off above the line (step 4), better proxies, or combining the PMT with community validation.")}
            </Notice>
          ) : null}
        </div>
      ) : null}
      {f && !f.converged ? (
        <Notice kind="warning">
          <strong>{t("The model did not converge cleanly.")}</strong>{" "}
          {t("Usually one criterion perfectly predicts the outcome (complete separation). Its weight is not trustworthy -- drop it in step 3 or set the weight by hand.")}
        </Notice>
      ) : null}
    </div>
  );
}

/** Below the estimates, folded: missing answers counted as "no", criteria removed by stepwise */
export function FitDetails({ t }: { t: T }) {
  const f = useShinyOutputValue<FitFacts>(ns("sc_fit"));
  if (!f || (!f.filled.length && !f.dropped.length)) return null;
  const head = [
    f.filled.length ? fill(f.is_pmt ? t("%s criteria had missing answers counted as 'no' (numbers as the average)") : t("%s criteria had missing answers counted as 'no'"), f.filled.length) : null,
    f.dropped.length ? fill(t("%s removed by stepwise selection"), f.dropped.length) : null,
  ].filter(Boolean).join(" · ");
  return (
    <details className="sc-details small text-muted sc-fit-details">
      <summary><Info size={13} /> {t("Notes on the fit:")} {head}</summary>
      {f.filled.length ? (
        <div className="mt-1">
          {f.is_pmt ? t("Missing answers counted as 'no', missing numbers as the average (as in the score):") : t("Missing answers counted as 'no' (as in the score):")}{" "}
          {f.filled.map((x) => `${x.name} (${int(x.n)})`).join(", ")}.
        </div>
      ) : null}
      {f.dropped.length ? (
        <div className="mt-1"><Scissors size={13} /> {t("Removed by stepwise selection (no information once the others are known):")} {f.dropped.join(", ")}</div>
      ) : null}
    </details>
  );
}

/* ----------------------------------------------- step 3: cluster profiles */

function TargetTick({ j, value, stamp, label, report }: { j: number; value: boolean; stamp: number; label: string; report: (j: number, v: boolean) => void }) {
  const [v, setV] = useRowInput<boolean>(ns(`tgt_${j}`), value, stamp);
  useEffect(() => { report(j, !!v); }, [v]); // eslint-disable-line
  return (
    <label className="sc-prof-tick">
      <input type="checkbox" className="form-check-input sc-tick" checked={!!v} onChange={(e) => setV(e.target.checked)} /> {label}
    </label>
  );
}

const tint = (d: number) => {
  const a = Math.min(Math.abs(d) / 0.4, 1) * 0.55;
  return d >= 0 ? `rgba(0,125,188, ${a.toFixed(2)})` : `rgba(247, 184, 37, ${a.toFixed(2)})`;
};

/** The household profiles (cluster methods): tick the ones to target, then refit the points */
export function ProfilesCard({ t }: { t: T }) {
  const p = useShinyOutputValue<Profiles>(ns("sc_profiles"));
  const [ticks, setTicks] = useState<Record<number, boolean>>({});
  const report = (j: number, v: boolean) => setTicks((x) => (x[j] === v ? x : { ...x, [j]: v }));
  const k = p?.k ?? 0;
  const rankWord = (r: number) => (r === 1 ? t("most vulnerable") : r === k ? t("least vulnerable") : fill(t("rank %s of %s"), r, k));
  // what the ticks would target (counting only; nothing is refitted)
  const pick = (p?.profiles ?? []).map((x) => x.j).filter((j) => ticks[j] ?? p?.target.includes(j)).sort((a, b) => a - b);
  const share = (p?.profiles ?? []).filter((x) => pick.includes(x.j)).reduce((s, x) => s + x.size, 0);
  const same = !!p && pick.length === p.target.length && pick.every((j) => p.target.includes(j));
  return (
    <Show when={!!p} className="sc-cluster">
      <Card title={fill(t("%s household profiles"), k)} icon={<Users size={15} />}
            help={<Tip>{t("Profiles are ordered from the most to the least vulnerable, judged on the anchor-oriented first component. Rows: the ten criteria that separate the profiles most. Each cell is the share of the profile's households giving the answer named under the criterion, tinted blue above the average household and amber below. Tick the profiles to target, then click Target the ticked profiles: the points are refitted to reproduce them.")}</Tip>}>
        {p ? (
          <div className="wfp-model-table-wrap wfp-prof-wrap">
            <table className="wfp-model-table wfp-prof-table">
              <thead>
                <tr>
                  <th>{t("Criterion")}</th>
                  <th>{t("Separates")} <Tip>{t("How strongly the criterion tells the profiles apart: Cramer's V of the criterion against profile membership, from 0 (every profile has the same share) to 1 (the criterion alone says which profile a household is in). Above about 0.3 the criterion is one of the things that define the profiles; below 0.1 it hardly differs between them.")}</Tip></th>
                  {p.profiles.map((x) => (
                    <th key={x.j} className="num wfp-prof-head">
                      <TargetTick j={x.j} value={p.target.includes(x.j)} stamp={p.stamp} label={fill(t("Profile %s"), x.j)} report={report} />
                      <div className="small fw-normal">{fill(t("%s of households"), pc0(x.size))}</div>
                      <div className={`small fw-normal ${x.rank === 1 ? "sc-down" : "text-muted"}`}>{rankWord(x.rank)}</div>
                    </th>
                  ))}
                  <th className="num">{t("All")} <Tip>{t("The share among all households, for comparison.")}</Tip></th>
                </tr>
              </thead>
              <tbody>
                {p.rows.map((r) => (
                  <tr key={r.criterion}>
                    <td className="tw-var wfp-prof-var">
                      <strong>{r.criterion}</strong>
                      {r.label ? <div className="tw-cell-label">{r.label}</div> : null}
                      {r.counted ? <div className="small text-muted">{fill(t("% of households answering “%s”"), r.counted)}</div> : null}
                    </td>
                    <td style={{ minWidth: 120 }}>
                      <div className="d-flex align-items-center gap-2">
                        <div className="wfp-prof-bar flex-grow-1"><span style={{ width: `${Math.round((100 * r.v) / p.vmax)}%`, background: "#007DBC" }} /></div>
                        <span className="small">{r.v.toFixed(2)}</span>
                      </div>
                    </td>
                    {r.cells.map((c, i) => <td key={i} className="num" style={{ background: tint(c.d) }}>{pc0(c.p)}</td>)}
                    <td className="num text-muted">{pc0(r.overall)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}
        <div className="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-2">
          <span className="small">
            {!pick.length ? t("No profile ticked.")
              : fill(pick.length > 1 ? t("Ticked: profiles %s, %s of households.") : t("Ticked: profile %s, %s of households."), pick.join(", "), pc0(share))}
            {!same && pick.length ? <span className="sc-warn-text"> {t("Click Target the ticked profiles to apply.")}</span> : null}
          </span>
          <ActionButton id={ns("cluster_apply")} label={t("Target the ticked profiles")} icon={<Target size={13} />} variant="primary" />
        </div>
        <div className="small mt-2">
          {fill(t("Separation of the profiles (silhouette): %s"), d2(p?.silhouette))}
          {isNum(p?.entropy) ? ` · ${fill(t("classification certainty (entropy): %s"), d2(p?.entropy))}` : ""}
          {isNum(p?.bic) ? ` · ${fill(t("BIC: %s"), int(p?.bic))}` : ""}{" "}
          <ActionButton id={ns("profile_quality")} label={t("Compare 2 to 8 profiles")} link />
        </div>
        {isNum(p?.fidelity) ? (
          <div className={`small ${p!.fidelity! < 0.8 ? "sc-warn-text" : "text-muted"}`}>
            {fill(p!.fidelity! < 0.8
              ? t("The points reproduce the targeted profiles with an AUC of %s: the profiles are not a straight cut through the criteria; try another number of profiles or method.")
              : t("The points reproduce the targeted profiles with an AUC of %s."), d2(p?.fidelity))}
          </div>
        ) : null}
      </Card>
    </Show>
  );
}

/* ------------------------------------------- step 3: diagram and tree rules */

/** The model's diagram (the design report's SVG, written by the app) and the tree's leaves */
export function DiagramCards({ t }: { t: T }) {
  const d = useShinyOutputValue<DiagramFacts>(ns("sc_diagram"));
  if (!d) return null;
  return (
    <>
      {d.diagram ? (
        <Card full title={t(d.diagram.title)} icon={<Network size={15} />} help={<Tip>{t(d.diagram.help)}</Tip>} className="sc-diagram-card">
          {/* app-written SVG (R/utils_diagrams.R, labels escaped there) */}
          <div className="sc-diagram" dangerouslySetInnerHTML={{ __html: d.diagram.svg }} />
        </Card>
      ) : null}
      {d.residuals ? (
        <Card full title={t(d.residuals.title)} icon={<Network size={15} />} help={<Tip>{t(d.residuals.help)}</Tip>} className="sc-diagram-card">
          {/* app-written SVG (residual_svg() in R/utils_diagrams.R) */}
          <div className="sc-diagram" dangerouslySetInnerHTML={{ __html: d.residuals.svg }} />
        </Card>
      ) : null}
      {d.tree?.length ? (
        <Card full title={t("Decision tree: the rules")} icon={<Network size={15} />}
              help={<Tip>{d.nof
                ? t("Each row is a leaf of the tree: the answers that lead to it, how many households it holds and the share of them in the targeted profiles. The points of the ranking are the tree's average effects, so it stays additive; the rules show what the tree itself does.")
                : t("Each row is a leaf of the tree: the answers that lead to it, how many training households it holds and the share of them that is vulnerable. The points of the card are the tree's average effects, so the card stays additive; the rules show what the tree itself does.")}</Tip>}>
          <div className="wfp-model-table-wrap sc-tree-rules">
            <table className="wfp-model-table">
              <thead><tr><th>{t("If the household...")}</th><th className="num">{t("Households")}</th><th className="num">{d.nof ? t("In targeted profiles") : t("Vulnerable")}</th></tr></thead>
              <tbody>
                {d.tree.map((r, i) => (
                  <tr key={i}><td className="small">{r.rule}</td><td className="num">{int(r.households)}</td><td className="num"><strong>{pc0(r.share)}</strong></td></tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      ) : null}
    </>
  );
}

/* --------------------------------------------------- step 4: PMT and ranking */

export function PmtAccuracyCard({ t }: { t: T }) {
  const a = useShinyOutputValue<PmtAccuracy>(ns("sc_pmt_accuracy"));
  if (!a) return null;
  return (
    <Card title={t("PMT targeting accuracy at this cut-off")} icon={<Target size={15} />} className="sc-pmt-acc">
      <div className="small text-muted mb-2">
        {fill(t("Selected when predicted welfare per person is below %s (%s of the poverty line); %s evaluation households."),
              a.welfare, `${Math.round(a.pct_line)}%`, int(a.n))}
      </div>
      <FigGrid figs={a.figs} t={t} />
    </Card>
  );
}

/** The PMT cut-off in welfare per person, under the threshold */
export function PmtLineNote({ stale, t }: { stale?: Stale | null; t: T }) {
  const l = stale?.pmt_line;
  if (!l) return null;
  return <span>{fill(t("Eligible when predicted welfare per person is below %s (%s of the poverty line)."), l.welfare, `${Math.round(l.pct)}%`)}</span>;
}

const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

/** Stability of the selection: the check's result, and the button that runs it */
export function StabilityBody({ r, t }: { r?: RankingFacts | null; t: T }) {
  const st = r?.stability;
  return (
    <>
      {!st ? <div className="small text-muted mb-2">{t("Refits the design on 20 resamples of the households and compares their selections with this one.")}</div> : (
        <div className="mb-2 sc-stability-result">
          <strong>{fill(t("%s: %s agreement"), cap(t(st.word)), pc0(st.jaccard))}</strong>
          <div className="small text-muted">
            {fill(t("Jaccard index of the selections, median of %s refits (10th-90th percentile %s-%s), at %s of households selected."),
                  st.draws, pc0(st.low), pc0(st.high), pc0(st.share))}
            {isNum(st.spearman) ? ` ${fill(t("Rank agreement (Spearman) %s."), d2(st.spearman))}` : ""}
          </div>
        </div>
      )}
      <ActionButton id={ns("run_stability")} label={st ? t("Check again") : t("Check stability")} icon={<Shuffle size={13} />} />
    </>
  );
}

/** What the selection concentrates */
export function InsightsList({ r, t }: { r?: RankingFacts | null; t: T }) {
  const si = r?.insights, st = r?.stability;
  if (!si) return <div className="small text-muted">{t("Set a threshold that selects some households.")}</div>;
  const item = (strong: ReactNode, rest: string) => <li><strong>{strong}</strong> {rest}</li>;
  return (
    <ul className="small mb-0 sc-insights">
      {item(fill(t("%s times"), si.ratio.toFixed(1)), fill(t("as many deprivations among the selected (%s of %s criteria) as among the others (%s)."), si.mean_sel.toFixed(1), si.n_criteria, si.mean_not.toFixed(1)))}
      {item(pc0(si.concentration), fill(t("of all deprivations are held by the %s of households selected."), pc0(si.share)))}
      {!st || !isNum(st.spearman) ? <li>{t("Rank agreement across resamples: run the stability check.")}</li>
        : item(d2(st.spearman), t("rank agreement across resamples (Spearman): how far the order of households holds when the data change."))}
    </ul>
  );
}

/** A note that a setting waits for its button, in the toolkit's look */
export function StaleNote({ show, children }: { show: boolean; children: ReactNode }) {
  return <Pending show={show}><TriangleAlert size={13} /> {children}</Pending>;
}

