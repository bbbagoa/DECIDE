// Spot Checking (spot_panel), module "spot_checking_1" (R/mod_spot_checking.R).
// Draw a sample of households to re-visit, then compare what the team
// re-collected with the first round. The server code is the Shiny page's:
// every input and output keeps its id; the facts the Shiny page wrote with
// textOutput() / renderUI() come as JSON (sc_kpis, verif_state).
import { useEffect, useRef, type ReactNode } from "react";
import {
  ArrowRight, CircleCheck, ClipboardCheck, CloudDownload, Database, Download, FileSpreadsheet, FileText, Filter, GitCompare,
  Link2, ListChecks, ListOrdered, MapPin, PieChart, Search, Shuffle, TriangleAlert, CircleHelp, X,
} from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import {
  ActionButton, DownloadButton, HostedUI, NumericInput, RadioInput, SelectInput, TextInput,
} from "@/lib/inputs";
import { Card, Notice, SideActions, SidebarLayout, Steps, Tabs, signalShown } from "@/lib/layout";
import { DataTable } from "@/lib/table";
import { Chart } from "@/lib/chart";
import { EmptyState } from "@/components/Figures";
import "./spot.css";

const ns = (id: string) => `spot_checking_1-${id}`;
type T = (s: string) => string;

type Kpis = {
  pool: string | null; share: string | null; sample: string | null; agreement: string | null;
  remote: boolean; phone_col: string; in_scope: string | null; reachable: string | null;
};
type VerifState = {
  loaded: boolean; n: string; source: string; shared: number; compared: boolean;
  kpis: null | { matched: string; agreement: string; discordant: string; unmatched: string; only_original: string;
                 only_verification: string; fields: number; key: string };
};

export function SpotPage({ active, t }: { active: boolean; t: T }) {
  // the page is mounted hidden: when it shows, Shiny looks again at what is
  // visible (downloads get their link, hosted outputs render)
  const root = useRef<HTMLDivElement>(null);
  useEffect(() => { if (active) signalShown(root.current, true); }, [active]);
  const k = useShinyOutputValue<Kpis>(ns("sc_kpis"));
  const a1 = useShinyInputValue<string[] | null>(ns("sc_admin1"));
  const a2 = useShinyInputValue<string[] | null>(ns("sc_admin2"));
  const a3 = useShinyInputValue<string[] | null>(ns("sc_admin3"));
  const q = useShinyInputValue<string>(ns("sc_search"));
  const areas = [a1, a2, a3].flatMap((x) => x ?? []);

  const sidebar = (
    <>
      <Steps steps={[
        {
          key: "areas", title: t("1. Areas"), icon: <MapPin size={15} />,
          summary: areas.length ? areas.slice(0, 3).join(", ") + (areas.length > 3 ? ` +${areas.length - 3}` : "") : t("All areas"),
          content: <>
            <SelectInput id={ns("sc_admin1")} label={t("Admin 1")} multiple actions placeholder={t("All")} />
            <SelectInput id={ns("sc_admin2")} label={t("Admin 2")} multiple actions placeholder={t("All")} />
            <SelectInput id={ns("sc_admin3")} label={t("Admin 3")} multiple actions placeholder={t("All")} />
          </>,
        },
        {
          key: "search", title: t("2. Search"), icon: <Search size={15} />, summary: q ? `"${q}"` : t("None"),
          content: <TextInput id={ns("sc_search")} placeholder={t("e.g. household ID")} help={t("Keeps the households where any column holds this text.")} />,
        },
      ]} />
      <SideActions>
        <div className="d-flex gap-2">
          <ActionButton id={ns("sc_apply")} label={t("Apply")} icon={<Filter size={14} />} className="flex-fill" />
          <ActionButton id={ns("sc_clear")} icon={<X size={14} />} variant="outline-secondary" title={t("Clear the filters")} />
        </div>
        <div className="tw-spot-group">{t("Back-check results")}</div>
        <DownloadButton id={ns("verif_report")} label={t("Verification report (HTML)")} icon={<FileText size={14} />} className="w-100" />
        <DownloadButton id={ns("verif_download")} label={t("Comparison (Excel)")} icon={<FileSpreadsheet size={14} />} variant="outline-secondary" className="w-100" />
      </SideActions>
    </>
  );

  return (
    <div ref={root} className="h-100">
    <SidebarLayout sidebar={sidebar} className="tw-spot">
      <div className="tw-spot-kpis">
        <Kpi icon={<Database size={16} />} label={t("Households in scope")} value={k?.pool} sub={k?.remote ? t("with a valid phone number") : t("after the area and search filters")} />
        <Kpi icon={<PieChart size={16} />} label={t("Share sampled")} value={k?.share} tone="info" />
        <Kpi icon={<ListOrdered size={16} />} label={t("Sample size")} value={k?.sample} tone="neutral" sub={k?.sample ? undefined : t("Draw the spot-check sample first.")} />
        <Kpi icon={<CircleCheck size={16} />} label={t("Back-check agreement")} value={k?.agreement} tone="success" sub={k?.agreement ? undefined : t("after the comparison")} />
      </div>

      {k?.remote && (k.phone_col
        ? <Notice>{t("Remote check")}: {k.reachable ?? "?"} {t("of")} {k.in_scope ?? "?"} {t("households in scope have a valid phone number in")} <b>{k.phone_col}</b>.</Notice>
        : <Notice kind="warning">{t("Remote check: choose the column holding the phone numbers, then draw the sample.")}</Notice>)}

      <Tabs id={ns("sc_tabs")} tabs={[
        { value: "sample", label: t("1. Sample for checking"), icon: <ListChecks size={15} />, content: <SampleTab t={t} /> },
        { value: "verify", label: t("2. Verification"), icon: <ClipboardCheck size={15} />, content: <VerifyTab t={t} /> },
      ]} />
    </SidebarLayout>
    </div>
  );
}

function Kpi({ icon, label, value, sub, tone = "primary" }: { icon: ReactNode; label: string; value?: string | null; sub?: string; tone?: string }) {
  return (
    <div className={`tw-spot-kpi tone-${tone}`}>
      <span className="tw-spot-kpi-icon">{icon}</span>
      <div className="min-w-0">
        <div className="tw-spot-kpi-label">{label}</div>
        <div className="tw-spot-kpi-value">{value ?? "—"}</div>
        {sub ? <div className="tw-spot-kpi-sub">{sub}</div> : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------ 1. sample */

function SampleTab({ t }: { t: T }) {
  const mode = useShinyInputValue<string>(ns("sc_mode")) ?? "face";
  return (
    <>
      <div className="tw-spot-band">
        <RadioInput id={ns("sc_mode")} label={t("Interview mode")} buttons value="face"
                    choices={[{ value: "face", label: t("Face to face") }, { value: "remote", label: t("Remote (phone)") }]} />
        {/* kept mounted: the server fills its choices when the data arrives */}
        <div style={{ display: mode === "remote" ? undefined : "none" }} className="tw-spot-band-wide">
          <SelectInput id={ns("sc_phone_col")} label={t("Phone column")} clearable={false}
                       help={t("Only households with a valid phone number are sampled.")} />
        </div>
        <NumericInput id={ns("sc_sample_size")} label={t("Sample size")} value={30} min={1} max={100000} step={1} className="tw-spot-band-num" />
        <SelectInput id={ns("sc_per_unit")} label={t("Applies to")} value="all" clearable={false} className="tw-spot-band-wide"
                     choices={[{ value: "all", label: t("The whole scope") }, { value: "admin1", label: t("Each Admin 1") },
                               { value: "admin2", label: t("Each Admin 2") }, { value: "admin3", label: t("Each Admin 3") },
                               { value: "village", label: t("Each village") }]} />
        <SelectInput id={ns("sc_sample_method")} label={t("Method")} value="random" clearable={false} className="tw-spot-band-wide"
                     choices={[{ value: "random", label: t("Simple Random") }, { value: "systematic", label: t("Systematic") },
                               { value: "pps", label: t("PPS (size = hh size or weight)") }]} />
        <NumericInput id={ns("sc_seed")} label={t("Seed")} value={12345} min={1} step={1} className="tw-spot-band-num" />
        <div className="tw-spot-band-go">
          <ActionButton id={ns("sc_draw")} label={t("Draw sample")} icon={<Shuffle size={14} />} variant="primary" />
        </div>
      </div>

      <Card full title={t("Sampled households")} icon={<ListChecks size={15} />}
            actions={<>
              <DownloadButton id={ns("download_spot")} label={t("Export sample (Excel)")} icon={<Download size={14} />} variant="outline-secondary" />
              <ActionButton id={ns("sc_go_verify")} label={t("Continue to verification")} icon={<ArrowRight size={14} />} />
            </>}>
        <p className="small text-muted mb-2">
          {t("Export this list, re-visit these households, then load what the team collected in the Verification tab.")}
        </p>
        <DataTable id={ns("spot_table")} />
      </Card>
    </>
  );
}

/* ------------------------------------------------------- 2. verification */

function VerifyTab({ t }: { t: T }) {
  const v = useShinyOutputValue<VerifState>(ns("verif_state"));
  const src = useShinyInputValue<string>(ns("verif_source")) ?? "file";
  return (
    <>
      <Card title={t("Back-check comparison")} icon={<ClipboardCheck size={15} />}>
        <p className="small text-muted">
          {t("Export the sample, re-collect those households, then load the results here to measure how far the two rounds agree.")}
        </p>
        <div className="tw-spot-vc">
          <section>
            <div className="tw-spot-vc-head"><span className="tw-spot-num">1</span>{t("Verification data")}</div>
            <RadioInput id={ns("verif_source")} buttons value="file"
                        choices={[{ value: "file", label: t("File") }, { value: "moda", label: t("MODA form") }]} />
            <div style={{ display: src === "file" ? undefined : "none" }}>
              <HostedUI id={ns("verif_file_ui")} className="tw-spot-file" />
            </div>
            <div style={{ display: src === "moda" ? undefined : "none" }} className="tw-spot-moda">
              <TextInput id={ns("verif_form_id")} label={t("Form ID")} placeholder={t("e.g. 123456")} />
              <TextInput id={ns("verif_token")} label={t("API key")} password />
              <div className="tw-spot-moda-go">
                <ActionButton id={ns("verif_fetch")} label={t("Fetch")} icon={<CloudDownload size={14} />} />
              </div>
            </div>
            {v?.loaded && (
              <div className={`small d-flex align-items-center gap-1 ${v.shared ? "text-success" : "text-danger"}`}>
                {v.shared ? <CircleCheck size={14} /> : <TriangleAlert size={14} />}
                {v.n} {t("records loaded")}{v.source ? ` (${v.source})` : ""}; {v.shared} {v.shared === 1 ? t("column in common with the sample") : t("columns in common with the sample")}.
              </div>
            )}
          </section>
          <section>
            <div className="tw-spot-vc-head"><span className="tw-spot-num">2</span>{t("Comparison")}</div>
            <div className="tw-spot-cmp">
              <SelectInput id={ns("verif_key")} label={t("Match records on")} clearable={false} />
              <SelectInput id={ns("verif_cols")} label={t("Fields to compare")} multiple actions placeholder={t("Nothing selected")} />
              <NumericInput id={ns("verif_tolerance")} label={t("Tolerance")} value={0} min={0} step={0.1}
                            help={t("Numeric answers closer than this count as agreeing.")} />
            </div>
            <div className="d-flex justify-content-end">
              <ActionButton id={ns("verif_run")} label={t("Run comparison")} icon={<GitCompare size={14} />} variant="primary" />
            </div>
          </section>
        </div>
        {!v?.loaded
          ? <EmptyState title={t("No verification data yet")} sub={t("Upload the re-collected dataset, or fetch the verification form from MODA, then run the comparison.")} />
          : !v.compared
            ? <EmptyState title={t("Ready to compare")} sub={t("Confirm the matching key and the fields to compare, then click Run comparison.")} />
            : null}
      </Card>

      {v?.compared && v.kpis && (
        <>
          <div className="tw-spot-kpis">
            <Kpi icon={<Link2 size={16} />} label={t("Matched records")} value={v.kpis.matched} sub={`${t("on")} ${v.kpis.key}`} />
            <Kpi icon={<CircleCheck size={16} />} label={t("Overall agreement")} value={v.kpis.agreement} tone="success" sub={`${v.kpis.fields} ${t("fields compared")}`} />
            <Kpi icon={<TriangleAlert size={16} />} label={t("Records with a discordance")} value={v.kpis.discordant} tone="warning" />
            <Kpi icon={<CircleHelp size={16} />} label={t("Unmatched")} value={v.kpis.unmatched} tone="neutral"
                 sub={`${v.kpis.only_original} ${t("not re-visited")}, ${v.kpis.only_verification} ${t("not in the sample")}`} />
          </div>
          <div className="tw-grid-2">
            <Card full title={t("Agreement by field")} help={<Legend t={t} />}>
              <Chart id={ns("verif_plot")} />
            </Card>
            <Card full title={t("Field summary")}>
              <DataTable id={ns("verif_field_table")} compact />
            </Card>
          </div>
          <Card full title={t("Discordances")}>
            <DataTable id={ns("verif_disc_table")} compact />
          </Card>
        </>
      )}
    </>
  );
}

function Legend({ t }: { t: T }) {
  return (
    <span className="tw-spot-legend">
      <i style={{ background: "#3f7e44" }} />95%+ <i style={{ background: "#f7b825" }} />90-95% <i style={{ background: "#c5192d" }} />{t("below 90%")}
    </span>
  );
}
