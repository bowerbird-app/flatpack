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
| `icon_variant` | Symbol, nil | `nil` | No | `:outline`, `:solid`, `:mini`, or `:micro` on that icon. Omit to use `default_icon_variant`. Unknown names raise `ArgumentError`. |
| `icon_style` | Symbol, nil | `nil` | No | `nil` inherits the row text. `:primary`, `:success`, `:warning`, or `:danger` use the button icon tokens. Unknown names raise `ArgumentError`. |
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
| `icon_variant:` / `icon_style:` | The header glyph uses the same artwork and colour as a button icon. A solid success `check-circle` is the usual “done” mark. |

## Example

```erb
<%= render FlatPack::Menu::Collapse::Component.new(title: "Share", icon: "pencil") do |section| %>
  <% section.items do %>
    <%= link_to "Copy link", "#" %>
    <%= link_to "Email", "#" %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::Menu::Collapse::Component.new(
  title: "Publish",
  icon: "check-circle",
  icon_variant: :solid,
  icon_style: :success
) do |section| %>
  <% section.items do %>
    <%= link_to "Publish now", "#" %>
  <% end %>
<% end %>
```

## Type
The header and the rows inside use `--type-control-size` and `--type-control-leading`. That is the same size as a dropdown item. The rules stay outside a CSS layer so they beat a host utility. They do not set a font weight.

## Accessibility
The header is a `button` with `aria-expanded` and `aria-controls` pointing at the panel id. The chevron is decorative. The panel is hidden when closed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Open and close behavior requires Stimulus controller `flat-pack--menu-collapse`.
