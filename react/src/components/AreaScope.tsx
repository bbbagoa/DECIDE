// Areas covered by an analysis (R/mod_area_scope.R), for any page.
//
//   <AreaScope ns="pdm_1-scope" title={null} t={t} />
//
// Props
//   ns     the module id (inputs `${ns}-col1`, `${ns}-val1`, `${ns}-col2`,
//          `${ns}-val2`, buttons `${ns}-apply`, `${ns}-clear`, text `${ns}-status`)
//   title  heading with an info tip (default "Areas covered"); null for none
//          (a line of help instead, as inside a sidebar step)
//   t      translator (optional)
//
// Server unchanged: it fills the column choices (updateSelectInput), cascades
// the area pickers (cascade_pickers()), applies the scope on Apply and clears
// it with the cross; the status line says what is covered.
import { Filter, Info, MapPin, X } from "lucide-react";
import { ActionButton, SelectInput, TextOutput } from "@/lib/inputs";
import "./modules.css";

const TIP = "Which part of the data this analysis covers. Households outside these areas are left out of the analysis entirely (they are not counted as not selected), and the reports say which areas are covered.";

export function AreaScope({ ns, title = "Areas covered", t = (s) => s }: {
  ns: string; title?: string | null; t?: (s: string) => string;
}) {
  const id = (x: string) => `${ns}-${x}`;
  const level = (k: 1 | 2, label: string) => (
    <div className="tw-scope-level" key={k}>
      <SelectInput id={id(`col${k}`)} label={t(`${label} column`)} choices={[{ value: "", label: t("(none)") }]} value="" clearable={false} />
      <SelectInput id={id(`val${k}`)} choices={[]} multiple actions placeholder={t("All areas")} className="tw-scope-values" />
    </div>
  );
  return (
    <div className="tw-scope">
      {title ? (
        <div className="tw-scope-head">
          <MapPin size={15} aria-hidden /> {t(title)}
          <span className="tw-scope-tip" title={t(TIP)} aria-label={t(TIP)}><Info size={13} /></span>
        </div>
      ) : (
        <p className="small text-muted mb-2">{t("Leave empty to cover every area. Records outside the chosen areas are left out of this analysis and its report.")}</p>
      )}
      {level(1, "First level")}
      {level(2, "Second level")}
      <div className="d-flex gap-2">
        <ActionButton id={id("apply")} label={t("Apply areas")} icon={<Filter size={14} />} className="flex-fill" />
        <ActionButton id={id("clear")} icon={<X size={14} />} variant="outline-secondary" title={t("All areas")} />
      </div>
      <div className="small text-muted mt-1"><TextOutput id={id("status")} /></div>
    </div>
  );
}

export default AreaScope;
