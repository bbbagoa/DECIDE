// Beneficiary Selection (ben_panel), the module ben_selection_1
// (R/mod_ben_selection.R). See PORT.md. The server code is the Shiny page's:
// every input keeps its id and waits for Apply selection (ben_apply); the
// server sends facts as JSON (ben_meta, ben_pending, selection_note,
// comp_insights, ben_profile), charts (render_echart) and the beneficiary
// list (render_react_table, paged on the server above 5,000 rows). The
// dialogs (rules, caseload per area, scorecard crosswalk, export) stay the
// server's; the scorecard file loader, its note and the caseload summary are
// hosted; the variable calculator is components/VarCalc.
import { type ReactNode } from "react";
import {
  ChartBar, CircleCheck, CircleMinus, Download, FileSpreadsheet, FileText, Filter, Info, Layers, List, MapPin,
  SlidersHorizontal, User, Users, UsersRound, Venus, X,
} from "lucide-react";
import { useShinyInputValue, useShinyOutputError, useShinyOutputValue } from "@/shiny";
import {
  ActionButton, CheckboxInput, DownloadButton, HostedUI, NumericInput, RadioInput, SelectInput, SliderInput, TextInput, TextOutput,
} from "@/lib/inputs";
import { Card, Notice, SideActions, SidebarLayout, Steps, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { EmptyState } from "@/components/Figures";
import { VarCalc } from "@/components/VarCalc";
import "./selection.css";

const ns = (id: string) => `ben_selection_1-${id}`;
type T = (s: string) => string;

type Approach = { value: string; label: string; description: string; gates: string[]; list: boolean };
type Meta = {
  ready: boolean; approaches: Approach[];
  card: { word: string; n: number; threshold: number; fp: string } | null;
  ranking: { profiles: boolean } | null;
};
type Note = { label: string; list_produced: boolean; eligible: number; served: number; notes: string[] };
type Insight = { icon: string; label: string; value: string; sub: string };
type ProfileRow = { indicator: string; selected: string; not_selected: string; difference: string; notable: boolean };

const num = (x: number) => Math.round(x).toLocaleString("en-US");
const INSIGHT_ICONS: Record<string, ReactNode> = {
  people: <Users size={14} />, person: <User size={14} />, female: <Venus size={14} />, cut: <CircleMinus size={14} />, area: <MapPin size={14} />,
};

export function SelectionPage({ t }: { active: boolean; t: T }) {
  const meta = useShinyOutputValue<Meta>(ns("ben_meta"));
  const pending = useShinyOutputValue<{ pending: string[] }>(ns("ben_pending"))?.pending ?? [];
  const approach = useShinyInputValue<string>(ns("ben_approach")) ?? "hybrid";
  const a = meta?.approaches.find((x) => x.value === approach);
  const gates = a?.gates ?? ["area", "criteria", "score"];
  const a1 = useShinyInputValue<string[] | string | null>(ns("ben_admin1"));
  const a2 = useShinyInputValue<string[] | string | null>(ns("ben_admin2"));
  const a3 = useShinyInputValue<string[] | string | null>(ns("ben_admin3"));
  const nAreas = [a1, a2, a3].reduce<number>((s, x) => s + (Array.isArray(x) ? x.length : x ? 1 : 0), 0);

  const sidebar = (
    <>
      <Steps steps={[{
        key: "areas", title: `1. ${t("Areas covered")}`, icon: <MapPin size={15} />,
        summary: nAreas ? `${nAreas} ${t("chosen")}` : t("Every area"),
        content: (
          <>
            <p className="small text-muted mb-2">
              {t("Leave empty to cover every area. Households outside the chosen areas are left out of the selection and its reports.")}
            </p>
            <SelectInput id={ns("ben_admin1")} label={t("Admin 1")} multiple actions placeholder={t("All areas")} />
            <SelectInput id={ns("ben_admin2")} label={t("Admin 2")} multiple actions placeholder={t("All areas")} />
            <SelectInput id={ns("ben_admin3")} label={t("Admin 3")} multiple actions placeholder={t("All areas")} />
          </>
        ),
      }]} />
      <SideActions>
        <PendingNote pending={pending} t={t} />
        <div className="d-flex gap-2">
          <ActionButton id={ns("ben_apply")} label={t("Apply selection")} icon={<Filter size={14} />} variant="primary" className="flex-fill" />
          <ActionButton id={ns("ben_clear")} icon={<X size={14} />} variant="outline-secondary" title={t("Clear the selection criteria")} />
        </div>
        <ActionButton id={ns("export_open")} label={t("Export selection (Excel)")} icon={<Download size={14} />} className="w-100 mt-2" />
        <DownloadButton id={ns("selection_report")} label={t("Selection report (HTML)")} icon={<FileText size={14} />} className="w-100 mt-2" />
        <div className="mt-2"><VarCalc ns={ns("calc")} t={t} block /></div>
      </SideActions>
    </>
  );

  return (
    <SidebarLayout width={300} sidebar={sidebar} className="tw-sel">
      <div className="tw-sel-main">
        {meta && !meta.ready && (
          <EmptyState title={t("Load the registration data and map its variables first.")} />
        )}
        <Kpis t={t} />
        <SelectionNote t={t} />
        <Tabs id={ns("ben_tabs")} value="design" tabs={[
          { value: "design", label: t("Selection design"), icon: <SlidersHorizontal size={14} />, content: <Design t={t} meta={meta} gates={gates} approach={a} pending={pending} /> },
          { value: "composition", label: t("Composition"), icon: <ChartBar size={14} />, content: <Composition t={t} meta={meta} /> },
          { value: "list", label: t("Beneficiary list"), icon: <List size={14} />, content: <BenList t={t} /> },
        ]} />
      </div>
    </SidebarLayout>
  );
}

/* ------------------------------------------------------------------ KPIs */

function Kpis({ t }: { t: T }) {
  const kpi = (id: string, label: string, icon: ReactNode, tone: string) => (
    <div className="tw-sel-kpi">
      <span className={`tw-sel-kpi-icon tone-${tone}`}>{icon}</span>
      <div className="min-w-0">
        <div className="tw-sel-kpi-label">{label}</div>
        <div className="tw-sel-kpi-value"><TextOutput id={ns(id)} /></div>
      </div>
    </div>
  );
  return (
    <div className="tw-sel-kpis">
      {kpi("ben_total", t("Selected households"), <Users size={18} />, "primary")}
      {kpi("ben_indiv", t("Selected individuals"), <UsersRound size={18} />, "secondary")}
      {kpi("ben_eligible", t("Eligible by design"), <CircleCheck size={18} />, "info")}
      {kpi("ben_cut", t("Excluded by design"), <CircleMinus size={18} />, "warning")}
    </div>
  );
}

function SelectionNote({ t }: { t: T }) {
  const n = useShinyOutputValue<Note | null>(ns("selection_note"));
  if (!n) return null;
  const cut = n.eligible - n.served;
  return (
    <div className="tw-sel-note">
      <div>
        <strong>{t(n.label)}</strong>{": "}
        {!n.list_produced ? t("no household list is produced.") : (
          <>
            {num(n.eligible)} {t("eligible by design")}
            {n.served < n.eligible && <>, {num(n.served)} {t("prioritised")}, <strong>{num(cut)} {t("excluded by design")}</strong> ({t("unmet need, not an exclusion error")})</>}.
          </>
        )}
      </div>
      {n.list_produced && n.notes.map((x) => <div key={x} className="tw-sel-note-warn">{x}</div>)}
    </div>
  );
}

function PendingNote({ pending, t }: { pending: string[]; t: T }) {
  if (!pending.length) return null;
  return (
    <Notice kind="warning" className="tw-sel-pending">
      {t("Not applied yet")}: {pending.map(t).join(", ")}. {t("Apply the selection to use them.")}
    </Notice>
  );
}

/* ---------------------------------------------------------------- design */

function Design({ t, meta, gates, approach, pending }: { t: T; meta?: Meta; gates: string[]; approach?: Approach; pending: string[] }) {
  const value = approach?.value ?? "hybrid";
  const isSelf = value === "self";
  const mode = useShinyInputValue<string>(ns("ben_prio_mode")) ?? "none";
  const useSc = useShinyInputValue<boolean>(ns("use_scorecard"));
  const card = meta?.card ?? null;
  const cardOn = !!card && useSc !== false;

  const steps: { key: string; title: string; show: boolean; body: ReactNode }[] = [
    {
      key: "approach", title: t("Approach"), show: true, body: (
        <>
          <SelectInput id={ns("ben_approach")} value="hybrid" clearable={false}
                       choices={(meta?.approaches ?? []).map((x) => ({ value: x.value, label: t(x.label) }))} />
          {approach && <p className="small text-muted mb-2">{t(approach.description)}</p>}
          <div hidden={value !== "hybrid"}>
            <RadioInput id={ns("ben_combine")} label={t("Criteria and score combine as")} value="both"
                        choices={[{ value: "both", label: t("Both (criteria AND score)") }, { value: "either", label: t("Either (criteria OR score)") }]} />
          </div>
        </>
      ),
    },
    {
      key: "rules", title: t("Eligibility rules"), show: gates.includes("criteria"), body: (
        <>
          <p className="small text-muted mb-2">{t("Combine conditions on any column, e.g. (A and B) or C.")}</p>
          <ActionButton id={ns("btn_rules")} label={t("Edit eligibility rules")} icon={<SlidersHorizontal size={14} />} />
          <div className="small text-muted mt-2"><TextOutput id={ns("rules_summary")} /></div>
        </>
      ),
    },
    {
      key: "score", title: t("Score"), show: gates.includes("score"), body: (
        <>
          <div hidden={!card}>
            <CheckboxInput key={`use-${card?.fp ?? "none"}`} id={ns("use_scorecard")} value asSwitch
                           label={card ? `${t("Apply the")} ${t(card.word)} (${card.n} ${t("criteria")})` : ""} />
            <div hidden={!cardOn}>
              <NumericInput id={ns("scorecard_threshold")} label={t("Eligible when score is above")}
                            value={card?.threshold ?? null} min={0} step={0.1} />
            </div>
            <HostedUI id={ns("scorecard_note")} />
            <ActionButton id={ns("sc_rematch")} label={t("Match columns")} icon={<Layers size={14} />} className="mt-1" />
          </div>
          {!card && (
            <p className="small text-muted mb-2">
              {t("No scorecard or vulnerability ranking in use. Build one under Targeting Design (with an outcome indicator, or without one for a ranking) and adopt it, or load one exported from there.")}
            </p>
          )}
          <div hidden={cardOn}>
            <SliderInput id={ns("ben_score_min")} label={t("Minimum vulnerability score")} min={0} max={100} value={0} />
            <SliderInput id={ns("ben_score_max")} label={t("Maximum vulnerability score")} min={0} max={100} value={100} />
          </div>
          <HostedUI id={ns("scorecard_ui")} />
        </>
      ),
    },
    {
      key: "community", title: t("Community decision"), show: gates.includes("community"), body: (
        <>
          <SelectInput id={ns("ben_comm_col")} label={t("Column recording the community's decision")} value="" clearable={false}
                       choices={[{ value: "", label: t("Choose a column") }]} />
          <SelectInput id={ns("ben_comm_vals")} label={t("Value(s) meaning selected")} multiple actions />
        </>
      ),
    },
    {
      key: "prio", title: t("Prioritisation"), show: !isSelf, body: (
        <>
          <RadioInput id={ns("ben_prio_mode")} value="none"
                      choices={[{ value: "none", label: t("None: serve all eligible") }, { value: "caseload", label: t("Total caseload") },
                                { value: "per_unit", label: t("Caseload per area") }]} />
          <div hidden={mode === "none"}>
            <RadioInput id={ns("ben_prio_count")} label={t("Caseload counted in")} inline value="people"
                        choices={[{ value: "people", label: t("People (beneficiaries)") }, { value: "households", label: t("Households") }]} />
            <div hidden={mode !== "caseload"}>
              <NumericInput id={ns("ben_prio_n")} label={t("Caseload to serve")} min={1} step={1} />
              <TextInput id={ns("ben_prio_rationale")} label={t("Rationale (required)")} area rows={2}
                         placeholder={t("e.g. Caseload set by the funding available for the first round.")} />
            </div>
            <div hidden={mode !== "per_unit"}>
              <SelectInput id={ns("ben_quota_unit")} label={t("Per")} value="admin1" clearable={false}
                           choices={[{ value: "admin1", label: "Admin 1" }, { value: "admin2", label: "Admin 2" },
                                     { value: "admin3", label: "Admin 3" }, { value: "admin4", label: "Admin 4" }]} />
              <ActionButton id={ns("quota_open")} label={t("Set the caseload per area...")} icon={<FileSpreadsheet size={14} />} className="w-100 mb-2" />
              <HostedUI id={ns("quota_summary")} />
            </div>
            <div className="text-muted small mt-1">
              {t("Most vulnerable first (highest score). Eligible households cut here are excluded by design: reported separately, not counted as exclusion errors.")}
            </div>
          </div>
        </>
      ),
    },
  ];
  let k = 0;
  return (
    <>
      <div className="tw-sel-design">
        {steps.map((s) => (
          // hidden, not unmounted: the server's updates must reach the inputs inside
          <section key={s.key} className="tw-sel-step" hidden={!s.show}>
            <div className="tw-sel-step-head"><span className="tw-sel-step-num">{s.show ? ++k : ""}</span>{s.title}</div>
            {s.body}
          </section>
        ))}
      </div>
      <div className="tw-sel-foot">
        <span className="small text-muted"><Info size={14} /> {pending.length
          ? `${t("Not applied yet")}: ${pending.map(t).join(", ")}.`
          : t("The design and the filters take effect together when you apply the selection.")}</span>
        <button type="button" className="btn btn-outline-primary btn-sm" onClick={() => document.getElementById(ns("ben_apply"))?.click()}>
          <Filter size={14} /> {t("Apply selection")}
        </button>
      </div>
    </>
  );
}

/* ----------------------------------------------------------- composition */

function Composition({ t, meta }: { t: T; meta?: Meta }) {
  const ins = useShinyOutputValue<{ empty: boolean; tiles: Insight[] } | null>(ns("comp_insights"));
  const prof = useShinyOutputValue<{ message?: string; rows?: ProfileRow[] } | null>(ns("ben_profile"));
  const rk = meta?.ranking ?? null;
  const mixNote = useShinyOutputError(ns("ben_validation_plot"))?.message;
  const help = (s: string) => <span className="tw-sel-help" title={t(s)} aria-label={t(s)}><Info size={13} /></span>;
  return (
    <div className="tw-sel-comp">
      {ins?.empty ? <EmptyState title={t("Nobody selected")} sub={t("Apply a selection to see what the list is made of.")} /> : (
        <div className="tw-sel-insights">
          {(ins?.tiles ?? []).map((x) => (
            <div key={x.label} className="tw-sel-insight">
              <div className="tw-sel-insight-label">{INSIGHT_ICONS[x.icon]} {t(x.label)}</div>
              <div className="tw-sel-insight-value">{x.value}</div>
              {x.sub && <div className="tw-sel-insight-sub">{x.sub}</div>}
            </div>
          ))}
        </div>
      )}
      {/* the mix chart needs eligibility or groups mapped: otherwise one line, and the area chart takes the row */}
      {mixNote && <div className="small text-muted"><Info size={13} /> {t(mixNote)}</div>}
      <div className={mixNote ? undefined : "tw-sel-grid2"}>
        <div hidden={!!mixNote}>
          <Card title={t("Eligibility and vulnerability mix")} icon={<ChartBar size={15} />} full><Chart id={ns("ben_validation_plot")} /></Card>
        </div>
        <Card title={t("By area: served, excluded by design, not eligible")} icon={<MapPin size={15} />} full><Chart id={ns("ben_area_plot")} /></Card>
      </div>
      <Card title={t("Who is selected, compared with who is not")} icon={<Users size={15} />} full>
        {!prof ? null : prof.message ? <div className="small text-muted">{t(prof.message)}</div> : (
          <>
            <div className="tw-sel-prof-wrap">
              <table className="table table-sm tw-table tw-sel-prof mb-0">
                <thead><tr><th>{t("Indicator")}</th><th className="text-end">{t("Selected")}</th><th className="text-end">{t("Not selected")}</th><th className="text-end">{t("Difference")}</th></tr></thead>
                <tbody>
                  {(prof.rows ?? []).map((r) => (
                    <tr key={r.indicator}>
                      <td>{r.indicator}</td><td className="text-end">{r.selected}</td><td className="text-end">{r.not_selected}</td>
                      <td className={`text-end${r.notable ? " tw-sel-notable" : ""}`}>{r.difference}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="small text-muted mt-2">
              {t("Means for numbers, shares for categories. Bold: a gap of 10 points or 20% or more, where the selection tells the groups apart.")}
            </div>
          </>
        )}
      </Card>
      {rk && (
        <div className={rk.profiles ? "tw-sel-grid2" : undefined}>
          <Card title={t("Share selected by number of deprivations")} icon={<Layers size={15} />} full
                help={help("Deprivations: the ranking's criteria a household meets in the vulnerable direction. The selection should rise with them.")}>
            <Chart id={ns("rank_dep_plot")} />
          </Card>
          {rk.profiles && (
            <Card title={t("Selected households by ranking profile")} icon={<Users size={15} />} full
                  help={help("Each registration household joins the ranking profile closest to its answers. The targeted profiles (marked) should be selected most.")}>
              <Chart id={ns("rank_prof_plot")} />
            </Card>
          )}
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ list */

function BenList({ t }: { t: T }) {
  return (
    <Card title={t("Selected beneficiaries")} icon={<Users size={15} />} full className="mt-3"
          actions={
            // the same export as the sidebar's (the list plus its metadata)
            <button type="button" className="btn btn-outline-primary btn-sm" onClick={() => document.getElementById(ns("export_open"))?.click()}>
              <FileSpreadsheet size={14} /> {t("Download the list (Excel)")}
            </button>
          }>
      <DataTable id={ns("ben_table")} />
    </Card>
  );
}
