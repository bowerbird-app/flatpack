# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.40] - 2026-05-06

### Added
- Added a host-app TipTap addon registry so `FlatPack::TextArea` rich text editors can opt into application-registered extensions without forking FlatPack.
- Added `rich_text_options[:addons]` validation and serialization, including support for addon descriptors with per-instance option hashes.

### Changed
- Refactored the rich text toolbar and bubble menu to accept addon-provided tool definitions alongside the built-in preset tools.
- Clarified the rich text docs so `addons` is the supported extension point and `extensions` is documented as reserved for FlatPack-managed overrides.
- Expanded the textarea docs and dummy `/demo/forms/text_area` page with a host-app addon walkthrough, including a working TipTap `Image` extension example registered from the dummy app.

### Tests
- Added regression coverage for valid and invalid `rich_text_options[:addons]` payloads and JSON serialization of addon descriptors.

## [0.1.39] - 2026-05-05

### Changed
- Expanded card-scoped `theme:` overrides to cover primary, default, and secondary button tokens alongside the card surface tokens.
- Updated the card docs and dummy demo variable tables so the new theme options and Wise-style example are reflected in both markdown docs and `/demo/cards`.

## [0.1.38] - 2026-05-05

### Changed
- Added an optional card `theme:` hash that can override background, text, muted text, and primary tokens for a single card subtree while preserving existing token fallbacks for any omitted keys.

### Tests
- Added regression coverage for partial card theme hashes, safe CSS color validation, and card-local primary token inheritance.

## [0.1.37] - 2026-05-05

### Added
- Added a new dummy Text Content demo page under `/demo/text/content` to showcase long-form editorial and marketing copy with primary-theme color accents.
- Added a new `FlatPack::Tree::Component` plus `/demo/tree` examples for VS Code-style folder explorers and nested list navigation.

### Changed
- Added `rich_text` and `rich_text_options` pass-through support to the comments composer and inline input wrappers so reply and comment fields can opt into the shared TipTap-backed `TextArea` editor while remaining plain text by default.

### Fixed
- Restored the dummy app importmap's missing `@tiptap/*` package pins so rich-text comment and textarea demos can actually boot the `flat-pack--tiptap` controller in the browser.
- Explicitly registered the dummy app's `flat-pack--tiptap` Stimulus controller so rich-text demos do not rely solely on nested lazy controller discovery at first paint.
- Added component file versions to the dummy app's full-page cache key so component-only demo updates, including the new Tree markup, no longer serve stale cached HTML until the cache expires.

## [0.1.36] - 2026-05-05

### Added
- Added a new `FlatPack::Tree::Component` for rendering expandable folder trees and hierarchical lists with a nested node DSL.
- Added dummy app route, sidebar entry, search index coverage, and documentation for the new Tree component.

## [0.1.35] - 2026-05-04

### Fixed
- Removed the stale self-referential Tailwind root token mappings from the dummy app scaffold and vendored install template so token-driven button radii resolve correctly during local preview and generated installs.
- Restored stylesheet- and importmap-aware dummy full-page cache keys so refreshed demo pages stop serving stale HTML that points at old digested CSS assets.

### Tests
- Added regression coverage to keep both the install-template scaffold and the dummy app Tailwind scaffold free of circular CSS variable mappings.
- Added controller regression coverage to keep dummy page-cache keys sensitive to layout stylesheet and importmap version changes.

## [0.1.34] - 2026-05-04

### Changed
- Refreshed the comments thread, composer, item, and replies components to use the new card-style layout with avatar-led composition, default sort pills in the thread header, and the floating composer submit affordance.
- Switched the dummy comments demo and component docs to the updated composer-based layout so the shipped examples match the rendered component structure.

### Tests
- Updated the comments component regression suite to cover the new default layout classes, sort controls, composer avatar behavior, and replies indentation.

## [0.1.33] - 2026-04-28

### Fixed
- Removed self-referential Tailwind token mappings from the generated `application.tailwind.css` scaffold so new FlatPack installs no longer emit invalid `:root` assignments for shared radius, transition, and focus-ring variables.
- Synchronized the shipped AI install contract metadata and the Rails 7 dummy lockfile with the current `0.1.33` gem version so contract validation and frozen bundle installs stay in sync.

### Tests
- Added regression coverage to keep the install generator's Tailwind template free of self-referential CSS variable mappings.

### Docs
- Updated the installation guide, AI entrypoint, and project-structure reference to reflect the `0.1.33` release metadata and current install-contract workflow.

## [0.1.32] - 2026-04-27

### Added
- Added DigitalOcean App Platform deployment support for the Rails dummy app, including a checked-in app spec with separate web and Sidekiq worker services.

### Changed
- Switched the Rails 8 dummy app to PostgreSQL in production, added a production Puma config, and enabled production defaults for static assets, SSL, and Sidekiq-backed Active Job.

### Docs
- Added a dedicated DigitalOcean deployment guide for the dummy app and linked it from the main documentation surfaces.

## [0.1.30] - 2026-04-24

### Changed
- Added an `actions` slot to `FlatPack::PageTitle::Component`, rendering action content directly below the subtitle when present and directly below the title when no subtitle is provided.
- Updated the admin dashboard and page-title demo pages to use the new `PageTitle` actions slot for inline page-level controls.

### Tests
- Added focused component coverage for `PageTitle` actions placement with and without a subtitle, and kept the admin demo request coverage asserting the rendered action button.

### Docs
- Updated the Page Title component documentation to describe the new `actions` slot, its placement behavior, and block-based usage examples.

## [0.1.29] - 2026-04-24

### Changed
- Added the standard FlatPack pagination component to the dummy admin dashboard user-management table and expanded the demo dataset so the page consistently shows a multi-page admin listing.

### Tests
- Added dummy request coverage to ensure the admin demo responds successfully and continues rendering pagination controls.

## [0.1.28] - 2026-04-24

### Fixed
- Changed breadcrumb back-link resolution to derive from the previous linked breadcrumb level instead of the HTTP referer, preventing breadcrumb back buttons from looping between sibling pages, while preserving explicit override and fallback behavior.

### Tests
- Added breadcrumb regression coverage for derived back-link targets, explicit `back_href` overrides, and fallback behavior when no earlier linked breadcrumb item exists.

### Docs
- Updated breadcrumb component documentation and dummy demo copy to describe hierarchy-based back-link behavior and the new `back_href` option.

## [0.1.27] - 2026-04-16

### Fixed
- Restored shared `.text-warning` and `.border-warning` utility classes in the engine stylesheet, mapped `.text-warning` to the visible warning accent token, preserved server-rendered validation error styling when the shared JS validator clears client-side errors, added explicit fallback copy for required-field blur validation when browsers do not surface a native message, aligned the text input demo error example with real `minlength` validation plus a matching too-short message override, and restored the baseline themed border class when JS clears warning state so fields do not fall back to a black browser-default border.
- Updated the dummy full-page cache key to include the current layout stylesheet digests and importmap digest so cached demo HTML no longer points at stale missing asset URLs after CSS or lazy-loaded controller JS changes.

### Tests
- Added regression coverage to keep the warning utility helpers present in the shared theme stylesheet.
- Added dummy controller regression coverage to ensure full-page cache keys roll when the layout stylesheet asset digests change.

## [0.1.23] - 2026-04-14

### Added
- Shipped an AI-oriented install contract at `docs/ai/install_contract.json` plus an AI entrypoint guide at `docs/ai/README.md`, so host apps and external tooling can read the exact FlatPack integration contract from the installed gem.
- Added `FlatPack::InstallContract`, `FlatPack::InstallVerifier`, `bin/rake flat_pack:contract`, and `bin/rake flat_pack:verify_install` so installation requirements can be read and verified programmatically.

### Docs
- Updated the top-level and docs index installation guidance to point to the new AI contract and verification workflow.

### Tests
- Added regression coverage for install-contract loading and host-app installation verification checks.

## [0.1.22] - 2026-04-13

### Changed
- `FlatPack::Picker::Component` now renders local search by default, while a new `minimum_searchable` option can hide the local search bar when the initial item count is less than or equal to a chosen threshold.
- Remote picker search now always renders the search bar whenever `search_mode: :remote` is used, even if `searchable: false` is passed.

### Docs
- Updated the picker component docs to describe the new default local search behavior, the `minimum_searchable` option, and the remote-search visibility rule.

### Tests
- Added picker component regression coverage for default search rendering, threshold-based hiding, local hard-off behavior, remote search visibility, and invalid `minimum_searchable` values.

## [0.1.21] - 2026-04-13

### Changed
- Added a reusable `flat-pack--chip-tag-input` Stimulus controller for chip tag-input flows, keeping local chip insertion as the default behavior and making request-backed add callbacks explicitly opt-in.
- The dummy chips page now demonstrates both local-only chip entry and an optional request-backed add flow that posts to a path only when auto-submit is enabled.
- `FlatPack::Chip::Component` size variants now use the same vertical spacing scale as buttons, aligning chip heights to the 30px, 38px, and 50px button sizes while keeping chip-specific horizontal padding.

### Docs
- Updated the chips component docs to describe the `flat-pack--chip-tag-input` integration and clarify that add auto-submit is optional and defaults to off.

### Tests
- Expanded chip tag-input JavaScript coverage for local mode, request-backed success, and request-backed failure, and added dummy request coverage for the add callback endpoint.

## [0.1.19] - 2026-04-10

### Changed
- `FlatPack::Chip::Component` removable chips now accept optional `remove_url`, `remove_method`, and `remove_params` options so a chip can trigger a GET or POST callback before the existing removal animation completes.
- The `flat-pack--chip` Stimulus controller now preserves the chip when that optional callback fails and emits `chip:remove-failed` for host-side error handling.
- The dummy chips demo now applies the GET callback flow to the main removable chip examples, matching the visible sample code instead of reserving request-backed removal for a separate demo chip.
- The `flat-pack--chip` Stimulus controller now falls back to the rendered `data-*` attributes when Stimulus value flags are unavailable at runtime, preventing stale browser sessions from silently skipping callback-backed removals.
- The dummy `chips` page and removal callback endpoint now bypass page caching and send no-store cache headers so the demo does not keep serving stale importmap/controller asset references.

### Docs
- Updated the chip component documentation to clarify that `remove_url`, `remove_method`, and `remove_params` are optional and that removable chips stay client-side only unless a `remove_url` is provided.

### Tests
- Added chip component and demo regression coverage for removable request configuration, invalid remove methods, unsafe remove URLs, invalid remove params, successful GET callbacks, and failed removal callbacks that keep the chip in place.

## [0.1.18] - 2026-04-10

### Fixed
- The Rails 8 dummy app now builds and serves its compiled Tailwind bundle as `application.css`, matching the layout asset tag and avoiding unstyled pages when running `test/dummy/bin/dev`.

### Tests
- Added dummy app request coverage to assert the demo layouts link the compiled `application` stylesheet instead of the legacy `tailwind` asset name.

## [0.1.17] - 2026-04-10

### Fixed
- `FlatPack::Chip::Component` now renders variant colors with explicit CSS-variable Tailwind utilities instead of semantic shorthand classes, restoring chip styling in the dummy app when the Tailwind v4 build does not emit those semantic utilities.

### Tests
- Updated chip component regression coverage to assert the explicit CSS-variable classes used for each variant style.

## [0.1.16] - 2026-04-10

### Changed
- `FlatPack.configure` now accepts `default_icon_variant`, allowing host apps to set the default Heroicons variant globally while keeping `:outline` as the gem default.
- `FlatPack::Shared::IconComponent` now uses the configured default variant when no per-icon variant is passed, and applies the correct SVG `viewBox` for `:outline`, `:solid`, `:mini`, and `:micro`.
- The generated `flat_pack/heroicons` JavaScript module now exports real Heroicons banks for all four variants instead of aliasing `:mini` and `:micro` to the 24px solid set.
- Updated the dummy Rails app to exercise `default_icon_variant` through `config/initializers/flat_pack.rb`, and documented the same initializer pattern in the installation guide.

### Tests
- Added configuration and icon component regression coverage for app-level default icon variants and the `mini`/`micro` SVG viewBox behavior.
- Added dummy app request coverage to verify a configured default icon variant is rendered on an existing demo page.

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
[0.1.33]: https://github.com/bowerbird-app/flatpack/compare/v0.1.32...v0.1.33
[0.1.8]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/bowerbird-app/flat_pack/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/flatpack/flat_pack/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/flatpack/flat_pack/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/flatpack/flat_pack/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/flatpack/flat_pack/releases/tag/v0.1.0
