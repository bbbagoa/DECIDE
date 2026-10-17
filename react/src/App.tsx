// The DECIDE shell (the R package is TargetWise): navbar, pages, theme, language. Page values match the
// Shiny app's (welcome_panel, scorecard_panel, ...) so the server's navigation
// (tw_nav() in R/utils_react.R), session restore and every link keep working.
//
// A page is either ported to React (a folder src/pages/<name>/ whose index.tsx
// exports `page` (the page value) and a default component) or still the Shiny page,
// hosted in a `pg_<value>` holder rendered by the server. Every page stays
// mounted and is hidden with CSS, so a page keeps its state between visits;
// Shiny is told when a hosted page is shown or hidden, as Bootstrap tabs do,
// so its outputs pause and resume.
import { useEffect, useRef, useState, type ComponentType, type ReactNode } from "react";
import { signalShown } from "@/lib/layout";
import {
  CircleUserRound, ClipboardCheck, History, House, Map as MapIcon, Moon, ScanSearch, Scale, Sun, Target, Upload, UserCheck,
} from "lucide-react";
import { ShinyOutput, useSetShinyInput, useShinyInitialized, useShinyInput, useShinyMessageHandler } from "@/shiny";
import { useT } from "@/i18n";
import { SessionToolbar } from "@/components/SessionToolbar";
import { DecideName, PhaseLetters } from "@/components/Decide";

// `phases`: the DECIDE letters an entry covers (0 Design, 1 Estimate, 2 Clean,
// 3 Identify, 4 Document, 5 Evaluate), shown before its label
type Page = { value: string; label: string; Icon: ComponentType<{ size?: number }>; phases?: number[] };
type NavEntry = Page | { menu: string; value: string; label: string; Icon: Page["Icon"]; phases?: number[]; pages: Page[] };

const NAV: NavEntry[] = [
  { value: "welcome_panel", label: "Welcome", Icon: House },
  { value: "scorecard_panel", label: "Targeting Design", Icon: Scale, phases: [0, 1] },
  {
    menu: "selection", value: "selection_menu", label: "Beneficiary Selection", Icon: UserCheck, phases: [2, 3],
    pages: [
      { value: "import_panel", label: "Load registration data", Icon: Upload },
      { value: "overview_panel", label: "Overview", Icon: MapIcon },
      { value: "dq_panel", label: "Data Quality", Icon: ClipboardCheck },
      { value: "spot_panel", label: "Spot Checking", Icon: ScanSearch },
      { value: "ben_panel", label: "Selection", Icon: CircleUserRound },
    ],
  },
  { value: "pdm_panel", label: "Targeting Monitoring", Icon: Target, phases: [5] },
  { value: "modif_logs", label: "Activity Log", Icon: History, phases: [4] },
];
const PAGES: Page[] = NAV.flatMap((e) => ("pages" in e ? e.pages : [e]));

// Pages drawn in React, found by their folder; the others are the Shiny page, hosted.
type PageProps = { active: boolean; t: (s: string) => string };
const PORTED: Record<string, ComponentType<PageProps>> = Object.fromEntries(
  Object.values(import.meta.glob<{ page: string; default: ComponentType<PageProps> }>("./pages/*/index.tsx", { eager: true }))
    .map((m) => [m.page, m.default]),
);

type NavMsg = { action: "select"; target: string[] };

export default function App() {
  const [current, setCurrent] = useShinyInput<string>("main_nav", "welcome_panel", { debounceMs: 0 });
  const [lang, setLang] = useShinyInput<string>("lang_selector", "en", { debounceMs: 0 });
  const [mode, setMode] = useShinyInput<string>("dark_mode", "light", { debounceMs: 0 });
  // pages the server keeps hidden (until the registration data is mapped)
  // hidden from the start, as app_ui did, until the server's state arrives
  const [hiddenList, setHiddenList] = useState<string[]>(["overview_panel", "dq_panel", "spot_panel", "ben_panel"]);
  useShinyMessageHandler<{ hidden: string[] }>("tw-nav-state", (m) => setHiddenList(m.hidden ?? []));
  const hidden = new Set(hiddenList);
  // Handshake: once connected and subscribed, say so; the server recomputes
  // the state computed before (a value sent before the client subscribed is
  // not delivered again).
  const initialized = useShinyInitialized();
  const setReady = useSetShinyInput<number>("tw_client_ready", 0, { debounceMs: 0 });
  // the server renders the Shiny page only for the pages not drawn here
  useShinyInput<string[]>("tw_ported", Object.keys(PORTED), { debounceMs: 0 });
  useEffect(() => {
    if (!initialized) return;
    const id = window.setTimeout(() => setReady(Date.now()), 50);
    return () => window.clearTimeout(id);
  }, [initialized]); // eslint-disable-line
  const [menuOpen, setMenuOpen] = useState(false);
  const t = useT(lang);

  // the server moves to a page as it did with bslib::nav_select()
  useShinyMessageHandler<NavMsg>("tw-nav", (m) => { if (m.action === "select" && m.target.length) setCurrent(m.target[0]); });

  useEffect(() => { document.documentElement.setAttribute("data-bs-theme", mode); }, [mode]);

  // close the menu on any click outside it
  const menuRef = useRef<HTMLLIElement>(null);
  useEffect(() => {
    const close = (e: MouseEvent) => { if (menuRef.current && !menuRef.current.contains(e.target as Node)) setMenuOpen(false); };
    document.addEventListener("click", close);
    return () => document.removeEventListener("click", close);
  }, []);

  const go = (v: string) => { setCurrent(v); setMenuOpen(false); };
  const inMenu = (e: NavEntry) => "pages" in e && e.pages.some((p) => p.value === current);

  return (
    <div className="tw-app">
      <nav className="navbar navbar-expand navbar-dark bg-primary tw-navbar" data-bs-theme="dark">
        <div className="container-fluid">
          <span className="navbar-brand">
            <img src="www/wfp-logo-standard-white-en.png" height={35} style={{ marginTop: -5 }} alt="WFP" />
            <span className="brand-divider" />
            <span className="brand-text"><DecideName dark /></span>
          </span>
          <ul className="navbar-nav nav me-auto">
            {NAV.map((e) =>
              "pages" in e ? (
                <li key={e.value} ref={menuRef} className={"nav-item dropdown" + (menuOpen ? " show" : "")}>
                  <a href="#" role="button" className={"nav-link dropdown-toggle" + (inMenu(e) ? " active" : "")}
                     onClick={(ev) => { ev.preventDefault(); setMenuOpen(!menuOpen); }}>
                    {e.phases ? <PhaseLetters phases={e.phases} /> : <e.Icon size={15} />} {t(e.label)}
                  </a>
                  <ul className={"dropdown-menu" + (menuOpen ? " show" : "")}>
                    {e.pages.filter((p) => !hidden.has(p.value)).map((p) => (
                      <li key={p.value}>
                        <a href="#" data-value={p.value} className={"dropdown-item" + (p.value === current ? " active" : "")}
                           onClick={(ev) => { ev.preventDefault(); go(p.value); }}>
                          <p.Icon size={15} /> {t(p.label)}
                        </a>
                      </li>
                    ))}
                  </ul>
                </li>
              ) : hidden.has(e.value) ? null : (
                <li key={e.value} className="nav-item">
                  <a href="#" data-value={e.value} className={"nav-link" + (e.value === current ? " active" : "")}
                     onClick={(ev) => { ev.preventDefault(); go(e.value); }}>
                    {e.phases ? <PhaseLetters phases={e.phases} /> : <e.Icon size={15} />} {t(e.label)}
                  </a>
                </li>
              ),
            )}
          </ul>
          <div className="d-flex align-items-center gap-3 tw-nav-right">
            <ShinyOutput id="co_badge" tagName="span" className="shiny-html-output" />
            <div className="mini-theme-selector">
              <span>{t("Language")}</span>
              <select className="form-select form-select-sm" value={lang} onChange={(ev) => setLang(ev.target.value)} aria-label="Language">
                <option value="en">English</option>
                <option value="fr">{"Français"}</option>
              </select>
            </div>
            <SessionToolbar t={t} />
            <button type="button" className="btn btn-sm tw-mode-btn" onClick={() => setMode(mode === "dark" ? "light" : "dark")}
                    title={mode === "dark" ? "Light mode" : "Dark mode"} aria-label="Switch light and dark mode">
              {mode === "dark" ? <Sun size={18} /> : <Moon size={18} />}
            </button>
          </div>
        </div>
      </nav>
      <main className="tw-main">
        {PAGES.map((p) => {
          const Ported = PORTED[p.value];
          const active = p.value === current;
          return Ported
            ? <PortedPage key={p.value} value={p.value} active={active}><Ported active={active} t={t} /></PortedPage>
            : <HostedPage key={p.value} value={p.value} active={active} />;
        })}
      </main>
    </div>
  );
}

/**
 * A React page. Mounted hidden, so Shiny is told when it is shown: its
 * outputs (download links, hosted UI) are paused while hidden, as in a tab.
 */
function PortedPage({ value, active, children }: { value: string; active: boolean; children: ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => signalShown(ref.current, active), [active]);
  return <div ref={ref} className="tw-page" data-value={value} style={{ display: active ? "flex" : "none" }}>{children}</div>;
}

/** A Shiny page not ported yet, rendered by the server in output$pg_<value>. */
function HostedPage({ value, active }: { value: string; active: boolean }) {
  const id = "pg_" + value;
  useEffect(() => {
    const el = document.getElementById(id);
    const $ = (window as unknown as { jQuery?: (e: Element) => { trigger: (ev: string) => void } }).jQuery;
    if (el && $) $(el).trigger(active ? "shown" : "hidden");
    // charts and maps measure themselves on resize
    if (active) window.dispatchEvent(new Event("resize"));
  }, [active, id]);
  return (
    <ShinyOutput id={id} className="shiny-html-output tw-page tw-hosted html-fill-container"
                 style={{ display: active ? "flex" : "none" }} />
  );
}
