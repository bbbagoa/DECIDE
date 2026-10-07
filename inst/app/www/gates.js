// Frozen buttons (R: gate_button()): greyed out until what they need is there, with
// the reason on hover and again as a notice when clicked -- never a button
// that silently does nothing. The state is kept here and re-applied when a
// button is redrawn by renderUI.
(function () {
  "use strict";
  var gates = {};

  function apply(id) {
    var g = gates[id], el = document.getElementById(id);
    if (!g || !el) return;
    if (!g.ok) {
      if (el.dataset.twTitle === undefined) el.dataset.twTitle = el.getAttribute("title") || "";
      el.classList.add("tw-frozen");
      el.setAttribute("aria-disabled", "true");
      el.setAttribute("data-tw-reason", g.reason);
      el.setAttribute("title", g.reason);
    } else if (el.classList.contains("tw-frozen")) {
      el.classList.remove("tw-frozen");
      el.removeAttribute("aria-disabled");
      el.removeAttribute("data-tw-reason");
      if (el.dataset.twTitle) el.setAttribute("title", el.dataset.twTitle); else el.removeAttribute("title");
      delete el.dataset.twTitle;
    }
  }

  // Capture phase: the click never reaches Shiny's button binding or a
  // download link, and the user is told why.
  document.addEventListener("click", function (e) {
    var el = e.target.closest && e.target.closest(".tw-frozen");
    if (!el) return;
    e.preventDefault();
    e.stopImmediatePropagation();
    var msg = el.getAttribute("data-tw-reason") || "Not available yet.";
    if (window.Shiny && Shiny.notifications) Shiny.notifications.show({ html: $("<span>").text(msg).html(), type: "warning", duration: 5000 });
  }, true);

  // React buttons (react/src/lib/inputs.tsx) re-apply their gate after each render
  window.twGates = { apply: apply };

  $(function () {
    Shiny.addCustomMessageHandler("tw-gate", function (m) { gates[m.id] = m; apply(m.id); });
  });
  $(document).on("shiny:value shiny:bound", function () {
    setTimeout(function () { Object.keys(gates).forEach(apply); }, 0);
  });
})();
