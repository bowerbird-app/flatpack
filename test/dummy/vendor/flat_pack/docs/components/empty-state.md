# Empty State

## Purpose
Invite the person to do the next useful thing when a list, search, or panel has nothing in it yet.

## When to use
Use Empty State when a surface is blank and the person can act: create the first item, clear filters, connect a source. Lead with that action. Do not use a large illustration as the empty state.

## Class
- Primary: `FlatPack::EmptyState::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Heading that names what is missing. |
| `description` | String | `nil` | no | One sentence on what to do next. |
| `icon` | Symbol/String/false | `nil` | no | Optional quiet kit icon (`:inbox`, `:search`, or any `IconComponent` name). Pass `false` or omit to skip. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `slot` | slot | no | The action row (primary button, optional secondary). Prefer this over a picture. |
| `graphic` | slot | no | Replaces the optional icon. Keep it small; the button still leads. |

## Variants
None.

## Example
```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "No projects yet",
  description: "Create a project to group work in one place."
) do |state| %>
  <% state.slot do %>
    <%= render FlatPack::Button::Component.new(text: "Create project", style: :primary) %>
  <% end %>
<% end %>
```

## Empty then content
The root is `.fp-empty-state`. It fades and rises a few pixels on `--duration-slow` / `--easing-enter` (`@starting-style`). When the first item arrives, hide the empty panel and show content with `.fp-content-enter` so the swap uses the same motion. Reduced motion snaps with no transform.

Dummy `/demo/empty_state` has a Show empty / Show content toggle.

## Accessibility
- Title and description are semantic text.
- Put the next step on a real button in `slot`, not only in the description.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `FlatPack::Shared::IconComponent` when `icon` is set.
- Kit CSS: `.fp-empty-state`, `.fp-content-enter`.
