# Command palette

## Purpose
Open a searchable overlay of pages and actions, including a Cmd/Ctrl+K shortcut.

## When to use
Use Command palette for jumping across an app. Use Search for a field that stays in the header. Use Combobox for a form value.

## Class
- Primary: `FlatPack::CommandPalette::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `id` | String | none | yes | DOM id. Triggers open with `data-command-palette-id`. |
| `items` | Array of Hash | none | yes | Each hash needs `label:`. Optional `href:`, `icon:`, `hint:` (key labels), `group:`. |
| `placeholder` | String | `"Search commands"` | no | Search field hint. |
| `empty_text` | String | `"No matching commands"` | no | Shown when nothing matches. |
| `shortcut` | Boolean | `true` | no | Listen for Cmd/Ctrl+K. Set `false` when another palette already owns the shortcut. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the overlay root. |

## Slots
None.

## Variants
- Grouped rows via `item[:group]` (defaults to `Commands`).
- Link rows when `href:` is set; otherwise a button that only closes the overlay.

## Example
```erb
<%= render FlatPack::Button::Component.new(text: "Open commands", data: { "command-palette-id": "commands" }) %>

<%= render FlatPack::CommandPalette::Component.new(
  id: "commands",
  items: [
    {label: "Theme variables", href: themes_path, icon: "cog", group: "Go to"},
    {label: "Copy last command", icon: "document", group: "Actions"}
  ]
) %>
```

## Accessibility
- Renders `role="dialog"` and `aria-modal="true"`. Rows are `role="option"`.
- Arrow keys move the highlighted row. Enter activates it. Escape closes.
- Focus is trapped while open. Body scroll lock shares Modal’s count key.
- Overlay uses `.fp-overlay-pad` and `overscroll-behavior: contain`.
- Enter uses `--duration-slow` / `--easing-enter`; exit uses `--duration-base` / `--easing-exit`. Reduced motion fades without scale.

## Dependencies
- Stimulus controller: `flat-pack--command-palette`.
- `FlatPack::Kbd::Component` for hints and the Esc keycap.
- `FlatPack::Shared::IconComponent` for optional row icons.
- Modal surface tokens for the overlay.
