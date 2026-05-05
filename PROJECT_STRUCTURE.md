# FlatPack Project Structure

This document summarizes the current FlatPack repository layout and the files that matter most when you are installing, extending, or verifying the engine.

## Project Overview

**FlatPack** is a Rails engine that ships ViewComponent-based UI components, Tailwind CSS 4 token styling, Propshaft-served assets, and importmap-friendly JavaScript.

**Version:** 0.1.39  
**License:** MIT  
**Ruby:** 3.2+  
**Supported host apps:** Rails 7.1+  
**Last Updated:** 2026-05-05

## Repository Layout

```text
flat_pack/
├── app/
│   ├── assets/stylesheets/flat_pack/
│   │   ├── application.css
│   │   ├── content_editor.css
│   │   ├── rich_text.css
│   │   └── variables.css
│   ├── components/flat_pack/
│   │   ├── accordion/
│   │   ├── alert/
│   │   ├── avatar/
│   │   ├── avatar_group/
│   │   ├── badge/
│   │   ├── bottom_nav/
│   │   ├── breadcrumb/
│   │   ├── button/
│   │   ├── button_group/
│   │   ├── card/
│   │   ├── carousel/
│   │   ├── chart/
│   │   ├── chat/
│   │   ├── checkbox/
│   │   ├── chip/
│   │   ├── chip_group/
│   │   ├── code_block/
│   │   ├── collapse/
│   │   ├── comments/
│   │   ├── content_editor/
│   │   ├── date_input/
│   │   ├── email_input/
│   │   ├── empty_state/
│   │   ├── file_input/
│   │   ├── grid/
│   │   ├── hero/
│   │   ├── link/
│   │   ├── list/
│   │   ├── modal/
│   │   ├── navbar/
│   │   ├── number_input/
│   │   ├── page_header/
│   │   ├── page_title/
│   │   ├── pagination/
│   │   ├── pagination_infinite/
│   │   ├── password_input/
│   │   ├── phone_input/
│   │   ├── picker/
│   │   ├── popover/
│   │   ├── progress/
│   │   ├── quote/
│   │   ├── radio_group/
│   │   ├── range_input/
│   │   ├── search/
│   │   ├── search_input/
│   │   ├── section_title/
│   │   ├── segmented_buttons/
│   │   ├── select/
│   │   ├── shared/
│   │   ├── sidebar/
│   │   ├── sidebar_layout/
│   │   ├── skeleton/
│   │   ├── switch/
│   │   ├── table/
│   │   ├── tabs/
│   │   ├── text_area/
│   │   ├── text_input/
│   │   ├── timeline/
│   │   ├── toast/
│   │   ├── toasts/
│   │   ├── tooltip/
│   │   ├── top_nav/
│   │   ├── url_input/
│   │   ├── INPUT_COMPONENTS.md
│   │   └── base_component.rb
│   └── javascript/flat_pack/
│       ├── controllers/
│       │   ├── accordion_controller.js
│       │   ├── alert_controller.js
│       │   ├── badge_controller.js
│       │   ├── button_dropdown_controller.js
│       │   ├── carousel_controller.js
│       │   ├── chart_controller.js
│       │   ├── chat_grouping_controller.js
│       │   ├── chat_image_deck_controller.js
│       │   ├── chat_message_actions_controller.js
│       │   ├── chat_scroll_controller.js
│       │   ├── chat_sender_controller.js
│       │   ├── chip_controller.js
│       │   ├── chip_tag_input_controller.js
│       │   ├── code_block_tabs_controller.js
│       │   ├── collapse_controller.js
│       │   ├── content_editor_controller.js
│       │   ├── date_input_controller.js
│       │   ├── file_input_controller.js
│       │   ├── form_validation_controller.js
│       │   ├── grid_sortable_controller.js
│       │   ├── icon_controller.js
│       │   ├── list_selectable_controller.js
│       │   ├── modal_controller.js
│       │   ├── navbar_controller.js
│       │   ├── pagination_infinite_controller.js
│       │   ├── password_input_controller.js
│       │   ├── picker_controller.js
│       │   ├── popover_controller.js
│       │   ├── range_input_controller.js
│       │   ├── range_input_demo_controller.js
│       │   ├── range_input_double_demo_controller.js
│       │   ├── search_controller.js
│       │   ├── search_input_controller.js
│       │   ├── section_title_anchor_controller.js
│       │   ├── select_controller.js
│       │   ├── sidebar_controller.js
│       │   ├── sidebar_group_controller.js
│       │   ├── sidebar_layout_controller.js
│       │   ├── table_controller.js
│       │   ├── table_sortable_controller.js
│       │   ├── tabs_controller.js
│       │   ├── text_area_controller.js
│       │   ├── theme_controller.js
│       │   ├── tiptap_controller.js
│       │   ├── toast_controller.js
│       │   ├── toasts_region_controller.js
│       │   └── tooltip_controller.js
│       ├── heroicons.js
│       └── tiptap/
├── config/
│   ├── importmap.rb
│   └── routes.rb
├── docs/
│   ├── README.md
│   ├── ai/
│   │   ├── README.md
│   │   └── install_contract.json
│   ├── architecture/
│   │   ├── assets.md
│   │   ├── engine.md
│   │   ├── tailwind_4.md
│   │   └── theme-tokens.md
│   ├── components/
│   │   ├── DOC_FORMAT.md
│   │   ├── README.md
│   │   ├── manifest.yml
│   │   └── *.md
│   ├── dark_mode.md
│   ├── installation.md
│   ├── security.md
│   └── theming.md
├── lib/
│   ├── flat_pack.rb
│   ├── flat_pack/
│   │   ├── attribute_sanitizer.rb
│   │   ├── engine.rb
│   │   ├── install_contract.rb
│   │   ├── install_verifier.rb
│   │   ├── rich_text_sanitizer.rb
│   │   └── version.rb
│   ├── generators/flat_pack/
│   └── tasks/flat_pack_tasks.rake
├── test/
│   ├── components/
│   ├── dummy/
│   ├── dummy-rails-7/
│   ├── generators/
│   ├── javascript/
│   ├── lib/
│   ├── support/
│   └── test_helper.rb
├── CHANGELOG.md
├── README.md
└── flat_pack.gemspec
```

## Key Runtime Surfaces

### Ruby entry points

- `lib/flat_pack.rb` loads the engine, sanitizers, and installation helpers.
- `lib/flat_pack/engine.rb` registers Propshaft asset paths, importmap paths, preview paths, and rake tasks.
- `lib/tasks/flat_pack_tasks.rake` exposes `flat_pack:version`, `flat_pack:info`, `flat_pack:contract`, and `flat_pack:verify_install`.

### CSS delivery

- `app/assets/stylesheets/flat_pack/variables.css` provides Tailwind tokens, component variables, and built-in theme variants.
- `app/assets/stylesheets/flat_pack/rich_text.css` styles TipTap editor surfaces.
- `app/assets/stylesheets/flat_pack/content_editor.css` styles content-editor output.
- Host apps load FlatPack styles with `stylesheet_link_tag`, not by copying files into the host app.

### JavaScript delivery

- `config/importmap.rb` pins FlatPack controllers, TipTap helpers, and the Heroicons module into the host app importmap.
- Controller pins use `preload: false`, so they are compatible with lazy Stimulus loading.
- Whether controllers stay lazy depends on the host app: a global `eagerLoadControllersFrom("controllers", application)` can still import them at boot.

## Documentation Map

- `README.md` is the top-level project overview.
- `docs/README.md` is the docs landing page.
- `docs/ai/install_contract.json` is the machine-readable host-app integration contract.
- `docs/ai/README.md` is the AI retrieval and install entrypoint.
- `docs/components/manifest.yml` is the machine-readable component inventory.
- `docs/components/README.md` is the human-readable component index.

## Installation Workflow

The canonical host-app workflow is:

```bash
bundle install
rails generate flat_pack:install
bin/rake flat_pack:contract
bin/rake flat_pack:verify_install
```

The install generator updates the host app layout, Tailwind entry CSS, importmap, and Stimulus setup. The verifier checks that those changes are present in the host app.

## Development Workflow

### Common commands

```bash
bundle install
bundle exec rake test
bundle exec rubocop -A
bundle exec rake build
```

### Dummy apps

- `test/dummy/` is the main Rails 8 demo and integration app.
- `test/dummy-rails-7/` provides Rails 7 compatibility coverage.

## Project Status

FlatPack is in active development. For the current released changes, use `CHANGELOG.md`; for the installed-gem integration contract, use `docs/ai/install_contract.json`.
