// Variables in the interface: names and labels.
//
// The server keeps one dictionary per session (register_labels(): every
// imported column, and its label when the data or the form has one) and
// sends it here. Then:
// - dropdowns listing variables show the name in bold, with the label below
//   it, small, in blue italics (the value sent back stays the column name, so
//   nothing on the server changes); search finds a variable by name or label;
// - tables: a variable named in a table's first column gets its label under
//   it; anywhere else in a table (headers, other columns) the label shows on
//   hover.
// Options or cells that already have their own text are left alone.
(function () {
  "use strict";
  var labels = {}, known = {};

  function has(o, k) { return Object.prototype.hasOwnProperty.call(o, k); }
  function labelFor(v) { return has(labels, v) ? labels[v] : null; }
  function isVar(v) { return has(known, v) || has(labels, v); }
  function esc(t) { return String(t).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function twoLines(name, label) {
    // bold only above a label: a bold name on its own reads as "selected"
    return '<span class="tw-opt"><span class="tw-opt-name' + (label ? ' tw-strong' : '') + '">' + esc(name) + '</span>' +
           (label ? '<span class="tw-opt-label">' + esc(label) + '</span>' : '') + '</span>';
  }

  // selectize: its own option store and renderers
  function decorateSelectize(s) {
    if (!s.__twRender) {
      var opt = s.settings.render.option, item = s.settings.render.item;
      s.settings.render.option = function (data, escape) {
        return data.tw_var ? '<div class="option tw-opt-row">' + twoLines(data.value, data.tw_label) + '</div>'
                           : opt.apply(this, arguments);
      };
      s.settings.render.item = function (data, escape) {
        return data.tw_var ? '<div class="item"' + (data.tw_label ? ' title="' + esc(data.tw_label) + '"' : '') + '>' + esc(data.value) + '</div>'
                           : item.apply(this, arguments);
      };
      s.__twRender = true;
    }
    var changed = false;
    Object.keys(s.options).forEach(function (k) {
      var o = s.options[k];
      if (!isVar(o.value) || o.tw_var) return;
      if (o.label !== o.value && o.text !== o.value) return;   // has its own text
      var l = labelFor(o.value) || "";
      s.updateOption(o.value, $.extend({}, o, { tw_var: true, tw_label: l,
                                               label: l ? o.value + " " + l : o.value, text: l ? o.value + " " + l : o.value }));
      changed = true;
    });
    if (changed) {
      if (s.clearCache) s.clearCache();
      s.refreshOptions(false);
      var v = s.getValue();
      s.clear(true); s.setValue(v, true);
    }
  }

  function decorateSelect(el) {
    if (el.selectize) { decorateSelectize(el.selectize); return; }
    var $el = $(el), any = false;
    // bootstrap-select wraps its select in .bootstrap-select (the select itself
    // does not keep the selectpicker class)
    var picker = !!$.fn.selectpicker && ($el.closest(".bootstrap-select").length > 0 || !!$el.data("selectpicker"));
    $el.find("option").each(function () {
      var l = labelFor(this.value);
      if (!l || this.getAttribute("data-tw")) return;
      if (picker) {
        if (this.textContent !== this.value) return;
        this.setAttribute("data-tokens", l);     // searchable by the label
      } else if (this.textContent === this.value) {
        this.textContent = this.value + " — " + l;   // a plain select cannot style its options
      } else return;
      this.setAttribute("data-tw", "1"); any = true;
    });
    if (any && picker) { try { $el.selectpicker("refresh"); } catch (e) {} }
    if (picker) decorateMenu(el);
  }

  // The drawn menu of a bootstrap-select. It is drawn again when opened,
  // filtered or scrolled, so this runs each time.
  function decorateMenu(el) {
    var bs = $(el).data("selectpicker");
    if (!bs || !bs.$menuInner) return;
    var opts = {};
    $(el).find("option").each(function () { opts[this.value] = this.textContent; });
    bs.$menuInner.find("span.text").each(function () {
      if (this.querySelector(".tw-opt")) return;
      var t = (this.textContent || "").trim();
      if (!isVar(t) || opts[t] !== t) return;
      this.innerHTML = twoLines(t, labelFor(t));
    });
  }
  $(document).on("shown.bs.select rendered.bs.select loaded.bs.select changed.bs.select", "select", function () {
    var el = this; setTimeout(function () { decorateMenu(el); }, 0);
  });
  document.addEventListener("scroll", function (e) {
    var inner = e.target && e.target.closest ? e.target.closest(".bootstrap-select .inner, .bs-container .inner") : null;
    if (!inner) return;
    var sel = $(inner).closest(".bootstrap-select").find("select")[0];
    if (sel) decorateMenu(sel);
  }, true);
  $(document).on("keyup", ".bs-searchbox input", function () {
    var sel = $(this).closest(".bootstrap-select").find("select")[0];
    if (sel) setTimeout(function () { decorateMenu(sel); }, 30);
  });

  // Tables: a variable in the first column (or a cell marked tw-var) gets
  // its label underneath; in a header or another column the label shows on
  // hover.
  function decorateCells(root) {
    $(root).find("table").each(function () {
      $(this).find("th, td").each(function () {
        if (this.getAttribute("data-tw")) return;
        var target = this, t = (this.textContent || "").trim();
        // a cell holding only <strong>name</strong> (and maybe an icon)
        var strong = this.querySelector("strong, b");
        if (!labelFor(t) && strong) { t = (strong.textContent || "").trim(); target = strong; if (!labelFor(t)) return; }
        var l = labelFor(t);
        if (!l) return;
        this.setAttribute("data-tw", "1");
        if (this.tagName === "TD" && (this.cellIndex === 0 || this.classList.contains("tw-var"))) {
          var span = document.createElement("span");
          span.className = "tw-cell-label"; span.textContent = l;
          (target === this ? this : target.parentNode).appendChild(span);
        } else {
          this.setAttribute("title", l);
        }
      });
    });
  }

  function decorate(root) {
    if (!Object.keys(known).length && !Object.keys(labels).length) return;
    root = root || document;
    $(root).find("select").addBack("select").each(function () { decorateSelect(this); });
    decorateCells(root);
  }

  var timer;
  function soon(root) { clearTimeout(timer); timer = setTimeout(function () { decorate(root); }, 60); }

  $(document).on("shiny:bound shiny:updateinput shiny:value", function (e) {
    // after Shiny has applied the update
    setTimeout(function () { decorate(e.target && e.target.parentNode ? e.target.parentNode : document); }, 30);
  });
  $(document).on("init.dt draw.dt", function (e) {
    var w = e.target.closest ? e.target.closest(".dataTables_wrapper") || e.target : e.target;
    setTimeout(function () { decorateCells(w); }, 0);
  });

  $(function () {
    if (!window.Shiny) return;
    // Shiny requires handlers that take one argument, or registration fails.
    Shiny.addCustomMessageHandler("tw-labels", function (m) {
      m = m || {};
      labels = m.labels || {};
      known = {};
      (m.cols || []).forEach(function (c) { known[c] = true; });
      soon(document);
    });
  });
})();
