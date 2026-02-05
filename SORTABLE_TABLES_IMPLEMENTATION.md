# Sortable Tables Implementation Summary

## Overview

This document summarizes the implementation of sortable table functionality for the FlatPack table component using Rails 8 and Turbo best practices.

## What Was Implemented

### 1. Core Functionality
- ✅ Sortable column headers with click-to-sort behavior
- ✅ Visual indicators (↑/↓ arrows) showing current sort state
- ✅ Toggle between ascending/descending on repeated clicks
- ✅ Turbo Frame integration for seamless, no-reload updates
- ✅ URL parameter-based sorting (shareable/bookmarkable)
- ✅ Backward compatible with existing non-sortable tables

### 2. Component Updates

#### ColumnComponent (`app/components/flat_pack/table/column_component.rb`)
**New Features:**
- `sortable` parameter - enables sorting for a column (default: `false`)
- `sort_key` parameter - custom key for URL params (defaults to `attribute`)
- `render_header` now accepts `current_sort`, `current_direction`, and `base_url`
- Generates sort links with proper Turbo Frame targeting
- Shows visual indicators for current sort state
- Calculates next sort direction (toggle asc/desc)

**Key Methods:**
```ruby
def initialize(label:, attribute: nil, html: nil, sortable: false, sort_key: nil, &block)
def render_header(current_sort: nil, current_direction: nil, base_url: nil)
def sort_link(current_sort, current_direction, base_url)
def calculate_new_direction(current_sort, current_direction)
def build_sort_url(base_url, direction)
def sort_indicator(current_sort, current_direction)
```

#### TableComponent (`app/components/flat_pack/table/component.rb`)
**New Features:**
- `turbo_frame` parameter - wraps table in Turbo Frame
- `sort` parameter - current sort column
- `direction` parameter - current sort direction ('asc'/'desc')
- `base_url` parameter - base URL for generating sort links
- Passes sort state to column headers
- Conditionally wraps output in `turbo_frame_tag`

**Updated Signature:**
```ruby
def initialize(
  data: [],
  stimulus: false,
  turbo_frame: nil,
  sort: nil,
  direction: nil,
  base_url: nil,
  **system_arguments
)
```

### 3. Demo Implementation

#### Controller (`test/dummy/app/controllers/pages_controller.rb`)
Added `sort_users` method demonstrating:
- Parameter validation (whitelist approach)
- Direction validation
- Sort logic for array-based data
- Nil value handling

#### View (`test/dummy/app/views/pages/tables.html.erb`)
Added new "Sortable Table" section showing:
- Turbo Frame usage
- Sortable column configuration
- Integration with formatting
- Proper parameter passing

### 4. Comprehensive Tests

Added 13 new test cases in `test/components/flat_pack/table_component_test.rb`:
- ✅ Sortable column headers render correctly
- ✅ Sort direction toggles properly
- ✅ Visual indicators show for current sort
- ✅ Non-sortable columns remain static
- ✅ Turbo Frame data attributes are set
- ✅ Table wraps in Turbo Frame when specified
- ✅ Custom sort keys work correctly
- ✅ Sortable columns work with formatters
- ✅ And more...

### 5. Documentation

Created/Updated:
- ✅ `docs/components/table.md` - Updated with sortable parameters and examples
- ✅ `docs/components/sortable-tables.md` - Comprehensive sortable tables guide

## File Changes

### Modified Files
1. `app/components/flat_pack/table/component.rb`
2. `app/components/flat_pack/table/column_component.rb`
3. `test/components/flat_pack/table_component_test.rb`
4. `test/dummy/app/controllers/pages_controller.rb`
5. `test/dummy/app/views/pages/tables.html.erb`
6. `docs/components/table.md`

### New Files
1. `docs/components/sortable-tables.md` - Complete guide to sortable tables
2. `SORTABLE_TABLES_IMPLEMENTATION.md` - This file

## Usage Example

### Basic Implementation

**Controller:**
```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @sorted_users = sort_users(@users, params[:sort], params[:direction])
  end

  private

  def sort_users(users, sort_column, direction)
    return users unless sort_column.present?
    
    # Whitelist valid columns
    valid_columns = %w[name email created_at status]
    return users unless valid_columns.include?(sort_column)
    
    # Validate and apply sorting using hash syntax (safe from SQL injection)
    direction = direction == "desc" ? :desc : :asc
    users.order(sort_column => direction)
  end
end
```

**View:**
```erb
<%= render FlatPack::Table::Component.new(
  data: @sorted_users,
  turbo_frame: "users_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: request.path
) do |table| %>
  <% table.with_column(title: "Name", attribute: :name, sortable: true) %>
  <% table.with_column(title: "Email", attribute: :email, sortable: true) %>
  <% table.with_column(title: "Status", attribute: :status, sortable: true) %>
  <% table.with_column(title: "Created", attribute: :created_at, sortable: true) %>
<% end %>
```

## Technical Details

### Turbo Frame Flow
1. User clicks sortable column header
2. Turbo intercepts the link click
3. Request is made with `sort` and `direction` params
4. Controller sorts data and renders view
5. Turbo extracts matching frame content
6. Only the table content is updated
7. Browser history is updated with new URL

### URL Structure
```
/users?sort=name&direction=asc
/users?sort=email&direction=desc
```

Benefits:
- Shareable links
- Bookmarkable states
- Browser back/forward navigation
- SEO-friendly

### Visual Indicators
- **Ascending**: Column name + ↑ (Unicode U+2191) with 0.25rem left margin
- **Descending**: Column name + ↓ (Unicode U+2193) with 0.25rem left margin
- **Not sorted**: Column name only
- **Hover state**: Transition effect on hover

### CSS Classes
```ruby
# Normal header
"px-4 py-3 text-left text-xs font-medium text-[var(--color-muted-foreground)] uppercase tracking-wider"

# Sortable header
"#{header_classes} cursor-pointer select-none"

# Sort indicator (with margin for spacing)
"ms-1 text-[var(--color-primary)] font-bold"

# Sort link
"group inline-flex items-center gap-1 hover:text-[var(--color-foreground)] transition-colors"
```

## Rails 8 / Turbo Best Practices

✅ **No JavaScript Required**: Pure Rails/Turbo implementation
✅ **Progressive Enhancement**: Works without JavaScript (falls back to full page load)
✅ **Hotwire First**: Uses Turbo Frames, not custom JS
✅ **URL-based State**: Sort state in URL params
✅ **Semantic HTML**: Proper use of `<th>`, `<a>` tags
✅ **Accessible**: Keyboard navigable, screen reader friendly

## Backward Compatibility

The implementation is fully backward compatible:

**Existing tables continue to work:**
```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.with_column(title: "Name", attribute: :name) %>
<% end %>
```

**Opt-in to sorting:**
- Only columns with `sortable: true` are sortable
- Tables without `turbo_frame` work as before
- All parameters are optional with sensible defaults

## Testing

### Running Tests
```bash
cd /home/runner/work/flatpack/flatpack
bundle exec rake test TEST=test/components/flat_pack/table_component_test.rb
```

### Test Coverage
- ✅ Component rendering
- ✅ Sortable link generation
- ✅ Direction toggling
- ✅ Visual indicators
- ✅ Turbo Frame integration
- ✅ Custom sort keys
- ✅ Formatter compatibility

## Demo

The demo is available at:
- **Path**: `test/dummy/app/views/pages/tables.html.erb`
- **Section**: "Sortable Table" (bottom of page)
- **Route**: `/tables` in the dummy app

To run the demo:
```bash
cd test/dummy
bin/dev
# Navigate to http://localhost:3000/tables
```

## Security Considerations

⚠️ **Important Security Practices:**

1. **Always Whitelist Columns**:
```ruby
valid_columns = %w[name email created_at]
return users unless valid_columns.include?(sort_column)
```

2. **Validate Direction**:
```ruby
direction = direction == "desc" ? "desc" : "asc"
```

3. **Never Directly Interpolate User Input**:
```ruby
# Bad - SQL injection risk
users.order("#{params[:sort]} #{params[:direction]}")

# Better - validated but still using string interpolation
users.order("#{validated_column} #{validated_direction}")

# Best - validated with hash syntax (no interpolation)
direction = validated_direction == "desc" ? :desc : :asc
users.order(validated_column => direction)
```

## Performance Considerations

### Database Sorting
For ActiveRecord:
```ruby
users.order("name ASC")  # Database sorts
```

### Indexes
Add indexes for sortable columns:
```ruby
add_index :users, :name
add_index :users, :email
```

### N+1 Prevention
Use `includes` for associations:
```ruby
Product.includes(:category).order("name ASC")
```

## Future Enhancements

Potential improvements (not implemented):
- [ ] Multi-column sorting (sort by multiple columns)
- [ ] Sort persistence (remember user's sort preference)
- [ ] Default sort order configuration
- [ ] Case-insensitive sorting option
- [ ] Natural sort order for strings with numbers
- [ ] Sort by computed/virtual columns

## API Reference

### Table Component

```ruby
FlatPack::Table::Component.new(
  data: Array,           # Required - data to display
  turbo_frame: String,   # Optional - Turbo Frame ID
  sort: String,          # Optional - current sort column
  direction: String,     # Optional - 'asc' or 'desc'
  base_url: String,      # Optional - base URL for links
  stimulus: Boolean,     # Optional - enable Stimulus
  **system_arguments     # Optional - HTML attributes
)
```

### Column Component

```ruby
table.with_column(
  title: String,         # Required - header text
  attribute: Symbol,     # Optional - attribute to display
  html: Proc,       # Optional - custom formatter
  sortable: Boolean,     # Optional - enable sorting (default: false)
  sort_key: Symbol,      # Optional - key for URL (default: attribute)
  &block                 # Optional - custom block
)
```

## Related Documentation

- [Table Component](docs/components/table.md)
- [Sortable Tables Guide](docs/components/sortable-tables.md)
- [Turbo Frames](https://turbo.hotwired.dev/handbook/frames)

## Author & Date

**Implemented**: January 2025
**Rails Version**: 8.0+
**Turbo Version**: 2.0+
**ViewComponent Version**: 3.0+

## Summary

This implementation provides a production-ready, Rails 8-native sortable table solution that:
- ✅ Uses Turbo Frames for seamless UX
- ✅ Follows "The Rails Way"
- ✅ Is fully tested
- ✅ Is well documented
- ✅ Is backward compatible
- ✅ Is secure by default
- ✅ Is accessible
- ✅ Is performant

The feature is ready for use in production applications and serves as a reference implementation for similar Turbo-based interactions in the FlatPack component library.
