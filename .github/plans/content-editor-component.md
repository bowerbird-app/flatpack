# Plan: FlatPack::ContentEditor::Component

## Goal

Extract the in-place content editing behaviour currently implemented as a
one-off Stimulus controller in the dummy app
(`test/dummy/app/javascript/controllers/article_editor_controller.js` +
`test/dummy/app/views/articles/show.html.erb`) into a reusable gem component.

After this work:
- The gem ships `FlatPack::ContentEditor::Component` (ViewComponent + Stimulus
  controller) that any host app can drop into a show/detail view.
- The dummy app's article show view uses the new component.
- The bespoke `article_editor_controller.js` in the dummy app is deleted.

---

## Architecture decision: Stimulus controller on the wrapper div

Use a **Stimulus controller** (`flat-pack--content-editor`) attached to the
outermost wrapper `<div>` rendered by the Ruby component. This is identical to
how every other FlatPack component works (e.g. `flat-pack--tiptap`,
`flat-pack--modal`, `flat-pack--popover`).

**Do not** use a CSS class as the targeting mechanism — CSS classes carry no
lifecycle and cannot scope targets reliably.

---

## Files to create

### 1. `app/components/flat_pack/content_editor/component.rb`

ViewComponent class. Renders the full HTML scaffold.

**Constructor:**

```ruby
def initialize(
  update_url:,        # String — PATCH endpoint for saving (required)
  upload_url: nil,    # String — image upload endpoint (optional; hides image button when nil)
  toolbar: true,      # Boolean — render balloon toolbar (default true)
  content_class: nil  # String — extra CSS classes on the content region
)
```

**Rendered HTML structure:**

```html
<div data-controller="flat-pack--content-editor"
     data-flat-pack--content-editor-update-url-value="<update_url>"
     data-flat-pack--content-editor-upload-url-value="<upload_url>"  <!-- omit attr when nil -->
     class="flat-pack-content-editor">

  <!-- Action bar -->
  <div class="flat-pack-content-editor-actions">
    <button type="button"
            data-flat-pack--content-editor-target="editBtn"
            data-action="flat-pack--content-editor#enableEditing"
            class="flat-pack-btn flat-pack-btn--primary">
      Edit
    </button>
    <button type="button"
            data-flat-pack--content-editor-target="saveBtn"
            data-action="flat-pack--content-editor#save"
            hidden
            class="flat-pack-btn flat-pack-btn--primary">
      Save
    </button>
    <button type="button"
            data-flat-pack--content-editor-target="cancelBtn"
            data-action="flat-pack--content-editor#cancel"
            hidden
            class="flat-pack-btn flat-pack-btn--secondary">
      Cancel
    </button>
  </div>

  <!-- Balloon toolbar (only rendered when toolbar: true) -->
  <!-- Reuses existing gem CSS classes: flat-pack-richtext-bubble-menu,
       flat-pack-richtext-bubble-btn, flat-pack-richtext-bubble-sep -->
  <div class="flat-pack-richtext-bubble-menu"
       data-flat-pack--content-editor-target="balloonToolbar"
       data-action="mousedown->flat-pack--content-editor#keepSelection"
       style="position:fixed;z-index:9999;display:none;"
       hidden>
    <!-- Text formatting -->
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="bold" title="Bold"><!-- bold SVG --></button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="italic" title="Italic"><!-- italic SVG --></button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="underline" title="Underline"><!-- underline SVG --></button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="strikeThrough" title="Strikethrough"><!-- strike SVG --></button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="removeFormat" title="Clear formatting"><!-- clear SVG --></button>
    <span class="flat-pack-richtext-bubble-sep"></span>
    <!-- Headings -->
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="h1" title="Heading 1"
            style="font-size:11px;font-weight:700;width:28px;">H1</button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="h2" title="Heading 2"
            style="font-size:11px;font-weight:700;width:28px;">H2</button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="h3" title="Heading 3"
            style="font-size:11px;font-weight:700;width:28px;">H3</button>
    <span class="flat-pack-richtext-bubble-sep"></span>
    <!-- Lists & block -->
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="insertUnorderedList" title="Bullet list"><!-- ul SVG --></button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="insertOrderedList" title="Ordered list"><!-- ol SVG --></button>
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="blockquote" title="Blockquote"><!-- quote SVG --></button>
    <span class="flat-pack-richtext-bubble-sep"></span>
    <!-- Link -->
    <button type="button" class="flat-pack-richtext-bubble-btn"
            data-action="flat-pack--content-editor#format"
            data-command="link" title="Insert / edit link"><!-- link SVG --></button>
    <!-- Image upload (only rendered when upload_url is present) -->
    <% if @upload_url %>
      <span class="flat-pack-richtext-bubble-sep"></span>
      <button type="button" class="flat-pack-richtext-bubble-btn"
              data-action="flat-pack--content-editor#triggerImageUpload"
              title="Insert image"><!-- image SVG --></button>
      <input type="file" accept="image/*" hidden
             data-flat-pack--content-editor-target="imageInput"
             data-action="change->flat-pack--content-editor#imageInputChanged">
    <% end %>
  </div>

  <!-- Content region — host app yields HTML here -->
  <div class="flat-pack-content-editor-content <%= @content_class %>"
       data-flat-pack--content-editor-target="displayContent">
    <%= content  <!-- ViewComponent slot/yield --> %>
  </div>
</div>
```

**Implementation notes for the Ruby component:**
- Copy the exact SVG icon markup from the existing
  `test/dummy/app/views/articles/show.html.erb` balloon toolbar section. Do
  not regenerate or simplify them.
- Use `content_tag` + `safe_join` following the same pattern as
  `FlatPack::TextArea::Component#call`.
- Inherit from `FlatPack::BaseComponent`.
- The `<style>` tag for `a { text-decoration: underline }` that currently
  lives inline in the view should become a single scoped rule targeting
  `.flat-pack-content-editor-content a` — place it in the gem's
  `app/assets/stylesheets/flat_pack/content_editor.css` (new file, see
  below).

---

### 2. `app/javascript/flat_pack/controllers/content_editor_controller.js`

**Exact source:** generalise `article_editor_controller.js` from the dummy app.
Copy the entire file and make the following changes only:

| Old (dummy app) | New (gem controller) |
|---|---|
| `article-editor` identifier (implicit) | `flat-pack--content-editor` (set by Stimulus via filename in importmap) |
| `data-article-editor-*` attribute prefixes | `data-flat-pack--content-editor-*` (handled automatically by Stimulus) |
| `article[body]` and `article[body_format]` hardcoded form field names | Read the field name from a new Stimulus value: `fieldName: { type: String, default: "body" }` and `fieldFormat: { type: String, default: "html" }` |

**Values:**

```js
static values = {
  updateUrl:   String,
  uploadUrl:   { type: String, default: "" },
  fieldName:   { type: String, default: "body" },
  fieldFormat: { type: String, default: "html" },
}
```

**Targets:** same as dummy app — `editBtn`, `saveBtn`, `cancelBtn`,
`displayContent`, `balloonToolbar`, `imageInput`.

**`save()` method** — replace the hardcoded field names:

```js
body.append(this.fieldNameValue, this.displayContentTarget.innerHTML)
body.append(`${this.fieldNameValue.split("[")[0]}[body_format]`, this.fieldFormatValue)
// Keep _method: patch and CSRF logic unchanged
```

Or more cleanly — pass the full field names as separate values:

```js
// Simpler: just two values
body.append(this.fieldNameValue, this.displayContentTarget.innerHTML)
body.append(this.fieldFormatNameValue, this.fieldFormatValue)
```

Whichever approach, the Ruby component must pass the correct attribute values
so a host app can point to any field name (e.g. `article[body]`).

**`imageInputChanged()`** — only runs when `this.uploadUrlValue` is non-empty
(guard with `if (!this.uploadUrlValue) return`).

**No other logic changes.** All private methods (`#handleSelection`,
`#handleImageClick`, `#savedContent`, `#savedRange`, `#selectedImage`,
`#selectionHandler`, `#imageClickHandler`) stay identical.

---

### 3. `app/assets/stylesheets/flat_pack/content_editor.css`

Minimal new stylesheet. Only two rules needed:

```css
/* Scope link underline to content editor display region */
.flat-pack-content-editor-content a {
  text-decoration: underline;
}

/* Action bar layout */
.flat-pack-content-editor-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-bottom: 1rem;
}
```

Register this file in `app/assets/stylesheets/flat_pack.css` (or whatever
the gem's CSS manifest is) using the same `@import` pattern as existing
component stylesheets.

---

### 4. Registration in importmap

The gem's `config/importmap.rb` already pins all files under
`app/javascript/flat_pack/controllers` via:

```ruby
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__),
  under: "controllers/flat_pack",
  to: "flat_pack/controllers",
  preload: false
```

No change needed — the new `content_editor_controller.js` will be picked up
automatically as `controllers/flat_pack/content_editor_controller`.

The host app must register it with Stimulus under the identifier
`flat-pack--content-editor`. Check how `tiptap_controller.js` is registered
in the dummy app's `app/javascript/application.js` and follow the same pattern
for the new controller.

---

## Files to modify

### 5. `test/dummy/app/views/articles/show.html.erb`

Replace the entire bespoke `data-controller="article-editor"` block with:

```erb
<%= render FlatPack::ContentEditor::Component.new(
  update_url: article_path(@article),
  upload_url: article_upload_image_url,
  field_name: "article[body]",
  field_format_name: "article[body_format]"
) do %>
  <%= raw @article.body %>
<% end %>
```

Remove the inline `<style>` tag (now handled by gem CSS).

### 6. `test/dummy/app/javascript/application.js` (or controllers index)

Register the new gem controller:

```js
import ContentEditorController from "controllers/flat_pack/content_editor_controller"
application.register("flat-pack--content-editor", ContentEditorController)
```

Verify the existing pattern by checking how `flat-pack--tiptap` is registered
in the same file and mirror it exactly.

### 7. Delete `test/dummy/app/javascript/controllers/article_editor_controller.js`

This file is fully superseded by the gem controller. Delete it.

---

## Files to create (tests)

### 8. `test/components/flat_pack/content_editor_component_test.rb`

Follow the pattern in
`test/components/flat_pack/text_area_rich_text_component_test.rb`.

Required test cases:

```ruby
# Rendering
test_renders_stimulus_controller_wrapper
  # assert data-controller="flat-pack--content-editor"

test_wrapper_has_update_url_value
  # assert data-flat-pack--content-editor-update-url-value=<url>

test_wrapper_has_upload_url_value_when_provided
test_wrapper_omits_upload_url_when_nil

test_renders_edit_save_cancel_buttons
  # assert editBtn, saveBtn (hidden), cancelBtn (hidden) targets

test_renders_balloon_toolbar_when_toolbar_true
  # assert .flat-pack-richtext-bubble-menu with balloonToolbar target

test_omits_balloon_toolbar_when_toolbar_false

test_toolbar_contains_bold_italic_underline_strike_buttons
test_toolbar_contains_heading_buttons
test_toolbar_contains_list_buttons
test_toolbar_contains_link_button

test_toolbar_contains_image_button_when_upload_url_present
  # assert triggerImageUpload action present
test_toolbar_omits_image_button_when_upload_url_nil
  # refute imageInput target

test_content_region_has_display_content_target
test_content_region_renders_yielded_html
  # render with block, assert yielded content appears in displayContent target

test_content_class_applied_to_content_region
  # render with content_class: "prose max-w-none", assert class present
```

---

## Verification steps

After implementation, run:

```bash
# Component tests
bundle exec rails test test/components/flat_pack/content_editor_component_test.rb

# Full test suite (no regressions)
bundle exec rails test

# Manual: visit dummy app article show page
# 1. Click Edit — content region becomes editable, toolbar visible
# 2. Select text — balloon toolbar appears above selection
# 3. Apply bold/italic/H2/link — formatting applied
# 4. Click image button — file picker opens, image inserted on selection
# 5. Click inserted image — toolbar appears, link button wraps image in <a>
# 6. Click Save — PATCH request fires, edit mode exits
# 7. Click Cancel — content restored to original, edit mode exits
```

---

## What NOT to change

- Do not modify `FlatPack::TextArea::Component` or its Tiptap controller.
- Do not add Tiptap/ProseMirror as a dependency — this component uses only
  native browser `contentEditable` and `execCommand`.
- Do not change the CSS variable names or `flat-pack-richtext-*` class names —
  the toolbar reuses those existing classes intentionally.
- Do not add a docs page — that is a separate task.
