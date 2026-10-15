# Media

## Purpose
Show one image that reserves its shape, rounds with the theme, and can carry a badge or button on top.

## When to use
Use Media anywhere a photo needs `alt`, a reserved box, and optional overlay items. Use `Masonry` when several of those photos should pack without empty holes. Use `Overlay` alone when the thing underneath is not this image. Use `Video preview` when the frame should load a player on click. `Card::Media` is the padded frame inside a card, not this image.

Link wrapping is the host's job. Do not put a button inside that link. To open a gallery, wrap Media in `FlatPack::Lightbox::Trigger` or put `FlatPack::Lightbox.trigger_data` on a control that is already a button. See [Lightbox](lightbox.md).

## Class
- Primary: `FlatPack::Media::Component`
- Related classes: `FlatPack::Overlay::Component`, `FlatPack::Overlay::Item`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `src` | String |  | yes | Image URL. `http(s)` or a relative URL. Anything else raises `ArgumentError`. |
| `alt` | String |  | yes | Accessible name. Required, including `""` when the image is decorative. Non-strings raise `ArgumentError`. |
| `width` | Integer |  | yes | Positive pixel width. Sets the attribute and, with `height`, `aspect-ratio`. Non-positive values raise `ArgumentError`. |
| `height` | Integer |  | yes | Positive pixel height. Same rules as `width`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the overlay root. There is no `style`, colour, radius, or theme prop. |

There is no `href`. Wrap the component in a link when the photo should navigate.

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `items` | slot (`with_item`, repeatable) | no | Passed through to `FlatPack::Overlay::Item`. A badge, a button, or anything else. |

`with_item` props match Overlay:

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `placement` | Symbol | `:top_left` | no | `:top_left`, `:top_center`, `:top_right`, `:middle_left`, `:center`, `:middle_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`. Invalid values raise `ArgumentError`. |
| `inset` | Symbol | `:md` | no | `:sm`, `:md`, `:lg`. `:center` ignores it. Edge-centers use it on the edge axis only. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into that item's wrapper. |

The root is `group/media`. A control that should appear on hover can use `group-hover/media:` on the item. Keep it visible for keyboard focus (`focus-within:opacity-100`) and for pointers that cannot hover.

## Variants
None. `width` and `height` set the shape. Radius comes from `--media-radius` (default `--radius-md`). The hairline is `--media-outline-color`.

## Example

```erb
<%= render FlatPack::Media::Component.new(
  src: "/photos/harbour.jpg",
  alt: "Harbour at dusk",
  width: 1120,
  height: 1400
) do |media| %>
  <% media.with_item(placement: :bottom_left, inset: :sm) do %>
    <%= render FlatPack::Badge::Component.new(text: "JPG · 1120×1400 · 4:5", size: :xs) %>
  <% end %>
<% end %>
```

A button on the photo. The host leaves this one unlinked:

```erb
<%= render FlatPack::Media::Component.new(src: "/photos/kiln.jpg", alt: "Kiln yard", width: 500, height: 300) do |media| %>
  <% media.with_item(placement: :top_right, inset: :sm, class: "opacity-100 focus-within:opacity-100 [@media(hover:hover)]:opacity-0 [@media(hover:hover)]:group-hover/media:opacity-100 motion-safe:transition-opacity motion-safe:duration-[var(--duration-fast)] motion-safe:ease-[var(--easing-standard)] motion-reduce:transition-none") do %>
    <%= render FlatPack::Button::Component.new(text: "Save", style: :primary, size: :sm) %>
  <% end %>
<% end %>
```

## Theming
`--media-radius` defaults to `--radius-md`. `--media-outline-color` is a 12% mix of `--surface-content-color`. Set either token on `:root` or a named `[data-theme]` block. There is no prop that resets them.

The image uses `loading="lazy"` and `decoding="async"`. `width` and `height` write `aspect-ratio` so the box is reserved before the file arrives. A muted surface fill shows in that box.

## Accessibility
`alt` is required. Use `""` only when nearby text already names the image. Overlay items do not name the image. A button in an item needs its own label. Do not wrap a button in the same link as the image. `group-hover/media:` is visual only. The control must still be reachable by keyboard, and it stays visible when the pointer cannot hover.

## Dependencies
- `FlatPack::Overlay::Component` for placement.
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Tailwind must see the image class literals in `FlatPack::Media::Component`, including `rounded-[var(--media-radius)]` and `outline-[var(--media-outline-color)]`.
- No Stimulus controller.
