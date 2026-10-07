// Charts for the React pages: the server's render_echart() output (an
// ECharts option, R/utils_react_render.R) drawn with the WFP theme, light or
// dark. Formatters travel as names ("fn:pct", "fn:tip", ...) and become
// functions here, since JSON carries no functions.
import { useEffect, useRef, useState } from "react";
// ECharts (about a megabyte) is loaded the first time a chart is drawn, not
// with the page: the app opens sooner (vite puts it in its own chunk).
import type * as Echarts from "echarts";
import { useOutputVisibility } from "./visibility";
import { useShinyOutputError, useShinyOutputStatus, useShinyOutputValue } from "@/shiny";

export const WFP_COLOURS = ["#0A6EB4", "#26bde2", "#f7b825", "#3f7e44", "#c5192d", "#8a96a3", "#5b6b7c", "#7fb3d5", "#fbd679", "#8bc28f"];

function theme(dark: boolean) {
  const text = dark ? "#c9d1dc" : "#5b6b7c", strong = dark ? "#e8edf3" : "#1f2a37", line = "rgba(128,128,128,0.2)";
  const axis = { axisLine: { lineStyle: { color: line } }, axisTick: { show: false }, axisLabel: { color: text, fontSize: 10 },
    splitLine: { lineStyle: { color: line } }, nameTextStyle: { color: text, fontSize: 11 } };
  return {
    color: WFP_COLOURS, backgroundColor: "transparent",
    textStyle: { fontFamily: "Commissioner, system-ui, sans-serif", color: text },
    title: { textStyle: { color: strong, fontSize: 13, fontWeight: 600 } },
    legend: { textStyle: { color: text, fontSize: 11 }, itemWidth: 10, itemHeight: 10, icon: "roundRect" },
    tooltip: { backgroundColor: "#1f2a37", borderWidth: 0, textStyle: { color: "#fff", fontSize: 12 }, extraCssText: "border-radius:6px;box-shadow:0 4px 14px rgba(0,0,0,.25);" },
    categoryAxis: { ...axis, splitLine: { show: false } }, valueAxis: axis, timeAxis: axis, logAxis: axis,
    // value labels in the text colour, no halo (dark mode drew one)
    bar: { itemStyle: { borderRadius: 2 }, label: { color: text, textBorderWidth: 0, textBorderColor: "transparent" } },
    line: { symbolSize: 5, lineStyle: { width: 2 }, label: { color: text, textBorderWidth: 0, textBorderColor: "transparent" } },
    scatter: { label: { color: text, textBorderWidth: 0, textBorderColor: "transparent" } },
    boxplot: { itemStyle: { color: dark ? "rgba(10,110,180,.25)" : "rgba(10,110,180,.12)", borderColor: "#0A6EB4" } },
    pie: { itemStyle: { borderColor: dark ? "#10233b" : "#fff", borderWidth: 1 }, label: { color: text, textBorderWidth: 0 } },
  };
}
let loading: Promise<typeof Echarts> | null = null;
export function loadEcharts(): Promise<typeof Echarts> {
  loading ??= import("./echarts-core").then(({ default: m }) => {
    m.registerTheme("tw-light", theme(false));
    m.registerTheme("tw-dark", theme(true));
    return m;
  });
  return loading;
}

type P = { value?: unknown; data?: { tip?: string; value?: unknown } | unknown; marker?: string; seriesName?: string; name?: string };
const numOf = (x: unknown): number => {
  if (typeof x === "number") return x;
  if (x && typeof x === "object") {
    const v = (x as P).value ?? (x as P).data;
    if (Array.isArray(v)) return Number(v[v.length - 1]);
    return numOf(v);
  }
  return Number(x);
};
const pctF = (d: number) => (x: unknown) => { const n = numOf(x); return isFinite(n) ? `${(100 * n).toFixed(d)}%` : ""; };
const tipOf = (p: P) => {
  const d = p.data as { tip?: string } | undefined;
  if (d && typeof d === "object" && d.tip) return d.tip;
  const v = Array.isArray(p.value) ? p.value[p.value.length - 1] : p.value;
  return `${p.marker ?? ""}${p.seriesName ? p.seriesName + ": " : ""}${p.name ? p.name + " " : ""}<b>${typeof v === "number" ? v.toLocaleString("en-US", { maximumFractionDigits: 2 }) : v ?? ""}</b>`;
};

/** The named formatters a server option may use. */
export const FORMATTERS: Record<string, (x: unknown) => string> = {
  pct: pctF(0), pct1: pctF(1),
  num: (x) => { const n = numOf(x); return isFinite(n) ? Math.round(n).toLocaleString("en-US") : ""; },
  dec1: (x) => { const n = numOf(x); return isFinite(n) ? n.toFixed(1) : ""; },
  dec2: (x) => { const n = numOf(x); return isFinite(n) ? n.toFixed(2) : ""; },
  hmap: (x) => { const v = (x as P).value; const n = Array.isArray(v) ? Number(v[2]) : numOf(x); return isFinite(n) ? (Math.abs(n) < 10 ? n.toFixed(2) : Math.round(n).toLocaleString("en-US")) : ""; },
  tip: (x) => (Array.isArray(x) ? (x as P[]).map(tipOf).join("<br>") : tipOf(x as P)),
};

function resolve(o: unknown): unknown {
  if (typeof o === "string" && o.startsWith("fn:")) return FORMATTERS[o.slice(3)] ?? o;
  if (Array.isArray(o)) return o.map(resolve);
  if (o && typeof o === "object") return Object.fromEntries(Object.entries(o).map(([k, v]) => [k, resolve(v)]));
  return o;
}

/**
 * Bar thickness follows the number of categories: thick bars for a few,
 * thinner ones as they multiply (the caps set chart by chart made a handful
 * of categories look thin). A series that sets barWidth keeps it
 * (histograms, lollipops), and so does one with no gap (barCategoryGap 0).
 */
export function sizeBars(o: Record<string, unknown>): Record<string, unknown> {
  const series = Array.isArray(o.series) ? (o.series as Record<string, unknown>[]) : o.series ? [o.series as Record<string, unknown>] : [];
  if (!series.some((x) => x?.type === "bar")) return o;
  const axes = (k: string) => (Array.isArray(o[k]) ? (o[k] as Record<string, unknown>[]) : o[k] ? [o[k] as Record<string, unknown>] : []);
  const catAxis = [...axes("xAxis"), ...axes("yAxis")].find((a) => a?.type === "category");
  const sz = (x: Record<string, unknown>) => {
    const d = (catAxis?.data as unknown[] | undefined) ?? (x.data as unknown[] | undefined) ?? [];
    return d.length;
  };
  const max = (n: number) => (n <= 2 ? 90 : n <= 4 ? 72 : n <= 7 ? 54 : n <= 12 ? 38 : n <= 20 ? 26 : n <= 35 ? 16 : 10);
  const gap = (n: number) => (n <= 4 ? "30%" : n <= 20 ? "22%" : "12%");
  const out = series.map((x) => {
    if (x?.type !== "bar" || x.barWidth !== undefined || x.barCategoryGap === 0 || x.barCategoryGap === "0%") return x;
    const n = Math.max(1, sz(x));
    const y: Record<string, unknown> = { ...x, barMaxWidth: max(n) };
    if (x.barCategoryGap === undefined) y.barCategoryGap = gap(n);
    return y;
  });
  return { ...o, series: out };
}

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

/** Draw an ECharts option (from the server or built here). */
export function EChart({ option, height = 320, className }: { option: Record<string, unknown> | null | undefined; height?: number | string; className?: string }) {
  const el = useRef<HTMLDivElement>(null);
  const chart = useRef<Echarts.ECharts | null>(null);
  const [ready, setReady] = useState(0);
  const dark = useDark();
  useEffect(() => {
    let gone = false, ro: ResizeObserver | null = null;
    loadEcharts().then((ec) => {
      if (gone || !el.current) return;
      const c = ec.init(el.current, dark ? "tw-dark" : "tw-light", { renderer: "canvas" });
      chart.current = c;
      ro = new ResizeObserver(() => { if (el.current && el.current.offsetWidth > 0) c.resize(); });
      ro.observe(el.current);
      setReady((n) => n + 1);
    });
    return () => { gone = true; ro?.disconnect(); chart.current?.dispose(); chart.current = null; };
  }, [dark]);
  useEffect(() => {
    if (!chart.current || !option) return;
    chart.current.setOption(resolve(sizeBars({ animationDuration: 300, ...option })) as Echarts.EChartsOption, { notMerge: true });
  }, [option, ready]);
  return <div ref={el} className={`tw-echart${className ? " " + className : ""}`} style={{ height, width: "100%" }} />;
}

/** A chart rendered by the server: output$<id> <- render_echart(...). Validation messages show in its place. */
export function Chart({ id, height, className }: { id: string; height?: number | string; className?: string }) {
  const v = useShinyOutputValue<{ option: Record<string, unknown>; height?: number | null }>(id);
  useOutputVisibility(id);   // computed only while on screen
  const err = useShinyOutputError(id);
  const status = useShinyOutputStatus(id);
  // the server's height wins (it knows how many categories there are); the page's is the default
  const h = v?.height ?? height ?? 320;
  if (err?.message) return <div className="tw-output-note" id={id}>{err.message}</div>;
  return (
    <div id={id} className={`tw-chart-holder${status === "recalculating" ? " recalculating" : ""}`}>
      {v?.option ? <EChart option={v.option} height={h} className={className} /> : <div style={{ height: typeof h === "number" ? h : 120 }} />}
    </div>
  );
}
