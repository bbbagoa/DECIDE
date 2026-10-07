// The chart builder (R/mod_chart_builder.R): a ready-made chart or one's own,
// previewed live, added to the monitoring report with a title and a comment.
// Used on the PDM data (monitoring_1-pdm_charts) and the targeting-process
// datasets (monitoring_1-pm_charts). Fields the Shiny page hid with
// conditionalPanel() are hidden here too, but stay mounted so the server's
// updateSelectInput() still reaches them.
import { useEffect, useRef } from "react";
import { ChartColumn, MoveVertical, Plus, SlidersHorizontal } from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, HostedUI, RadioInput, SelectInput, TextInput, type Choice } from "@/lib/inputs";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { Card, signalShown } from "@/lib/layout";
import { RichText } from "./RichText";

type Meta = { presets: Choice[]; types: Record<string, string>; styles: Record<string, string> };
type State = { has_data: boolean; too_many: string | null; ready: boolean; axes_set: boolean };

export function ChartBuilder({ prefix, t }: { prefix: string; t: (s: string) => string }) {
  const ns = (x: string) => prefix + x;
  const meta = useShinyOutputValue<Meta>(ns("cb_meta"));
  const st = useShinyOutputValue<State>(ns("cb_state"));
  const display = useShinyInputValue<string>(ns("display")) ?? "chart";
  const type = useShinyInputValue<string>(ns("type")) ?? "count";
  const title = useShinyInputValue<string>(ns("title")) ?? "";
  const table = display === "table";
  const ready = !!st?.ready;
  // a preview shown again is told so: Shiny pauses hidden outputs
  const body = useRef<HTMLDivElement>(null);
  useEffect(() => { signalShown(body.current, true); }, [table, ready]);
  if (!meta) return null;
  const show = (on: boolean) => (on ? undefined : { display: "none" });
  return (
    <div className="tw-cb">
      <Card title={t("Chart")} icon={<SlidersHorizontal size={15} />} className="tw-cb-fields">
        <SelectInput id={ns("preset")} label={t("Ready-made chart")} choices={meta.presets} value="custom" />
        <RadioInput id={ns("display")} label={t("Display as")} buttons value="chart"
                    choices={[{ value: "chart", label: t("Chart") }, { value: "table", label: t("Table") }]} className="tw-cb-seg" />
        <SelectInput id={ns("type")} label={t("Show")} choices={meta.types} value="count" />
        <div style={show(!table)}>
          <div className="tw-cb-row">
            <SelectInput id={ns("style")} label={t("Chart style")} choices={meta.styles} value="auto" className="flex-fill" />
            <ActionButton id={ns("axes")} label={st?.axes_set ? t("Axes (set)") : t("Axes")} icon={<MoveVertical size={13} />}
                          variant="outline-secondary" className="tw-cb-axes" title={t("Set the value axis")} />
          </div>
        </div>
        <div style={show(type !== "trend")}>
          <SelectInput id={ns("x")} label={t("By")} choices={[]} value="" />
        </div>
        <div className="tw-cb-row" style={show(type === "trend")}>
          <SelectInput id={ns("date")} label={t("Date column")} choices={[]} value="" className="flex-fill" />
          <SelectInput id={ns("period")} label={t("Per")} choices={[{ value: "month", label: t("Month") }, { value: "week", label: t("Week") }]}
                       value="month" className="tw-cb-period" />
        </div>
        <div style={show(["sum", "mean", "share", "trend"].includes(type))}>
          <SelectInput id={ns("value")} label={t("Number column")} choices={[]} value="" />
        </div>
        <div style={show(type === "share")}>
          <SelectInput id={ns("den")} label={t("Out of (total column)")} choices={[]} value="" />
        </div>
        <SelectInput id={ns("group")} label={t("Split by (optional; the columns of a crosstab)")} choices={[]} value="" />
        <div style={show(type === "crosstab")}>
          <RadioInput id={ns("pct")} label={t("Percentages")} buttons value="row"
                      choices={[{ value: "row", label: t("Row") }, { value: "col", label: t("Column") }, { value: "total", label: t("Total") },
                                { value: "count", label: t("Counts only") }]} />
        </div>
        <div className="tw-cb-row">
          <SelectInput id={ns("filter_col")} label={t("Only where")} choices={[]} value="" className="flex-fill" />
          <SelectInput id={ns("filter_vals")} label={t("is one of")} choices={[]} multiple actions className="flex-fill" />
        </div>
      </Card>

      <Card title={title.trim() || t("Preview")} icon={<ChartColumn size={15} />} full className="tw-cb-preview">
        <div ref={body}>
        <HostedUI id={ns("preview_empty")} />
        <HostedUI id={ns("stat_note")} />
        <div style={show(!table && ready)}><Chart id={ns("preview")} height={360} /></div>
        <div style={show(table && ready)}><DataTable id={ns("preview_table")} searchable={false} compact /></div>
        </div>
        <div className="tw-cb-add">
          <TextInput id={ns("title")} label={t("Title in the report")} />
          <RichText id={ns("comment")} label={t("Your comment (what it shows, why it matters)")} rows={3}
                    placeholder={t("e.g. Women made up 38% of participants in Beni, below the 50% target; sessions were held on market days.")} />
          <div className="d-flex justify-content-end">
            <ActionButton id={ns("add")} label={t("Add to report")} icon={<Plus size={14} />} variant="primary" />
          </div>
        </div>
      </Card>
    </div>
  );
}
