// A file input of this page (Shiny's fileInput, drawn by the server in a
// renderUI holder) in the drop zone of the shared FileImport component.
import { Upload } from "lucide-react";
import { HostedUI } from "@/lib/inputs";
import "@/components/modules.css";

export function Dropzone({ id }: { id: string }) {
  return (
    <div className="tw-dropzone mb-2">
      <Upload size={18} className="tw-dropzone-icon" aria-hidden />
      <HostedUI id={id} className="tw-dropzone-input" />
    </div>
  );
}
