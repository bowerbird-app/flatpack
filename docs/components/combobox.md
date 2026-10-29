# Combobox

## Purpose
Let someone type to filter a list, then pick one value for a form field.

## When to use
Use Combobox when the list is long enough to search. Use Select for a short native-style dropdown. Combobox always submits a single hidden value. Use `search_endpoint:` when the list lives on the server (place search, people, records). Use `loader: true` when the host already has a JS function that returns options.

## Class
- Primary: `FlatPack::Combobox::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String | none | yes | Name of the hidden submitted field. |
| `options` | Array | none | yes, unless `search_endpoint` or `loader` | Strings, or hashes with `value:`, `label:`, and optional `subtitle:`. Seed the current choice here for async fields. |
| `value` | String or nil | `nil` | no | Selected option value. |
| `label` | String or nil | `nil` | no | Visible field label. |
| `placeholder` | String | `"Search"` | no | Empty input hint. |
| `disabled` | Boolean | `false` | no | Disables the input and hidden field. |
| `required` | Boolean | `false` | no | Marks the hidden field required. |
| `empty_text` | String | `"No matches"` | no | Shown when the filter matches nothing. |
| `loading_text` | String | `"Searching..."` | no | Shown while a remote request is in flight. |
| `hint_text` | String | `"Type at least %{count} characters to search"` | no | Shown until the query reaches `min_search_length`. |
| `search_endpoint` | String or nil | `nil` | no | URL for `GET` JSON options. Sanitized. Unsafe URLs raise. |
| `search_param` | String | `"q"` | no | Query string parameter name for the typed text. |
| `min_search_length` | Integer | `2` | no | Characters required before a remote request. Minimum `1`. |
| `debounce` | Integer | `300` | no | Milliseconds to wait after typing before fetch or loader. |
| `loader` | Boolean | `false` | no | Listen for `flat-pack:combobox:load` and supply options in JS. |
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

`GET search_endpoint?search_param=query` with `Accept: application/json`. Canonical body:

```json
{
  "options": [
    { "value": "place_abc", "label": "Federation Square", "subtitle": "Melbourne VIC 3000" }
  ]
}
```

- `subtitle` is optional. The field still submits `value`.
- `results` or `items` may replace `options`.
- `id` may replace `value`. `name` may replace `label`.
- A top-level array of those objects is also accepted.
- Failed or empty responses show the empty row.

### Loader hook

```erb
<%= render FlatPack::Combobox::Component.new(
  name: "place_id",
  label: "Place",
  loader: true,
  min_search_length: 3
) %>
```

```javascript
element.addEventListener("flat-pack:combobox:load", (event) => {
  event.preventDefault()
  event.detail.options = searchPlaces(event.detail.query)
})
```

`event.detail.options` may be an array or a Promise of the JSON contract. If the event is not cancelled and `search_endpoint` is set, Combobox fetches that URL.

A choice dispatches `change` on the hidden field and `flat-pack:combobox:selected` on the root with `{ value, label, subtitle }`. Listen there to fill extra host fields.

## Accessibility
- The visible field is `role="combobox"` with `aria-controls` pointing at a `role="listbox"`.
- Arrow keys move `aria-activedescendant`. Enter chooses. Escape closes.
- Typing filters labels. A value that no longer matches the typed text is cleared until a row is chosen.
- Remote search sets `aria-busy` on the field while a request is in flight.
- Open/close uses `--duration-base` with `--easing-enter` / `--easing-exit`, a few pixels of offset, and origin from the field. A close in flight can reverse. Under `prefers-reduced-motion`, the list fades without the offset.

## Dependencies
- Stimulus controller: `flat-pack--combobox`.
- Overlay motion: `playOverlayEnter` / `playOverlayExit` from `controllers/flat_pack/reduced_motion`.
- Surface tokens for the field and list (`--surface-*`, `--list-item-*`, `--form-control-padding-x`, `--form-control-padding-y`, `--combobox-menu-padding`, `--combobox-item-padding-x`, `--combobox-item-padding-y`).
