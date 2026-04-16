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
├── application.css       # Convenience bundle importing FlatPack stylesheets
├── content_editor.css    # Content editor surface styles
├── rich_text.css         # TipTap rich text editor styles
└── variables.css         # Theme tokens and built-in theme variants
```

### Usage

Load FlatPack stylesheets in your application layout:

```erb
<%# app/views/layouts/application.html.erb %>
<%= stylesheet_link_tag "flat_pack/variables", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "flat_pack/rich_text", "data-turbo-track": "reload" %>
```

Propshaft resolves the correct digested path for each file. Using `stylesheet_link_tag` (not `@import`) is required because Propshaft fingerprints asset filenames — a bare CSS `@import "flat_pack/variables.css"` in a statically-served stylesheet would request an un-digested URL that Propshaft does not serve.

## JavaScript

### Structure

```
app/javascript/flat_pack/
├── controllers/
│   └── ..._controller.js   # Stimulus controllers
├── heroicons.js            # Generated Heroicons v2 icon banks for FlatPack icons
└── tiptap/
   └── ...js              # Rich-text helper modules imported by tiptap_controller
```

### Importmap Integration

FlatPack registers its JavaScript modules:

```ruby
# config/importmap.rb
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__),
  under: "controllers/flat_pack",
   to: "flat_pack/controllers",
   preload: false

pin_all_from File.expand_path("../app/javascript/flat_pack/tiptap", __dir__),
   under: "flat_pack/tiptap",
   to: "flat_pack/tiptap",
   preload: false

# Heroicons icon banks — served as a local JS module, no gem required
pin "flat_pack/heroicons", to: "flat_pack/heroicons.js", preload: false
```

### Icon Rendering

FlatPack icons are rendered entirely client-side via the `flat-pack--icon` Stimulus controller. The component emits an SVG shell with `data-controller`, `data-flat-pack--icon-name-value`, and `data-flat-pack--icon-variant-value` attributes. The controller imports icon path data from `flat_pack/heroicons` (an importmap-pinned module) and injects the correct SVG paths at runtime.

This means:
- No server-side SVG sprite partial is required in the host layout.
- Icons support `:outline`, `:solid`, `:mini`, and `:micro` variants.
- Host apps can set a global default with `FlatPack.configure { |config| config.default_icon_variant = :outline }`.
- Icon names follow [Heroicons v2](https://heroicons.com) canonical names (e.g. `magnifying-glass`, `cog-6-tooth`, `exclamation-triangle`). A set of legacy shorthand aliases (e.g. `search`, `settings`, `alert`) are mapped internally for backward compatibility.

## Tailwind CSS 4 Integration

### CSS-First Approach

Tailwind CSS 4 uses a CSS-first configuration model:

1. **No `tailwind.config.js`** - Configuration via CSS
2. **`@theme` directive** - Define variables in CSS
3. **`@source` comments** - Specify content paths

### Configuring Content Sources

Tell Tailwind to scan FlatPack components:

```css
/* app/assets/stylesheets/application.tailwind.css (Tailwind build file) */
@import "tailwindcss";

/* Scan FlatPack components */
/* @source "../../../.bundle/ruby/*/gems/flat_pack-*/app/components" */
```

The `@source` comment tells Tailwind CSS 4 where to find utility classes.

> **Note:** FlatPack CSS variables are loaded via `stylesheet_link_tag` in the layout, not via `@import` inside the Tailwind build file. The install generator updates the host Tailwind file with `@source` and token mappings, while Propshaft serves the FlatPack stylesheets from digested URLs.

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

3. **Check stylesheet link tags in your layout:**
   ```erb
   <%# Correct — lets Propshaft resolve the digested URL %>
   <%= stylesheet_link_tag "flat_pack/variables", "data-turbo-track": "reload" %>
   ```
   Avoid `@import "flat_pack/variables.css"` in a Propshaft-served stylesheet — Propshaft only serves files at their fingerprinted URLs.

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

FlatPack's Stimulus controllers are typically registered via importmap lazy loading:

```javascript
// app/javascript/controllers/index.js
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers", application)
```

If the host app also calls `eagerLoadControllersFrom("controllers", application)`, that eager pass can import FlatPack controllers at boot even though the FlatPack importmap pins use `preload: false`.

If your app caches full HTML pages that include `javascript_importmap_tags`, version that page cache with the current importmap digest as well as any stylesheet digests. Otherwise cached HTML can keep pointing at stale fingerprinted module URLs after a FlatPack controller changes, which surfaces in the browser as a failed dynamic import for a digested controller file that no longer exists.

### Usage

Controllers are namespaced:

```erb
<%= render FlatPack::Table::Component.new(data: @users, stimulus: true) do |table| %>
  <%# Adds data-controller="flat-pack--table" %>
<% end %>
```

## Performance

### Loading Strategy

- **CSS**: Loaded in `<head>`, blocking (intentional for FOUC prevention)
- **JS modules**: Exposed through importmap and fetched when imported
- **Stimulus controllers**: Lazy-load well when the host app avoids eager-loading the full `controllers` namespace

## Best Practices

1. **Keep assets in engine** - Don't copy to host app
2. **Use CSS variables** - Don't override classes
3. **Keep eager-loading narrow** - Avoid eager-loading the full `controllers` namespace if you want FlatPack controllers to stay lazy
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

If the browser reports `Failed to fetch dynamically imported module` for a digested FlatPack controller URL, check any full-page HTML caching first. The usual cause is cached markup containing an old importmap payload rather than a missing controller source file.

## Next Steps

- [Tailwind CSS 4 Integration](tailwind_4.md)
- [Engine Architecture](engine.md)
- [Theming Guide](../theming.md)
