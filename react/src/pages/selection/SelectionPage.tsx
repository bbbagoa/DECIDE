// Beneficiary Selection (ben_panel), the module ben_selection_1
// (R/mod_ben_selection.R). See PORT.md. The server code is the Shiny page's:
// every input keeps its id and waits for Apply selection (ben_apply); the
// server sends facts as JSON (ben_meta, ben_pending, selection_note,
// comp_insights, ben_profile, scorecard_note, quota_summary), charts (render_echart) and the beneficiary
// list (render_react_table, paged on the server above 5,000 rows). The
// dialogs (rules, caseload per area, scorecard crosswalk, export) stay the
// server's; the scorecard file loader is hosted; the variable calculator is
// components/VarCalc.
import { useRef, type ReactNode } from "react";
import {
  CalendarX, ChartBar, CircleAlert, CircleCheck, CircleMinus, Download, FileSpreadsheet, FileText, Filter, Info, Layers, List, MapPin,
  Shuffle, SlidersHorizontal, User, Users, UsersRound, Venus, X,
} from "lucide-react";
import { useShinyInputValue, useShinyOutputError, useShinyOutputValue } from "@/shiny";
import {
  ActionButton, CheckboxInput, DownloadButton, HostedUI, NumericInput, RadioInput, SelectInput, SliderInput, TextInput, TextOutput,
} from "@/lib/inputs";
import { Card, SideActions, SidebarLayout, Steps, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { useOutputVisibility } from "@/lib/visibility";
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
type ScNote = {
  ready: boolean; n: number; unmapped: number; missing: string[]; ranking: boolean; outcome: string;
  stale: { months: number; created: string } | null;
} | null;
type Quota = { set: boolean; total?: number; count?: string; areas?: number; share?: boolean } | null;
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

  // the sidebar: what is covered, then what comes out of the selection
  const sidebar = (
    <>
      <Steps steps={[{
        key: "areas", title: t("Areas covered"), icon: <MapPin size={15} />,
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
        <div className="tw-sel-side-cap">{t("Outputs")}</div>
        <ActionButton id={ns("export_open")} label={t("Export selection (Excel)")} icon={<Download size={14} />} className="w-100" />
        <DownloadButton id={ns("selection_report")} label={t("Selection report (HTML)")} icon={<FileText size={14} />} className="w-100 mt-2" />
        <ActionButton id={ns("mon_open")} label={t("Draw a monitoring sample")} icon={<Shuffle size={14} />} className="w-100 mt-2"
                      title={t("Households to survey for a post-targeting survey / baseline or a PDM, with replacements")} />
        <div className="tw-sel-side-cap mt-3">{t("Tools")}</div>
        <VarCalc ns={ns("calc")} t={t} block />
      </SideActions>
    </>
  );

  return (
    <SidebarLayout width={280} sidebar={sidebar} className="tw-sel">
      <div className="tw-sel-main">
        {meta && !meta.ready && (
          <EmptyState title={t("Load the registration data and map its variables first.")} />
        )}
        <ParamBar t={t} meta={meta} gates={gates} approach={a} pending={pending} />
        <SelectionNote t={t} />
        <Kpis t={t} />
        <Tabs id={ns("ben_tabs")} value="summary" tabs={[
          { value: "summary", label: t("Summary by area"), icon: <MapPin size={14} />, content: <AreaSummary t={t} /> },
          { value: "composition", label: t("Composition"), icon: <ChartBar size={14} />, content: <Composition t={t} meta={meta} /> },
          { value: "list", label: t("Beneficiary list"), icon: <List size={14} />, content: <BenList t={t} /> },
        ]} />
      </div>
    </SidebarLayout>
  );
}

/* ------------------------------------------------------------------ KPIs */

type Fig = { hh: number; people: number | null };
type Figs = { total: Fig; eligible: Fig; served: Fig; cut: Fig } | null;

/** Every figure in households and people (output$ben_figs). Served is shown
 *  as a share of the eligible (coverage of the need) and of all households. */
function Kpis({ t }: { t: T }) {
  const f = useShinyOutputValue<Figs>(ns("ben_figs"));
  // the figures go over the whole selection: they wait while the page is hidden
  const here = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("ben_figs"), here);
  const pct = (a: number, b: number) => (b > 0 ? `${((100 * a) / b).toFixed(1).replace(/\.0$/, "")}%` : "—");
  const kpi = (id: string, label: string, icon: ReactNode, tone: string, x: Fig | undefined, share?: ReactNode) => (
    <div className="tw-sel-kpi">
      <span className={`tw-sel-kpi-icon tone-${tone}`}>{icon}</span>
      <div className="min-w-0">
        <div className="tw-sel-kpi-label">{label}</div>
        <div className="tw-sel-kpi-value"><span id={ns(id)}>{x ? num(x.hh) : "—"}</span> <small>{t("households")}</small></div>
        {x?.people != null && <div className="tw-sel-kpi-people">{num(x.people)} {t("people")}</div>}
        {share && <div className="tw-sel-kpi-share">{share}</div>}
      </div>
    </div>
  );
  return (
    <div className="tw-sel-kpis" ref={here}>
      {kpi("ben_all", t("In the data"), <Layers size={18} />, "secondary", f?.total, t("areas covered"))}
      {kpi("ben_eligible", t("Eligible by design"), <CircleCheck size={18} />, "info", f?.eligible,
           f && `${pct(f.eligible.hh, f.total.hh)} ${t("of all households")}`)}
      {kpi("ben_total", t("Selected (served)"), <Users size={18} />, "primary", f?.served,
           f && <><b>{pct(f.served.hh, f.eligible.hh)}</b> {t("of eligible")} · {pct(f.served.hh, f.total.hh)} {t("of all households")}</>)}
      {kpi("ben_cut", t("Excluded by design"), <CircleMinus size={18} />, "warning", f?.cut,
           f && `${pct(f.cut.hh, f.eligible.hh)} ${t("of eligible (unmet need)")}`)}
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

/* --------------------------------------------------------- settings bar */

/** One group of the bar: a caption, then its fields side by side. Hidden, not
 *  unmounted, so the server's updates reach the inputs inside. */
function Group({ off = false, n, label, children, className, why }: {
  off?: boolean; n: number; label: string; children: ReactNode; className?: string; why?: string;
}) {
  return (
    <section className={`tw-sel-bar-group${off ? " is-off" : ""}${className ? ` ${className}` : ""}`} aria-disabled={off} title={off ? why : undefined}>
      <div className="tw-sel-bar-cap"><span className="tw-sel-step-num">{n}</span>{label}</div>
      <div className="tw-sel-bar-fields" inert={off}>{children}</div>
      {off && <div className="tw-sel-bar-offnote">{why}</div>}
    </section>
  );
}

function ParamBar({ t, meta, gates, approach, pending }: { t: T; meta?: Meta; gates: string[]; approach?: Approach; pending: string[] }) {
  const value = approach?.value ?? "hybrid";
  const isSelf = value === "self";
  const mode = useShinyInputValue<string>(ns("ben_prio_mode")) ?? "none";
  const useSc = useShinyInputValue<boolean>(ns("use_scorecard"));
  const card = meta?.card ?? null;
  const cardOn = !!card && useSc !== false;
  const show = { rules: gates.includes("criteria"), score: gates.includes("score"), community: gates.includes("community"), prio: !isSelf };
  const why = t("Not used by this approach");
  return (
    <div className="tw-sel-bar">
      <div className="tw-sel-bar-row">
        <Group n={1} label={t("Approach")} className="tw-sel-bar-approach">
          <SelectInput id={ns("ben_approach")} value="hybrid" clearable={false}
                       choices={(meta?.approaches ?? []).map((x) => ({ value: x.value, label: t(x.label) }))} />
          <div hidden={value !== "hybrid"} title={t("Both: criteria AND score. Either: criteria OR score.")}>
            <RadioInput id={ns("ben_combine")} value="both" buttons
                        choices={[{ value: "both", label: t("Both") }, { value: "either", label: t("Either") }]} />
          </div>
        </Group>

        <Group off={!show.rules} why={why} n={2} label={t("Eligibility rules")}>
          <ActionButton id={ns("btn_rules")} label={t("Edit rules")} icon={<SlidersHorizontal size={14} />} variant="outline-primary" />
          <span className="tw-sel-bar-sub"><TextOutput id={ns("rules_summary")} /></span>
        </Group>

        <Group off={!show.score} why={why} n={3} label={card ? t(card.word.charAt(0).toUpperCase() + card.word.slice(1)) : t("Vulnerability score")}
               className="tw-sel-bar-score">
          {!card && <div className="tw-sel-bar-sub">{t("No scorecard or ranking in use: adopt one in Targeting Design, or load one below.")}</div>}
          <div hidden={!card} className="tw-sel-bar-card">
            <CheckboxInput key={`use-${card?.fp ?? "none"}`} id={ns("use_scorecard")} value asSwitch
                           label={card ? `${t("Use it")} (${card.n} ${t("criteria")})` : ""} />
            <div hidden={!cardOn}>
              <SliderInput id={ns("scorecard_threshold")} label={t("Eligible when the score is above")}
                           min={0} max={100} step={0.1} value={card?.threshold ?? 0} />
              <div className="tw-sel-bar-agreed">
                <span>{t("Agreed threshold")}: <b>{card?.threshold ?? "—"}</b></span>
                <ActionButton id={ns("sc_rematch")} icon={<Layers size={14} />} variant="outline-secondary" title={t("Match columns")} />
              </div>
            </div>
          </div>
          <div hidden={cardOn} className="tw-sel-bar-range">
            <SliderInput id={ns("ben_score_range")} label={card ? t("Score range") : t("Vulnerability score range")}
                         min={0} max={100} value={[0, 100]} />
          </div>
          <div className="tw-sel-bar-load"><HostedUI id={ns("scorecard_ui")} /></div>
        </Group>

        <Group off={!show.community} why={why} n={4} label={t("Community decision")}>
          <SelectInput id={ns("ben_comm_col")} label={t("Column")} value="" clearable={false}
                       choices={[{ value: "", label: t("Choose a column") }]} />
          <SelectInput id={ns("ben_comm_vals")} label={t("Means selected")} multiple actions />
        </Group>

        <Group off={!show.prio} why={why} n={5} label={t("Prioritisation")} className="tw-sel-bar-prio">
          <RadioInput id={ns("ben_prio_mode")} value="none" buttons
                      choices={[{ value: "none", label: t("All eligible") }, { value: "caseload", label: t("Caseload") },
                                { value: "per_unit", label: t("Per area") }]} />
          {/* counted in (dropdown) and the caseload beside it; the rationale below */}
          <div hidden={mode === "none"} className="tw-sel-bar-caseload">
            <SelectInput id={ns("ben_prio_count")} value="people" clearable={false} className="tw-sel-bar-count"
                         choices={[{ value: "people", label: t("People") }, { value: "households", label: t("Households") }]} />
            <div hidden={mode !== "caseload"} className="tw-sel-bar-n">
              <NumericInput id={ns("ben_prio_n")} placeholder={t("Caseload")} min={1} step={1} />
            </div>
            <div hidden={mode !== "per_unit"} className="tw-sel-bar-n">
              <SelectInput id={ns("ben_quota_unit")} value="admin1" clearable={false}
                           choices={[{ value: "admin1", label: "Admin 1" }, { value: "admin2", label: "Admin 2" },
                                     { value: "admin3", label: "Admin 3" }, { value: "admin4", label: "Admin 4" }]} />
            </div>
          </div>
          <div hidden={mode !== "caseload"}>
            <TextInput id={ns("ben_prio_rationale")} area rows={3} placeholder={t("Rationale (required), e.g. caseload set by the funding available for the first round.")} />
          </div>
          <div hidden={mode !== "per_unit"}>
            <ActionButton id={ns("quota_open")} label={t("Set the caseload per area...")} icon={<FileSpreadsheet size={14} />} variant="outline-primary" />
          </div>
        </Group>
      </div>

      {/* what the settings mean, and what is not applied yet */}
      <div className="tw-sel-bar-foot">
        {approach && <span className="text-muted"><Info size={13} /> {t(approach.description)}</span>}
        {show.score && card && <ScorecardNote t={t} />}
        {show.prio && mode === "per_unit" && <QuotaSummary t={t} />}
        {mode !== "none" && show.prio && (
          <span className="text-muted">{t("Most vulnerable first. Eligible households cut here are excluded by design: reported separately, not counted as exclusion errors.")}</span>)}
        {pending.length > 0 && (
          <span className="tw-sel-bar-pending">{t("Not applied yet")}: {pending.map(t).join(", ")}.</span>)}
        <div className="tw-sel-bar-go">
          <ActionButton id={ns("ben_apply")} label={t("Apply selection")} icon={<Filter size={14} />} variant="primary" />
          <ActionButton id={ns("ben_clear")} icon={<X size={14} />} variant="outline-secondary" title={t("Clear the selection criteria")} />
        </div>
      </div>
    </div>
  );
}

/** Households and people by area, at the level chosen (output$sel_by_area). */
function AreaSummary({ t }: { t: T }) {
  return (
    <Card title={t("Summary by area")} icon={<MapPin size={15} />} full className="mt-3"
          actions={<SelectInput id={ns("sum_level")} clearable={false} className="tw-sel-sumlevel" />}>
      <DataTable id={ns("sel_by_area")} compact />
    </Card>
  );
}

/** How the card fits this dataset (output$scorecard_note). */
function ScorecardNote({ t }: { t: T }) {
  const n = useShinyOutputValue<ScNote>(ns("scorecard_note"));
  if (!n) return null;
  return (
    <div className="tw-sel-scnote">
      {n.ready ? (
        <div className="small text-success"><CircleCheck size={14} />{" "}
          {t("All %d criteria mapped.").replace("%d", String(n.n))}{" "}
          {n.ranking
            ? t("A vulnerability ranking built without an outcome indicator: its errors are not measured; calibrate it in Monitoring (PDM).")
            : <>{t("Outcome")}: {n.outcome}.</>}
        </div>
      ) : (
        <div className="small text-warning"><CircleAlert size={14} />{" "}
          {t("%1 of %2 criteria are not mapped to this dataset (%3). They score nobody.")
            .replace("%1", String(n.unmapped)).replace("%2", String(n.n)).replace("%3", n.missing.join(", "))}
        </div>
      )}
      {n.stale && (
        <div className="small text-warning"><CalendarX size={14} />{" "}
          {t("Designed %1 months ago (%2). The OGN asks for weights to be reviewed every 2-3 years, annually in dynamic contexts.")
            .replace("%1", String(n.stale.months)).replace("%2", n.stale.created)}
        </div>
      )}
    </div>
  );
}

/** The caseload in force for this level (output$quota_summary). */
function QuotaSummary({ t }: { t: T }) {
  const q = useShinyOutputValue<Quota>(ns("quota_summary"));
  if (!q) return null;
  return q.set ? (
    <div className="small text-muted tw-sel-quota"><CircleCheck size={14} className="text-success" />{" "}
      {num(q.total ?? 0)} {t(q.count ?? "households")} {t("in")} {q.areas} {t("areas")} ({q.share ? t("by share of the total") : t("per area")}).
    </div>
  ) : (
    <div className="small text-warning tw-sel-quota"><CircleAlert size={14} /> {t("No caseload set for this level yet.")}</div>
  );
}

/* ----------------------------------------------------------- composition */

function Composition({ t, meta }: { t: T; meta?: Meta }) {
  const ins = useShinyOutputValue<{ empty: boolean; tiles: Insight[] } | null>(ns("comp_insights"));
  const prof = useShinyOutputValue<{ message?: string; rows?: ProfileRow[] } | null>(ns("ben_profile"));
  const rk = meta?.ranking ?? null;
  const mixNote = useShinyOutputError(ns("ben_validation_plot"))?.message;
  const help = (s: string) => <span className="tw-sel-help" title={t(s)} aria-label={t(s)}><Info size={13} /></span>;
  // the insights and the profile go over the data: they wait while this tab is hidden
  const ref = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("comp_insights"), ref);
  useOutputVisibility(ns("ben_profile"), ref);
  return (
    <div className="tw-sel-comp" ref={ref}>
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
      {/* the areas, three ways, on one line */}
      <div className="tw-sel-grid3">
        <Card title={t("Households by area")} icon={<MapPin size={15} />} full
              help={help("Served, excluded by design (eligible but cut by prioritisation) and not eligible, in each area.")}><Chart id={ns("ben_area_plot")} /></Card>
        <Card title={t("Coverage by area")} icon={<ChartBar size={15} />} full
              help={help("Of eligible served: the share of the need covered (100% = every eligible household served). Of all households: the share of the area's population served.")}>
          <Chart id={ns("ben_cov_plot")} />
        </Card>
        <Card title={t("Selected households by sex of the head")} icon={<Venus size={15} />} full><Chart id={ns("ben_sex_plot")} /></Card>
      </div>
      <div hidden={!!mixNote}>
        <Card title={t("Eligibility and vulnerability mix")} icon={<ChartBar size={15} />} full><Chart id={ns("ben_validation_plot")} /></Card>
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
