// Location names normalization (R/mod_dq_location.R): the names of a level
// with their records, shown on Show names; selected names are merged into the
// correct spelling (the server's confirmation dialog, then the audit trail).
import { CheckCheck, Download, Eraser, List, MousePointerClick, Network, Signpost, Wand2, X } from "lucide-react";
import { useState } from "react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton, NumericInput, RadioInput, SelectInput, TextInput } from "@/lib/inputs";
import { EmptyState } from "@/components/Figures";
import { Card } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { DataTable } from "@/lib/table";
import { ns, Toolbar, type T } from "./common";

const LEVELS = ["Admin 1", "Admin 2", "Admin 3", "Admin 4", "Village"];
const VIEWS = [
  { value: "similar", label: "Similar names", note: "Each bubble is a name, sized by its records; look-alike names are linked and share a colour. Click one to select its group in the table." },
  { value: "sunburst", label: "Sunburst", note: "The levels as rings, the top level in the centre, sized by records; click a segment to zoom in, the centre to zoom out." },
  { value: "bars", label: "Variant bars", note: "One bar per group of look-alike names: the most common spelling in blue, the variants after it. Click a bar to select its group." },
];

type ShinyApi = { setInputValue: (id: string, v: unknown, o?: { priority: string }) => void };
// a name taken out of the selection (the cross on its chip)
const unselect = (name: string) =>
  (window as unknown as { Shiny?: ShinyApi }).Shiny?.setInputValue(ns("norm_unselect"), { name }, { priority: "event" });

export function LocationTab({ t }: { t: T }) {
  const hint = useShinyOutputValue<{ state: "none" | "unmapped"; level?: string } | null>(ns("location_hint"));
  const [view, setView] = useState("similar");
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
          {sel.map((c) => (
            <span key={c.name} className="tw-dq-chip">{c.name}<em>{c.n.toLocaleString("en-US")}</em>
              <button type="button" className="tw-dq-chip-x" title={t("Remove from the selection")} aria-label={`${t("Remove from the selection")}: ${c.name}`}
                      onClick={() => unselect(c.name)}><X size={12} /></button>
            </span>
          ))}
        </div>
      ) : (
        <div className="tw-dq-chips empty tw-dq-norm-sel"><MousePointerClick size={14} /> {t("Click the rows to merge, or search and use Select all shown.")}</div>
      )}
      <div className="tw-grid-2">
        <Card title={t("Names and their records")} icon={<Signpost size={15} />} full>
          <DataTable id={ns("tab_location_norm")} compact selectedFirst />
        </Card>
        <Card title={t("Names at a glance")} icon={<Network size={15} />} full
              actions={<RadioInput id={ns("loc_view")} choices={VIEWS.map((v) => ({ value: v.value, label: t(v.label) }))} value="similar" buttons className="mb-0" onChange={setView} />}>
          <div className="tw-loc-note-row">
            <p className="tw-dq-note">{t(VIEWS.find((v) => v.value === view)?.note ?? VIEWS[0].note)}</p>
            <div style={view === "sunburst" ? { display: "none" } : undefined}
                 title={t("How alike two names must be to count as variants: 80% lets one letter in five differ.")}>
              <NumericInput id={ns("loc_similarity")} label={t("Similarity (%)")} value={80} min={50} max={100} step={5} className="mb-0" />
            </div>
          </div>
          <Chart id={ns("dq_location_view")} />
        </Card>
      </div>
    </>
  );
}
