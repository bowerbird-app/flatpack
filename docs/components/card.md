# Card Component

A flexible, composable card component for displaying content in a structured container. The Card component supports multiple visual styles, slot-based composition, and clickable variants.

## Installation

The Card component is part of FlatPack. See the [main README](../../README.md) for installation instructions.

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
  <% card.with_header do %>
    <h3>Card Title</h3>
  <% end %>
  
  <% card.with_body do %>
    <p>Card content goes here.</p>
  <% end %>
<% end %>
```

### Card with All Slots

```erb
<%= render FlatPack::Card::Component.new do |card| %>
  <% card.with_media do %>
    <%= image_tag "product.jpg", class: "w-full h-48 object-cover" %>
  <% end %>
  
  <% card.with_header do %>
    <h3 class="text-lg font-semibold">Product Name</h3>
  <% end %>
  
  <% card.with_body do %>
    <p class="text-sm text-gray-600">Product description goes here.</p>
  <% end %>
  
  <% card.with_footer do %>
    <%= render FlatPack::Button::Component.new(text: "Add to Cart", style: :primary) %>
  <% end %>
<% end %>
```

## Props

### Main Component

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `style` | Symbol | `:default` | Visual style of the card. Options: `:default`, `:elevated`, `:outlined`, `:flat`, `:interactive` |
| `padding` | Symbol | `:md` | Padding size. Options: `:none`, `:sm`, `:md`, `:lg` |
| `clickable` | Boolean | `false` | Makes the entire card clickable when combined with `href` |
| `href` | String | `nil` | URL to navigate to when card is clicked (requires `clickable: true`) |

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

## Card Styles

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

## Padding Options

Control the internal spacing of the card:

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

**Note:** When using slots (header, body, footer), each slot has its own padding (`px-6 py-4`). The main card's padding applies to the overall container.

## Clickable Cards

Make entire cards clickable by combining `clickable: true` with an `href`:

```erb
<%= render FlatPack::Card::Component.new(
  style: :interactive,
  clickable: true,
  href: post_path(@post)
) do |card| %>
  <% card.with_header do %>
    <h3><%= @post.title %></h3>
  <% end %>
  
  <% card.with_body do %>
    <p><%= @post.excerpt %></p>
  <% end %>
<% end %>
```

## Common Patterns

### Product Card

```erb
<%= render FlatPack::Card::Component.new(style: :elevated) do |card| %>
  <% card.with_media(aspect_ratio: "4/3") do %>
    <%= image_tag @product.image_url, class: "w-full h-full object-cover" %>
  <% end %>
  
  <% card.with_body do %>
    <h3 class="text-lg font-semibold mb-2"><%= @product.name %></h3>
    <p class="text-sm text-gray-600 mb-4"><%= @product.description %></p>
    <p class="text-2xl font-bold text-green-600">$<%= @product.price %></p>
  <% end %>
  
  <% card.with_footer do %>
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
  <% card.with_body do %>
    <div class="text-center">
      <div class="text-4xl font-bold text-blue-600 mb-2">
        <%= number_with_delimiter(@stats.total_users) %>
      </div>
      <div class="text-sm text-gray-600 uppercase tracking-wide">
        Total Users
      </div>
      <div class="mt-2 text-sm text-green-600">
        ↑ 12% from last month
      </div>
    </div>
  <% end %>
<% end %>
```

### Profile Card

```erb
<%= render FlatPack::Card::Component.new(style: :elevated) do |card| %>
  <% card.with_body do %>
    <div class="flex items-center space-x-4">
      <%= image_tag @user.avatar_url, class: "w-16 h-16 rounded-full" %>
      <div>
        <h3 class="text-lg font-semibold"><%= @user.name %></h3>
        <p class="text-sm text-gray-600"><%= @user.title %></p>
      </div>
    </div>
  <% end %>
  
  <% card.with_footer(divider: true) do %>
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
<%= render FlatPack::Card::Component.new(style: :outlined) do |card| %>
  <% card.with_header do %>
    <div class="text-center">
      <h3 class="text-xl font-bold">Pro Plan</h3>
      <div class="text-3xl font-bold mt-2">
        $29<span class="text-sm text-gray-600">/month</span>
      </div>
    </div>
  <% end %>
  
  <% card.with_body do %>
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
  
  <% card.with_footer do %>
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
  style: :flat,
  padding: :sm,
  class: "hover:bg-gray-100 transition-colors"
) do |card| %>
  <% card.with_body do %>
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
  <% card.with_body do %>
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

### Clickable Cards

When using clickable cards, ensure the content provides sufficient context:

```erb
<%= render FlatPack::Card::Component.new(
  clickable: true,
  href: post_path(@post),
  aria: { label: "Read article: #{@post.title}" }
) do |card| %>
  <% card.with_header do %>
    <h3><%= @post.title %></h3>
  <% end %>
  
  <% card.with_body do %>
    <p><%= @post.excerpt %></p>
  <% end %>
<% end %>
```

## System Arguments

All Card components accept system arguments for HTML attributes:

```erb
<%= render FlatPack::Card::Component.new(
  id: "featured-product",
  class: "mb-4 max-w-sm",
  data: { controller: "product", product_id: @product.id },
  aria: { label: "Featured product" }
) do %>
  <!-- Card content -->
<% end %>
```

## Security

The Card component includes built-in XSS protection:

- URL sanitization for `href` attribute (only allows http, https, mailto, tel, and relative URLs)
- Dangerous HTML attributes (onclick, onerror, etc.) are automatically filtered
- All user content should still be properly escaped in your views

## Browser Support

The Card component works in all modern browsers and gracefully degrades in older browsers:

- Chrome, Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Dark Mode

The Card component automatically supports dark mode through CSS variables. No additional configuration needed.

## Testing

See the [test file](../../test/components/flat_pack/card_component_test.rb) for comprehensive test examples.

## Related Components

- [Button](./button.md) - For card actions
- [Badge](./badge.md) - For card labels and status indicators
- [Link](./link.md) - For clickable card elements

## Examples

For live examples, see the [Card demo page](../../test/dummy/app/views/pages/cards.html.erb) in the dummy application.
