// Reference docs page: filter rows as you type, hide empty groups and their jump chips.
// Inert on every other page. "/" is taken by the site search, so the box has no shortcut.
document.addEventListener("DOMContentLoaded", () => {
  const box = document.getElementById("ref-filter");
  if (!box) return;
  const count = document.getElementById("ref-count");
  const groups = [...document.querySelectorAll(".ref-group")];
  const apply = () => {
    const q = box.value.trim().toLowerCase();
    let shown = 0;
    for (const g of groups) {
      let n = 0;
      for (const li of g.querySelectorAll(".ref-list li")) {
        const hit = !q || li.textContent.toLowerCase().includes(q);
        li.hidden = !hit;
        if (hit) n++;
      }
      g.hidden = n === 0;
      const h = g.querySelector("h2");
      const chip = h && document.querySelector(`.ref-chip[href="#${h.id}"]`);
      if (chip) chip.hidden = n === 0;
      shown += n;
    }
    count.textContent = q ? `${shown} match${shown === 1 ? "" : "es"}` : "";
  };
  box.addEventListener("input", apply);
  box.addEventListener("keydown", (e) => { if (e.key === "Escape") { box.value = ""; apply(); } });
});
