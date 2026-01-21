# FlatPack Dummy Application

This is a Rails 8 application that demonstrates the FlatPack component library.

## Purpose

This dummy app serves as:
- A testing environment for the FlatPack gem during development
- A demo/showcase of FlatPack components
- Reference implementation showing how to integrate FlatPack into a Rails app

## Setup

The dummy app is configured to use the FlatPack gem from the parent directory.

### Quick Setup

Run the setup script to automatically install all dependencies and prepare the app:

```bash
bin/setup --skip-server
```

This will:
- Install all Ruby gem dependencies (including FlatPack parent gem)
- Prepare the database
- Build Tailwind CSS assets
- Clear logs and temporary files

### Manual Installation Steps

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Setup the database:**
   ```bash
   bin/rails db:create db:migrate
   ```

3. **Build Tailwind CSS:**
   ```bash
   bin/rails tailwindcss:build
   ```

4. **Start the server:**
   ```bash
   bin/rails server
   ```

5. **Visit the app:**
   Open http://localhost:3000 in your browser

## FlatPack Integration

The dummy app demonstrates proper FlatPack installation:

### 1. Gemfile Configuration

The FlatPack gem is loaded from the parent directory:

```ruby
gem "flat_pack", path: "../.."
```

### 2. CSS Variables Import

The FlatPack CSS variables are included directly in `app/assets/stylesheets/application.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* FlatPack CSS Variables */
:root {
  --color-primary: var(--color-brand-600);
  /* ... other variables */
}
```

For production apps, you can also use the import approach (requires proper asset path configuration):

```css
@import "flat_pack/variables.css";
```

### 3. Tailwind Configuration

The `config/tailwind.config.js` includes FlatPack component paths:

```javascript
const engineRoot = path.resolve(__dirname, '../../..')

module.exports = {
  content: [
    // ... other paths
    `${engineRoot}/app/components/**/*.{erb,haml,html,slim,rb}`,
  ]
}
```

### 4. Importmap Configuration

FlatPack's Stimulus controllers are pinned in `config/importmap.rb`:

```ruby
pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), 
             under: "controllers/flat_pack", 
             to: "flat_pack/controllers"
```

### 5. Engine Mount

The FlatPack engine is mounted in `config/routes.rb`:

```ruby
mount FlatPack::Engine => "/flat_pack"
```

## Demo Pages

The dummy app includes several demo pages:

- **Home/Demo** (`/`): Overview of available components
- **Buttons** (`/demo/buttons`): Button component examples
- **Tables** (`/demo/tables`): Table component examples

## Development

When developing FlatPack components, you can test them immediately in the dummy app by:

1. Making changes to components in the parent `app/components` directory
2. Refreshing the browser to see changes
3. The Tailwind watcher will automatically rebuild CSS if running in watch mode

## Using Components

Example usage in views:

```erb
<%# Button Component %>
<%= render FlatPack::Button::Component.new(
  label: "Click me",
  scheme: :primary
) %>

<%# Table Component %>
<%= render FlatPack::Table::Component.new do |table| %>
  <% table.with_column(header: "Name", accessor: :name) %>
  <% table.with_column(header: "Email", accessor: :email) %>
<% end %>
```

## Testing

Run tests from the parent directory:

```bash
cd ../..
bundle exec rake test
```

## Directory Structure

```
test/dummy/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.css      # Imports FlatPack CSS
│   ├── controllers/
│   │   └── pages_controller.rb      # Demo page controller
│   ├── javascript/
│   │   └── application.js
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb
│       └── pages/                   # Demo pages
│           ├── demo.html.erb
│           ├── buttons.html.erb
│           └── tables.html.erb
├── config/
│   ├── routes.rb                    # Mounts FlatPack engine
│   ├── importmap.rb                 # Pins FlatPack controllers
│   └── tailwind.config.js           # Includes FlatPack paths
└── Gemfile                          # References FlatPack gem
```
