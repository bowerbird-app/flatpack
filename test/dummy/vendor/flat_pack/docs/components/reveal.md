# Reveal

## Purpose
Bring any element in once, when it scrolls into view. Box variants fade, rise, blur, or scale. Media variants wipe or zoom. Words and lines split the copy and slide each piece up out of a mask.

## When to use
Use `reveal:` on a component root when the whole block should enter together. Use `FlatPack::Reveal::Component` when you need a wrapper, staggered children, a media wipe or zoom, or split text. Pass `delay:` and `duration:` when one piece should follow another, and `stagger:` when the children should step. Skip it for overlays. Those keep their own enter and exit.

## Class
- Primary: `FlatPack::Reveal::Component`
- Related classes: `FlatPack::Motion`, `FlatPack::Text::Stream::Component`, `FlatPack::Number::Component`, `FlatPack::Card::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `reveal` | Symbol | none | Yes | How it enters. Allowed: `:fade`, `:rise`, `:blur`, `:scale`, `:wipe`, `:zoom`, `:words`, `:lines`. Invalid values raise `ArgumentError`. |
| `delay` | Symbol or Integer | none | No | When this reveal starts. `:sm`, `:md`, or `:lg` read `--motion-delay-sm` (120ms), `--motion-delay-md` (250ms), and `--motion-delay-lg` (450ms). A non-negative Integer is a millisecond escape hatch. Anything else raises `ArgumentError`. Omit it and the reveal starts at once. |
| `duration` | Symbol or Integer | none | No | How long the move takes. `:fast`, `:base`, `:slow`, or `:slower` read `--motion-duration-*`. `:slower` is 600ms. A non-negative Integer is a millisecond escape hatch. Anything else raises `ArgumentError`. Omit it and the reveal uses `--motion-duration-slow`. |
| `stagger` | Boolean, Symbol, or Integer | `false` | No | `false` is off. `true` indexes the children of a box variant and waits `--reveal-stagger` (40ms) per step. `:sm`, `:md`, and `:lg` do the same with `--motion-stagger-sm` (40ms), `--motion-stagger-md` (80ms), and `--motion-stagger-lg` (120ms). A non-negative Integer is milliseconds per step. Words and lines already stagger each piece; a step there only changes the gap. Anything else raises `ArgumentError`. |
| `parallax` | Boolean | `false` | No | `true` adds a gentle scroll shift. Only with `:wipe` or `:zoom`. Must be `true` or `false`. |
| `intensity` | Symbol | none | No | `:strong` uses the strong tokens. Omit it for the default. Anything else raises `ArgumentError`. |
| `tag` | Symbol | `:div` | No | Root element. Allowed: `:div`, `:span`, `:p`, `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`, `:blockquote`, `:li`. |
| `text` | String | `nil` | Conditional | Plain copy for `:words` and `:lines`. Required for those variants unless the block has text. HTML-safe strings raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | No | HTML attributes on the root. `class` is merged with the reveal classes. |

`reveal:`, `delay:`, `duration:`, `stagger:`, `parallax:`, and `intensity:` are also system arguments on any component whose root calls `merge_attributes`. The classes land on that root, once. `:words` and `:lines` raise there. Pass those to this component so the copy can be split. Named steps are the API. A millisecond Integer is the escape hatch.

## Slots
None. Box and media variants take a block. `:words` and `:lines` use `text:` or the block text.

## Variants

| variant | description |
|---------|-------------|
| `:fade` | Hidden, then opacity from `0` to `1`. |
| `:rise` | Hidden, then up by `--motion-distance-md` (`1rem`). `:strong` uses `--motion-distance-lg` (`3rem`). |
| `:blur` | Hidden, then sharpens from `--motion-distance-md`. `:strong` uses `--motion-distance-lg`. |
| `:scale` | Hidden, then grows from `--motion-scale` (`0.95`). `:strong` uses `--motion-scale-strong` (`0.85`). |
| `:wipe` | Fully clipped, then a clip-path wipe. |
| `:zoom` | Hidden, then the child settles from `--motion-zoom` (`1.05`). `:strong` uses `--motion-zoom-strong` (`1.2`). |
| `:words` | Each word slides up out of an overflow mask. |
| `:lines` | Each line does the same. Split on newlines. |
| `delay: :md` | This reveal waits `--motion-delay-md` before it moves. `:sm` and `:lg` are the other steps. |
| `duration: :slower` | This reveal takes `--motion-duration-slower`. `:fast`, `:base`, and `:slow` are the other steps. |
| `stagger: true` | Children of a box variant wait `min(index, 12) * --reveal-stagger`. |
| `stagger: :lg` | Same indexing, with `--motion-stagger-lg` per step. `:sm` and `:md` are the other steps. |
| `parallax: true` | A short shift on `animation-timeline: view()` when the browser supports it. Otherwise the element just reveals. |

With scripting, a reveal that is not `.is-revealed` is hidden on first paint, so nothing flashes before the entrance. `@media (scripting: none)` and `prefers-reduced-motion: reduce` show the final state. The dummy gallery at `/demo/motion` puts default and `:strong` side by side. `?clip=fade` (and `rise`, `blur`, `scale`, `wipe`, `zoom`, `words`, `lines`, `stream`) renders that specimen.

## Example

```erb
<%= render FlatPack::Card::Component.new(reveal: :rise, shadow: :sm) do %>
  Notes
<% end %>

<%= render FlatPack::Reveal::Component.new(reveal: :rise, duration: :slower, tag: :h2) do %>
  Pack it once
<% end %>

<%= render FlatPack::Reveal::Component.new(reveal: :fade, delay: :md, tag: :p) do %>
  Walnut, oiled, ready Friday.
<% end %>

<%= render FlatPack::Reveal::Component.new(reveal: :rise, delay: :lg) do %>
  <%= render FlatPack::Button::Component.new(text: "Start packing", style: :primary) %>
<% end %>

<%= render FlatPack::Reveal::Component.new(reveal: :rise, stagger: :lg, class: "grid gap-4") do %>
  <div>One</div>
  <div>Two</div>
<% end %>

<%= render FlatPack::Reveal::Component.new(reveal: :words, tag: :h2, text: "Pack it up") %>

<%= render FlatPack::Reveal::Component.new(reveal: :zoom, parallax: true) do %>
  <%= image_tag "/images/hero-stool.jpg", alt: "A wooden stool" %>
<% end %>
```

## Accessibility
The resting CSS is the finished look. With no JavaScript the content is visible. `prefers-reduced-motion: reduce` skips the motion and shows that look immediately. The Stimulus controller adds `is-pending` only after it connects, then `is-revealed` once.

`:words` and `:lines` put the plain sentence in a visually hidden span. The masks are `aria-hidden`. Screen readers get the sentence, not the pieces.

Parallax is a CSS scroll-driven animation inside `@supports (animation-timeline: view())` and `prefers-reduced-motion: no-preference`. Without that support there is no shift.

## Dependencies
- Stimulus controller `flat-pack--reveal` (`app/javascript/flat_pack/controllers/reveal_controller.js`). One `IntersectionObserver`. It disconnects after the first reveal.
- Tokens: `--motion-duration-fast`, `--motion-duration-base`, `--motion-duration-slow`, `--motion-duration-slower`, `--motion-delay-sm`, `--motion-delay-md`, `--motion-delay-lg`, `--motion-stagger-sm`, `--motion-stagger-md`, `--motion-stagger-lg`, `--motion-ease-out`, `--motion-distance-md`, and `--reveal-stagger`. A named step writes `--reveal-delay`, `--reveal-duration`, or `--reveal-stagger` on that element. The CSS falls back to `--motion-duration-slow`, `0ms`, and `--reveal-stagger`. A theme can point `--motion-ease-out` at `--motion-ease-spring` or `--motion-ease-in-out`. Reveals stay on `--motion-ease-out` so overlays are not involved.
- Under `prefers-reduced-motion: reduce`, those duration, delay, and stagger tokens are `0ms`. An instance millisecond is forced to `0ms` on `.fp-reveal` as well.
- No per-component animation. `.fp-content-enter` and the collage entrance read the same tokens.
