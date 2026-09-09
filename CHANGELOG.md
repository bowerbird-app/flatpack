# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [0.1.178] - 2026-09-09

### Added
- Dummy app hosts Recording Studio API, OAuth Connect, MCP, Admin, and Users on Postgres.
- Signed-in host home at `/studio` with Connected apps and Registered apps entry points.
- Docs for dummy Recording Studio wiring (`docs/recording_studio_dummy.md`).
- `FlatPack::ComponentCatalog` lists public ViewComponents and shows initialize parameters. Hosts can serve those hashes from Recording Studio API `register_endpoint` without a fake recordable.

### Fixed
- Dummy root switcher includes the Admin root so staff can open Admin screens.
- `/studio` **Registered apps** switches the current root to Admin and opens `/admin/screens/oauth_clients`.
- Dummy public API no longer registers Workspace, Folder, Page, or `ping`, so MCP/ChatGPT stop treating the demo tree as FlatPack resources.
- Dummy forces the public API’s recordable list to the (empty) registry so HTTP and OpenAPI match MCP.

### Changed
- Dummy `recording_studio_api` pin is `v0.5.4` so named endpoints are available.
- Dummy OpenAPI title is **FlatPack Component Catalog**; only the two catalog `register_endpoint` routes are exposed.
- Bumped the gem version to `0.1.178`.

### Upgrade notes
- Call `FlatPack::ComponentCatalog.list` and `.show(name)` from a host initializer. The gem does not mount HTTP routes.
- Dummy and other hosts that want `GET flatpack/components` need `recording_studio_api` `0.5.4` or newer, then register the two endpoints. Bearer auth still applies. Unknown names should raise `RecordingStudioApi::NotFoundError`.
- `docs/components/manifest.yml` stays the docs and AI reading order. The running inventory is the catalog methods (and the dummy HTTP routes that wrap them).
- On this dummy, do not re-add `register_recordable_type_api` for Workspace/Folder/Page if the goal is a catalog-only MCP type enum. Tree models stay for Admin and OAuth roots only.

## [0.1.177] - 2026-09-09

### Fixed
- Ghost and secondary buttons press with a 1px translate and an inset shadow. All buttons ease colour, border, shadow, and that press on `--duration-fast` / `--easing-standard`. The hit target does not scale.
- Alert dismiss, chip remove, and badge remove collapse height (chips and badges also collapse width) on `--duration-slow` / `--easing-exit`, so neighbours slide in instead of jumping after a scale-out. Reduced motion snaps.

### Changed
- Bumped the gem version to `0.1.177`.

### Upgrade notes
- Buttons use `.fp-button`. Ghost and secondary also use `.fp-button-flat` for the inset press. Hosts that copied button colour transitions without `ease-[var(--easing-standard)]` should add it. Do not add `active:scale-*`.
- Chip and badge colour uses `duration-[var(--duration-fast)] ease-[var(--easing-standard)]`, not Tailwind `duration-base`.
- Alert, chip, and badge controllers call `playCollapseExit` from `controllers/flat_pack/reduced_motion`. Hide waits are `--duration-slow` (0ms under reduced motion). Do not keep a parallel scale-out.

## [0.1.176] - 2026-09-09

### Fixed
- Spinner keeps a loading signal under `prefers-reduced-motion`. `.fp-spinner` spins by default and opacity-pulses when motion is reduced, instead of `motion-reduce:animate-none` which froze the mark.
- Password show/hide icons crossfade on `--duration-fast` / `--easing-standard` in a fixed 1rem box. The control uses `aria-pressed` and “Show password” / “Hide password”. Reduced motion snaps because the duration tokens collapse to `0ms`.

### Changed
- Bumped the gem version to `0.1.176`.

### Upgrade notes
- Spinner class is `.fp-spinner`, not Tailwind `animate-spin motion-reduce:animate-none`. Hosts that copied those utilities should switch to the kit class. Pulse duration is 1.2s and is not `--duration-*`, so it does not collapse to `0ms`.
- Password toggle no longer uses `hidden` on the unused eye icon. Keep both icons in `.fp-password-toggle-icons` and drive visibility with `aria-pressed`. Hide waits are not involved; opacity follows `--duration-fast`.

## [0.1.175] - 2026-09-09

### Added
- Search `size:` prop with `:sm`, `:md` (default), and `:lg`. Medium keeps the previous field height and type. Padding uses `--search-padding-y-*` and `--search-padding-inline-*` tokens so themes can tune each size.

### Changed
- Search result rows use `px-4 py-4` instead of `px-3 py-2`.
- Bumped the gem version to `0.1.175`.

### Upgrade notes
- Existing Search calls keep the medium look with no changes. Pass `size: :sm` or `size: :lg` when you want a smaller or larger field. Hosts that hard-coded `py-2` / `pl-10` / `pr-10` / `text-sm` on Search markup should switch to the size prop or the new padding tokens. Rebuild host Tailwind if you `@import` kit sources and need the new arbitrary padding classes generated.
- Hosts that copied Search result link classes should switch from `px-3 py-2` to `px-4 py-4`.

## [0.1.174] - 2026-09-08

### Fixed
- Avatar Group hover no longer scales members (`hover:scale-110`). Hover still lifts z-index and keeps full opacity so stacked faces stay readable.
- Avatar Group initials and overflow (`+N`) circles sit on the same row as photos. Slots are `flex items-center leading-none`, and avatar images are `display: block`.
- Chat sent and received reveal trays use `duration-[var(--duration-fast)]` instead of Tailwind `duration-150`, so `prefers-reduced-motion` token collapse applies.
- Searchable Select, Combobox, and the FlatPack date picker open and close like Popover: opacity plus a 4px offset on `--duration-base` / `--easing-enter` / `--easing-exit`. They share `playOverlayEnter` / `playOverlayExit`. The helper cancels an in-flight hide on the same element. Reduced motion skips the offset and hides on the next turn.

### Changed
- Bumped the gem version to `0.1.174`.

### Upgrade notes
- Hosts that copied Avatar Group `hover:scale-110` / `transition-transform` should drop them. Keep `hover:!opacity-100` and the wrapper `hover:!z-[999]`.
- Hosts that copied Avatar Group slots as `relative` only should use `relative flex items-center leading-none`. Put `leading-none` after size/`text-*` classes so Tailwind Merge keeps it. Avatar `<img>` should be `block`.
- Hosts that copied chat reveal-tray `duration-150` should switch to `duration-[var(--duration-fast)]`. Rebuild host Tailwind if you `@import` kit sources and need the arbitrary duration class generated.
- Hosts that snap `hidden` on searchable Select, Combobox, or date picker panels should use `playOverlayEnter` / `playOverlayExit` from `controllers/flat_pack/reduced_motion`. The helper owns the hide timeout; do not keep a parallel `hideTimeout` on the controller. Hide is delayed by `--duration-base` (0ms under reduced motion). Date picker still sets `display: none` after the exit finishes because the panel also uses `md:flex`.

## [0.1.173] - 2026-09-08

### Fixed
- Range input paints track, fill, and thumb in kit CSS (`.fp-range-input` and `--range-*` tokens) so the native slider no longer falls back to OS `accent-color` chrome.

### Changed
- Bumped the gem version to `0.1.173`.

### Upgrade notes
- Range fill/thumb follow `--range-track-color`, `--range-fill-color`, `--range-thumb-color`, `--range-thumb-border-color`, `--range-thumb-shadow`, `--range-thumb-size`, and `--range-track-height`, not Tailwind `accent-[var(--color-primary)]`. The input still is `<input type="range">`. `--range-progress` is a runtime percent on the input, not a theme token. Rebuild host Tailwind only if you `@import` `flat_pack/application`; `stylesheet_link_tag` hosts pick the kit class up on reload.

## [0.1.172] - 2026-09-08

### Fixed
- Drawer overlays move onto `document.body` while open and sit at `z-[70]`, so a left drawer no longer paints under `SidebarLayout`. A slot marker holds the original place so Stimulus disconnect-on-move does not put the overlay back.
- Progress fill paint lives in kit CSS (`.fp-progress-fill` and `--progress-fill-color`), so the default bar is no longer missing `.bg-primary`.
- Stepper completed markers use `.fp-stepper-marker` and `--stepper-complete-text-color`, so checks stay visible when the Tailwind arbitrary fill class is not in the host sheet.
- Ordered list rows with `icon:` keep both the decimal marker and a content-coloured `.flat-pack-list-item-icon`.
- Chat inbox unread counts use the primary badge, tabular nums, and no `overflow-hidden` clip. The dummy inbox label is sentence-case **Inbox**.

### Changed
- Bumped the gem version to `0.1.172`.

### Upgrade notes
- Drawer markup stays in place until open. While open, the overlay is a child of `document.body` and returns to its original parent on close. Hosts must not assume the original parent while the panel is visible.
- Progress fill is `.fp-progress-fill` / `--progress-fill-color` (and `--success` / `--warning` / `--danger` modifiers), not `bg-primary`. Rebuild host Tailwind only if you `@import` `flat_pack/application`; `stylesheet_link_tag` hosts pick the kit class up on reload.
- Stepper complete/current/upcoming paint is kit CSS. Hosts that copied the old Tailwind fill classes can drop them. Override `--stepper-complete-text-color` if the check should not follow `--color-success-text`.
- Chat inbox unread badges use `:primary` instead of `:info`. Rows no longer set `overflow-hidden`.

## [0.1.171] - 2026-09-08

### Fixed
- Modal Tab now cycles inside the dialog. The trap is wired as `keydown.tab->flat-pack--modal#handleKeydown`, and the dialog is `tabindex="-1"` so it can take focus when nothing else inside is focusable.
- Select selected options use `--color-primary-text` instead of Tailwind `text-white`.
- Picker selection rings and dots on media use `--picker-selection-indicator-*` instead of `border-white` / `bg-white`.

### Changed
- Dummy sample copy drops kit jargon (ViewComponent, Stimulus, records/slots) from hero, collapse, chat, picker, page nav, and related demos.
- Bumped the gem version to `0.1.171`.

### Upgrade notes
- Modal Tab wrapping starts working on gem upgrade. Hosts that copy Modal markup should add `keydown.tab->flat-pack--modal#handleKeydown` and `tabindex="-1"` on the dialog.
- Select selected-option text follows `--color-primary-text` (dark on ocean). Rebuild host Tailwind if you `@import` `flat_pack/application`.
- Picker indicator tokens default to `--picker-badge-text-color`. Hosts that already override that keep the same paint.
- Dummy demo wording is host-app copy only.

## [0.1.170] - 2026-09-08

### Fixed
- Dismissible Alert binds Stimulus identifier `flat-pack--alert` so the close button matches the registered controller. The unprefixed `alert` identifier never connected.

### Changed
- Bumped the gem version to `0.1.170`.

### Upgrade notes
- Hosts that copy Alert markup must switch `data-controller="alert"`, `data-alert-target="alert"`, and `alert#dismiss` to `flat-pack--alert`, `data-flat-pack--alert-target="alert"`, and `flat-pack--alert#dismiss`. Component renders pick this up on gem upgrade.
- The custom event name `alert:dismissed` is unchanged.

## [0.1.169] - 2026-09-08

### Fixed
- Refreshed `test/dummy/vendor/flat_pack` and both dummy lockfiles so App Platform frozen Bundler (`BUNDLE_DEPLOYMENT=1`) no longer fails on a path-gem / gemspec version skew.
- Documented the frozen-install verify step for DigitalOcean dummy deploys.

### Changed
- Bumped the gem version to `0.1.169`.

### Upgrade notes
- No API change. Hosts on path or Rubygems installs are unaffected. Anyone deploying `test/dummy` via App Platform should keep the vendored snapshot and lockfiles aligned after engine changes (`bin/refresh_flat_pack_vendor` + `bundle lock`).

## [0.1.168] - 2026-09-08

### Changed
- Alert and toast success, warning, and danger use a status wash (`color-mix` of the fill into the surface) with coloured icon and border. Body text uses `--surface-content-color`.
- Info toasts alias the quiet info alert instead of filling with `--color-primary`.
- Bumped the gem version to `0.1.168`.

### Fixed
- Toast close is a compact centered ghost X on every style. The danger close no longer sits in a filled chip. `.fp-hit-slop` keeps the 44px hit without growing the painted box to 44px.

### Upgrade notes
- Buttons, badges, chips, and progress still use the filled `--color-success-*` / `--color-warning-*` / `--color-danger-*` paints.
- Hosts that already set `--alert-*` / `--toast-*` are unchanged. Hosts that wanted filled alerts must set those component tokens back to the semantic fills.
- Named kit themes inherit the washes from `:root` because they still override the semantic fills, not `--alert-*`.
- `--toast-danger-dismiss-*` now alias the shared `--toast-dismiss-*` tokens. Hosts that painted a danger-only close chip should set `--toast-dismiss-text-color` / `--toast-dismiss-hover-background-color` instead.
- Toast close uses `.fp-hit-slop` instead of `.fp-hit-target`. Hosts that load kit CSS with `stylesheet_link_tag` pick the slop class up on reload. Rebuild host Tailwind if the toast component classes are scanned into the host sheet.
- Rebuild host Tailwind only if you `@import` `flat_pack/application`.

## [0.1.167] - 2026-09-08

### Changed
- Overlay chrome that used Tailwind black/white utilities now follows tokens: hero (`--hero-overlay-*`), carousel controls/media/lightbox (`--carousel-control-*`, `--carousel-counter-*`, `--carousel-media-background-color`, `--carousel-lightbox-image-background-color`), badge remove hover (`--badge-remove-hover-background-color`), sidebar mobile drawer (`--drawer-backdrop-color`), and picker grid badges/idle rings (`--picker-badge-*`, `--picker-selection-idle-*`).
- Card stat up/down trends use `--color-success-background-color` / `--color-danger-background-color`.
- Dummy forms use `--card-background-color` instead of the missing `--color-card`. Dummy prices, chart deltas, the green link, and popover Delete use semantic success/danger tokens.
- Bumped the gem version to `0.1.167`.

### Upgrade notes
- No API change. Hosts that already override the overlay tokens listed above keep those values. Hosts that relied on hardcoded Tailwind `bg-black/60`, `text-green-600`, and similar utilities now follow the theme.
- Carousel prev/next, counter, and lightbox toggle fill follow `--carousel-control-*` / `--carousel-counter-*` (`rgb(0 0 0 / 0.6)` idle, `0.8` hover) instead of hardcoded `rgba(0,0,0,0.5)` / `0.75`.
- Rebuild host Tailwind if you `@import` `flat_pack/application`. Hosts that load kit CSS with `stylesheet_link_tag` pick this up on reload.

## [0.1.166] - 2026-09-07

### Fixed
- `:root` `--color-primary` / `--color-primary-hover` now follow `--brand-hue` / `--brand-chroma` / `--brand-lightness`. Hosts that only set the brand knobs recolor primary buttons and other `--color-primary` consumers.
- Theme generator output is brand knobs only. `:root` already maps those knobs to primary; hosts no longer uncomment a formula that subtracted chroma (invalid at charcoal chroma `0`).

### Changed
- Dummy Sunrise sets `--brand-lightness: 0.52` so the theme picker demo shows a warm primary instead of leftover charcoal.
- Bumped the gem version to `0.1.166`.

### Upgrade notes
- Hosts that already set `--color-primary` / `--color-primary-hover` are unchanged. Hosts that only set `--brand-*` will now recolor primary.
- Default charcoal is unchanged: chroma `0` / lightness `0.3211` still resolves near `oklch(0.3211 0 0)`. Hover is `oklch(calc(var(--brand-lightness) - 0.10) …)` instead of `#1f1f1f`.
- Named kit themes (`dark`, `ocean`) still override `--color-primary` with literals.
- Rebuild host Tailwind only if you `@import` `flat_pack/application`. Hosts that load kit CSS with `stylesheet_link_tag` pick this up on reload.

## [0.1.165] - 2026-09-07

### Added
- Kit primitives: Drawer (edge panel), Combobox (searchable single choice), Command palette (Cmd/Ctrl+K), Stepper, Kbd, Skip link, and Spinner.
- Dummy demos at `/demo/drawer`, `/demo/forms/combobox`, `/demo/command_palette`, `/demo/stepper`, `/demo/kbd`, `/demo/skip_link`, and `/demo/spinner`. Dummy layouts skip to `#main` and open a page palette with Cmd/Ctrl+K.
- Bumped the gem version to `0.1.165`.

### Changed
- Button loading renders `FlatPack::Spinner::Component` instead of an inline SVG.

### Upgrade notes
- Render `FlatPack::SkipLink::Component` first in `<body>` and put `id="main" tabindex="-1"` on `<main>` (the layout generator does this). Without `#main`, the default skip href has nowhere to land.
- Open a drawer with `data-drawer-id` matching the drawer `id:`. Open a command palette with `data-command-palette-id`. If two palettes sit on one page, set `shortcut: false` on all but one.
- Drawer tokens alias Modal. Hosts that override `--modal-*` get matching drawers. Optional `--kbd-*`, `--skip-link-*`, and `--stepper-*` tokens alias surfaces and brand colours.
- Rebuild host Tailwind only if you `@import` `flat_pack/application` into the Tailwind entry. Hosts that load kit CSS with `stylesheet_link_tag` pick up `.fp-skip-link` and overlay contain without a rebuild.

## [0.1.164] - 2026-09-07

### Changed
- Default Search idle fill (`--search-input-background-color`) now aliases `--surface-background-color` instead of `--surface-muted-background-color`.
- Bumped the gem version to `0.1.164`.

### Upgrade notes
- Hosts that override `--search-input-background-color` are unchanged. Hosts that relied on the muted grey default will see a surface fill after upgrade.
- Rebuild host Tailwind only if you `@import` `flat_pack/application`. SearchInput and form controls are unchanged.

## [0.1.163] - 2026-09-07

### Fixed
- Ordered lists show decimal markers (`1.`, `2.`, …) in a kit marker slot on each item. Unordered lists stay unmarked.

### Changed
- Bumped the gem version to `0.1.163`.

### Upgrade notes
- No API change. `ordered: true` still renders `<ol>`.
- Rebuild host Tailwind only if you `@import` `flat_pack/application`. Markers are kit CSS classes, not Tailwind utilities.

## [0.1.162] - 2026-09-07

### Fixed
- List drag-reorder persist runs when `orderable_url` is set. `saveOrder` now checks `hasOrderableUrlValue`, the Stimulus flag for `orderableUrl`, instead of leftover `hasOrderablePathValue`.
- Bumped the gem version to `0.1.162`.

### Upgrade notes
- No API change. Hosts that already pass `orderable_url:` need no code change. If drag-reorder stopped saving after the 0.1.124 param rename, upgrade this gem.

## [0.1.161] - 2026-09-07

### Changed
- Kit themes no longer ship decorative `--gradient-1` … `--gradient-4` or `.fp-gradient-*`. Named host themes may still define those tokens if they want a wash.
- Dummy heroes sit on the page surface instead of pastel hex gradients. Dummy cards use surface-muted media placeholders, sentence-case stat labels, and a `Popular` badge instead of tracked-out ALL-CAPS eyebrows.
- Bumped the gem version to `0.1.161`.

### Upgrade notes
- If a host used `var(--gradient-1)` through `var(--gradient-4)` or `.fp-gradient-*`, copy those tokens onto a named `[data-theme]` (see `docs/custom_theming.md`) or replace the wash with a surface token.
- Hero `background:` still accepts a CSS value. Prefer omitting it or passing `var(--surface-muted-background-color)`.
- Rebuild host Tailwind only if you `@import` `flat_pack/application` or copied the dummy `.fp-gradient-*` helpers.

## [0.1.160] - 2026-09-07

### Changed
- Loading copy uses a typographic ellipsis: skeleton `aria-label` is `Loading…`, infinite pagination skeletons match, and the default `loading_text` is `Loading more…` on both Pagination and PaginationInfinite.
- EmptyState is an invitation to act. Leftover inbox/search illustration SVGs are gone; optional `icon:` uses `IconComponent` at `lg`. The root is `.fp-empty-state` and fades in on `--duration-slow` / `--easing-enter`. Hosts add `.fp-content-enter` to the panel that replaces it.
- Billing invoice empty and payment-method empty no longer lead with an inbox picture. Payment method empty puts its actions in the EmptyState slot.
- Dummy `/demo/empty_state` shows action-first examples and an empty→content toggle. Dummy skeleton list heading is `Loading…`.
- Bumped the gem version to `0.1.160`.

### Upgrade notes
- No component API changes. `icon: :inbox` and `icon: :search` still work; they render kit icons instead of inline SVGs.
- If a host depended on the old 48px illustration, pass `graphic` or drop the icon and keep the button.
- When content replaces an empty panel, add `fp-content-enter` to the incoming node. Rebuild host Tailwind only if you `@import` `flat_pack/application`.

## [0.1.159] - 2026-09-07

### Changed
- Overlay scroll stays in the overlay: modal backdrop/body and carousel lightbox use `overscroll-behavior: contain`. Opening a modal also sets `overscroll-behavior: none` on `document.body` with the same lock count as overflow.
- Kit buttons, pill items, bottom-nav items, and `.fp-hit-target` / `.fp-hit-target-inline` use `touch-action: manipulation`.
- Fixed chrome respects safe-area insets. TopNav is `72px` plus `safe-area-inset-top`. Toast region sits below that bar and inset-right. Modal and carousel lightbox use `.fp-overlay-pad`. The mobile sidebar drawer pads the notch edges. Bottom nav already used `safe-area-inset-bottom`.
- Dummy layouts and the sidebar layout generator set `viewport-fit=cover` so `env(safe-area-inset-*)` is non-zero on notched devices.
- Bumped the gem version to `0.1.159`.

### Upgrade notes
- Add `viewport-fit=cover` to the host viewport meta (`width=device-width,initial-scale=1,viewport-fit=cover`). Without it, inset env() values stay `0`. Copy from `docs/installation.md` or re-run `rails generate flat_pack:layout`.
- No component API changes. Rebuild host Tailwind only if you `@import` `flat_pack/application` into the Tailwind entry. Hosts that load kit CSS with `stylesheet_link_tag` pick up the new classes without a rebuild.

## [0.1.158] - 2026-09-07

### Changed
- Outline icons use `--icon-stroke-width` (Heroicons `1.5`) instead of leftover Lucide `2` / `1.8` / `3`. TipTap bold/italic/underline/strike stay `2.5`. Button spinner rings stay `4`.
- `IconComponent` optically nudges `paper-airplane`, `pencil`, `pencil-square`, `arrow-up-tray`, and `arrow-down-tray` the same way as magnifying-glass (`-translate-y-0.5`). Caller classes such as `hidden` win over `block`, so password reveal still hides the slash icon.
- Left/right travel and alignment glyphs get `fp-icon-directional` and flip in `[dir="rtl"]` with CSS `scale` so optical translate nudges still apply. Vertical chevrons, checks, media playback, and chat-bubble tails do not flip.
- Pagination, modal close, toast dismiss, search clear, password reveal, accordion/collapse/select/dropdown chevrons, carousel lightbox close, and comment composer/replies use `IconComponent` instead of inline Lucide SVGs.
- Bumped the gem version to `0.1.158`.

### Upgrade notes
- No host app API changes. Icon names are the same.
- Hosts can set `--icon-stroke-width` on `:root` to thicken or thin outline icons. Default is `1.5`. Do not put `--icon-stroke-width: var(--icon-stroke-width)` on `:root`.
- `fp-icon-directional` lives in kit CSS. Rebuild host Tailwind only if you `@import` `flat_pack/application` into the Tailwind entry.

## [0.1.157] - 2026-09-07

### Changed
- Host Tailwind `@layer theme` still emits `--radius-md: 0.375rem` (and the rest of Tailwind's scale). Dummy and the install generator now re-set the kit radii on unlayered `:root` (`--radius-sm: 0.75rem`, `--radius-md: 1rem`, `--radius-lg: 1.5rem`, `--radius-xl: 2rem`) so rich-text chrome and `rounded-[var(--radius-*)]` surfaces keep the kit scale when host CSS loads last.
- Rich text and content editor CSS already fall back to those kit values when the token is unset. The fallback does not apply when Tailwind writes `0.375rem` onto `--radius-md`; the unlayered `:root` re-set is what makes the computed token match.
- Bumped the gem version to `0.1.157`.

### Upgrade notes
- Rebuild host Tailwind after you add the `:root` radii (or re-run `rails generate flat_pack:install` on a new app). Existing hosts that already have a FlatPack `@source` are not rewritten — copy the unlayered `:root` block from `docs/theming.md` next to any `--font-sans` re-set you already have.
- Do not put `--radius-md: var(--radius-md)` on `:root`. Concrete kit values only.
- Padding tokens such as `--button-padding-y-sm: 0.375rem` are not radius. Leave them.

## [0.1.156] - 2026-09-07

### Changed
- Tabs, chat incoming bubbles, sidebar and top-nav hover, list hover, and avatar fallbacks alias `--surface-muted-*` / `--surface-content-color` instead of light-theme grey hexes (`#4b5563`, `#dfe5ec`, `#f7f7f7`, `#e5e7eb`). Dark and ocean inherit those greys from the surface tokens.
- Bumped the gem version to `0.1.156`.

### Upgrade notes
- No host app API changes. Component token names are the same.
- If a host overrode `--tabs-pill-inactive-*`, `--chat-message-incoming-*`, `--sidebar-item-hover-background-color`, `--top-nav-item-hover-background-color`, `--list-item-*-background-color`, or `--avatar-background-color` / `--avatar-text-color` with a hex to match the old kit greys, drop those overrides and let the surface tokens drive them — or keep the hex if you want that frozen colour.

## [0.1.155] - 2026-09-06

### Changed
- Token values live once on `:root`. `@theme inline` registers the same names for Tailwind utilities without re-emitting hex/oklch (no second copy of the palette).
- `[data-theme="rounded"]` is a no-op alias of the default. It no longer restates charcoal colours, radii, or shadows.
- Carousel chrome tokens and extra-small button padding that previously existed only inside `@theme` now resolve on `:root`.
- Dummy `/themes` token tables read `:root`, not `@theme`.
- Bumped the gem version to `0.1.155`.

### Upgrade notes
- No host app API changes. `data-theme="rounded"` still looks like the default; you can keep or drop the attribute.
- Do not copy `@theme inline { --color-primary: var(--color-primary); }` onto `:root`. That pattern is Tailwind inventory only. Concrete values stay on `:root`. A `:root` (or `[data-theme]`) line of `--token: var(--token)` is still a circular map and will blank the token.
- Rebuild host Tailwind only if you `@import` `flat_pack/variables` into the Tailwind entry. Hosts that load it with `stylesheet_link_tag` already skip `@theme`; browsers keep reading `:root`.

## [0.1.154] - 2026-09-06

### Changed
- One application shell: `SidebarLayout` + `Sidebar` + `TopNav`. `FlatPack::Navbar::Component` and `Navbar::Sidebar` / `Navbar::TopNav` / `flat-pack--navbar` are removed.
- Dummy `/demo/navbar` is still the Top Nav slot demo. Dummy chrome was already `SidebarLayout`.
- Bumped the gem version to `0.1.154`.

### Upgrade notes
- If you render `FlatPack::Navbar::Component`, switch to `SidebarLayout` and compose `Sidebar` and `TopNav` into its slots. Remove any `application.register("flat-pack--navbar", …)` pin; collapse and mobile drawer live on `flat-pack--sidebar-layout`.
- No visual change for hosts that already use `SidebarLayout` (the layout generator and dummy).

```erb
<%= render FlatPack::SidebarLayout::Component.new(storage_key: "app-sidebar") do |layout| %>
  <% layout.sidebar do %>
    <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
      <% sidebar.items do %>
        <%= render FlatPack::Sidebar::Item::Component.new(text: "Dashboard", href: "/", icon: :home, active: true) %>
      <% end %>
    <% end %>
  <% end %>

  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new do |nav| %>
      <% nav.left { "Dashboard" } %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <%= yield %>
  <% end %>
<% end %>
```

## [0.1.153] - 2026-09-06

### Added
- `--font-sans` and `--font-mono`, plus a type scale (`--text-xs` through `--text-5xl`) and `--leading-tight` / `--leading-snug` / `--leading-normal`. Page title sizes alias the scale (`--page-title-h1-size` is `--text-4xl`).
- Kit classes `.fp-tabular-nums`, `.fp-text-balance`, and `.fp-text-pretty` on `flat_pack/application`, so hosts do not need a Tailwind rebuild for wrapping or lining up numbers.

### Changed
- `:root` sets `font-family: var(--font-sans)` and antialiased smoothing. Labels that were tracked-out ALL-CAPS (hero tagline, table headers, sidebar and navbar sections, date picker headings, card stats) are sentence case.
- Hero headlines use `--text-4xl` / `--text-5xl` and `fp-text-balance` instead of `lg:text-6xl` landing-page type. Pagination, progress meters, timestamps, card stats, and chart axes use tabular numbers.
- Bumped the gem version to `0.1.153`.

### Upgrade notes
- No host app API changes. Kit CSS variables apply as soon as `flat_pack/variables` loads.
- If host Tailwind loads after kit CSS, re-set `--font-sans` on unlayered `:root` (not `@theme`) so Tailwind’s `ui-sans-serif` stack does not win. `.fp-tabular-nums` / `.fp-text-balance` / `.fp-text-pretty` come from kit `flat_pack/application` and do not need a Tailwind rebuild.
- Rebuild host Tailwind if you want `text-[length:var(--text-4xl)]` utilities generated for any host markup. Kit components that need those sizes already emit the class.

### Fixed
- Bump `rubyzip` to `3.6.0` (CVE-2026-85396).

## [0.1.152] - 2026-09-04

### Added
- `--easing-standard` (`cubic-bezier(0.2, 0, 0, 1)`), `--easing-enter` (`cubic-bezier(0.05, 0.7, 0.1, 1)`), and `--easing-exit` (`cubic-bezier(0.3, 0, 1, 1)`). In-place motion uses standard, overlays enter with decelerate, and overlays exit with accelerate. No bounce.
- `motionTransition()`, `overlayOrigin()`, and `overlayEnterOffset()` on `controllers/flat_pack/reduced_motion` so Stimulus transitions share those tokens.

### Changed
- Modal, toast, dropdown, popover, and tooltip enter/exit are interruptible CSS transitions. Modal and toast enter on `--duration-slow` / `--easing-enter` and exit on `--duration-base` / `--easing-exit`. Popover and tooltip fade plus a 4px offset from the trigger, with origin from placement.
- Switch, progress, accordion, collapse, sidebar, and leftover JS transitions (alert, chip, badge, table, navbar overlay) use the named easings instead of `ease-in-out` or a hardcoded cubic-bezier.
- Form invalid chrome is still border and helper colour only. The kit does not shake fields.
- Bumped the gem version to `0.1.152`.

### Upgrade notes
- No host app API changes. Overlay enter/exit timing: modal exit is now `--duration-base` (faster than enter). Toast already had that split.
- Rebuild host Tailwind so `ease-[var(--easing-*)]` utilities are generated. Kit CSS variables apply as soon as `flat_pack/variables` loads.

## [0.1.151] - 2026-09-04

### Added
- Tracked `tests.mdc` under `.cursor/rules/` so Cloud Agents add tests for behavior changes. See [Cursor Cloud Agent skills and rules](docs/cursor-skills.md).

### Changed
- Bumped the gem version to `0.1.151`.

### Upgrade notes
- No host app API changes. Product UI is unchanged. After merge, rebuild the Cloud Agent environment Draft so checkout rules include `tests.mdc`.

## [0.1.150] - 2026-09-04

### Added
- `--color-error` and `--color-error-border` alias danger red. Invalid form chrome (borders, helper text, JS validation, rich-text error focus) uses those tokens. Chip, alert, and button **warning** styles stay amber.
- `--hit-target-min` (`2.75rem` / 44px) and `--hit-target-inline-min` (`1.5rem` / 24px), plus kit classes `.fp-hit-target` and `.fp-hit-target-inline`. Icon-only buttons, modal close, and alert/toast dismiss use 44px. Chip and badge remove use 24px so chips do not grow to 44px.
- `:root { color-scheme: light; }` and `[data-theme="dark"] { color-scheme: dark; }` so native controls follow the theme.

### Changed
- Icon-only `Button` requires `text:` (used as `aria-label`, not shown) or `aria: { label: "…" }`. Missing a name raises `ArgumentError`. Loading icon-only keeps the name and sets `aria-busy="true"`.
- Button schemes that already have a rest shadow now use `--button-shadow-hover` (`--shadow-button`) and `--button-shadow-active` (`--shadow-button-active`) on hover and press. Ghost and secondary stay unshadowed at rest. Colour, border, and shadow transitions use `--duration-fast`.
- Dark `--shadow-sm` / `--shadow-md` / `--shadow-lg` add a faint white hairline so elevation reads on near-black.
- `--switch-error-color` now aliases `--color-error` instead of `--color-warning`.
- Bumped the gem version to `0.1.150`.

### Upgrade notes
- Icon-only `FlatPack::Button::Component` without `text:` or `aria: { label: }` now raises. Pass a name. `text:` on an icon-only button is the accessible name and is not rendered as visible copy.
- Invalid form borders and messages are danger red (`--color-error`), not warning amber. Override `--color-error` if you need a different invalid colour. Warning chips, alerts, and buttons are unchanged.
- Rebuild host Tailwind so `hover:shadow-[var(--button-shadow-hover)]`, `active:shadow-[var(--button-shadow-active)]`, and `duration-[var(--duration-fast)]` are generated. `.fp-hit-target` / `.fp-hit-target-inline` come from kit `flat_pack/application` CSS and do not need a Tailwind rebuild.

## [0.1.149] - 2026-09-04

### Changed
- Under `prefers-reduced-motion: reduce`, `--duration-fast`, `--duration-base`, `--duration-slow`, and `--skeleton-shimmer-duration` collapse to `0ms`. Overlay Stimulus controllers share `controllers/flat_pack/reduced_motion` so hide delays match those tokens.
- Modal, toast, alert, chip, badge, and dropdown skip scale and slide when motion is reduced. Toast and alert remove immediately. Button loading spinner uses `motion-reduce:animate-none`. Carousel autoplay already skipped.
- Bumped the gem version to `0.1.149`.

### Fixed
- `--duration-fast`, `--duration-base`, and `--duration-slow` are defined on `:root` (150ms / 200ms / 300ms), not only inside `@theme`. `var(--duration-*)` and the reduced-motion helper now resolve when `flat_pack/variables` is loaded as a normal stylesheet.

### Upgrade notes
- No host app API changes. Rebuild host Tailwind so `duration-[var(--duration-*)]` and `motion-reduce:*` utilities are generated. Colour hovers that still use Tailwind's built-in `duration-200` keep a short fade. Kit surfaces that move now follow `--duration-*`.

## [0.1.148] - 2026-09-04

### Added
- `FlatPack::Chat::Layout::Component` accepts `split_breakpoint:` (`:sm`, `:md`, `:lg`) to choose the width where a `:split` layout stops stacking, and `sidebar_width:` to size the sidebar column with any single CSS grid track (length, keyword, CSS variable, `minmax()`, `clamp()`, `fit-content()`).
- `FlatPack::AttributeSanitizer.sanitize_css_grid_track` validates a grid track before it is interpolated into a style attribute.
- Dummy `/demo/chat/layout` gained a "Sizing the split" section showing `split_breakpoint: :lg` with `sidebar_width: "minmax(12rem, 30%)"`.

### Changed
- `Chat::Layout` `:split` is now fluid instead of a fixed `280px` sidebar from `md`. Columns are `clamp(12rem, 30%, 16rem)` plus `minmax(0, 1fr)`, both carry `min-w-0`, and the split starts at `sm` (640px). A half-width or tiled desktop window (roughly 720–960px) stays a scaled two-column desk with a readable thread and an unclipped composer, rather than squeezing against the clipped root or collapsing to list-only. The sidebar is proportional so it yields on a narrow desk, which a plain `16rem` track does not: it holds its width and makes the thread absorb every reduction.
- `chat_layout_controller.js` reads a `breakpoint` value instead of hardcoding `768px`, so the stacked list-then-panel behaviour switches at the same width as the CSS.
- A `:single` layout with a sidebar slot keeps its bottom divider at every width instead of flipping to a right divider at `md`, which never matched the stacked single column.
- `Chat::InboxRow` inherits `List::Item` padding of `py-3 px-4` (12px / 16px), up from `py-2 px-3`. Every chat inbox that uses `InboxRow` picks this up, including `/demo/chat/demo`. Other `List::Item` rows use the same padding.
- `List::Item` rows, including `Chat::InboxRow`, now use `rounded-[var(--radius-sm)]` so the hover and active highlight has a small corner radius instead of a square block.

### Upgrade notes
- No changes required for hosts that render `Chat::Layout` with defaults; the split simply scales instead of collapsing. Recording Studio Messages desks in the core default layout do not need to fork the grid.
- To keep the old stacking point, pass `split_breakpoint: :md`. There is no way to restore the fixed `280px` track, because it is what broke half-width windows; pass `sidebar_width: "16rem"` if you want a fixed sidebar back, and expect the thread to absorb every reduction when the desk is narrow.
- `List::Item` padding is now `py-3 px-4`. Chat inbox rows and any other `List::Item` grow by 4px on each side. No host code change is required.

## [0.1.147] - 2026-09-04

### Added
- Tracked Cursor rules pack under `.cursor/rules/` for Cloud Agents (eight `.mdc` files). Cloud Agents load them from the checkout. See [Cursor Cloud Agent skills and rules](docs/cursor-skills.md).

### Changed
- `.cursor/rules/` is no longer gitignored.
- Bumped the gem version to `0.1.147`.

### Upgrade notes
- No host app API changes. Product UI is unchanged. After merge, rebuild the Cloud Agent environment Draft off `v0.1.147` so checkout rules load. A snapshot taken while rules were gitignored will not see them.

## [0.1.146] - 2026-09-04

### Changed
- Kit components and Stimulus controllers now use `rounded-[var(--radius-*)]` instead of Tailwind radius scale names (`rounded-md`, `rounded-lg`, `rounded-xl`, `rounded-2xl`). The four kit tokens stay `--radius-sm` (`0.75rem`), `--radius-md` (`1rem`), `--radius-lg` (`1.5rem`), `--radius-xl` (`2rem`). `rounded-2xl` maps to `--radius-md` (both `1rem`). Pills keep `rounded-full`. Segmented groups keep `rounded-none`.
- Rich text and content editor CSS fallbacks now use the kit radius values (`1rem` / `0.75rem`) instead of Tailwind's `0.375rem` / `0.25rem`.
- Added `FlatPack::RadiusLanguageAuditor`, `bin/rake flat_pack:audit_radius_language`, and `ruby scripts/rewrite_radius_language.rb`.
- Bumped the gem version to `0.1.146`.

### Upgrade notes
- No host app API changes. Rebuild host Tailwind so the new `rounded-[var(--radius-*)]` utilities are generated. If a host copied kit class names such as `rounded-lg` into its own markup, those classes are unchanged. For `sm` / `md` / `lg` / `xl`, both the old and new class names resolve to `var(--radius-*)`, so computed size matches unless a host overrode Tailwind's `--radius-2xl` independently of `--radius-md`. Chat bubbles that used `rounded-2xl` now read `--radius-md`.
- `Button` still skips its default radius when you pass a `rounded-*` class. Card and most other components last-win the kit token, so `class: "rounded-xl"` does not override them. That last-wins behavior is unchanged.

## [0.1.145] - 2026-09-04

### Added
- Tracked [pstack](https://github.com/cursor/plugins/tree/main/pstack/skills) under `.cursor/skills/` for Cloud Agents.
- Tracked Flatpack craft skills: third-party `frontend-design`, `design-dna`, `make-interfaces-feel-better`, `motion-design`, `review-animations`, `visual-qa-testing`, `web-design-guidelines`, plus `flatpack-design` and `flatpack-micro-interactions`. `flatpack-design` decides what lands. Design DNA `visual_effects` and Framer/GSAP/Lottie stay muzzled. See [Cursor Cloud Agent skills](docs/cursor-skills.md).

### Changed
- Removed the Build-time `.cursor/fetch-skills.sh` hook that pulled Recording Studio skills. `.cursor/environment.json` `install` is a no-op. `.cursor/skills/` is tracked. `.cursor/rules/` stays gitignored.
- Bumped the gem version to `0.1.145`.

### Upgrade notes
- No host app API changes. Product UI is unchanged. After merge, rebuild the Cloud Agent environment Draft off `v0.1.145` so checkout skills load. A snapshot taken while skills were gitignored will not see them.

## [0.1.144] - 2026-09-02

### Added
- `FlatPack::Avatar::Component` accepts optional `icon:` (same Heroicons name as Button). When there is no `src` and no initials, that icon renders instead of the person glyph. Omit `icon:` to keep today's person fallback. Image and initials still win.
- Dummy `/demo/avatars` Fallback Types shows a photo-icon empty on circle and square (`data-theme="rounded"`), next to the unchanged person glyph.
- Cloud Agent Build hook `.cursor/fetch-skills.sh` plus `.cursor/environment.json`. Fetched skills and plugin rules stay gitignored.

### Changed
- Bumped the gem version to `0.1.144`.

### Upgrade notes
- No host app changes required. To show a site mark instead of a person on an empty avatar, pass `icon: "photo"` (or another existing Heroicon name). Users profile empty initials are unchanged if the host still passes `name` or `initials`.

## [0.1.143] - 2026-08-29

### Fixed
- Bound leftover hardcoded blues / frozen chart chrome to existing theme tokens so they recolor with the active theme (default charcoal / rounded):
  - `EmailButton` primary fallback hex is now `#333333` (resolved from default `--color-primary`) with `var(--button-primary-*, var(--color-primary, …))` overrides — no `#2563eb` path.
  - Rich text focus / selection / link-input chrome uses `var(--color-ring)` / `var(--color-primary)` (and `color-mix` with those tokens) with no blue `oklch(0.52 0.26 250…)` fallbacks.
  - Donut ApexCharts tooltips use `--tooltip-background-color` / `--tooltip-text-color` (falling through to `--surface-background-color` / `--surface-content-color`) instead of frozen `#fff`.
- Geochart legend/tooltip `textStyle` hexes (`#334155` / `#111827`) left as map-specific Google Charts ink (not the same frozen-chrome class).

### Changed
- Bumped the gem version to `0.1.143`.

### Upgrade notes
- No host app API changes. After upgrading, rebuild / reload FlatPack stylesheets so email primary buttons, rich-text rings, and donut tooltips pick up theme tokens. Hosts that depended on the old EmailButton blue hex (`#2563eb`) when CSS variables are absent will now see charcoal (`#333333`); override `--button-primary-background-color` / `--color-primary` (or pass themed email CSS) for a custom brand color.

## [0.1.142] - 2026-08-29

### Added
- `FlatPack::Divider::Component` — full-width horizontal rule with optional muted centered `label` (for example `"Or"` between password submit and Continue with Google). Omit or blank `label` for a plain rule. Uses `--surface-border-color` and `--surface-muted-content-color` only.
- Dummy demo at `/demo/divider` (`data-theme="rounded"`) showing a plain rule, a labeled rule, and a login/register-style composition.
- Divider docs, method/variables table, and component index entries.

### Changed
- Bumped the gem version to `0.1.142`.

### Upgrade notes
- No host app changes required. Compose with `<%= render FlatPack::Divider::Component.new(label: "Or") %>` or without `label` for a plain rule. Prefer this over ad-hoc borders or `Chat::DateDivider` outside chat lists.

## [0.1.141] - 2026-08-29

### Added
- `FlatPack::OverflowRow::Component` — one horizontal row for same-size items (for example ColorSwatch + FontSwatch). Never wraps; when children overflow it scrolls sideways with a hidden scrollbar, a soft trailing fade while more content remains to the right, and a natural peek of the next item. Optional `gap:` (`:sm` / `:md` / `:lg`) maps to stack gap tokens.
- Dummy demo at `/demo/overflow_row` (`data-theme="rounded"`) with a short fitting row and a long overflowing row.
- Overflow Row docs, method/variables table, and `--overflow-row-gap` / `--overflow-row-fade-size` theme tokens.
- Stimulus controller `flat-pack--overflow-row` toggles `data-can-scroll-end` for the fade.

### Changed
- Bumped the gem version to `0.1.141`.

### Upgrade notes
- No host app changes required. Compose children inside `FlatPack::OverflowRow::Component.new(gap: :md)` instead of `flex-wrap` when you want one row that scrolls only on overflow. Theme the fade length with `--overflow-row-fade-size` and the default gap with `--overflow-row-gap`.

## [0.1.140] - 2026-08-29

### Changed
- Internal DRY for form-control chrome: TextInput, EmailInput, PhoneInput, UrlInput, NumberInput, PasswordInput, SearchInput, TextArea, Select, DateInput, TimeInput, and DateTimeInput now compose a shared internal `FlatPack::FormField::Component` for the label / help_text / error wrapper stack, and share box classes via `FlatPack::FormField::ControlStyles` (still using `--form-control-padding` and related tokens). Hosts keep calling the same public input components with the same kwargs — no new public FormField API to adopt.
- Bumped the gem version to `0.1.140`.

### Upgrade notes
- No host app changes required. Public initialize kwargs and rendered chrome are unchanged; this is an internal refactor only.

## [0.1.139] - 2026-08-29

### Fixed
- `rails generate flat_pack:layout` now writes a real host shell layout (`sidebar_layout.html.erb.tt` was empty). The scaffold composes `SidebarLayout` with the generated sidebar/top-nav partials, sets `data-theme="rounded"`, and includes the FlatPack stylesheet tags plus importmap.
- Install generator Next Steps Button example uses `text:` / `style:` (not the dead `label:` / `scheme:` API).
- Install generator `show_next_steps` is public again so Next Steps actually print after `flat_pack:install` (it was unreachable under `private`).

### Changed
- `docs/installation.md` no longer hardcodes a `Current Version:` stamp; readers are pointed at `FlatPack::VERSION` / `lib/flat_pack/version.rb` and `docs/ai/install_contract.json`.
- Documented `--as_root` on `flat_pack:theme` in installation and theming docs (writes brand overrides on `:root` so no `data-theme` is required).
- Bumped the gem version to `0.1.139`.

### Upgrade notes
- No host app changes required for existing installs. Re-run `bin/rails generate flat_pack:layout` if you previously generated an empty layout file, or replace that layout with the new scaffold contents from the generator template.

## [0.1.138] - 2026-08-29

### Added
- `FlatPack::FontSwatch::Component` — circular font sample control with `font:`, host-provided `options:`, optional `text:` tooltip, optional `selected:` ring, ColorSwatch-scale sizes (`:xs`–`:lg`), and a FlatPack Popover menu on circle click (not a native `<select>`, not `FlatPack::Picker`). Each menu row shows `Aa` + the font name in that face; choosing a row updates a hidden input for form save.
- Dummy demo at `/demo/font_swatches` (Feedback catalog) with a FontSwatch and a composed ColorSwatch + FontSwatch row. Demo fonts are a small generic set (ui-sans-serif, ui-serif, ui-monospace, Georgia) — hosts pass their own option list.
- Font Swatch docs, method/variables table, and `--font-swatch-*` theme tokens (including dark/ocean via semantic `var()` references).
- `AttributeSanitizer.sanitize_css_font_family` for safe font-family style interpolation.

### Changed
- Bumped the gem version to `0.1.138`.

### Upgrade notes
- No host app changes required. Compose `FlatPack::FontSwatch::Component` with required `font:` and `options:` (`[[label, value], …]`), optional form `name:` (hidden input), optional `text:` for tooltip/accessible name (defaults to the selected option label), and `selected:` for the live ring in a row. Arrange rows with flex + kit gap tokens — do not wrap swatches in `ChipGroup`, and do not wrap FontSwatch in another Popover (it composes Popover internally).

## [0.1.137] - 2026-08-29

### Changed
- Kit default theme is now the former `rounded` look: charcoal/monochrome primaries, larger radii, softer shadows. Hosts with no `data-theme` get charcoal primary buttons instead of the previous purple-blue brand (`--brand-hue: 250`).
- `[data-theme="rounded"]` remains as an explicit alias of that default (same semantic values).
- `[data-theme="dark"]` and `[data-theme="ocean"]` are unchanged override themes.
- Bumped the gem version to `0.1.137`.

### Upgrade notes
- If you relied on the previous purple-blue default without setting `data-theme`, primary CTAs and kit surfaces will now look like today's `rounded` theme. No action needed if you already set `data-theme="rounded"` (Recording Studio style) — the look stays the same.
- To keep a purple-blue (or any other) brand on `:root`, override `--brand-hue` / `--brand-chroma` / `--brand-lightness` and/or `--color-primary` / `--color-primary-hover` in a host stylesheet loaded after `flat_pack/variables`, or generate a named theme with `bin/rails generate flat_pack:theme …`.
- Named themes (`dark`, `ocean`, custom) continue to work via `data-theme`.

## [0.1.136] - 2026-08-28

### Added
- `FlatPack::ColorSwatch::Component` — circular named colour control with `color:`, optional `text:` tooltip, optional `selected:` ring, native `<input type="color">` on circle click (no intermediate panel), and Avatar-scale sizes (`:xs`–`:lg`).
- Dummy demo at `/demo/color_swatches` (Feedback catalog) with a flex row of named swatches (Background / Text / Accent). Click a circle to open the OS/browser colour dialog.
- Color Swatch docs, method/variables table, and `--color-swatch-*` theme tokens.

### Changed
- Bumped the gem version to `0.1.136`.

### Upgrade notes
- No host app changes required. Compose `FlatPack::ColorSwatch::Component` with required `color:`, optional form `name:`, optional `text:` for tooltip/accessible name, and `selected:` for the live ring in a row. Prefer `#rrggbb` hex for the native picker. Arrange rows with flex + kit gap tokens — do not wrap swatches in `ChipGroup`.

## [0.1.135] - 2026-08-28

### Added
- `FlatPack::Avatar::Component` accepts `size: :"2xl"` (`h-24 w-24`, 6rem) for larger profile photos on edit pages.

### Changed
- Dummy demo pages that use the shared Related demos partial now render that block at the bottom of the page (after component examples and Theme Tokens).
- Dummy full-page cache keys also track `app/views/shared/**` so Related demos partial edits bust cached HTML.

### Fixed

## [0.1.134] - 2026-08-19

### Added
- Presentational `FlatPack::Billing::*` components: Plan Summary, Plan Picker, Usage Meter, Payment Method, Invoice List, and Status Alert.
- Dummy demo family under `/demo/billing` with expandable sidebar group and top-nav search entries.
- Billing component docs and method/variables tables for the dummy demos.
- `FlatPack::Progress::Component` accepts `label_visible:` to keep `label` as the `aria-label` while hiding the visible line, for use inside components that already show the name.

### Changed
- Bumped the gem version to `0.1.134`.
- `/demo/billing` uses anchor-linked sections and the shared Related demos block instead of a component tab switcher, matching the buttons demo layout.

### Fixed
- Usage Meter no longer prints its label twice above the progress bar.

### Upgrade notes
- No host app changes required. Compose the new billing components with host-supplied display strings and `href`s; FlatPack still does not collect card numbers or call payment providers.

## [0.1.133] - 2026-08-18

### Added
- `FlatPack::Search::Component` accepts `items:` for instant client-side filtering of static catalogs.
- Dummy demo catalog (`DemoCatalog`) now drives sidebar navigation and top-nav search from one source.
- Dummy `/demo/search` now shows local `items:` first, then remote `search_url`.

### Changed
- Dummy top-nav search filters the demo catalog in the browser instead of waiting on `/demo/search_results` for every keystroke.
- Dummy top-nav search ranks title matches above description matches, so "form" prefers Forms over Tables ("formatting").
- Dummy search, top-nav, and split-family demo pages document the current catalog and related routes.
- Reorganized long dummy demo pages into focused routes:
  - Collapse and Accordion are separate pages
  - Buttons family split into Buttons, Links, Pills, Segmented, Groups, and Dropdowns
  - Charts split into Overview, Types, Composition, and Setup
  - Cards split into Overview, Styles, Media, and Composed
  - Avatar Groups and Chip Groups have their own pages
- Legacy `/demo/inputs` now redirects to `/demo/forms`
- Bumped the gem version to `0.1.133`.

### Fixed
- Search icon sits optically in the middle of the field (the glass handle was making it look low).
- Icons render as `block` so they no longer pick up a text-baseline gap.
- Magnifying-glass icons are optically nudged on `IconComponent`, so Search, Picker, and buttons share the same alignment.

### Upgrade notes
- For static search lists, pass `items:` (`[{ title:, description:, url: }, ...]`) to `FlatPack::Search::Component`. Remote `search_url` still works when results must come from the server.
- `FlatPack::Shared::IconComponent` now uses `block` instead of `inline-block`. If an icon was sitting in inline text without a flex parent, wrap the row in `inline-flex items-center`.
- To optically align another handle-heavy Heroicon, add its canonical name to `IconComponent::OPTICAL_NUDGES` instead of component CSS.

## [0.1.132] - 2026-08-18

### Added
- Added brand primitives `--brand-hue`, `--brand-chroma`, and `--brand-lightness` so recoloring primary starts from the OKLCH triad. Hover is `calc(var(--brand-lightness) - 0.10)`. Exact hex still overrides `--color-primary`.
- Added `rails generate flat_pack:theme NAME` to scaffold a host-app brand override stylesheet.
- Added `bin/rake flat_pack:audit_tokens` and `FlatPack::TokenAuditor` to fail when referenced CSS variables are missing from `variables.css`.
- Added `--surface-subtle-background-color` and `--transition-*` aliases for `--duration-*`.
- Install generator now links `flat_pack/application` alongside `variables` and `rich_text`.
- Added `FlatPack::Tiptap::VERSION` as the single TipTap pin source for the gem importmap and install generator.
- Added `scripts/regenerate_theme_tokens.py` to rebuild slim theme override blocks from a full token source.

### Changed
- Streamlined `variables.css`: component tokens map to semantic tokens once on `:root`; named themes (`dark`, `ocean`, `rounded`) only declare overrides (~2.3k → ~1.1k lines).
- Install Tailwind scaffold now only injects `@source` for FlatPack components. Host apps no longer get a parallel `--color-fp-*` token fork.
- Dummy `/themes` pages and markdown (README, install, theming, architecture) now describe the brand → semantic → component-alias hierarchy instead of copying a host `@theme` fork.
- Documented shared `:root` names (`--color-primary`, `--radius-md`) and updated the install Tailwind comment so host apps keep a separate `--my-app-primary` when FlatPack must not reuse `--color-primary`. Do not rename FlatPack tokens.
- Notification unread badges use `--color-danger-*` tokens instead of `bg-red-600`.
- Bumped the gem version to `0.1.132`.

### Fixed
- TipTap CDN pins from the install generator no longer drift from the gem importmap version.
- Missing subtle-surface and transition token aliases used by components/docs.

### Upgrade notes
- **Re-run `bin/rails generate flat_pack:install`** (or manually add `stylesheet_link_tag "flat_pack/application"` and refresh the Tailwind `@source`). Then run `bin/rails tailwindcss:build` and `bin/rake flat_pack:verify_install`.
- **Remove host-app `--color-fp-*` / `:root` remaps** that the old install scaffold injected into your Tailwind entry. Tokens load from `flat_pack/variables`. Override with `--brand-hue` / `--brand-chroma` / `--brand-lightness` or `rails g flat_pack:theme …`. For an exact brand hex, set `--color-primary` / `--color-primary-hover`.
- **Custom themes:** prefer overriding brand/semantic tokens only. Re-copying the full component token list is no longer required for color changes.
- TipTap pins created by an older install may still say `2.11.5`. Update `TIPTAP_VERSION` in `config/importmap.rb` to `FlatPack::Tiptap::VERSION` (`2.27.2`) or re-run install.

## [0.1.131] - 2026-08-18

### Added
- Added a mobile chevron menu to `FlatPack::TopNav::Component`. Below `mobile_breakpoint` (default `768`), collapsible slot content moves into a right-aligned menu panel opened by a chevron-down toggle and returns to the bar on wider viewports. Content is relocated rather than duplicated, so ids, listeners, and nested Stimulus controllers keep working.
- Added `always_display:` to the TopNav `left`, `center`, and `right` slots, plus a `data-flat-pack-top-nav-always-display="true"` escape hatch for keeping individual elements in the bar while the rest of their section collapses.
- Added `mobile_menu`, `mobile_menu_label`, and `mobile_breakpoint` options to `FlatPack::TopNav::Component`.
- Added the `flat-pack--top-nav` Stimulus controller that drives the mobile chevron menu, including `Escape`, outside-click, and in-menu link dismissal.
- Added a 180° rotation to the TopNav mobile chevron toggle while the menu is open, driven by the `flat-pack--top-nav-toggle-open-class` Stimulus class (`[&>svg]:rotate-180` by default).
- Added `min_width` to `FlatPack::Table::Component` (`:none`, `:sm`, `:md`, `:lg`, or a Tailwind `min-w-*` class String).
- Added `wrap` to `FlatPack::CodeBlock::Component` for opting back into soft-wrapped code.

### Changed
- Bumped the gem version to `0.1.131`.
- `FlatPack::Table::Component` now applies a `40rem` minimum table width by default so the existing `overflow-x-auto` wrapper scrolls on narrow viewports instead of squashing columns.
- `FlatPack::CodeBlock::Component` now scrolls long lines horizontally (`overflow-x-auto whitespace-pre`) instead of soft wrapping them, which previously split identifiers mid-token.
- Dummy app button demo rows now use the mobile horizontal scroll container pattern (`overflow-x-auto pb-2 md:overflow-visible md:pb-0`) so every style variant stays reachable at 390px.

### Fixed
- Fixed the crowded mobile top nav where the search field, theme control, and notification button were compressed into an unusable row at narrow widths.
- Fixed clipped button examples on the dummy app buttons demo where non-wrapping example rows cut off the Success, Warning, and Danger variants on mobile.

### Upgrade notes
- **TopNav gains a mobile chevron menu by default.** `center` and `right` slot content now collapses below `768px`; `left` stays inline. The toggle uses a chevron-down icon. To keep the previous always-inline layout, pass `mobile_menu: false`, or mark sections with `always_display: true`. Host apps that already implement their own responsive top bar should pass `mobile_menu: false` to avoid two competing mechanisms.
- **TopNav now requires the `flat-pack--top-nav` Stimulus controller.** It ships through the engine importmap; apps that pin FlatPack controllers manually should confirm `controllers/flat_pack/top_nav_controller` resolves. Without JavaScript, TopNav renders exactly as before (no chevron toggle appears).
- **Tables now have a default minimum width of `40rem`.** Tables placed in narrow desktop containers (sidebars, cards, split panes) will scroll horizontally where they previously squashed. Pass `min_width: :none` to restore the old behavior, or `min_width: :sm`/`:lg`/a custom `min-w-*` class to tune it.
- **Code blocks no longer soft wrap.** Long lines scroll horizontally instead. Pass `wrap: true` to restore wrapping where a fixed-height, non-scrolling block is required.

## [0.1.130] - 2026-08-17

### Added
- Added `docs/components/PARAMS.md` as the canonical cross-component param naming guide.

### Changed
- Bumped the gem version to `0.1.130`.
- Standardized shared component param names. This gem is unreleased, so old names were removed rather than aliased.
- Updated development lockfiles to patched `rails` (`8.1.3.1` / `7.2.3.2`), `json` `2.21.2`, and `sqlite3` `2.9.6`.

#### Upgrade notes

Use these names everywhere the same concept appears:

- Color / semantic appearance: `style` (not `variant`, `type`, or `scheme`)
- Navigation destination: `href` (not `url`)
- Compact visible copy: `text` (not `label` or `message`)
- Overlay position: `placement` (not `position`)
- Extra CSS: `class` (not `class_name`)
- Action button copy: `*_label` (not `*_text`)
- Empty-state copy: `empty_text` or `empty_title` / `empty_description`
- Open / closed start state: `open` (not `default_open`)
- Data / form endpoints stay `*_url`

Renames:

| Component | Old | New |
| --- | --- | --- |
| `Button`, `ChartButtons#button` | `url` | `href` |
| `PageNav` | `anchor_url`, `secondary_anchor_url` | `anchor_href`, `secondary_anchor_href` |
| `Breadcrumb` | `home_url`, `back_fallback_url` | `home_href`, `back_fallback_href` |
| `Progress`, `EmailButton`, `Toast`, `Sidebar::Badge`, `Timeline::Item` | `variant` / `type` / `status` | `style` |
| `EmailButton`, `Sidebar::Item`, `BottomNav::Item` | `label` | `text` |
| `Toast` | `message` | `text` |
| `Button::Dropdown`, `ChartButtons#dropdown` | `position` | `placement` |
| `Timestamp` | `class_name` | `class` |
| `Picker` | `confirm_text`, `close_text`, `empty_state_text` | `confirm_label`, `close_label`, `empty_text` |
| `Notification` | `empty_message` | `empty_text` |
| `Comments::Thread` | `empty_body` | `empty_description` |
| `List` | `orderable_path` | `orderable_url` |
| `Sidebar::SectionTitle`, `Sidebar::Group` | `label` | `title` |
| `Sidebar::Group`, `SidebarLayout` | `default_open` | `open` |
| `ChartButtons` | `control_size` | `size` |

The `toast:add` event now uses `{ style, text }` instead of `{ type, message }`. Stimulus values follow the same names (`placement`, `orderableUrl`, `emptyText`, `open`).

Keep `variant` for structural/layout choices such as Hero, Tabs, Carousel, Page Title heading level, Comments Thread spacing, Skeleton shape, and Chat Layout. `Timeline::Item` no longer accepts `status` as an alias for color.

### Fixed

## [0.1.123] - 2026-07-27

### Added
- Added notification rollup support to `FlatPack::Notification::Component` with `notification[:rollup]` and `notification[:children]`, including single-open expand/collapse behavior, caret indicators, and nested child rendering.
- Added email-safe reusable components: `FlatPack::EmailCard::Component`, `FlatPack::EmailButton::Component`, and `FlatPack::EmailFooterLinks::Component`, plus `FlatPack::EmailTemplateExample::Component` composition coverage, docs, and tests.
- Added dummy app email demo pages for `EmailButton`, `EmailCard`, `EmailFooterLinks`, and `EmailTemplateExample`, including dedicated sidebar navigation links.

### Changed
- Bumped the gem version to `0.1.123`.
- Updated rollup notifications in `FlatPack::Notification::Component` to render a red unread-children counter badge on rollup parent icons (capped at `9+`) instead of the unread red dot.
- Synchronized release metadata, documentation indexes, and Rails 7/8 dummy app lockfiles.
- State and focus rings now use `ring-inset` to prevent clipping in overflow contexts.
- Reorganized dummy app navigation to include a dedicated **Email** sidebar section for all newly added email components.

### Fixed
- Updated the `fp-red-dot` utility to render reliably on SVG icons by appending a foreground SVG dot indicator with `z-index: 999999999`.
- Synchronized the dummy app's vendored Select component so modal-filter demo controls use inset focus rings.

## [0.1.122] - 2026-07-10

### Added
- Added the `fp-red-dot` SVG utility class that renders a top-right danger-status dot via `::after` with `8px` size and `z-index: 999`.

### Changed
- Bumped the gem version to `0.1.122`.

### Fixed

## [0.1.121] - 2026-07-09

### Added

### Changed
- Bumped the gem version to `0.1.121`.
- Updated nested `FlatPack::Select::Component` option row styling to use `rounded-none` instead of `rounded-sm`.

### Fixed
- Synchronized release metadata, docs contracts, and dummy app lockfiles with version `0.1.121`.

## [0.1.120] - 2026-07-09

### Added

### Changed
- Bumped the gem version to `0.1.120`.
- Updated `FlatPack::Select::Component` multi-select option styling so selected rows keep neutral text and rely on checkbox state instead of selected highlight backgrounds.

### Fixed
- Updated Select Stimulus selected-state class toggling so multi-select rows in `/demo/forms/select` no longer apply primary selected background/text classes when selected.

## [0.1.119] - 2026-07-09

### Added
- Added `secondary_anchor_url` and tooltip-specific options to `FlatPack::PageNav::Component`, including Tooltip wrapping and compatibility fallbacks for deprecated label options.

### Changed
- Bumped the gem version to `0.1.119`.
- Updated Page Nav docs with tooltip prop migration guidance.
- Updated the Page Nav action wrapper to use `flex gap-2` for back, secondary anchor, and anchor button layouts.
- Moved the Page Nav `right_slot` into its own right-aligned wrapper so secondary and primary anchors stay grouped separately from custom right-side actions.

### Fixed
- Preserved Page Nav accessible labels when new tooltip props are blank and when secondary anchors omit tooltip text.

## [0.1.118] - 2026-07-09

### Added
- Added nested multiselect support to `FlatPack::Select::Component`, including parent/child selection syncing, indeterminate parent states, ordered hidden inputs, docs, dummy examples, and JavaScript/Ruby coverage.

### Changed
- Bumped the gem version to `0.1.118`.
- Marked the legacy nested multiselect controller docs as deprecated for new usage in favor of Select nested options.

### Fixed

## [0.1.117] - 2026-07-08

### Added
- Added `:stacked_bar` and `:stacked_column` support to `FlatPack::Chart::Component`, including dummy app examples, docs, and tests.
- Added `shorten_timestamp:` support to `FlatPack::Timestamp::Component` and enabled compact timestamp labels in notifications.

### Changed
- Bumped the gem version to `0.1.117`.
- Updated the Timestamp and Local Time demos to compare unshortened and shortened relative time labels in tables.

### Fixed
- Updated `FlatPack::Chart::Component` bar/column defaults to use a dark tooltip theme so column hover popups render with dark backgrounds instead of white.

## [0.1.116] - 2026-07-08

### Added
- Added a reusable nested multiselect Stimulus controller with parent/child checkbox state syncing, indeterminate parent states, initial selected values, and hidden form input generation.
- Added a dummy app nested multiselect demo page under `/demo/forms/nested_multiselect` with sidebar navigation.

### Changed
- Bumped the gem version to `0.1.116` and synchronized release metadata across docs, the AI install contract, vendored engine snapshot, and dummy app lockfiles.

### Fixed

## [0.1.115] - 2026-07-07

### Added
- Added plain-text `help_text:` support across FlatPack form inputs, including muted helper rendering, `aria-describedby` wiring, docs, tests, and dummy `/demo/forms` plus `/demo/inputs` examples.

### Changed
- Bumped the gem version to `0.1.115` and synchronized release metadata across docs, the AI install contract, and dummy app lockfiles.

### Fixed
- Kept TextArea help text margin-free while preserving helper rendering and `aria-describedby` coverage.

## [0.1.113] - 2026-07-07

### Added

### Changed
- Updated `FlatPack::DateRangeInput::Component` and custom picker quick presets to include `Last 4 weeks` between `Last week` and `This month`, with matching Stimulus date-range computation.

### Fixed
- Updated `FlatPack::Search::Component` live-results dropdown wrapper to include `overflow-hidden`, preserving rounded-corner clipping for dropdown content.
- Updated Rounded theme primary token to `oklch(0.3211 0 0)`.
- Fixed `FlatPack::Chart::Component` GeoChart rendering so Google GeoChart receives normalized RGB/RGBA color strings instead of unsupported modern CSS color syntax (for example OKLCH/color-mix), preventing invalid color errors in theme-driven demos.

## [0.1.112] - 2026-07-03

### Added

### Changed
- Bumped the gem version to `0.1.112` and synchronized release metadata across root docs.
- Refreshed `test/dummy` vendored FlatPack snapshot and aligned dummy lockfiles with the current branch state.

### Fixed

## [0.1.111] - 2026-07-03

### Added
- Added `FlatPack::Notification::Component` with unread badges, popover notification lists, timestamp composition, docs, tests, and a dummy demo page.

### Changed

### Fixed

## [0.1.110] - 2026-07-03

### Added
- Added a `flat_pack/local_time` JavaScript module for enhancing `time.local-time` elements with local and relative time rendering, plus a dummy `/demo/local_time` page.

### Changed
- Moved the local time demo into the shared Pages demo structure at `/demo/local_time`, removed the standalone `/local-time-demo` route/page, and added a `Local Time` sidebar entry directly below `Timestamp`.

### Fixed

## [0.1.109] - 2026-07-07

### Added

### Changed
- Updated `FlatPack::DateRangeInput::Component` and custom picker quick presets to include `Last 4 weeks` between `Last week` and `This month`, with matching Stimulus date-range computation.

### Fixed
- Updated `FlatPack::Search::Component` live-results dropdown wrapper to include `overflow-hidden`, preserving rounded-corner clipping for dropdown content.
- Updated Rounded theme primary token to `oklch(0.3211 0 0)`.
- Fixed `FlatPack::Chart::Component` GeoChart rendering so Google GeoChart receives normalized RGB/RGBA color strings instead of unsupported modern CSS color syntax (for example OKLCH/color-mix), preventing invalid color errors in theme-driven demos.

## [0.1.108] - 2026-07-03

### Added

### Changed

### Fixed
- Fixed chat demo mobile layouts to open sidebar-first with panel back navigation, corrected message list scrolling/flex overflow, improved dark-mode attachment contrast, and aligned composer control heights.
- Fixed chat composer demo `+` attachment trigger sizing to render a strict 1:1 square control.
- Fixed `FlatPack::Button::Dropdown::Component` trigger class merge order so `trigger_attributes[:class]` can override default size padding classes (for example `p-0` without inherited `px/py`).

## [0.1.106] - 2026-06-18

### Added
- Added `type: :geochart` support to `FlatPack::Chart::Component`, rendering Google GeoChart region maps with FlatPack defaults and a `/demo/charts` example.

### Changed

### Fixed

## [0.1.105] - 2026-06-18

### Added

### Changed

### Fixed
- Fixed `FlatPack::DateRangeInput::Component` so calendar-selected ranges that exactly match a quick preset, such as yesterday, display the preset label after Apply.
- Fixed donut chart tooltip contrast in the Rounded theme by forcing a white tooltip surface and primary-color hovered tooltip text.
- Fixed `FlatPack::Avatar::Component` so boolean-like `show_tooltip` values such as `"false"` suppress the automatic tooltip, and documented the tooltip options with examples.

## [0.1.103] - 2026-06-16

### Added
- Added `FlatPack::ModalFilter::Component` for modal-only filtering with a dedicated `filter_body` slot and a `Filter {count}` trigger badge when `active_count > 0`.
- Added optional `quick_copy` support to plain `FlatPack::TextArea::Component` mode, including click-to-copy on the textarea, a trailing copy icon button, and toast feedback (rich text mode excluded).
- Added first-class gauge support to `FlatPack::Chart::Component` via `type: :gauge`, mapped to ApexCharts `radialBar` with rounded arc ends and primary-color shaded defaults.

### Changed
- Updated `FlatPack::Sidebar::Header::Component` to render a compact `v{gem_version}` badge beside the `FlatPack` title in the sidebar header.
- Renamed `FlatPack::MinimizedFilters::Component` to `FlatPack::ModalFilter::Component` with no backward compatibility alias, including demo docs/tests and `/demo/modal_filter` naming.
- Updated `FlatPack::Chart::DefaultFilterComponent` to replace `responsive`/`responsive_options` with `minimized`/`minimized_options`, preserving desktop inline auto-submit filters while using `FlatPack::ModalFilter::Component` for mobile modal flows.
- Updated `/demo/charts/default_filter` and `/demo/tables/basic` to use minimized filter patterns (desktop inline + mobile modal trigger).
- Updated the inline minimized filter demo trigger to use the larger `lg` button size for the `Filter {count}` action.
- Updated `FlatPack::Chart::Component` default series palette to derive from `--color-primary` using descending opacity steps `100%`, `90%`, `70%`, `50%`, `30%`, and `10%`, added a dedicated opacity ramp for multi-series area chart lines (`100%`, `85%`, `70%`, `55%`, `40%`, `25%`) with `10%` primary area fill, and preserved caller-provided `options[:colors]` values when present.
- Removed `/demo/responsive_filter` route/page and migrated Data Display navigation to `Modal Filter` only.
- Removed `FlatPack::ResponsiveFilters::Component` and its dedicated docs/tests in favor of minimized filter composition.

### Fixed
- Updated `/demo/forms/date_input` so the `Billing Anchor Date` example uses the browser native date input (`picker: :native`) instead of the FlatPack popup picker.
- Updated `FlatPack::RangeInput::Component` to apply `--color-primary` to the slider accent/handle so range dots follow active theme primary color instead of browser default blue.

## [0.1.95] - 2026-06-15

### Changed
- Updated `FlatPack::DateRangeInput::Component` so quick preset selections (for example `Last week`) display preset labels in the visible trigger, while custom calendar selections continue to display explicit date ranges.
- Updated `FlatPack::ResponsiveFilters::Component` mobile trigger count badge to use `size: :xs`.
- Added `:xs` size support to `FlatPack::Badge::Component`, including docs and component test coverage.
- Added `FlatPack::ResponsiveFilters::Component` to provide a shared responsive filter surface with desktop inline controls and a mobile `Filter {count}` modal trigger.
- Updated `FlatPack::Chart::DefaultFilterComponent` with opt-in responsive rendering (`responsive: true`) powered by `responsive_options`, so chart default filters can render desktop inline + mobile modal flows directly.
- Updated `/demo/charts/default_filter` to use `FlatPack::Chart::DefaultFilterComponent` in responsive mode so desktop keeps inline auto-submit controls while mobile uses an Apply-based modal flow.
- Added `/demo/responsive_filter` and a Data Display sidebar link above Tables to demonstrate responsive filter patterns with one chart example and one table example, including variable reference and code snippets.
- Updated `/demo/tables/basic` generic filter demo to use responsive filters with the same table result surface across desktop and mobile.
- Updated `FlatPack::TopNav::Component` to always render left, center, and right wrappers even when a slot is uninitialized/blank, preserving stable horizontal positioning; added regression tests and blank-slot documentation examples.
- Updated `FlatPack::Timestamp::Component` future relative copy from `X from now` to `In X` while preserving `X ago` for past timestamps.
- Updated tooltip-related examples to stop using `cursor-help` by default, aligned tooltip demo code snippets with rendered examples, and removed default `cursor-help` styling from `FlatPack::Timestamp::Component` output.
- Updated `FlatPack::Table::Column::Component` sortable header links to render a `Sort` tooltip on hover/focus via `FlatPack::Tooltip::Component`.
- Updated `/demo/forms/select` examples so searchable select dropdown menus are not clipped by card body overflow.
- Added `hide_labels` to `FlatPack::Chart::DefaultFilterComponent` so date range and status labels can be omitted in compact filter rows.
- Renamed `FlatPack::Carousel::Component` option `quick_preview` to `side_preview` with no backward compatibility alias, including Stimulus values, tests, and docs.

### Fixed
- Updated `FlatPack::Picker` selection indicator utility classes to use the canonical `--color-primary` theme token instead of `--primary-color`, preventing missing primary token styling in host apps.

## [0.1.84] - 2026-06-10

### Added
- Added `FlatPack::DateRangeInput::Component` as a standalone date-range form component with quick presets and calendar selection.
- Added a new `/demo/charts` example that renders mini sparkline-style charts inside a `FlatPack::Table::Component` activity column for repository-style rows.
- Added optional `quick_copy` support to `FlatPack::TextInput::Component`, including click-to-copy on the input, a trailing copy icon button, and toast feedback.
- Added `FlatPack::Timestamp::Component` for relative time rendering with automatic `ago`/`from now` copy and a hover tooltip that localizes the absolute timestamp in the browser timezone.

### Changed
- Updated `FlatPack::Chart::DefaultFilterComponent` to use `FlatPack::DateRangeInput::Component` for date-range controls.
- Removed DateInput range-mode usage from demos and docs in favor of the standalone DateRangeInput component.
- Corrected chart type naming so `type: :column` renders vertical columns and `type: :bar` renders horizontal bars, with updated chart defaults, demos, tests, and docs.
- Updated `FlatPack::Carousel::Component` with configurable default-variant `items_per_view_*` options and a `side_preview` mode to reveal 25% of the next slide, including docs/tests and a five-chart demo example.
- Wrapped each chart in the carousel quick preview demo inside an elevated `FlatPack::Card::Component` body slot.
- Added `controls_on_hover` to `FlatPack::Carousel::Component` so previous/next controls can stay hidden until hover/focus on larger screens while remaining visible on mobile.
- Renamed the Carousel logo variant from `:logo_cloud` to `:logo_slider` with no compatibility alias.
- Updated carousel component internals, Stimulus variant detection, tests, docs, and dummy demos to use the new Logo Slider naming.
- Standardized destructive variants on `:danger` for Button and Toast APIs (replacing previous `:error` usage), and updated source, vendored dummy mirror, tests, demos, and docs accordingly.
- Updated default danger semantic tokens to Tailwind red (`red-600` base and `red-700` hover) across built-in FlatPack themes.
- Updated chart and table component docs with guidance for embedding compact sparkline-style charts in table cells using `card: false` and sparkline options.

## [0.1.74] - 2026-06-04

### Changed
- Updated dummy page copy for slot-based APIs so component demo headings/subtitles now consistently say "slots" instead of "actions" where applicable.
- Added `--comments-composer-slots-background-color` as a new token alias backed by `--comments-composer-actions-background-color` to keep theming backward compatible during slot naming migration.

## [0.1.73] - 2026-06-04

### Changed
- Updated `FlatPack::Chart::Component` to prefer `top_right_slot` over `actions` for header action content while keeping `actions` as a deprecated compatibility alias.
- Updated `FlatPack::PageTitle::Component`, `FlatPack::EmptyState::Component`, `FlatPack::Hero::Component`, and `FlatPack::Comments::Composer::Component` to prefer `slot` over `actions` while keeping `actions` as a deprecated compatibility alias.
- Updated component docs and dummy app examples to use the new preferred slot method names and document the deprecated aliases.

## [0.1.72] - 2026-06-04

### Added
- Added `FlatPack::Chart::DefaultFilterComponent` to provide a reusable chart filter row with DateInput range selection (`start_date`/`end_date` defaults) and a status dropdown powered by Select options.
- Added `picker: :flatpack_date_picker` support to `FlatPack::DateInput::Component` with a custom popup layout that combines quick range presets and calendar selection.

### Changed
- Updated `/demo/forms/date_input` and `/demo/forms/date_time_input` examples to show the new DateInput custom picker workflow and range usage alongside DateTimeInput guidance.
- Updated input documentation and component method-variable tables to include DateInput picker/range options and DateTimeInput-specific API references.

## [0.1.71] - 2026-05-29

### Added
- Added a `:logo_cloud` variant to `FlatPack::Carousel::Component` for single-row multi-item logo carousels with responsive visible counts (`5` desktop / `3` tablet / `3` mobile), grayscale toggle, and logo opacity control.

### Changed
- Updated `FlatPack::PageNav::Component` to rename `close_*` options to `anchor_*` and replace `add_*` URL options with a `right_slot` API for right-side action content.
- Updated `/demo/carousel` to include a dedicated Logo Cloud variant example and refreshed component method variable docs for the new carousel options.

## [0.1.69] - 2026-05-28

### Added
- Added `FlatPack::ChartButtons::Component` as a generic sibling control surface for chart filtering, with helper APIs for direct button links, dropdown options, checkbox-driven Turbo GET filters, and custom control slot content.
- Added two `/demo/tables/basic` filter/search demos: a generic sibling-control table filter with debounced search input and a multi-control outer-frame example with independently targeted inner table frames.
- Added `flat-pack--auto-submit` Stimulus controller for debounced GET form submission in Turbo-driven filter/search controls.

### Changed
- Updated `/demo/charts` filter examples to use `FlatPack::ChartButtons::Component` with Turbo Frame targeting across button, dropdown, and checkbox filter controls while keeping chart data selection server-driven.
- Updated table demo controller data preparation to support URL-driven generic filter definitions, selected filter values, and shared search query state for Basic Table interactive examples.

## [0.1.66] - 2026-05-28

### Added
- Added optional live character counting support to `FlatPack::TextInput::Component` via `character_count`, `min_characters`, and `max_characters`, including updated dummy demos, docs, and component method variable listings.
- Added a `border` option to `FlatPack::Collapse::Component` (default `true`) so borderless collapses can disable the outer border and horizontal trigger/content padding.
- Added optional `left_slot` trigger content support to `FlatPack::Collapse::Component.new(...)` and per-item `accordion.item(..., left_slot: ...)` in `FlatPack::Accordion::Component` for icon and marker rendering.
- Added `FlatPack::PageNav::Component` with icon-only controls for browser back plus optional close and add links, including dummy demo, docs, and test coverage.
- Added a new `/demo/charts` Day/Month filter example that uses segmented actions and a dummy Stimulus controller to switch chart series and x-axis categories client-side without page reload.

### Fixed
- Updated the locked `net-imap` and `view_component` dependencies to patched versions so `bundle-audit` no longer reports the published advisories.

## [0.1.60] - 2026-05-15

### Fixed
- Restored FlatPack slot helper compatibility on ViewComponent 4.x so table and other slot-backed components render correctly in the dummy app and engine tests.

## [0.1.59] - 2026-05-15

### Fixed
- Added `FlatPack::DateTimeInput::Component` and `FlatPack::TimeInput::Component`, plus matching dummy demos and regression coverage.
- Updated the locked `nokogiri` versions in the root and dummy app bundle files to `1.19.3` to address the published security advisories.
- Updated the root bundle lockfile to `rack 3.2.6` to address the published CVEs affecting static file handling and multipart byte-range processing.
- Updated the rounded theme skeleton background token to follow `--surface-muted-background-color`, matching the other themes while keeping the softer neutral loading state.
- Updated the rounded theme muted surface background token to `#e5e5e5` for a softer neutral palette.

### Changed
- Removed the default `pb-8` class from `FlatPack::PageTitle::Component` so page titles no longer force extra bottom padding.

### Tests
- Updated the PageTitle component regression coverage to assert the wrapper no longer renders `pb-8`.

## [0.1.58] - 2026-05-13

### Fixed
- Fixed `FlatPack::Breadcrumb::Component` so combined Back and Home trails render Home only once, kept the Back link spacing consistent, and refreshed the dummy breadcrumb example.
- Updated text input and shared form-validation warning states to use the semantic `var(--color-warning)` token in both server-rendered and JS-driven validation flows.
- Refreshed the root and dummy bundle lockfiles to resolve `addressable` and `rack-session` to patched versions for the current `bundle-audit` advisories.

### Tests
- Added breadcrumb regression coverage for the Back + Home rendering path and class merging on breadcrumb links.
- Added focused regression coverage for the text input warning token classes and a Node-based test for the shared form-validation controller.

## [0.1.57] - 2026-05-12

### Changed
- Bumped the gem version and synchronized the versioned docs and dummy lockfiles.

## [0.1.56] - 2026-05-12

### Added
- Added drag-and-drop orderable support to `FlatPack::List::Component`, including a configurable persistence endpoint and a single-item reorder payload.

### Tests
- Added List component, dummy request, and Stimulus controller coverage for the new orderable list behavior.

## [0.1.55] - 2026-05-11

### Changed
- Removed the redundant top-level pill button example from the `/demo/buttons` page so the remaining pill demos focus on the same-page anchor and direct-link examples.

### Tests
- Updated the `/demo/buttons` request coverage to match the trimmed pill demo section.

## [0.1.54] - 2026-05-11

### Changed
- Added two `/demo/buttons` pill-button demos: same-page anchors with Stimulus-managed active state updates, and deep links to the `/demo/tabs/pills#account` example.

### Tests
- Expanded the `/demo/buttons` request coverage to assert the new pill demo markup and deep-link example render correctly.

## [0.1.53] - 2026-05-08

### Changed
- Updated `FlatPack::Chat::Layout::Component` to render a rounded root border using the chat border token, and removed the duplicate dummy demo wrapper borders so `/demo/chat/layout` shows the component-owned frame.
- Updated carousel thumbnail buttons so chat image carousel previews show a pointer cursor and restore full opacity plus the active ring styling on hover.
- Updated carousel chevron controls to keep a square footprint with a fully round shape, a dark translucent tint, and white chevron icons.
- Updated the carousel slide counter to use the same dark translucent tint and white text treatment as the refreshed chevron controls.
- Updated the carousel lightbox toggle to use the same dark translucent tint and white icon treatment as the refreshed carousel controls.
- Updated carousel lightbox images to size to the underlying image while capping them to `90vw` by `90vh`, leaving room for captions instead of forcing full-width rendering.

### Tests
- Added chat layout component coverage to verify the root wrapper includes the chat border classes.
- Added component coverage to verify carousel thumbnails include the interactive cursor, hover opacity, and hover ring classes.
- Extended carousel component coverage for the refreshed lightbox toggle styling.
- Added carousel lightbox coverage to verify intrinsic image sizing with `90vw` and `90vh` viewport max bounds.

## [0.1.52] - 2026-05-08

### Changed
- Updated the chat sender optimistic fallback so newly sent messages use the same chat record, message group, attachment, and meta structure as the FlatPack chat components when server-rendered preview HTML is unavailable.

### Tests
- Added Playwright coverage for optimistic fallback sends so the demo verifies the component-compatible chat structure during message submission.

## [0.1.51] - 2026-05-07

### Added
- Added configurable theme metadata support to `flat-pack--theme`, so host apps can expose custom theme names in the existing theme picker without forking the controller label map.
- Added a custom theming guide with a complete copy-pasteable starter template for host-app named theme selectors.

### Changed
- Added a `sunrise` host-app theme example to the dummy app theme picker and stylesheet to demonstrate first-class custom theme integration.

### Tests
- Added Playwright coverage to verify a custom host-app theme can be selected from the theme picker and restored after reload.

## [0.1.50] - 2026-05-07

### Added
- Added `FlatPack::Button::Pill::Component`, a reusable grouped pill-link component that renders item hashes with required `href`, optional `id`, and `active` state support for segmented navigation outside tabs.

### Changed
- Updated the `/demo/cards` media gallery example to show hover-only checkbox and action controls over the image preview.
- Added a checked-state full-card ring that uses the FlatPack primary theme token instead of hard-coded indigo utilities.
- Removed the default gallery card preview outline and adjusted the ring-offset behavior so no idle edge artifact appears around the card.
- Added a right-side clear control to `FlatPack::Search::Component` when the input has a value, including the `/demo/search` live-search examples.
- Updated `FlatPack::Modal::Component` so header, body, and footer wrappers only render when those sections have content, keeping the close control aligned with the header title when present and independently rendered otherwise.
- Adjusted modal section spacing so the body uses top padding only and the header does not add default bottom padding, avoiding assumed spacing when adjacent sections are omitted.
- Added `/demo/modals` examples for headerless, bodyless, and footerless modal configurations.
- Added a `/demo/buttons` pill-buttons example directly below the wrapped button groups section.

## [0.1.49] - 2026-05-06

### Changed
- Added `padding:` support to `FlatPack::Card::Body::Component`, including `padding: :none` for compact card body layouts.
- Added a `background_muted` card theme token override so flat cards can override their muted surface color independently of the standard background token.
- Synced the card docs and `/demo/cards` media gallery example with the current card API and the transparent gallery card surface example.
- Updated the dummy Rails 8 and Rails 7 app version metadata and lockfiles so CI resolves the current `flat_pack` gem version.

## [0.1.48] - 2026-05-06

### Changed
- Added a media gallery card example to the dummy `/demo/cards` page, showing how to build file-browser style image grids with `FlatPack::Card::Component` media and body slots.

## [0.1.47] - 2026-05-06

### Changed
- Tightened the comments-composer rich text editor override so `.flat-pack-comments-composer-input .flat-pack-richtext-editor` now removes the editor border entirely, in addition to clearing its box shadow.

## [0.1.46] - 2026-05-06

### Changed
- Added a comments-composer scoped rich text editor override so `.flat-pack-comments-composer-input .flat-pack-richtext-editor` clears the default editor box shadow and border color in the shared FlatPack stylesheet.

## [0.1.45] - 2026-05-06

### Changed
- Added bubble-only comments composer rich text overrides so `.flat-pack-comments-richtext--bubble-only` removes the editor border and inner TipTap padding in the shared FlatPack stylesheet.

## [0.1.44] - 2026-05-06

### Changed
- Added a `flat-pack-comments-richtext--has-toolbar` class to the comments composer shell when it renders a rich text variant with a visible toolbar, so host apps can target toolbar mode without relying on utility class internals.

## [0.1.43] - 2026-05-06

### Changed
- Added a `flat-pack-comments-richtext--bubble-only` class to the comments composer shell when it renders the bubble-menu-only rich text variant, so host apps can target that mode without relying on utility class internals.

## [0.1.42] - 2026-05-06

### Changed
- Added a stable `flat-pack-comments-item` root class to `FlatPack::Comments::Item::Component` so host apps can target comment-level CSS without relying on utility class internals.
- Added a stable `flat-pack-comments-composer-input` class to the comments composer textarea shell so host apps can target the rich/plain comment input surface without depending on utility class internals.

## [0.1.41] - 2026-05-06

### Added
- Added a host-app TipTap addon registry so `FlatPack::TextArea` rich text editors can opt into application-registered extensions without forking FlatPack.
- Added `rich_text_options[:addons]` validation and serialization, including support for addon descriptors with per-instance option hashes.

### Changed
- Refactored the rich text toolbar and bubble menu to accept addon-provided tool definitions alongside the built-in preset tools.
- Clarified the rich text docs so `addons` is the supported extension point and `extensions` is documented as reserved for FlatPack-managed overrides.
- Expanded the textarea docs and dummy `/demo/forms/text_area` page with a host-app addon walkthrough, including a working TipTap `Image` extension example registered from the dummy app.
- Added upgrade guidance telling existing FlatPack apps to rerun `flat_pack:install` and `flat_pack:verify_install` so the latest TipTap/importmap wiring is applied after upgrading.

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
[0.1.131]: https://github.com/bowerbird-app/flatpack/compare/v0.1.130...v0.1.131
[0.1.130]: https://github.com/bowerbird-app/flatpack/compare/v0.1.129...v0.1.130
[0.1.123]: https://github.com/bowerbird-app/flatpack/compare/v0.1.122...v0.1.123
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
