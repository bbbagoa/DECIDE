// Spelling & Integrity (R/mod_dq_spelling.R): the name columns are checked
// on Check names; a record is edited or deleted in the server's dialogs.
import { Download, Pencil, Search, SpellCheck, Trash2 } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton, SelectInput } from "@/lib/inputs";
import { EmptyState } from "@/components/Figures";
import { Card } from "@/lib/layout";
import { DataTable } from "@/lib/table";
import { ns, Toolbar, type T } from "./common";

export function SpellingTab({ t }: { t: T }) {
  const m = useShinyOutputValue<{ n: number; total: number; pct: number }>(ns("dq_names_metric"));
  const empty = useShinyOutputValue<"pick" | "clean" | null>(ns("dq_names_empty"));
  return (
    <>
      <Toolbar
        actions={<>
          <ActionButton id={ns("btn_open_edit")} label={t("Edit selected")} icon={<Pencil size={13} />} />
          <ActionButton id={ns("btn_delete_all_missing")} label={t("Delete rows with missing names")} icon={<Trash2 size={13} />} variant="outline-danger" />
          <DownloadButton id={ns("download_audit")} label={t("Export")} icon={<Download size={13} />} variant="outline-secondary" />
        </>}>
        <SelectInput id={ns("dq_name_cols")} label={t("Name columns to audit")} help={t("Head of household and alternates")} multiple actions
                     placeholder={t("Select all columns representing names...")} className="wide" />
        <ActionButton id={ns("dq_names_check")} label={t("Check names")} icon={<Search size={13} />} variant="primary" />
        {m && (
          <div className="tw-dq-metric">
            <div className="tw-dq-metric-label">{t("Invalid records")}</div>
            <div className="tw-dq-metric-value">{m.n.toLocaleString("en-US")}<small>{m.pct}% {t("of selected")}</small></div>
          </div>
        )}
      </Toolbar>
      {empty && <div className="card tw-card tw-dq-names-empty"><div className="card-body">
        {empty === "pick"
          ? <EmptyState title={t("Pick the name columns to audit")}
                        sub={t("Choose the columns holding names (head of household, alternates) above, then click Check names: records with missing or suspicious names are listed here.")} />
          : <EmptyState title={t("No suspicious names")} sub={t("Every record has a plausible name in the columns picked.")} />}
      </div></div>}
      {/* kept mounted (its selection is an input); shown when there is something to list */}
      <div style={{ display: m && m.n > 0 ? undefined : "none" }}>
        <Card title={t("Records with missing or suspicious names")} icon={<SpellCheck size={15} />} full>
          <p className="tw-dq-note">{t("Select a record, then Edit selected to correct its names or delete it. Every change goes to the audit trail.")}</p>
          <DataTable id={ns("dq_names_redflags")} compact />
        </Card>
      </div>
    </>
  );
}
