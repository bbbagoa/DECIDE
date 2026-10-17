// Audit Trail (R/mod_audit.R, module "audit_1"): every change and decision,
// across the three phases. Quick insights first (output$audit_facts, the
// action types chart), then the table (output$tab_mod_log): a change made to
// the data in this session has an Undo button, which sends input$undo (the
// server confirms, then puts the data back as it was before the change).
import { useRef } from "react";
import { BarChart3, Download, Eraser, History, ListChecks, PencilLine, RotateCcw, Trash2 } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { DownloadButton, RadioInput } from "@/lib/inputs";
import { DataTable } from "@/lib/table";
import { Chart } from "@/lib/chart";
import { Card } from "@/lib/layout";
import { useOutputVisibility } from "@/lib/visibility";
import "./audit.css";

const ns = (id: string) => `audit_1-${id}`;
const PHASES = ["All", "Design", "Selection", "Monitoring", "Session"];
type Facts = {
  n: number; deleted?: number; edits?: number; undoable?: number; kinds?: number; last?: string;
  phases?: { phase: string; n: number }[];
} | null;
const n0 = (x?: number) => Math.round(x ?? 0).toLocaleString("en-US");
const PHASE_COL: Record<string, string> = { Design: "#8e6bbf", Selection: "#007DBC", Monitoring: "#3f7e44", Session: "#8a96a3" };

export function AuditPage({ t }: { active: boolean; t: (s: string) => string }) {
  const f = useShinyOutputValue<Facts>(ns("audit_facts"));
  const here = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("audit_facts"), here);
  const tot = Math.max(1, f?.n ?? 0);
  return (
    <div className="tw-audit p-3 w-100" ref={here}>
      {/* quick insights: what was done so far, and what can still be undone */}
      {f && f.n > 0 && (
        <div className="tw-audit-top">
          <div className="tw-audit-tiles">
            <Tile icon={<ListChecks size={17} />} tone="blue" label={t("Entries")} value={n0(f.n)} sub={`${n0(f.kinds)} ${t("kinds of action")}`} />
            <Tile icon={<Trash2 size={17} />} tone="red" label={t("Records deleted")} value={n0(f.deleted)} />
            <Tile icon={<PencilLine size={17} />} tone="amber" label={t("Values edited")} value={n0(f.edits)} />
            <Tile icon={<RotateCcw size={17} />} tone="green" label={t("Changes you can undo")} value={n0(f.undoable)}
                  sub={t("made to the data in this session")} />
            <div className="tw-audit-phases">
              <div className="tw-audit-phases-label">{t("By phase")}</div>
              <div className="tw-audit-phasebar">
                {(f.phases ?? []).filter((p) => p.n > 0).map((p) => (
                  <span key={p.phase} style={{ width: `${(100 * p.n) / tot}%`, background: PHASE_COL[p.phase] }} title={`${t(p.phase)}: ${n0(p.n)}`} />
                ))}
              </div>
              <div className="tw-audit-legend">
                {(f.phases ?? []).filter((p) => p.n > 0).map((p) => (
                  <span key={p.phase}><i style={{ background: PHASE_COL[p.phase] }} />{t(p.phase)} {n0(p.n)}</span>
                ))}
              </div>
            </div>
          </div>
          <Card title={t("Most frequent actions")} icon={<BarChart3 size={15} />} full className="tw-audit-chart">
            <Chart id={ns("audit_types_plot")} />
          </Card>
        </div>
      )}
      <Card
        title={t("Activity log")} icon={<History size={15} />}
        actions={<>
          <RadioInput id={ns("phase")} choices={PHASES.map((p) => ({ value: p, label: t(p) }))} value="All" buttons className="mb-0" />
          <DownloadButton id={ns("download_full_log")} label={t("Export")} icon={<Download size={14} />} />
        </>}
      >
        <p className="small text-muted mb-2">
          {t("Every change to the data and every decision, across the three phases: who, when, what and why.")}{" "}
          <span className="tw-audit-undo-note"><Eraser size={13} /> {t("Undo is offered on the changes made to the data in this session; work loaded from a saved session cannot be undone.")}</span>
        </p>
        <DataTable id={ns("tab_mod_log")} />
      </Card>
    </div>
  );
}

function Tile({ icon, tone, label, value, sub }: { icon: React.ReactNode; tone: string; label: string; value: string; sub?: string }) {
  return (
    <div className={`tw-audit-tile tone-${tone}`}>
      <span className="tw-audit-tile-icon">{icon}</span>
      <div className="min-w-0">
        <div className="tw-audit-tile-label">{label}</div>
        <div className="tw-audit-tile-value">{value}</div>
        {sub && <div className="tw-audit-tile-sub">{sub}</div>}
      </div>
    </div>
  );
}
