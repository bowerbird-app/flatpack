# Picker Component

## Purpose
Render a reusable asset picker for images/files while keeping consumer behavior fully configurable.

## When to use
Use Picker when users need to select one or multiple assets and your feature decides what to do with the selected payload.

## Class
- Primary: `FlatPack::Picker::Component`

## Features

- Supports image and file items in one reusable UI
- Single or multi-select modes
- Optional search using `FlatPack::Search::Component`
- Local filtering or remote search endpoint mode
- Consumer-defined behavior via `flat-pack:picker:confirm` event
- Optional field output mode to write selected JSON to a target input

## Basic Usage

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-picker",
  title: "Select Assets",
  items: items,
  searchable: true,
  search_mode: :local,
  context: {target: "composer"}
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `id` | String | required | Modal/picker id used for open/close hooks |
| `items` | Array<Hash> | `[]` | Initial items to display |
| `title` | String | `"Select Assets"` | Picker heading |
| `subtitle` | String, nil | `nil` | Optional helper text |
| `size` | Symbol | `:lg` | Modal size (`:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`) |
| `selection_mode` | Symbol | `:multiple` | `:single` or `:multiple` |
| `accepted_kinds` | Array<Symbol/String> | `[:image, :file]` | Filterable kind whitelist |
| `searchable` | Boolean | `false` | Enable search input |
| `search_placeholder` | String | `"Search assets..."` | Search placeholder |
| `search_mode` | Symbol | `:local` | `:local` or `:remote` |
| `search_endpoint` | String, nil | `nil` | Required for remote mode |
| `search_param` | String | `"q"` | Remote query param name |
| `confirm_text` | String | `"Use Selected"` | Confirm button text |
| `close_text` | String | `"Close"` | Close button text |
| `output_mode` | Symbol | `:event` | `:event` or `:field` |
| `output_target` | String, nil | `nil` | CSS selector for field output |
| `context` | Hash | `{}` | Opaque context passed back in event detail |
| `empty_state_text` | String | `"No assets found"` | Empty-state copy |
| `results_layout` | Symbol | `:list` | Results layout: `:list` rows or `:grid` thumbnail cards |
| `modal_body_height_mode` | Symbol | `:fixed` | Modal body sizing mode: `:auto`, `:fixed`, or `:min` |
| `modal_body_height` | String | `"clamp(20rem, 55vh, 30rem)"` | Body height value used by non-auto mode |

## Item Schema

```ruby
{
  id: "asset-123",
  kind: "image", # or "file"
  label: "Homepage Hero",
  name: "homepage-hero-v2.png",
  content_type: "image/png",
  byte_size: 312_400,
  thumbnail_url: "https://...", # optional
  meta: "optional helper text",
  payload: { any: "custom data" }
}
```

## Event Contract

Picker emits `flat-pack:picker:confirm` with:

```js
{
  pickerId,
  selection,
  selectionMode,
  acceptedKinds,
  context
}
```

Example consumer:

```js
document.addEventListener("flat-pack:picker:confirm", (event) => {
  const { pickerId, selection, context } = event.detail
  if (pickerId !== "asset-picker") return

  // Consumer-specific behavior
  console.log("Selected", selection, context)
})
```

## Field Output Mode

When `output_mode: :field`, picker writes selected JSON to:

- `output_target` selector, if provided
- internal hidden field target

This is useful for traditional form flows that do not use custom event handlers.

## Stable Modal Height

Picker defaults to a fixed modal body height to avoid layout jumps between populated and empty search states.

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-picker",
  items: items,
  searchable: true,
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(20rem, 55vh, 30rem)"
) %>
```

Use `modal_body_height_mode: :min` when you want a minimum body height with room to grow.

## Thumbnail Grid Layout

Use `results_layout: :grid` for image-heavy pickers so users can scan thumbnails instead of row entries.

```erb
<%= render FlatPack::Picker::Component.new(
  id: "image-picker",
  title: "Select Image",
  items: items,
  accepted_kinds: [:image],
  selection_mode: :single,
  searchable: true,
  results_layout: :grid
) %>
```
