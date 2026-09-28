// Folded sections say what they hold.
//
// Sidebars and the setup dialog open one section at a time, so opening one
// folds the others. The header of a folded section shows its current choices
// ("Ituri, Nord-Kivu", "2026-03-01 - 2026-03-21", "3 of 4 set"), so folding
// hides no filter or setting. Recomputed on every change and whenever Shiny
// goes idle (the server updates inputs too).
(function () {
  function visible(el) {
    var c = el.closest('[data-display-if]');
    return !c || c.style.display !== 'none';
  }
  function labelOf(el) {
    var l = el.id ? document.querySelector('label[for="' + CSS.escape(el.id) + '"]') : null;
    return l ? l.textContent.trim().replace(/\s*\*\s*$/, '') : '';
  }
  function optText(sel, v) {
    var o = sel.querySelector('option[value="' + CSS.escape(v) + '"]');
    return (o ? o.textContent : v).trim();
  }
  function summarise(item) {
    var body = item.querySelector('.accordion-body');
    if (!body) return '';
    var parts = [], total = 0, set = 0, singles = 0;
    body.querySelectorAll('select').forEach(function (s) {
      if (!visible(s)) return;
      total++;
      if (!s.multiple) singles++;
      var vals = Array.prototype.map.call(s.selectedOptions || [], function (o) { return o.value; })
        .filter(function (v) { return v !== ''; });
      if (!vals.length) return;
      set++;
      if (s.multiple && vals.length > 1) parts.push((labelOf(s) || 'selected') + ': ' + vals.length);
      else parts.push(optText(s, vals[0]));
    });
    body.querySelectorAll('input').forEach(function (i) {
      if (!visible(i) || i.closest('.bootstrap-select, .selectize-control, .dropdown-menu')) return;
      var t = (i.type || '').toLowerCase();
      if (['text', 'number', 'date', 'search'].indexOf(t) < 0 || i.classList.contains('tw-no-sum')) return;
      var v = (i.value || '').trim();
      if (v) parts.push(v.length > 28 ? v.slice(0, 27) + '…' : v);
    });
    if (!parts.length) return '';
    // a group of plain field choices (the setup dialog): how many are set
    if (total > 3 && singles === total) return set + ' of ' + total + ' set';
    var txt = parts.slice(0, 3).join(' · ');
    if (parts.length > 3) txt += ' +' + (parts.length - 3);
    return txt;
  }
  function update(item) {
    if (item.closest('.tw-ov-acc')) return;       // the Overview sections: no summary
    var btn = item.querySelector(':scope > .accordion-header .accordion-button');
    if (!btn) return;
    var txt = summarise(item);
    var span = btn.querySelector('.tw-step-sum');
    if (!txt) { if (span) span.remove(); return; }
    if (!span) { span = document.createElement('span'); span.className = 'tw-step-sum'; btn.appendChild(span); }
    if (span.textContent !== txt) { span.textContent = txt; span.title = txt; }
  }
  var timer = null;
  function updateAll() {
    clearTimeout(timer);
    timer = setTimeout(function () { document.querySelectorAll('.accordion-item').forEach(update); }, 120);
  }
  $(document).on('change shiny:idle shown.bs.collapse hidden.bs.collapse shown.bs.modal', updateAll);
  $(document).on('changed.bs.select', updateAll);
})();

// Show or hide an input with its label (area levels that are not mapped)
Shiny.addCustomMessageHandler('tw-input-visible', function(m) {
  var go = function() {
    var el = document.getElementById(m.id); if (!el) return false;
    var c = el.closest('.shiny-input-container') || el.closest('.form-group') || el;
    c.style.display = m.show ? '' : 'none'; return true;
  };
  if (!go()) setTimeout(go, 300);
});
