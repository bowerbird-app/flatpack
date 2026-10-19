# Fieldset

## Purpose
Name a cluster of related form controls so the group has one accessible title.

## When to use
Use Fieldset when several controls belong together, such as an address, a set of preferences, or a billing block. Use a field `label` for one control. Use `SectionTitle` for a document heading, not for a group of fields.

## Class
- Primary: `FlatPack::Fieldset::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | none | yes | Group name, rendered as the `<legend>`. Blank titles raise `ArgumentError`. |
| `description` | String | `nil` | no | Plain-text hint under the legend. Only plain `String` values are accepted; HTML-like content is escaped as text. |
| `disabled` | Boolean | `false` | no | Sets `disabled` on the fieldset, which disables every control inside it. |
| `error` | String | `nil` | no | Plain-text group message under the fields. Sets `aria-invalid` and links the message with `aria-describedby`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the fieldset (`id`, `class`, `data`, `aria`). |

## Slots
| name | type | description |
|---|---|---|
| default | Block | The fields that belong to the group. |

## Variants
None.

## Example
```erb
<%= render FlatPack::Fieldset::Component.new(
  title: "Shipping address",
  description: "Where should we send this order?"
) do %>
  <%= render FlatPack::TextInput::Component.new(name: "line1", label: "Street") %>
  <%= render FlatPack::TextInput::Component.new(name: "city", label: "City") %>
<% end %>
```

## Accessibility
- The title is a `<legend>` and the first element inside the `<fieldset>`, so the group name is announced with the controls.
- `description` and `error` are linked from the fieldset with `aria-describedby`.
- `error` sets `aria-invalid="true"` on the fieldset.
- `disabled: true` uses the native fieldset `disabled` attribute.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- No Stimulus controller.
