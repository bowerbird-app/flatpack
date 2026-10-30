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
├── application.css       # Component helpers. Imports the other kit sheets.
├── content_editor.css    # Content editor surface styles
├── inline_edit.css       # Inline edit surface styles
├── rich_text.css         # TipTap rich text editor styles
└── variables.css         # Theme tokens and built-in theme variants
```

### Usage

Load FlatPack stylesheets in your application layout:

```erb
<%# app/views/layouts/application.html.erb %>
<%= stylesheet_link_tag "flat_pack/variables", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "flat_pack/application", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "flat_pack/rich_text", "data-turbo-track": "reload" %>
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

`flat_pack/application.css` starts with sibling imports, before `@layer`:

```css
@import url("variables.css");
@import url("rich_text.css");
@import url("content_editor.css");
@import url("inline_edit.css");
```

Propshaft `CssAssetUrls` rewrites each `url()` to a digested path under `flat_pack/`, such as `/assets/flat_pack/content_editor-<digest>.css`. `referenced_by` includes those files, so the `application.css` digest changes when an imported file changes. A host that links `flat_pack/application` receives `content_editor` and `inline_edit` without extra link tags.

The install generator also links `variables` and `rich_text`. Those tags repeat imports already inside `application.css`. The repeat is harmless. Leave the generator tags. Do not add link tags for `content_editor` or `inline_edit` unless you load those sheets without `application.css`.

A bare `@import "flat_pack/variables.css"` is not rewritten. The browser resolves it from `/assets/flat_pack/` and requests `/assets/flat_pack/flat_pack/variables.css`, which 404s. Use `stylesheet_link_tag` for the layout tags. Inside a kit sheet, use `@import url()` with a path relative to that file.

Host Tailwind usually loads last. `@layer theme` writes `--radius-md: 0.375rem` and `--font-sans: ui-sans-serif`. Re-set kit radii and the kit face on unlayered `:root` in the host stylesheet so rich-text chrome and kit surfaces keep the kit scale. Rich-text `TextArea` also applies the shared `border` and `--form-control-padding-x` / `--form-control-padding-y` utilities (not only kit CSS) so preflight cannot zero the editor outline or inset. See [Theming](../theming.md).

## JavaScript

### Structure

```
app/javascript/flat_pack/
├── controllers/
│   └── ..._controller.js   # Stimulus controllers
├── heroicons.js            # Generated Heroicons v2 icon banks for FlatPack icons
├── local_time.js           # Framework-independent local/relative time enhancer
├── focus_trap.js           # Shared Tab cycle for Drawer, Command palette, and Modal
├── click_outside.js        # Shared outside-click listener and dialog backdrop check
├── positioning.js          # Shared floating-panel placement. Popover, Button dropdown, Date picker, and Collection editor use it.
├── remote_query.js         # Shared debounce and aborting GET. Select, Picker, Search, and Combobox use it.
└── tiptap/
   └── ...js              # Rich-text helper modules imported by tiptap_controller
```

### Importmap Integration

importmap-rails hosts load these pins from the engine. `initializer "flat_pack.importmap"` appends the engine `config/importmap.rb` before importmap-rails reads pin paths. A host that bypasses that importmap, or that copies pins into its own file, adds the same lines or reruns `bin/rails generate flat_pack:install`.

`flat_pack/focus_trap` is imported only by Drawer, Command palette, and Modal. A missing pin stops those three controllers. Other controllers do not import it, so they still load.

`flat_pack/click_outside` is the document listener for overlays that close when the pointer lands outside, plus `isBackdropClick` for Modal, Drawer, Command palette, and Lightbox. Popover, Search, Select, Button dropdown, Date picker, Collection editor, Combobox, FAB, Button group menu, Trash button, and the collapsible Search field import it. Chat message actions uses `isOutside` for its window click. A missing pin stops those controllers. Escape handling stays in each controller. TipTap link and image popovers still bind their own `mousedown` listener.

`flat_pack/positioning` places a panel from an anchor rect: preferred side, optional flip to the opposite side, then clamp to `--overlay-edge-offset`. Popover flips and lets an oversized panel sit past the edge. Button dropdown passes `flip: false` and `stickToEdge: true`, so an oversized menu stays on the edge. Date picker places below, or above when below does not fit, with `stickToEdge: true`. Its width cap and the max-width 767px full-screen panel stay in the date picker controller. Collection editor places its search menu under the field (`bottom_left`, 4px gap, `stickToEdge: true`) and then keeps the field's left edge. A missing pin stops those four controllers. Tooltip still places itself.

`flat_pack/remote_query` is `createRemoteQuery`: a debounce timer, an abort of the previous request, and a JSON `GET`. Select, Picker, Search, and Combobox import it. Each still owns its wait, extra query params, and response shape. A missing pin stops those four controllers.

`flat_pack/reorder_items` is `buildItems`. Table sortable and grid sortable import it to build `{ id, position }` rows. `id` is the string from `data-id`. A missing pin stops those two controllers.

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

pin "flat_pack/local_time", to: "flat_pack/local_time.js", preload: false
pin "flat_pack/copy", to: "flat_pack/copy.js", preload: false
pin "flat_pack/clipboard", to: "flat_pack/clipboard.js", preload: false
pin "flat_pack/focus_trap", to: "flat_pack/focus_trap.js", preload: false
pin "flat_pack/click_outside", to: "flat_pack/click_outside.js", preload: false
pin "flat_pack/positioning", to: "flat_pack/positioning.js", preload: false
pin "flat_pack/remote_query", to: "flat_pack/remote_query.js", preload: false
pin "flat_pack/reorder_items", to: "flat_pack/reorder_items.js", preload: false

# Heroicons icon banks — served as a local JS module, no gem required
pin "flat_pack/heroicons", to: "flat_pack/heroicons.js", preload: false
```

### Icon Rendering

FlatPack icons are rendered entirely client-side via the `flat-pack--icon` Stimulus controller. The component emits an SVG shell with `data-controller`, `data-flat-pack--icon-name-value`, and `data-flat-pack--icon-variant-value` attributes. The controller imports icon path data from `flat_pack/heroicons` (an importmap-pinned module) and injects the correct SVG paths at runtime.

This means:
- No server-side SVG sprite partial is required in the host layout.
- Icons support `:outline`, `:solid`, `:mini`, and `:micro` variants.
- Outline stroke is `--icon-stroke-width` (default `1.5`, the Heroicons outline weight). The Stimulus controller writes the same token; kit CSS reapplies it on `svg[data-controller~="flat-pack--icon"][stroke]` so solid/mini/micro fills are not thickened after they drop the `stroke` attribute.
- Host apps can set a global default with `FlatPack.configure { |config| config.default_icon_variant = :outline }`.
- Icon names follow [Heroicons v2](https://heroicons.com) canonical names (e.g. `magnifying-glass`, `cog-6-tooth`, `exclamation-triangle`). A set of legacy shorthand aliases (e.g. `search`, `settings`, `alert`) are mapped internally for backward compatibility.
- Handle-heavy artwork (`magnifying-glass`, `paper-airplane`, `pencil`, `pencil-square`, `arrow-up-tray`, `arrow-down-tray`) gets `-translate-y-0.5` via `IconComponent::OPTICAL_NUDGES`. Add names there instead of per-component CSS.
- Names that include `-left` or `-right` as a travel or alignment direction get `fp-icon-directional` and flip in `[dir="rtl"]` with CSS `scale` (so a translate nudge still applies). Chat-bubble tails (`chat-bubble-left*`) are excluded. Vertical chevrons, checks, and media playback do not flip.

## Tailwind CSS 4 Integration

### CSS-First Approach

Tailwind CSS 4 uses a CSS-first configuration model:

1. **No `tailwind.config.js`** - Configuration via CSS
2. **`@theme` / `@theme inline` directive** - Register theme names in CSS. FlatPack uses `@theme inline` plus concrete `:root` values.
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

> **Note:** FlatPack CSS variables are loaded via `stylesheet_link_tag` in the layout, not via `@import` inside the Tailwind build file. The install generator adds `@source` for component scanning only. Tokens stay in `flat_pack/variables`; Propshaft serves those stylesheets from digested URLs. Load the host stylesheet after the gem tags so `--brand-hue` / `--brand-chroma` / `--brand-lightness` overrides apply.

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
   <%= stylesheet_link_tag "flat_pack/application", "data-turbo-track": "reload" %>
   <%= stylesheet_link_tag "flat_pack/rich_text", "data-turbo-track": "reload" %>
   ```
   Avoid a bare `@import "flat_pack/variables.css"` in a Propshaft-served stylesheet. Propshaft serves files at fingerprinted URLs, and `CssAssetUrls` only rewrites `url()`. `@import url("variables.css")` from a sibling in the same directory is rewritten.

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

## Next Steps

- [Tailwind CSS 4 Integration](tailwind_4.md)
- [Engine Architecture](engine.md)
- [Theming Guide](../theming.md)
