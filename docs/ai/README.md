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
- `docs/components/manifest.yml`: machine-readable component inventory
- `docs/components/DOC_FORMAT.md`: normalized component doc structure
- `docs/installation.md`: human-readable installation guide

## Notes

- Treat the installed gem as the primary source of truth.
- Prefer the verification command over manual file inspection.
- Use component docs for examples only after the install contract and manifest have been read.