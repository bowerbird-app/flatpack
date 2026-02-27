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
| `**system_arguments` | Hash | `{}` | no | HTML attributes for card root. |

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

## Accessibility
- Uses semantic container elements (`div` or `a` when clickable).
- Clickable cards become a single focusable link target.
- Keep nested interactive controls out of fully clickable cards to avoid conflicting focus targets.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
