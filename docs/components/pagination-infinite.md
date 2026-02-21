# Pagination Infinite Scroll Component

The Pagination Infinite Scroll component adds infinite scrolling capability with automatic loading and graceful fallback.

## Basic Usage

```erb
<%= render FlatPack::PaginationInfinite::Component.new(
  url: items_path(page: @next_page),
  page: @next_page,
  has_more: @has_more
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `url` | String | **required** | URL to fetch next page |
| `page` | Number | `1` | Current page number |
| `has_more` | Boolean | `true` | Whether more content is available |
| `loading_text` | String | `"Loading more..."` | Text shown while loading |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Examples

### Basic Infinite Scroll
```erb
<div>
  <% @items.each do |item| %>
    <div class="item"><%= item.name %></div>
  <% end %>
</div>

<%= render FlatPack::PaginationInfinite::Component.new(
  url: items_path(page: @pagy.next),
  page: @pagy.next,
  has_more: @pagy.next.present?
) %>
```

### Custom Loading Text
```erb
<%= render FlatPack::PaginationInfinite::Component.new(
  url: products_path(page: @next_page),
  page: @next_page,
  has_more: @has_more,
  loading_text: "Fetching more products..."
) %>
```

### With Query Parameters
```erb
<%= render FlatPack::PaginationInfinite::Component.new(
  url: search_path(q: params[:q], page: @next_page),
  page: @next_page,
  has_more: @has_more
) %>
```

## Stimulus Controller

Uses the `flat-pack--pagination-infinite` Stimulus controller for automatic loading.

### Features
- **Intersection Observer**: Automatically loads when button scrolls into view
- **Graceful Fallback**: Works as regular link if JavaScript disabled
- **Loading State**: Shows spinner during fetch
- **Error Handling**: Displays error message on failure

### Expected Response Format

Your controller should return HTML that includes:

```erb
<!-- New content -->
<div data-pagination-content>
  <% @items.each do |item| %>
    <!-- item markup -->
  <% end %>
</div>

<!-- New pagination component (or omit if no more pages) -->
<%= render FlatPack::PaginationInfinite::Component.new(...) if @has_more %>
```

## Controller Example

```ruby
def index
  @pagy, @items = pagy(Item.all, items: 20)
  
  if request.xhr?
    render partial: "items_list", locals: { items: @items, pagy: @pagy }
  else
    # Full page render
  end
end
```

## Accessibility

- Works without JavaScript (regular link fallback)
- Loading state announced to screen readers
- Keyboard accessible
- Focus management preserved during content insertion

## Use Cases

- Blog post feeds
- Product listings
- Search results
- Activity feeds
- News feeds
