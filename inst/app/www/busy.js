// Loading feedback for work that does not block the page.
//
// Whenever the server takes more than a moment, a small card appears at the
// bottom of the page -- the same card as the app's full-screen waiter
// (waiter_content(): ring + one line) -- saying WHAT is running: the button
// the user pressed ("Fit model..."), or the panels being redrawn ("Updating:
// Distribution and limits..."). Downloads do not make Shiny busy, so they
// show it from the click until the server says the file is built
// (download_handler() sends tw-download-done).
(function () {
  "use strict";
  var box, timer, dlTimer, downloads = 0;
  var action = null, actionAt = 0;      // the last button pressed, and when
  var updating = [];                     // titles of the panels being redrawn

  function el() {
    if (!box) {
      box = document.createElement("div");
      box.className = "tw-busy";
      box.innerHTML = '<div class="wfp-wait" role="status" aria-live="polite"><div class="wfp-wait-row">' +
                      '<span class="wfp-wait-ring"></span><span class="wfp-wait-msg"></span></div></div>';
      document.body.appendChild(box);
    }
    return box;
  }
  function show(text) {
    el().querySelector(".wfp-wait-msg").textContent = text;
    box.classList.add("on");
  }
  function hide() { if (box && !downloads) box.classList.remove("on"); }

  function clean(t) { return (t || "").replace(/\s+/g, " ").trim().slice(0, 80); }
  // What a redrawn output is: its card's header, else its tab, else nothing.
  function titleOf(node) {
    var card = node.closest && node.closest(".card");
    var head = card && card.querySelector(".card-header");
    if (head && clean(head.textContent)) return clean(head.textContent);
    var pane = node.closest && node.closest(".tab-pane");
    if (pane && pane.id) {
      var tab = document.querySelector('[data-bs-target="#' + pane.id + '"], a[href="#' + pane.id + '"]');
      if (tab && clean(tab.textContent)) return clean(tab.textContent);
    }
    return null;
  }
  function message() {
    if (downloads) return action ? "Preparing: " + action + "…" : "Preparing your file…";
    if (action && Date.now() - actionAt < 15000) return action + "…";
    if (updating.length) return "Updating: " + updating.slice(0, 2).join(", ") + (updating.length > 2 ? " and more" : "") + "…";
    return "Working…";
  }

  $(document).on("click", "button.action-button, a.action-button", function () {
    var t = clean(this.textContent) || clean(this.getAttribute("title"));
    if (t) { action = t; actionAt = Date.now(); }
  });
  $(document).on("shiny:recalculating", function (e) {
    var t = titleOf(e.target);
    if (t && updating.indexOf(t) < 0) updating.push(t);
    if (box && box.classList.contains("on")) show(message());
  });
  $(document).on("shiny:busy", function () {
    clearTimeout(timer);
    timer = setTimeout(function () { show(message()); }, 700);
  });
  $(document).on("shiny:idle", function () {
    clearTimeout(timer);
    updating = [];
    if (!downloads) action = null;
    hide();
  });

  $(document).on("click", "a.shiny-download-link", function () {
    downloads++;
    action = clean(this.textContent) || null;
    show(message());
    clearTimeout(dlTimer);
    // Safety net: never leave it up if the message is lost.
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
    // Shiny requires handlers that take one argument, or registration fails.
    Shiny.addCustomMessageHandler("tw-when-settled", function (m) {
      settle = m.id; arm();
      setTimeout(function () { if (settle === m.id) { Shiny.setInputValue(m.id, Date.now(), { priority: "event" }); settle = null; } }, 60000);
    });
    Shiny.addCustomMessageHandler("tw-download-done", function (m) {
      downloads = Math.max(0, downloads - 1);
      if (!downloads) { clearTimeout(dlTimer); action = null; hide(); }
    });
    // Start a fresh session: reload without the restore prompt. The flag
    // leaves the address once the server has read it, so a later refresh
    // offers the saved sessions again.
    Shiny.addCustomMessageHandler("tw-fresh", function (m) {
      window.location.href = window.location.pathname + "?fresh=1";
    });
  });
  // A page cannot change the browser zoom, but a high zoom mostly narrows the
  // page (125% on a laptop leaves ~1,230 px), where some layouts crowd. Below
  // 1,400 px the app sets its base text size to 90%: text, padding and
  // spacing (all in rem) shrink as with a 90% zoom. CSS zoom would do it too,
  // but it throws off the menus and pickers that position themselves.
  function fitZoom() {
    document.documentElement.style.fontSize = window.innerWidth < 1400 ? "90%" : "";
  }
  fitZoom();
  $(window).on("resize", function () { clearTimeout(window._twFit); window._twFit = setTimeout(fitZoom, 150); });

  // Keep-alive: a small message every 30 s while the page is open, so proxies
  // and hosting servers do not close an idle session. No observer reads it.
  setInterval(function () {
    if (window.Shiny && Shiny.shinyapp && Shiny.shinyapp.isConnected())
      Shiny.setInputValue("tw_keepalive", Date.now());
  }, 30000);

  $(document).on("shiny:connected", function () {
    if (/[?&]fresh=1/.test(window.location.search))
      setTimeout(function () { history.replaceState(null, "", window.location.pathname); }, 1500);
  });
})();
