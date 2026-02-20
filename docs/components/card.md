# Card Component

The Card component renders a flexible container for displaying content with support for slots, styles, and clickable variants.

## Basic Usage

### Simple Card

```erb
<%= render FlatPack::Card::Component.new do %>
  <p>Card content goes here.</p>
<% end %>
```

### Card with Header and Body

```erb
<%= render FlatPack::Card::Component.new do |card| %>
  <% card.header do %>
    <h3>Card Title</h3>
  <% end %>
  
  <% card.body do %>
    <p>Card content goes here.</p>
  <% end %>
<% end %>
```

### Card with All Slots

```erb
<%= render FlatPack::Card::Component.new do |card| %>
  <% card.media do %>
    <%= image_tag "product.jpg", class: "w-full h-48 object-cover" %>
  <% end %>
  
  <% card.header do %>
    <h3 class="text-lg font-semibold">Product Name</h3>
  <% end %>
  
  <% card.body do %>
    <p class="text-sm text-gray-600">Product description goes here.</p>
  <% end %>
  
  <% card.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Add to Cart", style: :primary) %>
  <% end %>
<% end %>
```

### Media Slot (Edge-to-Edge Top Media)

Use `card.media(..., padding: :none)` when you want top media to extend flush to the card edges.

```erb
<%= render FlatPack::Card::Component.new(style: :default) do |card| %>
  <% card.media(aspect_ratio: "16/9", padding: :none) do %>
    <%= image_tag "product-hero.jpg", class: "w-full h-full object-cover", alt: "Product hero image" %>
  <% end %>

  <% card.body do %>
    <h3 class="text-lg font-semibold mb-2">Edge-to-Edge Media Card</h3>
    <p class="text-sm text-gray-600">The media fills the top area without container side or top spacing.</p>
  <% end %>
<% end %>
```

## Props

### Main Component

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `style` | Symbol | `:default` | Visual style of the card. Options: `:default`, `:elevated`, `:outlined`, `:flat`, `:interactive`, `:list` |
| `hover` | Symbol | `nil` | Standardized hover behavior. Options: `:none`, `:subtle`, `:strong` (or `nil` to use style defaults) |
| `padding` | Symbol | `:md` | Padding size. Options: `:none`, `:sm`, `:md`, `:lg` |
| `clickable` | Boolean | `false` | Makes the entire card clickable when combined with `href` |
| `href` | String | `nil` | URL to navigate to when card is clicked (requires `clickable: true`) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

### Slot Components

#### Header

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `divider` | Boolean | `true` | Show bottom border separator |

#### Body

No additional props. Accepts standard HTML attributes.

#### Footer

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `divider` | Boolean | `true` | Show top border separator |

#### Media

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `aspect_ratio` | String | `nil` | Aspect ratio for media content. Options: `"16/9"`, `"4/3"`, `"1/1"`, or any custom ratio like `"21/9"` |
| `padding` | Symbol | `:md` | Media inset spacing. Options: `:none`, `:sm`, `:md`, `:lg` |

## Styles

### Default

Standard card with background and border.

```erb
<%= render FlatPack::Card::Component.new(style: :default) do %>
  <p>Default card style</p>
<% end %>
```

### Elevated

Card with shadow, no border - ideal for featured content.

```erb
<%= render FlatPack::Card::Component.new(style: :elevated) do %>
  <p>Elevated card with shadow</p>
<% end %>
```

### Outlined

Card with strong border, no shadow - good for form sections.

```erb
<%= render FlatPack::Card::Component.new(style: :outlined) do %>
  <p>Outlined card with prominent border</p>
<% end %>
```

### Flat

Card with subtle background, no border or shadow - perfect for list items.

```erb
<%= render FlatPack::Card::Component.new(style: :flat) do %>
  <p>Flat card with subtle background</p>
<% end %>
```

### Interactive

Card with hover effects, ideal for clickable cards.

```erb
<%= render FlatPack::Card::Component.new(style: :interactive) do %>
  <p>Interactive card with hover effects</p>
<% end %>
```

### List

Card style for horizontal/list rows with a subtle hover background.

```erb
<%= render FlatPack::Card::Component.new(style: :list, padding: :sm) do %>
  <p>List row card with standardized hover treatment</p>
<% end %>
```

## Hover Effects

Hover behavior is standardized with the `hover` prop and can be applied to any card style.

```erb
<!-- Subtle hover background (great for pricing/list-like cards) -->
<%= render FlatPack::Card::Component.new(style: :outlined, hover: :subtle) do %>
  <p>Outlined card with subtle hover</p>
<% end %>

<!-- Strong interactive hover (shadow + border emphasis) -->
<%= render FlatPack::Card::Component.new(style: :outlined, hover: :strong) do %>
  <p>Outlined card with strong hover</p>
<% end %>
```

Style defaults:

- `:interactive` defaults to `hover: :strong`
- `:list` defaults to `hover: :subtle`
- All other styles default to `hover: :none`

## Padding

Cards come in four padding sizes to control internal spacing:

```erb
<!-- No padding -->
<%= render FlatPack::Card::Component.new(padding: :none) do %>
  <p>No padding</p>
<% end %>

<!-- Small padding (16px) -->
<%= render FlatPack::Card::Component.new(padding: :sm) do %>
  <p>Small padding</p>
<% end %>

<!-- Medium padding (24px) - default -->
<%= render FlatPack::Card::Component.new(padding: :md) do %>
  <p>Medium padding</p>
<% end %>

<!-- Large padding (32px) -->
<%= render FlatPack::Card::Component.new(padding: :lg) do %>
  <p>Large padding</p>
<% end %>
```

**Note:** For slot-based cards, `header`, `body`, and `footer` manage their own spacing (`px-6 py-4`). Use `card.media(..., padding: ...)` to control media inset spacing.

## Clickable Cards

Make entire cards clickable by combining `clickable: true` with an `href`:

```erb
<%= render FlatPack::Card::Component.new(
  style: :interactive,
  clickable: true,
  href: post_path(@post)
) do |card| %>
  <% card.header do %>
    <h3><%= @post.title %></h3>
  <% end %>
  
  <% card.body do %>
    <p><%= @post.excerpt %></p>
  <% end %>
<% end %>
```

For cards with internal action controls (icon buttons, menus, secondary links), prefer a non-clickable card with `hover: :subtle` and make each action explicitly clickable via `url`/`href`. Avoid wrapping those controls inside a single full-card link.

## System Arguments

### Custom Classes

```erb
<%= render FlatPack::Card::Component.new(
  class: "mb-4 max-w-sm"
) do %>
  <p>Card content</p>
<% end %>
```

Classes are merged using `tailwind_merge`, so Tailwind utilities override correctly.

### Data Attributes

```erb
<%= render FlatPack::Card::Component.new(
  data: {
    controller: "product",
    product_id: @product.id
  }
) do %>
  <p>Card content</p>
<% end %>
```

### ARIA Attributes

```erb
<%= render FlatPack::Card::Component.new(
  clickable: true,
  href: post_path(@post),
  aria: { label: "Read article: #{@post.title}" }
) do |card| %>
  <% card.header do %>
    <h3><%= @post.title %></h3>
  <% end %>
  
  <% card.body do %>
    <p><%= @post.excerpt %></p>
  <% end %>
<% end %>
```

### Other Attributes

```erb
<%= render FlatPack::Card::Component.new(
  id: "featured-product",
  role: "article"
) do %>
  <p>Card content</p>
<% end %>
```

## Examples

### Product Card

```erb
<%= render FlatPack::Card::Component.new(style: :elevated) do |card| %>
  <% card.media(aspect_ratio: "4/3") do %>
    <%= image_tag @product.image_url, class: "w-full h-full object-cover" %>
  <% end %>
  
  <% card.body do %>
    <h3 class="text-lg font-semibold mb-2"><%= @product.name %></h3>
    <p class="text-sm text-gray-600 mb-4"><%= @product.description %></p>
    <p class="text-2xl font-bold text-green-600">$<%= @product.price %></p>
  <% end %>
  
  <% card.footer do %>
    <%= render FlatPack::Button::Component.new(
      text: "Add to Cart",
      style: :primary,
      class: "w-full"
    ) %>
  <% end %>
<% end %>
```

### Stat Card

```erb
<%= render FlatPack::Card::Component.new(style: :elevated, padding: :lg) do |card| %>
  <% card.body do %>
    <%= render FlatPack::Card::Stat::Component.new(
      value: number_with_delimiter(@stats.total_users),
      label: "Total Users",
      trend: "12%",
      trend_direction: :up,
      value_class: "text-blue-600"
    ) %>
  <% end %>
<% end %>
```

### Profile Card

```erb
<%= render FlatPack::Card::Component.new(style: :elevated) do |card| %>
  <% card.body do %>
    <div class="flex items-center space-x-4">
      <%= image_tag @user.avatar_url, class: "w-16 h-16 rounded-full" %>
      <div>
        <h3 class="text-lg font-semibold"><%= @user.name %></h3>
        <p class="text-sm text-gray-600"><%= @user.title %></p>
      </div>
    </div>
  <% end %>
  
  <% card.footer(divider: true) do %>
    <div class="flex justify-around text-center">
      <div>
        <div class="text-xl font-bold"><%= @user.followers_count %></div>
        <div class="text-xs text-gray-600">Followers</div>
      </div>
      <div>
        <div class="text-xl font-bold"><%= @user.following_count %></div>
        <div class="text-xs text-gray-600">Following</div>
      </div>
    </div>
  <% end %>
<% end %>
```

### Pricing Card

```erb
<%= render FlatPack::Card::Component.new(style: :outlined, hover: :subtle) do |card| %>
  <% card.header do %>
    <div class="text-center">
      <h3 class="text-xl font-bold">Pro Plan</h3>
      <div class="text-3xl font-bold mt-2">
        $29<span class="text-sm text-gray-600">/month</span>
      </div>
    </div>
  <% end %>
  
  <% card.body do %>
    <ul class="space-y-3">
      <li class="flex items-center">
        <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
        </svg>
        Unlimited projects
      </li>
      <li class="flex items-center">
        <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
        </svg>
        Advanced analytics
      </li>
      <li class="flex items-center">
        <svg class="w-5 h-5 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
        </svg>
        Priority support
      </li>
    </ul>
  <% end %>
  
  <% card.footer do %>
    <%= render FlatPack::Button::Component.new(
      text: "Get Started",
      style: :primary,
      class: "w-full"
    ) %>
  <% end %>
<% end %>
```

### Horizontal List Card

```erb
<%= render FlatPack::Card::Component.new(
  style: :list,
  padding: :sm
) do |card| %>
  <% card.body do %>
    <div class="flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <%= image_tag @notification.avatar, class: "w-10 h-10 rounded-full" %>
        <div>
          <p class="font-medium"><%= @notification.message %></p>
          <p class="text-sm text-gray-500"><%= time_ago_in_words(@notification.created_at) %> ago</p>
        </div>
      </div>
      <span class="text-xs text-gray-400"><%= @notification.time %></span>
    </div>
  <% end %>
<% end %>
```

### Testimonial Card

```erb
<%= render FlatPack::Card::Component.new(style: :elevated, padding: :lg) do |card| %>
  <% card.body do %>
    <div class="mb-4">
      <svg class="w-8 h-8 text-gray-400 mb-4" fill="currentColor" viewBox="0 0 24 24">
        <path d="M14.017 21v-7.391c0-5.704 3.731-9.57 8.983-10.609l.995 2.151c-2.432.917-3.995 3.638-3.995 5.849h4v10h-9.983zm-14.017 0v-7.391c0-5.704 3.748-9.57 9-10.609l.996 2.151c-2.433.917-3.996 3.638-3.996 5.849h3.983v10h-9.983z"/>
      </svg>
      <p class="text-lg mb-4">"<%= @testimonial.quote %>"</p>
    </div>
    <div class="flex items-center">
      <%= image_tag @testimonial.author_avatar, class: "w-12 h-12 rounded-full mr-4" %>
      <div>
        <p class="font-semibold"><%= @testimonial.author_name %></p>
        <p class="text-sm text-gray-600"><%= @testimonial.author_title %>, <%= @testimonial.company %></p>
      </div>
    </div>
  <% end %>
<% end %>
```

## Accessibility

The Card component follows accessibility best practices:

- Semantic HTML structure with proper heading hierarchy
- Keyboard navigation support for clickable cards
- Proper color contrast ratios for text and borders
- Support for ARIA attributes via system arguments

### Keyboard Support for Clickable Cards

Clickable cards support standard keyboard navigation:

- `Enter` - Navigate to card link
- `Tab` - Focus next card
- `Shift+Tab` - Focus previous card

## Testing

```ruby
# test/components/custom_card_test.rb
require "test_helper"

class CustomCardTest < ViewComponent::TestCase
  def test_renders_card_with_content
    render_inline FlatPack::Card::Component.new do
      "Test content"
    end
    
    assert_selector "div[class*='card']", text: "Test content"
  end
end
```

## API Reference

```ruby
FlatPack::Card::Component.new(
  style: Symbol,              # Optional, default: :default (:default, :elevated, :outlined, :flat, :interactive, :list)
  hover: Symbol,              # Optional, default: nil (:none, :subtle, :strong, or nil for style default)
  padding: Symbol,            # Optional, default: :md (:none, :sm, :md, :lg)
  clickable: Boolean,         # Optional, default: false
  href: String,               # Optional, default: nil
  **system_arguments          # Optional
)
```

### Slot Components

```ruby
card.header(divider: Boolean)         # Optional, default divider: true
card.body                              # No additional props
card.footer(divider: Boolean)          # Optional, default divider: true
card.media(aspect_ratio: String, padding: Symbol) # Optional aspect ratio and media padding (:none, :sm, :md, :lg)
```

### Card Subcomponents

```ruby
FlatPack::Card::Stat::Component.new(
  value: String,              # Required - main stat value (e.g. "2,543", "$45.2K")
  label: String,              # Required - subtitle text under the value
  trend: String,              # Required - change value text (e.g. "12%")
  trend_direction: Symbol,    # Required - :up or :down
  value_class: String,        # Optional - custom Tailwind class for the value color
  **system_arguments          # Optional
)
```

### System Arguments

- `class`: String - Additional CSS classes
- `data`: Hash - Data attributes
- `aria`: Hash - ARIA attributes
- `id`: String - Element ID
- `role`: String - ARIA role
- Any other valid HTML attribute

## Related Components

- [Button](./button.md) - For card actions
- [Badge](./badge.md) - For card labels and status indicators
- [Link](./link.md) - For clickable card elements

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode](../dark_mode.md)
- [Table Component](table.md)
