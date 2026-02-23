# Comments Composer Component

A rich text area component for composing new comments with optional toolbar, attachments, and action buttons.

## Basic Usage

```erb
<%= render FlatPack::Comments::Composer::Component.new %>
```

## With Form Integration

```erb
<%= form_with model: [@post, Comment.new] do |f| %>
  <%= render FlatPack::Comments::Composer::Component.new(
    name: "comment[body]",
    placeholder: "Share your thoughts..."
  ) %>
<% end %>
```

## Custom Labels

```erb
<%= render FlatPack::Comments::Composer::Component.new(
  submit_label: "Post Comment",
  cancel_label: "Discard",
  show_cancel: true
) %>
```

## With Toolbar

Add formatting options or other tools:

```erb
<%= render FlatPack::Comments::Composer::Component.new do |composer| %>
  <% composer.with_toolbar do %>
    <div class="flex gap-2 pt-2">
      <%= button_tag type: "button", class: "text-sm" do %>
        <strong>B</strong>
      <% end %>
      <%= button_tag type: "button", class: "text-sm" do %>
        <em>I</em>
      <% end %>
    </div>
  <% end %>
<% end %>
```

## With Attachments

Show uploaded files or previews:

```erb
<%= render FlatPack::Comments::Composer::Component.new do |composer| %>
  <% composer.with_attachments do %>
    <div class="flex gap-2">
      <span class="text-sm">📎 document.pdf</span>
      <button type="button">Remove</button>
    </div>
  <% end %>
<% end %>
```

## Custom Actions

Replace default buttons with custom actions:

```erb
<%= render FlatPack::Comments::Composer::Component.new do |composer| %>
  <% composer.with_actions do %>
    <div class="flex justify-between items-center w-full">
      <button type="button" class="text-sm">
        📎 Attach file
      </button>
      <div class="flex gap-2">
        <%= link_to "Cancel", "#", class: "text-sm" %>
        <%= button_tag "Submit", type: "submit", class: "btn-primary" %>
      </div>
    </div>
  <% end %>
<% end %>
```

## Compact Mode

Reduce padding for inline usage:

```erb
<%= render FlatPack::Comments::Composer::Component.new(
  compact: true,
  rows: 2
) %>
```

## Disabled State

Prevent interaction:

```erb
<%= render FlatPack::Comments::Composer::Component.new(
  disabled: true,
  placeholder: "Comments are disabled"
) %>
```

## With Initial Value

Pre-fill the composer (e.g., for editing):

```erb
<%= render FlatPack::Comments::Composer::Component.new(
  value: @comment.body,
  submit_label: "Update Comment",
  show_cancel: true
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `placeholder` | String | `"Write a comment..."` | Textarea placeholder |
| `submit_label` | String | `"Comment"` | Submit button text |
| `cancel_label` | String | `"Cancel"` | Cancel button text |
| `show_cancel` | Boolean | `false` | Show cancel button |
| `disabled` | Boolean | `false` | Disable all inputs |
| `compact` | Boolean | `false` | Reduce padding |
| `form` | String | `nil` | Form ID (for external form) |
| `name` | String | `"comment"` | Textarea name attribute |
| `value` | String | `nil` | Initial textarea value |
| `rows` | Integer | `3` | Textarea rows |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes |

## Slots

| Slot | Type | Description |
|------|------|-------------|
| `toolbar` | Single | Formatting tools or options |
| `attachments` | Single | File attachments or previews |
| `actions` | Single | Custom action buttons (replaces defaults) |

## Examples

### Reply Composer
```erb
<%= form_with model: [@comment, Comment.new] do |f| %>
  <%= render FlatPack::Comments::Composer::Component.new(
    name: "comment[body]",
    placeholder: "Write a reply...",
    submit_label: "Reply",
    compact: true,
    rows: 2
  ) %>
<% end %>
```

### Rich Text Editor
```erb
<%= render FlatPack::Comments::Composer::Component.new(
  rows: 6
) do |composer| %>
  <% composer.with_toolbar do %>
    <div class="flex gap-1 border-b pb-2">
      <%= button_tag "Bold", type: "button", class: "px-2 py-1 text-sm" %>
      <%= button_tag "Italic", type: "button", class: "px-2 py-1 text-sm" %>
      <%= button_tag "Link", type: "button", class: "px-2 py-1 text-sm" %>
    </div>
  <% end %>
  
  <% composer.with_actions do %>
    <div class="flex justify-between items-center w-full">
      <div class="text-xs text-[var(--surface-muted-content-color)]">
        Markdown supported
      </div>
      <button type="submit" class="btn-primary">
        Post Comment
      </button>
    </div>
  <% end %>
<% end %>
```

### Edit Mode
```erb
<%= form_with model: @comment, method: :patch do |f| %>
  <%= render FlatPack::Comments::Composer::Component.new(
    name: "comment[body]",
    value: @comment.body,
    submit_label: "Save Changes",
    cancel_label: "Cancel",
    show_cancel: true
  ) %>
<% end %>
```

### External Form
Useful when composer needs to be outside the form tag:

```erb
<%= form_with id: "comment-form", model: Comment.new do |f| %>
  <!-- Other form fields -->
<% end %>

<!-- Somewhere else in the page -->
<%= render FlatPack::Comments::Composer::Component.new(
  form: "comment-form",
  name: "comment[body]"
) %>
```

### With File Upload
```erb
<%= form_with model: Comment.new, multipart: true do |f| %>
  <%= render FlatPack::Comments::Composer::Component.new(
    name: "comment[body]"
  ) do |composer| %>
    <% composer.with_attachments do %>
      <%= f.file_field :attachments, multiple: true, class: "hidden", id: "file-input" %>
      <div id="file-previews"></div>
    <% end %>
    
    <% composer.with_actions do %>
      <div class="flex justify-between w-full">
        <%= label_tag :file_input, "📎 Attach", class: "cursor-pointer text-sm" %>
        <%= button_tag "Comment", type: "submit", class: "btn-primary" %>
      </div>
    <% end %>
  <% end %>
<% end %>
```
