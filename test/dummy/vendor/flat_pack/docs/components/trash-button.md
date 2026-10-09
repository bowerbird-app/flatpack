# Trash Button

## Purpose
A two-step delete control: a default trash button that turns into Confirm plus Cancel, so a single click cannot destroy anything.

## When to use
Use this for row actions and other tight delete controls where a modal would be heavy. Use `FlatPack::Button::Component` with `style: :danger` when the action is already behind another confirm step. Opt in per call; existing Button markup is unchanged.

## Class
- Primary: `FlatPack::TrashButton::Component`
- Related classes: `FlatPack::Button::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `text` | String, nil | `nil` | no | Visible label. Omit for icon-only (accessible name defaults to the `flatpack.trash_button.trash` copy). |
| `confirm_label` | String, nil | locale `Confirm` | no | Label on the danger confirm button. |
| `url` | String, nil | `nil` | no | Form action for confirm. Relative or `http`/`https`/`mailto`/`tel` only. When set, confirm submits like `button_to` (Turbo-friendly). |
| `method` | Symbol | `:delete` | no | Form method when `url` is set. Allowed: `:delete`, `:post`, `:put`, `:patch`, `:get`. |
| `expand` | Symbol | `:right` | no | Where Cancel slides in, so the confirm button stays under the pointer. Allowed: `:right`, `:left`. Use `:left` in a right-aligned table cell. |
| `size` | Symbol | `:md` | no | Same scale as Button: `:sm`, `:md`, `:lg`. Rest, Confirm, and Cancel share that size’s icon-only height. Cancel is the square footprint. |
| `timeout` | Integer, false | `4000` | no | Milliseconds before it returns to rest. `0` or `false` disables auto-revert. |
| `armed` | Boolean | `false` | no | Start on the Confirm + Cancel step. |
| `**system_arguments` | Hash | `{}` | no | Forwarded to the outer group (`class`, `id`, `data`, `aria`). |

## Slots
None.

## Variants
- Icon-only (default) or labelled (`text:`). Both keep the same control height as Cancel.
- Expand `:right` or `:left`
- Rest, hover/focus (danger tokens), and armed (Confirm + Cancel)
- Form confirm (`url:`) or JS-only (`flat-pack:trash-button:confirm`)

## Example
```erb
<%= render FlatPack::TrashButton::Component.new(url: take_path(@take)) %>
```

Labelled, expanding left in a row:

```erb
<%= render FlatPack::TrashButton::Component.new(
  text: "Trash",
  url: take_path(@take),
  method: :delete,
  expand: :left,
  size: :sm
) %>
```

JS-only callers listen on the group:

```js
element.addEventListener("flat-pack:trash-button:confirm", (event) => {
  event.preventDefault() // skip the form submit when `url:` is set
})
```

## Accessibility
Icon-only uses an accessible name (`text:` or the locale trash copy). Hover and keyboard focus both use the theme danger button tokens. Clicking the trash control moves focus to Confirm. Cancel, Escape, or a click outside returns focus to the trash control. A polite live region announces the armed and restored states. Confirm ignores clicks for 300ms after it appears so a double-click cannot submit. `prefers-reduced-motion` makes the swap instant (`--duration-*` collapses to `0ms`).

## Dependencies
- FlatPack Button (`style: :default` at rest, `style: :danger` on confirm). Hover/focus danger colour is scoped to `.fp-trash-button__arm` and does not change other buttons.
- Stimulus controller `flat-pack--trash-button` (`app/javascript/flat_pack/controllers/trash_button_controller.js`).
- Locale keys under `flatpack.trash_button.*` and `flatpack.common.cancel`.
- Rebuild host Tailwind so `sr-only` and `contents` generate. Reload kit CSS and JavaScript.
