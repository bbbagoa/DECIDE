// Category values (R/mod_dq_values.R): every qualitative variable scanned for
// answers typed several ways (and the same answer in other words). Left, the
// variables with a bar of their answers; right, the chosen variable's groups
// as cards (target editable, variants as chips with their differences shown)
// and its values for a merge by hand; below, what was applied, before / after.
// The page sends what to apply (input$val_apply); the server confirms it in a
// dialog, applies it to the whole data and writes the audit trail.
import { useMemo, useRef, useState } from "react";
import { ArrowLeft, CheckCheck, Hash, History, Info, Languages, ListChecks, Merge, ScanSearch, Tags, Wand2 } from "lucide-react";
import { useShinyInputValue, useShinyOutputStatus, useShinyOutputValue } from "@/shiny";
import { Busy } from "@/lib/layout";
import { useOutputVisibility } from "@/lib/visibility";
import { ActionButton, SliderInput } from "@/lib/inputs";
import { EmptyState, Ring } from "@/components/Figures";
import { Kpis, ns, type T } from "./common";

type Member = { value: string; n: number; main: boolean; kind: string; source?: string };
type Group = { id: number; target: string; translation: boolean; code: boolean; members: Member[] };
type Variable = {
  name: string; label: string; distinct: number; records: number; to_fix: number; variants: number; kept: boolean; would_fix: number;
  mixed: boolean; odd: number; numbers: { value: string; n: number; to: string; source: string }[];
  groups: Group[]; bar: { value: string; n: number; variant: boolean }[]; rest: number; values: { value: string; n: number }[];
};
type Hist = { variable: string; before: number; after: number; changed: number; values: number; at: string };
type View = {
  sim: number; variables: Variable[]; history: Hist[];
  totals: { scanned: number; to_harmonise: number; values: number; records: number; consistent: number; mixed: number };
} | null;
type Edit = { target?: string; tick?: boolean; off?: string[] };

const n0 = (x?: number) => Math.round(x ?? 0).toLocaleString("en-US");
/** One colour per answer on the bars (WFP tokens first, then softer ones). */
const PALETTE = ["#007DBC", "#26bde2", "#3f7e44", "#f7b825", "#c5192d", "#8e6bbf", "#e07b39", "#5b6b7c"];
type ShinyApi = { setInputValue: (id: string, v: unknown, o?: { priority: string }) => void };
const send = (changes: { col: string; from: string[]; to: string[] }[]) =>
  (window as unknown as { Shiny?: ShinyApi }).Shiny?.setInputValue(ns("val_apply"), { changes, at: Date.now() }, { priority: "event" });
const gkey = (v: string, g: Group) => `${v}\u0001${g.target}`;
/** Mark a variable clean (kept as it is), or take the mark back. */
const keep = (col: string, on: boolean) =>
  (window as unknown as { Shiny?: ShinyApi }).Shiny?.setInputValue(ns("val_keep"), { col, keep: on, at: Date.now() }, { priority: "event" });

/** What a group changes: its values (not left out) become the target. */
function groupChange(g: Group, e: Edit | undefined) {
  const target = (e?.target ?? g.target).trim();
  const off = new Set(e?.off ?? []);
  const from = g.members.map((m) => m.value).filter((v) => v !== target && !off.has(v));
  return { target, from };
}
const ticked = (g: Group, e?: Edit) => e?.tick ?? !g.translation;

export function ValuesTab({ t }: { t: T }) {
  const v = useShinyOutputValue<View>(ns("val_view"));
  const status = useShinyOutputStatus(ns("val_view"));
  const here = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("val_view"), here);
  const simNow = useShinyInputValue<number>(ns("val_similarity"));
  const [pick, setPick] = useState<string | null>(null);
  const [edits, setEdits] = useState<Record<string, Edit>>({});
  const vars = v?.variables ?? [];
  const cur = vars.find((x) => x.name === pick) ?? vars[0];
  const setEdit = (k: string, e: Edit) => setEdits((s) => ({ ...s, [k]: { ...s[k], ...e } }));

  // every ticked group of every variable
  const allChanges = useMemo(() => vars.filter((x) => !x.kept).map((x) => {
    const from: string[] = [], to: string[] = [];
    x.groups.forEach((g) => {
      const e = edits[gkey(x.name, g)];
      if (!ticked(g, e)) return;
      const c = groupChange(g, e);
      if (c.target) c.from.forEach((f) => { from.push(f); to.push(c.target); });
    });
    return { col: x.name, from, to };
  }).filter((c) => c.from.length), [vars, edits]);
  const nTicked = allChanges.reduce((s, c) => s + c.from.length, 0);

  return (
    <div ref={here} className="tw-val">
      <Busy show={status === "recalculating" && !!v} label={t("Scanning the variables...")} />
      {/* 1. one header: what this does, how strict, scan, apply everything */}
      <div className="card tw-card tw-val-head">
        <div className="card-body">
          <div className="tw-val-head-text">
            <Tags size={18} className="tw-val-head-icon" />
            <div>
              <div className="fw-semibold">{t("Harmonise the answers of qualitative variables")}</div>
              <div className="small text-muted">
                {t("The same answer typed several ways is grouped; the most common spelling is suggested.")}{" "}
                <span className="tw-val-info" title={t("Answers that differ only by case, accents, punctuation or spaces are always grouped; small typos are grouped at the similarity chosen. Answers in other words (Oui / Yes, Homme / Male) are proposed as translations, not ticked: check them first. Area names are handled in Location names.")}><Info size={13} /></span>
              </div>
            </div>
          </div>
          <div className="tw-val-head-set">
            <SliderInput id={ns("val_similarity")} label={t("Grouping: loose ↔ strict")} min={50} max={100} step={5} value={85}
                         format={(x) => `${x}%`} />
          </div>
          <div className="tw-val-head-go">
            <div className="tw-val-head-btns">
            <ActionButton id={ns("val_scan")} label={t("Re-scan")} icon={<ScanSearch size={13} />} variant="outline-secondary" />
            <button type="button" className="btn btn-primary btn-sm" disabled={!nTicked} onClick={() => send(allChanges)}>
              <CheckCheck size={14} /> {t("Apply all ticked")} ({nTicked})
            </button>
            </div>
            {v && simNow != null && Math.round(simNow) !== v.sim && (
              <div className="tw-val-pending">{t("Re-scan to group at")} {simNow}%</div>)}
          </div>
        </div>
      </div>

      {!v ? (
        <div className="card tw-card"><div className="card-body">
          <EmptyState title={t("Scanning the qualitative variables...")} sub={t("Load and map the data first if nothing shows.")} />
        </div></div>
      ) : !vars.length ? (
        <div className="card tw-card"><div className="card-body">
          <EmptyState title={t("No qualitative variable to harmonise")} sub={t("Text variables with a few hundred answers at most are checked here; area names are in Location names.")} />
        </div></div>
      ) : (
        <>
          {/* 2. figures: how consistent the answers already are */}
          <div className="tw-val-figs">
            <div className="card tw-card tw-val-ring">
              <Ring tile={{ label: t("Records already consistent"), value: `${Math.floor(100 * v.totals.consistent)}%`, share: v.totals.consistent }} />
            </div>
            <Kpis items={[
              { label: t("Variables to harmonise"), icon: <Tags size={16} />, tone: "amber", value: `${n0(v.totals.to_harmonise)} / ${n0(v.totals.scanned)}`, sub: t("scanned") },
              { label: t("Values to merge"), icon: <Merge size={16} />, tone: "cyan", value: n0(v.totals.values) },
              { label: t("Records affected"), icon: <Wand2 size={16} />, tone: "blue", value: n0(v.totals.records) },
            ]} />
          </div>

          {/* 3. variables on the left, the chosen one's groups on the right */}
          <div className="tw-val-main">
            <div className="tw-val-list">
              {vars.map((x, i) => (
                <div key={x.name} className="contents">
                  {x.to_fix === 0 && !x.mixed && (i === 0 || vars[i - 1].to_fix > 0 || vars[i - 1].mixed) && (
                    <div className="tw-val-list-sep">{t("Clean or kept")} ({vars.filter((y) => y.to_fix === 0 && !y.mixed).length})</div>)}
                  <VarCard x={x} active={x.name === cur?.name} onClick={() => setPick(x.name)} t={t} />
                </div>
              ))}
            </div>
            {cur && <Detail key={cur.name} x={cur} edits={edits} setEdit={setEdit} t={t} />}
            {/* 5. before / after, beside the corrections */}
            <div className="tw-val-hist-panel">
              <div className="tw-val-hist-head"><History size={15} /> {t("Applied in this session")}</div>
              {!v.history.length
                ? <div className="tw-val-hist-empty">{t("Nothing applied yet. Each change shows here: the variable, its distinct values before and after, and the records changed.")}</div>
                : v.history.map((h, i) => (
                  <div key={i} className="tw-val-hist">
                    <div className="tw-val-hist-top"><strong>{h.variable}</strong><span className="tw-val-hist-at">{h.at}</span></div>
                    <div className="tw-val-hist-change">
                      <span className="tw-val-hist-before">{h.before}</span><span className="text-muted">&rarr;</span>
                      <span className="tw-val-hist-after">{h.after}</span><span className="text-muted small">{t("distinct values")}</span>
                    </div>
                    <div className="tw-val-hist-sub">{n0(h.changed)} {t("records changed")}</div>
                  </div>
                ))}
            </div>
          </div>

        </>
      )}
    </div>
  );
}

/** A variable: status, a bar of its answers (variants in amber), its figures. */
function VarCard({ x, active, onClick, t }: { x: Variable; active: boolean; onClick: () => void; t: T }) {
  const tot = Math.max(1, x.records);
  return (
    <button type="button" className={`tw-val-var${active ? " active" : ""}${x.to_fix || x.mixed ? "" : " clean"}${x.kept ? " kept" : ""}`} onClick={onClick}>
      <div className="tw-val-var-top">
        <span className="tw-val-var-name" title={x.label || x.name}>{x.name}</span>
        {x.kept
          ? <span className="tw-val-chip kept">{t("Kept as is")}</span>
          // text mixed with numbers is explained in the correction panel, no badge here
          : x.mixed && x.to_fix === 0
            ? null
          : x.to_fix > 0
            ? <span className="tw-val-chip warn">{x.variants} {t("to merge")}</span>
            : <span className="tw-val-chip ok">{t("Clean")}</span>}
      </div>
      {x.label && <div className="tw-val-var-label">{x.label}</div>}
      <div className="tw-val-bar" aria-hidden>
        {x.bar.map((b, i) => {
          const c = PALETTE[i % PALETTE.length];
          return (
            <span key={b.value} className={b.variant && !x.kept ? "variant" : ""} title={`${b.value}: ${n0(b.n)}${b.variant && !x.kept ? ` (${t("variant")})` : ""}`}
                  style={{ width: `${(100 * b.n) / tot}%`, background: b.variant && !x.kept
                    ? `repeating-linear-gradient(135deg, ${c} 0 3px, rgba(255,255,255,.55) 3px 5px)` : c }} />
          );
        })}
        {x.rest > 0 && <span className="rest" style={{ width: `${(100 * x.rest) / tot}%` }} />}
      </div>
      <div className="tw-val-var-meta">{n0(x.distinct)} {t("values")}{x.to_fix > 0 ? ` · ${n0(x.to_fix)} ${t("records to harmonise")}` : ""}{x.mixed && x.to_fix === 0 ? ` · ${x.numbers.length} ${t("numeric answers")}` : ""}</div>
    </button>
  );
}

function Detail({ x, edits, setEdit, t }: { x: Variable; edits: Record<string, Edit>; setEdit: (k: string, e: Edit) => void; t: T }) {
  const change = () => {
    const from: string[] = [], to: string[] = [];
    x.groups.forEach((g) => {
      const e = edits[gkey(x.name, g)];
      if (!ticked(g, e)) return;
      const c = groupChange(g, e);
      if (c.target) c.from.forEach((f) => { from.push(f); to.push(c.target); });
    });
    return { col: x.name, from, to };
  };
  const c = change();
  const all = (on: boolean) => x.groups.forEach((g) => setEdit(gkey(x.name, g), { tick: on }));
  return (
    <div className="tw-val-detail">
      <div className="tw-val-detail-head">
        <div>
          <div className="fw-semibold">{x.name}</div>
          {x.label && <div className="small text-muted">{x.label}</div>}
        </div>
        {x.kept ? (
          <button type="button" className="btn btn-outline-secondary btn-sm" onClick={() => keep(x.name, false)}>{t("Undo: review it again")}</button>
        ) : (x.groups.length > 0 || x.mixed) && (
          <div className="d-flex gap-2 align-items-center flex-wrap">
            <button type="button" className="btn btn-outline-secondary btn-sm" onClick={() => keep(x.name, true)}
                    title={t("Keep this variable as it is: it leaves the figures and Apply all ticked")}>{t("Mark as clean")}</button>
            <button type="button" className="btn btn-link btn-sm p-0" onClick={() => all(true)}>{t("Tick all")}</button>
            <button type="button" className="btn btn-link btn-sm p-0" onClick={() => all(false)}>{t("Untick all")}</button>
            <button type="button" className="btn btn-primary btn-sm" disabled={!c.from.length} onClick={() => send([c])}>
              <Wand2 size={13} /> {t("Apply this variable")} ({c.from.length})
            </button>
          </div>
        )}
      </div>

      {x.mixed && (
        <div className="tw-val-mixed">
          <strong>{t("Text and numbers are mixed in this variable.")}</strong>{" "}
          {t("These answers are numbers among text answers (codes never labelled, or typed in the wrong field). Where the text they stand for is known, it is suggested in the groups below; merge the others by hand, or mark the variable as clean if that is how it should be.")}
          <div className="tw-val-chips mt-1">
            {x.numbers.map((m) => (
              <span key={m.value} className="tw-val-vchip num"><span>{m.value}</span><em>{n0(m.n)}</em>
                {m.to ? <><span className="text-muted">&rarr;</span> <b>{m.to}</b></> : null}</span>
            ))}
          </div>
          {x.numbers.some((m) => m.to) && (
            <div className="small mt-1">
              {x.numbers.some((m) => m.source === "labels")
                ? t("Suggested from the variable's value labels, in the groups below (ticked).")
                : t("Suggested from the usual codes (1 = Yes, 0 = No; 1 = Male, 2 = Female), in the groups below (ticked): check them before applying.")}
            </div>)}
        </div>
      )}
      {x.kept
        ? <div className="tw-val-clean kept"><CheckCheck size={16} /> {t("Marked as clean: kept as it is.")} {x.would_fix > 0 ? `${n0(x.would_fix)} ${t("records would otherwise be harmonised.")}` : ""}</div>
        : x.groups.length === 0
        ? (x.mixed ? null : <div className="tw-val-clean"><CheckCheck size={16} /> {t("Every answer of this variable is written one way. Merge answers in other words by hand below.")}</div>)
        : x.groups.map((g) => <GroupCard key={g.id + g.target} g={g} e={edits[gkey(x.name, g)]} onEdit={(e) => setEdit(gkey(x.name, g), e)} t={t} />)}

      <ManualMerge x={x} t={t} />
    </div>
  );
}

/** A group: tick, the value it becomes (editable), its variants as chips. */
function GroupCard({ g, e, onEdit, t }: { g: Group; e?: Edit; onEdit: (e: Edit) => void; t: T }) {
  const on = ticked(g, e);
  const target = e?.target ?? g.target;
  const off = new Set(e?.off ?? []);
  const main = g.members.find((m) => m.main);
  const variants = g.members.filter((m) => !m.main);
  const toggle = (v: string) => onEdit({ off: off.has(v) ? [...off].filter((x) => x !== v) : [...off, v] });
  return (
    <div className={`tw-val-group${on ? "" : " off"}${g.translation ? " translation" : ""}`}>
      <input type="checkbox" className="form-check-input" checked={on} onChange={(ev) => onEdit({ tick: ev.target.checked })}
             aria-label={t("Apply this group")} />
      <div className="tw-val-target">
        <input className="form-control form-control-sm" value={target} onChange={(ev) => onEdit({ target: ev.target.value })}
               aria-label={t("The value they become")} />
        {main && <span className="tw-val-target-n">{n0(main.n)}</span>}
      </div>
      <ArrowLeft size={15} className="tw-val-arrow" aria-hidden />
      <div className="tw-val-chips">
        {variants.map((m) => (
          <button key={m.value} type="button" className={`tw-val-vchip${off.has(m.value) ? " out" : ""}${m.kind === "translation" ? " tr" : ""}${m.kind === "code" ? " code" : ""}`}
                  onClick={() => toggle(m.value)}
                  title={off.has(m.value) ? t("Left out: click to merge it again")
                    : m.kind === "code" ? `${t(m.source === "labels" ? "Code read from the variable's value labels" : "Usual code (1 = Yes, 0 = No; 1 = Male, 2 = Female): check it")}. ${t("Click to leave this value out")}`
                    : t("Click to leave this value out")}>
            {m.kind === "translation" ? <><Languages size={11} /> <span>{shown(m.value)}</span></>
              : m.kind === "code" ? <><Hash size={11} /> <span>{m.value}</span></>
              : <Diff a={m.value} b={target} />}
            <em>{n0(m.n)}</em>
          </button>
        ))}
        {g.translation && <span className="tw-val-tr-note">{t("Other words: check before ticking")}</span>}
      </div>
    </div>
  );
}

/** Values merged by hand (answers in other words the scan cannot guess). */
function ManualMerge({ x, t }: { x: Variable; t: T }) {
  const [sel, setSel] = useState<string[]>([]);
  const [to, setTo] = useState("");
  // from the latest selection (two quick clicks must both count)
  const pickV = (v: string) => setSel((cur) => cur.includes(v) ? cur.filter((s) => s !== v) : [...cur, v]);
  // the suggested name: the most common of the picked answers, while nothing is typed
  const suggested = x.values.filter((y) => sel.includes(y.value)).sort((a, b) => b.n - a.n)[0]?.value ?? "";
  return (
    <div className="tw-val-manual">
      <div className="tw-val-manual-head"><ListChecks size={14} /> {t("Merge by hand")}
        <span className="small text-muted ms-2">{t("Click the answers that mean the same (e.g. Homme and Male), type what they become.")}</span></div>
      <div className="tw-val-chips">
        {x.values.slice(0, 120).map((y) => (
          <button key={y.value} type="button" className={`tw-val-vchip plain${sel.includes(y.value) ? " picked" : ""}`} onClick={() => pickV(y.value)}>
            <span>{shown(y.value)}</span><em>{n0(y.n)}</em>
          </button>
        ))}
        {x.values.length > 120 && <span className="small text-muted">+{x.values.length - 120}</span>}
      </div>
      <div className="tw-val-manual-go">
        <input className="form-control form-control-sm" placeholder={suggested || t("They become...")} value={to} onChange={(e) => setTo(e.target.value)} />
        <button type="button" className="btn btn-outline-primary btn-sm" disabled={sel.length < 1 || !(to.trim() || suggested)}
                onClick={() => { const v = to.trim() || suggested; send([{ col: x.name, from: sel, to: sel.map(() => v) }]); setSel([]); setTo(""); }}>
          <Merge size={13} /> {t("Merge")} ({sel.length})
        </button>
      </div>
    </div>
  );
}

/** Spaces made visible at the ends and where doubled. */
const shown = (s: string) => s.replace(/^ +| +$/g, (m) => "␣".repeat(m.length)).replace(/ {2,}/g, (m) => "␣".repeat(m.length));

/** 4. The variant with what differs from the target marked: case or accent
 *  (soft), extra or different letters and spaces (strong). */
function Diff({ a, b }: { a: string; b: string }) {
  const base = (s: string) => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
  const A = [...a], B = [...b], na = A.map(base), nb = B.map(base);
  // longest common subsequence on the letters without case or accents
  const L = Array.from({ length: A.length + 1 }, () => new Array<number>(B.length + 1).fill(0));
  for (let i = A.length - 1; i >= 0; i--) for (let j = B.length - 1; j >= 0; j--)
    L[i][j] = na[i] === nb[j] ? L[i + 1][j + 1] + 1 : Math.max(L[i + 1][j], L[i][j + 1]);
  const mark: ("" | "soft" | "strong")[] = new Array(A.length).fill("strong");
  for (let i = 0, j = 0; i < A.length && j < B.length;) {
    if (na[i] === nb[j]) { mark[i] = A[i] === B[j] ? "" : "soft"; i++; j++; }
    else if (L[i + 1][j] >= L[i][j + 1]) i++; else j++;
  }
  return (
    <span className="tw-val-diff">
      {A.map((ch, i) => mark[i]
        ? <mark key={i} className={mark[i]}>{ch === " " ? "␣" : ch}</mark>
        : <span key={i}>{ch}</span>)}
    </span>
  );
}
