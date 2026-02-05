# Sortable Table Examples

Visual and interactive examples of the sortable table functionality.

## Basic Usage

This document provides practical examples and visual representations of sortable tables in action.

## Examples

### Example 1: Initial State (No Sort)

When a table first loads without sorting:

```
┌─────────────────────────────────────────────────────────────────┐
│ ID ▼   Name ▼    Email ▼        Status ▼    Created ▼   Actions│
├─────────────────────────────────────────────────────────────────┤
│ 1      User 1    user1@...      active      Jan 15, 25  Edit    │
│ 2      User 2    user2@...      inactive    Jan 10, 25  Edit    │
│ 3      User 3    user3@...      pending     Jan 20, 25  Edit    │
└─────────────────────────────────────────────────────────────────┘

Note: All column headers are clickable (shown with ▼)
```

### Example 2: Sorted by Name (Ascending)

After clicking the "Name" column header:

```
┌─────────────────────────────────────────────────────────────────┐
│ ID ▼   Name ↑    Email ▼        Status ▼    Created ▼   Actions│
├─────────────────────────────────────────────────────────────────┤
│ 1      User 1    user1@...      active      Jan 15, 25  Edit    │
│ 2      User 2    user2@...      inactive    Jan 10, 25  Edit    │
│ 3      User 3    user3@...      pending     Jan 20, 25  Edit    │
└─────────────────────────────────────────────────────────────────┘

Note: Name column shows ↑ indicating ascending sort
URL: /tables?sort=name&direction=asc
```

### Example 3: Sorted by Name (Descending)

After clicking the "Name" column header again:

```
┌─────────────────────────────────────────────────────────────────┐
│ ID ▼   Name ↓    Email ▼        Status ▼    Created ▼   Actions│
├─────────────────────────────────────────────────────────────────┤
│ 3      User 3    user3@...      pending     Jan 20, 25  Edit    │
│ 2      User 2    user2@...      inactive    Jan 10, 25  Edit    │
│ 1      User 1    user1@...      active      Jan 15, 25  Edit    │
└─────────────────────────────────────────────────────────────────┘

Note: Name column shows ↓ indicating descending sort
URL: /tables?sort=name&direction=desc
```

### Example 4: Sorted by Status with Formatted Column

Sorting still works with custom formatters:

```
┌──────────────────────────────────────────────────────────────────────┐
│ Name ▼   Email ▼        Status ↑              Created ▼     Actions│
├──────────────────────────────────────────────────────────────────────┤
│ User 1   user1@...      ╔════════╗            Jan 15, 25    Edit    │
│                          ║ Active ║                                  │
│                          ╚════════╝                                  │
│ User 3   user3@...      ╔═════════╗           Jan 20, 25    Edit    │
│                          ║ Pending ║                                 │
│                          ╚═════════╝                                 │
│ User 2   user2@...      ╔══════════╗          Jan 10, 25    Edit    │
│                          ║ Inactive ║                                │
│                          ╚══════════╝                                │
└──────────────────────────────────────────────────────────────────────┘

Note: Status column is sorted alphabetically (Active, Inactive, Pending)
      despite having custom formatting (badges)
URL: /tables?sort=status&direction=asc
```

## HTML Structure

### Sortable Header (Non-sorted)

```html
<th class="px-4 py-3 text-left text-xs font-medium text-[var(--color-muted-foreground)] uppercase tracking-wider cursor-pointer select-none">
  <a href="/tables?sort=name&direction=asc" 
     data-turbo-frame="sortable_table"
     class="group inline-flex items-center gap-1 hover:text-[var(--color-foreground)] transition-colors">
    Name
  </a>
</th>
```

### Sortable Header (Sorted Ascending)

```html
<th class="px-4 py-3 text-left text-xs font-medium text-[var(--color-muted-foreground)] uppercase tracking-wider cursor-pointer select-none">
  <a href="/tables?sort=name&direction=desc" 
     data-turbo-frame="sortable_table"
     class="group inline-flex items-center gap-1 hover:text-[var(--color-foreground)] transition-colors">
    Name
    <span class="text-[var(--color-primary)] font-bold">↑</span>
  </a>
</th>
```

### Sortable Header (Sorted Descending)

```html
<th class="px-4 py-3 text-left text-xs font-medium text-[var(--color-muted-foreground)] uppercase tracking-wider cursor-pointer select-none">
  <a href="/tables?sort=name&direction=asc" 
     data-turbo-frame="sortable_table"
     class="group inline-flex items-center gap-1 hover:text-[var(--color-foreground)] transition-colors">
    Name
    <span class="text-[var(--color-primary)] font-bold">↓</span>
  </a>
</th>
```

### Full Turbo Frame Structure

```html
<turbo-frame id="sortable_table">
  <div class="overflow-x-auto rounded-[var(--radius-lg)] border border-[var(--color-border)]">
    <table class="w-full border-collapse bg-[var(--color-background)]">
      <thead class="bg-[var(--color-muted)]">
        <tr>
          <th><!-- Sortable column headers --></th>
        </tr>
      </thead>
      <tbody class="divide-y divide-[var(--color-border)]">
        <tr class="hover:bg-[var(--color-muted)] transition-colors">
          <td><!-- Table data --></td>
        </tr>
      </tbody>
    </table>
  </div>
</turbo-frame>
```

## User Interaction Flow

```
1. User sees table with sortable headers
   ┌─────────────────────┐
   │ Name ▼ │ Email ▼ │  │
   │─────────────────────│
   │ data   │ data    │  │
   └─────────────────────┘

2. User hovers over "Name" header
   ┌─────────────────────┐
   │ Name ▼ │ Email ▼ │  │  ← Cursor changes, color transitions
   │─────────────────────│
   │ data   │ data    │  │
   └─────────────────────┘

3. User clicks "Name" header
   ┌─────────────────────┐
   │ Name ↑ │ Email ▼ │  │  ← Arrow appears, data sorts ascending
   │─────────────────────│
   │ sorted │ data    │  │
   └─────────────────────┘
   
   URL updates: /tables?sort=name&direction=asc
   Turbo Frame updates (no page reload)

4. User clicks "Name" header again
   ┌─────────────────────┐
   │ Name ↓ │ Email ▼ │  │  ← Arrow flips, data sorts descending
   │─────────────────────│
   │ sorted │ data    │  │
   └─────────────────────┘
   
   URL updates: /tables?sort=name&direction=desc
   Turbo Frame updates (no page reload)

5. User clicks "Email" header
   ┌─────────────────────┐
   │ Name ▼ │ Email ↑ │  │  ← Different column sorts, Name arrow gone
   │─────────────────────│
   │ data   │ sorted  │  │
   └─────────────────────┘
   
   URL updates: /tables?sort=email&direction=asc
   Turbo Frame updates (no page reload)
```

## Responsive Behavior

### Desktop View (1024px+)

```
┌─────────────────────────────────────────────────────────────┐
│ ID ▼  Name ▼   Email ▼        Status ▼   Created ▼  Actions│
├─────────────────────────────────────────────────────────────┤
│ 1     User 1   user1@example   Active    Jan 15     Edit   │
│ 2     User 2   user2@example   Inactive  Jan 10     Edit   │
└─────────────────────────────────────────────────────────────┘
All columns visible, full width
```

### Tablet View (768px-1023px)

```
┌───────────────────────────────────────────────────┐
│← Name ▼   Email ▼      Status ▼   Created ▼  →  │
├───────────────────────────────────────────────────┤
│  User 1   user1@...    Active    Jan 15     →   │
│  User 2   user2@...    Inactive  Jan 10     →   │
└───────────────────────────────────────────────────┘
Horizontal scroll enabled, some columns may be hidden
```

### Mobile View (< 768px)

```
┌─────────────────────────────┐
│← Name ▼   Status ▼   →     │
├─────────────────────────────┤
│  User 1   Active      →    │
│  User 2   Inactive    →    │
└─────────────────────────────┘
Horizontal scroll, fewer columns visible
User can scroll to see more →
```

## State Diagram

```
                    ┌──────────────┐
                    │ Initial Load │
                    │  (no sort)   │
                    └──────┬───────┘
                           │
                           ↓
                    ┌──────────────┐
                    │  Click Name  │
                    └──────┬───────┘
                           │
                           ↓
                    ┌──────────────┐
                    │  Sort by     │
             ┌──────┤  Name ASC    ├──────┐
             │      └──────────────┘      │
             │                            │
    Click Name Again                  Click Email
             │                            │
             ↓                            ↓
      ┌──────────────┐            ┌──────────────┐
      │  Sort by     │            │  Sort by     │
      │  Name DESC   │            │  Email ASC   │
      └──────┬───────┘            └──────┬───────┘
             │                            │
             │                            │
             └──────────┬─────────────────┘
                        │
                        ↓
                  (continues...)
```

## Styling

### Visual Indicators

Sortable columns show visual feedback:

- **Non-sorted columns**: Normal appearance, hoverable
- **Sorted ascending**: Column name + ↑ arrow
- **Sorted descending**: Column name + ↓ arrow

The arrow indicator uses:
- Primary color: `text-[var(--color-primary)]`
- Bold font weight: `font-bold`
- Left margin: `ms-1` (0.25rem)

### CSS Variables

Customize the appearance:

```css
@theme {
  /* Sortable header colors */
  --color-muted-foreground: oklch(0.45 0.01 250);
  --color-foreground: oklch(0.25 0.02 250);
  --color-primary: oklch(0.55 0.25 270);
}
```

## Accessibility

### Keyboard Navigation

```
┌─────────────────────────────────────────────────┐
│ Name ↑ (Keyboard focusable, screen reader      │
│         announces "Name, sorted ascending,      │
│         click to sort descending")              │
├─────────────────────────────────────────────────┤
│ Proper contrast ratio for text and indicators  │
│ Focus rings visible on keyboard navigation     │
│ Arrow indicators use semantic Unicode chars    │
│ Links have hover/focus states                  │
└─────────────────────────────────────────────────┘

Keyboard Navigation:
- Tab: Move between sortable headers
- Enter/Space: Activate sort
- Shift+Tab: Move backwards
```

### ARIA Attributes

The implementation supports accessible markup:

- Links are keyboard accessible
- Header text announces sort state
- Visual indicators show current sort
- Focus states on clickable headers

## Performance Notes

### Rendering Performance

- Turbo Frame updates only the table, not entire page
- No JavaScript execution for DOM manipulation
- Browser handles HTML replacement natively

### Network Performance

- Only table HTML is transferred
- Gzip compression reduces payload
- HTTP/2 multiplexing for parallel requests

### Database Performance

- Sorting happens at database level (when using ActiveRecord)
- Indexes on sortable columns improve query speed
- Pagination reduces memory usage

Example Query:

```sql
-- Without sorting
SELECT * FROM users;

-- With sorting (indexed column)
SELECT * FROM users ORDER BY name ASC;
-- Uses index on (name) - fast

-- With sorting (non-indexed column)
SELECT * FROM users ORDER BY nickname ASC;
-- Full table scan - slow for large tables
```

## Error States

### No Data

```
┌─────────────────────────────────────────┐
│ Name ↑   Email ▼   Status ▼   Actions  │
├─────────────────────────────────────────┤
│          No data available              │
└─────────────────────────────────────────┘
```

### Invalid Sort Column (Ignored)

```
URL: /tables?sort=invalid_column&direction=asc
↓
Controller validates and ignores invalid column
↓
Returns default (unsorted) data
```

### Invalid Direction (Defaults to ASC)

```
URL: /tables?sort=name&direction=invalid
↓
Controller validates direction
↓
Returns data sorted by name ASC
```

## Browser Support

The sortable tables feature works in all modern browsers:

✅ Chrome 90+
✅ Firefox 88+
✅ Safari 14+
✅ Edge 90+
✅ Mobile Safari iOS 14+
✅ Chrome Android

**Requirements:**
- JavaScript enabled (for Turbo)
- CSS Grid support
- Flexbox support
- CSS Variables support

**Graceful Degradation:**
- Without JavaScript: Falls back to full page reload
- Without CSS Variables: Uses fallback colors
- Without modern CSS: Basic table layout maintained

## API Reference

### Sortable Table Props

```ruby
FlatPack::Table::Component.new(
  data: Array,                # Required
  turbo_frame: String,        # Required for sorting
  sort: String,               # Required for sorting
  direction: String,          # Required for sorting
  base_url: String,           # Required for sorting
  **system_arguments          # Optional
)
```

### Sortable Column Props

```ruby
table.with_column(
  title: String,              # Required
  attribute: Symbol,          # Optional
  sortable: Boolean,          # Optional, default: false
  sort_key: Symbol,           # Optional, defaults to attribute
  html: Proc,            # Optional
  &block                      # Optional
)
```

## Related Components

- [Table Component](table.md) - Main table documentation
- [Sortable Tables](sortable-tables.md) - Detailed implementation guide
- [Button Component](button.md) - Used for actions

## Next Steps

- [Table Component](table.md)
- [Sortable Tables](sortable-tables.md)
- [Turbo Frames](https://turbo.hotwired.dev/handbook/frames)
- [Theming Guide](../theming.md)
