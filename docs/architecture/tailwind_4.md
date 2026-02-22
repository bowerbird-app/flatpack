# Tailwind CSS 4 Integration

FlatPack is built for Tailwind CSS 4, which introduces a CSS-first approach to configuration.

## What's New in Tailwind CSS 4

### CSS-First Configuration

No more `tailwind.config.js`. Everything is in CSS:

```css
/* Old way (v3) */
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6'
      }
    }
  }
}

/* New way (v4) */
@theme {
  --color-primary: #3b82f6;
}
```

### `@theme` Directive

Define theme configuration in CSS:

```css
@theme {
  /* Colors */
  --color-brand-500: oklch(0.62 0.22 250);
  
  /* Spacing */
  --spacing-lg: 1.5rem;
  
  /* Border radius */
  --radius-md: 0.375rem;
}
```

### `@source` Comments

Tell Tailwind where to find utility classes:

```css
/* @source "app/views/**/*.html.erb" */
/* @source "app/components/**/*.rb" */
```

## FlatPack's Tailwind Setup

### CSS Variables

FlatPack defines CSS variables in `app/assets/stylesheets/flat_pack/variables.css`:

```css
@theme {
  /* Brand colors */
  --color-brand-500: oklch(0.62 0.22 250);
  --color-brand-600: oklch(0.52 0.26 250);
  
  /* Semantic colors */
  --color-primary: var(--color-brand-600);
  --color-primary-hover: var(--color-brand-700);
  
  /* ... more variables */
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  @theme {
    --color-primary: var(--color-brand-500);
    /* ... adjusted for dark backgrounds */
  }
}
```

### Component Classes

Components use CSS variables via Tailwind utilities:

```ruby
# app/components/flat_pack/button/component.rb
SCHEMES = {
  primary: "bg-[var(--color-primary)] hover:bg-[var(--color-primary-hover)] text-[var(--color-primary-text)]"
}
```

The `[var(--color-primary)]` syntax allows Tailwind to use CSS variables as values.

### Safelist Comments for Ruby Constants

**Important:** Tailwind CSS 4's `@source` directive scans for string literals but cannot detect classes stored in Ruby constants. To ensure all classes are generated, add safelist comments immediately above any constant containing Tailwind classes.

#### Required Format

```ruby
# Tailwind CSS scanning requires these classes to be present as string literals.
# DO NOT REMOVE - These duplicates ensure CSS generation:
# "class1" "class2" "class3" ...
CONSTANT_NAME = {
  key: "class1 class2 class3",
  # ...
}.freeze
```

#### Guidelines for Safelist Comments

1. **Extract all unique classes** - Include every class from all values in the constant
2. **Format as individual quoted strings** - Each class should be `"class-name"`, not `"class1 class2"`
3. **Include complete modifiers** - Keep modifiers intact: `"hover:bg-blue-500"` not `"hover:"` and `"bg-blue-500"`
4. **Preserve arbitrary values** - Include brackets: `"bg-[var(--color-primary)]"`
5. **Place immediately above constant** - No blank line between comment and constant
6. **Use consistent warning** - Always include "DO NOT REMOVE" to prevent accidental deletion

#### Example: Button Component

```ruby
# app/components/flat_pack/button/component.rb
module FlatPack
  module Button
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--color-primary)]" "hover:bg-[var(--color-primary-hover)]" "text-[var(--color-primary-text)]" "shadow-[var(--shadow-sm)]" "bg-[var(--color-secondary)]" "hover:bg-[var(--color-secondary-hover)]" "text-[var(--color-secondary-text)]" "border" "border-[var(--color-border)]"
      SCHEMES = {
        primary: "bg-[var(--color-primary)] hover:bg-[var(--color-primary-hover)] text-[var(--color-primary-text)] shadow-[var(--shadow-sm)]",
        secondary: "bg-[var(--color-secondary)] hover:bg-[var(--color-secondary-hover)] text-[var(--color-secondary-text)] border border-[var(--color-border)]"
      }.freeze
      
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "px-3" "py-1.5" "text-xs" "px-4" "py-2" "text-sm" "px-6" "py-3" "text-base"
      SIZES = {
        sm: "px-3 py-1.5 text-xs",
        md: "px-4 py-2 text-sm",
        lg: "px-6 py-3 text-base"
      }.freeze
    end
  end
end
```

#### When to Add Safelist Comments

Add safelist comments for any constant containing Tailwind classes:
- `SCHEMES`, `SIZES`, `VARIANTS` - Common component styling constants
- `ICON_SIZES`, `SPACINGS`, `COLORS` - Any hash/array with class strings
- Method return values that build class strings dynamically

**Note:** Inline classes in methods don't need safelist comments—only constants stored as Ruby class variables or constants.

## Host Application Configuration

### 1. Install tailwindcss-rails Gem

```ruby
# Gemfile
gem 'tailwindcss-rails', '~> 4.0'
```

Then run:

```bash
bundle install
```

### 2. Set Up Application CSS

Create or update `app/assets/stylesheets/application.css`:

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

/* Scan FlatPack component classes */
@source "../../../flat_pack/app/components";

/* Import FlatPack CSS Variables */
:root {
  /* Copy CSS variables from FlatPack's variables.css */
  /* Or include them inline as shown in the example below */
  --color-primary: oklch(0.52 0.26 250);
  /* ... other variables */
}
```

### 3. Configure Tailwind Content Scanning

Tailwind CSS 4 uses CSS-based scanning with `@source`. No `tailwind.config.js` is required for FlatPack.

Ensure your Tailwind entry CSS includes:

```css
@import "tailwindcss";
@source "../../../flat_pack/app/components";
```

### 4. Build CSS

Build Tailwind CSS:

```bash
bundle exec tailwindcss -i app/assets/stylesheets/application.css -o app/assets/builds/application.css --watch
```

Or use a Procfile.dev for development:

```yaml
web: bin/rails server -p 3000
css: bundle exec tailwindcss -i app/assets/stylesheets/application.css -o app/assets/builds/application.css --watch
```

## OKLCH Color Space

FlatPack uses OKLCH for perceptually uniform colors:

### Syntax

```
oklch(L C H)
  L = Lightness (0-1)
  C = Chroma (0-0.4)
  H = Hue (0-360)
```

### Examples

```css
@theme {
  /* Blue */
  --color-blue: oklch(0.62 0.22 250);
  
  /* Same blue, lighter */
  --color-blue-light: oklch(0.82 0.22 250);
  
  /* Same blue, darker */
  --color-blue-dark: oklch(0.42 0.22 250);
}
```

### Advantages

1. **Perceptually uniform** - Lightness changes feel consistent
2. **Wide gamut** - More vibrant colors
3. **Better than HSL** - No hue shifting with lightness changes
4. **Future-proof** - Native CSS support

### Browser Support

- Chrome 111+
- Firefox 113+
- Safari 15.4+

Fallbacks not needed as these are modern browsers.

## Dark Mode Implementation

### System Preference Only

FlatPack uses `prefers-color-scheme` media query:

```css
@theme {
  --color-background: oklch(1.0 0 0); /* White */
}

@media (prefers-color-scheme: dark) {
  @theme {
    --color-background: oklch(0.15 0.01 250); /* Dark */
  }
}
```

No JavaScript, no toggle, just CSS.

### Why Not `dark:` Class?

Tailwind v4 still supports `dark:` prefix, but FlatPack doesn't use it:

**Advantages of System Preference:**
- No JavaScript required
- Instant switching
- Respects OS settings
- No state management
- No flash of wrong theme

**When to Use `dark:` Class:**
If your app needs manual toggle, implement it in your application (not the component library).

## Customization

### Override FlatPack Variables

```css
/* app/assets/stylesheets/application.css */
@import "flat_pack/variables.css";

@theme {
  /* Your custom colors */
  --color-primary: oklch(0.55 0.25 270); /* Purple */
  --color-primary-hover: oklch(0.45 0.28 270);
}
```

Your values override FlatPack's defaults.

### Add New Variables

```css
@theme {
  /* FlatPack variables */
  @import "flat_pack/variables.css";
  
  /* Your variables */
  --color-brand-purple: oklch(0.55 0.25 270);
  --spacing-custom: 2.5rem;
}
```

### Per-Component Customization

Use system arguments:

```erb
<%= render FlatPack::Button::Component.new(
  text: "Custom",
  class: "!bg-gradient-to-r from-purple-500 to-pink-500"
) %>
```

The `!` prefix (via TailwindMerge) ensures your classes win.

## Performance

### CSS File Size

FlatPack's CSS is minimal:
- Only variable definitions
- No component styles (uses utilities)
- Total: ~3KB uncompressed

### Runtime Performance

- CSS variables are fast (browser-native)
- No JavaScript for theming
- No recalculation overhead

### Build Performance

- Tailwind scans components once
- Variables are static
- No dynamic generation

## Debugging

### Variables Not Applying

1. **Check import order:**
   ```css
   @import "tailwindcss";       /* First */
   @import "flat_pack/variables.css"; /* Second */
   /* Your overrides */          /* Third */
   ```

2. **Inspect computed styles:**
   DevTools → Computed → Filter "color-primary"

3. **Verify Tailwind is running:**
   ```bash
   bin/rails tailwindcss:watch
   ```

### Classes Not Generated

1. **Check safelist comments:**
   If classes from Ruby constants aren't appearing, verify safelist comments are present:
   ```ruby
   # Tailwind CSS scanning requires these classes to be present as string literals.
   # DO NOT REMOVE - These duplicates ensure CSS generation:
   # "px-3" "py-1.5" "text-xs"
   SIZES = {
     sm: "px-3 py-1.5 text-xs"
   }.freeze
   ```
   See [Safelist Comments for Ruby Constants](#safelist-comments-for-ruby-constants) for details.

2. **Check @source paths:**
   ```bash
   bundle info flat_pack
   # Verify path matches @source comment
   ```

3. **Restart Tailwind:**
   Tailwind needs to detect new sources.

4. **Check for typos:**
   ```ruby
   "bg-[var(--color-primary)]"  # Correct
   "bg-[var(--color-primary]"   # Wrong - missing ]
   ```

## Best Practices

1. **Use CSS variables for colors** - Don't hardcode
2. **Namespace custom variables** - Prefix with `--my-app-*`
3. **Test in dark mode** - Always verify both modes
4. **Use OKLCH** - Better than RGB/HSL
5. **Keep specificity low** - Let Tailwind classes win
6. **Add safelist comments to constants** - Always include safelist comments above Ruby constants containing Tailwind classes to ensure CSS generation

## Component Development Guidelines

When creating new FlatPack components:

1. **Store reusable classes in constants:**
   ```ruby
   SIZES = {
     sm: "px-3 py-1.5 text-xs",
     md: "px-4 py-2 text-sm"
   }.freeze
   ```

2. **Always add safelist comments above constants:**
   ```ruby
   # Tailwind CSS scanning requires these classes to be present as string literals.
   # DO NOT REMOVE - These duplicates ensure CSS generation:
   # "px-3" "py-1.5" "text-xs" "px-4" "py-2" "text-sm"
   SIZES = { ... }.freeze
   ```

3. **Extract all unique classes** - Don't miss any classes, including modifiers and arbitrary values

4. **Test CSS generation** - After creating a component, verify all classes appear in the compiled CSS

5. **Follow naming conventions:**
   - `SCHEMES` for color/styling variations
   - `SIZES` for size variations
   - `VARIANTS` for behavioral variations
   - Constants should be frozen (`.freeze`)

## Migration Checklist

For projects upgrading to Tailwind CSS 4:

1. **Remove `tailwind.config.js`** - Not needed
2. **Convert config to `@theme`** - Move to CSS
3. **Update content paths** - Use `@source` comments
4. **Test dark mode** - May need adjustments
5. **Update plugins** - Confirm Tailwind 4 compatibility

## Resources

- [Tailwind CSS 4 Docs](https://tailwindcss.com/blog/tailwindcss-v4-alpha)
- [OKLCH Color Picker](https://oklch.com/)
- [CSS @theme MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/@theme)

## Next Steps

- [Theming Guide](../theming.md)
- [Dark Mode Guide](../dark_mode.md)
- [Asset Pipeline](assets.md)
