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

The kit default (no `data-theme`) is the rounded / charcoal palette. Named themes (`[data-theme="dark"]`, `ocean`, or your own) should override **brand/semantic** tokens. `[data-theme="rounded"]` is an empty alias of the default. Component tokens are declared on `:root, [data-theme]` as `var(--semantic)`, so they re-resolve when a host puts `data-theme` on `<body>` or another descendant — not only on `<html>`. Do not copy `@theme inline` self-maps (`--token: var(--token)`) onto that selector. `html[data-theme="rounded"]` is `:root`, so those lines blank the token and sidebar `border-r` falls back to `currentColor`.

On that default, `--sidebar-background-color` is `var(--surface-page-background-color)`, so the rail matches the page. `--sidebar-header-background-color` aliases the sidebar token, so the header follows. Dark and ocean set their own sidebar fill. A host that wants a white rail sets `--sidebar-background-color` after FlatPack CSS. Do not assign it on `[data-theme="rounded"]`.

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

`--color-primary` is `oklch(var(--brand-lightness) var(--brand-chroma) var(--brand-hue))`. Hover follows `--color-primary` and subtracts `0.10` from lightness (`oklch(from var(--color-primary) calc(l - 0.1) c h)`), so an exact hex still darkens on hover. Browsers without relative colour syntax keep the brand-knob fallback. Charcoal chroma `0` stays valid. Surfaces keep their own colors unless you override `--surface-*`. `--color-primary-text` stays `#fff` unless you override it.

These follow `--color-primary` (and `--color-primary-text` for text or icons on that fill). You do not set them on a named theme unless you want them to diverge:

- `--color-ring` — focus rings
- `--sidebar-item-active-background-color` / `--top-nav-item-active-background-color` — selected nav fills
- `--button-primary-*`, `--badge-primary-*`, `--tabs-pill-active-*`, `--progress-fill-color`, `--range-fill-color`, `--range-thumb-color`, `--switch-track-checked-background-color`, `--stepper-current-color`, outgoing chat, and other primary-filled controls

The bottom nav bar (`--bottom-nav-background-color`) is a dark surface, not a brand fill. Dark and ocean set their own bar colours. Active bottom-nav *items* use `--bottom-nav-item-active-color` (contrast on that bar), not `--color-primary`.

For an exact brand hex, set `--color-primary`. Hover derives from it; set `--color-primary-hover` only when it should not be `l - 0.10`:

```css
:root {
  --color-primary: #2563eb;
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

--overlay-backdrop-color
--overlay-scrim-color

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

Dark theme (`[data-theme="dark"]`) adds a faint white hairline to `--shadow-sm` / `--shadow-md` / `--shadow-lg` so cards lift on near-black surfaces. Brand dark themes that want the same lift set those shadow tokens; they are not derived from `--surface-*`. Overlay dimming is `--overlay-backdrop-color`; on-media chrome (carousel chevrons) is `--overlay-scrim-color`.

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

`--page-title-h1-size` through `--page-title-h6-size` alias `--text-4xl` down to `--text-base`. `--content-p-size` and `--content-kicker-size` are `--text-lg` (1.125rem / 18px). `--content-lead-size` is `--text-2xl`. `--content-h1-size` is `--text-5xl` (3rem). `--content-h2-size` is `--text-3xl`. `--content-h3-size` through `--content-h6-size` step down the same kit scale to `--text-lg`. Bare tags inside `.fp-content` pick these up. Hero headlines use `--text-4xl` then `sm:` `--hero-headline-size` (default `--text-5xl`). Page-surface hero body uses `--hero-description-size` (default `--text-xl`). Do not add `--text-6xl` or `--text-7xl`; a theme that wants a larger hero sets `--hero-headline-size` to a rem.

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

`--duration-*` are set on `:root`. Hosts load `flat_pack/variables` as a normal stylesheet, and browsers skip `@theme`. `@theme inline` only registers the names for Tailwind. Under `prefers-reduced-motion: reduce`, `--duration-fast`, `--duration-base`, `--duration-slow`, and `--skeleton-shimmer-duration` become `0ms`. Overlay controllers read those tokens through `controllers/flat_pack/reduced_motion` so hide delays match. Spatial motion (scale, slide, fan) is skipped; colour and opacity may still change. Tailwind's built-in `duration-150` / `duration-200` / `duration-300` utilities are not the kit lever; they skip token collapse. Kit surfaces that move should use `duration-[var(--duration-fast)]`, `duration-[var(--duration-base)]`, or `duration-[var(--duration-slow)]`. Do not use `hover:scale-*` on stacked chrome such as Avatar Group. Button press is a 1px translate on `.fp-button`, not `active:scale-*`. Raised styles use `.fp-button-raised`. Ghost, secondary, and `press: :flat` add `.fp-button-flat` for an inset press. Colour uses `--easing-standard`. Alert, chip, and badge removal collapse size through `playCollapseExit` (height for alerts; width and height for chips and badges). Spinner loading is `.fp-spinner`: spin by default, opacity pulse under reduced motion. That pulse is not `--duration-*`, so it keeps beating when other motion collapses.

### Easing
```css
--easing-standard: cubic-bezier(0.2, 0, 0, 1)  /* in-place: hover, toggle, width */
--easing-enter: cubic-bezier(0.05, 0.7, 0.1, 1)  /* decelerate: overlay enter */
--easing-exit: cubic-bezier(0.3, 0, 1, 1)  /* accelerate: overlay exit */
--easing-spring: cubic-bezier(0.34, 1.25, 0.64, 1)  /* list/layout sibling FLIP only */
--easing-spring-snappy: cubic-bezier(0.22, 1.35, 0.36, 1)  /* list/layout drop settle only */
```

`--easing-*` are set on `:root`, for the same reason as durations. Kit overlays use `ease-[var(--easing-enter)]` / `ease-[var(--easing-exit)]`, or `motionTransition()` in Stimulus. In-place motion (switch, progress, sidebar, and the opt-in Tabs/Pill `indicator: :slide` marker) uses `--easing-standard`. Overlay enter/exit stay bounce-free. `--easing-spring` and `--easing-spring-snappy` are the exception for list (and future layout) reorder settle — do not use them on modals, drawers, toasts, popovers, or tooltips.

Use `--easing-enter` for modal, drawer, command palette, toast, dropdown, popover, and tooltip entrance. Use `--easing-exit` for their leave. Modal, drawer, and command palette enter on `--duration-slow` and exit on `--duration-base`. Popover, tooltip, searchable Select, Combobox, and the FlatPack date picker stay on `--duration-base` both ways, with a few pixels of offset from the trigger. Those form panels share `playOverlayEnter` / `playOverlayExit` in `controllers/flat_pack/reduced_motion`, so a close in flight can reverse and `hidden` is applied after the exit duration. Form invalid is colour only; do not shake the field. List orderable sibling shifts use `--easing-spring`; drop settle uses `--easing-spring-snappy`. Under reduced motion, list reorder snaps with no spring.

### Overlay and chrome
```css
--hero-overlay-background-color
--hero-overlay-left-background
--hero-overlay-text-color
--hero-overlay-muted-text-color
--hero-overlay-button-primary-background-color
--hero-overlay-button-primary-hover-background-color
--hero-overlay-button-primary-text-color
--hero-overlay-button-primary-border-color
--hero-overlay-button-secondary-background-color
--hero-overlay-button-secondary-hover-background-color
--hero-overlay-button-secondary-text-color
--hero-overlay-button-secondary-border-color
--hero-overlay-on-light-background-color
--hero-overlay-on-light-left-background
--hero-overlay-on-light-text-color
--hero-overlay-on-light-muted-text-color
--hero-overlay-on-light-button-primary-background-color
--hero-overlay-on-light-button-primary-hover-background-color
--hero-overlay-on-light-button-primary-text-color
--hero-overlay-on-light-button-primary-border-color
--hero-overlay-on-light-button-secondary-background-color
--hero-overlay-on-light-button-secondary-hover-background-color
--hero-overlay-on-light-button-secondary-text-color
--hero-overlay-on-light-button-secondary-border-color
--hero-overlay-min-height
--hero-overlay-copy-padding-top
--hero-headline-size
--hero-description-size

--drawer-backdrop-color
--drawer-surface-color
--drawer-border-color
--drawer-title-color
--drawer-body-color
--drawer-close-icon-color
--drawer-close-icon-hover-color
--drawer-backdrop-blur

--top-nav-height
--top-nav-backdrop-blur
--top-nav-background-color

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

Component tokens such as `--button-primary-background-color` map to semantic tokens (`var(--color-primary)`). `--color-ring` and the active sidebar / top-nav fills do the same. You normally change `--brand-hue` / `--brand-chroma` / `--brand-lightness` or `--color-primary` instead of editing those component tokens.

Alert and toast success/warning/danger wash the status fill into the surface (`color-mix` at 18%) and keep chroma on the icon and border. Info toasts alias the quiet info alert, not `--color-primary`. Buttons, badges, chips, and progress keep the filled `--color-success-*` / `--color-warning-*` / `--color-danger-*` paints. Progress reads those fills through `--progress-*-fill-color` and `.fp-progress-fill`, not Tailwind `bg-primary`. Range input paints the native slider through `.fp-range-input` and `--range-*` tokens, not `accent-color`.

Tabs, chat incoming bubbles, sidebar/top-nav hover, list hover, and avatar fallbacks alias `--surface-muted-*` / `--surface-content-color`. Named themes inherit those greys from the surface tokens; do not freeze Tailwind slate hexes on the component tokens.

Collection Editor aliases the same surface and list tokens. `--collection-editor-title-color` follows `--surface-content-color`. `--collection-editor-description-color` follows `--surface-muted-content-color`. Row hover follows `--list-item-hover-background-color`. The drop indicator follows `--color-primary`. Cell lines follow `--collection-editor-border-color`. Override the `--collection-editor-*` names on a parent when only that collection should change. Named themes inherit these aliases and do not need their own copies.

### Buttons
- Colors: `--color-default-*`, `--color-primary-*`, `--color-secondary-*`, `--color-ghost-*`, `--color-success-*`, `--color-warning-*`
- Local paint: `--fp-button-background`, `--fp-button-hover-background`, `--fp-button-text`, `--fp-button-border`. Built-in `data-fp-style` values map these from `--button-primary-*` and the other scheme tokens. Slot assignment is `[data-fp-style]`. `.fp-button` is still the chrome. A host-registered style sets the paint tokens on `[data-fp-style="…"]` and does not change the theme. See [Button](components/button.md).
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
- Thumb fill aliases `--color-primary` so it tracks brand and `data-theme`. The ring aliases `--surface-background-color` so the handle reads on both the primary fill and the grey track. Disabled uses the native input’s reduced opacity, so the thumb stays muted rather than full primary.
- Size: `--range-track-height`, `--range-thumb-size` (hit target is `--hit-target-min`)
- Runtime fill: `--range-progress` on the input (percentage). Not a theme token.

### Checkbox / Radio
- Colors: `--surface-background-color`, `--surface-border-color`, `--color-primary`, `--color-primary-text`, `--color-ring`
- Checked fill and accent use Tailwind arbitrary values of those tokens (`accent-[var(--color-primary)]`, `checked:bg-[var(--color-primary)]`, `checked:border-[var(--color-primary)]`, `checked:text-[var(--color-primary-text)]`), not bare `*-primary` utilities
- Size: `--checkbox-size` (Checkbox and RadioGroup; `size:` sets sm `1rem` / md `1.25rem` / lg `1.5rem`)
- Radius: `--checkbox-radius` (checkbox); radios stay `rounded-full`
- Label spacing: `--checkbox-label-gap` (checkbox)
- RadioGroup `variant: :swatches` reuses Color Swatch tokens: `--color-swatch-radius`, `--color-swatch-border-color`, `--color-swatch-selected-ring-color` (aliases `--color-ring`), `--color-swatch-ring-offset-color` (aliases `--surface-background-color`), `--color-swatch-shadow`, plus `--color-swatch-check-on-dark` / `--color-swatch-check-on-light` for the selected check. Circle size follows ColorSwatch `:sm` / `:md` / `:lg`, not `--checkbox-size`.

### Color Swatch
- Circle: `--color-swatch-radius` (pill), `--color-swatch-border-color`, `--color-swatch-shadow`
- Selected / focus ring: `--color-swatch-selected-ring-color`, `--color-swatch-ring-offset-color` (gap uses the page background so the ring reads on white and near-black fills)
- Selected check ink on RadioGroup swatches: `--color-swatch-check-on-dark` (light mark on a dark fill), `--color-swatch-check-on-light` (dark mark on a light fill)

### SVG Status Dot Utility
- Utility class: `fp-red-dot` (apply on an `svg` element)
- Dot size: `8px` by `8px`
- Position: top-right (`top: 0`, `right: 0`) with `z-index: 999999999`
- Color token: `--color-danger-background-color`

### Hero, carousel, picker, badge
- Hero `centered_image` overlay: `--hero-overlay-background-color`, `--hero-overlay-left-background`, `--hero-overlay-text-color`, `--hero-overlay-muted-text-color`, `--hero-overlay-button-*`. `on: :light` remaps those to `--hero-overlay-on-light-*`. Min-height is `--hero-overlay-min-height` (`560px`; set `100dvh` to fill the first viewport). Copy sits below a typical TopNav via `--hero-overlay-copy-padding-top`.
- TopNav frost: `--top-nav-backdrop-blur` (applied after scroll). Height is `--top-nav-height` (`72px`).
- Carousel chrome: `--carousel-control-*`, `--carousel-counter-*`, `--carousel-media-background-color`, `--carousel-lightbox-image-background-color`
- Picker grid: `--picker-badge-*`, `--picker-selection-idle-*`, `--picker-selection-indicator-*`
- Badge remove hover: `--badge-remove-hover-background-color` (aliases `--chip-remove-hover-background-color`)
- Card stat trends: `--color-success-background-color`, `--color-danger-background-color`

### FAB
- Main control: `--fab-size` (56px `:md`), `--fab-size-sm` (40px), `--fab-size-lg` (64px)
- Speed-dial glyphs: `--fab-action-size`, `--fab-action-size-sm`, `--fab-action-size-lg`
- Stack gap: `--fab-action-gap` (sm uses `--fab-action-gap-sm`)
- `style: :danger` on a speed-dial action uses `--button-danger-background-color`, `--button-danger-hover-background-color`, and `--button-danger-text-color` — the same tokens TrashButton uses. Default actions keep `--fab-action-*`.

## Dark mode and named themes

See [Dark Mode](dark_mode.md). Built-in variants (`dark`, `ocean`) only override tokens that differ from the default palette. `rounded` is an alias of the default. Component aliases are declared on `:root, [data-theme]` and re-resolve against that element's semantic tokens.

`var()` inside a custom property is computed on the element that declares it. If the kit only declared `--button-primary-background-color: var(--color-primary)` on `:root`, a host that sets `--color-primary` on `<body data-theme="…">` would keep the already-resolved `:root` value. Declaring the same wiring on `[data-theme]` is the generic fix. Prefer `data-theme` on `<html>` when you can; either placement works.

Dark and ocean set `--color-primary` directly. Their focus rings and active nav fills follow that primary. They do not restate `--color-ring`.

## Auditing tokens

```bash
bin/rake flat_pack:audit_tokens
bin/rake flat_pack:audit_radius_language
```

`audit_tokens` fails if any `var(--*)` / Tailwind `bg-(--*)` reference in the gem is missing from `variables.css`. `audit_radius_language` fails if kit Ruby, JavaScript, or gem CSS still uses Tailwind radius scale names (`rounded-md`, `rounded-lg`, and the rest) or the old Tailwind radius fallbacks. It audits `FlatPack::Engine.root`, not a host app.
