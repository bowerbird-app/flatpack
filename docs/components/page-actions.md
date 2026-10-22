# Page actions

## Purpose
Let a view nominate page-level actions, collect them for the request, and let the layout decide where they render. `FlatPack::PageActions` only maps a role to a button style and size.

## When to use
Use this when a screen has actions that belong to the page, such as creating a record or deleting it. The view knows the label, the path, the icon, and whether the action is primary, secondary, or destructive. The layout knows the placement.

Pass `component:` when the action is a pre-built component, such as a stateful dropdown, and a link button cannot express it.

Page Nav is the back and close row. Page actions are the page's own buttons.

## Class
- `page_action` and `page_actions` on `FlatPack::PageActionHelper`
- Registry: `FlatPack::PageActionRegistry`
- One action: `FlatPack::PageAction`
- Role to style map: `FlatPack::PageActions`
- Related classes: `FlatPack::Button::Component`, `FlatPack::ButtonGroup::Component`, `FlatPack::TopNav::Component`, `FlatPack::SidebarLayout::Component`, `FlatPack::PageLayout::Component`

## Props
`page_action` nominates one action. It returns nil.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `label` | String | none | for a link | Visible label. A blank label raises `ArgumentError`. Omit it when `component:` is set. |
| `href` | String | none | for a link | Path or URL. A blank path raises `ArgumentError`. An unsafe URL raises `ArgumentError`. Omit it when `component:` is set. |
| `role` | Symbol | `:secondary` | no | `:primary`, `:secondary`, or `:destructive`. Anything else raises `ArgumentError`. Unused when `component:` is set. A component action has no role. |
| `icon` | String, Symbol, nil | `nil` | no | Heroicon name, for example `:plus`. Unused when `component:` is set. |
| `data` | Hash, nil | `nil` | no | Forwarded to the button. Unused when `component:` is set. |
| `aria` | Hash, nil | `nil` | no | Forwarded to the button. Unused when `component:` is set. |
| `component` | Component, nil | `nil` | no | A pre-built component. The layout renders it once, as-is. Something that does not respond to `render_in` raises `ArgumentError`. |

A CSS `class:` or a button `style:` raises `ArgumentError`. The view does not choose placement.

`page_actions` renders the list as a `ButtonGroup` for one context.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `context` | Symbol | none | yes | `:header` or `:top_nav`. Anything else raises `ArgumentError`. |
| `actions` | Array, nil | the request list | no | Actions to render. Omit it to use the request registry. |
| `styles` | Hash, nil | the context map | no | Replaces button `style:` tokens by role. Unknown roles and unknown button styles raise `ArgumentError`. |

`mobile_actions` on Sidebar Layout and Page Layout chooses the phone placement.

| value | default | description |
| --- | --- | --- |
| `:menu` | yes | Rows in the Top Nav hamburger. |
| `:floating` | no | The primary action fixed at the bottom-right. |

Anything else raises `ArgumentError`.

## Slots
None on the helper. `:header` and `:top_nav` render `FlatPack::ButtonGroup::Component` and fill its `button` slot. A component action is rendered beside that group, not inside it. The phone menu renders one `FlatPack::Button::Component` per link action, as a direct row. The floating option renders the primary link as one button. A component action is not in the menu and is not the floating button.

## Variants
Roles are meaning. Button styles are the map's choice. `FlatPack::PageActions::STYLES` is the default map. Values are Button `style:` tokens. `FlatPack::PageActions.size` is `:sm` for both contexts.

| context | `:primary` | `:secondary` | `:destructive` | size | piece |
| --- | --- | --- | --- | --- | --- |
| `:header` | `:primary` (solid) | `:secondary` (subtle) | `:danger` | `:sm` | `ButtonGroup` |
| `:top_nav` | `:secondary` (subtle) | `:ghost` | `:danger` | `:sm` | `ButtonGroup`, and the phone menu rows |

`styles:` replaces any of those tokens for one call. Omitted roles keep the context default.

```erb
<%= page_actions(:header, styles: { primary: :ghost }) %>
```

The floating button uses the `:header` map for the primary role and renders at `:md`.

## Example
Nominate in the view. Call this before the shell renders. In a normal layout the view runs first, so a call in the template is enough.

```erb
<% page_action "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
<% page_action "Share", share_press_kit_path, role: :secondary, icon: :share %>
<% page_action "Delete", press_kit_path, role: :destructive, icon: :trash %>
<% page_action component: RecordingStudioPublishable::QuickActions::Component.new(press_kit) %>
```

`page_action component:` takes the component instance. Label, path, role, icon, `data:`, and `aria:` are unused. The layout renders that instance once, through the same button path the link actions use, and does not build a role or a button style for it.

Link actions are drawn twice: once in the desktop group and again as rows in the phone menu. A component action is not. The component is one node in the desktop bar. Below the `md` breakpoint that bar stays visible for the component, and the link buttons in the same bar stay hidden. The phone menu does not get a second copy.

That matters when the component replaces itself with a Turbo Stream aimed at one wrapper id, such as `publishable_quick_actions_<id>`. A second node with that id makes the replace hit the wrong copy. The component is also not eligible for `mobile_actions: :floating`, and a dropdown is not split into menu rows.

`FlatPack::SidebarLayout::Component` reads the registry. From the `md` breakpoint up it renders `page_actions(:top_nav)` in a bar under the top nav. Below that, the link actions are rows in the Top Nav hamburger. A component action stays in that bar at both widths. `FlatPack::PageLayout::Component` does the same with `page_actions(:header)` at the top of the column, and the same phone menu. An empty registry adds no markup.

The host Top Nav keeps its mobile menu (the default). The shell inserts the rows into that menu. A shell with no top nav renders one, hidden from `md` up, so the desktop group stays where it was.

```erb
<%= render FlatPack::SidebarLayout::Component.new(mobile_actions: :floating) do |layout| %>
  <% layout.main do %>
    <% page_action "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
  <% end %>
<% end %>
```

`mobile_actions: :floating` is off unless a layout passes it. The dummy does not.

A custom layout reads the same registry and places the HTML itself. Put the result in an existing slot. Do not restyle the buttons.

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.right do %>
    <%= page_actions(:top_nav) %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::PageTitle::Component.new(title: "Press kit") do |title| %>
  <% title.slot do %>
    <%= page_actions(:header) %>
  <% end %>
<% end %>
```

The registry is `FlatPack::PageActionRegistry`, stored at `request.env["flat_pack.page_actions"]`. `page_action_registry` returns it. Actions stay in source order. Another request does not see them. Do not store the registry on the class.

## Accessibility
Each link action is a link with the nominated label. `aria:` is forwarded. On a phone the links are rows in the Top Nav menu named "Menu". The floating primary is one link, fixed to the bottom-right, and is hidden from `md` up. A component action keeps the name and behaviour it already has. It sits in the action bar on a wide window and on a phone. The desktop group is not a landmark. The buttons carry their own names.

## Dependencies
- `FlatPack::PageActionHelper`, included by the engine on Action View and controllers that respond to `helper`.
- `FlatPack::Button::Component` and `FlatPack::ButtonGroup::Component`.
- The phone menu uses `flat-pack--top-nav`. The controller moves the rows into the open panel.
- Shell placement uses `.fp-page-actions`, `.fp-page-actions--desktop`, `.fp-page-actions--bar`, `.fp-page-actions-menu`, `.fp-page-actions-nav`, `.fp-page-actions-component`, and `.fp-page-actions--floating` in `flat_pack/application.css`. Spacing uses `--space-2`, `--space-3`, and `--space-4`. The bar inset uses `--layout-content-inset` when the shell sets it. `.fp-page-actions--floating` is the opt-in bottom button. `.fp-page-actions-component` marks the single component node. Below `md`, the desktop bar stays visible when that node is present, and the link group in the same bar is hidden.
- Dummy: `/demo/page_actions` (Sidebar Layout) and `/demo/page_actions?shell=page` (Page Layout). Both leave `mobile_actions` at `:menu`.
