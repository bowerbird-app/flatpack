# FlatPack AI Entry Point

Use this directory when FlatPack is being installed, inspected, or consumed by external AI tooling.

## Retrieval order

1. Read `docs/ai/install_contract.json`
2. Read `docs/components/manifest.yml`
3. Read `docs/installation.md`
4. Read `README.md`
5. Read the specific component doc under `docs/components/`

## Install commands

```bash
bundle install
bin/rails generate flat_pack:install
bin/rake flat_pack:contract
bin/rake flat_pack:verify_install
```

## Runtime contract commands

```bash
bin/rake flat_pack:contract
bin/rake flat_pack:verify_install
```

## Canonical artifacts

- `docs/ai/install_contract.json`: machine-readable host-app integration contract
- `docs/components/manifest.yml`: docs and AI reading order for the repo inventory
- `docs/components/DOC_FORMAT.md`: normalized component doc structure
- `docs/installation.md`: human-readable installation guide
- `docs/i18n.md`: English kit copy under `flatpack.*`; hosts provide other languages. `FlatPack::Copy.t` uses English when the active locale has no `flatpack.*` value

The running inventory is `FlatPack::ComponentCatalog` (HTTP `GET /recording_studio_api/api/v1/flatpack/components` on a host that registers those endpoints, including this dummy). `manifest.yml` is not the runtime catalog. `list` is skinny records plus `meta`. `show(name)` adds `parameters`, `slots`, and `examples` from the component doc `## Example` section. A parameter may include `default` when the `initialize` kwarg is a JSON-safe literal. The key is omitted when that default is unknown.

## Shape

Radius is a theme dimension, same pattern as `--space-*`. The moderate scale (`--radius-xs` through `--radius-xl`, plus `--radius-full`) lives on bare `:root`. Component tokens such as `--button-border-radius`, `--form-control-radius`, `--badge-radius`, `--card-radius`, `--menu-radius`, and `--modal-radius` alias a step. `--button-round-border-radius` is the opt-in Button `round:` corner and stays `--radius-full` on every theme. `[data-theme~="rounded"]` turns buttons, inputs, badges, tabs, and the chat composer into pills. Chips, sidebar item highlights, and menu item highlights stay `--radius-md`. Cards, menus, and modals step up to `--radius-xl`. Dark and ocean inherit the moderate shape. See `docs/theming.md`.

## Notes

- Treat the installed gem as the primary source of truth.
- Prefer the verification command over manual file inspection.
- Use component docs for examples only after the install contract and manifest have been read.