// Whole-interface translation (English -> French).
//
// shiny.i18n only translates strings tagged when the UI is built; most of this
// app's text is rendered later by the server (renderUI, notifications, modals,
// tables, chart labels, tooltips). This translator works on what is actually
// on the page: every text node and a few attributes are looked up in the same
// dictionary (www/translations.json) and replaced, and a MutationObserver
// translates new content as it arrives. Choosing English restores the
// originals.
//
// Lookup order for a piece of text:
//   1. exact match (whitespace-normalised);
//   2. pattern match for strings built with sprintf ("%d households", ...):
//      placeholders become capture groups and are carried into the French;
//   3. for longer text assembled from several phrases, each known phrase of
//      20+ characters found inside it is replaced.
// User data is never translated: code, data-table bodies and data chips are
// skipped.
(function () {
  "use strict";

  var SKIP = "script,style,code,pre,textarea,.notranslate,[translate='no'],.dataTable tbody," +
             ".dataTables_wrapper tbody,.leaflet-container,.wfp-calc-chip,.shiny-input-container input";
  var ATTRS = ["placeholder", "title", "aria-label", "alt"];
  var SPEC = /%[-+ 0#]*\d*(?:\.\d+)?[sdfgixX]|%%/g;

  var lang = "en";
  var exact = Object.create(null);
  var patterns = [];
  var phrases = [];
  var ready = false;
  var touched = new Set();          // nodes/elements we changed, to restore
  var orig = new WeakMap();         // text node -> original text
  var mine = new WeakMap();         // text node -> text we last set
  var attrOrig = new WeakMap();     // element -> {attr: original}

  function norm(s) { return s.replace(/\s+/g, " ").trim(); }
  function escapeRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }

  function compile(en, fr) {
    // Page text is compared whitespace-normalised, so the template is too.
    var t = norm(en);
    var parts = t.split(SPEC), specs = t.match(SPEC) || [];
    var letters = parts.join("").replace(/[^A-Za-z]/g, "");
    if (letters.length < 2) return;             // "%s: %s" would match anything
    var re = "";
    for (var i = 0; i < parts.length; i++) {
      re += escapeRe(parts[i]).replace(/\s+/g, "\\s+");
      if (i < specs.length) re += specs[i] === "%%" ? "%" : "(.+?)";
    }
    var frSpecs = fr.match(SPEC) || [];
    var nIn = specs.filter(function (s) { return s !== "%%"; }).length;
    var nOut = frSpecs.filter(function (s) { return s !== "%%"; }).length;
    if (nIn !== nOut) return;                   // placeholder mismatch: skip
    patterns.push({ re: new RegExp("^" + re + "$"), fr: norm(fr) });
  }

  function load(dict) {
    (dict.translation || []).forEach(function (e) {
      if (!e.en || !e.fr || e.en === e.fr) return;
      if (SPEC.test(e.en)) { SPEC.lastIndex = 0; compile(e.en, e.fr); return; }
      SPEC.lastIndex = 0;
      exact[norm(e.en)] = e.fr;
      if (e.en.length >= 20) phrases.push([e.en, e.fr]);
    });
    phrases.sort(function (a, b) { return b[0].length - a[0].length; });
    ready = true;
  }

  function fillPattern(p, m) {
    var i = 1;
    return p.fr.replace(SPEC, function (s) {
      if (s === "%%") return "%";
      var v = m[i++]; var t = exact[norm(v)];
      return t !== undefined ? t : v;
    });
  }

  var lastMode = null;
  function translate(text) {
    lastMode = null;
    var n = norm(text);
    if (!n || !/[A-Za-z]{2}/.test(n)) return null;
    var hit = exact[n];
    if (hit !== undefined) { lastMode = "exact"; return hit; }
    for (var i = 0; i < patterns.length; i++) {
      var m = patterns[i].re.exec(n);
      if (m) { lastMode = "pattern"; return fillPattern(patterns[i], m); }
    }
    if (n.length >= 20) {
      var out = n, changed = false;
      for (var j = 0; j < phrases.length; j++) {
        if (out.indexOf(phrases[j][0]) !== -1) { out = out.split(phrases[j][0]).join(phrases[j][1]); changed = true; }
      }
      if (changed) { lastMode = "phrase"; return out; }
    }
    return null;
  }

  // .tw-i18n marks the app's own labels inside skipped areas (the Details
  // button in a data table): translated, while the data around stays as is.
  function skipped(el) {
    if (!el) return true;
    if (el.closest && el.closest(".tw-i18n")) return false;
    return !!(el.closest && el.closest(SKIP));
  }

  function doText(node) {
    var parent = node.parentElement;
    if (skipped(parent)) return;
    var cur = node.nodeValue;
    // Content changed by Shiny since we last touched it: that is the new original.
    if (orig.has(node) && cur !== mine.get(node)) { orig.delete(node); mine.delete(node); }
    if (lang === "fr") {
      var src = orig.has(node) ? orig.get(node) : cur;
      var t = translate(src);
      if (t === null) return;
      var lead = src.match(/^\s*/)[0], trail = src.match(/\s*$/)[0];
      var val = lead + t + trail;
      if (val === cur) return;
      if (!orig.has(node)) orig.set(node, src);
      mine.set(node, val); node.nodeValue = val; touched.add(node);
    } else if (orig.has(node)) {
      node.nodeValue = orig.get(node); orig.delete(node); mine.delete(node); touched.delete(node);
    }
  }

  function doAttrs(el) {
    if (skipped(el)) return;
    var saved = attrOrig.get(el) || {};
    ATTRS.forEach(function (a) {
      if (!el.hasAttribute || !el.hasAttribute(a)) return;
      var cur = el.getAttribute(a);
      if (lang === "fr") {
        var src = saved[a] !== undefined && saved["_" + a] === cur ? saved[a] : cur;
        var t = translate(src);
        if (t === null || t === cur) return;
        saved[a] = src; saved["_" + a] = t; el.setAttribute(a, t);
        attrOrig.set(el, saved); touched.add(el);
      } else if (saved[a] !== undefined && saved["_" + a] === cur) {
        el.setAttribute(a, saved[a]); delete saved[a]; delete saved["_" + a];
      }
    });
  }

  function walk(root) {
    if (!ready || !root) return;
    if (root.nodeType === 3) { doText(root); return; }
    if (root.nodeType !== 1) return;
    if (skipped(root)) {
      // A skipped area (a table body) can still hold marked labels.
      if (root.querySelectorAll) root.querySelectorAll(".tw-i18n").forEach(walk);
      return;
    }
    doAttrs(root);
    var tw = document.createTreeWalker(root, NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT, null);
    var n;
    while ((n = tw.nextNode())) {
      if (n.nodeType === 3) doText(n); else doAttrs(n);
    }
  }

  var queue = [], scheduled = false;
  function flush() {
    scheduled = false;
    var q = queue; queue = [];
    for (var i = 0; i < q.length; i++) if (q[i].isConnected) walk(q[i]);
  }
  var observer = new MutationObserver(function (muts) {
    if (lang !== "fr" || !ready) return;
    muts.forEach(function (m) {
      if (m.type === "characterData") queue.push(m.target);
      else if (m.type === "attributes") queue.push(m.target);
      else m.addedNodes.forEach(function (n) { queue.push(n); });
    });
    if (!scheduled) { scheduled = true; requestAnimationFrame(flush); }
  });

  function setLang(l) {
    lang = l === "fr" ? "fr" : "en";
    try { localStorage.setItem("tma-lang", lang); } catch (e) {}
    document.documentElement.setAttribute("lang", lang);
    if (lang === "fr") {
      walk(document.body);
    } else {
      touched.forEach(function (n) {
        if (n.nodeType === 3) { if (orig.has(n) && n.nodeValue === mine.get(n)) n.nodeValue = orig.get(n); orig.delete(n); mine.delete(n); }
        else doAttrs(n);
      });
      touched.clear();
    }
  }

  function start() {
    observer.observe(document.body, { childList: true, subtree: true, characterData: true,
                                      attributes: true, attributeFilter: ATTRS });
    $(document).on("change", "#lang_selector", function () { setLang(this.value); });
    var saved = null;
    try { saved = localStorage.getItem("tma-lang"); } catch (e) {}
    var sel = document.getElementById("lang_selector");
    if (saved === "fr" && sel && sel.value !== "fr") {
      // Also tells the server (shiny.i18n) through the normal input.
      $(document).one("shiny:connected", function () { sel.value = "fr"; $(sel).trigger("change"); });
    }
    if (saved === "fr") setLang("fr");
  }

  fetch("www/translations.json")
    .then(function (r) { return r.json(); })
    .then(function (d) {
      load(d);
      if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start);
      else start();
    })
    .catch(function () { /* no dictionary: the interface stays in English */ });

  window.tmaTranslate = {
    setLang: setLang,
    translate: function (s) { return translate(s); },
    // "exact" | "pattern" | "phrase" | null -- used to audit coverage
    mode: function (s) { translate(s); return lastMode; }
  };
})();

// shiny.i18n's language input hands jQuery's change event to Shiny's input
// callback, which Shiny 1.14 rejects ("Unexpected input value mode"), so every
// language switch logged an error. Its message now translates the tagged
// labels directly (getValue does the work) without the rejected event; the
// server keeps the language through update_lang() as before.
$(function () {
  var entry = Shiny.inputBindings.getBindings().map(function (x) { return x.binding; })
    .find(function (b) { return b && b.find && String(b.find).indexOf("i18n-state") >= 0; });
  if (!entry) return;
  entry.receiveMessage = function (el, data) {
    $(el).data("lang", data.lang);
    try { entry.getValue(el); } catch (e) {}
  };
});
