# Pagination Infinite Scroll Component

## Purpose
Implement incremental loading and infinite scroll behavior for paginated collections.

## When to use
Use Pagination Infinite when list/table/grid content should load progressively without full-page pagination controls.

## Class
- Primary: `FlatPack::PaginationInfinite::Component`

## Props
See the `Props` section below for supported arguments and defaults.

## Slots
See examples below for wrapping and content composition.

## Variants
See loading trigger and fallback variants below.

## Example
Start with `Basic Usage` below.

## Accessibility
See accessibility notes below for focus management and loading feedback.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus/Turbo integration for incremental loading.

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
| `loading_variant` | Symbol | `:table` | Loading UI variant (`:table`, `:cards`, `:inline`) |
| `insert_mode` | Symbol | `:append` | Insert fetched content at end or start (`:append`, `:prepend`) |
| `observe_root_selector` | String | `nil` | CSS selector for custom IntersectionObserver root |
| `cursor_selector` | String | `nil` | CSS selector for cursor element inside `data-pagination-content` |
| `cursor_param` | String | `nil` | Query param name to send cursor value |
| `batch_size` | Number | `nil` | Optional page size/batch size sent with each request |
| `batch_size_param` | String | `"limit"` | Query param name for `batch_size` |
| `preserve_scroll_position` | Boolean | `false` | Preserve viewport offset when prepending content |
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

### Chat History (Scroll Up)
```erb
<%= render FlatPack::PaginationInfinite::Component.new(
  url: chat_group_messages_path(@chat_group),
  has_more: @has_more,
  loading_variant: :inline,
  insert_mode: :prepend,
  observe_root_selector: "[data-flat-pack--chat-scroll-target='messages']",
  cursor_selector: "[data-pagination-cursor]",
  cursor_param: "before_id",
  batch_size: 20,
  batch_size_param: "limit",
  preserve_scroll_position: true
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
