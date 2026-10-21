# Page actions

## Purpose
Let a view nominate page-level actions, collect them for the request, and let the layout decide where they render and how each role looks.

## When to use
Use this when a screen has actions that belong to the page, such as creating a record or deleting it. The view knows the label, the path, the icon, and whether the action is primary, secondary, or destructive. The layout knows the placement.

Page Nav is the back and close row. Page actions are the page's own buttons.

## Class
- `page_action` and `page_actions` on `FlatPack::PageActionHelper`
- Registry: `FlatPack::PageActionRegistry`
- One action: `FlatPack::PageAction`
- Role to style map and renderer: `FlatPack::PageActions`
- Related classes: `FlatPack::Button::Component`, `FlatPack::ButtonGroup::Component`, `FlatPack::Button::Dropdown::Component`, `FlatPack::SidebarLayout::Component`, `FlatPack::PageLayout::Component`

## Props
`page_action` nominates one action. It returns nil.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `label` | String | none | yes | Visible label. A blank label raises `ArgumentError`. |
| `href` | String | none | yes | Path or URL. A blank path raises `ArgumentError`. An unsafe URL raises `ArgumentError`. |
| `role` | Symbol | `:secondary` | no | `:primary`, `:secondary`, or `:destructive`. Anything else raises `ArgumentError`. |
| `icon` | String, Symbol, nil | `nil` | no | Heroicon name, for example `:plus`. |
| `data` | Hash, nil | `nil` | no | Forwarded to the button or menu item. |
| `aria` | Hash, nil | `nil` | no | Forwarded to the button or menu item. |

A CSS `class:` or a button `style:` raises `ArgumentError`. The view does not choose placement.

`page_actions` renders a list for one context.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `context` | Symbol | none | yes | `:header`, `:top_nav`, or `:mobile`. Anything else raises `ArgumentError`. |
| `actions` | Array, nil | the request list | no | Actions to render. Omit it to use the request registry. |
| `styles` | Hash, nil | the context map | no | Replaces button `style:` tokens by role. Unknown roles and unknown button styles raise `ArgumentError`. |

## Slots
None on the helper. `:header` and `:top_nav` render `FlatPack::ButtonGroup::Component` and fill its `button` slot. `:mobile` renders the first action as a button and the rest through `FlatPack::Button::Dropdown::Component` `menu_item` slots. The trigger is icon-only `ellipsis-horizontal`. Its accessible name is `flatpack.page_actions.more` (`More`).

## Variants
Roles are meaning. Button styles are the layout's choice. `FlatPack::PageActions::STYLES` is the default map. Values are Button `style:` tokens.

| context | `:primary` | `:secondary` | `:destructive` | size | piece |
| --- | --- | --- | --- | --- | --- |
| `:header` | `:primary` (solid) | `:secondary` (subtle) | `:danger` | `:sm` | `ButtonGroup` |
| `:top_nav` | `:secondary` (subtle) | `:ghost` | `:danger` | `:sm` | `ButtonGroup` |
| `:mobile` | `:primary` (solid) | `:secondary` | `:danger` | `:md` on the first action | first action, then the ⋯ menu |

On `:mobile`, the first action in source order is the visible button. Its style comes from the mobile row above. Later actions are menu items, in source order. A `:destructive` item sets `destructive: true` on the menu item.

`styles:` replaces any of those tokens for one call. Omitted roles keep the context default.

```erb
<%= page_actions(:header, styles: { primary: :ghost }) %>
```

## Example
Nominate in the view. Call this before the shell renders. In a normal layout the view runs first, so a call in the template is enough.

```erb
<% page_action "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
<% page_action "Share", share_press_kit_path, role: :secondary, icon: :share %>
<% page_action "Delete", press_kit_path, role: :destructive, icon: :trash %>
```

`FlatPack::SidebarLayout::Component` reads the registry. From the `md` breakpoint up it renders `page_actions(:top_nav)` in a bar under the top nav. Below that it renders `page_actions(:mobile)`, fixed to the bottom-right. `FlatPack::PageLayout::Component` does the same with `page_actions(:header)` at the top of the column. An empty registry adds no markup.

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
Each action is a link with the nominated label. `aria:` is forwarded. The ⋯ trigger is icon-only and is named `More` (`aria-label`). Destructive menu items use the dropdown item's destructive treatment. The shell cluster is not a landmark. The buttons carry their own names.

## Dependencies
- `FlatPack::PageActionHelper`, included by the engine on Action View and controllers that respond to `helper`.
- `FlatPack::Button::Component`, `FlatPack::ButtonGroup::Component`, and `FlatPack::Button::Dropdown::Component`.
- `flatpack.page_actions.more` in `config/locales/flatpack.en.yml`.
- Shell placement uses `.fp-page-actions`, `.fp-page-actions--desktop`, `.fp-page-actions--mobile`, and `.fp-page-actions--bar` in `flat_pack/application.css`. Spacing uses `--space-2`, `--space-3`, and `--space-4`. The bar inset uses `--layout-content-inset` when the shell sets it.
- The ⋯ menu uses the `flat-pack--button-dropdown` controller.
- Dummy: `/demo/page_actions` (Sidebar Layout) and `/demo/page_actions?shell=page` (Page Layout).
