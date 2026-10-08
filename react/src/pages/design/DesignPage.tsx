// Targeting Design (scorecard_panel), the module scorecard_1: R/mod_scorecard.R.
// See PORT.md. The server sends the design's state as JSON (sc_flow, ...) and
// keeps every input and output id; the sidebar's file input, MODA, calculator
// and areas covered are the Shiny parts, hosted (output host_*).
import { useEffect, useRef, useState, type ReactNode } from "react";
import {
  BookOpen, Calculator, Check, ChevronDown, CircleCheck, ClipboardList, Database, FileCode2, FileSpreadsheet, FileText,
  MapPin, PackageOpen, Share2, TriangleAlert, Upload,
} from "lucide-react";
import { ShinyOutput, useShinyInput, useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, HostedUI, TextOutput, useServerUpdates } from "@/lib/inputs";
import { SidebarLayout, SideActions, signalShown } from "@/lib/layout";
import { AreaScope } from "@/components/AreaScope";
import { ModaImport } from "@/components/ModaImport";
import { VarCalc } from "@/components/VarCalc";
import { DataSummary } from "@/components/DataSummary";
import "@/components/modules.css";
import { Boundary, ns, sendEvent, type T } from "./shared";
import type { Flow, Meta, Mode } from "./types";
import { StepFramework } from "./StepFramework";
import { StepCriteria } from "./StepCriteria";
import { StepModel } from "./StepModel";
import { StepThreshold } from "./StepThreshold";

export function DesignPage({ t }: { active: boolean; t: T }) {
  const meta = useShinyOutputValue<Meta>(ns("sc_meta"));
  const flow = useShinyOutputValue<Flow>(ns("sc_flow"));
  const mode = (useShinyInputValue<string>(ns("framework_mode")) ?? flow?.mode ?? "outcome") as Mode;
  const [side, setSide] = useState("data");
  const sideRef = useRef<HTMLDivElement>(null);

  // The stepper's "Data" opens the sidebar on the data section
  const openData = () => {
    setSide("data");
    const lay = sideRef.current?.closest(".tw-sidebar-layout");
    if (lay?.classList.contains("tw-side-closed")) (lay.querySelector(".tw-side-toggle") as HTMLButtonElement | null)?.click();
  };
  // a step: shown at once (as the server's nav_select() would), and input$steps follows
  const selectStep = (panel: string) => {
    const el = document.getElementById(ns("steps"));
    const jq = (window as unknown as { jQuery?: (e: Element) => { data: (k: string) => { receiveMessage?: (e: Element, m: unknown) => void } | undefined } }).jQuery;
    const b = el && jq ? jq(el).data("shiny-input-binding") : undefined;
    if (el && b?.receiveMessage) b.receiveMessage(el, { value: panel }); else sendEvent(ns("flow_go"), panel);
  };
  const go = (panel: string) => (panel === "data" ? openData() : selectStep(panel));

  const nof = mode === "none", pmt = mode === "pmt";

  const sidebar = (
    <div ref={sideRef} className="sc-side">
      <SideSections open={side} setOpen={setSide} sections={[
        {
          key: "data", title: t("1. Assessment data"), icon: <Database size={15} />,
          summary: flow?.data ? `${flow.data.rows.toLocaleString("en-US")} × ${flow.data.cols}` : t("not loaded"),
          content: (
            <>
              <p className="small text-muted mb-2">
                {t("An assessment survey with a food-security outcome (EFSA, VAM...) or a welfare measure (HIES, LSMS), not the registration or PDM data.")}
              </p>
              <div className="tw-dropzone sc-file">
                <Upload size={18} className="tw-dropzone-icon" aria-hidden />
                <HostedUI id={ns("host_file")} className="tw-dropzone-input" />
              </div>
              <div className="sc-data-tools">
                <ModaImport ns={ns("moda")} label="MODA" size="sm" t={t} />
                <VarCalc ns={ns("calc")} label="Calculator" block t={t} />
                <ActionButton id={ns("fsi-open")} label={t("Food security indicators")} icon={<Calculator size={14} />} variant="outline-secondary"
                              title={t("Calculate FCS, rCSI, LCS, FES or CARI from the WFP standard variables")} className="sc-full" />
                <DataSummary ns={ns("summary")} className="sc-full" t={t} />
                <ActionButton id={ns("open_guide")} label={t("How it works")} icon={<BookOpen size={14} />} variant="outline-secondary"
                              title={t("The design process step by step, with its methods")} className="w-100" />
              </div>
              <DataStatus flow={flow} t={t} />
            </>
          ),
        },
        {
          key: "areas", title: t("2. Areas covered"), icon: <MapPin size={15} />,
          content: <AreaScope ns={ns("scope")} title={null} t={t} />,
        },
        {
          key: "adopt", title: t("3. Exports"), icon: <Share2 size={15} />,
          content: (
            <div className="sc-exports">
              <ExportLink id={ns("download")} icon={<FileSpreadsheet size={17} />} title={`${nof ? t("Vulnerability ranking") : t("Scorecard")} (Excel)`}
                          sub={nof ? t("Criteria, points, threshold and validity") : t("Criteria, points, threshold and design errors")} />
              <ExportLink id={ns("download_json")} icon={<FileCode2 size={17} />} title={t("Card (JSON)")} sub={t("For other tools and systems")} />
              <ExportLink id={ns("download_report")} icon={<FileText size={17} />} title={`${nof ? t("Ranking report") : t("Design report")} (HTML)`}
                          sub={t("Every step and chart, to share and review")} />
              <ExportLink id={ns("download_xlsform")} icon={<ClipboardList size={17} />} title={t("Registration form (XLSForm)")}
                          sub={t("Draft for KoboToolbox, ODK or MODA, from the adopted design")} />
            </div>
          ),
        },
      ]} />
      <SideActions>
        <ActionButton id={ns("btn_use")} label={nof ? t("Use this ranking") : pmt ? t("Use this PMT") : t("Use this scorecard")}
                      icon={<CircleCheck size={15} />} variant="primary" className="w-100 sc-adopt-btn" />
        <div className={`sc-use-status${flow?.adopted ? " is-adopted" : ""}`}>
          {flow?.adopted ? <Check size={13} /> : null}<TextOutput id={ns("use_status")} />
        </div>
      </SideActions>
    </div>
  );

  return (
    <SidebarLayout sidebar={sidebar} width={320} className="sc-page">
      <Boundary t={t}><FlowBar flow={flow} go={go} t={t} /></Boundary>
      <StepPanels panels={[
        { value: "outcome", content: <Boundary t={t}><StepFramework flow={flow} meta={meta} mode={mode} t={t} /></Boundary> },
        { value: "screening", content: <Boundary t={t}><StepCriteria flow={flow} mode={mode} t={t} /></Boundary> },
        { value: "weights", content: <Boundary t={t}><StepModel flow={flow} meta={meta} mode={mode} t={t} /></Boundary> },
        { value: "threshold", content: <Boundary t={t}><StepThreshold flow={flow} meta={meta} mode={mode} t={t} /></Boundary> },
      ]} />
    </SidebarLayout>
  );
}

/* ------------------------------------------------------------ sidebar */

type Section = { key: string; title: string; icon: ReactNode; summary?: string; content: ReactNode };

/** The sidebar's numbered sections, one open at a time (side_steps()) */
function SideSections({ sections, open, setOpen }: { sections: Section[]; open: string; setOpen: (k: string) => void }) {
  const refs = useRef<Record<string, HTMLDivElement | null>>({});
  useEffect(() => { signalShown(refs.current[open], true); }, [open]);
  return (
    <div className="tw-steps">
      {sections.map((s) => {
        const on = open === s.key;
        return (
          <section key={s.key} className={`tw-step${on ? " open" : ""}`}>
            <button type="button" className="tw-step-head" aria-expanded={on} onClick={() => setOpen(on ? "" : s.key)}>
              <span className="tw-step-title">{s.icon} {s.title}</span>
              {!on && s.summary ? <span className="tw-step-summary">{s.summary}</span> : null}
              <ChevronDown size={14} className="tw-step-chev" />
            </button>
            <div className="tw-step-body" ref={(e) => { refs.current[s.key] = e; }} style={{ display: on ? undefined : "none" }}>{s.content}</div>
          </section>
        );
      })}
    </div>
  );
}

function DataStatus({ flow, t }: { flow?: Flow; t: T }) {
  if (!flow?.data) {
    return (
      <div className="sc-data-status is-empty">
        <TriangleAlert size={15} />
        <div><strong>{t("No assessment data yet.")}</strong><div className="text-muted">{t("Load a needs-assessment extract above to start the design.")}</div></div>
      </div>
    );
  }
  return (
    <div className="sc-data-status">
      <CircleCheck size={15} />
      <div>
        <strong>{t("%s rows, %s columns").replace("%s", flow.data.rows.toLocaleString("en-US")).replace("%s", String(flow.data.cols))}</strong>
        <div className="text-muted text-truncate" title={flow.data.source}>{t("Source:")} {flow.data.source}</div>
      </div>
    </div>
  );
}

/** A download in the exports list: what it is and what it is for */
function ExportLink({ id, icon, title, sub }: { id: string; icon: ReactNode; title: string; sub: string }) {
  useEffect(() => { (window as unknown as { twGates?: { apply: (id: string) => void } }).twGates?.apply(id); });
  return (
    <ShinyOutput id={id} tagName="a" className="sc-export shiny-download-link" {...{ download: "", target: "_blank" }}>
      <span className="sc-export-icon">{icon}</span>
      <span className="sc-export-text"><span className="sc-export-title">{title}</span><span className="sc-export-sub">{sub}</span></span>
    </ShinyOutput>
  );
}

/* ------------------------------------------------------------ stepper */

const STEP_NUM: Record<string, string> = { outcome: "1", screening: "2", weights: "3", threshold: "4" };

/** The whole design in one bar: done, current and next at a glance, each step one click away */
function FlowBar({ flow, go, t }: { flow?: Flow; go: (panel: string) => void; t: T }) {
  if (!flow) return <div className="sc-flow sc-flow-empty" />;
  const next = flow.todo_i ? flow.steps[flow.todo_i - 1]?.key : null;
  const label = (s: Flow["steps"][number]) => (s.key === "outcome" && flow.mode === "pmt" ? t("Welfare measure") : t(s.label));
  return (
    <div className="sc-flow">
      <ol className="sc-flow-track">
        {flow.steps.map((s, i) => {
          const cur = s.key === flow.here, isNext = s.key === next;
          return (
            <li key={s.key} className={`sc-flow-step${s.done ? " is-done" : ""}${cur ? " is-current" : ""}${isNext ? " is-next" : ""}`}>
              {i > 0 ? <span className={`sc-flow-line${flow.steps[i - 1].done ? " is-done" : ""}`} aria-hidden="true" /> : null}
              <button type="button" onClick={() => go(s.panel)} title={s.panel === "data" ? t("Open the assessment data (sidebar)") : `${t("Open")} ${label(s)}`}
                      aria-current={cur ? "step" : undefined}>
                <span className="sc-flow-dot">
                  {s.done ? <Check size={13} strokeWidth={3} /> : STEP_NUM[s.key] ?? (s.key === "data" ? <Database size={12} /> : <PackageOpen size={12} />)}
                </span>
                <span className="sc-flow-label">{label(s)}</span>
              </button>
            </li>
          );
        })}
      </ol>
      <div className="sc-flow-next">
        <span className={`sc-flow-status is-${flow.status.kind}`}>
          {flow.status.kind === "todo" ? <strong>{t("On this step:")} </strong> : <CircleCheck size={15} />} {t(flow.status.text)}
        </span>
        {flow.earlier ? (
          <span className="sc-flow-earlier">
            {t("%s is not finished.").replace("%s", t(flow.earlier.label))}{" "}
            <button type="button" className="btn btn-link btn-sm p-0" onClick={() => go(flow.earlier!.panel)}>{t("Back to it")}</button>
          </span>
        ) : null}
        {flow.next_panel ? (
          <button type="button" className="btn btn-sm btn-outline-primary ms-auto"
                  onClick={() => (flow.here === "screening" ? sendEvent(ns("nav_next_screening"), Date.now()) : go(flow.next_panel!))}>
            {t("Continue to")} {flow.next_panel === "outcome" && flow.mode === "pmt" ? t("Welfare measure") : t(flow.next_label ?? "")} {"→"}
          </button>
        ) : null}
      </div>
    </div>
  );
}

/* --------------------------------------------------------------- steps */

/**
 * The four steps, one shown at a time: input$steps, which the server moves
 * with nav_select("steps", ...). The stepper above is their navigation.
 */
function StepPanels({ panels }: { panels: { value: string; content: ReactNode }[] }) {
  const [cur, setCur] = useShinyInput<string>(ns("steps"), "outcome", { debounceMs: 0 });
  useServerUpdates(ns("steps"), (u) => { if (u.value !== undefined && u.value !== null) setCur(String(Array.isArray(u.value) ? u.value[0] : u.value)); });
  const refs = useRef<Record<string, HTMLDivElement | null>>({});
  const first = useRef(true);
  useEffect(() => {
    for (const p of panels) signalShown(refs.current[p.value], p.value === cur);
    // a new step starts at its top
    if (!first.current) refs.current[cur]?.closest(".tw-side-main")?.scrollTo({ top: 0 });
    first.current = false;
  }, [cur]); // eslint-disable-line
  return (
    <>
      {panels.map((p) => (
        <div key={p.value} ref={(e) => { refs.current[p.value] = e; }} className="sc-step-panel" role="region"
             style={{ display: p.value === cur ? undefined : "none" }}>{p.content}</div>
      ))}
    </>
  );
}
