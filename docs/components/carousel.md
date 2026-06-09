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
| `show_controls` | Boolean | `true` (`:default`), `false` (`:logo_slider`) | no | Render previous/next controls. |
| `autoplay` | Boolean | `false` (`:default`), `true` (`:logo_slider`) | no | Automatically advance slides. |
| `autoplay_interval_ms` | Integer | `5000` | no | Autoplay interval in milliseconds. |
| `pause_on_hover` | Boolean | `true` | no | Pause autoplay while pointer hovers. |
| `pause_on_focus` | Boolean | `true` | no | Pause autoplay while keyboard focus is inside. |
| `loop` | Boolean | `true` | no | Wrap from last slide to first slide. |
| `transition` | Symbol | `:slide` | no | Transition style: `:slide`, `:fade`. |
| `variant` | Symbol | `:default` | no | Rendering mode: `:default`, `:logo_slider` (image-only multi-item row). |
| `logo_items_per_view_desktop` | Integer | `5` | no | Logos visible at desktop width when `variant: :logo_slider`. |
| `logo_items_per_view_tablet` | Integer | `3` | no | Logos visible at tablet width when `variant: :logo_slider`. |
| `logo_items_per_view_mobile` | Integer | `3` | no | Logos visible at mobile width when `variant: :logo_slider`. |
| `logo_grayscale` | Boolean | `true` | no | Apply grayscale filter to logo images in logo-slider mode. |
| `logo_opacity` | Float | `1.0` | no | Opacity for logo images in logo-slider mode (`0.0..1.0`). |
| `logo_wrapper_background` | String | `nil` | no | Reserved for compatibility (sanitized input); current logo-slider rendering keeps wrapper/viewport transparent. |
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
- Carousel variant: `:default`, `:logo_slider`.

### Logo Slider Notes
- Shows multiple logos in one row using responsive counts.
- Default count targets: desktop `5`, tablet `3`, mobile `3`.
- Logo-slider mode only renders image slides (video/html slide payloads are ignored).
- Fade transition is not supported in logo-slider mode.
- Wrapper and viewport use no extra margin/padding and remain transparent in logo-slider mode.

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

## Slides Hash Options
| key | applies to | accepts | default | notes |
|---|---|---|---|---|
| `type` | image, video, html | `:image`, `:video`, `:html` | inferred | Optional if inferable from payload. |
| `src` | image, video | String URL | required | Required for image/video slides. |
| `url` | image | String URL | `nil` | Optional click-through URL. In `:logo_slider` mode, wraps the logo image in a link that opens in a new tab. |
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
