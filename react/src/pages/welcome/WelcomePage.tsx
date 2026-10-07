// Welcome (welcome_panel; was R/mod_welcome.R mod_welcome_ui). Explains the
// three phases and loads nothing. Server: mod_welcome_server() (the three
// shortcuts go_design / go_import / go_monitor, output$welcome_meta).
import type { ReactNode } from "react";
import { ArrowRight, BookMarked, Database, Info, Scale, Signpost, Target, UserCheck } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton } from "@/lib/inputs";
import "./welcome.css";

type T = (s: string) => string;

function Phase({ n, title, dataset, body, icon, action }: {
  n: string; title: string; dataset: string; body: string; icon: ReactNode; action: ReactNode;
}) {
  return (
    <div className="card tw-card tw-wl-phase wfp-lift">
      <div className="card-body">
        <div className="tw-wl-phase-head">
          <span className="wfp-phase-number">{n}</span>
          <span className="tw-wl-phase-icon">{icon}</span>
          <h3>{title}</h3>
        </div>
        <div className="wfp-phase-dataset"><Database size={12} aria-hidden /> {dataset}</div>
        <p>{body}</p>
        <div className="tw-wl-phase-action">{action}</div>
      </div>
    </div>
  );
}

export function WelcomePage({ t }: { active: boolean; t: T }) {
  const meta = useShinyOutputValue<{ version: string }>("welcome_meta");
  const go = (id: string, label: string, variant: "primary" | "outline-primary") => (
    <ActionButton id={id} label={<>{t(label)} <ArrowRight size={14} /></>} variant={variant} size="md" className="w-100" />
  );
  return (
    <div className="wfp-welcome tw-wl">
      <header className="wfp-hero text-center">
        <div className="wfp-eyebrow">{t("WFP Vulnerability Analysis and Mapping")}</div>
        <div className="wfp-hero-brand">
          <img src="www/wfp-logo-standard-white-en.png" alt="World Food Programme" className="wfp-hero-logo" />
          <span className="wfp-hero-divider" />
          <h1>TargetWise</h1>
        </div>
        <div className="wfp-hero-tagline"><span>{t("Reaching the most vulnerable")}</span></div>
        <div className="wfp-hero-rule" />
        <p className="wfp-hero-lead">
          {t("A workflow for designing, applying and checking humanitarian targeting: build an evidence-based scorecard from assessment data, use it to select beneficiaries from registration data, then measure what actually reached households.")}
        </p>
      </header>

      <section className="tw-wl-phases" aria-label={t("The three phases")}>
        <Phase n="1" title={t("Targeting Design")} dataset={t("Needs-assessment data")} icon={<Scale size={18} />}
               body={t("Screen candidate eligibility criteria against a food-security outcome, fit a scorecard, and see the inclusion and exclusion errors your design would produce before anyone is served.")}
               action={go("go_design", "Start a targeting design", "primary")} />
        <Phase n="2" title={t("Beneficiary Selection")} dataset={t("Household registration data")} icon={<UserCheck size={18} />}
               body={t("Load and clean the registration data, spot-check it against field verification, then apply the scorecard and your eligibility rules to produce the beneficiary list.")}
               action={go("go_import", "Load registration data", "outline-primary")} />
        <Phase n="3" title={t("Targeting Monitoring")} dataset={t("Post-distribution monitoring data")} icon={<Target size={18} />}
               body={t("Compare who was eligible with who actually received assistance, and measure the errors introduced during implementation rather than in the design.")}
               action={go("go_monitor", "Open monitoring", "outline-primary")} />
      </section>

      <section className="tw-wl-row">
        <div className="card tw-card">
          <div className="card-header"><span className="tw-card-title"><Signpost size={15} /> {t("Where to start")}</span></div>
          <div className="card-body">
            <ol className="tw-wl-steps">
              <li>{t("Designing a new targeting approach? Start with Targeting Design and load your assessment extract there.")}</li>
              <li>{t("Already have a design and need the beneficiary list? Go to Beneficiary Selection and load the registration data.")}</li>
              <li>{t("Checking a completed distribution? Go to Targeting Monitoring and load the PDM extract.")}</li>
            </ol>
            <div className="tw-wl-note"><Info size={14} aria-hidden /> {t("Each phase loads its own dataset. Nothing you load in one phase overwrites another.")}</div>
          </div>
        </div>
        <div className="card tw-card">
          <div className="card-header"><span className="tw-card-title"><BookMarked size={15} /> {t("Methodological basis")}</span></div>
          <div className="card-body">
            <div className="tw-wl-label">{t("WFP VAM Needs Assessment and Targeting Unit")}</div>
            <ul className="tw-wl-refs">
              <li><strong>WFP (2021)</strong><span>{t("Targeting and Prioritization Operational Guidance Note")}</span></li>
              <li><strong>Advisory 1/2025</strong><span>{t("Concerns regarding the use of outcome indicators during the targeting process")}</span></li>
              <li><strong>Advisory 2/2025</strong><span>{t("Methodological note on targeting errors measurement")}</span></li>
              <li><strong>Advisory 3/2025</strong><span>{t("Using ROC curves for targeting analysis")}</span></li>
            </ul>
          </div>
        </div>
      </section>

      {/* No personal details in the app: authorship, citation and contact are in the README. */}
      <footer className="card tw-card wfp-credits">
        <div className="card-body tw-wl-about">
          <div>
            <div className="tw-wl-label">{t("About")}</div>
            <div className="small">
              {t("Open-source R package for humanitarian targeting: design on assessment data, beneficiary selection on registration data, and monitoring on PDM data. ")}
              {t("Documentation, how to cite and how to report an issue are in the README distributed with the package.")}
            </div>
          </div>
          <div>
            <div className="tw-wl-label">{t("Release")}</div>
            <dl className="tw-wl-release small">
              <dt>{t("Version")}</dt><dd>{meta?.version ?? "…"}</dd>
              <dt>{t("Licence")}</dt><dd>GPL (&gt;= 3)</dd>
              <dt>{t("Built with")}</dt><dd>R, Shiny, React</dd>
            </dl>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default WelcomePage;
