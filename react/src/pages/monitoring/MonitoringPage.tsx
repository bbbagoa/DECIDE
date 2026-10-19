// Targeting Monitoring (pdm_panel), the module monitoring_1 (R/mod_monitoring.R).
// Three tabs, input$monitoring_1-tabs as on the Shiny page. See PORT.md.
import { FileText, Target, Users } from "lucide-react";
import { Tabs } from "@/lib/layout";
import { useShinyOutputValue } from "@/shiny";
import { PdmTab } from "./PdmTab";
import { ProcessTab } from "./ProcessTab";
import { ReportTab } from "./ReportTab";
import "./monitoring.css";

export function MonitoringPage({ t }: { active: boolean; t: (s: string) => string }) {
  // the number of charts and tables in the report, beside its tab
  const n = useShinyOutputValue<{ items?: unknown[] }>("monitoring_1-mon_state")?.items?.length ?? 0;
  return (
    <div className="tw-mon">
      <Tabs id="monitoring_1-tabs" tabs={[
        { value: "pdm", label: t("1. Implementation errors"), icon: <Target size={15} />, content: <PdmTab t={t} /> },
        { value: "process", label: t("2. Targeting process"), icon: <Users size={15} />, content: <ProcessTab t={t} /> },
        { value: "report", label: <>{t("3. Report builder")} <span className="tw-mon-count tw-mon-tabcount" title={t("Charts and tables in the report")}>{n}</span></>, icon: <FileText size={15} />, content: <ReportTab t={t} /> },
      ]} />
    </div>
  );
}
