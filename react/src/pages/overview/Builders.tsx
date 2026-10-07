// The Overview's table and chart builders (R/mod_overview.R: ov_explore,
// ct_table + ct_info, gb_meta + gb_plot + gb_note). They follow the fields as
// they change: builders are the exception to "settings wait for their button".
// The Axes dialog stays the server's (showModal()).
import { useEffect } from "react";
import { MoveVertical } from "lucide-react";
import { useShinyInput, useShinyInputValue, useShinyOutputValue } from "@/shiny";
import { ActionButton, SelectInput, TextOutput, type Choice } from "@/lib/inputs";
import { DataTable } from "@/lib/table";
import { Chart } from "@/lib/chart";
import { EmptyState } from "@/components/Figures";

const ns = (id: string) => `overview_1-${id}`;
type T = (s: string) => string;
type Explore = { choices: Choice[]; all: string[]; nums: string[] };

function useExplore() {
  const ex = useShinyOutputValue<Explore>(ns("ov_explore"));
  // the pickers start again only when the columns offered change
  return { ex, key: ex ? ex.all.join("|") : "" };
}

export function TableBuilder({ t }: { t: T }) {
  const { ex, key } = useExplore();
  if (!ex) return null;
  if (!ex.all.length) return <EmptyState title={t("No column to tabulate")} />;
  return <TableInner key={key} ex={ex} t={t} />;
}

const STATS = [
  { value: "n", label: "Households" }, { value: "row", label: "Row %" }, { value: "col", label: "Column %" },
  { value: "total", label: "Total %" }, { value: "mean", label: "Mean of a number" }, { value: "sum", label: "Sum of a number" },
];

function TableInner({ ex, t }: { ex: Explore; t: T }) {
  const stat = useShinyInputValue<string>(ns("ct_stat")) ?? "n";
  const info = useShinyOutputValue<{ what: string; n: string; col_label: string; chi: string | null }>(ns("ct_info"));
  const byNumber = stat === "mean" || stat === "sum";
  return (
    <div className="tw-ob">
      <div className="tw-ob-controls">
        <SelectInput id={ns("ct_row")} label={t("Rows")} choices={ex.choices} value={ex.all[0]} clearable={false} />
        <SelectInput id={ns("ct_col")} label={t("Columns")} value={ex.all[1] ?? ""} clearable={false}
                     choices={[{ value: "", label: t("(none: one-way table)") }, ...ex.choices]} />
        <SelectInput id={ns("ct_stat")} label={t("Cells")} value="n" clearable={false} choices={STATS.map((s) => ({ ...s, label: t(s.label) }))} />
        {/* kept mounted (its value is read only for a mean or a sum) */}
        <div style={{ display: byNumber ? undefined : "none" }}>
          <SelectInput id={ns("ct_value")} label={t("Number")} value={ex.nums[0] ?? ""} clearable={false}
                       choices={ex.nums.length ? ex.nums : [{ value: "", label: t("(no numeric column)") }]} />
        </div>
      </div>
      {info && (
        <div className="tw-ob-caption">
          <b>{t(info.what)}</b> · {info.n} {t("households")}
          {info.col_label ? <> · {t("columns")}: <span className="tw-ob-var">{info.col_label}</span></> : null}
        </div>
      )}
      <DataTable id={ns("ct_table")} compact searchable={false} height={360} />
      {info?.chi ? <div className="tw-ob-note">{t(info.chi)}</div> : null}
    </div>
  );
}

export function ChartBuilder({ t }: { t: T }) {
  const { ex, key } = useExplore();
  if (!ex) return null;
  if (!ex.all.length) return <EmptyState title={t("No column to chart")} />;
  return <ChartInner key={key} ex={ex} t={t} />;
}

function ChartInner({ ex, t }: { ex: Explore; t: T }) {
  const meta = useShinyOutputValue<{ types: Choice[]; axes_set: boolean }>(ns("gb_meta"));
  const [type, setType] = useShinyInput<string>(ns("gb_type"), "", { debounceMs: 0 });
  const types = meta?.types ?? [];
  // the chart types follow the variables: keep the one chosen while it fits
  useEffect(() => {
    if (types.length && !types.some((x) => x.value === type)) setType(types[0].value);
  }, [types.map((x) => x.value).join("|")]); // eslint-disable-line
  const none = { value: "", label: t("(none)") };
  return (
    <div className="tw-ob">
      <div className="tw-ob-controls">
        <SelectInput id={ns("gb_x")} label={t("Variable")} choices={ex.choices} value={ex.all[0]} clearable={false} />
        <SelectInput id={ns("gb_y")} label={t("Against")} choices={[none, ...ex.choices]} value="" clearable={false} />
        <SelectInput id={ns("gb_group")} label={t("Grouped by")} choices={[none, ...ex.choices]} value="" clearable={false} />
      </div>
      <div className="tw-ob-bar">
        {types.length > 0 && (
          <div className="btn-group btn-group-sm tw-seg" role="radiogroup" aria-label={t("Chart")}>
            {types.map((x) => (
              <button key={x.value} type="button" role="radio" aria-checked={x.value === type}
                      className={`btn btn-outline-primary${x.value === type ? " active" : ""}`} onClick={() => setType(x.value)}>
                {t(x.label)}
              </button>
            ))}
          </div>
        )}
        <ActionButton id={ns("gb_axes")} label={meta?.axes_set ? t("Axes (set)") : t("Axes")} icon={<MoveVertical size={13} />}
                      variant="outline-secondary" className="ms-auto" title={t("Set the bounds of the axes")} />
      </div>
      <Chart id={ns("gb_plot")} />
      <div className="tw-ob-note"><TextOutput id={ns("gb_note")} /></div>
    </div>
  );
}
