// Pieces shared by the Data Quality tabs: the module namespace, the figures
// row (server textOutputs or values, with a tinted icon chip) and the settings
// toolbar every tab starts with.
import type { ReactNode } from "react";
import { TextOutput } from "@/lib/inputs";
import "./dq.css";

export const ns = (id: string) => `dq_1-${id}`;
export type T = (s: string) => string;

export type Kpi = {
  label: string; icon: ReactNode; tone?: "blue" | "cyan" | "amber" | "red" | "green" | "grey";
  /** a server textOutput (un-namespaced id) or a value drawn here */
  id?: string; value?: ReactNode; subId?: string; sub?: ReactNode;
};

export function Kpis({ items }: { items: Kpi[] }) {
  return (
    <div className="tw-dq-kpis">
      {items.map((k) => (
        <div key={k.label} className={`tw-dq-kpi tone-${k.tone ?? "blue"}`}>
          <span className="tw-dq-kpi-icon" aria-hidden>{k.icon}</span>
          <div className="tw-dq-kpi-body">
            <div className="tw-dq-kpi-label">{k.label}</div>
            <div className="tw-dq-kpi-value">{k.id ? <TextOutput id={ns(k.id)} /> : k.value}</div>
            {k.subId ? <div className="tw-dq-kpi-sub"><TextOutput id={ns(k.subId)} /></div>
              : k.sub ? <div className="tw-dq-kpi-sub">{k.sub}</div> : null}
          </div>
        </div>
      ))}
    </div>
  );
}

/** The settings of a tab, in one row that wraps; actions go to the right. */
export function Toolbar({ children, actions, intro }: { children: ReactNode; actions?: ReactNode; intro?: ReactNode }) {
  return (
    <div className="card tw-card tw-dq-toolbar">
      <div className="card-body">
        {intro ? <p className="tw-dq-intro">{intro}</p> : null}
        <div className="tw-dq-toolbar-row">
          {children}
          {actions ? <div className="tw-dq-toolbar-actions">{actions}</div> : null}
        </div>
      </div>
    </div>
  );
}

/** A small explanation under a card title. */
export const Note = ({ children }: { children: ReactNode }) => <div className="tw-dq-note">{children}</div>;
