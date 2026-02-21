# Timeline and Timeline Item Components

The Timeline component displays chronological events with visual markers and connecting lines.

## Basic Usage

```erb
<%= render FlatPack::Timeline::Component.new do %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Project Started",
    timestamp: "2 hours ago"
  ) do %>
    <p>Project kickoff meeting completed.</p>
  <% end %>
<% end %>
```

## Timeline Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Timeline Item Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | String | **required** | Event title |
| `timestamp` | String | `nil` | Time or date string |
| `variant` | Symbol | `:default` | Marker color (`:default`, `:success`, `:warning`, `:danger`) |
| `icon` | String | `nil` | Custom SVG icon markup |
| `last` | Boolean | `false` | Whether this is the last item (hides connecting line) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Examples

### Basic Timeline
```erb
<%= render FlatPack::Timeline::Component.new do %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Order Placed",
    timestamp: "Jan 15, 2024"
  ) %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Order Shipped",
    timestamp: "Jan 16, 2024"
  ) %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Order Delivered",
    timestamp: "Jan 18, 2024",
    last: true
  ) %>
<% end %>
```

### With Variants
```erb
<%= render FlatPack::Timeline::Component.new do %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Deployment Started",
    variant: :default,
    timestamp: "10:00 AM"
  ) %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Tests Passed",
    variant: :success,
    timestamp: "10:05 AM"
  ) %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Warning Detected",
    variant: :warning,
    timestamp: "10:07 AM"
  ) %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Deployment Failed",
    variant: :danger,
    timestamp: "10:10 AM",
    last: true
  ) %>
<% end %>
```

### With Rich Content
```erb
<%= render FlatPack::Timeline::Component.new do %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Pull Request Opened",
    timestamp: "2 hours ago",
    variant: :default
  ) do %>
    <p>John Doe opened PR #123: "Add new feature"</p>
    <div class="mt-2">
      <%= render FlatPack::Badge::Component.new(text: "+150", style: :success) %>
      <%= render FlatPack::Badge::Component.new(text: "-45", style: :danger) %>
    </div>
  <% end %>
  
  <%= render FlatPack::Timeline::Item.new(
    title: "Review Completed",
    timestamp: "1 hour ago",
    variant: :success
  ) do %>
    <p>Jane Smith approved the changes</p>
  <% end %>
  
  <%= render FlatPack::Timeline::Item.new(
    title: "Merged to Main",
    timestamp: "30 minutes ago",
    variant: :success,
    last: true
  ) do %>
    <p>Automatically deployed to production</p>
  <% end %>
<% end %>
```

### Activity Feed
```erb
<%= render FlatPack::Timeline::Component.new do %>
  <% @activities.each_with_index do |activity, index| %>
    <%= render FlatPack::Timeline::Item.new(
      title: activity.title,
      timestamp: time_ago_in_words(activity.created_at) + " ago",
      variant: activity.status_variant,
      last: index == @activities.size - 1
    ) do %>
      <%= activity.description %>
    <% end %>
  <% end %>
<% end %>
```

## Accessibility

- Uses semantic markup with `role="list"` and `role="listitem"`
- Color is not the only indicator (includes text and icons)
- Proper heading hierarchy for event titles
- Timestamps use semantic `<time>` element
- Keyboard navigable
- Supports ARIA attributes via `system_arguments`

## Use Cases

- Activity feeds
- Order tracking
- Project milestones
- Git commit history
- Deployment logs
- User activity history
- Workflow progress
