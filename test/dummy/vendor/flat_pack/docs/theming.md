# Theming Guide

FlatPack uses CSS variables for theming, allowing you to customize the appearance without modifying component code.

## Token hierarchy

```text
Brand primitives (--brand-hue, --brand-chroma, --brand-lightness)
    ↓
Semantic tokens (--color-*, --surface-*, --radius-*, --shadow-*, --duration-*)
    ↓
Component tokens (--button-*, --sidebar-*, …) — defined once as var(--semantic)
    ↓
Components / Stimulus
```

Named themes (`[data-theme="dark"]`, `ocean`, `rounded`, or your own) should override **brand/semantic** tokens. Component tokens inherit automatically.

If you want a complete copy-pasteable custom theme with every current FlatPack variable, use the [Custom Theming Guide](custom_theming.md). Prefer the brand-kit path below for most apps.

## Fastest path: change the brand color

```bash
bin/rails generate flat_pack:theme Sunrise --hue=35 --chroma=0.2 --lightness=0.52
```

That writes `app/assets/stylesheets/flat_pack_theme_sunrise.css`. Load it after `flat_pack/variables`, then set `<html data-theme="sunrise">` (or use the `flat-pack--theme` controller).

Or override primitives directly:

```css
:root {
  --brand-hue: 160;
  --brand-chroma: 0.18;
  --brand-lightness: 0.52;
}
```

`--color-primary` is `oklch(var(--brand-lightness) var(--brand-chroma) var(--brand-hue))`. Hover is 0.10 darker. Surfaces pick up `--brand-hue` only; they keep their own lightness.

For an exact brand hex, set the semantic tokens instead:

```css
:root {
  --color-primary: #2563eb;
  --color-primary-hover: #1d4ed8;
}
```

## Shared names with a host Tailwind app

FlatPack does **not** rename `--color-primary` to `--fp-color-primary`. That name is the public override API: host CSS loaded after `flat_pack/variables` wins, so one brand color can drive both the app and FlatPack.

Do **not** put FlatPack tokens back into the Tailwind entry. A second `--color-primary` (or `--color-fp-*`) inside `@theme` is what used to clash and circular-map.

| Situation | What to do |
|---|---|
| Host has no `--color-primary` | Nothing. FlatPack defines it. |
| Host wants the same primary as FlatPack | Set `--color-primary` in the host stylesheet (last). That is an override, not a clash. |
| Host needs a different primary than FlatPack | Keep the host color as `--my-app-primary` (or similar). Leave `--color-primary` for FlatPack, or set it only if you intend FlatPack to match. |
| Host already uses `--color-primary` for something else | Rename the **host** token. Do not rename FlatPack's. |

`--brand-hue` / `--brand-chroma` / `--brand-lightness` are FlatPack-only and do not overlap Tailwind defaults. `--radius-md` and `--shadow-md` use the same names as Tailwind utilities; FlatPack's defaults match Tailwind's (`0.375rem` for `--radius-md`).

## Overview

FlatPack's theming system is built on:
- Tailwind CSS 4's `@theme` directive (token inventory for utilities)
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

--surface-background-color
--surface-page-background-color
--surface-content-color
--surface-subtle-background-color

--surface-muted-background-color
--surface-muted-content-color

--surface-border-color
--surface-border-hover-color

--gradient-1
--gradient-2
--gradient-3
--gradient-4

--color-ring
```

### Spacing Variables
```css
--stack-gap-sm: 0.5rem
--stack-gap-md: 1rem
--stack-gap-lg: 1.5rem
```

Use stack gap tokens on parent layout containers (for example, form stacks) to control spacing between components.

### Border Radius
```css
--radius-sm: 0.25rem
--radius-md: 0.375rem
--radius-lg: 0.5rem
--radius-xl: 0.75rem
```

### Shadows
```css
--shadow-sm
--shadow-md
--shadow-lg
```

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

## Component Variable Usage

Component tokens such as `--button-primary-background-color` map to semantic tokens (`var(--color-primary)`). You normally change `--brand-hue` / `--brand-chroma` / `--brand-lightness` or `--color-primary` instead of editing component tokens.

### Buttons
- Colors: `--color-default-*`, `--color-primary-*`, `--color-secondary-*`, `--color-ghost-*`, `--color-success-*`, `--color-warning-*`
- Radius: `--radius-md`
- Shadow: `--shadow-sm`
- Duration: `--duration-base`

### Input Components (Text, Email, Password, Phone, Search, URL, TextArea)
- Colors: `--surface-content-color`, `--surface-background-color`, `--surface-muted-content-color`, `--surface-border-color`, `--color-ring`, `--color-warning-border`
- Radius: `--radius-md`
- Duration: `--duration-base`

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

## Dark mode and named themes

See [Dark Mode](dark_mode.md). Built-in variants (`dark`, `ocean`, `rounded`) only override tokens that differ from `:root`. Component aliases stay on `:root` and inherit.

## Auditing tokens

```bash
bin/rake flat_pack:audit_tokens
```

Fails if any `var(--*)` / Tailwind `bg-(--*)` reference in the gem is missing from `variables.css`.
