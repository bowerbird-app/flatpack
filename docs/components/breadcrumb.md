# Breadcrumb Component

A navigation component that shows the user's current location in the site hierarchy and allows them to navigate back to parent pages.

## Overview

The Breadcrumb component follows Flatpack's patterns with `renders_many :items` for flexible composition. It provides multiple separator styles, support for icons, item collapsing, and full accessibility compliance.

## Visual Example

```
Home > Products > Electronics > Laptops > MacBook Pro
```

## Basic Usage

### Simple Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: root_path) %>
  <% breadcrumb.with_item(text: "Products", href: products_path) %>
  <% breadcrumb.with_item(text: "Electronics", href: electronics_path) %>
  <% breadcrumb.with_item(text: "Laptops") %> <!-- Current page, no link -->
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

## Configuration Options

### Main Component Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `separator` | Symbol | `:chevron` | Separator style (`:chevron`, `:slash`, `:arrow`, `:dot`, `:custom`) |
| `separator_icon` | String | `nil` | Custom icon name when `separator: :custom` |
| `show_home` | Boolean | `false` | Auto-prepend home icon/link |
| `home_url` | String | `"/"` | Home link URL |
| `home_text` | String | `"Home"` | Home link text |
| `home_icon` | String | `"home"` | Home icon name |
| `max_items` | Integer | `nil` | Maximum items before collapsing |
| `items` | Array | `nil` | Array of item hashes for convenience |

### Item Component Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | (required) | Link text |
| `href` | String | `nil` | URL (nil = current page, no link) |
| `icon` | String | `nil` | Icon name (optional) |

## Separator Styles

### Built-in Separators

```erb
<!-- Chevron (default) -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :chevron) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
  <% breadcrumb.with_item(text: "Products") %>
<% end %>
<!-- Result: Home › Products -->

<!-- Slash -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :slash) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
  <% breadcrumb.with_item(text: "Products") %>
<% end %>
<!-- Result: Home / Products -->

<!-- Arrow -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :arrow) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
  <% breadcrumb.with_item(text: "Products") %>
<% end %>
<!-- Result: Home → Products -->

<!-- Dot -->
<%= render FlatPack::Breadcrumb::Component.new(separator: :dot) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
  <% breadcrumb.with_item(text: "Products") %>
<% end %>
<!-- Result: Home • Products -->
```

### Custom Icon Separator

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  separator: :custom,
  separator_icon: "chevron-right"
) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Dashboard", href: dashboard_path) %>
  <% breadcrumb.with_item(text: "Reports") %>
<% end %>
```

## Home Item

### Auto-prepend Home Item

```erb
<%= render FlatPack::Breadcrumb::Component.new(show_home: true) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Settings", href: settings_path) %>
  <% breadcrumb.with_item(text: "Profile") %>
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
  <% breadcrumb.with_item(text: "Reports") %>
<% end %>
```

## Item Collapsing

When you have many breadcrumb items, you can collapse middle items to save space:

```erb
<%= render FlatPack::Breadcrumb::Component.new(max_items: 3) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
  <% breadcrumb.with_item(text: "Level 1", href: "/l1") %>
  <% breadcrumb.with_item(text: "Level 2", href: "/l2") %>
  <% breadcrumb.with_item(text: "Level 3", href: "/l3") %>
  <% breadcrumb.with_item(text: "Current") %>
<% end %>
<!-- Result: Home › ... › Level 3 › Current -->
```

The component keeps:
- First item
- Ellipsis (`...`)
- Last `(max_items - 1)` items

## Icons in Items

```erb
<%= render FlatPack::Breadcrumb::Component.new do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/", icon: "home") %>
  <% breadcrumb.with_item(text: "Settings", href: "/settings", icon: "cog") %>
  <% breadcrumb.with_item(text: "Profile", icon: "user") %>
<% end %>
```

## Accessibility

The Breadcrumb component is fully accessible:

- ✅ **Semantic HTML**: Uses `<nav>`, `<ol>`, and `<li>` elements
- ✅ **ARIA labels**: `aria-label="Breadcrumb"` on navigation
- ✅ **Current page**: `aria-current="page"` on current item
- ✅ **Hidden separators**: `aria-hidden="true"` on separator elements
- ✅ **Keyboard navigation**: All links are keyboard accessible

## Styling

### Custom Classes

```erb
<%= render FlatPack::Breadcrumb::Component.new(class: "mb-4 custom-breadcrumb") do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
<% end %>
```

### Data Attributes

```erb
<%= render FlatPack::Breadcrumb::Component.new(
  data: { testid: "main-breadcrumb" },
  id: "breadcrumb-nav"
) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Home", href: "/") %>
<% end %>
```

## Integration Patterns

### Rails Helper Integration

Create a helper for controller-based breadcrumbs:

```ruby
# app/helpers/breadcrumb_helper.rb
module BreadcrumbHelper
  def breadcrumb_from_controller
    crumbs = controller.breadcrumbs || []
    
    render FlatPack::Breadcrumb::Component.new(show_home: true) do |breadcrumb|
      crumbs.each do |crumb|
        breadcrumb.with_item(text: crumb[:text], href: crumb[:href])
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

### With breadcrumbs_on_rails Gem

```ruby
def breadcrumb_component
  crumbs = breadcrumbs_trail
  
  render FlatPack::Breadcrumb::Component.new do |breadcrumb|
    crumbs.each do |crumb|
      breadcrumb.with_item(
        text: crumb.name,
        href: crumb.url
      )
    end
  end
end
```

### With gretel Gem

```ruby
def render_gretel_breadcrumbs
  crumbs = breadcrumb_links
  
  render FlatPack::Breadcrumb::Component.new(separator: :slash) do |breadcrumb|
    crumbs.each do |crumb|
      breadcrumb.with_item(
        text: crumb.text,
        href: crumb.url
      )
    end
  end
end
```

## Common Patterns

### E-commerce Category Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new(show_home: true) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Products", href: products_path) %>
  <% breadcrumb.with_item(text: @category.name, href: category_path(@category)) %>
  <% breadcrumb.with_item(text: @product.name) %>
<% end %>
```

### Blog Post Breadcrumb

```erb
<%= render FlatPack::Breadcrumb::Component.new(separator: :slash) do |breadcrumb| %>
  <% breadcrumb.with_item(text: "Blog", href: blog_path) %>
  <% breadcrumb.with_item(text: @post.category.name, href: blog_category_path(@post.category)) %>
  <% breadcrumb.with_item(text: @post.title) %>
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
  <% breadcrumb.with_item(text: "Users", href: admin_users_path) %>
  <% breadcrumb.with_item(text: @user.name) %>
<% end %>
```

## Complete Example

```erb
<div class="container mx-auto px-4 py-6">
  <%= render FlatPack::Breadcrumb::Component.new(
    separator: :chevron,
    show_home: true,
    class: "mb-6"
  ) do |breadcrumb| %>
    <% breadcrumb.with_item(text: "Products", href: products_path, icon: "package") %>
    <% breadcrumb.with_item(text: "Electronics", href: electronics_path, icon: "laptop") %>
    <% breadcrumb.with_item(text: "Laptops", href: laptops_path) %>
    <% breadcrumb.with_item(text: @product.name) %>
  <% end %>
  
  <div class="content">
    <!-- Page content here -->
  </div>
</div>
```

## CSS Variables

The component uses the following CSS variables from the Flatpack theme:

- `--color-foreground` - Current page text color
- `--color-muted-foreground` - Link and separator color
- `--color-background` - Background color (inherited)

## Browser Support

Works in all modern browsers that support:
- CSS Flexbox
- CSS Custom Properties (CSS Variables)
- SVG (for icons)

## See Also

- [Button Component](button.md)
- [Link Component](link.md)
- [Card Component](card.md)
