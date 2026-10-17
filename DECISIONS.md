# pyark decisions

Dated. Append, never rewrite. Agent-facing.

## 2026-10-17 — shape (mockup: mockups/2026-10-17-shape.html, https://claude.ai/artifact/S3idvHgCseAuUEcEF1rzF5)

- Name `pyark`, repo `demian0311/pyark` (GitHub push pending). Public: no machine state, no secrets.
- Architecture: `harvest` (online) fills `store/`; `install` (offline) consumes it. `store/` gitignored, default `~/.local/share/pyark`, may be a USB mount.
- Target: this laptop, sometimes offline. Omarchy's own packages out of scope. Revisit if a second air-gapped machine appears.
- Python toolchain: uv. Versions in `manifest/python.txt`, first line default. mise stays for non-Python tools only.
- Libraries: curated, `manifest/packages.txt`, defaults accepted by Demian 2026-10-17 (52 incl. marimo). Each harvested with dependency closure, plus HTML docs where a build exists.
- Notebooks: marimo. No JupyterLab.
- Type checker: ty (fallback pyrefly); basedpyright NOT harvested, avoids node in the store. Revisit if ty fails on real code.
- Docs hub: mkdocs site at `localhost:8800` serving own guides + harvested HTML docs under one search. Zeal and DevDocs rejected (separate app / Ruby scraper).
- nvim: layer onto Demian's existing LazyVim (`~/.config/nvim`): python extra, plugin dir pointed at store, Mason disabled. Not `NVIM_APPNAME`, not a replacement.
- Scaffolding: copier template in `templates/`, `pyark new <name>`.
- Entry point `bin/pyark`: harvest · install · serve · new · doctor.
