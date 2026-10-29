# Text Stream

## Purpose
Type a line of copy once it scrolls into view, with a caret. The full text stays in the DOM. The typing is decorative.

## When to use
Use it for a chat reply, a caption, or any short line that should arrive as if it were being written. Compose it inside a chat message. Do not add a `stream:` flag to the message. Skip it for long articles. Static body copy is `FlatPack::Text::Component`.

## Class
- Primary: `FlatPack::Text::Stream::Component`
- Related classes: `FlatPack::Chat::Message::Component`, `FlatPack::Reveal::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `text` | String | none | Yes | The full line. Blank and HTML-safe strings raise `ArgumentError`. |
| `tag` | Symbol | `:p` | No | Root element. Allowed: `:div`, `:span`, `:p`, `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`, `:blockquote`, `:li`. |
| `**system_arguments` | Hash | `{}` | No | HTML attributes on the root. `class` is merged. |

## Slots
None.

## Variants
None. The caret blink uses `steps`. The gap between glyphs reads `--reveal-stagger`, clamped between 12ms and 80ms.

## Example

```erb
<%= render FlatPack::Chat::Message::Component.new(direction: :incoming) do %>
  <%= render FlatPack::Text::Stream::Component.new(text: "The walnut stool ships Friday.") %>
<% end %>
```

## Accessibility
The source string is in the accessibility tree the whole time. A sizer with the same string is `aria-hidden` and holds the layout. The typed copy and the caret are `aria-hidden`. Screen readers hear the finished line, not the keystrokes.

With no JavaScript the source is visible and the typed copy stays hidden. `prefers-reduced-motion: reduce` does the same: the controller does not start, and the CSS keeps the source on screen.

## Dependencies
- Stimulus controller `flat-pack--text-stream` (`app/javascript/flat_pack/controllers/text_stream_controller.js`). It types after one intersection, then stops.
- `--reveal-stagger` sets the glyph delay. `--motion-*` does not move this component.
- FlatPack install generator setup (`rails generate flat_pack:install`).
