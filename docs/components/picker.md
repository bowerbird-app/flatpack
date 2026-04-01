# Picker

## Purpose
Render an asset picker inline or in a modal. Picker supports single or multiple selection and returns selected items through events or field output.

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
| `size` | Symbol | `:lg` | No | Passed to `FlatPack::Modal::Component` size in modal mode, and reused for inline shell width (`:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`). |
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
| `modal` | Boolean | `false` | No | When `true`, renders inside `FlatPack::Modal::Component`. When `false`, renders inline on the page. |
| `auto_confirm` | Boolean | `false` | No | When `true` and `selection_mode: :single`, selecting an item immediately confirms it. |
| `modal_body_height_mode` | Symbol | `:fixed` | No | Passed to modal body sizing (`:auto`, `:fixed`, `:min`). |
| `modal_body_height` | String | `"clamp(20rem, 55vh, 30rem)"` | No | Passed to modal body height style. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the modal wrapper or inline shell. |

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
| `modal: false` | Renders the picker inline without a modal backdrop or modal close behavior. This is the default. |
| `selection_mode: :single, auto_confirm: true` | Selecting an item immediately syncs field output, emits `flat-pack:picker:confirm`, and closes the modal when modal-backed. |

## Examples

### Default inline picker

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

### Modal picker

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open Asset Picker",
  icon: "image",
  data: {
    action: "click->flat-pack--modal#open",
    "modal-id": "asset-picker-modal"
  }
) %>

<%= render FlatPack::Picker::Component.new(
  id: "asset-picker-modal",
  items: @assets,
  modal: true,
  searchable: true,
  search_mode: :local,
  selection_mode: :multiple,
  context: { target: "composer" }
) %>
```

### Inline auto-confirm picker

```erb
<input id="picker-inline-selected-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Inline selection JSON appears here">

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-inline",
  title: "Inline Asset Picker",
  subtitle: "Choose one item to confirm immediately.",
  items: @picker_demo_items,
  searchable: true,
  search_mode: :local,
  selection_mode: :single,
  auto_confirm: true,
  modal: false,
  output_mode: :field,
  output_target: "#picker-inline-selected-field",
  confirm_text: "Use Inline Selection",
  context: { target: "picker-demo-inline" }
) %>
```

### Image picker

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open Image Picker",
  icon: "image",
  data: {
    action: "click->flat-pack--modal#open",
    "modal-id": "picker-demo-images"
  }
) %>

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-images",
  title: "Select Image",
  subtitle: "Choose one or more image assets.",
  items: @picker_demo_items,
  modal: true,
  accepted_kinds: [:image],
  selection_mode: :multiple,
  searchable: true,
  search_mode: :local,
  results_layout: :grid,
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(18rem, 50vh, 26rem)",
  confirm_text: "Use Image",
  context: { target: "picker-demo-images" }
) %>
```

### Single-select auto-confirm picker

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open Auto-Confirm Picker",
  icon: "image",
  style: :secondary,
  data: {
    action: "click->flat-pack--modal#open",
    "modal-id": "picker-demo-auto-confirm"
  }
) %>

<input id="picker-auto-confirm-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Auto-confirm selection JSON appears here">

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-auto-confirm",
  title: "Choose One Asset",
  subtitle: "Selecting an item confirms immediately and closes the modal.",
  items: @picker_demo_items,
  modal: true,
  searchable: true,
  search_mode: :local,
  selection_mode: :single,
  auto_confirm: true,
  output_mode: :field,
  output_target: "#picker-auto-confirm-field",
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(18rem, 50vh, 24rem)",
  confirm_text: "Use Asset",
  context: { target: "picker-demo-auto-confirm" }
) %>
```

### Field output picker

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open Field Picker",
  icon: "file",
  data: {
    action: "click->flat-pack--modal#open",
    "modal-id": "picker-demo-field"
  }
) %>

<input id="picker-selected-assets-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Selected JSON appears here">

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-field",
  title: "Select Files",
  subtitle: "Writes selected items to a consumer-provided field selector.",
  items: @picker_demo_items,
  modal: true,
  accepted_kinds: [:file],
  searchable: true,
  search_mode: :local,
  modal_body_height_mode: :fixed,
  modal_body_height: "24rem",
  output_mode: :field,
  output_target: "#picker-selected-assets-field",
  confirm_text: "Store Selection",
  context: { target: "picker-demo-field" }
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

## Behavior notes

- `modal: false` is the default, so picker content renders inline unless a consumer explicitly opts into modal presentation.
- `modal: true` keeps the existing modal-backed behavior for trigger/button flows.
- `auto_confirm` only applies to newly selected items in `selection_mode: :single`.
- In `output_mode: :field`, field output is written before the confirm event is emitted.
- When `auto_confirm: true` and `modal: true`, the picker closes programmatically after dispatching `flat-pack:picker:confirm`.
- When `auto_confirm: true` and `modal: false`, the picker confirms immediately and stays visible inline.

## Accessibility
Picker content uses native form controls (`input[type=radio|checkbox]`) for list selection and button semantics for grid selection (`aria-pressed`). Search input includes an accessible label (`"Search available assets"`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Button::Component` and `FlatPack::Search::Component`, plus `FlatPack::Modal::Component` when `modal: true`.
- Interactive behavior requires Stimulus controller `flat-pack--picker`.
