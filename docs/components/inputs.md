# Input Components

FlatPack provides a comprehensive set of text-based input components with built-in accessibility, security, and mobile optimization.

## Basic Usage

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  placeholder: "Enter your username"
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `name` | String | **required** | Form field name |
| `value` | String | `nil` | Initial value |
| `placeholder` | String | `nil` | Placeholder text |
| `label` | String | `nil` | Accessible label text |
| `error` | String | `nil` | Error message to display |
| `disabled` | Boolean | `false` | Disabled state |
| `required` | Boolean | `false` | Required field |
| `rows` | Integer | `3` | Initial rows (TextArea only) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Component Types

### TextInput

Standard single-line text field for general text input.

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  placeholder: "Enter your username",
  required: true
) %>
```

### PasswordInput

Masked input field with an integrated show/hide toggle button.

```erb
<%= render FlatPack::PasswordInput::Component.new(
  name: "password",
  label: "Password",
  placeholder: "Enter your password",
  required: true
) %>
```

Features eye icon toggle for password visibility with Stimulus controller (`flat-pack--password-input`).

### EmailInput

Email input field that triggers the `@` keyboard on mobile devices.

```erb
<%= render FlatPack::EmailInput::Component.new(
  name: "email",
  label: "Email Address",
  placeholder: "you@example.com",
  required: true
) %>
```

### PhoneInput

Phone number input that triggers the numeric keypad on mobile devices.

```erb
<%= render FlatPack::PhoneInput::Component.new(
  name: "phone",
  label: "Phone Number",
  placeholder: "+1 (555) 123-4567"
) %>
```

### SearchInput

Search input field with an automatic clear (X) button.

```erb
<%= render FlatPack::SearchInput::Component.new(
  name: "q",
  label: "Search",
  placeholder: "Search for anything..."
) %>
```

Clear button appears when input has value. Uses Stimulus controller (`flat-pack--search-input`).

### TextArea

Multi-line text input that automatically expands to fit content.

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "description",
  label: "Description",
  placeholder: "Enter a detailed description...",
  rows: 3
) %>
```

Auto-expanding based on content with Stimulus controller (`flat-pack--text-area`).

### UrlInput

URL input field with XSS protection and mobile `.com` keyboard.

```erb
<%= render FlatPack::UrlInput::Component.new(
  name: "website",
  label: "Website URL",
  placeholder: "https://example.com"
) %>
```

Blocks dangerous protocols (javascript:, data:, vbscript:) for security.

## System Arguments

### Custom Classes

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "search",
  class: "w-full max-w-md"
) %>
```

Classes are merged using `tailwind_merge`, so Tailwind utilities override correctly.

### Data Attributes

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "search",
  data: {
    controller: "search",
    action: "input->search#query"
  }
) %>
```

### ARIA Attributes

```erb
<%= render FlatPack::SearchInput::Component.new(
  name: "q",
  aria: {
    label: "Search the site",
    describedby: "search-help"
  }
) %>
```

### Other Attributes

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  id: "user-name",
  disabled: true,
  required: true
) %>
```

## Examples

### Basic Form

```erb
<%= form_with model: @user do |f| %>
  <%= render FlatPack::TextInput::Component.new(
    name: "user[name]",
    label: "Full Name",
    value: @user.name,
    required: true
  ) %>

  <%= render FlatPack::EmailInput::Component.new(
    name: "user[email]",
    label: "Email",
    value: @user.email,
    required: true
  ) %>

  <%= render FlatPack::PasswordInput::Component.new(
    name: "user[password]",
    label: "Password",
    required: true
  ) %>

  <%= f.submit "Create Account" %>
<% end %>
```

### With Error States

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  value: @user.username,
  error: @user.errors[:username].first
) %>
```

### Disabled State

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "email",
  label: "Email (Verified)",
  value: @user.email,
  disabled: true
) %>
```

### Contact Form

```erb
<div class="max-w-md mx-auto p-6">
  <%= form_with url: contact_path do |f| %>
    <%= render FlatPack::TextInput::Component.new(
      name: "name",
      label: "Your Name",
      required: true
    ) %>

    <%= render FlatPack::EmailInput::Component.new(
      name: "email",
      label: "Email Address",
      required: true
    ) %>

    <%= render FlatPack::PhoneInput::Component.new(
      name: "phone",
      label: "Phone Number"
    ) %>

    <%= render FlatPack::TextArea::Component.new(
      name: "message",
      label: "Message",
      placeholder: "How can we help?",
      rows: 5,
      required: true
    ) %>

    <%= render FlatPack::Button::Component.new(
      text: "Send Message",
      style: :primary
    ) %>
  <% end %>
</div>
```

### User Profile Form

```erb
<%= form_with model: @user do |f| %>
  <div class="grid grid-cols-2 gap-4">
    <%= render FlatPack::TextInput::Component.new(
      name: "user[first_name]",
      label: "First Name",
      value: @user.first_name
    ) %>

    <%= render FlatPack::TextInput::Component.new(
      name: "user[last_name]",
      label: "Last Name",
      value: @user.last_name
    ) %>
  </div>

  <%= render FlatPack::EmailInput::Component.new(
    name: "user[email]",
    label: "Email",
    value: @user.email,
    required: true
  ) %>

  <%= render FlatPack::PhoneInput::Component.new(
    name: "user[phone]",
    label: "Phone",
    value: @user.phone
  ) %>

  <%= render FlatPack::UrlInput::Component.new(
    name: "user[website]",
    label: "Website",
    value: @user.website
  ) %>

  <%= render FlatPack::TextArea::Component.new(
    name: "user[bio]",
    label: "Biography",
    value: @user.bio,
    rows: 4
  ) %>

  <%= f.submit "Update Profile" %>
<% end %>
```

## Styling

### CSS Variables

Customize input colors by overriding CSS variables:

```css
@theme {
  /* Input colors */
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.15 0.01 250);
  --color-border: oklch(0.85 0.01 250);
  --color-ring: oklch(0.55 0.25 270);
  
  /* Error state */
  --color-destructive: oklch(0.55 0.22 25);
  
  /* Placeholders */
  --color-muted-foreground: oklch(0.45 0.01 250);
  
  /* Border radius */
  --radius-md: 0.375rem;
}
```

### Security Features

All input components include XSS prevention:

- HTML attributes are sanitized using `AttributeSanitizer`
- Dangerous event handlers (onclick, etc.) are filtered out
- UrlInput blocks dangerous protocols (javascript:, data:, vbscript:)

## Accessibility

The Input components follow accessibility best practices:

- Uses semantic HTML (`<input>`, `<textarea>`)
- Proper label associations (for/id)
- Includes ARIA attributes for error states
- aria-invalid on inputs with errors
- aria-describedby linking to error messages
- Supports keyboard navigation
- Focus indicators with high contrast
- Disabled state properly communicated

### Keyboard Support

- `Tab` - Focus next input
- `Shift+Tab` - Focus previous input
- Standard text input behavior

## Testing

```ruby
# test/components/input_test.rb
require "test_helper"

class InputTest < ViewComponent::TestCase
  def test_renders_with_error
    render_inline FlatPack::TextInput::Component.new(
      name: "username",
      label: "Username",
      error: "is required"
    )
    
    assert_selector "input[aria-invalid='true']"
    assert_selector "p", text: "is required"
  end
end
```

## API Reference

```ruby
# TextInput, EmailInput, PhoneInput, SearchInput, UrlInput
FlatPack::<ComponentType>::Component.new(
  name: String,               # Required
  value: String,              # Optional, default: nil
  placeholder: String,        # Optional, default: nil
  label: String,              # Optional, default: nil
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
)

# PasswordInput (same as above)
FlatPack::PasswordInput::Component.new(...)

# TextArea (adds rows parameter)
FlatPack::TextArea::Component.new(
  name: String,               # Required
  rows: Integer,              # Optional, default: 3
  # ... same parameters as above
)
```

### System Arguments

- `class`: String - Additional CSS classes
- `data`: Hash - Data attributes
- `aria`: Hash - ARIA attributes
- `id`: String - Element ID
- Any other valid HTML attribute

## Related Components

- [Button Component](button.md) - For form submit buttons
- [Table Component](table.md) - Inputs in table rows

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Security Policy](../../SECURITY.md)
