# Input Components

FlatPack provides a comprehensive set of form input components with built-in accessibility, security, and mobile optimization.

## Component Types

**Text-based Inputs:**
- TextInput - Standard text field
- PasswordInput - Password field with show/hide toggle
- EmailInput - Email field with mobile keyboard optimization
- PhoneInput - Phone number field with numeric keyboard
- SearchInput - Search field with clear button
- TextArea - Multi-line text field with auto-expansion
- UrlInput - URL field with XSS protection
- NumberInput - Numeric input with min/max/step validation
- DateInput - Date picker with calendar
- FileInput - File upload with drag-and-drop and preview

**Selection Inputs:**
- Checkbox - Single checkbox for boolean values
- RadioGroup - Radio button group for single selection
- Select - Dropdown select with optional search functionality

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
| `value` | String/Number/Date | `nil` | Initial value |
| `placeholder` | String | `nil` | Placeholder text |
| `label` | String | `nil` | Accessible label text |
| `error` | String | `nil` | Error message to display |
| `disabled` | Boolean | `false` | Disabled state |
| `required` | Boolean | `false` | Required field |
| `rows` | Integer | `3` | Initial rows (TextArea only) |
| `character_count` | Boolean | `false` | Show live character count (TextArea only) |
| `min_characters` | Integer | `nil` | Minimum character threshold for warning color (TextArea only) |
| `max_characters` | Integer | `nil` | Maximum character threshold and counter format (TextArea only) |
| `min` | Number/String/Date | `nil` | Minimum value (NumberInput, DateInput) |
| `max` | Number/String/Date | `nil` | Maximum value (NumberInput, DateInput) |
| `step` | Number | `1` | Step increment (NumberInput only) |
| `accept` | String | `nil` | Allowed file types (FileInput only) |
| `multiple` | Boolean | `false` | Allow multiple files (FileInput only) |
| `max_size` | Integer | `nil` | Max file size in bytes (FileInput only) |
| `preview` | Boolean | `true` | Show image previews (FileInput only) |
| `checked` | Boolean | `false` | Checked state (Checkbox only) |
| `options` | Array | **(required for RadioGroup, Select)** | List of options (RadioGroup, Select only) |
| `searchable` | Boolean | `false` | Enable search filtering (Select only) |
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
  rows: 3,
  character_count: true,
  min_characters: 30,
  max_characters: 140
) %>
```

Auto-expanding based on content with Stimulus controller (`flat-pack--text-area`).

When `character_count` is enabled, the component renders a live character counter below the textarea.
- Counter is muted by default
- Counter switches to warning color when below `min_characters` or above `max_characters`
- Counter format is `current/max characters` when `max_characters` is provided

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

### NumberInput

Numeric input field with min/max/step validation.

```erb
<%= render FlatPack::NumberInput::Component.new(
  name: "quantity",
  label: "Quantity",
  placeholder: "Enter quantity",
  min: 0,
  max: 100,
  step: 1,
  required: true
) %>
```

**Features:**
- HTML5 number input with native validation
- Mobile numeric keyboard
- Step controls (increment/decrement)
- Min/max value constraints
- Decimal support with step parameter

**Additional Props:**
- `min`: Integer/Float - Minimum allowed value
- `max`: Integer/Float - Maximum allowed value
- `step`: Integer/Float - Step increment (default: 1)

### DateInput

Date input field with calendar picker and date formatting.

```erb
<%= render FlatPack::DateInput::Component.new(
  name: "birth_date",
  label: "Birth Date",
  placeholder: "Select date",
  min: "1900-01-01",
  max: Date.today.to_s,
  required: true
) %>
```

**Features:**
- Native date picker on modern browsers
- Mobile-optimized date selection
- Automatic date formatting (YYYY-MM-DD)
- Accepts Date, Time, DateTime objects
- Min/max date constraints

**Additional Props:**
- `min`: String/Date - Minimum allowed date
- `max`: String/Date - Maximum allowed date
- Automatically converts Date objects to YYYY-MM-DD format

### FileInput

File upload input with drag-and-drop, previews, and validation.

```erb
<%= render FlatPack::FileInput::Component.new(
  name: "document",
  label: "Upload Document",
  accept: "image/png,image/jpeg,application/pdf",
  multiple: true,
  max_size: 5_242_880, # 5MB in bytes
  preview: true,
  required: true
) %>
```

**Features:**
- Drag-and-drop file upload
- Image preview for uploaded images
- File type validation (accept attribute)
- Client-side file size validation
- Multiple file support
- Visual file list with remove buttons
- Blocks dangerous file types (.exe, .bat, .sh, .js, etc.)
- Stimulus controller for interactivity

**Additional Props:**
- `accept`: String - Comma-separated MIME types or extensions (e.g., "image/*", ".pdf,.doc")
- `multiple`: Boolean - Allow multiple file selection (default: false)
- `max_size`: Integer - Maximum file size in bytes (default: nil)
- `preview`: Boolean - Show image previews (default: true)

**Security Features:**
- Blocks dangerous executable file types
- Client-side size validation
- Secure file type checking
- No SVG preview (XSS risk)

**Stimulus Controller:**
Uses `flat-pack--file-input` controller for drag-and-drop, preview, and validation.

### Checkbox

Single checkbox input for boolean values or multi-selection.

```erb
<%= render FlatPack::Checkbox::Component.new(
  name: "terms",
  label: "I agree to the terms and conditions",
  value: "1",
  checked: false,
  required: true
) %>
```

**Features:**
- Single checkbox for yes/no options
- Custom checkbox value (defaults to "1")
- Accessible label association
- Visual focus indicators
- Error state styling

**Additional Props:**
- `value`: String - The value when checked (default: "1")
- `checked`: Boolean - Initial checked state (default: false)
- `label`: String - Label text displayed next to checkbox (optional)

**Example - Accept Terms:**
```erb
<%= render FlatPack::Checkbox::Component.new(
  name: "user[accept_terms]",
  label: "I agree to the Terms of Service and Privacy Policy",
  value: "1",
  required: true
) %>
```

**Example - Newsletter Subscription:**
```erb
<%= render FlatPack::Checkbox::Component.new(
  name: "user[subscribe]",
  label: "Send me product updates and newsletters",
  checked: @user.subscribe
) %>
```

### RadioGroup

Group of radio buttons for selecting a single option from multiple choices.

```erb
<%= render FlatPack::RadioGroup::Component.new(
  name: "size",
  label: "Select Size",
  options: ["Small", "Medium", "Large"],
  value: "Medium",
  required: true
) %>
```

**Features:**
- Single selection from multiple options
- Multiple option formats (strings, arrays, hashes)
- Individual option disable support
- Accessible fieldset/legend structure
- Group-level or per-option disabled state

**Option Formats:**

**String Array** - Simple labels and values:
```erb
<%= render FlatPack::RadioGroup::Component.new(
  name: "color",
  options: ["Red", "Blue", "Green"]
) %>
```

**Nested Array** - Custom labels and values:
```erb
<%= render FlatPack::RadioGroup::Component.new(
  name: "size",
  options: [
    ["Small (S)", "s"],
    ["Medium (M)", "m"],
    ["Large (L)", "l"]
  ]
) %>
```

**Hash Array** - Advanced options with individual control:
```erb
<%= render FlatPack::RadioGroup::Component.new(
  name: "plan",
  options: [
    { label: "Free Plan", value: "free", disabled: false },
    { label: "Pro Plan", value: "pro", disabled: false },
    { label: "Enterprise", value: "enterprise", disabled: true }
  ]
) %>
```

**Additional Props:**
- `options`: Array - Options as strings, nested arrays, or hashes (required)
- `value`: String - Currently selected value (optional)
- `label`: String - Group label displayed above options (optional)

**Example - T-Shirt Size Selection:**
```erb
<%= render FlatPack::RadioGroup::Component.new(
  name: "order[size]",
  label: "Choose your size",
  options: [
    ["Extra Small", "xs"],
    ["Small", "s"],
    ["Medium", "m"],
    ["Large", "l"],
    ["Extra Large", "xl"]
  ],
  value: @order.size,
  required: true
) %>
```

**Example - Payment Method:**
```erb
<%= render FlatPack::RadioGroup::Component.new(
  name: "payment[method]",
  label: "Payment Method",
  options: [
    { label: "Credit Card", value: "card" },
    { label: "PayPal", value: "paypal" },
    { label: "Bank Transfer", value: "bank" }
  ],
  value: @payment.method
) %>
```

### Select

Dropdown select input for choosing from a list of options. Supports both native and custom searchable variants.

```erb
<%= render FlatPack::Select::Component.new(
  name: "country",
  label: "Country",
  options: ["United States", "Canada", "Mexico"],
  placeholder: "Select a country",
  required: true
) %>
```

**Features:**
- Native HTML select (default)
- Custom searchable dropdown (with `searchable: true`)
- Multiple option formats (strings, arrays, hashes)
- Individual option disable support
- Customizable placeholder
- Keyboard navigation
- Search filtering (searchable mode)

**Option Formats:**

**String Array** - Simple labels and values:
```erb
<%= render FlatPack::Select::Component.new(
  name: "status",
  options: ["Active", "Pending", "Inactive"]
) %>
```

**Nested Array** - Custom labels and values:
```erb
<%= render FlatPack::Select::Component.new(
  name: "country",
  options: [
    ["United States", "US"],
    ["United Kingdom", "GB"],
    ["Canada", "CA"]
  ]
) %>
```

**Hash Array** - Advanced options with individual control:
```erb
<%= render FlatPack::Select::Component.new(
  name: "role",
  options: [
    { label: "Admin", value: "admin", disabled: false },
    { label: "Editor", value: "editor", disabled: false },
    { label: "Viewer", value: "viewer", disabled: true }
  ]
) %>
```

**Searchable Select:**

Enable search functionality with `searchable: true`:

```erb
<%= render FlatPack::Select::Component.new(
  name: "country",
  label: "Country",
  options: ["United States", "Canada", "Mexico", "Brazil", "Argentina"],
  searchable: true,
  placeholder: "Search for a country..."
) %>
```

When searchable is enabled:
- Renders a custom dropdown instead of native `<select>`
- Includes a search input field
- Filters options as you type
- Uses Stimulus controller (`flat-pack--select`)
- Stores value in a hidden input field

**Additional Props:**
- `options`: Array - Options as strings, nested arrays, or hashes (required)
- `value`: String - Currently selected value (optional)
- `label`: String - Label text displayed above select (optional)
- `placeholder`: String - Placeholder text (default: "Select an option")
- `searchable`: Boolean - Enable searchable dropdown (default: false)

**Example - Country Selection:**
```erb
<%= render FlatPack::Select::Component.new(
  name: "user[country]",
  label: "Country",
  options: [
    ["United States", "US"],
    ["United Kingdom", "GB"],
    ["Canada", "CA"],
    ["Australia", "AU"],
    ["Germany", "DE"]
  ],
  value: @user.country,
  placeholder: "Choose your country",
  required: true
) %>
```

**Example - Large Searchable List:**
```erb
<%= render FlatPack::Select::Component.new(
  name: "product[category_id]",
  label: "Category",
  options: @categories.map { |c| [c.name, c.id] },
  searchable: true,
  placeholder: "Search categories...",
  value: @product.category_id
) %>
```

**Example - Status with Disabled Options:**
```erb
<%= render FlatPack::Select::Component.new(
  name: "task[status]",
  label: "Task Status",
  options: [
    { label: "Open", value: "open" },
    { label: "In Progress", value: "in_progress" },
    { label: "Completed", value: "completed" },
    { label: "Archived", value: "archived", disabled: true }
  ],
  value: @task.status
) %>
```

**Stimulus Controller:**
Searchable mode uses `flat-pack--select` controller for dropdown behavior and search filtering.

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
  
  <%= render FlatPack::DateInput::Component.new(
    name: "user[birth_date]",
    label: "Birth Date",
    value: @user.birth_date,
    max: Date.today
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

### Product Form with Numbers and Files

```erb
<%= form_with model: @product do |f| %>
  <%= render FlatPack::TextInput::Component.new(
    name: "product[name]",
    label: "Product Name",
    value: @product.name,
    required: true
  ) %>

  <%= render FlatPack::NumberInput::Component.new(
    name: "product[price]",
    label: "Price (USD)",
    value: @product.price,
    min: 0.01,
    step: 0.01,
    placeholder: "0.00",
    required: true
  ) %>

  <%= render FlatPack::NumberInput::Component.new(
    name: "product[quantity]",
    label: "Stock Quantity",
    value: @product.quantity,
    min: 0,
    step: 1,
    required: true
  ) %>

  <%= render FlatPack::DateInput::Component.new(
    name: "product[available_from]",
    label: "Available From",
    value: @product.available_from,
    min: Date.today
  ) %>

  <%= render FlatPack::FileInput::Component.new(
    name: "product[images][]",
    label: "Product Images",
    accept: "image/png,image/jpeg,image/webp",
    multiple: true,
    max_size: 2_097_152, # 2MB
    preview: true,
    required: true
  ) %>

  <%= render FlatPack::TextArea::Component.new(
    name: "product[description]",
    label: "Description",
    value: @product.description,
    rows: 5
  ) %>

  <%= f.submit "Save Product" %>
<% end %>
```

### Event Registration Form

```erb
<%= form_with url: event_registrations_path do |f| %>
  <%= render FlatPack::TextInput::Component.new(
    name: "registration[full_name]",
    label: "Full Name",
    required: true
  ) %>

  <%= render FlatPack::EmailInput::Component.new(
    name: "registration[email]",
    label: "Email Address",
    required: true
  ) %>

  <%= render FlatPack::PhoneInput::Component.new(
    name: "registration[phone]",
    label: "Phone Number",
    required: true
  ) %>

  <%= render FlatPack::NumberInput::Component.new(
    name: "registration[attendees]",
    label: "Number of Attendees",
    min: 1,
    max: 10,
    step: 1,
    value: 1,
    required: true
  ) %>

  <%= render FlatPack::DateInput::Component.new(
    name: "registration[preferred_date]",
    label: "Preferred Date",
    min: Date.today,
    max: Date.today + 90.days,
    required: true
  ) %>

  <%= render FlatPack::FileInput::Component.new(
    name: "registration[resume]",
    label: "Upload Resume (Optional)",
    accept: ".pdf,.doc,.docx",
    max_size: 5_242_880 # 5MB
  ) %>

  <%= render FlatPack::TextArea::Component.new(
    name: "registration[notes]",
    label: "Special Requirements",
    placeholder: "Dietary restrictions, accessibility needs, etc.",
    rows: 3
  ) %>

  <%= render FlatPack::Button::Component.new(
    text: "Register",
    style: :primary
  ) %>
<% end %>
```

### User Preferences Form

```erb
<%= form_with model: @preferences do |f| %>
  <%= render FlatPack::Select::Component.new(
    name: "preferences[theme]",
    label: "Theme",
    options: ["Light", "Dark", "Auto"],
    value: @preferences.theme,
    required: true
  ) %>

  <%= render FlatPack::Select::Component.new(
    name: "preferences[language]",
    label: "Language",
    options: [
      ["English", "en"],
      ["Spanish", "es"],
      ["French", "fr"],
      ["German", "de"],
      ["Japanese", "ja"]
    ],
    value: @preferences.language,
    searchable: true
  ) %>

  <%= render FlatPack::RadioGroup::Component.new(
    name: "preferences[notification_frequency]",
    label: "Email Notifications",
    options: [
      ["Real-time", "realtime"],
      ["Daily Digest", "daily"],
      ["Weekly Summary", "weekly"],
      ["Never", "never"]
    ],
    value: @preferences.notification_frequency
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "preferences[newsletter]",
    label: "Subscribe to newsletter",
    checked: @preferences.newsletter
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "preferences[marketing_emails]",
    label: "Receive marketing emails and product updates",
    checked: @preferences.marketing_emails
  ) %>

  <%= render FlatPack::Button::Component.new(
    text: "Save Preferences",
    style: :primary
  ) %>
<% end %>
```

### E-commerce Order Form

```erb
<%= form_with model: @order do |f| %>
  <%= render FlatPack::TextInput::Component.new(
    name: "order[product_name]",
    label: "Product Name",
    value: @order.product_name,
    disabled: true
  ) %>

  <%= render FlatPack::Select::Component.new(
    name: "order[size]",
    label: "Size",
    options: [
      ["Extra Small", "xs"],
      ["Small", "s"],
      ["Medium", "m"],
      ["Large", "l"],
      ["Extra Large", "xl"]
    ],
    value: @order.size,
    required: true
  ) %>

  <%= render FlatPack::RadioGroup::Component.new(
    name: "order[color]",
    label: "Color",
    options: ["Black", "White", "Navy", "Gray"],
    value: @order.color,
    required: true
  ) %>

  <%= render FlatPack::NumberInput::Component.new(
    name: "order[quantity]",
    label: "Quantity",
    value: @order.quantity || 1,
    min: 1,
    max: 10,
    step: 1,
    required: true
  ) %>

  <%= render FlatPack::RadioGroup::Component.new(
    name: "order[shipping_method]",
    label: "Shipping Method",
    options: [
      { label: "Standard (5-7 days) - $5.99", value: "standard" },
      { label: "Express (2-3 days) - $12.99", value: "express" },
      { label: "Overnight - $24.99", value: "overnight" }
    ],
    value: @order.shipping_method,
    required: true
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "order[gift_wrap]",
    label: "Add gift wrapping (+$5.00)",
    checked: @order.gift_wrap
  ) %>

  <%= render FlatPack::TextArea::Component.new(
    name: "order[gift_message]",
    label: "Gift Message (Optional)",
    placeholder: "Add a personal message...",
    rows: 3
  ) %>

  <%= render FlatPack::Button::Component.new(
    text: "Place Order",
    style: :primary
  ) %>
<% end %>
```

### Survey Form

```erb
<%= form_with url: survey_responses_path do |f| %>
  <%= render FlatPack::RadioGroup::Component.new(
    name: "survey[satisfaction]",
    label: "How satisfied are you with our service?",
    options: [
      ["Very Satisfied", "5"],
      ["Satisfied", "4"],
      ["Neutral", "3"],
      ["Dissatisfied", "2"],
      ["Very Dissatisfied", "1"]
    ],
    required: true
  ) %>

  <%= render FlatPack::Select::Component.new(
    name: "survey[heard_about]",
    label: "How did you hear about us?",
    options: [
      "Search Engine",
      "Social Media",
      "Friend or Colleague",
      "Advertisement",
      "Blog or Article",
      "Other"
    ],
    placeholder: "Please select...",
    required: true
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "survey[recommend]",
    label: "I would recommend this service to others",
    value: "1"
  ) %>

  <%= render FlatPack::TextArea::Component.new(
    name: "survey[feedback]",
    label: "Additional Feedback",
    placeholder: "Tell us more about your experience...",
    rows: 5
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "survey[follow_up]",
    label: "I'm open to a follow-up conversation",
    value: "1"
  ) %>

  <%= render FlatPack::Button::Component.new(
    text: "Submit Survey",
    style: :primary
  ) %>
<% end %>
```

### Job Application Form

```erb
<%= form_with model: @application do |f| %>
  <div class="grid grid-cols-2 gap-4">
    <%= render FlatPack::TextInput::Component.new(
      name: "application[first_name]",
      label: "First Name",
      required: true
    ) %>

    <%= render FlatPack::TextInput::Component.new(
      name: "application[last_name]",
      label: "Last Name",
      required: true
    ) %>
  </div>

  <%= render FlatPack::EmailInput::Component.new(
    name: "application[email]",
    label: "Email Address",
    required: true
  ) %>

  <%= render FlatPack::PhoneInput::Component.new(
    name: "application[phone]",
    label: "Phone Number",
    required: true
  ) %>

  <%= render FlatPack::Select::Component.new(
    name: "application[position]",
    label: "Position Applying For",
    options: [
      ["Software Engineer", "software_engineer"],
      ["Product Manager", "product_manager"],
      ["Designer", "designer"],
      ["Marketing Manager", "marketing_manager"],
      ["Sales Representative", "sales_rep"]
    ],
    searchable: true,
    placeholder: "Select a position...",
    required: true
  ) %>

  <%= render FlatPack::RadioGroup::Component.new(
    name: "application[experience_level]",
    label: "Experience Level",
    options: [
      ["Entry Level (0-2 years)", "entry"],
      ["Mid Level (3-5 years)", "mid"],
      ["Senior (6-10 years)", "senior"],
      ["Lead/Principal (10+ years)", "lead"]
    ],
    required: true
  ) %>

  <%= render FlatPack::Select::Component.new(
    name: "application[location]",
    label: "Preferred Work Location",
    options: [
      { label: "Remote", value: "remote" },
      { label: "San Francisco, CA", value: "sf" },
      { label: "New York, NY", value: "nyc" },
      { label: "Austin, TX", value: "austin" },
      { label: "Hybrid", value: "hybrid" }
    ],
    required: true
  ) %>

  <%= render FlatPack::NumberInput::Component.new(
    name: "application[salary_expectation]",
    label: "Salary Expectation (USD)",
    placeholder: "Annual salary",
    min: 0,
    step: 1000
  ) %>

  <%= render FlatPack::DateInput::Component.new(
    name: "application[available_from]",
    label: "Available Start Date",
    min: Date.today,
    required: true
  ) %>

  <%= render FlatPack::FileInput::Component.new(
    name: "application[resume]",
    label: "Resume",
    accept: ".pdf,.doc,.docx",
    max_size: 5_242_880,
    required: true
  ) %>

  <%= render FlatPack::FileInput::Component.new(
    name: "application[cover_letter]",
    label: "Cover Letter (Optional)",
    accept: ".pdf,.doc,.docx",
    max_size: 5_242_880
  ) %>

  <%= render FlatPack::TextArea::Component.new(
    name: "application[why_join]",
    label: "Why do you want to join our team?",
    placeholder: "Tell us what excites you about this opportunity...",
    rows: 5,
    required: true
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "application[legally_authorized]",
    label: "I am legally authorized to work in the United States",
    required: true
  ) %>

  <%= render FlatPack::Checkbox::Component.new(
    name: "application[terms]",
    label: "I agree to the terms and conditions",
    required: true
  ) %>

  <%= render FlatPack::Button::Component.new(
    text: "Submit Application",
    style: :primary,
    class: "w-full"
  ) %>
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

- Uses semantic HTML (`<input>`, `<textarea>`, `<select>`, `<fieldset>`, `<legend>`)
- Proper label associations (for/id)
- Includes ARIA attributes for error states
- aria-invalid on inputs with errors
- aria-describedby linking to error messages
- Supports keyboard navigation
- Focus indicators with high contrast
- Disabled state properly communicated
- RadioGroup uses fieldset/legend for proper grouping
- Checkbox and radio inputs properly associated with labels

### Keyboard Support

**Text Inputs, Select:**
- `Tab` - Focus next input
- `Shift+Tab` - Focus previous input
- Standard text input behavior

**Checkbox:**
- `Space` - Toggle checkbox
- `Tab` / `Shift+Tab` - Navigate between inputs

**RadioGroup:**
- `Tab` - Focus radio group
- `Arrow Keys` - Navigate between radio options
- `Space` - Select focused radio option

**Select (Searchable):**
- `Tab` - Focus select trigger
- `Enter` / `Space` - Open dropdown
- `Arrow Keys` - Navigate options
- `Enter` - Select option
- `Escape` - Close dropdown
- `Type` - Search/filter options

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

# TextArea (adds rows and character count parameters)
FlatPack::TextArea::Component.new(
  name: String,               # Required
  rows: Integer,              # Optional, default: 3
  character_count: Boolean,   # Optional, default: false
  min_characters: Integer,    # Optional, default: nil
  max_characters: Integer,    # Optional, default: nil
  # ... same parameters as above
)

# NumberInput (adds min, max, step parameters)
FlatPack::NumberInput::Component.new(
  name: String,               # Required
  value: Number,              # Optional, default: nil
  min: Number,                # Optional, default: nil
  max: Number,                # Optional, default: nil
  step: Number,               # Optional, default: 1
  placeholder: String,        # Optional, default: nil
  label: String,              # Optional, default: nil
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
)

# DateInput (adds min, max parameters, value accepts Date/Time)
FlatPack::DateInput::Component.new(
  name: String,               # Required
  value: String/Date/Time,    # Optional, default: nil (auto-converts to YYYY-MM-DD)
  min: String/Date,           # Optional, default: nil
  max: String/Date,           # Optional, default: nil
  placeholder: String,        # Optional, default: nil
  label: String,              # Optional, default: nil
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
)

# FileInput (adds accept, multiple, max_size, preview parameters)
FlatPack::FileInput::Component.new(
  name: String,               # Required
  accept: String,             # Optional, default: nil (e.g., "image/*", ".pdf,.doc")
  multiple: Boolean,          # Optional, default: false
  max_size: Integer,          # Optional, default: nil (bytes)
  preview: Boolean,           # Optional, default: true
  label: String,              # Optional, default: nil
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
)

# Checkbox
FlatPack::Checkbox::Component.new(
  name: String,               # Required
  value: String,              # Optional, default: "1"
  checked: Boolean,           # Optional, default: false
  label: String,              # Optional, default: nil
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
)

# RadioGroup (adds options parameter)
FlatPack::RadioGroup::Component.new(
  name: String,               # Required
  options: Array,             # Required (strings, nested arrays, or hashes)
  value: String,              # Optional, default: nil (selected value)
  label: String,              # Optional, default: nil (group label)
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false (applies to all options)
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
)

# Select (adds options, placeholder, searchable parameters)
FlatPack::Select::Component.new(
  name: String,               # Required
  options: Array,             # Required (strings, nested arrays, or hashes)
  value: String,              # Optional, default: nil (selected value)
  label: String,              # Optional, default: nil
  placeholder: String,        # Optional, default: "Select an option"
  searchable: Boolean,        # Optional, default: false (enables custom searchable dropdown)
  error: String,              # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  required: Boolean,          # Optional, default: false
  **system_arguments          # Optional
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

## Switch Component

The Switch component is a modern toggle switch for boolean on/off states, providing an alternative to checkboxes for settings and preferences.

### Basic Usage

```erb
<%= render FlatPack::Switch::Component.new(
  name: "notifications",
  label: "Enable notifications"
) %>
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `name` | String | **required** | Form field name |
| `checked` | Boolean | `false` | Initial state |
| `label` | String | `nil` | Label text |
| `error` | String | `nil` | Error message |
| `disabled` | Boolean | `false` | Disabled state |
| `required` | Boolean | `false` | Required field |
| `size` | Symbol | `:md` | Switch size (`:sm`, `:md`, `:lg`) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

### Visual States

**OFF State:** Circle on left, gray background  
**ON State:** Circle on right, primary color background

The switch includes:
- Smooth sliding animation
- Clear on/off visual states
- Haptic feel with visual feedback on click
- Label appearing to the right

### Sizes

```erb
# Small
<%= render FlatPack::Switch::Component.new(
  name: "setting",
  label: "Small switch",
  size: :sm
) %>

# Medium (default)
<%= render FlatPack::Switch::Component.new(
  name: "setting",
  label: "Medium switch",
  size: :md
) %>

# Large
<%= render FlatPack::Switch::Component.new(
  name: "setting",
  label: "Large switch",
  size: :lg
) %>
```

### States

```erb
# Checked
<%= render FlatPack::Switch::Component.new(
  name: "notifications",
  label: "Notifications",
  checked: true
) %>

# Disabled
<%= render FlatPack::Switch::Component.new(
  name: "notifications",
  label: "Notifications (disabled)",
  disabled: true
) %>

# With error
<%= render FlatPack::Switch::Component.new(
  name: "notifications",
  label: "Notifications",
  error: "This field is required"
) %>
```

### Behavior

- Uses hidden checkbox + styled switch UI
- Click anywhere on switch to toggle
- Keyboard accessible (Space/Enter to toggle)
- Smooth animation on state change
- Focus ring on keyboard focus

### Accessibility

- `role="switch"` on the control
- `aria-checked` attribute reflects state
- Proper label associations
- Full keyboard navigation support
- Visual and ARIA state communication

### Use Cases

**Settings and Preferences:**
```erb
<%= render FlatPack::Switch::Component.new(
  name: "email_notifications",
  label: "Email notifications",
  checked: true
) %>
<%= render FlatPack::Switch::Component.new(
  name: "sms_notifications",
  label: "SMS notifications"
) %>
```

**Feature Toggles:**
```erb
<%= render FlatPack::Switch::Component.new(
  name: "dark_mode",
  label: "Dark mode",
  checked: user.dark_mode_enabled?
) %>
```

**Privacy Controls:**
```erb
<%= render FlatPack::Switch::Component.new(
  name: "public_profile",
  label: "Make profile public",
  checked: false
) %>
```

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Security Policy](../../SECURITY.md)
