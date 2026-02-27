---
name: component-discovery
description: Discover available FlatPack components and recommend what to use based on UI intent using the canonical docs manifest.
---

# Component Discovery Skill

## Use when

- The user asks what components exist.
- The user asks which component to use for a specific UI need.
- The user asks what a component does or how to use it.
- The user asks for alternatives or tradeoffs between components.

## Canonical sources (in priority order)

1. `docs/components/manifest.yml` (machine-readable inventory)
2. `docs/components/README.md` (human index)
3. `docs/components/*.md` (detailed usage docs)
4. `docs/components/DOC_FORMAT.md` (required structure/terminology)

Do not treat ad-hoc examples or old summary docs as source of truth when they conflict with the manifest.

## Workflow

1. Parse the user’s intent into one or more UI tasks (for example: feedback, navigation, data display, forms, loading states).
2. Find candidate components in `docs/components/manifest.yml`.
3. Prefer components with `status: documented`.
4. Return canonical class names and direct docs links.
5. Provide one minimal example path (where to start) and optional alternatives.
6. If no documented component fits, explicitly say so and point to `undocumented_or_internal_candidates` as non-default options.

## Output format

Return concise sections in this order:

1. **Recommended component(s)**
   - Component name
   - Canonical class (`FlatPack::...::Component`)
   - Why it fits
2. **How to start**
   - Link to primary docs page
   - One minimal usage direction
3. **Alternatives** (optional)
   - When to choose another component
4. **Notes**
   - Mention if recommendation depends on Stimulus/Turbo/dependencies

## Guardrails

- Prefer documented components over undocumented/internal candidates.
- Do not invent component APIs; defer to linked docs.
- Keep recommendations aligned with existing FlatPack patterns.
- If request is ambiguous, ask one concise clarification question or provide top 2 safe options.
- Avoid recommending custom HTML when a documented component can satisfy the need.
