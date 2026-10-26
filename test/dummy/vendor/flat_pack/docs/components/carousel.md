# Carousel

## Purpose
Render an interactive, mixed-content carousel with native FlatPack JavaScript and owl-carousel style imperative controls.

## When to use
Use Carousel when users need to browse a sequence of visual or rich-content slides with optional controls, dots, thumbnails, and autoplay.

## Class
- Primary: `FlatPack::Carousel::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `slides` | Array<Hash> | `[]` | no | Slide payloads (`:image`, `:video`, `:html`) with sanitization. Image slides accept `lightbox` (default `true`). Video and HTML default `lightbox` to `false`. Omit it when every slide comes from the `items` slot. |
| `initial_index` | Integer | `0` | no | Zero-based starting slide index. |
| `show_thumbs` | Boolean | `false` | no | Render clickable thumbnail navigation. |
| `thumbs_position` | Symbol | `:bottom` | no | Thumbnail row position: `:top`, `:bottom`. |
| `thumbs_alignment` | Symbol | `:center` | no | Thumbnail row alignment: `:start`, `:center`, `:end`. |
| `show_indicators` | Boolean | `true` | no | Render indicator dots. |
| `show_controls` | Boolean | `true` (`:default`), `false` (`:logo_slider`) | no | Render previous/next controls. |
| `controls_on_hover` | Boolean | `false` | no | For desktop/tablet, hide controls until carousel hover/focus-within. Controls remain visible on mobile. |
| `autoplay` | Boolean | `false` (`:default`), `true` (`:logo_slider`) | no | Automatically advance slides. |
| `autoplay_interval_ms` | Integer | `5000` | no | Autoplay interval in milliseconds. |
| `pause_on_hover` | Boolean | `true` | no | Pause autoplay while pointer hovers. |
| `pause_on_focus` | Boolean | `true` | no | Pause autoplay while keyboard focus is inside. |
| `loop` | Boolean | `true` | no | Wrap from last slide to first slide. |
| `transition` | Symbol | `:slide` | no | Transition style: `:slide`, `:fade`. |
| `variant` | Symbol | `:default` | no | Rendering mode: `:default`, `:logo_slider` (image-only multi-item row). |
| `items_per_view_desktop` | Integer | `1` | no | Slides visible at desktop width when `variant: :default` and `transition: :slide`. |
| `items_per_view_tablet` | Integer | `1` | no | Slides visible at tablet width when `variant: :default` and `transition: :slide`. |
| `items_per_view_mobile` | Integer | `1` | no | Slides visible at mobile width when `variant: :default` and `transition: :slide`. |
| `side_preview` | Boolean | `false` | no | In default slide mode, reveals the next slide by `--carousel-peek` (default `0.25`, so one full slide plus a quarter of the next). Ignored for `:logo_slider` and `:fade`. |
| `logo_items_per_view_desktop` | Integer | `5` | no | Logos visible at desktop width when `variant: :logo_slider`. |
| `logo_items_per_view_tablet` | Integer | `3` | no | Logos visible at tablet width when `variant: :logo_slider`. |
| `logo_items_per_view_mobile` | Integer | `3` | no | Logos visible at mobile width when `variant: :logo_slider`. |
| `logo_grayscale` | Boolean | `true` | no | Apply grayscale filter to logo images in logo-slider mode. |
| `logo_opacity` | Float | `1.0` | no | Opacity for logo images in logo-slider mode (`0.0..1.0`). |
| `logo_wrapper_background` | String | `nil` | no | Reserved for compatibility (sanitized input); current logo-slider rendering keeps wrapper/viewport transparent. |
| `aspect_ratio` | String | `"16/9"` | no | CSS aspect ratio (`"16/9"` format). Ignored when the `items` slot supplies slides. The viewport then grows with the tallest slide. |
| `bleed` | Boolean | `false` | no | Pull the track out to the parent edge. The first slide stays lined up with the content. The inset is `--carousel-bleed`, then `--card-inset` on an ancestor card, then `--card-padding-md`. |
| `controls_on_touch` | Boolean | hidden for `items`, shown for hash slides | no | `false` hides previous and next on `@media (hover: none)`. Swipe still moves the track. Arrows stay absolutely positioned and take no width. Omit it and a card row hides them. A hash `slides:` carousel keeps them. |
| `show_border` | Boolean | `true` for hash slides, `false` for `items` | no | Draw the viewport border. `:logo_slider` stays borderless. Pass `true` or `false` to override the `items` default. |
| `show_background` | Boolean | `true` for hash slides, `false` for `items` | no | Fill the viewport. `:logo_slider` stays transparent. Pass `true` or `false` to override the `items` default. |
| `responsive` | Boolean | `true` | no | Keep container responsive width behavior. |
| `touch_swipe` | Boolean | `true` | no | Enable pointer swipe navigation. |
| `show_captions` | Boolean | `true` | no | Render active slide captions. |
| `caption_mode` | Symbol | `:below` | no | Caption location: `:below`, `:overlay`. |
| `show_counter` | Boolean | `true` | no | Show the `3 / 12` count when more than one slide is visible. |
| `fit` | Symbol | `:cover` | no | Image fit: `:cover` or `:contain`. `:contain` letterboxes the image. A normal carousel still keeps `aspect_ratio`. |
| `stage` | Boolean | `false` | no | Composition-only. `FlatPack::Lightbox` sets this so the overlay carousel fills the dialog and does not open another lightbox. Hosts leave it off. |
| `aria_label` | String | `"Carousel"` | no | Accessible region label for the viewport. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for root wrapper. |

## Slots
| name | description |
|---|---|
| `items` | One slide per call. The block is trusted component output: images, buttons, and `data-action` render as written, with no forced padding. Hash `slides:` can be omitted. When both are set, hash slides come first. |

`with_item` switches the viewport to content height. There is no aspect ratio and no letterboxing. The default border and muted fill turn off unless you pass `show_border:` or `show_background:`. The row is as tall as the tallest item. Each item stretches to that height, and the card inside fills the item, so the bottoms line up and the title and actions stay visible. Each item keeps a `--space-3` gap after the card. That gap is padding inside the slide, so `--carousel-peek` and `bleed:` stay aligned. Hash `slides:` do not get the gap.

## Card row
Put the carousel in a padded card and set `bleed: true` so the next card peeks to the card edge instead of stopping at the padding. `side_preview: true` reads `--carousel-peek`. A theme or host sets that token to change the peek. `0.25` shows about 80% of a slide when one slide is in view (`100 / 1.25`).

A card publishes `--card-inset` from its padding step. Bleed uses that length when the carousel sits inside the card. Set `--carousel-bleed` when the parent is not a card, or when that inset is not the one you want.

## Variants
- Transition: `:slide`, `:fade`.
- Caption mode: `:below`, `:overlay`.
- Carousel variant: `:default`, `:logo_slider`.

### Logo Slider Notes
- Shows multiple logos in one row using responsive counts.
- Default count targets: desktop `5`, tablet `3`, mobile `3`.
- Logo-slider mode only renders image slides (video/html slide payloads are ignored).
- Fade transition is not supported in logo-slider mode.
- Wrapper and viewport use no extra margin/padding and remain transparent in logo-slider mode. `show_border` and `show_background` do not change that.

## Viewport chrome
The default viewport draws a border and a muted fill. `show_border: false` replaces the border with `border-0`. `show_background: false` replaces the fill with `bg-transparent`. Leave a flag on and its token still paints it: `--carousel-viewport-border-color` and `--carousel-viewport-background-color`. A host `style:` that sets those tokens to `transparent` still works while the classes stay on.

Previous, next, and the expand toggle are `FlatPack::Button::Component` (secondary, round, icon-only). `.fp-overlay-icon-button` maps `--carousel-control-*` onto `--button-secondary-*`. The toggle keeps `data-flat-pack--carousel-target="lightboxToggle"` and `click->flat-pack--carousel#openLightbox`. Arrows keep `click->flat-pack--carousel#prev` and `#next`, plus `flat-pack-carousel__control`.

## Side Preview Notes
- Applies only to `variant: :default` with `transition: :slide`.
- Adds `--carousel-peek` (default `0.25`) to the items-per-view count. The previous fixed `+0.25` is that default.
- Keep per-breakpoint full-card counts with `items_per_view_desktop`, `items_per_view_tablet`, and `items_per_view_mobile`.
- Previous and next are overlays (`absolute`). They do not sit beside the track.

## Interactive Demo
- `/demo/carousel`

The dummy app consolidates carousel behavior (basic, autoplay, thumbnails, transitions, keyboard/touch notes, and token reference) on this single page.

## Example
```erb
<%= render FlatPack::Carousel::Component.new(
  slides: [
    {type: :image, src: "https://images.example.com/hero.jpg", alt: "Hero", caption: "Hero image", lightbox: true},
    {type: :video, src: "https://videos.example.com/teaser.mp4", poster: "https://images.example.com/poster.jpg", caption: "Teaser"},
    {type: :html, html: "<div class='p-6'><h3>Release Notes</h3><p>Shipped this week.</p></div>", thumb_src: "https://images.example.com/notes.jpg", caption: "Custom card"}
  ],
  show_thumbs: true,
  autoplay: true,
  loop: true,
  transition: :fade
) %>
```

## Logo Slider Example
```erb
<%= render FlatPack::Carousel::Component.new(
  slides: @brand_logos,
  variant: :logo_slider,
  loop: true,
  logo_items_per_view_desktop: 5,
  logo_items_per_view_tablet: 3,
  logo_items_per_view_mobile: 3,
  logo_grayscale: true,
  logo_opacity: 0.8,
  show_indicators: false,
  show_captions: false
) %>
```

## Card Row Example
```erb
<%= render FlatPack::Card::Component.new(padding: :md) do %>
  <%= render FlatPack::Carousel::Component.new(
    side_preview: true,
    bleed: true,
    items_per_view_desktop: 3,
    items_per_view_tablet: 2,
    items_per_view_mobile: 1,
    controls_on_touch: false,
    show_indicators: false,
    show_counter: false,
    show_captions: false,
    aria_label: "Episodes"
  ) do |carousel| %>
    <% carousel.with_item do %>
      <%= render FlatPack::Card::Component.new(padding: :none) do |card| %>
        <% card.media(aspect_ratio: "1/1", padding: :none) do %>
          <%= image_tag episode_art_url, alt: "" %>
        <% end %>
        <% card.body do %>
          <h3>Night drive</h3>
          <%= render FlatPack::Button::Component.new(text: "Play", icon: "play", style: :primary, size: :sm) %>
          <%= render FlatPack::Button::Component.new(text: "Save", style: :secondary, size: :sm) %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Side Preview Charts Example
```erb
<%= render FlatPack::Carousel::Component.new(
  slides: @carousel_chart_slides,
  side_preview: true,
  items_per_view_desktop: 3,
  items_per_view_tablet: 1,
  items_per_view_mobile: 1,
  show_controls: true,
  show_indicators: true,
  show_captions: true,
  caption_mode: :below,
  show_border: false,
  show_background: false
) %>
```

## Slides Hash Options
| key | applies to | accepts | default | notes |
|---|---|---|---|---|
| `type` | image, video, html | `:image`, `:video`, `:html` | inferred | Optional if inferable from payload. |
| `src` | image, video | String URL | required | Required for image/video slides. |
| `url` | image | String URL | `nil` | Optional click-through URL. In `:logo_slider` mode, wraps the logo image in a link that opens in a new tab. |
| `thumb_src` | image, html | String URL | `nil` | Thumbnail for `show_thumbs`. Image slides fall back to `src`. HTML slides without a usable URL show the slide number. |
| `thumb` | image, html | String URL | `nil` | Alias for `thumb_src`. |
| `alt` | image | String | I18n `flatpack.carousel.slide_fallback` | Falls back to the kit copy for slide `%{number}`. |
| `caption` | image, video, html | String | `""` | Used by caption rendering modes. |
| `lightbox` | image, video, html | `true`, `false` | image: `true`, others: `false` | Image and video open `FlatPack::Lightbox`. HTML never does. `:logo_slider` never does. |
| `poster` | video | String URL | `nil` | Poster image behind video element. |
| `controls` | video | `true`, `false` | `true` | Native video controls toggle. |
| `muted` | video | `true`, `false` | `false` | Passed to `<video muted>`. |
| `video_loop` | video | `true`, `false` | `false` | Passed to `<video loop>`. |
| `playsinline` | video | `true`, `false` | `true` | Passed to `<video playsinline>`. |
| `html` | html | String HTML | required for `:html` | HTML content is sanitized before render. |

HTML slides use the same `thumb_src` and `thumb` keys as images. A safe URL (`http`, `https`, or a relative path) becomes the thumbnail. Leave it off, or pass a rejected URL, and the thumb stays the slide number. Video thumbnails still come from `poster`.

## JS API (owl-style)
The Stimulus controller exposes methods both as component actions and as an imperative API:
- `next()`
- `prev()`
- `to(index)` / `goTo(index)`
- `play()`
- `pause()` / `stop()`
- `refresh()`

Interop events are supported on the root element:
- `next.owl.carousel`
- `prev.owl.carousel`
- `to.owl.carousel` (`detail.index`)
- `play.owl.autoplay`
- `stop.owl.autoplay`

Runtime events emitted by the carousel:
- `carousel:change`
- `carousel:play`
- `carousel:pause`

`lightbox: true` on an image or video slide renders one [Lightbox](lightbox.md) beside the carousel. Clicking the current slide, or the expand control, dispatches `flat-pack:lightbox:open` for that group and the current item. Previous, next, indicators, and thumbnails do not. Autoplay pauses while the dialog is open and resumes when it closes. Changing items inside the dialog stays on that dialog and does not move the carousel on the page. The overlay is the shared full-screen dialog: a transparent viewport, the modal backdrop, close, Escape, and the same carousel for next, previous, arrows, and swipe. Stage media is `object-fit: contain` with no frame behind it. One lightbox item hides the arrows and the count. HTML slides ignore `lightbox`. `:logo_slider` ignores it. Lightbox `thumbs: true` uses this carousel's `show_thumbs`. On the stage, that row is a horizontal strip along the bottom instead of a wrapping row.

The dialog uses `.fp-overlay-pad` and `overscroll-behavior: contain` so the overlay clears notches and does not chain scroll into the page. Hosts need `viewport-fit=cover` for insets to apply. See [Installation](../installation.md). Carousel swipe still uses `touch-action: pan-y` on the viewport when `touch_swipe` is enabled.

Controls, the slide counter, and video letterbox use `--carousel-control-*`, `--carousel-counter-*`, and `--carousel-media-background-color`. `fit: :contain` outside the lightbox fills the frame with `--carousel-lightbox-image-background-color`. The lightbox stage does not. Its backdrop uses `--modal-backdrop-color` and `--modal-backdrop-blur`, and its caption uses `--carousel-caption-overlay-text-color`. Named themes inherit those unless they override the family.

## Accessibility
- Viewport uses `role="region"` with configurable `aria-label`.
- Controls and indicators include explicit labels.
- Keyboard support: `ArrowLeft`, `ArrowRight`, `Home`, `End`, `Space`.
- Honors reduced motion by avoiding autoplay startup when `prefers-reduced-motion: reduce` is active.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--carousel`.
- Lightbox overlay: `FlatPack::Lightbox::Component` and `flat-pack--lightbox` when any slide can open it.
