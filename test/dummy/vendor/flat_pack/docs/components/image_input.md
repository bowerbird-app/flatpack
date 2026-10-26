# Image Input

## Purpose
It picks one image for a profile photo, avatar, logo, or cover, with a preview and a remove control.

## When to use
Use Image Input when the field stores one picture and the person should see that picture before submit. Use `FlatPack::FileInput::Component` for a general file dropzone.

## Class
- Primary: `FlatPack::ImageInput::Component`
- Related classes: `FlatPack::FormField::Component` (label, help text, error, and the outer wrapper), `FlatPack::Avatar::Component` (the same radius tokens), `FlatPack::FileInput::Component`
- Related Stimulus controller: `flat-pack--image-input`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `name` | String |  | yes | File input name. Blank raises `ArgumentError`. |
| `src` | String | `nil` | no | Current picture URL. Blank stays empty. `javascript:` and `data:` raise `ArgumentError`. `http`, `https`, and relative URLs stay. |
| `alt` | String | `nil` | no | Preview alt text. When `label` is omitted, the file input uses `alt` or "Choose an image". |
| `shape` | Symbol | `:circle` | no | `:circle`, `:rounded`, `:square`. Uses `--avatar-radius-circle`, `--avatar-radius-rounded`, and `--avatar-radius-square`. Unknown values raise `ArgumentError`. |
| `size` | Symbol, String | `:xl` | no | `:md` (`h-12 w-12`), `:lg` (`h-16 w-16`), `:xl` (`h-20 w-20`), `:"2xl"` (`h-24 w-24`), `:wide` (`h-20 w-36`). Unknown values raise `ArgumentError`. This map is not Avatar's map. |
| `icon` | String | `"camera"` | no | Heroicon shown when there is no picture. |
| `edit_icon` | String | `"pencil"` | no | Heroicon shown over a picture. |
| `accept` | String | `"image/*"` | no | File input `accept`. `nil` omits the attribute. Dangerous extensions such as `.exe` raise `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Disables the file input and the clear button. The picture still shows. |
| `required` | Boolean | `false` | no | Sets `required` on the file input. |
| `label` | String | `nil` | no | Visible label. `for` matches the file input id. |
| `help_text` | String | `nil` | no | Help text under the control. There is no `hint` alias. |
| `error` | String | `nil` | no | Error text. Sets `aria-invalid`, an error border on the empty layer, and a ring on the surface. |
| `clearable` | Boolean | `true` | no | Renders the remove button. `false` omits it. |
| `remove_name` | String | `nil` | no | Hidden input name. Value starts at `"0"`. Must be a non-blank string and must not equal `name`. |
| `input_attributes` | Hash | `{}` | no | Extra attributes on the file input. `data-controller` and `data-action` merge with a space. `type` and `name` stay on the component. |
| `clear_attributes` | Hash | `{}` | no | Extra attributes on the clear button. Merged the same way. `type` stays `button`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the `FlatPack::FormField::Component` wrapper (`.flat-pack-input-wrapper`), including `class`, `data`, and `aria`. `id` sets the file input id. |

## Slots
The component block renders inside the stage, after the file input, preview, and clear button, for extra hidden inputs.

## Variants
- Shapes: `:circle`, `:rounded`, `:square`.
- Sizes: `:md`, `:lg`, `:xl`, `:"2xl"`, `:wide`.

## Example
```erb
<%= render FlatPack::ImageInput::Component.new(
  name: "avatar",
  src: "https://i.pravatar.cc/150?img=5",
  alt: "A person",
  label: "Avatar",
  remove_name: "remove_avatar"
) %>
```

Clear is a two-step state machine.

- `empty` has no picture. The hidden remove input is `"1"` only after a persisted picture was cleared. Otherwise it is `"0"`.
- `persisted` shows `src`. The file input is empty. Remove is `"0"`.
- `selected` shows an object URL of the chosen file. Remove is `"0"`.

Choosing or dropping one matching file moves to `selected`, revokes the previous object URL, and sets remove to `"0"`. A non-matching drop leaves the input and the state alone. A non-matching file from the dialog is cleared off the file input so it is not submitted.

Clear while `selected`, when an initial `src` still exists, returns to `persisted`. Remove stays `"0"`. The stage dispatches `flat-pack:image-input:clear` with `{ removed: false, reverted: true }`.

Clear while `selected` with no initial `src`, or clear while `persisted`, moves to `empty` and sets remove to `"1"`. The detail is `{ removed: true, reverted: false }`. Clearing a persisted picture forgets that URL, so a later file does not restore it.

A second clear after a revert removes the persisted picture. Cancelling a replacement does not mark the saved image for deletion.

`input_attributes` merge onto the file input. `clear_attributes` merge onto the clear button. `system_arguments` land on the FormField wrapper.

## Accessibility
- With a `label`, the label's `for` is the file input id.
- Without a `label`, the file input has `aria-label` from `alt` or "Choose an image".
- Help text and error ids are in `aria-describedby`. An error sets `aria-invalid="true"` on the file input.
- The file input is `sr-only` and stays focusable. Focus draws `outline-primary` on the surface.
- The clear button is named "Remove image". The overlay icon does not take the click.
- A disabled stage sets `aria-disabled="true"`.

## Dependencies
- Stimulus controller `flat-pack--image-input` (`app/javascript/flat_pack/controllers/image_input_controller.js`), lazy-loaded by the existing controllers pin.
- `FlatPack::FormField::Component` for the wrapper.
- `FlatPack::Shared::IconComponent` for the empty, edit, and clear icons.
- Avatar radius tokens for the shape.
