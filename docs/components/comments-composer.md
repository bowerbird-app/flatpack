# Comments Composer

## Purpose
Render a comment entry surface with textarea, optional toolbar/attachments, and submit actions.

## When to use
Use Comments Composer where users create or edit comments with optional custom actions.

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
  show_cancel: true
) %>
```

## Accessibility
- Uses native `<textarea>` and submit `<button>` controls.
- Provide surrounding label context (or `aria-*` attributes) in composed forms.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
