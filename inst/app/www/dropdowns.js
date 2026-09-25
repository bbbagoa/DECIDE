// Selectize dropdowns are rendered inside the input's own container, so a
// select sitting in a scrolling sidebar or a card gets its menu clipped at the
// container edge. selectize supports re-parenting the menu to the body, but
// Shiny does not expose that option on selectInput(), and setting it per input
// would mean touching every call site.
//
// This re-parents every selectize instance as it is bound, and keeps the menu
// positioned over the input while it is open.
(function () {
  "use strict";

  function reparent(el) {
    var st = el && el.selectize;
    // selectize lists at most 1,000 options by default, so on a wide form
    // (MODA exports often pass 1,000 columns) every variable after that was
    // simply absent from the list. Read at search time, so this is enough.
    if (st) st.settings.maxOptions = 100000;
    if (!st || st._wfpReparented) return;
    st._wfpReparented = true;

    var $dropdown = st.$dropdown;
    if (!$dropdown || !$dropdown.length) return;

    $dropdown.detach().appendTo(document.body);
    $dropdown[0]._wfpOwner = st;
    $dropdown.css({ position: "absolute", zIndex: 1085 });

    function place() {
      var r = st.$control[0].getBoundingClientRect();
      var h = $dropdown.outerHeight() || 0;
      // No room below the input and more above it: open upwards.
      var up = r.bottom + h > window.innerHeight && r.top > window.innerHeight - r.bottom;
      $dropdown.css({
        // getBoundingClientRect is viewport-relative; the menu is on the body.
        top: (up ? r.top - h : r.bottom) + window.pageYOffset + "px",
        left: r.left + window.pageXOffset + "px",
        width: r.width + "px"
      });
    }

    // selectize repositions the menu itself (on open and on every options
    // refresh) relative to the control's offset parent -- which, once the menu
    // lives on the body, puts it at the top-left of the page. Replace it.
    st.positionDropdown = place;
    st.on("dropdown_open", place);
    // A sidebar or page scroll while the menu is open would leave it behind.
    var onMove = function () { if (st.isOpen) place(); };
    window.addEventListener("scroll", onMove, true);
    window.addEventListener("resize", onMove);
  }

  function sweep(root) {
    var nodes = (root || document).querySelectorAll("select.selectized, select[data-shinyjs], select");
    for (var i = 0; i < nodes.length; i++) reparent(nodes[i]);
  }

  // Inputs arrive in three ways: with the page, from renderUI, and from inside
  // a modal. shiny:bound covers the first two; the modal event covers the last.
  $(document).on("shiny:bound", function (e) {
    if (e.bindingType === "input") setTimeout(function () { sweep(e.target.parentElement || document); }, 0);
  });

  $(document).on("shown.bs.modal", function (e) { setTimeout(function () { sweep(e.target); }, 0); });

  // updateSelectInput() with new choices makes Shiny destroy and rebuild the
  // selectize instance: the new one had its menu back inside the card (clipped
  // by the scrolling page) and the 1,000-option cap back on.
  $(document).on("shiny:updateinput", function (e) {
    var el = e.target;
    if (el && el.tagName === "SELECT") setTimeout(function () { reparent(el); }, 0);
  });

  $(document).on("shiny:connected", function () { setTimeout(sweep, 250); });

  // Menus living on the body outlive their input. When a renderUI redraws
  // (the rule builder redraws its rows after every choice) the old input is
  // dropped without being destroyed, and a menu that was open stays on the
  // page with nothing behind it. The same happens when the input's tab is
  // hidden while its menu is open. Remove orphans, close hidden ones.
  function visible(el) { return !!(el && document.body.contains(el) && el.offsetParent !== null); }

  function tidy() {
    var i, d, st, c, sel;
    var menus = document.querySelectorAll("body > .selectize-dropdown");
    for (i = 0; i < menus.length; i++) {
      d = menus[i]; st = d._wfpOwner;
      if (!st || !document.body.contains(st.$control[0])) { d.parentNode.removeChild(d); continue; }
      if (st.isOpen && !visible(st.$control[0])) st.close();
    }
    var boxes = document.querySelectorAll("body > .bs-container");
    for (i = 0; i < boxes.length; i++) {
      c = boxes[i]; sel = c._wfpSelect;
      if (!sel) continue;
      if (!document.body.contains(sel)) { c.parentNode.removeChild(c); continue; }
      var sp = $(sel).data("selectpicker");
      var btn = sp && sp.$button ? sp.$button[0] : null;
      if (c.classList.contains("show") && !visible(btn)) {
        c.classList.remove("show", "open");
        $(c).find(".dropdown-menu").removeClass("show");
        if (btn) { btn.classList.remove("show"); btn.setAttribute("aria-expanded", "false"); }
      }
    }
  }

  // bootstrap-select (pickerInput with container = "body") only tells us which
  // select a body-level menu belongs to while it is being shown.
  $(document).on("shown.bs.select", "select", function () {
    var sp = $(this).data("selectpicker");
    if (sp && sp.$bsContainer && sp.$bsContainer.length) sp.$bsContainer[0]._wfpSelect = this;
  });

  // A page picked from a navbar menu (or selected from the server with
  // nav_select) is shown without the menu being told to close, so it stayed
  // open over the page. Close the menu that holds the tab just shown.
  $(document).on("shown.bs.tab", ".dropdown-menu [data-bs-toggle='tab'], .dropdown-menu [data-bs-toggle='pill']", function () {
    var menu = this.closest(".dropdown-menu");
    var holder = menu && menu.parentElement;
    var toggle = holder && holder.querySelector("[data-bs-toggle='dropdown']");
    if (toggle && window.bootstrap && bootstrap.Dropdown) bootstrap.Dropdown.getOrCreateInstance(toggle).hide();
    if (menu) menu.classList.remove("show");
    if (toggle) { toggle.classList.remove("show"); toggle.setAttribute("aria-expanded", "false"); }
  });

  // Scrolling DataTables measure their columns when drawn; one drawn in a
  // hidden tab or a collapsed card gets a misaligned header. Re-measure the
  // visible ones when a tab or card is shown, and on resize.
  function adjustTables() {
    if ($.fn.dataTable) $.fn.dataTable.tables({ visible: true, api: true }).columns.adjust();
  }
  $(document).on("shown.bs.tab shown.bs.collapse", function () { setTimeout(adjustTables, 30); });
  $(window).on("resize", function () { clearTimeout(window._wfpAdj); window._wfpAdj = setTimeout(adjustTables, 150); });

  var later = function () { setTimeout(tidy, 0); };
  $(document).on("shiny:value shiny:unbound shown.bs.tab hidden.bs.tab hidden.bs.modal", later);
})();
