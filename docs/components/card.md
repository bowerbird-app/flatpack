# Card

## Purpose
Render a flexible content container with optional structured header, body, footer, and media sections.

## When to use
Use Card to group related content in a consistent surface with optional hover and clickable behavior. Keep labels in sentence case. Colour fill is `background:`. Shadow, border, and hover are separate. Do not pass raw colours.

## Class
- Primary: `FlatPack::Card::Component`
- Related classes: `FlatPack::Card::Header::Component`, `FlatPack::Card::Body::Component`, `FlatPack::Card::Footer::Component`, `FlatPack::Card::Media::Component`, `FlatPack::Card::Title::Component`, `FlatPack::Card::Stat::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `background` | Symbol | `:default` | no | Colour fill: `:default` (theme surface), `:none` (transparent, so the page, a Backdrop, or a parent surface shows through), `:shaded`, `:brand`, `:brand_subtle`, `:gradient`. Each fill sets its text and muted text. `:none` leaves those colours to inherit. Unknown values raise `ArgumentError`. `style:` is not accepted. |
| `shadow` | Symbol, nil | `nil` | no | Omitted uses `--card-shadow`. `:none`, `:sm`, and `:md` override that token. `:sm` and `:md` use `--shadow-sm` and `--shadow-md`, which dark themes already draw larger. Invalid values raise `ArgumentError`. |
| `border` | Symbol, nil | `nil` | no | Omitted uses `--card-border-width` and `--card-border-color`. `:none` (0), `:default` (1px), and `:strong` (2px) override the width. The colour comes from the background. Invalid values raise `ArgumentError`. |
| `hover` | Symbol | `:none` | no | `:none`, `:subtle`, `:strong`. Subtle washes the fill. Strong lifts the shadow and shifts the border colour. Invalid values raise `ArgumentError`. |
| `clickable` | Boolean | `false` | no | When true and `href` is present, wraps card in a link element. |
| `href` | String | `nil` | no | Link target for clickable cards. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `padding` | Symbol | `:md` | no | Container padding for non-slot content: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `inset` | Symbol, nil | `nil` | no | Sets `--card-inset` without adding padding. `nil` follows `padding:` exactly. `:sm`, `:md`, and `:lg` map to `--card-padding-sm`, `--card-padding-md`, and `--card-padding-lg` through `data-fp-card-inset`. Unknown values raise `ArgumentError`. |
| `radius` | Symbol | `:default` | no | `:default`, `:none`, `:sm`, `:md`, `:lg`, `:xl`, `:xxl`, `:xxxl`. `:default` keeps the theme `--card-radius` and adds no markup. Other values set inline `--card-radius`. Independent of `padding:`. Invalid values raise `ArgumentError`. The inline value carries through to `--media-radius` and `--card-inner-radius`. `FlatPack::Card::Stat::Component` does not take `radius:`. |
| `variant` | Symbol, nil | `:default` | no | Layout. `:default` is the stacked card (media, header, badge, title, body, footer). `nil` is `:default`. `:featured` is a large cover: square media beside the copy once the card is about 640px (`40rem`) wide, stacked below that. The split follows the card width, not the viewport. Invalid values raise `ArgumentError`. `FlatPack::Card::Stat::Component` does not take `variant:`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for card root. |

Behavior note:
- The card does not set a height. A grid stretches a card that is the cell. Pass `class: "h-full"` when the card should fill a parent that already has a height.
- Card root uses `overflow-visible` by default so pop-out UI (for example, dropdown menus) is not clipped by the card container.
- When the `media` slot is present, card root switches to `overflow-hidden` to preserve media edge clipping.
- The `body` slot applies `overflow-hidden` by default to prevent inner content from overflowing the card boundaries.
- The root sets `data-fp-card-padding` to the card's `padding:` step (`none`, `sm`, `md`, or `lg`), including when slots move the padding utility onto the header, footer, or media slot. `FlatPack::Card::Stat::Component` publishes `md`, which is the padding it already uses.
- `variant: :featured` adds `.fp-card--featured` and `data-fp-card-variant="featured"`. The default variant adds neither. Featured still uses the same slots. It does not add an `actions` slot. Header is the top action row. Footer is the bottom action row.

## Inner radius
Kit CSS sets `--card-inset` from `data-fp-card-padding` (`0px`, or the matching `--card-padding-*` token). `inset:` writes `data-fp-card-inset` and those rules come after the padding rules, so they replace `--card-inset` only. Omit `inset:` and the attribute is absent. The radius is computed on `.fp-card`:

```css
--card-inner-radius: max(0px, calc(var(--card-radius) - var(--card-inset)));
```

Children inherit that length. A nested card sets its own step, so its children use its own inner radius.

`fp-card-inner-radius` sets `border-radius` to that length. It ships in kit CSS. Put it on a photo inside the padding, and add `overflow-hidden` when the bitmap should clip. `FlatPack::Media::Component` accepts `radius: :card_inner` and puts the class on the image frame.

The media slot stays on the card corner. The shell's `overflow-hidden` and `rounded-[var(--card-radius)]` clip it. The slot has no radius argument.

At a 16px root the default card radius is 12px. Padding sm, md, and lg is 12px, 16px, and 24px, so the inner radius is 0. The rounded theme uses a 20px card radius and padding of 16px, 20px, and 28px, so only small padding leaves a 4px curve. Padding none keeps the full card radius.

A photo with its own inset uses `padding: :none` and `inset:` so `radius: :card_inner` follows that inset. Pad the inner wrapper with the same token. `inset:` adds no padding of its own.

```erb
<%= render FlatPack::Card::Component.new(padding: :none, inset: :sm) do %>
  <div class="p-[var(--card-padding-sm)]">
    <%= render FlatPack::Media::Component.new(
      src: photo_path,
      alt: "Packaging",
      width: 800,
      height: 320,
      radius: :card_inner
    ) %>
  </div>
<% end %>
```

```erb
<%= render FlatPack::Card::Component.new(padding: :md) do %>
  <%= render FlatPack::Media::Component.new(
    src: "/photos/harbour.jpg",
    alt: "Harbour",
    width: 1200,
    height: 800,
    radius: :card_inner
  ) %>
<% end %>
```

```erb
<%= render FlatPack::Card::Component.new(padding: :sm) do %>
  <div class="fp-card-inner-radius overflow-hidden">
    <%= image_tag "harbour.jpg", alt: "Harbour", class: "block w-full" %>
  </div>
<% end %>
```

## Slots
| name | type | required | description |
|---|---|---|---|
| `header` | slot | no | Header slot wrapper (`FlatPack::Card::Header::Component`). On `:featured`, that element is the top action row (right-aligned in the copy column when the card is side by side, over the photo when the card is stacked). A host class, padding, border, or divider on `card.header` still applies. The row is not `display: contents`. |
| `badge` | slot | no | Small identity mark. On `:featured`, an info badge sits above the title. Pass `FlatPack::Badge::Component`. |
| `title` | slot | no | `FlatPack::Card::Title::Component`, which renders `FlatPack::Heading::Component`. The heading reads `--card-title-size`, `--card-title-weight`, and `--card-title-color`. Featured defaults are on `:where(.fp-card--featured)` (`--text-4xl`, `--display-weight`, `--surface-content-color`), so a declaration on the card wins. The weight fallback is `--display-weight`. The title does not add `font-semibold`; the weight variable is the only weight. |
| `body` | slot | no | Body slot wrapper (`FlatPack::Card::Body::Component`). On `:featured`, the label/value block and any extra line under the title. Direct children are stacked with `--card-body-gap` (default `--space-4`). Put the meta lines in one element and the copy in the next so that gap sits between them. A declaration of `--card-body-gap` on the card wins. |
| `footer` | slot | no | Footer slot wrapper (`FlatPack::Card::Footer::Component`). On `:featured`, the footer is a flex row: each control grows to half the row while the card is stacked, and the row aligns to the end when the columns sit side by side. The footer box is not `display: contents`. |
| `media` | slot | no | Media slot wrapper (`FlatPack::Card::Media::Component`). On `:featured`, the square cover beside the copy (full width when the card is stacked). The block receives that slot. The cover root has `fp-card__cover`. `image` renders `FlatPack::Media` with the slot's `cover:` (`true` on a featured card, `false` otherwise). Pass `cover: false` to `image` or to the media slot to keep `h-auto`. Photo height is `--card-media-image-height` (default `100%`) from `:where(.fp-card__featured-media) .fp-media__image` in `@layer base`. That beats preflight `img { height: auto }`, and a host `h-*` utility on the image still wins. `@layer components` is ordered before preflight, so a height there would not apply. `cover: true` omits `h-auto` so the rule can set the height. Other Media, including a nested card outside this slot, keeps `h-auto`. `:where(.fp-card__cover)` sets `contain: size` with `aspect-ratio: 1 / 1` and a width, so the square does not follow the photo's own ratio or a taller copy column. A host child with no width and no aspect ratio is not size-contained, so its height does not collapse to 0. The overlay and frame fill the cover. When the columns sit side by side the media column aligns to the start. |
| `media.hover_actions` | nested slot | no | One overlay on the photo (dropdown, button, checkbox). Hidden on hover-capable pointers until the media is hovered. Always visible on `focus-within` and on pointers that cannot hover. Named `hover_actions` so it does not collide with a Card-level `actions` slot. `FlatPack::Reveal::Component` does not cover this. Reveal is scroll-in motion. |

Slot props:

| name | type | default | required | description |
|---|---|---|---|---|
| `header.divider` | Boolean | `true` (`false` on `:featured`) | no | Adds bottom border separator. Featured defaults to no divider. |
| `body.padding` | Symbol | `:md` (`:none` on `:featured`) | no | Body inset spacing: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. Featured pads the copy column instead. |
| `footer.divider` | Boolean | `true` (`false` on `:featured`) | no | Adds top border separator. Featured defaults to no divider. |
| `media.aspect_ratio` | String | `nil` (`"1/1"` on `:featured`) | no | Aspect ratio class (`"16/9"`, `"4/3"`, `"1/1"`, or custom ratio string). Featured defaults to square. |
| `media.cover` | Boolean | `false` (`true` on `:featured`) | no | Forwarded to `FlatPack::Media` when the block calls `image`. `true` omits `h-auto`. `false` keeps it. On a featured card the slot default is `true`. Pass `cover: false` on the slot, or on `image`, to opt out. Invalid values raise `ArgumentError`. |
| `media.padding` | Symbol | `:md` (`:none` on `:featured`) | no | Media inset spacing: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. Featured insets the photo with `--card-inset`. |
| `media.hover_actions.placement` | Symbol | `:top_right` | no | Overlay cell. Same nine-cell grid as `FlatPack::Overlay::Item`: `:top_left`, `:top_center`, `:top_right`, `:middle_left`, `:center`, `:middle_right`, `:bottom_left`, `:bottom_center`, `:bottom_right`. Invalid values raise `ArgumentError`. |
| `media.hover_actions.inset` | Symbol | `:sm` | no | Gap from the media edge. `:sm`, `:md`, or `:lg`. Invalid values raise `ArgumentError`. `:center` ignores it. |
| `title.prefix` | String | `nil` | no | Optional text before the title. Include the separator, for example `"Press kit: "`. |
| `title.level` | Symbol, Integer | `:h2` | no | Heading tag. Same argument as `FlatPack::Heading::Component`: `:h1`–`:h6`, or `1`–`6`. Invalid values raise `ArgumentError`. |

## Variants
- Layout: `:default`, `:featured`.
- Background: `:default`, `:none`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`.
- Shadow variants: `:none`, `:sm`, `:md`.
- Border variants: `:none`, `:default`, `:strong`.
- Hover variants: `:none`, `:subtle`, `:strong`.

`:featured` is a two-column cover when the card is at least `40rem` (about 640px) wide. The card sets `container-type: inline-size`, so the split follows the card, not the viewport. The copy column is at least `18rem` (`minmax(18rem, 1fr)`). Below that the card stays stacked: a full-width square cover, with the header actions on the photo. The photo stays square at every width, including when the copy column is taller. It is inset with `--card-inset` on every side while stacked, and on the top, start, and bottom when side by side (flush toward the copy). The media column aligns to the start once the columns sit side by side, instead of stretching with the copy. Direct children of the body are separated by `--card-body-gap` (default `--space-4`). Use `padding: :none`, `inset: :md`, `radius: :xxxl`, `shadow: :md`, and `border: :none` for a large raised cover. Pair the photo with `FlatPack::Media` `radius: :card_inner`. Put a label and value (for example a release date) in one body element, and any longer copy in the next. Put action buttons in `footer`. Do not wrap the card in `href` when the footer has buttons. Header content must not rely on duplicate ids: one header node is used, and CSS places it on the photo while the card is stacked.

## Backgrounds
Each background is four theme tokens. The fill token is a CSS `background`, so a gradient can live there. Host themes set the colours. The card does not take a raw colour.

Filled backgrounds write text, muted text, and border colour back onto `--surface-content-color`, `--surface-muted-content-color`, `--surface-border-color`, and `--card-border-color` for the subtree. Nested text and icons that read those tokens stay with the fill. Button and badge colours stay the host's choice. `:none` paints `--card-background-none` (`transparent`) and does not rebind text, so the surrounding colours show through.

| background | fill | text | muted text | border |
|---|---|---|---|---|
| `:default` | `--card-background-default` | `--card-background-default-text-color` | `--card-background-default-muted-text-color` | `--card-background-default-border-color` |
| `:none` | `--card-background-none` | inherits | inherits | `--card-background-none-border-color` |
| `:shaded` | `--card-background-shaded` | `--card-background-shaded-text-color` | `--card-background-shaded-muted-text-color` | `--card-background-shaded-border-color` |
| `:brand` | `--card-background-brand` | `--card-background-brand-text-color` | `--card-background-brand-muted-text-color` | `--card-background-brand-border-color` |
| `:brand_subtle` | `--card-background-brand-subtle` | `--card-background-brand-subtle-text-color` | `--card-background-brand-subtle-muted-text-color` | `--card-background-brand-subtle-border-color` |
| `:gradient` | `--card-background-gradient` | `--card-background-gradient-text-color` | `--card-background-gradient-muted-text-color` | `--card-background-gradient-border-color` |

Light mode defines every colour token on `:root, [data-theme]`. Default follows `--card-background-color`, which is the raised surface (`#fff` on the default palette). Shaded follows `--card-background-muted-color`. Brand follows `--color-primary` and `--color-primary-text`. Soft brand mixes the primary into the surface. The gradient runs from `--color-primary` toward a darker mix so contrasting text stays readable. Dark mode overrides only `--card-background-gradient`, lifting the gradient toward white so dark primary text still reads. `:none` is `transparent`. The other fills follow the dark semantic tokens.

The default edge is `--card-border-width` and `--card-shadow`. Those live on bare `:root` (`1px` and `none`) and on `[data-theme~="rounded"]` (`0` and `var(--shadow-sm)`). Dark and ocean do not set them. Omit `border:` and `shadow:` to use the theme. Pass either argument to override that one card. A border-only card is `background: :none`. On rounded, pass `border: :default` as well, because the theme width is `0`.

`FlatPack::Card::Stat::Component` takes the same `background:` and paints that fill on itself. It does not take `radius:`.

## Example
```erb
<%= render FlatPack::Card::Component.new(hover: :strong, clickable: true, href: post_path(@post)) do |card| %>
  <% card.header do %>
    <h3 class="text-lg font-semibold"><%= @post.title %></h3>
  <% end %>

  <% card.body do %>
    <p class="text-sm text-[var(--surface-muted-content-color)]"><%= @post.excerpt %></p>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Card::Component.new(background: :brand, shadow: :md) do |card| %>
  <% card.body do %>
    <h3 class="text-lg font-semibold">Paid plan</h3>
    <p class="text-sm text-[var(--surface-muted-content-color)]">Renews on the first.</p>
    <%= render FlatPack::Button::Component.new(text: "Add money", style: :default) %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Card::Component.new(radius: :xxl, padding: :none) do |card| %>
  <% card.media(padding: :none) do %>
    <%= render FlatPack::Media::Component.new(
      src: "/images/hero-stool.jpg",
      alt: "Stool",
      width: 1200,
      height: 800
    ) %>
  <% end %>
  <% card.body { "Harbour card" } %>
<% end %>
```

`radius: :xxl` sets the corner to `--radius-xxl` (2rem). `padding: :none` is separate.

```erb
<%= render FlatPack::Card::Component.new(padding: :none) do |card| %>
  <% card.media(aspect_ratio: "16/9", padding: :none) do |media| %>
    <%= image_tag "/masonry/kiln.svg", class: "h-full w-full object-cover", alt: "Kiln yard" %>
    <% media.hover_actions do %>
      <%= render FlatPack::Button::Dropdown::Component.new(
        text: "Cover actions",
        icon: "ellipsis-vertical",
        icon_only: true,
        style: :secondary,
        size: :sm,
        placement: :bottom_left
      ) do |dropdown| %>
        <% dropdown.menu_item(text: "Replace cover", href: "#") %>
        <% dropdown.menu_item(text: "Remove cover", href: "#") %>
      <% end %>
    <% end %>
  <% end %>
  <% card.body { "Kiln notes" } %>
<% end %>
```

Omit `hover_actions` and the media markup stays the same. Pass `placement:` and `inset:` on `hover_actions` when the control should sit in another corner.

The slot is visible by default. On `(hover: hover)` it starts hidden and appears on `group-hover/media`. Keyboard focus uses `focus-within`. A phone never matches that hover query, so the control stays in view. `FlatPack::Media::Component` `with_item` can still take the same hover classes by hand. Prefer `hover_actions` on Card media so the host does not copy those utilities.

```erb
<%= render FlatPack::Card::Component.new(radius: :xxxl, padding: :md) do %>
  <%= render FlatPack::Media::Component.new(
    src: "/images/hero-stool.jpg",
    alt: "Stool",
    width: 1200,
    height: 800,
    radius: :card_inner
  ) %>
<% end %>
```

`radius: :xxxl` sets the corner to `--radius-xxxl` (2.5rem, 40px). `radius: :card_inner` on Media uses `max(0px, calc(var(--card-radius) - var(--card-inset)))`, so the photo nests inside that corner. `padding: :md` only sets the inset.

```erb
<%= render FlatPack::Card::Component.new(
  variant: :featured,
  padding: :none,
  inset: :md,
  radius: :xxxl,
  shadow: :md,
  border: :none
) do |card| %>
  <% card.media do |media| %>
    <%= media.image(
      src: cover_path,
      alt: "Spring launch",
      width: 800,
      height: 800,
      radius: :card_inner
    ) %>
  <% end %>
  <% card.header do %>
    <%= render FlatPack::Button::Component.new(icon: "share", icon_only: true, style: :secondary, size: :md, round: true, aria: { label: "Share" }) %>
    <%= render FlatPack::Button::Component.new(icon: "heart", icon_only: true, style: :secondary, size: :md, round: true, aria: { label: "Add to list" }) %>
  <% end %>
  <% card.badge do %>
    <%= render FlatPack::Badge::Component.new(text: "Northlight", style: :info, size: :xs) %>
  <% end %>
  <% card.title(prefix: "Press kit: ") { "Spring launch" } %>
  <% card.body do %>
    <p class="text-sm text-[var(--surface-muted-content-color)]">Release date</p>
    <p>3 Sep 2026</p>
  <% end %>
  <% card.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Contact", style: :secondary, size: :md) %>
    <%= render FlatPack::Button::Component.new(text: "Download kit", style: :primary, size: :md) %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Card::Stat::Component.new(
  value: "$12,400",
  label: "Monthly revenue",
  trend: "+4%",
  trend_direction: :up,
  background: :shaded
) %>
```

## Accessibility
- Uses semantic container elements (`div` or `a` when clickable).
- Clickable cards become a single focusable link target.
- Keep nested interactive controls out of fully clickable cards to avoid conflicting focus targets.
- `media.hover_actions` is visual only. The control needs its own label. It stays in the tab order. On a hover pointer it is hidden until the media is hovered or the control is focused. On a touch device it stays visible.
- `FlatPack::Card::Stat::Component` paints up/down trend copy with `--color-success-background-color` / `--color-danger-background-color`, not a Tailwind green or red.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
