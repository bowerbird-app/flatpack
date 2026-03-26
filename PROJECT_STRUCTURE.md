# FlatPack Project Structure

This document provides an overview of the complete FlatPack Rails 8 Engine project structure.

## Project Overview

**FlatPack** is a production-grade Rails 8 UI Component Library built with:
- ViewComponent for type-safe, testable components
- Tailwind CSS 4 with CSS-first configuration
- Propshaft for asset management
- Importmaps for JavaScript (no Node.js)
- System-driven dark mode

**Version:** 0.1.3  
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
│   │   ├── base_component.rb          # Base component with TailwindMerge
│   │   ├── shared/
│   │   │   └── icon_component.rb      # Shared icon component
│   │   ├── accordion/
│   │   ├── alert/
│   │   ├── avatar/
│   │   ├── avatar_group/
│   │   ├── badge/
│   │   ├── bottom_nav/
│   │   ├── breadcrumb/
│   │   ├── button/                    # Button + ButtonDropdown
│   │   ├── button_group/
│   │   ├── card/                      # Card + Card::Stat
│   │   ├── carousel/
│   │   ├── chart/
│   │   ├── chat/                      # Full chat UI suite
│   │   ├── checkbox/
│   │   ├── chip/
│   │   ├── chip_group/
│   │   ├── code_block/
│   │   ├── collapse/
│   │   ├── comments/                  # Thread, Item, Replies, Composer, InlineInput
│   │   ├── content_editor/
│   │   ├── date_input/
│   │   ├── email_input/
│   │   ├── empty_state/
│   │   ├── file_input/
│   │   ├── grid/
│   │   ├── hero/
│   │   ├── link/
│   │   ├── list/
│   │   ├── modal/
│   │   ├── navbar/
│   │   ├── number_input/
│   │   ├── page_header/
│   │   ├── page_title/
│   │   ├── pagination/
│   │   ├── pagination_infinite/
│   │   ├── password_input/
│   │   ├── phone_input/
│   │   ├── picker/
│   │   ├── popover/
│   │   ├── progress/
│   │   ├── quote/
│   │   ├── radio_group/
│   │   ├── range_input/
│   │   ├── search/
│   │   ├── search_input/
│   │   ├── section_title/
│   │   ├── segmented_buttons/
│   │   ├── select/
│   │   ├── sidebar/                   # Sidebar + Item + Header + Divider + Group
│   │   ├── sidebar_layout/
│   │   ├── skeleton/
│   │   ├── switch/
│   │   ├── table/                     # Table + Column + sortable support
│   │   ├── tabs/
│   │   ├── text_area/                 # Plain + TipTap rich text
│   │   ├── text_input/
│   │   ├── timeline/
│   │   ├── toast/
│   │   ├── toasts/
│   │   ├── tooltip/
│   │   ├── top_nav/
│   │   └── url_input/
│   └── javascript/flat_pack/
│       └── controllers/
│           ├── accordion_controller.js
│           ├── carousel_controller.js
│           ├── chart_controller.js
│           ├── chat_controller.js
│           ├── collapse_controller.js
│           ├── content_editor_controller.js
│           ├── modal_controller.js
│           ├── picker_controller.js
│           ├── popover_controller.js
│           ├── search_controller.js
│           ├── table_controller.js
│           ├── tabs_controller.js
│           ├── toast_controller.js
│           └── tooltip_controller.js
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
│   ├── README.md                  # Component index (human + AI quick-reference)
│   ├── installation.md            # Installation guide
│   ├── theming.md                 # Theming and customization
│   ├── dark_mode.md               # Dark mode implementation
│   ├── security.md                # Security model
│   ├── components/
│   │   ├── manifest.yml           # Machine-readable component index
│   │   ├── DOC_FORMAT.md          # Documentation contract
│   │   ├── README.md              # Human component index
│   │   └── <component>.md         # One file per component (55+ docs)
│   └── architecture/
│       ├── engine.md              # Engine architecture
│       ├── assets.md              # Asset pipeline (Propshaft)
│       ├── tailwind_4.md          # Tailwind CSS 4 integration
│       └── theme-tokens.md        # Design token reference
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

### Base Component (`app/components/flat_pack/base_component.rb`)
- Inherits from `ViewComponent::Base`
- Includes `TailwindMerge` for class merging
- Implements system arguments pattern
- Provides utility methods for all components

### Component Library (`app/components/flat_pack/`)
FlatPack ships 55+ production-ready components across seven categories:

| Category | Components |
|---|---|
| Layout & Structure | Card, Grid, SidebarLayout, Hero, PageHeader, PageTitle, SectionTitle |
| Navigation | Breadcrumb, Navbar, Sidebar, SidebarGroup, TopNav, BottomNav, Tabs, Pagination, PaginationInfinite |
| Data Display | Table, List, Timeline, Chart, Progress, Badge, Avatar, AvatarGroup, Skeleton |
| Interactive | Button, ButtonDropdown, ButtonGroup, SegmentedButtons, Accordion, Collapse, Modal, Popover, Tooltip, Picker, Carousel, Chips, RangeInput, Search |
| Feedback | Alert, Toast, Toasts, EmptyState |
| Content | CodeBlock, Quote, ContentEditor, Chat, Comments |
| Form Inputs | TextInput, PasswordInput, EmailInput, PhoneInput, SearchInput, TextArea (+ TipTap), UrlInput, NumberInput, DateInput, FileInput, Checkbox, RadioGroup, Select, Switch |

See [`docs/components/manifest.yml`](docs/components/manifest.yml) for the full machine-readable index.

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
Each interactive component ships a namespaced Stimulus controller (e.g. `flat-pack--modal`, `flat-pack--carousel`, `flat-pack--table`). Controllers are lazy-loaded via importmap.

### Integration
```javascript
// Host app automatically loads controllers
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers", application)
```

## Testing

### Test Suite
- **Framework**: Minitest (Rails default)
- **Component Tests**: `test/components/flat_pack/`
- **Coverage**: All shipped components
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
1. Automatically detects Tailwind CSS 4 configuration file
2. Injects `@source` directive, `@theme` block, and CSS variable mappings
3. Falls back to manual instructions if detection fails

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
# Creates pkg/flat_pack-0.1.3.gem
```

## Documentation

### Comprehensive Docs in `docs/`
- **Getting Started**: Installation, quick start
- **Components**: 55+ component docs in `docs/components/` — see `manifest.yml` for the full index
- **Theming**: CSS variables, customization
- **Dark Mode**: System preference implementation
- **Architecture**: Engine, assets, Tailwind 4, theme tokens

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
6. **Security-first design** - Built-in XSS protection and URL sanitization

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

**Project Status:** Active Development (v0.1.3)  
**Last Updated:** 2026-03-17
