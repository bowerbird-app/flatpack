# List and List Item Components

The List component renders semantic lists with optional ordered/unordered styling. List Items provide consistent spacing and optional icons.

## Basic Usage

```erb
<%= render FlatPack::List::Component.new do %>
  <%= render FlatPack::List::Item.new { "First item" } %>
  <%= render FlatPack::List::Item.new { "Second item" } %>
  <%= render FlatPack::List::Item.new { "Third item" } %>
<% end %>
```

## List Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `ordered` | Boolean | `false` | Use ordered list (`<ol>`) instead of unordered (`<ul>`) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## List Item Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `icon` | Symbol/String | `nil` | Icon identifier or SVG markup |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Examples

### Unordered List (Default)
```erb
<%= render FlatPack::List::Component.new do %>
  <%= render FlatPack::List::Item.new { "Task one" } %>
  <%= render FlatPack::List::Item.new { "Task two" } %>
  <%= render FlatPack::List::Item.new { "Task three" } %>
<% end %>
```

### Ordered List
```erb
<%= render FlatPack::List::Component.new(ordered: true) do %>
  <%= render FlatPack::List::Item.new { "First step" } %>
  <%= render FlatPack::List::Item.new { "Second step" } %>
  <%= render FlatPack::List::Item.new { "Third step" } %>
<% end %>
```

### With Icons
```erb
<%= render FlatPack::List::Component.new do %>
  <%= render FlatPack::List::Item.new(icon: :check) { "Completed task" } %>
  <%= render FlatPack::List::Item.new(icon: :alert) { "Pending task" } %>
  <%= render FlatPack::List::Item.new(icon: :user) { "Assigned to you" } %>
<% end %>
```

### Rich Content Items
```erb
<%= render FlatPack::List::Component.new do %>
  <%= render FlatPack::List::Item.new do %>
    <div>
      <h4 class="font-semibold">Item Title</h4>
      <p class="text-sm text-gray-600">Item description goes here</p>
    </div>
  <% end %>
<% end %>
```

### Feature List
```erb
<%= render FlatPack::List::Component.new do %>
  <%= render FlatPack::List::Item.new(icon: :check) do %>
    <strong>Unlimited Projects:</strong> Create as many as you need
  <% end %>
  <%= render FlatPack::List::Item.new(icon: :check) do %>
    <strong>Team Collaboration:</strong> Invite unlimited team members
  <% end %>
  <%= render FlatPack::List::Item.new(icon: :check) do %>
    <strong>24/7 Support:</strong> Always here to help
  <% end %>
<% end %>
```

## Accessibility

- Uses semantic `<ul>` or `<ol>` elements
- Includes `role="list"` and `role="listitem"` for screen readers
- Icons marked with appropriate color contrast
- Keyboard navigable
- Supports ARIA attributes via `system_arguments`

## Use Cases

- Feature lists
- Step-by-step instructions
- Navigation menus (as a base)
- Task lists
- Settings options
- Bullet point content
