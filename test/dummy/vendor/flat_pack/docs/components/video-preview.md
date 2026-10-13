# Video preview

## Purpose
Show a still frame and a play button. The player stays unloaded until someone presses play.

## When to use
Use Video preview for a trailer, lesson, or clip that should not fetch until the visitor asks. The host writes the player (an iframe, a video tag, or anything else). Flatpack does not know about providers, does not build embed URLs, and does not accept a raw embed string. The host decides which players are allowed.

Do not use it for a photo with a badge (that is Overlay) or a sliding gallery (that is Carousel).

## Class
- Primary: `FlatPack::VideoPreview::Component`
- Related classes: `FlatPack::Overlay::Component`, `FlatPack::Overlay::Item`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `label` | String |  | yes | Accessible name of the play button, for example `"Play: Launch trailer"`. The host translates this string. Flatpack does not ship a default. |
| `aspect_ratio` | String | `"16/9"` | no | Frame shape. Same values as Card media: `"16/9"`, `"4/3"`, `"1/1"` (`aspect-square`), or a custom ratio such as `"21/9"`. Invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the frame. |

There is no `style`, colour, or theme prop. The frame uses Card media rounding (`rounded-[var(--radius-lg)]`) and the play control uses button surface tokens.

## Slots
| name | type | required | description |
|---|---|---|---|
| `media` | slot (`with_media`) | yes | Thumbnail in the frame. A direct `img` covers the frame. |
| `player` | slot (`with_player`) | yes | Player markup. Rendered inside a `<template>` so the browser does not load it until activation. One root element (an iframe or a video tag) fills the frame. |
| `items` | slot (`with_item`, repeatable) | no | Passed through to `FlatPack::Overlay::Item`. `placement` and `inset` use that component's nine-cell grid and gap. A duration badge is a typical item. |

`with_item` props match Overlay:

| name | type | default | required | description |
|---|---|---|---|---|
| `placement` | Symbol | `:top_left` | no | `:top_left`, `:top_center`, `:top_right`, `:middle_left`, `:center`, `:middle_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`. Invalid values raise `ArgumentError`. |
| `inset` | Symbol | `:md` | no | `:sm`, `:md`, `:lg`. `:center` ignores it. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into that item's wrapper. |

The play button is always centred. It is not an item. An item on `:center` shares that spot.

## Variants
None.

## Example
```erb
<%= render FlatPack::VideoPreview::Component.new(label: "Play: Launch trailer") do |preview| %>
  <% preview.with_media do %>
    <%= image_tag poster_path, alt: "", class: "block h-full w-full object-cover" %>
  <% end %>

  <% preview.with_player do %>
    <iframe src="<%= trailer_embed_url %>" title="Launch trailer" allow="autoplay" allowfullscreen></iframe>
  <% end %>
<% end %>
```

Duration badge, passed through to Overlay:

```erb
<%= render FlatPack::VideoPreview::Component.new(label: "Play: Launch trailer", aspect_ratio: "16/9") do |preview| %>
  <% preview.with_media do %>
    <%= image_tag poster_path, alt: "" %>
  <% end %>

  <% preview.with_item(placement: :bottom_left, inset: :sm) do %>
    <%= render FlatPack::Badge::Component.new(text: "2:14", size: :sm) %>
  <% end %>

  <% preview.with_player do %>
    <iframe src="<%= trailer_embed_url %>" title="Launch trailer" allow="autoplay" allowfullscreen></iframe>
  <% end %>
<% end %>
```

## Accessibility
The play button's accessible name is `label:`. The icon is decorative. Activate with a click, Enter, or Space. Activation runs once: the template contents replace the thumbnail and the play button inside the same frame, then focus moves to the first focusable element in the player. If nothing in the player can take focus, the player container gets `tabindex="-1"` and takes focus. The component dispatches `flat-pack:video-preview:play` on the frame.

A click on a link or button in an overlay item does not start playback. Give the thumbnail `alt=""` when `label:` already names the clip, so the name is not announced twice.

With `prefers-reduced-motion: reduce`, the swap is instant and the play button does not move on press. The host's player markup decides whether media autoplays. Flatpack does not start playback itself.

## Dependencies
- `FlatPack::Overlay::Component` for the thumbnail, the centred play button, and item placement.
- Stimulus controller `flat-pack--video-preview` (`app/javascript/flat_pack/controllers/video_preview_controller.js`).
- Reduced motion uses `prefersReducedMotion`, `motionDuration`, and `motionTransition` from `controllers/flat_pack/reduced_motion`.
- Tailwind must see the frame, aspect-ratio, and play-button class literals in `FlatPack::VideoPreview::Component`.
- `.fp-video-preview__player` in `flat_pack/application.css` fills the inserted player.
