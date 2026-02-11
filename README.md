# FlatPack

A modern Rails 8 UI Component Library built with ViewComponent, Tailwind CSS, and Hotwire.

## Features

- 🎨 **ViewComponent-based** - Type-safe, testable components
- 🌈 **Tailwind CSS** - Modern utility-first CSS with CSS variables
- 🌙 **Dark Mode** - System preference-driven (no toggle required)
- ♿ **Accessible** - WCAG AA compliant, keyboard-friendly
- 🚀 **Zero Config** - Works out of the box with tailwindcss-rails gem
- ✨ **Automated Setup** - Install generator automatically configures Tailwind CSS 4
- 📦 **No Node.js** - Uses Propshaft + Importmaps
- 🔧 **Customizable** - Theme via CSS variables
- 🧩 **Composable** - Build complex UIs from simple components

## Installation

Add to your Gemfile:

```ruby
gem 'flat_pack'
gem 'tailwindcss-rails', '~> 3.0'
```

Then install:

```bash
bundle install
rails generate flat_pack:install
```

**What the generator does:**
- ✨ Automatically detects your Tailwind CSS 4 configuration file
- ✨ Calculates the correct relative path to FlatPack components
- ✨ Injects `@source` directive, `@theme` block, and CSS variable mappings
- ✨ No manual path finding or configuration copying required!

See the [Installation Guide](docs/installation.md) for detailed setup instructions.

## Quick Start

### Button Component

```erb
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  style: :primary
) %>
```

Schemes: `:primary`, `:secondary`, `:ghost`

### Card Component

```erb
<%= render FlatPack::Card::Component.new(style: :elevated) do |card| %>
  <% card.header do %>
    <h3>Card Title</h3>
  <% end %>
  
  <% card.body do %>
    <p>Card content goes here.</p>
  <% end %>
  
  <% card.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Action", style: :primary) %>
  <% end %>
<% end %>
```

Styles: `:default`, `:elevated`, `:outlined`, `:flat`, `:interactive`

### Breadcrumb Component

```erb
<%= render FlatPack::Breadcrumb::Component.new do |breadcrumb| %>
  <% breadcrumb.item(text: "Home", href: "/") %>
  <% breadcrumb.item(text: "Products", href: "/products") %>
  <% breadcrumb.item(text: "Laptops") %>
<% end %>
```

Separators: `:chevron`, `:slash`, `:arrow`, `:dot`, `:custom`

### Table Component

```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.column(title: "Name", html: ->(user) { user.name }) %>
  <% table.column(title: "Email", html: ->(user) { user.email }) %>
  <% table.with_action(text: "Edit", url: ->(user) { edit_user_path(user) }) %>
<% end %>
```

### Input Components

```erb
# Text Input
<%= render FlatPack::TextInput::Component.new(
  name: "username",
  label: "Username",
  placeholder: "Enter your username"
) %>

# Password Input with toggle
<%= render FlatPack::PasswordInput::Component.new(
  name: "password",
  label: "Password",
  required: true
) %>

# Email Input
<%= render FlatPack::EmailInput::Component.new(
  name: "email",
  label: "Email Address",
  placeholder: "you@example.com"
) %>

# Phone Input
<%= render FlatPack::PhoneInput::Component.new(
  name: "phone",
  label: "Phone Number"
) %>

# Search Input with clear button
<%= render FlatPack::SearchInput::Component.new(
  name: "q",
  placeholder: "Search..."
) %>

# Text Area with auto-expand
<%= render FlatPack::TextArea::Component.new(
  name: "description",
  label: "Description",
  rows: 3
) %>

# URL Input with validation
<%= render FlatPack::UrlInput::Component.new(
  name: "website",
  label: "Website URL"
) %>
```

## Documentation

- 📚 [Full Documentation](docs/)
- 🚀 [Installation Guide](docs/installation.md)
- 🎨 [Theming Guide](docs/theming.md)
- 🌙 [Dark Mode Guide](docs/dark_mode.md)
- 🧩 [Component Documentation](docs/components/)
- 🏗️ [Architecture](docs/architecture/)

## Components

### Layout Components
- **Card** - Flexible content containers with header, body, footer, and media slots

### Interactive Components
- **Button** - Buttons and links with multiple schemes
- **Table** - Data tables with columns and actions

### Feedback Components
- **Alert** - Prominent notifications and messages (success, errors, warnings, info)
- **Badge** - Status indicators, counts, labels, and tags

### Form Components
- **TextInput** - Single-line text field
- **PasswordInput** - Masked input with show/hide toggle
- **EmailInput** - Email field with mobile keyboard support
- **PhoneInput** - Phone field with numeric keypad
- **SearchInput** - Search field with clear button
- **TextArea** - Multi-line auto-expanding text area
- **UrlInput** - URL field with validation
- **Checkbox** - Single checkbox or checkbox groups
- **RadioGroup** - Radio button groups
- **Select** - Dropdown select menus
- **Switch** - Toggle switch for boolean states
- **DateInput** - Date picker input
- **NumberInput** - Numeric input field
- **FileInput** - File upload input

### Navigation Components
- **Breadcrumb** - Navigation trail showing current location in site hierarchy
- **Navbar** - Sidebar-first navigation system with collapsible sidebar and responsive top bar

### Utility Components
- **Link** - Styled links with consistent appearance
- **ButtonGroup** - Grouped button layouts
- **SegmentedButtons** - Segmented control buttons

More components coming soon!

## Requirements

- Rails 8.0+
- Ruby 3.2+
- Tailwind CSS 3.x or 4.x (via tailwindcss-rails gem)
- Propshaft (asset pipeline)
- Importmaps (JavaScript)

## Development

Clone the repository:

```bash
git clone https://github.com/flatpack/flat_pack.git
cd flat_pack
bundle install
```

### Using GitHub Codespaces / Devcontainer

This repository includes a devcontainer configuration for use with GitHub Codespaces or VS Code Dev Containers:

- **PostgreSQL 16** - Database service
- **Redis 7** - Cache/background jobs
- **Ruby 3.2.3** - Runtime environment
- **Pre-configured VS Code extensions** - Ruby LSP, Debug, Tailwind CSS

To use:

1. **GitHub Codespaces**: Click "Code" → "Create codespace on main"
2. **VS Code**: Open in VS Code, click "Reopen in Container" when prompted

The devcontainer automatically:
- Installs all dependencies
- Sets up the database
- Builds Tailwind CSS assets

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
6. **Security-first design** - Built-in XSS protection and sanitization

## Security

FlatPack is built with security as a core principle. Learn more in our [Security Policy](SECURITY.md).

**Key Security Features:**
- 🔒 **XSS Prevention** - Automatic attribute sanitization and URL validation
- 🛡️ **Injection Protection** - Blocks dangerous protocols (javascript:, data:, vbscript:)
- 🔐 **CSP Compatible** - No eval() or unsafe-inline required
- 📦 **Supply Chain Security** - Minimal dependencies, automated security scanning

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
