# Search

## Purpose
Render a search input with optional live-result dropdown backed by a JSON endpoint.

## When to use
Use Search where users need quick keyword filtering in top nav or content surfaces.

## Class
- Primary: `FlatPack::Search::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `placeholder` | String | `"Search..."` | No | Input placeholder text. |
| `name` | String | `"q"` | No | Input `name` and query param key used for live search requests. |
| `value` | String | `nil` | No | Initial input value. |
| `search_url` | String | `nil` | No | Enables live search when present. URL is sanitized (safe protocols + relative URLs). |
| `max_width` | Symbol | `:md` | No | Wrapper max width. Allowed: `:none`, `:md`, `:lg`, `:xl`. |
| `min_characters` | Integer | `2` | No | Minimum trimmed query length before fetch is triggered. |
| `debounce` | Integer | `250` | No | Debounce delay in milliseconds for live requests. |
| `no_results_text` | String | `"No results found"` | No | Empty-state text shown in dropdown when no results match. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the wrapper/input (`class`, `id`, `data`, `aria`). |

## Slots
None.

## Variants
None.

## Example

```erb
<%= render FlatPack::Search::Component.new(
  search_url: search_results_path,
  placeholder: "Search components..."
) %>
```

Expected live-search response shape:

```json
{
  "results": [
    {
      "title": "Buttons",
      "description": "Button variants and examples",
      "url": "/demo/buttons"
    }
  ]
}
```

The controller also accepts a top-level JSON array instead of `{ "results": [...] }`.

## Accessibility
When `search_url` is present, the input includes `aria-haspopup="listbox"` and toggles `aria-expanded` as the dropdown opens/closes. `Escape` closes the dropdown.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Live search behavior requires Stimulus controller `flat-pack--search`.
