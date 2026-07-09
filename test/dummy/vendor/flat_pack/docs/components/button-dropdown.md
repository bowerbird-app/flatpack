# Button Dropdown

## Purpose
Provide a button-triggered action menu with keyboard navigation and managed open/close behavior.
The menu is floated with viewport positioning so it can escape clipped cards, panels, and sidebars.

## When to use
Use Button Dropdown when multiple related actions should be grouped behind a single trigger.

## Class
- Primary: `FlatPack::Button::Dropdown::Component`
- Related classes: `FlatPack::Button::DropdownItem::Component`, `FlatPack::Button::DropdownDivider::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Trigger label text. |
| `style` | Symbol | `:default` | no | Trigger style. Delegates to `FlatPack::Button::Component` schemes (for example `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`). |
| `size` | Symbol | `:md` | no | Trigger size. Delegates to `FlatPack::Button::Component` sizes (for example `:sm`, `:md`, `:lg`). |
| `icon` | String/Symbol | `nil` | no | Optional leading icon in the trigger. |
| `show_chevron` | Boolean | `true` | no | Shows the dropdown chevron icon when true. |
| `disabled` | Boolean | `false` | no | Disables trigger interaction and applies disabled styling. |
| `position` | Symbol | `:bottom_right` | no | Menu placement: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`; invalid values raise `ArgumentError`. |
| `max_height` | String | `"384px"` | no | Applied to menu `max-height` style; menu scrolls when content exceeds this value. |
| `trigger_attributes` | Hash | `{}` | no | HTML attributes applied to the trigger button, useful for icon-only `title`, `aria-label`, or extra classes. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
Use `menu_item` and `menu_divider` as the slot builders (without a `with_` prefix).

| name | type | required | description |
|---|---|---|---|
| `menu_item` | slot | no | Adds `FlatPack::Button::DropdownItem::Component` entries. |
| `menu_divider` | slot | no | Adds `FlatPack::Button::DropdownDivider::Component` separators. |

`menu_item` props:

| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Item label text. |
| `icon` | String/Symbol | `nil` | no | Optional leading icon. |
| `badge` | String | `nil` | no | Optional badge content. |
| `badge_style` | Symbol | `:primary` | no | Badge style: `:default`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`, `:info`; invalid values raise `ArgumentError` when badge is present. |
| `href` | String | `nil` | no | Link destination. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Makes item non-focusable and non-interactive. |
| `destructive` | Boolean | `false` | no | Applies destructive visual treatment. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for item element. |

## Variants
- Position variants: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`.
- Trigger visual variants come from button `style` and `size` props.

## Example
```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions", position: :bottom_right) do |dropdown| %>
  <% dropdown.menu_item(text: "Edit", href: edit_post_path(@post)) %>
  <% dropdown.menu_divider %>
  <% dropdown.menu_item(text: "Delete", destructive: true) %>
<% end %>
```

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "",
  icon: "ellipsis-vertical",
  style: :ghost,
  size: :sm,
  show_chevron: false,
  trigger_attributes: {
    title: "Conversation actions",
    aria: { label: "Conversation actions" }
  }
) do |dropdown| %>
  <% dropdown.menu_item(text: "Search conversation", icon: "magnifying-glass", href: "#") %>
  <% dropdown.menu_item(text: "Archive", icon: "folder", href: "#") %>
<% end %>
```

## Accessibility
- Trigger uses `aria-haspopup="true"` and toggles `aria-expanded`.
- For icon-only triggers, pass a descriptive `aria-label` via `trigger_attributes`.
- Menu uses `role="menu"`; items use `role="menuitem"`; divider uses `role="separator"`.
- Keyboard behavior supports `Escape`, arrow navigation, `Home`, and `End`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--button-dropdown`.
