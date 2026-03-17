---
name: delivery-orchestration
description: Coordinate multi-domain implementation quality gates, verification, and release classification checks.
---

# Delivery Orchestration Skill

## Use when

- Requests span multiple domains and need coordinated execution or pre-merge hardening.

## Responsibilities

- Classify work by domains (implementation, security, tests, UI, review).
- Sequence work to minimize risk and rework.
- Ensure required quality checks run before handoff.
- Verify release impact classification and surface ambiguity.

## Verification checklist

- `bundle exec rubocop -A` (auto-correct style offenses after all code changes)
- `bundle exec rubocop` (verify no remaining offenses)
- `bundle exec rake app:test`
- If dummy boot/assets/migrations changed:
  - from `test/dummy`: `bundle exec rake db:migrate RAILS_ENV=test`
  - from `test/dummy`: `bundle exec rails tailwindcss:build`

## Release classification

- Ensure commit/PR metadata supports expected release type.
- If release scope is ambiguous, request confirmation or document conservative assumption.

## Guardrails

- Do not push with failing required checks unless blocked and clearly reported.
- Keep coordination concise and outcome-focused.
