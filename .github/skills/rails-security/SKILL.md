---
name: rails-security
description: Audit and remediate Rails security risks with minimal safe changes.
---

# Rails Security Skill

## Use when

- Requests involve security review, input handling, authorization, or data safety.

## Required checks

- Input validation and strong parameter handling
- SQL/command injection and unsafe interpolation
- XSS risks in views/helpers and rendering paths
- CSRF protections and controller safety defaults
- Authentication/authorization assumptions and gaps
- File/path handling and unsafe IO
- Unsafe deserialization and parser usage
- Secrets handling and sensitive-data logging
- Tenant/data isolation where applicable

## Workflow

1. Triage likely trust boundaries and attack surfaces.
2. Document findings by severity.
3. Apply only approved or safe auto-fix changes.
4. Add targeted regression tests for fixed issues.
5. Report residual risk and follow-up recommendations.

## Guardrails

- Never weaken existing defenses.
- Never log secrets or credentials.
- Avoid unrelated refactors.
- Preserve public APIs unless security requires a change.
