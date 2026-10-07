// Overview (overview_panel), the module overview_1. See react/PORT.md.
// The server sends facts (ov_meta, ov_view, ov_ready, ov_collection,
// ov_profile, ov_vuln); the map and the report download are the module's own
// outputs, hosted; the two builders are drawn here (Builders.tsx).
import { useEffect, useMemo, useState, type ReactNode } from "react";
import Select from "react-select";
import { Activity, Download, Filter, Globe2, X, ZoomIn } from "lucide-react";
import {
  ShinyOutput, useShinyButton, useShinyInput, useShinyOutputStatus, useShinyOutputValue,
} from "@/shiny";
import { EmptyState, Tiles, type Tile } from "@/components/Figures";
import { CrossChart, DailyChart, GroupsChart, ShareChart } from "./charts";
import { ChartBuilder, TableBuilder } from "./Builders";
import "./overview.css";

const NS = "overview_1-";
const ns = (id: string) => NS + id;

type Meta = {
  levels: string[]; level_cols: Record<string, string>; areas: string[][];
  dates: [string, string] | null; map_vars: { label: string; value: string }[]; map_default: string;
};
type Collection = { tiles: Tile[]; daily: { day: string; area: string; n: number }[]; by_area: boolean; areas: string[] };
type Profile = { empty: boolean; tiles: Tile[]; charts: { key: string; title: string; kind: string; data: { category: string; n: number }[] }[] };
type Cross = { indicator: string; label: string; pct: boolean; overall: number | null; rows: { dimension: string; category: string; value: number; households: number }[] };
type Vuln = {
  empty: boolean; indicator: string; available: string[];
  groups: { group: string; households: number; people: number; colour: string }[] | null;
  score: { category: string; n: number }[] | null; cross: Record<string, Cross>;
};

const LEVEL_LABEL: Record<string, string> = { admin1: "Admin 1", admin2: "Admin 2", admin3: "Admin 3" };
const INDICATORS: Record<string, string> = { eligible: "Share eligible", vulnerable: "Share in the most vulnerable groups", score: "Mean score" };

export function OverviewPage({ active, t }: { active: boolean; t: (s: string) => string }) {
  const meta = useShinyOutputValue<Meta>(ns("ov_meta"));
  if (!meta) {
    return <div className="p-4"><EmptyState title={t("Load the registration data and map its variables first.")} /></div>;
  }
  return <Overview meta={meta} active={active} t={t} />;
}

function Overview({ meta, active, t }: { meta: Meta; active: boolean; t: (s: string) => string }) {
  // ---- filters: sent as they change, applied by the server on Apply
  const [a1, setA1] = useShinyInput<string[]>(ns("filter_admin1"), []);
  const [a2, setA2] = useShinyInput<string[]>(ns("filter_admin2"), []);
  const [a3, setA3] = useShinyInput<string[]>(ns("filter_admin3"), []);
  const sel = [a1, a2, a3], setSel = [setA1, setA2, setA3];
  const [dates, setDates] = useShinyInput<string[]>(ns("filter_date"), meta.dates ?? []);
  const apply = useShinyButton(ns("btn_apply_filters"));
  const clear = useShinyButton(ns("btn_clear_filters"));
  useEffect(() => { if (meta.dates && dates.length !== 2) setDates([...meta.dates]); }, [meta.dates]); // eslint-disable-line

  // a level lists only the areas inside those picked above
  const options = useMemo(() => meta.levels.map((_, k) => {
    const n = meta.areas[0]?.length ?? 0, out = new Set<string>();
    for (let i = 0; i < n; i++) {
      let ok = true;
      for (let j = 0; j < k; j++) if (sel[j].length && !sel[j].includes(meta.areas[j][i])) { ok = false; break; }
      if (ok && meta.areas[k][i]) out.add(meta.areas[k][i]);
    }
    return [...out].sort();
  }), [meta, a1, a2, a3]); // eslint-disable-line
  // picks that the level above no longer allows are dropped
  useEffect(() => {
    meta.levels.forEach((_, k) => {
      const keep = sel[k].filter((v) => options[k].includes(v));
      if (keep.length !== sel[k].length) setSel[k](keep);
    });
  }, [options]); // eslint-disable-line

  const onClear = () => { setA1([]); setA2([]); setA3([]); if (meta.dates) setDates([...meta.dates]); clear(); };

  // ---- map colour, map view
  const [mapVar, setMapVar] = useShinyInput<string>(ns("map_var"), meta.map_default);
  useEffect(() => { if (!mapVar && meta.map_default) setMapVar(meta.map_default); }, [meta.map_default]); // eslint-disable-line
  const [follow, setFollow] = useShinyInput<boolean>(ns("view_follow"), false);
  const showAll = useShinyButton(ns("view_all"));
  const view = useShinyOutputValue<{ label: string; zoomed: boolean }>(ns("ov_view"));
  const ready = useShinyOutputValue<{ off: { feature: string; detail: string }[] }>(ns("ov_ready"));

  // ---- figures
  const coll = useShinyOutputValue<Collection>(ns("ov_collection"));
  const collStatus = useShinyOutputStatus(ns("ov_collection"));
  const [byArea, setByArea] = useState(true);   // display only
  const profile = useShinyOutputValue<Profile>(ns("ov_profile"));
  const vuln = useShinyOutputValue<Vuln>(ns("ov_vuln"));
  const [indicator, setIndicator] = useState<string>("");
  const cross = vuln && !vuln.empty ? vuln.cross[indicator] ?? vuln.cross[vuln.indicator] : undefined;

  const [open, setOpen] = useState("who");
  // charts in a section opened (or a page shown) measure their box again
  useEffect(() => { if (active) window.setTimeout(() => window.dispatchEvent(new Event("resize")), 30); }, [open, active]);

  const selectStyles = { menuPortal: (b: object) => ({ ...b, zIndex: 1090 }) };

  return (
    <div className="tw-rov">
      {/* sidebar */}
      <aside className="tw-rov-side">
        <section className="tw-rov-step">
          <div className="tw-rov-step-title">1. {t("Areas")}</div>
          {meta.levels.map((lv, k) => (
            <label key={lv} className="tw-rov-field">
              <span>{t(LEVEL_LABEL[lv] ?? lv)}</span>
              <Select isMulti classNamePrefix="tw-select" placeholder={t("Nothing selected")} menuPortalTarget={document.body} styles={selectStyles}
                      options={options[k].map((v) => ({ value: v, label: v }))}
                      value={sel[k].map((v) => ({ value: v, label: v }))}
                      onChange={(vals) => setSel[k](vals.map((v) => v.value))} />
            </label>
          ))}
        </section>
        {meta.dates && (
          <section className="tw-rov-step">
            <div className="tw-rov-step-title">2. {t("Interview dates")}</div>
            <div className="d-flex gap-2">
              <input type="date" className="form-control form-control-sm" aria-label="From" min={meta.dates[0]} max={meta.dates[1]}
                     value={dates[0] ?? ""} onChange={(e) => setDates([e.target.value, dates[1] ?? meta.dates![1]])} />
              <input type="date" className="form-control form-control-sm" aria-label="To" min={meta.dates[0]} max={meta.dates[1]}
                     value={dates[1] ?? ""} onChange={(e) => setDates([dates[0] ?? meta.dates![0], e.target.value])} />
            </div>
          </section>
        )}
        <div className="tw-rov-actions">
          <div className="d-flex gap-2">
            <button type="button" className="btn btn-primary btn-sm flex-fill" onClick={apply}><Filter size={14} /> {t("Apply")}</button>
            <button type="button" className="btn btn-outline-secondary btn-sm" onClick={onClear} title={t("Clear the filters")} aria-label={t("Clear the filters")}><X size={14} /></button>
          </div>
          <ShinyOutput id={ns("overview_report")} tagName="a" className="btn btn-outline-primary btn-sm w-100 mt-2 shiny-download-link"
                       {...{ download: "", target: "_blank" }}>
            <Download size={14} /> {t("Overview report (HTML)")}
          </ShinyOutput>
        </div>
      </aside>

      {/* map */}
      <div className="card tw-rov-map">
        <div className="wfp-map-toolbar">
          <div className="d-flex align-items-center gap-2">
            <span className="wfp-map-toolbar-label">{t("Colour by")}</span>
            <select className="form-select form-select-sm" value={mapVar} onChange={(e) => setMapVar(e.target.value)} aria-label="Colour by">
              {meta.map_vars.map((m) => <option key={m.value} value={m.value}>{t(m.label)}</option>)}
            </select>
          </div>
        </div>
        <ShinyOutput id={ns("map_plot")} className="leaflet html-widget html-widget-output tw-rov-map-body" />
      </div>

      {/* figures */}
      <div className="tw-rov-right">
        <div className={"card tw-rov-collection" + (collStatus === "recalculating" ? " recalculating" : "")}>
          <div className="tw-ov-head">
            <span className="tw-ov-title"><Activity size={14} /> {t("Data collection")}</span>
            {view && (
              <span className={"tw-ov-chip" + (view.zoomed ? " zoomed" : "")}>
                {view.zoomed ? <ZoomIn size={12} /> : <Globe2 size={12} />} {view.label}
                {view.zoomed && <a href="#" className="ms-1" onClick={(e) => { e.preventDefault(); setFollow(false); showAll(); }}>{t("show all")}</a>}
              </span>
            )}
            <label className="form-check form-switch tw-ov-follow ms-auto mb-0"
                   title={t("On: the figures describe the households in the map view and follow it as you pan or zoom. Off: every household.")}>
              <input className="form-check-input" type="checkbox" role="switch" checked={follow} onChange={(e) => setFollow(e.target.checked)} />
              <span className="form-check-label">{t("Follow the map")}</span>
            </label>
          </div>
          {ready && ready.off.length > 0 && (
            <div className="tw-ready-strip">
              <span>{t("Not available with these data:")}</span>
              {ready.off.map((o) => <span key={o.feature} className="tw-ready-chip off" title={o.detail}>{o.feature}</span>)}
            </div>
          )}
          {coll ? <Tiles tiles={coll.tiles} /> : null}
          <div className="tw-ov-daily">
            <div className="tw-ov-daily-bar">
              <span className="tw-ov-sub">{t("Households per day")}</span>
              {coll?.by_area && (
                <div className="btn-group btn-group-sm tw-seg-r" role="group" aria-label="Total or by area">
                  <button type="button" className={"btn" + (!byArea ? " active" : "")} onClick={() => setByArea(false)}>{t("Total")}</button>
                  <button type="button" className={"btn" + (byArea ? " active" : "")} onClick={() => setByArea(true)}>{t("By area")}</button>
                </div>
              )}
            </div>
            {coll && coll.daily.length > 0
              ? <DailyChart daily={coll.daily} byArea={byArea && coll.by_area} areas={coll.areas} />
              : coll ? <div className="small text-muted py-3">{t("Not in these data: map the data collection date to see the daily submissions.")}</div> : null}
          </div>
        </div>

        <div className="tw-rov-sections">
          <Section id="who" title={t("Who is in the data")} open={open} setOpen={setOpen}>
            {!profile ? null : profile.empty
              ? <EmptyState title={t("No household characteristic is mapped")}
                            sub={t("Map the head's sex and age, household size, children under 5, residence status... in Variable Definition & Setup.")} />
              : <>
                  <Tiles tiles={profile.tiles} />
                  <div className="tw-mini-grid">
                    {profile.charts.map((c) => (
                      <div key={c.key} className="tw-mini"><div className="tw-mini-title">{t(c.title)}</div><ShareChart data={c.data} kind={c.kind} /></div>
                    ))}
                  </div>
                </>}
          </Section>
          <Section id="vuln" title={t("Vulnerability")} open={open} setOpen={setOpen}>
            {!vuln ? null : vuln.empty
              ? <EmptyState title={t("No vulnerability variable is mapped")}
                            sub={t("Map a vulnerability score, vulnerability groups or eligibility in Variable Definition & Setup, or build a scorecard in Targeting Design.")} />
              : <>
                  <div className="tw-mini-grid">
                    {vuln.groups && <div className="tw-mini"><div className="tw-mini-title">{t("Households by vulnerability group")}</div><GroupsChart groups={vuln.groups} /></div>}
                    {vuln.score && <div className="tw-mini"><div className="tw-mini-title">{t("Distribution of the vulnerability score")}</div><ShareChart data={vuln.score} kind="bins" height={200} /></div>}
                  </div>
                  {cross && cross.rows.length > 0 && (
                    <div className="tw-mini tw-mini-wide">
                      <div className="tw-mini-title d-flex align-items-center justify-content-between gap-2">
                        <span>{t("Across household profiles")}</span>
                        <select className="form-select form-select-sm" style={{ width: 240 }} value={cross.indicator}
                                onChange={(e) => setIndicator(e.target.value)} aria-label="Indicator">
                          {vuln.available.map((k) => <option key={k} value={k}>{t(INDICATORS[k] ?? k)}</option>)}
                        </select>
                      </div>
                      <CrossChart rows={cross.rows} pctScale={cross.pct} overall={cross.overall} label={cross.label} />
                    </div>
                  )}
                </>}
          </Section>
          <Section id="explore" title={t("Table builder")} open={open} setOpen={setOpen}>
            <TableBuilder t={t} />
          </Section>
          <Section id="charts" title={t("Chart builder")} open={open} setOpen={setOpen}>
            <ChartBuilder t={t} />
          </Section>
        </div>
      </div>
    </div>
  );
}

/** One of the folding sections: one open at a time, all kept mounted. */
function Section({ id, title, open, setOpen, children }: {
  id: string; title: string; open: string; setOpen: (v: string) => void; children: ReactNode;
}) {
  const isOpen = open === id;
  return (
    <div className={"tw-rov-sec" + (isOpen ? " open" : "")}>
      <button type="button" className="tw-rov-sec-head" aria-expanded={isOpen} onClick={() => setOpen(isOpen ? "" : id)}>
        <span>{title}</span><span className="tw-rov-chev" aria-hidden>{isOpen ? "⌃" : "⌄"}</span>
      </button>
      <div className="tw-rov-sec-body" style={{ display: isOpen ? "block" : "none" }}>{children}</div>
    </div>
  );
}
