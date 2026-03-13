---
name: rails-implementation
description: Implement and fix Rails code with secure defaults and focused tests.
---

# Rails Implementation Skill

## Use when

- The user asks to implement features, fix bugs, or modify Rails code in this repo.

## Standards

- Correctness first: fix root causes and preserve public behavior unless requested.
- Rails conventions: clear naming, thin controllers, explicit data flow.
- Security by default: validate and sanitize external input.
- Performance awareness: avoid N+1 and unnecessary allocations.
- Maintainability: small, focused, reviewable changes.

## Workflow

1. Understand request constraints and impacted behavior.
2. Identify impacted models/services/controllers/views/tests.
3. Implement minimal high-confidence changes.
4. Add/update focused tests for changed behavior.
5. Run targeted verification, then broader checks as needed.
6. Report changes, risk level, and follow-up.

## Guardrails

- Do not introduce unrelated refactors.
- Do not bypass failing tests by weakening assertions or removing behavior.
- Do not add dependencies without clear need.
- Prefer existing project patterns and abstractions.
- When adding icons to a component, use `FlatPack::Shared::IconComponent` (not inline `<svg>` or `<use xlink:href>`). The icon system loads path data from the importmap-pinned `flat_pack/heroicons` JS module at runtime. Use Heroicons v2 canonical names (e.g. `"magnifying-glass"`, `"cog-6-tooth"`).
