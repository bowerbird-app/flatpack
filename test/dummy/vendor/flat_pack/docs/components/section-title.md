# Section Title

## Purpose
Render section headings with optional subtitle and optional copy-link anchor behavior.

## When to use
Use Section Title for document-style pages where subsections need deep-linkable anchors. Keep the default (`size: :lg`, `spacing: :lg`) for page sections. Inside a card or a compact stack, pass a smaller `size` and tighter `spacing`.

## Class
- Primary: `FlatPack::SectionTitle::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Section heading text. |
| `subtitle` | String | `nil` | no | Supporting copy below the heading. Blank or whitespace-only values render nothing. |
| `anchor_link` | Boolean | `false` | no | Enables hover/focus copy-link affordance and anchor id generation. |
| `anchor_id` | String | `nil` | no | Explicit anchor id when `anchor_link` is enabled; falls back to wrapper id or parameterized title. |
| `size` | Symbol | `:lg` | no | Type scale for the heading, subtitle, and copy-link icon: `:lg`, `:md`, `:sm`. `:lg` is today's `text-2xl` heading and `text-base` subtitle. |
| `spacing` | Symbol | `:lg` | no | Vertical margin on the `.fp-section-title` wrapper: `:lg` (`my-8`), `:md` (`my-6`), `:sm` (`my-4`), `:none` (no wrapper margin). |
| `level` | Symbol | `:h2` | no | Heading tag: `:h1` through `:h6`. Visual size stays with `size:`, not the tag. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
None.

## Variants
- Size: `:lg` (default), `:md`, `:sm`.
- Spacing: `:lg` (default), `:md`, `:sm`, `:none`.
- Heading level: `:h2` (default) through `:h1`–`:h6`.
- Anchor behavior off (`anchor_link: false`) or on (`anchor_link: true`).

Caller `class:` still loses to component utilities (BaseComponent merge order). To own the margin, pass `spacing: :none` and then add `class: "mb-2"` (or similar).

## Example
```erb
<%= render FlatPack::SectionTitle::Component.new(
  title: "API Limits",
  subtitle: "Understand request windows and quotas.",
  anchor_link: true
) %>
```

Inside a card:

```erb
<%= render FlatPack::Card::Component.new do |card| %>
  <% card.body do %>
    <%= render FlatPack::SectionTitle::Component.new(
      title: "Members",
      subtitle: "Who can access this workspace",
      size: :md,
      spacing: :none
    ) %>
  <% end %>
<% end %>
```

## Accessibility
- Heading defaults to semantic `h2`. Pass `level:` when the document outline needs a different tag.
- Anchor control includes `aria-label` with section context.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--section-title-anchor`.
- Uses `FlatPack::Tooltip::Component` for anchor hint.
