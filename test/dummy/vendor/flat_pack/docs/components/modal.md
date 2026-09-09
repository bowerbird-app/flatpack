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
| `body_height_mode` | Symbol | `:auto` | no | Body sizing mode: `:auto`, `:fixed`, `:min`. |
| `body_height` | String | `nil` | conditional | Required when `body_height_mode` is `:fixed` or `:min`; validated for safe CSS-length/expression characters. |
| `close_on_backdrop` | Boolean | `true` | no | Allow closing when clicking backdrop. |
| `close_on_escape` | Boolean | `true` | no | Allow closing on Escape key. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into modal root element. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `header` | method/slot | no | Provides custom header content (replaces title text area). |
| `body` | method/slot | no | Provides main scrollable dialog body content. |
| `footer` | method/slot | no | Provides footer action row content. |

## Variants
- Size variants via `size`.
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

## Overlay scroll and insets
The backdrop and `.flat-pack-modal__body` use `overscroll-behavior: contain` so a fling inside the dialog does not scroll the page underneath. Opening a modal also sets `overscroll-behavior: none` on `document.body` (same lock count as the overflow lock).

The dialog wrapper uses `.fp-overlay-pad` so padding is at least `1rem` (`1.5rem` from the `sm` breakpoint) and never less than the device safe-area insets. Hosts need `viewport-fit=cover` on the viewport meta for those insets to be non-zero. See [Installation](../installation.md).

## Accessibility
- Renders `role="dialog"`, `aria-modal="true"`, and `aria-labelledby` bound to the header id.
- Escape/backdrop close controls are configurable.
- Tab cycles inside the dialog. The trap is wired as `keydown.tab->flat-pack--modal#handleKeydown` even when Escape close is off. The dialog itself is `tabindex="-1"` so it can take focus when nothing else inside is focusable.
- Ensure trigger and focus-management behavior are implemented in the modal controller usage flow.
- Under `prefers-reduced-motion: reduce`, the dialog fades without scale. Enter uses `--duration-slow` / `--easing-enter`; exit uses `--duration-base` / `--easing-exit`. A close in flight can reverse.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--modal`.
