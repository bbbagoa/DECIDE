// Outliers (R/mod_dq_outliers.R): a variable, a method, its threshold and an
// allowed range, checked on Check; corrections are previewed in the server's
// dialog before they are written (and logged). input$outlier_tabs is switched
// by the server when a row of "All numeric variables" is clicked.
import {
  BarChart3, Check, ClipboardList, Download, Grid3x3, ListChecks, ListOrdered, MapPin, Pencil, Percent, Ruler, Search, SortDesc,
  TriangleAlert, Wand2,
} from "lucide-react";
import { useShinyInputValue } from "@/shiny";
import { ActionButton, DownloadButton, HostedUI, NumericInput, SelectInput, SliderInput, TextOutput } from "@/lib/inputs";
import { Card, Tabs } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { Kpis, ns, Note, Toolbar, type T } from "./common";

const METHODS = [
  { value: "IQR", label: "IQR (Tukey)" }, { value: "Z", label: "Z-Score (mean/SD)" },
  { value: "MAD", label: "Modified Z (MAD)" }, { value: "none", label: "Allowed range only" },
];
// the threshold of each method, as the Shiny page had it
const THRESHOLD: Record<string, { label: string; min: number; max: number; value: number }> = {
  IQR: { label: "IQR multiplier", min: 1, max: 5, value: 1.5 },
  Z: { label: "Standard deviations", min: 1, max: 6, value: 3 },
  MAD: { label: "Modified-Z multiplier", min: 1, max: 6, value: 3.5 },
};
const CORRECTIONS = [
  { value: "cap", label: "Cap at the limits" }, { value: "na", label: "Set to missing" },
  { value: "median", label: "Replace with Median" }, { value: "mean", label: "Replace with Mean" },
  { value: "knn", label: "K-Nearest Neighbors" }, { value: "drop", label: "Drop Row entirely" },
];

export function OutliersTab({ t }: { t: T }) {
  const method = useShinyInputValue<string>(ns("outlier_method")) || "IQR";
  const th = THRESHOLD[method];
  const tr = (cs: { value: string; label: string }[]) => cs.map((c) => ({ value: c.value, label: t(c.label) }));
  return (
    <>
      <Toolbar
        actions={<ActionButton id={ns("btn_apply_outlier_correction")} label={t("Correct all flagged")} icon={<Wand2 size={13} />} />}>
        <SelectInput id={ns("outlier_var")} label={t("Variable")} />
        <SelectInput id={ns("outlier_method")} label={t("Detection method")} choices={tr(METHODS)} value="IQR" />
        {/* a new slider per method: its own range and default (as the server's renderUI did) */}
        {th ? <SliderInput key={method} id={ns("outlier_threshold")} label={t(th.label)} min={th.min} max={th.max} step={0.5} value={th.value} />
          : null}
        <div className="tw-dq-fieldset">
          <label className="form-label" title={t("The values this variable can plausibly take (e.g. a household size of 1 to 30). Values outside it are flagged whatever the distribution says.")}>
            {t("Allowed range")}
          </label>
          <div className="tw-dq-range">
            <NumericInput id={ns("range_min")} placeholder="min" />
            <NumericInput id={ns("range_max")} placeholder="max" />
          </div>
        </div>
        <SelectInput id={ns("outlier_correction_method")} label={t("Correction")} choices={tr(CORRECTIONS)} value="cap" />
        <ActionButton id={ns("ol_check")} label={t("Check")} icon={<Search size={13} />} variant="primary"
                      title={t("Look for outliers with this variable, method and allowed range")} />
      </Toolbar>
      <HostedUI id={ns("range_hint")} />
      <HostedUI id={ns("ol_stale")} />
      <Kpis items={[
        { label: t("Values checked"), id: "outlier_total", icon: <ListOrdered size={18} />, tone: "blue" },
        { label: t("Flagged"), id: "outlier_count", subId: "outlier_verified", icon: <TriangleAlert size={18} />, tone: "amber" },
        { label: t("Flag rate"), id: "outlier_rate", icon: <Percent size={18} />, tone: "cyan" },
        { label: t("Accepted values"), id: "outlier_bounds", subId: "outlier_bounds_src", icon: <Ruler size={18} />, tone: "grey" },
      ]} />
      <Tabs id={ns("outlier_tabs")} value="dist" tabs={[
        {
          value: "dist", label: t("Distribution"), icon: <BarChart3 size={14} />,
          content: (
            <div className="tw-grid-2">
              <Card title={t("Distribution and limits")} full>
                <Note>{t("Red dashed: statistical bounds. Blue dotted: allowed range.")}</Note>
                <Chart id={ns("plot_outlier_hist")} height={320} />
              </Card>
              <Card title={t("By area")} full>
                <Note>{t("The spread in each Admin 1; red points lie beyond the whiskers.")}</Note>
                <Chart id={ns("plot_outlier_box")} height={320} />
              </Card>
            </div>
          ),
        },
        {
          value: "where", label: t("Where they come from"), icon: <MapPin size={14} />,
          content: (
            <div className="tw-grid-2">
              <Card title={t("Flag rate by Admin 1")} full><Chart id={ns("plot_outlier_admin_rates")} /></Card>
              <Card title={t("Flag rate by enumerator")} full><Chart id={ns("plot_outlier_enum_rates")} /></Card>
            </div>
          ),
        },
        {
          value: "flagged", label: t("Most extreme values"), icon: <SortDesc size={14} />,
          content: (
            <>
              <HostedUI id={ns("outlier_insights")} />
              <Card title={t("Flagged values, most extreme first")} icon={<ListChecks size={15} />} full>
                <div className="tw-dq-cardbar">
                  <ActionButton id={ns("ol_select_all")} label={t("Select all")} variant="outline-secondary" />
                  <ActionButton id={ns("ol_select_none")} label={t("Clear selection")} variant="outline-secondary" />
                  <span className="tw-dq-sel"><TextOutput id={ns("ol_selected_n")} /></span>
                  <div className="tw-dq-push">
                    <ActionButton id={ns("ol_correct_sel")} label={t("Correct selected")} icon={<Wand2 size={13} />} />
                    <ActionButton id={ns("ol_set_value")} label={t("Set a value")} icon={<Pencil size={13} />} />
                    <ActionButton id={ns("ol_verify")} label={t("Mark as verified")} icon={<Check size={13} />} variant="outline-secondary" />
                    <DownloadButton id={ns("ol_download")} label={t("Export")} icon={<Download size={13} />} variant="outline-secondary" />
                  </div>
                </div>
                <DataTable id={ns("ol_table")} compact />
              </Card>
            </>
          ),
        },
        {
          value: "all", label: t("All numeric variables"), icon: <Grid3x3 size={14} />,
          content: (
            <Card title={t("Every numeric variable, with the settings above")} icon={<ClipboardList size={15} />} full
                  actions={<ActionButton id={ns("ol_scan")} label={t("Audit all numeric variables")} icon={<Search size={13} />} />}>
              <Note>{t("Checks every numeric column with the detection method and the allowed ranges you entered. Click a row to open that variable.")}</Note>
              <HostedUI id={ns("ol_scan_empty")} />
              <DataTable id={ns("ol_scan_table")} compact />
            </Card>
          ),
        },
      ]} />
    </>
  );
}
