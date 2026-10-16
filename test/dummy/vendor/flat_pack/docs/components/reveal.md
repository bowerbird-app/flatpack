# Reveal

## Purpose
Bring any element in once, when it scrolls into view. Box variants fade, rise, blur, or scale. Media variants wipe or zoom. Words and lines split the copy and slide each piece up out of a mask.

## When to use
Use `reveal:` on a component root when the whole block should enter together. Use `FlatPack::Reveal::Component` when you need a wrapper, staggered children, a media wipe or zoom, or split text. Skip it for overlays. Those keep their own enter and exit.

## Class
- Primary: `FlatPack::Reveal::Component`
- Related classes: `FlatPack::Motion`, `FlatPack::Text::Stream::Component`, `FlatPack::Card::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `reveal` | Symbol | none | Yes | How it enters. Allowed: `:fade`, `:rise`, `:blur`, `:scale`, `:wipe`, `:zoom`, `:words`, `:lines`. Invalid values raise `ArgumentError`. |
| `stagger` | Boolean | `false` | No | Box variants only. `true` staggers the element children with `--reveal-index`. Words and lines already stagger each piece. Must be `true` or `false`. |
| `parallax` | Boolean | `false` | No | `true` adds a gentle scroll shift. Only with `:wipe` or `:zoom`. Must be `true` or `false`. |
| `tag` | Symbol | `:div` | No | Root element. Allowed: `:div`, `:span`, `:p`, `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`, `:blockquote`, `:li`. |
| `text` | String | `nil` | Conditional | Plain copy for `:words` and `:lines`. Required for those variants unless the block has text. HTML-safe strings raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | No | HTML attributes on the root. `class` is merged with the reveal classes. |

`reveal:`, `stagger:`, and `parallax:` are also system arguments on any component whose root calls `merge_attributes`. The classes land on that root, once. `:words` and `:lines` raise there. Pass those to this component so the copy can be split.

## Slots
None. Box and media variants take a block. `:words` and `:lines` use `text:` or the block text.

## Variants

| variant | description |
|---------|-------------|
| `:fade` | Opacity only. |
| `:rise` | Fade plus a move of `--motion-distance-md`. |
| `:blur` | Fade plus a blur of `--motion-distance-md`. |
| `:scale` | Fade plus a scale from `0.96` to `1`. |
| `:wipe` | Clip-path wipe from the inline start. |
| `:zoom` | The direct child scales from `1.05` to `1`. |
| `:words` | Each word slides up out of an overflow mask. |
| `:lines` | Each line does the same. Split on newlines. |
| `stagger: true` | Children of a box variant wait `min(index, 12) * --reveal-stagger`. |
| `parallax: true` | A short shift on `animation-timeline: view()` when the browser supports it. Otherwise the element just reveals. |

## Example

```erb
<%= render FlatPack::Card::Component.new(reveal: :rise, shadow: :sm) do %>
  Notes
<% end %>

<%= render FlatPack::Reveal::Component.new(reveal: :rise, stagger: true, class: "grid gap-4") do %>
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
- Tokens: `--motion-duration-slow`, `--motion-ease-out`, `--motion-distance-md`, `--reveal-stagger`. A theme can point `--motion-ease-out` at `--motion-ease-spring` or `--motion-ease-in-out`. Reveals stay on `--motion-ease-out` so overlays are not involved.
- No per-component animation. `.fp-content-enter` and the collage entrance read the same tokens.
