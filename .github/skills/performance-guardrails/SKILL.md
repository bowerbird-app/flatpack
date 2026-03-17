---
name: performance-guardrails
description: Detect and prevent common Rails and ViewComponent performance regressions with focused checks.
---

# Performance Guardrails Skill

## Use when

- The change affects rendering paths, queries, collections, loops, partials/components, or request-heavy flows.
- The user asks for performance review, optimization, or regression prevention.

## Primary checks

- N+1 query risk in controllers/models/views
- Over-rendering in loops and repeated component instantiation
- Inefficient data loading patterns and avoidable allocations
- Expensive helper usage in hot rendering paths
- Missing eager loading where query fan-out is predictable

## Workflow

1. Inspect changed files for likely hot paths and repeated operations.
2. Apply low-risk, behavior-preserving optimizations first.
3. Prefer query-shape fixes (includes/preload/select) and rendering reductions over broad rewrites.
4. Add or update focused tests if performance-sensitive behavior changes.
5. Run `bundle exec rubocop -A` to auto-correct style offenses after all code changes.
6. Run targeted checks/tests and report measurable or structural improvements.

## Handoff format

- Risks found
- Optimizations applied (or recommended)
- Validation performed
- Residual risk

## Guardrails

- Preserve public behavior and output fidelity.
- Avoid speculative micro-optimizations without clear value.
- Do not introduce caching layers or architecture changes unless explicitly requested.
