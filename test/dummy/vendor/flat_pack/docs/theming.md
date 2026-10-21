# Theming Guide

FlatPack uses CSS variables for theming, allowing you to customize the appearance without modifying component code.

## Token hierarchy

```text
Brand primitives (--brand-hue, --brand-chroma, --brand-lightness)
    ↓
    Semantic tokens (--color-*, --surface-*, --radius-*, --shadow-*, --font-*, --text-*, --display-*, --duration-*, --easing-*, --icon-*)
    ↓
Component tokens (--button-*, --sidebar-*, …) — defined once as var(--semantic)
    ↓
Components / Stimulus
```

The kit default (no `data-theme`) is the charcoal palette on the compact spacing scale and the moderate shape scale. Named themes (`[data-theme~="dark"]`, `ocean`, or your own) should override **brand/semantic** tokens. `[data-theme~="rounded"]` keeps that palette, shifts `--space-2` through `--space-6`, remaps the menu shells, and changes shape: buttons, badges, tabs, and the chat composer become pills (`--radius-full`). Form controls use `--form-control-radius`, which is `1rem` (16px) on rounded. Chips and menu item highlights stay `--radius-md` (8px). The rounded sidebar highlight is `--radius-md` (8px). The floating panel stays `--radius-xxxl`. Cards, menus, popovers, modals, alerts, and toasts step up to `--radius-xl`. Dark and ocean inherit the compact spacing and the moderate shape. Component padding is `round(nearest, calc(var(--space-N) * var(--density)), 1px)` on `:root, [data-theme]`, so a descendant theme re-resolves it. Concrete `--space-*`, `--density`, and `--radius-*` live on bare `:root` only. Component radii that rounded changes live on that same bare `:root`, not on `[data-theme]`, so a dark region inside rounded keeps that rounded shape. Do not copy `@theme inline` self-maps (`--token: var(--token)`) onto a named theme. `html[data-theme~="rounded"]` is `:root`, so those lines blank the token and sidebar `border-r` falls back to `currentColor`.

On that default, `--sidebar-background-color` is `var(--surface-page-background-color)`, so the rail matches the page. `--sidebar-header-background-color` aliases the sidebar token, so the header follows. Dark and ocean set their own sidebar fill. A host that wants a white rail sets `--sidebar-background-color` after FlatPack CSS. Do not assign colour on `[data-theme~="rounded"]`. Rounded sets spacing and shape. Set `<html data-theme="rounded">` when the generous steps, pill buttons, and 16px form controls should show. Without the attribute, the compact scale and moderate corners apply.

`SidebarLayout` `floating: true` paints the desktop panel with `--sidebar-float-background-color` (`#fff` by default, `oklch(0.22 0.02 250)` on dark), `--sidebar-float-shadow`, and `--sidebar-float-inset` (`1rem`). `--sidebar-float-radius` rounds that panel when there is no `data-theme`, or when the list contains `rounded`. Unset, that token is `--radius-lg` (0.75rem). Rounded sets it to `--radius-xxxl` (2.5rem). Other named themes stay square. The flush rail ignores these tokens.

`height: :content` on a floating rail uses that same inset as a max-height. The flush rail and the mobile drawer ignore it.

The rail width is `--sidebar-width` (`16rem`) open and `--sidebar-collapsed-width` (`4rem`) collapsed. `width: :content` clamps the open desktop rail between `--sidebar-content-min-width` (`12rem`) and `--sidebar-content-max-width` (`20rem`). Named themes do not remap those four. `--sidebar-measured-width` is the used pixel width the controller writes on the column after layout. It is not a theme token. Do not set it on `:root`. The aside starts at `--aside-width` (`20rem`) and a drag stays between `--aside-min-width` (`16rem`) and `--aside-max-width` (`32rem`). Those three are separate from the rail, so a wider details panel does not widen the nav. `--fp-panel-width` is the pixel length a drag writes on the column. It is not a theme token. Do not set it on `:root`. `--resize-handle-color` defaults to `--surface-border-color` and `--resize-handle-active-color` defaults to `--surface-muted-content-color`, and themes override those two only when the default grey fails.

`floating_top_nav: true` uses the rail fill and shadow for the top cards, at every breakpoint. The vertical gap stays `--sidebar-float-inset`. The left and right edges use `--layout-content-inset` plus `--top-nav-float-offset` (`0px`), then the centering from `--layout-content-max-width`. `--layout-content-inset` is the page's horizontal padding: `1rem`, then `2rem` from `640px`. Those lengths match `p-4` and `p-8`, and default `--space-4` and `--space-6`. `.fp-layout-content` applies that padding to the main pane. `.fp-layout-column` is the page column. `--layout-content-max-width` defaults to `100%`, so the column fills the pane and the bar stays on the inset. Set a length to center a measure; the bar follows that column. A nested `max-width` with auto margins does not. Override `--layout-content-inset` to move the page and the bar together. Override `--top-nav-float-offset` when the bar should sit off that edge. `--top-nav-float-radius` rounds the cards. It defaults to `var(--sidebar-float-radius)`, so the cards match the rail until a theme sets it. `[data-theme~="rounded"]` sets it to `var(--radius-full)` (pills). The rail keeps `--sidebar-float-radius`. `--top-nav-float-clearance` is the padding on the scroll pane when content runs under the cards. It defaults to the float inset (or the top safe area, whichever is larger) plus `3.25rem`. Override that token when the cards are taller than a toolbar. If the rendered band is still more than `8px` past the token, the layout raises `--top-nav-float-clearance` on the main column to the bottom of the cards. `--top-nav-float-padding-block` (`0.25rem`) and `--top-nav-float-padding-inline` pad the `left` and `center` cards. The inline default is `max(0.25rem, min(0.75rem, calc(var(--top-nav-float-radius) - var(--sidebar-float-radius))))`. Set it to a plain length when padding should ignore the radius. `--top-nav-float-gap` (`0.75rem`) is the gap between cards on the row. Below `768px` the stylesheet still uses `0.25rem` of inline padding and a `0.5rem` row gap. The docked bar still uses `--top-nav-padding-inline`.

`FlatPack::Backdrop::Component` blurs its photo with `--backdrop-blur` (`40px`), then applies `--backdrop-filter` (`saturate(1)`, so the filter list stays valid). The layer fills with `--backdrop-color` (`transparent`), which shows at the edge where the blur fades. The wash is `--backdrop-tint-color` (the page colour) at `--backdrop-tint-opacity` (`0.55`). Dark alone sets that opacity to `0.78`. `[data-theme~="rounded"]` sets `--backdrop-color` to `#2f2f2f` (the same neutral as the default bottom-nav fill, no hue), `--backdrop-tint-color` to `#000`, and `--backdrop-tint-opacity` to `0.18`. That block follows `[data-theme~="dark"]` at the same specificity, so `data-theme="rounded dark"` keeps `0.18`. Blur and the filter stay on the base defaults. Set those tokens to recolour the wash and the edge. `SidebarLayout`'s `background` slot uses this component and pins it to the viewport. The slot does not use hero or dialog overlay tokens.

If you want a complete copy-pasteable custom theme with every current FlatPack variable, use the [Custom Theming Guide](custom_theming.md). Prefer the brand-kit path below for most apps.

## Fastest path: change the brand color

```bash
bin/rails generate flat_pack:theme Sunrise --hue=35 --chroma=0.2 --lightness=0.52
```

That writes `app/assets/stylesheets/flat_pack_theme_sunrise.css`. Load it after `flat_pack/variables`, then set `<html data-theme="sunrise">` (or use the `flat-pack--theme` controller). Pass `--as_root` to write brand overrides on `:root` instead, so no `data-theme` attribute is needed. Pass `--inherits=rounded` to stack on rounded and set `data-theme="rounded sunrise"`. Named kit selectors are word matches (`[data-theme~="rounded"]`). A single name still matches. A host block loaded later, at the same specificity, wins where the two disagree.

A nested color theme keeps the ancestor's shape. On a page with `data-theme="rounded"`, a region with only `data-theme="harbor"` still uses `--card-radius: var(--radius-xl)`, pill buttons, and `--form-control-radius: 1rem`. Harbor does not set those tokens, and `:root, [data-theme]` does not restate the moderate radii, so the region inherits them. The moderate shape is `data-theme="harbor"` on the root, where no ancestor includes `rounded`. Put `rounded` on the nested element (`data-theme="rounded harbor"`) when that region should be rounded and the page is not. Moving the moderate radii onto `[data-theme]` would make a nested color theme snap back to the default corners. Do not do that.

Or override primitives directly:

```css
:root {
  --brand-hue: 160;
  --brand-chroma: 0.18;
  --brand-lightness: 0.52;
}
```

`--color-primary` is `oklch(var(--brand-lightness) var(--brand-chroma) var(--brand-hue))`. A primary button reads that colour on the element that paints, so a wrapper hex changes rest, text, border, hover, and pressed. Hover mixes the colour 88% toward black on a light page. Pressed mixes at 80%. Dark mixes toward white. The default palette does not set `--color-primary-hover`. Charcoal rest stays `oklch(0.3211 0 0)`. Charcoal chroma `0` stays valid. Set `--color-primary-text` with the brand colour and check AA contrast. White text fails on a light brand such as yellow. CSS cannot pick the text colour. Surfaces keep their own colors unless you override `--surface-*`.

These follow the palette `--color-primary`. A nested wrapper does not change them:

- `--color-ring` for focus rings

These still alias `--color-primary` on `:root, [data-theme]`, so they follow the theme and not a nested wrapper. Set one on a named theme only when it should diverge:

- `--badge-primary-*`, `--progress-fill-color`, `--range-fill-color`, `--range-thumb-color`, `--switch-track-checked-background-color`, `--stepper-current-color`, underline tab marks, the tree's 2px bar, and other primary-filled controls

Primary buttons are not in that list. The kit does not assign `--button-primary-*` on `:root`. Set those names when one control should diverge from the wrapper.

Outgoing chat follows the hover surface, not primary. `--chat-message-outgoing-background-color` is `var(--surface-hover-background-color)` (`#f0f0f0` on the default palette) and `--chat-message-outgoing-text-color` is `var(--surface-content-color)`. Incoming stays `--surface-muted-background-color` (`#e5e5e5`) with the same foreground. Dark and ocean set their own outgoing fill so the two bubbles stay apart: dark hover matches muted, and ocean hover sits on the muted fill. Timestamps, read receipts, and attachment icons use `--surface-muted-content-color`. They sit under the bubble or on the attachment card. Links inside a bubble inherit the bubble text colour.

Selected and hover chrome follows the surface pair instead. Set these once and sidebar, top nav, lists, pills, table rows, pagination, and the other mapped controls move together:

- `--surface-hover-background-color` — hover grey
- `--surface-active-background-color` — selected grey
- `--surface-active-text-color`, `--surface-active-icon-color`, `--surface-active-border-color` — ink and border on that selected grey

`--sidebar-item-active-*`, `--top-nav-item-active-*`, `--list-item-active-background-color`, `--tabs-pill-active-*`, `--table-row-selected-background-color`, and `--pagination-current-*` alias those tokens. Override a component token only when that one control should diverge. Pill `style: :primary` (and any other named pill style) still paints the active pill with that button colour. Omitting `style:` keeps the neutral active surface. That neutral pill is flat: `--tabs-pill-active-shadow` is `none`. Named styles restore `--shadow-md` on the same token.

The bottom nav bar (`--bottom-nav-background-color`) is a dark surface, not a brand fill. Dark and ocean set their own bar colours. Active bottom-nav *items* use `--bottom-nav-item-active-color` (contrast on that bar), not `--color-primary`.

For an exact brand hex, set `--color-primary` and `--color-primary-text` on the wrapper. Hover and pressed follow. Set `--color-primary-hover` only when hover should diverge from the mix. `--button-primary-hover-background-color` wins over that pin:

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
| Host Tailwind loads after kit CSS | Tailwind `@layer theme` sets `--font-sans` to `ui-sans-serif` and `--radius-md` to `0.375rem`. Re-set `--font-sans` / `--font-mono` and `--radius-xs` through `--radius-full` on unlayered `:root` in the host stylesheet so the kit face and kit radii win. Putting them in `@theme` does not replace Tailwind’s defaults. `var(--radius-md, 0.5rem)` in kit CSS only applies when the token is unset. |

`--brand-hue` / `--brand-chroma` / `--brand-lightness` are FlatPack-only and do not overlap Tailwind defaults. `--radius-md` and `--shadow-md` use the same names as Tailwind utilities. FlatPack's default `--radius-md` is `0.5rem`. Kit class names use `rounded-[var(--radius-*)]` so they do not collide with Tailwind's `rounded-md` scale.

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

For a named host-app variant such as `[data-theme~="sunrise"]`, see the theme generator or the [Custom Theming Guide](custom_theming.md).

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
--overlay-inset-sm: 0.5rem
--overlay-inset-md: 1rem
--overlay-inset-lg: 1.5rem

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

Empty State padding, the gap under the icon, image, or visual, the title gap, and the gap before the actions are `--empty-state-padding-*`, `--empty-state-gap-*`, `--empty-state-title-gap-*`, and `--empty-state-block-gap-*`. Each one is `round(nearest, calc(var(--space-N) * var(--density)), 1px)`, so rounded's larger steps loosen the panel. The text measure is `--empty-state-measure-sm` (`20rem`), `--empty-state-measure-md` (`28rem`), `--empty-state-measure-lg` (`36rem`), and `--empty-state-measure-full` (`none`). Those lengths do not follow `--density`.

Collage tilt, offset, hover lift, and stagger are `--collage-rotate` (`5deg`), `--collage-offset-x`, `--collage-offset-y`, `--collage-lift`, and `--collage-stagger` (`--reveal-stagger`, `40ms`). Entrance, idle, and hover use `--collage-duration` (`--motion-duration-slow`), `--collage-easing` (`--motion-ease-out`), `--collage-rise` (`--motion-distance-sm`, `4px`), `--collage-deal` (`100%`), `--collage-deal-duration` (`720ms`), `--collage-drift` (`1deg` over `8s`), `--collage-focus-lift`, `--collage-focus-scale` (`0.97`), and `--collage-focus-dim` (`0.62`). The offsets, the lift, `--collage-gap`, `--collage-pad`, `--collage-bleed`, `--collage-margin`, and `--collage-overlap` are `round(nearest, calc(var(--space-N) * var(--density)), 1px)`, so a rounded page loosens the scatter. `--collage-lift` is `calc(var(--collage-offset-y) * -1)`. `--collage-loose` (`2`) multiplies the subtle unit for `scatter: :loose`. An even grid pads by `--collage-pad` plus `(--collage-offset-y + --collage-bleed)` for each scatter unit. A brick (`rows:`) uses `--collage-margin` (`2rem`, about 32px) and overlaps rows by `--collage-overlap` (a negative `--space-5`). Slot proportion is `--collage-card-ratio` (`0.928`) swayed by `--collage-card-sway` (`0.1`). Below `md` the phone row is `33dvh` tall and each card is `--collage-item-size-sm` wide (about `0.7 * 33dvh` times the ratio). From `md` to `lg` a brick caps each card at `--collage-item-size-md` (`11rem`). Below `stack_below` the extra inset, the overlap, and the tilt drop off. Set `--collage-rotate: 0deg` on a theme to flatten every collage without passing `scatter: :none`.

### Border Radius
```css
--radius-xs: 0.125rem   /* 2px */
--radius-sm: 0.25rem    /* 4px */
--radius-md: 0.5rem     /* 8px */
--radius-lg: 0.75rem    /* 12px */
--radius-xl: 1.25rem    /* 20px */
--radius-xxl: 2rem      /* 32px */
--radius-xxxl: 2.5rem  /* 40px */
--radius-full: 9999px
```

The shape scale lives on bare `:root`, same as `--space-*`. Component radii alias a step and can be overridden:

| Token | Default | `[data-theme~="rounded"]` |
|---|---|---|
| `--button-border-radius` | `--radius-md` | `--radius-full` |
| `--button-round-border-radius` | `--radius-full` | `--radius-full` (not remapped) |
| `--form-control-radius` | `--radius-md` | `1rem` |
| `--badge-radius`, `--tabs-pill-corner-radius` | `--radius-md` | `--radius-full` |
| `--chip-border-radius` | `--radius-md` | `--radius-md` |
| `--sidebar-float-radius` | `--radius-lg` | `--radius-xxxl` |
| `--sidebar-item-radius` | `--radius-lg` | `--radius-md` |
| `--dropdown-item-radius` | `--radius-sm` | `--radius-md` |
| `--chat-composer-radius` | `--radius-lg` | `--radius-full` |
| `--card-radius`, `--menu-radius`, `--popover-radius`, `--modal-radius` | `--radius-lg` | `--radius-xl` |
| `--alert-border-radius`, `--toast-border-radius` | `--radius-lg` | `--radius-xl` |

Rounded sets `--sidebar-float-radius` to `--radius-xxxl` (2.5rem, 40px). The item highlight is `--radius-md` (0.5rem, 8px). The floating panel stays `--radius-xxxl`. Charcoal (no `data-theme`) keeps the floating rail at `--radius-lg`. Dark and ocean stay square.

`Button` `round: true` uses `--button-round-border-radius`, which stays `--radius-full` on the moderate scale and on rounded. An icon-only round button also sets its side from `--button-round-size-sm`, `--button-round-size-md`, or `--button-round-size-lg` (`max(--hit-target-min, padding + icon + border)`), declared with the other button padding formulas so density still applies.

`Search` `collapsible: true` opens to `--search-expanded-width` (`16rem` by default, not remapped by rounded, dark, or ocean). The open width is `min(100%, var(--search-expanded-width))`, so a 390px toolbar does not overflow. The collapsed face uses Button's `--button-round-size-*` tokens. It does not add a second circle scale.

Inputs, select, textarea, search fields, and the date range trigger use `--form-control-radius`. On rounded that token is `1rem` (16px). No radius step equals `1rem`, so the rounded block sets the length directly. Other themes keep `--radius-md` (8px). `--checkbox-radius` is `--radius-xs`. `--comments-inline-input-radius` follows `--form-control-radius`. `--media-radius`, accordion, collapse, and the collection editor follow `--card-radius`. Drawers use `--modal-radius`.

Kit surfaces use `rounded-[var(--radius-sm)]` through `rounded-[var(--radius-xl)]`, `rounded-[var(--radius-full)]`, or the component alias. Rich text toolbar buttons and bubble chrome use `var(--radius-md, 0.5rem)` / `var(--radius-sm, 0.25rem)`. The editor field corners use `--form-control-radius`. Do not use Tailwind's `rounded-sm` / `rounded-md` / `rounded-lg` / `rounded-xl` / `rounded-2xl` in kit components. Those names share `--radius-*` with FlatPack and hide which scale is in play. `rounded-full` stays on true circles: avatar circle, status dots, typing dots, stepper and timeline markers, switch, radio, spinner artwork, carousel dots, and the FAB. `rounded-none` stays on segmented inner edges and collection-editor cells.

If host Tailwind loads after `flat_pack/variables`, re-set the kit radii on unlayered `:root` (same block as `--font-sans`):

```css
:root {
  --radius-xs: 0.125rem;
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1.25rem;
  --radius-xxl: 2rem;
  --radius-xxxl: 2.5rem;
  --radius-full: 9999px;
}
```

`Button` already skips its default radius when the host passes a `rounded-*` class. Other components merge with last-wins, so a host `class: "rounded-xl"` on Card does not replace `--card-radius`. Kit maintainers run `bin/rake flat_pack:audit_radius_language` from this repo. That task audits the gem, not host markup. Remap leftovers with `ruby scripts/rewrite_radius_language.rb` in a checkout of this repository. The gem package does not ship `scripts/`.

### Shadows
```css
--shadow-sm
--shadow-md
--shadow-lg
--shadow-button
--shadow-button-active
```

`--button-shadow` is the rest elevation. `--button-shadow-hover` aliases `--shadow-button`. `--button-shadow-active` aliases `--shadow-button-active`. Ghost and secondary stay unshadowed at rest.

Dark theme (`[data-theme~="dark"]`) adds a faint white hairline to `--shadow-sm` / `--shadow-md` / `--shadow-lg` so cards lift on near-black surfaces. Brand dark themes that want the same lift set those shadow tokens; they are not derived from `--surface-*`. Overlay dimming is `--overlay-backdrop-color`; on-media chrome (carousel chevrons) is `--overlay-scrim-color`. Overlay item gaps are `--overlay-inset-sm`, `--overlay-inset-md`, and `--overlay-inset-lg`. Set those on `:root` or a named theme when the gap should differ from `0.5rem` / `1rem` / `1.5rem`.

### Hit targets
```css
--hit-target-min: 2.75rem   /* 44px — icon-only buttons, modal close, alert dismiss */
--hit-target-inline-min: 1.5rem  /* 24px — chip and badge remove */
```

Kit CSS defines `.fp-hit-target`, `.fp-hit-target-inline`, and `.fp-hit-slop`. `.fp-hit-target` grows the painted box to 44px. `.fp-hit-slop` keeps the control icon-sized and expands the hit with a pseudo-element. Toast close and icon-only `Button` `size: :xs` use that so the paint stays small. `.fp-button` is unlayered, so the slop's transparent background does not replace the button fill. Hosts get those classes from `flat_pack/application` without a Tailwind rebuild. `--button-icon-only-padding-xs` and `--button-round-size-xs` (`2rem`, no hit-target floor) are the `:xs` tokens. The utilities that read them need a Tailwind rebuild.

### Color scheme
`:root` sets `color-scheme: light`. `[data-theme~="dark"]` sets `color-scheme: dark` so native controls, scrollbars, and form chrome match the theme.

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
--text-6xl: 3.75rem
--text-7xl: 4.5rem
--text-8xl: 6rem

--text-6xl--line-height: 1
--text-7xl--line-height: 1
--text-8xl--line-height: 1

--leading-tight: 1.25
--leading-snug: 1.375
--leading-normal: 1.5

--display-size-min: var(--text-5xl)
--display-size-max: 5.5rem
--display-size: clamp(var(--display-size-min), 1rem + 5vw, var(--display-size-max))
--display-tracking: -0.03em
--display-leading: 1.05
--display-weight: 600
```

`--font-*` and `--text-*` are set on `:root` (not only inside `@theme`). `:root` also sets `font-family: var(--font-sans)` and antialiased smoothing. Hosts override `--font-sans` with a brand face. There is no kit webfont. If host Tailwind loads last, re-set `--font-sans` and the kit `--radius-*` values on unlayered `:root` in the host stylesheet — Tailwind’s `@layer theme` stack otherwise replaces the kit face and the kit radii (rich-text chrome follows `--radius-md`).

`--page-title-h1-size` through `--page-title-h6-size` alias `--text-4xl` down to `--text-base`. `--content-p-size` and `--content-kicker-size` are `--text-lg` (1.125rem / 18px). `--content-lead-size` is `--text-2xl`. `--content-h1-size` is `--text-5xl` (3rem). `--content-h2-size` is `--text-3xl`. `--content-h3-size` through `--content-h6-size` step down the same kit scale to `--text-lg`. Bare tags inside `.fp-content` pick these up. Hero headlines use `--text-4xl` then `sm:` `--hero-headline-size` (default `--text-5xl`). Page-surface hero body uses `--hero-description-size` (default `--text-xl`). `--text-6xl` (3.75rem / 60px), `--text-7xl` (4.5rem / 72px), and `--text-8xl` (6rem / 96px) are the display rungs; `@theme inline` maps them so `text-6xl` / `text-7xl` / `text-8xl` work after a Tailwind rebuild. Pairing `--text-*-line-height` tokens are `1`. Product PageTitle and Hero stay on `5xl` and below unless you pass `size: :display`.

`--display-size` is a theme-tunable fluid cover size: `--display-size-min` (`--text-5xl` / 48px) on a phone, about 80px at 1280, and `--display-size-max` (`5.5rem` / 88px) from 1440. Preferred size is `1rem + 5vw`. Override `--display-size-max` (or `--display-size-min`) on a named theme without rewriting the clamp, or replace `--display-size` entirely. `--display-tracking` is `-0.03em`. `--display-leading` is `1.05`. `--display-weight` is `600`, matching content `h1` and Hero headlines. Kit CSS ships unlayered `.fp-display` and `.fp-hero-title` so Tailwind preflight cannot collapse heading size. `FlatPack::HeroTitle::Component` is the cover headline. `:xl` (default) aliases `--display-size`. `:md` clamps `--text-4xl` to `--text-6xl` (`1rem + 3.5vw`). `:lg` clamps `--text-5xl` to `--text-7xl` (`1rem + 4.5vw`). `:xxl` clamps `--text-5xl` to `--text-8xl` (`1rem + 5.5vw`). Override `--hero-title-<size>-size-min` / `-max` without rewriting the clamp. PageTitle `size: :display` and Hero `size: :display` render Hero Title at `:xl` and set the same tokens inline.

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

### Motion
```css
--motion-duration-fast: var(--duration-fast)   /* 150ms */
--motion-duration-base: var(--duration-base)   /* 200ms */
--motion-duration-slow: var(--duration-slow)   /* 300ms */
--motion-duration-slower: 600ms
--motion-delay-sm: 120ms
--motion-delay-md: 250ms
--motion-delay-lg: 450ms
--motion-stagger-sm: 40ms
--motion-stagger-md: 80ms
--motion-stagger-lg: 120ms
--motion-ease-out: var(--easing-enter)
--motion-ease-in-out: cubic-bezier(0.4, 0, 0.2, 1)
--motion-ease-spring: var(--easing-spring)
--motion-distance-sm: 4px
--motion-distance-md: 1rem
--motion-distance-lg: 3rem
--motion-scale: 0.95
--motion-scale-strong: 0.85
--motion-zoom: 1.05
--motion-zoom-strong: 1.2
--reveal-stagger: 40ms
```

`--motion-*` and `--reveal-stagger` are the shared reveal scale. `FlatPack::Number::Component` reads the same duration and `--motion-ease-out` for a count, roll, or fade. Character and icon tracks do too: `:fast`, `:base`, and `:slow` follow `--motion-duration-*`, and easing `enter` follows `--motion-ease-out`. `standard` and `exit` stay on `--easing-standard` and `--easing-exit`. A millisecond duration is unchanged. `.fp-content-enter` and the collage entrance inherit the duration, ease, and `--motion-distance-sm`, so one theme change retunes the kit enter, the collage, and `FlatPack::Reveal`. Default rise and blur use `--motion-distance-md`. `intensity: :strong` uses `--motion-distance-lg`, `--motion-scale-strong`, and `--motion-zoom-strong`. Override a `--collage-*` motion token when a single collage should differ. Reveals use `--motion-ease-out`. Set that to `var(--motion-ease-spring)` or `var(--motion-ease-in-out)` when a theme wants a different curve. `--motion-ease-spring` is the list spring; overlays stay bounce-free. `delay:`, `duration:`, and `stagger:` on a reveal write `--reveal-delay`, `--reveal-duration`, and `--reveal-stagger` on that element. Named steps are the API: delay `:sm` / `:md` / `:lg`, duration `:fast` / `:base` / `:slow` / `:slower`, and stagger `true` (the `--reveal-stagger` default) or `:sm` / `:md` / `:lg`. A non-negative Integer of milliseconds is the escape hatch. Omit a step and the theme token applies (`0ms` for delay, `--motion-duration-slow` for duration). `FlatPack::Number::Component` duration stays `:fast`, `:base`, or `:slow`. Under `prefers-reduced-motion: reduce`, the motion durations, the delay steps, the stagger steps, and `--reveal-stagger` become `0ms`. An instance millisecond is forced to `0ms` on `.fp-reveal` as well.

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
--hero-title-md-size
--hero-title-md-size-min
--hero-title-md-size-max
--hero-title-lg-size
--hero-title-lg-size-min
--hero-title-lg-size-max
--hero-title-xl-size
--hero-title-xl-size-min
--hero-title-xl-size-max
--hero-title-xxl-size
--hero-title-xxl-size-min
--hero-title-xxl-size-max

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
--top-nav-float-radius
--top-nav-float-clearance
--top-nav-float-offset
--top-nav-float-padding-block
--top-nav-float-padding-inline
--top-nav-float-gap
--layout-content-inset
--layout-content-max-width

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

`--color-ring` maps to `var(--color-primary)` on the palette. Active sidebar, top nav, list, pill, table, and pagination fills map to `--surface-active-*` and `--surface-hover-background-color`. Primary button paint is specified on the button. `--button-primary-*` are optional pins. You normally change the brand knobs or `--color-primary` for brand colour, and the surface hover and active tokens for selected chrome.

Alert and toast success/warning/danger wash the status fill into the surface (`color-mix` at 18%) and keep chroma on the icon and border. Info toasts alias the quiet info alert, not `--color-primary`. Buttons, badges, chips, and progress keep the filled `--color-success-*` / `--color-warning-*` / `--color-danger-*` paints. Progress reads those fills through `--progress-*-fill-color` and `.fp-progress-fill`, not Tailwind `bg-primary`. Range input paints the native slider through `.fp-range-input` and `--range-*` tokens, not `accent-color`.

Chat incoming bubbles, avatar fallbacks, and the filled muted grey alias `--surface-muted-*` / `--surface-content-color`. Sidebar, top nav, list, and pill hover alias `--surface-hover-background-color`. Their selected states alias `--surface-active-*`. Named themes inherit those greys from the surface tokens; do not freeze Tailwind slate hexes on the component tokens.

Collection Editor aliases the same surface and list tokens. `--collection-editor-title-color` follows `--surface-content-color`. `--collection-editor-description-color` follows `--surface-muted-content-color`. Row hover follows `--list-item-hover-background-color`. A selected row follows `--list-item-active-background-color`. The drop indicator follows `--color-primary`. Cell lines follow `--collection-editor-border-color`. Override the `--collection-editor-*` names on a parent when only that collection should change. Named themes inherit these aliases and do not need their own copies.

### Buttons
- Colors: `--color-default-*`, `--color-primary-*`, `--color-secondary-*`, `--color-ghost-*`, `--color-success-*`, `--color-warning-*`
- Local paint: `--fp-button-background`, `--fp-button-hover-background`, `--fp-button-text`, `--fp-button-border`. Built-in primary sets those from `--button-primary-*` when the pin is set, and otherwise from `--color-primary` and `--color-primary-text`. Hover reads `--button-primary-hover-background-color`, then `--color-primary-hover`, then the mix. Pressed reads `--button-primary-active-background-color`, then the 80% mix. Slot assignment is `[data-fp-style]`. `.fp-button` is still the chrome. A host-registered style sets the paint tokens on `[data-fp-style="…"]` and does not change the theme. See [Button](components/button.md).
- Leading icon colour: `--button-icon-primary-color` (`--color-primary`), `--button-icon-success-color` (`--color-success-background-color`), `--button-icon-warning-color` (`--color-warning`), `--button-icon-danger-color` (`--color-danger-background-color`). `icon_style: nil` uses the button text. A set style mixes that token 55% toward `--fp-button-text` so the glyph stays readable on every button fill, including host-registered styles. When the icon style matches the button style, the glyph uses `--fp-button-text`. Disabled opacity on `.fp-button` still mutes it. There is no per-button icon class.
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
- Opt-in size slider: `.fp-range-input-ends` with `.fp-range-input-glyph` (theme `--font-sans`) or `.fp-range-input-end-icon`. Ticks are `.fp-range-input-ticks` / `.fp-range-input-tick` using `--surface-muted-content-color`. Preview runtime properties `--fp-range-value`, `--fp-range-scale`, and `--fp-range-max` are not theme tokens. Built-in `sample:` letters (default `Aa`) sit below the track with no fill.

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
- Lightbox fills the viewport. The dialog stays transparent. `--modal-backdrop-color` and `--modal-backdrop-blur` are the background. Controls and the count use the carousel chrome tokens. Captions use `--carousel-caption-overlay-text-color`. The thumbnail strip uses `--carousel-thumb-border-color` and `--carousel-thumb-placeholder-*`. `--carousel-lightbox-image-background-color` is the non-stage `fit: :contain` frame, not a lightbox panel. There is no lightbox colour prop.
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

`var()` inside a custom property is computed on the element that declares it. `--badge-primary-background-color: var(--color-primary)` on `:root, [data-theme]` re-resolves when `data-theme` is on `<body>`. Primary buttons do not use that alias. The button specifies the fallback itself, so a wrapper `--color-primary` changes the face without a theme attribute. Prefer `data-theme` on `<html>` when you can. Either placement works for the aliases that remain on `[data-theme]`.

Dark and ocean set `--color-primary` directly. Their focus rings and active nav fills follow that primary. They do not restate `--color-ring`.

## Auditing tokens

```bash
bin/rake flat_pack:audit_tokens
bin/rake flat_pack:audit_radius_language
```

`audit_tokens` fails if any `var(--*)` / Tailwind `bg-(--*)` reference in the gem is missing from `variables.css`. `audit_radius_language` fails if kit Ruby, JavaScript, or gem CSS still uses Tailwind radius scale names (`rounded-md`, `rounded-lg`, and the rest) or the old Tailwind radius fallbacks. It audits `FlatPack::Engine.root`, not a host app.
