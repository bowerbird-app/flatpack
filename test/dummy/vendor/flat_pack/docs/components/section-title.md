# Section Title

## Purpose
Render section headings with optional subtitle and optional copy-link anchor behavior.

## When to use
Use Section Title for document-style pages where subsections need deep-linkable anchors.

## Class
- Primary: `FlatPack::SectionTitle::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Section heading text. |
| `subtitle` | String | `nil` | no | Supporting copy below the heading. |
| `anchor_link` | Boolean | `false` | no | Enables hover/focus copy-link affordance and anchor id generation. |
| `anchor_id` | String | `nil` | no | Explicit anchor id when `anchor_link` is enabled; falls back to wrapper id or parameterized title. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
None.

## Variants
- Anchor behavior off (`anchor_link: false`) or on (`anchor_link: true`).

## Example
```erb
<%= render FlatPack::SectionTitle::Component.new(
  title: "API Limits",
  subtitle: "Understand request windows and quotas.",
  anchor_link: true
) %>
```

## Accessibility
- Heading is rendered as semantic `h2`.
- Anchor control includes `aria-label` with section context.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--section-title-anchor`.
- Uses `FlatPack::Tooltip::Component` for anchor hint.
