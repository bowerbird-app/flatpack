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

## Workflow

1. Check component docs and existing patterns first.
2. Replace raw markup with matching FlatPack components where feasible.
3. Keep changes minimal and preserve behavior.
4. Validate changed user flows and note any gaps.

## Guardrails

- Ask for approval before introducing a brand-new reusable component.
- Do not add stylistic rewrites unrelated to the requested UI change.
- Keep accessibility and semantic structure intact.
