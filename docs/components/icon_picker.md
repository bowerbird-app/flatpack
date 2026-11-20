# Icon picker

## Purpose
Choose one Heroicon by sight and submit its name with a normal form.

## When to use
Use Icon picker when a person should see the glyph, not a long list of names. A labelled field and a compact table cell are both built in. Pass `icons:` when the host only allows some names.

## Class
- Primary: `FlatPack::IconPicker::Component`
- Related classes: `FlatPack::Shared::IconComponent`, `FlatPack::Select::Component`, `FlatPack::FormField::Component` (internal label, help text, and error wrapper)

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String | none | yes | Form field name. A blank name raises `ArgumentError`. |
| `value` | String, nil | `nil` | no | Selected Heroicon name. An alias such as `search` is stored as the canonical name. A name that is not in the allowed set is ignored, and the field submits blank. |
| `icons` | Array, nil | `nil` | no | Allowed names. `nil` is every Heroicon Flatpack ships for `variant:`. An unknown name raises `ArgumentError`. An empty array raises `ArgumentError`. Anything that is not an Array raises `ArgumentError`. |
| `variant` | Symbol, String | `:outline` | no | `:outline`, `:solid`, `:mini`, or `:micro`. Anything else raises `ArgumentError`. |
| `label` | String, nil | `nil` | no | Visible label. Omit it on a table cell. |
| `placeholder` | String | Choose an icon | no | Shown when nothing is selected. `nil` or `""` is an explicit blank. |
| `search_placeholder` | String | Search icons | no | Placeholder on the search field inside the panel. |
| `include_blank` | Boolean, String | `false` | no | `true` adds a None choice. A String uses that label. Anything else raises `ArgumentError`. |
| `show_name` | Boolean, nil | `true` for `:field`, `false` for `:cell` | no | When true, the closed trigger shows the icon name beside the glyph. A selected cell stays icon-only unless this is true. An empty trigger still shows the placeholder. |
| `chrome` | Symbol | `:field` | no | `:field` is the bordered control. `:cell` drops the border, radius, and background. Anything else raises `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Disables the trigger and the hidden input. |
| `required` | Boolean | `false` | no | Sets `required` on the hidden input. |
| `error` | String, nil | `nil` | no | Error message under the control. Marks the trigger and the hidden input `aria-invalid`. |
| `help_text` | String, nil | `nil` | no | Plain text under the control. HTML is not accepted. |
| `id` | String, nil | generated | no | Id of the trigger. The hidden input id is that id plus `_value`. The panel id is that id plus `_panel`. |
| `**system_arguments` | Hash | `{}` | no | `class` is added to the trigger. |

## Slots
None.

## Variants
- `chrome: :field` is a labelled form control.
- `chrome: :cell` is the same control for a table cell.
- `variant:` selects the Heroicon drawing: `:outline`, `:solid`, `:mini`, or `:micro`.

## Example
```erb
<%= render FlatPack::IconPicker::Component.new(
  name: "category[icon]",
  label: "Icon",
  value: "star",
  include_blank: true,
  help_text: "Shown beside the name."
) %>

<%= render FlatPack::IconPicker::Component.new(
  name: "row[icon]",
  value: "inbox",
  chrome: :cell
) %>

<%= render FlatPack::IconPicker::Component.new(
  name: "nav[icon]",
  label: "Nav icon",
  icons: %w[star heart bolt inbox calendar]
) %>
```

The closed control renders the selected icon only. The grid of icons is one `<template>` per variant and allow-list on the page. The first open copies that template into the panel. A hidden input named with `name:` submits the icon name and dispatches `change`.

The panel uses `position: fixed` and the same placement helper as Popover. It flips above the trigger near the bottom of the viewport, stays at least 18rem wide when the screen allows, and scrolls inside a capped height. A modal body or an overflow table cell does not clip it.

## Accessibility
- The trigger is a button with `aria-haspopup="dialog"` and `aria-expanded`.
- Enter, Space, or Arrow Down opens the panel and moves focus to the search field.
- Arrow Down from the search field moves into the grid. Arrow keys move by column. Home and End jump to the ends. Enter or Space picks the icon. Escape closes the panel and returns focus to the trigger.
- Each icon button's accessible name is the icon name, with hyphens read as spaces. The selected button has `aria-pressed="true"`.
- Search is a case-insensitive substring match. Hyphens and spaces are treated the same. An empty match shows "No icons found".

## Dependencies
- Stimulus controller: `flat-pack--icon-picker`.
- `flat_pack/icon_picker`, `flat_pack/positioning`, and `flat_pack/click_outside`.
- Heroicon paths from `FlatPack::Heroicons`.
- Copy keys under `flatpack.icon_picker.*`.
