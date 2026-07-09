# Tree

## Purpose
Render expandable hierarchical trees for folder explorers, nested navigation, and structured parent-child content.

## When to use
Use Tree when users need to scan and expand nested relationships such as file systems, documentation sidebars, or grouped settings sections.

## Class
- Primary: `FlatPack::Tree::Component`

## Props
`FlatPack::Tree::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `compact` | Boolean | `false` | no | Uses tighter vertical row spacing for dense explorer-style trees. |
| `guides` | Boolean | `true` | no | Shows or hides the vertical guide lines between nested groups. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the tree wrapper (`role="tree"`). |

`tree.node(...)` builder arguments:

| name | type | default | required | description |
|---|---|---|---|---|
| `label` | String | `nil` | yes | Visible text label for the node. |
| `href` | String | `nil` | no | Optional link URL for leaf nodes. Unsafe URLs raise `ArgumentError`. |
| `icon` | Symbol/String | auto | no | Optional shared icon name. Defaults to folder for branches and document text for leaves. |
| `expanded` | Boolean | `false` | no | Starts branch nodes open when true. Ignored for leaf nodes. |
| `active` | Boolean | `false` | no | Applies the active row state and selection styling. |
| `meta` | String | `nil` | no | Optional trailing helper text, count, or status label. |
| `**system_arguments` | Hash | `{}` | no | Extra HTML attributes merged onto the rendered row. |

## Slots
- The component uses a nested builder DSL via `tree.node(...) do |node| ... end`.
- Nest additional `node.node(...)` calls inside a parent block to create child groups.

## Variants
- Standard or dense layout via `compact`.
- Guide lines on or off via `guides`.
- Branch nodes with nested children or leaf nodes with optional links.

## Example
```erb
<%= render FlatPack::Tree::Component.new(compact: true) do |tree| %>
  <% tree.node(label: "src", expanded: true) do |src| %>
    <% src.node(label: "components", expanded: true) do |components| %>
      <% components.node(label: "Button.tsx") %>
      <% components.node(label: "Card.tsx") %>
    <% end %>

    <% src.node(label: "App.js", active: true) %>
  <% end %>

  <% tree.node(label: "package.json") %>
<% end %>
```

## Accessibility
- The wrapper renders with `role="tree"`.
- Branch and leaf rows render with `role="treeitem"` and selection state.
- Nested containers render with `role="group"`.
- Interactive links remain keyboard-focusable when `href` is provided.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).