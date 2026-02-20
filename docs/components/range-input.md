# Range Input Component

The Range Input component provides an accessible slider input with live value display.

## Basic Usage

```erb
<%= render FlatPack::RangeInput::Component.new(name: "volume") %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `name` | String | **required** | Input name attribute |
| `id` | String | `name` | Input ID attribute |
| `value` | Number | `min` | Current value |
| `min` | Number | `0` | Minimum value |
| `max` | Number | `100` | Maximum value |
| `step` | Number | `1` | Step increment |
| `label` | String | `nil` | Optional label text |
| `show_value` | Boolean | `true` | Show current value |
| `disabled` | Boolean | `false` | Disabled state |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Examples

### Basic Range Input
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "volume",
  value: 50
) %>
```

### With Label
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "volume",
  label: "Volume Control",
  value: 75
) %>
```

### Custom Range
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "price",
  label: "Price Range",
  min: 0,
  max: 1000,
  step: 50,
  value: 500
) %>
```

### Without Value Display
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "opacity",
  label: "Opacity",
  min: 0,
  max: 1,
  step: 0.1,
  value: 1,
  show_value: false
) %>
```

### Disabled State
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "volume",
  value: 50,
  disabled: true
) %>
```

## Stimulus Controller

Uses the `flat-pack--range-input` Stimulus controller for live value updates.

### Events
Dispatches `range-input:change` custom event:

```javascript
element.addEventListener('range-input:change', (event) => {
  console.log('New value:', event.detail.value)
})
```

## Accessibility

- Uses native `<input type="range">` for built-in accessibility
- Includes proper `aria-label`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`
- Keyboard accessible (arrow keys to adjust)
- Focus visible with ring
- Value displayed in monospace font for clarity

## Use Cases

- Volume controls
- Opacity/transparency adjustments
- Price range filters
- Zoom level controls
- Progress indicators (as input)
- Rating inputs
