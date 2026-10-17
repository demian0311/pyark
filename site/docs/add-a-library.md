# Add a library or tool

When `uv add something` fails with a resolution error, the package is not in the store. uv is configured to read only the local wheelhouse, so this is expected and immediate.

**When you are online**

1. Add the name to `~/code/pyark/manifest/packages.txt`, in the category it belongs to.
2. Run `pyark harvest wheels`. It downloads the package and its dependencies for every Python version in the store, and skips what it already has.
3. `uv add something` now works, and keeps working offline.
4. If the project publishes a docs site, add a line to `manifest/docs.txt` and run `pyark harvest docs`.
5. Commit the manifest change.

**When you are offline and need it now**

`uv add --frozen something` records the dependency without resolving. The project will not run until the wheel is in the store, but the intent is saved for the next harvest.

**CLI tools**

- Python tools (installed in their own environment, on your PATH): `manifest/tools.txt`, then `pyark harvest wheels && pyark install python`.
- Arch packages: `manifest/arch.txt`, then `pyark harvest arch && pyark install arch`. The install asks for your password.

**A newer Python**

pyark supports exactly one version. Change the line in `manifest/python.txt`, then while online: `pyark harvest python && pyark harvest wheels && pyark harvest docs && pyark install python`. Projects follow via `uv python pin`.
