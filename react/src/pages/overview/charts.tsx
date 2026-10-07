// The Overview's charts, drawn from the server's facts (ECharts, the toolkit's
// EChart with the WFP theme, light or dark).
import { useEffect, useMemo, useState } from "react";
import { EChart } from "@/lib/chart";
import { AREA_COLS, WFP, num, pct } from "@/components/Figures";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type P = any;
const dmy = (iso: string) => { const [y, m, d] = iso.split("-"); return `${d}/${m}/${y}`; };
const dm = (iso: string) => { const [, m, d] = iso.split("-"); return `${d}/${m}`; };
const esc = (s: string) => s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c] as string);
// value labels in the theme's text colour (left to ECharts, dark mode drew
// them with a stroke)
const small = (dark: boolean) => ({ fontSize: 9, textBorderWidth: 0, color: dark ? "#c9d1dc" : "#5b6b7c" });
function useDark(): boolean {
  const get = () => document.documentElement.getAttribute("data-bs-theme") === "dark";
  const [dark, setDark] = useState(get);
  useEffect(() => {
    const mo = new MutationObserver(() => setDark(get()));
    mo.observe(document.documentElement, { attributes: true, attributeFilter: ["data-bs-theme"] });
    return () => mo.disconnect();
  }, []);
  return dark;
}

/** Households per day: bars by area (or one total) and the cumulative count on a right axis. */
export function DailyChart({ daily, byArea, areas, height = 205 }: {
  daily: { day: string; area: string; n: number }[]; byArea: boolean; areas: string[]; height?: number;
}) {
  const option = useMemo(() => {
    const days = [...new Set(daily.map((d) => d.day))].sort();
    const keys = byArea ? [...new Set(daily.map((d) => d.area))].sort((a, b) => areas.indexOf(a) - areas.indexOf(b)) : ["Households"];
    const at = new Map(days.map((d, i) => [d, i]));
    const val = keys.map(() => days.map(() => 0));
    for (const d of daily) val[byArea ? keys.indexOf(d.area) : 0][at.get(d.day)!] += d.n;
    let c = 0;
    const cum = days.map((_, i) => (c += keys.reduce((s, _k, j) => s + val[j][i], 0)));
    const colour = (k: string) => (byArea ? AREA_COLS[areas.indexOf(k) % AREA_COLS.length] : WFP.blue);
    return {
      grid: { left: 4, right: 4, top: byArea ? 26 : 10, bottom: 2, containLabel: true },
      legend: byArea ? { top: 0, left: 0, type: "scroll", data: keys, textStyle: { fontSize: 10 }, itemWidth: 8, itemHeight: 8 } : { show: false },
      tooltip: {
        trigger: "axis", axisPointer: { type: "shadow" },
        formatter: (ps: P[]) => `<b>${dmy(days[ps[0].dataIndex])}</b><br>` + ps.filter((p) => p.value > 0 || p.seriesName === "Cumulative")
          .map((p) => `${p.marker}${p.seriesName === "Cumulative" ? "In all" : esc(p.seriesName)}: <b>${num(p.value)}</b>`).join("<br>"),
      },
      xAxis: { type: "category", data: days.map(dm), axisLabel: { hideOverlap: true } },
      yAxis: [{ type: "value", minInterval: 1 }, { type: "value", minInterval: 1, splitLine: { show: false } }],
      series: [
        ...keys.map((k, j) => ({ type: "bar", stack: "d", name: k, data: val[j], itemStyle: { color: colour(k), borderRadius: 0 }, barCategoryGap: "15%" })),
        { type: "line", name: "Cumulative", yAxisIndex: 1, data: cum, showSymbol: false, lineStyle: { type: "dashed", width: 1.5, color: WFP.slate }, itemStyle: { color: WFP.slate } },
      ],
    };
  }, [daily, byArea, areas]);
  return <EChart option={option} height={height} />;
}

/** Horizontal bars with the value at their end; the first row on top. */
function hbars(rows: { label: string; value: number; colour: string; tip: string }[], fmt: (v: number) => string, dark: boolean): P {
  const max = Math.max(0, ...rows.map((r) => r.value));
  return {
    grid: { left: 4, right: 36, top: 4, bottom: 4, containLabel: true },
    tooltip: { trigger: "item", formatter: (p: P) => rows[p.dataIndex].tip },
    xAxis: { type: "value", show: false, max: max * 1.2 || 1 },
    yAxis: { type: "category", inverse: true, data: rows.map((r) => r.label), axisLabel: { width: 120, overflow: "truncate" } },
    series: [{
      type: "bar", barMaxWidth: 16,
      data: rows.map((r) => ({ value: r.value, itemStyle: { color: r.colour } })),
      label: { show: true, position: "right", ...small(dark), formatter: (p: P) => fmt(p.value) },
    }],
  };
}

/** Shares: columns for ordered bins (ages, sizes), horizontal bars for categories. */
export function ShareChart({ data, kind, height = 170 }: { data: { category: string; n: number }[]; kind: string; height?: number }) {
  const dark = useDark();
  const option = useMemo(() => {
    const total = data.reduce((s, d) => s + d.n, 0) || 1;
    const tip = (d: { category: string; n: number }) => `${esc(d.category)}: <b>${pct(d.n / total, 1)}</b> (${num(d.n)} households)`;
    if (kind !== "bins") return hbars(data.map((d) => ({ label: d.category, value: d.n / total, colour: WFP.blue, tip: tip(d) })), (v) => pct(v), dark);
    const max = Math.max(0, ...data.map((d) => d.n / total));
    return {
      grid: { left: 4, right: 4, top: 16, bottom: 2, containLabel: true },
      tooltip: { trigger: "item", formatter: (p: P) => tip(data[p.dataIndex]) },
      xAxis: { type: "category", data: data.map((d) => d.category), axisLabel: { interval: 0, hideOverlap: true } },
      yAxis: { type: "value", show: false, max: max * 1.15 || 1 },
      series: [{
        type: "bar", barCategoryGap: "20%", itemStyle: { color: WFP.blue, borderRadius: [3, 3, 0, 0] }, data: data.map((d) => d.n / total),
        label: { show: true, position: "top", ...small(dark), formatter: (p: P) => pct(p.value) },
      }],
    };
  }, [data, kind, dark]);
  const h = kind === "bins" ? height : Math.max(height, 24 * data.length + 12);
  return <EChart option={option} height={h} />;
}

/** Households by vulnerability group, coloured from least to most severe. */
export function GroupsChart({ groups, height = 200 }: { groups: { group: string; households: number; people: number; colour: string }[]; height?: number }) {
  const dark = useDark();
  const option = useMemo(() => {
    const total = groups.reduce((s, g) => s + g.households, 0) || 1;
    return hbars(groups.map((g) => ({
      label: g.group, value: g.households / total, colour: g.colour,
      tip: `${esc(g.group)}: <b>${pct(g.households / total, 1)}</b> of households, ${num(g.people)} people`,
    })), (v) => pct(v), dark);
  }, [groups, dark]);
  return <EChart option={option} height={Math.max(height, 28 * groups.length + 12)} />;
}

/** The chosen indicator across household profiles: one bar per category, coloured by dimension. */
export function CrossChart({ rows, pctScale, overall, label }: {
  rows: { dimension: string; category: string; value: number; households: number }[]; pctScale: boolean; overall: number | null; label: string;
}) {
  const dims = useMemo(() => [...new Set(rows.map((r) => r.dimension))], [rows]);
  const dark = useDark();
  const option = useMemo(() => {
    const fmt = (v: number) => (pctScale ? pct(v) : v.toFixed(1));
    const colour = (d: string) => AREA_COLS[dims.indexOf(d) % AREA_COLS.length];
    const max = Math.max(0, ...rows.map((r) => r.value), overall ?? 0);
    const o = hbars(rows.map((r) => ({
      label: `${r.category} `, value: r.value, colour: colour(r.dimension),
      tip: `${esc(r.category)} (${esc(r.dimension)})<br>${esc(label)}: <b>${pctScale ? pct(r.value, 1) : r.value.toFixed(1)}</b><br>${num(r.households)} households`,
    })), fmt, dark);
    o.grid = { left: 4, right: 38, top: 4, bottom: 4, containLabel: true };
    o.xAxis = { type: "value", max: max * 1.12 || 1, axisLabel: { formatter: (v: number) => fmt(v) } };
    o.yAxis.axisLabel = { width: 140, overflow: "truncate", interval: 0 };
    if (overall !== null && isFinite(overall)) {
      o.series[0].markLine = { silent: true, symbol: "none", label: { show: false }, lineStyle: { type: "dashed", color: WFP.slate }, data: [{ xAxis: overall }] };
    }
    return o;
  }, [rows, pctScale, overall, label, dims, dark]);
  return (
    <>
      <EChart option={option} height={Math.max(160, 19 * rows.length + 30)} />
      <div className="d-flex flex-wrap gap-3 small text-muted mt-1">
        {dims.map((d, i) => (
          <span key={d} className="d-inline-flex align-items-center gap-1">
            <span style={{ width: 9, height: 9, borderRadius: 2, background: AREA_COLS[i % AREA_COLS.length], display: "inline-block" }} />{d}
          </span>
        ))}
        {overall !== null && isFinite(overall) && (
          <span className="d-inline-flex align-items-center gap-1">
            <span style={{ width: 12, borderTop: `1.5px dashed ${WFP.slate}`, display: "inline-block" }} />overall
          </span>
        )}
      </div>
    </>
  );
}
