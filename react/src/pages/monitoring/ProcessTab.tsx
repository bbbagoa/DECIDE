// Tab 2, targeting process (R/mod_monitoring.R): the officer's own datasets
// (complaints, community sessions, committees...), any number of them, with
// the areas covered, and the chart builder on the one picked.
import { Database, MapPin, Trash2 } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, SelectInput } from "@/lib/inputs";
import { SidebarLayout, Steps } from "@/lib/layout";
import { AreaScope } from "@/components/AreaScope";
import { ModaImport } from "@/components/ModaImport";
import { ModaRefresh } from "@/components/ModaRefresh";
import { DataSummary } from "@/components/DataSummary";
import { Dropzone } from "./Dropzone";
import { ChartBuilder } from "./ChartBuilder";
import type { MonState } from "./types";

const ns = (x: string) => "monitoring_1-" + x;

export function ProcessTab({ t }: { t: (s: string) => string }) {
  const st = useShinyOutputValue<MonState>(ns("mon_state"));
  const ds = st?.datasets ?? [];
  const sidebar = (
    <Steps open="data" steps={[
      {
        key: "data", title: t("Datasets"), icon: <Database size={14} />,
        summary: ds.length ? `${ds.length} ${ds.length > 1 ? t("datasets") : t("dataset")}` : t("None yet"),
        content: <>
          <p className="small text-muted mb-2">{t("Complaints and feedback, community sessions, targeting committees, participation of women and minorities, focus groups on the criteria. Load as many as you have.")}</p>
          <Dropzone id={ns("pm_file_ui")} />
          <div className="d-flex gap-2 align-items-end">
            <SelectInput id={ns("pm_active")} label={t("Dataset to chart")} choices={[]} value="" className="flex-fill" />
            <ActionButton id={ns("pm_remove")} icon={<Trash2 size={14} />} variant="outline-danger" title={t("Remove this dataset")} className="mb-2" />
          </div>
          <div className="mb-2"><ModaImport ns={ns("pm_moda")} size="sm" t={t} /></div>
          <div className="mb-2"><ModaRefresh ns={ns("pm_refresh")} block t={t} /></div>
          <div className="mb-2"><DataSummary ns={ns("pm_summary")} label="Summary of this dataset" block t={t} /></div>
          {ds.length > 0 && (
            <div className="tw-mon-chips">
              {ds.map((d) => <span key={d.name} className="tw-mon-chip" title={d.name}>{d.name} <em>{d.rows.toLocaleString("en-US")}</em></span>)}
            </div>
          )}
        </>,
      },
      { key: "areas", title: t("Areas covered"), icon: <MapPin size={14} />, content: <AreaScope ns={ns("pm_scope")} title={null} t={t} /> },
    ]} />
  );
  return (
    <SidebarLayout width={330} sidebar={sidebar}>
      <ChartBuilder prefix="monitoring_1-pm_charts-" t={t} />
    </SidebarLayout>
  );
}
