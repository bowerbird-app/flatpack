# Lightbox

## Purpose
Open one overlay on a photo or video, starting from the thumbnail, button, or carousel slide the person clicked.

## When to use
Use Lightbox when a control should enlarge media that already lives somewhere else on the page. The gallery is one component. Triggers are separate, so the thumbnails can sit in Masonry, a grid, a Collection, or several places and still open the same items. Use Carousel `lightbox: true` when the sequence itself should open this overlay. Use Modal when the layer is a form or a page, not a gallery.

## Class
- Primary: `FlatPack::Lightbox::Component`
- Related classes: `FlatPack::Lightbox::Trigger`, `FlatPack::Carousel::Component`

`FlatPack::Lightbox.trigger_data(group:, index:)` returns the attributes for a control that is already a button. `flat_pack_lightbox_trigger` renders `FlatPack::Lightbox::Trigger`.

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `group` | String |  | yes | Gallery name. Starts with a letter. Then letters, numbers, hyphens, or underscores. Triggers use the same name. |
| `items` | Array<Hash> |  | yes | Media in order. Each hash needs `src`. Optional `alt`, `caption`, and `type` (`:image` or `:video`). `poster`, `controls`, `muted`, `video_loop`, and `playsinline` pass through for video. At least one safe URL is required. |
| `loop` | Boolean | `true` | no | Wrap from the last item to the first. `true` or `false` only. |
| `show_count` | Boolean | `true` | no | Show `3 / 12` when there is more than one item. `true` or `false` only. |
| `thumbs` | Boolean | `false` | no | Show a thumbnail strip when there is more than one item. `true` or `false` only. Passed to Carousel `show_thumbs`. |

There is no `class`, `style`, or colour prop. The dialog fills the viewport and stays transparent. The backdrop is the background. Media keeps its own shape.

### Item hash

| key | type | default | required | description |
|-----|------|---------|----------|-------------|
| `src` | String |  | yes | `http(s)` or a relative URL. Unsafe URLs are dropped. |
| `alt` | String | Item number | no | Accessible name. Falls back to I18n `flatpack.lightbox.item`. |
| `caption` | String | `""` | no | Copy under the media when any item has one. It sits below the picture or video, on the backdrop. |
| `thumb_src` | String | `src` | no | Thumbnail URL. A safe `http(s)` or relative URL. Anything else is dropped and the thumb uses `src`. |
| `type` | Symbol | inferred | no | `:image` or `:video`. A `.mp4` src, or a `poster`, infers `:video`. Anything else raises `ArgumentError`. |
| `poster` | String | `nil` | no | Video poster URL. |
| `controls` | Boolean | `true` | no | Native video controls. |
| `muted` | Boolean | `false` | no | Passed to `<video muted>`. |
| `video_loop` | Boolean | `false` | no | Passed to `<video loop>`. |
| `playsinline` | Boolean | `true` | no | Passed to `<video playsinline>`. |

### Trigger

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `group` | String |  | yes | Same rules as the gallery `group`. |
| `index` | Integer | `0` | no | Zero-based item to open. Negative indexes raise `ArgumentError`. |

`Trigger` does not take `class` or `style`. It renders a `<button type="button">`. Do not put it inside another button. Put `FlatPack::Lightbox.trigger_data` on `FlatPack::Button` instead.

## Slots
`Trigger` renders its block as the button label. The gallery component has no slots.

## Variants
None. The overlay is full-screen. There is no boxed panel and no prop to bring one back. One item hides the previous and next arrows and the count. Several items show them. `loop: false` stops at the ends.

The dialog is `h-dvh`, transparent, and covers the viewport. `::backdrop` uses `--modal-backdrop-color` and `--modal-backdrop-blur`. Each image or video is `object-fit: contain` on a transparent stage, so a square or portrait item stays that shape and does not sit in a frame. Close, previous, next, and the count float on the backdrop. A caption, when any item has one, sits below the media in `--carousel-caption-overlay-text-color`.

`thumbs: true` with more than one item adds the carousel thumbnail row as a strip along the bottom. It floats on the backdrop, highlights the current item, and scrolls horizontally when the row is wider than the screen. Clicking a thumbnail moves to that item. One item hides the strip. There is no prop for thumb size, alignment, or colour.

## Example
```erb
<%= render FlatPack::Lightbox::Component.new(
  group: "wall",
  items: [
    { type: :image, src: "/masonry/harbour.svg", alt: "Harbour at dusk", caption: "Harbour at dusk", thumb_src: "/masonry/harbour.svg" },
    { type: :image, src: "/masonry/cliff.svg", alt: "Sea cliff", caption: "Sea cliff" }
  ],
  loop: true,
  show_count: true,
  thumbs: true
) %>

<%= render FlatPack::Lightbox::Trigger.new(group: "wall", index: 0) do %>
  <%= render FlatPack::Media::Component.new(src: "/masonry/harbour.svg", alt: "Harbour at dusk", width: 1120, height: 1400) %>
<% end %>

<%= render FlatPack::Button::Component.new(
  text: "Open the harbour",
  data: FlatPack::Lightbox.trigger_data(group: "wall", index: 0)
) %>
```

Any element can carry the same data attributes: `data-flat-pack-lightbox-group` and `data-flat-pack-lightbox-index`.

Carousel slides with `lightbox: true` render this component. Image slides default to on. Video slides open it only when `lightbox: true`. HTML slides never do.

## Interactive Demo
- `/demo/lightbox`

## Accessibility
- The overlay is a native `<dialog>`, opened with `showModal`, so the browser supplies the backdrop, Escape, and the focus trap.
- Close returns focus to the trigger.
- The dialog is labelled with I18n `flatpack.lightbox.label`. The close button uses `flatpack.lightbox.close`.
- Arrow keys move between items unless focus is already in the carousel viewport, a video, or a field.
- One item has no arrows and no count.
- Reduced motion skips the scale and fade.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--lightbox` and `flat-pack--carousel`.
- The overlay renders `FlatPack::Carousel::Component` with `stage: true` and `fit: :contain`. Sliding, swipe, arrows, and the count stay on that carousel.
- Tokens: `--modal-backdrop-color`, `--modal-backdrop-blur`, `--carousel-control-*`, `--carousel-counter-*`, `--carousel-caption-overlay-text-color`, `--carousel-thumb-border-color`, `--carousel-thumb-placeholder-*`. `--carousel-lightbox-image-background-color` fills a carousel `fit: :contain` frame outside this overlay. It does not paint the lightbox.
