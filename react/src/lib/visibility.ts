// Hidden outputs wait. Shiny pauses an output whose element is hidden (a tab
// not shown, a folded section) until it shows again (suspendWhenHidden, the
// default). shinyreact binds each output to a div of its own in an invisible
// holder, which Shiny always sees as shown, so every chart and table was
// computed on every change, on every page. Here each React chart / table says
// whether it is on screen: its shinyreact div is hidden with it, and Shiny is
// told to look again (the "shown" / "hidden" events it listens to).
import { useEffect, type RefObject } from "react";

type JQ = (e: Element | Document) => { trigger: (ev: string) => void; on: (ev: string, fn: () => void) => void };
const jq = () => (window as unknown as { jQuery?: JQ }).jQuery;

const tracked = new Map<string, number>(); // id -> number of components showing it
const holders = new Map<string, RefObject<HTMLElement | null>>(); // id -> the element it is drawn in, when not its own
const state = new Map<string, boolean>();  // id -> hidden, as last told to Shiny
let started = false;
let pending = 0;

/** Our element for the output (not shinyreact's: that one lives in its holder). */
function ours(id: string): HTMLElement | null {
  for (const el of document.querySelectorAll<HTMLElement>(`[id="${CSS.escape(id)}"]`)) {
    if (!el.closest(".shiny-react-output-container")) return el;
  }
  return null;
}
function theirs(id: string): HTMLElement | null {
  return document.querySelector<HTMLElement>(`.shiny-react-output-container [id="${CSS.escape(id)}"]`);
}

function check() {
  pending = 0;
  const $ = jq();
  let changed: HTMLElement | null = null;
  for (const id of tracked.keys()) {
    const el = holders.get(id)?.current ?? ours(id), out = theirs(id);
    if (!el || !out) continue;
    // display: none on the element or an ancestor; a full-screen card is fixed
    const hidden = el.offsetParent === null && getComputedStyle(el).position !== "fixed";
    if (state.get(id) === hidden) continue;
    state.set(id, hidden);
    out.style.display = hidden ? "none" : "";
    changed = out;
  }
  // one event makes Shiny re-read every output's state
  if (changed && $) $(changed).trigger("shown");
}

/** Look again soon (after the layout settles). */
export function recheckVisibility() {
  if (!pending) pending = window.requestAnimationFrame(check);
}

function start() {
  if (started) return;
  started = true;
  const $ = jq();
  // pages, tabs and folding steps announce themselves (signalShown)
  if ($) $(document).on("shown hidden", () => recheckVisibility());
  window.addEventListener("resize", recheckVisibility);
  document.addEventListener("click", () => window.setTimeout(recheckVisibility, 50), true);
  // and a slow sweep for anything shown or hidden another way
  window.setInterval(recheckVisibility, 1500);
}

/**
 * Call in a component that draws output `id`. Chart and DataTable do it; for a
 * JSON output (reactive_output()) that is costly to compute, pass the element
 * it is drawn in: `useOutputVisibility(ns("ov_profile"), sectionRef)`.
 */
export function useOutputVisibility(id: string, holder?: RefObject<HTMLElement | null>) {
  useEffect(() => {
    if (!id) return;
    start();
    if (holder) holders.set(id, holder);
    tracked.set(id, (tracked.get(id) ?? 0) + 1);
    state.delete(id);
    recheckVisibility();
    // shinyreact makes its div once something reads the output: try again shortly
    const t = window.setTimeout(recheckVisibility, 300);
    return () => {
      window.clearTimeout(t);
      const n = (tracked.get(id) ?? 1) - 1;
      if (n > 0) { tracked.set(id, n); return; }
      tracked.delete(id);
      holders.delete(id);
      state.delete(id);
      const out = theirs(id);
      if (out) out.style.display = "";
    };
  }, [id]);
}
