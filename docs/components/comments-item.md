# Comments Item Component

Display an individual comment with avatar, author info, timestamp, body, and optional actions.

## Basic Usage

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "John Doe",
  body: "This is a great post!"
) %>
```

## With Full Details

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "John Doe",
  author_meta: "Software Engineer",
  timestamp: "2 hours ago",
  timestamp_iso: "2024-01-15T14:30:00Z",
  body: "This is a great post!",
  avatar: {
    src: "https://example.com/john.jpg",
    href: "/users/john"
  }
) %>
```

## With HTML Body

Use `body_html` for rich content (Markdown, etc.):

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Jane Smith",
  body_html: markdown_to_html(comment.body)
) %>
```

## With Actions

Add reply, like, edit buttons:

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Bob Johnson",
  body: "Great idea!"
) do |item| %>
  <% item.with_actions do %>
    <%= link_to "Reply", "#", class: "text-sm text-primary" %>
    <%= link_to "Like", "#", class: "text-sm text-muted-foreground" %>
    <%= link_to "Edit", "#", class: "text-sm text-muted-foreground" %>
  <% end %>
<% end %>
```

## States

### Default State
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "User",
  body: "Regular comment",
  state: :default
) %>
```

### System State
For automated messages:

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "System",
  body: "This issue was automatically closed.",
  state: :system
) %>
```

### Deleted State
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Former User",
  state: :deleted
) %>
<!-- Displays: "This comment has been deleted." -->
```

## With Footer

Add reactions or metadata:

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Alice",
  body: "Interesting point!"
) do |item| %>
  <% item.with_footer do %>
    <div class="flex gap-3 text-xs text-muted-foreground">
      <span>👍 12</span>
      <span>❤️ 5</span>
    </div>
  <% end %>
<% end %>
```

## With Replies

Nest replies within a comment:

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Parent",
  body: "Original comment"
) do |item| %>
  <% item.with_replies do %>
    <%= render FlatPack::Comments::Replies::Component.new do |replies| %>
      <% replies.with_comment do %>
        <%= render FlatPack::Comments::Item::Component.new(
          author_name: "Child",
          body: "Reply to comment"
        ) %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Edited Indicator

Show when a comment has been edited:

```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "User",
  timestamp: "3 hours ago",
  body: "Updated content",
  edited: true
) %>
<!-- Timestamp shows: "3 hours ago (edited)" -->
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `author_name` | String | required | Comment author name |
| `author_meta` | String | `nil` | Additional author info (title, role, etc.) |
| `timestamp` | String | `nil` | Human-readable timestamp |
| `timestamp_iso` | String | `nil` | ISO 8601 datetime for semantic markup |
| `body` | String | `nil` | Plain text comment body |
| `body_html` | String | `nil` | HTML comment body (rendered as safe HTML) |
| `edited` | Boolean | `false` | Show edited indicator |
| `state` | Symbol | `:default` | Visual state (`:default`, `:system`, `:deleted`) |
| `avatar` | Hash | `{}` | Avatar properties (src, name, href, etc.) |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes |

## Slots

| Slot | Type | Description |
|------|------|-------------|
| `actions` | Single | Action buttons (reply, like, edit) |
| `footer` | Single | Footer content (reactions, metadata) |
| `replies` | Single | Nested replies thread |

## Examples

### GitHub-Style Comment
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: current_user.name,
  author_meta: "Contributor",
  timestamp: time_ago_in_words(comment.created_at),
  timestamp_iso: comment.created_at.iso8601,
  body_html: markdown(comment.body),
  edited: comment.updated_at > comment.created_at,
  avatar: {
    src: current_user.avatar_url,
    href: user_path(current_user)
  }
) do |item| %>
  <% item.with_actions do %>
    <%= link_to "Reply", "#", class: "text-sm" %>
  <% end %>
<% end %>
```

### System Notification
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "GitHub",
  body: "merged commit abc123 into main",
  state: :system,
  timestamp: "1 day ago"
) %>
```

### Threaded Conversation
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Alice",
  body: "What do you think?"
) do |item| %>
  <% item.with_actions do %>
    <%= button_to "Reply", "#", class: "text-sm" %>
  <% end %>
  
  <% item.with_replies do %>
    <%= render FlatPack::Comments::Replies::Component.new do |replies| %>
      <% replies.with_comment do %>
        <%= render FlatPack::Comments::Item::Component.new(
          author_name: "Bob",
          body: "I agree!"
        ) %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```
