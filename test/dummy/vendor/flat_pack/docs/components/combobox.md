# Combobox

## Purpose
Let someone type to filter a list, then pick one value for a form field.

## When to use
Use Combobox when the list is long enough to search. Use Select for a short native-style dropdown. Combobox always submits a single hidden value.

## Class
- Primary: `FlatPack::Combobox::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String | none | yes | Name of the hidden submitted field. |
| `options` | Array | none | yes | Strings, or hashes with `value:` and `label:`. |
| `value` | String or nil | `nil` | no | Selected option value. |
| `label` | String or nil | `nil` | no | Visible field label. |
| `placeholder` | String | `"Search"` | no | Empty input hint. |
| `disabled` | Boolean | `false` | no | Disables the input and hidden field. |
| `required` | Boolean | `false` | no | Marks the hidden field required. |
| `empty_text` | String | `"No matches"` | no | Shown when the filter matches nothing. |
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

## Accessibility
- The visible field is `role="combobox"` with `aria-controls` pointing at a `role="listbox"`.
- Arrow keys move `aria-activedescendant`. Enter chooses. Escape closes.
- Typing filters labels. A value that no longer matches the typed text is cleared until a row is chosen.
- Open/close uses `--duration-base` with `--easing-enter` / `--easing-exit`, a few pixels of offset, and origin from the field. A close in flight can reverse. Under `prefers-reduced-motion`, the list fades without the offset.

## Dependencies
- Stimulus controller: `flat-pack--combobox`.
- Overlay motion: `playOverlayEnter` / `playOverlayExit` from `controllers/flat_pack/reduced_motion`.
- Surface tokens for the field and list (`--surface-*`, `--list-item-*`, `--form-control-padding`).
