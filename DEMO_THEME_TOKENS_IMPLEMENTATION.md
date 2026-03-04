# Demo Theme Tokens Implementation Summary

## Overview

This document explains how per-page token reference tables are wired into the FlatPack dummy app demo pages (for example `/demo/buttons`, `/demo/popovers`, `/demo/forms/*`).

The setup is designed so token value changes in the central theme source are automatically reflected across mapped demo pages.

## What Was Implemented

### 1. Automatic per-page token reference
- ✅ A shared token table section is rendered on demo pages when matching tokens exist.
- ✅ The section appears below page content in the main dummy layout.
- ✅ Existing token table rendering is reused for consistent formatting.

### 2. Controller-driven token mapping

In `PagesController`, a mapping constant is used to connect page actions to token families:

- `DEMO_THEME_TOKEN_MAPPINGS`
  - Matches action names (for example `buttons`, `tabs_pills`, `chat_demo`)
  - Defines token patterns (for example `--button-*`, `--tabs-*`, `--chat-*`)
  - Defines display title used in the section subtitle

A `before_action` applies this automatically:

- `before_action :load_demo_theme_tokens`

### 3. Token extraction source of truth

Token rows are extracted directly from:

- `app/assets/stylesheets/flat_pack/variables.css`
- Inside the `@theme { ... }` block

Extraction behavior:
- Reads variables matching `--token-name: value;`
- Builds rows with:
  - `variable`
  - `default_value`

### 4. Shared rendering partial

A reusable partial renders the section shell:

- `test/dummy/app/views/pages/_theme_token_reference.html.erb`

It reuses the existing table partial:

- `test/dummy/app/views/themes/_token_table.html.erb`

## File Changes

### Modified
1. `test/dummy/app/controllers/pages_controller.rb`
   - Added `DEMO_THEME_TOKEN_MAPPINGS`
   - Added `before_action :load_demo_theme_tokens`
   - Added `load_demo_theme_tokens`
   - Added `extract_theme_tokens`

2. `test/dummy/app/views/layouts/application.html.erb`
   - Added conditional render of token reference section when `@demo_theme_token_rows` is present

### Added
1. `test/dummy/app/views/pages/_theme_token_reference.html.erb`
   - Shared section wrapper for per-page token references

## Sync Behavior

### What syncs automatically
- Updating token **values** in `variables.css` automatically updates table values on all mapped demo pages.
- Adding/removing token names under an already-mapped prefix (for example `--button-*`) automatically updates those pages.

### What requires manual mapping updates
- Adding a **new token prefix/family** (for example `--carousel-*`) requires adding a matching pattern in `DEMO_THEME_TOKEN_MAPPINGS`.
- Adding a **new demo action/page** requires adding an action matcher to the mapping if that page should show token references.

## Maintenance Guide

When token system changes:

1. Update tokens in `app/assets/stylesheets/flat_pack/variables.css`
2. If needed, update mapping entries in `test/dummy/app/controllers/pages_controller.rb`
3. Verify a few demo pages, for example:
   - `/demo/buttons`
   - `/demo/forms/text_input`
   - `/demo/chat/demo`
4. Confirm the “Theme Tokens” section appears and token rows are correct

## Example Mapping Entry

```ruby
{ action: /\Abuttons\z/, title: "Buttons", patterns: [/\A--button-/] }
```

Meaning:
- Action `buttons` page gets a token section
- Title label is “Buttons”
- Rows include tokens whose variable starts with `--button-`

## Design Notes

- Controller-based mapping keeps page templates clean.
- Shared partial keeps section UX consistent.
- Reusing the existing token table avoids duplicate rendering logic.
- This is additive and does not change existing component demos.

## Quick Troubleshooting

If token section does not show on a page:
1. Confirm the page action matches an entry in `DEMO_THEME_TOKEN_MAPPINGS`
2. Confirm matching tokens exist in `@theme` in `variables.css`
3. Confirm page is rendered through the standard dummy layout

## Summary

This implementation provides a centralized, maintainable way to expose component token references directly on each relevant demo page, while keeping token definitions in one source (`variables.css`) and keeping rendering consistent with existing FlatPack table patterns.
