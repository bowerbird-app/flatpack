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
| `slides` | Array<Hash> | `[]` | yes | Slide payloads (`:image`, `:video`, `:html`) with sanitization. Image slides accept `lightbox` (default `true`), while non-image slides default `lightbox` to `false`. |
| `initial_index` | Integer | `0` | no | Zero-based starting slide index. |
| `show_thumbs` | Boolean | `false` | no | Render clickable thumbnail navigation. |
| `thumbs_position` | Symbol | `:bottom` | no | Thumbnail row position: `:top`, `:bottom`. |
| `thumbs_alignment` | Symbol | `:center` | no | Thumbnail row alignment: `:start`, `:center`, `:end`. |
| `show_indicators` | Boolean | `true` | no | Render indicator dots. |
| `show_controls` | Boolean | `true` | no | Render previous/next controls. |
| `autoplay` | Boolean | `false` | no | Automatically advance slides. |
| `autoplay_interval_ms` | Integer | `5000` | no | Autoplay interval in milliseconds. |
| `pause_on_hover` | Boolean | `true` | no | Pause autoplay while pointer hovers. |
| `pause_on_focus` | Boolean | `true` | no | Pause autoplay while keyboard focus is inside. |
| `loop` | Boolean | `true` | no | Wrap from last slide to first slide. |
| `transition` | Symbol | `:slide` | no | Transition style: `:slide`, `:fade`. |
| `aspect_ratio` | String | `"16/9"` | no | CSS aspect ratio (`"16/9"` format). |
| `responsive` | Boolean | `true` | no | Keep container responsive width behavior. |
| `touch_swipe` | Boolean | `true` | no | Enable pointer swipe navigation. |
| `show_captions` | Boolean | `true` | no | Render active slide captions. |
| `caption_mode` | Symbol | `:below` | no | Caption location: `:below`, `:overlay`. |
| `aria_label` | String | `"Carousel"` | no | Accessible region label for the viewport. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for root wrapper. |

## Slots
None.

## Variants
- Transition: `:slide`, `:fade`.
- Caption mode: `:below`, `:overlay`.

## Interactive Demo
- `/demo/carousel`

The dummy app consolidates carousel behavior (basic, autoplay, thumbnails, transitions, keyboard/touch notes, and token reference) on this single page.

## Example
```erb
<%= render FlatPack::Carousel::Component.new(
  slides: [
    {type: :image, src: "https://images.example.com/hero.jpg", alt: "Hero", caption: "Hero image", lightbox: true},
    {type: :video, src: "https://videos.example.com/teaser.mp4", poster: "https://images.example.com/poster.jpg", caption: "Teaser"},
    {type: :html, html: "<div class='p-6'><h3>Release Notes</h3><p>Shipped this week.</p></div>", caption: "Custom card"}
  ],
  show_thumbs: true,
  autoplay: true,
  loop: true,
  transition: :fade
) %>
```

## Slides Hash Options
| key | applies to | accepts | default | notes |
|---|---|---|---|---|
| `type` | image, video, html | `:image`, `:video`, `:html` | inferred | Optional if inferable from payload. |
| `src` | image, video | String URL | required | Required for image/video slides. |
| `thumb_src` | image | String URL | `nil` | Thumbnail source for `show_thumbs`. |
| `thumb` | image | String URL | `nil` | Alias for `thumb_src`. |
| `alt` | image | String | `"Slide n"` | Falls back to slide index label. |
| `caption` | image, video, html | String | `""` | Used by caption rendering modes. |
| `lightbox` | image, video, html | `true`, `false` | image: `true`, others: `false` | Only image slides can actually open lightbox. |
| `poster` | video | String URL | `nil` | Poster image behind video element. |
| `controls` | video | `true`, `false` | `true` | Native video controls toggle. |
| `muted` | video | `true`, `false` | `false` | Passed to `<video muted>`. |
| `video_loop` | video | `true`, `false` | `false` | Passed to `<video loop>`. |
| `playsinline` | video | `true`, `false` | `true` | Passed to `<video playsinline>`. |
| `html` | html | String HTML | required for `:html` | HTML content is sanitized before render. |

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

## Accessibility
- Viewport uses `role="region"` with configurable `aria-label`.
- Controls and indicators include explicit labels.
- Keyboard support: `ArrowLeft`, `ArrowRight`, `Home`, `End`, `Space`.
- Honors reduced motion by avoiding autoplay startup when `prefers-reduced-motion: reduce` is active.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--carousel`.
