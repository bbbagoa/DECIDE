// Enumerator Performance (R/mod_dq_enumerator.R): each enumerator against the
// team (speed, empty answers, daily load), flagged with the reason in words.
// "See their interviews" and Details open the server's dialogs.
import { useRef } from "react";
import { BarChart3, ClipboardCheck, Download, Flag, Info, Table2, UserRoundCheck, Users } from "lucide-react";
import { useSetShinyInput, useShinyOutputValue } from "@/shiny";
import { DownloadButton } from "@/lib/inputs";
import { useOutputVisibility } from "@/lib/visibility";
import { EmptyState } from "@/components/Figures";
import { Card, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { Kpis, ns, Note, type T } from "./common";
import { Insights, type Insight } from "./Insights";

type Flagged = {
  rules: { dur_lo: string; dur_hi: string; miss_hi: string; day_hi: string | null };
  flagged: { id: string; interviews: number; reasons: string[] }[];
};

/** The rules, then one card per flagged enumerator; "See their interviews" sets input$enum_open (server dialog). */
function FlaggedCards({ t }: { t: T }) {
  const box = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("enum_flagged_ui"), box);
  const f = useShinyOutputValue<Flagged | null>(ns("enum_flagged_ui"));
  const open = useSetShinyInput<string | null>(ns("enum_open"), null, { debounceMs: 0, priority: "event" });
  const r = f?.rules;
  return (
    <div ref={box} className="d-flex flex-column gap-2">
      <div className="tw-dq-cardbar">
        <div className="tw-dq-rules">
          {r && <><Info size={14} /><span>
            {t("Flagged against the other enumerators: average interview under")} {r.dur_lo} {t("or over")} {r.dur_hi} {t("min (outside the IQR fences), missing answers over")} {r.miss_hi}% {t("(mean + 2 SD)")}
            {r.day_hi ? <>, {t("or more than")} {r.day_hi} {t("interviews in one day")}</> : null}.
          </span></>}
        </div>
        <DownloadButton id={ns("enum_flag_download")} label={t("Export flagged")} icon={<Download size={13} />} variant="outline-secondary" />
      </div>
      {f && !f.flagged.length && (
        <EmptyState title={t("No enumerator flagged")} sub={t("Everyone's speed, completeness and daily load are in line with the team.")} />
      )}
      {f && f.flagged.length > 0 && (
        <div className="tw-dq-enum-grid">
          {f.flagged.map((e) => (
            <div key={e.id} className="tw-dq-insight tw-dq-enum-card">
              <div className="tw-dq-enum-head"><strong>{e.id}</strong><small>{e.interviews.toLocaleString("en-US")} {t("interviews")}</small></div>
              <ul className="tw-dq-enum-reasons">{e.reasons.map((x) => <li key={x}>{x}</li>)}</ul>
              <button type="button" className="btn btn-link p-0 tw-link align-self-start" onClick={() => open(e.id)}>{t("See their interviews")}</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function SpeedInsights({ t }: { t: T }) {
  const box = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("enum_speed_insights"), box);
  const items = useShinyOutputValue<Insight[] | null>(ns("enum_speed_insights"));
  return <div ref={box}><Insights items={items ?? []} t={t} /></div>;
}

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
            <FlaggedCards t={t} />
          ),
        },
        {
          value: "speed", label: t("Workload and speed"), icon: <BarChart3 size={14} />,
          content: (
            <>
              <SpeedInsights t={t} />
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
