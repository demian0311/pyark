# Search all docs

One search box over every mirrored page under [Reference docs](../reference/): the Python docs, SQLite, the Arch Wiki, the books and every library. The guides on this site have their own search in the top bar.

<link href="/pagefind/pagefind-ui.css" rel="stylesheet">
<div id="search"></div>
<script src="/pagefind/pagefind-ui.js"></script>
<script>
(function () {
  function start() {
    new PagefindUI({ element: "#search", baseUrl: "/ref/", showSubResults: true, showImages: false, pageSize: 10 });
    var q = new URLSearchParams(location.search).get("find");
    if (q) { var i = document.querySelector("#search input"); if (i) { i.value = q; i.dispatchEvent(new Event("input", { bubbles: true })); } }
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start); else start();
})();
</script>

!!! note
    The index is built by `pyark install site` and lives in the store. After `pyark harvest docs`, run `pyark install site` again to refresh it.
