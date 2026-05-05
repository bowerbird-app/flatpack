# Comments Composer

## Purpose
Render a comment entry surface with textarea, optional toolbar/attachments, and submit actions.

## When to use
Use Comments Composer where users create or edit comments with optional custom actions.

The default composer uses a rounded-xl textarea shell and a floating send control.

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
| `rich_text_options` | Hash | `{}` | no | Pass-through options for `FlatPack::TextArea::Component` rich text configuration. |
| `avatar` | Hash | `nil` | no | Optional avatar overrides (`src`, `alt`, `name`, `initials`) for the non-compact composer. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for composer wrapper. |

## Slots
- `toolbar`: optional region above actions for formatting/tools.
- `attachments`: optional region for file chips/previews.
- `actions`: custom actions row; overrides default cancel/submit controls.

## Variants
- Density variant via `compact: true/false`.
- Action mode via default actions or custom `actions` slot.

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

## Accessibility
- Defaults to native `<textarea>` and submit `<button>` controls.
- When `rich_text: true`, the composer uses the same TipTap-backed editor surface as `FlatPack::TextArea::Component`.
- Provide surrounding label context (or `aria-*` attributes) in composed forms.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
