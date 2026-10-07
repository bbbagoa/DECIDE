// Insight cards of the Data Quality tabs, from the server's facts
// (dq_insight() in R/utils_dq_health.R). A card may carry an action
// ("Select ..."), sent back as an input the server already reads.
import type { ReactNode } from "react";
import {
  ArrowDownUp, CalendarDays, CircleHelp, Gauge, IdCard, Info, ListChecks, MapPin, Signpost, Target, Timer, Users,
} from "lucide-react";
import { type T } from "./common";

export type Pick = { what: string; value: unknown; label: string };
export type Insight = { icon: string; label: string; value: string | null; sub: string | null; pick?: Pick | null };

const ICONS: Record<string, ReactNode> = {
  people: <Users size={14} />, stopwatch: <Timer size={14} />, "calendar-event": <CalendarDays size={14} />,
  speedometer2: <Gauge size={14} />, "ui-checks": <ListChecks size={14} />, "arrow-down-up": <ArrowDownUp size={14} />,
  bullseye: <Target size={14} />, "person-badge": <IdCard size={14} />, "geo-alt": <MapPin size={14} />,
  "question-octagon": <CircleHelp size={14} />, signpost: <Signpost size={14} />,
};

export function Insights({ items, t, onPick }: { items: Insight[]; t: T; onPick?: (p: Pick) => void }) {
  if (!items.length) return null;
  return (
    <div className="tw-dq-insights">
      {items.map((x) => (
        <div key={x.label} className="tw-dq-insight">
          <div className="tw-dq-insight-label">{ICONS[x.icon] ?? <Info size={14} />} {t(x.label)}</div>
          {x.value != null && <div className="tw-dq-insight-value">{x.value}</div>}
          {x.sub && <div className="tw-dq-insight-sub">{t(x.sub)}</div>}
          {x.pick && onPick && (
            <button type="button" className="btn btn-link p-0 tw-link tw-dq-insight-pick" onClick={() => onPick(x.pick!)}>{t(x.pick.label)}</button>
          )}
        </div>
      ))}
    </div>
  );
}
