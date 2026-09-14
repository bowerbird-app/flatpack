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

The running inventory is `FlatPack::ComponentCatalog` (HTTP `GET /recording_studio_api/api/v1/flatpack/components` on a host that registers those endpoints, including this dummy). `manifest.yml` is not the runtime catalog. `list` is skinny records plus `meta`. `show(name)` adds `parameters`, `slots`, and `examples` from the component doc `## Example` section. A parameter may include `default` when the `initialize` kwarg is a JSON-safe literal. The key is omitted when that default is unknown.

## Notes

- Treat the installed gem as the primary source of truth.
- Prefer the verification command over manual file inspection.
- Use component docs for examples only after the install contract and manifest have been read.