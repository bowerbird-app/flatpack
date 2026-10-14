# Card

## Purpose
Render a flexible content container with optional structured header, body, footer, and media sections.

## When to use
Use Card to group related content in a consistent surface with optional hover and clickable behavior. Keep labels in sentence case. Colour fill is `tone:`. `style:` is the border, shadow, and hover. Do not pass raw colours.

## Class
- Primary: `FlatPack::Card::Component`
- Related classes: `FlatPack::Card::Header::Component`, `FlatPack::Card::Body::Component`, `FlatPack::Card::Footer::Component`, `FlatPack::Card::Media::Component`, `FlatPack::Card::Stat::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `style` | Symbol | `:default` | no | Structure only: `:default`, `:elevated`, `:outlined`, `:interactive`, `:list`. Border, shadow, and hover. Invalid values raise `ArgumentError`. `:flat` is removed. |
| `tone` | Symbol | `:default` | no | Colour fill: `:default` (surface), `:shaded` (soft grey), `:brand` (solid brand colour and contrasting text), `:brand_subtle` (light brand tint and normal text), `:gradient` (brand gradient and contrasting text). One tone per card. Invalid values raise `ArgumentError`. |
| `hover` | Symbol | `nil` | no | Explicit hover mode: `:none`, `:subtle`, `:strong`; when `nil`, style default applies (`:interactive` => `:strong`, `:list` => `:subtle`, others => `:none`). Invalid values raise `ArgumentError`. |
| `clickable` | Boolean | `false` | no | When true and `href` is present, wraps card in a link element. |
| `href` | String | `nil` | no | Link target for clickable cards. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `padding` | Symbol | `:md` | no | Container padding for non-slot content: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for card root. |

Behavior note:
- Card root uses `overflow-visible` by default so pop-out UI (for example, dropdown menus) is not clipped by the card container.
- When the `media` slot is present, card root switches to `overflow-hidden` to preserve media edge clipping.
- The `body` slot applies `overflow-hidden` by default to prevent inner content from overflowing the card boundaries.

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
- Style variants: `:default`, `:elevated`, `:outlined`, `:interactive`, `:list`.
- Tone variants: `:default`, `:shaded`, `:brand`, `:brand_subtle`, `:gradient`.
- Hover variants: `:none`, `:subtle`, `:strong` (or style-derived when omitted).

## Tones
Each tone is four theme tokens. `background` is a `background` value so a gradient can live there. Host themes set the colours. The card does not take a raw colour.

The card writes those tokens back onto `--surface-content-color`, `--surface-muted-content-color`, `--surface-border-color`, and `--card-border-color` for its subtree. Nested text and icons that read those tokens stay with the tone. On `:brand` and `:gradient`, button and badge aliases are rebound to that text and border so a primary button does not disappear into the fill.

| tone | background | text | muted text | border |
|---|---|---|---|---|
| `:default` | `--card-tone-default-background` | `--card-tone-default-text-color` | `--card-tone-default-muted-text-color` | `--card-tone-default-border-color` |
| `:shaded` | `--card-tone-shaded-background` | `--card-tone-shaded-text-color` | `--card-tone-shaded-muted-text-color` | `--card-tone-shaded-border-color` |
| `:brand` | `--card-tone-brand-background` | `--card-tone-brand-text-color` | `--card-tone-brand-muted-text-color` | `--card-tone-brand-border-color` |
| `:brand_subtle` | `--card-tone-brand-subtle-background` | `--card-tone-brand-subtle-text-color` | `--card-tone-brand-subtle-muted-text-color` | `--card-tone-brand-subtle-border-color` |
| `:gradient` | `--card-tone-gradient-background` | `--card-tone-gradient-text-color` | `--card-tone-gradient-muted-text-color` | `--card-tone-gradient-border-color` |

Light mode defines every token on `:root, [data-theme]`. Default follows `--card-background-color`. Shaded follows `--card-background-muted-color`. Brand follows `--color-primary` and `--color-primary-text`. Soft brand mixes the primary into the surface. The gradient runs from `--color-primary` toward a darker mix so contrasting text stays readable. Dark mode overrides only `--card-tone-gradient-background`, lifting the gradient toward white so dark primary text still reads. The other tones follow the dark semantic tokens.

`FlatPack::Card::Stat::Component` takes the same `tone:` and paints that fill on itself.

## Example
```erb
<%= render FlatPack::Card::Component.new(style: :interactive, clickable: true, href: post_path(@post)) do |card| %>
  <% card.header do %>
    <h3 class="text-lg font-semibold"><%= @post.title %></h3>
  <% end %>

  <% card.body do %>
    <p class="text-sm text-[var(--surface-muted-content-color)]"><%= @post.excerpt %></p>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Card::Component.new(style: :elevated, tone: :brand) do |card| %>
  <% card.body do %>
    <h3 class="text-lg font-semibold">Paid plan</h3>
    <p class="text-sm text-[var(--surface-muted-content-color)]">Renews on the first.</p>
    <%= render FlatPack::Button::Component.new(text: "Add money", style: :primary) %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Card::Stat::Component.new(
  value: "$12,400",
  label: "Monthly revenue",
  trend: "+4%",
  trend_direction: :up,
  tone: :shaded
) %>
```

## Accessibility
- Uses semantic container elements (`div` or `a` when clickable).
- Clickable cards become a single focusable link target.
- Keep nested interactive controls out of fully clickable cards to avoid conflicting focus targets.
- `FlatPack::Card::Stat::Component` paints up/down trend copy with `--color-success-background-color` / `--color-danger-background-color`, not a Tailwind green or red.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
