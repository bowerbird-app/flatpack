# Comments Item

## Purpose
Render a single comment with author metadata, body content, and optional action/reply regions.

## When to use
Use Comments Item inside lists or nested replies to keep comment presentation consistent.

## Class
- Primary: `FlatPack::Comments::Item::Component`
- Related classes: `FlatPack::Avatar::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `author_name` | String | `nil` | yes | Author display name; blank values raise `ArgumentError`. |
| `author_meta` | String | `nil` | no | Secondary author text (role, handle, etc.). |
| `timestamp` | String | `nil` | no | Human-readable timestamp text. |
| `timestamp_iso` | String | `nil` | no | ISO datetime value for `<time datetime>`. |
| `body` | String | `nil` | no | Plain-text comment body. |
| `body_html` | String | `nil` | no | HTML body content; rendered as trusted HTML. |
| `edited` | Boolean | `false` | no | Appends `(edited)` marker beside timestamp. |
| `state` | Symbol | `:default` | no | Visual state: `:default`, `:system`, `:deleted`; invalid values raise `ArgumentError`. |
| `avatar` | Hash | `{}` | no | Avatar overrides (`src`, `alt`, `name`, `initials`, `href`). |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for item wrapper. |

## Slots
- `actions`: action links/buttons row (hidden for deleted state).
- `footer`: optional footer metadata (reactions, counters).
- `replies`: nested replies region.

## Variants
- State variants: `:default`, `:system`, `:deleted`.

## Example
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Mina Cho",
  author_meta: "Designer",
  timestamp: "2h ago",
  body: "Shipping this in the next iteration looks good.",
  state: :default
) %>
```

## Accessibility
- Uses semantic `<time>` when timestamp is provided.
- Ensure action controls in `actions` slot are keyboard reachable and labeled.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Avatar::Component` for author avatar rendering.
