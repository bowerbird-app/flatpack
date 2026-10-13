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
| name | type | description |
|---|---|---|
| `trailing` (`with_trailing`) | slot | Content after the heading and before the copy-link icon. Outside the heading tag and outside the anchor, so the heading's accessible name and the copy-link label stay the title. Generic: a badge, a count, or anything else. Not a count param. |

The title row stays vertically centred. On a narrow width the row can wrap, and the heading can shrink and break long words. Trailing content and the copy-link icon keep their size.

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

With something beside the title:

```erb
<%= render FlatPack::SectionTitle::Component.new(
  title: "Images",
  anchor_link: true
) do |section| %>
  <% section.with_trailing do %>
    <%= render FlatPack::Badge::Component.new(text: "24", size: :sm) %>
  <% end %>
<% end %>
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
- Anchor control includes `aria-label` with section context. The label is the title only.
- `with_trailing` is outside the heading and outside the anchor, so a badge does not become part of the heading name or the copy-link label.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--section-title-anchor` shows and hides the icon.
- The anchor uses `flat-pack--clipboard` (`feedback: quiet`) to copy the absolute URL, announce it, and update the hash. A non-hash `href` is left to the browser.
- Uses `FlatPack::Tooltip::Component` for anchor hint.
