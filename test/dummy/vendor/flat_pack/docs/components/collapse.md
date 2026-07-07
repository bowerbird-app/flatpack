# Collapse

## Purpose
Show and hide a content region with a toggle button and animated expansion.

## When to use
Use Collapse for disclosure sections, FAQs, advanced options, and progressive detail blocks.

## Class
- Primary: `FlatPack::Collapse::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `id` | String | `nil` | yes | Base identifier for ARIA wiring; content region ID becomes `"#{id}-content"`. |
| `title` | String | `nil` | yes | Trigger button label text. |
| `left_slot` | String | `nil` | no | Optional renderable content shown to the left of the trigger title (for example an icon component render). |
| `open` | Boolean | `false` | no | Initial expanded state; sets hidden state and controller value. |
| `border` | Boolean | `true` | no | Controls border and horizontal padding. When `false`, border styles are removed and trigger/content horizontal padding is skipped. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for outer collapse container. |

## Slots
- Default block content is rendered inside the collapsible content panel.

## Variants
- State variant: closed (`open: false`) and open (`open: true`).

## Example
```erb
<%= render FlatPack::Collapse::Component.new(id: "advanced", title: "Advanced Settings", open: false) do %>
  <p class="text-sm">Optional details go here.</p>
<% end %>

<%= render FlatPack::Collapse::Component.new(
  id: "security",
  title: "Security",
  left_slot: render(FlatPack::Shared::IconComponent.new(name: "lock-closed", size: :sm))
) do %>
  <p class="text-sm">Use left trigger content for iconography and status markers.</p>
<% end %>

<%= render FlatPack::Collapse::Component.new(id: "flush", title: "Borderless", border: false) do %>
  <p class="text-sm">This variant has no outer border and no horizontal padding.</p>
<% end %>
```

## Accessibility
- Trigger button uses `aria-expanded` and `aria-controls` tied to content ID.
- Hidden state is reflected via `hidden` attribute on content container.
- Uses a native `<button>` trigger for keyboard activation.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Requires Stimulus controller `flat-pack--collapse`.
