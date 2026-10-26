# Page nav registry

## Purpose
Let a view record page nav for the request. The registry stores the label, the path, and the role, or a component the gem already built. The view or the layout decides what to draw.

## When to use
Use this when a screen has nav that belongs to the page, such as creating a record or deleting it. Page Nav (`FlatPack::PageNav::Component`) is the back and close row. This registry is the page's own items. It does not render them.

A gem emits a role. It does not choose a button style.

## Class
- `register_page_nav`, `page_nav_items`, and `page_nav_button_group` on `FlatPack::PageNavRegistryHelper`
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
| `overflow` | Boolean, nil | `nil` | no | Passed to the child when `page_nav_button_group` draws the bucket. `true` forces that child into the group's overflow menu. `false` keeps it in the row. Omit it and the group's `visible:` decides. Anything other than `true`, `false`, or omitted raises `ArgumentError`. |

Component:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `component` | Component | none | yes | A pre-built component instance. The registry stores it. The caller renders it. |
| `role` | Symbol | none | yes | `:primary`, `:secondary`, or `:destructive`. It does not style the component. |
| `into` | Symbol, String | `:default` | no | Caller-named bucket. |
| `overflow` | Boolean, nil | `nil` | no | Same as on a link. It does not restyle the component. |

A CSS `class:`, a button `style:`, or any other keyword raises `ArgumentError`. A component entry that also passes a label, a path, an icon, `data:`, or `aria:` raises `ArgumentError`. `overflow:` is allowed on a link and on a component.

`page_nav_items` reads one bucket. It returns the descriptors in registration order. It does not render, and it does not remove the items.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `from` | Symbol, String | `:default` | no | The bucket `into:` used. A bucket with nothing in it returns `[]`. |

A link descriptor answers `label`, `href`, `role`, `icon`, `data`, `aria`, and `overflow`. `component?` is false. A component descriptor answers `role`, `component`, and `overflow`. `component?` is true. `label` and `href` are nil.

`page_nav_button_group` renders one `FlatPack::ButtonGroup::Component` for a bucket, in registration order. It returns nil when that bucket is empty.

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `styles` | Hash | none | yes | Role map. `FlatPack::PageNavRoleStyles::SOLID`, `QUIET`, `PIN`, or a caller's own role → `{style:, size:}`. A link uses the entry for its role. A component ignores the map. A missing role raises `ArgumentError`. |
| `from` | Symbol, String | `:default` | no | The bucket `into:` used. |
| `variant` | Symbol, String | `:joined` | no | Passed to the button group. `:joined` merges the row. `:outlined` is the bordered desktop container. Anything else raises `ArgumentError`. See [Button Group](button-group.md). |
| `style` | Symbol, String | `:default` | no | Passed to the button group. On `:outlined`, the container sets `data-fp-style` and paints `--fp-button-background` and `--fp-button-border`. `:joined` does not set the attribute. An unknown name raises `ArgumentError`. See [Button Group](button-group.md). |
| `collapse` | false or Symbol | `false` | no | Passed to the button group. `false` keeps the row. `:menu` is that row from 768px up and a menu below it. Anything else raises `ArgumentError`. |
| `visible` | Integer, nil | `nil` | no | Passed to the button group. The first that many children stay in the row. `overflow:` on an entry wins. See [Button Group](button-group.md). |
| `overflow_label` | String, nil | `nil` | no | Passed to the button group. Visible text on the overflow trigger. Omit it and the trigger is an icon named "More". |
| `overflow_icon` | String, Symbol, nil | `nil` | no | Passed to the button group. Replaces the default ellipsis or chevron. See [Button Group](button-group.md). |

## Slots
None. The registry has no markup. The caller renders the descriptors.

## Variants
Roles are meaning. Button styles belong to the caller. `FlatPack::PageNavRoleStyles` turns a role into a `FlatPack::Button::Component`. It does not know a layout position.

| map | `:primary` | `:secondary` | `:destructive` | size |
| --- | --- | --- | --- | --- |
| `SOLID` | `:primary` (solid) | `:secondary` (subtle) | `:danger` | `:sm` |
| `QUIET` | `:secondary` (subtle) | `:secondary` (bordered subtle) | `:danger` | `:sm` |
| `PIN` | `:primary` (solid) |  |  | `:md` |

A caller can pass any map of role → `{style:, size:}`. An unknown role, style, size, or key raises `ArgumentError`. An entry needs both `style` and `size`. `button_for` raises for a component descriptor. Render `item.component` yourself.

`page_nav_button_group` puts links and components in one group, in registration order. A component is passed through as the gem built it. The role on a component is metadata. The helper does not restyle it. `collapse: :menu` is the joined row from 768px up and that same group as a menu below that.

`SidebarLayout` and `PageLayout` do not read the registry and do not place the buttons. Register the items, then call `page_nav_button_group` in the page markup. A call before any `register_page_nav` for that bucket returns nil. The host chooses where the group sits. A flex row with the title on the left and the group on the right is one layout. The shells do not assume another.

The page-nav registry demo does that. Sidebar Layout uses `QUIET`. Page Layout uses `SOLID`. Both pass `collapse: :menu`. A named bucket stays out of that call. Pass `from:`.

`PIN` is the medium solid primary map. Nothing in the shells pins a button. A host that wants that link renders it with `button_for` and `PIN`.

There is no `FlatPack.configuration.page_nav_styles`.

## Example
Register before calling the helper. The helper reads whatever is already in the bucket.

```erb
<% register_page_nav "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
<% register_page_nav "Share", share_press_kit_path, role: :secondary, icon: :share %>
<% register_page_nav "Delete", press_kit_path, role: :destructive, icon: :trash, overflow: true %>
<% register_page_nav component: publishable_quick_actions, role: :secondary %>

<div class="flex items-center justify-between gap-4">
  <h1 class="m-0">Press kit</h1>
  <%= page_nav_button_group(styles: FlatPack::PageNavRoleStyles::QUIET, collapse: :menu) %>
</div>
```

Delete sits under More. The phone menu still lists every registered item once.

Page Layout uses `FlatPack::PageNavRoleStyles::SOLID` in that same kind of row.

Draw another bucket anywhere. This is the joined row from 768px up, and a menu below that. Each link is in the DOM once.

```erb
<% register_page_nav "Copy link", copy_press_kit_path, role: :secondary, into: :share %>
<%= page_nav_button_group(from: :share, styles: FlatPack::PageNavRoleStyles::QUIET, collapse: :menu) %>
```

A stack of rows uses `FlatPack::Menu::Collapse::Component`. Read `page_nav_items`, then render the links inside `items`. The registry does not know which one you picked.

The registry is `FlatPack::PageNavRegistry`, stored at `request.env["flat_pack.page_nav_registry"]`. `page_nav_registry` returns it. Another request does not see it. Do not store the registry on the class.

The helper passes a component through once, as a child of the button group, in registration order. With `collapse: :menu`, `call` is the joined control from 768px up and `menu_row` is the phone row below that. Put the Turbo id on `call` (`publishable_quick_actions_<id>`). `menu_row` must not repeat it, or a stream that replaces that id matches two nodes. `overflow: true` leaves `call` out of the row. `menu_row` is the More row and, with `collapse: :menu`, the phone row as well. Keep the id off `menu_row` there too, because both rows are in the page.

## Accessibility
The registry has no elements. The caller gives each link its label. `aria:` is on the descriptor for the caller to forward. `page_nav_button_group` forwards `aria:` and `data:` onto the link. With `collapse: :menu` the button group trigger is named "Menu" and the panel is `role="group"`. A component keeps the accessible name the gem gave it.

## Dependencies
- `FlatPack::PageNavRegistryHelper`, included by the engine on Action View and controllers that respond to `helper`.
- `page_nav_button_group` renders `FlatPack::ButtonGroup::Component`. A stack of rows still composes `FlatPack::Menu::Collapse::Component` from `page_nav_items`. The registry does not render.
- The folding menu is the button group's own CSS. The open panel is `position: absolute` with `z-index: 50` on `.fp-button-group-menu__panel`, so it paints above the page content around the group.
- Dummy: `/demo/page_nav_registry` (Sidebar Layout, `QUIET`) and `/demo/page_nav_registry?shell=page` (Page Layout, `SOLID`). Both pass `collapse: :menu`. The demo registers three links and `PublishableQuickActionsComponent` in the default bucket. Delete is registered with `overflow: true`, so the wide row ends in More and the phone menu still lists every item once.
