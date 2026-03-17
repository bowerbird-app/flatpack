# FlatPack Gem Installation Guide

This document provides the exact terminal commands and configuration steps needed to install and initialize the FlatPack Ruby gem from the GitHub repository `bowerbird-app/flatpack` in this project.

## Overview

FlatPack is a modern Rails 8 UI Component Library built with ViewComponent, Tailwind CSS, and Hotwire. It provides type-safe, testable components with dark mode support and accessibility features.

**Current Version:** 0.1.1 (Updated January 23, 2026)

## Prerequisites

- Rails 8.0+
- Ruby 3.2+
- Tailwind CSS via tailwindcss-rails gem (version 4.x) - ✓ Already installed in this project
- Propshaft (asset pipeline) - ✓ Already installed in this project  
- Importmaps (JavaScript) - ✓ Already installed in this project

**Note:** FlatPack is built for Tailwind CSS 4. This project uses Tailwind CSS 4 via the tailwindcss-rails gem.

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
- **Configures Stimulus** to lazy load FlatPack controllers on first use
- Shows next steps for using components

### 3.1 Optional: Generate a Sidebar Layout Shell

FlatPack also provides a layout generator for creating a starter application shell based on `SidebarLayout` + `TopNav`:

```bash
rails generate flat_pack:layout --type=sidebar
```

**What this generator creates:**
- `app/views/layouts/flat_pack_sidebar.html.erb`
- `app/views/layouts/flat_pack/_sidebar.html.erb`
- `app/views/layouts/flat_pack/_top_nav.html.erb`

**Supported options:**

```bash
rails generate flat_pack:layout \
   --type=sidebar \
   --layout_name=flat_pack_sidebar \
   --side=left \
   --storage_key=flat-pack-sidebar-layout
```

- `--type`: layout type to generate (currently: `sidebar`)
- `--layout_name`: layout filename under `app/views/layouts` (without `.html.erb`)
- `--side`: sidebar placement (`left` or `right`)
- `--storage_key`: localStorage key used by `FlatPack::SidebarLayout::Component`

After generation, set the layout in your controller (for example `ApplicationController`) and update the generated sidebar/top-nav partials to match your app routes and actions.

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
             to: "flat_pack/controllers",
             preload: false
```

**In `app/javascript/controllers/index.js`:**
```javascript
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"

// Lazy load FlatPack controllers on first use
lazyLoadControllersFrom("controllers/flat_pack", application)
```

**Why lazy loading?** FlatPack controllers are loaded when matching `data-controller` attributes appear, which reduces initial JavaScript requests and improves first-page load performance in apps that only use a subset of components per page.

**Why `preload: false`?** Importmap modulepreload is disabled for FlatPack controller pins so the browser does not fetch every controller on first page load.

**Manual Configuration (if needed):**

If you need to manually configure the JavaScript controllers:

1. Add to `config/importmap.rb`:
   ```ruby
   pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), 
                under: "controllers/flat_pack", 
                to: "flat_pack/controllers",
                preload: false
   ```

2. Add to `app/javascript/controllers/index.js`:
   ```javascript
   import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
   lazyLoadControllersFrom("controllers/flat_pack", application)
   ```

### 5.2 JavaScript Controllers — esbuild / Custom Build Pipeline (Non-Importmap Apps)

The automatic install generator configures FlatPack controllers for **importmap-based** apps only. If your app uses **esbuild, Webpack, Vite, or any other bundler**, the FlatPack Stimulus controllers will **not** be loaded automatically — and interactive components such as the sidebar collapse/expand, modals, popovers, tooltips, and tabs will silently fail.

**Root cause:** The `flat-pack--sidebar-layout` controller (and all other FlatPack Stimulus controllers) must be explicitly imported and registered in a bundled app. The importmap setup serves each controller file individually via Rails' asset pipeline; a custom bundler bypasses this entirely.

#### 1. Install npm dependencies

```bash
npm install --save-dev @hotwired/stimulus esbuild
```

#### 2. Create a build script

Create `scripts/build_stimulus.js` in your app root (create the `scripts/` directory if it does not exist):

```javascript
// scripts/build_stimulus.js
// Dynamically resolves the FlatPack gem path so the bundle always uses the
// currently-installed version. This is critical for git-sourced gems whose
// path contains a hash (e.g. flat_pack-abc1234/).
const { execSync, spawnSync } = require("child_process")
const { writeFileSync, mkdirSync } = require("fs")
const path = require("path")

const flatpackRoot = execSync("bundle show flat_pack").toString().trim()
const controllersDir = path.join(flatpackRoot, "app/javascript/flat_pack/controllers")

// Import all FlatPack controllers.
const entry = `
import { Application } from "@hotwired/stimulus";
import AccordionController        from "${controllersDir}/accordion_controller.js";
import AlertController            from "${controllersDir}/alert_controller.js";
import BadgeController            from "${controllersDir}/badge_controller.js";
import ButtonDropdownController   from "${controllersDir}/button_dropdown_controller.js";
import CarouselController         from "${controllersDir}/carousel_controller.js";
import ChartController            from "${controllersDir}/chart_controller.js";
import ChatGroupingController     from "${controllersDir}/chat_grouping_controller.js";
import ChatImageDeckController    from "${controllersDir}/chat_image_deck_controller.js";
import ChatMessageActionsController from "${controllersDir}/chat_message_actions_controller.js";
import ChatScrollController       from "${controllersDir}/chat_scroll_controller.js";
import ChatSenderController       from "${controllersDir}/chat_sender_controller.js";
import ChipController             from "${controllersDir}/chip_controller.js";
import CodeBlockTabsController    from "${controllersDir}/code_block_tabs_controller.js";
import CollapseController         from "${controllersDir}/collapse_controller.js";
import ContentEditorController    from "${controllersDir}/content_editor_controller.js";
import DateInputController        from "${controllersDir}/date_input_controller.js";
import FileInputController        from "${controllersDir}/file_input_controller.js";
import FormValidationController   from "${controllersDir}/form_validation_controller.js";
import GridSortableController     from "${controllersDir}/grid_sortable_controller.js";
import IconController             from "${controllersDir}/icon_controller.js";
import ListSelectableController   from "${controllersDir}/list_selectable_controller.js";
import ModalController            from "${controllersDir}/modal_controller.js";
import NavbarController           from "${controllersDir}/navbar_controller.js";
import PaginationInfiniteController from "${controllersDir}/pagination_infinite_controller.js";
import PasswordInputController    from "${controllersDir}/password_input_controller.js";
import PickerController           from "${controllersDir}/picker_controller.js";
import PopoverController          from "${controllersDir}/popover_controller.js";
import RangeInputController       from "${controllersDir}/range_input_controller.js";
import SearchController           from "${controllersDir}/search_controller.js";
import SearchInputController      from "${controllersDir}/search_input_controller.js";
import SectionTitleAnchorController from "${controllersDir}/section_title_anchor_controller.js";
import SelectController           from "${controllersDir}/select_controller.js";
import SidebarController          from "${controllersDir}/sidebar_controller.js";
import SidebarGroupController     from "${controllersDir}/sidebar_group_controller.js";
import SidebarLayoutController    from "${controllersDir}/sidebar_layout_controller.js";
import TableController            from "${controllersDir}/table_controller.js";
import TableSortableController    from "${controllersDir}/table_sortable_controller.js";
import TabsController             from "${controllersDir}/tabs_controller.js";
import TextAreaController         from "${controllersDir}/text_area_controller.js";
import ThemeController            from "${controllersDir}/theme_controller.js";
import TiptapController           from "${controllersDir}/tiptap_controller.js";
import ToastController            from "${controllersDir}/toast_controller.js";
import ToastsRegionController     from "${controllersDir}/toasts_region_controller.js";
import TooltipController          from "${controllersDir}/tooltip_controller.js";

const application = Application.start();
application.register("flat-pack--accordion",           AccordionController);
application.register("flat-pack--alert",               AlertController);
application.register("flat-pack--badge",               BadgeController);
application.register("flat-pack--button-dropdown",     ButtonDropdownController);
application.register("flat-pack--carousel",            CarouselController);
application.register("flat-pack--chart",               ChartController);
application.register("flat-pack--chat-grouping",       ChatGroupingController);
application.register("flat-pack--chat-image-deck",     ChatImageDeckController);
application.register("flat-pack--chat-message-actions", ChatMessageActionsController);
application.register("flat-pack--chat-scroll",         ChatScrollController);
application.register("flat-pack--chat-sender",         ChatSenderController);
application.register("flat-pack--chip",                ChipController);
application.register("flat-pack--code-block-tabs",     CodeBlockTabsController);
application.register("flat-pack--collapse",            CollapseController);
application.register("flat-pack--content-editor",      ContentEditorController);
application.register("flat-pack--date-input",          DateInputController);
application.register("flat-pack--file-input",          FileInputController);
application.register("flat-pack--form-validation",     FormValidationController);
application.register("flat-pack--grid-sortable",       GridSortableController);
application.register("flat-pack--icon",                IconController);
application.register("flat-pack--list-selectable",     ListSelectableController);
application.register("flat-pack--modal",               ModalController);
application.register("flat-pack--navbar",              NavbarController);
application.register("flat-pack--pagination-infinite", PaginationInfiniteController);
application.register("flat-pack--password-input",      PasswordInputController);
application.register("flat-pack--picker",              PickerController);
application.register("flat-pack--popover",             PopoverController);
application.register("flat-pack--range-input",         RangeInputController);
application.register("flat-pack--search",              SearchController);
application.register("flat-pack--search-input",        SearchInputController);
application.register("flat-pack--section-title-anchor", SectionTitleAnchorController);
application.register("flat-pack--select",              SelectController);
application.register("flat-pack--sidebar",             SidebarController);
application.register("flat-pack--sidebar-group",       SidebarGroupController);
application.register("flat-pack--sidebar-layout",      SidebarLayoutController);
application.register("flat-pack--table",               TableController);
application.register("flat-pack--table-sortable",      TableSortableController);
application.register("flat-pack--tabs",                TabsController);
application.register("flat-pack--text-area",           TextAreaController);
application.register("flat-pack--theme",               ThemeController);
application.register("flat-pack--tiptap",              TiptapController);
application.register("flat-pack--toast",               ToastController);
application.register("flat-pack--toasts-region",       ToastsRegionController);
application.register("flat-pack--tooltip",             TooltipController);
`.trim()

const tmpDir = path.join(__dirname, "../tmp")
mkdirSync(tmpDir, { recursive: true })
const entryPath = path.join(tmpDir, "flatpack_stimulus_entry.js")
writeFileSync(entryPath, entry)

const result = spawnSync(
  "npx",
  [
    "esbuild", entryPath,
    "--bundle",
    "--format=iife",
    "--outfile=app/assets/javascripts/stimulus_controllers.js"
  ],
  { stdio: "inherit" }
)

if (result.status !== 0) process.exit(result.status)
console.log("FlatPack Stimulus bundle written to app/assets/javascripts/stimulus_controllers.js")
```

#### 3. Add an npm build script

In `package.json`, add to the `scripts` section:

```json
{
  "scripts": {
    "build:stimulus": "node scripts/build_stimulus.js"
  }
}
```

#### 4. Run the build

```bash
npm run build:stimulus
```

This generates `app/assets/javascripts/stimulus_controllers.js` — a self-contained IIFE that boots Stimulus and registers all selected FlatPack controllers.

#### 5. Include the bundle in your layout

In your application layout (e.g., `app/views/layouts/application.html.erb`), add the script tag **before** your other application JavaScript:

```erb
<%# FlatPack Stimulus controllers — must load before scripts that depend on them %>
<%= javascript_include_tag "stimulus_controllers", defer: true %>
```

**Important:** `stimulus_controllers.js` must be placed in `app/assets/javascripts/` (or another directory on the Propshaft/Sprockets asset path) so Rails can serve and fingerprint it.

#### 6. Rebuild after FlatPack updates

After running `bundle update flat_pack`, regenerate the bundle because the gem path (which includes a git hash) will have changed:

```bash
npm run build:stimulus
```

Add this to your CI / deploy pipeline to keep the bundle current automatically.

**Sidebar localStorage key:** The `flat-pack--sidebar-layout` controller persists the sidebar open/closed state in localStorage. The key is controlled by the `data-flat-pack--sidebar-layout-storage-key-value` attribute on the controller element. The generated sidebar template defaults to `flat-pack-sidebar-layout`. Override it per layout if you need app-specific namespacing:

```erb
<div data-controller="flat-pack--sidebar-layout"
     data-flat-pack--sidebar-layout-storage-key-value="my-app-sidebar">
```

### 6. Verify Tailwind CSS Source Scanning

Tailwind CSS 4 scans files via `@source` directives in your CSS file (no `tailwind.config.js` required).

Ensure your Tailwind CSS file includes a FlatPack source path similar to:

```css
@import "tailwindcss";
@source "../../../flat_pack/app/components";
```

Use the path that matches your environment. If needed, run `bundle show flat_pack` and calculate the correct relative path to the gem's `app/components` directory.

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

2. **Verify your Tailwind CSS file uses Tailwind 4 syntax:**
   The generator looks for `@import "tailwindcss"` and `@source` directives.
   
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

### FlatPack Styles Missing When Using a Custom CSS Build Pipeline

**Root cause:** FlatPack components are Ruby files inside the installed gem that contain inline Tailwind class strings (e.g. `"flex items-center gap-3"`, `"bg-[var(--alert-...)]"`). Without an `@source` directive pointing at those files, Tailwind cannot detect those class names and omits them from the compiled output.

This is straightforward when you use a static CSS file that the generator edits. However, if your app has a **custom Rake task** (e.g. `lib/tasks/example_app_tasks.rake`) that assembles a temporary CSS file before invoking the Tailwind build, that temp file is generated at build time and the generator's static `@source` line is never included.

A second form of the same problem: if your app uses a **watch script** (e.g. `bin/tailwind-watch`) that lists files to monitor for changes, that script won't know about FlatPack's `.rb` component files and won't trigger a rebuild when they change.

#### Fix 1 — Dynamic `@source` injection in a custom Rake build task

In the Rake task method that builds the temp CSS input (commonly `build_input_with_flatpack_variables`), resolve `FlatPack::Engine.root` at build time and inject an `@source` line into the temp file **before** the Tailwind CLI is invoked:

```ruby
# lib/tasks/example_app_tasks.rake (inside your build helper method)

# Resolve the FlatPack gem root at build time so the path always matches
# the installed version, regardless of git hash or local path.
flatpack_components = FlatPack::Engine.root.join("app/components").to_s

# Append a Tailwind @source directive to the temp CSS file so Tailwind
# scans FlatPack's Ruby component files for inline class strings.
File.open(temp_css_path, "a") do |f|
  f.puts %(\n@source "#{flatpack_components}/**/*.rb";)
end
```

Key points:
- Use `FlatPack::Engine.root` (not `Gem.find_files` or a hard-coded path) — it resolves correctly for any install location, including git-sourced gems with a hash in the path.
- The `@source` glob must cover `**/*.rb` to reach nested component files.
- Inject **before** the build subprocess is spawned, not after.

#### Fix 2 — Watch FlatPack component files in a custom watch script

If your app uses a custom watch script (e.g. `bin/tailwind-watch`) that decides which files trigger a CSS rebuild, add a helper that locates the FlatPack components directory via Bundler and include its `.rb` files in the watched set:

```ruby
# bin/tailwind-watch (Ruby example, adapt to your script's language/style)

require "bundler/setup"

def flatpack_components_path
  spec = Gem.loaded_specs["flat_pack"] || Bundler.definition.specs.find { |s| s.name == "flat_pack" }
  raise "flat_pack gem not found in bundle" unless spec
  File.join(spec.gem_dir, "app", "components")
end

def get_watched_files
  app_files  = Dir.glob("app/**/*.{rb,erb,html}")
  fp_files   = Dir.glob(File.join(flatpack_components_path, "**", "*.rb"))
  app_files + fp_files
end
```

Key points:
- Discover the gem path via `Gem.loaded_specs` or `Bundler.definition.specs` — never hard-code the path or rely on `bundle show` output captured at script startup.
- Glob for `**/*.rb` inside the gem's `app/components` directory.
- Any change to a FlatPack component `.rb` file will now trigger a rebuild.

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

### Sidebar / Interactive Components Not Working (Non-Importmap Apps)

**Symptom:** The sidebar does not collapse or expand when the chevron button is clicked. Other interactive components (modals, popovers, tooltips, tabs) also appear inert. No JavaScript errors appear in the browser console.

**Root cause:** The `flat-pack--sidebar-layout` Stimulus controller (and all other FlatPack Stimulus controllers) was never registered with the Stimulus application. The install generator only configures FlatPack for importmap-based Rails apps. Apps that use esbuild, Webpack, Vite, or a custom JS build pipeline bypass the importmap setup entirely, so the controllers are never loaded.

**Fix:** Follow the steps in **Section 5.2** above to:

1. Create `scripts/build_stimulus.js` — a Node script that dynamically resolves the FlatPack gem path via `bundle show flat_pack` and bundles the controllers with esbuild.
2. Run `npm run build:stimulus` to generate `app/assets/javascripts/stimulus_controllers.js`.
3. Include the bundle in your layout **before** other scripts using `<%= javascript_include_tag "stimulus_controllers", defer: true %>`.

**Verify the fix:** Open the browser DevTools console. You should see no "Unknown custom element" warnings. Clicking the sidebar chevron should immediately collapse/expand the sidebar, and the state should persist across page reloads via localStorage.

---

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
   Should show: `lazyLoadControllersFrom("controllers/flat_pack", application)`

4. **Verify Stimulus is installed:**
   ```bash
   bundle info stimulus-rails
   ```

5. **Hard refresh the page** (Cmd+R or Ctrl+R) to reload JavaScript

**Common issue:** If controllers are not initializing, verify `data-controller` values match FlatPack controller identifiers (for example, `flat-pack--date-input`) and that `lazyLoadControllersFrom("controllers/flat_pack", application)` is present.

### Importmap "skipped missing path" Errors

If you see errors like `Importmap skipped missing path: controllers/flat_pack/text_area_controller.js`:

1. **Check the `to:` parameter** in your importmap configuration:
   ```ruby
   # config/importmap.rb
   pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), 
                under: "controllers/flat_pack", 
                to: "flat_pack/controllers",
                preload: false  # This is required for lazy loading behavior
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
