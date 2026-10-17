// The DECIDE name in its six colours, and the phase letters the navigation
// carries. One letter per phase of the targeting cycle (WFP UI Kit palette):
// Design, Estimate, Clean, Identify, Document, Evaluate.
import "./decide.css";

export const DECIDE = ["D", "E", "C", "I", "D", "E"] as const;
export const PHASES = ["Design", "Estimate", "Clean", "Identify", "Document", "Evaluate"] as const;
/** The phase colours: a ramp around the colour wheel at equal brightness,
 *  blue, teal, green, gold, coral, violet (which leads back to blue: the
 *  cycle). On white: */
export const LETTER_LIGHT = ["#0A78C2", "#0E9A8F", "#3E8E3A", "#C8901A", "#D45A35", "#7B5CC9"];
/** On the banner blue and in dark mode */
export const LETTER_DARK = ["#5BB8F0", "#4FD1C5", "#8BD17C", "#F5C451", "#F28C6B", "#B79CF2"];

/** The name's colours (decide_colours() in R/utils_helpers.R): the letters'
 *  gradient, the ochre I, the six phase bars. */
const COL_DARK = { letter: ["#FFFFFF", "#F1F6FB", "#C9DCEC"], accent: ["#FFE6A6", "#F5C451", "#DCA22E"], shadow: ".32", bars: LETTER_DARK };
const COL_LIGHT = { letter: ["#2A5B82", "#19486A", "#031C2D"], accent: ["#E8B54A", "#C8901A", "#A06F0E"], shadow: ".12", bars: LETTER_LIGHT };

/** The name: pearl letters (the I in ochre: Identify, the moment a household
 *  is selected), each standing on a short bar in the colour of its phase, so
 *  it reads as six steps. The space above the letters equals the bar below,
 *  so the letters sit on the centre of what they are aligned with (the WFP
 *  logo). `dark` on a dark ground. */
export function DecideName({ dark = false, className }: { dark?: boolean; className?: string }) {
  const k = dark ? COL_DARK : COL_LIGHT;
  return (
    <span className={`tw-decide${className ? ` ${className}` : ""}`} aria-label="DECIDE">
      {DECIDE.map((l, i) => {
        const f = i === 3 ? k.accent : k.letter;
        return (
          <span key={i} className="tw-decide-step" aria-hidden>
            <span className="tw-decide-l" style={{ backgroundImage: `linear-gradient(180deg, ${f[0]} 0%, ${f[1]} 60%, ${f[2]} 100%)`,
                                                  filter: `drop-shadow(0 .03em .03em rgba(0,0,0,${k.shadow}))` }}>{l}</span>
            <span className="tw-decide-bar" style={{ background: k.bars[i] }} />
          </span>
        );
      })}
    </span>
  );
}

/** The six phase words with the first letter emphasised in its colour. */
export function PhaseWords({ t, dark = true }: { t: (s: string) => string; dark?: boolean }) {
  const c = dark ? LETTER_DARK : LETTER_LIGHT;
  return (
    <span className="tw-phase-words">
      {PHASES.map((p, i) => {
        const w = t(p);
        return <span key={p}><b style={{ color: c[i] }}>{w.charAt(0)}</b>{w.slice(1)}</span>;
      })}
    </span>
  );
}

/** The letters of a navigation entry's phases. Drawn with CSS (data-l), so
 *  they stay out of the entry's text: its label reads as before. */
export function PhaseLetters({ phases, dark = true }: { phases: number[]; dark?: boolean }) {
  const c = dark ? LETTER_DARK : LETTER_LIGHT;
  return (
    <span className="tw-phase-letters" aria-hidden title={phases.map((p) => PHASES[p]).join(" · ")}>
      {phases.map((p) => <span key={p} className="tw-phase-letter" data-l={DECIDE[p]} style={{ color: c[p] }} />)}
    </span>
  );
}
