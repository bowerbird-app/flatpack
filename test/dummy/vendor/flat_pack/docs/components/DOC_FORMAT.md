# FlatPack Component Documentation Format (Agent-First)

Use this structure for every component doc under `docs/components/`.

## Required Section Order

1. `# <Component Name>`
2. `## Purpose`
3. `## When to use`
4. `## Class`
5. `## Props`
6. `## Slots` (if applicable; otherwise explicitly state `None`)
7. `## Variants` (if applicable; otherwise explicitly state `None`)
8. `## Example`
9. `## Accessibility`
10. `## Dependencies`

## Writing Rules

- Use canonical class names (for example `FlatPack::Button::Component`).
- Keep one minimal example first; place advanced examples after it.
- Keep prop tables normalized to: `name`, `type`, `default`, `required`, `description`.
- List all allowed enum values inline in `description`.
- Mention Stimulus controller dependencies explicitly when required.
- Mark internal-only or composition-only classes explicitly.
- Prefer short, parseable sentences over prose-heavy explanations.

## Agent Retrieval Hints

- Start each doc with one sentence that clearly states what UI problem the component solves.
- Include one primary class under `## Class` and additional classes under `Related classes`.
- Add a single “best first example” under `## Example` that works standalone.
- Keep cross-links only to existing paths under `docs/`.

## Canonical Inventory

- Human index: `docs/components/README.md`
- Machine index: `docs/components/manifest.yml`
