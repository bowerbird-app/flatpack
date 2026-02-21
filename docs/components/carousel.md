# Carousel Component

A modern, accessible media carousel/slider supporting images, video, and custom HTML slides.
Built with Stimulus for interactivity and full keyboard/touch support.

## Quick Start

```erb
<%= render FlatPack::Carousel::Component.new(autoplay: true, interval: 4000) do |carousel| %>
  <% carousel.slide(alt: "Slide 1") do %>
    <div class="h-64 flex items-center justify-center bg-gradient-to-r from-blue-500 to-cyan-500 text-white font-bold">Slide 1</div>
  <% end %>
<% end %>
```

## Props / Parameters

| Parameter | Type | Default |
|---|---|---|
| `autoplay` | Boolean | `false` |
| `interval` | Integer | `5000` |
| `loop` | Boolean | `true` |
| `show_indicators` | Boolean | `true` |
| `show_controls` | Boolean | `true` |
| `show_counter` | Boolean | `false` |
| `pause_on_hover` | Boolean | `true` |
| `transition` | Symbol (`:slide`, `:fade`, `:none`) | `:slide` |
| `aspect_ratio` | Symbol (`:auto`, `:square`, `:video`, `:wide`) | `:auto` |
| `keyboard` | Boolean | `true` |
| `swipe` | Boolean | `true` |
| `start_slide` | Integer | `0` |
| `show_thumbnails` | Boolean | `false` |
| `show_progress_bar` | Boolean | `false` |
| `**system_arguments` | Hash | `{}` |

## Slide API

```erb
<% carousel.slide(alt: "Hero", thumbnail_url: "/hero-thumb.jpg") do %>
  <%= image_tag "hero.jpg", class: "w-full h-full object-cover" %>
<% end %>
```

## Examples

- Basic image carousel
- Mixed media (images + video + HTML)
- Autoplay with progress bar
- Fade transition
- With thumbnails
- Custom aspect ratios
- Minimal (no controls, no indicators)

## Keyboard Navigation

- `ArrowLeft` / `ArrowRight`: previous/next slide
- `Home`: first slide
- `End`: last slide
- `Enter` / `Space` on focused indicator: jump to slide

## Touch / Swipe

- Touch and pointer swipe are supported.
- Swipes above 50px navigate slides.

## Accessibility

- `role="region"` with `aria-roledescription="carousel"`
- Slide wrappers use `aria-roledescription="slide"` and labels like `1 of 3`
- Live region announces slide changes
- Keyboard navigation is supported

## Reduced Motion

The Stimulus controller checks `prefers-reduced-motion` and disables animated transitions when requested by the user.

## CSS Variables / Theming

Carousel styling uses FlatPack CSS variables:

- `--color-primary`
- `--color-background`
- `--color-border`
- `--color-foreground`
- `--color-muted`
- `--color-muted-foreground`
- `--color-ring`
- `--color-text`
- `--color-text-muted`
- `--radius-md`
- `--radius-lg`

## Best Practices

- Provide meaningful `alt:` labels for each slide.
- Keep control visibility enabled for discoverability.
- Use `show_counter` and `show_progress_bar` for autoplay carousels.
- Prefer `transition: :fade` for mixed media slides.
