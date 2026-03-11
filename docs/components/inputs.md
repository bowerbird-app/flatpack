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
| `rich_text` | Boolean | `false` | no | Enables the built-in TipTap editor path on `TextArea` while keeping the same component API. |
| `rich_text_options` | Hash | `{}` | no | Validated Ruby-side TipTap configuration for presets, format, toolbar, extensions, Bubble Menu, and rich text behavior. |
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
<%= render FlatPack::TextArea::Component.new(
  name: "post[body]",
  label: "Body",
  rich_text: true,
  rich_text_options: {
    preset: :content,
    format: :json,
    toolbar: :standard,
    bubble_menu: true
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
- Rich `TextArea` mode renders a keyboard-focusable editor surface with `role="textbox"`, label/error wiring, toolbar buttons, and optional Bubble Menu / Floating Menu regions.
- `SearchInput` keeps a single clear control by using the component clear button and suppressing browser-native search clear icons.
- Searchable select trigger exposes `aria-haspopup` and toggles `aria-expanded`.
- `Switch` renders a checkbox input and switch track with `role="switch"` and `aria-checked`.

## Rich Text (`TextArea`)

`FlatPack::TextArea::Component` is the public entrypoint for both native textarea and rich text editing:

- `rich_text: false` keeps the current native `<textarea>` behavior.
- `rich_text: true` renders a TipTap-backed editor surface plus a synchronized hidden form field.
- FlatPack uses a TipTap UI-focused integration layer for menus and controls, themed to match FlatPack tokens.
- The hidden field keeps normal Rails form submission semantics through the component `name`.

Recommended storage format:

- Prefer `format: :json` for persistence. TipTap JSON is FlatPack’s canonical internal rich text model.
- `format: :html` is available when you need HTML submission/export, but you should sanitize stored/rendered HTML in your application.

Supported top-level `rich_text_options` keys:

| key | accepts | default | notes |
| --- | --- | --- | --- |
| `format` | `:json`, `:html` | `:json` | JSON is recommended for persisted storage. |
| `preset` | `:minimal`, `:content`, `:full` | `:minimal` | Presets enable groups of open-source TipTap extensions. |
| `bubble_menu` | `true`, `false` | `true` | Included by default in the rich text experience. |
| `floating_menu` | `true`, `false` | `false` | Optional block-level contextual menu. |
| `placeholder` | String | component `placeholder` | Rich text placeholder text. |
| `toolbar` | `:minimal`, `:standard`, `:full`, Array | `:minimal` | Array values must use supported toolbar item identifiers. |
| `extensions` | Hash | preset-derived | Per-extension boolean/config overrides after preset expansion. |
| `mentions` | `false`, Hash | `nil` | Mention trigger + suggestions config. |
| `uploads` | `false`, Hash | `nil` | Upload/file handling config for the built-in FileHandler hook. |
| `tables` | `false`, Hash | `nil` | TableKit/Table config such as resizable columns. |
| `collaboration` | `false`, Hash | `nil` | Collaboration runtime hook names (provider/document live at app level). |
| `character_count` | `true`, `false` | inherits component prop | Rich text mode uses TipTap character counting, not textarea length logic. |
| `readonly` | `true`, `false` | `false` | Readonly rich editor surface. |
| `autofocus` | `true`, `false` | `false` | Focus editor on connect. |
| `output_input_type` | `:hidden_input`, `:hidden_textarea` | `:hidden_input` | Real field used for submission. |
| `sanitization_profile` | `:flatpack`, `:relaxed`, `:none` | `:flatpack` | Applied to initial HTML-mode content before editor boot. |
| `ui` | Hash | themed defaults | TipTap UI presentation settings for FlatPack’s vanilla bridge layer. |

Supported `ui` keys:

- `theme` — currently `:flatpack`
- `mode` — currently `:adaptive` (prefer TipTap UI primitives/menus where applicable, bridge where upstream React-only UI is not available to vanilla Stimulus)
- `density` — `:comfortable` or `:compact`
- `toolbar_label`, `bubble_menu_label`, `floating_menu_label` — accessible labels for the themed TipTap UI regions

Preset guidance:

- `:minimal` — StarterKit, Placeholder, Bubble Menu, Character Count, Link, Underline, Text Align.
- `:content` — `:minimal` plus Highlight, Text Style, Color, Background Color, Typography, ListKit, TableKit, Image, Code Block, Code Block Lowlight.
- `:full` — `:content` plus Font Family, Font Size, Line Height, Mention, Mathematics, Emoji, Audio, YouTube, Twitch, Details, Table of Contents, collaboration hooks, the generic Drag Handle extension, Invisible Characters, Unique ID, Floating Menu, and other advanced editing extensions represented in the built-in registry.

Bubble Menu notes:

- Bubble Menu is part of the default rich text story and uses TipTap’s own menu extension behavior instead of FlatPack’s generic popover controller.
- It exposes common inline formatting actions and is selection-aware.

Extension strategy:

- FlatPack validates and normalizes `rich_text_options` in Ruby before serializing config to the frontend.
- All open-source TipTap extensions in the built-in registry are shipped through the normal install path, but presets keep the default editor smaller than “enable everything”.
- FlatPack’s TipTap UI layer is themed for Rails/ViewComponent usage. Official upstream TipTap UI packages are React/CLI-first, so the vanilla Stimulus integration uses a small FlatPack bridge around TipTap’s menu/editor primitives where upstream prebuilt UI components are not directly applicable.
- Relative URLs for links/images can be used for app-managed same-origin assets, but your backend should still validate upload endpoints and sanitize/render stored rich content defensively.
- Framework-specific wrappers such as `Drag Handle React` and `Drag Handle Vue` are documented as upstream TipTap wrappers and are not applicable to FlatPack’s Stimulus integration.

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
- Built-in rich text install pins:
  - `@tiptap/core`
  - `@tiptap/starter-kit`
  - `@tiptap/extensions`
  - `lowlight`
  - `yjs`
- Related component dependency:
  - `flat-pack--range-input` (`RangeInput`; documented in `docs/components/range-input.md`)
