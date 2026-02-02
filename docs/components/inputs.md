# Input Components

FlatPack provides a comprehensive set of text-based input components with built-in accessibility, security, and mobile optimization.

![Input Components Demo](https://github.com/user-attachments/assets/bcbd298a-0b9e-4d3f-8066-7c37135641d1)

## Components Overview

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

**Features:**
- Clean, minimal design
- Full accessibility support (ARIA, labels)
- Error state styling
- Disabled state support

---

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

**Features:**
- Eye icon toggle for password visibility
- Stimulus controller for toggle behavior
- Secure password masking
- Accessible toggle button with ARIA labels

**Stimulus Controller:** `flat-pack--password-input`

---

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

**Features:**
- HTML5 email validation
- Mobile @ keyboard trigger
- Standard email input behavior

---

### PhoneInput
Phone number input that triggers the numeric keypad on mobile devices.

```erb
<%= render FlatPack::PhoneInput::Component.new(
  name: "phone",
  label: "Phone Number",
  placeholder: "+1 (555) 123-4567"
) %>
```

**Features:**
- HTML5 tel input type
- Mobile numeric keypad trigger
- International phone number support

---

### SearchInput
Search input field with an automatic clear (X) button.

```erb
<%= render FlatPack::SearchInput::Component.new(
  name: "q",
  label: "Search",
  placeholder: "Search for anything..."
) %>
```

**Features:**
- Clear button appears when input has value
- Stimulus controller for clear functionality
- HTML5 search input type
- Mobile-optimized search keyboard

**Stimulus Controller:** `flat-pack--search-input`

---

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

**Features:**
- Auto-expanding based on content
- Stimulus controller for height adjustment
- Configurable initial rows
- Vertical resize handle

**Stimulus Controller:** `flat-pack--text-area`

---

### UrlInput
URL input field with XSS protection and mobile `.com` keyboard.

```erb
<%= render FlatPack::UrlInput::Component.new(
  name: "website",
  label: "Website URL",
  placeholder: "https://example.com"
) %>
```

**Features:**
- HTML5 URL validation
- XSS protection (blocks javascript:, data:, vbscript: protocols)
- Mobile .com keyboard trigger
- Secure URL sanitization

---

## Common Parameters

All input components accept these parameters:

### Required
- `name` - (String) Form field name

### Optional
- `value` - (String) Initial value
- `placeholder` - (String) Placeholder text
- `label` - (String) Accessible label text
- `error` - (String) Error message to display
- `disabled` - (Boolean) Disabled state (default: false)
- `required` - (Boolean) Required field (default: false)
- `**system_arguments` - Any additional HTML attributes (class, id, data, aria, etc.)

### Component-Specific
- **TextArea**
  - `rows` - (Integer) Initial number of rows (default: 3)

---

## Usage Examples

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

### Custom Classes and Attributes

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "search",
  placeholder: "Search...",
  class: "custom-class",
  data: { controller: "search" },
  aria: { label: "Search the site" }
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

---

## Styling

All input components share the base `flat-pack-input` CSS class with these features:

- **Consistent borders and focus states**
- **CSS variable-based theming**
- **Dark mode support**
- **Smooth transitions**
- **Error state styling**

### CSS Variables Used

```css
--color-background
--color-foreground
--color-border
--color-ring
--color-destructive (for errors)
--color-muted-foreground (for placeholders)
--radius-md
--transition-base
```

---

## Accessibility

All input components include:

- ✅ **Proper label associations** (for/id)
- ✅ **ARIA attributes** for error states
- ✅ **aria-invalid** on inputs with errors
- ✅ **aria-describedby** linking to error messages
- ✅ **Keyboard navigation** support
- ✅ **Screen reader** friendly
- ✅ **Focus indicators** with high contrast
- ✅ **Disabled state** properly communicated

---

## Security

### XSS Prevention
- All HTML attributes are sanitized using `AttributeSanitizer`
- Dangerous event handlers (onclick, etc.) are filtered out
- UrlInput blocks dangerous protocols (javascript:, data:, vbscript:)

### URL Validation (UrlInput)
```ruby
# Allowed protocols
http:// https:// mailto: tel:

# Relative URLs
/path/to/page
./relative/path

# Blocked protocols
javascript:alert('xss')  # ❌ Blocked
data:text/html,...        # ❌ Blocked
vbscript:msgbox('xss')   # ❌ Blocked
```

---

## Stimulus Controllers

### Password Input Controller
**Purpose:** Toggle password visibility

```javascript
// Targets: input, toggle, eyeIcon, eyeOffIcon
// Actions: toggle (on button click)
```

### Search Input Controller
**Purpose:** Clear search input

```javascript
// Targets: input, clearButton
// Actions: clear (on button click), toggleClearButton (on input)
```

### Text Area Controller
**Purpose:** Auto-expand textarea

```javascript
// Targets: textarea
// Actions: resize (on input, connect)
```

---

## Testing

All components include comprehensive test coverage:

```ruby
# Example test
def test_renders_with_error
  render_inline(FlatPack::TextInput::Component.new(
    name: "username",
    label: "Username",
    error: "is required"
  ))

  assert_selector "input[aria-invalid='true']"
  assert_selector "p", text: "is required"
end
```

Run tests:
```bash
bundle exec rake test
```

---

## Browser Support

- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Mobile Safari (iOS 12+)
- ✅ Chrome Mobile (latest)

---

## Mobile Optimization

All input components are optimized for mobile devices:

- **EmailInput** - Triggers @ key on keyboard
- **PhoneInput** - Triggers numeric keypad
- **UrlInput** - Triggers .com key on keyboard
- **SearchInput** - Triggers search keyboard with "Search" button
- **Touch-friendly** - All interactive elements have adequate tap targets (44x44px minimum)

---

## Customization

### Custom Classes

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "custom",
  class: "w-1/2 max-w-md"
) %>
```

### Custom CSS Variables

Override in your application CSS:

```css
:root {
  --color-ring: oklch(0.62 0.25 330); /* Custom focus ring */
  --color-destructive: oklch(65% .25 30); /* Custom error color */
}
```

---

## Performance

- **Zero JavaScript** for simple inputs (TextInput, EmailInput, PhoneInput, UrlInput)
- **Minimal JavaScript** for interactive inputs (PasswordInput, SearchInput, TextArea)
- **Lazy-loaded Stimulus controllers** via importmaps
- **No external dependencies**

---

## Examples

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

---

## Troubleshooting

### Input not focusing properly
Ensure you have proper label-input associations. The component automatically generates unique IDs.

### Stimulus controller not working
Verify that the controller is registered in your importmap:

```ruby
# config/importmap.rb
pin_all_from "app/javascript/flat_pack/controllers", under: "controllers/flat_pack"
```

### Error messages not showing
Ensure you're passing the `error` parameter with a non-empty string.

### Dark mode issues
Check that your app's stylesheet imports FlatPack variables:

```css
@import "flat_pack/variables.css";
```

---

## Contributing

Found a bug or have a suggestion? Please open an issue on GitHub!

---

## Related Documentation

- [Button Component](button.md)
- [Table Component](table.md)
- [Theming Guide](../theming.md)
- [Security Policy](../../SECURITY.md)
