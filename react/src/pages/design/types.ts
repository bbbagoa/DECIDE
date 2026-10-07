// The JSON the server sends the Targeting Design page (R/mod_scorecard.R,
// "The React page" section). Numbers may be null where R had NA.
import type { Choice } from "@/lib/inputs";

export type Mode = "outcome" | "pmt" | "none";
export type HelpEntry = { shows: string; read: string };

export type Meta = {
  models: Record<Mode, Choice[]>;
  schemes: Choice[];
  compare_default: string[];
  pmt_compare_default: string[];
  axes: string[];
  clusters: string[];
  help: Record<string, HelpEntry>;
  tol_default: [number, number];
};

export type NavStep = { ok: boolean; done: string; todo: string; n?: number; adopted?: boolean; adopted_at?: string };

export type Flow = {
  mode: Mode; here: string; has_data: boolean;
  data: { rows: number; cols: number; source: string } | null;
  steps: { key: string; label: string; done: boolean; panel: string }[];
  todo_i: number | null;
  status: { kind: "complete" | "todo" | "done"; text: string };
  earlier: { label: string; panel: string } | null;
  next_panel: string | null; next_label: string | null;
  nav: { outcome: NavStep; screening: NavStep; weights: NavStep; threshold: NavStep };
  gates: { screening: boolean; weights: boolean; threshold: boolean };
  framework_ready: boolean;
  fw_note: "validate" | "stale" | "ok";
  pmt_note: "validate" | "stale" | "ok";
  qs_stale: boolean;
  fit: { method: string; unsupervised: boolean; pmt: boolean; index: string | null; cluster: boolean; runs_inline: boolean } | null;
  params: string | null;
  scheme_apply: boolean;
  adopted: boolean; can_adopt: boolean;
};

export type Framework = {
  outcome: { n: number; pct: number | null; opos: string } | null;
  pmt: {
    n: number; median: string; line: string; poor: number;
    requirements: { status: "ok" | "warn" | "fail"; check: string; detail: string }[];
  } | null;
};

export type CritRow = {
  id: string; criterion: string; use: boolean;
  vuln: number | null; other: number | null; yes: number | null; missing: number | null;
  or: number | null; or_low: number | null; or_high: number | null; p: number | null; sig: boolean;
  dir: "inclusion" | "exclusion" | null; testable: boolean;
  overlap: { text: string; high: boolean } | null;
};
export type Criteria = { nof: boolean; rows: CritRow[]; n: number; associated: number; repeating: number; stamp: number };

export type PmtNumeric = { rows: { id: string; proxy: string; use: boolean; mean: number | null; missing: number | null; r: number | null }[]; stamp: number };

export type EstRow = {
  id: string; criterion: string; numeric: boolean; beta: number | null; se: number | null;
  or: number | null; or_low: number | null; or_high: number | null; p: number | null;
  dir: "inclusion" | "exclusion" | null; points: number | null; others: (number | null)[]; imp: number | null; agree: boolean | null;
};
export type Estimates = { pmt: boolean; unsupervised: boolean; others: string[]; has_imp: boolean; rows: EstRow[]; fit_line: string | null; stamp: number };

export type Run = { id: number; at: string; model: string; scheme: string; criteria: number; auc: number | null; held_out: boolean; current: boolean; best: boolean };
export type Comparison = {
  kind: "none" | "pmt" | "scorecard"; runs: Run[]; title: string; why?: string | null;
  table?: Record<string, number | string | null>[] | null;
};

export type Slider = { min: number; max: number; value: number; stamp: number };

export type Thresh = {
  e: {
    n: number; correctly_included: number; excluded_in_need: number; included_not_in_need: number; correctly_excluded: number;
    inclusion_error: number | null; exclusion_error: number | null; coverage: number | null;
  };
  lower: number; upper: number; threshold: string; outcome: string; opos: string; pmt: boolean;
  verdict: { level: string; interpretation: string; action: string };
  words: Record<"vuln" | "notvuln" | "incl" | "excl" | "card" | "elig" | "notelig" | "axis_row" | "axis_col" | "incl_mean" | "excl_mean", string>;
};
