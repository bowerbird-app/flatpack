---
name: docs-synchronization
description: Keep component and architecture docs accurate and synchronized with implementation changes.
---

# Docs Synchronization Skill

## Use when

- A change modifies component APIs, options, behavior, examples, or architecture notes.
- The user asks for docs updates, docs audit, or docs parity checks.

## Scope

- Component docs under `docs/components/`
- Top-level docs such as `README.md`, `docs/README.md`, and architecture notes under `docs/architecture/`
- Implementation summary docs when present

## Workflow

1. Identify behavior/API changes in code and tests.
2. Locate nearest docs that describe those behaviors.
3. Update examples, options tables, and usage notes to match current implementation.
4. Remove stale examples and contradictory statements.
5. Add concise migration notes when behavior changed intentionally.

## Quality checklist

- Examples compile conceptually against current component API.
- Required arguments, defaults, and variants match implementation.
- Accessibility and security caveats are documented where relevant.
- Cross-links point to existing docs paths.
- Icon names in examples use Heroicons v2 canonical names (e.g. `"magnifying-glass"`, `"cog-6-tooth"`, `"ellipsis-vertical"`) rather than legacy shorthands (`"search"`, `"cog"`, `"dots"`). Update any stale icon name references when found.

## Handoff format

- Files updated
- What changed in docs
- Any intentional gaps or follow-ups

## Guardrails

- Do not invent undocumented behavior not present in code.
- Do not rewrite unrelated docs sections.
- Keep wording concise and implementation-accurate.
