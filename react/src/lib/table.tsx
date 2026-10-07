// Tables for the React pages: the server's render_react_table() output
// (R/utils_react_render.R) drawn with search, sorting, paging, selection,
// row bands, cell styles and editing. It keeps DT's inputs so the server code
// reading them is unchanged: <id>_rows_selected, <id>_rows_all, <id>_cell_edit.
// Large tables are paged by the server (<id>_state).
import { useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { ArrowDown, ArrowUp, ChevronLeft, ChevronRight, Search } from "lucide-react";
import { useVarLabels } from "./labels";
import { useOutputVisibility } from "./visibility";
import { useSetShinyInput, useShinyMessageHandler, useShinyOutputError, useShinyOutputValue, useShinyOutputStatus } from "@/shiny";

type Style = { cell?: { bg?: string; color?: string }; map?: Record<string, { bg?: string; color?: string }>; breaks?: number[]; colors?: string[]; text?: string[]; bar?: string };
type Col = { key: string; label: string; type: "number" | "date" | "datetime" | "logical" | "text"; format?: string | null; style?: Style | null; html?: boolean; editable?: boolean };
type Cell = string | number | boolean | null;
export type TablePayload = {
  columns: Col[]; rows: Cell[][]; index: number[]; total: number; filtered: number; page: number; server: boolean;
  page_size: number; selection: "none" | "single" | "multiple"; group?: string | null; empty?: string; height?: number | null;
};

const nf = new Intl.NumberFormat("en-US", { maximumFractionDigits: 2 });
const pad = (n: number) => String(n).padStart(2, "0");

/** A cell as text, the way the app shows numbers and dates (day / month / year). */
export function fmtCell(v: Cell, col: Col): string {
  if (v === null || v === undefined) return "";
  const f = col.format ?? "";
  if (col.type === "logical" || typeof v === "boolean") return v ? "Yes" : "No";
  if (col.type === "number" || typeof v === "number") {
    const n = Number(v);
    if (!isFinite(n)) return String(v);
    switch (f) {
      case "int": return Math.round(n).toLocaleString("en-US");
      case "dec1": return n.toLocaleString("en-US", { minimumFractionDigits: 1, maximumFractionDigits: 1 });
      case "dec2": return n.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      case "pct": return `${Math.round(100 * n)}%`;
      case "pct1": return `${(100 * n).toFixed(1)}%`;
      case "text": return String(n);
      default: return nf.format(n);
    }
  }
  const s = String(v);
  if (col.type === "date" || f === "date") { const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(s); return m ? `${m[3]}/${m[2]}/${m[1]}` : s; }
  if (col.type === "datetime" || f === "datetime") {
    const d = new Date(s);
    return isNaN(d.getTime()) ? s : `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()}, ${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }
  return s;
}

function cellStyle(v: Cell, col: Col, max: number): React.CSSProperties | undefined {
  const st = col.style;
  if (!st || v === null) return undefined;
  if (st.cell) return v === "" ? undefined : { background: st.cell.bg, color: st.cell.color ?? (st.cell.bg ? "#1f2a37" : undefined) };
  if (st.map) { const m = st.map[String(v)]; return m ? { background: m.bg, color: m.color ?? (m.bg ? "#1f2a37" : undefined) } : undefined; }
  if (st.breaks && st.colors) {
    const n = Number(v); if (!isFinite(n)) return undefined;
    let i = 0; while (i < st.breaks.length && n > st.breaks[i]) i++;
    return { background: st.colors[i], color: st.text?.[i] ?? "#1f2a37" };
  }
  if (st.bar) {
    const n = Number(v); if (!isFinite(n) || max <= 0) return undefined;
    const w = Math.max(0, Math.min(100, (100 * n) / max));
    return { backgroundImage: `linear-gradient(90deg, ${st.bar}33 ${w}%, transparent ${w}%)` };
  }
  return undefined;
}

const cmp = (a: Cell, b: Cell) => {
  if (a === null) return 1; if (b === null) return -1;
  if (typeof a === "number" && typeof b === "number") return a - b;
  return String(a).localeCompare(String(b), undefined, { numeric: true, sensitivity: "base" });
};

export function DataTable({ id, height, className, toolbar, searchable = true, compact }: {
  id: string; height?: number | string; className?: string; toolbar?: ReactNode; searchable?: boolean; compact?: boolean;
}) {
  const data = useShinyOutputValue<TablePayload>(id);
  useOutputVisibility(id);   // computed only while on screen
  const status = useShinyOutputStatus(id);
  const err = useShinyOutputError(id);
  const setSelected = useSetShinyInput<number[] | null>(`${id}_rows_selected`, null, { debounceMs: 0, type: "tw.num" });
  const setAll = useSetShinyInput<number[] | null>(`${id}_rows_all`, null, { debounceMs: 150, type: "tw.num" });
  const setState = useSetShinyInput<Record<string, unknown> | null>(`${id}_state`, null, { debounceMs: 250 });
  const setEdit = useSetShinyInput<Record<string, unknown> | null>(`${id}_cell_edit`, null, { debounceMs: 0, priority: "event" });

  const vl = useVarLabels();
  const [search, setSearch] = useState("");
  const [sort, setSort] = useState<{ key: string; desc: boolean } | null>(null);
  const [page, setPage] = useState(0);
  const [size, setSize] = useState<number | null>(null);
  const [sel, setSel] = useState<number[]>([]);
  const [editing, setEditing] = useState<{ row: number; col: number; value: string } | null>(null);

  const cols = data?.columns ?? [];
  const pageSize = size ?? data?.page_size ?? 15;
  const server = !!data?.server;

  // new data (not a new page of the same data): selection cleared, as DT does
  const sig = data ? `${cols.map((c) => c.key).join("|")}#${data.total}#${server ? "" : data.index.slice(0, 50).join(",")}` : "";
  const lastSig = useRef("");
  useEffect(() => {
    if (!data || sig === lastSig.current) return;
    const first = lastSig.current === "";
    lastSig.current = sig;
    if (!first || sel.length) { setSel([]); setSelected(null); }
    if (!server) setPage(0);
  }, [sig]); // eslint-disable-line

  useShinyMessageHandler<{ rows: number[] }>(`${id}__select`, (m) => { const r = m.rows ?? []; setSel(r); setSelected(r.length ? r : null); });

  // the server pages large tables
  useEffect(() => { if (server) setState({ page, size: pageSize, sort: sort?.key ?? "", desc: !!sort?.desc, search }); },
    [server, page, pageSize, sort, search]); // eslint-disable-line

  // client side: search, sort, page
  const rows = useMemo(() => {
    if (!data) return [] as { cells: Cell[]; row: number }[];
    let r = data.rows.map((cells, i) => ({ cells, row: data.index[i] }));
    if (server) return r;
    const q = search.trim().toLowerCase();
    if (q) r = r.filter((x) => x.cells.some((c, j) => c !== null && (cols[j].html ? String(c).replace(/<[^>]+>/g, "") : fmtCell(c, cols[j])).toLowerCase().includes(q)));
    if (sort) { const j = cols.findIndex((c) => c.key === sort.key); if (j >= 0) r = [...r].sort((a, b) => (sort.desc ? -1 : 1) * cmp(a.cells[j], b.cells[j])); }
    return r;
  }, [data, search, sort, server, cols]);

  const allKey = server ? "" : rows.map((r) => r.row).join(",");
  useEffect(() => { if (data && !server) setAll(rows.map((r) => r.row)); }, [allKey]); // eslint-disable-line

  const filtered = server ? data?.filtered ?? 0 : rows.length;
  const pages = Math.max(1, Math.ceil(filtered / pageSize));
  const at = server ? data?.page ?? 0 : Math.min(page, pages - 1);
  const shown = server ? rows : rows.slice(at * pageSize, at * pageSize + pageSize);
  const max = useMemo(() => {
    const m: number[] = cols.map((c, j) => (c.style?.bar ? Math.max(0, ...(data?.rows ?? []).map((r) => Number(r[j]) || 0)) : 0));
    return m;
  }, [data, cols]);

  if (err?.message) return <div className="tw-output-note" id={id}>{err.message}</div>;
  if (!data) return <div className={`tw-dt tw-dt-empty${status === "recalculating" ? " recalculating" : ""}`} id={id} />;
  const mode = data.selection;
  const pick = (row: number) => {
    if (mode === "none") return;
    const next = mode === "single" ? (sel[0] === row ? [] : [row]) : sel.includes(row) ? sel.filter((x) => x !== row) : [...sel, row];
    setSel(next); setSelected(next.length ? next : null);
  };
  const pageRows = shown.map((r) => r.row);
  const allOnPage = mode === "multiple" && pageRows.length > 0 && pageRows.every((r) => sel.includes(r));
  const togglePage = () => {
    const next = allOnPage ? sel.filter((r) => !pageRows.includes(r)) : [...new Set([...sel, ...pageRows])];
    setSel(next); setSelected(next.length ? next : null);
  };
  const sortBy = (key: string) => { setSort((s) => (s?.key === key ? (s.desc ? null : { key, desc: true }) : { key, desc: false })); setPage(0); };
  const gi = data.group ? cols.findIndex((c) => c.key === data.group) : -1;
  const shownCols = cols.filter((_, j) => j !== gi);
  const h = height ?? data.height ?? undefined;

  const commit = () => {
    if (!editing) return;
    setEdit({ row: editing.row, col: editing.col + 1, value: editing.value, nonce: Date.now() });
    setEditing(null);
  };

  let lastGroup: Cell | undefined;
  return (
    <div className={`tw-dt${compact ? " tw-dt-compact" : ""}${status === "recalculating" ? " recalculating" : ""}${className ? " " + className : ""}`} id={id}>
      {(searchable || toolbar) && (
        <div className="tw-dt-top">
          <div className="d-flex align-items-center gap-2 flex-wrap">{toolbar}</div>
          {searchable && (
            <label className="tw-search">
              <Search size={13} />
              <input type="search" className="form-control form-control-sm" placeholder="Search" value={search}
                     onChange={(e) => { setSearch(e.target.value); setPage(0); }} />
            </label>
          )}
        </div>
      )}
      {!filtered ? (
        <div className="tw-dt-none">{search ? "No row matches." : data.empty ?? "No data."}</div>
      ) : (
        <div className="tw-table-wrap" style={h ? { maxHeight: h } : undefined}>
          <table className="table table-sm table-hover tw-table mb-0">
            <thead>
              <tr>
                {mode === "multiple" && (
                  <th className="tw-dt-check"><input type="checkbox" className="form-check-input" checked={allOnPage} onChange={togglePage} aria-label="Select the rows of this page" /></th>
                )}
                {shownCols.map((c) => (
                  <th key={c.key} onClick={() => sortBy(c.key)} className={c.type === "number" ? "text-end" : undefined}
                      aria-sort={sort?.key === c.key ? (sort.desc ? "descending" : "ascending") : "none"} data-col={c.key}
                      title={vl.label(c.key) ?? undefined}>
                    {c.label} {sort?.key === c.key && (sort.desc ? <ArrowDown size={11} /> : <ArrowUp size={11} />)}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {shown.map((r) => {
                const band = gi >= 0 && r.cells[gi] !== lastGroup;
                lastGroup = gi >= 0 ? r.cells[gi] : undefined;
                const on = sel.includes(r.row);
                return [
                  band ? <tr key={`g${r.row}`} className="tw-dt-group"><td colSpan={shownCols.length + (mode === "multiple" ? 1 : 0)}>{fmtCell(r.cells[gi], cols[gi])}</td></tr> : null,
                  <tr key={r.row} className={on ? "tw-dt-selected" : undefined} onClick={() => pick(r.row)}
                      style={mode !== "none" ? { cursor: "pointer" } : undefined}>
                    {mode === "multiple" && (
                      <td className="tw-dt-check"><input type="checkbox" className="form-check-input" checked={on} onChange={() => pick(r.row)} onClick={(e) => e.stopPropagation()} aria-label="Select" /></td>
                    )}
                    {cols.map((c, j) => {
                      if (j === gi) return null;
                      const v = r.cells[j];
                      if (editing && editing.row === r.row && editing.col === j) {
                        return (
                          <td key={c.key} onClick={(e) => e.stopPropagation()}>
                            <input autoFocus className="form-control form-control-sm" value={editing.value}
                                   onChange={(e) => setEditing({ ...editing, value: e.target.value })}
                                   onKeyDown={(e) => { if (e.key === "Enter") commit(); if (e.key === "Escape") setEditing(null); }} onBlur={commit} />
                          </td>
                        );
                      }
                      const props = {
                        key: c.key, style: cellStyle(v, c, max[j]),
                        className: `${c.type === "number" ? "text-end" : ""}${c.editable ? " tw-dt-editable" : ""}`,
                        title: c.editable ? "Double-click to edit" : undefined,
                        onDoubleClick: c.editable ? (e: React.MouseEvent) => { e.stopPropagation(); setEditing({ row: r.row, col: j, value: v === null ? "" : String(v) }); } : undefined,
                      };
                      if (c.html) return <td {...props} dangerouslySetInnerHTML={{ __html: String(v ?? "") }} />;
                      // a variable named in the first column gets its label under it
                      const lab = j === (gi === 0 ? 1 : 0) && typeof v === "string" && vl.isVar(v) ? vl.label(v) : null;
                      return <td {...props}>{fmtCell(v, c)}{lab ? <span className="tw-opt-label d-block">{lab}</span> : null}</td>;
                    })}
                  </tr>,
                ];
              })}
            </tbody>
          </table>
        </div>
      )}
      {filtered > 0 && (
        <div className="tw-dt-foot">
          <span>
            {at * pageSize + 1}-{Math.min(filtered, at * pageSize + pageSize)} of {filtered.toLocaleString("en-US")}
            {filtered < data.total ? ` (filtered from ${data.total.toLocaleString("en-US")})` : ""}
            {sel.length ? ` · ${sel.length} selected` : ""}
          </span>
          <div className="d-flex align-items-center gap-2">
            <select className="form-select form-select-sm tw-dt-size" value={pageSize} onChange={(e) => { setSize(Number(e.target.value)); setPage(0); }} aria-label="Rows per page">
              {[10, 15, 25, 50, 100].map((n) => <option key={n} value={n}>{n} rows</option>)}
            </select>
            <div className="btn-group btn-group-sm">
              <button type="button" className="btn btn-outline-secondary" disabled={at === 0} onClick={() => setPage(at - 1)} aria-label="Previous page"><ChevronLeft size={14} /></button>
              <button type="button" className="btn btn-outline-secondary" disabled={at >= pages - 1} onClick={() => setPage(at + 1)} aria-label="Next page"><ChevronRight size={14} /></button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
