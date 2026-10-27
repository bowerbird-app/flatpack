# FlatPack Component Params

Use these names whenever a component exposes a shared concept. Prefer an existing name over inventing a synonym.

## Shared names

| Concept | Param | Use for |
| --- | --- | --- |
| Color / semantic appearance | `style` | `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`, and other visual schemes |
| Card colour fill | `background` | Card and Card Stat. `:default`, `:none`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`. Not a raw colour. `:none` is transparent and inherits text. Card `shadow`, `border`, and `hover` are separate. |
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
| Gap from the media edge | `inset` | `FlatPack::Overlay::Item` `with_item`. Media and Video preview pass the same argument through. `:sm`, `:md`, `:lg` read `--overlay-inset-sm`, `--overlay-inset-md`, and `--overlay-inset-lg`, which are `--overlay-edge-offset`, twice that, and three times that. Default `:md` (`16px` when the edge token is `8px`). `:center` ignores it. Edge-centers use it on the edge axis only. |
| Image description | `alt` | Media, required String (`""` when the image is decorative). Avatar uses `alt` too. |
| Image box | `width` / `height` | Media only. Positive integers. They set the `img` attributes and `aspect-ratio`. Not Card media or Video preview `aspect_ratio`. Not EmptyState `width`. Not Sidebar Layout `height`. |
| Corner | `radius` | Card and Media both use `radius`. Media stays omit or `:card_inner`, and Card uses `:default`, `:none`, `:sm`, `:md`, `:lg`, `:xl`, `:xxl`, or `:xxxl`. |
| Floating rail height | `height` | `FlatPack::SidebarLayout::Component` only. `:full` (default) or `:content`. Content height applies only while `floating: true`, and only from the `md` breakpoint up. Not the image `height` attribute. |
| Panel resize | `resizable` | `FlatPack::SidebarLayout::Component`, and the same argument on its `aside` slot. `true` or `false`. Default `false`. Desktop only. The rail uses the sidebar content min and max. The aside uses `--aside-min-width` and `--aside-max-width`. |
| Aside column | `aside` | `FlatPack::SidebarLayout::Component` slot, opposite `side:`. `open:` defaults to `true`. `resizable:` defaults to `false`. Both are booleans. `mobile:` is `:drawer` (default) or `:stack`. `layout.aside_trigger("Details")` is the toggle. |
| Pane scrollbar | `scrollbar` | Sidebar Layout (main pane and aside), Drawer, and Modal. `:hidden` (default) or `:visible`. Anything else raises `ArgumentError`. `:visible` uses the browser bar. The width for a hidden pane is the theme token `--pane-scrollbar-width`, not a Ruby setting. |
| Bar and content | `content_scroll` | Sidebar Layout and Page Layout. `:below` (default) keeps the top bar in flow above the page. `:behind` lets the page scroll under the bar. Not `scroll:` (`:pane` or `:page`). |
| Empty state measure | `width` | `FlatPack::EmptyState::Component` only. `:sm`, `:md`, `:lg`, or `:full`. Caps the text block (and a `media` image) with `--empty-state-measure-*`. The root still fills its container. `:full` is `max-width: none`. |
| Page column | `width` | `FlatPack::PageLayout::Component` only. `:narrow`, `:default`, `:wide`, or `:full`. Sets `--page-layout-width-*`. Unknown values raise `ArgumentError`. Not a CSS length and not a class. |
| Page top bar measure | `top_nav_width` | `FlatPack::PageLayout::Component` only. `:content` (default) or `:full`. `:content` keeps the band full width and constrains the slot wrapper to the column measure and inline inset. `:full` leaves the slot content full width. Anything else raises `ArgumentError`. Not Page Layout `width`. Not Top Nav `padding`. |
| Page alignment | `align` | `FlatPack::PageLayout::Component` only. `:top` (default) or `:center`. `:center` centers the column in the viewport. Not Hero, Email, Button, Table, or Grid `align`. |
| Top nav inline padding | `padding` | `FlatPack::TopNav::Component` only for this row. `:default` (the `--top-nav-padding-inline` inset) or `:none` (side safe area only). Anything else raises `ArgumentError`. Not Card `padding`. |
| Top nav bar height | `size` | `FlatPack::TopNav::Component` only for this row. `:md` (default, `72px`) or `:lg` (`96px`). `:default` is an alias of `:md`. Anything else raises `ArgumentError`. Not Button `size` and not Page Layout `width`. |
| Table column track | `width` | `FlatPack::Table::Column` only. `:fit` (shrink to content), `:fill` (remaining space), or a CSS length such as `"12rem"`. A length uses `table-layout: fixed` unless a sibling is `:fit`. The length stays a `max-width` cap on the header and cells. |
| Table column floor and cap | `min_width` / `max_width` | On a column, CSS lengths such as `"8rem"`. Table `min_width:` stays the scroll floor (`:none`, `:sm`, `:md`, `:lg`, or a `min-w-*` class). |
| Table column wrapping | `wrap` | `FlatPack::Table::Column` only. `:wrap` (default), `:nowrap`, `:truncate`. Truncated cells expose the full text in `title`. |
| Table column visibility | `hide_below` | `FlatPack::Table::Column` only. `:sm`, `:md`, `:lg`, `:xl`. Hides that header and its cells below the breakpoint. The column stays in `colspan`. |
| Table frame | `style` | `FlatPack::Table::Component` `:default` (border, radius, row hover) and `:plain` (none of those). Same param name as Button and Badge. Card fill is `background`. |
| Table row lines | `dividers` | `FlatPack::Table::Component` only. `true` (default) draws the header rule and row lines. `false` removes them. Not List `divider`. |
| Media frame ratio | `aspect_ratio` | Card media, Carousel, and Video preview. `"16/9"`, `"4/3"`, `"1/1"`, or a custom ratio such as `"21/9"`. Video preview defaults to `"16/9"`. |
| Overlay enter origin | `origin` | Modal (and later Drawer). `:center` is today’s fade and scale. `:trigger` grows from the control that opened it. |
| Content / cluster alignment | `align` | Hero overlay copy (`:left` / `:center`) and Email (`:left` / `:center` / `:right`). Email-compatible values. Button label alignment is `:center` (default) or `:start`. `:start` left-aligns the label and gives it `flex-1 min-w-0`. |
| Table column alignment | `align` | `FlatPack::Table::Column` only. `:start` (default), `:center`, `:end`. Logical, so RTL flips start and end. |
| Overlay copy on a photo | `on` | Hero `:centered_image`. `:dark` is light type on a dark wash. `:light` is dark type on a light wash. |
| Grid item alignment | `align` | Grid `items-*` presets: `:start`, `:center`, `:stretch`. Same param name as content `align`, different enum. |
| Masonry column count | `columns` | Masonry: integer 1–6 or a breakpoint hash (`base`, `sm`, `md`, `lg`, `xl`). Collage grid: one integer 1–6. Collage brick uses `rows` instead. Do not use Grid's `cols` here. |
| Masonry pack direction | `order` | Masonry only. `:columns` reads down each column. `:rows` keeps left-to-right source order. |
| FAB viewport corner | `position` | FAB only. `:bottom_right`, `:bottom_left`, `:top_right`, `:top_left`. Not overlay `placement`. |
| FAB speed-dial arrangement | `layout` | FAB only. `:stack` in this release. `:arc` is reserved for a later PR. |
| List shape | `layout` | List only. `:items` (default, `<ul>` or `<ol>`) or `:key_value` (`<dl>`). Not FAB `layout`. Not Collection `layout`. |
| Collection arrangement | `layout` | `FlatPack::Collection::Component` only. `:stack` (default, vertical), `:grid` (auto-fill, equal height), or `:wrap` (inline flex-wrap for badges and chips). |
| Empty state actions | `layout` | `FlatPack::EmptyState::Component` only. `:wrap` (default, wrapping row) or `:stack` (one button under the next). The actions render as `FlatPack::Collection::Component` with that layout. Not `:grid`. |
| Collection element | `as` | `FlatPack::Collection::Component` only. `:list` (default, the `<ul>` alone) or `:nav` (wraps the list in `<nav aria-label>`). |
| Flash presentation | `as` | `FlatPack::Flash::Component`. `:alert` stacks alerts in place. `:toast` renders toasts in a toast region. Required. |
| Nav accessible name | `label` | Collection `as: :nav` requires `label:`. That string is the nav's `aria-label`. Not the visible button label (`text`). |
| Collection item floor | `min_item_width` | Collection `layout: :grid` only. A CSS length such as `"14rem"` (the default). Sets `--fp-collection-min-item-width`. Not Table `min_width`. |
| Collection gap | `gap` | Collection, Grid, and Masonry. `:sm`, `:md`, `:lg` (`gap-2`, `gap-4`, `gap-6`). |
| Button label lines | `lines` | `FlatPack::Button::Component`. `1` (default) or `2`. Clamps the label with an ellipsis. ReadMore `lines` is the clamp budget, a positive integer of line boxes (default `4`). |
| Button icon artwork | `icon_variant` | Heroicon weight on a button-family leading icon and on EmptyState `icon:`. `:outline`, `:solid`, `:mini`, `:micro`. Omit to use `default_icon_variant`. |
| Button icon colour | `icon_style` | `nil` inherits the button text through `currentColor`. `:primary`, `:success`, `:warning`, `:danger` use `--button-icon-*` tokens. |
| Current page control | `current` | `FlatPack::Button::Component` boolean. `true` paints the current look. On a link it also sets `aria-current="page"`. Not a billing plan hash key. |
| Clamped label tooltip | `title` | On Button, the full label for the HTML `title` tooltip when `lines` clamps the visible text. Elsewhere, `title` stays a section heading. |
| Key/value term | `key` | `FlatPack::List::Item` when the list `layout` is `:key_value`. The `<dt>` text. The block is the value. |
| Key column size | `key_width` | List `:key_value` only. `:fit` (widest key) or a CSS length such as `"10rem"`. |
| Stack key above value | `stack_below` | List `:key_value`: `:sm`, `:md`, or `:lg`. Below that breakpoint the key sits above the value. Collage: omit it for the phone row. `:sm`, `:md`, `:lg`, or `:xl` makes one column below that breakpoint and drops the tilt. |
| Collage brick | `rows` | `FlatPack::Collage::Component` only. A list of counts, such as `[5, 4]`. Each count is a row. A shorter row is centered, so it sits between the cards above. Omit it for an even grid of `columns`. |
| Collage scatter | `scatter` | `FlatPack::Collage::Component` only. `:subtle` (default), `:loose`, or `:none`. A deterministic tilt and offset from the item index. `:none` sits square. |
| Collage entrance | `entrance` | `FlatPack::Collage::Component` only. `:rise` (default, staggered fade-up), `:deal` (from the centre, then the tilt settles), or `:none`. |
| Collage idle | `idle` | `FlatPack::Collage::Component` only. `:none` (default) or `:drift` (a slow ±1deg sway). Off below `md`. |
| Collage hover | `hover` | `FlatPack::Collage::Component` only. `:lift` (default), `:focus` (straighten, raise, siblings ease back), or `:none`. Pointer hover needs `(hover: hover)`. Keyboard uses `:focus-visible` and `:focus-within`. Off below `md`. |
| Collage phone count | `mobile_items` | `FlatPack::Collage::Component` only. Default `4`. How many items stay in the phone row. Later items stay in the markup and are not displayed below `md`. Ignored when `stack_below` is set. |
| Scroll reveal | `reveal` | Any component root that calls `merge_attributes`, and `FlatPack::Reveal::Component`. `:fade`, `:rise`, `:blur`, `:scale`, `:wipe`, `:zoom`. `:words` and `:lines` are the Reveal component only. |
| Reveal delay | `delay` | Reveal timing. `:sm`, `:md`, or `:lg` (`--motion-delay-*`, 120ms, 250ms, 450ms). A non-negative Integer is milliseconds. Omit it to start at once. Not Number `duration`. |
| Reveal duration | `duration` | On a reveal: `:fast`, `:base`, `:slow`, or `:slower` (`--motion-duration-*`; `:slower` is 600ms). A non-negative Integer is milliseconds. Omit it for `--motion-duration-slow`. Number `duration` is still only `:fast`, `:base`, or `:slow`. |
| Reveal children | `stagger` | `false`, `true` (`--reveal-stagger`), `:sm`, `:md`, `:lg` (`--motion-stagger-*`, 40ms, 80ms, 120ms), or a non-negative Integer of milliseconds per step. `true` sets `--reveal-index` on the children of a box reveal. Not a text-stream prop. |
| Media scroll shift | `parallax` | Boolean. `true` only with `reveal: :wipe` or `reveal: :zoom`. CSS `animation-timeline: view()` when supported. |
| Reveal intensity | `intensity` | `:strong` or omit. Strong uses `--motion-distance-lg`, `--motion-scale-strong`, and `--motion-zoom-strong`. |
| Animated number | `value` | `FlatPack::Number::Component` only. The numeric amount. A number or a plain numeric string. |
| Number start | `from` | Number only. Where the count or roll begins. Default `0`. |
| Number format | `format` | Number only. `:number` (default), `:currency`, `:percent`, or `:compact`. Percent is a ratio: `0.18` is 18%. |
| Number currency | `currency` | Number only, required with `format: :currency`. A three-letter code such as `"USD"`. |
| Number places | `decimals` | Number only. Omit for the format's own places. `0`–`20` sets both the minimum and the maximum. |
| Number affixes | `prefix` / `suffix` | Number only. Extra text outside the formatted number, such as `"About "` and `" left"`. |
| Number duration | `duration` | Number only. `:fast`, `:base`, or `:slow` (default). Reads `--motion-duration-*`. |
| Number motion | `animate` | Number only. `:count` (default), `:roll`, `:fade`, or `:none`. |
| FAB speed-dial item look | `style` | FAB `with_action` only. Omit for today’s surface glyph. `:danger` uses `--button-danger-*` (same tokens as TrashButton). |
| Scale | `size` | `:sm`, `:md`, `:lg`, and other size tokens. PageTitle and Hero also accept `:display` for cover type. HeroTitle uses `:md`, `:lg`, `:xl`, `:xxl` (`:xl` is `--display-size`). Animated character sizes are `:sm`, `:md`, `:lg`, `:xl` on a larger scale than icons (`:xl` is `w-40`). |
| Character definition | `definition` | `FlatPack::AnimatedCharacter::Component` only. A Hash of `parts` and `states`. Not a raw SVG string. |
| Character mood | `state` | `FlatPack::AnimatedCharacter::Component` only. A state name from `definition`, such as `:idle` or `:blink`. Not billing `status`. |
| Icon motion | `animate` | `FlatPack::Shared::IconComponent` only. `:wiggle`, `:pop`, `:draw`, `:spin`, `:nudge`. |
| Icon motion trigger | `trigger` | `FlatPack::Shared::IconComponent` only, with `animate`. `:hover` (default), `:click`, or `:mount`. |
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
| Host-formatted money | `price_text` / `amount` | Display-only plan prices and invoice amounts. Billing does not format currency. `FlatPack::Number::Component` is the counter, and its `value:` is the numeric amount. |
| Host-formatted date copy | `renews_on`, `trial_ends_on`, `expires_text` | Billing renewal, trial, and card expiry strings the host already formatted |
| Subscription / invoice state | `status` | Billing enums such as `:active`, `:past_due`, `:paid`; map to Badge/Alert `style` in the component |
| Sliding active marker | `indicator` | Tabs, Button::Pill, and Segmented Buttons. Omit for today’s instant swap. `:slide` moves one marker on `--duration-base`. |
| Pill group track | `track` | Button::Pill and Tabs. `false` keeps the row flush. `true` on a pill row adds the border, the transparent track fill, and `--pill-padding`. Stacked and underline tabs ignore it. |
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
| Button group shape | `variant` | `FlatPack::ButtonGroup::Component` and `page_nav_button_group`. `:joined` (default) merges the row. `:outlined` is a bordered desktop container. Not a color. |
| Button group container | `style` | `FlatPack::ButtonGroup::Component` and `page_nav_button_group`. A button style name. On `:outlined`, the container sets `data-fp-style` and paints `--fp-button-background` and `--fp-button-border`. `:default` is the surface. Joined groups do not set the attribute. Children keep their own `style`. |
| Button group count | `visible` | `FlatPack::ButtonGroup::Component` and `page_nav_button_group`. A whole number, or omitted. The first that many children stay in the row. Not scrollbar `:visible`. |
| Button group overflow | `overflow` | `group.button` and `register_page_nav`. `true` forces that child into the trailing menu. `false` keeps it in the row. Omit it and `visible` decides. |
| Button group overflow label | `overflow_label` | `FlatPack::ButtonGroup::Component` and `page_nav_button_group`. Visible text on the trailing trigger. Omit it and the trigger is an icon with accessible name "More". |
| Button group overflow icon | `overflow_icon` | `FlatPack::ButtonGroup::Component` and `page_nav_button_group`. Heroicon on that trigger. Omit it for an ellipsis when there is no label, and a chevron when there is one. |

## Billing namespace notes

Planned family docs live under `docs/components/billing*.md`. When implementing `FlatPack::Billing::*`:

- Prefer `items` for plan picker and invoice collections (do not invent `plans` or `invoices` as prop names).
- Prefer `href` for Change plan, Update card, and invoice Download/View navigation.
- Prefer `empty_title` / `empty_description` for payment-method and invoice empty states.
- Prefer `price_text` and `amount` as preformatted strings on billing. Do not add a billing currency formatter. `FlatPack::Number::Component` formats a single `value:` for display.
- Prefer `cta_text` for plan-picker button copy (action label pattern via `*_text` / `text`).
- Keep PCI out of FlatPack: never add props for full PAN, CVC, or Elements mount points.

## Do not mix

- Do not use `variant`, `type`, `theme`, or `scheme` for color. Use `style`. Card colour fill is `background`. Card shadow, border width, and hover are `shadow`, `border`, and `hover`. Hero overlay contrast uses `on`, because `style` is the HTML attribute on the section.
- Do not use `url` for a clickable navigation destination. Use `href`.
- Do not use `label` for the visible string of a compact control. Use `text`. Copy Button is the exception: `text` is the clipboard string and `label` is the visible label.
- Do not use `position` for overlay placement. Use `placement`. FAB viewport corners stay `position`. Overlay, Media, and Video preview use the nine-cell grid on `with_item`, not the tooltip `:top` / `:bottom` / `:left` / `:right` set.
- Do not use `placement` for where a Modal grows from. Use `origin`.
- Keep `type` only for native HTML control types such as button `type: "submit"`. Carousel slides and lightbox items are the exception: `type` is `:image`, `:video`, or (carousel only) `:html`.
- Do not use `plans` or `invoices` as collection prop names when `items` already covers the concept.
- Do not pass Grid's `:start` or `:stretch` to Hero or Email `align`. Hero accepts `:left` and `:center`. Email also accepts `:right`. Table columns use `:start`, `:center`, and `:end`.
- Do not pass a Table column `width:` length to Media `width`, or a Media integer to a column. Column `min_width:` is a CSS length. Table `min_width:` is the scroll floor. Do not pass EmptyState `:sm` / `:md` / `:lg` / `:full` to Media or a Table column, or a Media integer to EmptyState `width`. Do not pass Page Layout `:narrow`, `:default`, `:wide`, or `:full` to EmptyState, Media, or a Table column. Do not pass a CSS length or a class to Page Layout `width`. Do not pass Page Layout `:top` to Hero, Email, Button, Table, or Grid `align`. Do not pass Page Layout `width` values to `top_nav_width`. That argument is `:content` or `:full`. Do not pass Card `:sm` or `:lg` to Top Nav `padding`. That argument is `:default` or `:none`. Do not pass Button `:sm` to Top Nav `size`. That argument is `:md`, `:lg`, or the `:default` alias of `:md`.
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
- Do not pass `reveal: :words` or `reveal: :lines` as a system argument. Those split the copy in `FlatPack::Reveal::Component`.
- Do not pass Number `duration: :slow` and expect `:slower`. `:slower` is a reveal step. Do not pass a millisecond string. Use a step, or an Integer.
- Do not pass `parallax: true` with `:fade`, `:rise`, `:blur`, `:scale`, `:words`, or `:lines`. It belongs on `:wipe` and `:zoom`.
- Do not add `stream:` to a chat message. Render `FlatPack::Text::Stream::Component` inside the message.
- Do not pass billing `price_text` or `amount` to `FlatPack::Number::Component`. Pass the numeric `value:`. Do not pass Number `currency:` to a billing plan.
