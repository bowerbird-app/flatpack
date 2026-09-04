---
name: flatpack-design
description: "Decide what lands for Flatpack UI, themes, tokens, and components. Use on any Flatpack visual work, or when Frontend Design, Design DNA, Motion Design, or Make Interfaces Feel Better propose visuals. Output is Flatpack ViewComponents, tokens, named themes, and presets."
---

# Flatpack design

You are the boss of what ships in this repo. Other design skills may advise. This skill decides.

## When to use

Any Flatpack UI, theme, token, or component work. Any time another design skill proposes a look.

## What Flatpack is

Flatpack is ViewComponents, CSS tokens, and named themes (`data-theme`). Search this repo and https://flatpack.bowerbird.io/ before you write markup.

Do not add a gem one-off. Do not put custom CSS or Tailwind in a host when Flatpack should own the piece. If the kit is missing a part, stop and ask whether to add it here. Dummy default is `html data-theme="rounded"` plus core `UsesDefaultLayout`. Hosts use a named theme, not forked CSS.

## One PR per step

One visual change per PR. Screenshot the live dummy demo for the component you changed, before and after. A render of markup is not the check. Confirm CSS loaded.

## Boss rule

Frontend Design, Design DNA, Motion Design, and Make Interfaces Feel Better may advise. `flatpack-design` decides what lands.

Output is Flatpack components, tokens, themes, and presets. Not ad-hoc markup. Not a second styling system.

## Design DNA muzzle

Allow extract of the measurable system into Flatpack tokens and themes: colour, type, space, radius, elevation, motion duration and easing.

Forbid implementing DNA `visual_effects` (WebGL, particles, shaders, Canvas, scroll theatres, cursor trails) unless Nic explicitly asks for a Flatpack-owned effect later.

## Motion muzzle

Advise timing, easing, and choreography only. Implement with Flatpack CSS and token transitions. Do not default to Framer, GSAP, or Lottie.

Today the kit has `--duration-fast` (150ms), `--duration-base` (200ms), `--duration-slow` (300ms), `--easing-standard` / `--easing-enter` / `--easing-exit`, and `--transition-*` aliases. Prefer `--duration-*` and `--easing-*` in new code. Do not sprinkle keyframes in a host app.

## Taste bar

WOW, not templated AI UI. Review as a designer: type, space, weight, colour. "Kit rules passed" is not enough.

Pair with `flatpack-micro-interactions` for hover, press, focus, loading, and enter/exit. Run Visual QA and Review Animations after the look is in the kit.
