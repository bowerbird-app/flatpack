# Table Component

The Table component renders data in a tabular format with columns and actions.

## Basic Usage

```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.column(title: "Name", html: ->(row) { row.name }) %>
  <% table.column(title: "Email", html: ->(row) { row.email }) %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `data` | Array | `[]` | Data to display in table |
| `stimulus` | Boolean | `false` | Enable Stimulus controller for interactivity |
| `turbo_frame` | String | `nil` | Wrap table in a Turbo Frame with this ID |
| `sort` | String | `nil` | Current sort column |
| `direction` | String | `nil` | Current sort direction ('asc' or 'desc') |
| `base_url` | String | `nil` | Base URL for sort links |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

## Columns

Define columns using `column`:

### Block-based Column

```erb
<% table.column(title: "Full Name") do |user| %>
  <%= "#{user.first_name} #{user.last_name}" %>
<% end %>
```

Use blocks for custom formatting.

### Lambda-based Column

```erb
<% table.column(title: "Name", html: ->(user) { user.name }) %>
```

Use the `html` parameter with a lambda for simple attribute display.

### Column Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | String | **required** | Column header text |
| `html` | Proc | **optional** | Lambda/proc for custom rendering (required if not using block) |
| `sortable` | Boolean | `false` | Enable sorting for this column |
| `sort_key` | Symbol | **(required when sortable)** | Key to use in sort URL |

## Actions

Define actions using `with_action`:

### Simple Action

```erb
<% table.with_action(
  text: "Edit",
  url: ->(user) { edit_user_path(user) }
) %>
```

### Action with Style

```erb
<% table.with_action(
  text: "Delete",
  url: ->(user) { user_path(user) },
  method: :delete,
  style: :secondary,
  data: { turbo_confirm: "Are you sure?" }
) %>
```

### Custom Action Block

```erb
<% table.with_action do |user| %>
  <%= link_to "Custom", user_path(user), class: "custom-link" %>
<% end %>
```

## Examples

### Complete Table with Actions

```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <%# Lambda column %>
  <% table.column(title: "ID", html: ->(row) { row.id.to_s }) %>
  
  <%# Block column with formatting %>
  <% table.column(title: "Name") do |user| %>
    <strong><%= user.name %></strong>
  <% end %>
  
  <%# Block column with conditional %>
  <% table.column(title: "Status") do |user| %>
    <span class="<%= user.active? ? 'text-green-600' : 'text-gray-400' %>">
      <%= user.active? ? 'Active' : 'Inactive' %>
    </span>
  <% end %>
  
  <%# Date formatting %>
  <% table.column(title: "Created") do |user| %>
    <%= user.created_at.strftime("%b %d, %Y") %>
  <% end %>
  
  <%# Edit action %>
  <% table.with_action(
    text: "Edit",
    url: ->(user) { edit_user_path(user) },
    style: :ghost
  ) %>
  
  <%# Delete action with confirmation %>
  <% table.with_action(
    text: "Delete",
    url: ->(user) { user_path(user) },
    method: :delete,
    style: :ghost,
    data: { turbo_confirm: "Delete #{user.name}?" }
  ) %>
<% end %>
```

### Sortable Tables

The table component supports sorting using Turbo Frames for seamless updates:

```erb
<%= render FlatPack::Table::Component.new(
  data: @sorted_users,
  turbo_frame: "sortable_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: request.path
) do |table| %>
  <% table.column(title: "Name", html: ->(row) { row.name }, sortable: true, sort_key: :name) %>
  <% table.column(title: "Email", html: ->(row) { row.email }, sortable: true, sort_key: :email) %>
  <% table.column(title: "Status", html: ->(row) { row.status }, sortable: true, sort_key: :status) %>
  <% table.column(title: "Created", html: ->(row) { row.created_at.to_s }, sortable: true, sort_key: :created_at) %>
<% end %>
```

**Features:**
- Click column headers to sort
- Visual indicators (↑/↓) show current sort state
- Toggle between ascending/descending on repeated clicks
- Uses Turbo Frames for no-reload updates
- Works with URL parameters for shareable links

See [Sortable Tables](sortable-tables.md) for complete implementation details.

### Sortable Column with Custom Formatter

You can combine sorting with custom formatters:

```erb
<% table.column(
  title: "Status",
  sortable: true,
  sort_key: :status,
  html: ->(user) {
    badge_class = case user.status
    when 'active' then 'bg-green-100 text-green-800'
    when 'inactive' then 'bg-gray-100 text-gray-800'
    else 'bg-yellow-100 text-yellow-800'
    end
    "<span class=\"px-2 py-1 text-xs rounded #{badge_class}\">#{user.status.capitalize}</span>".html_safe
  }
) %>
```

### Sortable Column with Custom Sort Key

Use a different key for sorting than the displayed value:

```erb
<% table.column(
  title: "Name",
  html: ->(row) { row.full_name },
  sortable: true,
  sort_key: :last_name
) %>
```

### With Avatar

```erb
<% table.column(title: "User") do |user| %>
  <div class="flex items-center gap-2">
    <%= image_tag user.avatar_url, class: "w-8 h-8 rounded-full" %>
    <%= user.name %>
  </div>
<% end %>
```

### With Badge

```erb
<% table.column(title: "Role") do |user| %>
  <span class="px-2 py-1 text-xs rounded bg-blue-100 text-blue-800">
    <%= user.role %>
  </span>
<% end %>
```

### Empty State

When `data` is empty, displays "No data available":

```erb
<%= render FlatPack::Table::Component.new(data: []) do |table| %>
  <% table.column(title: "Name", html: ->(row) { row.name }) %>
<% end %>
```

### With Stimulus Controller

Enable the Stimulus controller for advanced interactions:

```erb
<%= render FlatPack::Table::Component.new(data: @users, stimulus: true) do |table| %>
  <% table.column(title: "Name", html: ->(row) { row.name }) %>
<% end %>
```

The Stimulus controller (`flat-pack--table`) provides:
- Row selection
- Bulk actions
- Hover effects

### Conditional Actions

```erb
<% table.with_action do |user| %>
  <% if policy(user).edit? %>
    <%= render FlatPack::Button::Component.new(
      text: "Edit",
      url: edit_user_path(user),
      style: :ghost
    ) %>
  <% end %>
<% end %>
```

### Multiple Action Buttons

```erb
<% table.with_action(text: "View", url: ->(user) { user_path(user) }, style: :ghost) %>
<% table.with_action(text: "Edit", url: ->(user) { edit_user_path(user) }, style: :ghost) %>
<% table.with_action(text: "Delete", url: ->(user) { user_path(user) }, method: :delete, style: :ghost) %>
```

### With Pagination

Combine with pagination libraries like Pagy or Kaminari:

```erb
<%# With Pagy %>
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <%# ... columns ... %>
<% end %>

<%== pagy_nav(@pagy) %>
```

## System Arguments

### Custom Classes

```erb
<%= render FlatPack::Table::Component.new(
  data: @users,
  class: "mt-8"
) do |table| %>
  <%# ... columns ... %>
<% end %>
```

Classes are merged using `tailwind_merge`, so Tailwind utilities override correctly.

### Data Attributes

```erb
<%= render FlatPack::Table::Component.new(
  data: @users,
  data: { controller: "sortable" }
) do |table| %>
  <%# ... columns ... %>
<% end %>
```

## Styling

### CSS Variables

Customize table appearance:

```css
@theme {
  --color-border: oklch(0.85 0.02 250);
  --color-muted: oklch(0.96 0.01 250);
  --color-muted-foreground: oklch(0.45 0.01 250);
}
```

### Custom Styles

Add classes to the container:

```erb
<%= render FlatPack::Table::Component.new(
  data: @users,
  class: "shadow-lg"
) do |table| %>
  <%# ... %>
<% end %>
```

### Responsive Design

Tables are wrapped in a scrollable container:

```html
<div class="overflow-x-auto">
  <table>...</table>
</div>
```

For mobile, consider hiding columns:

```erb
<% table.column(title: "Email", html: ->(row) { row.email }, class: "hidden md:table-cell") %>
```

## Accessibility

The Table component follows accessibility best practices:

- Uses semantic HTML (`<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>`)
- Headers use `<th>` with `scope="col"`
- Proper ARIA attributes for interactive elements
- Keyboard navigation for actions

### Keyboard Support

- `Tab` - Focus next interactive element
- `Shift+Tab` - Focus previous interactive element
- `Enter` / `Space` - Activate focused link or button

## Testing

```ruby
require "test_helper"

class CustomTableTest < ViewComponent::TestCase
  def test_renders_table_with_data
    users = [OpenStruct.new(name: "Alice", email: "alice@example.com")]
    
    render_inline FlatPack::Table::Component.new(data: users) do |table|
      table.column(title: "Name", html: ->(row) { row.name })
      table.column(title: "Email", html: ->(row) { row.email })
    end
    
    assert_selector "th", text: "Name"
    assert_selector "td", text: "Alice"
  end
end
```

## API Reference

### Table Component

```ruby
FlatPack::Table::Component.new(
  data: Array,                # Optional, default: []
  stimulus: Boolean,          # Optional, default: false
  turbo_frame: String,        # Optional, default: nil
  sort: String,               # Optional, default: nil
  direction: String,          # Optional, default: nil (either 'asc' or 'desc')
  base_url: String,           # Optional, default: nil
  **system_arguments          # Optional
)
```

### System Arguments

- `class`: String - Additional CSS classes
- `data`: Hash - Data attributes
- `aria`: Hash - ARIA attributes
- `id`: String - Element ID
- Any other valid HTML attribute

### Column Component

```ruby
table.column(
  title: String,              # Required
  html: Proc,                 # Optional (required if not using block)
  sortable: Boolean,          # Optional, default: false
  sort_key: Symbol,           # Required when sortable is true
  &block                      # Optional (alternative to html parameter)
)
```

### Action Component

```ruby
table.with_action(
  text: String,              # Optional
  url: String | Proc,         # Optional
  method: Symbol,             # Optional
  style: Symbol,              # Optional, default: :ghost
  **system_arguments,         # Optional
  &block                      # Optional
)
```

## Related Components

- [Button Component](button.md) - Used for actions
- [Sortable Tables](sortable-tables.md) - Detailed sorting implementation
- [Icon Component](../shared/icon.md) - For action icons

## Next Steps

- [Sortable Tables](sortable-tables.md)
- [Button Component](button.md)
- [Theming Guide](../theming.md)
- [Stimulus Controllers](../architecture/assets.md#stimulus-controllers)
