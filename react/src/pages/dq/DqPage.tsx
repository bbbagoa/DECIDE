// Data Quality (dq_panel), the module dq_1 (R/mod_dq.R and R/mod_dq_*.R).
// The sidebar filters the data every tab reads (applied on Apply); the tabs
// are input$dq_tabs, so the Health check's Review buttons switch them from
// the server (bslib::nav_select("dq_tabs", <tab title>)). See PORT.md.
import { CalendarRange, ClipboardList, Copy, FileText, Filter, Gauge, HeartPulse, IdCard, MapPin, RotateCcw, SpellCheck, X } from "lucide-react";
import { DataExport } from "@/components/DataExport";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, DateInput, DownloadButton, SelectInput, TextOutput } from "@/lib/inputs";
import { SidebarLayout, SideActions, Steps, Tabs } from "@/lib/layout";
import { ns, type T } from "./common";
import { HealthTab } from "./HealthTab";
import { SpellingTab } from "./SpellingTab";
import { LocationTab } from "./LocationTab";
import { MissingTab } from "./MissingTab";
import { OutliersTab } from "./OutliersTab";
import { DuplicatesTab } from "./DuplicatesTab";
import { EnumeratorTab } from "./EnumeratorTab";

type Meta = { dates: [string, string] | null };

const dmy = (s?: string) => { const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(s ?? ""); return m ? `${m[3]}/${m[2]}/${m[1]}` : ""; };

export function DqPage({ t }: { active: boolean; t: T }) {
  const meta = useShinyOutputValue<Meta>(ns("dq_meta"));
  const a1 = useShinyInputValue<string[] | null>(ns("dq_filter_adm1"));
  const a2 = useShinyInputValue<string[] | null>(ns("dq_filter_adm2"));
  const a3 = useShinyInputValue<string[] | null>(ns("dq_filter_adm3"));
  const dates = useShinyInputValue<string[] | null>(ns("dq_filter_date"));
  const areaSummary = [a1, a2, a3].some((v) => Array.isArray(v) && v.length)
    ? [a1, a2, a3].map((v) => (Array.isArray(v) ? v.length : 0)).filter(Boolean).join(" / ") + ` ${t("selected")}` : t("All areas");

  const steps = [
    {
      key: "areas", title: t("1. Areas"), icon: <MapPin size={14} />, summary: areaSummary,
      content: <>
        {[1, 2, 3].map((k) => (
          <SelectInput key={k} id={ns(`dq_filter_adm${k}`)} label={`Admin ${k}`} multiple actions placeholder={t("All")} />
        ))}
      </>,
    },
  ];
  if (meta?.dates) {
    steps.push({
      key: "dates", title: t("2. Interview dates"), icon: <CalendarRange size={14} />,
      summary: Array.isArray(dates) && dates[0] ? `${dmy(dates[0])} - ${dmy(dates[1])}` : t("All dates"),
      content: <DateInput id={ns("dq_filter_date")} range value={meta.dates} min={meta.dates[0]} max={meta.dates[1]} />,
    });
  }

  const sidebar = (
    <>
      <Steps steps={steps} />
      <SideActions>
        <div className="d-flex gap-2">
          <ActionButton id={ns("btn_apply_dq_filters")} label={t("Apply")} icon={<Filter size={14} />} variant="primary" className="flex-fill" />
          <ActionButton id={ns("btn_clear_dq_filters")} icon={<X size={14} />} variant="outline-secondary" title={t("Clear the filters")} />
        </div>
        <DownloadButton id={ns("dq_report")} label={t("Data quality report (HTML)")} icon={<FileText size={14} />} className="w-100" />
        <DataExport ns="export_dq" label="Download the cleaned data" block t={t} />
        <ActionButton id={ns("btn_reset_data")} label={t("Reset to original data")} icon={<RotateCcw size={14} />} variant="outline-danger" className="w-100" />
        <div className="tw-dq-rows"><TextOutput id={ns("dq_filtered_rows")} /></div>
      </SideActions>
    </>
  );

  // values are the tab titles the server knows (nav_select("dq_tabs", ...))
  const tabs = [
    { value: "Health check", label: t("Health check"), icon: <HeartPulse size={14} />, content: <HealthTab t={t} /> },
    { value: "Spelling & Integrity", label: t("Spelling & Integrity"), icon: <SpellCheck size={14} />, content: <SpellingTab t={t} /> },
    { value: "Location names normalization", label: t("Location names"), icon: <MapPin size={14} />, content: <LocationTab t={t} /> },
    { value: "Missing Data Checking", label: t("Missing data"), icon: <ClipboardList size={14} />, content: <MissingTab t={t} /> },
    { value: "Outliers", label: t("Outliers"), icon: <Gauge size={14} />, content: <OutliersTab t={t} /> },
    { value: "Duplicates", label: t("Duplicates"), icon: <Copy size={14} />, content: <DuplicatesTab t={t} /> },
    { value: "Enumerator Performance", label: t("Enumerators"), icon: <IdCard size={14} />, content: <EnumeratorTab t={t} /> },
  ];

  return (
    <SidebarLayout className="tw-dq" sidebar={sidebar}>
      <Tabs id={ns("dq_tabs")} tabs={tabs} value="Health check" />
    </SidebarLayout>
  );
}
