---
name: push-readiness
description: Validate code is safe to push by running required quality gates and reporting pass/fail status.
---

# Push Readiness Skill

## Use when

- The user asks to push code, prepare for push, or confirm branch readiness.
- A change is complete and needs final quality-gate validation.

## Required checks

Run these checks and require they pass before push:

1. `bundle exec rubocop -A` (auto-correct style offenses first)
2. `bundle exec rubocop` (verify no remaining offenses)
3. `bundle exec rake app:test`

## Conditional checks

If changes touch dummy app boot, assets, or migrations, run from `test/dummy` before tests:

1. `bundle exec rake db:migrate RAILS_ENV=test`
2. `bundle exec rails tailwindcss:build`

## Workflow

1. Identify changed files and decide whether conditional dummy-app prep is needed.
2. Run required checks in deterministic order.
3. If any check fails, stop push recommendation and report failing command plus concise remediation path.
4. If all checks pass, return explicit “ready to push” status with command summary.

## Handoff format

- Overall status: ready / not ready
- Commands run
- Pass/fail per command
- Any blockers and next action

## Guardrails

- Never claim readiness if any required check failed or was skipped.
- Do not bypass failing checks by weakening code or tests.
- Keep fixes scoped to issues found by the checks.
