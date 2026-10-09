// Refresh a page's data from its MODA form (R/mod_moda_refresh.R).
//
//   <ModaRefresh ns="scorecard_1-moda_refresh" t={t} />
//
// Props
//   ns        the module id (button `${ns}-go`, state `${ns}-state`)
//   block     full width (default false)
//   className extra class on the button
//   t         translator (optional)
//
// Shown only when the data came from a MODA form (also after a restore: the
// form is saved with the page's work, never the API key).
import { RefreshCw } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton } from "@/lib/inputs";

export function ModaRefresh({ ns, block, className, t = (s) => s }: {
  ns: string; block?: boolean; className?: string; t?: (s: string) => string;
}) {
  const s = useShinyOutputValue<{ form: string | null }>(`${ns}-state`);
  if (!s?.form) return null;
  return (
    <ActionButton id={`${ns}-go`} label={t("Refresh from MODA")} icon={<RefreshCw size={14} />} variant="outline-secondary"
                  className={[block ? "w-100" : "", className ?? ""].join(" ").trim() || undefined}
                  title={`${t("Fetch the submissions received since, from MODA form")} ${s.form}`} />
  );
}

export default ModaRefresh;
