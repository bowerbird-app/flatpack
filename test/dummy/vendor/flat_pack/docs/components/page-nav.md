# Page Nav

## Purpose
Render a compact icon-only page navigation row with a browser-history back control, an optional close link, optional middle icon links, and an optional trailing action.

## When to use
Use Page Nav when the layout needs quick icon actions at the top of a page: go back, jump to another section, close, and a custom trailing action (for example add).

## Class
- `FlatPack::PageNav::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `back_icon` | String | `"chevron-left"` | no | Icon name for the back button. |
| `back_tooltip` | String, nil | `nil` | no | Tooltip and accessible label for the back icon button. Takes precedence over `back_label`. |
| `back_label` | String | `"Go back"` | no | Deprecated fallback for `back_tooltip`. |
| `back_style` | Symbol | `:secondary` | no | Button style for back action. |
| `back_size` | Symbol | `:md` | no | Button size for back action. |
| `show_back` | Boolean | `true` | no | When false, the back control is omitted and the empty left wrapper is omitted. |
| `back_href` | String, nil | `nil` | no | When `show_back` is true and this is present, the back control is a link to this URL. The page-nav controller is not rendered. `FlatPack::Button::Component` still sanitizes the URL. |
| `round` | Boolean | `false` | no | Passed to every button this nav renders (`back`, close, and each `with_link`). `true` uses `FlatPack::Button::Component`'s `round:`. `false` keeps the button's normal radius. Does not restyle `right_slot` content. No new tokens. |
| `anchor_href` | String, nil | `nil` | no | When present, renders the close icon as a link. |
| `anchor_icon` | String | `"x-mark"` | no | Icon name for anchor action. |
| `anchor_tooltip` | String, nil | `nil` | no | Tooltip and accessible label for primary anchor action. Takes precedence over `anchor_label`. |
| `anchor_label` | String | `"Close"` | no | Deprecated fallback for `anchor_tooltip`. |
| `anchor_style` | Symbol | `:secondary` | no | Button style for anchor action. |
| `anchor_size` | Symbol | `:md` | no | Button size for anchor action. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes and classes for the wrapper nav element. |

## Slots
- `with_link(href:, icon:, tooltip:)`: Icon-only link in the middle of the row, after the back and close controls and before `right_slot`. Call it once per link. `tooltip` is the tooltip and the `aria-label`. The link uses `anchor_style`, `anchor_size`, and `round`. `FlatPack::Button::Component` sanitizes `href`. With no links, that wrapper is omitted and the markup matches a nav that never called `with_link`. This is not breadcrumbs.
- `right_slot`: Custom content on the trailing side of the row. `round` does not pass through. Set `round:` on those buttons yourself.

## Variants
- Back only (default)
- Back hidden (`show_back: false`)
- Back link (`back_href`)
- Round buttons (`round: true`)
- Back + close (`anchor_href`)
- Back + close + middle links (`with_link`)
- Back + trailing action (`right_slot`)
- Back + close + trailing action (`anchor_href` and `right_slot`)

## Example
```erb
<%= render FlatPack::PageNav::Component.new(
  round: true,
  anchor_href: demo_path,
  anchor_tooltip: "Close"
) do |nav| %>
  <% nav.with_link(href: demo_forms_path, icon: "home", tooltip: "Home") %>
  <% nav.with_link(href: demo_page_header_path, icon: "squares-2x2", tooltip: "Admin") %>
  <% nav.right_slot do %>
    <%= render FlatPack::Button::Component.new(
      icon: "plus",
      icon_only: true,
      round: true,
      href: demo_forms_path,
      aria: { label: "Add" }
    ) %>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::PageNav::Component.new(
  anchor_href: demo_path
) do |component| %>
  <% component.right_slot do %>
    <%= render FlatPack::Button::Dropdown::Component.new(
      text: "",
      icon: "ellipsis-vertical",
      style: :ghost,
      size: :sm,
      show_chevron: false,
      trigger_attributes: {
        title: "More actions",
        aria: { label: "More actions" }
      }
    ) do |dropdown| %>
      <% dropdown.menu_item(text: "Edit", href: demo_forms_path) %>
      <% dropdown.menu_item(text: "Archive", href: demo_path) %>
    <% end %>
  <% end %>
<% end %>
```

## Accessibility
- Wrapper renders `nav[aria-label="Page navigation"]`.
- Icon-only controls include explicit `aria-label` values sourced from tooltip props or deprecated label fallbacks.
- Back action uses a button when `show_back` is true and `back_href` is omitted. The nav carries `data-controller="flat-pack--page-nav"` only for that button. When `anchor_href` is also set, `data-flat-pack--page-nav-fallback-url-value` is that href. The click calls `history.back` when `history.length` is greater than 1 and the referrer is empty or same-origin. Otherwise it assigns the fallback href when one exists. With no fallback href, it calls `history.back`.
- Back action is a link when `back_href` is present. That link has no page-nav click action.
- Back action is omitted when `show_back` is false.
- The close control is a link when `anchor_href` is provided.
- Each `with_link` is a link. The tooltip text is the accessible name.
- Right-side behavior is defined by the consumer via `right_slot` content.

## Migration

### Page Nav tooltip prop rename

Page Nav now uses tooltip-specific prop names for URL actions.

| Deprecated | Use instead |
| --- | --- |
| `back_label` | `back_tooltip` |
| `anchor_label` | `anchor_tooltip` |

Deprecated props continue to work as fallback values. When both old and new props are provided, the new tooltip prop wins.

`flat_pack_page_nav` does not accept `back_label` or `anchor_label`. Pass `back_tooltip` and `anchor_tooltip`.

### Middle links replace `secondary_anchor_*`

`secondary_anchor_href`, `secondary_anchor_icon`, and `secondary_anchor_tooltip` are gone. This is a breaking change for hosts using `secondary_anchor_*`.

Move one secondary anchor into one `with_link` call:

```erb
<%= render FlatPack::PageNav::Component.new(anchor_href: close_path, anchor_tooltip: "Close") do |nav| %>
  <% nav.with_link(href: admin_path, icon: "home", tooltip: "Home") %>
<% end %>
```

`href` was `secondary_anchor_href`. `icon` was `secondary_anchor_icon` (`"chevron-left"` when you omitted it). `tooltip` was `secondary_anchor_tooltip`. A blank tooltip no longer falls back to "Previous page". Pass `tooltip:`. The link uses `anchor_style`, `anchor_size`, and `round`. It renders after the close control and before the trailing action. There is no alias.

## Helpers

`FlatPack::PageNavHelper` is registered on views.

`flat_pack_page_nav(**kwargs, &block)` stores a `FlatPack::PageNav::Spec` at `request.env["flat_pack.page_nav"]`. The last call replaces the previous one. A call with no arguments still stores a spec, and the layout renders the default back button. The method returns nil. Unknown keys raise `ArgumentError`. `back_label` and `anchor_label` raise `ArgumentError`. `secondary_anchor_href`, `secondary_anchor_icon`, and `secondary_anchor_tooltip` raise `ArgumentError`.

Allowed keys are the keyword parameters of `FlatPack::PageNav::Component#initialize`, except `back_label` and `anchor_label`, plus `class`, `id`, `data`, and `aria`. `round:` is one of those keys.

The block receives the spec. Call `with_link(href:, icon:, tooltip:)` once per middle icon. `flat_pack_page_nav_tag` renders those links on the component. With no links, the tag renders the component with no link block.

```erb
<% flat_pack_page_nav(round: true, anchor_href: demo_path, anchor_tooltip: "Close") do |nav| %>
  <% nav.with_link(href: demo_forms_path, icon: "home", tooltip: "Home") %>
  <% nav.with_link(href: demo_page_header_path, icon: "squares-2x2", tooltip: "Admin") %>
<% end %>
```

`flat_pack_page_nav_tag` renders `FlatPack::PageNav::Component` from the resolved spec. A non-blank `anchor_href` from the view wins. A valid `return_to` fills `anchor_href` only when the view did not set one. The tag returns nil when the view did not call `flat_pack_page_nav` and there is no valid `return_to`.

`flat_pack_return_to_url(path)` appends that resolved anchor as the `return_to` query parameter. An existing `return_to` on `path` is replaced. Other query parameters stay. `path` is unchanged when there is no anchor. The method does not append the current request path.

`flat_pack_return_to_field` renders a hidden `return_to` field with that anchor, or nil when there is no anchor.

Call `flat_pack_page_nav` in the view. Call `flat_pack_page_nav_tag` in the layout, where the row should appear.

```erb
<% flat_pack_page_nav(anchor_href: demo_path, anchor_tooltip: "Close") %>
```

```erb
<% page_nav = flat_pack_page_nav_tag %>
<% if page_nav %>
  <div class="mb-4"><%= page_nav %></div>
<% end %>
```

## Return to

`FlatPack::ReturnTo` is a controller concern. The engine does not include it. Include it on the controller that should redirect.

`FlatPack::ReturnTo.origin_url` is the only method that passes `params[:return_to]` to `url_from`. A blank parameter returns nil. Rails returns nil when it rejects the URL, and the helpers do not check the host themselves. A protocol-relative URL, another host, a `javascript:` URL, a backslash host, an encoded host, and an empty value are ignored. A relative path and a same-host absolute URL are kept.

`flat_pack_return_to` returns that URL or nil.

`redirect_to_return_to(fallback:)` redirects to `flat_pack_return_to` when it is present, otherwise to `fallback`. A blank `fallback` raises `ArgumentError`. The method does nothing until the action calls it.

```ruby
class PageNavFlowController < ApplicationController
  include FlatPack::ReturnTo

  def create
    redirect_to_return_to(fallback: demo_page_nav_path)
  end
end
```

```erb
<%= render FlatPack::Button::Component.new(
  text: "Next",
  style: :primary,
  href: flat_pack_return_to_url(demo_page_nav_carry_next_path)
) %>

<%= form_with url: demo_page_nav_carry_path, method: :post do %>
  <%= flat_pack_return_to_field %>
  <%= render FlatPack::Button::Component.new(text: "Save and close", style: :primary, type: "submit") %>
<% end %>
```

## Dependencies
- `FlatPack::Button::Component` for icon-only button rendering and URL sanitization.
- `FlatPack::Tooltip::Component` for optional action tooltips.
- `flat-pack--page-nav` Stimulus controller for browser history back behavior.
- The default back icon is `chevron-left`. `IconComponent` marks that name as directional so it flips in `[dir="rtl"]`. Middle links use the icon you pass.
