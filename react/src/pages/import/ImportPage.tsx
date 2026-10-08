// Load registration data (import_panel; was R/mod_welcome.R mod_import_panel_ui).
// Modules: file_import_1 (file upload), moda_import_1 (server import),
// calc_reg (variable calculator), setup_1 (variable mapping). The import
// summary, the "data already in memory" warning and the mapping dialogs stay
// Shiny's (showModal()); their buttons keep their ids (btn_import_to_setup,
// setup_1-save, setup_1-review_confirm).
import { CircleCheck, CircleDashed, ClipboardList, ListChecks, SlidersHorizontal } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton } from "@/lib/inputs";
import { Card } from "@/lib/layout";
import { FileImport } from "@/components/FileImport";
import { ModaImport } from "@/components/ModaImport";
import { VarCalc } from "@/components/VarCalc";
import { DataSummary } from "@/components/DataSummary";
import "./import.css";

type T = (s: string) => string;
type State = { loaded: boolean; rows?: number; cols?: number; source?: string; mapped?: boolean; fields?: number };
const n = (x?: number) => (x ?? 0).toLocaleString("en-US");

function DataStatus({ t }: { t: T }) {
  const s = useShinyOutputValue<State>("setup_1-state");
  if (!s?.loaded) {
    return (
      <div className="tw-imp-status tw-imp-status-empty">
        <CircleDashed size={18} aria-hidden />
        <div>{t("No registration data yet. Load a file or pull it from a server; the variable setup opens after the import.")}</div>
      </div>
    );
  }
  return (
    <div className="tw-imp-status">
      {s.mapped ? <CircleCheck size={18} className="tw-imp-ok" aria-hidden /> : <CircleDashed size={18} className="tw-imp-todo" aria-hidden />}
      <div className="tw-imp-status-text">
        <div className="tw-imp-status-main">
          <strong>{n(s.rows)}</strong> {t("rows")} · <strong>{n(s.cols)}</strong> {t("columns")}
          <span className={`tw-imp-badge${s.mapped ? " ok" : ""}`}>
            {s.mapped ? `${t("Variables mapped")} (${s.fields})` : t("Variables not mapped yet")}
          </span>
        </div>
        {s.source ? <div className="tw-imp-status-sub">{s.source}</div> : null}
      </div>
      <ActionButton id="setup_1-open_modal" label={t("Variable Definition & Setup")} icon={<SlidersHorizontal size={15} />}
                    variant={s.mapped ? "outline-primary" : "primary"} size="md" />
    </div>
  );
}

const code = (x: string) => <code>{x}</code>;

export function ImportPage({ t }: { active: boolean; t: T }) {
  return (
    <div className="tw-imp">
      <div className="tw-imp-head">
        <h4>{t("Load household registration data")}</h4>
        <p>{t("The list of households you will clean, check and select beneficiaries from.")}</p>
      </div>

      <Card title={t("Household registration data")} icon={<ClipboardList size={15} />}>
        <p className="tw-imp-formats">
          {t("Excel (.xlsx), SPSS (.sav), Stata (.dta), CSV or Parquet; CSV and Parquet load fastest for large files. You can also pull the data from MODA, Kobo Toolbox or ODK Central.")}
        </p>
        <div className="tw-imp-grid">
          <FileImport ns="file_import_1" label={t("Load registration data")} t={t} />
          <div className="tw-imp-alt">
            <label className="form-label">{t("Or pull from a server")}</label>
            <ModaImport ns="moda_import_1" t={t} />
          </div>
          <div className="tw-imp-alt">
            <label className="form-label">{t("Missing a variable?")}</label>
            <VarCalc ns="calc_reg" size="md" block t={t} />
            <DataSummary ns="summary_reg" block className="mt-2" t={t} />
          </div>
        </div>
        <DataStatus t={t} />
      </Card>

      <Card title={t("Before you start, check your data")} icon={<ListChecks size={15} />}>
        <ol className="tw-imp-checks">
          <li>{t("Ensure quantitative variables (Age, HH Size, Scores) are formatted as")} {code("numeric")} {t("in your source file.")}</li>
          <li>{t("Vulnerability scales must be")} {code("ordered")} {t("(e.g., 1 to 5).")} {t("Fewer and shorter value labels are recommended for qualitative variables.")}</li>
          <li>{t("Records with missing")} {code("Long/Lat")} {t("coordinates are left off the map.")}</li>
          <li>{t("Verify that Administrative names are consistent across all levels to avoid filtering errors.")}</li>
          <li>{t("Do not remove or rename the")} {code("start")} / {code("end")} {t("variables. They are essential for computing survey duration and tracking operational speed.")}</li>
        </ol>
      </Card>
    </div>
  );
}

export default ImportPage;
