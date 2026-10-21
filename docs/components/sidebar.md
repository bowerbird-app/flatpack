# Sidebar

## Purpose
Provide a composable sidebar container with optional header, items area, and footer regions.

The shell fill is `--sidebar-background-color`. On the default rounded palette that token is the page background, so the rail matches the page. The header fill is `--sidebar-header-background-color`, which aliases the sidebar token. Dark and ocean set their own sidebar fill. The aside width is `--sidebar-width` (`16rem`). [Sidebar Layout](sidebar_layout.md) `width: :content` replaces that on the open desktop rail. A detached desktop rail is `floating: true` on that same layout. That option uses `--sidebar-float-background-color` and does not change this component.

## When to use
Use Sidebar in application shells that need persistent navigation and grouped links.

## Class
- Primary: `FlatPack::Sidebar::Component`
- Related classes: `FlatPack::Sidebar::Item::Component`, `FlatPack::Sidebar::Header::Component`, `FlatPack::Sidebar::Footer::Component`, `FlatPack::Sidebar::Divider::Component`, `FlatPack::Sidebar::Group::Component`, `FlatPack::Sidebar::Badge::Component`, `FlatPack::Sidebar::CollapseToggle::Component`, `FlatPack::Sidebar::SectionTitle::Component`

## Props

Primary component (`FlatPack::Sidebar::Component`):

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `collapsed` | Boolean | `false` | No | `true` sets `data-flat-pack-sidebar-collapsed="true"` on the aside. `false` omits the attribute so a parent column can own it. The aside always has `data-controller="flat-pack--sidebar"`. |
| `collapsible` | Boolean | `true` | No | Signals whether collapse controls should be shown by composed header/toggle components. |
| `side` | Symbol | `:left` | No | Border side for the shell. Allowed: `:left`, `:right`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<aside>` wrapper. |

`FlatPack::Sidebar::Item::Component`:

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `text` | String | — | Yes | Menu item text. |
| `href` | String | — | Yes | Link destination URL. |
| `icon` | Symbol or nil | `nil` | No | Heroicons v2 icon name. |
| `active` | Boolean | `false` | No | Marks the item as the current page (`aria-current="page"`). |
| `collapsed` | Boolean | `false` | No | Static icon-only markup: compact padding (`px-1`) and centered alignment (`justify-center`). A live rail does not add those classes. The menu CSS fades the label from the column attribute, or from the menu's own attribute. |
| `badge` | String or nil | `nil` | No | Optional badge value rendered beside the label. |

`FlatPack::Sidebar::Header::Component`:

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `logo` | String or nil | `nil` | No | Image URL for the badge slot. A present URL renders the mark and omits `brand_abbr`. Blank keeps the initials path. |
| `brand_abbr` | String or nil | `"FP"` | No | Initials in the square badge. Blank or `nil` omits the badge. Omitted when `logo:` is present. |
| `title` | String | `"FlatPack"` | No | Title text beside the badge. |
| `subtitle` | String or nil | `nil` | No | Accepted. Not rendered. |
| `collapsible` | Boolean | `true` | No | Shows the collapse toggle buttons when `true`. |
| `show_version` | Boolean | `true` | No | Default `true` renders `v{FlatPack::VERSION}` beside the title. `false` omits the badge span. Product hosts pass `false` so the kit version badge does not ship. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the header wrapper. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `header` | block slot | No | Top area for brand, title, and controls. |
| `items` | block slot | No | Scrollable middle area for nav items and groups. |
| `footer` | block slot | No | Bottom area for profile/actions/meta content. |

## Variants

| variant | description |
|---------|-------------|
| `side: :left` | Renders right border (`border-r`). |
| `side: :right` | Renders left border (`border-l`). |
| Header `show_version: true` | Default. Renders `v{FlatPack::VERSION}` beside the title. |
| Header `show_version: false` | Omits the version badge span. |
| Header `logo:` present | Square mark in the badge slot. Title, collapse toggles, and `show_version` stay. |

## Example

```erb
<%= render FlatPack::Sidebar::Component.new(side: :left) do |sidebar| %>
  <% sidebar.header do %>
    <%= render FlatPack::Sidebar::Header::Component.new(
      brand_abbr: "AC",
      title: "Acme"
    ) %>
  <% end %>

  <% sidebar.items do %>
    <nav class="py-4 space-y-1">
      <%= render FlatPack::Sidebar::Item::Component.new(
        text: "Dashboard",
        href: "/dashboard",
        icon: :home,
        active: true
      ) %>
    </nav>
  <% end %>

  <% sidebar.footer do %>
    <%= render FlatPack::Sidebar::Footer::Component.new do %>
      Signed in as you@example.com
    <% end %>
  <% end %>
<% end %>
```

A product host that should not ship the kit version badge:

```erb
<%= render FlatPack::Sidebar::Header::Component.new(
  brand_abbr: "AC",
  title: "Acme",
  show_version: false
) %>
```

Pass `logo:` as a URL when the host has a square mark. Header shows that mark and omits `brand_abbr`. Blank `logo:` keeps initials. The default `content` block still replaces the whole header.

```erb
<%= render FlatPack::Sidebar::Header::Component.new(
  logo: url_for(current_site.logo),
  brand_abbr: "AC",
  title: "Acme",
  show_version: false
) %>
```

## Accessibility
`FlatPack::Sidebar::Item::Component` sets `aria-current="page"` for active links and sets `aria-label` when rendered in collapsed mode.

`flat-pack--sidebar` sets `aria-expanded` on the collapse and expand controls. Collapsed is `"false"`. Expanded is `"true"`. On connect it reads the nearest `[data-flat-pack-sidebar-collapsed]`, or the aside itself. It then listens on the column for `flat-pack--sidebar-layout:collapse`. A menu used alone has no column, so connect uses the aside attribute. The header starts with the collapse button at `aria-expanded="true"` (`Collapse sidebar`) and the expand button at `aria-expanded="false"` (`Open sidebar`). The controller corrects both after connect. `CollapseToggle` keeps `aria-expanded` from its `collapsed:` argument until connect.

A Header `logo:` mark is decorative when `title` is present (`alt=""`, `aria-hidden`). The title names the brand. The brand wrapper is `.fp-sidebar-brand`. The footer is `.fp-sidebar-footer`. The items scroller is `.fp-sidebar-scroll`. It uses `.fp-pane-scroll`, so the bar follows `--pane-scrollbar-width`. The scroller is in the tab order with the name "Sidebar". It is not a second landmark inside the nav.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- The menu controller is `flat-pack--sidebar`, pinned with the other controllers. Do not rerun `bin/rails generate flat_pack:install`.
- `FlatPack::Sidebar::Group::Component` interactive expand/collapse requires Stimulus controller `flat-pack--sidebar-group`.
- `FlatPack::Sidebar::Item::Component` collapsed tooltip behavior requires Stimulus controller `flat-pack--tooltip`.
