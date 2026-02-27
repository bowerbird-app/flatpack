# Picker Component

## Purpose
Render a modal-based asset picker that supports single or multiple selection and returns selected items through events or field output.

## When to use
Use Picker when users need to choose image/file assets and your feature controls what happens after confirmation.

## Class
- Primary: `FlatPack::Picker::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `id` | String | none | Yes | Picker/modal id and event identity (`pickerId`). |
| `items` | Array<Hash> | `[]` | No | Initial items. Normalized to keys like `id`, `kind`, `label`, `name`, `contentType`, `byteSize`, `thumbnailUrl`, `meta`, `payload`. |
| `title` | String | `"Select Assets"` | No | Modal title. |
| `subtitle` | String or nil | `nil` | No | Optional helper text under title. |
| `confirm_text` | String | `"Use Selected"` | No | Confirm button text. |
| `close_text` | String | `"Close"` | No | Close button text. |
| `size` | Symbol | `:lg` | No | Passed to `FlatPack::Modal::Component` size (`:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`). |
| `selection_mode` | Symbol | `:multiple` | No | Allowed: `:single`, `:multiple`. |
| `accepted_kinds` | Array<Symbol/String> | `[:image, :file]` | No | Allowed kind filter. Non-`image` values normalize to `file`. |
| `searchable` | Boolean | `false` | No | Enables search input in picker body. |
| `search_placeholder` | String | `"Search assets..."` | No | Search input placeholder. |
| `search_mode` | Symbol | `:local` | No | Allowed: `:local`, `:remote`. |
| `search_endpoint` | String or nil | `nil` | No | Required when `searchable: true` and `search_mode: :remote`. URL is sanitized. |
| `search_param` | String | `"q"` | No | Query param key used for remote search requests. |
| `output_mode` | Symbol | `:event` | No | Allowed: `:event`, `:field`. |
| `output_target` | String or nil | `nil` | No | CSS selector to receive JSON output when `output_mode: :field`. |
| `context` | Hash | `{}` | No | Arbitrary hash returned in confirm event payload. |
| `empty_state_text` | String | `"No assets found"` | No | Empty-results text. |
| `results_layout` | Symbol | `:list` | No | Allowed: `:list`, `:grid`. |
| `modal_body_height_mode` | Symbol | `:fixed` | No | Passed to modal body sizing (`:auto`, `:fixed`, `:min`). |
| `modal_body_height` | String | `"clamp(20rem, 55vh, 30rem)"` | No | Passed to modal body height style. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into modal wrapper. |

## Slots
None.

## Variants

| variant | description |
|---------|-------------|
| `selection_mode: :single` | One selected item at a time (radio/list behavior and single grid pressed state). |
| `selection_mode: :multiple` | Multiple selected items (checkbox/list behavior and multi grid toggles). |
| `search_mode: :local` | Filters initial `items` in browser. |
| `search_mode: :remote` | Fetches `GET search_endpoint?search_param=query&kinds=image,file`; expects JSON with `items` array. |
| `results_layout: :list` | Row-style selectable entries with metadata. |
| `results_layout: :grid` | Thumbnail grid cards with pressed-state indicator. |
| `output_mode: :event` | Emits confirm event only. |
| `output_mode: :field` | Also writes selected JSON to hidden field and optional `output_target`. |

## Example

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-picker",
  items: @assets,
  searchable: true,
  search_mode: :local,
  selection_mode: :multiple,
  context: { target: "composer" }
) %>
```

Confirm event contract:

```js
{
  pickerId,
  selection,
  selectionMode,
  acceptedKinds,
  context
}
```

## Accessibility
Picker content uses native form controls (`input[type=radio|checkbox]`) for list selection and button semantics for grid selection (`aria-pressed`). Search input includes an accessible label (`"Search available assets"`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Modal::Component`, `FlatPack::Button::Component`, and `FlatPack::Search::Component`.
- Interactive behavior requires Stimulus controller `flat-pack--picker`.
