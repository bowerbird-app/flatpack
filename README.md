# FlatPack

A modern Rails UI Component Library built with ViewComponent, Tailwind CSS, and Hotwire. Supports Rails 7.1+.

## Features

- 🎨 **ViewComponent-based** - Type-safe, testable components
- 🌈 **Tailwind CSS** - Modern utility-first CSS with CSS variables
- 🌙 **Themes** - Light by default, with dark and custom `data-theme` variants
- ♿ **Accessible** - WCAG AA compliant, keyboard-friendly
- 🚀 **Zero Config** - Works out of the box with tailwindcss-rails gem
- ✨ **Automated Setup** - Install generator automatically configures Tailwind CSS 4
- 📦 **No Node.js** - Uses Propshaft + Importmaps
- 🔧 **Customizable** - Theme via CSS variables
- 🧩 **Composable** - Build complex UIs from simple components
- 📝 **Rich Text** - Built-in TipTap editor via `rich_text: true` on `TextArea`

## Installation

Add to your Gemfile:

```ruby
gem 'flat_pack'
gem 'tailwindcss-rails', '~> 4.0'
```

Then install:

```bash
bundle install
rails generate flat_pack:install
bin/rake flat_pack:contract
bin/rake flat_pack:verify_install
```

**What the generator does:**
- ✨ Automatically detects your Tailwind CSS 4 configuration file
- ✨ Calculates the correct relative path to FlatPack components
- ✨ Injects `@source` directive, `@theme` block, and CSS variable mappings
- ✨ No manual path finding or configuration copying required!

Optional layout scaffold:

```bash
rails generate flat_pack:layout --type=sidebar
```

The layout generator creates a sidebar + top-nav app shell in:
- `app/views/layouts/flat_pack_sidebar.html.erb`
- `app/views/layouts/flat_pack/_sidebar.html.erb`
- `app/views/layouts/flat_pack/_top_nav.html.erb`

You can customize the output with flags:

```bash
rails generate flat_pack:layout --type=sidebar --side=right --layout_name=admin
```

See the [Installation Guide](docs/installation.md) for detailed setup instructions.

If you want to deploy the dummy Rails app in `test/dummy`, use the [DigitalOcean deployment guide](docs/deployment_digitalocean.md). That guide is for the demo app only, not a requirement for FlatPack host applications.

## AI Entry Points

For AI-assisted installation and usage, start with the gem-shipped contract and verification surfaces instead of inferring setup from prose alone:

- [AI Entry Point](docs/ai/README.md)
- [AI Install Contract](docs/ai/install_contract.json)
- [Install Verification Workflow](docs/installation.md#verification)
- [Components Manifest (Machine-Readable)](docs/components/manifest.yml)

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
<% end %>
```

### Carousel Component

```erb
<%= render FlatPack::Carousel::Component.new(
  slides: [
    {
      type: :image,
      src: "https://images.example.com/hero.jpg",
      alt: "Hero",
      caption: "Hero image",
      lightbox: true
    },
    {
      type: :video,
      src: "https://videos.example.com/teaser.mp4",
      poster: "https://images.example.com/poster.jpg",
      caption: "Teaser"
    }
  ],
  show_controls: true,
  show_indicators: true
) %>
```

`slides` hash options:

| Key | Applies To | Accepts | Default |
|---|---|---|---|
| `type` | image, video, html | `:image`, `:video`, `:html` | inferred |
| `src` | image, video | String URL | required |
| `thumb_src` / `thumb` | image | String URL | `nil` |
| `alt` | image | String | `"Slide n"` |
| `caption` | image, video, html | String | `""` |
| `lightbox` | image, video, html | `true`, `false` | image: `true`, others: `false` |
| `poster` | video | String URL | `nil` |
| `controls` | video | `true`, `false` | `true` |
| `muted` | video | `true`, `false` | `false` |
| `video_loop` | video | `true`, `false` | `false` |
| `playsinline` | video | `true`, `false` | `true` |
| `html` | html | String HTML | required for `:html` |

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

# Rich Text Editor (TipTap — built-in, no extra dependencies)
<%= render FlatPack::TextArea::Component.new(
  name: "post[body]",
  label: "Post Body",
  rich_text: true,
  rich_text_options: {
    preset: :content,
    toolbar: :standard
  }
) %>

# URL Input with validation
<%= render FlatPack::UrlInput::Component.new(
  name: "website",
  label: "Website URL"
) %>
```

## Documentation

- 📚 [Full Documentation](docs/)
- 🤖 [AI Entry Point](docs/ai/README.md)
- 🧪 [AI Install Contract](docs/ai/install_contract.json)
- 🧭 [Components Index (Agent-First)](docs/components/README.md)
- 🤖 [Components Manifest (Machine-Readable)](docs/components/manifest.yml)
- 📐 [Component Doc Format](docs/components/DOC_FORMAT.md)
- ↕️ [Sortable & Draggable Tables](docs/components/sortable-tables.md)
- 🚀 [Installation Guide](docs/installation.md)
- 🎨 [Theming Guide](docs/theming.md)
- 🌙 [Dark Mode Guide](docs/dark_mode.md)
- 🧩 [Component Documentation](docs/components/)
- 🏗️ [Architecture](docs/architecture/)

## Components

### Layout & Structure
- **Card** - Flexible content containers with header, body, footer, and media slots
- **Grid** - Responsive CSS grid layout with configurable columns and gaps
- **SidebarLayout** - Full-height application shell with sidebar, top nav, and main content
- **Hero** - Full-width landing-page hero with seven layout variants
- **PageHeader** - Page-level header with title, subtitle, and action slots
- **PageTitle** - Lightweight semantic heading block with optional subtitle
- **SectionTitle** - In-page section heading with optional description

### Navigation
- **Breadcrumb** - Navigation trail showing current location in site hierarchy
- **Navbar** - Sidebar-first navigation system with collapsible sidebar and responsive top bar
- **Sidebar** - Composable sidebar with header, items, and footer regions
- **SidebarGroup** - Collapsible group of sidebar items with persisted state
- **TopNav** - Sticky top navigation bar with composable left, center, and right regions
- **BottomNav** - Fixed bottom navigation bar for mobile layouts
- **Tabs** - Tabbed content panels with URL-aware active state
- **Pagination** - Page-based navigation with Pagy integration
- **PaginationInfinite** - Infinite-scroll / load-more pagination

### Data Display
- **Table** - Data tables with configurable columns and optional drag-and-drop row reordering
- **List** - Structured list with composable items, avatars, and actions
- **Timeline** - Vertical event timeline with icons and timestamps
- **Chart** - ApexCharts-based visualizations with optional card framing
- **Progress** - Horizontal progress bar with optional label
- **Badge** - Status indicators, counts, labels, and tags
- **Avatar** - User avatar with image, initials, and size variants
- **AvatarGroup** - Stacked avatar group for compact multi-user display
- **Skeleton** - Loading placeholder animations for content regions

### Interactive
- **Button** - Buttons and links with multiple styles and loading states
- **ButtonDropdown** - Button with an attached dropdown menu
- **ButtonGroup** - Grouped button layouts
- **SegmentedButtons** - Segmented control / toggle group
- **Accordion** - Collapsible content sections
- **Collapse** - Single-panel show/hide toggler
- **Modal** - Accessible dialog overlay
- **Popover** - Anchored floating panel with Stimulus positioning
- **Tooltip** - Accessible tooltip via Stimulus
- **Picker** - Modal-based asset picker with single/multi selection
- **Carousel** - Interactive slide carousel with controls, autoplay, and lightbox
- **Chips** - Chip + ChipGroup for tag-like selection UI
- **RangeInput** - Slider control for bounded numeric values
- **Search** - Search input with live-result dropdown backed by a JSON endpoint

### Feedback & Notifications
- **Alert** - Prominent notifications (success, error, warning, info)
- **Toast** - Single dismissible toast notification
- **Toasts** - Toast region manager for stacked toast display
- **EmptyState** - Full-bleed empty state with icon, title, and action

### Content
- **CodeBlock** - Syntax-highlighted code block
- **Quote** - Blockquote with optional attribution
- **ContentEditor** - In-place rich-text editor with balloon toolbar and image upload
- **Chat** - Full chat UI suite (panel, messages, composer, attachments, inbox)
- **Comments** - Comment thread system (Thread, Item, Replies, Composer, InlineInput)

### Form Inputs
- **TextInput** - Single-line text field
- **PasswordInput** - Masked input with show/hide toggle
- **EmailInput** - Email field with mobile keyboard support
- **PhoneInput** - Phone field with numeric keypad
- **SearchInput** - Search field with clear button
- **TextArea** - Multi-line auto-expanding text area; set `rich_text: true` for full TipTap editor
- **UrlInput** - URL field with validation
- **NumberInput** - Numeric input field
- **DateInput** - Date picker input
- **FileInput** - File upload input
- **Checkbox** - Single checkbox or checkbox groups
- **RadioGroup** - Radio button groups
- **Select** - Dropdown select menus
- **Switch** - Toggle switch for boolean states

### Utility
- **Link** - Styled link with consistent appearance
- **Tooltip** - Accessible tooltip wrapper

## Requirements

- Rails 7.1+
- Ruby 3.2+
- Tailwind CSS 4.x (via tailwindcss-rails gem)
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
2. **Theme variants over hardcoded palettes** - Default light theme plus `data-theme` overrides when needed
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
