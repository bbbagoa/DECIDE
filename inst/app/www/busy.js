// Loading feedback: one waiter for the whole app.
//
// The full-screen waiter (waiter_show() + waiter_content()) and the busy card
// shown here are the same card: ring, one line saying WHAT is running, and a
// console of the steps under way, like an installer log. Heavy operations
// write their steps from R (waiter_log(), tw_step() -> "tw-wait-log"); the
// panels being redrawn add their own lines ("render Distribution and
// limits", ticked with the time it took). When a waiter closes and the server
// is still drawing, the busy card takes over with the same lines, so the
// two never blink in turn. Downloads do not make Shiny busy, so they show it
// from the click until the server says the file is built
// (download_handler() sends tw-download-done).
(function () {
  "use strict";
  var box, timer, dlTimer, downloads = 0, busy = false;
  var action = null, actionAt = 0;      // the last button pressed, and when
  var updating = [];                     // titles of the panels being redrawn
  var lines = [];                        // the console: {id, text, state, t0}
  var pending = {};                      // output title -> outputs still drawing
  var MAX_LINES = 7;

  function el() {
    if (!box) {
      box = document.createElement("div");
      box.className = "tw-busy";
      box.innerHTML = '<div class="wfp-wait" role="status" aria-live="polite"><div class="wfp-wait-row">' +
                      '<span class="wfp-wait-ring"></span><span class="wfp-wait-msg"></span></div>' +
                      '<div class="wfp-wait-log" style="display:none"></div></div>';
      document.body.appendChild(box);
    }
    return box;
  }
  function waiterCard() {
    var w = document.querySelectorAll(".waiter-overlay");
    for (var i = w.length - 1; i >= 0; i--) {
      if (w[i].offsetParent !== null || getComputedStyle(w[i]).display !== "none") {
        var c = w[i].querySelector(".wfp-wait");
        return c || w[i];
      }
    }
    return null;
  }
  function waiterOn() { return waiterCard() !== null; }

  // The console, drawn into whichever card is on screen.
  function renderLog() {
    var card = waiterCard() || (box && box.classList.contains("on") ? box.querySelector(".wfp-wait") : null);
    if (!card || !card.classList.contains("wfp-wait")) return;
    var log = card.querySelector(".wfp-wait-log");
    if (!log) { log = document.createElement("div"); log.className = "wfp-wait-log"; card.appendChild(log); }
    if (!lines.length) { log.style.display = "none"; return; }
    log.style.display = "";
    log.innerHTML = "";
    lines.slice(-MAX_LINES).forEach(function (l) {
      var d = document.createElement("div");
      d.className = "tw-line " + l.state;
      d.textContent = l.text;
      log.appendChild(d);
    });
  }
  function logLine(id, text, state) {
    var l = null;
    if (id) for (var i = 0; i < lines.length; i++) if (lines[i].id === id) { l = lines[i]; break; }
    if (!l) { l = { id: id, t0: Date.now() }; lines.push(l); if (lines.length > 60) lines.shift(); }
    l.text = text; l.state = state || "info";
    renderLog();
    return l;
  }
  function secs(l) { return " (" + ((Date.now() - l.t0) / 1000).toFixed(1) + " s)"; }

  function show(text) {
    if (waiterOn()) { if (box) box.classList.remove("on"); renderLog(); return; }
    // Straight after a full-screen waiter: no fade, the card simply stays.
    el().classList.toggle("instant", Date.now() - lastWaiter < 500);
    el().querySelector(".wfp-wait-msg").textContent = text;
    box.classList.add("on");
    renderLog();
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
    if (t) { action = t; actionAt = Date.now(); logLine("cmd", t, "cmd"); }
  });
  $(document).on("shiny:recalculating", function (e) {
    var t = titleOf(e.target);
    if (t && updating.indexOf(t) < 0) updating.push(t);
    var name = t || (e.target.id || "").replace(/^.*-/, "").replace(/_/g, " ");
    if (name) {
      pending[name] = (pending[name] || 0) + 1;
      logLine("out:" + name, "render " + name, "run");
    }
    if (box && box.classList.contains("on")) show(message());
  });
  function outputDone(e) {
    var t = titleOf(e.target) || (e.target.id || "").replace(/^.*-/, "").replace(/_/g, " ");
    if (!t || !pending[t]) return;
    if (--pending[t] > 0) return;
    delete pending[t];
    for (var i = 0; i < lines.length; i++) if (lines[i].id === "out:" + t) {
      logLine("out:" + t, "render " + t + secs(lines[i]), e.type === "shiny:error" ? "err" : "ok");
      break;
    }
  }
  $(document).on("shiny:value shiny:error", outputDone);

  // While the server works: the busy card after a moment, and it takes over
  // from a full-screen waiter the moment that one closes.
  // Tasks often run back to back (an import, then its summary, then the
  // panels it redraws). The card stays up through the short gaps between them
  // and closes only once the server has been quiet for a moment, so it does
  // not blink on and off; when a full-screen waiter closes mid-way, the card
  // takes over at once, with the same lines.
  var idleTimer, lastWaiter = 0;
  function tick() {
    if (!busy) return;
    if (waiterOn()) lastWaiter = Date.now();
    show(message());
    timer = setTimeout(tick, 100);
  }
  $(document).on("shiny:busy", function () {
    busy = true;
    clearTimeout(idleTimer);
    clearTimeout(timer);
    var on = (box && box.classList.contains("on")) || waiterOn();
    timer = setTimeout(tick, on ? 0 : 700);
  });
  $(document).on("shiny:idle", function () {
    busy = false;
    clearTimeout(timer);
    clearTimeout(idleTimer);
    idleTimer = setTimeout(function () {
      if (busy) return;
      updating = [];
      if (!downloads) action = null;
      hide();
      // A waiter can stay up between rounds (a session restore): keep its log.
      if (!waiterOn() && !downloads) { lines = []; pending = {}; }
    }, 600);
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
    // Progress of a long operation, written into the waiter on screen.
    Shiny.addCustomMessageHandler("tw-wait-progress", function (m) {
      var waits = document.querySelectorAll(".waiter-overlay .wfp-wait");
      if (!waits.length) return;
      var w = waits[waits.length - 1];
      function set(sel, text) {
        var n = w.querySelector(sel); if (!n || text === null || text === undefined) return;
        if (text === "" || (typeof text === "number" && isNaN(text))) { n.style.display = "none"; return; }
        n.textContent = text; n.style.display = "";
      }
      set(".wfp-wait-msg", m.message);
      set(".wfp-wait-sub", m.subtitle);
      if (m.percent !== null && m.percent !== undefined) {
        var p = Math.max(0, Math.min(100, Math.round(m.percent)));
        set(".wfp-wait-pct", p + "%");
        var bar = w.querySelector(".wfp-wait-bar");
        if (bar) { bar.style.display = ""; bar.firstElementChild.style.width = p + "%"; }
      }
    });
    // A step of a heavy operation, from R (waiter_log(), tw_step()).
    Shiny.addCustomMessageHandler("tw-wait-log", function (m) {
      logLine(m.id || null, m.text || "", m.state || "info");
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

  // A lock held for the life of the page: Chromium browsers (Edge, Chrome)
  // do not freeze or put to sleep a background tab holding one, which would
  // close the connection to R.
  if (navigator.locks && navigator.locks.request) {
    try { navigator.locks.request("targetwise-keep-awake", function () { return new Promise(function () {}); }); } catch (e) {}
  }

  // Connection lost: say what happened and how to get the work back,
  // instead of a page that no longer answers. Locally a lost connection
  // ends the R session; the last autosave is restored after a reload.
  var savedAt = null;
  if (window.Shiny) Shiny.addCustomMessageHandler("tw-saved-at", function (m) { savedAt = m && m.at; });
  $(document).on("shiny:disconnected", function () {
    if (document.getElementById("tw-lost")) return;
    var d = document.createElement("div");
    d.id = "tw-lost";
    d.innerHTML =
      '<div class="tw-lost-card">' +
      '<div class="tw-lost-title">The connection to TargetWise was lost</div>' +
      '<p>This happens when the computer goes to sleep, the network drops, or the browser puts an inactive tab to sleep.' +
      ' The page no longer reaches R, so nothing on it will respond.</p>' +
      '<p>' + (savedAt ? 'Your work was saved automatically at <strong>' + savedAt + '</strong>.' :
                         'Changed work is saved automatically every 30 seconds (below 200 MB of data).') +
      ' Reload the page and choose <strong>Restore</strong> to continue where you were.</p>' +
      '<button type="button" class="btn btn-primary" onclick="window.location.reload()">Reload</button>' +
      '</div>';
    document.body.appendChild(d);
  });

  $(document).on("shiny:connected", function () {
    if (/[?&]fresh=1/.test(window.location.search))
      setTimeout(function () { history.replaceState(null, "", window.location.pathname); }, 1500);
  });
})();
