---
name: minitest-coverage
description: Expand reliable Minitest coverage for engine and dummy-app integration behavior.
---

# Minitest Coverage Skill

## Use when

- Requests ask for tests, regressions, coverage improvements, or confidence hardening.

## Scope

- Gem suite under `test/`
- Dummy app suite under `test/dummy/test/`

## Coverage approach

- Prefer focused tests closest to changed behavior.
- Cover happy path, failure path, and critical edge cases.
- Keep tests deterministic, readable, and fast.
- Add regression tests for reported bugs.
- Verify hooks/callbacks/config defaults where touched.

## Workflow

1. Map changed behavior to nearest existing test files.
2. Add minimal tests that prove expected behavior and guard regressions.
3. Run targeted tests first, then broader suite if needed.
4. Report what scenarios are covered and any remaining gaps.

## Guardrails

- Do not delete, bypass, or stub production behavior just to pass tests.
- Do not overfit tests to implementation details.
- Preserve public behavior and APIs.
