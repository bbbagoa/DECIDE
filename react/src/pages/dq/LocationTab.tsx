// Location names normalization (R/mod_dq_location.R): the names of a level
// with their records, shown on Show names; selected names are merged into the
// correct spelling (the server's confirmation dialog, then the audit trail).
import { CheckCheck, Download, Eraser, List, MousePointerClick, Network, Signpost, Wand2 } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton, SelectInput, TextInput } from "@/lib/inputs";
import { EmptyState } from "@/components/Figures";
import { Card } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { ns, Toolbar, type T } from "./common";

const LEVELS = ["Admin 1", "Admin 2", "Admin 3", "Admin 4", "Village"];

export function LocationTab({ t }: { t: T }) {
  const hint = useShinyOutputValue<{ state: "none" | "unmapped"; level?: string } | null>(ns("location_hint"));
  const sel = useShinyOutputValue<{ name: string; n: number }[]>(ns("norm_selection")) ?? [];
  return (
    <>
      <Toolbar intro={t("Standardise the spelling of place names across the dataset: pick a level, select the variants of one name, type the correct spelling and apply.")}
        actions={<>
          <ActionButton id={ns("btn_apply_norm")} label={t("Apply to selected")} icon={<Wand2 size={13} />} variant="primary" />
          <ActionButton id={ns("btn_select_shown")} label={t("Select all shown")} icon={<CheckCheck size={13} />} variant="outline-secondary"
                        title={t("Select every row matching the table search")} />
          <ActionButton id={ns("btn_clear_selection")} label={t("Deselect all")} icon={<Eraser size={13} />} variant="outline-secondary" />
          <DownloadButton id={ns("download_locations")} label={t("Export")} icon={<Download size={13} />} variant="outline-secondary" />
        </>}>
        <SelectInput id={ns("norm_col")} label={t("Level to review")} choices={LEVELS} value="Admin 1" />
        <ActionButton id={ns("norm_show")} label={t("Show names")} icon={<List size={13} />} />
        <TextInput id={ns("correct_name")} label={t("Correct spelling")} placeholder={t("New spelling...")} />
      </Toolbar>
      {hint && <div className="card tw-card"><div className="card-body">
        {hint.state === "none"
          ? <EmptyState title={t("Choose a level")} sub={t("Pick the level to review, then click Show names.")} />
          : <EmptyState title={t("This level is not mapped")}
                        sub={`${t("No column is mapped to")} ${t(hint.level ?? "this level")}. ${t("Map it in Setup, or pick a level your dataset provides.")}`} />}
      </div></div>}
      {sel.length ? (
        <div className="tw-dq-chips tw-dq-norm-sel">
          <strong>{sel.length} {t("selected")}</strong>
          {sel.map((c) => <span key={c.name} className="tw-dq-chip">{c.name}<em>{c.n.toLocaleString("en-US")}</em></span>)}
        </div>
      ) : (
        <div className="tw-dq-chips empty tw-dq-norm-sel"><MousePointerClick size={14} /> {t("Click the rows to merge, or search and use Select all shown.")}</div>
      )}
      <div className="tw-grid-2">
        <Card title={t("Names and their records")} icon={<Signpost size={15} />} full>
          <DataTable id={ns("tab_location_norm")} compact />
        </Card>
        <Card title={t("How the names nest")} icon={<Network size={15} />} full>
          <p className="tw-dq-note">{t("Each box is a place, sized by its records; click one to zoom in. Near-identical names side by side are candidates to merge.")}</p>
          <Chart id={ns("dq_location_treemap")} />
        </Card>
      </div>
    </>
  );
}
