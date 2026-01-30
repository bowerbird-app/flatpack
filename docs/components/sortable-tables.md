# Sortable Tables

The FlatPack Table component supports sortable columns using Rails 8 and Turbo for seamless, no-reload sorting.

## Overview

Sortable tables allow users to click column headers to sort data in ascending or descending order. The implementation uses:
- **Turbo Frames** for seamless updates without full page reload
- **URL parameters** for shareable and bookmarkable sort states
- **Visual indicators** (↑/↓ arrows) to show current sort state
- **Toggle behavior** - clicking the same column switches between asc/desc

## Basic Usage

### Step 1: Update Your Controller

Add sorting logic to your controller action:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @sorted_users = sort_users(@users, params[:sort], params[:direction])
  end

  private

  def sort_users(users, sort_column, direction)
    return users unless sort_column.present?
    
    # Validate sort column to prevent SQL injection
    valid_columns = %w[name email created_at status]
    return users unless valid_columns.include?(sort_column)
    
    # Validate direction
    direction = direction == "desc" ? "desc" : "asc"
    
    # Sort users (adjust for ActiveRecord or Array)
    sorted = users.sort_by { |user| user.public_send(sort_column) }
    direction == "desc" ? sorted.reverse : sorted
  end
end
```

### Step 2: Update Your View

Render the table with sortable columns:

```erb
<%= render FlatPack::Table::Component.new(
  rows: @sorted_users,
  turbo_frame: "sortable_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: request.path
) do |table| %>
  <% table.with_column(label: "Name", attribute: :name, sortable: true) %>
  <% table.with_column(label: "Email", attribute: :email, sortable: true) %>
  <% table.with_column(label: "Created", attribute: :created_at, sortable: true) %>
<% end %>
```

## Required Parameters

For sortable tables to work, you must provide:

| Parameter | Type | Description |
|-----------|------|-------------|
| `turbo_frame` | String | ID for the Turbo Frame (e.g., "sortable_table") |
| `sort` | String | Current sort column from `params[:sort]` |
| `direction` | String | Current sort direction from `params[:direction]` |
| `base_url` | String | Base URL for links, typically `request.path` |

## Column Configuration

### Making Columns Sortable

Add `sortable: true` to any column:

```erb
<% table.with_column(
  label: "Name",
  attribute: :name,
  sortable: true
) %>
```

### Custom Sort Key

Use a different sort key than the display attribute:

```erb
<% table.with_column(
  label: "Full Name",
  attribute: :full_name,
  sortable: true,
  sort_key: :last_name  # Sort by last name instead
) %>
```

### Sortable with Formatter

Combine sorting with custom formatting:

```erb
<% table.with_column(
  label: "Status",
  attribute: :status,
  sortable: true,
  formatter: ->(user) {
    badge_class = case user.status
    when 'active' then 'bg-green-100 text-green-800'
    when 'inactive' then 'bg-gray-100 text-gray-800'
    end
    "<span class=\"px-2 py-1 text-xs rounded #{badge_class}\">
      #{user.status.capitalize}
    </span>".html_safe
  }
) %>
```

## ActiveRecord Integration

For ActiveRecord models, use the database for sorting:

```ruby
def sort_users(users, sort_column, direction)
  return users unless sort_column.present?
  
  # Whitelist sortable columns
  valid_columns = %w[name email created_at status]
  return users unless valid_columns.include?(sort_column)
  
  # Validate direction
  direction = direction == "desc" ? "desc" : "asc"
  
  # Use ActiveRecord ordering
  users.order("#{sort_column} #{direction}")
end
```

### With Associations

Sort by associated table columns:

```ruby
def sort_users(users, sort_column, direction)
  direction = direction == "desc" ? "desc" : "asc"
  
  case sort_column
  when "name", "email", "created_at"
    users.order("#{sort_column} #{direction}")
  when "company_name"
    users.joins(:company).order("companies.name #{direction}")
  else
    users
  end
end
```

## Complete Example

### Controller

```ruby
class ProductsController < ApplicationController
  def index
    @products = Product.includes(:category)
    @sorted_products = sort_products(@products, params[:sort], params[:direction])
  end

  private

  def sort_products(products, sort_column, direction)
    return products unless sort_column.present?
    
    valid_columns = %w[name price stock created_at category_name]
    return products unless valid_columns.include?(sort_column)
    
    direction = direction == "desc" ? "DESC" : "ASC"
    
    case sort_column
    when "category_name"
      products.joins(:category).order("categories.name #{direction}")
    else
      products.order("products.#{sort_column} #{direction}")
    end
  end
end
```

### View

```erb
<h1>Products</h1>

<%= render FlatPack::Table::Component.new(
  rows: @sorted_products,
  turbo_frame: "products_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: products_path
) do |table| %>
  
  <% table.with_column(
    label: "Name",
    attribute: :name,
    sortable: true
  ) %>
  
  <% table.with_column(
    label: "Price",
    attribute: :price,
    sortable: true,
    formatter: ->(product) { number_to_currency(product.price) }
  ) %>
  
  <% table.with_column(
    label: "Stock",
    attribute: :stock,
    sortable: true
  ) %>
  
  <% table.with_column(
    label: "Category",
    attribute: :category_name,
    sortable: true,
    sort_key: :category_name,
    formatter: ->(product) { product.category.name }
  ) %>
  
  <% table.with_column(
    label: "Created",
    attribute: :created_at,
    sortable: true,
    formatter: ->(product) { product.created_at.strftime("%b %d, %Y") }
  ) %>
  
  <% table.with_action(
    label: "Edit",
    url: ->(product) { edit_product_path(product) },
    scheme: :ghost
  ) %>
<% end %>
```

## How It Works

1. **Initial Load**: Table renders with default sort (or no sort)
2. **Click Header**: User clicks a sortable column header
3. **URL Update**: Browser navigates to URL with `?sort=column&direction=asc`
4. **Turbo Frame**: Turbo intercepts the request and updates only the frame
5. **Controller**: Sorts data based on params
6. **Partial Update**: Only the table content is replaced
7. **Visual Feedback**: Arrow indicator shows current sort state

## URL Parameters

The sortable table uses two URL parameters:

- `sort`: The column to sort by (e.g., `name`, `email`)
- `direction`: The sort direction (`asc` or `desc`)

Example URLs:
- `/users?sort=name&direction=asc` - Sort by name ascending
- `/users?sort=email&direction=desc` - Sort by email descending

These URLs are:
- **Shareable**: Users can copy/paste the URL
- **Bookmarkable**: Browser bookmarks preserve the sort state
- **SEO-friendly**: Search engines can index different sort orders

## Turbo Frame Details

The `turbo_frame` parameter wraps the entire table in a Turbo Frame:

```html
<turbo-frame id="sortable_table">
  <div class="overflow-x-auto">
    <table>
      <!-- table content -->
    </table>
  </div>
</turbo-frame>
```

When a sort link is clicked:
1. Turbo intercepts the navigation
2. Fetches the new URL
3. Extracts content with matching `turbo-frame` ID
4. Replaces the current frame content
5. Updates browser history

## Visual Indicators

Sortable columns show visual feedback:

- **Non-sorted columns**: Normal appearance, hoverable
- **Sorted ascending**: Column name + ↑ arrow
- **Sorted descending**: Column name + ↓ arrow

The arrow uses the primary color from your theme:

```css
.text-[var(--color-primary)]
```

## Best Practices

### 1. Always Validate Sort Parameters

Never trust user input. Always validate sort columns:

```ruby
def sort_users(users, sort_column, direction)
  # Whitelist valid columns
  valid_columns = %w[name email created_at]
  return users unless valid_columns.include?(sort_column)
  
  # ... rest of sorting logic
end
```

### 2. Use Database Sorting for Large Datasets

For ActiveRecord, sort at the database level:

```ruby
# Good: Database sorting
users.order("name ASC")

# Bad: Ruby sorting (loads all records into memory)
users.to_a.sort_by(&:name)
```

### 3. Provide Sensible Defaults

Consider a default sort order:

```ruby
def index
  sort_column = params[:sort] || "created_at"
  direction = params[:direction] || "desc"
  
  @users = sort_users(User.all, sort_column, direction)
end
```

### 4. Consider Pagination

Combine with pagination libraries like Pagy or Kaminari:

```ruby
def index
  users = sort_users(User.all, params[:sort], params[:direction])
  @pagy, @users = pagy(users, items: 20)
end
```

```erb
<%= render FlatPack::Table::Component.new(
  rows: @users,
  turbo_frame: "users_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: users_path
) do |table| %>
  <!-- columns -->
<% end %>

<%== pagy_nav(@pagy) %>
```

### 5. Handle Nil Values

Sort methods should handle nil values gracefully:

```ruby
def sort_users(users, sort_column, direction)
  # ... validation ...
  
  sorted = users.sort_by do |user|
    value = user.public_send(sort_column)
    # Put nils at the end
    value.nil? ? "" : value
  end
  
  direction == "desc" ? sorted.reverse : sorted
end
```

## Testing

### Component Tests

```ruby
class TableComponentTest < ViewComponent::TestCase
  def test_renders_sortable_column_headers
    users = [OpenStruct.new(name: "Alice", email: "alice@example.com")]
    
    render_inline FlatPack::Table::Component.new(
      rows: users,
      sort: "name",
      direction: "asc",
      base_url: "/users"
    ) do |table|
      table.with_column(label: "Name", attribute: :name, sortable: true)
    end
    
    assert_selector "th a[href*='sort=name']"
    assert_selector "th a", text: /Name.*↑/
  end
  
  def test_sortable_link_toggles_direction
    users = [OpenStruct.new(name: "Alice")]
    
    render_inline FlatPack::Table::Component.new(
      rows: users,
      sort: "name",
      direction: "asc",
      base_url: "/users"
    ) do |table|
      table.with_column(label: "Name", attribute: :name, sortable: true)
    end
    
    # When currently asc, link should be for desc
    assert_selector "th a[href*='direction=desc']"
  end
end
```

### Integration Tests

```ruby
class UsersIndexTest < ActionDispatch::IntegrationTest
  test "sorts users by name ascending" do
    User.create!(name: "Charlie")
    User.create!(name: "Alice")
    User.create!(name: "Bob")
    
    get users_path(sort: "name", direction: "asc")
    
    assert_response :success
    assert_select "tbody tr:nth-child(1)", text: /Alice/
    assert_select "tbody tr:nth-child(2)", text: /Bob/
    assert_select "tbody tr:nth-child(3)", text: /Charlie/
  end
  
  test "sorts users by name descending" do
    User.create!(name: "Charlie")
    User.create!(name: "Alice")
    
    get users_path(sort: "name", direction: "desc")
    
    assert_response :success
    assert_select "tbody tr:nth-child(1)", text: /Charlie/
    assert_select "tbody tr:nth-child(2)", text: /Alice/
  end
end
```

## Troubleshooting

### Sort Not Working

**Problem**: Clicking headers doesn't sort

**Solutions**:
- Verify `turbo_frame` is set on the component
- Check that `base_url` is provided
- Ensure columns have `sortable: true`
- Verify controller is handling `params[:sort]` and `params[:direction]`

### No Visual Indicators

**Problem**: Arrows not showing

**Solutions**:
- Verify `sort` and `direction` are passed to component
- Check that values match column's `sort_key` or `attribute`
- Inspect browser to ensure Unicode arrows are rendering

### Full Page Reload

**Problem**: Page reloads instead of frame update

**Solutions**:
- Verify Turbo is loaded (`import "@hotwired/turbo-rails"`)
- Check that `turbo_frame` ID matches in request and response
- Ensure response includes matching `<turbo-frame>` tag

### SQL Injection Risk

**Problem**: Unsafe sorting with user input

**Solution**: Always whitelist columns:

```ruby
# Bad - SQL injection risk
users.order("#{params[:sort]} #{params[:direction]}")

# Good - whitelisted columns
valid_columns = %w[name email created_at]
return users unless valid_columns.include?(params[:sort])
users.order("#{params[:sort]} #{params[:direction]}")
```

## Performance Considerations

### Database Indexes

Add indexes for sortable columns:

```ruby
class AddIndexesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :name
    add_index :users, :email
    add_index :users, :created_at
  end
end
```

### N+1 Queries

Use `includes` for associations:

```ruby
def index
  @products = Product.includes(:category)
  @sorted_products = sort_products(@products, params[:sort], params[:direction])
end
```

### Caching

Consider caching sorted results:

```ruby
def index
  cache_key = "users/sorted/#{params[:sort]}/#{params[:direction]}/#{User.maximum(:updated_at)}"
  
  @users = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
    sort_users(User.all, params[:sort], params[:direction]).to_a
  end
end
```

## Accessibility

The sortable table implementation is accessible:

- **Keyboard Navigation**: Links are keyboard accessible
- **Screen Readers**: Header text announces sort state
- **Visual Indicators**: Color and icons show current sort
- **Focus States**: Hover/focus states on clickable headers

Consider adding ARIA attributes for enhanced accessibility:

```ruby
def sort_link(current_sort, current_direction, base_url)
  # ... build URL ...
  
  aria_label = if current_sort.to_s == @sort_key.to_s
    "#{@label}, sorted #{current_direction}ending, click to sort #{opposite_direction}"
  else
    "#{@label}, not sorted, click to sort ascending"
  end
  
  tag.a(
    href: sort_url,
    data: { turbo_frame: "sortable_table" },
    aria: { label: aria_label },
    class: "..."
  ) do
    # ... link content ...
  end
end
```

## Related Documentation

- [Table Component](table.md) - Main table documentation
- [Turbo Frames](https://turbo.hotwired.dev/handbook/frames) - Turbo Frame documentation
- [Rails URL Helpers](https://guides.rubyonrails.org/routing.html) - URL generation

## Next Steps

- Combine with [pagination](table.md#performance-considerations)
- Add [filters](../advanced/filters.md) to complement sorting
- Implement [multi-column sorting](../advanced/multi-column-sort.md)
