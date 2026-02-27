# Popover

## Purpose
Render positioned popover content associated with an external trigger element.

## When to use
Use Popover for contextual content such as menus, hints, and quick actions anchored to an existing trigger.

## Class
- Primary: `FlatPack::Popover::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `trigger_id` | String | `nil` | yes | DOM id of the trigger element that controls/anchors the popover. |
| `placement` | Symbol | `:bottom` | no | Positioning hint: `:top`, `:bottom`, `:left`, `:right`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for popover wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `content` (`with_content` / `with_popover_content`) | slot | yes | Popover body content. |

## Variants
- Placement variants: `:top`, `:bottom`, `:left`, `:right`.

## Example
```erb
<button id="account-trigger" type="button">Account</button>

<%= render FlatPack::Popover::Component.new(trigger_id: "account-trigger", placement: :bottom) do |popover| %>
  <% popover.with_content do %>
    <div class="space-y-2">
      <%= render FlatPack::Link::Component.new(href: "/profile") { "Profile" } %>
      <%= render FlatPack::Link::Component.new(href: "/settings") { "Settings" } %>
    </div>
  <% end %>
<% end %>
```

## Accessibility
- Popover content wrapper is initialized hidden (`aria-hidden="true"`).
- Ensure trigger is keyboard-focusable and has accessible labeling.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--popover`.
