# Alert Component

The Alert component displays prominent notifications and messages for user feedback (success, errors, warnings, info).

## Basic Usage

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Success!",
  description: "Your changes have been saved."
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | String | `nil` | Alert title |
| `description` | String | `nil` | Alert message |
| `variant` | Symbol | `:info` | Visual variant (`:info`, `:success`, `:warning`, `:danger`) |
| `dismissible` | Boolean | `false` | Show close button |
| `icon` | Boolean | `true` | Show variant icon |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Variants

### Info (Default)
General information and updates.

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Information",
  description: "Your profile has been updated.",
  variant: :info
) %>
```

### Success
Successful operations and confirmations.

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Success!",
  description: "Your changes have been saved.",
  variant: :success
) %>
```

### Warning
Warnings and cautions.

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Warning",
  description: "This action cannot be undone.",
  variant: :warning
) %>
```

### Danger
Errors and critical issues.

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Error",
  description: "Failed to save changes. Please try again.",
  variant: :danger
) %>
```

## Icon Display

By default, alerts show an icon based on the variant. You can disable this:

```erb
<%= render FlatPack::Alert::Component.new(
  title: "No Icon",
  description: "This alert has no icon.",
  icon: false
) %>
```

## Dismissible Alerts

Add a close button to allow users to dismiss the alert:

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Notice",
  description: "Click X to dismiss this message.",
  variant: :info,
  dismissible: true
) %>
```

When `dismissible: true`, the alert:
- Shows a close button with proper accessibility labels
- Automatically includes the Stimulus `alert` controller
- Fades out with animation when dismissed
- Emits a custom `alert:dismissed` event
- Removes itself from the DOM after animation

## Rich Content with Slots

Use the content block for rich HTML content with buttons and links:

```erb
<%= render FlatPack::Alert::Component.new(variant: :success) do %>
  <div class="flex items-center justify-between gap-3">
    <div>
      <strong>Success!</strong> You've completed the tutorial.
    </div>
    <%= render FlatPack::Button::Component.new(text: "Continue →", size: :sm, style: :secondary) %>
  </div>
<% end %>
```

### With Multiple Actions

```erb
<%= render FlatPack::Alert::Component.new(variant: :warning) do %>
  <div class="flex items-center justify-between gap-3">
    <div>
      <strong>Confirm Action</strong>
      <p class="text-sm">This will permanently delete your data.</p>
    </div>
    <div class="flex gap-2">
      <%= render FlatPack::Button::Component.new(text: "Delete", size: :sm, style: :warning) %>
      <%= render FlatPack::Button::Component.new(text: "Cancel", size: :sm, style: :ghost) %>
    </div>
  </div>
<% end %>
```

When using slots, the `title` and `description` props are ignored.

## Title Only

```erb
<%= render FlatPack::Alert::Component.new(title: "Quick message") %>
```

## Description Only

```erb
<%= render FlatPack::Alert::Component.new(
  description: "Your session will expire in 5 minutes."
) %>
```

## Stimulus Controller

The alert controller is automatically attached when `dismissible: true`.

### Events

**alert:dismissed** - Fired when the alert is dismissed

```javascript
document.addEventListener('alert:dismissed', (event) => {
  console.log('Alert dismissed:', event.detail.element)
})
```

### Targets

- `alert` - The alert container element

### Actions

- `dismiss` - Close the alert with fade animation

## Use Cases

### Form Success Messages
```erb
<%= render FlatPack::Alert::Component.new(
  title: "Form submitted",
  description: "We'll process your request shortly.",
  variant: :success,
  dismissible: true
) %>
```

### Error Messages
```erb
<%= render FlatPack::Alert::Component.new(
  title: "Validation Error",
  description: "Please check the form for errors.",
  variant: :danger
) %>
```

### Warning Prompts
```erb
<%= render FlatPack::Alert::Component.new(
  title: "Before you proceed",
  description: "This will permanently delete your data.",
  variant: :warning
) %>
```

### Informational Banners
```erb
<%= render FlatPack::Alert::Component.new(
  title: "New Feature",
  description: "Check out our updated dashboard design!",
  variant: :info,
  dismissible: true
) %>
```

### Flash Messages
```erb
<% if flash[:notice] %>
  <%= render FlatPack::Alert::Component.new(
    description: flash[:notice],
    variant: :success,
    dismissible: true
  ) %>
<% end %>

<% if flash[:alert] %>
  <%= render FlatPack::Alert::Component.new(
    description: flash[:alert],
    variant: :danger,
    dismissible: true
  ) %>
<% end %>
```

## System Arguments

All standard HTML attributes are supported via `**system_arguments`:

```erb
<%= render FlatPack::Alert::Component.new(
  title: "Custom",
  description: "With custom attributes",
  id: "my-alert",
  class: "mb-4",
  data: { testid: "notification" },
  aria: { live: "polite" }
) %>
```

## Accessibility

- Uses `role="alert"` for screen reader announcements
- Live region for dynamic alerts
- Keyboard accessible close button with proper focus management
- Descriptive ARIA labels on interactive elements
- Visual indicators (color + icon + text) for all variants
- Proper color contrast ratios

## Styling

Alerts use:
- Colored left border (4px accent)
- Subtle background with dark mode support
- Rounded corners following design system
- Proper spacing and typography
- Icon sizing relative to text

## Testing

```ruby
# test/components/flat_pack/alert_component_test.rb
render_inline(FlatPack::Alert::Component.new(
  title: "Test",
  variant: :success,
  dismissible: true
))

assert_selector "div[role='alert']"
assert_selector "h3", text: "Test"
assert_selector "button[data-action='alert#dismiss']"
```
