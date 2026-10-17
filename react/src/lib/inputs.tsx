// Inputs for the React pages. Each one is a Shiny input under the id the
// Shiny page used, so the server code reads input$<id> unchanged, and each
// accepts the server's update*Input() / nav_select() messages: Shiny sends
// them to the element `.shiny-bound-input#<id>` and calls its binding's
// receiveMessage(); useServerUpdates() puts such an element in the page.
//
// Vectors travel as the "tw.chr" / "tw.num" / "tw.date" input types
// (R/utils_react_render.R), so R gets a character / numeric / Date vector,
// and NULL when nothing is chosen, as with Shiny's own inputs.
import { useEffect, useRef, useState, type CSSProperties, type ReactNode } from "react";
import Select from "react-select";
import { ShinyOutput, useShinyButton, useShinyInput } from "@/shiny";
import { useVarLabels } from "./labels";

/* --------------------------------------------------------------- choices */

export type Choice = { value: string; label: string; group?: string; disabled?: boolean };
/** Choices as R writes them: values, `{label: value}` (a named vector), or Choice objects. */
export type ChoicesIn = Choice[] | string[] | Record<string, string> | null | undefined;

export function toChoices(c: ChoicesIn): Choice[] {
  if (!c) return [];
  if (Array.isArray(c)) return (c as Array<string | Choice>).map((x) => (typeof x === "string" ? { value: x, label: x } : x));
  return Object.entries(c).map(([label, value]) => ({ value: String(value), label }));
}

/** Choices out of the HTML Shiny sends (<option>s, optgroups, radio / checkbox inputs). */
function parseChoiceHtml(html: string): { choices: Choice[]; selected: string[] } {
  const choices: Choice[] = [], selected: string[] = [];
  if (/<option/i.test(html)) {
    const doc = new DOMParser().parseFromString(`<select multiple>${html}</select>`, "text/html");
    doc.querySelectorAll("option").forEach((o) => {
      const g = o.parentElement?.tagName === "OPTGROUP" ? (o.parentElement as HTMLOptGroupElement).label : undefined;
      choices.push({ value: o.value, label: o.textContent ?? o.value, group: g, disabled: o.disabled });
      if (o.selected) selected.push(o.value);
    });
  } else {
    const doc = new DOMParser().parseFromString(`<div>${html}</div>`, "text/html");
    doc.querySelectorAll("input").forEach((i) => {
      const lab = i.closest("label")?.textContent?.trim() ?? i.nextElementSibling?.textContent?.trim() ?? i.value;
      choices.push({ value: i.value, label: lab });
      if (i.checked) selected.push(i.value);
    });
  }
  return { choices, selected };
}

/* ------------------------------------------------------ server updates */

/** What an update*Input() / nav_select() message asks for, whatever the widget it was written for. */
export type Update = {
  value?: unknown; label?: string; choices?: Choice[]; min?: number; max?: number; step?: number;
  /** min / max as sent, for dates ("2026-01-01") */
  minRaw?: string; maxRaw?: string;
  placeholder?: string; disabled?: boolean;
};

function readUpdate(m: Record<string, unknown>): Update {
  const u: Update = {};
  if ("label" in m && typeof m.label === "string") u.label = m.label;
  for (const k of ["min", "max", "step"] as const) {
    const v = m[k];
    if (v === undefined || v === null) continue;
    const n = Number(v);
    if (isFinite(n)) u[k] = n;
    if (k !== "step") u[k === "min" ? "minRaw" : "maxRaw"] = String(v);
  }
  if (typeof m.placeholder === "string") u.placeholder = m.placeholder;
  if (typeof m.disabled === "boolean") u.disabled = m.disabled;
  // option lists: selectInput / radioButtons send `options` as HTML, pickerInput `choices`
  const html = typeof m.options === "string" ? m.options : typeof m.choices === "string" ? m.choices : null;
  let htmlSel: string[] | null = null;
  if (html !== null) { const p = parseChoiceHtml(html); u.choices = p.choices; htmlSel = p.selected; }
  else if (Array.isArray(m.choices)) u.choices = toChoices(m.choices as string[]);
  // value: value / selected (picker) / start-end (date range)
  if ("value" in m) u.value = m.value;
  else if ("selected" in m) u.value = m.selected;
  else if ("start" in m || "end" in m) u.value = [m.start, m.end];
  else if (htmlSel && htmlSel.length) u.value = htmlSel;
  // dateRangeInput: {start, end}
  if (u.value && typeof u.value === "object" && !Array.isArray(u.value)) {
    const o = u.value as { start?: unknown; end?: unknown };
    if ("start" in o || "end" in o) u.value = [o.start ?? "", o.end ?? ""];
  }
  return u;
}

/**
 * Receive the server's updates for input `id`. A hidden element carries the
 * id and the binding Shiny looks for, so the visible control must not use
 * the same id (use `ctlId(id)`).
 */
export function useServerUpdates(id: string, fn: (u: Update) => void) {
  const ref = useRef(fn);
  ref.current = fn;
  useEffect(() => {
    const $ = (window as unknown as { jQuery?: (e: Element) => { data: (k: string, v: unknown) => void } }).jQuery;
    if (!$) return;
    const el = document.createElement("span");
    el.id = id;
    el.className = "shiny-bound-input tw-binding";
    el.hidden = true;
    document.body.appendChild(el);
    $(el).data("shiny-input-binding", { receiveMessage: (_e: Element, m: Record<string, unknown>) => ref.current(readUpdate(m ?? {})) });
    return () => el.remove();
  }, [id]);
}

export const ctlId = (id: string) => `${id}__ctl`;

/** Shown / hidden by the server (cascade_pickers() hides the pickers of unmapped levels). */
function useServerVisible(id: string): boolean {
  const [show, setShow] = useState(true);
  useEffect(() => {
    const on = (e: Event) => { const d = (e as CustomEvent).detail; if (d?.id === id) setShow(!!d.show); };
    document.addEventListener("tw-input-visible", on);
    return () => document.removeEventListener("tw-input-visible", on);
  }, [id]);
  return show;
}

/* ------------------------------------------------------------ the field */

export function Field({ id, label, help, children, className, inline, style }: {
  id: string; label?: ReactNode; help?: ReactNode; children: ReactNode; className?: string; inline?: boolean; style?: CSSProperties;
}) {
  const show = useServerVisible(id);
  if (!show) return null;
  return (
    <div className={`tw-field${inline ? " tw-field-inline" : ""}${className ? " " + className : ""}`} style={style}>
      {label ? <label className="form-label" htmlFor={ctlId(id)}>{label}</label> : null}
      {children}
      {help ? <div className="form-text">{help}</div> : null}
    </div>
  );
}

/* --------------------------------------------------------------- select */

type SelectProps = {
  id: string; label?: ReactNode; choices?: ChoicesIn; value?: string | string[] | null; multiple?: boolean;
  placeholder?: string; help?: ReactNode; clearable?: boolean; className?: string; disabled?: boolean;
  /** called with the new value, after it is sent */
  onChange?: (v: string | string[] | null) => void;
  /** pickers with "Select all / none" (pickerInput actions-box) */
  actions?: boolean; maxShown?: number;
};

/** selectInput / selectizeInput / pickerInput. Single: a string ("" when empty). Multiple: a vector, NULL when empty. */
export function SelectInput(p: SelectProps) {
  const init = p.multiple ? (Array.isArray(p.value) ? p.value : p.value ? [p.value] : []) : (Array.isArray(p.value) ? p.value[0] ?? "" : p.value ?? "");
  const [choices, setChoices] = useState<Choice[]>(toChoices(p.choices));
  const [label, setLabel] = useState<ReactNode>(p.label);
  const [val, setVal] = useShinyInput<string | string[] | null>(p.id, p.multiple ? (init.length ? init : null) : init,
    { debounceMs: 0, type: "tw.chr" });
  // choices given by the page (not the server) follow the props
  const key = JSON.stringify(p.choices ?? null);
  const first = useRef(true);
  useEffect(() => { if (first.current) { first.current = false; return; } setChoices(toChoices(p.choices)); }, [key]); // eslint-disable-line
  useServerUpdates(p.id, (u) => {
    if (u.label !== undefined) setLabel(u.label);
    let cs = choices;
    if (u.choices) { cs = u.choices; setChoices(u.choices); }
    if (u.value !== undefined) {
      const v = u.value === null ? [] : Array.isArray(u.value) ? (u.value as unknown[]).map(String) : [String(u.value)];
      send(p.multiple ? v : v[0] ?? "");
    } else if (u.choices) {
      // new choices: keep what is still offered (a single select falls back to the first, as Shiny does)
      const offered = new Set(cs.map((c) => c.value));
      if (p.multiple) { const cur = (Array.isArray(val) ? val : []).filter((x) => offered.has(x)); send(cur); }
      else if (!offered.has(String(val ?? ""))) send(cs[0]?.value ?? "");
    }
  });
  const send = (v: string | string[]) => {
    const out = Array.isArray(v) ? (v.length ? v : null) : v;
    setVal(out);
    p.onChange?.(out);
  };
  // a variable shows its label below its name (www/labels.js does it on the Shiny pages)
  const vl = useVarLabels();
  const optLabel = (c: Choice, ctx: string) => {
    const l = c.label === c.value ? vl.label(c.value) : null;
    return l && ctx === "menu" ? <span className="tw-opt"><span className="tw-opt-name tw-strong">{c.label}</span><span className="tw-opt-label">{l}</span></span> : c.label;
  };
  const withActions = !!(p.multiple && p.actions && choices.length > 1);
  const groups = [...new Set(choices.map((c) => c.group).filter(Boolean))] as string[];
  const opts = groups.length
    ? [...choices.filter((c) => !c.group), ...groups.map((g) => ({ label: g, options: choices.filter((c) => c.group === g) }))]
    : choices;
  const cur = Array.isArray(val) ? val : val ? [val] : [];
  const selected = cur.map((v) => choices.find((c) => c.value === v) ?? { value: v, label: v });
  return (
    // with "Select all / None", the label and the links share one row
    <Field id={p.id} label={withActions ? undefined : label} help={p.help} className={p.className}>
      {withActions ? (
        <div className="tw-select-head">
          {label ? <label className="form-label" htmlFor={ctlId(p.id)}>{label}</label> : <span />}
          <div className="tw-select-actions">
            <button type="button" className="btn btn-link btn-sm p-0" onClick={() => send(choices.map((c) => c.value))}>Select all</button>
            <button type="button" className="btn btn-link btn-sm p-0" onClick={() => send([])}>None</button>
          </div>
        </div>
      ) : null}
      <Select<Choice, boolean>
        inputId={ctlId(p.id)} classNamePrefix="tw-select" className="tw-select"
        options={opts as never} isMulti={!!p.multiple} isDisabled={p.disabled}
        value={p.multiple ? selected : selected[0] ?? null}
        onChange={(x) => send(p.multiple ? ((x as Choice[]) ?? []).map((c) => c.value) : (x as Choice | null)?.value ?? "")}
        isClearable={p.clearable ?? !!p.multiple} placeholder={p.placeholder ?? (p.multiple ? "All" : "Choose...")}
        isOptionDisabled={(c) => !!c.disabled} closeMenuOnSelect={!p.multiple} hideSelectedOptions={false}
        menuPortalTarget={document.body} menuPlacement="auto"
        styles={{ menuPortal: (b) => ({ ...b, zIndex: 2000 }) }}
        noOptionsMessage={() => "Nothing to choose"}
        formatOptionLabel={(c, m) => optLabel(c as Choice, m.context)}
        filterOption={(o, q) => { const x = q.toLowerCase(); return !x || o.label.toLowerCase().includes(x) || o.value.toLowerCase().includes(x) || (vl.label(o.value) ?? "").toLowerCase().includes(x); }}
      />
    </Field>
  );
}

/* ------------------------------------------------------- numbers, text */

export function NumericInput({ id, label, value, min, max, step, help, className, placeholder, onChange }: {
  id: string; label?: ReactNode; value?: number | null; min?: number; max?: number; step?: number; help?: ReactNode;
  className?: string; placeholder?: string; onChange?: (v: number | null) => void;
}) {
  const [v, setV] = useShinyInput<number | null>(id, value ?? null, { debounceMs: 250, type: "tw.num" });
  const [lim, setLim] = useState({ min, max, step });
  const [lab, setLab] = useState<ReactNode>(label);
  const [text, setText] = useState(v === null || v === undefined ? "" : String(v));
  useEffect(() => { if (v === null || v === undefined) { if (text !== "" && !isNaN(Number(text))) setText(""); } else if (Number(text) !== v) setText(String(v)); }, [v]); // eslint-disable-line
  useServerUpdates(id, (u) => {
    if (u.label !== undefined) setLab(u.label);
    if (u.min !== undefined || u.max !== undefined || u.step !== undefined) setLim((l) => ({ min: u.min ?? l.min, max: u.max ?? l.max, step: u.step ?? l.step }));
    if (u.value !== undefined) { const n = u.value === null || u.value === "" ? null : Number(u.value); setV(n); setText(n === null ? "" : String(n)); }
  });
  return (
    <Field id={id} label={lab} help={help} className={className}>
      <input id={ctlId(id)} type="number" className="form-control form-control-sm" value={text} placeholder={placeholder}
             min={lim.min} max={lim.max} step={lim.step ?? "any"}
             onChange={(e) => { setText(e.target.value); const n = e.target.value === "" ? null : Number(e.target.value); if (n === null || !isNaN(n)) { setV(n); onChange?.(n); } }} />
    </Field>
  );
}

export function TextInput({ id, label, value, placeholder, help, className, area, rows, password, onChange }: {
  id: string; label?: ReactNode; value?: string; placeholder?: string; help?: ReactNode; className?: string;
  area?: boolean; rows?: number; password?: boolean; onChange?: (v: string) => void;
}) {
  const [v, setV] = useShinyInput<string>(id, value ?? "", { debounceMs: 300 });
  const [ph, setPh] = useState(placeholder);
  const [lab, setLab] = useState<ReactNode>(label);
  useServerUpdates(id, (u) => {
    if (u.label !== undefined) setLab(u.label);
    if (u.placeholder !== undefined) setPh(u.placeholder);
    if (u.value !== undefined) setV(String(u.value ?? ""));
  });
  const common = { id: ctlId(id), className: "form-control form-control-sm", value: v ?? "", placeholder: ph,
    onChange: (e: { target: { value: string } }) => { setV(e.target.value); onChange?.(e.target.value); } };
  return (
    <Field id={id} label={lab} help={help} className={className}>
      {area ? <textarea {...common} rows={rows ?? 3} /> : <input {...common} type={password ? "password" : "text"} autoComplete={password ? "off" : undefined} />}
    </Field>
  );
}

/* ------------------------------------------------------------- toggles */

export function CheckboxInput({ id, label, value, help, className, asSwitch, onChange }: {
  id: string; label: ReactNode; value?: boolean; help?: ReactNode; className?: string; asSwitch?: boolean; onChange?: (v: boolean) => void;
}) {
  const [v, setV] = useShinyInput<boolean>(id, !!value, { debounceMs: 0 });
  const [lab, setLab] = useState<ReactNode>(label);
  useServerUpdates(id, (u) => { if (u.label !== undefined) setLab(u.label); if (u.value !== undefined) setV(!!u.value); });
  return (
    <Field id={id} help={help} className={className}>
      <div className={`form-check${asSwitch ? " form-switch" : ""}`}>
        <input id={ctlId(id)} className="form-check-input" type="checkbox" role={asSwitch ? "switch" : undefined}
               checked={!!v} onChange={(e) => { setV(e.target.checked); onChange?.(e.target.checked); }} />
        <label className="form-check-label" htmlFor={ctlId(id)}>{lab}</label>
      </div>
    </Field>
  );
}

/** radioButtons / radioGroupButtons: one value. `buttons` draws a segmented control. */
export function RadioInput({ id, label, choices, value, inline, buttons, help, className, size = "sm", onChange }: {
  id: string; label?: ReactNode; choices: ChoicesIn; value?: string; inline?: boolean; buttons?: boolean; help?: ReactNode;
  className?: string; size?: "sm" | "md"; onChange?: (v: string) => void;
}) {
  const [cs, setCs] = useState<Choice[]>(toChoices(choices));
  const key = JSON.stringify(choices ?? null);
  useEffect(() => setCs(toChoices(choices)), [key]); // eslint-disable-line
  const [v, setV] = useShinyInput<string>(id, value ?? toChoices(choices)[0]?.value ?? "", { debounceMs: 0, type: "tw.chr" });
  const [lab, setLab] = useState<ReactNode>(label);
  useServerUpdates(id, (u) => {
    if (u.label !== undefined) setLab(u.label);
    if (u.choices) setCs(u.choices);
    if (u.value !== undefined) { const x = String(Array.isArray(u.value) ? u.value[0] : u.value ?? ""); setV(x); onChange?.(x); }
  });
  const pick = (x: string) => { setV(x); onChange?.(x); };
  return (
    <Field id={id} label={lab} help={help} className={className}>
      {buttons ? (
        <div className={`btn-group${size === "sm" ? " btn-group-sm" : ""} tw-seg`} role="radiogroup" id={ctlId(id)}>
          {cs.map((c) => (
            <button key={c.value} type="button" role="radio" aria-checked={v === c.value}
                    className={`btn btn-outline-primary${v === c.value ? " active" : ""}`} onClick={() => pick(c.value)}>{c.label}</button>
          ))}
        </div>
      ) : (
        <div role="radiogroup" id={ctlId(id)}>
          {cs.map((c, i) => (
            <div key={c.value} className={`form-check${inline ? " form-check-inline" : ""}`}>
              <input className="form-check-input" type="radio" id={`${ctlId(id)}_${i}`} name={ctlId(id)} checked={v === c.value} onChange={() => pick(c.value)} />
              <label className="form-check-label" htmlFor={`${ctlId(id)}_${i}`}>{c.label}</label>
            </div>
          ))}
        </div>
      )}
    </Field>
  );
}

/** checkboxGroupInput: a vector, NULL when nothing is ticked. */
export function CheckboxGroupInput({ id, label, choices, value, inline, help, className }: {
  id: string; label?: ReactNode; choices: ChoicesIn; value?: string[]; inline?: boolean; help?: ReactNode; className?: string;
}) {
  const [cs, setCs] = useState<Choice[]>(toChoices(choices));
  const key = JSON.stringify(choices ?? null);
  useEffect(() => setCs(toChoices(choices)), [key]); // eslint-disable-line
  const [v, setV] = useShinyInput<string[] | null>(id, value?.length ? value : null, { debounceMs: 0, type: "tw.chr" });
  useServerUpdates(id, (u) => {
    if (u.choices) setCs(u.choices);
    if (u.value !== undefined) { const x = u.value === null ? [] : Array.isArray(u.value) ? u.value.map(String) : [String(u.value)]; setV(x.length ? x : null); }
  });
  const cur = v ?? [];
  return (
    <Field id={id} label={label} help={help} className={className}>
      {cs.map((c, i) => (
        <div key={c.value} className={`form-check${inline ? " form-check-inline" : ""}`}>
          <input className="form-check-input" type="checkbox" id={`${ctlId(id)}_${i}`} checked={cur.includes(c.value)}
                 onChange={(e) => { const x = e.target.checked ? [...cur, c.value] : cur.filter((y) => y !== c.value); setV(x.length ? x : null); }} />
          <label className="form-check-label" htmlFor={`${ctlId(id)}_${i}`}>{c.label}</label>
        </div>
      ))}
    </Field>
  );
}

/* ------------------------------------------------------------- sliders */

/** sliderInput: one number, or a range [lo, hi] when `value` has two. */
export function SliderInput({ id, label, min, max, step, value, help, className, format }: {
  id: string; label?: ReactNode; min: number; max: number; step?: number; value: number | [number, number];
  help?: ReactNode; className?: string; format?: (n: number) => string;
}) {
  const range = Array.isArray(value);
  const [v, setV] = useShinyInput<number | number[]>(id, value, { debounceMs: 250, type: "tw.num" });
  const [lim, setLim] = useState({ min, max, step: step ?? 1 });
  useEffect(() => setLim({ min, max, step: step ?? 1 }), [min, max, step]);
  useServerUpdates(id, (u) => {
    if (u.min !== undefined || u.max !== undefined || u.step !== undefined) setLim((l) => ({ min: u.min ?? l.min, max: u.max ?? l.max, step: u.step ?? l.step }));
    if (u.value !== undefined && u.value !== null) setV(Array.isArray(u.value) ? (u.value as unknown[]).map(Number) : Number(u.value));
  });
  const f = format ?? ((n: number) => n.toLocaleString("en-US"));
  const cur = Array.isArray(v) ? v : [v];
  return (
    <Field id={id} label={label} help={help} className={className}>
      <div className="tw-slider">
        {range ? (
          <div className="tw-slider-dual">
            {/* one track, the chosen range filled, two handles on the same line */}
            <div className="tw-slider-track" aria-hidden>
              <div className="tw-slider-fill" style={{
                left: `${lim.max > lim.min ? (100 * (cur[0] - lim.min)) / (lim.max - lim.min) : 0}%`,
                right: `${lim.max > lim.min ? 100 - (100 * (cur[1] - lim.min)) / (lim.max - lim.min) : 0}%`,
              }} />
            </div>
            <input type="range" className="form-range" min={lim.min} max={lim.max} step={lim.step} value={cur[0]}
                   onChange={(e) => setV([Math.min(Number(e.target.value), cur[1]), cur[1]])} aria-label="From" />
            <input type="range" className="form-range" min={lim.min} max={lim.max} step={lim.step} value={cur[1]}
                   onChange={(e) => setV([cur[0], Math.max(Number(e.target.value), cur[0])])} aria-label="To" />
          </div>
        ) : (
          <input id={ctlId(id)} type="range" className="form-range" min={lim.min} max={lim.max} step={lim.step} value={cur[0]}
                 onChange={(e) => setV(Number(e.target.value))} />
        )}
        <div className="tw-slider-value">{range ? `${f(cur[0])} – ${f(cur[1])}` : f(cur[0])}</div>
      </div>
    </Field>
  );
}

/* --------------------------------------------------------------- dates */

/** dateInput / dateRangeInput / airDatepickerInput: ISO dates, R gets Dates. */
export function DateInput({ id, label, value, range, min, max, help, className }: {
  id: string; label?: ReactNode; value?: string | [string, string] | null; range?: boolean; min?: string; max?: string;
  help?: ReactNode; className?: string;
}) {
  const init = range ? (Array.isArray(value) ? value : null) : (typeof value === "string" ? value : null);
  const [v, setV] = useShinyInput<string | string[] | null>(id, init, { debounceMs: 300, type: "tw.date" });
  const [lim, setLim] = useState({ min, max });
  useEffect(() => setLim({ min, max }), [min, max]);
  useServerUpdates(id, (u) => {
    if (u.minRaw !== undefined || u.maxRaw !== undefined) setLim((l) => ({ min: u.minRaw ?? l.min, max: u.maxRaw ?? l.max }));
    if (u.value !== undefined) setV(u.value === null ? null : Array.isArray(u.value) ? (u.value as unknown[]).map((x) => String(x ?? "")) : String(u.value));
  });
  const cur = Array.isArray(v) ? v : [v ?? "", ""];
  const set = (i: number, x: string) => {
    if (!range) { setV(x || null); return; }
    const n = [cur[0] ?? "", cur[1] ?? ""]; n[i] = x;
    setV(n[0] || n[1] ? n : null);
  };
  return (
    <Field id={id} label={label} help={help} className={className}>
      <div className="tw-dates">
        <input id={ctlId(id)} type="date" className="form-control form-control-sm" value={cur[0] ?? ""} min={lim.min} max={lim.max} onChange={(e) => set(0, e.target.value)} />
        {range ? <><span className="text-muted">to</span>
          <input type="date" className="form-control form-control-sm" value={cur[1] ?? ""} min={lim.min} max={lim.max} onChange={(e) => set(1, e.target.value)} /></> : null}
      </div>
    </Field>
  );
}

/* ------------------------------------------------------------- buttons */

type Variant = "primary" | "outline-primary" | "outline-secondary" | "outline-danger" | "danger" | "success" | "link" | "light";

/**
 * actionButton / actionLink: input$<id> counts the clicks from 0 (the server
 * observers ignore 0: the Shiny page never sent it). gate_button() freezes
 * it as before (www/gates.js).
 */
export function ActionButton({ id, label, icon, variant = "outline-primary", size = "sm", className, title, disabled, onClick, link }: {
  id: string; label?: ReactNode; icon?: ReactNode; variant?: Variant; size?: "sm" | "md"; className?: string; title?: string;
  disabled?: boolean; onClick?: () => void; link?: boolean;
}) {
  const click = useShinyButton(id);
  const ref = useRef<HTMLButtonElement>(null);
  // a re-render resets the class; the gate is applied again
  useEffect(() => { (window as unknown as { twGates?: { apply: (id: string) => void } }).twGates?.apply(id); });
  const cls = link ? "btn btn-link p-0 tw-link" : `btn btn-${variant}${size === "sm" ? " btn-sm" : ""}`;
  return (
    // data-shiny-no-bind-input: Shiny's own actionButton binding would also bind
    // it (.action-button) and every click would reach the server twice. (Browser
    // tests click it with tw_click(), react/dev/e2e.R: shinytest2's app$click() needs that binding.)
    <button ref={ref} id={id} type="button" className={`${cls} action-button${className ? " " + className : ""}`} title={title}
            data-shiny-no-bind-input="" disabled={disabled} onClick={() => { if (ref.current?.classList.contains("tw-frozen")) return; click(); onClick?.(); }}>
      {icon}{icon && label ? " " : null}{label}
    </button>
  );
}

/** downloadButton: the server's download_handler() under output$<id>. */
export function DownloadButton({ id, label, icon, variant = "outline-primary", size = "sm", className, title }: {
  id: string; label: ReactNode; icon?: ReactNode; variant?: Variant; size?: "sm" | "md"; className?: string; title?: string;
}) {
  useEffect(() => { (window as unknown as { twGates?: { apply: (id: string) => void } }).twGates?.apply(id); });
  return (
    <ShinyOutput id={id} tagName="a" title={title}
                 className={`btn btn-${variant}${size === "sm" ? " btn-sm" : ""} shiny-download-link${className ? " " + className : ""}`}
                 {...{ download: "", target: "_blank" }}>
      {icon}{icon ? " " : null}{label}
    </ShinyOutput>
  );
}

/* ---------------------------------------------------------- hosted UI */

/**
 * A server renderUI() / uiOutput() drawn as it was: for what has no React
 * equivalent (fileInput, leaflet maps, rich text editors) or is still HTML
 * the server writes. Shiny binds the inputs inside it.
 */
export function HostedUI({ id, className, style, inline }: { id: string; className?: string; style?: CSSProperties; inline?: boolean }) {
  return <ShinyOutput id={id} tagName={inline ? "span" : "div"} className={`shiny-html-output${className ? " " + className : ""}`} style={style} />;
}

/** A server renderText() / textOutput(). */
export function TextOutput({ id, className }: { id: string; className?: string }) {
  return <ShinyOutput id={id} tagName="span" className={`shiny-text-output${className ? " " + className : ""}`} />;
}
