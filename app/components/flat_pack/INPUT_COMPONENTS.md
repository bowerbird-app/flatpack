# FlatPack Input Components

This directory contains 7 text-based input components for the FlatPack Rails UI component library.

## Available Components

### 1. TextInput
Standard single-line text input field.

```ruby
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  placeholder: "Enter your username",
  value: @user.username,
  required: true
) %>
```

### 2. PasswordInput
Password input with toggle visibility button.

```ruby
<%= render FlatPack::PasswordInput::Component.new(
  name: "password",
  label: "Password",
  placeholder: "Enter your password",
  required: true
) %>
```

Features:
- Eye icon to toggle password visibility
- Secure by default (type="password")
- Keyboard accessible

### 3. EmailInput
Email input field with mobile keyboard optimization.

```ruby
<%= render FlatPack::EmailInput::Component.new(
  name: "email",
  label: "Email Address",
  placeholder: "you@example.com",
  value: @user.email,
  required: true
) %>
```

Features:
- HTML5 email validation (type="email")
- Mobile keyboards show @ symbol prominently

### 4. PhoneInput
Phone number input with numeric keypad on mobile.

```ruby
<%= render FlatPack::PhoneInput::Component.new(
  name: "phone",
  label: "Phone Number",
  placeholder: "+1 (555) 123-4567",
  value: @user.phone
) %>
```

Features:
- HTML5 telephone input (type="tel")
- Mobile keyboards show numeric keypad

### 5. SearchInput
Search field with auto-appearing clear button.

```ruby
<%= render FlatPack::SearchInput::Component.new(
  name: "query",
  label: "Search",
  placeholder: "Search...",
  value: params[:q]
) %>
```

Features:
- Clear (X) button appears when input has value
- Clears input and refocuses on click
- HTML5 search input (type="search")

### 6. TextArea
Multi-line textarea with auto-expand.

```ruby
<%= render FlatPack::TextArea::Component.new(
  name: "description",
  label: "Description",
  placeholder: "Enter a description...",
  value: @post.description,
  rows: 3,
  character_count: true,
  min_characters: 30,
  max_characters: 140,
  required: true
) %>
```

Features:
- Auto-expands to fit content
- Configurable initial rows
- Optional live character count
- Optional min/max thresholds with warning color when out of range
- No manual resize (resize: none)

### 7. UrlInput
URL input with XSS protection.

```ruby
<%= render FlatPack::UrlInput::Component.new(
  name: "website",
  label: "Website",
  placeholder: "https://example.com",
  value: @company.website
) %>
```

Features:
- URL sanitization using AttributeSanitizer
- Blocks javascript:, data:, vbscript: protocols
- Allows http:, https:, mailto:, tel:, and relative URLs
- HTML5 URL input (type="url")
- Mobile keyboards show .com key

## Common Parameters

All input components accept these parameters:

### Required
- `name:` (String) - Form field name attribute

### Optional
- `value:` (String) - Initial value
- `placeholder:` (String) - Placeholder text
- `label:` (String) - Label text
- `error:` (String) - Error message to display
- `disabled:` (Boolean, default: false) - Disable the input
- `required:` (Boolean, default: false) - Mark as required
- `**system_arguments` - Additional HTML attributes (class, data, aria, id, etc.)

### Component-Specific
- `rows:` (Integer, TextArea only) - Initial number of rows (default: 3)
- `character_count:` (Boolean, TextArea only) - Show live character count (default: false)
- `min_characters:` (Integer, TextArea only) - Min threshold for warning color (default: nil)
- `max_characters:` (Integer, TextArea only) - Max threshold and counter denominator (default: nil)

## Features

### Base CSS Class
All inputs share the `flat-pack-input` CSS class with consistent styling:
- Rounded corners using CSS variables
- Border with focus states
- CSS variable-based theming
- Disabled state styling
- Error state styling
- Focus ring for accessibility

### Accessibility
- Proper label associations (for/id attributes)
- ARIA attributes for error states (aria-invalid, aria-describedby)
- Keyboard navigation support
- Disabled state properly communicated
- Required fields marked appropriately

### Security
- All inputs use `FlatPack::AttributeSanitizer` to prevent XSS
- Dangerous HTML attributes (onclick, etc.) are filtered
- UrlInput sanitizes URL values to prevent script injection
- No inline JavaScript in component output

### Error Handling
When an `error` parameter is provided:
- Error message displayed below input
- Red border applied to input
- `aria-invalid="true"` added
- `aria-describedby` links to error message

### Styling
All components use Tailwind CSS with CSS variables for theming:
- `--color-background` - Input background
- `--color-foreground` - Text color
- `--color-border` - Border color
- `--color-ring` - Focus ring color
- `--color-destructive` - Error state color
- `--color-muted-foreground` - Placeholder color
- `--radius-md` - Border radius
- `--transition-base` - Transition duration

## Examples

### With Label and Error
```ruby
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  value: @user.username,
  error: @user.errors[:username].first,
  required: true
) %>
```

### With Custom Classes and Data Attributes
```ruby
<%= render FlatPack::EmailInput::Component.new(
  name: "email",
  label: "Email",
  class: "custom-input",
  data: { controller: "email-validator", action: "blur->email-validator#validate" }
) %>
```

### Disabled State
```ruby
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  value: @user.username,
  disabled: true
) %>
```

## Stimulus Controllers

The input components include Stimulus controllers for interactive features:

### password_input_controller.js
Handles password visibility toggle.

**Targets:**
- `input` - The password input field
- `toggle` - The toggle button
- `eyeIcon` - The eye icon (shown when password is hidden)
- `eyeOffIcon` - The eye-off icon (shown when password is visible)

**Actions:**
- `toggle` - Toggles password visibility

### search_input_controller.js
Handles search input clear functionality.

**Targets:**
- `input` - The search input field
- `clearButton` - The clear button

**Actions:**
- `clear` - Clears the input and refocuses
- `toggleClearButton` - Shows/hides clear button based on input value

### text_area_controller.js
Handles textarea auto-expansion.

**Targets:**
- `textarea` - The textarea element

**Actions:**
- `autoExpand` - Expands textarea to fit content

## Testing

All components have comprehensive Minitest test coverage in `test/components/flat_pack/`:
- Rendering with various parameters
- Accessibility attributes
- Error states
- Security (XSS prevention, attribute sanitization)
- Custom classes and data attributes
- Required and disabled states

Run tests:
```bash
bin/rails test test/components/flat_pack/text_input_component_test.rb
bin/rails test test/components/flat_pack/password_input_component_test.rb
# ... etc
```

## Browser Compatibility

All components use standard HTML5 input types and are compatible with:
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Mobile)

## Contributing

When adding new input components:
1. Extend `FlatPack::BaseComponent`
2. Use the `flat-pack-input` base CSS class
3. Include comprehensive parameter validation
4. Add accessibility attributes (ARIA, labels)
5. Use `AttributeSanitizer` for security
6. Write comprehensive tests
7. Follow the existing component patterns
