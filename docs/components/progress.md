# Progress Bar Component

## Purpose
Display visual progress for tasks, uploads, and multi-step flows.

## When to use
Use Progress when users need a clear indicator of completion percentage or current status.

## Class
- Primary: `FlatPack::Progress::Component`

## Props
See the `Props` section below for supported arguments and defaults.

## Slots
Not applicable; Progress is primarily prop-driven.

## Variants
See style and size variants below.

## Example
Start with `Basic Usage` below.

## Accessibility
See accessibility notes below for `aria` progress semantics.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).

The Progress Bar component displays task completion or loading progress with customizable variants and sizes.

## Basic Usage

```erb
<%= render FlatPack::Progress::Component.new(value: 50) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | Number | **required** | Current progress value |
| `max` | Number | `100` | Maximum value |
| `variant` | Symbol | `:default` | Visual style (`:default`, `:success`, `:warning`, `:danger`) |
| `size` | Symbol | `:md` | Bar height (`:sm`, `:md`, `:lg`, `:xl`) |
| `label` | String | `nil` | Optional label text |
| `show_label` | Boolean | `false` | Show percentage as label |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Examples

### Basic Progress Bar
```erb
<%= render FlatPack::Progress::Component.new(value: 65) %>
```

### With Label
```erb
<%= render FlatPack::Progress::Component.new(
  value: 75,
  label: "Upload Progress"
) %>
```

### Show Percentage
```erb
<%= render FlatPack::Progress::Component.new(
  value: 80,
  show_label: true
) %>
```

### Variants
```erb
<%= render FlatPack::Progress::Component.new(value: 100, variant: :success) %>
<%= render FlatPack::Progress::Component.new(value: 60, variant: :warning) %>
<%= render FlatPack::Progress::Component.new(value: 30, variant: :danger) %>
```

### Sizes
```erb
<%= render FlatPack::Progress::Component.new(value: 50, size: :sm) %>
<%= render FlatPack::Progress::Component.new(value: 50, size: :md) %>
<%= render FlatPack::Progress::Component.new(value: 50, size: :lg) %>
<%= render FlatPack::Progress::Component.new(value: 50, size: :xl) %>
```

## Accessibility

- Uses `role="progressbar"` with proper ARIA attributes
- Includes `aria-valuenow`, `aria-valuemin`, and `aria-valuemax`
- Screen reader accessible percentage hidden visually with `.sr-only`
- Supports custom ARIA labels via `system_arguments`

## Use Cases

- File upload progress
- Multi-step form completion
- Task completion indicators
- Loading states with known duration
