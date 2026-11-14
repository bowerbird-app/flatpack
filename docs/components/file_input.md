# File Input

## Purpose
It lets a person pick one or more files. The host uploads them. Flatpack does not.

## When to use
Use the dropzone when the person should drag files onto the page. Use the button when a single control should open the file dialog. Use [Image Input](image_input.md) when the field stores one picture and the person should see that picture before submit.

## Class
- Primary: `FlatPack::FileInput::Component`
- Related classes: `FlatPack::Button::Component` (the button variant)
- Related Stimulus controller: `flat-pack--file-input`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `name` | String |  | yes | File input name. Blank raises `ArgumentError`. |
| `variant` | Symbol | `:dropzone` | no | `:dropzone` or `:button`. Any other value, including `nil`, raises `ArgumentError`. |
| `text` | String | `nil` | no | Button label. Blank uses "Choose a file". Raises on `:dropzone`. |
| `style` | Symbol | `:primary` | no | Button scheme: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:danger`, or a registered button style. Raises on `:dropzone`. This is not a CSS `style` attribute. |
| `size` | Symbol | `:md` | no | Button size: `:sm`, `:md`, `:lg`. Raises on `:dropzone`. |
| `round` | Boolean | `nil` | no | Passes `round:` to the button. `nil` omits it. Raises on `:dropzone`. |
| `icon` | String | `nil` | no | Heroicon name on the button. Raises on `:dropzone`. |
| `icon_variant` | Symbol | `nil` | no | Passes through to the button. Raises on `:dropzone`. |
| `icon_style` | Symbol | `nil` | no | Passes through to the button. Raises on `:dropzone`. |
| `label` | String | `nil` | no | Visible field label. `for` matches the file input id. |
| `help_text` | String | `nil` | no | Plain text under the control. HTML-like content is escaped. |
| `error` | String | `nil` | no | Error text. Sets `aria-invalid` on the file input. The dropzone border uses the error color. |
| `accept` | String | `nil` | no | `accept` on the file input. Dangerous extensions such as `.exe` raise `ArgumentError`. |
| `multiple` | Boolean | `false` | no | Sets `multiple` on the file input. |
| `max_size` | Integer | `nil` | no | Client-side size cap in bytes. Must be a positive number. Oversized files are left out of the event and the dropzone list. |
| `max_files` | Integer | `nil` | no | Keeps the first N files in the event and the dropzone list. Must be a positive integer. Extra files are ignored. `input.files` is not rewritten. |
| `preview` | Boolean | `true` | no | Dropzone image previews. The button variant never shows a preview or a file list. |
| `disabled` | Boolean | `false` | no | Disables the file input and the button. |
| `required` | Boolean | `false` | no | Sets `required` on the file input. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes. `id` sets the file input id. `data` and `aria` land on the file input. `class` lands on the dropzone, or on the button when `variant: :button`. |

## Slots
`actions` renders host controls beside the dropzone or the button. The slot is outside the Stimulus controller. The button variant does not render a built-in file list, so the slot is where a host shows its own progress.

```erb
<%= render FlatPack::FileInput::Component.new(name: "documents", multiple: true) do |input| %>
  <% input.actions do %>
    <%= render FlatPack::Progress::Component.new(value: 0, label: "Host progress", show_label: true) %>
  <% end %>
<% end %>
```

## Variants
- `:dropzone` is the dashed zone, the "Upload a file" control, the drag hint, the built-in list, and optional image previews.
- `:button` is one `FlatPack::Button` plus a visually hidden file input. The button is the only tab stop. There is no built-in list and no preview.

## Example
```erb
<%= render FlatPack::FileInput::Component.new(
  name: "profile[avatar]",
  label: "Profile image",
  accept: "image/png,image/jpeg",
  max_size: 2_097_152,
  preview: true
) %>
```

```erb
<%= render FlatPack::FileInput::Component.new(
  name: "attachments[]",
  variant: :button,
  text: "Add files",
  style: :secondary,
  icon: "arrow-up-tray",
  multiple: true,
  max_files: 2
) %>
```

Choosing files or dropping them dispatches `flat-pack:file-input:change` on the controller element. It bubbles. `detail.files` is an array of `File`. The same event fires for both variants, including an empty selection and a remove from the dropzone list.

`max_files` keeps the first N of the raw selection, then the size check runs. The kept files are what the event and the dropzone list use. A status message says only the first file, or the first N files, were kept. The message clears when a later selection is within the cap, and when a file is removed from the list.

The component never assigns `input.files`. A dialog selection still fills that list, because the browser does. A drop does not. Removing a row from the dropzone list does not. A host that needs the capped set uses `event.detail.files`. Enforce `max_files` and `max_size` on the server. The component does not upload and does not know about storage.

## Accessibility
- With a `label`, the label's `for` is the file input id.
- Without a `label`, the button variant sets `aria-label` on the file input from the button text.
- Help text and error ids are in `aria-describedby` on the file input and, for the button variant, on the button.
- When `max_files` is set, that list also includes the limit message id. The message is `role="status"` and `aria-live="polite"`.
- The dropzone file input is `hidden`. The visible "Upload a file" button is the tab stop.
- The button variant file input is `sr-only` with `tabindex="-1"`. The `FlatPack::Button` is the only tab stop. After the dialog, focus returns to that button.
- An error sets `aria-invalid="true"` on the file input.

## Dependencies
- Stimulus controller `flat-pack--file-input` (`app/javascript/flat_pack/controllers/file_input_controller.js`), lazy-loaded by the existing controllers pin.
- `FlatPack::Button::Component` for `variant: :button`.
