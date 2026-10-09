# Per-Page Theme Token References

This document explains how per-page token reference tables are wired into the FlatPack dummy app demo pages (for example `/demo/buttons`, `/demo/popovers`, `/demo/forms/*`).

Token value changes in the central theme source are automatically reflected on all mapped demo pages.

## How It Works

### Token Extraction

Tokens are extracted from:

```
app/assets/stylesheets/flat_pack/variables.css  →  :root, [data-theme] { … }
```

All `--token-name: value;` declarations inside the `:root, [data-theme]` block are read and built into rows with `variable` and `default_value` fields. `@theme inline` only lists the same names as `var(--token)` so Tailwind can emit utilities; dummy tables do not use that block for displayed values.

Named theme overrides live in slim `[data-theme="…"]` blocks (only tokens that differ from the default). `[data-theme="rounded"]` is empty. Component aliases that are pure `var(--semantic)` references are defined once on `:root, [data-theme]` and are not re-copied per named theme. That shared selector is what lets a host put `data-theme` on `<body>` and still have `--button-primary-*` / `--color-ring` follow `--color-primary`. Overlay dimming is `--overlay-backdrop-color`; on-media chrome is `--overlay-scrim-color`. Hover follows `--color-primary` via relative colour syntax.

### Controller Mapping

`PagesController` defines a `DEMO_THEME_TOKEN_MAPPINGS` constant that connects page action names to token families:

```ruby
{ action: /\Abuttons\z/, title: "Buttons", patterns: [/\A--button-/] }
```

A `before_action :load_demo_theme_tokens` applies the mapping automatically — no per-page template changes needed.

### Rendering

A shared partial renders the token table section when `@demo_theme_token_rows` is present:

- **Section wrapper**: `test/dummy/app/views/pages/_theme_token_reference.html.erb`
- **Table partial**: `test/dummy/app/views/themes/_token_table.html.erb` (reused from existing theme tooling)
- **Layout hook**: `test/dummy/app/views/layouts/application.html.erb` conditionally renders the section below page content.

## What Syncs Automatically

- Updating token **values** in `variables.css` updates the displayed values on all mapped pages immediately.
- Adding or removing token names under an already-mapped prefix (e.g. `--button-*`) automatically updates those pages.

## What Requires Manual Updates

- Adding a **new token family** (e.g. `--range-*`) requires a new entry in `DEMO_THEME_TOKEN_MAPPINGS`.
- Adding a **new demo page** that should show token references requires a matching action pattern in the mapping.

## Adding a New Mapping Entry

Open `test/dummy/app/controllers/pages_controller.rb` and add to `DEMO_THEME_TOKEN_MAPPINGS`:

```ruby
{ action: /\Amycomponent\z/, title: "My Component", patterns: [/\A--mycomponent-/] }
```

- `action` — regex matched against the controller action name
- `title` — label shown in the section subtitle
- `patterns` — array of regexes matched against token variable names

## Source Files

| File | Role |
|------|------|
| `app/assets/stylesheets/flat_pack/variables.css` | Single source of truth for all token definitions |
| `test/dummy/app/controllers/pages_controller.rb` | `DEMO_THEME_TOKEN_MAPPINGS`, `load_demo_theme_tokens`, `extract_theme_tokens` |
| `test/dummy/app/views/pages/_theme_token_reference.html.erb` | Shared section wrapper partial |
| `test/dummy/app/views/themes/_token_table.html.erb` | Reusable token table partial |
| `test/dummy/app/views/layouts/application.html.erb` | Conditional render of token section |

## Troubleshooting

If the token section does not appear on a demo page:

1. Confirm the page action name matches an entry in `DEMO_THEME_TOKEN_MAPPINGS`.
2. Confirm matching tokens exist inside `:root, [data-theme] { … }` in `variables.css`.
3. Confirm the page is rendered through the standard dummy app layout.
