# Heading

## Purpose
Render a single heading tag. Semantic rank (`level:`) and visual size (`size:`) are independent.

## When to use
Use Heading when a host needs a bare `h1`–`h6` with kit type, without page chrome, section margins, or a copy-link.

Existing type components already cover most product cases. Map those first:

| Need | Use |
| --- | --- |
| In-app page heading, optional subtitle and actions | `FlatPack::PageTitle::Component` |
| Cover / display headline | `FlatPack::HeroTitle::Component` |
| In-page section with subtitle, trailing slot, or copy-link | `FlatPack::SectionTitle::Component` |
| Article / CMS HTML (bare tags inside a wrapper) | `FlatPack::Content::Component` |
| Empty-state title | `FlatPack::EmptyState::Component` |
| One heading tag, size not tied to the tag | `FlatPack::Heading::Component` |
| Body copy, captions, muted lines | `FlatPack::Text::Component` |

Hosts that today write `<h1 class="text-2xl font-semibold">` or a raw `<h2>` should use Heading. Keep Section Title when the block needs a subtitle, trailing badge, or anchor.

## Class
- Primary: `FlatPack::Heading::Component`
- Related classes: `FlatPack::SectionTitle::Component`, `FlatPack::PageTitle::Component`, `FlatPack::HeroTitle::Component`, `FlatPack::Text::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | conditional | Heading copy. Required unless the same string is passed as block content. HTML-safe strings raise `ArgumentError`. |
| `level` | Symbol, String, Integer | `:h2` | no | Semantic tag. `:h1`–`:h6`, or `1`–`6`. Visual size stays with `size:`. Invalid values raise `ArgumentError`. |
| `size` | Symbol, String | `:"2xl"` | no | Type scale: `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:"2xl"`, `:"3xl"`, `:"4xl"`, `:"5xl"`. Maps to `--text-*`. Product chrome stays at `--text-5xl` and below. Cover type stays on Hero Title. Invalid values raise `ArgumentError`. |
| `style` | Symbol, String | `:default` | no | Ink token. `:default` is `--surface-content-color`. `:muted` is `--surface-muted-content-color`. `:primary` is `--color-primary`. Not Alert/Badge `style`. Invalid values raise `ArgumentError`. |
| `weight` | Symbol, String | `:semibold` | no | Font weight: `:normal`, `:medium`, `:semibold`, `:bold`. Invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the heading tag. |

## Slots
None. Pass copy as `text:` or as the component block.

## Variants
- Level: `:h1`–`:h6` (default `:h2`).
- Size: `:xs` through `:"5xl"` (default `:"2xl"`, same visual step as Section Title `size: :lg`).
- Style: `:default`, `:muted`, `:primary`.
- Weight: `:normal`, `:medium`, `:semibold` (default), `:bold`.

## Example
```erb
<%= render FlatPack::Heading::Component.new(
  text: "Verify your email"
) %>
```

An `h1` that still looks like body-adjacent type:

```erb
<%= render FlatPack::Heading::Component.new(
  text: "Message sent",
  level: :h1,
  size: :"2xl"
) %>
```

A semantic `h2` at a smaller step, as in an embeddable card:

```erb
<%= render FlatPack::Heading::Component.new(
  text: "Clip stats",
  level: :h2,
  size: :lg,
  weight: :semibold
) %>
```

## Accessibility
- Default tag is `<h2>`. Pass `level:` so the heading rank matches the page outline. One `<h1>` per page.
- Copy is the accessible name. Do not hide the text.
- Default ink is `--surface-content-color`. Use `style: :muted` for a quieter line, not a lower heading rank.

## Dependencies
- `FlatPack::BaseComponent`
- Kit tokens `--text-xs` through `--text-5xl`, `--surface-content-color`, `--surface-muted-content-color`, `--color-primary`.
- No Stimulus controllers required.
