// Step 1, the vulnerability framework: a food-security outcome and its
// vulnerable level, a welfare measure and its poverty line (PMT), or no
// outcome (a ranking). Nothing counts before Validate (fw_applied() /
// pmt_applied() on the server).
import { Banknote, Check, CircleAlert, CircleCheck, CircleX, Compass, MapPin, TriangleAlert } from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, NumericInput, RadioInput, SelectInput, TextInput } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { ChartHelp, Pending, Show, StepNav, Tip, int, ns, type T } from "./shared";
import type { Flow, Framework, Meta, Mode } from "./types";

const MODES = (t: T) => [
  { value: "outcome", label: t("Food-security outcome indicator") },
  { value: "pmt", label: t("Welfare measure: proxy means test (PMT)") },
  { value: "none", label: t("No outcome indicator: vulnerability ranking") },
];

export function StepFramework({ flow, meta, mode, t }: { flow?: Flow; meta?: Meta; mode: Mode; t: T }) {
  const fw = useShinyOutputValue<Framework>(ns("sc_framework"));
  const unit = useShinyInputValue<string>(ns("pmt_unit")) ?? "hh";
  const lineMode = useShinyInputValue<string>(ns("pmt_line_mode")) ?? "value";
  const fwNote = flow?.fw_note ?? "validate";
  const note = (kind: string, changed: string) => (
    <>
      <Pending show={kind === "validate"}><CircleAlert size={14} /> {t("Click Validate: the design starts from there.")}</Pending>
      <Pending show={kind === "stale"}><TriangleAlert size={14} /> {t(changed)}</Pending>
    </>
  );
  return (
    <div className="sc-step">
      <RadioInput id={ns("framework_mode")} choices={MODES(t)} value="outcome" buttons className="sc-modes" size="md" />

      {/* no outcome: a ranking */}
      <Show when={mode === "none"}>
        <Card title={t("Targeting without an outcome indicator")} icon={<Compass size={15} />}>
          <p className="small mb-2">
            {t("When no food-security assessment is available (a sudden shock, data from a partner, a registry), households are ranked on the criteria you choose instead of predicting an outcome: deprivation counting, a PCA or MCA index, or household profiles from clustering. The criteria are not tested (there is nothing to test them against) and no inclusion or exclusion error can be measured: the design reports internal consistency and the stability of the selection instead.")}
          </p>
          <p className="small text-muted mb-3">{t("Plan a small verification sample (a light food-security module) or use the PDM to measure the errors later.")}</p>
          <div className="sc-row">
            <TextInput id={ns("rank_label")} label={t("What the ranking stands for")} placeholder={t("e.g. Economic vulnerability after the floods")} className="sc-grow" />
            <ActionButton id={ns("fw_validate_none")} label={t("Validate")} icon={<Check size={14} />} variant="primary" size="md" className="sc-row-btn" />
          </div>
          {mode === "none" ? note(fwNote, "") : null}
        </Card>
      </Show>

      {/* a food-security outcome */}
      <Show when={mode === "outcome"}>
        <p className="sc-lead">{t("Pick the food-security outcome the scorecard should predict, and which of its two levels means a vulnerable household.")}</p>
        <div className="sc-row">
          <SelectInput id={ns("outcome_col")} label={t("Outcome variable")} className="sc-grow" clearable={false} />
          <SelectInput id={ns("outcome_pos")} label={t("Level meaning 'vulnerable'")} className="sc-grow" clearable={false} />
          <ActionButton id={ns("fw_validate")} label={t("Validate")} icon={<Check size={14} />} variant="primary" size="md" className="sc-row-btn" />
        </div>
        {mode === "outcome" ? note(fwNote, "The outcome changed since it was validated: Validate again to apply it.") : null}
        {fw?.outcome ? <OutcomeSummary o={fw.outcome} t={t} /> : null}
      </Show>

      {/* a welfare measure: proxy means test */}
      <Show when={mode === "pmt"}>
        <PmtIntro t={t} />
        <div className="sc-row sc-pmt-setup">
          <SelectInput id={ns("pmt_welfare")} className="sc-grow-2" clearable={false}
                       label={<>{t("Welfare variable")} <Tip>{t("Total consumption or expenditure (food and non-food) per household or per person, over one period. It is what the PMT predicts, never a criterion.")}</Tip></>} />
          <SelectInput id={ns("pmt_unit")} label={t("Measured")} value="hh" clearable={false} className="sc-grow"
                       choices={[{ value: "hh", label: t("Per household") }, { value: "pc", label: t("Per person") }]} />
          <Show when={unit === "hh"} className="sc-grow-15">
            <SelectInput id={ns("pmt_size")} clearable={false}
                         label={<>{t("Household size")} <Tip>{t("Divides household welfare into welfare per person, which is compared with the line.")}</Tip></>} />
          </Show>
          <SelectInput id={ns("pmt_line_mode")} value="value" clearable={false} className="sc-grow-13"
                       label={<>{t("Poverty line")} <Tip>{t("A poverty line or the MEB per person, in the welfare's unit and period. Without one, the welfare below which a chosen share of households falls (relative targeting).")}</Tip></>}
                       choices={[{ value: "value", label: t("A line per person") }, { value: "share", label: t("The poorest share") }]} />
          <Show when={lineMode === "value"} className="sc-grow">
            <NumericInput id={ns("pmt_line")} label={t("Line per person")} min={0} />
          </Show>
          <Show when={lineMode === "share"} className="sc-grow">
            <NumericInput id={ns("pmt_share")} label={t("Share below it (%)")} value={30} min={5} max={90} step={5} />
          </Show>
          <ActionButton id={ns("pmt_validate")} label={t("Validate")} icon={<Check size={14} />} variant="primary" size="md" className="sc-row-btn" />
        </div>
        {mode === "pmt" ? (
          <>
            <Pending show={flow?.pmt_note === "validate"}><CircleAlert size={14} /> {t("Set the welfare variable and the poverty line, then Validate: the analysis starts from there.")}</Pending>
            <Pending show={flow?.pmt_note === "stale"}><TriangleAlert size={14} /> {t("The setup changed since it was validated: Validate again to apply it.")}</Pending>
          </>
        ) : null}
        {fw?.pmt ? <PmtSummary p={fw.pmt} t={t} /> : null}
      </Show>

      {/* where the vulnerable households are */}
      <Show when={mode !== "none"}>
        <Card full title={mode === "pmt" ? t("Poor households by area") : t("Vulnerable households by area")} icon={<MapPin size={15} />}
              help={<ChartHelp id="vuln_area_plot" meta={meta} t={t} />}
              actions={<div className="sc-card-select"><SelectInput id={ns("vuln_area")} choices={[{ value: "", label: t("(none)") }]} value="" placeholder={t("Area column")} clearable={false} /></div>}>
          <Chart id={ns("vuln_area_plot")} height={380} />
        </Card>
      </Show>

      <StepNav nav={flow?.nav.outcome} next="nav_next_outcome" nextLabel={t("Continue to Criteria")} t={t} />
    </div>
  );
}

function OutcomeSummary({ o, t }: { o: NonNullable<Framework["outcome"]>; t: T }) {
  if (!o.n) return <div className="tw-notice tw-notice-danger mt-2">{t("This outcome has no usable values.")}</div>;
  const p = o.pct ?? 0;
  return (
    <>
      <div className="sc-kpis sc-kpis-3">
        <Kpi label={t("Households with an outcome")} value={int(o.n)} />
        <Kpi label={`${t("Vulnerable")} (${o.opos})`} value={`${p.toFixed(1)}%`} tone="danger" share={p / 100} />
        <Kpi label={t("Not vulnerable")} value={`${(100 - p).toFixed(1)}%`} tone="success" share={1 - p / 100} />
      </div>
      {p > 95 || p < 5 ? (
        <div className="tw-notice tw-notice-warning mt-2"><TriangleAlert size={15} />
          <div>{t("Only %s of households fall on one side of this outcome.").replace("%s", `${Math.min(p, 100 - p).toFixed(1)}%`)}{" "}
            {t("A scorecard built on such an unbalanced outcome will separate very little. Check the level you selected is the one that means vulnerable.")}</div>
        </div>
      ) : null}
    </>
  );
}

/** A figure: label, value, and a thin bar when it is a share */
export function Kpi({ label, value, tone, share, sub, children }: {
  label: React.ReactNode; value: React.ReactNode; tone?: "danger" | "success" | "info" | "primary"; share?: number; sub?: React.ReactNode; children?: React.ReactNode;
}) {
  return (
    <div className={`sc-kpi${tone ? " is-" + tone : ""}`}>
      <div className="sc-kpi-label">{label}</div>
      <div className="sc-kpi-value">{value}</div>
      {typeof share === "number" ? <div className="sc-kpi-bar"><span style={{ width: `${Math.max(0, Math.min(1, share)) * 100}%` }} /></div> : null}
      {sub ? <div className="sc-kpi-sub">{sub}</div> : null}
      {children}
    </div>
  );
}

function PmtSummary({ p, t }: { p: NonNullable<Framework["pmt"]>; t: T }) {
  const icon = { ok: <CircleCheck size={15} className="text-success" />, warn: <TriangleAlert size={15} className="text-warning" />, fail: <CircleX size={15} className="text-danger" /> };
  return (
    <>
      <div className="sc-kpis sc-kpis-4">
        <Kpi label={t("Households with welfare")} value={int(p.n)} />
        <Kpi label={t("Median welfare per person")} value={p.median} tone="info" />
        <Kpi label={t("Poverty line per person")} value={p.line} />
        <Kpi label={t("Poor (at or below the line)")} value={`${p.poor.toFixed(1)}%`} tone="danger" share={p.poor / 100} />
      </div>
      <div className="sc-subhead">{t("Data requirements")}</div>
      <div className="wfp-model-table-wrap">
        <table className="wfp-model-table sc-req">
          <tbody>
            {p.requirements.map((r, i) => (
              <tr key={i}><td style={{ width: 28 }}>{icon[r.status] ?? null}</td><td><strong>{t(r.check)}</strong></td><td className="small">{r.detail}</td></tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

function PmtIntro({ t }: { t: T }) {
  return (
    <Card title={t("Proxy means test: predicting welfare")} icon={<Banknote size={15} />} className="mb-1">
      <p className="small mb-2">
        {t("A proxy means test (PMT) predicts each household's welfare, its consumption or expenditure per person, from characteristics a registration team can observe and verify: dwelling, assets, household composition, education and work of the head. A household is eligible when its predicted welfare is at or below a poverty line. It needs a survey that measured welfare: a household budget or living-standards survey (HIES, LSMS) or an assessment with a full expenditure module.")}
      </p>
      <details className="small sc-details">
        <summary><strong>{t("Data requirements and guidance")}</strong></summary>
        <ul className="mt-2 mb-2">
          <li><strong>{t("Welfare aggregate:")}</strong> {t("total consumption or expenditure, food and non-food, over one recall period, per household or per person (the World Bank's standard is consumption per person or per adult equivalent).")}</li>
          <li><strong>{t("Sample:")}</strong> {t("several thousand households (a household budget survey), representative of the population to be targeted; at least 10 to 20 households per proxy. Re-estimate when a new survey arrives (every 3 to 5 years, sooner after a shock).")}</li>
          <li><strong>{t("Proxies:")}</strong> {t("observable and verifiable at registration, hard to manipulate, and not the welfare measure itself (no expenditure, income or coping answers). Typical: household size and composition, dwelling materials, water and sanitation, assets, land and livestock, education and occupation of the head, location.")}</li>
          <li><strong>{t("Poverty line:")}</strong> {t("a national line or the MEB per person, in the welfare's unit and period; or the share of households the programme can serve (relative targeting).")}</li>
        </ul>
        <div className="fw-bold mt-2">{t("References")}</div>
        <ul className="mt-1 mb-0">
          <li>World Bank: Grosh &amp; Baker (1995), <em>Proxy Means Tests for Targeting Social Programs</em>, LSMS Working Paper 118; Grosh, del Ninno, Tesliuc &amp; Ouerghi (2008), <em>For Protection and Promotion</em>, ch. 4; Del Ninno &amp; Mills (2015), <em>Safety Nets in Africa</em>.</li>
          <li>{t("Accuracy:")} Brown, Ravallion &amp; van de Walle (2018), A poor means test?, <em>Journal of Development Economics</em> 134: {t("exclusion errors of 40-60% are common at typical coverage; a quantile regression at the poverty rate or a cut-off above the line lowers them.")}</li>
          <li>{t("Safeguards:")} Kidd, Gelders &amp; Bailey-Athias (2017), <em>Exclusion by Design</em>, ILO / Development Pathways: {t("validate on households the model never saw, explain the formula, pair it with community validation and a grievance mechanism.")}</li>
          <li>{t("Humanitarian practice: UNHCR-WFP Joint Programme Excellence and Targeting Hub, and the WFP Targeting OGN (2021): econometric eligibility models where expenditure data exist (for example Lebanon's VASyR and Jordan's refugee assistance), recalibrated with each survey.")}</li>
        </ul>
      </details>
    </Card>
  );
}
