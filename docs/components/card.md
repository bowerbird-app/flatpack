# Card

## Purpose
Render a flexible content container with optional structured header, body, footer, and media sections.

## When to use
Use Card to group related content in a consistent surface with optional hover and clickable behavior.

## Class
- Primary: `FlatPack::Card::Component`
- Related classes: `FlatPack::Card::Header::Component`, `FlatPack::Card::Body::Component`, `FlatPack::Card::Footer::Component`, `FlatPack::Card::Media::Component`, `FlatPack::Card::Stat::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `style` | Symbol | `:default` | no | Visual style: `:default`, `:elevated`, `:outlined`, `:flat`, `:interactive`, `:list`; invalid values raise `ArgumentError`. |
| `hover` | Symbol | `nil` | no | Explicit hover mode: `:none`, `:subtle`, `:strong`; when `nil`, style default applies (`:interactive` => `:strong`, `:list` => `:subtle`, others => `:none`). Invalid values raise `ArgumentError`. |
| `clickable` | Boolean | `false` | no | When true and `href` is present, wraps card in a link element. |
| `href` | String | `nil` | no | Link target for clickable cards. Sanitized via `FlatPack::AttributeSanitizer`; unsafe URLs raise `ArgumentError`. |
| `padding` | Symbol | `:md` | no | Container padding for non-slot content: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `theme` | Hash | `nil` | no | Optional card-local token overrides. Supported keys: `:background`, `:text`, `:muted_text`, `:primary`, `:primary_hover`, `:primary_text`, `:default_button`, `:default_button_hover`, `:default_button_text`, `:default_button_border`, `:secondary_button`, `:secondary_button_hover`, `:secondary_button_text`, and `:secondary_button_border`. Only supplied keys override the card subtree; omitted keys continue using the existing theme tokens. Invalid keys or unsafe CSS color values raise `ArgumentError`. |
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
| `footer.divider` | Boolean | `true` | no | Adds top border separator. |
| `media.aspect_ratio` | String | `nil` | no | Aspect ratio class (`"16/9"`, `"4/3"`, `"1/1"`, or custom ratio string). |
| `media.padding` | Symbol | `:md` | no | Media inset spacing: `:none`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |

## Variants
- Style variants: `:default`, `:elevated`, `:outlined`, `:flat`, `:interactive`, `:list`.
- Hover variants: `:none`, `:subtle`, `:strong` (or style-derived when omitted).

## Theme overrides
- `theme` writes CSS custom-property overrides on the card root, so nested content and token-driven components inherit the new palette only inside that card.
- Pass any subset of `:background`, `:text`, `:muted_text`, `:primary`, `:primary_hover`, `:primary_text`, `:default_button`, `:default_button_hover`, `:default_button_text`, `:default_button_border`, `:secondary_button`, `:secondary_button_hover`, `:secondary_button_text`, and `:secondary_button_border`.
- Omitted keys are not inferred from other values; they keep the original card or global token as a fallback.
- Theme values must be safe CSS colors such as hex, `oklch(...)`, `rgb(...)`, `hsl(...)`, or `var(--token)`.

| variable | accepts | example |
|---|---|---|
| `theme` | Full card-local override hash | `theme: { background: "#163300", text: "#9FE870", muted_text: "#9FE870", primary: "#9FE870", primary_hover: "#9FE870", primary_text: "#163300" }` |
| `background` | Card background color | `background: "#163300"` |
| `text` | Primary text color inside the card | `text: "#9FE870"` |
| `muted_text` | Muted/supporting text color inside the card | `muted_text: "#9FE870"` |
| `primary` | Shared primary accent and primary button background/border | `primary: "#9FE870"` |
| `primary_hover` | Shared primary hover accent and primary button hover background | `primary_hover: "#84cc16"` |
| `primary_text` | Shared primary contrast text and primary button text | `primary_text: "#163300"` |
| `default_button` | Default button background color | `default_button: "#f8fafc"` |
| `default_button_hover` | Default button hover background color | `default_button_hover: "#e2e8f0"` |
| `default_button_text` | Default button text color | `default_button_text: "#0f172a"` |
| `default_button_border` | Default button border color | `default_button_border: "#cbd5e1"` |
| `secondary_button` | Secondary button background color | `secondary_button: "#111827"` |
| `secondary_button_hover` | Secondary button hover background color | `secondary_button_hover: "#1f2937"` |
| `secondary_button_text` | Secondary button text color | `secondary_button_text: "#f9fafb"` |
| `secondary_button_border` | Secondary button border color | `secondary_button_border: "#4b5563"` |

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
<%= render FlatPack::Card::Component.new(
  style: :elevated,
  theme: {
    background: "#163300",
    text: "#9FE870",
    primary: "#9FE870",
    primary_text: "#163300"
  }
) do |card| %>
  <% card.header do %>
    <p class="text-sm font-medium uppercase tracking-[0.2em] opacity-80">Wise-style balance</p>
    <h3 class="mt-2 text-2xl font-semibold">Travel card</h3>
  <% end %>

  <% card.body do %>
    <p class="text-sm text-[var(--surface-muted-content-color)]">Local tokens stay inside this card. A neighboring card keeps the default FlatPack theme.</p>
  <% end %>

  <% card.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Add money", style: :primary) %>
  <% end %>
<% end %>
```

## Accessibility
- Uses semantic container elements (`div` or `a` when clickable).
- Clickable cards become a single focusable link target.
- Keep nested interactive controls out of fully clickable cards to avoid conflicting focus targets.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
