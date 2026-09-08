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
  <%= render FlatPack::Toast::Component.new(text: "Profile updated", style: :success) %>
  <%= render FlatPack::Toast::Component.new(text: "Background sync running", style: :info) %>
<% end %>
```

## Placement
The region is `.fp-toast-region`: fixed below the TopNav bar (`72px` plus `safe-area-inset-top`) and inset from the right by `safe-area-inset-right` plus one spacing unit. A fallback container created by `flat-pack--toasts-region` uses the same class. Hosts need `viewport-fit=cover` for those insets to apply. See [Installation](../installation.md).

## Accessibility
- Configures an ARIA live region (`aria-live="polite"`, `aria-atomic="false"`).
- Keep toast message text concise for screen-reader announcements.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Typically composed with `FlatPack::Toast::Component`.
- Stimulus controller: `flat-pack--toasts-region` when using delegated/event-driven toast appends (`toast:add` with `{ style, text }`).
