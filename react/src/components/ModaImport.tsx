// Import from a data collection server (MODA / ONA, Kobo Toolbox, ODK Central),
// R/mod_moda_import.R, for any page.
//
//   <ModaImport ns="scorecard_1-moda" label={t("MODA")} t={t} />
//
// Props
//   ns         the module id (button `${ns}-btn_open_moda`)
//   label      button text (default "Import from a server")
//   variant    button style (default "outline-secondary")
//   block      full width (default true)
//   size       "sm" | "md" (default "md")
//   t          translator (optional)
//
// The button opens the module's Shiny dialog (server, form, key, Sync Now,
// confirmation, download progress): those stay Shiny's (showModal()). The
// server returns the data through mod_moda_import_server()$data as before.
import { CloudDownload } from "lucide-react";
import { ActionButton } from "@/lib/inputs";

type Variant = Parameters<typeof ActionButton>[0]["variant"];

export function ModaImport({ ns, label = "Import from a server", variant = "outline-secondary", block = true, size = "md", t = (s) => s }: {
  ns: string; label?: string; variant?: Variant; block?: boolean; size?: "sm" | "md"; t?: (s: string) => string;
}) {
  return (
    <ActionButton id={`${ns}-btn_open_moda`} label={t(label)} icon={<CloudDownload size={15} />} variant={variant}
                  size={size} className={block ? "w-100" : undefined} title={t("Import from a MODA / ONA form")} />
  );
}

export default ModaImport;
