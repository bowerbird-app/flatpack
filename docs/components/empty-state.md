# Empty State

## Purpose
Show a clear no-data/no-results state with optional icon/graphic and action area.

## When to use
Use Empty State when a list, search, inbox, or dashboard panel has no content yet.

## Class
- Primary: `FlatPack::EmptyState::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Main empty-state heading. |
| `description` | String | `nil` | no | Supporting text shown below title. |
| `icon` | Symbol/String/false | `nil` | no | Built-ins include `:inbox` and `:search`; any other symbol uses shared icon renderer; pass `false` to suppress icon. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `graphic` | slot | no | Replaces built-in icon area with custom graphic content. |
| `actions` | slot | no | Action row (buttons/links). |

## Variants
None.

## Example
```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "No results",
  description: "Try a different filter or keyword.",
  icon: :search
) do |state| %>
  <% state.with_actions do %>
    <%= render FlatPack::Button::Component.new(text: "Clear filters") %>
  <% end %>
<% end %>
```

## Accessibility
- Title and description are rendered as semantic text content.
- Ensure action buttons are keyboard reachable and descriptive.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Shared::IconComponent` when `icon` is provided.
