# Input Components

## Purpose
Provide a consistent set of text, choice, and file form inputs with shared validation styling and accessible labeling patterns.

## When to use
Use these components when you need FlatPack-styled form controls with consistent error handling, required/disabled states, and optional interactive behaviors. This guide also covers Select-based nested multiselects for hierarchical parent/child choices.

## Class
- Primary: `FlatPack::TextInput::Component`
- Related classes: `FlatPack::PasswordInput::Component`, `FlatPack::EmailInput::Component`, `FlatPack::PhoneInput::Component`, `FlatPack::SearchInput::Component`, `FlatPack::TextArea::Component`, `FlatPack::UrlInput::Component`, `FlatPack::NumberInput::Component`, `FlatPack::DateInput::Component`, `FlatPack::DateRangeInput::Component`, `FlatPack::DateTimeInput::Component`, `FlatPack::TimeInput::Component`, `FlatPack::FileInput::Component`, `FlatPack::Checkbox::Component`, `FlatPack::RadioGroup::Component`, `FlatPack::Select::Component`, `FlatPack::Switch::Component`
- Related Stimulus controller: `flat-pack--nested-multiselect` for legacy hierarchical checkbox groups that submit hidden inputs.
- Related docs: [Range Input](range-input.md) (`FlatPack::RangeInput::Component`), [Color Swatch](color-swatch.md) (`FlatPack::ColorSwatch::Component`), [Font Swatch](font-swatch.md) (`FlatPack::FontSwatch::Component`)

## Props
Common props used across most input components:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `name` | String | none | yes | Field name submitted with the form. |
| `value` | String, Numeric, Date, Time, DateTime | `nil` | no | Current value. Supported value types vary by component. |
| `placeholder` | String | `nil` | no | Placeholder text for text-like inputs. |
| `label` | String | `nil` | no | Visible label text. |
| `help_text` | String | `nil` | no | Optional plain-text guidance rendered below the control using the same muted text style as character counts. Only plain `String` values are accepted; HTML-like content is escaped as text. |
| `error` | String | `nil` | no | Error message; enables invalid styling and `aria-describedby`. |
| `disabled` | Boolean | `false` | no | Disables interaction and submission for the control. |
| `required` | Boolean | `false` | no | Marks the control as required. |
| `**system_arguments` | Hash | `{}` | no | Standard HTML attributes (`id`, `class`, `data`, `aria`, etc.). |

Component-specific props:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `rows` | Integer | `3` | no | Initial row count (`TextArea` plain mode only; ignored when `rich_text: true`). |
| `character_count` | Boolean | `false` | no | Enables live count text in `TextInput` and `TextArea` (plain and rich text modes). |
| `quick_copy` | Boolean | `false` | no | Enables one-click copy for `TextInput` and plain `TextArea` from both field click and a trailing copy icon button, with toast feedback; the control is rendered `readonly` when enabled. Not applied when `TextArea` uses `rich_text: true`. |
| `rich_text` | Boolean | `false` | no | Activates the TipTap rich text editor in place of the native `<textarea>`. |
| `rich_text_options` | Hash | `{}` | no | Fine-grained config for the rich text editor; see [Rich Text Options](#rich-text-options) below. |
| `min_characters` | Integer | `nil` | no | Low threshold warning for `TextInput` and `TextArea` count color. |
| `max_characters` | Integer | `nil` | no | High threshold and `current/max` format for `TextInput` and `TextArea` count. |
| `min` | Numeric or date-like | `nil` (`NumberInput`), `0` (`RangeInput`) | no | Minimum value/date/time (`NumberInput`, `DateInput`, `DateTimeInput`, `TimeInput`, `RangeInput`). |
| `max` | Numeric or date-like | `nil` (`NumberInput`), `100` (`RangeInput`) | no | Maximum value/date/time (`NumberInput`, `DateInput`, `DateTimeInput`, `TimeInput`, `RangeInput`). |
| `picker` | Symbol | `:native` | no | Date input picker mode (`DateInput`): `:native` or `:flatpack_date_picker`. |
| `start_name` | String | none | yes (`DateRangeInput`) | Hidden field name used to submit the selected range start date. |
| `end_name` | String | none | yes (`DateRangeInput`) | Hidden field name used to submit the selected range end date. |
| `start_value` | String, Date, Time, DateTime | `nil` | no (`DateRangeInput`) | Initial selected range start date. |
| `end_value` | String, Date, Time, DateTime | `nil` | no (`DateRangeInput`) | Initial selected range end date. |
| `step` | Numeric | `1` | no | Step increment (`NumberInput`, `RangeInput`). |
| `accept` | String | `nil` | no | File MIME/extensions whitelist for `FileInput`. Dangerous executable extensions raise `ArgumentError`. |
| `multiple` | Boolean | `false` | no | Enables multiple file selection (`FileInput`) and multi-value selection (`Select`). |
| `max_size` | Integer | `nil` | no | Max file size in bytes for `FileInput` client-side checks. Must be positive when provided. |
| `preview` | Boolean | `true` | no | Enables image preview area in `FileInput`. |
| `checked` | Boolean | `false` | no | Initial checked state (`Checkbox`, `Switch`). |
| `options` | Array | none | yes (`RadioGroup`, `Select`) | Options list. Supports `String`, `[label, value]`, or `{ label:, value:, disabled: }`. For nested Select multiselects, hashes may include `children:` and may use `id:` instead of `value:`. |
| `searchable` | Boolean | `false` | no | Uses custom searchable dropdown mode for `Select`. |
| `search_mode` | Symbol | `:local` | no | Search mode for `Select`: `:local` (client filter) or `:remote` (AJAX endpoint). |
| `search_endpoint` | String | `nil` | no | Required when `search_mode: :remote`; URL used to fetch Select options. |
| `search_param` | String | `"q"` | no | Query string parameter name used for remote Select requests. |
| `min_search_length` | Integer | `2` | no | Minimum query length before remote Select requests are triggered. |
| `size` | Symbol | `:md` | no | Switch size: `:sm`, `:md`, `:lg` (`Switch`). |

## Slots
None.

## Variants
- Input classes by type: `TextInput`, `PasswordInput`, `EmailInput`, `PhoneInput`, `SearchInput`, `TextArea`, `UrlInput`, `NumberInput`, `DateInput`, `FileInput`
- Choice inputs: `Checkbox`, `RadioGroup`, `Select`, `Switch`
- Select rendering modes: native select (`searchable: false`) and custom searchable select (`searchable: true`)
- Select selection modes: single-value (`multiple: false`) and multi-value (`multiple: true`)
- In searchable multiselect mode, selected options render as chips inside the trigger
- In searchable multiselect dropdown rows, selected state is indicated by checkbox state with neutral row styling (no primary selected row background)
- Nested multiselect option rows use square corners (`rounded-none`) to align child option grouping under parent rows
- Hierarchical nested multiselect via `FlatPack::Select::Component` with `multiple: true` and option `children:`, including parent/child synchronization, indeterminate parent states, initial selection hydration, and hidden input generation
- Legacy hierarchical nested multiselect via `flat-pack--nested-multiselect`; prefer Select for new usage
- Remote Select mode (`search_mode: :remote`) fetches options from `search_endpoint` with `search_param`

## Example
```erb
<%= render FlatPack::TextInput::Component.new(
  name: "user[email]",
  label: "Email",
  placeholder: "you@example.com",
  help_text: "Use the address where you receive account updates.",
  required: true
) %>
```

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "post[headline]",
  label: "Headline",
  placeholder: "Write a short headline...",
  character_count: true,
  min_characters: 20,
  max_characters: 60
) %>
```

```erb
<%= render FlatPack::TextInput::Component.new(
  name: "api[key]",
  label: "API Key",
  value: @api_key,
  quick_copy: true
) %>
```

Additional focused examples:

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "post[body]",
  label: "Body",
  rows: 4,
  character_count: true,
  min_characters: 20,
  max_characters: 280
) %>
```

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "release[notes]",
  label: "Release Notes",
  value: "Fixed onboarding bug\nAdded quick copy to text area",
  rows: 3,
  quick_copy: true
) %>
```

```erb
<%= render FlatPack::Select::Component.new(
  name: "user[country]",
  label: "Country",
  options: [["United States", "US"], ["Canada", "CA"]],
  help_text: "Choose the country used for billing and tax rules.",
  searchable: true,
  placeholder: "Search..."
) %>
```

```erb
<%= render FlatPack::Select::Component.new(
  name: "user[frameworks]",
  label: "Frameworks",
  options: [["Ruby on Rails", "rails"], ["Hotwire", "hotwire"], ["React", "react"]],
  searchable: true,
  multiple: true,
  value: ["rails", "hotwire"],
  placeholder: "Search frameworks..."
) %>
```

```erb
<%= render FlatPack::Select::Component.new(
  name: "locations",
  label: "Service Locations",
  placeholder: "Select locations...",
  searchable: true,
  multiple: true,
  options: [
    {
      label: "Australia",
      value: "australia",
      children: [
        { label: "VIC", value: "vic" },
        { label: "NSW", value: "nsw" },
        { label: "QLD", value: "qld" }
      ]
    },
    {
      label: "Malaysia",
      value: "malaysia",
      children: [
        { label: "Penang", value: "penang" },
        { label: "Kuala Lumpur", value: "kuala-lumpur" },
        { label: "Selangor", value: "selangor" }
      ]
    }
  ],
  value: ["australia"]
) %>
```

Nested Select options require `multiple: true`. Selecting a parent selects the parent and all child values; deselecting a parent clears its children. Selecting all children automatically selects the parent, partial child selection renders the parent indeterminate, and submitted hidden inputs are ordered parent first followed by selected children. Nested Select is intended to replace `flat-pack--nested-multiselect` for new usage.

```erb
<% location_options = [
  {
    id: "australia",
    label: "Australia",
    children: [
      { id: "victoria", label: "Victoria" },
      { id: "new-south-wales", label: "New South Wales" }
    ]
  },
  {
    id: "malaysia",
    label: "Malaysia",
    children: [
      { id: "penang", label: "Penang" },
      { id: "selangor", label: "Selangor" }
    ]
  }
] %>

<div
  data-controller="flat-pack--nested-multiselect"
  data-flat-pack--nested-multiselect-options-value="<%= location_options.to_json %>"
  data-flat-pack--nested-multiselect-selected-value="<%= ["australia", "victoria", "penang"].to_json %>"
  data-flat-pack--nested-multiselect-input-name-value="locations[]"></div>
```

`flat-pack--nested-multiselect` is retained for backward compatibility but is deprecated for new examples. It expects each option group to provide `id`, `label`, and optional `children` entries. When a parent is preselected, the controller automatically selects all of its children; when only some children are selected, the parent checkbox is rendered in the native indeterminate state.

```erb
<%= render FlatPack::Select::Component.new(
  name: "user[assignee]",
  label: "Assignee",
  options: [],
  searchable: true,
  search_mode: :remote,
  search_endpoint: demo_forms_select_options_path,
  search_param: "q",
  min_search_length: 2,
  placeholder: "Type to search people..."
) %>
```

Remote endpoint response format for `Select` supports either:

```json
[{ "label": "Alice Johnson", "value": "alice-johnson" }]
```

or:

```json
{ "items": [{ "label": "Alice Johnson", "value": "alice-johnson" }] }
```

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
<%= render FlatPack::DateInput::Component.new(
  name: "billing_anchor_date",
  label: "Billing Anchor Date",
  picker: :flatpack_date_picker,
  min: (Date.today - 30).to_s,
  max: (Date.today + 30).to_s,
  value: Date.today.to_s
) %>
```

```erb
<%= render FlatPack::DateRangeInput::Component.new(
  start_name: "reporting_period_start",
  end_name: "reporting_period_end",
  label: "Reporting Period",
  start_value: (Date.today - 30).to_s,
  end_value: Date.today.to_s,
  min: (Date.today - 365).to_s,
  max: Date.today.to_s
) %>
```

In custom picker mode, both `DateInput` (`picker: :flatpack_date_picker`) and `DateRangeInput` provide quick presets: `Today`, `Yesterday`, `Last 3 days`, `This week`, `Last week`, `Last 4 weeks`, `This month`, `Last month`, `This year`, `Last year`.
The popup renders as side-by-side quick ranges + calendar on larger screens and stacks vertically on smaller screens.

## Rich Text Mode

When `rich_text: true` is set on `FlatPack::TextArea::Component`, the native `<textarea>` is replaced with a fully featured [TipTap](https://tiptap.dev) editor. The editor is rendered server-side as empty containers and bootstrapped by the `flat-pack--tiptap` Stimulus controller at runtime.

`FlatPack::Comments::Composer::Component` and `FlatPack::Comments::InlineInput::Component` both forward `rich_text` and `rich_text_options` directly to this same `TextArea` API, so the toolbar, bubble menu, and preset behavior documented below also apply to those comments components.

### How it works

- The editor output (HTML by default, or JSON) is written to a hidden `<input type="hidden">` that carries the field `name`, so the form submits as normal.
- Toolbar, bubble menu, and floating menu regions are pre-rendered in HTML and populated by JS after `Editor` is initialised.
- TipTap UI components (BubbleMenu, FloatingMenu) are used — not custom headless implementations.
- React and Vue framework wrappers are intentionally excluded; only the core vanilla-JS TipTap API is used.

### Rich Text Options

Pass any of these keys inside `rich_text_options: { ... }`. All keys accept symbols or strings.

| key | type | default | description |
| --- | --- | --- | --- |
| `preset` | Symbol | `:minimal` | Extension set: `:minimal`, `:content`, or `:full`. |
| `format` | Symbol | `:html` | Output format synced to the hidden field: `:html` or `:json`. |
| `toolbar` | Symbol \| Array | `:standard` | Toolbar preset (`:minimal`, `:standard`, `:full`, `:none`) or an Array of tool names, including host-registered addon tool names. |
| `bubble_menu` | Boolean | `true` | Show TipTap BubbleMenu on text selection. |
| `floating_menu` | Boolean | `false` | Show TipTap FloatingMenu at the start of an empty line. |
| `character_count` | Boolean | `false` | Display live character count below the editor. |
| `readonly` | Boolean | `false` | Put the editor in read-only mode. |
| `mentions` | Boolean \| Hash | `false` | Enable `@mention` support. Pass a Hash to supply `suggestion:` config. |
| `uploads` | Boolean \| Hash | `false` | Enable file-upload support in the image toolbar button. Pass `{ url: "/path/to/upload" }` to supply the upload endpoint. See [Image Upload](#image-upload) below. |
| `tables` | Boolean \| Hash | `false` | Enable Table toolbar button and table-keyboard shortcuts. |
| `collaboration` | Boolean \| Hash | `false` | Enable Collaboration extension (requires `:full` preset). Pass Hash for provider config. |
| `drag_handle` | Boolean | `false` | Enable drag-handle for block reordering (`:full` preset). |
| `addons` | Array | `[]` | Opt into host-registered TipTap addons. Entries may be addon names or `{ name:, options: }` hashes. |
| `extensions` | Hash | `{}` | Reserved for FlatPack-managed extension overrides. It does not load arbitrary host addons. |
| `ui` | Hash | `{}` | Reserved for future UI customisation options. |
| `placeholder` | String | `nil` | Placeholder text shown when the editor is empty (overrides the top-level `placeholder:` prop). |

### Presets

| Preset | Included extensions |
| --- | --- |
| `:minimal` | StarterKit, Placeholder, CharacterCount, Link, Underline, TextAlign, BubbleMenu/FloatingMenu (optional) |
| `:content` | All of `:minimal` + Highlight, TextStyle, Color, Typography, Image, CodeBlockLowlight, TaskList, TaskItem, Table (+Row/Cell/Header) |
| `:full` | All of `:content` + Subscript, Superscript, FontFamily, Mention, YouTube, Audio, Details, TrailingNode, UniqueID, Focus, ListKeymap, Collaboration+Cursor, DragHandle, Mathematics, Emoji, InvisibleCharacters, TableOfContents |

### Custom addons

FlatPack now supports host-registered TipTap addons without forking the gem. The integration is split in two parts:

- Ruby opts into addons by name via `rich_text_options[:addons]`.
- JavaScript registers how those addons load extensions and optional toolbar or bubble-menu tools.

When an addon is requested but not registered, FlatPack logs a warning and still boots the editor with the selected built-in preset.

Use this flow when you want to bring in a compatible TipTap extension from the official extensions overview:

- Pick a TipTap extension from <https://tiptap.dev/docs/editor/extensions/overview>.
- Install or pin the package in your host app.
- Register the extension with `registerTiptapAddon(...)` in host-app JavaScript.
- Opt into it from `rich_text_options[:addons]`.
- If the addon needs UI, either reuse an existing FlatPack toolbar tool or register addon-specific tools.

#### 1. Register the addon in app JavaScript

```js
import { registerTiptapAddon } from "flat_pack/tiptap/addon_registry"
import { Image } from "@tiptap/extension-image"

registerTiptapAddon("tiptap-image", {
  extensions: ({ addonOptions }) => [
    Image.configure({
      inline: false,
      allowBase64: false,
      ...addonOptions,
    })
  ]
})
```

If you use Importmap, pin any third-party TipTap package in your app's `config/importmap.rb`. If you use npm, install the package into your app bundle as usual.

#### 2. Opt into the addon from Ruby

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "article[body]",
  rich_text: true,
  rich_text_options: {
    preset: :minimal,
    addons: [
      { name: :tiptap_image, options: { inline: false } }
    ],
    toolbar: ["bold", "italic", "image", "undo", "redo"]
  }
) %>
```

Custom toolbar arrays may include registered addon tool names. They may also reuse existing FlatPack tools that depend on an addon-provided extension, like the built-in `image` toolbar button shown above. Addon bubble-menu tools are appended automatically when the addon is active and `bubble_menu: true`.

#### Where this code lives

FlatPack owns the extension mechanism:

- See `app/javascript/flat_pack/tiptap/addon_registry.js`

The host app owns the actual addon registration:

- In this repo, the host app is the dummy app, so the example lives in `test/dummy/app/javascript/tiptap_demo_addons.js`

The host app also has to import that registration file:

- See `test/dummy/app/javascript/application.js`

And if the host app uses Importmap, it has to pin anything it imports:

- See `test/dummy/config/importmap.rb`

So in a real consumer Rails app, the equivalent would be:

1. Add a JS file in the app, such as `app/javascript/tiptap_addons.js`.
2. Import `Image` from `@tiptap/extension-image` there.
3. Import `registerTiptapAddon` from FlatPack there.
4. Register the addon there.
5. Import that file from the app's JS entrypoint.
6. Pin the file and the TipTap package in the app's importmap if using Importmap.

#### Upgrading from older FlatPack versions

If your app already uses FlatPack and you are upgrading to pick up the newer TipTap addon support, rerun the install generator and verifier in the host app:

```bash
bin/rails generate flat_pack:install
bin/rake flat_pack:contract
bin/rake flat_pack:verify_install
```

That makes sure your app has the latest FlatPack importmap and rich-text wiring before you start adding app-owned TipTap addons.

#### Example: adding TipTap Image to the minimal preset

FlatPack already includes the Image extension in the `:content` preset, so you do not need an addon if `preset: :content` already fits your use case. The addon route is useful when you want to bring `Image` into a smaller preset such as `:minimal`, or when you want host-app ownership of the exact extension config.

### Example — Minimal editor

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "comment[body]",
  label: "Comment",
  placeholder: "Write your comment…",
  rich_text: true,
  rich_text_options: {
    preset: :minimal,
    toolbar: :minimal
  }
) %>
```

### Example — Content editor with character count

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "post[body]",
  label: "Post Body",
  required: true,
  rich_text: true,
  rich_text_options: {
    preset: :content,
    toolbar: :standard,
    character_count: true
  }
) %>
```

### Example — HTML output mode

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "page[content]",
  label: "Page Content",
  rich_text: true,
  rich_text_options: {
    format: :html,
    preset: :content
  }
) %>
```

### Example — Bubble menu only (no toolbar)

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "note[body]",
  label: "Note",
  rich_text: true,
  rich_text_options: {
    toolbar: :none,
    bubble_menu: true
  }
) %>
```

### Example — Comments composer with standard toolbar

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

## Image Upload

The `image` toolbar button normally shows a URL-input popover. When you supply `uploads: { url: "..." }`, the popover gains a second section with a `<input type="file">` that uploads directly to your endpoint and inserts the returned URL into the editor.

### Rails / ActiveStorage setup

**1. Install ActiveStorage** (skip if already installed):

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

**2. Configure a storage service** in `config/environments/development.rb`:

```ruby
config.active_storage.service = :local
```

And in `config/storage.yml` (generated by Rails, verify it exists):

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

**3. Create an upload controller**:

```ruby
# app/controllers/rich_text_images_controller.rb
class RichTextImagesController < ApplicationController
  ALLOWED_TYPES = %w[image/jpeg image/png image/gif image/webp image/svg+xml].freeze
  MAX_SIZE      = 10.megabytes

  def create
    file = params[:file]

    return render json: { error: "No file" }, status: :bad_request unless
      file.is_a?(ActionDispatch::Http::UploadedFile)
    return render json: { error: "Type not allowed" }, status: :unprocessable_entity unless
      ALLOWED_TYPES.include?(file.content_type)
    return render json: { error: "Too large (max 10 MB)" }, status: :unprocessable_entity if
      file.size > MAX_SIZE

    service_name = Rails.application.config.active_storage.service || :local
    blob = ActiveStorage::Blob.create_and_upload!(
      io:           file,
      filename:     file.original_filename,
      content_type: file.content_type,
      service_name: service_name
    )

    render json: { url: url_for(blob) }, status: :created
  end
end
```

> **Important:** `url_for(blob)` produces a signed URL that works with the default Disk service. In production, swap the service for S3/GCS/Azure in `storage.yml` and set `config.active_storage.service = :amazon` (etc.) — no controller changes needed.

**4. Add the route**:

```ruby
# config/routes.rb
post "rich_text/upload_image", to: "rich_text_images#create", as: :rich_text_upload_image
```

**5. Mount ActiveStorage routes** (Rails includes this automatically when you use `active_storage:install`, but confirm `config/routes.rb` is not excluding it):

```ruby
# This is added automatically by Rails — no manual step needed unless you use `draw :routes`
# direct :rails_blob_representation do ...
```

**6. Pass the URL to the component**:

```erb
<%= render FlatPack::TextArea::Component.new(
  name: "article[body]",
  label: "Body",
  rich_text: true,
  rich_text_options: {
    preset: :content,
    toolbar: %w[
      bold italic underline sep1
      h1 h2 h3 sep2
      bulletList orderedList sep3
      blockquote link image sep4
      undo redo
    ],
    bubble_menu: true,
    format: :html,
    uploads: { url: rich_text_upload_image_url }
  }
) %>
```

The `image` tool must be present in the custom toolbar array (or use `toolbar: :full`). The `:content` preset already loads the TipTap `Image` extension; no extra preset change is needed.

### How the popover works

When `uploads.url` is set the image popover renders two sections:

```
┌─────────────────────────────────┐
│ [ Image URL input ] [ Insert ]  │  ← paste any URL
│ ─── or upload a file ───        │
│ [ Choose file … ]               │  ← triggers upload, inserts on success
└─────────────────────────────────┘
```

- Selecting a file triggers an immediate `POST` with `Content-Type: multipart/form-data` and the `X-CSRF-Token` header.
- On a `201` response the editor receives `{ url }` and calls `editor.setImage({ src: url })`.
- On error, a message is shown inline in the popover without disrupting the editor.

### Sanitizing stored HTML

Always sanitize HTML output before rendering it back to users:

```erb
<%# In your show view: %>
<div class="prose">
  <%= FlatPack::RichTextSanitizer.sanitize(@article.body).html_safe %>
</div>
```

`FlatPack::RichTextSanitizer` strips all tags and attributes not on its allowlist. `<img src="...">` tags rendered by TipTap are preserved.

## Accessibility
- Label-to-control association is provided when `label` is passed (`for`/`id` linkage).
- Error state adds `aria-invalid` and `aria-describedby` for controls that receive `error`.
- Native controls are used for checkbox/radio/select/input/textarea semantics.
- `SearchInput` keeps a single clear control by using the component clear button and suppressing browser-native search clear icons.
- Searchable select trigger exposes `aria-haspopup` and toggles `aria-expanded`.
- `flat-pack--nested-multiselect` uses native checkbox semantics and applies the browser indeterminate state to partially selected parents.
- `Switch` renders a checkbox input and switch track with `role="switch"` and `aria-checked`.

## Dependencies
- Core install: `rails generate flat_pack:install`
- Stimulus controllers used by input components:
  - `flat-pack--password-input` (`PasswordInput`)
  - `flat-pack--search-input` (`SearchInput`)
  - `flat-pack--text-area` (`TextArea` plain mode)
  - `flat-pack--tiptap` (`TextArea` when `rich_text: true`)
  - `flat-pack--select` (`Select` when `searchable: true`)
  - `flat-pack--nested-multiselect` (hierarchical checkbox groups)
  - `flat-pack--date-input` (`DateInput`)
  - `flat-pack--file-input` (`FileInput`)
- Related component dependency:
  - `flat-pack--range-input` (`RangeInput`; documented in `docs/components/range-input.md`)
