# Pagination Infinite

## Purpose
Load additional paginated content as users scroll to a trigger sentinel.

## When to use
Use Pagination Infinite when table/card/list results should append or prepend incrementally without classic pagination controls.

## Class
- Primary: `FlatPack::PaginationInfinite::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `url` | String | `nil` | yes | Endpoint used for incremental fetches. |
| `page` | Integer | `1` | no | Current page number; must be greater than zero. |
| `has_more` | Boolean | `true` | no | When false, component renders nothing. |
| `loading_text` | String | `"Loading more..."` | no | Text used by inline loading variant. |
| `loading_variant` | Symbol | `:table` | no | Loading placeholder style: `:table`, `:cards`, `:inline`. |
| `insert_mode` | Symbol | `:append` | no | Content insertion mode: `:append`, `:prepend`. |
| `observe_root_selector` | String | `nil` | no | Optional custom `IntersectionObserver` root selector. |
| `cursor_selector` | String | `nil` | no | Selector for cursor element inside `[data-pagination-content]`. |
| `cursor_param` | String | `nil` | no | Query param name used to send cursor value. |
| `batch_size` | Integer | `nil` | no | Optional fetch batch size; must be greater than zero if provided. |
| `batch_size_param` | String | `"limit"` | no | Query parameter key used for `batch_size`. |
| `preserve_scroll_position` | Boolean | `false` | no | Preserves viewport position for prepend-mode loading. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper element. |

## Slots
None.

## Variants
- Loading variants: `:table`, `:cards`, `:inline`.
- Insert modes: `:append`, `:prepend`.

## Example
```erb
<%= render FlatPack::PaginationInfinite::Component.new(
  url: items_path(page: @next_page),
  page: @next_page,
  has_more: @has_more,
  loading_variant: :cards,
  insert_mode: :append
) %>
```

## Accessibility
- Trigger sentinel is hidden from assistive tech (`aria-hidden="true"`).
- Loading region visibility is toggled during fetches.
- Preserve clear heading/landmark context in surrounding result containers.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--pagination-infinite`.
- Uses `FlatPack::Skeleton::Component` for table/cards loading placeholders.
