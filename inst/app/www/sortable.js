// Drag-and-drop ordering of the monitoring report items (native HTML5, no
// library). Items are dragged by their handle only, so the comment box inside
// them stays selectable. The new order goes to the input named on the
// container's data-input attribute.
(function () {
  "use strict";
  var dragged = null;

  function send(box) {
    var ids = Array.prototype.map.call(box.querySelectorAll(".wfp-item"), function (x) { return x.dataset.id; });
    Shiny.setInputValue(box.dataset.input, ids, { priority: "event" });
  }
  function clearMarks() { $(".wfp-items .drop-before").removeClass("drop-before"); }

  $(document).on("mousedown touchstart", ".wfp-items .wfp-drag", function () {
    $(this).closest(".wfp-item").attr("draggable", "true");
  });
  $(document).on("dragstart", ".wfp-items .wfp-item", function (e) {
    dragged = this;
    this.classList.add("dragging");
    e.originalEvent.dataTransfer.effectAllowed = "move";
    e.originalEvent.dataTransfer.setData("text/plain", this.dataset.id);
  });
  $(document).on("dragend", ".wfp-items .wfp-item", function () {
    this.classList.remove("dragging");
    this.removeAttribute("draggable");
    clearMarks();
    dragged = null;
  });
  $(document).on("dragover", ".wfp-items .wfp-item", function (e) {
    if (!dragged || dragged === this) return;
    e.preventDefault();
    clearMarks();
    this.classList.add("drop-before");
  });
  $(document).on("drop", ".wfp-items .wfp-item", function (e) {
    if (!dragged || dragged === this) return;
    e.preventDefault();
    this.parentNode.insertBefore(dragged, this);
    send(this.parentNode);
  });
  // Dropped on the empty end of the list: last place.
  $(document).on("dragover", ".wfp-items", function (e) { if (dragged && e.target === this) e.preventDefault(); });
  $(document).on("drop", ".wfp-items", function (e) {
    if (!dragged || e.target !== this) return;
    e.preventDefault();
    this.appendChild(dragged);
    send(this);
  });
})();
