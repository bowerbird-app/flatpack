# Accordion Component

The Accordion component groups multiple collapsible sections with coordinated expand/collapse behavior.

## Basic Usage

```erb
<%= render FlatPack::Accordion::Component.new do |accordion| %>
  <% accordion.item(id: "item1", title: "Section 1") do %>
    <p>Content for section 1</p>
  <% end %>
  <% accordion.item(id: "item2", title: "Section 2") do %>
    <p>Content for section 2</p>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `allow_multiple` | Boolean | `false` | Allow multiple items open simultaneously |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Item Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `id` | String | **required** | Unique identifier for the item |
| `title` | String | **required** | Title shown on the trigger button |
| `open` | Boolean | `false` | Initial expanded state |

## Examples

### Basic Accordion
```erb
<%= render FlatPack::Accordion::Component.new do |accordion| %>
  <% accordion.item(id: "faq1", title: "What is FlatPack?") do %>
    <p>FlatPack is a ViewComponent library for Rails.</p>
  <% end %>
  <% accordion.item(id: "faq2", title: "How do I install it?") do %>
    <p>Add it to your Gemfile and run bundle install.</p>
  <% end %>
<% end %>
```

### Allow Multiple Open
```erb
<%= render FlatPack::Accordion::Component.new(allow_multiple: true) do |accordion| %>
  <% accordion.item(id: "feature1", title: "Feature 1") do %>
    <p>Details about feature 1</p>
  <% end %>
  <% accordion.item(id: "feature2", title: "Feature 2") do %>
    <p>Details about feature 2</p>
  <% end %>
<% end %>
```

### With Default Open Item
```erb
<%= render FlatPack::Accordion::Component.new do |accordion| %>
  <% accordion.item(id: "overview", title: "Overview", open: true) do %>
    <p>This section is open by default</p>
  <% end %>
  <% accordion.item(id: "details", title: "Details") do %>
    <p>This section is closed by default</p>
  <% end %>
<% end %>
```

## Stimulus Controller

Uses the `flat-pack--accordion` Stimulus controller for coordinated animations.

### Behavior
- By default, opening one item closes others
- Set `allow_multiple: true` to allow multiple open items
- Smooth CSS transitions on expand/collapse
- Icon rotation animation

## Accessibility

- Uses semantic `button` elements for triggers
- Includes `aria-expanded` attributes
- Proper `aria-controls` linking
- Keyboard accessible navigation
- Focus management with visible focus rings

## Use Cases

- FAQ sections
- Settings panels with multiple sections
- Product feature details
- Documentation navigation
