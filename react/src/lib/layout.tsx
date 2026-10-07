// Layout for the React pages, following the app's conventions (AGENTS.md):
// quiet cards with an expand corner, a sidebar of numbered folding steps
// (one open at a time) with the page's main action kept outside them, tabs
// the server can switch (nav_select()), notices and empty states.
import { useEffect, useRef, useState, type CSSProperties, type ReactNode } from "react";
import { createPortal } from "react-dom";
import { ChevronDown, Info, Maximize2, Minimize2, TriangleAlert, X } from "lucide-react";
import { useShinyInput } from "@/shiny";
import { useServerUpdates } from "./inputs";
import "./lib.css";

/** Tell Shiny outputs inside `el` they were shown / hidden (as Bootstrap tabs do), and charts to measure again. */
export function signalShown(el: Element | null, shown: boolean) {
  if (!el) return;
  const $ = (window as unknown as { jQuery?: (e: Element) => { trigger: (ev: string) => void } }).jQuery;
  if ($) $(el).trigger(shown ? "shown" : "hidden");
  if (shown) window.setTimeout(() => window.dispatchEvent(new Event("resize")), 30);
}

/* ---------------------------------------------------------------- card */

export function Card({ title, icon, actions, children, className, bodyClassName, full = false, help, style, footer }: {
  title?: ReactNode; icon?: ReactNode; actions?: ReactNode; children: ReactNode; className?: string; bodyClassName?: string;
  /** an expand corner, as bslib::card(full_screen = TRUE) */
  full?: boolean; help?: ReactNode; style?: CSSProperties; footer?: ReactNode;
}) {
  const [big, setBig] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => { window.dispatchEvent(new Event("resize")); }, [big]);
  useEffect(() => {
    if (!big) return;
    const k = (e: KeyboardEvent) => { if (e.key === "Escape") setBig(false); };
    document.addEventListener("keydown", k);
    return () => document.removeEventListener("keydown", k);
  }, [big]);
  const card = (
    <div ref={ref} className={`card tw-card${big ? " tw-card-full" : ""}${className ? " " + className : ""}`} style={style}>
      {(title || actions || full) && (
        <div className="card-header d-flex justify-content-between align-items-center gap-2 flex-wrap">
          <span className="tw-card-title">{icon}{icon ? " " : null}{title}{help ? <span className="ms-1">{help}</span> : null}</span>
          <div className="d-flex align-items-center gap-2 flex-wrap">
            {actions}
            {full && (
              <button type="button" className="btn btn-sm tw-expand" onClick={() => setBig(!big)} title={big ? "Close" : "Expand"} aria-label={big ? "Close" : "Expand"}>
                {big ? <Minimize2 size={14} /> : <Maximize2 size={14} />}
              </button>
            )}
          </div>
        </div>
      )}
      <div className={`card-body${bodyClassName ? " " + bodyClassName : ""}`}>{children}</div>
      {footer ? <div className="card-footer">{footer}</div> : null}
    </div>
  );
  // full screen in place (CSS), so the outputs inside are not drawn again
  return big ? <><div className="tw-card-backdrop" onClick={() => setBig(false)} />{card}</> : card;
}

/* ------------------------------------------------------------- sidebar */

export function SidebarLayout({ sidebar, children, width = 300, className }: { sidebar: ReactNode; children: ReactNode; width?: number; className?: string }) {
  const [open, setOpen] = useState(true);
  return (
    <div className={`tw-sidebar-layout${open ? "" : " tw-side-closed"}${className ? " " + className : ""}`} style={{ ["--tw-side-w" as string]: `${width}px` }}>
      <aside className="tw-side">
        <div className="tw-side-scroll">{sidebar}</div>
      </aside>
      <button type="button" className="tw-side-toggle" onClick={() => { setOpen(!open); window.setTimeout(() => window.dispatchEvent(new Event("resize")), 250); }}
              title={open ? "Hide the sidebar" : "Show the sidebar"} aria-label={open ? "Hide the sidebar" : "Show the sidebar"}>
        <ChevronDown size={14} style={{ transform: open ? "rotate(90deg)" : "rotate(-90deg)" }} />
      </button>
      <div className="tw-side-main">{children}</div>
    </div>
  );
}

export type Step = { key: string; title: ReactNode; icon?: ReactNode; summary?: ReactNode; content: ReactNode };

/** Numbered folding sections, one open at a time (side_steps()); a folded one says what it holds. */
export function Steps({ steps, open: initial }: { steps: Step[]; open?: string }) {
  const [open, setOpen] = useState<string | null>(initial ?? steps[0]?.key ?? null);
  const refs = useRef<Record<string, HTMLDivElement | null>>({});
  return (
    <div className="tw-steps">
      {steps.map((s) => {
        const on = open === s.key;
        return (
          <section key={s.key} className={`tw-step${on ? " open" : ""}`}>
            <button type="button" className="tw-step-head" aria-expanded={on}
                    onClick={() => { const n = on ? null : s.key; setOpen(n); if (n) signalShown(refs.current[n], true); }}>
              <span className="tw-step-title">{s.icon}{s.icon ? " " : null}{s.title}</span>
              {!on && s.summary ? <span className="tw-step-summary">{s.summary}</span> : null}
              <ChevronDown size={14} className="tw-step-chev" />
            </button>
            {/* kept mounted: inputs inside stay Shiny inputs while folded */}
            <div className="tw-step-body" ref={(e) => { refs.current[s.key] = e; }} style={{ display: on ? undefined : "none" }}>{s.content}</div>
          </section>
        );
      })}
    </div>
  );
}

/** The page's main actions, below the folding steps (side_actions()). */
export function SideActions({ children }: { children: ReactNode }) {
  return <div className="tw-side-actions">{children}</div>;
}

/* ---------------------------------------------------------------- tabs */

export type Tab = { value: string; label: ReactNode; icon?: ReactNode; content: ReactNode; hidden?: boolean };

type TabsProps = { id?: string; tabs: Tab[]; value?: string; onChange?: (v: string) => void; className?: string; pills?: boolean };

/**
 * Tabs, every panel kept mounted. With `id` the current tab is input$<id>
 * and the server can switch it (bslib::nav_select(id, value)).
 */
export function Tabs(p: TabsProps) {
  return p.id ? <ShinyTabs {...p} id={p.id} /> : <LocalTabs {...p} />;
}

function LocalTabs(p: TabsProps) {
  const [cur, setCur] = useState(p.value ?? p.tabs.filter((t) => !t.hidden)[0]?.value ?? "");
  return <TabsView {...p} cur={cur} set={(v) => { setCur(v); p.onChange?.(v); }} />;
}

function ShinyTabs(p: TabsProps & { id: string }) {
  const [cur, setCur] = useShinyInput<string>(p.id, p.value ?? p.tabs.filter((t) => !t.hidden)[0]?.value ?? "", { debounceMs: 0 });
  const set = (v: string) => { setCur(v); p.onChange?.(v); };
  useServerUpdates(p.id, (u) => { if (u.value !== undefined && u.value !== null) set(String(Array.isArray(u.value) ? u.value[0] : u.value)); });
  return <TabsView {...p} cur={cur} set={set} />;
}

function TabsView({ tabs, className, pills, cur, set }: TabsProps & { cur: string; set: (v: string) => void }) {
  const visible = tabs.filter((t) => !t.hidden);
  const active = visible.some((t) => t.value === cur) ? cur : visible[0]?.value;
  const refs = useRef<Record<string, HTMLDivElement | null>>({});
  useEffect(() => { for (const t of tabs) signalShown(refs.current[t.value], t.value === active); }, [active]); // eslint-disable-line
  return (
    <div className={`tw-tabs${className ? " " + className : ""}`}>
      <ul className={`nav ${pills ? "nav-pills" : "nav-underline"} tw-tabs-nav`} role="tablist">
        {visible.map((t) => (
          <li key={t.value} className="nav-item" role="presentation">
            <button type="button" role="tab" aria-selected={t.value === active} className={`nav-link${t.value === active ? " active" : ""}`} onClick={() => set(t.value)}>
              {t.icon}{t.icon ? " " : null}{t.label}
            </button>
          </li>
        ))}
      </ul>
      {tabs.map((t) => (
        <div key={t.value} ref={(e) => { refs.current[t.value] = e; }} role="tabpanel" className="tw-tab-panel"
             style={{ display: t.value === active ? undefined : "none" }}>{t.content}</div>
      ))}
    </div>
  );
}

/* --------------------------------------------------- notes and dialogs */

export function Notice({ kind = "info", children, className }: { kind?: "info" | "warning" | "danger" | "success"; children: ReactNode; className?: string }) {
  return (
    <div className={`tw-notice tw-notice-${kind}${className ? " " + className : ""}`} role={kind === "danger" ? "alert" : undefined}>
      {kind === "info" ? <Info size={15} /> : <TriangleAlert size={15} />}
      <div>{children}</div>
    </div>
  );
}

/** A dialog drawn by React (dialogs the server opens with showModal() stay Shiny's). */
export function Dialog({ open, onClose, title, children, footer, size = "lg" }: {
  open: boolean; onClose: () => void; title: ReactNode; children: ReactNode; footer?: ReactNode; size?: "sm" | "lg" | "xl";
}) {
  useEffect(() => {
    if (!open) return;
    const k = (e: KeyboardEvent) => { if (e.key === "Escape") onClose(); };
    document.addEventListener("keydown", k);
    return () => document.removeEventListener("keydown", k);
  }, [open, onClose]);
  if (!open) return null;
  return createPortal(
    <div className="tw-dialog-backdrop" onMouseDown={(e) => { if (e.target === e.currentTarget) onClose(); }}>
      <div className={`modal-dialog modal-${size} modal-dialog-scrollable tw-dialog`} role="dialog" aria-modal="true">
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
