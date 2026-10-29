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
| `size` | Symbol | `:md` | no | `:sm`, `:md`, `:lg`, or icon-only `:xs`. `:xs` with a label raises `ArgumentError`. `:xs` stays out of `SIZES`, so SegmentedButtons, Tabs, and Button::Pill do not accept it. |
| `round` | Boolean | `false` | no | `true` uses `--button-round-border-radius` (`--radius-full` on every theme). A label becomes a pill. `icon_only: true` also sets an equal width and height (`--button-round-size-sm`, `--button-round-size-md`, `--button-round-size-lg`, `--button-round-size-xs`) so the control is a circle at every size. `:xs` is `2rem` with no hit-target floor. `false` keeps `--button-border-radius`. Anything other than `true` or `false` raises `ArgumentError`. A host `rounded-*` class still replaces the radius. |
| `href` | String, nil | `nil` | no | When present, renders an `<a>` via `link_to`; otherwise a `<button>`. |
| `method` | Symbol, nil | `nil` | no | Link method passed to `link_to` (for non-GET link actions). |
| `target` | String, nil | `nil` | no | Link target, for example `"_blank"`. |
| `icon` | String, nil | `nil` | no | Leading mark, before text (or alone with `icon_only`). A Heroicons v2 name such as `"magnifying-glass"`, `"plus"`, or `"trash"`, including legacy short aliases. A String that starts with `<svg` (after leading whitespace) is painted as markup, the same way `FlatPack::List::Item` does. That string must be trusted host markup, not user input. The kit puts it in a Heroicon-sized box (`w-5 h-5` at `:md`, `w-4 h-4` at `:sm` and icon-only `:xs`, `w-6 h-6` at `:lg`). `icon_variant` and `icon_style` apply to Heroicon names only. |
| `icon_variant` | Symbol, nil | `nil` | no | `:outline`, `:solid`, `:mini`, or `:micro`. Omit to use `FlatPack.configuration.default_icon_variant` (`:outline` unless the host changed it). Passed to `FlatPack::Shared::IconComponent` `variant:`. Unknown names raise `ArgumentError`. |
| `icon_style` | Symbol, nil | `nil` | no | `nil` inherits the button text through `currentColor`. `:primary`, `:success`, `:warning`, or `:danger` paint the glyph from `--button-icon-primary-color`, `--button-icon-success-color`, `--button-icon-warning-color`, and `--button-icon-danger-color`. The class mixes that token toward `--fp-button-text` so it stays readable on every button `style`. When `icon_style` matches `style`, the glyph uses the button text colour. Disabled buttons still mute it with `--button-disabled-opacity`. Unknown names raise `ArgumentError`. There is no `icon_class`. |
| `icon_only` | Boolean | `false` | no | Uses compact icon-only padding and hides visible text. `:sm`, `:md`, and `:lg` grow the painted box with `.fp-hit-target` (44px). `:xs` paints about 32px (`--button-icon-only-padding-xs`, a 1rem icon) and keeps the 44px tap on `.fp-hit-slop`. Requires `text:` or `aria: { label: "…" }`. Always pass an `aria-label`. Adjacent `:xs` buttons need about 12px between them or the 44px tap areas overlap. |
| `loading` | Boolean | `false` | no | Disables button and shows spinner; text becomes `Loading` when not icon-only. |
| `disabled` | Boolean | `false` | no | Disables the control without the spinner. `true` mutes it with the same opacity and `pointer-events-none` as loading. A `<button>` sets `disabled`. A link keeps `href`, sets `aria-disabled="true"` and `tabindex="-1"`. `nil` and `false` leave the control enabled. |
| `type` | String | `"button"` | no | Native button type for button mode: `button`, `submit`, `reset`. |
| `align` | Symbol | `:center` | no | `:center` keeps the label in the middle. `:start` left-aligns it and lets the label fill the remaining space (`flex-1 min-w-0`). |
| `lines` | Integer | `1` | no | `1` or `2`. Clamps the label with an ellipsis. `2` top-aligns the row so a wrapped label and the trailing slot share the first line. |
| `current` | Boolean | `false` | no | Marks the control with the neutral active surface (`.fp-button-current`), including a primary button. On a link, also sets `aria-current="page"`. |
| `title` | String, nil | `nil` | no | Full label for the tooltip when `lines` clamps the visible text. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes/classes/data/aria. |

## Slots
| name | description |
| --- | --- |
| `trailing` | Fixed-width content at the end of the button (`shrink-0`). A `FlatPack::Badge::Component` with `size: :sm`, or an icon. Set with `with_trailing`. Not supported on icon-only buttons. |

## Variants
- Built-in styles: `:default`, `:primary`, `:secondary`, `:ghost`, `:success`, `:warning`, `:danger`
- Host-registered styles: any name added with `FlatPack::Button.register_style`
- Sizes: `:sm`, `:md`, `:lg`. Icon-only also accepts `:xs`.
- Round: `round: true` for a pill label or a circular icon-only button. Omit it for the theme corner.
- Render modes: button mode (`type`) and link mode (`href`, optional `method`, optional `target`)
- States: loading, disabled (`disabled: true`), icon + text, icon-only, current (`current: true`)
- Icon artwork: a Heroicon name (omit `icon_variant` for the host default, or `:outline`, `:solid`, `:mini`, `:micro`), or a trusted `<svg` string
- Icon colour: omit `icon_style` (button text), or `:primary`, `:success`, `:warning`, `:danger`
- Label alignment: `:center` (default), `:start`
- Label lines: `1` (default), `2`

## Host-registered styles
The seven built-in styles are kit-owned. Do not override `--color-primary` (or other theme tokens) to recolour one button. Register a style to recolour one button. A host or third-party gem registers a named colourway, then paints it with local `--fp-button-*` tokens.

A wrapper is a region brand. Set `--color-primary` and `--color-primary-text` on it. Primary button rest, text, border, hover, and pressed follow. Hover mixes that colour 88% toward black on a light page, and toward white in dark. Pressed mixes at 80%. Saturated colours also lose chroma. `--button-primary-hover-background-color` wins when it is set. Then `--color-primary-hover`. Then the mix. Ocean keeps hover at `oklch(0.42 0.18 220)` unless the wrapper sets `--color-primary-hover`. Set `--color-primary-text` with the brand colour and check AA contrast. White text fails on a light brand such as yellow. CSS cannot pick the text colour. The focus ring stays `--color-ring`, which follows the page `--color-primary` and does not follow the wrapper.

Ruby (initializer or gem engine):

```ruby
FlatPack::Button.register_style(:partner, press: :raised)
```

`press:` is `:raised` (default, shadowed like primary) or `:flat` (inset press like ghost and secondary). Size, radius, focus ring, disabled opacity, and loading stay kit.

CSS loaded after `flat_pack/application`:

```css
[data-fp-style="partner"] {
  --fp-button-background: #635bff;
  --fp-button-hover-background: #0a2540;
  --fp-button-text: #ffffff;
  --fp-button-border: #635bff;
}
```

```erb
<%= render FlatPack::Button::Component.new(text: "Manage billing", style: :partner) %>
```

The button sets `data-fp-style` to the style name. Slot assignment is `[data-fp-style]`. `.fp-button` is still the chrome. Built-in primary reads `--button-primary-*` when a host or the hero overlay sets those pins, and otherwise follows the wrapper `--color-primary` and `--color-primary-text`. Hero press uses the hero hover token. A registered style sets `--fp-button-*` directly and does not change the page theme.

A pill group uses the same `[data-fp-style]` rule. Omitting `style:` leaves the active pill on `--tabs-pill-active-*` (the neutral active surface, no shadow) and does not set `data-fp-style`. Any named style, including `:primary`, adds `fp-pill-button-slots`. That class copies the button slots onto the active pill and restores `--tabs-pill-active-shadow` to `--shadow-md`. A selector that only matches `.fp-button[data-fp-style="partner"]` still paints buttons. Those pill groups need the slots class, which a named pill `style:` adds.

Do not register over a built-in name. Names are a lowercase letter, then letters, numbers, or underscores. Vendor colours (Stripe, Paddle, and the rest) belong in the host or billing gem CSS, not in FlatPack.

The dummy demo registers `:partner` in `config/initializers/flat_pack.rb` and paints it in the host stylesheet. See `/demo/buttons`.

## Pill Group Variant
Use `FlatPack::Button::Pill::Component` when you need the rounded pills styling from the tabs demo as a grouped set of plain link controls for filters, view switches, or segmented navigation outside a tablist.

### Pill Group Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `items` | Array<Hash> | none | yes | One or more pill definitions. Each item requires `text` and `href`, and may include `id`, `active`, `target`, `class`, `data`, and `aria`. |
| `size` | Symbol | `:md` | no | Padding/text density: `:sm`, `:md`, `:lg` (shared with Tabs via Button size tokens). |
| `style` | Symbol | omitted | no | Active pill colour. Same names as Button `style` above. Omit it for the neutral active surface. `:primary` and every other name use that button colour on the active pill. |
| `indicator` | Symbol | `nil` | no | Omit for today’s instant active swap. `:slide` renders one filled marker that follows the active pill, then follows the link. Unknown names raise `ArgumentError`. |
| `track` | Boolean | `false` | no | `true` draws a group border (`--tabs-pill-list-border-color`), a track fill (`--tabs-pill-list-background-color`, transparent), and inner padding (`--pill-padding`). The corner stays `--tabs-pill-corner-radius`. Omit it and the row is flush with the content. Anything other than `true` or `false` raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes/classes/data/aria for the outer group wrapper. |

```erb
<%= render FlatPack::Button::Pill::Component.new(
  items: [
    {text: "All products", href: products_path, active: true, id: "products-pill"},
    {text: "On sale", href: sale_products_path}
  ]
) %>
```

The active pill is the neutral active surface until you pass `style:`. Pass `style: :primary` for a brand fill, or another Button style for that colour.

```erb
<%= render FlatPack::Button::Pill::Component.new(
  style: :default,
  items: [
    {text: "All products", href: products_path, active: true},
    {text: "On sale", href: sale_products_path}
  ]
) %>
```

Pass `indicator: :slide` for a sliding fill. Items keep text colour. A normal left click slides first (~200ms), then visits with `Turbo.visit` when Turbo is present. Modifier clicks, middle-click, and `target: :_blank` go straight to the link. `prefers-reduced-motion` skips the wait. The marker measures from inside the group border, so it still sits on the active pill when `track: true`.

Pass `track: true` when the row should read as a bordered group. The default is flush: no group padding, no border, and no track fill.

```erb
<%= render FlatPack::Button::Pill::Component.new(
  indicator: :slide,
  items: [
    {text: "All products", href: products_path, active: true},
    {text: "On sale", href: sale_products_path}
  ]
) %>
```

```erb
<%= render FlatPack::Button::Pill::Component.new(
  track: true,
  indicator: :slide,
  items: [
    {text: "All products", href: products_path, active: true},
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

```erb
<%= render FlatPack::Button::Component.new(
  text: "Save",
  style: :primary,
  disabled: true
) %>
```

```erb
<%= render FlatPack::Button::Component.new(
  text: "Open",
  href: post_path(@post),
  disabled: true
) %>
```

A host logo belongs in `icon:` as trusted SVG, not in the trailing slot.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Google",
  icon: %(<svg viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="8"></circle></svg>)
) %>
```

`:xs` is the press-kit overlay size. The glyph stays 1rem. The painted control is about 32px. The tap target stays 44px. Leave about 12px between two of them.

```erb
<%= render FlatPack::Button::Component.new(
  icon: "heart",
  icon_only: true,
  round: true,
  size: :xs,
  aria: { label: "Save" }
) %>
```

A default button can carry a solid status glyph. The green comes from `--button-icon-success-color`. It still follows the label when the button itself is `:success`, and a disabled button fades the icon with the label.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Published",
  icon: "check-circle",
  icon_variant: :solid,
  icon_style: :success
) %>
```

A menu row leaves the label at the start, clamps it to two lines, and parks a count at the end. `current: true` on a link sets `aria-current="page"`. See [Collection](collection.md) for the press-kit grid.

```erb
<%= render FlatPack::Button::Component.new(
  text: "Logos and lockups for print, screen, and social",
  title: "Logos and lockups for print, screen, and social",
  href: "/press/logos",
  icon: "swatch",
  align: :start,
  lines: 2,
  current: true
) do |button| %>
  <% button.with_trailing do %>
    <%= render FlatPack::Badge::Component.new(text: "12", size: :sm) %>
  <% end %>
<% end %>
```

## Collapsing button group
`menu_row` is the menu form used by [Button Group](button-group.md). `collapse: :menu` uses it in the phone menu. An overflow menu uses it for each child that did not stay in the row. It is a plain left-aligned row with the label, `href`, and icon. `style: :danger` is red text, not a red fill. Other styles drop their fill. The wide control is still `call`, and it keeps `id` and `class`. `menu_row` forwards other attributes, including `data` and `aria`, and omits `id`.

## Touch
Buttons, links rendered as buttons, and pill items include `.fp-touch-manipulation` (`touch-action: manipulation`) so taps are not delayed by double-tap zoom. Icon-only controls also get that from `.fp-hit-target`. Kit CSS does not set a host-wide `button {}` rule.

## Accessibility
- Icon-only buttons must have an accessible name: `text:` (used as `aria-label`, not shown) or `aria: { label: "Open settings" }`. Missing a name raises `ArgumentError`.
- Leading Heroicons render through `FlatPack::Shared::IconComponent` and stay `aria-hidden="true"`. `icon_variant` selects the Heroicon weight. `icon_style` colours that glyph only. A trusted `<svg` string on `icon:` is painted as markup (not escaped) inside an `aria-hidden` box the same size as a Heroicon. The trailing slot is unchanged. Do not pass user input as `icon:`.
- Loading icon-only buttons keep that name and set `aria-busy="true"`.
- `current: true` paints `--surface-active-background-color`, `--surface-active-text-color`, and `--surface-active-border-color`, including on `style: :primary`. Hover and press stay on that fill. On a link it also sets `aria-current="page"`. A button without `href` gets the same current look and does not set `aria-current`.
- Focus ring styles stay on for keyboard navigation, including the current control. The ring is `focus-visible`, inset, and uses `--button-focus-ring-color`.
- In loading state, the button is disabled to prevent duplicate actions. The spinner is `FlatPack::Spinner::Component` with `label: nil` (decorative).
- `disabled: true` is the rest state for a control that must not be used. It does not show the spinner. Native buttons use the `disabled` attribute. Link buttons keep `href`, set `aria-disabled="true"`, and leave the tab order (`tabindex="-1"`). Both reuse the loading muted opacity.
- Colour, border, and shadow ease on `--duration-fast` / `--easing-standard`. Press is a 1px `translateY` on `.fp-button`, not a scale. Raised styles use `.fp-button-raised`. Ghost, secondary, and `press: :flat` use `.fp-button-flat` for an inset shadow on press. Slot assignment is `[data-fp-style]`. `.fp-button` is still the chrome. Colour does not come from per-style Tailwind background classes.

## Unsaved changes
A save button can switch between `:default` and `:primary` while the form is edited. The form controller owns that state. The button stays a normal button and only its `data-fp-style` changes. See [Unsaved changes](../behaviours/unsaved-changes.md).

## Dependencies
- `FlatPack::Spinner::Component` for the loading mark.
- `FlatPack::Shared::IconComponent` for icon and spinner sizing.
- `FlatPack::AttributeSanitizer` for URL sanitization and protocol allowlisting (`http`, `https`, `mailto`, `tel`, relative URLs).
- Sliding pill groups (`indicator: :slide`) use Stimulus controller `flat-pack--slide-indicator`.
