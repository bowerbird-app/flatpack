# FAB

## Purpose
Pin a primary action to a corner. Alone it is a round button or link. With actions it opens a stacked speed-dial. Pass `contained: true` to pin it inside a section instead of the viewport.

## When to use
Use a FAB for the one action people reach for on a screen: compose, add, capture. Use `contained: true` when each section of a page has its own plus, such as an editor. Use a Button in the page flow when the action is not constant. Do not use a FAB for navigation; that is Bottom Nav or Sidebar.

## Class
- Primary: `FlatPack::Fab::Component`
- Related classes: `FlatPack::Fab::Action`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `icon` | Symbol/String | `:plus` | No | Icon for the main control. `FlatPack::Shared::IconComponent` name. |
| `label` | String | `nil` | No | Accessible name. On a single-action FAB it also shows as an extended pill from the `md` breakpoint up. |
| `href` | String | `nil` | No | Single-action destination. Sanitized (`http`, `https`, `mailto`, `tel`, or relative). Ignored when actions are present. |
| `position` | Symbol | `:bottom_right` | No | Viewport corner. Allowed: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. |
| `size` | Symbol | `:md` | No | Main control size. Allowed: `:sm` (40px), `:md` (56px), `:lg` (64px). |
| `layout` | Symbol | `:stack` | No | Speed-dial arrangement. Allowed: `:stack`. `:arc` is reserved and rejected until a later release. |
| `backdrop` | Boolean | `true` | No | Dim the page while the speed-dial is open. |
| `hide_on_scroll` | Boolean | `false` | No | Hide on scroll down, show on scroll up. Stays visible while open. |
| `contained` | Boolean | `false` | No | Pin to the nearest positioned ancestor instead of the viewport. |
| `offset` | String | `nil` | No | Extra gap from the corner, a CSS length such as `"1rem"` or `"16px"`. |
| `**system_arguments` | Hash | `{}` | No | On a speed-dial, merged onto the root. On a single-action FAB, merged onto the button or link so `data:` can drive Turbo or Stimulus. |

## Slots
- `with_action(icon:, label:, href: nil, style: :default, **attrs)` — one speed-dial item. `label` is required. `style: :danger` paints the round glyph with the theme danger button tokens (same as TrashButton). Omit `style:` for today’s surface glyph. Pass `data:` so an action can open a Modal (`data-modal-id`), Turbo, or a host controller. Default block content is not used.

## Variants
None. `layout: :stack` is the speed-dial arrangement in this release.

## Example

Single action:

```erb
<%= render FlatPack::Fab::Component.new(href: "/notes/new", label: "New note", icon: :pencil) %>
```

Speed-dial:

```erb
<%= render FlatPack::Fab::Component.new(position: :bottom_right) do |fab| %>
  <% fab.with_action(icon: :pencil, label: "Note", href: "/notes/new") %>
  <% fab.with_action(icon: :camera, label: "Photo", href: "/photos/new") %>
  <% fab.with_action(
    icon: :user_plus,
    label: "Invite",
    data: { modal_id: "invite" }
  ) %>
<% end %>
```

Contained small FAB in a section (actions open downward from a top corner):

```erb
<div class="relative">
  <%= render FlatPack::Fab::Component.new(
    contained: true,
    position: :top_right,
    size: :sm,
    backdrop: false
  ) do |fab| %>
    <% fab.with_action(icon: :pencil, label: "Edit title") %>
    <% fab.with_action(icon: :document_text, label: "Edit content") %>
    <% fab.with_action(icon: :arrows_up_down, label: "Reorder") %>
    <% fab.with_action(icon: :trash, label: "Trash", style: :danger) %>
    <% fab.with_action(icon: :plus, label: "Add section") %>
  <% end %>
</div>
```

## Accessibility
- The main control always has `aria-label` (`label:`, or “Add” / “Open actions”).
- Speed-dial sets `aria-expanded`, `aria-controls`, and `aria-haspopup="menu"` on the main button. The action list is `role="menu"` with `role="menuitem"` items.
- Opening moves focus to the first action. Arrow keys move between actions. Shift+Tab from the first action returns to the main button. Tab from the last action closes. Escape, the main button, the backdrop, a click outside, or choosing an action all close. Focus returns to the main button except after choosing an action.
- `prefers-reduced-motion: reduce` drops stagger and travel. Colour, opacity, and the 45° icon turn still update.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Speed-dial and `hide_on_scroll:` use Stimulus controller `flat-pack--fab` (`app/javascript/flat_pack/controllers/fab_controller.js`). A single-action FAB with no scroll hiding needs no JavaScript.
- Bottom Nav: when `position` is a bottom corner, the controller sets `--fp-fab-nav-offset` to the height of `.fp-bottom-nav` in the same container (or the document). `contained: true` only looks inside the nearest positioned ancestor, so a page tab bar does not lift a section FAB. Hosts can also set `--fp-fab-nav-offset` or pass `offset:`.
- `contained: true` is `position: absolute; inset: 0` on the nearest positioned ancestor. Give that ancestor `relative`. Top corners stack actions downward; bottom corners stack upward.
- z-index is `--fab-z-index` (45): above Bottom Nav (40), below Modal/Drawer (50) and Toasts (60).
- Corner insets use `env(safe-area-inset-*)`. Hosts need `viewport-fit=cover`. See [Installation](../installation.md).
- `--fp-fab-offset` and `--fp-fab-nav-offset` are runtime layout properties. They are not theme tokens.
