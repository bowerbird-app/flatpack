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
| `confirm_label` | String | `"Use Selected"` | No | Confirm button text. |
| `close_label` | String | `"Close"` | No | Close button text. |
| `size` | Symbol | `:lg` | No | Passed to `FlatPack::Modal::Component` size in modal mode, and reused for inline shell width (`:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`). |
| `selection_mode` | Symbol | `:multiple` | No | Allowed: `:single`, `:multiple`. |
| `accepted_kinds` | Array<Symbol/String> | `[:image, :file, :record]` | No | Allowed kind filter. Unknown kinds normalize to `file`. |
| `searchable` | Boolean | `true` | No | Enables the local search input. When `false`, local pickers hide the search bar entirely. Remote pickers still render search. |
| `minimum_searchable` | Integer or nil | `nil` | No | For local pickers, hide the search bar when the initial item count is less than or equal to this threshold. |
| `search_placeholder` | String | `"Search assets..."` | No | Search input placeholder. |
| `search_mode` | Symbol | `:local` | No | Allowed: `:local`, `:remote`. |
| `search_endpoint` | String or nil | `nil` | No | Required when `search_mode: :remote`. URL is sanitized. |
| `search_param` | String | `"q"` | No | Query param key used for remote search requests. |
| `output_mode` | Symbol | `:event` | No | Allowed: `:event`, `:field`. |
| `output_target` | String or nil | `nil` | No | CSS selector to receive JSON output when `output_mode: :field`. |
| `form` | Hash or nil | `nil` | No | Optional built-in Rails form wrapper. Supports `url`, `method`, `scope`, `field`, `value_mode`, `value_path`, and `turbo`. |
| `variant` | Symbol | `:default` | No | Allowed: `:default`, `:flush`. Inline shells only. `:flush` drops the panel chrome (border, fill, radius, shadow, padding) so the picker can sit inside another surface. Modal pickers ignore it and keep Modal chrome. Anything else raises `ArgumentError`. |
| `context` | Hash | `{}` | No | Arbitrary hash returned in confirm event payload. |
| `empty_text` | String | `"No assets found"` | No | Empty-results text when the `empty` slot is omitted. |
| `results_layout` | Symbol | `:list` | No | Allowed: `:list`, `:grid`. |
| `items_height` | String, Symbol, or Integer | `"max-content"` | No | Controls the results-region height inside the picker. Use `"max-content"` to fill the available picker body, `"min-content"` to shrink-wrap the current items up to the wrapper height, or a CSS height such as `"240px"`. Integers are converted to pixel values. |
| `modal` | Boolean | `false` | No | When `true`, renders inside `FlatPack::Modal::Component`. When `false`, renders inline on the page. |
| `auto_confirm` | Boolean | `false` | No | When `true` and `selection_mode: :single`, selecting an item immediately confirms it. |
| `modal_body_height_mode` | Symbol | `:fixed` | No | Passed to modal body sizing (`:auto`, `:fixed`, `:min`). Inline pickers still shrink-wrap short content; `:fixed` acts as a max-height cap for the inline body shell. |
| `modal_body_height` | String | `"clamp(20rem, 55vh, 30rem)"` | No | Modal body height or inline-body max-height cap, depending on `modal`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the modal wrapper or inline shell. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `empty` | slot | no | Markup for an empty result list. Rendered on the server inside the results region and hidden until nothing matches. `flat-pack--picker` only shows or hides it. It does not change the slot's contents. Omit the slot and the picker shows `empty_text`. Works for `search_mode: :local` and `:remote`. |
| `toolbar` | slot | no | Optional actions on the same row as the search box. Call `with_toolbar`. The search field grows. The toolbar sits at the end of the row and wraps onto the next line when the row is narrow. Omit the slot and the search box renders with no extra row. The toolbar is not part of the title. Use `modal: false` and `variant: :flush` when a host modal owns the header. |

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
| `search_mode: :remote` | Fetches `GET search_endpoint?search_param=query&page=1&kinds=image,file,record`. Expects JSON `{ items, pagination: { next_page } }`. A new query replaces the list. `next_page` loads another page onto the end. `null` or a missing `pagination` stops. Always renders the search bar. |
| `searchable: false` | Hides the search bar for local pickers regardless of item count. |
| `minimum_searchable: 5` | For local pickers, hides the search bar when the initial item count is 5 or fewer items. |
| `results_layout: :list` | Row-style selectable entries with metadata. Best default for record-like items such as folders. |
| `results_layout: :grid` | Thumbnail grid cards with pressed-state indicator. |
| `items_height: "max-content"` | Makes the results region fill the remaining picker body height and scroll within that area when needed. This is the default. |
| `items_height: "min-content"` | Shrinks the results region to the current item content while still capping at the picker wrapper height. Useful for short lists with only one or two options. |
| `items_height: "240px"` | Uses a fixed results-region height with overflow scrolling. Any valid CSS height string can be used. |
| `output_mode: :event` | Emits confirm event only. |
| `output_mode: :field` | Also writes selected JSON to hidden field and optional `output_target`. |
| `form: { ... }` | Wraps the picker in a standard Rails form and submits hidden inputs built from the current selection. |
| `modal: false` | Renders the picker inline without a modal backdrop or modal close behavior. Inline picker shells shrink-wrap their content and only use `modal_body_height` as a maximum body height cap. This is the default. |
| `variant: :flush` | Inline shell with no border, fill, radius, shadow, or padding (`border-0 bg-transparent shadow-none rounded-none p-0`). Use this instead of host `!` class overrides when the picker is embedded in a parent panel. Modal mode still uses Modal chrome. |
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

Each picker item must include `name`. The component uses `thumbnail_url` and `right_text` for picker-specific display fields, alongside `content_type`/`contentType` and `byte_size`/`byteSize` for file metadata. Remote responses use this JSON contract:

```json
{
  "items": [],
  "pagination": { "next_page": 2 }
}
```

`items` replaces the list on a new query and is appended for a later page. The picker sends `page`, starting at `1`, on the same request as the search param. Follow only `pagination.next_page`. `null`, `""`, or a missing `pagination` object means there is no next page. Do not infer a page number from the item count.

### Default inline picker

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-picker",
  items: @assets,
  search_mode: :local,
  selection_mode: :multiple,
  context: { target: "composer" }
) %>
```

### Flush inline picker

Use `variant: :flush` when the picker sits inside another surface (a moveable panel, a card body, a sidebar) and should not draw its own panel chrome.

```erb
<%= render FlatPack::Picker::Component.new(
  id: "embedded-asset-picker",
  items: @assets,
  variant: :flush,
  search_mode: :local,
  selection_mode: :single,
  auto_confirm: true
) %>
```

### Search toolbar

```erb
<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-toolbar",
  title: "Files",
  items: @picker_demo_items,
  variant: :flush,
  modal: false,
  search_mode: :local,
  selection_mode: :single,
  auto_confirm: true,
  items_height: "min-content"
) do |picker| %>
  <% picker.with_toolbar do %>
    <%= render FlatPack::Button::Component.new(text: "Upload", icon: "arrow-up-tray", style: :secondary, size: :sm) %>
    <%= render FlatPack::Button::Component.new(text: "New folder", icon: "folder-plus", style: :ghost, size: :sm) %>
  <% end %>
<% end %>
```

Pass `title: ""` when the host already draws the header. The toolbar stays on the search row either way.

### Thresholded local picker

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-picker-shortlist",
  items: @assets.first(4),
  minimum_searchable: 5,
  selection_mode: :multiple,
  context: { target: "shortlist" }
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
  search_mode: :remote,
  search_endpoint: demo_picker_results_path,
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(20rem, 55vh, 30rem)",
  confirm_label: "Use Remote Selection",
  context: { target: "picker-demo-remote" }
) %>
```

Remote search is debounced by 250ms and always renders the search bar, even if `searchable: false` is passed. The first request goes out when the picker connects, with an empty query and `page=1`. When `accepted_kinds` is present, the picker appends a `kinds=image,file,record` style query param alongside the configured `search_param` and `page`.

A changed or cleared query replaces the list and starts again at `page=1`. The next page is appended. An in-flight request is aborted when a newer query starts, and a response whose turn has passed is ignored. The items region is the scroll root. A sentinel at the end of the list asks for `next_page` when it enters that region. A loading row sits at the end of the list while a page is in flight. A polite live region announces how many results are loaded, for example `8 loaded`. Confirm still returns every selected item, including ones from an earlier page or query that is no longer on screen.

### Remote pages

Give the results region a fixed height so the sentinel scrolls inside the picker, not the page.

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-library",
  title: "Asset library",
  items: [],
  search_mode: :remote,
  search_endpoint: picker_results_path,
  items_height: "240px",
  selection_mode: :multiple
) %>
```

### Empty slot

```erb
<%= render FlatPack::Picker::Component.new(
  id: "asset-picker",
  items: @assets,
  search_mode: :local
) do |picker| %>
  <% picker.with_empty do %>
    <%= render FlatPack::EmptyState::Component.new(
      title: "Nothing in the drawer",
      description: "Try a different word, or add an asset.",
      icon: :search,
      size: :sm
    ) do |state| %>
      <% state.item do %>
        <%= render FlatPack::Button::Component.new(text: "Add an asset", style: :primary, type: "button") %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

Pass the same `empty` slot on a remote picker. The controller shows it when the endpoint returns no items, and hides it when items come back. The button stays the one you rendered. Leave the slot off and `empty_text` is the fallback.

### Inline auto-confirm picker

```erb
<input id="picker-inline-selected-field" type="text" readonly class="w-full rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-2 text-xs text-(--surface-muted-content-color)" placeholder="Inline selection JSON appears here">

<%= render FlatPack::Picker::Component.new(
  id: "picker-demo-inline",
  title: "Inline Asset Picker",
  subtitle: "Choose one item to confirm immediately.",
  items: @picker_demo_items,
  search_mode: :local,
  selection_mode: :single,
  auto_confirm: true,
  modal: false,
  output_mode: :field,
  output_target: "#picker-inline-selected-field",
  confirm_label: "Use Inline Selection",
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
  search_mode: :local,
  results_layout: :grid,
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(18rem, 50vh, 26rem)",
  confirm_label: "Use Image",
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
  search_mode: :local,
  output_mode: :field,
  output_target: "#picker-folder-field",
  modal_body_height_mode: :fixed,
  modal_body_height: "clamp(18rem, 48vh, 24rem)",
  confirm_label: "Use Folder",
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
  confirm_label: "Use Asset",
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
  confirm_label: "Store Selection",
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
  confirm_label: "Assign Folder",
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
- `items_height` only affects the results region that contains picker items. Search controls, the toolbar, and action buttons keep their natural height above and below it.
- `toolbar` renders beside search inside the picker body. It is not rendered in the inline title or the modal header. With no slot, the search box is a direct child of the picker and no toolbar row is rendered. A hidden search still renders the toolbar row when the slot is present.
- `auto_confirm` only applies to newly selected items in `selection_mode: :single`.
- Remote searches are debounced by 250ms and request JSON with `Accept: application/json`. Page 1 replaces `filteredItems` from `payload.items`. A later `pagination.next_page` appends. The items region (`data-flat-pack-picker-items-region`) is the `IntersectionObserver` root, not the viewport.
- The empty panel is in the first render, with the `hidden` class. An `empty` slot fills that panel. `empty_text` fills it when the slot is omitted. Local filtering and remote responses only toggle `hidden` and `flex`. They do not rewrite the panel.
- The loading row is hidden until a request starts. The empty state still shows when the rendered list is empty, and hides when it is not.
- Selected items are cached by id. Confirm uses that cache, so a selection from an earlier page or query is included after the list is replaced.
- In `output_mode: :field`, field output is written before the confirm event is emitted.
- When `form:` is configured, the picker maintains hidden inputs for the current selection and submits the generated form when `auto_confirm: true` selects a new single item.
- When `auto_confirm: true` and `modal: true`, the picker closes programmatically after dispatching `flat-pack:picker:confirm`.
- When `auto_confirm: true` and `modal: false`, the picker confirms immediately and stays visible inline.

Grid item badges use `--picker-badge-*`. Idle selection rings use `--picker-selection-idle-*`. The light ring and inner dot on media use `--picker-selection-indicator-*`. Selected rings stay on `--color-primary`.

## Accessibility
Picker content uses native form controls (`input[type=radio|checkbox]`) for list selection and button semantics for grid selection (`aria-pressed`). Multiple-mode list checkboxes use the same theme primary CSS vars as `Checkbox::Component` (`accent-[var(--color-primary)]`, `checked:bg-[var(--color-primary)]`, `checked:border-[var(--color-primary)]`, `checked:text-[var(--color-primary-text)]`). Search input includes an accessible label (`"Search available assets"`). Remote pickers expose a polite live region that announces the loaded count, and mark the items region `aria-busy` while a page is loading.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Button::Component` and `FlatPack::Search::Component`, plus `FlatPack::Modal::Component` when `modal: true`.
- Interactive behavior requires Stimulus controller `flat-pack--picker`.
