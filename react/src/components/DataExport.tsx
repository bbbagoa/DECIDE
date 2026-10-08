// Download the data as it is now (R/mod_data_export.R), for any page.
//
//   <DataExport ns="export_reg" t={t} />
//
// Props
//   ns        the module id (downloads `${ns}-xlsx`, `-sav`, `-dta`, `-parquet`)
//   label     button text (default "Download data")
//   variant   button style (default "outline-secondary")
//   block     full width (default false)
//   className extra class on the wrapper
//   t         translator (optional)
//
// A menu of formats: Excel (read-only, as every export), SPSS, Stata, Parquet.
import { useEffect, useRef, useState } from "react";
import { ChevronDown, Download } from "lucide-react";
import { ShinyOutput } from "@/shiny";

const FORMATS = [
  { key: "xlsx", label: "Excel (.xlsx, read-only)" },
  { key: "sav", label: "SPSS (.sav)" },
  { key: "dta", label: "Stata (.dta)" },
  { key: "parquet", label: "Parquet (.parquet)" },
];
type Variant = "outline-secondary" | "outline-primary" | "primary";

export function DataExport({ ns, label = "Download data", variant = "outline-secondary", block, className, t = (s) => s }: {
  ns: string; label?: string; variant?: Variant; block?: boolean; className?: string; t?: (s: string) => string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const close = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener("click", close);
    return () => document.removeEventListener("click", close);
  }, [open]);
  return (
    <div ref={ref} className={`dropdown tw-export${block ? " w-100" : ""}${className ? " " + className : ""}`}>
      <button type="button" className={`btn btn-${variant} btn-sm dropdown-toggle-split tw-export-btn${block ? " w-100" : ""}`}
              aria-expanded={open} onClick={() => setOpen(!open)} title={t("The data as it is now, after cleaning")}>
        <Download size={14} /> {t(label)} <ChevronDown size={13} />
      </button>
      {/* always rendered (download links need their address); shown on click */}
      <div className={`dropdown-menu tw-export-menu${open ? " show" : ""}`}>
        {FORMATS.map((f) => (
          <ShinyOutput key={f.key} id={`${ns}-${f.key}`} tagName="a" className="dropdown-item shiny-download-link"
                       {...{ download: "", target: "_blank", onClick: () => setOpen(false) }}>
            {t(f.label)}
          </ShinyOutput>
        ))}
      </div>
    </div>
  );
}

export default DataExport;
