# Button Component

## Purpose
Render a button or link with FlatPack styles, validation, and loading/icon states.

## When to use
Use this for primary and secondary actions in forms, toolbars, dialogs, and list rows.

## Class
- `FlatPack::Button::Component`

## Props
| Prop | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | String, nil | `nil` | Visible label text. Required unless `icon` is provided. |
| `style` | Symbol | `:default` | One of `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:error`. |
| `size` | Symbol | `:md` | One of `:sm`, `:md`, `:lg`. |
| `url` | String, nil | `nil` | When present, renders an `<a>` via `link_to`; otherwise a `<button>`. |
| `method` | Symbol, nil | `nil` | Link method passed to `link_to` (for non-GET link actions). |
| `target` | String, nil | `nil` | Link target, for example `"_blank"`. |
| `icon` | String, nil | `nil` | Heroicons v2 name rendered before text (or alone with `icon_only`), e.g. `"magnifying-glass"`, `"plus"`, `"trash"`. Legacy shorthand aliases are supported for backward compatibility. |
| `icon_only` | Boolean | `false` | Uses compact icon-only padding and hides text/spinner label. |
| `loading` | Boolean | `false` | Disables button and shows spinner; text becomes `Loading` when not icon-only. |
| `type` | String | `"button"` | Native button type for button mode: `button`, `submit`, `reset`. |
| `**system_arguments` | Hash | `{}` | Forwarded HTML attributes/classes/data/aria. |

## Slots
No slots.

## Variants
- Styles: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:error`
- Sizes: `:sm`, `:md`, `:lg`
- Render modes: button mode (`type`) and link mode (`url`, optional `method`, optional `target`)
- States: loading, icon + text, icon-only

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
