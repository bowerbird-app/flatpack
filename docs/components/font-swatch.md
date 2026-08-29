# Font Swatch

## Purpose
Render a circular font control that shows a two-letter sample in the selected face, names the font in a tooltip, and opens a native `<select>` of host-provided fonts on click.

## When to use
Use Font Swatch in theme editors and brand settings alongside Color Swatch. Compose several swatches in a flex row with kit gap tokens when you need a named palette (for example Background, Text, Accent, Font). Do not wrap swatches in `ChipGroup` — that component is for chips. Do not wrap Font Swatch in `FlatPack::Popover`.

## Class
- Primary: `FlatPack::FontSwatch::Component`
- Related classes: `FlatPack::Tooltip::Component`, `FlatPack::ColorSwatch::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `font` | String | none | yes | Current CSS `font-family` value. Accepts generic families, quoted/unquoted names, comma stacks, and `var(--token)`. Invalid values raise `ArgumentError`. |
| `options` | Array | none | yes | Font choices as `[[label, value], …]` or `[{label:, value:}, …]`. Values must be safe CSS font-family strings. Empty or malformed options raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Circle size: `:xs`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | When true, shows a selected ring on the circle. |
| `name` | String | `nil` | no | Optional form field name for the native select. |
| `text` | String | selected option label | no | Human label used as tooltip copy and accessible name. Defaults to the selected option’s label when omitted. |
| `disabled` | Boolean | `false` | no | Disables the native select. |
| `show_tooltip` | Boolean | `true` | no | Wraps the circle in `FlatPack::Tooltip::Component` when tooltip text is present. |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. `id` is applied to the select. Extra `data:` merges onto the root (for example `default_font` for a later Reset). |

## Tokens
| token | purpose |
|---|---|
| `--font-swatch-radius` | Circle radius (kit default matches Color Swatch). |
| `--font-swatch-border-color` | Face border. |
| `--font-swatch-selected-ring-color` | Selected / focus ring colour. |
| `--font-swatch-ring-offset-color` | Selected ring offset fill. |
| `--font-swatch-shadow` | Face shadow. |
| `--font-swatch-background-color` | Face background behind the sample. |
| `--font-swatch-text-color` | Sample text colour. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg` (same circle scale as Color Swatch / Avatar).
- Selected vs idle: selected shows a ring on the circle.
- Click the circle to open the native `<select>` directly — no Popover and no “Choose font” panel.
- The face always shows `Aa` (or the component sample) set in the selected font. There is no under-circle label.

## Example
```erb
<div class="flex flex-wrap items-start gap-[var(--stack-gap-md)]">
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#f8f9fa",
    text: "Background",
    name: "theme[background]",
    selected: true,
    size: :lg
  ) %>
  <%= render FlatPack::FontSwatch::Component.new(
    font: "ui-sans-serif",
    options: [
      ["Sans", "ui-sans-serif"],
      ["Serif", "ui-serif"],
      ["Mono", "ui-monospace"],
      ["Georgia", "Georgia, serif"]
    ],
    name: "theme[font]",
    text: "Sans",
    size: :lg
  ) %>
</div>
```

## Accessibility
- The control is a native `<select>` covering the circle, with `aria-label` from `text` (or the selected option label, or `"Font"`).
- Tooltip content uses `role="tooltip"` via `FlatPack::Tooltip::Component` when enabled.
- Stimulus updates the sample face, tooltip copy, and `aria-label` when the select value changes.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--font-swatch`, and `flat-pack--tooltip` when tooltips are enabled.
- Composes `FlatPack::Tooltip::Component` for the font name on hover/focus.
