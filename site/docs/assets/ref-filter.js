// Reference docs page: filter rows as you type. Groups with no match hide, and the contents
// block at the top shows live counts. Inert on every other page.
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
      const entry = h && document.querySelector(`.ref-index a[data-group="${h.id}"]`);
      if (entry) {
        entry.querySelector(".n").textContent = n;
        entry.classList.toggle("empty", n === 0);
      }
      shown += n;
    }
    count.textContent = q ? `${shown} match${shown === 1 ? "" : "es"}` : "";
  };
  box.addEventListener("input", apply);
  box.addEventListener("keydown", (e) => { if (e.key === "Escape") { box.value = ""; apply(); } });
});
