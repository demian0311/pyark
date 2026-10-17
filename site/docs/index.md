# pyark

<div class="eyebrow" markdown>offline python on omarchy</div>

This machine has a complete Python development environment that works with the network down. Interpreter, packages, tools and every page on this site come from a local **store** filled while online.

<div class="cards" markdown>
<div class="card" style="--hue: var(--slate-blue)" markdown>
<h3>uv never leaves the disk</h3>
<p><code>uv add polars</code> resolves from the local wheelhouse in well under a second. A package that is not in the store fails at once. <a href="add-a-library/">Add a library or tool</a> says what to do.</p>
</div>
<div class="card" style="--hue: var(--slate-teal)" markdown>
<h3>One Python</h3>
<p>pyark pins a single interpreter and every project runs on it. No version matrix, no second set of wheels or docs.</p>
</div>
<div class="card" style="--hue: var(--slate-orange)" markdown>
<h3>The docs are here</h3>
<p>Every library in the store, the Python docs, SQLite, the Arch Wiki and a shelf of free books, under <a href="reference/">Reference docs</a>.</p>
</div>
<div class="card" style="--hue: var(--slate-purple)" markdown>
<h3>The editor is ready</h3>
<p>nvim with ruff and ty as language servers, nothing downloaded at runtime. <a href="nvim/">Editor (nvim)</a>.</p>
</div>
</div>

**Where things are**

| What | Where |
|---|---|
| the repo | `~/code/pyark` |
| the store | `~/code/pyark/store`, not in git |
| uv's config | `~/.config/uv/uv.toml` |
| tools | `~/.local/bin` |
| this site | `pyark serve`, then <http://localhost:8800> |
| the check-up | `pyark doctor` lists what the store holds, how old it is, and what the machine lacks |

**Living without a search engine**

- Library API: open the library under Reference docs and use its own search.
- Anything installed in a project: `uv run python -m pydoc -b` inside the project opens a browser on the docstrings of every module it can import.
- Standard library: the Python docs have the full module index.
- System questions: the Arch Wiki.
