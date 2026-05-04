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
- `comment`: appends a comment entry.
- `footer`: optional footer controls/content.

## Variants
- Spacing variants: `:default`, `:compact`.
- Interaction mode: unlocked or locked (`locked: true`).

## Example
```erb
<%= render FlatPack::Comments::Thread::Component.new(count: @comments.count, title: "Discussion") do |thread| %>
  <% thread.composer do %>
    <%= render FlatPack::Comments::Composer::Component.new(avatar: {name: "You"}) %>
  <% end %>

  <% @comments.each do |comment| %>
    <% thread.comment do %>
      <%= render FlatPack::Comments::Item::Component.new(
        author_name: comment.author_name,
        body: comment.body,
        avatar: {
          name: comment.author_name,
          src: comment.avatar_url,
          alt: "#{comment.author_name} avatar"
        }
      ) %>
    <% end %>
  <% end %>
<% end %>
```

## Interactive Demo
https://redesigned-doodle-7vv56g46g9fp6qr-3000.app.github.dev/demo/comments?reply_to=1#interactive-thread

```erb
<%# test/dummy/app/views/pages/comments.html.erb %>
<%= render FlatPack::Comments::Thread::Component.new(
  count: @comments_count,
  title: "Discussion"
) do |thread| %>
  <% if @comments_table_available %>
    <% thread.composer do %>
        <%= render "pages/demo_comment_form" %>
    <% end %>
  <% end %>

  <% @root_comments.each do |comment| %>
    <% thread.comment do %>
      <%= render "pages/demo_comment_item",
        comment: comment,
        depth: 1,
        comments_by_parent_id: @comments_by_parent_id,
        reply_target_id: @reply_target_id,
        allow_reply: @comments_table_available %>
    <% end %>
  <% end %>
<% end %>

<%# test/dummy/app/views/pages/_demo_comment_item.html.erb %>
<% replies = comments_by_parent_id[comment.id] || [] %>

<%= render FlatPack::Comments::Item::Component.new(
  author_name: comment.author_name,
  author_meta: comment.author_meta,
  timestamp: "#{time_ago_in_words(comment.created_at)} ago",
  timestamp_iso: comment.created_at.iso8601,
  body: comment.body,
  edited: comment.edited?,
  state: comment.state.to_sym,
  avatar: {
    name: comment.author_name,
    src: "https://i.pravatar.cc/160?u=#{ERB::Util.url_encode(comment.author_name)}",
    alt: "#{comment.author_name} avatar"
  },
  id: "comment-#{comment.id}"
) do |item| %>
  <% if allow_reply %>
    <% item.actions do %>
      <%= link_to "Reply", demo_comments_path(reply_to: comment.id, anchor: "comment-#{comment.id}"), class: "text-sm font-medium text-[var(--color-primary)] hover:underline" %>
    <% end %>
  <% end %>

  <% if replies.any? || reply_target_id == comment.id %>
    <% item.replies do %>
      <%= render FlatPack::Comments::Replies::Component.new(depth: depth) do |thread_replies| %>
        <% replies.each do |reply| %>
          <% thread_replies.comment do %>
            <%= render "pages/demo_comment_item",
              comment: reply,
              depth: depth + 1,
              comments_by_parent_id: comments_by_parent_id,
              reply_target_id: reply_target_id,
              allow_reply: allow_reply %>
          <% end %>
        <% end %>

        <% if reply_target_id == comment.id && allow_reply %>
          <% thread_replies.comment do %>
            <%= form_with url: replies_demo_comment_path(comment), method: :post, local: true do %>
              <%= render FlatPack::Comments::Composer::Component.new(
                name: "comment[body]",
                placeholder: "Write a reply...",
                submit_label: "Reply",
                compact: true,
                rows: 2
              ) do |composer| %>
                <% composer.actions do %>
                  <div class="flex items-center justify-end w-full gap-2">
                    <%= render FlatPack::Button::Component.new(
                      text: "Cancel",
                      url: demo_comments_path(anchor: "comment-#{comment.id}"),
                      style: :ghost,
                      size: :sm
                    ) %>
                    <%= render FlatPack::Button::Component.new(
                      text: "Reply",
                      type: "submit",
                      style: :primary,
                      size: :sm
                    ) %>
                  </div>
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

## Accessibility
- Default locked indicator is visual + textual (`"Locked"`).
- Ensure controls inserted via slots have clear labels.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
