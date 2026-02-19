# Breadcrumb Component

A navigation component that shows the user's current location in the site hierarchy and allows them to navigate back to parent pages.

The Breadcrumb component follows Flatpack's patterns with `renders_many :items` for flexible composition. It provides multiple separator styles, support for icons, item collapsing, and full accessibility compliance.

## Basic Usage

### Simple Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: root_path) %>
  <% breadcrumb.item(text: "Products", href: products_path) %>
  <% breadcrumb.item(text: "Electronics", href: electronics_path) %>
  <% breadcrumb.item(text: "Laptops") %> <!-- Current page, no link -->
<% end %>
```

### Using Array of Items

For simple cases, you can pass an array of items:

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  items: [
    { text: "Home", href: "/" },
    { text: "Products", href: "/products" },
    { text: "Item" }
  ]
) %>
```

## Props

### Main Component Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `separator` | Symbol | `:chevron` | Separator style (`:chevron`, `:slash`, `:arrow`, `:dot`, `:custom`) |
| `separator_icon` | String | `nil` | Custom icon name when `separator: :custom` |
| `show_back` | Boolean | `false` | Auto-prepend a back link as the first breadcrumb item |
| `back_text` | String | `"Back"` | Back link text |
| `back_icon` | String | `"chevron-left"` | Back link icon |
| `back_fallback_url` | String | `"/"` | URL used when no previous page is available |
| `show_home` | Boolean | `false` | Auto-prepend home icon/link |
| `home_url` | String | `"/"` | Home link URL |
| `home_text` | String | `"Home"` | Home link text |
| `home_icon` | String | `"home"` | Home icon name |
| `max_items` | Integer | `nil` | Maximum items before collapsing |
| `items` | Array | `nil` | Array of item hashes for convenience |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

### Item Component Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | (required) | Link text |
| `href` | String | `nil` | URL (nil = current page, no link) |
| `icon` | String | `nil` | Icon name (optional) |

## Separator Styles

### Built-in Separators

```erb
<!-- Chevron (default) -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :chevron) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
  <% breadcrumb.item(text: "Products") %>
<% end %>
<!-- Result: Home › Products -->

<!-- Slash -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :slash) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
  <% breadcrumb.item(text: "Products") %>
<% end %>
<!-- Result: Home / Products -->

<!-- Arrow -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :arrow) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
  <% breadcrumb.item(text: "Products") %>
<% end %>
<!-- Result: Home → Products -->

<!-- Dot -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :dot) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
  <% breadcrumb.item(text: "Products") %>
<% end %>
<!-- Result: Home • Products -->
```

### Custom Icon Separator

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  separator: :custom,
  separator_icon: "chevron-right"
) do |breadcrumb| %>
  <% breadcrumb.item(text: "Dashboard", href: dashboard_path) %>
  <% breadcrumb.item(text: "Reports") %>
<% end %>
```

## Home Item

## Back Item

### Auto-prepend Back Item

```erb
<%= render FlatPack::Breadcrumb::Component.new(show_back: true) do |breadcrumb| %>
  <% breadcrumb.item(text: "Settings", href: settings_path) %>
  <% breadcrumb.item(text: "Profile") %>
<% end %>
```

When enabled, the back item is always the first link and uses the previous page URL (referer). If no previous page is available, it falls back to `back_fallback_url`.

### Custom Back Configuration

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  show_back: true,
  back_text: "Go Back",
  back_icon: "arrow-uturn-left",
  back_fallback_url: "/dashboard"
) do |breadcrumb| %>
  <% breadcrumb.item(text: "Reports") %>
<% end %>
```

### Auto-prepend Home Item

```erb
<%= render FlatPack::Breadcrumb::Component.new(show_home: true) do |breadcrumb| %>
  <% breadcrumb.item(text: "Settings", href: settings_path) %>
  <% breadcrumb.item(text: "Profile") %>
<% end %>
<!-- Result: 🏠 Home › Settings › Profile -->
```

### Custom Home Configuration

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  show_home: true,
  home_url: "/dashboard",
  home_text: "Dashboard",
  home_icon: "house"
) do |breadcrumb| %>
  <% breadcrumb.item(text: "Reports") %>
<% end %>
```

## Item Collapsing

When you have many breadcrumb items, you can collapse middle items to save space:

```erb
<%= render FlatPack::Breadcrumb::Component.new(max_items: 3) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
  <% breadcrumb.item(text: "Level 1", href: "/l1") %>
  <% breadcrumb.item(text: "Level 2", href: "/l2") %>
  <% breadcrumb.item(text: "Level 3", href: "/l3") %>
  <% breadcrumb.item(text: "Current") %>
<% end %>
<!-- Result: Home › ... › Level 3 › Current -->
```

The component keeps:
- First item
- Ellipsis (`...`)
- Last `(max_items - 1)` items

## Icons in Items

Add icons to breadcrumb items for better visual context:

```erb
<%= render FlatPack::Breadcrumb::Component.new do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/", icon: "home") %>
  <% breadcrumb.item(text: "Settings", href: "/settings", icon: "cog") %>
  <% breadcrumb.item(text: "Profile", icon: "user") %>
<% end %>
```

**Icon Reference:** Icons use [Heroicons](https://heroicons.com) by default. Use the icon name without prefixes (e.g., `"home"`, `"cog"`, `"user"`). For custom separator icons, any Heroicon name can be used with the `separator_icon` prop.

## System Arguments

### Custom Classes

```erb
<%= render FlatPack::Breadcrumb::Component.new(class: "mb-4 custom-breadcrumb") do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
<% end %>
```

Classes are merged using `tailwind_merge`, so Tailwind utilities override correctly.

### Data Attributes

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  data: { testid: "main-breadcrumb" },
  id: "breadcrumb-nav"
) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
<% end %>
```

### ARIA Attributes

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  aria: { label: "Navigation path" }
) do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
<% end %>
```

## Accessibility

The Breadcrumb component is fully accessible:

- ✅ **Semantic HTML**: Uses `<nav>`, `<ol>`, and `<li>` elements
- ✅ **ARIA labels**: `aria-label="Breadcrumb"` on navigation
- ✅ **Current page**: `aria-current="page"` on current item
- ✅ **Hidden separators**: `aria-hidden="true"` on separator elements
- ✅ **Keyboard navigation**: All links are keyboard accessible

### Keyboard Support

- `Tab` - Focus next link
- `Shift+Tab` - Focus previous link
- `Enter` - Activate link

## Examples

### Rails Helper Integration

Create a helper for controller-based breadcrumbs:

```ruby
# app/helpers/breadcrumb_helper.rb
module BreadcrumbHelper
  def breadcrumb_from_controller
    crumbs = controller.breadcrumbs || []
    
    render FlatPack::Breadcrumb::Component.new(show_home: true) do |breadcrumb|
      crumbs.each do |crumb|
        breadcrumb.item(text: crumb[:text], href: crumb[:href])
      end
    end
  end
end

# In controller
class ProductsController < ApplicationController
  before_action :set_breadcrumbs
  
  def show
    @breadcrumbs = [
      { text: "Products", href: products_path },
      { text: @product.category.name, href: category_path(@product.category) },
      { text: @product.name, href: nil }
    ]
  end
  
  def breadcrumbs
    @breadcrumbs
  end
end

# In view
<%= breadcrumb_from_controller %>
```

### E-commerce Category Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new(show_home: true) do |breadcrumb| %>
  <% breadcrumb.item(text: "Products", href: products_path) %>
  <% breadcrumb.item(text: @category.name, href: category_path(@category)) %>
  <% breadcrumb.item(text: @product.name) %>
<% end %>
```

### Blog Post Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new(separator: :slash) do |breadcrumb| %>
  <% breadcrumb.item(text: "Blog", href: blog_path) %>
  <% breadcrumb.item(text: @post.category.name, href: blog_category_path(@post.category)) %>
  <% breadcrumb.item(text: @post.title) %>
<% end %>
```

### Admin Dashboard Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  show_home: true,
  home_url: admin_path,
  home_text: "Dashboard",
  home_icon: "dashboard"
) do |breadcrumb| %>
  <% breadcrumb.item(text: "Users", href: admin_users_path) %>
  <% breadcrumb.item(text: @user.name) %>
<% end %>
```

### Full Width Container

```erb
<div class="container mx-auto px-4 py-6">
  <%= render FlatPack::Breadcrumb::Component.new(
    separator: :chevron,
    show_home: true,
    class: "mb-6"
  ) do |breadcrumb| %>
    <% breadcrumb.item(text: "Products", href: products_path, icon: "package") %>
    <% breadcrumb.item(text: "Electronics", href: electronics_path, icon: "laptop") %>
    <% breadcrumb.item(text: "Laptops", href: laptops_path) %>
    <% breadcrumb.item(text: @product.name) %>
  <% end %>
  
  <div class="content">
    <!-- Page content here -->
  </div>
</div>
```

## Styling

### CSS Variables

The component uses the following CSS variables from the Flatpack theme:

- `--color-foreground` - Current page text color
- `--color-muted-foreground` - Link and separator color
- `--color-background` - Background color (inherited)

Customize breadcrumb colors by overriding CSS variables:

```css
@theme {
  --color-foreground: oklch(0.2 0.02 250);
  --color-muted-foreground: oklch(0.5 0.02 250);
}
```

## Testing

```ruby
# test/components/breadcrumb_component_test.rb
require "test_helper"

class BreadcrumbComponentTest < ViewComponent::TestCase
  def test_renders_breadcrumb_with_items
    render_inline FlatPack::Breadcrumb::Component.new do |breadcrumb|
      breadcrumb.item(text: "Home", href: "/")
      breadcrumb.item(text: "Products")
    end
    
    assert_selector "nav[aria-label='Breadcrumb']"
    assert_selector "a", text: "Home"
    assert_selector "span[aria-current='page']", text: "Products"
  end
  
  def test_renders_with_array_items
    render_inline FlatPack::Breadcrumb::Component.new(
      items: [
        { text: "Home", href: "/" },
        { text: "Products" }
      ]
    )
    
    assert_selector "nav"
    assert_selector "a", text: "Home"
  end
end
```

## API Reference

```ruby
FlatPack::Breadcrumb::Component.new(
  separator: Symbol,          # Optional, default: :chevron (:chevron, :slash, :arrow, :dot, :custom)
  separator_icon: String,     # Optional, default: nil
  show_home: Boolean,         # Optional, default: false
  home_url: String,           # Optional, default: "/"
  home_text: String,          # Optional, default: "Home"
  home_icon: String,          # Optional, default: "home"
  max_items: Integer,         # Optional, default: nil
  items: Array,               # Optional, default: nil
  **system_arguments          # Optional
) do |breadcrumb|
  breadcrumb.item(
    text: String,             # Required
    href: String,             # Optional, default: nil
    icon: String              # Optional, default: nil
  )
end
```

### System Arguments

- `class`: String - Additional CSS classes
- `data`: Hash - Data attributes
- `aria`: Hash - ARIA attributes
- `id`: String - Element ID
- Any other valid HTML attribute

## Related Components

- [Link Component](link.md) - Breadcrumb items use Link component for navigation
- [Button Component](button.md) - For action buttons in layouts with breadcrumbs
- [Card Component](card.md) - Cards often appear below breadcrumbs in page layouts

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Installation Guide](../installation.md)
