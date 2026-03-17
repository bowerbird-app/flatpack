---
name: code-review
description: Perform a prioritized implementation review focused on correctness, security, and maintainability.
---

# Code Review Skill

## Use when

- Work is implemented and needs a quality review pass before merge.

## Review dimensions

- Correctness and edge cases
- Security and data safety
- Rails convention alignment and maintainability
- Test completeness and regression risk
- API and behavior compatibility
- Readability and duplication

## Output format

1. Overall assessment
2. Findings by priority (must-fix / should-fix / nice-to-have)
3. Suggested code-level actions by file
4. Test recommendations
5. Merge readiness status

## Guardrails

- Keep recommendations scoped to the request.
- Prefer targeted fixes over broad rewrites.
- Be explicit about assumptions and uncertainty.
- If Ruby code was changed, verify `bundle exec rubocop -A` was run to auto-correct style offenses.
