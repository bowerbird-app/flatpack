# Page nav registry

## Purpose
Let a view record page nav for the request. The registry stores the label, the path, and the role, or a component the gem already built. The view or the layout decides what to draw.

## When to use
Use this when a screen has nav that belongs to the page, such as creating a record or deleting it. Page Nav (`FlatPack::PageNav::Component`) is the back and close row. This registry is the page's own items. It does not render them.

A gem emits a role. It does not choose a button style.

## Class
- `register_page_nav` and `page_nav_items` on `FlatPack::PageNavRegistryHelper`
- Registry: `FlatPack::PageNavRegistry`
- One entry: `FlatPack::PageNavItem`
- Role map, used by the caller that draws the buttons: `FlatPack::PageNavRoleStyles`
- Related classes: `FlatPack::Button::Component`, `FlatPack::ButtonGroup::Component`, `FlatPack::Menu::Collapse::Component`, `FlatPack::SidebarLayout::Component`, `FlatPack::PageLayout::Component`

## Props
`register_page_nav` records one entry. It returns nil. `role:` is required in both forms. The name keeps it apart from `flat_pack_page_nav`, which draws the back and close row.

Link:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `label` | String | none | yes | Visible label. A blank label raises `ArgumentError`. |
| `href` | String | none | yes | Path or URL. A blank path raises `ArgumentError`. An unsafe URL raises `ArgumentError`. |
| `role` | Symbol | none | yes | `:primary`, `:secondary`, or `:destructive`. Anything else, including a missing role, raises `ArgumentError`. |
| `icon` | String, Symbol, nil | `nil` | no | Heroicon name, for example `:plus`. |
| `data` | Hash, nil | `nil` | no | For the caller that draws the button. |
| `aria` | Hash, nil | `nil` | no | For the caller that draws the button. |
| `into` | Symbol, String | `:default` | no | Caller-named bucket. `"title"` and `:title` are the same bucket. A blank name, or anything that is not a name, raises `ArgumentError`. |

Component:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `component` | Component | none | yes | A pre-built component instance. The registry stores it. The caller renders it. |
| `role` | Symbol | none | yes | `:primary`, `:secondary`, or `:destructive`. It does not style the component. |
| `into` | Symbol, String | `:default` | no | Caller-named bucket. |

A CSS `class:`, a button `style:`, or any other keyword raises `ArgumentError`. A component entry that also passes a label, a path, an icon, `data:`, or `aria:` raises `ArgumentError`.

`page_nav_items` reads one bucket. It returns the descriptors in registration order. It does not render, and it does not remove the items.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `from` | Symbol, String | `:default` | no | The bucket `into:` used. A bucket with nothing in it returns `[]`. |

A link descriptor answers `label`, `href`, `role`, `icon`, `data`, and `aria`. `component?` is false. A component descriptor answers `role` and `component`. `component?` is true. `label` and `href` are nil.

## Slots
None. The registry has no markup. The caller renders the descriptors.

## Variants
Roles are meaning. Button styles belong to the caller. `FlatPack::PageNavRoleStyles` turns a role into a `FlatPack::Button::Component`. It does not know a layout position.

| map | `:primary` | `:secondary` | `:destructive` | size |
| --- | --- | --- | --- | --- |
| `SOLID` | `:primary` (solid) | `:secondary` (subtle) | `:danger` | `:sm` |
| `QUIET` | `:secondary` (subtle) | `:ghost` | `:danger` | `:sm` |
| `PIN` | `:primary` (solid) |  |  | `:md` |

A caller can pass any map of role → `{style:, size:}`. An unknown role, style, size, or key raises `ArgumentError`. An entry needs both `style` and `size`. `button_for` raises for a component descriptor. Render `item.component` yourself.

`PageLayout` draws the default bucket with `SOLID`. `SidebarLayout` draws it with `QUIET`. Both put links and components in one `FlatPack::ButtonGroup::Component` with `collapse: :menu`, in registration order. The wide layout is the joined row. The narrow layout is that same group as a menu. A component is passed through as the gem built it. The role on a component is metadata. The shell does not restyle it. `mobile_actions: :floating` draws a plain row and pins the primary link with `PIN`. A component stays in the row and is not pinned. A named bucket is left for the view.

There is no `FlatPack.configuration.page_nav_styles`.

## Example
Register in the view. Call this before the shell reads the bucket. In a normal layout the view runs inside the main slot, and the shell reads after that slot.

```erb
<% register_page_nav "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
<% register_page_nav "Share", share_press_kit_path, role: :secondary, icon: :share %>
<% register_page_nav "Delete", press_kit_path, role: :destructive, icon: :trash %>
<% register_page_nav component: publishable_quick_actions, role: :secondary %>
```

`FlatPack::SidebarLayout::Component` and `FlatPack::PageLayout::Component` read `page_nav_items` (the `:default` bucket) and draw it. An empty bucket adds no markup. Items in another bucket stay out of the shell.

Draw a bucket yourself when it should not sit in the shell. This group is the joined row from 768px up, and a menu below that. Each link is in the DOM once.

```erb
<% register_page_nav "Copy link", copy_press_kit_path, role: :secondary, into: :share %>
<% items = page_nav_items(from: :share) %>
<%= render FlatPack::ButtonGroup::Component.new(collapse: :menu, menu_label: "Share") do |group| %>
  <% items.each do |item| %>
    <% child = item.component? ? item.component : FlatPack::PageNavRoleStyles.button_for(item, styles: FlatPack::PageNavRoleStyles::QUIET) %>
    <% group.button child %>
  <% end %>
<% end %>
```

A stack of rows uses `FlatPack::Menu::Collapse::Component` the same way. Read the descriptors, then render the links inside `items`. The registry does not know which one you picked.

`mobile_actions: :floating` is off unless a layout passes it. The dummy does not.

```erb
<%= render FlatPack::SidebarLayout::Component.new(mobile_actions: :floating) do |layout| %>
  <% layout.main do %>
    <% register_page_nav "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
  <% end %>
<% end %>
```

The registry is `FlatPack::PageNavRegistry`, stored at `request.env["flat_pack.page_nav_registry"]`. `page_nav_registry` returns it. Another request does not see it. Do not store the registry on the class.

A component is one DOM node when the caller renders it once. Components such as a publish control replace themselves with a Turbo Stream that targets a fixed wrapper id (`publishable_quick_actions_<id>`). Rendering that descriptor twice puts two nodes with that id on the page. The shells pass the component through once, as a child of the button group, in registration order. With `collapse: :menu` it is in the joined row from 768px up and in that group's menu below that. `mobile_actions: :floating` does not pin it.

## Accessibility
The registry has no elements. The caller gives each link its label. `aria:` is on the descriptor for the caller to forward. On a phone the shell's button group trigger is named "Menu". The panel is `role="group"`. The pinned primary is one link, fixed to the bottom-right, and is hidden from `md` up. A component keeps the accessible name the gem gave it.

## Dependencies
- `FlatPack::PageNavRegistryHelper`, included by the engine on Action View and controllers that respond to `helper`.
- Callers compose `FlatPack::Button::Component`, `FlatPack::ButtonGroup::Component`, or `FlatPack::Menu::Collapse::Component`. The registry does not.
- Shell placement uses `.fp-page-nav`, `.fp-page-nav--desktop`, `.fp-page-nav--bar`, `.fp-page-nav--pin-row`, and `.fp-page-nav--floating` in `flat_pack/application.css`. Spacing uses `--space-2`, `--space-3`, and `--space-4`. The bar inset uses `--layout-content-inset` when the shell sets it. `.fp-page-nav--floating` is the opt-in bottom button. Below `md`, `.fp-page-nav--pin-row` is hidden. The folding menu is the button group's own CSS.
- Dummy: `/demo/page_nav_registry` (Sidebar Layout) and `/demo/page_nav_registry?shell=page` (Page Layout). Both leave `mobile_actions` at `:menu`. The demo registers three links and `PublishableQuickActionsComponent` in the default bucket.
