# Overlay

## Purpose
Place any content on top of a photo or other element. The overlay only chooses the spot and the gap from the edge.

## When to use
Use Overlay when a badge, icon, or button should sit on media. Keep the item's own component for colour, type, and shadow. Do not use Overlay for a dialog, a hero wash, or a corner action pinned to the viewport (that is FAB).

## Class
- Primary: `FlatPack::Overlay::Component`
- Related classes: `FlatPack::Overlay::Item`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the overlay root. |

The overlay root is `relative inline-flex` and shrinks to the media. Pass `class: "w-full"` when the media should fill a column. There is no theme, colour, shadow, or item style prop.

## Slots
| name | type | required | description |
|---|---|---|---|
| `media` | slot (`with_media`) | no | The element underneath. One image, video, or other element. It sets the box. |
| `items` | slot (`with_item`, repeatable) | no | Content placed on the media. A badge, icon, button, or anything else. Each item keeps its own look. |

`with_item` props:

| name | type | default | required | description |
|---|---|---|---|---|
| `placement` | Symbol | `:top_left` | no | Nine-cell grid: `:top_left`, `:top_center`, `:top_right`, `:middle_left`, `:center`, `:middle_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`. Invalid values raise `ArgumentError`. Not FAB `position`. |
| `inset` | Symbol | `:md` | no | Gap from the media edge. `:sm`, `:md`, and `:lg` are `8px`, `16px`, and `24px` when `--overlay-edge-offset` is `8px`. The item resolves that length itself. `:center` ignores it. `:top_center`, `:bottom_center`, `:middle_left`, and `:middle_right` use it on the edge axis only. Invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into that item's wrapper. |

Two items with the same `placement` occupy the same spot.

## Variants
None. Placement and inset only change where the item sits.

## Example
```erb
<%= render FlatPack::Overlay::Component.new(class: "w-full") do |overlay| %>
  <% overlay.with_media do %>
    <%= image_tag photo_path, alt: "Stool in a box", class: "block h-auto w-full" %>
  <% end %>

  <% overlay.with_item(placement: :top_left, inset: :sm) do %>
    <%= render FlatPack::Badge::Component.new(text: "New", style: :primary, size: :sm) %>
  <% end %>

  <% overlay.with_item(placement: :bottom_right, inset: :lg) do %>
    <%= render FlatPack::Button::Component.new(text: "Share", style: :primary, size: :sm) %>
  <% end %>
<% end %>
```

## Theming
The gap is in px. It does not follow the root font size. `--overlay-edge-offset` defaults to `8px`. On the item, `:sm` is that token, `:md` is twice it, and `:lg` is three times it: `8px`, `16px`, and `24px` at the default. `:root` does not assign `--overlay-inset-sm`, `--overlay-inset-md`, or `--overlay-inset-lg`, so those lengths are not frozen before they reach the item.

A plain parent can set the edge token and the item follows:

```html
<div style="--overlay-edge-offset: 12px">
  <!-- :sm is 12px, :md is 24px, :lg is 36px -->
</div>
```

A parent inset token wins over that derivation for one size. The item does not set the token, so the parent keeps priority:

```html
<div style="--overlay-edge-offset: 12px; --overlay-inset-md: 20px">
  <!-- :md is 20px. :sm stays 12px. :lg stays 36px. -->
</div>
```

`:center` ignores the gap. Edge-centers use it on the edge axis only.

Carousel chevrons stay at `0.75rem` (`left-3` / `right-3`). The lightbox shell, Modal, Drawer, and Command palette keep `--overlay-padding`. Those insets are not the Overlay item gap.

## Accessibility
The overlay is a positioning wrapper. It does not add a name, role, or description. Write `alt` on the media. Give buttons and links their own labels. A decorative icon stays `aria-hidden`, which `FlatPack::Shared::IconComponent` already does. Position is visual only, so do not rely on placement to convey meaning.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Tailwind must see the positioning class literals in `FlatPack::Overlay::Component` and `FlatPack::Overlay::Item` (`inline-flex`, `contents`, `top-[var(--fp-overlay-item-inset)]` and the `right` / `bottom` / `left` matches, plus `top-1/2`, `left-1/2`, and the translate classes). The length itself is in `application.css` on `[data-fp-inset]`.
- No Stimulus controller.
