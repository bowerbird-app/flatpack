# Menu Collapse

## Purpose
A labelled menu row that opens an indented group of rows in place.

## When to use
Use Menu Collapse wherever menu rows need a nested group that stays in the flow. Use it inside a menu, a collapsed button group, or any other stack of rows. Do not use it when the nested choices should float over the page. That is `FlatPack::Button::Dropdown::Component`. Do not use it for sidebar navigation. That is `FlatPack::Sidebar::Group::Component`.

## Class
- Primary: `FlatPack::Menu::Collapse::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `title` | String | none | Yes | Header label. |
| `icon` | String, Symbol, or nil | `nil` | No | Optional leading icon on the header. |
| `open` | Boolean | `false` | No | Initial open state. A menu does not persist this. |
| `**system_arguments` | Hash | `{}` | No | HTML attributes merged into the wrapper. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `items` | block slot | No | Free-form rows shown under the header. Links and buttons pick up the menu-row styles. |

## Variants

| variant | description |
|---------|-------------|
| `open: false` | Header only. The panel is hidden. |
| `open: true` | The panel is open on first paint. |
| `icon:` | A leading icon sits before the label. |

## Example

```erb
<%= render FlatPack::Menu::Collapse::Component.new(title: "Share", icon: "pencil") do |section| %>
  <% section.items do %>
    <%= link_to "Copy link", "#" %>
    <%= link_to "Email", "#" %>
  <% end %>
<% end %>
```

## Accessibility
The header is a `button` with `aria-expanded` and `aria-controls` pointing at the panel id. The chevron is decorative. The panel is hidden when closed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Open and close behavior requires Stimulus controller `flat-pack--menu-collapse`.
