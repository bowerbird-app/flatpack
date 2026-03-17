---
name: docs-audit
description: Audit all component docs for completeness and format compliance, then update root project docs (README.md, PROJECT_STRUCTURE.md) to match the current component library.
---

# Docs Audit Skill

## Use when

- Performing a periodic documentation health check.
- After a batch of new components or significant API changes have landed.
- The user asks to "check up on docs", "audit documentation", or "make sure docs are up to date".

## Scope

1. **Component docs** — all `.md` files under `docs/components/` (excluding `DOC_FORMAT.md`, `README.md`, `manifest.yml`, and `*_SUMMARY.md` files).
2. **Root project docs** — `README.md` and `PROJECT_STRUCTURE.md` at the workspace root.
3. **Manifest and index** — `docs/components/manifest.yml` and `docs/components/README.md`.

---

## Phase 1 — Component docs audit

### Step 1: Read the contract

Read `docs/components/DOC_FORMAT.md` before auditing. All component docs must follow this contract.

### Step 2: Discover all components

- List `app/components/flat_pack/` to get the canonical set of component directories.
- List `docs/components/` to get all existing doc files.
- Note any component directory that has no matching doc file (missing docs).

### Step 3: Audit each component doc

For every component doc, verify all **10 required sections** are present in this order:

1. `# <Component Name>` — plain name only, no "Component" suffix, no camelCase (e.g. `# Button`, `# Top Nav`)
2. `## Purpose`
3. `## When to use`
4. `## Class`
5. `## Props`
6. `## Slots`
7. `## Variants`
8. `## Example`
9. `## Accessibility`
10. `## Dependencies`

Also check:

- Prop table has columns: `name`, `type`, `default`, `required`, `description`.
- No stale "Component" suffix in H1 (e.g. `# Button Component` → `# Button`).
- No introductory prose between H1 and `## Purpose`.
- No redundant sections that duplicate `## Props` or `## Example` content (e.g. `## Method`, `## Variables`).
- Non-standard section names that shadow required ones (e.g. `## Code Example` instead of `## Example`).

### Step 4: Fix all issues found

Apply all fixes inline. Do not create new files to report issues — fix them directly.

Common fixes:
- Rename `## Code Example` → `## Example`.
- Remove "Component" suffix from H1: `# Grid Component` → `# Grid`.
- Fix camelCase H1: `# TopNav Component` → `# Top Nav`.
- Add missing `required` column to prop tables.
- Absorb stray intro paragraph into `## Purpose` body.
- Remove redundant `## Method` / `## Variables` sections.

---

## Phase 2 — Root project doc updates

### README.md

Check and update:

- `## Components` section lists all shipped components, organized by category.
- No "coming soon" notes for components that now exist.
- Quick-start examples use current prop names (e.g. `style:` not `scheme:`).
- All doc cross-links point to paths that exist under `docs/`.

### PROJECT_STRUCTURE.md

Check and update:

- **Version** matches `lib/flat_pack/version.rb`.
- **Last Updated** date is current.
- **Directory tree** under `app/components/flat_pack/` lists all component directories.
- **Directory tree** under `app/javascript/flat_pack/controllers/` lists all Stimulus controller files.
- **Directory tree** under `docs/` reflects actual structure (manifest.yml, DOC_FORMAT.md, architecture files).
- **Core Components** section reflects the current full library, not just early components.
- **Future Enhancements** — remove items that have since shipped.
- **Generator Actions** description matches the current install generator behavior.
- **Project Status** reflects current release status.

---

## Phase 3 — Manifest and index sync

Check `docs/components/manifest.yml`:
- Every component directory in `app/components/flat_pack/` that is user-facing has a corresponding entry.
- Each entry has: `key`, `title`, `doc`, `primary_class`, `status: documented`.
- Add any missing entries; mark truly undocumented/internal ones under `undocumented_or_internal_candidates`.

Check `docs/components/README.md` (AI quick index):
- Every entry in `manifest.yml` has a matching line in the quick-index table.

---

## Handoff format

Report in two sections:

**Component docs fixed** — table of `file | issues fixed`

**Root docs updated** — bullet list per file of what changed

---

## Guardrails

- Do not invent undocumented behavior not present in code.
- Do not remove informative non-standard sections (e.g. `## Security Considerations` in sortable-tables) — these may be retained as they add value beyond the schema minimum.
- Do not rewrite prose that is accurate — only fix structural/format issues.
- Keep prop table content accurate to the component's actual Ruby API.
- After all doc edits are complete, commit with a `docs:` prefix commit message summarizing the changes.
