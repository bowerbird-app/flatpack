# Grid

## Purpose
Lay out block content in responsive CSS grid columns with configurable gaps, alignment, page justification, and optional max width.

## When to use
Use Grid for card collections, dashboards, and responsive sections that need predictable spacing and column behavior. For a single form stack (login/signup), use `cols: 1` with `justify: :center` and `max: :sm` so the column matches a form/card width and sits in the middle of the page — do not misuse `cols: 2` as a width cap, and do not rely on `align: :center` (that is `items-center`, not page centering).

## Class
- Primary: `FlatPack::Grid::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `cols` | Symbol or Integer | `:auto` | No | Column preset. Allowed: `:auto`, `1`, `2`, `3`, `4`, `6`, `12`. |
| `gap` | Symbol | `:md` | No | Gap preset. Allowed: `:sm`, `:md`, `:lg`. |
| `align` | Symbol | `:stretch` | No | Item alignment preset (`items-*`). Allowed: `:start`, `:center`, `:stretch`. |
| `justify` | Symbol | `:start` | No | Places the grid box on the page. Allowed: `:start`, `:center`. `:center` applies `mx-auto` so a max-width column can sit in the middle of the page. |
| `max` | Symbol or nil | `nil` | No | Caps the grid box width. Allowed: `:sm` (`max-w-sm w-full`, same size language as Modal `size: :sm`), or `nil` for no cap. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into grid container. |

## Slots
Default block content; each child element participates as a grid item.

## Variants

| variant | description |
|---------|-------------|
| `cols: :auto` | Responsive preset `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4`. |
| `cols: 2/3/4/6/12` | Fixed preset mappings defined in component constants. |
| `gap: :sm/:md/:lg` | Applies `gap-2`, `gap-4`, or `gap-6`. |
| `align: :start/:center/:stretch` | Applies `items-start`, `items-center`, or `items-stretch`. |
| `justify: :start/:center` | Default start; `:center` applies `mx-auto`. |
| `max: :sm` | Applies `max-w-sm w-full` (Modal `sm` width). |

## Example

```erb
<%= render FlatPack::Grid::Component.new(cols: 3, gap: :md, align: :stretch) do %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 1" } %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 2" } %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 3" } %>
<% end %>
```

### Centered form stack (auth)

```erb
<%= render FlatPack::Grid::Component.new(cols: 1, justify: :center, max: :sm) do %>
  <%= render FlatPack::EmailInput::Component.new(name: "email", label: "Email") %>
  <%= render FlatPack::PasswordInput::Component.new(name: "password", label: "Password") %>
  <%= render FlatPack::Button::Component.new(text: "Sign in", style: :primary, class: "w-full") %>
<% end %>
```

Optional drag-reorder pattern in demos can be composed with Stimulus `flat-pack--grid-sortable` by wrapping grid items with `data-flat-pack--grid-sortable-target="item"` and `data-id`.

## Accessibility
Grid is structural layout only. Accessibility is determined by the semantics of content rendered inside each grid item.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional drag-reorder integration uses Stimulus controller `flat-pack--grid-sortable`.
