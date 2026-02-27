# Accordion

## Purpose
Render collapsible sections with optional single-open or multi-open behavior.

## When to use
Use Accordion when related content should be progressively disclosed in stacked sections.

## Class
- Primary: `FlatPack::Accordion::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `allow_multiple` | Boolean | `false` | no | Allows more than one item to stay open. |
| `single_open` | Boolean | `nil` | no | Alternate switch for one-open mode. When provided, overrides `allow_multiple` (`allow_multiple = !single_open`). |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for accordion container. |

`item(...)` builder args:

| name | type | default | required | description |
|---|---|---|---|---|
| `id` | String | `nil` | yes | Unique id used to derive content panel id (`<id>-content`). |
| `title` | String | `nil` | yes | Trigger label text. |
| `open` | Boolean | `false` | no | Initial expanded state. |

## Slots
None (items are added through the `item` builder method).

## Variants
- Single-open mode (default).
- Multi-open mode (`allow_multiple: true`).

## Example
```erb
<%= render FlatPack::Accordion::Component.new(allow_multiple: true) do |accordion| %>
  <% accordion.item(id: "faq-1", title: "What is FlatPack?", open: true) do %>
    <p>FlatPack is a ViewComponent library for Rails.</p>
  <% end %>

  <% accordion.item(id: "faq-2", title: "How do I install it?") do %>
    <p>Add the gem and run the install generator.</p>
  <% end %>
<% end %>
```

## Accessibility
- Trigger buttons expose `aria-expanded` and `aria-controls`.
- Content panels are linked by id and hidden when collapsed.
- Focus-visible ring styles are included on triggers.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--accordion`.
