// Data summary (R/mod_data_summary.R), for any uploaded dataset.
//
//   <DataSummary ns="scorecard_1-summary" t={t} />
//
// Props
//   ns        the module id (button `${ns}-open`, outputs `${ns}-summary`, `${ns}-download`)
//   label     button text (default "Data summary")
//   variant   button style (default "outline-secondary")
//   block     full width (default false)
//   className extra class on the button
//   t         translator (optional)
//
// The button asks the server for a summary of the data as it is now; the
// dialog lists every variable: its type, missing values, its categories (with
// bars) or its distribution (a small histogram and the five numbers), and
// exports the same to Excel.
import { useMemo, useState } from "react";
import { BarChart3, Calendar, Fingerprint, Hash, ListChecks, Search, TableProperties, Type } from "lucide-react";
import { useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, DownloadButton } from "@/lib/inputs";
import { Dialog } from "@/lib/layout";
import "./data-summary.css";

type Level = { value: string; n: number };
type Hist = { edges: (number | string)[]; counts: number[]; date: boolean };
type Var = {
  name: string; label?: string | null; kind: "category" | "number" | "date" | "text" | "id" | "empty";
  missing: number; missing_pct: number; distinct: number;
  levels?: Level[]; other?: number; top?: Level[]; range?: string[]; hist?: Hist;
  stats?: { min: number; q1: number; median: number; mean: number; q3: number; max: number; sd: number | null };
};
type Summary = { empty: boolean; title: string; at: number; rows?: number; cols?: number; vars?: Var[] };
type Variant = Parameters<typeof ActionButton>[0]["variant"];

const KINDS: { key: Var["kind"]; label: string; one: string; Icon: typeof Hash }[] = [
  { key: "category", label: "Categories", one: "Category", Icon: ListChecks },
  { key: "number", label: "Numbers", one: "Number", Icon: Hash },
  { key: "date", label: "Dates", one: "Date", Icon: Calendar },
  { key: "text", label: "Text", one: "Text", Icon: Type },
  { key: "id", label: "Identifiers", one: "Identifier", Icon: Fingerprint },
  { key: "empty", label: "Empty", one: "Empty", Icon: TableProperties },
];
const PAGE = 40;
const fmt = (x: number | null | undefined, d = 2) => (x === null || x === undefined || !isFinite(x) ? "–" :
  Math.abs(x) >= 1000 ? Math.round(x).toLocaleString("en-US") : Number(x.toFixed(d)).toLocaleString("en-US"));
const pct = (x: number) => `${(100 * x).toFixed(x > 0 && x < 0.01 ? 1 : 0)}%`;

export function DataSummary({ ns, label = "Data summary", variant = "outline-secondary", block, className, t = (s) => s }: {
  ns: string; label?: string; variant?: Variant; block?: boolean; className?: string; t?: (s: string) => string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <ActionButton id={`${ns}-open`} label={t(label)} icon={<BarChart3 size={15} />} variant={variant}
                    className={[block ? "w-100" : "", className ?? ""].join(" ").trim() || undefined}
                    title={t("Every variable: its type, missing values, categories or distribution")} onClick={() => setOpen(true)} />
      {open && <SummaryDialog ns={ns} t={t} onClose={() => setOpen(false)} />}
    </>
  );
}

function SummaryDialog({ ns, t, onClose }: { ns: string; t: (s: string) => string; onClose: () => void }) {
  const s = useShinyOutputValue<Summary>(`${ns}-summary`);
  const clicks = useShinyInputValue<number>(`${ns}-open`) ?? 0;
  const [q, setQ] = useState("");
  const [kind, setKind] = useState<Var["kind"] | "all">("all");
  const [shown, setShown] = useState(PAGE);
  const ready = !!s && s.at === clicks;
  const vars = useMemo(() => {
    const x = q.trim().toLowerCase();
    return (s?.vars ?? []).filter((v) => (kind === "all" || v.kind === kind) &&
      (!x || v.name.toLowerCase().includes(x) || (v.label ?? "").toLowerCase().includes(x)));
  }, [s, q, kind]);
  const count = (k: Var["kind"]) => (s?.vars ?? []).filter((v) => v.kind === k).length;
  return (
    <Dialog open onClose={onClose} size="xl"
            title={<><BarChart3 size={18} /> {t("Data summary")}{ready && s?.title ? <span className="tw-ds-sub"> {"·"} {t(s.title)}</span> : null}</>}
            footer={<>
              <DownloadButton id={`${ns}-download`} label={t("Export (Excel)")} />
              <button type="button" className="btn btn-outline-secondary btn-sm" onClick={onClose}>{t("Close")}</button>
            </>}>
      {!ready ? (
        <div className="tw-ds-wait"><span className="spinner-border spinner-border-sm" /> {t("Summarising the data...")}</div>
      ) : s!.empty ? (
        <div className="tw-ds-wait">{t("No data loaded yet.")}</div>
      ) : (
        <>
          <div className="tw-ds-head">
            <span className="tw-ds-size"><strong>{(s!.rows ?? 0).toLocaleString("en-US")}</strong> {t("rows")} {"·"} <strong>{s!.cols}</strong> {t("variables")}</span>
            <div className="tw-ds-chips" role="group" aria-label={t("Type")}>
              <button type="button" className={`tw-ds-chip${kind === "all" ? " on" : ""}`} onClick={() => { setKind("all"); setShown(PAGE); }}>{t("All")} {s!.cols}</button>
              {KINDS.filter((k) => count(k.key) > 0).map((k) => (
                <button key={k.key} type="button" className={`tw-ds-chip${kind === k.key ? " on" : ""}`} onClick={() => { setKind(k.key); setShown(PAGE); }}>
                  <k.Icon size={12} /> {t(k.label)} {count(k.key)}
                </button>
              ))}
            </div>
            <label className="tw-search">
              <Search size={13} />
              <input type="search" className="form-control form-control-sm" placeholder={t("Find a variable")} value={q}
                     onChange={(e) => { setQ(e.target.value); setShown(PAGE); }} />
            </label>
          </div>
          {!vars.length ? <div className="tw-ds-wait">{t("No variable matches.")}</div> : (
            <div className="tw-ds-grid">
              {vars.slice(0, shown).map((v) => <VarCard key={v.name} v={v} rows={s!.rows ?? 0} t={t} />)}
            </div>
          )}
          {vars.length > shown && (
            <div className="text-center mt-2">
              <button type="button" className="btn btn-outline-secondary btn-sm" onClick={() => setShown(shown + PAGE)}>
                {t("Show more")} ({vars.length - shown})
              </button>
            </div>
          )}
        </>
      )}
    </Dialog>
  );
}

function VarCard({ v, rows, t }: { v: Var; rows: number; t: (s: string) => string }) {
  const k = KINDS.find((x) => x.key === v.kind)!;
  const ok = rows - v.missing;
  return (
    <div className={`tw-ds-card kind-${v.kind}`}>
      <div className="tw-ds-card-head">
        <div className="tw-ds-name">
          <span className="tw-ds-var" title={v.name}>{v.name}</span>
          {v.label ? <span className="tw-ds-label" title={v.label}>{v.label}</span> : null}
        </div>
        <span className="tw-ds-kind"><k.Icon size={11} /> {t(k.one)}</span>
      </div>
      <div className="tw-ds-meta">
        <span title={t("Missing values")}>
          <span className={`tw-ds-miss${v.missing_pct > 0.2 ? " high" : v.missing_pct > 0.05 ? " mid" : ""}`}>
            <span style={{ width: `${Math.min(100, 100 * v.missing_pct)}%` }} />
          </span>
          {v.missing ? `${pct(v.missing_pct)} ${t("missing")}` : t("no missing value")}
        </span>
        {v.kind !== "empty" && <span>{v.distinct.toLocaleString("en-US")} {t("distinct")}</span>}
      </div>
      {v.kind === "category" && v.levels && (
        <div className="tw-ds-levels">
          {v.levels.map((l) => (
            <div key={l.value} className="tw-ds-level" title={`${l.value}: ${l.n.toLocaleString("en-US")} (${pct(ok ? l.n / ok : 0)})`}>
              <span className="tw-ds-lv">{l.value}</span>
              <span className="tw-ds-bar"><span style={{ width: `${ok ? (100 * l.n) / ok : 0}%` }} /></span>
              <span className="tw-ds-n">{pct(ok ? l.n / ok : 0)}</span>
            </div>
          ))}
          {v.other ? <div className="tw-ds-other">{t("Other values")}: {v.other.toLocaleString("en-US")} ({pct(ok ? v.other / ok : 0)})</div> : null}
        </div>
      )}
      {(v.kind === "number" || v.kind === "date") && v.hist && <Spark h={v.hist} />}
      {v.kind === "number" && v.stats && (
        <div className="tw-ds-stats">
          <span><em>{t("min")}</em> {fmt(v.stats.min)}</span><span><em>{t("median")}</em> {fmt(v.stats.median)}</span>
          <span><em>{t("mean")}</em> {fmt(v.stats.mean)}</span><span><em>{t("max")}</em> {fmt(v.stats.max)}</span>
          <span><em>{t("SD")}</em> {fmt(v.stats.sd ?? null)}</span>
        </div>
      )}
      {v.kind === "date" && v.range && (
        <div className="tw-ds-stats"><span><em>{t("from")}</em> {dmy(v.range[0])}</span><span><em>{t("to")}</em> {dmy(v.range[1])}</span></div>
      )}
      {(v.kind === "text" || v.kind === "id") && v.top && (
        <div className="tw-ds-top">
          <span className="text-muted">{v.kind === "id" ? t("Nearly every value differs, e.g.") : t("Most frequent")}:</span>{" "}
          {v.top.map((l) => `${l.value}${v.kind === "text" ? ` (${l.n.toLocaleString("en-US")})` : ""}`).join(", ")}
        </div>
      )}
      {v.kind === "empty" && <div className="tw-ds-top text-muted">{t("No value in any row.")}</div>}
    </div>
  );
}

const dmy = (iso: string) => { const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso); return m ? `${m[3]}/${m[2]}/${m[1]}` : iso; };

/** A small histogram: one bar per bin, its range on hover. */
function Spark({ h }: { h: Hist }) {
  const max = Math.max(1, ...h.counts);
  const n = h.counts.length;
  const lab = (i: number) => (h.date ? `${dmy(String(h.edges[i]))} – ${dmy(String(h.edges[i + 1] ?? h.edges[i]))}`
    : `${fmt(Number(h.edges[i]))} – ${fmt(Number(h.edges[i + 1] ?? h.edges[i]))}`);
  return (
    <svg className="tw-ds-spark" viewBox={`0 0 ${n * 10} 40`} preserveAspectRatio="none" role="img" aria-label="Distribution">
      {h.counts.map((c, i) => (
        <rect key={i} x={i * 10 + 1} width={8} y={40 - (38 * c) / max} height={(38 * c) / max}>
          <title>{`${lab(i)}: ${c.toLocaleString("en-US")}`}</title>
        </rect>
      ))}
    </svg>
  );
}

export default DataSummary;
