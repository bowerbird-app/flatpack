# Collapse Component

The Collapse component creates expandable/collapsible content sections with smooth animations via Stimulus.

## Basic Usage

```erb
<%= render FlatPack::Collapse::Component.new(id: "details", title: "More Information") do %>
  <p>Hidden content that can be toggled.</p>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `id` | String | **required** | Unique identifier for the collapse |
| `title` | String | **required** | Title shown on the trigger button |
| `open` | Boolean | `false` | Initial expanded state |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Examples

### Closed by Default
```erb
<%= render FlatPack::Collapse::Component.new(id: "info", title: "Additional Info") do %>
  <p>This content is initially hidden.</p>
<% end %>
```

### Open by Default
```erb
<%= render FlatPack::Collapse::Component.new(id: "details", title: "Details", open: true) do %>
  <p>This content is initially visible.</p>
<% end %>
```

### With Rich Content
```erb
<%= render FlatPack::Collapse::Component.new(id: "settings", title: "Advanced Settings") do %>
  <div class="space-y-4">
    <%= render FlatPack::TextInput::Component.new(name: "api_key", label: "API Key") %>
    <%= render FlatPack::Switch::Component.new(name: "debug", label: "Debug Mode") %>
  </div>
<% end %>
```

## Stimulus Controller

The collapse component uses the `flat-pack--collapse` Stimulus controller for animations.

### Targets
- `trigger`: The button that toggles the collapse
- `content`: The collapsible content area
- `icon`: The chevron icon that rotates

### Actions
- `toggle`: Expands/collapses the content

## Accessibility

- Uses semantic `button` element for trigger
- Includes `aria-expanded` attribute that updates on toggle
- Proper `aria-controls` linking to content ID
- Keyboard accessible (Space/Enter to toggle)
- Focus management with visible focus rings

## Use Cases

- FAQ sections
- "Read more" content
- Settings panels
- Details sections
