// The Advisory's verdict as a status panel (R: verdict_card(); its facts come
// from verdict_facts()): a household in the verdict's colour, the status
// badge, the Advisory's wording, the two errors against the tolerance band.
// It fades in only when the verdict changes. Styled by www/wfp-ui.css (.wfp-verdict).
import { useEffect, useRef, type ReactNode } from "react";
import { House } from "lucide-react";

export type VerdictFacts = {
  level: string; invalid?: boolean; stage?: string; interpretation: string; action: string;
  inclusion?: number | null; exclusion?: number | null; lower?: number | null; upper?: number | null;
};

const isNum = (x: unknown): x is number => typeof x === "number" && isFinite(x);

export function verdictStatus(v: VerdictFacts): string {
  const lvl = ["good", "review", "redesign"].includes(v.level) ? v.level : "unknown";
  if (lvl === "redesign") return v.stage === "implementation" ? "Corrective action required" : "Redesign required";
  return { good: "Within tolerance", review: "Review recommended", unknown: v.invalid ? "Tolerance not valid" : "Not enough data" }[lvl as "good"];
}

export function VerdictCard({ v, t, labels, children }: {
  v: VerdictFacts; t: (s: string) => string;
  /** the errors' names (default: Inclusion error / Exclusion error) */
  labels?: { inclusion: string; exclusion: string };
  /** notes under the action */
  children?: ReactNode;
}) {
  const lvl = ["good", "review", "redesign"].includes(v.level) ? v.level : "unknown";
  const seen = useRef<string | null>(null);
  const animate = seen.current !== lvl;
  useEffect(() => { seen.current = lvl; }, [lvl]);
  const band = isNum(v.lower) && isNum(v.upper);
  const chip = (label: string, x: number | null | undefined) => {
    if (!isNum(x)) return null;
    const cls = !band ? "" : x <= (v.lower as number) ? "is-ok" : x <= (v.upper as number) ? "is-mid" : "is-bad";
    return (
      <div className={`vd-metric ${cls}`}>
        <span className="vd-metric-label">{label}</span>
        <span className="vd-metric-value">{(100 * x).toFixed(1)}%</span>
        {band && <span className="vd-metric-tol">{t("good")} {"≤"} {Math.round(100 * (v.lower as number))}% {"·"} {t("limit")} {"≤"} {Math.round(100 * (v.upper as number))}%</span>}
      </div>
    );
  };
  const hasErr = isNum(v.inclusion) || isNum(v.exclusion);
  return (
    <div className={`wfp-verdict is-${lvl}${animate ? "" : " no-anim"}`} role="status" key={lvl}>
      <div className="vd-icon"><House size={30} strokeWidth={2.2} /></div>
      <div className="vd-text">
        <div className="vd-head"><span className="vd-status">{t(verdictStatus(v))}</span></div>
        <div className="vd-interp">{t(v.interpretation)}</div>
        <div className="vd-action"><strong>{t("Recommended action:")} </strong>{t(v.action)}</div>
        {hasErr && (
          <div className="vd-metrics">
            {chip(labels?.inclusion ?? t("Inclusion error"), v.inclusion)}
            {chip(labels?.exclusion ?? t("Exclusion error"), v.exclusion)}
          </div>
        )}
        {children}
      </div>
    </div>
  );
}
