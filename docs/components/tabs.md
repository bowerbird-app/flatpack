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
| `**system_arguments` | Hash | `{}` | no | HTML attributes for root wrapper. |

## Slots
None (content is defined through component builder methods).

## Variants
- `:underline` horizontal underline tabs.
- `:pills` pill-style horizontal tabs.
- `:stacked` vertical tab list with side-by-side layout on medium+ breakpoints.

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

## Accessibility
- Renders ARIA tab semantics: `tablist`, `tab`, and `tabpanel`.
- Sets tab orientation metadata (`horizontal` or `vertical`) for controller behavior.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--tabs`.
