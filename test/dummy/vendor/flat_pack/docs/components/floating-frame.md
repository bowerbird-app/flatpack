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
| `padding` | Symbol | `:md` | no | Padding around the framed page. Same sizes as Card: `:none`, `:sm`, `:md`, `:lg`. `:md` uses `--card-padding-md`. `:none` puts the iframe edge to edge under the title bar. Anything else raises `ArgumentError`. |
| `background` | String | `nil` | no | Sets `--floating-frame-background` on the root. A CSS color: hex, `rgb()` / `hsl()` / `oklch()`, `var(--token)`, `transparent`, `currentcolor`, or a CSS-wide keyword (`inherit`, `initial`, `unset`, `revert`, `revert-layer`). Other color names are rejected. Omit it and the padded page uses `--surface-background-color`, which is `#fff` on the light palette. Anything else raises `ArgumentError`. A `bg-*` class in `content_class` still wins, because this only sets the variable. |
| `content_class` | String | `nil` | no | Extra classes on the padded page (`.fp-floating-frame__mount`), merged with Tailwind Merge. A `bg-*` utility replaces the white default and also replaces `background:`. `p-0` replaces the padding utility. Anything other than a String raises `ArgumentError`. |
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
  position: :bottom_left,
  padding: :md
) %>
```

An edge-to-edge page:

```erb
<%= render FlatPack::FloatingFrame::Component.new(
  src: "/map",
  title: "Map",
  label: "Open map",
  padding: :none
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
- Below 640px, an open panel sets `aria-modal="true"` and Tab stays inside it, including focus inside a same-origin iframe. A cross-origin frame, or a sandbox without `allow-same-origin`, does not let the parent see Tab inside the page. Focus sentinels at both ends of the panel catch that Tab and return it to the panel, and a `focusin` listener does the same if focus reaches the rest of the page. A pointer click does not. From 640px up the panel is not modal, and Tab can leave it. Resizing across that line updates `aria-modal` while the panel is open.
- The close control is a ghost icon Button with an accessible name.
- Opening moves focus to the close control. Escape, the close control, the launcher, or a click outside closes the panel. Focus returns to the launcher after Escape or the close control. A click outside does not move focus.
- Escape also closes when focus is inside a same-origin iframe. The controller listens on that frame's `contentWindow`. A cross-origin frame, or a sandbox without `allow-same-origin`, does not expose its window, so Escape inside that page does not close the panel. Use the close control, or press Escape after focus is back in the parent page.
- The iframe is not in the document until the first open. After that it stays mounted, including while the panel is closed, so the framed page keeps its state.
- Popover runs the open and close motion: opacity and a short offset on `--duration-base`, with `--easing-enter` and `--easing-exit`. Reduced motion drops the offset.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--popover` (position, Escape while focus is in the parent page, outside click, `aria-expanded`) and `flat-pack--floating-frame` (lazy iframe, focus, narrow-screen Tab trap, Escape inside a same-origin iframe).
- Fab pins the launcher. Popover anchors the panel. Embed renders the iframe. Button renders the close control.
- Below `640px` the open panel is near the full viewport (`100vw` / `100dvh` minus `--overlay-edge-offset`). From `640px` up it is `min(24rem, …)` by `min(32rem, …)`, anchored to the launcher.
- On connect, the root moves to `document.body` and stays there. Stimulus reconnects after the move and does not put the frame back. That keeps the fixed launcher outside a shell that uses `overflow` to clip, so a bottom-left button is not stuck under a sidebar.
- The title bar keeps its own padding and the popover surface. `padding:` insets the framed page under that bar. The open panel itself has no padding, so `:none` meets the panel edges. The padded page uses `--floating-frame-background`, which defaults to `--surface-background-color` (`#fff` on the light palette). That fill is painted in `@layer components` under `:where()`, so a single `bg-*` utility beats it. `background:` sets the variable on the root and changes the fill when no background utility is present. `content_class` is merged onto the mount with Tailwind Merge, so `p-0` replaces the padding utility and a `bg-*` class wins over both the default and `background:`. The embed frame is transparent. The framed page paints its own background, and the mount fill shows through when that page does not. The title bar does not use the fill.
- The root stacking level is `--fab-z-index` plus 1. The open panel uses the same level inside that context, above the launcher and Bottom Nav.
