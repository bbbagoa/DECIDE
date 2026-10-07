// Duplicates (R/mod_dq_duplicates.R): records that share the chosen columns
// (or nearly, with fuzzy matching), found on Find duplicates, shown one band
// per group. Compare opens a group side by side (server dialog); deletions are
// confirmed in the server's dialog and logged.
import { Copy, Download, Files, ListOrdered, Network, Search, Trash2 } from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, CheckboxInput, DownloadButton, HostedUI, SelectInput, SliderInput, TextOutput } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { DataTable } from "@/lib/table";
import { Kpis, ns, Note, Toolbar, type T } from "./common";

export function DuplicatesTab({ t }: { t: T }) {
  const fuzzy = useShinyInputValue<boolean>(ns("duplicate_fuzzy"));
  const has = useShinyOutputValue<boolean>(ns("dup_has_rows"));
  return (
    <>
      <Toolbar>
        <SelectInput id={ns("duplicate_vars")} label={t("Columns that identify a household")} multiple actions className="wide" />
        <CheckboxInput id={ns("duplicate_fuzzy")} label={t("Fuzzy matching")} asSwitch className="tw-dq-btn" />
        <div className={fuzzy ? "" : "tw-dq-dim"} style={{ flex: "0 1 200px" }}
             title={t("How alike two records must be to count as the same household: 90% lets about one character in ten differ, so longer names allow more typos than short ones. 100% means identical.")}>
          <SliderInput id={ns("duplicate_fuzzy_dist")} label={t("Similarity")} min={50} max={100} step={1} value={90} format={(n) => `${n}%`} />
        </div>
        <ActionButton id={ns("btn_refresh_duplicates")} label={t("Find duplicates")} icon={<Search size={13} />} variant="primary" />
        <DownloadButton id={ns("download_duplicates")} label={t("Export")} icon={<Download size={13} />} variant="outline-secondary" className="tw-dq-btn" />
      </Toolbar>
      <Kpis items={[
        { label: t("Records checked"), id: "dup_total", icon: <ListOrdered size={18} />, tone: "blue" },
        { label: t("Duplicate records"), id: "dup_count", icon: <Copy size={18} />, tone: "amber" },
        { label: t("Duplicate groups"), id: "dup_groups", icon: <Network size={18} />, tone: "cyan" },
        { label: t("Exact copies"), id: "dup_exact", sub: t("identical on every column: safe to remove"), icon: <Files size={18} />, tone: "red" },
      ]} />
      <HostedUI id={ns("dup_hint")} />
      <div style={{ display: has ? undefined : "none" }}>
        <Card title={t("Duplicate groups")} icon={<Copy size={15} />} full>
          <div className="tw-dq-cardbar">
            <ActionButton id={ns("dup_sel_extra")} label={t("Select all but the first of each group")} variant="outline-secondary" />
            <ActionButton id={ns("dup_sel_exact")} label={t("Select exact copies")} variant="outline-secondary" />
            <ActionButton id={ns("dup_sel_none")} label={t("Clear selection")} variant="outline-secondary" />
            <span className="tw-dq-sel"><TextOutput id={ns("dup_selected_n")} /></span>
            <div className="tw-dq-push">
              <ActionButton id={ns("dup_delete")} label={t("Delete selected")} icon={<Trash2 size={13} />} variant="outline-danger" />
            </div>
          </div>
          <Note>{t("Each band is one group. 'Differs in' lists the columns where its records disagree; none means exact copies. Compare shows a group side by side, and you can delete from there too.")}</Note>
          <DataTable id={ns("dq_duplicate_table")} compact />
        </Card>
      </div>
    </>
  );
}
