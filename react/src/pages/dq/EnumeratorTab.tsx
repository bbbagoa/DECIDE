// Enumerator Performance (R/mod_dq_enumerator.R): each enumerator against the
// team (speed, empty answers, daily load), flagged with the reason in words.
// "See their interviews" and Details open the server's dialogs.
import { BarChart3, ClipboardCheck, Download, Flag, Table2, UserRoundCheck, Users } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { DownloadButton, HostedUI } from "@/lib/inputs";
import { EmptyState } from "@/components/Figures";
import { Card, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { Kpis, ns, Note, type T } from "./common";

export function EnumeratorTab({ t }: { t: T }) {
  const st = useShinyOutputValue<{ mapped: boolean }>(ns("enum_state"));
  const off = st && !st.mapped;
  return (
    <>
      {off && (
        <div className="card tw-card"><div className="card-body">
          <EmptyState title={t("No enumerator mapped")}
                      sub={t("Map the enumerator in Variable Definition & Setup (Load registration data) to compare their speed, empty answers and daily load.")} />
        </div></div>
      )}
      {/* kept mounted: the outputs below stay bound */}
      <div className="d-flex flex-column gap-3" style={{ display: off ? "none" : undefined }}>
      <Kpis items={[
        { label: t("Active enumerators"), id: "enum_active", icon: <Users size={18} />, tone: "blue" },
        { label: t("Interviews per enumerator"), id: "enum_avg_int", icon: <UserRoundCheck size={18} />, tone: "grey" },
        { label: t("Total interviews"), id: "enum_total_int", icon: <ClipboardCheck size={18} />, tone: "cyan" },
        { label: t("Flagged for review"), id: "enum_flagged", icon: <Flag size={18} />, tone: "red" },
      ]} />
      <Tabs tabs={[
        {
          value: "flagged", label: t("Flagged enumerators"), icon: <Flag size={14} />,
          content: (
            <>
              <div className="tw-dq-cardbar">
                <HostedUI id={ns("enum_rules")} className="small text-muted flex-grow-1" />
                <DownloadButton id={ns("enum_flag_download")} label={t("Export flagged")} icon={<Download size={13} />} variant="outline-secondary" />
              </div>
              <HostedUI id={ns("enum_flagged_ui")} />
            </>
          ),
        },
        {
          value: "speed", label: t("Workload and speed"), icon: <BarChart3 size={14} />,
          content: (
            <>
              <HostedUI id={ns("enum_speed_insights")} />
              <div className="tw-grid-2">
                <Card title={t("Interviews by enumerator")} full>
                  <Note>{t("Red: flagged for review. Dashed line: the team median.")}</Note>
                  <Chart id={ns("enum_interviews_plot")} />
                </Card>
                <Card title={t("Average interview duration")} full>
                  <Note>{t("Green band: the team's usual range (IQR fences). Red: shorter; amber: longer. The enumerators furthest from the median are shown.")}</Note>
                  <Chart id={ns("enum_duration_plot")} />
                </Card>
              </div>
              <Card title={t("Interviews per day, by enumerator")} full>
                <Note>{t("Darker cells are busier days. A cell far darker than the rest of its row is a day worth checking.")}</Note>
                <Chart id={ns("enum_daily_plot")} />
              </Card>
            </>
          ),
        },
        {
          value: "table", label: t("Performance table"), icon: <Table2 size={14} />,
          content: (
            <>
              <Card title={t("Enumerator metrics")} full className="tw-dq-enum-table"><DataTable id={ns("enum_metrics_table")} compact /></Card>
              <Card title={t("Empty answers by enumerator")} full>
                <Note>{t("Red: over the team's limit (mean + 2 SD).")}</Note>
                <Chart id={ns("enum_missingness_plot")} />
              </Card>
            </>
          ),
        },
      ]} />
      </div>
    </>
  );
}
