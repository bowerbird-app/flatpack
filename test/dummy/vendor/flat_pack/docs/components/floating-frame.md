# Floating frame

## Purpose
Pin a launcher to a corner and open a same-origin page in a panel next to it.

## When to use
Use a floating frame when a page should stay available without leaving the screen: notes, help, a map, a short tool. Pass any same-origin URL. The component does not know about a product.

Use a link or a Button when the page should take over the screen. Use a Modal for a short decision. Use Embed alone when the frame is part of the page, not a launcher.

## Class
- Primary: `FlatPack::FloatingFrame::Component`
- Related classes: `FlatPack::Fab::Component`, `FlatPack::Popover::Component`, `FlatPack::Embed::Component`, `FlatPack::Button::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `src` | String |  | yes | Iframe URL. `http(s)` or a relative URL. Anything else raises `ArgumentError`. Same rules as Embed. |
| `title` | String |  | yes | Accessible name of the iframe, and the visible panel heading. Blank values raise `ArgumentError`. |
| `label` | String |  | yes | Accessible name of the launcher. On `md` and up, Fab also shows it on the button. Blank values raise `ArgumentError`. |
| `icon` | Symbol/String | `:arrow_top_right_on_square` | no | Launcher icon. `FlatPack::Shared::IconComponent` name. |
| `position` | Symbol | `:bottom_right` | no | Viewport corner, passed to Fab. Allowed: `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. |
| `size` | Symbol | `:md` | no | Launcher size, passed to Fab. Allowed: `:sm`, `:md`, `:lg`. |
| `sandbox` | String | `"allow-scripts allow-same-origin allow-forms allow-popups"` | no | Iframe sandbox tokens. Replaces the default. `""` is the strict sandbox. `nil` keeps the default. Add tokens such as `allow-top-navigation-by-user-activation` by passing the full list. |
| `allow` | String | `nil` | no | Permissions Policy string on the iframe. Omit the attribute when unset. |
| `allowfullscreen` | Boolean | `false` | no | Sets the iframe `allowfullscreen` attribute when `true`. |
| `referrerpolicy` | String | `"strict-origin-when-cross-origin"` | no | Iframe referrer policy. Same allowed values as Embed. |
| `loading` | String | `"lazy"` | no | `"lazy"` or `"eager"`. The iframe is not inserted until the first open, so this applies after that. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged onto the root. `id:` prefixes the launcher, panel, and heading ids. |

## Slots
None.

## Variants
None. `position` chooses the corner. The panel opens on the inner side of that corner (`:top` for a bottom corner, `:bottom` for a top corner) through Popover.

## Example

```erb
<%= render FlatPack::FloatingFrame::Component.new(
  src: "/notes",
  title: "Notes",
  label: "Open notes",
  position: :bottom_left
) %>
```

A frame that may navigate the top window when the person asks it to:

```erb
<%= render FlatPack::FloatingFrame::Component.new(
  src: "/notes",
  title: "Notes",
  label: "Open notes",
  sandbox: "allow-scripts allow-same-origin allow-forms allow-popups allow-top-navigation-by-user-activation"
) %>
```

## Accessibility
- The launcher is a button. It has `aria-label`, `aria-expanded`, `aria-controls`, and `aria-haspopup="dialog"`.
- The panel is `role="dialog"` and is named by the visible heading (`title:`).
- The close control is a ghost icon Button with an accessible name.
- Opening moves focus to the close control. Escape, the close control, the launcher, or a click outside closes the panel. Focus returns to the launcher.
- The iframe is not in the document until the first open. After that it stays mounted, including while the panel is closed, so the framed page keeps its state.
- Popover runs the open and close motion: opacity and a short offset on `--duration-base`, with `--easing-enter` and `--easing-exit`. Reduced motion drops the offset.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--popover` (position, Escape, outside click, `aria-expanded`) and `flat-pack--floating-frame` (lazy iframe, focus).
- Fab pins the launcher. Popover anchors the panel. Embed renders the iframe. Button renders the close control.
- Below `640px` the open panel is near the full viewport (`100vw` / `100dvh` minus `--overlay-edge-offset`). From `640px` up it is `min(24rem, …)` by `min(32rem, …)`, anchored to the launcher.
- On connect, the root moves to `document.body` and stays there. A comment marks the original place. Stimulus reconnects after the move and does not put the frame back, which would loop. That keeps the fixed launcher outside a shell that uses `overflow` to clip, so a bottom-left button is not stuck under a sidebar.
- The root stacking level is `--fab-z-index` plus 1. The open panel uses the same level inside that context, above the launcher and Bottom Nav.
