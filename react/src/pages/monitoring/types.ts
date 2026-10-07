// output$mon_state (R/mod_monitoring.R): the datasets, the earlier rounds, the report's items.
export type Item = {
  id: string; title: string; half: boolean; source: string; dataset: string; display: "chart" | "table"; comment: string; caption: string;
};
export type MonState = {
  datasets: { name: string; rows: number }[]; rounds: string | null; redraw: number; items: Item[];
};
