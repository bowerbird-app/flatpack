# Page Layout

## Purpose
Arrange a public page into a top bar, one column, and a footer.

## When to use
Use Page Layout for a page with no sidebar: a press kit, an article, a landing page, or a centered sign-in card. The host owns the words, the cards, and the photos. Use [Sidebar Layout](sidebar_layout.md) when the page needs a rail.

## Class
- Primary: `FlatPack::PageLayout::Component`
- Related classes: `FlatPack::TopNav::Component`, `FlatPack::Backdrop::Component`, `FlatPack::SidebarLayout::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `width` | Symbol | `:default` | No | Measure of the column. Allowed: `:narrow`, `:default`, `:wide`, `:full`. Reads `--page-layout-width-narrow` (`40rem`), `--page-layout-width-default` (`56rem`), `--page-layout-width-wide` (`72rem`), and `--page-layout-width-full` (`100%`). Anything else raises `ArgumentError`. Not a CSS length and not a class. |
| `align` | Symbol | `:top` | No | `:top` starts the column under the bar. `:center` centers it in the viewport, horizontally and vertically. Anything else raises `ArgumentError`. |
| `floating_top_nav` | Boolean | `false` | No | `false` keeps a full-width bar. `true` uses the same floating cards as Sidebar Layout. Anything else raises `ArgumentError`. |
| `content_scroll` | Symbol | `:behind` | No | Where the column sits when `floating_top_nav: true`. `:behind` lets the page scroll under the cards and pads with `--top-nav-float-clearance`. `:below` keeps the cards above the column. Ignored when the bar is not floating. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | No | HTML attributes merged into the root. `class` does not set the measure. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `top_nav` | block slot | No | Optional bar. A `TopNav` keeps its `<header>`. Other markup is wrapped in `<header>`. |
| content | block | No | The column. Rendered in `<main>`. |
| `footer` | block slot | No | Optional footer. Wrapped in `<footer>`. |
| `background` | block slot | No | Decorative photo (`img`, `picture`, or `video`) behind the page. Renders `FlatPack::Backdrop::Component` and pins it to the viewport, the same way Sidebar Layout does. |

## Variants

| variant | description |
|---------|-------------|
| `width: :narrow` | Column uses `--page-layout-width-narrow`. |
| `width: :default` | Column uses `--page-layout-width-default`. This is the default. |
| `width: :wide` | Column uses `--page-layout-width-wide`. |
| `width: :full` | Column fills the padded page. |
| `align: :top` | Column starts under the bar. This is the default. |
| `align: :center` | Column sits in the middle of the viewport. The bar stays at the top. The footer stays at the bottom. |
| `floating_top_nav: true` | The full-width bar becomes the shared floating cards. |
| `content_scroll: :below` | Those cards sit above the column. |
| `background` slot | Full-viewport photo behind the bar, the column, and the footer. |

## Example

```erb
<%= render FlatPack::PageLayout::Component.new(width: :default) do |layout| %>
  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new(mobile_menu: false) do |nav| %>
      <% nav.left { "Field notes" } %>
    <% end %>
  <% end %>

  <h1>Packing notes</h1>

  <% layout.footer do %>
    Field notes
  <% end %>
<% end %>
```

Center a sign-in card. Float the bar over a photo. Narrow the column for an article.

```erb
<%= render FlatPack::PageLayout::Component.new(width: :narrow, align: :center) do |layout| %>
  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new(mobile_menu: false) do |nav| %>
      <% nav.left { "Field notes" } %>
    <% end %>
  <% end %>

  <%= render FlatPack::Card::Component.new(padding: :lg) do %>
    <h1>Welcome back</h1>
  <% end %>
<% end %>
```

```erb
<%= render FlatPack::PageLayout::Component.new(width: :wide, floating_top_nav: true) do |layout| %>
  <% layout.background do %>
    <%= image_tag "/images/hero-packaging.jpg", alt: "" %>
  <% end %>

  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new(mobile_menu: false) do |nav| %>
      <% nav.left { "Field notes" } %>
    <% end %>
  <% end %>

  <h1>On the road</h1>
<% end %>
```

`floating_top_nav: true` paints the same cards as [Sidebar Layout](sidebar_layout.md). `TopNav` `left` and `center` are each one card. Each direct child of `right` is its own card. The fill, shadow, gap, and corner come from `--sidebar-float-background-color`, `--sidebar-float-shadow`, `--sidebar-float-inset`, and `--top-nav-float-radius`. The page sets `--layout-content-max-width` from the `width:` token and `--layout-content-inset` from `--page-layout-padding-inline`, so the cards share the column's edges.

The shell scrolls with the window. It does not lock a pane, store state, or read a cookie. The first paint is the finished page. Sidebar Layout's wrap measurement is not part of this shell. The window keeps its scrollbar. `--pane-scrollbar-width` does not apply here.

## Page nav
This shell does not read the page nav registry and does not place the buttons. Register the items, then call `page_nav_button_group` in the column where the row should sit. `SOLID` is the map for a public page (solid primary, subtle secondary, danger). `collapse: :menu` is the joined row from 768px up and a menu below that. A named bucket stays out unless `from:` names it. See [Page nav registry](page-nav-registry.md).

```erb
<% register_page_nav "New press kit", new_press_kit_path, role: :primary, icon: :plus %>
<div class="flex items-center justify-between gap-4">
  <h1 class="m-0">Press kit</h1>
  <%= page_nav_button_group(styles: FlatPack::PageNavRoleStyles::SOLID, collapse: :menu) %>
</div>
```

## Accessibility
The bar is a `<header>` (or the `<header>` from `TopNav`). The column is `<main>`. The footer slot is `<footer>`. The photo is decorative. `FlatPack::Backdrop::Component` marks it `aria-hidden="true"`. Pass `alt=""` on the image. Under `prefers-reduced-transparency: reduce`, or when `filter: blur()` is unavailable, the photo is hidden and the tint becomes solid.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- No Stimulus controller on this shell. A button group in the column with `collapse: :menu` uses `flat-pack--button-group-menu`.
- The floating bar is the shared Sidebar Layout top nav. It needs no extra controller to render.
- The `background` slot renders `FlatPack::Backdrop::Component`.
- Tokens: `--page-layout-width-narrow`, `--page-layout-width-default`, `--page-layout-width-wide`, `--page-layout-width-full`, `--page-layout-padding-inline` (`var(--space-4)`, then `var(--space-6)` from `640px`), `--page-layout-padding-block` (`var(--space-6)`), `--page-layout-gap` (`var(--space-6)`). The shell copies the chosen width onto `--page-layout-width`. That token is not in the theme file. Do not set it on `:root`. `[data-theme~="rounded"]` does not restate them. The larger `--space-*` steps on that theme make the padding generous. No token is tied to a photo colour. Floating cards also use `--top-nav-float-*` and `--sidebar-float-*`. The photo uses `--backdrop-*`.
