// Figures shared by the pages: quiet tiles, share rings, chart theme.
export type Tile = { label: string; value: string; sub?: string; icon?: string; share?: number | null };

/** WFP chart colours (the token hexes of wfp-ui.css). */
export const WFP = { blue: "#0A6EB4", cyan: "#26bde2", amber: "#f7b825", green: "#3f7e44", red: "#c5192d", grey: "#8a96a3", slate: "#5b6b7c" };
export const AREA_COLS = [WFP.blue, WFP.cyan, WFP.amber, WFP.green, WFP.red, WFP.grey];

const isShare = (t: Tile) => typeof t.share === "number" && isFinite(t.share);

/** The figures: plain tiles on top, then up to `maxRings` shares as rings (more become tiles). */
export function Tiles({ tiles, maxRings = 5 }: { tiles: Tile[]; maxRings?: number }) {
  if (!tiles?.length) return null;
  const shares = tiles.filter(isShare).slice(0, maxRings);
  const cards = tiles.filter((t) => !shares.includes(t));
  return (
    <>
      {cards.length > 0 && (
        <div className="tw-figs tw-figs-cards">
          {cards.map((t) => (
            <div key={t.label} className="tw-tile" data-key={t.label} title={t.sub ?? ""}>
              <div className="tw-tile-label">{t.label}</div>
              <div className="tw-tile-value">{t.value}</div>
              {t.sub ? <div className="tw-tile-sub">{t.sub}</div> : null}
            </div>
          ))}
        </div>
      )}
      {shares.length > 0 && <div className="tw-figs">{shares.map((t) => <Ring key={t.label} tile={t} />)}</div>}
    </>
  );
}

/** A share as a ring: the arc fills with the share, the percentage in the middle. */
export function Ring({ tile }: { tile: Tile }) {
  const r = 26, c = 2 * Math.PI * r, on = Math.max(0, Math.min(1, tile.share ?? 0)) * c;
  return (
    <div className="tw-donut" title={tile.sub ?? ""}>
      <svg viewBox="0 0 64 64" width={64} height={64} role="img" aria-label={`${tile.label}: ${tile.value}`}>
        <circle cx="32" cy="32" r={r} fill="none" stroke="rgba(128,128,128,.18)" strokeWidth="6" />
        <circle cx="32" cy="32" r={r} fill="none" stroke={WFP.blue} strokeWidth="6" strokeLinecap="round"
                strokeDasharray={`${on} ${c - on}`} transform="rotate(-90 32 32)" />
        <text x="32" y="36.5" textAnchor="middle" style={{ font: "700 13px Commissioner, system-ui, sans-serif", fill: "currentColor" }}>
          {tile.value}
        </text>
      </svg>
      <div className="tw-donut-label">{tile.label}</div>
    </div>
  );
}

export function EmptyState({ title, sub }: { title: string; sub?: string }) {
  return (
    <div className="wfp-empty text-center text-muted py-4">
      <div className="fw-semibold">{title}</div>
      {sub ? <div className="small mt-1">{sub}</div> : null}
    </div>
  );
}

export const pct = (x: number, digits = 0) => `${(100 * x).toFixed(digits)}%`;
export const num = (x: number) => Math.round(x).toLocaleString("en-US");
