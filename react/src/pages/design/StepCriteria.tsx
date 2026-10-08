// Step 2, the criteria: one table, every yes/no variable with its test and
// overlap, the Use ticks (inputs rvuse_<variable>) pre-set by the server.
// Continue (nav_next_screening) sends the ticked ones to the model.
import { useMemo, useRef, useState } from "react";
import { CheckSquare, Grid3x3, Hash, Play, Search, ShieldAlert, Square, TriangleAlert } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, NumericInput, SelectInput } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { useVarLabels } from "@/lib/labels";
import { useOutputVisibility } from "@/lib/visibility";
import { BlockedNote } from "./facts";
import { EmptyState } from "@/components/Figures";
import { VarCalcBulk } from "@/components/VarCalc";
import { Gate, OrCell, Pending, Show, StepNav, Tip, TipList, UseTick, isNum, ns, pct0, setUseTicks, type T } from "./shared";
import type { CritRow, Criteria, Flow, Mode, PmtNumeric } from "./types";

export function StepCriteria({ flow, mode, t }: { flow?: Flow; mode: Mode; t: T }) {
  const crit = useShinyOutputValue<Criteria>(ns("sc_criteria"));
  const [q, setQ] = useState("");
  const vl = useVarLabels();
  const nof = mode === "none";
  // computed only while this step shows (PORTING.md, "Hidden outputs wait")
  const ref = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("sc_criteria"), ref);
  useOutputVisibility(ns("sc_pmt_numeric"), ref);
  return (
    <div className="sc-step" ref={ref}>
      <Gate show={!!flow && flow.gates.screening} text={t("Screening compares each variable with the vulnerability framework, so set it first.")}
            btn="back_to_outcome" label={t("Back to Vulnerability Framework")} />

      <Show when={!nof}>
        <p className="sc-lead">{t("Every yes/no variable of the data, tested against the vulnerability framework. The ones associated with vulnerability come ticked in Use, except the weaker of any two that repeat each other. Adjust the ticks and continue to the model.")}</p>
        <div className="sc-settings">
          <NumericInput id={ns("qs_alpha")} value={0.05} min={0.001} max={0.5} step={0.005}
                        label={<>{t("Significance level")} <Tip>{t("A variable counts as associated when its adjusted p-value is below this level. 0.05 is the usual choice.")}</Tip></>} />
          <SelectInput id={ns("qs_adjust")} value="BH" clearable={false}
                       choices={[{ value: "BH", label: "Benjamini-Hochberg" }, { value: "bonferroni", label: "Bonferroni" }, { value: "holm", label: "Holm" }, { value: "none", label: t("None") }]}
                       label={<>{t("Multiplicity adjustment")} <Tip><TipList title={t("Testing many variables at once finds some by chance")} items={[
                         { name: "Benjamini-Hochberg.", text: t("Controls the share of false findings among those declared associated. Recommended."), ref: "Benjamini & Hochberg (1995), JRSS B 57(1)." },
                         { name: "Bonferroni / Holm.", text: t("Control the chance of even one false finding: stricter, fewer associations."), ref: "Holm (1979), Scandinavian Journal of Statistics 6(2)." },
                         { name: t("None."), text: t("No correction; expect false findings when there are many variables.") }]} /></Tip></>} />
          <NumericInput id={ns("corr_cutoff")} value={0.8} min={0.3} max={1} step={0.05}
                        label={<>{t("Overlap above |r|")} <Tip>{t("Two variables correlated above this value say nearly the same thing. The weaker of the pair starts unticked, so one effect is not counted twice in the score.")}</Tip></>} />
          <ActionButton id={ns("qs_run")} label={t("Run the tests")} icon={<Play size={13} />} variant="outline-primary" size="md" className="sc-row-btn" />
        </div>
        {flow?.qs_stale
          ? <Pending show><TriangleAlert size={14} /> {t("The settings changed since the tests were run: click Run the tests to apply them.")}</Pending>
          : <div className="small text-muted mb-1">{t("Change the settings, then Run the tests: running again resets the Use ticks.")}</div>}
      </Show>
      <Show when={nof}>
        <p className="sc-lead">{t("Every yes/no variable of the data. Without an outcome nothing is tested: tick the criteria that describe vulnerability in this context (for deprivation counting, so that 'yes' means deprived). Variables met by 5% to 95% of households come ticked, except the weaker of any two that repeat each other.")}</p>
      </Show>

      <Card className="sc-crit-card" title={t("Candidate criteria")} icon={<Hash size={15} />}
            actions={<>
              <span title={t("Turn variables with several answers or numbers into yes/no, with the split that separates vulnerable households best. The new variables join this table.")}>
                <VarCalcBulk ns={ns("calc")} t={t} />
              </span>
              <ActionButton id={ns("open_corr")} label={t("Correlations")} icon={<Grid3x3 size={13} />} variant="outline-secondary"
                            title={t("Correlation matrix and descriptive statistics of the ticked variables.")} />
            </>}>
        {crit ? (
          <>
            <div className="sc-crit-bar">
              <div className="sc-strip">
                <span><strong>{crit.n}</strong> {t("variables")}</span>
                {!crit.nof ? <span><strong>{crit.associated}</strong> {t("associated")}</span> : null}
                <span><strong>{crit.repeating}</strong> {t("repeating another")}</span>
                <span className="is-key"><strong>{flow?.nav.screening.n ?? 0}</strong> {t("ticked")}</span>
              </div>
              <div className="sc-crit-right">
                {/* the rows shown: after a search, only the ones found */}
                <button type="button" className="btn btn-outline-secondary btn-sm" onClick={() => setUseTicks(shownIds(crit, q, vl), true)}
                        title={t("Tick Use for every variable shown")}><CheckSquare size={13} /> {t("Select all")}</button>
                <button type="button" className="btn btn-outline-secondary btn-sm" onClick={() => setUseTicks(shownIds(crit, q, vl), false)}
                        title={t("Untick Use for every variable shown")}><Square size={13} /> {t("Deselect all")}</button>
                <label className="tw-search sc-search">
                  <Search size={13} />
                  <input type="search" className="form-control form-control-sm" placeholder={t("Search variables")} aria-label={t("Search variables")}
                         value={q} onChange={(e) => setQ(e.target.value)} />
                </label>
              </div>
            </div>
            <CriteriaTable crit={crit} q={q} t={t} />
          </>
        ) : <EmptyState title={t("No variables yet")} sub={t("Set the vulnerability framework: the table fills by itself.")} />}
      </Card>

      <Show when={mode === "pmt"}><PmtNumericCard t={t} /></Show>

      <details className="sc-details small">
        <summary><strong>{t("How to read this table")}</strong></summary>
        <ul className="mt-2 mb-0">
          <li><strong>{t("Among vulnerable / among others")}</strong>: {t("the share of households meeting the criterion in each outcome group. More common among the vulnerable: an inclusion criterion; less common: an exclusion criterion.")}</li>
          <li><strong>{t("Odds ratio and adjusted p")}</strong>: {t("each variable is tested alone with a one-criterion logistic regression and a likelihood-ratio test (Fisher's exact test when that model cannot be estimated). The p-values are adjusted for testing many variables. ↑ associated with vulnerability, ↓ associated with not being vulnerable.")}</li>
          <li><strong>{t("Overlaps with")}</strong>: {t("the associated variable it correlates with most. Above the cut-off, the weaker of the pair starts unticked.")}</li>
          <li><strong>{t("Missing")}</strong>: {t("households with no answer. Above about 20%, check the question: in the score a missing answer counts as 'no'.")}</li>
          {nof
            ? <li>{t("Without an outcome every yes/no variable is listed except names and identifiers: outcome indicators and what a registration team cannot observe may rank households too, but a criterion the registration cannot collect cannot be applied in Beneficiary Selection.")}</li>
            : <li>{t("Every variable listed is observable at registration and not an outcome indicator (checked automatically; the others are listed below).")}</li>}
          <li>{t("A variable with no clear association alone can still matter next to others: keep what field knowledge supports, the model gives each its net weight.")}</li>
        </ul>
      </details>
      <details className="sc-details small" onToggle={(e) => { if ((e.target as HTMLDetailsElement).open) window.dispatchEvent(new Event("resize")); }}>
        <summary><strong><ShieldAlert size={14} /> {t("Columns that cannot be criteria")}</strong></summary>
        <div className="pt-2"><BlockedNote t={t} /></div>
      </details>

      <StepNav back="nav_back_screening" backLabel={t("Back to Vulnerability Framework")} nav={flow?.nav.screening}
               next="nav_next_screening" nextLabel={`${t("Continue to the model")} (${flow?.nav.screening.n ?? 0})`} t={t} />
    </div>
  );
}

/** The rows the table shows for this search (name or label) */
function shownIds(crit: Criteria, q: string, vl: { label: (v: string) => string | null }): string[] {
  const s = q.trim().toLowerCase();
  return crit.rows.filter((r) => !s || `${r.criterion} ${vl.label(r.criterion) ?? ""}`.toLowerCase().includes(s)).map((r) => r.id);
}

function CriteriaTable({ crit, q, t }: { crit: Criteria; q: string; t: T }) {
  const vl = useVarLabels();
  const hide = useMemo(() => {
    const s = q.trim().toLowerCase();
    if (!s) return new Set<string>();
    return new Set(crit.rows.filter((r) => !(`${r.criterion} ${vl.label(r.criterion) ?? ""}`.toLowerCase().includes(s))).map((r) => r.id));
  }, [q, crit, vl]);
  const shown = crit.rows.length - hide.size;
  return (
    <div className="wfp-model-table-wrap sc-crit-wrap">
      <table className="wfp-model-table sc-crit">
        <thead>
          <tr>
            <th className="text-center">{t("Use")}</th><th>{t("Variable")}</th>
            {crit.nof ? <th className="num">{t("Households yes")}</th> : <>
              <th className="num">{t("Among vulnerable")}</th><th className="num">{t("Among others")}</th>
              <th>{t("Odds ratio")}</th><th className="num">{t("Adjusted p")}</th></>}
            <th>{t("Overlaps with")}</th><th className="num">{t("Missing")}</th>
          </tr>
        </thead>
        <tbody>
          {crit.rows.map((r) => <CritLine key={r.id} r={r} nof={crit.nof} stamp={crit.stamp} hidden={hide.has(r.id)} label={vl.label(r.criterion)} t={t} />)}
          {!shown ? <tr><td colSpan={8} className="text-center text-muted small py-3">{t("No variable matches.")}</td></tr> : null}
        </tbody>
      </table>
    </div>
  );
}

function CritLine({ r, nof, stamp, hidden, label, t }: { r: CritRow; nof: boolean; stamp: number; hidden: boolean; label: string | null; t: T }) {
  const p = r.p;
  const pCell = !r.testable && !isNum(p) ? <span className="text-muted">{"–"}</span>
    : !r.testable ? <span className="text-muted">{t("not testable")}</span>
    : r.sig ? <strong className={r.dir === "inclusion" ? "sc-up" : "sc-down"}>{r.dir === "inclusion" ? "↑ " : "↓ "}{fmtP(p)}</strong>
    : <span className="text-muted">{fmtP(p)}</span>;
  // the bars show the two shares side by side
  return (
    <tr style={hidden ? { display: "none" } : undefined} className={r.sig ? "is-sig" : undefined}>
      <td className="text-center"><UseTick id={r.id} value={r.use} stamp={stamp} label={`${t("Use")} ${r.criterion}`} /></td>
      <td className="tw-var" data-tw="1"><strong>{r.criterion}</strong>{label ? <div className="tw-cell-label">{label}</div> : null}</td>
      {nof ? <td className="num"><ShareBar v={r.yes} /></td> : <>
        <td className="num"><ShareBar v={r.vuln} tone="vuln" /></td>
        <td className="num"><ShareBar v={r.other} tone="other" /></td>
        <td><OrCell or={r.or} lo={r.or_low} hi={r.or_high} /></td>
        <td className="num">{pCell}</td></>}
      <td className="small">{r.overlap ? <span className={r.overlap.high ? "text-danger" : "text-muted"}>{r.overlap.text}</span> : "–"}</td>
      <td className={`num${isNum(r.missing) && r.missing > 0.2 ? " text-warning" : ""}`}>{pct0(r.missing)}</td>
    </tr>
  );
}

const fmtP = (v: number | null) => (!isNum(v) ? "–" : v < 0.0001 ? "< 0.0001" : v.toFixed(4));

function ShareBar({ v, tone }: { v: number | null; tone?: "vuln" | "other" }) {
  return (
    <span className={`sc-share${tone ? " is-" + tone : ""}`}>
      <span className="sc-share-num">{pct0(v)}</span>
      <span className="sc-share-bar"><span style={{ width: `${isNum(v) ? Math.max(0, Math.min(1, v)) * 100 : 0}%` }} /></span>
    </span>
  );
}

/** Step 2 with a welfare measure: the numeric proxies (inputs pnum_<column>) */
function PmtNumericCard({ t }: { t: T }) {
  const d = useShinyOutputValue<PmtNumeric>(ns("sc_pmt_numeric"));
  return (
    <Card title={t("Numeric proxies")} icon={<Hash size={15} />}>
      <p className="small text-muted mb-2">
        {t("A PMT also uses numbers as they are: household size (usually the strongest proxy), rooms, members by age, years of education. Each gets points per unit; a missing value takes the average. The yes/no variables ticked above are used too; tick the numbers to use here.")}
      </p>
      {!d ? <div className="small text-muted">{t("Validate the welfare setup (Vulnerability Framework) to list the numeric proxies.")}</div> : (
        <div className="wfp-model-table-wrap">
          <table className="wfp-model-table">
            <thead><tr>
              <th className="text-center">{t("Use")}</th><th>{t("Proxy")}</th><th className="num">{t("Average")}</th><th className="num">{t("Missing")}</th>
              <th className="num">{t("Correlation with log welfare")} <Tip>{t("Negative: households with more of it are poorer (an inclusion proxy, as household size usually is).")}</Tip></th>
            </tr></thead>
            <tbody>
              {d.rows.map((r) => (
                <tr key={r.id}>
                  <td className="text-center"><UseTick id={r.id} value={r.use} stamp={d.stamp} label={`${t("Use")} ${r.proxy}`} /></td>
                  <td className="tw-var"><strong>{r.proxy}</strong></td>
                  <td className="num">{isNum(r.mean) ? r.mean.toFixed(2) : "–"}</td>
                  <td className="num">{pct0(r.missing)}</td>
                  <td className="num">{isNum(r.r) ? `${r.r >= 0 ? "+" : ""}${r.r.toFixed(2)}` : "–"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Card>
  );
}
