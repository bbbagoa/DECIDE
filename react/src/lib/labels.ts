// Variable labels (the session dictionary, R/utils_labels.R), as www/labels.js
// shows them on the Shiny pages: dropdowns of variables show the name with its
// label below; tables give the label on hover.
import { useEffect, useState } from "react";

type Dict = { labels: Record<string, string>; known: Record<string, boolean> };
const get = (): Dict => (window as unknown as { twLabels?: Dict }).twLabels ?? { labels: {}, known: {} };

export function useVarLabels(): { label: (v: string) => string | null; isVar: (v: string) => boolean } {
  const [d, setD] = useState<Dict>(get);
  useEffect(() => {
    const on = () => setD({ ...get() });
    document.addEventListener("tw-labels", on);
    return () => document.removeEventListener("tw-labels", on);
  }, []);
  return {
    label: (v) => (Object.prototype.hasOwnProperty.call(d.labels, v) ? d.labels[v] : null),
    isVar: (v) => Object.prototype.hasOwnProperty.call(d.known, v) || Object.prototype.hasOwnProperty.call(d.labels, v),
  };
}
