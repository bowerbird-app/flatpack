# Avatar Group

## Purpose
Render overlapping user avatars with optional overflow count for compact participant displays.

## When to use
Use Avatar Group for teams, collaborators, or participant lists where many users must fit in limited space.

## Class
- Primary: `FlatPack::AvatarGroup::Component`
- Related classes: `FlatPack::Avatar::Component`, `FlatPack::Tooltip::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `items` | Array<Hash> | `[]` | yes | Avatar item hashes. Each item may include `:src`, `:alt`, `:name`, `:initials`, `:status`, `:href`. |
| `max` | Integer | `5` | no | Maximum visible avatars before overflow avatar is shown. |
| `size` | Symbol | `:sm` | no | Passed to each avatar (`FlatPack::Avatar::Component` sizes). |
| `overlap` | Symbol | `:md` | no | Overlap spacing: `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `show_overflow` | Boolean | `true` | no | Shows `+N` overflow avatar when hidden items exist. |
| `overflow_href` | String | `nil` | no | Optional link URL for overflow avatar. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for group wrapper. |

## Slots
None.

## Variants
- Overlap spacing: `:sm`, `:md`, `:lg`.
- Avatar appearance is controlled through `size` and per-item avatar fields.

## Example
```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: [
    { name: "Alex Rivera", src: "https://example.com/alex.jpg", status: :online },
    { name: "Morgan Lee", src: "https://example.com/morgan.jpg" },
    { name: "Casey Jordan" }
  ],
  max: 2,
  overlap: :md,
  overflow_href: "/users"
) %>
```

## Accessibility
- Individual avatars inherit avatar accessibility behavior (image `alt`, initials fallback).
- Avatars with `name`/`alt` render tooltip labels at `:bottom` placement.
- Overflow avatar tooltip lists hidden member names when available.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Avatar::Component` to render each item.
- Uses `FlatPack::Tooltip::Component` for member and overflow tooltips.
