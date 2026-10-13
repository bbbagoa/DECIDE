// The parts of ECharts the app draws (not the whole library): add a chart type
// or component here when an option uses a new one (it will not draw otherwise).
import * as echarts from "echarts/core";
import { BarChart, BoxplotChart, GraphChart, HeatmapChart, LineChart, LinesChart, PieChart, ScatterChart, SunburstChart, TreemapChart } from "echarts/charts";
import {
  GridComponent, LegendComponent, MarkAreaComponent, MarkLineComponent, MarkPointComponent, TitleComponent,
  TooltipComponent, VisualMapComponent, DataZoomComponent, GraphicComponent,
} from "echarts/components";
import { LabelLayout } from "echarts/features";
import { CanvasRenderer } from "echarts/renderers";

echarts.use([
  BarChart, BoxplotChart, GraphChart, HeatmapChart, LineChart, LinesChart, PieChart, ScatterChart, SunburstChart, TreemapChart,
  GridComponent, LegendComponent, MarkAreaComponent, MarkLineComponent, MarkPointComponent, TitleComponent,
  TooltipComponent, VisualMapComponent, DataZoomComponent, GraphicComponent, LabelLayout, CanvasRenderer,
]);

export default echarts;
