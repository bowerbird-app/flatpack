# Combobox

## Purpose
Let someone type to filter a list, then pick one value for a form field.

## When to use
Use Combobox when the list is long enough to search. Use Select for a short native-style dropdown. With `name:`, Combobox submits one hidden value. Omit `name:` when the choice is handled in JavaScript and nothing should be submitted. Use `search_mode: :remote` when the list lives on the server (place search, people, records). That mode shares Select's request and JSON contract.

## Class
- Primary: `FlatPack::Combobox::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String or nil | `nil` | no | Name of the hidden submitted field. Omit it and no hidden field is rendered. |
| `id` | String or nil | unique | no | Id of the text input. The label `for` uses it. Omit it and the id is `fp-combobox-input-` plus random hex, so two fields can share a `name`. |
| `options` | Array | none | yes, unless `search_mode: :remote` | Strings, or hashes with `value:`, `label:`, optional `subtitle:`, and optional `data:` (a flat hash of strings, numbers, or booleans). Seed the current choice here for a remote field. |
| `value` | String or nil | `nil` | no | Selected option value. |
| `label` | String or nil | `nil` | no | Visible field label. |
| `icon` | String or nil | `nil` | no | Leading `FlatPack::Shared::IconComponent` name inside the field. The trailing chevron stays. The input gains `pl-1` so the text clears the icon. |
| `placeholder` | String | `"Search"` | no | Empty input hint. |
| `disabled` | Boolean | `false` | no | Disables the input and hidden field. |
| `required` | Boolean | `false` | no | Marks the hidden field required. Ignored when `name:` is omitted. |
| `empty_text` | String | `"No matches"` | no | Shown when the filter matches nothing. |
| `error_text` | String | `"Search failed"` | no | Shown instead of `empty_text` when a remote request fails. |
| `empty_action` | Hash or nil | `nil` | no | `{label:, value:}`. When the list is empty, or the request fails, an extra `role="option"` row is shown. Choosing it does not set the hidden value. |
| `loading_text` | String | `"Searching..."` | no | Shown while a remote request is in flight. |
| `hint_text` | String | `"Type at least %{count} characters to search"` | no | Shown until the query reaches `min_search_length`. |
| `search_mode` | Symbol | `:local` | no | `:local` filters `options` in the browser. `:remote` fetches JSON. Invalid names raise. |
| `search_endpoint` | String or nil | `nil` | when `:remote` | URL for `GET` JSON options. Sanitized. Unsafe URLs raise. |
| `search_param` | String | `"q"` | no | Query string parameter name for the typed text. |
| `search_params` | Hash | `{}` | no | Extra query params sent on every remote request. Values must be strings, numbers, or booleans. Nested values raise. |
| `min_search_length` | Integer | `2` | no | Characters required before a remote request. Minimum `1`. |
| `debounce` | Integer | `300` | no | Milliseconds to wait after typing before the remote request. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the wrapper. |

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::Combobox::Component.new(
  name: "city",
  label: "City",
  value: "melbourne",
  options: [
    {value: "melbourne", label: "Melbourne"},
    {value: "sydney", label: "Sydney"}
  ]
) %>
```

```erb
<%= render FlatPack::Combobox::Component.new(
  name: "place_id",
  label: "Place",
  search_mode: :remote,
  search_endpoint: place_search_path,
  search_param: "q",
  min_search_length: 3,
  debounce: 300,
  options: [
    {value: @place.id, label: @place.name, subtitle: @place.address}
  ]
) %>
```

```erb
<%= render FlatPack::Combobox::Component.new(
  name: "place_id",
  label: "Place",
  icon: "map-pin",
  search_mode: :remote,
  search_endpoint: place_search_path,
  search_params: {region: "au"},
  empty_action: {label: "Add a place", value: "add-place"}
) %>
```

### JSON contract

Same contract as Select `search_mode: :remote`. `GET search_endpoint?search_param=query` with `Accept: application/json`. Canonical body:

```json
{
  "items": [
    { "value": "place_abc", "label": "Federation Square", "subtitle": "Melbourne VIC 3000", "data": { "city": "melbourne" } }
  ]
}
```

- `value` and `label` are required. Rows that omit either are dropped.
- `subtitle` is optional and Combobox-only. The field still submits `value`. Select ignores it.
- `data` is an optional flat hash of strings, numbers, or booleans. Nested values are dropped. It is stored as JSON on `data-option-data` and copied into the selected event. It is not submitted.
- A top-level array of those objects is also accepted, the same as Select.
- An empty successful response shows `empty_text`. A non-OK response or a network error shows `error_text` instead. `AbortError` is ignored.
- `search_params` are added to that query string on every request.

### Events

All of these fire on the combobox root and bubble.

| Event | When | Detail |
|---|---|---|
| `flat-pack:combobox:selected` | A result row is chosen | `{ value, label, subtitle, data }` |
| `flat-pack:combobox:results` | A remote response is OK and still matches the field | `{ query, items, payload }`. `items` are normalized. `payload` is the parsed JSON. There is no `meta` key. |
| `flat-pack:combobox:error` | The response is not OK, or the network fails | `{ status }`. `status` is the HTTP status, or `null` for a network error. |
| `flat-pack:combobox:empty-action` | The empty-action row is chosen | `{ query, value }`. The hidden value is left as it is. |
| `flat-pack:combobox:cleared` | `clear()` runs, or the person deletes the text in the field while a hidden value was set | none |

Choosing a row also dispatches `change` on the hidden field when `name:` is set. `clear()` does too. `setSelection({ value, label })` sets both fields, dispatches `change`, and does not open the list or dispatch `selected`. Use `change` for that path.

`clear()` empties the input and the hidden value, closes the list, then dispatches `change` and `flat-pack:combobox:cleared`. With no `name:`, there is no hidden field and no `change` event. `clear()` and `setSelection` still run.

## Accessibility
- The visible field is `role="combobox"` with `aria-controls` pointing at a `role="listbox"`. `spellcheck` is off.
- Arrow keys move `aria-activedescendant`. Enter chooses. Escape closes. One click on a row chooses it once. The empty-action row is a real option, so arrows and Enter reach it.
- Typing filters labels. A value that no longer matches the typed text is cleared until a row is chosen. Deleting the text also dispatches `flat-pack:combobox:cleared` when a hidden value was set.
- Remote search sets `aria-busy` on the field while a request is in flight. Hint, loading, empty, and error rows are `role="status"` with `aria-live="polite"`. Error text uses that same row, so it is announced the same way as empty text.
- A new keystroke aborts the in-flight search. A response for an older query does not paint rows.
- Open/close uses `--duration-base` with `--easing-enter` / `--easing-exit`, a few pixels of offset, and origin from the field. A close in flight can reverse. Under `prefers-reduced-motion`, the list fades without the offset.

## Dependencies
- Stimulus controller: `flat-pack--combobox`.
- Remote search uses `createRemoteQuery` in `flat_pack/remote_query.js`, shared with Select, Picker, and Search.
- Overlay motion: `playOverlayEnter` / `playOverlayExit` from `controllers/flat_pack/reduced_motion`.
- Surface tokens for the field and list (`--surface-*`, `--list-item-*`, `--form-control-padding-x`, `--form-control-padding-y`, `--combobox-menu-padding`, `--combobox-item-padding-x`, `--combobox-item-padding-y`).
