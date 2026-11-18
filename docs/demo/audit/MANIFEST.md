# Form control visual audit

Stills from the FlatPack dummy after PR #211 (`v0.1.183`, rich-text TextArea border and `--form-control-padding`).

Captured from the running dummy at `/demo/forms/...` with headless Chrome element screenshots. Type can look odd (extra letters) because of the headless face; use these for **chrome** (border, radius, inset, adjacent controls).

Each PNG has a matching `.b64` companion (`<file>.png.b64`) for fetch paths that cannot take binaries.

| File | Control | Dummy route | What it shows |
| --- | --- | --- | --- |
| `01-textarea-plain-release-notes.png` | `FlatPack::TextArea` plain | `/demo/forms/text_area` | Native `#release_notes` control only (“Release Notes (quick copy)”). |
| `01-textarea-plain-release-notes-field.png` | `FlatPack::TextArea` plain | `/demo/forms/text_area` | Same field with label, help, and copy button. |
| `02-textarea-rich-minimal-comment.png` | `FlatPack::TextArea` `rich_text` `:minimal` | `/demo/forms/text_area#minimal-preset` | Comment editor after the border/padding fix (toolbar + bordered surface). |
| `03-textarea-rich-content-post-body.png` | `FlatPack::TextArea` `rich_text` `:content` / standard toolbar | `/demo/forms/text_area` | Post Body editor, same field chrome as the minimal surface. |
| `04-text-input-username.png` | `FlatPack::TextInput` | `/demo/forms/text_input` | Username required field (label, input, help). |
| `05-select-country.png` | `FlatPack::Select` | `/demo/forms/select` | Country native select (label, trigger, help). |
| `06-checkbox-terms.png` | `FlatPack::Checkbox` | `/demo/forms/checkbox` | Terms checkbox with label and help. |
