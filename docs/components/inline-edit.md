# Inline Edit

## Purpose
Edit a heading or paragraph in place. The same element becomes `contenteditable`. Type, size, weight, and wrapping stay put. No bordered field appears.

## When to use
Use Inline Edit on a show page when people change a title, a short note, or a rich blurb without opening a form. Prefer a normal Text Input inside a form when the field sits in a settings layout. Prefer Content Editor when the page already has an Edit / Save / Cancel bar around a long HTML body.

## Class
- Primary: `FlatPack::InlineEdit::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `name` | String | — | yes | Hidden input name, and the key sent to `update_url:`. |
| `value` | String | `nil` | no | Starting text. `:rich` is sanitized with `RichTextSanitizer`. |
| `tag` | Symbol | `:span` for `:text`, `:div` otherwise | no | Element to render when there is no block. Allowed: `:span`, `:h1`–`:h6`, `:p`, `:div`. |
| `mode` | Symbol | `:text` | no | `:text` is one line (Enter saves, newlines blocked). `:plain` is multi-line (Enter newline, Cmd/Ctrl+Enter saves). `:rich` shows the Content Editor bubble toolbar. |
| `update_url` | String | `nil` | no | Self-save URL. Sanitized (`http`, `https`, `mailto`, `tel`, or relative). Omit to sync only the hidden input. |
| `method` | Symbol | `:patch` | no | Request method for `update_url:`. Allowed: `:patch`, `:put`, `:post`. |
| `label` | String | `"Edit text"` | no | Accessible name (`aria-label`). |
| `placeholder` | String | `"Untitled"` | no | Faint text when the surface is empty. |
| `maxlength` | Integer | `nil` | no | Component-enforced character limit. |
| `required` | Boolean | `false` | no | Component-enforced. Empty save shows an error and does not request. |
| `save_on_blur` | Boolean | `true` | no | Save when the surface loses focus. |
| `cue` | Symbol | `:highlight` | no | Rest hint. Allowed: `:highlight` (default), `:tint` (same paint), `:underline`, `:none`. |
| `**system_arguments` | Hash | `{}` | no | Extra HTML attributes. In tag mode, `class:` lands on the editable tag. In wrap mode, extras land on the wrapper. |

## Slots
- Default block: the wrapped markup stays as-is. The controller edits `data-inline-edit-target`, then the first heading, then the first `p`. A heading wins over an earlier tagline `p` (Hero wrap).

## Variants
- **Text** (`mode: :text`): single line. Enter saves. Paste is plain. Newlines are stripped.
- **Plain** (`mode: :plain`): multi-line. Cmd/Ctrl+Enter saves.
- **Rich** (`mode: :rich`): selection shows the Content Editor bubble. No Edit / Save / Cancel bar.
- **Cue** (`cue:`): highlight (default) is a Notion-style wash on hover — soft `--inline-edit-hover-bg`, `--radius-sm`, extra inset via box-shadow spread so layout does not move. Focus and edit use a slightly stronger `--inline-edit-focus-bg` and a thin `--inline-edit-focus-color` ring. `:tint` is the same paint. `:underline` is the old rest line. `:none` stays quiet until focus. Pointer is `cursor: text`. Wrapped lines clone the wash (`box-decoration-break: clone`).

## Example

```erb
<%= render FlatPack::InlineEdit::Component.new(
  tag: :h1,
  value: @kit.title,
  name: "kit[title]",
  update_url: kit_path(@kit),
  label: "Kit title",
  placeholder: "Untitled kit"
) %>
```

### Keep a PageTitle look

```erb
<%= render FlatPack::InlineEdit::Component.new(
  name: "kit[title]",
  update_url: kit_path(@kit)
) do %>
  <%= render FlatPack::PageTitle::Component.new(title: @kit.title) %>
<% end %>
```

### Rich blurb

```erb
<%= render FlatPack::InlineEdit::Component.new(
  tag: :div,
  mode: :rich,
  value: @kit.intro_html,
  name: "kit[intro]",
  update_url: kit_path(@kit)
) %>
```

### Hidden field only

```erb
<%= form_with url: kit_path(@kit), method: :patch do %>
  <%= render FlatPack::InlineEdit::Component.new(
    tag: :h2,
    value: @kit.title,
    name: "kit[title]",
    label: "Kit title"
  ) %>
  <%= render FlatPack::Button::Component.new(text: "Save kit", type: :submit) %>
<% end %>
```

## Accessibility
- Rest is focusable (`tabindex="0"`, `role="textbox"`, `aria-label`). `aria-multiline` is set when `mode` is not `:text`.
- Click or Enter starts editing. Escape restores the last saved value.
- Saving announces through an `aria-live` region. Failure restores the value, paints a red wash (or a red underline when `cue: :underline`), and reads the error.
- `prefers-reduced-motion: reduce` drops highlight and status motion.

## Dependencies
- Stimulus controller `flat-pack--inline-edit`.
- Stylesheet `flat_pack/inline_edit.css` (also bundled from `flat_pack/application.css`).
- Tokens `--inline-edit-hover-bg`, `--inline-edit-focus-bg`, `--inline-edit-focus-color`, `--inline-edit-cue-color`, `--inline-edit-error-color`, `--inline-edit-placeholder-color`, `--inline-edit-placeholder-hover-color` (light and dark). Hover and focus washes are `color-mix` tints (~7–11% light, ~9–14% dark). Placeholder copy darkens a little on hover and focus.
- `:rich` reuses the Content Editor balloon (`FlatPack::Shared::ExecCommandBalloon` and `exec_command_bubble.js`).
- `update_url:` requests send `name=value` with the CSRF token and `Accept: text/vnd.turbo-stream.html`. Turbo Stream bodies are applied with `Turbo.renderStreamMessage`.
- Events: `flat-pack:inline-edit:save` (cancelable), `flat-pack:inline-edit:saved`, `flat-pack:inline-edit:error`.
