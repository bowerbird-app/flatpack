# Button

## Purpose
Render a button or link with FlatPack styles, validation, and loading/icon states.

## When to use
Use this for primary and secondary actions in forms, toolbars, dialogs, and list rows.

## Class
- `FlatPack::Button::Component`
- `FlatPack::Button::Pill::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `text` | String, nil | `nil` | no | Visible label text. Required unless `icon` is provided. On `icon_only` buttons, `text` is the accessible name (`aria-label`) and is not shown. |
| `style` | Symbol | `:default` | no | Built-in: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:danger`. Hosts and gems may register more names with `FlatPack::Button.register_style`. Unknown names raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | One of `:sm`, `:md`, `:lg`. |
| `href` | String, nil | `nil` | no | When present, renders an `<a>` via `link_to`; otherwise a `<button>`. |
| `method` | Symbol, nil | `nil` | no | Link method passed to `link_to` (for non-GET link actions). |
| `target` | String, nil | `nil` | no | Link target, for example `"_blank"`. |
| `icon` | String, nil | `nil` | no | Heroicons v2 name rendered before text (or alone with `icon_only`), e.g. `"magnifying-glass"`, `"plus"`, `"trash"`. Legacy shorthand aliases are supported for backward compatibility. |
| `icon_only` | Boolean | `false` | no | Uses compact icon-only padding, a 44px hit target (`.fp-hit-target`), and hides visible text. Requires `text:` or `aria: { label: "…" }`. |
| `loading` | Boolean | `false` | no | Disables button and shows spinner; text becomes `Loading` when not icon-only. |
| `type` | String | `"button"` | no | Native button type for button mode: `button`, `submit`, `reset`. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes/classes/data/aria. |

## Slots
No slots.

## Variants
- Built-in styles: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:danger`
- Host-registered styles: any name added with `FlatPack::Button.register_style`
- Sizes: `:sm`, `:md`, `:lg`
- Render modes: button mode (`type`) and link mode (`href`, optional `method`, optional `target`)
- States: loading, icon + text, icon-only

## Host-registered styles
The seven built-in styles are kit-owned. Do not override `--color-primary` (or other theme tokens) to recolour one button. A host or third-party gem registers a named colourway, then paints it with local `--fp-button-*` tokens.

Ruby (initializer or gem engine):

```ruby
FlatPack::Button.register_style(:partner, press: :raised)
```

`press:` is `:raised` (default, shadowed like primary) or `:flat` (inset press like ghost and secondary). Size, radius, focus ring, disabled opacity, and loading stay kit.

CSS loaded after `flat_pack/application`:

```css
.fp-button[data-fp-style="partner"] {
  --fp-button-background: #635bff;
  --fp-button-hover-background: #0a2540;
  --fp-button-text: #ffffff;
  --fp-button-border: #635bff;
}
```

```erb
<%= render FlatPack::Button::Component.new(text: "Manage billing", style: :partner) %>
```

The button sets `data-fp-style` to the style name. Built-in styles map that attribute onto `--button-primary-*` and the other scheme tokens, so theme and hero overlay remaps still apply. A registered style sets `--fp-button-*` directly and does not change the page theme.

Do not register over a built-in name. Names are a lowercase letter, then letters, numbers, or underscores. Vendor colours (Stripe, Paddle, and the rest) belong in the host or billing gem CSS, not in FlatPack.

The dummy demo registers `:partner` in `config/initializers/flat_pack.rb` and paints it in the host stylesheet. See `/demo/buttons`.

## Pill Group Variant
Use `FlatPack::Button::Pill::Component` when you need the rounded pills styling from the tabs demo as a grouped set of plain link controls for filters, view switches, or segmented navigation outside a tablist.

### Pill Group Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `items` | Array<Hash> | none | yes | One or more pill definitions. Each item requires `text` and `href`, and may include `id`, `active`, `target`, `class`, `data`, and `aria`. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes/classes/data/aria for the outer group wrapper. |

```erb
<%= render FlatPack::Button::Pill::Component.new(
  items: [
    {text: "All products", href: products_path, active: true, id: "products-pill"},
    {text: "On sale", href: sale_products_path}
  ]
) %>
```

## Example
```erb
<%= render FlatPack::Button::Component.new(
  text: "Delete",
  style: :danger,
  size: :sm,
  href: post_path(@post),
  method: :delete,
  data: { turbo_confirm: "Delete this post?" }
) %>
```

```erb
<%= render FlatPack::Button::Component.new(
  icon: "magnifying-glass",
  icon_only: true,
  aria: { label: "Search" }
) %>
```

## Touch
Buttons, links rendered as buttons, and pill items include `.fp-touch-manipulation` (`touch-action: manipulation`) so taps are not delayed by double-tap zoom. Icon-only controls also get that from `.fp-hit-target`. Kit CSS does not set a host-wide `button {}` rule.

## Accessibility
- Icon-only buttons must have an accessible name: `text:` (used as `aria-label`, not shown) or `aria: { label: "Open settings" }`. Missing a name raises `ArgumentError`.
- Loading icon-only buttons keep that name and set `aria-busy="true"`.
- Focus ring styles are applied by default for keyboard navigation.
- In loading state, the button is disabled to prevent duplicate actions. The spinner is `FlatPack::Spinner::Component` with `label: nil` (decorative).
- Colour, border, and shadow ease on `--duration-fast` / `--easing-standard`. Press is a 1px `translateY` on `.fp-button`, not a scale. Raised styles use `.fp-button-raised`. Ghost, secondary, and `press: :flat` use `.fp-button-flat` for an inset shadow on press. Colour paint is kit CSS on `.fp-button[data-fp-style]`, not per-style Tailwind background classes.

## Dependencies
- `FlatPack::Spinner::Component` for the loading mark.
- `FlatPack::Shared::IconComponent` for icon and spinner sizing.
- `FlatPack::AttributeSanitizer` for URL sanitization and protocol allowlisting (`http`, `https`, `mailto`, `tel`, relative URLs).
