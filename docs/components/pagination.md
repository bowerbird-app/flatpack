# Pagination

## Purpose
Render standard page-number pagination or delegate to infinite loading behavior.

## When to use
Use Pagination for index/list pages that need explicit page navigation, or as a compatibility wrapper for infinite mode.

## Class
- Primary: `FlatPack::Pagination::Component`
- Related classes: `FlatPack::PaginationInfinite::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `pagy` | Pagy-like object | `nil` | conditional | Required in `:standard` mode; must respond to `page` and `pages` (and typically `prev`, `next`, `series`). |
| `size` | Symbol | `:normal` | no | Pagination density: `:normal`, `:compact`. |
| `mode` | Symbol | `:standard` | no | Behavior: `:standard` or `:infinite`. |
| `anchor` | String | `nil` | no | Optional URL fragment (without `#`) appended to generated links. |
| `turbo_frame` | String | `nil` | no | Adds `data-turbo-frame` to generated page links. |
| `infinite_url` | String | `nil` | no | Explicit URL used when `mode: :infinite`. |
| `has_more` | Boolean | `true` | no | `:infinite` mode guard for whether more content exists. |
| `loading_text` | String | `"Loading more..."` | no | `:infinite` mode loading text. |
| `loading_variant` | Symbol | `:table` | no | Forwarded loading style to `PaginationInfinite`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
None.

## Variants
- `mode`: `:standard`, `:infinite`.
- `size`: `:normal`, `:compact`.

## Example
```erb
<%= render FlatPack::Pagination::Component.new(
  pagy: @pagy,
  size: :normal,
  anchor: "results",
  turbo_frame: "search-results"
) %>
```

## Accessibility
- Renders `<nav aria-label="Pagination">`.
- Current page sets `aria-current="page"`.
- Disabled prev/next states expose `aria-disabled="true"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Pagy integration in standard mode.
- Uses `FlatPack::PaginationInfinite::Component` when `mode: :infinite`.
