// Tab 1, implementation errors (R/mod_pdm.R, module monitoring_1-pdm): the
// verification sample drawn from the selection, the survey (or PDM) data,
// who was selected and who was eligible, the weighting, then the errors, the
// verdict, the decision per area, the details and the ranking calibration.
// Facts come from output$pdm_state, pdm_side, pdm_verdict and calib_state;
// the file input is the server's, hosted.
import { useRef, type ReactNode } from "react";
import {
  Calculator, ChartColumn, ClipboardCheck, Download, Info, MapPin, Scale, Shuffle, SignpostBig, SlidersHorizontal, Table,
  Target, Upload, UserCheck, Users, UserMinus, UserPlus, Percent, Play, TrendingUp,
} from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton, NumericInput, RadioInput, SelectInput, type Choice } from "@/lib/inputs";
import { useOutputVisibility } from "@/lib/visibility";
import { VerdictCard, type VerdictFacts } from "@/components/VerdictCard";
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

type Decision = { area: string; n_selected: number; n_not: number; inclusion: number | null; exclusion: number | null; level: string; decision: string };
type PdmState = {
  data: { source: string; rows: number; cols: number } | null;
  sample: { drawn_at: string; n: number; selected: number; not_selected: number; reserve: number; areas: number } | null;
  match: { n: number; of: number } | null;
  results: {
    kind: string; inclusion: number | null; exclusion: number | null; coverage: number | null; precision: number | null; recall: number | null;
    elig_source: string; weighting: string; no_nonbenef: boolean;
    decisions: Decision[] | null;
  } | null;
};

type Side = { benef: { n: number; choices: Choice[] } | null; elig: { kind: "warning" | "note"; text: string } | null };
type Verdict = VerdictFacts & { excl_design: { n: number; share: number | null } | null };
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
  const sizeMode = useShinyInputValue<string>(ns("ptm_size_mode")) ?? "margin";
  const kind = useShinyInputValue<string>(ns("data_kind")) ?? "Baseline";
  const benefSrc = useShinyInputValue<string>(ns("benef_source")) ?? "design";
  const eligSrc = useShinyInputValue<string>(ns("pdm_elig_source")) ?? "column";
  const wMode = useShinyInputValue<string>(ns("pdm_weight_mode")) ?? "design";
  const popScope = useShinyInputValue<string>(ns("pop_scope")) ?? "overall";
  const unit = useShinyInputValue<string>(ns("pdm_unit")) ?? "";
  const r = st?.results ?? null;
  const before = r ? r.kind !== "PDM" : kind !== "PDM";
  const dec = r?.decisions ?? [];
  const nPause = dec.filter((d) => d.level === "redesign").length, nRev = dec.filter((d) => d.level === "review").length;

  const sidebar = (
    <>
      <Steps open="sample" steps={[
        {
          key: "sample", title: t("0. Verification sample"), icon: <Shuffle size={14} />,
          summary: st?.sample ? `${n0(st.sample.n)} ${t("households")}` : t("Not drawn"),
          content: <>
            <p className="small text-muted mb-2">{t("Draw households the targeting selected and households it did not, area by area, from the current selection (Beneficiary Selection). Survey them before any distribution: errors found then can still be corrected.")}</p>
            <SelectInput id={ns("ptm_level")} label={t("Area level")} choices={[]} value="" />
            <RadioInput id={ns("ptm_size_mode")} label={t("Households per group and area")} value="margin" buttons
                        choices={[{ value: "margin", label: t("From a margin of error") }, { value: "fixed", label: t("A fixed number") }]} />
            <div style={show(sizeMode === "margin")}>
              <NumericInput id={ns("ptm_margin")} label={t("Margin of error (%)")} value={10} min={3} max={25} step={1}
                            help={t("For each group of each area, enough households to estimate a share within this margin at 95% confidence (about 96 households at 10%, fewer in small groups).")} />
            </div>
            <div style={show(sizeMode === "fixed")}>
              <NumericInput id={ns("ptm_n")} label={t("Households per group")} value={60} min={10} step={10} />
            </div>
            <div className="tw-grid-2 tw-mon-pair">
              <NumericInput id={ns("ptm_reserve")} label={t("Reserve (%)")} value={10} min={0} max={50} step={5} />
              <NumericInput id={ns("ptm_seed")} label={t("Seed")} value={123} min={1} step={1} />
            </div>
            <div className="small text-muted mb-2">{t("The reserve replaces households who cannot be found.")}</div>
            <div className="d-flex flex-column gap-2">
              <ActionButton id={ns("ptm_draw")} label={t("Draw the sample")} icon={<Shuffle size={14} />} className="w-100" />
              <DownloadButton id={ns("ptm_download")} label={t("Sample list (Excel)")} icon={<Download size={14} />} variant="outline-secondary" className="w-100" />
            </div>
            <div className="tw-mon-status">
              {st?.sample
                ? <span className="ok">{t("Drawn")} {st.sample.drawn_at}: {n0(st.sample.n)} {t("households to survey")} ({n0(st.sample.selected)} {t("selected")}, {n0(st.sample.not_selected)} {t("not selected")}) {t("and")} {n0(st.sample.reserve)} {t("in reserve")}, {st.sample.areas} {t("area(s).")}</span>
                : t("No sample drawn yet.")}
            </div>
          </>,
        },
        {
          key: "data", title: t("1. Survey data"), icon: <Upload size={14} />,
          summary: st?.data ? st.data.source : t("Nothing loaded"),
          content: <>
            <RadioInput id={ns("data_kind")} value="Baseline" choices={[
              { value: "Baseline", label: t("Post-targeting survey / baseline (before distribution, recommended)") },
              { value: "PDM", label: t("PDM (after distribution, least preferred)") }]} />
            {kind === "PDM"
              ? <Notice kind="warning" className="mb-2">{t("The least preferred option: after distribution nothing can be undone, vulnerability may have changed, and the assistance itself may have changed the answers to some criteria (assets bought, debts paid). Use it when no survey could be done before distribution.")}</Notice>
              : <p className="small text-muted mb-2">{t("A survey of selected and non-selected households after the selection and before the distribution (the sample drawn in step 0): problems in an area can still be fixed, or its distribution paused.")}</p>}
            <Dropzone id={ns("pdm_file_ui")} />
            <ModaImport ns={ns("moda")} size="sm" t={t} />
            <ModaRefresh ns={ns("moda_refresh")} block className="mt-2" t={t} />
            <DataSummary ns={ns("summary")} block className="mt-2" t={t} />
            {st?.data && (
              <div className="tw-mon-status">
                <span className="ok"><strong>{st.data.source}</strong></span><br />
                {n0(st.data.rows)} {t("records")}, {n0(st.data.cols)} {t("variables. Continue with the steps below.")}
              </div>
            )}
          </>,
        },
        { key: "areas", title: t("Areas covered"), icon: <MapPin size={14} />, content: <AreaScope ns={ns("scope")} title={null} t={t} /> },
        {
          key: "benef", title: t("2. Selected or assisted households"), icon: <UserCheck size={14} />,
          summary: benefSrc === "design" ? t("From the sample list") : t("A column"),
          content: <>
            <RadioInput id={ns("benef_source")} value="design" choices={[
              { value: "design", label: t("From the sample list (match the household ID)") }, { value: "column", label: t("A column in the data") }]} />
            <div style={show(benefSrc === "design")}>
              <SelectInput id={ns("ptm_id")} label={t("Household ID in the survey")} choices={[]} value="" />
              {!st?.sample
                ? <div className="small text-warning mb-2">{t("Draw the sample in step 0 first, or use a column in the data.")}</div>
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
            </div>
            <SelectInput id={ns("pdm_prioritized")} label={t("Prioritised column (optional)")} choices={[]} value=""
                         help={t("Eligible households not prioritised for lack of resources are excluded by design, not exclusion errors.")} />
            <SelectInput id={ns("pdm_unit")} label={t("Area column (optional)")} choices={[]} value="" />
          </>,
        },
        {
          key: "elig", title: t("3. Who was eligible"), icon: <ClipboardCheck size={14} />,
          summary: { column: t("A column"), scorecard: t("The adopted scorecard"), rules: t("The eligibility rules") }[eligSrc],
          content: <>
            <RadioInput id={ns("pdm_elig_source")} value="column" choices={[
              { value: "column", label: t("A column in the data") }, { value: "scorecard", label: t("Apply the adopted scorecard") },
              { value: "rules", label: t("Apply the eligibility rules") }]} />
            <div style={show(eligSrc === "column")}>
              <SelectInput id={ns("pdm_eligibility")} label={t("Eligibility column")} choices={[]} value="" />
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
      ]} />
      <SideActions>
        <div className="small fw-semibold" ref={here}>{t("5. Compute")}</div>
        <ActionButton id={ns("pdm_run")} label={t("Compute implementation errors")} icon={<Calculator size={14} />} variant="primary" className="w-100" />
        <DownloadButton id={ns("pdm_download")} label={t("Export (Excel)")} icon={<Download size={14} />} variant="outline-secondary" className="w-100" />
        <div className="small text-muted d-flex gap-1"><Info size={14} className="flex-shrink-0 mt-1" />
          <span>{t("Implementation errors measure whether the criteria were applied correctly on the ground, not whether they were right (that is the design error).")}</span></div>
      </SideActions>
    </>
  );

  const perUnit = wMode === "population" && popScope === "unit";
  return (
    <SidebarLayout width={330} sidebar={sidebar}>
      {perUnit && (!unit || unit === "(none)"
        ? <Notice kind="warning">{t("Choose the area column (step 2) to give the population sizes per area.")}</Notice>
        : <Card title={t("Population sizes per area")} icon={<Users size={15} />}>
            <p className="small text-muted mb-2">{t("Double-click a cell of the last two columns to type the number of beneficiary and non-beneficiary households in each area.")}</p>
            <DataTable id={ns("pop_table")} searchable={false} compact />
          </Card>)}
      {!st?.data
        ? <EmptyState title={t("No survey data loaded")} sub={t("Draw the verification sample (step 0), survey it before distribution, then load the survey in step 1 and set up steps 2 to 4. A PDM extract can be loaded instead.")} />
        : !r && <EmptyState title={t("Ready to compute")} sub={t("Check steps 2 to 4, then click Compute implementation errors.")} />}
      <Tabs id={ns("pdm_tabs")} tabs={[
        {
          value: "errors", label: t("Errors and verdict"), icon: <Target size={14} />,
          content: <>
            {r && <>
              <div className="tw-mon-kpis">
                <Kpi label={t("Implementation inclusion error")} value={pc(r.inclusion)} icon={<UserPlus size={18} />} tone="danger" />
                <Kpi label={t("Implementation exclusion error")} value={pc(r.exclusion)} icon={<UserMinus size={18} />} tone="warning" />
                <Kpi label={t("Coverage rate")} value={pc(r.coverage)} icon={<Percent size={18} />} tone="success" />
                <Kpi label={t("Precision / Recall")} value={`${pc(r.precision)} / ${pc(r.recall)}`} icon={<Target size={18} />} tone="info" />
              </div>
              <Notice>
                {t("Eligibility from")} {r.elig_source}; {t("weighting")}: {r.weighting}.
                {r.no_nonbenef && <strong> {t("Only beneficiaries were surveyed: the exclusion error cannot be measured.")}</strong>}
              </Notice>
            </>}
            {dec.length > 0 && (
              <Card title={before ? t("Decision by area, before distribution") : t("Lessons by area, for the next round")} icon={<SignpostBig size={15} />}>
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
                      <th className="text-end">{t("Inclusion error")}</th><th className="text-end">{t("Exclusion error")}</th><th>{t("Decision")}</th>
                    </tr></thead>
                    <tbody>{dec.map((d) => (
                      <tr key={d.area}>
                        <td className="fw-semibold">{d.area}</td>
                        <td className="text-end">{n0(d.n_selected)}</td><td className="text-end">{n0(d.n_not)}</td>
                        <td className="text-end">{pc(d.inclusion)}</td><td className="text-end">{pc(d.exclusion)}</td>
                        <td><span className={`tw-mon-decision lv-${d.level}`}>{d.decision}</span></td>
                      </tr>))}
                    </tbody>
                  </table>
                </div>
              </Card>
            )}
            {st?.data && (
              <div className="tw-mon-tol">
                <NumericInput id={ns("tol_lower")} label={t("Lower error tolerance (%)")} value={5} min={0} max={49} step={1} />
                <NumericInput id={ns("tol_upper")} label={t("Upper error tolerance (%)")} value={20} min={1} max={49} step={1} />
              </div>
            )}
            <PdmVerdict t={t} />
          </>,
        },
        {
          value: "details", label: t("Details by group and area"), icon: <Table size={14} />,
          content: <>
            {!r && <EmptyState title={t("Nothing computed yet")} sub={t("Set up the steps on the left, then compute.")} />}
            <div className="tw-grid-2" style={show(!!r)}>
              <Card title={t("Eligibility vs. assistance received (estimated households)")} full>
                <DataTable id={ns("pdm_confusion")} searchable={false} />
              </Card>
              <Card title={t("Error decomposition")} full><Chart id={ns("pdm_plot")} height={300} /></Card>
            </div>
            <div style={show(!!r)}>
              <Card title={t("Coverage by area")} full><DataTable id={ns("pdm_by_unit")} /></Card>
            </div>
          </>,
        },
        { value: "calibrate", label: t("Calibrate the ranking"), icon: <SlidersHorizontal size={14} />, content: <Calibrate t={t} /> },
        { value: "explore", label: t("Explore the data"), icon: <ChartColumn size={14} />, content: <ChartBuilder prefix="monitoring_1-pdm_charts-" t={t} /> },
      ]} />
    </SidebarLayout>
  );
}

/** The verdict on the implementation errors (output$pdm_verdict), with the households excluded by design. */
function PdmVerdict({ t }: { t: (s: string) => string }) {
  const v = useShinyOutputValue<Verdict | null>(ns("pdm_verdict"));
  const ref = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("pdm_verdict"), ref);
  const lo = v && typeof v.lower === "number" ? Math.round(100 * v.lower) : 5, up = v && typeof v.upper === "number" ? Math.round(100 * v.upper) : 20;
  return (
    <div ref={ref} className="tw-mon-verdict">
      {v && (
        <VerdictCard v={v} t={t}>
          <div className="small mt-2 text-muted">
            {t("Implementation errors, judged against a %s band.").replace("%s", `${lo}%-${up}%`)}{" "}
            {t("These measure whether the criteria were applied correctly on the ground, not whether the criteria themselves were right: that is the design error on the Targeting Design tab.")}
          </div>
          {v.excl_design && (
            <div className="small mt-2">
              <strong>{t("Excluded by design")}: {n0(v.excl_design.n)} {t("households")} ({pc(v.excl_design.share)} {t("of eligible")}).</strong>{" "}
              {t("Eligible but not prioritised for lack of resources: unmet need, left out of the exclusion error.")}
            </div>
          )}
        </VerdictCard>
      )}
    </div>
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
        ? <EmptyState title={t("No vulnerability ranking adopted")} sub={t("This tab measures the errors of a ranking built without an outcome indicator (Targeting Design, 'No outcome indicator'). A scorecard built on an outcome already has its design errors.")} />
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
