// The toolkit gallery: every src/lib piece against a real Shiny server
// (dev/gallery/app.R), checked by dev/gallery/test.R. Build: npm run gallery.
import "@/app.css";
import { createRoot } from "react-dom/client";
import { useShinyOutputValue } from "@/shiny";
import {
  ActionButton, CheckboxGroupInput, CheckboxInput, DateInput, DownloadButton, NumericInput, RadioInput, SelectInput, SliderInput, TextInput,
} from "@/lib/inputs";
import { DataTable } from "@/lib/table";
import { Chart } from "@/lib/chart";
import { Card, Notice, SideActions, SidebarLayout, Steps, Tabs } from "@/lib/layout";

function Gallery() {
  const state = useShinyOutputValue<Record<string, unknown>>("state");
  return (
    <SidebarLayout sidebar={<>
      <Steps steps={[
        { key: "a", title: "1. Choices", content: <>
          <SelectInput id="sel" label="Single" choices={["a", "b", "c"]} value="a" />
          <SelectInput id="pick" label="Multiple" choices={{ Alpha: "a", Beta: "b", Gamma: "c" }} multiple actions />
          <RadioInput id="rad" label="Radio buttons" choices={["one", "two", "three"]} buttons />
          <CheckboxGroupInput id="cg" label="Group" choices={["x", "y"]} inline />
        </> },
        { key: "b", title: "2. Values", summary: "numbers, text, dates", content: <>
          <NumericInput id="num" label="Number" value={5} min={0} max={100} />
          <TextInput id="txt" label="Text" placeholder="type" />
          <SliderInput id="sld" label="Range" min={0} max={100} value={[10, 90]} />
          <DateInput id="dr" label="Dates" range />
          <CheckboxInput id="chk" label="A switch" asSwitch />
        </> },
      ]} />
      <SideActions>
        <ActionButton id="upd" label="Send updates" variant="primary" />
        <ActionButton id="gated" label="Frozen button" />
        <ActionButton id="selrows" label="Select rows 1-3" />
        <DownloadButton id="dl" label="Download" />
      </SideActions>
    </>}>
      <Notice>Gallery of the React toolkit.</Notice>
      <Tabs id="tabs" tabs={[
        { value: "charts", label: "Charts", content: (
          <div className="tw-grid-2">
            {["c_bar", "c_hbar", "c_line", "c_scatter", "c_box", "c_pie", "c_heat", "c_hist", "c_option"].map((c) => (
              <Card key={c} title={c} full><Chart id={c} height={260} /></Card>
            ))}
          </div>) },
        { value: "tables", label: "Tables", content: <>
          <Card title="Small table"><DataTable id="tbl" /></Card>
          <Card title="Server table"><DataTable id="big" /></Card>
          <Card title="Drawn only when shown"><Chart id="c_lazy" height={160} /></Card>
        </> },
      ]} />
      <pre id="state" className="small">{JSON.stringify(state ?? {}, null, 1)}</pre>
    </SidebarLayout>
  );
}

const root = document.createElement("div");
root.style.height = "100vh";
document.body.appendChild(root);
createRoot(root).render(<Gallery />);
