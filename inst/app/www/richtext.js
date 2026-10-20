// Formatted text editor for the report texts (see R/utils_richtext.R).
// A contenteditable box under a toolbar; document.execCommand does the
// formatting (still the only built-in way, supported by every browser).
// Editors with an id are Shiny inputs returning HTML; editors drawn in a
// list (report items) send {id, text} to the input named in data-send.
(function () {
  "use strict";

  var KEEP = { P: 1, DIV: 1, BR: 1, B: 1, STRONG: 1, I: 1, EM: 1, U: 1, S: 1, STRIKE: 1, DEL: 1, SUB: 1, SUP: 1,
               H3: 1, H4: 1, BLOCKQUOTE: 1, UL: 1, OL: 1, LI: 1, SPAN: 1, FONT: 1, A: 1 };
  var DROP = { SCRIPT: 1, STYLE: 1, IFRAME: 1, OBJECT: 1, EMBED: 1, TEMPLATE: 1, NOSCRIPT: 1, SVG: 1, MATH: 1,
               TEXTAREA: 1, SELECT: 1, META: 1, LINK: 1, TITLE: 1, HEAD: 1 };
  var STYLES = ["color", "background-color", "text-align", "font-size", "font-weight", "font-style", "text-decoration"];

  // Pasted content from Word or a web page: keep the formatting, lose the rest.
  function clean(node) {
    var kids = Array.prototype.slice.call(node.childNodes);
    kids.forEach(function (c) {
      if (c.nodeType === 3) return;
      if (c.nodeType !== 1) { c.remove(); return; }
      var tag = c.tagName.toUpperCase();
      if (DROP[tag]) { c.remove(); return; }
      clean(c);
      if (!KEEP[tag]) {                       // unwrap: keep the text
        while (c.firstChild) node.insertBefore(c.firstChild, c);
        c.remove();
        return;
      }
      var keepStyle = STYLES.map(function (p) {
        var v = c.style ? c.style.getPropertyValue(p) : "";
        return v && !/url|expression|javascript/i.test(v) ? p + ": " + v : null;
      }).filter(Boolean).join("; ");
      var href = tag === "A" ? c.getAttribute("href") : null;
      var color = tag === "FONT" ? c.getAttribute("color") : null;
      var size = tag === "FONT" ? c.getAttribute("size") : null;
      var align = c.getAttribute("align");
      Array.prototype.slice.call(c.attributes).forEach(function (a) { c.removeAttribute(a.name); });
      if (keepStyle) c.setAttribute("style", keepStyle);
      if (color) c.setAttribute("color", color);
      if (size) c.setAttribute("size", size);
      if (align) c.setAttribute("align", align);
      if (href && /^(https?:|mailto:)/i.test(href)) c.setAttribute("href", href);
    });
  }

  function html(el) {
    var t = (el.textContent || "").replace(/ /g, " ").trim();
    return t ? el.innerHTML : "";
  }

  // The toolbar's selects and colour pickers take the focus, and with it the
  // selection: remember the last selection inside each editor.
  var saved = new WeakMap();
  document.addEventListener("selectionchange", function () {
    var s = window.getSelection();
    if (!s.rangeCount) return;
    var r = s.getRangeAt(0);
    var ed = r.commonAncestorContainer.nodeType === 1 ? r.commonAncestorContainer : r.commonAncestorContainer.parentElement;
    ed = ed && ed.closest ? ed.closest(".tw-rich") : null;
    if (ed) saved.set(ed, r.cloneRange());
  });

  function run(editor, cmd, arg) {
    editor.focus();
    var r = saved.get(editor);
    if (r) { var s = window.getSelection(); s.removeAllRanges(); s.addRange(r); }
    if (cmd === "createLink") {
      arg = window.prompt("Link address (https://...)", "https://");
      if (!arg || !/^(https?:\/\/|mailto:)/i.test(arg)) return;
    }
    document.execCommand("styleWithCSS", false, cmd === "foreColor" || cmd === "hiliteColor");
    if (cmd === "formatBlock") arg = "<" + arg + ">";
    document.execCommand(cmd, false, arg || null);
    changed(editor);
  }

  function changed(editor) {
    $(editor).trigger("tw-rich-change");
    if (editor.classList.contains("tw-rich-send") && window.Shiny && editor.dataset.send) {
      clearTimeout(editor._twSend);
      editor._twSend = setTimeout(function () {
        Shiny.setInputValue(editor.dataset.send, { id: editor.dataset.item, text: html(editor), n: Math.random() });
      }, 600);
    }
  }

  function editorOf(el) { var f = el.closest(".tw-rt-frame"); return f ? f.querySelector(".tw-rich") : null; }

  // Buttons act without taking the focus from the text.
  $(document).on("mousedown", ".tw-rt-btn", function (e) { e.preventDefault(); });
  $(document).on("click", ".tw-rt-btn", function () {
    var ed = editorOf(this);
    if (ed) run(ed, this.dataset.cmd, this.dataset.arg);
  });
  $(document).on("change", ".tw-rt-select", function () {
    var ed = editorOf(this);
    if (ed) run(ed, this.dataset.cmd, this.value);
    if (this.dataset.cmd === "formatBlock") this.value = "p";
  });
  $(document).on("input change", ".tw-rt-color input", function () {
    var ed = editorOf(this);
    if (ed) run(ed, this.dataset.cmd, this.value);
  });

  $(document).on("input", ".tw-rich", function () { changed(this); });
  $(document).on("paste", ".tw-rich", function () {
    var ed = this;
    setTimeout(function () { clean(ed); changed(ed); }, 0);
  });
  // Ctrl/Cmd + B, I, U are handled by the browser; Tab indents lists.
  $(document).on("keydown", ".tw-rich", function (e) {
    if (e.key === "Tab" && document.queryCommandState("insertUnorderedList") + document.queryCommandState("insertOrderedList")) {
      e.preventDefault();
      document.execCommand(e.shiftKey ? "outdent" : "indent");
      changed(this);
    }
  });

  if (window.Shiny) {
    var binding = new Shiny.InputBinding();
    $.extend(binding, {
      find: function (scope) { return $(scope).find(".tw-rich[id]"); },
      getValue: function (el) { return html(el); },
      setValue: function (el, value) { el.innerHTML = value || ""; },
      receiveMessage: function (el, data) {
        if (data.value !== undefined) { el.innerHTML = data.value || ""; $(el).trigger("tw-rich-change"); }
      },
      subscribe: function (el, callback) { $(el).on("tw-rich-change.twrich", function () { callback(true); }); },
      unsubscribe: function (el) { $(el).off(".twrich"); },
      getRatePolicy: function () { return { policy: "debounce", delay: 400 }; }
    });
    Shiny.inputBindings.register(binding, "decide.richtext");
  }
})();
