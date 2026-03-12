# Content Editor

## Purpose
In-place rich-text editor that lets users edit HTML content directly on the page and save it via a PATCH request — no full page reload required.

## When to use
Use Content Editor when you need lightweight inline editing of an HTML body field on a show/detail page (e.g. wiki pages, articles, CMS content blocks). Prefer it over embedding a full form when the primary intent is reading with occasional edit.

## Class
- Primary: `FlatPack::ContentEditor::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `update_url` | String | — | yes | URL that receives a PATCH request with the edited content. |
| `upload_url` | String | `nil` | no | URL for image uploads (POST). When omitted the image toolbar button is hidden. |
| `toolbar` | Boolean | `true` | no | Render the floating balloon formatting toolbar. Set to `false` for plain text-only editing. |
| `content_class` | String | `nil` | no | Extra CSS classes appended to the content region element. |
| `field_name` | String | `"body"` | no | Form field name sent with the saved HTML. |
| `field_format_name` | String | `"body_format"` | no | Form field name sent alongside the content to indicate format. |
| `field_format` | String | `"html"` | no | Format value sent as `field_format_name`; defaults to `"html"`. |
| `**system_arguments` | Hash | `{}` | no | Additional HTML attributes forwarded to the outer wrapper element. |

## Slots
- Default block content is rendered as the initial HTML inside the editable content region.

## Variants
- **With toolbar** (`toolbar: true`, default): floating balloon toolbar appears on text selection with bold, italic, underline, strikethrough, headings (H1–H3), lists, blockquote, and link controls.
- **Without toolbar** (`toolbar: false`): no balloon toolbar; users can still save/cancel with action buttons.
- **With image upload** (`upload_url:` provided): image button appears in the toolbar; clicking it opens a file picker and uploads the image via a POST request.

## Example

```erb
<%= render FlatPack::ContentEditor::Component.new(
  update_url: article_path(@article)
) do %>
  <%= raw @article.body %>
<% end %>
```

### With image uploads

```erb
<%= render FlatPack::ContentEditor::Component.new(
  update_url: article_path(@article),
  upload_url: article_upload_image_path(@article),
  field_name: "article[body]",
  field_format_name: "article[body_format]"
) do %>
  <%= raw @article.body %>
<% end %>
```

### Without toolbar

```erb
<%= render FlatPack::ContentEditor::Component.new(
  update_url: page_path(@page),
  toolbar: false,
  field_name: "page[body]"
) do %>
  <%= raw @page.body %>
<% end %>
```

## Accessibility
- Edit, Save, and Cancel controls are native `<button>` elements, keyboard-accessible by default.
- The content region receives `contenteditable="true"` only while editing; it is `"false"` at rest.
- Save and Cancel buttons carry `hidden` attribute when not in edit mode so they are not reachable by screen readers or keyboard in the display state.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Requires Stimulus controller `flat-pack--content-editor`.
- Requires stylesheet `flat_pack/content_editor.css` (imported automatically via `flat_pack/application.css`).
- Image upload variant requires a server-side endpoint that accepts a `file` multipart field and returns `{ "url": "..." }` JSON.
