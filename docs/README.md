# FlatPack Documentation

Welcome to FlatPack - a modern Rails 8 UI Component Library built with ViewComponent, Tailwind CSS 4, and modern Rails conventions.

## Overview

FlatPack is a production-grade Rails Engine that provides a comprehensive set of UI components designed for rapid application development. It follows "The Rails Way" and integrates seamlessly with Rails 8 applications.

## Table of Contents

### Getting Started
- [Installation Guide](installation.md)
- [Quick Start](#quick-start)
- [Configuration](#configuration)

### Theming & Styling
- [Theming Guide](theming.md)
- [Dark Mode](dark_mode.md)
- [CSS Variables](#css-variables)

### Security
- [Security Guide](security.md)
- [Security Policy](../SECURITY.md)

### Components
- [Alert Component](components/alert.md)
- [Avatar Component](components/avatar.md)
- [Avatar Group Component](components/avatar-group.md)
- [Badge Component](components/badge.md)
- [Button Component](components/button.md)
- [Button Dropdown Component](components/button-dropdown.md)
- [Card Component](components/card.md)
- [Chat Components](components/chat.md)
- [Chip Component](components/chips.md)
- [Comments Thread Component](components/comments-thread.md)
- [Comments Item Component](components/comments-item.md)
- [Comments Composer Component](components/comments-composer.md)
- [Comments Replies Component](components/comments-replies.md)
- [Input Components](components/inputs.md)
- [Table Component](components/table.md)
- [Sortable Tables](components/sortable-tables.md)

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
end
```

## Design Principles

1. **Variables over configuration** - Customize via CSS variables, not Ruby config
2. **System-driven dark mode** - Uses `prefers-color-scheme` only
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
- Support dark mode via system preference
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
