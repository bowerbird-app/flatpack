# Comments Replies Component

A container for nested comment replies with indentation, left border, and collapsible state.

## Basic Usage

```erb
<%= render FlatPack::Comments::Replies::Component.new do |replies| %>
  <% replies.with_comment do %>
    <%= render FlatPack::Comments::Item::Component.new(
      author_name: "Reply Author",
      body: "This is a reply"
    ) %>
  <% end %>
<% end %>
```

## Multiple Replies

```erb
<%= render FlatPack::Comments::Replies::Component.new do |replies| %>
  <% @replies.each do |reply| %>
    <% replies.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(
        author_name: reply.author.name,
        body: reply.body,
        timestamp: time_ago_in_words(reply.created_at)
      ) %>
    <% end %>
  <% end %>
<% end %>
```

## Collapsed State

Show a button to expand replies:

```erb
<%= render FlatPack::Comments::Replies::Component.new(
  collapsed: true,
  collapsed_label: "Show 3 replies"
) %>
```

You'll typically toggle this with JavaScript:

```erb
<%= render FlatPack::Comments::Replies::Component.new(
  collapsed: @show_replies ? false : true,
  collapsed_label: "Show #{@reply_count} replies"
) do |replies| %>
  <% @replies.each do |reply| %>
    <% replies.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(...) %>
    <% end %>
  <% end %>
<% end %>
```

## Nested Depth

Control indentation depth for multi-level threading:

```erb
<%= render FlatPack::Comments::Replies::Component.new(depth: 1) do |replies| %>
  <% replies.with_comment do %>
    <%= render FlatPack::Comments::Item::Component.new(
      author_name: "Level 1 Reply",
      body: "First level"
    ) do |item| %>
      <% item.with_replies do %>
        <%= render FlatPack::Comments::Replies::Component.new(depth: 2) do |nested| %>
          <% nested.with_comment do %>
            <%= render FlatPack::Comments::Item::Component.new(
              author_name: "Level 2 Reply",
              body: "Second level"
            ) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `depth` | Integer | `1` | Nesting depth (affects indentation) |
| `collapsed` | Boolean | `false` | Show collapsed state with expand button |
| `collapsed_label` | String | `"Show replies"` | Label for expand button |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes |

## Slots

| Slot | Type | Description |
|------|------|-------------|
| `comment` | Multiple | Reply comment items |

## Examples

### Simple Reply Thread
```erb
<%= render FlatPack::Comments::Item::Component.new(
  author_name: "Alice",
  body: "Original comment"
) do |item| %>
  <% item.with_replies do %>
    <%= render FlatPack::Comments::Replies::Component.new do |replies| %>
      <% replies.with_comment do %>
        <%= render FlatPack::Comments::Item::Component.new(
          author_name: "Bob",
          body: "Great point!"
        ) %>
      <% end %>
      <% replies.with_comment do %>
        <%= render FlatPack::Comments::Item::Component.new(
          author_name: "Charlie",
          body: "I agree"
        ) %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### Collapsible Replies with Count
```erb
<div data-controller="replies">
  <%= render FlatPack::Comments::Item::Component.new(
    author_name: "User",
    body: "Main comment"
  ) do |item| %>
    <% item.with_actions do %>
      <%= button_tag "Reply (#{@reply_count})", 
          data: {action: "click->replies#toggle"}, 
          class: "text-sm text-primary" %>
    <% end %>
    
    <% item.with_replies do %>
      <div data-replies-target="container" class="hidden">
        <%= render FlatPack::Comments::Replies::Component.new do |replies| %>
          <% @comment.replies.each do |reply| %>
            <% replies.with_comment do %>
              <%= render FlatPack::Comments::Item::Component.new(
                author_name: reply.author.name,
                body: reply.body
              ) %>
            <% end %>
          <% end %>
        <% end %>
      </div>
    <% end %>
  <% end %>
</div>
```

### Deeply Nested Conversation
```erb
<%= render FlatPack::Comments::Thread::Component.new(count: @comments.count) do |thread| %>
  <% @comments.each do |comment| %>
    <% thread.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(
        author_name: comment.author.name,
        body: comment.body
      ) do |item| %>
        <% if comment.replies.any? %>
          <% item.with_replies do %>
            <%= render FlatPack::Comments::Replies::Component.new(depth: 1) do |replies_1| %>
              <% comment.replies.each do |reply_1| %>
                <% replies_1.with_comment do %>
                  <%= render FlatPack::Comments::Item::Component.new(
                    author_name: reply_1.author.name,
                    body: reply_1.body
                  ) do |reply_item| %>
                    <% if reply_1.replies.any? %>
                      <% reply_item.with_replies do %>
                        <%= render FlatPack::Comments::Replies::Component.new(depth: 2) do |replies_2| %>
                          <% reply_1.replies.each do |reply_2| %>
                            <% replies_2.with_comment do %>
                              <%= render FlatPack::Comments::Item::Component.new(
                                author_name: reply_2.author.name,
                                body: reply_2.body
                              ) %>
                            <% end %>
                          <% end %>
                        <% end %>
                      <% end %>
                    <% end %>
                  <% end %>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

### With Reply Composer
```erb
<%= render FlatPack::Comments::Replies::Component.new do |replies| %>
  <% @replies.each do |reply| %>
    <% replies.with_comment do %>
      <%= render FlatPack::Comments::Item::Component.new(
        author_name: reply.author.name,
        body: reply.body
      ) %>
    <% end %>
  <% end %>
  
  <% replies.with_comment do %>
    <div class="pt-2">
      <%= render FlatPack::Comments::Composer::Component.new(
        placeholder: "Write a reply...",
        compact: true,
        rows: 2
      ) %>
    </div>
  <% end %>
<% end %>
```

## Styling Notes

- Replies are indented with left margin (`ml-11`)
- A left border (`border-l-2`) visually connects replies to parent
- Hover effects scale avatars for better visibility in dense threads
- Depth parameter allows for consistent indentation across nesting levels
