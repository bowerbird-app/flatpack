# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.15] - 2026-04-09

### Changed
- `FlatPack::Picker::Component` list rows now render from explicit display regions for leading media/icon, title, description, and right text instead of branching on record-specific row content.
- Picker item normalization now accepts and emits `title`, `icon`, `thumbnail_url`, and `right_text`, while mapping legacy `label`, `meta`, `badge`, `path`, `content_type`, and `byte_size` values into those row regions as fallbacks.
- Updated the picker demo data and component docs to describe the row display-slot API and show explicit icon/right-text usage for file and record items.
- Picker demo page code blocks now render full, copyable examples with the complete `@picker_demo_items` setup included, and remote-search examples show full JSON payloads instead of abbreviated fragments.
- `FlatPack::Picker::Component` now supports `items_height` so the results region can either fill the wrapper, shrink to `min-content` for short lists, or use a fixed CSS height with overflow scrolling.
- Inline picker bodies now shrink-wrap their content by default and treat `modal_body_height` as a maximum height cap instead of forcing the inline shell to the full configured height.
- Built-in picker form mode now renders the hidden `formFields` target with `display: none`, so the empty container does not consume flex gap space before Stimulus populates hidden inputs.

### Tests
- Added picker component regression coverage for explicit display-slot fields and the backward-compatible fallback mapping for record items.

## [0.1.13] - 2026-04-08

### Fixed
- `FlatPack::Button::Dropdown::Component` menus now float from `document.body` with viewport-based positioning, so dropdown content is no longer clipped by `overflow-hidden` cards, chat panels, or sidebar shells.
- Dropdown menu items keep existing close/theme-switch/modal-launch behavior after the floating menu is reparented, and the menu now repositions on window resize and scroll.

### Tests
- Added Playwright regression coverage for a dropdown rendered inside an `overflow-hidden` chat panel to verify the floating menu escapes its clipping container and remains aligned to its trigger.

## [0.1.12] - 2026-04-01

### Security
- Updated Rails and Active Storage dependency bundles to patched releases that address the Active Storage proxy-mode multi-range request DoS advisory. The root and Rails 8 dummy bundles now resolve to Rails 8.1.3, and the Rails 7 dummy bundle now resolves to Rails 7.2.3.1.

### Changed
- `FlatPack::Picker::Component` now renders inline by default. Modal-backed pickers must opt in with `modal: true`.
- Updated picker docs and dummy app examples so modal trigger flows explicitly pass `modal: true`, while inline examples rely on the new default.
- `FlatPack::Picker::Component` now supports an optional `form:` configuration that renders a built-in Rails form wrapper, keeps hidden fields in sync with the current selection, and can submit ids, id arrays, or JSON without consumer-written Stimulus glue.
- Updated picker component docs to describe the new `form:` API, including `value_path` support for submitting `payload.record_id`, `payload.signed_id`, or other nested values.
- Added a "Required Data" section to the picker demo page with local `items:` and remote JSON examples showing the payload shape needed to render picker results.
- `FlatPack::Picker::Component` now preserves a first-class `record` kind, including optional `description`, `path`, and `badge` fields for folder-style selections.
- Image picker rows now hide the native radio or checkbox control when a thumbnail preview is present, so row clicks and the thumbnail overlay remain the visible selection affordance.
- Picker list results now apply a subtle hover background so result rows provide clearer pointer feedback before selection.
- Added a picker demo page example showing built-in form submission to a standard Rails controller, including a code example and a visible result panel after redirect.
- Added a folder-picker demo and request/component regression coverage for record-backed picker items and remote `kinds=record` searches.
- Added Playwright regression coverage for inline picker thumbnail rows to verify click-to-select behavior and the visible selection indicator.

### Tests
- Added picker component, request, and Playwright regression coverage for the built-in form submission flow.

## [0.1.11] - 2026-03-26

### Added
- **Rails 7.1 compatibility**: FlatPack now officially supports Rails 7.1 and 7.2 in addition to Rails 8. A dedicated `test/dummy-rails-7` application verifies engine boot, route loading, and component rendering on Rails 7.

### Changed
- **heroicons**: Replaced the manually curated subset (~40 icons) with the full Heroicons v2 icon set (324 outline + 324 solid icons). `FlatPack::Shared::IconComponent` can now render any Heroicons v2 icon without silent failures. The icon set is regenerated from the `heroicons` npm package via `npm run build:heroicons`.
- **Install generator** (`flat_pack:install`): Fixed the `under:` argument passed to `lazyLoadControllersFrom` — changed from `"controllers/flat_pack"` to `"controllers"`. The previous value caused stimulus-loading to build a doubled path (`controllers/flat_pack/flat_pack/…`) that never matched any importmap pin, silently failing to register all FlatPack Stimulus controllers.

### Security
- Updated `bcrypt` to 3.1.22 and `json` to 2.19.3 in gem dependencies.

## [0.1.10] - 2026-03-24

### Added
- `FlatPack::Sidebar::SectionTitle::Component` — new component that renders collapsible-aware section labels inside sidebar navigation. Displays as a small uppercase heading with `px-4` padding when expanded and `px-1` compact padding when collapsed. Integrates with `flat-pack--tooltip` (collapsed-only tooltips) and `flat-pack--sidebar-layout` (automatic padding toggle on collapse/expand).
- Demo page at `/demo/sidebar/section_title` with expanded, collapsed, collapsible, and long-label truncation examples.
- Variables table entry for `sidebar_section_title` in the dummy component reference page.

### Changed
- `sidebar_layout_controller.js`: toggles `px-4`/`px-1` on `[data-flat-pack-sidebar-section-title="true"]` elements during collapse/expand alongside item links and group buttons.
- `tooltip_controller.js`: `shouldShowTooltip()` now checks the nearest `[data-flat-pack-sidebar-collapsed]` ancestor when `collapsedOnly` is true and no `span.flex-1` label is present (used by section titles).
- `Sidebar::Header::Component`: added `headerRow` data-target so the layout controller can center the header row content in collapsed mode.
- Demo section headings migrated from inline `<p>` descriptions to the `subtitle:` param of `FlatPack::SectionTitle::Component`.
- Sidebar cache key bumped to `dummy/sidebar-shell-v2`.

## [0.1.9] - 2026-03-24

### Fixed
- Sidebar items and group header buttons now render with compact, centered padding (`px-1 justify-center`) when in collapsed/icon-only mode, both server-side (`collapsed: true`) and when toggled via the `flat-pack--sidebar-layout` Stimulus controller.
- `Sidebar::Item::Component` applies `px-1` and `justify-center` classes at render time when `collapsed: true`, matching the JS-toggled state.
- `Sidebar::Group::Component` header button now receives `data-flat-pack-sidebar-item="true"` so the layout controller targets it alongside item links during collapse/expand transitions.

### Changed
- `sidebar_layout_controller.js` updated to handle both `<a>` and `<button>` sidebar items in `setDesktopExpandedContentVisible`.

## [0.1.8] - 2026-03-20

### Fixed
- CSS variables and component styles now load correctly in host apps using Propshaft.
  The install generator previously prepended `@import "flat_pack/variables.css"` to
  `application.css`, which caused 404s because Propshaft only serves fingerprinted
  (digested) asset URLs. The generator now injects `stylesheet_link_tag` calls for
  `flat_pack/variables`, `flat_pack/rich_text` into the host app layout instead.
- Dummy app layouts updated to use `stylesheet_link_tag` for all three FlatPack
  stylesheets (`variables`, `rich_text`, `content_editor`), matching the documented
  install approach.
- Removed `@import` lines for FlatPack CSS from `application.tailwind.css` in the
  dummy app; styles are now loaded via link tags as documented.

### Changed
- Updated `docs/installation.md`, `docs/architecture/assets.md`,
  `docs/architecture/engine.md`, `docs/architecture/tailwind_4.md`,
  `docs/dark_mode.md`, and `docs/theming.md` to reflect `stylesheet_link_tag`
  as the correct CSS loading mechanism with Propshaft.

### Changed
- Removed `border-bottom` from `PageHeader::Component` and `Sidebar::Header::Component` for cleaner default styling.
- Updated `docs/installation.md` with additional setup guidance.

### Fixed
- Corrected failing test in `PageHeader::Component` test suite.

## [0.1.6] - 2026-03-18

### Added
- Security updates: bumped `action_text-trix` to 2.1.17 and `devise` to 5.0.3 to address known vulnerabilities.
- Expanded `docs/installation.md` with icon JS loading instructions and light theme defaults.

## [0.1.5] - 2026-03-17

### Added
- `docs/installation.md`: new **Section 5.2** — step-by-step guide for loading FlatPack Stimulus controllers in non-importmap apps (esbuild, Webpack, Vite, or any custom JS build pipeline).
  - `scripts/build_stimulus.js` build script that dynamically resolves the FlatPack gem path via `bundle show flat_pack` and bundles all controllers into a self-contained IIFE using esbuild.
  - Registers all 45 FlatPack Stimulus controllers by default (accordion, alert, badge, button-dropdown, carousel, chart, chat-*, chip, code-block-tabs, collapse, content-editor, date-input, file-input, form-validation, grid-sortable, icon, list-selectable, modal, navbar, pagination-infinite, password-input, picker, popover, range-input, search, search-input, section-title-anchor, select, sidebar, sidebar-group, sidebar-layout, table, table-sortable, tabs, text-area, theme, tiptap, toast, toasts-region, tooltip).
  - `package.json` `build:stimulus` script for easy regeneration after `bundle update flat_pack`.
  - Layout include instruction and localStorage key override note for `flat-pack--sidebar-layout`.
- `docs/installation.md`: new troubleshooting entry **"Sidebar / Interactive Components Not Working (Non-Importmap Apps)"** — explains the root cause (controller never registered), links to Section 5.2, and provides a browser console verification step.



### Added
- `FlatPack::ContentEditor::Component` — new in-place rich-text editor component that renders an editable content region with Edit / Save / Cancel controls and an optional floating balloon toolbar.
- Balloon toolbar supports bold, italic, underline, strikethrough, clear formatting, headings (H1–H3), bullet list, ordered list, blockquote, link, and image upload.
- Image upload support via optional `upload_url:` prop; images are uploaded via `POST` and inserted inline without a page reload.
- `flat_pack/content_editor.css` stylesheet with full typography reset (headings, paragraphs, lists, blockquotes, code, images) for the editable region.
- Stimulus controller `flat-pack--content-editor` with configurable `field_name`, `field_format_name`, and `field_format` values for flexible server-side field mapping.
- Component documentation at `docs/components/content-editor.md`.

### Changed
- Dummy app articles show view now uses `FlatPack::ContentEditor::Component` instead of the inline `article-editor` Stimulus controller.
- `flat_pack/application.css` and dummy app Tailwind stylesheet now import `content_editor.css`.

### Removed
- `test/dummy/app/javascript/controllers/article_editor_controller.js` — replaced by the engine-level `FlatPack::ContentEditor::Component`.

## [0.1.2] - 2026-01-23

### Added
- Automated Tailwind CSS 4 configuration in install generator
- Install generator now automatically detects Tailwind CSS 4 files and injects complete configuration
- Automatic calculation of relative paths from app's Tailwind file to gem's components directory
- Configuration template (`tailwind_config.css.tt`) with `@source` directive, `@theme` block, and `:root` mappings
- All FlatPack design tokens (colors, shadows, radius, transitions) automatically added to `@theme` block
- Fallback to manual instructions if automatic detection fails

### Changed
- Updated `docs/installation.md` to highlight automated Tailwind CSS 4 configuration
- Updated `README.md` to include automated setup in features list
- Manual configuration moved to fallback section in documentation

### Fixed
- Eliminates manual path finding and calculation errors during installation
- Ensures consistent Tailwind CSS 4 configuration across all installations

## [0.1.1] - 2026-01-23

### Fixed
- Added Tailwind CSS 4 safelist comments to Button and Icon components to ensure all classes stored in Ruby constants are detected and generated by Tailwind's `@source` directive
- Ruby constants (SCHEMES, SIZES, ICON_ONLY_SIZES) now include explicit string literal comments for proper CSS class scanning

### Added
- Comprehensive component development guidelines in `docs/architecture/tailwind_4.md`
- "Safelist Comments for Ruby Constants" documentation section with required format, guidelines, and examples
- Updated debugging section to troubleshoot missing safelist comments
- Updated best practices to include safelist comment requirement for future components

### Changed
- Button component: Added safelist comments for SCHEMES (18 classes), SIZES (9 classes), and ICON_ONLY_SIZES (3 classes)
- Icon component: Added safelist comments for SIZES (8 classes)

## [0.1.0] - 2025-01-20

### Added
- Initial release of FlatPack UI component library
- Rails 8 Engine with isolated namespace
- ViewComponent integration for all UI components
- Tailwind CSS 4 support with CSS variables
- Propshaft asset pipeline configuration
- Importmaps for JavaScript dependencies
- Base component with tailwind_merge integration
- Button component with multiple schemes (primary, secondary, ghost)
- Table component with configurable columns
- Icon component for shared icons
- Stimulus controller for table interactions
- Comprehensive documentation in docs/ directory
- Install generator for easy setup
- Test suite with dummy Rails 8 application
- Dark mode support via system preference (prefers-color-scheme)
- CSS variables for theming customization

[0.1.12]: https://github.com/bowerbird-app/flatpack/compare/v0.1.11...v0.1.12
[0.1.8]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/flatpack/flat_pack/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/flatpack/flat_pack/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/flatpack/flat_pack/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/flatpack/flat_pack/releases/tag/v0.1.0
