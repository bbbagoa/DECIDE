// Health check (R/mod_dq_health.R): light data is checked as soon as the tab
// opens (and again after every correction); heavy data waits for the Run
// button, shown on the left. Left: the health score and the figures; right:
// one row per check (Review sets input$hc_go and the server opens that tab),
// then three quick charts.
import { useRef } from "react";
import { BarChart3, CalendarDays, CircleCheck, CircleMinus, HeartPulse, MapPin, Play, TriangleAlert } from "lucide-react";
import { useSetShinyInput, useShinyOutputStatus, useShinyOutputValue } from "@/shiny";
import { ActionButton } from "@/lib/inputs";
import { Busy, Card } from "@/lib/layout";
import { Chart } from "@/lib/chart";
import { EmptyState, Ring } from "@/components/Figures";
import { useOutputVisibility } from "@/lib/visibility";
import { ns, type T } from "./common";

type Row = { check: string; tab: string; found: string; status: "ok" | "review" | "na" };
type Result = {
  auto: boolean; records: number; variables: number;
  rows?: Row[]; n?: number; at?: string; completeness?: number; dup_share?: number | null; incomplete?: number;
} | null;

const ICON = { ok: <CircleCheck size={18} />, review: <TriangleAlert size={18} />, na: <CircleMinus size={18} /> };
const PILL = { ok: ["tw-pill-ok", "OK"], review: ["tw-pill-review", "Review"], na: ["tw-pill-na", "Not checked"] } as const;
const n0 = (x?: number) => Math.round(x ?? 0).toLocaleString("en-US");
const p1 = (x?: number | null) => (x == null || !isFinite(x) ? "—" : `${(100 * x).toFixed(1).replace(/\.0$/, "")}%`);

export function HealthTab({ t }: { t: T }) {
  const box = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("hc_table"), box);
  const res = useShinyOutputValue<Result>(ns("hc_table"));
  const status = useShinyOutputStatus(ns("hc_table"));
  const go = useSetShinyInput<string | null>(ns("hc_go"), null, { debounceMs: 0, priority: "event" });
  const rows = res?.rows ?? [];
  const count = (s: Row["status"]) => rows.filter((r) => r.status === s).length;
  const judged = count("ok") + count("review");
  const score = judged ? count("ok") / judged : 0;
  const ran = rows.length > 0;
  return (
    <div ref={box} className="tw-hc-page">
    <Busy show={status === "recalculating"} label={t("Checking the data...")} />
    <div className="tw-hc-layout">
      {/* left: the score, the figures, and the button when the data is heavy */}
      <aside className="tw-hc-side">
        <div className="card tw-card"><div className="card-body">
          <div className="tw-hc-side-title"><HeartPulse size={16} /> {t("Health of the data in scope")}</div>
          {ran
            ? <div className="tw-hc-score"><Ring tile={{ label: t("Checks passed"), value: `${count("ok")}/${judged}`, share: score }} /></div>
            : null}
          {res && !res.auto && (
            <div className="tw-hc-run">
              {!ran && <p className="small text-muted mb-2">
                {t("Large data")} ({n0(res.records)} {t("records")} &times; {n0(res.variables)} {t("variables")}): {t("the check runs when you ask for it.")}
              </p>}
              <ActionButton id={ns("hc_run")} label={ran ? t("Run again") : t("Run the health check")} icon={<Play size={14} />}
                            variant={ran ? "outline-primary" : "primary"} className="w-100" />
            </div>
          )}
          {res?.auto && ran && <div className="tw-hc-auto"><CircleCheck size={13} /> {t("Checked automatically")} &middot; {res.at}</div>}
          {ran && (
            <dl className="tw-hc-figs">
              <div><dt>{t("Records")}</dt><dd>{n0(res?.n)}</dd></div>
              <div><dt>{t("Variables")}</dt><dd>{n0(res?.variables)}</dd></div>
              <div><dt>{t("Answers filled in")}</dt><dd className={(res?.completeness ?? 1) < 0.9 ? "warn" : ""}>{p1(res?.completeness)}</dd></div>
              <div><dt>{t("Columns over 10% missing")}</dt><dd className={res?.incomplete ? "warn" : ""}>{n0(res?.incomplete)}</dd></div>
              <div><dt>{t("Records sharing an ID")}</dt><dd className={res?.dup_share ? "warn" : ""}>{p1(res?.dup_share)}</dd></div>
            </dl>
          )}
        </div></div>
      </aside>

      {/* right: the checks, then the quick charts */}
      <div className="tw-hc-main">
        <Card title={t("Checks")} icon={<HeartPulse size={15} />}
              actions={ran ? <div className="tw-hc-summary m-0">
                <span className="tw-pill tw-pill-review">{count("review")} {t("to review")}</span>
                <span className="tw-pill tw-pill-ok">{count("ok")} OK</span>
                {count("na") > 0 && <span className="tw-pill tw-pill-na">{count("na")} {t("not checked")}</span>}
              </div> : undefined}>
          {!ran ? (
            res && !res.auto
              ? <EmptyState title={t("Not run yet")} sub={t("Click Run the health check on the left to see what needs attention.")} />
              : <EmptyState title={t("Checking the data...")} sub={t("Load and map the data first if nothing shows.")} />
          ) : (
            <>
              <div className="tw-hc" role="table">
                {rows.map((r) => (
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
                {t("Review opens the tab with the detail and the corrections; the Data quality report (sidebar) records everything.")}
              </div>
            </>
          )}
        </Card>
      </div>
    </div>
    {/* the quick charts: the full width, a third each */}
    {ran && (
          <div className="tw-hc-charts">
            <Card title={t("Missing answers by column")} icon={<BarChart3 size={15} />} full><Chart id={ns("hc_missing_plot")} /></Card>
            <Card title={t("Records by area")} icon={<MapPin size={15} />} full><Chart id={ns("hc_area_plot")} /></Card>
            <Card title={t("Interviews per day")} icon={<CalendarDays size={15} />} full><Chart id={ns("hc_daily_plot")} /></Card>
          </div>
        )}
    </div>
  );
}
