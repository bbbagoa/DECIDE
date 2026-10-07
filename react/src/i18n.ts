// The app's translations (www/translations.json, the same file the Shiny pages
// use), for the labels React draws.
import { useEffect, useState } from "react";

type Dict = Record<string, string>;
let cache: Promise<Record<string, Dict>> | null = null;

function load(): Promise<Record<string, Dict>> {
  if (!cache) {
    cache = fetch("www/translations.json")
      .then((r) => (r.ok ? r.json() : { translation: [] }))
      .then((j: { translation: Array<Record<string, string>> }) => {
        const out: Record<string, Dict> = {};
        for (const row of j.translation ?? []) {
          for (const [lang, txt] of Object.entries(row)) {
            if (lang === "en") continue;
            (out[lang] ??= {})[row.en] = txt;
          }
        }
        return out;
      })
      .catch(() => ({}));
  }
  return cache;
}

/** t("Welcome") in the chosen language; English when no translation exists. */
export function useT(lang: string): (en: string) => string {
  const [dict, setDict] = useState<Dict>({});
  useEffect(() => {
    let alive = true;
    load().then((all) => alive && setDict(lang === "en" ? {} : all[lang] ?? {}));
    return () => { alive = false; };
  }, [lang]);
  return (en: string) => dict[en] ?? en;
}
