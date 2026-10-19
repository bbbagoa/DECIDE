// Tab 1, implementation errors (R/mod_pdm.R, module monitoring_1-pdm): the
// survey (or PDM) data, the sample list drawn in Beneficiary Selection,
// who was selected and who was eligible, the weighting, then the errors, the
// verdict, the decision per area, the details and the ranking calibration.
// Facts come from output$pdm_state, pdm_side, pdm_verdict and calib_state;
// the file input is the server's, hosted.
import { useRef, useState, type ReactNode } from "react";
import {
  Calculator, ChartColumn, ClipboardCheck, Download, Info, MapPin, Scale, SignpostBig, SlidersHorizontal, Table,
  Target, Upload, UserCheck, Users, UserMinus, UserPlus, Play, TrendingUp,
} from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton, NumericInput, RadioInput, SelectInput, type Choice } from "@/lib/inputs";
import { useOutputVisibility } from "@/lib/visibility";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { Card, Notice, SideActions, SidebarLayout, Steps, Tabs } from "@/lib/layout";
import { EmptyState } from "@/components/Figures";
import { AreaScope } from "@/components/AreaScope";
import { ModaImport } from "@/components/ModaImport";
import { ModaRefresh } from "@/components/ModaRefresh";
import { DataSummary } from "@/components/DataSummary";
import { Dropzone } from "./Dropzone";
import { ChartBuilder } from "./ChartBuilder";

const P = "monitoring_1-pdm-";
const ns = (x: string) => P + x;

type Matrix = { correct_in: number; incl: number; excl: number; correct_out: number;
                n_correct_in: number; n_incl: number; n_excl: number; n_correct_out: number };
type Decision = { area: string; n_selected: number; n_not: number; eligible: number; reached: number; coverage: number | null; inclusion: number | null; exclusion: number | null; level: string; decision: string };
type PdmState = {
  data: { source: string; rows: number; cols: number } | null;
  sample: { file: string; drawn_at: string; n: number; selected: number; not_selected: number; areas: number; design: boolean; from_survey?: boolean } | null;
  match: { n: number; of: number } | null;
  results: {
    kind: string; inclusion: number | null; exclusion: number | null; coverage: number | null; precision: number | null; recall: number | null;
    elig_source: string; weighting: string; no_nonbenef: boolean;
    levels?: { label: string; rows: Decision[] }[]; matrix?: Matrix | null; excl_design?: number | null;
  } | null;
};

type Side = {
  benef: { n: number; choices: Choice[] } | null; elig: { kind: "warning" | "note"; text: string } | null;
  elig_levels: { n: number; choices: Choice[] } | null;
};
type Calib = {
  status: "none" | "nodata" | "ready"; missing?: string[]; cols?: string[];
  result?: {
    auc: number | null; n: number; outcome: string; pos: string; threshold: string; inclusion: number | null; exclusion: number | null;
    best: { threshold: string; inclusion: number | null; exclusion: number | null } | null;
  } | null;
} | null;

const n0 = (x: number) => Math.round(x).toLocaleString("en-US");
const pc = (x: number | null | undefined) => (x === null || x === undefined || !isFinite(x) ? "—" : `${(100 * x).toFixed(1).replace(/\.0$/, "")}%`);
const pcNa = (x: number | null | undefined) => (x === null || x === undefined || !isFinite(x) ? "n/a" : `${(100 * x).toFixed(1)}%`);
const show = (on: boolean) => (on ? undefined : { display: "none" });

function Kpi({ label, value, icon, tone }: { label: string; value: string; icon: ReactNode; tone: string }) {
  return (
    <div className={`tw-mon-kpi tone-${tone}`}>
      <span className="tw-mon-kpi-icon">{icon}</span>
      <div><div className="tw-mon-kpi-label">{label}</div><div className="tw-mon-kpi-value">{value}</div></div>
    </div>
  );
}

export function PdmTab({ t }: { t: (s: string) => string }) {
  const st = useShinyOutputValue<PdmState>(ns("pdm_state"));
  const side = useShinyOutputValue<Side>(ns("pdm_side"));
  // pdm_state waits while this tab is hidden (it matches the survey to the sample)
  const here = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("pdm_state"), here);
  const kind = useShinyInputValue<string>(ns("data_kind")) ?? "Baseline";
  const benefSrc = useShinyInputValue<string>(ns("benef_source")) ?? "design";
  const eligSrc = useShinyInputValue<string>(ns("pdm_elig_source")) ?? "column";
  const wMode = useShinyInputValue<string>(ns("pdm_weight_mode")) ?? "design";
  const popScope = useShinyInputValue<string>(ns("pop_scope")) ?? "overall";
  const unit = useShinyInputValue<string>(ns("pdm_unit")) ?? "";
  const tolLo = useShinyInputValue<number>(ns("tol_lower")), tolUp = useShinyInputValue<number>(ns("tol_upper"));
  const r = st?.results ?? null;
  const before = r ? r.kind !== "PDM" : kind !== "PDM";

  const sidebar = (
    <>
      <Steps open="data" steps={[
        {
          key: "data", title: t("1. Load the survey"), icon: <Upload size={14} />,
          summary: st?.data ? st.data.source : t("Nothing loaded"),
          content: <>
            <RadioInput id={ns("data_kind")} value="Baseline" choices={[
              { value: "Baseline", label: t("Post-targeting survey / baseline (before distribution, recommended)") },
              { value: "PDM", label: t("PDM (after distribution, least preferred)") }]} />
            {kind === "PDM"
              ? <Notice kind="warning" className="mb-2">{t("The least preferred option: after distribution nothing can be undone, vulnerability may have changed, and the assistance itself may have changed the answers to some criteria (assets bought, debts paid). Use it when no survey could be done before distribution.")}</Notice>
              : <p className="small text-muted mb-2">{t("A survey of eligible and not eligible households after the selection and before the distribution (the sample drawn in Beneficiary Selection): problems in an area can still be fixed, or its distribution paused.")}</p>}
            <Dropzone id={ns("pdm_file_ui")} />
            <ModaImport ns={ns("moda")} size="sm" t={t} />
            <ModaRefresh ns={ns("moda_refresh")} block className="mt-2" t={t} />
            <ActionButton id={ns("fsi-open")} label={t("Food security indicators")} icon={<Calculator size={14} />} variant="outline-secondary"
                          title={t("Calculate FCS, rCSI, LCS, FES or CARI from the WFP standard variables")} className="w-100 mt-2" />
            <DataSummary ns={ns("summary")} block className="mt-2" t={t} />
            {st?.data && (
              <div className="tw-mon-status">
                <span className="ok"><strong>{st.data.source}</strong></span><br />
                {n0(st.data.rows)} {t("records")}, {n0(st.data.cols)} {t("variables. Continue with the steps below.")}
              </div>
            )}
          </>,
        },
        {
          key: "benef", title: t("2. Who was selected"), icon: <UserCheck size={14} />,
          summary: benefSrc === "design" ? t("From the sample list") : t("A column"),
          content: <>
            <RadioInput id={ns("benef_source")} value="design" choices={[
              { value: "design", label: t("The sample list from Beneficiary Selection (recommended)") }, { value: "column", label: t("A column in the survey (e.g. a PDM)") }]} />
            <div style={show(benefSrc === "design")}>
              {/* a survey that kept the sample columns needs no upload */}
              <div hidden={!!st?.sample?.from_survey}>
                <div className="small text-muted mb-1">{t("The sample list downloaded from Beneficiary Selection (Excel), as it is.")}</div>
                <Dropzone id={ns("ptm_sample_ui")} />
              </div>
              {st?.sample && (
                <div className="tw-mon-status mb-2">
                  <span className="ok"><strong>{st.sample.from_survey ? t("Read from the survey: nothing to upload") : (st.sample.file || t("Sample list"))}</strong></span><br />
                  {n0(st.sample.n)} {t("households")} ({n0(st.sample.selected)} {t("eligible")}, {n0(st.sample.not_selected)} {t("not eligible")}), {st.sample.areas} {t("area(s)")}{st.sample.drawn_at ? `, ${t("drawn")} ${st.sample.drawn_at}` : ""}.
                  {!st.sample.design && <div className="text-warning">{t("No Design sheet: type the population sizes in step 4.")}</div>}
                </div>)}
              <SelectInput id={ns("ptm_id")} label={t("Household ID in the survey")} choices={[]} value="" />
              {!st?.sample
                ? <div className="small text-warning mb-2">{t("Upload the sample list first, or use a column in the data.")}</div>
                : st.match && (
                  <div className={`small mb-2 ${st.match.n < st.match.of ? "text-warning" : "text-success"}`}>
                    {n0(st.match.n)} {t("of")} {n0(st.match.of)} {t("surveyed households found in the sample list.")}
                    {st.match.n < st.match.of ? ` ${t("The others are left out.")}` : ""}
                  </div>)}
            </div>
            <div style={show(benefSrc === "column")}>
              <SelectInput id={ns("pdm_beneficiary")} label={t("Selected / beneficiary column")} choices={[]} value="" />
              {side?.benef && side.benef.n !== 2 && (
                <div className="small text-danger mb-2">{t("This column has %d different answers; choose one with exactly two (received / not received).").replace("%d", String(side.benef.n))}</div>)}
              {/* always mounted, so the server's choice of answer reaches it */}
              <div hidden={side?.benef?.n !== 2}>
                <RadioInput id={ns("pdm_benef_level")} label={t("Answer meaning 'received assistance'")} inline choices={side?.benef?.choices ?? []} />
              </div>
              <SelectInput id={ns("pdm_prioritized")} label={t("Prioritised column (optional)")} choices={[]} value=""
                           help={t("Eligible households not prioritised for lack of resources are excluded by design, not exclusion errors.")} />
              <SelectInput id={ns("pdm_unit")} label={t("Area column (optional)")} choices={[]} value=""
                           help={t("To judge each area on its own. The sample list already carries the areas.")} />
            </div>
          </>,
        },
        {
          key: "elig", title: t("3. Who should have been selected"), icon: <ClipboardCheck size={14} />,
          summary: { column: t("A column"), logic: t("The selection logic") }[eligSrc],
          content: <>
            <RadioInput id={ns("pdm_elig_source")} value="column" choices={[
              { value: "column", label: t("A column in the data") },
              { value: "logic", label: t("Apply the selection logic (from Beneficiary Selection)") }]} />
            {/* what Selection applied (approach, card and threshold, rules), from its file: not the Design card */}
            <div hidden={eligSrc !== "logic"}>
              <div className="small text-muted mb-1">{t("The selection logic file downloaded from Beneficiary Selection (Outputs, .json).")}</div>
              <Dropzone id={ns("pdm_logic_ui")} />
            </div>
            <div style={show(eligSrc === "column")}>
              <SelectInput id={ns("pdm_eligibility")} label={t("Eligibility column")} choices={[]} value=""
                           help={t("A yes / no column, e.g. one made by Food security indicators (CARI_FES_2class, FCS_PoorBorderline...).")} />
              {/* always mounted, so the server's choice of answer reaches it */}
              <div hidden={side?.elig_levels?.n !== 2}>
                <RadioInput id={ns("pdm_elig_level")} label={t("Answer meaning 'vulnerable' (should be assisted)")} inline choices={side?.elig_levels?.choices ?? []} />
              </div>
            </div>
            {side?.elig && (side.elig.kind === "warning"
              ? <Notice kind="warning" className="mb-2">{t(side.elig.text)}</Notice>
              : <div className="small text-muted mb-2">{t(side.elig.text)}</div>)}
          </>,
        },
        {
          key: "weight", title: t("4. Weighting"), icon: <Scale size={14} />,
          summary: { design: t("Sample design"), population: t("Population sizes"), column: t("A weight column"), none: t("None") }[wMode],
          content: <>
            <RadioInput id={ns("pdm_weight_mode")} value="design" choices={[
              { value: "design", label: t("From the sample design (recommended)") }, { value: "population", label: t("Population sizes typed in") },
              { value: "column", label: t("A weight column") }, { value: "none", label: t("None") }]} />
            <div style={show(wMode === "column")}>
              <SelectInput id={ns("pdm_weight")} label={t("Weight column")} choices={[]} value="" />
            </div>
            <div style={show(wMode === "population")}>
              <RadioInput id={ns("pop_scope")} value="overall" buttons
                          choices={[{ value: "overall", label: t("Overall") }, { value: "unit", label: t("Per area") }]} />
              <div style={show(popScope === "overall")}>
                <NumericInput id={ns("pop_benef")} label={t("Beneficiary households")} min={0} />
                <NumericInput id={ns("pop_nonbenef")} label={t("Non-beneficiary households")} min={0} />
              </div>
              {popScope === "unit" && <div className="small text-muted">{t("Type the sizes per area in the table on the right.")}</div>}
            </div>
          </>,
        },
        {
          key: "tol", title: t("5. Tolerance band"), icon: <Target size={14} />,
          summary: `${tolLo ?? 5}%-${tolUp ?? 20}%`,
          content: <>
            <NumericInput id={ns("tol_lower")} label={t("Lower error tolerance (%)")} value={5} min={0} max={49} step={1} />
            <NumericInput id={ns("tol_upper")} label={t("Upper error tolerance (%)")} value={20} min={1} max={49} step={1} />
            <div className="small text-muted">{t("Errors up to the lower value are acceptable, above the upper one the targeting must be revisited (Targeting Advisory 2/2025; the upper value stays below 50%).")}</div>
          </>,
        },
      ]} />
      <SideActions>
        <div className="small fw-semibold" ref={here}>{t("6. Compute")}</div>
        <ActionButton id={ns("pdm_run")} label={t("Compute implementation errors")} icon={<Calculator size={14} />} variant="primary" className="w-100" />
        <DownloadButton id={ns("pdm_download")} label={t("Export (Excel)")} icon={<Download size={14} />} variant="outline-secondary" className="w-100" />
        <div className="small text-muted d-flex gap-1"><Info size={14} className="flex-shrink-0 mt-1" />
          <span>{t("Implementation errors measure whether the criteria were applied correctly on the ground, not whether they were right (that is the design error).")}</span></div>
      </SideActions>
      {/* a filter, not a step: kept apart from the steps above */}
      <details className="tw-mon-filter">
        <summary><MapPin size={14} /> {t("Limit to some areas (optional)")}</summary>
        <AreaScope ns={ns("scope")} title={null} t={t} />
      </details>
    </>
  );

  const perUnit = wMode === "population" && popScope === "unit";
  return (
    <SidebarLayout width={330} sidebar={sidebar}>
      {!r && <HowTo t={t} />}
      {perUnit && (!unit || unit === "(none)"
        ? <Notice kind="warning">{t("Choose the area column (step 2, A column in the survey) to give the population sizes per area.")}</Notice>
        : <Card title={t("Population sizes per area")} icon={<Users size={15} />}>
            <p className="small text-muted mb-2">{t("Double-click a cell of the last two columns to type the number of beneficiary and non-beneficiary households in each area.")}</p>
            <DataTable id={ns("pop_table")} searchable={false} compact />
          </Card>)}
      {!st?.data
        ? <EmptyState title={t("No survey data loaded")} sub={t("Follow the steps on the left, from 1 to 5, then click Compute implementation errors.")} />
        : !r && <EmptyState title={t("Ready to compute")} sub={t("Check steps 2 to 5, then click Compute implementation errors.")} />}
      <Tabs id={ns("pdm_tabs")} tabs={[
        {
          value: "errors", label: t("Errors and decisions"), icon: <Target size={14} />,
          content: <>
            {r && <>
              <Notice>
                {t("Eligibility from")} {r.elig_source}; {t("weighting")}: {r.weighting}.
                {r.no_nonbenef && <strong> {t("Only beneficiaries were surveyed: the exclusion error cannot be measured.")}</strong>}
              </Notice>
            </>}
            {/* the table the errors come from, beside their chart */}
            <div className="tw-mon-errgrid" style={show(!!r)}>
              <Card title={t("Eligibility vs. assistance received (estimated households)")} full>
                {r && <ImplMatrix r={r} t={t} />}
              </Card>
              <Card title={t("Errors vs. tolerance")} full><Chart id={ns("pdm_plot")} height={320} /></Card>
              <Card title={t("Coverage and precision")} full><Chart id={ns("pdm_cov_plot")} height={320} /></Card>
            </div>
            {r && (r.levels?.length ?? 0) > 0 && <AreaTable levels={r.levels!} before={before} t={t} />}
          </>,
        },
        { value: "calibrate", label: t("Calibrate the ranking"), icon: <SlidersHorizontal size={14} />, content: <Calibrate t={t} /> },
        { value: "explore", label: t("Explore the data"), icon: <ChartColumn size={14} />, content: <ChartBuilder prefix="monitoring_1-pdm_charts-" t={t} /> },
      ]} />
    </SidebarLayout>
  );
}

/** The contingency table of Targeting Advisory 2/2025 (p. 6) with the survey's
 *  estimated households: assistance in rows, eligibility in columns. Each cell
 *  has its estimated households, its share of the row or column the Advisory
 *  divides by, and the households surveyed in it; the two error rates are
 *  coloured by the tolerance band. Styles shared with the design matrix (.sc-cm). */
function ImplMatrix({ r, t }: { r: NonNullable<PdmState["results"]>; t: (s: string) => string }) {
  const m = r.matrix;
  const lower = (useShinyInputValue<number>(ns("tol_lower")) ?? 5) / 100;
  const upper = (useShinyInputValue<number>(ns("tol_upper")) ?? 20) / 100;
  if (!m) return null;
  const int = (x: number) => Math.round(x).toLocaleString();
  const pc = (x: number, d: number) => (d > 0 ? `${((100 * x) / d).toFixed(1)}%` : "n/a");
  const rowA = m.correct_in + m.incl, rowN = m.excl + m.correct_out;
  const colE = m.correct_in + m.excl, colN = m.incl + m.correct_out;
  const band = (x: number, d: number) => (!(d > 0) ? "na" : x / d <= lower ? "good" : x / d <= upper ? "review" : "bad");
  const na = r.no_nonbenef;
  const cell = (x: number, n: number, d: number, label: string, kind: string, of: string, err = false) => (
    <td className={`sc-cm-cell ${kind}`}>
      <div className="sc-cm-count">{int(x)} <span className={`sc-cm-rate${err ? ` is-${band(x, d)}` : ""}`}>({pc(x, d)})</span></div>
      <div className="sc-cm-label"><span className="sc-cm-dot" />{label}</div>
      <div className="sc-cm-share">{of} · {int(n)} {t("surveyed")}</div>
    </td>
  );
  const blank = (label: string) => (
    <td className="sc-cm-cell"><div className="sc-cm-count">n/a</div><div className="sc-cm-label">{label}</div>
      <div className="sc-cm-share">{t("no non-beneficiaries surveyed")}</div></td>
  );
  return (
    <>
      <table className="sc-cm">
        <thead>
          <tr>
            <th className="sc-cm-corner">{t("Assistance (rows)")}<br />{t("Eligibility from the criteria (columns)")}</th>
            <th>{t("Eligible")}</th>
            <th>{t("Not eligible")}</th>
            <th className="sc-cm-tot">{t("Total")}</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th scope="row">{t("Assisted")}</th>
            {cell(m.correct_in, m.n_correct_in, colE, t("Correctly included"), "ok", t("of the eligible"))}
            {cell(m.incl, m.n_incl, rowA, t("Inclusion error"), "incl", t("of the assisted"), true)}
            <td className="sc-cm-tot">{int(rowA)}</td>
          </tr>
          <tr>
            <th scope="row">{t("Not assisted")}</th>
            {na ? blank(t("Exclusion error")) : cell(m.excl, m.n_excl, colE, t("Exclusion error"), "excl", t("of the eligible"), true)}
            {na ? blank(t("Correctly excluded")) : cell(m.correct_out, m.n_correct_out, colN, t("Correctly excluded"), "ok", t("of the not eligible"))}
            <td className="sc-cm-tot">{na ? "n/a" : int(rowN)}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th scope="row">{t("Total")}</th>
            <td className="sc-cm-tot">{na ? "n/a" : int(colE)}</td>
            <td className="sc-cm-tot">{na ? "n/a" : int(colN)}</td>
            <td className="sc-cm-tot sc-cm-grand">{na ? int(rowA) : int(rowA + rowN)}</td>
          </tr>
        </tfoot>
      </table>
      <div className="small text-muted mt-2">
        {t("Estimated households (weighted: %s).").replace("%s", r.weighting)}{" "}
        {t("Inclusion error = assisted but not eligible / all assisted; exclusion error = eligible but not assisted / all eligible (Targeting Advisory 2/2025). Error rates in brackets, against the tolerance band of %s: green within it, amber to review, red above it.").replace("%s", `${Math.round(100 * lower)}%-${Math.round(100 * upper)}%`)}
        {r.excl_design ? ` ${t("Households excluded by design (eligible, not prioritised): %s surveyed, left out of the table.").replace("%s", int(r.excl_design))}` : ""}
      </div>
    </>
  );
}

/** Decision and coverage by area, at the level the user picks (all levels are
 *  computed with the errors, so the picker only switches between them). */
function AreaTable({ levels, before, t }: { levels: { label: string; rows: Decision[] }[]; before: boolean; t: (s: string) => string }) {
  const [pick, setPick] = useState(0);
  const lv = levels[Math.min(pick, levels.length - 1)];
  const dec = lv.rows;
  const nPause = dec.filter((d) => d.level === "redesign").length, nRev = dec.filter((d) => d.level === "review").length;
  // each error placed on the tolerance band: green within, amber to review, red above
  const lower = (useShinyInputValue<number>(ns("tol_lower")) ?? 5) / 100;
  const upper = (useShinyInputValue<number>(ns("tol_upper")) ?? 20) / 100;
  const err = (x: number | null) => (
    <span className={x === null || x === undefined || !isFinite(x) ? undefined : `tw-mon-err is-${x <= lower ? "good" : x <= upper ? "review" : "bad"}`}>{pc(x)}</span>
  );
  return (
    <Card title={before ? t("Decision and coverage by area, before distribution") : t("Lessons and coverage by area, for the next round")} icon={<SignpostBig size={15} />}>
      <div className="d-flex flex-wrap align-items-center gap-2 mb-2">
        <label className="small fw-semibold mb-0" htmlFor="pdm-area-level">{t("Area level")}</label>
        <select id="pdm-area-level" className="form-select form-select-sm w-auto" value={pick} onChange={(e) => setPick(Number(e.target.value))}>
          {levels.map((l, i) => <option key={l.label} value={i}>{l.label}</option>)}
        </select>
      </div>
      <p className="small mb-2">
        {nPause || nRev
          ? <strong>{nPause} {t("area(s) to")} {before ? t("pause") : t("re-target")}, {nRev} {t("to review.")}</strong>
          : t("No area needs action.")}{" "}
        {t("Each area is judged on its own errors with the same decision table and tolerance band; areas with fewer than 30 surveyed households in either group are not judged.")}
      </p>
      <div className="tw-table-wrap">
        <table className="table table-sm tw-table mb-0">
          <thead><tr>
            <th>{t("Area")}</th><th className="text-end">{t("Selected surveyed")}</th><th className="text-end">{t("Not selected surveyed")}</th>
            <th className="text-end">{t("Eligible (est.)")}</th><th className="text-end">{t("Reached (est.)")}</th><th className="text-end">{t("Coverage")}</th>
            <th className="text-end">{t("Inclusion error")}</th><th className="text-end">{t("Exclusion error")}</th><th>{t("Decision")}</th>
          </tr></thead>
          <tbody>{dec.map((d) => (
            <tr key={d.area}>
              <td className="fw-semibold text-nowrap">{d.area}</td>
              <td className="text-end">{n0(d.n_selected)}</td><td className="text-end">{n0(d.n_not)}</td>
              <td className="text-end">{n0(d.eligible)}</td><td className="text-end">{n0(d.reached)}</td><td className="text-end">{pc(d.coverage)}</td>
              <td className="text-end">{err(d.inclusion)}</td><td className="text-end">{err(d.exclusion)}</td>
              <td style={{ minWidth: 260 }}><span className={`tw-mon-decision lv-${d.level}`}>{d.decision}</span></td>
            </tr>))}
          </tbody>
        </table>
      </div>
    </Card>
  );
}

/** Calibrate the ranking (output$calib_state): a ranking built without an outcome meets one in these data. */
function Calibrate({ t }: { t: (s: string) => string }) {
  const c = useShinyOutputValue<Calib>(ns("calib_state"));
  const ref = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("calib_state"), ref);
  const r = c?.result ?? null;
  const miss = c?.missing ?? [];
  return (
    <div ref={ref} className="tw-mon-calib">
      {!c ? null : c.status === "none"
        ? <EmptyState title={t("No vulnerability ranking loaded")} sub={t("This tab measures the errors of a ranking built without an outcome indicator (Targeting Design, 'No outcome indicator'). Load the selection logic that used it in step 3. A scorecard built on an outcome already has its design errors.")} />
        : c.status === "nodata"
          ? <EmptyState title={t("Load PDM or verification data")} sub={t("Data with a food-security outcome and the ranking's criteria.")} />
          : null}
      {/* the inputs stay mounted: the server fills the level when the outcome changes */}
      <div hidden={c?.status !== "ready"}>
        <Card title={t("Calibrate the ranking")} icon={<SlidersHorizontal size={15} />}>
          <p className="small text-muted mb-2">
            {t("The adopted ranking was built without an outcome, so its inclusion and exclusion errors were unknown. Choose the food-security outcome these data carry (CARI, FCS or rCSI class...) and the level that means vulnerable: the ranking is applied to these households and its errors, its AUC and the threshold that keeps both errors lowest are measured.")}
          </p>
          {miss.length > 0 && (
            <Notice kind="warning" className="mb-2">
              {t("These data lack %d of the ranking's criteria (%s): they cannot be scored.").replace("%d", String(miss.length)).replace("%s", miss.slice(0, 5).join(", "))}
            </Notice>
          )}
          <div className="tw-mon-calib-row">
            <SelectInput id={ns("calib_outcome")} label={t("Outcome in these data")} value="" clearable={false}
                         choices={[{ value: "", label: t("Choose a column") }, ...(c?.cols ?? []).map((x) => ({ value: x, label: x }))]} />
            <SelectInput id={ns("calib_pos")} label={t("Level meaning vulnerable")} choices={[]} value="" clearable={false} />
            <ActionButton id={ns("calib_run")} label={t("Measure the errors")} icon={<Play size={14} />} variant="primary" className="tw-mon-calib-go" />
          </div>
        </Card>
      </div>
      {c?.status === "ready" && r && (
        <>
          <div className="tw-mon-kpis">
            <Kpi label={t("AUC of the ranking")} value={r.auc === null || r.auc === undefined ? "n/a" : r.auc.toFixed(3)} icon={<TrendingUp size={18} />} tone="info" />
            <Kpi label={t("Inclusion error (adopted threshold)")} value={pcNa(r.inclusion)} icon={<UserPlus size={18} />} tone="warning" />
            <Kpi label={t("Exclusion error (adopted threshold)")} value={pcNa(r.exclusion)} icon={<UserMinus size={18} />} tone="danger" />
            <Kpi label={t("Households measured")} value={n0(r.n)} icon={<Users size={18} />} tone="info" />
          </div>
          <div className="small">
            {r.best
              ? t("The threshold that keeps both errors lowest on these data is %1 (inclusion %2, exclusion %3), against %4 adopted. Re-adopt the ranking in Targeting Design with it if the data are representative.")
                  .replace("%1", r.best.threshold).replace("%2", pcNa(r.best.inclusion)).replace("%3", pcNa(r.best.exclusion)).replace("%4", r.threshold)
              : t("No threshold does better than selecting everyone on these data.")}
          </div>
          <div className="small text-muted">
            {t("Outcome")}: {r.outcome} = {r.pos}. {t("An AUC near 0.5 means the ranking does not order households by this outcome: revisit the criteria or the method.")}
          </div>
        </>
      )}
    </div>
  );
}

/** What to do, in order: the sample is drawn in Beneficiary Selection, the survey and the list come back here. */
function HowTo({ t }: { t: (s: string) => string }) {
  return (
    <Card title={t("How to measure the implementation errors")} icon={<SignpostBig size={15} />}>
      <ul className="small mb-0 ps-3">
        <li><strong>{t("Before:")}</strong> {t("in Beneficiary Selection, click Draw a monitoring sample and download the sample list (Excel). Survey those households, keeping the columns household_id, eligibility, sample_area and sample_group_size (preload them in the form), and ask the scorecard's questions and the outcome.")}</li>
        <li><strong>{t("1. Load the survey")}</strong>: {t("the answers collected (file or MODA).")}</li>
        <li><strong>{t("2. Who was selected")}</strong>: {t("nothing to do when the survey kept the sample columns; otherwise upload the sample list as it was downloaded and choose the survey's household ID.")}</li>
        <li><strong>{t("3. Who should have been selected")}</strong>: {t("apply the adopted scorecard or rules to the survey answers.")}</li>
        <li><strong>{t("4. Weighting")}</strong>: {t("keep From the sample design.")}</li>
        <li>{t("Click Compute implementation errors: the errors, the verdict and a decision per area.")}</li>
      </ul>
      <div className="small text-muted mt-2">{t("No sample list? A PDM with a column saying who received assistance works too: choose A column in the survey in step 2 and type the population sizes in step 4.")}</div>
    </Card>
  );
}
