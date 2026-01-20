# FlatPack

A modern Rails 8 UI Component Library built with ViewComponent, Tailwind CSS 4, and Hotwire.

## Features

- 🎨 **ViewComponent-based** - Type-safe, testable components
- 🌈 **Tailwind CSS 4** - CSS-first configuration with CSS variables
- 🌙 **Dark Mode** - System preference-driven (no toggle required)
- ♿ **Accessible** - WCAG AA compliant, keyboard-friendly
- 🚀 **Zero Config** - Works out of the box
- 📦 **No Node.js** - Uses Propshaft + Importmaps
- 🔧 **Customizable** - Theme via CSS variables
- 🧩 **Composable** - Build complex UIs from simple components

## Installation

Add to your Gemfile:

```ruby
gem 'flat_pack'
```

Then install:

```bash
bundle install
rails generate flat_pack:install
```

See [Installation Guide](docs/installation.md) for detailed instructions.

## Quick Start

### Button Component

```erb
<%= render FlatPack::Button::Component.new(
  label: "Click me",
  scheme: :primary
) %>
```

Schemes: `:primary`, `:secondary`, `:ghost`

### Table Component

```erb
<%= render FlatPack::Table::Component.new(rows: @users) do |table| %>
  <% table.with_column(label: "Name", attribute: :name) %>
  <% table.with_column(label: "Email", attribute: :email) %>
  <% table.with_action(label: "Edit", url: ->(user) { edit_user_path(user) }) %>
<% end %>
```

## Documentation

- 📚 [Full Documentation](docs/)
- 🚀 [Installation Guide](docs/installation.md)
- 🎨 [Theming Guide](docs/theming.md)
- 🌙 [Dark Mode Guide](docs/dark_mode.md)
- 🧩 [Component Documentation](docs/components/)
- 🏗️ [Architecture](docs/architecture/)

## Components

- **Button** - Buttons and links with multiple schemes
- **Table** - Data tables with columns and actions
- **Icon** - Shared icon component

More components coming soon!

## Requirements

- Rails 8.0+
- Ruby 3.2+
- Tailwind CSS 4
- Propshaft (asset pipeline)
- Importmaps (JavaScript)

## Development

Clone the repository:

```bash
git clone https://github.com/flatpack/flat_pack.git
cd flat_pack
bundle install
```

### Running Tests

```bash
bundle exec rake test
```

### Running the Dummy App

```bash
cd test/dummy
bin/rails server
```

Visit http://localhost:3000 to see component demos.

### Linting

```bash
bin/rubocop
```

## Philosophy

FlatPack follows these principles:

1. **Variables over configuration** - Customize via CSS variables
2. **System-driven dark mode** - Respects OS preference
3. **Composition over inheritance** - Build complex UIs from simple parts
4. **Zero-config installation** - Works immediately
5. **UI-only responsibility** - No business logic

## Versioning

FlatPack follows [Semantic Versioning](https://semver.org/).

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Write tests for your changes
4. Ensure `bin/rubocop` passes
5. Submit a pull request

## License

FlatPack is released under the [MIT License](MIT-LICENSE).

## Credits

Built with:

- [Rails](https://rubyonrails.org/)
- [ViewComponent](https://viewcomponent.org/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Hotwire](https://hotwired.dev/)

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/flatpack/flat_pack/issues)
- 💬 [Discussions](https://github.com/flatpack/flat_pack/discussions)
