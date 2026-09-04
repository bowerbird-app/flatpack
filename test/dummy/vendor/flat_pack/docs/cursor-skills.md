# Cursor Cloud Agent skills

Flatpack Cloud Agents load project skills from the git checkout.

## What is tracked

`.cursor/skills/` holds three layers.

1. The [pstack](https://github.com/cursor/plugins/tree/main/pstack/skills) pack (`poteto-mode`, `how`, `why`, principles, and the rest).
2. Third-party craft skills copied from public raw URLs: `frontend-design`, `design-dna`, `make-interfaces-feel-better`, `motion-design`, `review-animations`, `visual-qa-testing`, `web-design-guidelines`.
3. Flatpack-owned skills: `flatpack-design` (boss of what lands) and `flatpack-micro-interactions` (kit motion patterns).

This repo does not use Recording Studio skills. Do not add `recording-studio-*`. Do not fetch `RecordingStudio_cursor_plugin`. Do not add `micro-interactions`, `interaction-design`, or `ui-ux-pro-max`.

`.cursor/rules/` stays gitignored. Do not invent a Flatpack rules pack. `setup-pstack` may write a local rule when someone runs it.

The gemspec does not package `.cursor/`. Host apps that install the gem do not receive these files. Cloud Agents that clone this repository do.

## How agents pick them up

`.cursor/environment.json` names the environment `flatpack`. `install` is a no-op (`true`). Skills are already in the tree, so Build does not download a pack.

After this layout merges, rebuild the Cloud Agent environment Draft off that commit. A snapshot taken while skills were gitignored will not see them.

## Working sequence

Use this order on Flatpack UI work:

1. Pstack (`poteto-mode` and the rest) for how the agent works.
2. Frontend Design for a distinctive direction. Open Design DNA only when there is a visual reference to extract from.
3. `flatpack-design` decides what lands. Output is ViewComponents, tokens, named themes, and presets.
4. Make Interfaces Feel Better and Motion Design advise craft (timing, easing, type, surfaces).
5. `flatpack-micro-interactions` turns that advice into kit tokens and component patterns.
6. Visual QA on the live dummy demo.
7. Review Animations on the motion you shipped.
8. Web Design Guidelines for the accessibility and interface pass.

## Muzzles

**Design DNA.** Extract measurable system into Flatpack tokens and themes: colour, type, space, radius, elevation, motion duration and easing. Do not implement DNA `visual_effects` (WebGL, particles, shaders, Canvas, scroll theatres, cursor trails) unless Nic explicitly asks for a Flatpack-owned effect later.

**Motion.** Advise timing, easing, and choreography. Implement with Flatpack CSS and `--duration-*` tokens. Do not default to Framer, GSAP, or Lottie.

## Refreshing pstack

Copy from the public pstack tree. Use the GitHub contents API and raw file URLs. Do not clone.

- Contents: `https://api.github.com/repos/cursor/plugins/contents/pstack/skills?ref=main&per_page=100`
- Raw file: `https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/<id>/...`

Replace the pstack directories only. Leave Flatpack-owned and third-party craft skills in place. Do not rewrite the files.
