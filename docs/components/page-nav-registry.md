# Page nav registry

## Purpose
Let a view register page nav, keep it for the request, and let Flatpack render it. The view chooses the label, the path, and the role, or hands over a component the gem already built. The host chooses how a role looks.

## When to use
Use this when a screen has nav that belongs to the page, such as creating a record or deleting it. Page Nav (`FlatPack::PageNav::Component`) is the back and close row. This registry is the page's own buttons.

A gem emits a role. It does not write the style map.

## Class
- `page_nav` and `render_page_nav` on `FlatPack::PageNavRegistryHelper`
- Registry: `FlatPack::PageNavRegistry`
- One entry: `FlatPack::PageNavItem`
- Role map: `FlatPack::PageNav`
- Related classes: `FlatPack::Button::Component`, `FlatPack::ButtonGroup::Component`, `FlatPack::TopNav::Component`, `FlatPack::SidebarLayout::Component`, `FlatPack::PageLayout::Component`

## Props
`page_nav` registers one entry. It returns nil. `role:` is required in both forms.

Semantic item:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `label` | String | none | yes | Visible label. A blank label raises `ArgumentError`. |
| `href` | String | none | yes | Path or URL. A blank path raises `ArgumentError`. An unsafe URL raises `ArgumentError`. |
| `role` | Symbol | none | yes | `:primary`, `:secondary`, or `:destructive`. Anything else, including a missing role, raises `ArgumentError`. |
| `icon` | String, Symbol, nil | `nil` | no | Heroicon name, for example `:plus`. |
| `data` | Hash, nil | `nil` | no | Forwarded to the button. |
| `aria` | Hash, nil | `nil` | no | Forwarded to the button. |

Component item:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `component` | Component | none | yes | A pre-built component instance. Rendered as the gem built it. |
| `role` | Symbol | none | yes | `:primary`, `:secondary`, or `:destructive`. Places and orders the component. Does not style it. |

A CSS `class:`, a button `style:`, or any other keyword raises `ArgumentError`. A component entry that also passes a label, a path, an icon, `data:`, or `aria:` raises `ArgumentError`.

`render_page_nav` is the only renderer. Layouts call it. A view calls it to render the registered nav inline, for example under a page title.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `context` | Symbol | none | yes | `:header` or `:top_nav`. Anything else raises `ArgumentError`. |
| `styles` | Hash, nil | none | no | Layout map, keyed context → role → `{style:, size:}`. Merged over the host map. Unknown contexts, roles, styles, sizes, or keys raise `ArgumentError`. |
| `place` | Symbol | `:group` | no | `:group` (desktop and inline), `:menu`, or `:floating`. Anything else raises `ArgumentError`. |

`mobile_actions` on Sidebar Layout and Page Layout chooses the phone placement for semantic buttons.

| value | default | description |
| --- | --- | --- |
| `:menu` | yes | Rows in the Top Nav hamburger. |
| `:floating` | no | The primary semantic button fixed at the bottom-right, at size `:md`. |

Anything else raises `ArgumentError`.

## Slots
None on the helper. `:group` renders semantic items as `FlatPack::ButtonGroup::Component`. A component entry is rendered beside that group, not inside it. `:menu` renders one `FlatPack::Button::Component` per semantic item. `:floating` renders the primary semantic item as one button. Components are left out of `:menu` and `:floating`.

## Variants
Roles are meaning. Button styles are the host's choice. `FlatPack::PageNav::DEFAULT_STYLES` is the default map. Values are Button `style:` and `size:` tokens.

| context | `:primary` | `:secondary` | `:destructive` | size |
| --- | --- | --- | --- | --- |
| `:header` | `:primary` (solid) | `:secondary` (subtle) | `:danger` | `:sm` |
| `:top_nav` | `:secondary` (subtle) | `:ghost` | `:danger` | `:sm` |

Resolution order for one context:

1. The `styles:` map passed to `render_page_nav`.
2. `FlatPack.configuration.page_nav_styles`, set once in an initializer.
3. `FlatPack::PageNav::DEFAULT_STYLES`.

A partial map replaces only the roles and keys it names. Omitted roles keep the layer below. A gem does not set `page_nav_styles`.

```ruby
FlatPack.configure do |config|
  config.page_nav_styles = {
    header: {primary: {style: :ghost, size: :md}}
  }
end
```

```erb
<%= render_page_nav(:header, styles: { header: { primary: { style: :secondary } } }) %>
```

The floating button uses the `:header` map for the primary role and renders at `:md`.

## Example
Register in the view. Call this before the shell renders. In a normal layout the view runs first, so a call in the template is enough.

```erb
<% page_nav "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
<% page_nav "Share", share_press_kit_path, role: :secondary, icon: :share %>
<% page_nav "Delete", press_kit_path, role: :destructive, icon: :trash %>
<% page_nav component: publishable_quick_actions, role: :secondary %>
```

`render_page_nav` reads the registry. Semantic items become buttons for the context. Component items render as they are, in role order (`:primary`, then `:secondary`, then `:destructive`), and only on the first `:group` call.

`FlatPack::SidebarLayout::Component` calls `render_page_nav(:top_nav)` in a bar under the top nav, and `render_page_nav(:top_nav, place: :menu)` for the phone rows. `FlatPack::PageLayout::Component` does the same with `render_page_nav(:header)` at the top of the column. An empty registry adds no markup.

A component is one DOM node. It is not copied into the phone menu. Components such as a publish control replace themselves with a Turbo Stream that targets a fixed wrapper id (`publishable_quick_actions_<id>`). A second node with that id breaks the stream. The bar keeps the component. Below the `md` breakpoint the semantic button group is hidden and the component stays in the bar, so it is reachable on a phone and on a desktop. Semantic buttons have no such limit. They render in the desktop group and again as menu rows.

The host Top Nav keeps its mobile menu (the default). The shell inserts the semantic rows into that menu. A shell with no top nav renders one, hidden from `md` up.

```erb
<%= render FlatPack::SidebarLayout::Component.new(mobile_actions: :floating) do |layout| %>
  <% layout.main do %>
    <% page_nav "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
  <% end %>
<% end %>
```

`mobile_actions: :floating` is off unless a layout passes it. The dummy does not.

A view can render the same nav inline. This is the same helper the shells call.

```erb
<%= render FlatPack::PageTitle::Component.new(title: "Press kit") do |title| %>
  <% title.slot do %>
    <%= render_page_nav(:header) %>
  <% end %>
<% end %>
```

The first `:group` render takes the components. A later call, including the shell bar, does not render them again.

The registry is `FlatPack::PageNavRegistry`, stored at `request.env["flat_pack.page_nav_registry"]`. `page_nav_registry` returns it. Items stay in source order. Another request does not see them. Do not store the registry on the class.

## Accessibility
Each semantic item is a link with the registered label. `aria:` is forwarded. On a phone those links are rows in the Top Nav menu named "Menu". The floating primary is one link, fixed to the bottom-right, and is hidden from `md` up. The desktop group is not a landmark. The buttons carry their own names. A component keeps the accessible name the gem gave it.

## Dependencies
- `FlatPack::PageNavRegistryHelper`, included by the engine on Action View and controllers that respond to `helper`.
- `FlatPack::Button::Component` and `FlatPack::ButtonGroup::Component` for semantic items.
- The phone menu uses `flat-pack--top-nav`. The controller moves the semantic rows into the open panel.
- Shell placement uses `.fp-page-nav`, `.fp-page-nav--desktop`, `.fp-page-nav--bar`, `.fp-page-nav-buttons`, `.fp-page-nav-components`, `.fp-page-nav-menu`, `.fp-page-nav-nav`, and `.fp-page-nav--floating` in `flat_pack/application.css`. Spacing uses `--space-2`, `--space-3`, and `--space-4`. The bar inset uses `--layout-content-inset` when the shell sets it. `.fp-page-nav--floating` is the opt-in bottom button. Below `md`, `.fp-page-nav--desktop` hides when it has no `.fp-page-nav-components`. When it has components, only `.fp-page-nav-buttons` hides.
- Dummy: `/demo/page_nav_registry` (Sidebar Layout) and `/demo/page_nav_registry?shell=page` (Page Layout). Both leave `mobile_actions` at `:menu`. The demo registers three semantic items and `PublishableQuickActionsComponent`.
