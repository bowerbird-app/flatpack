# FlatPack Project Structure

This document provides an overview of the complete FlatPack Rails 8 Engine project structure.

## Project Overview

**FlatPack** is a production-grade Rails 8 UI Component Library built with:
- ViewComponent for type-safe, testable components
- Tailwind CSS 4 with CSS-first configuration
- Propshaft for asset management
- Importmaps for JavaScript (no Node.js)
- System-driven dark mode

**Version:** 0.1.0  
**License:** MIT  
**Ruby:** 3.2+  
**Rails:** 8.0+

## Directory Structure

```
flat_pack/
├── app/                          # Application code
│   ├── assets/
│   │   └── stylesheets/flat_pack/
│   │       ├── application.css   # Main stylesheet
│   │       └── variables.css     # Theme variables (Tailwind 4 @theme)
│   ├── components/flat_pack/
│   │   ├── base_component.rb     # Base component with TailwindMerge
│   │   ├── button/
│   │   │   ├── component.rb      # Button component logic
│   │   │   └── component.html.erb # Button template
│   │   ├── table/
│   │   │   ├── component.rb      # Table component logic
│   │   │   ├── component.html.erb # Table template
│   │   │   ├── column/
│   │   │   │   └── component.rb # Column sub-component
│   │   └── shared/
│   │       └── icon_component.rb  # Shared icon component
│   └── javascript/flat_pack/
│       └── controllers/
│           └── table_controller.js # Stimulus controller for tables
│
├── bin/                           # Executable scripts
│   ├── rails                      # Rails command for dummy app
│   └── rubocop                    # Linting script
│
├── config/                        # Engine configuration
│   ├── routes.rb                  # Engine routes (empty)
│   └── importmap.rb               # JavaScript module pinning
│
├── docs/                          # Comprehensive documentation
│   ├── README.md                  # Documentation index
│   ├── installation.md            # Installation guide
│   ├── theming.md                 # Theming and customization
│   ├── dark_mode.md               # Dark mode implementation
│   ├── components/
│   │   ├── button.md              # Button component docs
│   │   └── table.md               # Table component docs
│   └── architecture/
│       ├── engine.md              # Engine architecture
│       ├── assets.md              # Asset pipeline (Propshaft)
│       └── tailwind_4.md          # Tailwind CSS 4 integration
│
├── lib/                           # Library code
│   ├── flat_pack.rb               # Main entry point
│   ├── flat_pack/
│   │   ├── version.rb             # Version constant
│   │   └── engine.rb              # Rails Engine configuration
│   ├── generators/flat_pack/
│   │   └── install_generator.rb   # Installation generator
│   └── tasks/
│       └── flat_pack_tasks.rake   # Rake tasks
│
├── test/                          # Test suite
│   ├── test_helper.rb             # Test configuration
│   ├── components/flat_pack/
│   │   ├── button_component_test.rb # Button tests
│   │   └── table_component_test.rb  # Table tests
│   └── dummy/                     # Rails 8 dummy application
│       ├── app/
│       │   ├── assets/stylesheets/
│       │   │   └── application.css # Imports FlatPack styles
│       │   ├── controllers/
│       │   │   ├── application_controller.rb
│       │   │   └── pages_controller.rb # Demo pages
│       │   ├── javascript/
│       │   │   ├── application.js
│       │   │   └── controllers/
│       │   └── views/
│       │       ├── layouts/
│       │       │   └── application.html.erb
│       │       └── pages/
│       │           ├── demo.html.erb # Main demo
│       │           ├── buttons.html.erb # Button demos
│       │           └── tables.html.erb # Table demos
│       └── config/
│           ├── application.rb
│           ├── boot.rb
│           ├── environment.rb
│           ├── routes.rb          # Mounts FlatPack engine
│           ├── database.yml
│           ├── importmap.rb
│           └── environments/
│
├── .gitignore                     # Git ignore rules
├── .rubocop.yml                   # RuboCop configuration
├── CHANGELOG.md                   # Version history
├── Gemfile                        # Development dependencies
├── MIT-LICENSE                    # MIT license
├── README.md                      # Project README
├── Rakefile                       # Rake tasks
└── flat_pack.gemspec              # Gem specification
```

## Core Components

### 1. Base Component (`app/components/flat_pack/base_component.rb`)
- Inherits from `ViewComponent::Base`
- Includes `TailwindMerge` for class merging
- Implements system arguments pattern
- Provides utility methods for all components

### 2. Button Component (`app/components/flat_pack/button/`)
**Features:**
- Three schemes: `:primary`, `:secondary`, `:ghost`
- Renders as `<button>` or `<a>` based on `url` prop
- Supports HTTP methods (for delete, etc.)
- Fully accessible (ARIA, keyboard nav)
- CSS variable-based theming

**Usage:**
```erb
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  scheme: :primary,
  url: some_path
) %>
```

### 3. Table Component (`app/components/flat_pack/table/`)
**Features:**
- Data table with configurable columns
- Lambda-based columns with html parameter
- Optional Stimulus controller for interactivity
- Empty state handling
- Responsive overflow scrolling

**Usage:**
```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.column(title: "Name", html: ->(user) { user.name }) %>
<% end %>
```

## Styling System

### Tailwind CSS 4 Configuration

**CSS Variables** (`app/assets/stylesheets/flat_pack/variables.css`):
```css
@theme {
  --color-primary: oklch(0.62 0.22 250);
  --color-secondary: oklch(0.95 0.01 250);
  /* ... more variables */
}

@media (prefers-color-scheme: dark) {
  @theme {
    --color-primary: oklch(0.65 0.22 250);
    /* ... adjusted for dark mode */
  }
}
```

**Key Features:**
- OKLCH color space for perceptual uniformity
- System-driven dark mode (no toggle)
- CSS-first (no `tailwind.config.js`)
- Customizable via variable overrides

## JavaScript Architecture

### Stimulus Controllers
- **table_controller.js**: Row selection, hover effects
- Lazy-loaded via importmap
- Namespaced as `flat-pack--table`

### Integration
```javascript
// Host app automatically loads controllers
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers/flat_pack", application)
```

## Testing

### Test Suite
- **Framework**: Minitest (Rails default)
- **Component Tests**: `test/components/flat_pack/`
- **Coverage**: Button and Table components
- **ViewComponent Helpers**: Integrated for rendering tests

### Running Tests
```bash
bundle exec rake test
```

### Dummy Application
- Full Rails 8 app in `test/dummy/`
- Mounts FlatPack engine
- Provides demo pages at `/`
- Used for integration testing

## Installation & Usage

### Installation
```bash
gem 'flat_pack'
bundle install
rails generate flat_pack:install
```

### Generator Actions
1. Adds `@import "flat_pack/variables.css"` to `application.css`
2. Displays Tailwind CSS 4 configuration instructions
3. Shows next steps

### Configuration
Host apps can customize via CSS variables:
```css
@import "flat_pack/variables.css";

@theme {
  --color-primary: oklch(0.55 0.25 270); /* Custom purple */
}
```

## Development Workflow

### Setup
```bash
git clone https://github.com/flatpack/flat_pack.git
cd flat_pack
bundle install
```

### Running Dummy App
```bash
cd test/dummy
bin/rails server
```

### Running Tests
```bash
bundle exec rake test
```

### Linting
```bash
bin/rubocop
```

### Building Gem
```bash
bundle exec rake build
# Creates pkg/flat_pack-0.1.0.gem
```

## Documentation

### Comprehensive Docs in `docs/`
- **Getting Started**: Installation, quick start
- **Components**: Button, Table usage and API
- **Theming**: CSS variables, customization
- **Dark Mode**: System preference implementation
- **Architecture**: Engine, assets, Tailwind 4

### Inline Documentation
- All Ruby code has descriptive comments
- ERB templates include component descriptions
- JavaScript controllers documented

## Dependencies

### Runtime Dependencies
- `rails ~> 8.0`
- `view_component ~> 3.0`
- `tailwind_merge ~> 0.13`

### Development Dependencies
- `sqlite3 ~> 2.0`
- `standard ~> 1.35` (Ruby style guide)
- `propshaft ~> 1.0`
- `importmap-rails`
- `stimulus-rails`
- `turbo-rails`

## Design Principles

1. **Variables over configuration** - Theme with CSS, not Ruby
2. **System-driven dark mode** - Respect OS preference
3. **Composition over inheritance** - Slot-based architecture
4. **Zero-config installation** - Works immediately
5. **UI-only responsibility** - No business logic, no AR assumptions

## Future Enhancements

Potential additions (not in v0.1.0):
- Form components (input, select, checkbox, radio)
- Modal/dialog component
- Alert/toast notifications
- Card component
- Navigation components (navbar, sidebar)
- Badge component
- Avatar component
- More Stimulus interactions

## Contributing

See main README.md for contribution guidelines.

## License

MIT License - see MIT-LICENSE file.

## Support & Resources

- Documentation: `docs/`
- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Source: https://github.com/flatpack/flat_pack

---

**Project Status:** Initial Release (v0.1.0)  
**Last Updated:** 2025-01-20
