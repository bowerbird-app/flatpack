# Toast Region

## Purpose
Provide a fixed-position stacking region for rendering multiple toast notifications.

## When to use
Use Toast Region as the shared container where toast instances are appended/managed.

## Class
- Primary: `FlatPack::Toasts::Region::Component`
- Related classes: `FlatPack::Toast::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the region wrapper. |

## Slots
None (renders passed block content as region children).

## Variants
None.

## Example
```erb
<%= render FlatPack::Toasts::Region::Component.new do %>
  <%= render FlatPack::Toast::Component.new(message: "Profile updated", type: :success) %>
  <%= render FlatPack::Toast::Component.new(message: "Background sync running", type: :info) %>
<% end %>
```

## Accessibility
- Configures an ARIA live region (`aria-live="polite"`, `aria-atomic="false"`).
- Keep toast message text concise for screen-reader announcements.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Typically composed with `FlatPack::Toast::Component`.
- Stimulus controller: `flat-pack--toasts-region` when using delegated/event-driven toast appends (`toast:add`).
