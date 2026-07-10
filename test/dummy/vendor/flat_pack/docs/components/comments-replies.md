# Comments Replies

## Purpose
Render indented nested reply content for a parent comment.

## When to use
Use Comments Replies when comment hierarchies need visual nesting and optional collapsed placeholders.

## Class
- Primary: `FlatPack::Comments::Replies::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `depth` | Integer | `1` | no | Nesting depth hint used for indentation styling. |
| `collapsed` | Boolean | `false` | no | Renders collapsed toggle row instead of reply content. |
| `collapsed_label` | String | `"Show replies"` | no | Label text for collapsed toggle button. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for replies wrapper. |

## Slots
- `comment`: reply items/content rendered when not collapsed.

## Variants
- Expanded list mode (`collapsed: false`).
- Collapsed toggle mode (`collapsed: true`).

## Example
```erb
<%= render FlatPack::Comments::Replies::Component.new(depth: 1) do |replies| %>
  <% replies.comment do %>
    <%= render FlatPack::Comments::Item::Component.new(author_name: "Sam", body: "Agree with this") %>
  <% end %>
<% end %>
```

## Accessibility
- Collapsed mode uses a native `<button>` for expand affordance.
- Keep collapsed labels descriptive when showing reply counts.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
