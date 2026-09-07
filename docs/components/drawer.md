# Drawer

## Purpose
Slide a panel in from the left, right, or bottom for filters, details, or short actions.

## When to use
Use Drawer when the work stays on the current page but needs more room than a popover. Use Modal for a centered blocking dialog. Do not use Drawer in place of `SidebarLayout`.

## Class
- Primary: `FlatPack::Drawer::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `id` | String | none | yes | DOM id. Triggers open with `data-drawer-id` matching this value. |
| `title` | String | `nil` | no | Header title when the `header` slot is omitted. |
| `side` | Symbol | `:right` | no | Edge: `:left`, `:right`, or `:bottom`. |
| `size` | Symbol | `:md` | no | Width for left/right (`:sm` / `:md` / `:lg`) or height for bottom. |
| `close_on_backdrop` | Boolean | `true` | no | Close when the dimmed backdrop is clicked. |
| `close_on_escape` | Boolean | `true` | no | Close on Escape. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the overlay root. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `header` | method/slot | no | Replaces the title text area. |
| `body` | method/slot | no | Scrollable panel body. |
| `footer` | method/slot | no | Action row. |

Use `drawer.header` / `drawer.body` / `drawer.footer`. There is no `with_` prefix.

## Variants
- Edge via `side`.
- Size via `size`.

## Example
```erb
<%= render FlatPack::Button::Component.new(text: "Open filters", data: { "drawer-id": "filters-drawer" }) %>

<%= render FlatPack::Drawer::Component.new(id: "filters-drawer", title: "Filters", side: :left) do |drawer| %>
  <% drawer.body do %>
    <p>Narrow the list without leaving the page.</p>
  <% end %>
  <% drawer.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Apply", data: { action: "click->flat-pack--drawer#close" }) %>
  <% end %>
<% end %>
```

## Accessibility
- Renders `role="dialog"`, `aria-modal="true"`, and `aria-labelledby` when a title or header is present.
- Focus moves into the panel; Tab cycles inside; close restores the trigger.
- Body scroll lock shares the same count key as Modal (`flatPackModalLockCount`).
- Overlay and `.fp-drawer-body` use `overscroll-behavior: contain`. The panel uses `.fp-overlay-pad`.
- Enter uses `--duration-slow` / `--easing-enter`; exit uses `--duration-base` / `--easing-exit`. Reduced motion fades without a slide. Motion writes the Tailwind v4 `translate` property (not `transform`).

## Dependencies
- Stimulus controller: `flat-pack--drawer`.
- Tokens alias Modal: `--drawer-backdrop-color`, `--drawer-surface-color`, `--drawer-border-color`, `--drawer-title-color`, `--drawer-body-color`, `--drawer-close-icon-color`, `--drawer-close-icon-hover-color`, `--drawer-backdrop-blur`.
