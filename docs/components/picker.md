# Picker

## Purpose
Render an item picker inline or in a modal. Picker supports images, files, and record-like items such as folders, with single or multiple selection returned through events or field output.

## When to use
Use Picker when users need to choose image assets, files, or application records such as folders, and your feature controls what happens after confirmation.

## Class
- Primary: `FlatPack::Picker::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `id` | String | none | Yes | Picker/modal id and event identity (`pickerId`). |
| `items` | Array<Hash> | `[]` | No | Initial items. Normalized to keys like `id`, `kind`, `title`, `label`, `name`, `icon`, `contentType`, `byteSize`, `thumbnail_url`, `description`, `right_text`, `path`, `badge`, `meta`, `payload`. |
| `title` | String | `"Select Assets"` | No | Modal title. |
| `subtitle` | String or nil | `nil` | No | Optional helper text under title. |
| `confirm_text` | String | `"Use Selected"` | No | Confirm button text. |
| `close_text` | String | `"Close"` | No | Close button text. |
| `size` | Symbol | `:lg` | No | Passed to `FlatPack::Modal::Component` size in modal mode, and reused for inline shell width (`:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`). |
| `selection_mode` | Symbol | `:multiple` | No | Allowed: `:single`, `:multiple`. |
| `accepted_kinds` | Array<Symbol/String> | `[:image, :file, :record]` | No | Allowed kind filter. Unknown kinds normalize to `file`. |
| `searchable` | Boolean | `false` | No | Enables search input in picker body. |
| `search_placeholder` | String | `"Search assets..."` | No | Search input placeholder. |
| `search_mode` | Symbol | `:local` | No | Allowed: `:local`, `:remote`. |
| `search_endpoint` | String or nil | `nil` | No | Required when `searchable: true` and `search_mode: :remote`. URL is sanitized. |
| `search_param` | String | `"q"` | No | Query param key used for remote search requests. |
| `output_mode` | Symbol | `:event` | No | Allowed: `:event`, `:field`. |
| `output_target` | String or nil | `nil` | No | CSS selector to receive JSON output when `output_mode: :field`. |
| `form` | Hash or nil | `nil` | No | Optional built-in Rails form wrapper. Supports `url`, `method`, `scope`, `field`, `value_mode`, `value_path`, and `turbo`. |
| `context` | Hash | `{}` | No | Arbitrary hash returned in confirm event payload. |
| `empty_state_text` | String | `"No assets found"` | No | Empty-results text. |
| `results_layout` | Symbol | `:list` | No | Allowed: `:list`, `:grid`. |
| `items_height` | String, Symbol, or Integer | `"max-content"` | No | Controls the results-region height inside the picker. Use `"max-content"` to fill the available picker body, `"min-content"` to shrink-wrap the current items up to the wrapper height, or a CSS height such as `"240px"`. Integers are converted to pixel values. |
| `modal` | Boolean | `false` | No | When `true`, renders inside `FlatPack::Modal::Component`. When `false`, renders inline on the page. |
| `auto_confirm` | Boolean | `false` | No | When `true` and `selection_mode: :single`, selecting an item immediately confirms it. |
| `modal_body_height_mode` | Symbol | `:fixed` | No | Passed to modal body sizing (`:auto`, `:fixed`, `:min`). Inline pickers still shrink-wrap short content; `:fixed` acts as a max-height cap for the inline body shell. |
| `modal_body_height` | String | `"clamp(20rem, 55vh, 30rem)"` | No | Modal body height or inline-body max-height cap, depending on `modal`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the modal wrapper or inline shell. |

## Item Display Slots

List rows are rendered through four display regions derived from item data rather than record-type-specific markup.

| region | item fields | fallback behavior |
|--------|-------------|-------------------|
| Leading media/icon | `thumbnail_url`, `icon` | Falls back to `photo`, `document-text`, or `folder` based on `kind` when no thumbnail/icon is provided. |
| Title | `title`, `label`, `name` | Uses the first present value in that order. |
| Description | `description` | Falls back to `path` or file metadata built from `content_type` and `byte_size`. |
| Right text | `right_text` | Falls back to `meta`, then `badge`. |

## Variants

| variant | description |
|---------|-------------|
| `selection_mode: :single` | One selected item at a time (radio/list behavior and single grid pressed state). |
| `selection_mode: :multiple` | Multiple selected items (checkbox/list behavior and multi grid toggles). |
| `search_mode: :local` | Filters initial `items` in browser. |
| `search_mode: :remote` | Fetches `GET search_endpoint?search_param=query&kinds=image,file,record`; expects JSON with `items` array. |
| `results_layout: :list` | Row-style selectable entries with metadata. Best default for record-like items such as folders. |
| `results_layout: :grid` | Thumbnail grid cards with pressed-state indicator. |
| `items_height: "max-content"` | Makes the results region fill the remaining picker body height and scroll within that area when needed. This is the default. |
| `items_height: "min-content"` | Shrinks the results region to the current item content while still capping at the picker wrapper height. Useful for short lists with only one or two options. |
| `items_height: "240px"` | Uses a fixed results-region height with overflow scrolling. Any valid CSS height string can be used. |
| `output_mode: :event` | Emits confirm event only. |
| `output_mode: :field` | Also writes selected JSON to hidden field and optional `output_target`. |
| `form: { ... }` | Wraps the picker in a standard Rails form and submits hidden inputs built from the current selection. |
| `modal: false` | Renders the picker inline without a modal backdrop or modal close behavior. Inline picker shells shrink-wrap their content and only use `modal_body_height` as a maximum body height cap. This is the default. |
| `selection_mode: :single, auto_confirm: true` | Selecting an item immediately syncs field output, emits `flat-pack:picker:confirm`, and closes the modal when modal-backed. |

## Built-in form config

Use `form:` when you want the picker to submit directly to a standard Rails controller without writing custom Stimulus or providing your own hidden field.

| key | type | default | description |
|-----|------|---------|-------------|
| `url` | String | none | Required form action URL. Sanitized with the same URL rules as other picker endpoints. |
| `method` | Symbol | `:post` | Form HTTP verb. Typical values are `:post`, `:patch`, or `:put`. |
| `scope` | Symbol/String or nil | `nil` | Optional param scope. Produces names like `project[asset_ids][]`. |
| `field` | Symbol/String | none | Required field name inside the scope, such as `folder_record_id` or `asset_ids`. |
| `value_mode` | Symbol | `:id` for single, `:ids` for multiple | Allowed: `:id`, `:ids`, `:json`. `:id` and `:ids` build Rails-friendly hidden inputs; `:json` submits one JSON string field. |
| `value_path` | String | `"id"` | Dot-path used to extract each submitted value from the selected item, such as `payload.record_id` or `payload.signed_id`. |
| `turbo` | Boolean | `true` | Whether the generated form should submit with Turbo enabled. |

## Example

Each picker item must include `name`. The component uses `thumbnail_url` and `right_text` for picker-specific display fields, alongside `content_type`/`contentType` and `byte_size`/`byteSize` for file metadata. Remote search responses must return JSON in the shape `{ items: [...] }`.

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

### Local-search modal picker

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

### Remote-search modal picker

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open Remote Picker",
  icon: "magnifying-glass",
  style: :secondary,
  data: {
    action: "click->flat-pack--modal#open",
    "modal-id": "picker-demo-remote"
  }
) %>

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-remote",
  title: "Search Remote Assets",
  subtitle: "Fetch matching assets from the server while keeping a stable modal height.",
  items: @picker_demo_items.first(2),
  modal: true,
  searchable: true,
  search_mode: :remote,
  search_endpoint: demo_picker_results_path,
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(20rem, 55vh, 30rem)",
  confirm_text: "Use Remote Selection",
  context: { target: "picker-demo-remote" }
) %>
```

Remote search is debounced by 250ms. When `accepted_kinds` is present, the picker appends a `kinds=image,file,record` style query param alongside the configured `search_param`.

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

### Record picker

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open Folder Picker",
  icon: "folder",
  style: :secondary,
  data: {
    action: "click->flat-pack--modal#open",
    "modal-id": "picker-demo-folders"
  }
) %>

<input id="picker-folder-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Folder selection JSON appears here">

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-folders",
  title: "Select Folder",
  subtitle: "Choose one folder record to confirm immediately.",
  items: @picker_demo_items,
  modal: true,
  accepted_kinds: [:record],
  selection_mode: :single,
  auto_confirm: true,
  searchable: true,
  search_mode: :local,
  output_mode: :field,
  output_target: "#picker-folder-field",
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(18rem, 48vh, 24rem)",
  confirm_text: "Use Folder",
  context: { target: "picker-demo-folders" }
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

The picker dispatches `flat-pack:picker:confirm` from its root element with `bubbles: true`, so document-level Stimulus listeners like `flat-pack:picker:confirm@document->picker-demo#handleConfirm` work for both inline and modal pickers.

### Built-in form picker

```erb
<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-built-in-form",
  title: "Assign Folder",
  subtitle: "Choose one folder and submit it through a built-in Rails form wrapper.",
  items: @picker_demo_items,
  accepted_kinds: [:record],
  selection_mode: :single,
  searchable: true,
  search_mode: :local,
  confirm_text: "Assign Folder",
  form: {
    url: demo_picker_submissions_path,
    method: :post,
    scope: :picker_assignment,
    field: :folder_record_id,
    value_mode: :id,
    value_path: "payload.record_id",
    turbo: false
  }
) %>
```

Controller example:

```ruby
def picker_submissions
  picker_assignment = params.require(:picker_assignment).permit(:folder_record_id)

  # Use the selected folder id however your app needs.
  flash[:picker_form_submission] = picker_assignment.to_h
  redirect_to demo_picker_path(anchor: "built-in-form")
end
```

Selected items preserve the optional display fields (`title`, `icon`, `description`, `right_text`) alongside `path`, `badge`, `meta`, and `payload` so consumers can round-trip both UI text and record metadata.

## Behavior notes

- `modal: false` is the default, so picker content renders inline unless a consumer explicitly opts into modal presentation.
- `modal: true` keeps the existing modal-backed behavior for trigger/button flows.
- List rows are built from display slots instead of record-specific row branches, so records, files, and images can share the same row structure.
- `items_height` only affects the results region that contains picker items. Search controls and action buttons keep their natural height above and below it.
- `auto_confirm` only applies to newly selected items in `selection_mode: :single`.
- Remote searches are debounced by 250ms, request JSON with `Accept: application/json`, and rerender the current result set from `payload.items`.
- In `output_mode: :field`, field output is written before the confirm event is emitted.
- When `form:` is configured, the picker maintains hidden inputs for the current selection and submits the generated form when `auto_confirm: true` selects a new single item.
- When `auto_confirm: true` and `modal: true`, the picker closes programmatically after dispatching `flat-pack:picker:confirm`.
- When `auto_confirm: true` and `modal: false`, the picker confirms immediately and stays visible inline.

## Accessibility
Picker content uses native form controls (`input[type=radio|checkbox]`) for list selection and button semantics for grid selection (`aria-pressed`). Search input includes an accessible label (`"Search available assets"`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Button::Component` and `FlatPack::Search::Component`, plus `FlatPack::Modal::Component` when `modal: true`.
- Interactive behavior requires Stimulus controller `flat-pack--picker`.
