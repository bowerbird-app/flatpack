# Button Dropdown Component

The Button Dropdown component provides an accessible dropdown menu triggered by a button, with full keyboard navigation support.

## Basic Usage

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions") do |dropdown| %>
  <% dropdown.with_menu_item(text: "Edit", href: "#") %>
  <% dropdown.with_menu_item(text: "Delete", href: "#") %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | required | Button text |
| `style` | Symbol | `:primary` | Visual style (`:primary`, `:secondary`, `:ghost`, `:success`, `:warning`) |
| `size` | Symbol | `:md` | Button size (`:sm`, `:md`, `:lg`) |
| `icon` | String | `nil` | Icon name to display in button |
| `disabled` | Boolean | `false` | Disable dropdown interaction |
| `position` | Symbol | `:bottom_right` | Menu position (`:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`) |
| `max_height` | String | `"384px"` | Maximum height of dropdown menu |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Content Methods

### Adding Items

Use `with_menu_item` to add menu items:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions") do |dropdown| %>
  <% dropdown.with_menu_item(text: "Edit", href: "/edit") %>
  <% dropdown.with_menu_item(text: "Delete", href: "/delete") %>
<% end %>
```

#### Item Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | required | Item text |
| `href` | String | `nil` | URL (renders as link if provided) |
| `icon` | String | `nil` | Icon name to display |
| `badge` | String | `nil` | Badge text (e.g., notification count) |
| `disabled` | Boolean | `false` | Disable item interaction |
| `destructive` | Boolean | `false` | Apply destructive styling (red) |

### Adding Dividers

Use `with_menu_divider` to add visual separators:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "File") do |dropdown| %>
  <% dropdown.with_menu_item(text: "New", href: "#") %>
  <% dropdown.with_menu_item(text: "Open", href: "#") %>
  <% dropdown.with_menu_divider %>
  <% dropdown.with_menu_item(text: "Exit", href: "#") %>
<% end %>
```

## Button Styles

Dropdown buttons support all standard button styles:

### Primary (Default)

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions", style: :primary) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Save", href: "#") %>
<% end %>
```

### Secondary

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Options", style: :secondary) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Settings", href: "#") %>
<% end %>
```

### Ghost

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "More", style: :ghost) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Help", href: "#") %>
<% end %>
```

### Success

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Create", style: :success) do |dropdown| %>
  <% dropdown.with_menu_item(text: "New Project", href: "#") %>
<% end %>
```

### Warning

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Danger", style: :warning) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Delete All", href: "#") %>
<% end %>
```

## Button Sizes

Dropdowns come in three sizes:

### Small

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Small", size: :sm) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option", href: "#") %>
<% end %>
```

### Medium (Default)

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Medium", size: :md) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option", href: "#") %>
<% end %>
```

### Large

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Large", size: :lg) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option", href: "#") %>
<% end %>
```

## Menu Positioning

Control where the dropdown menu appears relative to the trigger button:

### Bottom Right (Default)

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Menu", position: :bottom_right) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option 1", href: "#") %>
<% end %>
```

### Bottom Left

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Menu", position: :bottom_left) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option 1", href: "#") %>
<% end %>
```

### Top Right

Opens upward, useful when the dropdown is near the bottom of the viewport:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Menu", position: :top_right) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option 1", href: "#") %>
<% end %>
```

### Top Left

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Menu", position: :top_left) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Option 1", href: "#") %>
<% end %>
```

## Items with Icons

Add icons to menu items for better visual clarity:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions") do |dropdown| %>
  <% dropdown.with_menu_item(text: "Edit", icon: "edit", href: "#") %>
  <% dropdown.with_menu_item(text: "Copy", icon: "copy", href: "#") %>
  <% dropdown.with_menu_item(text: "Delete", icon: "trash", href: "#") %>
<% end %>
```

## Items with Badges

Display notification counts or status indicators:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Notifications") do |dropdown| %>
  <% dropdown.with_menu_item(text: "Messages", icon: "mail", badge: "12", href: "#") %>
  <% dropdown.with_menu_item(text: "Alerts", icon: "bell", badge: "3", href: "#") %>
<% end %>
```

## Disabled Items

Mark certain items as unavailable:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "File") do |dropdown| %>
  <% dropdown.with_menu_item(text: "New", href: "#") %>
  <% dropdown.with_menu_item(text: "Save", disabled: true) %>
  <% dropdown.with_menu_item(text: "Save As", disabled: true) %>
<% end %>
```

## Destructive Actions

Highlight dangerous actions with destructive styling:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Manage") do |dropdown| %>
  <% dropdown.with_menu_item(text: "Edit", href: "#") %>
  <% dropdown.with_menu_item(text: "Archive", href: "#") %>
  <% dropdown.with_menu_divider %>
  <% dropdown.with_menu_item(text: "Delete", destructive: true, href: "#") %>
<% end %>
```

## Button with Icon

Add an icon to the dropdown trigger button:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Settings", icon: "settings") do |dropdown| %>
  <% dropdown.with_menu_item(text: "Profile", href: "#") %>
  <% dropdown.with_menu_item(text: "Preferences", href: "#") %>
<% end %>
```

## Disabled Dropdown

Disable the entire dropdown:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions", disabled: true) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Edit", href: "#") %>
  <% dropdown.with_menu_item(text: "Delete", href: "#") %>
<% end %>
```

## Maximum Height

Control the maximum height of the dropdown menu (useful for long lists):

```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Long List", max_height: "200px") do |dropdown| %>
  <% 20.times do |i| %>
    <% dropdown.with_menu_item(text: "Item #{i + 1}", href: "#") %>
  <% end %>
<% end %>
```

## Complex Example

A comprehensive example combining multiple features:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "Account",
  icon: "user",
  style: :secondary,
  size: :md,
  position: :bottom_right
) do |dropdown| %>
  <% dropdown.with_menu_item(text: "Profile", icon: "user", href: profile_path) %>
  <% dropdown.with_menu_item(text: "Settings", icon: "settings", href: settings_path) %>
  <% dropdown.with_menu_item(text: "Messages", icon: "mail", badge: "5", href: messages_path) %>
  <% dropdown.with_menu_divider %>
  <% dropdown.with_menu_item(text: "Billing", icon: "credit-card", href: billing_path) %>
  <% dropdown.with_menu_divider %>
  <% dropdown.with_menu_item(text: "Sign out", icon: "log-out", href: signout_path) %>
<% end %>
```

## Accessibility

The Button Dropdown component follows accessibility best practices:

- Uses proper ARIA attributes (`aria-haspopup`, `aria-expanded`)
- Full keyboard navigation support
- Focus management
- Proper semantic HTML with `role="menu"` and `role="menuitem"`
- Screen reader announcements

### Keyboard Support

- `Enter` / `Space` - Toggle dropdown
- `Escape` - Close dropdown
- `↑` / `↓` - Navigate items
- `Home` - First item
- `End` - Last item
- `Tab` - Close dropdown and move to next focusable element

## Styling

### CSS Variables

The dropdown inherits button colors and uses theme variables:

```css
@theme {
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.25 0.02 250);
  --color-border: oklch(0.90 0.01 250);
  --color-muted: oklch(0.96 0.01 250);
  --color-destructive: oklch(0.55 0.22 25);
  --radius-md: 0.375rem;
  --radius-sm: 0.25rem;
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}
```

## Testing

```ruby
require "test_helper"

class DropdownTest < ViewComponent::TestCase
  def test_renders_dropdown
    render_inline FlatPack::Button::Dropdown::Component.new(text: "Actions") do |dropdown|
      dropdown.with_menu_item(text: "Edit", href: "/edit")
      dropdown.with_menu_divider
      dropdown.with_menu_item(text: "Delete", href: "/delete")
    end
    
    assert_selector "button", text: "Actions"
    assert_selector "a[href='/edit']", text: "Edit"
    assert_selector "div[role='separator']"
    assert_selector "a[href='/delete']", text: "Delete"
  end
end
```

## JavaScript Controller

The dropdown uses a Stimulus controller (`button-dropdown`) that handles:

- Opening/closing on click
- Clicking outside to close
- Keyboard navigation
- Focus management
- Smooth transitions

## API Reference

```ruby
FlatPack::Button::Dropdown::Component.new(
  text: String,               # Required
  style: Symbol,              # Optional, default: :primary
  size: Symbol,               # Optional, default: :md
  icon: String,               # Optional, default: nil
  disabled: Boolean,          # Optional, default: false
  position: Symbol,           # Optional, default: :bottom_right
  max_height: String,         # Optional, default: "384px"
  **system_arguments          # Optional
) do |dropdown|
  dropdown.with_menu_item(
    text: String,             # Required
    href: String,             # Optional, default: nil
    icon: String,             # Optional, default: nil
    badge: String,            # Optional, default: nil
    disabled: Boolean,        # Optional, default: false
    destructive: Boolean      # Optional, default: false
  )
  
  dropdown.with_menu_divider
end
```

## Related Components

- [Button Component](button.md) - Standard buttons
- [Icon Component](../shared/icon.md) - Icons used in items
- [Badge Component](badge.md) - Badges for notification counts

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Button Component](button.md)
