// Variable calculator (R/mod_var_calc.R), for any page.
//
//   <VarCalc ns="calc_reg" t={t} />                       the calculator
//   <VarCalcBulk ns="scorecard_1-calc" t={t} />           bulk binarise
//
// Props (both)
//   ns         the module id (buttons `${ns}-open` / `${ns}-open_bulk`)
//   label      button text (default "Variable calculator" / "Binarise variables")
//   variant    button style (default "outline-secondary")
//   block      full width (default false)
//   size       "sm" | "md" (default "sm")
//   t          translator (optional)
//
// Each button opens the module's Shiny dialog (conditions, formula, R code,
// preview, create; bulk binarise with the best split for vulnerability): the
// dialogs stay Shiny's (showModal()). New columns land in the data through
// the module's set_data, and the audit trail, as before.
import { Calculator, WandSparkles } from "lucide-react";
import { ActionButton } from "@/lib/inputs";

type Variant = Parameters<typeof ActionButton>[0]["variant"];
type Props = { ns: string; label?: string; variant?: Variant; block?: boolean; size?: "sm" | "md"; t?: (s: string) => string };

export function VarCalc({ ns, label = "Variable calculator", variant = "outline-secondary", block, size = "sm", t = (s) => s }: Props) {
  return <ActionButton id={`${ns}-open`} label={t(label)} icon={<Calculator size={15} />} variant={variant} size={size}
                       className={block ? "w-100" : undefined} />;
}

export function VarCalcBulk({ ns, label = "Binarise variables", variant = "outline-secondary", block, size = "sm", t = (s) => s }: Props) {
  return <ActionButton id={`${ns}-open_bulk`} label={t(label)} icon={<WandSparkles size={15} />} variant={variant} size={size}
                       className={block ? "w-100" : undefined} />;
}

export default VarCalc;
