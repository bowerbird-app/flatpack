# Copy Button

## Purpose
Copies a string, or the value of another element, with a short Copied state and a visible error when the write fails.

## When to use
Use this when the thing to copy is a button, not a field. For a readonly field with a trailing icon, keep `quick_copy: true` on Text Input or Text Area. For a heading permalink, keep Section Title `anchor_link: true`. Those both use the same clipboard controller.

## Class
- Primary: `FlatPack::CopyButton::Component`
- Related classes: `FlatPack::Button::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `text` | String, nil | `nil` | one of `text` or `target` | The string written to the clipboard. This is not the visible label. When both `text` and `target` are set, `text` wins. An empty string is a real source and shows the empty-copy error. |
| `target` | String, nil | `nil` | one of `text` or `target` | Element id, or a CSS selector (`#`, `.`, `[`, or a combinator). Form controls copy `.value`. Other elements copy `textContent`. |
| `label` | String | locale `Copy` | no | Visible label and accessible name. Omit it to use `flatpack.clipboard.copy`. |
| `icon` | String | `clipboard-document` | no | Idle Heroicon name. Copied swaps to `check`. Error swaps to `exclamation-circle`. |
| `icon_only` | Boolean | `false` | no | Hides the visible label. The accessible name stays `label` or the locale copy. |
| `style` | Symbol | `:default` | no | Same names as Button: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:danger`, plus any style registered with `FlatPack::Button::StyleRegistry`. |
| `size` | Symbol | `:md` | no | `:sm`, `:md`, `:lg`. Same padding scale as Button. |
| `timeout` | Integer | `2000` | no | Milliseconds before the button returns to idle. `0` holds the Copied or error state. |
| `type` | String | `"button"` | no | Native button type. |
| `**system_arguments` | Hash | `{}` | no | Forwarded to the outer span (`class`, `id`, `data`, `aria`). `disabled: true` is placed on the inner button. |

## Slots
None.

## Variants
- Labelled or icon-only
- Sizes `:sm`, `:md`, `:lg`
- Button styles
- Idle, Copied (success tokens and a check), and error (danger tokens). An empty source uses the same error chrome with the “Nothing to copy” label.

## Example
```erb
<%= render FlatPack::CopyButton::Component.new(text: "sk_live_1234567890") %>
```

Icon-only, copying another element:

```erb
<p id="invite-code">Harbour-42</p>
<%= render FlatPack::CopyButton::Component.new(target: "invite-code", icon_only: true) %>
```

Listen for the result:

```js
element.addEventListener("flat-pack:clipboard:copied", (event) => {
  event.detail.text
})

element.addEventListener("flat-pack:clipboard:error", (event) => {
  event.detail.reason // "empty", "missing", or "failed"
})
```

## Accessibility
The visible label is `aria-hidden`. The button’s accessible name stays the idle label, so a screen reader hears the live region once instead of a renamed button plus the region. The polite live region announces “Copied to clipboard”, “Nothing to copy”, or “Unable to copy”. `prefers-reduced-motion` keeps the state for at most 600ms, and `--duration-*` collapses to `0ms`, so the icon swap does not fade. A disabled button does nothing.

## Dependencies
- Button class strings and `FlatPack::Button::StyleRegistry`. Copied and error fills override `[data-fp-style]` on `.fp-copy-button` with `--button-success-*` and `--button-danger-*`.
- Stimulus controller `flat-pack--clipboard` (`app/javascript/flat_pack/controllers/clipboard_controller.js`).
- `flat_pack/clipboard.js` writes with `navigator.clipboard.writeText`, then a hidden textarea and `document.execCommand("copy")` when the async API is missing, the page is insecure, or `writeText` rejects.
- Locale keys under `flatpack.clipboard.*`.
- Reload kit CSS and JavaScript. Pin `flat_pack/clipboard` (the install generator backfills it).

A later share button can import `writeClipboardText` and `readClipboardSource` from `flat_pack/clipboard` and reuse `data-fp-clipboard-state`. This component does not call the Web Share API.
