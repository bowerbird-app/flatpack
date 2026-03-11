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
| `rows` | Integer | `3` | no | Initial row count (`TextArea` only). |
| `character_count` | Boolean | `false` | no | Enables live count text in `TextArea`. |
| `min_characters` | Integer | `nil` | no | Low threshold warning for `TextArea` count color. |
| `max_characters` | Integer | `nil` | no | High threshold and `current/max` format for `TextArea` count. |
| `rich_text` | Boolean | `false` | no | When true, `TextArea` renders a built-in TipTap editor shell and hidden submission field instead of a native textarea. |
| `rich_text_options` | Hash | `{}` | no | Validated TipTap configuration for `TextArea` rich text mode (format, preset, menus, toolbar, extensions, readonly, etc.). |
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
- `TextArea` rendering modes: native textarea (`rich_text: false`) and TipTap-backed rich text (`rich_text: true`)

### Rich `TextArea` option highlights

- Recommended storage format: `format: :json` (the default/canonical TipTap document form)
- Optional HTML submission/export: `format: :html`
- Presets:
  - `:minimal` → StarterKit, Placeholder, Bubble Menu, Character Count, Link, Underline, Text Align
  - `:content` → `:minimal` plus Highlight, Text Style, Color, Background Color, Typography, List/Table helpers, Image, Code Block support
  - `:full` → `:content` plus media, mentions, math, details, collaboration hooks, floating menu, identity/selection helpers
- Toolbar presets: `:minimal`, `:standard`, `:full`, or a custom array of command keys
- TipTap UI note: FlatPack themes TipTap interaction surfaces for Rails/ViewComponent usage. Framework-specific wrappers such as Drag Handle React/Vue are upstream open-source wrappers and are not runtime features of this importmap + Stimulus integration.

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
<%= render FlatPack::TextArea::Component.new(
  name: "post[body]",
  label: "Body",
  rich_text: true,
  rich_text_options: {
    preset: :content,
    toolbar: :standard,
    bubble_menu: true,
    format: :json
  }
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

## Accessibility
- Label-to-control association is provided when `label` is passed (`for`/`id` linkage).
- Error state adds `aria-invalid` and `aria-describedby` for controls that receive `error`.
- Native controls are used for checkbox/radio/select/input/textarea semantics.
- Rich `TextArea` mode uses a TipTap editor surface with a synchronized hidden input/textarea for Rails form submission.
- Rich `TextArea` Bubble Menu and toolbar controls remain keyboard reachable and inherit FlatPack error/required messaging.
- `SearchInput` keeps a single clear control by using the component clear button and suppressing browser-native search clear icons.
- Searchable select trigger exposes `aria-haspopup` and toggles `aria-expanded`.
- `Switch` renders a checkbox input and switch track with `role="switch"` and `aria-checked`.

## Dependencies
- Core install: `rails generate flat_pack:install`
- Stimulus controllers used by input components:
  - `flat-pack--password-input` (`PasswordInput`)
  - `flat-pack--search-input` (`SearchInput`)
  - `flat-pack--text-area` (`TextArea`)
  - `flat-pack--tiptap` (`TextArea` rich text mode)
  - `flat-pack--select` (`Select` when `searchable: true`)
  - `flat-pack--date-input` (`DateInput`)
  - `flat-pack--file-input` (`FileInput`)
- Related component dependency:
  - `flat-pack--range-input` (`RangeInput`; documented in `docs/components/range-input.md`)
