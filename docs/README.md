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

The component index is the complete human-readable inventory. The manifest is the canonical machine-readable inventory, including primary classes, related classes, and documentation paths.

### Architecture
- [Engine Architecture](architecture/engine.md)
- [Asset Pipeline](architecture/assets.md)
- [Tailwind CSS 4 Integration](architecture/tailwind_4.md)
- [Cursor Cloud Agent skills](cursor-skills.md)

## Quick Start

After installation, use FlatPack components in your views:

```erb
<%# Button Component %>
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  style: :primary,
  href: some_path
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
2. **Theme variants over one-off overrides** - Rounded / charcoal is the default palette, with `data-theme` variants and optional system-mode JS
3. **Composition over inheritance** - Build complex UIs from simple components
4. **Zero-config installation** - Works out of the box
5. **UI-only responsibility** - No business logic, no ActiveRecord assumptions
6. **Security-first design** - Built-in XSS protection and attribute sanitization

## CSS Variables

Tokens live in `flat_pack/variables.css`. Recolor from brand primitives after that stylesheet loads:

```css
/* Override in a host stylesheet loaded after flat_pack/variables */
:root {
  --brand-hue: 270;
  --brand-chroma: 0.22;
  --brand-lightness: 0.52;
}
```

`--color-primary` is `oklch(var(--brand-lightness) var(--brand-chroma) var(--brand-hue))`. Surfaces pick up hue only. For an exact hex, set `--color-primary` instead. See [Theming Guide](theming.md).

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
