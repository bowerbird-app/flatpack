# Text

## Purpose
Render a line of body copy with kit size, ink, and weight tokens.

## When to use
Use Text for captions, helper lines, and short paragraphs that should follow `--text-*` and surface ink. Do not use it for headings (use [Heading](heading.md)), section chrome (use [Section Title](section-title.md)), article HTML (use [Content](content.md)), quotes (use [Quote](quote.md)), or typed-on-scroll lines (use [Text Stream](text-stream.md)).

There was no existing body-copy primitive. Hosts that today write `<p class="text-sm text-gray-500">` should use Text.

## Class
- Primary: `FlatPack::Text::Component`
- Related classes: `FlatPack::Heading::Component`, `FlatPack::Content::Component`, `FlatPack::Quote::Component`, `FlatPack::Text::Stream::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | conditional | Copy. Required unless the same string is passed as block content. HTML-safe strings raise `ArgumentError`. |
| `size` | Symbol, String | `:base` | no | Type scale: `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:"2xl"`. Maps to `--text-*`. Invalid values raise `ArgumentError`. |
| `style` | Symbol, String | `:default` | no | Ink token. `:default` is `--surface-content-color`. `:muted` is `--surface-muted-content-color`. `:primary` is `--color-primary`. Use `style`, not `tone` or `color`. Invalid values raise `ArgumentError`. |
| `weight` | Symbol, String | `:normal` | no | Font weight: `:normal`, `:medium`, `:semibold`, `:bold`. Invalid values raise `ArgumentError`. |
| `as` | Symbol, String | `:p` | no | Tag: `:p`, `:span`, or `:div`. Heading tags belong on Heading. Invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the tag. |

## Slots
None. Pass copy as `text:` or as the component block.

## Variants
- Size: `:xs`, `:sm`, `:base` (default), `:lg`, `:xl`, `:"2xl"`.
- Style: `:default`, `:muted`, `:primary`.
- Weight: `:normal` (default), `:medium`, `:semibold`, `:bold`.
- Tag: `:p` (default), `:span`, `:div`.

## Example
```erb
<%= render FlatPack::Text::Component.new(
  text: "We sent a link to your inbox."
) %>
```

Muted helper under a heading:

```erb
<%= render FlatPack::Heading::Component.new(text: "Verify your email") %>
<%= render FlatPack::Text::Component.new(
  text: "The link expires in 30 minutes.",
  size: :sm,
  style: :muted
) %>
```

Inline status:

```erb
<%= render FlatPack::Text::Component.new(
  text: "Saved",
  as: :span,
  size: :sm,
  weight: :medium,
  style: :primary
) %>
```

## Accessibility
- Default tag is `<p>`. Use `as: :span` when the copy sits inside another paragraph or a control.
- Copy is the accessible name. Do not pass HTML through `text:`.

## Dependencies
- `FlatPack::BaseComponent`
- Kit tokens `--text-xs` through `--text-2xl`, `--surface-content-color`, `--surface-muted-content-color`, `--color-primary`.
- No Stimulus controllers required.
