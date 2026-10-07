// The Overview map: points from output map_points (binary, base64), colours
// from map_colours, drawn by mapgl.ts (MapLibre + deck.gl, loaded on demand).
// Sends input map_plot_bounds (as leaflet did) and map_click (a point's place).
import { useEffect, useRef, useState } from "react";
import { useSetShinyInput, useShinyMessageHandler, useShinyOutputError, useShinyOutputValue } from "@/shiny";
import { useOutputVisibility } from "@/lib/visibility";
import type { Bounds, TwMap } from "./mapgl";

type Points = { n: number; pos: string; bounds: [number, number, number, number] | null };
type Colours = { n: number; col: string; refused: boolean; title: string; palette: string[]; code: string;
                 legend: { numeric: boolean; colors: string[]; labels: string[] } };

const BASE_NAMES = ["Light", "Dark", "Terrain", "Satellite", "Satellite (Clarity)"];
const isDark = () => document.documentElement.getAttribute("data-bs-theme") === "dark";

export function MapView({ ns, t, card, fitSignal, onColourCol }: {
  ns: (id: string) => string; t: (s: string) => string; card: React.RefObject<HTMLDivElement | null>;
  fitSignal: number; onColourCol: (col: string) => void;
}) {
  const holder = useRef<HTMLDivElement>(null);
  const el = useRef<HTMLDivElement>(null);
  useOutputVisibility(ns("map_points"), holder);
  useOutputVisibility(ns("map_colours"), holder);
  const pts = useShinyOutputValue<Points>(ns("map_points"));
  const cols = useShinyOutputValue<Colours>(ns("map_colours"));
  const err = useShinyOutputError(ns("map_points"));
  const setBounds = useSetShinyInput<Bounds | null>(ns("map_plot_bounds"), null, { debounceMs: 150 });
  const setClick = useSetShinyInput<{ i: number; nonce: number } | null>(ns("map_click"), null, { debounceMs: 0, priority: "event" });

  const [map, setMap] = useState<TwMap | null>(null);
  const [dark, setDark] = useState(isDark);
  const [base, setBase] = useState("Terrain");
  const lightBase = useRef("Terrain");          // the base to go back to when leaving dark mode
  const [drawn, setDrawn] = useState(-1);
  const [posKey, setPosKey] = useState(0);      // positions decoded and set
  const mapRef = useRef<TwMap | null>(null);
  mapRef.current = map;

  // the engine, once (a chunk of its own)
  useEffect(() => {
    let gone = false, m: TwMap | null = null;
    import("./mapgl").then(({ TwMap }) => {
      if (gone || !el.current) return;
      m = new TwMap(el.current, card.current, {
        onBounds: (b) => setBounds(b),
        onPick: (i) => setClick({ i: i + 1, nonce: Date.now() }),
        onDrawn: (n) => setDrawn(n),
      }, isDark() ? "Dark" : "Terrain", isDark());
      setMap(m);
    });
    return () => { gone = true; m?.destroy(); };
  }, []); // eslint-disable-line

  // light / dark: dark mode draws on the dark basemap; leaving it goes back
  useEffect(() => {
    const mo = new MutationObserver(() => setDark(isDark()));
    mo.observe(document.documentElement, { attributes: true, attributeFilter: ["data-bs-theme"] });
    return () => mo.disconnect();
  }, []);
  useEffect(() => { setBase(dark ? "Dark" : lightBase.current); }, [dark]);
  useEffect(() => { map?.setBase(base, dark); }, [map, base, dark]);

  // points: new data or filters -> new positions, view fitted to them
  useEffect(() => {
    if (!map || !pts) return;
    let gone = false;
    import("./mapgl").then(({ b64bytes }) => b64bytes(pts.pos)).then((buf) => {
      if (gone) return;
      map.setPoints(new Float32Array(buf), pts.n, pts.bounds);
      setPosKey((k) => k + 1);
    });
    return () => { gone = true; };
  }, [map, pts]);
  // colours: in place, the view stays
  useEffect(() => {
    if (!map || !cols || !pts || cols.n !== pts.n) return;
    let gone = false;
    import("./mapgl").then(({ b64bytes }) => b64bytes(cols.code)).then((buf) => {
      if (!gone) map.setColours(new Uint8Array(buf), cols.palette);
    });
    return () => { gone = true; };
  }, [map, cols, posKey]); // eslint-disable-line
  // a refused variable: the picker goes back to the one drawn
  useEffect(() => { if (cols?.refused) onColourCol(cols.col); }, [cols]); // eslint-disable-line
  useEffect(() => { if (fitSignal) map?.fit(); }, [fitSignal]); // eslint-disable-line

  useShinyMessageHandler<{ lng: number; lat: number; html: string }>(ns("map_popup"), (m) => mapRef.current?.showPopup(m.lng, m.lat, m.html));

  const lg = cols?.legend;
  return (
    <div ref={holder} className="tw-map-holder" data-points={drawn}>
      <div ref={el} className="tw-map-gl" />
      <select className="form-select form-select-sm tw-map-base" value={base} aria-label={t("Basemap")} title={t("Basemap")}
              onChange={(e) => { setBase(e.target.value); if (e.target.value !== "Dark") lightBase.current = e.target.value; }}>
        {BASE_NAMES.map((b) => <option key={b} value={b}>{t(b)}</option>)}
      </select>
      {err?.message && <div className="tw-map-note">{err.message}</div>}
      {pts && pts.n === 0 && !err?.message && <div className="tw-map-note">{t("No household with usable GPS coordinates in these data.")}</div>}
      {lg && cols.title && lg.colors.length > 0 && (
        <div className="tw-map-legend">
          <div className="tw-map-legend-title">{cols.title}</div>
          {lg.numeric
            ? <>
                <div className="tw-map-ramp" style={{ background: `linear-gradient(to right, ${lg.colors.join(", ")})` }} />
                <div className="tw-map-ramp-labels">{lg.labels.map((l, i) => <span key={i}>{l}</span>)}</div>
              </>
            : lg.colors.map((c, i) => (
                <div key={i} className="tw-map-legend-row"><i style={{ background: c }} /><span>{lg.labels[i]}</span></div>
              ))}
        </div>
      )}
    </div>
  );
}
