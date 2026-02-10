# Button Component

The Button component renders a button or link with consistent styling and behavior.

## Basic Usage

```erb
<%= render FlatPack::Button::Component.new(text: "Click me") %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | `nil` | Button text (required unless `icon` is provided) |
| `style` | Symbol | `:primary` | Visual style (`:primary`, `:secondary`, `:ghost`, `:success`, `:warning`) |
| `size` | Symbol | `:md` | Button size (`:sm`, `:md`, `:lg`) |
| `url` | String | `nil` | If provided, renders as link instead of button |
| `method` | Symbol | `nil` | HTTP method for link (`:get`, `:post`, `:delete`, etc.) |
| `target` | String | `nil` | Link target (e.g., `"_blank"` for new tab) |
| `icon` | String | `nil` | Icon name to display (requires icon component) |
| `icon_only` | Boolean | `false` | Display icon without text |
| `loading` | Boolean | `false` | Show loading spinner and disable button |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Schemes

### Primary (Default)
Primary actions, most important button on the page.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Save",
  style: :primary
) %>
```

### Secondary
Secondary actions, less prominent.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Cancel",
  style: :secondary
) %>
```

### Ghost
Tertiary actions, minimal styling.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Learn More",
  style: :ghost
) %>
```

### Success
Positive or completion actions.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Approve",
  style: :success
) %>
```

### Warning
Destructive or cautionary actions.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Delete",
  style: :warning
) %>
```

## Sizes

Buttons come in three sizes: small (`:sm`), medium (`:md`, default), and large (`:lg`).

### Small
Compact size for tight spaces or secondary actions.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Small Button",
  size: :sm
) %>
```

### Medium (Default)
Standard button size for most use cases.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Medium Button",
  size: :md
) %>
```

### Large
Prominent size for primary call-to-action buttons.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Large Button",
  size: :lg
) %>
```

### Combining Sizes with Schemes

```erb
<%= render FlatPack::Button::Component.new(
  text: "Small Primary",
  style: :primary,
  size: :sm
) %>

<%= render FlatPack::Button::Component.new(
  text: "Large Secondary",
  style: :secondary,
  size: :lg
) %>
```

## Rendering as Link

When `url` is provided, button renders as a link (`<a>` tag):

```erb
<%= render FlatPack::Button::Component.new(
  text: "View Profile",
  url: user_path(@user),
  style: :primary
) %>
```

### With HTTP Method

```erb
<%= render FlatPack::Button::Component.new(
  text: "Delete",
  url: user_path(@user),
  method: :delete,
  style: :secondary,
  data: { turbo_confirm: "Are you sure?" }
) %>
```

### Open in New Tab

Use the `target` prop to open links in a new tab. Security attributes (`rel="noopener noreferrer"`) are automatically added.

```erb
<%= render FlatPack::Button::Component.new(
  text: "View External Site",
  url: "https://example.com",
  target: "_blank",
  style: :primary
) %>
```

## Icons

### Button with Icon

Display an icon alongside text using the `icon` prop:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Download",
  icon: "download",
  style: :primary
) %>
```

### Icon-Only Button

Create icon-only buttons for compact interfaces:

```erb
<%= render FlatPack::Button::Component.new(
  icon: "settings",
  icon_only: true,
  style: :ghost,
  aria: { label: "Settings" }
) %>
```

**Note:** Always provide an `aria-label` for icon-only buttons for accessibility.

## Loading State

Show a loading spinner and disable interaction with the `loading` prop:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Save",
  loading: true,
  style: :primary
) %>
```

When `loading: true`:
- Button is automatically disabled
- Shows an animated spinner
- Text changes to "Loading" (or hidden if `icon_only: true`)

## System Arguments

### Custom Classes

```erb
<%= render FlatPack::Button::Component.new(
  text: "Custom",
  class: "mt-4 w-full"
) %>
```

Classes are merged using `tailwind_merge`, so Tailwind utilities override correctly.

### Data Attributes

```erb
<%= render FlatPack::Button::Component.new(
  text: "Track Click",
  data: {
    controller: "analytics",
    action: "click->analytics#track"
  }
) %>
```

### ARIA Attributes

```erb
<%= render FlatPack::Button::Component.new(
  text: "Close",
  aria: {
    label: "Close dialog",
    controls: "my-dialog"
  }
) %>
```

### Other Attributes

```erb
<%= render FlatPack::Button::Component.new(
  text: "Submit",
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
    text: "Create User",
    style: :primary,
    type: "submit"
  ) %>
<% end %>
```

### Button Group

```erb
<div class="flex gap-2">
  <%= render FlatPack::Button::Component.new(text: "Save", style: :primary) %>
  <%= render FlatPack::Button::Component.new(text: "Cancel", style: :secondary) %>
</div>
```

### Full Width Button

```erb
<%= render FlatPack::Button::Component.new(
  text: "Continue",
  class: "w-full"
) %>
```

### With Icon (using Stimulus or Helper)

```erb
<%= render FlatPack::Button::Component.new(
  text: "Delete",
  style: :ghost,
  data: { controller: "icon", icon_name: "trash" }
) %>
```

### Loading State

```erb
<%= render FlatPack::Button::Component.new(
  text: "Loading...",
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
    render_inline FlatPack::Button::Component.new(text: "Test")
    
    assert_selector "button", text: "Test"
  end
end
```

## API Reference

```ruby
FlatPack::Button::Component.new(
  text: String,               # Optional (required unless icon is provided)
  style: Symbol,              # Optional, default: :primary (:primary, :secondary, :ghost, :success, :warning)
  size: Symbol,               # Optional, default: :md (:sm, :md, :lg)
  url: String,                # Optional, default: nil
  method: Symbol,             # Optional, default: nil
  target: String,             # Optional, default: nil
  icon: String,               # Optional, default: nil
  icon_only: Boolean,         # Optional, default: false
  loading: Boolean,           # Optional, default: false
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

- [Button Dropdown Component](button-dropdown.md) - Dropdown menus triggered by buttons
- [Card Component](card.md) - Cards often use buttons for actions
- [Icon Component](../shared/icon.md) - For button icons
- [Table Actions](table.md#actions) - Buttons in table rows

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Table Component](table.md)
