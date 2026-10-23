# Button Dropdown

## Purpose
Provide a button-triggered action menu with keyboard navigation and managed open/close behavior.
The menu is floated with viewport positioning so it can escape clipped cards, panels, and sidebars.

## When to use
Use Button Dropdown when multiple related actions should be grouped behind a single trigger.

## Class
- Primary: `FlatPack::Button::Dropdown::Component`
- Related classes: `FlatPack::Button::DropdownItem::Component`, `FlatPack::Button::DropdownDivider::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Trigger label. On `icon_only: true`, this is the accessible name (`aria-label`) and is not shown. Pass `""` when `trigger_attributes` already sets `aria-label`. |
| `style` | Symbol | `:default` | no | Trigger style. Built-in button styles plus any name registered with `FlatPack::Button.register_style`. Invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Trigger size. Delegates to `FlatPack::Button::Component` (`:sm`, `:md`, `:lg`, and icon-only `:xs`). `:xs` without `icon_only: true` raises `ArgumentError`. |
| `round` | Boolean | `false` | no | `true` uses `FlatPack::Button::Component::ROUND_RADIUS_CLASS` (`--button-round-border-radius`). A label becomes a pill. `icon_only: true` also applies `ROUND_ICON_ONLY_SIZES`, so the trigger is a circle. `false` keeps `--button-border-radius`. Anything other than `true` or `false` raises `ArgumentError`. |
| `icon` | String/Symbol | `nil` | no | Optional leading icon. Required when `icon_only: true`. A missing icon raises `ArgumentError`. |
| `icon_variant` | Symbol, nil | `nil` | no | `:outline`, `:solid`, `:mini`, or `:micro` on the leading icon. Omit to use `default_icon_variant`. The chevron stays on that default. Unknown names raise `ArgumentError`. |
| `icon_style` | Symbol, nil | `nil` | no | `nil` inherits the trigger text. `:primary`, `:success`, `:warning`, or `:danger` colour the leading icon the same way as Button. The chevron stays the trigger text colour. Unknown names raise `ArgumentError`. |
| `icon_only` | Boolean | `false` | no | Hides the label, drops the chevron, and uses Button `ICON_ONLY_SIZES`. `:sm`, `:md`, and `:lg` add `fp-hit-target`. `:xs` adds `fp-hit-slop` so the painted trigger stays about 32px and the tap stays 44px. Needs `icon:` and an accessible name (`text:` or `trigger_attributes: { aria: { label: } }`). Always pass an `aria-label`. A blank name raises `ArgumentError`. Leave about 12px before the next `:xs` control or the tap areas overlap. |
| `show_chevron` | Boolean | `nil` | no | Omitted or `nil` shows the chevron on a labeled trigger and hides it when `icon_only: true`. `false` hides it. `true` with `icon_only: true` raises `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Disables trigger interaction and applies disabled styling. |
| `placement` | Symbol | `:bottom_right` | no | Menu placement: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`; invalid values raise `ArgumentError`. |
| `max_height` | String | `"384px"` | no | Applied to menu `max-height` style; menu scrolls when content exceeds this value. |
| `trigger_attributes` | Hash | `{}` | no | HTML attributes on the trigger. Use `aria: { label: }` for an icon-only name when `text` is blank. `aria-haspopup` and `aria-expanded` stay on the button. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
Use `menu_item` and `menu_divider` as the slot builders (without a `with_` prefix).

| name | type | required | description |
|---|---|---|---|
| `menu_item` | slot | no | Adds `FlatPack::Button::DropdownItem::Component` entries. |
| `menu_divider` | slot | no | Adds `FlatPack::Button::DropdownDivider::Component` separators. |
| `menu_html` | method | no | Places already-rendered HTML in the menu, in call order with `menu_item` and `menu_divider`. Button Group uses it for each overflow child's `menu_row`. |

`menu_item` props:

| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Item label text. |
| `icon` | String/Symbol | `nil` | no | Optional leading icon. |
| `icon_variant` | Symbol, nil | `nil` | no | `:outline`, `:solid`, `:mini`, or `:micro` on that icon. Omit to use `default_icon_variant`. Unknown names raise `ArgumentError`. |
| `icon_style` | Symbol, nil | `nil` | no | `nil` inherits the item text. `:primary`, `:success`, `:warning`, or `:danger` use the button icon tokens. Unknown names raise `ArgumentError`. |
| `badge` | String | `nil` | no | Optional badge content. |
| `badge_style` | Symbol | `:primary` | no | Badge style: `:default`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`, `:info`; invalid values raise `ArgumentError` when badge is present. |
| `href` | String | `nil` | no | Link destination. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Makes item non-focusable and non-interactive. |
| `destructive` | Boolean | `false` | no | Applies destructive visual treatment. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for item element. |

## Variants
- Position variants: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. The menu is `fixed` and positioned from the trigger rectangle, including a small icon-only trigger.
- Trigger visual variants come from button `style`, `size`, `round`, and `icon_only`, including host-registered button styles.

## Example
```erb
<%= render FlatPack::Button::Dropdown::Component.new(text: "Actions", placement: :bottom_right) do |dropdown| %>
  <% dropdown.menu_item(text: "Edit", href: edit_post_path(@post)) %>
  <% dropdown.menu_divider %>
  <% dropdown.menu_item(text: "Delete", destructive: true) %>
<% end %>
```

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "Publish",
  icon: "check-circle",
  icon_variant: :solid,
  icon_style: :success
) do |dropdown| %>
  <% dropdown.menu_item(text: "Publish now", icon: "check-circle", icon_variant: :solid, icon_style: :success, href: "#") %>
  <% dropdown.menu_item(text: "Unpublish", icon: "x-circle", icon_style: :danger, href: "#") %>
<% end %>
```

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "",
  icon: "ellipsis-vertical",
  style: :ghost,
  size: :sm,
  show_chevron: false,
  trigger_attributes: {
    title: "Conversation actions",
    aria: { label: "Conversation actions" }
  }
) do |dropdown| %>
  <% dropdown.menu_item(text: "Search conversation", icon: "magnifying-glass", href: "#") %>
  <% dropdown.menu_item(text: "Archive", icon: "folder", href: "#") %>
<% end %>
```

A round heart on a photo. `text` is the accessible name. The chevron stays off.

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "Add to list",
  icon: "heart",
  icon_only: true,
  round: true,
  size: :lg,
  style: :primary
) do |dropdown| %>
  <% dropdown.menu_item(text: "Favorites", icon: "heart", href: "#") %>
  <% dropdown.menu_item(text: "Weekend", icon: "calendar", href: "#") %>
<% end %>
```

`:xs` matches the icon-only button. The painted trigger is about 32px. The tap area stays 44px, so leave about 12px before the next control. Pass an `aria-label`.

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "Share",
  icon: "share",
  icon_only: true,
  round: true,
  size: :xs,
  trigger_attributes: { aria: { label: "Share" } }
) do |dropdown| %>
  <% dropdown.menu_item(text: "Copy link", href: "#") %>
<% end %>
```

Square icon trigger. Omit `round` and the theme corner stays.

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "Add",
  icon: "plus",
  icon_only: true,
  size: :lg,
  style: :secondary
) do |dropdown| %>
  <% dropdown.menu_item(text: "Photo", href: "#") %>
  <% dropdown.menu_item(text: "Note", href: "#") %>
<% end %>
```

## Collapsing button group
`menu_row` is the menu form used by [Button Group](button-group.md). `collapse: :menu` uses it in the phone menu. An overflow menu uses it when this dropdown did not stay in the row. It renders this dropdown as [Menu Collapse](menu-collapse.md): `text` and `icon` are the header, and the menu items sit underneath. The wide control stays this dropdown. A dropdown that is the group's direct child takes the segment shape on its root. The trigger copies that box. The group does not style the trigger itself.

## Accessibility
- Trigger uses `aria-haspopup="true"` and toggles `aria-expanded`.
- `icon_only: true` sets `aria-label` from `text` unless `trigger_attributes` already has one. The visible label is omitted. A blank `text` and a blank label raise `ArgumentError`.
- Menu uses `role="menu"`; items use `role="menuitem"`; divider uses `role="separator"`.
- Keyboard behavior supports `Escape`, arrow navigation, `Home`, and `End`.
- Menu origin follows placement. Enter/exit uses `--duration-base` with `--easing-enter` / `--easing-exit` and scale-95, not scale-0. A close in flight can reverse.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--button-dropdown`.
