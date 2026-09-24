// A "Working..." pill whenever the server takes more than a moment, so a long
// step (screening, fitting, a large export) never looks like a frozen app.
// Downloads do not make Shiny busy, so they show it from the click until the
// server says the file is built (download_handler() sends tw-download-done).
(function () {
  "use strict";
  var pill, timer, dlTimer, downloads = 0;

  function el() {
    if (!pill) {
      pill = document.createElement("div");
      pill.className = "tw-busy";
      pill.setAttribute("role", "status");
      pill.setAttribute("aria-live", "polite");
      pill.innerHTML = '<span class="tw-busy-spin"></span><span class="tw-busy-text"></span>';
      document.body.appendChild(pill);
    }
    return pill;
  }
  function show(text) {
    el().querySelector(".tw-busy-text").textContent = text;
    pill.classList.add("on");
  }
  function hide() { if (pill && !downloads) pill.classList.remove("on"); }

  $(document).on("shiny:busy", function () {
    clearTimeout(timer);
    timer = setTimeout(function () { show(downloads ? "Preparing your file…" : "Working…"); }, 700);
  });
  $(document).on("shiny:idle", function () { clearTimeout(timer); hide(); });

  $(document).on("click", "a.shiny-download-link", function () {
    downloads++;
    show("Preparing your file…");
    clearTimeout(dlTimer);
    // Safety net: never leave the pill up if the message is lost.
    dlTimer = setTimeout(function () { downloads = 0; hide(); }, 180000);
  });

  // "Tell me when you have been quiet for a moment": a restored session is
  // drawn over several rounds (data, then the page the user returns to), so
  // the server keeps its loader up until the page has settled.
  var settle = null, settleTimer;
  function arm() { clearTimeout(settleTimer); settleTimer = setTimeout(function () {
    if (!settle) return;
    Shiny.setInputValue(settle, Date.now(), { priority: "event" }); settle = null; }, 500); }
  $(document).on("shiny:idle", function () { if (settle) arm(); });
  $(document).on("shiny:busy", function () { clearTimeout(settleTimer); });

  $(function () {
    Shiny.addCustomMessageHandler("tw-when-settled", function (m) {
      settle = m.id; arm();
      setTimeout(function () { if (settle === m.id) { Shiny.setInputValue(m.id, Date.now(), { priority: "event" }); settle = null; } }, 60000);
    });
    Shiny.addCustomMessageHandler("tw-download-done", function (m) {  // Shiny requires one argument
      downloads = Math.max(0, downloads - 1);
      if (!downloads) { clearTimeout(dlTimer); hide(); }
    });
  });
})();
