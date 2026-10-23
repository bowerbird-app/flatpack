# Custom Theming

FlatPack uses inset rings for selected, active, drag, and focus-visible states. Keep focus-ring color tokens sufficiently distinct from their component backgrounds so the indicator remains accessible inside overflow-clipped containers.

FlatPack ships with a default rounded / charcoal palette on `:root, [data-theme]` and additional named variants under `data-theme` selectors. You can add your own named theme by defining a new selector such as `[data-theme~="sunrise"]` in your host app stylesheet and overriding the same variables FlatPack already uses.

Use this guide when you want a complete starting point instead of hand-picking a few overrides.

## How Custom Themes Work

FlatPack's theming surface has three layers:

- `@theme inline {}` in `flat_pack/variables.css` registers the Tailwind token inventory (including `--brand-hue` / `--brand-chroma` / `--brand-lightness`) without copying values.
- `:root, [data-theme] {}` in the same file is the single source of concrete values: the default rounded / charcoal palette **and** component token wiring (`--button-primary-*` → `var(--color-primary)`, etc.). Repeating the wiring on `[data-theme]` re-resolves those aliases when `data-theme` is on `<body>` or another descendant, not only on `<html>`.
- `[data-theme~="rounded"]` shifts `--space-2`…`--space-6`, a few menu shells, and component radii (buttons, the outlined button group, badges, tabs, and the chat composer become `--radius-full`; chips, sidebar items, and menu items stay `--radius-md`; cards, menus, popovers, modals, alerts, and toasts become `--radius-xl`). It sets `--card-border-width: 0` and `--card-shadow: var(--shadow-sm)`. It does not restate colour or the global `--radius-*` steps. Dark and ocean inherit the compact scale and the moderate shape. The default card is a 1px border and `--card-shadow: none`.
- `[data-theme~="..."]` selectors override **only** tokens that differ from the default (semantic / intentional exceptions). Component aliases re-resolve.
- `--fp-button-*` are per-button paint tokens. Do not copy them onto a named theme. A host or gem registers a button style and paints those tokens on `[data-fp-style]`. `.fp-button` is still the chrome. See [Button](components/button.md).

For most apps, generate a brand kit instead of copying every variable:

```bash
bin/rails generate flat_pack:theme sunrise --hue=35 --chroma=0.2 --lightness=0.52
```

That means a custom host-app theme is usually just brand/semantic overrides:

```css
[data-theme~="sunrise"] {
  --brand-hue: 35;
  --brand-chroma: 0.19;
  --brand-lightness: 0.52;
  --surface-background-color: oklch(0.99 0.01 80);
}
```

For an exact primary hex, set `--color-primary` and `--color-primary-text` on the element that should rebrand. Primary button rest, text, border, hover, and pressed follow. Hover mixes that colour 88% toward black on a light page and toward white in dark. Pressed mixes at 80%. Set `--color-primary-hover` only when hover should diverge. `--button-primary-hover-background-color` wins over that pin. Ocean still sets `--color-primary-hover` to `oklch(0.42 0.18 220)`. Focus rings (`--color-ring`) follow the palette `--color-primary` and do not follow a nested wrapper. Active sidebar and top-nav fills follow `--surface-active-background-color`, with text and icons on `--surface-active-text-color`. Set `--color-primary-text` with the brand colour and check AA contrast. White text fails on a light brand such as yellow. CSS cannot pick the text colour. The bottom nav bar is inverted chrome (`--bottom-nav-background-color`). Leave it unless you want a different bar colour.

Any non-`light` theme value applied to `<html data-theme="...">` (or `<body data-theme="...">`) will activate the matching selector.

## Minimal brand themes

A named host theme should set semantic tokens, not component aliases. Component tokens are wired on `:root, [data-theme]` and re-resolve when `data-theme` is on `<body>`.

**Light** — pick one path:

- Recolor primary: `--brand-hue` / `--brand-chroma` / `--brand-lightness`
- Exact hex: `--color-primary` (and `--color-primary-text` if the fill is light)
- Surfaces, if they should differ from the kit greys: `--surface-page-background-color`, `--surface-background-color`, `--surface-muted-background-color`, `--surface-border-color`, `--surface-content-color`, `--surface-muted-content-color`

**Dark** — set `color-scheme: dark` plus the surface tokens and `--color-primary*`. Ghost, secondary, list hover, chip remove, switch track, and modal/carousel overlays then follow those semantics. Optional extras with no surface equivalent: `--overlay-backdrop-color`, `--overlay-scrim-color`, `--shadow-*` (hairline lift), `--bottom-nav-*`, `--top-nav-background-color`, `--sidebar-background-color`, `--backdrop-color`, `--backdrop-filter`, `--backdrop-tint-opacity`.

Stack the brand on rounded. The attribute is a list, base first. Rounded still supplies spacing, shape, and the backdrop wash (`#2f2f2f`, black tint at `0.18`). That wash follows the dark block in the kit, so `rounded dark` keeps `0.18` instead of `0.78`. The brand block overrides only the tokens it sets. Load that block after `flat_pack/variables`. Both selectors have the same specificity, so source order decides the winner.

```html
<html data-theme="rounded featured-in">
```

```css
[data-theme~="featured-in"] {
  --color-primary: #c41e6a;
  --color-primary-text: #fff;
  --surface-page-background-color: oklch(0.98 0.01 350);
  --surface-background-color: oklch(0.99 0.005 350);
  --surface-muted-background-color: oklch(0.94 0.02 350);
  --surface-border-color: oklch(0.86 0.03 350);
  --surface-content-color: oklch(0.22 0.04 350);
  --surface-muted-content-color: oklch(0.45 0.03 350);
}

[data-theme~="featured-in-dark"] {
  color-scheme: dark;
  --color-primary: oklch(0.72 0.18 350);
  --color-primary-text: oklch(0.18 0.04 350);
  --surface-page-background-color: oklch(0.16 0.02 350);
  --surface-background-color: oklch(0.18 0.02 350);
  --surface-muted-background-color: oklch(0.24 0.03 350);
  --surface-border-color: oklch(0.32 0.03 350);
  --surface-content-color: oklch(0.94 0.01 350);
  --surface-muted-content-color: oklch(0.72 0.02 350);
}
```

Do not copy `--button-*`, `--color-ghost-*`, or `--list-item-*` onto a brand theme unless that control should diverge from the surface tokens.

## Fastest Path

1. Prefer `bin/rails generate flat_pack:theme NAME --hue=… --chroma=… --lightness=…` (or a `:root { --brand-hue; --brand-chroma; --brand-lightness }` override) when you only need a recolor. Pass `--as_root` to write brand overrides on `:root` so no `data-theme` attribute is needed. Pass `--inherits=rounded` to stack the new theme on rounded. The file stays overrides only. Set `data-theme="rounded NAME"`.
2. If you need a named theme with extra semantic/surface tweaks, create or open a host stylesheet that loads **after** the FlatPack tags.
3. Start from brand/semantic overrides. Copy the complete starter block below only when you need a full fork.
4. Rename `[data-theme~="your-theme-name"]` to your own theme name.
5. Apply the theme by setting `data-theme="your-theme-name"` on `<html>` (preferred) or `<body>`. Derived tokens re-resolve in either place.

Example:

```erb
<html data-theme="sunrise" lang="<%= I18n.locale %>">
```

## Complete Starter Template

This block is a full-token override starter (historically based on the earlier purple-blue palette). Rename the selector, paste it into your app stylesheet, and edit values in place. For the shipped charcoal palette, leave `:root` alone. Set `data-theme="rounded"` for the generous spacing scale, pill buttons, and 16px form controls. Padding tokens below are formulas on the scale. Override `--space-*` or `--density` to move a whole theme. Override one component token only when that control should diverge. Do not self-map a token (`--token: var(--token)`).

Leave `--color-primary-hover`, `--button-primary-*`, `--fab-background-color`, `--fab-text-color`, `--fab-hover-background-color`, the chat send colour tokens, and the comments submit and replies colour tokens unset. The painters read them as pins. A value here freezes the shade. A wrapper `--color-primary` then leaves hover on that frozen colour.

Do not copy decorative `--gradient-*` tokens unless this theme actually needs a wash. The kit default has none.

<details>
<summary>Show complete custom-theme template</summary>

```css
[data-theme~="your-theme-name"] {
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.5rem;
  --space-6: 2rem;
  --density: 1;

  --color-primary: oklch(0.52 0.26 250);
  --color-primary-text: oklch(1.0 0 0);

  --color-default: var(--surface-background-color);
  --color-default-hover: var(--surface-muted-background-color);
  --color-default-text: var(--surface-content-color);
  --color-default-border: var(--surface-border-color);

  --color-secondary: color-mix(in oklab, var(--surface-muted-background-color) 18%, var(--surface-background-color));
  --color-secondary-hover: color-mix(in oklab, var(--surface-muted-background-color) 70%, var(--surface-background-color));
  --color-secondary-text: var(--surface-content-color);

  --color-ghost: transparent;
  --color-ghost-hover: color-mix(in oklab, var(--surface-muted-background-color) 35%, var(--surface-background-color));
  --color-ghost-text: var(--surface-content-color);

  --color-success-background-color: oklch(62.7% .194 149.214);
  --color-success-hover-background-color: oklch(57% .194 149.214);
  --color-success-text: oklch(1.0 0 0);
  --color-success-border: var(--color-success-background-color);

  --color-warning-background-color: oklch(70.5% 0.213 47.604);
  --color-warning-hover-background-color: oklch(64.6% 0.222 41.116);
  --color-warning-text: oklch(1.0 0 0);
  --color-warning-border: var(--color-warning-background-color);
  --color-warning: var(--color-warning-border);

  --color-danger-background-color: oklch(57.7% 0.245 27.325);
  --color-danger-hover-background-color: oklch(50.5% 0.213 27.518);
  --color-danger-text-color: oklch(1.0 0 0);
  --color-danger-border-color: var(--color-danger-background-color);
  --color-error: var(--color-danger-background-color);
  --color-error-border: var(--color-danger-border-color);
  --color-info-border: var(--surface-border-color);

  --surface-background-color: #fff;
  --surface-page-background-color: #f8f9fa;
  --surface-content-color: oklch(0.20 0.01 250);

  --surface-muted-background-color: oklch(0.96 0.01 250);
  --surface-hover-background-color: #f0f0f0;
  --surface-active-background-color: #e4e4e4;
  --surface-active-text-color: var(--surface-content-color);
  --surface-active-icon-color: var(--surface-active-text-color);
  --surface-active-border-color: transparent;
  --surface-muted-content-color: oklch(0.45 0.01 250);

  --surface-border-color: oklch(0.89 0.01 250);
  --surface-border-hover-color: oklch(0.82 0.02 250);
  --overlay-backdrop-color: rgb(0 0 0 / 0.5);
  --overlay-scrim-color: rgb(31 41 55 / 0.68);
  --checkbox-size: 1.25rem;
  --checkbox-radius: var(--radius-xs);
  --checkbox-label-gap: 0.75rem;
  --collapse-background-color: var(--surface-background-color);
  --collapse-border-color: var(--surface-border-color);
  --collapse-border-radius: var(--card-radius);
  --collapse-trigger-background-color: var(--surface-background-color);
  --collapse-trigger-hover-background-color: var(--surface-muted-background-color);
  --collapse-trigger-text-color: var(--surface-content-color);
  --collapse-trigger-padding: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --collapse-content-background-color: var(--surface-background-color);
  --collapse-content-padding: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --collapse-focus-ring-color: var(--color-ring);
  --collapse-transition-duration: var(--duration-slow);
  --collapse-icon-color: currentColor;
  --bottom-nav-background-color: oklch(0.24 0.02 250);
  --bottom-nav-border-color: oklch(0.36 0.03 250);
  --bottom-nav-item-active-color: oklch(0.98 0.01 250);
  --bottom-nav-item-color: oklch(0.78 0.02 250);
  --bottom-nav-item-hover-color: oklch(1.0 0 0);
  --bottom-nav-item-padding-x: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --bottom-nav-item-padding-y: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --fab-backdrop-color: var(--overlay-backdrop-color);
  --fab-action-background-color: var(--surface-background-color);
  --fab-action-hover-background-color: var(--surface-muted-background-color);
  --fab-action-text-color: var(--surface-content-color);
  --fab-label-background-color: var(--surface-background-color);
  --fab-label-text-color: var(--surface-content-color);
  --fab-label-shadow: var(--shadow-sm);
  --fab-shadow: var(--shadow-lg);
  --fab-shadow-hover: var(--shadow-button);
  --fab-shadow-active: var(--shadow-button-active);
  --fab-action-shadow: var(--shadow-md);
  --fab-focus-ring-color: var(--color-ring);
  --fab-focus-ring-offset-color: var(--surface-page-background-color);
  --fab-size: 3.5rem;
  --fab-size-sm: 2.5rem;
  --fab-size-lg: 4rem;
  --fab-action-size: 2.5rem;
  --fab-action-size-sm: 1.75rem;
  --fab-action-size-lg: 3rem;
  --fab-inset: 1rem;
  --fab-action-gap: 0.75rem;
  --fab-action-gap-sm: 0.5rem;
  --fab-z-index: 45;
  --quote-border-color: var(--surface-border-color);
  --quote-border-width: 4px;
  --quote-padding-left: 1rem;
  --quote-text-color: var(--surface-content-color);
  --quote-cite-color: var(--surface-muted-content-color);
  --quote-cite-margin-top: 0.5rem;
  --timeline-marker-default-background-color: var(--color-primary);
  --timeline-marker-success-background-color: var(--color-success-background-color);
  --timeline-marker-warning-background-color: var(--color-warning-background-color);
  --timeline-marker-danger-background-color: var(--color-danger-background-color);
  --timeline-marker-icon-color: var(--surface-page-background-color);
  --timeline-line-color: var(--surface-border-color);
  --timeline-title-color: var(--surface-content-color);
  --timeline-timestamp-color: var(--surface-muted-content-color);
  --timeline-content-color: var(--surface-content-color);
  --timeline-item-padding-bottom: 2rem;
  --timeline-content-padding-left: 1rem;
  --timeline-line-min-height: 2rem;
  --accordion-background-color: var(--surface-background-color);
  --accordion-border-color: var(--surface-border-color);
  --accordion-border-radius: var(--card-radius);
  --accordion-item-border-color: var(--surface-border-color);
  --accordion-trigger-text-color: var(--surface-content-color);
  --accordion-trigger-hover-background-color: var(--surface-muted-background-color);
  --accordion-trigger-padding-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --accordion-trigger-padding-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --accordion-trigger-padding-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --accordion-content-background-color: var(--surface-background-color);
  --accordion-content-padding-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --accordion-content-padding-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --accordion-content-padding-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --accordion-focus-ring-color: var(--color-ring);
  --accordion-transition-duration: var(--duration-slow);
  --breadcrumb-current-color: var(--surface-content-color);
  --breadcrumb-link-color: var(--surface-muted-content-color);
  --breadcrumb-link-hover-color: var(--surface-content-color);
  --breadcrumb-separator-color: var(--surface-muted-content-color);
  --breadcrumb-gap: 0.25rem;
  --breadcrumb-separator-gap: 0.5rem;
  --switch-track-background-color: color-mix(in oklab, var(--surface-muted-background-color) 92%, black);
  --switch-track-checked-background-color: var(--color-primary);
  --switch-focus-ring-color: var(--color-ring);
  --switch-label-color: var(--surface-content-color);
  --switch-thumb-background-color: var(--surface-page-background-color);
  --switch-thumb-shadow: var(--shadow-sm);
  --switch-error-color: var(--color-error);
  --skeleton-background-color: var(--surface-muted-background-color);
  --skeleton-shimmer-highlight-color: rgb(255 255 255 / 0.45);
  --skeleton-shimmer-duration: 1.35s;
  --easing-standard: cubic-bezier(0.2, 0, 0, 1);
  --easing-enter: cubic-bezier(0.05, 0.7, 0.1, 1);
  --easing-exit: cubic-bezier(0.3, 0, 1, 1);
  --easing-spring: cubic-bezier(0.34, 1.25, 0.64, 1); /* list/layout only */
  --easing-spring-snappy: cubic-bezier(0.22, 1.35, 0.36, 1); /* list/layout only */
  --motion-duration-fast: var(--duration-fast);
  --motion-duration-base: var(--duration-base);
  --motion-duration-slow: var(--duration-slow);
  --motion-duration-slower: 600ms;
  --motion-delay-sm: 120ms;
  --motion-delay-md: 250ms;
  --motion-delay-lg: 450ms;
  --motion-stagger-sm: 40ms;
  --motion-stagger-md: 80ms;
  --motion-stagger-lg: 120ms;
  --motion-ease-out: var(--easing-enter);
  --motion-ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
  --motion-ease-spring: var(--easing-spring);
  --motion-distance-sm: 4px;
  --motion-distance-md: 1rem;
  --motion-distance-lg: 3rem;
  --motion-scale: 0.95;
  --motion-scale-strong: 0.85;
  --motion-zoom: 1.05;
  --motion-zoom-strong: 1.2;
  --reveal-stagger: 40ms;
  --font-sans: system-ui, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
  --font-mono: ui-monospace, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace;
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;
  --text-4xl: 2.25rem;
  --text-5xl: 3rem;
  --text-6xl: 3.75rem;
  --text-6xl--line-height: 1;
  --text-7xl: 4.5rem;
  --text-7xl--line-height: 1;
  --text-8xl: 6rem;
  --text-8xl--line-height: 1;
  --leading-tight: 1.25;
  --leading-snug: 1.375;
  --leading-normal: 1.5;
  --display-size-min: var(--text-5xl);
  --display-size-max: 5.5rem;
  --display-size: clamp(var(--display-size-min), 1rem + 5vw, var(--display-size-max));
  --display-tracking: -0.03em;
  --display-leading: 1.05;
  --display-weight: 600;
  --hero-title-md-size-min: var(--text-4xl);
  --hero-title-md-size-max: var(--text-6xl);
  --hero-title-md-size: clamp(var(--hero-title-md-size-min), 1rem + 3.5vw, var(--hero-title-md-size-max));
  --hero-title-lg-size-min: var(--text-5xl);
  --hero-title-lg-size-max: var(--text-7xl);
  --hero-title-lg-size: clamp(var(--hero-title-lg-size-min), 1rem + 4.5vw, var(--hero-title-lg-size-max));
  --hero-title-xl-size-min: var(--display-size-min);
  --hero-title-xl-size-max: var(--display-size-max);
  --hero-title-xl-size: var(--display-size);
  --hero-title-xxl-size-min: var(--text-5xl);
  --hero-title-xxl-size-max: var(--text-8xl);
  --hero-title-xxl-size: clamp(var(--hero-title-xxl-size-min), 1rem + 5.5vw, var(--hero-title-xxl-size-max));
  --code-block-background-color: var(--surface-muted-background-color);
  --code-block-border-color: var(--surface-border-color);
  --code-block-title-color: var(--surface-muted-content-color);
  --code-block-code-color: var(--surface-content-color);
  --code-block-tab-color: var(--surface-muted-content-color);
  --code-block-tab-hover-color: var(--surface-content-color);
  --code-block-tab-active-background-color: var(--surface-border-color);
  --code-block-tab-active-color: var(--surface-muted-content-color);
  --tabs-pill-corner-radius: var(--radius-md);
  --tabs-pill-active-background-color: var(--surface-active-background-color);
  --tabs-pill-active-border-color: var(--surface-active-border-color);
  --tabs-pill-active-text-color: var(--surface-active-text-color);
  --tabs-pill-active-shadow: none;
  --tabs-pill-list-background-color: transparent;
  --tabs-pill-list-border-color: var(--surface-border-color);
  --tabs-pill-inactive-text-color: var(--surface-muted-content-color);
  --tabs-pill-inactive-hover-background-color: var(--surface-hover-background-color);
  --tabs-pill-inactive-hover-text-color: var(--surface-content-color);
  --card-background-color: var(--surface-background-color);
  --card-background-muted-color: var(--surface-muted-background-color);
  --card-border-color: var(--surface-border-color);
  --card-border-width: 1px;
  --card-shadow: none;
  --card-background-default: var(--card-background-color);
  --card-background-default-text-color: var(--surface-content-color);
  --card-background-default-muted-text-color: var(--surface-muted-content-color);
  --card-background-default-border-color: var(--card-border-color);
  --card-background-none: transparent;
  --card-background-none-text-color: inherit;
  --card-background-none-muted-text-color: inherit;
  --card-background-none-border-color: var(--card-border-color);
  --card-background-shaded: var(--card-background-muted-color);
  --card-background-shaded-text-color: var(--surface-content-color);
  --card-background-shaded-muted-text-color: var(--surface-muted-content-color);
  --card-background-shaded-border-color: var(--surface-border-color);
  --card-background-brand: var(--color-primary);
  --card-background-brand-text-color: var(--color-primary-text);
  --card-background-brand-muted-text-color: color-mix(in oklab, var(--color-primary-text) 72%, transparent);
  --card-background-brand-border-color: color-mix(in oklab, var(--color-primary-text) 28%, transparent);
  --card-background-brand-subtle: color-mix(in oklab, var(--color-primary) 14%, var(--surface-background-color));
  --card-background-brand-subtle-text-color: var(--surface-content-color);
  --card-background-brand-subtle-muted-text-color: var(--surface-muted-content-color);
  --card-background-brand-subtle-border-color: color-mix(in oklab, var(--color-primary) 34%, var(--surface-border-color));
  --card-background-gradient: linear-gradient(145deg, var(--color-primary) 0%, color-mix(in oklab, var(--color-primary) 48%, black) 100%);
  --card-background-gradient-text-color: var(--color-primary-text);
  --card-background-gradient-muted-text-color: color-mix(in oklab, var(--color-primary-text) 72%, transparent);
  --card-background-gradient-border-color: color-mix(in oklab, var(--color-primary-text) 28%, transparent);
  --card-padding-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --card-padding-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --card-padding-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --empty-state-padding-y-sm: round(nearest, calc(var(--space-6) * var(--density)), 1px);
  --empty-state-padding-x-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --empty-state-padding-y-md: round(nearest, calc((var(--space-6) + var(--space-4)) * var(--density)), 1px);
  --empty-state-padding-x-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --empty-state-padding-y-lg: round(nearest, calc(var(--space-6) * 2 * var(--density)), 1px);
  --empty-state-padding-x-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --empty-state-gap-sm: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --empty-state-gap-md: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --empty-state-gap-lg: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --empty-state-title-gap-sm: round(nearest, calc(var(--space-1) * var(--density)), 1px);
  --empty-state-title-gap-md: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --empty-state-title-gap-lg: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --empty-state-block-gap-sm: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --empty-state-block-gap-md: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --empty-state-block-gap-lg: round(nearest, calc(var(--space-6) * var(--density)), 1px);
  --empty-state-measure-sm: 20rem;
  --empty-state-measure-md: 28rem;
  --empty-state-measure-lg: 36rem;
  --empty-state-measure-full: none;
  --collage-rotate: 5deg;
  --collage-offset-x: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --collage-offset-y: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --collage-lift: calc(var(--collage-offset-y) * -1);
  --collage-stagger: var(--reveal-stagger);
  --collage-loose: 2;
  --collage-gap: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --collage-pad: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --collage-bleed: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --collage-margin: round(nearest, calc(var(--space-6) * var(--density)), 1px);
  --collage-overlap: calc(var(--space-5) * var(--density) * -1);
  --collage-card-ratio: 0.928;
  --collage-card-sway: 0.1;
  --collage-item-size-sm: calc(33dvh * 0.7 * var(--collage-card-ratio));
  --collage-item-size-md: 11rem;
  --collage-duration: var(--motion-duration-slow);
  --collage-easing: var(--motion-ease-out);
  --collage-rise: var(--motion-distance-sm);
  --collage-deal: 100%;
  --collage-deal-duration: 720ms;
  --collage-drift: 1deg;
  --collage-drift-duration: 8s;
  --collage-drift-easing: ease-in-out;
  --collage-drift-phase: -1.15s;
  --collage-focus-lift: calc(var(--collage-lift) * 2);
  --collage-focus-scale: 0.97;
  --collage-focus-dim: 0.62;
  --card-hover-subtle-background-color: var(--surface-muted-background-color);
  --card-hover-strong-border-color: var(--color-primary);
  --card-hover-strong-shadow: var(--shadow-md);
  --card-hover-strong-shadow-dark: var(--shadow-lg);
  --hero-overlay-background-color: rgb(0 0 0 / 0.6);
  --hero-overlay-left-background: linear-gradient(to right, rgb(0 0 0 / 0.78) 0%, rgb(0 0 0 / 0.52) 38%, rgb(0 0 0 / 0.22) 68%, rgb(0 0 0 / 0.08) 100%);
  --hero-overlay-text-color: oklch(1.0 0 0);
  --hero-overlay-muted-text-color: rgb(255 255 255 / 0.8);
  --hero-overlay-button-primary-background-color: oklch(1 0 0);
  --hero-overlay-button-primary-hover-background-color: oklch(0.96 0 0);
  --hero-overlay-button-primary-text-color: oklch(0.22 0 0);
  --hero-overlay-button-primary-border-color: oklch(1 0 0);
  --hero-overlay-button-secondary-background-color: transparent;
  --hero-overlay-button-secondary-hover-background-color: rgb(255 255 255 / 0.12);
  --hero-overlay-button-secondary-text-color: oklch(1 0 0);
  --hero-overlay-button-secondary-border-color: rgb(255 255 255 / 0.55);
  --hero-overlay-on-light-background-color: rgb(255 255 255 / 0.62);
  --hero-overlay-on-light-left-background: linear-gradient(to right, rgb(255 255 255 / 0.88) 0%, rgb(255 255 255 / 0.62) 38%, rgb(255 255 255 / 0.28) 68%, rgb(255 255 255 / 0.08) 100%);
  --hero-overlay-on-light-text-color: oklch(0.22 0 0);
  --hero-overlay-on-light-muted-text-color: rgb(34 34 34 / 0.82);
  --hero-overlay-on-light-button-primary-background-color: oklch(0.22 0 0);
  --hero-overlay-on-light-button-primary-hover-background-color: oklch(0.28 0 0);
  --hero-overlay-on-light-button-primary-text-color: oklch(1 0 0);
  --hero-overlay-on-light-button-primary-border-color: oklch(0.22 0 0);
  --hero-overlay-on-light-button-secondary-background-color: transparent;
  --hero-overlay-on-light-button-secondary-hover-background-color: rgb(0 0 0 / 0.08);
  --hero-overlay-on-light-button-secondary-text-color: oklch(0.22 0 0);
  --hero-overlay-on-light-button-secondary-border-color: rgb(0 0 0 / 0.35);
  --hero-overlay-min-height: 560px;
  --hero-overlay-copy-padding-top: calc(var(--top-nav-height) + env(safe-area-inset-top, 0px) + 2rem);
  --carousel-viewport-background-color: var(--surface-muted-background-color);
  --carousel-viewport-border-color: var(--surface-border-color);
  --carousel-chevron-background-color: var(--overlay-scrim-color);
  --carousel-control-background-color: rgb(0 0 0 / 0.6);
  --carousel-control-hover-background-color: rgb(0 0 0 / 0.8);
  --carousel-control-text-color: oklch(1.0 0 0);
  --carousel-counter-background-color: rgb(0 0 0 / 0.6);
  --carousel-counter-text-color: oklch(1.0 0 0);
  --carousel-indicator-track-background-color: rgb(0 0 0 / 0.5);
  --carousel-indicator-background-color: rgb(255 255 255 / 0.5);
  --carousel-indicator-active-background-color: rgb(255 255 255);
  --carousel-thumb-border-color: var(--surface-border-color);
  --carousel-thumb-placeholder-background-color: var(--surface-muted-background-color);
  --carousel-thumb-placeholder-text-color: var(--surface-muted-content-color);
  --carousel-caption-overlay-background-color: rgb(0 0 0 / 0.6);
  --carousel-caption-overlay-text-color: oklch(1.0 0 0);
  --carousel-caption-below-text-color: var(--surface-muted-content-color);
  --carousel-media-background-color: oklch(0 0 0);
  --carousel-lightbox-image-background-color: rgb(0 0 0 / 0.2);
  --modal-backdrop-color: var(--overlay-backdrop-color);
  --modal-surface-color: var(--surface-background-color);
  --modal-border-color: var(--surface-border-color);
  --modal-title-color: var(--surface-content-color);
  --modal-body-color: var(--surface-content-color);
  --modal-close-icon-color: var(--surface-muted-content-color);
  --modal-close-icon-hover-color: var(--surface-content-color);
  --drawer-backdrop-color: var(--modal-backdrop-color);
  --drawer-surface-color: var(--modal-surface-color);
  --drawer-border-color: var(--modal-border-color);
  --drawer-title-color: var(--modal-title-color);
  --drawer-body-color: var(--modal-body-color);
  --drawer-close-icon-color: var(--modal-close-icon-color);
  --drawer-close-icon-hover-color: var(--modal-close-icon-hover-color);
  --kbd-background-color: var(--surface-muted-background-color);
  --kbd-border-color: var(--surface-border-color);
  --kbd-text-color: var(--surface-content-color);
  --kbd-muted-color: var(--surface-muted-content-color);
  --skip-link-background-color: var(--surface-content-color);
  --skip-link-text-color: var(--surface-background-color);
  --stepper-current-color: var(--color-primary);
  --stepper-complete-color: var(--color-success-background-color);
  --stepper-upcoming-color: var(--surface-border-color);
  --stepper-label-color: var(--surface-content-color);
  --stepper-muted-color: var(--surface-muted-content-color);
  --stepper-complete-text-color: var(--color-success-text);
  --progress-fill-color: var(--color-primary);
  --progress-success-fill-color: var(--color-success-background-color);
  --progress-warning-fill-color: var(--color-warning-background-color);
  --progress-danger-fill-color: var(--color-danger-background-color);
  --range-track-color: var(--surface-muted-background-color);
  --range-fill-color: var(--color-primary);
  --range-thumb-color: var(--color-primary);
  --range-thumb-border-color: var(--surface-page-background-color);
  --range-thumb-shadow: var(--shadow-md);
  --range-thumb-size: 1.25rem;
  --range-track-height: 0.375rem;
  --popover-background-color: var(--surface-background-color);
  --popover-border-color: var(--surface-border-color);
  --popover-text-color: var(--surface-content-color);
  --popover-shadow: var(--shadow-lg);
  --popover-padding: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --popover-radius: var(--menu-radius);
  --tooltip-background-color: var(--surface-content-color);
  --tooltip-border-color: var(--surface-border-color);
  --tooltip-text-color: var(--surface-background-color);
  --tooltip-shadow: var(--shadow-lg);
  --tooltip-padding-x: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --tooltip-padding-y: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --tooltip-radius: var(--radius-sm);
  --tooltip-font-size: 0.875rem;
  --tooltip-max-width: 20rem;
  --sidebar-background-color: var(--surface-page-background-color);
  --sidebar-float-inset: 1rem;
  --sidebar-float-background-color: #fff;
  --sidebar-float-shadow: var(--shadow-md);
  --sidebar-float-radius: var(--radius-lg);
  /* --layout-content-inset stays on the kit: 1rem, then 2rem from 640px. Set it here only to change that page padding. */
  /* --layout-content-max-width stays 100% (the padded column). Set a length here to center a measure. */
  --backdrop-blur: 40px;
  --backdrop-color: transparent;
  --backdrop-filter: saturate(1);
  --backdrop-tint-color: var(--surface-page-background-color);
  --backdrop-tint-opacity: 0.55;
  --sidebar-border-color: oklch(0.89 0.01 250);
  --sidebar-divider-color: oklch(0.89 0.01 250);
  --sidebar-item-text-color: oklch(0.45 0.01 250);
  --sidebar-item-icon-color: oklch(0.45 0.01 250);
  --sidebar-item-hover-background-color: oklch(0.96 0.01 250);
  --list-item-hover-background-color: oklch(0.95 0.01 250);
  --list-item-active-background-color: oklch(0.93 0.01 250);
  --list-marker-color: var(--surface-muted-content-color);
  --list-marker-min-width: 1.5rem;
  --list-marker-gap: 0.5rem;
  --collection-editor-background-color: var(--surface-background-color);
  --collection-editor-border-color: var(--surface-border-color);
  --collection-editor-radius: var(--card-radius);
  --collection-editor-row-background-color: transparent;
  --collection-editor-row-hover-background-color: var(--list-item-hover-background-color);
  --collection-editor-row-padding: 0.75rem;
  --collection-editor-title-color: var(--surface-content-color);
  --collection-editor-description-color: var(--surface-muted-content-color);
  --collection-editor-handle-color: var(--surface-muted-content-color);
  --collection-editor-drop-indicator-color: var(--color-primary);
  --sidebar-item-hover-text-color: oklch(0.20 0.01 250);
  --sidebar-item-active-background-color: var(--surface-active-background-color);
  --sidebar-item-active-text-color: var(--surface-active-text-color);
  --sidebar-item-active-icon-color: var(--surface-active-icon-color);
  --sidebar-group-item-indent: 0.75rem;
  --sidebar-footer-text-color: oklch(0.45 0.01 250);
  --sidebar-header-background-color: var(--sidebar-background-color);
  --sidebar-header-border-color: var(--sidebar-border-color);
  --sidebar-header-text-color: var(--sidebar-item-text-color);
  --sidebar-header-icon-color: var(--sidebar-item-icon-color);
  --sidebar-header-icon-hover-background-color: var(--sidebar-item-hover-background-color);
  --sidebar-header-icon-hover-color: var(--sidebar-item-hover-text-color);
  --badge-default-background-color: var(--surface-muted-background-color);
  --badge-default-text-color: var(--surface-content-color);
  --badge-default-border-color: var(--surface-border-color);
  --badge-primary-background-color: var(--color-primary);
  --badge-primary-text-color: var(--color-primary-text);
  --badge-primary-border-color: var(--color-primary);
  --badge-secondary-background-color: var(--color-secondary);
  --badge-secondary-text-color: var(--color-secondary-text);
  --badge-secondary-border-color: var(--surface-border-color);
  --badge-success-background-color: var(--color-success-background-color);
  --badge-success-text-color: var(--color-success-text);
  --badge-success-border-color: var(--color-success-border);
  --badge-warning-background-color: var(--color-warning-background-color);
  --badge-warning-text-color: var(--color-warning-text);
  --badge-warning-border-color: var(--color-warning-border);
  --badge-danger-background-color: var(--color-danger-background-color);
  --badge-danger-text-color: var(--color-danger-text-color);
  --badge-danger-border-color: var(--color-danger-border-color);
  --badge-info-background-color: var(--surface-background-color);
  --badge-info-text-color: var(--surface-content-color);
  --badge-info-border-color: var(--color-info-border);
  --badge-remove-hover-background-color: var(--chip-remove-hover-background-color);
  --sidebar-header-badge-background-color: var(--badge-primary-background-color);
  --sidebar-header-badge-text-color: var(--badge-primary-text-color);
  --chat-background-color: var(--surface-background-color);
  --chat-border-color: var(--surface-border-color);
  --chat-header-background-color: var(--surface-background-color);
  --chat-header-border-color: var(--surface-border-color);
  --chat-composer-background-color: var(--surface-background-color);
  --chat-composer-border-color: var(--surface-border-color);
  --chat-composer-radius: var(--radius-lg);
  --chat-input-background-color: var(--surface-background-color);
  --chat-input-border-color: var(--surface-border-color);
  --chat-input-text-color: var(--surface-content-color);
  --chat-input-placeholder-color: var(--surface-muted-content-color);
  --chat-input-focus-ring-color: var(--color-ring);
  --chat-composer-control-height: calc(1.25rem + (var(--button-icon-only-padding-md) * 2) + 2px);
  --chat-message-incoming-background-color: var(--surface-muted-background-color);
  --chat-message-incoming-text-color: var(--surface-content-color);
  --chat-message-outgoing-background-color: var(--surface-hover-background-color);
  --chat-message-outgoing-text-color: var(--surface-content-color);
  --chat-message-system-text-color: var(--surface-muted-content-color);
  --chat-message-incoming-meta-color: var(--surface-muted-content-color);
  --chat-message-outgoing-meta-color: var(--surface-muted-content-color);
  --chat-message-meta-color: var(--chat-message-incoming-meta-color);
  --chat-message-failed-color: var(--color-danger-border-color);
  --chat-message-incoming-read-receipt-color: var(--chat-message-incoming-text-color);
  --chat-message-outgoing-read-receipt-color: var(--surface-muted-content-color);
  --chat-read-receipt-color: var(--chat-message-incoming-read-receipt-color);
  --chat-date-divider-line-color: var(--surface-border-color);
  --chat-date-divider-text-color: var(--surface-muted-content-color);
  --chat-attachment-border-color: var(--surface-border-color);
  --chat-attachment-hover-background-color: var(--surface-muted-background-color);
  --chat-attachment-text-color: var(--surface-content-color);
  --chat-attachment-meta-color: var(--surface-muted-content-color);
  --chat-attachment-icon-color: var(--surface-muted-content-color);
  --chat-jump-button-background-color: var(--surface-background-color);
  --chat-jump-button-border-color: var(--surface-border-color);
  --chat-jump-button-text-color: var(--surface-content-color);
  --chat-jump-button-hover-background-color: var(--surface-muted-background-color);
  --chat-typing-background-color: var(--surface-muted-background-color);
  --chat-typing-dot-color: var(--surface-content-color);
  --chat-avatar-placeholder-background-color: var(--surface-muted-background-color);
  --chat-avatar-placeholder-text-color: var(--surface-muted-content-color);
  --chat-send-button-focus-ring-color: var(--color-ring);
  --comments-item-background-color: var(--surface-background-color);
  --comments-item-system-background-color: var(--surface-muted-background-color);
  --comments-item-border-color: var(--surface-border-color);
  --comments-item-author-color: var(--surface-content-color);
  --comments-item-meta-color: var(--surface-muted-content-color);
  --comments-item-body-color: var(--surface-content-color);
  --comments-item-deleted-text-color: var(--surface-muted-content-color);
  --comments-item-footer-border-color: var(--surface-border-color);
  --comments-composer-background-color: var(--surface-background-color);
  --comments-composer-border-color: var(--surface-border-color);
  --comments-composer-focus-ring-color: var(--color-ring);
  --comments-composer-focus-border-color: var(--color-ring);
  --comments-composer-text-color: var(--surface-content-color);
  --comments-composer-placeholder-color: var(--surface-muted-content-color);
  --comments-composer-actions-background-color: color-mix(in oklab, var(--surface-muted-background-color) 30%, transparent);
  --comments-composer-slots-background-color: var(--comments-composer-actions-background-color);
  --comments-composer-cancel-text-color: var(--surface-content-color);
  --comments-composer-cancel-hover-background-color: var(--surface-muted-background-color);
  --comments-inline-input-radius: var(--form-control-radius);
  --comments-thread-header-border-color: var(--surface-border-color);
  --comments-thread-title-color: var(--surface-content-color);
  --comments-thread-count-color: var(--surface-muted-content-color);
  --comments-thread-locked-color: var(--surface-muted-content-color);
  --comments-thread-empty-title-color: var(--surface-content-color);
  --comments-thread-empty-body-color: var(--surface-muted-content-color);
  --comments-replies-border-color: var(--surface-border-color);
  --button-default-background-color: var(--color-default);
  --button-default-hover-background-color: var(--color-default-hover);
  --button-default-text-color: var(--color-default-text);
  --button-default-border-color: var(--color-default-border);
  --button-secondary-background-color: var(--color-secondary);
  --button-secondary-hover-background-color: var(--color-secondary-hover);
  --button-secondary-text-color: var(--color-secondary-text);
  --button-secondary-border-color: var(--surface-border-color);
  --button-ghost-background-color: var(--color-ghost);
  --button-ghost-hover-background-color: var(--color-ghost-hover);
  --button-ghost-text-color: var(--color-ghost-text);
  --button-ghost-border-color: transparent;
  --button-success-background-color: var(--color-success-background-color);
  --button-success-hover-background-color: var(--color-success-hover-background-color);
  --button-success-text-color: var(--color-success-text);
  --button-success-border-color: var(--color-success-border);
  --button-warning-background-color: var(--color-warning-background-color);
  --button-warning-hover-background-color: var(--color-warning-hover-background-color);
  --button-warning-text-color: var(--color-warning-text);
  --button-warning-border-color: var(--color-warning-border);
  --button-danger-background-color: var(--color-danger-background-color);
  --button-danger-hover-background-color: var(--color-danger-hover-background-color);
  --button-danger-text-color: var(--color-danger-text-color);
  --button-danger-border-color: var(--color-danger-border-color);
  --button-icon-primary-color: var(--color-primary);
  --button-icon-success-color: var(--color-success-background-color);
  --button-icon-warning-color: var(--color-warning);
  --button-icon-danger-color: var(--color-danger-background-color);
  --button-border-radius: var(--radius-md);
  --button-group-radius: var(--radius-md);
  --button-round-border-radius: var(--radius-full);
  --button-focus-ring-color: var(--color-ring);
  --button-focus-ring-offset-color: var(--surface-page-background-color);
  --button-disabled-opacity: 0.5;
  --button-shadow: var(--shadow-sm);
  --button-shadow-hover: var(--shadow-button);
  --button-shadow-active: var(--shadow-button-active);
  --hit-target-min: 2.75rem;
  --hit-target-inline-min: 1.5rem;
  --button-padding-x-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --button-padding-y-sm: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --button-padding-x-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --button-padding-y-md: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --button-padding-x-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --button-padding-y-lg: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --button-icon-only-padding-sm: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --button-icon-only-padding-md: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --button-icon-only-padding-lg: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --button-round-size-sm: max(var(--hit-target-min), calc((var(--button-icon-only-padding-sm) * 2) + 1rem + 2px));
  --button-round-size-md: max(var(--hit-target-min), calc((var(--button-icon-only-padding-md) * 2) + 1.25rem + 2px));
  --button-round-size-lg: max(var(--hit-target-min), calc((var(--button-icon-only-padding-lg) * 2) + 1.5rem + 2px));
  --alert-border-radius: var(--radius-lg);
  --alert-padding-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --alert-padding-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --alert-padding-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --alert-title-color: currentColor;
  --alert-description-color: currentColor;
  --alert-dismiss-button-radius: var(--radius-sm);
  --alert-dismiss-button-text-color: currentColor;
  --alert-dismiss-button-hover-background-color: color-mix(in oklab, currentColor 8%, transparent);
  --alert-dismiss-button-focus-ring-color: var(--color-ring);
  --alert-info-background-color: var(--surface-background-color);
  --alert-info-border-color: var(--color-info-border);
  --alert-info-text-color: var(--surface-content-color);
  --alert-info-icon-color: var(--surface-muted-content-color);
  --alert-success-background-color: color-mix(in oklab, var(--color-success-background-color) 18%, var(--surface-background-color));
  --alert-success-border-color: color-mix(in oklab, var(--color-success-background-color) 42%, var(--surface-border-color));
  --alert-success-text-color: var(--surface-content-color);
  --alert-success-icon-color: color-mix(in oklab, var(--color-success-background-color) 78%, black);
  --alert-warning-background-color: color-mix(in oklab, var(--color-warning-background-color) 18%, var(--surface-background-color));
  --alert-warning-border-color: color-mix(in oklab, var(--color-warning-background-color) 42%, var(--surface-border-color));
  --alert-warning-text-color: var(--surface-content-color);
  --alert-warning-icon-color: color-mix(in oklab, var(--color-warning-background-color) 78%, black);
  --alert-danger-background-color: color-mix(in oklab, var(--color-danger-background-color) 18%, var(--surface-background-color));
  --alert-danger-border-color: color-mix(in oklab, var(--color-danger-background-color) 42%, var(--surface-border-color));
  --alert-danger-text-color: var(--surface-content-color);
  --alert-danger-icon-color: color-mix(in oklab, var(--color-danger-background-color) 78%, black);
  --toast-border-radius: var(--radius-lg);
  --toast-padding-sm: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --toast-padding-md: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --toast-padding-lg: round(nearest, calc(var(--space-5) * var(--density)), 1px);
  --toast-shadow: var(--shadow-lg);
  --toast-dismiss-text-color: var(--surface-muted-content-color);
  --toast-dismiss-hover-text-color: var(--surface-content-color);
  --toast-dismiss-hover-background-color: color-mix(in oklab, currentColor 8%, transparent);
  --toast-danger-dismiss-background-color: transparent;
  --toast-danger-dismiss-hover-background-color: var(--toast-dismiss-hover-background-color);
  --toast-danger-dismiss-text-color: var(--toast-dismiss-text-color);
  --toast-info-background-color: var(--alert-info-background-color);
  --toast-info-border-color: var(--alert-info-border-color);
  --toast-info-text-color: var(--alert-info-text-color);
  --toast-info-icon-color: var(--alert-info-icon-color);
  --toast-success-background-color: var(--alert-success-background-color);
  --toast-success-border-color: var(--alert-success-border-color);
  --toast-success-text-color: var(--alert-success-text-color);
  --toast-success-icon-color: var(--alert-success-icon-color);
  --toast-warning-background-color: var(--alert-warning-background-color);
  --toast-warning-border-color: var(--alert-warning-border-color);
  --toast-warning-text-color: var(--alert-warning-text-color);
  --toast-warning-icon-color: var(--alert-warning-icon-color);
  --toast-danger-background-color: var(--alert-danger-background-color);
  --toast-danger-border-color: var(--alert-danger-border-color);
  --toast-danger-text-color: var(--alert-danger-text-color);
  --toast-danger-icon-color: var(--alert-danger-icon-color);
  --avatar-background-color: var(--surface-muted-background-color);
  --avatar-text-color: var(--surface-content-color);
  --avatar-link-hover-opacity: 0.8;
  --avatar-radius-circle: 9999px;
  --avatar-radius-rounded: var(--radius-xl);
  --avatar-radius-square: var(--radius-md);
  --avatar-status-ring-color: var(--surface-border-color);
  --avatar-status-online-color: oklch(0.73 0.19 150);
  --avatar-status-offline-color: var(--surface-muted-content-color);
  --avatar-status-busy-color: oklch(0.64 0.23 28);
  --avatar-status-away-color: oklch(0.77 0.16 80);
  --avatar-group-overlap-sm: -0.25rem;
  --avatar-group-overlap-md: -0.5rem;
  --avatar-group-overlap-lg: -0.75rem;
  --avatar-group-ring-color: var(--surface-page-background-color);
  --top-nav-background-color: oklch(1.0 0 0);
  --top-nav-border-color: transparent;
  --top-nav-item-text-color: oklch(0.45 0.01 250);
  --top-nav-item-icon-color: oklch(0.45 0.01 250);
  --top-nav-item-hover-background-color: oklch(0.96 0.01 250);
  --top-nav-item-hover-text-color: oklch(0.20 0.01 250);
  --top-nav-item-active-background-color: var(--surface-active-background-color);
  --top-nav-item-active-text-color: var(--surface-active-text-color);
  --top-nav-item-active-icon-color: var(--surface-active-icon-color);
  --top-nav-height: 72px;
  --top-nav-backdrop-blur: 16px;

  --search-icon-color: var(--surface-muted-content-color);
  --search-input-background-color: var(--surface-background-color);
  --search-input-border-color: transparent;
  --search-input-text-color: var(--surface-content-color);
  --search-input-placeholder-color: var(--surface-muted-content-color);
  --search-input-focus-ring-color: var(--color-primary);
  --search-padding-y-sm: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --search-padding-y-md: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --search-padding-y-lg: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --search-padding-inline-sm: 2rem;
  --search-padding-inline-md: 2.5rem;
  --search-padding-inline-lg: 3rem;
  --search-expanded-width: 16rem;
  --search-dropdown-background-color: var(--surface-background-color);
  --search-dropdown-border-color: var(--surface-border-color);
  --search-dropdown-muted-text-color: var(--surface-muted-content-color);
  --search-result-title-color: var(--surface-content-color);
  --search-result-description-color: var(--surface-muted-content-color);
  --search-result-hover-background-color: var(--surface-muted-background-color);
  --search-result-divider-color: var(--surface-border-color);

  --color-ring: var(--color-primary);
  --icon-stroke-width: 1.5;

  --stack-gap-sm: 0.5rem;
  --stack-gap-md: 1rem;
  --stack-gap-lg: 1.5rem;
  --overflow-row-gap: var(--stack-gap-md);
  --overflow-row-fade-size: 2rem;
  --pane-scrollbar-width: none;
  --pane-scroll-fade-size: 2.5rem;
  --form-control-padding-x: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --form-control-padding-y: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --table-padding-x: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --table-padding-y: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --table-background-color: var(--surface-background-color);
  --table-border-color: var(--surface-border-color);
  --table-header-background-color: var(--surface-background-color);
  --table-header-border-color: var(--surface-border-color);
  --table-header-text-color: var(--surface-muted-content-color);
  --table-row-divider-color: var(--surface-border-color);
  --table-row-hover-background-color: var(--surface-hover-background-color);
  --table-row-selected-background-color: var(--surface-active-background-color);
  --pagination-current-background-color: var(--surface-active-background-color);
  --pagination-current-text-color: var(--surface-active-text-color);
  --table-cell-text-color: var(--surface-content-color);
  --table-cell-muted-text-color: var(--surface-muted-content-color);
  --table-empty-state-text-color: var(--surface-muted-content-color);
  --table-sort-link-hover-color: var(--surface-content-color);
  --chip-remove-hover-background-color: color-mix(in oklab, var(--surface-content-color) 10%, transparent);
  --chip-border-radius: var(--radius-md);
  --chip-group-gap: 0.5rem;
  --chip-padding-x-sm: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --chip-padding-y-sm: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --chip-padding-x-md: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --chip-padding-y-md: round(nearest, calc(var(--space-2) * var(--density)), 1px);
  --chip-padding-x-lg: round(nearest, calc(var(--space-4) * var(--density)), 1px);
  --chip-padding-y-lg: round(nearest, calc(var(--space-3) * var(--density)), 1px);
  --picker-badge-background-color: rgb(0 0 0 / 0.55);
  --picker-badge-text-color: oklch(1.0 0 0);
  --picker-selection-idle-background-color: rgb(0 0 0 / 0.3);
  --picker-selection-idle-ring-color: rgb(0 0 0 / 0.2);
  --picker-selection-indicator-border-color: var(--picker-badge-text-color);
  --picker-selection-indicator-fill-color: var(--picker-badge-text-color);

  --page-title-h1-size: var(--text-4xl);
  --page-title-h2-size: var(--text-3xl);
  --page-title-h3-size: var(--text-2xl);
  --page-title-h4-size: var(--text-xl);
  --page-title-h5-size: var(--text-lg);
  --page-title-h6-size: var(--text-base);
  --content-kicker-size: var(--text-lg);
  --content-p-size: var(--text-lg);
  --content-lead-size: var(--text-2xl);
  --content-h1-size: var(--text-5xl);
  --content-h2-size: var(--text-3xl);
  --content-h3-size: var(--text-2xl);
  --content-h4-size: var(--text-xl);
  --content-h5-size: var(--text-lg);
  --content-h6-size: var(--text-lg);
  --hero-headline-size: var(--text-5xl);
  --hero-description-size: var(--text-xl);
  --hero-title-md-size: clamp(var(--hero-title-md-size-min), 1rem + 3.5vw, var(--hero-title-md-size-max));
  --hero-title-lg-size: clamp(var(--hero-title-lg-size-min), 1rem + 4.5vw, var(--hero-title-lg-size-max));
  --hero-title-xl-size: var(--display-size);
  --hero-title-xxl-size: clamp(var(--hero-title-xxl-size-min), 1rem + 5.5vw, var(--hero-title-xxl-size-max));

  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  --shadow-button: 0 0 15px 0px rgba(0, 0, 0, 0.15);
  --shadow-button-active: 0 0 8px 4px rgba(0, 0, 0, 0.15);

  --modal-backdrop-blur: 4px;
  --drawer-backdrop-blur: var(--modal-backdrop-blur);
  --kbd-shadow: 0 1px 0 var(--surface-border-color);
}
```

</details>

## Apply the Theme

Use the name you chose in the root HTML element:

```erb
<html data-theme="your-theme-name" lang="<%= I18n.locale %>">
```

Or set it at runtime:

```javascript
document.documentElement.setAttribute("data-theme", "your-theme-name")
```

## Theme Controller Behavior

`flat-pack--theme` treats `data-theme` as a list of names. The value you pick becomes the base. Names that are not in the picker list stay, in their previous order, after the base.

- `system` follows `prefers-color-scheme`. Dark sets the base to `dark`. Light clears owned base names. A custom name such as `featured-in` stays. Storage is cleared.
- `light` clears owned base names (`light`, `dark`, `ocean`, `rounded`, and any other name in the picker list). If none remain, it removes `data-theme`.
- Any other picker value is written first. Custom names stay after it.
- Dark mode is the list containing the whole name `dark`. `featured-in-dark` is not dark.

A single name still behaves as before. Picking `dark` while the attribute is `rounded` sets `dark`. Picking `light` on `rounded` alone removes the attribute.

There is no generator for a full token fork. `flat_pack:theme` writes the brand knobs. `--inherits=rounded` is the stack:

```bash
bin/rails generate flat_pack:theme featured-in --inherits=rounded --hue=330
```

The stylesheet is overrides only. Set `data-theme="rounded featured-in"`. The generated selector is `[data-theme~="featured-in"]`, so `data-theme="featured-in"` still matches.

A nested `data-theme="featured-in"` inside a rounded page keeps the rounded shape. The color file does not restate radii, and `[data-theme]` does not put the moderate radii back. The moderate shape is that name on the root, with no `rounded` ancestor. `data-theme="rounded featured-in"` on the nested element is how that region opts into rounded when the page is not already rounded.

## Where the Canonical Variables Live

The source of truth remains `app/assets/stylesheets/flat_pack/variables.css` in the FlatPack gem or repository.

- `@theme inline {}` contains the token names used by Tailwind utilities. Values are not stored there.
- `:root, [data-theme] {}` contains the default rounded / charcoal palette and component aliases.
- `[data-theme~="dark"]` and `[data-theme~="ocean"]` are **override-only** — they list tokens that differ from the default and inherit the spacing scale. `[data-theme~="rounded"]` shifts the scale. Component aliases re-resolve on `[data-theme]`.

When FlatPack adds a new **semantic** token, copy it into your host theme if you need a different value. Component aliases that are `var(--semantic)` do not need to be re-copied. `--color-ring` follows `--color-primary`. `--sidebar-item-active-*`, `--top-nav-item-active-*`, list, pill, table, and pagination selected fills follow `--surface-active-*`. Hover fills follow `--surface-hover-background-color`. Outgoing chat does too: background is `--surface-hover-background-color`, text is `--surface-content-color`. Incoming stays the muted surface. The shipped dark and ocean themes set `--chat-message-outgoing-background-color` because those hover surfaces do not separate the two bubbles. Set that one token when your own hover and muted fills match. Timestamps and read receipts stay on `--surface-muted-content-color`. Set those semantic tokens once. Set a component token only when that one control should diverge.

## Practical Editing Order

If you do not want to retune hundreds of variables at once, start with these groups first:

1. Core surface and text tokens: `--surface-*`, `--color-primary*` (hover, ring, and active nav follow), `--color-secondary*` / `--color-ghost-*` (follow surface unless you override them), `--color-default*`, `--overlay-backdrop-color`, `--overlay-scrim-color`, `--icon-stroke-width`
2. Global feel tokens: `--radius-*`, `--shadow-*`, `--stack-gap-*`
3. High-visibility component tokens: `--button-*`, `--card-*`, `--modal-*`, `--sidebar-*`, `--top-nav-*`
4. Lower-frequency component tokens only when those components appear in your app

## Related Guides

- [Theming Guide](theming.md)
- [Dark Mode Guide](dark_mode.md)
- [Installation Guide](installation.md)