# Search Component

## Purpose
Render a reusable search input pattern for navigation and filter workflows.

## When to use
Use Search where users need quick keyword filtering in top nav or content surfaces.

## Class
- Primary: `FlatPack::Search::Component`

## Props
See the `Props` section below for supported arguments and defaults.

## Slots
See examples below for embedding in host layouts.

## Variants
See sizing and placement variants below.

## Example
Start with `Basic Usage` below.

## Accessibility
See accessibility notes below for labels and keyboard behavior.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).

The Search component provides a reusable search input with a leading icon, optimized for navigation and filtering UIs.

## Features

- Reusable across TopNav, sidebars, and page sections
- Built-in search icon
- Lightweight API with `placeholder`, `name`, and `value`
- Configurable live search endpoint via `search_url`
- Built-in dropdown with no-results messaging
- Supports system arguments (`class`, `id`, `data`, `aria`)

## Basic Usage

```erb
<%= render FlatPack::Search::Component.new(
  search_url: "/search/results",
  placeholder: "Search..."
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `placeholder` | String | `"Search..."` | Placeholder text |
| `name` | String | `"q"` | Input name attribute |
| `value` | String | `nil` | Initial input value |
| `search_url` | String | `nil` | Endpoint used for live search results |
| `min_characters` | Integer | `2` | Minimum characters before searching |
| `debounce` | Integer | `250` | Debounce delay in milliseconds |
| `no_results_text` | String | `"No results found"` | Message displayed when no results are returned |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`) |

## Examples

### In TopNav

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(
      search_url: search_results_path,
      placeholder: "Search projects, files, or people..."
    ) %>
  <% end %>
<% end %>
```

### Response format

Set `search_url` to any endpoint returning JSON in this shape:

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

If `results` is empty, the dropdown displays `no_results_text`.

### With Custom Name and Value

```erb
<%= render FlatPack::Search::Component.new(
  name: "query",
  value: "flatpack",
  placeholder: "Search components..."
) %>
```

## Styling

- Wrapper: `relative flex items-center w-full max-w-md`
- Icon: absolute positioned at the left
- Input: rounded field with focus ring and muted placeholder text

## Related Components

- [TopNav](./top_nav.md)
- [SearchInput](./inputs.md#searchinput)
