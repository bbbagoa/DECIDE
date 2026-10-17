// The report text editor (R/utils_richtext.R, www/richtext.js), drawn here.
// richtext.js listens on the document, so the toolbar, typing and pasting work
// as on the Shiny pages. With `id` the box is a Shiny input returning HTML
// (bound here, so update_rich_text() reaches it); with `send` it reports
// {id: item, text} to that input, as the report items do.
import { useEffect, useRef, type ReactNode } from "react";
import {
  AlignCenter, AlignLeft, AlignRight, Bold, Eraser, Highlighter, Italic, Link, List, ListOrdered, Strikethrough, Type, Underline,
} from "lucide-react";
import { useShinyInitialized } from "@/shiny";

type ShinyBind = { bindAll?: (el: Element) => void; unbindAll?: (el: Element) => void };

const B = ({ cmd, title, children }: { cmd: string; title: string; children: ReactNode }) => (
  <button type="button" className="tw-rt-btn" data-cmd={cmd} title={title} aria-label={title}>{children}</button>
);

export function RichText({ id, send, item, label, placeholder = "", rows = 3, value = "", compact }: {
  id?: string; send?: string; item?: string; label?: ReactNode; placeholder?: string; rows?: number; value?: string; compact?: boolean;
}) {
  const wrap = useRef<HTMLDivElement>(null);
  const box = useRef<HTMLDivElement>(null);
  const ready = useShinyInitialized();
  // the text is set once: the editor owns it afterwards (a redraw would move the cursor)
  useEffect(() => { if (box.current) box.current.innerHTML = value; }, []); // eslint-disable-line
  useEffect(() => {
    const S = (window as unknown as { Shiny?: ShinyBind }).Shiny;
    const el = wrap.current;
    if (!id || !ready || !el || !S?.bindAll) return;
    S.bindAll(el);
    return () => S.unbindAll?.(el);
  }, [id, ready]);
  const s = 14;
  return (
    <div ref={wrap} className={`form-group shiny-input-container tw-rt${compact ? " tw-rt-compact" : ""}`} style={{ width: "100%" }}>
      {label ? <label className="control-label form-label" htmlFor={id}>{label}</label> : null}
      <div className="tw-rt-frame">
        <div className="tw-rt-toolbar" role="toolbar">
          <select className="tw-rt-select" data-cmd="formatBlock" title="Paragraph style" defaultValue="p">
            <option value="p">Paragraph</option><option value="h3">Heading</option>
            <option value="h4">Subheading</option><option value="blockquote">Quote</option>
          </select>
          <select className="tw-rt-select" data-cmd="fontSize" title="Text size" defaultValue="3">
            <option value="2">Small</option><option value="3">Medium</option><option value="5">Large</option><option value="6">Huge</option>
          </select>
          <span className="tw-rt-sep" />
          <B cmd="bold" title="Bold"><Bold size={s} /></B>
          <B cmd="italic" title="Italic"><Italic size={s} /></B>
          <B cmd="underline" title="Underline"><Underline size={s} /></B>
          <B cmd="strikeThrough" title="Strikethrough"><Strikethrough size={s} /></B>
          <span className="tw-rt-sep" />
          <label className="tw-rt-color" title="Text colour"><Type size={s} /><input type="color" data-cmd="foreColor" defaultValue="#007DBC" /></label>
          <label className="tw-rt-color" title="Highlight"><Highlighter size={s} /><input type="color" data-cmd="hiliteColor" defaultValue="#fff3bf" /></label>
          <span className="tw-rt-sep" />
          <B cmd="insertUnorderedList" title="Bulleted list"><List size={s} /></B>
          <B cmd="insertOrderedList" title="Numbered list"><ListOrdered size={s} /></B>
          <B cmd="justifyLeft" title="Align left"><AlignLeft size={s} /></B>
          <B cmd="justifyCenter" title="Centre"><AlignCenter size={s} /></B>
          <B cmd="justifyRight" title="Align right"><AlignRight size={s} /></B>
          <span className="tw-rt-sep" />
          <B cmd="createLink" title="Link"><Link size={s} /></B>
          <B cmd="removeFormat" title="Clear formatting"><Eraser size={s} /></B>
        </div>
        <div ref={box} id={id} className={id ? "tw-rich" : "tw-rich tw-rich-send"} contentEditable suppressContentEditableWarning
             role="textbox" aria-multiline="true" aria-label={typeof label === "string" ? label : placeholder}
             data-placeholder={placeholder} data-send={send} data-item={item}
             style={{ minHeight: `${1.6 * rows + 0.9}rem` }} />
      </div>
    </div>
  );
}
