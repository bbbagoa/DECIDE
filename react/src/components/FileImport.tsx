// File upload for any page (R/mod_file_import.R, module mod_file_import_server).
//
//   <FileImport ns="file_import_1" label={t("Load registration data")} t={t} />
//
// Props
//   ns     the module id (input `${ns}-file_in`, outputs `${ns}-file_ui`, `${ns}-loaded`)
//   label  text above the drop zone (optional)
//   hint   a line under it (optional; formats, size limit...)
//   t      translator (optional)
//
// The file input itself is Shiny's fileInput (no shinyreact equivalent: it
// streams the upload), drawn by the server in output$file_ui and hosted here;
// Shiny's drag and drop works on the whole zone. The rest is React: the
// line "<file> loaded: n rows, m columns" comes from output$loaded.
import type { ReactNode } from "react";
import { CircleCheck, Upload } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { HostedUI } from "@/lib/inputs";
import "./modules.css";

type Loaded = { name: string; rows: number; cols: number } | null;
const n = (x: number) => x.toLocaleString("en-US");

export function FileImport({ ns, label, hint, t = (s) => s }: {
  ns: string; label?: ReactNode; hint?: ReactNode; t?: (s: string) => string;
}) {
  const loaded = useShinyOutputValue<Loaded>(`${ns}-loaded`);
  return (
    <div className="tw-fileimport">
      {label ? <label className="form-label">{label}</label> : null}
      <div className="tw-dropzone">
        <Upload size={18} className="tw-dropzone-icon" aria-hidden />
        <HostedUI id={`${ns}-file_ui`} className="tw-dropzone-input" />
      </div>
      {hint ? <div className="form-text">{hint}</div> : null}
      {loaded ? (
        <div className="tw-file-ok">
          <CircleCheck size={14} aria-hidden />
          <span><strong>{loaded.name || t("File loaded.")}</strong> · {n(loaded.rows)} {t("rows")} · {n(loaded.cols)} {t("columns")}</span>
        </div>
      ) : null}
    </div>
  );
}

export default FileImport;
