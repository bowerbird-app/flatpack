# Cursor Cloud Agent skills

Flatpack Cloud Agents load project skills from the git checkout.

## What is tracked

`.cursor/skills/` holds the [pstack](https://github.com/cursor/plugins/tree/main/pstack/skills) pack. Each skill id is a directory with `SKILL.md` and any playbooks, references, or scripts that skill ships.

This repo does not use Recording Studio skills. Do not add `recording-studio-*` here. Do not fetch `RecordingStudio_cursor_plugin`.

`.cursor/rules/` stays gitignored. Do not invent a Flatpack rules pack. `setup-pstack` may write a local rule when someone runs it.

The gemspec does not package `.cursor/`. Host apps that install the gem do not receive these files. Cloud Agents that clone this repository do.

## How agents pick them up

`.cursor/environment.json` names the environment `flatpack`. `install` is a no-op (`true`). Skills are already in the tree, so Build does not download a pack.

After this layout merges, rebuild the Cloud Agent environment Draft off that commit. A snapshot taken while skills were gitignored will not see them.

## Refreshing the pack

Copy from the public pstack tree. Use the GitHub contents API and raw file URLs. Do not clone.

- Contents: `https://api.github.com/repos/cursor/plugins/contents/pstack/skills?ref=main&per_page=100`
- Raw file: `https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/<id>/...`

Replace `.cursor/skills/` with that listing. Do not rewrite the files.
