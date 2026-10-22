# Page Nav

## Purpose
Render a row of page actions in the order the host calls them. The component has no zones and no default order. `flat_pack_page_nav` and the generated sidebar layout supply the usual back control so a view with no items still looks the same.

## When to use
Use Page Nav when the layout needs a short row of icon actions at the top of a page. Go back, jump to another section, close, or run a custom action. Put them in the order that page needs. Registered page buttons use `register_page_nav` and `render_page_nav`. See [Page nav registry](page-nav-registry.md).

## Class
- `FlatPack::PageNav::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `round` | Boolean | `false` | no | Passed to every button the building blocks render (`with_back`, `with_close`, `with_link`, and `with_action`) as `FlatPack::Button::Component`'s `round:`. `with_item` content is left alone. No new tokens. |
| `style` | Symbol | `:secondary` | no | Button style for building blocks that do not pass their own `style:`. |
| `size` | Symbol | `:md` | no | Button size for building blocks that do not pass their own `size:`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes and classes for the wrapper nav element. |

`show_back:`, `right_slot`, `back_href:`, `anchor_href:`, `back_label`, `anchor_label`, and `secondary_anchor_*` are not component arguments. Passing one raises `ArgumentError` (`unknown keyword: :name`). There is no alias.

## Items
Call these on the component, in the order they should appear. The row is one `flex items-center gap-2` container. It stays one line. Gap uses the existing `gap-2` utility. There is no trailing zone and no `ml-auto`. Inside a Top Nav, the row folds into the hamburger menu with the rest of that bar on a phone. The open menu lists each action on its own row. A dropdown stays a parent row and discloses its items, indented, under that row.

- `with_item { ... }`: Arbitrary content at this position. `round:` does not restyle it.
- `with_back(href: nil, icon: nil, tooltip: nil, fallback_url: nil, style: nil, size: nil)`: History button when `href` is blank. The nav then carries `data-controller="flat-pack--page-nav"`. `fallback_url` sets `data-flat-pack--page-nav-fallback-url-value` for that history button. A present `href` renders a link and does not attach the controller. `FlatPack::Button::Component` sanitizes `href`. The default icon is `chevron-left`. The default tooltip is `flatpack.page_nav.back` ("Go back").
- `with_close(href:, icon: nil, tooltip: nil, style: nil, size: nil)`: Icon link. A blank `href` raises `ArgumentError`. The default icon is `x-mark`. The default tooltip is `flatpack.page_nav.close` ("Close").
- `with_link(href:, icon:, tooltip:, style: nil, size: nil)`: Icon link. `href`, `icon`, and `tooltip` are required. The tooltip is the accessible name. This is not breadcrumbs.
- `with_action(**button_arguments, &block)`: A `FlatPack::Button::Component` at this position. The nav's `round:` is passed through and wins over a `round:` on the action.

An empty item list renders the nav chrome and no controls.

## Variants
- Empty row
- History back (`with_back`)
- Back link (`with_back(href:)`)
- Round buttons (`round: true`)
- Any order of back, links, close, and action

## Example
```erb
<%= render FlatPack::PageNav::Component.new(round: true) do |nav| %>
  <% nav.with_back %>
  <% nav.with_link(href: demo_forms_path, icon: "home", tooltip: "Home") %>
  <% nav.with_link(href: demo_page_header_path, icon: "squares-2x2", tooltip: "Admin") %>
  <% nav.with_close(href: demo_path, tooltip: "Close") %>
<% end %>
```

```erb
<%= render FlatPack::PageNav::Component.new(round: true) do |nav| %>
  <% nav.with_back %>
  <% nav.with_action(
    icon: "plus",
    icon_only: true,
    href: demo_forms_path,
    aria: { label: "Add" }
  ) %>
<% end %>
```

## Accessibility
- Wrapper renders `nav[aria-label="Page navigation"]`.
- Icon-only controls include an explicit `aria-label`. For back, close, and link, that label is the tooltip.
- A history `with_back` is a button. The nav carries `data-controller="flat-pack--page-nav"` only when at least one history back is present. `fallback_url` sets `data-flat-pack--page-nav-fallback-url-value`. The click calls `history.back` when `history.length` is greater than 1 and the referrer is empty or same-origin. Otherwise it assigns the fallback href when one exists. With no fallback href, it calls `history.back`.
- `with_back(href:)` is a link. That link has no page-nav click action.
- Omit `with_back` when the row should not go back.
- `with_close` and `with_link` are links.

## Migration

### `show_back:`

`show_back:` is gone. There is no alias.

Before:

```erb
<%= render FlatPack::PageNav::Component.new(show_back: false, anchor_href: close_path) %>
```

After:

```erb
<%= render FlatPack::PageNav::Component.new do |nav| %>
  <% nav.with_close(href: close_path) %>
<% end %>
```

Skip `with_back` when the row has no back control. There is no alias.

### `right_slot`

`right_slot` is gone. There is no alias.

Before:

```erb
<%= render FlatPack::PageNav::Component.new do |nav| %>
  <% nav.right_slot do %>
    <%= render FlatPack::Button::Component.new(
      icon: "plus",
      icon_only: true,
      href: new_path,
      aria: { label: "Add" }
    ) %>
  <% end %>
<% end %>
```

After:

```erb
<%= render FlatPack::PageNav::Component.new do |nav| %>
  <% nav.with_back %>
  <% nav.with_action(icon: "plus", icon_only: true, href: new_path, aria: { label: "Add" }) %>
<% end %>
```

Call `with_action` at the position you want. The component does not push it to the end. There is no alias.

### `secondary_anchor_*`

`secondary_anchor_href`, `secondary_anchor_icon`, and `secondary_anchor_tooltip` are gone. This is a breaking change for hosts using `secondary_anchor_*`.

Before:

```erb
<%= render FlatPack::PageNav::Component.new(
  secondary_anchor_href: admin_path,
  secondary_anchor_icon: "home",
  secondary_anchor_tooltip: "Home"
) %>
```

After:

```erb
<%= render FlatPack::PageNav::Component.new do |nav| %>
  <% nav.with_back %>
  <% nav.with_link(href: admin_path, icon: "home", tooltip: "Home") %>
<% end %>
```

`href` was `secondary_anchor_href`. `icon` was `secondary_anchor_icon` (`"chevron-left"` when you omitted it). `tooltip` was `secondary_anchor_tooltip`. A blank tooltip no longer falls back to "Previous page". Pass `tooltip:`. `flatpack.page_nav.previous` is no longer read. There is no alias.

### `back_label` and `anchor_label`

`back_label` and `anchor_label` are gone. Pass `tooltip:` to `with_back` or `with_close`. There is no alias.

### Direct `PageNav::Component.new`

A component with no item calls renders an empty row. The history back button is no longer implicit. Call `with_back`, or use `flat_pack_page_nav` with no block.

`back_href:` on the component is gone. Pass `href:` to `with_back`. `anchor_href:` on the component is gone. Pass `href:` to `with_close`. The helper still accepts `back_href:` and `anchor_href:` for the default arrangement.

## Helpers

`FlatPack::PageNavHelper` is registered on views.

`flat_pack_page_nav(**kwargs, &block)` stores a `FlatPack::PageNav::Spec` at `request.env["flat_pack.page_nav"]`. The last call replaces the previous one. A call with no arguments still stores a spec, and the layout renders the default history back button. The method returns nil.

Unknown keys raise `ArgumentError`. `show_back`, `right_slot`, `back_label`, `anchor_label`, and `secondary_anchor_*` raise `unknown keyword: :name`.

Component keys are `round`, `style`, `size`, `class`, `id`, `data`, and `aria`. Arrangement keys for the default row are `back_href`, `back_icon`, `back_tooltip`, `back_style`, `back_size`, `anchor_href`, `anchor_icon`, `anchor_tooltip`, `anchor_style`, and `anchor_size`.

With no block, the tag renders `with_back` and, when `anchor_href` is present, `with_close`. `back_href` becomes the back link. `anchor_href` is also the history back `fallback_url`. A block replaces that default. Call `with_back`, `with_close`, `with_link`, `with_action`, and `with_item` in the order you want. A block does not gain a close control when `return_to` fills a blank anchor. The filled anchor is still used by `flat_pack_return_to_url` and `flat_pack_return_to_field`.

```erb
<% flat_pack_page_nav(round: true) do |nav| %>
  <% nav.with_back %>
  <% nav.with_link(href: demo_forms_path, icon: "home", tooltip: "Home") %>
  <% nav.with_link(href: demo_page_header_path, icon: "squares-2x2", tooltip: "Admin") %>
  <% nav.with_close(href: demo_path, tooltip: "Close") %>
<% end %>
```

`flat_pack_page_nav_tag` renders `FlatPack::PageNav::Component` from the resolved spec. A non-blank `anchor_href` from the view wins. A valid `return_to` fills `anchor_href` only when the view did not set one. The tag returns nil when the view did not call `flat_pack_page_nav` and there is no valid `return_to`.

`flat_pack_return_to_url(path)` appends that resolved anchor as the `return_to` query parameter. An existing `return_to` on `path` is replaced. Other query parameters stay. `path` is unchanged when there is no anchor. The method does not append the current request path.

`flat_pack_return_to_field` renders a hidden `return_to` field with that anchor, or nil when there is no anchor.

Call `flat_pack_page_nav` in the view. Call `flat_pack_page_nav_tag` in the layout, where the row should appear. `rails generate flat_pack:layout` writes that tag into the sidebar layout, above `yield`.

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
- `FlatPack::Button::Component` for icon buttons, actions, and URL sanitization.
- `FlatPack::Tooltip::Component` for back, close, and link tooltips.
- `flat-pack--page-nav` Stimulus controller for browser history back behavior.
- The default back icon is `chevron-left`. `IconComponent` marks that name as directional so it flips in `[dir="rtl"]`. Links use the icon you pass.
