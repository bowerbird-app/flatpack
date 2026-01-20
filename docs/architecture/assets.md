# Asset Pipeline with Propshaft

FlatPack uses Propshaft for asset management, providing a simpler alternative to Sprockets.

## Overview

Propshaft is Rails 8's default asset pipeline. It's designed for:
- Serving static assets efficiently
- Fingerprinting for cache busting
- Compiling assets without Node.js

## Configuration

### Engine Configuration

FlatPack registers its asset paths with Propshaft:

```ruby
# lib/flat_pack/engine.rb
initializer "flat_pack.assets" do |app|
  if app.config.respond_to?(:assets)
    app.config.assets.paths << root.join("app/assets/stylesheets")
    app.config.assets.paths << root.join("app/javascript")
  end
end
```

This allows Propshaft to serve assets from the engine.

### Host Application

In your application, Propshaft automatically detects FlatPack's assets:

```ruby
# config/environments/production.rb
# Propshaft is pre-configured in Rails 8
config.assets.compile = false
```

## Stylesheets

### Structure

```
app/assets/stylesheets/flat_pack/
├── application.css       # Main stylesheet
└── variables.css         # CSS variables (theme)
```

### Usage

Import in your `application.css`:

```css
@import "flat_pack/variables.css";
```

Propshaft resolves the path and serves the file.

## JavaScript

### Structure

```
app/javascript/flat_pack/
└── controllers/
    └── table_controller.js  # Stimulus controller
```

### Importmap Integration

FlatPack registers its JavaScript modules:

```ruby
# config/importmap.rb
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__),
  under: "controllers/flat_pack",
  to: "flat_pack/controllers"
```

## Tailwind CSS 4 Integration

### CSS-First Approach

Tailwind CSS 4 works differently from v3:

1. **No `tailwind.config.js`** - Configuration via CSS
2. **`@theme` directive** - Define variables in CSS
3. **`@source` comments** - Specify content paths

### Configuring Content Sources

Tell Tailwind to scan FlatPack components:

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";
@import "flat_pack/variables.css";

/* Scan FlatPack components */
/* @source "../../../.bundle/ruby/*/gems/flat_pack-*/app/components" */
```

The `@source` comment tells Tailwind CSS 4 where to find utility classes.

### Path Resolution

The path depends on your Bundler configuration:

```bash
# Find the correct path
bundle info flat_pack
# => /path/to/.bundle/ruby/3.2.0/gems/flat_pack-0.1.0

# Use in @source comment
/* @source "../../../.bundle/ruby/3.2.0/gems/flat_pack-0.1.0/app/components" */
```

## Production Deployment

### Precompilation

```bash
bin/rails assets:precompile
```

Propshaft:
1. Copies assets to `public/assets`
2. Adds fingerprints (e.g., `application-abc123.css`)
3. Generates manifest

### CDN Configuration

For CDN serving:

```ruby
# config/environments/production.rb
config.asset_host = "https://cdn.example.com"
```

## Caching

### Development

Assets are served directly, no caching:

```ruby
# config/environments/development.rb
config.assets.digest = false
config.public_file_server.headers = {}
```

### Production

Assets are fingerprinted and cached:

```ruby
# config/environments/production.rb
config.assets.digest = true
config.public_file_server.headers = {
  "Cache-Control" => "public, max-age=#{1.year.to_i}"
}
```

## Debugging

### Missing Assets

If assets aren't loading:

1. **Check Propshaft paths:**
   ```bash
   bin/rails runner "puts Rails.application.config.assets.paths"
   ```

2. **Verify file exists:**
   ```bash
   bundle info flat_pack
   ls $(bundle info flat_pack --path)/app/assets/stylesheets/
   ```

3. **Check import statement:**
   ```css
   @import "flat_pack/variables.css"; /* Correct */
   @import "flat_pack/variables";     /* Wrong - include .css */
   ```

### Tailwind Not Picking Up Classes

1. **Verify @source path:**
   ```bash
   bundle info flat_pack
   # Adjust @source comment accordingly
   ```

2. **Restart server:**
   Tailwind needs to detect new source paths.

3. **Check Tailwind is watching:**
   ```bash
   # In development
   bin/dev # or bin/rails server
   ```

## Stimulus Controllers

### Registration

FlatPack's Stimulus controllers are auto-registered via importmap:

```javascript
// app/javascript/controllers/index.js
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers/flat_pack", application)
```

### Usage

Controllers are namespaced:

```erb
<%= render FlatPack::Table::Component.new(rows: @users, stimulus: true) do |table| %>
  <%# Adds data-controller="flat-pack--table" %>
<% end %>
```

## Performance

### Asset Size

FlatPack's assets are minimal:
- `variables.css`: ~3KB
- `table_controller.js`: ~1.5KB

Total: ~4.5KB (uncompressed)

### Loading Strategy

- **CSS**: Loaded in `<head>`, blocking (intentional for FOUC prevention)
- **JS**: Loaded via importmap, non-blocking
- **Stimulus controllers**: Lazy-loaded on demand

## Best Practices

1. **Keep assets in engine** - Don't copy to host app
2. **Use CSS variables** - Don't override classes
3. **Import only what you need** - Selective imports reduce size
4. **Leverage HTTP/2** - Multiple small files are efficient
5. **Trust Propshaft** - Let it handle fingerprinting

## Troubleshooting

### Assets Not Found in Production

```ruby
# config/environments/production.rb
# Ensure public file server is enabled or use a CDN
config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
```

### Importmap Errors

```bash
# Verify importmap configuration
bin/rails importmap:audit

# Pin missing dependencies
bin/importmap pin @hotwired/stimulus
```

## Next Steps

- [Tailwind CSS 4 Integration](tailwind_4.md)
- [Engine Architecture](engine.md)
- [Theming Guide](../theming.md)
