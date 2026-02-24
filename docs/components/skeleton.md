# Skeleton Component

## Purpose
Display loading placeholders that preserve layout shape before content is ready.

## When to use
Use Skeleton during async loading states to reduce layout shift and improve perceived performance.

## Class
- Primary: `FlatPack::Skeleton::Component`

## Props
See the `Props` section below for supported arguments and defaults.

## Slots
Not applicable; Skeleton is primarily prop-driven.

## Variants
See shape, size, and animation variants below.

## Example
Start with `Basic Usage` below.

## Accessibility
See accessibility notes below for loading-state semantics.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).

The Skeleton component displays loading placeholders that match the shape of expected content.

## Basic Usage

```erb
<%= render FlatPack::Skeleton::Component.new %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | Symbol | `:text` | Preset shape (`:text`, `:title`, `:avatar`, `:button`, `:rectangle`) |
| `width` | String | `nil` | Custom width (e.g., "200px", "50%") |
| `height` | String | `nil` | Custom height (e.g., "100px", "3rem") |
| `shimmer` | Boolean | `true` | Enables or disables shimmer animation |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Variants

### Text (Default)
Single line of text placeholder.
```erb
<%= render FlatPack::Skeleton::Component.new(variant: :text) %>
```

### Title
Larger heading placeholder.
```erb
<%= render FlatPack::Skeleton::Component.new(variant: :title) %>
```

### Avatar
Circular avatar placeholder.
```erb
<%= render FlatPack::Skeleton::Component.new(variant: :avatar) %>
```

### Button
Button-shaped placeholder.
```erb
<%= render FlatPack::Skeleton::Component.new(variant: :button) %>
```

### Rectangle
Large rectangular content area.
```erb
<%= render FlatPack::Skeleton::Component.new(variant: :rectangle) %>
```

## Examples

### Custom Dimensions
```erb
<%= render FlatPack::Skeleton::Component.new(
  width: "300px",
  height: "200px"
) %>
```

### Disable Shimmer
```erb
<%= render FlatPack::Skeleton::Component.new(shimmer: false) %>
```

### Loading Card
```erb
<div class="border rounded-lg p-4 space-y-4">
  <%= render FlatPack::Skeleton::Component.new(variant: :avatar) %>
  <%= render FlatPack::Skeleton::Component.new(variant: :title) %>
  <%= render FlatPack::Skeleton::Component.new(variant: :text) %>
  <%= render FlatPack::Skeleton::Component.new(variant: :text) %>
  <%= render FlatPack::Skeleton::Component.new(variant: :button) %>
</div>
```

### Loading List
```erb
<div class="space-y-4">
  <% 3.times do %>
    <div class="flex items-center gap-3">
      <%= render FlatPack::Skeleton::Component.new(variant: :avatar) %>
      <div class="flex-1 space-y-2">
        <%= render FlatPack::Skeleton::Component.new(variant: :text) %>
        <%= render FlatPack::Skeleton::Component.new(variant: :text, width: "70%") %>
      </div>
    </div>
  <% end %>
</div>
```

### Loading Table
```erb
<table class="w-full">
  <tbody>
    <% 5.times do %>
      <tr>
        <td><%= render FlatPack::Skeleton::Component.new(variant: :text) %></td>
        <td><%= render FlatPack::Skeleton::Component.new(variant: :text) %></td>
        <td><%= render FlatPack::Skeleton::Component.new(variant: :button) %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

## Accessibility

- Uses `role="status"` for screen reader announcements
- Includes `aria-busy="true"` to indicate loading state
- Includes `aria-label="Loading..."` for context
- Includes a shimmer animation for visual loading feedback
- Automatically disables shimmer animation for users who prefer reduced motion

## Use Cases

- Loading states for data fetching
- Placeholder for async content
- Improved perceived performance
- Reducing layout shift during loading
