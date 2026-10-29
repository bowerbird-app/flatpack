# Color Swatch

## Purpose
Render a circular colour control that shows a colour, optionally names it in a tooltip, and opens the native browser colour picker on click.

## When to use
Use Color Swatch when the person should edit a colour with the native picker — theme editors, brand settings, a single accent well. Compose several pickers in a flex row with kit gap tokens for named roles such as Background, Text, Accent.

To let someone pick one colour from a fixed palette (press-kit covers, accent presets), use `FlatPack::RadioGroup::Component` with `variant: :swatches`. That keeps real radios, one submitted value, and the same circle/ring tokens. Do not wrap either control in `ChipGroup`.

## Class
- Primary: `FlatPack::ColorSwatch::Component`
- Related classes: `FlatPack::Tooltip::Component`, `FlatPack::RadioGroup::Component` (`variant: :swatches` for a fixed palette)

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `color` | String | none | yes | Current colour (American spelling). Prefer `#rrggbb` hex for the native picker; CSS colours and `var(--token)` are accepted for display. Invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Circle size: `:xs`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | When true, shows a selected ring on the circle. |
| `name` | String | `nil` | no | Optional form field name for the native colour input. |
| `value` | String | `nil` | no | Optional native input value override. Defaults to `color` when it is a hex colour; otherwise falls back to `#000000` for the picker. |
| `text` | String | `nil` | no | Human label used as tooltip copy and accessible name. |
| `disabled` | Boolean | `false` | no | Disables the native colour input. |
| `show_tooltip` | Boolean | `true` | no | Wraps the circle in `FlatPack::Tooltip::Component` when `text` is present. |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. `id` is applied to the colour input. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`.
- Selected vs idle: selected shows a ring on the circle.
- Click the circle to open the native `<input type="color">` dialog directly — no intermediate panel.

## Public reset
The native colour picker cannot be empty. `reset` restores the picker and the swatch face to the server-rendered `#rrggbb` on `data-flat-pack--color-swatch-color-value`. That value is the input hex from render (`value:` when it is `#rrggbb`, otherwise `color:` when that is `#rrggbb`, otherwise `#000000`). Reset does not read the input's value at connect time.

Hosts must not reach into the colour input or swatch face. Dispatch a bubbling event on the Color Swatch root (`[data-controller='flat-pack--color-swatch']`), or call the Stimulus method.

| Trigger | What happens |
|---|---|
| Stimulus `reset` | Sets the picker and the face to the server hex, fires `color-swatch:change`, then fires `input` and `change` on the colour input. |
| Event `color-swatch:reset` | Same as `reset`. Wired on the root as `color-swatch:reset->flat-pack--color-swatch#reset`. |
| `event.detail.value` | Optional `#rrggbb`. Sets the picker and the face to that colour instead of the server hex. A blank string keeps the server hex. Anything else throws. |

`detail.value` accepts only `#rrggbb` (six hex digits, either case). `#rgb`, `rgb()`, and `var(--token)` throw. A face painted with a CSS colour is still allowed on `color:` for the first paint. After connect, the face follows the picker hex. Reset returns that hex. It does not put a CSS variable back on the face.

```js
const swatch = document.querySelector("[data-color-swatch='accent']")
swatch.dispatchEvent(new CustomEvent("color-swatch:reset", { bubbles: true }))
swatch.dispatchEvent(new CustomEvent("color-swatch:reset", {
  bubbles: true,
  detail: { value: "#321100" }
}))
```

```erb
<%= render FlatPack::ColorSwatch::Component.new(
  color: "#321100",
  text: "Accent",
  data: { color_swatch: "accent" }
) %>
<button type="button" data-action="click->host-theme#resetAccent">Reset</button>
```

A sibling button is not inside the Color Swatch controller. Dispatch `color-swatch:reset` on the swatch root from the host controller. A descendant control can use `click->flat-pack--color-swatch#reset` directly.

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
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#333333",
    text: "Text",
    name: "theme[text]",
    size: :lg
  ) %>
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#321100",
    text: "Accent",
    name: "theme[accent]",
    size: :lg
  ) %>
</div>
```

## Accessibility
- The control is a native `input[type="color"]` covering the circle, with `aria-label` from `text` (or `"Color"`).
- Tooltip content uses `role="tooltip"` via `FlatPack::Tooltip::Component` when `text` is present.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--color-swatch`, and `flat-pack--tooltip` when tooltips are enabled.
- Public action: `reset`. Public event in: `color-swatch:reset`. Public events out: `input` and `change` on the colour input, and `color-swatch:change` on the root.
- Composes `FlatPack::Tooltip::Component` for the name on hover/focus.
