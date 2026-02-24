# List and List Item Components

## Purpose
Render consistent semantic lists and list items.

## When to use
Use List for structured collections where spacing, separators, and optional leading visuals should be standardized.

## Class
- Primary: `FlatPack::List::Component`

## Props
See the `Props` section below for supported arguments and defaults.

## Slots
See item composition examples below.

## Variants
See ordered/unordered and style variants below.

## Example
Start with `Basic Usage` below.

## Accessibility
See accessibility notes below for semantic list markup.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).

The List component renders semantic lists with optional ordered/unordered styling. List Items provide consistent spacing and optional icons.

## Basic Usage

```erb
<%= render FlatPack::List::Component.new do %>
  <%= render FlatPack::List::Item.new do %>
    First item
  <% end %>
  <%= render FlatPack::List::Item.new do %>
    Second item
  <% end %>
  <%= render FlatPack::List::Item.new do %>
    Third item
  <% end %>
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
  <%= render FlatPack::List::Item.new do %>
    Task one
  <% end %>
  <%= render FlatPack::List::Item.new do %>
    Task two
  <% end %>
  <%= render FlatPack::List::Item.new do %>
    Task three
  <% end %>
<% end %>
```

### Ordered List
```erb
<%= render FlatPack::List::Component.new(ordered: true) do %>
  <%= render FlatPack::List::Item.new do %>
    First step
  <% end %>
  <%= render FlatPack::List::Item.new do %>
    Second step
  <% end %>
  <%= render FlatPack::List::Item.new do %>
    Third step
  <% end %>
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
