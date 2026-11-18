# Icon

Draw a Heroicon in the page. The paths are in the HTML. The browser does not load an icon map.

## Purpose

Show a small status, action, or direction glyph inside another component.

## When to use

Use Icon when a component needs a Heroicon. Pass `icon:` on components that already accept it. Use the `fp-red-dot` class when the glyph needs an unread mark.

## Class

- Primary: `FlatPack::Shared::IconComponent`

## Props

| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String or Symbol | none | yes | Heroicons 2.2.0 name, or a shorthand in `NAME_MAP` (`search` is `magnifying-glass`). Underscores become dashes. |
| `size` | Symbol | `:md` | no | One of `:sm`, `:md`, `:lg`, `:xl`. |
| `variant` | Symbol or nil | `FlatPack.configuration.default_icon_variant` (`:outline`) | no | One of `:outline`, `:solid`, `:mini`, `:micro`. |
| `animate` | Symbol or nil | `nil` | no | Optional `flat-pack--svg-motion` preset. |
| `trigger` | Symbol | `:hover` | no | One of the svg-motion triggers. Used only when `animate` is set. |
| `class` | String | `nil` | no | Merged onto the SVG. `fp-red-dot` appends `circle.fp-red-dot-indicator`. |
| `**system_arguments` | Hash | `{}` | no | Extra HTML attributes. `data` and `aria` merge. |

## Slots

None.

## Variants

- `:outline` is a 24×24 stroked icon (`fill="none"`, `stroke-width` from `--icon-stroke-width`).
- `:solid` is a 24×24 filled icon.
- `:mini` is a 20×20 filled icon.
- `:micro` is a 16×16 filled icon.
- Filled variants set `fill="currentColor"` and omit `stroke` and `stroke-width`.

## Example

```erb
<%= render FlatPack::Shared::IconComponent.new(name: "magnifying-glass", size: :md) %>
<%= render FlatPack::Shared::IconComponent.new(name: :search, class: "fp-red-dot") %>
<%= render FlatPack::Shared::IconComponent.new(name: "star", variant: :solid) %>
```

An unknown name, after alias lookup, raises `ArgumentError` in development and test. In other environments it logs `[FlatPack] Unknown heroicon: "..."` and renders an empty SVG with the same size, viewBox, and variant attributes. An invalid size or variant raises in every environment.

Remote select items and picker items that draw an icon include `icon_svg`, the HTML from this component. A name alone does not become a glyph in the browser.

## Accessibility

The SVG is `aria-hidden="true"`. Name the control on the parent (button label, link text, or `aria-label`).

## Dependencies

- `FlatPack::Heroicons` (`lib/flat_pack/heroicons/paths.json`), generated from Heroicons 2.2.0 (MIT) with `npm run build:heroicons`.
- `flat-pack--svg-motion` when `animate` is set.
- No `flat-pack--icon` controller. No `flat_pack/heroicons` pin.
