# Theming Guide

FlatPack uses CSS variables for theming, allowing you to customize the appearance without modifying component code.

## Token hierarchy

```text
Brand primitives (--brand-hue, --brand-chroma, --brand-lightness)
    ↓
    Semantic tokens (--color-*, --surface-*, --radius-*, --shadow-*, --font-*, --text-*, --duration-*, --easing-*, --icon-*)
    ↓
Component tokens (--button-*, --sidebar-*, …) — defined once as var(--semantic)
    ↓
Components / Stimulus
```

The kit default (no `data-theme`) is the rounded / charcoal palette. Named themes (`[data-theme="dark"]`, `ocean`, or your own) should override **brand/semantic** tokens. `[data-theme="rounded"]` is an empty alias of the default. Component tokens inherit automatically.

If you want a complete copy-pasteable custom theme with every current FlatPack variable, use the [Custom Theming Guide](custom_theming.md). Prefer the brand-kit path below for most apps.

## Fastest path: change the brand color

```bash
bin/rails generate flat_pack:theme Sunrise --hue=35 --chroma=0.2 --lightness=0.52
```

That writes `app/assets/stylesheets/flat_pack_theme_sunrise.css`. Load it after `flat_pack/variables`, then set `<html data-theme="sunrise">` (or use the `flat-pack--theme` controller). Pass `--as_root` to write brand overrides on `:root` instead, so no `data-theme` attribute is needed.

Or override primitives directly:

```css
:root {
  --brand-hue: 160;
  --brand-chroma: 0.18;
  --brand-lightness: 0.52;
}
```

`--color-primary` is `oklch(var(--brand-lightness) var(--brand-chroma) var(--brand-hue))`. Hover subtracts `0.10` from lightness only, so charcoal chroma `0` stays valid. Surfaces keep their own colors unless you override `--surface-*`.

For an exact brand hex, set the semantic tokens instead:

```css
:root {
  --color-primary: #2563eb;
  --color-primary-hover: #1d4ed8;
}
```

## Shared names with a host Tailwind app

FlatPack does **not** rename `--color-primary` to `--fp-color-primary`. That name is the public override API: host CSS loaded after `flat_pack/variables` wins, so one brand color can drive both the app and FlatPack.

Do **not** put FlatPack tokens back into the Tailwind entry. A second `--color-primary` (or `--color-fp-*`) inside a host `@theme` is what used to clash and circular-map. The kit registers names with `@theme inline` and keeps concrete values on `:root`.

| Situation | What to do |
|---|---|
| Host has no `--color-primary` | Nothing. FlatPack defines it. |
| Host wants the same primary as FlatPack | Set `--color-primary` in the host stylesheet (last). That is an override, not a clash. |
| Host needs a different primary than FlatPack | Keep the host color as `--my-app-primary` (or similar). Leave `--color-primary` for FlatPack, or set it only if you intend FlatPack to match. |
| Host already uses `--color-primary` for something else | Rename the **host** token. Do not rename FlatPack's. |
| Host Tailwind loads after kit CSS | Tailwind `@layer theme` sets `--font-sans` to `ui-sans-serif` and `--radius-md` to `0.375rem`. Re-set `--font-sans` / `--font-mono` and `--radius-sm` / `--radius-md` / `--radius-lg` / `--radius-xl` on unlayered `:root` in the host stylesheet so the kit face and kit radii win. Putting them in `@theme` does not replace Tailwind’s defaults. `var(--radius-md, 1rem)` in kit CSS only applies when the token is unset. |

`--brand-hue` / `--brand-chroma` / `--brand-lightness` are FlatPack-only and do not overlap Tailwind defaults. `--radius-md` and `--shadow-md` use the same names as Tailwind utilities. FlatPack's default radii are the larger rounded scale (`1rem` for `--radius-md`). Kit class names use `rounded-[var(--radius-*)]` so they do not collide with Tailwind's `rounded-md` scale.

## Overview

FlatPack's theming system is built on:
- Tailwind CSS 4's `@theme inline` directive (token names for utilities; values stay on `:root`)
- CSS custom properties (variables)
- OKLCH color space for perceptual uniformity
- Default `:root` wiring plus slim `data-theme` overrides

## Basic Customization

FlatPack variables are loaded via `stylesheet_link_tag` in your layout (added by the install generator). Prefer brand primitives; override semantics only when needed:

```css
/* app/assets/stylesheets/application.css */

:root {
  --brand-hue: 270;
  --brand-chroma: 0.22;
  --brand-lightness: 0.52;
  /* Optional fine-tuning */
  --color-primary-text: oklch(1 0 0);
}
```

For a named host-app variant such as `[data-theme="sunrise"]`, see the theme generator or the [Custom Theming Guide](custom_theming.md).

## Available Variables

### Brand primitives
```css
--brand-hue
--brand-chroma
--brand-lightness
```

### Semantic Colors
```css
--color-default
--color-default-hover
--color-default-text
--color-default-border

--color-primary
--color-primary-hover
--color-primary-text

--color-secondary
--color-secondary-hover
--color-secondary-text

--color-ghost
--color-ghost-hover
--color-ghost-text

--color-success-background-color
--color-success-hover-background-color
--color-success-text
--color-success-border

--color-warning-background-color
--color-warning-hover-background-color
--color-warning-text
--color-warning-border

--color-danger-background-color
--color-danger-hover-background-color
--color-danger-text-color
--color-danger-border-color
--color-error
--color-error-border

--surface-background-color
--surface-page-background-color
--surface-content-color
--surface-subtle-background-color

--surface-muted-background-color
--surface-muted-content-color

--surface-border-color
--surface-border-hover-color

--color-ring
```

The kit does not ship `--gradient-1` … `--gradient-4` or `.fp-gradient-*`. Named host themes may define those tokens if they want a decorative wash. Heroes and cards stay on surface tokens unless the host asks.

### Icons
```css
--icon-stroke-width: 1.5
```

Outline Heroicons follow `--icon-stroke-width`. Solid, mini, and micro variants are fills and ignore it. TipTap bold/italic/underline/strike stay `2.5` so the 14px glyphs still read. Button spinner rings stay `4`. Empty-state optional icons use `IconComponent`.

`IconComponent` optically nudges handle-heavy artwork (`magnifying-glass`, `paper-airplane`, `pencil`, `pencil-square`, `arrow-up-tray`, `arrow-down-tray`) with `-translate-y-0.5`. Add names to `OPTICAL_NUDGES` instead of per-component CSS.

Left/right travel and alignment glyphs get `.fp-icon-directional`. In `[dir="rtl"]` they flip with CSS `scale: -1 1` so a translate nudge still applies. Vertical chevrons, checks, media playback, and chat-bubble tails do not flip.

### Spacing Variables
```css
--stack-gap-sm: 0.5rem
--stack-gap-md: 1rem
--stack-gap-lg: 1.5rem
--overflow-row-gap: var(--stack-gap-md)
--overflow-row-fade-size: 2rem
```

Use stack gap tokens on parent layout containers (for example, form stacks) to control spacing between components.

### Border Radius
```css
--radius-sm: 0.75rem
--radius-md: 1rem
--radius-lg: 1.5rem
--radius-xl: 2rem
```

Kit surfaces use `rounded-[var(--radius-sm)]` through `rounded-[var(--radius-xl)]`, or a component alias such as `--button-border-radius`. Rich text and content editor CSS use `var(--radius-md, 1rem)` / `var(--radius-sm, 0.75rem)` so toolbar and bubble chrome match those tokens. Do not use Tailwind's `rounded-sm` / `rounded-md` / `rounded-lg` / `rounded-xl` / `rounded-2xl` in kit components. Those names share `--radius-*` with FlatPack and hide which scale is in play. Keep `rounded-full` for pills and avatars, and `rounded-none` for segmented groups.

If host Tailwind loads after `flat_pack/variables`, re-set the four kit radii on unlayered `:root` (same block as `--font-sans`):

```css
:root {
  --radius-sm: 0.75rem;
  --radius-md: 1rem;
  --radius-lg: 1.5rem;
  --radius-xl: 2rem;
}
```

`Button` already skips its default radius when the host passes a `rounded-*` class. Other components merge with last-wins, so a host `class: "rounded-xl"` on Card does not replace the kit token. Kit maintainers run `bin/rake flat_pack:audit_radius_language` from this repo. That task audits the gem, not host markup. Remap leftovers with `ruby scripts/rewrite_radius_language.rb` in a checkout of this repository. The gem package does not ship `scripts/`.

`--chip-border-radius` (`0.5rem`) and `--checkbox-radius` (`0.125rem`) stay as named component tokens off the four-step scale.

### Shadows
```css
--shadow-sm
--shadow-md
--shadow-lg
--shadow-button
--shadow-button-active
```

`--button-shadow` is the rest elevation. `--button-shadow-hover` aliases `--shadow-button`. `--button-shadow-active` aliases `--shadow-button-active`. Ghost and secondary stay unshadowed at rest.

Dark theme (`[data-theme="dark"]`) adds a faint white hairline to `--shadow-sm` / `--shadow-md` / `--shadow-lg` so cards lift on near-black surfaces.

### Hit targets
```css
--hit-target-min: 2.75rem   /* 44px — icon-only buttons, modal close, alert dismiss */
--hit-target-inline-min: 1.5rem  /* 24px — chip and badge remove */
```

Kit CSS defines `.fp-hit-target`, `.fp-hit-target-inline`, and `.fp-hit-slop`. `.fp-hit-target` grows the painted box to 44px. `.fp-hit-slop` keeps the control icon-sized and expands the hit with a pseudo-element — toast close uses that so the X is not a 44px empty square. Hosts get those classes from `flat_pack/application` without a Tailwind rebuild.

### Color scheme
`:root` sets `color-scheme: light`. `[data-theme="dark"]` sets `color-scheme: dark` so native controls, scrollbars, and form chrome match the theme.

### Typography
```css
--font-sans: system-ui, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji"
--font-mono: ui-monospace, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace

--text-xs: 0.75rem
--text-sm: 0.875rem
--text-base: 1rem
--text-lg: 1.125rem
--text-xl: 1.25rem
--text-2xl: 1.5rem
--text-3xl: 1.875rem
--text-4xl: 2.25rem
--text-5xl: 3rem

--leading-tight: 1.25
--leading-snug: 1.375
--leading-normal: 1.5
```

`--font-*` and `--text-*` are set on `:root` (not only inside `@theme`). `:root` also sets `font-family: var(--font-sans)` and antialiased smoothing. Hosts override `--font-sans` with a brand face. There is no kit webfont. If host Tailwind loads last, re-set `--font-sans` and the kit `--radius-*` values on unlayered `:root` in the host stylesheet — Tailwind’s `@layer theme` stack otherwise replaces the kit face and the kit radii (rich-text chrome follows `--radius-md`).

`--page-title-h1-size` through `--page-title-h6-size` alias `--text-4xl` down to `--text-base`.

Kit CSS defines `.fp-tabular-nums` (`font-variant-numeric: tabular-nums`), `.fp-text-balance`, and `.fp-text-pretty`. Use tabular nums on live numbers (pagination, meters, timestamps, chart axes). Use balance on titles. Use pretty on short supporting copy. Labels are sentence case — do not force `uppercase tracking-widest` on taglines, table headers, or section titles. Avatar initials may stay `uppercase`.

### Durations / transitions
```css
--duration-fast: 150ms
--duration-base: 200ms
--duration-slow: 300ms

/* Aliases — prefer --duration-* in new code */
--transition-fast: var(--duration-fast)
--transition-base: var(--duration-base)
--transition-slow: var(--duration-slow)
```

`--duration-*` are set on `:root`. Hosts load `flat_pack/variables` as a normal stylesheet, and browsers skip `@theme`. `@theme inline` only registers the names for Tailwind. Under `prefers-reduced-motion: reduce`, `--duration-fast`, `--duration-base`, `--duration-slow`, and `--skeleton-shimmer-duration` become `0ms`. Overlay controllers read those tokens through `controllers/flat_pack/reduced_motion` so hide delays match. Spatial motion (scale, slide, fan) is skipped; colour and opacity may still change. Tailwind's built-in `duration-150` / `duration-200` / `duration-300` utilities are not the kit lever; they skip token collapse. Kit surfaces that move should use `duration-[var(--duration-fast)]`, `duration-[var(--duration-base)]`, or `duration-[var(--duration-slow)]`. Do not use `hover:scale-*` on stacked chrome such as Avatar Group. Spinner loading is `.fp-spinner`: spin by default, opacity pulse under reduced motion. That pulse is not `--duration-*`, so it keeps beating when other motion collapses.

### Easing
```css
--easing-standard: cubic-bezier(0.2, 0, 0, 1)  /* in-place: hover, toggle, width */
--easing-enter: cubic-bezier(0.05, 0.7, 0.1, 1)  /* decelerate: overlay enter */
--easing-exit: cubic-bezier(0.3, 0, 1, 1)  /* accelerate: overlay exit */
```

`--easing-*` are set on `:root`, for the same reason as durations. Kit overlays use `ease-[var(--easing-enter)]` / `ease-[var(--easing-exit)]`, or `motionTransition()` in Stimulus. In-place motion (switch, progress, sidebar) uses `--easing-standard`. There is no bounce: charcoal / rounded is Corporate/Premium, not Playful.

Use `--easing-enter` for modal, drawer, command palette, toast, dropdown, popover, and tooltip entrance. Use `--easing-exit` for their leave. Modal, drawer, and command palette enter on `--duration-slow` and exit on `--duration-base`. Popover, tooltip, searchable Select, Combobox, and the FlatPack date picker stay on `--duration-base` both ways, with a few pixels of offset from the trigger. Those form panels share `playOverlayEnter` / `playOverlayExit` in `controllers/flat_pack/reduced_motion`, so a close in flight can reverse and `hidden` is applied after the exit duration. Form invalid is colour only; do not shake the field.

### Overlay and chrome
```css
--hero-overlay-background-color
--hero-overlay-text-color
--hero-overlay-muted-text-color

--drawer-backdrop-color
--drawer-surface-color
--drawer-border-color
--drawer-title-color
--drawer-body-color
--drawer-close-icon-color
--drawer-close-icon-hover-color
--drawer-backdrop-blur

--kbd-background-color
--kbd-border-color
--kbd-text-color
--kbd-muted-color
--kbd-shadow

--skip-link-background-color
--skip-link-text-color

--stepper-current-color
--stepper-complete-color
--stepper-complete-text-color
--stepper-upcoming-color
--stepper-label-color
--stepper-muted-color

--progress-fill-color
--progress-success-fill-color
--progress-warning-fill-color
--progress-danger-fill-color

--range-track-color
--range-fill-color
--range-thumb-color
--range-thumb-border-color
--range-thumb-shadow
--range-thumb-size
--range-track-height
```

Drawer tokens alias Modal. Keyboard, skip link, and stepper tokens alias surface and brand colours so named themes inherit. Hero overlay, carousel media/controls, picker grid badges, and badge remove-hover are themeable instead of hardcoded black/white Tailwind utilities.

## Component Variable Usage

Component tokens such as `--button-primary-background-color` map to semantic tokens (`var(--color-primary)`). You normally change `--brand-hue` / `--brand-chroma` / `--brand-lightness` or `--color-primary` instead of editing component tokens.

Alert and toast success/warning/danger wash the status fill into the surface (`color-mix` at 18%) and keep chroma on the icon and border. Info toasts alias the quiet info alert, not `--color-primary`. Buttons, badges, chips, and progress keep the filled `--color-success-*` / `--color-warning-*` / `--color-danger-*` paints. Progress reads those fills through `--progress-*-fill-color` and `.fp-progress-fill`, not Tailwind `bg-primary`. Range input paints the native slider through `.fp-range-input` and `--range-*` tokens, not `accent-color`.

Tabs, chat incoming bubbles, sidebar/top-nav hover, list hover, and avatar fallbacks alias `--surface-muted-*` / `--surface-content-color`. Named themes inherit those greys from the surface tokens; do not freeze Tailwind slate hexes on the component tokens.

### Buttons
- Colors: `--color-default-*`, `--color-primary-*`, `--color-secondary-*`, `--color-ghost-*`, `--color-success-*`, `--color-warning-*`
- Radius: `--radius-md`
- Shadow: `--button-shadow`, `--button-shadow-hover`, `--button-shadow-active`
- Duration: `--duration-fast` for colour, border, and shadow
- Easing: `--easing-standard`

### Input Components (Text, Email, Password, Phone, Search, URL, TextArea)
- Colors: `--surface-content-color`, `--surface-background-color`, `--surface-muted-content-color`, `--surface-border-color`, `--color-ring`, `--color-error` (invalid chrome; aliases `--color-danger-background-color`)
- Radius: `--radius-md`
- Duration: `--duration-base`
- Easing: `--easing-standard` (invalid chrome is colour only; no shake)

### Range Input
- Kit class: `.fp-range-input`
- Track / fill / thumb: `--range-track-color`, `--range-fill-color`, `--range-thumb-color`, `--range-thumb-border-color`, `--range-thumb-shadow`
- Size: `--range-track-height`, `--range-thumb-size` (hit target is `--hit-target-min`)
- Runtime fill: `--range-progress` on the input (percentage). Not a theme token.

### Checkbox
- Colors: `--surface-background-color`, `--surface-border-color`, `--color-primary`, `--color-ring`
- Size: `--checkbox-size`
- Radius: `--checkbox-radius`
- Label spacing: `--checkbox-label-gap`

### SVG Status Dot Utility
- Utility class: `fp-red-dot` (apply on an `svg` element)
- Dot size: `8px` by `8px`
- Position: top-right (`top: 0`, `right: 0`) with `z-index: 999999999`
- Color token: `--color-danger-background-color`

### Hero, carousel, picker, badge
- Hero `centered_image` overlay: `--hero-overlay-background-color`, `--hero-overlay-text-color`, `--hero-overlay-muted-text-color`
- Carousel chrome: `--carousel-control-*`, `--carousel-counter-*`, `--carousel-media-background-color`, `--carousel-lightbox-image-background-color`
- Picker grid: `--picker-badge-*`, `--picker-selection-idle-*`, `--picker-selection-indicator-*`
- Badge remove hover: `--badge-remove-hover-background-color` (aliases `--chip-remove-hover-background-color`)
- Card stat trends: `--color-success-background-color`, `--color-danger-background-color`

## Dark mode and named themes

See [Dark Mode](dark_mode.md). Built-in variants (`dark`, `ocean`) only override tokens that differ from `:root`. `rounded` is an alias of the default. Component aliases stay on `:root` and inherit.

## Auditing tokens

```bash
bin/rake flat_pack:audit_tokens
bin/rake flat_pack:audit_radius_language
```

`audit_tokens` fails if any `var(--*)` / Tailwind `bg-(--*)` reference in the gem is missing from `variables.css`. `audit_radius_language` fails if kit Ruby, JavaScript, or gem CSS still uses Tailwind radius scale names (`rounded-md`, `rounded-lg`, and the rest) or the old Tailwind radius fallbacks. It audits `FlatPack::Engine.root`, not a host app.
