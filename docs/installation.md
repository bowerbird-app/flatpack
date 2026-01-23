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
- Displays instructions for Tailwind CSS 4 configuration
- Shows next steps for using components

### 4. Configure Tailwind CSS 4 to Scan FlatPack Components

**For Tailwind CSS 4 (via tailwindcss-rails):**

Configure `app/assets/tailwind/application.css` with the `@source` directive and FlatPack theme variables.

**First, find your gem path:**

```bash
bundle show flat_pack
```

This will output the full path, e.g., `/usr/local/bundle/ruby/3.3.0/bundler/gems/flatpack-26b6f5d354a7`

**Then configure your `app/assets/tailwind/application.css`:**

```css
@import "tailwindcss";

/* Tailwind CSS - Scan FlatPack components for classes */
@source "../../../../../../usr/local/bundle/ruby/3.3.0/bundler/gems/flatpack-YOURHASH/app/components";

/* Extend Tailwind theme with FlatPack color system */
@theme {
  --color-fp-primary: oklch(0.42 0.18 165);
  --color-fp-primary-hover: oklch(0.38 0.18 165);
  --color-fp-primary-text: oklch(1.0 0 0);
  --color-fp-secondary: oklch(0.96 0 0);
  --color-fp-secondary-hover: oklch(0.93 0 0);
  --color-fp-secondary-text: oklch(0.29 0.01 250);
  --color-fp-ghost: transparent;
  --color-fp-ghost-hover: oklch(0.96 0 0);
  --color-fp-ghost-text: oklch(0.40 0.01 250);
  --color-fp-border: oklch(0.85 0 0);
  --shadow-fp-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --radius-md: 0.375rem;
  --transition-base: 150ms;
  --color-ring: oklch(0.42 0.18 165);
  
  /* Define theme colors for Tailwind utility classes */
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

**Important Notes:**
- Replace `YOURHASH` with the actual git hash from `bundle show flat_pack`
- The `@source` path must be relative to the `application.css` file
- The path depth may vary: count `../` segments from `app/assets/tailwind/` to root, then to the bundle path
- All CSS variables used by FlatPack components must be defined in the `@theme` block
- After updating, rebuild Tailwind: `bin/rails tailwindcss:build`

**✅ This has been completed** - The configuration has been added to `app/assets/tailwind/application.css`.

### 5. Add FlatPack CSS Variables (Optional Customization)

If you want to customize the theme, add CSS variables to `app/assets/stylesheets/application.css`:

```css
:root {
  --color-primary: oklch(0.52 0.26 250);
  --color-primary-hover: oklch(0.42 0.24 250);
  --color-primary-text: oklch(1.0 0 0);
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.20 0.01 250);
  /* Add other variables as needed */
}
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

## Verification

Test the installation by adding a FlatPack button component to a view:

```erb
<%# Example: app/views/pages/home.html.erb %>
<%= render FlatPack::Button::Component.new(
  label: "Test Button",
  scheme: :primary
) %>
```

Visit the page in your browser. You should see a styled button.

## Available Components

FlatPack currently provides:

- **Button** - Buttons and links with multiple schemes (`:primary`, `:secondary`, `:ghost`)
- **Table** - Data tables with columns and actions
- **Icon** - Shared icon component

## Quick Start Examples

### Button Component

```erb
<%= render FlatPack::Button::Component.new(
  label: "Click me",
  scheme: :primary
) %>
```

### Table Component

```erb
<%= render FlatPack::Table::Component.new(rows: @users) do |table| %>
  <% table.with_column(label: "Name", attribute: :name) %>
  <% table.with_column(label: "Email", attribute: :email) %>
  <% table.with_action(label: "Edit", url: ->(user) { edit_user_path(user) }) %>
<% end %>
```

## Custom Installation Scripts

The FlatPack gem includes a custom Rails generator (`flat_pack:install`) which is the recommended installation method. There are no additional shell scripts or manual installation scripts required.

## Required Initializers

FlatPack does not require any custom initializers. The gem is designed for zero-config installation and works out of the box with the tailwindcss-rails gem.

## Troubleshooting

### Styles Not Applying

1. Check that Tailwind CSS is installed:
   ```bash
   bundle info tailwindcss-rails
   ```

2. Find your FlatPack gem path and verify the `@source` path in your `app/assets/tailwind/application.css` is correct:
   ```bash
   bundle show flat_pack
   ```
   
   The output will show the full path. Use this to update the `@source` directive with the correct git hash.

3. Ensure all required CSS variables are defined in the `@theme` block:
   - Color variables: `--color-fp-primary`, `--color-fp-secondary`, `--color-fp-ghost`, etc.
   - Supporting variables: `--radius-md`, `--transition-base`, `--color-ring`, `--color-border`
   - These must be in `@theme` to work with arbitrary values like `bg-[var(--color-secondary)]`

4. Rebuild Tailwind CSS:
   ```bash
   bin/rails tailwindcss:build
   ```

5. Restart the Rails server

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

1. Verify Stimulus is installed (should already be installed):
   ```bash
   bundle info stimulus-rails
   ```

2. Check importmap configuration:
   ```bash
   bin/rails importmap:audit
   ```

## Documentation

For more information, see the FlatPack documentation:

- [Full Documentation](https://github.com/bowerbird-app/flatpack/tree/main/docs/)
- [Theming Guide](https://github.com/bowerbird-app/flatpack/blob/main/docs/theming.md)
- [Dark Mode Guide](https://github.com/bowerbird-app/flatpack/blob/main/docs/dark_mode.md)
- [Component Documentation](https://github.com/bowerbird-app/flatpack/tree/main/docs/components/)

## Summary

The installation process for FlatPack is straightforward:

1. ✅ Add gem to Gemfile (completed)
2. ✅ Run `bundle install` (completed - updated to v0.1.1)
3. ✅ Run `rails generate flat_pack:install` (completed)
4. ✅ Add Tailwind CSS `@source` comment to application.css (completed)
5. Restart Rails server when ready
6. Start using FlatPack components in your views

No custom installation scripts or required initializers are needed beyond the standard Rails generator.

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
