# Avatar Component

A flexible avatar component that displays user images, initials, or a generic fallback icon with support for different sizes, shapes, and status indicators.

## Basic Usage

```erb
<%= render FlatPack::Avatar::Component.new(
  src: "https://example.com/avatar.jpg",
  alt: "John Doe"
) %>
```

## With Name and Initials

The component automatically extracts initials from the name:

```erb
<%= render FlatPack::Avatar::Component.new(name: "John Doe") %>
<!-- Displays "JD" -->
```

Or provide explicit initials:

```erb
<%= render FlatPack::Avatar::Component.new(
  name: "John Doe",
  initials: "AB"
) %>
```

## Sizes

Available sizes: `:xs`, `:sm`, `:md` (default), `:lg`, `:xl`

```erb
<%= render FlatPack::Avatar::Component.new(name: "User", size: :xs) %>
<%= render FlatPack::Avatar::Component.new(name: "User", size: :sm) %>
<%= render FlatPack::Avatar::Component.new(name: "User", size: :md) %>
<%= render FlatPack::Avatar::Component.new(name: "User", size: :lg) %>
<%= render FlatPack::Avatar::Component.new(name: "User", size: :xl) %>
```

## Shapes

Available shapes: `:circle` (default), `:rounded`, `:square`

```erb
<%= render FlatPack::Avatar::Component.new(name: "User", shape: :circle) %>
<%= render FlatPack::Avatar::Component.new(name: "User", shape: :rounded) %>
<%= render FlatPack::Avatar::Component.new(name: "User", shape: :square) %>
```

## Status Indicators

Show online/offline/busy/away status with a colored dot:

```erb
<%= render FlatPack::Avatar::Component.new(
  name: "John Doe",
  status: :online
) %>

<%= render FlatPack::Avatar::Component.new(
  name: "Jane Smith",
  status: :busy
) %>
```

Available statuses: `:online`, `:offline`, `:busy`, `:away`

## As a Link

Wrap the avatar in a link by providing an `href`:

```erb
<%= render FlatPack::Avatar::Component.new(
  name: "John Doe",
  href: "/users/1"
) %>
```

## Fallback Behavior

1. **Image**: If `src` is provided, displays the image
2. **Initials**: If no `src` but `name` or `initials` provided, displays initials
3. **Generic Icon**: If nothing provided, shows a generic user icon

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `src` | String | `nil` | Image URL |
| `alt` | String | `name` or "Avatar" | Alt text for image |
| `name` | String | `nil` | User name (used for initials and alt text) |
| `initials` | String | `nil` | Explicit initials to display |
| `size` | Symbol | `:md` | Size of avatar (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) |
| `shape` | Symbol | `:circle` | Shape (`:circle`, `:rounded`, `:square`) |
| `status` | Symbol | `nil` | Status indicator (`:online`, `:offline`, `:busy`, `:away`) |
| `href` | String | `nil` | If provided, wraps avatar in link |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes (class, data, aria, etc.) |

## Examples

### Image with Status
```erb
<%= render FlatPack::Avatar::Component.new(
  src: "https://example.com/avatar.jpg",
  alt: "John Doe",
  status: :online,
  size: :lg
) %>
```

### Initials with Custom Styling
```erb
<%= render FlatPack::Avatar::Component.new(
  name: "Jane Smith",
  shape: :rounded,
  class: "shadow-lg",
  data: {user_id: "123"}
) %>
```

### Clickable Avatar Group
```erb
<%= render FlatPack::Avatar::Component.new(
  src: "https://example.com/avatar.jpg",
  name: "John Doe",
  href: "/profile/john-doe",
  size: :xl,
  shape: :rounded
) %>
```
