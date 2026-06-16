# FlatPack Documentation

Welcome to FlatPack - a modern Rails UI Component Library built with ViewComponent, Tailwind CSS 4, and modern Rails conventions. Supports Rails 7.1 and above.

## Overview

FlatPack is a production-grade Rails Engine that provides a comprehensive set of UI components designed for rapid application development. It follows "The Rails Way" and integrates seamlessly with Rails 7.1+ applications.

For automated setup and external AI retrieval, start with [ai/README.md](ai/README.md) and [ai/install_contract.json](ai/install_contract.json), then fall back to [installation.md](installation.md) and the component docs for examples.

For the installed-gem contract in a host app, use:

```bash
bin/rake flat_pack:contract
bin/rake flat_pack:verify_install
```

## Table of Contents

### Getting Started
- [Installation Guide](installation.md)
- [DigitalOcean Deployment for the Dummy App](deployment_digitalocean.md)
- [AI Entry Point](ai/README.md)
- [AI Install Contract](ai/install_contract.json)
- [Quick Start](#quick-start)
- [Configuration](#configuration)

### Theming & Styling
- [Theming Guide](theming.md)
- [Custom Theming Guide](custom_theming.md)
- [Dark Mode](dark_mode.md)
- [CSS Variables](#css-variables)

### Security
- [Security Guide](security.md)
- [Security Policy](../SECURITY.md)

### Components
- [Components Index (Agent-First)](components/README.md)
- [Components Manifest (Machine-Readable)](components/manifest.yml)
- [Component Doc Format](components/DOC_FORMAT.md)
- [Alert Component](components/alert.md)
- [Avatar Component](components/avatar.md)
- [Avatar Group Component](components/avatar-group.md)
- [Badge Component](components/badge.md)
- [Bottom Nav Component](components/bottom-nav.md)
- [Breadcrumb Component](components/breadcrumb.md)
- [Button Component](components/button.md)
- [Button Dropdown Component](components/button-dropdown.md)
- [Button Group Component](components/button-group.md)
- [Card Component](components/card.md)
- [Carousel Component](components/carousel.md)
- [Chart Component](components/charts.md)
- [Chart Buttons Component](components/chart-buttons.md)
- [Chat Components](components/chat.md)
- [Chip Component](components/chips.md)
- [Code Block Component](components/code-block.md)
- [Collapse Component](components/collapse.md)
- [Comments Thread Component](components/comments-thread.md)
- [Comments Item Component](components/comments-item.md)
- [Comments Composer Component](components/comments-composer.md)
- [Comments Replies Component](components/comments-replies.md)
- [Comments Inline Input Component](components/comments-inline-input.md)
- [Content Editor Component](components/content-editor.md)
- [Date Range Input Component](components/date-range-input.md)
- [Empty State Component](components/empty-state.md)
- [Grid Component](components/grid.md)
- [Hero Component](components/hero.md)
- [Input Components](components/inputs.md)
- [Link Component](components/link.md)
- [List Component](components/list.md)
- [Modal Component](components/modal.md)
- [Modal Filter Component](components/modal-filter.md)
- [Navbar Component](components/navbar.md)
- [Page Header Component](components/page-header.md)
- [Page Nav Component](components/page-nav.md)
- [Page Title Component](components/page-title.md)
- [Pagination Component](components/pagination.md)
- [Pagination Infinite Component](components/pagination-infinite.md)
- [Picker Component](components/picker.md)
- [Popover Component](components/popover.md)
- [Progress Component](components/progress.md)
- [Quote Component](components/quote.md)
- [Range Input Component](components/range-input.md)
- [Search Component](components/search.md)
- [Section Title Component](components/section-title.md)
- [Segmented Buttons Component](components/segmented-buttons.md)
- [Sidebar Component](components/sidebar.md)
- [Sidebar Group Component](components/sidebar_group.md)
- [Sidebar Layout Component](components/sidebar_layout.md)
- [Sidebar Section Title Component](components/sidebar-section-title.md)
- [Skeleton Component](components/skeleton.md)
- [Table Component](components/table.md)
- [Sortable Tables](components/sortable-tables.md)
- [Tabs Component](components/tabs.md)
- [Timeline Component](components/timeline.md)
- [Timestamp Component](components/timestamp.md)
- [Toast Component](components/toast.md)
- [Toasts Component](components/toasts.md)
- [Tooltip Component](components/tooltip.md)
- [Top Nav Component](components/top_nav.md)
- [Tree Component](components/tree.md)

### Architecture
- [Engine Architecture](architecture/engine.md)
- [Asset Pipeline](architecture/assets.md)
- [Tailwind CSS 4 Integration](architecture/tailwind_4.md)

## Quick Start

After installation, use FlatPack components in your views:

```erb
<%# Button Component %>
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  style: :primary,
  url: some_path
) %>

<%# Card Component %>
<%= render FlatPack::Card::Component.new(style: :elevated) do |card| %>
  <% card.header do %>
    <h3>Card Title</h3>
  <% end %>
  
  <% card.body do %>
    <p>Card content goes here.</p>
  <% end %>
<% end %>

<%# Table Component %>
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.column(title: "Name", html: ->(row) { row.name }) %>
  <% table.column(title: "Email", html: ->(row) { row.email }) %>
<% end %>
```

## Configuration

FlatPack can be configured in an initializer:

```ruby
# config/initializers/flat_pack.rb
FlatPack.configure do |config|
  config.default_theme = :light
  config.default_icon_variant = :outline
end
```

## Design Principles

1. **Variables over configuration** - Customize via CSS variables, not Ruby config
2. **Theme variants over one-off overrides** - Light is the default palette, with `data-theme` variants and optional system-mode JS
3. **Composition over inheritance** - Build complex UIs from simple components
4. **Zero-config installation** - Works out of the box
5. **UI-only responsibility** - No business logic, no ActiveRecord assumptions
6. **Security-first design** - Built-in XSS protection and attribute sanitization

## CSS Variables

FlatPack uses Tailwind CSS 4's `@theme` directive to define CSS variables:

```css
/* Override in your application.css */
@theme {
  --color-primary: oklch(0.62 0.22 250);
  --color-primary-hover: oklch(0.52 0.26 250);
  /* ... more variables */
}
```

See [Theming Guide](theming.md) for complete customization options.

## Component Philosophy

All FlatPack components:
- Are ViewComponents
- Use TailwindMerge for class composition
- Accept system arguments (class, data, aria)
- Render correctly without JavaScript
- Support light, dark, and custom theme variants via CSS variables
- Follow accessibility best practices

## Browser Support

FlatPack supports all modern browsers:
- Chrome/Edge (last 2 versions)
- Firefox (last 2 versions)
- Safari (last 2 versions)

## Contributing

FlatPack is open source. Contributions are welcome!

See the main [README.md](../README.md) for development setup.

## License

FlatPack is released under the [MIT License](../MIT-LICENSE).
