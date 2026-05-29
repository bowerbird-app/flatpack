# Page Nav

## Purpose
Render a compact icon-only page navigation row with a browser-history back control plus an optional anchor link action and optional right slot action.

## When to use
Use Page Nav when the layout needs quick icon actions at the top of a page: go back, close/cancel, and a custom right-side action (for example add/create).

## Class
- `FlatPack::PageNav::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `back_icon` | String | `"chevron-left"` | no | Icon name for the back button. |
| `back_label` | String | `"Go back"` | no | Accessible label for back icon button. |
| `back_style` | Symbol | `:secondary` | no | Button style for back action. |
| `back_size` | Symbol | `:md` | no | Button size for back action. |
| `anchor_url` | String, nil | `nil` | no | When present, renders the middle anchor icon as a link. |
| `anchor_icon` | String | `"x-mark"` | no | Icon name for anchor action. |
| `anchor_label` | String | `"Close"` | no | Accessible label for anchor icon link. |
| `anchor_style` | Symbol | `:secondary` | no | Button style for anchor action. |
| `anchor_size` | Symbol | `:md` | no | Button size for anchor action. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes and classes for the wrapper nav element. |

## Slots
- `right_slot`: Renders custom content on the right side of the nav row.

## Variants
- Back only (default)
- Back + anchor (`anchor_url`)
- Back + right action (`right_slot`)
- Back + anchor + right action (`anchor_url` and `right_slot`)

## Example
```erb
<%= render FlatPack::PageNav::Component.new(
  anchor_url: demo_path
) do |component| %>
  <% component.right_slot do %>
    <%= render FlatPack::Button::Component.new(
      icon: "plus",
      icon_only: true,
      url: demo_forms_path,
      aria: { label: "Add" }
    ) %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::PageNav::Component.new(
  anchor_url: demo_path
) do |component| %>
  <% component.right_slot do %>
    <%= render FlatPack::Button::Dropdown::Component.new(
      text: "",
      icon: "ellipsis-vertical",
      style: :ghost,
      size: :sm,
      show_chevron: false,
      trigger_attributes: {
        title: "More actions",
        aria: { label: "More actions" }
      }
    ) do |dropdown| %>
      <% dropdown.menu_item(text: "Edit", href: demo_forms_path) %>
      <% dropdown.menu_item(text: "Archive", href: demo_path) %>
    <% end %>
  <% end %>
<% end %>
```

## Accessibility
- Wrapper renders `nav[aria-label="Page navigation"]`.
- Icon-only controls include explicit `aria-label` values.
- Back action uses a button (`window.history.back()`).
- Anchor action uses a link when `anchor_url` is provided.
- Right-side behavior is defined by the consumer via `right_slot` content.

## Dependencies
- `FlatPack::Button::Component` for icon-only button rendering and URL sanitization.
- `flat-pack--page-nav` Stimulus controller for browser history back behavior.
