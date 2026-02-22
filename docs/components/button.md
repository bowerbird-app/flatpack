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
| `style` | Symbol | `:default` | Visual style (`:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`) |
| `size` | Symbol | `:md` | Button size (`:sm`, `:md`, `:lg`) |
| `url` | String | `nil` | If provided, renders as link instead of button |
| `method` | Symbol | `nil` | HTTP method for link (`:get`, `:post`, `:delete`, etc.) |
| `target` | String | `nil` | Link target (e.g., `"_blank"` for new tab) |
| `icon` | String | `nil` | Icon name to display (requires icon component) |
| `icon_only` | Boolean | `false` | Display icon without text |
| `loading` | Boolean | `false` | Show loading spinner and disable button |
| `type` | String | `"button"` | Button type (`"button"`, `"submit"`, `"reset"`) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, `name`, `value`, `disabled`, etc.) |

## Schemes

### Default (Default)
Neutral action style (white/light surface), used for standard actions.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Cancel",
  style: :default
) %>
```

### Primary
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

### Form Submit Buttons

Submit buttons are used within forms to trigger form submission. The button component supports all button types and integrates seamlessly with Rails forms.

#### Button Types

The `type` prop controls button behavior within forms:

- `"button"` (default) - Does nothing by itself, useful for JavaScript interactions
- `"submit"` - Submits the containing form
- `"reset"` - Resets form inputs to initial values

```erb
<%= form_with model: @user do |f| %>
  <%= render FlatPack::TextInput::Component.new(
    label: "Name",
    name: "user[name]"
  ) %>
  
  <!-- Submit button -->
  <%= render FlatPack::Button::Component.new(
    text: "Submit",
    type: "submit",
    style: :primary
  ) %>
  
  <!-- Regular button (doesn't submit) -->
  <%= render FlatPack::Button::Component.new(
    text: "Cancel",
    type: "button",
    style: :secondary
  ) %>
  
  <!-- Reset button -->
  <%= render FlatPack::Button::Component.new(
    text: "Reset",
    type: "reset",
    style: :ghost
  ) %>
<% end %>
```

#### Different HTTP Methods

Submit buttons work with all HTTP methods (POST, PATCH, PUT, DELETE):

```erb
<!-- POST (Create) -->
<%= form_with url: users_path, method: :post do |f| %>
  <%= render FlatPack::Button::Component.new(
    text: "Create User",
    type: "submit",
    style: :primary
  ) %>
<% end %>

<!-- PATCH (Update) -->
<%= form_with model: @user, method: :patch do |f| %>
  <%= render FlatPack::Button::Component.new(
    text: "Update User",
    type: "submit",
    style: :success
  ) %>
<% end %>

<!-- DELETE (Destroy) -->
<%= form_with url: user_path(@user), method: :delete do |f| %>
  <%= render FlatPack::Button::Component.new(
    text: "Delete Account",
    type: "submit",
    style: :warning,
    data: { turbo_confirm: "Are you sure?" }
  ) %>
<% end %>
```

#### Multiple Submit Buttons

Forms can have multiple submit buttons with different actions using `name` and `value` attributes:

```erb
<%= form_with model: @post do |f| %>
  <%= render FlatPack::TextInput::Component.new(
    label: "Content",
    name: "post[content]"
  ) %>
  
  <%= render FlatPack::Button::Component.new(
    text: "Save as Draft",
    type: "submit",
    style: :secondary,
    name: "action",
    value: "draft"
  ) %>
  
  <%= render FlatPack::Button::Component.new(
    text: "Publish",
    type: "submit",
    style: :primary,
    name: "action",
    value: "publish"
  ) %>
<% end %>
```

In your controller, check which button was clicked:

```ruby
def create
  if params[:action] == "publish"
    @post.publish!
  elsif params[:action] == "draft"
    @post.save_as_draft!
  end
end
```

#### Submit Button Variations

Submit buttons support all styles, sizes, and features:

```erb
<%= form_with model: @user do |f| %>
  <!-- Different styles -->
  <%= render FlatPack::Button::Component.new(
    text: "Submit Primary",
    type: "submit",
    style: :primary
  ) %>
  
  <%= render FlatPack::Button::Component.new(
    text: "Submit Success",
    type: "submit",
    style: :success
  ) %>
  
  <!-- Different sizes -->
  <%= render FlatPack::Button::Component.new(
    text: "Small Submit",
    type: "submit",
    size: :sm
  ) %>
  
  <%= render FlatPack::Button::Component.new(
    text: "Large Submit",
    type: "submit",
    size: :lg
  ) %>
  
  <!-- With icon -->
  <%= render FlatPack::Button::Component.new(
    text: "Save",
    icon: "check",
    type: "submit",
    style: :success
  ) %>
  
  <!-- Full width -->
  <%= render FlatPack::Button::Component.new(
    text: "Continue",
    type: "submit",
    style: :primary,
    class: "w-full"
  ) %>
<% end %>
```

#### Loading State During Submission

Show a loading state while the form is being processed:

```erb
<%= form_with model: @user, 
              data: { controller: "form-submit" } do |f| %>
  
  <%= render FlatPack::Button::Component.new(
    text: "Submitting",
    type: "submit",
    style: :primary,
    loading: true,
    data: { 
      form_submit_target: "submitButton",
      action: "form-submit#disableOnSubmit" 
    }
  ) %>
<% end %>
```

When `loading: true`, the submit button:
- Displays an animated spinner
- Is automatically disabled
- Shows "Loading" text (or hides text if `icon_only: true`)

#### Disabled Submit Button

Prevent form submission with the `disabled` attribute:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Submit",
  type: "submit",
  disabled: true
) %>
```

#### Submit Button with Data Attributes

Add data attributes for Turbo, Stimulus, or other JavaScript interactions:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Submit",
  type: "submit",
  data: { 
    turbo_confirm: "Are you sure?",
    controller: "form-validator",
    action: "click->form-validator#validate"
  }
) %>
```

#### Accessible Submit Buttons

Always provide clear context for screen readers:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Submit",
  type: "submit",
  aria: { 
    label: "Submit user registration form",
    describedby: "form-help-text"
  }
) %>
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

Customize button colors and shadows by overriding CSS variables:

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
  
  /* Button shadows */
  --button-shadow: 0 0 15px 0px rgba(0, 0, 0, 0.15);
  --button-shadow-active: 0 0 8px 4px rgba(0, 0, 0, 0.15);
}
```

**Note:** Button components (rendered as `<button>` elements) include box-shadows by default. The `--button-shadow` is applied to the default state, while `--button-shadow-active` is applied on hover, focus, and active states. Link buttons (rendered as `<a>` elements when `url` is provided) and disabled buttons do not have box-shadows.

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
  type: String,               # Optional, default: "button" ("button", "submit", "reset")
  **system_arguments          # Optional
)
```

### System Arguments

- `class`: String - Additional CSS classes
- `data`: Hash - Data attributes
- `aria`: Hash - ARIA attributes
- `id`: String - Element ID
- `name`: String - Button name (for multiple submit buttons)
- `value`: String - Button value (for multiple submit buttons)
- `disabled`: Boolean - Disabled state
- Any other valid HTML attribute

## Related Components

- [Button Dropdown Component](button-dropdown.md) - Dropdown menus triggered by buttons
- [Card Component](card.md) - Cards often use buttons for actions
- [Icon Component](../shared/icon.md) - For button icons
- [Table Actions](table.md#actions) - Buttons in table rows

## Live Examples

See the [Forms Demo page](/demo/forms) in the dummy app for comprehensive examples of submit buttons with different HTTP methods, styles, sizes, and configurations.

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Table Component](table.md)
