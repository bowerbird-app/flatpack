# Combobox

## Purpose
Let someone type to filter a list, then pick one value for a form field.

## When to use
Use Combobox when the list is long enough to search. Use Select for a short native-style dropdown. Combobox always submits a single hidden value. Use `search_mode: :remote` when the list lives on the server (place search, people, records). That mode shares Select's request and JSON contract.

## Class
- Primary: `FlatPack::Combobox::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String | none | yes | Name of the hidden submitted field. |
| `options` | Array | none | yes, unless `search_mode: :remote` | Strings, or hashes with `value:`, `label:`, and optional `subtitle:`. Seed the current choice here for a remote field. |
| `value` | String or nil | `nil` | no | Selected option value. |
| `label` | String or nil | `nil` | no | Visible field label. |
| `placeholder` | String | `"Search"` | no | Empty input hint. |
| `disabled` | Boolean | `false` | no | Disables the input and hidden field. |
| `required` | Boolean | `false` | no | Marks the hidden field required. |
| `empty_text` | String | `"No matches"` | no | Shown when the filter matches nothing. |
| `loading_text` | String | `"Searching..."` | no | Shown while a remote request is in flight. |
| `hint_text` | String | `"Type at least %{count} characters to search"` | no | Shown until the query reaches `min_search_length`. |
| `search_mode` | Symbol | `:local` | no | `:local` filters `options` in the browser. `:remote` fetches JSON. Invalid names raise. |
| `search_endpoint` | String or nil | `nil` | when `:remote` | URL for `GET` JSON options. Sanitized. Unsafe URLs raise. |
| `search_param` | String | `"q"` | no | Query string parameter name for the typed text. |
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

### JSON contract

Same contract as Select `search_mode: :remote`. `GET search_endpoint?search_param=query` with `Accept: application/json`. Canonical body:

```json
{
  "items": [
    { "value": "place_abc", "label": "Federation Square", "subtitle": "Melbourne VIC 3000" }
  ]
}
```

- `value` and `label` are required. Rows that omit either are dropped.
- `subtitle` is optional and Combobox-only. The field still submits `value`. Select ignores it.
- A top-level array of those objects is also accepted, the same as Select.
- Failed or empty responses show the empty row.

A choice dispatches `change` on the hidden field and `flat-pack:combobox:selected` on the root with `{ value, label, subtitle }`. Listen there to fill extra host fields.

## Accessibility
- The visible field is `role="combobox"` with `aria-controls` pointing at a `role="listbox"`. `spellcheck` is off.
- Arrow keys move `aria-activedescendant`. Enter chooses. Escape closes. One click on a row chooses it once.
- Typing filters labels. A value that no longer matches the typed text is cleared until a row is chosen.
- Remote search sets `aria-busy` on the field while a request is in flight.
- Open/close uses `--duration-base` with `--easing-enter` / `--easing-exit`, a few pixels of offset, and origin from the field. A close in flight can reverse. Under `prefers-reduced-motion`, the list fades without the offset.

## Dependencies
- Stimulus controller: `flat-pack--combobox`.
- Remote search uses `createRemoteQuery` in `flat_pack/remote_query.js`, shared with Select, Picker, and Search.
- Overlay motion: `playOverlayEnter` / `playOverlayExit` from `controllers/flat_pack/reduced_motion`.
- Surface tokens for the field and list (`--surface-*`, `--list-item-*`, `--form-control-padding-x`, `--form-control-padding-y`, `--combobox-menu-padding`, `--combobox-item-padding-x`, `--combobox-item-padding-y`).
