# Tooltip

## Purpose
Render contextual tooltip content for a trigger element with placement controls.

## When to use
Use Tooltip for brief explanatory text tied to controls or compact UI affordances.

## Class
- Primary: `FlatPack::Tooltip::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | conditional | Tooltip copy when slot content is not provided. |
| `placement` | Symbol | `:top` | no | Positioning hint: `:top`, `:bottom`, `:left`, `:right`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for trigger wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `tooltip_content` (`with_tooltip_content`) | slot | no | Custom tooltip body content; overrides `text`. |

## Variants
- Placement variants: `:top`, `:bottom`, `:left`, `:right`.

## Example
```erb
<%= render FlatPack::Tooltip::Component.new(text: "Copy", placement: :top) do %>
  <button type="button" aria-label="Copy to clipboard">Copy</button>
<% end %>
```

## Accessibility
- Tooltip body uses `role="tooltip"`.
- Show/hide is driven by hover and focus events from the trigger wrapper.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--tooltip`.
