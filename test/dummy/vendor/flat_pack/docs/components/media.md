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
| `radius` | Symbol |  | no | Omit it and the frame uses `--media-radius`. `:card_inner` sets `fp-card-inner-radius` on the frame, so the corner is `max(0, card radius − card inset)`. Any other value raises `ArgumentError`. |
| `cover` | Boolean | `false` | no | `true` omits `h-auto` so a featured card's cover height can apply. `false` keeps `h-auto`, and the `width` and `height` attributes do not lock the used height. Anything else raises `ArgumentError`. A featured card's media slot sets this when the block calls `image`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the overlay root. There is no `style`, colour, or theme prop. |

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

The root is `group/media`. A control that should appear on hover can use `group-hover/media:` on the item. Keep it visible for keyboard focus (`focus-within:opacity-100`) and for pointers that cannot hover. On Card media, use `media.hover_actions` instead of copying those utilities. See [Card](card.md). `FlatPack::Reveal::Component` is scroll-in motion and does not hide overlay controls.

## Variants
`width` and `height` set the shape. The frame (`div.fp-media__frame`) owns the radius, the muted fill, and the hairline. Omit `radius:` and that radius is `--media-radius`, which follows `--card-radius`. `radius: :card_inner` uses the card's inner radius. See [Card](card.md).

```erb
<%= render FlatPack::Card::Component.new(padding: :md) do %>
  <%= render FlatPack::Media::Component.new(
    src: "/photos/harbour.jpg",
    alt: "Harbour at dusk",
    width: 1200,
    height: 800,
    radius: :card_inner
  ) %>
<% end %>
```

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
`--media-radius` follows `--card-radius` (default `--radius-lg`). `--media-outline-color` is a 12% mix of `--surface-content-color`. Set either token on `:root` or a named `[data-theme~="…"]` block. Omit `radius:` and there is no prop that resets those tokens.

The frame paints the fill, the hairline, and the radius. The `<img>` is the bitmap. It uses `loading="lazy"` and `decoding="async"`. `width` and `height` write `aspect-ratio` so the box is reserved before the file arrives.

Inside a padded card, `radius: :card_inner` reads `--card-inner-radius`. On the default theme that length is 0 for sm, md, and lg, because the padding is at least the card radius. Outside a card the same option is square, because the card did not set the variable.

## Accessibility
`alt` is required. Use `""` only when nearby text already names the image. Overlay items do not name the image. A button in an item needs its own label. Do not wrap a button in the same link as the image. `group-hover/media:` is visual only. The control must still be reachable by keyboard, and it stays visible when the pointer cannot hover.

## Dependencies
- `FlatPack::Overlay::Component` for placement.
- FlatPack install generator setup (`rails generate flat_pack:install`).
- The frame's fill, hairline, and default radius live in kit CSS (`.fp-media__frame`). `fp-card-inner-radius` does too. Reload kit CSS after an upgrade. A Tailwind rebuild is not required for those rules.
- No Stimulus controller.
