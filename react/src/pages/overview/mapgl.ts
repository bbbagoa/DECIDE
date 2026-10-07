// The Overview map engine: MapLibre GL for the Esri basemaps, deck.gl for the
// households (one ScatterplotLayer on binary attributes, so 1.5 million points
// stay fluid). Loaded on demand by MapView.tsx (import()): a chunk of its own.
import * as maplibregl from "maplibre-gl";
import type { StyleSpecification } from "maplibre-gl";
import mapCss from "maplibre-gl/dist/maplibre-gl.css?inline";
import workerCode from "maplibre-gl/dist/maplibre-gl-worker.mjs?raw";
import { MapboxOverlay } from "@deck.gl/mapbox";
import { ScatterplotLayer } from "@deck.gl/layers";

// ---- one-time set-up: the stylesheet, the worker (from this chunk, as a blob)
let ready = false;
function setup() {
  if (ready) return;
  ready = true;
  const st = document.createElement("style");
  st.textContent = mapCss;
  document.head.appendChild(st);
  maplibregl.setWorkerUrl(URL.createObjectURL(new Blob([workerCode], { type: "text/javascript" })));
  maplibregl.addProtocol("twsat", (p, ac) => satTile(p.url.replace(/^twsat:\/\//, "https://"), ac.signal).then((data) => ({ data })));
}

// ---- basemaps (BASE_GROUPS in R/utils_helpers.R): keyless Esri tiles
const ESRI = "https://server.arcgisonline.com/ArcGIS/rest/services/";
const canvas = (l: string) => `${ESRI}Canvas/World_${l}/MapServer/tile/{z}/{y}/{x}`;
const ESRI_ATTR = "Tiles &copy; Esri &mdash; Esri, HERE, Garmin, &copy; OpenStreetMap contributors";
const IMG_ATTR = "Tiles &copy; Esri &mdash; Source: Esri, Maxar, Earthstar Geographics, and the GIS User Community";
// satellite goes through twsat:// (below): blankTile=false makes a missing tile a 404
const IMAGERY = "World_Imagery/MapServer/tile/{z}/{y}/{x}?blankTile=false";
type Layer = { url: string; max: number; attr?: string };
export const BASES: Record<string, Layer[]> = {
  Light: [{ url: canvas("Light_Gray_Base"), max: 16, attr: ESRI_ATTR }, { url: canvas("Light_Gray_Reference"), max: 16 }],
  Dark: [{ url: canvas("Dark_Gray_Base"), max: 16, attr: ESRI_ATTR }, { url: canvas("Dark_Gray_Reference"), max: 16 }],
  Terrain: [{ url: `${ESRI}World_Topo_Map/MapServer/tile/{z}/{y}/{x}`, max: 19, attr: ESRI_ATTR }],
  Satellite: [{ url: `twsat://server.arcgisonline.com/ArcGIS/rest/services/${IMAGERY}`, max: 19, attr: IMG_ATTR }],
  "Satellite (Clarity)": [{ url: `twsat://clarity.maptiles.arcgis.com/arcgis/rest/services/${IMAGERY}`, max: 19, attr: IMG_ATTR }],
};

function style(base: string, dark: boolean): StyleSpecification {
  const ls = BASES[base] ?? BASES.Terrain;
  const sources: StyleSpecification["sources"] = {};
  ls.forEach((l, i) => { sources[`b${i}`] = { type: "raster", tiles: [l.url], tileSize: 256, maxzoom: l.max, attribution: l.attr }; });
  return {
    version: 8, sources,
    layers: [
      { id: "bg", type: "background", paint: { "background-color": dark ? "#1b2333" : "#eef1f4" } },
      ...ls.map((_, i) => ({ id: `b${i}`, type: "raster" as const, source: `b${i}` })),
    ],
  };
}

// Where Esri has no satellite image at this zoom (a 404), the deepest image
// above it is cut and enlarged instead, so a village zoomed past its imagery
// shows a real picture, not a blank tile (ESRI_FALLBACK_JS on the leaflet maps).
async function satTile(url: string, signal: AbortSignal): Promise<ArrayBuffer> {
  const m = url.match(/\/tile\/(\d+)\/(\d+)\/(\d+)/);
  if (!m) throw new Error("not a tile: " + url);
  const [z, y, x] = [+m[1], +m[2], +m[3]];
  for (let up = 0; up <= 6 && z - up >= 0; up++) {
    const r = await fetch(url.replace(m[0], `/tile/${z - up}/${y >> up}/${x >> up}`), { signal });
    if (r.status === 404) continue;
    if (!r.ok) throw new Error(`tile ${r.status}`);
    const blob = await r.blob();
    if (up === 0) return blob.arrayBuffer();
    const n = 1 << up, s = 256 / n;
    const bmp = await createImageBitmap(blob, (x % n) * s, (y % n) * s, s, s, { resizeWidth: 256, resizeHeight: 256, resizeQuality: "high" });
    const c = new OffscreenCanvas(256, 256);
    c.getContext("2d")!.drawImage(bmp, 0, 0);
    return (await c.convertToBlob({ type: "image/jpeg", quality: 0.9 })).arrayBuffer();
  }
  throw new Error("no imagery here");
}

// ---- the map
export type Bounds = { north: number; south: number; east: number; west: number };
export type MapEvents = {
  onBounds: (b: Bounds) => void;
  onPick: (i: number) => void;          // index in the points (from 0)
  onDrawn: (n: number) => void;         // points on screen after an update
};

const BOX_SVG = '<svg viewBox="0 0 16 16" width="15" height="15"><rect x="2" y="2" width="12" height="12" rx="1" fill="none" stroke="currentColor" stroke-width="1.5" stroke-dasharray="2.5 2"/><path d="M8 5v6M5 8h6" stroke="currentColor" stroke-width="1.5"/></svg>';
const FIT_SVG = '<svg viewBox="0 0 16 16" width="15" height="15"><path d="M2 6V2h4M10 2h4v4M14 10v4h-4M6 14H2v-4" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>';

export class TwMap {
  map: maplibregl.Map;
  private overlay: MapboxOverlay;
  private pos: Float32Array | null = null;
  private rgba: Uint8Array | null = null;
  private n = 0;
  private home: [number, number, number, number] | null = null;
  private popup: maplibregl.Popup | null = null;
  private base = "Terrain";
  private dark = false;
  private ro: ResizeObserver;
  private pending = -1;                 // points to report as drawn after the next frame

  constructor(el: HTMLElement, card: HTMLElement | null, private ev: MapEvents, base: string, dark: boolean) {
    setup();
    this.base = base; this.dark = dark;
    this.map = new maplibregl.Map({
      container: el, style: style(base, dark), center: [20, 5], zoom: 2, maxZoom: 21,
      attributionControl: { compact: true }, dragRotate: false, pitchWithRotate: false, touchPitch: false,
    });
    this.map.touchZoomRotate.disableRotation();
    this.map.addControl(new maplibregl.NavigationControl({ showCompass: false }), "top-left");
    this.map.addControl(this.tools(), "top-left");
    if (card) this.map.addControl(new maplibregl.FullscreenControl({ container: card }), "top-left");
    this.map.addControl(new maplibregl.ScaleControl({ unit: "metric" }), "bottom-left");
    this.overlay = new MapboxOverlay({
      interleaved: false, layers: [], pickingRadius: 4,
      getCursor: ({ isHovering, isDragging }) => (isDragging ? "grabbing" : isHovering ? "pointer" : "grab"),
      onAfterRender: () => { if (this.pending >= 0) { const n = this.pending; this.pending = -1; this.ev.onDrawn(n); } },
    });
    this.map.addControl(this.overlay);
    // the view, as leaflet sent it (input$map_plot_bounds)
    this.map.on("moveend", () => {
      const b = this.map.getBounds();
      this.ev.onBounds({ north: b.getNorth(), south: b.getSouth(), east: b.getEast(), west: b.getWest() });
    });
    // a hidden page has no size: draw again when the box changes
    this.ro = new ResizeObserver(() => { if (el.offsetWidth > 0) this.map.resize(); });
    this.ro.observe(el);
    (el as HTMLElement & { twMap?: TwMap }).twMap = this;   // for the browser checks (react/dev/test_overview.R)
  }

  /** Where point i (from 0) is on the page, in CSS pixels (browser checks) */
  screen(i: number): { x: number; y: number } | null {
    if (!this.pos || i < 0 || i >= this.n) return null;
    const p = this.map.project([this.pos[2 * i], this.pos[2 * i + 1]]), r = this.map.getCanvas().getBoundingClientRect();
    return { x: r.left + p.x, y: r.top + p.y };
  }

  /** Box zoom and "zoom to the households" (MapLibre has Shift + drag too) */
  private tools(): maplibregl.IControl {
    const map = () => this.map;
    let box: HTMLButtonElement, start: maplibregl.Point | null = null, rect: HTMLDivElement | null = null, on = false;
    const toggle = (v: boolean) => {
      on = v; box.classList.toggle("active", v);
      map().getCanvas().style.cursor = v ? "crosshair" : "";
      if (v) map().dragPan.disable(); else map().dragPan.enable();
    };
    const down = (e: maplibregl.MapMouseEvent) => {
      if (!on) return;
      start = e.point;
      rect = document.createElement("div");
      rect.className = "tw-map-box";
      map().getCanvasContainer().appendChild(rect);
    };
    const move = (e: maplibregl.MapMouseEvent) => {
      if (!on || !start || !rect) return;
      const p = e.point;
      Object.assign(rect.style, { left: Math.min(p.x, start.x) + "px", top: Math.min(p.y, start.y) + "px",
                                  width: Math.abs(p.x - start.x) + "px", height: Math.abs(p.y - start.y) + "px" });
    };
    const up = (e: maplibregl.MapMouseEvent) => {
      if (!on || !start) return;
      rect?.remove(); rect = null;
      const a = map().unproject(start), b = map().unproject(e.point);
      const moved = Math.abs(e.point.x - start.x) > 4 && Math.abs(e.point.y - start.y) > 4;
      start = null; toggle(false);
      if (moved) map().fitBounds([[Math.min(a.lng, b.lng), Math.min(a.lat, b.lat)], [Math.max(a.lng, b.lng), Math.max(a.lat, b.lat)]]);
    };
    return {
      onAdd: () => {
        const d = document.createElement("div");
        d.className = "maplibregl-ctrl maplibregl-ctrl-group tw-map-tools";
        box = document.createElement("button");
        box.type = "button"; box.className = "tw-boxzoom-btn"; box.innerHTML = BOX_SVG;
        box.title = "Zoom to an area: click, then draw a rectangle on the map (or Shift + drag)";
        box.setAttribute("aria-label", "Zoom to an area");
        box.onclick = () => toggle(!on);
        const fit = document.createElement("button");
        fit.type = "button"; fit.className = "tw-fit-btn"; fit.innerHTML = FIT_SVG;
        fit.title = "Zoom to the households"; fit.setAttribute("aria-label", "Zoom to the households");
        fit.onclick = () => this.fit();
        d.append(box, fit);
        map().on("mousedown", down); map().on("mousemove", move); map().on("mouseup", up);
        return d;
      },
      onRemove: () => { map().off("mousedown", down); map().off("mousemove", move); map().off("mouseup", up); },
    };
  }

  setBase(base: string, dark: boolean) {
    if (base === this.base && dark === this.dark) return;
    this.base = base; this.dark = dark;
    this.map.setStyle(style(base, dark));
  }

  /** New households: positions (lon, lat pairs) and the view to open on */
  setPoints(pos: Float32Array, n: number, home: [number, number, number, number] | null) {
    this.pos = pos; this.n = n; this.home = home;
    this.popup?.remove();
    if (this.rgba && this.rgba.length !== n * 4) this.rgba = null;
    this.draw();
    this.fit(false);
  }

  /** New colours: one byte a point, an index in the palette */
  setColours(code: Uint8Array, palette: string[]) {
    if (code.length !== this.n) return;
    const pal = palette.map(hexRgb);
    const out = new Uint8Array(this.n * 4);
    for (let i = 0; i < this.n; i++) {
      const c = pal[code[i]] ?? pal[pal.length - 1];
      const j = i * 4;
      out[j] = c[0]; out[j + 1] = c[1]; out[j + 2] = c[2]; out[j + 3] = 230;
    }
    this.rgba = out;
    this.popup?.remove();
    this.draw();
  }

  private draw() {
    const n = this.pos ? this.n : 0;
    const grey = new Uint8Array([190, 190, 190, 230]);
    const layer = new ScatterplotLayer({
      id: "households",
      data: { length: n, attributes: {
        getPosition: { value: this.pos ?? new Float32Array(0), size: 2 },
        ...(this.rgba ? { getFillColor: { value: this.rgba, size: 4, normalized: true } } : {}),
      } },
      ...(this.rgba ? {} : { getFillColor: [grey[0], grey[1], grey[2], grey[3]] }),
      radiusUnits: "pixels", getRadius: 3.5,
      // the outline triples the pixels drawn: kept for readable small maps only
      stroked: n <= 200000, lineWidthUnits: "pixels", getLineWidth: 0.6, getLineColor: [255, 255, 255, 150],
      pickable: true,
      onClick: (info) => { if (info.index >= 0) this.ev.onPick(info.index); return true; },
    });
    this.pending = n;
    this.overlay.setProps({ layers: [layer] });
  }

  fit(animate = true) {
    if (!this.home) return;
    const [w, s, e, n] = this.home;
    this.map.fitBounds([[w, s], [e, n]], { padding: 20, animate, maxZoom: 16 });
  }

  showPopup(lng: number, lat: number, html: string) {
    this.popup?.remove();
    this.popup = new maplibregl.Popup({ closeButton: true, maxWidth: "280px", className: "tw-map-popup" })
      .setLngLat([lng, lat]).setHTML(html).addTo(this.map);
  }

  destroy() { this.ro.disconnect(); this.overlay.finalize(); this.map.remove(); }
}

function hexRgb(h: string): [number, number, number] {
  const v = parseInt(h.replace("#", "").slice(0, 6), 16);
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255];
}

/** base64 -> bytes, natively (a data: URL), without a loop over a 16 MB string */
export async function b64bytes(s: string): Promise<ArrayBuffer> {
  if (!s) return new ArrayBuffer(0);
  return (await fetch("data:application/octet-stream;base64," + s)).arrayBuffer();
}
