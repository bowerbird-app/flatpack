# Badge Component

The Badge component renders small status indicators, counts, labels, and tags for highlighting information.

## Basic Usage

```erb
<%= render FlatPack::Badge::Component.new(text: "New") %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | **required** | Badge text content |
| `variant` | Symbol | `:default` | Visual variant (`:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`) |
| `size` | Symbol | `:md` | Badge size (`:sm`, `:md`, `:lg`) |
| `dot` | Boolean | `false` | Show indicator dot |
| `removable` | Boolean | `false` | Show remove/close button |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Variants

### Default (Neutral/Gray)
General purpose badges, neutral information.

```erb
<%= render FlatPack::Badge::Component.new(text: "Default") %>
```

### Primary
Brand color, primary actions or features.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "New",
  variant: :primary
) %>
```

### Success
Positive status, completed actions.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Active",
  variant: :success
) %>
```

### Warning
Caution, pending status.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Pending",
  variant: :warning
) %>
```

### Danger
Errors, critical status.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Error",
  variant: :danger
) %>
```

### Info
Informational badges.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Beta",
  variant: :info
) %>
```

## Sizes

### Small
Compact badges for tight spaces.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Small",
  size: :sm
) %>
```

### Medium (Default)
Standard size for most use cases.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Medium",
  size: :md
) %>
```

### Large
Larger badges for emphasis.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Large",
  size: :lg
) %>
```

## Dot Indicator
Show a status dot alongside the text.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Online",
  variant: :success,
  dot: true
) %>
```

## Removable Badge
Show a close button for removable tags.

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Tag",
  removable: true
) %>
```

## Use Cases

### Status Indicators
```erb
<%= render FlatPack::Badge::Component.new(text: "Active", variant: :success) %>
<%= render FlatPack::Badge::Component.new(text: "Pending", variant: :warning) %>
<%= render FlatPack::Badge::Component.new(text: "Completed", variant: :primary) %>
```

### Notification Counts
```erb
<%= render FlatPack::Badge::Component.new(text: "5", variant: :danger) %>
<%= render FlatPack::Badge::Component.new(text: "12 new", variant: :primary) %>
```

### Category Tags
```erb
<%= render FlatPack::Badge::Component.new(text: "Ruby", removable: true) %>
<%= render FlatPack::Badge::Component.new(text: "Rails", removable: true) %>
<%= render FlatPack::Badge::Component.new(text: "JavaScript", removable: true) %>
```

### User Roles
```erb
<%= render FlatPack::Badge::Component.new(text: "Admin", variant: :danger) %>
<%= render FlatPack::Badge::Component.new(text: "Editor", variant: :primary) %>
<%= render FlatPack::Badge::Component.new(text: "Viewer", variant: :default) %>
```

### Feature Flags
```erb
<%= render FlatPack::Badge::Component.new(text: "Beta", variant: :info) %>
<%= render FlatPack::Badge::Component.new(text: "New", variant: :primary) %>
<%= render FlatPack::Badge::Component.new(text: "Experimental", variant: :warning) %>
```

## System Arguments

All standard HTML attributes are supported via `**system_arguments`:

```erb
<%= render FlatPack::Badge::Component.new(
  text: "Custom",
  id: "my-badge",
  class: "mr-2",
  data: { testid: "status-badge" },
  aria: { label: "Status indicator" }
) %>
```

## Accessibility

- Uses semantic markup with proper color contrast
- Color is not the only indicator (includes text)
- Removable badges have accessible close buttons with aria-label
- Supports custom ARIA attributes via system_arguments

## Testing

```ruby
# test/components/flat_pack/badge_component_test.rb
render_inline(FlatPack::Badge::Component.new(text: "Test", variant: :success))
assert_selector "span", text: "Test"
```
