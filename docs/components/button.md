# Button Component

The Button component renders a button or link with consistent styling and behavior.

## Basic Usage

```erb
<%= render FlatPack::Button::Component.new(label: "Click me") %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `label` | String | **required** | Button text |
| `scheme` | Symbol | `:primary` | Visual style (`:primary`, `:secondary`, `:ghost`) |
| `url` | String | `nil` | If provided, renders as link instead of button |
| `method` | Symbol | `nil` | HTTP method for link (`:get`, `:post`, `:delete`, etc.) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Schemes

### Primary (Default)
Primary actions, most important button on the page.

```erb
<%= render FlatPack::Button::Component.new(
  label: "Save",
  scheme: :primary
) %>
```

### Secondary
Secondary actions, less prominent.

```erb
<%= render FlatPack::Button::Component.new(
  label: "Cancel",
  scheme: :secondary
) %>
```

### Ghost
Tertiary actions, minimal styling.

```erb
<%= render FlatPack::Button::Component.new(
  label: "Learn More",
  scheme: :ghost
) %>
```

## Rendering as Link

When `url` is provided, button renders as a link (`<a>` tag):

```erb
<%= render FlatPack::Button::Component.new(
  label: "View Profile",
  url: user_path(@user),
  scheme: :primary
) %>
```

### With HTTP Method

```erb
<%= render FlatPack::Button::Component.new(
  label: "Delete",
  url: user_path(@user),
  method: :delete,
  scheme: :secondary,
  data: { turbo_confirm: "Are you sure?" }
) %>
```

## System Arguments

### Custom Classes

```erb
<%= render FlatPack::Button::Component.new(
  label: "Custom",
  class: "mt-4 w-full"
) %>
```

Classes are merged using `tailwind_merge`, so Tailwind utilities override correctly.

### Data Attributes

```erb
<%= render FlatPack::Button::Component.new(
  label: "Track Click",
  data: {
    controller: "analytics",
    action: "click->analytics#track"
  }
) %>
```

### ARIA Attributes

```erb
<%= render FlatPack::Button::Component.new(
  label: "Close",
  aria: {
    label: "Close dialog",
    controls: "my-dialog"
  }
) %>
```

### Other Attributes

```erb
<%= render FlatPack::Button::Component.new(
  label: "Submit",
  id: "submit-btn",
  disabled: true
) %>
```

## Examples

### Form Submit Button

```erb
<%= form_with model: @user do |f| %>
  <%# ... form fields ... %>
  
  <%= render FlatPack::Button::Component.new(
    label: "Create User",
    scheme: :primary,
    type: "submit"
  ) %>
<% end %>
```

### Button Group

```erb
<div class="flex gap-2">
  <%= render FlatPack::Button::Component.new(label: "Save", scheme: :primary) %>
  <%= render FlatPack::Button::Component.new(label: "Cancel", scheme: :secondary) %>
</div>
```

### Full Width Button

```erb
<%= render FlatPack::Button::Component.new(
  label: "Continue",
  class: "w-full"
) %>
```

### With Icon (using Stimulus or Helper)

```erb
<%= render FlatPack::Button::Component.new(
  label: "Delete",
  scheme: :ghost,
  data: { controller: "icon", icon_name: "trash" }
) %>
```

### Loading State

```erb
<%= render FlatPack::Button::Component.new(
  label: "Loading...",
  disabled: true,
  data: { controller: "loading" }
) %>
```

## Styling

### CSS Variables

Customize button colors by overriding CSS variables:

```css
@theme {
  /* Primary button */
  --color-primary: oklch(0.55 0.25 270);
  --color-primary-hover: oklch(0.45 0.28 270);
  --color-primary-text: oklch(1.0 0 0);
  
  /* Secondary button */
  --color-secondary: oklch(0.95 0.01 250);
  --color-secondary-hover: oklch(0.90 0.02 250);
  --color-secondary-text: oklch(0.25 0.02 250);
  
  /* Ghost button */
  --color-ghost: transparent;
  --color-ghost-hover: oklch(0.96 0.01 250);
  --color-ghost-text: oklch(0.35 0.02 250);
}
```

### Custom Scheme

To add a custom scheme, extend the component in your application:

```ruby
# app/components/custom_button_component.rb
class CustomButtonComponent < FlatPack::Button::Component
  SCHEMES = FlatPack::Button::Component::SCHEMES.merge(
    danger: "bg-red-600 hover:bg-red-700 text-white"
  )
end
```

## Accessibility

The Button component follows accessibility best practices:

- Uses semantic HTML (`<button>` or `<a>`)
- Includes visible focus ring
- Supports keyboard navigation
- Accepts ARIA attributes
- Disabled state prevents interaction

### Keyboard Support

- `Enter` / `Space` - Activate button
- `Tab` - Focus next button
- `Shift+Tab` - Focus previous button

## Testing

```ruby
# test/components/custom_button_test.rb
require "test_helper"

class CustomButtonTest < ViewComponent::TestCase
  def test_renders_primary_button
    render_inline FlatPack::Button::Component.new(label: "Test")
    
    assert_selector "button", text: "Test"
  end
end
```

## API Reference

```ruby
FlatPack::Button::Component.new(
  label: String,              # Required
  scheme: Symbol,             # Optional, default: :primary
  url: String,                # Optional, default: nil
  method: Symbol,             # Optional, default: nil
  **system_arguments          # Optional
)
```

### System Arguments

- `class`: String - Additional CSS classes
- `data`: Hash - Data attributes
- `aria`: Hash - ARIA attributes
- `id`: String - Element ID
- `disabled`: Boolean - Disabled state
- Any other valid HTML attribute

## Related Components

- [Icon Component](../shared/icon.md) - For button icons
- [Table Actions](table.md#actions) - Buttons in table rows

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Table Component](table.md)
