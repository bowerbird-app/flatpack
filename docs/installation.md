# FlatPack Gem Installation Guide

This document provides the exact terminal commands and configuration steps needed to install and initialize the FlatPack Ruby gem from the GitHub repository `bowerbird-app/flatpack` in this project.

## Overview

FlatPack is a modern Rails 8 UI Component Library built with ViewComponent, Tailwind CSS, and Hotwire. It provides type-safe, testable components with dark mode support and accessibility features.

**Current Version:** 0.1.1 (Updated January 23, 2026)

## Prerequisites

- Rails 8.0+
- Ruby 3.2+
- Tailwind CSS via tailwindcss-rails gem (version 3.x or 4.x) - ✓ Already installed in this project
- Propshaft (asset pipeline) - ✓ Already installed in this project  
- Importmaps (JavaScript) - ✓ Already installed in this project

**Note:** FlatPack works with both Tailwind CSS 3 and 4. This project uses Tailwind CSS 4 via the tailwindcss-rails gem.

## Installation Steps

### 1. Add FlatPack to Gemfile

The gem has already been added to the Gemfile:

```ruby
gem "flat_pack", github: "bowerbird-app/flatpack"
```

### 2. Install Dependencies

Run bundle install to install the gem:

```bash
bundle install
```

**Note:** Since the gem is hosted on GitHub, bundle install will use your configured git credentials to access the repository. The flatpack repository is public, so no special authentication is required.

### 3. Run the FlatPack Install Generator

FlatPack provides a custom Rails generator that automates the installation:

```bash
rails generate flat_pack:install
```

**What the generator does:**
- Adds `@import "flat_pack/variables.css";` to your `app/assets/stylesheets/application.css`
- **Automatically configures Tailwind CSS 4** by detecting your Tailwind CSS file and injecting the necessary configuration
- **Configures importmap** to load FlatPack Stimulus controllers
- **Configures Stimulus** to eager load FlatPack controllers
- Shows next steps for using components

### 4. Configure Tailwind CSS 4 to Scan FlatPack Components

**✨ Automated Configuration (Recommended)**

The `rails generate flat_pack:install` command now **automatically configures Tailwind CSS 4** for you! The generator will:

1. **Detect** your Tailwind CSS 4 configuration file (checks common locations like `app/assets/stylesheets/application.tailwind.css`)
2. **Calculate** the correct relative path from your Tailwind file to the FlatPack gem components
3. **Inject** the `@source` directive with the correct path
4. **Add** the `@theme` block with all FlatPack design tokens (colors, shadows, radius, transitions)
5. **Map** CSS variables to `:root` for component compatibility

**The generator automatically adds:**

```css
/* Tailwind CSS - Scan FlatPack components for classes */
@source "../path/to/flat_pack/app/components";

/* Extend Tailwind theme with FlatPack design tokens */
@theme {
  /* Primary Button Colors */
  --color-fp-primary: oklch(0.52 0.26 250);
  --color-fp-primary-hover: oklch(0.42 0.24 250);
  --color-fp-primary-text: oklch(1.0 0 0);
  
  /* Secondary Button Colors */
  --color-fp-secondary: oklch(0.95 0.01 250);
  --color-fp-secondary-hover: oklch(0.90 0.02 250);
  --color-fp-secondary-text: oklch(0.25 0.02 250);
  
  /* Ghost Button Colors */
  --color-fp-ghost: transparent;
  --color-fp-ghost-hover: oklch(0.96 0.01 250);
  --color-fp-ghost-text: oklch(0.35 0.02 250);
  
  /* Border and Ring Colors */
  --color-fp-border: oklch(0.89 0.01 250);
  --color-ring: oklch(0.52 0.26 250);
  
  /* Design tokens */
  --shadow-fp-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --radius-md: 0.375rem;
  --transition-base: 200ms cubic-bezier(0.4, 0, 0.2, 1);
  
  /* Map to Tailwind utility class names */
  --color-primary: var(--color-fp-primary);
  --color-primary-hover: var(--color-fp-primary-hover);
  --color-primary-text: var(--color-fp-primary-text);
  --color-secondary: var(--color-fp-secondary);
  --color-secondary-hover: var(--color-fp-secondary-hover);
  --color-secondary-text: var(--color-fp-secondary-text);
  --color-ghost: var(--color-fp-ghost);
  --color-ghost-hover: var(--color-fp-ghost-hover);
  --color-ghost-text: var(--color-fp-ghost-text);
  --color-border: var(--color-fp-border);
}

/* Map FlatPack CSS variables to :root for component compatibility */
:root {
  --color-primary: var(--color-fp-primary);
  --color-primary-hover: var(--color-fp-primary-hover);
  --color-primary-text: var(--color-fp-primary-text);
  --color-secondary: var(--color-fp-secondary);
  --color-secondary-hover: var(--color-fp-secondary-hover);
  --color-secondary-text: var(--color-fp-secondary-text);
  --color-ghost: var(--color-fp-ghost);
  --color-ghost-hover: var(--color-fp-ghost-hover);
  --color-ghost-text: var(--color-fp-ghost-text);
  --color-border: var(--color-fp-border);
  --shadow-sm: var(--shadow-fp-sm);
  --radius-md: var(--radius-md);
  --transition-base: var(--transition-base);
  --color-ring: var(--color-ring);
}
```

**After the generator runs:**
- Rebuild Tailwind CSS: `bin/rails tailwindcss:build`
- Restart your Rails server

**Manual Configuration (If Automatic Detection Fails)**

If the generator cannot automatically detect your Tailwind CSS 4 file, it will display instructions for manual configuration. You can also manually configure by:

1. Finding your gem path:
   ```bash
   bundle show flat_pack
   ```

2. Adding the configuration to your Tailwind CSS file (e.g., `app/assets/stylesheets/application.tailwind.css`) using the example above, replacing the `@source` path with the correct relative path to your gem's `app/components` directory.

### 5. Add FlatPack CSS Variables (Optional Customization)

If you want to customize the theme, add CSS variables to `app/assets/stylesheets/application.css`:

```css
:root {
  --color-primary: var(--color-fp-primary);
  --color-primary-hover: var(--color-fp-primary-hover);
  --color-primary-text: var(--color-fp-primary-text);
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.20 0.01 250);
  /* Add other variables as needed */
}
```

### 5. JavaScript Controllers Configuration (Automatic)

**✨ Automated Configuration**

The install generator automatically configures JavaScript imports for FlatPack's Stimulus controllers:

**In `config/importmap.rb`:**
```ruby
# Pin FlatPack controllers
pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), 
             under: "controllers/flat_pack", 
             to: "flat_pack/controllers"
```

**In `app/javascript/controllers/index.js`:**
```javascript
// Eager load FlatPack controllers
eagerLoadControllersFrom("controllers/flat_pack", application)
```

**Why eager loading?** FlatPack controllers are eagerly loaded (not lazy loaded) to ensure they're available immediately on page load, including hard refreshes. This prevents timing issues where controllers might not be registered when components are rendered.

**Manual Configuration (if needed):**

If you need to manually configure the JavaScript controllers:

1. Add to `config/importmap.rb`:
   ```ruby
   pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), 
                under: "controllers/flat_pack", 
                to: "flat_pack/controllers"
   ```

2. Add to `app/javascript/controllers/index.js`:
   ```javascript
   import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
   eagerLoadControllersFrom("controllers/flat_pack", application)
   ```

### 6. Configure Tailwind CSS Content Paths (If Needed)

If a `config/tailwind.config.js` file exists, ensure it includes the FlatPack components path:

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

### 7. Restart Your Rails Server

After installation, restart the Rails server:

```bash
bin/rails server
```

Or if using Foreman:

```bash
bin/dev
```

## Verification

Test the installation by adding a FlatPack button component to a view:

```erb
<%# Example: app/views/pages/home.html.erb %>
<%= render FlatPack::Button::Component.new(
  text: "Test Button",
  style: :primary
) %>
```

Visit the page in your browser. You should see a styled button.

## Available Components

FlatPack currently provides:

- **Button** - Buttons and links with multiple schemes (`:primary`, `:secondary`, `:ghost`)
- **Table** - Data tables with configurable columns
- **Icon** - Shared icon component

## Quick Start Examples

### Button Component

```erb
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  scheme: :primary
) %>
```

### Table Component

```erb
<%= render FlatPack::Table::Component.new(data: @users) do |table| %>
  <% table.column(title: "Name", html: ->(row) { row.name }) %>
  <% table.column(title: "Email", html: ->(row) { row.email }) %>
<% end %>
```

## Custom Installation Scripts

The FlatPack gem includes a custom Rails generator (`flat_pack:install`) which is the recommended installation method. There are no additional shell scripts or manual installation scripts required.

## Required Initializers

FlatPack does not require any custom initializers. The gem is designed for zero-config installation and works out of the box with the tailwindcss-rails gem.

## Troubleshooting

### Automatic Configuration Issues

If the install generator didn't automatically configure Tailwind CSS 4:

1. **Check if Tailwind CSS 4 is installed:**
   ```bash
   bundle info tailwindcss-rails
   ```

2. **Verify your Tailwind CSS file uses the v4 syntax:**
   The generator looks for `@import "tailwindcss"` (Tailwind CSS 4) instead of `@tailwind` directives (Tailwind CSS 3).
   
   Common locations checked:
   - `app/assets/stylesheets/application.tailwind.css`
   - `app/assets/stylesheets/application.css`
   - `app/assets/tailwind/application.css`

3. **Run the generator again with debug output:**
   ```bash
   DEBUG=true rails generate flat_pack:install
   ```

4. **Manually verify the configuration was added:**
   Check your Tailwind CSS file for the `@source` directive and `@theme` block.

### Styles Not Applying

1. **Verify the `@source` path is correct:**
   ```bash
   bundle show flat_pack
   ```
   
   The output shows the full path. The `@source` directive in your Tailwind file should point to this path's `app/components` directory using a relative path.

2. **Ensure all required CSS variables are defined:**
   The generator automatically adds these to the `@theme` block:
   - Color variables: `--color-fp-primary`, `--color-fp-secondary`, `--color-fp-ghost`, etc.
   - Supporting variables: `--radius-md`, `--transition-base`, `--color-ring`, `--color-border`
   - These must be in `@theme` to work with arbitrary values like `bg-[var(--color-secondary)]`

3. **Rebuild Tailwind CSS:**
   ```bash
   bin/rails tailwindcss:build
   ```

4. **Restart the Rails server**

### Components Not Found

1. Verify the gem is installed:
   ```bash
   bundle info flat_pack
   ```

2. Check autoloading:
   ```bash
   bin/rails zeitwerk:check
   ```

3. Restart the Rails server

### JavaScript Not Working

If FlatPack Stimulus controllers are not working (e.g., password toggle, file upload preview, auto-expanding textareas):

1. **Check browser console** for controller loading errors

2. **Verify importmap configuration:**
   ```bash
   bin/rails runner "puts Rails.application.importmap.packages.keys.grep(/flat_pack/)"
   ```
   Should show: `controllers/flat_pack/text_area_controller`, `controllers/flat_pack/password_input_controller`, etc.

3. **Check controllers/index.js:**
   ```bash
   grep -n "flat_pack" app/javascript/controllers/index.js
   ```
   Should show: `eagerLoadControllersFrom("controllers/flat_pack", application)`

4. **Verify Stimulus is installed:**
   ```bash
   bundle info stimulus-rails
   ```

5. **Hard refresh the page** (Cmd+R or Ctrl+R) to reload JavaScript

**Common issue:** If controllers work on Turbo navigation but not on hard refresh, make sure you're using `eagerLoadControllersFrom` (not `lazyLoadControllersFrom`) for FlatPack controllers.

### Importmap "skipped missing path" Errors

If you see errors like `Importmap skipped missing path: controllers/flat_pack/text_area_controller.js`:

1. **Check the `to:` parameter** in your importmap configuration:
   ```ruby
   # config/importmap.rb
   pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), 
                under: "controllers/flat_pack", 
                to: "flat_pack/controllers"  # This is required!
   ```

2. **Restart the Rails server** after changing importmap configuration

3. **Verify asset paths:**
   ```bash
   bin/rails runner "puts Rails.application.config.assets.paths.grep(/flat_pack/)"
   ```

## Documentation

For more information, see the FlatPack documentation:

- [Full Documentation](https://github.com/bowerbird-app/flatpack/tree/main/docs/)
- [Theming Guide](https://github.com/bowerbird-app/flatpack/blob/main/docs/theming.md)
- [Dark Mode Guide](https://github.com/bowerbird-app/flatpack/blob/main/docs/dark_mode.md)
- [Component Documentation](https://github.com/bowerbird-app/flatpack/tree/main/docs/components/)

## Summary

The installation process for FlatPack is now fully automated:

1. ✅ Add gem to Gemfile
2. ✅ Run `bundle install`
3. ✅ Run `rails generate flat_pack:install` - **Now automatically configures Tailwind CSS 4!**
4. Rebuild Tailwind CSS: `bin/rails tailwindcss:build`
5. Restart Rails server
6. Start using FlatPack components in your views

**What's Automated:**
- ✨ Automatic detection of Tailwind CSS 4 configuration file
- ✨ Automatic calculation of relative paths to FlatPack gem components
- ✨ Automatic injection of `@source` directive
- ✨ Automatic injection of `@theme` block with all FlatPack design tokens
- ✨ Automatic mapping of CSS variables to `:root` for component compatibility

No manual path finding, no manual copying of CSS variables, no manual configuration - just run the generator and you're ready to go!

## Recent Updates

### Tailwind CSS 4 Integration Fix (January 23, 2026)

**What Changed:**
- Updated `@source` directive path to match actual FlatPack gem location
- Added missing CSS variables to `@theme` block: `--radius-md`, `--transition-base`, `--color-ring`
- Added all variables to `:root` for full component compatibility

**Why This Was Needed:**
- FlatPack button components use arbitrary value classes like `bg-[var(--color-secondary)]`
- Tailwind CSS 4 requires CSS variables to be defined in the `@theme` block to work with arbitrary values
- The `@source` directive must point to the exact gem path (including git hash) for Tailwind to scan component files

**How to Apply:**
1. Run `bundle show flat_pack` to get the correct gem path
2. Update the `@source` path in `app/assets/tailwind/application.css`
3. Ensure all CSS variables from the example above are in your `@theme` block
4. Run `bin/rails tailwindcss:build` to regenerate the CSS
5. Refresh your browser

### Version 0.1.1 (January 23, 2026)

This update includes important fixes for Tailwind CSS 4 class detection:

**What's Fixed:**
- Added safelist comments to Button and Icon components
- All Tailwind classes stored in Ruby constants (SCHEMES, SIZES, ICON_ONLY_SIZES) are now properly detected by Tailwind CSS 4's `@source` directive
- Button component: Added safelist comments for 18 scheme classes, 9 size classes, and 3 icon-only size classes
- Icon component: Added safelist comments for 8 size classes

**Impact:**
- Ensures all FlatPack component styles are properly generated by Tailwind CSS 4
- No breaking changes - this is a patch release
- No action required beyond updating the gem

**How to Update:**
```bash
bundle update flat_pack
rails generate flat_pack:install  # Re-run if needed
```

For full changelog, see: [FlatPack CHANGELOG](https://github.com/bowerbird-app/flatpack/blob/main/CHANGELOG.md)
