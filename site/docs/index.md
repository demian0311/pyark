---
icon: material/home-outline
---

# pyark

<p class="lede">Offline Python for Omarchy.</p>

<link href="/pagefind/pagefind-ui.css" rel="stylesheet">
<div id="search" class="home-search"></div>
<script src="assets/ref-titles.js"></script>
<script src="/pagefind/pagefind-ui.js"></script>
<script>
(function () {
  // One search over every mirrored doc under /ref/. ?find=<query> deep-links a search.
  function start() {
    if (typeof PagefindUI === "undefined") return;
    var ui = new PagefindUI({ element: "#search", baseUrl: "/ref/", showSubResults: true, showImages: false, pageSize: 10,
                     translations: { placeholder: "Search every manual, book and library doc" },
                     // Name the source: /ref/<id>/... -> "Title (Library)".
                     processResult: function (r) {
                       var id = (r.url.match(/\/ref\/([^/]+)\//) || [])[1];
                       var lib = id && (window.PYARK_REF_TITLES || {})[id];
                       if (lib && r.meta && r.meta.title && r.meta.title.indexOf(lib) === -1) r.meta.title += " (" + lib + ")";
                       return r;
                     } });
    // triggerSearch waits for the index; a synthetic input event fired before it loaded was dropped.
    var q = new URLSearchParams(location.search).get("find");
    if (q) ui.triggerSearch(q);
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", start); else start();
})();
</script>

## :material-bookshelf: Reference docs

<!-- ref-tiles: install/site.sh puts the group tiles here -->

## :material-information-outline: About this machine

This machine has a complete Python development environment that works with the network down. Interpreter, packages, tools and every page on this site come from a local **store** filled while online.

<div class="cards" markdown>
<div class="card" style="--hue: var(--slate-blue)" markdown>
<h3 markdown>:material-package-variant-closed: uv never leaves the disk</h3>
<p><code>uv add polars</code> resolves from the local wheelhouse in well under a second. A package that is not in the store fails at once. <a href="add-a-library/">Add a library or tool</a> says what to do.</p>
</div>
<div class="card" style="--hue: var(--slate-teal)" markdown>
<h3 markdown>:material-language-python: One Python</h3>
<p>pyark pins a single interpreter and every project runs on it. No version matrix, no second set of wheels or docs.</p>
</div>
<div class="card" style="--hue: var(--slate-orange)" markdown>
<h3 markdown>:material-bookshelf: The docs are here</h3>
<p>Every library in the store, the Python docs, SQLite, the Arch Wiki and a shelf of free books, under <a href="reference/">Reference docs</a>.</p>
</div>
<div class="card" style="--hue: var(--slate-purple)" markdown>
<h3 markdown>:material-file-code-outline: The editor is ready</h3>
<p>nvim with ruff and ty as language servers, nothing downloaded at runtime. <a href="nvim/">Editor (nvim)</a>.</p>
</div>
</div>

## :material-map-marker-outline: Where things are

| What | Where |
|---|---|
| the repo | `~/code/pyark` |
| the store | `~/code/pyark/store`, not in git |
| uv's config | `~/.config/uv/uv.toml` |
| tools | `~/.local/bin` |
| this site | `pyark serve`, then <http://localhost:8800> |
| the check-up | `pyark doctor` lists what the store holds, how old it is, and what the machine lacks |

## :material-compass-outline: Living without a search engine

- Anything in the docs: the search box at the top of this page covers every mirrored page.
- Library API: open the library under Reference docs and use its own search.
- Anything installed in a project: `uv run python -m pydoc -b` inside the project opens a browser on the docstrings of every module it can import.
- Standard library: the Python docs have the full module index.
- System questions: the Arch Wiki.
