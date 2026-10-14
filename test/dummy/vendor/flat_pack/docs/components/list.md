# List

## Purpose
Render semantic ordered or unordered lists, or a key/value description list, with optional spacing, divider, selectable behavior, and drag-to-reorder support. Ordered lists show decimal markers (`1.`, `2.`, …) through a kit marker slot. Unordered lists stay unmarked. A key/value list lines icons and keys up in columns and lets values wrap.

## When to use
Use List when grouped items need consistent spacing and optional active-item selection handling. Use `layout: :key_value` when each row is a label and a value, such as a recording's details.

## Class
- Primary: `FlatPack::List::Component`
- Related classes: `FlatPack::List::Item`

## Props
`FlatPack::List::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `layout` | Symbol | `:items` | no | `:items` (default) renders `<ul>` or `<ol>`. `:key_value` renders a `<dl>`. |
| `key_width` | Symbol or String | `:fit` | no | `:key_value` only. `:fit` sizes the key column to the widest key. A CSS length such as `"10rem"` fixes the column. Values wrap in the next column. |
| `stack_below` | Symbol | `nil` | no | `:key_value` only. `:sm`, `:md`, or `:lg`. Below that breakpoint the key sits above the value. From the breakpoint up, icons, keys, and values stay in columns. |
| `ordered` | Boolean | `false` | no | Renders `<ol>` when true, otherwise `<ul>`. Ordered lists show decimal markers via a kit slot. Not supported when `layout` is `:key_value`. |
| `spacing` | Symbol | `:comfortable` | no | Vertical spacing. `:items` uses `gap-3` / `gap-1`. `:key_value` uses `gap-y-3` / `gap-y-1` so the key and value columns stay put. Rows keep no bottom margin. Skipped when `orderable` and `divider` are both on so the rule stays even. |
| `divider` | Boolean | `false` | no | Adds a straight 1px rule between rows. The rule does not follow the row's corner radius. |
| `selectable` | Boolean | `false` | no | Enables active-item behavior via `flat-pack--list-selectable`. Not supported when `layout` is `:key_value`. |
| `orderable` | Boolean | `false` | no | Enables pointer-driven reordering via `flat-pack--list-orderable`. Not supported when `layout` is `:key_value`. |
| `orderable_url` | String | `nil` | no | PATCH/PUT endpoint used to persist the new item position after drop. |
| `orderable_method` | String/Symbol | `:patch` | no | Request method sent by the orderable controller. |
| `param_uuid_name` | String | `"id"` | no | Form field name used for the dragged item UUID in orderable requests. |
| `param_target_position_name` | String | `"position"` | no | Form field name used for the destination position in orderable requests. |
| `handle_selector` | String | `nil` | no | CSS selector for the only element that can start a drag or keyboard move. Omit it to keep the whole row draggable, except links, buttons, and fields. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for list element. |

`FlatPack::List::Item`:

| name | type | default | required | description |
|---|---|---|---|---|
| `key` | String | `nil` | no | `:key_value` only, and required there. The `<dt>` text. The block is the value (`<dd>`). |
| `icon` | Symbol/String | `nil` | no | Leading icon in `.flat-pack-list-item-icon` (content colour). String values starting with `<svg` render inline SVG. Ordered lists show the decimal marker and this icon together. In `:key_value`, the icon sits inside the `<dt>` before the key and is `aria-hidden`. |
| `leading` | String | `nil` | no | Custom leading content text. Not supported when the list layout is `:key_value`. |
| `trailing` | String | `nil` | no | Trailing content, such as a copy button, at the end of the row. |
| `href` | String | `nil` | no | Optional link URL. Sanitized and validated; unsafe URLs raise `ArgumentError`. Not supported when the list layout is `:key_value`. |
| `hover` | Boolean | `false` | no | Enables hover background styling. |
| `active` | Boolean | `false` | no | Applies active item background styling. |
| `link_arguments` | Hash | `{}` | no | Extra attributes merged into internal link when `href` is present. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for `<li>`, or for the key/value row `<div>`. Default padding is `py-4 px-4`. |

## Slots
None.

## Variants
- Layout `:items` (default) or `:key_value`.
- Ordered vs unordered (`ordered: true/false`). Ordered lists number each item. Unordered lists do not.
- Spacing variants via `spacing`.
- Selectable behavior via `selectable: true`.
- Orderable behavior via `orderable: true` and `orderable_url:`.
- Key column `:fit` or a fixed CSS length, and an optional `stack_below` breakpoint.

`layout: :key_value` renders a `<dl>`. Each item renders a `<div>` that contains one `<dt>` and one `<dd>`. The list is a grid. Each row uses subgrid, so icons share a column and keys share a column no matter how long a key is. `:fit` sets that key column to `max-content` (the widest key). `key_width: "10rem"` fixes it. Values wrap in their column. `trailing:` sits in a column at the end of the row. `spacing` and `divider` still apply. The divider is the same 1px `--surface-border-color` rule, with `border-radius: 0`.

Render each item inside the list block. The item reads the layout from that render. A row built before the list cannot see `:key_value`.

`ordered: true`, `orderable: true`, and `selectable: true` raise `ArgumentError` when `layout` is `:key_value`. On an item in that layout, a missing `key:`, an `href:`, or a `leading:` also raises. `key:` outside `:key_value` raises. `key_width:` and `stack_below:` outside `:key_value` raise. `key_width` must be `:fit` or a CSS length such as `"10rem"`.

`stack_below: :md` stacks the key above the value below the `md` breakpoint. At `md` and up, the columns return. `:sm` and `:lg` work the same way at those breakpoints. Omit `stack_below` to keep columns at every width.

Tailwind must see the grid class literals in `FlatPack::List::KeyValueLayout`, including `grid-cols-subgrid` and `grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]`, plus the `sm:`, `md:`, and `lg:` forms.

Ordered markers use `--list-marker-color`, `--list-marker-min-width`, and `--list-marker-gap`. Leading icons use `--surface-content-color` via `.flat-pack-list-item-icon` so they stay visible next to the number.

`divider: true` draws `.flat-pack-list-divided` rules with `border-radius: 0`. Rows may still use `--radius-sm`. That radius must not bend the rule.

## Orderable motion
Orderable lists use pointer-driven reorder (not HTML5 drag-and-drop). Press and drag a row:

- Press scales the row to `0.98` on `--duration-fast`. Past a 4px move it lifts to `1.02` with `--shadow-lg` and follows the pointer at full opacity (no ghost fade, no drag lag).
- A landing slot, `.flat-pack-list-reorder-placeholder`, keeps the row height and fills with `--list-item-hover-background-color`. It fades in on `--duration-fast`. On a divided list the slot sits between the straight rules.
- Other rows ease their text to `--surface-muted-content-color` and spring aside with FLIP using `--easing-spring` (list/layout only).
- Release travels onto the slot with `--easing-spring-snappy`. Scale and shadow return to rest in that same motion. Drag styles clear on `transitionend`, then the order persists if `orderable_url` is set.

Under `prefers-reduced-motion: reduce`, drag still works, the slot stays visible, and the DOM order still updates. Press scale, lift scale, shadow travel, and sibling FLIP do not run. Overlay easings stay bounce-free; spring tokens are a list/layout exception.

The root adds `.flat-pack-list--orderable` when `orderable: true`.

## Example
```erb
<%= render FlatPack::List::Component.new(ordered: false, selectable: true, divider: true) do %>
  <%= render FlatPack::List::Item.new(icon: :check, href: "/tasks/1") { "First task" } %>
  <%= render FlatPack::List::Item.new(icon: :clock, href: "/tasks/2") { "Second task" } %>
<% end %>
```

```erb
<%= render FlatPack::List::Component.new(ordered: true) do %>
  <%= render FlatPack::List::Item.new(icon: :sun) { "Heat the pan" } %>
  <%= render FlatPack::List::Item.new(icon: :star) { "Crack two eggs" } %>
<% end %>
```

```erb
<%= render FlatPack::List::Component.new(layout: :key_value, key_width: "10rem", divider: true) do %>
  <%= render FlatPack::List::Item.new(key: "Room", icon: :map_pin) { "Studio B" } %>
  <%= render FlatPack::List::Item.new(key: "Guest code", icon: :key, trailing: copy_button) { "morning-b" } %>
<% end %>
```

```erb
<%= render FlatPack::List::Component.new(layout: :key_value, stack_below: :md) do %>
  <%= render FlatPack::List::Item.new(key: "Session notes", icon: :document_text) { "Bring the ribbon mic." } %>
<% end %>
```

```erb
<%= render FlatPack::List::Component.new(
  orderable: true,
  orderable_url: patch_path,
  param_uuid_name: "moving_recording_id",
  param_target_position_name: "target_position"
) do %>
  <%= render FlatPack::List::Item.new(id: "2b6f8d0d-3c1b-4ec0-9ed0-7a5d8d3b4e11") { "First task" } %>
  <%= render FlatPack::List::Item.new(id: "44d7b3a8-9a16-4f34-8c7a-9f0c8cb2f3f2") { "Second task" } %>
<% end %>
```

Persist runs only when `orderable_url` is set. Drop still reorders the list in the page if you omit the URL. A row with `data-orderable-unsaved="true"` also stays in the page and does not send the reorder request. `target_position` counts the other saved rows and leaves unsaved rows out of that number. `list:reordered` still reports the visual position. Pass `handle_selector:` when only a drag handle should start the move. Arrow Up and Arrow Down on that handle move the row. New rows added after connect are bound automatically.

The orderable controller sends a form-encoded payload shaped like:

```text
moving_recording_id=2b6f8d0d-3c1b-4ec0-9ed0-7a5d8d3b4e11&target_position=2
```

## Events
- `list:reordered` fires immediately after the DOM order changes, with `detail.id` and `detail.position` for the dragged item.
- `list:saved` fires after the backend returns `ok: true`.
- `list:error` fires when the backend rejects the update or the request fails.

## Accessibility
- `:items` renders semantic `<ul>`/`<ol>` with `role="list"`.
- `:items` items render `<li role="listitem">`.
- `:key_value` renders a `<dl>`. Each row is a `<div>` with one `<dt>` (the key) and one `<dd>` (the value). There is no `role="list"`.
- The icon in a key/value row is `aria-hidden`. The key text is the term.
- The marker slot is `aria-hidden`. Screen readers use the `<ol>` semantics.
- Selectable mode sets `aria-current="page"` on active links.
- Orderable mode expects stable item IDs so the controller can persist the dragged item's UUID and destination position.
- Orderable mode can customize the request parameter names with `param_uuid_name` and `param_target_position_name`.
- Links, buttons, and form controls inside a row do not start a reorder drag.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional selectable mode requires Stimulus controller `flat-pack--list-selectable`.
- Optional orderable mode requires Stimulus controller `flat-pack--list-orderable`.
- `:key_value` needs a Tailwind rebuild so the grid and subgrid classes in `FlatPack::List::KeyValueLayout` are generated. No new Stimulus controller.
