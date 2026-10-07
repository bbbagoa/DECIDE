// Audit Trail (R/mod_audit.R, module "audit_1"): every change and decision,
// across the three phases. The server code is the Shiny page's: the phase
// buttons are input$phase, the table output$tab_mod_log (render_react_table),
// the export output$download_full_log.
import { Download, History } from "lucide-react";
import { DownloadButton, RadioInput } from "@/lib/inputs";
import { DataTable } from "@/lib/table";
import { Card } from "@/lib/layout";

const ns = (id: string) => `audit_1-${id}`;
const PHASES = ["All", "Design", "Selection", "Monitoring", "Session"];

export function AuditPage({ t }: { active: boolean; t: (s: string) => string }) {
  return (
    <div className="tw-audit p-3 w-100">
      <Card
        title={t("Audit trail")} icon={<History size={15} />}
        actions={<>
          <RadioInput id={ns("phase")} choices={PHASES.map((p) => ({ value: p, label: t(p) }))} value="All" buttons className="mb-0" />
          <DownloadButton id={ns("download_full_log")} label={t("Export")} icon={<Download size={14} />} />
        </>}
      >
        <p className="small text-muted mb-2">{t("Every change to the data and every decision, across the three phases: who, when, what and why.")}</p>
        <DataTable id={ns("tab_mod_log")} />
      </Card>
    </div>
  );
}
