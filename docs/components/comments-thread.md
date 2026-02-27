# Comments Thread

## Purpose
Compose full comment experiences with header, composer, comment list, and footer regions.

## When to use
Use Comments Thread as the root wrapper for page-level comment sections.

## Class
- Primary: `FlatPack::Comments::Thread::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `count` | Integer | `0` | no | Comment count shown in default header. |
| `title` | String | `"Comments"` | no | Default header title text. |
| `variant` | Symbol | `:default` | no | Spacing variant: `:default`, `:compact`; invalid values raise `ArgumentError`. |
| `empty_title` | String | `"No comments yet"` | no | Empty-state title when no comments are rendered. |
| `empty_body` | String | `"Be the first to share your thoughts."` | no | Empty-state description text. |
| `locked` | Boolean | `false` | no | Hides composer and shows locked indicator in default header. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for thread wrapper. |

## Slots
- `header`: custom header content (replaces default header).
- `composer`: composer area (suppressed when `locked` is true).
- `comment` (`renders_many`): comment entries.
- `footer`: optional footer controls/content.

## Variants
- Spacing variants: `:default`, `:compact`.
- Interaction mode: unlocked or locked (`locked: true`).

## Example
```erb
<%= render FlatPack::Comments::Thread::Component.new(count: @comments.count, title: "Discussion") do |thread| %>
  <% thread.with_composer do %>
    <%= render FlatPack::Comments::Composer::Component.new %>
  <% end %>

  <% @comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(author_name: comment.author_name, body: comment.body) %>
    <% end %>
  <% end %>
<% end %>
```

## Accessibility
- Default locked indicator is visual + textual (`"Locked"`).
- Ensure controls inserted via slots have clear labels.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
