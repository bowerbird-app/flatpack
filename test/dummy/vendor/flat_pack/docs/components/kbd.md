# Keyboard

## Purpose
Render one or more keyboard keys as compact keycaps.

## When to use
Use Kbd next to a shortcut hint, in help copy, or inside Command palette rows. Do not use it for generic badges.

## Class
- Primary: `FlatPack::Kbd::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `keys` | Array of String | none | yes | One or more key labels, shown in order with `+` between them. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the wrapper. |

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::Kbd::Component.new(keys: ["Cmd", "K"]) %>
```

## Accessibility
- Each key is a `<kbd>`. Separators are `aria-hidden`.

## Dependencies
- Tokens: `--kbd-background-color`, `--kbd-border-color`, `--kbd-text-color`, `--kbd-muted-color`, `--kbd-shadow`.
