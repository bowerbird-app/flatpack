# Installation Guide

This guide walks you through installing FlatPack in your Rails 8 application.

## Prerequisites

- Rails 8.0+
- Ruby 3.2+
- Tailwind CSS 4 (CSS-first)
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

### 3. Configure Tailwind CSS 4

Add FlatPack components to your Tailwind CSS 4 source scanning.

In `app/assets/stylesheets/application.css`, add:

```css
@import "tailwindcss";
@import "flat_pack/variables.css";

/* Add FlatPack components to Tailwind's content sources */
/* @source "../../../.bundle/ruby/*/gems/flat_pack-*/app/components" */
```

**Note:** The exact path may vary depending on your Bundler configuration. Check your bundle path with:

```bash
bundle info flat_pack
```

### 4. Configure Importmap (Optional, for Stimulus)

If you want to use FlatPack's Stimulus controllers (like the table controller), ensure your importmap includes Stimulus:

```ruby
# config/importmap.rb
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# FlatPack controllers are automatically pinned by the engine
```

### 5. Restart Your Server

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
