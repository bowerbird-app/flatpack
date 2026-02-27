# Modal

## Purpose
Display layered dialog content with managed focus/keyboard/backdrop behavior.

## When to use
Use Modal for confirmation flows, forms, and detailed contextual content that should temporarily block page interaction.

## Class
- Primary: `FlatPack::Modal::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `id` | String | `nil` | yes | DOM id for the modal root; also used to derive the title id. |
| `title` | String | `nil` | no | Header title when `header` slot is not provided. |
| `size` | Symbol | `:md` | no | Dialog width: `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`. |
| `body_height_mode` | Symbol | `:auto` | no | Body sizing mode: `:auto`, `:fixed`, `:min`. |
| `body_height` | String | `nil` | conditional | Required when `body_height_mode` is `:fixed` or `:min`; validated for safe CSS-length/expression characters. |
| `close_on_backdrop` | Boolean | `true` | no | Allow closing when clicking backdrop. |
| `close_on_escape` | Boolean | `true` | no | Allow closing on Escape key. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into modal root element. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `header` | slot | no | Custom header content (replaces title text area). |
| `body` | slot | no | Main scrollable dialog body. |
| `footer` | slot | no | Footer action row. |

## Variants
- Size variants via `size`.
- Body sizing variants via `body_height_mode` (`:auto`, `:fixed`, `:min`).

## Example
```erb
<%= render FlatPack::Modal::Component.new(id: "invite-modal", title: "Invite member", size: :lg) do |modal| %>
  <% modal.with_body do %>
    <p class="text-sm">Send access to a new collaborator.</p>
  <% end %>

  <% modal.with_footer do %>
    <%= render FlatPack::Button::Component.new(text: "Cancel", style: :secondary) %>
    <%= render FlatPack::Button::Component.new(text: "Send invite") %>
  <% end %>
<% end %>
```

## Accessibility
- Renders `role="dialog"`, `aria-modal="true"`, and `aria-labelledby` bound to the header id.
- Escape/backdrop close controls are configurable.
- Ensure trigger and focus-management behavior are implemented in the modal controller usage flow.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--modal`.
