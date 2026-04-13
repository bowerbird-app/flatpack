# Chip

## Purpose
Render compact labels that can be static, interactive, link-based, or removable.

## When to use
Use Chip for tags, filters, selected states, and quick token-like actions.

## Class
- Primary: `FlatPack::Chip::Component`
- Related classes: `FlatPack::ChipGroup::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | no | Chip label; if omitted, block content is used. |
| `style` | Symbol | `:default` | no | Style: `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`; invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Size: `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | Selected state; applies visual ring for `type: :button`. |
| `disabled` | Boolean | `false` | no | Disabled state; disables button chips and renders disabled link chips as `<span>`. |
| `removable` | Boolean | `false` | no | Adds remove control and `flat-pack--chip` controller when not disabled. Without `remove_url`, removal stays client-side only. |
| `href` | String | `nil` | no | Link URL used when `type: :link` and not disabled. |
| `type` | Symbol | `:static` | no | Root type: `:static`, `:button`, `:link`; invalid values raise `ArgumentError`. |
| `value` | String | `nil` | no | Value passed through removable-chip data payload/events. |
| `name` | String | `nil` | no | Reserved name metadata for future form integration. |
| `remove_url` | String | `nil` | no | Optional URL requested before a removable chip is removed. Supports safe relative URLs and `http`/`https`. |
| `remove_method` | Symbol | `:post` | no | HTTP verb used with `remove_url`. Supported values: `:get`, `:post`. Ignored when `remove_url` is omitted. |
| `remove_params` | Hash | `nil` | no | Params sent with the optional removal request. GET requests append query params; POST requests send JSON. Ignored when `remove_url` is omitted. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for chip root element. |

## Slots
- `leading`: sets content shown before label.
- `trailing`: content shown after label.
- `remove_button`: custom remove control (overrides default removable button).

## Variants
- Styles: `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`.
- Sizes: `:sm`, `:md`, `:lg`.
- Types: `:static`, `:button`, `:link`.

## Example
```erb
<%= render FlatPack::Chip::Component.new(
  text: "Active",
  type: :button,
  style: :primary,
  selected: true,
  value: "active"
) %>
```

```erb
<%= render FlatPack::Chip::Component.new(
  text: "Ruby",
  removable: true,
  value: "ruby",
  remove_url: tags_path,
  remove_method: :get,
  remove_params: { tag: "ruby", source: "chips_demo" }
) %>
```

## Accessibility
- Button chips expose `aria-pressed` for selected state.
- Disabled chips use disabled semantics for buttons and non-interactive rendering for links.
- Default remove control includes `aria-label="Remove"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Removable chips attach Stimulus controller `flat-pack--chip`.
- Optional request-backed tag input uses Stimulus controller `flat-pack--chip-tag-input`.

## Notes
- When `removable: true` is set without `remove_url`, the chip uses the default client-side removal animation and emits `chip:removed` immediately.
- When `remove_url` is present, the chip waits for the GET or POST request to succeed before it runs the existing removal animation and emits `chip:removed`.
- Failed removal requests keep the chip in place and emit `chip:remove-failed` with the request error message in `event.detail.error`.
- Adding chips from a tag-input flow is not configured on `FlatPack::Chip::Component` itself. Use `flat-pack--chip-tag-input` on the wrapper that owns the input, chip group, and template.
- Auto-submit for added chips is optional and defaults to off. Without configuration, the tag-input controller inserts chips locally with no request.
- To turn auto-submit on, set `data-flat-pack--chip-tag-input-auto-submit-value="true"` and provide `data-flat-pack--chip-tag-input-add-url-value`. Optional `add_method` and `add_params` values mirror the remove callback pattern.
- The tag-input controller emits `chip:added` after a local insert or a successful add callback, and emits `chip:add-failed` when the optional add callback returns a failure.

## Tag Input Integration
```erb
<div data-controller="flat-pack--chip-tag-input">
  <%= render FlatPack::TextInput::Component.new(
    name: "project_tags",
    label: "Project Tags",
    data: {
      flat_pack__chip_tag_input_target: "input",
      action: "keydown->flat-pack--chip-tag-input#handleKeydown"
    }
  ) %>

  <%= render FlatPack::ChipGroup::Component.new(data: { flat_pack__chip_tag_input_target: "chips" }) do %>
    <%= render FlatPack::Chip::Component.new(text: "Frontend", removable: true, value: "frontend") %>
  <% end %>

  <template data-flat-pack--chip-tag-input-target="template">
    <%= render FlatPack::Chip::Component.new(text: "__TAG_TEXT__", removable: true, value: "__TAG_VALUE__") %>
  </template>
</div>
```

```erb
<div
  data-controller="flat-pack--chip-tag-input"
  data-flat-pack--chip-tag-input-auto-submit-value="true"
  data-flat-pack--chip-tag-input-add-url-value="/tags"
  data-flat-pack--chip-tag-input-add-method-value="post"
  data-flat-pack--chip-tag-input-add-params-value='<%= { source: "chips_demo" }.to_json %>'>
  ...
</div>
```
