# Tabs

## Purpose
Render interactive tab navigation with paired tab panels.

## When to use
Use Tabs when content can be split into a small number of peer sections in the same page region.

## Class
- Primary: `FlatPack::Tabs::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `default_tab` | Integer | `0` | no | Zero-based index of initially active tab/panel. |
| `variant` | Symbol | `:underline` | no | Visual style: `:underline`, `:pills`, `:stacked`. |
| `size` | Symbol | `:md` | no | Padding/text density: `:sm`, `:md`, `:lg` (shared with Button::Pill; invalid values raise). |
| `style` | Symbol | omitted | no | Colour of the active pill or stacked control. Omit it for the neutral active surface. A named [Button](button.md) `style`, including `:primary`, paints that button colour. Unknown names raise `ArgumentError`. Underline tabs ignore it. |
| `indicator` | Symbol | `nil` | no | Omit for today’s instant active swap. `:slide` renders one indicator that follows the selected tab. Unknown names raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for root wrapper. |

## Slots
None (content is defined through component builder methods).

## Variants
- `:underline` horizontal underline tabs. `style:` is accepted. Underline paint does not change.
- `:pills` pill-style horizontal tabs. Omit `style:` for the neutral active surface. A named style, including `:primary`, paints that button colour on the active control.
- `:stacked` vertical tab list with side-by-side layout on medium+ breakpoints. The track uses `--surface-hover-background-color` so the active pill reads darker. `style:` paints the active control the same way as pills.
- `indicator: :slide` is opt-in on every variant. Default markup stays the same. One marker follows the selected tab. Tabs keep only the text colour change. Motion is `--duration-base` / `--easing-standard`. `prefers-reduced-motion` snaps.

## Example
```erb
<%= render FlatPack::Tabs::Component.new(default_tab: 0, variant: :underline) do |tabs| %>
  <% tabs.tab(label: "Overview", id: "overview") do %>
    <p>Overview content</p>
  <% end %>

  <% tabs.tab(label: "Activity", id: "activity") do %>
    <p>Activity content</p>
  <% end %>
<% end %>
```

Pill and stacked tabs take the same `style:` names as Button. Omit `style:` for the neutral active surface. Pass `style: :primary` for the brand fill.

```erb
<%= render FlatPack::Tabs::Component.new(variant: :pills, style: :default) do |tabs| %>
  <% tabs.tab(label: "Overview", id: "overview") do %>
    <p>Overview content</p>
  <% end %>

  <% tabs.tab(label: "Activity", id: "activity") do %>
    <p>Activity content</p>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Tabs::Component.new(variant: :pills, indicator: :slide) do |tabs| %>
  <% tabs.tab(label: "Overview", id: "overview") do %>
    <p>Overview content</p>
  <% end %>
<% end %>
```

## Accessibility
- Renders ARIA tab semantics: `tablist`, `tab`, and `tabpanel`.
- Sets tab orientation metadata (`horizontal` or `vertical`) for controller behavior.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--tabs`.
- Sliding indicator: `flat-pack--slide-indicator` when `indicator: :slide`.
