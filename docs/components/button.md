# Button

## Purpose
Render a button or link with FlatPack styles, validation, and loading/icon states.

## When to use
Use this for primary and secondary actions in forms, toolbars, dialogs, and list rows.

## Class
- `FlatPack::Button::Component`
- `FlatPack::Button::Pill::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `text` | String, nil | `nil` | no | Visible label text. Required unless `icon` is provided. |
| `style` | Symbol | `:default` | no | One of `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:error`. |
| `size` | Symbol | `:md` | no | One of `:sm`, `:md`, `:lg`. |
| `url` | String, nil | `nil` | no | When present, renders an `<a>` via `link_to`; otherwise a `<button>`. |
| `method` | Symbol, nil | `nil` | no | Link method passed to `link_to` (for non-GET link actions). |
| `target` | String, nil | `nil` | no | Link target, for example `"_blank"`. |
| `icon` | String, nil | `nil` | no | Heroicons v2 name rendered before text (or alone with `icon_only`), e.g. `"magnifying-glass"`, `"plus"`, `"trash"`. Legacy shorthand aliases are supported for backward compatibility. |
| `icon_only` | Boolean | `false` | no | Uses compact icon-only padding and hides text/spinner label. |
| `loading` | Boolean | `false` | no | Disables button and shows spinner; text becomes `Loading` when not icon-only. |
| `type` | String | `"button"` | no | Native button type for button mode: `button`, `submit`, `reset`. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes/classes/data/aria. |

## Slots
No slots.

## Variants
- Styles: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:error`
- Sizes: `:sm`, `:md`, `:lg`
- Render modes: button mode (`type`) and link mode (`url`, optional `method`, optional `target`)
- States: loading, icon + text, icon-only

## Pill Group Variant
Use `FlatPack::Button::Pill::Component` when you need the rounded pills styling from the tabs demo as a grouped set of plain link controls for filters, view switches, or segmented navigation outside a tablist.

### Pill Group Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `items` | Array<Hash> | none | yes | One or more pill definitions. Each item requires `text` and `href`, and may include `id`, `active`, `target`, `class`, `data`, and `aria`. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes/classes/data/aria for the outer group wrapper. |

```erb
<%= render FlatPack::Button::Pill::Component.new(
  items: [
    {text: "All products", href: products_path, active: true, id: "products-pill"},
    {text: "On sale", href: sale_products_path}
  ]
) %>
```

## Example
```erb
<%= render FlatPack::Button::Component.new(
  text: "Delete",
  style: :error,
  size: :sm,
  url: post_path(@post),
  method: :delete,
  data: { turbo_confirm: "Delete this post?" }
) %>
```

## Accessibility
- For icon-only buttons, provide an accessible name, for example `aria: { label: "Open settings" }`.
- Focus ring styles are applied by default for keyboard navigation.
- In loading state, the button is disabled to prevent duplicate actions.

## Dependencies
- `FlatPack::Shared::IconComponent` for icon and spinner sizing.
- `FlatPack::AttributeSanitizer` for URL sanitization and protocol allowlisting (`http`, `https`, `mailto`, `tel`, relative URLs).
