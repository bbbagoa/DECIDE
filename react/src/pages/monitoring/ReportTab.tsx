// Tab 3, the monitoring report (R/mod_monitoring.R): templates (draft, save,
// export as JSON, import), the officer's texts, then the report's items in
// order, each with its comment. Order and width change on the server
// (input$item_order, input$item_act): drag an item by its handle, or use
// the arrows; half-width items sit side by side, as in the report.
import { useEffect, useState, type DragEvent } from "react";
import {
  ArrowDown, ArrowUp, Clock, Columns2, Download, FileText, GripVertical, Layers, Lightbulb, Maximize2, PenLine, Save, Trash2, WandSparkles, X,
} from "lucide-react";
import { useSetShinyInput, useShinyInitialized, useShinyOutputValue } from "@/shiny";
import { ActionButton, CheckboxInput, DownloadButton, SelectInput } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { EmptyState } from "@/components/Figures";
import { RichText } from "./RichText";
import { Dropzone } from "./Dropzone";
import type { Item, MonState } from "./types";

const ns = (x: string) => "monitoring_1-" + x;

// The report check sends this when nothing needs a look: click the hidden download link.
function useDownloadMessage() {
  const ready = useShinyInitialized();
  useEffect(() => {
    const w = window as unknown as { Shiny?: { addCustomMessageHandler: (n: string, f: (m: { id: string }) => void) => void }; twMonDl?: boolean };
    if (w.twMonDl || !w.Shiny) return;
    w.twMonDl = true;
    w.Shiny.addCustomMessageHandler("tw-mon-download", (m) => document.getElementById(m.id)?.click());
  }, [ready]);
}

export function ReportTab({ t }: { t: (s: string) => string }) {
  useDownloadMessage();
  const st = useShinyOutputValue<MonState>(ns("mon_state"));
  const items = st?.items ?? [];
  return (
    <div className="tw-mon-report">
      <Card title={t("Your analysis")} icon={<PenLine size={15} />} className="tw-mon-analysis">
        <details className="tw-mon-tpl" open>
          <summary><WandSparkles size={14} /> {t("Start from a template, or build your own charts")}</summary>
          <p className="small text-muted mt-2 mb-2">{t("Fills the report with ready-made charts from the data you loaded, each with a suggested finding you can edit. Your own charts and texts are kept unless you choose to replace them.")}</p>
          <div className="d-flex gap-2 align-items-end">
            <SelectInput id={ns("tpl")} choices={[]} value="" className="flex-fill" />
            <ActionButton id={ns("tpl_apply")} label={t("Draft")} icon={<WandSparkles size={14} />} className="mb-2"
                          title={t("Fill the report with this template's charts, with findings written from the numbers")} />
          </div>
          <p className="small text-muted mb-2">{t("Share a saved template with colleagues or another office as a file (charts and figures, never the data), or import one.")}</p>
          <div className="d-flex gap-2 mb-2">
            <DownloadButton id={ns("tpl_export")} label={t("Export")} icon={<Download size={14} />} variant="outline-secondary"
                            title={t("Save the template picked above as a file")} />
            <ActionButton id={ns("tpl_delete")} icon={<Trash2 size={14} />} variant="outline-danger" title={t("Delete the saved template picked above")} />
          </div>
          <Dropzone id={ns("tpl_import_ui")} />
          {st?.rounds && <div className="small d-flex align-items-center gap-1"><Clock size={13} /> {st.rounds}</div>}
        </details>
        <RichText id={ns("context")} label={t("Context")} placeholder={t("Programme, area, period, targeting approach, who collected what.")} />
        <RichText id={ns("findings")} label={t("Key findings")} placeholder={t("What worked, what did not, where and for whom.")} />
        <RichText id={ns("recommendations")} label={t("Recommendations")} placeholder={t("What to change in the next round, and who does it.")} />
        <CheckboxInput id={ns("include_pdm")} label={t("Include the implementation errors (post-targeting survey or PDM)")} value />
        <ActionButton id={ns("report_check")} label={t("Targeting monitoring report (HTML)")} icon={<FileText size={14} />} variant="primary" size="md" className="w-100" />
        <div className="small text-muted mt-1">{t("The report is checked first (titles, comments, small groups); you can still export as it is.")}</div>
        <ActionButton id={ns("tpl_save")} label={t("Save this report as a template")} icon={<Save size={14} />} className="w-100 mt-3"
                      title={t("Keep the charts (not the data) and this round's figures; next round, pick it and click Draft")} />
        <div style={{ display: "none" }}><DownloadButton id={ns("report")} label="Download" /></div>
      </Card>

      <Card title={t("In the report")} icon={<Layers size={15} />} className="tw-mon-items-card"
            actions={items.length ? <span className="tw-mon-count">{items.length}</span> : null}>
        {!items.length
          ? <EmptyState title={t("Nothing added yet")} sub={t("Build a chart or a table on the PDM or Targeting process tab and click Add to report.")} />
          : <Items items={items} redraw={st?.redraw ?? 0} t={t} />}
      </Card>
    </div>
  );
}

function Items({ items, redraw, t }: { items: Item[]; redraw: number; t: (s: string) => string }) {
  const setAct = useSetShinyInput<Record<string, unknown> | null>(ns("item_act"), null, { debounceMs: 0, priority: "event" });
  const setOrder = useSetShinyInput<string[] | null>(ns("item_order"), null, { debounceMs: 0, priority: "event" });
  const act = (what: string, id: string) => setAct({ what, id, n: Math.random() });
  // dragged by the handle only, so the comment stays selectable
  const [grab, setGrab] = useState<string | null>(null);
  const [drag, setDrag] = useState<string | null>(null);
  const [over, setOver] = useState<string | null>(null);
  const ids = items.map((x) => x.id);
  const drop = (before: string | null) => {
    if (!drag || drag === before) return;
    const rest = ids.filter((x) => x !== drag);
    const at = before === null ? rest.length : rest.indexOf(before);
    rest.splice(at, 0, drag);
    setOrder(rest);
  };
  const end = () => { setDrag(null); setOver(null); setGrab(null); };
  return (
    <>
      <p className="small text-muted mb-2 d-flex align-items-center gap-1">
        <GripVertical size={13} /> {t("Drag an item by its handle to reorder. Two half-width items next to each other sit side by side in the report.")}
      </p>
      <div className="tw-mon-items" onDragOver={(e) => { if (drag && e.target === e.currentTarget) e.preventDefault(); }}
           onDrop={(e) => { if (e.target === e.currentTarget) { e.preventDefault(); drop(null); } end(); }}>
        {items.map((it, i) => (
          <div key={it.id} data-id={it.id} draggable={grab === it.id}
               className={`tw-mon-item${it.half ? " is-half" : ""}${drag === it.id ? " dragging" : ""}${over === it.id ? " drop-before" : ""}`}
               onDragStart={(e: DragEvent) => { setDrag(it.id); e.dataTransfer.effectAllowed = "move"; e.dataTransfer.setData("text/plain", it.id); }}
               onDragEnd={end}
               onDragOver={(e) => { if (drag && drag !== it.id) { e.preventDefault(); setOver(it.id); } }}
               onDrop={(e) => { e.preventDefault(); e.stopPropagation(); drop(it.id); end(); }}>
            <div className="tw-mon-item-head">
              <span className="tw-mon-drag" title={t("Drag to reorder")} onMouseDown={() => setGrab(it.id)} onMouseUp={() => setGrab(null)}
                    onTouchStart={() => setGrab(it.id)}><GripVertical size={15} /></span>
              <span className="tw-mon-num">{i + 1}</span>
              <div className="flex-grow-1 min-w-0">
                <div className="tw-mon-item-title">{it.title}</div>
                <div className="small text-muted">{it.source} · {it.dataset} · {it.display === "table" ? t("table") : t("chart")}</div>
              </div>
              <div className="btn-group btn-group-sm">
                <button type="button" className="btn btn-outline-secondary" onClick={() => act("width", it.id)}
                        title={it.half ? t("Make full width") : t("Make half width (side by side)")}>
                  {it.half ? <Maximize2 size={13} /> : <Columns2 size={13} />}</button>
                <button type="button" className="btn btn-outline-secondary" onClick={() => act("up", it.id)} disabled={i === 0} title={t("Move up")}><ArrowUp size={13} /></button>
                <button type="button" className="btn btn-outline-secondary" onClick={() => act("down", it.id)} disabled={i === items.length - 1} title={t("Move down")}><ArrowDown size={13} /></button>
                <button type="button" className="btn btn-outline-danger" onClick={() => act("remove", it.id)} title={t("Remove")}><X size={13} /></button>
              </div>
            </div>
            <RichText key={`${it.id}-${redraw}`} send={ns("item_comment")} item={it.id} value={it.comment} placeholder={t("Comment")} rows={2} compact />
            {it.caption && (
              <div className="tw-mon-suggest small">
                <Lightbulb size={13} /> <span className="text-muted">{t("Suggested finding:")}</span> {it.caption}{" "}
                <button type="button" className="btn btn-link btn-sm p-0 align-baseline" onClick={() => act("caption", it.id)}>{t("Use it")}</button>
              </div>
            )}
          </div>
        ))}
      </div>
    </>
  );
}
