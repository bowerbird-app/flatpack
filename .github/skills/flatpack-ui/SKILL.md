---
name: flatpack-ui
description: Prefer FlatPack components over raw HTML and enforce component-first UI choices.
---

# FlatPack UI Skill

## Use when

- Requests involve UI in dummy app views, examples, or component usage decisions.

## Core policy

- Prefer `render FlatPack::X::Component.new(...)` over handwritten HTML.
- Use existing components, slots, and APIs before custom markup.
- Use custom HTML only when no component can satisfy the requirement.

## Icon usage

FlatPack icons are rendered via `FlatPack::Shared::IconComponent` (or the `icon:` prop on components that accept one). Icons load their paths client-side from the importmap-pinned `flat_pack/heroicons` module — **no SVG sprite partial is required in the host layout**.

- Use [Heroicons v2](https://heroicons.com) canonical dash-separated names: `"magnifying-glass"`, `"cog-6-tooth"`, `"exclamation-triangle"`, etc.
- Ruby symbol form is also accepted (underscores converted): `:magnifying_glass`, `:cog_6_tooth`.
- The `:variant` option accepts `:outline` (default) or `:solid`.
- A set of legacy shorthand aliases (`"search"` → `"magnifying-glass"`, `"settings"` → `"cog-6-tooth"`, etc.) are mapped internally; prefer canonical names in new code.
- Do **not** add raw `<svg>` markup or `<use xlink:href>` when `FlatPack::Shared::IconComponent` can be used instead.

## Workflow

1. Check component docs and existing patterns first.
2. Replace raw markup with matching FlatPack components where feasible.
3. Keep changes minimal and preserve behavior.
4. Run `bundle exec rubocop -A` to auto-correct style offenses after all code changes.
5. Validate changed user flows and note any gaps.

## Guardrails

- Ask for approval before introducing a brand-new reusable component.
- Do not add stylistic rewrites unrelated to the requested UI change.
- Keep accessibility and semantic structure intact.
