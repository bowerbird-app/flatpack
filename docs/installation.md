# Installation Guide

This guide walks you through installing FlatPack in your Rails 8 application.

## Prerequisites

- Rails 8.0+
- Ruby 3.2+
- Tailwind CSS 3.x via tailwindcss-rails gem
- Propshaft (asset pipeline)
- Importmaps (JavaScript)

## Installation Steps

### 1. Add to Gemfile

```ruby
gem 'flat_pack'
```

Then run:

```bash
bundle install
```

### 2. Run the Install Generator

```bash
rails generate flat_pack:install
```

This generator will:
- Add `@import "flat_pack/variables.css";` to your `application.css`
- Display instructions for Tailwind CSS 4 configuration

### 3. Install tailwindcss-rails Gem

Add to your Gemfile:

```ruby
gem 'tailwindcss-rails', '~> 3.0'
```

Then install:

```bash
bundle install
```

### 4. Configure Tailwind CSS

Update `app/assets/stylesheets/application.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* FlatPack CSS Variables */
:root {
  --color-primary: oklch(0.52 0.26 250);
  --color-primary-hover: oklch(0.42 0.24 250);
  --color-primary-text: oklch(1.0 0 0);
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.20 0.01 250);
  /* Add other variables as needed */
}
```

Create `config/tailwind.config.js`:

```javascript
module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{rb,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    // Include FlatPack components
    './vendor/bundle/ruby/*/gems/flat_pack-*/app/components/**/*.{rb,erb}',
  ],
  theme: {
    extend: {},
  },
  plugins: []
}
```

### 5. Build Tailwind CSS

Build the CSS:

```bash
bundle exec tailwindcss -i app/assets/stylesheets/application.css -o app/assets/builds/application.css --watch
```

### 6. Configure Importmap (Optional, for Stimulus)

If you want to use FlatPack's Stimulus controllers (like the table controller), ensure your importmap includes Stimulus:

```ruby
# config/importmap.rb
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# FlatPack controllers are automatically pinned by the engine
```

### 7. Restart Your Server

```bash
bin/rails server
```

## Verification

Test the installation by rendering a button:

```erb
<%# app/views/pages/home.html.erb %>
<%= render FlatPack::Button::Component.new(label: "Test Button", scheme: :primary) %>
```

Visit the page in your browser. You should see a styled button.

## Manual Installation (Without Generator)

If you prefer manual installation:

### 1. Add stylesheet import

In `app/assets/stylesheets/application.css`:

```css
@import "flat_pack/variables.css";
```

### 2. Configure Tailwind CSS 4

Add the `@source` comment as shown in Step 3 above.

### 3. Configure assets (if needed)

Propshaft should automatically detect FlatPack assets. If not, add to `config/initializers/assets.rb`:

```ruby
# This is usually not necessary
Rails.application.config.assets.paths << FlatPack::Engine.root.join("app/assets/stylesheets")
```

## Troubleshooting

### Styles not applying

1. **Check Tailwind CSS 4 is installed:**
   ```bash
   bundle info tailwindcss-rails
   ```

2. **Verify the @source path:**
   Check that the path in your `application.css` matches your gem location:
   ```bash
   bundle info flat_pack
   ```

3. **Restart the server:**
   Tailwind CSS 4 needs to detect the new source path.

### Components not found

1. **Verify the gem is installed:**
   ```bash
   bundle info flat_pack
   ```

2. **Check autoloading:**
   ```bash
   bin/rails zeitwerk:check
   ```

3. **Restart the server:**
   Rails needs to detect the new engine.

### JavaScript not working

1. **Verify Stimulus is installed:**
   ```bash
   bundle info stimulus-rails
   ```

2. **Check importmap configuration:**
   ```bash
   bin/rails importmap:audit
   ```

## Next Steps

- [Quick Start Guide](README.md#quick-start)
- [Theming Guide](theming.md)
- [Component Documentation](components/)

## Upgrading

See [CHANGELOG.md](../CHANGELOG.md) for upgrade guides between versions.

## Local Development

To use a local version of FlatPack during development:

```ruby
# Gemfile
gem 'flat_pack', path: '/path/to/local/flat_pack'
```

Then:

```bash
bundle install
bin/rails flat_pack:install:migrations
```
