# Breadcrumb

## Purpose
Render hierarchical navigation with separators, optional back/home items, and current-page semantics.

## When to use
Use Breadcrumb on nested pages where users need orientation and quick navigation to parent levels.

## Class
- Primary: `FlatPack::Breadcrumb::Component`
- Related classes: `FlatPack::Breadcrumb::Item::Component`

## Props
`FlatPack::Breadcrumb::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `separator` | Symbol | `:chevron` | no | Separator style: `:chevron`, `:slash`, `:arrow`, `:dot`, `:custom`; invalid values raise `ArgumentError`. |
| `separator_icon` | String | `nil` | no | Icon name used only when `separator: :custom`. |
| `show_back` | Boolean | `false` | no | Prepends a back item that defaults to the previous linked breadcrumb level. |
| `back_text` | String | `"Back"` | no | Back item text. |
| `back_icon` | String | `"chevron-left"` | no | Back item icon name. |
| `back_href` | String | `nil` | no | Explicit back target that overrides derived breadcrumb behavior. |
| `back_fallback_url` | String | `"/"` | no | URL used when no previous linked breadcrumb level exists. |
| `show_home` | Boolean | `false` | no | Prepends a home item before declared items. |
| `home_url` | String | `"/"` | no | Home item URL. |
| `home_text` | String | `"Home"` | no | Home item label text. |
| `home_icon` | String | `"home"` | no | Home item icon name. |
| `max_items` | Integer | `nil` | no | When exceeded, collapses middle items to `...` item. |
| `items` | Array<Hash> | `nil` | no | Convenience item array; each hash supports `text`, `href`, `icon`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for `<nav>` wrapper. |

`FlatPack::Breadcrumb::Item::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Display text for the breadcrumb item. Blank values raise `ArgumentError`. |
| `href` | String | `nil` | no | Link URL. When omitted, item renders as current page (`aria-current="page"`). |
| `icon` | String | `nil` | no | Optional leading icon name rendered via `FlatPack::Shared::IconComponent`. |
| `**system_arguments` | Hash | `{}` | no | Extra HTML attributes for the `<a>` element when `href` is present. |

## Methods
`FlatPack::Breadcrumb::Component`:

| method | arguments | description |
|---|---|---|
| `item` | `text:, href: nil, icon: nil` | Appends one breadcrumb item in the block API. |

`FlatPack::Breadcrumb::Item::Component`:

| method | arguments | description |
|---|---|---|
| `current?` | none | Returns `true` when `href` is `nil`, meaning the item is the current page. |

## Slots
- `item(text:, href: nil, icon: nil)` creates breadcrumb items.

## Variants
- Separator variants: `:chevron`, `:slash`, `:arrow`, `:dot`, `:custom`.
- Item state: linked item when `href` is present, current-page item when `href` is `nil`.

## Example
```erb
<%= render FlatPack::Breadcrumb::Component.new(separator: :chevron, show_home: true) do |breadcrumb| %>
  <% breadcrumb.item(text: "Settings", href: "/settings") %>
  <% breadcrumb.item(text: "Profile") %>
<% end %>
```

When `show_back: true` is enabled, the back item resolves to the previous linked breadcrumb item by default. Use `back_href:` to force a specific destination, and `back_fallback_url:` when the trail has no earlier linked level.

## Accessibility
- Wrapper uses semantic `<nav aria-label="Breadcrumb">` with ordered list items.
- Current page item renders `aria-current="page"` when `href` is omitted.
- Separator elements are marked with `aria-hidden="true"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Shared::IconComponent` for item and custom separator icons.
