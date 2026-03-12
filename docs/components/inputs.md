# Input Components

## Purpose
Provide a consistent set of text, choice, and file form inputs with shared validation styling and accessible labeling patterns.

## When to use
Use these components when you need FlatPack-styled form controls with consistent error handling, required/disabled states, and optional interactive behaviors.

## Class
- Primary: `FlatPack::TextInput::Component`
- Related classes: `FlatPack::PasswordInput::Component`, `FlatPack::EmailInput::Component`, `FlatPack::PhoneInput::Component`, `FlatPack::SearchInput::Component`, `FlatPack::TextArea::Component`, `FlatPack::UrlInput::Component`, `FlatPack::NumberInput::Component`, `FlatPack::DateInput::Component`, `FlatPack::FileInput::Component`, `FlatPack::Checkbox::Component`, `FlatPack::RadioGroup::Component`, `FlatPack::Select::Component`, `FlatPack::Switch::Component`
- Related docs: [Range Input](range-input.md) (`FlatPack::RangeInput::Component`)

## Props
Common props used across most input components:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `name` | String | none | yes | Field name submitted with the form. |
| `value` | String, Numeric, Date, Time, DateTime | `nil` | no | Current value. Supported value types vary by component. |
| `placeholder` | String | `nil` | no | Placeholder text for text-like inputs. |
| `label` | String | `nil` | no | Visible label text. |
| `error` | String | `nil` | no | Error message; enables invalid styling and `aria-describedby`. |
| `disabled` | Boolean | `false` | no | Disables interaction and submission for the control. |
| `required` | Boolean | `false` | no | Marks the control as required. |
| `**system_arguments` | Hash | `{}` | no | Standard HTML attributes (`id`, `class`, `data`, `aria`, etc.). |

Component-specific props:

| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `rows` | Integer | `3` | no | Initial row count (`TextArea` plain mode only; ignored when `rich_text: true`). |
| `character_count` | Boolean | `false` | no | Enables live count text in `TextArea` (both plain and rich text modes). |
| `rich_text` | Boolean | `false` | no | Activates the TipTap rich text editor in place of the native `<textarea>`. |
| `rich_text_options` | Hash | `{}` | no | Fine-grained config for the rich text editor; see [Rich Text Options](#rich-text-options) below. |
| `min_characters` | Integer | `nil` | no | Low threshold warning for `TextArea` count color. |
| `max_characters` | Integer | `nil` | no | High threshold and `current/max` format for `TextArea` count. |
| `min` | Numeric or date-like | `nil` (`NumberInput`), `0` (`RangeInput`) | no | Minimum value/date (`NumberInput`, `DateInput`, `RangeInput`). |
| `max` | Numeric or date-like | `nil` (`NumberInput`), `100` (`RangeInput`) | no | Maximum value/date (`NumberInput`, `DateInput`, `RangeInput`). |
| `step` | Numeric | `1` | no | Step increment (`NumberInput`, `RangeInput`). |
| `accept` | String | `nil` | no | File MIME/extensions whitelist for `FileInput`. Dangerous executable extensions raise `ArgumentError`. |
| `multiple` | Boolean | `false` | no | Enables multiple file selection (`FileInput`). |
| `max_size` | Integer | `nil` | no | Max file size in bytes for `FileInput` client-side checks. Must be positive when provided. |
| `preview` | Boolean | `true` | no | Enables image preview area in `FileInput`. |
| `checked` | Boolean | `false` | no | Initial checked state (`Checkbox`, `Switch`). |
| `options` | Array | none | yes (`RadioGroup`, `Select`) | Options list. Supports `String`, `[label, value]`, or `{ label:, value:, disabled: }`. |
| `searchable` | Boolean | `false` | no | Uses custom searchable dropdown mode for `Select`. |
| `size` | Symbol | `:md` | no | Switch size: `:sm`, `:md`, `:lg` (`Switch`). |

## Slots
None.

## Variants
- Input classes by type: `TextInput`, `PasswordInput`, `EmailInput`, `PhoneInput`, `SearchInput`, `TextArea`, `UrlInput`, `NumberInput`, `DateInput`, `FileInput`
- Choice inputs: `Checkbox`, `RadioGroup`, `Select`, `Switch`
- Select rendering modes: native select (`searchable: false`) and custom searchable select (`searchable: true`)

## Example
```erb
<%= render FlatPack::TextInput::Component.new(
  name: "user[email]",
  label: "Email",
  placeholder: "you@example.com",
  required: true
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
<%= render FlatPack::Select::Component.new(
  name: "user[country]",
  label: "Country",
  options: [["United States", "US"], ["Canada", "CA"]],
  searchable: true,
  placeholder: "Search..."
) %>
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

## Rich Text Mode

When `rich_text: true` is set on `FlatPack::TextArea::Component`, the native `<textarea>` is replaced with a fully featured [TipTap](https://tiptap.dev) editor. The editor is rendered server-side as empty containers and bootstrapped by the `flat-pack--tiptap` Stimulus controller at runtime.

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
| `toolbar` | Symbol \| Array | `:standard` | Toolbar preset (`:minimal`, `:standard`, `:full`, `:none`) or an Array of tool names. |
| `bubble_menu` | Boolean | `true` | Show TipTap BubbleMenu on text selection. |
| `floating_menu` | Boolean | `false` | Show TipTap FloatingMenu at the start of an empty line. |
| `character_count` | Boolean | `false` | Display live character count below the editor. |
| `readonly` | Boolean | `false` | Put the editor in read-only mode. |
| `mentions` | Boolean \| Hash | `false` | Enable `@mention` support. Pass a Hash to supply `suggestion:` config. |
| `collaboration` | Boolean \| Hash | `false` | Enable Collaboration extension (requires `:full` preset). Pass Hash for provider config. |
| `drag_handle` | Boolean | `false` | Enable drag-handle for block reordering (`:full` preset). |
| `extensions` | Hash | `{}` | Pass-through config forwarded to individual TipTap extensions. |
| `ui` | Hash | `{}` | Reserved for future UI customisation options. |
| `placeholder` | String | `nil` | Placeholder text shown when the editor is empty (overrides the top-level `placeholder:` prop). |

### Presets

| Preset | Included extensions |
| --- | --- |
| `:minimal` | StarterKit, Placeholder, CharacterCount, Link, Underline, TextAlign, BubbleMenu/FloatingMenu (optional) |
| `:content` | All of `:minimal` + Highlight, TextStyle, Color, Typography, Image, CodeBlockLowlight, TaskList, TaskItem, Table (+Row/Cell/Header) |
| `:full` | All of `:content` + Subscript, Superscript, FontFamily, Mention, YouTube, Audio, Details, TrailingNode, UniqueID, Focus, ListKeymap, Collaboration+Cursor, DragHandle, Mathematics, Emoji, InvisibleCharacters, TableOfContents |

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

## Accessibility
- Label-to-control association is provided when `label` is passed (`for`/`id` linkage).
- Error state adds `aria-invalid` and `aria-describedby` for controls that receive `error`.
- Native controls are used for checkbox/radio/select/input/textarea semantics.
- `SearchInput` keeps a single clear control by using the component clear button and suppressing browser-native search clear icons.
- Searchable select trigger exposes `aria-haspopup` and toggles `aria-expanded`.
- `Switch` renders a checkbox input and switch track with `role="switch"` and `aria-checked`.

## Dependencies
- Core install: `rails generate flat_pack:install`
- Stimulus controllers used by input components:
  - `flat-pack--password-input` (`PasswordInput`)
  - `flat-pack--search-input` (`SearchInput`)
  - `flat-pack--text-area` (`TextArea` plain mode)
  - `flat-pack--tiptap` (`TextArea` when `rich_text: true`)
  - `flat-pack--select` (`Select` when `searchable: true`)
  - `flat-pack--date-input` (`DateInput`)
  - `flat-pack--file-input` (`FileInput`)
- Related component dependency:
  - `flat-pack--range-input` (`RangeInput`; documented in `docs/components/range-input.md`)
