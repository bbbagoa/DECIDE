// Health check (R/mod_dq_health.R): one row per check, run on its button;
// Review sets input$hc_go and the server opens that tab (nav_select).
import { CircleCheck, CircleMinus, HeartPulse, Play, TriangleAlert } from "lucide-react";
import { useSetShinyInput, useShinyOutputValue } from "@/shiny";
import { ActionButton } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { EmptyState } from "@/components/Figures";
import { ns, type T } from "./common";

type Row = { check: string; tab: string; found: string; status: "ok" | "review" | "na" };
type Result = { rows: Row[]; n: number; at: string };

const ICON = { ok: <CircleCheck size={18} />, review: <TriangleAlert size={18} />, na: <CircleMinus size={18} /> };
const PILL = { ok: ["tw-pill-ok", "OK"], review: ["tw-pill-review", "Review"], na: ["tw-pill-na", "Not checked"] } as const;

export function HealthTab({ t }: { t: T }) {
  const res = useShinyOutputValue<Result | null>(ns("hc_table"));
  const go = useSetShinyInput<string | null>(ns("hc_go"), null, { debounceMs: 0, priority: "event" });
  const count = (s: Row["status"]) => res?.rows.filter((r) => r.status === s).length ?? 0;
  return (
    <Card title={t("Health check of the data in scope")} icon={<HeartPulse size={15} />}
          actions={<ActionButton id={ns("hc_run")} label={res ? t("Run again") : t("Run the health check")} icon={<Play size={13} />} variant="primary" />}>
      <p className="tw-dq-note">
        {t("A quick pass with the rules of each tab. Review opens the tab with the detail and the corrections; the Data quality report (sidebar) records everything.")}
      </p>
      {!res ? (
        <EmptyState title={t("Not run yet")} sub={t("Click Run the health check to see what needs attention.")} />
      ) : (
        <>
          <div className="tw-hc-summary">
            <span className="tw-pill tw-pill-review">{count("review")} {t("to review")}</span>
            <span className="tw-pill tw-pill-ok">{count("ok")} OK</span>
            {count("na") > 0 && <span className="tw-pill tw-pill-na">{count("na")} {t("not checked")}</span>}
          </div>
          <div className="tw-hc" role="table">
            {res.rows.map((r) => (
              <div key={r.check} className={`tw-hc-row ${r.status}`} role="row">
                <span className={`tw-hc-icon ${r.status}`} aria-hidden>{ICON[r.status]}</span>
                <span className="tw-hc-check">{t(r.check)}</span>
                <span className="tw-hc-found">{r.found}</span>
                <span className={`tw-pill ${PILL[r.status][0]}`}>{t(PILL[r.status][1])}</span>
                <button type="button" className={`btn btn-sm ${r.status === "review" ? "btn-outline-primary" : "btn-outline-secondary"}`}
                        onClick={() => go(r.tab)}>{t("Review")}</button>
              </div>
            ))}
          </div>
          <div className="tw-hc-foot">
            {t("Checked on")} {res.n.toLocaleString("en-US")} {t("records")}, {res.at}. {t("Run it again after corrections.")}
          </div>
        </>
      )}
    </Card>
  );
}
