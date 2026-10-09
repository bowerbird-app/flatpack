# Modal

## Purpose
Display layered dialog content with managed focus/keyboard/backdrop behavior.

## When to use
Use Modal for confirmation flows, forms, and detailed contextual content that should temporarily block page interaction. Use [Drawer](drawer.md) when the extra content should slide in from an edge instead of centering.

## Class
- Primary: `FlatPack::Modal::Component`

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
- Under `prefers-reduced-motion: reduce`, the dialog fades without scale. Enter uses `--duration-slow` / `--easing-enter`; exit uses `--duration-base` / `--easing-exit`. A close in flight can reverse. Motion writes the Tailwind v4 `scale` property (not `transform`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--modal`.
