# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Button accepts `disabled:`. `false` is the default and keeps today’s markup. `true` sets the `disabled` attribute on a `<button>` and mutes it with the same opacity as loading, without the spinner. `nil` and `false` mean enabled. Link buttons with `href` keep their `href`. `loading: true` still disables as before.
- `FlatPack::Picker::Component` accepts `variant: :flush` on the inline shell. That look is borderless, transparent, unpadded, and unrounded (`border-0 bg-transparent shadow-none rounded-none p-0`), plus `py-0` on the body. Omit it, or pass `variant: :default`, and the existing panel chrome stays. Modal pickers ignore `variant` and keep Modal chrome. Unknown values raise `ArgumentError`.
- `FlatPack::TextArea::Component` accepts `variant: :chat`. That look uses the Chat::Composer tokens (`--chat-composer-control-height`, `--chat-composer-radius`, `--chat-composer-control-padding-y`, `--chat-input-border-color`, `--chat-input-background-color`, `--chat-input-text-color`, `--chat-input-placeholder-color`, `--chat-input-focus-ring-color`) plus the same compact `px-4`, `leading-5`, and `max-h-32` classes the composer already puts on a field. Autogrow stays on. `rows` defaults to `1`. Omit `variant` (or pass `:default`) and the field is unchanged. Invalid names raise `ArgumentError`. `:chat` cannot be paired with `chrome: :cell`.
- `FlatPack::List::Component` and `FlatPack::List::Item` accept `align: :start`, `:center`, `:end`, or `:baseline`. The default is `:start` (`items-start`), the same row alignment as before. List `align:` is the default for items rendered inside that list. An item `align:` overrides it. Invalid values raise `ArgumentError`. `layout: :key_value` still starts rows at the top; a non-`:start` `align:` there raises.
- `FlatPack::Chart::Component` accepts `integer_ticks: true`. The chart controller then sets ApexCharts `yaxis` (and numeric `xaxis`) to whole-number ticks: `stepSize: 1`, `decimalsInFloat: 0`, and a rounding label formatter. Category axes are left alone. Omit it or pass `false` and labels stay as they are today, including `0.0`.
- Card media accepts a nested `hover_actions` slot for a control on the photo (a dropdown, a button). On hover-capable pointers the control is hidden until the media is hovered. It stays visible on `focus-within` and on pointers that cannot hover. Omit the slot and the media markup is unchanged. Default placement is `:top_right` with inset `:sm`. The slot is named `hover_actions` so it does not collide with a Card-level `actions` slot. `FlatPack::Reveal::Component` does not cover this; Reveal is scroll-in motion.
- `FlatPack::Heading::Component` renders a bare `h1`–`h6`. `level:` (or `1`–`6`) is the tag. `size:` is the look (`:xs` through `:"5xl"`, default `:"2xl"` / `--text-2xl`). `style:` is `:default`, `:muted`, or `:primary`. `weight:` is `:normal`, `:medium`, `:semibold` (default), or `:bold`. No wrapper, subtitle, trailing slot, or copy-link.
- `FlatPack::Text::Component` renders body copy. `size:` is `:xs` through `:"2xl"` (default `:base`). `style:` and `weight:` use the same tokens as Heading (`weight` defaults to `:normal`). `as:` is `:p` (default), `:span`, or `:div`.
- Section Title, Page Title, Hero Title, Content, and Empty State still cover section chrome, page chrome, cover type, article HTML, and empty-state titles. Use Heading when a host needs a plain heading tag with an independent size. Use Text when a host needs a line of kit copy. Demos: `/demo/heading`, `/demo/text`.
- `FlatPack::Embed::Component` frames a host iframe (`src:`, required `title:`) at a Card-media aspect ratio (default `16/9`). `loading:` defaults to `lazy`. `referrerpolicy:` defaults to `strict-origin-when-cross-origin`. Optional `allow:`, `sandbox:`, `allowfullscreen:`, and `caption:` (or a block). Demo: `/demo/embed`.
- Color Swatch exposes a public reset for the native colour picker. Stimulus `reset` restores the server-rendered `#rrggbb` on `data-flat-pack--color-swatch-color-value`. It does not read the input value at connect time. Hosts dispatch `color-swatch:reset` on the swatch root, or pass `detail.value` as `#rrggbb`. Reset fires `input` and `change` on the colour input, then `color-swatch:change`. Do not reach into the input or swatch face.
- Combobox `search_mode: :remote` loads options with the same request and JSON contract as Select. Pass `search_endpoint:` (required for `:remote`; optional `search_param:`, `min_search_length:`, `debounce:`). `GET` expects `{ "items": [{ "value", "label" }] }` or a top-level array. Combobox rows may also include `subtitle`. Omit `search_mode` (or pass `:local`) and typing still filters `options:` in the browser. The list keeps keyboard movement, Enter, Escape, and `aria-activedescendant`. One click on a row chooses it once. The field sets `spellcheck="false"`. Loading, hint, and empty rows are kit copy. A choice still writes the hidden field and dispatches `change`. It also dispatches `flat-pack:combobox:selected` with `value`, `label`, and optional `subtitle`. Hint and loading rows are `role="status"` with `aria-live="polite"`.
- Grid items can span more than one column. Pass `span:` on `with_item` or render `FlatPack::Grid::Item`. A bare integer `1`–`12` starts at the first breakpoint where that grid's `cols` preset has at least that many columns. `with_item` passes the preset. On `cols: :auto`, `span: 2` is `sm:col-span-2`. On `cols: 2`, `3`, and `4`, `span: 2` is `md:col-span-2`, because those presets are one column until `md`. Later breakpoints that repeat the same count are omitted. If the preset never has that many columns, the span is clamped to the widest count and starts where that width first appears (`cols: 2` and `span: 3` is `md:col-span-2`). A hash, including `base:`, is emitted as written. `:full` is `col-span-full` at `base`. Omit `span:` and the cell is one track wide. Each `with_item` wrapper has the class `fp-grid__item`. A host `col-span-*` class on that wrapper wins over `span:`. Grids that still pass children with no `with_item` keep the same markup. A non-integer span such as `2.5` raises `ArgumentError`.
- `FlatPack::Stack::Component` lays out children in a vertical flex column. `gap:` is `:sm`, `:md` (default), or `:lg`, mapped to `--stack-gap-sm`, `--stack-gap-md`, and `--stack-gap-lg`. `align:` is `:start`, `:center`, or `:stretch` (default). Gap classes, align classes, and those validators live on `FlatPack::Shared::Flex` with `FlatPack::Shared::Breakpoints`. Grid uses the same module.
- `FlatPack::Cluster::Component` lays out children in a wrapping horizontal flex row. `gap:` and `align:` match Stack and Grid (`align` defaults to `:center`). `justify:` is `:start` (default), `:center`, `:end`, or `:between`.
- Demo pages: `/demo/stack` and `/demo/cluster`.
- `FlatPack::Card::Component` `variant: :featured` is a large cover layout: square media on the left, copy on the right, stacking below `md`. Header is the top action row (over the photo on small screens). The header element itself is that flex row, so a host class, padding, border, or divider on `card.header` still applies. `badge` and `title` sit above `body`. Footer is the bottom action row: two controls share the row below `md` and sit at the end from `md`. The footer is a flex container. Neither row uses `display: contents`. Existing stacked cards stay `variant: :default`. `nil` variant is `:default`. `title` renders `FlatPack::Heading::Component` and reads `--card-title-size`, `--card-title-weight`, and `--card-title-color`. Featured defaults live on `:where(.fp-card--featured)` (`--text-4xl`, `--display-weight`, `--surface-content-color`), so a declaration on the card wins. The title weight fallback is `--display-weight`. Title accepts `prefix:` and `as:` (`:h1`, `:h2`, `:h3`). There is no `actions` slot.

### Upgrade notes
- Additive. Existing picker calls keep the bordered inline panel. Pass `variant: :flush` instead of host `!border-0 !bg-transparent !shadow-none !rounded-none !p-0` overrides when the picker is embedded in another surface. Rebuild host Tailwind so `border-0`, `bg-transparent`, `shadow-none`, `rounded-none`, `p-0`, and `py-0` are generated if the host did not already use them. Reload kit CSS. Do not rerun the install generator.
- Additive. Pass `variant: :chat` on `FlatPack::TextArea::Component` instead of a long host Tailwind class list. Example: `render FlatPack::TextArea::Component.new(name: "chat[message]", placeholder: "Write a message...", variant: :chat, submit_on_enter: true)`.
- Rebuild host Tailwind so `min-h-[var(--chat-composer-control-height)]`, `max-h-32`, `rounded-[var(--chat-composer-radius)]`, `border-[var(--chat-input-border-color)]`, `bg-[var(--chat-input-background-color)]`, `px-4`, `py-[var(--chat-composer-control-padding-y)]`, `leading-5`, `text-[var(--chat-input-text-color)]`, `placeholder:text-[var(--chat-input-placeholder-color)]`, and `focus:ring-[var(--chat-input-focus-ring-color)]` exist if the host did not already use Chat::Composer. Reload kit CSS. Do not rerun the install generator.
- Additive. Omit `align:` and rows still use `items-start`. Spacing (`gap-3` / `gap-1`) is unchanged. Pass `align: :center` on the list when a short row should line an icon up with trailing actions, instead of `!items-center` on the host. Rebuild host Tailwind so `items-center`, `items-end`, and `items-baseline` are generated if the host did not already use them. Do not rerun the install generator.
- Additive. Pass `integer_ticks: true` when a count chart should show `0`, `1`, `2` instead of `0.0` or `1.5`. Do not wrap `chart.render` in the host. A host `yaxis.labels.formatter` still runs, with the rounded number. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator.
- Additive. Pass `media.hover_actions` inside `card.media`. Rebuild host Tailwind so `group/media`, `group-hover/media:opacity-100`, `focus-within:opacity-100`, `[@media(hover:hover)]:opacity-0`, and the motion-safe opacity transition utilities are generated if the host did not already use them. Reload kit CSS. Do not rerun the install generator.
- Additive. Existing Section Title, Page Title, Hero Title, Content, and Text Stream calls are unchanged.
- Replace a host `<h1 class="text-2xl font-semibold">` or raw `<h2>` with `FlatPack::Heading::Component`. Replace a host `<p class="text-sm text-gray-500">` with `FlatPack::Text::Component` (`style: :muted`, `size: :sm`). Keep Section Title when the block needs a subtitle, trailing content, or a copy-link.
- Rebuild host Tailwind so `text-[length:var(--text-xs)]` through `text-[length:var(--text-5xl)]`, `font-normal` / `font-medium` / `font-semibold` / `font-bold`, and `text-[var(--surface-content-color)]` / `text-[var(--surface-muted-content-color)]` / `text-[var(--color-primary)]` exist if the host did not already use them. Reload kit CSS. Do not rerun the install generator.
- Additive. Render `FlatPack::Embed::Component` for maps, clips, and other host iframe URLs. Flatpack does not build provider URLs.
- Rebuild host Tailwind so `aspect-[16/9]`, `aspect-[4/3]`, `aspect-square`, and `rounded-[var(--media-radius)]` are generated if the host did not already use them. Reload kit CSS. Do not rerun the install generator.
- Additive. Existing Color Swatch markup and `color-swatch:change` stay the same. To reset without touching internals, dispatch `color-swatch:reset` on `[data-controller='flat-pack--color-swatch']`, or call `reset` on `flat-pack--color-swatch`. `detail.value` must be `#rrggbb`. A CSS colour on `color:` still paints the first face. Reset returns the picker hex, not that CSS colour. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator.
- Column presets are unchanged. `cols: 4` stays `grid-cols-1 md:grid-cols-2 lg:grid-cols-4`. Existing grids with no `with_item` do not wrap cells and do not add `col-span-*` or `fp-grid__item`.
- A bare `span:` integer follows the column preset instead of always starting at `sm`. `cols: 2`, `3`, and `4` stay one column until `md`, so `span: 2` is `md:col-span-2` and does not add an implicit track between `sm` and `md`. Pass `base:` to span on a phone, and only when that preset already has enough base columns (`cols: 6` and `cols: 12` are `grid-cols-2` at base). A span wider than the columns at that breakpoint still adds an implicit `auto` track. `span: :full` is `grid-column: 1 / -1` and covers only the explicit tracks.
- A host `col-span-*` class on the item wins over the classes from `span:`.
- Rebuild host Tailwind so `col-span-1` through `col-span-12`, `col-span-full`, and the `sm:`, `md:`, `lg:`, and `xl:` prefixes are generated. Reload kit CSS. Do not rerun the install generator.
- Additive for local Combobox calls with `options:`. Those fields now also set `spellcheck="false"`.
- A new keystroke aborts the in-flight Combobox search, including when the query drops below the minimum length. A response for the previous query does not paint rows. Hint and loading rows announce politely. Reload kit JavaScript.
- `options:` may be omitted when `search_mode: :remote`. Seed `options:` with the current choice so the field can show a label before the next search. `search_endpoint:` is required in that mode. An unknown `search_mode` raises `ArgumentError`.
- Hosts that keep their own importmap pin list need `pin "flat_pack/remote_query"`. importmap-rails hosts that load the engine importmap already receive it. Rerun `bin/rails generate flat_pack:install` only when that pin is missing. Rebuild host Tailwind if the host did not already use `block` and `text-xs` on Combobox rows. Reload kit JavaScript.
- Prefer Stack for `flex flex-col gap-*` host markup and Cluster for `flex flex-wrap gap-*`. Keep Collection when the children are a list. Keep Overflow Row when a second row is unwanted. Collection and Overflow Row gap classes are unchanged. Grid gap classes and hand-built Grid items changed; see Changed.
- Rebuild host Tailwind so `flex-col`, `flex-wrap`, `justify-start`, `justify-center`, `justify-end`, `justify-between`, `gap-[var(--stack-gap-sm)]`, `gap-[var(--stack-gap-md)]`, and `gap-[var(--stack-gap-lg)]` are generated if the host did not already use them. Grid, Stack, and Cluster share those gap classes. Reload the gem. Do not rerun the install generator.
- Additive. Omit `variant:` and the card stays stacked. Pass `variant: :featured` with the existing `media`, `header`, `body`, and `footer` slots, plus optional `badge` and `title`. Recommended cover chrome: `padding: :none`, `inset: :md`, `radius: :xxxl`, `shadow: :md`, `border: :none`. Put `FlatPack::Media` `radius: :card_inner` in `media`. Do not make the card `clickable` when footer buttons are present. Rebuild host Tailwind only if you still need the existing card utilities. Reload kit CSS. Do not rerun the install generator.
- A secondary button paints its glyph with `--button-secondary-text-color`. Do not put `text-white` on a media overlay to colour those icons. Rebuild host Tailwind so `text-[var(--button-secondary-text-color)]` is generated. Reload kit CSS. Do not rerun the install generator.

### Changed
- Grid `gap: :sm`, `:md`, and `:lg` emit `gap-[var(--stack-gap-sm)]`, `gap-[var(--stack-gap-md)]`, and `gap-[var(--stack-gap-lg)]`. They used to emit `gap-2`, `gap-4`, and `gap-6`. A theme that sets `--stack-gap-sm`, `--stack-gap-md`, or `--stack-gap-lg` now resizes Grid as well as Stack and Cluster. A host selector that matched `.gap-2`, `.gap-4`, or `.gap-6` on a Grid no longer matches. Collection, Masonry, and Overflow Row still use `gap-2`, `gap-4`, and `gap-6`.
- A hand-built `FlatPack::Grid::Item` with no `columns:` and a bare integer `span:` emits no `col-span-*` class. `with_item` still passes the grid's column preset, so a bare integer there still starts at the first breakpoint that has enough columns. Pass a hash, including `base:`, on a hand-built item when that cell should span without a preset. An integer outside `1`–`12` still raises `ArgumentError`.
- Select, Picker, Search, and Combobox share `createRemoteQuery` in `flat_pack/remote_query.js` for the debounce timer, the abort, and the JSON `GET`. Each component still owns its wait, its query params, and its response shape. Select and Combobox both read `items` (or a top-level array). Picker still reads `items`. Search still reads `results`.
- ComponentCatalog still maps the `text` family to `docs/components/text-stream.md`. `Text::Component` is the one override (`DOC_PATH_OVERRIDES`) and reads `docs/components/text.md`. Nested billing, button, comments, menu, and sidebar entries still use the family file.

### Fixed
- A secondary button keeps `--button-secondary-text-color` on itself. A `text-white` class on the media overlay wrapper is dropped, so the icon is not the same colour as the light button fill.
- Modal closes and releases its body scroll lock on `turbo:before-cache`. A Turbo snapshot never restores an open dialog or a leftover `flatPackModalLockCount`. Nested modals still share that count; each open modal decrements once. A close already in flight does not decrement again.

## [0.1.330] - 2026-10-29

### Added
- `DateRangeInput` accepts `presets:`. Omit it and the quick list is unchanged: Today, Yesterday, Last 3 days, This week, Last week, Last 4 weeks, This month, Last month, This year, Last year. Pass names to choose the list. `:last_30_days` is a built-in name (today and the 29 days before it) and is not in the default list. Custom entries take `label:` plus `days:` (a rolling inclusive window ending today) or `start:` and `end:`.
- The date picker Stimulus controller fills that range on click. Named built-ins stay in the controller. Custom `days:` / `start:` / `end:` ranges are written on the field as `presetRanges` so the click path does not need a host prepend.

### Upgrade notes
- Additive. Calls that omit `presets:` render the same default names. `:last_4_weeks` and the other default names are unchanged.
- Recording Studio sitemaps can drop the `DateRangeInput` prepend. Pass the last-30-days name first, then the default names:

```erb
<%= render FlatPack::DateRangeInput::Component.new(
  start_name: "start_date",
  end_name: "end_date",
  presets: [:last_30_days, *FlatPack::DateRangeInput::Component::DEFAULT_PRESET_KEYS]
) %>
```

- A prepend that still overrides `quick_range_presets` and `preset_range_for` keeps working. Prefer `presets:` for new hosts.
- Reload the gem. Rebuild host JavaScript so the date picker controller picks up `last_30_days` and `presetRanges`. Do not rebuild Tailwind. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.330`.

## [0.1.329] - 2026-10-28

### Added
- `FlatPack::Chat::Panel::Component` accepts optional `right_header` and `right_header_mobile` slots. Each sits in the panel header at `w-min`, right-aligned, and does not shrink. `header` keeps the remaining width. Omit both and the panel markup stays the same. The bar adds no padding. The parts expose `data-flat-pack-chat-panel-part="header"`, `data-flat-pack-chat-panel-part="right-header"`, and `data-flat-pack-chat-panel-part="right-header-mobile"`. With no `header`, a right part also has `ml-auto`. The row is `flex items-center`, so the title block and the actions share a vertical center. The header part stays `min-w-0 flex-1`.
- `right_header_mobile` is the compact set below the chat `sm` breakpoint (640px). Below `sm`, that part is shown and `right_header` is hidden when both slots are passed. At `sm` and up, `right_header` is shown and the mobile part is hidden. The swap follows the viewport, not the panel's container width, so a narrow panel on a wide viewport (including a `Chat::Layout` split column) still shows the desktop set. Pair `right_header` with `right_header_mobile` when that desktop set has four or more actions, or a long-text badge. `right_header` alone stays visible at every width. `right_header_mobile` alone shows below `sm`; with no `header`, the bar hides at `sm` and up. Both parts are in the DOM. CSS hides one, so ids and Stimulus targets must not be duplicated between them.
- Because a right part is `w-min` and does not shrink, its content must not wrap. Use `whitespace-nowrap`, icon buttons, and badges.

### Upgrade notes
- Additive. Existing `panel.header` calls render the same markup. Pass `panel.right_header` for actions that stay on the right at every width. Pair it with `panel.right_header_mobile` when the desktop set has four or more actions, or a long-text badge. The pair swaps at a 640px viewport, not at the panel's own width. Put your own padding on the slot content (`p-4`). Keep that content on one line (`whitespace-nowrap`, icon buttons, badges). `Chat::Header`'s `right` slot is for actions inside that header, next to its title. `right_header` is for actions beside the panel `header` slot. Do not repeat ids or Stimulus targets across `right_header` and `right_header_mobile`.
- Rebuild host Tailwind so `w-min`, `hidden`, `sm:flex`, and `sm:hidden` are generated if the host did not already use them. Reload kit CSS. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.329`.

## [0.1.328] - 2026-10-28

### Added
- Button `icon:` accepts a trusted `<svg` string and paints it as markup, the same way List::Item does. A Heroicon name and a short alias such as `"search"` are unchanged. `icon_variant` and `icon_style` still apply only to Heroicon names. A host `render_icon` override still paints that SVG; Heroicon names still skip the override.

### Upgrade notes
- Pass a trusted `<svg` string on Button `icon:` when the mark is not a Heroicon. Do not pass user input. The kit sizes that mark to the same box as a Heroicon at that button size.
- Link buttons, Button Group children, Page Nav icon controls, and the Button Dropdown trigger pick this up because they render `FlatPack::Button::Component`. Dropdown menu items and Menu Collapse headers still use `IconComponent` and stay Heroicon names.
- The Recording Studio Users `FlatpackButtonSvgIcon` prepend on `FlatPack::Button::Component` can be deleted. Button now paints and sizes that SVG. Keep the prepend only if it still does extra wrapping or restyling you want.
- Reload the gem. Do not rebuild Tailwind. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.328`.

## [0.1.327] - 2026-10-28

### Added
- `--backdrop-content-color` and `--backdrop-muted-content-color` alias the surface content colours. `[data-theme~="rounded"]` points them at `--hero-overlay-text-color` and `--hero-overlay-muted-text-color`. Dark does not set them. `rounded dark` keeps the white overlay text because that block follows dark.
- `.fp-on-backdrop` and `.fp-on-backdrop-muted` recolour page text from those tokens. Breadcrumbs, top-nav items, and ghost buttons follow `.fp-on-backdrop`. Both classes do nothing without `[data-flat-pack-layout-background]`. A card inside `.fp-on-backdrop` keeps its own text.

### Upgrade notes
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.327`.

## [0.1.326] - 2026-10-27

### Changed
- Overlay item gaps are px and resolve on the item. `:sm` is `--overlay-edge-offset`. `:md` is twice that. `:lg` is three times that. At the default `8px` token that is `8px`, `16px`, and `24px`. `:root` does not assign `--overlay-inset-sm`, `--overlay-inset-md`, or `--overlay-inset-lg`.
- A plain parent such as `<div style="--overlay-edge-offset: 12px">` changes those gaps. A parent `--overlay-inset-sm`, `--overlay-inset-md`, or `--overlay-inset-lg` wins for that one size. The item reads the token and does not set it.
- Carousel chevrons stay at `0.75rem`. The lightbox shell, Modal, Drawer, and Command palette keep `--overlay-padding`. Those insets are not the Overlay item gap.

### Upgrade notes
- The gaps no longer follow the root font size. At a 16px root and the default `8px` token, the default looks the same. A larger root font no longer widens the gap.
- `--overlay-inset-sm`, `--overlay-inset-md`, and `--overlay-inset-lg` are no longer set on `:root` or `@theme`. Host CSS that read one of those tokens from `:root` no longer gets a length from the kit. Set the token on a parent, or set `--overlay-edge-offset`.
- Rebuild host Tailwind so `top-[var(--fp-overlay-item-inset)]` and the `right`, `bottom`, and `left` matches exist. Reload kit CSS. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.326`.

## [0.1.325] - 2026-10-27

### Changed
- Collection editor places its search menu with `place` in `flat_pack/positioning.js`. The menu still opens 4px under the field, aligned to the field's left edge, or above when below does not fit. The width is still the field width, or 192px when the field is narrower. The vertical clamp reads `--overlay-edge-offset` (8px unless a theme sets another px value). An oversized menu sticks to that edge. The left edge stays on the field, including when that edge is outside the viewport. Scroll and resize while the controller is connected still follow an open menu. Disconnect still removes those listeners. The open menu is still portaled to `document.body`.
- No new `place` option. Collection editor passes `placement: "bottom_left"`, `flip: true`, and `stickToEdge: true`, then writes the field's left edge over the clamped `left`.
- `watchViewport` listens for scroll on `window` instead of `document`. Both listeners use capture, so a scroll inside a nested overflow container still reaches the controller.

### Upgrade notes
- No new importmap pin. `flat_pack/positioning` is already on the engine importmap. A missing pin now stops Collection editor as well as Popover, Button dropdown, and Date picker. Those four controllers import the module. Every other controller is its own lazy-loaded file and still loads.
- Placement of an on-screen field is unchanged when `--overlay-edge-offset` is `8px`. A theme that changes the token changes the vertical fit inset and the vertical clamp. The 4px gap does not follow the token. The horizontal position does not follow the token. A menu that would start above the viewport now sits on the edge instead of following the field off the top. A menu flipped above a field that is itself past the bottom of the viewport is kept on screen. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.325`.

## [0.1.324] - 2026-10-27

### Changed
- Date picker places its panel with `place` in `flat_pack/positioning.js`. The panel still opens below the trigger, or above when below does not fit. The gap stays 8px. The viewport clamp reads `--overlay-edge-offset` (8px unless a theme sets another px value). An oversized panel still sticks to that edge. The controller still sets the panel width, and at `max-width: 767px` the panel is still full screen. Scroll and resize while the panel is open still follow the trigger. Disconnect still removes those listeners. The open panel is still portaled to `document.body`.
- No new `place` option. Date picker passes `placement: "bottom"`, `flip: true`, and `stickToEdge: true`.

### Upgrade notes
- No new importmap pin. `flat_pack/positioning` is already on the engine importmap. A missing pin now stops Date picker as well as Popover and Button dropdown. Those three controllers import the module. Every other controller is its own lazy-loaded file and still loads.
- Placement is unchanged when `--overlay-edge-offset` is `8px`. A theme that changes the token changes the fit inset, the clamp, the width cap, and `max-width`. The 8px gap does not follow the token. The `max-width: 767px` full-screen panel does not follow the token. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.324`.

## [0.1.323] - 2026-10-27

### Changed
- Button dropdown places its menu with `place` in `flat_pack/positioning.js`. Placements stay `bottom_right`, `bottom_left`, `top_right`, and `top_left`. The menu does not flip. The gap stays 8px. The viewport clamp reads `--overlay-edge-offset` (8px unless a theme sets another px value). An oversized menu still sticks to that edge. Scroll and resize while the menu is open still follow the trigger. Disconnect still removes those listeners.
- `place` accepts `stickToEdge`. The default is false, so Popover still lets an oversized panel sit past the viewport edge. Button dropdown passes `stickToEdge: true` and `flip: false`.

### Upgrade notes
- No new importmap pin. `flat_pack/positioning` is already on the engine importmap. A missing pin now stops Button dropdown as well as Popover. Those two controllers import the module. Every other controller is its own lazy-loaded file and still loads.
- Placement is unchanged when `--overlay-edge-offset` is `8px`. A theme that changes the token changes how far an open menu sits from the viewport edge, including an oversized menu. The 8px gap does not follow the token. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.323`.

## [0.1.322] - 2026-10-27

### Changed
- Popover places its panel with `place` in `flat_pack/positioning.js`. Placements stay `top`, `bottom`, `left`, and `right`. The panel still flips to the opposite side when the preferred side does not fit, and the gap between the trigger and the panel stays 12px. The viewport clamp reads `--overlay-edge-offset` (8px unless a theme sets another px value). Scroll and resize while the popover is open still follow the trigger. Disconnect still removes those listeners.
- Tooltip, Button dropdown, Date picker, and Collection editor still place themselves.

### Upgrade notes
- importmap-rails hosts already receive `flat_pack/positioning` from the engine importmap. `initializer "flat_pack.importmap"` appends `config/importmap.rb` before importmap-rails reads it. Add the pin, or rerun `bin/rails generate flat_pack:install`, only when the host bypasses that importmap or keeps its own pin list. A missing pin stops Popover. That controller imports the module. Every other controller is its own lazy-loaded file and still loads.
- Placement is unchanged when `--overlay-edge-offset` is `8px`. A theme that changes the token changes how far an open Popover sits from the viewport edge. The 12px gap does not follow the token. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator when the engine importmap is in use.
- Redeploy so `meta.gem_version` shows `0.1.322`.

## [0.1.321] - 2026-10-27

### Changed
- Popover, Search, Select, Button dropdown, Date picker, Collection editor, Combobox, FAB, the button-group menu, Trash button, and collapsible Search close from a pointer outside through `onClickOutside` in `flat_pack/click_outside.js`. Each keeps its event (`click`, `mousedown`, or `pointerdown`), capture or bubble phase, and connect/disconnect listener. A click on the trigger or inside the overlay does not close. Escape handling is unchanged.
- Chat message actions uses `isOutside` from the same module for its window click.
- Modal, Drawer, and Command palette close on a backdrop click through `isBackdropClick`. The click target is the backdrop element. A click inside the dialog does not close. Lightbox uses the same helper: the stage and the controls are not the backdrop, and a click on the shell is.

### Upgrade notes
- importmap-rails hosts already receive `flat_pack/click_outside` from the engine importmap. `initializer "flat_pack.importmap"` appends `config/importmap.rb` before importmap-rails reads it. Add the pin, or rerun `bin/rails generate flat_pack:install`, only when the host bypasses that importmap or keeps its own pin list. A missing pin stops Popover, Search, Select, Button dropdown, Date picker, Collection editor, Combobox, FAB, the button-group menu, Trash button, collapsible Search, Chat message actions, Modal, Drawer, Command palette, and Lightbox. Those controllers import the module. Every other controller is its own lazy-loaded file and still loads.
- Pointer behavior is unchanged. Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun the install generator when the engine importmap is in use.
- Redeploy so `meta.gem_version` shows `0.1.321`.

## [0.1.320] - 2026-10-26

### Added
- `FlatPack::ImageInput::Component` picks one image, shows a preview, and can remove it.

### Changed
- Image Input's empty state is a filled surface. The dashed border is gone. Hover and drag-over use the focus outline on the shaped surface. An error stays a ring on that surface.

### Upgrade notes
- New component. Existing markup is unchanged.
- The empty Image Input is a filled surface with no dashed border. Hover and drag-over use the focus outline on the shaped surface.
- Hosts that scan the gem for Tailwind need one CSS rebuild so `h-20`, `w-36`, and the shape classes exist.
- The controller is lazy-loaded by the existing controllers pin. Do not rerun the install generator.
- Redeploy so `meta.gem_version` shows `0.1.320`.

## [0.1.319] - 2026-10-26

### Changed
- Drawer, Command palette, and Modal cycle Tab through `trapTab` in `flat_pack/focus_trap.js`. One selector finds the controls. Modal still skips disabled, hidden, and `aria-hidden` controls, focuses the dialog when nothing inside can take Tab, and wraps when focus is outside the dialog. Drawer and Command palette keep the previous cycle.

### Upgrade notes
- importmap-rails hosts already receive `flat_pack/focus_trap` from the engine importmap. `initializer "flat_pack.importmap"` appends `config/importmap.rb` before importmap-rails reads it. Add the pin, or rerun `bin/rails generate flat_pack:install`, only when the host bypasses that importmap or keeps its own pin list. A missing pin stops Drawer, Command palette, and Modal. Those three controllers import the module. Every other controller is its own lazy-loaded file and still loads.
- Keyboard behavior is unchanged. Reload kit JavaScript. Do not rebuild Tailwind.
- Redeploy so `meta.gem_version` shows `0.1.319`.

## [0.1.318] - 2026-10-26

### Added
- `--overlay-edge-offset` is `8px` on `:root, [data-theme]`. It is the shared distance from a viewport or anchor edge. It is also registered on `@theme inline`. The unit is `8px`, not `rem`, on purpose: the offset does not follow the root font size. `--overlay-inset-*` stays in rem.

### Upgrade notes
- The token is additive. No component reads it. Rendered markup is unchanged.
- Reload kit CSS when a host wants to override the token. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.318`.

## [0.1.317] - 2026-10-26

### Fixed
- Clicking the current slide in `FlatPack::Carousel::Component` opens `FlatPack::Lightbox` on that item. Previous, next, indicators, and thumbnails no longer open the first item. A swipe does not open the lightbox, and the expand control still opens on the next press after that swipe. Autoplay pauses while the dialog is open and resumes when it closes. Changing items inside the dialog does not move the carousel on the page or open the dialog again.

### Upgrade notes
- Reload kit JS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.317`.

## [0.1.316] - 2026-10-26

### Changed
- Dropdown triggers, the modal-filter trigger, the chat jump control, the comments floating send, and the modal, drawer, alert, and toast close controls render `FlatPack::Button::Component`. Carousel previous, next, and expand, and the lightbox close, do too. Each parent sets `--button-*` from its own tokens. Stimulus actions, aria names, and carousel lightbox data attributes are unchanged.
- The comments floating send no longer paints with a one-off `button[type="submit"]` rule. Fill, hover, text, border, and shadow come from `--comments-composer-submit-*` only. A parent's `--button-primary-*` does not paint this control. The shadow is `--comments-composer-submit-shadow` (the old Tailwind `shadow-lg` utility). The disk has no border, and a disabled send stays fully opaque.
- Keyboard focus on the comments send and the chat jump draws the browser `auto` outline from `--focus-outline-color`. The light default is `#101010`. On `data-theme~="dark"` that token is `--surface-content-color`, so the stroke stays visible. `--comments-composer-submit-focus-ring-color` reads the shared token and falls back to `#101010`. Each parent maps it onto `--button-focus-ring-color`. The send does not inherit a parent's `--button-primary-*`.
- The chat jump shadow is `--chat-jump-button-shadow` (the same Tailwind `shadow-lg` utility). Flatpack's `--shadow-lg` is a different shadow.
- Modal and drawer close glyphs sit at the start of the hit area and are centered on the cross axis. Carousel, lightbox, toast, modal, and drawer focus rings are a 2px inset ring in the control's own text color, with no offset. Modal close and back are icon-only `md` buttons, so they still carry `fp-hit-target` (minimum 2.75rem).
- A labeled dropdown trigger puts the chevron in Button's trailing slot, so the icon is inside an extra span. The trigger's direct children are the label span and that trailing span.
- The modal back control uses the same ghost Button as the close control. A host `style:` string, `href`, `method`, and `target` on `trigger_attributes` are dropped and are not copied onto the trigger. `size`, `text`, `icon`, and the other Button option keys are dropped the same way, so they do not replace the dropdown's own options.

### Upgrade notes
- Restyle these controls with `--button-*` on a parent, or with the existing component tokens (`--modal-close-icon-*`, `--drawer-close-icon-*`, `--alert-dismiss-button-*`, `--alert-dismiss-icon-size`, `--toast-dismiss-*`, `--chat-jump-button-*`, `--chat-jump-button-shadow`, `--comments-composer-submit-*`, `--comments-composer-submit-shadow`, `--comments-composer-submit-size`, `--comments-composer-submit-focus-ring-color`, `--focus-outline-color`, `--carousel-control-*`). Do not target the old utility class strings on those buttons. Do not expect the comments send to inherit `--button-primary-*`. Set `--focus-outline-color` to recolour both focus outlines. Set `--comments-composer-submit-focus-ring-color` to recolour only the send.
- Selectors that expected the dropdown chevron as a direct `svg` child of the trigger should look inside the trailing span.
- A `trigger_attributes` `style:` string, `href`, `method`, or `target` no longer reaches the trigger. Pass `style:`, `size:`, and `icon:` as dropdown arguments.
- Copy button and the date picker day cells still use their own markup. No install step. No Tailwind rebuild. Redeploy so `meta.gem_version` shows `0.1.316`.

## [0.1.315] - 2026-10-26

### Added
- `FlatPack::TopNav::Component` takes `size:`. `:md` (the default) keeps `--top-nav-height` at `72px`. `:lg` sets that same property to `96px` on the row, the layout bar, the scroll pane beside it, and `html`. `:default` is an alias of `:md`. The header sets `data-fp-top-nav-size` to `md` or `lg`.

### Fixed
- `PageLayout` with a top bar in flow (`content_scroll: :below`) no longer stacks `--page-layout-gap` and `<main>` `padding-top`. The frame gap is the only space under the bar. A page with no top bar still pads `<main>`.

### Upgrade notes
- Pass `size: :lg` for a `96px` bar. Existing calls stay `72px`. `:default` normalizes to `:md`.
- A page that already added its own padding under the bar can drop that extra space. The kit gap is the space now.
- Reload kit CSS/JS. Redeploy so `meta.gem_version` shows `0.1.315`.

## [0.1.314] - 2026-10-26

### Added
- `FlatPack::ButtonGroup::Component` takes `style:`. The default is `:default`. On `variant: :outlined`, the container sets `data-fp-style` and paints `--fp-button-background` and `--fp-button-border`. `:joined` does not set the attribute. With `collapse: :menu`, the attribute is on `.fp-button-group-menu__row`. `page_nav_button_group` forwards `style:`.

### Upgrade notes
- An outlined group fills with the surface (`--button-default-background-color` and `--button-default-border-color`) instead of a transparent background. Pass `style:` to paint another button style on the container. Children still take their own `style`, usually `:ghost`.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.314`.

## [0.1.313] - 2026-10-26

### Changed
- `DateInput` and `DateRangeInput` render the picker popup through internal `FlatPack::DatePicker::Panel` and share field helpers through `FlatPack::DatePicker::Field`. Public kwargs, rendered HTML, data attributes, and Stimulus identifiers are unchanged.

### Upgrade notes
- No host changes. Keep calling `FlatPack::DateInput::Component` and `FlatPack::DateRangeInput::Component`.
- A prepend on `DateRangeInput` that overrides `quick_range_presets` and `preset_range_for` still adds a preset. `FlatPack::DatePicker::Panel` renders the list those methods return.
- Private `DateInput#picker_nav_button_classes` is gone. Month navigation is a `FlatPack::Button::Component`.
- Private `DateInput#default_picker_placeholder` is now `picker_placeholder`. `DateRangeInput` implements the same method. It used to inline the range placeholder.
- Redeploy so `meta.gem_version` shows `0.1.313`.

## [0.1.312] - 2026-10-26

### Added
- `FlatPack::Flash::Component` turns a flash hash the caller passes into Flatpack UI. `as: :alert` stacks `FlatPack::Alert::Component`. `as: :toast` renders `FlatPack::Toast::Component` inside `FlatPack::Toasts::Region::Component`. The existing toast controller shows those toasts on load and dismisses them on the toast timeout, including when Turbo inserts the markup. Default styles: `notice` and `success` map to success, `alert`, `error`, and `danger` map to danger, `warning` maps to warning, `info` maps to info, and any other key maps to info. `styles:` overrides keys for that call. Blank values are skipped. Array values render one message each. Message text is escaped.

### Upgrade notes
- Opt in where you render flash: `render FlatPack::Flash::Component.new(flash: flash, as: :toast)`. Pass `flash:` on each call.
- No new Stimulus controller. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.312`.

## [0.1.311] - 2026-10-26

### Changed
- `flat_pack` depends on `view_component` `>= 4.14`, `< 5`. The previous constraint was `~> 4.12.0`.

### Fixed
- `~> 4.12.0` blocked the fix for GHSA-8qw7-6phv-7q6p (`view_component` <= 4.12.0). A reused component instance could leak `with_content` and slot content into a later render. ViewComponent 4.14.0 raises `ViewComponent::ReusedInstanceError` on a second render. The lockfiles resolve `view_component` 4.19.0.
- The lockfiles resolve `crass` 1.0.8. `loofah` already allows that release.

### Upgrade notes
- Run `bundle update view_component`. Render each component instance once. A second render raises `ViewComponent::ReusedInstanceError`.
- ViewComponent 4.18 enables caching support on every component and renames `ViewComponent::ExperimentallyCacheable` to `ViewComponent::Cacheable`. Remove `include ViewComponent::ExperimentallyCacheable` if a host added it. FlatPack components do not include it.
- Redeploy so `meta.gem_version` shows `0.1.311`.

## [0.1.310] - 2026-10-23

### Added
- `FlatPack::PageLayout::Component` takes `top_nav_width:`. `:content` (the default) keeps the bar the full window and constrains `.fp-page-layout-top-nav-column` to the same measure and inline inset as the column. `:full` leaves the slot content full width. Anything else raises `ArgumentError`. The wrapper does not name Top Nav.
- `FlatPack::TopNav::Component` takes `padding:`. `:default` keeps `--top-nav-padding-inline`. `:none` drops that inset and keeps the side safe area. Anything else raises `ArgumentError`.

### Upgrade notes
- Page Layout now aligns the top bar's content with the column. Pass `top_nav_width: :full` when the slot should span the window, including a floating cluster that uses the row's own padding.
- Pass `padding: :none` on Top Nav when that slot already supplies the inset and the controls should meet the column edges. The side safe area stays.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.310`.

## [0.1.309] - 2026-10-23

### Changed
- `FlatPack::TopNav::Component` is a layout row. It keeps the `<header>`, the three slots, the height, the gap, the inline padding, the safe-area insets, and `min-width: 0`. It has no fill, border, shadow, or scroll frost.
- `SidebarLayout` and `PageLayout` wrap the `top_nav` slot in `.fp-layout-top-nav`. That wrapper is the bar: sticky, `--top-nav-background-color`, a hairline from `--top-nav-border-color`, and `--top-nav-backdrop-blur` after scroll. `flat-pack--top-nav` sets `data-scrolled` on the wrapper.
- `content_scroll:` is a position on that bar. `:below` (the default) keeps the bar above the page. `:behind` lets the page scroll under it and pads with `--top-nav-height` plus the top safe area. `scroll: :page` works with both.
- `FlatPack::Card::Component` no longer sets `h-full`. A card in a grid still stretches with the cell. Pass `class: "h-full"` when the card should fill a parent that already has a height.
- A `collapse: :menu` trigger with `menu_label` shows that word, then a trailing icon. The default trailing icon is `chevron-down`. There is no leading icon. Omit the label and the trigger is still the bars glyph, labelled "Menu". `menu_icon:` replaces the icon and keeps that place: alone, or after the label.

### Removed
- `floating_top_nav:` on `SidebarLayout` and `PageLayout`. Passing it raises `ArgumentError`.
- The floating wrapper, `--top-nav-float-*`, and the CSS that turned Top Nav sections and right-slot children into cards.
- `data-flat-pack-top-nav-section`.
- The clearance measurement in `sidebar_layout_controller.js`.

### Fixed
- The skip link rests far enough off the page that its shadow no longer paints a grey band along the top edge.

### Upgrade notes
- Stop passing `floating_top_nav:`. A floating cluster is a `Card` in a Top Nav slot around content that has no surface of its own: `FlatPack::Card::Component.new(padding: :sm, radius: :xxxl, shadow: :sm)`. `radius: :xxxl` is the roundest card corner. A segmented control or a pill button already has a surface, so it sits in the slot directly. A bare icon is a card at `--button-round-size-md` with `padding: :none` and `radius: :xxxl`. Card does not set `h-full`. There is no new pill component. The host supplies the inset with its own margin (`--sidebar-float-inset`, `1rem`). Top Nav does not.
- A card that used to fill a fixed-height parent because of `h-full` now sizes to its content. Pass `class: "h-full"` on that card.
- A labeled `collapse: :menu` trigger no longer draws the bars glyph in front of the word. The word is followed by `chevron-down`, unless `menu_icon:` names another icon. An omitted label is still the bars glyph.
- `content_scroll` now applies to the full-width bar. The default is `:below`. Pass `:behind` when the page should scroll under the bar. The old default `:behind` only applied while the top nav floated.
- Stop reading `data-flat-pack-top-nav-section`, `data-flat-pack-top-nav-floating`, and `--top-nav-float-*`.
- Reload kit CSS and JS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`. A generated top nav is still the plain row. The comment in that template shows the card.
- Redeploy so `meta.gem_version` shows `0.1.309`.

## [0.1.308] - 2026-10-23

### Changed
- `FlatPack::TopNav::Component` is a left, center, and right row at every width. `left` and `right` use `min-w-0`, so a long title can shrink inside the column. A field in any slot uses `min-width: 0` and stays inside that column. The bar still frosts after scroll. `data-flat-pack-top-nav-section` is unchanged, so floating cards still key off it.

### Removed
- `mobile_menu`, `mobile_menu_label`, and `mobile_breakpoint`.
- `always_display:` on the `left`, `center`, and `right` slots, and `data-flat-pack-top-nav-always-display`.
- The hamburger toggle, the mobile panel, and the fold in `top_nav_controller.js` (`collapseIntoMenu`, the bell hoist, panel open and close, and the resize watchers used only for that fold). The controller now only frosts the bar.
- The `flatpack.top_nav.more` locale key.

### Upgrade notes
- Stop passing `mobile_menu`, `mobile_menu_label`, `mobile_breakpoint`, and `always_display:`. Passing one raises `ArgumentError`.
- Top Nav does not fold. Put actions that should become one phone menu in `FlatPack::ButtonGroup::Component.new(collapse: :menu)`, usually in `right`. A bell or an avatar stays a plain child beside that group.
- The header row is `flat_pack_page_nav_tag` on the left and `page_nav_button_group(styles:, collapse: :menu, visible: 2)` on the right. That group is the only phone menu.
- `rails generate flat_pack:layout` writes that group around the New action, with the bell beside it. Replace a generated top nav that expected the bar to fold.
- Reload kit CSS and JS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.308`.

## [0.1.307] - 2026-10-23

### Added
- `FlatPack::ButtonGroup::Component` takes `variant:`. `:joined` (the default) is the merged row. `:outlined` is a bordered desktop container. Children keep their own border, radius, and fill. The container radius is `--button-group-radius` (`--radius-md` on the default theme, `--radius-full` on rounded). The overflow trigger is ghost when the variant is outlined, and secondary when it is joined.
- `page_nav_button_group` accepts `variant:` and passes it to the group.
- `overflow_icon:` on the button group and on `page_nav_button_group`. Omit it for `ellipsis-horizontal` when `overflow_label` is omitted, and `chevron-down` when a label is set.

### Changed
- An omitted or blank `overflow_label` shows the icon alone. The accessible name stays the locale string "More" (`aria-label`). A set label shows that text, then the trailing icon. The icon is not also drawn in front of the text.

### Upgrade notes
- Pass `variant: :outlined` for a quiet desktop row. Pass `style: :ghost` on each child when those actions should read as links. The group does not restyle them.
- Pass `overflow_label: "More"` when the overflow trigger should show that word. It is followed by a chevron. Omit the label for the ellipsis alone. Pass `overflow_icon:` to use another Heroicon in that same place.
- `--button-group-radius` is `--radius-md` until `[data-theme~="rounded"]`, where it is `--radius-full`. Ghost hover stays on `--button-border-radius`, which is the same pill on rounded.
- `collapse: :menu` still folds every child into the phone menu. The outline is the wide row.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.307`.

## [0.1.306] - 2026-10-23

### Added
- `FlatPack::ButtonGroup::Component` takes `visible:`. The first that many children stay in the joined row. The rest sit in a trailing More menu. `overflow_label:` sets that trigger's text. The default is "More", with an ellipsis icon.
- `group.button(child, overflow: true)` forces that child into the More menu. `overflow: false` keeps it in the row. Those flags win over `visible:`. Visible children keep their order. Overflow children keep theirs. Each overflow row is that child's `menu_row`. A nested dropdown is a `Menu::Collapse`. A danger row is red text.
- With `collapse: :menu`, the phone menu still lists every child once, in the order they were added. Without `collapse: :menu`, the More menu stays on the row.
- `register_page_nav` accepts `overflow:` on a link or a component and passes it to that child. `page_nav_button_group` accepts `visible:` and `overflow_label:` and passes both to the group.
- `FlatPack::Button::Dropdown::Component#menu_html` places already-rendered HTML in the menu.

### Fixed
- A dropdown at the end of a button group, including the More trigger, no longer paints a dark right edge. The segment's outer corner and border match the other children.

### Upgrade notes
- Pass `visible:` when a wide row should keep a fixed number of actions. Pass `overflow: true` on a child that should always sit under More, such as Delete.
- `register_page_nav "Delete", path, role: :destructive, overflow: true` then `page_nav_button_group(styles:, collapse: :menu, visible: 2, overflow_label: "More")`.
- A host component in that menu still implements `menu_row` and returns HTML. Do not repeat an `id` that `call` already renders.
- Reload kit JavaScript so choosing a More row closes the menu. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.306`.

## [0.1.305] - 2026-10-22

### Added
- `page_nav_button_group(styles:, from: :default, collapse: false)` on `FlatPack::PageNavRegistryHelper`. It reads one bucket and renders `FlatPack::ButtonGroup::Component`, in registration order. A link becomes a button through the `styles:` role map. A registered component is passed through. `collapse:` is passed to the button group. An empty bucket returns nil.

### Changed
- `PageLayout` and `SidebarLayout` do not read the page nav registry and do not place the buttons. The view registers items, then calls `page_nav_button_group` in its own markup. The page-nav registry demo puts the title on the left and the group on the right (`QUIET` in the sidebar shell, `SOLID` in Page Layout), with `collapse: :menu`.

### Removed
- `mobile_actions` on both shells. The shells no longer fold a button group or pin a primary link. `.fp-page-nav`, `.fp-page-nav--desktop`, `.fp-page-nav--bar`, `.fp-page-nav--floating`, and `.fp-page-nav--pin-row` are gone. `PageNavRoleStyles::PIN` remains a style map.
- The `actions` slot on both shells.

### Upgrade notes
- Stop passing `mobile_actions` and `layout.actions`. Register, then draw the group in the page: `page_nav_button_group(styles: FlatPack::PageNavRoleStyles::QUIET, collapse: :menu)`. Page Layout uses `SOLID`. A call before `register_page_nav` returns nil.
- The pinned phone button is not drawn. `PageNavRoleStyles::PIN` is still the medium solid primary map if a host renders that link.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`. Delete an `actions` block from a layout you already generated. `rails generate flat_pack:layout` no longer writes one.
- Redeploy so `meta.gem_version` shows `0.1.305`.

## [0.1.304] - 2026-10-22

### Fixed
- The open phone panel measures its vertical offset the same way it measures the horizontal one. A transformed shell ancestor no longer places the panel below the toggle.

### Changed
- A collapsing button group asks each child for `menu_row`. `Button::Component#menu_row` is a plain row (label, href, icon; danger is red text). `Button::Dropdown#menu_row` is a `Menu::Collapse` of that dropdown. A host component can implement the same method. A child that does not return HTML from `menu_row` is shown as itself in the wide row and again in the phone menu.

### Removed
- Top Nav no longer turns a dropdown inside the phone menu into an in-place disclosure. The controller no longer stamps `data-flat-pack-top-nav-disclosure` or `data-flat-pack-top-nav-expanded`, and it no longer captures the trigger click. The panel CSS for that disclosure is gone. A dropdown that folds into the hamburger stays a normal `Button::Dropdown` and opens its own menu on `document.body`.
- The unlayered rule `.fp-top-nav [data-flat-pack-top-nav-section="center"] input { min-width: 0 }` is gone. The center section still has `min-w-0`.
- The button group no longer reads `menu_rows` or `trigger_label`, no longer renders a hidden dropdown beside a cloned menu collapse, and no longer styles `[data-flat-pack--button-dropdown-target="trigger"]`.
- The button group script no longer treats a portaled dropdown menu as inside the group. `data-flat-pack-dropdown-owner` is removed. Opening a dropdown no longer assigns an id for that stamp.

### Upgrade notes
- `data-flat-pack-top-nav-disclosure` is removed. Stop reading or styling that hook, and stop reading `data-flat-pack-top-nav-expanded`.
- A dropdown inside the phone menu is the dropdown's own menu. It is not a nested disclosure.
- Implement `menu_row` on a component you put in a collapsing button group when the phone menu should not be a second copy of the wide control. Return HTML. Do not repeat an `id` that `call` already renders.
- Stop reading `data-flat-pack-dropdown-owner`. Stop styling `.fp-button-group-menu__dropdown`, `.fp-button-group-menu__inline`, and `.fp-button-group-menu__choice`.
- A dropdown joins a button group only as the direct child. A wrapper around it keeps the dropdown's own shape.
- Reload kit CSS and JavaScript. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.304`.

## [0.1.303] - 2026-10-22

### Changed
- The page nav registry is data only. `register_page_nav` records a link (`label`, path, `role:`, `icon:`, `data:`, `aria:`) or a component (`component:`, `role:`). `into:` names the bucket and defaults to `:default`. `page_nav_items(from:)` returns those descriptors in registration order. The registry does not render, place, or style.
- `FlatPack::PageNavRoleStyles` maps a role to a button style and size. `SOLID`, `QUIET`, and `PIN` are the maps the shells use. A caller can pass its own role → `{style:, size:}` map. Roles stay `:primary`, `:secondary`, and `:destructive`. `QUIET` `:secondary` is the bordered subtle button (`:secondary`, small). `QUIET` `:primary` stays subtle and `QUIET` `:destructive` stays danger. `SOLID` and `PIN` are unchanged.
- `PageLayout` draws the default bucket with `SOLID`. `SidebarLayout` draws it with `QUIET`. Links and registered components go in one `ButtonGroup` with `collapse: :menu`, in registration order. A component is passed through as the gem built it. The wide layout is the joined row and the narrow layout is that same group as a menu. `mobile_actions: :floating` still pins the primary link. A component is not pinned.

### Removed
- `render_page_nav`, `place:` (`:group`, `:menu`, `:floating`), and the `:header` / `:top_nav` context. `FlatPack::PageNavStyles` and `FlatPack.configuration.page_nav_styles` are gone.
- The shell no longer injects page nav into Top Nav, and it no longer renders a fallback Top Nav for that menu. `.fp-page-nav-menu` and `.fp-page-nav-nav` are gone.

### Upgrade notes
- Delete `config.page_nav_styles`. Delete `render_page_nav`. Read `page_nav_items` and render the buttons, a `collapse: :menu` button group, or `Menu::Collapse` yourself. `FlatPack::PageNav` (the back and close row) is unchanged.
- `into:` is the bucket. Omit it for `:default`, which is the bucket the shells draw. A named bucket stays out of the shell.
- Page nav on a phone is the button group's menu, in the page nav bar. It is not a row inside the Top Nav hamburger.
- Reload kit CSS and JavaScript. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.303`.

## [0.1.302] - 2026-10-22

### Added
- `FlatPack::Menu::Collapse::Component` is a labelled menu row that opens the next rows in place. `title:` is required. `icon:` and `open:` are optional. The `items` slot is the row content.

### Fixed
- A dropdown inside a collapsing button group opens in the phone panel as that inline section. The wide row still uses the floating dropdown, joined into the segment.

### Upgrade notes
- Reload kit CSS and JavaScript. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.302`.

## [0.1.301] - 2026-10-22

### Fixed
- The open phone panel of a collapsing button group reads as a menu. Rows are flat and full width. A `data-fp-style="danger"` row is red text. A dropdown trigger in that panel uses the same row. The joined desktop row is unchanged.

### Upgrade notes
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.301`.

## [0.1.300] - 2026-10-22

### Fixed
- A dropdown inside a button group joins the row. The segment rules reach the dropdown trigger, including when another element wraps the dropdown. This applies to the plain group and to `collapse: :menu` from `collapse_at` up. The stacked phone menu is unchanged. A dropdown outside a button group keeps its own radius.

### Upgrade notes
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.300`.

## [0.1.299] - 2026-10-22

### Fixed
- A collapsing button group stays open when the pointer goes down in a child dropdown menu. Opening a dropdown stamps `data-flat-pack-dropdown-owner` on the menu with the dropdown root's id. The group ignores that press when the root is inside the group. A press outside both still closes the group.

### Upgrade notes
- Reload kit JavaScript. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.299`.

## [0.1.298] - 2026-10-22

### Added
- `FlatPack::ButtonGroup::Component` accepts `collapse: :menu`. From `collapse_at:` up (768px) the group is the joined row. Below that, a hamburger trigger opens the same panel as a vertical menu. Each button is rendered once.

### Upgrade notes
- `collapse:` defaults to `false`. Groups that omit it stay a joined row.
- Opt in with `collapse: :menu`. `menu_label:` is the trigger text and the group's accessible name. Omit it for an icon-only trigger labelled "Menu". `menu_icon:` defaults to `"menu"` (the bars glyph). `collapse_at:` is a positive pixel width.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.298`.

## [0.1.297] - 2026-10-22

### Fixed
- The dummy demo pages that read Postgres render when the connection is refused or their tables are missing. Collection editor, modal filter, the data tables, infinite pagination, movable cards, comments, chat, articles, and sign-in no longer answer with an empty 500. Other database errors still raise. Sorting, filtering, dragging, chat, comments, the collection editor, and sign-in still use Postgres when it is up.
- The dummy app serves `public/406-unsupported-browser.html` when `allow_browser` blocks an old browser, instead of raising because that file was missing.
- Comments say when Postgres is down, and a different warning when the comments table is missing. Chat shows a warning when the inbox cannot load.
- Seeded demo table rows take a category from the filter list, in row order, so technology, business, marketing, and design each return rows.

### Upgrade notes
- Dummy App Platform keeps `bundle exec rails db:prepare && bundle exec puma -C config/puma.rb`. Do not add `db:seed` to that run command. `db:prepare` seeds a database only when it creates it. Load demo rows later with `bundle exec rails db:seed`, or with an App Platform pre-deploy job that the owner approves first.
- Redeploy so `meta.gem_version` shows `0.1.297`. Hosts that do not run the dummy app are unchanged.

## [0.1.296] - 2026-10-22

### Changed
- Page actions are page nav. `register_page_nav` registers an item for the current request. `FlatPack::PageNavItem` is one item. `FlatPack::PageNavRegistry` keeps them, in source order, on `request.env["flat_pack.page_nav_registry"]`. `render_page_nav` is the only renderer.
- Two forms. A semantic item is `register_page_nav "Label", path, role:, icon:, data:, aria:`. A pre-built component is `register_page_nav component:, role:`. `role:` is required (`:primary`, `:secondary`, or `:destructive`). A component renders as the gem built it. Its role places and orders it. The style map does not restyle it.
- The role map is host-owned and lives on `FlatPack::PageNavStyles`, apart from `FlatPack::PageNav::Component` (the back and close row). Set `FlatPack.configuration.page_nav_styles` once in an initializer. A layout passes `styles:` to `render_page_nav`. Resolution is that map, then `page_nav_styles`, then `FlatPack::PageNavStyles::DEFAULT_STYLES`. A gem emits roles. It does not write the map.
- A registered component is one DOM node. It stays in the page nav bar on desktop and on a phone. It is not copied into the phone menu, so a Turbo Stream can target its wrapper id. Semantic buttons still render in the desktop group and fold into the phone menu. `mobile_actions: :floating` still pins the primary button.

### Upgrade notes
- Replace `page_action` with `register_page_nav` and pass `role:` every time. Replace `page_actions` with `render_page_nav`. There is no alias. `register_page_nav` is not `flat_pack_page_nav`.
- Set `config.page_nav_styles` inside `FlatPack.configure` to change button style and size. The default matches the previous `:header` and `:top_nav` maps. Read it from `FlatPack::PageNavStyles`, not from `FlatPack::PageNav`.
- A component registered with `register_page_nav component:` renders once. Do not expect a second copy in the phone menu.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.296`.

## [0.1.294] - 2026-10-21

### Added
- `page_action` nominates a page-level action for the current request: label, path, `role:` (`:primary`, `:secondary`, or `:destructive`), `icon:`, and pass-through `data:` / `aria:`. The view decides which actions exist and what they mean. It does not pass a CSS class, a button style, or a placement.
- `FlatPack::PageActionRegistry` collects those actions in source order. The helper stores one registry on `request.env["flat_pack.page_actions"]`. A new request starts empty.
- `FlatPack::PageActions` maps a role to a button style and size. `:header` is a solid primary (`:primary`), a subtle secondary (`:secondary`), and `:danger`, at `:sm`. `:top_nav` is a subtle primary (`:secondary`), a ghost secondary (`:ghost`), and `:danger`, at `:sm`. `styles:` replaces any role's button style for that call.
- `page_actions` renders that map as a `ButtonGroup` for `:header` and `:top_nav`.
- Sidebar Layout places the `:top_nav` group in a bar under the top nav from the `md` breakpoint up. Page Layout places the `:header` group at the top of the column. Below `md`, both shells put the actions in the Top Nav hamburger as full-width rows, using the `:top_nav` map. An empty registry adds no markup.
- `mobile_actions: :floating` on either shell pins the primary action to the bottom-right on a phone. The default is `:menu`.

### Fixed
- The Top Nav phone menu stays inside the viewport when a shell ancestor is the fixed containing block. Page-action rows in that menu are not clipped off the left edge.
- A horizontal cluster in that menu becomes one full-width row per control, including a search field and a dropdown. The dropdown still discloses in place. A control with `data-flat-pack-top-nav-always-display="true"` stays in the bar. The demo notification bell uses it and stays beside the hamburger.

### Upgrade notes
- Call `page_action` in the view. Sidebar Layout and Page Layout place the buttons. A custom layout calls `page_actions(:header)` or `page_actions(:top_nav)` and puts the group where it wants. Pass `styles: { primary: :ghost }` to replace a role's button style.
- On a phone the actions join the Top Nav menu. The host Top Nav needs its mobile menu (the default). A shell with no top nav renders one for that menu, hidden from `md` up.
- Pass `mobile_actions: :floating` to pin the primary action to the bottom-right instead of the menu. Other actions stay in the desktop group.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.294`.

## [0.1.293] - 2026-10-21

### Added
- `aside(mobile: :stack)` lays the aside under main below `md`. `:drawer` stays the off-canvas panel. Anything else raises `ArgumentError`.
- `layout.aside_trigger("Details")` is the aside button. The label, `aria-expanded`, and `aria-controls` are on the control.

### Fixed
- The menu button gets `aria-expanded` and `aria-controls` when the rail drawer opens, closes, and on connect.
- On a phone, the Top Nav row folds into one hamburger menu labelled "Menu". The open menu is one column of full-width rows. A nested dropdown stays a parent row and discloses its items in place, indented under that row. A wide window keeps the row. The sidebar's mobile toggle stays in the bar and is only that button. A notification bell stays in the bar when its section passes `always_display: true`. Page Nav stays one row.
- An open phone drawer paints `--drawer-backdrop-color` on the shell scrim, above the page and below the drawer.
- Phone drawers animate `translate` and `transform`. `prefers-reduced-motion: reduce` snaps the slide.
- A stacked aside below `md` uses the floating panel fill, border, radius, and shadow. A close control and an aside trigger stay hidden there. The gap under main is `--stack-gap-md`.
- On the rounded theme, a phone drawer rounds its inner edge with `--sidebar-float-radius`. The outer edge stays flush. The rail and the aside share that corner and one backdrop.

### Upgrade notes
- `mobile:` on `aside` defaults to `:drawer`. Pass `:stack` to drop the phone drawer. There is no alias.
- Replace a hand-wired `asideToggle` button with `layout.aside_trigger("Details")` where the control should sit. A hand-wired button still works. The controller now also sets `aria-controls`.
- Reload kit CSS and JS. Do not rerun `bin/rails generate flat_pack:install`. Page Nav is one row. On a phone the Top Nav row folds into the hamburger menu, one action per row. A nested dropdown in that menu discloses in place. `left` folds too. Pass `always_display: true` on a section that should stay in the bar, such as the notification bell.
- Load `flat_pack/application.css` after Tailwind. Keep `transform`, `filter`, `will-change`, and `contain` off ancestors of the shell. Those pin the fixed drawers to the ancestor.
- Redeploy so `meta.gem_version` shows `0.1.293`.

## [0.1.292] - 2026-10-21

### Changed
- Layout and panel scrollers hide the bar. `--pane-scrollbar-width` defaults to `none` and is applied as `scrollbar-width`. A theme may set `thin` or `auto`. Older Safari hides the WebKit bar when `scrollbar-width` is unsupported, unless the pane opts into the browser bar.
- `scrollbar: :hidden` (default) or `:visible` on Sidebar Layout (the main pane and the aside), Drawer, and Modal. Other values raise `ArgumentError`. `:visible` uses the browser bar.
- A hidden pane is in the tab order (`tabindex="0"`) with an accessible name, so arrow keys and Page Down scroll it when nothing inside can take focus. The main pane is not a second landmark. The aside keeps its landmark. Drawer, Modal, and the chat message list use `role="region"`. Focus uses `--color-ring`.
- A soft edge fade marks the side that still has content. It uses `animation-timeline: scroll(self)` and `--pane-scroll-fade-size` (`2.5rem`). Browsers without scroll-driven animations skip the fade. `prefers-reduced-motion: reduce` skips it too.
- The sidebar nav and the chat message list follow the theme token. Tables, code blocks, horizontal scrollers, and menu listboxes keep a visible bar. Page Layout still scrolls the window. `.fp-scrollbar-hidden` stays on Overflow Row.

### Upgrade notes
- New tokens: `--pane-scrollbar-width` (`none`) and `--pane-scroll-fade-size` (`2.5rem`). Set them on a theme. There is no Ruby setting for the width.
- `scrollbar: :visible` on Sidebar Layout, Drawer, or Modal shows the browser bar on that pane. The default is hidden.
- Hidden panes are a new tab stop.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.292`.

## [0.1.291] - 2026-10-21

### Changed
- `--surface-page-background-color` is the tinted canvas and `--surface-background-color` is the raised layer. They no longer match. Default page stays `#f8f9fa` and the surface is `#fff`. Dark page is `oklch(0.12 0.01 250)` and the surface is `oklch(0.19 0.015 250)`. Ocean page is `oklch(0.96 0.018 220)` and the surface is `#fff`. Rounded keeps whichever light or dark palette it is paired with.
- Cards use `--card-border-width` and `--card-shadow`. The default is a 1px border and no shadow. Rounded is no border and `--shadow-sm`. Omit `border:` and `shadow:` to take those tokens. Pass `:none`, `:default`, or `:strong`, and `:none`, `:sm`, or `:md`, to override one card.
- Focus ring offsets, the avatar group ring, swatch ring gaps, the range thumb border, the timeline marker dot, and the switch thumb follow the page. A card, modal, popover, menu, table, accordion, collapse, or chat resets the ring, gap, and marker dot to its own fill. Skip-link text stays the surface colour, because that chip uses it as inverse ink.
- `FlatPack::Card::Component` and `FlatPack::Card::Stat::Component` take `background:` (`:default`, `:none`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`). `style:` is removed. `:none` is transparent and inherits the surrounding text. The other fills still set matching text and muted text. Unknown values raise `ArgumentError`.
- Card fill tokens are `--card-background-{name}`, `--card-background-{name}-text-color`, `--card-background-{name}-muted-text-color`, and `--card-background-{name}-border-color`. The fill drops the extra `-background` suffix, so the brand fill is `--card-background-brand`. `:none` adds `--card-background-none` (`transparent`), `--card-background-none-text-color` (`inherit`), `--card-background-none-muted-text-color` (`inherit`), and `--card-background-none-border-color`.

### Upgrade notes
- Hosts that painted a card with no border and no shadow now get the theme edge. On the default palette that is still a 1px border. On rounded it is a soft shadow and no border.
- Replace Card and Card Stat `style:` with `background:`. There is no alias. `style:` raises `ArgumentError`.
- Rename host overrides from `--card-style-{name}-background` to `--card-background-{name}`, and from `--card-style-{name}-text-color` (and the muted and border parts) to `--card-background-{name}-text-color`. Dark mode overrides `--card-background-gradient`.
- A border-only card is `background: :none`. On rounded, also pass `border: :default`, because `--card-border-width` is `0`.
- Rebuild host Tailwind so the renamed background classes are generated, including `[background:var(--card-background-brand)]` and `[background:var(--card-background-none)]`.
- New tokens: `--card-border-width`, `--card-shadow`. Set them on a host theme when the card edge should differ. Do not restate them on a nested `[data-theme]` colour block, or a dark region inside rounded snaps back to a 1px border.
- Dark muted, hover, active, border, and muted text moved up with the surface so secondary, ghost hover, and alerts still read. Reload kit CSS. Do not rebuild Tailwind for the colour tokens. A Tailwind rebuild is needed only if the host scans `shadow-[var(--card-shadow)]` and `border-[length:var(--card-border-width)]` itself. The gem classes are in the component source.
- Redeploy so `meta.gem_version` shows `0.1.291`.

## [0.1.290] - 2026-10-21

### Added
- `FlatPack::PageLayout::Component` arranges a public page: optional top nav, one column, optional footer, and an optional `background` photo. `width:` is `:narrow`, `:default`, `:wide`, or `:full`. `align: :center` centers the column in the viewport. `:top` is the default.
- The floating top bar is one implementation. Sidebar Layout and Page Layout both use it. The markup and the card styles are unchanged.

### Upgrade notes
- New shell. Hosts that do not render it are unchanged. Sidebar Layout markup is unchanged.
- `width:` accepts only `:narrow`, `:default`, `:wide`, or `:full`. There is no length and no class override.
- New tokens: `--page-layout-width-narrow` (`40rem`), `--page-layout-width-default` (`56rem`), `--page-layout-width-wide` (`72rem`), `--page-layout-width-full` (`100%`), `--page-layout-padding-inline` (`var(--space-4)`, then `var(--space-6)` from `640px`), `--page-layout-padding-block` (`var(--space-6)`), `--page-layout-gap` (`var(--space-6)`). Rounded does not restate them. Its larger spacing steps make the padding generous. `--page-layout-width` is the width the shell writes on the page. It is not a theme token. Do not set it on `:root`.
- The `background` slot renders Backdrop and pins it, the same way Sidebar Layout does.
- The shell has no controller, no storage, and no cookie. It renders complete on the server.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.290`.

## [0.1.289] - 2026-10-21

### Changed
- Trackless pill rows on `FlatPack::Button::Pill::Component` and Tabs `variant: :pills` no longer add group padding. The first pill lines up with the surrounding content. The row shifts left by about 8px. Consumers don't need to change anything.
- `track: true` (default `false`) opts a pill row into a bordered track. The border uses `--tabs-pill-list-border-color`. The fill uses new `--tabs-pill-list-background-color`, which defaults to `transparent`. The inset reuses `--pill-padding`. The corner stays `--tabs-pill-corner-radius`. Stacked tabs are unchanged. Underline tabs ignore `track`.

### Upgrade notes
- The default is `track: false`. Existing pill markup stays valid and sits flush.
- New token: `--tabs-pill-list-background-color`, default `transparent`.
- The sliding indicator measures from inside the group border, so a track still lines the marker up with the active pill.
- Hosts reload kit CSS and JS. Rebuild host Tailwind so it emits `bg-[var(--tabs-pill-list-background-color)]`. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.289`.

## [0.1.288] - 2026-10-21

### Added
- `FlatPack::Backdrop::Component` puts a blurred photo, a tint, and an edge fill behind any content. The `media` slot takes the host's `img`, `picture`, or `video`. The component clips to its container and follows that container's corner. Content styling stays with the host.
- `SidebarLayout`'s `background` slot renders Backdrop and still pins that layer to the viewport. The slot name is unchanged.

### Changed
- Backdrop owns `--backdrop-blur` (`40px`), `--backdrop-color` (`transparent`), `--backdrop-filter` (`saturate(1)`), `--backdrop-tint-color` (the page colour), and `--backdrop-tint-opacity` (`0.55`). Dark alone still sets the opacity to `0.78`. `[data-theme~="rounded"]` still sets the edge to `#2f2f2f`, the tint to `#000`, and the opacity to `0.18`, including on `rounded dark`.
- Removed `--layout-background-*` and `.fp-layout-background*`. There is no alias.

### Upgrade notes
- Rename host overrides from `--layout-background-*` to `--backdrop-*`. Same defaults. Same rounded wash.
- `layout.background` still takes the host's `img`, `picture`, or `video`. The shell still looks the same.
- Use Backdrop on a hero, a card, a modal, or a page that has no sidebar. Hero and Carousel are unchanged.
- Under `prefers-reduced-transparency: reduce`, or when `filter: blur()` is missing, the photo hides and the tint is solid.
- Reload kit CSS. Do not rebuild Tailwind for the component. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.288`.

## [0.1.287] - 2026-10-21

### Added
- `--layout-background-color` defaults to `transparent` and paints `.fp-layout-background`. That fill shows at the edge where the blur fades.
- `--layout-background-filter` defaults to `saturate(1)`. The photo filter is `blur(var(--layout-background-blur)) var(--layout-background-filter)`, including `-webkit-filter`.
- `[data-theme~="rounded"]` sets `--layout-background-color` to `#2f2f2f` (the default bottom-nav neutral), `--layout-background-tint-color` to `#000`, and `--layout-background-tint-opacity` to `0.18`. The block follows `[data-theme~="dark"]` at the same specificity, so `data-theme="rounded dark"` keeps `0.18` instead of `0.78`.

### Upgrade notes
- Base blur stays `40px`. Base tint stays the page colour at `0.55`. Dark alone stays `0.78`. The filter default stays `saturate(1)`.
- Rounded changes the photo wash: neutral edge `#2f2f2f`, black tint at `0.18`, including when dark is combined with rounded. A theme that is not rounded is unchanged.
- Set `--layout-background-color` for the edge. Set `--layout-background-filter` for extra filters, such as `brightness(0.93) saturate(0.75)`.
- Reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.287`.

## [0.1.286] - 2026-10-21

### Fixed
- `[data-theme~="rounded"]` sets `--sidebar-item-radius` to `var(--radius-md)` (0.5rem, 8px). Hover and active row highlights use that soft corner. The floating panel stays `--sidebar-float-radius: var(--radius-xxxl)` (2.5rem, 40px).

### Upgrade notes
- Visual change on the rounded theme. Sidebar row corners go from 1.75rem to 0.5rem. The floating panel stays 2.5rem. Dark, ocean, and the unset theme are unchanged.
- No new tokens. Hosts reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.286`.

## [0.1.285] - 2026-10-21

### Added
- `FlatPack::Button::Component` and `FlatPack::Button::Dropdown::Component` accept `size: :xs` on icon-only controls. The painted control is about 32px (`--button-icon-only-padding-xs`, and `--button-round-size-xs: 2rem` with no hit-target floor). The 44px tap stays on `.fp-hit-slop`. `size: :xs` without `icon_only: true` raises `ArgumentError`. `:sm`, `:md`, and `:lg` are unchanged. `:xs` is not in `SIZES`.
- `FlatPack::Card::Component` accepts `inset:` (`nil`, `:sm`, `:md`, `:lg`). `nil` keeps `--card-inset` tied to `padding:`. The other values set `data-fp-card-inset` and `--card-inset` from the existing `--card-padding-*` tokens, and add no padding.

### Upgrade notes
- Additive. Existing markup is unchanged when the new options are omitted.
- New tokens: `--button-icon-only-padding-xs` and `--button-round-size-xs`. No new card tokens.
- Do not rerun `bin/rails generate flat_pack:install`.
- Reload kit CSS for the tokens, `.fp-hit-slop`, and the card inset rules. Rebuild host Tailwind so it emits `p-[var(--button-icon-only-padding-xs)]`, `h-[var(--button-round-size-xs)]`, and `w-[var(--button-round-size-xs)]`. `inset:` does not add utilities.
- Pass an `aria-label` on `:xs`. Leave about 12px between adjacent `:xs` buttons so the 44px tap areas do not overlap.

## [0.1.284] - 2026-10-21

### Added
- Floating top nav cards read `--top-nav-float-padding-block`, `--top-nav-float-padding-inline`, and `--top-nav-float-gap`. The block padding defaults to `0.25rem`. The inline padding defaults to `max(0.25rem, min(0.75rem, calc(var(--top-nav-float-radius) - var(--sidebar-float-radius))))`. The row gap defaults to `0.75rem`. Below `768px` the inline padding stays `0.25rem`, the row gap stays `0.5rem`, and the gap inside `left` and `center` stays `0.25rem`.
- Bumped the gem version to `0.1.284`.

### Upgrade notes
- Additive. The three defaults match the previous hard-coded padding and row gap, including on `[data-theme~="rounded"]`. No visual change until a host sets one of the tokens.
- `--top-nav-float-padding-block` defaults to `0.25rem`. `--top-nav-float-padding-inline` defaults to `max(0.25rem, min(0.75rem, calc(var(--top-nav-float-radius) - var(--sidebar-float-radius))))`. `--top-nav-float-gap` defaults to `0.75rem`. Set the inline token to a plain length when the padding should ignore the radius.
- The full-width bar is unchanged. It still uses `--top-nav-padding-inline`.
- Hosts reload kit CSS. Do not rebuild Tailwind. Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.284`.

## [0.1.283] - 2026-10-20

### Added
- `FlatPack::SegmentedButtons::Component` accepts `indicator:`. Omit it, or pass `nil`, and the joined group is unchanged. `indicator: :slide` uses the pill track and `FlatPack::Shared::SlideIndicator` already used by Tabs `variant: :pills`. One indicator slides behind the labels. Each option stays a `FlatPack::Button::Component`, so `href:`, submits, Stimulus actions, and ARIA stay. `style:` and `size:` still apply. Omit `style:` for the neutral grey indicator. A named Button style, including `:primary`, paints the indicator that colour. Unknown `indicator` values raise `ArgumentError`.
- A click moves the indicator, sets `aria-pressed`, then dispatches cancelable `flat-pack--segmented-buttons:change` with `{ index, button }`. `preventDefault()` leaves the indicator on the previous option. The button action still runs. `selected: true` sets the first position. The indicator re-syncs on resize and on `turbo:render` / `turbo:load`. `prefers-reduced-motion` snaps. Motion uses `--duration-base` and `--easing-standard`.
- Bumped the gem version to `0.1.283`.

### Upgrade notes
- Additive. The default is `indicator: nil`. Existing segmented button markup and look stay the same. Tabs and Button::Pill markup stay the same.
- Hosts reload kit CSS and JS. Do not rerun `bin/rails generate flat_pack:install`. `flat-pack--slide-indicator` is already registered with the other controllers. Do not rebuild Tailwind. No new tokens.
- Redeploy so `meta.gem_version` shows `0.1.283`.

## [0.1.282] - 2026-10-20

### Added
- `FlatPack::SidebarLayout` accepts `scroll:`. The default is `:pane`, and that markup is unchanged. `:page` scrolls the window. `:page` with `content_scroll: :below` raises `ArgumentError`.

### Upgrade notes
- `scroll:` is additive. Hosts that omit it keep `:pane`.
- No new tokens. Do not rebuild Tailwind. The new rules are kit CSS. `md:sticky` is not a new utility.
- The layout generator writes `class="h-full"` on `html` and `body`. It does not write `overflow-hidden`. Leave `h-full`. It does not lock the window. Remove `overflow-hidden` from `html` and `body` when the host added that class. The generator does not. `:pane` hosts leave their lock in place.
- Do not rerun `bin/rails generate flat_pack:install`. Reload kit CSS and JS.
- Redeploy so `meta.gem_version` shows `0.1.282`.

## [0.1.281] - 2026-10-20

### Changed
- Column collapse is one boolean, `data-flat-pack-sidebar-collapsed`, written only by `FlatPack::SidebarLayout` on the column it owns. The menu reads that ancestor attribute. A menu used alone with `collapsed: true` writes the same attribute on its own `<aside class="fp-sidebar">`. `collapsed: false` does not write it.
- The layout still changes column width, persists `localStorage` (`"true"` collapses), honors `open:`, keeps the first-paint script on the column, and still collapses from resize. Each desktop apply dispatches `flat-pack--sidebar-layout:collapse` with `{ collapsed }` from the column.
- The menu owns the collapsed look in CSS, for the ancestor column and for a menu that carries the attribute. `flat-pack--sidebar` sets `aria-expanded` on the collapse and expand controls.
- Bumped the gem version to `0.1.281`.

### Upgrade notes
- There is no alias. Hosts reload kit CSS and JS. Do not rerun `bin/rails generate flat_pack:install`. Controllers stay `pin_all_from` the directory. Do not rebuild Tailwind. No new tokens.
- Removed `SidebarLayoutController` methods: `labelNodes`, `itemNodes`, `isSectionTitleLabel`, `sectionTitleNodes`, `groupPanelNodes`, `groupChevronNodes`, `footerNodes`, `headerRowNodes`, `headerBrandNodes`, `clearCollapsedRestState`, `applyCollapsedHeaderChrome`, `setCollapsedToggleButtons`, `syncToggleAria`, `updateCollapsedScrollContainerState`.
- Removed `SidebarController#toggleSection`. The menu controller now sets `aria-expanded` from the column.
- Removed layout targets `desktopToggle`, `collapsedToggle`, `headerLabel`, `headerBrand`, `headerRow`, `footer`, and the chevron query `[data-flat-pack--sidebar-layout-target="chevron"]`.
- Removed `collapsed_menu_script`. The layout no longer copies `data-flat-pack-sidebar-collapsed` onto `aside`.
- Removed selectors that hide the footer or labels from a layout target. Those rules are under `.fp-sidebar`. Drop `[data-flat-pack--sidebar-layout-target="footer"]` and `[data-flat-pack-sidebar-collapsed="true"] [data-flat-pack--sidebar-layout-target="scrollContainer"]`.
- New hooks: `flat-pack--sidebar`, `data-flat-pack-sidebar-toggle`, `fp-sidebar-brand`, `fp-sidebar-footer`, `fp-sidebar-scroll`, and the event `flat-pack--sidebar-layout:collapse`.
- Header buttons drop the `hidden` utility. Kit CSS shows the collapse chevron when the rail is open and the menu icon when it is collapsed, at `min-width: 768px`. Below that, both stay hidden.
- Redeploy so `meta.gem_version` shows `0.1.281`.

## [0.1.280] - 2026-10-20

### Changed
- A floating `FlatPack::SidebarLayout` column is the card. Border, radius, shadow, and `--sidebar-float-background-color` sit on the column for the rail and the aside. The column sets `--sidebar-background-color`, `--sidebar-header-background-color`, and `--sidebar-collapsed-frame` (`2px`). Contents fill the column.
- Floating panels use `--sidebar-float-inset` on the inner side as well as the top, bottom, and outer side.
- The floating resize handle is the column's inner edge. The hit strip straddles that border. Hover and `data-flat-pack-panel-dragging` paint the border with `--resize-handle-active-color`. Keyboard focus uses `--color-ring` on that border. A flush panel still draws the full-height `::after` line.
- Collapsed sidebar icons are centered by `FlatPack::Sidebar::Component` from `data-flat-pack-sidebar-collapsed` on the menu, using `--sidebar-collapsed-width`, `--sidebar-item-inset`, `--sidebar-item-padding-collapsed`, and `--sidebar-collapsed-frame`.
- A missing rail storage key keeps the server `open:` value. `open: false` stays collapsed after `flat-pack--sidebar-layout` connects, matching the first-paint script.
- Bumped the gem version to `0.1.280`.

### Upgrade notes
- The floating card styling now lives on the column. Hosts that styled `[data-flat-pack-sidebar-floating="true"] aside` directly should drop that CSS. There is no alias.
- Also drop `html[data-theme]:not([data-theme~="rounded"]) [data-flat-pack-sidebar-floating="true"] aside`. The square-corner reset is `html[data-theme]:not([data-theme~="rounded"]) [data-flat-pack-sidebar-floating="true"]` on the column.
- Drop `[data-flat-pack-sidebar-floating="true"][data-mobile-drawer-side="left"]` and `[data-flat-pack-sidebar-floating="true"][data-mobile-drawer-side="right"]`. Both sides use `--sidebar-float-inset`.
- Drop `[data-flat-pack-sidebar-floating="true"][data-flat-pack-sidebar-collapsed="true"] [data-flat-pack-sidebar-item="true"] > [data-flat-pack-sidebar-item-icon="true"]` and `[data-flat-pack-sidebar-floating="true"][data-flat-pack-sidebar-collapsed="true"] [data-flat-pack-sidebar-item="true"] > span.flex-shrink-0:first-child`. The menu rule is `.fp-sidebar[data-flat-pack-sidebar-collapsed="true"] [data-flat-pack-sidebar-item="true"] > [data-flat-pack-sidebar-item-icon="true"]` (and the same `span.flex-shrink-0:first-child` descendant).
- Drop `[data-flat-pack-sidebar-collapsed="true"] [data-flat-pack-sidebar-item="true"] > [data-flat-pack-sidebar-item-icon="true"]` and `[data-flat-pack-sidebar-collapsed="true"] [data-flat-pack-sidebar-item="true"] > span.flex-shrink-0:first-child`. Those selectors reached into the menu from the layout.
- Floating panels now have an inner inset, so a card no longer sits flush against main.
- A layout with `open: false` and an empty rail storage key stays collapsed. Hosts that counted on the controller expanding that rail should pass `open: true`, or write `"false"` to the storage key. That key stores the collapsed state, so `"true"` collapses the rail.
- The floating resize handle is now the panel edge. `--resize-handle-color` is unchanged. The floating handle does not draw `::after`.
- Hosts reload kit CSS and JS. esbuild and Vite hosts already register `flat-pack--panel-resize`. Importmap hosts already pin the controllers. Do not rerun `bin/rails generate flat_pack:install`.
- No new tokens. `--sidebar-collapsed-frame` is a length on the floating column, not a theme token.
- Redeploy so `meta.gem_version` shows `0.1.280`.

## [0.1.279] - 2026-10-20

### Changed
- `[data-theme~="rounded"]` sets `--form-control-radius` to `1rem` (16px). Text inputs, textareas, selects, search fields, date and number inputs, the date range trigger, and the comments inline input follow that token. Buttons, badges, tabs, chips, and the other component radii are unchanged.
- The rich text editor's field corners follow `--form-control-radius`. Toolbar buttons and bubble chrome stay on `--radius-md` and `--radius-sm`.
- Bumped the gem version to `0.1.279`.

### Upgrade notes
- Rounded-theme form controls go from a pill (`--radius-full`) to 16px corners. There are no token renames.
- Hosts reload kit CSS. The `rounded-[var(--form-control-radius)]` class already ships, so this token change does not need a Tailwind rebuild.
- Do not rerun `bin/rails generate flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.279`.

## [0.1.276] - 2026-10-20

### Added
- `FlatPack::Button::Dropdown::Component` accepts `icon_only:` and `round:`. Both default to `false`. `icon_only: true` requires `icon:` and an accessible name from `text:` or `trigger_attributes: { aria: { label: } }`. The name becomes the trigger `aria-label`. The label is not shown. `aria-haspopup` and `aria-expanded` stay. Padding, the circle sizes, the round radius, and `fp-hit-target` come from `FlatPack::Button::Component`.
- `show_chevron` defaults to `nil`. Omitted or `nil` shows the chevron on a labeled trigger and hides it on an icon-only trigger. `show_chevron: true` with `icon_only: true` raises `ArgumentError`. The component catalog reports that `nil` default.
- Bumped the gem version to `0.1.276`.

### Upgrade notes
- Additive. Two new options, `icon_only:` and `round:`. No removals. A labeled trigger renders the same markup.
- `round:` must be `true` or `false`. Anything else raises `ArgumentError`.
- No new tokens. No Tailwind rebuild. Reload kit CSS and JS if the host caches them. The classes already ship with Button.
- Do not rerun `bin/rails generate flat_pack:install`.
- A labeled trigger still shows the chevron when you omit `show_chevron`. An icon-only trigger hides it. The catalog default is `nil`.
- Redeploy so `meta.gem_version` shows `0.1.276`.

## [0.1.275] - 2026-10-20

### Added
- `FlatPack::SidebarLayout::Component` accepts `resizable:` (`true` or `false`, default `false`). `true` puts a separator on the rail. Drag and arrow keys set the desktop width. Double-click returns to the token, or to the measured content width when `width: :content`. A rail dragged or keyed below its minimum collapses through the existing collapse path.
- Slot `aside`. It sits on the opposite edge from `side:`. Call `layout.aside(open: true, resizable: false)`. `open:` defaults to `true`. `resizable:` defaults to `false`. Both must be booleans. The panel stays put on desktop and scrolls inside. `floating:` and `height: :content` apply the same way they do on the rail. A floating aside uses `--sidebar-float-radius`, so the rounded theme rounds it to `--radius-xxxl` (2.5rem), the same corner as the rail.
- Actions `toggleAside`, `openAside`, and `closeAside` on `flat-pack--sidebar-layout`. An optional `asideToggle` target gets `aria-expanded`. `openAside` and `closeAside` are idempotent.
- Below `768px` the aside is a drawer from its own edge. It reuses the shell drawer and the one backdrop. Opening one drawer closes the other. Escape closes the open drawer. Focus moves to the panel and returns to the opener. `closeMobile` closes whichever shell drawer is open.
- Stimulus controller `flat-pack--panel-resize`, on the column rather than the layout root.
- Tokens `--aside-width` (`20rem`), `--aside-min-width` (`16rem`), and `--aside-max-width` (`32rem`).
- Tokens `--resize-handle-color` and `--resize-handle-active-color`. The shared resize line uses `--resize-handle-color` at rest and `--resize-handle-active-color` on hover and while the button is down. The defaults are `--surface-border-color` and `--surface-muted-content-color`. Keyboard focus widens that line to 3px in `--color-ring` and draws a soft ring of the same colour on the line. A pointer drag does not leave that ring.
- `rails generate flat_pack:layout --aside` adds the slot and a close button. The flag defaults to off.
- Bumped the gem version to `0.1.275`.

### Changed
- `FlatPack::TopNav::Component` drops the `min-w-[30%]` reserve on each section. The center section is `min-w-0` and its search field can shrink. `mobile_breakpoint` is the bar's width, so a wide viewport with a narrow main column collapses into the existing chevron menu.

### Upgrade notes
- Existing layouts are unchanged. No `aside` slot means the same markup, classes, and backdrop. `resizable:` defaults to `false`.
- New argument `resizable:` on `FlatPack::SidebarLayout::Component`.
- New slot `aside`, with `open:` and `resizable:`.
- New tokens `--aside-width`, `--aside-min-width`, and `--aside-max-width`. Reload kit CSS. `--fp-panel-width` is a runtime length written on the column after a drag. Do not set it on `:root`. `--fp-panel-min`, `--fp-panel-max`, and `--fp-panel-default` are wiring on the column, not theme tokens.
- New tokens `--resize-handle-color` and `--resize-handle-active-color`. No removals. Hosts reload kit CSS.
- New Stimulus controller `flat-pack--panel-resize`.
- Storage, when `storage_key` is set. The unsuffixed key is unchanged: `"true"` means the rail is collapsed. `storage_key:aside` uses the opposite polarity: `"true"` means the aside is open. `storage_key:rail:width` and `storage_key:aside:width` are integer pixel widths. A missing aside key keeps the server `open:` value. The mobile drawer is not stored. Nothing is written when `storage_key` is nil.
- Do not rerun `bin/rails generate flat_pack:install`. Importmap hosts already pin `app/javascript/flat_pack/controllers` with `pin_all_from`. No new pin.
- Do not rebuild Tailwind unless the host sheet copies the sidebar width rules. Those hosts copy the new desktop width rules as well, or a drag looks stuck. Kit CSS is enough when the host sheet does not restate those rules. The aside tracks are kit CSS on `data-flat-pack-layout-columns` (`three`, `main-aside`, `aside-main`). The main track is `minmax(0, 1fr)`. There is no new Tailwind class.
- esbuild and Vite hosts must register `flat-pack--panel-resize`. Import `PanelResizeController` from `panel_resize_controller.js` and call `application.register("flat-pack--panel-resize", PanelResizeController)`.
- TopNav no longer reserves 30% for each section. `mobile_breakpoint` (default `768`) is the bar's width. A narrower bar, including the main column beside an aside, moves collapsible center and right content into the existing chevron menu. The center search can shrink above that width. Reload kit CSS and JS. No new controller.
- No removals. No renames.
- Redeploy so `meta.gem_version` shows `0.1.275`.

## [0.1.274] - 2026-10-20

### Added
- `FlatPack::PageNav::Component` renders items in call order. `with_item` is arbitrary content. `with_back`, `with_close`, `with_link`, and `with_action` are the styled pieces. `round:` (Boolean, default `false`) is passed to each of those buttons as `FlatPack::Button::Component`'s existing `round:`. `style:` and `size:` are the row defaults. No new tokens.
- `with_back` without `href:` is the history button. `fallback_url:` sets `data-flat-pack--page-nav-fallback-url-value`. `with_back(href:)` is a link and does not attach the page-nav controller. The click calls `history.back` when the visit has in-app history. Otherwise it assigns the fallback href. With no fallback href, it still calls `history.back`.
- View helpers `flat_pack_page_nav`, `flat_pack_page_nav_tag`, `flat_pack_return_to_url`, and `flat_pack_return_to_field`. With no block, `flat_pack_page_nav` renders the history back control and a close link when `anchor_href` is set. A block replaces that arrangement. `back_href:` and `anchor_href:` on the helper feed that default only.
- `rails generate flat_pack:layout` writes `flat_pack_page_nav_tag` into the sidebar layout, above `yield`.
- `FlatPack::ReturnTo` with `flat_pack_return_to` and `redirect_to_return_to(fallback:)`. The engine does not include the concern. `FlatPack::ReturnTo.origin_url` remains the only `url_from` check for `return_to`.
- Bumped the gem version to `0.1.274`.

### Removed
- `show_back:` on `FlatPack::PageNav::Component` and `flat_pack_page_nav`. Omit `with_back`.
- `right_slot` on `FlatPack::PageNav::Component` and `flat_pack_page_nav`. Use `with_action` or `with_item` at the position you want.
- `secondary_anchor_href`, `secondary_anchor_icon`, and `secondary_anchor_tooltip`. Use `with_link`.
- Component keywords `back_href`, `back_icon`, `back_tooltip`, `back_label`, `back_style`, `back_size`, `anchor_href`, `anchor_icon`, `anchor_tooltip`, `anchor_label`, `anchor_style`, and `anchor_size`. The helper still accepts the arrangement names, except `back_label` and `anchor_label`.

### Upgrade notes
- `PageNav::Component.new` with no item calls renders an empty row. Call `with_back`, or call `flat_pack_page_nav` with no block, to keep the history back button.
- A layout switches by calling `flat_pack_page_nav_tag`. Regenerate the sidebar layout, or paste the tag above `yield`, to pick up the default row.
- A non-blank `anchor_href` on `flat_pack_page_nav` wins. A valid `return_to` fills `anchor_href` only when the view did not set one. That default row passes the anchor to `with_close` and to the history back `fallback_url`. A custom block is not rewritten when `return_to` arrives. The filled anchor still feeds `flat_pack_return_to_url` and `flat_pack_return_to_field`.
- `round: true` passes through to Button on `with_back`, `with_close`, `with_link`, and `with_action`. `round: false` is the default. `with_item` content does not inherit it.
- No Tailwind rebuild. No `bin/rails generate flat_pack:install` rerun. Importmap hosts already pin the page-nav controller. Spacing stays on `gap-2`.
- Redeploy so `meta.gem_version` shows `0.1.274`.
- `show_back:` is gone. Before: `PageNav::Component.new(show_back: false, anchor_href: close_path)`. After: `PageNav::Component.new { |nav| nav.with_close(href: close_path) }`. There is no alias.
- `right_slot` is gone. Before: `nav.right_slot { render FlatPack::Button::Component.new(icon: "plus", icon_only: true, href: new_path, aria: { label: "Add" }) }` inside a nav that also rendered back. After: `nav.with_back` then `nav.with_action(icon: "plus", icon_only: true, href: new_path, aria: { label: "Add" })`. Call it where it should sit. There is no alias.
- Breaking change for hosts using `secondary_anchor_href`, `secondary_anchor_icon`, or `secondary_anchor_tooltip`. Before: `PageNav::Component.new(secondary_anchor_href: admin_path, secondary_anchor_icon: "home", secondary_anchor_tooltip: "Home")`. After: `nav.with_link(href: admin_path, icon: "home", tooltip: "Home")` at the position you want. `href` was `secondary_anchor_href`. `icon` was `secondary_anchor_icon` (`"chevron-left"` when you omitted it). `tooltip` was `secondary_anchor_tooltip`. A blank tooltip no longer falls back to "Previous page". Pass `tooltip:`. `flatpack.page_nav.previous` is no longer read. There is no alias.

## [0.1.272] - 2026-10-20

### Added
- `--radius-xxxl: 2.5rem` (40px) on bare `:root`, pinned in `@theme inline` as `--radius-xxxl: var(--radius-xxxl)`.
- `FlatPack::Card::Component` `radius:` accepts `:xxxl`. That sets inline `--card-radius` to `var(--radius-xxxl)`. `padding:` stays independent. `Media` `radius: :card_inner` still nests with `max(0px, calc(var(--card-radius) - var(--card-inset)))`.
- Bumped the gem version to `0.1.272`.

### Changed
- `[data-theme~="rounded"]` sets `--sidebar-float-radius` to `var(--radius-xxxl)`. The floating panel moves from `--radius-xl` (1.25rem) to 2.5rem.
- Rounded `--sidebar-item-radius` is `max(0px, calc(var(--sidebar-float-radius) - var(--sidebar-item-inset)))`. It was `--radius-md` (0.5rem). The rounded inset is 0.75rem, so the highlight is 1.75rem and shares the rail center.

### Upgrade notes
- Additive. `:xxxl` is new. Existing cards stay `:default`. Nothing is removed. Do not rerun `bin/rails generate flat_pack:install`.
- `--radius-xxxl` is `2.5rem` on bare `:root`.
- The rounded floating rail is rounder. It moves from `1.25rem` to `2.5rem` (40px). The rounded item highlight moves from `0.5rem` to the rail radius minus the item inset (1.75rem at the rounded spacing). Charcoal, dark, and ocean stay as they are.
- Hosts rebuild Tailwind only if their sheet restates the radius tokens. Add `--radius-xxxl: 2.5rem` next to `--radius-xxl` in that block.
- Reload kit CSS. Redeploy so `meta.gem_version` shows `0.1.272`.

## [0.1.269] - 2026-10-20

### Added
- `FlatPack::Card::Component` accepts `radius:`. `:default` keeps the theme `--card-radius` and adds no markup. `:none`, `:sm`, `:md`, `:lg`, `:xl`, and `:xxl` set an inline `--card-radius` (`0px`, or `var(--radius-sm)` through `var(--radius-xxl)`). Invalid values raise `ArgumentError`. `padding:` stays independent.
- `--radius-xxl: 2rem` on bare `:root`, pinned in `@theme inline` as `--radius-xxl: var(--radius-xxl)`.
- Bumped the gem version to `0.1.269`.

### Changed
- `[data-theme~="rounded"]` sets `--sidebar-float-radius` to `var(--radius-xl)`. The floating panel moves from the inherited `--radius-lg` (0.75rem) to 1.25rem. `--sidebar-item-radius` stays `var(--radius-md)` (0.5rem).

### Upgrade notes
- `radius:` is new (`:default`, `:none`, `:sm`, `:md`, `:lg`, `:xl`, `:xxl`). Existing cards stay `:default`.
- `--radius-xxl` is `2rem` on bare `:root`.
- Rounded floating rails move from `0.75rem` to `1.25rem`. Item highlights stay `0.5rem`.
- Nothing is removed.
- Reload kit CSS/JS. Redeploy so `meta.gem_version` shows `0.1.269`.

## [0.1.267] - 2026-10-19

### Added
- `--button-primary-active-background-color`. Override only. The base scope leaves it unset. A host or theme that sets it pins the pressed fill of a primary button.

### Changed
- A wrapper that sets `--color-primary` and `--color-primary-text` rebrands primary button rest, text, border, hover, and pressed. Hover and pressed are worked out on the element that paints.
- Hover is `--button-primary-hover-background-color`, then `--color-primary-hover`, then `color-mix(in oklab, var(--color-primary) 88%, var(--primary-shade-mix-target, black))`. Pressed is `--button-primary-active-background-color`, then the same mix at 80%. The 1px press stays. Focus stays the ring.
- The same hover mix is on the FAB trigger, the chat send button (it is a primary button), the comments submit button, the comments replies toggle, the rich-text link apply button, and date-picker preset buttons.
- Comments Replies adds the class `fp-comments-replies-toggle`. Its hover colour uses that mix.
- Bumped the gem version to `0.1.267`.

### Upgrade notes
- Default charcoal hover shifts. Rest stays `oklch(0.3211 0 0)`. Hover lightness moves from `0.2211` to about `0.283` oklab (`0.282568`, 88% of that charcoal toward black, chroma 0). Saturated brands also lose chroma toward the mix target.
- Primary buttons now have a pressed fill. Pressed on that charcoal is about `0.257` oklab (`0.25688`, the 80% mix). The 1px press stays. There is no alias for the old hover formula `oklch(calc(var(--brand-lightness) - 0.10) …)` or for `oklch(from var(--color-primary) …)`.
- Set `--color-primary-text` next to `--color-primary` and check AA contrast. White text fails on a light brand such as yellow. CSS cannot pick the text colour.
- New token `--button-primary-active-background-color`. Leave it unset to derive pressed. Set it to pin pressed, including on `.fp-hero-overlay`, which pins it to the hero hover token.
- `--button-primary-hover-background-color` still wins for hover. Then `--color-primary-hover`. Then the mix. `--color-primary-hover` is no longer set on the default palette or on dark. Ocean still sets `--color-primary-hover: oklch(0.42 0.18 220)`. A host that sets `--color-primary-hover` still wins. There is no alias from the brand knobs to `--color-primary-hover`.
- Dark mixes hover and pressed toward white, so pressed is lighter than hover. `--bottom-nav-item-active-color` on dark stays `oklch(0.72 0.15 250)`. There is no alias from that bar colour to primary hover.
- `--primary-shade-mix-target` is private (`black` on bare `:root`, `white` on `[data-theme~="dark"]`, `black` on `[data-theme~="ocean"]`). It is not in `@theme inline`.
- These `:root` aliases are gone. There is no alias. `--button-primary-background-color`, `--button-primary-hover-background-color`, `--button-primary-text-color`, `--button-primary-border-color`, `--fab-background-color`, `--fab-text-color`, `--fab-hover-background-color`, `--chat-send-button-background-color`, `--chat-send-button-text-color`, `--chat-send-button-hover-background-color`, `--comments-composer-submit-background-color`, `--comments-composer-submit-text-color`, `--comments-composer-submit-hover-background-color`, `--comments-replies-toggle-color`, and `--comments-replies-toggle-hover-color` stay as pins. They are unset until a host sets them. The painters then fall through to `--color-primary` and the mix.
- FAB hover follows the mix unless `--fab-hover-background-color` is set. Comments submit hover follows the mix unless `--comments-composer-submit-hover-background-color` is set. The old comments submit `color-mix(… 90%, black)` is gone. There is no alias. Comments replies hover follows the mix unless `--comments-replies-toggle-hover-color` is set.
- Chat send is a primary button, so its hover is the primary button hover. `--chat-send-button-hover-background-color` no longer paints it. There is no alias. Pin hover with `--button-primary-hover-background-color` or `--color-primary-hover`.
- A `theme.css` generated earlier only sets `--brand-hue`, `--brand-chroma`, and `--brand-lightness`. Leave that file. Hover and pressed follow those knobs without a regenerate. Regenerate only if you want the new comment about `--color-primary-text`.
- Do not rerun `bin/rails generate flat_pack:install`. Do not rebuild Tailwind. No new Tailwind class literals. Reload kit CSS.
- Redeploy so `meta.gem_version` shows `0.1.267`.
## [0.1.266] - 2026-10-19

### Added
- `FlatPack::ReadMore::Component` clamps a block to `lines:` (default `4`) and shows the rest. `open:` starts expanded. Omitted `more_label` and `less_label` use `flatpack.read_more.more` and `flatpack.read_more.less` (`Show more` and `Show less`).
- The closed clip uses `max-height: calc(var(--read-more-lines) * 1lh)`. Opening transitions to `max-content` with `interpolate-size: allow-keywords`, `--duration-slow`, and `--easing-standard`. A fade shows only when the clip is closed and the body overflows. `--read-more-fade-height` is `2.5rem` on `:root, [data-theme]`. `--read-more-lines` is set on the root at render time and is not a theme token.
- Stimulus controller `flat-pack--read-more` tracks `open` and `overflowing`. The button stays in the page and starts hidden. It appears when the body is taller than the clamp. Demo at `/demo/read_more`.
- Bumped the gem version to `0.1.266`.

### Upgrade notes
- New component. Existing call sites stay as they are.
- New token `--read-more-fade-height` (`2.5rem`). Reload kit CSS so it loads. `--read-more-lines` is a runtime length on the component root. Do not set it in a theme.
- Importmap hosts already pin `app/javascript/flat_pack/controllers` with `pin_all_from`. No new pin.
- esbuild, webpack, and Vite hosts must register `flat-pack--read-more`. Import `ReadMoreController` from `read_more_controller.js` and call `application.register("flat-pack--read-more", ReadMoreController)`.
- No Tailwind rebuild. The clamp and the fade live in kit CSS. The button reuses the ghost button classes the kit already ships. No `bin/rails generate flat_pack:install` rerun.
- Where `interpolate-size` is missing, the height snaps. The clamp still works.
- Redeploy so `meta.gem_version` shows `0.1.266`.

## [0.1.265] - 2026-10-19

### Fixed
- `flat_pack/application.css` imports `variables.css`, `rich_text.css`, `content_editor.css`, and `inline_edit.css` with `@import url(...)`. Propshaft `CssAssetUrls` rewrites each `url()` to a digested file such as `/assets/flat_pack/content_editor-<digest>.css`. `referenced_by` includes those files, so the `application.css` digest changes when one of them changes. A bare `@import "flat_pack/variables.css"` stayed in the compiled sheet. The browser then requested `/assets/flat_pack/flat_pack/variables.css` and got a 404. Hosts that linked only the install-contract sheets never received `content_editor` or `inline_edit` styles.
- The dummy layout links the same kit sheets as the install generator, `variables`, `application`, and `rich_text`, then the host `application` sheet.
- Bumped the gem version to `0.1.265`.

### Upgrade notes
- Hosts now load `content_editor` and `inline_edit` styles through `flat_pack/application`. Inline edit and the content editor may change to the kit look those files already describe.
- Reload kit CSS. No `bin/rails generate flat_pack:install` rerun. No Tailwind rebuild.
- The generator still links `variables` and `rich_text` beside `application`. Those two tags repeat imports already inside `application.css`. The repeat is harmless. Leave the tags.
- A host that rewrote bare `@import` strings with its own Propshaft compiler can delete that workaround.
- Redeploy so `meta.gem_version` shows `0.1.265`.

## [0.1.262] - 2026-10-19

### Added
- `FlatPack::Carousel::Component` accepts an `items` slot (`with_item`). Each block is one slide of trusted component output. Images, buttons, and `data-action` render as written, with no `overflow-auto p-4` wrapper. Hash `slides:` can be omitted. When both are set, hash slides come first.
- Slot slides size the viewport to the tallest slide. The aspect ratio, default border, and default fill are off. Pass `show_border:` or `show_background:` to turn them back on. Items stretch to that height and the card fills the item, so a wrapped title does not leave a ragged row, and the title and actions stay visible. Each item leaves a `--space-3` gap after the card. The gap is padding inside the slide, so the peek and `bleed:` alignment stay put. Hash slides do not get it.
- `side_preview: true` adds `--carousel-peek` to the items-per-view count. The default is `0.25`, the same peek as before. A theme or host can set the token. `0.25` with one slide in view shows about 80% of the slide.
- `bleed: true` lets the track run to the parent edge while the first slide stays lined up with the content. The inset is `--carousel-bleed`, then `--card-inset` (the padding step on an ancestor `.fp-card`), then `--card-padding-md`.
- `controls_on_touch:` hides previous and next on `@media (hover: none)` when `false`. A card row (`items`) hides them by default, because swipe covers that case. A hash `slides:` carousel keeps them unless you pass `false`. Pass `true` on a card row to keep the arrows. Arrows stay `absolute` overlays and take no width. `controls_on_hover` is unchanged and still shows arrows on small screens.
- Demo: the Card row section on `/demo/carousel`.
- Bumped the gem version to `0.1.262`.

### Upgrade notes
- Additive. The `slides:` hash API, sanitizer, aspect ratio, border, and background are unchanged when you do not pass `with_item`. No host call site has to change.
- Reload kit CSS and the carousel controller so `--carousel-peek` and `.flat-pack-carousel__control--touch-hidden` load. No new Stimulus controller. Importmap hosts need no new pin. esbuild, webpack, and Vite hosts already register `flat-pack--carousel`. Do not register another controller.
- No Tailwind rebuild. The slot layout reuses `h-auto`, `min-w-0`, and `shrink-0`, which the kit already ships. Content height and the touch rule live in kit CSS. No `bin/rails generate flat_pack:install` rerun.
- A carousel inside a card inherits that card's `--card-inset`. Set `--carousel-bleed` on the parent when the carousel is not inside a card and the padding is not `--card-padding-md`.
- Redeploy so `meta.gem_version` shows `0.1.262`.

## [0.1.261] - 2026-10-19

### Added
- A card publishes its padding step as `data-fp-card-padding` (`none`, `sm`, `md`, or `lg`). Kit CSS sets `--card-inset` from that step and `--card-inner-radius: max(0px, calc(var(--card-radius) - var(--card-inset)))` on `.fp-card`. A nested card recomputes for its own children. Stat cards publish `md`, which is the padding they already use.
- The kit class `fp-card-inner-radius` sets `border-radius` to that length. `FlatPack::Media::Component` accepts `radius: :card_inner` and puts the class on `div.fp-media__frame`, which also owns the fill and the hairline. Omit `radius:` and the frame keeps `--media-radius`.
- On the default theme, sm, md, and lg padding are at least the card radius, so the inner radius is 0. The media slot stays on the full card radius and has no radius argument.
- Bumped the gem version to `0.1.261`.

### Upgrade notes
- Media now wraps the image in `div.fp-media__frame`, and the radius, fill and hairline moved from `img.fp-media__image` to the frame. There is no alias.
- Token overrides of `--media-radius`, `--media-outline-color`, and `--surface-muted-background-color` still apply. A stylesheet that targeted those utilities on `img.fp-media__image` should target `.fp-media__frame`.
- Reload kit CSS so `.fp-card-inner-radius`, `.fp-media__frame`, and the inset rules load. Do not rebuild Tailwind for this change. Those rules live in kit CSS, not in the Tailwind layer.
- No host call site has to change. No `bin/rails generate flat_pack:install` rerun.
- Redeploy so `meta.gem_version` shows `0.1.261`.

## [0.1.260] - 2026-10-19

### Added
- `FlatPack::SidebarLayout::Component` accepts `width:` (`:fixed` by default, or `:content`). `:fixed` keeps the open desktop rail at `--sidebar-width`. `:content` sizes that rail to its widest item. Collapsed width stays `--sidebar-collapsed-width`. The mobile drawer stays `--sidebar-width`. Unknown values raise `ArgumentError`.
- Tokens on `:root, [data-theme]`: `--sidebar-width` (`16rem`), `--sidebar-collapsed-width` (`4rem`), `--sidebar-content-min-width` (`12rem`), and `--sidebar-content-max-width` (`20rem`). The content max matches the label ceiling, so a long label can grow past the old `16rem` rail and a short menu can shrink to `12rem`. Set `--sidebar-content-max-width: var(--sidebar-width)` when content mode should not exceed the fixed rail.
- The open desktop rail reads those tokens, including the collapsed icon offset, the label max-width, and the mobile drawer. `!important` stays where it beats a width utility.
- `width: :content` works with `floating: true`, `height: :content`, and `floating_top_nav: true`. The floating cards still share `--layout-content-inset` with `.fp-layout-content`.
- Dummy chrome reads `?width=content`. `/demo/sidebar_layout?width=content` hugs the labels.
- Bumped the gem version to `0.1.260`.

### Upgrade notes
- Additive. Hosts that omit `width:` keep a `16rem` open rail and a `4rem` collapsed rail. No call site has to change.
- Reload kit CSS and JS so the tokens and `rememberOpenWidth` load. New tokens: `--sidebar-width`, `--sidebar-collapsed-width`, `--sidebar-content-min-width`, `--sidebar-content-max-width`. Rounded, dark, and ocean do not remap them. `--sidebar-measured-width` is a runtime length on the column after layout. It is not a theme token. Do not set it on `:root`.
- No new Tailwind class literals. `w-64` is gone from `Sidebar` and from the layout column. Do not rebuild Tailwind for this change. Do not rerun `bin/rails generate flat_pack:install`. The install generator does not stamp these widths.
- A host stylesheet that still sets `width: 16rem !important` or `width: 4rem !important` on `[data-flat-pack-sidebar-collapsed]` wins over the tokens. Point those rules at `var(--sidebar-width)` and `var(--sidebar-collapsed-width)`. The dummy `application.tailwind.css` had that copy and now uses the tokens.
- Redeploy so `meta.gem_version` shows `0.1.260`.

## [0.1.259] - 2026-10-19

### Added
- `data-theme` can list more than one name, base first. `data-theme="rounded featured-in"` applies rounded, then the custom theme's tokens where they differ.
- Named kit selectors are word matches: `[data-theme~="rounded"]`, `[data-theme~="dark"]`, and `[data-theme~="ocean"]`. `:root, [data-theme]` is unchanged. The floating sidebar and floating top-nav cards use `:not([data-theme~="rounded"])`, so `data-theme="rounded harbor"` keeps the pill corners.
- `flat-pack--theme` swaps the base name and keeps names that are not in the picker list. Light clears owned base names and removes the attribute when nothing remains. Dark mode is true when the list contains the whole name `dark`.
- `bin/rails generate flat_pack:theme NAME --inherits=rounded` writes an overrides-only file and tells you to set `data-theme="rounded NAME"`. The generated selector is `[data-theme~="NAME"]`. There is no full-fork theme generator.
- Dummy themes page shows Harbor stacked on rounded. Those samples are cards, so the corners follow `--card-radius` (`--radius-xl` on the rounded page).
- Bumped the gem version to `0.1.259`.

### Upgrade notes
- Single-name themes keep working. `data-theme="rounded"` still matches `[data-theme~="rounded"]`. `data-theme="dark"` still matches dark. Picking light while the only name is a base theme still removes the attribute.
- A nested `data-theme="harbor"` inside a rounded page keeps the rounded shape. Harbor does not restate radii, and `[data-theme]` does not put the moderate radii back. The moderate shape is `data-theme="harbor"` on the root, with no rounded ancestor.
- A host selector that is an exact match, `[data-theme="brand"]`, does not match `data-theme="rounded brand"`. Change that host selector to `[data-theme~="brand"]` when you stack. Load the host file after `flat_pack/variables`. Specificity is unchanged, so source order still decides the winner. Kit CSS is not in a cascade layer. Putting it in one would let unlayered host CSS beat the kit even when the host file loads first.
- The picker stores the base name, not the full list. A custom name rendered in the HTML stays when the base changes.
- Reload kit CSS. No Tailwind rebuild is required for the kit selector change. Rebuild Tailwind only if a host stylesheet that Tailwind compiles still uses exact `data-theme` selectors you are stacking. No `bin/rails generate flat_pack:install` rerun.
- Redeploy so `meta.gem_version` shows `0.1.259`.

## [0.1.258] - 2026-10-19

### Added
- `FlatPack::Search::Component` accepts `collapsible:` (`false` by default). `true` rests the field as a round icon button and grows it into the same search field. `collapsed:` (`true` by default) chooses the starting posture. `false` starts expanded. A present `value` stays open. An outside click or Escape collapses an empty field only while that field holds focus, so a field that starts open stays open until you use it. `grow:` is `:end` (default, the start edge stays put) or `:start` (the end edge stays put). The open field keeps the plain search icon on the left and the clear button on the right.
- The collapsed face is `FlatPack::Button` with `round: true` and `icon_only: true`. Its accessible name is `flatpack.common.search`, overridable with `aria: { label: }`.
- `--search-expanded-width` (`16rem`) is the open width, capped with `min(100%, var(--search-expanded-width))` so a 390px toolbar does not overflow. Rounded, dark, and ocean do not remap it.
- Stimulus controller `flat-pack--search-collapse` runs the expand and collapse. Demo: the Toolbar section on `/demo/search`.
- Bumped the gem version to `0.1.258`.

### Upgrade notes
- Additive. Existing arguments, tokens, classes, and the default render are unchanged. No host call site has to change.
- Reload kit CSS and JS so `.fp-search--collapsible` and `--search-expanded-width` load. No new Tailwind class literals. The circle classes are the Button round classes from `0.1.255`. No `bin/rails generate flat_pack:install` rerun. The install generator does not stamp this controller.
- Importmap hosts need no new pin. The engine already pins `app/javascript/flat_pack/controllers`. esbuild, webpack, and Vite hosts add `import SearchCollapseController from ".../search_collapse_controller.js"` and `application.register("flat-pack--search-collapse", SearchCollapseController)`.
- Redeploy so `meta.gem_version` shows `0.1.258`.

## [0.1.257] - 2026-10-19

### Added
- `FlatPack::SidebarLayout::Component` accepts `floating_top_nav:` (`false` by default). The full-width bar becomes cards on the page. `TopNav` `left` and `center` are each one card sized to their contents. Each direct child of `right` is its own card. The cards use `--sidebar-float-inset`, `--sidebar-float-background-color`, `--sidebar-float-shadow`, and `--top-nav-float-radius`.
- `content_scroll:` is `:behind` (default) or `:below`. It applies only when the top nav floats. `:behind` lets main content scroll under the cards and pads the pane with `--top-nav-float-clearance`. `:below` keeps the cards above the pane.
- `TopNav` sections always set `data-flat-pack-top-nav-section`, including when `mobile_menu: false`.
- Dummy chrome reads `?floating_top_nav=1`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1` shows the cards over the photo. `content_scroll=below` parks the cards above the scroll pane.
- `height:` is `:full` (default) or `:content`. `:content` sizes the floating desktop rail to its items and caps it at the viewport minus `--sidebar-float-inset`. The list scrolls inside that cap. It does nothing when `floating` is false. The mobile drawer stays full height.
- Dummy chrome reads `?height=content`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1&height=content` shows the short rail.
- Bumped the gem version to `0.1.257`.

### Upgrade notes
- Additive. Hosts that do not pass `floating_top_nav: true` keep the full-width bar and the same scroll pane. `content_scroll:` does nothing until the top nav floats. Hosts that do not pass `height: :content` keep the full-height floating rail.
- New tokens `--top-nav-float-clearance` and `--top-nav-float-radius`. The radius defaults to `var(--sidebar-float-radius)`. `[data-theme~="rounded"]` sets it to `var(--radius-full)`, so the cards are pills. The rail still uses `--sidebar-float-radius`. The content-height cap reuses `--sidebar-float-inset`. No token was renamed.
- `--layout-content-inset` is the horizontal page padding: `1rem`, then `2rem` from `640px`. `.fp-layout-content` applies it to the main pane. `.fp-layout-column` is the page column inside that pane. `--layout-content-max-width` defaults to `100%`, so the column fills the pane. A length centers that measure, and the floating bar follows it. The bar's left and right edges use the inset plus `--top-nav-float-offset` (`0px`) plus that centering. A nested `max-width` with auto margins is a second column and will not meet the bar. Override `--layout-content-inset` to move the page and the bar together. The docked bar still uses `--top-nav-padding-inline`.
- Below `768px`, floating `left` and `center` cards use `0.25rem` of inline padding and the row gap is `0.5rem`. Text buttons in those cards use `0.625rem` of inline padding. The cards shrink before the row wraps.
- When the floating cards are more than `8px` taller than `--top-nav-float-clearance`, the layout sets that token on the main column to the bottom of the band so a wrapped row does not cover the page.
- Reload kit CSS. There are no new Tailwind class literals for this layout. Do not rerun `flat_pack:install`.
- Redeploy so `meta.gem_version` shows `0.1.257`.

## [0.1.256] - 2026-10-19

### Fixed
- `FlatPack::Copy.t` (and `fp_t` / `fp_text`) uses the English `flatpack.*` string when the active locale has no translation for that key. A translation already in the active locale still wins, including a host English file that overrides the gem string. `I18n.t`, `I18n.fallbacks`, and `I18n.exception_handler` are unchanged.
- `Copy.t` raises `ArgumentError` if you pass `scope:`. The key is already under `flatpack.`, so a scope cannot move the fallback onto another namespace.
- A silent English fallback publishes `fallback.flat_pack_copy` with `key` and `locale`.
- Bumped the gem version to `0.1.256`.

### Upgrade notes
- A host locale can omit kit keys. Chrome rendered through `FlatPack::Copy.t` shows English until the host translates that key. A host English file replaces the gem string for that key, and that host string is the fallback.
- Do not pass `scope:` to `FlatPack::Copy.t`, `fp_t`, or `fp_text`.
- `config.i18n.raise_on_missing_translations` still raises for a missing host key, and for a `flatpack.*` key that English does not define either.
- Redeploy so `meta.gem_version` shows `0.1.256`.

## [0.1.255] - 2026-10-19

### Added
- `FlatPack::Button::Component` accepts `round:` (`false` by default). `true` paints `--button-round-border-radius`. A label becomes a pill. `icon_only: true` also sets an equal width and height from `--button-round-size-sm`, `--button-round-size-md`, or `--button-round-size-lg`, so the button is a circle at every size. Omit `round:` and the theme corner is unchanged.
- `--button-round-border-radius` is `--radius-full` on the moderate scale and is not remapped by rounded, dark, or ocean. The size tokens follow icon-only padding and `--hit-target-min`.
- Demo: the Round section on `/demo/buttons`.
- Bumped the gem version to `0.1.255`.

### Upgrade notes
- Additive. Existing arguments, tokens, classes, and defaults are unchanged. No host call site has to change.
- Rebuild Tailwind. New class literals: `rounded-[var(--button-round-border-radius)]`, `h-[var(--button-round-size-sm)]`, `w-[var(--button-round-size-sm)]`, and the `md` and `lg` size pair. No `bin/rails generate flat_pack:install` rerun. The install generator does not stamp these classes.
- Redeploy so `meta.gem_version` shows `0.1.255`.

## [0.1.254] - 2026-10-19

### Added
- `FlatPack::SidebarLayout::Component` accepts an optional `background` slot. The host renders an `<img>` or `<picture>` into it. The layout fixes that photo to the viewport behind the sidebar, the top nav, and main, blurs it with `--layout-background-blur`, and washes it with `--layout-background-tint-color` at `--layout-background-tint-opacity`. The main column clears `--surface-page-background-color` so the photo shows through. Omit the slot and the shell is unchanged.
- Dark sets `--layout-background-tint-opacity` to `0.78`. Under `prefers-reduced-transparency: reduce`, or when `filter: blur()` is missing, the photo hides and the tint is solid.
- Dummy chrome reads `?background=1`. `/demo/sidebar_layout?floating=1&background=1` shows the floating photo.
- Bumped the gem version to `0.1.254`.

### Upgrade notes
- New optional `background` slot on `SidebarLayout`, and new `--layout-background-blur`, `--layout-background-tint-color`, and `--layout-background-tint-opacity` tokens. No host change required.
- Reload kit CSS/JS. Redeploy so `meta.gem_version` shows `0.1.254`.

## [0.1.253] - 2026-10-19

### Added
- `FlatPack::SidebarLayout::Component` accepts an optional `floating:` argument (`false` by default). On desktop the rail insets by `--sidebar-float-inset` on the top, bottom, and outer edge, and paints `--sidebar-float-background-color` with a full border and `--sidebar-float-shadow`. The rounded palette rounds it with `--sidebar-float-radius`. Other named themes stay square. Below the `md` breakpoint the drawer stays flush.
- Dummy chrome reads `?floating=1` to show the detached rail.
- Bumped the gem version to `0.1.253`.

### Upgrade notes
- New optional `floating:` argument on `SidebarLayout`, and new `--sidebar-float-*` tokens. No host change required.
- Reload kit CSS/JS. Redeploy so `meta.gem_version` shows `0.1.253`.

## [0.1.252] - 2026-10-17

### Added
- Reveal timing. `delay:` is `:sm`, `:md`, or `:lg` (`--motion-delay-sm` 120ms, `--motion-delay-md` 250ms, `--motion-delay-lg` 450ms). `duration:` is `:fast`, `:base`, `:slow`, or `:slower` (`--motion-duration-slower` is 600ms). `stagger:` stays `true` for `--reveal-stagger`, and also accepts `:sm`, `:md`, or `:lg` (`--motion-stagger-sm` 40ms, `--motion-stagger-md` 80ms, `--motion-stagger-lg` 120ms).
- Each step writes `--reveal-delay`, `--reveal-duration`, or `--reveal-stagger` on that element. Omit a step and the theme token applies.
- A non-negative Integer of milliseconds is the escape hatch for any of the three.
- Demo: the Sequence section on `/demo/motion`.
- Bumped the gem version to `0.1.252`.

### Upgrade notes
- New optional arguments. `stagger: true` and `stagger: false` still mean the same thing.
- Named steps are the API. A millisecond Integer still works when a step is the wrong size.
- `FlatPack::Number::Component` `duration:` is still `:fast`, `:base`, or `:slow`. `:slower` is a reveal step.
- Under `prefers-reduced-motion: reduce`, the new delay, duration, and stagger tokens are `0ms`.
- Reload kit CSS. There are no new Tailwind class literals.
- Redeploy so `meta.gem_version` shows `0.1.252`.

## [0.1.251] - 2026-10-16

### Added
- Motion tokens: `--motion-duration-fast`, `--motion-duration-base`, `--motion-duration-slow`, `--motion-ease-out`, `--motion-ease-in-out`, `--motion-ease-spring`, `--motion-distance-sm`, `--motion-distance-md`, `--motion-distance-lg`, and `--reveal-stagger`. A theme tunes reveals, the kit enter, and the collage entrance in one place.
- `reveal:` on any component root that calls `merge_attributes`. Every variant starts hidden. `:fade` is opacity. `:rise`, `:blur`, and `:scale` then move, sharpen, or grow. `:wipe` and `:zoom` are the media pair. `intensity: :strong` uses the strong motion tokens. `stagger: true` indexes the children. `parallax: true` is a gentle scroll shift, only with `:wipe` or `:zoom`.
- `FlatPack::Reveal::Component` is the wrapper. `:words` and `:lines` split the copy on the server. Each piece slides up out of a mask. The plain sentence stays in a visually hidden span. The pieces are `aria-hidden`.
- `FlatPack::Text::Stream::Component` types a line once it is in view, with a caret. The full string stays in the DOM for screen readers. The typing is decorative. Put it inside a chat message. There is no `stream:` flag.
- One Stimulus controller, `flat-pack--reveal`, reveals once. `flat-pack--text-stream` types once. Both share the reduced-motion helper. `prefers-reduced-motion: reduce` shows the finished look. With no JavaScript the content stays visible.
- `FlatPack::Number::Component` counts, rolls, or fades a number the first time it enters the view. The finished formatted value is in the page, so a screen reader and a browser without JavaScript get the final number. `value:` is the amount. `format:` is `:number`, `:currency`, `:percent`, or `:compact`. `animate:` is `:count` (default), `:roll`, `:fade`, or `:none`. `duration:` is `:fast`, `:base`, or `:slow`. A later value change animates from the number on screen to the new one. Tabular figures keep the width steady.
- `observeOnce` in `reduced_motion.js` is the shared in-view trigger for reveals and numbers.
- Demo: `/demo/motion`.
- Bumped the gem version to `0.1.251`.

### Changed
- `.fp-content-enter` and `.fp-empty-state` use `--motion-duration-slow`, `--motion-ease-out`, and `--motion-distance-sm`.
- `--collage-duration`, `--collage-easing`, `--collage-rise`, and `--collage-stagger` inherit those tokens. A collage token set on its own still wins.
- `flat-pack--svg-motion` named durations `:fast`, `:base`, and `:slow` follow `--motion-duration-*`. Easing `enter` follows `--motion-ease-out`. `standard` and `exit` stay on `--easing-standard` and `--easing-exit`. A millisecond duration is unchanged.
- Under `prefers-reduced-motion: reduce`, the motion durations and `--reveal-stagger` are `0ms`.

### Upgrade notes
- New tokens and three components. Nothing was renamed.
- `reveal: :words` and `reveal: :lines` belong on `FlatPack::Reveal::Component`. On any other component they raise `ArgumentError`.
- `parallax: true` raises unless the reveal is `:wipe` or `:zoom`.
- Overriding `--motion-duration-slow` or `--motion-ease-out` also retunes `.fp-content-enter`, the collage entrance, and svg-motion tracks that use a named duration or easing `enter`. Set the `--collage-*` token when one collage should differ. Easing `standard` and `exit` stay on `--easing-standard` and `--easing-exit`.
- Do not add `stream:` to `FlatPack::Chat::Message::Component`. Render `FlatPack::Text::Stream::Component` in the message.
- `FlatPack::Number::Component` is new. Billing prices stay on `price_text` and `amount`. A counter takes a numeric `value:`.
- Percent is a ratio. `0.18` formats as 18%.
- Reload kit CSS. There are no new Tailwind class literals.
- Redeploy so `meta.gem_version` shows `0.1.251`.

## [0.1.250] - 2026-10-16

### Changed
- Radius is a theme dimension, on the same bare `:root` as `--space-*`.
- The moderate shape scale is `--radius-xs` (`0.125rem`), `--radius-sm` (`0.25rem`), `--radius-md` (`0.5rem`), `--radius-lg` (`0.75rem`), `--radius-xl` (`1.25rem`), and `--radius-full` (`9999px`).
- Component radii alias a step: `--button-border-radius`, `--form-control-radius`, `--chip-border-radius`, `--badge-radius`, `--tabs-pill-corner-radius`, `--card-radius`, `--menu-radius`, `--popover-radius`, `--modal-radius`, `--alert-border-radius`, `--toast-border-radius`, and `--chat-composer-radius`.
- `[data-theme="rounded"]` makes buttons, inputs, badges, tabs, and the chat composer pills, and steps cards, menus, popovers, modals, alerts, and toasts up to `--radius-xl`. Chips stay `--radius-md`. `--sidebar-item-radius` and `--dropdown-item-radius` are `--radius-md` there too, so nav rows and menu highlights stay a soft corner. Dark and ocean keep the moderate shape.
- Circles stay fixed: avatar circle, status dots, typing dots, stepper and timeline markers, switch, radio, spinners, carousel dots, and the FAB.
- Bumped the gem version to `0.1.250`.

### Upgrade notes
- The old default (`--radius-md: 1rem`, `--radius-sm: 0.75rem`, `--radius-lg: 1.5rem`, `--radius-xl: 2rem`) is gone. There is no alias.
- Hosts that re-set kit radii on unlayered `:root` should copy the new six steps. Tailwind's layered `--radius-md: 0.375rem` still loses to that unlayered block.
- Rebuild host Tailwind so these classes are generated: `rounded-[var(--form-control-radius)]`, `rounded-[var(--badge-radius)]`, `rounded-[var(--card-radius)]`, `rounded-[var(--menu-radius)]`, `rounded-[var(--modal-radius)]`, `rounded-[var(--chat-composer-radius)]`, `rounded-[var(--button-border-radius)]`, `rounded-[var(--chip-border-radius)]`, `rounded-[var(--sidebar-item-radius)]`, `rounded-[var(--dropdown-item-radius)]`, `rounded-[var(--media-radius)]`, `rounded-[var(--radius-full)]`, `rounded-[var(--radius-xs)]`, `rounded-l-[var(--button-border-radius)]`, `rounded-r-[var(--button-border-radius)]`, `rounded-r-[var(--modal-radius)]`, `rounded-l-[var(--modal-radius)]`, `rounded-t-[var(--modal-radius)]`, and `[border-radius:var(--tabs-pill-corner-radius)]`.
- Set `data-theme="rounded"` for pill buttons and inputs. Chips, sidebar rows, and menu item highlights stay 8px (`--radius-md`). Without the theme, controls use the 8px step and sidebar rows use 12px.
- Reload kit CSS. Redeploy so `meta.gem_version` shows `0.1.250`.

## [0.1.249] - 2026-10-16

### Added
- `FlatPack::AnimatedCharacter::Component` draws a character from a Ruby hash and plays named states with the Web Animations API.
- A definition lists nested parts (`circle`, `ellipse`, `rect`, `path`, `line`, `polyline`) and tracks for `translateX`, `translateY`, `scaleX`, `scaleY`, `rotate`, `opacity`, and `strokeDashoffset`.
- `FlatPack::AnimatedCharacter.bot` and `FlatPack::AnimatedCharacter.pip` are ready-made characters. Bot states are `idle`, `blink`, `happy`, and `thinking`. Blink scales the eye group on Y.
- `FlatPack::Shared::IconComponent` takes `animate:` (`:wiggle`, `:pop`, `:draw`, `:spin`, `:nudge`) and `trigger:` (`:hover`, `:click`, `:mount`).
- The Stimulus controller `flat-pack--svg-motion` exposes `setState`, `play`, `stop`, `reset`, `pause`, and `resume`. `prefers-reduced-motion: reduce` keeps the first frame.
- Demo: `/demo/animated_character`.
- Bumped the gem version to `0.1.249`.

### Upgrade notes
- New component, and two optional keyword arguments on `IconComponent`. Nothing was renamed.
- `definition` is a Hash. A raw SVG string, an unknown shape, or an attribute outside the allowlist raises `ArgumentError`.
- `state` must be a key in that definition. `size` is `:sm`, `:md`, `:lg`, or `:xl`.
- `animate` must be `:wiggle`, `:pop`, `:draw`, `:spin`, or `:nudge`. `trigger` must be `:hover`, `:click`, or `:mount`.
- Pass `label:` when the character should have an accessible name. Without it, the SVG is `aria-hidden`.
- Durations `:fast`, `:base`, and `:slow` follow `--duration-fast`, `--duration-base`, and `--duration-slow`. Easing `standard`, `enter`, and `exit` follow the matching `--easing-*` tokens.
- Reload kit CSS and JavaScript. There is no path morphing in this version.
- Redeploy so `meta.gem_version` shows `0.1.249`.

## [0.1.248] - 2026-10-16

### Changed
- `FlatPack::Collage::Component` takes `entrance:`, `idle:`, and `hover:` instead of `motion:`.
- `entrance:` is `:rise` (default, the staggered fade-up), `:deal` (flat, near the centre, then into place, then the tilt settles), or `:none`.
- `idle:` is `:none` (default) or `:drift` (a slow sway of about ±1deg, each item on its own beat).
- `hover:` is `:lift` (default), `:focus` (straighten, raise, and bring forward while siblings ease back), or `:none`. Pointer hover runs under `(hover: hover)`. Keyboard focus uses `:focus-visible` and `:focus-within`.
- Below `md`, only the entrance runs. `prefers-reduced-motion: reduce` skips the entrance, the sway, and the hover.
- Motion durations, distances, and easings are `--collage-*` tokens: `--collage-duration`, `--collage-easing`, `--collage-rise`, `--collage-deal`, `--collage-deal-duration`, `--collage-drift`, `--collage-drift-duration`, `--collage-drift-easing`, `--collage-drift-phase`, `--collage-focus-lift`, `--collage-focus-scale`, and `--collage-focus-dim`.
- Demo: `/demo/collage` has a section for each option.
- Bumped the gem version to `0.1.248`.

### Upgrade notes
- `motion:` is gone. Pass `entrance:`, `idle:`, and `hover:`. There is no alias.
- The old default (`motion: true`) is `entrance: :rise`, `idle: :none`, `hover: :lift`.
- The old `motion: false` is `entrance: :none, hover: :none`.
- `:drift` and both hover styles are off below `md`. Pass `entrance: :none` when a phone should not animate.
- Tune the motion with the new `--collage-*` tokens. `--collage-duration` follows `--duration-slow`, and `--collage-easing` follows `--easing-enter`.
- Reload kit CSS. There are no new Tailwind class literals.
- Redeploy so `meta.gem_version` shows `0.1.248`.

## [0.1.247] - 2026-10-16

### Added
- `FlatPack::Collage::Component` scatters any host content. `columns:` is an even grid, 1–6 (default 3). `rows:` is a brick, such as `[5, 4]`: five across, then four centered between them. `scatter:` is `:subtle` (default), `:loose`, or `:none`.
- `collage.item(rotate:, offset:, z:)` takes any markup. Omit `rotate` and `offset` and the tilt comes from the item index, so a re-render stays put. Pass either one to pin that card.
- Below `md`, the collage is one overlapping row, `33dvh` tall. `mobile_items:` (default `4`) is how many items stay in that row. Later items stay in source order and are not displayed. The outer cards may cross the side edges. `--collage-item-size-sm` is the card width.
- From `md` up to `lg`, a brick is rows of three, capped by `--collage-item-size-md` (`11rem`). The second row shifts sideways. From `lg` up, `rows: [5, 4]` is five across and four centered between them.
- `stack_below:` (`:sm`, `:md`, `:lg`, `:xl`) is opt-in. Omit it. Pass it when that width should be one column with the tilt off. DOM order is the reading order. Nothing is absolutely positioned.
- `--collage-rotate` is `5deg`. `--collage-offset-x`, `--collage-offset-y`, `--collage-lift`, and `--collage-stagger` are the other ranges. `--collage-loose` scales the subtle unit. A brick insets by `--collage-margin` (about 32px), overlaps rows by `--collage-overlap`, and sizes each slot with `--collage-card-ratio` and `--collage-card-sway`. An even grid still pads with `--collage-pad` plus the offset and `--collage-bleed`. Below `stack_below` the overlap, the tilt, and the extra inset drop off. The kit does not style the item.
- `motion: true` (default) staggers `.fp-content-enter` and lifts on hover with `--duration-slow` / `--easing-enter`. `motion: false` and `prefers-reduced-motion: reduce` skip both.
- Demo: `/demo/collage`.
- Bumped the gem version to `0.1.247`.

### Upgrade notes
- New component. There is no alias to retire.
- `stack_below` defaults to omitted. A phone shows the short row, not a list. Pass `stack_below: :md` when that width should stack.
- Tune a theme with the `--collage-*` tokens. Do not restyle `.fp-collage__item` to change the lean.
- `scatter: :none` is the square grid. A theme that sets `--collage-rotate: 0deg` and zero offsets flattens every collage, including `:loose`.
- Reload kit CSS. There are no new Tailwind class literals.
- Redeploy so `meta.gem_version` shows `0.1.247`.

## [0.1.246] - 2026-10-15

### Added
- `FlatPack::EmptyState::Component` takes `icon_variant:` (`:outline`, `:solid`, `:mini`, `:micro`) for any kit icon.
- One visual above the title. `icon:` is the default. `media` fills it with one `FlatPack::Media::Component` (`src`, `alt`, `width`, `height`) and keeps that aspect ratio. `visual` is freeform host markup and spans the empty state, so a large composition fits. A block or an image replaces the icon.
- `width:` `:sm`, `:md`, `:lg`, or `:full` caps the text block with `--empty-state-measure-*`. Default `:md` is `28rem`. `:full` is `max-width: none`.
- `title_size:` `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:xxl`, or `:display`. `:display` uses `.fp-display`. Omit it and the heading follows `size`.
- `description_size:` `:sm`, `:md`, `:lg`, or `:xl` (`--text-sm`, `--text-base`, `--text-lg`, `--text-xl`). Omit it and the sentence follows `size`.
- `icon_size:` `:sm`, `:md`, `:lg`, or `:xl` on the kit icon. Omit it and `size` maps `:sm` → `:md`, `:md` → `:lg`, `:lg` → `:xl`. Requires `icon`.
- `layout:` `:wrap` (default) or `:stack`. Actions are one `item` each and render in `FlatPack::Collection::Component`.
- `--empty-state-padding-*`, `--empty-state-gap-*`, `--empty-state-title-gap-*`, and `--empty-state-block-gap-*` are `round(nearest, calc(var(--space-N) * var(--density)), 1px)`.
- Demo: `/demo/empty_state`.
- Bumped the gem version to `0.1.246`.

### Changed
- The root is still a block-level flex column with no width of its own, so it fills its container. `width:` caps the words (and a media image), not the root. A `visual` block is not capped.
- Padding and the gaps no longer use `py-*` / `px-*` / `mb-*` utilities. On the compact scale the medium padding is still `3rem` by `1rem`. Rounded's larger `--space-*` steps loosen it.
- `slot` and the deprecated `actions` alias are gone. Pass `item` once per button.
- The default description is one step larger. `size: :sm` is `--text-sm`, `:md` is `--text-base`, `:lg` is `--text-lg`. `size:` still sets padding, gaps, the icon, the title, and the description together.

### Upgrade notes
- Replace `empty.slot` and `empty.actions` with `empty.item` for each button. `layout: :stack` piles them. The default `:wrap` is the old wrapping row.
- `icon_variant` must be `:outline`, `:solid`, `:mini`, or `:micro`, and it requires `icon`. Anything else raises `ArgumentError`.
- Pass `visual` or `media`, not both. There is no `graphic` slot. `media` uses Media's `width` and `height` integers and does not take a block. EmptyState `width:` is `:sm`, `:md`, `:lg`, or `:full`.
- `title_size` is not Hero's scale. `:xxl` is `--text-2xl`. `:display` is the cover heading.
- `description_size` is not `title_size`. `:md` is `--text-base`. `:base` raises. Pass `description_size: :sm` to keep the old medium sentence (`--text-sm`).
- `icon_size` requires `icon` and uses `:sm`, `:md`, `:lg`, or `:xl`. A media image stays on `width:`.
- The text block defaults to `--empty-state-measure-md` (`28rem`), which was the old description cap. Pass `width: :full` for an uncapped sentence.
- Hosts that want the old compact padding on a rounded page should not restate these tokens on `[data-theme="rounded"]`. Override `--empty-state-padding-*` only when this panel should diverge.
- Rebuild host Tailwind so these literals are generated: `py-[var(--empty-state-padding-y-sm)]`, `px-[var(--empty-state-padding-x-sm)]`, `py-[var(--empty-state-padding-y-md)]`, `px-[var(--empty-state-padding-x-md)]`, `py-[var(--empty-state-padding-y-lg)]`, `px-[var(--empty-state-padding-x-lg)]`, `mb-[var(--empty-state-gap-sm)]`, `mb-[var(--empty-state-gap-md)]`, `mb-[var(--empty-state-gap-lg)]`, `mb-[var(--empty-state-title-gap-sm)]`, `mb-[var(--empty-state-title-gap-md)]`, `mb-[var(--empty-state-title-gap-lg)]`, `mb-[var(--empty-state-block-gap-sm)]`, `mb-[var(--empty-state-block-gap-md)]`, `mb-[var(--empty-state-block-gap-lg)]`, `max-w-[var(--empty-state-measure-sm)]`, `max-w-[var(--empty-state-measure-md)]`, `max-w-[var(--empty-state-measure-lg)]`, `max-w-[var(--empty-state-measure-full)]`, `text-[length:var(--text-xs)]`, `text-[length:var(--text-sm)]`, `text-[length:var(--text-base)]`, `text-[length:var(--text-lg)]`, `text-[length:var(--text-xl)]`, and `text-[length:var(--text-2xl)]`.
- Reload kit CSS for the new tokens.
- Redeploy so `meta.gem_version` shows `0.1.246`.

## [0.1.245] - 2026-10-15

### Changed
- Outgoing chat bubbles use a light neutral surface instead of the primary fill. `--chat-message-outgoing-background-color` is `var(--surface-hover-background-color)` (`#f0f0f0` on the default palette). `--chat-message-outgoing-text-color` is `var(--surface-content-color)`.
- Incoming stays `--surface-muted-background-color` (`#e5e5e5`) with the same foreground. Body text is about 11:1 on the sent bubble and about 10:1 on the received bubble.
- Dark sets `--chat-message-outgoing-background-color` to `oklch(0.32 0.015 250)`. Dark hover and muted are the same lightness, so the hover alias would match incoming. Text stays the surface foreground (about 11:1). Incoming text on the muted surface is about 15:1.
- Ocean sets `--chat-message-outgoing-background-color` to `oklch(0.90 0.025 220)`. Ocean hover sits on the muted fill, so the sent bubble uses a slightly deeper neutral. Text stays the surface foreground (about 13:1).
- Timestamps, read receipts, and attachment icons stay on `--surface-muted-content-color`. They sit under the bubble or on the attachment card. Links inside a bubble inherit the bubble text colour.
- Bumped the gem version to `0.1.245`.

### Upgrade notes
- There is no compatibility alias and no class that restores the primary bubble. To keep a brand fill, set `--chat-message-outgoing-background-color` and `--chat-message-outgoing-text-color` after Flatpack CSS.
- Drop a host rule that forced outgoing text to white so it would read on the primary fill. White ink fails on the neutral bubble.
- A theme whose hover and muted surfaces match should set `--chat-message-outgoing-background-color`, or the sent and received bubbles match. Dark and ocean already do this.
- Reload kit CSS. There are no new Tailwind class literals.
- Redeploy so `meta.gem_version` shows `0.1.245`.

## [0.1.244] - 2026-10-15

### Added
- `--space-1` through `--space-6` and `--density` on bare `:root`. Component padding is `round(nearest, calc(var(--space-N) * var(--density)), 1px)`.
- `[data-theme="rounded"]` shifts steps 2–6 (`0.75rem`, `1rem`, `1.25rem`, `1.75rem`, `2.5rem`) and remaps menu shells plus the search result block axis. `--space-1` stays `0.25rem`. `--density` stays `1`.
- Family padding tokens for menus, fields, badges, overlays, sidebar, list, modal, and drawer. Badges and search icon gutters stay fixed lengths.
- Bumped the gem version to `0.1.244`.

### Changed
- Buttons, fields, chips, pills, tabs, cards, lists, tables, sidebar, top nav, modal, drawer, popover, tooltip, alert, toast, accordion, collapse, and bottom nav read those tokens. Alert, toast, and accordion no longer write a size onto the token with an inline style.
- Card header and footer follow the card padding step.
- `--form-control-padding` is `--form-control-padding-x` and `--form-control-padding-y`. `--table-padding` is `--table-padding-x` and `--table-padding-y`. `--alert-padding` and `--toast-padding` are `-sm`, `-md`, and `-lg`. Accordion trigger and content padding are sized the same way.
- Removed unused `--button-padding-x-xs` and `--button-padding-y-xs`.
- The dummy app sets `data-theme="rounded"` on its HTML layouts.
- Dark and ocean inherit the compact scale. A dark region nested inside rounded keeps the generous steps.

### Upgrade notes
- There are no compatibility aliases. Hosts that set `--form-control-padding`, `--table-padding`, `--alert-padding`, `--toast-padding`, `--button-padding-x-xs`, or `--button-padding-y-xs` must switch to the new names.
- Set `<html data-theme="rounded">` for the generous scale. Omit it, or use `dark` / `ocean`, and padding stays on the compact scale.
- Do not restate `--space-*`, `--density`, or the remapped menu shells on a generic `[data-theme]` rule. Do not self-map a token on `rounded`.
- Rebuild host Tailwind so the new `px-[var(--…)]` / `py-[var(--…)]` / `p-[var(--…)]` / `sm:p-[var(--…)]` literals are generated. Reload kit CSS for the token values.
- Select options use the menu item steps. At the compact scale that is `12px` by `8px`, down from the old field padding.
- Redeploy so `meta.gem_version` shows `0.1.244`.
- Do not tag this PR.

## [0.1.243] - 2026-10-15

### Added
- `FlatPack::Button::Component`, `FlatPack::Button::Dropdown::Component`, and `FlatPack::Button::DropdownItem::Component` accept `icon_variant:` (`:outline`, `:solid`, `:mini`, `:micro`) and `icon_style:` (`nil`, `:primary`, `:success`, `:warning`, `:danger`).
- `icon_variant` is passed to `FlatPack::Shared::IconComponent` `variant:`. Omit it to keep `config.default_icon_variant`.
- `icon_style: nil` inherits the button text through `currentColor`. The other values use `--button-icon-primary-color`, `--button-icon-success-color`, `--button-icon-warning-color`, and `--button-icon-danger-color`.
- Those tokens alias `--color-primary`, `--color-success-background-color`, `--color-warning`, and `--color-danger-background-color`. The glyph mixes the token toward `--fp-button-text` so it stays readable on every button style. When `icon_style` matches `style`, the glyph uses the button text colour.
- The dropdown chevron stays the trigger text colour and the default icon weight.
- Demo: `/demo/buttons#icon-colour`.
- Bumped the gem version to `0.1.243`.

### Upgrade notes
- Additive params. Existing buttons keep the configured icon weight and the button text colour.
- `icon_variant` must be `:outline`, `:solid`, `:mini`, or `:micro`. `icon_style` must be `nil`, `:primary`, `:success`, `:warning`, or `:danger`. Anything else raises `ArgumentError`.
- There is no `icon_class`. Hosts recolour icons by overriding `--button-icon-primary-color`, `--button-icon-success-color`, `--button-icon-warning-color`, and `--button-icon-danger-color`.
- A disabled button still uses `--button-disabled-opacity`, which mutes the icon with the label.
- Rebuild host Tailwind so these literals are generated: `fp-button-icon`, `text-[color-mix(in_oklab,var(--button-icon-primary-color)_55%,var(--fp-button-text))]`, `text-[color-mix(in_oklab,var(--button-icon-success-color)_55%,var(--fp-button-text))]`, `text-[color-mix(in_oklab,var(--button-icon-warning-color)_55%,var(--fp-button-text))]`, and `text-[color-mix(in_oklab,var(--button-icon-danger-color)_55%,var(--fp-button-text))]`.
- Reload kit CSS for the same-style icon rule.
- Redeploy so `meta.gem_version` shows `0.1.243`.
- Do not tag this PR.

## [0.1.242] - 2026-10-15

### Added
- `--surface-hover-background-color`, `--surface-active-background-color`, `--surface-active-text-color`, `--surface-active-icon-color`, and `--surface-active-border-color`. Light hover is `#f0f0f0` and active is `#e4e4e4`. Dark hover is `oklch(0.22 0.02 250)` and active is `oklch(0.28 0.02 250)`. Ocean hover is `oklch(0.92 0.03 220)` and active is `oklch(0.88 0.04 220)`.
- `--table-row-selected-background-color` and `--pagination-current-background-color` / `--pagination-current-text-color`, both aliased to the active surface.

### Changed
- Sidebar, top nav, list, pill, table hover, and pill inactive hover follow the hover or active surface. A checked table row uses the selected token and keeps it on hover. Ocean no longer copies `--list-item-*`; it sets the surface pair.
- Pill and stacked tabs omit `style:` for the neutral active fill. `style: :primary` (and every other named style) adds `.fp-pill-button-slots` so the active pill uses that button colour. The stacked track uses the hover token.
- `current: true` on any Button, including `style: :primary`, uses the active surface and keeps it on hover.
- Segmented buttons and chart filter buttons do the same when `style:` is omitted. A named `style:` still paints that button colour.
- Inline radios, button chips, single-select options, rich text toolbar and bubble toggles, tree rows, and font-swatch rows use the active surface. Tree bars, underline tabs, and the sliding underline stay `--color-primary`.
- The neutral active pill is flat. `--tabs-pill-active-shadow` is `none`. Named pill styles, including `:primary`, keep `--shadow-md` through `.fp-pill-button-slots`.
- Bumped the gem version to `0.1.242`.

### Upgrade notes
- Selected chrome is one place: set `--surface-hover-background-color` and `--surface-active-*` after Flatpack CSS. Do not recolor each component. Set `--sidebar-item-active-*` (or another component token) only when that one control should diverge.
- Pill, stacked tab, and segmented `style:` now defaults to omitted. The active control is the neutral surface. Pass `style: :primary` to keep the brand fill. Underline tabs are unchanged.
- `current: true` is no longer the button's hover fill. A primary button with `current: true` is the neutral active surface, not a darker primary.
- Chart filter `selected: true` without `style:` is the same neutral surface, not primary.
- The current pagination page is `--pagination-current-*`, not `bg-primary`. A checked table row is `--table-row-selected-background-color`.
- A selected button chip fills with the active surface. It no longer draws `ring-[var(--color-ring)]`.
- The omitted pill shadow is `none`. Pass a named `style:`, including `:primary`, to keep `--shadow-md` on the active pill.
- Rebuild host Tailwind so the new literals are generated, including `bg-[var(--surface-active-background-color)]`, `text-[var(--surface-active-text-color)]`, `border-[var(--surface-active-border-color)]`, `hover:bg-[var(--surface-hover-background-color)]`, `bg-[var(--pagination-current-background-color)]`, `text-[var(--pagination-current-text-color)]`, `has-[:checked]:bg-[var(--table-row-selected-background-color)]`, and `has-[:checked]:hover:bg-[var(--table-row-selected-background-color)]`. Reload kit CSS for the token values.

## [0.1.241] - 2026-10-15

### Added
- `FlatPack::Lightbox::Component` is the overlay: a native `<dialog>` with backdrop, close, Escape, a focus trap, and focus returned to the trigger.
- Items take `src`, optional `alt` and `caption`, and `type` `:image` or `:video`. `group` names the gallery. `loop` and `show_count` are booleans.
- Triggers are separate. `FlatPack::Lightbox::Trigger`, `flat_pack_lightbox_trigger`, or `FlatPack::Lightbox.trigger_data(group:, index:)` open that group on an index. Thumbnails can sit in Masonry or anywhere else.
- Several items reuse `FlatPack::Carousel` inside the dialog for next, previous, arrows, swipe, and the count. One item hides the arrows and the count.
- Demo: `/demo/lightbox`.
- Lightbox `thumbs:` (default `false`) shows a thumbnail strip when there is more than one item. It passes through to Carousel `show_thumbs`. An item `thumb_src` falls back to `src`.

### Changed
- Carousel `lightbox: true` renders this same lightbox. The old overlay markup is gone.
- The lightbox dialog fills the viewport and stays transparent. Each image or video is `object-fit: contain` and keeps its shape, with no frame behind it. Close, arrows, and the count float on the backdrop. The caption sits below the media.
- With `thumbs: true`, the thumbnail strip floats along the bottom of that backdrop. It highlights the current item, scrolls horizontally, and a click jumps to that item. One item hides it. There is no thumb styling prop.
- Image slides still default `lightbox` to `true`. Video slides open the lightbox when `lightbox: true`. HTML slides and `:logo_slider` do not.
- Carousel accepts `show_counter` (default `true`), `fit` (`:cover` or `:contain`), and `stage` (Lightbox sets this; hosts leave it off).
- Bumped the gem version to `0.1.241`.

### Upgrade notes
- There is one lightbox. Carousel no longer renders `[data-flat-pack--carousel-target="lightbox"]`. Open and close go through `dialog[data-controller="flat-pack--lightbox"]`.
- `flat-pack:lightbox:open` detail is `{ group, index, trigger }`. `flat-pack:lightbox:close` and `flat-pack:lightbox:close-request` carry `{ group }`.
- A video slide with `lightbox: true` now opens. It used to ignore that flag. HTML still cannot.
- Lightbox takes no `class`, `style`, or colour prop, and no boxed-panel option. The dialog fills the viewport and stays transparent. Hosts colour the backdrop with `--modal-backdrop-color` and `--modal-backdrop-blur`. Controls and the count use `--carousel-control-*` and `--carousel-counter-*`. Captions use `--carousel-caption-overlay-text-color`. `--carousel-lightbox-image-background-color` still fills a carousel `fit: :contain` frame outside the lightbox.
- `group` must start with a letter. `index` must be zero or greater. `loop` and `show_count` must be `true` or `false`.
- Rebuild host Tailwind so the dialog and trigger literals are generated, including `h-dvh`, `backdrop:bg-[var(--modal-backdrop-color)]`, `backdrop:backdrop-blur-[var(--modal-backdrop-blur)]`, `absolute`, `inset-0`, `flex-1`, `rounded-none`, `bg-transparent`, `object-contain`, `text-[var(--carousel-caption-overlay-text-color)]`, `overflow-x-auto`, `flex-nowrap`, `pb-20`, and `[justify-content:safe_center]`.
- `thumbs` must be `true` or `false`.
- Reload kit CSS. The overscroll rule now targets `[data-controller~="flat-pack--lightbox"]`.
- Redeploy so `meta.gem_version` shows `0.1.241`.
- Do not tag this PR.

## [0.1.240] - 2026-10-14

### Added
- `FlatPack::Button::Component` accepts `align:` (`:center` default, `:start`), `lines:` (`1` default, or `2`), `current:` (`true` / `false`), and `title:` for the full label.
- `:start` left-aligns the label and gives it `flex-1 min-w-0`. `lines` clamps the label with an ellipsis. `2` top-aligns the row.
- `with_trailing` renders a fixed-width slot (`shrink-0`) at the end of the button. A count badge or an icon. It is top-aligned when the label wraps. Icon-only buttons reject it.
- `current: true` adds `.fp-button-current` (the hover fill at rest). On a link it also sets `aria-current="page"`. The focus ring stays.
- Leading icons stay `aria-hidden`.
- `FlatPack::Collection::Component` renders `<ul><li>` for each `with_item`. `as: :nav` wraps that list in `<nav aria-label>` and requires `label:`.
- `layout:` is `:stack` (default), `:grid` (auto-fill, equal height, `min_item_width:` default `"14rem"`), or `:wrap` (inline flex-wrap). `gap:` is `:sm`, `:md`, or `:lg`.
- Demos: `/demo/collection` (press-kit menu and badge/chip wrap) and `/demo/buttons` (align, lines, trailing, current).

### Changed
- Button labels clamp to one line. Pass `lines: 2` for two.
- Bumped the gem version to `0.1.240`.

### Upgrade notes
- Additive params. `align` defaults to `:center`. `lines` defaults to `1`, so a width-constrained label now ellipsizes instead of wrapping. Pass `lines: 2` for two lines and `title:` for the full string.
- `current` must be `true` or `false`. It sets `aria-current="page"` only when the button has `href:`.
- `align` must be `:center` or `:start`. Do not pass Hero `:left` or Grid `:stretch`.
- `with_trailing` is the trailing slot. Icon-only buttons raise if you set it.
- Collection `as` is `:list` or `:nav`. `as: :nav` requires `label:`. `label:` on a plain list raises.
- Collection `layout` is `:grid`, `:wrap`, or `:stack`. `min_item_width` is a CSS length and only works with `:grid`. There is no colour prop and no item class.
- Rebuild host Tailwind so these literals are generated: `justify-start`, `items-start`, `flex-1`, `min-w-0`, `text-start`, `truncate`, `line-clamp-2`, `shrink-0`, `self-start`, `grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]`, `[&>*]:w-full`, `[&>*]:flex-1`, `[&>*]:min-w-0`, `[&>*]:self-stretch`.
- Reload kit CSS for `.fp-button.fp-button-current`.
- Redeploy so `meta.gem_version` shows `0.1.240`.
- Do not tag this PR.

## [0.1.239] - 2026-10-14

### Added
- `FlatPack::List::Component` accepts `layout: :key_value`. The list renders a `<dl>`. Each `FlatPack::List::Item` takes `key:` and renders a `<div>` with a `<dt>` and a `<dd>`. Icons and keys share columns. Values wrap. Demo: `/demo/list#key-value`.
- `key_width:` is `:fit` (the widest key) or a CSS length such as `"10rem"`.
- `stack_below:` is `:sm`, `:md`, or `:lg`. Below that breakpoint the key sits above the value.
- `icon:` still renders inside the key, `aria-hidden`, through `FlatPack::Shared::IconComponent`. `trailing:` still sits at the end of the row.

### Changed
- Bumped the gem version to `0.1.239`.

### Upgrade notes
- Additive. `layout` defaults to `:items`. Existing lists render the same `<ul>` or `<ol>`.
- Pass `layout: :key_value` and give every item a `key:`. Render items inside the list block.
- `ordered: true`, `orderable: true`, and `selectable: true` raise `ArgumentError` on a key/value list. `href:` and `leading:` raise on those items. `key:` outside `:key_value` raises.
- `key_width` must be `:fit` or a CSS length. `stack_below` must be `:sm`, `:md`, `:lg`, or omitted.
- Rebuild host Tailwind so the grid classes in `FlatPack::List::KeyValueLayout` are generated, including `grid-cols-subgrid` and the full track literals `grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]`, `sm:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]`, `md:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]`, and `lg:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]`. Reload kit CSS for the description-list margin reset and divider.
- Redeploy so `meta.gem_version` shows `0.1.239`.

## [0.1.238] - 2026-10-14

### Added
- `FlatPack::Table::Column` accepts `width:` (`:fit`, `:fill`, or a CSS length such as `"12rem"`), `min_width:`, `max_width:`, `align:` (`:start`, `:center`, `:end`), `wrap:` (`:wrap`, `:nowrap`, `:truncate`), and `hide_below:` (`:sm`, `:md`, `:lg`, `:xl`).
- Widths render on `<colgroup>` / `<col>`. A CSS length uses `table-layout: fixed` unless a sibling column is `:fit` (fixed layout clips shrink-to-content columns). The length is still a `max-width` cap on the header and cells. Table `min_width:` still sets the horizontal scroll floor.
- `wrap: :truncate` clips the header and cells and puts the full text in `title`.
- `hide_below:` hides that header and its cells below the breakpoint. The column stays in the markup, so colspan still counts it.
- `FlatPack::Table::Component` accepts `style:` (`:default`, `:plain`) and `dividers:` (`true` / `false`). `:plain` drops the outer border, radius, and row hover.
- Demos: `/demo/tables/basic#table-column-widths`, `#table-align-wrap`, `#table-hide-below`, `#table-plain-rows`, `#table-no-dividers`. The plain demo is an icon column (`width: :fit`), a fixed key, and a fill value, with `headers: false` and `style: :plain`.

### Changed
- Bumped the gem version to `0.1.238`.
- Header and cell alignment uses logical `text-start` / `text-center` / `text-end`. Default align is `:start`.
- The draggable demo sizes the grip with `width: :fit`. Sortable id and views columns use the same column options.

### Upgrade notes
- Additive. Existing tables keep the bordered frame, row lines, and row hover.
- `style` must be `:default` or `:plain`. `dividers` must be `true` or `false`.
- Column `width:` is `:fit`, `:fill`, or a length such as `"12rem"`. Column `min_width:` and `max_width:` are lengths. They are not the table scroll floor and they are not a class or a raw style string.
- A length `width:` sets `table-layout: fixed` when no column is `:fit`. Beside `:fit`, the table stays on automatic layout and the length cells get `max-width` of that length. Pass `min_width: :none` on the table when the scroll floor should stay off.
- `align:` is `:start`, `:center`, or `:end`. In left-to-right text, `:start` matches the old `text-left`.
- `wrap: :truncate` ellipsizes inside a length `width:`. On a `:fill` column the cell is capped with `max-width: 0` so the ellipsis uses the leftover space instead of widening the table.
- `hide_below:` does not remove the column from `column_count` or colspan.
- There is no compatibility shim. These options are new.
- Rebuild host Tailwind so `text-start`, `text-center`, `text-end`, `whitespace-nowrap`, `truncate`, `min-w-0`, `max-w-full`, `shrink-0`, `table-fixed`, `max-sm:hidden`, `max-md:hidden`, `max-lg:hidden`, `max-xl:hidden`, and the `max-*: [visibility:collapse]` column classes are generated.
- Redeploy so `meta.gem_version` shows `0.1.238`.
- Main was `0.1.237` after #276. Recheck main at merge time and bump again if it has moved. Do not tag this PR.

## [0.1.237] - 2026-10-14

### Added
- `FlatPack::Card::Component` `style:` is the colour fill: `:default`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`. `shadow:` is `:none`, `:sm`, or `:md`. `border:` is `:none`, `:default` (1px), or `:strong` (2px). `hover:` stays `:none`, `:subtle`, or `:strong`, and defaults to `:none`. Hover paints outside the component layer so a style fill or shadow does not cover it. Demo: `/demo/cards/tones`.
- `FlatPack::Card::Stat::Component` takes the same `style:`.

### Changed
- Removed card `style:` values `:flat`, `:elevated`, `:outlined`, `:interactive`, and `:list`.
- Removed the card `theme:` hash.
- Bumped the gem version to `0.1.237`.

### Upgrade notes
- Replace `style: :flat` with `style: :shaded` and `border: :none`.
- Replace `style: :elevated` with `shadow: :md`. Dark themes already draw `--shadow-md` larger than the light token.
- Replace `style: :outlined` with `border: :strong`.
- Replace `style: :interactive` with `hover: :strong`. Hover no longer follows the old style.
- `:list` only set the hover default to `:subtle`. The horizontal list demo already passed `padding: :sm`. Use `hover: :subtle` and `padding:`.
- Replace `theme:` with `style:`. The card does not take raw colours, and it does not recolour nested buttons or badges.
- Host themes set `--card-style-{default|shaded|brand|brand-subtle|gradient}-{background|text-color|muted-text-color|border-color}`. `background` is a CSS `background` so the gradient token can be a gradient. Dark mode overrides `--card-style-gradient-background`.
- Rebuild host Tailwind so the style classes are generated, including `[background:var(--card-style-brand-background)]`, `shadow-[var(--shadow-sm)]`, and `shadow-[var(--shadow-md)]`.
- Reload `flat_pack/variables` and `flat_pack/application`.
- Redeploy so `meta.gem_version` shows `0.1.237`.

## [0.1.236] - 2026-10-14

### Added
- `FlatPack::Table::Component` accepts `headers: false` (default `true`). The header row stays in the DOM and is visually hidden with `sr-only`. Column `title:` stays required. Demo: `/demo/tables/basic#table-without-headers`.
- `FlatPack::Select::Component` option hashes accept `icon:` (a Heroicon name). The custom menu, the closed control, multiselect chips, nested parent and child rows, and remote search results show it before the label. Icons are decorative. Demo: `/demo/forms/select#select-with-icons`.

### Changed
- Bumped the gem version to `0.1.236`.
- A searchable select inside a collection editor cell can open its menu past the card edge.

### Upgrade notes
- Additive. Existing tables keep visible headers. Existing selects without `icon:` look the same.
- `headers` must be `true` or `false`. `title:` is still required when headers are hidden.
- `icon:` is a Heroicon name such as `"camera"`. The icon uses `FlatPack::Shared::IconComponent` size `:sm`, matching the `text-sm` select. A native `<select>` cannot draw icons.
- Remote select JSON may include `"icon"` on each item. Local options use the same key, including `children`.
- Rebuild host Tailwind so `sr-only` is generated if it is not already. Reload kit CSS so a collection editor card can show an open select menu, and reload kit JavaScript so select icons update after a search.
- Redeploy so `meta.gem_version` shows `0.1.236`.

## [0.1.235] - 2026-10-14

### Added
- `FlatPack::Media::Component` renders one image: `src`, required `alt`, `width`, `height`, `loading="lazy"`, `decoding="async"`, and `aspect-ratio` from those dimensions. Corners use `--media-radius` (default `--radius-md`). The hairline uses `--media-outline-color`. `with_item(placement:, inset:)` passes through to Overlay for a badge or button. Demo: `/demo/masonry`.

### Changed
- `FlatPack::Masonry::Component` is layout only. Cells are `with_item`. `FlatPack::Masonry::Image` and `with_image` are gone.
- Bumped the gem version to `0.1.235`.

### Upgrade notes
- Replace `masonry.with_image(...)` with `masonry.with_item` and `FlatPack::Media::Component`.
- Wrap a link in the host when the tile should navigate. Put the filename in that same cell, under the media. Do not put a button inside the link.
- `--media-radius` and `--media-outline-color` are the image tokens. There is no colour, radius, or theme prop.
- Rebuild host Tailwind so `rounded-[var(--media-radius)]`, `outline-[var(--media-outline-color)]`, and `group/media` are generated.
- Redeploy so `meta.gem_version` shows `0.1.235`.

## [0.1.234] - 2026-10-14

### Added
- `FlatPack::CopyButton::Component` copies `text:` or the value of `target:`. It uses Button sizes and styles. The Copied state keeps that style and only changes the label and icon. Error uses danger tokens. Demo: `/demo/buttons/copy`.
- `flat-pack--clipboard` writes with `navigator.clipboard.writeText`, then a hidden textarea and `document.execCommand("copy")`. It announces through a live region, and dispatches `flat-pack:clipboard:copied` and `flat-pack:clipboard:error`.
- Locale keys `flatpack.clipboard.copy`, `flatpack.clipboard.copied_label`, and `flatpack.clipboard.error_label`.

### Fixed
- `flat_pack/copy.js` includes the English fallback for `collection_editor.already_joined`.
- Copy button icons are centered with CSS grid. Kit `application.css` still does not use `justify-content: center`.

### Changed
- Bumped the gem version to `0.1.234`.
- Text Input and Text Area `quick_copy: true` copy through `flat-pack--clipboard`. The trailing icon, readonly field, and toast stay. After a click the icon swaps to a check or an error icon. The check keeps the field’s icon colour.
- Section Title `anchor_link: true` copies through the same controller. Hover, the link icon, the tooltip, and the hash update stay. The anchor announces the copy instead of staying silent. The check keeps the link colour.

### Upgrade notes
- Additive for Button, Text Input, Text Area, and Section Title callers. `quick_copy:` and `anchor_link:` keep the same arguments.
- Copy Button `text:` is the clipboard string. The visible label is `label`.
- Add `flatpack.clipboard.copy` (“Copy”), `flatpack.clipboard.copied_label` (“Copied”), and `flatpack.clipboard.error_label` (“Couldn’t copy”) to host locale files that translate `flatpack.*`.
- Pin `flat_pack/clipboard`, or rerun `rails generate flat_pack:install`. The engine importmap pins it too.
- Reload kit CSS and JavaScript. No new Tailwind utilities.
- With `prefers-reduced-motion: reduce`, Copied and error stay for at most 600ms and the icon swap does not fade. `timeout: 0` still holds the state.
- `writeClipboardText` and `readClipboardSource` in `flat_pack/clipboard.js` are the extension point for a later share button. This release does not call the Web Share API.
- Redeploy so `meta.gem_version` shows `0.1.234`.

## [0.1.233] - 2026-10-13

### Added
- `FlatPack::VideoPreview::Component` shows a thumbnail and a centred play button in a fixed aspect-ratio frame (default `16/9`, same ratio strings as Card media, rounded like Card media). The host supplies the player in `with_player`. That markup stays in a `<template>` until someone clicks, or presses Enter or Space. Flatpack does not know about providers, build embed URLs, or accept a raw embed string. `with_item` passes `placement` and `inset` through to Overlay. Demo: `/demo/video_preview`.

### Changed
- Bumped the gem version to `0.1.233`.

### Upgrade notes
- Additive. Card, Carousel, and Overlay stay as they are.
- `label:` is required. It is the play button's accessible name. Translate it in the host. There is no `flatpack.video_preview` string and no colour or theme prop.
- The host writes the iframe or video tag, including any autoplay flag, and decides which players are allowed.
- Activation runs once, dispatches `flat-pack:video-preview:play`, and moves focus into the player.
- With `prefers-reduced-motion: reduce`, the swap is instant and the play button does not shift on press.
- Rebuild host Tailwind so the frame utilities are generated: `aspect-[16/9]`, `aspect-[4/3]`, `aspect-square`, `rounded-[var(--radius-lg)]`, and the play-button classes in `FlatPack::VideoPreview::Component`.
- Reload Flatpack CSS so `.fp-video-preview__player` fills the inserted player, and reload Flatpack JavaScript so `flat-pack--video-preview` is available.
- Redeploy so `meta.gem_version` shows `0.1.233`.

## [0.1.232] - 2026-10-13

### Added
- `FlatPack::SectionTitle::Component` accepts `with_trailing`. The slot renders in the title row after the heading and before the copy-link icon. It sits outside the heading and outside the anchor, so the heading name and the copy-link label stay the title. Pass a badge, a count, or anything else. Demo: `/demo/section_title`.

### Changed
- Bumped the gem version to `0.1.232`.
- The title row can wrap. The heading can shrink and break long words. Trailing content and the copy-link icon keep their size.

### Upgrade notes
- Additive. Calls that only pass `title:` render the same heading, subtitle, and copy link.
- `title:` stays a string. Inline edit titles are unchanged.
- There is no count or badge param. Use `with_trailing`.
- Rebuild host Tailwind so these utilities are generated: `flex-wrap`, `flex-1`, `max-w-max`, `min-w-0`, `break-words`, and `shrink-0`.
- Redeploy so `meta.gem_version` shows `0.1.232`.

## [0.1.231] - 2026-10-13

### Added
- `FlatPack::Overlay::Component` places content on media. `with_media` is the element underneath. `with_item` can be used more than once for a badge, icon, button, or anything else.
- Each item takes `placement:` on a nine-cell grid (`:top_left`, `:top_center`, `:top_right`, `:middle_left`, `:center`, `:middle_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`, default `:top_left`) and `inset:` `:sm` / `:md` / `:lg` (default `:md`). The gaps are `--overlay-inset-sm` (`0.5rem`), `--overlay-inset-md` (`1rem`), and `--overlay-inset-lg` (`1.5rem`). Demo: `/demo/overlay`.

### Changed
- Bumped the gem version to `0.1.231`.

### Upgrade notes
- Additive. Hero, Carousel, FAB, Avatar, and Card media stay as they are.
- Overlay does not theme, recolour, or shadow its items. Pass those components in the item slot so they keep their own look.
- `placement` on an overlay item is the nine-cell grid. Tooltip, popover, and dropdown `placement` values are unchanged. FAB corners stay `position`.
- Rebuild host Tailwind so the positioning utilities are generated: `inline-flex`, `contents`, `top-[var(--overlay-inset-sm)]` (and the `md` / `lg` and `right` / `bottom` / `left` matches), plus `top-1/2`, `left-1/2`, and the translate classes.
- To change the gap, set `--overlay-inset-sm`, `--overlay-inset-md`, and `--overlay-inset-lg` on `:root` or a named `[data-theme]` block. `:center` ignores them. Edge-centers use the token on the edge axis only.
- Redeploy so `meta.gem_version` shows `0.1.231`.

## [0.1.230] - 2026-10-13

### Added
- Inline edit shows a small muted label just above the field while you edit (“Editing”), while the save is in flight (“Saving…” plus a small spinner), and after a successful save (“Saved” plus a green check, for about 1.5 seconds, then it fades). When save or validation fails, the same label shows the message the live region speaks, in the error color. The label is absolutely positioned, so the field does not shift. It is `aria-hidden`. Copy uses the existing `flatpack.inline_edit.saved` string (“Saved”).

### Changed
- Bumped the gem version to `0.1.230`.
- `flatpack.inline_edit.saving` is now “Saving…”.
- The spinner and check that sat beside the field are gone. Save feedback lives only in the floating label.

### Upgrade notes
- Additive. Add `flatpack.inline_edit.editing` to host locale files. English default is “Editing”. `flatpack.inline_edit.saved` is unchanged (“Saved”).
- If a host translated `flatpack.inline_edit.saving`, update that string if it should match the visible “Saving…” label. The English default changed from “Saving” to “Saving…”.
- Drop any host CSS aimed at `.fp-inline-edit__status`, `.fp-inline-edit__spinner`, or `.fp-inline-edit__tick`. Those elements are no longer rendered.
- Rebuild host CSS so `flat_pack/inline_edit.css` includes the state label. No Tailwind utilities were added.
- Redeploy so `meta.gem_version` shows `0.1.230`.
- With `prefers-reduced-motion: reduce`, the saved label skips the 1.5s hold and stays only briefly, with no fade.

## [0.1.229] - 2026-10-13

### Fixed
- Table and grid sortable controllers attach drag listeners when a row or item appears after `connect()`. `rowTargetConnected` and `itemTargetConnected` store one handler set and add it. `rowTargetDisconnected` and `itemTargetDisconnected` remove that set. Reconnecting the controller does not add a second set.

### Changed
- Bumped the gem version to `0.1.229`.
- Synchronized `Gemfile.lock` and the Rails 7 dummy lockfile with `0.1.229`.

### Upgrade notes
- Reload Flatpack JavaScript. Ruby callers stay the same.
- A sortable row or grid item added after the controller connects is draggable.

## [0.1.228] - 2026-10-12

### Added
- `FlatPack::Fieldset::Component` names a cluster of form controls. `title:` is the legend. Optional `description:`, `error:`, and `disabled:` cover the hint, the group message, and a native disabled group. The block is the fields. Demo: `/demo/forms/fieldset`.

### Changed
- Bumped the gem version to `0.1.228`.
- Synchronized the Rails 7 dummy lockfile with `0.1.228`.

### Upgrade notes
- Additive. Keep calling the same input components. Wrap a cluster in `FlatPack::Fieldset::Component` when that cluster needs a name.
- Rebuild host Tailwind so the fieldset utilities (`float-left`, `clear-both`, `min-w-0`, `border-0`) are generated if the host scans component files.
- Redeploy so `meta.gem_version` shows `0.1.228`.

## [0.1.227] - 2026-10-10

### Added
- `FlatPack::InlineEdit::Component` turns a heading or paragraph into an in-place editor. The same element becomes `contenteditable`. Type, size, weight, and wrapping stay put. No bordered field.
- `mode:` `:text` (default, Enter saves), `:plain` (Enter is a newline, Cmd/Ctrl+Enter saves), `:rich` (ContentEditor bubble toolbar, no Edit/Save/Cancel bar).
- `tag:` `:span`, `:h1`–`:h6`, `:p`, `:div`. A content block edits the first `data-inline-edit-target`, heading, or `p` inside.
- `name:` / `value:` keep a hidden input for a normal form when `update_url:` is omitted. `update_url:` + `method:` (default `:patch`) save with CSRF and `Accept: turbo-stream`.
- `label:`, `placeholder:`, `maxlength:`, `required:`, `save_on_blur:` (default true), `cue:` `:highlight` (default Notion-style wash) / `:tint` (same paint) / `:underline` / `:none`.
- Tokens `--inline-edit-hover-bg`, `--inline-edit-focus-color`, `--inline-edit-cue-color`, `--inline-edit-error-color`, `--inline-edit-placeholder-color`, `--inline-edit-placeholder-hover-color` (light and dark). Hover wash is a ~7% (dark ~9%) `color-mix` tint with box-shadow spread, not padding. Keyboard Tab before edit uses the same wash (`:focus-visible`). Editing drops the wash and ring — caret only. Placeholder copy darkens on hover and keyboard focus.
- ContentEditor’s balloon toolbar now lives in `FlatPack::Shared::ExecCommandBalloon` and `exec_command_bubble.js`. ContentEditor still renders the Edit/Save/Cancel bar and the same bubble.

### Changed
- Bumped the gem version to `0.1.227`.
- Synchronized the Rails 7 dummy lockfile with `0.1.227`.

### Upgrade notes
- New opt-in component. Existing ContentEditor, PageTitle, and Hero calls are unchanged.
- Reload kit CSS and JavaScript. Rebuild host Tailwind if you scan Flatpack sources.
- Redeploy so `meta.gem_version` shows `0.1.227`.
- For `:rich`, sanitize stored HTML with `FlatPack::RichTextSanitizer`. `update_url:` uses `AttributeSanitizer`.

## [0.1.226] - 2026-10-10

### Added
- `FlatPack::HeroTitle::Component` renders a standalone cover headline. Args: `text:` (or a content block), `size:` (`:md`, `:lg`, `:xl`, `:xxl`; default `:xl`), `level:` (`:h1`–`:h6`, default `:h1`), optional `align:` (`:left`, `:center`), and `system_arguments`. Ink is `--surface-content-color`; a caller `text-*` class still wins (Hero overlay ink).
- Size tokens `--hero-title-md-size`, `--hero-title-lg-size`, `--hero-title-xl-size`, `--hero-title-xxl-size` with matching `-min` / `-max`. Each size is a fluid clamp. `:xl` aliases `--display-size` (`clamp` from `--text-5xl` / 48px to `5.5rem` / 88px, preferred `1rem + 5vw`) so today's display output is unchanged. Weight, tracking, and leading reuse `--display-weight` (600), `--display-tracking` (`-0.03em`), and `--display-leading` (`1.05`). Unlayered `.fp-hero-title` / `.fp-hero-title--*` sit beside `.fp-display`.
- Hero accepts opt-in `title_size:` (`:md`, `:lg`, `:xl`, `:xxl`) to pick a Hero Title step.
- Dummy demo at `/demo/hero_title` (sizes, wrapping, inside Hero, dark).
- Bumped the gem version to `0.1.226`.

### Changed
- Hero `size: :display` renders the headline through Hero Title at `:xl`. Default Hero headlines stay on `--text-4xl` / `--hero-headline-size`.
- PageTitle `size: :display` renders the heading through Hero Title at `:xl`. Default PageTitle stays `font-bold` with `--page-title-h*-size`.

### Upgrade notes
- Existing Hero and PageTitle calls are unchanged. `size: :default` and `size: :display` look the same as `0.1.224`.
- New component. Use `FlatPack::HeroTitle::Component` for a cover line without Hero or PageTitle chrome. Hero `size: :display` already does this. Pass `title_size:` on Hero to pick another step.
- Reload kit CSS for `--hero-title-*` and `.fp-hero-title`. Themes override `--hero-title-<size>-size-min` / `-max` (or the clamp) on a named `data-theme` block. `:xl` follows `--display-size`; override `--display-size-max` to raise or lower that step.
- Redeploy so `meta.gem_version` shows `0.1.226`.

## [0.1.225] - 2026-10-10

### Added
- `FlatPack::RangeInput::Component` accepts an opt-in size-slider presentation. `variant: :size` / `:text_size` put a small and large `A` (theme font) at the track ends. `variant: :zoom` defaults to `magnifying-glass-minus` / `magnifying-glass-plus`. `start_icon:` / `end_icon:` take any kit icon name. End glyphs and icons are decorative (`aria-hidden`); the input keeps its accessible label.
- Size, text-size, and zoom sliders snap to `step:` and show one tick under the track per step. Pass `ticks: true` on a default RangeInput for the same notches, or `ticks: false` to hide them. Arrow keys move one step (native range). Ticks render when the step count is 2–24.
- Optional live preview: `preview_target:` (CSS selector or element id) and `with_preview` write `--fp-range-value` (current number), `--fp-range-scale` (0–1), and `--fp-range-max` on the target as you drag. The sample renders **below** the track with no fill or border. Size and text-size sliders show decorative `sample:` letters there (`"Aa"` by default). `with_preview` replaces the built-in letters. Stimulus does this work only when a preview is present. Default RangeInput markup and behaviour are unchanged.

### Changed
- Bumped the gem version to `0.1.225`.
- Synchronized the Rails 7 dummy lockfile with `0.1.225` so frozen CI installs resolve the path gem.

### Upgrade notes
- Existing RangeInput calls are unchanged. Pass `variant: :size`, `variant: :zoom`, or `start_icon:` / `end_icon:` for the size-slider layout.
- For live preview, pass `with_preview` (renders below the track) and/or `preview_target:`. Size and text-size sliders already show `sample:` (`"Aa"` by default) below the track; pass `sample: "Embiggen"` to change it or `sample: ""` to hide it. Size custom slot markup with `.fp-range-input-sample`, or `font-size: calc(var(--fp-range-value) * 1px)`. Set the same custom properties on an external target for first paint.
- Thumb fill still aliases `--color-primary`. Reload kit CSS and JavaScript. Redeploy so `meta.gem_version` shows `0.1.225`.

## [0.1.224] - 2026-10-10

### Changed
- Display cover size now tops out at `--display-size-max` (`5.5rem` / 88px) on wide desktops, with `--display-size-min` (`--text-5xl` / 48px) on small viewports. Preferred size is `1rem + 5vw` (~80px at 1280). `--display-leading` is `1.05`. `--display-tracking` stays `-0.03em`.
- `--display-weight` is `600` (semibold). Content `h1` and Hero headlines already use 600; PageTitle `size: :display` now matches. Default PageTitle stays `font-bold`.
- Type scale token `--text-8xl` (6rem / 96px) with `--text-8xl--line-height` of `1`, mapped in `@theme inline` so `text-8xl` works after a Tailwind rebuild. Themes can set `--display-size-max: var(--text-8xl)` for a 96px ceiling.
- Bumped the gem version to `0.1.224`.

### Upgrade notes
- Existing default PageTitle and Hero calls are unchanged. Only `size: :display` and `--display-*` defaults change.
- Cover titles are larger on desktop (~88px from 1440) and still ~48px on a phone. Reload kit CSS. Rebuild host Tailwind for `text-8xl`.
- Themes that overrode `--display-size` keep that override. To keep the fluid clamp and change the ceiling, set `--display-size-max` (or `--display-size-min`) instead.
- Redeploy so `meta.gem_version` shows `0.1.224`.

## [0.1.223] - 2026-10-09

### Added
- Type scale tokens `--text-6xl` (3.75rem / 60px) and `--text-7xl` (4.5rem / 72px), with `--text-6xl--line-height` / `--text-7xl--line-height` of `1`, mapped in `@theme inline` so `text-6xl` / `text-7xl` utilities work after a Tailwind rebuild.
- Theme-tunable display tokens `--display-size` (fluid clamp from `--text-5xl` / 48px to `--text-7xl` / 72px), `--display-tracking` (`-0.03em`), and `--display-leading` (`1.1`). Kit CSS ships unlayered `.fp-display` so Tailwind preflight cannot collapse heading size.
- `FlatPack::PageTitle::Component` and `FlatPack::Hero::Component` accept opt-in `size: :display` for cover titles. Default output is unchanged. Display headlines set the display tokens inline.

### Changed
- Bumped the gem version to `0.1.223`.

### Upgrade notes
- Existing PageTitle and Hero calls are unchanged. Pass `size: :display` for cover type.
- Rebuild host Tailwind so `text-6xl` / `text-7xl` generate. Reload kit CSS for `--display-*` and `.fp-display`.
- Themes override `--display-size` (and tracking / leading) on a named `data-theme` block. Product chrome stays on `--text-5xl` and below unless a component opts in.
- Redeploy so `meta.gem_version` shows `0.1.223`.

## [0.1.222] - 2026-10-09

### Added
- FAB `size: :sm` is a 40px main control with matching speed-dial glyphs, label pills, and icons. `:md` (56px) and `:lg` (64px) are unchanged.
- Speed-dial `with_action(..., style: :danger)` paints the round glyph (rest, hover, and focus) with `--button-danger-*`, the same tokens TrashButton uses. Omit `style:` for today’s surface glyph.

### Changed
- Bumped the gem version to `0.1.222`.

### Upgrade notes
- Existing FAB calls are unchanged. Pass `size: :sm` for the smaller control. Pass `style: :danger` on a speed-dial action for Trash and other destructive items.
- `contained: true` already shipped in `0.1.221`. It pins the FAB inside the nearest positioned ancestor (`position: absolute`), opens the stack inside that box, and does not lift for a page Bottom Nav. Top corners open downward. Rebuild host CSS if you `@import` kit sources.
- Redeploy so `meta.gem_version` shows `0.1.222`.

## [0.1.221] - 2026-10-09

### Added
- `FlatPack::Fab::Component` is a floating action button. Rest is a large round primary control (`:md` 56px, `:lg` 64px) pinned to a corner (`position: :bottom_right` default, also `:bottom_left`, `:top_right`, `:top_left`). No actions: a link (`href:`) or a button (`data:` for Turbo/Stimulus). `with_action(icon:, label:, href:, **attrs)` opens a stacked speed-dial (`layout: :stack`). Actions are smaller round buttons with a label pill, staggered ~30ms, and the plus rotates 45°. Close via the main button, Escape, backdrop/outside click, or choosing an action. `backdrop:` defaults to true. `hide_on_scroll:` hides on scroll down. Safe-area insets and auto offset above Bottom Nav (`--fp-fab-nav-offset`). z-index 45, below Modal/Drawer/Toasts. An `:arc` layout is reserved for a later release.

### Changed
- Bumped the gem version to `0.1.221`.

### Upgrade notes
- New component. Existing Button, Modal, and Bottom Nav calls are unchanged.
- Rebuild host Tailwind so `rounded-full` and the FAB utilities generate. Reload kit CSS and JavaScript.
- Redeploy so `meta.gem_version` shows `0.1.221`.
- `layout: :arc` raises until that layout ships. Use `:stack`.
- When a Bottom Nav is on the same screen, the FAB measures `.fp-bottom-nav` and sits above it. Hosts can also set `--fp-fab-nav-offset` or pass `offset:`.

## [0.1.220] - 2026-10-09

### Added
- `FlatPack::RadioGroup::Component` accepts `variant: :swatches` for a fixed colour palette. Each option is a filled circle with a visually hidden radio, a selected offset ring (ColorSwatch tokens), a check that flips ink on light vs dark fills, and a name tooltip. Pass `options: [{ label:, value:, color: }]` — `color:` defaults to `value` when that is a CSS colour. `size:` maps to ColorSwatch `:sm` / `:md` / `:lg`. `show_tooltip:` defaults to true. Existing `:default`, `:inline`, and `:cards` markup is unchanged. ColorSwatch stays the native `<input type="color">` picker.

### Changed
- Bumped the gem version to `0.1.220`.

### Upgrade notes
- Existing RadioGroup and ColorSwatch calls are unchanged. Pass `variant: :swatches` only when the person picks one colour from a host-supplied palette.
- Hash options may add `color:`. A hex (or other safe CSS colour) `value` is enough; otherwise `color:` is required.
- Rebuild host Tailwind so swatch size, ring, and `sr-only` utilities generate. Reload kit CSS if you ship ColorSwatch tokens already.
- Redeploy so `meta.gem_version` shows `0.1.220`.

## [0.1.219] - 2026-10-09

### Added
- `FlatPack::TrashButton::Component` is an opt-in two-step delete control. At rest it is a default Button with a trash icon (icon-only unless `text:` is passed). Hover and keyboard focus use the theme danger button tokens, scoped to this component. Click swaps it for a danger Confirm button in the same position plus a default Cancel (X) that slides in on `expand: :right` or `:left`. Confirm submits `url:` with `method: :delete` by default (Turbo `button_to` form) and dispatches `flat-pack:trash-button:confirm`. Confirm ignores clicks for 300ms after it appears. Cancel, Escape, or a click outside restores rest. `timeout:` (default 4000ms, `0` or `false` to disable) auto-reverts. Stimulus controller: `flat-pack--trash-button`.

### Changed
- Bumped the gem version to `0.1.219`.

### Fixed
- Rest, Confirm, and Cancel share one height for each `size:` (`:sm` / `:md` / `:lg`). Cancel is the icon-only square. Labelled rest and Confirm use that same height so arming does not jump. The swap is opacity and a Cancel slide, not `scale()`, so the chrome does not shrink. Scoped to `.fp-trash-button`; other Buttons are unchanged.

### Upgrade notes
- New component. Existing Button calls, markup, and styles are unchanged.
- Pass `url:` only when Confirm should submit a form. JS-only callers listen for `flat-pack:trash-button:confirm` and may `preventDefault` to skip the submit.
- Rebuild host Tailwind so `sr-only` and `contents` generate. Reload kit CSS and JavaScript.
- Redeploy so `meta.gem_version` shows `0.1.219`.

## [0.1.218] - 2026-10-09

### Added
- `FlatPack::Modal::Component` accepts `origin: :trigger` so the dialog can grow out of the control that opened it and shrink back on close. Default `origin: :center` keeps today’s fade and scale, including markup. Motion lives in `trigger_origin.js` for later Drawer reuse. Picker, Modal Filter, Drawer, and other hosts are unchanged.

### Changed
- Bumped the gem version to `0.1.218`.

### Upgrade notes
- Existing Modal calls are unchanged. Pass `origin: :trigger` only when the dialog should grow from the opening control.
- `:trigger` falls back to today’s motion when no trigger is known, the trigger is gone or off-screen, motion is reduced, or the viewport is under `640px`.
- With `navigable: true`, only the first open and the final close use the trigger motion.
- Reload kit JavaScript. Redeploy so `meta.gem_version` shows `0.1.218`.

## [0.1.217] - 2026-10-09

### Added
- Tabs and Button::Pill accept `indicator: :slide`. Default stays today’s instant active swap. `:slide` renders one marker per list (underline bar or pill fill) that follows the active item on `--duration-base` / `--easing-standard`. Items keep the text colour change. A shared Stimulus controller (`flat-pack--slide-indicator`) measures the active item, tracks resize and font load, and snaps under `prefers-reduced-motion`. Pill links slide first, then visit (`Turbo.visit` when present). Modifier-clicks, middle-click, and `target: :_blank` are not intercepted.

### Changed
- Bumped the gem version to `0.1.217`.

### Upgrade notes
- Existing Tabs and Pill calls are unchanged. Omit `indicator:` for today’s markup and behaviour.
- Pass `indicator: :slide` to opt in. Unknown names raise `ArgumentError`.
- Reload kit CSS and JavaScript so `.fp-slide-indicator` and `flat-pack--slide-indicator` load. Bundled esbuild hosts add `SlideIndicatorController` from `docs/installation.md`.
- Redeploy so `meta.gem_version` shows `0.1.217`.

## [0.1.216] - 2026-10-09

### Added
- `FlatPack::Modal::Component` accepts `navigable: true` with `src:` for opt-in multi-screen flows. The body is a Turbo Frame (`{id}-screen`) loaded lazily on open. Screens wrap in `flat_pack_modal_screen` / `FlatPack::Modal::Screen` and can supply title, header actions, and footer slots. `data-fp-nav="push|back|close|replace|reset"` drives navigation with no host JavaScript. History is in-memory (no `pushState`). Back re-fetches the previous URL. Closing clears history. Loading uses the kit spinner/skeleton; failed frame requests show an error with retry. Logic lives in `flat-pack--navigable` so Drawer can reuse it later.

### Changed
- Bumped the gem version to `0.1.216`.

### Upgrade notes
- Existing Modal calls are unchanged. `navigable:` defaults to `false`. Picker, ModalFilter, Command palette, Drawer, and other consumers keep today’s markup.
- Pass `navigable: true` and `src:` only for multi-screen dialogs. Do not pass `header` or `body` slots with `navigable: true`.
- Rebuild host Tailwind so `sr-only`, `min-h-48`, and overlay utilities generate. Reload kit CSS and JavaScript.
- Redeploy so `meta.gem_version` shows `0.1.216`.

## [0.1.215] - 2026-10-09

### Fixed
- RangeInput’s slider thumb uses `--color-primary` so the handle is visible in the default light theme. The ring stays `--surface-background-color` (plus the existing thumb shadow) so it still reads on the primary fill and the grey track, in light and dark, WebKit and Firefox.

### Changed
- Bumped the gem version to `0.1.215`.

### Upgrade notes
- `--range-thumb-color` now aliases `--color-primary` instead of `--surface-background-color`. `--range-thumb-border-color` is still `--surface-background-color`. Token names are unchanged, so a host override of either name still wins.
- Reload kit CSS. Redeploy so `meta.gem_version` shows `0.1.215`.

## [0.1.214] - 2026-10-09

### Added
- `FlatPack::Masonry::Component` stacks mixed-ratio items without empty holes. `columns:` takes an integer or a breakpoint hash. `gap:` uses the same `:sm` / `:md` / `:lg` scale as Grid. `order: :columns` (default) is CSS multi-column layout with no JavaScript. `order: :rows` keeps left-to-right reading order: native CSS masonry where the browser has it, otherwise a Stimulus controller (`flat-pack--masonry`) measures heights and sets grid-row spans. `with_item` takes arbitrary content. `with_image` takes `src`, `alt`, `width`, `height`, and optional `href` / `caption`. Images set `aspect-ratio` from width/height, plus `loading="lazy"` and `decoding="async"`.

### Changed
- Bumped the gem version to `0.1.214`.

### Upgrade notes
- New component. Existing Grid calls are unchanged. Use Masonry when portraits and landscapes should keep their shape.
- Rebuild host Tailwind so `columns-*`, `grid-cols-*`, and the gap classes generate. Reload kit CSS and JavaScript.
- Redeploy so `meta.gem_version` shows `0.1.214`.
- In `order: :columns`, assistive tech follows DOM order while the visual stack goes down each column. Prefer `order: :rows` when those should match.

## [0.1.213] - 2026-10-09

### Added
- `FlatPack::Modal::Component` accepts `scroll: :body | :page` (default `:body`, today’s capped card with an internal body scroller) and `sticky_footer:` (default `false`). `scroll: :page` sizes the dialog to its content and scrolls the overlay. Short page-scroll dialogs still sit like today. `sticky_footer: true` requires `:page` and pins the action row to the bottom of the viewport.

### Changed
- Bumped the gem version to `0.1.213`.
- Modal enter/exit motion writes the Tailwind v4 `scale` property, matching Command palette.

### Fixed
- Opening a modal no longer leaves the dialog at `scale-95`. Tailwind 4’s `scale-95` uses the CSS `scale` property; the controller was writing `transform: scale(1)`.
- Dialog height cap and overlay min-height use `dvh` with a `vh` fallback, so iOS Safari toolbars do not hide the footer.
- `.fp-overlay-pad` is unlayered, same as `.fp-top-nav`, so host Tailwind preflight cannot zero overlay insets when Flatpack CSS is linked first. Drawer, Command palette, and carousel lightbox share that class.

### Upgrade notes
- Existing Modal calls are unchanged. Pass `scroll: :page` only when the overlay should scroll. Pass `sticky_footer: true` only with `:page`.
- Rebuild host Tailwind so `sm:my-auto` is generated if you use page scroll. Reload kit CSS and JavaScript.
- Redeploy so `meta.gem_version` shows `0.1.213`.

## [0.1.212] - 2026-10-09

### Added
- `FlatPack::RadioGroup::Component` accepts `variant: :default | :inline | :cards`. Default stays the vertical radio list. `:inline` is a wrapping row of compact options that reuse Button chrome (secondary when unselected, primary when selected, same radius/padding/type). `:cards` is a responsive grid of larger selectable cards with a centred plain `icon:`, a title, and optional `description:`. Both keep real radio inputs (same name, required/disabled/error/help_text, aria, native arrow keys). The visible radio dot is hidden. Help and error copy under inline and cards sits further from the options (`mt-4`); the default list is unchanged.

### Changed
- Bumped the gem version to `0.1.212`.

### Upgrade notes
- Existing RadioGroup calls are unchanged. Pass `variant: :inline` or `variant: :cards` only when you want the visual layouts. String, `[label, value]`, and `{ label:, value:, disabled: }` options still work. Hash options may add `icon:` (kit IconComponent name) and `description:` (shown on `:cards`). Inline options follow Button secondary/primary tokens, so host button themes apply without extra CSS.
- An unknown `variant:` raises `ArgumentError`.
- Rebuild host Tailwind so the new pill/card utilities are generated. Redeploy so `meta.gem_version` shows `0.1.212`.

## [0.1.211] - 2026-10-08

### Added
- A collection editor row can join a library image. The identity cell is a thumbnail. An empty cell opens a library modal and stores the chosen image id on the row. Choosing an image that is already joined focuses that row. Caption and the other cells stay on the join. With `update_url`, the thumbnail edits the library record. `+ New` creates a library image, then joins it.
- `column_widths` sets one CSS grid track per content cell. Omit it and the first content column stays `minmax(0, 1.4fr)` and each later column stays `minmax(8rem, 1fr)`. The gallery demo sizes the image column with `max-content`.

### Changed
- Bumped the gem version to `0.1.211`.

### Upgrade notes
- Call `with_image` with `search_url` for the library and `thumbnail_url` for the current join. Include `:id` in `update_url` when the thumbnail should edit the library record. Search items accept `thumbnail_url`.
- Pass `column_widths` with one grid track per header when a content column should differ from the default. Omit it and the columns stay as they are. A bad track, or a list that does not match `headers`, raises `ArgumentError`.
- Reload kit CSS and JavaScript. Redeploy so `meta.gem_version` shows `0.1.211`.

## [0.1.210] - 2026-10-08

### Added
- `FlatPack::SectionTitle::Component` accepts `size:` (`:lg`, `:md`, `:sm`), `spacing:` (`:lg`, `:md`, `:sm`, `:none`), and `level:` (`:h1`–`:h6`). Defaults match today's look: `size: :lg` (`text-2xl` heading, `text-base` subtitle), `spacing: :lg` (`my-8`), `level: :h2`. Smaller sizes scale the subtitle and the copy-link icon.

### Changed
- Bumped the gem version to `0.1.210`.

### Fixed
- A blank `subtitle` (`""` or whitespace) no longer renders an empty `<p class="mt-1 …">`. Only a present subtitle gets a paragraph, so an empty optional field or blank translation does not add a gap.

### Upgrade notes
- Existing SectionTitle calls are unchanged. Pass `size:`, `spacing:`, and `level:` only when you want a smaller heading, tighter or no wrapper margin, or a different heading tag.
- Caller `class: "mb-2"` still cannot override the default `my-8`. Use `spacing: :none` when the caller should own the margin.
- Rebuild host Tailwind so `my-6`, `my-4`, and the smaller type sizes are generated. Redeploy so `meta.gem_version` shows `0.1.210`.

## [0.1.209] - 2026-10-08

### Changed
- Below 40rem a collection editor row drops the table lines. The drag handle, the name, and remove sit on one line. Relationship fields sit underneath, lined up with the name, and use a normal bordered control. Focus and an invalid value ring that control. The chip's own remove control hides, so the row remove is the only one. A row with no person keeps its first field on that top line. The same handle still drags the whole row. Wide screens keep the table.
- Bumped the gem version to `0.1.209`.

### Upgrade notes
- Reload kit CSS. Wide screens keep the table. Redeploy so `meta.gem_version` shows `0.1.209`.

## [0.1.208] - 2026-10-08

### Added
- The collection editor chip name edits the selected record when `update_url` includes an `:id` token. The name is a button whose hit target fills the chip, so a click on the pill opens edit. Remove stays its own button. Edit loads the record with GET and saves it with PATCH through the same modal used for create. The person id stays on the row. Other chips with that id update too. Join fields such as role stay on the row until the parent form is saved.

### Changed
- Bumped the gem version to `0.1.208`.

### Upgrade notes
- Pass `update_url: "/people/:id"` and keep the entity fields marked `data-create-field`. GET returns `{ "item": { "id", "title", "description" }, "fields": { "name": "Alice Chen" } }`. PATCH accepts those same fields and returns `{ "ok": true, "item": { "id", "title", "description" } }`.
- `edit_label` defaults to the kit string for Edit. `update_label` defaults to Save. The modal titles use `flatpack.collection_editor.new_record` and `flatpack.collection_editor.edit_record`.
- Omit `update_url` and the chip name stays plain text.
- Reload kit CSS and JavaScript.
- Redeploy so `meta.gem_version` shows `0.1.208`.

## [0.1.207] - 2026-10-08

### Added
- `--overlay-backdrop-color` (modal/drawer dim) and `--overlay-scrim-color` (on-media chrome such as carousel chevrons). Dark and ocean set these instead of the component tokens.

### Changed
- `--color-primary-hover` follows `--color-primary` with CSS relative colour syntax (`oklch(from var(--color-primary) calc(l - 0.1) c h)`). Browsers without that syntax keep the existing brand-knob fallback (`l - 0.10` on `--brand-*`). Setting `--brand-*` still recolors primary and hover. `--color-primary-text` stays `#fff` unless a theme overrides it.
- Secondary, ghost, chip-remove hover, and modal/carousel overlay paints derive from semantic surface/content/overlay tokens on `:root, [data-theme]`. `[data-theme="dark"]` no longer restates those component colours. It still sets `--color-primary-hover` (a lift, not `l - 0.10`), hairline shadows, inverted bottom-nav / top-nav / sidebar fills, and `--modal-backdrop-blur: 3px`.
- Bumped the gem version to `0.1.207`.

### Upgrade notes
- A named brand theme that sets an exact `--color-primary` no longer needs `--color-primary-hover` unless hover should diverge (for example dark themes that lighten on hover).
- A brand dark theme can set `color-scheme: dark` plus `--surface-*` and `--color-primary*` and inherit ghost/secondary/list/chip/switch colours. Optional: `--overlay-backdrop-color`, `--overlay-scrim-color`, `--shadow-*`, `--bottom-nav-*`, `--top-nav-background-color`, `--sidebar-background-color`.
- Component token names are unchanged. Reload kit CSS. Redeploy so `meta.gem_version` shows `0.1.207`.

## [0.1.206] - 2026-10-08

### Added
- Kit chrome copy lives under `flatpack.*`. The gem ships English only, in `config/locales/flatpack.en.yml`. Hosts add their own locale files (for example `config/locales/flatpack.fr.yml`) and own the language list.
- Components read omitted string props from I18n. An explicit prop, including `nil`, still wins.
- JavaScript copy uses `data-fp-copy` on `<html>` (`flat_pack_copy_data`) with English fallbacks in `flat_pack/copy.js`.
- The Rails 8 dummy app demonstrates locale switching with `recording_studio_internationalization`, a host `flatpack.fr.yml` that covers every gem English key, and a language selector in the catalog top nav (left of the theme control). Catalog full-page HTML cache keys include the current locale.

### Changed
- Bumped the gem version to `0.1.206`.

### Upgrade notes
- Put `<%= tag.attributes(data: flat_pack_copy_data) %>` (and `lang="<%= I18n.locale %>"`) on the host `<html>` tag so Stimulus copy follows the current locale.
- Pin `flat_pack/copy` if you rerun `rails generate flat_pack:install`.
- Do not expect a French (or other) locale file from the gem. Copy `config/locales/flatpack.en.yml` into the host app as `flatpack.<locale>.yml` and translate it. `RecordingStudio_Internationalization` is optional and stays a host dependency.
- Dummy-rails-7 does not use the internationalization gem.
- Redeploy so `meta.gem_version` shows `0.1.206`.

## [0.1.205] - 2026-10-08

### Added
- HTML carousel slides accept `thumb_src` or `thumb`. With `show_thumbs: true`, that URL is the thumbnail. A missing or rejected URL keeps the numbered placeholder.
- `FlatPack::Carousel::Component` accepts `show_border` and `show_background`. Both default to `true`. Pass `false` to drop the viewport border, the viewport fill, or both. `:logo_slider` stays borderless and transparent.
- Bumped the gem version to `0.1.205`.

### Upgrade notes
- No call-site changes are required. Image thumbs still prefer `thumb_src`, then `src`. Video thumbs still use `poster`.
- An HTML slide that already passed `thumb` or `thumb_src` will now show that picture. Those keys were ignored before.
- Existing carousels keep the viewport border and fill. Pass `show_border: false` or `show_background: false` to turn a piece off. `--carousel-viewport-border-color` and `--carousel-viewport-background-color` still paint the pieces that stay on.
- This is a Ruby render change. Reload the app so the new carousel code is loaded.
- Redeploy so `meta.gem_version` shows `0.1.205`.

## [0.1.204] - 2026-10-08

### Added
- `FlatPack::CollectionEditor::Component` edits an ordered collection of related records inside a Rails form. A row shows the selected record as an info chip and leaves relationship fields to the host. Add clones a `fields_for` template and replaces the child-index token in identifier attributes. Remove sets `_destroy` on a saved row and drops an unsaved row. The entity picker searches, selects, or creates a record and writes its id onto the join. Enter selects the highlighted result, or the only result. Several matches stay in the menu and do not create a record. No matches shows "+ New" when create is configured. A failed search stays in the picker. Moves are announced in a polite status.
- List orderable accepts `handle_selector`. Arrow keys on that handle move the row. A row with `data-orderable-unsaved="true"` does not PATCH. A saved row's `target_position` ignores unsaved rows. Rows marked `data-collection-editor-destroyed` stay out of the order.
- Collection editor tokens alias surface, list, and primary colors. See `docs/components/collection-editor.md`.
- Dummy `/demo/collection_editor` is a Project collaborators form. Person name and email stay on the person. Role and order stay on the join. Reorder posts `moving_recording_id` and `target_position` to `Ordering::ReorderService`. A second section, Text fields, shows three single-line text inputs per row with `chrome: :cell` and no person picker or dropdown.
- Bumped the gem version to `0.1.204`.

### Changed
- The collection editor heading sits outside the bordered list. The list frame is `.flat-pack-collection-editor-card`.
- Collection editor rows are a grid of cells. Each `with_field` block is its own column. Text input, Select, and the other controls that share `FormField::ControlStyles` accept `chrome: :cell` and drop their own border, radius, and background. Focus and errors draw an inset ring on the cell. The person search uses the same cell treatment. Create fields stay bordered.
- Collection editor remove is a ghost button with a trash icon. It was a danger button with an X.
- A single-line collection editor cell is one line. Vertical field padding no longer stacks on the 44px remove control, so the value lines up with the trash icon.
- The collection editor add control is a full-width ghost row at the bottom of the table. The default label is `Row`, and the plus icon stays, so it reads "+ Row".
- Select's field wrapper includes `flat-pack-input-wrapper` as well as `flat-pack-select-wrapper`, so a role select fills its collection editor cell.
- A selected collection editor record is an info chip showing the name. The chip remove control drops the row. Search results open in a menu. "+ New" is at the bottom of that menu when the query has no matches, and it opens the create form in a modal. The search cell stays one line. Cancel, Escape, and the backdrop leave the row unselected. Validation errors stay in the modal.

### Fixed
- `FlatPack::Chip::Component` renders a custom `remove_button`. That control replaces the default remove button.
- A modal click on the dimmed area reaches the backdrop. The dialog wrapper no longer sits on top of that click.

### Upgrade notes
- The collection editor border, background, and padding now live on `.flat-pack-collection-editor-card`. The heading is outside that card. The add control is the last row inside it. Host CSS that painted the border on `.flat-pack-collection-editor` should move to the card class. `add_label` defaults to `Row`. Select's wrapper now includes `flat-pack-input-wrapper` alongside `flat-pack-select-wrapper`. The entity summary is an info chip. `edit_url_template`, `edit_label`, and `change_label` are accepted and no longer rendered. Create starts from "+ New" in the search menu and opens a modal titled `New {label}`. `create_label` is that modal's submit button. Host CSS that targeted `.flat-pack-collection-editor-create-fields` inside the cell should target the modal body.
- Card padding and the gap between cells are gone. Cells draw the lines with `--collection-editor-border-color`. `--collection-editor-row-padding` pads the empty state. Pass one header per content cell (the entity, then each field). The section sets `--collection-editor-columns` from that count. It is not a theme token. `chrome:` defaults to `:field`, so a normal form keeps its bordered controls. Pass `chrome: :cell` on a control inside a collection editor cell. Host CSS that targeted a single `.flat-pack-collection-editor-fields` wrapper should expect one cell per field. Inside the editor, those controls keep horizontal `--form-control-padding` and use no vertical padding. A row of single-line fields is the height of the remove button.
- `orderable:` on List still drags the whole row when `handle_selector` is omitted.
- Importmap apps load `collection_editor_controller.js` from the existing controllers pin.
- Bundled apps that copy the esbuild list in `docs/installation.md` add `CollectionEditorController` and `application.register("flat-pack--collection-editor", CollectionEditorController)`.
- New nested child indexes must be integers. Rails 8 `permit` drops any other nested-attribute key. The template placeholder `NEW_RECORD` is replaced in `name`, `id`, `for`, `data-id`, `data-results-id`, `data-create-modal-id`, and the aria attributes that point at those ids. Text in the row is left as written.
- FlatPack does not store order. A host that already uses Recording Studio Orderable keeps that API. Pass its URL and parameter names to the collection editor.
- Reload kit CSS and JavaScript. Modal backdrop clicks pass through the dialog wrapper.
- Redeploy so `meta.gem_version` shows `0.1.204`.

## [0.1.203] - 2026-10-07

### Changed
- Focus rings (`--color-ring`) and active sidebar / top-nav fills now follow `--color-primary`. Matching text and icons stay on `--color-primary-text`.
- Default palette wiring is declared on `:root, [data-theme]` so a named theme on `<body>` (or another descendant) re-resolves derived tokens.
- Dark and ocean no longer freeze `--color-ring`; they follow `--color-primary` (same colour they already set).
- The bottom nav bar stays a surface (`#2f2f2f` by default), not a brand fill.
- Bumped the gem version to `0.1.203`.

### Upgrade notes
- Reload kit CSS.
- Hosts that overrode `--color-ring`, `--sidebar-item-active-background-color`, or `--top-nav-item-active-background-color` to match charcoal can drop those overrides. Keep them only if those chrome pieces should stay independent of primary.
- `data-theme` on `<body>` now re-resolves component aliases. Prefer `<html>` when you can; either placement works.
- Dark and ocean ring / active nav colours now track `--color-primary`. Override those tokens only if they should diverge.
- Redeploy so `meta.gem_version` shows `0.1.203`.

## [0.1.202] - 2026-10-07

### Changed
- `FlatPack::SegmentedButtons::Component` accepts `style:` and defaults to `:primary`. The selected button uses that Button style. Unselected buttons stay `:secondary`.
- Unknown style names raise the same `ArgumentError` as `Button`. Passing `style:` on a segment raises `ArgumentError`.
- Bumped the gem version to `0.1.202`.

### Upgrade notes
- `style:` defaults to `:primary`. Unselected segments stay `:secondary`.
- Reload is not required for the Ruby API.
- A host that toggles selection in JavaScript must set `data-fp-style`, not swap colour classes.

## [0.1.201] - 2026-10-07

### Changed
- `style:` on pill tabs, stacked tabs, and `Button::Pill` defaults to `:primary`. Omitted calls stay on the pill tokens.
- Active pill colour for other built-in styles comes from the button slots.
- Bumped the gem version to `0.1.201`.

### Upgrade notes
- Hosts that set `--fp-button-*` only on `.fp-button[data-fp-style="name"]` should use `[data-fp-style="name"]` if that colourway should also paint pills. Built-in styles need no host CSS change.
- `style:` on Tabs is no longer an HTML style attribute. Pass a button style name. A CSS string in that keyword raises `ArgumentError`.
- Host overrides of `--tabs-pill-active-*` still win for the default primary pills.
- Reload kit CSS.

## [0.1.200] - 2026-10-07

### Added
- A form can show unsaved changes on its save button. Add `flat-pack--unsaved-changes` to the form and mark each save button with the `submit` target. The button keeps `data-fp-style="default"` while the fields match the saved baseline, and switches to `data-fp-style="primary"` when they differ. Restoring every field, or resetting the form, returns the button to default.
- TipTap writes its hidden field and then dispatches `input` after the editor is ready. A combobox choice dispatches `change` on the hidden field. Form listeners can see those edits.
- Bumped the gem version to `0.1.200`.

### Upgrade notes
- Importmap apps load `unsaved_changes_controller.js` from the existing controllers pin. No new register call.
- Bundled apps that copy the esbuild list in `docs/installation.md` add `UnsavedChangesController` and `application.register("flat-pack--unsaved-changes", UnsavedChangesController)`.
- No existing button changes on its own. A form opts in by adding the controller.
- Forms that already use `flat-pack--auto-submit` now submit when a rich text field changes or a combobox choice is made. They did not before.

## [0.1.199] - 2026-10-07

### Changed
- Orderable list drag now presses the row (`scale: 0.98`), lifts it with `--shadow-lg` (`scale: 1.02`), and shows a visible landing slot filled with `--list-item-hover-background-color`. Sibling text eases to `--surface-muted-content-color`. Drop settle clears drag styles on `transitionend`.
- Bumped the gem version to `0.1.199`.

### Upgrade notes
- No host call-site changes. `orderable:` still pointer-drags and saves the same payload.
- Reload kit CSS and JavaScript so the landing slot, press, and lift apply. The placeholder is no longer `visibility: hidden`.
- Under `prefers-reduced-motion: reduce`, the slot stays and the lift scale does not run.
- Redeploy so `meta.gem_version` shows `0.1.199`.

## [0.1.198] - 2026-10-02

### Changed
- Orderable list drag no longer paints a radial spotlight / circle-of-light under the pointer. Soft elevation shadow, pointer drag, FLIP springs, and reduced-motion settle are unchanged. Removed `--fp-list-drag-x` / `--fp-list-drag-y`.
- Bumped the gem version to `0.1.198`.

### Upgrade notes
- No host call-site changes. Rebuild host CSS (or reload kit CSS) so the spotlight `::after` rule is gone.
- Redeploy so `meta.gem_version` shows `0.1.198`.

## [0.1.197] - 2026-10-02

### Added
- List orderable spring tokens `--easing-spring` and `--easing-spring-snappy` for list/layout reorder only. Overlay enter/exit stay bounce-free.
- Orderable list drag chrome: soft elevation shadow and radial spotlight via `--fp-list-drag-x` / `--fp-list-drag-y`.

### Changed
- List `orderable:` uses pointer-driven reorder with FLIP sibling springs and a snappy drop settle instead of HTML5 drag-and-drop (`opacity-70` ghost + primary ring). Ruby API, save payload, and `list:reordered` / `list:saved` / `list:error` detail shapes are unchanged.
- Orderable lists add `.flat-pack-list--orderable`. Under `prefers-reduced-motion: reduce`, drag still works and DOM order still updates; springs snap.
- List spacing uses `flex flex-col` + `gap-3` / `gap-1` instead of `space-y-*`, so rows keep `margin-bottom: 0` (no Tailwind `margin-block-end` from `space-y`). Orderable + divided lists omit gap so the divider spacing stays even.
- `List::Item` vertical padding is `py-4` (was `py-3`).
- Bumped the gem version to `0.1.197`.

### Upgrade notes
- No host call-site changes. Keep passing `orderable:` / `orderable_url:` / method / param names as before.
- List roots now use `flex flex-col gap-*` instead of `space-y-*`. Rebuild host Tailwind so `gap-1` / `gap-3` / `py-4` utilities exist if you rely on class scanning.
- `List::Item` rows are taller (`py-4`). Chat inbox rows that inherit `List::Item` pick this up too.
- Rebuild host Tailwind (or reload kit CSS) so spring tokens and orderable drag classes apply. Do not use `--easing-spring*` on overlays.
- Redeploy so `meta.gem_version` shows `0.1.197`.

## [0.1.196] - 2026-09-23

### Added
- Bare `size:` (`:sm` / `:md` / `:lg`, default `:md`) on Checkbox, RadioGroup, SegmentedButtons, Button::Pill, Tabs, Skeleton, EmptyState, Toast, Alert, and Accordion. Invalid sizes raise `ArgumentError`.
- Checkbox and RadioGroup share `FlatPack::Shared::ControlSize` (`--checkbox-size`: sm `1rem`, md `1.25rem`, lg `1.5rem`). Button::Pill and Tabs share `FlatPack::Shared::PadTextSizes` (Button padding/text tokens).
- SegmentedButtons group `size:` forwards into each `button(...)` unless that call already passes `size:`.
- Dummy demos show sm/md/lg for every component that gained `size:`.

### Changed
- RadioGroup default (`:md`) uses the Checkbox size map (`1.25rem`) instead of hardcoded `h-4 w-4` (`1rem`), so radios grow at the default size.
- Bumped the gem version to `0.1.196`.

### Upgrade notes
- No host call-site changes required. Defaults preserve prior appearance except RadioGroup `:md`, which is intentionally larger (matches Checkbox).
- Pass `size: :sm` on RadioGroup to keep the previous `1rem` control size.
- Rebuild host Tailwind (or reload kit CSS) if new arbitrary-value class strings need generation. Redeploy so `meta.gem_version` shows `0.1.196`.

## [0.1.195] - 2026-09-22

### Fixed
- Top nav side padding stays at least `1rem`. `.fp-top-nav` is unlayered, so host Tailwind preflight (`* { padding: 0 }` in `@layer base`) no longer wipes it when Flatpack CSS is linked first.

### Changed
- Bumped the gem version to `0.1.195`.

### Upgrade notes
- No host markup change. The bar inset is `max(1rem, env(safe-area-inset-*))` on each side.
- Do not move `.fp-top-nav` back into `@layer components`. Redeploy so `meta.gem_version` shows `0.1.195`.

## [0.1.194] - 2026-09-22

### Fixed
- Checkbox, RadioGroup, and Picker list checkboxes use theme CSS vars for checked paint (`accent-[var(--color-primary)]`, `checked:bg-[var(--color-primary)]`, `checked:border-[var(--color-primary)]`, `checked:text-[var(--color-primary-text)]`) instead of bare Tailwind `*-primary` utilities that stayed blue across themes.

### Changed
- Bumped the gem version to `0.1.194`.

### Upgrade notes
- Rebuild host Tailwind (or reload kit CSS) so the new arbitrary-value classes are generated. `stylesheet_link_tag` hosts that already ship FlatPack CSS pick the class strings up on reload after the gem upgrade.
- Checked checkboxes and radios follow `--color-primary` / `--color-primary-text` per theme. Do not rely on Tailwind's default `primary` palette for these controls.
- Redeploy so `meta.gem_version` shows `0.1.194`.

## [0.1.193] - 2026-09-22

### Fixed
- List `divider: true` draws a straight 1px rule. The row's `--radius-sm` no longer bends the ends on the rounded theme.

### Changed
- Bumped the gem version to `0.1.193`.

### Upgrade notes
- Divided lists no longer use `divide-y`. The separator is `.flat-pack-list-divided > li + li::before`, with `border-radius: 0`.
- Do not put the row radius on that rule. Redeploy so `meta.gem_version` shows `0.1.193`.

## [0.1.192] - 2026-09-22

### Changed
- The default rounded sidebar matches the page. `--sidebar-background-color` is `var(--surface-page-background-color)` (`#f8f9fa`). The header follows that token. Dark and ocean keep their own sidebar fills.
- Bumped the gem version to `0.1.192`.

### Upgrade notes
- Hosts that want the previous white rail set `--sidebar-background-color: oklch(1 0 0)` after FlatPack CSS. Do not put that assignment on `[data-theme="rounded"]`. That block stays empty.
- Dark and ocean sidebar colors are unchanged.
- Redeploy so `meta.gem_version` shows `0.1.192`.

## [0.1.191] - 2026-09-18

### Changed
- Desktop sidebar collapse and expand is one motion: rail width eases on `--duration-slow` while labels fade on `--duration-fast`. Labels stay in layout until the width transition ends, then the existing icon-only rest state applies (hamburger, hidden brand mark, compact-centered icons).
- Sidebar scroll stays put across refresh and Turbo visits. The current item is no longer pinned to the top of the rail. If it is off-screen, the list nudges just enough to show it.
- Bumped the gem version to `0.1.191`.

### Fixed
- Clicking a sidebar item marks it current immediately (active paint and `aria-current`) instead of waiting for the next page render.
- Long-menu scroll is restored after sidebar groups apply their open state, so Turbo visits no longer snap a scrolled rail back to the top.
- Collapsed rest state no longer `sr-only`s section titles, so title space stays in flow and item/icon row height does not jump.
- Closing the sidebar no longer restyles icons when the width transition ends. Labels shrink on `--duration-slow`, and the collapsed row centers its icon with equal padding, so the rail does not shudder into a second pose.
- The header collapse control hover fill wraps the chevron. Collapsed active items use the same padding on both sides of the icon.
- Collapsed icon tooltips open from `data-flat-pack-sidebar-collapsed`, so they still appear after labels stopped using `sr-only`.

### Upgrade notes
- No host markup change. Upgrade the gem so `meta.gem_version` shows `0.1.191`.
- Closed rest state is still hamburger + 4rem icon rail. Do not hide the menu icon behind the brand mark.
- Live collapse is CSS on `data-flat-pack-sidebar-collapsed`. Do not `sr-only` labels or add a `justify-center` class from JavaScript at click time or when the width transition ends. Collapsed centering is the stylesheet.
- Do not scroll the current sidebar item to the top on load. Restore the last rail position; only move if that item is out of view.
- Restore sidebar scroll after groups have applied open state. Do not `sr-only` section titles in the collapsed state; fade them and leave the block in flow.
- Do not restyle sidebar icons when the width transition ends. Do not center them with a percentage `margin-left` (it computes to 0 on a flex item) or with `justify-content` (the icon overshoots while the label is still wide). Use a fixed leading margin. Collapsed padding and gap need `!important` so they beat Tailwind utilities.
- Collapsed-only tooltips inside a live rail follow `data-flat-pack-sidebar-collapsed`. Do not require `sr-only` on the label. Static `collapsed: true` items still tip from `sr-only`.
- Clicking a sidebar item should mark it current in the kit. Dummy chrome also clears previous items on `turbo:load`.
- Static demos can still pass `collapsed: true` on Item / Section Title / Group for a server-rendered icon-only snapshot.
- `prefers-reduced-motion: reduce` snaps width and opacity (duration tokens are `0ms`).

## [0.1.190] - 2026-09-18

### Added
- `FlatPack::Sidebar::Header::Component` accepts `logo:` (URL string, default `nil`). A present URL renders a square mark in the existing `w-8 h-8` badge via `Avatar` size `:sm` and omits `brand_abbr`. Title, collapse toggles, and `show_version` stay. Blank, `nil`, or an unsafe URL keeps the initials path. The default `content` block still replaces the whole header row.

### Changed
- Bumped the gem version to `0.1.190`.

### Upgrade notes
- Omit `logo:` to keep the initials badge.
- Product hosts pass a square image URL, for example `logo: url_for(site.logo)`, and keep `brand_abbr:` as the fallback. Header shows the mark, not both.
- Do not put a wide wordmark in `logo:`. The slot stays 32×32.
- Do not use the Header `content` block for a mark. That block still wipes title, toggles, and version.
- Redeploy so `meta.gem_version` shows `0.1.190`.

## [0.1.189] - 2026-09-17

### Added
- Hosts and gems can register extra button styles with `FlatPack::Button.register_style(:name, press: :raised)` or `press: :flat`. The button sets `data-fp-style` and paints through local `--fp-button-*` tokens. Built-in styles still map those tokens from `--button-primary-*` and the other scheme tokens, so themes and hero overlays keep working. Vendor colours stay in host or gem CSS. Dummy `/demo/buttons` shows a `:partner` colourway that does not change `--color-primary`.

### Changed
- Bumped the gem version to `0.1.189`.
- Button colour and raised shadows live in kit CSS on `.fp-button` / `.fp-button-raised`, not per-style Tailwind background and shadow classes. `FlatPack::Button::Component::SCHEMES` is now the built-in style list (name → press), not a Tailwind class map. Dropdown triggers use the same paint surface.

### Upgrade notes
- Built-in `style:` values are unchanged. Recolouring one billing or partner button is a registered style plus host CSS, not a theme token change.
- Do not add `:stripe` (or any vendor name) by patching FlatPack. Register the name in the host or billing gem and set `--fp-button-background`, `--fp-button-hover-background`, `--fp-button-text`, and `--fp-button-border` on `.fp-button[data-fp-style="…"]` after `flat_pack/application`.
- Markup no longer includes `bg-[var(--button-primary-background-color)]` and the other scheme class strings. Selectors should use `.fp-button[data-fp-style="primary"]` or the `--button-primary-*` tokens. `--button-primary-*` still drive built-in primary paint.
- `SCHEMES` values are now `:raised` or `:flat`. Do not read them as CSS class strings.
- Redeploy so `meta.gem_version` shows `0.1.189`.

## [0.1.188] - 2026-09-17

### Added
- `FlatPack::Sidebar::Header::Component` accepts `show_version:` (Boolean, default `true`). `true` renders `v{FlatPack::VERSION}` beside the title. `false` omits the badge span.

### Changed
- Bumped the gem version to `0.1.188`.

### Upgrade notes
- Omit `show_version:` or pass `true` to keep the kit version badge.
- Product hosts pass `false`. The span is not rendered.
- Redeploy so `meta.gem_version` shows `0.1.188`.

## [0.1.187] - 2026-09-17

### Fixed
- `[data-theme="rounded"]` stays an empty alias of `:root`. Tests reject `--token: var(--token)` in named theme blocks. A self-map on `html[data-theme="rounded"]` blanks the token because that element is `:root`. Sidebar `border-r` then falls back to `currentColor` (hard black).

### Changed
- Bumped the gem version to `0.1.187`.

### Upgrade notes
- No API change. If host CSS still assigns `--sidebar-border-color: var(--sidebar-border-color)` (or any `--token: var(--token)`) under `[data-theme="rounded"]`, delete those lines. `@theme inline` self-maps are Tailwind inventory only. Do not copy them onto a theme selector. Redeploy so `meta.gem_version` shows `0.1.187`.

## [0.1.186] - 2026-09-17

### Added
- `--hero-headline-size` (default `--text-5xl`) so a theme can make the hero larger than product `5xl` without adding `--text-6xl` or `--text-7xl`.
- `--hero-description-size` (default `--text-xl`) for page-surface hero body. Overlay body on `:centered_image` stays `--text-2xl`.
- `--hero-overlay-min-height` (default `560px`) and `--hero-overlay-copy-padding-top` on `.fp-hero-overlay`. Landing pages set `--hero-overlay-min-height: 100dvh` instead of wrapping the section.
- `--top-nav-backdrop-blur` (default `16px`) and `--top-nav-height` (`72px`). TopNav frosts after the page has scrolled.

### Changed
- Bumped the gem version to `0.1.186`.
- `:centered_image` copy sits high in the frame (`items-start`) below a typical sticky TopNav. It is no longer vertically centered on the photo.
- Hero headlines use `--hero-headline-size` at the `sm:` step. Page-surface descriptions drop the hardcoded `text-lg` class.
- TopNav no longer always applies `backdrop-blur-lg`. At rest the blur is 0. The `flat-pack--top-nav` controller always attaches, including when `mobile_menu: false`, and listens to the window plus the nearest overflow pane.

### Upgrade notes
- Overlay heroes place copy below the TopNav. Hosts that relied on dead-center copy on `:centered_image` will see it sit higher.
- Page-surface hero body is `--text-xl` (`--hero-description-size`). `--text-lg` itself is unchanged.
- Fill the first viewport with `style: "--hero-overlay-min-height: 100dvh"` on the hero. Do not wrap the section, and do not pass a competing `min-h-*` utility. Catalog embeds keep `560px`.
- TopNav frost is scroll-gated. Hosts do not attach a window scroll listener. `--top-nav-background-color` is still the fill; there is no second TopNav variant. Redeploy so `meta.gem_version` shows `0.1.186`.

## [0.1.185] - 2026-09-16

### Added
- `FlatPack::Content::Component` renders a `div.fp-content`. Bare `p`, `h1`–`h6`, lists, quotes, links, and images take the kit reading scale (kicker and body `--text-lg` / 18px, lead `--text-2xl`, title `--text-5xl`, then `--text-3xl` down to `--text-lg`). Optional `.fp-content-kicker` and `.fp-content-lead` force those roles. Dummy `/demo/text/content` wraps the article and documents the API.

### Changed
- Bumped the gem version to `0.1.185`.

### Upgrade notes
- Wrap CMS or article HTML in `render FlatPack::Content::Component.new do |content| ... end`. Leave the tags bare. Body is `--text-lg` (18px). Do not add per-element size classes. Redeploy so `meta.gem_version` shows `0.1.185`.

## [0.1.184] - 2026-09-15

### Added
- `FlatPack::Hero::Component` accepts `align: :left` or `:center` (default `:center`). On `:centered_image`, `:left` docks tagline, headline, body, and CTAs to the start of the photo and keeps them vertically centered. `:centered` and `:screenshot` follow the same copy alignment. Split and column variants ignore `align`. Invalid values raise `ArgumentError`.
- `FlatPack::Hero::Component` accepts `on: :dark` or `:light` (default `:dark`) on `:centered_image`. `:dark` is light type on a dark wash. `:light` is dark type on a light wash. Invalid values raise `ArgumentError`.
- Overlay tokens `--hero-overlay-left-background`, `--hero-overlay-button-*`, and `--hero-overlay-on-light-*`. `:centered_image` paints `.fp-hero-overlay` so primary and secondary buttons invert on the photo. `on: :light` remaps those tokens to the on-light set.

### Changed
- Bumped the gem version to `0.1.184`.
- `:centered_image` tagline uses `--hero-overlay-muted-text-color` instead of page muted gray.
- `:left` on `:centered_image` uses a larger start inset (`lg:ps-16` plus safe-area) and a left-to-clear wash. Overlay copy padding is `py-16`.
- Dummy full-page `:centered_image` demos pass `class: "h-svh"`. The component default stays `min-h-[560px]` so catalog embeds do not grow with the viewport.
- Overlay `:centered_image` headline uses `leading-tight`. Overlay body uses `text-2xl`. Left overlay headline uses `fp-text-pretty` so the body shares the copy-column rag. Center overlay headline keeps `fp-text-balance`. Page-surface variants keep `text-lg` body.

### Upgrade notes
- New optional `align:` on `FlatPack::Hero::Component`. Omit it or pass `:center` to keep centered copy. Pass `align: :left` on `:centered`, `:centered_image`, or `:screenshot` for left-docked copy. `:right` is not valid. Split layouts do not change.
- New optional `on:` on `:centered_image`. Omit it or pass `:dark` for light type on a dark wash. Pass `on: :light` for dark type on a light wash. For one photo that is neither, set `--hero-overlay-*` on that section (`style:` or a wrapper class). `style` merges with `background:`.
- `:centered_image` overlay copy and CTAs now follow overlay tokens. Tagline is light, not page `--surface-muted-content-color`. Primary buttons on that variant render light-on-dark. Overlay headline leading is tight. Overlay body is `text-2xl`. Hosts that already passed inverted button styles or overlay type classes should drop those overrides. Landing pages that want a viewport-tall still pass `class: "h-svh"`. Redeploy so `meta.gem_version` shows `0.1.184`.

## [0.1.183] - 2026-09-15

### Changed
- Bumped the gem version to `0.1.183`.

### Fixed
- `FlatPack::TextArea` rich text uses the same `form_control_border_classes` and `form_control_padding_classes` as the plain textarea (`border` width plus `--surface-border-color` / `--color-error`, and `--form-control-padding`). Host Tailwind preflight no longer leaves the TipTap surface borderless or flush next to a normal field.

### Upgrade notes
- No API change. Upgrade the gem so `meta.gem_version` shows `0.1.183`. Rich-text `TextArea` (including `:minimal`) picks up the shared field border automatically. Comment composers that strip editor chrome with `.flat-pack-comments-composer-input` / `--bubble-only` still win.

## [0.1.182] - 2026-09-14

### Fixed
- Dummy `ApplicationController` skips Recording Studio root resolution on public catalog requests. Anonymous `/` and `/demo` no longer query `Workspace` and no longer 500 when Postgres is down.

### Changed
- Bumped the gem version to `0.1.182`.

### Upgrade notes
- If a host includes `RecordingStudio::RootSwitchable::ControllerSupport` on the same controller as the public catalog, call `skip_recording_studio_root_resolution if: :public_catalog_request?` or the host's equivalent predicate. The dummy already does this. Redeploy so `meta.gem_version` shows `0.1.182`.

## [0.1.181] - 2026-09-11

### Added
- ComponentCatalog `show` includes `examples` (`[{erb:}, ...]`, possibly empty) copied from `erb` and `ruby` fences in the first `## Example` section of the component doc. Each fence is indexed under every `FlatPack::…` class named in its body.

### Changed
- Bumped the gem version to `0.1.181`.

### Upgrade notes
- `show` always includes `examples`. An empty array means the doc has no `## Example` fence that names that class. Host helpers in copied ERB stay as written. `list` rows do not include `examples`. Redeploy / reconnect so `meta.gem_version` shows `0.1.181`.

## [0.1.180] - 2026-09-11

### Added
- ComponentCatalog `show` parameters include `default` when `initialize` has a JSON-safe literal kwarg (`nil`, bool, string, number, symbol as string). The key is omitted when the default is unknown (required, keyrest, constant, call, unreadable source).

### Changed
- Bumped the gem version to `0.1.180`.

### Upgrade notes
- `show` parameters may include `default` when that kwarg default is a known JSON-safe literal. Treat a missing `default` key as unknown, not as `nil`. An explicit `default: null` means the source wrote `kwarg: nil`. Clients that assumed a fixed parameter key list should treat `default` as optional. Redeploy / reconnect so `meta.gem_version` shows `0.1.180`.

## [0.1.179] - 2026-09-10

### Changed
- Bumped the gem version to `0.1.179` so live hosts (ChatGPT catalog `meta.gem_version`) can confirm the slots tip. Catalog `show` slots auto-discovery shipped in `0.1.178`; this bump is the deploy signal only.

### Upgrade notes
- Redeploy / reconnect against a host on `0.1.179` to see `meta.gem_version` update. Slot payloads are unchanged from `0.1.178`.

## [0.1.178] - 2026-09-09

### Added
- ComponentCatalog `show` includes ViewComponent slots (`renders_one` / `renders_many`) with public ERB names (`body_slot` → `body`).
- Catalog list meta: `gem_version` + publicity excludes; richer enums.
- Dummy MCP: pin `recording_studio_mcp` v0.3.1; FlatPack compose workflow in OpenAPI / `instructions_suffix`.

### Changed
- Bumped the gem version to `0.1.178`.

### Upgrade notes
- Call `FlatPack::ComponentCatalog.list` and `.show(name)` from a host initializer. `show` includes `slots` (`[{name:, collection:}, ...]` or `[]`). The gem does not mount HTTP routes.

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
