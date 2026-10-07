// Missing Data Checking (R/mod_dq_missing.R): the fields that must be filled
// and a geographic level, analysed on Apply; then the headline figures and one
// view per question (which fields, which combinations, where).
import type { ReactNode } from "react";
import { ArrowDownCircle, CircleAlert, CircleCheck, Filter, Grid3x3, ListChecks, MapPin } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, HostedUI, SelectInput } from "@/lib/inputs";
import { Card, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { Kpis, ns, Note, Toolbar, type T } from "./common";

type Tile = { label: string; value: string; sub: string; tone: string };
const LEVELS = ["Admin 1", "Admin 2", "Admin 3", "Admin 4", "Village"];
const KPI_STYLE: Record<string, { icon: ReactNode; tone: "green" | "amber" | "cyan" | "red" }> = {
  ok: { icon: <CircleCheck size={18} />, tone: "green" }, warn: { icon: <CircleAlert size={18} />, tone: "amber" },
  info: { icon: <ListChecks size={18} />, tone: "cyan" }, bad: { icon: <ArrowDownCircle size={18} />, tone: "red" },
};

export function MissingTab({ t }: { t: T }) {
  const ready = useShinyOutputValue<boolean>(ns("missing_results"));
  const kpis = useShinyOutputValue<Tile[]>(ns("missing_kpis"));
  return (
    <>
      <Toolbar>
        <SelectInput id={ns("mandatory_vars")} label={t("Mandatory fields to check")} multiple actions className="wide" />
        <SelectInput id={ns("missing_geo_level")} label={t("Geographic level")} choices={LEVELS} value="Admin 1" />
        <ActionButton id={ns("btn_apply_missing")} label={t("Apply")} icon={<Filter size={13} />} variant="primary" />
      </Toolbar>
      <HostedUI id={ns("missing_hint")} />
      {/* kept mounted (charts measure themselves once shown) */}
      <div className="d-flex flex-column gap-3" style={{ display: ready ? undefined : "none" }}>
        {kpis && <Kpis items={kpis.map((k) => ({ label: t(k.label), value: k.value, sub: k.sub, ...KPI_STYLE[k.tone] }))} />}
        <Tabs tabs={[
          {
            value: "field", label: t("By field"), icon: <ListChecks size={14} />,
            content: (
              <div className="tw-grid-75">
                <Card title={t("Completeness by field")} full>
                  <Note>{t("Green: 95% or more filled in; amber: 90 to 95%; red: under 90%.")}</Note>
                  <Chart id={ns("plot_field_completeness")} />
                </Card>
                <Card title={t("Column health")} full>
                  <DataTable id={ns("tab_col_health")} compact searchable={false} />
                </Card>
              </div>
            ),
          },
          {
            value: "patterns", label: t("Patterns"), icon: <Grid3x3 size={14} />,
            content: (
              <Card title={t("Which fields go missing together")} full>
                <Note>{t("Top: the most frequent combinations of empty fields. Bottom: the fields in each combination, with each field's total on the left.")}</Note>
                <Chart id={ns("plot_missing_upset")} />
              </Card>
            ),
          },
          {
            value: "where", label: t("By location"), icon: <MapPin size={14} />,
            content: (
              <>
                <Card title={t("Gap rate by location")} full>
                  <Note>{t("Share of households with at least one checked field empty, the 50 locations with the most gaps.")}</Note>
                  <Chart id={ns("plot_geo_missing_bars")} />
                </Card>
                <div className="tw-grid-2">
                  <Card title={t("Categorical fields by location")} full>
                    <Note>{t("Share of answers left empty, by field and location.")}</Note>
                    <Chart id={ns("plot_missing_qualitative")} />
                  </Card>
                  <Card title={t("Numeric fields by location")} full>
                    <Note>{t("Number of answers left empty, by field and location.")}</Note>
                    <Chart id={ns("plot_missing_quantitative")} />
                  </Card>
                </div>
              </>
            ),
          },
        ]} />
      </div>
    </>
  );
}
