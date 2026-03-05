# Carousel Component Proposal

Status: implemented (see `docs/components/carousel.md`)

For the implemented docs format, including `Interactive Demo` and `Code Example`, use:
- `docs/components/carousel.md`

## Goals

- Support mixed slide content: images, video, and sanitized HTML.
- Provide configurable thumbs, indicator circles, and forward/back controls.
- Support autoplay and loop behavior with accessibility-safe defaults.
- Remain mobile responsive and include optional captions.

## Core API (proposed)

```ruby
render FlatPack::Carousel::Component.new(
  slides: slides,
  initial_index: 0,
  show_thumbs: true,
  thumbs_position: :bottom,
  thumbs_alignment: :center,
  show_indicators: true,
  show_controls: true,
  autoplay: false,
  autoplay_interval_ms: 5000,
  pause_on_hover: true,
  pause_on_focus: true,
  loop: false,
  transition: :slide,
  aspect_ratio: "16/9",
  responsive: true,
  touch_swipe: true,
  show_captions: true,
  caption_mode: :overlay
)
```

## Slide types (proposed)

- `:image` with `src`, `alt`, optional thumb and caption
- `:video` with `src`, optional poster, video behavior flags
- `:html` with sanitized custom content

## Added recommendations

- Fullscreen/lightbox mode
- RTL-aware controls and gestures
- Per-slide timing and video-aware autoplay coordination
- Loading and error fallback states
- Virtualization for large collections
- Imperative API (`next`, `prev`, `goTo`, `play`, `pause`)
- Events (`carousel:change`, `carousel:play`, `carousel:pause`, `carousel:error`)
- Strong sanitization contract for custom HTML
- Tokenized theming hooks for controls/captions/thumbs/indicators
- Deep-linking support (`?slide=3` or hash)
- Reduced-motion behavior that disables autoplay by default

## Dummy app proposal pages

See the split demo proposal pages under:

- `/demo/carousel`
- `/demo/carousel/mixed_content`
- `/demo/carousel/navigation`
- `/demo/carousel/autoplay_loop`
- `/demo/carousel/mobile`
- `/demo/carousel/captions`
- `/demo/carousel/fullscreen`
- `/demo/carousel/rtl`
- `/demo/carousel/video_aware`
- `/demo/carousel/loading_states`
- `/demo/carousel/performance`
- `/demo/carousel/events_api`
- `/demo/carousel/security`
- `/demo/carousel/theming`
- `/demo/carousel/deep_linking`
- `/demo/carousel/reduced_motion`
