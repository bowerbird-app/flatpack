# Chip Component

Chips are compact elements that represent input, attributes, or actions. They allow users to enter information, make selections, filter content, or trigger actions.

## Types

- **Static** - Non-interactive display chips
- **Button** - Interactive, clickable chips (can be selected/toggled)
- **Link** - Navigation chips
- **Removable** - Chips with a remove button
- **Filter** - Selectable chips for filtering (button type with selected state)

## Basic Usage

```erb
<%= render FlatPack::Chip::Component.new(text: "Ruby") %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | `nil` | Text content (optional if block content provided) |
| `style` | Symbol | `:default` | Visual style: `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info` |
| `size` | Symbol | `:md` | Size variant: `:sm`, `:md`, `:lg` |
| `selected` | Boolean | `false` | Whether chip is selected (only for button type) |
| `disabled` | Boolean | `false` | Whether chip is disabled |
| `removable` | Boolean | `false` | Whether chip can be removed |
| `href` | String | `nil` | URL for link chips (requires `type: :link`) |
| `type` | Symbol | `:static` | Chip type: `:static`, `:button`, `:link` |
| `value` | String | `nil` | Value passed in events (useful for tracking) |
| `name` | String | `nil` | Name attribute (reserved for future form integration) |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes (class, data, aria, id, etc.) |

## Slots

### `leading`
Content to display before the text (icons, avatars, etc.)

```erb
<%= render FlatPack::Chip::Component.new(text: "Ruby") do |c| %>
  <% c.with_leading do %>
    <%= render FlatPack::Shared::IconComponent.new(name: :star, size: :sm) %>
  <% end %>
<% end %>
```

### `trailing`
Content to display after the text

```erb
<%= render FlatPack::Chip::Component.new(text: "5 items") do |c| %>
  <% c.with_trailing do %>
    <%= render FlatPack::Shared::IconComponent.new(name: :arrow_right, size: :sm) %>
  <% end %>
<% end %>
```

### `remove_button`
Custom remove button (overrides default if provided)

## Examples

### Basic Chips

```erb
<%= render FlatPack::Chip::Component.new(text: "Default") %>
<%= render FlatPack::Chip::Component.new(text: "Primary", style: :primary) %>
<%= render FlatPack::Chip::Component.new(text: "Success", style: :success) %>
<%= render FlatPack::Chip::Component.new(text: "Warning", style: :warning) %>
<%= render FlatPack::Chip::Component.new(text: "Danger", style: :danger) %>
<%= render FlatPack::Chip::Component.new(text: "Info", style: :info) %>
```

### Sizes

```erb
<%= render FlatPack::Chip::Component.new(text: "Small", size: :sm) %>
<%= render FlatPack::Chip::Component.new(text: "Medium", size: :md) %>
<%= render FlatPack::Chip::Component.new(text: "Large", size: :lg) %>
```

### With Leading Icons

```erb
<%= render FlatPack::Chip::Component.new(text: "Ruby", style: :danger) do |c| %>
  <% c.with_leading do %>
    <%= render FlatPack::Shared::IconComponent.new(name: :code, size: :sm) %>
  <% end %>
<% end %>

<%= render FlatPack::Chip::Component.new(text: "JavaScript", style: :warning) do |c| %>
  <% c.with_leading do %>
    <%= render FlatPack::Shared::IconComponent.new(name: :code, size: :sm) %>
  <% end %>
<% end %>
```

### Removable Chips

Removable chips include a remove button and emit a `chip:removed` event when removed.

```erb
<%= render FlatPack::Chip::Component.new(
  text: "Ruby",
  removable: true,
  value: "ruby"
) %>

<%= render FlatPack::Chip::Component.new(
  text: "JavaScript",
  style: :warning,
  removable: true,
  value: "javascript"
) %>
```

**Listening to remove events:**

```javascript
document.addEventListener('chip:removed', (event) => {
  console.log('Chip removed:', event.detail.value)
  // event.detail.value contains the chip's value
  // event.detail.element contains the removed element
})
```

### Selectable Filter Chips

Use button type chips for filtering or selection. They can be toggled and emit `chip:toggled` events.

```erb
<%= render FlatPack::Chip::Component.new(
  text: "All",
  type: :button,
  selected: true,
  value: "all"
) %>

<%= render FlatPack::Chip::Component.new(
  text: "Active",
  type: :button,
  selected: false,
  value: "active"
) %>

<%= render FlatPack::Chip::Component.new(
  text: "Archived",
  type: :button,
  selected: false,
  value: "archived"
) %>
```

**Listening to toggle events:**

```javascript
document.addEventListener('chip:toggled', (event) => {
  console.log('Chip toggled:', event.detail.value, event.detail.selected)
  // event.detail.value contains the chip's value
  // event.detail.selected is true/false
  // event.detail.element contains the chip element
})
```

### Disabled Chips

```erb
<%= render FlatPack::Chip::Component.new(
  text: "Disabled",
  disabled: true
) %>

<%= render FlatPack::Chip::Component.new(
  text: "Disabled Button",
  type: :button,
  disabled: true
) %>

<%= render FlatPack::Chip::Component.new(
  text: "Disabled Link",
  type: :link,
  href: "#",
  disabled: true
) %>
```

### Link Chips

```erb
<%= render FlatPack::Chip::Component.new(
  text: "View Details",
  type: :link,
  href: "/details",
  style: :primary
) %>

<%= render FlatPack::Chip::Component.new(
  text: "Documentation",
  type: :link,
  href: "/docs"
) do |c| %>
  <% c.with_trailing do %>
    <%= render FlatPack::Shared::IconComponent.new(name: :external_link, size: :sm) %>
  <% end %>
<% end %>
```

### Chips with Avatars

```erb
<%= render FlatPack::Chip::Component.new(text: "Nathan Garcia") do |c| %>
  <% c.with_leading do %>
    <%= render FlatPack::Avatar::Component.new(
      initials: "NG",
      size: :xs
    ) %>
  <% end %>
<% end %>

<%= render FlatPack::Chip::Component.new(text: "Team", style: :primary) do |c| %>
  <% c.with_leading do %>
    <%= render FlatPack::AvatarGroup::Component.new(
      items: [
        { initials: "NG", size: :xs },
        { initials: "JD", size: :xs },
        { initials: "AB", size: :xs }
      ],
      size: :xs,
      max: 3
    ) %>
  <% end %>
<% end %>
```

### Using ChipGroup

The `ChipGroup` component provides a convenient wrapper for groups of chips with proper spacing and wrapping.

```erb
<%= render FlatPack::ChipGroup::Component.new do %>
  <%= render FlatPack::Chip::Component.new(text: "Ruby", style: :danger) %>
  <%= render FlatPack::Chip::Component.new(text: "Rails", style: :danger) %>
  <%= render FlatPack::Chip::Component.new(text: "JavaScript", style: :warning) %>
  <%= render FlatPack::Chip::Component.new(text: "React", style: :info) %>
  <%= render FlatPack::Chip::Component.new(text: "TypeScript", style: :info) %>
<% end %>
```

**No wrapping:**

```erb
<%= render FlatPack::ChipGroup::Component.new(wrap: false) do %>
  <%= render FlatPack::Chip::Component.new(text: "Ruby") %>
  <%= render FlatPack::Chip::Component.new(text: "Rails") %>
  <%= render FlatPack::Chip::Component.new(text: "JavaScript") %>
<% end %>
```

## ChipGroup Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `wrap` | Boolean | `true` | Whether chips should wrap to next line |
| `size` | Symbol | `nil` | Reserved for future use |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes |

## Events

### `chip:removed`

Emitted when a chip is removed. Event detail contains:
- `value` - The chip's value prop
- `element` - The removed chip element

### `chip:toggled`

Emitted when a button chip is toggled. Event detail contains:
- `value` - The chip's value prop
- `selected` - Boolean indicating new selected state
- `element` - The chip element

## Accessibility

- Button chips use `aria-pressed` to indicate selection state
- Removable chips have `aria-label="Remove"` on the remove button
- Focus rings on interactive elements (buttons and links)
- Disabled state properly communicated to assistive technologies

## Styling

Chips use CSS variables for theming:
- `--color-muted` / `--color-foreground` - Default style
- `--color-primary` / `--color-primary-text` - Primary style
- `--color-success` / `--color-success-text` - Success style
- `--color-warning` / `--color-warning-text` - Warning style
- `--color-ring` - Focus ring color
- `--transition-base` - Transition duration

## Best Practices

1. **Use appropriate types** - Static for display, button for interaction, link for navigation
2. **Provide meaningful values** - Set the `value` prop for removable/selectable chips to track them
3. **Keep text concise** - Chips should contain brief, scannable text
4. **Use ChipGroup for collections** - Wrap multiple chips in ChipGroup for consistent spacing
5. **Consider mobile** - Use appropriate sizes for touch targets on mobile devices
6. **Limit removable chips** - Don't allow users to remove critical filters or required data
7. **Provide feedback** - Use events to update UI state when chips are removed or toggled

## Related Components

- [Badge](badge.md) - For status indicators and counts
- [Button](button.md) - For primary actions
- [Avatar](avatar.md) - Can be used with chips for user representation
