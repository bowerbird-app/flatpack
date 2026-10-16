# FlatPack Component Params

Use these names whenever a component exposes a shared concept. Prefer an existing name over inventing a synonym.

## Shared names

| Concept | Param | Use for |
| --- | --- | --- |
| Color / semantic appearance | `style` | `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`, and other visual schemes |
| Card colour fill | `style` | Card and Card Stat. `:default`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`. Not a raw colour. Card `shadow`, `border`, and `hover` are separate. |
| Literal CSS colour | `color` | ColorSwatch fill and RadioGroup `variant: :swatches` option fill. Not semantic `style`. |
| Structural / layout shape | `variant` | Layout or composition choices such as `:underline` vs `:pills`, `:centered` vs `:split` |
| Navigation destination | `href` | User-facing links the visitor clicks to go somewhere |
| Turbo Frame source | `src` | Navigable Modal (and later Drawer) lazy-load URL. Not a clickable `href`. |
| Data / form endpoint | `*_url` | Search, upload, reorder, form submit, and other non-navigation URLs |
| Compact visible copy | `text` | Primary string on buttons, badges, chips, nav items, quotes, and toasts. Exception: `FlatPack::CopyButton::Component` `text` is the clipboard string. The visible label is `label`. |
| Form or accessible name | `label` | Field labels and dedicated accessible names that are not the primary visual copy. Video preview's play button requires `label:` (for example `"Play: Launch trailer"`). The host translates it. |
| Section heading | `title` | Headings on pages, modals, cards, empty states, and sidebar groups |
| Beside a heading | `trailing` | Section Title slot (`with_trailing`). After the heading element, before the copy-link icon. Outside both, so the accessible name stays `title`. Generic content. Not a count param. |
| Supporting copy | `description` or `subtitle` | `description` for body explainer text; `subtitle` for a heading companion |
| Floating layer anchor | `placement` | Tooltips, popovers, dropdowns, and notification menus. Typical values are `:top`, `:bottom`, `:left`, `:right`. Menu components that already list corner values keep those. |
| Content on media | `placement` | `FlatPack::Overlay::Item` `with_item`. Media and Video preview pass the same argument through. Nine-cell grid: `:top_left`, `:top_center`, `:top_right`, `:middle_left`, `:center`, `:middle_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`. Default `:top_left`. Not FAB `position`, and not the floating-layer anchor above. |
| Gap from the media edge | `inset` | `FlatPack::Overlay::Item` `with_item`. Media and Video preview pass the same argument through. `:sm`, `:md`, `:lg` read `--overlay-inset-sm` (`0.5rem`), `--overlay-inset-md` (`1rem`), and `--overlay-inset-lg` (`1.5rem`). Default `:md`. `:center` ignores it. Edge-centers use it on the edge axis only. |
| Image description | `alt` | Media, required String (`""` when the image is decorative). Avatar uses `alt` too. |
| Image box | `width` / `height` | Media only. Positive integers. They set the `img` attributes and `aspect-ratio`. Not Card media or Video preview `aspect_ratio`. Not EmptyState `width`. |
| Empty state measure | `width` | `FlatPack::EmptyState::Component` only. `:sm`, `:md`, `:lg`, or `:full`. Caps the text block (and a `media` image) with `--empty-state-measure-*`. The root still fills its container. `:full` is `max-width: none`. |
| Table column track | `width` | `FlatPack::Table::Column` only. `:fit` (shrink to content), `:fill` (remaining space), or a CSS length such as `"12rem"`. A length uses `table-layout: fixed` unless a sibling is `:fit`. The length stays a `max-width` cap on the header and cells. |
| Table column floor and cap | `min_width` / `max_width` | On a column, CSS lengths such as `"8rem"`. Table `min_width:` stays the scroll floor (`:none`, `:sm`, `:md`, `:lg`, or a `min-w-*` class). |
| Table column wrapping | `wrap` | `FlatPack::Table::Column` only. `:wrap` (default), `:nowrap`, `:truncate`. Truncated cells expose the full text in `title`. |
| Table column visibility | `hide_below` | `FlatPack::Table::Column` only. `:sm`, `:md`, `:lg`, `:xl`. Hides that header and its cells below the breakpoint. The column stays in `colspan`. |
| Table frame | `style` | `FlatPack::Table::Component` `:default` (border, radius, row hover) and `:plain` (none of those). Same param as Button, Badge, and Card. |
| Table row lines | `dividers` | `FlatPack::Table::Component` only. `true` (default) draws the header rule and row lines. `false` removes them. Not List `divider`. |
| Media frame ratio | `aspect_ratio` | Card media, Carousel, and Video preview. `"16/9"`, `"4/3"`, `"1/1"`, or a custom ratio such as `"21/9"`. Video preview defaults to `"16/9"`. |
| Overlay enter origin | `origin` | Modal (and later Drawer). `:center` is today’s fade and scale. `:trigger` grows from the control that opened it. |
| Content / cluster alignment | `align` | Hero overlay copy (`:left` / `:center`) and Email (`:left` / `:center` / `:right`). Email-compatible values. Button label alignment is `:center` (default) or `:start`. `:start` left-aligns the label and gives it `flex-1 min-w-0`. |
| Table column alignment | `align` | `FlatPack::Table::Column` only. `:start` (default), `:center`, `:end`. Logical, so RTL flips start and end. |
| Overlay copy on a photo | `on` | Hero `:centered_image`. `:dark` is light type on a dark wash. `:light` is dark type on a light wash. |
| Grid item alignment | `align` | Grid `items-*` presets: `:start`, `:center`, `:stretch`. Same param name as content `align`, different enum. |
| Masonry column count | `columns` | Masonry: integer 1–6 or a breakpoint hash (`base`, `sm`, `md`, `lg`, `xl`). Collage grid: one integer 1–6, the count at and above `stack_below`. Collage brick uses `rows` instead. Do not use Grid's `cols` here. |
| Masonry pack direction | `order` | Masonry only. `:columns` reads down each column. `:rows` keeps left-to-right source order. |
| FAB viewport corner | `position` | FAB only. `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. Not overlay `placement`. |
| FAB speed-dial arrangement | `layout` | FAB only. `:stack` in this release. `:arc` is reserved for a later PR. |
| List shape | `layout` | List only. `:items` (default, `<ul>` or `<ol>`) or `:key_value` (`<dl>`). Not FAB `layout`. Not Collection `layout`. |
| Collection arrangement | `layout` | `FlatPack::Collection::Component` only. `:stack` (default, vertical), `:grid` (auto-fill, equal height), or `:wrap` (inline flex-wrap for badges and chips). |
| Empty state actions | `layout` | `FlatPack::EmptyState::Component` only. `:wrap` (default, wrapping row) or `:stack` (one button under the next). The actions render as `FlatPack::Collection::Component` with that layout. Not `:grid`. |
| Collection element | `as` | `FlatPack::Collection::Component` only. `:list` (default, the `<ul>` alone) or `:nav` (wraps the list in `<nav aria-label>`). |
| Nav accessible name | `label` | Collection `as: :nav` requires `label:`. That string is the nav's `aria-label`. Not the visible button label (`text`). |
| Collection item floor | `min_item_width` | Collection `layout: :grid` only. A CSS length such as `"14rem"` (the default). Sets `--fp-collection-min-item-width`. Not Table `min_width`. |
| Collection gap | `gap` | Collection, Grid, and Masonry. `:sm`, `:md`, `:lg` (`gap-2`, `gap-4`, `gap-6`). |
| Button label lines | `lines` | `FlatPack::Button::Component` only. `1` (default) or `2`. Clamps the label with an ellipsis. |
| Button icon artwork | `icon_variant` | Heroicon weight on a button-family leading icon and on EmptyState `icon:`. `:outline`, `:solid`, `:mini`, `:micro`. Omit to use `default_icon_variant`. |
| Button icon colour | `icon_style` | `nil` inherits the button text through `currentColor`. `:primary`, `:success`, `:warning`, `:danger` use `--button-icon-*` tokens. |
| Current page control | `current` | `FlatPack::Button::Component` boolean. `true` paints the current look. On a link it also sets `aria-current="page"`. Not a billing plan hash key. |
| Clamped label tooltip | `title` | On Button, the full label for the HTML `title` tooltip when `lines` clamps the visible text. Elsewhere, `title` stays a section heading. |
| Key/value term | `key` | `FlatPack::List::Item` when the list `layout` is `:key_value`. The `<dt>` text. The block is the value. |
| Key column size | `key_width` | List `:key_value` only. `:fit` (widest key) or a CSS length such as `"10rem"`. |
| Stack key above value | `stack_below` | List `:key_value`: `:sm`, `:md`, or `:lg`. Below that breakpoint the key sits above the value. Collage: `:sm`, `:md`, `:lg`, or `:xl`. Below that breakpoint the items become one column and the tilt drops. |
| Collage brick | `rows` | `FlatPack::Collage::Component` only. A list of counts, such as `[5, 4]`. Each count is a row. A shorter row is centered, so it sits between the cards above. Omit it for an even grid of `columns`. |
| Collage scatter | `scatter` | `FlatPack::Collage::Component` only. `:subtle` (default), `:loose`, or `:none`. A deterministic tilt and offset from the item index. `:none` sits square. |
| Collage motion | `motion` | `FlatPack::Collage::Component` only. `true` (default) plays the enter rise and the hover lift. `false` leaves the scatter still. `prefers-reduced-motion` also skips both. |
| FAB speed-dial item look | `style` | FAB `with_action` only. Omit for today’s surface glyph. `:danger` uses `--button-danger-*` (same tokens as TrashButton). |
| Scale | `size` | `:sm`, `:md`, `:lg`, and other size tokens. PageTitle and Hero also accept `:display` for cover type. HeroTitle uses `:md`, `:lg`, `:xl`, `:xxl` (`:xl` is `--display-size`). |
| Hero cover step | `title_size` | Hero only. Opt-in `FlatPack::HeroTitle::Component` size (`:md`, `:lg`, `:xl`, `:xxl`) for the headline. Omit to keep today's default or `size: :display` mapping. Not EmptyState `title_size`. |
| Empty state heading | `title_size` | `FlatPack::EmptyState::Component` only. `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:xxl`, or `:display`. `:display` uses `.fp-display`. Omit and the heading follows `size` (`:sm` → `:base`, `:md` → `:lg`, `:lg` → `:xl`). |
| Empty state sentence | `description_size` | `FlatPack::EmptyState::Component` only. `:sm`, `:md`, `:lg`, or `:xl` (`--text-sm`, `--text-base`, `--text-lg`, `--text-xl`). Omit and it follows `size` with those names. Not `title_size` and not `:base`. |
| Empty state icon | `icon_size` | `FlatPack::EmptyState::Component` only. IconComponent `:sm`, `:md`, `:lg`, or `:xl`. Requires `icon`. Omit and `size` maps `:sm` → `:md`, `:md` → `:lg`, `:lg` → `:xl`. Not EmptyState `size`. |
| Empty state visual | `visual` | `FlatPack::EmptyState::Component` only. One slot above the title. A block is host markup and spans the empty state. An image uses `media` (`src`, `alt`, `width`, `height`) and is not a second slot. Either one replaces `icon:`. |
| Extra CSS | `class` | System argument. Do not add `class_name` |
| Action button copy | `*_label` | Confirm, close, submit, cancel, and reset strings |
| Empty-state copy | `empty_text` or `empty_title` / `empty_description` | Single-line empty copy vs title-plus-body empty states |
| List of records | `items` | Search catalogs, pickers, avatar groups, billing plan/invoice rows, and other collections already in the page |
| Open / closed start state | `open` | Whether a collapse, group, or layout starts expanded |
| Host-formatted money | `price_text` / `amount` | Display-only plan prices and invoice amounts; FlatPack does not format currency |
| Host-formatted date copy | `renews_on`, `trial_ends_on`, `expires_text` | Billing renewal, trial, and card expiry strings the host already formatted |
| Subscription / invoice state | `status` | Billing enums such as `:active`, `:past_due`, `:paid`; map to Badge/Alert `style` in the component |
| Sliding active marker | `indicator` | Tabs and Button::Pill. Omit for today’s instant swap. `:slide` moves one marker on `--duration-base`. |
| Inline edit flavour | `mode` | InlineEdit only. `:text` (single line), `:plain` (multi-line), `:rich` (bubble toolbar). |
| Inline edit rest cue | `cue` | InlineEdit only. `:highlight` (default Notion-style wash), `:tint` (same paint), `:underline`, `:none`. Not Badge/Button `style`. |
| RangeInput end glyphs | `start_icon` / `end_icon` | Kit icon names at the track ends. `variant: :size` / `:text_size` use theme-font `A` glyphs instead; `:zoom` defaults to magnifying-glass minus/plus. |
| RangeInput live preview | `preview_target` | CSS selector or element id. Stimulus writes `--fp-range-value` and `--fp-range-scale` on the target while dragging. |
| Clipboard source element | `target` | `FlatPack::CopyButton::Component` only. An element id or CSS selector whose value or text is copied. Not RangeInput `preview_target`. |
| RangeInput sample letters | `sample` | Text under a `:size` / `:text_size` slider. Default `"Aa"`. Pass `""` to hide. `with_preview` replaces it. |
| RangeInput step notches | `ticks` | Visible notches under the track, one per `step`. Size and zoom variants show ticks unless you pass `ticks: false`. |
| Lightbox gallery name | `group` | `FlatPack::Lightbox` and its triggers. A letter, then letters, numbers, hyphens, or underscores. Several triggers can name one group. |
| Lightbox start item | `index` | Zero-based item in that `group`. Triggers pass it. The gallery opens on the clicked item. |
| Lightbox item list | `items` | `FlatPack::Lightbox` only. Each hash has `src`, optional `alt` and `caption`, and `type` `:image` or `:video`. |
| Slide or item caption | `caption` | Carousel slides and lightbox items. Optional supporting copy under the media. |
| Lightbox count | `show_count` | `FlatPack::Lightbox` boolean. `true` shows `3 / 12` when there is more than one item. Maps to Carousel `show_counter`. |
| Lightbox thumbnails | `thumbs` | `FlatPack::Lightbox` boolean. Default `false`. `true` shows the carousel thumb strip when there is more than one item. Maps to Carousel `show_thumbs`. |
| Lightbox item thumbnail | `thumb_src` | Optional image URL on a lightbox item. Falls back to `src`. Carousel slides use the same key. |

## Billing namespace notes

Planned family docs live under `docs/components/billing*.md`. When implementing `FlatPack::Billing::*`:

- Prefer `items` for plan picker and invoice collections (do not invent `plans` or `invoices` as prop names).
- Prefer `href` for Change plan, Update card, and invoice Download/View navigation.
- Prefer `empty_title` / `empty_description` for payment-method and invoice empty states.
- Prefer `price_text` and `amount` as preformatted strings; do not add a `currency` formatter in FlatPack.
- Prefer `cta_text` for plan-picker button copy (action label pattern via `*_text` / `text`).
- Keep PCI out of FlatPack: never add props for full PAN, CVC, or Elements mount points.

## Do not mix

- Do not use `variant`, `type`, `theme`, or `scheme` for color. Use `style`. Card shadow, border width, and hover are `shadow`, `border`, and `hover`. Hero overlay contrast uses `on`, because `style` is the HTML attribute on the section.
- Do not use `url` for a clickable navigation destination. Use `href`.
- Do not use `label` for the visible string of a compact control. Use `text`. Copy Button is the exception: `text` is the clipboard string and `label` is the visible label.
- Do not use `position` for overlay placement. Use `placement`. FAB viewport corners stay `position`. Overlay, Media, and Video preview use the nine-cell grid on `with_item`, not the tooltip `:top` / `:bottom` / `:left` / `:right` set.
- Do not use `placement` for where a Modal grows from. Use `origin`.
- Keep `type` only for native HTML control types such as button `type: "submit"`. Carousel slides and lightbox items are the exception: `type` is `:image`, `:video`, or (carousel only) `:html`.
- Do not use `plans` or `invoices` as collection prop names when `items` already covers the concept.
- Do not pass Grid's `:start` or `:stretch` to Hero or Email `align`. Hero accepts `:left` and `:center`. Email also accepts `:right`. Table columns use `:start`, `:center`, and `:end`.
- Do not pass a Table column `width:` length to Media `width`, or a Media integer to a column. Column `min_width:` is a CSS length. Table `min_width:` is the scroll floor. Do not pass EmptyState `:sm` / `:md` / `:lg` / `:full` to Media or a Table column, or a Media integer to EmptyState `width`.
- Do not use `divider` on Table. The param is `dividers`.
- Do not add a per-column `class` or raw `style` string. Width, min width, max width, align, wrap, and `hide_below` are the column controls.
- Do not add a count or badge param to Section Title. Pass that content through `with_trailing`.
- Do not pass FAB `layout: :stack` to List or Collection, or List `layout: :key_value` to FAB or Collection. Collection `layout` is `:grid`, `:wrap`, or `:stack`. EmptyState `layout` is only `:wrap` or `:stack` for its action row. Do not pass Collection `:grid` or List `:key_value` to EmptyState.
- Do not pass Hero `title_size` (`:md`, `:lg`, `:xl`, `:xxl`) to EmptyState. EmptyState `title_size` is `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:xxl`, or `:display`. `:xxl` is `--text-2xl` there, not HeroTitle's largest step.
- Do not pass EmptyState `title_size` to `description_size`. `description_size` is `:sm`, `:md`, `:lg`, or `:xl`. `:md` is `--text-base`. `:base` is not a description step.
- Do not pass EmptyState `size` (`:sm`, `:md`, `:lg`) to `icon_size` and expect the same glyph. `icon_size` is the IconComponent scale. `size: :md` draws a `:lg` icon unless `icon_size` is set.
- Do not pass `graphic` to EmptyState, and do not pass `visual` and `media` together. Markup is `visual`. An image is `media`. `icon:` is the default when neither is set. A block replaces the icon.
- Do not pass Grid `:stretch` or Hero `:left` to Button `align`. Button accepts `:center` and `:start`.
- Do not pass Collection `min_item_width` to Table, or a Table column `min_width` to Collection.
- Do not add a colour `style` or an item class to Collection. Hosts style the items.
- Button `title` is the full-text tooltip. Do not use it as a heading. Button `label` is not the visible string; use `text`.
- Do not add `icon_class` on a button. Recolour the glyph with `icon_style` and the `--button-icon-*` tokens.
- Do not use `label` for a key/value term. Use `key`. The item block is the value.
