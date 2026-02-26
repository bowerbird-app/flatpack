# Comments Inline Input Component

## Purpose
Render a minimal multiline comment input with an inline submit button.

## When to use
Use this component for lightweight comment entry UIs where users may write short or multiline comments without a full composer toolbar.

## Behavior

- The textarea auto-grows as the user types.
- The container corner radius is controlled by theme tokens.
- Pressing Enter inserts a new line.
- Comments are submitted only when the submit button is clicked.

## Theming

- `--comments-inline-input-radius` controls the inline input corner radius.

## Class
- Primary: `FlatPack::Comments::InlineInput::Component`

## Basic Usage

```erb
<%= form_with url: demo_comments_path, method: :post, local: true do %>
  <%= render FlatPack::Comments::InlineInput::Component.new(
    name: "comment[body]",
    placeholder: "Write a comment...",
    submit_label: "Comment"
  ) %>
<% end %>
```

## With Custom Label

```erb
<%= render FlatPack::Comments::InlineInput::Component.new(
  submit_label: "Post"
) %>
```

## With Initial Value

```erb
<%= render FlatPack::Comments::InlineInput::Component.new(
  value: "Prefilled text"
) %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `placeholder` | String | `"Write a comment..."` | Input placeholder text |
| `submit_label` | String | `"Comment"` | Submit button text |
| `disabled` | Boolean | `false` | Disable input and submit button |
| `form` | String | `nil` | Associate input/button to an external form ID |
| `name` | String | `"comment"` | Input name attribute |
| `value` | String | `nil` | Input value |
| `rows` | Integer | `1` | Initial textarea rows |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes on root container |

## Accessibility

- The textarea and button are keyboard accessible by default.
- Use standard Rails form labels or ARIA attributes via `system_arguments` when needed.

## Related

- Use `FlatPack::Comments::Composer::Component` for multiline comments with toolbar/attachments/actions.