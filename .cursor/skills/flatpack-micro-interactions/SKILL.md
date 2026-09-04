---
name: flatpack-micro-interactions
description: "Reusable Flatpack motion tokens and component patterns for buttons, icons, toggles, popovers, modals, toasts, forms, lists, skeletons, and empty states. Use for hover, press, focus, loading, success, error, or any micro-animation in Flatpack. Ship into the kit, not a host app."
---

# Flatpack micro-interactions

Ship motion as kit tokens and component patterns. Do not sprinkle animation in a consumer app.

Pair with Motion Design and Make Interfaces Feel Better for craft. Use Review Animations for QA after. `flatpack-design` still decides what lands. Framer, GSAP, and Lottie are out unless `flatpack-design` says otherwise.

## When to use

Button, icon, toggle, popover, modal, toast, form, list, skeleton, or empty-state work. Hover, press, focus, loading, success, or error. Any micro-animation in Flatpack.

## Tokens

Reuse the kit. Do not invent a parallel timing scale.

Existing:

- `--duration-fast` 150ms. Hover, colour, icon rotate.
- `--duration-base` 200ms. Press, toggle, tooltip, form invalid.
- `--duration-slow` 300ms. Modal, drawer, toast, list insert/remove, skeleton-to-content.
- `--transition-fast` / `--transition-base` / `--transition-slow` alias `--duration-*`. Prefer `--duration-*` in new code.

If easing needs a name, add `--easing-standard`, `--easing-enter`, `--easing-exit` on the theme in a Flatpack PR. Map enter to decelerate, exit to accelerate, in-place to standard. Until those tokens exist, use CSS transitions on the component, still keyed to `--duration-*`.

Every pattern below has a `prefers-reduced-motion: reduce` branch: duration 0 or a colour/opacity cut with no transform.

## Patterns

Implement these on the Flatpack component, not in the host.

**Button hover.** Colour and shadow on `--duration-fast`. No scale-up that shifts layout.

**Button press.** Translate or shadow inset on `--duration-fast`. Keep the hit target still.

**Button loading.** Swap label for the kit spinner. Disable the control. Do not bounce the button.

**Button success / error.** Flash using `--color-success-*` / `--color-error-*` (or the theme's status tokens) on `--duration-base`, then return. Do not invent a second button type for a one-shot state.

**Icon change / rotate.** Crossfade or rotate 180° on `--duration-fast` (TopNav chevron already does this). Keep the box size fixed.

**Toggle and checkbox.** Thumb/check on `--duration-base`. Reduced motion: snap the state, keep the colour change.

**Dropdown, tooltip, popover.** Opacity plus a few pixels of offset on `--duration-base`. Origin is the trigger, not the viewport centre. Interruptible: a close in flight cancels the open.

**Modal and drawer.** Backdrop opacity and panel offset on `--duration-slow`. Drawer from its edge. Modal from a small scale plus fade, not a bounce. `modal-backdrop-blur` already exists. Reduced motion: fade only.

**Toast / notification.** Enter from the stack edge on `--duration-slow`. Exit faster (`--duration-base`). Respect the toast controller's existing reduced-motion check.

**Form validation.** Border and help text colour on `--duration-base`. Do not shake the field.

**List insert / remove.** Height plus opacity on `--duration-slow`. Reduced motion: snap.

**Skeleton to content.** Crossfade on `--duration-slow`. Stop `--skeleton-shimmer-duration` when content is in. Reduced motion: no shimmer, static skeleton then snap.

**Empty and success states.** Fade the empty illustration out and the content in on `--duration-slow`. No confetti.

## Reduced motion

For each pattern, `prefers-reduced-motion: reduce` must do something a person can perceive as instant: colour or opacity, no transform, no shimmer, no autoplay (Carousel already skips autoplay). Test both branches on the dummy demo.

## How to ship

Change the ViewComponent and its tokens. Add or extend the dummy demo. One PR per component family. Screenshot before and after with CSS loaded.

Do not add keyframes in a host app to fake these. If the kit cannot express the motion yet, stop. Propose the token or component change. Do not invent a Flatpack UI PR from a skills task.
