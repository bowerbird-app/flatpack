# Modal

## Purpose
Display layered dialog content with managed focus/keyboard/backdrop behavior.

## When to use
Use Modal for confirmation flows, forms, and detailed contextual content that should temporarily block page interaction. Use [Drawer](drawer.md) when the extra content should slide in from an edge instead of centering.

## Class
- Primary: `FlatPack::Modal::Component`

## Related classes
- `FlatPack::Modal::Screen` — turbo-frame wrapper for a navigable screen. Helper: `flat_pack_modal_screen`.

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `id` | String | `nil` | yes | DOM id for the modal root; also used to derive the title id. |
| `title` | String | `nil` | no | Header title when `header` slot is not provided. |
| `size` | Symbol | `:md` | no | Dialog width: `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`. |
| `scroll` | Symbol | `:body` | no | `:body` caps the dialog to the viewport and scrolls the body. `:page` sizes the dialog to its content and scrolls the overlay. |
| `sticky_footer` | Boolean | `false` | no | With `scroll: :page`, pin the footer to the bottom of the viewport while the overlay scrolls. Invalid with `:body`. |
| `body_height_mode` | Symbol | `:auto` | no | Body sizing mode: `:auto`, `:fixed`, `:min`. |
| `body_height` | String | `nil` | conditional | Required when `body_height_mode` is `:fixed` or `:min`; validated for safe CSS-length/expression characters. In `:page` mode these still size the body; they do not add a viewport cap. |
| `close_on_backdrop` | Boolean | `true` | no | Allow closing when clicking backdrop. |
| `close_on_escape` | Boolean | `true` | no | Allow closing on Escape. |
| `navigable` | Boolean | `false` | no | Opt-in multi-screen navigation. Off keeps today’s markup and behaviour. |
| `src` | String | `nil` | with `navigable` | Turbo Frame URL loaded lazily on open. Required when `navigable: true`. Relative, `http`, and `https` only. Not a clickable `href`. |
| `origin` | Symbol | `:center` | no | Enter/exit origin. `:center` is today’s fade and scale (markup unchanged). `:trigger` grows the panel out of the control that opened it and shrinks back on close. Not a shape morph. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into modal root element. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `header` | method/slot | no | Provides custom header content (replaces title text area). |
| `body` | method/slot | no | Provides main dialog body content. Scrolls inside the card when `scroll: :body`. |
| `footer` | method/slot | no | Provides footer action row content. |

## Variants
- Size variants via `size`.
- Scroll variants via `scroll` (`:body`, `:page`).
- Body sizing variants via `body_height_mode` (`:auto`, `:fixed`, `:min`).
- Origin variants via `origin` (`:center`, `:trigger`).

## Example
```erb
<%= render FlatPack::Modal::Component.new(id: "invite-modal", title: "Invite member", size: :lg) do |modal| %>
  <% modal.body do %>
    <p class="text-sm">Send access to a new collaborator.</p>
  <% end %>

  <% modal.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Cancel", style: :secondary) %>
    <%= render FlatPack::Button::Component.new(text: "Send invite") %>
  <% end %>
<% end %>
```

Page-scroll overlay with pinned actions:

```erb
<%= render FlatPack::Modal::Component.new(
  id: "policy-modal",
  title: "Workspace policy",
  size: :lg,
  scroll: :page,
  sticky_footer: true
) do |modal| %>
  <% modal.body do %>
    <%# Long copy. The overlay scrolls; Save stays on screen. %>
  <% end %>

  <% modal.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Cancel", style: :secondary) %>
    <%= render FlatPack::Button::Component.new(text: "Save changes") %>
  <% end %>
<% end %>
```

Navigable screens (opt-in). Default calls are unchanged. The body becomes a Turbo Frame whose id is `#{id}-screen`. Each screen is a server-rendered URL wrapped in `flat_pack_modal_screen` (or `FlatPack::Modal::Screen`). Links and forms inside use `data-fp-nav` — hosts do not write custom JavaScript.

```erb
<%= render FlatPack::Modal::Component.new(
  id: "gallery-editor",
  title: "Gallery",
  size: :lg,
  navigable: true,
  src: gallery_path
) %>
```

```erb
<%= flat_pack_modal_screen(modal_id: "gallery-editor", title: "Edit image") do |screen| %>
  <% screen.header_actions do %>
    <%# Optional controls next to the close button. %>
  <% end %>
  <% screen.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Save", data: {fp_nav: "back"}) %>
  <% end %>

  <%= render FlatPack::Button::Component.new(
    text: "Edit photographer",
    href: photographer_path,
    data: {fp_nav: "push"}
  ) %>
<% end %>
```

Grow from the control that opened it. Default calls stay on `:center`. Logic lives in `trigger_origin.js` so Drawer can reuse it later. Picker, Modal Filter, and other Modal hosts stay on `:center` unless they pass `origin:`.

```erb
<%= render FlatPack::Modal::Component.new(id: "invite-modal", title: "Invite member", origin: :trigger) do |modal| %>
  <% modal.body do %>
    <p class="text-sm">Send access to a new collaborator.</p>
  <% end %>
<% end %>
```

`origin: :trigger` measures the opening control (the click target or its closest `[data-modal-id]`, or `document.activeElement` for a keyboard open). The panel starts translated and scaled over that rect, then eases to identity on `--duration-slow` / `--easing-enter`. Close remeasures the control and reverses on `--duration-base` / `--easing-exit`. Only `transform` and `opacity` animate. Backdrop fade is unchanged.

It falls back to the `:center` fade and scale when:

- No trigger is known (programmatic open, Turbo Stream, or open on page load)
- The trigger was removed or is fully off-screen
- `prefers-reduced-motion: reduce` (fade only, same as today)
- The viewport is narrower than `640px` (`sm`). Near-full-width cards growing from a corner look wrong on a phone.

Works with every `size`, `scroll: :body`, and `scroll: :page` (including `sticky_footer: true`). Focus still moves into the dialog and back to the trigger.

With `navigable: true`, only the first open and the final close use the trigger motion. Screen-to-screen navigation is unchanged.

`data-fp-nav` values: `push` (load into the frame and stack the URL), `back` (re-fetch the previous URL; DOM is not cached), `close` (clear history and close), `replace` (update the current URL without growing the stack), `reset` (clear the stack and make this URL the root). Closing the dialog clears history. Reopening starts at `src`. Browser history is not used (`pushState` is not called).

The header is managed: title comes from the current screen, a back arrow appears only when the stack has a previous URL, and close stays. Title changes are announced (`aria-live`). Focus moves to the heading (or the remembered control on back). One dialog and one focus trap for the whole flow. Escape still closes.

While a screen loads, the kit spinner and skeleton sit over the body. If the frame request fails (missing frame, network, or non-2xx), an error state with **Try again** is shown.

Navigation lives in `flat-pack--navigable`, attached next to `flat-pack--modal` only when `navigable: true`. Drawer can reuse that controller later. `header` and `body` slots are invalid with `navigable: true`; screens supply title, body, and actions.

## Overlay scroll and insets
Opening a modal locks `document.body` (`overflow: hidden` and `overscroll-behavior: none`, same lock count as Drawer and Command palette). The overlay itself is `overflow-y-auto` and uses `overscroll-behavior: contain`, so a fling does not scroll the page underneath.

`scroll: :body` (default) keeps today’s card: the dialog is capped with `.fp-modal-dialog-cap` (`100dvh` minus padding, `100vh` fallback) and `.flat-pack-modal__body` scrolls inside.

`scroll: :page` drops that cap, `overflow-hidden`, and the body’s internal scroller. The dialog grows with its content. The overlay is the scroller. Opening resets `scrollTop` to `0`. Short dialogs still sit like today (top-aligned on small screens, vertically centred from `sm` via `sm:my-auto`). Tall dialogs start at the top. `sticky_footer: true` pins the action row to the bottom of the viewport and the header to the top.

The clickable dim sits inside the wrapper so a click on the margin still closes after the overlay has scrolled. Clicks inside the dialog do not.

The dialog wrapper uses `.fp-overlay-pad` so padding is at least `1rem` (`1.5rem` from the `sm` breakpoint) and never less than the device safe-area insets. That rule is unlayered, the same as `.fp-top-nav`, so host Tailwind preflight (`* { padding: 0 }` in `@layer base`) cannot zero it when Flatpack CSS is linked first. The wrapper ignores pointer events, and the dialog accepts them, so a click on the dimmed area reaches the backdrop. Hosts need `viewport-fit=cover` on the viewport meta for those insets to be non-zero. See [Installation](../installation.md).

## Accessibility
- Renders `role="dialog"`, `aria-modal="true"`, and `aria-labelledby` bound to the header id.
- Escape/backdrop close controls are configurable.
- Tab cycles inside the dialog. The trap is wired as `keydown.tab->flat-pack--modal#handleKeydown` even when Escape close is off. The dialog itself is `tabindex="-1"` so it can take focus when nothing else inside is focusable.
- Ensure trigger and focus-management behavior are implemented in the modal controller usage flow.
- Under `prefers-reduced-motion: reduce`, the dialog fades without scale. Enter uses `--duration-slow` / `--easing-enter`; exit uses `--duration-base` / `--easing-exit`. A close in flight can reverse. `:center` writes the Tailwind v4 `scale` property (not `transform`). `:trigger` writes `transform` and `opacity` from `trigger_origin.js` and falls back to that fade when the trigger cannot be used.
- Navigable modals keep one `role="dialog"` and update `aria-labelledby` through the stable title id. A polite live region announces the new title. The back button is omitted from the tab order until there is a previous screen.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--modal`.
- Navigable only: Stimulus controller `flat-pack--navigable`, Turbo Frames, and `src` responses that include a matching `<turbo-frame id="{modal_id}-screen">`.
