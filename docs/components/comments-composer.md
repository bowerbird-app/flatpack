# Comments Composer

## Purpose
Render a comment entry surface with plain-text or rich-text input, optional custom toolbar/attachments slots, and submit actions.

## When to use
Use Comments Composer where users create or edit comments with optional custom actions.

The default composer uses a rounded-xl textarea shell and a floating send control.
Enable `rich_text: true` when the comment flow needs TipTap formatting controls such as the standard toolbar or selection bubble menu.

## Class
- Primary: `FlatPack::Comments::Composer::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `placeholder` | String | `"Write a comment..."` | no | Textarea placeholder text. |
| `submit_label` | String | `"Comment"` | no | Default submit button label when custom `actions` slot is not provided. |
| `cancel_label` | String | `"Cancel"` | no | Default cancel button label when `show_cancel` is true. |
| `show_cancel` | Boolean | `false` | no | Shows cancel button in default actions row. |
| `disabled` | Boolean | `false` | no | Disables textarea and default actions and applies muted state. |
| `compact` | Boolean | `false` | no | Reduces composer padding. |
| `form` | String | `nil` | no | Optional external form id applied to textarea. |
| `name` | String | `"comment"` | no | Textarea name attribute. |
| `value` | String | `nil` | no | Initial textarea content. |
| `rows` | Integer | `3` | no | Initial textarea row count. |
| `rich_text` | Boolean | `false` | no | Opts the composer into the TipTap-backed `TextArea` rich text mode. |
| `rich_text_options` | Hash | `{}` | no | Pass-through options for `FlatPack::TextArea::Component` rich text configuration, including toolbar presets, bubble menu, output format, preset selection, and host-registered TipTap addons. |
| `avatar` | Hash | `nil` | no | Optional avatar overrides (`src`, `alt`, `name`, `initials`) for the non-compact composer. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for composer wrapper. |

## Slots
- `toolbar`: optional custom slot rendered below the input shell and above attachments/actions. This is separate from the TipTap rich-text toolbar controlled by `rich_text_options[:toolbar]`.
- `attachments`: optional region for file chips/previews.
- `actions`: custom actions row; overrides default cancel/submit controls.

## Variants
- Density variant via `compact: true/false`.
- Action mode via default actions or custom `actions` slot.
- Input mode via plain textarea (`rich_text: false`) or TipTap-backed rich text (`rich_text: true`).

## Example
```erb
<%= render FlatPack::Comments::Composer::Component.new(
  name: "comment[body]",
  placeholder: "Add a comment...",
  submit_label: "Post",
  rich_text: true,
  rich_text_options: {toolbar: :full},
  show_cancel: true,
  avatar: {name: "You"}
) %>
```

### Rich text toolbar example

Use `rich_text_options[:toolbar]` to control the editor toolbar inside the composer.

If your app registers custom TipTap addons through `flat_pack/tiptap/addon_registry`, the composer can opt into them with `rich_text_options[:addons]`, and custom toolbar arrays may include those addon tool names.

```erb
<%= render FlatPack::Comments::Composer::Component.new(
  name: "comment[body]",
  placeholder: "Write a formatted comment...",
  submit_label: "Post",
  avatar: { name: "You" },
  rich_text: true,
  rich_text_options: {
    preset: :content,
    toolbar: :standard
  }
) %>
```

### Bubble menu reply example

```erb
<%= render FlatPack::Comments::Composer::Component.new(
  name: "reply[body]",
  value: "<p>Select text to reveal inline formatting.</p>",
  submit_label: "Reply",
  compact: true,
  rich_text: true,
  rich_text_options: {
    preset: :minimal,
    toolbar: :none,
    bubble_menu: true
  }
) %>
```

## Accessibility
- Defaults to native `<textarea>` and submit `<button>` controls.
- When `rich_text: true`, the composer uses the same TipTap-backed editor surface as `FlatPack::TextArea::Component`.
- The rich-text toolbar and bubble menu are populated client-side by the `flat-pack--tiptap` Stimulus controller after the server-rendered containers load.
- Provide surrounding label context (or `aria-*` attributes) in composed forms.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
