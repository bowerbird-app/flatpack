# Card

## Purpose
Render a flexible content container with optional structured header, body, footer, and media sections.

## When to use
Use Card to group related content in a consistent surface with optional hover and clickable behavior. Keep labels in sentence case. Colour fill is `style:`. Shadow, border, and hover are separate. Do not pass raw colours.

## Class
- Primary: `FlatPack::Card::Component`
- Related classes: `FlatPack::Card::Header::Component`, `FlatPack::Card::Body::Component`, `FlatPack::Card::Footer::Component`, `FlatPack::Card::Media::Component`, `FlatPack::Card::Stat::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `style` | Symbol | `:default` | no | Colour fill: `:default` (surface), `:shaded` (soft grey), `:brand` (solid brand colour and contrasting text), `:brand_subtle` (light brand tint and normal text), `:gradient` (brand gradient and contrasting text). Sets background, text, muted text, and border colour only. Invalid values raise `ArgumentError`. |
| `shadow` | Symbol | `:none` | no | `:none`, `:sm`, `:md`. Uses `--shadow-sm` and `--shadow-md`, which dark themes already draw larger. Invalid values raise `ArgumentError`. |
| `border` | Symbol | `:default` | no | `:none`, `:default` (1px), `:strong` (2px). The colour comes from the style. Invalid values raise `ArgumentError`. |
| `hover` | Symbol | `:none` | no | `:none`, `:subtle`, `:strong`. Subtle washes the fill. Strong lifts the shadow and shifts the border colour. Invalid values raise `ArgumentError`. |
| `clickable` | Boolean | `false` | no | When true and `href` is present, wraps card in a link element. |
| `href` | String | `nil` | no | Link target for clickable cards. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `padding` | Symbol | `:md` | no | Container padding for non-slot content: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `radius` | Symbol | `:default` | no | `:default`, `:none`, `:sm`, `:md`, `:lg`, `:xl`, `:xxl`. `:default` keeps the theme `--card-radius` and adds no markup. Other values set inline `--card-radius`. Independent of `padding:`. Invalid values raise `ArgumentError`. The inline value carries through to `--media-radius` and `--card-inner-radius`. `FlatPack::Card::Stat::Component` does not take `radius:`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for card root. |

Behavior note:
- Card root uses `overflow-visible` by default so pop-out UI (for example, dropdown menus) is not clipped by the card container.
- When the `media` slot is present, card root switches to `overflow-hidden` to preserve media edge clipping.
- The `body` slot applies `overflow-hidden` by default to prevent inner content from overflowing the card boundaries.
- The root sets `data-fp-card-padding` to the card's `padding:` step (`none`, `sm`, `md`, or `lg`), including when slots move the padding utility onto the header, footer, or media slot. `FlatPack::Card::Stat::Component` publishes `md`, which is the padding it already uses.

## Inner radius
Kit CSS sets `--card-inset` from `data-fp-card-padding` (`0px`, or the matching `--card-padding-*` token) and computes this on `.fp-card`:

```css
--card-inner-radius: max(0px, calc(var(--card-radius) - var(--card-inset)));
```

Children inherit that length. A nested card sets its own step, so its children use its own inner radius.

`fp-card-inner-radius` sets `border-radius` to that length. It ships in kit CSS. Put it on a photo inside the padding, and add `overflow-hidden` when the bitmap should clip. `FlatPack::Media::Component` accepts `radius: :card_inner` and puts the class on the image frame.

The media slot stays on the card corner. The shell's `overflow-hidden` and `rounded-[var(--card-radius)]` clip it. The slot has no radius argument.

At a 16px root the default card radius is 12px. Padding sm, md, and lg is 12px, 16px, and 24px, so the inner radius is 0. The rounded theme uses a 20px card radius and padding of 16px, 20px, and 28px, so only small padding leaves a 4px curve. Padding none keeps the full card radius.

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
| `header` | slot | no | Header slot wrapper (`FlatPack::Card::Header::Component`). |
| `body` | slot | no | Body slot wrapper (`FlatPack::Card::Body::Component`). |
| `footer` | slot | no | Footer slot wrapper (`FlatPack::Card::Footer::Component`). |
| `media` | slot | no | Media slot wrapper (`FlatPack::Card::Media::Component`). |

Slot props:

| name | type | default | required | description |
|---|---|---|---|---|
| `header.divider` | Boolean | `true` | no | Adds bottom border separator. |
| `body.padding` | Symbol | `:md` | no | Body inset spacing: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `footer.divider` | Boolean | `true` | no | Adds top border separator. |
| `media.aspect_ratio` | String | `nil` | no | Aspect ratio class (`"16/9"`, `"4/3"`, `"1/1"`, or custom ratio string). |
| `media.padding` | Symbol | `:md` | no | Media inset spacing: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |

## Variants
- Style variants: `:default`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`.
- Shadow variants: `:none`, `:sm`, `:md`.
- Border variants: `:none`, `:default`, `:strong`.
- Hover variants: `:none`, `:subtle`, `:strong`.

## Styles
Each style is four theme tokens. `background` is a `background` value so a gradient can live there. Host themes set the colours. The card does not take a raw colour.

The card writes those tokens back onto `--surface-content-color`, `--surface-muted-content-color`, `--surface-border-color`, and `--card-border-color` for its subtree. Nested text and icons that read those tokens stay with the style. Button and badge colours stay the host's choice.

| style | background | text | muted text | border |
|---|---|---|---|---|
| `:default` | `--card-style-default-background` | `--card-style-default-text-color` | `--card-style-default-muted-text-color` | `--card-style-default-border-color` |
| `:shaded` | `--card-style-shaded-background` | `--card-style-shaded-text-color` | `--card-style-shaded-muted-text-color` | `--card-style-shaded-border-color` |
| `:brand` | `--card-style-brand-background` | `--card-style-brand-text-color` | `--card-style-brand-muted-text-color` | `--card-style-brand-border-color` |
| `:brand_subtle` | `--card-style-brand-subtle-background` | `--card-style-brand-subtle-text-color` | `--card-style-brand-subtle-muted-text-color` | `--card-style-brand-subtle-border-color` |
| `:gradient` | `--card-style-gradient-background` | `--card-style-gradient-text-color` | `--card-style-gradient-muted-text-color` | `--card-style-gradient-border-color` |

Light mode defines every token on `:root, [data-theme]`. Default follows `--card-background-color`. Shaded follows `--card-background-muted-color`. Brand follows `--color-primary` and `--color-primary-text`. Soft brand mixes the primary into the surface. The gradient runs from `--color-primary` toward a darker mix so contrasting text stays readable. Dark mode overrides only `--card-style-gradient-background`, lifting the gradient toward white so dark primary text still reads. The other styles follow the dark semantic tokens.

`FlatPack::Card::Stat::Component` takes the same `style:` and paints that fill on itself. It does not take `radius:`.

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
<%= render FlatPack::Card::Component.new(style: :brand, shadow: :md) do |card| %>
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
<%= render FlatPack::Card::Stat::Component.new(
  value: "$12,400",
  label: "Monthly revenue",
  trend: "+4%",
  trend_direction: :up,
  style: :shaded
) %>
```

## Accessibility
- Uses semantic container elements (`div` or `a` when clickable).
- Clickable cards become a single focusable link target.
- Keep nested interactive controls out of fully clickable cards to avoid conflicting focus targets.
- `FlatPack::Card::Stat::Component` paints up/down trend copy with `--color-success-background-color` / `--color-danger-background-color`, not a Tailwind green or red.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
