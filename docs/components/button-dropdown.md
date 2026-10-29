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
| `icon` | String/Symbol | `nil` | no | Optional leading icon on the trigger, passed through to `FlatPack::Button::Component`. A trusted `<svg` string works the same as on Button. Required when `icon_only: true`. A missing icon raises `ArgumentError`. |
| `icon_variant` | Symbol, nil | `nil` | no | `:outline`, `:solid`, `:mini`, or `:micro` on the leading icon. Omit to use `default_icon_variant`. The chevron stays on that default. Unknown names raise `ArgumentError`. |
| `icon_style` | Symbol, nil | `nil` | no | `nil` inherits the trigger text. `:primary`, `:success`, `:warning`, or `:danger` colour the leading icon the same way as Button. The chevron stays the trigger text colour. Unknown names raise `ArgumentError`. |
| `icon_only` | Boolean | `false` | no | Hides the label, drops the chevron, and uses Button `ICON_ONLY_SIZES`. `:sm`, `:md`, and `:lg` add `fp-hit-target`. `:xs` adds `fp-hit-slop` so the painted trigger stays about 32px and the tap stays 44px. Needs `icon:` and an accessible name (`text:` or `trigger_attributes: { aria: { label: } }`). Always pass an `aria-label`. A blank name raises `ArgumentError`. Leave about 12px before the next `:xs` control or the tap areas overlap. |
| `show_chevron` | Boolean | `nil` | no | Omitted or `nil` shows the chevron on a labeled trigger and hides it when `icon_only: true`. `false` hides it. `true` with `icon_only: true` raises `ArgumentError`. |
| `chevron` | String, Symbol | `"chevron-down"` | no | Trailing icon when the chevron is shown. It sits in Button's trailing slot (a span around the svg). The default rotates when the menu opens. Another Heroicon name sits in that same slot and does not rotate. A symbol is accepted. Anything else raises `ArgumentError`. Ignored when the chevron is hidden. |
| `disabled` | Boolean | `false` | no | Disables trigger interaction and applies disabled styling. |
| `placement` | Symbol | `:bottom_right` | no | Menu placement: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`; invalid values raise `ArgumentError`. |
| `max_height` | String | `"384px"` | no | Sets `--dropdown-max-height` on the menu. The menu uses `max-height: var(--dropdown-max-height)` and scrolls when content exceeds it. |
| `trigger_attributes` | Hash | `{}` | no | HTML attributes on the trigger. Use `aria: { label: }` for an icon-only name when `text` is blank. `aria-haspopup` and `aria-expanded` stay on the button. A host `style:` string, `href`, `method`, and `target` are dropped and are not copied onto the trigger. `size`, `text`, `icon`, and the other Button option keys are dropped the same way, so they do not replace the dropdown's own options. `type` and `title` still land on the button. |
| `menu_class` | String | `nil` | no | Extra classes on the menu. Kit menu classes stay. Omit it and the menu classes stay the same. |
| `menu_attributes` | Hash | `{}` | no | Extra HTML attributes on the menu. `class` and `data-controller` merge. `aria-hidden` and the Stimulus menu target stay. A pure action list stays `role="menu"`. A menu that contains `menu_form` is `role="dialog"` instead. A host `role` is dropped. In development that drop is written to the log. A host `style:` string is joined after `--dropdown-max-height`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper. |

## Slots
Use `menu_item` and `menu_divider` as the slot builders (without a `with_` prefix).

| name | type | required | description |
|---|---|---|---|
| `trigger_label` | slot | no | A new `renders_one` slot (main had none). Replaces the visible trigger label in place (`with_trigger_label`). The trigger stays a Button. `text:` stays the accessible name when `icon_only: true`, and the collapse header. Omit the slot and the trigger shows `text:`. |
| `menu_item` | slot | no | Adds `FlatPack::Button::DropdownItem::Component` entries. |
| `menu_divider` | slot | no | Adds `FlatPack::Button::DropdownDivider::Component` separators. |
| `menu_html` | method | no | Places already-rendered HTML in the menu, in call order with `menu_item`, `menu_divider`, and `menu_form`. Button Group uses it for each overflow child's `menu_row`. A hand-written `role="menuitem"` in that HTML still runs its outer `data-action` after the menu moves to `document.body`, even without `data-flat-pack-dropdown-item`. |
| `menu_form` | slot | no | Places a form in the menu. The panel becomes `role="dialog"` (not `role="menu"`), and items are not `menuitem`. Each item has `data-flat-pack-dropdown-item`, so an outer `data-action` still runs. The form wrapper has no `menu`, `menuitem`, or `none` role. Clicks, Tab, and focus inside that wrapper do not close the menu. Escape still closes. A nested Dropdown inside the form keeps its own menu roles. A `form` in `menu_html` closes the menu unless it sets `data-flat-pack-dropdown-keep-open`. |

`menu_item` props:

| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Item label text. |
| `icon` | String/Symbol | `nil` | no | Optional leading Heroicon name. Menu items do not paint a raw `<svg` string; the trigger does, through Button. |
| `icon_position` | Symbol | `:start` | no | `:start` paints the icon before the label. `:end` renders the icon after the label and pushes it to the trailing edge with `ms-auto` (one class, so a host class on that icon wins). Unknown names raise `ArgumentError`. |
| `keep_open` | Boolean | `false` | no | `true` keeps the menu open when this item is used. The item stays `role="menuitem"`. Anything other than `true` or `false` raises `ArgumentError`. |
| `icon_variant` | Symbol, nil | `nil` | no | `:outline`, `:solid`, `:mini`, or `:micro` on that icon. Omit to use `default_icon_variant`. Unknown names raise `ArgumentError`. |
| `icon_style` | Symbol, nil | `nil` | no | `nil` inherits the item text. `:primary`, `:success`, `:warning`, or `:danger` use the button icon tokens. Unknown names raise `ArgumentError`. |
| `badge` | String | `nil` | no | Optional badge content. |
| `badge_style` | Symbol | `:primary` | no | Badge style: `:default`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`, `:info`; invalid values raise `ArgumentError` when badge is present. |
| `href` | String | `nil` | no | Link destination. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Makes item non-focusable and non-interactive. |
| `destructive` | Boolean | `false` | no | Applies destructive visual treatment. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for item element. |

## Variants
- Position variants: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. The menu is `fixed` and positioned from the trigger rectangle, including a small icon-only trigger. `place` in `flat_pack/positioning.js` keeps the requested corner (`flip: false`). The gap is 8px. The viewport clamp reads `--overlay-edge-offset`, and an oversized menu sticks to that edge. Scroll and resize while open run the same placement. Disconnect removes those listeners.
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

Host menu classes and a trigger label, with no subclass:

```erb
<%= render FlatPack::Button::Dropdown::Component.new(
  text: "Lists",
  placement: :bottom_left,
  menu_class: "min-w-[18rem]",
  menu_attributes: { id: "add-to-list-menu" }
) do |dropdown| %>
  <% dropdown.with_trigger_label { "Lists · 3" } %>
  <% dropdown.menu_item(text: "Favorites", icon: "heart", icon_position: :end, href: "#") %>
  <% dropdown.menu_form do %>
    <form>
      <%= render FlatPack::TextInput::Component.new(name: "name", label: "New list") %>
      <%= render FlatPack::Button::Component.new(text: "Add", size: :sm, style: :primary, type: "submit") %>
    </form>
  <% end %>
<% end %>
```

## Collapsing button group
`menu_row` is the menu form used by [Button Group](button-group.md). `collapse: :menu` uses it in the phone menu. An overflow menu uses it when this dropdown did not stay in the row. It renders this dropdown as [Menu Collapse](menu-collapse.md): `text` and `icon` are the header, and the menu items sit underneath. The wide control stays this dropdown. A dropdown that is the group's direct child takes the segment shape on its root. The trigger copies that box. The group does not style the trigger itself.

## Accessibility
- Trigger uses `aria-haspopup="true"` and toggles `aria-expanded`.
- `icon_only: true` sets `aria-label` from `text` unless `trigger_attributes` already has one. The visible label is omitted. A blank `text` and a blank label raise `ArgumentError`.
- A pure action list uses `role="menu"`; items use `role="menuitem"`; the divider uses `role="separator"`.
- A menu that contains `menu_form` uses `role="dialog"` with `aria-modal="false"` and an accessible name from `text`. Items in that dialog are not `menuitem`. The form is not wrapped in `role="menu"`, `role="menuitem"`, or `role="none"`. The trigger uses `aria-haspopup="dialog"`.
- Keyboard behavior supports `Escape`, arrow navigation, `Home`, and `End`. `Enter` and `Space` on the trigger open the menu. The trigger's `data-action` includes `keydown.enter`, `keydown.space`, `keyup.enter`, and `keyup.space` beside `click`. A repeated key is ignored. Space keyup cancels the activation click, and a click that still arrives immediately after the key is ignored, so the menu opens once. An action menu then focuses the first item. A dialog focuses the first visible form field (a hidden input such as `authenticity_token`, and a disabled control, are skipped), or the first item when the panel has no field. `Tab` closes a `role="menu"` and returns focus to the trigger, including when the item is `keep_open`. `Tab` in a `role="dialog"` leaves the panel open while the next stop is still inside it. Tabbing past the last stop closes the dialog and returns focus to the trigger. A keep-open control, including the form wrapper, does not close on `Tab`.
- Menu origin follows placement (`top right`, `top left`, `bottom right`, or `bottom left`). Enter/exit uses `--duration-base` with `--easing-enter` / `--easing-exit` and scale-95, not scale-0. A close in flight can reverse.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--button-dropdown`.
