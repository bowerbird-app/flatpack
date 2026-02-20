# Comments Thread Component

A container component for managing comment threads with header, composer, comments list, and footer sections.

## Basic Usage

```erb
<%= render FlatPack::Comments::Thread::Component.new(
  count: 24,
  title: "Discussion"
) do |thread| %>
  <% thread.with_comment do %>
    <%= render FlatPack::Comments::Item::Component.new(...) %>
  <% end %>
<% end %>
```

## With Composer

Add a composer for creating new comments:

```erb
<%= render FlatPack::Comments::Thread::Component.new(count: 5) do |thread| %>
  <% thread.with_composer do %>
    <%= render FlatPack::Comments::Composer::Component.new %>
  <% end %>
  
  <% @comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(...) %>
    <% end %>
  <% end %>
<% end %>
```

## Empty State

Customize the empty state message:

```erb
<%= render FlatPack::Comments::Thread::Component.new(
  empty_title: "No feedback yet",
  empty_body: "Share your thoughts to start the conversation."
) %>
```

## Locked State

Prevent new comments with a locked indicator:

```erb
<%= render FlatPack::Comments::Thread::Component.new(
  count: 12,
  locked: true
) do |thread| %>
  <% @comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(...) %>
    <% end %>
  <% end %>
<% end %>
```

## Custom Header

Replace the default header with custom content:

```erb
<%= render FlatPack::Comments::Thread::Component.new do |thread| %>
  <% thread.with_header do %>
    <div class="flex justify-between items-center">
      <h2>Custom Header</h2>
      <button>Sort</button>
    </div>
  <% end %>
  
  <% thread.with_comment do %>
    ...
  <% end %>
<% end %>
```

## Variants

Control spacing between comments:

```erb
<!-- Default spacing -->
<%= render FlatPack::Comments::Thread::Component.new(variant: :default) %>

<!-- Compact spacing -->
<%= render FlatPack::Comments::Thread::Component.new(variant: :compact) %>
```

## With Footer

Add pagination or load more actions:

```erb
<%= render FlatPack::Comments::Thread::Component.new(count: 50) do |thread| %>
  <% @comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(...) %>
    <% end %>
  <% end %>
  
  <% thread.with_footer do %>
    <%= link_to "Load more comments", "#", class: "text-primary" %>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `count` | Integer | `0` | Number of comments |
| `title` | String | `"Comments"` | Header title |
| `variant` | Symbol | `:default` | Spacing variant (`:default`, `:compact`) |
| `empty_title` | String | `"No comments yet"` | Empty state title |
| `empty_body` | String | `"Be the first..."` | Empty state body |
| `locked` | Boolean | `false` | Show locked indicator, hide composer |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes |

## Slots

| Slot | Type | Description |
|------|------|-------------|
| `header` | Single | Custom header content |
| `composer` | Single | Comment composer (hidden when locked) |
| `comment` | Multiple | Comment items |
| `footer` | Single | Footer content (pagination, etc.) |

## Examples

### Full Comment Thread
```erb
<%= render FlatPack::Comments::Thread::Component.new(
  count: @post.comments.count,
  title: "Comments"
) do |thread| %>
  <% thread.with_composer do %>
    <%= form_with model: [@post, Comment.new] do |f| %>
      <%= render FlatPack::Comments::Composer::Component.new(
        name: "comment[body]"
      ) %>
    <% end %>
  <% end %>
  
  <% @post.comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(
        author_name: comment.author.name,
        timestamp: time_ago_in_words(comment.created_at),
        body: comment.body
      ) %>
    <% end %>
  <% end %>
<% end %>
```

### Read-Only Thread
```erb
<%= render FlatPack::Comments::Thread::Component.new(
  count: @archived_comments.count,
  title: "Archived Discussion",
  locked: true,
  variant: :compact
) do |thread| %>
  <% @archived_comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(...) %>
    <% end %>
  <% end %>
<% end %>
```
