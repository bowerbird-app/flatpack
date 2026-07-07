# Comments Inline Input

## Purpose
Render a compact inline comment input with an auto-expanding textarea and submit button.

## When to use
Use Inline Input for lightweight comment entry where a full toolbar/composer is not needed.

## Class
- Primary: `FlatPack::Comments::InlineInput::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `placeholder` | String | `"Write a comment..."` | No | Textarea placeholder text. |
| `submit_label` | String | `"Comment"` | No | Submit button label. |
| `disabled` | Boolean | `false` | No | Disables textarea and submit button, and applies muted container styles. |
| `form` | String or nil | `nil` | No | Associates textarea/button with an external form id. |
| `name` | String | `"comment"` | No | Textarea `name` attribute. |
| `value` | String or nil | `nil` | No | Initial textarea content. |
| `rows` | Integer | `1` | No | Initial textarea rows before auto-expand. |
| `rich_text` | Boolean | `false` | No | Opts the inline input into the TipTap-backed `TextArea` rich text mode. |
| `rich_text_options` | Hash | `{}` | No | Pass-through options for `FlatPack::TextArea::Component` rich text configuration, including host-registered TipTap addons. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into root container. |

## Slots
None.

## Variants
None.

## Example

```erb
<%= form_with url: demo_comments_path, method: :post, local: true do %>
  <%= render FlatPack::Comments::InlineInput::Component.new(
    name: "comment[body]",
    placeholder: "Write a comment...",
    submit_label: "Comment"
  ) %>
<% end %>
```

## Accessibility
Keyboard and form semantics come from native `textarea` and `button[type=submit]` by default. When `rich_text: true`, the input uses the same TipTap-backed editor surface as `FlatPack::TextArea::Component`. Add surrounding label context (or ARIA attributes via `system_arguments`) when needed for screen readers.

If your app registers custom TipTap addons through `flat_pack/tiptap/addon_registry`, the inline input can opt into them with `rich_text_options[:addons]`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Auto-grow behavior requires Stimulus controller `flat-pack--text-area`.
