// Pieces shared by the Targeting Design steps: ids, hover tips, chart cards
// with their help, gates, step footers, an always-mounted dialog, and inputs
// that sit in table rows and take the server's values each time it redraws
// the table (as the Shiny page's renderUI did).
import { Component, useEffect, useRef, useState, type CSSProperties, type ReactNode } from "react";
import { createPortal } from "react-dom";
import { ArrowLeft, ArrowRight, Check, CircleCheck, Info, Lock, X } from "lucide-react";
import { useShinyInput } from "@/shiny";
import { ActionButton, useServerUpdates } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { Chart, FORMATTERS } from "@/lib/chart";
import type { HelpEntry, Meta, NavStep } from "./types";
import "./design.css";

export const NS = "scorecard_1-";
export const ns = (id: string) => NS + id;
export type T = (s: string) => string;

/* ------------------------------------------------------------ formats */

const val = (x: unknown): number => {
  if (typeof x === "number") return x;
  if (x && typeof x === "object") {
    const v = (x as { value?: unknown }).value;
    if (Array.isArray(v)) return Number(v[v.length - 1]);
    return val(v);
  }
  return Number(x);
};
// Chart formatters the server's options name (R/utils_scorecard_echarts.R)
FORMATTERS.pctv = (x) => { const n = val(x); return isFinite(n) ? `${Math.round(n)}%` : ""; };
FORMATTERS.abspctv = (x) => { const n = val(x); return isFinite(n) ? `${Math.round(Math.abs(n))}%` : ""; };

export const isNum = (x: unknown): x is number => typeof x === "number" && isFinite(x);
export const pct0 = (x: number | null | undefined) => (isNum(x) ? `${Math.round(100 * x)}%` : "–");
export const pct1 = (x: number | null | undefined) => (isNum(x) ? `${(100 * x).toFixed(1)}%` : "n/a");
export const int = (x: number | null | undefined) => (isNum(x) ? Math.round(x).toLocaleString("en-US") : "–");
/** up to 5 decimals, no trailing zeros (fmt5() in R) */
export const fmt5 = (x: number | null | undefined) => (isNum(x) ? String(Math.round(x * 1e5) / 1e5) : "–");
/** a ratio: 4 decimals at most, huge or tiny ones as bounds (fmt_ratio() in R) */
export const ratio = (x: number | null | undefined) => {
  if (!isNum(x)) return "–";
  if (x > 9999) return "> 9999";
  if (x > 0 && x < 0.0001) return "< 0.0001";
  return String(Math.round(x * 1e4) / 1e4);
};
/** p-values as the app shows them, with their significance band */
export const pLevel = (p: number | null) => (!isNum(p) ? "na" : p < 0.001 ? "p001" : p < 0.01 ? "p01" : p < 0.05 ? "p05" : p < 0.1 ? "p10" : "ns");
export function PPill({ p }: { p: number | null }) {
  return <span className={`wfp-p wfp-p-${pLevel(p)}`}>{!isNum(p) ? "-" : p < 0.001 ? "<0.001" : p.toFixed(3)}</span>;
}
export function PLegend({ t }: { t: T }) {
  return (
    <div className="wfp-p-legend small text-muted">
      {t("p-value:")} <span className="wfp-p wfp-p-p001">&lt;0.001</span><span className="wfp-p wfp-p-p01">&lt;0.01</span>
      <span className="wfp-p wfp-p-p05">&lt;0.05</span><span className="wfp-p wfp-p-p10">&lt;0.10</span><span className="wfp-p wfp-p-ns">{"≥"}0.10</span>
    </div>
  );
}
export function DirBadge({ d, t }: { d: string | null; t: T }) {
  if (!d) return <span className="text-muted">-</span>;
  const incl = d === "inclusion";
  return <span className={`wfp-dir ${incl ? "is-incl" : "is-excl"}`} title={t(d)}>{incl ? t("Incl") : t("Excl")}</span>;
}
/** Odds ratio with its interval as a small whisker on a log scale (0.1 left, 10 right) */
export function OrCell({ or, lo, hi }: { or: number | null; lo: number | null; hi: number | null }) {
  if (!isNum(or)) return <span className="text-muted">-</span>;
  const pos = (x: number) => (100 * (Math.min(Math.max(Math.log10(x), -1), 1) + 1)) / 2;
  return (
    <div className="wfp-or">
      <div className="wfp-or-num"><strong>{ratio(or)}</strong>{isNum(lo) && isNum(hi) ? <span className="wfp-or-ci"> ({ratio(lo)}{"–"}{ratio(hi)})</span> : null}</div>
      <div className={`wfp-or-track ${or >= 1 ? "is-incl" : "is-excl"}`}>
        <span className="wfp-or-one" />
        {isNum(lo) && isNum(hi) ? <span className="wfp-or-whisker" style={{ left: `${pos(lo).toFixed(1)}%`, width: `${Math.max(pos(hi) - pos(lo), 0.5).toFixed(1)}%` }} /> : null}
        <span className="wfp-or-dot" style={{ left: `${pos(or).toFixed(1)}%` }} />
      </div>
    </div>
  );
}

/* ------------------------------------------------------------- showing */

/**
 * Shown or hidden, never unmounted: an action button that mounted again
 * would send its count again, and the server would run its action again.
 */
export function Show({ when, children, as = "div", className, style }: {
  when: boolean; children: ReactNode; as?: "div" | "span"; className?: string; style?: CSSProperties;
}) {
  const El = as;
  return <El className={className ?? (as === "div" ? "sc-stack" : undefined)} style={when ? style : { ...style, display: "none" }}>{children}</El>;
}

/** An info icon; the text shows on hover or focus, above everything (portal). */
export function Tip({ children, label = "More information", className }: { children: ReactNode; label?: string; className?: string }) {
  const ref = useRef<HTMLSpanElement>(null);
  const [at, setAt] = useState<{ x: number; y: number; below: boolean } | null>(null);
  const show = () => {
    const r = ref.current?.getBoundingClientRect();
    if (r) setAt({ x: Math.min(Math.max(r.left + r.width / 2, 170), window.innerWidth - 170), y: r.top > 220 ? r.top - 6 : r.bottom + 6, below: r.top <= 220 });
  };
  return (
    <span ref={ref} className={`sc-tip${className ? " " + className : ""}`} tabIndex={0} aria-label={label} role="button"
          onMouseEnter={show} onMouseLeave={() => setAt(null)} onFocus={show} onBlur={() => setAt(null)}
          onClick={(e) => e.stopPropagation()}>
      <Info size={13} />
      {at ? createPortal(
        <div className={`sc-tip-pop${at.below ? " below" : ""}`} style={{ left: at.x, top: at.y }} role="tooltip">{children}</div>,
        document.body) : null}
    </span>
  );
}

/** A tip body: a title, then items with a reference each */
export function TipList({ title, items }: { title?: string; items: { name?: string; text: string; ref?: string }[] }) {
  return (
    <div className="sc-tip-list">
      {title ? <div className="sc-tip-title">{title}</div> : null}
      {items.map((it, i) => (
        <div key={i} className="sc-tip-item">
          {it.name ? <strong>{it.name} </strong> : null}{it.text}
          {it.ref ? <div className="sc-tip-ref">{it.ref}</div> : null}
        </div>
      ))}
    </div>
  );
}

/** What a chart shows and how to read it (CHART_HELP in R/utils_chart_help.R) */
export function ChartHelp({ id, meta, t }: { id: string; meta?: Meta | null; t: T }) {
  const h: HelpEntry | undefined = meta?.help?.[id];
  if (!h) return null;
  return (
    <Tip label={t("About this chart")}>
      <TipList title={t("About this chart")} items={[{ name: t("What it shows."), text: t(h.shows) }, { name: t("How to read it."), text: t(h.read) }]} />
    </Tip>
  );
}

/** A chart in a card with an expand corner and its help */
export function ChartCard({ id, title, icon, height = 380, meta, t, actions, className, children }: {
  id: string; title: ReactNode; icon?: ReactNode; height?: number; meta?: Meta | null; t: T; actions?: ReactNode; className?: string; children?: ReactNode;
}) {
  return (
    <Card title={title} icon={icon} full help={<ChartHelp id={id} meta={meta} t={t} />} actions={actions} className={className}>
      {children}
      <Chart id={ns(id)} height={height} />
    </Card>
  );
}

/** A chart with a small title line (inside a card that holds two) */
export function ChartPane({ id, title, height = 420, meta, t }: { id: string; title: string; height?: number; meta?: Meta | null; t: T }) {
  return (
    <div className="sc-pane">
      <div className="sc-pane-title">{title} <ChartHelp id={id} meta={meta} t={t} /></div>
      <Chart id={ns(id)} height={height} />
    </div>
  );
}

/* ------------------------------------------------- gates and footers */

/** What replaces a step whose prerequisite is missing, with the way back */
export function Gate({ show, text, btn, label }: { show: boolean; text: string; btn: string; label: string }) {
  return (
    <Show when={show}>
      <div className="sc-gate" role="status">
        <span className="sc-gate-icon"><Lock size={18} /></span>
        <div className="sc-gate-text">{text}</div>
        <ActionButton id={ns(btn)} label={label} icon={<ArrowLeft size={14} />} variant="outline-primary" />
      </div>
    </Show>
  );
}

/** Every step ends the same way: back, what the step achieved, continue */
export function StepNav({ back, backLabel, nav, next, nextLabel, nextIcon, t, after }: {
  back?: string; backLabel?: string; nav?: NavStep; next: string; nextLabel: string; nextIcon?: ReactNode; t: T; after?: ReactNode;
}) {
  const ok = !!nav?.ok;
  return (
    <div className="sc-stepnav">
      {back ? <ActionButton id={ns(back)} label={backLabel} icon={<ArrowLeft size={14} />} variant="outline-secondary" /> : <span />}
      <div className={`sc-stepnav-status${ok ? " ok" : ""}`}>
        {ok ? <CircleCheck size={15} /> : <Info size={15} />} <span>{ok ? t(nav?.done ?? "") : t(nav?.todo ?? "")}</span>
      </div>
      {after}
      <ActionButton id={ns(next)} label={nextLabel} icon={nextIcon ?? <ArrowRight size={14} />} variant={ok ? "primary" : "outline-secondary"}
                    disabled={!ok} className="sc-stepnav-next" />
    </div>
  );
}

/** A note that a setting waits for its button */
export function Pending({ show, children }: { show: boolean; children: ReactNode }) {
  return show ? <div className="sc-pending">{children}</div> : null;
}

/* -------------------------------------------------------------- dialogs */

/**
 * A dialog that stays in the page while closed (hidden), so the inputs in
 * it keep their bindings: session restores and update*Input() reach them.
 */
export function KeepDialog({ open, onClose, title, children, footer }: {
  open: boolean; onClose: () => void; title: ReactNode; children: ReactNode; footer?: ReactNode;
}) {
  useEffect(() => {
    if (!open) return;
    const k = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    document.addEventListener("keydown", k);
    return () => document.removeEventListener("keydown", k);
  }, [open, onClose]);
  return createPortal(
    <div className="tw-dialog-backdrop sc-keep-dialog" style={{ display: open ? "flex" : "none" }}
         onMouseDown={(e) => { if (e.target === e.currentTarget) onClose(); }}>
      <div className="modal-dialog tw-dialog" role="dialog" aria-modal="true" style={{ maxWidth: 560 }}>
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">{title}</h5>
            <button type="button" className="btn-close" onClick={onClose} aria-label="Close"><X size={0} /></button>
          </div>
          <div className="modal-body">{children}</div>
          {footer ? <div className="modal-footer">{footer}</div> : null}
        </div>
      </div>
    </div>,
    document.body,
  );
}

/* ------------------------------------------------------ inputs in rows */

/**
 * An input in a table row (Use tick, points). Each time the server sends the
 * table again (a new `stamp`) the input takes the value sent, as the Shiny
 * page's redraw did; update*Input() from the server reaches it too.
 */
export function useRowInput<V>(id: string, value: V, stamp: number, type?: string): [V, (v: V) => void] {
  const [v, setV] = useShinyInput<V>(id, value, { debounceMs: 0, type });
  useServerUpdates(id, (u) => {
    if (u.value === undefined) return;
    if (typeof value === "boolean") setV(!!u.value as V);
    else setV((u.value === null || u.value === "" ? null : Number(u.value)) as V);
  });
  useEffect(() => { setV(value); }, [stamp]); // eslint-disable-line
  return [v, setV];
}

export function UseTick({ id, value, stamp, label }: { id: string; value: boolean; stamp: number; label: string }) {
  const [v, setV] = useRowInput<boolean>(ns(id), value, stamp);
  return <input type="checkbox" className="form-check-input sc-tick" checked={!!v} aria-label={label} onChange={(e) => setV(e.target.checked)} />;
}

/** The Done icon shown where the Shiny page had a check mark */
export const Done = () => <Check size={14} />;

/** Send an event input, as the Shiny page's onclick did */
export function sendEvent(id: string, value: unknown) {
  const S = (window as unknown as { Shiny?: { setInputValue: (id: string, v: unknown, o?: { priority: string }) => void } }).Shiny;
  S?.setInputValue(id, value, { priority: "event" });
}

/**
 * A step that fails to draw says so and leaves the rest of the app working.
 * No retry: drawing it again would mount its buttons again, and a button
 * that mounts sends its count, which the server would take as a click.
 */
export class Boundary extends Component<{ children: ReactNode; t: T }, { err: Error | null }> {
  state = { err: null as Error | null };
  static getDerivedStateFromError(err: Error) { return { err }; }
  render() {
    if (!this.state.err) return this.props.children;
    return (
      <div className="tw-notice tw-notice-danger" role="alert">
        <X size={15} />
        <div>{this.props.t("This part of the page could not be drawn. Save the session and reload the page.")}
          <div className="small text-muted">{String(this.state.err.message)}</div></div>
      </div>
    );
  }
}
